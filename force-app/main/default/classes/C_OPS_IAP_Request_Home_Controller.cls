public with sharing class C_OPS_IAP_Request_Home_Controller {
    public String userAction {get;set;}
    public String errorMsg {set; get;}
    
        public C_OPS_IAP_Request_Home_Controller() {
        userAction = '';
        errorMsg = '';
    }
    
     public PageReference redirectToSelectedPage(){
        PageReference nextPage;
        String selOption = ApexPages.currentPage().getParameters().get('selectedOption');
system.debug('--->'+selOption);
        if(String.isNotBlank(userAction) || String.isNotBlank(selOption)){        
            if(userAction == 'newRequest'){          
                nextPage = new PageReference('/apex/C_OPS_IAP_CONTACT_INFOPG');
                nextPage.setRedirect(true);
                nextPage.getParameters().put('requestType','New Request');
                return nextPage;
            }
            if(userAction == 'renewRequest'){          
                nextPage = new PageReference('/apex/C_OPS_IAP_CONTACT_INFOPG');
                nextPage.setRedirect(true);
                nextPage.getParameters().put('requestType','Renewal');
                return nextPage;
            }
            if(userAction == 'addProdRequest'){          
                nextPage = new PageReference('/apex/C_OPS_IAP_CONTACT_INFOPG');
                nextPage.setRedirect(true);
                nextPage.getParameters().put('requestType','Add Product');
                return nextPage;
            }
            if(userAction == 'addSites'){
                nextPage = new PageReference('/apex/C_OPS_IAP_CONTACT_INFOPG');
                nextPage.setRedirect(true);
                nextPage.getParameters().put('requestType','Add Location');
                return nextPage;
            }
            if(userAction == 'checkRequest'){
                nextPage = new PageReference('/apex/C_OPS_IAP_CHECK_REQ');
                nextPage.setRedirect(true);
            //    nextPage.getParameters().put('requestType','Check Request');
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