@isTest
public class CORE_Merge_Engine_Test {
    @testSetup
    private static void init() {
        CORE_Merge_Test_Util.configureUser();
    }
    
    private static testMethod void testReadConfiguration() {
        Map<String, CORE_Merge_Object__c> mObjsMap = CORE_Merge_Test_Util.prepareMergeObjects();
        CORE_Merge_Test_Util.prepareMergeConfiguration(mObjsMap);
        List<CORE_Merge_Job__c> mJobs = CORE_Merge_Test_Util.prepareMergeJobs(mObjsMap);
        Test.startTest();
        CORE_Merge_Util.MergeObjectWrapper mObjWrapper = new CORE_Merge_Util.MergeObjectWrapper(mObjsMap.get('Account'));
        CORE_Merge_Configuration.readConfiguration(mObjsMap.get('Account'));
        CORE_Merge_Configuration.readConfiguration(mJobs[0]);
        CORE_Merge_Configuration.RelationshipConfigWrapper rcw = (CORE_Merge_Configuration.RelationshipConfigWrapper)mObjWrapper.getPropertyValue('ArchiveChildRelationship', 'Cases');
        System.assertNotEquals(null, rcw, 'ArchiveChildRelationship.Cases should be set');
        System.assertNotEquals(null, rcw.getQueryFields(), 'ArchiveChildRelationship.Cases.QueryFields should be set');
        System.assert(rcw.getQueryFields().contains('IsClosedOnCreate'), 'ArchiveChildRelationship.Cases.QueryFields should contain Case.IsClosedOnCreate field');
        System.assertEquals(null, rcw.getQueryWhere(), 'ArchiveChildRelationship.Cases.QueryWhere should not be set');
        System.assertEquals('CreatedDate DESC', rcw.getQueryOrderBy(), 'ArchiveChildRelationship.Cases.QueryOrderBy - wrong value');
        System.assertEquals('CASES', rcw.getRelationshipName(), 'ArchiveChildRelationship.Cases.RelationshipName - wrong value');
        System.assertEquals(null, rcw.getArchiveType(), 'ArchiveChildRelationship.Cases.ArchiveType should not be set');
        SObject matchingRec = (SObject)mObjWrapper.getPropertyValue(CORE_Merge_Configuration.MergeProperty.MatchingRecord);
        System.assertNotEquals(null, matchingRec, 'MatchingRecord should be set');
        System.assertEquals(UserInfo.getUserId(), matchingRec.get('CreatedById'), 'MatchingRecord.CreatedById should be equal to current user id');
        Boolean archiveEnabled = mObjWrapper.getPropertyBooleanValue(CORE_Merge_Configuration.MergeProperty.ArchiveEnabled);
        System.assertEquals(true, archiveEnabled, 'MatchingRecord.ArchiveEnabled - wrong value');
        String archiveOwnerId = mObjWrapper.getPropertyStringValue(CORE_Merge_Configuration.MergeProperty.ArchiveOwner);
        System.assertEquals(UserInfo.getUserId(), archiveOwnerId, 'MatchingRecord.ArchiveOwner - wrong value');
        Set<String> fieldNotNulls = mObjWrapper.getPropertyKeysByType(CORE_Merge_Configuration.MergeProperty.FieldNotNull);
        System.assertNotEquals(null, fieldNotNulls, 'FieldNotNull should be set');
        System.assert(fieldNotNulls.contains('PHONE'), 'FieldNotNull.Phone should exist');
        Map<String,Object> fieldNotNullsMap = mObjWrapper.getPropertiesByType(CORE_Merge_Configuration.MergeProperty.FieldNotNull);
        System.assertNotEquals(null, fieldNotNullsMap, 'FieldNotNull should be set');
        System.assert(fieldNotNullsMap.containsKey('PHONE'), 'FieldNotNull.Phone should exist');
        Map<String,Map<String,Object>> fieldNotNullsMapMap = mObjWrapper.getPropertiesByTypes(new Set<String>{CORE_Merge_Configuration.MergeProperty.FieldNotNull.name()});
        System.assertNotEquals(null, fieldNotNullsMap, 'FieldNotNull should be set');
        Map<String,Object> attrs = (Map<String,Object>)mObjWrapper.getPropertyAttributes(CORE_Merge_Configuration.MergeProperty.FieldNotNull.name(), 'Phone');
        System.assertNotEquals(null, attrs, 'FieldNotNull.Phone.attributes should be set');
        System.assertNotEquals(null, attrs.get('nullValues'), 'FieldNotNull.Phone.attributes.nullValues should be set');
        System.assert(new Set<Object>((List<Object>)attrs.get('nullValues')).contains('Other'), 'FieldNotNull.Phone.attributes.nullValues should contain "Other" value');
        Test.stopTest();
    }
    
    private static testMethod void testSchedulerWithPopulateCandidatesJob() {
        Map<String, CORE_Merge_Object__c> mObjsMap = CORE_Merge_Test_Util.prepareMergeObjects();
        CORE_Merge_Test_Util.prepareMergeConfiguration(mObjsMap);
        Test.startTest();
        CORE_Merge_Scheduler scheduler = new CORE_Merge_Scheduler();
        scheduler.execute(null);
        Test.stopTest();
    }
    
    private static testMethod void testSchedulerWithMergeJob() {
        Map<String, CORE_Merge_Object__c> mObjsMap = CORE_Merge_Test_Util.prepareMergeObjects();
        CORE_Merge_Test_Util.prepareMergeConfiguration(mObjsMap);
        
        CORE_Merge_Object__c allMergeObjRef = new CORE_Merge_Object__c(External_Id_gne__c = mObjsMap.get('ALL').External_Id_gne__c);
        
        List<CORE_Merge_Configuration__c> mconfigs = new List<CORE_Merge_Configuration__c>{
            new CORE_Merge_Configuration__c(Category_gne__c = 'Main Setting', Type_gne__c = 'SchedulerConfig', Key_gne__c = 'SchedulerConfig', Value_json_gne__c = '[{"jobType":"Merge","cronExpression":"* ? *","jobArguments":{}}]', Merge_Object_gne__r = allMergeObjRef)
        };
        
        for(CORE_Merge_Configuration__c mconfig : mconfigs) {
            mconfig.External_Id_gne__c = String.format('{0}|{1}_{2}', new String[]{mconfig.Merge_Object_gne__r.External_Id_gne__c, mconfig.Type_gne__c, mconfig.Key_gne__c});
            mconfig.Active_gne__c = true;
        }
        
        upsert mconfigs CORE_Merge_Configuration__c.External_Id_gne__c;
        
        Test.startTest();
        CORE_Merge_Scheduler scheduler = new CORE_Merge_Scheduler();
        scheduler.execute(null);
        Test.stopTest();
    }
    
    private static testMethod void testExecuteMerge() {
        Map<String, CORE_Merge_Object__c> mObjsMap = CORE_Merge_Test_Util.prepareMergeObjects();
        CORE_Merge_Test_Util.prepareMergeConfiguration(mObjsMap);
        CORE_Merge_Test_Util.prepareDuplicateData();
        CORE_Merge_Util.MergeObjectWrapper mObjWrapper = new CORE_Merge_Util.MergeObjectWrapper(mObjsMap.get('ALL'));
        Test.startTest();
        mObjWrapper.executeMergeJob();
        Test.stopTest();
        
        List<CORE_Merge_Error__c> errs = [SELECT Id, Merge_Object_gne__r.Name, Error_Code_gne__c, Full_Description_gne__c, Stacktrace_gne__c FROM CORE_Merge_Error__c ORDER BY Merge_Object_gne__r.Order_gne__c, Id];
        System.assertEquals(0,errs.size(), JSON.serialize(errs));
        List<CORE_Merge_Candidate__c> allCandidates = [SELECT Id, Merge_Object_gne__r.Name, Status_gne__c, Error_Codes_gne__c, Error_Details_gne__c, Source_gne__c FROM CORE_Merge_Candidate__c];
        Integer autoPopulatedCandidates=0;
        
        for(CORE_Merge_Candidate__c mc : allCandidates) {
            System.assertEquals(CORE_Merge_Util.CANDIDATE_STATUS_PROCESSED, mc.Status_gne__c, '[After Merge]: Candidate should be processed. Candidate: ' + JSON.serialize(mc));
            System.assertEquals(null, mc.Error_Codes_gne__c, '[After Merge]: Error Codes should be empty');
            System.assertEquals(null, mc.Error_Details_gne__c, '[After Merge]: Error Codes should be empty');
            
            if(mc.Source_gne__c==CORE_Merge_Util.CANDIDATE_SOURCE_AUTO_POPULATE) {
                autoPopulatedCandidates++;
            }
        }
        
        System.assertEquals(1, autoPopulatedCandidates, '[After Merge]: Wrong number of Auto-Populated Candidates for Cases');
        System.assertEquals(2,[SELECT ID FROM Account WHERE Name IN ('ACC1', 'ACC2') AND SicDesc=null].size(), '[After Merge]: Winner Accounts should be in DB');
        System.assertEquals(2,[SELECT ID FROM Account WHERE Name IN ('ACC1', 'ACC2') AND Website = 'http://test.website.com' AND AccountSource = 'Winner'].size(), '[After Merge]: Winner Account Clones should be in DB');
        System.assertEquals(3,[SELECT ID FROM Contact WHERE Name IN ('Contact1 ACC1', 'Contact2 ACC1', 'Contact1 ACC2') AND Department=null].size(), '[After Merge]: Winner Contacts should be in DB');
        System.assertEquals(0,[SELECT ID FROM Account WHERE Name like '%(Duplicate%)' AND SicDesc=null].size(), '[After Merge]: Loser Accounts should not be in DB');
        System.assertEquals(3,[SELECT ID FROM Account WHERE Name like '%(Duplicate%)' AND Website = 'http://test.website.com' AND AccountSource = 'Loser'].size(), '[After Merge]: Loser Account Clones should be in DB');
        System.assertEquals(6,[SELECT ID FROM Contact WHERE LastName like '%(Duplicate%)' AND Department=null].size(), '[After Merge]: Loser Contacts should not be in DB');
        System.assertEquals(7,[SELECT ID FROM Case WHERE Subject like 'ACC%.SUB%'].size(), '[After Merge]: Loser Cases should not be in DB');
    }
    
    private static testMethod void testExecuteMergeWithDeferOnConflict() {
        Map<String, CORE_Merge_Object__c> mObjsMap = CORE_Merge_Test_Util.prepareMergeObjects();
        CORE_Merge_Test_Util.prepareMergeConfiguration(mObjsMap);
        CORE_Merge_Object__c accMergeObjRef = new CORE_Merge_Object__c(External_Id_gne__c = mObjsMap.get('Account').External_Id_gne__c);
        
        List<CORE_Merge_Configuration__c> mconfigs = new List<CORE_Merge_Configuration__c>{
            new CORE_Merge_Configuration__c(Category_gne__c = 'Business Rule', Type_gne__c = 'DeferOnConflict', Key_gne__c = 'Name', Error_Code_gne__c = 'TEST_ERROR_CODE', Group_gne__c = 'Partner Rules', Merge_Object_gne__r = accMergeObjRef)
        };
        
        for(CORE_Merge_Configuration__c mconfig : mconfigs) {
            mconfig.External_Id_gne__c = String.format('{0}|{1}_{2}', new String[]{mconfig.Merge_Object_gne__r.External_Id_gne__c, mconfig.Type_gne__c, mconfig.Key_gne__c});
            mconfig.Active_gne__c = true;
        }
        
        upsert mconfigs CORE_Merge_Configuration__c.External_Id_gne__c;
        
        CORE_Merge_Test_Util.prepareDuplicateData();
        CORE_Merge_Util.MergeObjectWrapper mObjWrapper = new CORE_Merge_Util.MergeObjectWrapper(mObjsMap.get('ALL'));
        
        Test.startTest();
        mObjWrapper.executeMergeJob();
        Test.stopTest();
        
        List<CORE_Merge_Error__c> errs = [SELECT Id, Merge_Object_gne__r.Name, Error_Code_gne__c, Full_Description_gne__c, Stacktrace_gne__c FROM CORE_Merge_Error__c ORDER BY Merge_Object_gne__r.Order_gne__c, Id];
        System.assertEquals(3,errs.size(), JSON.serialize(errs));
        
        for(CORE_Merge_Error__c err : errs) {
            System.assertEquals('TEST_ERROR_CODE', err.Error_Code_gne__c, '[After Merge]: Error Code has wrong value');
            System.assertNotEquals(null, err.Full_Description_gne__c, '[After Merge]: Error Description should not be empty');
        }
    }
    
    private static testMethod void testExecuteMergeWithDeferChildRelationship() {
        Map<String, CORE_Merge_Object__c> mObjsMap = CORE_Merge_Test_Util.prepareMergeObjects();
        CORE_Merge_Test_Util.prepareMergeConfiguration(mObjsMap);
        CORE_Merge_Object__c accMergeObjRef = new CORE_Merge_Object__c(External_Id_gne__c = mObjsMap.get('Account').External_Id_gne__c);
        
        List<CORE_Merge_Configuration__c> mconfigs = new List<CORE_Merge_Configuration__c>{
            new CORE_Merge_Configuration__c(Category_gne__c = 'Business Rule', Type_gne__c = 'DeferOnChildRelationship', Key_gne__c = 'Cases', Value_json_gne__c = '{"queryWhere":"SuppliedCompany=\'ABC\'"}', Error_Code_gne__c = 'TEST_ERROR_CODE', Group_gne__c = 'General Rules', Merge_Object_gne__r = accMergeObjRef)
        };
        
        for(CORE_Merge_Configuration__c mconfig : mconfigs) {
            mconfig.External_Id_gne__c = String.format('{0}|{1}_{2}', new String[]{mconfig.Merge_Object_gne__r.External_Id_gne__c, mconfig.Type_gne__c, mconfig.Key_gne__c});
            mconfig.Active_gne__c = true;
        }
        
        upsert mconfigs CORE_Merge_Configuration__c.External_Id_gne__c;
        
        CORE_Merge_Test_Util.prepareDuplicateData();
        CORE_Merge_Util.MergeObjectWrapper mObjWrapper = new CORE_Merge_Util.MergeObjectWrapper(mObjsMap.get('ALL'));
        
        Test.startTest();
        mObjWrapper.executeMergeJob();
        Test.stopTest();
        
        List<CORE_Merge_Error__c> errs = [SELECT Id, Merge_Object_gne__r.Name, Error_Code_gne__c, Full_Description_gne__c, Stacktrace_gne__c FROM CORE_Merge_Error__c ORDER BY Merge_Object_gne__r.Order_gne__c, Id];
        System.assertEquals(1,errs.size(), JSON.serialize(errs));
        
        for(CORE_Merge_Error__c err : errs) {
            System.assertEquals('TEST_ERROR_CODE', err.Error_Code_gne__c, '[After Merge]: Error Code has wrong value');
            System.assertNotEquals(null, err.Full_Description_gne__c, '[After Merge]: Error Description should not be empty');
        }
    }
    
    private static testMethod void testExecuteMergeWithExcludeMatching() {
        Map<String, CORE_Merge_Object__c> mObjsMap = CORE_Merge_Test_Util.prepareMergeObjects();
        CORE_Merge_Test_Util.prepareMergeConfiguration(mObjsMap);
        CORE_Merge_Object__c accMergeObjRef = new CORE_Merge_Object__c(External_Id_gne__c = mObjsMap.get('Account').External_Id_gne__c);
        
        List<CORE_Merge_Configuration__c> mconfigs = new List<CORE_Merge_Configuration__c>{
            new CORE_Merge_Configuration__c(Category_gne__c = 'Business Rule', Type_gne__c = 'ExcludeMatching', Key_gne__c = 'NameExclussion', Value_json_gne__c = '{"Name":"ACC1"}', Error_Code_gne__c = 'TEST_ERROR_CODE', Group_gne__c = 'Test Rules', Merge_Object_gne__r = accMergeObjRef)
        };
        
        for(CORE_Merge_Configuration__c mconfig : mconfigs) {
            mconfig.External_Id_gne__c = String.format('{0}|{1}_{2}', new String[]{mconfig.Merge_Object_gne__r.External_Id_gne__c, mconfig.Type_gne__c, mconfig.Key_gne__c});
            mconfig.Active_gne__c = true;
        }
        
        upsert mconfigs CORE_Merge_Configuration__c.External_Id_gne__c;
        
        CORE_Merge_Test_Util.prepareDuplicateData();
        CORE_Merge_Util.MergeObjectWrapper mObjWrapper = new CORE_Merge_Util.MergeObjectWrapper(mObjsMap.get('ALL'));
        
        Test.startTest();
        mObjWrapper.executeMergeJob();
        Test.stopTest();
        
        List<CORE_Merge_Error__c> errs = [SELECT Id, Merge_Object_gne__r.Name, Error_Code_gne__c, Full_Description_gne__c, Stacktrace_gne__c FROM CORE_Merge_Error__c ORDER BY Merge_Object_gne__r.Order_gne__c, Id];
        System.assertEquals(1,errs.size(), JSON.serialize(errs));
        
        for(CORE_Merge_Error__c err : errs) {
            System.assertEquals('TEST_ERROR_CODE', err.Error_Code_gne__c, '[After Merge]: Error Code has wrong value, Error: ' + JSON.serialize(err));
            System.assertNotEquals(null, err.Full_Description_gne__c, '[After Merge]: Error Description should not be empty');
        }
    }
    
    private static testMethod void testExecuteMergeWithBrokenSource() {
        Map<String, CORE_Merge_Object__c> mObjsMap = CORE_Merge_Test_Util.prepareMergeObjects();
        CORE_Merge_Test_Util.prepareMergeConfiguration(mObjsMap);
        List<CORE_Merge_Candidate__c> mcs = CORE_Merge_Test_Util.prepareDuplicateData();
        
        mcs[0].Id_gne__c = mcs[0].Master_Id_gne__c  = mcs[0].Id_gne__c.substring(0,3) + '0'.repeat(14) + '1';
        mcs[1].Id_gne__c = mcs[1].Master_Id_gne__c  = mcs[0].Id_gne__c.substring(0,3) + '0'.repeat(14) + '2';

        CORE_Merge_Util.setInTrigger(CORE_Merge_Candidate__c.sObjectType, true);
        update new List<CORE_Merge_Candidate__c>{mcs[0],mcs[1]};
        CORE_Merge_Util.setInTrigger(CORE_Merge_Candidate__c.sObjectType, false);
        CORE_Merge_Util.MergeObjectWrapper mObjWrapper = new CORE_Merge_Util.MergeObjectWrapper(mObjsMap.get('ALL'));
        
        Test.startTest();
        mObjWrapper.executeMergeJob();
        Test.stopTest();
        
        List<CORE_Merge_Error__c> errs = [SELECT Id, Merge_Object_gne__r.Name, Error_Code_gne__c, Full_Description_gne__c, Stacktrace_gne__c FROM CORE_Merge_Error__c ORDER BY Merge_Object_gne__r.Order_gne__c, Error_Code_gne__c];
        System.assertEquals(2,errs.size(), JSON.serialize(errs));
        System.assertEquals('SourceRecordIsMissing', errs[1].Error_Code_gne__c, '[After Merge]: Error Code has wrong value');
        System.assertEquals('SourceRecordIsMissing', errs[0].Error_Code_gne__c, '[After Merge]: Error Code has wrong value');
    }
    
    private static testMethod void testExecuteMergeInPreviewMode() {
        Map<String, CORE_Merge_Object__c> mObjsMap = CORE_Merge_Test_Util.prepareMergeObjects();
        CORE_Merge_Test_Util.prepareMergeConfiguration(mObjsMap);
        CORE_Merge_Test_Util.prepareDuplicateData();
        CORE_Merge_Util.MergeObjectWrapper mObjWrapper = new CORE_Merge_Util.MergeObjectWrapper(mObjsMap.get('ALL'));
        Test.startTest();
        mObjWrapper.executeMergeJob(true, null, null, null);
        Test.stopTest();
    }
    
    private static testMethod void testExecutePopulateCandidates() {
        Map<String, CORE_Merge_Object__c> mObjsMap = CORE_Merge_Test_Util.prepareMergeObjects();
        CORE_Merge_Test_Util.prepareMergeConfiguration(mObjsMap);
        CORE_Merge_Test_Util.prepareDuplicateData();
        CORE_Merge_Util.MergeObjectWrapper mObjWrapper = new CORE_Merge_Util.MergeObjectWrapper(mObjsMap.get('Case'));
        Test.startTest();
        mObjWrapper.executePopulateCandidatesJob();
        Test.stopTest();
    }
    
    private static testMethod void testExecuteMergeBatchWithAdditionalBatch() {
        Map<String, CORE_Merge_Object__c> mObjsMap = CORE_Merge_Test_Util.prepareMergeObjects();
        CORE_Merge_Test_Util.prepareMergeConfiguration(mObjsMap);
        CORE_Merge_Test_Util.prepareDuplicateData();
        CORE_Merge_Object__c caseMergeObjRef = new CORE_Merge_Object__c(External_Id_gne__c = mObjsMap.get('Case').External_Id_gne__c);
        
        List<CORE_Merge_Configuration__c> mconfigs = new List<CORE_Merge_Configuration__c>{
            new CORE_Merge_Configuration__c(Category_gne__c = 'Main Setting', Type_gne__c = 'PopulateCandidatesConfig', Key_gne__c = 'PopulateCandidatesConfig', Value_json_gne__c = '{"enabled":true,"populateFromParentEnabled":true,"mergeFromParentEnabled":false,"querySortBy":["LastModifiedDate DESC"],"queryUniqueField":"Subject","queryWhere":"IsEscalated = false","queryBatchWhere":"IsEscalated = false AND Account.LastModifiedDate >= {{LAST_POPULATE_JOB_DATETIME}}"}', Merge_Object_gne__r = caseMergeObjRef)
        };
        
        for(CORE_Merge_Configuration__c mconfig : mconfigs) {
            mconfig.External_Id_gne__c = String.format('{0}|{1}_{2}', new String[]{mconfig.Merge_Object_gne__r.External_Id_gne__c, mconfig.Type_gne__c, mconfig.Key_gne__c});
            mconfig.Active_gne__c = true;
        }
        
        upsert mconfigs CORE_Merge_Configuration__c.External_Id_gne__c;
        
        Test.startTest();
        CORE_Merge_Engine_Batch mBatch = new CORE_Merge_Engine_Batch();
        System.assertEquals(CORE_Merge_Engine_Batch.class, mBatch.getBatchType(), 'CORE_Merge_Engine_Batch.getBatchType() - wrong type');
        mBatch.executeBatch(mObjsMap.get('ALL').Id);
        Test.stopTest();
    }
    
    private static testMethod void testExecuteMergeSingleMode() {
        Map<String, CORE_Merge_Object__c> mObjsMap = CORE_Merge_Test_Util.prepareMergeObjects();
        CORE_Merge_Test_Util.prepareMergeConfiguration(mObjsMap);
        List<CORE_Merge_Candidate__c> mcs = CORE_Merge_Test_Util.prepareDuplicateData();
        Set<String> winnerIds = new Set<String>();
        
        for(CORE_Merge_Candidate__c mc : mcs) {
            winnerIds.add(mc.Master_Id_gne__c);
        }
        
        Test.startTest();
        CORE_Merge_Engine_Batch mBatch = new CORE_Merge_Engine_Batch();
        System.assertEquals(CORE_Merge_Engine_Batch.class, mBatch.getBatchType(), 'CORE_Merge_Engine_Batch.getBatchType() - wrong type');
        mBatch.initBatch(mObjsMap.get('ALL').Id, false, winnerIds, null, null);
        mBatch.executeBatch(mObjsMap.get('ALL').Id);
        Test.stopTest();
    }
    
    private static testMethod void testScheduleMergeBatch() {
        Map<String, CORE_Merge_Object__c> mObjsMap = CORE_Merge_Test_Util.prepareMergeObjects();
        CORE_Merge_Test_Util.prepareMergeConfiguration(mObjsMap);
        CORE_Merge_Test_Util.prepareDuplicateData();
        
        Test.startTest();
        CORE_Merge_Engine_Batch mBatch = new CORE_Merge_Engine_Batch();
        
        mBatch.setSchedulerArguments(new Map<String,String>());
        mBatch.scheduleBatch(mObjsMap.get('ALL').Id, 'TEST JOB 1', 1);
        Test.stopTest();
    }
    
    private static testMethod void testSchedulePopulateCandidatesBatch() {
        Map<String, CORE_Merge_Object__c> mObjsMap = CORE_Merge_Test_Util.prepareMergeObjects();
        CORE_Merge_Test_Util.prepareMergeConfiguration(mObjsMap);
        CORE_Merge_Test_Util.prepareDuplicateData();
        
        Test.startTest();
        CORE_Merge_Populate_Candidates_Batch mBatch = new CORE_Merge_Populate_Candidates_Batch();
        System.assertEquals(CORE_Merge_Populate_Candidates_Batch.class, mBatch.getBatchType(), 'CORE_Merge_Populate_Candidates_Batch.getBatchType() - wrong type');
        mBatch.setSchedulerArguments(new Map<String,String>());
        mBatch.scheduleBatch(mObjsMap.get('Case').Id, 'TEST JOB 1', 1);
        Test.stopTest();
    }
    
    private static testMethod void testHandleStandAloneException() {
        Map<String, CORE_Merge_Object__c> mObjsMap = CORE_Merge_Test_Util.prepareMergeObjects();
        
        Test.startTest();
        CORE_Merge_Util.handleStandAloneException(new CORE_Merge_Configuration.MergeConfigurationException('TEST EXCEPTION', 'MatchingRecord'), mObjsMap.get('ALL').Id);
        Test.stopTest();
    }
    
    private static testMethod void testHandleWrongConfiguration() {
        Map<String, CORE_Merge_Object__c> mObjsMap = CORE_Merge_Test_Util.prepareMergeObjects();
        CORE_Merge_Test_Util.prepareMergeConfiguration(mObjsMap);
        Test.startTest();
        
        CORE_Merge_Object__c allMergeObjRef = new CORE_Merge_Object__c(External_Id_gne__c = mObjsMap.get('ALL').External_Id_gne__c);
        
        List<CORE_Merge_Configuration__c> mconfigs = new List<CORE_Merge_Configuration__c>{
            new CORE_Merge_Configuration__c(Category_gne__c = 'Main Setting', Type_gne__c = 'SchedulerConfig', Key_gne__c = 'SchedulerConfig', Value_json_gne__c = '[{"jobType":"MergeWrongJobType","cronExpression":"* ? *","jobArguments":{}}]', Merge_Object_gne__r = allMergeObjRef)
        };
        
        for(CORE_Merge_Configuration__c mconfig : mconfigs) {
            mconfig.External_Id_gne__c = String.format('{0}|{1}_{2}', new String[]{mconfig.Merge_Object_gne__r.External_Id_gne__c, mconfig.Type_gne__c, mconfig.Key_gne__c});
            mconfig.Active_gne__c = true;
        }
        
        Database.UpsertResult[] dmlResults = Database.upsert(mconfigs,CORE_Merge_Configuration__c.External_Id_gne__c, false);
        
        for(Database.UpsertResult dmlResult : dmlResults) {
            System.assert(!dmlResult.isSuccess(), 'Configuration Update should fail, because config record has wrong data');
            
            for(Database.Error err : dmlResult.getErrors()) {
                CORE_Merge_Util.handleStandAloneException(new CORE_Merge_Util.MergeDmlException(err), mObjsMap.get('ALL').Id);
            }
        }
        
        Test.stopTest();
    }
}