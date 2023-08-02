public without sharing class AGS_ST_Proxy_TC_Controller_gne 
{
    public PageReference loadAction()
    {
        System.debug('Starting AGS_ST_Proxy_TC_Controller_gne.loadAction'); 
        AGS_ST_Proxy_gne__c proxy = AGS_ST_DbUtils.findProxyByUserId(UserInfo.getUserId());
        if(proxy.tcAccepted_gne__c)
        {
            this.addErrorMessage('Terms and Conditions already accepted !');
            System.debug('Terms and Conditions already accepted for user: ' + UserInfo.getUserId());
        }
        return null;
    }
    
    public PageReference acceptTcAction()
    {
        System.debug('Starting AGS_ST_Proxy_TC_Controller_gne.acceptTcAction'); 
        AGS_ST_Proxy_gne__c proxy = AGS_ST_DbUtils.findProxyByUserId(UserInfo.getUserId());
        proxy.tcAccepted_gne__c = true;
        update proxy;
        System.debug('TS Accepted for user: ' + UserInfo.getName()); 
        
        return Page.AGS_ST_Proxy_Management_gne;
    }

    public PageReference declineTcAction()
    {
        System.debug('Starting AGS_ST_Proxy_TC_Controller_gne.declineTcAction');                    
        //return Page.AGS_ST_Login_gne;     
        return prepareRegisterErrorPage('Terms and conditions are mandatory and it needs to be accepted in order to log onto Sunshine Tool.');      
    }       
    
    private PageReference prepareRegisterErrorPage(String errMessage)
    {
        PageReference pr = Page.AGS_ST_RegisterError_gne;
        pr.setRedirect(true);
        pr.getParameters().put('errMsg',errMessage);        
        return pr;
    }   
    
    private void addErrorMessage(String message)
    {
        ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR, message);       
        ApexPages.addMessage(msg);  
    }   
}