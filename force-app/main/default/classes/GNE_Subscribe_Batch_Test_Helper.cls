@isTest
public without sharing class GNE_Subscribe_Batch_Test_Helper {
	public static User prepareEnv() {
		String profileName = 'GNE-SYS-Support';
		User u = createTestUser(profileName);
		System.assertNotEquals(null,u, 'Test user not found');
		return u;
	}
	
	public static User createTestUser(String profileName) {
		User result = null;
		
		for(User u : [SELECT Id FROM User WHERE Profile.Name = :profileName AND IsActive = true LIMIT 1]) {
			result = u;
		}
		
		return result;
	}
	
	public static void runBatch(Database.Batchable<sObject> batch, User asUser, Integer batchSize) {
		System.runAs(asUser) {
	    	Test.startTest();
	    	Database.executeBatch(batch,batchSize);
	    	Test.stopTest();
	    }
	}
	
	public static void assertStagingObject(SObject stgObj, String expectedStatus) {
		assertStagingObject(stgObj, expectedStatus, null);
	}
	
	public static void assertStagingObject(SObject stgObj, String expectedStatus, String expectedCommentPart) {
		String status = (String)stgObj.get(GNE_Subscribe_Batch_Base.STATUS_FIELD_API_NAME);
	    
		System.assertEquals(expectedStatus, status, 'Wrong staging status');
		if(expectedCommentPart!=null) {
			String comment = (String)stgObj.get(GNE_Subscribe_Batch_Base.COMMENT_FIELD_API_NAME);
	    	comment = comment!=null ? comment : '';
			System.assert(comment.contains(expectedCommentPart), 'Comment doesn\'t contain \'' + expectedCommentPart + '\'');
		}
	}
	
	public static void assertNotChangedRecords(List<SObject> objs, DateTime timeStamp) {
		if(!objs.isEmpty()) {
			Set<Id> objIds = (new Map<Id,SObject>(objs)).keySet();
			String objApiName = objs[0].getSObjectType().getDescribe().getName();
			System.assertEquals(0, Database.query('SELECT Id FROM ' + objApiName + ' WHERE Id IN :objIds AND LastModifiedDate >= :timeStamp').size(),
				objApiName + ' shouldn\'t be modified');
		}
	}
}