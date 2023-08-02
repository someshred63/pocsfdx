@RestResource(urlMapping='/sfa2_dtp_aoc_outbound_R1/*')
global with sharing class GNE_SFA2_PFG_REST_DTP_AOC_Signatures extends GNE_SFA2_PFG_REST_Base {
    global class ResultSet extends GNE_SFA2_PFG_REST_Base.ResultSet {
        public List<DtpAocSignature> records = new List<DtpAocSignature>();
    }
    
    global class DtpAocSignature {
        public String Txn_ID;
        public String Ship_ID;
        public String Call_ID;
        public String AOC_Status;
        public String AOC_Date;
        public String AOC_Time;
        public String Sig;
        
        public DtpAocSignature(SFA2_PFG_Transaction_gne__c trnRec) {
            Txn_ID      = trnRec.Transaction_Ref_Number_gne__c;
            Ship_ID     = trnRec.Shipment_Id_gne__c;
            Call_ID     = trnRec.Call_PFG_Detail_ID_gne__r.Call_gne__r.Name;
            AOC_Status  = trnRec.Signature_Status_gne__c;
            AOC_Date    = GNE_SFA2_PFG_REST_Utils.formatDate(trnRec.Signature_Date_gne__c, 'MM/dd/yyyy');
            AOC_Time    = GNE_SFA2_PFG_REST_Utils.formatDateTime(trnRec.Signature_Date_gne__c, 'HH:mm:ss');
            Sig         = trnRec.Signature_gne__c;
        }
    }
        
    @HttpPost
    global static ResultSet getAocSignatures(String lastSyncDate, List<String> trxIds) {
        ResultSet result = null;
    	GNE_SFA2_PFG_REST_DTP_AOC_Signatures service = new GNE_SFA2_PFG_REST_DTP_AOC_Signatures();
    	if(trxIds!=null && !trxIds.isEmpty()) {
    		result = (ResultSet)service.prepareOutputObjects(trxIds, new ResultSet());
    	} else {
    		result = (ResultSet)service.prepareOutputObjects(lastSyncDate, new ResultSet());
    	}
        return result;
    }
    
    protected override void intPrepareOutputObjects(Object inputData, GNE_SFA2_PFG_REST_Base.ResultSet a_result) {
        ResultSet result = (ResultSet)a_result;
    
        Set<String> visitedRefNos = new Set<String>();
    
        for(SFA2_PFG_Transaction_gne__c trnRec : GNE_SFA2_PFG_REST_DAO.getDtpAOCs(inputData)) {
            if(trnRec.Transaction_Ref_Number_gne__c!=null && !visitedRefNos.contains(trnRec.Transaction_Ref_Number_gne__c.toUpperCase())) {
                result.records.add(new DtpAocSignature(trnRec));
                visitedRefNos.add(trnRec.Transaction_Ref_Number_gne__c.toUpperCase());  
            }
        }
    }
}