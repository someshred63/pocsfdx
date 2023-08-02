@RestResource(urlMapping='/sfa2_hc_adj_outbound_R1/*')
global with sharing class GNE_SFA2_PFG_REST_HcAdjustments extends GNE_SFA2_PFG_REST_Base {
    global class ResultSet extends GNE_SFA2_PFG_REST_Base.ResultSet {
        public List<HcAdjustment> records = new List<HcAdjustment>();
    }
    
    global class HcAdjustment {
        public String Txn_ID;
        public String Txn_Date;
        public String Txn_Type;
        public String Txn_Reas;
        public Integer Txn_Qty;
        public String NDC;
        public String Prod_Nm;
        public String Lot;
        public String From_User;
        public String Call_ID;
        
        public HcAdjustment(SFA2_PFG_Transaction_gne__c trnRec) {
            Txn_ID      = trnRec.Name;
            Txn_Date    = GNE_SFA2_PFG_REST_Utils.formatDate(trnRec.Transaction_Date_gne__c, 'MM/dd/yyyy');
            Txn_Type    = trnRec.Transaction_Type_gne__c;
            Txn_Reas    = trnRec.Transaction_Reason_gne__c;
            Txn_Qty     = trnRec.Requested_Quantity_gne__c!=null ? trnRec.Requested_Quantity_gne__c.intValue() : null;
            NDC         = trnRec.Product_gne__r.NDC_Number_gne__c;
            Prod_Nm     = trnRec.Product_gne__r.Name;
            Lot         = trnRec.Lot_No_gne__c;
            From_User   = trnRec.From_User_gne__r.External_ID_gne__c;
            Call_ID     = trnRec.Call_PFG_Detail_ID_gne__r.Call_gne__r.Name;
        }
    }
    
    @HttpPost
	global static ResultSet getHcAdjustments(String lastSyncDate) {
		return (ResultSet)(new GNE_SFA2_PFG_REST_HcAdjustments()).prepareOutputObjects(lastSyncDate, new ResultSet());
	}
	
	protected override void intPrepareOutputObjects(DateTime lastSyncDateTime, GNE_SFA2_PFG_REST_Base.ResultSet a_result) {
		ResultSet result = (ResultSet)a_result;
        
        for(SFA2_PFG_Transaction_gne__c trnRec : GNE_SFA2_PFG_REST_DAO.getHcAdjustments(lastSyncDateTime)) {
            result.records.add(new HcAdjustment(trnRec));
        }
	}
}