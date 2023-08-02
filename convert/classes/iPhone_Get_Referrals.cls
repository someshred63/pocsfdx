@RestResource(urlMapping='/iPhoneGetReferrals/*')
global with sharing class iPhone_Get_Referrals {

    @HttpPost 
    global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, String unixId, Boolean enhDelta, String otrVersion) {
        return iPhone_Commons_gne.buildResponse(
                new iPhoneGetReferrals(), 
                new iPhone_Commons_gne.DefaultDeltaArgs(lastSyncDate, unixId, null, enhDelta, otrVersion)
        );
    }
    
    class iPhoneGetReferrals extends iPhone_Commons_gne.DeltaRecordsResponseBuilder { 
    	
    	protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
    		return args.isEnhancedDelta() ? iPhone_DeltaDAO.getMedicalCommunicationReferralsByUnixId(args.unixId, args.getLastSyncDate()) : iPhone_DAO.getMedicalCommunicationReferralsByUnixId(args.unixId);    		  
    	} 	
    	     	 			
    	protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
    		ReferralWrapper ref = new ReferralWrapper((Referral_Assignment_gne__c)sObj);
    		iPhone_Commons_gne.DeltaRecord result = ref;
    		result.id = ref.medComId;
    		return result;
    		//return new ReferralWrapper((Referral_Assignment_gne__c)sObj); 
    	} 
    }    
    
    private class ReferralWrapper extends iPhone_Commons_gne.DeltaRecord { 
		private String aid; //(account id)
		private String pd;  //(product id)
		private String ir;  //(is referral)
		private String mdi; //(local id)
		private String fm;  //(follow-up method)
		private String ne;  //(notify for education)
		private String pt;  //(priority)
		private String mq;  //(medical question)
		private String od;  //(open date)
		private String md;  //(last modification date)
		private String cd;  //(close date)
		private String ms;  //(status)
		private String em;  //(email)
		private String ph;  //(phone)
		private String fx;  //(fax)
		private String ci;  //(created by id)
		private String cb;  //(created by name)
		private String a1;  //(address line 1)
		private String a2;  //(address line 2)
		private String ct;  //(city)
		private String st;  //(state)
		private String zp;  //(zip)
		private String z4;  //(zip 4)
		private String mo;  //(product id, molecule)
		private String ta;  //(product id, taSubTa(?))
		private String asid; //(Referral, assigned to SFDC ID)
		private String asn; //(Referral, assigned to name). Field name changed: 'as' => 'asn' ('as' is a apex keyword).
		private String rbi; //(Referral, requested by id)
		private String rbn; //(Referral, requested by name)
		private String rc;  //(Referral, requested completion date, tracking date)	
		private String lp;  // Language_of_Preference_can_gne__c
		private String cid;  //(Referral, requested call)
		private String raid;  //(Referral Assigment)
		private String ranm;  //(Referral Assigment Name)
		private String urv; //Unsolicited_Request_Verified_gne__c
		private String cm; //Comments_Referral_gne__c
		private String accountName; 
        private String accountMobilePhone;
        private String createdDate;
        private String medName;
        private String productName;
        private String revCompletionDate;
        private String referralTitle;
        private String referralHistory;
        private String medComId;
        private String srd; //Status_Referral_Date_gne__c

    	private ReferralWrapper(Referral_Assignment_gne__c ref) {	 
			this.id  = ref.Id;
			this.medComId  = ref.Medical_Request_gne__r.Id;
			this.aid = iPhone_StringUtil.getString(ref.Medical_Request_gne__r.Account_gne__c);				
			this.pd  = iPhone_StringUtil.getString(ref.Medical_Request_gne__r.Product_gne__c); 			
			this.mdi = iPhone_StringUtil.getString(ref.Medical_Request_gne__r.iPhone_Request_Id_gne__c);	
			this.fm  = iPhone_StringUtil.getString(ref.Medical_Request_gne__r.Follow_up_Method_gne__c); 	
			this.ne  = iPhone_StringUtil.getString(ref.Medical_Request_gne__r.Notify_for_Education_gne__c);
			this.pt  = iPhone_StringUtil.getString(ref.Medical_Request_gne__r.Priority_gne__c); 			
			this.mq  = iPhone_StringUtil.getString(ref.Medical_Request_gne__r.Medical_Question_gne__c); 	
			this.od  = iPhone_StringUtil.getString(ref.Medical_Request_gne__r.Open_Date_gne__c); 		
			this.md  = iPhone_StringUtil.getString(ref.LastModifiedDate); 		
			this.cd  = iPhone_StringUtil.getString(ref.Medical_Request_gne__r.Closed_Date_gne__c); 	
			this.em  = iPhone_StringUtil.getString(ref.Medical_Request_gne__r.Email_gne__c); 				
			this.ph  = iPhone_StringUtil.getString(ref.Medical_Request_gne__r.Phone_gne__c); 				
			this.fx  = iPhone_StringUtil.getString(ref.Medical_Request_gne__r.Fax_gne__c); 				
			this.ci  = iPhone_StringUtil.getString(ref.CreatedBy.Id);				
			this.cb  = iPhone_StringUtil.getString(ref.CreatedBy.Name); 			
			this.a1  = iPhone_StringUtil.getString(ref.Medical_Request_gne__r.Address_Line_1_gne__c); 		
			this.a2  = iPhone_StringUtil.getString(ref.Medical_Request_gne__r.Address_Line_2_gne__c); 		
			this.ct  = iPhone_StringUtil.getString(ref.Medical_Request_gne__r.City_gne__c); 				
			this.st  = iPhone_StringUtil.getString(ref.Medical_Request_gne__r.State_gne__c); 				
			this.zp  = iPhone_StringUtil.getString(ref.Medical_Request_gne__r.Zip_gne__c); 				
			this.z4  = iPhone_StringUtil.getString(ref.Medical_Request_gne__r.Zip_4_gne__c); 				
			this.mo  = iPhone_StringUtil.getString(ref.Medical_Request_gne__r.Molecule_gne__c); 			
			this.ta  = String.isNotBlank(ref.Medical_Request_gne__r.TA_gne__c) ? ref.Medical_Request_gne__r.TA_gne__c : iPhone_StringUtil.getString(ref.Medical_Request_gne__r.TA_SubTA_gne__c); 
			this.lp  = iPhone_StringUtil.getString(ref.Medical_Request_gne__r.Language_of_Preference_can_gne__c);
			this.urv  = iPhone_StringUtil.getString(ref.Medical_Request_gne__r.Unsolicited_Request_Verified_gne__c);
			this.ir  = 'true';
			this.asid = iPhone_StringUtil.getString(ref.Assigned_To_gne__c);
			this.asn = iPhone_StringUtil.getString(ref.Assigned_To_gne__r.Name);
			this.rbi = iPhone_StringUtil.getString(ref.Medical_Request_gne__r.Requested_By_gne__c); 
			this.rbn = iPhone_StringUtil.getString(ref.Medical_Request_gne__r.Requested_By_gne__r.Name);
			this.rc  = iPhone_StringUtil.getStringDate(ref.Medical_Request_gne__r.Requested_Completion_Date_gne__c);
			this.cid  = iPhone_StringUtil.getString(ref.Call2_vod__c);	
			this.raid  = iPhone_StringUtil.getString(ref.Id);
			this.ranm  = iPhone_StringUtil.getString(ref.Name);
			this.ms  = iPhone_StringUtil.getString(ref.Medical_Request_gne__r.Status_Referral_gne__c); 
			this.cm = iPhone_StringUtil.getString(ref.Medical_Request_gne__r.Comments_Referral_gne__c);
        	this.accountName = ref.Medical_Request_gne__r.Account_gne__r.Name;
        	this.accountMobilePhone = ref.Medical_Request_gne__r.Phone_1_gne__c;
        	this.createdDate = String.valueOf(ref.CreatedDate);
        	this.medName = ref.Name;
        	this.productName = ref.Medical_Request_gne__r.Product_Name_gne__c;
        	this.referralTitle = ref.Medical_Request_gne__r.Referral_Source_gne__c;
        	this.referralHistory = ref.Medical_Request_gne__r.Referral_History_gne__c;
        	this.revCompletionDate = String.valueOf(ref.Revised_Requested_Completion_Date_gne__c);
        	this.srd = iPhone_StringUtil.getStringDate(ref.Status_Referral_Date_gne__c);
    	}
    }
        
    private class Response extends iPhone_Commons_gne.RestResponse {
        private List<ReferralWrapper> referrals;
        
        private Response(List<ReferralWrapper> referrals) {
            this.referrals = referrals;
        }
    }
}