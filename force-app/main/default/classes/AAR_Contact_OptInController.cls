/**
 * @author Venky Kambham
 * @date 2/9/2021
 * @description Handles ARM Contact email opt-in process.
 */
public without sharing class AAR_Contact_OptInController {
    
    //public String firstName {get; set;}
    //public String lastName {get; set;}
    /*VK 3/16/21, Commenting as requirements changed
    public String email {get; set;}
    public Boolean subscribed {get; set;}
    public Boolean hasValidAuthCode {get; set;}
    public Boolean showMessage {get; set;}
    public String msgType {get; set;}
    public Boolean success {get; set;}
    public Boolean error {get; set;}
    public String captchaPublicSecret {get; set;}
    public Boolean isCaptchaVerified {get; set;}
    public String captchaResponse {get; set;}
    
    C_Ops_Captcha_Property__c captchaProp;
    String authorizationCode;

    public AAR_Contact_OptInController(){
        msgType = 'error';
        authorizationCode = ApexPages.currentPage().getParameters().get('code');
        if(String.isBlank(authorizationCode)){
            hasValidAuthCode = false;
            handleMessage('error','This URL is no longer valid, request for new.');
            return;
        }
        List<Contact> contacts = [SELECT Id,Opt_In_Authorization_Code__c,Opt_In_Code_Expiration_Date__c 
                                  FROM Contact WHERE Opt_In_Authorization_Code__c = :authorizationCode LIMIT 1];

        if(!contacts.isEmpty() && contacts[0].Opt_In_Code_Expiration_Date__c >= System.now()){
            hasValidAuthCode = true;
        }else{
            hasValidAuthCode = false;
            handleMessage('error','This URL is no longer valid, request for new.');
            return;
        }
        
        List<C_Ops_Captcha_Property__c> props = [SELECT ID,GSiteKey__c,GSecurityKey__c,GSite__c,Active__c 
                                                 FROM C_Ops_Captcha_Property__c WHERE Active__c = true LIMIT 1];        
        if(!props.isEmpty()){
            captchaProp = props[0];
            captchaPublicSecret = props[0].GSiteKey__c;
        }
    }
    public void handleMessage(String type, String msg){
        showMessage = true;
        msgType = type;
        ApexPages.Message message;

        if(msgType == 'success') message = new ApexPages.Message(ApexPages.Severity.CONFIRM,msg);
        if(msgType == 'error') message = new ApexPages.Message(ApexPages.Severity.ERROR,msg);
        if(msgType == 'info') message = new ApexPages.Message(ApexPages.Severity.INFO,msg);
        ApexPages.addMessage(message);
    }

    @testVisible 
    private Boolean verifyCaptcha(){
        if(isCaptchaVerified) return isCaptchaVerified;
        
        if(String.isBlank(captchaResponse)){
            handleMessage('error','Please acknowledge the reCAPTCHA by checking the I\'m not a robot checkbox');
            return isCaptchaVerified;
        }

        String body = 'secret=' + captchaProp.GSecurityKey__c + '&response=' + captchaResponse;

        HttpRequest req = new HttpRequest();  
        req.setEndpoint(captchaProp.GSite__c);
        req.setMethod('POST');
        req.setBody(body);
        try{
            Http http = new Http();
            HttpResponse response = http.send(req);

            if(String.isNotBlank(response.getBody())){
                JSONParser parser = JSON.createParser(response.getBody());
            
                if(response.getBody().containsIgnoreCase('timeout-or-duplicate'))
                    isCaptchaVerified = true;

                while(parser.nextToken() != null){                    
                    if((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'success')) {              
                        parser.nextToken();
                        if(parser.getText() == 'true') isCaptchaVerified = true;
                    }
                }
            }else{
                handleMessage('error','Please acknowledge the reCAPTCHA by checking the I\'m not a robot checkbox');
            }
        }
        catch(Exception e){
            System.debug('Error*** '+e.getMessage()+' @ '+e.getStackTraceString());
            isCaptchaVerified = false;
        }
        return isCaptchaVerified;
    }

    /**
     * @author Venky Kambham
     * @date 2/9/2021
     * @description Handles ARM Contact email subscription. Called from AAR_Contact_OptInPage.
     *
    public PageReference subscribe(){
        error = false;
        success = false;
        if(!verifyCaptcha()) return null;

        if(subscribed && String.isNotBlank(email)){
            List<Contact> contacts = [SELECT Id,Name,Email,HasOptedOutOfEmail,Opt_In_Date__c,Opt_In_Code_Expiration_Date__c 
                                      FROM Contact WHERE Email = :email AND Opt_In_Authorization_Code__c = :authorizationCode LIMIT 1];
            if(contacts.isEmpty()){
                subscribed = false;
                handleMessage('error','No entry found with the given details.');
                return null;
            }else if(contacts[0].Opt_In_Code_Expiration_Date__c < System.now()){
                hasValidAuthCode = false;
                handleMessage('error','This URL is no longer valid, request for new.');
                return null;
            }
            else if(!contacts[0].HasOptedOutOfEmail){
                handleMessage('info','You have already subscribed.');
                return null;
            }
            else{
                contacts[0].HasOptedOutOfEmail = false;
                contacts[0].Opt_In_Date__c = System.now();
                contacts[0].Opt_In_Authorization_Code__c = '';
                contacts[0].Opt_In_Code_Expiration_Date__c = null;
                
                update contacts;
                handleMessage('success','You have successfully subscribed.');
            }
        }
        return null;
    }

    //Generate random string by character length
    public static String getRandomString(Integer len){
        Blob blobKey = Crypto.generateAesKey(128);
        String key = EncodingUtil.convertToHex(blobKey);
        String randomStr = key.substring(0,len);

        return randomStr;
    }
    */

    /**
     * @author Venky Kambham
     * @date 2/9/2021
     * @description Checks whether contact has already Opted-in or not. Called from AAR_Contact_OptInAction.cmp.
     */    
    @AuraEnabled
    public static String hasAlreadySubscribed(String contactId){
        try{
            Map<Id,Profile> authorizedProfiles = new Map<Id,Profile>([SELECT Id,Name FROM Profile WHERE Name IN ('System Administrator','AAR-User','GNE-SYS-Support')]);
            if(!authorizedProfiles.containsKey(UserInfo.getProfileId())) return 'You do not have access to perform this operation.';
            
            List<Contact> contacts = [SELECT Id,Name,Email,HasOptedOutOfEmail FROM Contact WHERE Id = :contactId LIMIT 1];
        
            if(contacts.isEmpty()) return 'No contact found.';
            else if(!contacts[0].HasOptedOutOfEmail) return 'Yes';
            else return '';            
        }
        catch(Exception e){
            System.debug('Error*** '+e.getMessage()+' @ '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
     * @author Venky Kambham
     * @date 2/9/2021
     * @description Sends an Opt-in email to the ARM Contact. Called from AAR_Contact_OptInAction.cmp.
     */
    @AuraEnabled
    public static String processOptIn(String contactId){
        try{
            List<Contact> contacts = [SELECT Id,HasOptedOutOfEmail FROM Contact WHERE Id = :contactId LIMIT 1];
            if(contacts.isEmpty()) return 'No contact found.';

            Contact cont = contacts[0];
            cont.HasOptedOutOfEmail = false;
            update cont;

            /*if(cont.Opt_In_Code_Expiration_Date__c <= System.now()){
                cont.Opt_In_Authorization_Code__c = getRandomString(10);
                cont.Opt_In_Code_Expiration_Date__c = System.now() + 1; //1 day from now
                update cont;
            }
            List<EmailTemplate> templates = [SELECT Id,DeveloperName FROM EmailTemplate WHERE DeveloperName = 'ARM_Opt_In_Template' LIMIT 1];
            if(templates.isEmpty()) return 'ARM Opt-In template is not available.';
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(templates[0].Id);
            mail.setTargetObjectId(contactId);
            
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
            */
            
            return 'Success';
        }
        catch(Exception e){
            System.debug('Error*** '+e.getMessage()+' @ '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}