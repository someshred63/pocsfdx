@RestResource(urlMapping='/sfa2_hc_inv_ct_outbound_R1/*')
global with sharing class GNE_SFA2_PFG_REST_HcInventoryCounts extends GNE_SFA2_PFG_REST_Base {
    global class ResultSet extends GNE_SFA2_PFG_REST_Base.ResultSet {
        public List<InventoryCount> records = new List<InventoryCount>();
    }
    
    global class InventoryCount {
        public String Ct_ID;
        public String Ct_Typ;
        public String Ct_Dt;
        public String User;
        public String Line_ID;
        public String NDC;
        public String Prod_Nm;
        public String Lot;
        public Integer Ct_Qty;
                
        public InventoryCount(SFA2_PFG_Inventory_Count_gne__c icRec) {
            Ct_ID   = icRec.Inventory_Ref_Number_gne__c;
            Ct_Typ  = icRec.Inventory_Type_gne__c;
            Ct_Dt   = GNE_SFA2_PFG_REST_Utils.formatDate(icRec.Inventory_Count_Date_gne__c, 'MM/dd/yyyy');
            User    = icRec.Inventory_For_gne__r.External_ID_gne__c;
            Line_ID = icRec.Name;
            NDC     = icRec.Product_gne__r.NDC_Number_gne__c;
            Prod_Nm = icRec.Product_gne__r.Name;
            Lot     = icRec.Lot_gne__c;
            Ct_Qty  = icRec.Count_gne__c!=null ? icRec.Count_gne__c.intValue() : null;
        }
    }
    
    @HttpPost
	global static ResultSet getInventoryCounts(String lastSyncDate) {
		return (ResultSet)(new GNE_SFA2_PFG_REST_HcInventoryCounts()).prepareOutputObjects(lastSyncDate, new ResultSet());
	}
	
	protected override void intPrepareOutputObjects(DateTime lastSyncDateTime, GNE_SFA2_PFG_REST_Base.ResultSet a_result) {
        ResultSet result = (ResultSet)a_result;
        
        for(SFA2_PFG_Inventory_Count_gne__c icRec : GNE_SFA2_PFG_REST_DAO.getInventoryCounts(lastSyncDateTime)) {
            result.records.add(new InventoryCount(icRec));
        }
	}
}