public with sharing class GNE_SFA2_PFG_CreateInventoryCountCtrl extends GNE_SFA2_Dynamic_VF_Edit_Create {
    public List<SFA2_PFG_Inventory_Count_gne__c> inventoryItems {get; set;} 
    public List<SFA2_PFG_to_User_Detail_gne__c> userDetailList {get; set;}  
    public List<InventoryWrapper> inventoryCountsWrapperList {get; private set;}
    public Map<Integer,InventoryWrapper> inventoryCountsWrapperMap {private get; private set;}
    public String handCarryProductIds {get; private set;}
    public String handCarryLotIds {get; private set;}
        
    public String rowIdx {get; set;}    
    public Integer populateRowId {get; set;}
    public String productId {get; set;}
    public String lotId {get; set;}
    
    public GNE_SFA2_PFG_CreateInventoryCountCtrl(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_PFG_CreateInvCountLayout');
        if(controller.getRecord().Id == null){
            myObject = new SFA2_PFG_Inventory_Count_gne__c();
        }
        
        Id currentUserId = UserInfo.getUserId();
       
        userDetailList = GNE_SFA2_PFG_DAO.getPFGToUserDetailsForUsersWithPositiveQty(new Set<Id>{ currentUserId }, new Set<String>{GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC});
        List<SFA2_PFG_Inventory_Count_gne__c> inventoryItems = createInvCounts(userDetailList);
        populateInvCountsWrapperList(inventoryItems);
        
        Set<Id> brandProdIds = GNE_SFA2_PFG_Util.getProductIdsForBrands(GNE_SFA2_PFG_Util.getBrandNamesByUserTerritory(currentUserId));
        Set<Id> hcProdIds = GNE_SFA2_PFG_Util.getProductIdsForDistMethod(GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC);
        brandProdIds.retainAll(hcProdIds);
        Set<Id> lotIds = new Set<Id>();
        
        // Make sure that no record will be displayed in Product Lookup
        if(brandProdIds.isEmpty()) {
        	brandProdIds.add(currentUserId);
        } else {
        	for(SFA2_Lot_Catalog_gne__c lotC : GNE_SFA2_PFG_DAO.getLotCatalogsForProdIds(brandProdIds)) {
        		lotIds.add(lotC.Id);
        	}	
        }
        
        handCarryProductIds = String.join(new List<Id>(brandProdIds),',');
        
        // Make sure that no record will be displayed in Product Lookup
        if(lotIds.isEmpty()) {
        	lotIds.add(currentUserId);
        }
        
        handCarryLotIds = String.join(new List<Id>(lotIds),',');
    }
    
    public String getPfgActiveMenuItem() {
        return GNE_SFA2_PFG_Base_Controller.MY_PFG_PAGE_NAME;
    }
    
    private List<SFA2_PFG_Inventory_Count_gne__c> createInvCounts(List<SFA2_PFG_to_User_Detail_gne__c> userDetailsList){
        List<SFA2_PFG_Inventory_Count_gne__c> resultList = new List<SFA2_PFG_Inventory_Count_gne__c>();
        Map<String,SFA2_Lot_Catalog_gne__c> lotCatalogs = GNE_SFA2_PFG_Util.getLotCatalogList(userDetailsList);
        for(SFA2_PFG_to_User_Detail_gne__c uDetail : userDetailList){
            SFA2_Lot_Catalog_gne__c lotC = lotCatalogs.get(uDetail.Lot_NO_gne__c);
            if(lotC!=null) {
                SFA2_PFG_Inventory_Count_gne__c invCount = new  SFA2_PFG_Inventory_Count_gne__c(
                    Expected_Quantity_gne__c = uDetail.Qty_Total_Available_gne__c);
                GNE_SFA2_PFG_IC_Field_Updates.populateInvCountFieldsFromLotCatalog(invCount,lotC);
                invCount.Product_gne__r = lotC.Product_gne__r;
                resultList.add(invCount);
            }
        }
        
        return resultList;
        
    }
        
    public void populateInvCountsWrapperList(List<SFA2_PFG_Inventory_Count_gne__c> inventoryItems) {
        inventoryCountsWrapperList = new List<InventoryWrapper>();
        inventoryCountsWrapperMap = new Map<Integer,InventoryWrapper>();
        Integer idx = 0;
        for(SFA2_PFG_Inventory_Count_gne__c invItem : inventoryItems){
            InventoryWrapper invWrap = new InventoryWrapper(invItem,idx);   
            inventoryCountsWrapperList.add(invWrap);
            inventoryCountsWrapperMap.put(idx,invWrap);
            idx++;      
        }
    }
    
    public PageReference saveInventory() {
        PageReference result = null;
        try {
            result = IntSaveInventory();
        } catch(Exception ex) {
            result = GNE_SFA2_PFG_Base_Controller.setErrorPageReference(GNE_SFA2_PFG_Base_Controller.SAVE_ERROR_MESSAGE_PREFIX, ex);
        }
        
        return result;
    }
    
    public PageReference IntSaveInventory(){
        PageReference result = null;
        
        SFA2_PFG_Inventory_Count_gne__c mainInvCount = (SFA2_PFG_Inventory_Count_gne__c)myObject;
	    List<SFA2_PFG_Inventory_Count_gne__c> inventoryItems = new List<SFA2_PFG_Inventory_Count_gne__c>();
	    Set<String> lotIds = new Set<String>();
	    for(InventoryWrapper wrapper : inventoryCountsWrapperList){
	    	if(wrapper.newRow && String.isNotBlank(wrapper.inventoryCount.Lot_gne__c)) {
	        	lotIds.add(wrapper.inventoryCount.Lot_gne__c);
	        }
	    }
	        
	    Map<Id,SFA2_Lot_Catalog_gne__c> lotCatalogs = new Map<Id,SFA2_Lot_Catalog_gne__c>(GNE_SFA2_PFG_DAO.getLotCatalogsForIds(lotIds));
	     
	    for(InventoryWrapper wrapper : inventoryCountsWrapperList){
	    	SFA2_PFG_Inventory_Count_gne__c invC = wrapper.inventoryCount.clone();
	    	if(wrapper.newRow && String.isNotBlank(invC.Lot_gne__c)) {
	        	GNE_SFA2_PFG_IC_Field_Updates.populateInvCountFieldsFromLotCatalog(invC,lotCatalogs.get(invC.Lot_gne__c));
	        }
	        invC.Inventory_Type_gne__c = mainInvCount.Inventory_Type_gne__c;
	        inventoryItems.add(invC);
	    }
        
        Boolean isOk = false;
	        
	    try {
	      	validate(inventoryItems);
            GNE_SFA2_PFG_Util.saveInventoryCounts(inventoryItems);
	        isOk = true;
	    } catch(GNE_SFA2_PFG_Base_Controller.InvalidInputValueException ex) {
           	for(String errorMsg : ex.errorMessages) {
              	Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR,errorMsg));
           	}
    	} catch(Exception ex) {
	    	Apexpages.addMessages(ex);
	    }
	        
	    if(isOk) {
	    	result = GNE_SFA2_PFG_Base_Controller.redirectToReturnUrl();
	    }
        
        return result;
    }
    
    private void validate(List<SFA2_PFG_Inventory_Count_gne__c> inventoryItems) {
    	List<String> errorMessages = new List<String>();
    	
    	if(inventoryItems.isEmpty()) {
    		errorMessages.add('Please select at least one Inventory Item.');
    	}
    	
    	Set<String> lotNos = new Set<String>();
    	Integer i = 0;
        Boolean singleMode = inventoryCountsWrapperList.size()==1;
        
    	for(SFA2_PFG_Inventory_Count_gne__c invC : inventoryItems) {
    		String rowPrefix = singleMode ? '' : ('Row ' + ++i + ': ');
    		
    		if(String.isBlank(invC.Product_gne__c)) {
    			errorMessages.add(
                    rowPrefix + 'NDC' + GNE_SFA2_PFG_Base_Controller.MISSING_REQUIRED_FIELD_VALUE);
    		}
    		
    		if(String.isBlank(invC.Lot_gne__c)) {
    			errorMessages.add(
                    rowPrefix + SFA2_PFG_Inventory_Count_gne__c.Lot_gne__c.getDescribe().getLabel() + 
                    GNE_SFA2_PFG_Base_Controller.MISSING_REQUIRED_FIELD_VALUE);
    		} else {
    			if(lotNos.contains(invC.Lot_gne__c)) {
    				errorMessages.add(
                    	rowPrefix + SFA2_PFG_Inventory_Count_gne__c.Lot_gne__c.getDescribe().getLabel() + 
						GNE_SFA2_PFG_Base_Controller.VALUE_ALREADY_IN_USE_MSG);
    			}
    			
    			lotNos.add(invC.Lot_gne__c);
    		}
    		
    		if(invC.Count_gne__c!=null && invC.Count_gne__c<0) {
    			errorMessages.add(
                    rowPrefix + System.Label.GNE_SFA2_PFG_COUNT_MUST_BE_EQUAL_OR_GREATER_THAN_ZERO);
    		} else if(!GNE_SFA2_PFG_Base_Controller.validateIsInteger(invC.Count_gne__c)) {
    			errorMessages.add(
                    rowPrefix + System.Label.GNE_SFA2_PFG_COUNT_IS_TOO_LARGE);
    		}
    	}
    	
    	if(!errorMessages.isEmpty()) {
            throw new GNE_SFA2_PFG_Base_Controller.InvalidInputValueException(errorMessages);
    	} 
    }
    
    public PageReference addInventoryCount(){
        Integer maxUsedIdx = 0;
        for(Integer usedIdx : inventoryCountsWrapperMap.keySet()) {
            maxUsedIdx = Math.max(usedIdx, maxUsedIdx);
        }
        
        Integer idx = Math.max(maxUsedIdx+1,inventoryCountsWrapperList.size());
        InventoryWrapper newItem = new InventoryWrapper(null,idx);
        inventoryCountsWrapperList.add(newItem);
        inventoryCountsWrapperMap.put(idx,newItem);
        return null;
    }
    
    public PageReference removeInventoryCount() {
        Integer idx = Integer.valueOf(rowIdx);
        inventoryCountsWrapperMap.remove(idx);
        
        Integer idxToRemove=0;
        for(InventoryWrapper newItem : inventoryCountsWrapperList) {
            if(newItem.rowNumber == idx) {
                break;
            }
            idxToRemove++;
        }
        
        inventoryCountsWrapperList.remove(idxToRemove);
        
        return null;
    }
        
    public PageReference productSelected() {
        return productSelected(false);
    }
    
    private PageReference productSelected(Boolean fromActionOnLot) {
        Integer rowIdxValue = Integer.valueOf(rowIdx);
        InventoryWrapper wrapper = inventoryCountsWrapperMap.get(rowIdxValue);
        
        wrapper.inventoryCount.Product_gne__c = null;
        wrapper.inventoryCount.Product_gne__r = null;
        wrapper.inventoryCount.NDC_gne__c = null;
        wrapper.inventoryCount.UOM_gne__c = null;
        wrapper.lotWhereExpression = wrapper.getLotWhereExpression(null);
        
        if(!fromActionOnLot) {
            lotId = null;
            lotSelected();
        }
        
        if(String.isNotBlank(productId)) {
            for(Product_vod__c prod : GNE_SFA2_PFG_DAO.getProductsById(new Set<String>{productId})) {
                wrapper.inventoryCount.Product_gne__c = prod.Id;
                wrapper.inventoryCount.Product_gne__r = prod;
                wrapper.inventoryCount.NDC_gne__c = prod.NDC_Number_gne__c;
                wrapper.inventoryCount.UOM_gne__c = prod.UOM_gne__c;
                
                wrapper.lotWhereExpression = wrapper.getLotWhereExpression(prod.Id);
                break;
            }
        }
        
        return null;
    }
    
    
    public PageReference lotSelected() {
        Integer rowIdxValue = Integer.valueOf(rowIdx);
        InventoryWrapper wrapper = inventoryCountsWrapperMap.get(rowIdxValue);
        
        wrapper.inventoryCount.Lot_gne__c = null;
        wrapper.inventoryCount.Expiration_Date_gne__c = null;
        
        if(String.isNotBlank(lotId)) {
            for(SFA2_Lot_Catalog_gne__c lotC : GNE_SFA2_PFG_DAO.getLotCatalogsForIds(new Set<String>{lotId})) {
                wrapper.inventoryCount.Expiration_Date_gne__c = lotC.Expiration_Date_gne__c;
                wrapper.inventoryCount.Lot_gne__c = lotC.Id;
                
                if(lotC.Product_gne__c!=wrapper.inventoryCount.Product_gne__c) {
                    productId = lotC.Product_gne__c;
                    productSelected(true);
                }
                break;
            }
        }
        
        return null;
    }
    
    // wrapper class
    public class InventoryWrapper{
        public SFA2_PFG_Inventory_Count_gne__c inventoryCount{get;set;}
        public Boolean newRow {get; set;}
        public Integer rowNumber {get; set;}
        public String lotWhereExpression {get; set;}
        public String productWhereExpression {get; set;}
        
        public InventoryWrapper(SFA2_PFG_Inventory_Count_gne__c invCount, Integer rowNumber){
            this.rowNumber = rowNumber;
            inventoryCount = invCount;
            productWhereExpression = 'Product_Type_vod__c = \'PFG\'';
            
            if(inventoryCount==null) {
                inventoryCount = new SFA2_PFG_Inventory_Count_gne__c(
                    Count_gne__c = 0.0,
                    Expected_Quantity_gne__c = 0.0);
                lotWhereExpression = getLotWhereExpression(null);
                newRow = true;
                
            } else {
                newRow = false;
                lotWhereExpression = getLotWhereExpression(invCount.Product_gne__c);
            }   
        }
        
        public String getLotWhereExpression(Id productId) {
            String result;

            if(productId==null) {
                result = 'Product_gne__r.Product_Type_vod__c = \'PFG\' AND Distribution_Method_gne__c = \'' + GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC + '\'';
            } else {
                result = 'Product_gne__c = \''+ productId +'\' AND Distribution_Method_gne__c = \'' + GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC + '\'';
            }
            
            return result;
        }
    }
}