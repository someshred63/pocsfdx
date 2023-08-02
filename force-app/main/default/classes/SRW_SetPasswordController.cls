public without sharing class SRW_SetPasswordController {
    public String newPassword{set; get;}
    public String confirmPassword{set; get;}
    public String username {get; set;}
    public Id userId {get; set;}
    public SRW_Security_Community_Data__c secData {get; set;}
    
    public boolean passwordIsValid(){
        return (newPassword.equals(confirmPassword) || newPassword.toLowerCase().contains(username.substring(0, username.indexOf('@')).toLowerCase()));
    }
    public boolean passwordLength(){
        return (newPassword.length() > 7);
    }
    public boolean passwordChars(){
        return ((newPassword.containsAny('1234567890')) && (newPassword.containsAny('qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM')) && (newPassword.containsAny('QWERTYUIOPASDFGHJKLZXCVBNM')));
    }
    
    public PageReference changePassword(){
        if(passwordIsValid()){
            if(passwordLength()){
                if(passwordChars()){
                    try{
                        PageReference pr;
                        if(secData.First_Login_gne__c && !Site.isPasswordExpired()){
                            updateSecData(secData.Id);
                            ResetPasswordResult rpr = System.resetPassword(userId, false);
                            system.debug('reset password: ' + rpr);
                            changePassword(userId, newPassword);
                            
                        } else{
                            system.debug('--- change passwd');
                            pr = Site.changePassword(newPassword, confirmPassword);
                            system.debug('--- 1 after change passwd (if null => error): ' + pr);
                            if(pr == null) {
                                return null;
                            }
                        }
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.SRW_Password_changed));
                        return new PageReference(Page.SRW_SetSecurityQA.getURL());
                        //return null;
                    }catch(Exception e){
                        System.debug('Change password error: ' + e.getMessage());
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
    
    @future
    public static void updateSecData(Id secDataId){
        SRW_Security_Community_Data__c secData = [SELECT id, First_Login_gne__c FROM SRW_Security_Community_Data__c WHERE id =:secDataId];
        secData.First_Login_gne__c = false;
        update secData;
    }

    public static void changePassword(Id userId, String password){
        system.debug('in set password');
        System.setPassword(userId, password);
        system.debug('after set password');
    }

    public SRW_SetPasswordController(){
        username = UserInfo.getUserName();
        User u = [SELECT id, contactId, username FROM User WHERE username = :username];
        userId = u.id;

        List<SRW_Security_Community_Data__c> temp = [SELECT id, First_Login_gne__c FROM SRW_Security_Community_Data__c WHERE Trading_Partner_gne__r.Contact_gne__c = :u.contactId LIMIT 1];
        secData = !temp.isEmpty() ? temp[0] : new SRW_Security_Community_Data__c();
    }
}