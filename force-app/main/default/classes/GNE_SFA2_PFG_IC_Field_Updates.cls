public without sharing class GNE_SFA2_PFG_IC_Field_Updates {
    private static Boolean isCreationMode;
    
    public static Boolean getIsCreationMode() {
        return isCreationMode == true;
    }
    
    public static void setIsCreationMode(Boolean value) {
        isCreationMode = value;
    }
    
    public static void onBeforeInsert(List<SFA2_PFG_Inventory_Count_gne__c> triggerNew) {
        setIsCreationMode(true);
        setFieldsUpdates(triggerNew);
    }
    
    public static void onBeforeUpdate(List<SFA2_PFG_Inventory_Count_gne__c> triggerNew, List<SFA2_PFG_Inventory_Count_gne__c> triggerOld) {

    }
    
    private static void setFieldsUpdates(List<SFA2_PFG_Inventory_Count_gne__c> triggerNew){
    	Id currentUserId = UserInfo.getUserId();
    	GNE_SFA2_PFG_Util.cacheStorageLocationsByUserIds(new Set<Id>{currentUserId}, true);
        SFA2_PFG_Storage_Location_gne__c storageLocation = GNE_SFA2_PFG_Util.getApprovedStorageLocationForUser(currentUserId);
        Map<String,SFA2_Lot_Catalog_gne__c> lotCatalogs = GNE_SFA2_PFG_Util.getLotCatalogList(triggerNew);
        
        for(SFA2_PFG_Inventory_Count_gne__c inv : triggerNew){
            inv.Submitted_Date_gne__c = Date.today();
            inv.Inventory_For_gne__c = currentUserId;
            inv.Inventory_Count_Date_gne__c = Date.today();
            inv.Status_gne__c = GNE_SFA2_PFG_Util.INVENTORY_STATUS_SUBMITTED;
            inv.PFG_Storage_Location_gne__c = storageLocation!=null ? storageLocation.Id : null;
            SFA2_Lot_Catalog_gne__c lotC = lotCatalogs.get(inv.Lot_gne__c); 
            
            if(lotC!=null) {
                populateInvCountFieldsFromLotCatalog(inv,lotC);
            }
        }
    }
    
    public static void populateInvCountFieldsFromLotCatalog(SFA2_PFG_Inventory_Count_gne__c ic, SFA2_Lot_Catalog_gne__c lotC) {
        ic.Product_gne__c = lotC.Product_gne__c;
        ic.Lot_gne__c = lotC.Name;
        ic.UOM_gne__c = lotC.Product_gne__r.UOM_gne__c;
        ic.NDC_gne__c = lotC.Product_gne__r.NDC_Number_gne__c;
        ic.Expiration_Date_gne__c = lotC.Expiration_Date_gne__c;
    }
}