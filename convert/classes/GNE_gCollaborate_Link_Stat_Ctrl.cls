public without sharing class GNE_gCollaborate_Link_Stat_Ctrl {

	private String customeSettingName;
	private String groupId;

	/* 
	* Constructor 
	*/
	public GNE_gCollaborate_Link_Stat_Ctrl() { 
		customeSettingName = (ApexPages.currentPage().getparameters().get('c')!=null) ? ApexPages.currentPage().getParameters().get('c') : '';
		groupId = (ApexPages.currentPage().getparameters().get('g')!=null) ? ApexPages.currentPage().getParameters().get('g') : '';
	}

	/* 
	* Redirect
	*
	* Insert / Update statistic for links and redirect to URL
	*/
	public PageReference redirect() {

		GNE_Collaborate_Link_Stat_URL__c customSetting = GNE_Collaborate_Link_Stat_URL__c.getValues(customeSettingName);

		if(customSetting != null) {
			List<GNE_Collaborate_Link_Stat__c> statList = [SELECT Count_gne__c FROM GNE_Collaborate_Link_Stat__c WHERE GroupId_gne__c = :groupId AND Url_gne__c = :customSetting.URL_gne__c AND CreatedById = :UserInfo.getUserId() LIMIT 1];

			if(statList.size() > 0) {
				GNE_Collaborate_Link_Stat__c stat = statList[0];
				stat.Count_gne__c = stat.Count_gne__c + 1;
				update stat;
			} else {
				GNE_Collaborate_Link_Stat__c stat = new GNE_Collaborate_Link_Stat__c();
				stat.Count_gne__c = 1;
				stat.Url_gne__c = customSetting.URL_gne__c;
				stat.GroupId_gne__c = groupId;
				stat.Link_name_gne__c = customSetting.Name_gne__c;
				insert stat;
			}

			PageReference redirect = new PageReference(customSetting.URL_gne__c);
			redirect.setRedirect(true);
			return redirect;
		} else {
			return null;
		}

	}

}