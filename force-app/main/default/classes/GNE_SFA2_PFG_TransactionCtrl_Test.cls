@isTest
public with sharing class GNE_SFA2_PFG_TransactionCtrl_Test {
	private static void init() {
		GNE_SFA2_PFG_TestHelper.init();
	}

	private static void init(String userRole) {
		GNE_SFA2_PFG_TestHelper.init(userRole);
	}

	private static SFA2_PFG_Transaction_gne__c insertAllocationTransfer(String fromUserName, String toUserName) {
		Territory2 fromTerr = GNE_SFA2_PFG_TestHelper.getTerritory(fromUserName);
		Territory2 toTerr = GNE_SFA2_PFG_TestHelper.getTerritory(toUserName);
		Product_vod__c dtpProd = ((Map<String,Product_vod__c>)GNE_SFA2_PFG_TestHelper.cache.get('pfgProducts')).get('DTP1');
		SFA2_PFG_Transaction_gne__c trx = new SFA2_PFG_Transaction_gne__c(
			RecordTypeId = GNE_SFA2_PFG_Util.getTransactionRecordTypeId(GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION_TRANSFER),
			From_User_Territory_gne__c = fromTerr.Id,
			From_Territory_Name_gne__c = fromTerr.Name,
			To_User_Territory_gne__c = toTerr.Id,
			To_Territory_Name_gne__c = toTerr.Name,
			Product_gne__c = dtpProd.Id,
			Distribution_Method_gne__c = GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP,
			Requested_Quantity_gne__c = 1
		);

		insert trx;
		return trx;
	}

	private static SFA2_PFG_Transaction_gne__c insertTransfer(String fromUserName, String toUserName) {
		User fromUser = GNE_SFA2_PFG_TestHelper.getUser(fromUserName);
		User toUser = GNE_SFA2_PFG_TestHelper.getUser(toUserName);
		Product_vod__c hcProd = ((Map<String,Product_vod__c>)GNE_SFA2_PFG_TestHelper.cache.get('pfgProducts')).get('HC1');
		SFA2_PFG_Transaction_gne__c trx = new SFA2_PFG_Transaction_gne__c(
			RecordTypeId = GNE_SFA2_PFG_Util.getTransactionRecordTypeId(GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_TRANSFER),
			From_User_gne__c = fromUser.Id,
			To_User_gne__c = toUser.Id,
			Product_gne__c = hcProd.Id,
			Distribution_Method_gne__c = GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC,
			Requested_Quantity_gne__c = 1
		);

		insert trx;
		return trx;
	}

	private static void testNewMode(String rtName) {
		init();
		GNE_SFA2_PFG_TestHelper.configurationObjectHelper.insertCosForRecordTypeNames(new Set<String>{rtName});
		GNE_SFA2_PFG_Trans_Edit_Create_Ext ctrl;
		PageReference pRef;
		System.runAs(GNE_SFA2_PFG_TestHelper.getCurrentUser()) {
			PageReference pageRef = Page.GNE_SFA2_PFG_Trans_CreateEdit_Layout;
			pageRef.getParameters().put('transactionType', rtName);
			if(rtName==GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ORDER) {
				pageRef.getParameters().put('requestSubmitted','1');
			}
			Test.setCurrentPage(pageRef);
        	ApexPages.StandardController stdCtrl = new ApexPages.StandardController(new SFA2_PFG_Transaction_gne__c());
        	Test.startTest();
        	ctrl = new GNE_SFA2_PFG_Trans_Edit_Create_Ext(stdCtrl);
        	pRef = ctrl.init();
        	Test.stopTest();
		}

		System.assertEquals(null, pRef, 'PegeReference not null: ' + (pRef!=null ? pRef.getURL() : ''));
		System.assertNotEquals(null, ctrl.myObject, 'MyObject should be set');
		System.assertEquals(null, ctrl.myObject.Id, 'MyObject Id should be null');
		System.assertEquals(ctrl.myObject, ctrl.mainTrx, 'MyObject should be the same as mainTrx');
		System.assertEquals(1, ctrl.transactions.size(), 'Transaction Wrappers should contain mainTrx only');
		System.assert(ctrl.isPfgInformationEnabled,'Information section should be enabled for ' + rtName);
	}

	private static void testSaveAllocationTransferNewMode(String userName, String fromUserName, String toUserName) {
		system.debug(fromUserName);
		system.debug(toUserName);
		system.debug(userName);
		init(userName);
		String rtName = GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION_TRANSFER;
		GNE_SFA2_PFG_TestHelper.configurationObjectHelper.insertCosForRecordTypeNames(new Set<String>{rtName});
		GNE_SFA2_PFG_TestHelper.insertPfgToTerritoryDetails();
		Product_vod__c dtpProd = ((Map<String,Product_vod__c>)GNE_SFA2_PFG_TestHelper.cache.get('pfgProducts')).get('DTP1');
		GNE_SFA2_PFG_Trans_Edit_Create_Ext ctrl;
		PageReference pRefSave;

		System.runAs(GNE_SFA2_PFG_TestHelper.getCurrentUser()) {
			PageReference pageRef = Page.GNE_SFA2_PFG_Trans_CreateEdit_Layout;
			pageRef.getParameters().put('transactionType', rtName);
			Test.setCurrentPage(pageRef);
        	ApexPages.StandardController stdCtrl = new ApexPages.StandardController(new SFA2_PFG_Transaction_gne__c());
        	Test.startTest();
        	ctrl = new GNE_SFA2_PFG_Trans_Edit_Create_Ext(stdCtrl);
        	ctrl.init();
        	ctrl.customRecId = GNE_SFA2_PFG_TestHelper.getTerritory(fromUserName).Id;
        	ctrl.fieldName = 'From_User_Territory_gne__c';
        	ctrl.territoryLookupFieldActionMethod();
        	ctrl.customRecId = GNE_SFA2_PFG_TestHelper.getTerritory(toUserName).Id;
        	ctrl.fieldName = 'To_User_Territory_gne__c';
        	ctrl.territoryLookupFieldActionMethod();
        	ctrl.rowIdx = '0';
        	ctrl.productId = dtpProd.Id;
        	ctrl.populateProductFields();
        	ctrl.transactions[0].record.Requested_Quantity_gne__c = 1;
        	pRefSave = ctrl.saveTransaction();
        	Test.stopTest();
		}

		List<String> pageErrors = new List<String>();

		for(ApexPages.Message msg : ApexPages.getMessages()) {
			pageErrors.add(msg.getSummary());
		}

		System.assertNotEquals(null, pRefSave, 'PegeReference is null. Page Errors: ' + String.join(pageErrors,'\n'));
		System.assertNotEquals(null, ctrl.mainTrx.Id,'Main Trx should have SFDC ID. Page Erorrs: ' + String.join(pageErrors,'\n'));
		System.assertEquals('/' + ctrl.mainTrx.Id, pRefSave.getUrl(),'After Save page should be redirected to Transaction detail page');
		System.assertEquals(1, ctrl.transactions.size(), 'Transaction Wrappers should contain mainTrx only');
		System.assertEquals(1, [SELECT count() FROM SFA2_PFG_Transaction_gne__c WHERE RecordType.Name = :rtName], 'There should be exactly 1 Allocation Transfer in the Database');
	}

	private TestMethod static void testInitAllocTransferViewMode() {
		init('HO1');
		String rtName = GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION_TRANSFER;
		GNE_SFA2_PFG_TestHelper.configurationObjectHelper.insertCosForRecordTypeNames(new Set<String>{rtName});
		GNE_SFA2_PFG_TestHelper.insertPfgToTerritoryDetails();
		GNE_SFA2_PFG_Trans_Ext ctrl;
		SFA2_PFG_Transaction_gne__c trx;
		PageReference pRef;
		System.runAs(GNE_SFA2_PFG_TestHelper.getCurrentUser()) {
			trx = insertAllocationTransfer('CS1', 'CS2');
			PageReference pageRef = Page.GNE_SFA2_PFG_Transactions_Layout;
			Test.setCurrentPage(pageRef);
        	ApexPages.StandardController stdCtrl = new ApexPages.StandardController(trx);
        	Test.startTest();
        	ctrl = new GNE_SFA2_PFG_Trans_Ext(stdCtrl);
        	pRef = ctrl.init();
        	Test.stopTest();
		}

		System.assertEquals(null, pRef, 'PegeReference not null: ' + (pRef!=null ? pRef.getURL() : ''));
		System.assertNotEquals(null, ctrl.myObject, 'MyObject should be set');
		System.assertEquals(trx.Id, ctrl.myObject.Id, 'MyObject Id should not be null');
		System.assertEquals(rtName, ctrl.recordTypeVisName, 'Wrong ctrl.recordTypeVisName');
		System.assert(ctrl.isDtp,'DTP flag should be marked');
		System.assert(!ctrl.isOrder,'Order flag should not be marked');
		System.assertEquals(1, ctrl.relatedTransactions.size(), 'Transaction Wrappers should contain mainTrx only');
	}

	private TestMethod static void testInitTransferViewMode() {
		init();
		String rtName = GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_TRANSFER;
		GNE_SFA2_PFG_TestHelper.configurationObjectHelper.insertCosForRecordTypeNames(new Set<String>{rtName});
		GNE_SFA2_PFG_TestHelper.insertPfgToUserDetails();
		GNE_SFA2_PFG_Trans_Ext ctrl;
		SFA2_PFG_Transaction_gne__c trx;
		PageReference pRef;
		System.runAs(GNE_SFA2_PFG_TestHelper.getCurrentUser()) {
			trx = insertTransfer('CS1', 'CS2');
			PageReference pageRef = Page.GNE_SFA2_PFG_Transactions_Layout;
			Test.setCurrentPage(pageRef);
        	ApexPages.StandardController stdCtrl = new ApexPages.StandardController(trx);
        	Test.startTest();
        	ctrl = new GNE_SFA2_PFG_Trans_Ext(stdCtrl);
        	pRef = ctrl.init();
        	Test.stopTest();
		}

		System.assertEquals(null, pRef, 'PegeReference not null: ' + (pRef!=null ? pRef.getURL() : ''));
		System.assertNotEquals(null, ctrl.myObject, 'MyObject should be set');
		System.assertEquals(trx.Id, ctrl.myObject.Id, 'MyObject Id should not be null');
		System.assertEquals(rtName, ctrl.recordTypeVisName, 'Wrong ctrl.recordTypeVisName');
		System.assert(!ctrl.isDtp,'DTP flag should not be marked');
		System.assert(!ctrl.isOrder,'Order flag should not be marked');
		System.assertEquals(1, ctrl.relatedTransactions.size(), 'Transaction Wrappers should contain mainTrx only');
	}

	private TestMethod static void testInitTransferEditMode() {
		init();
		String rtName = GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_TRANSFER;
		GNE_SFA2_PFG_TestHelper.configurationObjectHelper.insertCosForRecordTypeNames(new Set<String>{rtName});
		GNE_SFA2_PFG_Trans_Edit_Create_Ext ctrl;
		SFA2_PFG_Transaction_gne__c trx;
		PageReference pRef;
		System.runAs(GNE_SFA2_PFG_TestHelper.getCurrentUser()) {
			trx = insertTransfer('CS1', 'CS2');
			PageReference pageRef = Page.GNE_SFA2_PFG_Trans_CreateEdit_Layout;
			pageRef.getParameters().put('transactionType', rtName);
			Test.setCurrentPage(pageRef);
        	ApexPages.StandardController stdCtrl = new ApexPages.StandardController(trx);
        	Test.startTest();
        	ctrl = new GNE_SFA2_PFG_Trans_Edit_Create_Ext(stdCtrl);
        	pRef = ctrl.init();
        	Test.stopTest();
		}

		System.assertEquals(null, pRef, 'PegeReference not null: ' + (pRef!=null ? pRef.getURL() : ''));
		System.assertNotEquals(null, ctrl.myObject, 'MyObject should be set');
		System.assertEquals(trx.Id, ctrl.myObject.Id, 'MyObject Id should not be null');
		System.assertEquals(ctrl.myObject, ctrl.mainTrx, 'MyObject should be the same as mainTrx');
		System.assertEquals(1, ctrl.transactions.size(), 'Transaction Wrappers should contain mainTrx only');
		System.assert(ctrl.isPfgInformationEnabled,'Information section should be enabled for ' + rtName);
	}

	private TestMethod static void testInitAllocTransferNewMode() {
		testNewMode(GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION_TRANSFER);
	}

	private TestMethod static void testInitTransferNewMode() {
		testNewMode(GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_TRANSFER);
	}

	private TestMethod static void testInitAdjustmentNewMode() {
		testNewMode(GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ADJUSTMENT);
	}

	private TestMethod static void testInitOrderNewMode() {
		testNewMode(GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ORDER);
	}

	private TestMethod static void testInitReturnNewMode() {
		testNewMode(GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RETURN);
	}

	private TestMethod static void testSaveAllocationTransferHONewMode() {
		testSaveAllocationTransferNewMode('HO1', 'CS1', 'CS2');
	}

	private TestMethod static void testSaveAllocationTransferRMNewMode() {
		testSaveAllocationTransferNewMode('RM1', 'CS1', 'CS2');
	}

	private TestMethod static void testSaveAllocationTransferDMNewMode() {
		testSaveAllocationTransferNewMode('DM1', 'CS1', 'DM1');
	}

	private TestMethod static void testAddAndRemoveTransferNewMode() {
		init();
		String rtName = GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_TRANSFER;
		GNE_SFA2_PFG_TestHelper.configurationObjectHelper.insertCosForRecordTypeNames(new Set<String>{rtName});
		GNE_SFA2_PFG_Trans_Edit_Create_Ext ctrl;
		PageReference pRefAdd, pRefRemove;

		System.runAs(GNE_SFA2_PFG_TestHelper.getCurrentUser()) {
			PageReference pageRef = Page.GNE_SFA2_PFG_Trans_CreateEdit_Layout;
			pageRef.getParameters().put('transactionType', rtName);
			Test.setCurrentPage(pageRef);
        	ApexPages.StandardController stdCtrl = new ApexPages.StandardController(new SFA2_PFG_Transaction_gne__c());
        	Test.startTest();
        	ctrl = new GNE_SFA2_PFG_Trans_Edit_Create_Ext(stdCtrl);
        	ctrl.init();
        	pRefAdd = ctrl.addTransfer();
        	System.assertEquals(2, ctrl.transactions.size(), 'Transaction Wrappers should contain new row');
        	ctrl.rowIdx = '1';
        	pRefRemove = ctrl.removeTransfer();
        	Test.stopTest();
		}

		System.assertEquals(null, pRefAdd, 'PegeReference (AddTransfer) not null: ' + (pRefAdd!=null ? pRefAdd.getURL() : ''));
		System.assertEquals(null, pRefRemove, 'PegeReference (RemoveTranfer) not null: ' + (pRefRemove!=null ? pRefRemove.getURL() : ''));
		System.assertEquals(1, ctrl.transactions.size(), 'Transaction Wrappers should contain mainTrx only');

	}

	private TestMethod static void testSetLotCatalogForAdjustmentNewMode() {
		init();
		String rtName = GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RETURN;
		GNE_SFA2_PFG_TestHelper.configurationObjectHelper.insertCosForRecordTypeNames(new Set<String>{rtName});
		GNE_SFA2_PFG_TestHelper.insertPfgToUserDetails();
		SFA2_Lot_Catalog_gne__c lot = ((Map<Id,SFA2_Lot_Catalog_gne__c>)GNE_SFA2_PFG_TestHelper.cache.get('lotCatalogs')).values()[0];

		GNE_SFA2_PFG_Trans_Edit_Create_Ext ctrl;
		PageReference pRefProductChange, pRefLotChange;

		System.runAs(GNE_SFA2_PFG_TestHelper.getCurrentUser()) {
			PageReference pageRef = Page.GNE_SFA2_PFG_Trans_CreateEdit_Layout;
			pageRef.getParameters().put('transactionType', rtName);
			Test.setCurrentPage(pageRef);
        	ApexPages.StandardController stdCtrl = new ApexPages.StandardController(new SFA2_PFG_Transaction_gne__c());
        	Test.startTest();
        	ctrl = new GNE_SFA2_PFG_Trans_Edit_Create_Ext(stdCtrl);
        	ctrl.init();
        	ctrl.rowIdx = '0';
        	ctrl.productId = lot.Product_gne__c;
        	pRefProductChange = ctrl.populateProductFields();
        	ctrl.lotId = lot.Id;
        	pRefLotChange = ctrl.lotNoSelectAction();
        	Test.stopTest();
		}

		System.assertEquals(null, pRefProductChange, 'PegeReference (SetProduct) not null: ' + (pRefProductChange!=null ? pRefProductChange.getURL() : ''));
		System.assertEquals(null, pRefLotChange, 'PegeReference (SetLot) not null: ' + (pRefLotChange!=null ? pRefLotChange.getURL() : ''));
		System.assertEquals(lot.Product_gne__c, ctrl.mainTrx.Product_gne__c, 'Wrong value of Product');
		System.assertEquals(lot.Name, ctrl.mainTrx.Lot_No_gne__c, 'Wrong value of Lot#');
	}


	private TestMethod static void testSaveTransferNewMode() {
		init();
		String rtName = GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_TRANSFER;
		GNE_SFA2_PFG_TestHelper.configurationObjectHelper.insertCosForRecordTypeNames(new Set<String>{rtName});
		GNE_SFA2_PFG_TestHelper.insertPfgToUserDetails();
		List<SFA2_Lot_Catalog_gne__c> lots = ((Map<Id,SFA2_Lot_Catalog_gne__c>)GNE_SFA2_PFG_TestHelper.cache.get('lotCatalogs')).values();
		GNE_SFA2_PFG_Trans_Edit_Create_Ext ctrl;
		PageReference pRefSave;

		System.runAs(GNE_SFA2_PFG_TestHelper.getCurrentUser()) {
			PageReference pageRef = Page.GNE_SFA2_PFG_Trans_CreateEdit_Layout;
			pageRef.getParameters().put('transactionType', rtName);
			Test.setCurrentPage(pageRef);
        	ApexPages.StandardController stdCtrl = new ApexPages.StandardController(new SFA2_PFG_Transaction_gne__c());
        	Test.startTest();
        	ctrl = new GNE_SFA2_PFG_Trans_Edit_Create_Ext(stdCtrl);
        	ctrl.init();
        	ctrl.addTransfer();
        	ctrl.customRecId = GNE_SFA2_PFG_TestHelper.getUser('CS1').Id;
        	ctrl.fieldName = 'From_User_gne__c';
        	ctrl.userLookupFieldActionMethod();
        	ctrl.customRecId = GNE_SFA2_PFG_TestHelper.getUser('CS1').Id;
        	ctrl.fieldName = 'To_User_gne__c';
        	ctrl.userLookupFieldActionMethod();
        	ctrl.rowIdx = '0';
        	ctrl.lotId = lots[0].Id;
        	ctrl.lotNoSelectAction();
        	ctrl.transactions[0].record.Requested_Quantity_gne__c = 1;
        	ctrl.rowIdx = '1';
        	ctrl.lotId = lots[1].Id;
        	ctrl.lotNoSelectAction();
        	ctrl.transactions[1].record.Requested_Quantity_gne__c = 2;
        	pRefSave = ctrl.saveTransaction();
        	Test.stopTest();
		}

		List<String> pageErrors = new List<String>();

		for(ApexPages.Message msg : ApexPages.getMessages()) {
			pageErrors.add(msg.getSummary());
		}

		System.assertNotEquals(null, pRefSave, 'PegeReference is null. Page Errors: ' + String.join(pageErrors,'\n'));
		System.assertNotEquals(null, ctrl.mainTrx.Id,'Main Trx should have SFDC ID. Page Erorrs: ' + String.join(pageErrors,'\n'));
		System.assertEquals('/' + ctrl.mainTrx.Id, pRefSave.getUrl(),'After Save page should be redirected to Transaction detail page');
		System.assertEquals(2, ctrl.transactions.size(), 'Transaction Wrappers should contain mainTrx and one additional Transfer');
		System.assertEquals(2, [SELECT count() FROM SFA2_PFG_Transaction_gne__c WHERE RecordType.Name = :rtName], 'There should be exactly 2 Transfers in the Database');
	}

	private TestMethod static void testSaveReturnNewMode() {
		init('HO1');
		String rtName = GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RETURN;
		GNE_SFA2_PFG_TestHelper.configurationObjectHelper.insertCosForRecordTypeNames(new Set<String>{rtName});
		GNE_SFA2_PFG_TestHelper.insertPfgToUserDetails();
		Vendor_gne__c vendor = GNE_SFA2_PFG_TestHelper.insertVendor();
		List<SFA2_Lot_Catalog_gne__c> lots = ((Map<Id,SFA2_Lot_Catalog_gne__c>)GNE_SFA2_PFG_TestHelper.cache.get('lotCatalogs')).values();
		GNE_SFA2_PFG_Trans_Edit_Create_Ext ctrl;
		PageReference pRefVendorChange, pRefSave;

		System.runAs(GNE_SFA2_PFG_TestHelper.getCurrentUser()) {
			PageReference pageRef = Page.GNE_SFA2_PFG_Trans_CreateEdit_Layout;
			pageRef.getParameters().put('transactionType', rtName);
			Test.setCurrentPage(pageRef);
        	ApexPages.StandardController stdCtrl = new ApexPages.StandardController(new SFA2_PFG_Transaction_gne__c());
        	Test.startTest();
        	ctrl = new GNE_SFA2_PFG_Trans_Edit_Create_Ext(stdCtrl);
        	ctrl.init();
        	ctrl.customRecId = GNE_SFA2_PFG_TestHelper.getUser('CS1').Id;
        	ctrl.fieldName = 'From_User_gne__c';
        	ctrl.userLookupFieldActionMethod();
        	ctrl.rowIdx = '0';
        	ctrl.lotId = lots[0].Id;
        	ctrl.lotNoSelectAction();
        	ctrl.transactions[0].record.Requested_Quantity_gne__c = 1;
        	ctrl.vendorId = vendor.Id;
        	GNE_SFA2_PFG_Util.vendorsByIdCache = null;
        	pRefVendorChange = ctrl.returnToValueChanged();
        	pRefSave = ctrl.saveTransaction();
        	Test.stopTest();
		}

		List<String> pageErrors = new List<String>();

		for(ApexPages.Message msg : ApexPages.getMessages()) {
			pageErrors.add(msg.getSummary());
		}

		pageErrors.add('Vendors in Cache: ' + String.valueOf(GNE_SFA2_PFG_Util.vendorsByIdCache.values()));
		System.assertEquals(null, pRefVendorChange, 'PegeReference not null: ' + (pRefVendorChange!=null ? pRefVendorChange.getURL() : ''));
		System.assertNotEquals(null, pRefSave, 'PegeReference is null. Page Errors: ' + String.join(pageErrors,'\n'));
		System.assertNotEquals(null, ctrl.mainTrx.Id,'Main Trx should have SFDC ID. Page Erorrs: ' + String.join(pageErrors,'\n'));
		System.assertEquals('/' + ctrl.mainTrx.Id, pRefSave.getUrl(),'After Save page should be redirected to Transaction detail page');
		System.assertEquals(1, ctrl.transactions.size(), 'Transaction Wrappers should contain mainTrx only');
		System.assertEquals(1, [SELECT count() FROM SFA2_PFG_Transaction_gne__c WHERE RecordType.Name = :rtName], 'There should be exactly 1 Return in the Database');
	}

	private TestMethod static void testSaveOrderNewMode() {
		init();
		String rtName = GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ORDER;
		GNE_SFA2_PFG_TestHelper.configurationObjectHelper.insertCosForRecordTypeNames(new Set<String>{rtName});
		GNE_SFA2_PFG_TestHelper.insertPfgToUserDetails();
		List<SFA2_Lot_Catalog_gne__c> lots = ((Map<Id,SFA2_Lot_Catalog_gne__c>)GNE_SFA2_PFG_TestHelper.cache.get('lotCatalogs')).values();
		GNE_SFA2_PFG_Trans_Edit_Create_Ext ctrl;
		PageReference pRefSave;

		System.runAs(GNE_SFA2_PFG_TestHelper.getCurrentUser()) {
			PageReference pageRef = Page.GNE_SFA2_PFG_Trans_CreateEdit_Layout;
			pageRef.getParameters().put('transactionType', rtName);
			Test.setCurrentPage(pageRef);
        	ApexPages.StandardController stdCtrl = new ApexPages.StandardController(new SFA2_PFG_Transaction_gne__c());
        	Test.startTest();
        	ctrl = new GNE_SFA2_PFG_Trans_Edit_Create_Ext(stdCtrl);
        	ctrl.init();
        	ctrl.rowIdx = '0';
        	ctrl.productId = lots[0].Product_gne__c;
        	ctrl.populateProductFields();
        	ctrl.transactions[0].record.Requested_Quantity_gne__c = 1;
        	pRefSave = ctrl.saveTransaction();
        	Test.stopTest();
		}

		List<String> pageErrors = new List<String>();

		for(ApexPages.Message msg : ApexPages.getMessages()) {
			pageErrors.add(msg.getSummary());
		}

		System.assertNotEquals(null, pRefSave, 'PegeReference is null. Page Errors: ' + String.join(pageErrors,'\n'));
		System.assertNotEquals(null, ctrl.mainTrx.Id,'Main Trx should have SFDC ID. Page Erorrs: ' + String.join(pageErrors,'\n'));
		System.assert(pRefSave.getUrl().containsIgnoreCase('/' + ctrl.mainTrx.getSobjectType().getDescribe().getKeyPrefix() + '/e'),'After Save page should be redirected to new Order page');
		System.assertEquals(rtName, pRefSave.getParameters().get('transactionType'), 'Wrong value for URL Attribite transactionType');
		System.assertEquals('1', pRefSave.getParameters().get('requestSubmitted'), 'Wrong value for URL Attribite requestSubmitted');
		System.assertEquals(1, ctrl.transactions.size(), 'Transaction Wrappers should contain mainTrx only');
		System.assertEquals(1, [SELECT count() FROM SFA2_PFG_Transaction_gne__c WHERE RecordType.Name = :rtName], 'There should be exactly 1 Order in the Database');
	}

	private TestMethod static void testSaveAdjustmentNewMode() {
		init('HO1');
		String rtName = GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ADJUSTMENT;
		GNE_SFA2_PFG_TestHelper.configurationObjectHelper.insertCosForRecordTypeNames(new Set<String>{rtName});
		GNE_SFA2_PFG_TestHelper.insertPfgToUserDetails();
		List<SFA2_Lot_Catalog_gne__c> lots = ((Map<Id,SFA2_Lot_Catalog_gne__c>)GNE_SFA2_PFG_TestHelper.cache.get('lotCatalogs')).values();
		GNE_SFA2_PFG_Trans_Edit_Create_Ext ctrl;
		PageReference pRefSave;

		System.runAs(GNE_SFA2_PFG_TestHelper.getCurrentUser()) {
			PageReference pageRef = Page.GNE_SFA2_PFG_Trans_CreateEdit_Layout;
			pageRef.getParameters().put('transactionType', rtName);
			Test.setCurrentPage(pageRef);
        	ApexPages.StandardController stdCtrl = new ApexPages.StandardController(new SFA2_PFG_Transaction_gne__c());
        	Test.startTest();
        	ctrl = new GNE_SFA2_PFG_Trans_Edit_Create_Ext(stdCtrl);
        	ctrl.init();
        	ctrl.customRecId = GNE_SFA2_PFG_TestHelper.getUser('CS1').Id;
        	ctrl.fieldName = 'From_User_gne__c';
        	ctrl.userLookupFieldActionMethod();
        	ctrl.mainTrx.Transaction_Reason_gne__c = 'Inventory Miscount';
        	ctrl.rowIdx = '0';
        	ctrl.lotId = lots[0].Id;
        	ctrl.lotNoSelectAction();
        	ctrl.transactions[0].record.Requested_Quantity_gne__c = 1;
        	pRefSave = ctrl.saveTransaction();
        	Test.stopTest();
		}

		List<String> pageErrors = new List<String>();

		for(ApexPages.Message msg : ApexPages.getMessages()) {
			pageErrors.add(msg.getSummary());
		}

		System.assertNotEquals(null, pRefSave, 'PegeReference is null. Page Errors: ' + String.join(pageErrors,'\n'));
		System.assertNotEquals(null, ctrl.mainTrx.Id,'Main Trx should have SFDC ID. Page Erorrs: ' + String.join(pageErrors,'\n'));
		System.assertEquals('/' + ctrl.mainTrx.Id, pRefSave.getUrl(),'After Save page should be redirected to Transaction detail page');
		System.assertEquals(1, ctrl.transactions.size(), 'Transaction Wrappers should contain mainTrx only');
		System.assertEquals(1, [SELECT count() FROM SFA2_PFG_Transaction_gne__c WHERE RecordType.Name = :rtName], 'There should be exactly 1 Adjustment in the Database');
	}

	private TestMethod static void testExceptionHandlingNewMode() {
		init();
		String rtName = GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_TRANSFER;
		GNE_SFA2_PFG_TestHelper.configurationObjectHelper.insertCosForRecordTypeNames(new Set<String>{rtName});
		GNE_SFA2_PFG_TestHelper.insertPfgToUserDetails();
		List<SFA2_Lot_Catalog_gne__c> lots = ((Map<Id,SFA2_Lot_Catalog_gne__c>)GNE_SFA2_PFG_TestHelper.cache.get('lotCatalogs')).values();
		GNE_SFA2_PFG_Trans_Edit_Create_Ext ctrl;
		PageReference pRefSave;

		System.runAs(GNE_SFA2_PFG_TestHelper.getCurrentUser()) {
			PageReference pageRef = Page.GNE_SFA2_PFG_Trans_CreateEdit_Layout;
			pageRef.getParameters().put('transactionType', rtName);
			Test.setCurrentPage(pageRef);
        	ApexPages.StandardController stdCtrl = new ApexPages.StandardController(new SFA2_PFG_Transaction_gne__c());
        	Test.startTest();
        	ctrl = new GNE_SFA2_PFG_Trans_Edit_Create_Ext(stdCtrl);
        	ctrl.init();
        	ctrl.addTransfer();
        	ctrl.addTransfer();
        	ctrl.addTransfer();
        	ctrl.addTransfer();
        	ctrl.customRecId = GNE_SFA2_PFG_TestHelper.getUser('CS1').Id;
        	ctrl.fieldName = 'From_User_gne__c';
        	ctrl.userLookupFieldActionMethod();
        	ctrl.customRecId = GNE_SFA2_PFG_TestHelper.getUser('CS2').Id;
        	ctrl.fieldName = 'To_User_gne__c';
        	ctrl.userLookupFieldActionMethod();
        	ctrl.mainTrx.City_gne__c = null;
        	ctrl.rowIdx = '0';
        	ctrl.lotId = lots[0].Id;
        	ctrl.lotNoSelectAction();
        	ctrl.transactions[0].record.Requested_Quantity_gne__c = -1;
        	ctrl.rowIdx = '1';
        	ctrl.lotId = lots[1].Id;
        	ctrl.lotNoSelectAction();
        	ctrl.transactions[1].record.Requested_Quantity_gne__c = 2000000;
        	ctrl.rowIdx = '2';
        	ctrl.productId = lots[2].Product_gne__c;
        	ctrl.populateProductFields();
        	ctrl.transactions[2].record.Requested_Quantity_gne__c = 1;
        	ctrl.rowIdx = '3';
        	ctrl.lotId = lots[0].Id;
        	ctrl.lotNoSelectAction();
        	ctrl.transactions[2].record.Requested_Quantity_gne__c = 1;
        	pRefSave = ctrl.saveTransaction();
        	Test.stopTest();
		}

		List<String> pageErrors = new List<String>();

		for(ApexPages.Message msg : ApexPages.getMessages()) {
			pageErrors.add(msg.getSummary());
		}

		String pageErrorsString = String.join(pageErrors,'\n');

		System.assertEquals(null, pRefSave, 'PegeReference not null: ' + (pRefSave!=null ? pRefSave.getURL() : ''));
		System.assertEquals(0, [SELECT count() FROM SFA2_PFG_Transaction_gne__c WHERE RecordType.Name = :rtName], 'There should be no Transfers in the Database');

		System.assert(pageErrorsString.containsIgnoreCase(GNE_SFA2_PFG_Base_Controller.MISSING_REQUIRED_FIELD_VALUE),'"Missing Required Field" Exception should be raised');
		System.assert(pageErrorsString.containsIgnoreCase(GNE_SFA2_PFG_Base_Controller.VALUE_ALREADY_IN_USE_MSG),'"Lot# Already in User" Exception should be raised');
		System.assert(pageErrorsString.containsIgnoreCase(System.Label.GNE_SFA2_PFG_QUANTITY_MUST_BE_BETWEEN.substringBefore('{')),'"Quantity must be between" Exception should be raised');
	}
}