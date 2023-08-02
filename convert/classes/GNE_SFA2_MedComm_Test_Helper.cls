/************************************************************
*  @author: Michal Hrycenko, Roche
*  Date: 2012-08-20
*  Description: This is a helper class for MedComm related unit tests
*  
*  Modification History
*  Date        Name        Description
*  
*************************************************************/
public with sharing class GNE_SFA2_MedComm_Test_Helper {

	public static Integer BATCH_SIZE = 201;	// 201 to test agains governor limits
	static final String SOBJECT_TYPE_NAME = 'Medical_Communication_gne__c';
    static final String REFERRAL_RECORD_TYPE_NAME = 'Referral';
    static final String MEDCOMM_RECORD_TYPE_NAME = 'MedComm';
    
	public static Id referralRecordTypeId() {
    	RecordType referralRecordType = [Select Id, IsActive, Name, SobjectType from RecordType where SobjectType =: SOBJECT_TYPE_NAME and Name =: REFERRAL_RECORD_TYPE_NAME and IsActive =: true limit 1];
    	return referralRecordType.id;
    }
	
	public static Id medCommRecordTypeId() {
    	RecordType medCommRecordType = [Select Id, IsActive, Name, SobjectType from RecordType where SobjectType =: SOBJECT_TYPE_NAME and Name =: MEDCOMM_RECORD_TYPE_NAME and IsActive =: true limit 1];
    	return medCommRecordType.id;
    }
	
	public static List<Medical_Communication_gne__c> insertTestMedComms(Set<String> emptyFieldNames, Map<String, Object> testFieldValues) {
		List<Medical_Communication_gne__c> testMedComms = prepareTestMedComms(emptyFieldNames, testFieldValues);
		insert testMedComms;
		return testMedComms;
	}
	
	/* helper method used for preparing test data */
	public static List<Medical_Communication_gne__c> prepareTestMedComms(Set<String> emptyFieldNames, Map<String, Object> testFieldValues) {
		List<Medical_Communication_gne__c> testData = new List<Medical_Communication_gne__c>();
		for(Integer i = 0; i < BATCH_SIZE; i++) {
			Medical_Communication_gne__c medComm = new Medical_Communication_gne__c();
				
			// populate Account_gne__c field
			medComm.Account_gne__c = (Id) getFieldValue('Account_gne__c', emptyFieldNames, testFieldValues);
			// populate RecordTypeId field
			medComm.RecordTypeId = (Id) getFieldValue('RecordTypeId', emptyFieldNames, testFieldValues);
			
			testData.add(medComm);
			
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