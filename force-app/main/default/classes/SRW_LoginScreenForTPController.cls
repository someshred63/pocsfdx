global class SRW_LoginScreenForTPController {
    //TODO: lock user - info to security
    //NEXT TODO: Submit Sales Data!!
    private String usernameSuffix;
    
    global String userPrefix {get; set;}
    global String passwordUsernamePrefix {get; set;}
    
    global SRW_LoginScreenForTPController(){
        //RW_Settings__c settings = [SELECT Name, Username_Suffix_gne__c FROM SRW_Settings__c WHERE Name ='sqa'];
        usernameSuffix = SRW_Utils.getSettingByName('UsernameSufix');//settings.Username_Suffix_gne__c;
    }
    
    global PageReference forwardToCustomAuthPage(){
        if (UserInfo.getUserType()=='Guest') {
            PageReference pr = Page.SRW_LoginScreenForTradingPartners;
            pr.setRedirect(true);
            return pr;
        } else { 
            return null;
        } 
    }
    
    global PageReference loginUsernamePrefix(){
        String loginName = userPrefix + usernameSuffix;
        List<LoginHistory> communityUserLoginHistory = new List<LoginHistory>();
        User userToLogin = new User();
        SRW_Security_Community_Data__c securData = new SRW_Security_Community_Data__c();
        SRW_Security_Community_Data__c obj =  new SRW_Security_Community_Data__c();
        UserLogin ul = new UserLogin();
        try{
            userToLogin = [SELECT id, ContactId FROM User WHERE Username = :loginName];
            securData = [SELECT id, securityQuestion__c, Status_gne__c FROM SRW_Security_Community_Data__c WHERE Trading_Partner_gne__r.Contact_gne__c = :userToLogin.ContactId];
            ul = [SELECT UserId, isFrozen FROM UserLogin WHERE UserId = :userToLogin.Id LIMIT 1];
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.SRW_Invalid_Username_or_Password));
            System.debug('Error: ' + e.getMessage());
        }
        if(securData == obj){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.SRW_Invalid_Username_or_Password));
            return null;
        } else {
            system.debug('apex messages: ' + ApexPages.getMessages());
            try{
                PageReference login = new PageReference('');
                system.debug('before login');
                if(String.isBlank(securData.SecurityQuestion__c)){
                    login = Site.login(loginName, passwordUsernamePrefix,Page.SRW_SetSecurityQA.getURL());
                } else {
                    login = Site.login(loginName, passwordUsernamePrefix, null); 
                }
                List<ApexPages.Message> apmsg = ApexPages.getMessages();
                System.debug('apex messages: ' + apmsg);
                if(apmsg.size() > 0){
                    if (apmsg[0].getDetail().equals('Your login attempt has failed. Make sure the username and password are correct.')){
                        communityUserLoginHistory = [SELECT status FROM LoginHistory WHERE UserId = :userToLogin.id Order by LoginTime desc LIMIT 1];
                        if(communityUserLoginHistory[0].status.Equals('Password Lockout') ){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.SRW_User_is_locked));
                            securData.Status_gne__c = 'Locked';
                            update securData;
                        }else if(ul.IsFrozen){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'USER IS DEACTIVATED. CONTACT WITH YOUR FOIM BUSINESS PARTNER TO REACTIVATE THE ACCOUNT.'));
                        }
                        return null;
                    }
                    return null;
                } else {
                    return login;
                }
            }catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.SRW_Invalid_Username_or_Password));
                System.debug('Login failed. Error: ' + e.getMessage());
                return null;
            }
        }
    }
}