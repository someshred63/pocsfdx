public without sharing class GNE_MCCO_Create_ART_Team_Controller {	

	private ApexPages.StandardController ctrl;
	
	public GNE_MCCO_Create_ART_Team_Controller(ApexPages.StandardController controller) {
		this.ctrl = controller;
	}
	
	public PageReference canBeCreated(){

		Map<String, String> parametersMap = ApexPages.currentPage().getParameters();
		
		String artSite = parametersMap.get('retUrl').substring(1,parametersMap.get('retUrl').length());
		
		List<ART_Team_gne__c> memberships = [ select id from ART_Team_gne__c where ART_Site_gne__c = :artSite and Team_Member_gne__c = :Userinfo.getUserId() ];
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
				ART_Team_gne__c artTeam = [select id from ART_Team_gne__c limit 1];
							
				result = new Pagereference('/' + ((String)artTeam.get('Id')).subString(0, 3) + '/e?');
				// rewrite original parametrs passed to the page
				for(String paramenterKey : parametersMap.keySet()){
					result.getParameters().put(paramenterKey,parametersMap.get(paramenterKey));
				}
				result.getParameters().put('nooverride','0');
				result.getParameters().remove('save_new');
			}
		}

		return result;
	}
}