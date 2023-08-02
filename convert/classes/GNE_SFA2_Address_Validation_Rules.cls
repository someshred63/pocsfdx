/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-08-07
*  Description: This is a helper class for handling Address validation rules
*  Test class: GNE_SFA2_Address_Trigger_Test
*    
*  Modification History
*  Date        Name        			Description
*  2014-01-23  Marta Malinowska	    Change the logic of validation methods: the error message is added to all invalid address records and to all their fields.
*  2016-04-15  Lukasz Kozminski	    Fix logic for primary address validation      
*************************************************************/
public without sharing class GNE_SFA2_Address_Validation_Rules {
	
	private static RecordType companyMaintainedRecordType;
	private static Set<Id> sfaCanadaCompanyMainteinedRecordTypeIds;
	private static Set<Id> sfaCanadaRecordTypeIds;
	private static Set<Id> accountsWithMorePrimaryAddresses = new Set<Id>();
	private static Boolean modifyAllDataCache;
	private static Map<Id, Account>accountsWithAddresses;
	
    
    private static Boolean applyDeactivationValidations(Address_vod__c address) {
        Boolean result = false;
        if(address.Primary_vod__c) {
            address.addError(System.Label.Primary_address_cannot_be_marked_inactive);
            result = true;
        } else if(!address.Primary_vod__c) {
            address.addError(System.Label.There_must_be_at_least_one_active_primary_address_for_each_account);
            result = true;
        } else if(address.Inactivate_Reason_gne__c == null) {
            address.addError(System.Label.Address_inactive_reason_cannot_be_null);
            result = true;
        }
        return result;
    }
    
    private static void addressDeactivationValidationsOnInsert(List<Address_vod__c> triggerNew) {
        for(Address_vod__c address : triggerNew) {
            if(address.Inactive_vod__c) {
                if(applyDeactivationValidations(address)) {
                	//Add address Id to the collection of failed validation records
                    GNE_SFA2_Address_Trigger_Helper.setFailedValidation(address.Id);
                }
            }
        }
    }
    
    
    private static void addressDeactivationValidationsOnUpdate(List<Address_vod__c> triggerOld, List<Address_vod__c> triggerNew) {

        Map<Id, List<Address_vod__c>> accountToAddresses = new Map<Id, List<Address_vod__c>>();
        String accountsToQuery = '';
    	for(Address_vod__c addr : triggerNew) {
    		if(!accountToAddresses.containsKey(addr.Account_vod__c)){
    			accountToAddresses.put(addr.Account_vod__c, new List<Address_vod__c>());
    			accountsToQuery +=  addr.Account_vod__c + ';';
    		}
    		accountToAddresses.get(addr.Account_vod__c).add(addr);
    	}
        Map<Id, Account> accounts = getAccountsWithAddresses(accountToAddresses.keySet());
        
        String accountsLst = '';
		for(Id accountId : accounts.keySet()){
			accountsLst += accountId + ';';
		}
        
        Integer idx = 0;
        for(Address_vod__c addr : triggerNew) {
        	Address_vod__c addrOld = triggerOld[idx++];
        	
        	//if removing primary flag
        	if(addr.Primary_vod__c == false && addrOld.Primary_vod__c == true){
        		List<Address_vod__c> addresses;
        		try{
        			addresses = accounts.get(addr.Account_vod__c).Address_vod__r;
        		} catch (Exception e){
        			String message = 'Missing account: '+addr.Account_vod__c + ' (address: ' + addr + '). Available accounts: ' + accountsLst + '. AccountsToQuery: ' + accountsToQuery;
        			throw new GNE_SFA2_Exception(message, e);
        		}
        		Boolean hasAnotherPrimaryAddress = false;
        		for(Address_vod__c address: addresses){
        			if(addr.Id != address.Id && address.Primary_vod__c == true){
        					hasAnotherPrimaryAddress = true;
        					break;
        			}
        		}
        		for(Address_vod__c address: accountToAddresses.get(addr.Account_vod__c)){
        		
        			if(addr.Id != address.Id && address.Primary_vod__c == true){
        				if(!GNE_SFA2_Address_Trigger_Helper.getFailedValidation(address.Id)){
        					hasAnotherPrimaryAddress = true;
        					break;
        				}
        			}
        		}
	        	
	        	if(!hasAnotherPrimaryAddress){
	        		if(CORE_Subscribe_Util.isSubscribeProcess()){
	        			addr.Primary_vod__c = true;
	        		}else{
	        			addr.addError(System.Label.There_must_be_at_least_one_active_primary_address_for_each_account);
	            		GNE_SFA2_Address_Trigger_Helper.setFailedValidation(addr.Id);
	        		}
	        	}
        	} 
        }
    }
    
    private static Set<Id> getAllAccountsWithLastPrimaryAddress(List<Address_vod__c> triggerOld) {
    	
    	Set<String> accountIds = new Set<String>();
    	for(Address_vod__c addr : triggerOld) {
    		accountIds.add(addr.Account_vod__c);
    	}
    	
    	List<Address_vod__c> addessesList = [SELECT Id, Account_vod__c, Primary_vod__c
	    								     FROM
	    								     	  Address_vod__c
	    								     WHERE
	    								     	  Inactive_vod__c = false AND Account_vod__c IN : accountIds
	    								     ORDER BY Account_vod__c  
	    								    ];
		
		Set<Id> result = new Set<Id>();
		String lastAccountId;
		for(Address_vod__c addr : addessesList) {
			if( addr.Primary_vod__c == false ) {
				result.add(addr.Account_vod__c);
			} else {
				if( lastAccountId == null ) {
					lastAccountId = addr.Account_vod__c;
				} else if( lastAccountId == addr.Account_vod__c ) { // if true there is more than one primary address
					accountsWithMorePrimaryAddresses.add( addr.Account_vod__c );
				} else {
					lastAccountId = addr.Account_vod__c;
				}
			}
		}
		
		return result;
    }
    
    private static void addressValidationsOnUpdate(List<Address_vod__c> triggerOld, List<Address_vod__c> triggerNew) {
        Boolean validationFailed;
        Boolean modifyAllData = getUserHasModifyAllPermission();
        Boolean lockFieldExists = getLockFieldExists();

        for(Integer i = 0; i < triggerNew.size(); i++) {   
        	validationFailed = false;
            if(! modifyAllData && triggerOld[i].DEA_Address_vod__c) {
                if (triggerOld[i].Name != triggerNew[i].Name ||
                    triggerOld[i].City_vod__c != triggerNew[i].City_vod__c ||
                    triggerOld[i].State_vod__c != triggerNew[i].State_vod__c ||
                    triggerOld[i].Zip_vod__c != triggerNew[i].Zip_vod__c ||                                                 
                    triggerOld[i].Zip_4_vod__c != triggerNew[i].Zip_4_vod__c || 
                    triggerOld[i].Address_line_2_vod__c != triggerNew[i].Address_line_2_vod__c ||
                    triggerOld[i].DEA_Status_vod__c != triggerNew[i].DEA_Status_vod__c ||
                    triggerOld[i].DEA_vod__c != triggerNew[i].DEA_vod__c ||
                    triggerOld[i].DEA_Status_vod__c != triggerNew[i].DEA_Status_vod__c ||
                    triggerOld[i].DEA_Expiration_Date_vod__c != triggerNew[i].DEA_Expiration_Date_vod__c ||
                    triggerOld[i].DEA_Address_vod__c != triggerNew[i].DEA_Address_vod__c ||
                    triggerOld[i].DEA_Schedule_vod__c != triggerNew[i].DEA_Schedule_vod__c ||
                    triggerOld[i].ASSMCA_vod__c !=  triggerNew[i].ASSMCA_vod__c) {
                    triggerNew[i].Name.addError(System.Label.DEA_Address_Update_Lock_Label);
                    validationFailed = true;
                }
            }
            
            if (triggerNew[i].Inactive_vod__c == true && triggerNew[i].Primary_vod__c == true) {
                triggerNew[i].Inactive_vod__c.addError(System.Label.Address_Primary_Label);
                validationFailed = true;
            }
         
            if (triggerOld[i].Name != triggerNew[i].Name) {
                if (lockFieldExists && ! modifyAllData) {
                    SObject obj = triggerNew[i];
                    Boolean checkLock = (Boolean)obj.get('Lock_vod__c');
                    if (checkLock == true) {
                        triggerNew[i].Name.addError(System.Label.Address_Update_Lock_Label);
                        validationFailed = true;
                    }
                }
            }
            
            if(validationFailed) {
            	//Add address Id to the collection of failed validation records
                GNE_SFA2_Address_Trigger_Helper.setFailedValidation(triggerNew[i].Id);
            }
        }
    }
    
    private static Boolean getUserHasModifyAllPermission() {
    	if(modifyAllDataCache==null) {
	        Profile currentUserProfile = [Select Id, PermissionsModifyAllData From Profile where Id = :UserInfo.getProfileId()];
	        modifyAllDataCache = currentUserProfile != null && currentUserProfile.PermissionsModifyAllData;
        }
        
        return modifyAllDataCache;
    }
    
    private static Boolean getLockFieldExists() {
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Address_vod__c.fields.getMap();
        Schema.SObjectField lockVodField = fieldMap.get('Lock_vod__c');
        Boolean lockFieldExists = false;
        if (lockVodField != null) {
            lockFieldExists = true;
        }
        
        return lockFieldExists;
    }
    
    private static void addressLockValidationsOnDelete(List<Address_vod__c> triggerOld) {
        Boolean validationFailed;
        Map <Id, Address_vod__c> addMap = new Map <Id,Address_vod__c> ([ SELECT Id, (SELECT Id FROM Controlling_Address_vod__r), (SELECT Id FROM Call2_vod__r 
                                   WHERE Status_vod__c = 'Submitted_vod' or Status_vod__c = 'Saved_vod') 
                                   FROM Address_vod__c WHERE ID in :triggerOld ]);
                                   
        Boolean modifyAllData = getUserHasModifyAllPermission();
        Boolean lockFieldExists = getLockFieldExists();
        for(Address_vod__c address : triggerOld) {
        	validationFailed = false;
            if(! modifyAllData) {
                if(address.Controlling_Address_vod__c != null && !GNE_SFA2_Address_Trigger_Helper.getChildAccount()) {
                    address.Name.addError(System.Label.Address_Delete_Lock_Label);
                    validationFailed = true;
                } else if(address.DEA_Address_vod__c) {
                    address.Name.addError(System.Label.DEA_Address_Delete_Lock_Label);
                    validationFailed = true;
                } else if(lockFieldExists) {
                    SObject obj = address;
                    Boolean checkLock = (Boolean)obj.get('Lock_vod__c');
                    if(checkLock == true) {
                         address.Name.addError(System.Label.Address_Delete_Lock_Label);
                         validationFailed = true;
                    }
                }
            }
            
            if(validationFailed) {
            	//Add address Id to the collection of failed validation records
                GNE_SFA2_Address_Trigger_Helper.setFailedValidation(address.Id);
            }
            
        }
    }
    
    private static Boolean validateFaxFormat(Address_vod__c address) {
        Boolean result = false;
        if(address.Fax_vod__c != null && address.Fax_vod__c != ''){
            String a = '\\D*?(\\d\\D*?){10}';
            Pattern p = Pattern.compile(a);
            Matcher matcher = p.matcher(address.Fax_vod__c);
            if(!matcher.matches()) {
                address.Fax_vod__c.addError(System.Label.Address_Invalid_Fax_Number);
                result = true;
            }
        }
        return result;
    }
    
    private static Boolean validateFax2Format(Address_vod__c address) {
        Boolean result = false;
        if(address.Fax_2_vod__c != null && address.Fax_2_vod__c != ''){
            String a = '\\D*?(\\d\\D*?){10}';
            Pattern p = Pattern.compile(a);
            Matcher matcher = p.matcher(address.Fax_2_vod__c);
            if(!matcher.matches()) {
                address.Fax_2_vod__c.addError(System.Label.Address_Invalid_Fax_Number);
                result = true;
            }
        }
        return result;
    }
    
    private static Boolean validateCanadaPostalCodeFormat(Address_vod__c address) {
        Boolean result = false;
        String regExString = '[A-Z]\\d[A-Z]\\s\\d[A-Z]\\d';
        Pattern p = Pattern.compile(regExString);
        if(address.Postal_Code_can_gne__c != null){
            Matcher matcher = p.matcher(address.Postal_Code_can_gne__c);
            if(!matcher.matches()) {
                address.Postal_Code_can_gne__c.addError(System.Label.Address_Invalid_Canada_Postal_Code);
                result = true;
            }
        }else{
            address.Postal_Code_can_gne__c.addError(System.Label.Address_Invalid_Canada_Postal_Code);
        }
        
        return result;
    }
    
    private static Boolean validateStreetAddressChange(Address_vod__c oldAddress, Address_vod__c newAddress, String currentUserProfile) {
        Boolean result = false;
        Set<String> excludedProfiles = new Set<String>();
        for(GNE_SFA2_Addr_Valid_Excluded_Profiles__c value : GNE_SFA2_Addr_Valid_Excluded_Profiles__c.getAll().values()){
            excludedProfiles.add(value.Profile_Name__c);
        }
        if(oldAddress.RecordTypeId == companyMaintainedRecordType.Id && (oldAddress.Name != newAddress.Name 
            || oldAddress.City_vod__c != newAddress.City_vod__c || oldAddress.State_vod__c != newAddress.State_vod__c 
            || oldAddress.Zip_vod__c != newAddress.Zip_vod__c) && !excludedProfiles.contains(currentUserProfile)) {
                result = true;
                newAddress.addError(System.Label.Address_Street_Address_Cannot_Be_Updated); 
            }
        return result;
    }
    
     private static Boolean validateCanadaCompanyMaintainedAddressChange(Address_vod__c oldAddress, Address_vod__c newAddress, Map<Id, Account> parentAccounts, String currentUserProfile) {
        Boolean result = false;
        Set<String> includedProfiles = new Set<String>();
        for(GNE_SFA2_Addr_CA_Valid_Included_Profiles__c value : GNE_SFA2_Addr_CA_Valid_Included_Profiles__c.getAll().values()){
            includedProfiles.add(value.Profile_Name__c);
        }
        if(!includedProfiles.contains(currentUserProfile)) {
        	return result;
        }
        
        if(newAddress.MRM_Lock_add_can_gne__c && sfaCanadaRecordTypeIds.contains(newAddress.RecordTypeId)) {
        	Set<String> addressFields  = Schema.SobjectType.Address_vod__c.fields.getMap().keyset();
        	Set<String> changedFieldNames = new Set<String>();
        	String phone2FieldName = 'PHONE_2_VOD__C';
        
        	for(String fieldName : addressFields){
            	try{
                	if(newAddress.get(fieldName) != oldAddress.get(fieldName)){
                    	changedFieldNames.add(fieldName.toUpperCase());
                	}
            	}catch(Exception e){
                	System.debug('Cannot access field \'' + fieldName + '\'' );
                	// do nothing
            	}
        	}        
        	changedFieldNames.remove(phone2FieldName);
        	
            if(!changedFieldNames.isEmpty()){
                newAddress.addError(System.Label.Address_Company_Maintained_Address_Cannot_Be_Updated);
                result = true;
            }
        } else if((sfaCanadaCompanyMainteinedRecordTypeIds.contains(newAddress.RecordTypeId) || parentAccounts.get(newAddress.Account_vod__c).Account_Type_gne__c == 'Pharmacist' 
                || parentAccounts.get(newAddress.Account_vod__c).Account_Type_gne__c == 'Physician') && (oldAddress.Name != newAddress.Name || oldAddress.Org_Name_can_gne__c != newAddress.Org_Name_can_gne__c
                || oldAddress.Address_line_2_vod__c != newAddress.Address_line_2_vod__c || oldAddress.City_vod__c != newAddress.City_vod__c || oldAddress.Province_can_gne__c != newAddress.Province_can_gne__c
                || oldAddress.Country_gen__c != newAddress.Country_gen__c || oldAddress.Postal_Code_can_gne__c != newAddress.Postal_Code_can_gne__c || oldAddress.Phone_vod__c != newAddress.Phone_vod__c
                || oldAddress.Phone_1_Ext_gne__c != newAddress.Phone_1_Ext_gne__c || oldAddress.Address_Type_gne__c != newAddress.Address_Type_gne__c || oldAddress.Gatekeeper_gne__c != newAddress.Gatekeeper_gne__c
                || oldAddress.Appt_Required_vod__c != newAddress.Appt_Required_vod__c || oldAddress.Appointment_Restrictions_gne__c != newAddress.Appointment_Restrictions_gne__c || oldAddress.Appointment_Type_gne__c != newAddress.Appointment_Type_gne__c)){
            newAddress.addError(System.Label.Address_Company_Maintained_Address_Cannot_Be_Updated);
            result = true;  
        }
        return result;
    }
    
    private static Boolean validateDeaAddress(Address_vod__c address) {
        Boolean result = false;
        if(address.DEA_Address_vod__c && (address.DEA_Schedule_vod__c == '' || address.DEA_vod__c == '' || address.DEA_Status_vod__c == '' || address.DEA_Expiration_Date_vod__c == null)) {
            address.Accepting_New_Patients_gne__c.addError(System.Label.Address_Missing_DEA_Fields);
            result = true;  
        }
        return result;
    }
    
    private static Boolean validatePuertoRicoDeaAddress(Address_vod__c address) {
        Boolean result = false; 
        if(address.DEA_Address_vod__c && address.State_vod__c != null && address.State_vod__c.equalsIgnoreCase('PR') && (address.ASSMCA_vod__c == null || address.ASSMCA_vod__c == '')) {
            address.Accepting_New_Patients_gne__c.addError(System.Label.Address_Missing_ASSMCA_Number);
            result = true;  
        }
        return result;
    }
    
    private static Boolean validateMdmHcpAddressReactivation(Address_vod__c oldAddress, Address_vod__c newAddress, String currentUserProfile) {
        Boolean result = false; 
        Set<String> excludedProfiles = new Set<String>();
        for(GNE_SFA2_Addr_Valid_Excluded_Profiles__c value : GNE_SFA2_Addr_Valid_Excluded_Profiles__c.getAll().values()){
            excludedProfiles.add(value.Profile_Name__c);
        }       
        if(!newAddress.Inactive_vod__c && oldAddress.Inactive_vod__c != newAddress.Inactive_vod__c && newAddress.Active_Flag_gne__c == false
            && newAddress.Active_Flag_gne__c == oldAddress.Active_Flag_gne__c && newAddress.MDM_Address_ID_gne__c != '' && newAddress.Account_vod__r.IsPersonAccount
            && !excludedProfiles.contains(currentUserProfile) && newAddress.RecordTypeId == companyMaintainedRecordType.Id) {
            newAddress.addError(System.Label.Address_Dactivated_Address_Reactivation_New_Address);
            result = true;  
        }
        return result;
    }
    
    private static Boolean validateMdmHcoAddressReactivation(Address_vod__c oldAddress, Address_vod__c newAddress, String currentUserProfile) {
        Boolean result = false; 
        Set<String> excludedProfiles = new Set<String>();
        for(GNE_SFA2_Addr_Valid_Excluded_Profiles__c value : GNE_SFA2_Addr_Valid_Excluded_Profiles__c.getAll().values()){
            excludedProfiles.add(value.Profile_Name__c);
        }
        if(!newAddress.Inactive_vod__c && oldAddress.Inactive_vod__c != newAddress.Inactive_vod__c && newAddress.Active_Flag_gne__c == false
            && newAddress.Active_Flag_gne__c == oldAddress.Active_Flag_gne__c && newAddress.MDM_Address_ID_gne__c != '' && !newAddress.Account_vod__r.IsPersonAccount
            && !excludedProfiles.contains(currentUserProfile) && newAddress.RecordTypeId == companyMaintainedRecordType.Id) {
            newAddress.addError(System.Label.Address_Dactivated_Address_Reactivation_DCR);
            result = true;  
        }
        return result;
    }
    
    private static Boolean validateActemraNetworkAddress(Address_vod__c oldAddress, Address_vod__c newAddress, Map<Id, Account> parentAccounts, String currentUserProfile) {
        Boolean result = false;         
        if(currentUserProfile.toUpperCase().contains('ACTEMRA') && parentAccounts.get(newAddress.Account_vod__c).Record_Type_Text_GNE__c != null && parentAccounts.get(newAddress.Account_vod__c).Record_Type_Text_GNE__c.toUpperCase().contains('NETWORK') 
            && (oldAddress.Name != newAddress.Name || newAddress.Address_line_2_vod__c != oldAddress.Address_line_2_vod__c || newAddress.Address_Line_3_gne__c != oldAddress.Address_Line_3_gne__c
            || newAddress.Address_Line_4_gne__c != oldAddress.Address_Line_4_gne__c || newAddress.City_vod__c != oldAddress.City_vod__c || newAddress.Country_vod__c != oldAddress.Country_vod__c
            || newAddress.Zip_vod__c != oldAddress.Zip_vod__c || newAddress.Primary_vod__c != oldAddress.Primary_vod__c || newAddress.Phone_vod__c != oldAddress.Phone_vod__c
            || newAddress.Phone_1_Ext_gne__c != oldAddress.Phone_1_Ext_gne__c || newAddress.Phone_2_vod__c != oldAddress.Phone_2_vod__c || newAddress.Phone_2_Ext_gne__c != oldAddress.Phone_2_Ext_gne__c
            || newAddress.Fax_vod__c != oldAddress.Fax_vod__c || newAddress.Fax_2_vod__c != oldAddress.Fax_2_vod__c)) {
            newAddress.addError(System.Label.Address_Cannot_Be_Modified);
            result = true;  
        }
        return result;
    }
    
	private static void runValidationRulesOnInsert(List<Address_vod__c> triggerNew) {
    	Boolean validationFailed;
        Boolean hasCanadaProfile = GNE_SFA2_Address_Trigger_Helper.userHasCanadianProfile();
        for(Address_vod__c address : triggerNew) {
        	validationFailed = false;
        	if(validateFaxFormat(address)) {
                validationFailed = true;
            } 
            if(validateFax2Format(address)) {
                validationFailed = true;
            } 
            if(hasCanadaProfile && validateCanadaPostalCodeFormat(address)) {
                validationFailed = true;
            } 
            if(validateDeaAddress(address)) {
                validationFailed = true;
            } 
            if(validatePuertoRicoDeaAddress(address)) {
                validationFailed = true;
            } 
   		
            if(validationFailed) {
            	//Add address Id to the collection of failed validation records	
                GNE_SFA2_Address_Trigger_Helper.setFailedValidation(address.Id);
            }
        }  
    }
    
    private static Map<Id, Account> getAccountsWithAddresses(Set<Id> accountIds){
    	if(accountsWithAddresses == null){
    		accountsWithAddresses = new Map<Id, Account>([ SELECT Id, Account_Type_gne__c, Record_Type_Text_GNE__c, 
    																(SELECT Id, Account_vod__c, Primary_vod__c, Inactive_vod__c, MDM_Address_ID_gne__c, Active_Flag_gne__c FROM Address_vod__r)
	    								      FROM Account WHERE Id in :accountIds]);
    	}
		return accountsWithAddresses;    	
    }
    
     private static void runValidationRulesOnUpdate(List<Address_vod__c> triggerOld, List<Address_vod__c> triggerNew) {
        Boolean validationFailed;
        Boolean hasCanadaProfile = GNE_SFA2_Address_Trigger_Helper.userHasCanadianProfile();
        String currentUserProfile = GNE_SFA2_Util.getCurrentUserProfileName();
        cacheAddressRecordTypes();

        Set<Id> ids = new Set<Id>();
        for(Address_vod__c addr : triggerNew) {
            ids.add(addr.Account_vod__c);
        }
        Map<Id, Account> parentAccounts = getAccountsWithAddresses(ids);

        for(Integer i = 0; i < triggerNew.size(); i++) {
        	validationFailed = false;
        	if(validateFaxFormat(triggerNew[i])) {
                validationFailed = true;
            } 
            if(validateFax2Format(triggerNew[i])) {
                validationFailed = true;
            } 
            if(hasCanadaProfile && validateCanadaPostalCodeFormat(triggerNew[i])) {
                validationFailed = true;
            } 
            if(validateStreetAddressChange(triggerOld[i], triggerNew[i], currentUserProfile)) {
                validationFailed = true;
            } 
            if(validateCanadaCompanyMaintainedAddressChange(triggerOld[i], triggerNew[i], parentAccounts, currentUserProfile)) {
                validationFailed = true;
            } 
            if(validateDeaAddress(triggerNew[i])) {
                validationFailed = true;
            } 
            if(validatePuertoRicoDeaAddress(triggerNew[i])) {
                validationFailed = true;
            } 
            if(validateMdmHcpAddressReactivation(triggerOld[i], triggerNew[i], currentUserProfile)) {
                validationFailed = true;
            } 
            if(validateMdmHcoAddressReactivation(triggerOld[i], triggerNew[i], currentUserProfile)) {
                validationFailed = true;
            } 
            if(validateActemraNetworkAddress(triggerOld[i], triggerNew[i], parentAccounts, currentUserProfile)) {
                validationFailed = true;
            }
            if(validationFailed) {
            	//Add address Id to the collection of failed validation records
                GNE_SFA2_Address_Trigger_Helper.setFailedValidation(triggerNew[i].Id);
            }
        }  
    }
    
    private static void cacheAddressRecordTypes() {
    	if(companyMaintainedRecordType==null) {
    		companyMaintainedRecordType = [ SELECT Id FROM RecordType WHERE DeveloperName = :GNE_SFA2_Address_Field_Updates.ADDRESS_COMPANY_MAINTEINED_REC_TYPE AND SObjectType = 'Address_vod__c'];
    		sfaCanadaRecordTypeIds = new Set<Id>();
    		sfaCanadaCompanyMainteinedRecordTypeIds = new Set<Id>();
    		List<RecordTypeInfo> rtInfos = Address_vod__c.sObjectType.getDescribe().getRecordTypeInfos();
    		
    		for(RecordTypeInfo rtInfo : rtInfos) {
    			String rtName = rtInfo.getName();
    			Id rtId = rtInfo.getRecordTypeId();
    			if(rtName.startsWithIgnoreCase('SFA Canada')) {
    				sfaCanadaRecordTypeIds.add(rtId);
    				
    				if(rtName.startsWithIgnoreCase('SFA Canada Company Maintained')) {
    					sfaCanadaCompanyMainteinedRecordTypeIds.add(rtId);
    				}
    			}
    		}
    	}
    }
    
    public static void onBeforeUpdate(List<Address_vod__c> triggerOld, List<Address_vod__c> triggerNew) {
    	if(!GNE_SFA2_Util.isMergeMode()) {
	        runValidationRulesOnUpdate(triggerOld, triggerNew);
	        addressValidationsOnUpdate(triggerOld, triggerNew);
	        addressDeactivationValidationsOnUpdate(triggerOld, triggerNew);
    	}
    }
    
    public static void onBeforeInsert(List<Address_vod__c> triggerNew) {
    	if(!GNE_SFA2_Util.isMergeMode()) {
	        runValidationRulesOnInsert(triggerNew);
	        addressDeactivationValidationsOnInsert(triggerNew);
    	}
    }
    
    public static void onBeforeDelete(List<Address_vod__c> triggerOld) {
    	if(!GNE_SFA2_Util.isMergeMode()) {
        	addressLockValidationsOnDelete(triggerOld);
    	}
    }
}