@isTest(SeeAllData=false)
private class CFAR_Administrator_Controller_Test {

	@isTest static void testWBS()
	{
		List<sObject> testRecords = new List<sObject>();
		Map<sObject, Map<String, object>> objectConfig = new Map<sObject, Map<String, object>>();
		Map<String,object> fieldsConfig = new Map<String, object>();
		for(Integer wi=0; wi<=15; wi++)
		{	
			fieldsConfig.put('Name', 'WBS Name' + String.valueOf(wi));
			fieldsConfig.put('Active_gne__c', true);
			fieldsConfig.put('GSR_WBS_gne__c', 'WBS'+String.valueOf(wi));
			objectConfig.put(new CFAR_WBS_gne__c(), fieldsConfig);
			sObject cfarWBS = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarWBS);
		}
		insert testRecords;
		//test 21042016 END
		User adminUser = null;
		// start new context via system.runAs() for the same user
		System.runAs(new User(Id = Userinfo.getUserId())) {
			adminUser = CFAR_TestUtils.createTestAdminUser();
		}
		Test.startTest();
			system.runAs(adminUser)
			{
				CFAR_Administrator_Controller adminController = new CFAR_Administrator_Controller();
				system.assertEquals(adminController.getRenderAdminSection(), true);
				system.assertEquals(adminController.addWBS, false);
				system.assertNotEquals(adminController.objectMapWBS.size(), 0);
				//sort WBS
				adminController.sortExpression = 'Name';
				adminController.sortDirection = 'asc';
				adminController.sortWBS();
				system.debug('adminController.objectListWBS[0]= '+adminController.objectListWBS[0].innerObject.get('Name'));
				system.assertEquals(adminController.objectListWBS[0].innerObject.get('Name'), 'WBS Name0');
				adminController.nextWBS();
				adminController.previousWBS();
				adminController.lastWBS();
				system.assertEquals(adminController.hasPreviousWBS, true);
				adminController.firstWBS();
				system.assertEquals(adminController.hasNextWBS, true);
				//add New WBS
				adminController.addNewWBS();
				system.assertEquals(adminController.addWBS, true);
				system.assertEquals(adminController.s_object.getSObjectType(), Schema.getGlobalDescribe().get('CFAR_WBS_gne__c'));
				adminController.s_object.put('Name', 'Test_WBS');
				adminController.s_object.put('GSR_WBS_gne__c', 'GSR_WBS');
				adminController.s_object.put('Active_gne__c', true);
				//create WBS
				adminController.createWBS();
				system.assertEquals(adminController.addWBS, false);
				List<CFAR_WBS_gne__c> newWBS = [Select Id from CFAR_WBS_gne__c where Name ='Test_WBS'];
				system.assertEquals(newWBS.size(), 1);
				//edit WBS
				adminController.objectId = [Select Id from CFAR_WBS_gne__c where Name='WBS Name0'].Id;
				adminController.editWBS();
				system.assertEquals(adminController.objectMapWBS.get(adminController.objectId).selected, true);
				system.assertEquals(adminController.s_object.get('Name'), 'WBS Name0');
				system.assertEquals(adminController.s_object.get('GSR_WBS_gne__c'), 'WBS0');
				system.assertEquals(adminController.s_object.get('Active_gne__c'), true);
				system.assertEquals(adminController.s_object.get('Id'), adminController.objectId);
				//save WBS
				adminController.s_object.put('Name','Edit WBS');
				adminController.saveWBS();
				system.assertEquals(adminController.objectMapWBS.get(adminController.objectId).selected, false);
				List<CFAR_WBS_gne__c> wbsSaved = [Select Id from CFAR_WBS_gne__c where Name = 'Edit WBS'];
				List<CFAR_WBS_gne__c> wbsOld = [Select Id from CFAR_WBS_gne__c where Name = 'WBS Name0'];
				system.assertEquals(wbsSaved.size(), 1);
				system.assertEquals(wbsOld.size(), 0);
				//cancel edit WBS
				adminController.editWBS();
				system.assertEquals(adminController.objectMapWBS.get(adminController.objectId).selected, true);
				adminController.cancelEditWBS();
				system.assertEquals(adminController.objectMapWBS.get(adminController.objectId).selected, false);
				//cancel create WBS
				adminController.addNewWBS();
				system.assertEquals(adminController.addWBS, true);
				adminController.controllerWBSBDay = adminController.controllerWBSBDay.addMinutes(-15);
				adminController.nextWBS();
				//delete WBS
				/*
				adminController.deleteWBS();
				List<CFAR_WBS_gne__c> delWBS = [Select Id from CFAR_WBS_gne__c where Name ='Edit WBS'];
				system.assertEquals(delWBS.size(), 0);*/
			}
		Test.stopTest();
	}

	@isTest static void testRDT()
	{
		List<sObject> testRecords = new List<sObject>();
		Map<sObject, Map<String, object>> objectConfig = new Map<sObject, Map<String, object>>();
		Map<String,object> fieldsConfig = new Map<String, object>();
		/*
		Set<String> initialTrackingActivitiesSet = new Set<String>{'Study Introduction Packet Sent', 'Protocol Approval Letter Sent', 
        'CV (Curriculum Vitae)', 'ML (Medical License)', 'IB Signature Page', 'clinicaltrials.gov', 'CTV Confirmation Email', 
        'CTV Safety Letter signed', 'Study Activation Letter', 'Final Enrollment Log', 'Final Drug Accountability Log', 
        'Final CTV Confirmation', 'Study Closure Letter Sent' ,'Study Closure Letter PI signed & returned'};
        Set<String> IRBActivitiesSet = new Set<String>{'IRB Approval Letter for Original Protocol', 'IRB Approved Protocol', 'IRB Closure Letter Received'};
        Set<String> INDActivitiesSet = new Set<String>{'Cross Reference Letter', '1571', '1572', 'FDA response to IND Submission (copy)', 'FDA Notification of Closure'};
        Set<String> FSRActivitiesSet = new Set<String>{'Final Study Report Received'};
        Set<String> CapAssessActivitiesSet = new Set<String>{'Capability Assessment Form Completed'};
		*/
		
		fieldsConfig.put('Name', 'CV (Curriculum Vitae)');
		fieldsConfig.put('Active_gne__c', true);
		fieldsConfig.put('Study_Stage__c', 'Activation');
		objectConfig.put(new CFAR_Tracking_Activity_gne__c(), fieldsConfig);
		sObject act1 = CFAR_TestUtils.createRecord(objectConfig);
		testRecords.add(act1);

		fieldsConfig.put('Name', 'ML (Medical License)');
		fieldsConfig.put('Active_gne__c', true);
		fieldsConfig.put('Study_Stage__c', 'Activation');
		objectConfig.put(new CFAR_Tracking_Activity_gne__c(), fieldsConfig);
		sObject act2 = CFAR_TestUtils.createRecord(objectConfig);
		testRecords.add(act2);

		fieldsConfig.put('Name', 'Study Closure Letter Sent');
		fieldsConfig.put('Active_gne__c', true);
		fieldsConfig.put('Study_Stage__c', 'Closure');
		objectConfig.put(new CFAR_Tracking_Activity_gne__c(), fieldsConfig);
		sObject act3 = CFAR_TestUtils.createRecord(objectConfig);
		testRecords.add(act3);

		fieldsConfig.put('Name', 'Final Enrollment Log');
		fieldsConfig.put('Active_gne__c', true);
		fieldsConfig.put('Study_Stage__c', 'Closure');
		objectConfig.put(new CFAR_Tracking_Activity_gne__c(), fieldsConfig);
		sObject act4 = CFAR_TestUtils.createRecord(objectConfig);
		testRecords.add(act4);

		fieldsConfig.put('Name', 'Maintenance 1');
		fieldsConfig.put('Active_gne__c', true);
		fieldsConfig.put('Study_Stage__c', 'Maintenance');
		objectConfig.put(new CFAR_Tracking_Activity_gne__c(), fieldsConfig);
		sObject act5 = CFAR_TestUtils.createRecord(objectConfig);
		testRecords.add(act5);

		fieldsConfig.put('Name', 'Maintenance 2');
		fieldsConfig.put('Active_gne__c', true);
		fieldsConfig.put('Study_Stage__c', 'Maintenance');
		objectConfig.put(new CFAR_Tracking_Activity_gne__c(), fieldsConfig);
		sObject act6 = CFAR_TestUtils.createRecord(objectConfig);
		testRecords.add(act6);

		insert testRecords;
		//test 21042016 END
		User adminUser = null;
		// start new context via system.runAs() for the same user
		System.runAs(new User(Id = Userinfo.getUserId())) {
			adminUser = CFAR_TestUtils.createTestAdminUser();
		}
		Test.startTest();
			system.runAs(adminUser)
			{
				CFAR_Administrator_Controller adminController = new CFAR_Administrator_Controller();
				system.assertEquals(adminController.getRenderAdminSection(), true);
				system.assertEquals(adminController.addRdt, false);
				system.assertNotEquals(adminController.objectMapRdt.size(), 0);
				//sort RDT
				adminController.sortExpression = 'Name';
				adminController.sortDirection = 'asc';
				adminController.sortRdt();						
				adminController.nextRdt();
				adminController.previousRdt();
				adminController.lastRdt();
				adminController.firstRdt();		
				//add New RDT
				adminController.addNewRdt();
				system.assertEquals(adminController.addRdt, true);
				system.assertEquals(adminController.s_object.getSObjectType(), Schema.getGlobalDescribe().get('CFAR_Tracking_Activity_gne__c'));
				adminController.s_object.put('Name', 'Test_Rdt');
				adminController.s_object.put('Study_Stage__c', 'Closure');
				adminController.s_object.put('Active_gne__c', true);
				//create Rdt
				adminController.createRdt();
				system.assertEquals(adminController.addRdt, false);
				List<CFAR_Tracking_Activity_gne__c> newRdt = [Select Id from CFAR_Tracking_Activity_gne__c where Name ='Test_Rdt'];
				system.assertEquals(newRdt.size(), 1);
				//edit Rdt
				adminController.objectId = [Select Id from CFAR_Tracking_Activity_gne__c where Name='Final Enrollment Log'].Id;
				adminController.editRdt();
				system.assertEquals(adminController.objectMapRdt.get(adminController.objectId).selected, true);
				system.assertEquals(adminController.s_object.get('Name'), 'Final Enrollment Log');
				system.assertEquals(adminController.s_object.get('Study_Stage__c'), 'Closure');
				system.assertEquals(adminController.s_object.get('Active_gne__c'), true);
				system.assertEquals(adminController.s_object.get('Id'), adminController.objectId);
				//save Rdt
				adminController.s_object.put('Name','Edit Rdt');
				adminController.saveRdt();
				system.assertEquals(adminController.objectMapRdt.get(adminController.objectId).selected, false);
				List<CFAR_Tracking_Activity_gne__c> rdtSaved = [Select Id from CFAR_Tracking_Activity_gne__c where Name = 'Edit Rdt'];
				List<CFAR_Tracking_Activity_gne__c> rdtOld = [Select Id from CFAR_Tracking_Activity_gne__c where Name = 'Final Enrollment Log'];
				system.assertEquals(rdtSaved.size(), 1);
				system.assertEquals(rdtOld.size(), 0);
				//cancel edit Rdt
				adminController.editRdt();
				system.assertEquals(adminController.objectMapRdt.get(adminController.objectId).selected, true);
				adminController.cancelEditRdt();
				system.assertEquals(adminController.objectMapRdt.get(adminController.objectId).selected, false);
				//cancel create Rdt
				adminController.addNewRdt();
				system.assertEquals(adminController.addRdt, true);
				adminController.controllerRdtBDay = adminController.controllerRdtBDay.addMinutes(-15);
				adminController.nextRdt();
				
			}
		Test.stopTest();
	}

	@isTest static void testPartnership()
	{
		List<sObject> testRecords = new List<sObject>();
		Map<sObject, Map<String, object>> objectConfig = new Map<sObject, Map<String, object>>();
		Map<String,object> fieldsConfig = new Map<String, object>();
		for(Integer wi=0; wi<=15; wi++) {
			fieldsConfig.put('Name', 'Partnership Name' + String.valueOf(wi));
			fieldsConfig.put('Active_gne__c', true);
			objectConfig.put(new CFAR_Partnership_gne__c(), fieldsConfig);
			sObject cfarPartnership = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarPartnership);
		}
		insert testRecords;

		User adminUser = null;
		System.runAs(new User(Id = Userinfo.getUserId())) {
			adminUser = CFAR_TestUtils.createTestAdminUser();
		}
		Test.startTest();
			system.runAs(adminUser)
			{
				CFAR_Administrator_Controller adminController = new CFAR_Administrator_Controller();
				//sort Partnership
				adminController.sortExpression = 'Name';
				adminController.sortDirection = 'asc';
				adminController.sortPartnership();
				system.debug('adminController.objectListPartnership[0]= '+adminController.objectListPartnership[0].innerObject.get('Name'));
				system.assertEquals(adminController.objectListPartnership[0].innerObject.get('Name'), 'Partnership Name0');
				adminController.nextPartnership();
				adminController.previousPartnership();
				adminController.lastPartnership();
				system.assertEquals(adminController.hasPreviousPartnership, true);
				adminController.firstPartnership();
				system.assertEquals(adminController.hasNextPartnership, true);
				//add New Partnership
				adminController.addNewPartnership();
				system.assertEquals(adminController.addPartnership, true);
				system.assertEquals(adminController.s_object.getSObjectType(), Schema.getGlobalDescribe().get('CFAR_Partnership_gne__c'));
				adminController.s_object.put('Name', 'Test_Partnership');
				adminController.s_object.put('Active_gne__c', true);
				//create Partnership
				adminController.createPartnershipAF();
				system.assertEquals(adminController.addPartnership, false);
				List<CFAR_Partnership_gne__c> newPartnership = [Select Id from CFAR_Partnership_gne__c where Name ='Test_Partnership'];
				system.assertEquals(newPartnership.size(), 1);
				//edit Partnership
				adminController.objectId = [Select Id from CFAR_Partnership_gne__c where Name='Partnership Name0'].Id;
				adminController.editPartnership();
				system.assertEquals(adminController.objectMapPartnership.get(adminController.objectId).selected, true);
				system.assertEquals(adminController.s_object.get('Name'), 'Partnership Name0');
				system.assertEquals(adminController.s_object.get('Active_gne__c'), true);
				system.assertEquals(adminController.s_object.get('Id'), adminController.objectId);
				//save Partnership
				adminController.s_object.put('Name','Edit Partnership');
				adminController.savePartnership();
				system.assertEquals(adminController.objectMapPartnership.get(adminController.objectId).selected, false);
				List<CFAR_Partnership_gne__c> partnershipSaved = [Select Id from CFAR_Partnership_gne__c where Name = 'Edit Partnership'];
				List<CFAR_Partnership_gne__c> partnershipOld = [Select Id from CFAR_Partnership_gne__c where Name = 'Partnership Name0'];
				system.assertEquals(partnershipSaved.size(), 1);
				system.assertEquals(partnershipOld.size(), 0);
				//cancel edit Partnership
				adminController.editPartnership();
				system.assertEquals(adminController.objectMapPartnership.get(adminController.objectId).selected, true);
				adminController.cancelEditPartnership();
				system.assertEquals(adminController.objectMapPartnership.get(adminController.objectId).selected, false);
				//cancel create Partnership
				adminController.addNewPartnership();
				system.assertEquals(adminController.addPartnership, true);

				//validate partnership
				adminController.s_object.put('Name', '');
				adminController.validatePartnership();
				System.assertEquals(new ApexPages.message(ApexPages.severity.ERROR, 
					Label.CFAR_ADMINTAB_PARTNERSHIP_CANT_BE_BLANK), ApexPages.getMessages().get(0));

				adminController.s_object.put('Name', 'Name that exceed 25 characters');
				adminController.validatePartnership();
				System.assertEquals(new ApexPages.message(ApexPages.severity.ERROR, 
					String.format(Label.CFAR_GSTARS_MAX_CHAR_NUMBER_EXCEEDED, new List<String>{'25'})), ApexPages.getMessages().get(1));

				//delete Partnership
				CFAR_Trial_gne__c trial = CFAR_TestUtils.createTestTrial();
				trial.Partnership_Multi_gne__c = adminController.objectId;
				CFAR_ConfigUtil.setDisabled('Disabled_Triggers_gne__c', new List<String>{'CFAR_TrialTrigger'});
				update trial;
				adminController.deletePartnership();
				System.assertEquals(new ApexPages.message(ApexPages.severity.ERROR, 
					Label.CFAR_ADMINTAB_CANT_DELETE_PARTNERSHIP), ApexPages.getMessages().get(2),
					'Should throw exception if partnetship is used in trial Partnership_Multi_gne__c field');

				trial.Partnership_Multi_gne__c = null;
				update trial;
				adminController.deletePartnership();
				System.assertEquals(0, [SELECT COUNT() FROM CFAR_Partnership_gne__c WHERE Id =: adminController.objectId],
					'deletePartnership() should delete selected partnetship if its not used in trials Partnership_Multi_gne__c');
				adminController.controllerPartnershipBDay = adminController.controllerPartnershipBDay.addMinutes(-15);
				adminController.nextPartnership();
			}
		Test.stopTest();
	}

	@isTest static void testProductAndTheme()
	{
		List<sObject> testRecords = new List<sObject>();
		Map<sObject, Map<String, object>> objectConfig = new Map<sObject, Map<String, object>>();
		Map<String,object> fieldsConfig = new Map<String, object>();
		for(Integer th=0; th<=15; th++)
		{	
			fieldsConfig.put('Name', 'TH' + String.valueOf(th));
			fieldsConfig.put('Active_gne__c', true);
			objectConfig.put(new CFAR_Theme_gne__c(), fieldsConfig);
			sObject cfarTheme = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarTheme);
		}
		insert testRecords;
		testRecords = new List<sObject>();
		objectConfig = new Map<sObject, Map<String, object>>();
		fieldsConfig = new Map<String, object>();
		List<CFAR_Theme_gne__c> cfarThemes = [Select Id, Name from CFAR_Theme_gne__c];
		Integer prodCounter = 0;
		for(CFAR_Theme_gne__c theme : cfarThemes)
		{
			fieldsConfig.put('Name', 'Product' + String.valueOf(prodCounter));
			fieldsConfig.put('Description_gne__c', 'ABCD'+String.valueOf(prodCounter));
			fieldsConfig.put('Generic_Name_gne__c', 'GenName' + String.valueOf(prodCounter));
			fieldsConfig.put('Other_GNE_Agent_Active_gne__c', true);
			fieldsConfig.put('Active_gne__c', true);
			fieldsConfig.put('Theme_ref_gne__c', theme.Id);
			fieldsConfig.put('Abbreviation_gne__c', 'TST');
			objectConfig.put(new CFAR_Product_gne__c(), fieldsConfig);
			sObject cfarProduct = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarProduct);
			prodCounter++;
		}
		insert testRecords;
		User adminUser = null;
		// start new context via system.runAs() for the same user
		System.runAs(new User(Id = Userinfo.getUserId())) {
			adminUser = CFAR_TestUtils.createTestAdminUser();
		}
		Test.startTest();
			system.runAs(adminUser)
			{
				CFAR_Administrator_Controller adminController = new CFAR_Administrator_Controller();
				system.assertEquals(adminController.getRenderAdminSection(), true);
				system.assertEquals(adminController.addProduct, false);
				system.assertNotEquals(adminController.objectMapProduct.size(), 0);
				system.assertEquals(adminController.addTheme, false);
				system.assertNotEquals(adminController.objectMapTheme.size(), 0);
				//sort Product
				adminController.sortExpression = 'Name';
				adminController.sortDirection = 'asc';
				adminController.sortProduct();
				system.debug('adminController.objectListProduct[0]= '+adminController.objectListProduct[0].innerObject.get('Name'));
				system.assertEquals(adminController.objectListProduct[0].innerObject.get('Name'), 'Product0');
				adminController.nextProduct();
				adminController.previousProduct();
				adminController.lastProduct();
				system.assertEquals(adminController.hasPreviousProduct, true);
				adminController.firstProduct();
				system.assertEquals(adminController.hasNextProduct, true);
				//sort Theme
				adminController.sortExpression = 'Name';
				adminController.sortDirection = 'asc';
				adminController.sortTheme();
				system.debug('adminController.objectListTheme[0]= '+adminController.objectListTheme[0].innerObject.get('Name'));
				system.assertEquals(adminController.objectListTheme[0].innerObject.get('Name'), 'TH0');
				adminController.nextTheme();
				adminController.previousTheme();
				adminController.lastTheme();
				system.assertEquals(adminController.hasPreviousTheme, true);
				adminController.firstTheme();
				system.assertEquals(adminController.hasNextTheme, true);

				//getThemeSelectOptions

				//add new Product
				adminController.addNewProduct();
				system.assertEquals(adminController.addProduct, true);
				system.assertEquals(adminController.s_object.getSObjectType(), Schema.getGlobalDescribe().get('CFAR_Product_gne__c'));
				adminController.s_object.put('Name', 'Test Prod');
				adminController.s_object.put('Active_gne__c', true);
				adminController.s_object.put('Description_gne__c', 'TEST DESC');
				adminController.s_object.put('Generic_Name_gne__c', 'Test Gen Name');
				adminController.s_object.put('Other_GNE_Agent_Active_gne__c', true);
				adminController.s_object.put('Theme_ref_gne__c', cfarThemes[0].Id);
				adminController.s_object.put('Abbreviation_gne__c', 'TST');
				System.assertEquals(cfarThemes.size() + 1, adminController.themeSelectOptions.size());
				//create new Product
				adminController.createProduct();
				system.assertEquals(adminController.addProduct, false);
				List<CFAR_Product_gne__c> newProd = [Select Id from CFAR_Product_gne__c where Name ='Test Prod'];
				system.assertEquals(newProd.size(), 1);
				//edit Product
				adminController.objectId = [Select Id from CFAR_Product_gne__c where Name='Product2'].Id;
				adminController.editProduct();
				system.assertEquals(adminController.objectMapProduct.get(adminController.objectId).selected, true);
				system.assertEquals(adminController.s_object.get('Name'), 'Product2');
				system.assertEquals(adminController.s_object.get('Active_gne__c'), true);
				system.assertEquals(adminController.s_object.get('Generic_Name_gne__c'), 'GenName2');
				system.assertEquals(adminController.s_object.get('Other_GNE_Agent_Active_gne__c'), true);
				system.assertNotEquals(adminController.s_object.get('Theme_ref_gne__c'), null);
				system.assertEquals(adminController.s_object.get('Id'), adminController.objectId);
				//save Product
				adminController.s_object.put('Name','Edit Prod');
				adminController.saveProduct();
				system.assertEquals(adminController.objectMapProduct.get(adminController.objectId).selected, false);
				List<CFAR_Product_gne__c> prdSaved = [Select Id from CFAR_Product_gne__c where Name = 'Edit Prod'];
				List<CFAR_Product_gne__c> prdOld = [Select Id from CFAR_Product_gne__c where Name = 'Product2'];
				system.assertEquals(prdSaved.size(), 1);
				system.assertEquals(prdOld.size(), 0);
				//cancel edit Product
				adminController.editProduct();
				system.assertEquals(adminController.objectMapProduct.get(adminController.objectId).selected, true);
				adminController.cancelEditProduct();
				system.assertEquals(adminController.objectMapProduct.get(adminController.objectId).selected, false);
				//cancel create Product
				adminController.addNewProduct();
				system.assertEquals(adminController.addProduct, true);
				//delete Product
				/*
				adminController.deleteProduct();
				List<CFAR_Product_gne__c> delProd= [Select Id from CFAR_Product_gne__c where Name ='Edit Prod'];
				system.assertEquals(delProd.size(), 0);*/
				//add new Theme
				adminController.addNewTheme();
				system.assertEquals(adminController.addTheme, true);
				system.assertEquals(adminController.s_object.getSObjectType(), Schema.getGlobalDescribe().get('CFAR_Theme_gne__c'));
				adminController.s_object.put('Name', 'TH_T');
				adminController.s_object.put('Active_gne__c', true);
				//create new Theme
				adminController.createTheme();
				system.assertEquals(adminController.addTheme, false);
				List<CFAR_Theme_gne__c> newTH = [Select Id from CFAR_Theme_gne__c where Name ='TH_T'];
				system.assertEquals(newTH.size(), 1);
				//edit Theme
				adminController.objectId = [Select Id from CFAR_Theme_gne__c where Name='TH2'].Id;
				adminController.editTheme();
				system.assertEquals(adminController.objectMapTheme.get(adminController.objectId).selected, true);
				system.assertEquals(adminController.s_object.get('Name'), 'TH2');
				system.assertEquals(adminController.s_object.get('Active_gne__c'), true);
				system.assertEquals(adminController.s_object.get('Id'), adminController.objectId);
				//save Theme
				adminController.s_object.put('Name','THE');
				adminController.saveTheme();
				system.assertEquals(adminController.objectMapTheme.get(adminController.objectId).selected, false);
				List<CFAR_Theme_gne__c> thSaved = [Select Id from CFAR_Theme_gne__c where Name = 'THE'];
				List<CFAR_Theme_gne__c> thOld = [Select Id from CFAR_Theme_gne__c where Name = 'TH2'];
				system.assertEquals(thSaved.size(), 1);
				system.assertEquals(thOld.size(), 0);
				//cancel edit Theme
				adminController.editTheme();
				system.assertEquals(adminController.objectMapTheme.get(adminController.objectId).selected, true);
				adminController.cancelEditTheme();
				system.assertEquals(adminController.objectMapTheme.get(adminController.objectId).selected, false);
				//cancel create Theme
				adminController.addNewTheme();
				system.assertEquals(adminController.addTheme, true);
				adminController.controllerThemeBDay = adminController.controllerThemeBDay.addMinutes(-15);
				adminController.nextTheme();
				adminController.controllerProductBDay = adminController.controllerProductBDay.addMinutes(-15);
				adminController.nextProduct();
				//delete Theme
				/*
				adminController.deleteTheme();
				List<CFAR_Theme_gne__c> delTH = [Select Id from CFAR_Theme_gne__c where Name ='THE'];
				system.assertEquals(delTH.size(), 0);*/
			}
		Test.stopTest();
	}

	@isTest static void testUnitType()
	{
		List<sObject> testRecords = new List<sObject>();
		Map<sObject, Map<String, object>> objectConfig = new Map<sObject, Map<String, object>>();
		Map<String,object> fieldsConfig = new Map<String, object>();
		for(Integer ta=0; ta<=15; ta++)
		{
			fieldsConfig.put('Name', 'Unit Type' + String.valueOf(ta));
			fieldsConfig.put('Active_gne__c', true);
			objectConfig.put(new CFAR_Unit_Type_gne__c(), fieldsConfig);
			sObject cfarUnitType = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarUnitType);
		}
		insert testRecords;

		//test 21042016 END
		User adminUser = null;
		// start new context via system.runAs() for the same user
		System.runAs(new User(Id = Userinfo.getUserId())) {
			adminUser = CFAR_TestUtils.createTestAdminUser();
		}
		Test.startTest();
		system.runAs(adminUser)
		{
			CFAR_Administrator_Controller adminController = new CFAR_Administrator_Controller();
			system.assertEquals(adminController.getRenderAdminSection(), true);
			system.assertEquals(adminController.addUnitType, false);
			system.assertNotEquals(adminController.objectMapUnitType.size(), 0);
			//sort Unit Type
			adminController.sortExpression = 'Name';
			adminController.sortDirection = 'asc';
			adminController.sortUnitType();
			system.debug('adminController.objectListUnitType[0]= '+adminController.objectListUnitType[0].innerObject.get('Name'));
			system.assertEquals(adminController.objectListUnitType[0].innerObject.get('Name'), 'Unit Type0');
			//add Unit Type
			adminController.addNewUnitType();
			system.assertEquals(adminController.addUnitType, true);
			system.assertEquals(adminController.s_object.getSObjectType(), Schema.getGlobalDescribe().get('CFAR_Unit_Type_gne__c'));
			adminController.s_object.put('Name', 'Test Unit Type');
			adminController.s_object.put('Active_gne__c', true);
			//create new Unit Type
			adminController.createUnitType();
			system.assertEquals(adminController.addUnitType, false);
			List<CFAR_Unit_Type_gne__c> newUnitType = [Select Id from CFAR_Unit_Type_gne__c where Name ='Test Unit Type'];
			system.assertEquals(newUnitType.size(), 1);
			//edit Unit Type
			adminController.objectId = [Select Id from CFAR_Unit_Type_gne__c where Name='Unit Type2'].Id;
			adminController.editUnitType();
			system.assertEquals(adminController.objectMapUnitType.get(adminController.objectId).selected, true);
			system.assertEquals(adminController.s_object.get('Name'), 'Unit Type2');
			system.assertEquals(adminController.s_object.get('Active_gne__c'), true);
			system.assertEquals(adminController.s_object.get('Id'), adminController.objectId);
			//save Unit Type
			adminController.s_object.put('Name','Edit UT');
			adminController.saveUnitType();
			system.assertEquals(adminController.objectMapUnitType.get(adminController.objectId).selected, false);
			List<CFAR_Unit_Type_gne__c> unitTypeSaved = [Select Id from CFAR_Unit_Type_gne__c where Name = 'Edit UT'];
			List<CFAR_Unit_Type_gne__c> unitTypeOld = [Select Id from CFAR_Unit_Type_gne__c where Name = 'Unit Type2'];
			system.assertEquals(unitTypeSaved.size(), 1);
			system.assertEquals(unitTypeOld.size(), 0);
			//cancel edit Unit Type
			adminController.editUnitType();
			system.assertEquals(adminController.objectMapUnitType.get(adminController.objectId).selected, true);
			adminController.cancelEditUnitType();
			system.assertEquals(adminController.objectMapUnitType.get(adminController.objectId).selected, false);
			//cancel create Unit Type
			adminController.addNewUnitType();
			system.assertEquals(adminController.addUnitType, true);

			//validate UnitType
			adminController.s_object.put('Name', '');
			adminController.validateUnitType();
			System.assertEquals(new ApexPages.message(ApexPages.severity.ERROR, 
				Label.CFAR_ADMINTAB_UNITTYPE_CANT_BE_BLANK), ApexPages.getMessages().get(0));

			adminController.s_object.put('Name', 'Name that exceed 25 characters');
			adminController.validateUnitType();
			System.assertEquals(new ApexPages.message(ApexPages.severity.ERROR, 
				String.format(Label.CFAR_GSTARS_MAX_CHAR_NUMBER_EXCEEDED, new List<String>{'25'})), ApexPages.getMessages().get(1));

			adminController.s_object.put('Name', 'Unit Type1');

			adminController.validateUnitType();
			System.assertEquals(new ApexPages.message(ApexPages.severity.ERROR, 
				Label.CFAR_ADMINTAB_MOLECULE_UNITTYPE_EXISTS), ApexPages.getMessages().get(2));

			//delete Unit Type
			CFAR_Theme_gne__c theme = new CFAR_Theme_gne__c(
				Name = '99999',
				Theme_Name_gne__c = 'Accutane',
				Active_gne__c = true
			);
			insert theme;

			CFAR_Product_gne__c product1 = new CFAR_Product_gne__c(
				Theme_ref_gne__c = theme.Id,
				Name = 'Accutane',
				Generic_Name_gne__c = 'acc',
				Active_gne__c = true
			);
			insert product1;

			CFAR_Molecule_Configuration_gne__c molecConfig = new CFAR_Molecule_Configuration_gne__c(
				Product_gne__c = product1.Id,
				CFAR_Unit_Type_ref_gne__c = adminController.objectId,
				Configuration_gne__c = '100mg',
				Active_gne__c = true
			);
			insert molecConfig;

			adminController.deleteUnitType();
			System.assertEquals(new ApexPages.message(ApexPages.severity.ERROR, 
				Label.CFAR_ADMINTAB_CANT_DELETE_UNIT_TYPE), ApexPages.getMessages().get(3));

			delete molecConfig;
			adminController.deleteUnitType();
			System.assertEquals(0, [SELECT COUNT() FROM CFAR_Unit_Type_gne__c WHERE Id =:adminController.objectId]);
			adminController.controllerUnitTypeBDay = adminController.controllerUnitTypeBDay.addMinutes(-15);
			adminController.nextUnitType();
		}
		Test.stopTest();
	}

	@isTest static void testItAdminUser() 
	{
		//Test Data Creation - start
		List<sObject> testRecords = new List<sObject>();
		Map<sObject, Map<String, object>> objectConfig = new Map<sObject, Map<String, object>>();
		Map<String,object> fieldsConfig = new Map<String, object>();
		for(Integer ta=0; ta<=15; ta++)
		{	
			fieldsConfig.put('Name', 'Ther Area' + String.valueOf(ta));
			fieldsConfig.put('Active_gne__c', true);
			objectConfig.put(new CFAR_Therapeutic_Area_gne__c(), fieldsConfig);
			sObject cfarTherapeuticArea = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarTherapeuticArea);
		}
		objectConfig = new Map<sObject, Map<String, object>>();
		fieldsConfig = new Map<String, object>();
		for(Integer wi=0; wi<=15; wi++)
		{	
			fieldsConfig.put('Name', 'WBS Name' + String.valueOf(wi));
			fieldsConfig.put('Active_gne__c', true);
			fieldsConfig.put('GSR_WBS_gne__c', 'WBS'+String.valueOf(wi));
			objectConfig.put(new CFAR_WBS_gne__c(), fieldsConfig);
			sObject cfarWBS = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarWBS);
		}
		insert testRecords;
		testRecords = new List<sObject>();
		objectConfig = new Map<sObject, Map<String, object>>();
		fieldsConfig = new Map<String, object>();
		for(Integer th=0; th<=15; th++)
		{	
			fieldsConfig.put('Name', 'TH' + String.valueOf(th));
			fieldsConfig.put('Active_gne__c', true);
			objectConfig.put(new CFAR_Theme_gne__c(), fieldsConfig);
			sObject cfarTheme = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarTheme);
		}
		insert testRecords;
		testRecords = new List<sObject>();
		objectConfig = new Map<sObject, Map<String, object>>();
		fieldsConfig = new Map<String, object>();
		List<CFAR_Theme_gne__c> cfarThemes = [Select Id, Name from CFAR_Theme_gne__c];
		Integer prodCounter = 0;
		for(CFAR_Theme_gne__c theme : cfarThemes)
		{
			fieldsConfig.put('Name', 'Product_' + theme.Name);
			fieldsConfig.put('Description_gne__c', 'ABCD'+String.valueOf(prodCounter));
			fieldsConfig.put('Generic_Name_gne__c', 'GenName' + String.valueOf(prodCounter));
			fieldsConfig.put('Other_GNE_Agent_Active_gne__c', true);
			fieldsConfig.put('Active_gne__c', true);
			fieldsConfig.put('Theme_ref_gne__c', theme.Id);
			objectConfig.put(new CFAR_Product_gne__c(), fieldsConfig);
			sObject cfarProduct = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarProduct);
			prodCounter++;
		}
		insert testRecords;
		//Test Data Creatio - stop
		User itAdminUser = null;
		// start new context via system.runAs() for the same user
		System.runAs(new User(Id = Userinfo.getUserId())) {
			itAdminUser = CFAR_TestUtils.createTestITAdminUser();
		}
		Test.startTest();
			system.runAs(itAdminUser)
			{
				CFAR_Administrator_Controller adminController = new CFAR_Administrator_Controller();
				system.assertEquals(adminController.getRenderItAdminSection(), true);
				system.assertEquals(adminController.addWBS, false);
				system.assertNotEquals(adminController.objectMapWBS.size(), 0);
				system.assertEquals(adminController.addProduct, false);
				system.assertNotEquals(adminController.objectMapProduct.size(), 0);
				system.assertEquals(adminController.addTheme, false);
				system.assertNotEquals(adminController.objectMapTheme.size(), 0);
			}
		Test.stopTest();
	}
	@isTest static void testParentOrganization()
	{
		List<sObject> testRecords = new List<sObject>();
		Map<sObject, Map<String, object>> objectConfig = new Map<sObject, Map<String, object>>();
		Map<String,object> fieldsConfig = new Map<String, object>();
		for(Integer po=0; po<=15; po++)
		{	
			fieldsConfig.put('Name', 'Parent Organization' + String.valueOf(po));
			fieldsConfig.put('Active_gne__c', true);
			objectConfig.put(new CFAR_Parent_Organization_gne__c(), fieldsConfig);
			sObject cfarParentOrg = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarParentOrg);
		}
		insert testRecords;

		//test 21042016 END
		User adminUser = null;
		// start new context via system.runAs() for the same user
		System.runAs(new User(Id = Userinfo.getUserId())) {
			adminUser = CFAR_TestUtils.createTestAdminUser();
		}
		Test.startTest();
			system.runAs(adminUser)
			{
				CFAR_Administrator_Controller adminController = new CFAR_Administrator_Controller();
				system.assertEquals(adminController.getRenderAdminSection(), true);
				system.assertNotEquals(adminController.objectMapParentOrganization.size(), 0);
				//add new ParentOrganization
				adminController.addNewParentOrganization();
				system.assertEquals(adminController.addParentOrganization, true);
				system.assertEquals(adminController.s_object.getSObjectType(), Schema.getGlobalDescribe().get('CFAR_Parent_Organization_gne__c'));
				adminController.s_object.put('Name', 'Test Parent Org AAA');
				adminController.s_object.put('Active_gne__c', true);
				adminController.nextParentOrganization();
				adminController.previousParentOrganization();
				adminController.lastParentOrganization();
				system.assertEquals(adminController.hasPreviousParentOrganization, true);
				adminController.firstParentOrganization();
				system.assertEquals(adminController.hasNextParentOrganization, true);
				//create new ParentOrganization

				adminController.saveParentOrganizationValidation();
				System.assertEquals(adminController.isError,false);

				adminController.validation=false;
				adminController.createParentOrganization();
				system.assertEquals(adminController.addParentOrganization, true);
				List<CFAR_Parent_Organization_gne__c> newParentOrganization = [Select Id from CFAR_Parent_Organization_gne__c where Name ='Test Parent Org AAA'];
				system.assertEquals(newParentOrganization.size(), 1);
				//edit ParentOrganization
				adminController.objectId = [Select Id from CFAR_Parent_Organization_gne__c where Name='Parent Organization2'].Id;
				adminController.editParentOrganization();
				system.assertEquals(adminController.objectMapParentOrganization.get(adminController.objectId).selected, true);
				system.assertEquals(adminController.s_object.get('Name'), 'Parent Organization2');
				system.assertEquals(adminController.s_object.get('Active_gne__c'), true);
				system.assertEquals(adminController.s_object.get('Id'), adminController.objectId);
				//save ParentOrganization
				adminController.s_object.put('Name','Edit Parent Organization');
				adminController.saveParentOrganization();
				system.assertEquals(adminController.objectMapParentOrganization.get(adminController.objectId).selected, false);
				List<CFAR_Parent_Organization_gne__c> poSaved = [Select Id from CFAR_Parent_Organization_gne__c where Name = 'Edit Parent Organization'];
				List<CFAR_Parent_Organization_gne__c> poOld = [Select Id from CFAR_Parent_Organization_gne__c where Name = 'Parent Organization2'];
				system.assertEquals(poSaved.size(), 1);
				system.assertEquals(poOld.size(), 0);
				//cancel edit ParentOrganization
				adminController.editParentOrganization();
				system.assertEquals(adminController.objectMapParentOrganization.get(adminController.objectId).selected, true);
				adminController.cancelEditParentOrganization();
				system.assertEquals(adminController.objectMapParentOrganization.get(adminController.objectId).selected, false);
				//cancel create ParentOrganization
				adminController.addNewParentOrganization();
				system.assertEquals(adminController.addParentOrganization, true);
				//delete ParentOrganization
				Apexpages.currentPage().getParameters().put('parentOrgToDelete',adminController.objectId);
				system.assertEquals(CFAR_Administrator_Controller.checkIfDeletableParentOrganization(adminController.objectId),false);
				adminController.deleteParentOrganization();
				List<CFAR_Parent_Organization_gne__c> delPO = [Select Id from CFAR_Parent_Organization_gne__c where Name ='Edit Parent Organization'];
				system.assertEquals(delPO.size(), 0);
				adminController.controllerParentOrganizationBDay = DateTime.now().addMinutes(-15);
				adminController.nextParentOrganization();
			}
		Test.stopTest();
	}
	@isTest static void testMoleculeConfiguration()
	{
		List<sObject> testRecords = new List<sObject>();
		Map<sObject, Map<String, object>> objectConfig = new Map<sObject, Map<String, object>>();
		Map<String,object> fieldsConfig = new Map<String, object>();
		//test 21042016 BEGIN

		CFAR_Unit_Type_gne__c unitType = new CFAR_Unit_type_gne__c();
		unitType.Name = 'Tablet';
		unitType.Active_gne__c = true;
		insert unitType;

		System.assertEquals(1, [SELECT ID FROM CFAR_Unit_Type_gne__c].size());

		for(Integer th=0; th<=15; th++)
		{
			fieldsConfig.put('Name', 'TH' + String.valueOf(th));
			fieldsConfig.put('Active_gne__c', true);
			objectConfig.put(new CFAR_Theme_gne__c(), fieldsConfig);
			sObject cfarTheme = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarTheme);
		}
		insert testRecords;
		testRecords = new List<sObject>();
		objectConfig = new Map<sObject, Map<String, object>>();
		fieldsConfig = new Map<String, object>();
		List<CFAR_Theme_gne__c> cfarThemes = [Select Id, Name from CFAR_Theme_gne__c];
		Integer prodCounter = 0;
		for(CFAR_Theme_gne__c theme : cfarThemes)
		{
			fieldsConfig.put('Name', 'Product' + String.valueOf(prodCounter));
			fieldsConfig.put('Description_gne__c', 'ABCD'+String.valueOf(prodCounter));
			fieldsConfig.put('Generic_Name_gne__c', 'GenName' + String.valueOf(prodCounter));
			fieldsConfig.put('Other_GNE_Agent_Active_gne__c', true);
			fieldsConfig.put('Active_gne__c', true);
			fieldsConfig.put('Theme_ref_gne__c', theme.Id);
			objectConfig.put(new CFAR_Product_gne__c(), fieldsConfig);
			sObject cfarProduct = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarProduct);
			prodCounter++;
		}
		insert testRecords;
		//test 21042016 END
		testRecords = new List<sObject>();
		objectConfig = new Map<sObject, Map<String, object>>();
		fieldsConfig = new Map<String, object>();
		List<CFAR_Product_gne__c> cfarProducts = [select id, Name from CFAR_Product_gne__c];
		List<CFAR_Unit_Type_gne__c> cfarUnitTypes = [select id, Name from CFAR_Unit_Type_gne__c];
		Integer molCounter = 0;

		User adminUser = null;
		// start new context via system.runAs() for the same user
		System.runAs(new User(Id = Userinfo.getUserId())) {
			adminUser = CFAR_TestUtils.createTestAdminUser();
		}
		Test.startTest();
			system.runAs(adminUser)
			{
				CFAR_Administrator_Controller adminController = new CFAR_Administrator_Controller();
				system.assertEquals(adminController.getRenderAdminSection(), true);
				system.assertEquals(adminController.objectMapMoleculeConfiguration.size(), 0);

				//add new MoleculeConfiguration
				adminController.addNewMoleculeConfiguration();
				system.assertEquals(adminController.addMoleculeConfiguration, true);
				system.assertEquals(adminController.s_object.getSObjectType(), Schema.getGlobalDescribe().get('CFAR_Molecule_Configuration_gne__c'));
				adminController.s_object.put('Name', 'Molecule');
				adminController.s_object.put('Active_gne__c', true);
				adminController.s_object.put('Configuration_gne__c', 'created conf');
				adminController.s_object.put('Product_gne__c', cfarProducts.get(0).Id);
				adminController.selectedUnitType = unitType.id;

				//create new MoleculeConfiguration
				adminController.saveMoleculeConfigurationValidation();
				adminController.fillMoleculeConfigurations();
				adminController.validation=false;
				adminController.createMoleculeConfiguration();
				System.assertEquals(1, [SELECT ID FROM CFAR_MOlecule_Configuration_gne__c].size());
				system.assertEquals(adminController.addMoleculeConfiguration, true);

 				List<CFAR_Molecule_Configuration_gne__c> newMoleculeConfiguration = [Select Id from CFAR_Molecule_Configuration_gne__c where Name ='Molecule'];
				system.assertEquals(newMoleculeConfiguration.size(), 1);

 				//edit MoleculeConfiguration
				adminController.fillMoleculeConfigurations();
				adminController.objectId = [Select Id from CFAR_Molecule_Configuration_gne__c].Id;
				System.assertEquals(adminController.objectId, [SELECT ID FROM CFAR_Molecule_Configuration_gne__c].id);
				adminController.editMoleculeConfiguration();
				adminController.s_object=adminController.objectMapMoleculeConfiguration.get(adminController.objectId).innerObject;

				//system.assertEquals(adminController.objectMapMoleculeConfiguration.get(adminController.objectId).selected, true);
				system.assertEquals(adminController.s_object.get('Configuration_gne__c'), 'created conf');
				system.assertEquals(adminController.s_object.get('Active_gne__c'), true);
				system.assertEquals(adminController.s_object.get('Id'), adminController.objectId);
				//save MoleculeConfiguration
				adminController.s_object.put('Configuration_gne__c','edited conf');
				adminController.saveMoleculeConfiguration();
				system.assertEquals(adminController.objectMapMoleculeConfiguration.get(adminController.objectId).selected, false);
				List<CFAR_Molecule_Configuration_gne__c> mcSaved = [Select Id from CFAR_Molecule_Configuration_gne__c where Configuration_gne__c = 'edited conf'];
				List<CFAR_Molecule_Configuration_gne__c> mcOld = [Select Id from CFAR_Molecule_Configuration_gne__c where Configuration_gne__c = 'created conf'];
				system.assertEquals(mcSaved.size(), 1);
				system.assertEquals(mcOld.size(), 0);
				//cancel edit MoleculeConfiguration
				adminController.editMoleculeConfiguration();
				system.assertEquals(adminController.objectMapMoleculeConfiguration.get(adminController.objectId).selected, true);
				adminController.cancelEditMoleculeConfiguration();
				system.assertEquals(adminController.objectMapMoleculeConfiguration.get(adminController.objectId).selected, false);
				//cancel create MoleculeConfiguration
				adminController.addNewMoleculeConfiguration();
				system.assertEquals(adminController.addMoleculeConfiguration, true);
//				//delete MoleculeConfiguration
				Apexpages.currentPage().getParameters().put('moleculeConfigurationToDelete',adminController.objectId);
				system.assertEquals(CFAR_Administrator_Controller.checkIfDeletableMoleculeConfiguration(adminController.objectId),false);
				adminController.deleteMoleculeConfiguration();
				List<CFAR_Molecule_Configuration_gne__c> delMC = [Select Id from CFAR_Molecule_Configuration_gne__c];
				system.assertEquals(delMC.size(), 0);

				//test pagination
				sObject[] configurations = new List<sObject>();
				for (Integer po = 0; po <= 15; po++) {
					sObject clonedConfiguration = adminController.s_object.clone(false,true);
					clonedConfiguration.put('Name', 'Molecule' + String.valueOf(po));
					clonedConfiguration.put('Configuration_gne__c', 'created conf' +  String.valueOf(po));
					clonedConfiguration.put('Product_gne__c', cfarProducts.get(0).Id);
					configurations.add(clonedConfiguration);
				}
				insert configurations;
				adminController.fillMoleculeConfigurations();
				adminController.nextMoleculeConfiguration();
				adminController.previousMoleculeConfiguration();
				adminController.lastMoleculeConfiguration();
				system.assertEquals(adminController.hasPreviousMoleculeConfiguration, true);
				adminController.firstMoleculeConfiguration();
				system.assertEquals(adminController.hasNextMoleculeConfiguration, true);
				adminController.controllerMoleculeConfigurationBDay = adminController.controllerMoleculeConfigurationBDay.addMinutes(-15);
				adminController.nextMoleculeConfiguration();
			}
		Test.stopTest();
	}

	@isTest static void testInstitution()
	{
		List<sObject> testRecords = new List<sObject>();
		Map<sObject, Map<String, object>> objectConfig = new Map<sObject, Map<String, object>>();
		Map<String,object> fieldsConfig = new Map<String, object>();
		for(Integer po=0; po<=15; po++)
		{	
			fieldsConfig.put('Name', 'Parent Organization' + String.valueOf(po));
			fieldsConfig.put('Active_gne__c', true);
			objectConfig.put(new CFAR_Parent_Organization_gne__c(), fieldsConfig);
			sObject cfarParentOrg = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarParentOrg);
		}
		insert testRecords;

		//test 21042016 END
		testRecords = new List<sObject>();
		objectConfig = new Map<sObject, Map<String, object>>();
		fieldsConfig = new Map<String, object>();
		List<CFAR_Parent_Organization_gne__c> cfarParentOrgs = [select id, Name from CFAR_Parent_Organization_gne__c];
		Integer instCounter = 0;
		for(CFAR_Parent_Organization_gne__c parorg : cfarParentOrgs)
		{	
			fieldsConfig.put('Name', 'Institution' + String.valueOf(instCounter));
			fieldsConfig.put('Active_gne__c', true);
			fieldsConfig.put('Parent_Organization__c', parorg.id); 
			objectConfig.put(new CFAR_Institution_gne__c(), fieldsConfig);
			sObject cfarParentOrg = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarParentOrg);
			instCounter++;
		}
		insert testRecords;
		User adminUser = null;
		// start new context via system.runAs() for the same user
		System.runAs(new User(Id = Userinfo.getUserId())) {
			adminUser = CFAR_TestUtils.createTestAdminUser();
		}
		Test.startTest();
			system.runAs(adminUser)
			{
				CFAR_Administrator_Controller adminController = new CFAR_Administrator_Controller();
				system.assertEquals(adminController.getRenderAdminSection(), true);
				system.assertEquals(adminController.objectMapInstitution.size(), 10);
				//add new Institution
				adminController.addNewInstitution();
				system.assertEquals(adminController.addInstitution, true);
				system.assertEquals(adminController.s_object.getSObjectType(), Schema.getGlobalDescribe().get('CFAR_Institution_gne__c'));
				adminController.s_object.put('Name', 'Institution AAA');
				adminController.s_object.put('Parent_Organization__c', [Select Id from CFAR_Parent_Organization_gne__c where Name='Parent Organization2'].Id);
				adminController.s_object.put('Active_gne__c', true);
				adminController.nextInstitution();
				adminController.previousInstitution();
				adminController.lastInstitution();
				system.assertEquals(adminController.hasPreviousInstitution, true);
				adminController.firstInstitution();
				system.assertEquals(adminController.hasNextInstitution, true);
				//create new Institution
				adminController.saveInstitutionValidation();
				System.assertEquals(adminController.isError,false);
				adminController.validation=false;
				adminController.createInstitution();
				system.assertEquals(adminController.addInstitution, true);
				List<CFAR_Institution_gne__c> newInstitution = [Select Id from CFAR_Institution_gne__c where Name ='Institution AAA'];
				system.assertEquals(newInstitution.size(), 1);
				adminController.fillInstitutions();
				//edit Institution
				adminController.objectId = [Select Id from CFAR_Institution_gne__c where Name='Institution AAA'].Id;
				adminController.editInstitution();
				system.assertEquals(adminController.objectMapInstitution.get(adminController.objectId).selected, true);
				system.assertEquals(adminController.s_object.get('Name'), 'Institution AAA');
				system.assertEquals(adminController.s_object.get('Active_gne__c'), true);
				system.assertEquals(adminController.s_object.get('Id'), adminController.objectId);
				//save Institution
				adminController.s_object.put('Name','Edit Institution');
				adminController.saveInstitution();
				system.assertEquals(adminController.objectMapInstitution.get(adminController.objectId).selected, false);
				List<CFAR_Institution_gne__c> insSaved = [Select Id from CFAR_Institution_gne__c where Name = 'Edit Institution'];
				List<CFAR_Institution_gne__c> insOld = [Select Id from CFAR_Institution_gne__c where Name = 'Institution AAA'];
				system.assertEquals(insSaved.size(), 1);
				system.assertEquals(insOld.size(), 0);
				//cancel edit Institution
				adminController.editInstitution();
				system.assertEquals(adminController.objectMapInstitution.get(adminController.objectId).selected, true);
				adminController.cancelEditInstitution();
				system.assertEquals(adminController.objectMapInstitution.get(adminController.objectId).selected, false);
				//cancel create Institution
				adminController.addNewInstitution();
				system.assertEquals(adminController.addInstitution, true);
				//delete Institution
				//adminController.fillInstitutions();
				Apexpages.currentPage().getParameters().put('institutionToDelete',adminController.objectId);
				system.assertEquals(CFAR_Administrator_Controller.checkIfDeletableInstitution(adminController.objectId),false);
				adminController.deleteInstitution();
				List<CFAR_Institution_gne__c> delIns = [Select Id from CFAR_Institution_gne__c where Name ='Edit Institution'];
				system.assertEquals(delIns.size(), 0);
				adminController.controllerInstitutionBDay = adminController.controllerInstitutionBDay.addMinutes(-15);
				adminController.nextInstitution();
			}
		Test.stopTest();
	}
	@isTest static void testInstitutionAddress()
	{
		List<sObject> testRecords = new List<sObject>();
		Map<sObject, Map<String, object>> objectConfig = new Map<sObject, Map<String, object>>();
		Map<String,object> fieldsConfig = new Map<String, object>();
		for(Integer po=0; po<=15; po++)
		{	
			fieldsConfig.put('Name', 'Parent Organization' + String.valueOf(po));
			fieldsConfig.put('Active_gne__c', true);
			objectConfig.put(new CFAR_Parent_Organization_gne__c(), fieldsConfig);
			sObject cfarParentOrg = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarParentOrg);
		}
		insert testRecords;

		//test 21042016 END
		testRecords = new List<sObject>();
		objectConfig = new Map<sObject, Map<String, object>>();
		fieldsConfig = new Map<String, object>();
		List<CFAR_Parent_Organization_gne__c> cfarParentOrgs = [select id, Name from CFAR_Parent_Organization_gne__c];
		Integer instCounter = 0;
		for(CFAR_Parent_Organization_gne__c parorg : cfarParentOrgs)
		{	
			fieldsConfig.put('Name', 'Institution' + String.valueOf(instCounter));
			fieldsConfig.put('Active_gne__c', true);
			fieldsConfig.put('Parent_Organization__c', parorg.id); 
			objectConfig.put(new CFAR_Institution_gne__c(), fieldsConfig);
			sObject cfarParentOrg = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarParentOrg);
			instCounter++;
		}
		insert testRecords;
		User adminUser = null;
		// start new context via system.runAs() for the same user
		System.runAs(new User(Id = Userinfo.getUserId())) {
			adminUser = CFAR_TestUtils.createTestAdminUser();
		}
		Test.startTest();
			system.runAs(adminUser)
			{
				CFAR_Administrator_Controller adminController = new CFAR_Administrator_Controller();
				system.assertEquals(adminController.getRenderAdminSection(), true);
				system.assertEquals(adminController.objectMapInstitutionAddress.size(), 0);
				//add new Institution Address
				adminController.addNewInstitutionAddress();
				system.assertEquals(adminController.addInstitutionAddress, true);
				system.assertEquals(adminController.s_object.getSObjectType(), Schema.getGlobalDescribe().get('CFAR_Contact_Address_gne__c'));

				adminController.selectedInstitution = [Select Id from CFAR_Institution_gne__c  where Name='Institution2'].Id;
				adminController.s_object.put('Name', 'Institution Address AAA');
				adminController.s_object.put('Active_gne__c', true);
				adminController.s_object.put('Address_Type_gne__c', 'Test Type');
				adminController.s_object.put('Address_gne__c','created address');
				adminController.s_object.put('City_gne__c', 'some city');
				adminController.s_object.put('State_gne__c', 'DC');
				adminController.s_object.put('Zip_gne__c', '78451');

				//create new ParentOrganization
				adminController.validation=false;
				adminController.createInstitutionAddress();
				system.assertEquals(adminController.addInstitutionAddress, true);

				//create new address type
				CFAR_Address_Type_gne__c addressType = new CFAR_Address_Type_gne__c();
				addressType.Name = 'Fedex Delivery';
				insert addressType;

				List<CFAR_Contact_Address_gne__c> newInstitutionAddress = [Select Id from CFAR_Contact_Address_gne__c where Name ='Institution Address AAA'];
				system.assertEquals(newInstitutionAddress.size(), 1);
				adminController.addNewInstitutionAddress();
				system.assertEquals(adminController.addInstitutionAddress, true);
				system.assertEquals(adminController.s_object.getSObjectType(), Schema.getGlobalDescribe().get('CFAR_Contact_Address_gne__c'));
				adminController.selectedInstitution = [Select Id from CFAR_Institution_gne__c  where Name='Institution2'].Id;
				adminController.s_object.put('Name', 'Institution Address BBB');
				adminController.s_object.put('Active_gne__c', true);
				adminController.s_object.put('Address_Type_gne__c', 'Test Type');
				adminController.s_object.put('address_gne__c','created address');
				adminController.s_object.put('City_gne__c', 'some city');
				adminController.s_object.put('State_gne__c', 'DC');
				adminController.s_object.put('Zip_gne__c', '78451');
				adminController.s_object.put('Address_Type_ref_gne__c', String.valueOf(addressType.Id));

				//create new Institutio Address
				adminController.validation=false;
				adminController.createInstitutionAddress();
				adminController.fillInstitutionAddresses();

				//edit Institution Address
				adminController.objectId = [Select Id from CFAR_Contact_Address_gne__c where Name='Institution Address AAA'].Id;
				adminController.editInstitutionAddress();
				system.assertEquals(adminController.objectMapInstitutionAddress.get(adminController.objectId).selected, true);
				system.assertEquals(adminController.s_object.get('Name'), 'Institution Address AAA');
				system.assertEquals(adminController.s_object.get('Active_gne__c'), true);
				system.assertEquals(adminController.s_object.get('Id'), adminController.objectId);

				adminController.s_object.put('Address_Type_ref_gne__c', addressType.Id);
				CFAR_Contact_gne__c investigator = CFAR_TestUtils.createTestInvestigator();
				CFAR_Contact_Address_JO_gne__c joinAddress = new CFAR_Contact_Address_JO_gne__c();
				joinAddress.CFAR_Contact_ref_gne__c = investigator.id;
				joinAddress.Contact_Address_ref_gne__c = adminController.objectId;
				insert joinAddress;
				joinAddress = [SELECT Name, CFAR_Contact_ref_gne__r.Name FROM CFAR_Contact_Address_JO_gne__c WHERE Id = :joinAddress.Id];

				//test saveInstitutionAddressValidation
				//GIVEN
				sObject clonedSObject = adminController.s_object.clone(true, true);
				adminController.s_object.put('Active_gne__c', false);
				adminController.s_object.put('address_gne__c', null);
				adminController.selectedCountry = 'USA';
				adminController.s_object.put('state_gne__c', null);
				adminController.s_object.put('Zip_gne__c', null);
				adminController.s_object.put('city_gne__c', null);

				//WHEN
				adminController.saveInstitutionAddressValidation();

				//THEN
				System.assertEquals(new ApexPages.message(ApexPages.severity.ERROR, 
					Label.CFAR_ADMINTAB_CANT_DEACTIVATE_INSTITUTION_ADDRESS), ApexPages.getMessages().get(0));
				System.assertEquals(new ApexPages.message(ApexPages.severity.ERROR, 
					Label.CFAR_ADMINTAB_ADDRESS_CANT_BE_BLANK), ApexPages.getMessages().get(1));
				System.assertEquals(new ApexPages.message(ApexPages.severity.ERROR, 
					Label.CFAR_ADMINTAB_CITY_CANT_BE_BLANK), ApexPages.getMessages().get(2));
				System.assertEquals(new ApexPages.message(ApexPages.severity.ERROR, 
					Label.CFAR_ADMINTAB_STATE_CANT_BE_BLANK), ApexPages.getMessages().get(3));
				System.assertEquals(new ApexPages.message(ApexPages.severity.ERROR, 
					Label.CFAR_ADMINTAB_ZIP_CANT_BE_BLANK), ApexPages.getMessages().get(4));

				//GIVEN
				adminController.s_object = clonedSObject.clone(true, true);
				adminController.s_object.put('Zip_gne__c', 'qwertyuiop');

				//WHEN
				adminController.saveInstitutionAddressValidation();

				//THEN
				System.assertEquals(new ApexPages.message(ApexPages.severity.ERROR, 
					Label.CFAR_ADMINTAB_INVALID_ZIP_FORMAT), ApexPages.getMessages().get(5));

				//GIVEN
				adminController.s_object = clonedSObject.clone(true, true);
				adminController.selectedCountry = 'Poland';
				adminController.s_object.put('Province_gne__c', null);
				adminController.s_object.put('Postal_Code_gne__c', null);
				adminController.s_object.put('Address_Type_ref_gne__c', null);

				//WHEN
				adminController.saveInstitutionAddressValidation();

				//THEN
				System.assertEquals(new ApexPages.message(ApexPages.severity.ERROR, 
					Label.CFAR_ADMINTAB_PROVINCE_CANT_BE_BLANK), ApexPages.getMessages().get(6));
				System.assertEquals(new ApexPages.message(ApexPages.severity.ERROR, 
					Label.CFAR_ADMINTAB_POSTAL_CANT_BE_BLANK), ApexPages.getMessages().get(7));

				//save Institution Address
				adminController.s_object = clonedSObject.clone(true, true);
				adminController.editInstitutionAddress();
				adminController.s_object.put('Name','Edit Institution Address');
				CFAR_Address_Type_gne__c addrType = new CFAR_Address_Type_gne__c(Name = 'testType', Active_gne__c = true);
				insert addrType;
				adminController.selectedAddressType = addrType.Id;
				adminController.saveInstitutionAddress();
				system.assertEquals(adminController.objectMapInstitutionAddress.get(adminController.objectId).selected, false);
				List<CFAR_Contact_Address_gne__c> insAdrSaved = [Select Id from CFAR_Contact_Address_gne__c where Name = 'Edit Institution Address'];
				List<CFAR_Contact_Address_gne__c> insAdrOld = [Select Id from CFAR_Contact_Address_gne__c where Name = 'Institution Address AAA'];
				system.assertEquals(1, insAdrSaved.size());
				system.assertEquals(0, insAdrOld.size());
				//cancel edit Institution Address
				adminController.editInstitutionAddress();
				system.assertEquals(adminController.objectMapInstitutionAddress.get(adminController.objectId).selected, true);
				adminController.cancelEditInstitutionAddress();
				system.assertEquals(adminController.objectMapInstitutionAddress.get(adminController.objectId).selected, false);
				//cancel create Institution Address
				adminController.addNewInstitutionAddress();
				system.assertEquals(adminController.addInstitutionAddress, true);
				//delete Institution Address
				Apexpages.currentPage().getParameters().put('institutionAddressToDelete',adminController.objectId);
				adminController.deleteInstitutionAddress();
				List<CFAR_Contact_Address_gne__c> delInsAdr = [Select Id from CFAR_Contact_Address_gne__c where Name ='Edit Institution Address'];
				system.assertEquals(delInsAdr.size(), 1);
				adminController.selectedInstitution = [Select Id from CFAR_Institution_gne__c  where Name='Institution2'].Id;
				adminController.fillInstitutionAddresses();
				Apexpages.currentPage().getParameters().put('institutionAddressToDelete',adminController.objectId);
				system.assertEquals(true, CFAR_Administrator_Controller.checkIfDeletableInstitutionAddress(adminController.objectId));
				adminController.deleteInstitutionAddress();
				delInsAdr = [Select Id from CFAR_Contact_Address_gne__c where Name ='Edit Institution Address'];
				system.assertEquals(1, delInsAdr.size());
				System.assertEquals(new ApexPages.message(ApexPages.severity.ERROR, String.format(Label.CFAR_ADMINTAB_CANT_DELETE_INSTITUTION_ADDRESS, 
					new List<String>{joinAddress.CFAR_Contact_ref_gne__r.Name + '; '})), ApexPages.getMessages().get(8));
				delete joinAddress;
				adminController.deleteInstitutionAddress();
				delInsAdr = [Select Id from CFAR_Contact_Address_gne__c where Name ='Edit Institution Address'];
				system.assertEquals(0, delInsAdr.size());

				//test pgination
				sObject[] institutionAddresses = new List<sObject>();
				for (Integer th = 0; th <= 15; th++) {
					sObject s_object = clonedSObject.clone(false, true);
					institutionAddresses.add(s_object);
				}
				insert institutionAddresses;
				adminController.fillInstitutionAddresses();
				adminController.nextInstitutionAddress();
				adminController.previousInstitutionAddress();
				adminController.lastInstitutionAddress();
				system.assertEquals(adminController.hasPreviousInstitutionAddress, true);
				adminController.firstInstitutionAddress();
				system.assertEquals(adminController.hasNextInstitutionAddress, true);
				adminController.controllerInstitutionAddressBDay = Datetime.now().addMinutes(-15);
				adminController.nextInstitutionAddress();
			}
		Test.stopTest();
	}
	
	@isTest static void testFieldHistory()
	{
		List<sObject> testRecords = new List<sObject>();
		Map<sObject, Map<String, object>> objectConfig = new Map<sObject, Map<String, object>>();
		Map<String,object> fieldsConfig = new Map<String, object>();
		//test 21042016 BEGIN
		for(Integer th=0; th<=15; th++)
		{	
			fieldsConfig.put('Name', 'TH' + String.valueOf(th));
			fieldsConfig.put('Active_gne__c', true);
			objectConfig.put(new CFAR_Theme_gne__c(), fieldsConfig);
			sObject cfarTheme = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarTheme);
		}
		insert testRecords;
		testRecords = new List<sObject>();
		objectConfig = new Map<sObject, Map<String, object>>();
		fieldsConfig = new Map<String, object>();
		List<CFAR_Theme_gne__c> cfarThemes = [Select Id, Name from CFAR_Theme_gne__c];
		Integer prodCounter = 0;
		for(CFAR_Theme_gne__c theme : cfarThemes)
		{
			fieldsConfig.put('Name', 'Product' + String.valueOf(prodCounter));
			fieldsConfig.put('Description_gne__c', 'ABCD'+String.valueOf(prodCounter));
			fieldsConfig.put('Generic_Name_gne__c', 'GenName' + String.valueOf(prodCounter));
			fieldsConfig.put('Other_GNE_Agent_Active_gne__c', true);
			fieldsConfig.put('Active_gne__c', true);
			fieldsConfig.put('Theme_ref_gne__c', theme.Id);
			objectConfig.put(new CFAR_Product_gne__c(), fieldsConfig);
			sObject cfarProduct = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarProduct);
			prodCounter++;
		}
		insert testRecords;
		//test 21042016 END
		testRecords = new List<sObject>();
		objectConfig = new Map<sObject, Map<String, object>>();
		fieldsConfig = new Map<String, object>();
		for(Integer t=0; t<=15; t++) {
			fieldsConfig.put('Name', 'Trial'+String.valueOf(t));
			fieldsConfig.put('Cost_Center_gne__c', 'abc');
			fieldsConfig.put('Cost_Element_gne__c', 'abc');
			fieldsConfig.put('Planned_Enrollment_gne__c', 10);
			fieldsConfig.put('Received_Date_gne__c', Date.today());
			objectConfig.put(new CFAR_Trial_gne__c(), fieldsConfig);
			sObject cfarTrial = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarTrial);
		}
		User adminUser = null;
		// start new context via system.runAs() for the same user
		System.runAs(new User(Id = Userinfo.getUserId())) {
			adminUser = CFAR_TestUtils.createTestAdminUser();
		}
		Test.startTest();
			system.runAs(adminUser)
			{
				CFAR_Administrator_Controller adminController = new CFAR_Administrator_Controller();
				system.assertEquals(adminController.getRenderAdminSection(), true);
				//init
				adminController.historyInitNewTrial();
				adminController.sortFieldHistory();
			}
		Test.stopTest();
	}

	@isTest static void showDeleteErrors_shouldReturnErrorMessages() {
		CFAR_Administrator_Controller adminController = new CFAR_Administrator_Controller();
		adminController.showParentOrganizationDeleteError();
		System.assertEquals(new ApexPages.message(ApexPages.severity.ERROR, Label.CFAR_ADMINTAB_CANT_DELETE_ORGANIZATION), ApexPages.getMessages().get(0));

		adminController.showInstitutionDeleteError();
		System.assertEquals(new ApexPages.message(ApexPages.severity.ERROR,
		Label.CFAR_ADMINTAB_CANT_DELETE_INSTITUTION_ASSOCIATED_ADDRESS), ApexPages.getMessages().get( ApexPages.getMessages().size() - 1));

		adminController.showInstitutionAddressDeleteError();
		System.assertEquals(new ApexPages.message(ApexPages.severity.ERROR,
		Label.CFAR_ADMINTAB_CANT_DELETE_INSTITUTION_ASSOCIATED_CONTACT), ApexPages.getMessages().get( ApexPages.getMessages().size() - 1));

		adminController.showMoleculeConfigurationDeleteError();
		System.assertEquals(new ApexPages.message(ApexPages.severity.ERROR,
		Label.CFAR_ADMINTAB_CANT_DELETE_MOLECULE_CONFIG), ApexPages.getMessages().get( ApexPages.getMessages().size() - 1));
	}

	@IsTest
	private static void shouldPaginateUnitTypes() {
		System.runAs(CFAR_TestUtils.createTestAdminUser()) {
			List<CFAR_Unit_Type_gne__c> toInsert = new List<CFAR_Unit_Type_gne__c>();
			for (Integer i = 0; i < 25; i++) {
				toInsert.add(new CFAR_Unit_Type_gne__c(
						Name = 'Test' + i,
						Active_gne__c = true
				));
			}
			insert toInsert;
			CFAR_Administrator_Controller adminController = new CFAR_Administrator_Controller();

			adminController.fillUnitType();
			System.assertEquals(10, adminController.objectMapUnitType.size());
			System.assertEquals(10, adminController.objectListUnitType.size());
			Id firstPageRecord = adminController.objectListUnitType[0].innerObject.Id;
			System.assert(String.isNotBlank(firstPageRecord));
			System.assertEquals(false, adminController.hasPreviousUnitType);
			System.assertEquals(true, adminController.hasNextUnitType);

			adminController.nextUnitType();
			System.assertEquals(10, adminController.objectMapUnitType.size());
			System.assertEquals(10, adminController.objectListUnitType.size());
			Id nextPageRecord = adminController.objectListUnitType[0].innerObject.Id;
			System.assert(String.isNotBlank(nextPageRecord));
			System.assertNotEquals(firstPageRecord, nextPageRecord);
			System.assertEquals(true, adminController.hasPreviousUnitType);
			System.assertEquals(true, adminController.hasNextUnitType);

			adminController.lastUnitType();
			System.assertEquals(5, adminController.objectMapUnitType.size());
			System.assertEquals(5, adminController.objectListUnitType.size());
			Id lastPageRecord = adminController.objectListUnitType[0].innerObject.Id;
			System.assert(String.isNotBlank(lastPageRecord));
			System.assertNotEquals(firstPageRecord, lastPageRecord);
			System.assertNotEquals(nextPageRecord, lastPageRecord);
			System.assertEquals(true, adminController.hasPreviousUnitType);
			System.assertEquals(false, adminController.hasNextUnitType);
		}
	}

	@isTest
	static void testSRTTeam() {
		System.runAs(CFAR_TestUtils.createTestAdminUser()) {
			List<CFAR_Picklist_Value_gne__c> testSRTTeams = new List<CFAR_Picklist_Value_gne__c>();
			for (Integer i = 0; i < 16; i++) {
				testSRTTeams.add(new CFAR_Picklist_Value_gne__c(RecordTypeId = Schema.SObjectType.CFAR_Picklist_Value_gne__c.getRecordTypeInfosByName().get('SRT Team').getRecordTypeId()));
			}
			insert testSRTTeams;
			CFAR_Administrator_Controller adminController = new CFAR_Administrator_Controller();
			adminController.showSRTTeam = true;
			adminController.addNewSRTTeam();
			adminController.cancelCreateSRTTeam();
			adminController.addNewSRTTeam();
			adminController.s_object.put('Name', 'TestName');
			adminController.createSRTTeam();
			adminController.controllerSRTTeamBDay= adminController.controllerSRTTeamBDay.addMinutes(-15);
			adminController.nextSRTTeam();
		}
	}
}