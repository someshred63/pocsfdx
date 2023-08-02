@RestResource(urlMapping='/iPhoneGetAccountPrepInformation/*')
global with sharing class iPhone_Get_Account_PrepTestingInfo_gne {
	@HttpPost 
     global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, String unixId, List<String> accountIds, Boolean enhDelta, String otrVersion) {       
        return iPhone_Commons_gne.buildResponse(
                new GetAccountPrepInformationResponseBuilder(), 
                new iPhone_Commons_gne.DefaultDeltaArgs(lastSyncDate, unixId, accountIds, enhDelta, otrVersion)           
        );        
    } 

    class GetAccountPrepInformationResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder { 
                                                        
        protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
            return args.isEnhancedDelta() ? iPhone_DeltaDAO.getPrepTestingInfoByAccountIds(args.accountIds, args.getLastSyncDate()) : iPhone_DAO.getPrepTestingInfoByAccountIds(args.accountIds);
        }   
                            
        protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
            return new GetAccountPrepTestingInfoRecord((SFA2_PREP_Account_Testing_Info_gne__c)sObj);                      
        }
    }
    
    public virtual class GetAccountPrepTestingInfoRecord extends iPhone_Commons_gne.DeltaRecord {
    	public String at;	// Account_gne__c
		public String mtl;	// MDT_Lead_gne__c
		public String mtlt;	// MDT_Lead_Title_gne__c
		public Integer pog;	// Percent_of_Global_gne__c
		public Integer pot;	// Percent_of_TC_gne__c
		public String ra;	// Referred_Account_gne__c
		public String rnm;	// Referred_Account_gne__r.Name
		public String stg;	// Stage_Tested_gne__c
		public String tc;	// Test_Component_gne__c
		public String th;	// Test_Hierarchy_gne__c
		public String ti;	// Test_Initiator_gne__c
		public String tm;	// Test_Method_gne__c
		public String tt;	// Test_Type_gne__c
		public Integer tv;	// Testing_Volume_Month_gne__c
        
        public GetAccountPrepTestingInfoRecord() {}
        
        public GetAccountPrepTestingInfoRecord(SFA2_PREP_Account_Testing_Info_gne__c testingInfo) {
            this.id		= testingInfo.Id;
            this.at		= iPhone_StringUtil.getString(testingInfo.Account_gne__c);
			this.mtl	= iPhone_StringUtil.getString(testingInfo.MDT_Lead_gne__c);
			this.mtlt	= iPhone_StringUtil.getString(testingInfo.MDT_Lead_Title_gne__c);
			this.pog	= testingInfo.Percent_of_Global_gne__c!=null ? testingInfo.Percent_of_Global_gne__c.intValue() : null;
			this.pot	= testingInfo.Percent_of_TC_gne__c!=null ? testingInfo.Percent_of_TC_gne__c.intValue() : null;
			this.ra		= iPhone_StringUtil.getString(testingInfo.Referred_Account_gne__c);
			this.rnm	= testingInfo.Referred_Account_gne__r!=null ? iPhone_StringUtil.getString(testingInfo.Referred_Account_gne__r.Name) : null;
			this.stg	= iPhone_StringUtil.getString(testingInfo.Stage_Tested_gne__c);
			this.tc		= iPhone_StringUtil.getString(testingInfo.Test_Component_gne__c);
			this.th		= iPhone_StringUtil.getString(testingInfo.Test_Hierarchy_gne__c);
			this.ti		= iPhone_StringUtil.getString(testingInfo.Test_Initiator_gne__c);
			this.tm		= iPhone_StringUtil.getString(testingInfo.Test_Method_gne__c);
			this.tt		= iPhone_StringUtil.getString(testingInfo.Test_Type_gne__c);
			this.tv		= testingInfo.Testing_Volume_Month_gne__c!=null ? testingInfo.Testing_Volume_Month_gne__c.intValue() : null;
        }
    }
}