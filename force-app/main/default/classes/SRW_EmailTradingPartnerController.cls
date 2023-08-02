public with sharing class SRW_EmailTradingPartnerController {
    
    
    public List<SelectOption> tpOptions {get; set;}     
    public List<SelectOption> mdOptions {get; set;}     
    public Map<String, String> emailTemplatesMap {get; set;}
    public Map<String, String> emailSubjectsMap {get; set;}
    public String selectedTPOption { get; set;}



    public String selectedDataMonth { get; set;}
    public List<String> selectedTPs { get; set;}
    public String subject {get; set;}
    public String emailBody {get; set;}

    public SRW_EmailTradingPartnerController(){
        tpOptions = getAllTPs();
        mdOptions = getDateMonths();
        emailTemplatesMap = new Map<String,String>();
        emailSubjectsMap = new Map<String,String>();
        selectedTPOption = 'allActive';
        emailBody = '';  
        selectedDataMonth  = 'null';
        selectedTPs = new List<String>{'all'};
        subject = 'null';
    }

    public Boolean getTPsPicklistDisabled() {
        if('selectedTPs'.equals(selectedTPOption))
            return false;
        return true;

    }

    public Boolean getDMsPicklistDisabled() {
        if('notSubmitted'.equals(selectedTPOption))
            return false;
        return true;

    }
    
    public List<SelectOption> getSubjects() {
        SRW_Utils.getActiveSettingsByPrefix('TPEmailTemplate');
        List<String> emailTemplates = SRW_Utils.getActiveSettingsByPrefix('TPEmailTemplate');
        List<EmailTemplate> ets = [Select Body,  DeveloperName, Id, IsActive, Name, Subject from EmailTemplate where DeveloperName in: emailTemplates];
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('null', 'Please select email Subject'));
        for(EmailTemplate et :ets) {
            if(et.IsActive) {
                emailTemplatesMap.put(et.Id, et.Body);
                emailSubjectsMap.put(et.Id, et.Subject);
                options.add(new SelectOption(et.Id, et.Subject));               
            }
        }
        options.add(new SelectOption('other', 'Other'));
        return options;
    }

    public List<SelectOption> getDateMonths() {
        List<SRW_DataMonths__c> dateMonths = [Select Id, Name, Data_Month_Cal_gne__c, Data_Month_gne__c, Data_Year_gne__c, Data_Month_Number_gne__c From SRW_DataMonths__c order by Data_Year_gne__c desc, Data_Month_Number_gne__c desc];
        System.debug('--- getDateMonths() ' + dateMonths);
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('null', 'Please select Data Month'));
        for(SRW_DataMonths__c dm : dateMonths) {
            options.add(new SelectOption(dm.Id, dm.Data_Month_Cal_gne__c)); 
        }
        return options;
    }   

    public List<SelectOption> getAllTPs() {
        List<SRW_Trading_Partner_Profile__c> tps = [Select Id, Name, Contact_Email_Address_gne__c, Active_gne__c, Trading_Partner_Name_gne__c, Trading_Partner_User_Name_gne__c, Contact_First_Name_gne__c, Contact_Last_Name_gne__c from SRW_Trading_Partner_Profile__c order by Trading_Partner_Name_gne__c, Contact_Last_Name_gne__c, Contact_First_Name_gne__c];
        System.debug('--- getAllTradingPartners ' + tps);
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('all', 'All'));
        for(SRW_Trading_Partner_Profile__c tp : tps) {
            if(tp.Trading_Partner_Name_gne__c!=null)
                options.add(new SelectOption(tp.Id, tp.Trading_Partner_Name_gne__c));   
        }
        return options;
    }

    private Boolean validateEmailAction() {
        Boolean isError = false;
        if(selectedTPOption == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please select email recipients.'));
            isError = true;
        }

        if('selectedTPs'.equals(selectedTPOption) && (selectedTPs == null || selectedTPs.isEmpty())) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please select email recipients.'));
            isError = true;
        } else if('notSubmitted'.equals(selectedTPOption) && ('null'.equals(selectedDataMonth) || selectedDataMonth == null)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please select email recipients.'));
            isError = true;
        }

        if('null'.equals(subject)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please select email Subject.'));
            isError = true; 
        }
        return isError;
    }

    public List<User> getEmailRecipients() {

        List<String> contactIds = new List<String>();
        
        System.debug('--- selectedTPOption ' + selectedTPOption);
        if('allActive'.equals(selectedTPOption)) {
            contactIds.addall(getTPsContactIds(true));
        }
        else if('allInactive'.equals(selectedTPOption)) {
            contactIds.addall(getTPsContactIds(false));
        } else if('notSubmitted'.equals(selectedTPOption)) {
            List<SRW_TP_Data_Months__c> tpDMs = getUnsubmittedTPsForDataMonth();
            for(SRW_TP_Data_Months__c tpDM : tpDMs) {
                if(tpDM.Trading_Partner_gne__c != null && tpDM.Trading_Partner_gne__r.Contact_gne__c != null)
                    contactIds.add(tpDM.Trading_Partner_gne__r.Contact_gne__c);
            }
        } else if('selectedTPs'.equals(selectedTPOption)) {
            System.debug('--- selectedTPs ' +selectedTPs);
            List<SRW_Trading_Partner_Profile__c> tps = new List<SRW_Trading_Partner_Profile__c>();
            Set<String> tpSet =  new Set<String>(selectedTPs);
            System.debug('--- tpSet ' + tpSet);
            if(tpSet.contains('all')) {
                System.debug('--- all ');
                tps = [Select Id, Contact_gne__c from SRW_Trading_Partner_Profile__c where Contact_gne__c != null];
                
            } else {
                System.debug('--- not all ');
                tps = getTPsById(selectedTPs);
            }
            if(tps != null) {
                for(SRW_Trading_Partner_Profile__c tp : tps) {
                    contactIds.add(tp.Contact_gne__c);
                }
            }
        }
        System.debug('--- contactId1 ' + contactIds);
        if(contactIds == null || contactIds.isEmpty())
            return null;
        
        System.debug('--- contactId ' + contactIds);
        List<User> users = [Select Id, IsActive, ContactId, Email from User where IsActive = true and ContactId in: contactIds];
        System.debug('--- users ' + users);
        
        return users;
    }


    public List<SRW_TP_Data_Months__c> getUnsubmittedTPsForDataMonth() {
        if(selectedDataMonth == null || selectedDataMonth == 'null')
            return null;
        system.debug('--- selectedDataMonth '+selectedDataMonth );
        List<SRW_TP_Data_Months__c> tpDataMonths = [Select Id, SRW_Data_Month_gne__c, Data_Month_Status_gne__c, Trading_Partner_gne__c, Trading_Partner_gne__r.Contact_gne__c from SRW_TP_Data_Months__c where SRW_Data_Month_gne__c =: selectedDataMonth and Data_Month_Status_gne__c in ('Submitted No Sales Data', 'Open')];
        return tpDataMonths;
    }

    public Set<String> getTPsContactIds(Boolean active) {
        Set<String> contactIds = new Set<String>();
        List<String> statuses = new List<String>();   
        if(active == true) {
            statuses.add('Active');
            statuses.add('Locked');
        } else {
            statuses.add('Inactive');
        }
        List<SRW_Security_Community_Data__c> secData = [Select Status_gne__c, Trading_Partner_gne__c, Trading_Partner_gne__r.Contact_gne__c from SRW_Security_Community_Data__c where Status_gne__c in :statuses and Trading_Partner_gne__r.Contact_gne__c != null];
        for(SRW_Security_Community_Data__c sec : secData) {
            contactIds.add(sec.Trading_Partner_gne__r.Contact_gne__c);
        }

        return contactIds;
    }

    public List<SRW_Trading_Partner_Profile__c> getTPsById(List<String> ids) {
        return [Select Id, Contact_gne__c from SRW_Trading_Partner_Profile__c where id in: ids];
    }

    public PageReference changeEmail() {
        
        if(emailTemplatesMap.containsKey(subject)) {
            emailBody = emailTemplatesMap.get(subject);
            emailBody = fillCommunityURL(emailBody);
        } else {
            emailBody = '';
        }

        return null;
    }

    public PageReference sendEmail() {
        Boolean isError = validateEmailAction();
        if(isError)
            return null;

        List<User> users = getEmailRecipients();
        System.debug('--- users ' + users);
        
        if(users == null || users.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Empty Email Recipients'));
            return null;    
        }       
        
        List<String> userIds = new List<String>();
        for(User usr : users) {
            userIds.add(usr.Id);
        }
        

        List<String> toAddresses = new List<String>();
        for(User usr : users) {
            toAddresses.add(usr.Email);
        }
        //toAddresses.add(UserInfo.getUserEmail());
        if(toAddresses.size() > 1000) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'To many Email Recipients'));
            return null;    
        
        }

        Integer i = 0, j = 1;
        Map<Integer, List<String>> toAddressesMap = new Map<Integer, List<String>>();
        toAddressesMap.put(j, new List<String>());
        for(String toAddress :toAddresses) {
            i++;
            //if(i>100) {
            //changed from 100 to 25 because of bcc limit which may content max 25 adresses
            if(i>25) {
                i = 1;
                j++;
                toAddressesMap.put(j, new List<String>());
                system.debug('--- j iterator: '+j);
            }
            toAddressesMap.get(j).add(toAddress);

        }
        //Messaging.reserveSingleEmailCapacity(2);
        Messaging.SingleEmailMessage mail;
        String orgWideAddress = SRW_Utils.getSettingByName('OrgWideEmailAddress');
        if(String.isBlank(orgWideAddress)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Email sender is not configured.'));
            return null;
        }

        List<OrgWideEmailAddress> orgWideAddresses = [select Id, Address, DisplayName from OrgWideEmailAddress where Address =: orgWideAddress];
        String orgWideAddressId;
        if(orgWideAddresses != null && !orgWideAddresses.isEmpty()) {
            orgWideAddressId = orgWideAddresses.get(0).Id;
        }
        if(String.isBlank(orgWideAddressId)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Email sender is not configured.'));
            return null;
        }
        try {
            for(List<String> toAddressesValues : toAddressesMap.values()) {
                mail = new Messaging.SingleEmailMessage();
                //mail.setToAddresses(toAddressesValues);
                mail.setBccAddresses(toAddressesValues);
                mail.setOrgWideEmailAddressId(orgWideAddressId); 
        
                String[] ccAddresses = new String[] {orgWideAddress};               
                mail.setCcAddresses(ccAddresses);   

                mail.setReplyTo(orgWideAddress);
                if(emailSubjectsMap.containsKey(subject))
                    mail.setSubject(emailSubjectsMap.get(subject));
                else 
                    mail.setSubject('gST Email Message');
                mail.setPlainTextBody(emailBody); 
                mail.setBccSender(false);
                mail.setSaveAsActivity(false);
                mail.setUseSignature(false);

                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Email was sent'));
                
            }
            emailBody = '';
            selectedTPOption = 'allActive';
            selectedDataMonth  = 'null';
            selectedTPs = new List<String>{'all'};
            subject = 'null';
        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
        }       
        return null;
    }
    
    public string fillCommunityURL(string emailBodyToFix){
    try{
        String fixedEmailBody = emailBodyToFix;
        if(fixedEmailBody.contains('<gST URL>')){
            system.debug('--- community url detected');
            String myCommunityUrl = SRW_Utils.getSettingByName('Community URL');
            if(myCommunityUrl != null && myCommunityUrl != ''){
                fixedEmailBody = fixedEmailBody.replace('<gST URL>', myCommunityUrl );
                system.debug('--- fixed template: '+fixedEmailBody);
            }
        }
        return fixedEmailBody;
    }catch(exception e){
        return emailBodyToFix;
    }
    
    }
    
    public PageReference cancel() {
        PageReference pr = new PageReference('/apex/SRW_TradingPartnerManagement');
        pr.setRedirect(true);       
        return pr;
    }
    public PageReference selectAllActiveTP() {
        selectedTPOption = 'allActive'; 
        return null;
    }

    public PageReference selectAllInactiveTP() {
        selectedTPOption = 'allInactive';   
        return null;
    }

    public PageReference selectNotSubmittedTP() {
        selectedTPOption = 'notSubmitted';  
        return null;
    }

    public PageReference selectTP() {
        selectedTPOption = 'selectedTPs';   
        return null;
    }
}