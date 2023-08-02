@isTest
private class EDM_AABP_Layout_Ext_Test{

	public static testMethod void currentAABPNotFinalizedTest(){

		EDM_AABP_gne__c testAABP = new EDM_AABP_gne__c(
			EDM_Plan_Year_gne__c = '2015',
			EDM_Plan_Received_gne__c = Date.today(),
			EDM_Final_Approval_Received_gne__c = Date.today()
		);
		insert testAABP;

		ApexPages.StandardController sc = new ApexPages.StandardController(testAABP);

		EDM_AABP_Layout_Ext ext = new EDM_AABP_Layout_Ext(sc);

		PageReference pr = ext.initOverride();

		System.assertEquals('/apex/edm_aabp_edit_create?id='+testAABP.Id+'&retURL=%2Fapex%2FEDM_AABP_List_View',pr.getUrl());
	}

	public static testMethod void addEventTest(){

		EDM_AABP_gne__c testAABP = new EDM_AABP_gne__c(
			EDM_Plan_Year_gne__c = '2015',
			EDM_Plan_Received_gne__c = Date.today(),
			EDM_Final_Approval_Received_gne__c = Date.today(),
			EDM_ABS_Manager_gne__c = EDM_ABM_Test_Utils.getABSes()[0].Id
		);
		insert testAABP;

		ApexPages.StandardController sc = new ApexPages.StandardController(testAABP);

		EDM_AABP_Layout_Ext ext = new EDM_AABP_Layout_Ext(sc);

		ext.newEvent.EDM_Type_of_Event_gne__c = 'Test event type';

		ext.addEvent();

		List<EDM_IABP_gne__c> IABPs = [Select Id From EDM_IABP_gne__c Where EDM_Parent_AABP_gne__c = :testAABP.Id];
		System.assertEquals(1,IABPs.size());
	}

	public static testMethod void cancelEventTest(){

		EDM_AABP_gne__c testAABP = new EDM_AABP_gne__c(
			EDM_Plan_Year_gne__c = '2015',
			EDM_Plan_Received_gne__c = Date.today(),
			EDM_Final_Approval_Received_gne__c = Date.today(),
			EDM_ABS_Manager_gne__c = EDM_ABM_Test_Utils.getABSes()[0].Id
		);
		insert testAABP;

		EDM_IABP_gne__c testIABP = new EDM_IABP_gne__c(
			EDM_Parent_AABP_gne__c = testAABP.Id,
			EDM_Executive_Summary_gne__c = false,
			EDM_Type_of_Event_gne__c = 'test event type',
			EDM_IABP_Version_gne__c = 199
		);
		insert testIABP;

		ApexPages.StandardController sc = new ApexPages.StandardController(testAABP);

		EDM_AABP_Layout_Ext ext = new EDM_AABP_Layout_Ext(sc);

		ext.newEvent.EDM_Type_of_Event_gne__c = 'Test event type';
		ext.addEvent();

		List<EDM_IABP_gne__c> IABPs = [Select Id From EDM_IABP_gne__c Where EDM_Parent_AABP_gne__c = :testAABP.Id];
		System.assertEquals(2,IABPs.size());

		ext.CancelId = testIABP.Id;
		PageReference pr = ext.cancelEvent();
		System.assertEquals(null, pr);

		IABPs = [Select Id From EDM_IABP_gne__c Where EDM_Parent_AABP_gne__c = :testAABP.Id And EDM_Canceled_gne__c = true];
		System.assertEquals(1,IABPs.size());
	}

	public static testMethod void deleteAabpTest(){

		EDM_AABP_gne__c testAABP = new EDM_AABP_gne__c(
			EDM_Plan_Year_gne__c = '2015',
			EDM_Plan_Received_gne__c = Date.today(),
			EDM_Final_Approval_Received_gne__c = Date.today(),
			EDM_ABS_Manager_gne__c = EDM_ABM_Test_Utils.getABSes()[0].Id
		);
		insert testAABP;

		ApexPages.StandardController sc = new ApexPages.StandardController(testAABP);

		EDM_AABP_Layout_Ext ext = new EDM_AABP_Layout_Ext(sc);

		ext.newEvent.EDM_Type_of_Event_gne__c = 'Test event type';
		PageReference pr = ext.deleteAabp();

		List<EDM_AABP_gne__c> AABPs = [Select Id From EDM_AABP_gne__c Where Id = :testAABP.Id];
		System.assertEquals(0, AABPs.size());
		System.assertNotEquals(null, pr);
	}

	public static testMethod void deleteEventTest(){

		EDM_AABP_gne__c testAABP = new EDM_AABP_gne__c(
			EDM_Plan_Year_gne__c = '2018',
			EDM_Plan_Received_gne__c = Date.today(),
			EDM_Final_Approval_Received_gne__c = Date.today(),
			EDM_ABS_Manager_gne__c = EDM_ABM_Test_Utils.getABSes()[0].Id
		);
		insert testAABP;

		EDM_IABP_gne__c testIABP = new EDM_IABP_gne__c(
			EDM_Parent_AABP_gne__c = testAABP.Id,
			EDM_Executive_Summary_gne__c = false,
			EDM_Type_of_Event_gne__c = 'Other',
			EDM_IABP_Version_gne__c = 199
		);
		insert testIABP;

		EDM_IABP_gne__c testExeSum = new EDM_IABP_gne__c(
			EDM_Parent_AABP_gne__c = testAABP.Id,
			EDM_Parent_IABP_gne__c = testIABP.Id,
			EDM_Executive_Summary_gne__c = true,
			EDM_Type_of_Event_gne__c = 'Other',
			EDM_IABP_Version_gne__c = 200
		);
		insert testExeSum;

		EDM_IABP_gne__c testSecondIABP = new EDM_IABP_gne__c(
			EDM_Parent_AABP_gne__c = testAABP.Id,
			EDM_Executive_Summary_gne__c = false,
			EDM_Type_of_Event_gne__c = 'Other',
			EDM_IABP_Version_gne__c = 199
		);
		insert testSecondIABP;

		EDM_Recently_Chosen_IABP_gne__c recentlyChosenIABP = new EDM_Recently_Chosen_IABP_gne__c(
												EDM_IABP_gne__c = testIABP.Id, 
												EDM_User_gne__c = UserInfo.getUserId()
											);
		insert recentlyChosenIABP;

		ApexPages.StandardController sc = new ApexPages.StandardController(testAABP);

		EDM_AABP_Layout_Ext ext = new EDM_AABP_Layout_Ext(sc);
		
		ext.newEvent.EDM_Type_of_Event_gne__c = 'Test event type';
		
		ext.EventId = testIABP.Id;
		PageReference pr = ext.deleteEvent();

		List<EDM_Recently_Chosen_IABP_gne__c> recentlyChosenIABPs = [SELECT Id FROM EDM_Recently_Chosen_IABP_gne__c WHERE EDM_IABP_gne__c =: testIABP.Id];
		List<EDM_IABP_gne__c> IABPs = [SELECT Id FROM EDM_IABP_gne__c WHERE Id =:testIABP.Id OR EDM_Parent_IABP_gne__c =: testIABP.Id];
		System.assertEquals(0, IABPs.size());
		System.assertEquals(1, ext.TotalMeetings);
		System.assertEquals(0, recentlyChosenIABPs.size());
		System.assertEquals(null, pr);
	}

	public static testMethod void removeAttachmentTest(){

		EDM_AABP_gne__c testAABP = new EDM_AABP_gne__c(
			EDM_Plan_Year_gne__c = '2015',
			EDM_Plan_Received_gne__c = Date.today(),
			EDM_Final_Approval_Received_gne__c = Date.today()
		);
		insert testAABP;

		EDM_Attachment_gne__c a = new EDM_Attachment_gne__c(
			EDM_Parent_AABP_gne__c = testAABP.Id
		);
		insert a;

		ApexPages.StandardController sc = new ApexPages.StandardController(testAABP);

		EDM_AABP_Layout_Ext ext = new EDM_AABP_Layout_Ext(sc);

		ext.attachments.add(a);
		ext.attachToDel = a.Id;

		PageReference pr = ext.removeAttachment();
		System.assertEquals(null,pr);
		System.assertEquals(0,[Select Id From EDM_Attachment_gne__c Where EDM_Parent_AABP_gne__c = :testAABP.Id].size());
	}

	public static testMethod void removeAttachmentExceptionTest(){

		EDM_AABP_gne__c testAABP = new EDM_AABP_gne__c(
			EDM_Plan_Year_gne__c = '2015',
			EDM_Plan_Received_gne__c = Date.today(),
			EDM_Final_Approval_Received_gne__c = Date.today()
		);
		insert testAABP;

		ApexPages.StandardController sc = new ApexPages.StandardController(testAABP);

		EDM_AABP_Layout_Ext ext = new EDM_AABP_Layout_Ext(sc);

		ext.attachToDel = 'WrongId';
		PageReference pr = ext.removeAttachment();

		List<ApexPages.Message> msgs = ApexPages.getMessages();
		System.assert(msgs[0].getDetail().contains('Could not delete Attachment!'));
	}

	public static testMethod void attachmentCountTest(){

		EDM_AABP_gne__c testAABP = new EDM_AABP_gne__c(
			EDM_Plan_Year_gne__c = '2015',
			EDM_Plan_Received_gne__c = Date.today(),
			EDM_Final_Approval_Received_gne__c = Date.today()
		);
		insert testAABP;

		EDM_Attachment_gne__c a = new EDM_Attachment_gne__c(
			EDM_Parent_AABP_gne__c = testAABP.Id
		);
		insert a;

		System.assertEquals(1,EDM_AABP_Layout_Ext.getAttachmentCount(testAABP.Id));
	}

	public static testMethod void goBackWithoutRetUrlTest(){

		EDM_AABP_gne__c testAABP = new EDM_AABP_gne__c(
			EDM_Plan_Year_gne__c = '2015',
			EDM_Plan_Received_gne__c = Date.today(),
			EDM_Final_Approval_Received_gne__c = Date.today()
		);
		insert testAABP;

		ApexPages.StandardController sc = new ApexPages.StandardController(testAABP);

		EDM_AABP_Layout_Ext ext = new EDM_AABP_Layout_Ext(sc);

		PageReference pr = ext.goBack();

		System.assertEquals('/apex/EDM_AABP_List_View',pr.getUrl());
	}

	public static testMethod void goBackWithRetUrlTest(){

		EDM_AABP_gne__c testAABP = new EDM_AABP_gne__c(
			EDM_Plan_Year_gne__c = '2015',
			EDM_Plan_Received_gne__c = Date.today(),
			EDM_Final_Approval_Received_gne__c = Date.today()
		);
		insert testAABP;

		ApexPages.currentPage().getParameters().put('retURL','www.google.com');
		ApexPages.StandardController sc = new ApexPages.StandardController(testAABP);

		EDM_AABP_Layout_Ext ext = new EDM_AABP_Layout_Ext(sc);

		PageReference pr = ext.goBack();

		System.assertEquals('www.google.com',pr.getUrl());
	}

	public static testMethod void shareAABPTest(){

		List<PermissionSet> ps = [Select id,UserLicenseId From PermissionSet Where Name in (:EDM_ABM_Utils.ABS)];
		Profile p_AB_Man = [Select Id From Profile Where Name = 'GNE-TLS-Manager'];
		User u = new User(
			FirstName = 'Manager',
			ProfileId = p_AB_Man.Id,
			Username = 'b@roche.com',
			LastName = 'Test',
			Email = 'b@roche.com',
			TimeZoneSidKey = 'America/Los_Angeles',
			LocaleSidKey = 'en_US',
			EmailEncodingKey = 'ISO-8859-1',
			LanguageLocaleKey = 'en_US'
		);
		insert u;

		User userToShareWith = new User(
			FirstName = 'testUser',
			ProfileId = p_AB_Man.Id,
			Username = 'c@roche.com',
			LastName = 'Test',
			Email = 'c@roche.com',
			TimeZoneSidKey = 'America/Los_Angeles',
			LocaleSidKey = 'en_US',
			EmailEncodingKey = 'ISO-8859-1',
			LanguageLocaleKey = 'en_US'
		);
		insert userToShareWith;

		List<PermissionSetAssignment> psa = new List<PermissionSetAssignment>();

		psa.add(new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps[0].Id));
		insert psa;

		Integer usersCount = [SELECT Id, AssigneeId FROM PermissionSetAssignment
                              WHERE PermissionSetId IN (SELECT Id FROM PermissionSet WHERE Name in (:EDM_ABM_Utils.ABS)) 
                              AND AssigneeId IN (SELECT Id FROM User WHERE Profile_Name_gne__c LIKE 'GNE%' AND isActive = true)].size();

        System.runAs(u){

			insert new EDM_Notifications_gne__c(
				Name = 'Default',
				Escalation_Address_gne__c = 'test@gmail.com',
				Test_CC_Address_gne__c = 'test@gmail.com'
			);
        	EDM_AABP_gne__c testAABP = new EDM_AABP_gne__c(
				EDM_Plan_Year_gne__c = '2015',
				EDM_Plan_Received_gne__c = Date.today(),
				EDM_Final_Approval_Received_gne__c = Date.today()
			);
			insert testAABP;

			ApexPages.StandardController sc = new ApexPages.StandardController(testAABP);

			EDM_AABP_Layout_Ext ext = new EDM_AABP_Layout_Ext(sc);

			System.assertEquals(true,ext.getIsAbsUser(),ext.UserRole);

			ext.UsersSharedWith.Add(new SelectOption(userToShareWith.Id,userToShareWith.FirstName));

			ext.currentAABP.EDM_Share_Comment_gne__c = 'testShareComment';
			PageReference pr = ext.shareAABP();
			System.assertEquals(null, pr);

			System.assertEquals(usersCount,ext.getABSManagers().size());
		}

	}

	public static testMethod void abPlannerTest(){

		Integer usersCount = [SELECT Id, AssigneeId FROM PermissionSetAssignment
                              WHERE PermissionSetId IN (SELECT Id FROM PermissionSet WHERE Name in (:EDM_ABM_Utils.ABLEAD,:EDM_ABM_Utils.VDST_ABM))].size();

		List<PermissionSet> ps = [Select id,UserLicenseId From PermissionSet Where Name in (:EDM_ABM_Utils.ABLEAD)];
		Profile p_SBL = [Select Id From Profile Where Name = 'GNE-TLS-SpeakerBureauLead'];
		User u2 = new User(
			FirstName = 'VDST_ABM',
			ProfileId = p_SBL.Id,
			Username = 'b@roche.com',
			LastName = 'Test',
			Email = 'b@roche.com',
			TimeZoneSidKey = 'America/Los_Angeles',
			LocaleSidKey = 'en_US',
			EmailEncodingKey = 'ISO-8859-1',
			LanguageLocaleKey = 'en_US'
		);
		insert u2;

		List<PermissionSetAssignment> psa = new List<PermissionSetAssignment>();
		psa.add(new PermissionSetAssignment(AssigneeId = u2.Id, PermissionSetId = ps[0].Id));
		insert psa;

		System.runAs(u2){

			EDM_AABP_gne__c testAABP = new EDM_AABP_gne__c(
				EDM_Plan_Year_gne__c = '2015',
				EDM_Plan_Received_gne__c = Date.today(),
				EDM_Final_Approval_Received_gne__c = Date.today()
			);
			insert testAABP;

        	ApexPages.StandardController sc = new ApexPages.StandardController(testAABP);

			EDM_AABP_Layout_Ext ext = new EDM_AABP_Layout_Ext(sc);

			System.assert(ext.getIsABPlanner());
        }
	}

	public static testMethod void ablsTest(){
		List<PermissionSet> ps = [SELECT Id, Name FROM PermissionSet WHERE Name in (:EDM_ABM_Utils.ABLEAD,:EDM_ABM_Utils.VDST_ABM)];
		Integer usersCount = [SELECT Id, AssigneeId, Assignee.isActive FROM PermissionSetAssignment
                              WHERE Assignee.isActive = true AND PermissionSetId IN :ps].size();

        Id ablId;
        for(PermissionSet permSet :ps){
        	if(permSet.Name.equalsIgnoreCase(EDM_ABM_Utils.ABLEAD)){
        		ablID = permSet.Id;
        	}
        }
		Profile p_SBL = [Select Id From Profile Where Name = 'GNE-TLS-SpeakerBureauLead'];
		User u2 = new User(
			FirstName = 'ABLEAD',
			ProfileId = p_SBL.Id,
			Username = 'a@roche.com',
			LastName = 'Test',
			Email = 'a@roche.com',
			TimeZoneSidKey = 'America/Los_Angeles',
			LocaleSidKey = 'en_US',
			EmailEncodingKey = 'ISO-8859-1',
			LanguageLocaleKey = 'en_US'
		);
		insert u2;
		User u = new User(
			FirstName = 'User',
			ProfileId = p_SBL.Id,
			Username = 'b@roche.com',
			LastName = 'Test',
			Email = 'b@roche.com',
			TimeZoneSidKey = 'America/Los_Angeles',
			LocaleSidKey = 'en_US',
			EmailEncodingKey = 'ISO-8859-1',
			LanguageLocaleKey = 'en_US'
		);
		insert u;

		List<PermissionSetAssignment> psa = new List<PermissionSetAssignment>();
		psa.add(new PermissionSetAssignment(AssigneeId = u2.Id, PermissionSetId = ablID));
		psa.add(new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ablID));
		insert psa;

		System.runAs(u){
			EDM_AABP_gne__c testAABP = new EDM_AABP_gne__c(
				EDM_Plan_Year_gne__c = '2015',
				EDM_Plan_Received_gne__c = Date.today(),
				EDM_Final_Approval_Received_gne__c = Date.today()
			);
			insert testAABP;
	       	ApexPages.StandardController sc = new ApexPages.StandardController(testAABP);
			EDM_AABP_Layout_Ext ext = new EDM_AABP_Layout_Ext(sc);
			System.assertEquals(ext.getVendorLeads(),ext.getABLeads());
			System.assertEquals(usersCount+2,ext.getABLeads().size());
		}
	}

	public static testMethod void shouldChangeABSManager() {
		//given
		User abs1 = EDM_ABM_Test_Utils.getABSes()[0];
		User abs2 = EDM_ABM_Test_Utils.getABSes()[1];

		EDM_AABP_gne__c testAABP = new EDM_AABP_gne__c(
			EDM_Plan_Year_gne__c = '2015',
			EDM_Plan_Received_gne__c = Date.today(),
			EDM_Final_Approval_Received_gne__c = Date.today(),
			EDM_ABS_Manager_gne__c = abs1.Id
		);
		insert testAABP;

		//when
		ApexPages.StandardController sc = new ApexPages.StandardController(testAABP);
		EDM_AABP_Layout_Ext ext = new EDM_AABP_Layout_Ext(sc);
		EDM_AABP_gne__c aabp = (EDM_AABP_gne__c)sc.getRecord();
		aabp.EDM_ABS_Manager_gne__c = abs2.Id;
		PageReference pr = ext.updatemanagers();

		//then
		EDM_AABP_gne__c updatedAABP = [SELECT Id, EDM_ABS_Manager_gne__c FROM EDM_AABP_gne__c LIMIT 1];
		System.assertEquals(updatedAABP.EDM_ABS_Manager_gne__c, abs2.Id);
	}

	public static testMethod void cancelReasonsTest(){

		EDM_AABP_gne__c testAABP = new EDM_AABP_gne__c(
			EDM_Plan_Year_gne__c = '2015',
			EDM_Plan_Received_gne__c = Date.today(),
			EDM_Final_Approval_Received_gne__c = Date.today()
		);
		insert testAABP;

        ApexPages.StandardController sc = new ApexPages.StandardController(testAABP);

		EDM_AABP_Layout_Ext ext = new EDM_AABP_Layout_Ext(sc);

		List<SelectOption> cr = ext.getCancelReasons();

		System.assertEquals(5,cr.size(),cr);
		System.assertEquals('--None--',cr[0].getLabel());
		System.assertEquals('Combined with another event',cr[1].getLabel());
		System.assertEquals('Lack of funding/resources/time',cr[2].getLabel());
		System.assertEquals('Change in overall business strategy',cr[3].getLabel());
		System.assertEquals('Other',cr[4].getLabel());
	}

	public static testMethod void eventFocusesTest(){

		EDM_AABP_gne__c testAABP = new EDM_AABP_gne__c(
			EDM_Plan_Year_gne__c = '2015',
			EDM_Plan_Received_gne__c = Date.today(),
			EDM_Final_Approval_Received_gne__c = Date.today()
		);
		insert testAABP;

        ApexPages.StandardController sc = new ApexPages.StandardController(testAABP);
		EDM_AABP_Layout_Ext ext = new EDM_AABP_Layout_Ext(sc);
		List<SelectOption> ef = ext.getEventFocusPicklist();
		System.assertEquals('--None--',ef[0].getLabel());
	}

	public static testMethod void addEventTestShouldGenerateTitleWith11(){

		EDM_AABP_gne__c testAABP = new EDM_AABP_gne__c(
			EDM_Plan_Year_gne__c = '2015',
			EDM_Plan_Received_gne__c = Date.today(),
			EDM_Final_Approval_Received_gne__c = Date.today(),
			EDM_ABS_Manager_gne__c = EDM_ABM_Test_Utils.getABSes()[0].Id,
			EDM_Group_gne__c = 'Test Group',
			EDM_Unit_gne__c = 'Test Unit',
			EDM_Team_gne__c = 'Test Team'
		);
		insert testAABP;

		List<EDM_IABP_gne__c> testIABPs = new List<EDM_IABP_gne__c>();
		for (Integer i : new Set<Integer> {1, 5, 4, 6, 2, 3}) {
			String eventName = '(Ad Hoc) 2015 Test Group Test Unit Test Team Test event type';
			if  (i > 1) {
				eventName += '#' + i;
			}
			EDM_IABP_gne__c testIABP = new EDM_IABP_gne__c(
				EDM_Parent_AABP_gne__c = testAABP.Id,
				EDM_Executive_Summary_gne__c = false,
				EDM_Type_of_Event_gne__c = 'test event type',
				EDM_Event_Name_gne__c = eventName,
				EDM_IABP_Version_gne__c = 199
			);
			testIABPs.add(testIABP);
		}
		insert testIABPs;

		ApexPages.StandardController sc = new ApexPages.StandardController(testAABP);
		EDM_AABP_Layout_Ext ext = new EDM_AABP_Layout_Ext(sc);

		Test.startTest();
		for (Integer i = 1; i <= 5; i++) {
			ext.newEvent.EDM_Type_of_Event_gne__c = 'Test event type';
			ext.addEvent();
		}
		Test.stopTest();

		List<EDM_IABP_gne__c> IABPs = [Select Id, EDM_Event_Name_gne__c From EDM_IABP_gne__c Where EDM_Parent_AABP_gne__c = :testAABP.Id];
		System.assertEquals(11, IABPs.size());
		//only check title of iabps added by addEvent
		for (Integer i = 7; i <= 11; i++) {
			System.assertEquals('(Ad Hoc) 2015 Test Group Test Unit Test Team Test event type #' + i, IABPs.get(i - 1).EDM_Event_Name_gne__c);
		}
	}
}