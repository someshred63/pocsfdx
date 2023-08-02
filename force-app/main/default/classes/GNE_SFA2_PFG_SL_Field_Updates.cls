public with sharing class GNE_SFA2_PFG_SL_Field_Updates {
    
    private static void setAddressChangedFlag(List<SFA2_PFG_Storage_Location_gne__c> triggerOld, List<SFA2_PFG_Storage_Location_gne__c> triggerNew) {
        Set<Id> pendingList = new Set<Id> ();
        
        for(ProcessInstance pr : [Select Id, Status, TargetObjectId from ProcessInstance 
                                  where Status = :GNE_SFA2_PFG_Util.APPROVAL_STATUS_PENDING and TargetObjectId IN :triggerNew]) {
            pendingList.add(pr.TargetObjectId);
        }

        Integer index = 0;
        for(SFA2_PFG_Storage_Location_gne__c slNew : triggerNew) {
            SFA2_PFG_Storage_Location_gne__c slOld = triggerOld[index++];
            
            if(pendingList.contains(slNew.Id)) {
                continue;
            }
            
            Boolean isAddressChanged = false;
            for(String addressFieldName : GNE_SFA2_PFG_SL_Trigger_Helper.SL_ADDRESS_FIELDS) {
                if(slNew.get(addressFieldName) != slOld.get(addressFieldName)) {
                    slNew.Address_Changed_gne__c = true;
                    slNew.Status_gne__c = GNE_SFA2_PFG_Util.STORAGE_LOCATION_STATUS_SUBMITTED;
                    break;
                } 
            }
        }
    }
    
    private static void setManager(List<SFA2_PFG_Storage_Location_gne__c> triggerOld, List<SFA2_PFG_Storage_Location_gne__c> triggerNew) {
        Integer index = 0;
        for(SFA2_PFG_Storage_Location_gne__c slNew : triggerNew) {
            SFA2_PFG_Storage_Location_gne__c slOld = triggerOld!=null ? triggerOld[index++] : null;
            
            if(slNew.User_gne__c!=null && ((slOld==null && slNew.Manager_gne__c==null) || (slOld!=null && slOld.User_gne__c!=slNew.User_gne__c))) {
                slNew.Manager_gne__c = GNE_SFA2_PFG_Util.getManagerForUser(slNew.User_gne__c);
            }
        }
    }
    
    public static void onBeforeUpdate(List<SFA2_PFG_Storage_Location_gne__c> triggerOld, List<SFA2_PFG_Storage_Location_gne__c> triggerNew) {
        setAddressChangedFlag(triggerOld, triggerNew);
        setManager(triggerOld,triggerNew);
    }

    public static void onBeforeInsert(List<SFA2_PFG_Storage_Location_gne__c> triggerNew) {
        setManager(null,triggerNew);
    }
    
    public static void onBeforeDelete(List<SFA2_PFG_Storage_Location_gne__c> triggerOld) {
    
    }
}