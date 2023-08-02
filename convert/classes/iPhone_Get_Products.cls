@RestResource(urlMapping='/iPhoneGetProducts/*')
global with sharing class iPhone_Get_Products {

	@HttpPost 
    global static iPhone_Commons_gne.RestResponse processRequest(String unixId) {
        
        return iPhone_Commons_gne.buildResponse(
                new ProductsResponseBuilder(), 
                new iPhone_Commons_gne.DefaultDeltaArgs(null, unixId)
        );                              
    }
    
    class ProductsResponseBuilder implements iPhone_Commons_gne.ResponseBuilder{
		
    	public iPhone_Commons_gne.RestResponse build(Object args){
	    	String unixId = ((iPhone_Commons_gne.DefaultDeltaArgs)args).unixId;
	    	User user = iPhone_DAO.getUserByExternalId(unixId);
	    	List<ProductRecord>products = new List<ProductRecord>();
	    	
	    	Set<Id>mySetupProdIds = new Set<Id>();
	    	Set<Id>uniqueProducts = new Set<Id>();
	    	
	    	for(Product_vod__c prod: iPhone_DAO.getUserSetupProducts(user.Id)){
	    		mySetupProdIds.add(prod.Id);
	    	}
	    	
	    	for(Product_vod__c prod: getProducts()){
	    		if(uniqueProducts.add(prod.id)){
		    		ProductRecord product = new ProductRecord(prod);
		    		product.ms = mySetupProdIds.contains(prod.Id);
		    		products.add(product);
	    		}
			}
			
	    	for(Product_vod__c prod: getProductSamples(mySetupProdIds)){
	    		if(uniqueProducts.add(prod.id)){
	    			products.add(new ProductRecord(prod));
	    		}
	    	}

			MoleculesFetcher mFetcher = new MoleculesFetcher();
			for(Product_vod__c prod: mFetcher.getOtherProducts()){
				if(uniqueProducts.add(prod.id)){
					ProductRecord prodRecord = new ProductRecord(prod);
					if(prod.Detail_Product_Subtype_Code_gne__c==GNE_SFA2_CreateReferral.PRODUCT_MOLECULE_TYPE || 
						(prod.Product_Type_vod__c == GNE_SFA2_CreateReferral.PRODUCT_DETAIL_TYPE && prod.Detail_Product_Subtype_Code_gne__c == GNE_SFA2_CreateReferral.PRODUCT_THERA_DISEASE_TYPE)){
						prodRecord.ml = true;
					}else{
						prodRecord.ir = true;
					}
					products.add(prodRecord);
				}
			}                    
		    return new DeltaRecordsResponse(products, getTdToMoleculeMappings());
    	}
    } 
    
    class ProductRecord extends iPhone_Commons_gne.RestRecord {
        public String pn; //product name
        public String pp; //Parent_Product_vod__c
        public String pt; //Product_Type_vod__c
        public String ps; //Detail_Product_Subtype_Code_gne__c
        public Boolean ms; //my setup
        public Boolean ml; //is molecule
        public Boolean ac; //is active
        public Boolean ir; //is referral product
        
        
        public ProductRecord(Product_vod__c prod) {
        	this.id = prod.Id;
        	this.pn = prod.Name;
        	this.pp = prod.Parent_Product_vod__c;
        	this.pt = prod.Product_Type_vod__c;
        	this.ps = prod.Detail_Product_Subtype_Code_gne__c;
        	this.ac = prod.active__c;
        	this.ms = false;
        	this.ml = false;
        	this.ir = false;
        }
    }
    
    class TdToMolecule extends iPhone_Commons_gne.RestRecord {
        public String mo; //molecule
        public String td; //tasubta
    }
    
    private class ProductDeltaArgs extends iPhone_Commons_gne.DeltaArgs {
		
        public ProductDeltaArgs(String lastSyncDate) {
            this.lastSyncDate = lastSyncDate;
        }
	}
	
	public class DeltaRecordsResponse extends iPhone_Commons_gne.RestResponse{
    	public final List<RestRecord> products;
    	public final List<TdToMolecule> tdToMoleculeMapping;
        
        public DeltaRecordsResponse(List<RestRecord> products, List<TdToMolecule> tdToMoleculeMapping) {
            this.products = products;
            this.tdToMoleculeMapping = tdToMoleculeMapping;
        }
    }
    
    public static List<Product_vod__c> getProducts(){
    	return [SELECT Name, Parent_Product_vod__c, Product_Type_vod__c, Detail_Product_Subtype_Code_gne__c, TheraDisease_Reference_gne__c, Active__c, LastModifiedDate FROM Product_vod__c ORDER BY Name];
    }
    
    private static List<Product_vod__c> getProductSamples(Set<Id>parentProducts){
    	return [SELECT Id, Name, Parent_Product_vod__c, Product_Type_vod__c, Detail_Product_Subtype_Code_gne__c, Active__c FROM Product_vod__c WHERE Active__c = true AND Parent_Product_vod__c IN :parentProducts ORDER BY Name];
    }
    
    public static List<TdToMolecule> getTdToMoleculeMappings() {
    	List<TdToMolecule>mappings = new List<TdToMolecule>();
        for (TASubTA_To_Molecule_gne__c row : [SELECT Id, Product_TA_SubTA_gne__c, Product_Molecule_gne__c FROM TASubTA_To_Molecule_gne__c]) {
            TdToMolecule mapping = new TdToMolecule();
            mapping.id = row.Id;
            mapping.mo = row.Product_Molecule_gne__c;
            mapping.td = row.Product_TA_SubTA_gne__c;
            mappings.add(mapping);
        }
        return mappings;
    }
    
    global without sharing class MoleculesFetcher {
       
        public List<Product_vod__c> getOtherProducts() {
	    	List<String> productOwnerQueueName = new List<String> ();
			productOwnerQueueName.add(System.Label.GNE_SFA_Canada_Queue);
			productOwnerQueueName.add('GNE-INACTIVE-PROD-QUEUE');
			List<Id> productOwnerQueueId = GNE_Referral_Utils.getProductOwnerQueueId(productOwnerQueueName);
			List<String> lstMedAffairsMoleculeNames = GNE_Referral_Utils.getRestrictedProductName();
            return [SELECT Id, Name, Product_Type_vod__c, Detail_Product_Subtype_code_gne__c, TheraDisease_Reference_gne__c, Parent_Product_vod__c, No_Details_vod__c, Active__c 
            		FROM Product_vod__c WHERE Name not IN :lstMedAffairsMoleculeNames and OwnerId not In : productOwnerQueueId ORDER BY Name];
        }
    }

}