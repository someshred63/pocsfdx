public with sharing class GNE_CM_IHCP_ResetPasswordMessage_Ctlr
{
    public String message { get; set; }
    public String message2 { get; set; }
    public String title { get; set; }
    public String action { get; set; }
    private String portal;
    
    public GNE_CM_IHCP_ResetPasswordMessage_Ctlr()
    {
        try
        {
            message2 = '';
            action = System.currentPageReference().getParameters().get('action');
            portal = System.currentPageReference().getParameters().get('portal');
            if (action == 'invalid')
            {
                title = 'Invalid Activation Link';
                message = 'We are sorry, but the activation link you have used is not valid. If you have reached this page by clicking the link in your e-mail, please try to copy and paste this link in to your browser.';
            }
            if (action == 'locked')
            {
                title = 'Unable to Verify Your Identity';
                if (portal=='LWO')
                {
                    message = 'We are unable to verify your identity at this time. Your account has been disabled for security reasons. Please contact a Lucentis Direct Customer Specialist at 1-800-963-1778, 9am - 8pm ET, Monday through Friday for assistance.';
                }
                else if (portal=='MPS')
                {
                    message = 'We are unable to verify your identity at this time. Your account has been disabled for security reasons.';
                    message2 = 'Please call Genentech Access Solutions at (866) 4 ACCESS/(866) 422-2377 for assistance.';
                }
            }
            if (action == 'lockout')
            {
                title = 'Unable to Verify Your Identity';
                if (portal=='LWO')
                {
                    message = 'We are unable to verify your identity at this time. Your account has been disabled for security reasons. Please contact a Lucentis Direct Customer Specialist at 1-800-963-1778 from 9am-8pm ET, Monday through Friday for assistance.';
                }
                else if (portal=='MPS')
                {
                    message = 'You have exceeded login attempts and your account has been disabled for security reasons.';
                    message2 = 'Please call Genentech Access Solutions at (866) 4 ACCESS/(866) 422-2377 for assistance.';

                }
            }
        }
        catch (Exception ex)
        {
            title = 'Error';
            message = 'Error: ' + GlobalUtils.getExceptionDescription(ex);
        }
    }
    
    /**
     * Redirect to the LWO external home page (e.g. on the Lucentis server)
     */
    public PageReference redirectToHome()
    {
    	PageReference pageRef = new PageReference(GNE_LWO_CustomSettingsHelper.self().getLWOConfig().LWO_Login_Page__c);
    	String ims=System.currentPageReference().getParameters().get('IMS');
    	if(ims!=null && ims.trim()=='PODIS') pageRef = new PageReference(GNE_LWO_CustomSettingsHelper.self().getLWOConfig().PODIS_Login_page__c);
		pageRef.setRedirect(true);
		return pageRef;
    }
}