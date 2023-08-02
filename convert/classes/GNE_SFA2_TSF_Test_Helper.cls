/************************************************************
*  @author: Michal Hrycenko, Roche
*  Date: 2012-09-19
*  Description: This is a helper class for TSF related unit tests
*  
*  Modification History
*  Date        Name        Description
*  
*************************************************************/
public with sharing class GNE_SFA2_TSF_Test_Helper {
	
	public static Integer BATCH_SIZE = 201;	// 201 to test agains governor limits
	
	public static List<TSF_vod__c> insertTestTSFs(Set<String> emptyFieldNames, Map<String, Object> testFieldValues) {
		List<TSF_vod__c> testTSFs = prepareTestTSFs(emptyFieldNames, testFieldValues);
		insert testTSFs;
		return testTSFs;
	}
	
	/* helper method used for preparing test data */
	public static List<TSF_vod__c> prepareTestTSFs(Set<String> emptyFieldNames, Map<String, Object> testFieldValues) {
		List<TSF_vod__c> testData = new List<TSF_vod__c>();
		for(Integer i = 0; i < BATCH_SIZE; i++) {
			TSF_vod__c tsf = new TSF_vod__c();
				
			// populate Account_vod__c field
			tsf.Account_vod__c = (Id) getFieldValue('Account_vod__c', emptyFieldNames, testFieldValues);
			// populate Territory_vod__c field
			tsf.Territory_vod__c = (String) getFieldValue('Territory_vod__c', emptyFieldNames, testFieldValues);
			tsf.Territory_vod__c += i;
			
			testData.add(tsf);
			
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