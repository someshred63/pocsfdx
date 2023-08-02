/*********************************************************************************************
*  @author: Sebastian Karczmarski, Roche (contractor)
*  @email: sebastian.karczmarski@contractors.roche.com   
*  Created: 2013-05-24
*  Project: OTR2
*  Description: REST Webservice, returns a list of Products for the specified user id (unixId).             
**********************************************************************************************/
@RestResource(urlMapping='/iPhoneGetUserProductsConfig/*')
global with sharing class iPhone_Get_User_ProductsConfig_gne {
	
	@HttpPost 
    global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, String unixId) {    	
    	return iPhone_Commons_gne.buildResponse(
	    		new GetUserProductsConfigResponseBuilder(), 
	    		new iPhone_Commons_gne.DefaultDeltaArgs(lastSyncDate, unixId)    	
    	);     	      		
    }
    
    class GetUserProductsConfigResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder { 
    	
    	protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {    		
    		User user = iPhone_DAO.getUserByExternalId(args.unixId);	
    		if(user == null)
				throw new iPhone_Commons_gne.IPhoneException('User not found: ' + args.unixId);  	    	
				 
    		return iPhone_DAO.getUserSetupProducts(user.Id);
    	} 	
    	     	 			
    	protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
    		return new GetUserProductsConfigRecord((Product_vod__c)sObj);    		    		
    	}    
    	
    	protected override iPhone_Commons_gne.DeltaCalculator getDeltaCalculator(String lastSyncDate){
        	return new UserProductDeltaCalculator(lastSyncDate);
        }   	    	    
    }      
    
    class UserProductDeltaCalculator extends iPhone_Commons_gne.DeltaCalculator{
    	
    	public UserProductDeltaCalculator(String lastSyncDate){
    		super(lastSyncDate);    		    		
    	}
    	
		protected override String getDeltaStatus(SObject sObj) {
			if(lastSynchronized == null || sObj == null)
				return null;
			
			Product_vod__c product = (Product_vod__c)sObj;
			Datetime created = null, lastModified = null;
			
			My_Setup_Products_vod__c mySetupProduct = product.My_Setup_Products_vod__r.get(0);
			created = mySetupProduct.CreatedDate;
			lastModified = mySetupProduct.LastModifiedDate;
			
			if(created >= lastSynchronized) { 
				return STAT_INSERT;
			} else {
				if(lastModified >= lastSynchronized) {
					return STAT_UPDATE; 
				} else {
					return STAT_SYNC; 
				}
			}			
		}							
	}
              
    class GetUserProductsConfigRecord extends iPhone_Commons_gne.DeltaRecord {  
    	public final String name;	
    
    	public GetUserProductsConfigRecord(Product_vod__c product) {
    		this.id = product.id;
    		this.name = product.Name;
    	}    	
    }        
}