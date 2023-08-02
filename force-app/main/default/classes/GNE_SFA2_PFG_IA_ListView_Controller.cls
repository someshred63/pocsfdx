public with sharing class GNE_SFA2_PFG_IA_ListView_Controller extends GNE_SFA2_PFG_Base_Controller {
    public String currentSalesForce {get; set;}
    public List<SelectOption> availableSalesForces {private get; private set;}
    public String currentProductId {get; set;}
    public List<SelectOption> availableProducts {private get; private set;}
    public String pfgType {get; private set;}
    public String inputTextValue {get; set;}
    public PBT_ListenerEngine listEngine {get; set;}
    
    private Set<Id> recordsToSelectAfterGenerateShipment;
    private List<SFA2_PFG_Transaction_gne__c> allocTransfers;
    
    
    public GNE_SFA2_PFG_IA_ListView_Controller() {
        pfgType = 'HC';
        listEngine = new PBT_ListenerEngine(this);
    }
    
    protected override PageReference intInitCotroller() {
        PageReference pageRef = null;
        getAvailableSalesForces();
        return pageRef;
    }
    
    public List<SelectOption> getAvailableSalesForces() {
        availableSalesForces = new List<SelectOption>{new SelectOption('','All Sales Forces')};
        
        Set<String> activeUserBrands = GNE_SFA2_PFG_Config.ACTIVE_BRANDS_FOR_HC;
        Set<String> availableBrands = GNE_SFA2_PFG_Util.getBrandNamesBySalesforceActiveBrands(activeUserBrands);
        Set<String> brandsWithAvailableProducts = GNE_SFA2_PFG_Util.getBrandNames();
    	availableBrands.RetainAll(brandsWithAvailableProducts);        
        
        if (availableBrands.size() > 0){
        	for(String value : availableBrands) {
        	    availableSalesForces.add(new SelectOption(value,value));    
	        }
	        availableSalesForces.sort();
        }
        
        return availableSalesForces;
    }
    
    public void setCurrentSalesForce(String newValue) {
        currentProductId = null;
        currentSalesForce = newValue;
    }
    
    public List<SelectOption> getAvailableProducts() {
        availableProducts = new List<SelectOption>{new SelectOption('','All Products')};
        
        List<Product_vod__c> prods = GNE_SFA2_PFG_Util.getProductsForBrand(currentSalesForce); 
        
        for(Product_vod__c prod : prods) {
            if(GNE_SFA2_PFG_Util.isProductHandCarry(prod.Id)) {
                availableProducts.add(new SelectOption(prod.Id,prod.Name));
            }   
        }
        
        return availableProducts;
    }
    
    public List<SFA2_PFG_Transaction_gne__c> getAllocationTransferRecs() {
        Set<String> brandNames = (currentSalesForce!=null && currentSalesForce!='' && (currentProductId==null || currentProductId==''))
                                        ? new Set<String>{currentSalesForce} : new Set<String>();
        Set<Id> pfgProdIds = (currentProductId!=null && currentProductId!='') ? new Set<Id>{(Id)currentProductId} : new Set<Id>();
            
        return allocTransfers = GNE_SFA2_PFG_Util.getAllocTransfersAssignedToCSs(brandNames, pfgProdIds);
    }
    
    public PageReference generateShipment() {
        PageReference result = null;
        
        List<SFA2_PFG_Transaction_gne__c> handCarryAllocs = new List<SFA2_PFG_Transaction_gne__c>();
        Set<Id> selectedIds = listEngine.getSelectedRecords();
        if(selectedIds!=null && !selectedIds.isEmpty()) {
            for(SFA2_PFG_Transaction_gne__c allocRec : allocTransfers) {
                if(selectedIds.contains(allocRec.Id)) {
                    handCarryAllocs.add(allocRec);
                }
            }
        }
    
        if(handCarryAllocs.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, System.Label.GNE_SFA2_PFG_SELECT_ALLOCATION_TRANSFER));    
        } else {
            System.debug('handCarryAllocs = ' + handCarryAllocs);
            try {
                recordsToSelectAfterGenerateShipment = GNE_SFA2_PFG_Util.generateShipment(handCarryAllocs);
                
                if(!recordsToSelectAfterGenerateShipment.isEmpty()) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, System.Label.GNE_SFA2_PFG_CS_HAVE_NO_STORAGE_LOCATION_INFO));
                }
                
                listEngine.setSelectedRecords(recordsToSelectAfterGenerateShipment, true);
            } catch(Exception ex) {
                result = setErrorPageReference(ex);
            }
        }
        return result;
    }
    
    public class PBT_ListenerEngine extends GNE_SFA2_PBT_Controller.ListenerEngine {
        private GNE_SFA2_PFG_IA_ListView_Controller controller;
        
        public PBT_ListenerEngine(GNE_SFA2_PFG_IA_ListView_Controller controller) {
            super();
            this.controller = controller;
        }
        public override Object getColumnValueForRecord(SObject obj, String columnName) {
            Object result = null;
            SFA2_PFG_Transaction_gne__c allocRec = (SFA2_PFG_Transaction_gne__c)obj;
            
            if(columnName== 'salesForce') {
                result = allocRec.Product_gne__r.Parent_Product_vod__r.Name;
            }
            
            return result;
        }
    }
}