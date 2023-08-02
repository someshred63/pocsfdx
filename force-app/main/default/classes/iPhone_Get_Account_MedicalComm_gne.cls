/******************************************************************************************
*  @author: Sebastian Karczmarski, Roche (contractor)
*  @email: sebastian.karczmarski@contractors.roche.com   
*  Created: 2013-05-24
*  Project: OTR2
*  Description: REST Webservice, returns a list of MedicalCommunications for the specified 
*  accounts.             
*******************************************************************************************/
@RestResource(urlMapping='/iPhoneGetAccountMedicalCommunications/*')
global with sharing class iPhone_Get_Account_MedicalComm_gne {
	
	@HttpPost 
    global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, String unixId, List<String> accountIds, Boolean enhDelta, String otrVersion) {    	
    	return iPhone_Commons_gne.buildResponse(
	    		new GetAccountMedicalCommResponseBuilder(), 
	    		new iPhone_Commons_gne.DefaultDeltaArgs(lastSyncDate, unixId, accountIds, enhDelta, otrVersion)
    	);     	     	    	 
    } 
    
    class GetAccountMedicalCommResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder { 
    	
    	protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
    		return args.isEnhancedDelta() ? iPhone_DeltaDAO.getMedicalCommunicationByAccountIds(args.accountIds, args.getLastSyncDate()) : iPhone_DAO.getMedicalCommunicationByAccountIds(args.accountIds);    		  
    	} 	
    	     	 			
    	protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
    		return new GetAccountMedicalCommRecord((Medical_Communication_gne__c)sObj); 		    		
    	}      	    				
    }
    
    public virtual class GetAccountMedicalCommRecord extends iPhone_Commons_gne.DeltaRecord {
		public String aid; //(account id)
		public String pd;  //(product id)
		public String ir;  //(is referral)
		public String mdi; //(local id)
		public String fm;  //(follow-up method)
		public String ne;  //(notify for education)
		public String pt;  //(priority)
		public String mq;  //(medical question)
		public String od;  //(open date)
		public String md;  //(last modification date)
		public String cd;  //(close date)
		public String ms;  //(status)
		public String em;  //(email)
		public String ph;  //(phone)
		public String fx;  //(fax)
		public String ci;  //(created by id)
		public String cb;  //(created by name)
		public String a1;  //(address line 1)
		public String a2;  //(address line 2)
		public String ct;  //(city)
		public String st;  //(state)
		public String zp;  //(zip)
		public String z4;  //(zip 4)
		public String mo;  //(product id, molecule)
		public String ta;  //(product id, taSubTa(?))
		public String asid; //(Referral, assigned to SFDC ID)
		public String asn; //(Referral, assigned to name). Field name changed: 'as' => 'asn' ('as' is a apex keyword).
		public String rbi; //(Referral, requested by name)
		public String rc;  //(Referral, requested completion date, tracking date)	
		public String lp;  // Language_of_Preference_can_gne__c
		public String cid;  //(Referral, requested call)
		public String raid;  //(Referral Assigment)
		public String ranm;  //(Referral Assigment Name)
		public String urv; //Unsolicited_Request_Verified_gne__c
		public String cm; //Comments_Referral_gne__c
						
		public GetAccountMedicalCommRecord() {		
		}
		
		public GetAccountMedicalCommRecord(Medical_Communication_gne__c medicalComm) {		
			this.id  = medicalComm.Id; 																						
			this.aid = iPhone_StringUtil.getString(medicalComm.Account_gne__c);				
			this.pd  = iPhone_StringUtil.getString(medicalComm.Product_gne__c); 			
			this.mdi = iPhone_StringUtil.getString(medicalComm.iPhone_Request_Id_gne__c);	
			this.fm  = iPhone_StringUtil.getString(medicalComm.Follow_up_Method_gne__c); 	
			this.ne  = iPhone_StringUtil.getString(medicalComm.Notify_for_Education_gne__c);
			this.pt  = iPhone_StringUtil.getString(medicalComm.Priority_gne__c); 			
			this.mq  = iPhone_StringUtil.getString(medicalComm.Medical_Question_gne__c); 	
			this.od  = iPhone_StringUtil.getString(medicalComm.Open_Date_gne__c); 		
			this.md  = iPhone_StringUtil.getString(medicalComm.LastModifiedDate); 		
			this.cd  = iPhone_StringUtil.getString(medicalComm.Closed_Date_gne__c); 	
			this.em  = iPhone_StringUtil.getString(medicalComm.Email_gne__c); 				
			this.ph  = iPhone_StringUtil.getString(medicalComm.Phone_gne__c); 				
			this.fx  = iPhone_StringUtil.getString(medicalComm.Fax_gne__c); 				
			this.ci  = iPhone_StringUtil.getString(medicalComm.CreatedBy.Id);				
			this.cb  = iPhone_StringUtil.getString(medicalComm.CreatedBy.Name); 			
			this.a1  = iPhone_StringUtil.getString(medicalComm.Address_Line_1_gne__c); 		
			this.a2  = iPhone_StringUtil.getString(medicalComm.Address_Line_2_gne__c); 		
			this.ct  = iPhone_StringUtil.getString(medicalComm.City_gne__c); 				
			this.st  = iPhone_StringUtil.getString(medicalComm.State_gne__c); 				
			this.zp  = iPhone_StringUtil.getString(medicalComm.Zip_gne__c); 				
			this.z4  = iPhone_StringUtil.getString(medicalComm.Zip_4_gne__c); 				
			this.mo  = iPhone_StringUtil.getString(medicalComm.Molecule_gne__c); 			
			this.ta  = String.isNotBlank(medicalComm.TA_gne__c) ? medicalComm.TA_gne__c : iPhone_StringUtil.getString(medicalComm.TA_SubTA_gne__c); 
			this.lp  = iPhone_StringUtil.getString(medicalComm.Language_of_Preference_can_gne__c);
			this.urv  = iPhone_StringUtil.getString(medicalComm.Unsolicited_Request_Verified_gne__c);
			if(medicalComm.Referral_Assignment_gne__c != null) {
				this.ir  = 'true';
				this.asid = iPhone_StringUtil.getString(medicalComm.Referral_Assignment_gne__r.Assigned_To_gne__c);
				this.asn = iPhone_StringUtil.getString(medicalComm.Referral_Assignment_gne__r.Assigned_To_gne__r.Name);
				this.rbi = iPhone_StringUtil.getString(medicalComm.Requested_By_gne__c); 
				this.rc  = iPhone_StringUtil.getStringDate(medicalComm.Requested_Completion_Date_gne__c);
				this.cid  = iPhone_StringUtil.getString(medicalComm.Referral_Assignment_gne__r.Call2_vod__c);	
				this.raid  = iPhone_StringUtil.getString(medicalComm.Referral_Assignment_gne__c);
				this.ranm  = iPhone_StringUtil.getString(medicalComm.Referral_Assignment_gne__r.Name);
				this.ms  = iPhone_StringUtil.getString(medicalComm.Status_Referral_gne__c); 
				this.cm = iPhone_StringUtil.getString(medicalComm.Comments_Referral_gne__c);
			} else {
				this.ir  = 'false';	
				this.asn = '';			
				this.rbi = ''; 			
				this.rc  = '';
				this.ms  = iPhone_StringUtil.getString(medicalComm.Status_gne__c);  		
			}																		
		}
    }
}