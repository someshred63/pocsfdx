@RestResource(urlMapping='/sfa2_ship_rt_outbound_R1/*')
global with sharing class GNE_SFA2_PFG_REST_HcShipmentReceipts extends GNE_SFA2_PFG_REST_Base {
    global class ResultSet extends GNE_SFA2_PFG_REST_Base.ResultSet {
        public List<HcShipmentReceipt> records = new List<HcShipmentReceipt>();
    }
        
    global class HcShipmentReceipt {
        public String Txn_ID;
        public String Ord_ID;
        public String Shp_ID;
        public String To_User;
        public String Rec_Date;
        public String NDC;
        public String Prod_Nm;
        public String Lot;
        public Integer Rec_Qty;
        
        public HcShipmentReceipt(SFA2_PFG_Transaction_gne__c trnRec) {
            Txn_ID      = trnRec.Name;
            Ord_ID      = trnRec.Transaction_Ref_Number_gne__c;
            Shp_ID      = trnRec.Shipment_Id_gne__c;
            To_User     = trnRec.To_User_gne__r.External_ID_gne__c;
            Rec_Date    = GNE_SFA2_PFG_REST_Utils.formatDate(trnRec.Receipt_Date_gne__c, 'MM/dd/yyyy');
            NDC         = trnRec.Product_gne__r.NDC_Number_gne__c;
            Prod_Nm     = trnRec.Product_gne__r.Name;
            Lot         = trnRec.Lot_No_gne__c;
            Rec_Qty     = trnRec.Received_Quantity_gne__c!=null ? trnRec.Received_Quantity_gne__c.intValue() : null;
        }
    }
    
    @HttpPost
	global static ResultSet getShipmentReceipts(String lastSyncDate) {
		return (ResultSet)(new GNE_SFA2_PFG_REST_HcShipmentReceipts()).prepareOutputObjects(lastSyncDate, new ResultSet());
	}
	
	protected override void intPrepareOutputObjects(DateTime lastSyncDateTime, GNE_SFA2_PFG_REST_Base.ResultSet a_result) {
		ResultSet result = (ResultSet)a_result;
		
		for(SFA2_PFG_Transaction_gne__c trnRec : GNE_SFA2_PFG_REST_DAO.getHcShipmentReceipts(lastSyncDateTime)) {
            result.records.add(new HcShipmentReceipt(trnRec));
        }
	}
}