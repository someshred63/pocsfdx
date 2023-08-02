public class SFA_AccountRedirectService {

    public string mdmid { get; set; }
    
    public PageReference init() {
    
        mdmId = ApexPages.currentPage().getParameters().get('mdmid');
        

        try {             
            if ( mdmid != null ) {

                Account acct = [select id, name from account 
                                where mdmid_gne__c = :mdmid ];
                
		        String actionType = ApexPages.currentPage().getParameters().get('action');
                
                if (actionType != null ) {                    
                    if( actionType.equalsIgnoreCase('NewInteraction') ){	

				        PageReference callPage = new PageReference ('/apex/SFAInteractionRedirectPage?id=' + acct.Id);
				        callPage.setRedirect(true);
				        return callPage;

                    }                  	
                } else {
                    return (new ApexPages.StandardController(acct) ).view();                          
                }
                                
            }    
        } catch (Exception e) {        
            ApexPages.addMessages(e);
        }
        
        return null;
        
    }


}