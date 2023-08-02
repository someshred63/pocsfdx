public class SFA2_SBC_Profiler_Log_Action_Logic {
    private static GNE_Foun_Misc_Config_Items_gne__c config = GNE_Foun_Misc_Config_Items_gne__c.getValues('SBCEmailAlerts');
    private static final GNE_Foun_Misc_Config_Items_gne__c INCLUDED_ERRORS_CODES  = GNE_Foun_Misc_Config_Items_gne__c.getValues('SbcEmailAlertCodes');   
    private static final String SERVICE_ERROR_CODE  = 'MDMSearch.ServiceError';
    private static final String EMAIL_SUBJECT       = createSubject();
    
    private static List<String> toAddresses = new List<String>();
    private static List<String> ccAddresses = new List<String>();
    @testVisible private static Messaging.SingleEmailMessage [] emails;
    
    public static void sendAlertEmails(SFA2_SBC_Profiler_Log_Action_gne__c[] records) {
        if(config == null || isConfigError()){
            return;
        }

        List<SFA2_SBC_Profiler_Log_Action_gne__c> logsToSend = new List<SFA2_SBC_Profiler_Log_Action_gne__c>();
        
        for(SFA2_SBC_Profiler_Log_Action_gne__c r :[
            SELECT Id, Createdby.Name, Createdby.Profile.Name, SBC_Profiler_Log_ref_gne__r.Search_Query_gne__c, Action_Name_gne__c, Description_gne__c
            FROM SFA2_SBC_Profiler_Log_Action_gne__c
            WHERE Id IN :records
        ]) {
            if(isRecordApplicableForAlert(r)) {
                logsToSend.add(r);
            }
        }  
        if(!logsToSend.isEmpty()) {
            String jsonEmails = JSON.serialize(logsToSend);
            sendEmails(jsonEmails, toAddresses, ccAddresses);
        }
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
        if(INCLUDED_ERRORS_CODES == null) {
            System.debug('INCLUDED_ERRORS_CODES IS NULL');
            result = true;
        }
        
        return result;
    }
    
    private static Boolean isRecordApplicableForAlert(SFA2_SBC_Profiler_Log_Action_gne__c record) {
        Boolean result = false;
        if(String.isNotEmpty(record.Description_gne__c) && String.isNotEmpty(record.Action_Name_gne__c)) {
            result = true;
            result &= record.Action_Name_gne__c == SERVICE_ERROR_CODE;
            Boolean isErrorMatch = false;
            Set<String> errorCodes = new Set<String>(INCLUDED_ERRORS_CODES.Configuration_Value_gne__c.split(';'));
            for(String errCode : errorCodes) {
                if(record.Description_gne__c.contains(errCode)){
                    isErrorMatch = true;
                    break;
                }                
            }
            result &= isErrorMatch;            
        }
        
        return result;        
    }

    private static void sendEmails(String jsonemails, List<String> toAddr, List<String>bcAddr) {
        if(Test.isRunningTest() || System.isBatch() || System.isFuture() || System.isQueueable() || System.isScheduled() ){
            sendEmailSync(jsonemails, toAddr, bcAddr);            
        } else {
            sendEmailFuture(jsonemails, toAddr, bcAddr);            
        }                
    }
    
    @future
    private static void sendEmailFuture(String jsonemails, List<String> toAddr, List<String>bcAddr) {
        sendEmailSync(jsonemails, toAddr, bcAddr);
    }
    
    private static void sendEmailSync(String jsonemails, List<String> toAddr, List<String>bcAddr) {
        List<SFA2_SBC_Profiler_Log_Action_gne__c> logsToSend = (List<SFA2_SBC_Profiler_Log_Action_gne__c>) JSON.deserialize(jsonemails, List<SFA2_SBC_Profiler_Log_Action_gne__c>.class);
        emails = new Messaging.SingleEmailMessage []{};

        String emailBodyHtml = 'Hi Team,<BR/><BR/>SBC is down. Please resolve the issue ASAP.<BR/><BR/>';
        
        for(SFA2_SBC_Profiler_Log_Action_gne__c r :logsToSend) {
           emailBodyHtml += createRecordInfo(r);
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
    
    private static String createRecordInfo(SFA2_SBC_Profiler_Log_Action_gne__c record) {
        String txt = 'Failed search:<BR/>';
        txt += '<B>User Name</B>: ' + record.Createdby.Name + '<BR/>';
        txt += '<B>User Profile</B>: ' + record.Createdby.Profile.Name + '<BR/>';
        txt += '<B>Search Query</B>: ' + record.SBC_Profiler_Log_ref_gne__r.Search_Query_gne__c + '<BR/>';
        txt += '<B>Error</B>: ' + record.Action_Name_gne__c + '<BR/>';
        txt += '<B>Error Details</B>: ' + record.Description_gne__c + '<BR/><BR/>';

        return txt;        
    }
    
    private static String createSubject() {        
        String subject = '[Urgent] SBC is down - please resolve ASAP';
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