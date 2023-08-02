@RestResource(urlMapping='/sfa2_dtp_ordstatus_inbound_R1/*')
global with sharing class GNE_SFA2_PFG_REST_DTP_Order_Status extends GNE_SFA2_PFG_REST_Base {
    global class ResultSet extends GNE_SFA2_PFG_REST_Base.ResultSet {
        public transient List<SFA2_PFG_Transaction_gne__c> trxsToUpdate;
        public transient Map<Id,Call_PFG_Detail_gne__c> cDetailsToUpdate;
    }
    
    global class DtpOrderStatus {
        public String Txn_ID;
        public String Ord_Sts;
        public String Ord_Sts_Nt;
        public String Ord_Sts_Lst_Updt;
        
        public void updateTransaction(SFA2_PFG_Transaction_gne__c trx) {
            trx.Delivery_Status_gne__c              = Ord_Sts;
            trx.Order_Status_Note_gne__c            = Ord_Sts_Nt;
            trx.Order_Status_Last_Updated_gne__c    = GNE_SFA2_PFG_REST_Utils.parseDateTimeGmt(Ord_Sts_Lst_Updt);
        }
        
        public Call_PFG_Detail_gne__c updateCallDetail(Id callDetailId) {
            return new Call_PFG_Detail_gne__c(Id = callDetailId, Order_Status_gne__c = Ord_Sts);
        }
    }
    
    @HttpPost
    global static ResultSet setOrderStatus(List<DtpOrderStatus> records) {
        return (ResultSet)(new GNE_SFA2_PFG_REST_DTP_Order_Status()).processInputObjects(records, new ResultSet());
    }
    
    protected override void intProcessInputObjects(List<Object> a_inputObjects, GNE_SFA2_PFG_REST_Base.ResultSet a_result) {
        List<DtpOrderStatus> orderStatuses = (List<DtpOrderStatus>)a_inputObjects;
        ResultSet result = (ResultSet)a_result;
        
        
        Map<String,DtpOrderStatus> refNoToOrderStatus = new Map<String,DtpOrderStatus>();
        
        for(DtpOrderStatus orderStatusWrapper : orderStatuses) {
            refNoToOrderStatus.put(orderStatusWrapper.Txn_ID,orderStatusWrapper);
        }
        
        List<SFA2_PFG_Transaction_gne__c> trxsToUpdate = result.trxsToUpdate = GNE_SFA2_PFG_REST_DAO.getDtpOrderStatus(refNoToOrderStatus.keySet());
        Map<Id,Call_PFG_Detail_gne__c> cDetailsToUpdate = result.cDetailsToUpdate = new Map<Id,Call_PFG_Detail_gne__c>();
        for(SFA2_PFG_Transaction_gne__c trx : trxsToUpdate) {
            DtpOrderStatus orderStatusWrapper = refNoToOrderStatus.get(trx.Transaction_Ref_Number_gne__c);
            orderStatusWrapper.updateTransaction(trx);
            if(trx.Call_PFG_Detail_ID_gne__c!=null && !cDetailsToUpdate.containsKey(trx.Call_PFG_Detail_ID_gne__c)) {
                Call_PFG_Detail_gne__c cDetail = orderStatusWrapper.updateCallDetail(trx.Call_PFG_Detail_ID_gne__c);
                cDetailsToUpdate.put(trx.Call_PFG_Detail_ID_gne__c, cDetail);
            }
        }
    }
    
    protected override void executeDmls(GNE_SFA2_PFG_REST_Base.ResultSet a_result) {
        ResultSet result = (ResultSet)a_result;
        
        if(!result.trxsToUpdate.isEmpty()) {
            update result.trxsToUpdate;
        }
        
        if(!result.cDetailsToUpdate.isEmpty()) {
            update result.cDetailsToUpdate.values();
        }
    }
}