@isTest
public class CORE_Merge_Triggers_Test {
    @testSetup
    private static void init() {
        CORE_Merge_Test_Util.configureUser();
    }
    
    private static testMethod void testUpsertMergeObject() {
        Test.startTest();
        List<CORE_Merge_Object__c> mobjs = CORE_Merge_Test_Util.prepareMergeObjects().values();
        Database.UpsertResult[] dmlResults = Database.upsert(mobjs,CORE_Merge_Object__c.External_Id_gne__c, false);
        Test.stopTest();
        
        assertUpsertDml(dmlResults, true, 'Update of Merge Objects should not fail!');
    }
    
    private static testMethod void testBlockDeleteMergeObject() {
        List<CORE_Merge_Object__c> mobjs = CORE_Merge_Test_Util.prepareMergeObjects().values();
        
        Test.startTest();
        Database.DeleteResult[] delResults = Database.delete(mobjs, false);
        Test.stopTest();
        
        assertDeleteDml(delResults, false, 'Deleting of Merge Object should be blocked!');
    }
    
    private static testMethod void testDeleteMergeObject() {
        List<CORE_Merge_Object__c> mobjs = CORE_Merge_Test_Util.prepareMergeObjects().values();
        
        Test.startTest();
        CORE_Merge_Util.setInTrigger(CORE_Merge_Object__c.sObjectType, true);
        Database.DeleteResult[] delResults = Database.delete(mobjs, false);
        CORE_Merge_Util.setInTrigger(CORE_Merge_Object__c.sObjectType, false);
        Test.stopTest();
        
        assertDeleteDml(delResults, true, 'Deleting of Merge Object should not fail in Admin Mode!');
    }
    
    private static testMethod void testUpsertMergeConfiguration() {
        Map<String,CORE_Merge_Object__c> mobjsMap = CORE_Merge_Test_Util.prepareMergeObjects();
        Test.startTest();
        List<CORE_Merge_Configuration__c> mConfigs = CORE_Merge_Test_Util.prepareMergeConfiguration(mobjsMap);
        Database.UpsertResult[] dmlResults = Database.upsert(mConfigs,CORE_Merge_Configuration__c.External_Id_gne__c, false);
        Test.stopTest();
        
        assertUpsertDml(dmlResults, true, 'Update of Merge Configuration should not fail!');
    }
    
    private static testMethod void testDeleteMergeConfiguration() {
        CORE_Merge_Test_Util.prepareMergeConfiguration(CORE_Merge_Test_Util.prepareMergeObjects());
        List<CORE_Merge_Object__c> mobjs = CORE_Merge_Test_Util.prepareMergeObjects().values();
        
        Test.startTest();
        CORE_Merge_Util.setInTrigger(CORE_Merge_Object__c.sObjectType, true);
        Database.DeleteResult[] delResults = Database.delete(mobjs, false);
        CORE_Merge_Util.setInTrigger(CORE_Merge_Object__c.sObjectType, false);
        Test.stopTest();
        
        assertDeleteDml(delResults, true, 'Deleting of Merge Object should not fail in Admin Mode!');
    }
    
    private static testMethod void testUpsertMergeCandidates() {
        CORE_Merge_Test_Util.prepareMergeConfiguration(CORE_Merge_Test_Util.prepareMergeObjects());
        
        Test.startTest();
        List<CORE_Merge_Candidate__c> mcs = CORE_Merge_Test_Util.prepareDuplicateData();
        Database.UpsertResult[] dmlResults = Database.upsert(mcs,CORE_Merge_Candidate__c.External_Id_gne__c, false);
        Test.stopTest();
        
        assertUpsertDml(dmlResults, true, 'Update of Merge Candidates should not fail!');
    }
    
    private static testMethod void testBlockDeleteMergeCandidates() {
        CORE_Merge_Test_Util.prepareMergeConfiguration(CORE_Merge_Test_Util.prepareMergeObjects());
        List<CORE_Merge_Candidate__c> mcs = CORE_Merge_Test_Util.prepareDuplicateData();
        
        for(CORE_Merge_Candidate__c mc : mcs) {
            mc.Status_gne__c = 'Processed';
        }
        
        update mcs;
        
        Test.startTest();
        Database.DeleteResult[] delResults = Database.delete(mcs, false);
        Test.stopTest();
        
        assertDeleteDml(delResults, false, 'Deleting of Processed Merge Candidate should be blocked!');
    }
    
    private static testMethod void testDeleteMergeCandidates() {
        CORE_Merge_Test_Util.prepareMergeConfiguration(CORE_Merge_Test_Util.prepareMergeObjects());
        List<CORE_Merge_Candidate__c> mcs = CORE_Merge_Test_Util.prepareDuplicateData();
        
        for(CORE_Merge_Candidate__c mc : mcs) {
            mc.Status_gne__c = 'Processed';
        }
        
        update mcs;
        
        Test.startTest();
        CORE_Merge_Util.setInTrigger(CORE_Merge_Candidate__c.sObjectType, true);
        Database.DeleteResult[] delResults = Database.delete(mcs, false);
        CORE_Merge_Util.setInTrigger(CORE_Merge_Candidate__c.sObjectType, false);
        Test.stopTest();
        
        assertDeleteDml(delResults, true, 'Deleting of Processed Merge Candidate should not fail in Admin Mode!');
    }
    
    private static testMethod void testDeleteLoadedMergeCandidates() {
        CORE_Merge_Test_Util.prepareMergeConfiguration(CORE_Merge_Test_Util.prepareMergeObjects());
        List<CORE_Merge_Candidate__c> mcs = CORE_Merge_Test_Util.prepareDuplicateData();
        
        Test.startTest();
        Database.DeleteResult[] delResults = Database.delete(mcs, false);
        Test.stopTest();
        
        assertDeleteDml(delResults, true, 'Deleting of Loaded Merge Candidate should not fail!');
    }
    
    private static testMethod void testUpsertMergeJobs() {
        Map<String,CORE_Merge_Object__c> mObjsMap = CORE_Merge_Test_Util.prepareMergeObjects();
        
        Test.startTest();
        List<CORE_Merge_Job__c> mcJobs = CORE_Merge_Test_Util.prepareMergeJobs(mObjsMap);
        Database.SaveResult[] dmlResults = Database.update(mcJobs, false);
        Test.stopTest();
        
        assertSaveDml(dmlResults, true, 'Updating Merge Jobs should not fail!');
    }
    
    private static testMethod void testBlockDeleteMergeJobs() {
        List<CORE_Merge_Job__c> mcJobs = CORE_Merge_Test_Util.prepareMergeJobs(CORE_Merge_Test_Util.prepareMergeObjects());
        
        Test.startTest();
        Database.DeleteResult[] delResults = Database.delete(mcJobs, false);
        Test.stopTest();
        
        assertDeleteDml(delResults, false, 'Deleting of Merge Job should be blocked!');
    }
    
    private static testMethod void testDeleteMergeJobs() {
        List<CORE_Merge_Job__c> mcJobs = CORE_Merge_Test_Util.prepareMergeJobs(CORE_Merge_Test_Util.prepareMergeObjects());
        
        Test.startTest();
        CORE_Merge_Util.setInTrigger(CORE_Merge_Job__c.sObjectType, true);
        Database.DeleteResult[] delResults = Database.delete(mcJobs, false);
        CORE_Merge_Util.setInTrigger(CORE_Merge_Job__c.sObjectType, false);
        Test.stopTest();
        
        assertDeleteDml(delResults, true, 'Deleting of Merge Job should not fail in Admin Mode!');
    }
    
    private static testMethod void testUpsertMergeErrors() {
        Map<String,CORE_Merge_Object__c> mObjsMap = CORE_Merge_Test_Util.prepareMergeObjects();
        
        Test.startTest();
        List<CORE_Merge_Error__c> mcErrors = CORE_Merge_Test_Util.prepareMergeErrors(mObjsMap);
        Database.SaveResult[] dmlResults = Database.update(mcErrors, false);
        Test.stopTest();
        
        assertSaveDml(dmlResults, true, 'Updating Merge Error should not fail!');
    }
    
    private static testMethod void testDeleteMergeErrors() {
        List<CORE_Merge_Error__c> mcErrors = CORE_Merge_Test_Util.prepareMergeErrors(CORE_Merge_Test_Util.prepareMergeObjects());
        
        Test.startTest();
        Database.DeleteResult[] delResults = Database.delete(mcErrors, false);
        Test.stopTest();
        
        assertDeleteDml(delResults, true, 'Deleting of Merge Error should not fail!');
    }
    
    private static testMethod void testInsertArchiveData() {
        CORE_Merge_Test_Util.prepareMergeConfiguration(CORE_Merge_Test_Util.prepareMergeObjects());
        List<CORE_Merge_Candidate__c> mcs = CORE_Merge_Test_Util.prepareDuplicateData();
        Map<String,List<SObject>> archiveRecsMap = CORE_Merge_Test_Util.prepareArchiveData();
        
        Test.startTest();
        Database.SaveResult[] dmlResults = Database.insert(archiveRecsMap.get(String.valueOf(CORE_Merge_Archive_Record__c.sObjectType)),true);
        assertSaveDml(dmlResults, true, 'Inserting of Merge Archive Records should not fail!');
        dmlResults = Database.insert(archiveRecsMap.get(String.valueOf(CORE_Merge_Archive_App_Record__c.sObjectType)),false);
        assertSaveDml(dmlResults, true, 'Inserting of Merge Archive App Records should not fail!');
        dmlResults = Database.insert(archiveRecsMap.get(String.valueOf(CORE_Merge_Archive_Child_Record__c.sObjectType)),false);
        assertSaveDml(dmlResults, true, 'Inserting of Merge Archive Child Records should not fail!');
        dmlResults = Database.insert(archiveRecsMap.get(String.valueOf(CORE_Merge_Archive_JSON_Part__c.sObjectType)),false);
        assertSaveDml(dmlResults, true, 'Inserting of Merge Archive JSON Parts should not fail!');
        Test.stopTest();
    }
    
    private static testMethod void testBlockDeleteArchiveData() {
        CORE_Merge_Test_Util.prepareMergeConfiguration(CORE_Merge_Test_Util.prepareMergeObjects());
        List<CORE_Merge_Candidate__c> mcs = CORE_Merge_Test_Util.prepareDuplicateData();
        Map<String,List<SObject>> archiveRecsMap = CORE_Merge_Test_Util.prepareArchiveData();
        Database.insert(archiveRecsMap.get(String.valueOf(CORE_Merge_Archive_Record__c.sObjectType)),false);
        Database.insert(archiveRecsMap.get(String.valueOf(CORE_Merge_Archive_App_Record__c.sObjectType)),false);
        Database.insert(archiveRecsMap.get(String.valueOf(CORE_Merge_Archive_Child_Record__c.sObjectType)),false);
        Database.insert(archiveRecsMap.get(String.valueOf(CORE_Merge_Archive_JSON_Part__c.sObjectType)),false);
        
        Test.startTest();
        Database.DeleteResult[] dmlResults = Database.delete(archiveRecsMap.get(String.valueOf(CORE_Merge_Archive_JSON_Part__c.sObjectType)),false);
        assertDeleteDml(dmlResults, false, 'Deleting  of Merge Archive JSON Parts should be blocked!');
        
        dmlResults = Database.delete(archiveRecsMap.get(String.valueOf(CORE_Merge_Archive_Child_Record__c.sObjectType)),false);
        assertDeleteDml(dmlResults, false, 'Deleting  of Merge Archive Child Records should be blocked!');
        
        dmlResults = Database.delete(archiveRecsMap.get(String.valueOf(CORE_Merge_Archive_App_Record__c.sObjectType)),false);
        assertDeleteDml(dmlResults, false, 'Deleting  of Merge Archive App Records should be blocked!');
        
        dmlResults = Database.delete(archiveRecsMap.get(String.valueOf(CORE_Merge_Archive_Record__c.sObjectType)),false);
        assertDeleteDml(dmlResults, false, 'Deleting  of Merge Archive Records should be blocked!');
        Test.stopTest();
    }
    
    private static testMethod void testDeleteArchiveData() {
        CORE_Merge_Test_Util.prepareMergeConfiguration(CORE_Merge_Test_Util.prepareMergeObjects());
        List<CORE_Merge_Candidate__c> mcs = CORE_Merge_Test_Util.prepareDuplicateData();
        Map<String,List<SObject>> archiveRecsMap = CORE_Merge_Test_Util.prepareArchiveData();
        Database.insert(archiveRecsMap.get(String.valueOf(CORE_Merge_Archive_Record__c.sObjectType)),false);
        Database.insert(archiveRecsMap.get(String.valueOf(CORE_Merge_Archive_App_Record__c.sObjectType)),false);
        Database.insert(archiveRecsMap.get(String.valueOf(CORE_Merge_Archive_Child_Record__c.sObjectType)),false);
        Database.insert(archiveRecsMap.get(String.valueOf(CORE_Merge_Archive_JSON_Part__c.sObjectType)),false);
        
        Test.startTest();
        CORE_Merge_Util.setInTrigger(CORE_Merge_Archive_JSON_Part__c.sObjectType, true);
        Database.DeleteResult[] dmlResults = Database.delete(archiveRecsMap.get(String.valueOf(CORE_Merge_Archive_JSON_Part__c.sObjectType)),false);
        assertDeleteDml(dmlResults, true, 'Deleting  of Merge Archive JSON Parts should not fail in Admin Mode!');
        CORE_Merge_Util.setInTrigger(CORE_Merge_Archive_JSON_Part__c.sObjectType, false);
        
        CORE_Merge_Util.setInTrigger(CORE_Merge_Archive_Child_Record__c.sObjectType, true);
        dmlResults = Database.delete(archiveRecsMap.get(String.valueOf(CORE_Merge_Archive_Child_Record__c.sObjectType)),false);
        assertDeleteDml(dmlResults, true, 'Deleting  of Merge Archive Child Records should not fail in Admin Mode!');
        CORE_Merge_Util.setInTrigger(CORE_Merge_Archive_Child_Record__c.sObjectType, false);
        
        CORE_Merge_Util.setInTrigger(CORE_Merge_Archive_App_Record__c.sObjectType, true);
        dmlResults = Database.delete(archiveRecsMap.get(String.valueOf(CORE_Merge_Archive_App_Record__c.sObjectType)),false);
        assertDeleteDml(dmlResults, true, 'Deleting  of Merge Archive App Records should not fail in Admin Mode!');
        CORE_Merge_Util.setInTrigger(CORE_Merge_Archive_App_Record__c.sObjectType, false);
        
        CORE_Merge_Util.setInTrigger(CORE_Merge_Archive_Record__c.sObjectType, true);
        dmlResults = Database.delete(archiveRecsMap.get(String.valueOf(CORE_Merge_Archive_Record__c.sObjectType)),false);
        assertDeleteDml(dmlResults, true, 'Deleting  of Merge Archive Records should not fail in Admin Mode!');
        CORE_Merge_Util.setInTrigger(CORE_Merge_Archive_Record__c.sObjectType, false);
        Test.stopTest();
    }
    
    private static void assertDeleteDml(Database.DeleteResult[] dmlResults, Boolean shouldBeSuccess, String errorMsg) {
        for(Database.DeleteResult dmlResult : dmlResults) {
            String dmlErrorMsg =  shouldBeSuccess && !dmlResult.isSuccess() ? (', DML Error: ' + dmlResult.getErrors()[0].getMessage()) : '';
            System.assert(dmlResult.isSuccess()==shouldBeSuccess, errorMsg + dmlErrorMsg);
        }
    }
    
    private static void assertUpsertDml(Database.UpsertResult[] dmlResults, Boolean shouldBeSuccess, String errorMsg) {
        for(Database.UpsertResult dmlResult : dmlResults) {
            String dmlErrorMsg =  shouldBeSuccess && !dmlResult.isSuccess() ? (', DML Error: ' + dmlResult.getErrors()[0].getMessage()) : '';
            System.assert(dmlResult.isSuccess()==shouldBeSuccess, errorMsg + dmlErrorMsg);
        }
    }
    
    private static void assertSaveDml(Database.SaveResult[] dmlResults, Boolean shouldBeSuccess, String errorMsg) {
        for(Database.SaveResult dmlResult : dmlResults) {
            String dmlErrorMsg =  shouldBeSuccess && !dmlResult.isSuccess() ? (', DML Error: ' + dmlResult.getErrors()[0].getMessage()) : '';
            System.assert(dmlResult.isSuccess()==shouldBeSuccess, errorMsg + dmlErrorMsg);
        }
    }
}