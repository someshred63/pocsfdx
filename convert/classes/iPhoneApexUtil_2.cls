public without sharing class iPhoneApexUtil_2 {

	//constant values for error messages
	static final String DISBURSEMENT_INVALID_ATTENDEE = 'Invalid Attendee';
	static final String DISBURSEMENT_INVALID_SIGNATURE = 'Invalid Signature';
	static final String DISBURSEMENT_INVALID_SIGNATURE_DATE = 'Invalid Signature Date';
	static final String DISBURSEMENT_INVALID_SAMPLE = 'Invalid Sample';
	static final String DISBURSEMENT_INVALID_SAMPLE_FOR_RECIEVER = 'Invalid Sample for sample reciever';
	static final String DISBURSEMENT_INVALID_LOT = 'Invalid Lot';
	static final String DISBURSEMENT_INVALID_QUANTITY = 'Invalid Quantity';
	static final String DISBURSEMENT_INVALID_PRODUCT = 'Invalid Product';
	static final String DISBURSEMENT_INVALID_ACCOUNT = 'Invalid Account';
	static final String DISBURSEMENT_INVALID_ADDRESS = 'Invalid Address';
	static final String DISBURSEMENT_INVALID_LICENSE = 'Invalid License';
	static final String DISBURSEMENT_INVALID_LICENSE_TO_ADDRESS = 'Invalid License to Address';
	static final String DISBURSEMENT_LICENSE_NOT_MATCH_ACCOUNT = 'License does not match Account';
	static final String DISBURSEMENT_LICENSE_NOT_MATCH_ADDRESS_STATE= 'Licence doen not match Address State';
	static final String DISBURSEMENT_LICENSE_NOT_VALID_TO_SAMPLE = 'Licence not valid to sample';
	static final String DISBURSEMENT_LICENSE_EXPIRED = 'Licence expired';
	static final String DISBURSEMENT_SIGNATURE_PARAMATERS = 'Invalid Signature Paramenters';
	static final String DISBURSEMENT_SIGNATURE_DATE = 'Invalid Signature Date';
	static final String DISBURSEMENT_SIGNATURE_DISCLAIMER = 'Invalid Signature Disclaimer';
	static final String DISBURSEMENT_SIGNATURE_LICENSENUMBER = 'Invalid Signature LicenseNumber';
	static final String DISBURSEMENT_INVALID_SAMPLERECIEVER = 'Invalid Sample Reciever';

	static final String REQUESTID_VALENG_PREFIX_FOR_MAIN_CALL = 'Valeng_INT';
	static final String REQUESTID_VALENG_PREFIX_FOR_ATTENDEE = 'Valeng_ATT';
	static final String REQUESTID_VALENG_PREFIX_FOR_SAMPLE = 'Valeng_SAM';
	static final String REQUESTID_VALENG_PREFIX_FOR_PFG = 'Valeng_PFG';
	static final String REQUESTID_VALENG_PREFIX_FOR_DETAIL = 'Valeng_DET';
	static final String REQUESTID_VALENG_PREFIX_FOR_DISCUSSION= 'Valeng_DISC';

	static final String NonProduct_NonMolecule= 'Non-Product/Non-Molecule';
	public static Boolean ignoreValidationTrigger = false;
	public static Map<Id, List<Call2_Sample_vod__c>> callSampleCache;
	public static Map<String,SObject> callChildRecordsCache = new Map<String,SObject>();
    
    public static Map<String,String> prefixToSObjectType = new Map<String,String>();
    static {
        prefixToSObjectType.put(Account.sObjectType.getDescribe().getKeyPrefix(), 'Account');
        prefixToSObjectType.put(Contact.sObjectType.getDescribe().getKeyPrefix(), 'Contact');
    }

	public class MyException extends Exception {}

	/* Get List of Territories assigned to the logged in User
	1. If user exists in only one territory then assign user territory to call2_vod__c.teritory_vod__c
	2. If user does not exist in any territory then do nothing
	3. If user exists in more than one terrirory then get the account's territories and assign the intersection of user AND account teritory to call2_vod__c.teritory_vod__c
	*/
	public static String getUserTerritoryId(String callUserId, String callAcountId){
		String territoryId;
		String territoryName;
		List<String> userTerritoryList = new List<String>();

		try{
			for (UserTerritory2Association u: [SELECT ut.Territory2Id FROM UserTerritory2Association ut WHERE ut.UserId = :callUserId]){
				userTerritoryList.add(u.Territory2Id);
			}
			if (userTerritoryList.size() == 0){
				//do nothing
			}else if (userTerritoryList.size() == 1){
				territoryId = userTerritoryList.get(0);
			}else if (userTerritoryList.size() > 1){
				if(callAcountId != null){
					// Get GroupId of Account
					List<String> accountGroupList = new List<String>();
					try{
						for (AccountShare a: [ SELECT UserOrGroupId FROM AccountShare WHERE accountId = :callAcountId]){
							accountGroupList.add(a.UserOrGroupId);
						}
					}catch(Exception ex){
						//do nothing
					}

					if (accountGroupList.size() > 0){
						// get common Territory list for from_account AND user
						Group g;
						try{
							g = [SELECT RelatedId, ID FROM Group WHERE Id in :accountGroupList	AND Type = 'Territory'	AND RelatedId in :userTerritoryList limit 1];
						}catch(Exception ex){
							//do nothing
						}

						if(g != null){
							territoryId = g.relatedId;
						}else{
							territoryId = userTerritoryList.get(0);
						}
					}else{
						territoryId = userTerritoryList.get(0);
					}
					//if accountId is null then assign the first user territory to call2_vod__c.territory_vod__c
				}else {
					territoryId = userTerritoryList.get(0);
				}
			}
			if (territoryId != null){
				territoryName = [SELECT name FROM Territory2 WHERE id = :territoryId limit 1].name;
			}
		}catch(Exception ex){
			//do nothing
		}
		return territoryName;
	}

	/////////////////////////////Merge Account methods////////////////////////////////////

	//create AND return a list of acountIds passed to iPhoneApex_2 to later get their merged acoount Ids
	public static List<String> accountIdsFromCallAttribute(iPhoneApex_2.CallAttributes callAttributes){
		List<String> acctIds = new List<String>();
		if(callAttributes.Account != null){
			acctIds.add(callAttributes.Account);
		}
		if (callAttributes.CallAttendeeList != null) {
			for (iPhoneApex_2.CallAttendee attendee : callAttributes.CallAttendeeList){
				if(attendee.Attendee != null){
					acctIds.add(attendee.Attendee);
				}
			}
		}
		if (callAttributes.callSampleList != null) {
			for (iPhoneApex_2.CallSample callSample : callAttributes.callSampleList) {
				acctIds.add(callSample.Account);
			}
		}
		return acctIds;
	}


	//create AND return map(accounts to their merged acountId) for merged acounts
	public static Map<String, String> findMergedAccounts (List<String> acctIds){
		Map<String, String> mapAcctToMergedAcct = new Map<String, String>();
		try{
			// Check DCH_Parent_Id_gne__r.Id instead of DCH_Parent_Id_gne__c to make sure that Parent still exists
			List<Account> objAcct = [SELECT Id, Name, DCH_Previous_Id_gne__c, DCH_Parent_Id_gne__c FROM Account WHERE DCH_Parent_Id_gne__r.Id != null AND DCH_Action_gne__c='Merge (Loser)' AND DCH_Previous_Id_gne__c IN : acctIds];
			for(Account act : objAcct){
				mapAcctToMergedAcct.put(act.DCH_Previous_Id_gne__c, act.DCH_Parent_Id_gne__c);
			}
		}catch(Exception ex){
			//do nothing
		}
		return mapAcctToMergedAcct;
	}

	//create AND return map(AddressId to their Merged AdressId) for merged Addreses
	public static Map<String, String> findMergedAddresses (List<String> addrIds){
		Map<String, String> mapAddrToMergedAAddr = new Map<String, String>();
		try{
			// Check DCH_Parent_Id_gne__r.Id instead of DCH_Parent_Id_gne__c to make sure that Parent still exists
			List<Address_vod__c> objAddr = [SELECT Id, Name, DCH_Action_gne__c, DCH_Parent_Id_gne__c, DCH_Previous_Id_gne__c FROM Address_vod__c a WHERE DCH_Parent_Id_gne__r.Id != null AND DCH_Action_gne__c='Merge (Loser)' AND DCH_Previous_Id_gne__c IN : addrIds];
			for(Address_vod__c adr : objAddr){
				mapAddrToMergedAAddr.put(adr.DCH_Previous_Id_gne__c, adr.DCH_Parent_Id_gne__c);
			}
		}catch(Exception ex){
			//do nothing
		}
		return mapAddrToMergedAAddr;
	}

	/////////////////////////////Ends Merge Account methods////////////////////////////////////

	//convert callattributes to corresponding list AND string representation to send to future method
	static Map<String, Map<String, String>> convertCallAtributesToMap(iPhoneApex_2.CallAttributes callAttributes){
		Map<String, Map<String, String>> callAttributesMap = new Map<String, Map<String, String>>();

		Map<String, String> callAttribMap = new Map<String, String>();
		Map<String, String> callAttendeeMap = new Map<String, String>();
		Map<String, String> callSampleMap = new Map<String, String>();
		Map<String, String> callPfgDetailMap = new Map<String, String>();

		Integer cnt =1;
		if(callAttributes.CallAttendeeList != null){
			for(iPhoneApex_2.CallAttendee attendee : callAttributes.CallAttendeeList){
				String joinAttendeeAttrib = '';
				if(attendee.Attendee != null){
					joinAttendeeAttrib = attendee.Attendee;
				}
				joinAttendeeAttrib = joinAttendeeAttrib + '::';

				if(attendee.RequestId != null){
					joinAttendeeAttrib=joinAttendeeAttrib + attendee.RequestId;
				}
				joinAttendeeAttrib = joinAttendeeAttrib + '::';

				if(attendee.CallAttendeeType != null){
					joinAttendeeAttrib=joinAttendeeAttrib + attendee.CallAttendeeType.Name();
				}
				callAttendeeMap.put(String.valueOf(cnt), joinAttendeeAttrib);
				cnt++;
			}
		}
		cnt = 1;
		if(callAttributes.callSampleList != null) {
			for (iPhoneApex_2.CallSample callSample : callAttributes.callSampleList) {
				String joinSampleAttrib = String.join(new List<String> {
					callSample.Product != null ? callSample.Product : '',
					callSample.Account != null ? callSample.Account : '',
					callSample.RequestId != null ? callSample.RequestId : '',
					callSample.LotNo != null ? callSample.LotNo : '',
					callSample.Quantity != null ? String.valueOf(callSample.Quantity) : ''
				},'::');
				callSampleMap.put(String.valueOf(cnt++), joinSampleAttrib);
			}
		}
		cnt = 1;
		if(callAttributes.callPfgDetailList != null) {
			for (iPhoneApex_2.CallPfgDetail callPfgDetail : callAttributes.callPfgDetailList) {
				String joinPfgDetailAttrib = String.join(new List<String> {
					callPfgDetail.Product != null ? callPfgDetail.Product : '',
					callPfgDetail.Account != null ? callPfgDetail.Account : '',
					callPfgDetail.RequestId != null ? callPfgDetail.RequestId : '',
					callPfgDetail.LotNo != null ? callPfgDetail.LotNo : '',
					callPfgDetail.Quantity != null ? String.valueOf(callPfgDetail.Quantity) : ''
				},'::');
				callPfgDetailMap.put(String.valueOf(cnt++), joinPfgDetailAttrib);
			}
		}
		if(callAttributes.id != null){
			callAttribMap.put('Id', callAttributes.id);
		}
		if(callAttributes.Account != null){
			callAttribMap.put('Account', callAttributes.Account);
		}
		if(callAttributes.Address != null){
			callAttribMap.put('Address', callAttributes.Address);
		}
		if(callAttributes.AddressText != null){
			callAttribMap.put('AddressText', callAttributes.AddressText);
		}
		if(callAttributes.InteractionType != null){
			callAttribMap.put('InteractionType', callAttributes.InteractionType);
		}
		if(callAttributes.RequestId != null){
			callAttribMap.put('RequestId', callAttributes.RequestId);
		}
		if(callAttributes.BusinessSponsor != null){
			callAttribMap.put('BusinessSponsor', callAttributes.BusinessSponsor);
		}
		if(callAttributes.MealLocationCity != null){
			callAttribMap.put('MealLocationCity', callAttributes.MealLocationCity);
		}
		if(callAttributes.MealLocationState != null){
			callAttribMap.put('MealLocationState', callAttributes.MealLocationState);
		}
		if(callAttributes.SpendUser != null){
			callAttribMap.put('SpendUser', callAttributes.SpendUser);
		}
		if(callAttributes.OwnerId != null){
			callAttribMap.put('OwnerId', callAttributes.OwnerId);
		}
		if(callAttributes.id != null){
			callAttribMap.put('Id', callAttributes.id);
		}
		if(callAttributes.TerritoryName != null){
			callAttribMap.put('TerritoryName', callAttributes.TerritoryName);
		}
		if(callAttributes.CallAttendeeType != null){
			callAttribMap.put('CallAttendeeType', callAttributes.CallAttendeeType.Name());
		}
		if(callAttributes.NumOfCustomersPresent != null){
			callAttribMap.put('NumOfCustomersPresent', String.valueOf(callAttributes.NumOfCustomersPresent));
		}
		if(callAttributes.MealPlannedAttendeeCount != null){
			callAttribMap.put('MealPlannedAttendeeCount', String.valueOf(callAttributes.MealPlannedAttendeeCount));
		}
		if(callAttributes.MealActualAttendeeCount != null){
			callAttribMap.put('MealActualAttendeeCount', String.valueOf(callAttributes.MealActualAttendeeCount));
		}
		if(callAttributes.MealAmount != null){
			callAttribMap.put('MealAmount', String.valueOf(callAttributes.MealAmount));
		}
		if(callAttributes.CallDateTime  != null){
			callAttribMap.put('CallDateTime', callAttributes.CallDateTime.format('yyyy-MM-dd HH:mm:ss.sss'));
		}
		if(callAttributes.IsComplete != null){
			callAttribMap.put('IsComplete', String.valueOf(callAttributes.IsComplete));
		}
		if(callAttributes.isOtrRequest != null){
			callAttribMap.put('isOtrRequest', String.valueOf(callAttributes.isOtrRequest));
		}
		if(callAttributes.ContractedServices != null){
			callAttribMap.put('ContractedServices', String.valueOf(callAttributes.ContractedServices));
		}
		if(callAttributes.ValidationEngine != null){
			callAttribMap.put('ValidationEngine', String.valueOf(callAttributes.ValidationEngine));
		}
		//sampleable fields
		if(callAttributes.Signature != null){
			callAttribMap.put('Signature', callAttributes.Signature);
		}
		if(callAttributes.Disclaimer != null){
			callAttribMap.put('Disclaimer', callAttributes.Disclaimer);
		}
		if(callAttributes.SampleReceiver != null){
			callAttribMap.put('SampleReceiver', callAttributes.SampleReceiver);
		}
		if(callAttributes.LicenseNumber != null){
			callAttribMap.put('LicenseNumber', callAttributes.LicenseNumber);
		}
		if(callAttributes.SignatureDate  != null){
			callAttribMap.put('SignatureDate', callAttributes.SignatureDate.format('yyyy-MM-dd HH:mm:ss.sss'));
		}

		callAttributesMap.put('callAttributes', callAttribMap);
		callAttributesMap.put('CallAttendee', callAttendeeMap);
		callAttributesMap.put('CallSample', callSampleMap);
		callAttributesMap.put('CallPfgDetail', callPfgDetailMap);

		return callAttributesMap;
	}

	//deletes AND archives the call AND its related items
	//when the main call objects get deleted the trigger will delete all child calls AND their relateditems automatically
	public static void deletCallHelper(String callId){
		List<Call2_vod__c> callDeleteList = new List<Call2_vod__c>();
		List<Call2_vod__c>  callList = [SELECT id, parent_call_vod__c, account_vod__c, attendee_type_vod__c, call_type_vod__c, parent_address_vod__c,address_vod__c, completed_gne__c, customers_gne__c, meal_expense_gne__c,detailed_products_vod__c,
											planned_attendees_gne__c,actual_attendees_gne__c, business_sponsor_gne__c, city_gne__c, state_gne__c, Status_vod__c, iPhone_Request_Id_gne__c, Signature_Date_vod__c, License_vod__c, License_designation_gne__c, Last_Device_vod__c
										FROM Call2_vod__c
										WHERE (Id = :callId OR parent_call_vod__c = :callId)];

		for(Call2_vod__c cl : callList){
			if(cl.Completed_gne__c){
				throw new MyException('Cannot delete a Completed call');
			}
		}

		//deleting main call will automatically delete AND archive all child calls AND their related items by a trigger on the call object
		//main call is the string callId passed as parameter to this method but confirming here again if the callId is for the main call
		for(Call2_vod__c cl : callList){
			if(cl.parent_call_vod__c == null){
				callDeleteList.add(cl);
				break;//main call found now exit
			}
		}

		if(callDeleteList.size()>0){
			delete callDeleteList;
		}else{
			throw new MyException('Invalid Call');
		}
	}

	public static iPhoneApex_2.CallAttributes getCallAttributes(String callId){
		List<Call2_vod__c> callList = [SELECT id, parent_call_vod__c, call_datetime_vod__c, attendee_type_vod__c, account_vod__c, call_type_vod__c, interaction_type_gne__c, parent_address_vod__c,address_vod__c,
										completed_gne__c, customers_gne__c, meal_expense_gne__c,meal_amount_gne__c, planned_attendees_gne__c,actual_attendees_gne__c, detailed_products_vod__c, Business_sponsor_gne__c,
										city_gne__c, state_gne__c, iphone_request_id_gne__c, Territory_vod__c, Territory_Id_gne__c, Spend_User_gne__c, Contracted_Services_gne__c, Signature_vod__c, Interaction_Method_gne__c, Interaction_Location_gne__c,
										Primary_Interaction_Reason_gne__c, Visit_Reason_gne__c, Visit_Reason_Description_gne__c, Is_Referral_gne__c, Other_Referral_Source_gne__c, Referral_Requested_By_gne__c, Referral_Requested_Date_gne__c, Referral_Source_gne__c,
										Group_RAMA_gne__c, Access_Echo_Alignment_RAMA_gne__c, Objectives_RAMA_gne__c, Key_Messages_RAMA_gne__c, Outcomes_RAMA_gne__c, Next_Steps_RAMA_gne__c, No_InService_Attendees__c, Other_Attendees_Count_gne__c,
										(SELECT id,iphone_request_id_gne__c, product_vod__c, Detail_Priority_vod__c, Therapeutic_Area_gne__c, Indication_gne__c FROM call2_detail_vod__r order by iphone_request_id_gne__c),
										(SELECT id,iphone_request_id_gne__c, product_vod__c, product_strategy_Vod__c, product_tactic_vod__c, PREP_MBO_gne__c, Non_provider_Group__c , Patient_Journey_F2F_or_Virtual__c , Patient_Interaction_F2F_or_Virtual__c ,  reaction_gne__c FROM call2_discussion_vod__r order by iphone_request_id_gne__c),
										(SELECT id, iphone_request_id_gne__c, account_vod__c, contact_vod__c, user_vod__c, attendee_type_vod__c, address_vod__c FROM call2_vod__r order by iphone_request_id_gne__c)
									FROM Call2_vod__c
									WHERE Id = :callId AND parent_call_vod__c = null];
		iPhoneApex_2.CallAttributes callAttributes = null;
		if (callList.size() == 1) {
			callAttributes = new iPhoneApex_2.CallAttributes();
			callAttributes.callAttendeeList = new List<iPhoneApex_2.CallAttendee>();
			callAttributes.callDetailList = new List<iPhoneApex_2.CallDetail>();
			callAttributes.callDiscussionList = new List<iPhoneApex_2.CallDiscussion>();

			Call2_vod__c callRecord = callList[0];
			callAttributes.CallAttendeeType = iPhoneApex_2.AttendeeType.PERSONACCOUNT;

			callAttributes.Id = callRecord.Id;
			callAttributes.RequestId = callRecord.iPhone_Request_id_gne__c;
			callAttributes.InteractionType = callRecord.Interaction_Type_gne__c;
			callAttributes.Account = callRecord.account_vod__c;
			callAttributes.CallDateTime = callRecord.call_datetime_vod__c;
			callAttributes.NumOfCustomersPresent = callRecord.customers_gne__c != null ?
			callRecord.customers_gne__c.intValue():0;
			callAttributes.AttendeesInService = callRecord.No_InService_Attendees__c != null ? callRecord.No_InService_Attendees__c.intValue() : 0;
			callAttributes.OtherAttendeesCount = callRecord.Other_Attendees_Count_gne__c != null ? callRecord.Other_Attendees_Count_gne__c.intValue() : 0;

			callAttributes.IsComplete = callRecord.completed_gne__c != null ?
			callRecord.completed_gne__c : FALSE;
			callAttributes.isOtrRequest = false;

			callAttributes.BusinessSponsor = callRecord.Business_Sponsor_gne__c;
			callAttributes.MealLocationCity = callRecord.City_gne__c;
			callAttributes.MealLocationState = callRecord.State_gne__c;

			callAttributes.InteractionMethod = callRecord.Interaction_Method_gne__c;
			callAttributes.InteractionLocation = callRecord.Interaction_Location_gne__c;

			callAttributes.isReferral = callRecord.Is_Referral_gne__c;
			callAttributes.otherReferralSource = callRecord.Other_Referral_Source_gne__c;
			callAttributes.referralRequestedBy = callRecord.Referral_Requested_By_gne__c;
			callAttributes.referralRequestedDate = callRecord.Referral_Requested_Date_gne__c;
			callAttributes.referralSource = callRecord.Referral_Source_gne__c;
			
			callattributes.GroupCanada = callRecord.Group_RAMA_gne__c;
			callAttributes.AccessEchoAlignment = callRecord.Access_Echo_Alignment_RAMA_gne__c;
			callattributes.NoteObjectives = callRecord.Objectives_RAMA_gne__c;
			callattributes.NoteKeyMessages = callRecord.Key_Messages_RAMA_gne__c;
			callattributes.NoteOutcomes = callRecord.Outcomes_RAMA_gne__c;
			callattributes.NoteNextSteps = callRecord.Next_Steps_RAMA_gne__c;

			if (callRecord.call_type_vod__c.equalsIgnoreCase('Group_Account_vod')){
				callAttributes.CallAttendeeType = iPhoneApex_2.AttendeeType.ACCOUNT;
			}
			if (callRecord.Address_vod__c != null) {
				callAttributes.Address = callRecord.Parent_address_vod__c;
				callAttributes.AddressText = callRecord.address_vod__c;
			}
			if (callRecord.meal_amount_gne__c != null) {
				callAttributes.MealAmount = callRecord.meal_amount_gne__c;
			}
			if (callRecord.planned_attendees_gne__c != null &&
					callRecord.actual_attendees_gne__c != null) {
				callAttributes.MealPlannedAttendeeCount = callRecord.planned_attendees_gne__c.intValue();
				callAttributes.MealActualAttendeecount = callRecord.actual_attendees_gne__c.intValue();
			}
			if (callRecord.Spend_User_gne__c != null) {
				callAttributes.SpendUser = callRecord.Spend_User_gne__c;
			}
			if (callRecord.Contracted_Services_gne__c != null) {
				callAttributes.ContractedServices = callRecord.Contracted_Services_gne__c;
			}

			for (Call2_vod__c callAttendeeRecord : callRecord.call2_vod__r) {
				iPhoneApex_2.CallAttendee cAttendee = new iPhoneApex_2.CallAttendee();
				if (callAttendeeRecord.attendee_type_vod__c == 'Contact_vod') {
					cAttendee.CallAttendeeType = iPhoneApex_2.AttendeeType.CONTACT;
					cAttendee.Attendee = callAttendeeRecord.contact_vod__c;
				} else if (callAttendeeRecord.attendee_type_vod__c == 'User_vod') {
					cAttendee.CallAttendeeType = iPhoneApex_2.AttendeeType.USER;
					cAttendee.Attendee = callAttendeeRecord.user_vod__c;
				} else if (callAttendeeRecord.account_vod__c != null) {
					cAttendee.CallAttendeeType = iPhoneApex_2.AttendeeType.PERSONACCOUNT;
					cAttendee.Attendee = callAttendeeRecord.account_vod__c;
					cAttendee.Address =  callAttendeeRecord.Address_vod__c;
				}
				cAttendee.RequestId = callAttendeeRecord.iPhone_Request_id_gne__c;
				callAttributes.callAttendeeList.add (cAttendee);
			}
			for (Call2_Detail_vod__c callDetailRecord : callRecord.call2_detail_vod__r) {
				iPhoneApex_2.CallDetail cDetail = new iPhoneApex_2.CallDetail();
				cDetail.Product = callDetailRecord.Product_vod__c;
				cDetail.DetailPriority = callDetailRecord.Detail_Priority_vod__c.format();
				cDetail.TherapeuticArea = callDetailRecord.Therapeutic_Area_gne__c;
				cDetail.DiseaseIndication = callDetailRecord.Indication_gne__c;
				cDetail.RequestId = callDetailRecord.iPhone_Request_id_gne__c;
				callAttributes.callDetailList.add (cDetail);
			}
			for (Call2_Discussion_vod__c callDiscussionRecord : callRecord.call2_discussion_vod__r) {
				iPhoneApex_2.CallDiscussion cDiscussion = new iPhoneApex_2.CallDiscussion();
				cDiscussion.Product = callDiscussionRecord.Product_vod__c;
				cDiscussion.ProductStrategy = callDiscussionRecord.Product_Strategy_vod__c;
				cDiscussion.ProductTactic = callDiscussionRecord.Product_Tactic_vod__c;
				cDiscussion.PrepMbo = callDiscussionRecord.PREP_MBO_gne__c;
				cDiscussion.Reaction = callDiscussionRecord.Reaction_gne__c;
				cDiscussion.RequestId = callDiscussionRecord.iPhone_Request_id_gne__c;
				cDiscussion.NonProviderGroup = callDiscussionRecord.Non_provider_Group__c;
				cDiscussion.PatientJourney = callDiscussionRecord.Patient_Journey_F2F_or_Virtual__c;
				cDiscussion.InteractionNumber = callDiscussionRecord.Patient_Interaction_F2F_or_Virtual__c;
				callAttributes.callDiscussionList.add (cDiscussion);
			}
		}
		return callAttributes;
	}

	//split comma sepearted string to extract AND update call2_vod__c for FRM users
	public static Call2_vod__c getTopicsAddressedMSL(Call2_vod__c callvod , String value){
		String sTopics = value;
		List<String> topicsList = new List<String>();
		//set all FRM users Boolean fields to false to later update the specific fileds to true in case of an update
		callvod.Access_Solutions_gne__c = false;
		callvod.Case_Review_gne__c = false;
		callvod.Coding_gne__c = false;
		callvod.Co_pay_INO_gne__c = false;
		callvod.Co_pay_BioOnc_Card_gne__c = false;
		callvod.Customer_frustration_gne__c = false;
		callvod.Delayed_Reimbursement_gne__c = false;
		callvod.Diagnostic_report_call_gne__c = false;
		callvod.GATCF_gne__c = false;
		callvod.GES_gne__c = false;
		callvod.Local_Market_Insights_Resource_gne__c = false;
		callvod.Medicare_Update_gne__c = false;
		callvod.Misc_J_Code_gne__c = false;
		callvod.New_indication_gne__c = false;
		callvod.Oncology_National_Accounts_gne__c = false;
		callvod.Price_Objections_gne__c = false;
		callvod.Private_Payer_Denial_gne__c = false;
		callvod.Private_Payer_PA_gne__c = false;
		callvod.Private_Payer_Update_gne__c = false;
		callvod.Public_Payer_Denial_gne__c = false;
		callvod.Public_Payer_PA_gne__c = false;
		callvod.PSL_gne__c = false;
		callvod.SP_Education_gne__c = false;
		callvod.Trends_in_Reimbursement_gne__c = false;
		callvod.Impact_Now_gne__c = false;
		callvod.Oncology_Trend_Report_Resource_gne__c = false;
		callvod.Other_Topics_Addressed_gne__c = false;

		try{
			topicsList = sTopics.split(',');
		}catch(Exception ex){
			//do nothing
		}

		if(topicsList.size()>0){
			for(String tp : topicsList){
				if(!isNull(tp)){
					if(tp.trim().equalsIgnoreCase('Access_Solutions_gne__c')) {
						callvod.Access_Solutions_gne__c = true;
					}else if(tp.trim().equalsIgnoreCase('Case_Review_gne__c')) {
						callvod.Case_Review_gne__c = true;
					}else if(tp.trim().equalsIgnoreCase('Coding_gne__c')) {
						callvod.Coding_gne__c = true;
					}else if(tp.trim().equalsIgnoreCase('Co_pay_INO_gne__c')) {
						callvod.Co_pay_INO_gne__c = true;
					}else if(tp.trim().equalsIgnoreCase('Co_pay_BioOnc_Card_gne__c')) {
						callvod.Co_pay_BioOnc_Card_gne__c = true;
					}else if(tp.trim().equalsIgnoreCase('Customer_frustration_gne__c')) {
						callvod.Customer_frustration_gne__c = true;
					}else if(tp.trim().equalsIgnoreCase('Delayed_Reimbursement_gne__c')) {
						callvod.Delayed_Reimbursement_gne__c = true;
					}else if(tp.trim().equalsIgnoreCase('Diagnostic_report_call_gne__c')) {
						callvod.Diagnostic_report_call_gne__c = true;
					}else if(tp.trim().equalsIgnoreCase('GATCF_gne__c')) {
						callvod.GATCF_gne__c = true;
					}else if(tp.trim().equalsIgnoreCase('GES_gne__c')) {
						callvod.GES_gne__c = true;
					}else if(tp.trim().equalsIgnoreCase('Local_Market_Insights_Resource_gne__c')) {
						callvod.Local_Market_Insights_Resource_gne__c = true;
					}else if(tp.trim().equalsIgnoreCase('Medicare_Update_gne__c')) {
						callvod.Medicare_Update_gne__c = true;
					}else if(tp.trim().equalsIgnoreCase('Misc_J_Code_gne__c')) {
						callvod.Misc_J_Code_gne__c = true;
					}else if(tp.trim().equalsIgnoreCase('New_indication_gne__c')) {
						callvod.New_indication_gne__c = true;
					}else if(tp.trim().equalsIgnoreCase('Oncology_National_Accounts_gne__c')) {
						callvod.Oncology_National_Accounts_gne__c = true;
					}else if(tp.trim().equalsIgnoreCase('Price_Objections_gne__c')) {
						callvod.Price_Objections_gne__c = true;
					}else if(tp.trim().equalsIgnoreCase('Private_Payer_Denial_gne__c')) {
						callvod.Private_Payer_Denial_gne__c = true;
					}else if(tp.trim().equalsIgnoreCase('Private_Payer_PA_gne__c')) {
						callvod.Private_Payer_PA_gne__c = true;
					}else if(tp.trim().equalsIgnoreCase('Private_Payer_Update_gne__c')) {
						callvod.Private_Payer_Update_gne__c = true;
					}else if(tp.trim().equalsIgnoreCase('Public_Payer_Denial_gne__c')) {
						callvod.Public_Payer_Denial_gne__c = true;
					}else if(tp.trim().equalsIgnoreCase('Public_Payer_PA_gne__c')) {
						callvod.Public_Payer_PA_gne__c = true;
					}else if(tp.trim().equalsIgnoreCase('PSL_gne__c')) {
						callvod.PSL_gne__c = true;
					}else if(tp.trim().equalsIgnoreCase('SP_Education_gne__c')) {
						callvod.SP_Education_gne__c = true;
					}else if(tp.trim().equalsIgnoreCase('Trends_in_Reimbursement_gne__c')) {
						callvod.Trends_in_Reimbursement_gne__c = true;
					}else if(tp.trim().equalsIgnoreCase('Impact_Now_gne__c')) {
						callvod.Impact_Now_gne__c = true;
					}else if(tp.trim().equalsIgnoreCase('Oncology_Trend_Report_Resource_gne__c')) {
						callvod.Oncology_Trend_Report_Resource_gne__c = true;
					}else if(tp.trim().equalsIgnoreCase('Other_Topics_Addressed_gne__c')) {
						callvod.Other_Topics_Addressed_gne__c = true;
					}
				}
			}
		}
		return callvod;
	}

	public static String truncateString(String value){
		if(String.isEmpty(value)){
			return null;
		}
		value = value.trim();
		return value.length() > 255 ? value.substring(0, 254) : value;
	}

	public static Call2_vod__c updateFRMInteraction(Call2_vod__c attendeeCall, iPhoneApex_2.callAttributes callAttributes){
		//to support Interactions by FRM users
		//its an FRM user
		if(callAttributes.isFRM != null && callAttributes.isFRM){
			if(callAttributes.SpeakerProgram != null) {
				attendeeCall.Speaker_Program_gne__c = callAttributes.SpeakerProgram;
			}
			if(callAttributes.Resolution != null) {
				attendeeCall.Resolution_gne__c = callAttributes.Resolution;
			}
			if(callAttributes.Reactive != null) {
				attendeeCall.Reactive__c = callAttributes.Reactive;
			}
			if(callAttributes.ResponseTime != null) {
				attendeeCall.FRM_Response_Time_gne__c = callAttributes.ResponseTime;
			}
			if(callAttributes.InteractionMethod != null) {
				attendeeCall.Interaction_Method_gne__c = callAttributes.InteractionMethod;
			}
			if(!isNull(callAttributes.InteractionLocation)) {
				attendeeCall.Interaction_Location_gne__c = callAttributes.InteractionLocation;
			}
			if(callAttributes.AdditionalNotes != null) {

				attendeeCall.Other_Details_Topics_Addressed_gne__c = truncateString(callAttributes.AdditionalNotes);
			}
			if(callAttributes.TopicsAddressed != null){
				attendeeCall = iPhoneApexUtil_2.getTopicsAddressedMSL(attendeeCall, callAttributes.TopicsAddressed);
			}
		}
		return attendeeCall;
	}

	public static Call2_vod__c updateMSLInteraction(Call2_vod__c attendeeCall, iPhoneApex_2.callAttributes callAttributes){
		//to support Interactions by MSL users
		if(callAttributes.isMSL != null && callAttributes.isMSL){
			if(callAttributes.InteractionMethod != null) {
				attendeeCall.Interaction_Method_gne__c = callAttributes.InteractionMethod;
			}
			if(callAttributes.isVisitReason != null) {
				attendeeCall.Visit_Reason_gne__c = callAttributes.isVisitReason; //dependant picklist in SFDC. dependant on Primary_Interaction_Reason_gne__c
			}
			if(callAttributes.visitReasonDescription != null) {
				attendeeCall.Visit_Reason_Description_gne__c = callAttributes.visitReasonDescription; //dependant picklist in SFDC. dependant on Visit_Reason_gne__c
			}
			if(callAttributes.GroupMeetingTopic != null) {
				attendeeCall.Group_Meeting_Topic_gne__c = truncateString(callAttributes.GroupMeetingTopic);
			}
			if(callAttributes.PrimaryInteractionReason != null) {
				attendeeCall.Primary_Interaction_Reason_gne__c = callAttributes.PrimaryInteractionReason;
			}
			if(!isNull(callAttributes.InteractionLocation)) {
				attendeeCall.Interaction_Location_gne__c = callAttributes.InteractionLocation;
			}
		}
		return attendeeCall;
	}

	public static iPhoneApex_2.CallAttributes updateOrCreateCallForValEngine (iPhoneApex_2.CallAttributes callAttributes){
		String CallOwnerId;
		if(callAttributes.OwnerId != null){
			CallOwnerId = callAttributes.OwnerId;
		}else{
			CallOwnerId=UserInfo.getUserId();
		}
		String requestId = DateTime.Now().format ('yyyyMMddHHmmssS');
		String userAlias = [SELECT alias FROM user WHERE Id = :CallOwnerId].alias;

		if (callAttributes == null){
			return null;
		}

		if (callAttributes.RequestId == null){
			callAttributes.RequestId = REQUESTID_VALENG_PREFIX_FOR_MAIN_CALL + userAlias + requestId + '0';
		}
		if (callAttributes.callAttendeeList != null) {
			for (Integer i = 0; i < callAttributes.CallAttendeeList.size(); i++) {
				if (callAttributes.CallAttendeeList[i].RequestId == null){
					callAttributes.CallAttendeeList[i].RequestId = REQUESTID_VALENG_PREFIX_FOR_ATTENDEE + userAlias + requestId + (i+1);
				}
			}
		}
		if (callAttributes.callDetailList != null) {
			for (Integer i = 0; i < callAttributes.callDetailList.size(); i++) {
				if (callAttributes.callDetailList[i].RequestId == null){
					callAttributes.callDetailList[i].RequestId = REQUESTID_VALENG_PREFIX_FOR_DETAIL + userAlias + requestId + i;
				}
			}
		}
		if (callAttributes.callDiscussionList != null) {
			for (Integer i = 0; i < callAttributes.callDiscussionList.size(); i++) {
				if (callAttributes.callDiscussionList[i].RequestId == null){
					callAttributes.callDiscussionList[i].RequestId = REQUESTID_VALENG_PREFIX_FOR_DISCUSSION + userAlias + requestId + i;
				}
			}
		}
		if (callAttributes.callSampleList != null) {
			for (Integer i = 0; i < callAttributes.callSampleList.size(); i++) {
				if (callAttributes.callSampleList[i].RequestId == null){
					callAttributes.callSampleList[i].RequestId = REQUESTID_VALENG_PREFIX_FOR_SAMPLE + userAlias + requestId + i;
				}
			}
		}

		if (callAttributes.callPfgDetailList != null) {
			for (Integer i = 0; i < callAttributes.callPfgDetailList.size(); i++) {
				if (callAttributes.callPfgDetailList[i].RequestId == null){
					callAttributes.callPfgDetailList[i].RequestId = REQUESTID_VALENG_PREFIX_FOR_PFG + userAlias + requestId + i;
				}
			}
		}
		return callAttributes;
	}

	//get product list in detal AND discussion(only MSL)
	public static Set<Id> getDetailproductIdList(iPhoneApex_2.CallAttributes callAttributes){
		// detailed product initializer
		Set<Id> productIdList = new Set<Id> ();
		if (callAttributes.callDetailList != null) {
			for (iPhoneApex_2.CallDetail callDetail : callAttributes.callDetailList) {
				if(!isNull(callDetail.Product) && !productIdList.contains(callDetail.Product)) {
					productIdList.add(callDetail.Product);
				}
			}
			//callRecord.detailed_products_vod__c = iPhoneApex_2.getDetailedProductString(productIdList);
		}
		if(callAttributes.isMSL != null && callAttributes.isMSL) {
			if (callAttributes.callDiscussionList != null) {
				for (iPhoneApex_2.CallDiscussion callDisc : callAttributes.callDiscussionList) {
					if(!isNull(callDisc.Product) && !productIdList.contains(callDisc.Product)) {
						productIdList.add(callDisc.Product);
					}
				}
			}
		}
		return productIdList;
	}

	//get molecule list FROM calldiscussion for MSL interaction
	public static Set<Id> getMoleculeproductIdList(iPhoneApex_2.CallAttributes callAttributes){
		Set<Id> productIdList = new Set<Id> ();
		if(callAttributes.isMSL != null && callAttributes.isMSL) {
			if (callAttributes.callDiscussionList != null) {
				for (iPhoneApex_2.CallDiscussion callDisc : callAttributes.callDiscussionList) {
					if (String.isNotBlank(callDisc.Molecule) && callDisc.Molecule.equalsIgnoreCase('N/A') == false){
						for (Id moleculeId : callDisc.Molecule.split(';')){
							productIdList.add(moleculeId);
						}
					}
				}
			}
		}
		return productIdList;
	}

	public static Map<Id, Product_vod__c> getDetailedProducts (Set<Id> productIdList, iPhoneApex_2.CallAttributes callAttributes) {
		Map<Id, Product_vod__c> mapProducts;
		Boolean isFoundNA = false;
		if(callAttributes.isMSL != null && callAttributes.isMSL) {
			if (callAttributes.callDiscussionList != null) {
				for (iPhoneApex_2.CallDiscussion callDisc : callAttributes.callDiscussionList) {
					if(String.isNotBlank(callDisc.Molecule) && callDisc.Molecule.equalsIgnoreCase('N/A')){
						isFoundNA=true;
						break;
					}
				}
			}
		}
		if(productIdList.size()>0 && isFoundNA){
			mapProducts= new Map<Id, Product_vod__c>([SELECT Id, name FROM product_vod__c WHERE name =:NonProduct_NonMolecule OR Id in :productIdList]);
		}else if(productIdList.size() <=0 && isFoundNA){
			mapProducts= new Map<Id, Product_vod__c>([SELECT Id, name FROM product_vod__c WHERE name =:NonProduct_NonMolecule]);
		}else if(productIdList.size() > 0){
			mapProducts= new Map<Id, Product_vod__c>([SELECT Id, name FROM product_vod__c WHERE Id in :productIdList]);
		}
		return mapProducts;
	}

	//returns product names.
	//accepts product list AND exempt id list(molecule list)
	public static String getDetailedProductString (Map<Id, Product_vod__c> mapProducts, Set<Id> moleculeIdList) {
		String detailedProductString = null;
		if(mapProducts != null && mapProducts.size()>0){
			for (Id productItem : mapProducts.keySet()){
				if(!moleculeIdList.contains(productItem)){
					if (detailedProductString != null){
						detailedProductString = detailedProductString + ' ' + mapProducts.get(productItem).Name;
					}else{
						detailedProductString = mapProducts.get(productItem).Name;
					}
				}
			}
		}
		return detailedProductString;
	}

	public static Boolean isNull(String value){
		return String.isEmpty(value);
	}

	public static String processProductTactic(String productTacticIdOld, iPhoneApex_2.CallAttributes callAttributes){
		//check if Product Tactic exist
		List<Product_Tactic_vod__c> existingProductTactics = [SELECT Id FROM Product_Tactic_vod__c WHERE id = :productTacticIdOld];
		if(existingProductTactics.size()>0){
			return productTacticIdOld;
		}
		//search for Product Tactic in deleted
		List<Product_Tactic_vod__c> deletedProductTactics = [SELECT Id, isDeleted, Name FROM Product_Tactic_vod__c WHERE isDeleted =:true AND id = :productTacticIdOld ALL ROWS];
		if(deletedProductTactics.size()>0){
			//find in existing Product Tactics
			String productTacticName = deletedProductTactics.get(0).Name;
			List<String> productIds = collectProducts(callAttributes);
			List<Product_Tactic_vod__c> productTactics = [SELECT p.Id,p.Name FROM Product_Tactic_vod__c p WHERE p.Name = :productTacticName AND p.Product_Strategy_vod__r.Product_Plan_vod__r.Product_vod__c in :productIds];
			if(productTactics.size() > 0){
				return productTactics.get(0).Id;
			}
		}
		return null;
	}

	private static List<String> collectProducts(iPhoneApex_2.CallAttributes callAttributes){
		List<String> productIds = new List<String>();
		for(iPhoneApex_2.CallDiscussion callDiscussion : callAttributes.callDiscussionList){
			if(callDiscussion.Product != null && callDiscussion.Product.length() > 0){
				productIds.add(callDiscussion.Product);
			}
		}
		return productIds;
	}

	public static List<Call2_vod__c> getListOfAttendeesToCreateOrUpdate(Call2_vod__c cRec, iPhoneApex_2.CallAttributes callAttributes, String callOwnerId, String terrName, String terrId, Map<String, String> mapMergedAccountIds, List<String> inputRequestIdList, String lastDevice){
		List<iPhoneApex_2.CallAttendee> callAttendeeList = callAttributes.CallAttendeeList;
		List<Call2_vod__c> callAttendeeListToUpsert = new List<Call2_vod__c>();
		Map<Id,Call2_vod__c> callAttendeesToDelete = new Map<Id,Call2_vod__c>();
		Map<String, Call2_vod__c> callAttendeeToUpdate = new Map<String, Call2_vod__c>();
		//Cache existing records - at the beginning all existing records are candidates to delete
		for(Call2_vod__c existingCallAttendee : cRec.Call2_vod__r){
			cacheExistingCallChildRecord(existingCallAttendee.Id, existingCallAttendee.iPhone_Request_Id_gne__c, existingCallAttendee);
			if(existingCallAttendee.EMS_International_Speaker_gne__c == null) {	// skip iHCPs
				callAttendeesToDelete.put(existingCallAttendee.Id, existingCallAttendee);
			}
		}
		if(callAttendeeList != null){
			for(iPhoneApex_2.CallAttendee attendee : callAttendeeList) {
				Call2_vod__c attendeeCall = (Call2_vod__c)getExistingCallChildRecord(attendee.Id, attendee.RequestId);
				if(attendeeCall != null){
					callAttendeesToDelete.remove(attendeeCall.Id);
				}else{
					attendeeCall = new Call2_vod__c();
					attendeeCall.parent_call_vod__c = cRec.id;
				}

				//---------------meal opt out ------------
				attendeeCall.HCP_Attendee_Meal_Opt_Out_gne__c = attendee.MealOptOut;
				attendeeCall.call_datetime_vod__c = callAttributes.CallDateTime;
				attendeeCall.iphone_request_id_gne__c = attendee.RequestId;
				attendeeCall.OwnerId = callOwnerId;

				attendeeCall.completed_Gne__c = callAttributes.IsComplete;
				if(attendeeCall.completed_Gne__c == true){
					attendeeCall.Interaction_Status_gne__c='Completed';
					if (attendeeCall.Date_Completed_gne__c == null) {
						attendeeCall.Date_Completed_gne__c = date.today();
					}
				}
				attendeeCall.call_type_vod__c = cRec.call_type_vod__c;
				attendeeCall.Status_vod__c = cRec.Status_vod__c;
				//---------------meal opt out ------------
				attendeeCall.HCP_OR_Attendee_Meal_Opt_Out_gne__c = cRec.HCP_OR_Attendee_Meal_Opt_Out_gne__c;

				if (attendee.CallAttendeeType == iPhoneApex_2.AttendeeType.ACCOUNT || attendee.CallAttendeeType == iPhoneApex_2.AttendeeType.PERSONACCOUNT) {
					attendeeCall.attendee_type_vod__c = 'Person_Account_vod';
					attendeeCall.account_Vod__c = iPhoneApex_2.getWinnerAccountId(mapMergedAccountIds, attendee.Attendee);
				} else if (attendee.CallAttendeeType == iPhoneApex_2.AttendeeType.CONTACT) {
					attendeeCall.contact_vod__c = attendee.Attendee;
                    attendeeCall.attendee_type_vod__c = 'Contact_vod';
                    if(attendee.CallContactType  != null) {
                        attendeeCall.attendee_type_vod__c = attendee.CallContactType == iPhoneApex_2.ContactType.CONTACT ? 'Contact_vod' : 'Person_Account_vod';  
                    }					                   
				} else if (attendee.CallAttendeeType == iPhoneApex_2.AttendeeType.USER) {
					attendeeCall.user_vod__c = attendee.Attendee;
					attendeeCall.attendee_type_vod__c = 'User_vod';
				}
                

				attendeeCall.Parent_address_vod__c = cRec.Parent_address_vod__c;
				attendeeCall.address_vod__c = cRec.address_vod__c;
				//assign the address fields to call object address fields
				attendeeCall.Address_Line_1_vod__c = cRec.Address_Line_1_vod__c;
				attendeeCall.Address_Line_2_vod__c = cRec.Address_Line_2_vod__c;
				attendeeCall.City_vod__c = cRec.City_vod__c;
				attendeeCall.State_vod__c = cRec.State_vod__c;
				attendeeCall.Zip_vod__c = cRec.Zip_vod__c;
				attendeeCall.Unsolicited_Request_gne__c = cRec.Unsolicited_Request_gne__c;
				attendeeCall.Sales_Collateral_gne__c = cRec.Sales_Collateral_gne__c;
				attendeeCall.Visit_Reason_RCanada_MSL_gne__c = cRec.Visit_Reason_RCanada_MSL_gne__c;
				attendeeCall.Visit_Reason_Canada_SAM_gne__c = cRec.Visit_Reason_Canada_SAM_gne__c;
				attendeeCall.Patient_Education_Materials_gne__c = cRec.Patient_Education_Materials_gne__c;
				attendeeCall.Protection_Strategy_gne__c = cRec.Protection_Strategy_gne__c;
				attendeeCall.Group_RAMA_gne__c = cRec.Group_RAMA_gne__c;
				attendeeCall.Access_Echo_Alignment_RAMA_gne__c = cRec.Access_Echo_Alignment_RAMA_gne__c;
				attendeeCall.Objectives_RAMA_gne__c = cRec.Objectives_RAMA_gne__c;
				attendeeCall.Key_Messages_RAMA_gne__c = cRec.Key_Messages_RAMA_gne__c;
				attendeeCall.Outcomes_RAMA_gne__c = cRec.Outcomes_RAMA_gne__c;
				attendeeCall.Next_Steps_RAMA_gne__c = cRec.Next_Steps_RAMA_gne__c;

				//Veeva populates this field on child interactions everytime a call has a call2_Detail
				attendeeCall.detailed_products_vod__c = cRec.detailed_products_vod__c;

				if (callAttributes.BusinessSponsor != null) {
					attendeeCall.Business_sponsor_gne__c = callAttributes.BusinessSponsor;
				}
				if (callAttributes.MealLocationCity != null) {
					attendeeCall.city_gne__c = callAttributes.MealLocationCity;
				}
				if (callAttributes.MealLocationState != null) {
					attendeeCall.state_gne__c = callAttributes.MealLocationState;
				}
				if (callAttributes.MealAmount != null) {
					attendeeCall.meal_amount_gne__c = callAttributes.MealAmount;
				}
				if((callAttributes.MealPlannedAttendeeCount != null && callAttributes.MealPlannedAttendeeCount > 0) &&
							(callAttributes.MealActualAttendeeCount != null && callAttributes.MealActualAttendeeCount > 0)) {
					attendeeCall.meal_expense_gne__c = true;
					attendeeCall.planned_attendees_gne__c = callAttributes.MealPlannedAttendeeCount;
					attendeeCall.actual_attendees_gne__c = callAttributes.MealActualAttendeecount;
				} else {
					attendeeCall.meal_expense_gne__c = false;
					attendeeCall.meal_amount_gne__c = 0;
					attendeeCall.planned_attendees_gne__c = 0;
					attendeeCall.actual_attendees_gne__c = 0;
				}

				if(!isNull(callAttributes.InteractionLocation)){
					attendeeCall.Interaction_Location_gne__c = callAttributes.InteractionLocation;
				}

				//to support Interactions by FRM and MSL users its an FRM user
				if(callAttributes.isFRM !=null && callAttributes.isFRM){
					//Interaction type is populated here for FRM users only because updating Reactive for attendees require appropriate iteraction type
					if(callAttributes.InteractionType != null){
						attendeeCall.Interaction_Type_gne__c = callAttributes.InteractionType;
					}
					attendeeCall = updateFRMInteraction(attendeeCall, callAttributes);
				}
				if(!isNull(callAttributes.AccountPlan)){
					attendeeCall.Account_Plan_vod__c = callAttributes.AccountPlan ;
				}
				if(callAttributes.isMSL != null && callAttributes.isMSL){
					attendeeCall = updateMSLInteraction(attendeeCall, callAttributes);
				}
				if(terrName != null){
					attendeeCall.Territory_vod__c = terrName;
				}

				if(terrId != null){
					attendeeCall.Territory_Id_gne__c = terrId;
				}

				attendeeCall.Last_Device_vod__c = lastDevice;

				//added later(3/16/2010) to address issue of duplicate interactions being created from iphone
				//Sales Reps select the same HCP as attendee also to recod interaction
				//so we are eliminating the attendee if the attendee and the main HCP are same
				//for HCO based call this will always be true
				if(attendee.Attendee!=null && callAttributes.Account!=attendee.Attendee){
					callAttendeeListToUpsert.add(attendeeCall);
					inputRequestIdList.add(attendee.RequestId);
				}
			}
		}
		if(!callAttendeesToDelete.isEmpty()) {
			if (callSampleCache != null){
				for(Id attendeeId : callAttendeesToDelete.keySet()){
					callSampleCache.remove(attendeeId);
				}
			}
			//ignoreValidationTrigger = true;
			GNE_SFA2_Interaction_Trigger_Helper.setIsAllowDeleteAttendeeMode(callAttributes.isFRM == null || callAttributes.isFRM == false);
			delete callAttendeesToDelete.values();
			//ignoreValidationTrigger = false;
		}

		return callAttendeeListToUpsert;
	}

	public static List<Call2_Detail_vod__c> getListOfCallDetailToCreateOrUpdate(Call2_vod__c cRec, iPhoneApex_2.CallAttributes callAttributes, List<String> inputRequestIdList){
		List<iPhoneApex_2.CallDetail> callDetailList = callAttributes.callDetailList;
		List<Call2_Detail_vod__c> callDetailListToUpsert = new List<Call2_Detail_vod__c>();
		Map<Id,Call2_Detail_vod__c> callDetailsToDelete = new Map<Id,Call2_Detail_vod__c>();
		//Cache existing records - at the beginning all existing records are candidates to delete
		for(Call2_Detail_vod__c existingCallDetail : cRec.call2_detail_vod__r){
			cacheExistingCallChildRecord(existingCallDetail.Id, existingCallDetail.iPhone_Request_Id_gne__c, existingCallDetail);
			callDetailsToDelete.put(existingCallDetail.Id, existingCallDetail);
		}

		if(callDetailList != null){
			for(iPhoneApex_2.CallDetail callDetail : callDetailList) {
				Call2_Detail_vod__c cdetail = (Call2_Detail_vod__c)getExistingCallChildRecord(callDetail.Id, callDetail.RequestId);
				if(cdetail!=null){
					callDetailsToDelete.remove(cdetail.Id);
					// OTR-4171
					/*if(callDetail.Product == cdetail.Product_vod__c && callDetail.RequestId == cDetail.iphone_request_id_gne__c
						&& Double.valueOf(callDetail.DetailPriority) == cdetail.Detail_Priority_vod__c && callDetail.TherapeuticArea == cDetail.Therapeutic_Area_gne__c
						&& callDetail.DiseaseIndication == cDetail.Indication_gne__c){
						continue;
					}*/
				}else{
					cdetail = new Call2_Detail_vod__c();
					cdetail.call2_vod__c = cRec.Id;
				}

				cdetail.Product_vod__c = callDetail.Product;
				cdetail.iphone_request_id_gne__c = callDetail.RequestId;
				if(callDetail.DetailPriority != null){
					cdetail.Detail_Priority_vod__c = Double.valueOf(callDetail.DetailPriority);
				}
				if (callDetail.TherapeuticArea != null){
					cDetail.Therapeutic_Area_gne__c = callDetail.TherapeuticArea;
				}
				if (callDetail.DiseaseIndication != null){
					cDetail.Indication_gne__c = callDetail.DiseaseIndication;
				}
				callDetailListToUpsert.add(cdetail);
				inputRequestIdList.add(callDetail.RequestId);
			}
		}

		if(!callDetailsToDelete.isEmpty()) {
			delete callDetailsToDelete.values();
		}

		return callDetailListToUpsert;
	}
    
    public static List<Call2_Threat_vod__c> getListOfCallThreatToCreateOrUpdate(Call2_vod__c cRec, iPhoneApex_2.CallAttributes callAttributes,  List<String> inputRequestIdList) {
        List<iPhoneApex_2.CallThreat> callThreatList = callAttributes.callThreatList;
        List<Call2_Threat_vod__c> callThreatListToUpsert = new List<Call2_Threat_vod__c>();
        Map<Id, Call2_Threat_vod__c> callThreatsToDelete = new Map<Id, Call2_Threat_vod__c>();
        
		//Cache existing records - at the beginning all existing records are candidates to delete        
        for(Call2_Threat_vod__c existingCallThreat: cRec.Call2_Threat_vod__r){
            cacheExistingCallChildRecord(existingCallThreat.Id, existingCallThreat.iPhone_Request_Id_gne__c, existingCallThreat);
            callThreatsToDelete.put(existingCallThreat.Id, existingCallThreat);
        }
        
        if(callThreatList != null) {
            for(iPhoneApex_2.CallThreat callTreat :callThreatList) {
                Call2_Threat_vod__c cThreat = callTreat.Id != null ? (Call2_Threat_vod__c)getExistingCallChildRecord(callTreat.Id, callTreat.RequestId) : null; 
                
                if(cThreat == null) {
                    cThreat = new Call2_Threat_vod__c(Call2_vod__c = cRec.Id);
                } else {
                    callThreatsToDelete.remove(callTreat.Id);
                }
				cThreat.iphone_request_id_gne__c = callTreat.RequestId;
                if(callTreat.product != null) {
                    cThreat.Product_vod__c = String.isBlank(callTreat.product) ? null : callTreat.product;
                }
                if(callTreat.bookOfBusiness != null) {
                    cThreat.Book_of_Business__c = callTreat.bookOfBusiness;
                }
                if(callTreat.requestedPosition != null) {
                    cThreat.Requested_Position__c = callTreat.requestedPosition;
                }
                if(callTreat.rebate != null) {
                    cThreat.Rebate__c = callTreat.rebate;
                }
                if(callTreat.requestedStartDate != null) {
                    cThreat.Requested_Start_Date__c = Date.newInstance( callTreat.requestedStartDate.year(), callTreat.requestedStartDate.month(), callTreat.requestedStartDate.day());
                }
                if(callTreat.riskLevel != null) {
                    cThreat.Risk_Level__c = callTreat.riskLevel;
                }
                if(callTreat.initialAssessment != null) {
                    cThreat.Initial_Assessment__c = callTreat.initialAssessment;
                }  
                callThreatListToUpsert.add(cThreat);
                inputRequestIdList.add(callTreat.RequestId);
            }            
        }        
        
        if(!callThreatsToDelete.isEmpty()) {
			delete callThreatsToDelete.values();
		}
        
        return callThreatListToUpsert;
    }

	public static List<Call2_Discussion_vod__c> getListOfCallDiscussionToCreateOrUpdate(Call2_vod__c cRec, iPhoneApex_2.CallAttributes callAttributes, Map<String, String> mapMergedAccountIds, Map<Id, Product_vod__c> mapProducts, List<String> inputRequestIdList){
		List<iPhoneApex_2.CallDiscussion> callDiscussionList = callAttributes.callDiscussionList;
		List<Call2_Discussion_vod__c> callDiscussionListToUpsert = new List<Call2_Discussion_vod__c>();
		Id accountId = iPhoneApex_2.getWinnerAccountId(mapMergedAccountIds, callAttributes.Account);

		Map<Id,Call2_Discussion_vod__c> callDiscussionsToDelete = new Map<Id,Call2_Discussion_vod__c>();
		//Cache existing records - at the beginning all existing records are candidates to delete
		for(Call2_Discussion_vod__c existingCallDiscussion : cRec.call2_discussion_vod__r){
			cacheExistingCallChildRecord(existingCallDiscussion.Id, existingCallDiscussion.iPhone_Request_Id_gne__c, existingCallDiscussion);
			callDiscussionsToDelete.put(existingCallDiscussion.Id, existingCallDiscussion);
		}

		if(callDiscussionList != null){
			for(iPhoneApex_2.CallDiscussion callDiscussion : callDiscussionList) {
				Call2_Discussion_vod__c cDiscussion = (Call2_Discussion_vod__c)getExistingCallChildRecord(callDiscussion.Id, callDiscussion.RequestId);
				String productTactic = String.isBlank(callDiscussion.ProductTactic) ? null : processProductTactic(callDiscussion.ProductTactic,callAttributes);

				if(cDiscussion!=null){
					callDiscussionsToDelete.remove(cDiscussion.Id);
				}else{
					cDiscussion = new Call2_Discussion_vod__c();
					cDiscussion.call2_vod__c = cRec.Id;
				}

				if(!isNull(callDiscussion.Product)){
					cDiscussion.Product_vod__c = String.isBlank(callDiscussion.Product) ? null : callDiscussion.Product;
				}

				if(callDiscussion.DetailPriority != null){
					cDiscussion.Detail_Priority_gne__c = String.isBlank(callDiscussion.DetailPriority) ? null : Double.valueOf(callDiscussion.DetailPriority);
				}

				cDiscussion.Account_vod__c = accountId;

				if (callDiscussion.ProductStrategy != null) {
					if (String.isBlank(callDiscussion.ProductStrategy)){
						cDiscussion.Product_Strategy_vod__c = null;
						cDiscussion.Product_Tactic_vod__c = null;
					} else {
					cDiscussion.Product_Strategy_vod__c = callDiscussion.ProductStrategy;
				}
				}

				if (callDiscussion.ProductTactic != null) {
					cDiscussion.Product_Tactic_vod__c = String.isBlank(callDiscussion.ProductTactic) ? null : productTactic;
				}

				if (String.isNotBlank(callDiscussion.PrepMbo) || String.isNotBlank(cDiscussion.PREP_MBO_gne__c)) {
					cDiscussion.PREP_MBO_gne__c = callDiscussion.PrepMbo;
				}

				if (callDiscussion.AccountTactic != null) {
					cDiscussion.Account_Tactic_vod__c = String.isBlank(callDiscussion.AccountTactic) ? null : callDiscussion.AccountTactic;
				}

				if (callDiscussion.Reaction != null) {
					cDiscussion.Reaction_gne__c = String.isBlank(callDiscussion.Reaction) ? null : callDiscussion.Reaction;
				}

				if (callDiscussion.Reason != null) {
					cDiscussion.Reason_gne__c = String.isBlank(callDiscussion.Reason) ? null : callDiscussion.Reason;
				}

				if (callDiscussion.NbrPatientsImpacted != null) {
					cDiscussion.Number_of_Patients_Impacted_gne__c = callDiscussion.NbrPatientsImpacted;
				}
				//new OTR functionality added by Dominik Wasilewski 5-11-2011
				if(callDiscussion.Curriculum != null){
					cDiscussion.Event_Curriculum_gne__c = String.isBlank(callDiscussion.Curriculum) ? null : callDiscussion.Curriculum;

				}
				if(callDiscussion.Activity != null){
					cDiscussion.Activity_gne__c = String.isBlank(callDiscussion.Activity) ? null : callDiscussion.Activity;
				}
				if(callDiscussion.EventRelated != null){
					cDiscussion.Event_gne__c = callDiscussion.EventRelated;
				}
		        if(callDiscussion.SpeakerTraining != null){
		          	cDiscussion.Speaker_Training_gne__c = callDiscussion.SpeakerTraining;
		          	if (GNE_SFA2_Util.isPREPUser() && callDiscussion.SpeakerTraining) {
		          		cDiscussion.Activity_gne__c = '1:1 Training/Deck Update';
                    } else if (GNE_SFA2_Util.isPREPUser() && !callDiscussion.SpeakerTraining) {
                        cDiscussion.Event_Curriculum_gne__c = null;
                        cDiscussion.Activity_gne__c = null;                       
		          	}
		        }

				if(callDiscussion.ActivityTimeSpent !=null){
					cDiscussion.Activity_Time_Spent_gne__c = String.isBlank(callDiscussion.ActivityTimeSpent) ? null : callDiscussion.ActivityTimeSpent;
				}

				if(callDiscussion.Observation !=null){
					cDiscussion.Observation_gne__c = String.isBlank(callDiscussion.Observation) ? null : callDiscussion.Observation;
				}

				if(callDiscussion.DecisionCycle !=null){
					cDiscussion.Decision_Cycle_gne__c = String.isBlank(callDiscussion.DecisionCycle) ? null : callDiscussion.DecisionCycle;
				}

				cDiscussion.FRM_Issue_entered_into_ASMI_gne__c = callDiscussion.IssueEnteredIntoASMI==true;

				if(String.isNotBlank(callDiscussion.TriagedTo) || String.isNotBlank(cDiscussion.FRM_Triaged_To_gne__c)) {
					cDiscussion.FRM_Triaged_To_gne__c = callDiscussion.TriagedTo;
				}

				if(callDiscussion.PatientsImpacted!=null || cDiscussion.FRM_Patients_Impacted_gne__c!=null) {
					cDiscussion.FRM_Patients_Impacted_gne__c = callDiscussion.PatientsImpacted;
				}

				if(String.isNotBlank(callDiscussion.DeckUsed) || String.isNotBlank(cDiscussion.FRM_Deck_Used_gne__c)) {
					cDiscussion.FRM_Deck_Used_gne__c = callDiscussion.DeckUsed;
				}

				if (callDiscussion.AttendeeGroup != null){
					cDiscussion.Attendee_Group_gne__c = callDiscussion.AttendeeGroup;
				}
				if (callDiscussion.NumOfAttendees != null){
					cDiscussion.Number_of_Attendees_gne__c = String.isBlank(callDiscussion.NumOfAttendees) ? null : Integer.valueOf(callDiscussion.NumOfAttendees);
				}

				if(String.isNotBlank(callDiscussion.Status)) {
                    cDiscussion.FRM_Issue_Status__c = callDiscussion.Status;
                }

                if(String.isNotBlank(callDiscussion.NonProviderGroup)) {
                    cDiscussion.Non_provider_Group__c = callDiscussion.NonProviderGroup;
                }                

                if(String.isNotBlank(callDiscussion.PatientJourney)) {
                    cDiscussion.Patient_Journey_F2F_or_Virtual__c = callDiscussion.PatientJourney;
                }

                if(String.isNotBlank(callDiscussion.InteractionNumber)) {
                    cDiscussion.Patient_Interaction_F2F_or_Virtual__c = callDiscussion.InteractionNumber;
                }
                if(String.isNotBlank(callDiscussion.CRMMeetingObjective)) {
                    cDiscussion.CRM_Meeting_Objective__c = callDiscussion.CRMMeetingObjective;
                }
                if(callDiscussion.ObjectivesMet != null) {
                    cDiscussion.CRM_Objectives_Met__c = callDiscussion.ObjectivesMet;
                }
                if(String.isNotBlank(callDiscussion.CRMTactic)) {
                    cDiscussion.CRM_Tactic__c = callDiscussion.CRMTactic;
                }
                if(String.isNotBlank(callDiscussion.CRMWhen)) {
                    cDiscussion.CRM_When__c = callDiscussion.CRMWhen;
                }
                if(String.isNotBlank(callDiscussion.Impact)) {
                    cDiscussion.CRM_Impact__c = callDiscussion.Impact;
                }
                if(String.isNotBlank(callDiscussion.Utility)) {
                    cDiscussion.CRM_Marketing_Material__c = callDiscussion.CRMMarketingMaterial;
                }    
                if(String.isNotBlank(callDiscussion.CRMMarketingMaterial)) {
                    cDiscussion.CRM_Value__c = callDiscussion.Utility;
                }  

				//to support Interactions by MSL users
				if(callAttributes.isMSL != null && callAttributes.isMSL){
					if(callDiscussion.Answer != null) {
						cDiscussion.Answer_gne__c = String.isBlank(callDiscussion.Answer) ? null : truncateString(callDiscussion.Answer);
					}
					if(callDiscussion.Question != null) {
						cDiscussion.Question_gne__c = String.isBlank(callDiscussion.Question) ? null : truncateString(callDiscussion.Question);
					}
					if(callDiscussion.Topic != null) {
						cDiscussion.Topic_gne__c = String.isBlank(callDiscussion.Topic) ? null : callDiscussion.Topic;
					}
					if(callDiscussion.CurrentIssue != null) {
						cDiscussion.Current_Issue_gne__c = String.isBlank(callDiscussion.CurrentIssue) ? null : callDiscussion.CurrentIssue; //dependant picklist is SFDC. dependant on Product(zvod_Product_Map_vod__c)
					}

					if(String.isNotBlank(callDiscussion.Molecule)){
						if(callDiscussion.Molecule.equalsIgnoreCase('N/A')){
							cDiscussion.Molecule_gne__c = 'N/A';
							//insert Non-Product/Non-Molecule to product if molecule is N/A
							if(isNull(callDiscussion.Product)) {
								if(mapProducts != null) {
									for(Product_vod__c pr : mapProducts.values()) {
										if(pr.Name == NonProduct_NonMolecule) {
											cDiscussion.Product_vod__c = pr.Id;
											break;
										}
									}
								}
							}
						}else{
							if (mapProducts != null){
								List<String> selectedMolecules = new List<String>();
								for (Id moleculeId : callDiscussion.Molecule.split(';')){
									if (mapProducts.containsKey(moleculeId)){
										selectedMolecules.add(mapProducts.get(moleculeId).Name);
									}
								}
								if (selectedMolecules.size() > 0){
									cDiscussion.Molecule_gne__c = String.join(selectedMolecules, ';'); //dependant picklist is SFDC. dependant on Product(zvod_Product_Map_vod__c)
								}
							}
						}
					}
				}
				if(GNE_SFA2_Util.isFrmUser() && String.isNotBlank(callDiscussion.Status)){
                    callDiscussisonAssignValues(cDiscussion);
                }

				cDiscussion.iphone_request_id_gne__c = callDiscussion.RequestId;
				callDiscussionListToUpsert.add(cDiscussion);
				inputRequestIdList.add(callDiscussion.RequestId);
			}
		}

		if(!callDiscussionsToDelete.isEmpty()) {
			delete callDiscussionsToDelete.values();
		}

		return callDiscussionListToUpsert;
	}

	private static void callDiscussisonAssignValues(Call2_Discussion_vod__c cd) {
        if(GNE_SFA2_Interaction_Ctrl.status2fields.get(cd.FRM_Issue_Status__c) == null){
            return;
        }

        callDiscussisonClearValues(cd);

        for(String field: GNE_SFA2_Interaction_Ctrl.status2fields.get(cd.FRM_Issue_Status__c)){
            cd.put(field, true);
        }
    }

    private static void callDiscussisonClearValues(Call2_Discussion_vod__c cd) {
        for(String field: GNE_SFA2_Interaction_Ctrl.status2fields.get('FieldsToClear')){
            cd.put(field, false);
        }
    }

    public static List<Call2_Interaction_Detail_vod__c> getListOfCallInteractionDetailToCreateOrUpdate(Call2_vod__c cRec, iPhoneApex_2.CallAttributes callAttributes, Map<String, String> mapMergedAccountIds, Map<Id, Product_vod__c> mapProducts, List<String> inputRequestIdList){
		List<iPhoneApex_2.CallVisitReason> callVisitReasonList = callAttributes.callVisitReasonList;
		List<Call2_Interaction_Detail_vod__c> callInteractionDetailListToUpsert = new List<Call2_Interaction_Detail_vod__c>();

		Map<Id,Call2_Interaction_Detail_vod__c> callInteractionDetailToDelete = new Map<Id,Call2_Interaction_Detail_vod__c>();
		//Cache existing records - at the beginning all existing records are candidates to delete
		for(Call2_Interaction_Detail_vod__c existingRec : cRec.Call2_Interaction_Detail_vod__r){
			cacheExistingCallChildRecord(existingRec.Id, existingRec.iPhone_Request_Id_gne__c, existingRec);
			callInteractionDetailToDelete.put(existingRec.Id, existingRec);
		}

		if(callVisitReasonList != null){
			for(iPhoneApex_2.CallVisitReason callVisitReason : callVisitReasonList) {
				//Call2_Interaction_Detail_vod__c cDiscussion = (Call2_Interaction_Detail_vod__c)getExistingCallChildRecord(callDiscussion.Id, callDiscussion.RequestId);
				Call2_Interaction_Detail_vod__c cInteractionDetail = (Call2_Interaction_Detail_vod__c)getExistingCallChildRecord(callVisitReason.Id, callVisitReason.RequestId);

				if(cInteractionDetail!=null){
					callInteractionDetailToDelete.remove(cInteractionDetail.Id);
				}else{
					cInteractionDetail = new Call2_Interaction_Detail_vod__c();
					cInteractionDetail.call2_vod__c = cRec.Id;
				}

				if(callVisitReason.visitReason != null && callVisitReason.visitReason.length() > 0 ){
					cInteractionDetail.Visit_Reason_vod__c = callVisitReason.visitReason;
				}
				if(callVisitReason.conferenceName != null && callVisitReason.conferenceName.length() > 0 ){
					cInteractionDetail.Name_vod__c = callVisitReason.conferenceName;
				}
				if(callVisitReason.conferenceType != null && callVisitReason.conferenceType.length() > 0 ){
					cInteractionDetail.Type_vod__c = callVisitReason.conferenceType;
				}
				if(callVisitReason.visitReasonTactic != null && callVisitReason.visitReasonTactic.length() > 0 ){
					cInteractionDetail.Tactic_vod__c = callVisitReason.visitReasonTactic;
				}
				
				if(callVisitReason.strategyType != null && callVisitReason.strategyType.length() > 0 ){
					cInteractionDetail.Strategy_RAMA_vod__c = callVisitReason.strategyType;
				}
				if(callVisitReason.strategyTactic != null && callVisitReason.strategyTactic.length() > 0 ){
					cInteractionDetail.Tactic_RAMA_vod__c = callVisitReason.strategyTactic;
				}
				if(callVisitReason.strategyTool != null && callVisitReason.strategyTool.length() > 0 ){
					cInteractionDetail.Tools_RAMA_vod__c = callVisitReason.strategyTool;
				}

				cInteractionDetail.iphone_request_id_gne__c = callVisitReason.RequestId;

				callInteractionDetailListToUpsert.add(cInteractionDetail);
				inputRequestIdList.add(callVisitReason.RequestId);

			}
		}

		if(!callInteractionDetailToDelete.isEmpty()) {
			delete callInteractionDetailToDelete.values();
		}

		return callInteractionDetailListToUpsert;
	}

	public static List<Call2_Category_vod__c> getListOfCallCategoryToCreateOrUpdate(Call2_vod__c cRec, iPhoneApex_2.CallAttributes callAttributes, Map<String, String> mapMergedAccountIds, Map<Id, Product_vod__c> mapProducts, List<String> inputRequestIdList){
		List<iPhoneApex_2.CallCategory> callCategoryList = callAttributes.callCategoryList;
		List<Call2_Category_vod__c> callCategoryListToUpsert = new List<Call2_Category_vod__c>();

		Map<Id,Call2_Category_vod__c> callCategoryToDelete = new Map<Id,Call2_Category_vod__c>();
		//Cache existing records - at the beginning all existing records are candidates to delete
		for(Call2_Category_vod__c existingRec : cRec.Call2_Categories__r){
			cacheExistingCallChildRecord(existingRec.Id, existingRec.iPhone_Request_Id_gne__c, existingRec);
			callCategoryToDelete.put(existingRec.Id, existingRec);
		}

		if(callCategoryList != null){
			for(iPhoneApex_2.CallCategory callCategory : callCategoryList) {
				Call2_Category_vod__c cCategory = (Call2_Category_vod__c)getExistingCallChildRecord(callCategory.Id, callCategory.RequestId);

				if(cCategory!=null){
					callCategoryToDelete.remove(cCategory.Id);
				}else{
					cCategory = new Call2_Category_vod__c();
					cCategory.call2_vod__c = cRec.Id;
				}

				if(callCategory.BrandAboveBrand != null) {
					cCategory.Brand_Above_Brand_gne__c = callCategory.BrandAboveBrand;
				}
				if(callCategory.BrandName != null) {
					cCategory.Brand_Name_gne__c = callCategory.BrandName;
				}
				if(callCategory.Indication != null) {
					cCategory.Indication_gne__c = callCategory.Indication;
				}
				if(callCategory.Molecule != null) {
					cCategory.Molecule_gne__c = callCategory.Molecule;
				}
				if(callCategory.NOCStatus != null) {
					cCategory.NOC_Status_gne__c = callCategory.NOCStatus;
				}
				if(callCategory.TherapeuticArea != null) {
					cCategory.Therapeutic_Area_gne__c = callCategory.TherapeuticArea;
				}

				cCategory.iphone_request_id_gne__c = callCategory.RequestId;

				callCategoryListToUpsert.add(cCategory);
				inputRequestIdList.add(callCategory.RequestId);

			}
		}

		if(!callCategoryToDelete.isEmpty()) {
			delete callCategoryToDelete.values();
		}

		return callCategoryListToUpsert;
	}

	public static List<Call2_Key_Message_vod__c> getListOfCallKeyMessageToCreateOrUpdate(Call2_vod__c cRec, iPhoneApex_2.CallAttributes callAttributes, Map<String, String> mapMergedAccountIds, List<String> inputRequestIdList){
		List<iPhoneApex_2.CallKeyMessage> callKeyMessageList = callAttributes.callKeyMessageList;
		List<Call2_Key_Message_vod__c> callKeyMessageListToUpsert = new List<Call2_Key_Message_vod__c>();
		Id accountId = iPhoneApex_2.getWinnerAccountId(mapMergedAccountIds, callAttributes.Account);

		Map<Id,Call2_Key_Message_vod__c> callKeyMessagesToDelete = new Map<Id,Call2_Key_Message_vod__c>();
		//Cache existing records - at the beginning all existing records are candidates to delete
		for(Call2_Key_Message_vod__c existingCallKeyMessage : cRec.call2_key_message_vod__r){
			cacheExistingCallChildRecord(existingCallKeyMessage.Id, existingCallKeyMessage.iPhone_Request_Id__c, existingCallKeyMessage);
			callKeyMessagesToDelete.put(existingCallKeyMessage.Id, existingCallKeyMessage);
		}

		if(callKeyMessageList != null){
			for(iPhoneApex_2.CallKeyMessage callKeyMsg : callKeyMessageList){
				Call2_Key_Message_vod__c cMessage = (Call2_Key_Message_vod__c)getExistingCallChildRecord(callKeyMsg.Id, callKeyMsg.RequestId);
				if(cMessage!=null){
					callKeyMessagesToDelete.remove(cMessage.Id);

					if(callKeyMsg.Product == cMessage.Product_vod__c && AccountId == cMessage.Account_vod__c
						&& callKeyMsg.KeyMessage == cMessage.Key_Message_vod__c && callKeyMsg.Reaction == cMessage.Reaction_vod__c
						&& callKeyMsg.RequestId == cMessage.iPhone_Request_Id__c){
							continue;
						}
				}else{
					cMessage = new Call2_Key_Message_vod__c();
					cMessage.call2_vod__c = cRec.Id;
				}

				if(callKeyMsg.Product != null){
					cMessage.Product_vod__c = callKeyMsg.Product;
				}
				cMessage.Account_vod__c = AccountId;
				if(callKeyMsg.KeyMessage != null){
					cMessage.Key_Message_vod__c = callKeyMsg.KeyMessage;
				}
				if(callKeyMsg.Reaction != null){
					cMessage.Reaction_vod__c = callKeyMsg.Reaction;
				}
				cMessage.iPhone_Request_Id__c = callKeyMsg.RequestId;
				callKeyMessageListToUpsert.add(cMessage);
				inputRequestIdList.add(callKeyMsg.RequestId);
			}
		}

		if(!callKeyMessagesToDelete.isEmpty()) {
			delete callKeyMessagesToDelete.values();
		}

		return callKeyMessageListToUpsert;
	}

	public static List<Call_Pre_Call_gne__c> getListOfCallPreCallToCreateOrUpdate(Call2_vod__c cRec, iPhoneApex_2.CallAttributes callAttributes, List<String> inputRequestIdList){
		List<iPhoneApex_2.CallPreCall> callPreCallList = callAttributes.callPreCallList;
		List<Call_Pre_Call_gne__c> callPreCallListToUpsert = new List<Call_Pre_Call_gne__c>();

		Map<Id, Call_Pre_Call_gne__c> callPreCallToDelete = new Map<Id, Call_Pre_Call_gne__c>();
		//Cache existing records - at the beginning all existing records are candidates to delete
		for(Call_Pre_Call_gne__c existingCallPreCall : cRec.Call_Pre_Calls__r){
			cacheExistingCallChildRecord(existingCallPreCall.Id, existingCallPreCall.iPhone_Request_Id__c, existingCallPreCall);
			callPreCallToDelete.put(existingCallPreCall.Id, existingCallPreCall);
		}

		if(callPreCallList != null){
			for(iPhoneApex_2.CallPreCall callPreCall : callPreCallList){
				Call_Pre_Call_gne__c preCall = (Call_Pre_Call_gne__c)getExistingCallChildRecord(callPreCall.Id, callPreCall.RequestId);
				if(preCall!=null){
					callPreCallToDelete.remove(preCall.Id);


					if(callPreCall.Product == preCall.Product_gne__c
						&& callPreCall.CustomerSegment == preCall.Customer_Segment_gne__c && callPreCall.DecisionCycle == preCall.Decision_Cycle_gne__c && callPreCall.InteractionObjectives == preCall.Interaction_Objectives_gne__c
						&& callPreCall.NeedsPayoffQuestions == preCall.Need_payoff_Questions_gne__c && callPreCall.ImplicationQuestions == preCall.Implication_Questions_gne__c && callPreCall.ProblemQuestions == preCall.Problem_Questions_gne__c
						&& callPreCall.RequestId == preCall.iPhone_Request_Id__c){
							continue;
						}
				}else{
					preCall = new Call_Pre_Call_gne__c();
					preCall.call_gne__c = cRec.Id;
				}

				if(callPreCall.Product != null){
					preCall.Product_gne__c = callPreCall.Product;
				}
				if(callPreCall.CustomerSegment != null){
					preCall.Customer_Segment_gne__c = callPreCall.CustomerSegment;
				}
				if(callPreCall.DecisionCycle != null){
					preCall.Decision_Cycle_gne__c = callPreCall.DecisionCycle;
				}
				if(callPreCall.InteractionObjectives != null){
					preCall.Interaction_Objectives_gne__c = callPreCall.InteractionObjectives;
				}
				if(callPreCall.ImplicationQuestions != null){
					preCall.Implication_Questions_gne__c = callPreCall.ImplicationQuestions;
				}
				if(callPreCall.NeedsPayoffQuestions != null){
					preCall.Need_payoff_Questions_gne__c = callPreCall.NeedsPayoffQuestions;
				}
				if(callPreCall.ProblemQuestions != null){
					preCall.Problem_Questions_gne__c = callPreCall.ProblemQuestions;
				}
				preCall.iPhone_Request_Id__c = callPreCall.RequestId;
				callPreCallListToUpsert.add(preCall);
				inputRequestIdList.add(callPreCall.RequestId);
			}
		}

		if(!callPreCallToDelete.isEmpty()) {
			delete callPreCallToDelete.values();
		}
		return callPreCallListToUpsert;
	}

	public static List<Call2_Sample_vod__c> getListOfCallSampleToCreateOrUpdate(Call2_vod__c cRec, iPhoneApex_2.CallAttributes callAttributes, Map<String,String> acctAttendee2CallIdMap, Map<String, String> mapMergedAccountIds, List<String> inputRequestIdList){
		List<iPhoneApex_2.CallSample> callSampleList = callAttributes.callSampleList;
		List<Call2_Sample_vod__c> callSampleListToUpsert = new List<Call2_Sample_vod__c>();

		Map<Id, Call2_Sample_vod__c> callSamplesToDelete = new Map<Id, Call2_Sample_vod__c>();
		//Cache existing records - at the beginning all existing records are candidates to delete
		for (Id attendeeId : callSampleCache.keyset()){
			for(Call2_Sample_vod__c existingCallSample : callSampleCache.get(attendeeId)){
				cacheExistingCallChildRecord(existingCallSample.Id, existingCallSample.iPhone_Request_Id_gne__c, existingCallSample);
				callSamplesToDelete.put(existingCallSample.Id, existingCallSample);
			}
		}

		if(callSampleList != null){
			for(iPhoneApex_2.CallSample callSample : callSampleList) {
				Id accountId = iPhoneApex_2.getWinnerAccountId(mapMergedAccountIds, callSample.Account);

				Call2_Sample_vod__c cSample = (Call2_Sample_vod__c)getExistingCallChildRecord(callSample.Id, callSample.RequestId);
				if(cSample!=null){
					callSamplesToDelete.remove(cSample.Id);
					if(callSample.Product == cSample.Product_vod__c && Date.newInstance(callAttributes.CallDateTime.year(), callAttributes.CallDateTime.month(), callAttributes.CallDateTime.day()) == cSample.Call_Date_vod__c
						&& AccountId == cSample.Account_vod__c && callSample.Quantity == cSample.quantity_vod__c
						&& callSample.LotNo == cSample.Lot_vod__c && callSample.RequestId == cSample.iphone_request_id_gne__c){
						continue;
					}
				}else{
					cSample = new Call2_Sample_vod__c();
					cSample.call2_vod__c = acctAttendee2CallIdMap.get(AccountId);
				}
                    
				cSample.Product_vod__c = callSample.Product;
				cSample.Call_Date_vod__c = Date.newInstance( callAttributes.CallDateTime.year(), callAttributes.CallDateTime.month(), callAttributes.CallDateTime.day());
                
                String sObjectType = prefixToSObjectType.get(String.valueOf(accountId).substring(0,3));

                if(sObjectType == 'Account') {
                    cSample.Account_vod__c = AccountId;
                } else if(sObjectType == 'Contact') {
                    cSample.Contact_vod__c = AccountId;
                }                              
                
				cSample.quantity_vod__c = callSample.Quantity;
				cSample.Lot_vod__c = callSample.LotNo;
				cSample.iphone_request_id_gne__c = callSample.RequestId;
				callSampleListToUpsert.add (cSample);
				inputRequestIdList.add(callSample.RequestId);
			}
		}

		if(!callSamplesToDelete.isEmpty()) {
			delete callSamplesToDelete.values();
		}

		return callSampleListToUpsert;
	}

	private static void cacheExistingCallChildRecord(String recId, String requestId, SObject callChildRec) {
		if(String.isNotBlank(recId)){
			callChildRecordsCache.put(recId, callChildRec);
		}

		if(String.isNotBlank(requestId)) {
			callChildRecordsCache.put(requestId, callChildRec);
		}
	}

	private static SObject getExistingCallChildRecord(String recId, String requestId) {
		return String.isNotBlank(recId) ? callChildRecordsCache.get(recId) : callChildRecordsCache.get(requestId);
	}

	public static AffiliatedContact findMatchingContact(iPhoneApex_2.ContactAttributes contactAttributes){
		AffiliatedContact result = new AffiliatedContact();
		String queryFields = String.join(
			new List<String>{ 'Id', 'FirstName', 'LastName', 'MailingStreet', 'MailingCity', 'MailingState', 'MailingCountry', 'MailingPostalCode', 'Phone', 'Fax', 'Email', 'AccountId',
				String.valueOf(Contact.Iphone_Request_Id_gne__c),
				String.valueOf(Contact.Middle_Name_gne__c),
				String.valueOf(Contact.Zip_4_gne__c),
				String.valueOf(Contact.Ext_gne__c),
				String.valueOf(Contact.Secondary_Phone_gne__c),
				String.valueOf(Contact.Secondary_Ext_gne__c),
				String.valueOf(Contact.Secondary_Email_gne__c),
				String.valueOf(Contact.Type_gne__c),
				String.valueOf(Contact.Website_gne__c),
				String.valueOf(Contact.LinkedIn_gne__c),
				String.valueOf(Contact.Twitter_gne__c)
			},
			', '
		);

		String whereExpr = 'FirstName = ' + (contactAttributes.FirstName == null ? 'null' : '\'' + String.escapeSingleQuotes(contactAttributes.FirstName.trim()) + '\'');
		whereExpr += ' AND LastName = ' + (contactAttributes.LastName == null ? 'null' : '\'' + String.escapeSingleQuotes(contactAttributes.LastName.trim()) + '\'');
		whereExpr += ' AND MailingStreet = ' + (contactAttributes.StreetAddress == null ? 'null' : '\'' + String.escapeSingleQuotes(contactAttributes.StreetAddress.trim()) + '\'');
		whereExpr += ' AND MailingCity = ' + (contactAttributes.City == null ? 'null' : '\'' + String.escapeSingleQuotes(contactAttributes.City.trim()) + '\'');
		whereExpr += ' AND MailingState = ' + (contactAttributes.State == null ? 'null' : '\'' + String.escapeSingleQuotes(contactAttributes.State.trim()) + '\'');
		whereExpr += ' AND MailingCountry = ' + (contactAttributes.Country == null ? 'null' : '\'' + String.escapeSingleQuotes(contactAttributes.Country.trim()) + '\'');
		if (String.isNotBlank(contactAttributes.Zipcode)){
			whereExpr += ' AND MailingPostalCode = \'' + String.escapeSingleQuotes(contactAttributes.Zipcode.trim()) + '\'';
		} else if(String.isNotBlank(contactAttributes.Zip4)){
			whereExpr += ' AND Zip_4_gne__c = \'' + String.escapeSingleQuotes(contactAttributes.Zip4.trim()) + '\'';
		}

		String queryTemplate = 'SELECT ' + queryFields + ' FROM Contact WHERE IsPersonAccount = false AND {0} ORDER BY LastModifiedDate desc';
		String query = null;
		Map<Id, SObject> contactCandidates = new Map<Id, SObject>();
		DatabaseWithSharingExecutor databaseWithSharingExecutor = new DatabaseWithSharingExecutor();

		// Search Contacts by given Account Id
		if (String.isNotBlank(contactAttributes.Account)){
			String whereExprExt = whereExpr;
			whereExprExt += ' AND AccountId = \'' + String.escapeSingleQuotes(contactAttributes.Account.trim()) + '\'';
			query = String.format(queryTemplate, new String[]{whereExprExt});
			contactCandidates = new Map<Id, SObject>(databaseWithSharingExecutor.executeQuery(query));
		}
		// Search all accessible Contacts
		if (contactCandidates.size() == 0){
			query = String.format(queryTemplate, new String[]{whereExpr});
			contactCandidates = new Map<Id, SObject>(databaseWithSharingExecutor.executeQuery(query));
		}
		if (contactCandidates.size() == 0){
			result.contact = new Contact();
			return result;
		}

		// Search by affiliations
		if (String.isNotBlank(contactAttributes.Account)){
			String affQueryFields = String.join(
				new List<String>{
					'Id',
					String.valueOf(Affiliation_vod__c.To_Contact_vod__c),
					String.valueOf(Affiliation_vod__c.Role_vod__c)
				},
				', '
			);
			String affQuery = String.format('SELECT {0} FROM Affiliation_vod__c WHERE From_Account_vod__c = \'\'{1}\'\' AND To_Contact_vod__c In {2} ORDER BY LastModifiedDate Desc',
				new String[]{
					affQueryFields,
					String.escapeSingleQuotes(contactAttributes.Account.trim()),
					GNE_SFA2_Util.createInListForQuery(contactCandidates.keyset())
				}
			);

			Affiliation_vod__c firstAffFound = null;
			for (Affiliation_vod__c affiliation : Database.query(affQuery)){
				if (firstAffFound == null){
					firstAffFound = affiliation;
				}
				if (affiliation.Role_vod__c == contactAttributes.Role){
					result.contact = (Contact)contactCandidates.get(affiliation.To_Contact_vod__c);
					result.affiliationId = affiliation.Id;
					break;
				}
			}
			if (result.contact == null && firstAffFound != null) {
				result.contact = (Contact)contactCandidates.get(firstAffFound.To_Contact_vod__c);
			}
		}
		if (result.contact == null){
			for (Id contactId : contactCandidates.keyset()){
				result.contact = (Contact)contactCandidates.get(contactId);
				break;
			}
		}
		return result;
	}

	public static Boolean checkIfPicklistValueExist(String sObjectName, String fieldName, String value) {
		Map<String,Schema.SObjectField> fields = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap();
		if(fields.containsKey(fieldName)) {
			DescribeFieldResult field = fields.get(fieldName).getDescribe();
			if(String.valueOf(field.getType()) == 'Picklist') {
				List<Schema.PicklistEntry> plEntries = field.getPicklistValues();
				for(Schema.PicklistEntry plEntry : plEntries) {
					if(plEntry.getValue() == value) {
						return true;
					}
				}
			}
		}

		return false;
	}
    
    public static Id getRecordTypeId(Boolean isNewMode, Id territoryId) {
        Id result = null;
        if(isNewMode) {
            String rtDeveloperName = getDefaultRecordTypeBasedOnTerritory(territoryId);
            if (String.isNotBlank(rtDeveloperName)) {
                for (RecordType rt : [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Call2_vod__c' AND DeveloperName = :rtDeveloperName LIMIT 1]) {
                    result = rt.Id;
                }
            }
        }
        return result;
    }
    
    private static String getDefaultRecordTypeBasedOnTerritory(Id currentTerritoryId) {
        String defaultRecordType = null;
        try {
            Territory2 terr = [SELECT Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c FROM Territory2 WHERE Id = :currentTerritoryId LIMIT 1];
            if (terr.Salesforce_Code_gne__c != null) {
                GNE_SFA2_Territory_Record_Type_mapping__c terrToRTmapping = GNE_SFA2_Territory_Record_Type_mapping__c.getInstance(terr.Salesforce_Code_gne__c);
                if (terrToRTmapping != null) {
                    defaultRecordType = terrToRTmapping.Record_Type_DeveloperName__c;
                } else if(terr.Salesforce_SubTeam_Code_gne__c != null ){
                    String subteamCode = terr.Salesforce_Code_gne__c + '_' +terr.Salesforce_SubTeam_Code_gne__c;
                    terrToRTmapping = GNE_SFA2_Territory_Record_Type_mapping__c.getInstance(subteamCode);
                    if(terrToRTmapping != null) {
                        defaultRecordType = terrToRTmapping.Record_Type_DeveloperName__c;
                    }
                }
            }
        } catch (Exception ex) {
            System.debug('Exception while retrieving default record type: ' + ex);
        }
        return defaultRecordType;
    }

	public with sharing class DatabaseWithSharingExecutor {
		public DatabaseWithSharingExecutor(){}
		public List<SObject> executeQuery(String query){
			return Database.query(query);
		}
	}

	public class AffiliatedContact {
		public Contact contact { get; set; }
		public String affiliationId { get; set; }
		public AffiliatedContact(){}
	}
}