global without sharing class iPhoneApex {

	static final String DEFAULT_CALL_INTERACTION_TYPE   = 'Office Appt/Drop In';
	static final String DEFAULT_CALL_TYPE               = 'Detail with Sample';
	static final String DEFAULT_GROUP_CALL_TYPE         = 'Group Detail with Sample';
	static final String NON_GROUP_CALL_TYPE             = 'Detail Only';
	static final String GROUP_CALL_TYPE                 = 'Group Detail';
	static final String DEFAULT_CONTACT_AFFILIATION_TYPE= 'EMPLOYED BY';
	static final String DEFAULT_CALL_STATUS             = 'Saved_vod';
	static final String DEFAULT_SAMPLE_RECORD_TYPE_FOR_CALL = 'Meeting Brief SFA-Primary-Care';
	static final String DEFAULT_LAST_DEVICE             = 'iPhone_gne';
	static final String DEFAULT_CREATED_ON_DEVICE       = 'iPhone_gne';
	static final String NonProduct_NonMolecule= 'Non-Product/Non-Molecule';
	static final String REQUESTID_PREFIX_FOR_MAIN_CALL = 'Infu_INT';
	static final String REQUESTID_PREFIX_FOR_ATTENDEE  = 'Infu_ATT';
	static final String REQUESTID_PREFIX_FOR_SAMPLE    = 'Infu_SAM';
	static final String REQUESTID_PREFIX_FOR_DETAIL    = 'Infu_DET';
	static final String REQUESTID_PREFIX_FOR_DISCUSSION= 'Infu_DISC';
	// variables used for distingiush OTR and WEB requests
	public static Boolean isOtrRequestStat = false;
	static final Map<String,AttendeeType> CALL_ATTENDEE_TYPES_MAP;
	
	global enum AttendeeType { PERSONACCOUNT,ACCOUNT,CONTACT,USER }
	
	static {
		CALL_ATTENDEE_TYPES_MAP = new Map<String,AttendeeType>();
		
		for(AttendeeType attType : AttendeeType.values()) {
			CALL_ATTENDEE_TYPES_MAP.put(attType.name(), attType);
		}
	} 

	// response 
	global class Response {
		WebService DateTime StartTime = DateTime.now();
		WebService DateTime EndTime   = null;
		WebService String ErrorCode;
		WebService String ErrorMessage;
		WebService List<RequestIdResponseIdMap> RequestIdResponseIdList;
	}

	global class RequestIdResponseIdMap {
		WebService String RequestId;
		WebService String ResponseId;    
		WebService String ObjectType;
		WebService String ObjectName;
	}
	
	// call structures
	global class CallDetail {
		WebService String Product;
		WebService String DetailPriority;   
		WebService String RequestId;
		WebService String TherapeuticArea;
		WebService String DiseaseIndication;               
	}
	
	global class CallDiscussion {
		WebService String Product;
		WebService String ProductStrategy;
		WebService String ProductTactic;
		WebService String Reaction;
		WebService String RequestId;
		WebService Integer NbrPatientsImpacted;
		WebService String AccountTactic;
		
		//Attributes to support MSL users interactions
		WebService String Answer; 
		WebService String Question; 
		WebService String Topic; 
		WebService String CurrentIssue; 
		WebService String Molecule;
		//new fields for OTR Added by Dominik Wasilewski 5-13-2011
		Webservice String Curriculum;
		WebService String Activity;
		WebService Boolean EventRelated;
		
		//new field for force.com new data model
		WebService String DetailPriority;
		WebService String ActivityTimeSpent;
	}
	
	global class CallSample {
		WebService String Account;
		WebService String Product;
		WebService Double Quantity;
		WebService String RequestId;
		WebService String LotNo;
	}
	
	global class CallKeyMessage {
		WebService String Account;
		WebService String KeyMessage;
		WebService String Reaction;
		WebService String RequestId;
		WebService String Product; //new field for OTR Added by Dominik Wasilewski 5-13-2011
	}
	
	global class CallAttendee implements iPhoneBase.EnumSerializable {
		WebService String Attendee;        
		WebService AttendeeType CallAttendeeType; // user, account or contact
		WebService String RequestId;
		WebService Boolean MealOptOut;
		
		public String callAttendeeTypeString; // Used in JSON serialization
		
		public void serializeEnums() {
			callAttendeeTypeString = CallAttendeeType!=null ? CallAttendeeType.name() : null;
		}
		
		public void deserializeEnums() {
			CallAttendeeType = CALL_ATTENDEE_TYPES_MAP.get(callAttendeeTypeString);
		}
	}
	
	global class CallAttributes implements iPhoneBase.EnumSerializable {
		// used to remove existing call Info            
		WebService String               Id; 
		WebService String               RequestId;
		WebService String               OwnerId;
		
		WebService String               Account;
		WebService String               Address;
		WebService String               AddressText;
		WebService DateTime             CallDateTime;
		WebService Boolean              IsComplete;
		WebService Boolean        		isOtrRequest;
		WebService String               InteractionType;
		WebService AttendeeType         CallAttendeeType;
		
		WebService Integer              NumOfCustomersPresent;
		// compliance
		WebService Double               MealAmount;
		WebService Integer              MealPlannedAttendeeCount;
		WebService Integer              MealActualAttendeeCount;
		WebService String               BusinessSponsor;
		WebService String               MealLocationCity;
		WebService String               MealLocationState; 
		
		WebService List<CallAttendee>   callAttendeeList;
		WebService List<CallDetail>     callDetailList;
		WebService List<CallDiscussion> callDiscussionList;
		WebService List<CallSample>     callSampleList;
		// atls key message 
		WebService List<CallKeyMessage> callKeyMessageList;        

		//added by sandeep on Feb 12 2009
		WebService String               SpendUser;
		
		WebService Boolean              ContractedServices;
		WebService String               TerritoryName;
		
		//sample fields
		WebService String               Signature;
		WebService DateTime             SignatureDate;
		WebService String               Disclaimer;
		WebService String               SampleReceiver ;
		WebService String               LicenseNumber; //commented out StateMedicalLicense below. To clarify wether LicenseNumber is the SDFC id or textual Licence number
		//WebService String             StateMedicalLicense; //this was assumed to be a SFDC License Id as per Ross but later LicenseNumber was communicated by QingQing. TO verify and change Validation logic accordingly
		webservice Boolean              ValidationEngine;
		
		//Attributes to support FRM users interactions
		webservice Boolean              isFRM;
		WebService String               SpeakerProgram;
		WebService String               Resolution;
		WebService Boolean              Reactive;
		WebService String               ResponseTime;
		WebService String               InteractionMethod;
		WebService String               TopicsAddressed;
		WebService String               InteractionLocation;
		WebService String               AdditionalNotes;
		WebService String               AccountPlan;
		
		//Attributes to support MSL users interactions
		WebService Boolean              isMSL;
		WebService String               isVisitReason;
		WebService String         		visitReasonDescription;
		WebService String               GroupMeetingTopic;
		WebService String               PrimaryInteractionReason; 
		
		WebService Boolean              UnwillingToMeet;
		WebService Boolean              MealOptOut;
		
		WebService String               NotesCanada;
		WebService String               MedicalSupportNotesCanada;
		WebService String               Referral;
		Webservice String				UnsolicitedRequest;
		WebService String 				SalesCollateral;
		
		public String callAttendeeTypeString; // Used in JSON serialization
		
		public void serializeEnums() {
			callAttendeeTypeString = CallAttendeeType!=null ? CallAttendeeType.name() : null;
			
			if(callAttendeeList!=null) {
				for(CallAttendee cAtt : callAttendeeList) {
					cAtt.serializeEnums();
				}
			}
		}
		
		public void deserializeEnums() {
			CallAttendeeType = CALL_ATTENDEE_TYPES_MAP.get(callAttendeeTypeString);
			
			if(callAttendeeList!=null) {
				for(CallAttendee cAtt : callAttendeeList) {
					cAtt.deserializeEnums();
				}
			}
		}
	}
	
	global class MedcomAttributes {
		WebService String RequestId;
		WebService String Account;
		
		WebService String MedicalQuestion;
		WebService String Product;
		WebService String Priority;
		WebService String FollowUpMethod;
		WebService Boolean NotifyForEducation;
		
		WebService String StreetAddress;
		WebService String Suite;
		WebService String DepartmentName;
		WebService String AttnCareOf; 
		WebService String City;
		WebService String State;
		WebService String Zip;
		WebService String ZipPlus4;
		
		WebService String Email;
		WebService String Phone;
		WebService String Fax;
		
		WebService String LanguageOfPreferenceCan;
		WebService String ProvinceCan;
		WebService String PostalCodeCan;
	}

	global enum AddressAttributeType { PHONE, PHONEEXT, 
		PHONE2, PHONE2EXT, 
		FAX, FAX2,POSTALCODE,PROVINCE,ORGANIZATION }
	
	global class AttributeValuePair {
		WebService String value;
		WebService AddressAttributeType attributeType;        
	}

	global class AddressAttributes {
		WebService String AddressId; 
		WebService List<AttributeValuePair> AttributeValuePairList;  
	}

	global class ContactAttributes {
		WebService String RequestId;
		WebService String AffiliationRequestId;
		
		WebService String Id;
		WebService String AffiliationId;
		
		WebService String Account;
		WebService String Role;
		
		WebService String FirstName;
		WebService String LastName;
		WebService String MiddleName;
		
		WebService String StreetAddress;
		WebService String City;
		WebService String State;
		WebService String Country;
		WebService String Zipcode;
		WebService String Zip4;
		
		WebService String Phone;
		WebService String PhoneExt;
		WebService String Phone2;
		WebService String Phone2Ext;
		WebService String Email;
		WebService String Email2;
		WebService String Fax;
	}
	
	global class ReferralInfo{
		WebService String       RequestId;
		WebService Id           AccountId;
		WebService Id           AddressId;
		WebService String       MedicalQuestion;
		WebService String       FollowupMethod;
		WebService Id           ProductId;
		WebService Id           MoleculeId;
		WebService Id           TA_SubTAId;
		WebService Date         RequestedCompletionDate;
		WebService String       Priority;
		WebService Id           RequestedById;
		WebService Boolean      isMedComm;
		WebService Id           UserId;
		WebService Id           AssignedToId;
		WebService String       customPhone;
	}

	global enum PreferenceType { FAVORITE, PREFERREDADDRESS }
	global enum ObjectType { ACCOUNT, CONTACT }
	
	global class UserPreferenceAttributes {
		WebService PreferenceType preferenceType;
		WebService String         OnObjectId;
		WebService ObjectType     OnObjectType;
		WebService Boolean        MyFavorite;
		WebService String         WithObjectId;     
	}

	global class CallListAfterDelete {
		WebService List<Call2_vod__c> remainingCallList;
	}
	
	WebService static Response deleteCall(CallAttributes callAttributes){
		Response callResponse       = new Response();        
		SavePoint savePoint         = Database.setSavePoint(); 
		String callId               = callAttributes.Id;
		
		try{
			if (callAttributes.Id != null ){ 
				if(callAttributes.Id.trim()!=''){
					List<Call2_vod__c> callList = [SELECT id FROM call2_vod__c WHERE id = :callAttributes.id ];
					if (callList.size() > 0 ){ 
						callId =  callList[0].Id;
					}    
				}
			}
			//if call found then delete call
			if(callId!=null && callId !='') {
				iPhoneApexUtil.deletCallHelper(callId);
				
				//Request Id to Response Id Map
				callResponse.RequestIdResponseIdList = new List<RequestIdResponseIdMap>();
				RequestIdResponseIdMap requestIdResponseIdItem = new RequestIdResponseIdMap(); 
				requestIdResponseIdItem.RequestId  = callAttributes.RequestId;
				requestIdResponseIdItem.ResponseId = callId;
				requestIdResponseIdItem.ObjectType = 'Call2_vod__c';
				callResponse.RequestIdResponseIdList.add ( requestIdResponseIdItem ); 
			}//return error call does not exists in SFDC
			else {
				callResponse.ErrorMessage = 'Invalid call';
				callResponse.RequestIdResponseIdList = new List<RequestIdResponseIdMap>();
			}
		}catch (Exception e){
			callResponse.ErrorMessage = e.getMessage();
			callResponse.RequestIdResponseIdList = new List<RequestIdResponseIdMap>();
			Database.rollback ( savePoint ); 
		}
		callResponse.EndTime = DateTime.now();
		return callResponse;
	}

	static void addIdToRequestReponseMap (List<RequestIdResponseIdMap> requestIdResponseIdList,
		String objectType,
		List<Database.SaveResult> saveResultList,
		List<String> inputRequestIdList) {

		Integer resultLen = saveResultList.size();
		for (Integer i = 0; i < resultLen; i++ ){           
			Database.SaveResult saveResult = saveResultList[i];
			if ( saveResult.getId() != null ) {  
				RequestIdResponseIdMap requestIdResponseIdItem = new RequestIdResponseIdMap(); 
				requestIdResponseIdItem.RequestId  = inputRequestIdList[i];
				requestIdResponseIdItem.ResponseId = saveResult.getId();
				requestIdResponseIdItem.ObjectType = objectType;
				requestIdResponseIdList.add ( requestIdResponseIdItem );
				
			}                                                                             
		}
	}
	
	static void addIdToRequestReponseMap (List<RequestIdResponseIdMap> requestIdResponseIdList,
		String objectType,
		List<Database.Upsertresult> saveResultList,
		List<String> inputRequestIdList) {

		Integer resultLen = saveResultList.size();
		for (Integer i = 0; i < resultLen; i++ ){           
			Database.Upsertresult saveResult = saveResultList[i];
			if ( saveResult.getId() != null ) {  
				RequestIdResponseIdMap requestIdResponseIdItem = new RequestIdResponseIdMap(); 
				requestIdResponseIdItem.RequestId  = inputRequestIdList[i];
				requestIdResponseIdItem.ResponseId = saveResult.getId();
				requestIdResponseIdItem.ObjectType = objectType;
				requestIdResponseIdList.add ( requestIdResponseIdItem );
			}                                                                             
		}
	}
	
	static List<Call2_vod__c> findOrCreateCall (CallAttributes callAttributes) {
		Call2_vod__c callRecord                 = null;
		Call2_vod__c sampledCallRecord          = null;
		String callId                           = callAttributes.Id;
		Boolean isIncomingSignatureCall         = false;
		CallListAfterDelete callsAfterDelete    = new CallListAfterDelete();
		List<Call2_vod__c> mainAndSampleCall    = new List<Call2_vod__c>();
		
		// get Call Id for iPhone Request Id 
		// when iPhone CallAttributes.Id is null 
		if ( callAttributes.Id == null && callAttributes.RequestId != null ) { 
			List<Call2_vod__c> callList = [SELECT id FROM call2_vod__c WHERE iphone_request_Id_gne__c = :callAttributes.RequestId];
			if (callList.size() > 0 ){ 
				callId =  callList[0].Id; 
			}                                                                    
		}
		
		if ( callId != null ){ 
			if ( callAttributes.Signature != null || callAttributes.SignatureDate!=null || callAttributes.Disclaimer!=null || callAttributes.LicenseNumber!=null) {
				isIncomingSignatureCall=true; //if incoming call has signature attached
			}
			callsAfterDelete = iPhoneApexUtil.deleteCallRelatedItems (callId, isIncomingSignatureCall, callAttributes.OwnerId);
			if( callsAfterDelete.remainingCallList!=null && callsAfterDelete.remainingCallList.size()>0){
				callRecord          = callsAfterDelete.remainingCallList[0];
				if(callsAfterDelete.remainingCallList.size()>1){
					sampledCallRecord   = callsAfterDelete.remainingCallList[1];
				}
			}
			
			if ( callRecord == null ){ 
				callRecord = new Call2_vod__c(); // should not be the case....
			}     
		}                
		
		if ( callRecord == null ){
			callRecord  = new Call2_vod__c();
		}
		
		// initializer for iPhone call 
		if ( callAttributes.InteractionType == null || callAttributes.InteractionType.trim().length() == 0 ){
			callRecord.Interaction_Type_gne__c  = iPhoneApex.DEFAULT_CALL_INTERACTION_TYPE;
		}else{
			callRecord.Interaction_Type_gne__c  = callAttributes.InteractionType;
		}
		callRecord.Call_Type_vod__c         = iPhoneApex.DEFAULT_CALL_TYPE;
		callRecord.iPhone_Request_Id_gne__c = callAttributes.RequestId;
		mainAndSampleCall.add(callRecord);
		mainAndSampleCall.add(sampledCallRecord);
		return mainAndSampleCall;
	}
	
	//return winner account id for a merged account
	static String getWinnerAccountId(Map<String, String> mapAcctIds, String accountId){
		if(accountId!=null) {
			if(mapAcctIds!=null && mapAcctIds.containsKey(accountId)){
				return mapAcctIds.get(accountId);
			}
		}
		return accountId;
	}
	
	//return winner account id for a merged address
	static String getWinnerAddressId(Map<String, String> mapaddrIds, String addressId){
		if(addressId!=null) {
			if(mapaddrIds!=null && mapaddrIds.containsKey(addressId)){
				return mapaddrIds.get(addressId);
			}
		}
		return addressId;
	}
	
	//get state medical license record for Account and license number
	static Address_vod__c getAddressFields(String addressId){
		Address_vod__c obAddress;
		try{
			obAddress = [SELECT Id, Name, Account_vod__c, ADDRESS_1_GNE__C, ADDRESS_LINE_2_VOD__C, ADDRESS_LINE_3_GNE__C, ADDRESS_LINE_4_GNE__C, City_Vod__c, State_vod__c, ZIP_VOD__C, Designation_gne__c, Country_vod__c, Zip_4_vod__c FROM Address_vod__c WHERE Id =:addressId ];
		}
		catch(Exception ex){
			//do nothing)
		}
		return obAddress;
	}

	//method call for Sample Signatur(Sampling)
	Webservice static Response updateOrCreateCall (CallAttributes callAttributes){
		Response callResponse = new Response();        
		SavePoint savePoint = Database.setSavePoint(); 
		String callOwnerId;
		String terrName;
		CallListAfterDelete callsAfterDelete = new CallListAfterDelete();
		List<Call2_vod__c> mainAndSampleCall = new List<Call2_vod__c>();
		Boolean isNewInteraction = false;
		Boolean isIncomingSignatureCall = false; 
		Boolean isExistingCallSampleCall = false; //for ading samples 
		
		Map<Id, Product_vod__c> sampleProductMap = new Map<Id, Product_vod__c>();
		
		Map<String,String> acctAttendee2CallIdMap = new Map<String,String>();
		
		// [OSOWIECB, OTR-1341] This will be turned on after call samples will be created.
		//Inactivated due to Veeva removal 
		//VOD_CALL2_HEADER_CLASS.setUpdateSampleTransactionAction(false);

		// If errors occur such that sample all information is not passed
		// Fail this save so Call will stay on iPhone
		//        if (callAttributes.callSampleList != null &&
		//            callAttributes.callSampleList.size() > 0 &&(
		//            callAttributes.SignatureDate == null ||
		//            callAttributes.Disclaimer == null    ||
		//            callAttributes.Signature == null)){
		//             String errorTxt = 'Missing Signature Info Call Save aborted';
		//             iPhoneBase.handleErrors(String.valueOf(callAttributes), userInfo.getUserId(), errorTxt, new MissingSignatureException(errorTxt));
		//             callResponse.ErrorMessage = errorTxt; 
		//           return callResponse;
		//        }
		
		//get winner account
		List<String> addrIds = new List<String>();

		try {
			
			//get userId to stamp call owner
			if(callAttributes.OwnerId!=null){
				callOwnerId=callAttributes.OwnerId;
			}
			else{
				callOwnerId = UserInfo.getUserId();
			}
			
			Map<String, String> mapMergedAccountIds = iPhoneApexUtil.findMergedAccounts( iPhoneApexUtil.AccountIdsFromCallAttribute(callAttributes))  ;
			
			// Add current call address id to addrIds and find winner if it is looser
			if(callAttributes.Address != null){
				addrIds.add(callAttributes.Address);
			}
			Map<String, String> mapMergedAddressIds = iPhoneApexUtil.findMergedAddresses(addrIds);
			
			if(callAttributes.Address!=null){

				Address_vod__c fullAddress = getAddressFields(getWinnerAddressId(mapMergedAddressIds, callAttributes.Address));

				// Call account is different than call address account
				if(callAttributes.Account != null && fullAddress.Account_vod__c != null && callAttributes.Account != fullAddress.Account_vod__c){
					
					
					List<Address_vod__c> accountAddressList = [SELECT Id, Account_vod__c, Name, City_vod__c, State_vod__c, Zip_vod__c, Country_vod__c FROM Address_vod__c WHERE Account_vod__c = :callAttributes.Account];
					String initialCallAddress = callAttributes.Address;
					Boolean addressFound = false;
					
					for(Address_vod__c tmpAddress : accountAddressList){
						if (
								((fullAddress.Name == null && tmpAddress.Name == null) || (fullAddress.Name != null && tmpAddress.Name != null && fullAddress.Name.equalsIgnoreCase(tmpAddress.Name))) &&
								((fullAddress.City_Vod__c == null && tmpAddress.City_Vod__c == null) || (fullAddress.City_Vod__c != null && tmpAddress.City_Vod__c != null && fullAddress.City_Vod__c.equalsIgnoreCase(tmpAddress.City_Vod__c))) &&
								((fullAddress.State_vod__c == null && tmpAddress.State_vod__c == null) || (fullAddress.State_vod__c != null && tmpAddress.State_vod__c != null && fullAddress.State_vod__c.equalsIgnoreCase(tmpAddress.State_vod__c))) &&
								((fullAddress.Zip_vod__c == null && tmpAddress.Zip_vod__c == null) || (fullAddress.Zip_vod__c != null && tmpAddress.Zip_vod__c != null && fullAddress.Zip_vod__c.equalsIgnoreCase(tmpAddress.Zip_vod__c))) &&
								((fullAddress.Country_vod__c == null && tmpAddress.Country_vod__c == null) || (fullAddress.Country_vod__c != null && tmpAddress.Country_vod__c != null && fullAddress.Country_vod__c.equalsIgnoreCase(tmpAddress.Country_vod__c)))){ // identical address found
							// swap call address to the same address from account
							callAttributes.Address = tmpAddress.Id;
							addressFound = true;
							break;
						}
					}
					if (!addressFound) { //create new address and add it to the call account
						Address_vod__c newAccountAddress = new Address_vod__c();
						newAccountAddress.Account_vod__c = getWinnerAccountId(mapMergedAccountIds, callAttributes.Account);
						newAccountAddress.Name = fullAddress.Name;
						newAccountAddress.Address_line_2_vod__c = fullAddress.Address_line_2_vod__c;
						newAccountAddress.Address_Line_3_gne__c = fullAddress.Address_Line_3_gne__c;
						newAccountAddress.Address_Line_4_gne__c = fullAddress.Address_Line_4_gne__c;
						newAccountAddress.City_vod__c = fullAddress.City_vod__c;
						newAccountAddress.Zip_vod__c = fullAddress.Zip_vod__c;
						newAccountAddress.Zip_4_vod__c = fullAddress.Zip_4_vod__c;
						newAccountAddress.Country_vod__c = fullAddress.Country_vod__c;
						newAccountAddress.State_vod__c = fullAddress.State_vod__c;
						
						try {
							insert(newAccountAddress);
							callAttributes.Address = newAccountAddress.Id;
							System.debug('###########################call address successfully changed to: '+callAttributes.Address);
						}
						catch (Exception e){
							callAttributes.Address = initialCallAddress;
							iPhoneBase.handleException(e, UserInfo.getUserId(), (callAttributes.isOtrRequest==true ? 'OTR' : null),
								'Record Interaction', iPhoneApex.CallAttributes.class, callAttributes, '[iPhoneApex] Error while creating new address for interaction');
						}
					}
				}
			}
			
			if(callAttributes.ValidationEngine!=null){
				callAttributes=iPhoneApexUtil.updateOrCreateCallForValEngine(callAttributes);
			}

			if(callAttributes.Signature!=null || callAttributes.SignatureDate !=null || callAttributes.Disclaimer !=null || callAttributes.LicenseNumber!=null){
				isIncomingSignatureCall = true; 
			}
			
			Call2_vod__c c                  = null;
			Call2_vod__c sampledCallRecord  = null;
			mainAndSampleCall               = findOrCreateCall(callAttributes);              
			
			List<Call2_Sample_vod__c> callSampProdList = new List<Call2_Sample_vod__c>();

			if(mainAndSampleCall!=null && mainAndSampleCall.size()>0){
				c = mainAndSampleCall[0];
				if(c.Call2_sample_vod__r!=null){
					callSampProdList = c.Call2_sample_vod__r;
				}
				if(mainAndSampleCall.size()>1){
					sampledCallRecord = mainAndSampleCall[1];
					if(sampledCallRecord!=null && sampledCallRecord.Call2_sample_vod__r!=null){
						callSampProdList = sampledCallRecord.Call2_sample_vod__r;
					}
				}
			}
			
			Set<String> prodSet = new Set<String>();
			if(callAttributes.callSampleList!=null){
				for ( CallSample sampleProd : callAttributes.callSampleList ){
					if(sampleProd.Product!=null){
						prodSet.add(sampleProd.Product);
					}
				}
			}
			if(callSampProdList!=null && callSampProdList.size()>0){
				for(Call2_Sample_vod__c csc : callSampProdList){
					prodSet.add(csc.Product_vod__c);
				}
			}
			if(prodSet.size()>0){
				sampleProductMap = iPhoneApexUtil.getSampleProductList(prodSet);
			}
			
			//get list of detail, discussion and molecule products
			set<Id> productIdList = new set<Id> ();
			set<Id> moleculeIdList = new set<Id> ();
			productIdList = iPhoneApexUtil.getDetailproductIdList(callAttributes);
			moleculeIdList = iPhoneApexUtil.getMoleculeproductIdList(callAttributes);
			if(moleculeIdList!=null){
				if(moleculeIdList.size()>0){
					for(String sm : moleculeIdList){
						if(!productIdList.contains(sm)){
							productIdList.add(sm);
						}
					}
				}
				
			}
			Map<Id, Product_vod__c> mapProducts;
			mapProducts=iPhoneApexUtil.getDetailedProducts(productIdList, callAttributes);
			c.detailed_products_vod__c = iPhoneApexUtil.getDetailedProductString(mapProducts, moleculeIdList);
			
			System.Debug('-------------------------etWinnerAccountId'+getWinnerAccountId(mapMergedAccountIds, callAttributes.Account));
			
			c.Last_Device_vod__c= iPhoneApex.DEFAULT_LAST_DEVICE;
			
			//to update address fields address_line_1, line_2, city_vod__c on call object
			Address_vod__c objAddress = getAddressFields(getWinnerAddressId(mapMergedAddressIds, callAttributes.Address));

			//first check if existing main call record is a sample attendee call or the main call is an HCO with a sample attendee
			//If yes then do not update incoming signature values else
			//it not then update signature fields 
			if(c.Is_Sampled_Call_vod__c || sampledCallRecord!=null){ //if attendee and is sampled OR if HCO and sample attendee
				isExistingCallSampleCall = true;
				if(c.account_vod__c!=null && callAttributes.Account!=null){
					if(getWinnerAccountId(mapMergedAccountIds, c.account_vod__c) == getWinnerAccountId(mapMergedAccountIds, callAttributes.Account) ){ //if call is sample attendee then if account is same then update to winner account
						c.account_vod__c = getWinnerAccountId(mapMergedAccountIds, callAttributes.Account);
						System.Debug('-----------------account_vod__c '+c.account_vod__c );
					}
					else{
						//do nothing because if this is s sampled call then the account for the main call should not be updated if the incoming account is different
					}
				}
			}else{
				c.account_vod__c = getWinnerAccountId(mapMergedAccountIds, callAttributes.Account); //if call is not sample attendee then update with incoming acount
				c.call_datetime_vod__c     = callAttributes.CallDateTime;
				c.OwnerId = callOwnerId;
				c.Status_vod__c = iPhoneApex.DEFAULT_CALL_STATUS;

			}
			system.debug('----------------------------address parent'+getWinnerAddressId(mapMergedAddressIds, c.Parent_address_vod__c));
			system.debug('----------------------------address call atr'+getWinnerAddressId(mapMergedAddressIds, callAttributes.Address));
			system.debug('----------------------------mapMergedAddressIds'+mapMergedAddressIds.size());
			//if existing main call is a sample HCP then do not update signature fields else update signature fields
			if(isExistingCallSampleCall) {  
				if(c.Parent_address_vod__c==null){
					system.debug('----------------------------address'+getWinnerAddressId(mapMergedAddressIds, callAttributes.Address));
					c.Parent_address_vod__c =  getWinnerAddressId(mapMergedAddressIds, callAttributes.Address);
					if(objAddress!=null) {
						c.License_designation_gne__c = objAddress.Designation_gne__c;
					}
					//assign the address fields to call object address fields
					if(objAddress!=null){ 
						c.Address_Line_1_vod__c = objAddress.Name;
						c.Address_Line_2_vod__c = objAddress.Address_line_2_vod__c;
						c.City_vod__c           = objAddress.City_vod__c;
						c.State_vod__c          = objAddress.State_vod__c;
						c.Zip_vod__c            = objAddress.Zip_vod__c;
					}
				}else if(c.Parent_address_vod__c!=null){
					// if addresses are same then update  winner address
					if(getWinnerAddressId(mapMergedAddressIds, c.Parent_address_vod__c) == getWinnerAddressId(mapMergedAddressIds, callAttributes.Address))
					c.Parent_address_vod__c =  getWinnerAddressId(mapMergedAddressIds, callAttributes.Address);
					if(objAddress!=null) {
						c.License_designation_gne__c = objAddress.Designation_gne__c;
					}
					if(objAddress!=null){ //assign the address fields to call object address fields
						c.Address_Line_1_vod__c = objAddress.Name;
						c.Address_Line_2_vod__c = objAddress.Address_line_2_vod__c;
						c.City_vod__c           = objAddress.City_vod__c;
						c.State_vod__c          = objAddress.State_vod__c;
						c.Zip_vod__c            = objAddress.Zip_vod__c;
					}
				}
				if (c.address_vod__c==null){
					c.address_vod__c = callAttributes.AddressText;
				}
			}else {
				c.Parent_address_vod__c =  getWinnerAddressId(mapMergedAddressIds, callAttributes.Address);
				c.address_vod__c        = callAttributes.AddressText;
				if(objAddress!=null){ //assign the address fields to call object address fields
					c.License_designation_gne__c = objAddress.Designation_gne__c;
					c.Address_Line_1_vod__c = objAddress.Name;
					c.Address_Line_2_vod__c = objAddress.Address_line_2_vod__c;
					c.City_vod__c           = objAddress.City_vod__c;
					c.State_vod__c          = objAddress.State_vod__c;
					c.Zip_vod__c            = objAddress.Zip_vod__c;
				}
			}

			if ( callAttributes.CallAttendeeType == AttendeeType.ACCOUNT){
				c.attendee_type_vod__c = 'Group_Account_vod';
				//c.call_type_vod__c     = iPhoneApex.GROUP_CALL_TYPE; 
				//existing sample call
				if( (isExistingCallSampleCall) ){ 
					c.call_type_vod__c     = iPhoneApex.DEFAULT_GROUP_CALL_TYPE; 
				}
				//call with incoming sample
				else if(isIncomingSignatureCall){
					c.call_type_vod__c     = iPhoneApex.DEFAULT_GROUP_CALL_TYPE; 
				}
				//call without sample
				else{ 
					c.call_type_vod__c     = iPhoneApex.GROUP_CALL_TYPE; 
				}
			} else if ( callAttributes.CallAttendeeType == AttendeeType.PERSONACCOUNT ) {
				//a group call with PersonAccount as main call will always have its attendee_type_vod__c as 'Person_Account_vod'
				c.attendee_type_vod__c = 'Person_Account_vod';
				//a group call with PersonAccount as main call will always have its call_type_vod__c either 'Detail with sample' or 'Detail only'
				//if existing main call is a sample attendee then do not update signature fields else update signature fields
				
				if(!c.Is_Sampled_Call_vod__c){
					if(isIncomingSignatureCall){
						c.Signature_Date_vod__c     = callAttributes.SignatureDate;
						c.Signature_vod__c          = callAttributes.Signature;
						c.License_vod__c            = callAttributes.LicenseNumber;
						c.Disclaimer_vod__c         = callAttributes.Disclaimer;
						c.Is_Sampled_Call_vod__c    = true;
						c.call_type_vod__c          = iPhoneApex.DEFAULT_CALL_TYPE; 
						if(objAddress!=null) {
							c.License_designation_gne__c = objAddress.Designation_gne__c;
						}
					}else{
						c.call_type_vod__c = NON_GROUP_CALL_TYPE;
					}
				}else{
					//do nothing, because the call types would already have been stamped - earlier comment
					//added code on 10 Sept'10 to update signature fields in sfdc for a sampled call that were not passed earlier and are null in sfdc
					if(c.Signature_Date_vod__c==null){
						if(callAttributes.SignatureDate!=null){
							c.Signature_Date_vod__c = callAttributes.SignatureDate;
						}
					}
					if(c.Signature_vod__c==null){
						if(callAttributes.Signature!=null){
							c.Signature_vod__c = callAttributes.Signature;
						}
					}
					if(c.License_vod__c==null){
						if(callAttributes.LicenseNumber!=null){
							c.License_vod__c = callAttributes.LicenseNumber;
						}
					}
					if(c.Disclaimer_vod__c==null){
						if(callAttributes.Disclaimer!=null){
							c.Disclaimer_vod__c = callAttributes.Disclaimer;
						}
					}
				}
			}                
			
			// compliance: meal section attributes
			if ( callAttributes.MealAmount != null ) {   
				c.meal_amount_gne__c = callAttributes.MealAmount;
			}
			
			if((callAttributes.MealPlannedAttendeeCount != null && callAttributes.MealPlannedAttendeeCount > 0) &&
					(callAttributes.MealActualAttendeeCount != null && callAttributes.MealActualAttendeeCount > 0)) {
				c.meal_expense_gne__c = true;
				c.planned_attendees_gne__c = callAttributes.MealPlannedAttendeeCount;
				c.actual_attendees_gne__c = callAttributes.MealActualAttendeecount;       
			} else {
				c.meal_expense_gne__c = false;
				c.meal_amount_gne__c = 0;
				c.planned_attendees_gne__c = 0;
				c.actual_attendees_gne__c = 0;
			}             
			
			// lytics only - provided to match Lytics Interaction layout   
			if ( callAttributes.NumOfCustomersPresent != null ) {
				c.customers_gne__c = callAttributes.NumOfCustomersPresent;  
			}
			
			if ( callAttributes.IsComplete != null ) { 
				c.completed_Gne__c = callAttributes.IsComplete;  
			}
			if(c.completed_Gne__c == true){
				c.Interaction_Status_gne__c='Completed';
				if (c.Date_Completed_gne__c == null) {
					c.Date_Completed_gne__c = date.today();
				}
			}
			
			if ( callAttributes.isOtrRequest != null ) { 
				iPhoneApex.isOtrRequestStat = callAttributes.isOtrRequest;
				GNE_SFA2_Interaction_Trigger_Helper.setIsOtrRequest(callAttributes.isOtrRequest);
			}

			if ( callAttributes.UnwillingToMeet != null ) { 
				c.Attempted_Visit_HCP_UnwillingToMeet_gne__c = callAttributes.UnwillingToMeet;  
			}
			
			if ( callAttributes.BusinessSponsor != null ) {
				c.Business_sponsor_gne__c = callAttributes.BusinessSponsor;
			}
			
			if ( callAttributes.MealLocationCity != null ) {
				c.city_gne__c = callAttributes.MealLocationCity;    
			}

			if ( callAttributes.MealLocationState != null ) {
				c.state_gne__c = callAttributes.MealLocationState;    
			}
			
			if ( callAttributes.SpendUser != null ) {
				c.Spend_User_gne__c  = callAttributes.SpendUser;    
			}
			
			if ( callAttributes.Referral != null ) {
			    c.Referral_Assignment_gne__c  = callAttributes.Referral;
			}
			
			if ( callAttributes.ContractedServices != null ) {
				c.Contracted_Services_gne__c  = callAttributes.ContractedServices;    
			}
			
			if(!iPhoneApexUtil.isNull(callAttributes.InteractionLocation)){
				c.Interaction_Location_gne__c = callAttributes.InteractionLocation;
			}

			//for MSL or FRM interactions
			//its an FRM user
			if(callAttributes.isFRM!=null && callAttributes.isFRM){
				c = iPhoneApexUtil.updateFRMInteraction(c, callAttributes);
			} 
			
			if(!iPhoneApexUtil.isNull(callAttributes.AccountPlan)){
				c.Account_Plan_vod__c = callAttributes.AccountPlan;
			}
			
			if(callAttributes.isMSL!=null && callAttributes.isMSL){   
				c = iPhoneApexUtil.updateMSLInteraction(c, callAttributes);
			}
			
			if(callAttributes.NotesCanada != null){
				c.Notes_can_gne__c = callAttributes.NotesCanada;
			}
			
			if(callAttributes.MedicalSupportNotesCanada != null){
				c.Medical_Support_Notes_gne__c = callAttributes.MedicalSupportNotesCanada;
			}

			if(callAttributes.UnsolicitedRequest != null){
				c.Unsolicited_Request_gne__c = callAttributes.UnsolicitedRequest;
			}
			
			if (callAttributes.SalesCollateral != null){
				c.Sales_Collateral_gne__c = callAttributes.SalesCollateral;
			}

			//---------------Starts Get User territory and assign to call--------------------
			//for backward compatibllity, if Territory name is passed then stamp territry_vod with territory name else fetch territory name
			//if existing interaction in sfdc was already stamped with territory name and incoming user no longer belongs to any territory then this code will not update existing territory to blank/null
			if(callAttributes.TerritoryName!=null){
				terrName = callAttributes.TerritoryName;
				c.Territory_vod__c=callAttributes.TerritoryName;
			}else{
				terrName = iPhoneApexUtil.getUserTerritoryId(callOwnerId, getWinnerAccountId(mapMergedAccountIds, callAttributes.Account));
				if(terrName!=null){
					c.Territory_vod__c=terrName;
				}
			}
			//---------------Ends Get User territory and assign to call--------------------
			
			//---------------Meal Opt Out -------------------------------------------
			if(callAttributes.MealOptOut ==null){
				callAttributes.MealOptOut = false;
			}
			
			Boolean isHcpOrAttendeeMealOptOut = callAttributes.MealOptOut;
			if(!isHcpOrAttendeeMealOptOut){
				if(callAttributes.CallAttendeeList!=null){
					for ( CallAttendee attendee : callAttributes.CallAttendeeList ) {
						if(attendee.MealOptOut == null){
							attendee.MealOptOut = false;
						}
						if(attendee.MealOptOut){
							isHcpOrAttendeeMealOptOut = true;
							break;
						}  
					}
				}
			}
			c.HCP_OR_Attendee_Meal_Opt_Out_gne__c = isHcpOrAttendeeMealOptOut;
			c.HCP_Account_Meal_Opt_Out_gne__c = callAttributes.MealOptOut;
			//----------------------------------------------------------------------
			
			Database.UpsertResult upsertResult = Database.Upsert (c);   
			Id id = upsertResult.getId();
			if ( id == null ) {             
				callResponse.RequestIdResponseIdList = new List<RequestIdResponseIdMap>();
				Database.rollback ( savePoint ); 
				Database.Error dbError = upsertResult.getErrors()[0];
				callResponse.ErrorMessage = dbError.getStatusCode().Name() + ' : '  + dbError.getMessage() ; 
				return callResponse;                
			}

			acctAttendee2CallIdMap.put (getWinnerAccountId(mapMergedAccountIds, callAttributes.Account), id);
			
			//check custom settings to enable sample validation by a future call else use synchronous call
			
			Boolean isFutureCall = false;
			ToggleFutureCalls__c toggleFuture = ToggleFutureCalls__c.getValues('iPhoneSampleValidations');
		 	//if toggleFuture.iPhoneApex__c is not defined in target platform
			if(toggleFuture!=null && toggleFuture.iPhoneApex__c!=null){
				isFutureCall = toggleFuture.iPhoneApex__c;
			}

			try{
				 //log validations issues for sample calls only
				if(isExistingCallSampleCall || isIncomingSignatureCall){
					//asynchronous(future) call
					//do not log disbursement issues if its an existing sample call as disbursement issues would have already been logged
					if(!isExistingCallSampleCall){
						if(isFutureCall){
							iPhoneApexUtil.validateInteractionsFuture(callAttributes, (String)Id);
						}
						//synchronous call
						else{ 
							iPhoneApexUtil.ValidateSample(callAttributes, Id);
						}
					}
					
				}
			}catch(Exception ex){
				//do nothing as we do not want the call to fail if there is an error during validation logging
			}
			
			//Request Id to Response Id Map
			callResponse.RequestIdResponseIdList = new List<RequestIdResponseIdMap>();
			RequestIdResponseIdMap requestIdResponseIdItem = new RequestIdResponseIdMap(); 
			requestIdResponseIdItem.RequestId  = callAttributes.RequestId;
			requestIdResponseIdItem.ResponseId = id;
			requestIdResponseIdItem.ObjectType = 'Call2_vod__c';
			requestIdResponseIdItem.ObjectName = [SELECT Name FROM Call2_vod__c WHERE Id = :id].Name;
			callResponse.RequestIdResponseIdList.add ( requestIdResponseIdItem );                         
			
			List<Call2_vod__c> attendeesToUpdate    = new List<Call2_vod__c>();
			
			//attendees if any passed
			if ( callAttributes.CallAttendeeList != null && 
					callAttributes.CallAttendeeList.size() > 0 ) {
				List<Call2_vod__c> attendees    = new List<Call2_vod__c>();
				List<String> inputRequestIdList = new List<String>();

				for ( CallAttendee attendee : callAttributes.CallAttendeeList ){
					
					Call2_vod__c attendeeCall     = new Call2_vod__c();
					Boolean isSampleAttendee = false;
					
					//---------------meal opt out ------------
					attendeeCall.HCP_Attendee_Meal_Opt_Out_gne__c = attendee.MealOptOut;
					
					if(sampledCallRecord!=null){
						//if incoming attendee matches sample attendee by Request Id match then if accouns are same then update 
						if(sampledCallRecord.account_Vod__c!=null && getWinnerAccountId(mapMergedAccountIds, sampledCallRecord.account_Vod__c) == getWinnerAccountId(mapMergedAccountIds, attendee.Attendee)){
							
							attendeeCall = sampledCallRecord;
							if(attendeeCall.Signature_Date_vod__c==null){
								if(callAttributes.SignatureDate!=null)  {
									attendeeCall.Signature_Date_vod__c = callAttributes.SignatureDate;
								}
							}
							if(attendeeCall.Signature_vod__c==null) {
								if(callAttributes.Signature!=null){
									attendeeCall.Signature_vod__c = callAttributes.Signature;
								}
							}
							if(attendeeCall.License_vod__c==null)   {
								if(callAttributes.LicenseNumber!=null){
									attendeeCall.License_vod__c = callAttributes.LicenseNumber;
								}
							}
							if(attendeeCall.Disclaimer_vod__c==null)    {
								if(callAttributes.Disclaimer!=null){
									attendeeCall.Disclaimer_vod__c = callAttributes.Disclaimer;
								}
							}
						}else{
							attendeeCall.call_datetime_vod__c     = callAttributes.CallDateTime;
							attendeeCall.iphone_request_id_gne__c = attendee.RequestId;
							attendeeCall.OwnerId = callOwnerId;
						}
					}else{
						attendeeCall.call_datetime_vod__c     = callAttributes.CallDateTime;
						attendeeCall.iphone_request_id_gne__c = attendee.RequestId;
						attendeeCall.OwnerId = callOwnerId;
					}
					
					//Child Completed Status Synch
					attendeeCall.completed_Gne__c = callAttributes.IsComplete;
					if(attendeeCall.completed_Gne__c == true){
						attendeeCall.Interaction_Status_gne__c='Completed';
						if (attendeeCall.Date_Completed_gne__c == null) {
							attendeeCall.Date_Completed_gne__c = date.today();
						}
					}
					attendeeCall.call_type_vod__c = c.call_type_vod__c;
					attendeeCall.Status_vod__c = c.Status_vod__c;
					attendeeCall.HCP_OR_Attendee_Meal_Opt_Out_gne__c = c.HCP_OR_Attendee_Meal_Opt_Out_gne__c;
					
					
					if ( attendee.CallAttendeeType == AttendeeType.ACCOUNT ||
							attendee.CallAttendeeType == AttendeeType.PERSONACCOUNT ) { 
						attendeeCall.attendee_type_vod__c = 'Person_Account_vod';
						//if a sample attende exists then do not update signature fields else update signature fields for attendee is equal to sampleReciever
						if(sampledCallRecord!=null){
							//if incoming attendee matches sample attendee by Request Id match then if accounts are same then update winner account because as per sample signature law account cannot be updated to a different account but winner account is not different
							if(sampledCallRecord.account_Vod__c!=null && getWinnerAccountId(mapMergedAccountIds, sampledCallRecord.account_Vod__c) == getWinnerAccountId(mapMergedAccountIds, attendee.Attendee)){
								attendeeCall.account_Vod__c = getWinnerAccountId(mapMergedAccountIds, attendee.Attendee);
								//update license designation
								if(objAddress!=null) {
									attendeeCall.License_designation_gne__c = objAddress.Designation_gne__c;
								}
							}else{
								attendeeCall.account_Vod__c =  getWinnerAccountId(mapMergedAccountIds, attendee.Attendee);
								//attendeeCall.Status_vod__c = iPhoneApex.DEFAULT_CALL_STATUS;
							}
						}else{
							if(isIncomingSignatureCall){
								//for callAttributes.CallAttendeeType == AttendeeType.PERSONACCOUNT the license info and samples will always be atached to the attendee call
								if(callAttributes.SampleReceiver!=null && attendee.CallAttendeeType == AttendeeType.PERSONACCOUNT && callAttributes.SampleReceiver==attendee.Attendee){
									attendeeCall.account_Vod__c =  getWinnerAccountId(mapMergedAccountIds, attendee.Attendee);
									attendeeCall.Signature_Date_vod__c = callAttributes.SignatureDate;
									attendeeCall.Signature_vod__c = callAttributes.Signature;
									attendeeCall.License_vod__c = callAttributes.LicenseNumber;
									attendeeCall.Disclaimer_vod__c = callAttributes.Disclaimer;
									attendeeCall.Is_Sampled_Call_vod__c=true;
									//update license designation
									if(objAddress!=null) {
										attendeeCall.License_designation_gne__c = objAddress.Designation_gne__c;
									}
								}else{
									attendeeCall.account_Vod__c =  getWinnerAccountId(mapMergedAccountIds, attendee.Attendee);
								}
							}else{
								attendeeCall.account_Vod__c =  getWinnerAccountId(mapMergedAccountIds, attendee.Attendee);
							}
							//attendeeCall.Status_vod__c = iPhoneApex.DEFAULT_CALL_STATUS;
						}
					} else if ( attendee.CallAttendeeType == AttendeeType.CONTACT ) {
						attendeeCall.contact_vod__c = attendee.Attendee;                       
						attendeeCall.attendee_type_vod__c = 'Contact_vod';
					} else if ( attendee.CallAttendeeType == AttendeeType.USER ) {
						attendeeCall.user_vod__c = attendee.Attendee;                    
						attendeeCall.attendee_type_vod__c = 'User_vod';
					}                              

					attendeeCall.parent_call_vod__c       = id;
					attendeeCall.Parent_address_vod__c = c.Parent_address_vod__c;
					attendeeCall.address_vod__c        = c.address_vod__c; 
					//assign the address fields to call object address fields
					attendeeCall.Address_Line_1_vod__c  = c.Address_Line_1_vod__c;
					attendeeCall.Address_Line_2_vod__c  = c.Address_Line_2_vod__c;
					attendeeCall.City_vod__c            = c.City_vod__c;
					attendeeCall.State_vod__c           = c.State_vod__c;
					attendeeCall.Zip_vod__c             = c.Zip_vod__c;
					attendeeCall.Unsolicited_Request_gne__c = c.Unsolicited_Request_gne__c;
					attendeeCall.Sales_Collateral_gne__c = c.Sales_Collateral_gne__c;
					
					//Veeva populates this field on child interactions everytime a call has a call2_Detail
					attendeeCall.detailed_products_vod__c = c.detailed_products_vod__c;  
					
					if ( callAttributes.BusinessSponsor != null ) {
						attendeeCall.Business_sponsor_gne__c  = callAttributes.BusinessSponsor;
					}
					
					if ( callAttributes.MealLocationCity != null ) {
						attendeeCall.city_gne__c = callAttributes.MealLocationCity;    
					}
					
					if ( callAttributes.MealLocationState != null ) {
						attendeeCall.state_gne__c = callAttributes.MealLocationState;    
					}
					
					if ( callAttributes.MealAmount != null ) {   
						attendeeCall.meal_amount_gne__c = callAttributes.MealAmount;
					}

					if((callAttributes.MealPlannedAttendeeCount != null && callAttributes.MealPlannedAttendeeCount > 0) &&
							(callAttributes.MealActualAttendeeCount != null && callAttributes.MealActualAttendeeCount > 0)) {
						//attendeeCall.detailed_products_vod__c   = c.detailed_products_vod__c;   //moved outside the if clause because Veeva populates this field evrytime a call2_Detailis sent with a product           
						attendeeCall.meal_expense_gne__c = true; 
						//attendeeCall.I_Saw_the_Warning_gne__c = true;                        
						attendeeCall.planned_attendees_gne__c = callAttributes.MealPlannedAttendeeCount;
						attendeeCall.actual_attendees_gne__c = callAttributes.MealActualAttendeecount;       
					} else {
						attendeeCall.meal_expense_gne__c = false;
						attendeeCall.meal_amount_gne__c = 0;
						attendeeCall.planned_attendees_gne__c = 0;
						attendeeCall.actual_attendees_gne__c = 0;
					}               
					
					if(!iPhoneApexUtil.isNull(callAttributes.InteractionLocation)){
						attendeeCall.Interaction_Location_gne__c = callAttributes.InteractionLocation ;
					}

					//to support Interactions by FRM and MSL users
					//its an FRM user{
					if(callAttributes.isFRM!=null && callAttributes.isFRM){
						
						//Interaction type is populated here for FRM users only because updating Reactive for attendees require appropriate iteraction type
						if(callAttributes.InteractionType!=null){
							attendeeCall.Interaction_Type_gne__c = callAttributes.InteractionType;
						}
						attendeeCall = iPhoneApexUtil.updateFRMInteraction(attendeeCall, callAttributes);
					}
					
					if(!iPhoneApexUtil.isNull(callAttributes.AccountPlan)){
						attendeeCall.Account_Plan_vod__c = callAttributes.AccountPlan ;
					}
					
					if(callAttributes.isMSL!=null && callAttributes.isMSL){   
						attendeeCall = iPhoneApexUtil.updateMSLInteraction(attendeeCall, callAttributes);
					}
					
					if(terrName!=null){
						attendeeCall.Territory_vod__c=terrName;
					}
					
					attendeeCall.Last_Device_vod__c= iPhoneApex.DEFAULT_LAST_DEVICE;
					
					//added later(3/16/2010) to address issue of duplicate interactions being created from iphone
					//Sales Reps select the same HCP as attendee also to recod interaction
					//so we are eliminating the attendee if the attendee and the main HCP are same
					//for HCO based call this will always be true
					if(attendee.Attendee!=null && callAttributes.Account!=attendee.Attendee){
						attendees.add (attendeeCall);
						inputRequestIdList.add ( attendee.RequestId );
						//callResponse.ErrorMessage = callResponse.ErrorMessage +  ' ' + cnt + 'id='+ attendeeCall.account_vod__c+ ' p= ' +attendeeCall.Parent_Call_vod__c + ' ';
						//cnt++;
					} 
				}
				
				//insert attendees;
				if(attendees!=null && attendees.size()>0){
					System.debug('YYYYYYYY attendees ='+attendees);
					
					Database.UpsertResult[] saveResultList = Database.Upsert(attendees,true); //attendees with sample signatures ca bu updated for other than signature fields and new attendees may be inserted
					if ( saveResultList[0].getId() != null ) {
						System.debug('YYYYYYYYYYYYYYYYYYYY 3');
						addIdToRequestReponseMap(callResponse.RequestIdResponseIdList, 
						'Call2_vod__c',
						saveResultList,
						inputRequestIdList);
						
						for (Integer i = 0; i < saveResultList.size(); i++ ){           
							Database.UpsertResult saveResult = saveResultList[i];
							Id attendeeCallId  = saveResult.getId();
							//acctAttendee2CallIdMap.put ( callAttributes.CallAttendeeList[i].Attendee,
							//                             attendeeCallId);
							acctAttendee2CallIdMap.put ( attendees[i].account_Vod__c,
							attendeeCallId);
						}                                            
					} else {
						//pending error handling 10/29/2009
					}
				}
				attendeesToUpdate = attendees;
			}

			// call detail 
			if ( callAttributes.callDetailList != null && 
					callAttributes.callDetailList.size() > 0 ) {
				List<String> inputRequestIdList = new List<String>();
				List<Call2_Detail_vod__c> callDetailList = new List<Call2_Detail_vod__c>();    
				for ( CallDetail callDetail : callAttributes.callDetailList ) {
					
					Call2_Detail_vod__c cdetail      = new Call2_Detail_vod__c();
					cdetail.call2_vod__c             = id; 
					cdetail.Product_vod__c           = callDetail.Product;
					cDetail.iphone_request_id_gne__c = callDetail.RequestId;
					if(callDetail.DetailPriority != null){
						cdetail.Detail_Priority_vod__c   = Double.valueOf(callDetail.DetailPriority);
					}
					
					if ( callDetail.TherapeuticArea != null)
					cDetail.Therapeutic_Area_gne__c = callDetail.TherapeuticArea;

					if ( callDetail.DiseaseIndication != null )
					cDetail.Indication_gne__c = callDetail.DiseaseIndication;
					
					callDetailList.add ( cdetail );
					inputRequestIdList.add ( callDetail.RequestId );
				}

				//insert callDetailList;
				Database.SaveResult[] saveResultList = Database.Insert(callDetailList,true);
				if ( saveResultList[0].getId() != null ) {
					addIdToRequestReponseMap(callResponse.RequestIdResponseIdList, 
					'Call2_Detail_vod__c',
					saveResultList,
					inputRequestIdList);
				} else {
					//pending error handling 10/29/2009
				}
			}
			
			// call discussion
			if ( callAttributes.callDiscussionList != null && 
					callAttributes.callDiscussionList.size() > 0 ) {
				List<Call2_Discussion_vod__C> callDiscussionList = new List<Call2_Discussion_vod__C>();    
				List<String> inputRequestIdList                  = new List<String>();
				for ( CallDiscussion callDiscussion : callAttributes.callDiscussionList ) {
					Call2_Discussion_vod__C cDiscussion    = new Call2_Discussion_vod__C();
					cDiscussion.call2_vod__c               = id;
					if(!iPhoneApexUtil.isNull(callDiscussion.Product)){
						cDiscussion.Product_vod__c             = callDiscussion.Product;
					}
					
					if(callDiscussion.DetailPriority != null){
						cDiscussion.Detail_Priority_gne__c   = Double.valueOf(callDiscussion.DetailPriority);
					} 
					
					cDiscussion.Account_vod__c = getWinnerAccountId(mapMergedAccountIds, callAttributes.Account);

					if ( callDiscussion.ProductStrategy != null && callDiscussion.ProductStrategy.length() > 0 ) { 
						cDiscussion.Product_Strategy_vod__c    = callDiscussion.ProductStrategy;
					}                        
					
					if ( callDiscussion.ProductTactic != null && callDiscussion.ProductTactic.length() > 0 ) {  
						cDiscussion.Product_Tactic_vod__c = iPhoneApexUtil.processProductTactic(callDiscussion.ProductTactic,callAttributes);
					}
					
					if ( callDiscussion.AccountTactic != null && callDiscussion.AccountTactic.length() > 0 ) {  
						cDiscussion.Account_Tactic_vod__c = callDiscussion.AccountTactic;
					}                        
					
					if ( callDiscussion.Reaction != null && callDiscussion.Reaction.length() > 0 ) {                         
						cDiscussion.Reaction_gne__c = callDiscussion.Reaction;
					}
					
					if ( callDiscussion.NbrPatientsImpacted != null ) {                         
						cDiscussion.Number_of_Patients_Impacted_gne__c = callDiscussion.NbrPatientsImpacted;
					}
					//new OTR functionality added by Dominik Wasilewski 5-11-2011
					if(callDiscussion.Curriculum != null && callDiscussion.Curriculum.length() > 0 ){
						cDiscussion.Event_Curriculum_gne__c = callDiscussion.Curriculum;
					}
					if(callDiscussion.Activity != null){
						cDiscussion.Activity_gne__c = callDiscussion.Activity;
					}
					if(callDiscussion.EventRelated != null){
						cDiscussion.Event_gne__c = callDiscussion.EventRelated;
					}
					
					if(callDiscussion.ActivityTimeSpent !=null){
						cDiscussion.Activity_Time_Spent_gne__c = callDiscussion.ActivityTimeSpent;
					}
					
					//to support Interactions by MSL users
					if(callAttributes.isMSL!=null && callAttributes.isMSL){
						if(callDiscussion.Answer!=null) {
							cDiscussion.Answer_gne__c = iPhoneApexUtil.truncateString(callDiscussion.Answer);
						}
						if(callDiscussion.Question!=null)   {
							cDiscussion.Question_gne__c = iPhoneApexUtil.truncateString(callDiscussion.Question);
						}
						if(callDiscussion.Topic!=null)  {
							cDiscussion.Topic_gne__c = callDiscussion.Topic;
						}
						if(callDiscussion.CurrentIssue!=null) {
							cDiscussion.Current_Issue_gne__c = callDiscussion.CurrentIssue; //dependant picklist is SFDC. dependant on Product(zvod_Product_Map_vod__c)
						}
						
						if(!iPhoneApexUtil.isNull(callDiscussion.Molecule)){
							if(callDiscussion.Molecule.equalsIgnoreCase('N/A')){
								cDiscussion.Molecule_gne__c = 'N/A';
								//insert Non-Product/Non-Molecule to product if molecule is N/A
								if(iPhoneApexUtil.isNull(callDiscussion.Product))   {
									if(mapProducts!=null)  {
										if(mapProducts.size()>0) {
											for(Product_vod__c pr : mapProducts.values()) {
												if(pr.Name == NonProduct_NonMolecule) {
													cDiscussion.Product_vod__c = pr.Id;
													break;
												}
											}
											
										}
									}
								}
							}else{
								if(mapProducts!=null) {
									if(mapProducts.size()>0){
										if(mapProducts.containsKey(callDiscussion.Molecule)) {
											cDiscussion.Molecule_gne__c = mapProducts.get(callDiscussion.Molecule).Name; //dependant picklist is SFDC. dependant on Product(zvod_Product_Map_vod__c)
											if(iPhoneApexUtil.isNull(callDiscussion.Product))   {
												cDiscussion.Product_vod__c = callDiscussion.Molecule;
											}
										}
									}
								}
							}
						}
					}
					
					cDiscussion.iphone_request_id_gne__c   = callDiscussion.RequestId;
					callDiscussionList.add ( cDiscussion );
					inputRequestIdList.add(callDiscussion.RequestId);                    
				}
				//insert callDiscussionList;
				Database.SaveResult[] saveResultList = Database.Insert(callDiscussionList,true);  
				if ( saveResultList[0].getId() != null ) {
					addIdToRequestReponseMap(callResponse.RequestIdResponseIdList, 'Call2_Discussion_vod__c', saveResultList, inputRequestIdList);
				} else {
					//pending error handling 10/29/2009
				}
			}
			//new OTR functionality [add Marketing Key Messages to Call] added 5-11-2011 by Dominik Wasilewski
			if(callAttributes.callKeyMessageList != null && callAttributes.callKeyMessageList.size()>0){
				List<Call2_Key_Message_vod__c> callKeyMessageList = new List<Call2_Key_Message_vod__c>();
				List<String> inputRequestIdList = new List<String>();
				for(CallKeyMessage callKeyMsg : callAttributes.callKeyMessageList){
					Call2_Key_Message_vod__c cMessage = new Call2_Key_Message_vod__c();
					cMessage.Call2_vod__c = id;
					system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>Key Message= '+callKeyMsg.Product);   
					if(callKeyMsg.Product != null){
						cMessage.Product_vod__c = callKeyMsg.Product;
					} 
					system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Winner Account=' +getWinnerAccountId(mapMergedAccountIds, callAttributes.Account));
					cMessage.Account_vod__c = getWinnerAccountId(mapMergedAccountIds, callAttributes.Account);
					system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Key Message=' +callKeyMsg.KeyMessage);
					if(callKeyMsg.KeyMessage != null){
						cMessage.Key_Message_vod__c = callKeyMsg.KeyMessage;
					}
					if(callKeyMsg.Reaction != null){
						cMessage.Reaction_vod__c = callKeyMsg.Reaction;
					}
					cMessage.iPhone_Request_Id__c = callKeyMsg.RequestId;
					callKeyMessageList.add(cMessage);
					inputRequestIdList.add(callKeyMsg.RequestId);
					//insert callKeyMessageList;
					system.debug('--------------------------------------'+callKeyMessageList);
					Database.UpsertResult[] upsertResultList = Database.Upsert(callKeyMessageList,true);
					if ( upsertResultList[0].getId() != null ){
						addIdToRequestReponseMap(callResponse.RequestIdResponseIdList, 
						'Call2_Key_Message_vod__c',
						upsertResultList,
						inputRequestIdList);
					}
				}
			}

			// call samples  
			if ( callAttributes.callSampleList != null && 
					callAttributes.callSampleList.size() > 0 ){
				List<Call2_sample_vod__C> callSampleList = new List<Call2_sample_vod__C>();    
				List<String> inputRequestIdList          = new List<String>();
				
				if(isExistingCallSampleCall){
					//samples exist in sfdc for an update call
					if(callSampProdList!=null && callSampProdList.size()>0){
						for(Call2_Sample_vod__c callS : callSampProdList){
							if(sampleProductMap.get(callS.Product_vod__c)!=null && sampleProductMap.get(callS.Product_vod__c).Product_Type_vod__c == 'Samples'){
								callS.Account_vod__c = getWinnerAccountId(mapMergedAccountIds, callS.Account_vod__c);
								callSampleList.add(callS);
								inputRequestIdList.add(callS.iphone_request_id_gne__c);
								
							}
						}
					}
				}
				
				for ( CallSample callSample : callAttributes.callSampleList ){
					Call2_Sample_vod__c cSample        = new Call2_Sample_vod__c();
					if(isExistingCallSampleCall){
						//if incoming call sample has a lot no then ignore the sample as no more samples can be attached to an existing sample call
						if(sampleProductMap!=null && sampleProductMap.size()>0){
							//there could be an incoming sample with a lot number but of product_type other than Sample
							if(sampleProductMap.get(callSample.Product)!=null && sampleProductMap.get(callSample.Product).Product_Type_vod__c == 'Samples'){
								continue;
							}
						}
						if(callSample.LotNo!=null){
							continue;
						}
					}

					cSample.Product_vod__c             = callSample.Product;
					cSample.Call_Date_vod__c           = Date.newInstance( 
					callAttributes.CallDateTime.year(),
					callAttributes.CallDateTime.month(),
					callAttributes.CallDateTime.day());
					cSample.Account_vod__c             = getWinnerAccountId(mapMergedAccountIds, callSample.Account);
					cSample.quantity_vod__c            = callSample.Quantity;
					cSample.Lot_vod__c                 = callSample.LotNo;
					cSample.iphone_request_id_gne__c   = callSample.RequestId; 
					cSample.call2_vod__c               = acctAttendee2CallIdMap.get(getWinnerAccountId(mapMergedAccountIds, callSample.Account));
					callSampleList.add ( cSample );
					inputRequestIdList.add(callSample.RequestId); 
				}

				//insert callSampleList;
				if(callSampleList!=null && callSampleList.size()>0){
					System.debug('JL::.. upserting sample list: '+callSampleList);
					Database.UpsertResult[] saveResultList = Database.Upsert(callSampleList, true);
					if ( saveResultList[0].getId() != null ) {
						addIdToRequestReponseMap(callResponse.RequestIdResponseIdList, 
						'Call2_Sample_vod__c',
						saveResultList,
						inputRequestIdList);
					} else {
						//pending error handling 10/29/2009
					}
					
					// START [OSOWIECB, OTR-1341] Update calls to generate sample transactions (if needed).
					// This will be done in call after update trigger (VOD_CALL2_AFTER_UPDATE_TRIGGER).
					Map<Id,Call2_vod__c> attsToUpdate = new Map<Id,Call2_vod__c>();
					for(Call2_Sample_vod__c cSample : callSampleList) {
						attsToUpdate.put(cSample.call2_vod__c, new Call2_vod__c(id=cSample.call2_vod__c));
					}
					// Turn on sample transaction creation trigger
					//Inactivated due to Veeva removal
					//VOD_CALL2_HEADER_CLASS.setUpdateSampleTransactionAction(true);
					//VOD_CALL2_HEADER_CLASS.setInsertAction (false);
					//VOD_CALL2_HEADER_CLASS.setUpdateAction (false);
					update attsToUpdate.values();
					// Turn off sample transaction creation trigger
					//VOD_CALL2_HEADER_CLASS.setUpdateSampleTransactionAction(false);
					// END [OSOWIECB, OTR-1341] 
				}
			}
			
			/* START OLD SAMPLE TRANSACTION UPDATE ([OSOWIECB,OTR-1341]) - We don't need this block anymore, 
			because sample transaction will be created in previous block.
			
			//if sample call and not already sampled then update main call(this will automatically create sample transaction of type disbursement)
			if(!isExistingCallSampleCall){
				if(callAttributes.CallAttendeeType == AttendeeType.ACCOUNT){
					if(attendeesToUpdate!=null && attendeesToUpdate.size()>0){
						Call2_vod__c attToUpdate ;
						for(Call2_vod__c att: attendeesToUpdate){
							if(att.Is_Sampled_Call_vod__c){
								attToUpdate = new Call2_vod__c(id=att.id);
							}
						}
						if(attToUpdate!=null){
							VOD_CALL2_HEADER_CLASS.setInsertAction (false);
							//try{
							update attToUpdate;
							//}catch(Exception ex){
							//  //do nothing as we do not the cal to fail if a sample reciept canot be created. 
							//  //The call might fail if the sample lot number does not exist in SFDC
							//}
						}
					}
					
				} 
				else if(callAttributes.CallAttendeeType == AttendeeType.PERSONACCOUNT){
					//set this veeva flag to false the first time a sample call interaction is created
					//veeva functionality does not creates sample transaction when an interactiojn is inserte but ceates when it is updated
					//so to create sample transaction when an interaction is created we need to set this flag to false
					//An update to an interaction need not be called for an existing sample interaction because the sample transactio would already have been created, but this is updated here just in case the first time sample transactions are not created!
					VOD_CALL2_HEADER_CLASS.setInsertAction (false); 
					Call2_vod__c updCall = new Call2_vod__c(id=id);
					//try{
					upsert updCall;
					//}catch(Exception ex){
					//  //do nothing as we do not the cal to fail if a sample reciept canot be created. 
					//  //The call might fail if the sample lot number does not exist in SFDC
					//}
					
					
				}     
			} END OLD SAMPLE TRANSACTION UPDATE ([OSOWIECB,OTR-1341])*/

			// guruk: Log Missing Sample Transaction entries      
			// March 2012: http://jira.intranet.roche.com/jira/browse/SFA-130       
			try {
				iPhoneApex_Config_gne__c iphoneApexConfig = iPhoneApex_Config_gne__c.getInstance();                        
				if ( iphoneApexConfig.Log_Missing_Sample_Transaction_gne__c ) {
					List<Sample_Transaction_vod__c> sampleTransacionVodList = new List<Sample_Transaction_vod__c>(); 
					List<Missing_Sample_Transaction_Log_gne__c> missingSampleTransactionLogList = new List<Missing_Sample_Transaction_Log_gne__c>();                         
					List<String> callIdList = new List<String> { id } ;
					Integer logItems = iPhoneApex_SampleTransactionLogUtility.getSampleTransactionInfo
					(callIdList, sampleTransacionVodList,missingSampleTransactionLogList);                    
					if ( logItems > 0 ) {
						upsert missingSampleTransactionLogList Missing_Sample_Transaction_Log_gne__c.external_id_gne__c;                        
						// insert Sample_Transaction_vod__c to support compliance
						if ( iphoneApexConfig.Insert_Missing_Sample_Transaction_gne__c ) {
							insert sampleTransacionVodList;
						}                                                 
					}
				}            
			} catch (Exception e) {
				System.debug(e.getMessage());
			}             
			// guruk: Log Missing Sample Transaction entries - end
		} 
		catch (Exception e){
			callResponse.ErrorMessage = e.getMessage();
			callResponse.RequestIdResponseIdList = new List<RequestIdResponseIdMap>();
			Database.rollback ( savePoint ); 
			iPhoneBase.handleException(e, UserInfo.getUserId(), (callAttributes.isOtrRequest==true ? 'OTR' : null),
					'Record Interaction', iPhoneApex.CallAttributes.class, callAttributes, '[iPhoneApex] Error while creating or updating interaction');
		}
		callResponse.EndTime = DateTime.now();
		return callResponse;
	}
	
	Webservice static Response createMedcomRequest (MedcomAttributes medcomAttributes){
		Response response                              = new Response();
		response.RequestIdResponseIdList               = new List<RequestIdResponseIdMap>();
		RequestIdResponseIdMap requestIdResponseIdItem = new RequestIdResponseIdMap(); 
		requestIdResponseIdItem.RequestId              = medcomAttributes.RequestId;
		requestIdResponseIdItem.ObjectType             = 'Medical_Communication_gne__c';
		response.RequestIdResponseIdList.add ( requestIdResponseIdItem );                         
		
		try {            
			List<String> acctIds = new List<String>();
			if(medcomAttributes.Account!=null){
				acctIds.add(medcomAttributes.Account);
			}
			Map<String, String> mapMergedAccountIds = iPhoneApexUtil.findMergedAccounts( acctIds );
			
			List<Medical_Communication_gne__c> medcomList  
			= [SELECT id FROM Medical_Communication_gne__c 
			WHERE iphone_request_id_gne__c = :medcomAttributes.RequestId
			order by createddate desc];
			
			// check for existence          
			if ( medcomList != null && medcomList.size() > 0  ) {
				requestIdResponseIdItem.ResponseId = medcomList[0].Id;
			} else {
				
				Boolean bNotifyForEducation = false;
				
				if (medcomAttributes.NotifyForEducation != null)
				
				bNotifyForEducation = medcomAttributes.NotifyForEducation;
				
				// create new medical communication object
				Medical_Communication_gne__c medcom =  new Medical_Communication_gne__c();            
				medcom.iphone_request_id_gne__c     =  medcomAttributes.RequestId;
				medcom.account_gne__c               =  getWinnerAccountId(mapMergedAccountIds, medcomAttributes.Account);
				
				//medcom.product_gne__c               =  medcomAttributes.Product; 
				if(!iPhoneApexUtil.isNull(medcomAttributes.Product))   {
					Product_vod__c objProduct = [SELECT id, name, Product_Type_vod__c, Detail_Product_Subtype_Code_gne__c FROM Product_vod__c WHERE id =:medcomAttributes.Product];
					if(objProduct!=null) {
						if(!iPhoneApexUtil.isNull(objProduct.Detail_Product_Subtype_Code_gne__c) && objProduct.Detail_Product_Subtype_Code_gne__c=='Molecule')  {
							medcom.Molecule_gne__c = medcomAttributes.Product;
						}
						else {
							medcom.product_gne__c = medcomAttributes.Product;
						}
					}
				}
				
				medcom.medical_question_gne__c      =  medcomAttributes.MedicalQuestion;
				medcom.priority_gne__c              =  medcomAttributes.Priority;
				medcom.Follow_up_method_gne__c      =  medcomAttributes.FollowUpMethod;             
				medcom.Notify_for_education_gne__c  =  bNotifyForEducation;
				
				medcom.address_line_1_gne__c        =  medcomAttributes.StreetAddress;
				medcom.address_line_2_gne__c        =  medcomAttributes.Suite;
				medcom.address_line_3_gne__c        =  medcomAttributes.DepartmentName;
				medcom.address_line_4_gne__c        =  medcomAttributes.AttnCareOf;
				medcom.city_gne__c                  =  medcomAttributes.City;
				medcom.state_gne__c                 =  medcomAttributes.State;
				medcom.zip_gne__c                   =  medcomAttributes.Zip;
				medcom.zip_4_gne__c                 =  medcomAttributes.zipPlus4;
				
				medcom.email_gne__c                 =  medcomAttributes.Email;
				medcom.phone_gne__c                 =  medcomAttributes.Phone;
				medcom.fax_gne__c                   =  medcomAttributes.Fax;
				if(medcomAttributes.LanguageOfPreferenceCan != null){
					medcom.Language_of_Preference_can_gne__c = medcomAttributes.LanguageOfPreferenceCan;
				} 
				if(medcomAttributes.ProvinceCan != null){
					medcom.Province_can_gne__c = medcomAttributes.ProvinceCan;
				}
				if(medcomAttributes.PostalCodeCan != null){
					medcom.Postal_Code_can_gne__c= medcomAttributes.PostalCodeCan;
				}
				Database.SaveResult saveResult      = Database.Insert (medcom); 
				
				if ( saveResult.getId() == null ) {
					Database.Error dbError          = saveResult.getErrors()[0];
					response.ErrorMessage           = dbError.getStatusCode().Name() 
					+ '/' +  
					dbError.getMessage();        
				} else {
					requestIdResponseIdItem.ResponseId = saveResult.getId();
				}                                       
			}             
			
		} catch (Exception e) {
			response.ErrorMessage =  e.getMessage();
			iPhoneBase.handleException(e, 'Create MedComm Request', iPhoneApex.MedcomAttributes.class, medcomAttributes, '[iPhoneApex] Error while creating MedCom');
		}
		
		response.EndTime = DateTime.now();        
		return response; 
	}       

	Webservice static Response updateAddress (AddressAttributes addressAttributes){
		Response response  = new Response();
		try {               
			if ( addressAttributes.AddressId != null &&
					addressAttributes.AttributeValuepairList != null &&  
					addressAttributes.AttributeValuePairList.size() > 0 ) {                     

				List<String> addrIds = new List<String>();
				if(addressAttributes.AddressId!=null){
					addrIds.add(addressAttributes.AddressId);
				}
				Map<String, String> mapMergedAddressIds = iPhoneApexUtil.findMergedAddresses(addrIds);
				
				Address_vod__c addr = [SELECT id, Phone_vod__c,Phone_1_Ext_gne__c,
				Phone_2_vod__c,Phone_2_Ext_gne__c,
				Fax_vod__c, Fax_2_vod__c 
				FROM address_vod__c 
				WHERE id = :  getWinnerAddressId(mapMergedAddressIds, addressAttributes.AddressId) ];
				
				// need to generalize this assignment to support more 
				// attributes
				for ( AttributeValuePair attributeValuePair : addressAttributes.AttributeValuePairList ) {                                               
					if ( attributeValuePair.attributeType == AddressAttributeType.PHONE ) {
						addr.phone_vod__c = attributeValuePair.value;
					} else if ( attributeValuePair.attributeType == AddressAttributeType.PHONEEXT ) {
						addr.phone_1_ext_gne__c = attributeValuePair.value;
					} else if ( attributeValuePair.attributeType == AddressAttributeType.PHONE2 ) {
						addr.phone_2_vod__c = attributeValuePair.value;                    
					} else if ( attributeValuePair.attributeType == AddressAttributeType.PHONE2EXT ) {
						addr.phone_2_ext_gne__c = attributeValuePair.value;
					} else if ( attributeValuePair.attributeType == AddressAttributeType.FAX ) {
						addr.fax_vod__c = attributeValuePair.value;
					} else if ( attributeValuePair.attributeType == AddressAttributeType.FAX2 ) {
						addr.fax_2_vod__c = attributeValuePair.value;
					} else if ( attributeValuePair.attributeType == AddressAttributeType.POSTALCODE ) {
						addr.Postal_Code_can_gne__c= attributeValuePair.value;
					} else if ( attributeValuePair.attributeType == AddressAttributeType.PROVINCE ) {
						addr.Province_can_gne__c= attributeValuePair.value;
					} else if ( attributeValuePair.attributeType == AddressAttributeType.ORGANIZATION) {
						addr.Org_Name_can_gne__c = attributeValuePair.value;
					}              
				}
				update addr;
			}
		} catch (Exception e) {
			response.ErrorMessage =  e.getMessage();
			
		}
		response.EndTime = DateTime.now();        
		return response; 
	}       

	static String updateContactAffiliation(String ToAccount, String FromContact, String AffiliationType, String AffiliationRole, String requestId) {

		String affiliationId = null;
		List<Affiliation_vod__c> affiliationList = 
		[ SELECT id, iphone_request_id_gne__c, 
		from_account_vod__c, to_contact_vod__c,
		affiliation_type_gne__c, role_vod__c, role_opposite_vod__c,
		(SELECT id, affiliation_type_gne__c,role_vod__c, role_opposite_vod__c,
		from_contact_vod__c, to_account_vod__c, 
		iphone_request_id_gne__c 
		FROM affiliation_vod__r) 
		FROM Affiliation_vod__c 
		WHERE     parent_vod__c         = True
		and to_account_vod__c     = :ToAccount 
		and from_contact_vod__c   = :FromContact
		and createdById           = :UserInfo.getUserId()
		order by LastModifiedDate desc Limit 1];

		if ( affiliationList.size() > 0 ) {
			
			affiliationList[0].affiliation_type_gne__c  = AffiliationType;
			affiliationList[0].role_vod__c              = AffiliationRole;
			affiliationList[0].role_opposite_vod__c     = AffiliationRole;
			
			Affiliation_vod__c childAffiliation         = affiliationList[0].affiliation_vod__r;
			
			childAffiliation.affiliation_type_gne__c    = AffiliationType;
			childAffiliation.role_vod__c                = AffiliationRole;
			childAffiliation.role_opposite_vod__c       = AffiliationRole;
			childAffiliation.iphone_request_id_gne__c   = requestId;
			
			affiliationId                               = childAffiliation.Id;
			
			affiliationList.add (childAffiliation);
			update affiliationList;
		}
		return affiliationId;
	}                                           
	
	Webservice static Response updateOrCreateContact (ContactAttributes contactAttributes){
		System.debug('##### ContactAttributes === ' + contactAttributes);
		Response response                              = new Response();
		
		response.RequestIdResponseIdList               = new List<RequestIdResponseIdMap>();
		RequestIdResponseIdMap requestIdResponseIdItem = new RequestIdResponseIdMap(); 
		requestIdResponseIdItem.RequestId              = contactAttributes.RequestId; 
		requestIdResponseIdItem.ObjectType             = 'Contact';
		response.RequestIdResponseIdList.add ( requestIdResponseIdItem );                         

		try {  
			
			List<String> acctIds = new List<String>();
			if(contactAttributes.Account!=null){
				acctIds.add(contactAttributes.Account);
			}
			Map<String, String> mapMergedAccountIds = iPhoneApexUtil.findMergedAccounts( acctIds );
			
			Contact contact           =  null;
			List<Contact> contactList =  [  SELECT 
			id, 
			Iphone_Request_Id_gne__c,
			FirstName,
			LastName, 
			Middle_Name_gne__c,
			MailingStreet, 
			MailingCity, 
			MailingState,
			MailingCountry, 
			MailingPostalCode, 
			Zip_4_gne__c,
			Phone, 
			Ext_gne__c, 
			Secondary_Phone_gne__c, 
			Secondary_Ext_gne__c,
			Fax,
			Email, 
			Secondary_Email_gne__c,
			Type_gne__c
			FROM 
			Contact
			WHERE 
			Id =: contactAttributes.Id 
			OR 
			(     Iphone_Request_Id_gne__c =: contactAttributes.RequestId 
			AND Iphone_Request_Id_gne__c != null
			)
			];
			
			if ( contactList != null && contactList.size() > 0 ) {
				contact = contactList[0];
			}
			else 
			contact = new Contact();
			
			contact.iphone_request_id_gne__c        = contactAttributes.RequestId;
			
			if (contact.FirstName != contactAttributes.FirstName){
				contact.FirstName                   = contactAttributes.FirstName;
			}
			if (contact.LastName != contactAttributes.LastName){
				contact.LastName                    = contactAttributes.LastName;  
			}
			contact.Middle_Name_gne__c              = contactAttributes.MiddleName;

			contact.MailingStreet                   = contactAttributes.StreetAddress;
			contact.MailingCity                     = contactAttributes.City;
			contact.MailingState                    = contactAttributes.State;
			contact.MailingCountry                  = contactAttributes.Country;
			contact.MailingPostalCode               = contactAttributes.Zipcode; 
			contact.Zip_4_gne__c                    = contactAttributes.Zip4;
			
			contact.Phone                           = contactAttributes.Phone;
			contact.Ext_gne__c                      = contactAttributes.PhoneExt;
			contact.Secondary_Phone_gne__c          = contactAttributes.Phone2;
			contact.Secondary_Ext_gne__c            = contactAttributes.Phone2Ext;
			contact.Fax                             = contactAttributes.Fax;
			contact.Email                           = contactAttributes.Email;
			contact.Secondary_Email_gne__c          = contactAttributes.Email2;

			contact.Type_gne__c                     = contactAttributes.Role;                
			
			if ( contact.Id != null ) {
				update contact;
				requestIdResponseIdItem.ResponseId=contact.Id;
				
				if(contactAttributes.affiliationId != null) {
					Affiliation_vod__c aff = [SELECT id, role_vod__c, role_opposite_vod__c FROM  Affiliation_vod__c WHERE id =: contactAttributes.affiliationId];
					aff.role_vod__c                = contactAttributes.Role;
					aff.role_opposite_vod__c       = contactAttributes.Role;
					update aff;                  
				}
				
			} else {
				contact.AccountId              =   getWinnerAccountId(mapMergedAccountIds, contactAttributes.Account);
				Database.SaveResult saveResult = Database.Insert(contact); 
				
				if ( saveResult.getId() != null ) {                 

					requestIdResponseIdItem.ResponseId = saveResult.getId();

					String affiliationId =
					updateContactAffiliation(getWinnerAccountId(mapMergedAccountIds, contactAttributes.Account),
					(String) saveResult.getId(), 
					iPhoneApex.DEFAULT_CONTACT_AFFILIATION_TYPE,
					contactAttributes.Role,
					contactAttributes.AffiliationRequestId);
					
					RequestIdResponseIdMap affRequestIdResponseIdItem = new RequestIdResponseIdMap(); 
					affRequestIdResponseIdItem.RequestId              = contactAttributes.AffiliationRequestId; 
					affRequestIdResponseIdItem.ObjectType             = 'Affiliation_vod__c';
					affRequestIdResponseIdItem.ResponseId             = affiliationId;
					response.RequestIdResponseIdList.add ( affRequestIdResponseIdItem );                         

					
				} else {
					Database.Error dbError          = saveResult.getErrors()[0];
					response.ErrorMessage           = dbError.getStatusCode().Name() 
					+ '/' +  
					dbError.getMessage();        
				}
			}
			
		} catch (Exception e) {
			response.ErrorMessage =  e.getMessage();
		}
		
		response.EndTime = DateTime.now();        
		return response;         
	}       
	
	Webservice static Response addOrRemoveUserPreference (UserPreferenceAttributes 
	userPreferenceAttributes) {
		Response response = new Response();
		try {     

			List<String> acctIds = new List<String>();
			if(userPreferenceAttributes.OnObjectId!=null){
				acctIds.add(userPreferenceAttributes.OnObjectId);
			}
			Map<String, String> mapMergedAccountIds =  iPhoneApexUtil.findMergedAccounts( acctIds ) ;
			
			List<String> addrIds = new List<String>();
			Map<String, String> mapMergedAddressIds;
			if(userPreferenceAttributes.WithObjectId!=null && userPreferenceAttributes.preferenceType!=null && userPreferenceAttributes.preferenceType==PreferenceType.PREFERREDADDRESS){
				addrIds.add(userPreferenceAttributes.WithObjectId);
				mapMergedAddressIds = iPhoneApexUtil.findMergedAddresses(addrIds);
			}

			if ( userPreferenceAttributes.OnObjectId     == null || 
					userPreferenceAttributes.preferenceType == null ) {
				response.ErrorMessage = 'Object Id, Preference Type are required input parameters -  ' + 
				' please provide missing parameter values.' ;                           
				return response;
			}                               

			if ( userPreferenceAttributes.preferenceType == PreferenceType.FAVORITE && 
					userPreferenceAttributes.MyFavorite == null ) { 
				response.ErrorMessage = 'MyFavorite is null for PreferenceType.FAVORITE - ' +   
				' please provide assign MyFavorite parameter value.' ;                           
				return response;
			}                                
			
			String externalId = UserInfo.getUserId() + '_' + 
			getWinnerAccountId(mapMergedAccountIds, userPreferenceAttributes.OnObjectId) + '_' + 
			userPreferenceAttributes.preferenceType.Name() ; 
			
			User_Preference_gne__c userPreference = null; 
			List<User_Preference_gne__c> userPreferenceList 
			=  [SELECT id,  
			Type_gne__c, OnObject_Id_gne__c, 
			My_favorite_gne__c, 
			WithObject_Id_gne__c,
			User_gne__c
			FROM User_Preference_gne__c
			WHERE external_id_gne__c = :externalId ];

			if ( userPreferenceList != null && userPreferenceList.size() > 0 ) {  
				userPreference = userPreferenceList[0];
			} else {                
				userPreference                            = new User_Preference_gne__c();
			}                
			
			//userPreference.OnObject_id_gne__c       = userPreferenceAttributes.OnObjectId;
			if(userPreferenceAttributes.WithObjectId!=null && userPreferenceAttributes.preferenceType!=null && userPreferenceAttributes.preferenceType==PreferenceType.PREFERREDADDRESS){
				userPreference.WithObject_Id_gne__c   = getWinnerAddressId(mapMergedAddressIds, userPreferenceAttributes.WithObjectId); 
			}
			else{
				userPreference.WithObject_Id_gne__c=userPreferenceAttributes.WithObjectId;
			}
			userPreference.OnObject_Type_gne__c       = userPreferenceAttributes.OnObjectType.Name();
			userPreference.Type_gne__c                = userPreferenceAttributes.preferenceType.Name();
			userPreference.User_gne__c                = UserInfo.getUserId();
			if( userPreferenceAttributes.OnObjectType==ObjectType.ACCOUNT){
				userPreference.OnObject_id_gne__c         = getWinnerAccountId(mapMergedAccountIds, userPreferenceAttributes.OnObjectId);
				externalId = UserInfo.getUserId() + '_' + 
				getWinnerAccountId(mapMergedAccountIds, userPreferenceAttributes.OnObjectId) + '_' + 
				userPreferenceAttributes.preferenceType.Name() ; 
			}
			else{
				userPreference.OnObject_id_gne__c         = userPreferenceAttributes.OnObjectId;
			}
			userPreference.External_Id_gne__c         = externalId;                                                                  
			
			// delete preference when account/contact favorite is false/unset 
			if ( userPreference.Id != null && 
					userPreferenceAttributes.preferenceType == PreferenceType.FAVORITE && 
					userPreferenceAttributes.MyFavorite != null && 
					userPreferenceAttributes.MyFavorite == FALSE) {
				delete userPreference; 
			} else if ( userPreference.Id == null && 
					userPreferenceAttributes.preferenceType == PreferenceType.FAVORITE && 
					userPreferenceAttributes.MyFavorite != null && 
					userPreferenceAttributes.MyFavorite == FALSE ) {
				// no operation as no favorite record present
			} else {            
				
				if ( userPreferenceAttributes.MyFavorite != null && 
						userPreferenceAttributes.MyFavorite ) 
				userPreference.My_Favorite_gne__C = True;
				
				Database.UpsertResult upsertResult = Database.Upsert(userPreference,
				User_Preference_gne__c.External_Id_gne__c); 
				
				if ( upsertResult.getId() == null ) {                 
					Database.Error dbError          = upsertResult.getErrors()[0];
					response.ErrorMessage           = dbError.getStatusCode().Name() 
					+ '/' +  
					dbError.getMessage();        
				}
			}
		} catch (Exception e) {
			response.ErrorMessage =  e.getMessage();
		}
		response.EndTime = DateTime.now();        
		return response; 
	}       

	// get call attributes for infrequent user
	WebService static CallAttributes getCallAttributes (String callId) {
		CallAttributes callAttributes       = null; 
		callAttributes = iPhoneApexUtil.getCallAttributes(callId);
		return callAttributes;            
	}

	Webservice static Response updateOrCreateCallForIFU (CallAttributes callAttributes){

		String callOwnerId;
		if(callAttributes.OwnerId!=null){
			callOwnerId = callAttributes.OwnerId;
		}
		else{
			callOwnerId=UserInfo.getUserId();
		}
		String requestId = DateTime.Now().format ('yyyyMMddHHmmssS');
		String userAlias = [SELECT alias FROM user WHERE Id = :callOwnerId].alias;

		if ( callAttributes == null ) 
		return null;
		
		if ( callAttributes.RequestId == null ) 
		callAttributes.RequestId = REQUESTID_PREFIX_FOR_MAIN_CALL + userAlias + requestId + '0'; 

		if ( callAttributes.callAttendeeList != null ) { 
			for ( Integer i = 0; i < callAttributes.CallAttendeeList.size(); i++ ) {
				if ( callAttributes.CallAttendeeList[i].RequestId == null ) 
				callAttributes.CallAttendeeList[i].RequestId = REQUESTID_PREFIX_FOR_ATTENDEE + userAlias + requestId + (i+1) ; 
				
			}
		}
		
		if ( callAttributes.callDetailList != null ) {
			for ( Integer i = 0; i < callAttributes.callDetailList.size(); i++ ) {
				if ( callAttributes.callDetailList[i].RequestId == null ) 
				callAttributes.callDetailList[i].RequestId = REQUESTID_PREFIX_FOR_DETAIL + userAlias + requestId + i ; 
			}
		}

		if ( callAttributes.callDiscussionList != null ) {
			for ( Integer i = 0; i < callAttributes.callDiscussionList.size(); i++ ) {
				if ( callAttributes.callDiscussionList[i].RequestId == null ) 
				callAttributes.callDiscussionList[i].RequestId = REQUESTID_PREFIX_FOR_DISCUSSIOn + userAlias + requestId + i ; 
			}
		}
		
		if ( callAttributes.callSampleList != null ) { 
			for ( Integer i = 0; i < callAttributes.callSampleList.size(); i++ ) {
				if ( callAttributes.callSampleList[i].RequestId == null ) 
				callAttributes.callSampleList[i].RequestId = REQUESTID_PREFIX_FOR_SAMPLE + userAlias + requestId + i ; 
			}
		}
		
		return updateOrCreateCall(callAttributes); 
	}

	Webservice static Boolean checkUserForImmunoTerr(String userId){
		return GlobalUtils.isUserInTerr(UserInfo.getUserId(),System.Label.GNE_MedAffairs_Immunology_Terr);
	}
	
	Webservice static Boolean checkCallIsPersonAccount(String callId) {
		Boolean result = [SELECT Account_vod__r.isPersonAccount FROM Call2_vod__c WHERE Id = :callId].Account_vod__r.isPersonAccount;      
		return result;
	}

	Webservice static Response createReferral (ReferralInfo RefInfo){
		Response callResponse = new Response();
		String strErrorMessage = '';
		
		List<String> acctIds = new List<String>();
		if(RefInfo.AccountId!=null){
			acctIds.add(RefInfo.AccountId);
		}
		Map<String, String> mapMergedAccountIds = iPhoneApexUtil.findMergedAccounts( acctIds );
		
		GNE_Med_iPhone_CreateReferral.ReferralInfo refferalInfo = new GNE_Med_iPhone_CreateReferral.ReferralInfo();
		GNE_Med_iPhone_CreateReferral.Response createRefResponse = new GNE_Med_iPhone_CreateReferral.Response();
		
		refferalInfo.RequestId                  = RefInfo.RequestId;
		refferalInfo.AccountId                  = getWinnerAccountId(mapMergedAccountIds, RefInfo.AccountId);
		refferalInfo.AddressId                  = RefInfo.AddressId;
		refferalInfo.MedicalQuestion            = RefInfo.MedicalQuestion;
		refferalInfo.FollowupMethod             = RefInfo.FollowupMethod;
		refferalInfo.ProductId                  = RefInfo.ProductId;
		refferalInfo.MoleculeId                 = RefInfo.MoleculeId;
		refferalInfo.TA_SubTAId                 = RefInfo.TA_SubTAId;
		refferalInfo.RequestedCompletionDate    = RefInfo.RequestedCompletionDate;
		refferalInfo.Priority                   = RefInfo.Priority;
		refferalInfo.RequestedById              = RefInfo.RequestedById;
		refferalInfo.isMedComm                  = RefInfo.isMedComm;
		refferalInfo.UserId                     = RefInfo.UserId;
		refferalInfo.AssignedToId               = RefInfo.AssignedToId;
		refferalInfo.phone						= RefInfo.customPhone;
		
		createRefResponse = GNE_Med_iPhone_CreateReferral.createReferral(refferalInfo);
		
		if(createRefResponse.ErrorMessage != null && createRefResponse.ErrorMessage!=''){
			strErrorMessage = createRefResponse.ErrorMessage;
			System.debug('strErrorMessage : ' + strErrorMessage);
			
			callResponse.ErrorMessage = strErrorMessage;
			callResponse.RequestIdResponseIdList = new List<RequestIdResponseIdMap>();
			callResponse.EndTime = createRefResponse.EndTime;
		}else{
			strErrorMessage='';
			
			callResponse.RequestIdResponseIdList            = new List<RequestIdResponseIdMap>();
			RequestIdResponseIdMap requestIdResponseIdItem  = new RequestIdResponseIdMap(); 
			requestIdResponseIdItem.RequestId               = RefInfo.RequestId; 
			requestIdResponseIdItem.ObjectType              = 'Medical_Communication_gne__c';
			requestIdResponseIdItem.ResponseId              = createRefResponse.getResponseReferral().Id;
			callResponse.RequestIdResponseIdList.add ( requestIdResponseIdItem );   

			callResponse.EndTime = createRefResponse.EndTime;
			
			System.debug('ResponseHere : ' + String.valueOf(callResponse));
			GNE_Referral_Utils.isMedicalReferral = false;
		}
		return callResponse;  
	}
}