public without sharing class GNE_CM_MPS_Header_Controller {
	
	public string currentPageName{get; set;}
	public Boolean showForAdmin {get; set;}
	
	//link for header Log Out Link
	public string logOutLink {get;set;}
	//link for header My Profile Settings
	public string myProfileSettingsLink {get;set;}
	//link for header User Guide
	public string userGuideLink {get;set;}		
    //link for Footer Home Page
    public string footerHomePageLink {get;set;} 	
    //link for Footer Unsecure Home Page
    public string footerHomePageUnsecureLink {get;set;} 
    public string underconstrctn {get;set;} 	
	
	public GNE_CM_MPS_Header_Controller()
	{
		Set<String> envVaribles = new Set<String>();
		envVaribles.add('GNE_CM_MPS_LogoutHeader');
		envVaribles.add('GNE_CM_MPS_UserGuide');
		envVaribles.add('GNE_CM_MPS_MyProfileSettings');
		envVaribles.add('GNE_CM_MPS_FooterHomeLink');
		envVaribles.add('GNE_CM_MPS_FooterHomeUnsecureLink');
		Map<String, List<Environment_Variables__c>> result = GNE_CM_MPS_Utils.populateEnvVariables(envVaribles);		
		List<Environment_Variables__c> envVar = result.get('GNE_CM_MPS_LogoutHeader');
		if(envVar != null && envVar.size() > 0)
		{
			logOutLink = envVar[0].Value__c;
		}
		envVar = result.get('GNE_CM_MPS_UserGuide');
		if(envVar != null && envVar.size() > 0)
		{
			userGuideLink = envVar[0].Value__c;
		}		
		envVar = result.get('GNE_CM_MPS_MyProfileSettings');
		if(envVar != null && envVar.size() > 0)
		{
			myProfileSettingsLink = envVar[0].Value__c;
		}
		envVar = result.get('GNE_CM_MPS_FooterHomeLink');
		if(envVar != null && envVar.size() > 0)
		{
			footerHomePageLink = envVar[0].Value__c;
		}
        if(footerHomePageLink == null || footerHomePageLink == '')
        {
            footerHomePageLink = GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Default_Portal_Address__c;
        }
		envVar = result.get('GNE_CM_MPS_FooterHomeUnsecureLink');
		if(envVar != null && envVar.size() > 0)
		{
			footerHomePageUnsecureLink = envVar[0].Value__c;
		}
        if(footerHomePageUnsecureLink == null || footerHomePageUnsecureLink == '')
        {
            footerHomePageUnsecureLink = GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Footer_Home_Page_Unsecure_Link__c;
        }
			
		//Tab Practice Administration visibility
		//RK set to false in final and uncomment the rest of code 
		showForAdmin = false;
		
		Id currentUserId = UserInfo.getUserId();
		List<GNE_CM_MPS_User__c> mpsUsers = [Select Id from GNE_CM_MPS_User__c 
									  		 where SFDC_User__c = :currentUserId];	
		if(mpsUsers.size() == 0)
		{
			showForAdmin = false;			
		}
		else
		{
			List<GNE_CM_MPS_Practice_Agreement__c> practiceAgreementsList = [select SFDC_User_Id__c, Is_Admin_Flag__c
																		     from GNE_CM_MPS_Practice_Agreement__c
																		     where MPS_User__c = :mpsUsers[0].Id];			
			if(practiceAgreementsList.size() == 0)
			{
				showForAdmin = false;
			}
			else
			{
				if(practiceAgreementsList[0].Is_Admin_Flag__c == 'Yes')
					showForAdmin = true;
				else
					showForAdmin = false;
			}
		}
	}
}