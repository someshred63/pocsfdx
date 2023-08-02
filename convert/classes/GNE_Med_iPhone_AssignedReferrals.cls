global without sharing class  GNE_Med_iPhone_AssignedReferrals{
	
	/*
	This is a webservice in SFDC that gets the list of Referrals assigned to a MedAffair User.
	This service is caled by OTR to display assigned Referrals in the Referral Inbox in OTR for the user.
	
	Author : Sandeep Kumar
	Created : 27 Jul 2011
	Last Modified : 27 Jul 2011
	Project : gMARS Phase 2
	*/
	
	static final DateTime prevDateTime = DateTime.now().addDays(-90);
	static final List<String> referralStatus = new List<String>{'Assigned','Acknowledged'} ;
	
	global class Response {
		WebService DateTime StartTime = DateTime.now();
		WebService DateTime EndTime   = null;
		WebService String ErrorCode;
		WebService String ErrorMessage;
		WebService List<CallParentRow> CallReferralList;
	}
	
	global class CallReferralRows{
		WebService List<CallRefAdded> added;
		WebService List<CallRefUpdated> updated;
		WebService String allIds;   
	}
	
	global class CallParentRow{
		WebService List<CallReferralRows> rows;
	}
	
	global class CallRefAdded{
		webservice List<RefDetail> row;
	}
	
	global class CallRefUpdated{
		webservice List<RefDetail> row;
	}

	global class CallReferrals{
		WebService DateTime CallDateTime;
		WebService String UserId;
		WebService List<Id> ReferralAssigmentIds;
	}
	
	
	global class RefDetail {
		WebService String Id;
		WebService String Account;
		WebService String MedicalQuestion;          //from Med Comm
		WebService String Product;                  
		WebService String TASubTA;
		WebService String Molecule;
		WebService String Status;
		WebService DateTime StatusDate;
		WebService String Priority;                 //from Med Comm
		WebService String FollowUpMethod;           //from Med Comm
		WebService Date   RequestedCompletionDate;  //from Med Comm
		WebService Date   RevisedCompletionDate;
		WebService String StreetAddress;            //from Med Comm
		WebService String Suite;                    //from Med Comm
		WebService String DepartmentName;           //from Med Comm
		WebService String AttnCareOf;               //from Med Comm
		WebService String City;                     //from Med Comm
		WebService String State;                    //from Med Comm
		WebService String Zip;                      //from Med Comm
		WebService String ZipPlus4;                 //from Med Comm
		WebService String Country;                  //from Med Comm
		WebService String Email;                    //from Account
		WebService String Phone;                    //from Med Comm
		WebService String MobilePhone;              //from Med Comm
		WebService String Fax;                      //from Med Comm
		WebService String RequestedById;
		WebService String RequestedByName;
		WebService Boolean isMedcomm;				//from Med Comm
		WebService String MedcommId;				//from Med Comm
		WebService String Ownerid;
		
		WebService String Call;				//Call_2_vod__c
		
		public RefDetail(Referral_Assignment_gne__c ra){
			this.Id = ra.Id;
			this.Account = ra.Medical_Request_gne__r.Account_gne__c;
			this.MedicalQuestion = ra.Medical_Request_gne__r.medical_question_gne__c;
			this.Priority = ra.Medical_Request_gne__r.priority_gne__c;
			this.FollowUpMethod = ra.Medical_Request_gne__r.Follow_up_method_gne__c;
			this.Status = ra.Status_Referral_gne__c;
			this.StatusDate = ra.Status_Referral_Date_gne__c;
			this.RequestedCompletionDate = ra.Medical_Request_gne__r.Requested_Completion_Date_gne__c;
			this.RevisedCompletionDate = ra.Revised_Requested_Completion_Date_gne__c;                    
			this.Product = ra.Medical_Request_gne__r.Product_gne__c;
			this.TASubTA = ra.Medical_Request_gne__r.TA_SubTA_gne__c;
			this.Molecule = ra.Medical_Request_gne__r.Molecule_gne__c;
			this.StreetAddress = ra.Medical_Request_gne__r.address_line_1_gne__c;
			this.Suite = ra.Medical_Request_gne__r.address_line_2_gne__c;
			this.DepartmentName = ra.Medical_Request_gne__r.address_line_3_gne__c;
			this.AttnCareOf = ra.Medical_Request_gne__r.address_line_4_gne__c;
			this.City = ra.Medical_Request_gne__r.city_gne__c;
			this.State = ra.Medical_Request_gne__r.state_gne__c;
			this.Zip = ra.Medical_Request_gne__r.zip_gne__c;
			this.zipPlus4 = ra.Medical_Request_gne__r.zip_4_gne__c;
			this.Email = ra.Medical_Request_gne__r.email_gne__c;
			this.Phone = ra.Medical_Request_gne__r.phone_gne__c;
			this.Fax = ra.Medical_Request_gne__r.fax_gne__c;
			this.RequestedById = ra.Medical_Request_gne__r.Requested_By_gne__c;
			this.RequestedByName = ra.Medical_Request_gne__r.Requested_By_Name_gne__c;
			this.isMedcomm = ra.Medical_Request_gne__r.Is_MedComm_gne__c;
			this.MedcommId = ra.Medical_Request_gne__c;
			this.Call = ra.Call2_vod__c;
			this.Ownerid = ra.OwnerId;
		}
	}
	
	Webservice static Response getReferralInbox(CallReferrals callReferrals){
		Response callResponse = new Response(); 
		List<RefDetail> toAdd = new List<RefDetail>();
		List<RefDetail> toUpdate = new List<RefDetail>();
		List<String> allUserReferrals = new List<String>();
		if(callReferrals.referralAssigmentIds == null){
			callReferrals.referralAssigmentIds = new List<String>();
		}
		
		try{
			if(callReferrals.UserId==null){
				callResponse.EndTime = DateTime.now();
				callResponse.ErrorMessage = 'Invalid User';
				callResponse.CallReferralList = new List<CallParentRow>();
				return callResponse;
			}
			
			DateTime last_synch_date = callReferrals.CallDateTime;
			
			//get innitial load : get all Referrals assigned between now and last 3 months 
			if(last_synch_date == null){
				List<Referral_Assignment_gne__c> refAss = [SELECT Id, Medical_Request_gne__c, Status_Referral_gne__c, Status_Referral_Date_gne__c, Revised_Requested_Completion_Date_gne__c, 
						Medical_Request_gne__r.Id, Medical_Request_gne__r.Medical_Question_gne__c, Medical_Request_gne__r.Account_gne__c, Medical_Request_gne__r.Address_Name_gne__c, Medical_Request_gne__r.Requested_Completion_Date_gne__c, 
						Medical_Request_gne__r.Address_Line_1_gne__c, Medical_Request_gne__r.Address_Line_2_gne__c, Medical_Request_gne__r.Address_Line_3_gne__c, Medical_Request_gne__r.Address_Line_4_gne__c, 
						Medical_Request_gne__r.City_gne__c, Medical_Request_gne__r.State_gne__c, Medical_Request_gne__r.Country_gne__c, 
						Medical_Request_gne__r.Email_gne__c, Medical_Request_gne__r.Phone_gne__c, Medical_Request_gne__r.Fax_gne__c, Medical_Request_gne__r.Zip_4_gne__c, Medical_Request_gne__r.Zip_gne__c,
						Medical_Request_gne__r.Priority_gne__c, Medical_Request_gne__r.Follow_up_Method_gne__c,  
						Medical_Request_gne__r.Product_gne__c, Medical_Request_gne__r.TA_SubTA_gne__c, Medical_Request_gne__r.Molecule_gne__c, Medical_Request_gne__r.Is_MedComm_gne__c,
						Medical_Request_gne__r.Requested_By_gne__c, Medical_Request_gne__r.Requested_By_Name_gne__c, Call2_vod__c, OwnerId
					FROM Referral_Assignment_gne__c 
					WHERE (ownerId = :callReferrals.UserId  AND Status_Referral_gne__c IN :referralStatus) OR (ownerId = :callReferrals.UserId AND CreatedDate >= :prevDateTime) OR (id IN :callReferrals.referralAssigmentIds)]; 
				
				for(Referral_Assignment_gne__c ra : refAss){
					toAdd.add(new RefDetail(ra));
				}
			}else{
				//get delta load : get all Referrals assigned between now and last 3 months (only referrals that are created or updated since last last_synch_date)
				toAdd=getReferralsAdded(callReferrals.UserId, last_synch_date, callReferrals.referralAssigmentIds);
				toUpdate=getReferralsUpdated(callReferrals.UserId, last_synch_date, callReferrals.referralAssigmentIds);
				//get list of all assignments assigned to the user
				List<Referral_Assignment_gne__c> refAll = [SELECT Id, OwnerId, Status_Referral_gne__c, Assigned_To_gne__c FROM Referral_Assignment_gne__c 
														   WHERE (ownerId = :callReferrals.UserId  AND Status_Referral_gne__c IN :referralStatus) OR (ownerId = :callReferrals.UserId AND CreatedDate >= :prevDateTime) ]; 
				for(Referral_Assignment_gne__c allr : refAll){
					allUserReferrals.add(allr.Id);
				}
			}
			
			CallReferralRows CallReferralRows = new CallReferralRows();
			CallReferralRows.added = new List<CallRefAdded>();
			CallRefAdded CallRefAdded = new CallRefAdded();
			CallRefAdded.row = toAdd;
			CallReferralRows.added.add(CallRefAdded);
			
			CallReferralRows.updated = new List<CallRefUpdated>();
			CallRefUpdated CallRefUpdated = new CallRefUpdated();
			CallRefUpdated.row = toUpdate;
			CallReferralRows.updated.add(CallRefUpdated);
			
			String joinAllIds = '';
			if(allUserReferrals!=null && allUserReferrals.size()>0){
				for(String str : allUserReferrals){
					joinAllIds = joinAllIds + str + ',';
				}
				
				Integer lastIndex = joinAllIds.lastIndexOf(',');
				if(lastIndex!=null && lastIndex!=-1){
					joinAllIds = joinAllIds.substring(0, lastIndex);
				}
			}
			CallReferralRows.allIds = joinAllIds;
			callResponse.CallReferralList = new List<CallParentRow>();
			
			CallParentRow cpr = new CallParentRow();
			cpr.rows = new List<CallReferralRows>();
			cpr.rows.add(CallReferralRows);
			callResponse.CallReferralList.add(cpr);
			callResponse.EndTime = DateTime.now();
			return callResponse;
		}
		catch(Exception ex){
			callResponse.EndTime = DateTime.now();
			callResponse.ErrorMessage = ex.getMessage();
			callResponse.CallReferralList = new List<CallParentRow>();
			return callResponse;
		}
	}
	
	private static List<RefDetail> getReferralsAdded(String UserId , DateTime last_synch_date, List<String> referralAssigmentIds){
		List<RefDetail> toAdd = new List<RefDetail>();
		//get records created after the last sync
		List<Referral_Assignment_gne__c> refAssAdded = [SELECT Id, Medical_Request_gne__c, Status_Referral_gne__c, Status_Referral_Date_gne__c, Revised_Requested_Completion_Date_gne__c, 
						Medical_Request_gne__r.Id, Medical_Request_gne__r.Medical_Question_gne__c, Medical_Request_gne__r.Account_gne__c, Medical_Request_gne__r.Address_Name_gne__c, Medical_Request_gne__r.Requested_Completion_Date_gne__c, 
						Medical_Request_gne__r.Address_Line_1_gne__c, Medical_Request_gne__r.Address_Line_2_gne__c, Medical_Request_gne__r.Address_Line_3_gne__c, Medical_Request_gne__r.Address_Line_4_gne__c, 
						Medical_Request_gne__r.City_gne__c, Medical_Request_gne__r.State_gne__c, Medical_Request_gne__r.Country_gne__c, 
						Medical_Request_gne__r.Email_gne__c, Medical_Request_gne__r.Phone_gne__c, Medical_Request_gne__r.Fax_gne__c, Medical_Request_gne__r.Zip_4_gne__c, Medical_Request_gne__r.Zip_gne__c,
						Medical_Request_gne__r.Priority_gne__c, Medical_Request_gne__r.Follow_up_Method_gne__c,  
						Medical_Request_gne__r.Product_gne__c, Medical_Request_gne__r.TA_SubTA_gne__c, Medical_Request_gne__r.Molecule_gne__c, Medical_Request_gne__r.Is_MedComm_gne__c,
						Medical_Request_gne__r.Requested_By_gne__c, Medical_Request_gne__r.Requested_By_Name_gne__c, Call2_vod__c, OwnerId
		FROM Referral_Assignment_gne__c 
		WHERE (( (ownerId = :UserId  AND Status_Referral_gne__c IN :referralStatus) OR (ownerId = :UserId AND CreatedDate >= :prevDateTime) ) AND (CreatedDate >= :last_synch_date )) OR (id IN :referralAssigmentIds) ];
		
		for(Referral_Assignment_gne__c ra : refAssAdded){
			toAdd.add(new RefDetail(ra));
		}
		return toAdd;
	}
	
	private static List<RefDetail> getReferralsUpdated(String UserId , DateTime last_synch_date, List<String> referralAssigmentIds){
		List<RefDetail> toUpdate = new List<RefDetail>();
		//get records updated siince the last synch date                                    
		List<Referral_Assignment_gne__c> refAssUpdated = [SELECT Id, Medical_Request_gne__c, Status_Referral_gne__c, Status_Referral_Date_gne__c, Revised_Requested_Completion_Date_gne__c, 
						Medical_Request_gne__r.Id, Medical_Request_gne__r.Medical_Question_gne__c, Medical_Request_gne__r.Account_gne__c, Medical_Request_gne__r.Address_Name_gne__c, Medical_Request_gne__r.Requested_Completion_Date_gne__c, 
						Medical_Request_gne__r.Address_Line_1_gne__c, Medical_Request_gne__r.Address_Line_2_gne__c, Medical_Request_gne__r.Address_Line_3_gne__c, Medical_Request_gne__r.Address_Line_4_gne__c, 
						Medical_Request_gne__r.City_gne__c, Medical_Request_gne__r.State_gne__c, Medical_Request_gne__r.Country_gne__c, 
						Medical_Request_gne__r.Email_gne__c, Medical_Request_gne__r.Phone_gne__c, Medical_Request_gne__r.Fax_gne__c, Medical_Request_gne__r.Zip_4_gne__c, Medical_Request_gne__r.Zip_gne__c,
						Medical_Request_gne__r.Priority_gne__c, Medical_Request_gne__r.Follow_up_Method_gne__c,  
						Medical_Request_gne__r.Product_gne__c, Medical_Request_gne__r.TA_SubTA_gne__c, Medical_Request_gne__r.Molecule_gne__c, Medical_Request_gne__r.Is_MedComm_gne__c,
						Medical_Request_gne__r.Requested_By_gne__c, Medical_Request_gne__r.Requested_By_Name_gne__c, Call2_vod__c, OwnerId
		FROM Referral_Assignment_gne__c 
		WHERE (((ownerId = :UserId  AND Status_Referral_gne__c IN :referralStatus) OR (ownerId = :UserId AND CreatedDate >= :prevDateTime) ) AND (CreatedDate < :last_synch_date AND LastModifiedDate >= :last_synch_date ))  OR (id IN :referralAssigmentIds)];

		for(Referral_Assignment_gne__c ra : refAssUpdated){
			toUpdate.add(new RefDetail(ra));
		}
		return toUpdate;    
	}
}