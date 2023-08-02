@IsTest
private class GNE_Subscribe_Batch_Alignment_Test {

    private static final String STG_ALIGNMENT_ERROR_STATE = 'Error Processing';
    private static final String STG_ALIGNMENT_SUCCESS_STATE = 'Processed';
    private static List<String> testTerritoryNamesCache = new List<String>();
    private static final Map<String, Id> ids2ProfilesMap = GNE_FRM_TestUtilities.getProfiles();

    @TestSetup
    private static void init() {
        prepareCustomSettings();
        String userExtId = 'uniqueemail@gene.com';
        User user = CORE_Subscribe_Test_Util.insertDefaultRecordOwner(userExtId);
        user.External_ID_gne__c = userExtId;
        update user;
        CORE_Subscribe_Test_Util.initCustomSettings();
        CORE_Subscribe_Test_Util.initMappingConfig(user.External_ID_gne__c);
    }

    private static void prepareEnv() {
        AggregateResult[] groupedResults = [SELECT count(Territory2Id) , UserId FROM UserTerritory2Association GROUP BY UserId HAVING count(Territory2Id) > 1];
        Set<Id> userIds = new Set<Id>();
        for(AggregateResult ar: groupedResults) {
            
            userIds.add((Id)ar.get('UserId'));
        }
        for(User u: [Select profile.name from User where Id in:userIds]) {
            System.debug(u.Id + '  '+ u.Profile.name);
            
        }
        Map<Id, User> csUsers = new Map<Id, User>([SELECT Id FROM User WHERE IsActive = TRUE AND Profile.Name LIKE 'GNE-%' AND Id IN : userIds LIMIT 10]);
        for (Territory2 terr : [SELECT Name FROM Territory2 WHERE Id IN (SELECT Territory2Id FROM UserTerritory2Association WHERE UserId IN :csUsers.keySet()) LIMIT 2]) {
            testTerritoryNamesCache.add(terr.Name);
        }
    }

    static testMethod void notActiveRecordsTest() {
        prepareEnv();
        List<Staging_Alignment_gne__c> scope = new List<Staging_Alignment_gne__c>();
        Staging_Alignment_gne__c stgAlignment;

        stgAlignment = new Staging_Alignment_gne__c();
        stgAlignment.Activaction_Date_gne__c = Date.today().addYears(1);
        stgAlignment.MDM_ID_gne__c = 'Invalid mdm id';
        stgAlignment.MDM_Address_Id_gne__c = 'Invalid mdm address id';
        stgAlignment.Status_gne__c = GNE_Subscribe_Batch_Base.STATUS_LOADED;
        stgAlignment.Unalign_Date_gne__c = Date.today();
        stgAlignment.Account_ID_gne__c = '0';
        scope.add(stgAlignment);

        stgAlignment = new Staging_Alignment_gne__c();
        stgAlignment.Activaction_Date_gne__c = Date.today().addYears(1);
        stgAlignment.MDM_ID_gne__c = 'Invalid mdm id';
        stgAlignment.MDM_Address_Id_gne__c = 'Invalid mdm address id';
        stgAlignment.Status_gne__c = GNE_Subscribe_Batch_Base.STATUS_LOADED;
        stgAlignment.Territory_Key_gne__c = 'Invalid Territory';
        stgAlignment.Target_gne__c = true;
        stgAlignment.Unalign_Date_gne__c = Date.today();
        stgAlignment.Account_ID_gne__c = '1';
        scope.add(stgAlignment);
        insert scope;

        Test.startTest();
        GNE_Subscribe_Batch_Alignment subscribe = new GNE_Subscribe_Batch_Alignment();

        Database.QueryLocator queryLocator = subscribe.start(null);
        String query = queryLocator.getQuery();
        query = query.replace(':tmpVar1', '\'' + GNE_Subscribe_Batch_Base.STATUS_LOADED + '\'');
        List<Staging_Alignment_gne__c> scope2 = (List<Staging_Alignment_gne__c>) Database.query(query);
        System.assertEquals(0, scope2.size());
        subscribe.execute(null, scope2);

        Test.stopTest();

        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'Account', 0, 0, 0);
        for (Staging_Alignment_gne__c stgAlign : getAllAlignments()) {
            System.assertEquals(GNE_Subscribe_Batch_Base.STATUS_LOADED, stgAlign.Status_gne__c);
            System.assertEquals(null, stgAlign.SFDC_Account_gne__c);
            System.assertEquals(null, stgAlign.SFDC_TSF_gne__c);
            System.assertEquals(null, stgAlign.SFDC_Group_gne__c);
        }
    }

    static testMethod void alreadyProcessedRecordsTest() {
        prepareEnv();
        List<Staging_Alignment_gne__c> scope = new List<Staging_Alignment_gne__c>();
        Staging_Alignment_gne__c stgAlignment;

        stgAlignment = new Staging_Alignment_gne__c();
        stgAlignment.Activaction_Date_gne__c = Date.today();
        stgAlignment.MDM_ID_gne__c = 'Invalid mdm id';
        stgAlignment.MDM_Address_Id_gne__c = 'Invalid mdm address id';
        stgAlignment.Status_gne__c = STG_ALIGNMENT_ERROR_STATE;
        stgAlignment.Unalign_Date_gne__c = Date.today();
        stgAlignment.Account_ID_gne__c = '0';
        scope.add(stgAlignment);

        stgAlignment = new Staging_Alignment_gne__c();
        stgAlignment.Activaction_Date_gne__c = Date.today();
        stgAlignment.MDM_ID_gne__c = 'Invalid mdm id';
        stgAlignment.MDM_Address_Id_gne__c = 'Invalid mdm address id';
        stgAlignment.Status_gne__c = STG_ALIGNMENT_SUCCESS_STATE;
        stgAlignment.Territory_Key_gne__c = 'Invalid Territory';
        stgAlignment.Target_gne__c = true;
        stgAlignment.Unalign_Date_gne__c = Date.today();
        stgAlignment.Account_ID_gne__c = '1';
        scope.add(stgAlignment);
        insert scope;

        Test.startTest();
        GNE_Subscribe_Batch_Alignment subscribe = new GNE_Subscribe_Batch_Alignment();

        Database.QueryLocator queryLocator = subscribe.start(null);
        String query = queryLocator.getQuery();
        query = query.replace(':tmpVar1', '\'' + GNE_Subscribe_Batch_Base.STATUS_LOADED + '\'');
        List<Staging_Alignment_gne__c> scope2 = (List<Staging_Alignment_gne__c>) Database.query(query);
        System.assertEquals(0, scope2.size());
        subscribe.execute(null, scope2);

        Test.stopTest();

        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'Account', 0, 0, 0);

        for (Staging_Alignment_gne__c stgAlign : scope) {
            System.assertEquals(null, stgAlign.SFDC_Account_gne__c);
            System.assertEquals(null, stgAlign.SFDC_TSF_gne__c);
            System.assertEquals(null, stgAlign.SFDC_Group_gne__c);
        }
    }

    static testMethod void invalidAccountMdmIdTest() {
        prepareEnv();
        List<Staging_Alignment_gne__c> scope = new List<Staging_Alignment_gne__c>();
        Staging_Alignment_gne__c stgAlignment;

        stgAlignment = new Staging_Alignment_gne__c();
        stgAlignment.Activaction_Date_gne__c = Date.today();
        stgAlignment.MDM_ID_gne__c = 'Invalid mdm id';
        stgAlignment.MDM_Address_Id_gne__c = GNE_Subscribe_Process_TestDataPrepare.PARTY_LOCATION_MDMID;
        stgAlignment.Status_gne__c = GNE_Subscribe_Batch_Base.STATUS_LOADED;
        stgAlignment.Territory_Key_gne__c = testTerritoryNamesCache[1];
        stgAlignment.Target_gne__c = true;
        stgAlignment.Unalign_Date_gne__c = Date.today();
        stgAlignment.Account_ID_gne__c = '0';
        scope.add(stgAlignment);
        insert scope;

        Test.startTest();
        GNE_Subscribe_Batch_Alignment subscribe = new GNE_Subscribe_Batch_Alignment();

        Database.QueryLocator queryLocator = subscribe.start(null);
        String query = queryLocator.getQuery();
        query = query.replace(':tmpVar1', '\'' + GNE_Subscribe_Batch_Base.STATUS_LOADED + '\'');
        scope = (List<Staging_Alignment_gne__c>) Database.query(query);
        subscribe.execute(null, scope);

        Test.stopTest();
        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'Account', 0, 0, 0);
        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'STAGING_ALIGNMENT', 0, 1, 0);

        for (Staging_Alignment_gne__c stgAlign : scope) {
            System.assertEquals(STG_ALIGNMENT_ERROR_STATE, stgAlign.Status_gne__c);
            System.assert(stgAlign.Comment_gne__c.contains(GNE_Subscribe_Batch_Alignment.ACCOUNT_SFDC_ID_MISSING));
            System.assertEquals(null, stgAlign.SFDC_Account_gne__c);
            System.assertEquals(null, stgAlign.SFDC_TSF_gne__c);
        }
    }

    static testMethod void insertNewAccountAndAddressWithoutTerritory() {
        prepareEnv();
        prepareInsertData();

        List<Staging_Alignment_gne__c> scope = new List<Staging_Alignment_gne__c>();
        Staging_Alignment_gne__c stgAlignment;

        stgAlignment = new Staging_Alignment_gne__c();
        stgAlignment.Activaction_Date_gne__c = Date.today();
        stgAlignment.MDM_ID_gne__c = GNE_Subscribe_Process_TestDataPrepare.PARTY_MDMID;
        stgAlignment.MDM_Address_Id_gne__c = GNE_Subscribe_Process_TestDataPrepare.PARTY_LOCATION_MDMID;
        stgAlignment.Status_gne__c = GNE_Subscribe_Batch_Base.STATUS_LOADED;
        stgAlignment.Account_ID_gne__c = '0';
        scope.add(stgAlignment);
        insert scope;

        Test.startTest();
        GNE_Subscribe_Batch_Alignment subscribe = new GNE_Subscribe_Batch_Alignment();
        subscribe.initBatch();
        subscribe.execute(null, scope);

        Test.stopTest();

        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'Account', 1, 0, 0);
        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'Address_vod__c', 1, 0, 0);
        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'STAGING_ALIGNMENT', 0, 1, 0);

        System.assertEquals(STG_ALIGNMENT_SUCCESS_STATE, stgAlignment.Status_gne__c);
        System.assertNotEquals(null, stgAlignment.SFDC_Account_gne__c);
        System.assertEquals(null, stgAlignment.SFDC_Group_gne__c);
        System.assertEquals(null, stgAlignment.SFDC_TSF_gne__c);

        System.assertEquals(1, [SELECT COUNT() FROM Account WHERE Id = :stgAlignment.SFDC_Account_gne__c]);
        System.assertEquals(1, [SELECT COUNT() FROM Address_vod__c]);
        System.assertEquals(0, [SELECT COUNT() FROM TSF_vod__c]);
    }

    static testMethod void insertNewAccountAndAddressTest() {
        prepareEnv();
        prepareInsertData();

        List<Staging_Alignment_gne__c> scope = new List<Staging_Alignment_gne__c>();
        Staging_Alignment_gne__c stgAlignment;

        stgAlignment = new Staging_Alignment_gne__c();
        stgAlignment.Activaction_Date_gne__c = Date.today();
        stgAlignment.MDM_ID_gne__c = GNE_Subscribe_Process_TestDataPrepare.PARTY_MDMID;
        stgAlignment.MDM_Address_Id_gne__c = GNE_Subscribe_Process_TestDataPrepare.PARTY_LOCATION_MDMID;
        stgAlignment.Status_gne__c = GNE_Subscribe_Batch_Base.STATUS_LOADED;
        stgAlignment.Territory_Key_gne__c = testTerritoryNamesCache[0];
        stgAlignment.Target_gne__c = true;
        stgAlignment.Unalign_Date_gne__c = null;
        stgAlignment.Account_ID_gne__c = '0';
        scope.add(stgAlignment);
        insert scope;

        Test.startTest();
        GNE_Subscribe_Batch_Alignment subscribe = new GNE_Subscribe_Batch_Alignment();
        subscribe.initBatch();
        subscribe.execute(null, scope);

        Test.stopTest();

        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'Account', 1, 0, 0);
        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'STAGING_ALIGNMENT', 0, 1, 0);
        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'TSF_vod__c', 1, 0, 0);
        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'ObjectTerritory2Association', 1, 0, 0);

        System.assertEquals(STG_ALIGNMENT_SUCCESS_STATE, stgAlignment.Status_gne__c);
        System.assertNotEquals(null, stgAlignment.SFDC_Account_gne__c);
        System.assertNotEquals(null, stgAlignment.SFDC_Group_gne__c);
        System.assertNotEquals(null, stgAlignment.SFDC_TSF_gne__c);
        System.assertEquals(1, [SELECT COUNT() FROM Account WHERE Id = :stgAlignment.SFDC_Account_gne__c]);
        System.assertEquals(1, [SELECT COUNT() FROM Address_vod__c]);
        System.assertEquals(1, [SELECT COUNT() FROM TSF_vod__c WHERE Id = :stgAlignment.SFDC_TSF_gne__c]);
        System.assertEquals(1, [SELECT COUNT() FROM Group WHERE RelatedId = :stgAlignment.SFDC_Group_gne__c AND Type = 'Territory']);
    }

    static testMethod void updateAccountAndAddressTest() {
        prepareEnv();
        prepareUpdateData();

        System.assertEquals(1, [SELECT COUNT() FROM Account]);
        System.assertEquals(1, [SELECT COUNT() FROM Address_vod__c]);
        System.assertEquals(0, [SELECT COUNT() FROM TSF_vod__c]);

        Account acc = [SELECT Id FROM Account];

        List<Staging_Alignment_gne__c> scope = new List<Staging_Alignment_gne__c>();
        Staging_Alignment_gne__c stgAlignment;

        stgAlignment = new Staging_Alignment_gne__c();
        stgAlignment.Activaction_Date_gne__c = Date.today();
        stgAlignment.MDM_ID_gne__c = GNE_Subscribe_Process_TestDataPrepare.PARTY_MDMID;
        stgAlignment.MDM_Address_Id_gne__c = GNE_Subscribe_Process_TestDataPrepare.PARTY_LOCATION_MDMID;
        stgAlignment.Status_gne__c = GNE_Subscribe_Batch_Base.STATUS_LOADED;
        stgAlignment.Territory_Key_gne__c = testTerritoryNamesCache[0];
        stgAlignment.Target_gne__c = true;
        stgAlignment.Unalign_Date_gne__c = null;
        stgAlignment.Account_ID_gne__c = '0';
        scope.add(stgAlignment);
        insert scope;

        User adminUser = GNE_FRM_TestUtilities.createUser('adminUser', ids2ProfilesMap.get('System Administrator'), false);
        GNE_Subscribe_Batch_Alignment subscribe;

        Test.startTest();
        System.runAs(adminUser) {
            subscribe = new GNE_Subscribe_Batch_Alignment();
            subscribe.initBatch();
            subscribe.execute(null, scope);
        }
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM Account]);
        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'Account', 0, 1, 0);
        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'Address_vod__c', 0, 1, 0);
        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'STAGING_ALIGNMENT', 0, 1, 0);
        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'TSF_vod__c', 1, 0, 0);
        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'ObjectTerritory2Association', 1, 0, 0);

        System.assertEquals(STG_ALIGNMENT_SUCCESS_STATE, stgAlignment.Status_gne__c);
        System.assertEquals(acc.Id, stgAlignment.SFDC_Account_gne__c);
        System.assertNotEquals(null, stgAlignment.SFDC_Group_gne__c);
        System.assertNotEquals(null, stgAlignment.SFDC_TSF_gne__c);

        System.assertEquals(1, [SELECT COUNT() FROM Account WHERE Id = :stgAlignment.SFDC_Account_gne__c]);
        System.assertEquals(1, [SELECT COUNT() FROM Address_vod__c]);
        System.assertEquals(1, [SELECT COUNT() FROM TSF_vod__c WHERE Id = :stgAlignment.SFDC_TSF_gne__c]);
        System.assertEquals(1, [SELECT COUNT() FROM Group WHERE RelatedId = :stgAlignment.SFDC_Group_gne__c AND Type = 'Territory']);
    }

    static testMethod void subscribeAccountWithInvalidSecondAddressTest() {
        prepareEnv();
        prepareInsertData();

        List<Staging_Alignment_gne__c> scope = new List<Staging_Alignment_gne__c>();
        Staging_Alignment_gne__c stgAlignment;

        stgAlignment = new Staging_Alignment_gne__c();
        stgAlignment.Activaction_Date_gne__c = Date.today();
        stgAlignment.MDM_ID_gne__c = GNE_Subscribe_Process_TestDataPrepare.PARTY_MDMID;
        stgAlignment.MDM_Address_Id_gne__c = GNE_Subscribe_Process_TestDataPrepare.PARTY_LOCATION_MDMID;
        stgAlignment.Status_gne__c = GNE_Subscribe_Batch_Base.STATUS_LOADED;
        stgAlignment.Territory_Key_gne__c = testTerritoryNamesCache[0];
        stgAlignment.Target_gne__c = true;
        stgAlignment.Unalign_Date_gne__c = null;
        stgAlignment.Account_ID_gne__c = '0';
        scope.add(stgAlignment);

        stgAlignment = new Staging_Alignment_gne__c();
        stgAlignment.Activaction_Date_gne__c = Date.today();
        stgAlignment.MDM_ID_gne__c = GNE_Subscribe_Process_TestDataPrepare.PARTY_MDMID;
        stgAlignment.MDM_Address_Id_gne__c = 'Invalid second Address';
        stgAlignment.Status_gne__c = GNE_Subscribe_Batch_Base.STATUS_LOADED;
        stgAlignment.Account_ID_gne__c = '1';
        scope.add(stgAlignment);
        insert scope;

        Test.startTest();
        GNE_Subscribe_Batch_Alignment subscribe = new GNE_Subscribe_Batch_Alignment();
        subscribe.initBatch();
        subscribe.execute(null, scope);

        Test.stopTest();

        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'Account', 1, 0, 0);
        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'Address_vod__c', 1, 0, 0);
        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'STAGING_ALIGNMENT', 0, 2, 0);
        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'TSF_vod__c', 1, 0, 0);
        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'ObjectTerritory2Association', 1, 0, 0);

        System.assertEquals(STG_ALIGNMENT_SUCCESS_STATE, scope.get(0).Status_gne__c);
        System.assertNotEquals(null, scope.get(0).SFDC_Account_gne__c);
        System.assertNotEquals(null, scope.get(0).SFDC_Group_gne__c);
        System.assertNotEquals(null, scope.get(0).SFDC_TSF_gne__c);

        System.assertEquals(1, [SELECT COUNT() FROM Account WHERE Id = :scope.get(0).SFDC_Account_gne__c]);
        System.assertEquals(1, [SELECT COUNT() FROM Address_vod__c]);
        System.assertEquals(1, [SELECT COUNT() FROM TSF_vod__c WHERE Id = :scope.get(0).SFDC_TSF_gne__c]);
        System.assertEquals(1, [SELECT COUNT() FROM Group WHERE RelatedId = :scope.get(0).SFDC_Group_gne__c AND Type = 'Territory']);

        System.assertEquals(STG_ALIGNMENT_SUCCESS_STATE, scope.get(1).Status_gne__c);
        System.assertNotEquals(null, scope.get(1).SFDC_Account_gne__c);
        System.assertEquals(null, scope.get(1).SFDC_Group_gne__c);
        System.assertEquals(null, scope.get(1).SFDC_TSF_gne__c);
        System.assertEquals(1, [SELECT COUNT() FROM Account WHERE Id = :scope.get(1).SFDC_Account_gne__c]);
    }

    static testMethod void invalidAddressMdmIdTest() {
        prepareEnv();
        prepareInsertData();

        List<Staging_Alignment_gne__c> scope = new List<Staging_Alignment_gne__c>();
        Staging_Alignment_gne__c stgAlignment;

        stgAlignment = new Staging_Alignment_gne__c();
        stgAlignment.Activaction_Date_gne__c = Date.today();
        stgAlignment.MDM_ID_gne__c = GNE_Subscribe_Process_TestDataPrepare.PARTY_MDMID;
        stgAlignment.MDM_Address_Id_gne__c = 'InvalidMDMID';
        stgAlignment.Status_gne__c = GNE_Subscribe_Batch_Base.STATUS_LOADED;
        stgAlignment.Territory_Key_gne__c = testTerritoryNamesCache[0];
        stgAlignment.Target_gne__c = true;
        stgAlignment.Unalign_Date_gne__c = Date.today();
        stgAlignment.Account_ID_gne__c = '0';
        scope.add(stgAlignment);
        insert scope;

        Test.startTest();
        GNE_Subscribe_Batch_Alignment subscribe = new GNE_Subscribe_Batch_Alignment();
        subscribe.initBatch();
        subscribe.execute(null, scope);

        Test.stopTest();
        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'Account', 0, 0, 0);
        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'STAGING_ALIGNMENT', 0, 1, 0);

        System.assertEquals(STG_ALIGNMENT_ERROR_STATE, stgAlignment.Status_gne__c);
        System.assertEquals(null, stgAlignment.SFDC_Account_gne__c);
        System.assertEquals(null, stgAlignment.SFDC_TSF_gne__c);
        System.assertEquals(null, stgAlignment.SFDC_Group_gne__c);
    }

    static testMethod void invalidTerritoryKeyTest() {
        prepareEnv();
        prepareInsertData();

        List<Staging_Alignment_gne__c> scope = new List<Staging_Alignment_gne__c>();
        Staging_Alignment_gne__c stgAlignment = new Staging_Alignment_gne__c();
        stgAlignment.Activaction_Date_gne__c = Date.today();
        stgAlignment.MDM_ID_gne__c = GNE_Subscribe_Process_TestDataPrepare.PARTY_MDMID;
        stgAlignment.MDM_Address_Id_gne__c = GNE_Subscribe_Process_TestDataPrepare.PARTY_LOCATION_MDMID;
        stgAlignment.Status_gne__c = GNE_Subscribe_Batch_Base.STATUS_LOADED;
        stgAlignment.Territory_Key_gne__c = 'InvalidTerritory1';
        stgAlignment.Target_gne__c = true;
        stgAlignment.Unalign_Date_gne__c = null;
        stgAlignment.Account_ID_gne__c = '0';
        scope.add(stgAlignment);
        insert scope;

        Test.startTest();
        GNE_Subscribe_Batch_Alignment subscribe = new GNE_Subscribe_Batch_Alignment();
        subscribe.initBatch();
        subscribe.execute(null, scope);

        Test.stopTest();

        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'Account', 1, 0, 0);
        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'STAGING_ALIGNMENT', 0, 1, 0);

        System.assertEquals(STG_ALIGNMENT_ERROR_STATE, stgAlignment.Status_gne__c);
        System.assertEquals(null, stgAlignment.SFDC_Account_gne__c);
        System.assertEquals(null, stgAlignment.SFDC_Group_gne__c);
        System.assertEquals(null, stgAlignment.SFDC_TSF_gne__c);

        System.assertEquals(1, [SELECT COUNT() FROM Account]);
        System.assertEquals(1, [SELECT COUNT() FROM Address_vod__c]);
        System.assertEquals(0, [SELECT COUNT() FROM TSF_vod__c]);
    }

    static testMethod void alignAndRealignTerritoryTest() {
        prepareEnv();
        prepareInsertData();

        List<Staging_Alignment_gne__c> scope = new List<Staging_Alignment_gne__c>();
        Staging_Alignment_gne__c stgAlignment;

        // align Territory
        stgAlignment = new Staging_Alignment_gne__c();
        stgAlignment.Activaction_Date_gne__c = Date.today();
        stgAlignment.MDM_ID_gne__c = GNE_Subscribe_Process_TestDataPrepare.PARTY_MDMID;
        stgAlignment.MDM_Address_Id_gne__c = GNE_Subscribe_Process_TestDataPrepare.PARTY_LOCATION_MDMID;
        stgAlignment.Status_gne__c = GNE_Subscribe_Batch_Base.STATUS_LOADED;
        stgAlignment.Territory_Key_gne__c = testTerritoryNamesCache[0];
        stgAlignment.Target_gne__c = true;
        stgAlignment.Unalign_Date_gne__c = null;
        stgAlignment.Account_ID_gne__c = '0';
        scope.add(stgAlignment);

        insert scope;

        Test.startTest();

        GNE_Subscribe_Batch_Alignment subscribe = new GNE_Subscribe_Batch_Alignment();
        subscribe.initBatch();
        subscribe.execute(null, scope);

        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'Account', 1, 0, 0);
        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'STAGING_ALIGNMENT', 0, 1, 0);
        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'TSF_vod__c', 1, 0, 0);
        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'ObjectTerritory2Association', 1, 0, 0);
        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'Address_vod__c', 1, 0, 0);

        System.assertEquals(STG_ALIGNMENT_SUCCESS_STATE, stgAlignment.Status_gne__c);
        System.assertNotEquals(null, stgAlignment.SFDC_Account_gne__c);
        System.assertNotEquals(null, stgAlignment.SFDC_Group_gne__c);
        System.assertNotEquals(null, stgAlignment.SFDC_TSF_gne__c);
        System.assertEquals(1, [SELECT COUNT() FROM Account WHERE Id = :stgAlignment.SFDC_Account_gne__c]);
        TSF_vod__c tsf = [SELECT My_Target_vod__c FROM TSF_vod__c WHERE Id = :stgAlignment.SFDC_TSF_gne__c][0];
        System.assertEquals(true, tsf.My_Target_vod__c);
        System.assertEquals(1, [SELECT COUNT() FROM TSF_vod__c WHERE Id = :stgAlignment.SFDC_TSF_gne__c]);
        System.assertEquals(1, [SELECT COUNT() FROM Group WHERE RelatedId = :stgAlignment.SFDC_Group_gne__c AND Type = 'Territory']);

        // territory double realignment
        stgAlignment.Status_gne__c = GNE_Subscribe_Batch_Base.STATUS_LOADED;
        stgAlignment.Territory_Key_gne__c = testTerritoryNamesCache[0];
        stgAlignment.Target_gne__c = true;
        stgAlignment.Unalign_Date_gne__c = null;

        stgAlignment = new Staging_Alignment_gne__c();
        stgAlignment.Activaction_Date_gne__c = Date.today().addYears(-1);
        stgAlignment.MDM_ID_gne__c = GNE_Subscribe_Process_TestDataPrepare.PARTY_MDMID;
        stgAlignment.MDM_Address_Id_gne__c = GNE_Subscribe_Process_TestDataPrepare.PARTY_LOCATION_MDMID;
        stgAlignment.Status_gne__c = GNE_Subscribe_Batch_Base.STATUS_LOADED;
        stgAlignment.Territory_Key_gne__c = testTerritoryNamesCache[0];
        stgAlignment.Target_gne__c = false;
        stgAlignment.Unalign_Date_gne__c = Date.today().addYears(1);
        stgAlignment.Account_ID_gne__c = '1';
        scope.add(stgAlignment);
        upsert scope;

        subscribe = new GNE_Subscribe_Batch_Alignment();
        subscribe.initBatch();
        subscribe.execute(null, scope);
        Test.stopTest();

        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'Account', 0, 1, 0);
        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'STAGING_ALIGNMENT', 0, 2, 0);
        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'TSF_vod__c', 1, 0, 0);

        System.assertEquals(STG_ALIGNMENT_SUCCESS_STATE, scope.get(0).Status_gne__c);
        System.assertNotEquals(null, scope.get(0).SFDC_Account_gne__c);
        System.assertNotEquals(null, scope.get(0).SFDC_Group_gne__c);
        System.assertNotEquals(null, scope.get(0).SFDC_TSF_gne__c);

        System.assertEquals(1, [SELECT COUNT() FROM Account WHERE Id = :scope.get(0).SFDC_Account_gne__c]);
        System.assertEquals(1, [SELECT COUNT() FROM Address_vod__c]);
        tsf = [SELECT My_Target_vod__c FROM TSF_vod__c WHERE Id = :scope.get(0).SFDC_TSF_gne__c][0];
        System.assertEquals(true, tsf.My_Target_vod__c);
        System.assertEquals(1, [SELECT COUNT() FROM TSF_vod__c WHERE Id = :scope.get(0).SFDC_TSF_gne__c]);
        System.assertEquals(1, [SELECT COUNT() FROM Group WHERE RelatedId = :scope.get(0).SFDC_Group_gne__c AND Type = 'Territory']);

        System.assertEquals(STG_ALIGNMENT_ERROR_STATE, scope.get(1).Status_gne__c);
        System.assert(scope.get(1).Comment_gne__c.contains(GNE_Subscribe_Batch_Alignment.TERRITORY_DUPLICATED));
    }

    static testMethod void insertAccountAndAddressNoTerritoryTest() {
        prepareEnv();
        prepareInsertData();

        List<Staging_Alignment_gne__c> scope = new List<Staging_Alignment_gne__c>();
        Staging_Alignment_gne__c stgAlignment;

        stgAlignment = new Staging_Alignment_gne__c();
        stgAlignment.Activaction_Date_gne__c = Date.today();
        stgAlignment.MDM_ID_gne__c = GNE_Subscribe_Process_TestDataPrepare.PARTY_MDMID;
        stgAlignment.MDM_Address_Id_gne__c = GNE_Subscribe_Process_TestDataPrepare.PARTY_LOCATION_MDMID;
        stgAlignment.Status_gne__c = GNE_Subscribe_Batch_Base.STATUS_LOADED;
        stgAlignment.Territory_Key_gne__c = null;
        stgAlignment.Target_gne__c = true;
        stgAlignment.Unalign_Date_gne__c = null;
        stgAlignment.Account_ID_gne__c = '0';
        scope.add(stgAlignment);
        insert scope;

        Test.startTest();
        GNE_Subscribe_Batch_Alignment subscribe = new GNE_Subscribe_Batch_Alignment();
        subscribe.initBatch();
        subscribe.execute(null, scope);

        Test.stopTest();

        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'Account', 1, 0, 0);
        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'Address_vod__c', 1, 0, 0);
        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'STAGING_ALIGNMENT', 0, 1, 0);

        System.assertEquals(STG_ALIGNMENT_SUCCESS_STATE, stgAlignment.Status_gne__c);
        System.assertNotEquals(null, stgAlignment.SFDC_Account_gne__c);
        System.assertEquals(null, stgAlignment.SFDC_Group_gne__c);
        System.assertEquals(null, stgAlignment.SFDC_TSF_gne__c);

        System.assertEquals(1, [SELECT COUNT() FROM Account WHERE Id = :stgAlignment.SFDC_Account_gne__c]);
        System.assertEquals(1, [SELECT COUNT() FROM Address_vod__c]);
        System.assertEquals(0, [SELECT COUNT() FROM TSF_vod__c WHERE Id = :stgAlignment.SFDC_TSF_gne__c]);
    }

    static testMethod void subscribeAccountAndAddressWithTwoTerritoriesTest() {
        prepareEnv();
        prepareInsertData();

        List<Staging_Alignment_gne__c> scope = new List<Staging_Alignment_gne__c>();
        Staging_Alignment_gne__c stgAlignment;

        stgAlignment = new Staging_Alignment_gne__c();
        stgAlignment.Activaction_Date_gne__c = Date.today();
        stgAlignment.MDM_ID_gne__c = GNE_Subscribe_Process_TestDataPrepare.PARTY_MDMID;
        stgAlignment.MDM_Address_Id_gne__c = GNE_Subscribe_Process_TestDataPrepare.PARTY_LOCATION_MDMID;
        stgAlignment.Status_gne__c = GNE_Subscribe_Batch_Base.STATUS_LOADED;
        stgAlignment.Territory_Key_gne__c = testTerritoryNamesCache[0];
        stgAlignment.Target_gne__c = true;
        stgAlignment.Unalign_Date_gne__c = null;
        stgAlignment.Account_ID_gne__c = '0';
        scope.add(stgAlignment);

        stgAlignment = new Staging_Alignment_gne__c();
        stgAlignment.Activaction_Date_gne__c = Date.today();
        stgAlignment.MDM_ID_gne__c = GNE_Subscribe_Process_TestDataPrepare.PARTY_MDMID;
        stgAlignment.MDM_Address_Id_gne__c = GNE_Subscribe_Process_TestDataPrepare.PARTY_LOCATION_MDMID;
        stgAlignment.Status_gne__c = GNE_Subscribe_Batch_Base.STATUS_LOADED;
        stgAlignment.Territory_Key_gne__c = testTerritoryNamesCache[1];
        stgAlignment.Target_gne__c = true;
        stgAlignment.Unalign_Date_gne__c = null;
        stgAlignment.Account_ID_gne__c = '1';
        scope.add(stgAlignment);
        insert scope;

        Test.startTest();
        GNE_Subscribe_Batch_Alignment subscribe = new GNE_Subscribe_Batch_Alignment();
        subscribe.initBatch();
        subscribe.execute(null, scope);

        Test.stopTest();

        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'Account', 1, 0, 0);
        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'STAGING_ALIGNMENT', 0, 2, 0);
        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'TSF_vod__c', 2, 0, 0);
        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'ObjectTerritory2Association', 2, 0, 0);

        for (Staging_Alignment_gne__c stgAlign : scope) {
            System.assertEquals(STG_ALIGNMENT_SUCCESS_STATE, stgAlign.Status_gne__c);
            System.assertNotEquals(null, stgAlign.SFDC_Account_gne__c);
            System.assertNotEquals(null, stgAlign.SFDC_Group_gne__c);
            System.assertNotEquals(null, stgAlign.SFDC_TSF_gne__c);
            System.assertEquals(1, [SELECT COUNT() FROM Account WHERE Id = :stgAlign.SFDC_Account_gne__c]);
            System.assertEquals(1, [SELECT COUNT() FROM Address_vod__c]);
            System.assertEquals(1, [SELECT COUNT() FROM TSF_vod__c WHERE Id = :stgAlign.SFDC_TSF_gne__c]);
            System.assertEquals(1, [SELECT COUNT() FROM Group WHERE RelatedId = :stgAlign.SFDC_Group_gne__c AND Type = 'Territory']);
        }
        System.assertEquals(2, [SELECT COUNT() FROM TSF_vod__c]);
        System.assert(scope.get(0).SFDC_Account_gne__c == scope.get(1).SFDC_Account_gne__c);
        System.assertNotEquals(scope.get(0).SFDC_Group_gne__c, scope.get(1).SFDC_Group_gne__c);
        System.assertNotEquals(scope.get(0).SFDC_TSF_gne__c, scope.get(1).SFDC_TSF_gne__c);
    }
    /*
    static testMethod void unalignTerritoryTest() {
    	prepareEnv();
        prepareInsertData();

        List<Staging_Alignment_gne__c> scope = new List<Staging_Alignment_gne__c>();
        Staging_Alignment_gne__c stgAlignment;

        stgAlignment = new Staging_Alignment_gne__c();
        stgAlignment.Activaction_Date_gne__c = date.today();
        stgAlignment.MDM_ID_gne__c = GNE_Subscribe_Process_TestDataPrepare.PARTY_MDMID;
        stgAlignment.MDM_Address_Id_gne__c = GNE_Subscribe_Process_TestDataPrepare.PARTY_LOCATION_MDMID;
        stgAlignment.Status_gne__c = GNE_Subscribe_Batch_Base.STATUS_LOADED;
        stgAlignment.Territory_Key_gne__c = testTerritoryNamesCache[0];
        stgAlignment.Target_gne__c = false;
        stgAlignment.Unalign_Date_gne__c = null;
        stgAlignment.Account_ID_gne__c = '0';
        scope.add(stgAlignment);

        insert scope;

        Test.StartTest();

        GNE_Subscribe_Batch_Alignment subscribe = new GNE_Subscribe_Batch_Alignment();

        subscribe.execute(null, scope);

        TSF_vod__c tsf = [Select My_Target_vod__c From TSF_vod__c Where id=:stgAlignment.SFDC_TSF_gne__c][0];
        System.assertEquals(false, tsf.My_Target_vod__c);
        String terr = stgAlignment.SFDC_Group_gne__c;
        System.assertEquals(1, [Select count() From Group Where RelatedId =:terr and Type='Territory']);

        stgAlignment.Status_gne__c = GNE_Subscribe_Batch_Base.STATUS_LOADED;
        stgAlignment.Territory_Key_gne__c = testTerritoryNamesCache[0];
        stgAlignment.Target_gne__c = true;
        stgAlignment.Unalign_Date_gne__c = date.today();

        Test.StopTest();

        subscribe = new GNE_Subscribe_Batch_Alignment();
        subscribe.execute(null, scope);

		checkSubscribeMetrics(subscribe.getCoreMetrics(), 'Account', 0, 1, 0);
        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'STAGING_ALIGNMENT', 0, 1, 0);
        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'TSF_vod__c', 0, 0, 1);
        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'ObjectTerritory2Association', 0, 0, 1);

        System.assertEquals(STG_ALIGNMENT_SUCCESS_STATE, stgAlignment.Status_gne__c);
        System.assertEquals(null, stgAlignment.SFDC_Account_gne__c);
        System.assertEquals(null, stgAlignment.SFDC_Group_gne__c);
        System.assertEquals(null, stgAlignment.SFDC_TSF_gne__c);

        System.assertEquals(1, [Select count() From Account Where id=:stgAlignment.SFDC_Account_gne__c]);
        System.assertEquals(1, [Select count() From Address_vod__c]);
        System.assertEquals(0, [Select count() From TSF_vod__c]);
        System.assertEquals(0, [Select count() From Group Where RelatedId=:terr and Type='Territory']);
    }
    */

    static testMethod void alignTerritoryErrorTest() {
        prepareEnv();
        prepareInsertData();

        List<Staging_Alignment_gne__c> scope = new List<Staging_Alignment_gne__c>();
        Staging_Alignment_gne__c stgAlignment;

        // Territory not exist
        stgAlignment = new Staging_Alignment_gne__c();
        stgAlignment.Activaction_Date_gne__c = Date.today();
        stgAlignment.MDM_ID_gne__c = GNE_Subscribe_Process_TestDataPrepare.PARTY_MDMID;
        stgAlignment.MDM_Address_Id_gne__c = GNE_Subscribe_Process_TestDataPrepare.PARTY_LOCATION_MDMID;
        stgAlignment.Status_gne__c = GNE_Subscribe_Batch_Base.STATUS_LOADED;
        stgAlignment.Territory_Key_gne__c = 'InvalidTerritory1';
        stgAlignment.Target_gne__c = true;
        stgAlignment.Unalign_Date_gne__c = Date.today();
        stgAlignment.Account_ID_gne__c = '0';
        scope.add(stgAlignment);
        insert scope;
        Test.startTest();

        GNE_Subscribe_Batch_Alignment subscribe = new GNE_Subscribe_Batch_Alignment();
        subscribe.initBatch();
        subscribe.execute(null, scope);

        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'Account', 1, 0, 0);
        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'STAGING_ALIGNMENT', 0, 1, 0);

        System.assertEquals(STG_ALIGNMENT_ERROR_STATE, stgAlignment.Status_gne__c);
        System.assertEquals(null, stgAlignment.SFDC_Account_gne__c);
        System.assertEquals(null, stgAlignment.SFDC_Group_gne__c);
        System.assertEquals(null, stgAlignment.SFDC_TSF_gne__c);

        System.assertEquals(1, [SELECT COUNT() FROM Account]);
        System.assertEquals(1, [SELECT COUNT() FROM Address_vod__c]);
        System.assertEquals(0, [SELECT COUNT() FROM TSF_vod__c]);

        // Account not belong to territory
        stgAlignment.Status_gne__c = GNE_Subscribe_Batch_Base.STATUS_LOADED;
        stgAlignment.Territory_Key_gne__c = testTerritoryNamesCache[1];
        stgAlignment.Target_gne__c = true;
        //stgAlignment.Unalign_Date_gne__c = date.today();

        update scope;

        Test.stopTest();

        subscribe = new GNE_Subscribe_Batch_Alignment();
        subscribe.initBatch();
        subscribe.execute(null, scope);

        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'Account', 0, 1, 0);
        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'STAGING_ALIGNMENT', 0, 1, 0);
        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'TSF_vod__c', 1, 0, 0);
        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'ObjectTerritory2Association', 1, 0, 0);

        System.assertEquals(STG_ALIGNMENT_SUCCESS_STATE, stgAlignment.Status_gne__c);
        System.assertNotEquals(null, stgAlignment.SFDC_Account_gne__c);
        System.assertNotEquals(null, stgAlignment.SFDC_Group_gne__c);
        System.assertNotEquals(null, stgAlignment.SFDC_TSF_gne__c);

        System.assertEquals(1, [SELECT COUNT() FROM Account]);
        System.assertEquals(1, [SELECT COUNT() FROM Address_vod__c]);
        System.assertEquals(1, [SELECT COUNT() FROM TSF_vod__c]);
    }

    private static void prepareInsertData() {
        GNE_Subscribe_Process_TestDataPrepare dataPrepare = new GNE_Subscribe_Process_TestDataPrepare();
        dataPrepare.insertPartyStructureForSubscribeCreate();
    }

    private static void prepareUpdateData() {
        Map<String, Schema.RecordTypeInfo> accountRecordType = new Map<String, Schema.RecordTypeInfo>();
        accountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName();
        Id hcpId = accountRecordType.get('Health Care Professional (Prescriber)').getRecordTypeId();
        Account a = new Account(RecordTypeId = hcpId,
                FirstName = GNE_Subscribe_Process_TestDataPrepare.INDIVIDUAL_FIRST_NAME,
                LastName = GNE_Subscribe_Process_TestDataPrepare.INDIVIDUAL_LAST_NAME,
                MDMID_gne__c = GNE_Subscribe_Process_TestDataPrepare.PARTY_MDMID
        );
        insert a;

        Address_vod__c adr = new Address_vod__c(
                Name = GNE_Subscribe_Process_TestDataPrepare.SECONDARY_ADDRESS_UNIT_TYPE_CODE + ' ' + GNE_Subscribe_Process_TestDataPrepare.SECONDARY_ADDRESS_VALUE,
                Account_vod__c = a.Id,
                State_vod__c = GNE_Subscribe_Process_TestDataPrepare.STATE_PROVINCE,
                Zip_vod__c = GNE_Subscribe_Process_TestDataPrepare.POSTAL_AREA_NAME,
                City_vod__c = GNE_Subscribe_Process_TestDataPrepare.PHYSICAL_ADDR_CITY,
                MDM_Address_ID_gne__c = GNE_Subscribe_Process_TestDataPrepare.PARTY_LOCATION_MDMID);
        insert adr;

        GNE_Subscribe_Process_TestDataPrepare dataPrepare = new GNE_Subscribe_Process_TestDataPrepare();
        dataPrepare.insertPartyStructureForSubscribeUpdate();
    }

    static testMethod void internallyStewardedAccountsTest() {
        prepareEnv();
        prepareInsertData();
        insert new GNE_Foun_Misc_Config_Items_gne__c(Name = 'InternallyStewardedAccounts', Configuration_Value_gne__c = GNE_Subscribe_Process_TestDataPrepare.ORGANIZATION_ROLE_TYPE_HOSP);

        List<Staging_Alignment_gne__c> scope = new List<Staging_Alignment_gne__c>();
        Staging_Alignment_gne__c stgAlignment;

        stgAlignment = new Staging_Alignment_gne__c();
        stgAlignment.Activaction_Date_gne__c = Date.today();
        stgAlignment.MDM_ID_gne__c = GNE_Subscribe_Process_TestDataPrepare.PARTY_MDMID_2;
        stgAlignment.MDM_Address_Id_gne__c = GNE_Subscribe_Process_TestDataPrepare.PARTY_LOCATION_MDMID_2;
        stgAlignment.Status_gne__c = GNE_Subscribe_Batch_Base.STATUS_LOADED;
        stgAlignment.Territory_Key_gne__c = testTerritoryNamesCache[0];
        stgAlignment.Target_gne__c = true;
        stgAlignment.Unalign_Date_gne__c = null;
        stgAlignment.Account_ID_gne__c = '0';
        scope.add(stgAlignment);
        insert scope;

        Test.startTest();
        GNE_Subscribe_Batch_Alignment subscribe = new GNE_Subscribe_Batch_Alignment();
        subscribe.initBatch();
        subscribe.execute(null, scope);

        Test.stopTest();
        System.assertEquals(STG_ALIGNMENT_ERROR_STATE, stgAlignment.Status_gne__c);
        System.assertEquals(0, [SELECT COUNT() FROM Account]);
        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'Account', 0, 0, 0);
        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'Address_vod__c', 0, 0, 0);
        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'STAGING_ALIGNMENT', 0, 1, 0);
        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'TSF_vod__c', 0, 0, 0);
        checkSubscribeMetrics(subscribe.getCoreMetrics(), 'ObjectTerritory2Association', 0, 0, 0);
        System.assert(stgAlignment.Comment_gne__c.startsWith(GNE_Subscribe_Batch_Alignment.ACCOUNT_SFDC_ID_MISSING));

        Map<String, Schema.RecordTypeInfo> accountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName();
        Id hospId = accountRecordType.get('Hospital').getRecordTypeId();
        Account a = new Account(RecordTypeId = hospId, Name = GNE_Subscribe_Process_TestDataPrepare.ORG_NAME, MDMID_gne__c = GNE_Subscribe_Process_TestDataPrepare.PARTY_MDMID_2);
        insert a;

        Address_vod__c adr = new Address_vod__c(
                Name = GNE_Subscribe_Process_TestDataPrepare.SECONDARY_ADDRESS_UNIT_TYPE_CODE + ' ' + GNE_Subscribe_Process_TestDataPrepare.SECONDARY_ADDRESS_VALUE,
                Account_vod__c = a.Id,
                State_vod__c = GNE_Subscribe_Process_TestDataPrepare.STATE_PROVINCE,
                Zip_vod__c = GNE_Subscribe_Process_TestDataPrepare.POSTAL_AREA_NAME,
                City_vod__c = GNE_Subscribe_Process_TestDataPrepare.PHYSICAL_ADDR_CITY,
                MDM_Address_ID_gne__c = GNE_Subscribe_Process_TestDataPrepare.PARTY_LOCATION_MDMID_2);
        insert adr;

        stgAlignment.Status_gne__c = GNE_Subscribe_Batch_Base.STATUS_LOADED;

        subscribe = new GNE_Subscribe_Batch_Alignment();
        subscribe.initBatch();
        subscribe.execute(null, scope);

        System.assertEquals(STG_ALIGNMENT_SUCCESS_STATE, stgAlignment.Status_gne__c);

        System.assertEquals(1, [SELECT COUNT() FROM Account WHERE Id = :stgAlignment.SFDC_Account_gne__c]);
        System.assertEquals(1, [SELECT COUNT() FROM Address_vod__c]);
        System.assertEquals(1, [SELECT COUNT() FROM TSF_vod__c WHERE Id = :stgAlignment.SFDC_TSF_gne__c]);
        System.assertEquals(1, [SELECT COUNT() FROM Group WHERE RelatedId = :stgAlignment.SFDC_Group_gne__c AND Type = 'Territory']);
    }

    private static void prepareCustomSettings() {
        insert new List<GNE_SFA2_Addr_Valid_Excluded_Profiles__c>{
                new GNE_SFA2_Addr_Valid_Excluded_Profiles__c(Name = 'System Administrator', Profile_Name__c = 'System Administrator'),
                new GNE_SFA2_Addr_Valid_Excluded_Profiles__c(Name = 'GNE-SYS-Support', Profile_Name__c = 'GNE-SYS-Support'),
                new GNE_SFA2_Addr_Valid_Excluded_Profiles__c(Name = 'GNE-SFA-InternalUser', Profile_Name__c = 'GNE-SFA-InternalUser'),
                new GNE_SFA2_Addr_Valid_Excluded_Profiles__c(Name = 'GNE-SYS-AutomatedJob', Profile_Name__c = 'GNE-SYS-AutomatedJob')
        };
    }

    private static void checkSubscribeMetrics(CORE_Subscribe_Metrics metrics, String targetObject, Integer upsertCount, Integer updateCount, Integer deleteCount) {
        Boolean containsMetrics = false;
        for (CORE_Subscribe_Metrics node : metrics.relatedMetrics) {
            if (node.targetObject == targetObject) {
                System.assertEquals(upsertCount, node.upsertCount + node.insertCount);
                System.assertEquals(updateCount, node.updateCount);
                System.assertEquals(deleteCount, node.deleteCount);
                containsMetrics = true;
                break;
            }
        }
        if (!containsMetrics) {
            System.assertEquals(upsertCount, 0);
            System.assertEquals(updateCount, 0);
            System.assertEquals(deleteCount, 0);
        }
    }

    private static List<Staging_Alignment_gne__c> getAllAlignments() {
        return [
                SELECT Id, Account_ID_gne__c, MDM_Address_Id_gne__c, Territory_Key_gne__c, Target_gne__c, Zip_Code_gne__c, Source_gne__c,
                        Activaction_Date_gne__c, SFDC_Account_gne__c, SFDC_TSF_gne__c, SFDC_Group_gne__c, Status_gne__c, Comment_gne__c
                FROM Staging_Alignment_gne__c
                ORDER BY Territory_Key_gne__c NULLS FIRST, Account_ID_gne__c NULLS FIRST
        ];
    }
}