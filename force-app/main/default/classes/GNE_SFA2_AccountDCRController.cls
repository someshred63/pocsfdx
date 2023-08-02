public virtual with sharing class GNE_SFA2_AccountDCRController {
    
    public static final String NONE_SELECTED = '--None--';
    public transient List<SelectOption> orgTypeList; 
    public transient List<SelectOption> profTypeList;
    public enum RequestType {None, DCRRequestTypes, HCPChangeInfo, HCPDuplicate, HCPInactivate, HCPReactivate, HCOChangeInfo, HCODuplicate, HCOInactivate,
        ChangeAddress, RemoveDuplicateAddress, RemoveAddress, ReactivateAddress, HCOReactivate, HCPFMVTierRequest, USLicensedPhysician}
    public String RequestObjectType { get; set; } 
    public String RequestRecordType { get; set; }
    public List<SelectOption> accountAddresses { get; private set; }
    public List<SelectOption> selectedSpecialities { get; private set; }
    public Set<String> selectedSpecialitiesSet { get; private set; }
    public Boolean canadaStewardedHCP { get; private set; }

    protected String parameters = null;
    protected Account acct;
    protected Change_Request_gne__c changeRequest;
    protected Map<String,String> mapRecordType = new Map<String,String>{
        RequestType.HCPChangeInfo.Name() => 'HCP_Change_HCP_Info',
        RequestType.HCPDuplicate.Name()  => 'HCP_Remove_Duplicate',
        RequestType.HCPInactivate.Name() => 'HCP_Remove_Inactivate_HCP',
        RequestType.HCPReactivate.Name() => 'HCP_Reactivate_HCP',
        RequestType.HCOChangeInfo.Name() => 'HCO_Change_Organization_Info',
        RequestType.HCODuplicate.Name()  => 'HCO_Remove_Duplicate_Organization',
        RequestType.HCOInactivate.Name() => 'HCO_Remove_Inactivate_Organization',
        RequestType.HCOReactivate.Name() => 'HCO_Reactivate_Account',
        RequestType.HCPFMVTierRequest.Name() => 'HCP_FMV_Tier_request',
        RequestType.USLicensedPhysician.Name() => 'US_Licensed_Physician'
    };
    
    protected Map<String,String> addressRecordTypeDesc = new Map<String,String>{
        RequestType.ChangeAddress.Name() => 'Change Address',
        RequestType.RemoveDuplicateAddress.Name() => 'Remove Duplicate Address',
        RequestType.RemoveAddress.Name() => 'Remove/Inactivate Address',
        RequestType.ReactivateAddress.Name() => 'Reactivate Address'
    };
    
    protected RequestType DCRRequestType = RequestType.None;
    
    public GNE_SFA2_AccountDCRController(ApexPages.StandardController stdController) {       
        init();
        SObject sobjectInstance = stdController.getRecord();
        DCRRequestType = RequestType.DCRRequestTypes;
        
        if(sobjectInstance.getsObjectType() ==  Account.sObjectType){
            this.canadaStewardedHCP = false;
            String id = (String) sobjectInstance.get('Id');
            system.debug('accountId: '+ id);
            system.debug('account param id: '+ ApexPages.currentPage().getParameters().get('Id'));
            system.debug('params: '+ ApexPages.currentPage().getParameters());
            Set<Id> hiddenAddrIds = getHiddenAddressIds((Id)id);
            
            try {
                acct = [
                    SELECT
                        FirstName, LastName, Middle_vod__c, Suffix_gne__c, Suffix_vod__c,
                        Professional_type_gne__c, Credentials_gne__c, MDMID_Status_gne__c,
                        Specialties_gne__c, Specialties_can_gne__c, isPersonaccount,
                        Name, Account_type_gne__c, Group_specialty_1_vod__c, Stewardship_system_name_gne__c, 
                        Ams_id_gne__c, Mdmid_gne__c, Gender_vod__c, Group_gne__r.Name, Tier_Level_gne__c, HCP_Stakeholder_Type_gne__c,
                        Language_of_Preference_can_gne__c, Account_Type_RAMA_gne__c,
                        (SELECT Id, Name, Address_line_2_vod__c, City_vod__c, State_vod__c, Zip_vod__c, Postal_Code_can_gne__c, 
                           Province_can_gne__c, Primary_vod__c 
                         FROM Address_vod__r 
                         WHERE Id NOT  IN : hiddenAddrIds)
                    FROM
                        Account 
                    WHERE 
                        Id =: id 
                ];
                
                if(acct != null && acct.isPersonAccount){
                    RequestObjectType ='Person Account';
                } else{
                    RequestObjectType ='Account';
                }
                
                accountAddresses = new List<SelectOption>();
                
                for(Address_vod__c addr : acct.address_vod__r) {
                    accountAddresses.add(new SelectOption(addr.Id, getAddressLongName(addr)));
                }


                GNE_SFA2_User_App_Context_gne__c userApplicationContext = GNE_SFA2_Util.getUserApplicationContext();
                if(userApplicationContext != null && userApplicationContext.App_Name_gne__c == 'SFA-Canada') {
                    if(userApplicationContext.Role_gne__c == 'Manager' || userApplicationContext.Role_gne__c == 'TS' || userApplicationContext.Role_gne__c == 'OPS') {
                        this.canadaStewardedHCP = String.isNotBlank(acct.Account_Type_gne__c) ? true : false;
                    } else if(userApplicationContext.Role_gne__c == 'RAMA') {
                        this.canadaStewardedHCP = String.isNotBlank(acct.Account_Type_RAMA_gne__c) ? true : false;
                    }
                }

                if(this.canadaStewardedHCP) {
                    this.selectedSpecialities = getSelectedSpecialities(acct.Specialties_can_gne__c);
                }
                
            } catch (QueryException ex) {
                ApexPages.addMessages(ex);
            }                           
        } else {
            RequestObjectType = 'Address';          
        }
    }
    
    private Set<Id> getHiddenAddressIds(Id accId) {
        return (new GNE_SFA2_UserPreference_Ctrl()).getHiddenAddressIds(UserInfo.getUserId(), accId);
    }
    
    private String getAddressLongName(Address_vod__c ad) {
        return GNE_SFA2_Util.getAddressAsString(ad);
    }
    
    public String getPrimaryAddressLongName() {
        String result = '';
        for(Address_vod__c addr : acct.address_vod__r) {
            if (addr.Primary_vod__c) {
                result = getAddressLongName(addr);
                break;
            }
        }
        return result;
    }

    private  void  init() {    
        Map<String, String> paramMap = ApexPages.currentPage().getParameters();
        for (String key : paramMap.keySet()){
            parameters = parameters +  key + '=' + paramMap.get(key) + '<br>';                            
        }        
    }
    
    public String getParameters() {
        return parameters;
    }

    protected Id getRecordTypeId (String recordTypeName) {
        return [SELECT Id FROM RecordType WHERE isActive=true AND DeveloperName =:recordTypeName AND sObjectType ='change_request_gne__c'].Id ;    
    }
    
    public Boolean getDCRRequestTypes() {
        return (DCRRequestType == RequestType.DCRRequestTypes);   
    }

    //method to indicate whether the logged on user is a Canada user
    public Boolean getHasCanadaProfile() {
        return GNE_SFA2_Util.isCanadaUser();
    }

    //method do indicate whether the logged on user has access to FMV Tier section
    public Boolean getHasCanadaTierSectionProfile() {
        String profileName = GNE_SFA2_Util.getCurrentUserProfileName();
        return getHasCanadaProfile() 
                && profileName != null 
                && (profileName.toUpperCase().contains('SFA-OPS') || profileName.toUpperCase().contains('SFA-MANAGER')
                    || profileName.toUpperCase().contains('SFA-RAMA') || profileName.toUpperCase().contains('SFA-ReadOnly')
                    || profileName.toUpperCase().contains('SFA-SAM') || profileName.toUpperCase().contains('SFA-TS'));
    }

    public String getRequestLabelDisplayText() {
        String labelText = '';
        try {
            if(getHasCanadaProfile() && (getHCPChangeInfo() || getHCOChangeInfo())){
                labelText = [SELECT id, value FROM externalstring WHERE masterlabel =: DCRRequestType.Name() + '_Pre_can_gne'].value; 
            }else{
                labelText = [SELECT id, value FROM externalstring WHERE masterlabel =: DCRRequestType.Name() + '_Pre_gne'].value; 
            }
        } catch (Exception e) {
            // no exception handled.            
        }
        return labelText;
    } 
    
    // HCP DCR Request Types
    public Boolean getHCPDCRRequestTypes() {
        return ((DCRRequestType == RequestType.DCRRequestTypes) && (acct.IsPersonAccount == true) );                  
    }

    // HCO DCR Requests Types
    public Boolean getHCODCRRequestTypes() {
        return ((DCRRequestType == RequestType.DCRRequestTypes) && (acct.IsPersonAccount == false));                  
    }

    // HCP 
    public Boolean getHCPChangeInfo() {
        return (DCRRequestType == RequestType.HCPChangeInfo);   
    }
    
    public Boolean getHCPDuplicate() {
        return (DCRRequestType == RequestType.HCPDuplicate);   
    }
    
    public Boolean getHCPInactivate() {
        return (DCRRequestType == RequestType.HCPInactivate);   
    }
    
    public Boolean getHCPReactivate() {
        return (DCRRequestType == RequestType.HCPReactivate);   
    }

    // HCO
    public Boolean getHCOChangeInfo() {
        return (DCRRequestType == RequestType.HCOChangeInfo);   
    }
    public Boolean getHCODuplicate() {
        return (DCRRequestType == RequestType.HCODuplicate);   
    }
    public Boolean getHCOInactivate() {
        return (DCRRequestType == RequestType.HCOInactivate);   
    }
    public Boolean getHCPFMVTierRequest() {
        return (DCRRequestType == RequestType.HCPFMVTierRequest);   
    }
    public Boolean getUSLicensedPhysician() {
        return (DCRRequestType == RequestType.USLicensedPhysician);
    }
    
    // navigation - selection of recordTypes
    public PageReference selectRecordType() {
        PageReference result = null;
        Boolean isOk = true;
        // HCP             
        if (RequestRecordType.equalsIgnoreCase ('HCPChangeInfo')){
            DCRRequestType = RequestType.HCPChangeInfo;                                                 
        }else if (RequestRecordType.equalsIgnoreCase ('HCPDuplicate')){
            DCRRequestType = RequestType.HCPDuplicate;                                                 
        }else if (RequestRecordType.equalsIgnoreCase ('HCPInactivate')){
            DCRRequestType = RequestType.HCPInactivate;
        }else if (RequestRecordType.equalsIgnoreCase ('HCPReactivate')){
            DCRRequestType = RequestType.HCPReactivate;    
                
        // HCO
        }else if (RequestRecordType.equalsIgnoreCase ('HCOChangeInfo')){
            DCRRequestType = RequestType.HCOChangeInfo;                                                 
        }else if (RequestRecordType.equalsIgnoreCase ('HCODuplicate')){
            DCRRequestType = RequestType.HCODuplicate;                                                 
        }else if (RequestRecordType.equalsIgnoreCase ('HCOInactivate')){
            DCRRequestType = RequestType.HCOInactivate;                   
        }else if (RequestRecordType.equalsIgnoreCase ('HCPFMVTierRequest')){
            DCRRequestType = RequestType.HCPFMVTierRequest;                       
        }else if (RequestRecordType.equalsIgnoreCase ('USLicensedPhysician')){
            DCRRequestType = RequestType.USLicensedPhysician;
        }else if(RequestRecordType.endsWithIgnoreCase ('Address')){
            isOk = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,String.format(System.Label.GNE_SFA2_HideAddress_Error_AddressIsRequired, new String[]{addressRecordTypeDesc.get(RequestRecordType) + ' DCR'})));
        } 
        
        if(isOk) {
	        // initialize change request
		    changeRequest = new Change_Request_gne__c();
			changeRequest.RecordTypeId = getRecordTypeId(mapRecordType.get(DCRRequestType.Name()));
		    changeRequest.account_gne__c = acct.Id;
		    changeRequest.Reason_dcr_gne__c = '';
		    
		    if (RequestObjectType.equalsIgnoreCase ('Person Account')) {
	            changeRequest.first_name_dcr_gne__c        = acct.firstName;
	            changeRequest.last_name_dcr_gne__c         = acct.lastname;
	            changeRequest.suffix_DCR_gne__c            = acct.suffix_vod__c != null ? acct.suffix_vod__c : acct.suffix_Gne__c;
	            changeRequest.new_value_2_Gne__c           = acct.middle_vod__c;
	            changeRequest.professional_type_dcr_gne__c = acct.professional_type_gne__c;
	            changeRequest.account_type_dcr_gne__c      = acct.account_type_gne__c;
	            changeRequest.credentials_dcr_gne__c       = acct.credentials_gne__c;
	            changeRequest.specialties_hcp_dcr_gne__c   = getHasCanadaProfile() ? acct.Specialties_can_gne__c : acct.specialties_gne__c;
                changeRequest.Tier_Level_gne__c            = acct.Tier_Level_gne__c;
                changeRequest.HCP_Stakeholder_Type_gne__c  = acct.HCP_Stakeholder_Type_gne__c;
                changeRequest.Language_of_Preference_dcr_gne__c  = acct.Language_of_Preference_can_gne__c;
		    } else {
	            changeRequest.New_Organization_Name_gne__c = acct.name;
	            changeRequest.account_type_dcr_gne__c      = acct.account_type_gne__c;
	            changeRequest.specialties_hco_dcr_gne__c   = acct.group_specialty_1_vod__c;
	        }
        }
               
        return result;
    }

    public Account getAccount() {
        return acct; 
    }

    public Boolean getIsAccountAMSStewarded() {
        Boolean bRet = false;  
        
        if((acct.stewardship_system_name_gne__c != null) && acct.stewardship_system_name_gne__c.equalsIgnoreCase('ams')){ 
             bRet = true;
        }
        return bRet;
    }

    public PageReference confirm() {
        try {
            if(this.selectedSpecialities != null) {
                changeRequest.Specialties_HCP_DCR_gne__c = getSelectedSpecialities();
            }
            insert changeRequest;
        } catch (DMLException ex) {
            ApexPages.addMessages(ex);
            return null;              
        }           
        String status = [SELECT Status_gne__c FROM Change_Request_gne__c where id = :changeRequest.Id].Status_gne__c;
        PageReference acctPage = (new ApexPages.StandardController(acct)).view();
        acctPage.getParameters().put('DCRStatus', status);
        acctPage.setRedirect(true);
        return acctPage;
    }

    public PageReference cancel() {
        return (new ApexPages.StandardController(acct)).view();
        
    }
 
    public Change_Request_gne__c getChangeRequest() {
        return changeRequest;              
    }
    
    // usability
    public List<SelectOption> getAccountTypeValues() { 
        List<SelectOption> accountTypeOptions = new List<SelectOption>();
        // field describe of Account.Account_Type_gne__c  
        Schema.DescribeFieldResult acctTypeDescribe = Account.Account_Type_gne__c.getDescribe();
        List<Schema.PicklistEntry> pickListValues   = acctTypeDescribe.getPicklistValues();
        for (Schema.PicklistEntry pickListItem : pickListValues ){
            accountTypeOptions.add ( new SelectOption(pickListItem.getLabel(), pickListItem.getValue()));
        }
        return accountTypeOptions;              
    }
    
    public List<SelectOption> getCredentialsValues() {         
        List<SelectOption> credentialsValues = new List<SelectOption>();        
        // field describe of Account.Credentials_gne__C  
        Schema.DescribeFieldResult credentialsDescribe = Account.Credentials_gne__c.getDescribe();
        List<Schema.PicklistEntry> pickListValues   = credentialsDescribe.getPicklistValues();
        for (Schema.PicklistEntry pickListItem : pickListValues ){
            credentialsValues.add ( new SelectOption(pickListItem.getLabel(), pickListItem.getValue()) );
        }
        return credentialsValues;              
    }

    public List<SelectOption> getSpecialtiesValues() {         
        List<SelectOption> specialtiesValues = new List<SelectOption>();        
        // field describe of Account.specialties_gne__C or Account.Specialties_can_gne__c depending on profile
        Schema.DescribeFieldResult specialtiesDescribe = getHasCanadaProfile() ? Account.Specialties_can_gne__c.getDescribe() : Account.specialties_gne__c.getDescribe();
        List<Schema.PicklistEntry> pickListValues   = specialtiesDescribe.getPicklistValues();
        for (Schema.PicklistEntry pickListItem : pickListValues ){
            specialtiesValues.add ( new SelectOption(pickListItem.getLabel(), pickListItem.getValue()));
        }
        return specialtiesValues;              
    }

    public List<SelectOption> getTierLevelValues() {         
        List<SelectOption> tierLevelValues = new List<SelectOption>();        
        // field describe of Account.Tier_Level_gne__c  
        Schema.DescribeFieldResult tierLevelDescribe = Account.Tier_Level_gne__c.getDescribe();
        List<Schema.PicklistEntry> pickListValues   = tierLevelDescribe.getPicklistValues();
        tierLevelValues.add(new SelectOption(NONE_SELECTED, NONE_SELECTED));
        for (Schema.PicklistEntry pickListItem : pickListValues ){
            tierLevelValues.add ( new SelectOption(pickListItem.getLabel(), pickListItem.getValue()) );
        }
        return tierLevelValues;              
    }   

    public List<SelectOption> getHCPStateOfLicenseValues() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult licenseStateDescribe = Change_Request_gne__c.License_State_gne__c.getDescribe(); //Account.Type.getDescribe();
        List<Schema.PicklistEntry> pickListValues = licenseStateDescribe.getPicklistValues();
        for(Schema.PicklistEntry pickListItem : pickListValues) {
            options.add(new SelectOption(pickListItem.getLabel(), pickListItem.getValue()));
        }
        return options;
    }

    public List<SelectOption> getHCPStakeholderTypeValues() {         
        List<SelectOption> hcpStakeholderTypeValues = new List<SelectOption>();        
        // field describe of Account.HCP_Stakeholder_Type_gne__c  
        Schema.DescribeFieldResult hcpStakeholderTypeDescribe = Account.HCP_Stakeholder_Type_gne__c.getDescribe();
        List<Schema.PicklistEntry> pickListValues   = hcpStakeholderTypeDescribe.getPicklistValues();
        hcpStakeholderTypeValues.add(new SelectOption(NONE_SELECTED, NONE_SELECTED));
        for (Schema.PicklistEntry pickListItem : pickListValues ){
            hcpStakeholderTypeValues.add ( new SelectOption(pickListItem.getLabel(), pickListItem.getValue()) );
        }
        return hcpStakeholderTypeValues;              
    }

    private String getAccountDuplicateInfo (Id id) {        
        String acctInfo = '';        
        try {
            if ( id != null) {          
                Account acct = [select id, createdBy.FirstName, CreatedBy.LastName, Name, createdDate from Account where id =: id ];            
                acctInfo = '<b>Created By:</b> '            +   
                           acct.createdBy.FirstName    + ' ' + 
                           acct.createdBy.LastName     + '. ' +
                           '<b>Created Date:</b> '          +
                           acct.createdDate         + ' (<b>SFDC Id:</b> '+ 
                           acct.Id                  + ')' ;                             
            }
                
        } catch (Exception e) {
            System.debug ( e.getMessage());
        }

        return acctInfo;            
    }
    
    public String getAccount1Info() {
        return getAccountDuplicateInfo(acct.Id); 
    }

    public String getAccount2Info() {
        return getAccountDuplicateInfo(changeRequest.Duplicate_Account_2_gne__c);              
    }

    public String getAccount3Info() {
        return getAccountDuplicateInfo(changeRequest.Duplicate_Account_3_gne__c);              
    }

    public String getAccount4Info() {
        return getAccountDuplicateInfo(changeRequest.Duplicate_Account_4_gne__c);              
    }

    public String getAccount5Info() {
        return getAccountDuplicateInfo(changeRequest.Duplicate_Account_5_gne__c);              
    }

    public String getActiveMenuItem() {
       return 'DCR';
    }
    
    public List<SelectOption> getOrgTypes(){
		if(orgTypeList == null){
			orgTypeList = getOrgTypesList();
		}
		return orgTypeList;
	}
	
	public static List<SelectOption> getOrgTypesList(){
		return getOrgTypesList(GNE_SFA2_Util.getCurrentUserProfileName());
	}
	
	public static List<SelectOption> getOrgTypesList(String profileName){
		List<SelectOption> orgTypeList = new List<SelectOption>();
		orgTypeList.add(new SelectOption(NONE_SELECTED, NONE_SELECTED));
		Map<String, String> orgTypesMap = getOrgTypesMap(profileName);
		for (String iValue : orgTypesMap.keyset()){
			orgTypeList.add(new SelectOption(orgTypesMap.get(iValue), iValue));
		}
		sortSelectOptions(orgTypeList, 1, orgTypeList.size() - 1);
		return orgTypeList;
	} 
	
	public static Map<String, String> getOrgTypesMap(){
		return getOrgTypesMap(GNE_SFA2_Util.getCurrentUserProfileName());
	}
	
	public static Map<String, String> getOrgTypesMap(String profileName){
		Map<String, String> valueToLabelMap = new Map<String, String>();
		if (GNE_SFA2_Util.isCanadaUser()){
			Map<String, String> recTypeMap = getAccountRecordTypes();
			Map<String, GNE_SFA_Canada_HCO_Record_Types__c> orgTypeMapCanada = GNE_SFA_Canada_HCO_Record_Types__c.getAll();
			for(GNE_SFA_Canada_HCO_Record_Types__c row : orgTypeMapCanada.values()){
				if (recTypeMap.containsKey(row.RecordType__c)){
					valueToLabelMap.put(row.RecordTypeDisplay__c, row.RecordTypeDisplay__c);
				}
			}
			String rCanadaHDepartment = 'GNE-SFA-Roche_Canada_Hospital_Depatment';
			if (recTypeMap.containsKey(rCanadaHDepartment)){
				valueToLabelMap.put('Hospital Department', 'Hospital Department');
			}
		} else {
			for (GNE_SFA2_Account_Trigger_Helper.AccountTypeWrapper atWrapper : GNE_SFA2_Account_Trigger_Helper.getAccountTypesMap(profileName).values()) {
				if (atWrapper.getRecordTypeId() != null) {
					valueToLabelMap.put(atWrapper.getAccountType(), atWrapper.getAccountType());
                }
			}
		}
		return valueToLabelMap;
	}
    
    //get list of HCP Professional Types via Custom Setting
    public List<SelectOption> getProfTypes(){
        if(profTypeList == null){
            profTypeList = new List<SelectOption>();
            if (GNE_SFA2_Util.isCanadaUser()){
            	profTypeList.add(new SelectOption(NONE_SELECTED, NONE_SELECTED));
            }
            Map<String, String> profTypesMap = getProfTypesMap();
            for (String iValue : profTypesMap.keyset()){
            	profTypeList.add(new SelectOption(profTypesMap.get(iValue), iValue));
            }
            sortSelectOptions(profTypeList, 1, profTypeList.size() - 1);
        }   
        return profTypeList;
    }
    
    public static Map<String, String> getProfTypesMap(){
    	Map<String, String> valueToLabelMap = new Map<String, String>();
		if (GNE_SFA2_Util.isCanadaUser()){
			Map<String, GNE_SFA_Canada_HCP_Record_Types__c> typeMap = GNE_SFA_Canada_HCP_Record_Types__c.getAll();
			if(typeMap != null && typeMap.size() > 0){
				for (GNE_SFA_Canada_HCP_Record_Types__c row : typeMap.values()){
					valueToLabelMap.put(row.RecordType__c, row.RecordType__c);
                }
			}
		} else {
			List<Schema.PicklistEntry> pickListValues = Account.Professional_Type_gne__c.getDescribe().getPicklistValues();
        	for (Schema.PicklistEntry pickListItem : pickListValues){
        		valueToLabelMap.put(pickListItem.getValue(), pickListItem.getLabel());
        	}
		}
		return valueToLabelMap;
    }

    public List<SelectOption> getLanguageOfPreferences() {
        List<SelectOption> languageOfPreferenceList = new List<SelectOption>();
        languageOfPreferenceList.add(new SelectOption(NONE_SELECTED, NONE_SELECTED));
        List<Schema.PicklistEntry> pickListValues = Account.Language_of_Preference_can_gne__c.getDescribe().getPicklistValues();
        for (Schema.PicklistEntry pickListItem : pickListValues) {
            languageOfPreferenceList.add(new SelectOption(pickListItem.getValue(), pickListItem.getLabel()));
        }
        return languageOfPreferenceList;
    }

    public List<SelectOption> getSpecialities() {
        List<SelectOption> specialities = new List<SelectOption>();
        List<Schema.PicklistEntry> pickListValues = Account.Specialties_can_gne__c.getDescribe().getPicklistValues();
        for (Schema.PicklistEntry pickListItem : pickListValues) {
            if(!this.selectedSpecialitiesSet.contains(pickListItem.getValue())) {
                specialities.add(new SelectOption(pickListItem.getValue(), pickListItem.getLabel()));
            }
        }
        return specialities;
    }

    public String getSelectedSpecialities() {
        String selectedSpecialitiesTmp = '';
        for(System.SelectOption so : this.selectedSpecialities) {
            if(String.isNotBlank(selectedSpecialitiesTmp)) {
                selectedSpecialitiesTmp += ';' + so.getValue();
            } else {
                selectedSpecialitiesTmp += so.getValue();
            }

        }
        return selectedSpecialitiesTmp;
    }

    public List<SelectOption> getSelectedSpecialities(String selectedSpecialities) {
        this.selectedSpecialitiesSet = new Set<String>();
        List<SelectOption> specialities = new List<SelectOption>();
        if(String.isNotBlank(selectedSpecialities)) {
            for(String spec : selectedSpecialities.split(';')) {
                specialities.add(new SelectOption(spec, spec));
                this.selectedSpecialitiesSet.add(spec);
            }
        }
        return specialities;
    }
    
    private static Map<String, String> getAccountRecordTypes() {
        Map <String, String> recTypeMap = new Map <String, String>();       
        
        Schema.DescribeSObjectResult d = Schema.SObjectType.Account;
        Map<Id,Schema.RecordTypeInfo> rtMapById = d.getRecordTypeInfosById();
        
        Map <Id, RecordType> rtMap = new Map<Id, RecordType>([SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account' ORDER BY Name]);
        
        for(Id rtId : rtMapById.keyset()){
             Schema.RecordTypeInfo rtById = rtMapById.get( rtId );
             if (rtById.IsAvailable() == true ){
                RecordType rt = rtMap.get(rtId);
                if(rt != null){
                	recTypeMap.put(rt.Name, rt.Id);
                }
             }   
        }
        return recTypeMap;
    }
    
    private static void sortSelectOptions(List<SelectOption> a, Integer lo0, Integer hi0) {
        Integer lo = lo0;
        Integer hi = hi0;
        
        if (lo >= hi) {
            return;
        } else if( lo == hi - 1 ) {
        
            if (a[lo].getLabel() > a[hi].getLabel()) {
                SelectOption o = a[lo];
                a[lo]         = a[hi];
                a[hi]         = o;
            }
            return;
        }
        SelectOption pivot = a[(lo + hi) / 2];
        a[(lo + hi) / 2] = a[hi];
        a[hi] = pivot;
        while( lo < hi ) {
            while (a[lo].getLabel() <= pivot.getLabel() && lo < hi) { lo++; }
            while (pivot.getLabel() <= a[hi].getLabel() && lo < hi ) { hi--; }
            
            if( lo < hi ){
                SelectOption o = a[lo];
                a[lo]         = a[hi];
                a[hi]         = o;
            }
        }
        
        a[hi0] = a[hi];
        a[hi] = pivot;
        
        sortSelectOptions(a, lo0, lo-1);
        sortSelectOptions(a, hi+1, hi0);
    }   
}