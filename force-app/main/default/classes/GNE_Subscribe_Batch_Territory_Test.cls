@isTest
private class GNE_Subscribe_Batch_Territory_Test {

	private static final String STG_TERRITORY_NEW_STATE = 'Loaded';
	private static final String STG_TERRITORY_ERROR_STATE = 'Error Processing';
	private static final String STG_TERRITORY_SUCCESS_STATE = 'Processed';
	private static final String SALESFOCE_CODE = 'AVS';
	private static final String SALESFOCE_SUBTEAM_CODE = 'AVS';

    static testMethod void notActiveRecordsTest() {

    	List<Staging_Territory_Def_gne__c> scope = new List<Staging_Territory_Def_gne__c>();
        Staging_Territory_Def_gne__c stgTerritory;

        stgTerritory = new Staging_Territory_Def_gne__c();
        stgTerritory.Activation_Date_gne__c = date.today().addYears(1);
        stgTerritory.Territory_Nbr_gne__c = 'Invalid terrtitory number';
        stgTerritory.Territory_Name_gne__c = 'Invalid territory name';
        stgTerritory.Parent_Territory_External_ID_gne__c = 'Invalid parent territory id';
        stgTerritory.Status_gne__c = STG_TERRITORY_NEW_STATE;
        stgTerritory.Salesforce_Code_gne__c = SALESFOCE_CODE;
        stgTerritory.Salesforce_SubTeam_Code_gne__c = SALESFOCE_SUBTEAM_CODE;
        scope.add(stgTerritory);

        insert scope;

        Set<String> scopeIds = new Set<String>();
        for(Staging_Territory_Def_gne__c s : scope) {
        	scopeIds.add(s.Id);
        }

        GNE_Subscribe_Batch_Territory subscribe = new GNE_Subscribe_Batch_Territory(false);

        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs (thisUser) {
	        Test.StartTest();
	        //Database.executeBatch(subscribe);
	        new GNE_Subscribe_Territory(false);
	        Test.StopTest();
        }

        List<Staging_Territory_Def_gne__c> scopeAfterTest = [Select Id, CreatedDate, LastModifiedDate, Territory_Name_gne__c, Parent_Territory_External_ID_gne__c, Territory_ID_gne__c, Status_gne__c, Comment_gne__c,Salesforce_Code_gne__c,Salesforce_SubTeam_Code_gne__c  from Staging_Territory_Def_gne__c where Id in :scopeIds];

        for (Staging_Territory_Def_gne__c stgTerr : scopeAfterTest) {
        	System.assertEquals(STG_TERRITORY_NEW_STATE, stgTerr.Status_gne__c);
        	System.assertEquals(null, stgTerritory.Territory_ID_gne__c);
        	System.assertEquals(null, stgTerritory.Comment_gne__c);
        	System.assertEquals(stgTerritory.CreatedDate, stgTerritory.LastModifiedDate);
        }
    }

    static testMethod void activationDatePastEndDateTest() {

    	List<Staging_Territory_Def_gne__c> scope = new List<Staging_Territory_Def_gne__c>();
        Staging_Territory_Def_gne__c stgTerritory;

        stgTerritory = new Staging_Territory_Def_gne__c();
        stgTerritory.Activation_Date_gne__c = date.today().addYears(1);
        stgTerritory.End_Date_gne__c = date.today();
        stgTerritory.Territory_Nbr_gne__c = 'Invalid terrtitory number';
        stgTerritory.Territory_Name_gne__c = 'Invalid territory name';
        stgTerritory.Parent_Territory_External_ID_gne__c = 'Invalid parent territory id';
        stgTerritory.Territory_External_ID_gne__c = 'Invalid external id';
        stgTerritory.Status_gne__c = STG_TERRITORY_NEW_STATE;
        stgTerritory.Salesforce_Code_gne__c = SALESFOCE_CODE;
        stgTerritory.Salesforce_SubTeam_Code_gne__c = SALESFOCE_SUBTEAM_CODE;
        scope.add(stgTerritory);

        insert scope;

        Set<String> scopeIds = new Set<String>();
        for(Staging_Territory_Def_gne__c s : scope) {
        	scopeIds.add(s.Id);
        }

        //GNE_Subscribe_Batch_Territory subscribe = new GNE_Subscribe_Batch_Territory(false);

        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs (thisUser) {
	        Test.StartTest();
	        new GNE_Subscribe_Territory(false);
	        //Database.executeBatch(subscribe);
	        Test.StopTest();
        }

        List<Staging_Territory_Def_gne__c> scopeAfterTest = [Select Id, Territory_Name_gne__c, Parent_Territory_External_ID_gne__c, Territory_ID_gne__c, Status_gne__c, Comment_gne__c, Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c from Staging_Territory_Def_gne__c where Id in :scopeIds];

        for (Staging_Territory_Def_gne__c stgTerr : scopeAfterTest) {
        	System.assertEquals(STG_TERRITORY_ERROR_STATE, stgTerr.Status_gne__c);
        	System.assert(stgTerr.Comment_gne__c.contains(GNE_Subscribe_Batch_Territory.COMMENT_RESULT_STATUS_ERROR));
        	System.assertEquals(null, stgTerritory.Territory_ID_gne__c);
        }
    }

    static testMethod void alreadyProcessedRecordsTest() {

    	List<Staging_Territory_Def_gne__c> scope = new List<Staging_Territory_Def_gne__c>();
        Staging_Territory_Def_gne__c stgTerritory;

        stgTerritory = new Staging_Territory_Def_gne__c();
        stgTerritory.Activation_Date_gne__c = date.today();
        stgTerritory.Territory_Nbr_gne__c = 'Invalid terrtitory number';
        stgTerritory.Territory_Name_gne__c = 'Invalid territory name';
        stgTerritory.Parent_Territory_External_ID_gne__c = 'Invalid parent territory id 1';
        stgTerritory.Territory_External_ID_gne__c = 'Invalid external id 1';
        stgTerritory.Status_gne__c = STG_TERRITORY_ERROR_STATE;
        stgTerritory.Salesforce_Code_gne__c = SALESFOCE_CODE;
        stgTerritory.Salesforce_SubTeam_Code_gne__c = SALESFOCE_SUBTEAM_CODE;
        scope.add(stgTerritory);

        stgTerritory = new Staging_Territory_Def_gne__c();
        stgTerritory.Activation_Date_gne__c = date.today();
        stgTerritory.Territory_Nbr_gne__c = 'Invalid terrtitory number';
        stgTerritory.Territory_Name_gne__c = 'Invalid territory name';
        stgTerritory.Parent_Territory_External_ID_gne__c = 'Invalid parent territory id 2';
        stgTerritory.Territory_External_ID_gne__c = 'Invalid external id 2';
        stgTerritory.Status_gne__c = STG_TERRITORY_SUCCESS_STATE;
        stgTerritory.Salesforce_Code_gne__c = SALESFOCE_CODE;
        stgTerritory.Salesforce_SubTeam_Code_gne__c = SALESFOCE_SUBTEAM_CODE;
        scope.add(stgTerritory);

        insert scope;

        Set<String> scopeIds = new Set<String>();
        for(Staging_Territory_Def_gne__c s : scope) {
        	scopeIds.add(s.Id);
        }


        GNE_Subscribe_Batch_Territory subscribe = new GNE_Subscribe_Batch_Territory(false);

        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs (thisUser) {
	        Test.StartTest();
	        //DataBase.executeBatch(subscribe);
	        new GNE_Subscribe_Territory(false);
	        Test.StopTest();
        }

	    List<Staging_Territory_Def_gne__c> scopeAfterTest = [Select Id, CreatedDate, LastModifiedDate, Territory_Name_gne__c, Parent_Territory_External_ID_gne__c, Territory_ID_gne__c, Status_gne__c, Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c from Staging_Territory_Def_gne__c where Id in :scopeIds];
	    for (Staging_Territory_Def_gne__c stgTerr : scopeAfterTest) {
	       	System.assertEquals(null, stgTerr.Territory_ID_gne__c);
	       	System.assertEquals(stgTerr.CreatedDate, stgTerr.LastModifiedDate);
	    }
    }

    static testMethod void createNewTerritoryTest() {
    	// 07-12-2013 Dominik Wasilewski added Salesforce_Code_gne__c and Salesforce_SubTeam_Code_gne__c to logic
    	Territory2 terr = createTerritory('ParentTerritory1', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME, 'description0', date.today().addYears(1), 'SOURCE0');
        System.debug('parentTerritory: ' + [SELECT Name, id, External_Id_gne__c, parent_external_id_gne__c, ParentTerritory2Id FROM Territory2 where id=:terr.Id][0].Name);
    	List<Staging_Territory_Def_gne__c> scope = new List<Staging_Territory_Def_gne__c>();
        Staging_Territory_Def_gne__c stgTerritory;

        stgTerritory = new Staging_Territory_Def_gne__c();
        stgTerritory.Activation_Date_gne__c = date.today();
        stgTerritory.Territory_Nbr_gne__c = '001122334455';
        stgTerritory.Territory_Name_gne__c = 'TestTerritoryName1';
        stgTerritory.Parent_Territory_External_ID_gne__c =  GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1';
        stgTerritory.Status_gne__c = STG_TERRITORY_NEW_STATE;
        stgTerritory.End_Date_gne__c = date.today().addYears(1);
        stgTerritory.Territory_Description_gne__c = 'descripton1';
        stgTerritory.Territory_Source_gne__c = 'SOURCE1';
        stgTerritory.Salesforce_Code_gne__c = SALESFOCE_CODE;
        stgTerritory.Salesforce_SubTeam_Code_gne__c = SALESFOCE_SUBTEAM_CODE;
        scope.add(stgTerritory);

        insert scope;

        System.debug('scope: ' + scope);

        Set<String> scopeIds = new Set<String>();
        for(Staging_Territory_Def_gne__c s : scope) {
        	scopeIds.add(s.Id);
        }

		GNE_Subscribe_Batch_Territory subscribe = new GNE_Subscribe_Batch_Territory(false);

		User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs (thisUser) {
        	Test.StartTest();
	    	//Database.executeBatch(subscribe);
	    	new GNE_Subscribe_Territory(false);
	    	Test.StopTest();
	    }

        List<Staging_Territory_Def_gne__c> scopeAfterTest = [Select Id, Territory_Name_gne__c, Parent_Territory_External_ID_gne__c, Territory_ID_gne__c, Status_gne__c, Comment_gne__c, Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c from Staging_Territory_Def_gne__c where Id in :scopeIds];
		system.debug(scopeAfterTest);
	    System.assertEquals(STG_TERRITORY_SUCCESS_STATE, scopeAfterTest[0].Status_gne__c, [SELECT id, External_Id_gne__c FROM Territory2 where Name=:stgTerritory.Territory_Name_gne__c]);
	    System.assert(scopeAfterTest[0].Comment_gne__c.contains(GNE_Subscribe_Batch_Territory.COMMENT_RESULT_STATUS_NEW));

	    System.assertNotEquals(null, scopeAfterTest[0].Territory_ID_gne__c);
	    System.assertNotEquals('', scopeAfterTest[0].Territory_ID_gne__c);

        Territory2 result = [Select Description, Name, external_id_gne__c, End_Date__c, parent_external_id_gne__c, source_gne__c, Territory_Number_gne__c, AccountAccessLevel, Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c  From Territory2 where id =: scopeAfterTest[0].Territory_ID_gne__c][0];
		system.debug(result);
		system.debug(result.Territory_Number_gne__c);
        assertTerritory(stgTerritory, result);
    }

    static testMethod void createNewTerritoryInPreviewModeTest() {

    	createTerritory('ParentTerritory1', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME);

    	List<Staging_Territory_Def_gne__c> scope = new List<Staging_Territory_Def_gne__c>();
        Staging_Territory_Def_gne__c stgTerritory;

        stgTerritory = new Staging_Territory_Def_gne__c();
        stgTerritory.Activation_Date_gne__c = date.today();
        stgTerritory.Territory_Nbr_gne__c = '001122334455';
        stgTerritory.Territory_Name_gne__c = 'TestTerritoryName1';
        stgTerritory.Parent_Territory_External_ID_gne__c =  GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1';
        stgTerritory.Status_gne__c = STG_TERRITORY_NEW_STATE;
        stgTerritory.End_Date_gne__c = date.today().addYears(1);
        stgTerritory.Territory_Description_gne__c = 'descripton1';
        stgTerritory.Territory_Source_gne__c = 'SOURCE1';
        stgTerritory.Salesforce_Code_gne__c = SALESFOCE_CODE;
        stgTerritory.Salesforce_SubTeam_Code_gne__c = SALESFOCE_SUBTEAM_CODE;
        scope.add(stgTerritory);

        insert scope;

        Set<String> scopeIds = new Set<String>();
        for(Staging_Territory_Def_gne__c s : scope) {
        	scopeIds.add(s.Id);
        }

		GNE_Subscribe_Batch_Territory subscribe = new GNE_Subscribe_Batch_Territory(true);
		User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs (thisUser) {
        	Test.StartTest();
	    	//DataBase.executeBatch(subscribe);
	    	new GNE_Subscribe_Territory(true);
	    	Test.StopTest();
	    }

		String commentTag = GNE_Subscribe_Batch_Territory.COMMENT_PREVIEW_MODE_PREFIX + ' ' + GNE_Subscribe_Batch_Territory.COMMENT_RESULT_STATUS_NEW.substring(1);

	    List<Staging_Territory_Def_gne__c> scopeAfterTest = [Select Id, Territory_Name_gne__c, Parent_Territory_External_ID_gne__c, Territory_ID_gne__c, Status_gne__c, Comment_gne__c, Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c from Staging_Territory_Def_gne__c where Id in :scopeIds];
	    system.debug(scopeAfterTest);
		System.assertEquals(STG_TERRITORY_NEW_STATE, scopeAfterTest[0].Status_gne__c);
		System.assertNotEquals(null,scopeAfterTest[0].Comment_gne__c);
		System.assert(scopeAfterTest[0].Comment_gne__c.contains(commentTag));
	    System.assertNotEquals(null, scopeAfterTest[0].Territory_ID_gne__c);
	    System.assertNotEquals('', scopeAfterTest[0].Territory_ID_gne__c);
    }

    static testMethod void createBigAmountNewTerritoriesTest() {

    	// 07-12-2013 Dominik Wasilewski added Salesforce_Code_gne__c and Salesforce_SubTeam_Code_gne__c to logic
    	//createTerritory('ParentTerritory1', 'ParentTerritory1', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME);

    	List<Staging_Territory_Def_gne__c> scope = new List<Staging_Territory_Def_gne__c>();
        Staging_Territory_Def_gne__c stgTerritory;
		Id terrModelId = [SELECT Id FROM Territory2Model LIMIT 1].Id;
    	Id terrTypeId = [SELECT Id FROM Territory2Type LIMIT 1].Id;
        for(Integer i = 0; i < 20; i++){
        	Territory2 terr2 = createTerritory('ParentTerritory' + i, GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory' + i, GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME, null, null, null, terrModelId, terrTypeId);
	        stgTerritory = new Staging_Territory_Def_gne__c();
	        stgTerritory.Activation_Date_gne__c = date.today();
	        stgTerritory.Territory_Nbr_gne__c = '001122334455' + i;
	        stgTerritory.Territory_Name_gne__c = 'TestTerritoryName' + i;
	        stgTerritory.Parent_Territory_External_ID_gne__c = GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME  + ';ParentTerritory' + i;
	        stgTerritory.Status_gne__c = STG_TERRITORY_NEW_STATE;
	        stgTerritory.End_Date_gne__c = date.today().addYears(1);
	        stgTerritory.Territory_Description_gne__c = 'descripton1';
	        stgTerritory.Territory_Source_gne__c = 'SOURCE1';
	        stgTerritory.Salesforce_Code_gne__c = SALESFOCE_CODE;
            stgTerritory.Salesforce_SubTeam_Code_gne__c = SALESFOCE_SUBTEAM_CODE;
	        scope.add(stgTerritory);
        }
        insert scope;

        Set<String> scopeIds = new Set<String>();
        for(Staging_Territory_Def_gne__c s : scope) {
        	scopeIds.add(s.Id);
        }

		GNE_Subscribe_Batch_Territory subscribe = new GNE_Subscribe_Batch_Territory(false);

		User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs (thisUser) {
        	Test.StartTest();
	    	//DataBase.executeBatch(subscribe);
	    	new GNE_Subscribe_Territory(false);
	    	
	    	Test.StopTest();
	    }

        List<Staging_Territory_Def_gne__c> scopeAfterTest = [Select Id, Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c, End_Date_gne__c, Territory_Description_gne__c, Territory_Source_gne__c, Territory_Name_gne__c, Parent_Territory_External_ID_gne__c, Territory_ID_gne__c, Territory_Nbr_gne__c, Status_gne__c, Comment_gne__c from Staging_Territory_Def_gne__c where Id in :scopeIds];
	    for(Staging_Territory_Def_gne__c std : scopeAfterTest){
		    System.assertEquals(STG_TERRITORY_SUCCESS_STATE, scopeAfterTest[0].Status_gne__c);

		    System.assertNotEquals(null, std.Territory_ID_gne__c);
		    System.assertNotEquals('', std.Territory_ID_gne__c);
	    	System.assert(std.Comment_gne__c.contains(GNE_Subscribe_Batch_Territory.COMMENT_RESULT_STATUS_NEW));
	        Territory2 result = [Select Description, Name, external_id_gne__c, End_Date__c, parent_external_id_gne__c, source_gne__c, Territory_Number_gne__c, AccountAccessLevel, Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c From Territory2 where id =: std.Territory_ID_gne__c][0];
	        assertTerritory(std, result);
	    }
    }

    // tests adding territories, when root has invalid parent id
    static testMethod void createTerritoryHierarchyWithInvalidParentIdTest() {

    	createTerritory('ParentTerritory1', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME);

    	List<Staging_Territory_Def_gne__c> scope = new List<Staging_Territory_Def_gne__c>();
        Staging_Territory_Def_gne__c stgTerritory;

        stgTerritory = new Staging_Territory_Def_gne__c();
        stgTerritory.Activation_Date_gne__c = date.today();
        stgTerritory.Territory_Nbr_gne__c = '001122334455';
        stgTerritory.Territory_Name_gne__c = 'TestTerritoryName1';
        stgTerritory.Parent_Territory_External_ID_gne__c = 'InvalidParent';
        stgTerritory.Status_gne__c = STG_TERRITORY_NEW_STATE;
        stgTerritory.End_Date_gne__c = date.today().addYears(1);
        stgTerritory.Territory_Description_gne__c = 'descripton1';
        stgTerritory.Territory_Source_gne__c = 'SOURCE1';
        stgTerritory.Salesforce_Code_gne__c = SALESFOCE_CODE;
        stgTerritory.Salesforce_SubTeam_Code_gne__c = SALESFOCE_SUBTEAM_CODE;
        scope.add(stgTerritory);

        stgTerritory = new Staging_Territory_Def_gne__c();
        stgTerritory.Activation_Date_gne__c = date.today();
        stgTerritory.Territory_Nbr_gne__c = '001122334455';
        stgTerritory.Territory_Name_gne__c = 'TestTerritoryName2';
        stgTerritory.Parent_Territory_External_ID_gne__c = 'TestTerritoryName1';
        stgTerritory.Status_gne__c = STG_TERRITORY_NEW_STATE;
        stgTerritory.End_Date_gne__c = date.today().addYears(1);
        stgTerritory.Territory_Description_gne__c = 'descripton1';
        stgTerritory.Territory_Source_gne__c = 'SOURCE1';
        stgTerritory.Salesforce_Code_gne__c = SALESFOCE_CODE;
        stgTerritory.Salesforce_SubTeam_Code_gne__c = SALESFOCE_SUBTEAM_CODE;
        scope.add(stgTerritory);

        stgTerritory = new Staging_Territory_Def_gne__c();
        stgTerritory.Activation_Date_gne__c = date.today();
        stgTerritory.Territory_Nbr_gne__c = '001122334455';
        stgTerritory.Territory_Name_gne__c = 'TestTerritoryName3';
        stgTerritory.Parent_Territory_External_ID_gne__c = 'TestTerritoryName2';
        stgTerritory.Territory_External_ID_gne__c = 'Invalid external id';
        stgTerritory.Status_gne__c = STG_TERRITORY_NEW_STATE;
        stgTerritory.End_Date_gne__c = date.today().addYears(1);
        stgTerritory.Territory_Description_gne__c = 'descripton1';
        stgTerritory.Territory_Source_gne__c = 'SOURCE1';
        stgTerritory.Salesforce_Code_gne__c = SALESFOCE_CODE;
        stgTerritory.Salesforce_SubTeam_Code_gne__c = SALESFOCE_SUBTEAM_CODE;
        scope.add(stgTerritory);

        insert scope;

        Set<String> scopeIds = new Set<String>();
        for(Staging_Territory_Def_gne__c s : scope) {
        	scopeIds.add(s.Id);
        }

		GNE_Subscribe_Batch_Territory subscribe = new GNE_Subscribe_Batch_Territory(false);

		User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs (thisUser) {
        	Test.StartTest();
	    	//DataBase.executeBatch(subscribe);
	    	new GNE_Subscribe_Territory(false);
	    	Test.StopTest();
	    }

        List<Staging_Territory_Def_gne__c> scopeAfterTest = [Select Id, Territory_Name_gne__c, Parent_Territory_External_ID_gne__c, Territory_ID_gne__c, Status_gne__c,Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c, Comment_gne__c from Staging_Territory_Def_gne__c where Id in :scopeIds];

	    for(Staging_Territory_Def_gne__c stgTerr : scopeAfterTest) {
	    	System.assertEquals(STG_TERRITORY_ERROR_STATE, stgTerr.Status_gne__c);
	    	System.assert(stgTerr.Comment_gne__c.contains(GNE_Subscribe_Batch_Territory.COMMENT_RESULT_STATUS_ERROR));
		    System.assertEquals(null, stgTerr.Territory_ID_gne__c);
	    }
    }

    static testMethod void updateTerritoryTest() {

		// 07-12-2013 Dominik Wasilewski added Salesforce_Code_gne__c and Salesforce_SubTeam_Code_gne__c to logic
		createTerritory('ParentTerritory3', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory3', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME);
    	createTerritory('Los Angeles-Phoenix',  GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory3;Los Angeles-Phoenix',  GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory3');

    	List<Staging_Territory_Def_gne__c> scope = new List<Staging_Territory_Def_gne__c>();
        Staging_Territory_Def_gne__c stgTerritory;

        stgTerritory = new Staging_Territory_Def_gne__c();
        stgTerritory.Activation_Date_gne__c = date.today();
        stgTerritory.Territory_Nbr_gne__c = '00BA101';
        stgTerritory.Territory_Name_gne__c = 'Los Angeles-Phoenix';
        stgTerritory.Parent_Territory_External_ID_gne__c = GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory3';
        stgTerritory.Territory_External_ID_gne__c = GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory3;Los Angeles-Phoenix';
        stgTerritory.Status_gne__c = STG_TERRITORY_NEW_STATE;
        stgTerritory.Salesforce_Code_gne__c = SALESFOCE_CODE;
        stgTerritory.Salesforce_SubTeam_Code_gne__c = SALESFOCE_SUBTEAM_CODE;
        scope.add(stgTerritory);

        insert scope;

        Set<String> scopeIds = new Set<String>();
        for(Staging_Territory_Def_gne__c s : scope) {
        	scopeIds.add(s.Id);
        }

		GNE_Subscribe_Batch_Territory subscribe = new GNE_Subscribe_Batch_Territory(false);


		User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs (thisUser) {
        	Test.StartTest();
	    	//DataBase.executeBatch(subscribe);
	    	new GNE_Subscribe_Territory(false);
	    	Test.StopTest();
	    }

		List<Staging_Territory_Def_gne__c> scopeAfterTest = [Select Id, Territory_Name_gne__c, Parent_Territory_External_ID_gne__c, Territory_ID_gne__c, Status_gne__c, Comment_gne__c, Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c from Staging_Territory_Def_gne__c where Id in :scopeIds];

        System.assertEquals(STG_TERRITORY_SUCCESS_STATE, scopeAfterTest[0].Status_gne__c);
        system.debug(scopeAfterTest[0]);
        System.assert(scopeAfterTest[0].Comment_gne__c.contains(GNE_Subscribe_Batch_Territory.COMMENT_RESULT_STATUS_UPDATE));
        System.assertNotEquals(null, scopeAfterTest[0].Territory_ID_gne__c);
        System.assertNotEquals('', scopeAfterTest[0].Territory_ID_gne__c);

        Territory2 result = [Select Description, Name, external_id_gne__c, End_Date__c, parent_external_id_gne__c, source_gne__c, Territory_Number_gne__c, AccountAccessLevel, Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c  From Territory2 where id =: scopeAfterTest[0].Territory_ID_gne__c][0];

        assertTerritory(stgTerritory, result);
    }

    static testMethod void updateTerritoryByExternalIdTest() {

    	// 07-12-2013 Dominik Wasilewski added Salesforce_Code_gne__c and Salesforce_SubTeam_Code_gne__c to logic
    	createTerritory('ParentTerritory4', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory4', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME);
    	createTerritory('Los Angeles-Phoenix', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory4;SFA;HER;HER;00BA;OCC Hercepti;00BA1;West;00BA101;Los Angeles-Phoenix', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory4' );

    	List<Staging_Territory_Def_gne__c> scope = new List<Staging_Territory_Def_gne__c>();
        Staging_Territory_Def_gne__c stgTerritory;

        stgTerritory = new Staging_Territory_Def_gne__c();
        stgTerritory.Activation_Date_gne__c = date.today();
        stgTerritory.Territory_Nbr_gne__c = '00BA101';
        stgTerritory.Territory_Name_gne__c = 'Los Angeles-Phoenix';
        stgTerritory.Territory_External_ID_gne__c = GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory4;SFA;HER;HER;00BA;OCC Hercepti;00BA1;West;00BA101;Los Angeles-Phoenix';
        stgTerritory.Parent_Territory_External_ID_gne__c = GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory4';
        stgTerritory.Status_gne__c = STG_TERRITORY_NEW_STATE;
        stgTerritory.Salesforce_Code_gne__c = SALESFOCE_CODE;
        stgTerritory.Salesforce_SubTeam_Code_gne__c = SALESFOCE_SUBTEAM_CODE;
        scope.add(stgTerritory);

        insert scope;

        Set<String> scopeIds = new Set<String>();
        for(Staging_Territory_Def_gne__c s : scope) {
        	scopeIds.add(s.Id);
        }

		GNE_Subscribe_Batch_Territory subscribe = new GNE_Subscribe_Batch_Territory(false);
		User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs (thisUser) {
        	Test.StartTest();
	    	//DataBase.executeBatch(subscribe);
	    	new GNE_Subscribe_Territory(false);
	    	Test.StopTest();
	    }

  		List<Staging_Territory_Def_gne__c> scopeAfterTest = [Select Id, Territory_Name_gne__c, Territory_Nbr_gne__c, Parent_Territory_External_ID_gne__c, Territory_ID_gne__c, Status_gne__c, Comment_gne__c, End_Date_gne__c, Territory_Source_gne__c, Territory_Description_gne__c, Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c from Staging_Territory_Def_gne__c where Id in :scopeIds];
  		System.debug('BOS::[TEST] Comment_gne__c = ' + scopeAfterTest[0].Comment_gne__c);
        System.assertEquals(STG_TERRITORY_SUCCESS_STATE, scopeAfterTest[0].Status_gne__c);
        System.assert(scopeAfterTest[0].Comment_gne__c.contains(GNE_Subscribe_Batch_Territory.COMMENT_RESULT_STATUS_UPDATE));

        System.assertNotEquals(null, scopeAfterTest[0].Territory_ID_gne__c);
        System.assertNotEquals('', scopeAfterTest[0].Territory_ID_gne__c);

        Territory2 result = [Select Description, Name, external_id_gne__c, End_Date__c, parent_external_id_gne__c, source_gne__c, Territory_Number_gne__c, AccountAccessLevel, Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c From Territory2 where id =: scopeAfterTest[0].Territory_ID_gne__c][0];

        assertTerritory(scopeAfterTest[0], result);
    }

    static testMethod void invalidTerritoryExternalIdTest() {
    	List<Staging_Territory_Def_gne__c> scope = new List<Staging_Territory_Def_gne__c>();
        Staging_Territory_Def_gne__c stgTerritory;

        stgTerritory = new Staging_Territory_Def_gne__c();
        stgTerritory.Activation_Date_gne__c = date.today();
        stgTerritory.Territory_Nbr_gne__c = '0011223344552';
        stgTerritory.Territory_Name_gne__c = 'TestTerritoryName2';
        stgTerritory.Parent_Territory_External_ID_gne__c = 'ParentTerritory2';
        stgTerritory.Territory_External_ID_gne__c = stgTerritory.Territory_Nbr_gne__c + ';' + stgTerritory.Territory_Name_gne__c;
        stgTerritory.Status_gne__c = STG_TERRITORY_NEW_STATE;
        stgTerritory.Salesforce_Code_gne__c = SALESFOCE_CODE;
        stgTerritory.Salesforce_SubTeam_Code_gne__c = SALESFOCE_SUBTEAM_CODE;
        scope.add(stgTerritory);

        insert scope;

        Set<String> scopeIds = new Set<String>();
        for(Staging_Territory_Def_gne__c s : scope) {
        	scopeIds.add(s.Id);
        }

        GNE_Subscribe_Batch_Territory subscribe = new GNE_Subscribe_Batch_Territory(false);

        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
    	System.runAs (thisUser) {
	        Test.StartTest();
	        //DataBase.executeBatch(subscribe);
	        new GNE_Subscribe_Territory(false);
	        Test.StopTest();
    	}
   		List<Staging_Territory_Def_gne__c> scopeAfterTest = [Select Id, Territory_Name_gne__c, Parent_Territory_External_ID_gne__c, Territory_ID_gne__c, Status_gne__c, Comment_gne__c, Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c from Staging_Territory_Def_gne__c where Id in :scopeIds];

        System.assertEquals(STG_TERRITORY_ERROR_STATE, scopeAfterTest[0].Status_gne__c);
        System.assert(scopeAfterTest[0].Comment_gne__c.contains(GNE_Subscribe_Batch_Territory.COMMENT_RESULT_STATUS_ERROR));
        System.assertEquals(null, scopeAfterTest[0].Territory_ID_gne__c);
    }

    static testMethod void parentTerritoryInBatchTest() {

    	createTerritory('ParentTerritory1', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME);

    	List<Staging_Territory_Def_gne__c> scope = new List<Staging_Territory_Def_gne__c>();

    	Staging_Territory_Def_gne__c stgTerritory;
        stgTerritory = new Staging_Territory_Def_gne__c();
        stgTerritory.Activation_Date_gne__c = date.today();
        stgTerritory.Territory_Nbr_gne__c = '001122334452';
        stgTerritory.Territory_Name_gne__c = 'TestTerritoryName1';
        stgTerritory.Parent_Territory_External_ID_gne__c = GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1';
        stgTerritory.Status_gne__c = STG_TERRITORY_NEW_STATE;
        stgTerritory.End_Date_gne__c = date.today().addYears(1);
        stgTerritory.Territory_Description_gne__c = 'descripton1';
        stgTerritory.Territory_Source_gne__c = 'SOURCE1';
        stgTerritory.Salesforce_Code_gne__c = SALESFOCE_CODE;
        stgTerritory.Salesforce_SubTeam_Code_gne__c = SALESFOCE_SUBTEAM_CODE;
        scope.add(stgTerritory);

        Staging_Territory_Def_gne__c stgTerritory2;
        stgTerritory2 = new Staging_Territory_Def_gne__c();
        stgTerritory2.Activation_Date_gne__c = date.today();
        stgTerritory2.Territory_Nbr_gne__c = '001122334455';
        stgTerritory2.Territory_Name_gne__c = 'TestTerritoryName2';
        stgTerritory2.Parent_Territory_External_ID_gne__c = GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1';
        stgTerritory2.Status_gne__c = STG_TERRITORY_NEW_STATE;
        stgTerritory2.End_Date_gne__c = date.today().addYears(1);
        stgTerritory2.Territory_Description_gne__c = 'descripton2';
        stgTerritory2.Territory_Source_gne__c = 'SOURCE2';
        stgTerritory.Salesforce_Code_gne__c = SALESFOCE_CODE;
        stgTerritory.Salesforce_SubTeam_Code_gne__c = SALESFOCE_SUBTEAM_CODE;
        scope.add(stgTerritory2);

        insert scope;

        Set<String> scopeIds = new Set<String>();
        for(Staging_Territory_Def_gne__c s : scope) {
        	scopeIds.add(s.Id);
        }

		GNE_Subscribe_Batch_Territory subscribe = new GNE_Subscribe_Batch_Territory(false);

		User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs (thisUser) {
        	Test.StartTest();
	    	//DataBase.executeBatch(subscribe);
	    	new GNE_Subscribe_Territory(false);
	    	Test.StopTest();
	    }

        List<Staging_Territory_Def_gne__c> scopeAfterTest = [Select Id, Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c, Territory_Name_gne__c, Territory_Nbr_gne__c, Parent_Territory_External_ID_gne__c, Territory_ID_gne__c, Status_gne__c, End_Date_gne__c, Territory_Source_gne__c, Territory_Description_gne__c, Comment_gne__c from Staging_Territory_Def_gne__c where Id in :scopeIds ORDER BY Id asc];
		system.debug(scopeAfterTest[0].Comment_gne__c);
        System.assertEquals(STG_TERRITORY_SUCCESS_STATE, scopeAfterTest[0].Status_gne__c);
		System.assert(scopeAfterTest[0].Comment_gne__c.contains(GNE_Subscribe_Batch_Territory.COMMENT_RESULT_STATUS_NEW));
		System.assertNotEquals(null, scopeAfterTest[0].Territory_ID_gne__c);
		System.assertNotEquals('', scopeAfterTest[0].Territory_ID_gne__c);

		System.assertEquals(STG_TERRITORY_SUCCESS_STATE, scopeAfterTest[1].Status_gne__c);
		System.assert(scopeAfterTest[1].Comment_gne__c.contains(GNE_Subscribe_Batch_Territory.COMMENT_RESULT_STATUS_NEW));
		System.assertNotEquals(null, scopeAfterTest[1].Territory_ID_gne__c);
		System.assertNotEquals('', scopeAfterTest[1].Territory_ID_gne__c);

		Territory2 result = [Select Description, Name, external_id_gne__c, End_Date__c, parent_external_id_gne__c, source_gne__c, Territory_Number_gne__c, AccountAccessLevel, Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c From Territory2 where id =: scopeAfterTest[0].Territory_ID_gne__c][0];
        assertTerritory(scopeAfterTest[0], result);

        Territory2 result2 = [Select Description, Name, external_id_gne__c, End_Date__c, parent_external_id_gne__c, source_gne__c, Territory_Number_gne__c, AccountAccessLevel, Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c From Territory2 where id =: scopeAfterTest[1].Territory_ID_gne__c][0];
        assertTerritory(scopeAfterTest[1], result2);
    }

	static testMethod void noChangeTerritoryTest() {
		User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];

		Territory2 terr = createTerritory('Territory1', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';Territory1',
								GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME,
								'Territory1', date.today().addYears(1), 'TEST_SOURCE');

		Territory2 resultBefore = [Select LastModifiedDate From Territory2 where External_Id_gne__c =:terr.External_Id_gne__c][0];

		List<Staging_Territory_Def_gne__c> scope = new List<Staging_Territory_Def_gne__c>();

    	Staging_Territory_Def_gne__c stgTerritory;
        stgTerritory = new Staging_Territory_Def_gne__c();
        stgTerritory.Activation_Date_gne__c = date.today();
        stgTerritory.Territory_Nbr_gne__c = terr.Name;
        stgTerritory.Territory_Name_gne__c = terr.Name;
        stgTerritory.Parent_Territory_External_ID_gne__c = terr.Parent_External_Id_gne__c;
        stgTerritory.Status_gne__c = STG_TERRITORY_NEW_STATE;
        stgTerritory.End_Date_gne__c = terr.End_Date__c;
        stgTerritory.Territory_Description_gne__c = terr.Description;
        stgTerritory.Territory_Source_gne__c = terr.Source_gne__c;
        stgTerritory.Salesforce_Code_gne__c = SALESFOCE_CODE;
        stgTerritory.Salesforce_SubTeam_Code_gne__c = SALESFOCE_SUBTEAM_CODE;
        scope.add(stgTerritory);

        insert scope;

        Set<String> scopeIds = new Set<String>();
        for(Staging_Territory_Def_gne__c s : scope) {
        	scopeIds.add(s.Id);
        }

		GNE_Subscribe_Batch_Territory subscribe = new GNE_Subscribe_Batch_Territory(false);


        System.runAs (thisUser) {
        	Test.StartTest();
	    	//DataBase.executeBatch(subscribe);
	    	new GNE_Subscribe_Territory(false);
	    	Test.StopTest();
	    }

	    List<Staging_Territory_Def_gne__c> scopeAfterTest = [Select Id, Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c, Territory_Name_gne__c, Territory_Nbr_gne__c, Parent_Territory_External_ID_gne__c, Territory_ID_gne__c, Status_gne__c, End_Date_gne__c, Territory_Source_gne__c, Territory_Description_gne__c, Comment_gne__c from Staging_Territory_Def_gne__c where Id in :scopeIds];
	    for(Staging_Territory_Def_gne__c s : scopeAfterTest) {
	    	System.debug(LoggingLevel.ERROR, 'BOS::[TEST] Comment_gne__c = ' + s.Comment_gne__c);
		    System.assertEquals(STG_TERRITORY_SUCCESS_STATE, s.Status_gne__c);
		    System.assert(s.Comment_gne__c.contains(GNE_Subscribe_Batch_Territory.COMMENT_RESULT_STATUS_NOCHANGE));

		    System.assertNotEquals(null, s.Territory_ID_gne__c);
		    System.assertNotEquals('', s.Territory_ID_gne__c);
	    }

        Territory2 result = [Select LastModifiedDate From Territory2 where id =: scopeAfterTest[0].Territory_ID_gne__c][0];

        // check if territory was untouched.
        System.assertEquals(resultBefore.LastModifiedDate, result.LastModifiedDate);
	}

	static testMethod void onlySourceAttrChangedTest() {
		User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];

		Territory2 terr = createTerritory('Territory1', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';Territory1',
								GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME,
								'Territory1', date.today().addYears(1), 'TEST_SOURCE');

		Territory2 resultBefore = [Select LastModifiedDate From Territory2 where External_Id_gne__c =:terr.External_Id_gne__c][0];

		List<Staging_Territory_Def_gne__c> scope = new List<Staging_Territory_Def_gne__c>();

    	Staging_Territory_Def_gne__c stgTerritory;
        stgTerritory = new Staging_Territory_Def_gne__c();
        stgTerritory.Activation_Date_gne__c = date.today();
        stgTerritory.Territory_Nbr_gne__c = terr.Name;
        stgTerritory.Territory_Name_gne__c = terr.Name;
        stgTerritory.Parent_Territory_External_ID_gne__c = terr.Parent_External_Id_gne__c;
        stgTerritory.Status_gne__c = STG_TERRITORY_NEW_STATE;
        stgTerritory.End_Date_gne__c = terr.End_Date__c;
        stgTerritory.Territory_Description_gne__c = terr.Description;
        stgTerritory.Territory_Source_gne__c = terr.Source_gne__c + '_NEW';
        stgTerritory.Salesforce_Code_gne__c = SALESFOCE_CODE;
        stgTerritory.Salesforce_SubTeam_Code_gne__c = SALESFOCE_SUBTEAM_CODE;
        scope.add(stgTerritory);

        insert scope;

        Set<String> scopeIds = new Set<String>();
        for(Staging_Territory_Def_gne__c s : scope) {
        	scopeIds.add(s.Id);
        }

		GNE_Subscribe_Batch_Territory subscribe = new GNE_Subscribe_Batch_Territory(false);


        System.runAs (thisUser) {
        	Test.StartTest();
	    	//DataBase.executeBatch(subscribe);
	    	new GNE_Subscribe_Territory(false);
	    	Test.StopTest();
	    }

	    List<Staging_Territory_Def_gne__c> scopeAfterTest = [Select Id, Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c, Territory_Name_gne__c, Territory_Nbr_gne__c, Parent_Territory_External_ID_gne__c, Territory_ID_gne__c, Status_gne__c, End_Date_gne__c, Territory_Source_gne__c, Territory_Description_gne__c, Comment_gne__c from Staging_Territory_Def_gne__c where Id in :scopeIds];
	    for(Staging_Territory_Def_gne__c s : scopeAfterTest) {
	    	System.debug('BOS::[TEST] Comment_gne__c = ' + s.Comment_gne__c);
		    System.assertEquals(STG_TERRITORY_SUCCESS_STATE, s.Status_gne__c);
		    System.assert(s.Comment_gne__c.contains(GNE_Subscribe_Batch_Territory.COMMENT_RESULT_STATUS_UPDATE));
		    System.assertEquals(s.Comment_gne__c.split('\\' + GNE_Subscribe_Batch_Territory.COMMENT_DELIMETER)[1].toUpperCase(),'Source_gne__c'.toUpperCase());

		    System.assertNotEquals(null, s.Territory_ID_gne__c);
		    System.assertNotEquals('', s.Territory_ID_gne__c);
	    }

        Territory2 result = [Select LastModifiedDate, Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c, Description, Name, external_id_gne__c, End_Date__c, parent_external_id_gne__c, source_gne__c, Territory_Number_gne__c, AccountAccessLevel From Territory2 where id =: scopeAfterTest[0].Territory_ID_gne__c][0];

        // check if territory was touched.
        System.assertNotEquals(resultBefore.LastModifiedDate, result.LastModifiedDate);
        System.assertEquals(result.Source_gne__c, stgTerritory.Territory_Source_gne__c);
	}

   static testMethod void deactiveOneTerritoryTest() {

    	createTerritory('ParentTerritory1', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME);
    	Territory2 resultBefore = createTerritory('TerritoryToDeactivte',  GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1;001122334455-TerritoryToDeactivte', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1');
    	system.debug(resultBefore);

    	String inactiveTerrName = 'INACTIVE TERRITORIES_TEST';
    	// create incative territory
    	createTerritory(inactiveTerrName, GNE_Subscribe_Batch_Territory.INACTIVE_ROOT_TERRITORY_NAME + ';' + inactiveTerrName, GNE_Subscribe_Batch_Territory.INACTIVE_ROOT_TERRITORY_NAME);
    	List<Territory2> inactiveTerritory = [select id, Name, external_id_gne__c, ParentTerritory2Id from Territory2 where Name = :inactiveTerrName];

    	List<Staging_Territory_Def_gne__c> scope = new List<Staging_Territory_Def_gne__c>();

        Staging_Territory_Def_gne__c stgTerritory2;
        stgTerritory2 = new Staging_Territory_Def_gne__c();
        stgTerritory2.Activation_Date_gne__c = date.today() - 10;
        stgTerritory2.Territory_Nbr_gne__c = '001122334455';
        stgTerritory2.Territory_Name_gne__c = 'TerritoryToDeactivte';
        stgTerritory2.Parent_Territory_External_ID_gne__c =  GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1';
        stgTerritory2.Status_gne__c = STG_TERRITORY_NEW_STATE;
        stgTerritory2.End_Date_gne__c = date.today();
        stgTerritory2.Territory_Description_gne__c = 'descripton1';
        stgTerritory2.Territory_Source_gne__c = 'SOURCE1';
        stgTerritory2.Salesforce_Code_gne__c = SALESFOCE_CODE;
        stgTerritory2.Salesforce_SubTeam_Code_gne__c = SALESFOCE_SUBTEAM_CODE;
        scope.add(stgTerritory2);

        insert scope;

        Set<String> scopeIds = new Set<String>();
        for(Staging_Territory_Def_gne__c s : scope) {
        	scopeIds.add(s.Id);
        }

		GNE_Subscribe_Batch_Territory subscribe = new GNE_Subscribe_Batch_Territory(false);

		User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs (thisUser) {
        	Test.StartTest();
	    	//DataBase.executeBatch(subscribe);
	    	new GNE_Subscribe_Territory(false);
	    	Test.StopTest();
	    }

        List<Staging_Territory_Def_gne__c> scopeAfterTest = [Select Id, Territory_Name_gne__c, Territory_Nbr_gne__c, Parent_Territory_External_ID_gne__c, Territory_ID_gne__c, Status_gne__c, End_Date_gne__c, Territory_Source_gne__c, Territory_Description_gne__c, Comment_gne__c from Staging_Territory_Def_gne__c where Id in :scopeIds];
	    for(Staging_Territory_Def_gne__c s : scopeAfterTest) {
	    	System.debug('BOS::[TEST] Comment_gne__c = ' + s.Comment_gne__c);
		    System.assertEquals(STG_TERRITORY_SUCCESS_STATE, s.Status_gne__c);
		    System.assert(s.Comment_gne__c.contains(GNE_Subscribe_Batch_Territory.COMMENT_RESULT_STATUS_DEACTIVATE));

		    System.assertNotEquals(null, s.Territory_ID_gne__c);
		    System.assertNotEquals('', s.Territory_ID_gne__c);
	    }

        Territory2 result = [Select Description, Name, external_id_gne__c, End_Date__c, parent_external_id_gne__c, source_gne__c, Territory_Number_gne__c, ParentTerritory2Id, AccountAccessLevel From Territory2 where id =: scopeAfterTest[0].Territory_ID_gne__c][0];
system.debug(result);

        String terrExternalId = GNE_Subscribe_Batch_Territory.INACTIVE_ROOT_TERRITORY_NAME + ';' + resultBefore.External_Id_gne__c + '_OLD';

        System.assertEquals(terrExternalId, result.external_id_gne__c);
        // check if territory was moved to inactive territories
		System.assertEquals(inactiveTerritory[0].ParentTerritory2Id, result.ParentTerritory2Id);
		System.assertEquals('INACTIVE TERRITORIES', result.parent_external_id_gne__c);
    }


	static testMethod void deactiveHierarchyOfTerritoriesTest() {

    	// create territory structure
    	createTerritory('ParentTerritory1', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME);
    	Territory2 resultBefore = createTerritory('TerritoryToDeactivte1', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1;TerritoryToDeactivte1', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1');
    	createTerritory('TerritoryToDeactivte2', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1;TerritoryToDeactivte1;TerritoryToDeactivte2', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1;TerritoryToDeactivte1');
    	createTerritory('TerritoryToDeactivte3', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1;TerritoryToDeactivte1;TerritoryToDeactivte2;TerritoryToDeactivte3', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1;TerritoryToDeactivte1;TerritoryToDeactivte2');

    	// create incative territory
    	String inactiveTerrName = 'INACTIVE TERRITORIES_TEST';
    	createTerritory(inactiveTerrName, GNE_Subscribe_Batch_Territory.INACTIVE_ROOT_TERRITORY_NAME + ';' + inactiveTerrName, GNE_Subscribe_Batch_Territory.INACTIVE_ROOT_TERRITORY_NAME);
    	List<Territory2> inactiveTerritory = [select id, Name, external_id_gne__c, ParentTerritory2Id from Territory2 where Name = :inactiveTerrName];

    	List<Staging_Territory_Def_gne__c> scope = new List<Staging_Territory_Def_gne__c>();

        Staging_Territory_Def_gne__c stgTerritory = new Staging_Territory_Def_gne__c();
        stgTerritory.Activation_Date_gne__c = date.today() - 10;
        stgTerritory.Territory_Nbr_gne__c = '001122334455';
        stgTerritory.Territory_Name_gne__c = 'TerritoryToDeactivte1';
        stgTerritory.Territory_External_ID_gne__c = GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1;TerritoryToDeactivte1';
        stgTerritory.Parent_Territory_External_ID_gne__c = GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1';
        stgTerritory.Status_gne__c = STG_TERRITORY_NEW_STATE;
        stgTerritory.End_Date_gne__c = date.today();
        stgTerritory.Territory_Description_gne__c = 'descripton1';
        stgTerritory.Territory_Source_gne__c = 'SOURCE1';
        stgTerritory.Salesforce_Code_gne__c = SALESFOCE_CODE;
        stgTerritory.Salesforce_SubTeam_Code_gne__c = SALESFOCE_SUBTEAM_CODE;
        scope.add(stgTerritory);

        insert scope;

        Set<String> scopeIds = new Set<String>();
        for(Staging_Territory_Def_gne__c s : scope) {
        	scopeIds.add(s.Id);
        }

		GNE_Subscribe_Batch_Territory subscribe = new GNE_Subscribe_Batch_Territory(false);

		User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs (thisUser) {
        	Test.StartTest();
	    	//DataBase.executeBatch(subscribe);
	    	new GNE_Subscribe_Territory(false);
	    	Test.StopTest();
	    }

        List<Staging_Territory_Def_gne__c> scopeAfterTest = [Select Id, Territory_Name_gne__c, Territory_Nbr_gne__c, Parent_Territory_External_ID_gne__c, Territory_ID_gne__c, Status_gne__c, End_Date_gne__c, Territory_Source_gne__c, Territory_Description_gne__c, Comment_gne__c from Staging_Territory_Def_gne__c where Id in :scopeIds];
        
	    for(Staging_Territory_Def_gne__c s : scopeAfterTest) {
	    	system.debug(s);
		    System.assertEquals(STG_TERRITORY_SUCCESS_STATE, s.Status_gne__c);
		    System.assert(s.Comment_gne__c.contains(GNE_Subscribe_Batch_Territory.COMMENT_RESULT_STATUS_DEACTIVATE));

		    System.assertNotEquals(null, s.Territory_ID_gne__c);
		    System.assertNotEquals('', s.Territory_ID_gne__c);
	    }

        Territory2 result = [Select Description, Name, external_id_gne__c, End_Date__c, parent_external_id_gne__c, source_gne__c, Territory_Number_gne__c, ParentTerritory2Id, AccountAccessLevel From Territory2 where id = :scopeAfterTest[0].Territory_ID_gne__c][0];
        String terrExternalId = GNE_Subscribe_Batch_Territory.INACTIVE_ROOT_TERRITORY_NAME + ';' + resultBefore.External_Id_gne__c + '_OLD';
        
        System.assertEquals(terrExternalId, result.external_id_gne__c);
        // check if territory was moved to inactive territories
		System.assertEquals(inactiveTerritory[0].ParentTerritory2Id, result.ParentTerritory2Id);
		System.assertEquals('INACTIVE TERRITORIES', result.parent_external_id_gne__c);
    }

    static testMethod void deactiveHierarchyOfTerritoriesInPreviewModeTest() {

    	// create territory structure
    	createTerritory('ParentTerritory1', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME);
    	createTerritory('TerritoryToDeactivte1', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1;TerritoryToDeactivte1', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1');
    	createTerritory('TerritoryToDeactivte2', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1;TerritoryToDeactivte1;TerritoryToDeactivte2', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1;TerritoryToDeactivte1');
    	createTerritory('TerritoryToDeactivte3', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1;TerritoryToDeactivte1;TerritoryToDeactivte2;TerritoryToDeactivte3', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1;TerritoryToDeactivte1;TerritoryToDeactivte2');

    	// create incative territory
    	String inactiveTerrName = 'INACTIVE TERRITORIES_TEST';
    	createTerritory(inactiveTerrName, GNE_Subscribe_Batch_Territory.INACTIVE_ROOT_TERRITORY_NAME + ';' + inactiveTerrName, GNE_Subscribe_Batch_Territory.INACTIVE_ROOT_TERRITORY_NAME);
    	List<Territory2> inactiveTerritory = [select id, external_id_gne__c from Territory2 where Name = :inactiveTerrName];

    	List<Staging_Territory_Def_gne__c> scope = new List<Staging_Territory_Def_gne__c>();

        Staging_Territory_Def_gne__c stgTerritory = new Staging_Territory_Def_gne__c();
        stgTerritory.Activation_Date_gne__c = date.today() - 10;
        stgTerritory.Territory_Nbr_gne__c = '001122334455';
        stgTerritory.Territory_Name_gne__c = 'TerritoryToDeactivte1';
        stgTerritory.Territory_External_ID_gne__c =  GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1;TerritoryToDeactivte1';
        stgTerritory.Parent_Territory_External_ID_gne__c = GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1';
        stgTerritory.Status_gne__c = STG_TERRITORY_NEW_STATE;
        stgTerritory.End_Date_gne__c = date.today();
        stgTerritory.Territory_Description_gne__c = 'descripton1';
        stgTerritory.Territory_Source_gne__c = 'SOURCE1';
        stgTerritory.Salesforce_Code_gne__c = SALESFOCE_CODE;
        stgTerritory.Salesforce_SubTeam_Code_gne__c = SALESFOCE_SUBTEAM_CODE;
        scope.add(stgTerritory);

        insert scope;

        List<Territory2> resultsBefore = [Select LastModifiedDate, Description, Name, external_id_gne__c, End_Date__c, parent_external_id_gne__c, source_gne__c, Territory_Number_gne__c, ParentTerritory2Id, AccountAccessLevel From Territory2 where Name like 'TerritoryToDeactivte%' ORDER BY Id asc];

        Set<String> scopeIds = new Set<String>();
        for(Staging_Territory_Def_gne__c s : scope) {
        	scopeIds.add(s.Id);
        }

		GNE_Subscribe_Batch_Territory subscribe = new GNE_Subscribe_Batch_Territory(true);

		User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs (thisUser) {
        	Test.StartTest();
	    	//DataBase.executeBatch(subscribe);
	    	new GNE_Subscribe_Territory(true);
	    	Test.StopTest();
	    }

        String commentPrefix = GNE_Subscribe_Batch_Territory.COMMENT_PREVIEW_MODE_PREFIX + ' ' + GNE_Subscribe_Batch_Territory.COMMENT_RESULT_STATUS_DEACTIVATE.substring(1);

        List<Staging_Territory_Def_gne__c> scopeAfterTest = [Select Id, Territory_Name_gne__c, Territory_Nbr_gne__c, Parent_Territory_External_ID_gne__c, Territory_ID_gne__c, Status_gne__c, End_Date_gne__c, Territory_Source_gne__c, Territory_Description_gne__c, Comment_gne__c from Staging_Territory_Def_gne__c where Id in :scopeIds];
	    for(Staging_Territory_Def_gne__c s : scopeAfterTest) {
		    System.assertEquals(STG_TERRITORY_NEW_STATE, s.Status_gne__c);
		    System.assertEquals(resultsBefore[0].Id,s.Territory_ID_gne__c);
		    System.assert(s.Comment_gne__c!=null && s.Comment_gne__c.contains(commentPrefix));
	    }

        List<Territory2> resultsAfter = [Select LastModifiedDate, Description, Name, external_id_gne__c, End_Date__c, parent_external_id_gne__c, source_gne__c, Territory_Number_gne__c, ParentTerritory2Id, AccountAccessLevel From Territory2 where Name like 'TerritoryToDeactivte%' ORDER BY Id asc];
        System.assertEquals(3, resultsAfter.size());
        for(Integer i=0;i<resultsAfter.size();i++) {
        	System.assertEquals(resultsBefore[i].LastModifiedDate, resultsAfter[i].LastModifiedDate);
        }

    }

    static testMethod void recordsNotActiveForDeactivateTerritoryTest() {

    	createTerritory('ParentTerritory1', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME);
    	createTerritory('TerritoryToDeactivte', 'ParentTerritory1;TerritoryToDeactivte', 'ParentTerritory1');

    	List<Staging_Territory_Def_gne__c> scope = new List<Staging_Territory_Def_gne__c>();

		Staging_Territory_Def_gne__c stgTerritory;
        stgTerritory = new Staging_Territory_Def_gne__c();
        stgTerritory.Activation_Date_gne__c = date.today() - 10;
        stgTerritory.Territory_Nbr_gne__c = '001122334455';
        stgTerritory.Territory_Name_gne__c = 'TerritoryToDeactivte';
        stgTerritory.Parent_Territory_External_ID_gne__c = GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1';
        stgTerritory.Status_gne__c = STG_TERRITORY_SUCCESS_STATE;
        stgTerritory.End_Date_gne__c = date.today();
        stgTerritory.Territory_Description_gne__c = 'descripton1';
        stgTerritory.Territory_Source_gne__c = 'SOURCE1';
        stgTerritory.Salesforce_Code_gne__c = SALESFOCE_CODE;
        stgTerritory.Salesforce_SubTeam_Code_gne__c = SALESFOCE_SUBTEAM_CODE;
        scope.add(stgTerritory);

        Staging_Territory_Def_gne__c stgTerritory3;
        stgTerritory3 = new Staging_Territory_Def_gne__c();
        stgTerritory3.Activation_Date_gne__c = date.today() - 10;
        stgTerritory3.Territory_Nbr_gne__c = '001122334455';
        stgTerritory3.Territory_Name_gne__c = 'TerritoryToDeactivte';
        stgTerritory3.Parent_Territory_External_ID_gne__c = GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1;TerritoryToDeactivte';
        stgTerritory3.Status_gne__c = STG_TERRITORY_ERROR_STATE;
        stgTerritory3.End_Date_gne__c = date.today();
        stgTerritory3.Territory_Description_gne__c = 'descripton1';
        stgTerritory3.Territory_Source_gne__c = 'SOURCE1';
        stgTerritory3.Salesforce_Code_gne__c = SALESFOCE_CODE;
        stgTerritory3.Salesforce_SubTeam_Code_gne__c = SALESFOCE_SUBTEAM_CODE;
        scope.add(stgTerritory3);

        insert scope;

        Set<String> scopeIds = new Set<String>();
        for(Staging_Territory_Def_gne__c s : scope) {
        	scopeIds.add(s.Id);
        }

		GNE_Subscribe_Batch_Territory subscribe = new GNE_Subscribe_Batch_Territory(false);

		User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs (thisUser) {
        	Test.StartTest();
	    	//DataBase.executeBatch(subscribe);
	    	new GNE_Subscribe_Territory(false);
	    	Test.StopTest();
	    }

        List<Staging_Territory_Def_gne__c> scopeAfterTest = [Select Id, Territory_Name_gne__c, Territory_Nbr_gne__c, Parent_Territory_External_ID_gne__c, Territory_ID_gne__c, Status_gne__c, End_Date_gne__c, Territory_Source_gne__c, Territory_Description_gne__c, Comment_gne__c from Staging_Territory_Def_gne__c where Id in :scopeIds];
	    for(Staging_Territory_Def_gne__c s : scopeAfterTest) {
		    System.assertEquals(null, s.Territory_ID_gne__c);
	    }
    }

	static testMethod void invalidTerritoryExternalIdDecvitactonTest() {
    	List<Staging_Territory_Def_gne__c> scope = new List<Staging_Territory_Def_gne__c>();
        Staging_Territory_Def_gne__c stgTerritory;

        stgTerritory = new Staging_Territory_Def_gne__c();
        stgTerritory.Activation_Date_gne__c = date.today() - 10;
        stgTerritory.Territory_Nbr_gne__c = '0011223344552';
        stgTerritory.Territory_Name_gne__c = 'TestTerritoryName2';
        stgTerritory.Parent_Territory_External_ID_gne__c = 'ParentTerritory2';
        stgTerritory.Territory_External_ID_gne__c = 'InvalidExternalID';
        stgTerritory.Status_gne__c = STG_TERRITORY_NEW_STATE;
        stgTerritory.End_Date_gne__c = date.today();
        stgTerritory.Salesforce_Code_gne__c = SALESFOCE_CODE;
        stgTerritory.Salesforce_SubTeam_Code_gne__c = SALESFOCE_SUBTEAM_CODE;
        scope.add(stgTerritory);

        insert scope;

        Set<String> scopeIds = new Set<String>();
        for(Staging_Territory_Def_gne__c s : scope) {
        	scopeIds.add(s.Id);
        }

        GNE_Subscribe_Batch_Territory subscribe = new GNE_Subscribe_Batch_Territory(false);

        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
    	System.runAs (thisUser) {
	        Test.StartTest();
	        //DataBase.executeBatch(subscribe);
	        new GNE_Subscribe_Territory(false);
	        Test.StopTest();
    	}
   		List<Staging_Territory_Def_gne__c> scopeAfterTest = [Select Id, Territory_Name_gne__c, Parent_Territory_External_ID_gne__c, Territory_ID_gne__c, Status_gne__c, Comment_gne__c from Staging_Territory_Def_gne__c where Id in :scopeIds];

        System.assertEquals(STG_TERRITORY_ERROR_STATE, scopeAfterTest[0].Status_gne__c);
        System.assert(scopeAfterTest[0].Comment_gne__c!=null && scopeAfterTest[0].Comment_gne__c.contains(GNE_Subscribe_Batch_Territory.COMMENT_RESULT_STATUS_ERROR));
        System.assertEquals(null, scopeAfterTest[0].Territory_ID_gne__c);
    }

    static testMethod void deactiveHierarchyOfTerritoriesWithOneInvalidExternalIdTest() {

    	// create territory structure
    	createTerritory('ParentTerritory1', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME);
    	createTerritory('TerritoryToDeactivte1', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1;TerritoryToDeactivte1', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1');
    	createTerritory('TerritoryToDeactivte2', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1;TerritoryToDeactivte1;001122334455;TerritoryToDeactivte2', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1;TerritoryToDeactivte1');
    	createTerritory('TerritoryToDeactivte3', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1;TerritoryToDeactivte1;001122334455;TerritoryToDeactivte2;001122334455;TerritoryToDeactivte3', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1;TerritoryToDeactivte1;001122334455;TerritoryToDeactivte2');

    	String inactiveTerrName = 'INACTIVE TERRITORIES_TEST';
    	// create incative territory
    	createTerritory(inactiveTerrName, GNE_Subscribe_Batch_Territory.INACTIVE_ROOT_TERRITORY_NAME + ';' + inactiveTerrName, GNE_Subscribe_Batch_Territory.INACTIVE_ROOT_TERRITORY_NAME);
    	List<Territory2> inactiveTerritory = [select id, Name, external_id_gne__c, parent_external_id_gne__c, ParentTerritory2Id from Territory2 where Name = :inactiveTerrName];

    	List<Staging_Territory_Def_gne__c> scope = new List<Staging_Territory_Def_gne__c>();

        Staging_Territory_Def_gne__c stgTerritory = new Staging_Territory_Def_gne__c();
        stgTerritory.Activation_Date_gne__c = date.today() - 10;
        stgTerritory.Territory_Nbr_gne__c = '001122334455';
        stgTerritory.Territory_Name_gne__c = 'InvalidTerritory1';
        stgTerritory.Territory_External_ID_gne__c = GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1;InvalidTerritory1';
        stgTerritory.Parent_Territory_External_ID_gne__c = GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1';
        stgTerritory.Status_gne__c = STG_TERRITORY_NEW_STATE;
        stgTerritory.End_Date_gne__c = date.today();
        stgTerritory.Territory_Description_gne__c = 'descripton1';
        stgTerritory.Territory_Source_gne__c = 'SOURCE1';
        stgTerritory.Salesforce_Code_gne__c = SALESFOCE_CODE;
        stgTerritory.Salesforce_SubTeam_Code_gne__c = SALESFOCE_SUBTEAM_CODE;
        scope.add(stgTerritory);

        Staging_Territory_Def_gne__c stgTerritory3 = new Staging_Territory_Def_gne__c();
        stgTerritory3.Activation_Date_gne__c = date.today() - 10;
        stgTerritory3.Territory_Nbr_gne__c = '001122334455';
        stgTerritory3.Territory_Name_gne__c = 'TerritoryToDeactivte3';
        stgTerritory3.Territory_External_ID_gne__c = GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1;TerritoryToDeactivte1;001122334455;TerritoryToDeactivte2;001122334455;TerritoryToDeactivte3';
        stgTerritory3.Parent_Territory_External_ID_gne__c = GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1;TerritoryToDeactivte1;001122334455;TerritoryToDeactivte2';
        stgTerritory3.Status_gne__c = STG_TERRITORY_NEW_STATE;
        stgTerritory3.End_Date_gne__c = date.today();
        stgTerritory3.Territory_Description_gne__c = 'descripton1';
        stgTerritory3.Territory_Source_gne__c = 'SOURCE1';
        stgTerritory3.Salesforce_Code_gne__c = SALESFOCE_CODE;
        stgTerritory3.Salesforce_SubTeam_Code_gne__c = SALESFOCE_SUBTEAM_CODE;
        scope.add(stgTerritory3);

        Staging_Territory_Def_gne__c stgTerritory2 = new Staging_Territory_Def_gne__c();
        stgTerritory2.Activation_Date_gne__c = date.today() - 10;
        stgTerritory2.Territory_Nbr_gne__c = '001122334455';
        stgTerritory2.Territory_Name_gne__c = 'TerritoryToDeactivte2';
        stgTerritory2.Territory_External_ID_gne__c = GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1;TerritoryToDeactivte1;001122334455;TerritoryToDeactivte2';
        stgTerritory2.Parent_Territory_External_ID_gne__c = GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1;TerritoryToDeactivte1';
        stgTerritory2.Status_gne__c = STG_TERRITORY_NEW_STATE;
        stgTerritory2.End_Date_gne__c = date.today();
        stgTerritory2.Territory_Description_gne__c = 'descripton1';
        stgTerritory2.Territory_Source_gne__c = 'SOURCE1';
        stgTerritory2.Salesforce_Code_gne__c = SALESFOCE_CODE;
        stgTerritory2.Salesforce_SubTeam_Code_gne__c = SALESFOCE_SUBTEAM_CODE;
        scope.add(stgTerritory2);

        insert scope;

        Set<String> scopeIds = new Set<String>();
        for(Staging_Territory_Def_gne__c s : scope) {
        	scopeIds.add(s.Id);
        }

		GNE_Subscribe_Batch_Territory subscribe = new GNE_Subscribe_Batch_Territory(false);

		User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs (thisUser) {
        	Test.StartTest();
	    	//DataBase.executeBatch(subscribe);
	    	new GNE_Subscribe_Territory(false);
	    	Test.StopTest();
	    }

        List<Staging_Territory_Def_gne__c> scopeAfterTest = [Select Id, Territory_Name_gne__c, Territory_Nbr_gne__c, Parent_Territory_External_ID_gne__c, Territory_ID_gne__c, Status_gne__c, End_Date_gne__c, Territory_Source_gne__c, Territory_Description_gne__c, Comment_gne__c from Staging_Territory_Def_gne__c where id in :scopeIds order by id asc];
		System.assertEquals(STG_TERRITORY_ERROR_STATE, scopeAfterTest[0].Status_gne__c);
		System.assert(scopeAfterTest[0].Comment_gne__c!=null && scopeAfterTest[0].Comment_gne__c.contains(GNE_Subscribe_Batch_Territory.COMMENT_RESULT_STATUS_ERROR));
		System.assertEquals(null, scopeAfterTest[0].Territory_ID_gne__c);

	    System.assertEquals(STG_TERRITORY_ERROR_STATE, scopeAfterTest[1].Status_gne__c);
	    System.assert(scopeAfterTest[1].Comment_gne__c!=null && scopeAfterTest[1].Comment_gne__c.contains(GNE_Subscribe_Batch_Territory.COMMENT_RESULT_STATUS_ERROR));
		System.assertEquals(null, scopeAfterTest[0].Territory_ID_gne__c);
system.debug(scopeAfterTest[2].Comment_gne__c);
		System.assertEquals(STG_TERRITORY_SUCCESS_STATE, scopeAfterTest[2].Status_gne__c);
		System.assert(scopeAfterTest[2].Comment_gne__c!=null && scopeAfterTest[2].Comment_gne__c.contains(GNE_Subscribe_Batch_Territory.COMMENT_RESULT_STATUS_DEACTIVATE));
		System.assertNotEquals(null, scopeAfterTest[2].Territory_ID_gne__c);
		System.assertNotEquals('', scopeAfterTest[2].Territory_ID_gne__c);

		String newExternalId = GNE_Subscribe_Batch_Territory.INACTIVE_ROOT_TERRITORY_NAME + ';' + stgTerritory2.Territory_External_ID_gne__c + '_OLD';

		Territory2 result = [Select Description, Name, external_id_gne__c, End_Date__c, parent_external_id_gne__c, source_gne__c, Territory_Number_gne__c, ParentTerritory2Id, AccountAccessLevel From Territory2 where id = :scopeAfterTest[2].Territory_ID_gne__c][0];
        System.assertEquals(newExternalId, result.external_id_gne__c);
        // check if territory was moved to inactive territories
		System.assertEquals(result.ParentTerritory2Id, inactiveTerritory[0].ParentTerritory2Id);
		System.assertEquals(result.parent_external_id_gne__c, inactiveTerritory[0].parent_external_id_gne__c);

		String childExternalId = GNE_Subscribe_Batch_Territory.INACTIVE_ROOT_TERRITORY_NAME + ';' + stgTerritory3.Territory_External_ID_gne__c + '_OLD';

		// check if child territory was also moved to inactive territories
		Territory2 result2 = [Select Description, Name, external_id_gne__c, End_Date__c, parent_external_id_gne__c, source_gne__c, Territory_Number_gne__c, ParentTerritory2Id, AccountAccessLevel From Territory2 where external_ID_gne__c = :childExternalId][0];
        System.assertEquals(result2.ParentTerritory2Id, result.Id);
		System.assertEquals(result2.parent_external_id_gne__c, result.external_id_gne__c);
    }

    static testMethod void deactiveHierarchyOfTerritoriesWithTwoInvalidExternalIdTest() {

    	// create territory structure
    	createTerritory('ParentTerritory1', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME);
    	createTerritory('TerritoryToDeactivte1', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1;TerritoryToDeactivte1', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1');
    	createTerritory('TerritoryToDeactivte2', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1;TerritoryToDeactivte1;TerritoryToDeactivte2', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1;TerritoryToDeactivte1');
    	createTerritory('TerritoryToDeactivte3', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1;TerritoryToDeactivte1;TerritoryToDeactivte2;TerritoryToDeactivte3',  GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1;TerritoryToDeactivte1;TerritoryToDeactivte2');

    	String inactiveTerrName = 'INACTIVE TERRITORIES_TEST';
    	// create incative territory
    	createTerritory(inactiveTerrName, GNE_Subscribe_Batch_Territory.INACTIVE_ROOT_TERRITORY_NAME + ';' + inactiveTerrName, GNE_Subscribe_Batch_Territory.INACTIVE_ROOT_TERRITORY_NAME);
    	List<Territory2> inactiveTerritory = [select id, Name, external_id_gne__c, ParentTerritory2Id, parent_external_id_gne__c from Territory2 where Name = :inactiveTerrName];

    	List<Staging_Territory_Def_gne__c> scope = new List<Staging_Territory_Def_gne__c>();

        Staging_Territory_Def_gne__c stgTerritory = new Staging_Territory_Def_gne__c();
        stgTerritory.Activation_Date_gne__c = date.today() - 10;
        stgTerritory.Territory_Nbr_gne__c = '001122334455';
        stgTerritory.Territory_Name_gne__c = 'InvalidTerritory1';
        stgTerritory.Territory_External_ID_gne__c = 'ParentTerritory1;InvalidTerritory1';
        stgTerritory.Parent_Territory_External_ID_gne__c = 'ParentTerritory1';
        stgTerritory.Status_gne__c = STG_TERRITORY_NEW_STATE;
        stgTerritory.End_Date_gne__c = date.today();
        stgTerritory.Territory_Description_gne__c = 'descripton1';
        stgTerritory.Territory_Source_gne__c = 'SOURCE1';
        stgTerritory.Salesforce_Code_gne__c = SALESFOCE_CODE;
        stgTerritory.Salesforce_SubTeam_Code_gne__c = SALESFOCE_SUBTEAM_CODE;
        scope.add(stgTerritory);

        Staging_Territory_Def_gne__c stgTerritory2 = new Staging_Territory_Def_gne__c();
        stgTerritory2.Activation_Date_gne__c = date.today() - 10;
        stgTerritory2.Territory_Nbr_gne__c = '001122334455';
        stgTerritory2.Territory_Name_gne__c = 'InvalidTerritory2';
        stgTerritory2.Territory_External_ID_gne__c = 'InvalidTerritory1;InvalidTerritory2';
        stgTerritory2.Parent_Territory_External_ID_gne__c = 'InvalidTerritory1';
        stgTerritory2.Status_gne__c = STG_TERRITORY_NEW_STATE;
        stgTerritory2.End_Date_gne__c = date.today();
        stgTerritory2.Territory_Description_gne__c = 'descripton1';
        stgTerritory2.Territory_Source_gne__c = 'SOURCE1';
        stgTerritory2.Salesforce_Code_gne__c = SALESFOCE_CODE;
        stgTerritory2.Salesforce_SubTeam_Code_gne__c = SALESFOCE_SUBTEAM_CODE;
        scope.add(stgTerritory2);

        Staging_Territory_Def_gne__c stgTerritory3 = new Staging_Territory_Def_gne__c();
        stgTerritory3.Activation_Date_gne__c = date.today() - 10;
        stgTerritory3.Territory_Nbr_gne__c = '001122334455';
        stgTerritory3.Territory_Name_gne__c = 'TerritoryToDeactivte3';
        stgTerritory3.Territory_External_ID_gne__c = GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1;TerritoryToDeactivte1;TerritoryToDeactivte2;TerritoryToDeactivte3';
        stgTerritory3.Parent_Territory_External_ID_gne__c = GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1;TerritoryToDeactivte1;TerritoryToDeactivte2';
        stgTerritory3.Status_gne__c = STG_TERRITORY_NEW_STATE;
        stgTerritory3.End_Date_gne__c = date.today();
        stgTerritory3.Territory_Description_gne__c = 'descripton1';
        stgTerritory3.Territory_Source_gne__c = 'SOURCE1';
        stgTerritory3.Salesforce_Code_gne__c = SALESFOCE_CODE;
        stgTerritory3.Salesforce_SubTeam_Code_gne__c = SALESFOCE_SUBTEAM_CODE;
        scope.add(stgTerritory3);

        insert scope;

        Set<String> scopeIds = new Set<String>();
        for(Staging_Territory_Def_gne__c s : scope) {
        	scopeIds.add(s.Id);
        }

		GNE_Subscribe_Batch_Territory subscribe = new GNE_Subscribe_Batch_Territory(false);

		User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs (thisUser) {
        	Test.StartTest();
	    	//DataBase.executeBatch(subscribe);
	    	new GNE_Subscribe_Territory(false);
	    	Test.StopTest();
	    }

        List<Staging_Territory_Def_gne__c> scopeAfterTest = [Select Id, Territory_Name_gne__c, Territory_Nbr_gne__c, Parent_Territory_External_ID_gne__c, Territory_ID_gne__c, Status_gne__c, End_Date_gne__c, Territory_Source_gne__c, Territory_Description_gne__c, Comment_gne__c from Staging_Territory_Def_gne__c where Id in :scopeIds];

		System.assertEquals(STG_TERRITORY_ERROR_STATE, scopeAfterTest[0].Status_gne__c);
		System.assert(scopeAfterTest[0].Comment_gne__c!=null && scopeAfterTest[0].Comment_gne__c.contains(GNE_Subscribe_Batch_Territory.COMMENT_RESULT_STATUS_ERROR));
		System.assertEquals(null, scopeAfterTest[0].Territory_ID_gne__c);

	    System.assertEquals(STG_TERRITORY_ERROR_STATE, scopeAfterTest[1].Status_gne__c);
	    System.assert(scopeAfterTest[1].Comment_gne__c!=null && scopeAfterTest[1].Comment_gne__c.contains(GNE_Subscribe_Batch_Territory.COMMENT_RESULT_STATUS_ERROR));
		System.assertEquals(null, scopeAfterTest[1].Territory_ID_gne__c);

system.debug(scopeAfterTest[2].Comment_gne__c);
		System.assertEquals(STG_TERRITORY_SUCCESS_STATE, scopeAfterTest[2].Status_gne__c);
		System.assert(scopeAfterTest[2].Comment_gne__c!=null && scopeAfterTest[2].Comment_gne__c.contains(GNE_Subscribe_Batch_Territory.COMMENT_RESULT_STATUS_DEACTIVATE));
		System.assertNotEquals(null, scopeAfterTest[2].Territory_ID_gne__c);
		System.assertNotEquals('', scopeAfterTest[2].Territory_ID_gne__c);

        Territory2 result = [Select Description, Name, external_id_gne__c, End_Date__c, parent_external_id_gne__c, source_gne__c, Territory_Number_gne__c, ParentTerritory2Id, AccountAccessLevel From Territory2 where id = :scopeAfterTest[2].Territory_ID_gne__c][0];
        System.assertEquals(GNE_Subscribe_Batch_Territory.INACTIVE_ROOT_TERRITORY_NAME + ';' + stgTerritory3.Territory_External_ID_gne__c + '_OLD', result.external_id_gne__c);
        // check if territory was moved to inactive territories
		System.assertEquals(result.ParentTerritory2Id, inactiveTerritory[0].ParentTerritory2Id);
		System.assertEquals(result.parent_external_id_gne__c, inactiveTerritory[0].parent_external_id_gne__c);
    }

    static testMethod void deactiveHierarchyOfTerritoriesWithPassingChildTerritoriesTest() {

    	// create territory structure
    	createTerritory('ParentTerritory1', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME);
    	createTerritory('TerritoryToDeactivte1', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1;TerritoryToDeactivte1', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1');
    	createTerritory('TerritoryToDeactivte2', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1;TerritoryToDeactivte1;TerritoryToDeactivte2', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1;TerritoryToDeactivte1');
    	createTerritory('TerritoryToDeactivte3', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1;TerritoryToDeactivte1;TerritoryToDeactivte2;TerritoryToDeactivte3', GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1;TerritoryToDeactivte1;TerritoryToDeactivte2');

    	String inactiveTerrName = 'INACTIVE TERRITORIES_TEST';
    	// create incative territory
    	createTerritory(inactiveTerrName, GNE_Subscribe_Batch_Territory.INACTIVE_ROOT_TERRITORY_NAME + ';' + inactiveTerrName, GNE_Subscribe_Batch_Territory.INACTIVE_ROOT_TERRITORY_NAME);
    	List<Territory2> inactiveTerritory = [select id, Name, external_id_gne__c, ParentTerritory2Id, parent_external_id_gne__c from Territory2 where Name = :inactiveTerrName];

    	List<Staging_Territory_Def_gne__c> scope = new List<Staging_Territory_Def_gne__c>();

        Staging_Territory_Def_gne__c stgTerritory = new Staging_Territory_Def_gne__c();
        stgTerritory.Activation_Date_gne__c = date.today() - 10;
        stgTerritory.Territory_Nbr_gne__c = 'TerritoryToDeactivte1';
        stgTerritory.Territory_Name_gne__c = 'TerritoryToDeactivte1';
        stgTerritory.Parent_Territory_External_ID_gne__c = GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1';
        stgTerritory.Status_gne__c = STG_TERRITORY_NEW_STATE;
        stgTerritory.End_Date_gne__c = date.today();
        stgTerritory.Territory_Description_gne__c = 'descripton1';
        stgTerritory.Territory_Source_gne__c = 'SOURCE1';
        stgTerritory.Salesforce_Code_gne__c = SALESFOCE_CODE;
        stgTerritory.Salesforce_SubTeam_Code_gne__c = SALESFOCE_SUBTEAM_CODE;
        scope.add(stgTerritory);

        Staging_Territory_Def_gne__c stgTerritory2 = new Staging_Territory_Def_gne__c();
        stgTerritory2.Activation_Date_gne__c = date.today() - 10;
        stgTerritory2.Territory_Nbr_gne__c = 'TerritoryToDeactivte2';
        stgTerritory2.Territory_Name_gne__c = 'TerritoryToDeactivte2';
        stgTerritory2.Parent_Territory_External_ID_gne__c = GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1;TerritoryToDeactivte1';
        stgTerritory2.Status_gne__c = STG_TERRITORY_NEW_STATE;
        stgTerritory2.End_Date_gne__c = date.today();
        stgTerritory2.Territory_Description_gne__c = 'descripton1';
        stgTerritory2.Territory_Source_gne__c = 'SOURCE1';
        stgTerritory2.Salesforce_Code_gne__c = SALESFOCE_CODE;
        stgTerritory2.Salesforce_SubTeam_Code_gne__c = SALESFOCE_SUBTEAM_CODE;
        scope.add(stgTerritory2);

        Staging_Territory_Def_gne__c stgTerritory3 = new Staging_Territory_Def_gne__c();
        stgTerritory3.Activation_Date_gne__c = date.today() - 10;
        stgTerritory3.Territory_Nbr_gne__c = 'TerritoryToDeactivte3';
        stgTerritory3.Territory_Name_gne__c = 'TerritoryToDeactivte3';
        stgTerritory3.Parent_Territory_External_ID_gne__c = GNE_Subscribe_Batch_Territory.US_ROOT_TERRITORY_NAME + ';ParentTerritory1;TerritoryToDeactivte1;TerritoryToDeactivte2';
        stgTerritory3.Status_gne__c = STG_TERRITORY_NEW_STATE;
        stgTerritory3.End_Date_gne__c = date.today();
        stgTerritory3.Territory_Description_gne__c = 'descripton1';
        stgTerritory3.Territory_Source_gne__c = 'SOURCE1';
        stgTerritory3.Salesforce_Code_gne__c = SALESFOCE_CODE;
        stgTerritory3.Salesforce_SubTeam_Code_gne__c = SALESFOCE_SUBTEAM_CODE;
        scope.add(stgTerritory3);

        insert scope;

        Set<String> scopeIds = new Set<String>();
        for(Staging_Territory_Def_gne__c s : scope) {
        	scopeIds.add(s.Id);
        }

		GNE_Subscribe_Batch_Territory subscribe = new GNE_Subscribe_Batch_Territory(false);

		User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs (thisUser) {
        	Test.StartTest();
	    	//DataBase.executeBatch(subscribe);
	    	new GNE_Subscribe_Territory(false);
	    	Test.StopTest();
	    }

        List<Staging_Territory_Def_gne__c> scopeAfterTest = [Select Id, Territory_Name_gne__c, Territory_Nbr_gne__c, Parent_Territory_External_ID_gne__c, Territory_ID_gne__c, Status_gne__c, End_Date_gne__c, Territory_Source_gne__c, Territory_Description_gne__c, Comment_gne__c from Staging_Territory_Def_gne__c where Id in :scopeIds order by id asc];

	    System.debug('BOS::[TEST] 1 Comment_gne__c = ' + scopeAfterTest[0].Comment_gne__c);
		System.assertEquals(STG_TERRITORY_SUCCESS_STATE, scopeAfterTest[0].Status_gne__c);
		System.assert(scopeAfterTest[0].Comment_gne__c!=null && scopeAfterTest[0].Comment_gne__c.contains(GNE_Subscribe_Batch_Territory.COMMENT_RESULT_STATUS_DEACTIVATE));
		System.assertNotEquals(null, scopeAfterTest[0].Territory_ID_gne__c);
		System.assertNotEquals('', scopeAfterTest[0].Territory_ID_gne__c);

	    System.debug('BOS::[TEST] 2 Comment_gne__c = ' + scopeAfterTest[1].Comment_gne__c);
	    System.assertEquals(STG_TERRITORY_ERROR_STATE, scopeAfterTest[1].Status_gne__c);
	    System.assert(scopeAfterTest[1].Comment_gne__c!=null && scopeAfterTest[1].Comment_gne__c.contains(GNE_Subscribe_Batch_Territory.COMMENT_RESULT_STATUS_ERROR));
	    //FIXME: lk
//		System.assertEquals(null, scopeAfterTest[1].Territory_ID_gne__c);

		System.debug('BOS::[TEST] 3 Comment_gne__c = ' + scopeAfterTest[2].Comment_gne__c);
		System.assertEquals(STG_TERRITORY_ERROR_STATE, scopeAfterTest[2].Status_gne__c);
		System.assert(scopeAfterTest[2].Comment_gne__c!=null && scopeAfterTest[2].Comment_gne__c.contains(GNE_Subscribe_Batch_Territory.COMMENT_RESULT_STATUS_ERROR));
		//FIXME: lk
		//System.assertEquals(null, scopeAfterTest[2].Territory_ID_gne__c);

		String newExternalId = GNE_Subscribe_Batch_Territory.INACTIVE_ROOT_TERRITORY_NAME + ';' + stgTerritory2.Parent_Territory_External_ID_gne__c + '_OLD';

        Territory2 result = [Select id, Description, Name, external_id_gne__c, End_Date__c, parent_external_id_gne__c, source_gne__c, Territory_Number_gne__c, ParentTerritory2Id, AccountAccessLevel From Territory2 where id = :scopeAfterTest[0].Territory_ID_gne__c][0];
        System.assertEquals(newExternalId, result.external_id_gne__c);
        // check if territory was moved to inactive territories
		System.assertEquals(result.ParentTerritory2Id, inactiveTerritory[0].ParentTerritory2Id);
		System.assertEquals(result.parent_external_id_gne__c, inactiveTerritory[0].parent_external_id_gne__c);

		String childExternalId = GNE_Subscribe_Batch_Territory.INACTIVE_ROOT_TERRITORY_NAME + ';' + stgTerritory3.Parent_Territory_External_ID_gne__c + '_OLD';

		Territory2 result2 = [Select id, Description, Name, external_id_gne__c, End_Date__c, parent_external_id_gne__c, source_gne__c, Territory_Number_gne__c, ParentTerritory2Id, AccountAccessLevel From Territory2
							 where external_id_gne__c = :childExternalId][0];
        // check if child territory is still below parent territory
		System.assertEquals(result2.ParentTerritory2Id, result.Id);
		System.assertEquals(result2.parent_external_id_gne__c, result.external_id_gne__c);

    }


    static private void assertTerritory(Staging_Territory_Def_gne__c stgTerritory, Territory2 result) {
    	//07-12-2013 Dominik Wasilewski added asserts for Salesforce_Code_gne__c and Salesforce_SubTeam_Code_gne__c

    	System.assertEquals(stgTerritory.Territory_Nbr_gne__c, result.Territory_Number_gne__c);
        System.assertEquals(stgTerritory.Territory_Nbr_gne__c + '-' + stgTerritory.Territory_Name_gne__c, result.Name);
        System.assertEquals(stgTerritory.Parent_Territory_External_ID_gne__c, result.parent_external_id_gne__c);

        System.assertEquals(stgTerritory.End_Date_gne__c, result.End_Date__c);
        System.assertEquals(stgTerritory.Territory_Description_gne__c, result.Description);
        System.assertEquals(stgTerritory.Territory_Source_gne__c, result.source_gne__c);
        System.assertEquals(GNE_Subscribe_Batch_Territory.ACCOUNT_ACCESS_LEVEL, result.AccountAccessLevel);
        System.assertEquals(stgTerritory.Salesforce_Code_gne__c, result.Salesforce_Code_gne__c);
        System.assertEquals(stgTerritory.Salesforce_SubTeam_Code_gne__c, result.Salesforce_SubTeam_Code_gne__c);

        System.assertEquals((stgTerritory.Parent_Territory_External_ID_gne__c + ';' + stgTerritory.Territory_Nbr_gne__c + '-' + stgTerritory.Territory_Name_gne__c).toUpperCase(), result.external_id_gne__c.toUpperCase());
    }


    static private Territory2 createTerritory(String territoryName, String externalId, String parentExternalId) {
    	return createTerritory(territoryName, externalId, parentExternalId, null, null, null);
    }

    static private Territory2 createTerritory(String territoryName, String externalId, String parentExternalId,
    										 String description, Date endDate, String source ) {
    	Id terrModelId = [SELECT Id FROM Territory2Model LIMIT 1].Id;
    	Id terrTypeId = [SELECT Id FROM Territory2Type LIMIT 1].Id;
    	return createTerritory(territoryName, externalId, parentExternalId, null, null, null, terrModelId, terrTypeId);
    										 	
    }
    
    static private Territory2 createTerritory(String territoryName, String externalId, String parentExternalId,
    										 String description, Date endDate, String source, Id terrModelId, Id terrTypeId) {    										 	

    	User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
    	Territory2 territory;
    	
    	Id parentId = null;
    	List<Territory2> parents = [SELECT Id FROM Territory2 WHERE External_Id_gne__c =: parentExternalId LIMIT 1]; 
        if (!parents.isEmpty()) {
        	parentId = parents[0].Id;
        }

    	System.runAs (thisUser) {
	    	territory = new Territory2();
	    	territory.Name = territoryName;
	    	territory.DeveloperName = 'DM_' + territoryName.replaceAll('[|\\,| |\\.|\\,|\\"|\\:|\\~|\\!|\\@|\\#|\\$|\\%|\\^|\\&|\\*|\\-|\\_|\\+|\\=|\\<|\\>|\\?|\\(|\\)|\\{|\\}|\\;|\\\'"]', '');
	    	territory.Territory2ModelId = terrModelId;
	    	territory.Territory2TypeId = terrTypeId;
	    	territory.AccountAccessLevel = GNE_Subscribe_Batch_Territory.ACCOUNT_ACCESS_LEVEL;
	    	territory.external_id_gne__c = externalId;
	    	territory.parent_external_id_gne__c = parentExternalId;
	    	territory.Description = description;
	    	territory.End_Date__c = endDate;
	    	territory.Source_gne__c = source;
	    	territory.Salesforce_Code_gne__c = SALESFOCE_CODE;
        	territory.Salesforce_SubTeam_Code_gne__c = SALESFOCE_SUBTEAM_CODE;
            territory.ParentTerritory2Id = parentId;

	    	insert territory;
    	}

    	return territory;
    }

}