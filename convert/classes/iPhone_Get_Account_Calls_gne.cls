/******************************************************************************************
*  @author: Sebastian Karczmarski, Roche (contractor)
*  @email: sebastian.karczmarski@contractors.roche.com   
*  Created: 2013-05-24
*  Project: OTR2
*  Description: REST Webservice, returns a list of Call2s for the specified accounts.             
*******************************************************************************************/
@RestResource(urlMapping='/iPhoneGetAccountCalls/*')
global with sharing class iPhone_Get_Account_Calls_gne {
	private static String userIdPrefix;
	
	@HttpPost 
    global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, String unixId, List<String> accountIds, Boolean enhDelta, String otrVersion) {    	
    	return iPhone_Commons_gne.buildResponse(
	    		new GetAccountCallsResponseBuilder(), 
	    		new iPhone_Commons_gne.DefaultDeltaArgs(lastSyncDate, unixId, accountIds, enhDelta, otrVersion)
    	);     	  
    } 
              
    class GetAccountCallsResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder { 
    	private Map<Id, String> userToPhoto;
    													
    	protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
    		List<Call2_vod__c> callToReturn = args.isEnhancedDelta() ? iPhone_DeltaDAO.getCallsByAccountIds(args.accountIds, args.getLastSyncDate()) : iPhone_DAO.getCallsByAccountIds(args.accountIds);
    		initializeMap(callToReturn);
    		return callToReturn;
    	}

    	private void initializeMap(List<Call2_vod__c> callList){
    		Set<Id> userIds = new Set<Id>();
    		for(Call2_vod__c sobj :callList){
    			userIds.add(sObj.OwnerId);
    			userIds.add(sObj.CreatedById);
    		}
    		userToPhoto = new Map<Id, String>();
    		for(User u :[SELECT Id, SmallPhotoUrl FROM User WHERE Id IN :userIds]){
    			userToPhoto.put(u.Id, u.SmallPhotoUrl);
    		}
    	}
    	     	 			
    	protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
    		return new GetAccountCallsRecord((Call2_vod__c)sObj, userToPhoto);    		    		
    	}        	    	
    }  
     
    class GetAccountCallsRecord extends iPhone_Commons_gne.DeltaRecord {	
		public String na;	// Call2_vod__c.Name
		public String ad;	// Call2_vod__c.Address_vod__c
		public String cd;	// Call2_vod__c.Call_Datetime_vod__c
		public String st;	// Call2_vod__c.interaction_status_gne__c
		public String me;	// Call2_vod__c.Meal_Expense_gne__c
		public String ma;	// Call2_vod__c.Meal_Amount_gne__c
		public String pa;	// Call2_vod__c.Planned_Attendees_gne__c
		public String aa;	// Call2_vod__c.Actual_Attendees_gne__c
		public String cb;	// Call2_vod__c.CreatedBy.Name
		public String ci;	// Call2_vod__c.CreatedById
		public String aid;	// Call2_vod__c.Account_vod__c
		public String mdi;	// Call2_vod__c.iphone_request_id_gne__c
		public String md;	// Call2_vod__c.lastmodifieddate
		public String ai;	// Call2_vod__c.Parent_Address_vod__c
		public String cs;	// Call2_vod__c.customers_gne__c
		public String ty;	// Call2_vod__c.interaction_type_gne__c
		public String sa;	// Call2_vod__c.Is_Sampled_Call_vod__c
		public String sd;	// Call2_vod__c.Signature_Date_vod__c
		public String rsd;	// Call2_vod__c.Request_Signature_Date_gne__c
		public String ln;	// Call2_vod__c.License_vod__c
		public String sp;	// Call2_vod__c.Speaker_program_gne__c
		public String im;	// Call2_vod__c.Interaction_method_gne__c
		public String ta;	// Call2_vod__c.Topics_Addressed_gne__c
		public String an;	// Call2_vod__c.Other_Details_Topics_Addressed_gne__c
		public String re;	// Call2_vod__c.Resolution_gne__c
		public String rt;	// Call2_vod__c.FRM_Response_Time_gne__c
		public String ra;	// Call2_vod__c.Reactive__c
		public String ml;	// Call2_vod__c.interaction_location_gne__c
		public String mp;	// Call2_vod__c.Primary_Interaction_Reason_gne__c
		public String mc;	// Call2_vod__c.City_gne__c
		public String mm;	// Call2_vod__c.Group_Meeting_Topic_gne__c
		public String mv;	// Call2_vod__c.Visit_Reason_gne__c
		public String ms;	// Call2_vod__c.State_gne__c
		public String no;	// Call2_vod__c.Notes_can_gne__c
		public String ap;	// Call2_vod__c.Account_Plan_vod__c
		public String av;	// Call2_vod__c.Attempted_Visit_HCP_UnwillingToMeet_gne__c
		public String mn;	// Call2_vod__c.Medical_Support_Notes_gne__c
		public String moo;	// Call2_vod__c.HCP_Account_Meal_Opt_Out_gne__c
		public String foi;	// Call2_vod__c.HCP_Follow_Up_Opt_In_gne__c
		public String ur;   // Call2_vod__c.Unsolicited_Request_gne__c
		public String rid;  // Call2_vod__c.Referral_Assignment_gne__r.Medical_Request_gne__c
		public String raid; // Call2_vod__c.Referral_Assignment_gne__c
		public String sc;	// Call2_vod__c.Sales_Collateral_gne__c
		public String pem;  // Call2_vod__c.Patient_Education_Materials_gne__c
		public String ps;   // Call2_vod__c.Protection_Strategy_gne__c
		public String rct;	// Call2_vod__c.RecordType.DeveloperName
		public String bdd;  // Call2_vod__c.PFG_BDTD_gne__c
		public String vrc;  // Call2_vod__c.Visit_Reason_RCanada_MSL_gne__c or Call2_vod__c.Visit_Reason_Canada_SAM_gne__c
		public String ilen;	// Call2_vod__c.Interaction_Length_gne__c
		public String clb;	// Call2_vod__c.Collaboration_gne__c
		public Integer oac;	// Call2_vod__c.Other_Attendees_Count_gne__c
		public String prepst; // Call2_vod__c.PREP_Status_gne__c
		public String fuw; // Call2_vod__c.PREP_Follow_Up_With_gne__c
		public String spkw; // Call2_vod__c.PREP_Speak_With_gne__c
		public String abt; // Call2_vod__c.PREP_About_gne__c
		public String odr; // Call2_vod__c.PREP_Other_gne__c
		public List<String> mbos; // Call2_vod__c.Call_PREP_MBOs_gne__r
		public String isr; // Call2_vod__c.Is_Referral_gne__c
		public String ors; // Call2_vod__c.Other_Referral_Source_gne__c
		public String rrb; // Call2_vod__c.Referral_Requested_By_gne__c
		public String rrd; // Call2_vod__c.Referral_Requested_Date_gne__c
		public String rs; // Call2_vod__c.Referral_Source_gne__c
		public String tnm; // Call2_vod__c.Territory_vod__c
		public String tid; // Call2_vod__c.Territory_Id_gne__c
		public String mbac; // Call2_vod__c.MBaC_gne__c
		public String mbic; // Call2_vod__c.MBiC_gne__c
		public String mboc; // Call2_vod__c.MBoC_gne__c
		public String vr; // Call2_vod__c.Visit_Reason_Description_gne__c
		public String hcpsp; // Call2_vod__c.HCP_Specialty_gne__c
		public String ispc; // Call2_vod__c.Pre_Call_Plan_gne__c
        public Decimal latitude; // Call2_vod__c.Geolocation_gne__Latitude__s;
		public Decimal longitude; //Call2_vod__c.Geolocation_gne__Longitude__s;
		public String gcw; //Call2_vod__c.Group_Call_with_gne__c
		public String bio; //Call2_vod__c.Biosimilars_gne__c
		public Integer nas; // Call2_vod__c.No_InService_Attendees__c
		public String ownerExternalId; //Call2_vod__c.Owner_External_Id_frm_gne__c
		public String ownerPhoto; // Owner SmallPhotoUrl
		public String dc; //Date_Completed_gne__c
		public String upr; //Call2_vod__c.user_business_role_gne__c,
        public String cbup; // Call2_vod__c.createdby_Profile_gne__c
        public String gr; //Call2_vod__c.Group_RAMA_gne__c
        public String aea; //Call2_vod__c.Access_Echo_Alignment_RAMA_gne__c
        public String obj; //Call2_vod__c.Objectives_RAMA_gne__c
        public String kms; //Call2_vod__c.Key_Messages_RAMA_gne__c
        public String otc; //Call2_vod__c.Outcomes_RAMA_gne__c
        public String nst; //Call2_vod__c.Next_Steps_RAMA_gne__c
        public String maacc;//Call2_vod__c.M_A_Account__c
        public String prob;//Call2_vod__c.Probability__c
        public Boolean initByAcc;//Call2_vod__c.Initiated_by_Account__c
		public String ides;//Call2_vod__c.Interaction_Description_gne__c
		public String ins;//Call2_vod__c.Insight_gne__c
		public String nint;//Call2_vod__c.Next_Interaction_Objective_gne__c
		
		public GetAccountCallsRecord(Call2_vod__c call){
			this(call, null);
		}
         
        public GetAccountCallsRecord(Call2_vod__c call, Map<Id, String> userToPhoto) {
            Boolean ownerIsUser = isUserId(call.OwnerId);
        	id	= call.Id;
        	na	= call.Name; 
			ad	= getAddressAsString(call);
			cd	= iPhone_StringUtil.getString(call.Call_Datetime_vod__c);
			st	= iPhone_StringUtil.getString(call.Interaction_Status_gne__c);
			me	= iPhone_StringUtil.getString(call.Meal_Expense_gne__c);
			ma	= iPhone_StringUtil.getString(call.Meal_Amount_gne__c);
			pa	= iPhone_StringUtil.getString(call.Planned_Attendees_gne__c);
			aa	= iPhone_StringUtil.getString(call.Actual_Attendees_gne__c);
			cb	= ownerIsUser ? call.Owner.Name : call.CreatedBy.Name;
			ci	= ownerIsUser ? call.OwnerId : call.CreatedById;
			ownerExternalId = call.Owner_External_Id_frm_gne__c;
			if(userToPhoto != null){
				ownerPhoto = ownerIsUser ? userToPhoto.get(call.OwnerId) : userToPhoto.get(call.CreatedById);
			}
			aid	= call.Account_vod__c;
			mdi	= iPhone_StringUtil.getString(call.iphone_request_id_gne__c);
			md	= iPhone_StringUtil.getString(call.LastModifiedDate);
			ai	= iPhone_StringUtil.getString(call.Parent_Address_vod__c);
			cs	= iPhone_StringUtil.getString(call.Customers_gne__c);
			ty	= iPhone_StringUtil.getString(call.Interaction_Type_gne__c);
			sa	= iPhone_StringUtil.getString(call.Is_Sampled_Call_vod__c);
			sd	= iPhone_StringUtil.getStringDate(call.Signature_Date_vod__c);
			rsd	= iPhone_StringUtil.getStringDate(call.Request_Signature_Date_gne__c);
			ln	= iPhone_StringUtil.getString(call.License_vod__c);
			sp	= iPhone_StringUtil.getString(call.Speaker_Program_gne__c);
			im	= iPhone_StringUtil.getString(call.Interaction_Method_gne__c);
			ta	= iPhone_StringUtil.getString(call.Topics_Addressed_gne__c);
			an	= iPhone_StringUtil.getString(call.Other_Details_Topics_Addressed_gne__c);
			re	= iPhone_StringUtil.getString(call.Resolution_gne__c);
			rt	= iPhone_StringUtil.getString(call.FRM_Response_Time_gne__c);
			ra	= iPhone_StringUtil.getString(call.Reactive__c);
			ml	= iPhone_StringUtil.getString(call.Interaction_Location_gne__c);
			mp	= iPhone_StringUtil.getString(call.Primary_Interaction_Reason_gne__c);
			mc	= iPhone_StringUtil.getString(call.City_gne__c);
			mm	= iPhone_StringUtil.getString(call.Group_Meeting_Topic_gne__c);
			mv	= iPhone_StringUtil.getString(call.Visit_Reason_gne__c);
			ms	= iPhone_StringUtil.getString(call.State_gne__c);
			no	= iPhone_StringUtil.getString(call.Notes_can_gne__c);
			ap	= iPhone_StringUtil.getString(call.Account_Plan_vod__c);
			av	= iPhone_StringUtil.getString(call.Attempted_Visit_HCP_UnwillingToMeet_gne__c);
			mn	= iPhone_StringUtil.getString(call.Medical_Support_Notes_gne__c);
			moo	= iPhone_StringUtil.getString(call.HCP_Account_Meal_Opt_Out_gne__c);
			foi = iPhone_StringUtil.getString(call.HCP_Follow_Up_Opt_In_gne__c);
			ur  = iPhone_StringUtil.getString(call.Unsolicited_Request_gne__c);
			rid = 	iPhone_StringUtil.getString(call.Referral_Assignment_gne__r.Medical_Request_gne__c);	
			raid = 	iPhone_StringUtil.getString(call.Referral_Assignment_gne__c);
			sc	= iPhone_StringUtil.getString(call.Sales_Collateral_gne__c);			
			pem	= iPhone_StringUtil.getString(call.Patient_Education_Materials_gne__c);
			ps	= iPhone_StringUtil.getString(call.Protection_Strategy_gne__c);
			rct = iPhone_StringUtil.getString(call.RecordType.DeveloperName);
			bdd = iPhone_StringUtil.getString(call.PFG_BDTD_gne__c);
			if (String.isNotBlank(call.Visit_Reason_Canada_SAM_gne__c)) {
				vrc = iPhone_StringUtil.getString(call.Visit_Reason_Canada_SAM_gne__c);
			} else {				
				vrc = iPhone_StringUtil.getString(call.Visit_Reason_RCanada_MSL_gne__c);
			}			
			ilen = iPhone_StringUtil.getString(call.Interaction_Length_gne__c);
			clb = iPhone_StringUtil.getString(call.Collaboration_gne__c);
			oac = call.Other_Attendees_Count_gne__c!=null ? call.Other_Attendees_Count_gne__c.intValue() : null;
			prepst = iPhone_StringUtil.getString(call.PREP_Status_gne__c);
			fuw = iPhone_StringUtil.getString(call.PREP_Follow_Up_With_gne__c);
			spkw = iPhone_StringUtil.getString(call.PREP_Speak_With_gne__c);
			abt = iPhone_StringUtil.getString(call.PREP_About_gne__c);
			odr = iPhone_StringUtil.getString(call.PREP_Other_gne__c);
			mbos = new List<Id>(GNE_SFA2_PREP_Util.getCallMbos(call.Call_PREP_MBOs_gne__r).keySet());
			isr = iPhone_StringUtil.getString(call.Is_Referral_gne__c);
			ors = iPhone_StringUtil.getString(call.Other_Referral_Source_gne__c);
			rrb = iPhone_StringUtil.getString(call.Referral_Requested_By_gne__c);
			rrd = iPhone_StringUtil.getString(call.Referral_Requested_Date_gne__c);
			rs = iPhone_StringUtil.getString(call.Referral_Source_gne__c);
			tnm = iPhone_StringUtil.getString(call.Territory_vod__c);
			tid = iPhone_StringUtil.getString(call.Territory_Id_gne__c);
			mbac = iPhone_StringUtil.getString( call.MBaC_gne__c );
			mbic = iPhone_StringUtil.getString( call.MBiC_gne__c );
			mboc = iPhone_StringUtil.getString( call.MBoC_gne__c );
			vr = iPhone_StringUtil.getString(call.Visit_Reason_Description_gne__c);
			hcpsp = iPhone_StringUtil.getString(call.HCP_Specialty_gne__c);
			ispc = iPhone_StringUtil.getString(call.Pre_Call_Plan_gne__c);
            latitude = call.Geolocation_gne__Latitude__s;
			longitude = call.Geolocation_gne__Longitude__s;
			gcw = iPhone_StringUtil.getString(call.Group_Call_with_gne__c);
			bio = iPhone_StringUtil.getString(call.Biosimilars_gne__c);
			nas = Integer.valueOf(call.No_InService_Attendees__c);
			dc	= iPhone_StringUtil.getStringDate(call.Date_Completed_gne__c);
            upr = iPhone_StringUtil.getString(call.user_business_role_gne__c);
            cbup = iPhone_StringUtil.getString(call.createdby_Profile_gne__c);
            gr = iPhone_StringUtil.getString(call.Group_RAMA_gne__c);
            aea = iPhone_StringUtil.getString(call.Access_Echo_Alignment_RAMA_gne__c);
            obj = iPhone_StringUtil.getString(call.Objectives_RAMA_gne__c);
            kms = iPhone_StringUtil.getString(call.Key_Messages_RAMA_gne__c);
        	otc = iPhone_StringUtil.getString(call.Outcomes_RAMA_gne__c);
        	nst = iPhone_StringUtil.getString(call.Next_Steps_RAMA_gne__c);
            maacc = iPhone_StringUtil.getString(call.M_A_Account__c);
        	prob = iPhone_StringUtil.getString(call.Probability__c);
        	initByAcc = call.Initiated_by_Account__c;
			ides = iPhone_StringUtil.getString(call.Interaction_Description_gne__c);
			ins = iPhone_StringUtil.getString(call.Insight_gne__c);
			nint = iPhone_StringUtil.getString(call.Next_Interaction_Objective_gne__c);
        }
        
        private String getAddressAsString(Call2_vod__c call) {
        	String addressText = iPhone_StringUtil.getString(call.Address_vod__c);
        	String addressTextFromParent = call.Parent_Address_vod__r!=null ? GNE_SFA2_Util.getAddressAsString(call.Parent_Address_vod__r) : null;
        	addressText = String.isNotBlank(addressTextFromParent) && addressTextFromParent!=addressText ? addressTextFromParent : addressText;
        	return addressText;
        }
	}
	
	private static String getUserIdPrefix() {
	    if(userIdPrefix==null) {
	        userIdPrefix = User.sObjectType.getDescribe().getKeyPrefix();
	    }
	    
	    return userIdPrefix;
	}
	
	private static Boolean isUserId(Id idValue) {
	    return idValue!=null && String.valueOf(idValue).startsWith(getUserIdPrefix());
	}
}