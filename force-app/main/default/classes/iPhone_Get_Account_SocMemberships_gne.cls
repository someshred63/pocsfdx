@RestResource(urlMapping='/iPhoneGetAccountSocMemberships/*')
global with sharing class iPhone_Get_Account_SocMemberships_gne {
	@HttpPost 
     global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, String unixId, List<String> accountIds, Boolean enhDelta, String otrVersion) {       
        return iPhone_Commons_gne.buildResponse(
                new GetAccountSocMembershipsResponseBuilder(), 
                new iPhone_Commons_gne.DefaultDeltaArgs(lastSyncDate, unixId, accountIds, enhDelta, otrVersion)           
        );        
    } 

    class GetAccountSocMembershipsResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder { 
                                                        
        protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
            return args.isEnhancedDelta() ? iPhone_DeltaDAO.getSocietyMembershipsByAccountIds(args.accountIds, args.getLastSyncDate()) : iPhone_DAO.getSocietyMembershipsByAccountIds(args.accountIds);
        }   
                            
        protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
            return new GetAccountSocMembershipRecord((SFA2_Account_Society_Membership_gne__c)sObj);                      
        }
    }
    
    public virtual class GetAccountSocMembershipRecord extends iPhone_Commons_gne.DeltaRecord {
    	public String at;	// Account_gne__c
		public String mn;	// Membership_Name_gne__c
		public String ot;	// Other_gne__c
		public Integer yr;	// Year_gne__c
		
		public GetAccountSocMembershipRecord() {}
		
        public GetAccountSocMembershipRecord(SFA2_Account_Society_Membership_gne__c sMem) {
            this.id	= sMem.Id;
            this.at	= iPhone_StringUtil.getString(sMem.Account_gne__c);
			this.mn	= iPhone_StringUtil.getString(sMem.Membership_Name_gne__c);
			this.ot	= iPhone_StringUtil.getString(sMem.Other_gne__c);
			
			try {
				this.yr	= sMem.Year_gne__c!=null ? Integer.valueOf(sMem.Year_gne__c) : null;
			} catch(Exception e) {}
        }
    }
}