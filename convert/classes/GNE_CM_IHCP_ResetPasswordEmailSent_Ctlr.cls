public with sharing class GNE_CM_IHCP_ResetPasswordEmailSent_Ctlr {
    public String email { get; set; }
    
    public GNE_CM_IHCP_ResetPasswordEmailSent_Ctlr()
    {
        email = System.currentPageReference().getParameters().get('email');
    }
    
    /*public PageReference OK()
    {
    
       return GNE_CM_IHCP_Utils.getLWOHomePage();    
    }*/
    //Jie made teh change for PODIS - LOW integration project
    public PageReference OK()
    {
       String loginUrl = Site.getCurrentSiteUrl();
       if(loginUrl.contains('PODIS')) return GNE_CM_IHCP_Utils.getLWOHomePage('PODIS'); 
       else return GNE_CM_IHCP_Utils.getLWOHomePage('LWO');    
       
       
    }
}