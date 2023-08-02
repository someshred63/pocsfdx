public with sharing class CFAR_Trial_Redirect_Controller {
	
	private Id trialId;
	
	public CFAR_Trial_Redirect_Controller(ApexPages.StandardController ctrl) {
		trialId = ctrl.getId();
	}
	
	public PageReference redirectToTrial() {
		return new PageReference('/apex/CFAR_Trial?id=' + trialId).setRedirect(true);
	}
}