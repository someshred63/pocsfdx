public without sharing class SRW_ForgotUsernameController {

public String email{get;set;}
public List<SRW_Security_Community_Data__c> securityData;
    
    public SRW_ForgotUsernameController (){
        List<SRW_Security_Community_Data__c> securityData = new List<SRW_Security_Community_Data__c>();
    }
    
    public PageReference forgotUsername(){
        securityData = [SELECT id, securityAnswer__c, securityQuestion__c, Trading_Partner_gne__c, Trading_Partner_gne__r.Contact_gne__c FROM SRW_Security_Community_Data__c WHERE Trading_Partner_gne__r.Contact_gne__r.Email = :email LIMIT 1];
        system.debug('security data: ' + securityData);
        if(securityData.isEmpty()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.SRW_Forgot_username_wrong_email));
            return null;
        }else {
            List<User> u = [SELECT id FROM User WHERE ContactId = :securityData[0].Trading_Partner_gne__r.Contact_gne__c LIMIT 1];
            if (u.isEmpty()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.SRW_Forgot_username_wrong_email));
            } else {
                sendUsernameEmail(u[0]);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.SRW_Forgot_username_email_sent));
            }
            return null;
        }
    }
    
    public void sendUsernameEmail(User u){
        EmailTemplate forgotUsernameTemplate = [SELECT id FROM EmailTemplate WHERE developerName = 'SRW_ForgotUsername' LIMIT 1];
        Messaging.SingleEmailMessage sem = new Messaging.SingleEmailMessage();
        sem.setTemplateId(forgotUsernameTemplate.id);
        system.debug('security: ' + securityData);
        sem.setTargetObjectId(u.id);
        sem.setSaveAsActivity(false);
        List<String> a = new List<String>();
        String emailAddress = SRW_Utils.getSettingByName('OrgWideEmailAddress');
        OrgWideEmailAddress[] owea = [select Id, Address from OrgWideEmailAddress where Address = :emailAddress LIMIT 1];
        sem.setOrgWideEmailAddressId(owea[0].id);
        a.add(owea[0].Address);
        sem.setCcAddresses(a);
        Messaging.SendEmailResult[] ser = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {sem});
    }
    
    public PageReference returnToLoginPage(){
        PageReference pr = Page.SRW_LoginScreenForTradingPartners;
        pr.setRedirect(true);
        return pr;
    }
}