@isTest
public with sharing class GNE_SFA2_PFG_DtpAoc_Test {

	private enum AocWorkflowStatus {COMPLETED, SHIPPED, AOC_COMPLETED, ORDER_STATUS, CANCELLED, AOC_STATUS, TERRITORY_QTY_REACHED, PAPER_ORDER}
	private static final String REQUEST_SIGNATURE_VALUE = 'REQUEST SIGNATURE';
	private static final String AOC_SIGNATURE_VALUE = 'AOC SIGNATURE';
	private static final String LOT_NO_VALUE = 'DTP-LOT-001';
	private static final String REST_DATE_TIME_FORMAT = 'yyyy-MM-dd hh:mm:ss.S';
	private static final String SIGNATURE_PENDING_STATUS = 'P';
	private static final String SIGNATURE_COMPLETE_STATUS = 'C';
	private static final String SHIPMENT_VALUE = 'SPT-0001';
	private static final String PICK_NUMBER_VALUE = 'PSN-001';
	private static final String ORDER_STATUS_CANCELLED_NOTES = 'Order Cancelled in Warehouse';
	private static final String ORDER_STATUS_REJECTED_NOTES = 'Judged ineligible; unfound state license credentials';
	private static final String ORDER_STATUS_SHIPPED = 'Shipped';
	private static final String ORDER_STATUS_SHIPPED_NOTES = 'Order Shipped';
	private static final String PAPER_ORDER_ID = 'ORDID-0001';
    private static final String PAPER_LINE_ITEM_ID = 'PRODLN-000';
    private static final String FACILITY_NAME = 'TEST FACILITY NAME';
    private static final String SLN = 'J6868';
    private static final String DESIGNATION = 'MD';

	private static Map<String,SFA2_PFG_Transaction_gne__c> trxCache;
	private static Map<String,SFA2_PFG_Transaction_gne__c> trxByNameCache;
	private static Map<String,List<SFA2_PFG_Transaction_gne__c>> trxByRefNoCache;

	private static AccountTestHelper accountTestHelper;
	private static VeQtyChecker veQtyChecker;

	public static TestMethod void testAocWorkflowCompleted() {
		intTestAocWorkflow(0,0,true, true);
	}

	public static TestMethod void testShippmentWithDifferentQty() {
		intTestAocWorkflow(1,0,false, true);
	}

	public static TestMethod void testAocCompleteWithDifferentQty() {
		intTestAocWorkflow(1, 1, true, true);
	}

	public static TestMethod void testTerritoryQtyLimitReached() {
		User u = prepareEnv('CS1');

		List<SFA2_PFG_to_Territory_Detail_gne__c> tDetails = [SELECT Qty_Total_Available_gne__c, Qty_Shipped_to_Physician_gne__c FROM SFA2_PFG_to_Territory_Detail_gne__c];
		List<SFA2_PFG_to_Territory_Detail_gne__c> tDetailsToRevert = new List<SFA2_PFG_to_Territory_Detail_gne__c>();

		for(SFA2_PFG_to_Territory_Detail_gne__c tDetail : tDetails) {
			tDetailsToRevert.add(new SFA2_PFG_to_Territory_Detail_gne__c(Id = tDetail.Id, Qty_Shipped_to_Physician_gne__c = tDetail.Qty_Shipped_to_Physician_gne__c));
			tDetail.Qty_Shipped_to_Physician_gne__c += tDetail.Qty_Total_Available_gne__c;
		}

		update tDetails;

		iPhoneApex_2.CallAttributes cAttrs = createTestCallAttrs(u);
		GNE_SFA2_PFG_TestHelper.clearPFGCache();
		iPhoneApex_2.Response wsResult;

		Test.startTest();

		System.runAs(u) {
			wsResult = iPhoneApex_2.updateOrCreateCall(cAttrs);
		}

		Test.stopTest();

		update tDetailsToRevert;

		cacheTransactions(cAttrs.RequestId);
		assertOrderTransactions(cAttrs, null, null, null, null, AocWorkflowStatus.TERRITORY_QTY_REACHED);
		veQtyChecker.assertQty(true);
	}

	public static TestMethod void testAocWorkflowAocStatusPending() {
		intTestAocWorkflow(0, 0, false, false, false, true, null, null);
	}

	public static TestMethod void testAocWorkflowAocStatusComplete() {
		intTestAocWorkflow(0, 0, true, true, false, true, null, null);
	}

	public static TestMethod void testAocWorkflowCancelled() {
		intTestAocWorkflow(0, 1, false, false, true, false, GNE_SFA2_PFG_Util.TRANSACTION_DELIVERY_CANCELLED, ORDER_STATUS_CANCELLED_NOTES);
	}

	public static TestMethod void testAocWorkflowRejected() {
		intTestAocWorkflow(0, 1, false, false, true, false, GNE_SFA2_PFG_Util.TRANSACTION_DELIVERY_REJECTED, ORDER_STATUS_REJECTED_NOTES);
	}

	public static TestMethod void testAllocationTrasferRestInterfaceDeltaMode() {
		User u = prepareEnv('CS1');
		GNE_SFA2_PFG_TestHelper.clearPFGCache();
		GNE_SFA2_PFG_REST_DTP_AllocTransfers.ResultSet restResult = GNE_SFA2_PFG_REST_DTP_AllocTransfers.getDtpAllocationTransfers(
				String.valueOf(System.now().addDays(-1)), null);

		System.assertEquals(2, restResult.records.size(), 'DTP Allocation Transfer Outbount interface returns wrong number of records');
	}

	public static TestMethod void testAllocationTrasferRestInterfaceRecMode() {
		User u = prepareEnv('CS1');
		GNE_SFA2_PFG_TestHelper.clearPFGCache();
		Id trxId = GNE_SFA2_PFG_TestHelper.allocTransfersCache.get('DM1:CS1:DTP1').Id;
		GNE_SFA2_PFG_REST_DTP_AllocTransfers.ResultSet restResult = GNE_SFA2_PFG_REST_DTP_AllocTransfers.getDtpAllocationTransfers(
				String.valueOf(System.now().addDays(-1)), new List<String>{[SELECT Name FROM SFA2_PFG_Transaction_gne__c WHERE Id = :trxId].Name});

		System.assertEquals(1, restResult.records.size(), 'DTP Allocation Transfer Outbount interface returns wrong number of records');
	}

	public static TestMethod void testOrdersRestInterfaceDeltaMode() {
		intTestAocWorkflow(0, 0, false, false);
		GNE_SFA2_PFG_TestHelper.clearPFGCache();
		GNE_SFA2_PFG_REST_DTP_Orders.ResultSet restResult = GNE_SFA2_PFG_REST_DTP_Orders.getOrders(
				String.valueOf(System.now().addDays(-1)), null);

		System.assertEquals(2, restResult.records.size(),
				'DTP Orders Outbount interface returns wrong number of records');
	}

	public static TestMethod void testOrdersRestInterfaceRecMode() {
		intTestAocWorkflow(0, 0, false, false);
		GNE_SFA2_PFG_TestHelper.clearPFGCache();
		Call2_vod__c c = [SELECT Name FROM CAll2_vod__c WHERE Parent_Call_vod__c = null][0];

		GNE_SFA2_PFG_REST_DTP_Orders.ResultSet restResult = GNE_SFA2_PFG_REST_DTP_Orders.getOrders(
				String.valueOf(System.now().addDays(-1)), new List<String>{c.Name});

		System.assertEquals(2, restResult.records.size(),
				'DTP Orders Outbount interface returns wrong number of records');
	}

	public static TestMethod void testOrdersRestInterfaceRefejectedCall() {
		testTerritoryQtyLimitReached();
		GNE_SFA2_PFG_TestHelper.clearPFGCache();
		GNE_SFA2_PFG_REST_DTP_Orders.ResultSet restResult = GNE_SFA2_PFG_REST_DTP_Orders.getOrders(
				String.valueOf(System.now().addDays(-1)), null);

		System.assertEquals(0, restResult.records.size(),
				'DTP Orders Outbount interface returns wrong number of records');
	}

	public static TestMethod void testAocSignaturesRestInterfaceDeltaMode() {
		intTestAocWorkflow(0, 0, true, true);
		GNE_SFA2_PFG_TestHelper.clearPFGCache();
		GNE_SFA2_PFG_REST_DTP_AOC_Signatures.ResultSet restResult = GNE_SFA2_PFG_REST_DTP_AOC_Signatures.getAocSignatures(
				String.valueOf(System.now().addDays(-1)), null);

		System.assertEquals(1, restResult.records.size(),
				'DTP AOC Signatures Outbount interface returns wrong number of records');
	}

	public static TestMethod void testAocSignaturesRestInterfaceRecMode() {
		intTestAocWorkflow(0, 0, true, true);
		GNE_SFA2_PFG_TestHelper.clearPFGCache();
		Call2_vod__c c = [SELECT Name FROM CAll2_vod__c WHERE Parent_Call_vod__c = null][0];
		GNE_SFA2_PFG_REST_DTP_AOC_Signatures.ResultSet restResult = GNE_SFA2_PFG_REST_DTP_AOC_Signatures.getAocSignatures(
				String.valueOf(System.now().addDays(-1)), new List<String>{c.Name});

		System.assertEquals(1, restResult.records.size(),
				'DTP AOC Signatures Outbount interface returns wrong number of records');
	}

	public static TestMethod void testPaperOrderMissingMandatoryField() {
		List<GNE_SFA2_PFG_REST_DTP_Paper_Order.DtpPaperOrder> paperOrdersData = preparePaperOrderData();

		for(GNE_SFA2_PFG_REST_DTP_Paper_Order.DtpPaperOrder paperOrder : paperOrdersData) {
			paperOrder.Txn_ID = null;
			paperOrder.Terr_No = '';
		}

		Test.startTest();
		GNE_SFA2_PFG_REST_DTP_Paper_Order.ResultSet paperOrderResult = executePaperOrder(paperOrdersData);
		Test.stopTest();

		System.assertNotEquals(null, paperOrderResult.error, 'Error should be reported');
		System.assert(paperOrderResult.error.message.contains(String.format(System.Label.GNE_SFA2_PFG_REST_PAPER_ORDER_REQUIRED_FIELD, new String[]{'Txn_ID', null})), 'Error for Txn_ID attribute should be reported');
		System.assert(paperOrderResult.error.message.contains(String.format(System.Label.GNE_SFA2_PFG_REST_PAPER_ORDER_REQUIRED_FIELD, new String[]{'Terr_No', ''})), 'Error for Terr_No attribute should be reported');
		System.assertEquals(0, [SELECT count() FROM SFA2_PFG_Transaction_gne__c WHERE RecordType.Name = :GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_DTP_PAPER_ORDER], 'DTP Paper Orders should not be created');
	}

	public static TestMethod void testPaperOrderMissingTerritory() {
		List<GNE_SFA2_PFG_REST_DTP_Paper_Order.DtpPaperOrder> paperOrdersData = preparePaperOrderData();

		for(GNE_SFA2_PFG_REST_DTP_Paper_Order.DtpPaperOrder paperOrder : paperOrdersData) {
			paperOrder.Terr_No = 'WRONG_NO';
			break;
		}

		Test.startTest();
		GNE_SFA2_PFG_REST_DTP_Paper_Order.ResultSet paperOrderResult = executePaperOrder(paperOrdersData);
		Test.stopTest();

		System.assertNotEquals(null, paperOrderResult.error, 'Error should be reported');
		System.assert(paperOrderResult.error.message.contains(String.format(System.Label.GNE_SFA2_PFG_REST_PAPER_ORDER_MISSING_TERRITORY, new String[]{'WRONG_NO'})), 'Error for Missing Territory should be reported');
		System.assertEquals(0, [SELECT count() FROM SFA2_PFG_Transaction_gne__c WHERE RecordType.Name = :GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_DTP_PAPER_ORDER], 'DTP Paper Orders should not be created');
	}

	public static TestMethod void testPaperOrderMissingCS() {
		List<GNE_SFA2_PFG_REST_DTP_Paper_Order.DtpPaperOrder> paperOrdersData = preparePaperOrderData();

		for(GNE_SFA2_PFG_REST_DTP_Paper_Order.DtpPaperOrder paperOrder : paperOrdersData) {
			paperOrder.Rep_Unix_ID = 'WRONG_CS_UNIX_ID';
			break;
		}

		Test.startTest();
		GNE_SFA2_PFG_REST_DTP_Paper_Order.ResultSet paperOrderResult = executePaperOrder(paperOrdersData);
		Test.stopTest();

		System.assertNotEquals(null, paperOrderResult.error, 'Error should be reported');
		System.assert(paperOrderResult.error.message.contains(String.format(System.Label.GNE_SFA2_PFG_REST_PAPER_ORDER_MISSING_USER, new String[]{'WRONG_CS_UNIX_ID'})), 'Error for Missing CS should be reported');
		System.assertEquals(0, [SELECT count() FROM SFA2_PFG_Transaction_gne__c WHERE RecordType.Name = :GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_DTP_PAPER_ORDER], 'DTP Paper Orders should not be created');
	}

	public static TestMethod void testPaperOrderMissingHcp() {
		List<GNE_SFA2_PFG_REST_DTP_Paper_Order.DtpPaperOrder> paperOrdersData = preparePaperOrderData();

		for(GNE_SFA2_PFG_REST_DTP_Paper_Order.DtpPaperOrder paperOrder : paperOrdersData) {
			paperOrder.HCP_Id = 'WRONG_HCP_ID';
			break;
		}

		Test.startTest();
		GNE_SFA2_PFG_REST_DTP_Paper_Order.ResultSet paperOrderResult = executePaperOrder(paperOrdersData);
		Test.stopTest();

		System.assertNotEquals(null, paperOrderResult.error, 'Error should be reported');
		System.assert(paperOrderResult.error.message.contains(String.format(System.Label.GNE_SFA2_PFG_REST_PAPER_ORDER_MISSING_HCP, new String[]{'WRONG_HCP_ID'})), 'Error for Missing HCP should be reported, Error: ' + paperOrderResult.error.message);
		System.assertEquals(0, [SELECT count() FROM SFA2_PFG_Transaction_gne__c WHERE RecordType.Name = :GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_DTP_PAPER_ORDER], 'DTP Paper Orders should not be created');
	}

	public static TestMethod void testPaperOrderMissingAddress() {
		List<GNE_SFA2_PFG_REST_DTP_Paper_Order.DtpPaperOrder> paperOrdersData = preparePaperOrderData();

		for(GNE_SFA2_PFG_REST_DTP_Paper_Order.DtpPaperOrder paperOrder : paperOrdersData) {
			paperOrder.HCP_Add_Id = 'WRONG_ADDR_ID';
			break;
		}

		Test.startTest();
		GNE_SFA2_PFG_REST_DTP_Paper_Order.ResultSet paperOrderResult = executePaperOrder(paperOrdersData);
		Test.stopTest();

		System.assertNotEquals(null, paperOrderResult.error, 'Error should be reported');
		System.assert(paperOrderResult.error.message.contains(String.format(System.Label.GNE_SFA2_PFG_REST_PAPER_ORDER_MISSING_ADDRESS, new String[]{'WRONG_ADDR_ID'})), 'Error for Missing Address should be reported');
		System.assertEquals(0, [SELECT count() FROM SFA2_PFG_Transaction_gne__c WHERE RecordType.Name = :GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_DTP_PAPER_ORDER], 'DTP Paper Orders should not be created');
	}

	public static TestMethod void testPaperOrderQtyLimitReached() {
		List<GNE_SFA2_PFG_REST_DTP_Paper_Order.DtpPaperOrder> paperOrdersData = preparePaperOrderData();

		for(GNE_SFA2_PFG_REST_DTP_Paper_Order.DtpPaperOrder paperOrder : paperOrdersData) {
			paperOrder.Txn_Qty = 10000;
			break;
		}

		Test.startTest();
		GNE_SFA2_PFG_REST_DTP_Paper_Order.ResultSet paperOrderResult = executePaperOrder(paperOrdersData);
		Test.stopTest();

		System.assertNotEquals(null, paperOrderResult.error, 'Error should be reported');
		System.assert(paperOrderResult.error.message.contains('Quantity Limit reached for Territory'), 'Error for Territory Qty Limit should be reported');
		System.assert(paperOrderResult.error.message.contains('Quantity Limit reached for HCP'), 'Error for HCP Qty Limit should be reported');
		System.assertEquals(0, [SELECT count() FROM SFA2_PFG_Transaction_gne__c WHERE RecordType.Name = :GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_DTP_PAPER_ORDER], 'DTP Paper Orders should not be created');
	}

	public static TestMethod void testPaperOrderQtyDuplicateOrder() {
		List<GNE_SFA2_PFG_REST_DTP_Paper_Order.DtpPaperOrder> paperOrdersData = preparePaperOrderData();

		for(GNE_SFA2_PFG_REST_DTP_Paper_Order.DtpPaperOrder paperOrder : paperOrdersData) {
			paperOrder.Prod_Ln_ID = PAPER_LINE_ITEM_ID;
		}
		Set<Id> prodIds = new Set<Id>();
		for(Product_vod__c prod :new List<Product_vod__c>{GNE_SFA2_PFG_TestHelper.getPfgProduct('DTP1'), GNE_SFA2_PFG_TestHelper.getPfgProduct('DTP2')}){
			System.debug('prod: ' + prod );
			GNE_SFA2_PFG_TestHelper.createLimit(prod);
			prodIds.add(prod.Id);
		}
		GNE_SFA2_PFG_Util.cacheProductLimits(prodIds, String.valueOf(Date.today().year()));

		Territory2 terr = [Select Id,Name From Territory2 Where Name ='00F23B1-DAYTON - COLUMBUS' Limit 1];
		SFA2_PFG_to_Territory_Detail_gne__c detail = new SFA2_PFG_to_Territory_Detail_gne__c(
			Product_gne__c=GNE_SFA2_PFG_TestHelper.getPfgProduct('DTP1').id,
			Distribution_Method_gne__c='DTP',
			Territory_gne__c = terr.Id,
			Territory_Name_gne__c= terr.Name,
			Year_gne__c=Date.today().year(),
			Qty_Total_Allocated_gne__c =5,
			Qty_Adjusted_gne__c=0,
			Qty_Reserved_gne__c=0,
			Qty_Shipped_to_Physician_gne__c=0
			);
		insert detail;
		detail.recalculateFormulas();
		GNE_SFA2_PFG_Util.addPfgToTerritoryDetailToCache(detail);



		Test.startTest();
		GNE_SFA2_PFG_REST_DTP_Paper_Order.ResultSet paperOrderResult = executePaperOrder(paperOrdersData);
		Test.stopTest();

		System.assertNotEquals(null, paperOrderResult.error, 'Error should be reported');
		System.assert(paperOrderResult.error.message.contains(String.format(System.Label.GNE_SFA2_PFG_REST_PAPER_ORDER_DUPLICATE_ORDER, new String[]{PAPER_ORDER_ID, PAPER_LINE_ITEM_ID})), 'Error for Missing Address should be reported: ' + paperOrderResult.error.message);
		System.assertEquals(0, [SELECT count() FROM SFA2_PFG_Transaction_gne__c WHERE RecordType.Name = :GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_DTP_PAPER_ORDER], 'DTP Paper Orders should not be created');
	}


	public static TestMethod void testIphoneCsLimitsInterfaceDeltaMode() {
		User u = prepareEnv('CS1');
		GNE_SFA2_PFG_TestHelper.clearPFGCache();
		iPhone_Get_PFGtoUserAccProductQtyLimit.RestResponse restResult;
		System.runAs(u) {
			restResult = iPhone_Get_PFGtoUserAccProductQtyLimit.processRequest(
					String.valueOf(System.now().addDays(-1)), u.External_Id_gne__c, new List<Id>(AccountTestHelper.accountsCache.keySet()), true, '1');
		}
		/*
		System.assertEquals(null, restResult.error, 'iPhone PFG to User Qty Limit REST Interface should not return error:\n' +
				(restResult.error!=null ? (restResult.error.message + '\n' + restResult.error.stackTrace) : ''));

		System.assertEquals(2, restResult.products.size(),
				'iPhone Product Qty Limit outbound interface returns wrong number of product records');
		*/
	}

	public static TestMethod void testIphoneCsDetailsInterface() {
		User u = prepareEnv('CS1');
		GNE_SFA2_PFG_TestHelper.clearPFGCache();
		iPhone_Commons_gne.RestResponse restResult;
		//System.runAs(u) {
		//	restResult = iPhone_Get_User_Details_gne.processRequest(u.External_Id_gne__c);
		//}
		/*
		System.assertEquals(null, restResult.error, 'iPhone User Detail REST Interface should not return error:\n' +
				(restResult.error!=null ? (restResult.error.message + '\n' + restResult.error.stackTrace) : ''));

		iPhone_Get_User_Details_gne.GetUserDetailsResponse udRestResult = (iPhone_Get_User_Details_gne.GetUserDetailsResponse)restResult;

		System.assertEquals(String.valueOf(true), udRestResult.pfg, 'PFG should be active for User ' +  u.External_Id_gne__c);
		System.assertEquals(String.valueOf(true), udRestResult.dtp, 'DTP should be active for User ' +  u.External_Id_gne__c);
		System.assertEquals('Nutropin', udRestResult.brd, 'Nutroping brand should be active for User ' +  u.External_Id_gne__c);
		*/
	}

	private static void intTestAocWorkflow(Integer shipedDiff, Integer receiveDiff,
		Boolean aocCompleteInOtr, Boolean shipmentMode) {
		intTestAocWorkflow(shipedDiff, receiveDiff, aocCompleteInOtr, shipmentMode, false, false, null, null);
	}

	private static void intTestAocWorkflow(Integer shipedDiff, Integer receiveDiff,
			Boolean aocCompleteInOtr, Boolean shipmentMode, Boolean orderStatusMode, Boolean aocStatusMode, String abortStatus, String abortStatusNotes) {
		User u = prepareEnv('CS1');

		// 1. Create completed interaction
		iPhoneApex_2.CallAttributes cAttrs = createTestCallAttrs(u);
		GNE_SFA2_PFG_TestHelper.clearPFGCache();
		iPhoneApex_2.Response wsResult;

		Test.startTest();

		System.runAs(u) {
			wsResult = iPhoneApex_2.updateOrCreateCall(cAttrs);
		}

		cacheTransactions(cAttrs.RequestId);
		assertOrderTransactions(cAttrs, null, null, null, null, AocWorkflowStatus.COMPLETED);

		// 2a. Vendor Shipment Notification Request
		if(shipmentMode) {
			GNE_SFA2_PFG_TestHelper.clearPFGCache();
			List<GNE_SFA2_PFG_REST_DTP_Shipments.DtpShipment> shipmentsData = prepareShipmentsData();

			for(GNE_SFA2_PFG_REST_DTP_Shipments.DtpShipment shipData : shipmentsData) {
				shipData.Txn_Qty += shipedDiff;
			}

			GNE_SFA2_PFG_REST_DTP_Shipments.ResultSet shipmentResult = GNE_SFA2_PFG_REST_DTP_Shipments.setShipments(shipmentsData);
			cacheTransactions(cAttrs.RequestId);
			System.assertEquals(null, shipmentResult.error, 'Error during Shipment: ' + (shipmentResult.error!=null ? shipmentResult.error.message : ''));
			assertOrderTransactions(null, shipmentsData, null, null, null, AocWorkflowStatus.SHIPPED);
		}

		Test.stopTest();

		// 2b. Vendor Order Status Notification Request
		if(orderStatusMode) {
			GNE_SFA2_PFG_TestHelper.clearPFGCache();
			List<GNE_SFA2_PFG_REST_DTP_Order_Status.DtpOrderStatus> orderStatusData = prepareOrderStatusData(abortStatus, abortStatusNotes);
			GNE_SFA2_PFG_REST_DTP_Order_Status.ResultSet orderStatusResult = GNE_SFA2_PFG_REST_DTP_Order_Status.setOrderStatus(orderStatusData);
			cacheTransactions(cAttrs.RequestId);
			System.assertEquals(null, orderStatusResult.error, 'Error during Order Status: ' + (orderStatusResult.error!=null ? orderStatusResult.error.message : ''));
			assertOrderTransactions(null, null, orderStatusData, null, null, AocWorkflowStatus.CANCELLED);
		}

		// 2c. Vendor AOC Status Notification Request
		if(aocStatusMode) {
			GNE_SFA2_PFG_TestHelper.clearPFGCache();
			List<GNE_SFA2_PFG_REST_DTP_AOC_Status.DtpAocStatus> aocStatusData = prepareAocStatusData(SIGNATURE_PENDING_STATUS);
			GNE_SFA2_PFG_REST_DTP_AOC_Status.ResultSet aocStatusResult = GNE_SFA2_PFG_REST_DTP_AOC_Status.setAocStatus(aocStatusData);
			cacheTransactions(cAttrs.RequestId);
			System.assertEquals(null, aocStatusResult.error, 'Error during AOC Status: ' + (aocStatusResult.error!=null ? aocStatusResult.error.message : ''));
			assertOrderTransactions(null, null, null, aocStatusData, null, AocWorkflowStatus.AOC_STATUS);
		}

		// 3. AOC signature
		if(aocCompleteInOtr) {
			GNE_SFA2_PFG_TestHelper.clearPFGCache();
			//iPhoneApex_Test.copyIdsFromResponseToAttrs(wsResult, cAttrs);
			cAttrs.RequestSignature = null;
			cAttrs.RequestSignatureDate = null;
			cAttrs.Signature = AOC_SIGNATURE_VALUE;
			cAttrs.SignatureDate = System.now();

			for(iPhoneApex_2.CallPfgDetail cDetailAttr : cAttrs.callPfgDetailList) {
				cDetailAttr.LotNo = LOT_NO_VALUE;
				cDetailAttr.Quantity += receiveDiff;
			}

			System.runAs(u) {
				wsResult = iPhoneApex_2.intUpdateOrCreateCall(cAttrs, new iPhoneApex_2.Response());
			}

			cacheTransactions(cAttrs.RequestId);
			assertOrderTransactions(cAttrs, null, null, null, null, AocWorkflowStatus.AOC_COMPLETED);

			if(aocStatusMode) {
				GNE_SFA2_PFG_TestHelper.clearPFGCache();
				List<GNE_SFA2_PFG_REST_DTP_AOC_Status.DtpAocStatus> aocStatusData = prepareAocStatusData(SIGNATURE_COMPLETE_STATUS);
				GNE_SFA2_PFG_REST_DTP_AOC_Status.setAocStatus(aocStatusData);
				cacheTransactions(cAttrs.RequestId);
				assertOrderTransactions(null, null, null, aocStatusData, null, AocWorkflowStatus.AOC_STATUS);
			}
		}

		veQtyChecker.assertQty(abortStatus!=null)
;	}


	public static TestMethod void testPaperOrderAocStatusComplete() {
		intTestPaperOrderAocWorkflow(0, 0, true, true, true);
	}

	private static void intTestPaperOrderAocWorkflow(Integer shipedDiff, Integer receiveDiff,
			Boolean shipmentMode, Boolean orderStatusMode, Boolean aocStatusMode) {
		GNE_SFA2_PFG_TestHelper.clearPFGCache();

		GNE_SFA2_PFG_Util.clearPfgToTerritoryCache();
		System.debug( GNE_SFA2_PFG_Util.pfgToTerritoryDetailsCache );

		// 1. Create Paper Order
		List<GNE_SFA2_PFG_REST_DTP_Paper_Order.DtpPaperOrder> paperOrdersData = preparePaperOrderData();
		User esbUser = GNE_SFA2_PFG_TestHelper.getUser('ESB1');

		Set<Id> prodIds = new Set<Id>();
		for(Product_vod__c prod :new List<Product_vod__c>{GNE_SFA2_PFG_TestHelper.getPfgProduct('DTP1'), GNE_SFA2_PFG_TestHelper.getPfgProduct('DTP2')}){
			GNE_SFA2_PFG_TestHelper.createLimit(prod);
			prodIds.add(prod.Id);
		}

		GNE_SFA2_PFG_Util.cacheProductLimits(prodIds, String.valueOf(Date.today().year()));
		SFA2_PFG_Transaction_gne__c[] lTransactions = [SELECT Product_gne__c, To_Territory_Name_gne__c, From_Territory_Name_gne__c, Transaction_Date_gne__c FROM SFA2_PFG_Transaction_gne__c];

		GNE_SFA2_PFG_Util.cachePfgToTerritoryDetails(lTransactions);

		Test.startTest();

		GNE_SFA2_PFG_REST_DTP_Paper_Order.ResultSet paperOrderResult = executePaperOrder(paperOrdersData);
		System.assertEquals(null, paperOrderResult.error, 'Error during creating Paper Order: ' + (paperOrderResult.error!=null ? paperOrderResult.error.message : ''));

		cacheTransactions(null, paperOrdersData[0].Txn_ID);
		System.assertEquals(null, paperOrderResult.error, 'Error during creating Paper Order: ' + (paperOrderResult.error!=null ? paperOrderResult.error.message : ''));
		assertOrderTransactions(null, null, null, null, paperOrdersData, AocWorkflowStatus.PAPER_ORDER);

		// 2. Vendor Shipment Notification Request
		if(shipmentMode) {
			GNE_SFA2_PFG_TestHelper.clearPFGCache();
			List<GNE_SFA2_PFG_REST_DTP_Shipments.DtpShipment> shipmentsData = prepareShipmentsData();

			for(GNE_SFA2_PFG_REST_DTP_Shipments.DtpShipment shipData : shipmentsData) {
				shipData.Txn_Qty += shipedDiff;
			}

			GNE_SFA2_PFG_REST_DTP_Shipments.ResultSet shipmentResult;
			System.runAs(esbUser) {
				shipmentResult = GNE_SFA2_PFG_REST_DTP_Shipments.setShipments(shipmentsData);
			}

			cacheTransactions(null, paperOrdersData[0].Txn_ID);
			System.assertEquals(null, shipmentResult.error, 'Error during Shipment: ' + (shipmentResult.error!=null ? shipmentResult.error.message : '') + '\n\nInput: ' + String.valueOf(shipmentsData));
			assertOrderTransactions(null, shipmentsData, null, null, null, AocWorkflowStatus.SHIPPED);
		}


		// 3. Vendor Order Status Notification Request
		if(orderStatusMode) {
			GNE_SFA2_PFG_TestHelper.clearPFGCache();
			List<GNE_SFA2_PFG_REST_DTP_Order_Status.DtpOrderStatus> orderStatusData = prepareOrderStatusData(ORDER_STATUS_SHIPPED, ORDER_STATUS_SHIPPED_NOTES);

			GNE_SFA2_PFG_REST_DTP_Order_Status.ResultSet orderStatusResult;
			System.runAs(esbUser) {
				orderStatusResult = GNE_SFA2_PFG_REST_DTP_Order_Status.setOrderStatus(orderStatusData);
			}

			cacheTransactions(null, paperOrdersData[0].Txn_ID);
			System.assertEquals(null, orderStatusResult.error, 'Error during Order Status: ' + (orderStatusResult.error!=null ? orderStatusResult.error.message : ''));
			assertOrderTransactions(null, null, orderStatusData, null, null, AocWorkflowStatus.ORDER_STATUS);
		}

		// 4. Vendor AOC Status Notification Request
		if(aocStatusMode) {
			GNE_SFA2_PFG_TestHelper.clearPFGCache();
			List<GNE_SFA2_PFG_REST_DTP_AOC_Status.DtpAocStatus> aocStatusData = prepareAocStatusData(SIGNATURE_COMPLETE_STATUS);

			GNE_SFA2_PFG_REST_DTP_AOC_Status.ResultSet aocStatusResult;
			System.runAs(esbUser) {
				aocStatusResult = GNE_SFA2_PFG_REST_DTP_AOC_Status.setAocStatus(aocStatusData);
			}

			cacheTransactions(null, paperOrdersData[0].Txn_ID);
			System.assertEquals(null, aocStatusResult.error, 'Error during AOC Status: ' + (aocStatusResult.error!=null ? aocStatusResult.error.message : ''));
			assertOrderTransactions(null, null, null, aocStatusData, null, AocWorkflowStatus.AOC_STATUS);
		}

		for(SFA2_PFG_to_Territory_Detail_gne__c detail : [select Active_gne__c, Distribution_Method_gne__c, Expiration_Date_gne__c, Id, IsLocked, Lot_NO_gne__c, MayEdit, Merged_gne__c, Name, Product_gne__c, Qty_Adjusted_gne__c, Qty_Reserved_gne__c, Qty_Shipped_to_Physician_gne__c, Qty_Total_Allocated_gne__c, Qty_Total_Available_gne__c, Region_Code_gne__c, Territory_gne__c, Territory_Name_gne__c, Territory_Number_gne__c, UOM_gne__c, Year_gne__c, YTD_Allocated_gne__c from SFA2_PFG_to_Territory_Detail_gne__c ]){
		    System.debug(detail);
		}

		Test.stopTest();
	}

	private static List<GNE_SFA2_PFG_REST_DTP_Paper_Order.DtpPaperOrder> preparePaperOrderData() {
		User u = prepareEnv('CS1');

		List<GNE_SFA2_PFG_REST_DTP_Paper_Order.DtpPaperOrder> paperOrdersData = preparePaperOrdersData(u);
		//GNE_SFA2_PFG_TestHelper.clearPFGCache();

		return paperOrdersData;
	}

	private static GNE_SFA2_PFG_REST_DTP_Paper_Order.ResultSet executePaperOrder(List<GNE_SFA2_PFG_REST_DTP_Paper_Order.DtpPaperOrder> paperOrdersData) {
		User esbUser = GNE_SFA2_PFG_TestHelper.getUser('ESB1');

		GNE_SFA2_PFG_REST_DTP_Paper_Order.ResultSet paperOrderResult;
		System.runAs(esbUser) {
			paperOrderResult = GNE_SFA2_PFG_REST_DTP_Paper_Order.insertPaperOrders(paperOrdersData);
		}

		return paperOrderResult;
	}

	private static User prepareEnv(String userName) {
		User u = GNE_SFA2_PFG_TestHelper.prepareEnvWithTerrs(userName);

        accountTestHelper = new AccountTestHelper();
        accountTestHelper.insertAccountsWithAddresses(3, u.Id);
        veQtyChecker = new VeQtyChecker();
        iPhoneApex_Test.initEnv(false);
        GNE_SFA2_PFG_TestHelper.insertAllocationTransfers('DTP', new Set<String>{'DTP1', 'DTP2'});
        return u;
    }

    private static iPhoneApex_2.CallAttributes createTestCallAttrs(User u) {
    	List<Id> accIds = new List<Id>(accountTestHelper.accountsByTypeCache.get('HCP'));
		Id mainAccId = accIds.remove(0);
		Account mainAcc = accountTestHelper.accountsCache.get(mainAccId);
		List<Account> atts = new List<Account>();

		for(Id attAccId : accIds) {
			atts.add(accountTestHelper.accountsCache.get(attAccId));
		}

		List<Product_vod__c> pfgProds = new List<Product_vod__c>{GNE_SFA2_PFG_TestHelper.getPfgProduct('DTP1'), GNE_SFA2_PFG_TestHelper.getPfgProduct('DTP2')};

		iPhoneApex_2.CallAttributes cAttrs = iPhoneApex_Test.createCallAttributes(mainAcc,
					u.Id, null, true, 'Account Call', null, null,
					atts, null, null, pfgProds);

		cAttrs.RequestSignature = REQUEST_SIGNATURE_VALUE;
		cAttrs.RequestSignatureDate = System.now();

		return cAttrs;
    }

    private static void cacheTransactions(String iPhoneRequestId) {
    	cacheTransactions(iPhoneRequestId, null);
    }

    private static void cacheTransactions(String iPhoneRequestId, String papepOrderId) {
    	trxByNameCache = new Map<String,SFA2_PFG_Transaction_gne__c>();
    	trxCache = new Map<String,SFA2_PFG_Transaction_gne__c>();
    	trxByRefNoCache = new Map<String,List<SFA2_PFG_Transaction_gne__c>>();

    	Set<String> orderRecordTypeNames = new Set<String>{GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RFF, GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_DTP_PAPER_ORDER};

    	List<SFA2_PFG_Transaction_gne__c> trxs =
    		[
    			SELECT
    				Name, Transaction_Ref_Number_gne__c, RecordType.Name,
    				Call_PFG_Detail_Id_gne__r.Call_gne__c,
    				Call_PFG_Detail_Id_gne__r.Call_gne__r.Request_Signature_gne__c, Call_PFG_Detail_Id_gne__r.Call_gne__r.Request_Signature_Date_gne__c,
    				Call_PFG_Detail_Id_gne__r.Call_gne__r.Signature_vod__c, Call_PFG_Detail_Id_gne__r.Call_gne__r.Signature_Date_vod__c,
    				Request_Signature_gne__c, Request_Signature_Date_gne__c, Signature_gne__c, Signature_Date_gne__c,
    				Address_ID_gne__r.Name, Address_ID_gne__r.Address_Line_2_vod__c, Address_ID_gne__r.City_vod__c,
    				Address_ID_gne__r.State_vod__c, Address_ID_gne__r.Zip_vod__c, Address_ID_gne__r.Zip_4_vod__c,
    				Product_gne__r.Name, Product_gne__r.NDC_Number_gne__c,
    				Signature_Status_gne__c, Status_gne__c,
    				Shipment_Id_gne__c, Pick_Slip_Number_gne__c, Shipped_To_Address_By_Third_Party_gne__c,
    				Transaction_Date_gne__c, Distribution_Method_gne__c, Lot_No_gne__c,
    				Requested_Quantity_gne__c, Shipped_Quantity_gne__c, Received_Quantity_gne__c,
    				Call_PFG_Detail_Id_gne__r.Quantity_gne__c, Call_PFG_Detail_Id_gne__r.DTP_AOC_Status_gne__c,
    				Carrier_gne__c, Tracking_Id_gne__c, Tracking_URL_gne__c,
    				Call_PFG_Detail_Id_gne__r.Shipment_Id_gne__c, Call_PFG_Detail_Id_gne__r.Lot_No_gne__c, Call_PFG_Detail_Id_gne__r.Order_Status_gne__c,
    				Call_PFG_Detail_Id_gne__r.iPhone_Request_Id_gne__c,
    				Account_gne__c, Shipped_Date_gne__c,
    				Order_Status_Last_Updated_gne__c, Order_Status_Note_gne__c, Delivery_Status_gne__c,
    				Line_Item_ID_gne__c, NDC_Number__c, Account_Name_gne__c, Account_MDMID_gne__c,
    				Address_ID_gne__c, Address_Line_1_gne__c, Address_Line_2_gne__c, City_gne__c, State_gne__c, Zip_gne__c,
    				Facility_Name_gne__c, SLN_gne__c, Designation_gne__c,
    				From_User_gne__c, From_User_gne__r.External_Id_gne__c, CS_ID_gne__c, CS_First_Name_gne__c, CS_Last_Name_gne__c, CS_Email_gne__c,
    				From_Territory_Name_gne__c, From_Territory_Number_gne__c, From_User_Territory_gne__c
    			FROM SFA2_PFG_Transaction_gne__c
    			WHERE (Call_PFG_Detail_ID_gne__r.Call_gne__r.iPhone_Request_Id_gne__c = :iPhoneRequestId OR Transaction_Ref_Number_gne__c = :papepOrderId)
    				AND RecordType.Name IN :orderRecordTypeNames
    		];

    	for(SFA2_PFG_Transaction_gne__c trx : trxs) {
    		if(trx.RecordType.Name == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RFF) {
    			trxCache.put(trx.Call_PFG_Detail_Id_gne__r.iPhone_Request_Id_gne__c, trx);
    			trxByNameCache.put(trx.Transaction_Ref_Number_gne__c + '_' + trx.Name, trx);
    		} else {
    			trxCache.put(trx.Id, trx);
    			trxByNameCache.put(trx.Transaction_Ref_Number_gne__c + '_' + trx.Line_Item_ID_gne__c, trx);
    		}

    		if(!trxByRefNoCache.containsKey(trx.Transaction_Ref_Number_gne__c)) {
    			trxByRefNoCache.put(trx.Transaction_Ref_Number_gne__c, new List<SFA2_PFG_Transaction_gne__c>());
    		}

    		trxByRefNoCache.get(trx.Transaction_Ref_Number_gne__c).add(trx);
    	}
    }

    private static List<GNE_SFA2_PFG_REST_DTP_Shipments.DtpShipment> prepareShipmentsData() {
    	List<GNE_SFA2_PFG_REST_DTP_Shipments.DtpShipment> result = new List<GNE_SFA2_PFG_REST_DTP_Shipments.DtpShipment>();

    	for(SFA2_PFG_Transaction_gne__c trx : trxCache.values()) {
    		GNE_SFA2_PFG_REST_DTP_Shipments.DtpShipment shipment = new GNE_SFA2_PFG_REST_DTP_Shipments.DtpShipment();
    		shipment.Ship_Id = SHIPMENT_VALUE;
			shipment.Txn_ID = trx.Transaction_Ref_Number_gne__c;
			shipment.Call_Id = (trx.RecordType.Name == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RFF ? trx.Call_PFG_Detail_Id_gne__r.Call_gne__c : null);
    		shipment.Prod_Ln_ID = (trx.RecordType.Name == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RFF ? trx.Name : trx.Line_Item_ID_gne__c);
			shipment.Pick_Num = PICK_NUMBER_VALUE;
			shipment.Ship_Date = System.now().formatGmt(REST_DATE_TIME_FORMAT);
			shipment.HCP_Id = trx.Account_gne__c;
			shipment.HCP_Add_Ln_1 = trx.Address_ID_gne__r.Name;
			shipment.HCP_Add_Ln_2 = trx.Address_ID_gne__r.Address_Line_2_vod__c;
			shipment.HCP_City = trx.Address_ID_gne__r.City_vod__c;
			shipment.HCP_State = trx.Address_ID_gne__r.State_vod__c;
			shipment.HCP_Zip = trx.Address_ID_gne__r.Zip_vod__c;
			shipment.Zip_Ext = trx.Address_ID_gne__r.Zip_4_vod__c;
			shipment.NDC = trx.Product_gne__r.NDC_Number_gne__c;
			shipment.Prod_Nm = trx.Product_gne__r.Name;
			shipment.Lot_No = LOT_NO_VALUE;
			shipment.Txn_Qty = trx.Requested_Quantity_gne__c.intValue();
			shipment.Carrier = 'test';
			shipment.Track_Id = 'testID';
			shipment.Track_URL = 'https://test.vendor/home?id=testId';
			shipment.Sig_Sts = SIGNATURE_PENDING_STATUS;

			result.add(shipment);
    	}

    	return result;
    }

    private static List<GNE_SFA2_PFG_REST_DTP_Order_Status.DtpOrderStatus> prepareOrderStatusData(String status, String statusNotes) {
    	List<GNE_SFA2_PFG_REST_DTP_Order_Status.DtpOrderStatus> result = new List<GNE_SFA2_PFG_REST_DTP_Order_Status.DtpOrderStatus>();
    	Set<String> visitedRefNo = new Set<String>();

    	for(SFA2_PFG_Transaction_gne__c trx : trxCache.values()) {
    		if(!visitedRefNo.contains(trx.Transaction_Ref_Number_gne__c)) {
    			visitedRefNo.add(trx.Transaction_Ref_Number_gne__c);

    			GNE_SFA2_PFG_REST_DTP_Order_Status.DtpOrderStatus ordStatus = new GNE_SFA2_PFG_REST_DTP_Order_Status.DtpOrderStatus();
    			ordStatus.Txn_ID = trx.Transaction_Ref_Number_gne__c;
        		ordStatus.Ord_Sts = status;
       			ordStatus.Ord_Sts_Nt = statusNotes;
       			ordStatus.Ord_Sts_Lst_Updt = System.now().formatGmt(REST_DATE_TIME_FORMAT);
    			result.add(ordStatus);
    		}
    	}

    	return result;
    }

    private static List<GNE_SFA2_PFG_REST_DTP_AOC_Status.DtpAocStatus> prepareAocStatusData(String status) {
    	List<GNE_SFA2_PFG_REST_DTP_AOC_Status.DtpAocStatus> result = new List<GNE_SFA2_PFG_REST_DTP_AOC_Status.DtpAocStatus>();

    	for(SFA2_PFG_Transaction_gne__c trx : trxCache.values()) {
    		GNE_SFA2_PFG_REST_DTP_AOC_Status.DtpAocStatus aocStatus = new GNE_SFA2_PFG_REST_DTP_AOC_Status.DtpAocStatus();
    		aocStatus.Txn_ID = trx.Transaction_Ref_Number_gne__c;
    		aocStatus.Call_Id = (trx.RecordType.Name == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RFF ? trx.Call_PFG_Detail_Id_gne__r.Call_gne__c : null);
    		aocStatus.Prod_Ln_ID = (trx.RecordType.Name == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RFF ? trx.Name : trx.Line_Item_ID_gne__c);
    		aocStatus.Ship_Id = SHIPMENT_VALUE;
        	aocStatus.Sig_Sts = status;
        	if(status == SIGNATURE_COMPLETE_STATUS) {
        		aocStatus.Txn_Qty = trx.Shipped_Quantity_gne__c.intValue();
        	}
       		result.add(aocStatus);
    	}

    	return result;
    }

    private static List<GNE_SFA2_PFG_REST_DTP_Paper_Order.DtpPaperOrder> preparePaperOrdersData(User u) {
    	List<GNE_SFA2_PFG_REST_DTP_Paper_Order.DtpPaperOrder> result = new List<GNE_SFA2_PFG_REST_DTP_Paper_Order.DtpPaperOrder>();

    	List<Id> accIds = new List<Id>(accountTestHelper.accountsByTypeCache.get('HCP'));
		Account hcpAcc = accountTestHelper.accountsCache.get(accIds[0]);
		Address_vod__c addr = hcpAcc.Address_vod__r[0];

		Territory2 terr = GNE_SFA2_PFG_Util.getTerritoryForUser(u.Id);

		List<Product_vod__c> pfgProds = new List<Product_vod__c>{GNE_SFA2_PFG_TestHelper.getPfgProduct('DTP1'), GNE_SFA2_PFG_TestHelper.getPfgProduct('DTP2')};

    	Integer idx = 0;
    	for(Product_vod__c pfgProd : pfgProds) {
    		idx++;
    		GNE_SFA2_PFG_REST_DTP_Paper_Order.DtpPaperOrder paperOrder = new GNE_SFA2_PFG_REST_DTP_Paper_Order.DtpPaperOrder();
    		paperOrder.Txn_ID = PAPER_ORDER_ID;
			paperOrder.Txn_Date = System.now().formatGmt(REST_DATE_TIME_FORMAT);
			paperOrder.Txn_Type = GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_DTP_Paper_Order;
			paperOrder.Prod_Ln_ID = PAPER_LINE_ITEM_ID + idx;
			paperOrder.Txn_Qty = 1;
			paperOrder.NDC = pfgProd.NDC_Number_gne__c;
			paperOrder.Prod_Nm = pfgProd.Name;
			paperOrder.HCP_Id = hcpAcc.Id;
			paperOrder.MDM_Id = hcpAcc.MDMID_gne__c + 'T';
			paperOrder.HCP_Fst_Nm = hcpAcc.FirstName;
			paperOrder.HCP_Mid_Init = 'L';
			paperOrder.HCP_Lst_Nm = hcpAcc.LastName;
			paperOrder.HCP_Add_Id = addr.Id;
			paperOrder.HCP_Add_Ln_1 = addr.Name + 'T';
			paperOrder.HCP_Add_Ln_2 = addr.Address_Line_2_vod__c;
			paperOrder.HCP_City = addr.City_vod__c + 'T';
			paperOrder.HCP_State = addr.State_vod__c;
			paperOrder.HCP_Zip = addr.Zip_vod__c;
			paperOrder.HCP_Fcty_Nm = FACILITY_NAME;
			paperOrder.SLN = SLN + 'T';
			paperOrder.Prof_Des = DESIGNATION;
			paperOrder.Rep_Unix_ID = u.External_Id_gne__c;
			paperOrder.Rep_ID = u.External_Id_gne__c;
			paperOrder.Rep_Fst_Nm = u.FirstName + 'T';
			paperOrder.Rep_Lst_Nm = u.LastName + 'T';
			paperOrder.Rep_eMail = 'test.cs.email.dev@gene.com';
			paperOrder.Terr_Nm = terr.Name;
			paperOrder.Terr_No = terr.Territory_Number_gne__c;
			result.add(paperOrder);
    	}

    	return result;
    }

    private static void assertOrderTransactions(iPhoneApex_2.CallAttributes cAttrs,
    		List<GNE_SFA2_PFG_REST_DTP_Shipments.DtpShipment> shipmentsData,
    		List<GNE_SFA2_PFG_REST_DTP_Order_Status.DtpOrderStatus> orderStatusData,
    		List<GNE_SFA2_PFG_REST_DTP_AOC_Status.DtpAocStatus> aocStatusData,
    		List<GNE_SFA2_PFG_REST_DTP_Paper_Order.DtpPaperOrder>  paperOrderData,
    		AocWorkflowStatus wfStatus) {
    	if(cAttrs!=null) {
    		System.assertEquals(cAttrs.callPfgDetailList.size(),trxCache.size(), 'Number of PFGs should be equal to number of RFF Transactions');

	    	for(iPhoneApex_2.CallPfgDetail cDetailAttr : cAttrs.callPfgDetailList) {
				SFA2_PFG_Transaction_gne__c trx = trxCache.get(cDetailAttr.RequestId);

				if(wfStatus == AocWorkflowStatus.COMPLETED || wfStatus == AocWorkflowStatus.TERRITORY_QTY_REACHED) {
					System.assertEquals(REQUEST_SIGNATURE_VALUE, trx.Request_Signature_gne__c, '[Call Complete] Request Signature not set on Transaction');
		    		System.assertNotEquals(null, trx.Request_Signature_Date_gne__c, '[Call Complete] Request Signature Date not set on Transaction');
		    		System.assertEquals(REQUEST_SIGNATURE_VALUE, trx.Call_PFG_Detail_Id_gne__r.Call_gne__r.Request_Signature_gne__c, '[Call Complete] Request Signature not set on Call');
		    		System.assertNotEquals(null, trx.Call_PFG_Detail_Id_gne__r.Call_gne__r.Request_Signature_Date_gne__c, '[Call Complete] Request Signature Date not set on Call');
		    		System.assertEquals(cDetailAttr.Quantity, trx.Requested_Quantity_gne__c.intValue(), '[Call Complete] Requested Qty is not valid');

		    		if(wfStatus == AocWorkflowStatus.COMPLETED) {
		    			System.assertEquals(GNE_SFA2_PFG_Util.TRANSACTION_STATUS_SUBMITTED, trx.Status_gne__c, '[Call Complete] Status is not valid');
		    		}

		    		System.assertEquals(cDetailAttr.Quantity, trx.Call_PFG_Detail_Id_gne__r.Quantity_gne__c.intValue(), '[Call Complete] Call PFG Detail Quantity is not valid');
				} else if(wfStatus == AocWorkflowStatus.AOC_COMPLETED) {
					//System.assertEquals(AOC_SIGNATURE_VALUE, trx.Signature_gne__c, '[AOC Complete] AOC Signature not set on Transaction');
		    		//System.assertNotEquals(null, trx.Signature_Date_gne__c, '[AOC Complete] AOC Signature Date not set on Transaction');
		    		System.assertEquals(AOC_SIGNATURE_VALUE, trx.Call_PFG_Detail_Id_gne__r.Call_gne__r.Signature_vod__c, '[AOC Complete] AOC Signature not set on Call');
		    		System.assertNotEquals(null, trx.Call_PFG_Detail_Id_gne__r.Call_gne__r.Signature_Date_vod__c, '[AOC Complete] AOC Signature Date not set on Call');
		    		//System.assertEquals(cDetailAttr.Quantity, trx.Received_Quantity_gne__c.intValue(), '[AOC Complete] Received Qty is not valid');
		    		//System.assertEquals(GNE_SFA2_PFG_Util.TRANSACTION_SIGNATURE_COMPLETE, trx.Signature_Status_gne__c, '[AOC Complete] Signature status is not valid');
		    		//System.assertEquals(GNE_SFA2_PFG_Util.TRANSACTION_STATUS_COMPLETED, trx.Status_gne__c, '[AOC Complete] Status is not valid');

		    		System.assertEquals(GNE_SFA2_PFG_Util.TRANSACTION_SIGNATURE_COMPLETE, trx.Call_PFG_Detail_Id_gne__r.DTP_AOC_Status_gne__c, '[AOC Complete] Call PFG Detail AOC Status is not valid');
				}

				if(wfStatus == AocWorkflowStatus.TERRITORY_QTY_REACHED) {
					System.assertEquals(GNE_SFA2_PFG_Util.TRANSACTION_STATUS_CANCELLED, trx.Status_gne__c, '[Limit Reached] Status is not valid');
					System.assertEquals(GNE_SFA2_PFG_Util.TRANSACTION_DELIVERY_CANCELLED, trx.Delivery_Status_gne__c, '[Limit Reached] Delivery Status is not valid');
	    			System.assertEquals(GNE_SFA2_PFG_Util.TRANSACTION_ORDER_STATUS_CANCELLED_NOTE, trx.Order_Status_Note_gne__c, '[Limit Reached] Order Status Notes are not valid');
	    			System.assertNotEquals(null, trx.Order_Status_Last_Updated_gne__c, '[Limit Reached] Order Status Last Update Date is not set');

		    		System.assertEquals(GNE_SFA2_PFG_Util.TRANSACTION_DELIVERY_CANCELLED, trx.Call_PFG_Detail_Id_gne__r.Order_Status_gne__c, '[Limit Reached] Call PFG Detail Order Status is not valid');
				}
	    	}
    	}

    	if(shipmentsData!=null && wfStatus == AocWorkflowStatus.SHIPPED) {
    		System.assertEquals(shipmentsData.size(),trxCache.size(), '[Shipped] Number of Shipments should be equal to number of RFF Transactions');

    		for(GNE_SFA2_PFG_REST_DTP_Shipments.DtpShipment shipData : shipmentsData) {
    			SFA2_PFG_Transaction_gne__c trx = trxByNameCache.get(shipData.Txn_ID + '_' + shipData.Prod_Ln_ID);

	    		System.assertNotEquals(null, trx, '[Shipped] Matching Transaction not found');
	    		System.assertEquals(shipData.Ship_Id, trx.Shipment_Id_gne__c, '[Shipped] Shipment ID is not valid');
	    		System.assertEquals(shipData.Pick_Num, trx.Pick_Slip_Number_gne__c, '[Shipped] Pick Number is not valid');
	    		System.assertNotEquals(null, trx.Shipped_Date_gne__c, '[Shipped] Shipment Date is not set');
	    		System.assertNotEquals(null, trx.Shipped_To_Address_By_Third_Party_gne__c, '[Shipped] Shipped Adddress is not set');
	    		System.assertEquals(shipData.Lot_No, trx.Lot_No_gne__c, '[Shipped] LOT NO is not valid');
	    		System.assertEquals(shipData.Carrier, trx.Carrier_gne__c, '[Shipped] Carrier is not valid');
	    		System.assert(trx.Tracking_Id_gne__c!=null && trx.Tracking_Id_gne__c.contains(shipData.Track_Id), '[Shipped] Track Id is not valid');
	    		System.assert(trx.Tracking_URL_gne__c!=null && trx.Tracking_URL_gne__c.contains(shipData.Track_URL), '[Shipped] Track URL is not valid');
	    		System.assertEquals(shipData.Txn_Qty, trx.Shipped_Quantity_gne__c.intValue(), '[Shipped] Shipped Qty is not valid');
				System.assertEquals(GNE_SFA2_PFG_Util.TRANSACTION_SIGNATURE_PENDING, trx.Signature_Status_gne__c, '[Shipped] Signature status is not valid');

				if(trx.RecordType.Name == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RFF) {
					System.assertEquals(shipData.Txn_Qty, trx.Call_PFG_Detail_Id_gne__r.Quantity_gne__c.intValue(), '[Shipped] Call PFG Detail Quantity is not valid');
					System.assertEquals(shipData.Ship_Id, trx.Call_PFG_Detail_Id_gne__r.Shipment_Id_gne__c, '[Shipped] Call PFG Detail Shipment ID is not valid');
					System.assertEquals(shipData.Lot_No, trx.Call_PFG_Detail_Id_gne__r.Lot_No_gne__c, '[Shipped] Call PFG Detail LOT NO is not valid');
					System.assertEquals(GNE_SFA2_PFG_Util.TRANSACTION_SIGNATURE_PENDING, trx.Call_PFG_Detail_Id_gne__r.DTP_AOC_Status_gne__c, '[Shipped] Call PFG Detail AOC Status is not valid');
				}
	    	}
    	}

    	if(orderStatusData!=null && (wfStatus == AocWorkflowStatus.ORDER_STATUS || wfStatus == AocWorkflowStatus.CANCELLED)) {
    		for(GNE_SFA2_PFG_REST_DTP_Order_Status.DtpOrderStatus  ordData : orderStatusData) {
    			System.assert(trxByRefNoCache.containsKey(ordData.Txn_ID), '[Order Status] Matching Transactions not found');

    			for(SFA2_PFG_Transaction_gne__c trx  : trxByRefNoCache.get(ordData.Txn_ID)) {
	    			System.assertEquals(ordData.Ord_Sts, trx.Delivery_Status_gne__c, '[Order Status] Delivery Status is not valid');
	    			System.assertEquals(ordData.Ord_Sts_Nt, trx.Order_Status_Note_gne__c, '[Order Status] Order Status Notes are not valid');
	    			System.assertNotEquals(null, trx.Order_Status_Last_Updated_gne__c, '[Order Status] Order Status Last Update Date is not set');

	    			if(trx.RecordType.Name == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RFF) {
	    				System.assertEquals(ordData.Ord_Sts, trx.Call_PFG_Detail_Id_gne__r.Order_Status_gne__c, '[Order Status] Call PFG Detail Order Status is not valid');
	    			}
	    		}
    		}
    	}

    	if(aocStatusData!=null && wfStatus == AocWorkflowStatus.AOC_STATUS) {
    		for(GNE_SFA2_PFG_REST_DTP_AOC_Status.DtpAocStatus  aocData : aocStatusData) {
    			SFA2_PFG_Transaction_gne__c trx = trxByNameCache.get(aocData.Txn_ID + '_' + aocData.Prod_Ln_ID);

	    		System.assertNotEquals(null, trx, '[AOC Status] Matching Transaction not found');

	    		String trxStatus = aocData.Sig_Sts == 'C' ? GNE_SFA2_PFG_Util.TRANSACTION_STATUS_COMPLETED : GNE_SFA2_PFG_Util.TRANSACTION_STATUS_SUBMITTED;
	    		String trxSigStatus = aocData.Sig_Sts == 'C' ? GNE_SFA2_PFG_Util.TRANSACTION_SIGNATURE_COMPLETE :
	    			(aocData.Sig_Sts == 'P' ? GNE_SFA2_PFG_Util.TRANSACTION_SIGNATURE_PENDING : GNE_SFA2_PFG_Util.TRANSACTION_SIGNATURE_INCOMPLETE);

	    		System.assertEquals(aocData.Ship_Id, trx.Shipment_Id_gne__c, '[AOC Status] Shipment ID is not valid');
	    		System.assertEquals(trxSigStatus, trx.Signature_Status_gne__c, '[AOC Status] Signature Status is not valid');
	    		System.assertEquals(trxStatus, trx.Status_gne__c, '[AOC Status] Status is not valid');

	    		if(aocData.Sig_Sts == SIGNATURE_COMPLETE_STATUS) {
	    			System.assertEquals(aocData.Txn_Qty, trx.Received_Quantity_gne__c.intValue(), '[AOC Status] Received Quantity is not valid');
        		}

    			if(trx.RecordType.Name == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RFF) {
    				System.assertEquals(trxSigStatus, trx.Call_PFG_Detail_Id_gne__r.DTP_AOC_Status_gne__c, '[AOC Status] Call PFG Detail AOC Status is not valid');
    			}
    		}
    	}

    	if(paperOrderData!=null && wfStatus == AocWorkflowStatus.PAPER_ORDER) {
    		for(GNE_SFA2_PFG_REST_DTP_Paper_Order.DtpPaperOrder  paperOrder : paperOrderData) {
    			SFA2_PFG_Transaction_gne__c trx = trxByNameCache.get(paperOrder.Txn_ID + '_' + paperOrder.Prod_Ln_ID);

    			System.assertNotEquals(null, trx, '[Paper Order] Matching Transaction not found');
	    		System.assertEquals(GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP, trx.Distribution_Method_gne__c,
	    				'[Paper Order] Distribution Method is not valid');
				System.assertEquals(GNE_SFA2_PFG_Util.LOT_NO_NA_VALUE, trx.Lot_No_gne__c, '[Paper Order] Lot # is not valid');
				System.assertEquals(paperOrder.Txn_ID, trx.Transaction_Ref_Number_gne__c, '[Paper Order] Transaction Ref Number is not valid');
				System.assertEquals(paperOrder.Prod_Ln_ID, trx.Line_Item_ID_gne__c, '[Paper Order] Line Item ID is not valid');
				System.assertNotEquals(null, trx.Transaction_Date_gne__c, '[Paper Order] Transaction Date is not valid');
				System.assertEquals(paperOrder.Prod_Nm, trx.Product_gne__r.Name, '[Paper Order] Product is not valid');
				System.assertEquals(paperOrder.NDC, trx.NDC_Number__c, '[Paper Order] NDC is not valid');
				System.assertEquals(paperOrder.Txn_Qty, trx.Requested_Quantity_gne__c.intValue(), '[Paper Order] Requested Quantity is not valid');
				System.assertEquals((Id)paperOrder.HCP_Id, trx.Account_gne__c, '[Paper Order] Account is not valid');
				System.assertEquals(paperOrder.HCP_Fst_Nm + ' ' + (String.isNotBlank(paperOrder.HCP_Mid_Init) ? paperOrder.HCP_Mid_Init + ' ' : '') + paperOrder.HCP_Lst_Nm, trx.Account_Name_gne__c, '[Paper Order] Account Name is not valid');
				System.assertEquals(paperOrder.MDM_Id, trx.Account_MDMID_gne__c, '[Paper Order] Account MDM ID is not valid');
				System.assertEquals(paperOrder.HCP_Add_Id, trx.Address_ID_gne__c, '[Paper Order] Address ID is not valid');
				System.assertEquals(paperOrder.HCP_Add_Ln_1, trx.Address_Line_1_gne__c, '[Paper Order] Address Line 1 is not valid');
				System.assertEquals(paperOrder.HCP_Add_Ln_2, trx.Address_Line_2_gne__c, '[Paper Order] Address Line 2 not valid');
				System.assertEquals(paperOrder.HCP_City, trx.City_gne__c, '[Paper Order] City is not valid');
				System.assertEquals(paperOrder.HCP_State, trx.State_gne__c, '[Paper Order] State is not valid');
				System.assertEquals(paperOrder.HCP_Zip, trx.Zip_gne__c, '[Paper Order] Zip is not valid');
				System.assertEquals(paperOrder.HCP_Fcty_Nm, trx.Facility_Name_gne__c, '[Paper Order] Facility Name is not valid');
				System.assertEquals(paperOrder.SLN, trx.SLN_gne__c, '[Paper Order] SLN is not valid');
				System.assertEquals(paperOrder.Prof_Des, trx.Designation_gne__c, '[Paper Order] Designation is not valid');
				System.assertEquals(paperOrder.Rep_ID, trx.CS_ID_gne__c, '[Paper Order] CS ID is not valid');
				System.assertEquals(paperOrder.Rep_Fst_Nm, trx.CS_First_Name_gne__c, '[Paper Order] CS First Name is not valid');
				System.assertEquals(paperOrder.Rep_Lst_Nm, trx.CS_Last_Name_gne__c, '[Paper Order] CS Last Name is not valid');
				System.assertEquals(paperOrder.Rep_eMail, trx.CS_Email_gne__c, '[Paper Order] CS Email is not valid');
				System.assertEquals(paperOrder.Rep_Unix_ID, trx.From_User_gne__r.External_Id_gne__c, '[Paper Order] From User is not valid');
				System.assertEquals(paperOrder.Terr_Nm, trx.From_Territory_Name_gne__c, '[Paper Order] Territory Name is not valid');
				System.assertEquals(paperOrder.Terr_No, trx.From_Territory_Number_gne__c, '[Paper Order] Territory Number is not valid');
				System.assertNotEquals(null, trx.From_User_Territory_gne__c, '[Paper Order] Territory ID is not set');
    		}
    	}
	}

    public class AccountTestHelper {

		public Map<Id,Account> accountsCache;
		public Map<String,Set<Id>> accountsByTypeCache;
		public Map<String,Id> accRecTypesCache;
		public Map<String,Id> addrRecTypesCache;

		public final String HCP_RECORD_TYPE_NAME = 'Health Care Professional';
		public final String HCO_RECORD_TYPE_NAME = 'Hospital';
		public final String ADDRESS_RECORD_TYPE_NAME = 'Rep Maintained';

		public void insertAccountsWithAddresses(Integer numberOfAccts, Id ownerId) {
			cacheRecordTypes();
			GNE_SFA2_Account_Trigger_Helper.setAccountTrig(true);
			GNE_SFA2_Address_Trigger_Helper.setAddressTrig(true);

			List<Account> accountsToInsert = new List<Account>();
			List<Address_vod__c> addressesToInsert = new List<Address_vod__c>();

			String hcpFirstName = 'JOHN', hcpLastName = 'SMITH', hcoName = 'MEDICAL CENTER';
			String addressName = 'TEST STREET', addressLine2 = 'STE', city = 'SAN FRANCISCO', state = 'CA', zip = '99999', zip4 = '1111';

			Integer idx = 0;
			for(String mode : new String[]{'HCP','HCO'}) {
				Id recTypeId = accRecTypesCache.get(mode);

				for(Integer i = 0; i < numberOfAccts; i++) {
					idx++;
					Account acc = new Account(
						RecordTypeId = recTypeId,
						OwnerId = ownerId);

					if(mode.equals('HCP')) {
						acc.FirstName = hcpFirstName + idx;
						acc.LastName = hcpLastName + idx;
					} else {
						acc.Name = hcoName;
					}

					accountsToInsert.add(acc);
				}
			}

			insert accountsToInsert;

			idx = 0;
			for(Account acc : accountsToInsert) {
				idx++;
				Id recTypeId = addrRecTypesCache.get(getAccountType(acc));

				Address_vod__c addr = new Address_vod__c(
					RecordTypeId = recTypeId,
					Account_vod__c = acc.Id,
					Name = addressName + ' ' + idx,
					Address_Line_2_vod__c = addressLine2 + ' ' + idx,
					Primary_vod__c = true,
					City_vod__c = city,
					State_vod__c = state,
					Zip_vod__c = zip,
					Zip_4_vod__c = zip4,
					License_vod__c = SLN,
					License_Status_vod__c = 'Valid_vod',
					License_Expiration_Date_vod__c = System.today().addDays(365));

				addressesToInsert.add(addr);
			}

			insert addressesToInsert;

			cacheAccounts(new Map<Id,Account>(accountsToInsert).keySet());

			GNE_SFA2_Account_Trigger_Helper.setAccountTrig(false);
			GNE_SFA2_Address_Trigger_Helper.setAddressTrig(false);
		}

		private void cacheRecordTypes() {
			accRecTypesCache = new Map<String,Id>();
			List<Schema.RecordTypeInfo> rtInfos = Account.getSobjectType().getDescribe().getRecordTypeInfos();

		    for(Schema.RecordTypeInfo rtInfo : rtInfos) {
		       	Id rtId = rtInfo.getRecordTypeId();
		        String rtName = rtInfo.getName();
		    	if(rtName == HCP_RECORD_TYPE_NAME) {
		    		accRecTypesCache.put('HCP', rtId);
		    	} else if(rtName == HCO_RECORD_TYPE_NAME) {
		    		accRecTypesCache.put('HCO', rtId);
		    	}
		    }

		    addrRecTypesCache = new Map<String,Id>();
			rtInfos = Address_vod__c.getSobjectType().getDescribe().getRecordTypeInfos();

		    for(Schema.RecordTypeInfo rtInfo : rtInfos) {
		       	Id rtId = rtInfo.getRecordTypeId();
		        String rtName = rtInfo.getName();
		    	if(rtName == ADDRESS_RECORD_TYPE_NAME) {
		    		addrRecTypesCache.put('HCP', rtId);
		    		addrRecTypesCache.put('HCO', rtId);
		    	}
		    }
		}

		public void cacheAccounts(Set<Id> accIds) {
			List<Account> accs = [
				SELECT Id, Name, OwnerId, FirstName, LastName, IsPersonAccount, RecordTypeId, RecordType.Name, MDMID_gne__c,
					(SELECT Id, Primary_vod__c, Account_vod__c, Name, Address_Line_2_vod__c, City_vod__c,
						State_vod__c, Zip_vod__c, Zip_4_vod__c, Province_can_gne__c, Postal_Code_can_gne__c
					 FROM Address_vod__r)
				FROM Account
				WHERE Id IN :accIds
			];

			for(Account acc : accs) {
				cacheAccount(acc);
			}
		}

		public void cacheAccount(Account acc) {
			if(accountsCache==null) {
				accountsCache = new Map<Id,Account>();
				accountsByTypeCache = new Map<String,Set<Id>>{
					'HCP' => new Set<Id>(),
					'HCO' => new Set<Id>()
				};
			}

			accountsCache.put(acc.Id, acc);
			String accType = getAccountType(acc);
			accountsByTypeCache.get(accType).add(acc.Id);
		}

		private String getAccountType(Account acc) {
			String accMode = acc.RecordTypeId == accRecTypesCache.get('HCP') ? 'HCP' : 'HCO';
			return accMode;
		}
	}

	public class VeQtyChecker {
		private GNE_SFA2_PFG_VE_QtyChecker_Batch qtyChecker;
		private GNE_SFA2_PFG_VE_HcpQtyChecker_Batch hcpQtyChecker;
		public VeQtyChecker() {
			qtyChecker = new GNE_SFA2_PFG_VE_QtyChecker_Batch();
			hcpQtyChecker = new GNE_SFA2_PFG_VE_HcpQtyChecker_Batch();
		}

		public void assertQty(Boolean rffAborted) {
			Set<String> validRecordTypes = new Set<String>{
				GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION,
				GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION_TRANSFER,
				GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RFF,
				GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_DTP_PAPER_ORDER};
			String distributionType = GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP;
			Set<String> excludedDeliveryStatuses = GNE_SFA2_PFG_Util.TRANSACTION_DELIVERY_ABORT_STATUSES;
			Object tmpVar1 = validRecordTypes;
			Object tmpVar2 = distributionType;
			Object tmpVar3 = excludedDeliveryStatuses;

			Database.QueryLocator ql = qtyChecker.start(null);
			List<SObject> scope = Database.query(ql.getQuery());

			System.assertNotEquals(0, scope.size(), 'No DTP Transaction found for Qty Validation');
			qtyChecker.execute(null, scope);
			qtyChecker.finish(null);

			String reportText = '';

			for(SFA2_PFG_Report_gne__c report : [SELECT Report_Id_gne__c FROM SFA2_PFG_Report_gne__c LIMIT 1]) {
				reportText = ' REPORT JSON: ' + GNE_SFA2_PFG_Report_Engine.getReportInJSON(report.Report_Id_gne__c);
			}

			System.assertEquals(0, qtyChecker.reportRowsWrappers.size(), 'Qty Exception found' + reportText + ', ROWS: ' + String.valueOf(qtyChecker.reportRowsWrappers));

			validRecordTypes = new Set<String>{
				GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RFF,
				GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_DTP_PAPER_ORDER};
			tmpVar1 = validRecordTypes;

			ql = hcpQtyChecker.start(null);
			scope = Database.query(ql.getQuery());

			if(rffAborted) {
				System.assertEquals(0, scope.size(), 'DTP Transaction found for Hcp Qty Validation');
			} else {
				System.assertNotEquals(0, scope.size(), 'No DTP Transaction found for Hcp Qty Validation');
			}


			hcpQtyChecker.execute(null, scope);
			hcpQtyChecker.finish(null);

			for(SFA2_PFG_Report_gne__c report : [SELECT Report_Id_gne__c FROM SFA2_PFG_Report_gne__c LIMIT 1]) {
				reportText = ' REPORT JSON: ' + GNE_SFA2_PFG_Report_Engine.getReportInJSON(report.Report_Id_gne__c);
			}

			System.assertEquals(0, hcpQtyChecker.reportRowsWrappers.size(), 'HCP Qty Exception found' + reportText);

		}
	}
}