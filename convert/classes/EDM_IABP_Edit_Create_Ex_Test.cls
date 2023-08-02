@isTest
private class EDM_IABP_Edit_Create_Ex_Test {
	static EDM_AABP_gne__c testAABP;
	static EDM_IABP_gne__c testIABP;

	static void insertData() {		
		List<sObject> AABPnIABP = EDM_ABM_Test_Utils.insertABMStructure();
		testAABP = (EDM_AABP_gne__c)AABPnIABP[0];
		testIABP = (EDM_IABP_gne__c)AABPnIABP[1];
	}

	static EDM_IABP_Edit_Create_Ex setupPage() {
		insertData();
    	insert new GNE_SFA2_User_App_Context_gne__c(SFA2_Mode_gne__c = true, App_Name_gne__c = 'ABM', Role_gne__c = 'ABS-Manager', Brand_gne__c = null, SetupOwnerId = UserInfo.getUserId());

    	PageReference pr = Page.EDM_IABP_Edit_Create;
		pr.getParameters().put('Id', testIABP.Id);
		Test.setCurrentPage(pr);
        ApexPages.StandardController iabpSC = new ApexPages.StandardController(testIABP);
        EDM_IABP_Edit_Create_Ex controller = new EDM_IABP_Edit_Create_Ex(iabpSC);
        System.assertNotEquals(null, controller.myObject);

        PageReference cInitRef = controller.init();
        System.debug('$$ debug: ' + cInitRef);
        System.assert(cInitRef == null);

        return controller;
	}
	static EDM_IABP_Edit_Create_Ex setupPage(EDM_IABP_gne__c test_IABP,EDM_AABP_gne__c test_AABP) {

    	insert new GNE_SFA2_User_App_Context_gne__c(SFA2_Mode_gne__c = true, App_Name_gne__c = 'ABM', Role_gne__c = 'ABS-Manager', Brand_gne__c = null, SetupOwnerId = UserInfo.getUserId());

    	PageReference pr = Page.EDM_IABP_Edit_Create;
		pr.getParameters().put('Id', test_IABP.Id);
		Test.setCurrentPage(pr);
        ApexPages.StandardController iabpSC = new ApexPages.StandardController(test_IABP);
        EDM_IABP_Edit_Create_Ex controller = new EDM_IABP_Edit_Create_Ex(iabpSC);
        System.assertNotEquals(null, controller.myObject);

        PageReference cInitRef = controller.init();
        System.debug('$$ debug: ' + cInitRef);
        //System.assertEquals(cInitRef == null);

        return controller;
	}

	@isTest 
	static void testControllerExt() {		
		EDM_ABM_Test_Utils.insertIABPConfig();

        User abs = EDM_ABM_Test_Utils.getABSes()[0]; //Eduardo
        System.assert(abs != null);
        System.debug('$$ User: ' + abs);
        System.runAs(abs) {

	        EDM_IABP_Edit_Create_Ex controller = setupPage();
	        controller.validateUpdatedIABP();
	        controller.getABPlanners();
	        controller.saveIABP();
	        controller.getStates();
	        controller.submitToABS();
	        controller.returnToABL();
	        controller.getHours();
	        controller.getMinutes();
	        controller.getPeriods();
	        controller.getProvinces();
	        controller.getTotalEstimated();
	        controller.getTotalActual();
	        controller.getBrands();
			controller.getEventFocus();

	        PageReference goBack = controller.goBack();
	        System.assert(goBack.getUrl().contains('EDM_AABP_Layout'));

	        String title = controller.getIABPTitle();
	        System.assert(!String.isBlank(title));        
        }
	}

	@isTest 
	static void testIABPRelatedList() {
		EDM_ABM_Test_Utils.insertIABPConfig();

		User abs = EDM_ABM_Test_Utils.getABSes()[0]; //Eduardo
        System.assert(abs != null);
        System.runAs(abs) { 
	        EDM_IABP_Edit_Create_Ex controller = setupPage();

	        controller.addObjective();
	        System.assert(controller.Objectives.size() == 1);
	        controller.RowToDel = 0;
	        controller.delObjective();
	        System.assert(controller.Objectives.size() == 0);

	        controller.addQuestion();
	        System.assert(controller.ABQuestions.size() == 1);
	        controller.RowToDel = 0;
	        controller.delQuestion();
	        System.assert(controller.ABQuestions.size() == 0);

	        controller.addBudgetItem();
	        System.assert(controller.Budget.size() == 10);
	        controller.RowToDel = 0;
	        controller.delBudgetItem();
	        System.assert(controller.Budget.size() == 9);

	        controller.addSession();
	        System.assert(controller.Agenda.size() == 1);
	        controller.RowToDel = 0;
	        controller.delSession();
	        System.assert(controller.Agenda.size() == 0);
        }        
	}
	
	public static testMethod void saveIABPTest() {		
		EDM_ABM_Test_Utils.insertIABPConfig();

        User abs = EDM_ABM_Test_Utils.getABSes()[0]; //Eduardo
        System.assert(abs != null);
        System.debug('$$ User: ' + abs);
        System.runAs(abs) {

        	insert new EDM_Notifications_gne__c(
				Name = 'Default',
				Escalation_Address_gne__c = 'test@gmail.com',
				Test_CC_Address_gne__c = 'test@gmail.com'
			);

        	EDM_IABP_Edit_Create_Ex controller = setupPage();
	        
	        PageReference pr = controller.saveIABP(); 

	        List<Apexpages.Message> msgs = ApexPages.getMessages();
			System.assertEquals(1,msgs.size());
			System.assertEquals('IABP has been saved.',msgs[0].getDetail());
        }
	}

	public static testMethod void saveAndGoBackAsABSTest() {		
		
		EDM_ABM_Test_Utils.insertIABPConfig();

        User abs = EDM_ABM_Test_Utils.getABSes()[0]; //Eduardo
        System.assert(abs != null);
        System.debug('$$ User: ' + abs);
        System.runAs(abs) {
        	
        	insert new EDM_Notifications_gne__c(
				Name = 'Default',
				Escalation_Address_gne__c = 'test@gmail.com',
				Test_CC_Address_gne__c = 'test@gmail.com'
			);

        	EDM_IABP_Edit_Create_Ex controller = setupPage();
	        
	        System.currentPageReference().getParameters().put('retURL','www.google.com');
		
			PageReference pr = controller.saveAndGoBack();

	        System.assertEquals('www.google.com',pr.getUrl());
        }
	}

	public static testMethod void saveAndGoBackAsABLTest() {		
		
		EDM_ABM_Test_Utils.insertIABPConfig();

        User abs = EDM_ABM_Test_Utils.getABLs()[0];
        System.assert(abs != null);
        System.debug('$$ User: ' + abs);
        System.runAs(abs) {
        	
        	insert new EDM_Notifications_gne__c(
				Name = 'Default',
				Escalation_Address_gne__c = 'test@gmail.com',
				Test_CC_Address_gne__c = 'test@gmail.com'
			);
			
        	EDM_IABP_Edit_Create_Ex controller = setupPage();
	        
	        System.currentPageReference().getParameters().put('retURL','www.google.com');
		
			PageReference pr = controller.saveAndGoBack();
	        System.assertEquals('www.google.com',pr.getUrl());
        }
	}

	public static testMethod void shareIABPTest(){

		insert new EDM_Notifications_gne__c(
			Name = 'Default',
			Escalation_Address_gne__c = 'test@gmail.com',
			Test_CC_Address_gne__c = 'test@gmail.com'
		);

		EDM_ABM_Test_Utils.insertIABPConfig();
		User abs = EDM_ABM_Test_Utils.getABSes()[0];

        System.runAs(abs){

			EDM_IABP_Edit_Create_Ex ext = setupPage();

			ext.UsersSharedWith.add(new SelectOption(UserInfo.getUserId(),UserInfo.getUserName()));
			System.assert(ext.UsersSharedWith.size()>0);
			PageReference pr = ext.shareIABP();

			System.assertEquals(null, pr);
        }
	}

	public static testMethod void convertIABPToSingleEventTest(){

		insert new EDM_Notifications_gne__c(
			Name = 'Default',
			Escalation_Address_gne__c = 'test@gmail.com',
			Test_CC_Address_gne__c = 'test@gmail.com'
		);

		EDM_ABM_Test_Utils.insertIABPConfig();
		User abs = EDM_ABM_Test_Utils.getABSes()[0];

        System.runAs(abs){
			List<sObject> AABPnIABP = EDM_ABM_Test_Utils.insertABMStructure();
			
			// create a new joint event and share it
			EDM_AABP_gne__c jointAABP = (EDM_AABP_gne__c)AABPnIABP[0];
			EDM_IABP_gne__c adHocIABP = (EDM_IABP_gne__c)AABPnIABP[1];
			List<String> jointAABPsIds = new List<String> { jointAABP.Id };
			adHocIABP.EDM_Joint_AABP_gne__c = jointAABPsIds[0];
			system.debug('adHocIABP.EDM_Joint_AABP_gne__c:'  + adHocIABP.EDM_Joint_AABP_gne__c);
			update adHocIABP;

			EDM_IABP_Edit_Create_Ex ext = setupPage(adHocIABP, jointAABP);

			Set<Id> uShareIds = EDM_ABM_Utils.getUserIdsToShareWithBaseOnAABPs(jointAABP, jointAABPsIds);
			uShareIds.add(UserInfo.getUserId()); //add current user for ad-hoc in case when current user is not ab lead or vandor 
			uShareIds.addAll(EDM_ABM_Utils.getUserIdsForRole(EDM_ABM_Utils.ABS));
			List<User> uShare = EDM_ABM_Utils.getUsers(uShareIds);
			EDM_ABM_Utils.shareRecord(adHocIABP.Id, uShare, EDM_ABM_Utils.AL_EDIT, EDM_ABM_Utils.SHARE_DIRECTCHILD);
			
			List<EDM_IABP_gne__Share> iabpSharesBefore = [SELECT UserOrGroupId FROM EDM_IABP_gne__Share WHERE ParentId = :adHocIABP.Id
                                                                AND UserOrGroupId IN :uShareIds];
			ext.convertToSingleEvent();
			
			List<EDM_IABP_gne__Share> iabpSharesAfter = [SELECT UserOrGroupId FROM EDM_IABP_gne__Share WHERE ParentId = :adHocIABP.Id
                                                                AND UserOrGroupId IN :uShareIds];			
			
			System.assert(iabpSharesAfter.size() < iabpSharesBefore.size());			
			EDM_IABP_gne__c iabpAfter = [SELECT EDM_Joint_AABP_gne__c FROM EDM_IABP_gne__c WHERE Id =: adHocIABP.Id LIMIT 1];
			System.assertEquals(null, iabpAfter.EDM_Joint_AABP_gne__c);
        }
	}

	public static testMethod void getPossibleGroupsTest(){

		EDM_ABM_Test_Utils.insertIABPConfig();
		User abs = EDM_ABM_Test_Utils.getABSes()[0];

        System.runAs(abs){

			EDM_IABP_Edit_Create_Ex ext = setupPage();

			ext.oGroup = 'Multiple;Group1;Group2';
			List<SelectOption> groups = ext.getPossibleGroups();
			System.assertEquals(2,groups.size(),groups);
        }
	}

	public static testMethod void getPossibleGroupsTest2(){

		EDM_ABM_Test_Utils.insertIABPConfig();
		User abs = EDM_ABM_Test_Utils.getABSes()[0];

        System.runAs(abs){

			EDM_IABP_Edit_Create_Ex ext = setupPage();

			ext.oGroup = 'Group1';
			List<SelectOption> groups = ext.getPossibleGroups();
			System.assertEquals(1,groups.size());
        }
	}

	public static testMethod void addQuestionLimitTest(){

		EDM_ABM_Test_Utils.insertIABPConfig();
		User abs = EDM_ABM_Test_Utils.getABSes()[0];

        System.runAs(abs){

			EDM_IABP_Edit_Create_Ex ext = setupPage();

			for(Integer i = 0;i < ext.AB_QUESTIONS_LIMIT; i++){
				ext.addQuestion();
			}
			System.assertEquals(ext.AB_QUESTIONS_LIMIT,ext.ABQuestions.size());
			PageReference pr = ext.addQuestion();
			System.assertEquals(null, pr);

			List<Apexpages.Message> msgs = ApexPages.getMessages();
			System.assertEquals(1,msgs.size());
			System.assert(msgs[0].getDetail().contains('You cannot add more than ' + String.valueOf(ext.AB_QUESTIONS_LIMIT) + ' Session Objectives!'));
        }
	}

	public static testMethod void addBudgetItemLimitTest(){

		EDM_ABM_Test_Utils.insertIABPConfig();
		User abs = EDM_ABM_Test_Utils.getABSes()[0];

        System.runAs(abs){

			EDM_IABP_Edit_Create_Ex ext = setupPage();

			for(Integer i = 0;i < ext.BUDGET_LIMIT; i++){
				ext.addBudgetItem();
			}
			System.assertEquals(ext.BUDGET_LIMIT,ext.Budget.size());
			PageReference pr = ext.addBudgetItem();
			System.assertEquals(null, pr);

			List<Apexpages.Message> msgs = ApexPages.getMessages();
			System.assertEquals(1,msgs.size());
			System.assert(msgs[0].getDetail().contains('You cannot add more than ' + String.valueOf(ext.BUDGET_LIMIT) + ' Budget Items!'));
        }
	}

	public static testMethod void addObjectiveLimitTest(){

		EDM_ABM_Test_Utils.insertIABPConfig();
		User abs = EDM_ABM_Test_Utils.getABSes()[0];

        System.runAs(abs){

			EDM_IABP_Edit_Create_Ex ext = setupPage();

			for(Integer i = 0;i < ext.OBJECTIVES_LIMIT; i++){
				ext.addObjective();
			}
			System.assertEquals(ext.OBJECTIVES_LIMIT,ext.Objectives.size());
			PageReference pr = ext.addObjective();
			System.assertEquals(null, pr);

			List<Apexpages.Message> msgs = ApexPages.getMessages();
			System.assertEquals(1,msgs.size());
			System.assert(msgs[0].getDetail().contains('You cannot add more than ' + String.valueOf(ext.OBJECTIVES_LIMIT) + ' Objectives!'));
        }
	}

	public static testMethod void renumberObjectivesTest(){

		EDM_ABM_Test_Utils.insertIABPConfig();
		User abs = EDM_ABM_Test_Utils.getABSes()[0];

        System.runAs(abs){

			EDM_IABP_Edit_Create_Ex ext = setupPage();

			ext.oGroup = 'Multiple;TestGroup';
			ext.addObjective();
			ext.oGroup = 'Commercial';
			ext.addObjective();
			ext.oGroup = 'Medical';
			ext.addObjective();
			ext.oGroup = 'gRED';
			ext.addObjective();
			ext.oGroup = 'PD';
			ext.addObjective();
			ext.oGroup = 'Other';
			ext.addObjective();

			System.assertEquals(6,ext.Objectives.size());
			ext.RowToDel = 0;
			PageReference pr = ext.renumberObjectives();
        }
	}

	public static testMethod void addSessionTest(){

		EDM_ABM_Test_Utils.insertIABPConfig();
		User abs = EDM_ABM_Test_Utils.getABSes()[0];

        System.runAs(abs){

        	testAABP = new EDM_AABP_gne__c(
				EDM_Plan_Year_gne__c = '2015',
				EDM_Plan_Received_gne__c = Date.today(),
				EDM_Final_Approval_Received_gne__c = Date.today()
			);
			insert testAABP;
			testIABP = new EDM_IABP_gne__c(
				EDM_Parent_AABP_gne__c = testAABP.Id,
				EDM_Executive_Summary_gne__c = true,
				EDM_Type_of_Event_gne__c = 'test event type',
				EDM_IABP_Version_gne__c = 199
			);
			insert testIABP;
			EDM_Session_gne__c session = new EDM_Session_gne__c(
				EDM_Parent_IABP_gne__c = testIABP.Id
			);
			insert session;

			ApexPages.StandardController sc = new ApexPages.StandardController(testIABP);
			EDM_IABP_Edit_Create_Ex ext = setupPage();
			ext.init();

			Integer sessionsSize = ext.Agenda.size();

			Apexpages.currentPage().getParameters().put('sessionId',session.Id);
			ext.newSession = session;

			ext.populateSessionForEdit();
			PageReference pr = ext.addSession();
			
			ext.RowToDel = 0;
			ext.delSession();
			System.assertEquals(sessionsSize-1,ext.Agenda.size());
        }
	}

	public static testMethod void initSessionTest(){

		EDM_ABM_Test_Utils.insertIABPConfig();
		User abs = EDM_ABM_Test_Utils.getABSes()[0];

        System.runAs(abs){

        	testAABP = new EDM_AABP_gne__c(
				EDM_Plan_Year_gne__c = '2015',
				EDM_Plan_Received_gne__c = Date.today(),
				EDM_Final_Approval_Received_gne__c = Date.today()
			);
			insert testAABP;
			testIABP = new EDM_IABP_gne__c(
				EDM_Parent_AABP_gne__c = testAABP.Id,
				EDM_Executive_Summary_gne__c = true,
				EDM_Type_of_Event_gne__c = 'test event type',
				EDM_IABP_Version_gne__c = 199
			);
			insert testIABP;
			EDM_Session_gne__c session = new EDM_Session_gne__c(
				EDM_Parent_IABP_gne__c = testIABP.Id
			);
			insert session;

			ApexPages.StandardController sc = new ApexPages.StandardController(testIABP);
			EDM_IABP_Edit_Create_Ex ext = setupPage();
			ext.init();

			PageReference pr = ext.initSession();
        }
	}

	public static testMethod void getPresentationAndDiscussionTimePercentageTest(){

		EDM_ABM_Test_Utils.insertIABPConfig();
		User abs = EDM_ABM_Test_Utils.getABSes()[0];

        System.runAs(abs){

        	insert new EDM_Notifications_gne__c(
				Name = 'Default',
				Escalation_Address_gne__c = 'test@gmail.com',
				Test_CC_Address_gne__c = 'test@gmail.com'
			);

			EDM_IABP_Edit_Create_Ex ext = setupPage();

			ext.PresentationStart = new EDM_IABP_Utils.TimeWrapper();
			ext.presentationStart.setFromString('1:20:10');
			ext.PresentationEnd = new EDM_IABP_Utils.TimeWrapper();
			ext.PresentationEnd.setFromString('1:20:10');
			ext.DiscussionStart = new EDM_IABP_Utils.TimeWrapper();
			ext.DiscussionStart.setFromString('1:20:10');
			ext.DiscussionEnd = new EDM_IABP_Utils.TimeWrapper();
			ext.DiscussionEnd.setFromString('1:20:10');

			PageReference pr = ext.addSession();

			List<Apexpages.Message> msgs = ApexPages.getMessages();
			System.assertEquals(1,msgs.size(),msgs);
			System.assert(msgs[0].getDetail().contains('IABP has been saved.'));

			System.assertEquals('50', ext.agendaSummary.getPresentationTimePercentage());
			System.assertEquals('50', ext.agendaSummary.getDiscussionTimePercentage());
			Integer sessionsSize = ext.Agenda.size();

			ext.RowToDel = 0;
			ext.delSession();

			System.assertEquals(sessionsSize-1,ext.Agenda.size());

			System.assertEquals('0:40', ext.agendaSummary.getTotalMeetingTime());
		}
	}

	public static testMethod void compareVersionsLinkTest(){

		EDM_ABM_Test_Utils.insertIABPConfig();
		
		User abs = EDM_ABM_Test_Utils.getABSes()[0];

        System.runAs(abs){
        	insert new EDM_Notifications_gne__c(
				Name = 'Default',
				Escalation_Address_gne__c = 'test@gmail.com',
				Test_CC_Address_gne__c = 'test@gmail.com'
			);
			
			testAABP = new EDM_AABP_gne__c(
				EDM_Plan_Year_gne__c = '2015',
				EDM_Plan_Received_gne__c = Date.today(),
				EDM_Final_Approval_Received_gne__c = Date.today()
			);
			insert testAABP;
			testIABP = new EDM_IABP_gne__c(
				EDM_Parent_AABP_gne__c = testAABP.Id,
				EDM_Executive_Summary_gne__c = true,
				EDM_Type_of_Event_gne__c = 'test event type',
				EDM_IABP_Version_gne__c = 199
			);
			insert testIABP;
			EDM_IABP_gne__c compareIABP = new EDM_IABP_gne__c(
				EDM_Parent_AABP_gne__c = testAABP.Id,
				EDM_Executive_Summary_gne__c = true,
				EDM_Type_of_Event_gne__c = 'test event type',
				EDM_IABP_Version_gne__c = 199
			);
			insert compareIABP;

			insert new Product_vod__c(
				Product_Type_vod__c = 'Detail',
	        	Detail_Product_Subtype_Code_gne__c = 'Brand',
	        	Brand_Code_gne__c = 'abc'
	        );

			ApexPages.StandardController sc = new ApexPages.StandardController(testIABP);
			EDM_IABP_Edit_Create_Ex ext = setupPage();

			ext.init();
			String compareURL = '/apex/EDM_IABP_Version_Compare';
			compareURL += '?idOld=' + compareIABP.Id;
			compareURL += '&idNew=' + testIABP.Id;
			compareURL += '&retURL=/apex/EDM_IABP_Edit_Create?Id=' + testIABP.Id;

			String brand = EDM_ABM_Utils.getListOfBrands()[0];
			List<SelectOption> brandOption = new List<SelectOption>();
			brandOption.add(new SelectOption(brand, brand));

			ext.SelectedBrands = brandOption;
			ext.compareId = compareIABP.Id;

			ext.addQuestion();
			PageReference pr = ext.compareVersions();

			List<Apexpages.Message> msgs = ApexPages.getMessages();
				System.assertEquals(1,msgs.size(),msgs);
				System.assertEquals(msgs[0].getDetail(),'IABP has been saved.');


			System.assert(pr.getUrl().contains('/apex/EDM_IABP_Version_Compare'));
			System.assert(pr.getUrl().contains('idOld=' + compareIABP.Id));
			System.assert(pr.getUrl().contains('idNew=' + testIABP.Id));
		}
	}
	
	//public static testMethod void checkIfExistsNotClassifiedOrExcludedAttendeesTest(){

	//	EDM_ABM_Test_Utils.insertIABPConfig();
	//	User abs = EDM_ABM_Test_Utils.getABSes()[0];

 //       System.runAs(abs){

	//		testAABP = new EDM_AABP_gne__c(
	//			EDM_Plan_Year_gne__c = '2015',
	//			EDM_Plan_Received_gne__c = Date.today(),
	//			EDM_Final_Approval_Received_gne__c = Date.today()
	//		);
	//		insert testAABP;
	//		testIABP = new EDM_IABP_gne__c(
	//			EDM_Parent_AABP_gne__c = testAABP.Id,
	//			EDM_Executive_Summary_gne__c = true,
	//			EDM_Type_of_Event_gne__c = 'test event type',
	//			EDM_IABP_Version_gne__c = 199
	//		);
	//		insert testIABP;

	//		System.assertEquals(false,EDM_IABP_Edit_Create_Ex.checkIfExistsNotClassifiedOrExcludedAttendees(testIABP.Id));

	//		Account a = new Account(
	//			Name = 'TestAccount',
	//			AGS_EX_Exclusion_Status_Base_gne__c = 'Excluded'
	//		);
	//		insert a;
	//		insert new EDM_Attendee_gne__c(
	//			EDM_Parent_IABP_gne__c = testIABP.Id,
	//			EDM_Account_gne__c = a.Id
	//		);

	//		System.assertEquals(true,EDM_IABP_Edit_Create_Ex.checkIfExistsNotClassifiedOrExcludedAttendees(testIABP.Id));
 //       }
	//}

	public static testMethod void sendForApprovalNoApproversTest(){

		EDM_ABM_Test_Utils.insertIABPConfig();
		User abs = EDM_ABM_Test_Utils.getABSes()[0];

	    System.runAs(abs){

			testAABP = new EDM_AABP_gne__c(
				EDM_Plan_Year_gne__c = '2015',
				EDM_Plan_Received_gne__c = Date.today(),
				EDM_Final_Approval_Received_gne__c = Date.today()
			);
			insert testAABP;
			testIABP = new EDM_IABP_gne__c(
				EDM_Parent_AABP_gne__c = testAABP.Id,
				EDM_Executive_Summary_gne__c = false,
				EDM_Type_of_Event_gne__c = 'test event type',
				EDM_IABP_Version_gne__c = 199
			);
			insert testIABP;

			EDM_IABP_Edit_Create_Ex ext = setupPage();
	    	ext.init();
			Test.startTest();
			PageReference pr = ext.sendForApproval();
			Test.stopTest();
			List<Apexpages.Message> msgs = ApexPages.getMessages();
			System.assertEquals(1,msgs.size());
			System.assert(msgs[0].getDetail().contains('At least one Approver needs to be selected.'));
		}
	}

	public static testMethod void sendForApprovalOneApproverTest(){
		
		EDM_ABM_Test_Utils.insertIABPConfig();
		User abs = EDM_ABM_Test_Utils.getABSes()[0];

	    System.runAs(abs){
			insert new EDM_Notifications_gne__c(
				Name = 'Default',
				Escalation_Address_gne__c = 'test@gmail.com',
				Test_CC_Address_gne__c = 'test@gmail.com'
			);

			testAABP = new EDM_AABP_gne__c(
				EDM_Plan_Year_gne__c = '2015',
				EDM_Plan_Received_gne__c = Date.today(),
				EDM_Final_Approval_Received_gne__c = Date.today()
			);
			insert testAABP;
			testIABP = new EDM_IABP_gne__c(
				EDM_Parent_AABP_gne__c = testAABP.Id,
				EDM_Executive_Summary_gne__c = false,
				EDM_Type_of_Event_gne__c = 'test event type',
				EDM_IABP_Version_gne__c = 199,
				EDM_Approver_1_gne__c = UserInfo.getUserId()
			);
			insert testIABP;	

			EDM_IABP_Edit_Create_Ex ext = setupPage();
			ext.init();
			Test.startTest();

			ext.selectedApprovers.add(ext.getAvailableApprovers()[0]);

			PageReference pr = ext.sendForApproval();
			Test.stopTest();
			testIABP = [Select EDM_Approval_Status_gne__c,EDM_Approver_1_Status_gne__c,EDM_Version_Validated_gne__c,EDM_Approval_Request_Comment_gne__c From EDM_IABP_gne__c Where Id = :testIABP.Id Limit 1];
			System.assertEquals('Submitted',testIABP.EDM_Approval_Status_gne__c);
			System.assertEquals('Sent for approval '+ Date.today().format(),testIABP.EDM_Approver_1_Status_gne__c);
			System.assertEquals(null,testIABP.EDM_Approval_Request_Comment_gne__c);
			System.assertEquals(Date.today(),testIABP.EDM_Version_Validated_gne__c);
		}
	}

	public static testMethod void sendForApprovalTwoApproversTest(){
		
		EDM_ABM_Test_Utils.insertIABPConfig();
		User abs = EDM_ABM_Test_Utils.getABSes()[0];

	    System.runAs(abs){
			insert new EDM_Notifications_gne__c(
				Name = 'Default',
				Escalation_Address_gne__c = 'test@gmail.com',
				Test_CC_Address_gne__c = 'test@gmail.com'
			);

			testAABP = new EDM_AABP_gne__c(
				EDM_Plan_Year_gne__c = '2015',
				EDM_Plan_Received_gne__c = Date.today(),
				EDM_Final_Approval_Received_gne__c = Date.today()
			);
			insert testAABP;
			testIABP = new EDM_IABP_gne__c(
				EDM_Parent_AABP_gne__c = testAABP.Id,
				EDM_Executive_Summary_gne__c = false,
				EDM_Type_of_Event_gne__c = 'test event type',
				EDM_IABP_Version_gne__c = 199
			);
			insert testIABP;

			EDM_IABP_Edit_Create_Ex ext = setupPage();
			ext.init();
			Test.startTest();
			ext.selectedApprovers.add(ext.getAvailableApprovers()[0]);
			ext.selectedApprovers.add(ext.getAvailableApprovers()[1]);

			PageReference pr = ext.sendForApproval();
			Test.stopTest();
			
			testIABP = [Select EDM_Approval_Status_gne__c,EDM_Approver_1_Status_gne__c,EDM_Approver_2_Status_gne__c,EDM_Version_Validated_gne__c,EDM_Approval_Request_Comment_gne__c From EDM_IABP_gne__c 
			              Where Id = :testIABP.Id Limit 1];
			System.assertEquals('Submitted',testIABP.EDM_Approval_Status_gne__c);
			System.assertEquals('Sent for approval '+ Date.today().format(),testIABP.EDM_Approver_1_Status_gne__c);
			System.assertEquals('Sent for approval '+ Date.today().format(),testIABP.EDM_Approver_2_Status_gne__c);
			System.assertEquals(null,testIABP.EDM_Approval_Request_Comment_gne__c);
			System.assertEquals(Date.today(),testIABP.EDM_Version_Validated_gne__c);
		}
	}

	public static testMethod void sendForApprovalThreeApproversTest(){
		
		EDM_ABM_Test_Utils.insertIABPConfig();
		User abs = EDM_ABM_Test_Utils.getABSes()[0];

	    System.runAs(abs){
			insert new EDM_Notifications_gne__c(
				Name = 'Default',
				Escalation_Address_gne__c = 'test@gmail.com',
				Test_CC_Address_gne__c = 'test@gmail.com'
			);

			testAABP = new EDM_AABP_gne__c(
				EDM_Plan_Year_gne__c = '2015',
				EDM_Plan_Received_gne__c = Date.today(),
				EDM_Final_Approval_Received_gne__c = Date.today()
			);
			insert testAABP;
			testIABP = new EDM_IABP_gne__c(
				EDM_Parent_AABP_gne__c = testAABP.Id,
				EDM_Executive_Summary_gne__c = false,
				EDM_Type_of_Event_gne__c = 'test event type',
				EDM_IABP_Version_gne__c = 199
			);
			insert testIABP;

			EDM_IABP_Edit_Create_Ex ext = setupPage();
			ext.init();
			Test.startTest();

			ext.selectedApprovers.add(ext.getAvailableApprovers()[0]);
			ext.selectedApprovers.add(ext.getAvailableApprovers()[1]);
			ext.selectedApprovers.add(ext.getAvailableApprovers()[2]);

			PageReference pr = ext.sendForApproval();
			Test.stopTest();
			
			testIABP = [Select EDM_Approval_Status_gne__c,EDM_Approver_1_Status_gne__c,EDM_Approver_2_Status_gne__c,EDM_Approver_3_Status_gne__c,EDM_Version_Validated_gne__c,EDM_Approval_Request_Comment_gne__c
						  From EDM_IABP_gne__c 
			              Where Id = :testIABP.Id Limit 1];
			System.assertEquals('Submitted',testIABP.EDM_Approval_Status_gne__c);
			System.assertEquals('Sent for approval '+ Date.today().format(),testIABP.EDM_Approver_1_Status_gne__c);
			System.assertEquals('Sent for approval '+ Date.today().format(),testIABP.EDM_Approver_2_Status_gne__c);
			System.assertEquals('Sent for approval '+ Date.today().format(),testIABP.EDM_Approver_3_Status_gne__c);
			System.assertEquals(null,testIABP.EDM_Approval_Request_Comment_gne__c);
			System.assertEquals(Date.today(),testIABP.EDM_Version_Validated_gne__c);
		}
	}
	public static testMethod void sendForApprovalFourApproversTest(){
		
		EDM_ABM_Test_Utils.insertIABPConfig();
		User abs = EDM_ABM_Test_Utils.getABSes()[0];

	    System.runAs(abs){
			insert new EDM_Notifications_gne__c(
				Name = 'Default',
				Escalation_Address_gne__c = 'test@gmail.com',
				Test_CC_Address_gne__c = 'test@gmail.com'
			);

			testAABP = new EDM_AABP_gne__c(
				EDM_Plan_Year_gne__c = '2015',
				EDM_Plan_Received_gne__c = Date.today(),
				EDM_Final_Approval_Received_gne__c = Date.today()
			);
			insert testAABP;
			testIABP = new EDM_IABP_gne__c(
				EDM_Parent_AABP_gne__c = testAABP.Id,
				EDM_Executive_Summary_gne__c = false,
				EDM_Type_of_Event_gne__c = 'test event type',
				EDM_IABP_Version_gne__c = 199
			);
			insert testIABP;
			
			EDM_IABP_Edit_Create_Ex ext = setupPage();
			ext.init();
			Test.startTest();
			ext.selectedApprovers.add(ext.getAvailableApprovers()[0]);
			ext.selectedApprovers.add(ext.getAvailableApprovers()[1]);
			ext.selectedApprovers.add(ext.getAvailableApprovers()[2]);
			ext.selectedApprovers.add(ext.getAvailableApprovers()[3]);

			PageReference pr = ext.sendForApproval();
			Test.stopTest();
			testIABP = [Select EDM_Approval_Status_gne__c,EDM_Approver_1_Status_gne__c,EDM_Approver_2_Status_gne__c,EDM_Approver_3_Status_gne__c,EDM_Approver_4_Status_gne__c,EDM_Version_Validated_gne__c,
						         EDM_Approval_Request_Comment_gne__c
						  From EDM_IABP_gne__c 
			              Where Id = :testIABP.Id Limit 1];
			System.assertEquals('Submitted',testIABP.EDM_Approval_Status_gne__c);
			System.assertEquals('Sent for approval '+ Date.today().format(),testIABP.EDM_Approver_1_Status_gne__c);
			System.assertEquals('Sent for approval '+ Date.today().format(),testIABP.EDM_Approver_2_Status_gne__c);
			System.assertEquals('Sent for approval '+ Date.today().format(),testIABP.EDM_Approver_3_Status_gne__c);
			System.assertEquals('Sent for approval '+ Date.today().format(),testIABP.EDM_Approver_4_Status_gne__c);
			System.assertEquals(null,testIABP.EDM_Approval_Request_Comment_gne__c);
			System.assertEquals(Date.today(),testIABP.EDM_Version_Validated_gne__c);
		}
	}

	public static testMethod void sendForApprovalFiveApproversTest(){
		
		EDM_ABM_Test_Utils.insertIABPConfig();
		User abs = EDM_ABM_Test_Utils.getABSes()[0];

	    System.runAs(abs){
			insert new EDM_Notifications_gne__c(
				Name = 'Default',
				Escalation_Address_gne__c = 'test@gmail.com',
				Test_CC_Address_gne__c = 'test@gmail.com'
			);

			testAABP = new EDM_AABP_gne__c(
				EDM_Plan_Year_gne__c = '2015',
				EDM_Plan_Received_gne__c = Date.today(),
				EDM_Final_Approval_Received_gne__c = Date.today()
			);
			insert testAABP;
			testIABP = new EDM_IABP_gne__c(
				EDM_Parent_AABP_gne__c = testAABP.Id,
				EDM_Executive_Summary_gne__c = false,
				EDM_Type_of_Event_gne__c = 'test event type',
				EDM_IABP_Version_gne__c = 199
			);
			insert testIABP;

			EDM_IABP_Edit_Create_Ex ext = setupPage();
			ext.init();
			Test.startTest();
			List<SelectOption> avApp = ext.getAvailableApprovers();
			ext.selectedApprovers.add(avApp[0]);
			ext.selectedApprovers.add(avApp[1]);
			ext.selectedApprovers.add(avApp[2]);
			ext.selectedApprovers.add(avApp[3]);
			ext.selectedApprovers.add(avApp[4]);

			PageReference pr = ext.sendForApproval();
			Test.stopTest();
			testIABP = [Select EDM_Approval_Status_gne__c,EDM_Approver_1_Status_gne__c,EDM_Approver_2_Status_gne__c,EDM_Approver_3_Status_gne__c,EDM_Approver_4_Status_gne__c,EDM_Approver_5_Status_gne__c,EDM_Version_Validated_gne__c,
			                     EDM_Approval_Request_Comment_gne__c
						  From EDM_IABP_gne__c 
			              Where id = :testIABP.Id];
			System.assertEquals('Submitted',testIABP.EDM_Approval_Status_gne__c);
			System.assertEquals('Sent for approval '+ Date.today().format(),testIABP.EDM_Approver_1_Status_gne__c);
			System.assertEquals('Sent for approval '+ Date.today().format(),testIABP.EDM_Approver_2_Status_gne__c);
			System.assertEquals('Sent for approval '+ Date.today().format(),testIABP.EDM_Approver_3_Status_gne__c);
			System.assertEquals('Sent for approval '+ Date.today().format(),testIABP.EDM_Approver_4_Status_gne__c);
			System.assertEquals('Sent for approval '+ Date.today().format(),testIABP.EDM_Approver_5_Status_gne__c);
			System.assertEquals(null,testIABP.EDM_Approval_Request_Comment_gne__c);
			System.assertEquals(Date.today(),testIABP.EDM_Version_Validated_gne__c);

			System.assertEquals(5,ext.getApproverList().size());
		}
	}

	public static testMethod void downloadDocumentsTest(){

		EDM_ABM_Test_Utils.insertIABPConfig();
		User abs = EDM_ABM_Test_Utils.getABSes()[0];

	    System.runAs(abs){
			testAABP = new EDM_AABP_gne__c(
				EDM_Plan_Year_gne__c = '2015',
				EDM_Plan_Received_gne__c = Date.today(),
				EDM_Final_Approval_Received_gne__c = Date.today()
			);
			insert testAABP;
			testIABP = new EDM_IABP_gne__c(
				EDM_Parent_AABP_gne__c = testAABP.Id,
				EDM_Executive_Summary_gne__c = true,
				EDM_Type_of_Event_gne__c = 'test event type',
				EDM_IABP_Version_gne__c = 199
			);
			insert testIABP;

			EDM_IABP_Edit_Create_Ex ext = setupPage();
			ext.init();
			Test.startTest();
			ext.startDownloadDocuments();
			System.assertEquals(true,ext.downloadDocumentsStarted);

			ext.closeDownloadDocuments();
			Test.stopTest();
			System.assertEquals(false,ext.downloadDocumentsStarted);

			System.assertEquals(2,ext.getDownloadDocumentIds().size());
		}
	}

	public static testMethod void cancelApprovalProcessTest(){

		EDM_ABM_Test_Utils.insertIABPConfig();
		User abs = EDM_ABM_Test_Utils.getABSes()[0];

	    System.runAs(abs){
			insert new EDM_Notifications_gne__c(
				Name = 'Default',
				Escalation_Address_gne__c = 'test@gmail.com',
				Test_CC_Address_gne__c = 'test@gmail.com'
			);

			testAABP = new EDM_AABP_gne__c(
				EDM_Plan_Year_gne__c = '2015',
				EDM_Plan_Received_gne__c = Date.today(),
				EDM_Final_Approval_Received_gne__c = Date.today()
			);
			insert testAABP;
			testIABP = new EDM_IABP_gne__c(
				EDM_Parent_AABP_gne__c = testAABP.Id,
				EDM_Executive_Summary_gne__c = false,
				EDM_Type_of_Event_gne__c = 'test event type',
				EDM_IABP_Version_gne__c = 199
			);
			insert testIABP;

			EDM_IABP_Edit_Create_Ex ext = setupPage();
			ext.init();
			Test.startTest();
			List<SelectOption> avApp = ext.getAvailableApprovers();
			ext.selectedApprovers.add(avApp[0]);
			ext.selectedApprovers.add(avApp[1]);
			ext.selectedApprovers.add(avApp[2]);
			ext.selectedApprovers.add(avApp[3]);
			ext.selectedApprovers.add(avApp[4]);

			PageReference pr = ext.sendForApproval();

			pr = ext.cancelApprovalProcess();
			Test.stopTest();
			testIABP = [Select EDM_Approval_Status_gne__c,EDM_Approver_1_Status_gne__c,EDM_Approver_2_Status_gne__c,EDM_Approver_3_Status_gne__c,EDM_Approver_4_Status_gne__c,EDM_Approver_5_Status_gne__c,EDM_Version_Validated_gne__c,
			                     EDM_Approval_Request_Comment_gne__c
						  From EDM_IABP_gne__c 
			              Where id = :testIABP.Id];
			System.assertEquals('Canceled',testIABP.EDM_Approval_Status_gne__c);
		}
	}
	
	public static testMethod void changeMeetingApproachTest(){

		EDM_ABM_Test_Utils.insertIABPConfig();
		User abs = EDM_ABM_Test_Utils.getABSes()[0];

	    System.runAs(abs){
			insert new EDM_Notifications_gne__c(
				Name = 'Default',
				Escalation_Address_gne__c = 'test@gmail.com',
				Test_CC_Address_gne__c = 'test@gmail.com'
			);

			testAABP = new EDM_AABP_gne__c(
				EDM_Plan_Year_gne__c = '2015',
				EDM_Plan_Received_gne__c = Date.today(),
				EDM_Final_Approval_Received_gne__c = Date.today()
			);
			insert testAABP;
			testIABP = new EDM_IABP_gne__c(
				EDM_Parent_AABP_gne__c = testAABP.Id,
				EDM_Executive_Summary_gne__c = false,
				EDM_Type_of_Event_gne__c = 'test event type',
				EDM_IABP_Version_gne__c = 199,
				EDM_Meeting_Approach_gne__c = 'iAdvise'
			);
			insert testIABP;

			EDM_IABP_Edit_Create_Ex ext = setupPage(testIABP,testAABP);
			ext.init();
			Test.startTest();
			
			EDM_Session_gne__c session = new EDM_Session_gne__c(
				EDM_Parent_IABP_gne__c = testIABP.Id
			);
			insert session;

			Integer sessionsSize = ext.Agenda.size();

			Apexpages.currentPage().getParameters().put('sessionId',session.Id);
			ext.newSession = session;

			ext.addSession();
			ext.changeMeetingApproach();
			Test.stopTest();

			System.assertEquals(null,ext.currentIABP.EDM_Venue_gne__c);
			System.assertEquals(null,ext.currentIABP.EDM_Country_gne__c);
			System.assertEquals(null,ext.currentIABP.EDM_State_gne__c);
			System.assertEquals(null,ext.currentIABP.EDM_City_gne__c);
			System.assertEquals(null,ext.currentIABP.EDM_Meeting_Date_gne__c);
			System.assertEquals(null,ext.currentIABP.EDM_Log_Vendor_Company_Name_gne__c);
			System.assertEquals(null,ext.currentIABP.EDM_Log_Vendor_Contact_Name_gne__c);
			System.assertEquals(null,ext.currentIABP.EDM_Log_Vendor_Contact_Email_gne__c);
		}
	}

	public static testMethod void changeMeetingApproachTest2(){

		EDM_ABM_Test_Utils.insertIABPConfig();
		User abs = EDM_ABM_Test_Utils.getABSes()[0];

	    System.runAs(abs){
	    	testAABP = new EDM_AABP_gne__c(
				EDM_Plan_Year_gne__c = '2015',
				EDM_Plan_Received_gne__c = Date.today(),
				EDM_Final_Approval_Received_gne__c = Date.today()
			);
			insert testAABP;
			testIABP = new EDM_IABP_gne__c(
				EDM_Parent_AABP_gne__c = testAABP.Id,
				EDM_Executive_Summary_gne__c = false,
				EDM_Type_of_Event_gne__c = 'test event type',
				EDM_IABP_Version_gne__c = 199,
				EDM_Meeting_Approach_gne__c = 'Face to Face'
			);
			insert testIABP;

			EDM_IABP_Edit_Create_Ex ext = setupPage(testIABP,testAABP);
			ext.init();
			Test.startTest();
			ext.addQuestion();
			ext.changeMeetingApproach();
			
			System.assertEquals(null,ext.currentIABP.EDM_Meeting_Date_gne__c);
			System.assertEquals(null,ext.currentIABP.EDM_Log_Vendor_Company_Name_gne__c);
			System.assertEquals(null,ext.currentIABP.EDM_Log_Vendor_Contact_Name_gne__c);
			System.assertEquals(null,ext.currentIABP.EDM_Log_Vendor_Contact_Email_gne__c);

			ext.cancelMeetingApproachChange();
			Test.stopTest();

			System.assertEquals('Face to Face',ext.currentIABP.EDM_Meeting_Approach_gne__c);
		}
	}

	public static testMethod void getTotalEstimatedAndActualTest(){
		EDM_ABM_Test_Utils.insertIABPConfig();

		//EDM_ABM_Test_Utils.insertIABPConfig('IABP');
		User abs = EDM_ABM_Test_Utils.getABSes()[0];

	    System.runAs(abs){

	    	Test.startTest();
	    	testAABP = new EDM_AABP_gne__c(
				EDM_Plan_Year_gne__c = '2015',
				EDM_Plan_Received_gne__c = Date.today(),
				EDM_Final_Approval_Received_gne__c = Date.today(),
				EDM_ABS_Manager_gne__c = UserInfo.getUserId()
			);
			insert testAABP;
			testIABP = new EDM_IABP_gne__c(
				EDM_Parent_AABP_gne__c = testAABP.Id,
				EDM_Executive_Summary_gne__c = false,
				EDM_Type_of_Event_gne__c = 'test event type',
				EDM_IABP_Version_gne__c = 199				
			);
			insert testIABP;
			
			List<Account> accounts = new List<Account>();
			accounts.add(new Account(
				Name = 'TestAccount1'
			));
			accounts.add(new Account(
				Name = 'TestAccount2'
			));
			accounts.add(new Account(
				Name = 'TestAccount3'
			));
			insert accounts;
	    	List<EDM_Attendee_gne__c> attds = new List<EDM_Attendee_gne__c>();
			attds.add(new EDM_Attendee_gne__c(
				EDM_Parent_IABP_gne__c = testIABP.Id,
				EDM_Account_gne__c = accounts[0].Id,
				EDM_System_Type_gne__c = EDM_IABP_Utils.AttendeeSystemType.Advisor.Name()
			));
			attds.add(new EDM_Attendee_gne__c(
				EDM_Parent_IABP_gne__c = testIABP.Id,
				EDM_Account_gne__c = accounts[1].Id,
				EDM_System_Type_gne__c = EDM_IABP_Utils.AttendeeSystemType.Genentech.Name()
			));
			attds.add(new EDM_Attendee_gne__c(
				EDM_Parent_IABP_gne__c = testIABP.Id,
				EDM_Account_gne__c = accounts[2].Id,
				EDM_System_Type_gne__c = EDM_IABP_Utils.AttendeeSystemType.Other.Name()
			));
			insert attds;
			update testIABP;
			testIABP = [SELECT Id, EDM_Parent_AABP_gne__c, EDM_Executive_Summary_gne__c, EDM_Type_of_Event_gne__c, EDM_IABP_Version_gne__c, EDM_Actual_Nr_of_Advisors_gne__c, EDM_Actual_Nr_of_Gene_Reps_gne__c,
						RecordTypeId 
						FROM EDM_IABP_gne__c WHERE Id = :testIABP.Id LIMIT 1];
			system.debug(testIABP);
			EDM_IABP_Edit_Create_Ex ext = setupPage(testIABP,testAABP);

			ext.init();
			ext.currentIABP.EDM_Est_nr_of_Attendees_gne__c = 1;
			ext.currentIABP.EDM_Est_nr_of_Gne_Attendees_gne__c = 1;
			ext.currentIABP.EDM_Est_nr_of_Other_Attendees_gne__c = 1;
			Test.stopTest();
			System.debug('ext.currentIABP ' + ext.currentIABP);
			System.assertEquals(3, ext.getTotalEstimated());
			System.assertEquals(3, ext.getTotalActual());
		}
	}

	public static testMethod void testSFA1815_IABPDiscussionTimeGreaterThan10Hours() {
		insertData();
		testIABP.EDM_Total_Discussion_Time_gne__c = '11:59';

		update testIABP;

		List<EDM_IABP_gne__c> results = [SELECT EDM_Total_Discussion_Time_gne__c, EDM_Total_Discussion_Time_Minutes_gne__c FROM EDM_IABP_gne__c WHERE Id = :testIABP.Id];

		System.debug(results[0].EDM_Total_Discussion_Time_gne__c);
		System.assertEquals(11*60 + 59, results[0].EDM_Total_Discussion_Time_Minutes_gne__c);
	}

	public static testMethod void testSFA1815_IABPDiscussionTimeLesserThan10Hours() {
		insertData();
		testIABP.EDM_Total_Discussion_Time_gne__c = '9:01';

		update testIABP;

		List<EDM_IABP_gne__c> results = [SELECT EDM_Total_Discussion_Time_gne__c, EDM_Total_Discussion_Time_Minutes_gne__c FROM EDM_IABP_gne__c WHERE Id = :testIABP.Id];

		System.debug(results[0].EDM_Total_Discussion_Time_gne__c);
		System.assertEquals(9*60 + 1, results[0].EDM_Total_Discussion_Time_Minutes_gne__c);
	}

		public static testMethod void testSFA1815_IABPPresentationTimeGreaterThan10Hours() {
		insertData();
		testIABP.EDM_Total_Presentation_Time_gne__c = '11:59';

		update testIABP;

		List<EDM_IABP_gne__c> results = [SELECT EDM_Total_Presentation_Time_gne__c, EDM_Total_Presentation_Time_Minutes_gne__c FROM EDM_IABP_gne__c WHERE Id = :testIABP.Id];

		System.debug(results[0].EDM_Total_Presentation_Time_gne__c);
		System.assertEquals(11*60 + 59, results[0].EDM_Total_Presentation_Time_Minutes_gne__c);
	}

	public static testMethod void testSFA1815_IABPPresentationTimeLesserThan10Hours() {
		insertData();
		testIABP.EDM_Total_Presentation_Time_gne__c = '9:01';

		update testIABP;

		List<EDM_IABP_gne__c> results = [SELECT EDM_Total_Presentation_Time_gne__c, EDM_Total_Presentation_Time_Minutes_gne__c FROM EDM_IABP_gne__c WHERE Id = :testIABP.Id];

		System.debug(results[0].EDM_Total_Presentation_Time_gne__c);
		System.assertEquals(9*60 + 1, results[0].EDM_Total_Presentation_Time_Minutes_gne__c);
	}

	public static testMethod void checkEventFocusValuesDisplayedOnPage() {		
		EDM_ABM_Test_Utils.insertIABPConfig();

        User abs = EDM_ABM_Test_Utils.getABSes()[0]; //Eduardo
        System.assert(abs != null);
        System.debug('$$ User: ' + abs);
        System.runAs(abs) {

        	EDM_IABP_Edit_Create_Ex controller = setupPage();
			Set<String> eventFocusLabelsSet = new Set<String>();
			for(SelectOption eventFocus : controller.getEventFocus()) {
				eventFocusLabelsSet.add(eventFocus.getLabel());
			}

			System.assertEquals(false, eventFocusLabelsSet.contains('--None--'));

        }
	}
}