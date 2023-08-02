public with sharing class GNE_SFA2_FRMAccountDCRController extends GNE_SFA2_AccountDCRController{
    public static final String ACCOUNT_MDM_STATUS_ACTIVE = 'Active';
    public Address_vod__c selectedAddress { get; set; }
    public Id selectedAddressId { get; set; }
    private boolean isAddresSelectorVisible;
    private Map<Id, Address_vod__c> id2Address = new Map<Id, Address_vod__c>();
    @testVisible private Change_Request_gne__c orginalChangeRequest;
    private Change_Request_gne__c addressChangeRequest;
    private Change_Request_gne__c accountChangeRequest;
    public String frmRecordTypeId { get; private set; }

    public GNE_SFA2_FRMAccountDCRController(ApexPages.StandardController stdController) {
        super(stdController);        
        initVariables();        
    }
    
    private void initVariables() {
        if(acct == null ) return;
        frmRecordTypeId = GNE_SFA2_Util.getFrmHcoAccountRecordTypeId();
        isAddresSelectorVisible = false;
        Boolean selected = false;
        changeRequest = null;
        for(Address_vod__c addr : acct.address_vod__r) {
            id2Address.put(addr.Id, addr);
            if(!selected){
                selected = true;
                selectedAddress = addr;
            }
        }
        if(selectedAddress == null) {
            selectedAddress = acct.address_vod__r.isEmpty() ? new Address_vod__c() : acct.address_vod__r[0];
        }
    }
    
    public PageReference chooseRecordType() {
        if (RequestRecordType.equalsIgnoreCase ('HCOChangeInfo')){
            DCRRequestType = RequestType.HCOChangeInfo;  
            isAddresSelectorVisible = true;
        } else if (RequestRecordType.equalsIgnoreCase ('HCODuplicate')){
            DCRRequestType = RequestType.HCODuplicate;                                                 
        } else if (RequestRecordType.equalsIgnoreCase ('HCOReactivate')){
            DCRRequestType = RequestType.HCOReactivate;                   
        }        
        
        changeRequest = fetchChangeRequest();
        orginalChangeRequest = fetchChangeRequest();    
        GNE_SFA2_DBCacheManager.initDmlCache();
        return null;
    }
    
    public Boolean getIsAddresSelectorVisible(){
        return isAddresSelectorVisible && id2Address.size() > 1;
    }
    
    public void selectAddress(){
        selectedAddress = id2Address.get(selectedAddressId);
        isAddresSelectorVisible = false;
    }
    
    private Change_Request_gne__c fetchChangeRequest() {
        Change_Request_gne__c changeReq = new Change_Request_gne__c();
        if(DCRRequestType == RequestType.HCOReactivate){
            DCRRequestType = acct.MDMID_Status_gne__c == ACCOUNT_MDM_STATUS_ACTIVE ? RequestType.HCOInactivate : RequestType.HCOReactivate;
        }
        changeReq.RecordTypeId = getRecordTypeId(mapRecordType.get(DCRRequestType.Name()));
        changeReq.Account_gne__c = acct.Id;
        changeReq.Reason_dcr_gne__c = '';
        changeReq.New_Organization_Name_gne__c = acct.name;
        changeReq.Account_type_dcr_gne__c      = acct.account_type_gne__c;
        changeReq.Specialties_hco_dcr_gne__c   = acct.group_specialty_1_vod__c;
        changeReq.Account_Group_gne__c         = acct.Group_gne__r.Name;
        changeReq.Address_Line_1_gne__c        = selectedAddress.Name;
        changeReq.Address_Line_2_gne__c        = selectedAddress.address_line_2_vod__c;
        changeReq.City_gne__c                  = selectedAddress.City_vod__c;
        changeReq.State_gne__c                 = selectedAddress.State_vod__c;
        changeReq.Zip_gne__c                   = selectedAddress.Zip_vod__c;
        return changeReq;
    }
    
    public PageReference saveRecord(){
        try {
            insert changeRequest;
        } catch (DMLException ex) {
            ApexPages.addMessages(ex);
            return null;              
        }  
        return (new ApexPages.StandardController(acct)).view();
    }
    
    public PageReference saveRequests() {
        List<Change_Request_gne__c> toInsert = new List<Change_Request_gne__c> ();
        createRequests();
        if(!compareRequests(addressChangeRequest, new List<String> {'Address_Line_1_gne__c','Address_Line_2_gne__c','City_gne__c','State_gne__c','Zip_gne__c'})){
            toInsert.add(addressChangeRequest);
        }
        if(!compareRequests(accountChangeRequest, new List<String> {'New_Organization_Name_gne__c','Account_type_dcr_gne__c','Account_Group_gne__c'})){
            toInsert.add(accountChangeRequest);
        }
        if(!toInsert.isEmpty()){
            Database.insert(toInsert);
            return (new ApexPages.StandardController(acct)).view();
        } else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,' Please change at least one attribute for your data change request.'));
            return null;
        }
    }
    
    private void createRequests(){
        addressChangeRequest = new Change_Request_gne__c(
            RecordTypeId           = selectedAddress.Id == null ? getRecordTypeId('AddressChange') : getRecordTypeId('HCO_Change_Address') ,
            current_address_gne__c = selectedAddress.Id == null ? null : selectedAddress.Id,
            Account_gne__c         = changeRequest.Account_gne__c,
            Address_Line_1_gne__c  = changeRequest.Address_Line_1_gne__c,
            Address_Line_2_gne__c  = changeRequest.Address_Line_2_gne__c,
            City_gne__c            = changeRequest.City_gne__c,
            State_gne__c           = changeRequest.State_gne__c,
            Zip_gne__c             = changeRequest.Zip_gne__c
        );
        accountChangeRequest = new Change_Request_gne__c(
            RecordTypeId                 = changeRequest.RecordTypeId,
            Account_gne__c               = changeRequest.Account_gne__c,
            Reason_dcr_gne__c            = changeRequest.Reason_dcr_gne__c,
            New_Organization_Name_gne__c = changeRequest.New_Organization_Name_gne__c, 
            Account_type_dcr_gne__c      = changeRequest.Account_type_dcr_gne__c, 
            Specialties_hco_dcr_gne__c   = changeRequest.specialties_hco_dcr_gne__c,  
            Account_Group_gne__c         = changeRequest.Account_Group_gne__c
        );
    }
    
    private Boolean compareRequests(Change_Request_gne__c chRequest, List<String> fields){
        Boolean isRecordsTheSame = true;
        for(String field : fields){
            Object orginal = orginalChangeRequest.get(field);
            Object req     = chRequest.get(field);
                
            if(String.isBlank(String.valueOf(orginal)) && String.isBlank(String.valueOf(req))){
                continue;
            }
            if(orginal != req){
                isRecordsTheSame = false;
                break;
            }
        } 
        
        return isRecordsTheSame;        
    }
    
    public Boolean getHCOReactivateInactivate() {
        return  DCRRequestType == RequestType.HCOReactivate || DCRRequestType == RequestType.HCOInactivate;
    }
    
    public Boolean getAccountActive() {
        changeRequest.Reason_dcr_gne__c = 'Re-acivate HCO'; //this value will be send only if we reactivate HCO, otherwise the value is taken from VFP 
        return acct.MDMID_Status_gne__c == ACCOUNT_MDM_STATUS_ACTIVE;
    }
    
    public String getLabelForDCRRequest(){
        String labelText = '<p><div><b>No label avilable for this DCR. Please report this issue to System Administrator.</div></b><p>';
        List<ExternalString> labels = [SELECT Value FROM ExternalString WHERE MasterLabel = :'FRM_' + DCRRequestType.Name() +'_Pre_gne'];
        if(!labels.isEmpty()){
            labelText = labels[0].Value;
        }
         
        return labelText;
    }
    
    public List<SelectOption> getOrganizationTypes(){
        List<SelectOption> orgTypeList = getOrgTypes();
        if(orgTypeList[0].getValue() == NONE_SELECTED){
            orgTypeList.remove(0);
        }
        
        return orgTypeList;
    }
    
     // USPS Address Validation Logic 

    @RemoteAction
    public static String addressValidate(Map<String, String> params) {
        return GNE_SFA2_USPSEngine.addressValidate(params);
    }

    @RemoteAction
    public static String cityStateLookup(Map<String, String> params) {
        return GNE_SFA2_USPSEngine.cityStateLookup(params);
    }

    @RemoteAction
    public static String zipCodeLookup(Map<String, String> params) {
        return GNE_SFA2_USPSEngine.zipCodeLookup(params);
    }
}