@isTest
public without sharing class GNE_Subscribe_Brand_2_Salesforce_Test {
	
	private static final String BRAND_CODE = 'AVS';
	private static final String SALESFORCE_CODE = 'AVS';
	private static final String SALESFORCE_SUBTEAM_CODE = 'AVS';
	private static final String SALESFORCE_NAME = 'AVS';
	private static final String SALESFORCE_SUBTEAM_NAME = 'AVASTIN';
	private static final String BRAND_NAME = 'AVASTIN';
	
	static testMethod void testValidInsert() {
		User testUser = prepareEnv();
		List<Staging_Brand_2_Salesforce_gne__c> stgObjs = createStagingObjects(10,0);
		
		GNE_Subscribe_Brand_2_Salesforce batch = runBatch(testUser, false);
		stgObjs = getAllStagingObjects(stgObjs);
		batch.initCache(stgObjs);
		
		for(Staging_Brand_2_Salesforce_gne__c stgObj : stgObjs) {
			Brand_2_Salesforce_gne__c b2s = (Brand_2_Salesforce_gne__c)batch.getTargetForStagingObject(stgObj);
			assertTargetObject(b2s, stgObj);
			GNE_Subscribe_Batch_Test_Helper.assertStagingObject(stgObj, GNE_Subscribe_Batch_Base.STATUS_PROCESSED, '');
		}
	}
	
	static testMethod void testValidUpdate() {
		User testUser = prepareEnv();
		List<Staging_Brand_2_Salesforce_gne__c> stgObjs = createStagingObjectsWithTargets(10);
		
		GNE_Subscribe_Brand_2_Salesforce batch = runBatch(testUser, false);
		stgObjs = getAllStagingObjects(stgObjs);
		batch.initCache(stgObjs);
		
		for(Staging_Brand_2_Salesforce_gne__c stgObj : stgObjs) {
			Brand_2_Salesforce_gne__c b2s = (Brand_2_Salesforce_gne__c)batch.getTargetForStagingObject(stgObj);
			assertTargetObject(b2s, stgObj);
			GNE_Subscribe_Batch_Test_Helper.assertStagingObject(stgObj, GNE_Subscribe_Batch_Base.STATUS_PROCESSED, '');
		}
	}
	
	static testMethod void testValidUpsert() {
		User testUser = prepareEnv();
		List<Staging_Brand_2_Salesforce_gne__c> stgObjs = createStagingObjectsWithTargets(10);
		stgObjs.addAll(createStagingObjects(10,10));
		GNE_Subscribe_Brand_2_Salesforce batch = runBatch(testUser, false);
		stgObjs = getAllStagingObjects(stgObjs);
		batch.initCache(stgObjs);
		
		for(Staging_Brand_2_Salesforce_gne__c stgObj : stgObjs) {
			Brand_2_Salesforce_gne__c b2s = (Brand_2_Salesforce_gne__c)batch.getTargetForStagingObject(stgObj);
			assertTargetObject(b2s, stgObj);
			GNE_Subscribe_Batch_Test_Helper.assertStagingObject(stgObj, GNE_Subscribe_Batch_Base.STATUS_PROCESSED, '');
		}
	}
	
	static testMethod void testPreviewMode() {
		User testUser = prepareEnv();
		List<Staging_Brand_2_Salesforce_gne__c> stgObjs = createStagingObjects(10,0);
		
		GNE_Subscribe_Brand_2_Salesforce batch = runBatch(testUser, true);
		stgObjs = getAllStagingObjects(stgObjs);
		batch.initCache(stgObjs);
		
		for(Staging_Brand_2_Salesforce_gne__c stgObj : stgObjs) {
			Brand_2_Salesforce_gne__c b2s = (Brand_2_Salesforce_gne__c)batch.getTargetForStagingObject(stgObj);
			System.assertEquals(null, b2s, 'Brand to Salesforce cannot be inserted');
			GNE_Subscribe_Batch_Test_Helper.assertStagingObject(stgObj, GNE_Subscribe_Batch_Base.STATUS_LOADED, GNE_Subscribe_Batch_Base.STATUS_PROCESSED);
		}
	}
	
	static testMethod void testProcessedNotIncluded() {
		User testUser = prepareEnv();
		List<Staging_Brand_2_Salesforce_gne__c> stgObjs = createStagingObjectsWithTargets(10);
		stgObjs[0].Status_gne__c = GNE_Subscribe_Batch_Base.STATUS_PROCESSED;
		update stgObjs[0];
		 
		GNE_Subscribe_Brand_2_Salesforce batch = runBatch(testUser, false);
		stgObjs = getAllStagingObjects(stgObjs);
		batch.initCache(stgObjs);
		Integer idx = 0;
		for(Staging_Brand_2_Salesforce_gne__c stgObj : stgObjs) {
			Brand_2_Salesforce_gne__c b2s = (Brand_2_Salesforce_gne__c)batch.getTargetForStagingObject(stgObj);
			
			if(idx==0) {
				GNE_Subscribe_Batch_Test_Helper.assertStagingObject(stgObj, GNE_Subscribe_Batch_Base.STATUS_PROCESSED, 'OLD Comment');	
			} else {
				assertTargetObject(b2s, stgObj);
				GNE_Subscribe_Batch_Test_Helper.assertStagingObject(stgObj, GNE_Subscribe_Batch_Base.STATUS_PROCESSED, '');
			}
			
			idx++;
		}
	}
	
	private static User prepareEnv() {
		return GNE_Subscribe_Batch_Test_Helper.prepareEnv();
	}
	
	private static GNE_Subscribe_Brand_2_Salesforce runBatch(User asUser, Boolean previewMode) {
		GNE_Subscribe_Brand_2_Salesforce batch = new GNE_Subscribe_Brand_2_Salesforce(previewMode);
		GNE_Subscribe_Batch_Test_Helper.runBatch(batch, asUser, 20);
		return batch;
	}
	
	private static List<Staging_Brand_2_Salesforce_gne__c> getStagingObjectsForProcess(List<Staging_Brand_2_Salesforce_gne__c> stgObjs) {
		Set<Id> stgIds = (new Map<Id,Staging_Brand_2_Salesforce_gne__c>(stgObjs)).keySet();
		
		GNE_Subscribe_Brand_2_Salesforce batch = new GNE_Subscribe_Brand_2_Salesforce(false);
		Database.QueryLocator queryLocator = batch.start(null);
		String tmpVar1 = GNE_Subscribe_Batch_Base.STATUS_LOADED;
		return Database.query(queryLocator.getQuery() + ' AND ID IN :stgIds');
	}
	
	private static List<Staging_Brand_2_Salesforce_gne__c> getAllStagingObjects(List<Staging_Brand_2_Salesforce_gne__c> stgObjs) {
		Set<Id> stgIds = (new Map<Id,Staging_Brand_2_Salesforce_gne__c>(stgObjs)).keySet();
		return [
			SELECT 
		 		CDM_Brand_Code_gne__c, 
		 		Comment_gne__c, 
		 		External_Id_gne__c, 
		 		Salesforce_Code_gne__c,
		 		Salesforce_Name_gne__c, 
		 		Salesforce_SubTeam_Code_gne__c, 
		 		Salesforce_SubTeam_Name_gne__c,
		 		SFA_Brand_Name_gne__c, 
		 		Status_gne__c
		 	FROM Staging_Brand_2_Salesforce_gne__c
        	WHERE Id IN :stgIds];
	}
	
	private static List<Staging_Brand_2_Salesforce_gne__c> createStagingObjectsWithTargets(Integer numberOfRecords) {
		List<GNE_Foun_Brand_Map_gne__c> configObjs = new List<GNE_Foun_Brand_Map_gne__c>();
		GNE_Foun_Brand_Map_gne__c configTemplate = new GNE_Foun_Brand_Map_gne__c(
			Is_Active_gne__c = true, Comments_gne__c = 'N/A');
			
		List<Brand_2_Salesforce_gne__c> targetObjs = new List<Brand_2_Salesforce_gne__c>();
		
		for(Integer i=0; i<numberOfRecords; i++) {
			Brand_2_Salesforce_gne__c b2S = new Brand_2_Salesforce_gne__c(
        		CDM_Brand_Code_gne__c = (BRAND_CODE + (i+1)),
        		CDM_Salesforce_Code_gne__c = SALESFORCE_CODE,
        		CDM_Salesforce_SubTeam_Code_gne__c = SALESFORCE_SUBTEAM_CODE,
        		Salesforce_Name_gne__c = SALESFORCE_NAME,
        		Salesforce_SubTeam_Name_gne__c = SALESFORCE_SUBTEAM_NAME,
        		SFA_Brand_Name_gne__c = (BRAND_NAME + (i+1)));
        		
        	b2S.External_Id_gne__c = b2S.CDM_Salesforce_Code_gne__c  + '_' + b2S.CDM_Salesforce_SubTeam_Code_gne__c  + '_' + b2S.CDM_Brand_Code_gne__c;
                                                       
            targetObjs.add(b2S);
        }
        	
        List<Staging_Brand_2_Salesforce_gne__c> stgObjs = new List<Staging_Brand_2_Salesforce_gne__c>();
        
        Integer idx = 0;
        for(Brand_2_Salesforce_gne__c b2S : targetObjs) {
        	Staging_Brand_2_Salesforce_gne__c stgB2S = new Staging_Brand_2_Salesforce_gne__c(
        		CDM_Brand_Code_gne__c = b2S.CDM_Brand_Code_gne__c,
        		Salesforce_Code_gne__c = b2S.CDM_Salesforce_Code_gne__c,
        		Salesforce_SubTeam_Code_gne__c = b2S.CDM_Salesforce_SubTeam_Code_gne__c,
        		Salesforce_Name_gne__c = b2S.Salesforce_Name_gne__c,
        		Salesforce_SubTeam_Name_gne__c = b2S.Salesforce_SubTeam_Name_gne__c + 'NEW',
        		SFA_Brand_Name_gne__c = b2S.SFA_Brand_Name_gne__c + '_NEW',
        		Comment_gne__c = 'OLD Comment',
        		Status_gne__c = GNE_Subscribe_Batch_Base.STATUS_LOADED);
        	
        	stgObjs.add(stgB2S);
        	GNE_Foun_Brand_Map_gne__c configRec = configTemplate.clone();
        	configRec.Name = stgB2S.CDM_Brand_Code_gne__c;
        	configRec.SFA_Brand_Name_gne__c = stgB2S.SFA_Brand_Name_gne__c;
        	configObjs.add(configRec);
        }
        
        insert configObjs;
        insert targetObjs;
        insert stgObjs;
        return stgObjs; 
	}
	
	private static List<Staging_Brand_2_Salesforce_gne__c> createStagingObjects(Integer numberOfRecords, Integer startNumber) {
		List<GNE_Foun_Brand_Map_gne__c> configObjs = new List<GNE_Foun_Brand_Map_gne__c>();
		GNE_Foun_Brand_Map_gne__c configTemplate = new GNE_Foun_Brand_Map_gne__c(
			Is_Active_gne__c = true, Comments_gne__c = 'N/A');
			
		List<Staging_Brand_2_Salesforce_gne__c> stgObjs = new List<Staging_Brand_2_Salesforce_gne__c>();
		
		for(Integer i=0; i<numberOfRecords; i++) {
			Staging_Brand_2_Salesforce_gne__c stgB2S = new Staging_Brand_2_Salesforce_gne__c(
        		CDM_Brand_Code_gne__c = (BRAND_CODE + (startNumber+i+1)),
        		Salesforce_Code_gne__c = SALESFORCE_CODE,
        		Salesforce_SubTeam_Code_gne__c = SALESFORCE_SUBTEAM_CODE,
        		Salesforce_Name_gne__c = SALESFORCE_NAME,
        		Salesforce_SubTeam_Name_gne__c = SALESFORCE_SUBTEAM_NAME,
        		SFA_Brand_Name_gne__c = (BRAND_NAME + (startNumber+i+1)),
        		
        		Comment_gne__c = 'OLD Comment',
        		Status_gne__c = GNE_Subscribe_Batch_Base.STATUS_LOADED);
        		
        	stgObjs.add(stgB2S);
        	
        	GNE_Foun_Brand_Map_gne__c configRec = configTemplate.clone();
        	configRec.Name = stgB2S.CDM_Brand_Code_gne__c;
        	configRec.SFA_Brand_Name_gne__c = stgB2S.SFA_Brand_Name_gne__c;
        	configObjs.add(configRec);
        }
        
        insert configObjs;
        insert stgObjs;
        return stgObjs; 
	}
	
	private static void assertTargetObject(Brand_2_Salesforce_gne__c targetObj, Staging_Brand_2_Salesforce_gne__c stgObj) {
		System.assertEquals(stgObj.CDM_Brand_Code_gne__c, targetObj.CDM_Brand_Code_gne__c, 'Brand Code is different');
		System.assertEquals(stgObj.Salesforce_Code_gne__c, targetObj.CDM_Salesforce_Code_gne__c, 'Salesforce Code is different');
		System.assertEquals(stgObj.Salesforce_SubTeam_Code_gne__c, targetObj.CDM_Salesforce_SubTeam_Code_gne__c, 'Salesforce SubTeam Code is different');
		System.assertEquals(stgObj.Salesforce_Name_gne__c, targetObj.Salesforce_Name_gne__c, 'Salesforce Name is different');
		System.assertEquals(stgObj.Salesforce_SubTeam_Name_gne__c, targetObj.Salesforce_SubTeam_Name_gne__c, 'Salesforce SubTeam Name is different');
		System.assertEquals(stgObj.SFA_Brand_Name_gne__c, targetObj.SFA_Brand_Name_gne__c, 'Brand Name is different');
	}
}