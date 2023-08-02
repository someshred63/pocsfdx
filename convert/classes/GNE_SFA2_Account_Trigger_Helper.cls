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
public without sharing class GNE_SFA2_Account_Trigger_Helper {
	
	public static final String DEFAULT_STEWARDSHIP_SYSTEM_NAME = 'sfdc';
	public static final String DEFAULT_HCP_STEWARDSHIP_SYSTEM_NAME = 'ams';
	public static final String REC_TYPE_FRM_HCO = 'FRM_HCO';
	public static final String REC_TYPE_HCP = 'Professional_vod';
    public static final String REC_TYPE_CP = 'Contracted_patient_gne';
	public static final String MDM_SYNCH_STATUS_PENDING = 'Pending';
	public static final String MDM_SYNCH_STATUS_SYNCHRONIZED = 'Synchronized';
	
	public enum AccountTypeKeyType {TYPE, CODE, CODE_TYPE, RECORD_TYPE_ACCOUNT_TYPE, RECORD_TYPE}
    
	private static Boolean inAccountTrig = false;
	private static Set<Id> failedValidations = new Set<Id>();
	private static Set<String> exludedProfilesForNameChangeValidation = null;
	private static Map<Id,Account> accountCache = new Map<Id,Account>();
	private static Set<String> includedProfilesForCanadaChangeValidation = null;
	private static Map<String,String> environmentVariablesMap = null;
	private static Map<Id,Set<Speaker_Bureau_Membership_gne__c>> accountsWithUpdatedSBMs = new Map<Id,Set<Speaker_Bureau_Membership_gne__c>>();
	private static Boolean isValidationDisabled = false;
	private static Map<AccountTypeKeyType,Map<String, AccountTypeWrapper>> accountTypesMap;
	private static Map<String,Id> recordTypeIdsMap;
    private static Map<String,Id> ownerIdsMap;
    public static Map<String, CORE_Pub_Org_Typ_Map__c> frmOwnerConfiguration;
    private static Map<String, User> externalId2User;
    
    
	public static void setAccountTrig(Boolean p_inAccountTrig) {
        inAccountTrig = p_inAccountTrig;
    }
            
    public static Boolean inAccountTrig()  {
        return inAccountTrig;
    }
    
    public static void clearFailedValidations() {
    	failedValidations.clear();
    }
    
    public static Set<Id> getFailedValidations() {
    	return failedValidations;
    }
    
    public static void setFailedValidation(Id accID) {
    	failedValidations.add(accID);
    }
    
    public static Boolean getFailedValidation(Id accID) {
		return failedValidations.contains(accID);
    }
    
    public static void removeFailedValidationRecords(List<Account> accs) {
    	if(!accs.isEmpty()) {
			for(Integer i = accs.size()-1;i>=0;i--) {
				if(failedValidations.contains(accs[i].Id)) {
					accs.remove(i);
				}
			}
    	}
	}
	
	public static String getCurrentUserProfileName() {
    	return GNE_SFA2_Util.getCurrentUserProfileName();
    }
    
    public static Boolean userHasCanadaProfile() {
    	return GNE_SFA2_Util.isCanadaUser();
    }
    
    public static Boolean userHasActemraProfile() {
    	return getCurrentUserProfileName().containsIgnoreCase('ACTEMRA');
    }
    
    public static Set<String> getExludedProfilesForNameChangeValidation() {
    	if(exludedProfilesForNameChangeValidation!=null) return exludedProfilesForNameChangeValidation;
    	
    	exludedProfilesForNameChangeValidation = new Set<String>();
    	for(GNE_SFA2_Acct_Name_Valid_Excl_Prfs__c value : GNE_SFA2_Acct_Name_Valid_Excl_Prfs__c.getAll().values()){
    		exludedProfilesForNameChangeValidation.add(value.Profile_Name__c.toUpperCase());
    	}
    	
    	return exludedProfilesForNameChangeValidation;
    }
    
    public static void cacheAccounts(Map<Id,Account> accs) {
    	accountCache.putAll(accs);
    }
    
    public static Account getCachedAccount(Id accId) {
    	return accountCache.get(accId);
    }
    
    public static void cacheAccountChildren(Set<Id> accIds) {
    	if(accountCache.keySet().containsAll(accIds)) return;
    	
    	Map<Id,Account> cachedChildren = new Map <Id,Account> ([Select Id, 
                                                (Select Id from Call2_vod__r 
                                                     where Status_vod__c != 'Planned_vod'),
                                                (Select Id From Affiliation_vod__r),
                                                (Select Id From Affiliation_vod__pr)//,
                                        		from Account where ID in :accIds]);
    	cacheAccounts(cachedChildren);
    }
    
    public static Set<String> getIncludedProfilesForCanadaChangeValidation() {
    	if(includedProfilesForCanadaChangeValidation!=null) return includedProfilesForCanadaChangeValidation;
    	
    	includedProfilesForCanadaChangeValidation = new Set<String>();
    	for(GNE_SFA2_Acct_CA_Valid_Included_Profiles__c value : GNE_SFA2_Acct_CA_Valid_Included_Profiles__c.getAll().values()){
    		includedProfilesForCanadaChangeValidation.add(value.Profile_Name__c.toUpperCase());
    	}
    	
    	return includedProfilesForCanadaChangeValidation;
    }
    
    public static Map<String,String> getEnvironmentVariablesMap() {
        if(environmentVariablesMap!=null) return environmentVariablesMap;
        
        environmentVariablesMap = new Map<String,String> ();
        List<Environment_Variables__c> envVars = [
            SELECT Key__c, Value__c
            FROM Environment_Variables__c 
            WHERE (Key__c LIKE 'AccountType.account.%' OR Key__c LIKE 'stewardshipSystem.account.%') 
                AND Environment__c = 'all'
        ];
                                                
        for (Environment_Variables__c envVar : envVars) {
            environmentVariablesMap.put(envVar.Key__c, envVar.Value__c);
        }
        
        return environmentVariablesMap;
    }
    
    public static void setAccountsWithUpdatedSBMs(Map<Id,Set<Speaker_Bureau_Membership_gne__c>> accIdsToSBMs) {
        accountsWithUpdatedSBMs = accIdsToSBMs;
    }
    
    public static Map<Id,Set<Speaker_Bureau_Membership_gne__c>> getAccountsWithUpdatedSBMs() {
        return accountsWithUpdatedSBMs;
    }
    
    public static Boolean isValidationDisabled() {
        return isValidationDisabled==true;
    }
    
    public static void setValidationDisabled(Boolean disabled) {
      isValidationDisabled=disabled;
    }
    
    public static Set<String> getInfoServiceTrackedFields() {
        return new Set<String>{
            String.valueOf(Account.MDMID_gne__c),
            String.valueOf(Account.FirstName),
            String.valueOf(Account.Middle_vod__c),
            String.valueOf(Account.LastName),
            String.valueOf(Account.Salutation),
            String.valueOf(Account.Account_Type_gne__c)
        };
    }
    
    public static Set<String> getIPhoneTrackedFields() {
        return new Set<String>{
            String.valueOf(Account.Name),
            String.valueOf(Account.FirstName),
            String.valueOf(Account.LastName),
            String.valueOf(Account.Salutation),
            String.valueOf(Account.Middle_vod__c),
            String.valueOf(Account.MDMID_gne__c),
            String.valueOf(Account.Account_Type_gne__c),
            String.valueOf(Account.IsPersonAccount),
            String.valueOf(Account.HCP_Patient_Ed_Consent_Form_gne__c),
            String.valueOf(Account.PersonEmail),
            String.valueOf(Account.Secondary_Email_gne__c),
            String.valueOf(Account.Phone_gne__c),
            String.valueOf(Account.Mobile_ID_vod__c),
            String.valueOf(Account.Language_of_Preference_can_gne__c),
            String.valueOf(Account.Specialties_can_gne__c),
            String.valueOf(Account.Specialties_gne__c),
            String.valueOf(Account.Specialty_1_vod__c),
            String.valueOf(Account.Roche_Id_can_gne__c),
            String.valueOf(Account.TL_Type_gne__c),
            String.valueOf(Account.SP_Investigator_Status_gne__c),
            String.valueOf(Account.Classification_gne__c),
            String.valueOf(Account.Area_of_Expertise_gne__c),
            String.valueOf(Account.Target__c),
            String.valueOf(Account.RecordTypeId),
            String.valueOf(Account.Gender_vod__c),
            String.valueOf(Account.Active_US_License_gne__c),
            String.valueOf(Account.Credentials_gne__c),
            String.valueOf(Account.Website),
            String.valueOf(Account.LinkedIn_gne__c),
            String.valueOf(Account.Twitter_gne__c),
            String.valueOf(Account.PREP_Status_gne__c),
            String.valueOf(Account.PersonDoNotCall),
            String.valueOf(Account.PersonHasOptedOutOfEmail),
            String.valueOf(Account.PersonHasOptedOutOfFax),
            String.valueOf(Account.PREP_Professional_Type_gne__c),
            String.valueOf(Account.Fax),
            String.valueOf(Account.Status_gne__c),
            String.valueOf(Account.BAM_Level_gne__c),
            String.valueOf(Account.BAM_Area_gne__c),
            String.valueOf(Account.BAM_Full_Primary_Title_gne__c),
            String.valueOf(Account.BAM_Other_Title_gne__c),
            String.valueOf(Account.PREP_Double_Testing_Rate_gne__c),
            String.valueOf(Account.PREP_Implied_HER2_Positivity_Rate_gne__c),
            String.valueOf(Account.PREP_HER2_Testing_Segment_gne__c),
            String.valueOf(Account.Est_Annual_Tested_Breast_Patients_gne__c),
            String.valueOf(Account.Est_Annual_Tested_Gastric_Patients_gne__c),
            String.valueOf(Account.Est_Annual_Tested_Lung_Patients_gne__c),
            String.valueOf(Account.Picture_File_Id_gne__c),
            String.valueOf(Account.Type_gne__pc),
            String.valueOf(Account.Professional_Type_gne__c),
            String.valueOf(Account.Group_gne__c),
            String.valueOf(Account.Art_Account_frm_gne__c),
            String.valueOf(Account.stewardship_system_name_gne__c),
            String.valueOf(Account.AFRM_Additional_Account_frm_gne__c),
            String.valueOf(Account.BFRM_Additional_Account_frm_gne__c),
            String.valueOf(Account.EFRM_Additional_Account_frm_gne__c),
            String.valueOf(Account.IFRM_Additional_Account_frm_gne__c),
            String.valueOf(Account.NFRM_Additional_Account_frm_gne__c),
            String.valueOf(Account.RFRM_Additional_Account_frm_gne__c),
            String.valueOf(Account.RESPFRM_Additional_Account_frm_gne__c),
            String.valueOf(Account.SMA_Additional_Account_frm_gne__c),
            String.valueOf(Account.AFRM_My_Tier_frm_gne__c),
            String.valueOf(Account.BFRM_My_Tier_frm_gne__c),
            String.valueOf(Account.EFRM_My_Tier_frm_gne__c),
            String.valueOf(Account.IFRM_My_Tier_frm_gne__c),
            String.valueOf(Account.NFRM_My_Tier_frm_gne__c),
            String.valueOf(Account.PFRM_My_Tier_frm_gne__c),
            String.valueOf(Account.RFRM_My_Tier_frm_gne__c),
            String.valueOf(Account.RESPFRM_My_Tier_frm_gne__c),
            String.valueOf(Account.SMA_My_Tier_frm_gne__c),
            String.valueOf(Account.Spend_Rest_gne__c)
        };
    }
    
    public static Map<String, AccountTypeWrapper> getAccountTypesMap() {
        return getAccountTypesMap(null, AccountTypeKeyType.RECORD_TYPE_ACCOUNT_TYPE);
    }
    
    public static Map<String, AccountTypeWrapper> getAccountTypesMap(AccountTypeKeyType keyType) {
        return getAccountTypesMap(null, keyType);
    }
    
    public static Map<String, AccountTypeWrapper> getAccountTypesMap(String profileName) {
        return getAccountTypesMap(profileName, AccountTypeKeyType.TYPE);
    }
    
    public static Map<String, AccountTypeWrapper> getAccountTypesMap(String profileName, AccountTypeKeyType keyType) {
        if(accountTypesMap==null) {
            accountTypesMap = new Map<AccountTypeKeyType,Map<String,AccountTypeWrapper>>();    
        }
        
        if(!accountTypesMap.containsKey(keyType)) {
            Map<String,AccountTypeWrapper> accTypesMap = new Map<String, AccountTypeWrapper>{
                'DEFAULT' => new AccountTypeWrapper(null, null, DEFAULT_STEWARDSHIP_SYSTEM_NAME)
            };
            accountTypesMap.put(keyType, accTypesMap);
            
            Boolean isFrmUser = GNE_SFA2_Util.isFrmUser();
        
            for(CORE_Pub_Org_Typ_Map__c setting : CORE_Pub_Org_Typ_Map__c.getAll().values()) {
                if(setting.Active_gne__c && String.isNotBlank(setting.Account_Type_gne__c) && (String.isBlank(profileName) || isFrmUser==(setting.Account_Record_Type_gne__c==REC_TYPE_FRM_HCO))) {
                    AccountTypeWrapper accTypeWrapper = new AccountTypeWrapper(setting);
                    String key = accTypeWrapper.getKey(keyType);
                    
                    if(!accTypesMap.containsKey(key)) {
                        accTypesMap.put(accTypeWrapper.getKey(keyType), accTypeWrapper);
                    }
                }
            }
        }
        
        return accountTypesMap.get(keyType);
    }
    
    private static Map<String,Id> getRecordTypeIdsMap() {
        if(recordTypeIdsMap==null) {
            recordTypeIdsMap = new Map<String,Id>{
                REC_TYPE_HCP.toUpperCase() => null,
                REC_TYPE_CP.toUpperCase() => null
            };
            
            for(CORE_Pub_Org_Typ_Map__c setting : CORE_Pub_Org_Typ_Map__c.getAll().values()) {
                if(setting.Active_gne__c && String.isNotBlank(setting.Account_Type_gne__c)) {
                    recordTypeIdsMap.put(setting.Account_Record_Type_gne__c.toUpperCase(), null);
                }
            }
            
            List<RecordType> rts = recordTypeIdsMap.isEmpty() ? new List<RecordType>() : [
                SELECT Id, DeveloperName
                FROM RecordType
                WHERE DeveloperName IN :recordTypeIdsMap.keySet()
                    AND IsActive = true
                    AND SObjectType = 'Account'
            ];
            
            for(RecordType rt : rts) {
                recordTypeIdsMap.put(rt.DeveloperName.toUpperCase(), rt.Id);
            }
        }
        
        return recordTypeIdsMap;
    }
    
    private static Map<String,Id> getOwnerIdsMap() {
        if(ownerIdsMap==null) {
            ownerIdsMap = new Map<String,Id>();
            
            for(AccountTypeWrapper accTypeWrapper : getAccountTypesMap().values()) {
                if(accTypeWrapper.owner!=null) {
                    ownerIdsMap.put(accTypeWrapper.owner.toUpperCase(), null);
                }
            }
            
            List<User> usrs = ownerIdsMap.isEmpty() ? new List<User>() : [
                SELECT Id, External_Id_gne__c
                FROM User
                WHERE External_Id_gne__c IN :ownerIdsMap.keySet()
                    AND IsActive = true
            ];
            
            for(User usr : usrs) {
                ownerIdsMap.put(usr.External_Id_gne__c.toUpperCase(), usr.Id);
            }
        }
        
        return ownerIdsMap;
    }
    
    /*
    * functions returns owners configurations for all Account Types of FRM_HCO Accounts
    */
    public static Map<String, CORE_Pub_Org_Typ_Map__c> getFrmOwnerConfiguration() {
        if (frmOwnerConfiguration == null) {
            frmOwnerConfiguration = new  Map<String, CORE_Pub_Org_Typ_Map__c>();
            for(CORE_Pub_Org_Typ_Map__c conf : [
                SELECT Account_Owner_gne__c, Account_Type_gne__c 
                FROM CORE_Pub_Org_Typ_Map__c 
                WHERE Account_Record_Type_gne__c = :REC_TYPE_FRM_HCO
            ]) {
                frmOwnerConfiguration.put(conf.Account_Type_gne__c, conf);
            }
        }
        
        return frmOwnerConfiguration;
    }
    
    /*
    * function returns default owners for FRM_HCO Accounts
    * externalId to User
    */
    public static Map<String, User> prepareDefaultOwnerMap() {
        if(externalId2User == null) {
            externalId2User = new Map<String, User>();
            Set<String> defaultFRMOwners = fetchDefFRMOwners();
            for(User owner : [
                SELECT Id, External_ID_gne__c FROM User WHERE External_ID_gne__c IN : defaultFRMOwners
            ]) {
                externalId2User.put(owner.External_ID_gne__c, owner);
            }
        }
        
        return externalId2User;
    }
    
    private static Set<String> fetchDefFRMOwners() {
        Set<String> defOwners = new Set<String>();
        for(CORE_Pub_Org_Typ_Map__c conf : getFrmOwnerConfiguration().values()){
            defOwners.add(conf.Account_Owner_gne__c);
        }

        return defOwners;
    }
    
    public class AccountTypeWrapper {
        private String code;
        private String accountType;
        private String recordType;
        private String recordTypeLabel;
        private String ssn;
        private String owner;
        
        public AccountTypeWrapper(CORE_Pub_Org_Typ_Map__c setting) {
            this(setting.Account_Type_gne__c, setting.Account_Record_Type_gne__c, setting.Stewardship_System_Name_gne__c);
            this.code = setting.Name.substringBefore(':');
            this.recordTypeLabel = setting.Account_Record_Type_Display_gne__c;
            this.owner = setting.Account_Owner_gne__c;
        }
        
        public AccountTypeWrapper(String accountType, String recordType, String snn) {
            this.accountType = accountType;
            this.recordType = recordType;
            this.ssn = snn;
        }
        
        public String getAccountType() {
            return this.accountType;
        }
        
        public String getRecordType() {
            return this.recordType;
        }
        
        public String getRecordTypeLabel() {
            return this.recordTypeLabel;
        }
        
        public String getCode() {
            return this.code;
        }
        
        public String getSSN() {
            return this.ssn;
        }
        
        public String getOwner() {
            return this.owner;
        }
        
        public String getKey() {
            return getKey(AccountTypeKeyType.TYPE);
        }
        
        public String getKey(AccountTypeKeyType keyType) {
            String key = null;
            
            if(keyType==AccountTypeKeyType.TYPE) {
                key = getAccountType()!=null ? getAccountType().toUpperCase() : null;
            } else if(keyType==AccountTypeKeyType.CODE) {
                key = getCode()!=null ? getCode().toUpperCase() : null;
            } else if(keyType==AccountTypeKeyType.CODE_TYPE) {
                key = (getCode() + '_' + getAccountType()).toUpperCase();
            } else if(keyType==AccountTypeKeyType.RECORD_TYPE_ACCOUNT_TYPE) {
                key = (getRecordTypeId() + '_' + getAccountType()).toUpperCase();
            } else if(keyType==AccountTypeKeyType.RECORD_TYPE) {
                key = getRecordType()!=null ? getRecordType().toUpperCase() : null;
            }
            
            return key;
        }
        
        public String getRecordTypeKey() {
            return getKey(AccountTypeKeyType.RECORD_TYPE);
        }
        
        public String getRecordTypeId() {
            return getRecordTypeKey()!=null && getRecordTypeIdsMap().containsKey(getRecordTypeKey()) ? getRecordTypeIdsMap().get(getRecordTypeKey()) : null;
        }
        
        public String getOwnerId() {
            return getOwner()!=null ? getOwnerIdsMap().get(this.getOwner().toUpperCase()) : null;
        }
        
        public void updateAccount(Account acc) {
            acc.Stewardship_System_Name_gne__c = this.getSSN();
            
            Id recordTypeId = null;
            if((recordTypeId = getRecordTypeId())!=null) {
                acc.RecordTypeId = recordTypeId;    
            }
            
            Id ownerId = null;
            if((ownerId = getOwnerId())!=null) {
                acc.OwnerId = ownerId;
            }
        }
    }
}