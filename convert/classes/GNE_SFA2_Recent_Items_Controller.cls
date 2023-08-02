/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-11-23
*  Description: This is a controller class for GNE_SFA2_Recent_Items
*  
*  Modification History
*  Date        Name        Description
*  2013/03/04  kwiatkol    Excluded SFA2_View_Config records from recent items
*  2013/03/11  bieniawl	   HttpGet callout moved to jquery/ajax to avoid uncommitted transaction exception
*  2013/03/14  kwiatkol	   Extended list with excluded objects based on SFA2_Search_Settings object
*************************************************************/
public with sharing class GNE_SFA2_Recent_Items_Controller {
	
	private static Integer MAX_RECENT_ITEMS_COUNT = 5;
	public static String testJson {get; set;}
	
	public Integer getMaxRecentItemsCount() {
		return MAX_RECENT_ITEMS_COUNT;
	}
	
	public String getRequestHeader(){ 
		return 'OAuth ' + UserInfo.getSessionId();
	}
	
	public String getEndPointUrl(){
		return 'https://' + System.URL.getSalesforceBaseURL().getHost() + '/services/data/v26.0/recent';
	}
	
	public Set<String> getAvailableObjects() {
		Set<String> result = new Set<String>();
		for(SFA2_Search_Settings_gne__c searchSetting : [ SELECT Id, Object_gne__c FROM SFA2_Search_Settings_gne__c WHERE Application_Name_gne__c = :GNE_SFA2_Application_Cache.userApplicationContext.App_Name_gne__c AND Product_gne__c = :GNE_SFA2_Application_Cache.userApplicationContext.Brand_gne__c 
        	AND Role_gne__c = :GNE_SFA2_Application_Cache.userApplicationContext.Role_gne__c ORDER BY Order_gne__c ]) {
        		result.add(searchSetting.Object_gne__c);
        }
        return result;
	}

	@RemoteAction
	public static String getRecentAABPs(String jsonAabps){
		if(jsonAabps != null){
			List<String> aabpIds = (List<String>)System.JSON.deserialize(jsonAabps, List<String>.class);
			
			List<EDM_AABP_gne__c> approvedAabps = [SELECT Id FROM EDM_AABP_gne__c WHERE Id IN :aabpIds AND EDM_Finalized_gne__c = true];

			Set<String> approvedAabpIds = new Set<String>();

			for(EDM_AABP_gne__c a : approvedAabps){
				approvedAabpIds.add(a.Id);
			}
			testJson = jsonAabps;
			String result = System.JSON.serialize(approvedAabpIds);
			result = result.replace('\"', '"');
			return result;
		}
		return null;
	}
	
	public GNE_SFA2_Recent_Items_Controller() {	}
}