/************************************************************
*  @author: Michal Hrycenko, Roche
*  Date: 2012-09-13
*  Description: This is a helper class for IRF related unit tests
*  
*  Modification History
*  Date        Name        Description
*  
*************************************************************/
@isTest
public with sharing class GNE_SFA2_IRF_Test_Helper {

	public static Integer BATCH_SIZE = 201;	// 201 to test agains governor limits
	public static User user = [SELECT Id, FirstName, LastName, Email FROM User WHERE isActive = true AND Profile.Name LIKE 'GNE-Field' limit 1];
	public static Account acct = [Select Id from Account where Account_Type_gne__c = 'Hospital' limit 1];
	
	public static List<Issue_gne__c> insertTestIRFs(Set<String> emptyFieldNames, Map<String, Object> testFieldValues) {
		List<Issue_gne__c> testIRF = prepareTestIRFs(emptyFieldNames, testFieldValues);
		insert testIRF;
		return testIRF;
	}
	
	/* helper method used for preparing test data */
	public static List<Issue_gne__c> prepareTestIRFs(Set<String> emptyFieldNames, Map<String, Object> testFieldValues) {
		List<Issue_gne__c> testData = new List<Issue_gne__c>();
		for(Integer i = 0; i < BATCH_SIZE; i++) {
			Issue_gne__c iRF = new Issue_gne__c();
				
			// populate Assigned_FRM_gne__c field
			iRF.Assigned_FRM_gne__c = (Id) getFieldValue('Assigned_FRM_gne__c', emptyFieldNames, testFieldValues);
			// populate Practice_Name_frm_gne__c field
			iRF.Practice_Name_frm_gne__c = (Id) getFieldValue('Practice_Name_frm_gne__c', emptyFieldNames, testFieldValues);
			// populate Status_frm_gne__c field
			iRF.Status_frm_gne__c = (String) getFieldValue('Status_frm_gne__c', emptyFieldNames, testFieldValues);
			
			testData.add(iRF);
		}
		
		return testData;
	}
	
	/* helper method for getting field value */
	public static Object getFieldValue(String fieldName, Set<String> emptyFieldNames, Map<String, Object> testFieldValues){
		Object result = null;
		if(emptyFieldNames != null && emptyFieldNames.contains(fieldName)) {
			result = '';			
		} else if(testFieldValues != null && testFieldValues.containsKey(fieldName)) {
			result = (Object) testFieldValues.get(fieldName);
		} else {
			result = 'test';
		}
		return result;
	}
}