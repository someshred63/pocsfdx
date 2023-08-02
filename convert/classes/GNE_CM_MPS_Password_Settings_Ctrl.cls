public without sharing class GNE_CM_MPS_Password_Settings_Ctrl {
    public String oldpassword { get; set; }
    public String newpassword { get; set; }
    public String newpasswordconfirm { get; set; }
    public String msg { get; set; }
    public GNE_CM_MPS_User__c existingMpsUser { get; set; }
        
    private static final String ACTION = 'Password';

    
    public GNE_CM_MPS_Password_Settings_Ctrl()
    {
    	try
    	{      
	        msg = '';
	        existingMpsUser = GNE_CM_IHCP_Utils.getMPSUser(Userinfo.getUserName());
	        if(existingMpsUser == null)
	            msg = 'MPS user not found: ' + Userinfo.getUserName() + '. <br/>';
    	}
    	catch(Exception ex)
    	{
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Error: ' + GlobalUtils.getExceptionDescription(ex)));
    	}
    }
    
    public PageReference showAccountForm()
    {   
        return null;
    }
    public PageReference cancel()
    {
        PageReference pageRef = new PageReference('/apex/GNE_CM_MPS_Profile_Settings');
        return pageRef;
    }
    public PageReference save()
    {
        Id currentUserId = UserInfo.getUserId();   
        msg = '';
        if(newpassword != '')
        {
            String startUrl = '/GNE_CM_MPS_Profile_settings';
            if(Site.login(UserInfo.getUserName(), oldpassword, startUrl) == null)
            {
                msg = 'Your Old Password is incorrect.  Please try again.';
                //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,msg);
				//ApexPages.addMessage(myMsg);
				return null;              
            } else {
                try
                {
                    System.setPassword(currentUserId, newpassword);
                    existingMpsUser.Last_Password_Modified_Date__c = System.now();  
            		update existingMpsUser;
                }   catch (Exception e) {   
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Error: ' + GlobalUtils.getExceptionDescription(e)));
	        		Error_Log_gne__c err = GNE_CM_MPS_Utils.createError('GNE_CM_MPS_Password_Settings_Ctrl', 'High', 'save', 'Apex Class', e);
	        		insert err;   
                }
            }
        }
                      
        if(msg == '')     
        {
            //Confirmation email
            GNE_CM_MPS_Email_Utils.sendSettingsConfirmationEmail(existingMpsUser, ACTION);
            PageReference pageRef = new PageReference('/apex/GNE_CM_MPS_Confirmation_Settings?action=Password&email=' + existingMpsUser.Email_address__c);        
            return pageRef;
        }                                             
        return null;
    }
}