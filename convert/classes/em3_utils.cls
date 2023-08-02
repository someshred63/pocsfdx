public class em3_utils {
	
	//CONTRACT CREATION METHODS
	public static Boolean party_check(New_Speaker_Contract_WS.New_Contract nc){
		List<Account> party  = new List<Account>();
		if(nc.Contracted_Party_ID == null || nc.Contracted_Party_ID.length() == 0){
			return false;
		}else {
			nc.Contracted_Party_id = nc.Contracted_Party_id.substring(0,15);
			party = [SELECT ID FROM Account WHERE ID = :nc.Contracted_Party_ID];
		}
		return party.size() > 0 ;
	}
	
	public static Boolean required_fields_check(New_Speaker_Contract_WS.New_Contract nc){
		if(String.isEmpty(nc.vendor_agreement_id) || String.isEmpty(nc.agreement_Party_type_code) || String.isEmpty(nc.contracted_party_id) || 
			String.isEmpty(nc.speaker_classification) || String.isEmpty(nc.created_by) || String.isEmpty(nc.Bureau_ID) || nc.Created_Date == null){
			return false;
		}
		return true;
	}
	
	public static Speaker_Contract_gne__c ins_upd_contract(New_Speaker_Contract_WS.New_Contract nc){
		Speaker_Contract_gne__c contract;
		List<Speaker_Contract_gne__c> contract_list = [SELECT Vendor_Code_gne__c, Contract_Works_Template_ID_gne__c, Contract_Works_Template_Desc_gne__c, Vendor_Agreement_ID_gne__c, Parent_Agreement_ID__c,
															Begin_Date_gne__c, End_Date_gne__c, Sign_Date_gne__c, Agreement_Party_Type_Code_gne__c, Agreement_Type_Code_gne__c, amendment_type_code_gne__c,
															Contracted_Party_Name_gne__c, Contracted_Party_ID__c, Speaker_Classification_gne__c, Status_Code_gne__c, Street_Address_gne__c,
															City_gne__c, State_gne__c, ZIP_Code_gne__c, Country_gne__c, Business_Unit_gne__c, Brands_gne__c, Created_By_gne__c, Created_Date_gne__c,
															CreatedDate, Speaker_Bureau_ID_gne__c, Id
														FROM
															Speaker_Contract_gne__c
														WHERE Vendor_Agreement_ID_gne__c = :nc.vendor_agreement_ID];
		
		//might want to check if there is more than 1 and if so return an error becuase there should ONLY be 1 result returned
		if(contract_list.size() > 0){
			contract = contract_list[0];
			contract.Contract_Works_Template_ID_gne__c = nc.Contract_Works_Template_ID;
			contract.Contract_Works_Template_Desc_gne__c = nc.Contract_Works_Template_Desc;
			contract.Vendor_Agreement_ID_gne__c = nc.Vendor_Agreement_ID;
			contract.Speaker_Bureau_ID_gne__c = nc.Bureau_ID;
			if(String.isNotBlank(nc.Parent_Agreement_ID)){
				List<Speaker_Contract_gne__c> parent_contract = [SELECT id FROM Speaker_Contract_gne__c WHERE Vendor_Agreement_ID_gne__c = :nc.Parent_Agreement_ID];
				//should only return 1 result
				if(parent_contract.size() > 0){
					contract.Parent_Agreement_ID_ref__c = parent_contract[0].id;
				}
			}
			contract.Begin_Date_gne__c = nc.Begin_Date;
			contract.End_Date_gne__c = nc.End_Date;
			contract.Sign_Date_gne__c = nc.Sign_Date;
			contract.Agreement_Party_Type_Code_gne__c = nc.Agreement_Party_Type_Code;
			contract.Agreement_Type_Code_gne__c = nc.Agreement_Type_Code;
			contract.amendment_type_code_gne__c = nc.Amendment_Type_Code;
			contract.Contracted_Party_Name_gne__c = nc.Contracted_Party_Name;
			contract.Contracted_Party_ID__c = nc.Contracted_Party_ID;
			contract.Speaker_Classification_gne__c = nc.Speaker_Classification;
			contract.Status_Code_gne__c = nc.Status_Code;
			contract.Street_Address_gne__c = nc.Street_Address;
			contract.City_gne__c = nc.City;
			contract.State_gne__c = nc.State;
			contract.ZIP_Code_gne__c = nc.ZIP_Code;
			contract.Country_gne__c = nc.Country;
			contract.Business_Unit_gne__c = nc.Business_Unit;
			contract.Brands_gne__c = nc.brands;
			contract.Created_By_gne__c = nc.Created_By;
			contract.Created_Date_gne__c = nc.Created_Date;
			contract.Vendor_Code_gne__c = nc.Vendor_Name;
		}else{
			String parent_id;
			if(String.isNotBlank(nc.Parent_Agreement_ID)){
				List<Speaker_Contract_gne__c> parent_contract = [SELECT id FROM Speaker_Contract_gne__c WHERE Vendor_Agreement_ID_gne__c = :nc.Parent_Agreement_ID];
				
				//should only return 1 result
				if(parent_contract.size() > 0){
					parent_id = parent_contract[0].id;
				}
			}
			contract = new Speaker_Contract_gne__c(
								Contract_Works_Template_ID_gne__c = nc.Contract_Works_Template_ID,
								Contract_Works_Template_Desc_gne__c = nc.Contract_Works_Template_Desc,
								Vendor_Agreement_ID_gne__c = nc.Vendor_Agreement_ID,
								Parent_Agreement_ID_ref__c = parent_id,
								Begin_Date_gne__c = nc.Begin_Date,
								End_Date_gne__c = nc.End_Date,
								Sign_Date_gne__c = nc.Sign_Date,
								Agreement_Party_Type_Code_gne__c = nc.Agreement_Party_Type_Code,
								Agreement_Type_Code_gne__c = nc.Agreement_Type_Code,
								amendment_type_code_gne__c = nc.Amendment_Type_Code,
								Contracted_Party_Name_gne__c = nc.Contracted_Party_Name,
								Contracted_Party_ID__c = nc.Contracted_Party_ID,
								Speaker_Classification_gne__c = nc.Speaker_Classification,
								Status_Code_gne__c = nc.Status_Code,
								Street_Address_gne__c = nc.Street_Address,
								City_gne__c = nc.City,
								State_gne__c = nc.State,
								ZIP_Code_gne__c = nc.ZIP_Code,
								Country_gne__c = nc.Country,
								Business_Unit_gne__c = nc.Business_Unit,
								Brands_gne__c = nc.brands,
								Created_By_gne__c = nc.Created_By,
								Speaker_Bureau_ID_gne__c= nc.Bureau_ID,
								Created_Date_gne__c = nc.Created_Date,
								Vendor_Code_gne__c = nc.Vendor_Name
			);
		}
		system.debug('Sud contract: ' + contract);
		return contract;
	}
	
	public static List<Speaker_Contract_Line_Item_gne__c> ins_line_items(List<New_Speaker_Contract_WS.New_Contract_line_item> line_items, Speaker_Contract_gne__c contract){
		List<Speaker_Contract_Line_Item_gne__c> line_items_list = new List<Speaker_Contract_Line_Item_gne__c>();
		for(New_Speaker_Contract_WS.New_Contract_line_item li : line_items){
			line_items_list.add(new Speaker_Contract_Line_Item_gne__c(Speaker_Contract_gne__c = contract.id, activity_pricing_term_amount_gne__c = li.activity_pricing_term_amount, service_fee_category_code_gne__c = li.service_fee_category_code));
		}
		return line_items_list;
	}
	
	public static String tie_contracts_to_memberships(Speaker_Contract_gne__c contract, String bureauID, String acc_id){
		//create List of bureaus
		List<String> bureaus = bureauID.split(',');
		
		//Retrieve the Associated Account
		Account acc  = [SELECT Id FROM Account WHERE Id = :contract.Contracted_Party_ID__c];
		List<Speaker_Bureau_Membership_gne__c> membership = [SELECT Id, Bureau_Member_gne__c, Speaker_Bureau_ID_gne__r.Aprimo_Bureau_ID_gne__c FROM
															Speaker_Bureau_Membership_gne__c 
															WHERE Bureau_Member_gne__c = :acc.id 
																AND Speaker_Bureau_ID_gne__r.Aprimo_Bureau_ID_gne__c IN :bureaus];

		if(membership.isEmpty()){
			return 'FAILURE,NO CORRESPONDING BUREAU MEMBERSHIP FOR ACCOUNT: '+acc.id+' IN ONE OF THE FOLLOWING BUREAUS: '+bureaus;
		}
		
		//ADDED 9/22/09 - Checks to see which Bureau's were not found to be associated to the specified Account ID and returns an error
		String missingBureaus = '';
		for(String bureau : bureaus){
			Boolean found = false;
			for(Speaker_Bureau_Membership_gne__c sbm : membership){
				if(sbm.Speaker_Bureau_ID_gne__r.Aprimo_Bureau_ID_gne__c == bureau){
					found = true;
					break;
				}
			}
			if(!found){
				if(missingBureaus == ''){
					missingBureaus += bureau;
				}else{
					missingBureaus += ','+bureau;
				}
			}
		}
		system.debug(LoggingLevel.INFO, 'missingBureaus: ' + missingBureaus);
		if(missingBureaus != ''){
			return 'FAILURE, ONE OF THE BUREAUS WAS NOT FOUND IN SFDC';
		}
		//SFA-778
		Map<Id, Membership_Contracts_gne__c>sbMembershipToMembership = new Map<Id, Membership_Contracts_gne__c>();
		for(Membership_Contracts_gne__c sbm: [SELECT Id, Active_gne__c, Speaker_Bureau_Membership_gne__c FROM Membership_Contracts_gne__c WHERE Speaker_Contract_gne__c=:contract.id]){
			sbMembershipToMembership.put(sbm.Speaker_Bureau_Membership_gne__c, sbm);
		}
		
		//List of Membership Contracts to insert
		List<Membership_Contracts_gne__c> to_insert = new List<Membership_Contracts_gne__c>();
		for(Speaker_Bureau_Membership_gne__c bm : membership){
			if(!sbMembershipToMembership.containsKey(bm.id)){
				to_insert.add(new Membership_Contracts_gne__c(Speaker_Bureau_Membership_gne__c = bm.id, Speaker_Contract_gne__c = contract.id));
			}
		}

		List<Membership_Contracts_gne__c> to_delete = [SELECT Id FROM Membership_Contracts_gne__c 
														WHERE Speaker_Contract_gne__c = :contract.id
															AND Speaker_Bureau_Membership_gne__r.Speaker_Bureau_ID_gne__r.Aprimo_Bureau_ID_gne__c NOT IN :bureaus];

		try{
			insert(to_insert);
			delete(to_delete);
		}catch(DmlException e){
			return 'FAILURE,FAILURE INSERTING MEMBERSHIP CONTRACT: '+e.getMessage();
		}
		return 'SUCCESS';
	}
	
	/**
	*  CURRICULUM CREATION METHODS
	*/

	public static New_Event_Curriculum_WS.Messages setCurriculumToDeletedStatus(New_Event_Curriculum_WS.New_Curriculum nc, New_Event_Curriculum_WS.Messages msg){
		List<Event_Curriculum_gne__c> curriculumToDelete = [SELECT Id, EDM_Is_Deleted_gne__c, Replacing_Curr_gne__c, Replaced_By_Curr_gne__c FROM Event_Curriculum_gne__c 
															WHERE Aprimo_ID_gne__c = :nc.PRC_Code AND EDM_Is_Deleted_gne__c = false LIMIT 1];
		if(curriculumToDelete.size() == 0 ){
			msg.Status = 'SUCCESS';
			msg.Message = '';
			return msg;
		} 
		try{
			//set curriculum status to deleted
			curriculumToDelete[0].EDM_Is_Deleted_gne__c = true;
			Set<Id> curriculasToAdjust = new Set<Id>();
			if(curriculumToDelete[0].Replaced_By_Curr_gne__c != null){
				curriculasToAdjust.add(curriculumToDelete[0].Replaced_By_Curr_gne__c);
				curriculumToDelete[0].Replaced_By_Curr_gne__c = null;
			}
			if(curriculumToDelete[0].Replacing_Curr_gne__c != null){
				curriculasToAdjust.add(curriculumToDelete[0].Replacing_Curr_gne__c);
				curriculumToDelete[0].Replacing_Curr_gne__c = null;
			}
			for(Event_Curriculum_gne__c c :[SELECT Id, Replacing_Curr_gne__c, Replaced_By_Curr_gne__c FROM Event_Curriculum_gne__c WHERE Aprimo_ID_gne__c IN :curriculasToAdjust]){
				if(c.Replacing_Curr_gne__c == curriculumToDelete[0].Id){
					c.Replacing_Curr_gne__c = null;
				}
				if(c.Replaced_By_Curr_gne__c == curriculumToDelete[0].Id){
					c.Replaced_By_Curr_gne__c = null;
				}
				curriculumToDelete.add(c);
			}
			update curriculumToDelete;
			//set training records if applicable status to deleted (should be automatic based on formula)
		} catch(Exception ex){
			msg.Status = 'FAILURE';
			msg.Message = 'Delete curriculum error: '+ex.getMessage();
			return msg;
		}
		msg.Status = 'SUCCESS';
		msg.Message = '';
		return msg;
		// deleted curriculums should be hidden in UI
	}

	public static Event_Curriculum_gne__c ins_upd_Curriculum(New_Event_Curriculum_WS.New_Curriculum nc, Event_Curriculum_gne__c current_curriculum){
		Map<String, Schema.RecordTypeInfo> em3TypeMap = Event_Curriculum_gne__c.SObjectType.getDescribe().getRecordTypeInfosByName();
		ID em3TypeID = em3TypeMap.get('EM3 Event Curriculum').getRecordTypeId();
		
		if([SELECT count() FROM Event_Curriculum_gne__c WHERE aprimo_id_gne__c = :nc.PRC_Code] > 0){
			current_curriculum = [SELECT ID, Approval_Date_gne__c, Aprimo_ID_gne__c, Brands_gne__c, Description_gne__c, PRC_Number_gne__c, EDM_Is_Deleted_gne__c, Deactivation_Date_gne__c, Name,
										 Speaker_Bureau_ID_gne__c, Start_Date_gne__c, Version_Number_gne__c, Previous_Version_Regulatory_Code_gne__c, Replaced_Asset_Regulatory_Code_gne__c,
										 Existing_T2E_Regulatory_Code_gne__c, Target_Audience_gne__c, Speaker_Retraining_Required_gne__c, Disposition_gne__c ,
										 User_Defined_Predecessor_gne__c
								  FROM Event_Curriculum_gne__c 
								  WHERE aprimo_id_gne__c = :nc.PRC_Code
								 ];
			current_curriculum.Name = nc.name;
			current_curriculum.Approval_Date_gne__c = nc.Approval_date;
			current_curriculum.Aprimo_ID_gne__c = nc.PRC_Code;
			current_curriculum.Deactivation_Date_gne__c = nc.Deactivation_date;
			current_curriculum.Start_Date_gne__c = nc.start_date;
			current_curriculum.Version_Number_gne__c = nc.version_number;
			current_curriculum.PRC_Number_gne__c = nc.prc_number;
			current_curriculum.Brands_gne__c = nc.brands;
			if(current_curriculum.User_Defined_Predecessor_gne__c == false) {
				current_curriculum.Previous_Version_Regulatory_Code_gne__c = nc.Previous_Version_Regulatory_Code;
				current_curriculum.Replaced_Asset_Regulatory_Code_gne__c = nc.Replaced_Asset_Regulatory_Code;
				current_curriculum.Existing_T2E_Regulatory_Code_gne__c = nc.Existing_T2E_Regulatory_Code;
			}
			current_curriculum.Target_Audience_gne__c = nc.Target_Audience;
			current_curriculum.Speaker_Retraining_Required_gne__c = nc.Speaker_Retraining_Required;
			current_curriculum.Disposition_gne__c = nc.Disposition;
			current_curriculum.EDM_Is_Deleted_gne__c = false;
			if(String.isBlank(current_curriculum.Description_gne__c)){
				current_curriculum.Description_gne__c = '<Title Needed>';
			}
		}else{
			current_curriculum.RecordTypeID = em3TypeID; 
			current_curriculum.Name = nc.name.left(80);
			current_curriculum.Approval_Date_gne__c = nc.Approval_date;
			current_curriculum.Aprimo_ID_gne__c = nc.PRC_Code; 
			current_curriculum.Deactivation_Date_gne__c = nc.Deactivation_date;
			current_curriculum.Start_Date_gne__c = nc.start_date; 
			current_curriculum.Version_Number_gne__c = nc.version_number;
			current_curriculum.PRC_Number_gne__c = nc.prc_number; 
			current_curriculum.Brands_gne__c = nc.brands; 
			current_curriculum.Previous_Version_Regulatory_Code_gne__c = nc.Previous_Version_Regulatory_Code;
			current_curriculum.Replaced_Asset_Regulatory_Code_gne__c = nc.Replaced_Asset_Regulatory_Code; 
			current_curriculum.Existing_T2E_Regulatory_Code_gne__c = nc.Existing_T2E_Regulatory_Code; 
			current_curriculum.Target_Audience_gne__c = nc.Target_Audience;
			current_curriculum.Speaker_Retraining_Required_gne__c = nc.Speaker_Retraining_Required;
			current_curriculum.Disposition_gne__c = nc.Disposition;
			current_curriculum.EDM_Is_Deleted_gne__c = false;
			current_curriculum.Description_gne__c = '<Title Needed>';
			current_curriculum.Curriculum_External_Id_gne__c = nc.PRC_Code;
		}
		return current_curriculum;
	}

	public static String getPreviousPRCCode(New_Event_Curriculum_WS.New_Curriculum nc){
		String previousCode = '';
		if(String.isNotBlank(nc.Previous_Version_Regulatory_Code)){
			previousCode = nc.Previous_Version_Regulatory_Code;
		} else if (String.isNotBlank(nc.Replaced_Asset_Regulatory_Code)){
			previousCode = nc.Replaced_Asset_Regulatory_Code;
		} else if (String.isNotBlank(nc.Existing_T2E_Regulatory_Code)){
			previousCode = nc.Existing_T2E_Regulatory_Code;
		}
		return previousCode;
	}

	public static Boolean checkIfPreviousPRCExists(String prcCode){
		return [SELECT COUNT() FROM Event_Curriculum_gne__c WHERE aprimo_id_gne__c = :prcCode] > 0;
	}

	public static void sendCurriculumCreateEmail(String curr, String speakerBureauId){
		Id template = [select id,Name from EmailTemplate where developername = 'EDM_Create_Curriculum_WS'].id;
		Event_Curriculum_gne__c nc = [Select Id from Event_Curriculum_gne__c where id=:curr];
				  
		List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
		List<User> emailAddress = [SELECT Id, Email, Profile_Name_gne__c FROM User WHERE Id IN( 
				SELECT Speaker_Bureau_Lead_gne__c FROM Speaker_Bureau_gne__c WHERE Aprimo_Bureau_ID_gne__c = :speakerBureauId
			)];
		
		for(User u : emailAddress){
			Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
			email.setTargetObjectId(u.Id);
			email.setWhatId(curr);
			email.setTemplateId(template);
			email.setSaveAsActivity(false);
			emails.add(email);
		}
		if(emails.size()>0){
			Messaging.sendEmail(emails);
		}
	}

	public static List<Speaker_Training_gne__c> ins_trainings(Event_Curriculum_gne__c nc, Date approvalDate, String previousCode){
		
		if (previousCode == '') {
			return new List<Speaker_Training_gne__c>(); 
		}

		Map<String, Speaker_Training_gne__c> automaticTrainingsMap = getExistingAutomaticTrainingsForReceivedCurriculum(nc.Aprimo_ID_gne__c);

		Id ownerId = tryToGetESBAdminOwnerOrCurrentUser();

		for (Speaker_Training_gne__c st : getSortedTrainingsForPreviousCurriculum(previousCode)) {
			if (!automaticTrainingsMap.keySet().contains(nc.Id + ' ' + st.Speaker_gne__c)){
				Speaker_Training_gne__c newTraining = createNewAutomaticTrainingFromOldTraining(nc, st, ownerId, approvalDate);
				automaticTrainingsMap.put(nc.Id + ' ' + st.Speaker_gne__c, newTraining);
			} 
			else {
				Speaker_Training_gne__c trainingToUpdate = automaticTrainingsMap.get(nc.Id + ' ' + st.Speaker_gne__c);
				if (trainingToUpdate != null) {
					updateExistingAutomaticTrainingsToNewCurriculumValues(nc, trainingToUpdate, st, ownerId, approvalDate);
					automaticTrainingsMap.put(nc.Id + ' ' + st.Speaker_gne__c, trainingToUpdate);
				}
			}
		}
		return automaticTrainingsMap.values();
	}

	private static Map<String, Speaker_Training_gne__c> getExistingAutomaticTrainingsForReceivedCurriculum(String apprimoId) {
		Map<String, Speaker_Training_gne__c> automaticTrainingsMap = new Map<String, Speaker_Training_gne__c>();

		for(Speaker_Training_gne__c existingST : [SELECT Id, Call_Discussion_ID_gne__c, Curriculum_Version_ID_gne__c, Delivery_Method_gne__c,
														 Event_Curriculum_gne__c, Expiration_Date_gne__c, Interaction_ID_gne__c, Location_gne__c,
														 Medical_Event_ID_gne__c, OwnerId, Speaker_gne__c, Speaker_Scope_gne__c, Status_gne__c,
														 Trained_Date_gne__c, Training_Method_gne__c, Training_Status_gne__c 
													 FROM Speaker_Training_gne__c 
													 WHERE PRC_Number_gne__c = :apprimoId 
													 AND Delivery_Method_gne__c = 'Automatic']) {
			String uniqueKey = existingST.Event_Curriculum_gne__c + ' ' + existingST.Speaker_gne__c;

			automaticTrainingsMap.put(uniqueKey, existingST);
		}

		return automaticTrainingsMap;
	}

	private static Id tryToGetESBAdminOwnerOrCurrentUser() {
		Id ownerId = UserInfo.getUserId();
		try {
			User esbAdmin = [SELECT Id FROM User WHERE Name = 'ESB Admin' AND IsActive = true LIMIT 1];
			ownerId = esbAdmin.Id;
		} catch (Exception ex) {
			system.debug('User not found');
		}
		return ownerId;
	}

	private static List<Speaker_Training_gne__c> getSortedTrainingsForPreviousCurriculum(String previousPRCCode) {
		return [SELECT Id, Call_Discussion_ID_gne__c, Curriculum_Version_ID_gne__c, Delivery_Method_gne__c,
					 Event_Curriculum_gne__c, Expiration_Date_gne__c, Interaction_ID_gne__c, Location_gne__c,
					 Medical_Event_ID_gne__c, OwnerId, Speaker_gne__c, Speaker_Scope_gne__c, Status_gne__c,
					 Trained_Date_gne__c, Training_Method_gne__c, Training_Status_gne__c
				 FROM Speaker_Training_gne__c 
				 WHERE PRC_Number_gne__c = :previousPRCCode
				 ORDER BY Trained_Date_gne__c ASC];
	}

	private static Speaker_Training_gne__c createNewAutomaticTrainingFromOldTraining(Event_Curriculum_gne__c nc, Speaker_Training_gne__c st, Id ownerId, Date approvalDate) {
		Speaker_Training_gne__c spTrain = new Speaker_Training_gne__c();
		spTrain.Call_Discussion_ID_gne__c = st.Call_Discussion_ID_gne__c;
		spTrain.Curriculum_Version_ID_gne__c = nc.Aprimo_ID_gne__c;
		spTrain.Delivery_Method_gne__c = 'Automatic';
		spTrain.Event_Curriculum_gne__c = nc.Id;
		spTrain.Expiration_Date_gne__c = st.Expiration_Date_gne__c;
		spTrain.Interaction_ID_gne__c = st.Interaction_ID_gne__c;
		spTrain.Location_gne__c = st.Location_gne__c;
		spTrain.Medical_Event_ID_gne__c = st.Medical_Event_ID_gne__c;
		spTrain.OwnerId = ownerId;
		spTrain.Speaker_gne__c = st.Speaker_gne__c;
		spTrain.Speaker_Scope_gne__c = st.Speaker_Scope_gne__c;
		spTrain.Status_gne__c = st.Status_gne__c;
		spTrain.Trained_Date_gne__c = approvalDate;
		spTrain.Training_Method_gne__c = st.Training_Method_gne__c;
		spTrain.Training_Status_gne__c = st.Training_Status_gne__c;
		return spTrain;
	}

	private static void updateExistingAutomaticTrainingsToNewCurriculumValues(Event_Curriculum_gne__c nc, Speaker_Training_gne__c newTraining, Speaker_Training_gne__c oldTraining, Id ownerId, Date approvalDate) {
		newTraining.Call_Discussion_ID_gne__c = oldTraining.Call_Discussion_ID_gne__c;
		newTraining.Curriculum_Version_ID_gne__c = nc.Aprimo_ID_gne__c;
		newTraining.Delivery_Method_gne__c = 'Automatic';
		newTraining.Expiration_Date_gne__c = oldTraining.Expiration_Date_gne__c;
		newTraining.Interaction_ID_gne__c = oldTraining.Interaction_ID_gne__c;
		newTraining.Location_gne__c = oldTraining.Location_gne__c;
		newTraining.Medical_Event_ID_gne__c = oldTraining.Medical_Event_ID_gne__c;
		newTraining.OwnerId = ownerId;
		newTraining.Speaker_Scope_gne__c = oldTraining.Speaker_Scope_gne__c;
		newTraining.Status_gne__c = oldTraining.Status_gne__c;
		newTraining.Trained_Date_gne__c = approvalDate;
		newTraining.Training_Method_gne__c = oldTraining.Training_Method_gne__c;
		newTraining.Training_Status_gne__c = oldTraining.Training_Status_gne__c;
	}

	public static void updateTrainingRecords(Event_Curriculum_gne__c nc){
		update [SELECT Id FROM Speaker_Training_gne__c WHERE PRC_Number_gne__c = :nc.Aprimo_ID_gne__c];
	}

	public static List<Member_Trainings_gne__c> ins_trainingMembers(Map<Id, Speaker_Training_gne__c> oldToNewTrainings, String sbAprimoId){
		List<String> bureaus = sbAprimoId.split(',');
		List<Member_Trainings_gne__c> toInsert = new List<Member_Trainings_gne__c>();
		for(Member_Trainings_gne__c oldMT :[SELECT Speaker_Bureau_Membership_gne__c, Speaker_Training_gne__c 
					FROM Member_Trainings_gne__c WHERE Speaker_Training_gne__c IN :oldToNewTrainings.keySet() 
					AND Speaker_Bureau_Membership_gne__r.Speaker_Bureau_ID_gne__r.Aprimo_Bureau_ID_gne__c IN :bureaus]){
			toInsert.add(new Member_Trainings_gne__c(
					Speaker_Bureau_Membership_gne__c = oldMT.Speaker_Bureau_Membership_gne__c,
					Speaker_Training_gne__c = oldToNewTrainings.get(oldMT.Speaker_Training_gne__c).Id
				));
		}
		return toInsert;
	}

	public static List<Event_Curriculum_gne__c> upd_replacing_curr(String previousCode, String currentCode){
		List<Event_Curriculum_gne__c> eCurriculums = [SELECT Id, Aprimo_ID_gne__c, Replaced_By_Curr_gne__c, Replacing_Curr_gne__c FROM Event_Curriculum_gne__c WHERE Aprimo_ID_gne__c IN (:previousCode, :currentCode)];
		Event_Curriculum_gne__c oldC;
		Event_Curriculum_gne__c newC;
		for(Event_Curriculum_gne__c ec :eCurriculums){
			if(ec.Aprimo_ID_gne__c == previousCode){
				oldC = ec;
			} else {
				newC = ec;
			}
		}
		List<Event_Curriculum_gne__c> toUpdate = new List<Event_Curriculum_gne__c>();
		oldC.Replaced_By_Curr_gne__c = newC.Id;
		newC.Replacing_Curr_gne__c = oldC.Id;
		toUpdate.add(oldC);
		toUpdate.add(newC);
		return toUpdate;
	}
	
	
	public static Boolean bureau_Check(New_Event_Curriculum_WS.New_Curriculum nc){
		List<String> spk_bur_list = new List<String>();
		if(nc.Speaker_bureau_IDs.contains(',')){
			spk_bur_list = nc.Speaker_bureau_IDs.split(',');
		}else{
			spk_bur_list.add(nc.Speaker_bureau_IDs);
		}
		
		if(spk_bur_list.size() != [SELECT count() FROM Speaker_Bureau_gne__c WHERE Aprimo_Bureau_ID_gne__c IN :spk_bur_list]){
			return false;
		}
		return true;
	}
	
	public static List<Curriculum_Speaker_Bureau_gne__c> create_bur_relationships(New_Event_Curriculum_WS.New_Curriculum nc,Event_Curriculum_gne__c ec){
		//collect Curr. Speaker bureau records
		List<Curriculum_Speaker_Bureau_gne__c> curr_join = [SELECT Id, Speaker_Bureau_gne__c FROM Curriculum_Speaker_Bureau_gne__c WHERE event_Curriculum_gne__c = :ec.id];
		
		Set<Id> existingJoinsId = new Set<Id>();
		for(Curriculum_Speaker_Bureau_gne__c oldJoin :curr_join){
			existingJoinsId.add(oldJoin.Speaker_Bureau_gne__c);
		}

		List<String> spk_bur_list = new List<String>();
		if(nc.Speaker_bureau_IDs.contains(',')){
			spk_bur_list = nc.Speaker_bureau_IDs.split(',');
		}else{
			spk_bur_list.add(nc.Speaker_bureau_IDs);
		}
		
		List<Curriculum_Speaker_Bureau_gne__c> new_joins = new List<Curriculum_Speaker_Bureau_gne__c>();
		try{
			for(Speaker_Bureau_gne__c spk_id : [SELECT ID FROM Speaker_Bureau_gne__c WHERE Aprimo_Bureau_ID_gne__c IN :spk_bur_list]){
				if(!existingJoinsId.contains(spk_id.Id)){
					new_joins.add(new Curriculum_Speaker_Bureau_gne__c(Event_Curriculum_Gne__c = ec.id, Speaker_Bureau_gne__c = spk_id.id));
				}
			}
		}catch(Exception e){
			system.debug(e.getMessage());
		}
		return new_joins;
	}

	/**
	* EVENT CREATION METHODS
	*/
	public static New_Event_Creation_WS.Events_obj ins_upd_Events(New_Event_Creation_WS.New_Event ne, New_Event_Creation_WS.Events_obj evt_obj ){
		//Retrieves the ID for the 'EM3 Medical Event' record type
		Map<String, Schema.RecordTypeInfo> em3TypeMap = Medical_Event_vod__c.SObjectType.getDescribe().getRecordTypeInfosByName();
		ID em3SpkrPrgm1stSite = em3TypeMap.get('Em3 Speaker Program 1st Site Layout').getRecordTypeId();
		ID em3SpkrPrgmAddlSite = em3TypeMap.get('EM3 Speaker Program Addl Site Layout').getRecordTypeId();
		ID em3SpkrTrng1stSite = em3TypeMap.get('Em3 Speaker Training 1st Site Layout').getRecordTypeId();
		ID em3SpkrTrngAddlSite =  em3TypeMap.get('Em3 Speaker Training Addl Site Layout').getRecordTypeId();
		
		if(String.isEmpty(ne.Curriculum_version_id) && (ne.Event_type == 'Speaker Training') && (ne.status == 'Closed' || ne.status == 'Occurred') ){
			evt_obj.msgs.Status = 'FAILURE';
			evt_obj.msgs.Message = 'Missing Curriculum on a Speaker Program or Speaker Training Event';
			return evt_obj;
		}
		ID parent_Site_type;
		ID child_Site_type;
		
		//Set Record type
		if(ne.event_type == 'Speaker Program'){
			parent_site_type = em3SpkrPrgm1stSite;
			child_site_type = em3SpkrPrgmAddlSite;
		}else if(ne.Event_type == 'Speaker Training'){
			parent_site_type = em3SpkrTrng1stSite;
			child_site_type = em3SpkrTrngAddlSite;
		}else {
			GNE_EM3_Monitoring.insertTransactionLogFailure('Wrong Event Type. The permitted types are: Speaker Program, Speaker Training', ne);
			evt_obj.msgs.Status = 'FAILURE';
			evt_obj.msgs.Message = 'Wrong Event Type. The permitted types are: Speaker Program, Speaker Training';
			return evt_obj;
		}
		
		//Set to hold all site IDs (not SFDC ID's but Source_System_ID external ID's)
		Set<String> sites = new Set<String>();
		
		//Map to hold the external Source_System_ID and it's Medical_Event record in SFDC
		Map<String, Medical_Event_vod__c> site_to_medEvent_map = new Map<String, Medical_Event_vod__c>();
		
		//a variable to hold the location event (or site)
		Medical_Event_vod__c location_event;
		
		//a variable to hold the parent event
		Medical_Event_vod__c parent_event;
		
		//Checks to see if the Source_System_ID is null and returns an error if so
		if(String.isEmpty(ne.source_system_id)){
			GNE_EM3_Monitoring.insertTransactionLogFailure('Source System ID is null', ne);
			evt_obj.msgs.Status = 'FAILURE';
			evt_obj.msgs.Message = 'SOURCE SYSTEM ID IS NULL';
			return evt_obj;
		}
		
		//Modified by Chatham Reed per Request to assign ownership to Queues
		Id owner;
		List<Group> queueList = new List<Group>([SELECT id FROM Group WHERE Type='Queue' and (Name = 'Advisory Boards Queue' or Name = 'Investigator Meetings Queue' or Name = 'Speaker Program Queue' or Name = 'Speaker Training Queue') order by Name]);
		
		if([SELECT count() FROM Medical_Event_vod__c WHERE Source_System_ID_gne__c = :ne.source_system_id AND Site_ID_gne__c = ''] == 1){
			try {
				
				//Altered 09/23/09 to remove the parent_medical_Event_gne__c check
				parent_event = [SELECT id, RecordTypeID, Start_Time_gne__c, Time_Zone_gne__c, Speaker_gne__c, Requestor_ID_gne__c, Brands_gne__c, Method_Of_Delivery_gne__c, Accountable_id_gne__c, Description_vod__c,Catered_Event_gne__c, name, Event_Planned_Date_1_gne__c,
										Event_Planned_Date_2_gne__c,Event_Planned_Date_3_gne__c, Event_Series_Name_gne__c, Event_Type_gne__c, Timing_gne__c, Event_Sub_Type_Code_gne__c, Status_gne__c, Event_Roster_gne__c, Start_Date_vod__c, End_Date_vod__c, Speaker_Bureau_ID_gne__c, Requesting_Third_Party_Org_gne__c,
										Therapeutic_Areas_gne__c, Location_gne__c, Indications_gne__c, Parent_Site_gne__c, Source_System_ID_gne__c,
										Invitations_Sent_Date_gne__c, Request_Date_gne__c, Created_By_gne__c,
										Event_Status_Date_gne__c, Event_Status_Time_gne__c, Event_Created_Date_Time_gne__c, Canceled_By_gne__c, Cancelation_Reason_gne__c, Cancelation_Explanation_gne__c
								FROM Medical_Event_vod__c
								WHERE Source_System_ID_gne__c = :ne.source_system_id AND Site_ID_gne__c = '' for update];
				
				parent_event.RecordTypeID = parent_site_type;
				//Once we have retireved the parent event the rest of the code in this code block is used to update the fields on the parent medical event
				//with what is brought into the webservice
				parent_event.Parent_Site_gne__c = true;
				//parent_event.Aprimo_Event_ID_gne__c = ne.aprimo_event_id;
				parent_event.Name = ne.Name;
				parent_event.Description_vod__c = ne.Name;  //The event's description is the same as the name of the event
				parent_event.Source_System_gne__c = ne.source_system;
				parent_event.Source_System_ID_gne__c = ne.source_system_id;
				parent_event.Event_Management_Vendors_gne__c = evt_obj.vendors;
				
				//Updates the medical event's planned dates if they are not NULL
				if(ne.event_planned_date_1 != null){
					parent_event.Event_Planned_Date_1_gne__c = date.newinstance(ne.event_planned_date_1.year(),ne.Event_planned_date_1.month(),ne.event_planned_date_1.day());
				}
				if(ne.event_planned_date_2 != null){
					parent_event.Event_Planned_Date_2_gne__c = date.newinstance(ne.event_planned_date_2.year(),ne.Event_planned_date_2.month(),ne.event_planned_date_2.day());
				}
				if(ne.event_planned_date_3 != null){
					parent_event.Event_Planned_Date_3_gne__c = date.newinstance(ne.event_planned_date_3.year(),ne.Event_planned_date_3.month(),ne.event_planned_date_3.day());
				}
				parent_event.Event_Series_Name_gne__c = ne.event_series_name;
				parent_event.Event_Type_gne__c = ne.event_type;
				parent_event.Timing_gne__c = ne.timing;
				parent_event.Event_Sub_Type_Code_gne__c = ne.event_sub_type_code;
				parent_event.Status_gne__c = ne.status;
				parent_event.Start_Date_vod__c = date.newInstance(ne.start_date.year(),ne.start_date.month(),ne.start_date.day());
				parent_event.End_Date_vod__c = date.newInstance(ne.end_date.year(),ne.end_date.month(),ne.end_date.day());
				parent_event.Speaker_Bureau_ID_gne__c = ne.speaker_bureau_id;
				parent_event.Brands_gne__c = ne.brands;
				parent_event.Indications_gne__c = ne.indications;
				parent_event.Therapeutic_Areas_gne__c = ne.therapeutic_areas;
				parent_event.Requesting_Third_Party_Org_gne__c = ne.requesting_third_party_org;
				parent_event.event_format_gne__c = ne.medium_type;
				parent_event.Method_of_Delivery_gne__c = ne.method_of_delivery;
				if(ne.Start_time!=null){
					parent_event.Start_Time_gne__c = ne.Start_time.substring(0,8);
				}
				parent_event.Time_Zone_gne__c = ne.time_zone;
				parent_event.Invitations_Sent_Date_gne__c = ne.invitations_sent_date;
				parent_event.Request_Date_gne__c = ne.request_date;
				parent_event.Created_By_gne__c = ne.event_created_by;

				if(ne.event_status_date != null){
					parent_event.Event_Status_Date_gne__c = date.newinstance(ne.event_status_date.year(),ne.event_status_date.month(),ne.event_status_date.day());
				}
				if(ne.event_status_time != null){
					parent_event.Event_Status_Time_gne__c = ne.event_status_time.substring(0,8);
				}
				if(ne.event_created_date_time != null){
					parent_event.Event_Created_Date_Time_gne__c = ne.event_created_date_time;
				}
				parent_event.Canceled_By_gne__c = ne.canceled_by;
				parent_event.Cancelation_Reason_gne__c = ne.cancelation_reason;
				parent_event.Cancelation_Explanation_gne__c = ne.cancelation_explanation;
				
				update(parent_event);
			}catch(Exception e){
				system.debug(e);
				GNE_EM3_Monitoring.insertTransactionLogFailure('Failure updating parent event', ne);
				evt_obj.msgs.Status = 'FAILURE';
				evt_obj.msgs.Message = 'FAILURE UPDATING PARENT EVENT:'+e.getMessage();
				return evt_obj;
			}
			//The else statement indicates a situation in which the parent event did not exist in SFDC and a new one is created
		}else {
			try{
				//The following statements check weather the Event Type matches one of the following event types.  If so the event is put
				//into it's respective queue for visibility purposes, otherwise it will default to have the ESB ADMIN as the owner
				if(ne.event_type == 'Advisory Board'){
					owner = queueList[0].Id;
				}else if(ne.event_type == 'Investigator Meeting'){
					owner = queueList[1].Id;
				}else if(ne.event_type == 'Speaker Program'){
					owner = queueList[2].Id;
				}else if(ne.event_type == 'Speaker Training'){
					owner = queueList[3].Id;
				}else{
					owner = userinfo.getuserid();
				}
				String trimStartTime;
				if(ne.Start_time != null){
					trimStartTime = ne.Start_time.substring(0,8);
				}
				
				//Creates a new Medical Event using the values brought into the webservice FROM aprimo
				parent_event = new Medical_Event_vod__c(
										//	Aprimo_Event_ID_gne__c = ne.aprimo_event_id,
											Name = ne.Name,
											RecordTypeID = parent_site_type,
											Description_vod__c = ne.Name,
											Event_Series_Name_gne__c = ne.event_series_name,
											Event_Type_gne__c = ne.event_type,
											Timing_gne__c = ne.timing,
											Event_Sub_Type_Code_gne__c = ne.event_sub_type_code,
											Status_gne__c = ne.status,
											Brands_gne__c = ne.brands,
											Speaker_Bureau_ID_gne__c = ne.speaker_bureau_id,
											Indications_gne__c = ne.indications,
											Therapeutic_Areas_gne__c = ne.therapeutic_areas,
											Requesting_Third_Party_Org_gne__c = ne.requesting_third_party_org,
											Event_Format_gne__c = ne.medium_type,
											Method_Of_Delivery_gne__c = ne.Method_Of_Delivery,
											Parent_Site_gne__c = true,
											Start_Time_gne__c = trimStartTime,
											Time_Zone_gne__c = ne.time_zone,
											OwnerId = owner,
											Source_System_gne__c = ne.source_system,
											Source_System_ID_gne__c = ne.source_system_id,
											Event_Management_Vendors_gne__c = evt_obj.vendors,
											Invitations_Sent_Date_gne__c = ne.invitations_sent_date,
											Request_Date_gne__c = ne.request_date,
											Created_By_gne__c = ne.event_created_by
				);
				
				//The following lines check to see if the event planned dates are null, if they are not
				//the event planned date values on the newly created medical event are populated with the
				//values brought in through the webservice
				if(ne.event_planned_date_1 != null){
					parent_event.Event_Planned_Date_1_gne__c = date.newinstance(ne.event_planned_date_1.year(),ne.Event_planned_date_1.month(),ne.event_planned_date_1.day());
				}
				if(ne.event_planned_date_2 != null){
					parent_event.Event_Planned_Date_2_gne__c = date.newinstance(ne.event_planned_date_2.year(),ne.Event_planned_date_2.month(),ne.event_planned_date_2.day());
				}
				if(ne.event_planned_date_3 != null){
					parent_event.Event_Planned_Date_3_gne__c = date.newinstance(ne.event_planned_date_3.year(),ne.Event_planned_date_3.month(),ne.event_planned_date_3.day());
				}
				
				parent_event.Start_Date_vod__c = date.newInstance(ne.start_date.year(),ne.start_date.month(),ne.start_date.day());
				parent_event.End_Date_vod__c = date.newInstance(ne.end_date.year(),ne.end_date.month(),ne.end_date.day());
				
				system.debug('Apex: insert parent_event: ' + parent_event);
				
				if(parent_event.Name != null && parent_event.Name.length() > 80){
					parent_event.Name = parent_event.Name.substring(0,80);
				}

				if(ne.event_status_date != null){
					parent_event.Event_Status_Date_gne__c = date.newinstance(ne.event_status_date.year(),ne.event_status_date.month(),ne.event_status_date.day());
				}
				if(ne.event_status_time != null){
					parent_event.Event_Status_Time_gne__c = ne.event_status_time.substring(0,8);
				}		
				if(ne.event_created_date_time != null){
					parent_event.Event_Created_Date_Time_gne__c = ne.event_created_date_time;
				}
				parent_event.Canceled_By_gne__c = ne.canceled_by;
				parent_event.Cancelation_Reason_gne__c = ne.cancelation_reason;
				parent_event.Cancelation_Explanation_gne__c = ne.cancelation_explanation;

				insert parent_event;
			}catch(Exception e){
				GNE_EM3_Monitoring.insertTransactionLogFailure('Failure creating parent event', ne);
				evt_obj.msgs.Status = 'FAILURE';
				evt_obj.msgs.Message = 'FAILURE CREATING PARENT EVENT:'+e.getMessage();
				return evt_obj;
			}
		}
		
		//ADDED 09/23/09 THE PARENT EVENT IS ALWAYS KNOWN NOW AND IT IS COMPLETELY SEPARATE FROM ANY OF THE SITES COMING IN
		evt_obj.parent_event = parent_event;
		evt_obj.event_locations.add(parent_event);
		
		//sites List begins
		//Checks to see if there are sites in the sites_list
		if(ne.sites_list != null && ne.sites_list.size() > 0){
			for(Integer i=0; i<ne.sites_list.size(); i++){
				sites.add(ne.sites_list[i].site_id);
			}
			
			//For all Medical Event locations which contain a matching Aprimo_Event_ID FROM the previusly created Set
			//put that medical Event location in the MAP with the key Set to the medical event location's APrimo_Event_ID
			for(Medical_Event_vod__c location : [SELECT id, Start_time_gne__c, Time_Zone_gne__c, RecordTypeID, Speaker_gne__c, Description_vod__c, Source_System_ID_gne__c, name, parent_medical_event_gne__c,
														Parent_Aprimo_Event_gne__c, event_medium_type_gne__c, Catered_Event_gne__c, Primary_Street_Address_gne__c, City_Name_gne__c,
														State_Province_Code_gne__c, Zip_Code_gne__c, Country_Code_gne__c, Total_Attendee_Count_gne__c,Event_Roster_gne__c, Site_ID_gne__c,
														Event_Planned_Date_1_gne__c,Event_Planned_Date_2_gne__c,Event_Planned_Date_3_gne__c,Event_Series_Name_gne__c,Event_Sub_Type_Code_gne__c,
														Status_gne__c,Brands_gne__c,Indications_gne__c,Therapeutic_Areas_gne__c,Requesting_Third_Party_Org_gne__c,Method_Of_Delivery_gne__c,
														Requesting_Company_gne__c,Accountable_id_gne__c,Location_gne__c, Invitations_Sent_Date_gne__c, Request_Date_gne__c, Created_By_gne__c
												FROM
														Medical_Event_vod__c
												WHERE
														Site_ID_gne__c IN :sites
												AND Source_System_ID_gne__c = :parent_event.Source_System_ID_gne__c for update]){
				
				site_to_medEvent_map.put(location.site_id_gne__c,location);
			}
			
			//For the List of sites brought in to the webservice first default the catered_event_flag to false
			//and then proceed to create/update the sites
			for(New_Event_Creation_WS.New_site ns: ne.sites_list){
				
				//For speaker programs and Trainings with a status of Occurred or Closed throw an error if there is no curriculum
				//attached to the event
				if(ne.Curriculum_version_id == null || ne.Curriculum_version_id == ''){
					if((ne.Event_type == 'Speaker Training' ) && (ne.status == 'Closed' || ne.status == 'Occurred') ){
						GNE_EM3_Monitoring.insertTransactionLogFailure('Missing Curriculum on a Speaker Program or Speaker Training Event', ne);
						evt_obj.msgs.Status = 'FAILURE';
						evt_obj.msgs.Message = 'Missing Curriculum on a Speaker Program or Speaker Training Event';
						return evt_obj;
					}
				}
				
				try {
					//Default the catered Event value for all sites to FALSE
					if(ns.catered_event_flag == null){
						ns.catered_event_flag = false;
					}
					
					//If the current site exists in SFDC already (checked via the previously created site_to_medEvent_map)
					//Then retrieve the site FROM the map and update the fields brought in to the webservice and
					//relate this event to the previously created parent event
					if(site_to_medEvent_map.keySet().contains(ns.site_id)){
						location_event = site_to_medEvent_map.get(ns.site_id);
						location_event.RecordTypeID = child_site_type;
						if(ne.Start_time != null){
							location_event.Start_Time_gne__c = ne.Start_time.substring(0,8);
						}
						location_event.name = ne.name;
						location_event.Event_Type_gne__c = ne.event_type;
						location_event.Description_vod__c = ne.name;
						location_event.parent_medical_event_gne__c = parent_event.id;
						//location_event.Aprimo_Event_ID_gne__c = parent_event.Aprimo_Event_ID_gne__c;
						location_event.Site_ID_gne__c = ns.site_id;
						location_event.Time_Zone_gne__c = ne.time_zone;
						location_event.event_medium_type_gne__c = ns.event_medium_type;
						location_event.Catered_Event_gne__c = ns.catered_event_flag;
						location_event.Primary_Street_Address_gne__c = ns.Street_Address;
						location_event.City_Name_gne__c = ns.City_Name;
						location_event.State_Province_Code_gne__c = ns.State_Province_Code;
						location_event.Zip_Code_gne__c = ns.zip_code;
						location_event.Country_Code_gne__c = ns.country_code;
						location_event.Total_Attendee_Count_gne__c = ns.total_attendee_count;
						location_event.Event_Roster_gne__c = ns.roster;
						location_event.location_gne__c = em3_utils_2.getLocation(ns.location);
						location_event.Start_date_vod__c = date.newInstance(ne.start_date.year(),ne.start_date.month(),ne.start_date.day());
						location_event.End_date_vod__c = date.newInstance(ne.end_date.year(),ne.end_date.month(),ne.end_date.day());
						location_event.Event_Planned_Date_1_gne__c = parent_event.Event_Planned_Date_1_gne__c;
						location_event.Event_Planned_Date_2_gne__c = parent_event.Event_planned_Date_2_gne__c;
						location_event.Event_Planned_Date_3_gne__c = parent_event.Event_Planned_Date_3_gne__c;
						location_event.Event_Series_Name_gne__c = parent_event.Event_Series_Name_gne__c;
						location_event.Event_Sub_Type_Code_gne__c = parent_event.Event_Sub_Type_Code_gne__c;
						location_event.Status_gne__c = parent_event.Status_gne__c;
						location_event.Brands_gne__c = parent_event.Brands_gne__c;
						location_event.Indications_gne__c = parent_event.Indications_gne__c;
						location_event.Therapeutic_Areas_gne__c = parent_event.Therapeutic_Areas_gne__c;
						location_event.Requesting_Third_Party_Org_gne__c = parent_event.Requesting_Third_Party_Org_gne__c;
						location_event.Method_Of_Delivery_gne__c = parent_event.Method_Of_Delivery_gne__c;
						location_event.Requesting_Company_gne__c = parent_event.Requesting_Company_gne__c;
						location_event.Accountable_id_gne__c = parent_event.Accountable_id_gne__c;
						location_event.Sign_in_sheet_date_gne__c = ns.sign_in_sheet_date;
						location_event.Sign_in_sheet_status_gne__c = ns.sign_in_sheet_status;
						location_event.Source_System_ID_gne__c = ne.source_system_id;
						location_event.Site_Total_Planned_Attendee_Count_gne__c= ns.site_total_planned_attendee_count;
						location_event.Site_Roster_Attendee_Opt_Out_Count_gne__c = ns.site_roster_attendee_opt_out_count;
						location_event.Site_Final_Planned_Opt_Out_Count_gne__c = ns.site_final_planned_attendee_opt_out_count;
						location_event.Site_Roster_Attendee_Count_gne__c= ns.site_roster_attendee_count;
						location_event.Venue_Guaranteed_Count_gne__c= ns.venue_guaranteed_count;
						location_event.Invitations_Sent_Date_gne__c = ns.invitations_sent_date;
						location_event.Request_Date_gne__c = ns.request_date;
						location_event.Created_By_gne__c = ne.event_created_by;

						location_event.Event_Status_Date_gne__c = parent_event.Event_Status_Date_gne__c;
						location_event.Event_Status_Time_gne__c = parent_event.Event_Status_Time_gne__c;
					}else{
						//The following statements check weather the Event Type matches one of the following event types.  If so the event is put
						//into it's respective queue for visibility purposes, otherwise it will default to have the ESB ADMIN as the owner
						if(ne.event_type == 'Advisory Board'){
							owner = queueList[0].Id;
						}else if(ne.event_type == 'Investigator Meeting'){
							owner = queueList[1].Id;
						}else if(ne.event_type == 'Speaker Program'){
							owner = queueList[2].Id;
						}else if(ne.event_type == 'Speaker Training'){
							owner = queueList[3].Id;
						}else{
							owner = userinfo.getuserid();
						}
						String trimStartTime;
						if(ne.Start_time != null){
							trimStartTime = ne.Start_time.substring(0,8);
						}
						location_event = new Medical_event_vod__c(
							name = ne.name,
							RecordTypeID = child_site_type,
							Event_Type_gne__c = ne.event_type,
							parent_medical_event_gne__c = parent_event.id,
							//Aprimo_Event_ID_gne__c = parent_event.Aprimo_Event_ID_gne__c,
							Site_ID_gne__c = ns.site_id,
							event_medium_type_gne__c = ns.event_medium_type,
							Catered_Event_gne__c = ns.catered_event_flag,
							Primary_Street_Address_gne__c = ns.Street_Address,
							City_Name_gne__c = ns.City_Name,
							State_Province_Code_gne__c = ns.State_Province_Code,
							Zip_Code_gne__c = ns.zip_code,
							Country_Code_gne__c = ns.country_code,
							Total_Attendee_Count_gne__c = ns.total_attendee_count,
							location_gne__c = em3_utils_2.getLocation(ns.location),
							Event_Roster_gne__c = ns.roster,
							Start_date_vod__c = date.newInstance(ne.start_date.year(),ne.start_date.month(),ne.start_date.day()),
							End_date_vod__c = date.newInstance(ne.end_date.year(),ne.end_date.month(),ne.end_date.day()),
							Event_Planned_Date_1_gne__c = parent_event.Event_Planned_Date_1_gne__c,
							Event_Planned_Date_2_gne__c = parent_event.Event_planned_Date_2_gne__c,
							Event_Planned_Date_3_gne__c = parent_event.Event_Planned_Date_3_gne__c,
							Event_Series_Name_gne__c = parent_event.Event_Series_Name_gne__c,
							Event_Sub_Type_Code_gne__c = parent_event.Event_Sub_Type_Code_gne__c,
							Status_gne__c = parent_event.Status_gne__c,
							Brands_gne__c = parent_event.Brands_gne__c,
							Indications_gne__c = parent_event.Indications_gne__c,
							Therapeutic_Areas_gne__c = parent_event.Therapeutic_Areas_gne__c,
							Requesting_Third_Party_Org_gne__c = parent_event.Requesting_Third_Party_Org_gne__c,
							Method_Of_Delivery_gne__c = parent_event.Method_Of_Delivery_gne__c,
							Requesting_Company_gne__c = parent_event.Requesting_Company_gne__c,
							Accountable_id_gne__c = parent_event.Accountable_id_gne__c,
							Start_Time_gne__c = trimStartTime,
							Time_Zone_gne__c = ne.time_zone,
							OwnerId = owner,
							Sign_in_sheet_date_gne__c = ns.sign_in_sheet_date,
							Sign_in_sheet_status_gne__c = ns.sign_in_sheet_status,
							Source_System_ID_gne__c = ne.source_system_id,
							Site_Total_Planned_Attendee_Count_gne__c= ns.site_total_planned_attendee_count,
							Site_Roster_Attendee_Opt_Out_Count_gne__c = ns.site_roster_attendee_opt_out_count,
							Site_Final_Planned_Opt_Out_Count_gne__c = ns.site_final_planned_attendee_opt_out_count,
							Site_Roster_Attendee_Count_gne__c= ns.site_roster_attendee_count,
							Venue_Guaranteed_Count_gne__c= ns.venue_guaranteed_count,
							Invitations_Sent_Date_gne__c = ns.invitations_sent_date,
							Request_Date_gne__c = ns.request_date,
							Created_By_gne__c = ne.event_created_by
						);
						location_event.Event_Status_Date_gne__c = parent_event.Event_Status_Date_gne__c;
						location_event.Event_Status_Time_gne__c = parent_event.Event_Status_Time_gne__c;
					}
					evt_obj.event_locations.add(location_event);
				}catch(Exception e){
					GNE_EM3_Monitoring.insertTransactionLogFailure('Error creating/updating sites', ne);
					evt_obj.msgs.Status = 'FAILURE';
					evt_obj.msgs.Message = 'ERROR CREATING/UPDATING SITES:'+e.getMessage();
					return evt_obj;
				}
			}
		}else{
			evt_obj.parent_event = parent_event;
		}
		return evt_obj;
	}
	
	//This function gathers up all attendees with a status of 'deleted' and gathers the associated event_attendee_vod__c records
	//into a List for deletion
	public static List<Event_Attendee_vod__c> del_attendees(List<New_Event_Creation_WS.new_site> sites_list){
		//Map to hold aprimo event ID's to there attendees SFDC ID to be deleted
		Map<String,Set<ID>> siteID_to_SFDCattendees = new Map<String,Set<ID>>();
		
		//Set to hold all unique sfdc and aprimo ids
		Set<ID> SFDC_set = new Set<ID>();
		Set<String> aprimo_set = new Set<String>();
		
		///Set to hold UNIX IDs
		Set<String> UNIX_IDs = new Set<String>();
		
		//Loop through the sites_list and gather all deleted Users and put them in the Set of unix id's to delete
		for(New_Event_Creation_WS.new_site ns : sites_list){
			if(ns.attendees_list != null){
				for(New_Event_Creation_WS.New_Attendee attendee : ns.attendees_list){
					if(String.isNotEmpty(attendee.UNIX_ID) && attendee.status == 'Deleted'){
						UNIX_IDs.add(attendee.UNIX_ID);
						//sites_list[i].attendees_list.remove(j); //depricated, users weren't deleting once put in.
					}
				}
			}
		}
		
		//If the users exist in sfdc then populate the unixID_list with there external id's
		List<User> unixID_list = [SELECT ID, external_id_gne__c FROM User WHERE external_id_gne__c IN :UNIX_IDs];
		
		//Retrieve the SFDC id's FROM the current user and add there SFDC id to the attendees List so I can easily delete them
		for(User cur_user : unixID_list){
			for(New_Event_Creation_WS.new_site ns : sites_list){
				if(ns.attendees_list != null){
					for(New_Event_Creation_WS.New_Attendee attendee : ns.attendees_list){
						if(attendee.UNIX_ID == cur_user.external_id_gne__c){
							attendee.SFDC_ID = cur_user.id;
							break;
						}
					}
				}
			}
		}
		
		//Loop through all sites and associated attendees List to find those to be deleted and populate the previously created map
		for(New_Event_Creation_WS.new_site aSite :sites_list){
			if(aSite.attendees_list != null){
				for(New_Event_Creation_WS.new_attendee anAttendee : asite.attendees_list){
					if(anAttendee.status == 'Deleted' && !(anAttendee.SFDC_ID == null)){
						if(!siteID_to_SFDCattendees.containsKey(aSite.site_id)){
							siteID_to_SFDCattendees.put(aSite.site_id,new Set<ID>());
						}
						siteID_to_SFDCattendees.get(aSite.site_id).add(anAttendee.SFDC_ID);
						sfdc_set.add(anAttendee.SFDC_ID);
						aprimo_set.add(aSite.site_id);
					}
				}
			}
		}
		
		//Loop through the sites List and remove the attendees which are going to be deleted
		for(New_Event_Creation_WS.new_site ns : sites_list){
			if(ns.attendees_list != null){
				for(Integer j=0;j<ns.attendees_list.size();j++){
					if(String.isNotEmpty(ns.attendees_list[j].SFDC_ID) && ns.attendees_list[j].status == 'Deleted'){
						ns.attendees_list.remove(j);
					}
				}
			}
		}
		
		//SELECT all event attendee records that are to be deleted
		return [SELECT User_vod__c, Medical_Event_vod__r.Site_ID_gne__c, Medical_Event_vod__c, Contact_vod__c, Account_vod__c
				FROM Event_Attendee_vod__c WHERE Medical_Event_vod__r.Site_ID_gne__c IN :Aprimo_set
				AND (User_vod__c IN :SFDC_set OR Contact_vod__c IN :SFDC_Set OR Account_vod__c IN :SFDC_set)];
	}

	//Create the relationship between the curriculum's and medical events for the junction
	public static New_Event_Creation_WS.Events_obj tie_evts_to_curr(New_Event_Creation_WS.Events_obj evt_obj, List<String> aprimo_curr_list){
		Map<String, Set<String>> currID_to_events_map = new Map<String, Set<String>>();
		
		//will hold all curriculum id's of those curriculums which already exist (checked by using the aprimo external id)
		Set<String> curr_set = new Set<String>();
		List<String> curr_list = new List<String>();
		
		//Populate the curr_set with Event_Curriculum_gne__c id's that exist in SFDC
		for(Event_Curriculum_gne__c ec : [SELECT ID, Aprimo_ID_gne__c, Deactivation_Date_gne__c FROM Event_Curriculum_gne__c WHERE Aprimo_ID_gne__c IN :aprimo_curr_list]){
			curr_set.add(ec.id);
			curr_list.add(ec.id);
			evt_obj.curr_obj.aprimoID_to_curric_map.put(ec.Aprimo_ID_gne__c, ec);
		}
		
		if(evt_obj.event_locations != null && evt_obj.event_locations.size() > 0){
			//retrieve all event_curriculum_Join_gne__c (junctions) records WHERE a records Med. Evt and Evt. Curr are within the List of event curriclums and medical events
			List<Event_Curriculum_Join_gne__c> existing_jncns = [SELECT id, Medical_Event_gne__c, Event_Curriculum_gne__c FROM Event_Curriculum_Join_gne__c WHERE Medical_Event_gne__c IN :evt_obj.event_locations AND Event_Curriculum_gne__c IN :curr_set];
			
			//Populates the currId... map to have every Event Curriculum SFDC ID mapped to a List of Medical Event
			for(Event_Curriculum_Join_gne__c jncn : existing_jncns){
				if (!currID_to_events_map.containsKey(jncn.Event_Curriculum_gne__c)){
					currID_to_events_map.put(jncn.Event_Curriculum_gne__c, new Set<String>());
				}
				currID_to_events_map.get(jncn.Event_Curriculum_gne__c).add(jncn.Medical_Event_gne__c);
			}
			
			//For each curriculum run through all events and first check if the curriculum already exists, if so check if it's related
			//medical events are equal to any of the medical events we are currently processing.  If not add the relationship between the
			//curriculum and medical event to the junction object.  Otherwise do nothing because the relationship is already established.
			//if the curriculum doesn't have any relationship between the medical event being processed then for all events create the relationship
			//between this curriculum
			system.debug('EX_JUNCTION:'+existing_jncns);
			for(Event_Curriculum_Join_gne__c jncn : existing_jncns){
				for(Integer i=0; i<curr_list.size(); i++){
					if(curr_list[i] == jncn.Event_Curriculum_gne__c){
						curr_list.remove(i);
						break;
					}
				}
				
				for(Medical_Event_vod__c evt : evt_obj.event_locations){
					if(currID_to_events_map.containsKey(jncn.Event_Curriculum_gne__c)){
						if(!currID_to_events_map.get(jncn.Event_Curriculum_gne__c).contains(evt.id)){
							evt_obj.curr_obj.evt_to_curr_jncn.add(new Event_Curriculum_Join_gne__c(Event_Curriculum_gne__c = jncn.Event_Curriculum_gne__c, Medical_Event_gne__c = evt.id));
							currID_to_events_map.get(jncn.Event_Curriculum_gne__c).add(evt.Id);
						}
					}else{
						evt_obj.curr_obj.evt_to_curr_jncn.add(new Event_Curriculum_Join_gne__c(Event_Curriculum_gne__c = jncn.Event_Curriculum_gne__c, Medical_Event_gne__c = evt.id));
					}
				}
			}
		}
		for(Integer i=0; i<curr_list.size(); i++){
			if(evt_obj.event_locations != null){
				for(Medical_Event_vod__c evt : evt_obj.event_locations){
					evt_obj.curr_obj.evt_to_curr_jncn.add(new Event_Curriculum_Join_gne__c(Event_Curriculum_gne__c = curr_list[i], Medical_Event_gne__c = evt.id));
				}
			}else{
				evt_obj.curr_obj.evt_to_curr_jncn.add(new Event_Curriculum_Join_gne__c(Event_Curriculum_gne__c = curr_list[i], Medical_Event_gne__c = evt_obj.parent_event.id));
			}
		}
		return evt_obj;
	}
	
	//public static New_Event_Creation_WS.Att_and_Spk_obj create_attendees(New_Event_Creation_WS.attendees_obj att_obj, List<Medical_Event_vod__c> event_locations,New_Event_Creation_WS.New_Event ne,New_Event_Creation_WS.curriculum_obj curr_obj){
	public static New_Event_Creation_WS.Events_obj create_attendees(New_Event_Creation_WS.Events_obj evt_obj, New_Event_Creation_WS.New_Event ne){
		List<New_Event_Creation_WS.new_attendee> successAttendeesToLog = new List<New_Event_Creation_WS.new_attendee>();
		List<New_Event_Creation_WS.new_attendee> failureAttendeesToLog = new List<New_Event_Creation_WS.new_attendee>();
		
		List<Event_Attendee_vod__c> attendees_to_update = new List<Event_Attendee_vod__c>();
		List<Medical_Event_vod__c> speaker_updates = new List<Medical_Event_vod__c>();
		List<EDM_Event_Attendee_Placeholder_gne__c> placeholders_to_update = new List<EDM_Event_Attendee_Placeholder_gne__c>();
		
		//creates List's of all accounts/contacts and user's which are attendees in SITES
		List<Account> acc_attendee = [SELECT id FROM Account WHERE id IN :evt_obj.att_obj.attendees];
		system.debug('MISZE: acc_attendee :' +acc_attendee);
		system.debug('MISZE: evt_obj.event_locations :' +evt_obj.event_locations);
		List<Contact> cont_attendee = [SELECT id FROM Contact WHERE id IN :evt_obj.att_obj.attendees];
		system.debug('MISZE: cont_attendee :' +cont_attendee);
		List<User> user_attendee = [SELECT id, External_ID_gne__c FROM User WHERE id IN :evt_obj.att_obj.attendees];
		system.debug('MISZE: user_attendee :' +user_attendee);

		Set<String> set_acc_attendee = new Set<String>();
		Set<String> set_cont_attendee = new Set<String>();
		Set<String> set_usr_attendee = new Set<String>();
		Set<String> set_usrID_attendee = new Set<String>();
		Set<String> malforms = new Set<String>();
		
		for(Account acc : acc_attendee){
			String id = acc.id;
			id = id.substring(0,15);
			set_acc_attendee.add(id);
		}
		
		for(Contact cont : cont_attendee){
			String id = cont.id;
			id = id.substring(0,15);
			set_cont_attendee.add(id);
		}
		
		for(User user : user_attendee){
			String id = user.id;
			id = id.substring(0,15);
			set_usr_attendee.add(id);
			set_usrid_attendee.add(user.External_ID_gne__c);
		}
		
		Integer attendees_size = 0;
		for(Integer i=0;i<ne.sites_list.size();i++){
			if(ne.sites_list[i].attendees_list != null){
				for(New_Event_Creation_WS.New_Attendee att : ne.sites_list[i].attendees_list){
					if(String.isNotBlank(att.SFDC_id)){
						if(!set_acc_attendee.contains(att.SFDC_ID) || !set_cont_attendee.contains(att.SFDC_ID)){
							malforms.add(att.SFDC_ID);
						}
					}else if(String.isNotBlank(att.Unix_ID)){
						if(!set_usrID_attendee.contains(att.Unix_ID)){
							malforms.add(att.Unix_ID);
						}
					}
				}
				attendees_size += ne.sites_list[i].attendees_list.size();
			}
		}
		
		//each of these maps are used to contain the Medical Event id and the account/contact/user/placeholder id the event is related to
		Map<String, List<Event_Attendee_vod__c>> event_to_attendeeAcc_map = new Map<String,List<Event_Attendee_vod__c>>();
		Map<String, List<Event_Attendee_vod__c>> event_to_attendeeUsr_map = new Map<String,List<Event_Attendee_vod__c>>();
		Map<String, List<Event_Attendee_vod__c>> event_to_attendeeCont_map = new Map<String,List<Event_Attendee_vod__c>>();
		Map<String, List<EDM_Event_Attendee_Placeholder_gne__c>> event_to_attendeePlace_map = new Map<String, List<EDM_Event_Attendee_Placeholder_gne__c>>();
		
		//get the event attendee and account id for all medical events and account's that are in the acc_attendee List
		//these accounts are for event attendees to be UPDATED
		for(Event_Attendee_vod__c acc_attend : [SELECT id, Medical_Event_vod__c, Account_vod__c FROM Event_Attendee_vod__c WHERE Account_vod__c IN :acc_attendee AND Medical_Event_vod__c IN :evt_obj.event_locations]){
			if(!event_to_attendeeAcc_map.keySet().contains(acc_attend.Medical_Event_vod__c)){
				event_to_attendeeAcc_map.put(acc_attend.Medical_Event_vod__c, new List<Event_Attendee_vod__c>());
			}
			event_to_attendeeAcc_map.get(acc_attend.Medical_Event_vod__c).add(acc_attend);
		}
		system.debug('MISZE: event_to_attendeeAcc_map :' +event_to_attendeeAcc_map);
		//get the event attendee and user id for all medical events and user's that are in the user_attendee List
		//these users are for event attendees to be UPDATED
		system.debug('MISZE: SOQL :' +  [SELECT id, Medical_Event_vod__c, User_vod__c FROM Event_Attendee_vod__c WHERE user_vod__c IN :user_attendee AND Medical_Event_vod__c IN :evt_obj.event_locations]);
		
		for(Event_Attendee_vod__c user_attend : [SELECT id, Medical_Event_vod__c, User_vod__c FROM Event_Attendee_vod__c WHERE user_vod__c IN :user_attendee AND Medical_Event_vod__c IN :evt_obj.event_locations]){
			if(!event_to_attendeeUsr_map.keySet().contains(user_attend.Medical_Event_vod__c)){
				event_to_attendeeUsr_map.put(user_attend.Medical_Event_vod__c, new List<Event_Attendee_vod__c>());
			}
			event_to_attendeeUsr_map.get(user_attend.Medical_Event_vod__c).add(user_attend);
		}
		
		//get the event attendee and contact id for all medical events and contact's that are in the cont_attendee List
		//these contacts are for event attendees to be UPDATED
		for(Event_Attendee_vod__c cont_attend : [SELECT id, Medical_Event_vod__c, Contact_vod__c FROM Event_Attendee_vod__c WHERE Contact_vod__c IN :cont_attendee AND Medical_Event_vod__c in :evt_obj.event_locations]){
			if(!event_to_attendeeCont_map.keySet().contains(cont_attend.Medical_Event_vod__c)){
				event_to_attendeeCont_map.put(cont_attend.Medical_Event_vod__c, new List<Event_Attendee_vod__c>());
			}
			event_to_attendeeCont_map.get(cont_attend.Medical_Event_vod__c).add(cont_attend);
		}

		//get the event attendee placeholder and ssa id for all medical events and ssa ids that are in the ssaid_placeholder List
		//these ssaids are for event attendee placeholders to be UPDATED
		for(EDM_Event_Attendee_Placeholder_gne__c ssaid_placeh : [SELECT id, EDM_Medical_Event_gne__c, EDM_Source_System_Attendee_Id_gne__c FROM EDM_Event_Attendee_Placeholder_gne__c WHERE EDM_Source_System_Attendee_Id_gne__c IN :evt_obj.placeh_obj.placeholders AND EDM_Medical_Event_gne__c in :evt_obj.event_locations]){
			if(!event_to_attendeePlace_map.keySet().contains(ssaid_placeh.EDM_Medical_Event_gne__c)){
				event_to_attendeePlace_map.put(ssaid_placeh.EDM_Medical_Event_gne__c, new List<EDM_Event_Attendee_Placeholder_gne__c>());
			}
			event_to_attendeePlace_map.get(ssaid_placeh.EDM_Medical_Event_gne__c).add(ssaid_placeh);
		}
		
		List<Speaker_Training_gne__c> spk_trainings = new List<Speaker_Training_gne__c>();
		Map<String, List<Speaker_Training_gne__c>> acc_to_spkTr_map = new Map<String, List<Speaker_Training_gne__c>>();
		
		//eventId to Set of attendee ids
		Map<Id, Set<String>> already_updated = new Map<Id, Set<String>>();
		
		if(evt_obj.parent_event.Status_gne__c == 'Occurred' || evt_obj.parent_event.Status_gne__c == 'Closed'){
			//retrieve all speaker training objects which have Speakers that are associated to the speakers realted to the current events
			//being processed, as well as WHERE the medical event the speaker training object is related to is related to the medical
			//event currently being processed - THESE ARE FOR UPDATES TO SPEAKER TRAININGS
			
			for(Speaker_Training_gne__c spkTr : [SELECT Trained_Date_gne__c, Training_Status_gne__c, Speaker_gne__c, Medical_Event_ID_gne__c, Event_Curriculum_gne__c,
												Delivery_Method_gne__c, Curriculum_Version_ID_gne__c FROM Speaker_Training_gne__c WHERE Speaker_gne__c IN :acc_attendee AND Medical_Event_ID_gne__c = :evt_obj.parent_event.Id
												AND Delivery_Method_gne__c != 'Automatic']){
				String speaker = ((String)spkTr.speaker_gne__c).substring(0,15);
				if(!acc_to_spkTr_map.containsKey(speaker)){
					acc_to_spkTr_map.put(speaker, new List<Speaker_Training_gne__c>());
				}
				acc_to_spkTr_map.get(speaker).add(spkTr);
			}
		}
		//iterate through all events (sites)
		for(Medical_Event_vod__c cur_event : evt_obj.event_locations){
			if(event_to_attendeeAcc_map.get(cur_event.id) != null){
				for(Event_Attendee_vod__c eAttendee : event_to_attendeeAcc_map.get(cur_event.id)){
					String id = ((String)eAttendee.Account_vod__c).substring(0,15) + cur_event.Site_ID_gne__c;
					if (evt_obj.att_obj.SFDC_to_attendees_map.get(id) != null) {
						eAttendee.Role_gne__c = evt_obj.att_obj.SFDC_to_attendees_map.get(id).role;
						eAttendee.Status_vod__c = evt_obj.att_obj.SFDC_to_attendees_map.get(id).status;
						eAttendee.Individual_Role_Code_gne__c = evt_obj.att_obj.SFDC_to_attendees_map.get(id).individual_role_code;
						eAttendee.meal_consumption_status_gne__c = evt_obj.att_obj.SFDC_to_attendees_map.get(id).meal_consumption_status;
						eAttendee.Source_System_Attendee_Id_gne__c = evt_obj.att_obj.SFDC_to_attendees_map.get(id).source_system_attendee_id;
						eAttendee.Source_System_Id_gne__c = evt_obj.att_obj.SFDC_to_attendees_map.get(id).source_system_id;
						eAttendee.Street_Address_gne__c = evt_obj.att_obj.SFDC_to_attendees_map.get(id).street_address;
						eAttendee.City_Name_gne__c = evt_obj.att_obj.SFDC_to_attendees_map.get(id).city_name;
						eAttendee.State_Province_Code_gne__C = evt_obj.att_obj.SFDC_to_attendees_map.get(id).state_province_code;
						eAttendee.Country_Code_gne__c = evt_obj.att_obj.SFDC_to_attendees_map.get(id).country_code;
						eAttendee.Zip_Code_gne__c = evt_obj.att_obj.SFDC_to_attendees_map.get(id).zip_code;
						if (evt_obj.att_obj.SFDC_to_attendees_map.get(id).participant_added_date_time != null) {
							eAttendee.Participant_Added_Date_Time_gne__c = evt_obj.att_obj.SFDC_to_attendees_map.get(id).participant_added_date_time;
						}
						if(!already_updated.containsKey(cur_event.id)){
							already_updated.put(cur_event.id, new Set<String>());
						}
						already_updated.get(cur_event.id).add(id);
						attendees_to_update.add(eAttendee);
						successAttendeesToLog.add(evt_obj.att_obj.SFDC_to_attendees_map.get(id));						
					}
				}
			}
			//for all accounts who pertain to this event
			system.debug('curr_event:'+cur_event.Source_System_ID_gne__c);
			system.debug('MAP:'+evt_obj.att_obj.site_to_attendees_map);
			
			if(evt_obj.att_obj.site_to_attendees_map.containsKey(cur_event.Source_System_ID_gne__c+cur_event.Site_ID_gne__c)){
				
				//new changes - This address the site attendees not getting added. 08/06/09
				String eventID = cur_event.Source_System_ID_gne__c+cur_event.Site_ID_gne__c;
				//the following is depricated now because we're using a comination of both aprimo event id and site id to uniquely identify the right event
				
				//the bottom was taken out for the new changes
				for(New_Event_Creation_WS.new_attendee site_Attendee : evt_obj.att_obj.site_to_attendees_map.get(eventID)){
					if(set_acc_attendee.contains(site_attendee.SFDC_ID)){
						if(!already_updated.containsKey(cur_event.id) || !already_updated.get(cur_event.id).contains(site_attendee.SFDC_ID+cur_event.Site_ID_gne__c)){
							Event_Attendee_vod__c eventAttToUpdate = new Event_Attendee_vod__c(Medical_Event_vod__c = cur_event.id, Account_vod__c = site_Attendee.SFDC_ID, Role_gne__c = site_attendee.role, Status_vod__c = site_attendee.Status,
																				Individual_Role_Code_gne__c = site_attendee.individual_role_code,  meal_consumption_status_gne__c = site_attendee.meal_consumption_status,
																				Source_System_Attendee_Id_gne__c = site_attendee.source_system_attendee_id, Source_System_Id_gne__c = site_attendee.source_system_id,
																				Street_Address_gne__c = site_attendee.street_address,
																				City_Name_gne__c = site_attendee.city_name,
																				State_Province_Code_gne__C = site_attendee.state_province_code,
																				Country_Code_gne__c = site_attendee.country_code,
																				Zip_Code_gne__c = site_attendee.zip_code);
							if (site_attendee.participant_added_date_time != null) {
								eventAttToUpdate.Participant_Added_Date_Time_gne__c = site_attendee.participant_added_date_time;
							}
							attendees_to_update.add(eventAttToUpdate);
							system.debug('SW:Log to remove XXXXXXXXXXXXXXXXXXXXXXX line 1169'+site_attendee);
							successAttendeesToLog.add(site_attendee);
						}
						
						/* SPEAKER TRAINING SECTION */
						if(evt_obj.parent_event.Status_gne__c == 'Occurred' || evt_obj.parent_event.Status_gne__c == 'Closed' ){
							if(cur_event.event_type_gne__c == 'Speaker Training' && site_Attendee.Role == 'Attendee' && site_Attendee.status == 'Attended'){
								if(String.isNotEmpty(ne.Curriculum_version_id)){
									for(String current_curr : ne.curriculum_version_id.split(',')){
										if (evt_obj.curr_obj.aprimoID_to_curric_map.get(current_curr) != null) { //Waclaw Smaga 2015/06/01: check if valid curriculum ID
											Boolean containsSpeakerTrainingForCurriculum = false;
											if(acc_to_spkTr_map.containsKey(site_attendee.SFDC_ID)){
												for(Speaker_Training_gne__c spk : acc_to_spkTr_map.get(site_attendee.SFDC_ID)){
													if(evt_obj.curr_obj.aprimoID_to_curric_map.get(current_curr).id == spk.Event_Curriculum_gne__c){
														containsSpeakerTrainingForCurriculum = true;
														try{
															/* Update Current Speaker training Record */
															spk.Medical_Event_ID_gne__c = evt_obj.parent_event.id;
															spk.trained_date_gne__c = ne.start_date;
															spk.Training_Status_gne__c = 'Active';
															spk.Delivery_Method_gne__c = ne.medium_type;
															//The Speaker Training expiration date is equal to the associated curriculums deactivation date - 10/26/09
															spk.Expiration_Date_gne__c = evt_obj.curr_obj.aprimoID_to_curric_map.get(current_curr).Deactivation_Date_gne__c;
														}catch(Exception e){
															GNE_EM3_Monitoring.insertTransactionLogFailure('SFDC-I-01_E4:'+e.getMessage(), ne);
															evt_obj.msgs.Status = 'FAILURE';
															evt_obj.msgs.Message = 'SFDC-I-01_E4:'+e.getMessage();
															return evt_obj;
														}
														spk_trainings.add(spk);
													}
												}
											}
											if(!acc_to_spkTr_map.containsKey(site_attendee.SFDC_ID) || !containsSpeakerTrainingForCurriculum){
												try{
													/* Insert New Speaker training Record */
													//ask about what to do for trained date, what date should it be mapped to FROM the xml
													//Changed as per ticket HD0000002974426 - Duplicate Speaker Training Records Issue
													//Adding the Parent Medical Event ID instead of Site ID.
													spk_trainings.add(new Speaker_Training_gne__c(Curriculum_version_id_gne__c = current_curr, Medical_Event_ID_gne__c = evt_obj.parent_event.id, Event_Curriculum_gne__c = evt_obj.curr_obj.aprimoID_to_curric_map.get(current_curr).id, 
																									trained_date_gne__c = ne.start_date, Training_Status_gne__c = 'Active', Delivery_Method_gne__c = ne.medium_type, 
																									Expiration_Date_gne__c = evt_obj.curr_obj.aprimoID_to_curric_map.get(current_curr).Deactivation_Date_gne__c, Speaker_gne__c = site_attendee.SFDC_ID));
													
												}catch(Exception e){
													GNE_EM3_Monitoring.insertTransactionLogFailure('SFDC-I-01_E4:'+e.getMessage(), ne);
													evt_obj.msgs.Status = 'FAILURE';
													evt_obj.msgs.Message = 'SFDC-I-01_E4:'+e.getMessage();
													return evt_obj;
												}
											}
										}
										else {
											GNE_EM3_Monitoring.insertTransactionLogFailure('Curriculum ID Not Found', ne);
											evt_obj.msgs.Status = 'FAILURE';
											evt_obj.msgs.Message = 'Curriculum ID Not Found';
											return evt_obj;
										}										
									}
								}else {
									GNE_EM3_Monitoring.insertTransactionLogFailure('Tried to create a Speaker Training with no Curriculums.  Curriculum:'+ne.curriculum_version_id, ne);
									evt_obj.msgs.Status = 'FAILURE';
									evt_obj.msgs.Message = 'Tried to create a Speaker Training with no Curriculums.  Curriculum:'+ne.curriculum_version_id;
									return evt_obj;
								}
							}
						}
					} /* END SPEAKER TRAINING SECTION */
				}
				system.debug('MISZE: ADD spk_trainings :'+spk_trainings);
			}
			//for all users who pertain to this event
			if(event_to_attendeeUsr_map.get(cur_event.id) != null){
				for(Event_Attendee_vod__c eAttendee : event_to_attendeeUsr_map.get(cur_event.id)){					
					String id = ((String)eAttendee.User_vod__c).substring(0,15) + cur_event.Site_ID_gne__c;					
					if (evt_obj.att_obj.SFDC_to_attendees_map.get(id) != null) {
						eAttendee.Role_gne__c = evt_obj.att_obj.SFDC_to_attendees_map.get(id).role;
						eAttendee.Status_vod__c = evt_obj.att_obj.SFDC_to_attendees_map.get(id).status;
						eAttendee.Individual_Role_Code_gne__c = evt_obj.att_obj.SFDC_to_attendees_map.get(id).individual_role_code;
						eAttendee.meal_consumption_status_gne__c = evt_obj.att_obj.SFDC_to_attendees_map.get(id).meal_consumption_status;
						eAttendee.Source_System_Attendee_Id_gne__c = evt_obj.att_obj.SFDC_to_attendees_map.get(id).source_system_attendee_id;
						eAttendee.Source_System_Id_gne__c = evt_obj.att_obj.SFDC_to_attendees_map.get(id).source_system_id;
						eAttendee.Street_Address_gne__c = evt_obj.att_obj.SFDC_to_attendees_map.get(id).street_address;
						eAttendee.City_Name_gne__c = evt_obj.att_obj.SFDC_to_attendees_map.get(id).city_name;
						eAttendee.State_Province_Code_gne__C = evt_obj.att_obj.SFDC_to_attendees_map.get(id).state_province_code;
						eAttendee.Country_Code_gne__c = evt_obj.att_obj.SFDC_to_attendees_map.get(id).country_code;
						eAttendee.Zip_Code_gne__c = evt_obj.att_obj.SFDC_to_attendees_map.get(id).zip_code;
						if (evt_obj.att_obj.SFDC_to_attendees_map.get(id).participant_added_date_time != null) {
							eAttendee.Participant_Added_Date_Time_gne__c = evt_obj.att_obj.SFDC_to_attendees_map.get(id).participant_added_date_time;
						}
						if(!already_updated.containsKey(cur_event.id)){
							already_updated.put(cur_event.id, new Set<String>());
						}
						already_updated.get(cur_event.id).add(id);
						
						attendees_to_update.add(eAttendee);
						system.debug('SW:Log to remove XXXXXXXXXXXXXXXXXXXXXXX line 1238'+evt_obj.att_obj.SFDC_to_attendees_map.get(id));
						successAttendeesToLog.add(evt_obj.att_obj.SFDC_to_attendees_map.get(id));
					}
				}
			}
			
			if(evt_obj.att_obj.site_to_attendees_map.keySet().contains(cur_event.Source_System_ID_gne__c+cur_event.Site_ID_gne__c)){
				String eventID = cur_event.Source_System_ID_gne__c+cur_event.Site_ID_gne__c;
				for(New_Event_Creation_WS.new_attendee site_Attendee : evt_obj.att_obj.site_to_attendees_map.get(eventID)){
					if(set_usr_attendee.contains(site_attendee.SFDC_ID)){						
						if(!already_updated.containsKey(cur_event.id) || !already_updated.get(cur_event.id).contains(site_attendee.SFDC_ID+cur_event.Site_ID_gne__c)){							
							Event_Attendee_vod__c eventAttToUpdate = new Event_Attendee_vod__c(
																Medical_Event_vod__c = cur_event.id,
																Status_vod__c = site_Attendee.status,
																User_vod__c = site_Attendee.SFDC_ID,
																Role_gne__c = site_attendee.role,
																Individual_Role_Code_gne__c = site_attendee.individual_role_code,
																meal_consumption_status_gne__c = site_attendee.meal_consumption_status,
																Source_System_Attendee_Id_gne__c = site_attendee.source_system_attendee_id,
																Source_System_Id_gne__c = site_attendee.source_system_id,
																Street_Address_gne__c = site_attendee.street_address,
																City_Name_gne__c = site_attendee.city_name,
																State_Province_Code_gne__C = site_attendee.state_province_code,
																Country_Code_gne__c = site_attendee.country_code,
																Zip_Code_gne__c = site_attendee.zip_code
							);
							if (site_attendee.participant_added_date_time != null) {
								eventAttToUpdate.Participant_Added_Date_Time_gne__c = site_attendee.participant_added_date_time;
							}
							attendees_to_update.add(eventAttToUpdate);
							if(!already_updated.containsKey(cur_event.id)){
								already_updated.put(cur_event.id, new Set<String>());
							}
							already_updated.get(cur_event.id).add(site_Attendee.SFDC_ID+cur_event.Site_ID_gne__c);
							system.debug('SW:Log to remove XXXXXXXXXXXXXXXXXXXXXXX line 1256'+site_attendee);
							successAttendeesToLog.add(site_attendee);
						}
					}
				}
			}
			
			//for all contacts who pertain to this event
			if(event_to_attendeeCont_map.get(cur_event.id) != null){
				for(Event_Attendee_vod__c eAttendee : event_to_attendeeCont_map.get(cur_event.id)){
					String id = eAttendee.Contact_vod__c;
					id = id.substring(0,15) + cur_event.Site_ID_gne__c;
					if (evt_obj.att_obj.SFDC_to_attendees_map.get(id) != null) {
						eAttendee.Role_gne__c = evt_obj.att_obj.SFDC_to_attendees_map.get(id).role;
						eAttendee.Status_vod__c = evt_obj.att_obj.SFDC_to_attendees_map.get(id).status;
						eAttendee.Individual_Role_Code_gne__c = evt_obj.att_obj.SFDC_to_attendees_map.get(id).individual_role_code;
						eAttendee.meal_consumption_status_gne__c = evt_obj.att_obj.SFDC_to_attendees_map.get(id).meal_consumption_status;
						eAttendee.Source_System_Attendee_Id_gne__c = evt_obj.att_obj.SFDC_to_attendees_map.get(id).source_system_attendee_id;
						eAttendee.Source_System_Id_gne__c = evt_obj.att_obj.SFDC_to_attendees_map.get(id).source_system_id;
						eAttendee.Street_Address_gne__c = evt_obj.att_obj.SFDC_to_attendees_map.get(id).street_address;
						eAttendee.City_Name_gne__c = evt_obj.att_obj.SFDC_to_attendees_map.get(id).city_name;
						eAttendee.State_Province_Code_gne__C = evt_obj.att_obj.SFDC_to_attendees_map.get(id).state_province_code;
						eAttendee.Country_Code_gne__c = evt_obj.att_obj.SFDC_to_attendees_map.get(id).country_code;
						eAttendee.Zip_Code_gne__c = evt_obj.att_obj.SFDC_to_attendees_map.get(id).zip_code;
						if (evt_obj.att_obj.SFDC_to_attendees_map.get(id).participant_added_date_time != null) {
							eAttendee.Participant_Added_Date_Time_gne__c = evt_obj.att_obj.SFDC_to_attendees_map.get(id).participant_added_date_time;
						}
						if(!already_updated.containsKey(cur_event.id)){
							already_updated.put(cur_event.id, new Set<String>());
						}
						already_updated.get(cur_event.id).add(id);
						attendees_to_update.add(eAttendee);
						system.debug('SW:Log to remove XXXXXXXXXXXXXXXXXXXXXXX line 1273'+evt_obj.att_obj.SFDC_to_attendees_map.get(id));
						successAttendeesToLog.add(evt_obj.att_obj.SFDC_to_attendees_map.get(id));
					}
				}
			}
			if(evt_obj.att_obj.site_to_attendees_map.keySet().contains(cur_event.Source_System_ID_gne__c+cur_event.Site_ID_gne__c)){
				//new changes - This address the site attendees not getting added. 08/06/09
				String eventID = cur_event.Source_System_ID_gne__c+cur_event.Site_ID_gne__c;
				
				//new changes - This address the site attendees not getting added. 08/06/09
				for(New_Event_Creation_WS.new_attendee site_Attendee : evt_obj.att_obj.site_to_attendees_map.get(eventID)){
					if(set_cont_attendee.contains(site_attendee.SFDC_ID)){
						if(!already_updated.containsKey(cur_event.id) || !already_updated.get(cur_event.id).contains(site_attendee.SFDC_ID+cur_event.Site_ID_gne__c)){
							Event_Attendee_vod__c eventAttToUpdate = new Event_Attendee_vod__c(
																		Medical_Event_vod__c = cur_event.id,
																		Contact_vod__c = site_Attendee.SFDC_ID,
																		Status_vod__c = site_Attendee.status,
																		Role_gne__c = site_attendee.role,
																		Individual_Role_Code_gne__c = site_attendee.individual_role_code,
																		meal_consumption_status_gne__c = site_attendee.meal_consumption_status,
																		Source_System_Attendee_Id_gne__c = site_attendee.source_system_attendee_id,
																		Source_System_Id_gne__c = site_attendee.source_system_id,
																		Street_Address_gne__c = site_attendee.street_address,
																		City_Name_gne__c = site_attendee.city_name,
																		State_Province_Code_gne__C = site_attendee.state_province_code,
																		Country_Code_gne__c = site_attendee.country_code,
																		Zip_Code_gne__c = site_attendee.zip_code);
							if (site_attendee.participant_added_date_time != null) {
								eventAttToUpdate.Participant_Added_Date_Time_gne__c = site_attendee.participant_added_date_time;
							}
							attendees_to_update.add(eventAttToUpdate);
							system.debug('SW:Log to remove XXXXXXXXXXXXXXXXXXXXXXX line 1294'+site_attendee);
							successAttendeesToLog.add(site_attendee);
						}
					}
				}
			}

			//for all placeholders who pertain to this event
			if(event_to_attendeePlace_map.get(cur_event.id) != null){
				for(EDM_Event_Attendee_Placeholder_gne__c eAttendee : event_to_attendeePlace_map.get(cur_event.id)){
					String ssaid = eAttendee.EDM_Source_System_Attendee_Id_gne__c;
					eAttendee.EDM_Role_gne__c = evt_obj.placeh_obj.ssaIdToPlaceholder.get(ssaId).role;
					eAttendee.EDM_Company_Name_gne__c = evt_obj.placeh_obj.ssaIdToPlaceholder.get(ssaId).company_name;
					eAttendee.EDM_First_Name_gne__c = evt_obj.placeh_obj.ssaIdToPlaceholder.get(ssaId).first_name;
					eAttendee.EDM_Last_Name_gne__c = evt_obj.placeh_obj.ssaIdToPlaceholder.get(ssaId).last_name;
					eAttendee.EDM_Status_gne__c = evt_obj.placeh_obj.ssaIdToPlaceholder.get(ssaId).status;
					eAttendee.EDM_Individual_Role_Code_gne__c = evt_obj.placeh_obj.ssaIdToPlaceholder.get(ssaId).individual_role_code;
					eAttendee.EDM_Meal_Consumption_Status_gne__c = evt_obj.placeh_obj.ssaIdToPlaceholder.get(ssaId).meal_consumption_status;
					eAttendee.EDM_Source_System_Attendee_Id_gne__c = evt_obj.placeh_obj.ssaIdToPlaceholder.get(ssaId).source_system_attendee_id;
					eAttendee.EDM_Source_System_Id_gne__c = evt_obj.placeh_obj.ssaIdToPlaceholder.get(ssaId).source_system_id;
					eAttendee.EDM_Street_Address_gne__c = evt_obj.placeh_obj.ssaIdToPlaceholder.get(ssaId).street_address;
					eAttendee.EDM_City_Name_gne__c = evt_obj.placeh_obj.ssaIdToPlaceholder.get(ssaId).city_name;
					eAttendee.EDM_State_Province_Code_gne__C = evt_obj.placeh_obj.ssaIdToPlaceholder.get(ssaId).state_province_code;
					eAttendee.EDM_Country_Code_gne__c = evt_obj.placeh_obj.ssaIdToPlaceholder.get(ssaId).country_code;
					eAttendee.EDM_Zip_Code_gne__c = evt_obj.placeh_obj.ssaIdToPlaceholder.get(ssaId).zip_code;
					if (evt_obj.placeh_obj.ssaIdToPlaceholder.get(ssaId).participant_added_date_time != null) {
						eAttendee.Participant_Added_Date_Time_gne__c = evt_obj.placeh_obj.ssaIdToPlaceholder.get(ssaId).participant_added_date_time;
					}
					if(!already_updated.containsKey(cur_event.id)){
						already_updated.put(cur_event.id, new Set<String>());
					}
					already_updated.get(cur_event.id).add(ssaId);
					placeholders_to_update.add(eAttendee);
					system.debug('SW:Log to remove XXXXXXXXXXXXXXXXXXXXXXX line 1273'+evt_obj.placeh_obj.ssaIdToPlaceholder.get(ssaId));
					successAttendeesToLog.add(evt_obj.placeh_obj.ssaIdToPlaceholder.get(ssaId));
				}
			}
			system.debug('PP: evt_obj.placeh_obj.site_to_placeholders_map: ' + evt_obj.placeh_obj.site_to_placeholders_map);
			system.debug('PP: map key' + cur_event.Source_System_ID_gne__c + cur_event.Site_ID_gne__c);
			if(evt_obj.placeh_obj.site_to_placeholders_map.keySet().contains(cur_event.Source_System_ID_gne__c + cur_event.Site_ID_gne__c)){
				String eventID = cur_event.Source_System_ID_gne__c + cur_event.Site_ID_gne__c;
				
				for(New_Event_Creation_WS.new_attendee site_attendee : evt_obj.placeh_obj.site_to_placeholders_map.get(eventID)){
					if(!already_updated.containsKey(cur_event.id) || !already_updated.get(cur_event.id).contains(site_attendee.source_system_attendee_id)){
						EDM_Event_Attendee_Placeholder_gne__c eventAttToUpdate = new EDM_Event_Attendee_Placeholder_gne__c(
																	EDM_Medical_Event_gne__c = cur_event.id,
																	EDM_Status_gne__c = site_Attendee.status,
																	EDM_Company_Name_gne__c = site_Attendee.company_name,
																	EDM_First_Name_gne__c = site_Attendee.first_name,
																	EDM_Last_Name_gne__c = site_Attendee.last_name,
																	EDM_Role_gne__c = site_attendee.role,
																	EDM_Individual_Role_Code_gne__c = site_attendee.individual_role_code,
																	EDM_Meal_Consumption_Status_gne__c = site_attendee.meal_consumption_status,
																	EDM_Source_System_Attendee_Id_gne__c = site_attendee.source_system_attendee_id,
																	EDM_Source_System_Id_gne__c = site_attendee.source_system_id,
																	EDM_Street_Address_gne__c = site_attendee.street_address,
																	EDM_City_Name_gne__c = site_attendee.city_name,
																	EDM_State_Province_Code_gne__c = site_attendee.state_province_code,
																	EDM_Country_Code_gne__c = site_attendee.country_code,
																	EDM_Zip_Code_gne__c = site_attendee.zip_code);
						if (site_attendee.participant_added_date_time != null) {
							eventAttToUpdate.Participant_Added_Date_Time_gne__c = site_attendee.participant_added_date_time;
						}
						placeholders_to_update.add(eventAttToUpdate);
						system.debug('SW:Log to remove XXXXXXXXXXXXXXXXXXXXXXX line 1294'+site_attendee);
						successAttendeesToLog.add(site_attendee);
					}
				}
			}
		}
		evt_obj.att_spk_obj.spk_trainings = spk_trainings; 
		evt_obj.att_spk_obj.attendees_to_update = attendees_to_update;
		evt_obj.att_spk_obj.event_att_placeholders_to_update = placeholders_to_update;
		if(!speaker_updates.isEmpty()){
			try{
				update(speaker_updates);
			}catch(DmlException e){
				system.debug(e.getMessage());
			}
		}
		GNE_EM3_Monitoring.insertEventAttendeeLogSuccess(successAttendeesToLog, ne);
		GNE_EM3_Monitoring.insertEventAttendeeLogFailure('Malformed Attendee', failureAttendeesToLog, ne);
		return evt_obj;
	}
	
	public static List<Medical_Event_vod__c> removeSitesWithAttendes(List<Database.upsertResult> results){
		Set<Id> parent_event_ids = new Set<Id>();
		Set<Id> medifal_events_Ids = new Set<Id>();
		for(Database.upsertResult result:results){
			if (result.isSuccess()){
				medifal_events_Ids.add(result.getId());
			}
		}
		for(Medical_Event_vod__c tmpMedEvent : [SELECT parent_medical_event_gne__c, Id FROM Medical_Event_vod__c m WHERE Id IN :medifal_events_Ids for update]){
			if(tmpMedEvent.parent_medical_event_gne__c != null){
				parent_event_ids.add(tmpMedEvent.parent_medical_event_gne__c);
			}
		}
		system.debug('XXX removeSitesWithAttendes : parent_event_ids : '+ parent_event_ids);
		return [SELECT Id FROM Medical_Event_vod__c WHERE Id  NOT IN :medifal_events_Ids AND parent_medical_event_gne__c IN :parent_event_ids for update];
	}
	
	public static List<Speaker_Training_gne__c> removeSpkTrainingsAfterUpsert(List<Database.upsertResult> results, Id medicalEventId){
		Set<Id> spk_training_Ids = new Set<Id>();
		for(Database.upsertResult result:results){
			if (result.isSuccess()){
				spk_training_Ids.add(result.getId());
			}
		}
		return [SELECT Id FROM Speaker_Training_gne__c WHERE Medical_Event_ID_gne__c = :medicalEventId AND Id NOT IN :spk_training_Ids AND Delivery_Method_gne__c != 'Automatic'];
	}
	
	/*Return list of curriculum junction objects to remove.
	* @param evt_obj eventObject
	* @param aprimo_curr_list list of curriculum aprimo ids
	* @return list of Event_Curriculum_Join_gne__c object to remove
	*/
	public static List<Event_Curriculum_Join_gne__c> removeCurrJoin(New_Event_Creation_WS.Events_obj evt_obj, List<String> aprimo_curr_list){
		List<Id>medicalEventsIds = new List<Id>();
		medicalEventsIds.add(evt_obj.parent_event.Id);
		
		if(evt_obj.event_locations != null){
			for(Medical_Event_vod__c me: evt_obj.event_locations){
				medicalEventsIds.add(me.Id);
			}
		}
		return [SELECT Id, Medical_Event_gne__c, Event_Curriculum_gne__c FROM Event_Curriculum_Join_gne__c WHERE Medical_Event_gne__c IN :medicalEventsIds AND Event_Curriculum_gne__r.Aprimo_ID_gne__c NOT IN :aprimo_curr_list];
	}
	
	public static List<Event_Attendee_vod__c> removeAttendeesAfterUpsert(List<Database.upsertResult> results){
		Set<Id> attend_Ids = new Set<Id>();
		Set<Id> medifal_events_Ids = new Set<Id>();
		for(Database.upsertResult result:results){
			if (result.isSuccess()){
				attend_Ids.add(result.getId());
			}
		}
		for(Event_Attendee_vod__c tmpAttende : [SELECT Id,Account_vod__c, Medical_Event_vod__c, Medical_Event_vod__r.parent_medical_event_gne__c FROM Event_Attendee_vod__c WHERE Id IN :attend_Ids]){
			if(tmpAttende.Medical_Event_vod__r.parent_medical_event_gne__c != null){
				medifal_events_Ids.add(tmpAttende.Medical_Event_vod__c);
			}
		}
		system.debug('XXX Attendess medifal_events_Ids' + medifal_events_Ids);
		return [SELECT Id, Account_vod__c, Medical_Event_vod__c FROM Event_Attendee_vod__c WHERE Id NOT IN :attend_Ids AND Medical_Event_vod__c IN :medifal_events_Ids];
	}
	
	public static List<Event_Attendee_vod__c> removeEventAttendeesAfterUpsert(List<Database.upsertResult> results){
		Set<Id> attend_Ids = new Set<Id>();
		Set<Id> medifal_events_Ids = new Set<Id>();
		system.debug('XXX removeAttendeesAfterUpsert : results :' +results);
		for(Database.upsertResult result:results){
			if (result.isSuccess()){
				attend_Ids.add(result.getId());
			}
		}
		for(Event_Attendee_vod__c tmpAttende : [SELECT Id, Account_vod__c, Medical_Event_vod__c, Medical_Event_vod__r.parent_medical_event_gne__c FROM Event_Attendee_vod__c WHERE Id IN :attend_Ids ]){
			if(tmpAttende.Medical_Event_vod__r.parent_medical_event_gne__c == null){
				medifal_events_Ids.add(tmpAttende.Medical_Event_vod__c);
			}
		}
		return [SELECT Id, Account_vod__c, Medical_Event_vod__c FROM Event_Attendee_vod__c WHERE Id NOT IN :attend_Ids AND Medical_Event_vod__c IN :medifal_events_Ids];
	}

	public static List<EDM_Event_Attendee_Placeholder_gne__c> removePlaceholdersAfterUpsert(List<Database.upsertResult> results, New_Event_Creation_WS.Events_obj evt_obj){
		Set<Id> attend_Ids = new Set<Id>();
		Set<Id> medical_events_Ids = new Set<Id>();
		for(Database.upsertResult result:results){
			if (result.isSuccess()){
				attend_Ids.add(result.getId());
			}
		}
	/*	for(EDM_Event_Attendee_Placeholder_gne__c tmpAttende : [SELECT Id, EDM_Medical_Event_gne__c, 
												EDM_Medical_Event_gne__r.Parent_Medical_Event_gne__c, EDM_Source_System_Attendee_Id_gne__c
												FROM EDM_Event_Attendee_Placeholder_gne__c WHERE Id IN :attend_Ids]){
			if(tmpAttende.EDM_Medical_Event_gne__r.Parent_Medical_Event_gne__c != null){
				medical_events_Ids.add(tmpAttende.EDM_Medical_Event_gne__c);
			}
		}*/

		system.debug('PP EDM Attendee Placeholders medical_events_Ids' + medical_events_Ids);
		return [SELECT Id, EDM_Source_System_Attendee_Id_gne__c, EDM_Medical_Event_gne__c 
				FROM EDM_Event_Attendee_Placeholder_gne__c WHERE Id NOT IN :attend_Ids AND EDM_Medical_Event_gne__c IN :evt_obj.event_locations];
	}

	public static List<SelectOption> getTargetAudiencePicklistValues() {
        List<EDM_Curriculum_Target_Audience_gne__c> targetAudiencesListFromCs = [Select ID, Name, Target_Audience_gne__c, Order_gne__c From EDM_Curriculum_Target_Audience_gne__c order by Order_gne__c ASC];
		List<SelectOption> targetAudiences = new List<SelectOption>();
		for(EDM_Curriculum_Target_Audience_gne__c ta : targetAudiencesListFromCs) {
			targetAudiences.add(new SelectOption(ta.Target_Audience_gne__c, ta.Target_Audience_gne__c));
		}
        return targetAudiences;
    }	
}