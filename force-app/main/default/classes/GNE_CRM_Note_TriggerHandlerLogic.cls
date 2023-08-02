public class GNE_CRM_Note_TriggerHandlerLogic {
    public static void updateParent() {
        Set<Id> parentIds = new Set<Id>();
        for(Note record : (Note[]) Trigger.new){
            parentIds.add(record.ParentId);
        }
        
        updateParent340BCases(parentIds); //sObject to update : GNE_CRM_340B_Case__c
    }
    
    /* we want update only LastModifiedDate */
    private static void updateParent340BCases(Set<Id> parentIds) {
        update [SELECT Id FROM GNE_CRM_340B_Case__c WHERE Id IN: parentIds];        
    }
}