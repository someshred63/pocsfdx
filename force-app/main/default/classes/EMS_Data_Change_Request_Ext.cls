public with sharing class EMS_Data_Change_Request_Ext extends EMS_DynamicVFLoader {


    public EMS_Data_Change_Request_Ext(ApexPages.StandardController controller) {
        super(controller, '/apex/EMS_Data_Change_Request_Layout');
    }

    public static boolean getisAdmin() {
        return EMS_Util.isAdmin();
    }

    public Boolean isAssignedBps { get {
        EMS_Data_Change_Request_gne__c changeRequest = (EMS_Data_Change_Request_gne__c) myObject;
        return changeRequest.Assigned_BPS_gne__c == UserInfo.getUserId();
    } }

    public PageReference close() {
        EMS_Data_Change_Request_gne__c changeRequest = (EMS_Data_Change_Request_gne__c) myObject;
        changeRequest.Status_gne__c = 'Closed' ;

        try {
            upsert changeRequest;
        } catch (Exception e) {
            if (e.getMessage().contains('DUPLICATE_VALUE')) {
                String strId = e.getMessage().substring(e.getMessage().indexof('id:'), e.getMessage().length() - 4);
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, 'Invalid Data: Duplicate Value On Record ' + strId));
                return null;
            } else if (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                //Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR,e.getMessage()));
                Apexpages.addMessages(e);
                return null;
            } else if (e.getMessage().contains('FIELD_FILTER_VALIDATION_EXCEPTION')) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, 'Value does not exist or does not match filter criteria.'));
                return null;
            } else if (e.getMessage().contains('TRANSFER_REQUIRES_READ')) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, 'User you selected can not be owner of the record. New owner must have object read permission.'));
                return null;
            } else if (e.getMessage().contains('CIRCULAR_DEPENDENCY')) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, ''));
                return null;
            } else if (e.getMessage().contains('INVALID_CROSS_REFERENCE_KEY')) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, ''));
                return null;
            } else if (e.getMessage().contains('INSUFFICIENT')) {
                return GNE_SFA2_Util.redirectToAccessDeniedPage();
            } else if (e.getMessage().contains('ENTITY_IS_LOCKED')) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, 'You cannot update the record, because it\'s locked for editing.'));
                return null;
            } else {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, e.getMessage()));
                return null;
            }
            return null;
        }

        PageReference pr = new PageReference('/' + changeRequest.Id);
        pr.setRedirect(true);
        return pr;

    }

}