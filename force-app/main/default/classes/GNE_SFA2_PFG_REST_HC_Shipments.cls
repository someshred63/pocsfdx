@RestResource(urlMapping='/sfa2_hc_shipments_inbound_R1/*')
global with sharing class GNE_SFA2_PFG_REST_HC_Shipments extends GNE_SFA2_PFG_REST_Base {
	global class ResultSet extends GNE_SFA2_PFG_REST_Base.ResultSet {
		public transient List<SFA2_PFG_Transaction_gne__c> trxsToUpdate;
	}
	
	global class HcShipment {
		public String Ship_Id;
		public String Txn_Ref_ID;
		public String Txn_id;
		public String Pick_Num;
		public String Ship_Date;
		public String To_User;
		public String Add_Ln_1;
		public String Add_Ln_2;
		public String City;
		public String State;
		public String Zip;
		public String Zip_Ext;
		public String NDC;
		public String Prod_Nm;
		public String Lot_No;
		public Integer Txn_Qty;
		public String Carrier;
		public String Track_Id;
		public String Track_URL;
		
		public void updateTransaction(SFA2_PFG_Transaction_gne__c trx) {
			trx.Shipment_Id_gne__c = Ship_Id;
			trx.Pick_Slip_Number_gne__c = Pick_Num;
			trx.Shipped_Date_gne__c = GNE_SFA2_PFG_REST_Utils.parseDateTime(Ship_Date).dateGmt();
			trx.To_User_gne__c = To_User;
			trx.Shipped_To_Address_By_Third_Party_gne__c = getAddressDescription();
			trx.Lot_No_gne__c = Lot_No;
			trx.Shipped_Quantity_gne__c = Txn_Qty;
			trx.Carrier_gne__c = Carrier;
			
			if(String.isBlank(trx.Tracking_Id_gne__c) || !trx.Tracking_Id_gne__c.endsWith(Track_Id)) {
				trx.Tracking_Id_gne__c = (String.isBlank(trx.Tracking_Id_gne__c) ? Track_Id : (trx.Tracking_Id_gne__c + '\n' + Track_Id));
			}
			
			if(String.isBlank(trx.Tracking_URL_gne__c) || !trx.Tracking_URL_gne__c.endsWith(Track_URL)) {
				trx.Tracking_URL_gne__c = (String.isBlank(trx.Tracking_URL_gne__c) ? Track_URL : (trx.Tracking_URL_gne__c + '\n' + Track_URL));
			}
		}
		
		private String getAddressDescription() {
			return String.join(new List<String>{Add_Ln_1,Add_Ln_2,City,State,Zip},'||');
		}
	}
	
	@HttpPost
	global static ResultSet setShipments(List<HcShipment> records) {
		return (ResultSet)(new GNE_SFA2_PFG_REST_HC_Shipments()).processInputObjects(records, new ResultSet());
	}
	
	protected override void intProcessInputObjects(List<Object> a_inputObjects, GNE_SFA2_PFG_REST_Base.ResultSet a_result) {
		List<HcShipment> shipments = (List<HcShipment>)a_inputObjects;
		ResultSet result = (ResultSet)a_result;
		
		
		Map<String,HcShipment> refNoToShipments = new Map<String,HcShipment>();
		
		for(HcShipment shipmentsWrapper : shipments) {
			refNoToShipments.put(shipmentsWrapper.Txn_Ref_ID,shipmentsWrapper);
		}
		
		List<SFA2_PFG_Transaction_gne__c> trxsToUpdate = result.trxsToUpdate = GNE_SFA2_PFG_REST_DAO.getHcShipments(refNoToShipments.keySet());
		
		for(SFA2_PFG_Transaction_gne__c trx : trxsToUpdate) {
			HcShipment shipmentsWrapper = refNoToShipments.get(trx.Transaction_Ref_Number_gne__c);
			shipmentsWrapper.updateTransaction(trx);
		}
	}
	
	protected override void executeDmls(GNE_SFA2_PFG_REST_Base.ResultSet a_result) {
		ResultSet result = (ResultSet)a_result;
		
		if(!result.trxsToUpdate.isEmpty()) {
			update result.trxsToUpdate;
		}
	}
}