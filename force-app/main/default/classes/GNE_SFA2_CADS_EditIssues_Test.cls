/************************************************************
*  @author: Piotr Przesmycki
*  Date: 2014-09-03
*  Description: This is a test class for GNE_SFA2_CADS_EditIssues class
*    
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
@isTest
private class GNE_SFA2_CADS_EditIssues_Test {
	
	public static testMethod void testConstructorForCreate() {
		List<Group> groups = getGroups();
		system.assertEquals(5, groups.size());
		User u = getSFA2UserFromGroups(groups, true);
		system.runAs(u){
			CADS_Account_Address_Issues_gne__c cadsAAI = GNE_SFA2_Triggers_Test_Util.prepareCADS_Account_Address_Issues_gne();
			GNE_SFA2_CADS_EditIssues cadsCtrl = new GNE_SFA2_CADS_EditIssues(new ApexPages.StandardController(cadsAAI));
			system.assertEquals(0, cadsCtrl.hcpActual);
			String prefix = GNE_SFA2_CADS_EditIssues.getKeyPrefix();
			system.assert(prefix.startsWith('/'));
			system.equals(4, prefix.length());
			system.assertEquals(false, cadsCtrl.isSalesTeam);
			system.assert(cadsCtrl.showList().getUrl().contains(prefix));
			system.assertEquals('',cadsCtrl.BO_URL);
			system.assert(cadsCtrl.GetHost.startsWith('https://'));
		}
	}

	public static testMethod void testConstructorForEditFlowA(){
		List<Group> groups = getGroups();
		system.assertEquals(5, groups.size());
		User u = getSFA2UserFromGroups(groups, false);
		system.runAs(u){
			PageReference pr = Page.CADS_Account_Address_Issues;
			pr.getParameters().put('msg','Sample message');
			Test.setCurrentPage(pr);
			CADS_Account_Address_Issues_gne__c cadsAAI = GNE_SFA2_Triggers_Test_Util.prepareCADS_Account_Address_Issues_gne();
			cadsAAI.Has_Spend_ETL_populate_gne__c = 'Yes';
			cadsAAI.Processing_STS_gne__c = 'Submitted';
			insert cadsAAI;
			List<Stewardship_Issue_Action_History_gne__c> siahs = new List<Stewardship_Issue_Action_History_gne__c>();
			siahs.add(new Stewardship_Issue_Action_History_gne__c(Issue_Id_gne__c = cadsAAI.Id));
			siahs.add(new Stewardship_Issue_Action_History_gne__c(Issue_Id_gne__c = cadsAAI.Id));
			insert siahs;
			GNE_SFA2_CADS_EditIssues cadsCtrl = new GNE_SFA2_CADS_EditIssues(new ApexPages.StandardController(cadsAAI));
			system.assertEquals(0, cadsCtrl.hcpActual);
			system.assertEquals(true, cadsCtrl.isSalesTeam);
			system.assertEquals(cadsAAI.Id, cadsCtrl.getIssue().Id);
			system.assertEquals(cadsAAI.Id, cadsCtrl.getEditIssue().Id);

			system.assertEquals(true, cadsCtrl.getShowHistoryBtn());
			system.assertEquals(false, cadsCtrl.getShowEditBtn());
			system.assertEquals(true, cadsCtrl.getHideMsg());
			system.assertEquals(false, cadsCtrl.getShowSubmitBtn());
			system.assertEquals(true, cadsCtrl.getSalesTeam());
			system.assertEquals(null, cadsCtrl.getMode());
			system.assertEquals(null, cadsCtrl.getTab());
			system.assertEquals(true, cadsCtrl.getShowTransactionHistoryBtn());
		}
	}

	public static testMethod void testConstructorForEditFlowB(){
		List<Group> groups = getGroups();
		system.assertEquals(5, groups.size());
		User u = getSFA2UserFromGroups(groups, true);
		system.runAs(u){
			PageReference pr = Page.CADS_Account_Address_Issues;
			pr.getParameters().put('mode', 'reopen');
			pr.getParameters().put('msg', 'submit');
			Test.setCurrentPage(pr);
			CADS_Account_Address_Issues_gne__c cadsAAI = GNE_SFA2_Triggers_Test_Util.prepareCADS_Account_Address_Issues_gne();
			cadsAAI.Has_Spend_ETL_populate_gne__c = 'Yes';
			cadsAAI.Processing_STS_gne__c = 'Submitted';
			insert cadsAAI;
			GNE_SFA2_CADS_EditIssues cadsCtrl = new GNE_SFA2_CADS_EditIssues(new ApexPages.StandardController(cadsAAI));
			system.assertEquals(0, cadsCtrl.hcpActual);
			system.assertEquals(false, cadsCtrl.isSalesTeam);

			system.assertEquals(false, cadsCtrl.getShowHistoryBtn());
			system.assertEquals(false, cadsCtrl.getShowEditBtn());
			system.assertEquals(false, cadsCtrl.getHideMsg());
			system.assertEquals(true, cadsCtrl.getShowSubmitBtn());
			system.assertEquals(false, cadsCtrl.getSalesTeam());
			system.assertEquals('reopen', cadsCtrl.getMode());
			system.assertEquals(null, cadsCtrl.getTab());
			system.assertEquals(true, cadsCtrl.getShowTransactionHistoryBtn());

		}
	}

	public static testMethod void testConstructorForEditFlowC(){
		List<Group> groups = getGroups();
		system.assertEquals(5, groups.size());
		User u = getSFA2UserFromGroups(groups, false);
		system.runAs(u){
			PageReference pr = Page.CADS_Account_Address_Issues;
			pr.getParameters().put('mode','reopen');
			pr.getParameters().put('tab','tab');
			Test.setCurrentPage(pr);
			CADS_Account_Address_Issues_gne__c cadsAAI = GNE_SFA2_Triggers_Test_Util.prepareCADS_Account_Address_Issues_gne();
			insert cadsAAI;
			GNE_SFA2_CADS_EditIssues cadsCtrl = new GNE_SFA2_CADS_EditIssues(new ApexPages.StandardController(cadsAAI));
			system.assertEquals(0, cadsCtrl.hcpActual);
			system.assertEquals(true, cadsCtrl.isSalesTeam);

			system.assertEquals(false, cadsCtrl.getShowHistoryBtn());
			system.assertEquals(false, cadsCtrl.getShowEditBtn());
			system.assertEquals(true, cadsCtrl.getHideMsg());
			system.assertEquals(false, cadsCtrl.getShowSubmitBtn());
			system.assertEquals(true, cadsCtrl.getSalesTeam());
			system.assertEquals('reopen', cadsCtrl.getMode());
			system.assertEquals('tab', cadsCtrl.getTab());
			system.assertEquals(false, cadsCtrl.getShowTransactionHistoryBtn());
		}
	}

	public static testMethod void testPageReferences(){
		List<Group> groups = getGroups();
		system.assertEquals(5, groups.size());
		User u = getSFA2UserFromGroups(groups, false);
		String tab = 'testTabParamVal';
		system.runAs(u){
			PageReference currentPage = Page.CADS_Account_Address_Issues;
			currentPage.getParameters().put('tab',tab);
			Test.setCurrentPage(currentPage);
			CADS_Account_Address_Issues_gne__c cadsAAI = GNE_SFA2_Triggers_Test_Util.prepareCADS_Account_Address_Issues_gne();
			insert cadsAAI;
			GNE_SFA2_CADS_EditIssues cadsCtrl = new GNE_SFA2_CADS_EditIssues(new ApexPages.StandardController(cadsAAI));
			system.assertEquals(true, cadsCtrl.isSalesTeam);

			system.assertEquals(6, cadsCtrl.getRadioItems().size());
			cadsCtrl.setRadioItemValue('testValue');//this actualy does nothing
			system.assertEquals(null, cadsCtrl.getRadioItemValue());
			system.assertEquals(9, cadsCtrl.getUnitTypes().size());
			List<SelectOption> states = cadsCtrl.getStates();
			system.assertEquals('', states[0].getValue());
			system.assertEquals('-None-', states[0].getLabel());
			system.assert(states.size()>=1);
			cadsCtrl.acName = 'test';
			system.assertEquals('test',cadsCtrl.acName);
			cadsCtrl.acLastName = 'test';
			system.assertEquals('test',cadsCtrl.acLastName);
			cadsCtrl.acEmail = 'test';
			system.assertEquals('test',cadsCtrl.acEmail);
			cadsCtrl.acCellPhone = 'test';
			system.assertEquals('test',cadsCtrl.acCellPhone);
			cadsCtrl.acMiddleName = 'test';
			system.assertEquals('test',cadsCtrl.acMiddleName);
			cadsCtrl.acOrganization = 'test';
			system.assertEquals('test',cadsCtrl.acOrganization);
      		cadsCtrl.adAddress = 'test';
			system.assertEquals('test',cadsCtrl.adAddress);
			cadsCtrl.adUnitNumber = 'test';
			system.assertEquals('test',cadsCtrl.adUnitNumber);
			cadsCtrl.adCity = 'test';
			system.assertEquals('test',cadsCtrl.adCity);
			cadsCtrl.adState = 'test';
			system.assertEquals('test',cadsCtrl.adState);
			cadsCtrl.adPostalCode = 'test';
			system.assertEquals('test',cadsCtrl.adPostalCode);
			cadsCtrl.adCountry = 'test';
			system.assertEquals('test',cadsCtrl.adCountry);
			Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('lastName');
			insert acc;
			Address_vod__c addr = GNE_SFA2_Triggers_Test_Util.prepareAddress_vod(acc.Id, 'address', true, 'addressName');
			insert addr;
			cadsCtrl.SAddAddrId = addr.Id;
			cadsCtrl.qetHcpDetails();

			PageReference pr = cadsCtrl.reopenIssue();
			system.assertEquals(true, pr.getRedirect());
			system.assertEquals(cadsAAI.Id, pr.getParameters().get('id'));
			system.assertEquals('reopen', pr.getParameters().get('mode'));
			system.assertEquals(tab, pr.getParameters().get('tab'));
			system.assert(pr.getUrl().contains('GNE_SFA2_CADS_Issue_Edit_Layout'), 'Wrong URL: ' + pr.getUrl());

			pr = cadsCtrl.edit();
			system.assertEquals(true, pr.getRedirect());
			system.assertEquals(cadsAAI.Id, pr.getParameters().get('id'));
			system.assertEquals(tab, pr.getParameters().get('tab'));
			system.assert(pr.getUrl().contains('GNE_SFA2_CADS_Issue_Edit_Layout'), 'Wrong URL: ' + pr.getUrl());

			pr = cadsCtrl.cancel();
			system.assertEquals(true, pr.getRedirect());
			system.assert(pr.getUrl().contains(Page.GNE_SFA2_CADS_My_Issues.getUrl()), 'Wrong URL: ' + pr.getUrl());

			pr = cadsCtrl.back();
			system.assertEquals(true, pr.getRedirect());
			system.assert(pr.getUrl().contains(Page.GNE_SFA2_CADS_My_Issues.getUrl()), 'Wrong URL: ' + pr.getUrl());
		}
	}

	public static testMethod void testSubmitIssue(){
		List<Group> groups = getGroups();
		system.assertEquals(5, groups.size());
		User u = getSFA2UserFromGroups(groups, false);
		system.runAs(u){
			List<All_User_Hierarchy_gne__c> allUH = new List<All_User_Hierarchy_gne__c>(); 
			allUH.add(new All_User_Hierarchy_gne__c(User_External_Id_gne__c = u.External_ID_gne__c, Active_gne__c = true, FirstName_gne__c = 'test', LastName_gne__c = 'tester'));
			allUH.add(new All_User_Hierarchy_gne__c(User_External_Id_gne__c = 'dstwd', Active_gne__c = true, FirstName_gne__c = 'data', LastName_gne__c = 'tester'));
			insert allUH;
			Infrequent_interaction_enabled_profiles__c infIntEP = new Infrequent_interaction_enabled_profiles__c(Name = 'test', Infrequent_enabled_profile__c = u.Profile.Name, Infrequent_interaction_enabled__c = true);
			insert infIntEP;
			CADS_User_Exception_List_gne__c cadsUExc = new CADS_User_Exception_List_gne__c(Name = 'test', User_External_ID_gne__c = u.External_ID_gne__c);
			insert cadsUExc;

			CADS_Account_Address_Issues_gne__c cadsAAI = GNE_SFA2_Triggers_Test_Util.prepareCADS_Account_Address_Issues_gne();
			//cadsAAI.Next_Action_Owner_gne__c = allUH[0].Id;
			cadsAAI.SFDC_USERID_gne__c = u.External_ID_gne__c;
			insert cadsAAI;

			GNE_SFA2_CADS_EditIssues cadsCtrl = new GNE_SFA2_CADS_EditIssues(new ApexPages.StandardController(cadsAAI));
			system.debug('Issue details: ' + cadsCtrl.getIssue());
			system.debug('Edit Issue details: ' + cadsCtrl.getEditIssue());
			system.debug('all user hierarchy: ' + [select User_External_Id_gne__c, Active_gne__c,email_id__c from All_User_Hierarchy_gne__c Where Id = :cadsCtrl.getEditIssue().Next_Action_Owner_gne__c limit 1]);

			PageReference pr = cadsCtrl.submitIssue();
			system.assertEquals(true, pr.getRedirect());
			system.assert(pr.getUrl().contains(Page.GNE_SFA2_CADS_My_Issues.getUrl()), 'Wrong URL: ' + pr.getUrl());
		}
	}

	public static testMethod void testSaveIssue(){
		List<Group> groups = getGroups();
		system.assertEquals(5, groups.size());
		User u = getSFA2UserFromGroups(groups, false);
		system.runAs(u){
			PageReference pr = Page.CADS_Account_Address_Issues;
			pr.getParameters().put('mode','reopen');
			pr.getParameters().put('tab','tab');
			Test.setCurrentPage(pr);
			CADS_Account_Address_Issues_gne__c cadsAAI = GNE_SFA2_Triggers_Test_Util.prepareCADS_Account_Address_Issues_gne();
			cadsAAI.Next_Action_Comment_gne__c = 'test comment';
			insert cadsAAI;
			GNE_SFA2_CADS_EditIssues cadsCtrl = new GNE_SFA2_CADS_EditIssues(new ApexPages.StandardController(cadsAAI));
			system.assertEquals('test comment', [SELECT Next_Action_Comment_gne__c FROM CADS_Account_Address_Issues_gne__c WHERE Id = :cadsAAI.Id LIMIT 1][0].Next_Action_Comment_gne__c);
			pr = cadsCtrl.saveIssue();
			system.assertEquals(true, pr.getRedirect());
			system.assertEquals('tab', pr.getParameters().get('tab'));
			system.assert(pr.getUrl().contains(cadsAAI.Id), 'Wrong URL: ' + pr.getUrl());
			system.assertEquals(null, [SELECT Next_Action_Comment_gne__c FROM CADS_Account_Address_Issues_gne__c WHERE Id = :cadsAAI.Id LIMIT 1][0].Next_Action_Comment_gne__c);

		}
	}

	private static List<Group> getGroups(){
		return [SELECT Id FROM Group WHERE Name IN ('Data Stewardship', 'GNE-AGS-CCO-Manager-Group', 'GNE-AGS-CCO-Analyst-Group', 'GNE-AGS-CCO-TempAnalyst-Group', 'GNE-AGS-CCO-TEAM')];
	}

	private static User getSFA2UserFromGroups(List<Group> groups, Boolean isGroupMember){
		List<Id> groupsId = new List<Id>();
		for(Group g :groups){
			groupsId.add(g.Id);
		}
		List<Profile> p = [SELECT Id FROM Profile WHERE Name LIKE 'GNE-Field' AND Name NOT IN ('GNE-SFA-Ops', 'GNE-SFA-InternalUser')];
		system.assertNotEquals(0, p.size());
		List<User> users;
		if(isGroupMember){
			users = [SELECT Id, External_ID_gne__c, Profile.Name FROM User WHERE ProfileId IN :p AND IsActive = true];
			system.assertNotEquals(0, users.size(), 'No user found. IsGroupMember = ' + isGroupMember);
			insert new GroupMember(GroupId = groupsId[0], UserOrGroupId = users[0].Id);
		} else {
			users = [SELECT Id, External_ID_gne__c, Profile.Name FROM User WHERE ProfileId IN :p AND IsActive = true AND Id NOT IN (SELECT UserOrGroupId FROM GroupMember WHERE GroupId IN :groupsId)];
			system.assertNotEquals(0, users.size(), 'No user found. IsGroupMember = ' + isGroupMember);
			system.debug('Selected user: ' + users[0]);
		}
		return users[0];
	}
}