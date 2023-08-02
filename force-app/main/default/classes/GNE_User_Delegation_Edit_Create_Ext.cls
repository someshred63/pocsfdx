public with sharing class GNE_User_Delegation_Edit_Create_Ext {
    private GNE_User_Delegation__c userDelegation;

    public String pageErrorMessage { get; set; }
    public Boolean isUsernameEditable { get {return EMS_Access.isAdmin();} }
    public RecordType recordType {
        get {
            if (recordType == null) {
                recordType = [SELECT Id FROM RecordType WHERE SobjectType = 'GNE_User_Delegation__c' AND DeveloperName = 'EMS'];
            }
            return recordType;
        }
        private set;
    }

    public GNE_User_Delegation_Edit_Create_Ext(ApexPages.StandardController controller) {
        userDelegation = (GNE_User_Delegation__c) controller.getRecord();
        if (userDelegation.Id == null) {
            userDelegation.RecordTypeId = recordType.Id;
        }

        if (isUsernameEditable == false) {
            userDelegation.Username__c = UserInfo.getUserId();
        }
    }

    public PageReference save() {
        pageErrorMessage = null;
        userDelegation.OwnerId = userDelegation.Username__c;

        Database.UpsertResult ur;
        try {
            ur = Database.upsert(userDelegation);
        } catch (Exception e) {
            if (e.getTypeName() == 'System.DmlException') {
                DmlException eDML = (DmlException) e;
                for (Integer i = 0; i < eDML.getNumDml(); i++) {
                    pageErrorMessage += (i == 0) ? eDML.getDmlMessage(i) : '; ' + eDML.getDmlMessage(i);
                }
            } else {
                pageErrorMessage = e.getMessage();
            }
            return null;
        }
        PageReference result = Page.GNE_User_Delegation_Layout;
        result.getParameters().put('id', userDelegation.Id);
        if (ur.isCreated()) {
            result.getParameters().put('msg', 'Your Delegation was completed successfully');
        }
        return result;
    }
}