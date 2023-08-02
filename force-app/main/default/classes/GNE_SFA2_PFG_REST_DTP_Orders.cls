@RestResource(urlMapping='/sfa2_dtp_orders_outbound_R1/*')
global with sharing class GNE_SFA2_PFG_REST_DTP_Orders extends GNE_SFA2_PFG_REST_Base {
    global class ResultSet extends GNE_SFA2_PFG_REST_Base.ResultSet {
        public List<DtpOrder> records = new List<DtpOrder>();
    }
        
    global class DtpOrder {
        public String Txn_ID;
        public String Call_ID;
        public String Txn_Date;
        public String Txn_Type;
        public String Prod_Ln_ID;
        public Integer Txn_Qty;
        public String NDC;
        public String Prod_Nm;
        public String HCP_Id;
        public String MDM_Id;
        public String HCP_Fst_Nm;
        public String HCP_Mid_Init;
        public String HCP_Lst_Nm;
        public String HCP_Add_Id;
        public String HCP_Add_Ln_1;
        public String HCP_Add_Ln_2;
        public String HCP_City;
        public String HCP_State;
        public String HCP_Zip;
        public String HCP_Zip_E;
        public String HCP_Phn;
        public String HCP_Fax;
        public String HCP_eMail;
        public String HCP_Bdtd;
        public String SLN;
        public String Prof_Des;
        public String Sig_Cap_Dt;
        public String Sig_Cap_Tm;
        public String Sig;
        public String Rep_Fst_Nm;
        public String Rep_Lst_Nm;
        public String HCP_Spec;
        public String Rep_Unix_ID;
                
        public DtpOrder(SFA2_PFG_Transaction_gne__c trnRec) {
        	
            Txn_ID          = trnRec.Transaction_Ref_Number_gne__c;
            Call_ID         = trnRec.Call_PFG_Detail_ID_gne__r.Call_gne__r.Name;
            Txn_Date        = GNE_SFA2_PFG_REST_Utils.formatDateTime(trnRec.Transaction_Date_gne__c, 'MM/dd/yyyy HH:mm:ss');
            Txn_Type        = trnRec.Transaction_Type_gne__c;
            Prod_Ln_ID      = trnRec.Name;
            Txn_Qty         = trnRec.Requested_Quantity_gne__c!=null ? trnRec.Requested_Quantity_gne__c.intValue() : null;
            NDC             = trnRec.Product_gne__r.NDC_Number_gne__c;
            Prod_Nm         = trnRec.Product_gne__r.Name;
            HCP_Id          = trnRec.Account_gne__c;
            MDM_Id          = trnRec.Account_gne__r.MDMID_gne__c;
            HCP_Fst_Nm      = trnRec.Account_gne__r.FirstName;
            HCP_Mid_Init    = trnRec.Account_gne__r.Middle_vod__c;
            HCP_Lst_Nm      = trnRec.Account_gne__r.LastName;
            HCP_Add_Id      = trnRec.Address_ID_gne__c;
            HCP_Add_Ln_1    = trnRec.Address_Line_1_gne__c;
            HCP_Add_Ln_2    = trnRec.Address_Line_2_gne__c;
            HCP_City        = trnRec.City_gne__c;
            HCP_State       = trnRec.State_gne__c;
            HCP_Zip         = trnRec.Zip_gne__c;
            HCP_Zip_E       = trnRec.Address_ID_gne__r.Zip_4_vod__c;
            HCP_Phn         = trnRec.Address_ID_gne__r.Phone_vod__c;
            HCP_Fax         = trnRec.Address_ID_gne__r.Fax_vod__c;
            HCP_eMail       = trnRec.Address_ID_gne__r.Email_gne__c;
            SLN             = trnRec.Address_ID_gne__r.License_vod__c;
            Prof_Des        = trnRec.Address_ID_gne__r.Designation_gne__c;
            HCP_Bdtd        = String.isNotBlank(trnRec.BDTD_gne__c) ? trnRec.BDTD_gne__c : trnRec.Address_ID_gne__r.PFG_BDTD_gne__c;
            Sig_Cap_Dt      = GNE_SFA2_PFG_REST_Utils.formatDate(trnRec.Request_Signature_Date_gne__c, 'MM/dd/yyyy');
            Sig_Cap_Tm      = GNE_SFA2_PFG_REST_Utils.formatDateTime(trnRec.Request_Signature_Date_gne__c, 'HH:mm:ss');
            Sig             = trnRec.Request_Signature_gne__c;
            // If CS Last Name is not set, get first and last name from lookup 
            Rep_Fst_Nm		= String.isNotBlank(trnRec.CS_Last_Name_gne__c) ? trnRec.CS_First_Name_gne__c : trnRec.From_User_gne__r.FirstName;
            Rep_Lst_Nm		= String.isNotBlank(trnRec.CS_Last_Name_gne__c) ? trnRec.CS_Last_Name_gne__c : trnRec.From_User_gne__r.LastName; 
            HCP_Spec		= trnRec.HCP_Specialty_gne__c;
            if (GNE_SFA2_PFG_Util.getUser(trnRec.From_User_gne__c) != null) {
                Rep_Unix_ID     = GNE_SFA2_PFG_Util.getUser(trnRec.From_User_gne__c).External_Id_gne__c;
            }
        }
    }
    
    @HttpPost
    global static ResultSet getOrders(String lastSyncDate, List<String> trxIds) {
        ResultSet result = null;
    	GNE_SFA2_PFG_REST_DTP_Orders service = new GNE_SFA2_PFG_REST_DTP_Orders();
    	if(trxIds!=null && !trxIds.isEmpty()) {
    		result = (ResultSet)service.prepareOutputObjects(trxIds, new ResultSet());
    	} else {
    		result = (ResultSet)service.prepareOutputObjects(lastSyncDate, new ResultSet());
    	}
        return result;
    }
    
    protected override void intPrepareOutputObjects(Object inputData, GNE_SFA2_PFG_REST_Base.ResultSet a_result) {
        ResultSet result = (ResultSet)a_result;
        
        for(SFA2_PFG_Transaction_gne__c trnRec : GNE_SFA2_PFG_REST_DAO.getDtpOrders(inputData)) {
            result.records.add(new DtpOrder(trnRec));
        }
    }
}