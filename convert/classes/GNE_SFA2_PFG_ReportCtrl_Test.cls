@isTest
public with sharing class GNE_SFA2_PFG_ReportCtrl_Test {
	private static void init() {
		GNE_SFA2_PFG_TestHelper.init();
	}
	
	private static void init(String userRole) {
		GNE_SFA2_PFG_TestHelper.init(userRole);
	}

	private static void insertReportTypes() {
		Map<String, String> reportTypesSettings= new Map<String, String> {
			'Adjustments' => 'HC Reports', //OK
			'Disbursements' => 'HC Reports', //OK
			'HC Exception' => 'HC Reports', //OK
			'Lot Expiration' => 'HC Reports', //OK
			'Quantity Limits for HCP Change History' => 'HC Reports', //OK
			'Returns' => 'HC Reports', // OK
			'Unacknowledged Shipments' => 'HC Reports', //OK
		    'DTP Exception' => 'DTP Reports', //OK
		    'Outstanding AOC' => 'DTP Reports', //OK
		    'Qnt Limits for HCP Change History DTP' => 'DTP Reports' //OK
		};
		
		List<SFA2_PFG_Report_Types_gne__c> reportTypesRecs = new List<SFA2_PFG_Report_Types_gne__c>();
		for(String rName : reportTypesSettings.keySet()) {
		   reportTypesRecs.add(new SFA2_PFG_Report_Types_gne__c(
		   		Name=rName,
		   		Report_Category_gne__c = reportTypesSettings.get(rName),
		   		Report_Name_gne__c = (rName != 'Qnt Limits for HCP Change History DTP' ? rName : 'Quantity Limits for HCP Change History DTP') 
		   ));
		}
		
		insert reportTypesRecs;
		
		Map<String, String> reportCategoriesSettings = new Map<String, String> {
			'DTP Reports' => GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP,
			'HC Reports' => GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC
		};
		List<SFA2_PFG_Report_Categories_gne__c> reportCategoryRecs = new List<SFA2_PFG_Report_Categories_gne__c>();
		
		for(String cName : reportCategoriesSettings.keySet()) {
			reportCategoryRecs.add(new SFA2_PFG_Report_Categories_gne__c(
					Name=cName,
					Is_Visible_gne__c = true,
					Distribution_Method_gne__c = reportCategoriesSettings.get(cName)
			));
		}
		
		insert reportCategoryRecs;
	}
	
	
	
	private static List<GNE_SFA2_PFG_Reports_Helper.WrappedCS> getCSFilterWrappers(Set<String> csNames) {
		List<GNE_SFA2_PFG_Reports_Helper.WrappedCS> result = new List<GNE_SFA2_PFG_Reports_Helper.WrappedCS>();
		
		for(String csName : csNames) {
			User u = GNE_SFA2_PFG_TestHelper.getUser(csName);
			result.addAll(GNE_SFA2_PFG_Report_Filters_Ctrl.searchCSs(u.Name,100));
		}
		
		return result;
	}
	
	private static List<GNE_SFA2_PFG_Reports_Helper.WrappedProduct> getProductFilterWrappers() {
		List<GNE_SFA2_PFG_Reports_Helper.WrappedProduct> result = new List<GNE_SFA2_PFG_Reports_Helper.WrappedProduct>();
		result.addAll(GNE_SFA2_PFG_Report_Filters_Ctrl.searchProducts('%',100, GNE_SFA2_PFG_Reports_Helper.REPORT_CATEGORY_HC));
		result.addAll(GNE_SFA2_PFG_Report_Filters_Ctrl.searchProducts('%',100, GNE_SFA2_PFG_Reports_Helper.REPORT_CATEGORY_DTP));
		return result;
	}
	
	private static List<GNE_SFA2_PFG_Reports_Helper.WrappedLot> getLotFilterWrappers() {
		List<GNE_SFA2_PFG_Reports_Helper.WrappedLot> result = new List<GNE_SFA2_PFG_Reports_Helper.WrappedLot>();
		result.addAll(GNE_SFA2_PFG_Report_Filters_Ctrl.searchLots('%',100, GNE_SFA2_PFG_Reports_Helper.REPORT_CATEGORY_HC));
		return result;
	}
	
	private static List<GNE_SFA2_PFG_Reports_Helper.WrappedAccount> getAccountFilterWrappers(Id hcpId) {
		List<GNE_SFA2_PFG_Reports_Helper.WrappedAccount> result = new List<GNE_SFA2_PFG_Reports_Helper.WrappedAccount>();
		result.addAll(GNE_SFA2_PFG_Report_Filters_Ctrl.searchAccounts(hcpId, 100, true, false, false));
		return result;
	}
	
	private static List<GNE_SFA2_PFG_Reports_Helper.WrappedShipment> getShipmentsFilterWrappers(Set<String> shipmentIds) {
		List<GNE_SFA2_PFG_Reports_Helper.WrappedShipment> result = new List<GNE_SFA2_PFG_Reports_Helper.WrappedShipment>();
		
		for(String shipmentId : shipmentIds) {
			result.addAll(GNE_SFA2_PFG_Report_Filters_Ctrl.searchShipments(shipmentId, 100));
		}
		
		return result;
	}
	
	private static List<GNE_SFA2_PFG_Reports_Helper.WrappedOrder> getOrdersFilterWrappers(Set<Id> orderIds) {
		List<GNE_SFA2_PFG_Reports_Helper.WrappedOrder> result = new List<GNE_SFA2_PFG_Reports_Helper.WrappedOrder>();
		
		for(SFA2_PFG_Transaction_gne__c trx : [SELECT Transaction_Ref_Number_gne__c FROM SFA2_PFG_Transaction_gne__c WHERE Id IN :orderIds]) {
			String refNo = trx.Transaction_Ref_Number_gne__c;
			result.addAll(GNE_SFA2_PFG_Report_Filters_Ctrl.searchOrders(refNo, 100));
		}
		
		return result;
	}
	
	private static void setFilters(GNE_SFA2_PFG_Report_Filters_Ctrl ctrl) {
		ctrl.leftSelectedYears.add(String.valueOf(System.today().year()));
		ctrl.selectProductClick();
		ctrl.selectedCSsJSON = JSON.serialize(getCSFilterWrappers(new Set<String>{'CS1', 'CS2'}));
        ctrl.addCSs();
        ctrl.selectedProductsJSON = JSON.serialize(getProductFilterWrappers());
        ctrl.addProducts();
        ctrl.selectedLotsJSON = JSON.serialize(getLotFilterWrappers());
        ctrl.addLots();
        ctrl.expirationDays = ctrl.expirationOptions[0].getValue();
        ctrl.selectLotExpiration();
        
        if(GNE_SFA2_PFG_TestHelper.accountHelper.accountsCache!=null) {
        	Id hcpId = new List<Id>(GNE_SFA2_PFG_TestHelper.accountHelper.accountsByTypeCache.get('US_HCP'))[0];
			Account hcp = GNE_SFA2_PFG_TestHelper.accountHelper.accountsCache.get(hcpId);
			ctrl.selectedAccsJSON = JSON.serialize(getAccountFilterWrappers(hcpId));
        	ctrl.addAccounts();
        }
	}
	
	private static void setFilters(GNE_SFA2_PFG_Report_Filters_Ctrl ctrl, Set<Id> orderIds, Set<String> shipmentIds) {
		setFilters(ctrl);
		ctrl.selectedShpJSON = JSON.serialize(getShipmentsFilterWrappers(shipmentIds));
		ctrl.addShipments();
		
		ctrl.selectedOrdJSON = JSON.serialize(getOrdersFilterWrappers(orderIds));
		ctrl.addOrders(); 
	}
	
	private TestMethod static void testInitReportCtrl() {
		init('HO1');
		insertReportTypes();
		GNE_SFA2_PFG_Report_Filters_Ctrl ctrl;
		PageReference pRef; 
		Integer reportGroupSize, reportTypeSize; 
		System.runAs(GNE_SFA2_PFG_TestHelper.getCurrentUser()) {
			PageReference pageRef = Page.GNE_SFA2_PFG_Report_Filters;
			Test.setCurrentPage(pageRef);
        	Test.startTest();
        	ctrl = new GNE_SFA2_PFG_Report_Filters_Ctrl();
        	reportGroupSize = ctrl.reportGroups.size();
        	reportTypeSize = ctrl.reportTypes.size();
        	Test.stopTest();
		}
		
		System.assertEquals(null, pRef, 'PageRefernce should be null. PageRef: ' + (pRef!=null ? pRef.getUrl() : ''));
		System.assert(!ctrl.showResults, 'ctrl.showResults not false');
        System.assertEquals('', ctrl.transName,'ctrl.transName should not be set');
        System.assertNotEquals(null, ctrl.expirationDays, 'ctrl.expirationDays not set');
        System.assertNotEquals(null, ctrl.lotExpirationDate, 'ctrl.lotExpirationDate not set');
        System.assertNotEquals(null, ctrl.leftYearValues, 'ctrl.leftYearValues not set');
        System.assertNotEquals(null, ctrl.leftSelectedYears, 'ctrl.leftSelectedYears not set');
        System.assertNotEquals(null, ctrl.rightSelectedYears, 'ctrl.rightSelectedYears not set');
        System.assert(!ctrl.renderCsSelcetion, 'ctrl.renderCsSelcetion not false');
        System.assert(!ctrl.renderProdSelection, 'ctrl.renderProdSelection not false');
        System.assert(!ctrl.renderLotSelection, 'ctrl.renderLotSelection not false');
        System.assert(!ctrl.renderDateRangeSelection, 'ctrl.renderDateRangeSelection not false');
        System.assert(!ctrl.renderYearsSelection, 'ctrl.renderYearsSelection not false');
        System.assert(!ctrl.renderHcpSelection, 'ctrl.renderHcpSelection not false');
        System.assert(!ctrl.renderShipmentSelection, 'ctrl.renderShipmentSelection not false');
        System.assert(!ctrl.renderLotExp, 'ctrl.renderLotExp not false');
        System.assert(!ctrl.renderOrderId, 'ctrl.renderOrderId not false');
        System.assert(!ctrl.renderDateField, 'ctrl.renderDateField not false');
        System.assert(!ctrl.renderOrderIdSelection, 'ctrl.renderOrderIdSelection not false');
        System.assert(!ctrl.isProductSelectionRequired, 'ctrl.isProductSelectionRequired not false');
        System.assert(!ctrl.isYearPicklistRequired, 'ctrl.isYearPicklistRequired not false');
        System.assertNotEquals(null, ctrl.startDate, 'ctrl.startDate not set');
        System.assertNotEquals(null, ctrl.endDate, 'ctrl.endDate not set');
        System.assertNotEquals(null, ctrl.dateField, 'ctrl.dateField not set');
        System.assertNotEquals(null, ctrl.csIds, 'ctrl.csIds not set');
        System.assertNotEquals(null, ctrl.prodIds, 'ctrl.prodIds not set');
        System.assertNotEquals(null, ctrl.lotNOs, 'ctrl.lotNOs not set');
        System.assertNotEquals(null, ctrl.accIds, 'ctrl.accIds not set');
        System.assertNotEquals(null, ctrl.shpntIds, 'ctrl.shpntIds not set');
        System.assertNotEquals(null, ctrl.orderIds, 'ctrl.orderIds not set');
        System.assertNotEquals(null, ctrl.filteredCSc, 'ctrl.filteredCSc not set');
        System.assertNotEquals(null, ctrl.filteredProducts, 'ctrl.filteredProducts not set');
        System.assertNotEquals(null, ctrl.filteredLots, 'ctrl.filteredLots not set');
        System.assertNotEquals(null, ctrl.filteredAccounts, 'ctrl.filteredAccounts not set');
        System.assertNotEquals(null, ctrl.filteredShipments, 'ctrl.filteredShipments not set');
        System.assertNotEquals(null, ctrl.filteredOrders, 'ctrl.filteredOrders not set');
        System.assertEquals(0, ctrl.csElementsCount, 'ctrl.csElementsCount not 0');
        System.assertEquals(0, ctrl.prodElementsCount, 'ctrl.prodElementsCount not 0');
        System.assertEquals(0, ctrl.lotElementsCount, 'ctrl.lotElementsCount not 0');
        System.assertEquals(0, ctrl.accElementsCount, 'ctrl.accElementsCount not 0');
        System.assertEquals(0, ctrl.shpntElementsCount, 'ctrl.shpntElementsCount not 0');
        System.assertEquals(0, ctrl.orderElementsCount, 'ctrl.orderElementsCount not 0');
        
        System.assertEquals(2+1, reportGroupSize, 'Two Categories should be visisble + empty value. Available values: ' + String.valueOf(ctrl.reportGroups));
        System.assertEquals(1, reportTypeSize, 'No Record Types should be visible. Only empty value');
        System.assertEquals(4, ctrl.expirationOptions.size(), '4 Expiration Date options should be visible');
        System.assertEquals(ctrl.leftYearValues.size(), ctrl.getUnselectedYearValues().size(), 'Unselected Years should be the same as all avaialable Years');
        System.assertEquals(0, ctrl.getSelectedYearValues().size(), 'Selected Years should be empty');
        System.assertNotEquals(null, ctrl.getWorkbookProperties(), 'ctrl.WorkbookProperties should be set');
        System.assertEquals(null, ctrl.sortExpression, 'ctrl.sortField should be null');
        System.assertEquals('ASC', ctrl.getSortDirection(), 'Sort Direction should be ASC');
        ctrl.sortExpression = 'Name';
        ctrl.sortExpression = 'Name';
        ctrl.setSortDirection('DESC'); 
        System.assertEquals('DESC', ctrl.getSortDirection(), 'Sort Direction should be DESC (after switch)');
        System.assertEquals('Name', ctrl.sortExpression, 'ctrl.sortField should be set');
	}
	
	private TestMethod static void testRunAdjustmentReportNoRecords() {
		init('HO1');
		insertReportTypes();
		GNE_SFA2_PFG_Report_Filters_Ctrl ctrl;
		PageReference pRef;
		Integer reportTypeSize; 
		System.runAs(GNE_SFA2_PFG_TestHelper.getCurrentUser()) {
			PageReference pageRef = Page.GNE_SFA2_PFG_Report_Filters;
			Test.setCurrentPage(pageRef);
        	Test.startTest();
        	ctrl = new GNE_SFA2_PFG_Report_Filters_Ctrl();
        	ctrl.reportCategory = 'HC Reports';
        	ctrl.selectReportCategory();
        	reportTypeSize = ctrl.reportTypes.size();
        	ctrl.reportType = GNE_SFA2_PFG_Reports_Helper.REPORT_TYPE_ADJUSTEMNTS;
        	ctrl.reportTypeSelect();
        	pRef = ctrl.runReport();
        	Test.stopTest();
		}
		
		System.assertNotEquals(null, pRef, 'PageRefernce should be set. PageRef: ' + (pRef!=null ? pRef.getUrl() : ''));
		System.assertEquals('/apex/GNE_SFA2_PFG_ReportDisplay', pRef.getUrl(), 'Wrong PageReference'); 
		System.assertEquals(0, ctrl.reportRows.size(), 'Report Rows should be empty');
		System.assertEquals(0, GNE_SFA2_PFG_TestHelper.getPageMessages().size(), 'Page Messages should be empty');
		System.assertEquals([SELECT count() FROM SFA2_PFG_Report_Types_gne__c WHERE Report_Category_gne__c = :ctrl.reportCategory] + 1, reportTypeSize, 'Record Types should be visible.');
	}
	
	private TestMethod static void testAddAndRemoveFilters() {
		init('HO1');
		insertReportTypes();
		GNE_SFA2_PFG_TestHelper.accountHelper.insertAccountsWithAddresses(1);
		String rtName = GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ORDER;
		GNE_SFA2_PFG_Report_Filters_Ctrl ctrl;
		System.runAs(GNE_SFA2_PFG_TestHelper.getCurrentUser()) {
			List<SFA2_PFG_Transaction_gne__c> trxs = GNE_SFA2_PFG_TestHelper.insertTrxRecords(2, rtName, false, null, 'CS1');
			Set<Id> orderIds = new Set<Id>();
			Set<String> shipmentIds = new Set<String>();
			for(SFA2_PFG_Transaction_gne__c trx : trxs) {
				orderIds.add(trx.Id);
				trx.Shipped_Date_gne__c = System.today().addDays(1);
				trx.Shipment_Id_gne__c = 'TEST SHIPMENT ID';
				trx.Received_Quantity_gne__c = null;
				shipmentIds.add(trx.Shipment_Id_gne__c);
			}
			update trxs;
			
			PageReference pageRef = Page.GNE_SFA2_PFG_Report_Filters;
			Test.setCurrentPage(pageRef);
        	Test.startTest();
        	ctrl = new GNE_SFA2_PFG_Report_Filters_Ctrl();
        	ctrl.reportCategory = 'HC Reports';
        	ctrl.selectReportCategory();
        	ctrl.reportType = GNE_SFA2_PFG_Reports_Helper.REPORT_TYPE_ADJUSTEMNTS;
        	ctrl.reportTypeSelect();
        	setFilters(ctrl, orderIds, shipmentIds);
        	ctrl.rightSelectedYears.add(String.valueOf(System.today().year()));
			ctrl.unselectProductClick();
        	ctrl.csIndex = 0;
        	ctrl.removeCS();
        	ctrl.prodIndex = 0;
        	ctrl.removeProduct();
        	ctrl.lotIndex = 0;
        	ctrl.removeLot();
        	ctrl.accIndex = 0;
        	ctrl.removeAcc();
        	ctrl.shpntIndex = 0;
        	ctrl.removeShipment();
        	ctrl.orderIndex = 0;
        	ctrl.removeOrder();
        	
        	ctrl.removeAllCSs();
        	ctrl.removeAllProducts();
        	ctrl.removeAllLots();
        	ctrl.removeAllAccounts();
        	ctrl.removeAllShipments();
        	ctrl.removeAllOrders();
        	Test.stopTest();
		}
		
		System.assertEquals(0, ctrl.filteredCSc.size(), 'ctrl.filteredCSc should be empty');
		System.assertEquals(0, ctrl.filteredProducts.size(), 'ctrl.filteredProducts should be empty');
		System.assertEquals(0, ctrl.filteredLots.size(), 'ctrl.filteredLots should be empty');
		System.assertEquals(0, ctrl.filteredAccounts.size(), 'ctrl.filteredAccounts should be empty');
		System.assertEquals(0, ctrl.filteredShipments.size(), 'ctrl.filteredShipments should be empty');
		System.assertEquals(0, ctrl.filteredOrders.size(), 'ctrl.filteredOrders should be empty');
	}
	
	private TestMethod static void testRunAdjustmentReport() {
		init('HO1');
		insertReportTypes();
		String rtName = GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ADJUSTMENT;
		GNE_SFA2_PFG_Report_Filters_Ctrl ctrl;
		PageReference pRef, pRefCancel, pRefBack, pRefExcel, pRefPdf;
		List<SFA2_PFG_Transaction_gne__c> trxs; 
		System.runAs(GNE_SFA2_PFG_TestHelper.getCurrentUser()) {
			trxs = GNE_SFA2_PFG_TestHelper.insertTrxRecords(2, rtName, false, 'CS1', 'CS2');
			PageReference pageRef = Page.GNE_SFA2_PFG_Report_Filters;
			Test.setCurrentPage(pageRef);
        	Test.startTest();
        	ctrl = new GNE_SFA2_PFG_Report_Filters_Ctrl();
        	ctrl.reportCategory = 'HC Reports';
        	ctrl.selectReportCategory();
        	ctrl.reportType = GNE_SFA2_PFG_Reports_Helper.REPORT_TYPE_ADJUSTEMNTS;
        	ctrl.reportTypeSelect();
        	ctrl.endDate = String.valueOf(DateTime.now().addDays(10).format('MM/dd/yyyy'));
        	pRef = ctrl.runReport();
        	pRefCancel = ctrl.cancel();
        	pRefBack = ctrl.goBack();
        	pRefExcel = ctrl.exportToExcel();
        	pRefPdf = ctrl.printReport();
        	Test.stopTest();
		}
		
		List<String> pageMgs = GNE_SFA2_PFG_TestHelper.getPageMessages();
		System.assertNotEquals(null, pRef, 'PageRefernce should be set. PageRef: ' + (pRef!=null ? pRef.getUrl() : ''));
		System.assertEquals('/apex/GNE_SFA2_PFG_ReportDisplay', pRef.getUrl(), 'Wrong PageReference');
		System.assertEquals(0, pageMgs.size(), 'Page Messages should be empty: ' + String.join(pageMgs,'\n'));
		System.assertEquals(trxs.size(), ctrl.reportRows.size(), 'Report Rows should be empty');
		
		System.assertNotEquals(null, pRefCancel, 'Cancel PageRefernce should be set. PageRef: ' + (pRefCancel!=null ? pRefCancel.getUrl() : ''));
		System.assertEquals('/apex/GNE_SFA2_PFG_MyPFG', pRefCancel.getUrl(), 'Wrong Cancel PageReference');
		System.assertNotEquals(null, pRefBack, 'Go Back PageRefernce should be set. PageRef: ' + (pRefBack!=null ? pRefBack.getUrl() : ''));
		System.assertEquals('/apex/GNE_SFA2_PFG_Report_Filters', pRefBack.getUrl(), 'Wrong Go Back PageReference');
		System.assertNotEquals(null, pRefExcel, 'Export To Excel PageRefernce should be set. PageRef: ' + (pRefExcel!=null ? pRefExcel.getUrl() : ''));
		System.assertEquals('/apex/GNE_SFA2_PFG_ReportExportToExcel', pRefExcel.getUrl(), 'Wrong Export To Excel PageReference');
		System.assertNotEquals(null, pRefPdf, 'Print Report PageRefernce should be set. PageRef: ' + (pRefPdf!=null ? pRefPdf.getUrl() : ''));
		System.assertEquals('/apex/GNE_SFA2_PFG_ReportPrint', pRefPdf.getUrl(), 'Wrong Print Report PageReference');
	}
	
	private TestMethod static void testRunAdjustmentReportWithFilters() {
		init('HO1');
		insertReportTypes();
		String rtName = GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ADJUSTMENT;
		GNE_SFA2_PFG_Report_Filters_Ctrl ctrl;
		PageReference pRef;
		List<SFA2_PFG_Transaction_gne__c> trxs; 
		System.runAs(GNE_SFA2_PFG_TestHelper.getCurrentUser()) {
			trxs = GNE_SFA2_PFG_TestHelper.insertTrxRecords(2, rtName, false, 'CS1', 'CS2');
			PageReference pageRef = Page.GNE_SFA2_PFG_Report_Filters;
			Test.setCurrentPage(pageRef);
        	Test.startTest();
        	ctrl = new GNE_SFA2_PFG_Report_Filters_Ctrl();
        	ctrl.reportCategory = 'HC Reports';
        	ctrl.selectReportCategory();
        	ctrl.reportType = GNE_SFA2_PFG_Reports_Helper.REPORT_TYPE_ADJUSTEMNTS;
        	ctrl.reportTypeSelect();
        	ctrl.endDate = String.valueOf(DateTime.now().addDays(10).format('MM/dd/yyyy'));
        	setFilters(ctrl);
        	pRef = ctrl.runReport();
        	Test.stopTest();
		}
		
		List<String> pageMgs = GNE_SFA2_PFG_TestHelper.getPageMessages();
		System.assertNotEquals(null, pRef, 'PageRefernce should be set. PageRef: ' + (pRef!=null ? pRef.getUrl() : ''));
		System.assertEquals('/apex/GNE_SFA2_PFG_ReportDisplay', pRef.getUrl(), 'Wrong PageReference');
		System.assertEquals(0, pageMgs.size(), 'Page Messages should be empty: ' + String.join(pageMgs,'\n'));
		System.assertEquals(trxs.size(), ctrl.reportRows.size(), 'Report Rows should not be empty');
		
	}
	
	private TestMethod static void testRunHcExceptionReportWithFilters() {
		init('HO1');
		insertReportTypes();
		String rtName = GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ORDER;
		GNE_SFA2_PFG_Report_Filters_Ctrl ctrl;
		PageReference pRef;
		List<SFA2_PFG_Transaction_gne__c> trxs; 
		System.runAs(GNE_SFA2_PFG_TestHelper.getCurrentUser()) {
			trxs = GNE_SFA2_PFG_TestHelper.insertTrxRecords(2, rtName, false, null, 'CS1');
			PageReference pageRef = Page.GNE_SFA2_PFG_Report_Filters;
			Test.setCurrentPage(pageRef);
        	Test.startTest();
        	ctrl = new GNE_SFA2_PFG_Report_Filters_Ctrl();
        	ctrl.reportCategory = 'HC Reports';
        	ctrl.selectReportCategory();
        	ctrl.reportType = GNE_SFA2_PFG_Reports_Helper.REPORT_TYPE_HC_EXCEPTION;
        	ctrl.reportTypeSelect();
        	//ctrl.dateField = String.valueOf(DateTime.now().addDays(10).format('MM/dd/yyyy'));
        	setFilters(ctrl);
        	pRef = ctrl.runReport();
        	Test.stopTest();
		}
		
		List<String> pageMgs = GNE_SFA2_PFG_TestHelper.getPageMessages();
		System.assertNotEquals(null, pRef, 'PageRefernce should be set. PageRef: ' + (pRef!=null ? pRef.getUrl() : ''));
		System.assertEquals('/apex/GNE_SFA2_PFG_ReportDisplay', pRef.getUrl(), 'Wrong PageReference');
		System.assertEquals(0, pageMgs.size(), 'Page Messages should be empty: ' + String.join(pageMgs,'\n'));
		System.assertEquals(trxs.size(), ctrl.reportRows.size(), 'Report Rows should not be empty');
	}
	
	private TestMethod static void testRunUnacknowledgedShipmentsReportWithFilters() {
		init('HO1');
		insertReportTypes();
		String rtName = GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ORDER;
		GNE_SFA2_PFG_Report_Filters_Ctrl ctrl;
		PageReference pRef;
		List<SFA2_PFG_Transaction_gne__c> trxs; 
		System.runAs(GNE_SFA2_PFG_TestHelper.getCurrentUser()) {
			trxs = GNE_SFA2_PFG_TestHelper.insertTrxRecords(2, rtName, false, null, 'CS1');
			Set<Id> orderIds = new Set<Id>();
			Set<String> shipmentIds = new Set<String>();
			for(SFA2_PFG_Transaction_gne__c trx : trxs) {
				orderIds.add(trx.Id);
				trx.Shipped_Date_gne__c = System.today().addDays(1);
				trx.Shipment_Id_gne__c = 'TEST SHIPMENT ID';
				trx.Received_Quantity_gne__c = null;
				shipmentIds.add(trx.Shipment_Id_gne__c);
			}
			update trxs;
			
			PageReference pageRef = Page.GNE_SFA2_PFG_Report_Filters;
			Test.setCurrentPage(pageRef);
        	Test.startTest();
        	ctrl = new GNE_SFA2_PFG_Report_Filters_Ctrl();
        	ctrl.reportCategory = 'HC Reports';
        	ctrl.selectReportCategory();
        	ctrl.reportType = GNE_SFA2_PFG_Reports_Helper.REPORT_TYPE_UNACKNOWLEDGED_SHIPMENTS;
        	ctrl.reportTypeSelect();
        	//ctrl.dateField = String.valueOf(DateTime.now().addDays(10).format('MM/dd/yyyy'));
        	setFilters(ctrl, orderIds, shipmentIds);
        	pRef = ctrl.runReport();
        	Test.stopTest();
		}
		
		List<String> pageMgs = GNE_SFA2_PFG_TestHelper.getPageMessages();
		System.assertNotEquals(null, pRef, 'PageRefernce should be set. PageRef: ' + (pRef!=null ? pRef.getUrl() : ''));
		System.assertEquals('/apex/GNE_SFA2_PFG_ReportDisplay', pRef.getUrl(), 'Wrong PageReference');
		System.assertEquals(0, pageMgs.size(), 'Page Messages should be empty: ' + String.join(pageMgs,'\n'));
		System.assertEquals(trxs.size(), ctrl.reportRows.size(), 'Report Rows should not be empty');
	}
	
	private TestMethod static void testRunDisbursementReportWithFilters() {
		init('HO1');
		insertReportTypes();
		GNE_SFA2_PFG_TestHelper.accountHelper.insertAccountsWithAddresses(1);
		String rtName = GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_DISBURSEMENT;
		GNE_SFA2_PFG_Report_Filters_Ctrl ctrl;
		PageReference pRef;
		List<SFA2_PFG_Transaction_gne__c> trxs;
		 
		System.runAs(GNE_SFA2_PFG_TestHelper.getCurrentUser()) {
			trxs = GNE_SFA2_PFG_TestHelper.insertTrxRecords(2, rtName, false, 'CS1', null);
			PageReference pageRef = Page.GNE_SFA2_PFG_Report_Filters;
			Test.setCurrentPage(pageRef);
        	Test.startTest();
        	ctrl = new GNE_SFA2_PFG_Report_Filters_Ctrl();
        	ctrl.reportCategory = 'HC Reports';
        	ctrl.selectReportCategory();
        	ctrl.reportType = GNE_SFA2_PFG_Reports_Helper.REPORT_TYPE_DISBURSEMENTS;
        	ctrl.reportTypeSelect();
        	setFilters(ctrl);
        	pRef = ctrl.runReport();
        	Test.stopTest();
		}
		
		List<String> pageMgs = GNE_SFA2_PFG_TestHelper.getPageMessages();
		System.assertNotEquals(null, pRef, 'PageRefernce should be set. PageRef: ' + (pRef!=null ? pRef.getUrl() : ''));
		System.assertEquals('/apex/GNE_SFA2_PFG_ReportDisplay', pRef.getUrl(), 'Wrong PageReference');
		System.assertEquals(0, pageMgs.size(), 'Page Messages should be empty: ' + String.join(pageMgs,'\n'));
		System.assertEquals(trxs.size(), ctrl.reportRows.size(), 'Report Rows should not be empty');
	}
	
	private TestMethod static void testRunReturnsReportWithFilters() {
		init('HO1');
		insertReportTypes();
		GNE_SFA2_PFG_TestHelper.insertVendor();
		String rtName = GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RETURN;
		GNE_SFA2_PFG_Report_Filters_Ctrl ctrl;
		PageReference pRef;
		List<SFA2_PFG_Transaction_gne__c> trxs;
		 
		System.runAs(GNE_SFA2_PFG_TestHelper.getCurrentUser()) {
			trxs = GNE_SFA2_PFG_TestHelper.insertTrxRecords(2, rtName, false, 'CS1', null);
			PageReference pageRef = Page.GNE_SFA2_PFG_Report_Filters;
			Test.setCurrentPage(pageRef);
        	Test.startTest();
        	ctrl = new GNE_SFA2_PFG_Report_Filters_Ctrl();
        	ctrl.reportCategory = 'HC Reports';
        	ctrl.selectReportCategory();
        	ctrl.reportType = GNE_SFA2_PFG_Reports_Helper.REPORT_TYPE_RETURNS;
        	ctrl.reportTypeSelect();
        	setFilters(ctrl);
        	pRef = ctrl.runReport();
        	Test.stopTest();
		}
		
		List<String> pageMgs = GNE_SFA2_PFG_TestHelper.getPageMessages();
		System.assertNotEquals(null, pRef, 'PageRefernce should be set. PageRef: ' + (pRef!=null ? pRef.getUrl() : ''));
		System.assertEquals('/apex/GNE_SFA2_PFG_ReportDisplay', pRef.getUrl(), 'Wrong PageReference');
		System.assertEquals(0, pageMgs.size(), 'Page Messages should be empty: ' + String.join(pageMgs,'\n'));
		System.assertEquals(trxs.size(), ctrl.reportRows.size(), 'Report Rows should not be empty');
	}
	
	private TestMethod static void testRunLotExpirationReportWithFilters() {
		init('CS1');
		insertReportTypes();
		GNE_SFA2_PFG_TestHelper.insertVendor();
		GNE_SFA2_PFG_Report_Filters_Ctrl ctrl;
		PageReference pRef;

		System.runAs(GNE_SFA2_PFG_TestHelper.getCurrentUser()) {
			List<SFA2_PFG_Inventory_Count_gne__c> invs = GNE_SFA2_PFG_TestHelper.insertInventoryCounts(2, new Set<String>{'CS1'});
			for(SFA2_PFG_Inventory_Count_gne__c inv : invs) {
				inv.Expiration_Date_gne__c = System.today().addDays(1);
			}
			update invs;

			PageReference pageRef = Page.GNE_SFA2_PFG_Report_Filters;
			Test.setCurrentPage(pageRef);
        	Test.startTest();
        	ctrl = new GNE_SFA2_PFG_Report_Filters_Ctrl();
        	ctrl.reportCategory = 'HC Reports';
        	ctrl.selectReportCategory();
        	ctrl.reportType = GNE_SFA2_PFG_Reports_Helper.REPORT_TYPE_LOT_EXPIRATION;
        	ctrl.reportTypeSelect();
        	setFilters(ctrl);
        	pRef = ctrl.runReport();
        	Test.stopTest();
        	System.assertEquals(invs.size(), ctrl.reportRows.size(), 'Report Rows should not be empty');
		}
		
		List<String> pageMgs = GNE_SFA2_PFG_TestHelper.getPageMessages();
		System.assertNotEquals(null, pRef, 'PageRefernce should be set. PageRef: ' + (pRef!=null ? pRef.getUrl() : ''));
		System.assertEquals('/apex/GNE_SFA2_PFG_ReportDisplay', pRef.getUrl(), 'Wrong PageReference');
		System.assertEquals(0, pageMgs.size(), 'Page Messages should be empty: ' + String.join(pageMgs,'\n'));

	}
	
	private TestMethod static void testRunHcQtyLimitHistoryReportWithFilters() {
		init('HO1');
		insertReportTypes();
		GNE_SFA2_PFG_TestHelper.accountHelper.insertAccountsWithAddresses(1);
		GNE_SFA2_PFG_TestHelper.insertAccQtyLimits();
		GNE_SFA2_PFG_Report_Filters_Ctrl ctrl;
		PageReference pRef;
		 
		System.runAs(GNE_SFA2_PFG_TestHelper.getCurrentUser()) {
			PageReference pageRef = Page.GNE_SFA2_PFG_Report_Filters;
			Test.setCurrentPage(pageRef);
        	Test.startTest();
        	ctrl = new GNE_SFA2_PFG_Report_Filters_Ctrl();
        	ctrl.reportCategory = 'HC Reports';
        	ctrl.selectReportCategory();
        	ctrl.reportType = GNE_SFA2_PFG_Reports_Helper.REPORT_TYPE_QTY_LMT_CHG_HISTORY;
        	ctrl.reportTypeSelect();
        	setFilters(ctrl);
        	ctrl.removeAllLots();
        	pRef = ctrl.runReport();
        	Test.stopTest();
		}
		
		List<String> pageMgs = GNE_SFA2_PFG_TestHelper.getPageMessages();
		System.assertNotEquals(null, pRef, 'PageRefernce should be set. PageRef: ' + (pRef!=null ? pRef.getUrl() : ''));
		System.assertEquals('/apex/GNE_SFA2_PFG_ReportDisplay', pRef.getUrl(), 'Wrong PageReference');
		System.assertEquals(0, pageMgs.size(), 'Page Messages should be empty: ' + String.join(pageMgs,'\n'));
		System.assertEquals(0, ctrl.reportRows.size(), 'Report Rows should not be empty');
	}
	
	private TestMethod static void testRunDtpExceptionsReportWithFilters() {
		init('HO1');
		insertReportTypes();
		GNE_SFA2_PFG_TestHelper.accountHelper.insertAccountsWithAddresses(1);
		String rtName = GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RFF;
		GNE_SFA2_PFG_Report_Filters_Ctrl ctrl;
		PageReference pRef;
		List<SFA2_PFG_Transaction_gne__c> trxs;
		 
		System.runAs(GNE_SFA2_PFG_TestHelper.getCurrentUser()) {
			trxs = GNE_SFA2_PFG_TestHelper.insertTrxRecords(2, rtName, true, 'CS1', null);
			for(SFA2_PFG_Transaction_gne__c trx : trxs) {
				trx.Delivery_Status_gne__c = null;
			}
			update trxs;
			
			PageReference pageRef = Page.GNE_SFA2_PFG_Report_Filters;
			Test.setCurrentPage(pageRef);
        	Test.startTest();
        	ctrl = new GNE_SFA2_PFG_Report_Filters_Ctrl();
        	ctrl.reportCategory = 'DTP Reports';
        	ctrl.selectReportCategory();
        	ctrl.reportType = GNE_SFA2_PFG_Reports_Helper.REPORT_TYPE_DTP_EXCEPTION;
        	ctrl.reportTypeSelect();
        	setFilters(ctrl);
        	pRef = ctrl.runReport();
        	Test.stopTest();
		}
		
		List<String> pageMgs = GNE_SFA2_PFG_TestHelper.getPageMessages();
		System.assertNotEquals(null, pRef, 'PageRefernce should be set. PageRef: ' + (pRef!=null ? pRef.getUrl() : ''));
		System.assertEquals('/apex/GNE_SFA2_PFG_ReportDisplay', pRef.getUrl(), 'Wrong PageReference');
		System.assertEquals(0, pageMgs.size(), 'Page Messages should be empty: ' + String.join(pageMgs,'\n'));
		System.assertEquals(trxs.size(), ctrl.reportRows.size(), 'Report Rows should not be empty');
	}
	
	private TestMethod static void testRunDtpOutstandingAOCReportWithFilters() {
		init('HO1');
		insertReportTypes();
		GNE_SFA2_PFG_TestHelper.accountHelper.insertAccountsWithAddresses(1);
		String rtName = GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RFF;
		GNE_SFA2_PFG_Report_Filters_Ctrl ctrl;
		PageReference pRef;
		List<SFA2_PFG_Transaction_gne__c> trxs;
		 
		System.runAs(GNE_SFA2_PFG_TestHelper.getCurrentUser()) {
			trxs = GNE_SFA2_PFG_TestHelper.insertTrxRecords(2, rtName, true, 'CS1', null);
			PageReference pageRef = Page.GNE_SFA2_PFG_Report_Filters;
			Test.setCurrentPage(pageRef);
        	Test.startTest();
        	ctrl = new GNE_SFA2_PFG_Report_Filters_Ctrl();
        	ctrl.reportCategory = 'DTP Reports';
        	ctrl.selectReportCategory();
        	ctrl.reportType = GNE_SFA2_PFG_Reports_Helper.REPORT_TYPE_OUTSTANDING_AOC;
        	ctrl.reportTypeSelect();
        	setFilters(ctrl);
        	ctrl.removeAllLots();
        	pRef = ctrl.runReport();
        	Test.stopTest();
		}
		
		List<String> pageMgs = GNE_SFA2_PFG_TestHelper.getPageMessages();
		System.assertNotEquals(null, pRef, 'PageRefernce should be set. PageRef: ' + (pRef!=null ? pRef.getUrl() : ''));
		System.assertEquals('/apex/GNE_SFA2_PFG_ReportDisplay', pRef.getUrl(), 'Wrong PageReference');
		System.assertEquals(0, pageMgs.size(), 'Page Messages should be empty: ' + String.join(pageMgs,'\n'));
		System.assertEquals(trxs.size(), ctrl.reportRows.size(), 'Report Rows should not be empty');
	}
	
	private TestMethod static void testRunDtpQtyLimitHistoryReportWithFilters() {
		init('HO1');
		insertReportTypes();
		GNE_SFA2_PFG_TestHelper.accountHelper.insertAccountsWithAddresses(1);
		GNE_SFA2_PFG_TestHelper.insertAccQtyLimits();
		GNE_SFA2_PFG_Report_Filters_Ctrl ctrl;
		PageReference pRef;
		 
		System.runAs(GNE_SFA2_PFG_TestHelper.getCurrentUser()) {
			PageReference pageRef = Page.GNE_SFA2_PFG_Report_Filters;
			Test.setCurrentPage(pageRef);
        	Test.startTest();
        	ctrl = new GNE_SFA2_PFG_Report_Filters_Ctrl();
        	ctrl.reportCategory = 'HC Reports';
        	ctrl.selectReportCategory();
        	ctrl.reportType = GNE_SFA2_PFG_Reports_Helper.REPORT_TYPE_QTY_LMT_CHG_HISTORY_DTP;
        	ctrl.reportTypeSelect();
        	setFilters(ctrl);
        	ctrl.removeAllLots();
        	pRef = ctrl.runReport();
        	Test.stopTest();
		}
		
		List<String> pageMgs = GNE_SFA2_PFG_TestHelper.getPageMessages();
		System.assertNotEquals(null, pRef, 'PageRefernce should be set. PageRef: ' + (pRef!=null ? pRef.getUrl() : ''));
		System.assertEquals('/apex/GNE_SFA2_PFG_ReportDisplay', pRef.getUrl(), 'Wrong PageReference');
		System.assertEquals(0, pageMgs.size(), 'Page Messages should be empty: ' + String.join(pageMgs,'\n'));
		System.assertEquals(0, ctrl.reportRows.size(), 'Report Rows should not be empty');
	}
	
}