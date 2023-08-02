public without sharing class GNE_CM_MPS_Question_Settings_Ctrl {
    public String answercityofbirth { get; set; }
    public String answerdayofbirth { get; set; }
    public String answercityofjob { get; set; }
    public String msg { get; set; }
    public GNE_CM_MPS_User__c existingMpsUser { get; set; }
    public GNE_CM_IHCP_User__c existingIhcpUser { get; set; }
    
    private static final String ACTION = 'Questions';

    
    public GNE_CM_MPS_Question_Settings_Ctrl()
    {       
        msg = '';

        existingMpsUser = GNE_CM_IHCP_Utils.getMPSUser(Userinfo.getUserName());
        existingIhcpUser = GNE_CM_IHCP_Utils.getIHCPUser(Userinfo.getUserName());
        
        if(existingIhcpUser != null)
        {
            /*answercityofbirth = existingMpsUser.Security_Question_Answer_City_Of_Birth__c;
            answerdayofbirth = existingMpsUser.Security_Question_Answer_Day_Of_Birth__c;
            answercityofjob = existingMpsUser.Security_Question_Answer_City_Of_Job__c;
			*/
            answercityofbirth = existingIhcpUser.Security_Question_Answer_City_Of_Birth__c;
            answerdayofbirth = existingIhcpUser.Security_Question_Answer_Day_Of_Birth__c;
            answercityofjob = existingIhcpUser.Security_Question_Answer_City_Of_Job__c;
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
        msg = updateIHCPUserFuture(answercityofbirth, answerdayofbirth, answercityofjob);
        
        if (msg == '')
        {
        	if (existingMpsUser.Email_address__c == null || existingMpsUser.Email_address__c == '')
        	{
        		throw new GNE_CM_Exception('Confirmation could not be sent because the MPS user\'s email is empty');
        	}
        	
            // send confirmation email
            GNE_CM_MPS_Email_Utils.sendSettingsConfirmationEmail(existingMpsUser, ACTION);                                                            
            PageReference pageRef = new PageReference('/apex/GNE_CM_MPS_Confirmation_Settings?action=Questions&email=' + existingMpsUser.Email_address__c); 
            return pageRef;
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
    
    private void addError(String msg)
    {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, msg));
    }
}