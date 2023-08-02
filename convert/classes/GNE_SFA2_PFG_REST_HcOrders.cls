@RestResource(urlMapping='/sfa2_hc_orders_outbound_R1/*')
global with sharing class GNE_SFA2_PFG_REST_HcOrders extends GNE_SFA2_PFG_REST_Base {
    global class ResultSet extends GNE_SFA2_PFG_REST_Base.ResultSet {
        public List<HcOrder> records = new List<HcOrder>();
    }
        
    global class HcOrder {
        public String Ord_ID;
        public String Txn_ID;
        public String Ord_Date;
        public String Ord_Typ;
        public String User_Id;
        public String User_Fst_Nm;
        public String User_Lst_Nm;
        public String Stor_Loc_Id;
        public String NDC;
        public String Prod_Nm;
        public Integer Txn_Qty;
        
        public HcOrder(SFA2_PFG_Transaction_gne__c trnRec, SFA2_PFG_Storage_Location_gne__c sl) {
            Ord_ID      = trnRec.Name;
            Txn_ID      = trnRec.Name;
            Ord_Date    = GNE_SFA2_PFG_REST_Utils.formatDate(trnRec.Shipment_Request_Date_gne__c, 'MM/dd/yyyy');
            Ord_Typ     = trnRec.Distribution_Method_gne__c;
            User_Id     = trnRec.To_User_gne__r.External_ID_gne__c;
            User_Fst_Nm = trnRec.To_User_gne__r.FirstName;
            User_Lst_Nm = trnRec.To_User_gne__r.LastName;
            Stor_Loc_Id = sl!=null ? sl.Name : null;
            NDC         = trnRec.Product_gne__r.NDC_Number_gne__c;
            Prod_Nm     = trnRec.Product_gne__r.Name;
            Txn_Qty     = trnRec.Requested_Quantity_gne__c!=null ? trnRec.Requested_Quantity_gne__c.intValue() : null;
        }
    }
    
    @HttpPost
	global static ResultSet getOrders(String lastSyncDate) {
		return (ResultSet)(new GNE_SFA2_PFG_REST_HcOrders()).prepareOutputObjects(lastSyncDate, new ResultSet());
	}
	
	protected override void intPrepareOutputObjects(DateTime lastSyncDateTime, GNE_SFA2_PFG_REST_Base.ResultSet a_result) {
		ResultSet result = (ResultSet)a_result;
		
		List<SFA2_PFG_Transaction_gne__c> trns = GNE_SFA2_PFG_REST_DAO.getHcOrders(lastSyncDateTime);
        Set<Id> userIds = new Set<Id>();
            
        for(SFA2_PFG_Transaction_gne__c trnRec : trns) {
            userIds.add(trnRec.To_User_gne__c);
        }
            
        GNE_SFA2_PFG_Util.cacheStorageLocations(GNE_SFA2_PFG_DAO.getStorageLocationsByUserIds(userIds),true);
            
        for(SFA2_PFG_Transaction_gne__c trnRec : trns) {
            result.records.add(new HcOrder(trnRec, GNE_SFA2_PFG_Util.getApprovedStorageLocationForUser(trnRec.To_User_gne__c)));
        }
	}
}