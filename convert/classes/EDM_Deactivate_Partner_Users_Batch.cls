public class EDM_Deactivate_Partner_Users_Batch implements Database.Batchable<sObject>, Database.Stateful {

    private Map<Id, String> userIdToEmailForDeactivationMap = new Map<Id, String>();
    private List<EDM_Partner_User_License_Deact_gne__c> partnerUserLicenseDeactListToUpdate = new List<EDM_Partner_User_License_Deact_gne__c>();
    private Map<Id, EDM_Partner_User_License_Deact_gne__c> userIdToPartnerUserLicenseDeactMap = new Map<Id, EDM_Partner_User_License_Deact_gne__c>();
    private String owaId = '';
    private String batchId;
    public String query;

    public EDM_Deactivate_Partner_Users_Batch(){
        String absApproversIdsToNotDeactivate = EDM_Deactivate_Utils.getAbsApproversIdsToNotDeactivate();
        this.query = 'SELECT Id,FirstName, LastName, CreatedDate, LastModifiedDate, Alias, Profile.Name, Email, IsActive, LastLoginDate ' +
                'FROM User ' +
                'WHERE Id NOT IN (Select EDM_User_gne__c FROM EDM_Deactivate_Partners_Exception_gne__c WHERE EDM_Active_gne__c = TRUE) ' +
                'AND Id IN (Select EDM_User_gne__c From EDM_Partner_User_License_Deact_gne__c WHERE EDM_Reminder_Sent_gne__c = TRUE AND EDM_Deactivated_gne__c = FALSE) ' +
                'AND Id NOT IN (' + absApproversIdsToNotDeactivate + ') '+
                'AND ((Profile_Name_gne__c IN (\'GNE-VDST-Partner-External\',\'Partner Community User\') ' +
                'AND IsActive = true and  LastLoginDate < LAST_N_MONTHS:12) ' +
                'OR (Profile_Name_gne__c in (\'GNE-VDST-Partner-External\',\'Partner Community User\') ' +
                'AND IsActive = true AND LastLoginDate = null AND CreatedDate < LAST_N_MONTHS:12)) '+
                'ORDER BY LastLoginDate';
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('query: ' + this.query);
        return Database.getQueryLocator(this.query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<User> usersToDeactivate = new List<User>();
        for(Sobject s : scope) {
            this.userIdToEmailForDeactivationMap.put(String.valueOf(s.get('Id')), String.valueOf(s.get('Email')));
            usersToDeactivate.add(new User(Id=s.Id, IsActive = false));
            this.userIdToPartnerUserLicenseDeactMap = getPartnerUserLicenseDeactRecords();
            EDM_Partner_User_License_Deact_gne__c puldToUpdate = this.userIdToPartnerUserLicenseDeactMap.get(s.Id);
            this.partnerUserLicenseDeactListToUpdate.add(updateRecordWhenUserWasDeactivated(puldToUpdate));
        }
        if(!usersToDeactivate.isEmpty()) {
            Database.upsert(usersToDeactivate);
        }
    }

    public void finish(Database.BatchableContext BC){
        this.batchId = String.valueOf(BC.getJobId()) + '-' + String.valueOf(Datetime.now().getTime());
        this.owaId = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'Partner License Deactivation Report' Limit 1].Id;
        Database.upsert(this.partnerUserLicenseDeactListToUpdate);

        if(!this.userIdToEmailForDeactivationMap.values().isEmpty()) {
            sendDeactivationEmail(this.userIdToEmailForDeactivationMap.values());
        }

        createReport();

    }

    private void sendDeactivationEmail(List<String> userEmailsList) {
        List<String> bccAdd = new List<String>();
        bccAdd.addAll(userEmailsList);
        Messaging.Singleemailmessage message = createDeactivationEmail(userEmailsList);
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.Singleemailmessage[] {message});
    }

    private Messaging.SingleEmailMessage createDeactivationEmail(List<String> userEmailsList) {
        List<String> bccAdd = new List<String>();
        bccAdd.addAll(userEmailsList);
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        if(owaId != null){
            message.setOrgWideEmailAddressId(owaId);
        }
        message.setSubject('License Deactivation Confirmation');
        message.setBccAddresses(bccAdd);
        String finBody =    '<p>Your Genentech Advisory Board access has been deactivated and you will no longer have access to the ABM Tool.</p>\n' +
                            '<p>If you have any questions, please contact <b>abs-d@gene.com</b>.</p>\n' +
                            '<p>Thank you.</p>';
        message.setHtmlBody(finBody);
        return message;
    }

    private void createReport() {
        List<User> userRecordForReport = [Select Id,FirstName, LastName, CreatedDate, LastModifiedDate, Alias, Profile.Name, Email, IsActive, LastLoginDate
                                          From User
                                          Where Id IN : userIdToEmailForDeactivationMap.keySet()];
        String emailBody = 'Number of deactivated licenses: ' + userRecordForReport.size() + '\n' +
                           'Batch Id: ' + batchId + '\n';
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        if(owaId != null){
            message.setOrgWideEmailAddressId(owaId);
        }
        message.setUseSignature(false);
        message.setBccSender(false);
        message.setSaveAsActivity(false);
        message.toAddresses = new String[] { GNE_Foun_Misc_Config_Items_gne__c.getValues('Email_To_Report_Deactivated_Part_Usr').Configuration_Value_gne__c };
        message.subject = 'Report: Deactivated Partner Users';
        message.plainTextBody = emailBody;
        GNE_Csv_Helper csvHelper = new GNE_Csv_Helper(userRecordForReport);
        message.setFileAttachments(new Messaging.EmailFileAttachment[]{csvHelper.attachment});
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
    }

    private Map<Id, EDM_Partner_User_License_Deact_gne__c> getPartnerUserLicenseDeactRecords() {
        Map<Id, EDM_Partner_User_License_Deact_gne__c> userIdToPartnerUserLicenseDeactMap = new Map<Id, EDM_Partner_User_License_Deact_gne__c>();

        List<EDM_Partner_User_License_Deact_gne__c> partnerUserLicenseDeactList = [
                SELECT Id, Name, EDM_Reminder_Sent_gne__c, EDM_Deactivated_gne__c, EDM_User_gne__c
                FROM EDM_Partner_User_License_Deact_gne__c
                WHERE EDM_Deactivated_gne__c = false];

        for(EDM_Partner_User_License_Deact_gne__c puld : partnerUserLicenseDeactList) {
            userIdToPartnerUserLicenseDeactMap.put(puld.EDM_User_gne__c, puld);
        }
        return userIdToPartnerUserLicenseDeactMap;
    }

    private EDM_Partner_User_License_Deact_gne__c updateRecordWhenUserWasDeactivated(EDM_Partner_User_License_Deact_gne__c puld) {
        puld.EDM_Deactivated_gne__c = true;
        return puld;
    }

    public class GNE_Csv_Helper {
        public String fileBody = '';
        public Messaging.EmailFileAttachment attachment { get; set; }

        public GNE_Csv_Helper(List<sObject> recList) {
            this.fileBody = createFileBody(recList);
            this.attachment = buildAttachment('deactivatedUsers', this.fileBody);
        }

        public String createFileBody(List<sObject> recList) {
            String fileBodyTmp = '';
            String fileHeaderTmp = '';
            fileHeaderTmp = '"Id","FirstName","LastName","Email","Profile.Name","CreatedDate","LastModifiedDate","LastLoginDate","IsActive"\n';
            fileBodyTmp += fileHeaderTmp;
            for(sObject rec : recList) {
                String fileRecord = '';
                fileRecord = '"' + (String)rec.get('Id') + '","' + (String)rec.get('FirstName') +
                        '","' + (String)rec.get('LastName') + '","' + (String)rec.get('Email') +
                        '","' + (String)rec.getSobject('Profile').get('Name') + '","' + (DateTime)rec.get('CreatedDate') +
                        '","' + (DateTime)rec.get('LastModifiedDate') + '","' + (DateTime)rec.get('LastLoginDate') +
                        '","' + (Boolean)rec.get('IsActive') + '"' + '\n';
                fileBodyTmp += fileRecord;
            }
            return fileBodyTmp;
        }

        public Messaging.EmailFileAttachment buildAttachment(String attName, String fileBody) {
            Messaging.EmailFileAttachment attachmentTmp = new Messaging.EmailFileAttachment();
            Blob csvBlob = Blob.valueOf(fileBody);
            attachmentTmp.setFileName(attName + '.csv');
            attachmentTmp.setBody(csvBlob);
            return attachmentTmp;
        }

    }

}