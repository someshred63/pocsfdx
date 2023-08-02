public class EDM_Send_Remainder_To_Partner_Usr_Batch implements Database.Batchable<sObject>, Database.Stateful {
    private String batchId;
    public String query;
    private String owaId = '';
    private Map<Id, String> userIdToEmailForSendRemainderMap = new Map<Id, String>();
    public EDM_Send_Remainder_To_Partner_Usr_Batch() {
        this.query = 'SELECT Id,FirstName, LastName, CreatedDate, LastModifiedDate, Alias, Profile.Name, Email, IsActive, LastLoginDate ' +
                'FROM User ' +
                'WHERE Id NOT IN (Select EDM_User_gne__c FROM EDM_Deactivate_Partners_Exception_gne__c WHERE EDM_Active_gne__c = TRUE) ' +
                'AND Id NOT IN (Select EDM_User_gne__c From EDM_Partner_User_License_Deact_gne__c WHERE EDM_Reminder_Sent_gne__c = TRUE) ' +
                'AND ((Profile_Name_gne__c IN (\'GNE-VDST-Partner-External\',\'Partner Community User\') ' +
                'AND IsActive = true and  LastLoginDate < LAST_N_MONTHS:12) ' +
                'OR (Profile_Name_gne__c in (\'GNE-VDST-Partner-External\',\'Partner Community User\') ' +
                'AND IsActive = true AND LastLoginDate = null AND CreatedDate < LAST_N_MONTHS:12)) '+
                'ORDER BY LastLoginDate';
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('query: ' + this.query);
        return Database.getQueryLocator(this.query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        List<EDM_Partner_User_License_Deact_gne__c> partnerUserLicenseRecordsList = new List<EDM_Partner_User_License_Deact_gne__c>();
        for(Sobject s : scope){
            userIdToEmailForSendRemainderMap.put(s.Id, String.valueOf(s.get('Email')));
            partnerUserLicenseRecordsList.add(createRecordWithSendReminder(s));
        }

        if(!partnerUserLicenseRecordsList.isEmpty()) {
            Database.insert(partnerUserLicenseRecordsList);
        }

    }

    public void finish(Database.BatchableContext bc) {
        this.batchId = String.valueOf(BC.getJobId()) + '-' + String.valueOf(Datetime.now().getTime());
        this.owaId = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'Partner License Deactivation Report' Limit 1].Id;
        if(!userIdToEmailForSendRemainderMap.keySet().isEmpty()) {
            sendRemainderEmail(userIdToEmailForSendRemainderMap);
        }
    }

    private void sendRemainderEmail(Map<Id, String> userIdToEmailMap) {
        Set<String> userEmailsSet = getEmailsFromMap(userIdToEmailMap);
        Messaging.SingleEmailMessage message = createRemainderEmail(userEmailsSet);
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {message});
    }

    Messaging.SingleEmailMessage createRemainderEmail(Set<String> userEmailsSet) {
        List<String> bccAdd = new List<String>();
        bccAdd.addAll(userEmailsSet);
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        if(this.owaId != null){
            message.setOrgWideEmailAddressId(owaId);
        }
        message.setSubject('Call for action - login within 7 days');
        message.setBccAddresses(bccAdd);
        Datetime today_plus_7 = System.now() + 7;
        String dayName = String.valueOf(today_plus_7.format('EEEE'));
        String finBody =    '<p>ACTION by ' + dayName + ' ' + String.valueOf(System.today().month()) + '/' + String.valueOf(System.today().day() + 7) + ': Please login to the system within next seven days</p>\n' +
                '<p style="color:red">IF YOU ARE STILL SUPPORTING GENENTECH ADVISORY BOARDS</p> \n' +
                '<p>to ensure your account will not be deactivated.</p>\n' +
                '<p>If you do not login before the deadline above, your account will be deactivated and you will no longer have access to the ABM Tool.</p>\n' +
                '<p>Thank you.</p>';
        message.setHtmlBody(finBody);
        return message;
    }

    private EDM_Partner_User_License_Deact_gne__c createRecordWithSendReminder(SObject s) {
        return New EDM_Partner_User_License_Deact_gne__c(EDM_User_gne__c = s.Id, EDM_Reminder_Sent_gne__c = true);
    }

    private Set<String> getEmailsFromMap(Map<Id, String> userIdToEmailMap) {
        Set<String> userEmailsSet = new Set<String>();
        for(Id usrId : userIdToEmailMap.keySet()) {
            userEmailsSet.add(userIdToEmailMap.get(usrId));
        }
        return userEmailsSet;
    }
}