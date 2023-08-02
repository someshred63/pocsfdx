@isTest(seeAllData=false)
private class AGS_EX_Exclusion_Request_Reminder_Test{
    static User currentUser;
    public static void switchAdminMode(Boolean isAdminMode) {
        if(currentUser == null) {
            currentUser = [ SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        }
        List<GNE_SFA2_Admin_Mode__c> adminModeSetting = [SELECT Id, SetupOwnerId, GNE_SFA2_Is_Admin_Mode__c FROM GNE_SFA2_Admin_Mode__c WHERE SetupOwnerId =: currentUser.Id LIMIT 1];

        if (adminModeSetting.isEmpty()) {
            insert new GNE_SFA2_Admin_Mode__c(SetupOwnerId = currentUser.Id, GNE_SFA2_Is_Admin_Mode__c = isAdminMode);
        } else {
            adminModeSetting.get(0).GNE_SFA2_Is_Admin_Mode__c = isAdminMode;
            update adminModeSetting;
        } 
    }
    
    static testmethod void test() {
        switchAdminMode(true);
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(LastName = 'Exclusion Check', Email = 'exclusioncheck-d@gene.com'));
        contacts.add(new Contact(LastName = 'Exclusion Escalation', Email = 'exclusion_escalation-d@gene.com'));
        insert contacts;
        switchAdminMode(false);

        Profile p = [select id from profile where name='GNE-AGS-CCO-Analyst'];
        User u = new User(alias = 'ccoAnaly', email='ccoAnalyst@gene.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', username='ccoAnalyst@gene.com');
        insert u;
        p = [select id from profile where name='GNE-AGS-CCG-Exclusions'];
        u = new User(alias = 'ccoExc', email='ccoExc@gene.com',
            emailencodingkey='UTF-8', lastname='Tester', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', username='ccoExc@gene.com');
        insert u;        

        List<String> accounts = new List<String>();
        
        Account a = new Account(name='TEST_REVIEWER_PENDING_LIMIT',AGS_EX_Exclusion_Status_base_gne__c='Not Checked');
        insert a;
        accounts.add(a.Id);
        a = new Account(name='TEST_MANAGER_PENDING_LIMIT',AGS_EX_Exclusion_Status_base_gne__c='Not Checked');
        insert a;
        accounts.add(a.Id);
        a = new Account(name='TEST_FINAL_PENDING_LIMIT',AGS_EX_Exclusion_Status_base_gne__c='Not Checked');
        insert a;
        accounts.add(a.Id);
        
        AGS_EX_Exclusion_Utils.createMultipleRequests(accounts);

        AGS_EX_Exclusion_Request_Reminder ext = new AGS_EX_Exclusion_Request_Reminder();
        System.debug('ext.emails.size(): '+ext.emails.size());
        System.assert(ext.emails.size() == 5);
    }

}