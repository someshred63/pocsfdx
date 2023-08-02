@RestResource(urlMapping='/sfa2_dtp_alloctransfers_outbound_R1/*')
global with sharing class GNE_SFA2_PFG_REST_DTP_AllocTransfers extends GNE_SFA2_PFG_REST_Base {
    global class ResultSet extends GNE_SFA2_PFG_REST_Base.ResultSet {
        public List<DtpAllocationTransfers> records = new List<DtpAllocationTransfers>();
    }

    global class DtpAllocationTransfers {
        public String Txn_ID;
        public String Txn_Date;
        public String Txn_Type;
        public Integer Txn_Qty;
        public String NDC;
        public String Prod_Nm;
        public String From_Terr;
        public String To_Terr;

        public DtpAllocationTransfers(SFA2_PFG_Transaction_gne__c trnRec) {
            Txn_ID      = trnRec.Name;
            Txn_Date    = GNE_SFA2_PFG_REST_Utils.formatDate(trnRec.Transaction_Date_gne__c, 'MM/dd/yyyy');
            Txn_Type    = trnRec.Transaction_Type_gne__c;
            Txn_Qty     = trnRec.Received_Quantity_gne__c!=null ? trnRec.Received_Quantity_gne__c.intValue() : null;
            NDC         = trnRec.Product_gne__r.NDC_Number_gne__c;
            Prod_Nm     = trnRec.Product_gne__r.Name;
            From_Terr   = trnRec.From_Territory_Number_gne__c;
            To_Terr     = trnRec.To_Territory_Number_gne__c;
        }
    }

    @HttpPost
    global static ResultSet getDtpAllocationTransfers(String lastSyncDate, List<String> trxIds) {
    	ResultSet result = null;
    	GNE_SFA2_PFG_REST_DTP_AllocTransfers service = new GNE_SFA2_PFG_REST_DTP_AllocTransfers();
    	if(trxIds!=null && !trxIds.isEmpty()) {
    		result = (ResultSet)service.prepareOutputObjects(trxIds, new ResultSet());
    	} else {
    		result = (ResultSet)service.prepareOutputObjects(lastSyncDate, new ResultSet());
    	}
        return result;
    }

    protected override void intPrepareOutputObjects(Object inputData, GNE_SFA2_PFG_REST_Base.ResultSet a_result) {
        ResultSet result = (ResultSet)a_result;

        Set<String> csTerrNames = new Set<String>();

        for(Territory2 csTerr : GNE_SFA2_PFG_Util.getAllCsTerritories()) {
            csTerrNames.add(csTerr.Name);
        }

        for(SFA2_PFG_Transaction_gne__c trnRec : GNE_SFA2_PFG_REST_DAO.getDtpAllocationTansfers(inputData)) {
            if(csTerrNames.contains(trnRec.To_Territory_Name_gne__c) || csTerrNames.contains(trnRec.From_Territory_Name_gne__c)) {
               	result.records.add(new DtpAllocationTransfers(trnRec));
            }
        }
    }
}