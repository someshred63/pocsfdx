public without sharing class GNE_CM_IHCP_ResetPassword_Controller {
   
    public String userId { get; set; }
    public String hash { get; set; }
    public Integer step { get; set; }
    
    public String cityOfBirth { get; set; }
    public String dayOfBirth { get; set; }
    public String cityOfFirstJob { get; set; }
    public String newPassword { get; set; }
    public String confirmPassword { get; set; }

    // url holders which will be set based on portal
    public String lockedPage { get; set; }
    public String invalidPage { get; set; }
    public String confirmPage { get; set; }
    public String cancelPage { get; set; }
    
    public String errorMessage { get; private set; }
    public Boolean isErrorDisplayed { get; private set; }
    
    private Boolean isInvalid;
    private Boolean isLocked;
    private Integer goodAnswers;
    private Integer failCounter;
    
    public String portal { get; set; }
    public String debug { get; set; }

    //
    public IHCPUserObject existingUser { get; set; }
    
    // used by GNE_LWO_ResetPassword.page
    public String getlwoUserName(){
    	if(existingUser.lwoUser.SFDC_User__r.UserName!=null)
    	return existingUser.lwoUser.SFDC_User__r.UserName;
    	else return '';
    }
    
    // local class to manage the various portal objects
    public class IHCPUserObject
    {
        public GNE_CM_IHCP_User__c ihcpUser { get; set; }
        public GNE_CM_MPS_User__c mpsUser { get; set; }
        public GNE_LWO_User__c lwoUser { get; set; }
        
        
        public DateTime Last_Password_Modified_Date {
            get { 
                if (lwoUser!=null) {
                    return lwoUser.Last_Password_Modified_Date__c;
                } else if (mpsUser!=null) {
                    return mpsUser.Last_Password_Modified_Date__c;
                } else {
                    return null;
                }
            }
        }
            
        public DateTime Reset_Password_Email_Sent_Date { 
            get {
                if (lwoUser!=null) {
                    return lwoUser.Reset_Password_Email_Sent_Date__c;
                } else if (mpsUser!=null) {
                    return mpsUser.Reset_Password_Email_Sent_Date__c;
                } else {
                    return null;
                }
            }
        }
        
        public Boolean Is_Locked  {            
            get {
                if (ihcpUser!=null) {
                    return ihcpUser.IsLocked__c;
                } 
                else {
                    return null;
                }
            }
        }
    }       
    
    
    public GNE_CM_IHCP_ResetPassword_Controller() {
        try
        {
            isErrorDisplayed = false;
            errorMessage = '';
            isInvalid = false;
            isLocked = false;
            failCounter = 0;
            step = 1;

            portal=ApexPages.currentPage().getParameters().get('portal');

            // portal specific setup
            if (portal=='LWO') {
                lockedPage='/apex/GNE_LWO_ResetPasswordMessage?action=locked&portal=LWO';
                invalidPage='/apex/GNE_LWO_ResetPasswordMessage?action=invalid&portal=LWO';
                confirmPage='/apex/GNE_LWO_Activation_Messages?action=PasswordReset';
                cancelPage='/apex/GNE_LWO_Login_Panel';
            } else if (portal=='MPS') {
                lockedPage='/apex/GNE_CM_MPS_ResetPasswordMessage?action=locked&portal=MPS';
                invalidPage='/apex/GNE_CM_MPS_ResetPasswordMessage?action=invalid&portal=MPS';
                confirmPage='/apex/GNE_CM_MPS_ResetPasswordConfirmation';
                cancelPage='/apex/GNE_CM_MPS_Login';
            }
            debug=portal + '\n';
            
            userId = System.currentPageReference().getParameters().get('userId');
            hash = System.currentPageReference().getParameters().get('hash');
                    
            existingUser = getCurrentUser();
            if (existingUser == null)
            {
                isInvalid = true;
            }
            else
            {
                if (existingUser.Is_Locked != null && existingUser.Is_Locked)
                {
                    isLocked = true;
                }
                // TODO: Make this work configurable per portal
                if (!GNE_CM_IHCP_Utils.isResetPasswordEmailValid(existingUser.Last_Password_Modified_Date, existingUser.Reset_Password_Email_Sent_Date))
                {
                    //errorMessage = 'Email is not valid';
                    //isErrorDisplayed = true;
                    isInvalid = true;
                }
            }
        }
        catch (Exception e)
        {           
            errorMessage = 'Error: ' + GlobalUtils.getExceptionDescription(e);
            isErrorDisplayed = true;        
        }
    }
    
    // redirect on error condition
    public Pagereference showResetPasswordForm()
    {
        if (isLocked)
        {
            PageReference pageRef = new PageReference(lockedPage);
            return pageRef;
        }
        if (isInvalid)
        {
            PageReference pageRef = new PageReference(invalidPage);
            return pageRef;
        }
        return null;
    }
    
    private IHCPUserObject getCurrentUser()
    {
        IHCPUserObject retObj=new IHCPUserObject();
        
        User sfdcUser=null;
        if (portal=='LWO') {
            List<GNE_LWO_User__c> users = 
                [select Id, 
                    SFDC_User__r.username, 
                    SFDC_User__r.id, 
                    SFDC_User__r.ContactId, 
                    Last_Password_Modified_Date__c, 
                    Reset_Password_Email_Sent_Date__c
                from GNE_LWO_User__c 
                where Id = :userId and Activation_Hash_Number__c = :hash];
                
            if (users.size()>0) {
                sfdcUser=users[0].SFDC_User__r; 
                retObj.lwoUser=users[0];
            }               
            
        } else if (portal=='MPS') {
            List<GNE_CM_MPS_User__c> users = 
                [select Id, 
                    SFDC_User__r.username, 
                    SFDC_User__r.id,
                    SFDC_User__r.ContactId, 
                    Last_Password_Modified_Date__c, 
                    Reset_Password_Email_Sent_Date__c,
                    Email_address__c 
                    from GNE_CM_MPS_User__c 
                where Id = :userId and Activation_Hash_Number__c = :hash];
                
            if (users.size()>0) {
                sfdcUser=users[0].SFDC_User__r; 
                retObj.mpsUser=users[0];
            }               
            
        }
        
        if (sfdcUser == null)
        {
            return null;            
        }
        else
        {
            List<GNE_CM_IHCP_User__c> users=[select Id, 
                    IsLocked__c,
                    Login_Failed__c,
                    Locked_Date_Time__c,
                  SFDC_User__r.username, 
                  SFDC_User__r.id,
                  SFDC_User__r.ContactId, 
                  Security_Question_Answer_City_Of_Birth__c, 
                  Security_Question_Answer_Day_Of_Birth__c, 
                  Security_Question_Answer_City_Of_Job__c
                from GNE_CM_IHCP_User__c 
                where SFDC_User__c=:sfdcUser.Id];
            retObj.ihcpUser=users[0];
            return retObj;
        }
    }
    
    public Pagereference submitStep1()
    {
        isErrorDisplayed = true;
        errorMessage = '';
        
        try
        {
            goodAnswers = 0;
            
            if (cityOfBirth == existingUser.ihcpUser.Security_Question_Answer_City_Of_Birth__c)
            {
                goodAnswers += 1;
            } 
            if (dayOfBirth == existingUser.ihcpUser.Security_Question_Answer_Day_Of_Birth__c)
            {
                goodAnswers += 1;
            }
            if (cityOfFirstJob == existingUser.ihcpUser.Security_Question_Answer_City_Of_Job__c)
            {
                goodAnswers += 1;
            }
            
            if (goodAnswers < 2)
            {
                errorMessage= 'One or more answers you provided are not correct.  Please try again.';
                failCounter += 1;
                
                if (failCounter >= 3)
                {
                    if (existingUser.ihcpUser != null)
                    {
                        GNE_CM_IHCP_Utils.lockIHCPUserAtFuture(existingUser.ihcpUser.Id, true);
                    }                     
                    PageReference pageRef = new PageReference(lockedPage);
                    return pageRef;
                }
                return null;
            }
            
            isErrorDisplayed = false;
            failCounter = 0;
            step = 2;
            return null;            
        }
        catch (Exception ex)
        {
            String sourceClass = 'GNE_CM_IHCP_ResetPassword_Controller';
            String sourceMethod = 'submitStep1';
            Error_Log_gne__c error = GNE_CM_IHCP_Utils.createError(sourceClass, 'High', sourceMethod, 'Apex Code', 'Unhandled exception has ocurred: ' + GlobalUtils.getExceptionDescription(ex));
            insert error;
            errorMessage = 'Error: ' + GlobalUtils.getExceptionDescription(ex);
            return null;
        }
    }
    
    
    public Pagereference submitStep2()
    {
        isErrorDisplayed = true;
        
        try
        {
            if (newPassword == null || newPassword == '' ||
                    confirmPassword == null || confirmPassword == '')
            {
                errorMessage = 'Please enter new password and confirm password';
                return null;
            }
            else if (newPassword != confirmPassword)
            {
                errorMessage = 'Password and confirm password must be the same';
                return null;
            }       
            
            //change password
            GNE_CM_IHCP_Email_Utility emailUtil=new GNE_CM_IHCP_Email_Utility(portal);
            
            if (existingUser.lwoUser!=null) {
                existingUser.lwoUser.Last_Password_Modified_Date__c = System.now();
                update existingUser.lwoUser;    
                emailUtil.sendResetPasswordConfirmationEmail(existingUser.ihcpUser.SFDC_User__r.ContactId, 
                                            existingUser.lwoUser.Id);
            } else if (existingUser.mpsUser!=null) {
                existingUser.mpsUser.Last_Password_Modified_Date__c = System.now();
                update existingUser.mpsUser;    
                emailUtil.sendResetPasswordConfirmationEmail(existingUser.ihcpUser.SFDC_User__r.ContactId, 
                                            existingUser.mpsUser.Id);
                confirmPage = '/apex/GNE_CM_MPS_Activation_Messages?action=resetPasswordSuccessfull&email='+existingUser.mpsUser.Email_address__c;
            }               
            System.setPassword(existingUser.ihcpUser.SFDC_User__r.id, newPassword);

            isErrorDisplayed = false;     
               
            return new PageReference(confirmPage);
        }  
        catch (Exception ex)
        {
            String sourceClass = 'GNE_CM_IHCP_ResetPassword_Controller';
            String sourceMethod = 'submitStep2';
            Error_Log_gne__c error = GNE_CM_IHCP_Utils.createError(sourceClass, 'High', sourceMethod, 'Apex Code', 'Unhandled exception has ocurred: ' + GlobalUtils.getExceptionDescription(ex));
            insert error;
            errorMessage = 'Error: ' + GlobalUtils.getExceptionDescription(ex);
            return null;
        }       
    }
    
    public PageReference cancel()
    {
        PageReference pageRef = new PageReference(cancelPage);
        return pageRef;
    }
    
    private GNE_CM_MPS_User__c getCurrentMPSUser()
    {
        List<GNE_CM_MPS_User__c> users = 
            [select Id, SFDC_User__r.username, SFDC_User__r.id, Email_Address__c,          
            Last_Password_Modified_Date__c, Reset_Password_Email_Sent_Date__c, SFDC_User__c 
            from GNE_CM_MPS_User__c 
             where Id = :userId and Activation_Hash_Number__c = :hash];
        
        if (users == null || users.size() == 0)
        {
            return null;            
        }
        else
        {
            return users[0];
        }
    }
    
 }