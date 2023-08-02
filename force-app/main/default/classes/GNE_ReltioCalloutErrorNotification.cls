public class GNE_ReltioCalloutErrorNotification {
    private static GNE_Foun_Misc_Config_Items_gne__c config = GNE_Foun_Misc_Config_Items_gne__c.getValues('Reltio_EmailAlerts');
    private static final String EMAIL_SUBJECT = createSubject();
    
    private static List<String> toAddresses = new List<String>();
    private static List<String> ccAddresses = new List<String>();
    @testVisible private static Messaging.SingleEmailMessage [] emails;
    
    
    public static void sendAlertEmail(String error) {
        if(config == null || isConfigError()){
            return;
        }
        sendEmails(error, toAddresses, ccAddresses, true);  
    }
    
    public static void sendAlertEmail(Affiliation_vod__c forUpdate) {
        if(config == null || isConfigError()){
            return;
        }
        forUpdate = [
            SELECT Createdby.Name, Createdby.Profile.Name, MDM_Response_Code_gen__c,  MDM_Error_Details_gne__c, Name, CreatedDate
            FROM Affiliation_vod__c 
            WHERE Id = :forUpdate.Id
        ];
        String jsonEmails = JSON.serialize(forUpdate);
        sendEmails(jsonEmails, toAddresses, ccAddresses, true);        
    }
    
    public static void sendAlertEmail(Change_Request_gne__c dcrForUpdate) {
        if(config == null || isConfigError()){
            return;
        }
        dcrForUpdate = [
            SELECT Createdby.Name, Createdby.Profile.Name, MDM_DCR_Response_Code_gen__c, RecordTypeId, MDM_DCR_Error_Details_gne__c, Name
            FROM Change_Request_gne__c 
            WHERE Id = :dcrForUpdate.Id
        ];
        String jsonEmails = JSON.serialize(dcrForUpdate);
        sendEmails(jsonEmails, toAddresses, ccAddresses, false);        
    }
    
    private static Boolean isConfigError() {
        System.debug('CHECKING JSON CONFIG:: '+config);
        Boolean result = true;
        if(config != null) {
            try{
                AddressWrapper addresConfig = (AddressWrapper) JSON.deserialize(config.Configuration_Value_gne__c, AddressWrapper.class);
                if(addresConfig != null && addresConfig.To != null){
                    toAddresses.addAll(addresConfig.To);
                    result = false;
                }
                if(addresConfig != null && addresConfig.Cc != null){
                    ccAddresses.addAll(addresConfig.Cc);  
                }
            } catch(JSONException ex) {
                System.debug('ERROR PARSING JSON :: '+ex);
                result = true;
            }            
        }
        
        return result;
    }
    
    private static void sendEmails(String jsonemails, List<String> toAddr, List<String>bcAddr, Boolean isAffiliation) {
        if(Test.isRunningTest() || System.isBatch() || System.isFuture() || System.isQueueable() || System.isScheduled() ){
            sendEmailSync(jsonemails, toAddr, bcAddr, isAffiliation);            
        } else {
            sendEmailFuture(jsonemails, toAddr, bcAddr, isAffiliation);            
        }                
    }
    
    @future
    private static void sendEmailFuture(String jsonemails, List<String> toAddr, List<String>bcAddr, Boolean isAffiliation) {
        sendEmailSync(jsonemails, toAddr, bcAddr, isAffiliation);
    }
    
    private static void sendEmailSync(String jsonemails, List<String> toAddr, List<String>bcAddr, Boolean isAffiliation) {
        Change_Request_gne__c dcr;
        Affiliation_vod__c affiliation;
        if(!isAffiliation) dcr = (Change_Request_gne__c) JSON.deserialize(jsonemails, Change_Request_gne__c.class);
        if(isAffiliation) affiliation = (Affiliation_vod__c) JSON.deserialize(jsonemails, Affiliation_vod__c.class);
        emails = new Messaging.SingleEmailMessage []{};

        String emailBodyHtml = 'Hi Team,<BR/><BR/>DCR Endpoint is down. Please resolve the issue ASAP.<BR/><BR/>';    
        if(isAffiliation) {
            emailBodyHtml += createRecordInfo(affiliation); 
        } else {
            emailBodyHtml += createRecordInfo(dcr);   
        }
             
        emailBodyHtml += 'Thanks,<BR/>Main Org Bot Automation';
        emails.add(createMessage(emailBodyHtml, toAddr, bcAddr));
        List<Messaging.Sendemailresult> results = Messaging.sendEmail(emails);

        for(Messaging.Sendemailresult result : results) {            
            if (!result.isSuccess()){
                for(Messaging.SendEmailError err : result.getErrors()) {
                       System.debug('Couldn\'t send email. Reason: ' + err.getMessage());
                }
            }    
        }        
    }
    
    private static Messaging.SingleEmailMessage createMessage(String htmlBody, List<String> toAddr, List<String>bcAddr) {
        Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
        emailMsg.setSubject(EMAIL_SUBJECT);
        emailMsg.setHtmlBody(htmlBody);
        emailMsg.setToAddresses(toAddr);
        if(!bcAddr.isEmpty()) emailMsg.setCcAddresses(bcAddr);
        Id orgWideEmail = fetchIdOrgWideEmail();
        if(orgWideEmail != null) {
            emailMsg.setOrgWideEmailAddressId(orgWideEmail);            
        }
        
        return emailMsg;
    }
    
     private static Id fetchIdOrgWideEmail() {        
        OrgWideEmailAddress[] orgWideEmails = [
            SELECT Id FROM OrgWideEmailAddress WHERE address = 'comm-sfa-ops-d@gene.com' LIMIT 1
        ];
        return orgWideEmails.isEmpty() ? null : orgWideEmails[0].Id;
    }
    
    private static String createRecordInfo(Affiliation_vod__c record) {
        String operation = record.CreatedDate.addDays(1) > System.now() ? 'Create_Affiliation' : 'Delete_Affiliation';
        String serviceUrl = GNE_ReltioCalloutHandler.servicesURLs.get(operation)[1];
        String serverUrl = '';
        String pathSeparator = String.isNotBlank(serviceURL) && serviceURL.startsWith('/') ? '' : '/';        
        NamedCredential nc = [SELECT DeveloperName, Endpoint FROM NamedCredential WHERE DeveloperName = :GNE_ReltioCalloutHandler.servicesURLs.get(operation)[0] LIMIT 1];
        serverUrl = nc.Endpoint;

        String txt = 'Failed DCR Connection:<BR/>';
        txt += '<B>User Name</B>: ' + record.Createdby.Name + '<BR/>';
        txt += '<B>User Profile</B>: ' + record.Createdby.Profile.Name + '<BR/>';
        txt += '<B>DCR Name</B>: ' + record.Name + '<BR/>';
        txt += '<B>DCR Endpoint URL</B>: ' +serverUrl +''+pathSeparator+''+ serviceUrl + '<BR/>';
        txt += '<B>Response Code</B>: ' + record.MDM_Response_Code_gen__c + '<BR/>';
        txt += '<B>Error Details</B>: ' + record.MDM_Error_Details_gne__c + '<BR/><BR/>';

        return txt;        
    }
    
    private static String createRecordInfo(Change_Request_gne__c record) {
        String recordTypename = GNE_ReltioDCRWrapperConverter.id2RecordTypeDevName.get(record.RecordTypeId) != null ? GNE_ReltioDCRWrapperConverter.id2RecordTypeDevName.get(record.RecordTypeId) : null;
        String serviceUrl = recordTypename != null ? GNE_ReltioCalloutHandler.servicesURLs.get(recordTypename)[1] : 'unknown';
        String serverUrl = '';
        String pathSeparator = String.isNotBlank(serviceURL) && serviceURL.startsWith('/') ? '' : '/';
        if(recordTypename != null) {
            NamedCredential nc = [SELECT DeveloperName, Endpoint FROM NamedCredential WHERE DeveloperName = :GNE_ReltioCalloutHandler.servicesURLs.get(recordTypename)[0] LIMIT 1];
            serverUrl = nc.Endpoint;
        }
        String txt = 'Failed DCR Connection:<BR/>';
        txt += '<B>User Name</B>: ' + record.Createdby.Name + '<BR/>';
        txt += '<B>User Profile</B>: ' + record.Createdby.Profile.Name + '<BR/>';
        txt += '<B>DCR Name</B>: ' + record.Name + '<BR/>';
        txt += '<B>DCR Endpoint URL</B>: ' +serverUrl +''+pathSeparator+''+ serviceUrl + '<BR/>';
        txt += '<B>Response Code</B>: ' + record.MDM_DCR_Response_Code_gen__c + '<BR/>';
        txt += '<B>Error Details</B>: ' + record.MDM_DCR_Error_Details_gne__c + '<BR/><BR/>';

        return txt;        
    }
    
     private static String createSubject() {        
        String subject = '[Urgent] DCR Endpoint is down - please resolve ASAP';
        if(isProductionEnv()){
            subject = 'PROD '+subject;
        } else {
            String sandboxName = UserInfo.getUserName().substringAfterLast('.');
            subject = sandboxName.toUpperCase() + ' ' + subject;
        }

        return subject;    
    }
    
    private static Boolean isProductionEnv() {
        return ![SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    
    class AddressWrapper{
        public List<String> To {get;set;}
        public List<String> Cc {get;set;}
    }
}