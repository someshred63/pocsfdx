public with sharing class SRW_ForgotPasswordController{
    
    private String usernameSuffix;
    private Integer counter;
    
    public String username {get; set;}
    public String securityQuestion {get; set;}
    public String securityAnswer {get; set;}
    public SRW_Security_Community_Data__c securityData;
    public List<SelectOption> securityQuestionsForPickList;
    
    public SRW_ForgotPasswordController(){
        securityData = new SRW_Security_Community_Data__c();
        //SRW_Settings__c settings = [SELECT Name, Username_Suffix_gne__c FROM SRW_Settings__c WHERE Name ='sqa'];
    	usernameSuffix = SRW_Utils.getSettingByName('UsernameSufix');//settings.Username_Suffix_gne__c;
        counter = 0;
        securityQuestionsForPickList = new List<SelectOption>();
    }
    
    public List<SelectOption> getSecurityQuestionsForPickList(){
        Schema.DescribeFieldResult fieldResult = SRW_Security_Community_Data__c.SecurityQuestion__c.getDescribe();
        List<Schema.PicklistEntry> pickListEntry = fieldResult.getPicklistValues();
        List<SelectOption> options = new List<SelectOption>();
        for (Schema.PicklistEntry ple : pickListEntry) {
            options.add(new SelectOption(ple.getLabel(), ple.getValue()));
        }
        return options;
    }
    
    public PageReference returnToLoginPage(){
        PageReference pr = Page.SRW_LoginScreenForTradingPartners;
        pr.setRedirect(true);
        return pr;
    }
    
    public PageReference resetPassword(){
        String login = username + usernameSuffix;
        User userToResetPassword = new User();
        List<LoginHistory> communityUserLoginHistory = new List<LoginHistory>();
        SRW_Security_Community_Data__c obj = new SRW_Security_Community_Data__c();
        UserLogin ul = new UserLogin();
        Boolean passwordLockout;
        try{
        	userToResetPassword = [SELECT id, FirstName, LastName, Email, ContactId, Username FROM User WHERE Username = :login];
            securityData = [SELECT id, securityAnswer__c, securityQuestion__c, Fail_Reset_Password_Attempts_gne__c, Status_gne__c FROM SRW_Security_Community_Data__c WHERE Trading_Partner_gne__r.Contact_gne__c = :userToResetPassword.ContactId];
            communityUserLoginHistory = [SELECT status FROM LoginHistory WHERE UserId = :userToResetPassword.id Order by LoginTime desc LIMIT 1];
            ul = [SELECT Id, UserId, isFrozen FROM UserLogin WHERE UserId = :userToResetPassword.id LIMIT 1];
            passwordLockout = communityUserLoginHistory.isEmpty() ? false : communityUserLoginHistory[0].status.Equals('Password Lockout');
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.SRW_Forgot_error_message));
            System.debug('No user with such username. DB error: ' + e.getMessage());
            return null;
        } if (securityData == obj){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.SRW_Forgot_error_message));
            return null;
        }else if (passwordLockout || ul.isFrozen){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.SRW_User_is_locked));
            return null;
        }else if(securityData.Fail_Reset_Password_Attempts_gne__c >= 4){
            lockUser(userToResetPassword);
            securityData.Status_gne__c = 'Locked';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.SRW_User_is_locked));
            return null;
        }else if(securityQuestion == securityData.securityQuestion__c){
                if(securityAnswer == securityData.securityAnswer__c){
                    System.resetPassword(userToResetPassword.Id, true);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.SRW_Forgot_email_sent));
                    securityData.Fail_Reset_Password_Attempts_gne__c = 0;
                    update securityData;
                    return null;
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.SRW_Forgot_error_message));
                    securityData.Fail_Reset_Password_Attempts_gne__c = securityData.Fail_Reset_Password_Attempts_gne__c == null ? 0 : securityData.Fail_Reset_Password_Attempts_gne__c++; 
                    update securityData; 
                    return null;
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.SRW_Forgot_error_message));
                securityData.Fail_Reset_Password_Attempts_gne__c = securityData.Fail_Reset_Password_Attempts_gne__c == null ? 0 : securityData.Fail_Reset_Password_Attempts_gne__c++;
                update securityData;
                return null;
            }
        
    }
    
    public void lockUser(User u){
    	PageReference dummyPr = new PageReference('');
    	for(Integer i=0; i<4; i++){
    		dummyPr = Site.login(u.username, 'dummypassword', null); 
    	}
    }
}