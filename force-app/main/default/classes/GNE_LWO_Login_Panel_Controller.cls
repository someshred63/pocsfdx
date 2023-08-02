/**
 * Controller class for LWO login panel that will be embedded in an iframe.
 * @author Radek Krawiec
 * @created 08/10/2012
 *
 * Test class: GNE_LWO_IHCP_Conversion_Test
 */
public without sharing class GNE_LWO_Login_Panel_Controller extends GNE_CM_IHCP_Login_Controller
{
    public String username { get; set; }
    public String password { get; set; }
    public Id sfdcUserId { get; set; }
    public Boolean isErrorDisplayed { get; private set; }
    public String errorMessage { get; set; }
    public Boolean isAuthenticated { get; set; }
    public String redirectUrl { get; set; }
    private String loginFrom='LWO';
    private String loginUrl;
    
    private static final String FAILED_LOGIN = 'The User Name or Password you entered is incorrect. Please try again.';
    
    public GNE_LWO_Login_Panel_Controller()
    {
        isAuthenticated=false;
        //System.debug('>>>> params=' + ApexPages.currentPage().getParameters());  
        if (ApexPages.currentPage().getParameters().get('USER')!=null)  {
            username=ApexPages.currentPage().getParameters().get('USER');
            password=ApexPages.currentPage().getParameters().get('PASSWORD');
        }
        
        loginUrl = System.currentPageReference().getUrl();
        
        if(loginUrl!=null && loginUrl.length()>0){
            Integer i=loginUrl.lastindexof('_');
            if(i!=-1) loginFrom=loginUrl.subString(i+1);
            if(loginFrom=='PODIS') loginFrom='PODIS';
            else loginFrom='LWO';
        }
    }
    
    /**
     * Method called when user submits the login form.
     */
    public override PageReference login()
    {
        String startUrl = '/apex/GNE_LWO_Order?IMS='+loginFrom;   
        //String startUrl = '/apex/GNE_LWO_Iframe';       
        isErrorDisplayed = true;
        
        try
        {  
            // check if an IHCP user exists for this user
            GNE_CM_IHCP_User__c ihcpUser = GNE_CM_IHCP_Utils.getIHCPUser(username);
        
            System.debug('IHCP User: '+ ihcpUser);

            if (ihcpUser != null && ihcpUser.LWO_Status__c == 'Approved')
            {   
                errorMessage = validateLock(ihcpUser);
                if (errorMessage != null && errorMessage.length() > 0)
                {
                    if(loginFrom=='PODIS') return new PageReference('/apex/GNE_LWO_ResetPasswordMessage?action=lockout&portal=LWO&IMS=PODIS');
                    else return new PageReference('/apex/GNE_LWO_ResetPasswordMessage?action=lockout&portal=LWO');
                }
                
                system.debug('Calling site.login');
                Pagereference pRef = Site.login(username, password, startUrl);
                system.debug('Site login returned = ' + pRef);
                
                if (pRef == null)
                {
                    // log non-existing username
                    GNE_CM_MPS_Utils.insertError('LWO login', 'Low', 'login', 'Apex Class', 'Incorrect password for user \'' + username + '\'');
                
                    increaseLoginCounter(ihcpUser);
                    String errorURL=null;
                    if(loginFrom=='LWO') errorURL = GNE_LWO_CustomSettingsHelper.self().getLWOConfig().Login_Panel_Error_URL__c;
                  
                    if(errorURL != null)
                    {
                        PageReference pg = new PageReference(errorURL);
                        return pg;
                    }
                    username = null;
                    password = null;                    
                    errorMessage = FAILED_LOGIN;
                    return null;
                }
                
                resetLoginCounter(ihcpUser);
                isErrorDisplayed = false;                
              
                isAuthenticated = true;
                system.debug('Redirecting to page ref = ' + pRef);    
                
                GNE_LWO_User__c lwouser=[select SFDC_User__c, Last_LWO_Login__c from GNE_LWO_User__c where User_Name__c =:username ];
                lwouser.Last_LWO_Login__c =System.now();
                update lwouser;
                
                return pRef;                
            } 
            else 
            {
                if (GNE_CM_IHCP_User_Util.findUserAndRollbackConversionSteps('LWO', username))
                {
                    // redirect to WAC to check credentials
                    String wacURL = GNE_LWO_CustomSettingsHelper.self().getLWOConfig().Login_Panel_Current_User_Redirect_URL__c;
                    
                    if (wacURL != null)
                    {
                       PageReference pg = new PageReference(wacURL);
                       return pg;
                    }
                }
                
                // log non-existing username
                GNE_CM_MPS_Utils.insertError('LWO login', 'Low', 'login', 'Apex Class', 'User \'' + username + '\' does not exist');
                
                String errorURL=null;
                if(loginFrom=='LWO') errorURL = GNE_LWO_CustomSettingsHelper.self().getLWOConfig().Login_Panel_Error_URL__c;
                
                if (errorURL != null)
                {
                    PageReference pg = new PageReference(errorURL);
                    return pg;
                }
                
                username = null;
                password = null;
                errorMessage = FAILED_LOGIN;
                return null;            
            }
        }
        catch(Exception ex)
        {
            errorMessage = 'Error occurred: ' + GlobalUtils.getExceptionDescription(ex);
            return null;
        }                   
    }
    
   
}