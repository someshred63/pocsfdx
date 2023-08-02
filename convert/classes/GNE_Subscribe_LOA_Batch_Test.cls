@isTest
public without sharing class GNE_Subscribe_LOA_Batch_Test {
	
	static testMethod void testValidUpdate() {
		GNE_SFA2_Util.switchAdminMode(true);
		User testUser = prepareEnv();
		
		List<Staging_User_LOA_gne__c> stgObjs = createStagingObjects(20);
		GNE_Subscribe_LOA_Batch batch = runBatch(testUser, stgObjs, false);
		stgObjs = getAllStagingObjects(stgObjs);
		batch.initCache(stgObjs);
		
		for(Staging_User_LOA_gne__c stgObj : stgObjs) {
			User u = (User)batch.getTargetForStagingObject(stgObj);
			assertTargetObject(u, stgObj);
			GNE_Subscribe_Batch_Test_Helper.assertStagingObject(stgObj, GNE_Subscribe_Batch_Base.STATUS_PROCESSED, '');
		}
	}
	
	static testMethod void testInvalidEndDatePriorStartDate() {
		GNE_SFA2_Util.switchAdminMode(true);
		User testUser = prepareEnv();
		
		List<Staging_User_LOA_gne__c> stgObjs = createStagingObjects(2);
		stgObjs[0].LOA_End_Date_gne__c = stgObjs[0].LOA_Start_Date_gne__c.addDays(-1);
		update stgObjs[0];
		DateTime timeStamp = System.now();
		
		GNE_Subscribe_LOA_Batch batch = runBatch(testUser, stgObjs, false);
		stgObjs = getAllStagingObjects(stgObjs);
		batch.initCache(stgObjs);
		
		Integer idx = 0;
		List<User> notChangedUsers = new List<User>();
		for(Staging_User_LOA_gne__c stgObj : stgObjs) {
			User u = (User)batch.getTargetForStagingObject(stgObj);
			
			if(idx==0) {
				GNE_Subscribe_Batch_Test_Helper.assertStagingObject(
					stgObj, GNE_Subscribe_Batch_Base.STATUS_ERROR_PROCESSING, GNE_Subscribe_LOA_Batch.COMMENT_DATES_VALIDATION);
				notChangedUsers.add(u);
			} else {
				assertTargetObject(u, stgObj);
				GNE_Subscribe_Batch_Test_Helper.assertStagingObject(stgObj, GNE_Subscribe_Batch_Base.STATUS_PROCESSED, '');	
			}
			
			idx++;
		}
		
		GNE_Subscribe_Batch_Test_Helper.assertNotChangedRecords(notChangedUsers, timeStamp);
	}
	
	static testMethod void testInvalidUserNotFound() {
		GNE_SFA2_Util.switchAdminMode(true);
		User testUser = prepareEnv();
		
		List<Staging_User_LOA_gne__c> stgObjs = createStagingObjects(2);
		stgObjs[0].User_UnixID_gne__c = 'FAKE_EXT_ID';
		update stgObjs[0];
		DateTime timeStamp = System.now();
		
		GNE_Subscribe_LOA_Batch batch = runBatch(testUser, stgObjs, false);
		stgObjs = getAllStagingObjects(stgObjs);
		batch.initCache(stgObjs);
		
		Integer idx = 0;
		List<User> notChangedUsers = new List<User>();
		for(Staging_User_LOA_gne__c stgObj : stgObjs) {
			User u = (User)batch.getTargetForStagingObject(stgObj);
			
			if(idx==0) {
				GNE_Subscribe_Batch_Test_Helper.assertStagingObject(
					stgObj, GNE_Subscribe_Batch_Base.STATUS_ERROR_PROCESSING, GNE_Subscribe_LOA_Batch.COMMENT_USER_NOT_FOUND);
				System.assertEquals(null, u, 'Target user should be null');
			} else {
				assertTargetObject(u, stgObj);
				GNE_Subscribe_Batch_Test_Helper.assertStagingObject(stgObj, GNE_Subscribe_Batch_Base.STATUS_PROCESSED, '');	
			}
			
			idx++;
		}
		
		GNE_Subscribe_Batch_Test_Helper.assertNotChangedRecords(notChangedUsers, timeStamp);
	}
	
	static testMethod void testPreviewMode() {
		GNE_SFA2_Util.switchAdminMode(true);
		User testUser = prepareEnv();
		
		List<Staging_User_LOA_gne__c> stgObjs = createStagingObjects(2);
		stgObjs[0].LOA_End_Date_gne__c = stgObjs[0].LOA_Start_Date_gne__c.addDays(-1);
		update stgObjs[0];
		DateTime timeStamp = System.now();
		
		GNE_Subscribe_LOA_Batch batch = runBatch(testUser, stgObjs, true);
		stgObjs = getAllStagingObjects(stgObjs);
		batch.initCache(stgObjs);
		
		Integer idx = 0;
		List<User> notChangedUsers = new List<User>();
		for(Staging_User_LOA_gne__c stgObj : stgObjs) {
			User u = (User)batch.getTargetForStagingObject(stgObj);
			notChangedUsers.add(u);
			
			if(idx==0) {
				GNE_Subscribe_Batch_Test_Helper.assertStagingObject(
					stgObj, GNE_Subscribe_Batch_Base.STATUS_LOADED, GNE_Subscribe_LOA_Batch.COMMENT_DATES_VALIDATION);
				GNE_Subscribe_Batch_Test_Helper.assertStagingObject(
					stgObj, GNE_Subscribe_Batch_Base.STATUS_LOADED, GNE_Subscribe_Batch_Base.STATUS_ERROR_PROCESSING);
				
			} else {
				GNE_Subscribe_Batch_Test_Helper.assertStagingObject(stgObj, 
					GNE_Subscribe_Batch_Base.STATUS_LOADED, GNE_Subscribe_Batch_Base.STATUS_PROCESSED);	
			}
			
			idx++;
		}
		
		GNE_Subscribe_Batch_Test_Helper.assertNotChangedRecords(notChangedUsers, timeStamp);
	}
	
	static testMethod void testProcessedRecordNotModified() {
		GNE_SFA2_Util.switchAdminMode(true);
		User testUser = prepareEnv();
		
		List<Staging_User_LOA_gne__c> stgObjs = createStagingObjects(2);
		stgObjs[0].Status_gne__c = GNE_Subscribe_Batch_Base.STATUS_PROCESSED;
		update stgObjs[0];
		
		DateTime timeStamp = System.now();
		
		GNE_Subscribe_LOA_Batch batch = runBatch(testUser, stgObjs, false);
		stgObjs = getAllStagingObjects(stgObjs);
		batch.initCache(stgObjs);
		
		Integer idx = 0;
		List<User> notChangedUsers = new List<User>();
		
		for(Staging_User_LOA_gne__c stgObj : stgObjs) {
			User u = (User)batch.getTargetForStagingObject(stgObj);
			
			if(idx==0) {
				notChangedUsers.add(u);
				GNE_Subscribe_Batch_Test_Helper.assertStagingObject(stgObj, GNE_Subscribe_Batch_Base.STATUS_PROCESSED, 'OLD Comment');
				
			} else {
				GNE_Subscribe_Batch_Test_Helper.assertStagingObject(stgObj, GNE_Subscribe_Batch_Base.STATUS_PROCESSED, '');	
			}
			
			idx++;
		}
		
		GNE_Subscribe_Batch_Test_Helper.assertNotChangedRecords(notChangedUsers, timeStamp);
	}
	
	static testMethod void testLOAHOOverrideFlagReset() {
		GNE_SFA2_Util.switchAdminMode(true);
		User testUser = prepareEnv();
		
		List<Staging_User_LOA_gne__c> stgObjs = createStagingObjects(3);
		String extId1 = stgObjs[0].User_UnixID_gne__c;
		String extId2 = stgObjs[1].User_UnixID_gne__c;
		String extId3 = stgObjs[2].User_UnixID_gne__c;
		User u1 = [SELECT Id FROM User WHERE External_ID_gne__c = :extId1];
		User u2 = [SELECT Id FROM User WHERE External_ID_gne__c = :extId2];
		User u3 = [SELECT Id FROM User WHERE External_ID_gne__c = :extId3];
		u1.LOA_HO_Override_Flag_gne__c = GNE_SFA2_PFG_Util.USER_LOA_HO_OVERRIDE_FLAG_TRUE;
		u2.LOA_HO_Override_Flag_gne__c = GNE_SFA2_PFG_Util.USER_LOA_HO_OVERRIDE_FLAG_FALSE;
		u3.LOA_HO_Override_Flag_gne__c = GNE_SFA2_PFG_Util.USER_LOA_HO_OVERRIDE_FLAG_TRUE;
		u3.LOA_Start_Date_gne__c = stgObjs[2].LOA_Start_Date_gne__c;
		u3.LOA_End_Date_gne__c = stgObjs[2].LOA_End_Date_gne__c;
		update (new List<User>{u1,u2, u3});
		
		DateTime timeStamp = System.now();
		
		GNE_Subscribe_LOA_Batch batch = runBatch(testUser, stgObjs, false);
		stgObjs = getAllStagingObjects(stgObjs);
		batch.initCache(stgObjs);
		
		Set<Id> userIds = new Set<Id>();
		for(Staging_User_LOA_gne__c stgObj : stgObjs) {
			User u = (User)batch.getTargetForStagingObject(stgObj);
			userIds.add(u.Id);
			assertTargetObject(u, stgObj);
			GNE_Subscribe_Batch_Test_Helper.assertStagingObject(stgObj, GNE_Subscribe_Batch_Base.STATUS_PROCESSED, '');	
		}
		
		Integer usersWithHOFlagNACount = [
			SELECT count() FROM User 
			WHERE External_Id_gne__c IN (:extId1,:extId2) 
				AND LOA_HO_Override_Flag_gne__c = :GNE_SFA2_PFG_Util.USER_LOA_HO_OVERRIDE_FLAG_NA];
		System.assertEquals(0, usersWithHOFlagNACount, 'LOA Home Office Override Flag should be set to \'NA\'');
		
		Integer usersWithHOFlagTrueCount = [
			SELECT count() FROM User 
			WHERE External_Id_gne__c IN (:extId3) 
				AND LOA_HO_Override_Flag_gne__c = :GNE_SFA2_PFG_Util.USER_LOA_HO_OVERRIDE_FLAG_TRUE];
		System.assertEquals(1, usersWithHOFlagTrueCount, 'LOA Home Office Override Flag shouldn\'t be set to \'NA\'');
	}
	
	private static User prepareEnv() {
		return GNE_Subscribe_Batch_Test_Helper.prepareEnv();
	}
	
	private static GNE_Subscribe_LOA_Batch runBatch(User asUser, List<Staging_User_LOA_gne__c> stgObjs, Boolean previewMode) {
		GNE_Subscribe_LOA_Batch batch = new GNE_Subscribe_LOA_Batch(previewMode);
		batch.execute(null,getStagingObjectsForProcess(stgObjs));
		batch.finish(null);
		//GNE_Subscribe_Batch_Test_Helper.runBatch(batch, asUser, 20);
		return batch;
	}
	
	private static List<Staging_User_LOA_gne__c> getStagingObjectsForProcess(List<Staging_User_LOA_gne__c> stgObjs) {
		Set<Id> stgIds = (new Map<Id,Staging_User_LOA_gne__c>(stgObjs)).keySet();
		
		GNE_Subscribe_LOA_Batch batch = new GNE_Subscribe_LOA_Batch(false);
		Database.QueryLocator queryLocator = batch.start(null);
		String tmpVar1 = GNE_Subscribe_Batch_Base.STATUS_LOADED;
		return Database.query(queryLocator.getQuery() + ' AND ID IN :stgIds');
	}
	
	private static List<Staging_User_LOA_gne__c> getAllStagingObjects(List<Staging_User_LOA_gne__c> stgObjs) {
		Set<Id> stgIds = (new Map<Id,Staging_User_LOA_gne__c>(stgObjs)).keySet();
		return [
			SELECT 
        		Id, 
        		Comment_gne__c, 
        		LOA_End_Date_gne__c, 
        		LOA_Start_Date_gne__c, 
        		Status_gne__c, 
        		User_UnixID_gne__c
        	FROM Staging_User_LOA_gne__c
        	WHERE Id IN :stgIds];
	}
	
	private static List<Staging_User_LOA_gne__c> createStagingObjects(Integer numberOfUsers) {
		List<User> users = [
			SELECT 
        		Id, 
        		LOA_Start_Date_gne__c, 
        		LOA_End_Date_gne__c, 
        		External_ID_gne__c
        	FROM User
        	WHERE IsActive = true AND External_ID_gne__c!=null AND Profile.Name = 'GNE-FIELD'
        	ORDER BY LastLoginDate desc
        	LIMIT :numberOfUsers];
        	
        List<Staging_User_LOA_gne__c> stgObjs = new List<Staging_User_LOA_gne__c>();
        
        Integer idx = 0;
        for(User u : users) {
        	stgObjs.add(new Staging_User_LOA_gne__c(
        		User_UnixID_gne__c = u.External_ID_gne__c,
        		LOA_Start_Date_gne__c = System.today().addDays(-idx),
        		LOA_End_Date_gne__c = System.today().addDays(idx),
        		LOA_Status_gne__c = 'ROSTER ACTIVE EMPLOYEE',
        		Comment_gne__c = 'OLD Comment',
        		Status_gne__c = GNE_Subscribe_Batch_Base.STATUS_LOADED));
        }
        
        insert stgObjs;
        return stgObjs; 
	}
	
	private static void assertTargetObject(User targetObj, Staging_User_LOA_gne__c stgObj) {
		System.assertEquals(stgObj.LOA_Start_Date_gne__c, targetObj.LOA_Start_Date_gne__c, 'LOA Start Date is different');
		System.assertEquals(stgObj.LOA_End_Date_gne__c, targetObj.LOA_End_Date_gne__c, 'LOA End Date is different');
	}
}