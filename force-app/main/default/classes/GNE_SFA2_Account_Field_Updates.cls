/************************************************************
*  @author: Bartosz Osowiecki, Roche
*  Date: 2012-12-19
*  Description: Helper class for GNE_SFA2_Account_Trigger
*  Test class: GNE_SFA2_Account_Trigger_Test
*  
*  Modification History
*  Date        Name        Description
*  2017-05-23  lanieckj    Setting record type to FRM_HCO should automatically set the account owner to frm admin (SFA-2874)
*            
*************************************************************/
public without sharing class GNE_SFA2_Account_Field_Updates
{
	private static String restrictedProductNames = null;
	
	public static final String RECORD_TYPE_US_HOSPITAL = 'Hospital Department_vod';
	public static final String RECORD_TYPE_CAN_HOSPITAL = 'GNE-SFA-Roche_Canada_Hospital_Depatment';
	public static final String RECORD_TYPE_GFRS = 'gFRS';
    private static Map<String, User> externalId2User;
    private static final Id RECORD_TYPE_ID_FRM_HCO = Schema.SObjectType.Account.getRecordTypeInfosByName().get('HCO').getRecordTypeId();
	
	
	public static String getRestrictedProductNames() {
    	if(restrictedProductNames!=null) return restrictedProductNames;
    	
    	restrictedProductNames = '';
    	
    	for (Product_vod__c product : [
    	   SELECT Name 
    	   FROM Product_vod__c 
    	   WHERE Product_Type_vod__c='Detail' 
    	       AND Restricted_vod__c = true 
    	       AND Company_Product_vod__c = true
    	]) {
        	if(restrictedProductNames!='') {
				restrictedProductNames += ';;';
            }
            
            restrictedProductNames += product.Name;
		}
		
		return restrictedProductNames;
    }
	
	private static void setRestrictedProducts(List<Account> triggerNew) {
		for (Account accNew : triggerNew) {
			if(accNew.Enable_Restricted_Products_vod__c==true) {
				accNew.Restricted_Products_vod__c = getRestrictedProductNames();
			}
		}
	}
	
	private static void setParentHospital(List<Account> triggerNew) {
		Set<String> hospitalsRecTypes = new Set<String> {RECORD_TYPE_US_HOSPITAL, RECORD_TYPE_CAN_HOSPITAL};
		for (Account accNew : triggerNew) {
			if(accNew.ParentId!=null && hospitalsRecTypes.contains(accNew.Record_Type_Name_gne__c)) {
				accNew.Parent_Hospital_gne__c = accNew.ParentId;
			}
		}
	}
	
    private static void setOwnerForAccount(List<Account> triggerNew, Set<String> excludeTypes) {
        for(Account accNew : triggerNew) {
            if (accNew.Record_Type_Name_gne__c == RECORD_TYPE_GFRS && !excludeTypes.contains(RECORD_TYPE_GFRS)) {
                accNew.OwnerId = System.Label.GFRS_Account_Owner_Id;
            } else if (accNew.RecordTypeId == RECORD_TYPE_ID_FRM_HCO && !excludeTypes.contains(GNE_SFA2_Account_Trigger_Helper.REC_TYPE_FRM_HCO)) {
                if (Trigger.oldMap == null ) {
                    accNew.OwnerId = fetchAccountOwnerForFRM_HCO(accNew);
                } else {
                    Account oldAccount = (Account)Trigger.oldMap.get(accNew.Id);
                    if(oldAccount.RecordTypeId != accNew.RecordTypeId) {
                        accNew.OwnerId = fetchAccountOwnerForFRM_HCO(accNew);
                    }
                }
            }
        }
    }
    
    private static void setOwnerForAccount(List<Account> triggerNew) {
        setOwnerForAccount(triggerNew, new Set<String>());
    }
    
    private static String fetchAccountOwnerForFRM_HCO(Account acc) {
        String userId = UserInfo.getUserId();
        prepareDefaultOwnerMap();
        if(acc.Account_Type_gne__c == null) {
            userId = !externalId2User.isEmpty() ? externalId2User.values().get(0).Id : userId;
        } else {
            if (!externalId2User.isEmpty()) {
                String externalId = GNE_SFA2_Account_Trigger_Helper.frmOwnerConfiguration.get(acc.Account_Type_gne__c) != null ? 
                    GNE_SFA2_Account_Trigger_Helper.frmOwnerConfiguration.get(acc.Account_Type_gne__c).Account_Owner_gne__c : null;
                if (externalId != null) {
                    User defOwner = externalId2User.get(externalId) != null ? externalId2User.get(externalId) : null;
                    if (defOwner != null) {
                        userId = defOwner.Id;
                    }
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

	private static void setHcpDefaultAccountType(List<Account> triggerNew) {
		if(!GNE_SFA2_Account_Trigger_Helper.userHasCanadaProfile()) {
	        // Record Type - Account Type Mapping  
	        // This is a 1 to 1 mapping 
	        for (Account accNew : triggerNew) {          
                if(accNew.IsPersonAccount && accNew.Account_Type_gne__c == null) {
                    String key_prefix = 'AccountType.account.';
                    Map<String, String> envVariablesMap = GNE_SFA2_Account_Trigger_Helper.getEnvironmentVariablesMap();
                    String value = envVariablesMap.get(key_prefix + accNew.Record_Type_Name_gne__c);
	                accNew.Account_Type_gne__c = value==null ? envVariablesMap.get(key_prefix + 'default') : value;
	            }
	        }
    	}
	}
	
	/*Set account.Stewardship_System_Name_gne__c field based on account type*/
    public static void setHcpDefaultStewardshipSystem(List<Account> triggerNew){
        String key_prefix = 'stewardshipSystem.account.';
        
        for (Account accNew : triggerNew){        
            if(accNew.Stewardship_System_Name_gne__c == null && accNew.IsPersonAccount) {
                Map<String, String> envVariablesMap = GNE_SFA2_Account_Trigger_Helper.getEnvironmentVariablesMap();
                String value = envVariablesMap.get (key_prefix + accNew.Record_Type_Name_gne__c);
                accNew.Stewardship_System_Name_gne__c = value!=null ? value : (envVariablesMap.containsKey(key_prefix + 'default') ? envVariablesMap.get(key_prefix + 'default') : GNE_SFA2_Account_Trigger_Helper.DEFAULT_HCP_STEWARDSHIP_SYSTEM_NAME);
            }
        }
    }
    
    private static void setContactNameAndInactiveDate(List<Account> triggerNew) {
        for(Account accNew : triggerNew) {
            if(accNew.Contract_Name_gne__c == null && accNew.Name !=null) {
            	accNew.Contract_Name_gne__c = accNew.Name.abbreviate(Account.Contract_Name_gne__c.getDescribe().getLength());
            }
            if(accNew.Status_gne__c == 'Inactive' && accNew.Date_Inactive_gne__c == null) {
                accNew.Date_Inactive_gne__c = System.today();
            } else if(accNew.Status_gne__c != 'Inactive' && accNew.Date_Inactive_gne__c != null) {
                accNew.Date_Inactive_gne__c = null;
            } 
        }
    }

    private static void setDefaultClassificationAndExclusionValues(List<Account> triggerNew){
        for(Account accNew : triggerNew) {
            if(accNew.IsPersonAccount){
                if(String.isBlank(accNew.EDM_Business_Classification_gne__c)){
                    accNew.EDM_Business_Classification_gne__c = 'Not Classified';
                }
                if(String.isBlank(accNew.EDM_Clinical_Classification_gne__c)){
                    accNew.EDM_Clinical_Classification_gne__c = 'Not Classified';
                }
                if(String.isBlank(accNew.AGS_EX_Exclusion_Status_base_gne__c)){
                    accNew.AGS_EX_Exclusion_Status_base_gne__c = 'Not checked';
                }
                if(accNew.Professional_Type_gne__c == 'Patient Ambassador') {
                    accNew.EDM_Business_Classification_gne__c = 'Not Applicable';    
                    accNew.EDM_Clinical_Classification_gne__c = 'Not Applicable';
                    accNew.AGS_EX_Exclusion_Status_base_gne__c = 'Not Applicable';
                }
            }
        }
    }
    
    public static void setHcoAccountType(List<Account> triggerNew) {
        setHcoAccountType(triggerNew, null);
    }
    
    private static void setHcoAccountType(List<Account> triggerNew, List<Account> triggerOld) {
        List<Account> accsToUpdate = new List<Account>();
        Integer idx = 0;
        
        for(Account accNew : triggerNew) {
            Account accOld = triggerOld!=null ? triggerOld[idx++] : new Account();
            
            if(!accNew.IsPersonAccount && (String.isBlank(accNew.Account_Type_gne__c) || accNew.Account_Type_gne__c!=accOld.Account_Type_gne__c)) {
                accsToUpdate.add(accNew);
            }
        }
        
        if(!accsToUpdate.isEmpty()) {
            Map<String,GNE_SFA2_Account_Trigger_Helper.AccountTypeWrapper> accTypesMap = GNE_SFA2_Account_Trigger_Helper.getAccountTypesMap(GNE_SFA2_Account_Trigger_Helper.AccountTypeKeyType.RECORD_TYPE_ACCOUNT_TYPE);
            
            for(Account acc : accsToUpdate) {
                String accType = (acc.RecordTypeId + '_' + acc.Account_Type_gne__c).toUpperCase();
                GNE_SFA2_Account_Trigger_Helper.AccountTypeWrapper accTypeWrapper = null;
                
                if((accTypeWrapper=accTypesMap.get(accType))!=null) {
                    accTypeWrapper.updateAccount(acc);
                } else if(String.isBlank(acc.Stewardship_System_Name_gne__c)) {
                    accTypesMap.get('DEFAULT').updateAccount(acc);
                }
            }
        }
    }

    private static void synchronizeAccountTypeForRAMA(List<Account> triggerNew) {
        for(Account account : triggerNew) {
            String ramaValue = account.Account_Type_RAMA_gne__c;
            account.Account_Type_gne__c = ramaValue;
        }
    }

    public static void onBeforeUpdate(List<Account> triggerOld, List<Account> triggerNew) {
        List<Account> new_triggerNew = triggerNew.clone();
        GNE_SFA2_Account_Trigger_Helper.removeFailedValidationRecords(new_triggerNew);
        List<Account> new_triggerOld = triggerOld.clone();
        GNE_SFA2_Account_Trigger_Helper.removeFailedValidationRecords(new_triggerOld);
        if(!GNE_SFA2_Util.isMergeMode()){
            setContactNameAndInactiveDate(new_triggerNew);
            setHcoAccountType(new_triggerNew, new_triggerOld);
            setOwnerForAccount(new_triggerNew, new Set<String>{RECORD_TYPE_GFRS});
            
            if(!GNE_SFA2_Address_Trigger_Helper.inAddressTrig()) {
            	GNE_SFA2_DCR_Util.onBeforeUpdateParent(new_triggerNew);
            }
            if(GNE_SFA2_Util.isCanadaRAMA()) {
                synchronizeAccountTypeForRAMA(triggerNew);
            }
        }
    }
    
    public static void onBeforeInsert(List<Account> triggerNew) {
    	List<Account> new_triggerNew = triggerNew.clone();
		GNE_SFA2_Account_Trigger_Helper.removeFailedValidationRecords(new_triggerNew);
    	
    	// .........:::::::::::::: THIS CODE RULE MUST BE ACTIVE DURING MERGE - NOT ADDING BYPASS :::::::::::::::::.................
    	setRestrictedProducts(new_triggerNew);
    	
    	if(!GNE_SFA2_Util.isMergeMode()){
	    	setParentHospital(new_triggerNew);
	    	setOwnerForAccount(new_triggerNew);
	    	setHcpDefaultAccountType(new_triggerNew);
            setHcpDefaultStewardshipSystem(new_triggerNew);
            setHcoAccountType(new_triggerNew);
	    	setContactNameAndInactiveDate(new_triggerNew);
            setDefaultClassificationAndExclusionValues(new_triggerNew);
    	}
        if(GNE_SFA2_Util.isCanadaRAMA()) {
            synchronizeAccountTypeForRAMA(triggerNew);
        }
    }
    
    public static void onBeforeDelete(List<Account> triggerOld) { }
}