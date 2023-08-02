public with sharing class GNE_CRM_Quick_Reference_Controller {
	public WebLink myCOContacts {get; private set;}
	public WebLink myRecentInteractions {get; private set;}
	public WebLink myPrimaryContacts {get; private set;}
	public WebLink hpsmSupport {get; private set;}
	public WebLink myAdverseEvent {get; private set;}
	public WebLink aeroTrainingMaterial {get; private set;}
	public WebLink apa {get; private set;}
	public WebLink chris {get; private set;}
	public WebLink concur {get; private set;}
	public WebLink golf {get; private set;}
	public WebLink ramp {get; private set;}
	public WebLink est {get; private set;}
	public WebLink esbrietCcResources {get; private set;}
	public WebLink ePAD {get; private set;}
	public WebLink interactionsDashboardCC {get; private set;}
	
	public Boolean isMCCOKaiser {get; private set;}
	public Boolean isMCCOAM {get; private set;}
	public Boolean isEsbrietCC {get; private set;}
    public Boolean isCCcrm {get; private set;}


	public GNE_CRM_Quick_Reference_Controller() {
		isEsbrietCC = false;
		isMCCOAM = false;
		isMCCOKaiser = false;
        isCCcrm = false;
		
		String userProfile = GNE_SFA2_Util.getCurrentUserProfileName();
		if(userProfile.equalsIgnoreCase('GNE-MCCO-Kaiser')){
			isMCCOKaiser = true;
		} else if (userProfile.equalsIgnoreCase('GNE-MCCO-AM')){
			isMCCOAM = true;
		} else if (userProfile.equalsIgnoreCase('GNE-SFA-CC-Esbriet')){
			isEsbrietCC = true;
        } else if(GNE_SFA2_Util.isCCCrmUser()) {
            isCCcrm = true;
		}
		
		List<WebLink> links = [
				SELECT Id, Name, MasterLabel, OpenType, Url 
				FROM WebLink 
			WHERE Name IN ('APA' , 'CHRIS' , 'CONCUR' , 'GOLF' , 'RAMP' , 'EST' , 'Esbriet_CC_Resources', 'ePAD' ,'My_Primary_Contacts_cft_gne', 'Interactions_Dashboard',
				'My_Recent_Interactions_cft_gne', 'My_CO_Notification_Contacts', 'HPSM_Support', 'Adverse_Event_Reporting', 'Aero_Training_Material')
		];

		for(WebLink wl :links){
			if(wl.Name.equalsIgnoreCase('My_Primary_Contacts_cft_gne')){
				myPrimaryContacts = wl;
			} else if(wl.Name.equalsIgnoreCase('My_Recent_Interactions_cft_gne')){
				myRecentInteractions = wl;
			} else if(wl.Name.equalsIgnoreCase('My_CO_Notification_Contacts')){
				myCOContacts = wl;
			} else if(wl.Name.equalsIgnoreCase('HPSM_Support')){
				hpsmSupport = wl;
			} else if(wl.Name.equalsIgnoreCase('Adverse_Event_Reporting')){
				myAdverseEvent = wl;
			} else if(wl.Name.equalsIgnoreCase('Aero_Training_Material')){
				aeroTrainingMaterial = wl;
			} else if(wl.Name.equalsIgnoreCase('APA')){
				apa = wl;
			} else if(wl.Name.equalsIgnoreCase('CHRIS')){
				chris = wl;
			} else if(wl.Name.equalsIgnoreCase('CONCUR')){
				concur = wl;
			} else if(wl.Name.equalsIgnoreCase('GOLF')){
				golf = wl;
			} else if(wl.Name.equalsIgnoreCase('RAMP')){
				ramp = wl;
			} else if(wl.Name.equalsIgnoreCase('EST')){
				est = wl;
			} else if(wl.Name.equalsIgnoreCase('Esbriet_CC_Resources')){
				esbrietCcResources = wl;
			} else if(wl.Name.equalsIgnoreCase('ePAD')){
				ePAD = wl;
			} else if(wl.Name.equalsIgnoreCase('Interactions_Dashboard')){
				interactionsDashboardCC = wl;
			} 
			
		}
	}


}