public class GNE_CRM_Attachment_TriggerHandler {
    public static void onAfterInsert(){
        GNE_CRM_Attachment_TriggerHandlerLogic.updateParent();
    }
    
    public static void onAfterUpdate(){
        GNE_CRM_Attachment_TriggerHandlerLogic.updateParent();
    }
}