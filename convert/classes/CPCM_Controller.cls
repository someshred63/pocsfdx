public without sharing class CPCM_Controller {

 public PageReference redirectToSalesforceLogin(){
  PageReference nextPage = new PageReference('https://crm.gene.com/');
   return nextPage;       
 }
}