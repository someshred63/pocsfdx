public without sharing class SRW_UserOperationUtils {
    public User currentUser;
    
    public SRW_UserOperationUtils(Id userId){
        this.currentUser = [SELECT id, ContactId, Username FROM User WHERE Id = :userId];
    }
    public SRW_UserOperationUtils(){
        this.currentUser = [SELECT id, ContactId, Username FROM User WHERE Id = :UserInfo.getUserId()];
    }

    public static boolean newStringMatchesConfirm(String newString, String confirmString){
        return (newString == confirmString);
    }
    public static boolean newPasswordMinimalLength(String newPassword){
        return (newPassword.length() > 7);
    }
    public static boolean newPasswordVariousChars(String newPassword){
        return ((newPassword.containsAny('1234567890')) && (newPassword.containsAny('qwertyuiopasdfghjklzxcvbnm')) && (newPassword.containsAny('QWERTYUIOPASDFGHJKLZXCVBNM')));
    }
    public static boolean newUsernameMinimalLength(String username){
        return (username.length() > 7);
    }    
    public static boolean newUsernameIsValid(String username){
        String userNameRegEx = '^[a-zA-Z0-9]{8,}$';//'[A-Z]|[a-z]|[0-9]';
        Pattern MyPattern = Pattern.compile(userNameRegEx);
        Matcher MyMatcher = MyPattern.matcher(username);
        return MyMatcher.matches();
    } 
    public boolean oldUsernameMatches(String oldUsername){
        String username = currentUser.Username;
        return (oldUsername.equals(username.substring(0, (username.indexOf('@')))));
    }
    
    public PageReference changeCurrentUserPassword(String newPassword, String confirmPassword, String oldPassword){
        if(newStringMatchesConfirm(newPassword, confirmPassword)){
            if(newPasswordMinimalLength(newPassword)){
                if(newPasswordVariousChars(newPassword)){
                        PageReference pr = Site.changePassword(newPassword, confirmPassword, oldPassword); 
                        System.debug('password changed');
                        System.debug('pr:' + pr);
                        if(pr != null){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.SRW_Password_changed));
                            return null;
                        } else {
                            return null;
                        }
                } else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.SRW_Password_characters_error));
                    return null;
                }
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.SRW_Password_length_error));
                return null;
            }
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.SRW_Password_does_not_match));
            return null;
        }
    }
    
    public PageReference changeCurrentUserUsername(String newUsername, String confirmUsername, String oldUsername){
        if(newStringMatchesConfirm(newUsername, confirmUsername)){
            if (newUsernameMinimalLength(newUsername) && newUsernameIsValid(newUsername) ){
                if(oldUsernameMatches(oldUsername)){
                    currentUser.username = newUsername + SRW_Utils.getSettingByName('UsernameSufix');//settings.Username_Suffix_gne__c;
                    System.debug('user to update: ' + currentUser);
                    try{
                        update currentUser;
                        futureUpdateContact(currentUser.ContactId, currentUser.Username);
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.SRW_TP_profile_changed));
                    }catch(Exception e){
                        system.debug('db exception: ' + e.getMessage()); 
                    }
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Old username does not match'));
                    System.debug('validation fails');
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.SRW_UsernameChangeError));
                System.debug('validation fails');
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Confirm username does not match new username.'));
            System.debug('validation fails');
        }
        return null;
    }

    @future
    public static void futureUpdateContact(String contactId, String username){
        Contact c = [SELECT id, SRW_Username__c FROM Contact WHERE id = : contactId];
        c.SRW_Username__c = username;
        SRW_Trading_Partner_Profile__c tpp = [SELECT id, Trading_Partner_User_Name_gne__c, Username_gne__c FROM SRW_Trading_Partner_Profile__c WHERE Contact_gne__c = :c.id];
        tpp.Username_gne__c = username;
        tpp.Trading_Partner_User_Name_gne__c = username.substring(0, username.indexOf('@'));
        try{
            update tpp;
            update c;
        }catch(Exception e){
            system.debug('db exception: ' + e.getMessage()); 
        }
    }

    private void switchAdminMode(Boolean isAdminMode, Id userid) {
      Id currentUserId = userid;
      List<GNE_SFA2_Admin_Mode__c> adminModeSetting = [SELECT Id, SetupOwnerId, GNE_SFA2_Is_Admin_Mode__c FROM GNE_SFA2_Admin_Mode__c WHERE SetupOwnerId = :currentUserId LIMIT 1];
      if (adminModeSetting.isEmpty()) {
        insert new GNE_SFA2_Admin_Mode__c(SetupOwnerId = currentUserId, GNE_SFA2_Is_Admin_Mode__c = isAdminMode);
      } else {
        adminModeSetting.get(0).GNE_SFA2_Is_Admin_Mode__c = isAdminMode;
        update adminModeSetting;
      }
    }
    
    public PageReference assignSecurityQAForCurrentUser(String securityQuestion, String securityAnswer, boolean returnToHomePage){
        SRW_Security_Community_Data__c securityData;
        try{
            securityData = [SELECT id, securityAnswer__c, securityQuestion__c FROM SRW_Security_Community_Data__c WHERE Trading_Partner_gne__r.Contact_gne__c = :CurrentUser.ContactId];
        }catch(Exception e){
            System.debug('DB error: ' + e.getMessage());
        }
        if(!String.isBlank(securityAnswer)){
            securityData.SecurityQuestion__c = securityQuestion;
            securityData.SecurityAnswer__c = securityAnswer;
            update securityData;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.SRW_SecurityQASet));
            if(returnToHomePage){
                PageReference pr = Page.SRW_HomePageRouter;
                pr.setRedirect(true);
                return pr;
            }else 
            return null;
        }else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill Security Answer.'));
            System.debug('No answer.');
            return null;
        }
    }
    
    public PageReference resetCurrentTradingPartnerSecurityQA(){
        SRW_Security_Community_Data__c securityQAData = [SELECT id, securityAnswer__c, securityQuestion__c FROM SRW_Security_Community_Data__c WHERE Trading_Partner_gne__r.Contact_gne__c = :CurrentUser.ContactId];
        securityQAData.securityQuestion__c = null;
        securityQAData.securityAnswer__c = null;
        update securityQAData;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.SRW_Security_QA_reset));
        sendEmailToCurrentUserFromTemplate('SRW_ResetSecurityQA');
        return null;
    }
    
    public void sendEmailToCurrentUserFromTemplate(String emailTemplateUniqueName){
        EmailTemplate forgotUsernameTemplate = [SELECT id FROM EmailTemplate WHERE developerName = :emailTemplateUniqueName LIMIT 1];
        Messaging.SingleEmailMessage sem = new Messaging.SingleEmailMessage();
        sem.setTemplateId(forgotUsernameTemplate.id);
        sem.setTargetObjectId(currentUser.id);
        sem.setSaveAsActivity(false);
        List<String> a = new List<String>();
        //change email below
        String emailAddress = SRW_Utils.getSettingByName('OrgWideEmailAddress');
        OrgWideEmailAddress[] owea = [select Id, Address from OrgWideEmailAddress where Address = :emailAddress LIMIT 1];
        sem.setOrgWideEmailAddressId(owea[0].id);
        a.add(owea[0].Address);
        sem.setCcAddresses(a);
        Messaging.SendEmailResult[] ser = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {sem});
    }
    
}