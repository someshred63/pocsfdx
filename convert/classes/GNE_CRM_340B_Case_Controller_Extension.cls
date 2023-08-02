public with sharing class GNE_CRM_340B_Case_Controller_Extension {

    private GNE_CRM_340B_Case__c case340B;
    private ApexPages.StandardController sController;
    private String queryString;
    public Boolean isCreateMode {get; set;}

    public GNE_CRM_340B_Case_Controller_Extension(ApexPages.StandardController controller) {
        sController = controller;
        case340B = (GNE_CRM_340B_Case__c)controller.getRecord();
        List<string> pageUrl = ApexPages.currentPage().getUrl().split('\\?');
        queryString = pageUrl[1];
        this.isCreateMode = String.isBlank(case340B.Id) ? true : false;
    }
    
    public PageReference saveAndNew() {
        try { 
	    sController.save();
	    Schema.DescribeSObjectResult describeResult = sController.getRecord().getSObjectType().getDescribe();
            PageReference pr = new PageReference('/' + describeResult.getKeyPrefix() + '/e?' + queryString);
            pr.setRedirect(true);
            return pr;    
        } catch(System.DMLException e) {
            ApexPages.addMessages(e);
            return null;
        }
    }
    
}