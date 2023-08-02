public with sharing class PRP_AuthenticationController {
    public String email {get; set;}
    public String passcode {get; set;}
    public String captchaSiteKey {get; set;}
    public String captchaResponse {get; set;}
    public Boolean isCaptchaVerified {get; set;}
    public Boolean isAuthenticated {get; set;}

    public PRP_AuthenticationController() {
        isAuthenticated = false;
    }

    public void validateUser(){
        isAuthenticated = true;
        System.debug('email***'+email);
        System.debug('passcode***'+passcode);
    }
}