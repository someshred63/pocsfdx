public with sharing class AGS_ST_Proxy_Management_PageHelper 
{
    public static PageReference prepareProxyMangementPage()
    {
        PageReference pr = Page.AGS_ST_Proxy_Management_gne;      
        pr.setRedirect(true);
        return pr;      
    }
    
    public static PageReference prepareProxyMangementPageForRefresh()
    {
        PageReference pr = Page.AGS_ST_Proxy_Management_gne; 
        pr.setRedirect(true);
        return pr;      
    }
    
    public static PageReference prepareCreatePermissionsPage(String userId)
    {
        PageReference pr = Page.AGS_ST_CreatePermissions_gne;
        pr.getParameters().put('user_id', userId);  
        pr.setRedirect(true);
        return pr;          
    }
    
    public static PageReference prepareProxyCreateUserPage(String accountId, String proxyId)
    {
        PageReference pr = Page.AGS_ST_Proxy_CreateUser_gne;
        pr.getParameters().put('acct_id', accountId);
        pr.getParameters().put('proxy_id', proxyId);  
        pr.setRedirect(true);
        return pr;              
    }    
    
    public static PageReference prepareProxyCreateAccountPage(String proxyId, String email)
    {
        PageReference pr = Page.AGS_ST_Proxy_CreateAccount_gne;
        pr.getParameters().put('proxy_id', proxyId); 
        pr.getParameters().put('email',email);
        pr.setRedirect(true);
        return pr;  
    }
    
    public static PageReference prepareSimsPage(String proxyId, String userId)
    {
        PageReference pr = Page.AGS_ST_Create_SIMS_Usr_gne;
        pr.getParameters().put('proxy_id', proxyId);
        pr.getParameters().put('user_id', userId);
        pr.setRedirect(true);
        return pr;  
    }
    
    
    public static PageReference prepareUpdateProxyUser(String proxyId, String proxyUserId, String goToSims)
    {
        PageReference pr = Page.AGS_ST_Proxy_UpdateProxy;
        pr.getParameters().put('pu_proxy_id', proxyId);
        pr.getParameters().put('pu_user_id', proxyUserId);
        pr.getParameters().put('pu_goto_sims', goToSims);
        pr.setRedirect(true);       
        return pr;
    }
    
    public static PageReference prepareCurrentPage()
    {
        PageReference ref =  Apexpages.currentPage();
        ref.setRedirect(true);
        return ref;
    }
    
    public static PageReference prepareErrorPage()
    {
        PageReference pr = Page.AGS_ST_RegisterError_gne;
        pr.setRedirect(true);
        pr.getParameters().put('errMsg', 'Error while performing operation! Please contact Your helpdesk!');        
        return pr;
    }              

}