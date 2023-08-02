public with sharing class SRW_ViewTradingPartnerController {
    
    
    
    public String partnerId{get; set;}
    public Boolean isMimicVisible {get; set;}
    public Boolean isUserCreated {get; set;}
    public Boolean isPartnerIdOK {get; set;}
    public String tradingPartnerUserId {get; set;}
    public String newUserName {get; set;}
    public SRW_ViewTradingPartnerController(){
        partnerId='';
        isPartnerIdOK=false;
        partnerId = ApexPages.currentPage().getParameters().get('partner');
        String userId = UserInfo.getUserId();
        List<SRW_Mimic_Data__c> mimicData = [select Id, SRW_Trading_Partner_Profile_gne__c, User_gne__c from SRW_Mimic_Data__c where User_gne__c =: userId and SRW_Trading_Partner_Profile_gne__c =: partnerId]; 
        isMimicVisible = true;
        if(mimicData != null && mimicData.size() > 0)
            isMimicVisible = false;
        isUserCreated = true;
        if(partnerId != null && (partnerId.length()==15 || partnerId.length()==18)){
            isPartnerIdOK= true;
        }
        if([Select Id from User where ContactId in (Select Contact_gne__c FROM SRW_Trading_Partner_Profile__c 
                                                    WHERE id = :partnerId) ].isEmpty()&&isPartnerIdOK == true){
                                                        isUserCreated = false;
                                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.SRW_RecreateUser));
                                                    }
        system.debug('--- isUserCreated: '+isUserCreated);
        system.debug('--- isPartnerIdOK: '+isPartnerIdOK);
    }
    
    public SRW_Trading_Partner_Profile__c getNewTradingPartner(){
        try{
        SRW_Trading_Partner_Profile__c newTradingPartner = [SELECT
            Trading_Partner_Phone_gne__c,
            Trading_Partner_Name_gne__c ,
            Trading_Partner_User_Name_gne__c,
            TP_Phone_Extn_gne__c,
            Trading_Partner_Fax_gne__c,
            Contact_gne__c,
            Contact_First_Name_gne__c,
            Contact_Last_Name_gne__c,
            Contact_Email_Address_gne__c,
            Contract_Effective_Date_gne__c,
            Contract_Termination_Date_gne__c,
            MCCO_Account_Manger_gne__c,
            Comment_gne__c 
            FROM SRW_Trading_Partner_Profile__c 
            WHERE id = :partnerId
            LIMIT 1][0];
            return newTradingPartner;
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'MISSING OR INVALID TRADING PARTNER ID. PLEASAE CONTACT SFDC SYSTEM ADMINISTRATOR.'));
            return null;
        }

            
        
    }
    public List<Product_vod__c> getAssignedProducts(){
        List<Product_vod__c> products = new List<Product_vod__c>();
        products = [Select Name From Product_vod__c Where Id in (Select Product_gne__c From SRW_Trd_Prt_Product_gne__c where Trading_Partner_gne__c =:partnerId) ORDER BY Name];
        return products;
    }
    
    public pageReference back(){
        PageReference newPageRef;
        newPageRef = Page.SRW_TradingPartnerManagement;
        newPageRef.setRedirect(true);
        return newPageRef;
    }

    public PageReference mimicTP() {
        String userId = UserInfo.getUserId();
        SRW_Mimic_Data__c mimicRecord; 
        List<SRW_Mimic_Data__c> mimicData = [select Id, SRW_Trading_Partner_Profile_gne__c, User_gne__c from SRW_Mimic_Data__c where User_gne__c =: userId]; 
        if(mimicData != null && mimicData.size() == 1)
            mimicRecord = mimicData.get(0);
        else if(mimicData != null && mimicData.size() > 1)
            delete mimicData;

        if(mimicRecord == null)
            mimicRecord = new SRW_Mimic_Data__c(User_gne__c = userId);

        mimicRecord.SRW_Trading_Partner_Profile_gne__c = partnerId;
        upsert mimicRecord;

        PageReference pr = Page.SRW_SubmitSalesData;
        pr.setRedirect(true);

        return pr;
    }
    public pageReference recreateUser(){
         SRW_Trading_Partner_Profile__c newTradingPartner = [SELECT
            Trading_Partner_Phone_gne__c,
            Trading_Partner_Name_gne__c ,
            Trading_Partner_User_Name_gne__c,
            TP_Phone_Extn_gne__c,
            Trading_Partner_Fax_gne__c,
            Contact_gne__c,
            Contact_First_Name_gne__c,
            Contact_Last_Name_gne__c,
            Contact_Email_Address_gne__c,
            Contract_Effective_Date_gne__c,
            Contract_Termination_Date_gne__c,
            MCCO_Account_Manger_gne__c,
            Comment_gne__c,
            Id
            FROM SRW_Trading_Partner_Profile__c 
            WHERE id = :partnerId
            LIMIT 1][0];
            
            
        User u = new User();
        String usernameSuffix = SRW_Utils.getSettingByName('UsernameSufix');//SRW_Settings__c.getAll().get('sqa').Username_Suffix_gne__c;
        if(newUserName == null || newUserName == ''){
        newUserName = newTradingPartner.Trading_Partner_User_Name_gne__c;
        }else{
                // checking username format
                string userNameString = newUserName ;
                String userNameRegEx = '^[a-zA-Z0-9]{8,}$';//'[A-Z]|[a-z]|[0-9]';
                Pattern MyPattern = Pattern.compile(userNameRegEx);
                Matcher MyMatcher = MyPattern.matcher(userNameString);
                Boolean result = MyMatcher.matches();
                if(!result){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'User name should contains only letters and/or numbers. No special chars or spaces are avaliable.Minimum 8 chars');
                    ApexPages.addMessage(myMsg);
                    return null;
                }
                // checking if username is duplicated
               
                try{
                    String userNameQuery = newUserName  + usernameSuffix;
                    List<User> tempUsrList = [select Id From User where Username =: userNameQuery];
                    if(!tempUsrList.isEmpty()) {
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'UserName: '+newUserName +' is not unique.');
                        ApexPages.addMessage(myMsg);
                        system.debug('--- tp username not unique');
                        return null;
                    } else if(![Select id from SRW_Trading_Partner_Profile__c where Trading_Partner_User_Name_gne__c = :newUserName].isEmpty()){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'UserName: '+newUserName +' is not unique.'));
                        return null;
                    }
                }catch(Exception e){
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Error during checking if username is duplicated. Please try other.'+e.getMessage());
                        ApexPages.addMessage(myMsg);
                        return null;
                }
        }
        u.UserName = newUserName + usernameSuffix;
        u.FirstName = newTradingPartner.Contact_First_Name_gne__c;
        u.LastName = newTradingPartner.Contact_Last_Name_gne__c;
        u.Email = newTradingPartner.Contact_Email_Address_gne__c;
        u.EmailEncodingKey = 'UTF-8';
        u.CommunityNickname = newUserName;
        String accountIdForTradingPartner = SRW_Utils.getSettingByName('AccountId');//SRW_Settings__c.getAll().get('sqa').AccountId__c;
        Account[] acc = [select id, name from Account where Id = :accountIdForTradingPartner limit 1];
        Account accForContact = acc.size()==0 ? null : acc[0];
        string roleId = [select id, name from Userrole where name like :accForContact.Name+'%' and name like '%Partner Executive' limit 1][0].Id;
        System.debug('--- roleId ' + roleId);
        string profileId = [select id from Profile where name = 'GNE-GST-Partner-External'][0].Id;
        u.ProfileId = ProfileId;
        u.UserRoleId = roleId;
        u.ContactId = newTradingPartner.Contact_gne__c;
        u.CommunityNickname = newUserName+usernameSuffix;
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.LocaleSidKey = 'en_US';
        u.LanguageLocaleKey = 'en_US';
        u.TPName__c = newTradingPartner.Trading_Partner_Name_gne__c;
        
        try{
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.EmailHeader.triggerUserEmail = false;
            dml.EmailHeader.triggerAutoResponseEmail = false;
            dml.EmailHeader.triggerOtherEmail = false;
            Database.SaveResult sr = Database.Insert(u, dml);
            System.debug('Save Results: ' + sr);
            if(sr.isSuccess()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'User recreated with success!'));
                updateTP(newTradingPartner.Id, newTradingPartner.Contact_gne__c, newUserName, newTradingPartner.Contact_Email_Address_gne__c);
                PageReference pr = new PageReference('/apex/srw_viewtradingpartner?partner=' + partnerId);
                pr.setRedirect(true);
        
                return pr;
            }else{
                String dbError = 'The following error has occurred: ';
                for(Database.Error err : sr.getErrors()) {
                   dbError += err.getStatusCode() + ': ' + err.getMessage() + ': ' +err.getFields();               
                    
                }
               Messaging.SingleEmailMessage sem = new Messaging.SingleEmailMessage();
               String htmlBody = '<div>User: ' + newUserName + usernameSuffix +'</div><div>Email: ' + newTradingPartner.Contact_Email_Address_gne__c + '</div><div>Error message: '+dbError +'</div>';
               String subject = 'CREATING USER FOR TRADING PARTNER EXCEPTION';
               List<String> addresses = new List<String>();
               sem.setHtmlBody(htmlBody);
               sem.setSubject(subject);
               String emailAddress = SRW_Utils.getSettingByName('OrgWideEmailAddress');
               OrgWideEmailAddress[] owea = [select Id, Address from OrgWideEmailAddress where Address = :emailAddress LIMIT 1];
               addresses.add(owea[0].Address);
               sem.setToAddresses(addresses);
               sem.setOrgWideEmailAddressId(owea[0].id);
               Messaging.SendEmailResult[] ser = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {sem});
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error during user recreation. Please contact System Administrator. Error message: '+dbError ));
        
            }
            
        }catch(Exception e){
           System.debug('----- ex ' + e.getMessage());
           Messaging.SingleEmailMessage sem = new Messaging.SingleEmailMessage();
           String htmlBody = '<div>User: ' + newUserName + usernameSuffix +'</div><div>Email: ' + newTradingPartner.Contact_Email_Address_gne__c + '</div><div> Errod message: '+e.getMessage()+'</div>';
           String subject = 'CREATING USER FOR TRADING PARTNER EXCEPTION';
           List<String> addresses = new List<String>();
           sem.setHtmlBody(htmlBody);
           sem.setSubject(subject);
           String emailAddress = SRW_Utils.getSettingByName('OrgWideEmailAddress');
           OrgWideEmailAddress[] owea = [select Id, Address from OrgWideEmailAddress where Address = :emailAddress LIMIT 1];
           addresses.add(owea[0].Address);
           sem.setToAddresses(addresses);
           sem.setOrgWideEmailAddressId(owea[0].id);
           Messaging.SendEmailResult[] ser = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {sem});
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error during user recreation. Please contact System Administrator.'));
        }
        return null;
    }
    @future
    public static void updateTP(string tpId, string conId, string tpUserName, string tpEmail){
        try{
            SRW_Trading_Partner_Profile__c tpToUpdate = new SRW_Trading_Partner_Profile__c();
            tpToUpdate.Id = tpId;
            tpToUpdate.Trading_Partner_User_Name_gne__c = tpUserName;
            update tpToUpdate;
            Contact conToUpdate = new Contact();
            conToUpdate.Id = conId;
            conToUpdate.SRW_Username__c = tpUserName;
            update conToUpdate;
        }catch(Exception e){
            System.debug('----- ex ' + e.getMessage());
           Messaging.SingleEmailMessage sem = new Messaging.SingleEmailMessage();
           String htmlBody = '<div>User: ' + tpUserName+'</div><div>Email: ' + tpEmail + '</div><div>Updating Trading Partner SFDC Id: ' + tpId+ '</div><div>Updating Contact SFDC Id: ' + conId+ '</div><div> Error message: '+e.getMessage()+'</div>';
           String subject = 'CREATING USER FOR TRADING PARTNER EXCEPTION';
           List<String> addresses = new List<String>();
           sem.setHtmlBody(htmlBody);
           sem.setSubject(subject);
           String emailAddress = SRW_Utils.getSettingByName('OrgWideEmailAddress');
           OrgWideEmailAddress[] owea = [select Id, Address from OrgWideEmailAddress where Address = :emailAddress LIMIT 1];
           addresses.add(owea[0].Address);
           sem.setToAddresses(addresses);
           sem.setOrgWideEmailAddressId(owea[0].id);
           Messaging.SendEmailResult[] ser = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {sem});
           
        }
    }
    
}