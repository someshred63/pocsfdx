public without sharing class GNE_CM_IHCP_Profile_Settings_Ctlr {
    public Boolean debugOn { get; set; }
    public Boolean hasErrors { get { return (errorMessage!=''); } }
    public String debugMessage { get; set; }
    public String errorMessage { get; set; }
    public String accountID { get; set; }
    public String accountIndicator { get; set; }
    
    public String fname { get; set; }  
    public String lname { get; set; } 
    public String email { get; set; }
    public String phone { get; set; }
    public String ext   { get; set; }
    public String uname { get; set; }
    public GNE_LWO_User__c existingLwoUser { get; set; }
    public GNE_CM_IHCP_User__c existingIhcpUser { get; set; }
    
    public Boolean IsLWOUser { get { return (existingLwoUser!=null); } }

    private String oldName;
    public String oldpassword { get; set; }
    public String newpassword { get; set; }
    public String newpasswordconfirm { get; set; }
    public String portal { get; set; }
        
    public String answercityofbirth { get; set; }
    public String answerdayofbirth { get; set; }
    public String answercityofjob { get; set; }
            
    public GNE_CM_IHCP_Profile_Settings_Ctlr() {
        fname = Userinfo.getFirstName();
        lname = Userinfo.getLastName();
        uname = Userinfo.getUserName();
        portal = ApexPages.currentPage().getParameters().get('portal');
    
        oldName = uname;
        errorMessage = '';
        
        existingLwoUser = GNE_CM_IHCP_Utils.getLWOUserForProfileSettings(Userinfo.getUserName());
        existingIhcpUser = GNE_CM_IHCP_Utils.getIHCPUser(Userinfo.getUserName());
        if(existingLwoUser != null)
        { 
            email = existingLwoUser.Email__c;
            phone = existingLwoUser.SFDC_User__r.Phone;
            ext = existingLwoUser.SFDC_User__r.Extension;
        } else {
            errorMessage += 'LWO user not found: ' + Userinfo.getUserName() + '. \n';
        }
        
        if(existingIhcpUser != null)
        {
            answercityofbirth = existingIhcpUser.Security_Question_Answer_City_Of_Birth__c;
            answerdayofbirth = existingIhcpUser.Security_Question_Answer_Day_Of_Birth__c;
            answercityofjob = existingIhcpUser.Security_Question_Answer_City_Of_Job__c;
        }  else {
            errorMessage += 'IHCP user not found: ' + Userinfo.getUserName() + '. \n';
        }    
        PageReference pageRef = System.currentPageReference(); 
        this.accountID = pageRef.getParameters().get('accountId');
        this.accountIndicator = pageRef.getParameters().get('accountIndicator');
        
    }

    public PageReference save() {
        Id currentUserId = UserInfo.getUserId();
        List<User> users = [Select FirstName, LastName, Email, Username, Extension from User 
                                             where ID = :currentUserId];
        
        // save changes
        User currentUser = users.get(0);
        currentUser.FirstName = fname;
        currentUser.LastName = lname;
        currentUser.Phone = phone;
        currentUser.Extension = ext; 
                    
        update currentUser;
        
        // sent email 2 user
        GNE_CM_IHCP_Email_Utility emailUtil=new GNE_CM_IHCP_Email_Utility(portal);
        emailUtil.sendResetProfileConfirmationEmail(existingLwoUser.SFDC_User__r.ContactId, existingLwoUser.Id);           
        
        // show message
        return redirectToMessage('Setting');
    }   
    
    public PageReference savePassword()
    {
        Id currentUserId = UserInfo.getUserId();   
        errorMessage = '';
        
        // validate and save changes
        if(String.valueof(newpassword) != '')
        {
            String startUrl = '/GNE_LWO_Profile_settings';
            if(Site.login(UserInfo.getUserName(), String.valueof(oldpassword), startUrl) == null)
            {
                errorMessage = 'Your Old Password is incorrect.  Please try again.';
                return null;              
            } else {
                try
                {
                    System.setPassword(currentUserId, String.valueof(newpassword));
                }   catch (Exception e) {   
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Error: ' + GlobalUtils.getExceptionDescription(e)));
                    Error_Log_gne__c err = GNE_CM_MPS_Utils.createError('GNE_CM_MPS_Password_Settings_Ctrl', 'High', 'save', 'Apex Class', e);
                    insert err;   
                }
            }
        }
                      
        if(errorMessage == '')     
        {
            //timestamp the LWO suer
            existingLwoUser.Last_Password_Modified_Date__c = System.now();
            update existingLwoUser;    

            // send Confirmation email
            GNE_CM_IHCP_Email_Utility emailUtil=new GNE_CM_IHCP_Email_Utility(portal);
            emailUtil.sendResetPasswordConfirmationEmail(existingLwoUser.SFDC_User__r.ContactId, existingLwoUser.Id);           

            // show message
            return redirectToMessage('Password');
        }                                             
        return null;
    }
    
    
    public PageReference saveQuestions()
    {
        // save changes
        errorMessage = updateIHCPUserFuture(answercityofbirth, answerdayofbirth, answercityofjob);
        
        if (errorMessage == '')
        {
            // send confirmation email
            //Confirmation email
            GNE_CM_IHCP_Email_Utility emailUtil=new GNE_CM_IHCP_Email_Utility(portal);
            emailUtil.sendResetQuestionConfirmationEmail(existingLwoUser.SFDC_User__r.ContactId, existingLwoUser.Id);           
            
            // show message
            return redirectToMessage('Question');
        }
        return null;
    }

    
    private static String updateIHCPUserFuture(String answercityofbirth, String answerdayofbirth, String answercityofjob)
    {
        String msg = '';
        GNE_CM_IHCP_User__c existingIhcpUser = GNE_CM_IHCP_Utils.getIHCPUser(Userinfo.getUserName());
        
        if(existingIhcpUser == null)
            return 'ERROR: ihcp user not found';
         
        existingIhcpUser.Security_Question_Answer_City_Of_Birth__c = String.valueof(answercityofbirth);
        existingIhcpUser.Security_Question_Answer_Day_Of_Birth__c = String.valueof(answerdayofbirth);
        existingIhcpUser.Security_Question_Answer_City_Of_Job__c = String.valueof(answercityofjob);
        
        try 
        {
            update existingIhcpUser;
            
        } catch (DmlException e) {
            //wilczekk: here we should log exception to error log
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Error: ' + GlobalUtils.getExceptionDescription(e)));
            Error_Log_gne__c err = GNE_CM_MPS_Utils.createError('GNE_CM_MPS_Question_Settings_Ctrl', 'High', 'save', 'Apex Class', e);
            insert err;       
        }    
        return msg;    
    }   
    
    public PageReference cancel() {
        errorMessage = '';
        return Page.GNE_LWO_Profile_Settings;
    }  
    
    private PageReference redirectToMessage(String action) {
        PageReference pageRef = Page.GNE_LWO_Message;
        pageRef.getParameters().put('action', action);
        pageRef.getParameters().put('email', email);
        pageRef.getParameters().put('accountId', accountId);
        pageRef.getParameters().put('accountIndicator', accountIndicator);        
        return pageRef;
    } 
}