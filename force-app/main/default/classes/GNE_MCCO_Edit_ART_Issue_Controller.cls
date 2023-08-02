public without sharing class GNE_MCCO_Edit_ART_Issue_Controller {	

	private ApexPages.StandardController ctrl;
	
	public GNE_MCCO_Edit_ART_Issue_Controller(ApexPages.StandardController controller) {
		this.ctrl = controller;
	}
	
	public PageReference canBeEdited(){
		ART_Issue_gne__c artIssue = (ART_Issue_gne__c) ctrl.getRecord();
		
		Map<String, String> parametersMap = ApexPages.currentPage().getParameters();
		
		String artSite = artIssue.ART_Site_Local_gne__c;
		
		List<ART_Team_gne__c> memberships = [select id from ART_Team_gne__c where ART_Site_gne__c = :artSite and Team_Member_gne__c = :Userinfo.getUserId()];
		Profile currentUserProfile = [ select id, name from Profile where id = :Userinfo.getProfileId() limit 1];
		
		boolean isMemberOfTheSite = false;
		if(memberships.size() > 0) {
			isMemberOfTheSite = true;
		} 
		
		PageReference result = null;
		
		if(! currentUserProfile.Name.toLowerCase().contains('gne-mcco-mcl-manager')) {
			if(currentUserProfile.Name.toLowerCase().contains('manager')
					|| currentUserProfile.Name.toLowerCase().contains('ops')
					|| currentUserProfile.Name.toLowerCase().contains('leadership')
					|| isMemberOfTheSite){
				result = ctrl.edit();
				result.getParameters().put('nooverride','0');
				result.getParameters().put('retUrl', artSite);
			}
		}
		
		return result;
	}
}