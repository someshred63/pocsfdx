@isTest(seeAllData=false)
private class EDM_Classification_Rltd_List_Ctrl_Test{

	static testMethod void crFieldListNotDefinedTest(){

		RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Business'];

		EDM_Classification_Related_List_Ctrl ctrl = new EDM_Classification_Related_List_Ctrl();
		System.assertEquals(null,ctrl.showRelatedList());

		ctrl.editEnabled = true;
		ctrl.deleteEnabled = true;

		Account acc = new Account(Name='testAccount');
	    insert acc;
	    EDM_Classification_Request_gne__c req = new EDM_Classification_Request_gne__c(EDM_Account_gne__c = acc.Id,EDM_Type_of_Classification_gne__c = 'Business',RecordTypeId = rt.Id);
	    insert req;

	    List<sObject> lo = ctrl.getRecordsList();
	    List<Apexpages.Message> msgs = ApexPages.getMessages();
        System.assertEquals(1,msgs.size(),msgs);
        System.assert(msgs[0].getDetail().contains('fieldList or fieldsCSV attribute must be defined.'));

        System.assertEquals(null,lo);
	}

	static testMethod void crParentFieldIdNotDefinedTest(){

		RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Business'];

		EDM_Classification_Related_List_Ctrl ctrl = new EDM_Classification_Related_List_Ctrl();
		System.assertEquals(null,ctrl.showRelatedList());

		ctrl.editEnabled = true;
		ctrl.deleteEnabled = true;

		Account acc = new Account(Name='testAccount');
	    insert acc;
	    EDM_Classification_Request_gne__c req = new EDM_Classification_Request_gne__c(EDM_Account_gne__c = acc.Id,EDM_Type_of_Classification_gne__c = 'Business',RecordTypeId = rt.Id);
	    insert req;

	    ctrl.fieldsCSV='To_Account_vod__c,To_Contact_vod__c,Role_vod__c,CreatedById,CreatedDate';
		
        List<sObject> lo = ctrl.getRecordsList();
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        System.assertEquals(1,msgs.size(),msgs);
        System.assert(msgs[0].getDetail().contains('parentFieldId attribute can not be null'));

        System.assertEquals(null,lo);
	}

	static testMethod void crRelatedListTest(){
		EDM_Classification_Related_List_Ctrl ctrl = new EDM_Classification_Related_List_Ctrl();

		ctrl.editEnabled = true;
		ctrl.deleteEnabled = true;
		System.assertEquals(null,ctrl.showRelatedList());		

		RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Business'];

		Account acc = new Account(Name='testAccount');
	    insert acc;
	    EDM_Classification_Request_gne__c req = new EDM_Classification_Request_gne__c(EDM_Account_gne__c = acc.Id,EDM_Type_of_Classification_gne__c = 'Business',RecordTypeId = rt.Id);
	    insert req;

        ctrl.fieldsCSV='CreatedDate';
        ctrl.filter='CreatedDate != null';
		ctrl.objectName='EDM_Classification_Request_gne__c';
		ctrl.pageSize=20;
		ctrl.urlForNewRecord='new record link';
		ctrl.sortDirection = 'desc';
		ctrl.recordsLimit = 10;

		Map<String, Schema.DescribeSObjectResult> objectDescribe = new Map<String, Schema.DescribeSObjectResult>();

		System.debug('###: '+Schema.getGlobalDescribe().get('EDM_Classification_Request_gne__c').getDescribe());

		List<sObject> lo = ctrl.getRecordsList();
	}

	public static testMethod void testGetRecordsList() {
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('name');
		insert acc;
		Call2_vod__c call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
		call.Account_vod__c = acc.Id;
		insert call;
		EDM_Classification_Related_List_Ctrl ctrl = new EDM_Classification_Related_List_Ctrl();
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
		
		l = ctrl.getRecordsList();
		system.assertEquals(1, l.size());

        ctrl.fieldsCSV = 'Account_vod__c,Account_vod__r.Name';
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
		EDM_Classification_Related_List_Ctrl ctrl = new EDM_Classification_Related_List_Ctrl();
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
		EDM_Classification_Related_List_Ctrl ctrl = new EDM_Classification_Related_List_Ctrl();
		ctrl.objectName = 'Call2_vod__c(';
		system.assertEquals(true, ctrl.getShowNewButton());
		system.assertEquals('Call', ctrl.getObjectLabel());
		system.assertEquals('Call2_vod__c', ctrl.getActionObjectName());

	}
	
}