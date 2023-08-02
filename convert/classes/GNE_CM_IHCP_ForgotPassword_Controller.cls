public without sharing class GNE_CM_IHCP_ForgotPassword_Controller {
    public String username { get; set; }
    public String email { get; set; }
    public String errorMessage { get; private set; }
    public String actionMessage { get; private set; }
    public Boolean isErrorDisplayed { get; private set; }    
    public String contactId { get; set; }
    public String portalUserId { get; set; }
    public String portal { get; set; }
    public String debug { get; set; }
    
    private PageReference emailSentPage;
    private PageReference cancelPage;
    
    public GNE_CM_IHCP_ForgotPassword_Controller()
    {
        isErrorDisplayed = false;
        portal=ApexPages.currentPage().getParameters().get('portal');
        
        if (portal=='LWO') {
            emailSentPage = Page.GNE_LWO_ResetPasswordEmailSent;
            cancelPage = GNE_CM_IHCP_Utils.getLWOHomePage();    
        } else if (portal=='MPS') {
            emailSentPage = Page.GNE_CM_MPS_ResetPasswordEmailSent;
            cancelPage = Page.GNE_CM_MPS_Login;
        }
        /*
        if (ApexPages.currentPage().getUrl().indexOf('GNE_LWO') > -1) {
            portal = 'LWO_Configuration';
            
        } else {
            portal = 'MPS_Configuration';   
        }
        */
        debug=portal + '\n';
    }    
    
    public PageReference forgotPassword()
    {
        Boolean userHasMultiPortalAccess; 
        try
        {       
            contactId=null;
            portalUserId=null;
            
            // Query the right user object based on portal
            if (portal == 'LWO') {
            debug+='LWO_Configuration\n' + email +'\n';
                List<GNE_LWO_User__c> userList = [select id, SFDC_User__c, SFDC_User__r.ContactId, SFDC_User__r.username, Reset_Password_Email_Sent_Date__c, Activation_Hash_Number__c, Activation_Server__c from GNE_LWO_User__c where SFDC_User__r.Contact.Email = :email];
                
            debug+=('userList >>>>' + userList);
                if (userList.size()>0) {
                    //PK 10/23/2013 
                    Id userId = userList[0].SFDC_User__c;
                    userHasMultiPortalAccess = checkMultiPortalAccess(userId,'LWO');
                    System.debug('----------userHasMultiPortalAccess ---'+userHasMultiPortalAccess );                    
                    // save the ids
                    contactId=userList[0].SFDC_User__r.ContactId; 
                    portalUserId=userList[0].Id;

                    // set the hash for later and save
                    userList[0].Activation_Server__c=GNE_CM_IHCP_Utils.getPortalServer();
                    userList[0].Activation_Hash_Number__c=GNE_CM_IHCP_Email_Utility.generateActivationHash(100);
                    userList[0].Reset_Password_Email_Sent_Date__c=System.now();
                    update userList[0];
                }
            } else if (portal=='MPS'){
                List<GNE_CM_MPS_User__c> userList = [select id, SFDC_User__c, SFDC_User__r.ContactId, SFDC_User__r.username, Reset_Password_Email_Sent_Date__c, Activation_Hash_Number__c, Activation_Server__c from GNE_CM_MPS_User__c where SFDC_User__r.Contact.Email = :email];
                
                if (userList.size()>0) { 
                    //PK 10/23/2013 
                    Id userId = userList[0].SFDC_User__c;
                    userHasMultiPortalAccess = checkMultiPortalAccess(userId,'MPS');
                    System.debug('----------userHasMultiPortalAccess ---'+userHasMultiPortalAccess );
                    contactId=userList[0].SFDC_User__r.ContactId; 
                    portalUserId=userList[0].Id;

                    // set the hash for later and save
                    userList[0].Activation_Server__c=GNE_CM_IHCP_Utils.getPortalServer();
                    userList[0].Activation_Hash_Number__c=GNE_CM_IHCP_Email_Utility.generateActivationHash(100);
                    userList[0].Reset_Password_Email_Sent_Date__c=System.now();
                    update userList[0];
                }
            }
            
            if (contactId == null || portalUserId == null)
            {
                if (portal=='MPS') {
                    errorMessage = 'A My Patient Solutions account with an email address of ' + email + ' does not exist.  Please try again.';
                } else if (portal=='LWO') {
                    errorMessage = 'A Lucentis Direct account with an email address of ' + email + ' does not exist.  Please try again.'; 
                }
                isErrorDisplayed = true;            
                return null;
            }
            //blocking unconverted users                
            if(GNE_CM_IHCP_Utils.isUserUnconverted(email, portal))
            {
                if(portal == 'MPS') 
                {
                    errorMessage = 'We have recently changed our password policy. As a result, all users of My Patient Solutions will need to create a new password. <br/> Please contact Genentech Access Solutions at (866) 4ACCESS/(866) 422 2377, 6am-5pm PST, Monday through Friday for assistance.';
                }
                else if (portal == 'LWO')
                {
                    errorMessage = 'We have recently changed our password policy. As a result, all users of Lucentis Direct Web Ordering will need to create a new password. <br/> Please contact a Lucentis Direct Customer Specialist at (800) 963-1778, 9am - 8pm ET, Monday through Friday.';
                }
                isErrorDisplayed = false;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, errorMessage);
                ApexPages.addMessage(myMsg);            
                return null;
            }
                        
            GNE_CM_IHCP_Email_Utility emUtil=new GNE_CM_IHCP_Email_Utility(portal);
            
            emUtil.sendResetPasswordEmail(contactId, portalUserId,userHasMultiPortalAccess );//PK 10/23/2013     
            
            isErrorDisplayed = false;
            emailSentPage.getParameters().put('email', email);
            return emailSentPage;
        }
        catch(Exception ex)
        {
            errorMessage = 'Error: ' + GlobalUtils.getExceptionDescription(ex);
            isErrorDisplayed = true;            
            return null;
        }
    }
    
    //added 10/23/2013 by Prashanth Kambalapally
     public Boolean checkMultiPortalAccess(String userId, String portal){
        Boolean userHasMultiPortalAccess = false;
        List<GNE_CM_IHCP_User__c> sunshineUsers = [SELECT SFDC_User__c FROM GNE_CM_IHCP_User__c WHERE SFDC_User__c =:userId];
        if(!sunshineUsers.isEmpty()){
            userHasMultiPortalAccess = true;
            return userHasMultiPortalAccess;
        }
        if(portal == 'MPS'){
            List<GNE_LWO_User__c> lwoUsers =  [SELECT Id, SFDC_User__c, SFDC_User__r.ContactId FROM GNE_LWO_User__c WHERE SFDC_User__c =:userId];
            if(!lwoUsers.isEmpty()){
                userHasMultiPortalAccess = true;
            }
        }else if(portal == 'LWO'){
            List<GNE_CM_MPS_User__c> mpsUsers = [SELECT SFDC_User__c FROM GNE_CM_MPS_User__c WHERE SFDC_User__c =:userId];
            if(!mpsUsers.isEmpty()){
                userHasMultiPortalAccess = true;
            }
        }
        return userHasMultiPortalAccess;
    }//end checkMultiPortalAccess()
    public PageReference cancel()
    {
        return cancelPage;
    }

}