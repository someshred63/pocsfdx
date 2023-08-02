public with sharing class GNE_SFA2_DCR_Validation_Rules {

	public static void onBeforeInsert(List<Change_Request_gne__c> triggerNewList){
		runDCRValidations(triggerNewList);
		runNewDCRNoChangeDetectedValidations(triggerNewList);
	}
	
	public static void onBeforeUpdate(List<Change_Request_gne__c> triggerNewList){
		if(!GNE_SFA2_Util.isMergeMode()) {
			runDCRValidations(triggerNewList);
		}
	}
	
	public static Boolean checkPostalCodeFormat(String postal_code){
		String phoneRegexFormat ='[A-Z]\\d[A-Z]\\s\\d[A-Z]\\d';  
		Pattern MyPattern = Pattern.compile(phoneRegexFormat);
		Matcher MyMatcher = MyPattern.matcher(postal_code);
		if (!MyMatcher.matches()) {
			return true;
		}
		return false;
	}

	public static Boolean checkNationalProviderIdFormat(String npi) {
		String phoneRegexFormat ='^[0-9]{10}$';  
		Pattern MyPattern = Pattern.compile(phoneRegexFormat);
		Matcher MyMatcher = MyPattern.matcher(npi);
		if (!MyMatcher.matches()) {
			return true;
		}
		return false;
	}
	
	public static void runDCRValidations(List<Change_Request_gne__c> trigger_New){
		Map<Id,RecordType> rtMap = new Map<Id,RecordType>([SELECT id, DeveloperName, Name FROM recordtype WHERE sobjecttype ='change_request_gne__c']);
		for(Change_Request_gne__c dcr : trigger_New){
			try{
				if( (dcr.Reason_dcr_gne__c != null && dcr.Reason_dcr_gne__c.equals('Organization is not my account or not in my territory'))  || (dcr.Reason_dcr_gne__c!=null && dcr.Reason_dcr_gne__c.equals('HCP is not my account or not in my territory'))){
					dcr.addError(System.Label.NotMyAccount_InvalidRequest);
				}
				
				if(dcr.Remove_Inactive_Address_gne__c != null && dcr.Remove_Inactive_Address_gne__c.equals('This address is valid but not relevant to my job')){
					dcr.addError(System.Label.NotRelevantAddressDCR);
				}

				//Postal Code must consist of 3 capital letters, 3 digits and one space character and match ''XXX XXX'' pattern (i.e. A0A 1B1)..
				if(Test.isRunningTest()){
					if(dcr.Postal_Code_can_gne__c!=null && rtMap.get(dcr.recordtypeId).DeveloperName.equalsIgnoreCase ('HCP_Existing_Address_Typo_Missing_Info') && checkPostalCodeFormat(dcr.Postal_Code_can_gne__c)){
						dcr.Postal_Code_can_gne__c.addError(System.Label.GNE_SFA_Canada_Postal_Code_Validation);
					}
				}else  if(dcr.Postal_Code_can_gne__c!=null && GNE_SFA2_Util.isCanadaUser() && rtMap.get(dcr.recordtypeId).DeveloperName.equalsIgnoreCase ('HCP_Existing_Address_Typo_Missing_Info') && checkPostalCodeFormat(dcr.Postal_Code_can_gne__c)){
					dcr.Postal_Code_can_gne__c.addError(System.Label.GNE_SFA_Canada_Postal_Code_Validation);
				}
			}catch(Exception e){
				dcr.addError(e.getMessage());
			}
		}
	}
	
	public static void runNewDCRNoChangeDetectedValidations(List<Change_Request_gne__c> trigger_New){
		Map<Id,RecordType> rtMap = new Map<Id,RecordType>([SELECT id, DeveloperName, Name FROM recordtype WHERE sobjecttype ='change_request_gne__c']);
		List<String>addressDcrFields = GNE_SFA2_DCR_Config_Items_gne__c.getValues('AddressDcrFields').Value_gne__c.split(',');
		Map<String, String>addressDcrFieldsMapping = GNE_SFA2_DCR_Util.getAddressDCRFieldMapping('HCP_Existing_Address_Typo_Missing_Info');
		
		Set<Id> acctSet = new Set<Id>();
		for (Change_Request_gne__c dcr : trigger_New){ 
			acctSet.add(dcr.account_gne__c);
		}

		Set<Id> addrSet = new Set<Id>();
		for (Change_Request_gne__c dcr : trigger_New){
			if(dcr.current_address_gne__C != null){  
				addrSet.add ( dcr.current_address_gne__c );
			}
		}
		
		Map<Id, Account> mapAcctInfo = new Map<Id, Account>([
            SELECT Firstname, Lastname, Middle_vod__c, Suffix_gne__c, Suffix_vod__c, Professional_type_gne__c, Credentials_gne__c, Group_gne__r.Name,
			    Specialties_gne__c, isPersonaccount, Name, Account_type_gne__c, Group_specialty_1_vod__c, Stewardship_system_name_gne__c, Gender_vod__c,
				Language_of_Preference_can_gne__c, Specialties_can_gne__c
			FROM Account 
            WHERE Id IN :acctSet
        ]);                                    
		
		Map<Id, Address_vod__c> mapAddrInfo = new Map<Id, Address_vod__c>([
            SELECT Name, City_vod__c, State_vod__c, Zip_vod__c, Postal_Code_can_gne__c, Province_can_gne__c, Address_line_2_vod__c  
			FROM address_vod__C 
            WHERE id in :addrSet
        ]); 
		
		for (Change_Request_gne__c dcr : trigger_New )  {        
			RecordType rt = rtMap.get (dcr.recordTypeId);

			// 3 types basically
			// 2 account based & 1 address change         
			
			if (rt.DeveloperName.equalsIgnoreCase('HCO_Change_Organization_Info') ) {
				Account acct = mapAcctInfo.get ( dcr.account_gne__c );
				if(GNE_SFA2_Util.isCanadaUser()){
					if(!isFieldValueChanged(acct.name,dcr.New_Organization_Name_gne__c) && !isFieldValueChanged(acct.account_type_gne__c, dcr.account_type_dcr_gne__c)){
						dcr.addError (System.Label.Change_RequestChange_Attribute);  
					}
				} else if (!isFieldValueChanged(acct.name,dcr.New_Organization_Name_gne__c) && 
                           !isFieldValueChanged(acct.account_type_gne__c, dcr.account_type_dcr_gne__c) &&
                           !isFieldValueChanged(acct.Group_gne__r.Name, dcr.Account_Group_gne__c) &&
						   dcr.verify_hco_specialties_gne__c != true
                ){
					dcr.addError (System.Label.Change_RequestChange_Attribute);
				}
			} else if ( rt.DeveloperName.equalsIgnoreCase('HCP_Change_HCP_Info') ) {
				Account acct = mapAcctInfo.get ( dcr.account_gne__c );

				if(GNE_SFA2_Util.isCanadaUser()){
					if(!isFieldValueChanged(acct.firstname, dcr.first_name_dcr_gne__c) && !isFieldValueChanged(acct.lastname, dcr.last_name_dcr_gne__c)  && 
						!isFieldValueChanged(acct.middle_vod__c, dcr.new_value_2_gne__c) && !isFieldValueChanged(acct.account_type_gne__c, dcr.account_type_dcr_gne__c) &&
						!isFieldValueChanged(acct.Language_of_Preference_can_gne__c, dcr.Language_of_Preference_dcr_gne__c) &&
						!isFieldValueChanged(acct.Specialties_can_gne__c, dcr.specialties_hcp_dcr_gne__c) &&
						dcr.Verify_Gender_can_gne__c != true){
							dcr.addError (System.Label.Change_RequestChange_Attribute);
					}
				} else {
					String suffix = acct.suffix_vod__c!=null ? acct.suffix_vod__c : acct.suffix_gne__c;
					
					if(!isFieldValueChanged(acct.firstname, dcr.first_name_dcr_gne__c) && !isFieldValueChanged(acct.lastname, dcr.last_name_dcr_gne__c)  && 
						!isFieldValueChanged(acct.middle_vod__c, dcr.new_value_2_gne__c) && !isFieldValueChanged(suffix, dcr.suffix_dcr_gne__c) &&
						!isFieldValueChanged(acct.professional_type_gne__c, dcr.professional_type_dcr_gne__c) && 
						dcr.verify_hcp_credentials_gne__c != true && dcr.verify_hcp_specialties_gne__c != true){
							dcr.addError (System.Label.Change_RequestChange_Attribute);
					}
				}
			} else if ( rt.DeveloperName.equalsIgnoreCase ('HCP_Existing_Address_Typo_Missing_Info') || rt.DeveloperName.equalsIgnoreCase ('HCO_Change_Address')) {
				Address_vod__c addr = mapAddrInfo.get( dcr.current_address_gne__c );
				system.debug ('change address info --> '+ addr.name + '/' +  dcr.address_line_1_gne__c + '\n' +  
							addr.city_vod__c                   + '/' + dcr.city_gne__c +  '\n' +
							addr.state_Vod__C   + '/' + dcr.state_gne__C + '\n' + 
							addr.zip_vod__C         + '/' + dcr.zip_gne__c +       '\n'
							);
				
				if(GNE_SFA2_Util.isCanadaUser()){
					if(!isFieldValueChanged(addr.name, dcr.address_line_1_gne__c) && !isFieldValueChanged(addr.Address_Line_2_vod__c , dcr.Address_Line_2_gne__c) && !isFieldValueChanged(addr.city_vod__c, dcr.city_gne__c) && 
						!isFieldValueChanged(addr.Province_can_gne__c, dcr.Province_can_gne__c) && !isFieldValueChanged(addr.Postal_Code_can_gne__c, dcr.Postal_Code_can_gne__c)){
							dcr.addError (System.Label.Change_RequestChange_Attribute);
					}            
				}else{
					Boolean valueChanged = false;
					for(String addressFieldName: addressDcrFields){
						String dcrFieldName = addressDcrFieldsMapping.get(addressFieldName);
						if(isFieldValueChanged(addr.get(addressFieldName), dcr.get(dcrFieldName))){
							valueChanged = true;
						}
					}
					
					if(!valueChanged){
						dcr.addError (System.Label.Change_RequestChange_Attribute);
					}
				}
			} else if ( rt.DeveloperName.equalsIgnoreCase('US_Licensed_Physician') ) {
				if (String.isBlank(dcr.License_Number_gne__c)) {
					dcr.addError(System.Label.DCR_US_License_Empty);
				}
				if (!String.isBlank(dcr.HCP_National_Provider_Id_gne__c) && checkNationalProviderIdFormat(dcr.HCP_National_Provider_Id_gne__c)) {
					dcr.addError(System.Label.DCR_US_NPI_Format);
				}
			}
		}
	}
	
	private static Boolean isFieldValueChanged(Object oldValue, Object newValue) {
		return GNE_SFA2_DCR_Util.isFieldValueChanged(oldValue, newValue);
	}
}