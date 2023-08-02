global with sharing class SRW_TradingPartnerManagementController {
    
    public UserWrapper                                  newPortalUser               { get; set; }
    public TradingPartnerWrapper                        newTradingPartner           { get; set; }
    public List<TradingPartnerWrapper>                  tradingPartnerList          { get; set; }
    public String                                       tradingPartnerId            { get; set; }
    //public List<SelectOption>                         tradingPartnerStatusPicklist{ get; set; }
    public String                                       selectedTradingPartnerStatus{ get; set; }
    public String                                       selectedTradingPartner      { get; set; }
    public String                                       selectedTradingPartnerName  { get; set; }
    public map<string,string>                           conId2Usr                   { get; set; }
    public map<string, SRW_Security_Community_Data__c>  conId2SecurComDat           { get; set; }
    public String selectedFileFormat                                                { get; set; }
    public boolean                                      sendActivateEmailTP             { get; set; }
    public boolean                                      sendDeactivateEmailTP           { get; set; }
    
    private Map<Id,SRW_Trading_Partner_Profile__c> tpMap = new Map<Id,SRW_Trading_Partner_Profile__c>();
    
    public SRW_TradingPartnerManagementController(){
        selectedTradingPartnerStatus = 'All';
        sendActivateEmailTP = false;
        sendDeactivateEmailTP = false;
        tradingPartnerList = findTradingPartners(selectedTradingPartnerStatus);
        system.debug('tradingPartnerList: '+tradingPartnerList);
        //tradingPartnerStatusPicklist = fillTradingPartnerStatusPicklist();
        
    }
    
     public List<SelectOption> getFileFormatOptions() {
      
      List<SelectOption> fileFormats = new List<SelectOption>();
      fileFormats.add(new Selectoption('pdf','pdf'));
      fileFormats.add(new Selectoption('csv','csv'));
      fileFormats.add(new Selectoption('xls','xls'));

      return fileFormats;
  }
  
      public PageReference exportDataToFile(){
    
        PageReference newPageRef ;
    
        if(selectedFileFormat == 'xls') {
    
            newPageRef = Page.SRW_Export_Excel;
            newPageRef.getParameters().put('mode', 'partner');
            newPageRef.getParameters().put('csv', 'no');
            newPageRef.getParameters().put('filter', selectedTradingPartnerStatus);
            newPageRef.setRedirect(false);
    
          } else if (selectedFileFormat == 'pdf') {
    
            newPageRef = Page.SRW_Export_Pdf;
            newPageRef.getParameters().put('mode', 'partner');
            newPageRef.getParameters().put('csv', 'no');
            newPageRef.getParameters().put('filter', selectedTradingPartnerStatus);
            newPageRef.setRedirect(true);
          } else {
    
            newPageRef = Page.SRW_Export_CSV;
            newPageRef.getParameters().put('mode', 'partner');
            newPageRef.getParameters().put('csv', 'yes');
            newPageRef.getParameters().put('filter', selectedTradingPartnerStatus);
            newPageRef.setRedirect(true);
          }
    
    
        return newPageRef;
      }
    public PageReference activateEmailTP(){
        sendActivateEmailTP = true;
        return null;
    }
    public PageReference deactivateEmailTP(){
        sendDeactivateEmailTP = true;
        return null;
    }
    public PageReference deactivateTPNo() {
        sendDeactivateEmailTP = false;
        boolean result = deactivateTP();
        return null;
    }
    public PageReference deactivateTPYes() {
        sendDeactivateEmailTP = true;
        boolean result = deactivateTP();
        return null;
    }
    public boolean deactivateTP() {
        system.debug('conId2SecurComDat '+conId2SecurComDat);
        system.debug('------- sendDeactivateEmailTP '+sendDeactivateEmailTP);
        SRW_Trading_Partner_Profile__c tpToUpdate = tpMap.get(selectedTradingPartner);
        tpToUpdate.Trading_Partner_Deactivation_Date__c = system.now();
        update tpToUpdate;
        system.debug(tpToUpdate.Contact_gne__c);
        SRW_Security_Community_Data__c scdToUpdate = conId2SecurComDat.get(tpToUpdate.Contact_gne__c);
        scdToUpdate.Status_gne__c = 'Inactive';
        update scdToUpdate;
        system.debug(tpToUpdate);
        try{
            Id userId = conId2Usr.get(tpToUpdate.Contact_gne__c);
            system.debug(userId);
            UserLogin usrLoginToDeactivate = [Select isFrozen from UserLogin where UserId = :userId];
            system.debug('isFrozen: '+usrLoginToDeactivate.isFrozen);
            usrLoginToDeactivate.isFrozen = true;
            update usrLoginToDeactivate;
            system.debug('isFrozen: '+usrLoginToDeactivate.isFrozen);
        }catch(Exception e){
            system.debug(logginglevel.ERROR, e.getMessage());
        }
        try{
            if(sendDeactivateEmailTP == true){
            sendEmailNotification('deactivate');
        }
        }catch(Exception e){
            system.debug(logginglevel.ERROR, e.getMessage());
        }
        tradingPartnerList = findTradingPartners('All');
        gettradingPartnerStatusPicklist();
        return true;
     }
     
     public PageReference activateTPNo() {
        sendActivateEmailTP = false;
        boolean result = activateTP();
        return null;
    }
    public PageReference activateTPYes() {
        sendActivateEmailTP = true;
        boolean result = activateTP();
        return null;
    }
     
      public boolean activateTP() {
        system.debug('------ sendActivateEmailTP '+ sendActivateEmailTP);
        system.debug('activateTP - BEGIN');
        system.debug('conId2SecurComDat '+conId2SecurComDat);
        SRW_Trading_Partner_Profile__c tpToUpdate = tpMap.get(selectedTradingPartner);
        tpToUpdate.Trading_Partner_Activation_Date__c = system.now();
        update tpToUpdate;
        system.debug('activateTP - tpToUpdate: '+tpToUpdate);
        system.debug(tpToUpdate.Contact_gne__c);
        SRW_Security_Community_Data__c scdToUpdate = conId2SecurComDat.get(tpToUpdate.Contact_gne__c);
        scdToUpdate.Status_gne__c = 'Active';
        update scdToUpdate;
        system.debug('activateTP - scdToUpdate: '+scdToUpdate);
        
        try{
            Id userId = conId2Usr.get(tpToUpdate.Contact_gne__c);
            system.debug(userId);
            UserLogin usrLoginToActivate = [Select isFrozen from UserLogin where UserId = :userId];
            system.debug('activateTP - isFrozen: '+usrLoginToActivate.isFrozen);
            usrLoginToActivate.isFrozen = false;
            update usrLoginToActivate;
            system.debug('activateTP - isFrozen: '+usrLoginToActivate.isFrozen);
            system.debug(logginglevel.INFO, 'activate - after update userLogn');
        }catch(exception e){
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Error during activatingTP: '+e.getMessage()));
            system.debug(logginglevel.ERROR, e.getMessage());
        }
        try{
            if(sendActivateEmailTP == true){
            string sendEmailResult = sendEmailNotification('activate');
        }
        }catch(Exception e){
            system.debug(logginglevel.ERROR, e.getMessage());
        }
        
        tradingPartnerList = findTradingPartners('All');
        gettradingPartnerStatusPicklist();
        system.debug('activateTP - END');
        return true;
        
     }
      public PageReference unlockTP() {
        system.debug('conId2SecurComDat '+conId2SecurComDat);
        SRW_Trading_Partner_Profile__c tpToUpdate = tpMap.get(selectedTradingPartner);
        system.debug(tpToUpdate.Contact_gne__c);
        SRW_Security_Community_Data__c scdToUpdate = conId2SecurComDat.get(tpToUpdate.Contact_gne__c);
        scdToUpdate.Status_gne__c = 'Active';
        update scdToUpdate;
        
        system.debug(tpToUpdate);
        Id userId = conId2Usr.get(tpToUpdate.Contact_gne__c);
        UserLogin usrLoginToUnlock = [Select isFrozen from UserLogin where UserId = :userId];
        usrLoginToUnlock.isFrozen = false;
        update usrLoginToUnlock;
        System.resetPassword(userId, true);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.SRW_Forgot_email_sent));
        
        return null;
     }
     public string sendEmailNotification(String action){
        
        system.debug('------ sendActivateEmailTP '+ sendActivateEmailTP);
        system.debug('------ sendDeactivateEmailTP '+ sendDeactivateEmailTP);
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
        
        Messaging.SendEmailResult err;
        string tpAction = null;
        string message = '';
        string oweaID = orgWideAddressId;
        string myCommunityName  = 'SRW-Partner Community';
        SRW_Trading_Partner_Profile__c tpToUpdate = tpMap.get(selectedTradingPartner);
        system.debug(tpToUpdate);
        Id userId = conId2Usr.get(tpToUpdate.Contact_gne__c);
        user tmpuser = [Select userName, email from user where id = :userid limit 1][0];
        system.debug(tmpuser);
        //getting community URL
        //Network myCommunity = [SELECT Id FROM Network WHERE Name = :myCommunityName];
        //String myCommunityUrl = myCommunity.getPublicUrl();
        //String myCommunityUrl = URL.getSalesforceBaseUrl().toExternalForm();
        String myCommunityUrl = SRW_Utils.getSettingByName('Community URL');
        //String myCommunityUrl = 'https://srw-srwdev.cs1.force.com/partner/';
        if(action == 'activate'){
            tpAction = 'Trading Partner Activation';
            message = 'Dear ' + selectedTradingPartnerName + ',<br/><br/>';
            //message = SRW_Utils.getSettingByName('TPActivationEmailHeader');
            message += 'Your gST account has been activated. <br/><br/>';
            message += 'Use fallowing link to login into system: <br/>';
            message += myCommunityUrl   ;
            
            message += '<br/><br/><br/>';
            message +=  'If you have questions, please send an email to gSalesTracker-d@gene.com.<br/>';
            message += 'Thank you for your interest and participation !<br/>Genentech Sales Tracker Data Manager or <br/>Genentech FOIM Data Management';
                 
        }else if(action == 'deactivate'){
            tpAction = 'Trading Partner Activation';
            message = 'Dear ' + selectedTradingPartnerName + ',<br/><br/>';
            message += 'Your gST account has been deactivated. <br/><br/>';
            
            message +=  'If you have questions, please send an email to gSalesTracker-d@gene.com.<br/>';
            message += 'Thank you for your interest and participation !<br/>Genentech Sales Tracker Data Manager or <br/>Genentech FOIM Data Management';
                 
        }
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddress = new String[] {string.valueof(tmpuser.Email)};
        mail.setOrgWideEmailAddressId(orgWideAddressId); 
        mail.setReplyTo(orgWideAddress);
        mail.setToAddresses(toAddress);
        mail.setSubject('Genentech gST Help Desk');
        mail.setHtmlBody(message);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        return 'Success';
     }
     
     public  List<TradingPartnerWrapper> findTradingPartners(){
        List <TradingPartnerWrapper> tradingPartnerList = new List <TradingPartnerWrapper>();
        for(SRW_Trading_Partner_Profile__c tpprof : [select id, name, Active_gne__c , Trading_Partner_Name_gne__c, Trading_Partner_User_Name_gne__c, Trading_Partner_Address_1_gne__c, Trading_Partner_Address_2_gne__c, City_gne__c, State_gne__c, Zip_Code_gne__c, Contact_Email_Address_gne__c, Trading_Partner_Activation_Date__c, Trading_Partner_Deactivation_Date__c  from SRW_Trading_Partner_Profile__c ] ){
            tradingPartnerList.add(new TradingPartnerWrapper(tpprof));
            tpMap.put(tpprof.Id, tpprof);
        }
        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, 'Selected: '+selectedTradingPartnerStatus));
        system.debug(tradingPartnerList);
        return tradingPartnerList;
     }
     public  List<TradingPartnerWrapper> findTradingPartners(String tpStatus){
        tradingPartnerList = new List<TradingPartnerWrapper>();
        
         // nowy mechanizm
         SRW_Trading_Partner_Profile__c[] tpList = [Select Id,Contact_gne__c from SRW_Trading_Partner_Profile__c];
        //map ContactId to TPProf
        Map<String, String> conId2TPProfId = new map<String,String>();
        Map<string, string> tpId2status = new map<String, String>();
        List<SRW_Security_Community_Data__c> securCommList = new List<SRW_Security_Community_Data__c>();
        securCommList = [Select Id,Trading_Partner_gne__c, Trading_Partner_gne__r.Contact_gne__c, Status_gne__c from SRW_Security_Community_Data__c
                                                            WHERE Trading_Partner_gne__r.Contact_gne__c != null and Status_gne__c in ('Active','Inactive','Locked')];
        
         conId2SecurComDat = new map<string, SRW_Security_Community_Data__c>();
        for(SRW_Security_Community_Data__c tempsecCommDat : securCommList){
            //system.debug(tempsecCommDat.Trading_Partner_gne__r.Contact_gne__c+' \n\n'+tempsecCommDat.Status_gne__c);
            conId2TPProfId.put(tempsecCommDat.Trading_Partner_gne__r.Contact_gne__c, tempsecCommDat.Trading_Partner_gne__c);
            tpId2status.put(tempsecCommDat.Trading_Partner_gne__c, tempsecCommDat.Status_gne__c);
            //system.debug('Contact_gne__c: '+tempsecCommDat.Trading_Partner_gne__r.Contact_gne__c);
            conId2SecurComDat.put(tempsecCommDat.Trading_Partner_gne__r.Contact_gne__c, tempsecCommDat);
        }
        //map userId to security status
        /*for(UserLogin tempUsrLog : [Select id, UserId, IsFrozen From UserLogin where UserId in (Select Id from User where ContactId in :conId2TPProfId.keySet())]){
            system.debug(tempUsrLog.UserId);
        }*/
         conId2Usr = new Map<string,string>{};
        for(User tempUsr : [Select Id, ContactId from User where ContactId in :conId2TPProfId.keySet()]){
            conId2Usr.put(tempUsr.ContactId, tempUsr.Id);
        }
        
        //final TPProf list
        string[] tppprodIdList = new string[]{};
        for(string tmpConId : conId2Usr.keySet()){
            tppprodIdList.add(conId2TPProfId.get(tmpConId));
        }
        system.debug('tppprodIdList list: '+tppprodIdList);
        //for(SRW_Trading_Partner_Profile__c tmpTpprof : [select id, name, Active_gne__c, Contact_gne__c, Contract_Effective_Date_gne__c, Contract_Termination_Date_gne__c, Trading_Partner_Name_gne__c, Trading_Partner_User_Name_gne__c,  Trading_Partner_Address_1_gne__c, Trading_Partner_Address_2_gne__c, Contact_Email_Address_gne__c from SRW_Trading_Partner_Profile__c where id in :tppprodIdList ]){
        for(SRW_Trading_Partner_Profile__c tmpTpprof : [select id, name, Active_gne__c, Contact_gne__c, Contract_Effective_Date_gne__c, Contract_Termination_Date_gne__c, Trading_Partner_Name_gne__c, Trading_Partner_User_Name_gne__c,  Trading_Partner_Address_1_gne__c, Trading_Partner_Address_2_gne__c, City_gne__c, State_gne__c, Zip_Code_gne__c, Contact_Email_Address_gne__c from SRW_Trading_Partner_Profile__c where id in :conId2TPProfId.values() order by Trading_Partner_Name_gne__c asc]){
            string tpStatusForTP = tpId2status.get(tmpTpprof.Id);
            //system.debug(tmpTpprof.Trading_Partner_Name_gne__c); 
            tradingPartnerList.add(new TradingPartnerWrapper(tmpTpprof, tpStatusForTP));
            tpMap.put(tmpTpprof.Id, tmpTpprof);
        }
            
        
        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, 'tp.size: '+tradingPartnerList.size()));
        
        system.debug(tradingPartnerList);
        return tradingPartnerList;
     }
      /*public  void findTradingPartnersPageReferenceHelper(){
        List <TradingPartnerWrapper> tradingPartnerList = new List <TradingPartnerWrapper>();
        tradingPartnerList = findTradingPartners('All');
      }
     */
      public  void findTradingPartnersPageReference(){
        findTradingPartners('All');
        
        
      }
      
     
     
     public List<SelectOption> fillTradingPartnerStatusPicklist(){
        List<String> tradingPartnerStatusPicklist = new List<String>{'All', 'Active','Inactive','Locked'};
        
        List<SelectOption> optionList = new List<SelectOption>();
                                                for(String tempOption: tradingPartnerStatusPicklist){
                                                    optionList.add(new SelectOption(tempOption, tempOption));
                                                }
                                                
        return optionList;
     }
     public List<SelectOption> gettradingPartnerStatusPicklist(){
         List<SelectOption> status = new List<SelectOption>();
          status.add(new Selectoption('All','All'));
          status.add(new Selectoption('Active','Active'));
          status.add(new Selectoption('Inactive','Inactive'));
          status.add(new Selectoption('Locked','Locked'));
          system.debug(status); 
      return status;
     }
     
        public PageReference setTPId(){

            selectedTradingPartnerName = tpMap.get(selectedTradingPartner).Trading_Partner_Name_gne__c;

        return null;
  }
    
    
    /** @date 19/11/2014
    * @Author Damian Gwozdowski
    * @description button redirecting to addNewTradingPartner page
    */
    public PageReference addNewTradingPartner(){
        PageReference pr = new PageReference('/apex/SRW_AddNewTradingPartner');
         pr.setRedirect(true);
         return pr;
    }
    
    public PageReference viewTradingPartner(){
        PageReference pr = Page.SRW_ViewTradingPartner;
        pr.getParameters().put('partner', selectedTradingPartner);
        pr.setRedirect(false);
        return pr;
    }
    
    
    
     /** @date 18/11/2014
    * @Author Damian Gwozdowski
    * @description Method generating Nickname for User
    * @param String firstName (User first name), String lastName (User last name)
    */
    private String generateNickname(String firstName, String lastName) {
        String nickname = firstName + '.' +lastName;
        for(Integer i=0; i<100; i++) {
            List<User> userList = [SELECT Id FROM User WHERE CommunityNickname = :nickname];
            if(userList.size() < 1) {
                return nickname;
            } else {
                Integer randomNum = Integer.valueOf(Math.random()*1000);
                nickname = firstName + '.' +lastName + randomNum;
            }
        }
        return null;
    }

    public PageReference emailTradingPartnerRedirect(){
        PageReference pr = new PageReference('/apex/SRW_EmailTradingPartner');
        pr.setRedirect(true);
        return pr;
    }
    
     public class UserWrapper {
        public String firstName {get; set;}
        public String lastName {get; set;}
        public String emailAddress {get; set;}
        public String phone {get;set;}

        public UserWrapper(String fn, String ln, String email, String phoneVal) {
            this.firstName = fn;
            this.lastName = ln;
            this.emailAddress = email;
            this.phone = phoneVal;
        }

        public UserWrapper() {}
    }
     public class TradingPartnerWrapper {
        public SRW_Trading_Partner_Profile__c tradingPartner {get;set;}
        public String tradingPartnerStatus {get; set;}
        
        public TradingPartnerWrapper(SRW_Trading_Partner_Profile__c tradingPartner) {
            this.tradingPartner = tradingPartner;
        }
         public TradingPartnerWrapper(SRW_Trading_Partner_Profile__c tradingPartner, string statusFromSecurityObject) {
            this.tradingPartner = tradingPartner;
            this.tradingPartnerStatus = statusFromSecurityObject;
        }
        
    }
    
}