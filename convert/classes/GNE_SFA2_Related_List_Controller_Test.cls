@isTest
private class GNE_SFA2_Related_List_Controller_Test {
	
	public static testMethod void testGetRecordsList() {
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('name');
		insert acc;
		Call2_vod__c call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
		call.Account_vod__c = acc.Id;
		insert call;
		GNE_SFA2_Related_List_Controller ctrl = new GNE_SFA2_Related_List_Controller();
		List<sObject> l = ctrl.getRecordsList();
		system.assertNotEquals(null, l);
		system.assertEquals(0, l.size());
		//system.assertEquals(null, ctrl.showRelatedList());
		ctrl.pageController = new GNE_SFA2_Account_Ext(new ApexPages.StandardController(acc));
		ctrl.objectName = 'Call2_vod__c(';
        ctrl.fieldsCSV = null;
        ctrl.filter = null;
        ctrl.pageSize = 5;
        ctrl.parentFieldId = acc.Id;
        ctrl.parentFieldName = 'Account_vod__c';
        ctrl.orderByFieldName = 'CreatedDate';
        ctrl.urlForNewRecord = 'www.google.com';
        ctrl.sortDirection = 'asc';
        ctrl.editEnabled = false;
        ctrl.deleteEnabled = false;
        ctrl.relatedListLabel = 'Calls';
        ctrl.initRecords = true;
        ctrl.recordsLimit = 100;
		ctrl.fieldsList = new List<String>{'Account_vod__c', 'Account_vod__r.Name'};
        ctrl.fieldsCSV = 'Account_vod__c,Account_vod__r.Name#/';
		
		l = ctrl.getRecordsList();
		system.assertEquals(1, l.size());

        ctrl.filter = 'Id = \'' + call.Id + '\'';
        ctrl.sortDirection = 'desc';
		ctrl.fieldsList = null;
		l = ctrl.getRecordsList();
		system.assertEquals(1, l.size());
	}

	public static testMethod void testPageReferences(){
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('name');
		insert acc;
		Call2_vod__c call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
		call.Account_vod__c = acc.Id;
		insert call;
		GNE_SFA2_Related_List_Controller ctrl = new GNE_SFA2_Related_List_Controller();
		ctrl.objectName = 'Call2_vod__c';

		PageReference pr = ctrl.showRelatedList();
		system.assertEquals(null, pr);
		system.assertEquals(true, ctrl.loadData);
		ctrl.deleteRecordId = call.Id;

		pr = ctrl.deleteRecord();
		system.assertEquals(null, pr);
		system.assertEquals(0, [SELECT Count() FROM Call2_vod__c]);

		ctrl.userIdToViewLink = 'test';
		pr = ctrl.overrideUserViewLink();
		system.assert(pr.getUrl().contains('GNE_SFA2_User_Layout'), 'Wrong URL: ' + pr.getUrl());
		system.assertEquals('test', pr.getParameters().get('Id'));
		system.assertEquals(true, pr.getRedirect());

		system.assertEquals(null, ctrl.callActionMethod());

		ctrl.pageController = new GNE_SFA2_Account_Ext(new ApexPages.StandardController(acc));
        ctrl.fieldsCSV = 'Account_vod__c,Account_vod__r.Name';
        ctrl.filter = 'Id = \'' + call.Id + '\'';
        ctrl.pageSize = 5;
        ctrl.parentFieldId = acc.Id;
        ctrl.parentFieldName = 'Account_vod__c';
        ctrl.urlForNewRecord = 'www.google.com';
        ctrl.sortDirection = 'asc';
        ctrl.editEnabledCalc = false;
        ctrl.deleteEnabledCalc = false;
        ctrl.relatedListLabel = 'Calls';
        ctrl.initRecords = true;
        ctrl.recordsLimit = 100;
		ctrl.fieldsList = null;
		system.assertNotEquals(null, ctrl.viewAllClick());
	}

	public static testMethod void testGetters(){
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('name');
		insert acc;
		Call2_vod__c call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
		call.Account_vod__c = acc.Id;
		insert call;
		GNE_SFA2_Related_List_Controller ctrl = new GNE_SFA2_Related_List_Controller();
		ctrl.objectName = 'Call2_vod__c(';
		system.assertEquals(true, ctrl.getShowNewButton());
		system.assertEquals('Call', ctrl.getObjectLabel());
		system.assertEquals('Call2_vod__c', ctrl.getActionObjectName());

	}
}