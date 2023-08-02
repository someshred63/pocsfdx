public without sharing class SRW_EmailUsController {

    public SRW_Trading_Partner_Profile__c tradingPartner {get; set;}
    public TradingPartnerWrapper tradingPartnerData {get; set;}
    public String subject {get; set;}
    public String emailBody {get; set;}
    public Map<String, String> emailSubjectsMap {get; set;}
    public Map<String, String> emailTemplatesMap {get; set;}
    
    
    public SRW_EmailUsController() {
        emailTemplatesMap = new Map<String, String>();
        emailSubjectsMap = new Map<String, String>();
        emailBody = '';  
        subject = 'null';
        List<Profile> FOIMs = [SELECT Name, Id FROM Profile WHERE (Id = :UserInfo.getProfileId() AND Name = 'GNE-GST-Partner-External')];
        Boolean isFOIM = FOIMs.isEmpty();
        User currentUser = [SELECT id, ContactId FROM User WHERE id = :UserInfo.getUserId()];
        if(!isFOIM)
            tradingPartner = [SELECT Contact_gne__c, Contact_gne__r.Email, Alt_Contact_Email_Address_gne__c, Alt_Contact_First_Name_gne__c, Alt_Contact_Last_Name_gne__c, Alt_Contact_Phone_Extn_gne__c, Alt_Contact_Phone_gne__c,
                         Contact_Email_Address_gne__c, Contact_Fax_Number_gne__c, Contact_First_Name_gne__c, Contact_Last_Name_gne__c, Contact_Phone_Extn_gne__c, Contact_Phone_gne__c,
                         Contract_Effective_Date_gne__c, Contract_Termination_Date_gne__c, MCCO_Account_Manger_gne__c, Comment_gne__c, 
                         Trading_Partner_Name_gne__c, Trading_Partner_Phone_gne__c, TP_Phone_Extn_gne__c, Trading_Partner_Fax_Extn_gne__c, Trading_Partner_Fax_gne__c, Trading_Partner_Address_1_gne__c, Trading_Partner_Address_2_gne__c,
                         City_gne__c, State_gne__c, Zip_Code_gne__c, Type_of_Identifier_gne__c, Identifier_gne__c                 
                         FROM SRW_Trading_Partner_Profile__c 
                         WHERE Contact_gne__c = :currentUser.ContactId LIMIT 1];
        else {
            List<SRW_Mimic_Data__c> mimicData = [select Id, SRW_Trading_Partner_Profile_gne__c, User_gne__c from SRW_Mimic_Data__c where User_gne__c =: currentUser.Id]; 
            if(!mimicData.isEmpty()) {
                    tradingPartner = [SELECT Contact_gne__c, Contact_gne__r.Email, Alt_Contact_Email_Address_gne__c, Alt_Contact_First_Name_gne__c, Alt_Contact_Last_Name_gne__c, Alt_Contact_Phone_Extn_gne__c, Alt_Contact_Phone_gne__c,
                         Contact_Email_Address_gne__c, Contact_Fax_Number_gne__c, Contact_First_Name_gne__c, Contact_Last_Name_gne__c, Contact_Phone_Extn_gne__c, Contact_Phone_gne__c,
                         Contract_Effective_Date_gne__c, Contract_Termination_Date_gne__c, MCCO_Account_Manger_gne__c, Comment_gne__c, 
                         Trading_Partner_Name_gne__c, Trading_Partner_Phone_gne__c, TP_Phone_Extn_gne__c, Trading_Partner_Fax_Extn_gne__c, Trading_Partner_Fax_gne__c, Trading_Partner_Address_1_gne__c, Trading_Partner_Address_2_gne__c,
                         City_gne__c, State_gne__c, Zip_Code_gne__c, Type_of_Identifier_gne__c, Identifier_gne__c                 
                         FROM SRW_Trading_Partner_Profile__c 
                         WHERE Id =: mimicData.get(0).SRW_Trading_Partner_Profile_gne__c LIMIT 1];
            }         
        }

        tradingPartnerData = new TradingPartnerWrapper(tradingPartner); 
    
    }

    public List<SelectOption> getSubjects() {
        SRW_Utils.getActiveSettingsByPrefix('TPEmailTemplate');
        //Map<String,SRW_TP_Emails__c> settings = SRW_TP_Emails__c.getAll();
        List<String> emailTemplates = SRW_Utils.getActiveSettingsByPrefix('ContactUsEmailTemplate');
        /*for(SRW_TP_Emails__c sett : settings.values()) {
            if(sett.Is_Active__c) {
                emailTemplates.add(sett.Email_Template_Name__c);
            }
        }*/

        List<EmailTemplate> ets = [Select Body,  DeveloperName, Id, IsActive, Name, Subject from EmailTemplate where DeveloperName in: emailTemplates];
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('null', 'Please select an email Subject'));
        for(EmailTemplate et :ets) {
            if(et.IsActive) {
                emailTemplatesMap.put(et.Id, et.Body);
                emailSubjectsMap.put(et.Id, et.Subject);
                options.add(new SelectOption(et.Id, et.Subject));               
            }
        }
        return options;
    }


    public PageReference changeEmail() {
        
        if(emailTemplatesMap.containsKey(subject)) {
            emailBody = emailTemplatesMap.get(subject);
        } else {
            emailBody = '';
        }

        return null;
    }

    public PageReference sendEmail() {

        if(!emailTemplatesMap.containsKey(subject)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please select email subject'));
            return null;
        }
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        try { 
            String orgWideAddress = SRW_Utils.getSettingByName('OrgWideEmailAddress');
            if(String.isBlank(orgWideAddress)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Email recipient is not configured.'));
                return null;
            }

            List<String> toAddresses = new List<String>{orgWideAddress};        
            mail.setToAddresses(toAddresses);
            String senderDisplayName = tradingPartner.Trading_Partner_Name_gne__c;
            String sender = tradingPartner.Contact_gne__r.Email;
            mail.setReplyTo(sender);
            mail.setSenderDisplayName(senderDisplayName);
            mail.setSubject(emailSubjectsMap.get(subject));
            mail.setPlainTextBody(emailBody); 
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.setSaveAsActivity(false);

            if(isEmailInvalid()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please fill mandtory fields.'));
                return null;
            }

            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Email was sent'));
            emailBody = '';  
            subject = 'null';
        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error: ' + ex.getMessage()));             
        }
        return null;
    }

    public Boolean isEmailInvalid(){
        return (String.isBlank(emailBody) || String.isBlank(emailSubjectsMap.get(subject)));
    }

    public class TradingPartnerWrapper {
        public SRW_Trading_Partner_Profile__c tradingPartner {get;set;}
        
        public String tradingPartnerPhoneNumber {get; set;}
        public String tradingPartnerPhoneAreaCode {get; set;}
        
        public TradingPartnerWrapper(SRW_Trading_Partner_Profile__c tradingPartner) {
            this.tradingPartner = tradingPartner;
            if(!String.isBlank(tradingPartner.Trading_Partner_Phone_gne__c) && tradingPartner.Trading_Partner_Phone_gne__c.length() == 10){
                this.tradingPartnerPhoneAreaCode = tradingPartner.Trading_Partner_Phone_gne__c.substring(0,3);
                this.tradingPartnerPhoneNumber = tradingPartner.Trading_Partner_Phone_gne__c.substring(3);
            }else {
                this.tradingPartnerPhoneAreaCode = null;
            }            
        }

    }

}