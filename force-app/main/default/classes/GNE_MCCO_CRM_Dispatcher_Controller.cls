public with sharing class GNE_MCCO_CRM_Dispatcher_Controller {

    private final sObject STANDARD_OBJECT;
	private String profileName { get; set; }
	private PageReference pageRefEdit { get; set; }

    public GNE_MCCO_CRM_Dispatcher_Controller(ApexPages.StandardController stdController) {
        STANDARD_OBJECT	= stdController.getRecord();
        profileName 	= getUserProfileName();
        pageRefEdit		= stdController.edit();
    }
		
	private String getUserProfileName() {
		return [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1][0].Name;
	}
	
	public PageReference interactionDispatcher() {
		PageReference pageRef;

		if(checkUserProfile()) {
			if (GNE_SFA2_Util.isFrmUser()){
				pageRef = new PageReference('/apex/GNE_SFA2_Interaction?id=' + STANDARD_OBJECT.Id);
			} else {
				pageRef = new PageReference('/apex/GNE_MCCO_CRM_Interaction?id=' + STANDARD_OBJECT.Id);
			}	
		} else {
			pageRef = pageRefEdit;	
		}

		pageRef.setRedirect(true); 
		return pageRef;
	}

	public PageReference surveyDispatcher() {
		PageReference pageRef;
		String retUrl;
		
		if(checkUserProfile()) {
			
			retUrl = (ApexPages.currentPage().getParameters().get('retUrl') != null && ApexPages.currentPage().getParameters().get('retUrl') != '') ? ApexPages.currentPage().getParameters().get('retUrl') : null;
			
			GNE_MCCO_CRM_Field_Intelligence__c fi = [SELECT Id, Account_gne__c, Survey_Status_gne__c FROM GNE_MCCO_CRM_Field_Intelligence__c WHERE Id = :STANDARD_OBJECT.Id];
			
			if(String.isNotBlank(retUrl)) {
				pageRef = new PageReference('/apex/GNE_MCCO_CRM_Field_Intelligence_Edit?id=' + STANDARD_OBJECT.Id + '&retUrl=' + fi.Account_gne__c);
			} else {
				pageRef = new PageReference('/apex/GNE_MCCO_CRM_Field_Intelligence_Det?id=' + STANDARD_OBJECT.Id + '&retUrl=' + fi.Account_gne__c);
			}	
			
		} else {
			pageRef = pageRefEdit;	
		}

		pageRef.setRedirect(true); 
		return pageRef;
	}
	
	private Boolean checkUserProfile() {
		return (profileName == 'GNE-MCCO-AM') || GNE_SFA2_Util.isFrmUser();
	}
	
}