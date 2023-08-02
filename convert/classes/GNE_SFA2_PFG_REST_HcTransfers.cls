@RestResource(urlMapping='/sfa2_hc_tsf_outbound_R1/*')
global with sharing class GNE_SFA2_PFG_REST_HcTransfers extends GNE_SFA2_PFG_REST_Base {
	global class ResultSet extends GNE_SFA2_PFG_REST_Base.ResultSet {
		public List<HcTransfer> records = new List<HcTransfer>();
	}
	
	global class HcTransfer {
		public String Txn_ID;
		public String Txn_Date;
		public String Txn_Type;
		public String Prod_Ln_ID;
		public Integer Txn_Qty;
		public String NDC;
		public String Prod_Nm;
		public String Lot;
		public String From_User;
		public String To_User;
		public String Rec_Dt;
		public Integer Rec_Qty;
		
		public HcTransfer(SFA2_PFG_Transaction_gne__c trnRec) {
			Txn_ID		= trnRec.Transaction_Ref_Number_gne__c;
			Txn_Date	= GNE_SFA2_PFG_REST_Utils.formatDate(trnRec.Transaction_Date_gne__c, 'MM/dd/yyyy');
			Txn_Type	= trnRec.Transaction_Type_gne__c;
			Prod_Ln_ID	= trnRec.Name;
			Txn_Qty		= trnRec.Requested_Quantity_gne__c!=null ? trnRec.Requested_Quantity_gne__c.intValue() : null;
			NDC			= trnRec.Product_gne__r.NDC_Number_gne__c;
			Prod_Nm		= trnRec.Product_gne__r.Name;
			Lot			= trnRec.Lot_No_gne__c;
			From_User	= trnRec.From_User_gne__r.External_ID_gne__c;
			To_User		= trnRec.To_User_gne__r.External_ID_gne__c;
			Rec_Dt		= GNE_SFA2_PFG_REST_Utils.formatDate(trnRec.Receipt_Date_gne__c, 'MM/dd/yyyy');
			Rec_Qty		= trnRec.Received_Quantity_gne__c!=null ? trnRec.Received_Quantity_gne__c.intValue() : null;
		}
	}
	
	@HttpPost
	global static ResultSet getHcTransfers(String lastSyncDate) {
		return (ResultSet)(new GNE_SFA2_PFG_REST_HcTransfers()).prepareOutputObjects(lastSyncDate, new ResultSet());
	}
	
	protected override void intPrepareOutputObjects(DateTime lastSyncDateTime, GNE_SFA2_PFG_REST_Base.ResultSet a_result) {
		ResultSet result = (ResultSet)a_result;
		
		for(SFA2_PFG_Transaction_gne__c trnRec : GNE_SFA2_PFG_REST_DAO.getHcTransfers(lastSyncDateTime)) {
			result.records.add(new HcTransfer(trnRec));
		}
	}
}