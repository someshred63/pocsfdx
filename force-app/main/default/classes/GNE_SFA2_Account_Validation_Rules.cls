/************************************************************
*  @author: Bartosz Osowiecki, Roche
*  Date: 2012-12-19
*  Description: Helper class for GNE_SFA2_Account_Trigger
*  Test class: GNE_SFA2_Account_Trigger_Test
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public without sharing class GNE_SFA2_Account_Validation_Rules{

	public static final String RECORD_TYPE_GNE_NETWORK = 'GNE-Network';
	public static final String RECORD_TYPE_HOSPITAL_DEPARTMENT = 'Hospital Department_vod';
	public static final String RECORD_TYPE_BUSINESS_PROFESSIONAL = 'Business_Professional_vod';
	public static final String RECORD_TYPE_CANADA_HCO = 'GNE-SFA-Roche_Canada';
	public static final String RECORD_TYPE_CANADA_HCP = 'HCP Canada';
	public static final String RCANADA_SFA_MANAGER_PROFILE_NAME = 'RCanada-SFA-Manager';
	public static final String RCANADA_SFA_TS_PROFILE_NAME = 'RCanada-SFA-TS';
	public static final String RCANADA_SFA_RAMA_PROFILE_NAME = 'RCanada-SFA-RAMA';
	private static final Id RECORD_TYPE_ID_FRM_HCO = Schema.SObjectType.Account.getRecordTypeInfosByName().get('HCO').getRecordTypeId();
	private static Map<String, User> externalId2User;	
	private static String frmAccountTypesAsStr;

	public static final Set<String> CANADA_HCO_ACCOUNT_TYPES_NOT_FOR_EDIT = new Set<String> {
		'Government', 
		'Hospital', 
		'Medical Association', 
		'Nursing Home', 
		'Retail', 
		'Pharmacy', 
		'University', 
		'Wholesaler'
	};
	
	public static final Set<String> CANADA_HCP_ACCOUNT_TYPES_NOT_FOR_EDIT = new Set<String> {
		'Physician',
		'Pharmacist',
		'Nurse'
	};

	public static final Set<String> CANADA_HCO_EDIT_FIELDS = new Set<String>{
		String.valueOf(Account.Preferred_Name_vod__c).toUpperCase(),
		String.valueOf(Account.Secondary_Phone_gne__c).toUpperCase(),
		String.valueOf(Account.Beds__c).toUpperCase(),
		String.valueOf(Account.Number_of_Positions_can_gne__c).toUpperCase(),
		String.valueOf(Account.Infusion_Center_gne__c).toUpperCase(),
		String.valueOf(Account.New_Patient_Starts_can_gne__c).toUpperCase(),
		String.valueOf(Account.Chemo_Center_can_gne__c).toUpperCase(),
		String.valueOf(Account.Company_Target_gne__c).toUpperCase(),
		String.valueOf(Account.Main_Address_gne__c).toUpperCase(),
		String.valueOf(Account.REST_AccInfo_Fields_LastModDate_gne__c).toUpperCase(),
		String.valueOf(Account.iPhone_Fields_LastModifiedDate_gne__c).toUpperCase(),
		String.valueOf(Account.LastModifiedById).toUpperCase(),
		String.valueOf(Account.LastModifiedDate).toUpperCase(),
		String.valueOf(Account.SystemModstamp).toUpperCase(),
		String.valueOf(Account.Primary_Point_Of_Contact_gne__c).toUpperCase()
	};
	
	public static final Set<String> CANADA_HCP_EDIT_FIELDS = new Set<String>{
		String.valueOf(Account.Cell_Phone_gne__c).toUpperCase(),
		String.valueOf(Account.PersonEmail).toUpperCase(),
		String.valueOf(Account.Company_Target_gne__c).toUpperCase(),
		String.valueOf(Account.Preferred_Contact_Method_gne__c).toUpperCase(),
		String.valueOf(Account.Main_Address_gne__c).toUpperCase(),
		String.valueOf(Account.REST_AccInfo_Fields_LastModDate_gne__c).toUpperCase(),
		String.valueOf(Account.iPhone_Fields_LastModifiedDate_gne__c).toUpperCase(),
		String.valueOf(Account.LastModifiedById).toUpperCase(),
		String.valueOf(Account.LastModifiedDate).toUpperCase(),
		String.valueOf(Account.SystemModstamp).toUpperCase(),
		String.valueOf(Account.Primary_Point_Of_Contact_gne__c).toUpperCase()
	};

	public static final Map<String, Set<String>> CANADA_ADDITIONAL_EDITABLE_FIELDS_BY_PROFILE = new Map<String, Set<String>>{
			RCANADA_SFA_MANAGER_PROFILE_NAME => new Set<String> {
				String.valueOf(Account.Tier_Level_gne__c).toUpperCase(),
				String.valueOf(Account.HCP_Stakeholder_Type_gne__c).toUpperCase(),
				String.valueOf(Account.Primary_Point_Of_Contact_gne__c).toUpperCase(),
				String.valueOf(Account.Rep_Specialty_can_gne__c).toUpperCase()
			},
			RCANADA_SFA_TS_PROFILE_NAME => new Set<String> {
					String.valueOf(Account.Rep_Specialty_can_gne__c).toUpperCase()
			}
	};

	public static final Map<String, Set<String>> CANADA_ADDITIONAL_EDITABLE_FIELDS_FOR_NON_STEWARDED_BY_PROFILE = new Map<String, Set<String>>{
			RCANADA_SFA_MANAGER_PROFILE_NAME => new Set<String> {
					String.valueOf(Account.FirstName).toUpperCase(),
					String.valueOf(Account.LastName).toUpperCase(),
					String.valueOf(Account.Account_Type_gne__c).toUpperCase(),
					String.valueOf(Account.Middle_vod__c).toUpperCase(),
					String.valueOf(Account.Specialties_can_gne__c).toUpperCase(),
					String.valueOf(Account.Gender_vod__c).toUpperCase(),
					String.valueOf(Account.Rep_Specialty_can_gne__c).toUpperCase(),
					String.valueOf(Account.Language_of_Preference_can_gne__c).toUpperCase(),
					String.valueOf(Account.Primary_Point_Of_Contact_gne__c).toUpperCase(),
					String.valueOf(Account.Tier_Level_gne__c).toUpperCase(),
					String.valueOf(Account.HCP_Stakeholder_Type_gne__c).toUpperCase(),
					String.valueOf(Account.Cell_Phone_gne__c).toUpperCase(),
					String.valueOf(Account.Preferred_Contact_Method_gne__c).toUpperCase(),
					String.valueOf(Account.PersonEmail).toUpperCase()
			},
			RCANADA_SFA_TS_PROFILE_NAME => new Set<String> {
					String.valueOf(Account.FirstName).toUpperCase(),
					String.valueOf(Account.LastName).toUpperCase(),
					String.valueOf(Account.Account_Type_gne__c).toUpperCase(),
					String.valueOf(Account.Middle_vod__c).toUpperCase(),
					String.valueOf(Account.Specialties_can_gne__c).toUpperCase(),
					String.valueOf(Account.Gender_vod__c).toUpperCase(),
					String.valueOf(Account.Rep_Specialty_can_gne__c).toUpperCase(),
					String.valueOf(Account.Language_of_Preference_can_gne__c).toUpperCase(),
					String.valueOf(Account.Primary_Point_Of_Contact_gne__c).toUpperCase(),
					String.valueOf(Account.Tier_Level_gne__c).toUpperCase(),
					String.valueOf(Account.HCP_Stakeholder_Type_gne__c).toUpperCase(),
					String.valueOf(Account.Cell_Phone_gne__c).toUpperCase(),
					String.valueOf(Account.Preferred_Contact_Method_gne__c).toUpperCase(),
					String.valueOf(Account.PersonEmail).toUpperCase()
			},
			RCANADA_SFA_RAMA_PROFILE_NAME => new Set<String> {
					String.valueOf(Account.FirstName).toUpperCase(),
					String.valueOf(Account.LastName).toUpperCase(),
					String.valueOf(Account.Account_Type_gne__c).toUpperCase(),
					String.valueOf(Account.Middle_vod__c).toUpperCase(),
					String.valueOf(Account.Specialties_can_gne__c).toUpperCase(),
					String.valueOf(Account.Gender_vod__c).toUpperCase(),
					String.valueOf(Account.Rep_Specialty_can_gne__c).toUpperCase(),
					String.valueOf(Account.Language_of_Preference_can_gne__c).toUpperCase(),
					String.valueOf(Account.Primary_Point_Of_Contact_gne__c).toUpperCase(),
					String.valueOf(Account.Tier_Level_gne__c).toUpperCase(),
					String.valueOf(Account.HCP_Stakeholder_Type_gne__c).toUpperCase(),
					String.valueOf(Account.Cell_Phone_gne__c).toUpperCase(),
					String.valueOf(Account.Preferred_Contact_Method_gne__c).toUpperCase(),
					String.valueOf(Account.PersonEmail).toUpperCase()
			}
	};
	
	private static Boolean validateNameChanged(Account accOld, Account accNew) {
		Boolean validationFailed = false;
		String profileName = GNE_SFA2_Account_Trigger_Helper.getCurrentUserProfileName();
		String recordTypeName = accNew.Record_Type_Name_gne__c;
		Boolean hasCanadaProfile = GNE_SFA2_Account_Trigger_Helper.userHasCanadaProfile();
		Boolean hasActemraProfile = GNE_SFA2_Account_Trigger_Helper.userHasActemraProfile();
		
		Set<String> excludedProfileNames = GNE_SFA2_Account_Trigger_Helper.getExludedProfilesForNameChangeValidation();
		
		if(!excludedProfileNames.contains(profileName.toUpperCase()) && !hasCanadaProfile && 
			(accNew.Name != accOld.Name || accNew.FirstName != accOld.FirstName || accNew.LastName != accOld.LastName)) {
			if(recordTypeName!=RECORD_TYPE_GNE_NETWORK && recordTypeName!=RECORD_TYPE_HOSPITAL_DEPARTMENT) {
				validationFailed = true;
			} else if(recordTypeName==RECORD_TYPE_GNE_NETWORK && hasActemraProfile) {
				validationFailed = true;
			}
		}
		
		if(validationFailed) {
			accNew.addError(System.Label.Account_Name_Cannot_Be_Modified);
		}
		return validationFailed;
	}
	
	private static Boolean validateBusinessProfessionalIsPersonAccount(Account accNew) {
		Boolean validationFailed = false;
		String recordTypeName = accNew.Record_Type_Name_gne__c;
		
		if(recordTypeName == RECORD_TYPE_BUSINESS_PROFESSIONAL && accNew.Business_Professional_Person_vod__c!=null) {
			Account bpp = GNE_SFA2_Account_Trigger_Helper.getCachedAccount(accNew.Business_Professional_Person_vod__c);
			validationFailed = !bpp.IsPersonAccount;
		}
		if(validationFailed) {
			accNew.Business_Professional_Person_vod__c.addError(System.Label.Account_BPP_Must_Be_Person);
		}
		
		return validationFailed;
	}
	
	private static Boolean validatePrimaryParentIsPersonAccount(Account accNew) {
		Boolean validationFailed = false;
		
		if(accNew.Primary_Parent_vod__c!=null) {
			Account pp = GNE_SFA2_Account_Trigger_Helper.getCachedAccount(accNew.Primary_Parent_vod__c);
			validationFailed = pp.IsPersonAccount;
		}
		
		if(validationFailed) {
			accNew.Primary_Parent_vod__c.addError(System.Label.Account_Primary_Parent_Must_Be_HCO);
		}
		return validationFailed;
	}
	
	private static Boolean validateCanadaHCO(Account accOld, Account accNew) {
		Boolean validationFailed = false;
		
		String profileName = GNE_SFA2_Account_Trigger_Helper.getCurrentUserProfileName();
		String recordTypeName = accNew.Record_Type_Name_gne__c;
		Set<String> includedProfileNames = GNE_SFA2_Account_Trigger_Helper.getIncludedProfilesForCanadaChangeValidation();
		
		if(includedProfileNames.contains(profileName.toUpperCase()) && recordTypeName == RECORD_TYPE_CANADA_HCO &&
			CANADA_HCO_ACCOUNT_TYPES_NOT_FOR_EDIT.contains(accOld.Account_Type_gne__c) &&
			(accOld.Name != accNew.Name || accOld.Account_Type_gne__c != accNew.Account_Type_gne__c || accOld.Phone != accNew.Phone)) {
			
			validationFailed = true;
			accNew.addError(System.Label.Account_CAN_HCO_Cannot_Be_Modified);
		}
		return validationFailed;
	}
	
	private static Boolean validateCanadaHCP(Account accOld, Account accNew) {
		Boolean validationFailed = false;
		
		String profileName = GNE_SFA2_Account_Trigger_Helper.getCurrentUserProfileName();
		String recordTypeName = accNew.Record_Type_Name_gne__c;
		Set<String> includedProfileNames = GNE_SFA2_Account_Trigger_Helper.getIncludedProfilesForCanadaChangeValidation();

		if(includedProfileNames.contains(profileName.toUpperCase()) && 
				recordTypeName == RECORD_TYPE_CANADA_HCP &&
				CANADA_HCP_ACCOUNT_TYPES_NOT_FOR_EDIT.contains(accOld.Account_Type_gne__c) &&
				(accOld.FirstName != accNew.FirstName || 
					accOld.LastName != accNew.LastName || 
					accOld.Middle_vod__c != accNew.Middle_vod__c || 
					accOld.Gender_vod__c != accNew.Gender_vod__c || 
					accOld.Language_of_Preference_can_gne__c  != accNew.Language_of_Preference_can_gne__c  ||
					accOld.Account_Type_gne__c != accNew.Account_Type_gne__c || 
					accOld.Specialties_gne__c != accNew.Specialties_gne__c)) {
			
			validationFailed = true;
			accNew.addError(System.Label.Account_CAN_HCP_Cannot_Be_Modified);
		}

		if(GNE_SFA2_Util.isCanadaRAMA() && recordTypeName == RECORD_TYPE_CANADA_HCP) {
			if(!isAccountRoleChangeValid(accOld, accNew)) {
				accNew.addError(Label.Account_CAN_HCP_Cannot_Be_Modified);
				validationFailed = true;
			}
		}
		return validationFailed;
	}
	
	private static Boolean isAccountRoleChangeValid(Account accOld, Account accNew) {
		if(accOld.Account_Type_RAMA_gne__c == 'Physician' && accNew.Account_Type_RAMA_gne__c != 'Physician') {
			accNew.addError(Label.Account_CAN_HCP_Cannot_Be_Modified);
			GNE_SFA2_Account_Trigger_Helper.setFailedValidation(accNew.Id);
			return false;
		}
		if (accOld.Account_Type_RAMA_gne__c == 'Pharmacist' && accNew.Account_Type_RAMA_gne__c != 'Pharmacist') {
			accNew.addError(Label.Account_CAN_HCP_Cannot_Be_Modified);
			GNE_SFA2_Account_Trigger_Helper.setFailedValidation(accNew.Id);
			return false;
		}
		return true;
	}

	// Error Handeling - Inserting Error Records in Error Log Table
	public static void InsertErrorLog(Exception Error, string accOldId, string accNewId){
		List<Error_Log_gne__c> errorLogList = new List<Error_Log_gne__c>(); 
		try{
			errorLogList.add(new Error_Log_gne__c(Object_Name__c = 'Account', 
			Error_Level_gne__c = 'High',
			Snippet_Name__c = 'Account Trigger - Validation Rules', 
			Code_Type__c = 'Apex Class', 
			Error_Description__c = GlobalUtils.getExceptionDescription(Error) + ':Old Id:'+accOldId+ ':New Id'+accNewId, 
			User_Name__c = UserInfo.getUserName()));
			
			if(errorLogList.size() > 0){
				insert errorLogList;
			}
		}catch(exception ex){
			system.debug('ERROR WHILE EXC LOG METHOD.............' + ex.getMessage());
		}
		finally{
			errorLogList.clear();
		}
	} 
	
	/**
		This code addresses the Precriber (Account) record validation
		for Cases for Business Rules BR-Vendor_Data-03 and BR-Vendor_Data-04
		
		Created by: Marc Friedman
		Last Modified: 01/24/2009
	**/
	private static void CM_validateCasesForVendorData(List<Account> triggerOld, List<Account> triggerNew) {
		String profileName = GNE_SFA2_Account_Trigger_Helper.getCurrentUserProfileName();
		Map<Id,Account> triggerNewMap = new Map<Id,Account>(triggerNew);
		
		// Get Nutropin / Vendor Cases where the Account is the Prescriber
		for (Case c : [SELECT Case_Treating_Physician_gne__c,Address_gne__r.Phone_vod__c, Address_gne__r.Fax_vod__c 
					FROM Case 
					WHERE Case_Treating_Physician_gne__c IN :triggerNewMap.keySet() 
					AND Product_gne__c = 'Nutropin'  AND Case_Being_Worked_By_gne__c = 'EXTERNAL - MCKESSON' 
					AND (Function_Performed_gne__c = 'Benefits Investigation' OR Function_Performed_gne__c = 'Appeals Follow-up')]) {
			
			Account accNew = triggerNewMap.get(c.Case_Treating_Physician_gne__c);
			
			if(GNE_SFA2_Account_Trigger_Helper.getFailedValidation(accNew.Id)){
				continue;
			}
			
			if (profileName.StartsWith('GNE-CM-') && (c.Address_gne__r.Phone_vod__c == null || accNew.FirstName == null || accNew.LastName == null || c.Address_gne__r.Fax_vod__c == null)) {
				accNew.addError('Accounts referenced as Prescribers from one or more Nutropin Cases being worked by McKesson for benefits investigation or appeals follow-up must have a First Name, Last Name, Phone and Fax.');
				GNE_SFA2_Account_Trigger_Helper.setFailedValidation(accNew.Id);
			}
		}
		
		//Sharmas 04/21/2010: Defect ID : 11369. 
		//Code added to update the Username associated with Account when Physician_Portal_Username_gne__c is updated.
		Set<String> variable = new Set<String>{'Account_Access_Summary_Editable_Group'};
		Set<id> PersonContactIdSet = new Set<id>();
		List<Environment_Variables__c> env_var = new List<Environment_Variables__c>();
		Map<String,String> Account_Access_Summary_Editable_Group = new map<String,String>();
		Map<String,String> portalEmailMap = new Map<String,String>();
		
		try{
			//Sharmas 04/21/2010: Get Public Group Name
			env_var = GNE_CM_Environment_variable.get_env_variable(variable);   
			
			for (Integer j = 0; j < env_var.size(); j++){
				if (env_var[j].Key__c == 'Account_Access_Summary_Editable_Group'){
					Account_Access_Summary_Editable_Group.put(env_var[j].Value__c, env_var[j].Value__c);
				}
			}
			//Sharmas 04/21/2010: SOQL to determine whether the current User is in Public Group.
			List<GroupMember> GroupMember_list = [SELECT id FROM GroupMember WHERE Group.Name in: Account_Access_Summary_Editable_Group.keySet() AND UserOrGroupId =: userInfo.getUserId()];
			for(Integer i = 0; i< triggerNew.size(); i++){
				Account accNew = triggerNew[i];
				Account accOld = triggerOld[i];
				
				if(GNE_SFA2_Account_Trigger_Helper.getFailedValidation(accNew.Id)){
					continue;
				}
				
				//Sharmas 04/21/2010: Only Public Group member can update Physician_Portal_Username_gne__c field.
				if(GroupMember_list.size() == 0 && accOld.Physician_Portal_Username_gne__c != accNew.Physician_Portal_Username_gne__c){
					accNew.Physician_Portal_Username_gne__c.addError('Field is not editable.');
					GNE_SFA2_Account_Trigger_Helper.setFailedValidation(accNew.Id);
				}else if(GroupMember_list.size() > 0 && accNew.PersonContactId != null && accOld.Physician_Portal_Username_gne__c != accNew.Physician_Portal_Username_gne__c){
					//Sharmas 04/30: Defect 11484. To update username only if portal username is not null.
					if(accNew.Physician_Portal_Username_gne__c != null){
						portalEmailMap.put(accNew.PersonContactId,accNew.Physician_Portal_Username_gne__c);
					}else{
						PersonContactIdSet.add(accNew.PersonContactId);
					}
				}
			}
			
			if(portalEmailMap.size() > 0){
				//Sharmas 04/21/2010: Call asynchronous method to update the associated User record.
				GNE_CM_Update_Account_Portal_Username.updateUser(portalEmailMap);
			}
		}catch(Exception ex){
			InsertErrorLog(ex,'','');
		}
		
		//Sharmas 04/30: Defect 11484. Code added to throw error if user is active and portal username is set to blank.
		if(PersonContactIdSet.size() > 0){
			//Get list of active users whose corresponding Portal username is set to blank.
			List<User> activeUserList = [SELECT id, isActive, ContactId,contact.AccountId FROM User	WHERE isActive = true AND ContactId in : PersonContactIdSet];
			Set<id> userContactIdSet = new Set<id>();
			if(activeUserList.size() > 0){
				for(User u:activeUserList){
					//Set of Account ids from user records created.
					userContactIdSet.add(u.contact.AccountId);
				}
				
				for(Account accNew : triggerNew){              
					if(GNE_SFA2_Account_Trigger_Helper.getFailedValidation(accNew.Id)){
						continue;
					}
					
					//if above set created contains account id, then throw the error. Record with blank username will not be updated for active users
					if(userContactIdSet.contains(accNew.id)){
						accNew.Physician_Portal_Username_gne__c.addError('Physician Portal Username should not be Blank.');
						GNE_SFA2_Account_Trigger_Helper.setFailedValidation(accNew.Id);
					}//end if 
				}//end Account for loop
				activeUserList.clear();
				userContactIdSet.clear();
			}//end activeUserList 
		}
	}
	
	/**
		@author: Lukasz Bieniawski
		Description: Canada validation - if MRM Lock is turned On and if this is not territory aligning transaction process
		system doesn't allow to update Account record. There is only exceptions if user tries to modify: 
		HCP record in fields: Cell Phone, Email, Preferred Contact. 
		HCO record in fields: Preferred Name, Secondary Phone, # of Beds, # of Positions, Infusion Center, New Patient Starts, Chemo Center
		Update is possible in that case.
		This code was previously implemented in VRs (SFA_Canada_HCP_Account_Edit and SFA_Canada_HCO_Account_Edit),
		but additional implementation of excluded fields exception rule has more complicated logic and
		couldn't be done in VRs.    
		Modification History
	**/
	private static void validateCanadaMRMLock(List<Account> triggerOld, List<Account> triggerNew) {
		// Check if this is not territory aligning process
		Canada_Account_Config_gne__c config = Canada_Account_Config_gne__c.getInstance();
		System.debug('config.Align_To_Territory_Transaction_gne__c: ' + config.Align_To_Territory_Transaction_gne__c);
		if (config.Align_To_Territory_Transaction_gne__c){
			return ;
		}
		
		Boolean isCanadaMRMCheckNeeded = false;
		for(Account accNew : triggerNew) {
			if(GNE_SFA2_Account_Trigger_Helper.getFailedValidation(accNew.Id)){
				continue;
			}
			
			if(accNew.MRM_Lock_can_gne__c == true) {
				isCanadaMRMCheckNeeded = true;
				break;
			}
		}
		
		String profileName = GNE_SFA2_Util.getCurrentUserProfileName();
		Set<String> includedProfileNames = GNE_SFA2_Account_Trigger_Helper.getIncludedProfilesForCanadaChangeValidation();
		
		if(isCanadaMRMCheckNeeded && includedProfileNames.contains(profileName.toUpperCase())) {
			
			Set<String> canadaRecordTypes = new Set<String>{RECORD_TYPE_CANADA_HCO, RECORD_TYPE_CANADA_HCP};
			Map<String, Schema.SObjectField> accountFieldsMap  = Schema.SobjectType.Account.fields.getMap();
			Set<String>accountFields = new Set<String>();
			
			for(String accountField: accountFieldsMap.keySet()){
				Schema.DescribeFieldResult fieldDescribe = accountFieldsMap.get(accountField).getDescribe();
				if(!fieldDescribe.isAutoNumber() && !fieldDescribe.isCalculated()){
					accountFields.add(accountField);		
				}
			}
			
			Integer idx = 0;
			for(Account accNew : triggerNew) {
				if(GNE_SFA2_Account_Trigger_Helper.getFailedValidation(accNew.Id)){
					continue;
				}
				
				Account accOld = triggerOld[idx++];
				Boolean isHco = !accNew.IsPersonAccount;
				
				if(accNew.MRM_Lock_can_gne__c != true || !canadaRecordTypes.contains(accNew.Record_Type_Name_gne__c)) {
					continue;
				}
				
				Set<String> changedFieldNames = new Set<String>();
				
				for (String fieldName : accountFields) {
					try {
						if(accNew.get(fieldName) != accOld.get(fieldName)){
							system.debug(fieldName);
							changedFieldNames.add(fieldName.toUpperCase());
						}
					} catch(Exception e) {
						system.debug('Cannot access field \'' + fieldName + '\'' );
						//InsertErrorLog(e,fieldName,accNew.Id);
					}
				}
				
				for (String fieldName : isHco ? CANADA_HCO_EDIT_FIELDS : CANADA_HCP_EDIT_FIELDS) {
					changedFieldNames.remove(fieldName);
				}
				system.debug(changedFieldNames);
				if(CANADA_ADDITIONAL_EDITABLE_FIELDS_BY_PROFILE.containsKey(profileName)){
					changedFieldNames.removeAll(CANADA_ADDITIONAL_EDITABLE_FIELDS_BY_PROFILE.get(profileName));
				}
				if(!CANADA_HCP_ACCOUNT_TYPES_NOT_FOR_EDIT.contains(accOld.Account_Type_gne__c) && CANADA_ADDITIONAL_EDITABLE_FIELDS_FOR_NON_STEWARDED_BY_PROFILE.containsKey(profileName)) {
					changedFieldNames.removeAll(CANADA_ADDITIONAL_EDITABLE_FIELDS_FOR_NON_STEWARDED_BY_PROFILE.get(profileName));
				}
				if(!changedFieldNames.isEmpty()) {
					accNew.addError(System.Label.Account_CAN_MRM_Lock_Cannot_Be_Modified);
					GNE_SFA2_Account_Trigger_Helper.setFailedValidation(accNew.Id);
				}
			}
		}
	}
	
	
	private static void cacheRelatedAccounts(List<Account> triggerNew) {
		Set<Id> relatedAccIds = new Set<Id>();
		for(Account acc : triggerNew) {
			if(acc.Business_Professional_Person_vod__c!=null) {
				relatedAccIds.add(acc.Business_Professional_Person_vod__c);
			}
			if(acc.Primary_Parent_vod__c!=null) {
				relatedAccIds.add(acc.Primary_Parent_vod__c);
			}
		}
		if(!relatedAccIds.isEmpty()) {
			GNE_SFA2_Account_Trigger_Helper.cacheAccounts(new Map<Id,Account>([SELECT ID, IsPersonAccount FROM Account WHERE Id IN :relatedAccIds]));
		}
	}
	
    private static void frmValidation(Account newAcc, Account oldAcc) {
        if (newAcc.RecordTypeId == RECORD_TYPE_ID_FRM_HCO) {
            frmCheckOwner(newAcc, oldAcc);
            frmCheckAccountType(newAcc, oldAcc);
        }
    }

    private static void frmCheckOwner(Account newAcc, Account oldAcc) {
        if (newAcc.OwnerId == oldAcc.OwnerId || prepareDefaultOwnerMap().isEmpty()) {
            return;
        }
        
        String userId = frmPrepareDefaultOwner(newAcc);
        if(userId != null && newAcc.OwnerId != userId){
            newAcc.OwnerId.addError(Label.ERROR_FRM_ACCOUNT_OWNER);
        }
    }

    private static void frmCheckAccountType(Account newAcc, Account oldAcc) {
        if (newAcc.Account_Type_gne__c == oldAcc.Account_Type_gne__c) {
            return;
        }
        Set<String> allowedAccountTypes = new Set<String>(GNE_SFA2_Account_Trigger_Helper.getFrmOwnerConfiguration().keySet());

        if (!allowedAccountTypes.isEmpty() && !allowedAccountTypes.contains(newAcc.Account_Type_gne__c)) {
            String errMsg = String.format(Label.ERROR_FRM_ACCOUNT_TYPE, new String[]{getFrmAccountTypesAsStr(allowedAccountTypes)});
            newAcc.Account_Type_gne__c.addError(errMsg);
        }
    }
    
    private static String getFrmAccountTypesAsStr(Set<String> allowedAccountTypes) {
        if(frmAccountTypesAsStr == null ){
            frmAccountTypesAsStr = '';
            for(String s :allowedAccountTypes){
                frmAccountTypesAsStr += (frmAccountTypesAsStr == '' ? '' : ', ' ) + s; 
            }
        }
        
        return frmAccountTypesAsStr;
    }
    
    private static String frmPrepareDefaultOwner(Account newAcc) {
        String userId;
        if(newAcc.Account_Type_gne__c == null) {
            userId = externalId2User.values().get(0).Id;
        } else {
            String externalId = GNE_SFA2_Account_Trigger_Helper.frmOwnerConfiguration.get(newAcc.Account_Type_gne__c) != null ? 
                GNE_SFA2_Account_Trigger_Helper.frmOwnerConfiguration.get(newAcc.Account_Type_gne__c).Account_Owner_gne__c : null;
            if (externalId != null) {
                User defOwner = externalId2User.get(externalId) != null ? externalId2User.get(externalId) : null;
                if (defOwner != null) {
                    userId = defOwner.Id;
                }
            }
        }
        
        return userId;
    }
    
    private static Map<String, User> prepareDefaultOwnerMap() {
        if(externalId2User == null) {
            externalId2User = GNE_SFA2_Account_Trigger_Helper.prepareDefaultOwnerMap();
        }
        
        return externalId2User;
    }

	private static void runValidationRulesOnUpdate(List<Account> triggerOld, List<Account> triggerNew) {
		cacheRelatedAccounts(triggerNew);
		
		Integer size = triggerNew.size();
		for (Integer i = 0;i<size;i++) {
			Account accNew = triggerNew[i];
			Account accOld = triggerOld[i];
			frmValidation(accNew, accOld);
			
			Boolean validationFailed = validateNameChanged(accOld, accNew) || validateBusinessProfessionalIsPersonAccount(accNew)|| validatePrimaryParentIsPersonAccount(accNew)
										|| validateCanadaHCO(accOld, accNew) || validateCanadaHCP(accOld, accNew);
			
			if(validationFailed) {
				GNE_SFA2_Account_Trigger_Helper.setFailedValidation(accNew.Id);
			}
		}
	}
	
	private static void runValidationRulesOnInsert(List<Account> triggerNew) {
		cacheRelatedAccounts(triggerNew);
		for (Account accNew : triggerNew) {
			Boolean validationFailed = validateBusinessProfessionalIsPersonAccount(accNew) || validatePrimaryParentIsPersonAccount(accNew);
			if(validationFailed) {
				GNE_SFA2_Account_Trigger_Helper.setFailedValidation(accNew.Id);
			}
		}
	}
	
	private static void runSavedCallsValidationOnDelete(List<Account> triggerOld) {
		GNE_SFA2_Account_Trigger_Helper.cacheAccountChildren(new Map<Id,Account>(triggerOld).keySet());
		
		for(Account accOld : triggerOld) {
			if(accOld.masterRecordId==null) {
				Account cachedAcc = GNE_SFA2_Account_Trigger_Helper.getCachedAccount(accOld.Id);
				if (cachedAcc.Call2_vod__r.size() > 0) {
					accOld.addError(System.Label.Account_With_Saved_Calls_Cannot_Be_Deleted);
					GNE_SFA2_Account_Trigger_Helper.setFailedValidation(accOld.Id);
				}
			}
		}
	}	
	
	public static void onBeforeUpdate(List<Account> triggerOld, List<Account> triggerNew) {
		// run only when not in merge mode
		if(!GNE_SFA2_Util.isMergeMode()){
			runValidationRulesOnUpdate(triggerOld, triggerNew);
			validateCanadaMRMLock(triggerOld, triggerNew);
		}
		// .........:::::::::::::: THIS CODE RULE MUST BE ACTIVE DURING MERGE - NOT ADDING BYPASS :::::::::::::::::.................
		CM_validateCasesForVendorData(triggerOld, triggerNew);
	}
	
	public static void onBeforeInsert(List<Account> triggerNew) {
		// run only when not in merge mode
		if(!GNE_SFA2_Util.isMergeMode()){
			runValidationRulesOnInsert(triggerNew);
		}
	}
	
	public static void onBeforeDelete(List<Account> triggerOld) {
		// run only when not in merge mode
		if(!GNE_SFA2_Util.isMergeMode()){
			runSavedCallsValidationOnDelete(triggerOld);
		}
	}
}