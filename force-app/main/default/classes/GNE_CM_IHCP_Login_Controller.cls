public virtual without sharing class GNE_CM_IHCP_Login_Controller
{
    public String username { get; set; }
    public String password { get; set; }
    public String portal { get; set; }        
    public GNE_CM_IHCP_User__c ihcpUser { get; set; }
    
    private static final String LOCKOUT_MESSAGE = 'You have exceeded login attempts and your account has been disabled for security reasons. Please call Genentech Access Solutions at (866) 4 ACCESS/(866) 422-2377 for assistance.';
    
    public virtual PageReference login()
    {
        String startUrl = System.currentPageReference().getParameters().get('startURL');        
        
        if (portal == 'MPS')
        {
            GNE_CM_IHCP_User__c existingIhcpUser = GNE_CM_IHCP_Utils.getIHCPUser(username);
            
            if (existingIhcpUser == null)
            {                
                return null;
            }
            /*
            if (existingIhcpUser.Security_Question_Answer__c != ihcpUser.Security_Question_Answer__c)
            {
                errorMessages.add('Incorrect answer to the security question');
                return null;
            }
            */
        }
        
        return Site.login(username, password, startUrl);
    }
    
    protected String validateLock(GNE_CM_IHCP_User__c localIhcpUser)
    {
        String result; 
        Integer loginAttemptLimit = Integer.valueOf(GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Login_Attempt_Limit__c);
        Integer lockoutTime = Integer.valueOf(GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Lockout_Time_minutes__c);
                        
        if(localIhcpUser.IsLocked__c && GNE_CM_IHCP_Utils.SubtractDate(DateTime.now(), localIhcpUser.Locked_Date_Time__c) < lockoutTime)
        {
            result = LOCKOUT_MESSAGE;
        }
        else if(localIhcpUser.IsLocked__c && GNE_CM_IHCP_Utils.SubtractDate(DateTime.now(), localIhcpUser.Locked_Date_Time__c) >= lockoutTime) 
        {
            localIhcpUser.IsLocked__c = false;              
            update localIhcpUser;
        }           
        else if(localIhcpUser.Login_Failed__c == loginAttemptLimit)
        {
            localIhcpUser.IsLocked__c = true;
            localIhcpUser.Locked_Date_Time__c = DateTime.now();
            update localIhcpUser;
            result = LOCKOUT_MESSAGE;   
        }
        return result;         
    }
    
    protected void increaseLoginCounter(GNE_CM_IHCP_User__c localIhcpUser)
    {          
        if(localIhcpUser.Login_Failed__c == null)
        {
            localIhcpUser.Login_Failed__c = 0;
        }

        localIhcpUser.Login_Failed__c++;
        update localIhcpUser;                   
    }
    
    protected void resetLoginCounter(GNE_CM_IHCP_User__c localIhcpUser)
    {   
        localIhcpUser.Login_Failed__c = 0;
        update localIhcpUser;       
    }    
}