@RestResource(urlMapping='/iPhoneGetAccountCallThreats/*')
global with sharing class iPhone_Get_Account_CallThreats_gne {
    @HttpPost 
    global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, String unixId, List<String> accountIds, Boolean enhDelta, String otrVersion) {  	
        return iPhone_Commons_gne.buildResponse(
            new GetAccountCallCallThreatsResponseBuilder(), 
            new iPhone_Commons_gne.DefaultDeltaArgs(lastSyncDate, unixId, accountIds, enhDelta, otrVersion)    		
        );     	    	 
    }
    
    class GetAccountCallCallThreatsResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder {
        
        protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
            return args.isEnhancedDelta() ? iPhone_DeltaDAO.getCallThreatsByAccountIds(args.accountIds, args.getLastSyncDate()) : iPhone_DAO.getCallThreatsByAccountIds(args.accountIds);      
        } 	
        
        protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
            return new GetAccountCallCallThreatRecord((Call2_Threat_vod__c)sObj);
        }
    }
    
    @testVisible
    class GetAccountCallCallThreatRecord extends iPhone_Commons_gne.DeltaRecord {
        public String pd;    // Call2_Threat_vod__c.Product_vod__c
        public String bob;   // Call2_Threat_vod__c.Book_of_Business__c
        public String rp;    // Call2_Threat_vod__c.Requested_Position__c
        public String reb;   // Call2_Threat_vod__c.Rebate__c
        public String rsd;   // Call2_Threat_vod__c.Requested_Start_Date__c
        public String rlvl;  // Call2_Threat_vod__c.Risk_Level__c
        public String ia;    // Call2_Threat_vod__c.Initial_Assessment__c
        public String iid;    // Call2_Threat_vod__c.Call2_vod__c

        
        public GetAccountCallCallThreatRecord(Call2_Threat_vod__c callThreat) {
            this.id	= callThreat.Id;
            this.pd = callThreat.Product_vod__c;  
            this.bob = iPhone_StringUtil.getString(callThreat.Book_of_Business__c);  
            this.rp = iPhone_StringUtil.getString(callThreat.Requested_Position__c);  
            this.reb = iPhone_StringUtil.getString(callThreat.Rebate__c);  
            this.rsd = iPhone_StringUtil.getString(callThreat.Requested_Start_Date__c); 
            this.rlvl = iPhone_StringUtil.getString(callThreat.Risk_Level__c); 
            this.ia = iPhone_StringUtil.getString(callThreat.Initial_Assessment__c);  
            this.iid = callThreat.Call2_vod__c;
        }        
    }
}