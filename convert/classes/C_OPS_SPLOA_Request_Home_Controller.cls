/***********************************************************************************************************************
Purpose: C_OPS_SPLOA_Request_Home_Controller class is used to handle the selection of the entry page.
Jira : ROBOCOPS-203
========================================================================================================================
History                                                            
-------                                                            
VERSION  AUTHOR        DATE            DETAIL                       
1.0                                 INITIAL DEVELOPMENT
1.1     Raju Manche  9/4/2020       Add an entry page to the Online form, which allows actor to choose the type of submission.
**********************************************************************************************************************/

public without sharing class C_OPS_SPLOA_Request_Home_Controller {
    public String userAction {get;set;}
    public String errorMsg {set; get;}

    public C_OPS_SPLOA_Request_Home_Controller() {
        userAction = '';
        errorMsg = '';
    }

    public PageReference redirectToSelectedPage(){
        PageReference nextPage;
        String selOption = ApexPages.currentPage().getParameters().get('selectedOption');

        if(String.isNotBlank(userAction) || String.isNotBlank(selOption)){        
            if(userAction == 'newRequest'){          
                //nextPage = Page.C_OPS_SPLOA_CONTACT_INFOPG;                
                //nextPage = new PageReference('/apex/C_OPS_SPLOA_CONTACT_INFOPG');
                nextPage = new PageReference('/apex/C_OPS_SPLOA_CONTACT_INFOPG');
                nextPage.setRedirect(true);
                nextPage.getParameters().put('requestType','New Request');
                return nextPage;
            }
            if(userAction == 'renewRequest'){          
                //nextPage = Page.C_OPS_SPLOA_RENEW_PAGE;
                //nextPage = new PageReference('/apex/C_OPS_SPLOA_RENEW_PAGE');
                //nextPage = Page.C_OPS_SPLOA_CONTACT_INFOPG;
                nextPage = new PageReference('/apex/C_OPS_SPLOA_CONTACT_INFOPG');
                nextPage.setRedirect(true);
                nextPage.getParameters().put('requestType','Renewal');
                return nextPage;
            }
            if(userAction == 'addProdRequest'){          
                //nextPage = Page.C_OPS_SPLOA_NEW_PRODUCT_PAGE;
                //nextPage = new PageReference('/apex/C_OPS_SPLOA_NEW_PRODUCT_PAGE');
                nextPage = new PageReference('/apex/C_OPS_SPLOA_CONTACT_INFOPG');
                nextPage.setRedirect(true);
                nextPage.getParameters().put('requestType','Add Product');
                return nextPage;
            }
            if(userAction == 'addSites'){
                //nextPage = Page.C_OPS_SPLOA_ADD_SITES;
                //nextPage = new PageReference('/apex/C_OPS_SPLOA_ADD_SITES');
                nextPage = new PageReference('/apex/C_OPS_SPLOA_CONTACT_INFOPG');
                nextPage.setRedirect(true);
                nextPage.getParameters().put('requestType','Add Location');
                return nextPage;
            }       
            errorMsg = '';
        }        
        else{
            errorMsg = 'Please select one option';
            ApexPages.Message apexMsg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg);
            ApexPages.addMessage(apexMsg);
        }
        return nextPage;       
    }
}