/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2013-03-08
*  This is SFA2 app cache used to improve SFA2 app performance
*    
*  Modification History
*  Date        Name        Description
*************************************************************/
public without sharing class GNE_SFA2_Application_Cache {

	public static Map<String, Schema.SObjectType> globalDescribe { get {
		if(globalDescribe == null) {
			globalDescribe = Schema.getGlobalDescribe();
		}
		return globalDescribe;	 
	} private set; }
	
	private static Map<String, Schema.DescribeSObjectResult> objectDescribe = new Map<String, Schema.DescribeSObjectResult>(); 
	
	public static Schema.DescribeSObjectResult describeObject(String objectName) {
		system.debug('MICK_LOKO objectName:' +objectName);
		if(objectDescribe.containsKey(objectName)) {
			// object is already described
			return objectDescribe.get(objectName);
		} else {
			// object is not described yet
			objectDescribe.put(objectName, globalDescribe.get(objectName).getDescribe());
			return objectDescribe.get(objectName);
		}
	}
	
	public static GNE_SFA2_User_App_Context_gne__c userApplicationContext { get {
			if(userApplicationContext == null) {
				userApplicationContext = GNE_SFA2_Util.getUserApplicationContext();
			}
			return userApplicationContext;
	} private set; }
}