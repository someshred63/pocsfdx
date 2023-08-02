public with sharing class VDST_SiteLoginController {
/* Deprecated:
    public String password     { get; set; }
    public String usrname      { get; set; }
    
    public PageReference usrLogin() {
        try {
            system.debug('User logon starts.');    
            if (this.password.equals('')) {
                 return showErrorOnPage('Please enter a password.');    
            }       
                              
            PageReference pageRef = Site.login(usrname, password, '/VDST_EventList');
            if(pageRef == null) {             
                return showErrorOnPage('Incorect user or password.');                    
            } else {
                return pageRef;
            }          
        }             
        catch(Exception e)
        {
            return showErrorOnPage(e.getStackTraceString());
        }   
    }
    
    private PageReference showErrorOnPage(String errorMessage)
    {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, errorMessage));
        return ApexPages.currentPage();     
    }
*/ 
}