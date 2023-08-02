public class GNE_CRM_Note_TriggerHandler {
    public static void onAfterInsert(){
        GNE_CRM_Note_TriggerHandlerLogic.updateParent();
    }
    
    public static void onAfterUpdate(){
        GNE_CRM_Note_TriggerHandlerLogic.updateParent();
    }
}