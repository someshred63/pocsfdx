public with sharing class AccountDCRController {
    
    public static final String NONE_SELECTED = '--None--';
    public transient List<SelectOption> orgTypeList; 
    public transient List<SelectOption> profTypeList;
    public enum RequestType {None, DCRRequestTypes, HCPChangeInfo, HCPDuplicate, HCPInactivate, HCPReactivate, HCOChangeInfo, HCODuplicate,HCOInactivate}
    public String RequestObjectType { get; set; } 
    public string RequestRecordType { get; set; }

    private String parameters = null;
    private Account acct;
    private Change_Request_gne__c changeRequest;    
    private Map<String,String> mapRecordType = new Map<String,String>{
               RequestType.HCPChangeInfo.Name() => 'HCP_Change_HCP_Info',
               RequestType.HCPDuplicate.Name()  => 'HCP_Remove_Duplicate',
               RequestType.HCPInactivate.Name() => 'HCP_Remove_Inactivate_HCP',
               RequestType.HCPReactivate.Name() => 'HCP_Reactivate_HCP',

               RequestType.HCOChangeInfo.Name() => 'HCO_Change_Organization_Info',
               RequestType.HCODuplicate.Name()  => 'HCO_Remove_Duplicate_Organization',
               RequestType.HCOInactivate.Name() => 'HCO_Remove_Inactivate_Organization'
    };
    private RequestType DCRRequestType = RequestType.None;
    
    public AccountDCRController(ApexPages.StandardController stdController) {       
        init();
        SObject sobjectInstance = stdController.getRecord();
        DCRRequestType = RequestType.DCRRequestTypes;
        
        if(sobjectInstance.getsObjectType() ==  Account.sObjectType){
            String id = (String) sobjectInstance.get('Id');
            try {
                acct = [select firstname,lastname,middle_vod__c,suffix_gne__c,suffix_vod__c,
                           professional_type_gne__c,credentials_gne__c,
                           specialties_gne__c, specialties_can_gne__c, ispersonaccount,  
                           name, account_type_gne__c, group_specialty_1_vod__c,
                           stewardship_system_name_gne__c, ams_id_gne__c, mdmid_gne__c
                           ,Gender_vod__c  
                           from account where id =: id ];
                
                if(acct!=null && acct.isPersonAccount){
                    RequestObjectType ='Person Account';
                } else{
                    RequestObjectType ='Account';           
                }
            } catch (QueryException ex) {
                ApexPages.addMessages(ex);
            }                           
        } else {
            RequestObjectType = 'Address';          
        }
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

    private Id getRecordTypeId (String recordTypeName) {
    	system.debug(recordTypeName);
        return [SELECT Id FROM RecordType WHERE isActive=true AND DeveloperName =:recordTypeName AND sObjectType ='change_request_gne__c'].Id ;    
    }
    
    public Boolean getDCRRequestTypes() {
        return (DCRRequestType == RequestType.DCRRequestTypes);   
    }

    //method to indicate whether the logged on user is a Canada user
    public Boolean getHasCanadaProfile() {
        return GNE_SFA2_Util.isCanadaUser();
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

    // navigation - selection of recordTypes
    public PageReference selectRecordType() {        
        if (RequestRecordType.equalsIgnoreCase ('OtherFAQ')){
            if(!getHasCanadaProfile()){
                return Page.DCR_FAQ;
            }else{
                return Page.DCR_FAQ_Canada;
            }
        }else if (RequestRecordType.equalsIgnoreCase ('HCPChangeAddress')){
            return (new ApexPages.StandardController(acct)).view();
        }else if (RequestRecordType.equalsIgnoreCase ('HCOChangeAddress')){ 
            return (new ApexPages.StandardController(acct)).view();
        // HCP             
        }else if (RequestRecordType.equalsIgnoreCase ('HCPChangeInfo')){
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
        }                              

        // initialize change request
        changeRequest = new Change_Request_gne__c();
		system.debug(DCRRequestType.Name());
		
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

        } else {
            changeRequest.New_Organization_Name_gne__c = acct.name;
            changeRequest.account_type_dcr_gne__c      = acct.account_type_gne__c;
            changeRequest.specialties_hco_dcr_gne__c   = acct.group_specialty_1_vod__c;                
        }            
        return null;
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
            insert changeRequest;
        } catch (DMLException ex) {
            ApexPages.addMessages(ex);
            return null;              
        }           
        String status = [SELECT Status_gne__c FROM Change_Request_gne__c where id = :changeRequest.Id].Status_gne__c;
		PageReference acctPage = new PageReference ('/apex/AccountDCRConfirmation?id=' + acct.Id + 
                                                    '&status=' + status);
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

    public List<SelectOption> getProfessionalTypeValues() {         
        List<SelectOption> profTypeValues = new List<SelectOption>();        
        // field describe of Account.Professional_Type  
        Schema.DescribeFieldResult profTypeDescribe = Account.Professional_Type_gne__c.getDescribe();
        List<Schema.PicklistEntry> pickListValues   = profTypeDescribe.getPicklistValues();
        for (Schema.PicklistEntry pickListItem : pickListValues ){
            profTypeValues.add ( new SelectOption(pickListItem.getLabel(), pickListItem.getValue()));
        }
        return profTypeValues;              
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
        List<SelectOption> options;
        if(orgTypeList == null){
            options = new List<SelectOption>();
            options.add(new SelectOption(NONE_SELECTED, NONE_SELECTED));
            
            // Check Canada RTypes access
            if(getHasCanadaProfile()){
                Map <String, String> recTypeMap = getAccountRecordTypes();
                Map <String, GNE_SFA_Canada_HCO_Record_Types__c> orgTypeMapCanada = GNE_SFA_Canada_HCO_Record_Types__c.getAll();
                for(GNE_SFA_Canada_HCO_Record_Types__c row : orgTypeMapCanada.values()){
                    if (recTypeMap.containsKey(row.RecordType__c)){             
                        options.add(new SelectOption(row.RecordTypeDisplay__c, row.RecordTypeDisplay__c));
                    }
                }
                String rCanadaHDepartment = 'GNE-SFA-Roche_Canada_Hospital_Depatment';
                if (recTypeMap.containsKey(rCanadaHDepartment)){    
                    options.add(new SelectOption('Hospital Department', 'Hospital Department'));
                }
            }else{ // Check USA RTypes access
                for(GNE_SFA2_Account_Trigger_Helper.AccountTypeWrapper atWrapper : GNE_SFA2_Account_Trigger_Helper.getAccountTypesMap(GNE_SFA2_Util.getCurrentUserProfileName()).values()) {
                    if(atWrapper.getRecordTypeId()!=null) {
                        options.add(new SelectOption(atWrapper.getAccountType(), atWrapper.getAccountType()));
                    }
                }
            }
            sortSelectOptions(options, 1, options.size() - 1);
            orgTypeList = removeDups(options);
        }
        return orgTypeList;
    }
    
    //get list of HCP Professional Types via Custom Setting
    public List<SelectOption> getProfTypes(){
        List<SelectOption> options;
        if(profTypeList == null){
            options = new List<SelectOption>();
            options.add(new SelectOption(NONE_SELECTED, NONE_SELECTED));
            
            if(getHasCanadaProfile()){
                Map <String, GNE_SFA_Canada_HCP_Record_Types__c> typeMap = GNE_SFA_Canada_HCP_Record_Types__c.getAll();
                if(typeMap != null && typeMap.size() > 0){
                    for (GNE_SFA_Canada_HCP_Record_Types__c row : typeMap.values()){
                        options.add(new SelectOption(row.RecordType__c, row.RecordType__c));                    
                    }
                    sortSelectOptions(options, 1, options.size() - 1);
                    profTypeList = removeDups(options);
                }
            }else{
                Map <String, GNE_Foun_Role_Ranking_gne__c> typeMap = GNE_Foun_Role_Ranking_gne__c.getAll();
                if(typeMap != null && typeMap.size() > 0){
                    for (GNE_Foun_Role_Ranking_gne__c row : typeMap.values()){
                        options.add(new SelectOption(row.Account_Professional_Type_gne__c, row.Account_Professional_Type_gne__c));                  
                    }
                    sortSelectOptions(options, 1, options.size() - 1);
                    profTypeList = removeDups(options);
                }
            }
        }   
        return profTypeList;
    }
    
    private  Map <String, String> getAccountRecordTypes() {
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
    
    private List<SelectOption> removeDups(List<SelectOption> inList) {
        List<SelectOption> newList = new List<SelectOption>{};
        String currVal;
        for (SelectOption row : inList) {
            if (currVal != row.getLabel()) {
                newList.add(row);   
            }
            currVal = row.getLabel();
        }   
        return newList; 
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