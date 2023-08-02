public class GNE_CRM_Attachment_TriggerHandlerLogic {
    public static void updateParent() {
        Set<Id> parentIds = new Set<Id>();
        for(Attachment record : (Attachment[]) Trigger.new){
            parentIds.add(record.ParentId);
        }
        
        updateParent340BCases(parentIds); 
    }
    
    /* we want update only LastModifiedDate */
    private static void updateParent340BCases(Set<Id> parentIds) {
        update [SELECT Id FROM GNE_CRM_340B_Case__c WHERE Id IN: parentIds];        
    }

}