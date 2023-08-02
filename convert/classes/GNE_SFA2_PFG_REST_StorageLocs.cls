@RestResource(urlMapping='/sfa2_stor_loc_outbound_R1/*')
global with sharing class GNE_SFA2_PFG_REST_StorageLocs extends GNE_SFA2_PFG_REST_Base{
    global class ResultSet extends GNE_SFA2_PFG_REST_Base.ResultSet{
        public List<StorageLoc> records = new List<StorageLoc>();
    }
    
    global class StorageLoc {
        public String St_loc_id;
        public String User_Id;
        public String Fst_Nm;
        public String Lst_Nm;
        public String Add_Ln_1;
        public String Add_Ln_2;
        public String City;
        public String State;
        public String Zip;
        public String Phone;
        public String Apr_Dt;
        public String Apr_By;
                
        public StorageLoc(SFA2_PFG_Storage_Location_gne__c slRec, ProcessInstance pi) {
            St_loc_id   = slRec.Name;
            User_Id     = slRec.User_gne__r.External_Id_gne__c;
            Fst_Nm      = slRec.User_gne__r.FirstName;
            Lst_Nm      = slRec.User_gne__r.LastName;
            Add_Ln_1    = slRec.Address_Line_1_gne__c;
            Add_Ln_2    = slRec.Address_Line_2_gne__c;
            City        = slRec.City_gne__c;
            State       = slRec.State_gne__c;
            Zip         = slRec.Zip_gne__c;
            Phone       = slRec.Phone_gne__c;
            
            if(pi!=null && pi.Steps!=null && !pi.Steps.isEmpty()) {
                ProcessInstanceStep pis = pi.Steps[0];
                Apr_Dt  = GNE_SFA2_PFG_REST_Utils.formatDate(pis.CreatedDate,'MM/dd/yyyy');
                Apr_By  = pis.Actor.Name;
            }
        }
    }
    
    @HttpPost
	global static ResultSet getStoreageLocs(String lastSyncDate) {
		return (ResultSet)(new GNE_SFA2_PFG_REST_StorageLocs()).prepareOutputObjects(lastSyncDate, new ResultSet());
	}
	
	protected override void intPrepareOutputObjects(DateTime lastSyncDateTime, GNE_SFA2_PFG_REST_Base.ResultSet a_result) {
		ResultSet result = (ResultSet)a_result;
		
		List<SFA2_PFG_Storage_Location_gne__c> sls = GNE_SFA2_PFG_REST_DAO.getStorageLocs(lastSyncDateTime);
        Map<Id, ProcessInstance> approvedProcesses = GNE_SFA2_PFG_Util.getApprovedProcesses((new Map<Id,SFA2_PFG_Storage_Location_gne__c>(sls)).keySet());
            
        for(SFA2_PFG_Storage_Location_gne__c slRec : sls) {
            result.records.add(new StorageLoc(slRec, approvedProcesses.get(slRec.Id)));
        }
	}
}