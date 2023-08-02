global class GENE_SFDC_FOUN_INT_ACCT {    
    //  Request Classes    
    global class Account_stub{
        WebService string Account_Type_gne;
        WebService string AMS_ID_gne;
        WebService string Cell_Phone_gne;
        WebService string Credentials_gne;
        WebService string Date_of_Birth_gne;
        WebService string Fax;
        WebService string Firstname;
        WebService string Gender_vod;
        WebService string Id;
        WebService string Lastname;
        WebService DateTime MDM_Update_Date_gne;
        WebService string MDMID_gne;
        WebService string MDMID_Status_gne;
        WebService string Middle_gne;
        WebService string Name;
        WebService string Phone;
        WebService string Preferred_Name_vod;
        WebService string Professional_Type_gne;
        WebService string RecordTypeId;
        WebService string Salutation;
        WebService string Specialties_gne;
        WebService string Suffix_gne;
        WebService string Website;
        WebService string Plan_Type_gne;
        WebService string Plan_Product_Type_gne;
        WebService string Payer_gne;
        WebService string Plan_gne;
        WebService string Carrier_gne;
        
        //Added for PFT June 09 (D5) release
        WebService string Account_Level_gne; //pftD5
        WebService integer Lives_Medical_gne; //pftD5
        WebService integer Lives_Pharmacy_gne; //pftD5
    }
    global class Account_External_Id_gne_stub{
        WebService string Third_Party_gne;
        WebService string Third_Party_Id_gne;
        WebService string Third_Party_Index_gne;
        WebService string MDMID_gne;
    }
    global class Address_stub{
        WebService List<Address_External_Id_gne_stub> Address_External_Ids;
        WebService string Address_line_2_vod;
        WebService string Address_Line_3_gne;
        WebService string Address_Line_4_gne;
        WebService boolean Billing_vod;
        WebService boolean Business_vod;
        WebService string City_vod;
        WebService string Country_gne;
        WebService string Fax_vod;
        WebService boolean Hospital_gne;
        WebService string License_vod;
        WebService Date License_Expiration_Date_vod;
        WebService string License_Status_vod;
        WebService boolean Mailing_vod;
        WebService string MDM_Address_ID_gne;
        WebService string Name;
        WebService boolean Office_gne;
        WebService string Phone_1_Ext_gne;
        WebService string Phone_vod;
        WebService string Phone_2_vod;
        WebService boolean Shipping_vod;
        WebService string State_vod;
        WebService string Zip_4_vod;
        WebService string Zip_vod;
        WebService boolean GOLD_RECORD_gne;
        WebService string Phone_2_Ext_gne;
        WebService boolean Active_Flag_gne;
    }
    global class Address_External_Id_gne_stub{
        WebService string Third_Party_gne;
        WebService string Third_Party_Id_gne;
        WebService string Third_Party_Index_Id_gne;
    }
    global class RequestAccountFoundationItem {
        WebService Account_stub Account;
        WebService List<Account_External_Id_gne_stub> Account_External_Ids;
        WebService List<String> Ids;
        WebService List<Address_stub> Addresses;
        WebService String Carrier_MDM_Id;
        WebService String Payer_MDM_Id;
        WebService String HCAO_MDM_Id;
        WebService String SourceSystemIdentifier;
    }
    global class RequestAccountFoundation {
        WebService String Transaction_Id;
        WebService String SourceSystem;
        WebService String PartyType;
        WebService List<RequestAccountFoundationItem> RequestItems;
    }    
    //  Response Classes
    global class ResponseAccountFoundation{
        public ResponseAccountFoundation(){
            this.ResponseErrorItems=new List<ResponseAccountErrorStatus>();
            this.ResponseItems=new List<ResponseAccountFoundationItem>();
            this.StartTime=DateTime.now();
        }
        WebService ResponseStatus BatchStatus;
        WebService List<ResponseAccountErrorStatus> ResponseErrorItems;
        WebService List<ResponseAccountFoundationItem> ResponseItems;
        WebService DateTime StartTime;
        WebService DateTime EndTime;
        WebService String ErrorCode;
        WebService String ErrorMessage;
        WebService String ErrorDetails;
        WebService String Transaction_Id;
        WebService String SourceSystem;
    }
    global class ResponseAccountErrorStatus {
        public ResponseAccountErrorStatus(){
            this.ErrorCode=new List<String>();
            this.ErrorDetails=new List<String>();
        }
        WebService String MDMId;
        WebService List<String> ErrorCode;
        WebService String ErrorMessage;
        WebService List<String> ErrorDetails;
        WebService String SourceSystemIdentifier;
    }
    global class ResponseAccountFoundationItem {
        public ResponseAccountFoundationItem(){
            this.Account=new ResponseResult();
            this.Account_External_Ids=new List<ResponseResult>();
            this.Addresses=new List<ResponseResultAddress>();
            this.MergedAccounts=new List<ResponseResult>();
        }
        WebService ResponseResult Account;
        WebService List<ResponseResult> Account_External_Ids;
        WebService List<ResponseResult> MergedAccounts;
        WebService List<ResponseResultAddress> Addresses;
    }
    global class ResponseResult {       
        WebService String MDM_Id;
        WebService String Id;
        WebService OperationType Operation;
        WebService String Note;
    }
    global class ResponseResultAddress {
        public ResponseResultAddress(){
            this.Address=new ResponseResult();
            this.Address_External_Ids=new List<ResponseResult>();
        }
        WebService ResponseResult Address;
        WebService List<ResponseResult> Address_External_Ids;
    }    
    //  Utility Classes
    global enum ResponseStatus {success, failure}
    global enum OperationType {updated,deleted,created,none,merged,merge_winner}
    private class RequestAccountFoundationItem_mirror {
        public RequestAccountFoundationItem requestItem;
        public Account Account_obj;
        public List<Account_External_Id_gne__c> Account_External_Ids;
        public List<Address_stub_mirror> Addresses;
        public RequestAccountFoundationItem_mirror(){
            this.Account_External_Ids=new List<Account_External_Id_gne__c>();
            this.Addresses=new List<Address_stub_mirror>();
        }
    }
    private class Address_stub_mirror{
        public Address_vod__c Address;
        public List<Address_External_Id_gne__c> Address_External_Ids;
        public Address_stub_mirror(){
            this.Address_External_Ids=new List<Address_External_Id_gne__c>();
        }
    }
    private class MergerHelper{
        public MergerHelper(){
            this.multipleMDMIdFound=false;
            this.emptyIdsList=false;
            this.winningRecordAccountTerritories=new Map<Id,AccountShare>();
            this.mergeRecordsAccountTerritories=new Map<Id,AccountShare>();
        }
        public Account winner;
        public string winnerMDMId;
        public List<Id> ids;
        public List<Account> accountsForMerge;
        public boolean multipleMDMIdFound;
        public boolean emptyIdsList;
        public RequestAccountFoundationItem requestItem;
        public Map<Id,AccountShare> winningRecordAccountTerritories;
        public Map<Id,AccountShare> mergeRecordsAccountTerritories;
    }
    public class HelperException extends Exception {}     
    //  Utility Methods    
    private static ResponseAccountFoundationItem populateRequestAccountFoundationItemMirror(    RequestAccountFoundationItem_mirror item_mirror,
                                                                    RequestAccountFoundationItem item,
                                                                    List<Account> serializedAccounts,
                                                                    List<Account_External_Id_gne__c> serializedAccountsExtIds,
                                                                    boolean isPersonType,boolean isPlanProduct){
        boolean isNew=false;
        boolean isUpdated=false;
        if(item_mirror.Account_obj==null){
            item_mirror.Account_obj=new Account();
            isNew=true;
        }
        if(!(isPersonType && isNew)){
            system.debug('I have entered @1');
            //Fields Upsert for the Account Object
            if(isNew || item_mirror.Account_obj.Account_Type_gne__c!=item.Account.Account_Type_gne) {item_mirror.Account_obj.Account_Type_gne__c=item.Account.Account_Type_gne; isUpdated=true; } //1
            if(isPlanProduct && (isNew || item_mirror.Account_obj.Account_Type_gne__c!='Plan Product')) {item_mirror.Account_obj.Account_Type_gne__c='Plan Product'; isUpdated=true; } //1
            if(isNew || item_mirror.Account_obj.AMS_ID_gne__c!=item.Account.AMS_ID_gne) {item_mirror.Account_obj.AMS_ID_gne__c=item.Account.AMS_ID_gne; isUpdated=true; } //1
            if(isNew || item_mirror.Account_obj.Cell_Phone_gne__c!=item.Account.Cell_Phone_gne) {item_mirror.Account_obj.Cell_Phone_gne__c=item.Account.Cell_Phone_gne; isUpdated=true; } //1
            if(isNew || item_mirror.Account_obj.Credentials_gne__c!=item.Account.Credentials_gne) { item_mirror.Account_obj.Credentials_gne__c=item.Account.Credentials_gne; isUpdated=true; } //1
            if(isNew || item_mirror.Account_obj.Date_of_Birth_gne__c!=item.Account.Date_of_Birth_gne) { item_mirror.Account_obj.Date_of_Birth_gne__c=item.Account.Date_of_Birth_gne; isUpdated=true; } //1
            if(isNew || item_mirror.Account_obj.Fax!=item.Account.Fax) { item_mirror.Account_obj.Fax=item.Account.Fax; isUpdated=true; } //1
            //pftD5
            if(isNew || item_mirror.Account_obj.Account_Level_gne__c!=item.Account.Account_Level_gne) { item_mirror.Account_obj.Account_Level_gne__c=item.Account.Account_Level_gne; isUpdated=true; } //1
         
            if(isNew || item_mirror.Account_obj.Gender_vod__c!=item.Account.Gender_vod) { item_mirror.Account_obj.Gender_vod__c=item.Account.Gender_vod; isUpdated=true; } //1
            
            if(isNew || item_mirror.Account_obj.MDM_Update_Date_gne__c!=item.Account.MDM_Update_Date_gne) { item_mirror.Account_obj.MDM_Update_Date_gne__c=item.Account.MDM_Update_Date_gne; isUpdated=true; } //1
            
            if(!isPlanProduct){
                if(isNew || item_mirror.Account_obj.MDMID_gne__c!=item.Account.MDMID_gne) { item_mirror.Account_obj.MDMID_gne__c=item.Account.MDMID_gne; isUpdated=true; } //1
            } else {
                if(isNew || item_mirror.Account_obj.MDM_plan_product_id_gne__c!=item.Account.MDMID_gne) { item_mirror.Account_obj.MDM_plan_product_id_gne__c=item.Account.MDMID_gne; isUpdated=true; } //1
                //pftD5
                if(isNew || item_mirror.Account_obj.Lives_Medical_gne__c!=item.Account.Lives_Medical_gne) { item_mirror.Account_obj.Lives_Medical_gne__c=item.Account.Lives_Medical_gne; isUpdated=true; } //1
                if(isNew || item_mirror.Account_obj.Lives_Pharmacy_gne__c!=item.Account.Lives_Pharmacy_gne) { item_mirror.Account_obj.Lives_Pharmacy_gne__c=item.Account.Lives_Pharmacy_gne; isUpdated=true; } //1
            }
            if(isNew || item_mirror.Account_obj.MDMID_Status_gne__c!=item.Account.MDMID_Status_gne) { item_mirror.Account_obj.MDMID_Status_gne__c=item.Account.MDMID_Status_gne; isUpdated=true; } //1
            if(isNew || item_mirror.Account_obj.middle_vod__c!=item.Account.Middle_gne) { item_mirror.Account_obj.middle_vod__c=item.Account.Middle_gne; isUpdated=true; } //1
            
            if(!isPersonType) { 
                if(isNew || item_mirror.Account_obj.Name!=item.Account.Name) { item_mirror.Account_obj.Name=item.Account.Name; isUpdated=true; } //1
            } else {
                if(isNew || item_mirror.Account_obj.Firstname!=item.Account.Firstname) { item_mirror.Account_obj.Firstname=item.Account.Firstname; isUpdated=true; } //1
                if(isNew || item_mirror.Account_obj.Lastname!=item.Account.Lastname) { item_mirror.Account_obj.Lastname=item.Account.Lastname; isUpdated=true; } //1
                if(isNew || item_mirror.Account_obj.Salutation!=item.Account.Salutation) { item_mirror.Account_obj.Salutation=item.Account.Salutation; isUpdated=true; } //1
                if(item.Account.Suffix_gne!=null && (isNew || item_mirror.Account_obj.Suffix_gne__c==null)) { item_mirror.Account_obj.Suffix_gne__c=item.Account.Suffix_gne; isUpdated=true; }
            }
            if(item_mirror.Account_obj.Phone!=item.Account.Phone) { item_mirror.Account_obj.Phone=item.Account.Phone; isUpdated=true; } //1
            // commented preferred name assignment - this field is type 3 
            //if(item_mirror.Account_obj.Preferred_Name_vod__c!=item.Account.Preferred_Name_vod) { item_mirror.Account_obj.Preferred_Name_vod__c=item.Account.Preferred_Name_vod; isUpdated=true; } //1

            // 6/17/2009 start - change proposed by Willi H & CADS TEam
            if(item.Account.Professional_Type_gne != null) {
                List<String> roleListByRank = GENE_SFDC_FOUN_INT_UTIL.getCADSRoleListByRank();
                Map<String,String> roleToProfessionalType = GENE_SFDC_FOUN_INT_UTIL.getRoleToProfessionalTypeMapping();
                String highestRole = 'default';                             
                String tempRoles = item.Account.Professional_Type_gne + ',';
                for (String role : roleListByRank ) {                   
                    if ( tempRoles.contains(role + ',') ){                   
                        highestRole = role;break; // break on first highest role match
                }} 
                String profType = roleToProfessionalType.get(highestRole);
                if (profType != null && item_mirror.Account_obj.Professional_Type_gne__c != profType) { 
                   item_mirror.Account_obj.Professional_Type_gne__c=profType; isUpdated=true;
                }}  
            // 6/17/2009 end            
            if(item_mirror.Account_obj.RecordTypeId!=item.Account.RecordTypeId) { item_mirror.Account_obj.RecordTypeId=item.Account.RecordTypeId;isUpdated=true; } //1
            if(item_mirror.Account_obj.Specialties_gne__c!=item.Account.Specialties_gne) { item_mirror.Account_obj.Specialties_gne__c=item.Account.Specialties_gne; isUpdated=true; } //1
            if(item.Account.Website!=null && (isNew || item_mirror.Account_obj.Website==null)) { item_mirror.Account_obj.Website=item.Account.Website; isUpdated=true; } //3
            if(item_mirror.Account_obj.Plan_Type_gne__c != item.Account.Plan_Type_gne)  { item_mirror.Account_obj.Plan_Type_gne__c=item.Account.Plan_Type_gne; isUpdated=true; }
            if(item_mirror.Account_obj.Plan_Product_Type_gne__c != item.Account.Plan_Product_Type_gne )  { item_mirror.Account_obj.Plan_Product_Type_gne__c=item.Account.Plan_Product_Type_gne; isUpdated=true; }
            if(isNew || item_mirror.Account_obj.Payer_gne__c!=item.Account.Payer_gne) { item_mirror.Account_obj.Payer_gne__c=item.Account.Payer_gne; isUpdated=true; } //1
            if(isNew || item_mirror.Account_obj.Plan_gne__c!=item.Account.Plan_gne) { item_mirror.Account_obj.Plan_gne__c=item.Account.Plan_gne; isUpdated=true; } //1
            if(isNew || item_mirror.Account_obj.Carrier_gne__c!=item.Account.Carrier_gne) { item_mirror.Account_obj.Carrier_gne__c=item.Account.Carrier_gne; isUpdated=true; } //1
        }
        if(isUpdated || (isNew && !isPersonType)) serializedAccounts.add(item_mirror.Account_obj);
        if(!isNew) {
            ResponseAccountFoundationItem status=new ResponseAccountFoundationItem();
            status.Account.MDM_Id=item_mirror.Account_obj.MDMID_gne__c;
            status.Account.Id=item_mirror.Account_obj.Id;
            if(isUpdated) status.Account.Operation=OperationType.updated;
            else status.Account.Operation=OperationType.none;
            return status;
        }
        if(isNew && item.Account_External_Ids!=null){
            for(Account_External_Id_gne_stub accountExternalIdStub:item.Account_External_Ids){
                Account_External_Id_gne__c accountExternalId=new Account_External_Id_gne__c();
                    accountExternalId.Third_Party_gne__c=accountExternalIdStub.Third_Party_gne;
                    accountExternalId.Third_Party_Id_gne__c=accountExternalIdStub.Third_Party_Id_gne;
                    accountExternalId.Third_Party_Index_gne__c=accountExternalIdStub.Third_Party_Index_gne;
                item_mirror.Account_External_Ids.add(accountExternalId);
                serializedAccountsExtIds.add(accountExternalId);
            }
        }
        return null;
    }
    
    private static ResponseResultAddress populateAddressStubMirror( Address_stub_mirror addressStubMirror,
                                                    Address_stub addressStub,
                                                    List<Address_vod__c> serializedAddresses,
                                                    List<Address_External_Id_gne__c> serializedAddressesExtIds){
        boolean isNew=false;
        boolean isUpdated=false;
        if(addressStubMirror.Address==null){
            addressStubMirror.Address=new Address_vod__c();
            isNew=true;
        }
        //We should skip this process if the record is new and we are disabling it
        if(addressStub.Active_Flag_gne!=false || !isNew){           
            if (AddressStub.GOLD_RECORD_gne !=null && AddressStub.GOLD_RECORD_gne == true) {
                if(addressStub.Address_line_2_vod != null) {addressStubMirror.Address.Address_line_2_vod__c=addressStub.Address_line_2_vod; isUpdated=true; } //1
                if(addressStub.Address_line_3_gne != null) {addressStubMirror.Address.Address_Line_3_gne__c=addressStub.Address_Line_3_gne; isUpdated=true; } //1
                if(addressStub.Address_line_4_gne != null) {addressStubMirror.Address.Address_Line_4_gne__c=addressStub.Address_Line_4_gne; isUpdated=true; } //1
            } else {    
                if(addressStub.Address_line_2_vod != null && addressStubMirror.Address.Address_line_2_vod__c == null)  {addressStubMirror.Address.Address_line_2_vod__c=addressStub.Address_line_2_vod; isUpdated=true; } //3
                if(addressStub.Address_line_3_gne != null && addressStubMirror.Address.Address_Line_3_gne__c == null)  {addressStubMirror.Address.Address_Line_3_gne__c=addressStub.Address_Line_3_gne; isUpdated=true; } //3
                if(addressStub.Address_line_4_gne != null && addressStubMirror.Address.Address_Line_4_gne__c == null)  {addressStubMirror.Address.Address_Line_4_gne__c=addressStub.Address_Line_4_gne; isUpdated=true; } //3
            }                        
            if(isNew || addressStubMirror.Address.City_vod__c!=addressStub.City_vod) {addressStubMirror.Address.City_vod__c=addressStub.City_vod; isUpdated=true; } //1
            if(isNew || addressStubMirror.Address.Country_gen__c!=addressStub.Country_gne) {addressStubMirror.Address.Country_gen__c=addressStub.Country_gne; isUpdated=true; } //1
            if(isNew || addressStubMirror.Address.MDM_Address_ID_gne__c!=addressStub.MDM_Address_ID_gne) {addressStubMirror.Address.MDM_Address_ID_gne__c=addressStub.MDM_Address_ID_gne; isUpdated=true; } //1

            if(isNew || addressStubMirror.Address.Name!=addressStub.Name) {addressStubMirror.Address.Name=addressStub.Name; isUpdated=true; } //1

            if(isNew || addressStubMirror.Address.State_vod__c!=addressStub.State_vod) {addressStubMirror.Address.State_vod__c=addressStub.State_vod; isUpdated=true; } //1
            if(isNew || addressStubMirror.Address.Zip_4_vod__c!=addressStub.Zip_4_vod) {addressStubMirror.Address.Zip_4_vod__c=addressStub.Zip_4_vod; isUpdated=true; } //1
            if(isNew || addressStubMirror.Address.Zip_vod__c!=addressStub.Zip_vod) {addressStubMirror.Address.Zip_vod__c=addressStub.Zip_vod; isUpdated=true; } //1
            if(isNew || addressStubMirror.Address.Active_Flag_gne__c!=addressStub.Active_Flag_gne) {addressStubMirror.Address.Active_Flag_gne__c=addressStub.Active_Flag_gne; isUpdated=true; } //1
            if(addressStub.Fax_vod!=null && (isNew || addressStubMirror.Address.Fax_vod__c==null)) { addressStubMirror.Address.Fax_vod__c=addressStub.Fax_vod; isUpdated=true; } //3
            if(addressStub.Hospital_gne!=null && (isNew || addressStubMirror.Address.Hospital_gne__c==null)) { addressStubMirror.Address.Hospital_gne__c=addressStub.Hospital_gne; isUpdated=true; } //3
            if(addressStub.License_vod!=null && (isNew || addressStubMirror.Address.License_vod__c==null)) { addressStubMirror.Address.License_vod__c=addressStub.License_vod;  isUpdated=true; } //?
            if(addressStub.License_Expiration_Date_vod!=null && (isNew || addressStubMirror.Address.License_Expiration_Date_vod__c==null)) { addressStubMirror.Address.License_Expiration_Date_vod__c=addressStub.License_Expiration_Date_vod;  isUpdated=true; } //?
            if(addressStub.License_Status_vod!=null && (isNew || addressStubMirror.Address.License_Status_vod__c==null)) { addressStubMirror.Address.License_Status_vod__c=addressStub.License_Status_vod;  isUpdated=true; } //?
            if(addressStub.Mailing_vod!=null && (isNew || addressStubMirror.Address.Mailing_vod__c==null)) { addressStubMirror.Address.Mailing_vod__c=addressStub.Mailing_vod; isUpdated=true; } //3
            if(addressStub.Office_gne!=null && (isNew || addressStubMirror.Address.Office_gne__c==null)) { addressStubMirror.Address.Office_gne__c=addressStub.Office_gne; isUpdated=true; } //3
            if(addressStub.Phone_1_Ext_gne!=null && (isNew || addressStubMirror.Address.Phone_1_Ext_gne__c==null)) { addressStubMirror.Address.Phone_1_Ext_gne__c=addressStub.Phone_1_Ext_gne; isUpdated=true; } //3
            if(addressStub.Phone_vod!=null && (isNew || addressStubMirror.Address.Phone_vod__c==null)) { addressStubMirror.Address.Phone_vod__c=addressStub.Phone_vod; isUpdated=true; } //3
            if(addressStub.Phone_2_vod!=null && (isNew || addressStubMirror.Address.Phone_2_vod__c==null)) { addressStubMirror.Address.Phone_2_vod__c=addressStub.Phone_2_vod; isUpdated=true; } //3
            if(addressStub.Shipping_vod!=null && (isNew || addressStubMirror.Address.Shipping_vod__c==null)) { addressStubMirror.Address.Shipping_vod__c=addressStub.Shipping_vod; isUpdated=true; } //3
            if(addressStub.Billing_vod!=null && (isNew || addressStubMirror.Address.Billing_vod__c==null)) { addressStubMirror.Address.Billing_vod__c=addressStub.Billing_vod; isUpdated=true; } //3
            if(addressStub.Business_vod!=null && (isNew || addressStubMirror.Address.Business_vod__c==null)) { addressStubMirror.Address.Business_vod__c=addressStub.Business_vod; isUpdated=true; } //3
            if(addressStub.Phone_2_Ext_gne!=null && (isNew || addressStubMirror.Address.Phone_2_Ext_gne__c==null)) { addressStubMirror.Address.Phone_2_Ext_gne__c=addressStub.Phone_2_Ext_gne; isUpdated=true; } //3
            if(addressStub.GOLD_RECORD_gne!=null && (isNew || addressStubMirror.Address.GOLD_RECORD_gne__c==null)) { addressStubMirror.Address.GOLD_RECORD_gne__c=addressStub.GOLD_RECORD_gne; isUpdated=true; } //3
        
            // Nov 2009 copy address line to address.Name when physical address is missing
	        if ( (addressStub.Name == null || 
	              addressStub.Name.length() == 0) && 
	              addressStub.Address_line_2_vod != null ) {	              
	            addressStubMirror.Address.Name=addressStub.Address_line_2_vod;
	            addressStubMirror.Address.Address_line_2_vod__c = null;
	            isUpdated=true; 
	        }
        } else isNew=false;
        
        if(isUpdated || isNew) serializedAddresses.add(addressStubMirror.Address);
        else {
            ResponseResultAddress status=new ResponseResultAddress();
            status.Address.MDM_Id=addressStubMirror.Address.MDM_Address_ID_gne__c;
            status.Address.Id=addressStubMirror.Address.Id;
            status.Address.Operation=OperationType.none;
            return status;
        }
        
        //Adding Address_External_Id_gne__c
        if(isNew && addressStub.Address_External_Ids!=null){
            for(Address_External_Id_gne_stub AddressExternalIdGneStub:addressStub.Address_External_Ids){
                Address_External_Id_gne__c AddressExternalIdGne=new Address_External_Id_gne__c();
                addressStubMirror.Address_External_Ids.add(AddressExternalIdGne);
                //Fields Insert for the Address_External_Id_gne__c Object
                AddressExternalIdGne.Third_Party_gne__c=AddressExternalIdGneStub.Third_Party_gne;
                AddressExternalIdGne.Third_Party_Id_gne__c=AddressExternalIdGneStub.Third_Party_Id_gne;
                AddressExternalIdGne.Third_Party_Index_gne__c=AddressExternalIdGneStub.Third_Party_Index_Id_gne;
                serializedAddressesExtIds.add(AddressExternalIdGne);
            }
        }
        return null;
    }

    private static ResponseAccountFoundation handleGenericError(ResponseAccountFoundation response,Exception e,Savepoint sp,string customCode,string customError){
        if(sp!=null) Database.rollback(sp);
        response.EndTime=DateTime.now();
        response.ResponseItems=null;
        if(customError!=null && customCode!=null){
            response.ErrorCode=customCode;
            response.ErrorMessage=customError;
            response.ErrorDetails= e.getTypeName() + ' - ' + e.getMessage();
        } else {
            response.ErrorCode=e.getTypeName();
            response.ErrorMessage=e.getMessage();
        }
        response.BatchStatus=ResponseStatus.failure;
        return response;    
    }
    private static ResponseAccountFoundation handleUpsertError(ResponseAccountFoundation response,Savepoint sp){
        if(sp!=null) Database.rollback(sp);
        response.EndTime=DateTime.now();
        response.BatchStatus=ResponseStatus.failure;
        response.ResponseItems=null;
        response.ErrorCode='';
        response.ErrorMessage='';
        response.ErrorDetails='';
        return response;
    }
    
    //  Interface 
    WebService static ResponseAccountFoundation  AccountFoundation(RequestAccountFoundation Request){

        //  Init Response
        ResponseAccountFoundation response=new ResponseAccountFoundation();
        response.Transaction_Id=Request.Transaction_Id;
        response.SourceSystem=Request.SourceSystem;
        
        //Split RequestAccountFoundation between Merge and Upsert
        RequestAccountFoundation RequestUpsert=new RequestAccountFoundation();
        RequestAccountFoundation RequestMerge=new RequestAccountFoundation();
        RequestUpsert.RequestItems=new List<RequestAccountFoundationItem>();
        RequestMerge.RequestItems=new List<RequestAccountFoundationItem>();
        if(Request.PartyType!='PLANPRODUCT'){
            Savepoint sp = Database.setSavepoint();
            for(RequestAccountFoundationItem item:Request.RequestItems){
                if(item.Ids!=null && item.Ids.size()!=0) RequestMerge.RequestItems.add(item);
                RequestUpsert.RequestItems.add(item);
            }
            //Calling Merge
            if(RequestMerge.RequestItems.size()>0) AccountFoundationMerge(RequestMerge,response,sp);
            //Calling Upsert
            if(response.ResponseErrorItems.size()==0 && response.BatchStatus==null && RequestUpsert.RequestItems.size()>0) AccountFoundationUpsert(RequestUpsert,response,sp);
        } else {
            Savepoint sp=AccountFoundationPlanProductMerge(Request,response);
            if(response.ResponseErrorItems.size()==0 && response.BatchStatus==null) AccountFoundationPlanProductUpsert(Request,response,sp);
        }
        if(response.ResponseErrorItems.size()==0 && response.BatchStatus==null){
            response.EndTime=DateTime.now();
            response.BatchStatus=ResponseStatus.success;
            response.ErrorCode='';
            response.ErrorMessage='';
            response.ErrorDetails='';
        }
        return response;
    }

    private static ResponseAccountFoundation  AccountFoundationUpsert(RequestAccountFoundation Request,ResponseAccountFoundation response,Savepoint sp){
        //      Strategy: copy the request data into an internal tree that uses actual objects
        //      At the same time serialize the objects to be upserted into Lists for bulk operations
        //  Init list that will hold serialized objects
        List<Account> serializedAccounts=new List<Account>();
        List<Account_External_Id_gne__c> serializedAccountsExtIds=new List<Account_External_Id_gne__c>();
        List<Address_vod__c> serializedAddresses=new List<Address_vod__c>();
        List<Address_External_Id_gne__c> serializedAddressesExtIds=new List<Address_External_Id_gne__c>();
        
        //  Init the Map that will hold the internal tree view for the request
        //  Will map Accounts with MDMIds 
        Map<string,RequestAccountFoundationItem_mirror> internalTreeMap=new Map<string,RequestAccountFoundationItem_mirror>();
        Map<string,Address_stub_mirror> internalAddressSubTreeMap=new Map<string,Address_stub_mirror>();
        
        //Init the list of the Person Accounts Recordtypes;
        Set<Id> personAccountsRecordtypes=new Map<ID, RecordType>([Select Id,Name from RecordType where IsPersonType=true]).keySet();
        try{
            //          Get all the MDM Ids in this call into one object
            Set<string> MDMIdsOnThisCall=new Set<string>();
            Set<string> SFDCIdsOnThisCall=new Set<string>();

            for(RequestAccountFoundationItem item:Request.RequestItems){
                MDMIdsOnThisCall.add(item.Account.MDMID_gne);
                if(item.Account.Id!=null) 
                    SFDCIdsOnThisCall.add(item.Account.Id);
            }

            //          Get the list of the objects to be updated
            Map<Id,Account> accountsToUpdateMapNames=new Map<Id,Account>([Select Id,Name from Account where MDMID_gne__c in:MDMIdsOnThisCall or Id in:SFDCIdsOnThisCall]);
            List<Account> accountsToUpdateList=[ Select a.Account_Type_gne__c, a.AMS_ID_gne__c, a.Carrier_gne__c, 
                                                a.Cell_Phone_gne__c, a.Credentials_gne__c, a.Date_of_Birth_gne__c, 
                                                a.Fax, a.FirstName, a.Gender_vod__c, a.Id, a.LastName, 
                                                a.MDM_Update_Date_gne__c, a.MDMID_gne__c, a.MDMID_Status_gne__c, 
                                                a.middle_vod__c, a.Payer_gne__c, a.Phone, a.Plan_gne__c, 
                                                a.Plan_Product_Type_gne__c, a.Plan_Type_gne__c,   
                                                a.Professional_Type_gne__c, a.RecordTypeId, a.Salutation, 
                                                a.Specialties_gne__c, a.Suffix_gne__c, a.Website,
                                                //added pftd5
                                                a.Account_Level_gne__c,
                                                //-----------
                                                (Select Address_line_2_vod__c, Address_Line_3_gne__c, Address_Line_4_gne__c, 
                                                Billing_vod__c, Business_vod__c, City_vod__c, Country_gen__c, Fax_vod__c, 
                                                Hospital_gne__c, Id, License_Expiration_Date_vod__c, License_Status_vod__c, 
                                                License_vod__c, Mailing_vod__c, MDM_Address_ID_gne__c, Name, Office_gne__c, 
                                                Phone_1_Ext_gne__c, Phone_2_vod__c, Phone_vod__c, Shipping_vod__c, State_vod__c, 
                                                Zip_4_vod__c, Zip_vod__c,GOLD_RECORD_gne__c,Phone_2_Ext_gne__c,Active_Flag_gne__c From Address_vod__r) 
                                                from Account a where
                                                (a.MDMID_gne__c in:MDMIdsOnThisCall or 
                                                a.Id in:SFDCIdsOnThisCall) for update]; //Calling lock on selected accounts

            Map<Id,Account> accountsToUpdateMap= new Map<Id,Account>();
            Map <String, Id> MDMIdsAlreadyInSFDC = new Map<String, Id>();
            
            for(Account acct:accountsToUpdateList){
                accountsToUpdateMap.put(acct.Id,acct);
                if(!personAccountsRecordtypes.contains(acct.RecordTypeId)) acct.Name=accountsToUpdateMapNames.get(acct.Id).Name;
                if ( acct.MDMID_gne__c != null )
                    MDMIdsAlreadyInSFDC.put (acct.MDMID_gne__c, acct.Id);
            }
            
            for(RequestAccountFoundationItem item:Request.RequestItems){
                //  Recreate the request tree:add a RequestAccountFoundationItem_mirror to the tree Map
                RequestAccountFoundationItem_mirror item_mirror=new RequestAccountFoundationItem_mirror();
                internalTreeMap.put(item.Account.MDMID_gne,item_mirror);
                item_mirror.requestItem=item;
                
                if( ( item.Account.Id!=null && accountsToUpdateMap.containsKey(item.Account.Id) )  || 
                    MDMIdsAlreadyInSFDC.containsKey(item.Account.MDMID_gne) ){

                    //This Account's MDM id is already contained in SFDC
                    if ( item.Account.Id != null && accountsToUpdateMap.containsKey(item.Account.Id))   
                        item_mirror.Account_obj=accountsToUpdateMap.get(item.Account.Id);
                    else 
                        item_mirror.Account_obj=accountsToUpdateMap.get(MDMIdsAlreadyInSFDC.get(item.Account.MDMID_gne));
                    
                    internalTreeMap.put(item_mirror.Account_obj.Id,item_mirror);
                    
                    // Updating Accounts
                    ResponseAccountFoundationItem responseAccountItem=populateRequestAccountFoundationItemMirror(item_mirror,item,serializedAccounts,serializedAccountsExtIds,personAccountsRecordtypes.contains(item.Account.RecordTypeId),false);                 
                    if(responseAccountItem!=null) response.ResponseItems.add(responseAccountItem);
                    if(item.Addresses!=null){
                        //What addresses are already in SFDC?
                        Map<string,Address_vod__c> AddressesMDMIdsOnSFDC=new Map<string,Address_vod__c>();
                        for(Address_vod__c address:item_mirror.Account_obj.Address_vod__r){
                            AddressesMDMIdsOnSFDC.put(address.MDM_Address_ID_gne__c,address);
                        }
                        for(Address_stub addressStub:item.Addresses){
                            Address_stub_mirror addressStubMirror;
                            if(AddressesMDMIdsOnSFDC.containsKey(addressStub.MDM_Address_ID_gne)){
                                //Addresses to be updated
                                addressStubMirror=new Address_stub_mirror();
                                addressStubMirror.Address=AddressesMDMIdsOnSFDC.get(addressStub.MDM_Address_ID_gne);
                                //Fields Update for the Addresses Object
                                ResponseResultAddress responseAddressItem=populateAddressStubMirror(addressStubMirror,addressStub,serializedAddresses,serializedAddressesExtIds);
                                if(responseAddressItem!=null) responseAccountItem.Addresses.add(responseAddressItem);
                            } else {
                                // no address add on update - guruk 2/19/09 business input from Quincc/Raj.
                                continue;
                                
                                /*
                                //Addresses to be inserted
                                addressStubMirror=new Address_stub_mirror();                            
                                populateAddressStubMirror(addressStubMirror,addressStub,serializedAddresses,serializedAddressesExtIds);
                                addressStubMirror.Address.Account_vod__c=item_mirror.Account_obj.Id;
                                */
                                
                            }
                            item_mirror.Addresses.add(addressStubMirror);
                            internalAddressSubTreeMap.put(addressStub.MDM_Address_ID_gne,addressStubMirror);
                        }
                    }
                } else {
                    //This Account's MDM ID was not contained in SFDC
                    populateRequestAccountFoundationItemMirror(item_mirror,item,serializedAccounts,serializedAccountsExtIds,personAccountsRecordtypes.contains(item.Account.RecordTypeId),false);   
                    if(item.Addresses!=null){
                        for(Address_stub addressStub:item.Addresses){
                            //Addresses to be inserted
                            Address_stub_mirror addressStubMirror=new Address_stub_mirror();
                            populateAddressStubMirror(addressStubMirror,addressStub,serializedAddresses,serializedAddressesExtIds);
                            item_mirror.Addresses.add(addressStubMirror);
                            internalAddressSubTreeMap.put(addressStub.MDM_Address_ID_gne,addressStubMirror);
                        }
                    }
                }
            }
        } catch( Exception e){
            return handleGenericError(response,e,null,null,null);
        }        
        //      Upserting Records
        Database.UpsertResult[] lsr;
        integer exceptionsCount;
        integer itemsCount;
        Map<string,ResponseAccountErrorStatus> ResponseItemMapByAccountId=new Map<string,ResponseAccountErrorStatus>();
        
        //  Upserting Accounts
        try{
            lsr = Utilities_BulkDMLOperationsUtils.batchDMLupsert(serializedAccounts,false);
        }catch(Exception e){
            return handleGenericError(response,e,sp,null,null);
        }
        //  Error Verification
        exceptionsCount=0;
        itemsCount=0;
        for(Database.UpsertResult sr : lsr){
            RequestAccountFoundationItem_mirror currentInternalTreeMapNode=internalTreeMap.get(serializedAccounts[itemsCount].MDMID_gne__c);
            if(!sr.isSuccess()){
                exceptionsCount++;
                //Create a responseItem
                ResponseAccountErrorStatus responseItem=new ResponseAccountErrorStatus();
                response.ResponseErrorItems.add(responseItem);
                responseItem.MDMId=serializedAccounts[itemsCount].MDMID_gne__c;
                responseItem.ErrorMessage='Error while usperting Account MDM_Id=' + serializedAccounts[itemsCount].MDMID_gne__c;
                for(Database.Error err:sr.getErrors()){
                    responseItem.ErrorCode.add(err.getStatusCode().name());
                    responseItem.ErrorDetails.add(err.getMessage());
                }
                responseItem.SourceSystemIdentifier=currentInternalTreeMapNode.requestItem.SourceSystemIdentifier;
            } else if(exceptionsCount==0) {
                //If no error yet occurred
                //Use the current internalTreeMap to store addresses by Address SFDC Id
                internalTreeMap.put(sr.getId(),currentInternalTreeMapNode);
                //Add Address Id to Address External Id
                for(Address_stub_mirror addressStub:currentInternalTreeMapNode.Addresses){
                    if(sr.isCreated()) addressStub.Address.Account_vod__c=sr.getId();
                }
                for(Account_External_Id_gne__c AccountExternalId:currentInternalTreeMapNode.Account_External_Ids){
                    if(sr.isCreated()) AccountExternalId.Account_gne__c=sr.getId();
                }
                if(sr.isCreated()){
                    ResponseAccountFoundationItem status=new ResponseAccountFoundationItem();
                    status.Account.MDM_Id=serializedAccounts[itemsCount].MDMID_gne__c;
                    status.Account.Id=sr.getId();
                    status.Account.Operation=OperationType.created;
                    response.ResponseItems.add(status);
                }
            }
            itemsCount++;
        }
        if(exceptionsCount>0) return handleUpsertError(response,sp);
        
        //Building a map of the current response
        Map<Id,ResponseAccountFoundationItem> ResponseItemsMap=new Map<Id,ResponseAccountFoundationItem>();
        for(ResponseAccountFoundationItem responseItem:response.ResponseItems) ResponseItemsMap.put(responseItem.Account.Id,responseItem);
        Map<Id,ResponseResultAddress> ResponseAddressItemsMap=new Map<Id,ResponseResultAddress>();
        
        //  Upserting Account External Ids
        try{
            lsr = Utilities_BulkDMLOperationsUtils.batchDMLupsert(serializedAccountsExtIds,false);
        }catch(Exception e){
            return handleGenericError(response,e,sp,null,null);
        }
        
        //  Error Verification
        exceptionsCount=0;
        itemsCount=0;
        for(Database.UpsertResult sr : lsr){
            RequestAccountFoundationItem_mirror currentInternalTreeMapNode=internalTreeMap.get(serializedAccountsExtIds[itemsCount].Account_gne__c);
            if(!sr.isSuccess()){
                exceptionsCount++;
                //Create a responseItem or get one already created
                ResponseAccountErrorStatus responseItem;
                if(ResponseItemMapByAccountId.containsKey(serializedAccountsExtIds[itemsCount].Account_gne__c)) responseItem=ResponseItemMapByAccountId.get(serializedAccountsExtIds[itemsCount].Account_gne__c);
                else {
                    responseItem=new ResponseAccountErrorStatus();
                    ResponseItemMapByAccountId.put(serializedAccountsExtIds[itemsCount].Account_gne__c,responseItem);
                    response.ResponseErrorItems.add(responseItem);
                }
                responseItem.MDMId=currentInternalTreeMapNode.Account_obj.MDMID_gne__c;
                responseItem.ErrorMessage='Error while usperting Account External Ids';
                for(Database.Error err:sr.getErrors()){
                    responseItem.ErrorCode.add(err.getStatusCode().name());
                    responseItem.ErrorDetails.add('Account SFDC_id=' + serializedAccountsExtIds[itemsCount].Account_gne__c + ' ' +err.getMessage());
                }
                responseItem.SourceSystemIdentifier=currentInternalTreeMapNode.requestItem.SourceSystemIdentifier;
            } else {
                ResponseAccountFoundationItem responseItem= ResponseItemsMap.get(serializedAccountsExtIds[itemsCount].Account_gne__c);
                ResponseResult accountExternalStatus=new ResponseResult();
                accountExternalStatus.Id=sr.getId();
                accountExternalStatus.Operation=OperationType.created;
                responseItem.Account_External_Ids.add(accountExternalStatus);
            }
            itemsCount++;
        }
        if(exceptionsCount>0) return handleUpsertError(response,sp);
        
        //  Upserting Addresses
        try{
            lsr = Utilities_BulkDMLOperationsUtils.batchDMLupsert(serializedAddresses,false);
        }catch(Exception e){
            return handleGenericError(response,e,sp,null,null);
        }
        
        //  Error Verification
        exceptionsCount=0;
        itemsCount=0;
        for(Database.UpsertResult sr : lsr){
            RequestAccountFoundationItem_mirror currentInternalTreeMapNode=internalTreeMap.get(serializedAddresses[itemsCount].Account_vod__c);
            if(!sr.isSuccess()){
                exceptionsCount++;
                //Create a responseItem or get one already created
                ResponseAccountErrorStatus responseItem;
                if(ResponseItemMapByAccountId.containsKey(serializedAddresses[itemsCount].Account_vod__c)) responseItem=ResponseItemMapByAccountId.get(serializedAddresses[itemsCount].Account_vod__c);
                else {
                    responseItem=new ResponseAccountErrorStatus();
                    ResponseItemMapByAccountId.put(serializedAddresses[itemsCount].Account_vod__c,responseItem);
                    response.ResponseErrorItems.add(responseItem);
                }
                responseItem.MDMId=currentInternalTreeMapNode.Account_obj.MDMID_gne__c;
                Database.Error err = sr.getErrors()[0];
                responseItem.ErrorMessage='Error while usperting Addresss';
                responseItem.ErrorCode.add(err.getStatusCode().name());
                responseItem.ErrorDetails.add('Address MDM_id=' + serializedAddresses[itemsCount].MDM_Address_ID_gne__c + ' ' +err.getMessage());
                responseItem.SourceSystemIdentifier=currentInternalTreeMapNode.requestItem.SourceSystemIdentifier;
            } else if(exceptionsCount==0) {
                //If no error yet occurred
                //We get the Address_stub_mirror from the internal mapping
                Address_stub_mirror addressStubMirror=internalAddressSubTreeMap.get(serializedAddresses[itemsCount].MDM_Address_ID_gne__c);
                internalAddressSubTreeMap.put(sr.getId(),addressStubMirror);
                //Add Address Id to Addresses External Id
                for(Address_External_Id_gne__c AddressExternalId:addressStubMirror.Address_External_Ids){
                    AddressExternalId.Address_gne__c=sr.getId();
                }
                ResponseAccountFoundationItem responseItem = ResponseItemsMap.get(serializedAddresses[itemsCount].Account_vod__c);
                ResponseResultAddress responseItemAddress=new ResponseResultAddress();
                responseItem.Addresses.add(responseItemAddress);
                responseItemAddress.Address.MDM_Id=serializedAddresses[itemsCount].MDM_Address_ID_gne__c;
                responseItemAddress.Address.Id=sr.getId();
                if(sr.isCreated()) responseItemAddress.Address.Operation=OperationType.created;
                else responseItemAddress.Address.Operation=OperationType.updated;
                ResponseAddressItemsMap.put(responseItemAddress.Address.Id,responseItemAddress);
            }           
            itemsCount++;
        }
        if(exceptionsCount>0) return handleUpsertError(response,sp);
        
        //  Upserting Address_External_Id_gne
        try{
            lsr = Utilities_BulkDMLOperationsUtils.batchDMLupsert(serializedAddressesExtIds,false);
        }catch(Exception e){
            return handleGenericError(response,e,sp,null,null);
        }
        //  Error Verification
        exceptionsCount=0;
        itemsCount=0;
        for(Database.UpsertResult sr : lsr){
            //We get the Address_stub_mirror from the internal mapping
            Address_stub_mirror addressStubMirror=internalAddressSubTreeMap.get(serializedAddressesExtIds[itemsCount].Address_gne__c);
            //We access the original Request using the Account Id contained in the Address_stub_mirror
            RequestAccountFoundationItem_mirror currentInternalTreeMapNode=internalTreeMap.get(addressStubMirror.Address.Account_vod__c);
            
            if(!sr.isSuccess()){
                exceptionsCount++;
                //Create a responseItem or get one already created
                ResponseAccountErrorStatus responseItem;
                if(ResponseItemMapByAccountId.containsKey(addressStubMirror.Address.Account_vod__c)) responseItem=ResponseItemMapByAccountId.get(addressStubMirror.Address.Account_vod__c);
                else {
                    responseItem=new ResponseAccountErrorStatus();
                    ResponseItemMapByAccountId.put(addressStubMirror.Address.Account_vod__c,responseItem);
                    response.ResponseErrorItems.add(responseItem);
                }
                responseItem.MDMId=currentInternalTreeMapNode.Account_obj.MDMID_gne__c;
                responseItem.ErrorMessage='Error while usperting Address_External_Id_gne';
                for(Database.Error err:sr.getErrors()){
                    responseItem.ErrorCode.add(err.getStatusCode().name());
                    responseItem.ErrorDetails.add('Address SFDC_id=' + serializedAddressesExtIds[itemsCount].Address_gne__c + ' ' +err.getMessage());
                }
                responseItem.SourceSystemIdentifier=currentInternalTreeMapNode.requestItem.SourceSystemIdentifier;
            }  else {
                ResponseResultAddress responseItemAddress=ResponseAddressItemsMap.get(serializedAddressesExtIds[itemsCount].Address_gne__c);
                ResponseResult addressesExtIdStatus=new ResponseResult();
                addressesExtIdStatus.Id=sr.getId();
                addressesExtIdStatus.Operation=OperationType.created;
                responseItemAddress.Address_External_Ids.add(addressesExtIdStatus);
            }
            itemsCount++;
        }
        if(exceptionsCount>0) return handleUpsertError(response,sp);
        return response;
    }

    private static ResponseAccountFoundation  AccountFoundationMerge(RequestAccountFoundation Request,ResponseAccountFoundation response,Savepoint sp){
        
        //          Get all the MDM Ids in this call into one object
        Set<string> potentialWinnerMDMIds=new Set<string>();
        Map<String,MergerHelper> potentialWinnersMergerHelpers=new  Map<String,MergerHelper>();
        //          Get all the Merge Ids in this call into one object
        Set<Id> mergeIdsOnThisCall=new Set<Id>();
        Set<Id> allIdsOnThisCall=new Set<Id>();

        try{
                        
            //          Prepare local storage for all the values to be merged
            for(RequestAccountFoundationItem item:Request.RequestItems){
                potentialWinnerMDMIds.add(item.Account.MDMID_gne);
                MergerHelper mh=new MergerHelper();
                mh.winnerMDMId=item.Account.MDMID_gne;
                mh.requestItem=item;
                potentialWinnersMergerHelpers.put(item.Account.MDMID_gne,mh);
                if(item.Ids!=null && item.Ids.size()!=0){
                    mh.ids=item.Ids;
                    for(string itemIdStr:item.Ids){
                        Id itemId=itemIdStr;
                        mergeIdsOnThisCall.add(itemId);
                    }
                } else {
                    mh.emptyIdsList=true;
                }
            }
        } catch( Exception e){
            e.setMessage(e.getMessage() + ' Prepare local storage for all the values to be merged');
            return handleGenericError(response,e,null,null,null);
        }
        
        //      Determining Winning Records
        List<Account> potentialWinnerAccounts;
        Map<Id,Account> mergeAccountsOnThisCall;
        try{
            //          Get the list of the Account objects possible winners                                                                                                                                //pftD5
            potentialWinnerAccounts=[Select Id,MDMID_gne__c,CreatedDate,MDM_Update_Date_gne__c,MDMId_Status_gne__c,Suffix_gne__c,Website,Plan_Type_gne__c,Plan_Product_Type_gne__c,Payer_gne__c,Plan_gne__c,Account_Level_gne__c,Lives_Medical_gne__c,Lives_Pharmacy_gne__c,Carrier_gne__c from Account where MDMID_gne__c in:potentialWinnerMDMIds for update];
            //          Get the list of the Accounts objects involved in the merges                                                                                                                                             //pftD5
            mergeAccountsOnThisCall=new Map<Id,Account>([Select Id,MDMID_gne__c,CreatedDate,MDM_Update_Date_gne__c,MDMId_Status_gne__c,Suffix_gne__c,Website,Plan_Type_gne__c,Plan_Product_Type_gne__c,Payer_gne__c,Plan_gne__c,Account_Level_gne__c,Lives_Medical_gne__c,Lives_Pharmacy_gne__c,Carrier_gne__c,(Select Id, MDM_Address_ID_gne__c,Account_vod__c From Address_vod__r where MDM_Address_Id_gne__c=null) from Account where Id in:mergeIdsOnThisCall  for update]);

            mergeIdsOnThisCall.clear();
            
            //          Verify Integrity:flag multiple MDMID
            boolean foundMultipleMDMIds=false;
            for(Account winnerAccount:potentialWinnerAccounts){
                MergerHelper mh=potentialWinnersMergerHelpers.get(winnerAccount.MDMID_gne__c);
                //Flagging the duplicate MDM error
                if(mh.winner!=null) {
                    mh.multipleMDMIdFound=true;
                    foundMultipleMDMIds=true;
                } else mh.winner=winnerAccount;
            }
            //      Handling Multiple MDM_Ids Error
            if(foundMultipleMDMIds){
                for(Account winnerAccount:potentialWinnerAccounts){
                    MergerHelper mh=potentialWinnersMergerHelpers.get(winnerAccount.MDMID_gne__c);
                    if(!mh.multipleMDMIdFound) continue;
                    //Create a responseItem
                    ResponseAccountErrorStatus responseItem=new ResponseAccountErrorStatus();
                    response.ResponseErrorItems.add(responseItem);
                    responseItem.ErrorMessage='SFA-I-5_E5';
                    responseItem.ErrorDetails.add('MDM_Id=' + mh.winner.MDMID_gne__c);
                    responseItem.SourceSystemIdentifier=mh.requestItem.SourceSystemIdentifier;
                }
                return handleUpsertError(response,null);
            }
        } catch( Exception e){
            e.setMessage(e.getMessage() + ' Determining Winning Records');
            return handleGenericError(response,e,null,null,null);
        }
        Map<Id,Id> mapBetweenWinnersAndMergeIds=new Map<Id,Id>();
        Map<Id,MergerHelper> winnersMergerHelpers=new  Map<Id,MergerHelper>();

        //          Verify Integrity:set winner record on those without one
        try{
            for(MergerHelper mh:potentialWinnersMergerHelpers.values()){
                if(mh.winner==null && !mh.emptyIdsList){
                    integer h=0;
                    for(integer i=0; i<mh.Ids.size(); i++){
                        Id mId=mh.Ids.get(i);
                        if(mh.winner==null || mh.winner.CreatedDate>mergeAccountsOnThisCall.get(mId).CreatedDate) {
                            mh.winner=mergeAccountsOnThisCall.get(mId);
                            h=i;
                            mh.winnerMDMId=mh.winner.MDMID_gne__c;
                        }
                        mh.ids.remove(h);
                    }
                }
                if(!mh.emptyIdsList && !mh.multipleMDMIdFound) {
                    mergeIdsOnThisCall.addAll(mh.ids);
                    allIdsOnThisCall.addAll(mh.ids);
                    allIdsOnThisCall.add(mh.winner.Id);
                    winnersMergerHelpers.put(mh.winner.Id,mh);
                    for(Id mId:mh.ids) mapBetweenWinnersAndMergeIds.put(mId,mh.winner.Id);
                }
            }
        } catch( Exception e){
            e.setMessage(e.getMessage() + ' Verify Integrity:set winner record on those without one');
            return handleGenericError(response,e,null,null,null);
        }
        //Now, all the MergerHelper have a winner or have an error condition and only the merge accounts that we need for merging
        //      a.  Add [SFDC Account] to each territory of [SFDC Duplicate Account] -  Retrieve AccountShare for [SFDC DuplicateAccount] where Group is of Type ?Territory?.  Loop each row and Insert AccountShare as specified in STM ?AccountShare Mapping Section?.  Note: Only insert AccountShare for [SFDC Account]  which are missing.
        //              
        List<AccountShare> accountSharesForMerge = [Select Id, AccountId, UserOrGroupId, AccountAccessLevel, CaseAccessLevel, OpportunityAccessLevel from AccountShare where AccountId in:allIdsOnThisCall];            
        try{
            //          Sort Out AccountShares with territories
            Set<Id> accountSharesGroups=new Set<Id>();
            for(AccountShare ash:accountSharesForMerge){
                accountSharesGroups.add(ash.UserOrGroupId);
            }
            accountSharesGroups = new Map<ID, Group>([select id, Name from Group where Type='Territory' and id in:accountSharesGroups]).keySet();
            
            integer iaccountSharesForMerge=0;
            while(iaccountSharesForMerge<accountSharesForMerge.size()){
                AccountShare ash=accountSharesForMerge.get(iaccountSharesForMerge);
                if(!accountSharesGroups.contains(ash.UserOrGroupId)){
                    accountSharesForMerge.remove(iaccountSharesForMerge);
                } else iaccountSharesForMerge++;
            }
            
            //          Sort Shares belonging to merge and shares belonging to winners
            for(AccountShare ash:accountSharesForMerge){
                if(mapBetweenWinnersAndMergeIds.containsKey(ash.AccountId) && !winnersMergerHelpers.containsKey(ash.AccountId)){
                    winnersMergerHelpers.get(mapBetweenWinnersAndMergeIds.get(ash.AccountId)).mergeRecordsAccountTerritories.put(ash.UserOrGroupId,ash);
                } else if(winnersMergerHelpers.containsKey(ash.AccountId)){
                    winnersMergerHelpers.get(ash.AccountId).winningRecordAccountTerritories.put(ash.UserOrGroupId,ash);
                }
            }
            
        } catch( Exception e){
            e.setMessage(e.getMessage() + ' Add [SFDC Account] to each territory of [SFDC Duplicate Account]');
            return handleGenericError(response,e,null,null,null);
        }
        
        List<ObjectTerritory2Association> territoryAssociations = new List<ObjectTerritory2Association>();
        try{        
            for(MergerHelper mh:winnersMergerHelpers.values()){
                Set<Id> winningTerritories =new Set<Id>(mh.winningRecordAccountTerritories.keySet());
                for(Id mergeTerritory:mh.mergeRecordsAccountTerritories.keySet()){
                    if(!winningTerritories.contains(mergeTerritory)) {
                    	ObjectTerritory2Association territoryAssociation = new ObjectTerritory2Association(ObjectId = mh.winner.Id, Territory2Id = mergeTerritory, AssociationCause='Territory2Manual');
                        territoryAssociations.add(territoryAssociation);
                    }
                }
            }
        } catch( Exception e){
            e.setMessage(e.getMessage() + ' Create new Territory Associations for winning Records');
            return handleGenericError(response,e,null,null,null);
        }
        
        //      b.  Update [SFDC Account] Non-Type 1 values from [SFDC Duplicate Account] when [SFDC Account] value is empty.
        //          Collect all winners in a single list for final update
        List<Account> winnersUpdateList=new List<Account>();
        Map<Id,Account> winnersUpdateMap=new Map<Id,Account>();
        //Used to build a map of the final response
        Map<Id,ResponseAccountFoundationItem> ResponseItemsMap=new Map<Id,ResponseAccountFoundationItem>();
        try{
            for(Id acctId:mergeIdsOnThisCall){
                if(winnersMergerHelpers.containsKey(acctId)) continue;
                ID winnerId=mapBetweenWinnersAndMergeIds.get(acctId);
                Account acct=mergeAccountsOnThisCall.get(acctId);
                Account acctWinner=winnersMergerHelpers.get(winnerId).winner;
                boolean isUpdate=false;

                if(acctWinner.Suffix_gne__c==null && acct.Suffix_gne__c!=null) { acctWinner.Suffix_gne__c=acct.Suffix_gne__c; isUpdate=true; }
                if(acctWinner.Website==null && acct.Website!=null) { acctWinner.Website=acct.Website; isUpdate=true; }
                if(acctWinner.Plan_Type_gne__c==null && acct.Plan_Type_gne__c!=null) { acctWinner.Plan_Type_gne__c=acct.Plan_Type_gne__c; isUpdate=true; }
                if(acctWinner.Plan_Product_Type_gne__c==null && acct.Plan_Product_Type_gne__c!=null) { acctWinner.Plan_Product_Type_gne__c=acct.Plan_Product_Type_gne__c; isUpdate=true; }
                if(acctWinner.Payer_gne__c==null && acct.Payer_gne__c!=null) { acctWinner.Payer_gne__c=acct.Payer_gne__c; isUpdate=true; }
                if(acctWinner.Plan_gne__c==null && acct.Plan_gne__c!=null) { acctWinner.Plan_gne__c=acct.Plan_gne__c; isUpdate=true; }
                if(acctWinner.Carrier_gne__c==null && acct.Carrier_gne__c!=null) { acctWinner.Carrier_gne__c=acct.Carrier_gne__c; isUpdate=true; }
                
                //pftD5
                
                if(acctWinner.Account_Level_gne__c==null && acct.Account_Level_gne__c!=null) { acctWinner.Account_Level_gne__c=acct.Account_Level_gne__c; isUpdate=true; }
                if(acctWinner.Lives_Pharmacy_gne__c==null && acct.Lives_Pharmacy_gne__c!=null) { acctWinner.Lives_Pharmacy_gne__c=acct.Lives_Pharmacy_gne__c; isUpdate=true; }
                if(acctWinner.Lives_Medical_gne__c==null && acct.Lives_Medical_gne__c!=null) { acctWinner.Lives_Medical_gne__c=acct.Lives_Medical_gne__c; isUpdate=true; }
                                
                if(isUpdate && !winnersUpdateMap.containsKey(winnerId)) winnersUpdateMap.put(winnerId,acctWinner);
                else if(!isUpdate && !ResponseItemsMap.containsKey(winnerId)){
                    ResponseAccountFoundationItem status=new ResponseAccountFoundationItem();
                    status.Account.MDM_Id=acctWinner.MDMID_gne__c;
                    status.Account.Id=acctWinner.Id;
                    status.Account.Operation=OperationType.merge_winner;
                    response.ResponseItems.add(status);
                    ResponseItemsMap.put(acctWinner.Id,status);
                }
            }
            winnersUpdateList=winnersUpdateMap.values();

        } catch( Exception e){
            e.setMessage(e.getMessage() + ' Update [SFDC Account] Non-Type 1');
            return handleGenericError(response,e,null,null,null);
        }
        //      c.  Add [SFDC Duplicate Account]?s Account External entries to [SFDC Account] and delete [SFDC Duplicate Account]?s Account External entries.
        List<Account_External_Id_gne__c> accountExternalForMerge=[Select Account_gne__c, Address_gne__c, MDMID_gne__c, Third_Party_gne__c, Third_Party_Id_gne__c, Third_Party_Index_gne__c, Id from Account_External_Id_gne__c a where Account_gne__c in:mergeIdsOnThisCall];
        List<Account_External_Id_gne__c> accountExternalToCreate=new List<Account_External_Id_gne__c>();
        List<Account_External_Id_gne__c> accountExternalToDelete=new List<Account_External_Id_gne__c>();
        try{
            for(Account_External_Id_gne__c accExt:accountExternalForMerge){
                if(winnersMergerHelpers.containsKey(accExt.Account_gne__c)) continue;
                accountExternalToDelete.add(accExt);
                accountExternalToCreate.add(new Account_External_Id_gne__c(
                                                Account_gne__c=mapBetweenWinnersAndMergeIds.get(accExt.Account_gne__c), 
                                                Address_gne__c=accExt.Address_gne__c, 
                                                MDMID_gne__c=accExt.MDMID_gne__c, 
                                                Third_Party_gne__c=accExt.Third_Party_gne__c, 
                                                Third_Party_Id_gne__c=accExt.Third_Party_Id_gne__c, 
                                                Third_Party_Index_gne__c=accExt.Third_Party_Index_gne__c));
            
            }
        } catch( Exception e){
            e.setMessage(e.getMessage() + ' Add [SFDC Duplicate Account]?s Account External');
            return handleGenericError(response,e,null,null,null);
        }
        
        //      d.  Add [SFDC Duplicate Account]?s Address_vod__c entries where MDM_Address_Id_gne__c is null to [SFDC Account]. 
        List<Address_vod__c> addressesForMerge=new List<Address_vod__c>();
         //      e.  Disable [SFDC Duplicate Account] ? Update [SFDC DuplicateAccount] set MDMId_Status_gne__c='Inactive',  MDM_Update_Date_gne__c = [CADS Publish Date]. 
        try {
            for(Id acctId:mergeIdsOnThisCall){
                if(winnersMergerHelpers.containsKey(acctId)) {
                    //This remove is made in oredr to haveonly accounts merged in this object
                    mergeAccountsOnThisCall.remove(acctId);
                    continue;
                }
                Account acct=mergeAccountsOnThisCall.get(acctId);
                acct.MDMId_Status_gne__c='Inactive';
                acct.MDM_Update_Date_gne__c = winnersMergerHelpers.get(mapBetweenWinnersAndMergeIds.get(acctId)).requestItem.Account.MDM_Update_Date_gne;
            }
        } catch( Exception e){
            e.setMessage(e.getMessage() + ' Disable [SFDC Duplicate Account] ? Update [SFDC DuplicateAccount]');
            return handleGenericError(response,e,null,null,null);
        }
        
        Database.UpsertResult[] lsr;
        Database.DeleteResult[] dlr;
        integer exceptionsCount;
        integer itemsCount;
        try{
            lsr = Utilities_BulkDMLOperationsUtils.batchDMLupsert(territoryAssociations,false);
        }catch(Exception e){
            e.setMessage(e.getMessage() + ' Upserting Territory Associations');
            return handleGenericError(response,e,sp,null,null);
        }
        //  Error Verification
        exceptionsCount=0;
        itemsCount=0;
        for(Database.UpsertResult sr : lsr){
            if(!sr.isSuccess()){
                exceptionsCount++;
                //Create a responseItem
                ResponseAccountErrorStatus responseItem=new ResponseAccountErrorStatus();
                response.ResponseErrorItems.add(responseItem);
                MergerHelper winnerMerger=winnersMergerHelpers.get(territoryAssociations[itemsCount].ObjectId);
                responseItem.ErrorMessage='Error while usperting AccountShares MDM_Id=' + winnerMerger.winner.MDMID_gne__c + ' SFDC_Id=' + winnerMerger.winner.Id;
                for(Database.Error err:sr.getErrors()){
                    responseItem.ErrorCode.add(err.getStatusCode().name());
                    responseItem.ErrorDetails.add(err.getMessage());
                }
                responseItem.SourceSystemIdentifier=winnerMerger.requestItem.SourceSystemIdentifier;
            } 
            itemsCount++;
        }
        if(exceptionsCount>0) return handleUpsertError(response,sp);


        //  Deleting Old Accounts External IDs
        try{
            dlr = Utilities_BulkDMLOperationsUtils.batchDMLdelete(accountExternalToDelete,false);
        }catch(Exception e){
            e.setMessage(e.getMessage() + ' Deleting Old Accounts External IDs');
            return handleGenericError(response,e,sp,null,null);
        }
        //  Error Verification
        exceptionsCount=0;
        itemsCount=0;
        for(Database.DeleteResult sr : dlr){
            if(!sr.isSuccess()){
                exceptionsCount++;
                //Create a responseItem
                ResponseAccountErrorStatus responseItem=new ResponseAccountErrorStatus();
                response.ResponseErrorItems.add(responseItem);
                MergerHelper winnerMerger=winnersMergerHelpers.get(mapBetweenWinnersAndMergeIds.get(accountExternalToDelete[itemsCount].Account_gne__c));
                responseItem.ErrorMessage='Error while deleting previous Account_External_Id_gne__c related to merge of Account MDM_Id=' + winnerMerger.winner.MDMID_gne__c + ' SFDC_Id=' + winnerMerger.winner.Id;
                for(Database.Error err:sr.getErrors()){
                    responseItem.ErrorCode.add(err.getStatusCode().name());
                    responseItem.ErrorDetails.add(err.getMessage());
                }
                responseItem.SourceSystemIdentifier=winnerMerger.requestItem.SourceSystemIdentifier;
            } 
            itemsCount++;
        }
        if(exceptionsCount>0) return handleUpsertError(response,sp);


        //  Upserting Account External IDs
        try{
            lsr = Utilities_BulkDMLOperationsUtils.batchDMLupsert(accountExternalToCreate,false);
        }catch(Exception e){
            e.setMessage(e.getMessage() + ' Upserting Account External IDs');
            return handleGenericError(response,e,sp,null,null);
        }
        //  Error Verification
        exceptionsCount=0;
        itemsCount=0;
        for(Database.UpsertResult sr : lsr){
            if(!sr.isSuccess()){
                exceptionsCount++;
                //Create a responseItem
                ResponseAccountErrorStatus responseItem=new ResponseAccountErrorStatus();
                response.ResponseErrorItems.add(responseItem);
                MergerHelper winnerMerger=winnersMergerHelpers.get(accountExternalToCreate[itemsCount].Account_gne__c);
                responseItem.ErrorMessage='Error while usperting Account_External_Id_gne__c MDM_Id=' + winnerMerger.winner.MDMID_gne__c + ' SFDC_Id=' + winnerMerger.winner.Id;
                for(Database.Error err:sr.getErrors()){
                    responseItem.ErrorCode.add(err.getStatusCode().name());
                    responseItem.ErrorDetails.add(err.getMessage());
                }
                responseItem.SourceSystemIdentifier=winnerMerger.requestItem.SourceSystemIdentifier;
            } 
            itemsCount++;
        }
        if(exceptionsCount>0) return handleUpsertError(response,sp);
            
        for(Account acct:winnersUpdateList){
            ResponseAccountFoundationItem status=new ResponseAccountFoundationItem();
            status.Account.MDM_Id=acct.MDMID_gne__c;
            status.Account.Id=acct.Id;
            status.Account.Operation=OperationType.merge_winner;
            response.ResponseItems.add(status);
            ResponseItemsMap.put(acct.Id,status);
        }

        //  Upserting Merged Accounts
        try{
            lsr = Utilities_BulkDMLOperationsUtils.batchDMLupsert(mergeAccountsOnThisCall.values(),false);
        }catch(Exception e){
            e.setMessage(e.getMessage() + ' Upserting Merged Accounts');
            return handleGenericError(response,e,sp,null,null);
        }
        //  Error Verification
        exceptionsCount=0;
        itemsCount=0;
        for(Database.UpsertResult sr : lsr){
            if(!sr.isSuccess()){
                exceptionsCount++;
                //Create a responseItem
                ResponseAccountErrorStatus responseItem=new ResponseAccountErrorStatus();
                response.ResponseErrorItems.add(responseItem);
                MergerHelper winnerMerger=winnersMergerHelpers.get(mapBetweenWinnersAndMergeIds.get(mergeAccountsOnThisCall.values()[itemsCount].Id));
                responseItem.ErrorMessage='Error while usperting Merged Account MDM_Id=' + winnerMerger.winner.MDMID_gne__c + ' SFDC_Id=' + winnerMerger.winner.Id;
                for(Database.Error err:sr.getErrors()){
                    responseItem.ErrorCode.add(err.getStatusCode().name());
                    responseItem.ErrorDetails.add(err.getMessage());
                }
                responseItem.SourceSystemIdentifier=winnerMerger.requestItem.SourceSystemIdentifier;
            } else {
                ResponseAccountFoundationItem status=ResponseItemsMap.get(mapBetweenWinnersAndMergeIds.get(sr.getId()));
                ResponseResult rs=new ResponseResult();
                status.MergedAccounts.add(rs);
                rs.MDM_Id=mergeAccountsOnThisCall.values()[itemsCount].MDMID_gne__c;
                rs.Id=sr.getId();
                rs.Operation=OperationType.merged;
            }
            itemsCount++;
        }
        if(exceptionsCount>0) return handleUpsertError(response,sp);

        //  Upserting Final Accounts
        try{
            lsr = Utilities_BulkDMLOperationsUtils.batchDMLupsert(winnersUpdateList,false);
        }catch(Exception e){
            e.setMessage(e.getMessage() + ' Upserting Final Accounts');
            return handleGenericError(response,e,sp,null,null);
        }
        
        //  Error Verification
        exceptionsCount=0;
        itemsCount=0;

        for(Database.UpsertResult sr : lsr){
            if(!sr.isSuccess()){
                exceptionsCount++;
                //Create a responseItem
                ResponseAccountErrorStatus responseItem=new ResponseAccountErrorStatus();
                response.ResponseErrorItems.add(responseItem);
                MergerHelper winnerMerger=winnersMergerHelpers.get(winnersUpdateList[itemsCount].Id);

                responseItem.ErrorMessage='Error while usperting Accounts MDM_Id=' + winnerMerger.winner.MDMID_gne__c + ' SFDC_Id=' + winnerMerger.winner.Id;
                for(Database.Error err:sr.getErrors()){
                    responseItem.ErrorCode.add(err.getStatusCode().name());
                    responseItem.ErrorDetails.add(err.getMessage());
                }
                responseItem.SourceSystemIdentifier=winnerMerger.requestItem.SourceSystemIdentifier;
            } 
            itemsCount++;
        }
        if(exceptionsCount>0) return handleUpsertError(response,sp);
        return response;
    }
    private static Savepoint  AccountFoundationPlanProductMerge(RequestAccountFoundation Request,ResponseAccountFoundation response){
        //Setting a SavePoint
        Savepoint sp = Database.setSavepoint();
        //          Get all the MDM Ids in this call into one object
        Set<string> potentialWinnerMDMIds=new Set<string>();
        Map<String,MergerHelper> potentialWinnersMergerHelpers=new  Map<String,MergerHelper>();
        //          Get all the Merge Ids in this call into one object
        Set<Id> mergeIdsOnThisCall=new Set<Id>();
        Set<Id> allIdsOnThisCall=new Set<Id>();
        
        try{
            //          Prepare local storage for all the values to be merged
            for(RequestAccountFoundationItem item:Request.RequestItems){
                potentialWinnerMDMIds.add(item.Account.MDMID_gne);
                MergerHelper mh=new MergerHelper();
                mh.winnerMDMId=item.Account.MDMID_gne;
                mh.requestItem=item;
                potentialWinnersMergerHelpers.put(item.Account.MDMID_gne,mh);
                if(item.Ids!=null && item.Ids.size()!=0){
                    mh.ids=item.Ids;
                    for(string itemIdStr:item.Ids){
                        Id itemId=itemIdStr;
                        mergeIdsOnThisCall.add(itemId);
                    }
                } else {
                    mh.emptyIdsList=true;
                }
            }
        } catch( Exception e){
            e.setMessage(e.getMessage() + ' Prepare local storage for all the values to be merged');
            handleGenericError(response,e,null,'SFA-I-6_E99','Unhandled Error during PlanProduct  Record processing for CADS Id ' + Request.RequestItems[0].SourceSystemIdentifier); 
            return NULL;
        }
        //      Determining Winning Records (SFAI1 Step 8)
        
        List<Account> potentialWinnerAccounts;
        Map<Id,Account> mergeAccountsOnThisCall;
        try{

            //          Get the list of the Account objects possible winners                                                                                                                                //pftD5
            potentialWinnerAccounts=[Select Id,MDMID_gne__c,CreatedDate,MDM_Update_Date_gne__c,MDMId_Status_gne__c,Suffix_gne__c,Website,Plan_Type_gne__c,Plan_Product_Type_gne__c,Payer_gne__c,Plan_gne__c,Account_Level_gne__c,Lives_Pharmacy_gne__c,Lives_Medical_gne__c,Carrier_gne__c from Account where MDMID_gne__c in:potentialWinnerMDMIds for update];
            //          Get the list of the Accounts objects involved in the merges                                                                                                                                             //pftD5
            mergeAccountsOnThisCall=new Map<Id,Account>([Select Id,MDMID_gne__c,CreatedDate,MDM_Update_Date_gne__c,MDMId_Status_gne__c,Suffix_gne__c,Website,Plan_Type_gne__c,Plan_Product_Type_gne__c,Payer_gne__c,Plan_gne__c,Account_Level_gne__c,Lives_Pharmacy_gne__c,Lives_Medical_gne__c,Carrier_gne__c,(Select Id, MDM_Address_ID_gne__c,Account_vod__c From Address_vod__r where MDM_Address_Id_gne__c=null) from Account where Id in:mergeIdsOnThisCall  for update]);

            mergeIdsOnThisCall.clear();
            
            //          Verify Integrity:flag multiple MDMID
            boolean foundMultipleMDMIds=false;
            for(Account winnerAccount:potentialWinnerAccounts){
                MergerHelper mh=potentialWinnersMergerHelpers.get(winnerAccount.MDMID_gne__c);
                //Flagging the duplicate MDM error
                if(mh.winner!=null) {
                    mh.multipleMDMIdFound=true;
                    foundMultipleMDMIds=true;
                } else mh.winner=winnerAccount;
            }
            //      Handling Multiple MDM_Ids Error
            if(foundMultipleMDMIds){
                for(Account winnerAccount:potentialWinnerAccounts){
                    MergerHelper mh=potentialWinnersMergerHelpers.get(winnerAccount.MDMID_gne__c);
                    if(!mh.multipleMDMIdFound) continue;
                    //Create a responseItem
                    ResponseAccountErrorStatus responseItem=new ResponseAccountErrorStatus();
                    response.ResponseErrorItems.add(responseItem);
                    responseItem.ErrorMessage='Merge SFDC Account failed for  PlanProduct Identifier <<PlanProductIdentifier>>';
                    responseItem.ErrorCode.add('SFA-I-6_E12');
                    responseItem.ErrorDetails.add('MDM_Id=' + mh.winner.MDMID_gne__c);
                    responseItem.SourceSystemIdentifier=mh.requestItem.SourceSystemIdentifier;
                }
                handleUpsertError(response,null);
                return null;
            }
        } catch( Exception e){
            e.setMessage(e.getMessage() + ' Determining Winning Records (SFAI1 Step 8)');
            handleGenericError(response,e,null,'SFA-I-6_E99','Unhandled Error during PlanProduct Record processing for CADS Id ' + Request.RequestItems[0].SourceSystemIdentifier);
            return null;
        }
        Map<Id,Id> mapBetweenWinnersAndMergeIds=new Map<Id,Id>();
        Map<Id,MergerHelper> winnersMergerHelpers=new  Map<Id,MergerHelper>();

        //          Verify Integrity:set winner record on those without one
        try{
            for(MergerHelper mh:potentialWinnersMergerHelpers.values()){
                if(mh.winner==null && !mh.emptyIdsList){
                    integer h=0;
                    for(integer i=0; i<mh.Ids.size(); i++){
                        Id mId=mh.Ids.get(i);
                        if(mh.winner==null || mh.winner.CreatedDate>mergeAccountsOnThisCall.get(mId).CreatedDate) {
                            mh.winner=mergeAccountsOnThisCall.get(mId);
                            h=i;
                            mh.winnerMDMId=mh.winner.MDMID_gne__c;
                        }
                        mh.ids.remove(h);
                    }
                }
                if(!mh.emptyIdsList && !mh.multipleMDMIdFound) {
                    mergeIdsOnThisCall.addAll(mh.ids);
                    allIdsOnThisCall.addAll(mh.ids);
                    allIdsOnThisCall.add(mh.winner.Id);
                    winnersMergerHelpers.put(mh.winner.Id,mh);
                    for(Id mId:mh.ids) mapBetweenWinnersAndMergeIds.put(mId,mh.winner.Id);
                }
            }
        } catch( Exception e){
            e.setMessage(e.getMessage() + ' Verify Integrity:set winner record on those without one');
            handleGenericError(response,e,null,'SFA-I-6_E99','Unhandled Error during PlanProduct Record processing for CADS Id ' + Request.RequestItems[0].SourceSystemIdentifier);
            return null;
        }
        //Now, all the MergerHelper have a winner or have an error condition and only the merge accounts that we need for merging
        
        //      1.  Disable SFDC Duplicate Account List 
        try {
            for(Id acctId:mergeIdsOnThisCall){
                if(winnersMergerHelpers.containsKey(acctId)) {
                    //Building a map of the current response
                    ResponseAccountFoundationItem status=new ResponseAccountFoundationItem();
                    Account winn=mergeAccountsOnThisCall.get(acctId);
                    status.Account.MDM_Id=winn.MDMID_gne__c;
                    status.Account.Id=winn.Id;
                    status.Account.Operation=OperationType.merge_winner;
                    response.ResponseItems.add(status);
                    //This remove is made in oredr to haveonly accounts merged in this object
                    mergeAccountsOnThisCall.remove(acctId);
                    continue;
                }
                Account acct=mergeAccountsOnThisCall.get(acctId);
                acct.MDMId_Status_gne__c='Inactive';
                acct.MDM_Update_Date_gne__c = winnersMergerHelpers.get(mapBetweenWinnersAndMergeIds.get(acctId)).requestItem.Account.MDM_Update_Date_gne;
            }
        } catch( Exception e){
            e.setMessage(e.getMessage() + ' Disable SFDC Duplicate Account List ');
            handleGenericError(response,e,null,'SFA-I-6_E99','Unhandled Error during PlanProduct Record processing for CADS Id ' + Request.RequestItems[0].SourceSystemIdentifier);
            return null;
        }
        
        //This is a quick patch but i can't do better than this for now
        if(response.ResponseItems.size()==0 && mergeAccountsOnThisCall.values().size()>0){
            ResponseAccountFoundationItem status=new ResponseAccountFoundationItem();
            Account winn=winnersMergerHelpers.values().get(0).winner;
            status.Account.MDM_Id=winn.MDMID_gne__c;
            status.Account.Id=winn.Id;
            status.Account.Operation=OperationType.merge_winner;
            response.ResponseItems.add(status);
        }
        
        //      Upserting Records
        Database.UpsertResult[] lsr;
        Database.DeleteResult[] dlr;
        integer exceptionsCount;
        integer itemsCount;

        //  Upserting Merged Accounts
        try{
            lsr = Utilities_BulkDMLOperationsUtils.batchDMLupsert(mergeAccountsOnThisCall.values(),false);
        }catch(Exception e){
            handleGenericError(response,e,sp,'SFA-I-6_E99','Unhandled Error during PlanProduct Record processing for CADS Id ' + Request.RequestItems[0].SourceSystemIdentifier);
            return null;
        }
        //  Error Verification
        exceptionsCount=0;
        itemsCount=0;
        for(Database.UpsertResult sr : lsr){
            if(!sr.isSuccess()){
                exceptionsCount++;
                //Create a responseItem
                ResponseAccountErrorStatus responseItem=new ResponseAccountErrorStatus();
                response.ResponseErrorItems.add(responseItem);
                MergerHelper winnerMerger=winnersMergerHelpers.get(mapBetweenWinnersAndMergeIds.get(mergeAccountsOnThisCall.values()[itemsCount].Id));
                responseItem.ErrorMessage='Error while usperting Account MDM_Id=' + winnerMerger.winner.MDMID_gne__c + ' SFDC_Id=' + winnerMerger.winner.Id;
                for(Database.Error err:sr.getErrors()){
                    responseItem.ErrorCode.add(err.getStatusCode().name());
                    responseItem.ErrorDetails.add(err.getMessage());
                }
                responseItem.SourceSystemIdentifier=winnerMerger.requestItem.SourceSystemIdentifier;
            } else {
                ResponseAccountFoundationItem status=response.ResponseItems[0];
                ResponseResult rs=new ResponseResult();
                status.MergedAccounts.add(rs);
                rs.MDM_Id=mergeAccountsOnThisCall.values()[itemsCount].MDMID_gne__c;
                rs.Id=sr.getId();
                rs.Operation=OperationType.merged;
            } 
            itemsCount++;
        }
        if(exceptionsCount>0) {
            handleUpsertError(response,sp); 
            return null;
        }
        return sp;
    }

    private static void  AccountFoundationPlanProductUpsert(RequestAccountFoundation Request,ResponseAccountFoundation response, Savepoint sp){
        List<Account> serializedAccounts=new List<Account>();
        List<Account_External_Id_gne__c> serializedAccountsExtIds=new List<Account_External_Id_gne__c>();

        Map<string,RequestAccountFoundationItem_mirror> internalTreeMap=new Map<string,RequestAccountFoundationItem_mirror>();
        Map<string,Address_stub_mirror> internalAddressSubTreeMap=new Map<string,Address_stub_mirror>();
        List<Account> accs;
        RequestAccountFoundationItem mainItem=Request.RequestItems[0];
        boolean isDisabled=false;
        
        if(mainItem.Account.MDMID_Status_gne!=null && mainItem.Account.MDMID_Status_gne=='Inactive') isDisabled=true;
        if(mainItem.Carrier_MDM_Id!=null ) {
            accs=[Select Id,MDMID_gne__c from Account where MDMID_gne__c=:mainItem.Carrier_MDM_Id];
            if(accs.size()==1) mainItem.Account.Carrier_gne=accs[0].Id;
            else {
                ResponseAccountErrorStatus responseItem=new ResponseAccountErrorStatus();
                response.ResponseErrorItems.add(responseItem);
                responseItem.SourceSystemIdentifier=mainItem.SourceSystemIdentifier;
                responseItem.ErrorDetails.add('MDM_Id=' + mainItem.Carrier_MDM_Id);
                if(accs.size()>1) {
                    responseItem.ErrorMessage='Multiple Active MDM XREF present (ie Null RecordEffectiveDate ). '+mainItem.Carrier_MDM_Id+' for Carrier';
                    responseItem.ErrorCode.add('SFA-I-6_E3');
                } else {
                    responseItem.ErrorMessage='SFDC Account Missing for Carrier MDM record ' + mainItem.Carrier_MDM_Id;
                    responseItem.ErrorCode.add('SFA-I-6_E9');
                }
                handleUpsertError(response,sp);
                return;
            }
        }
        if(mainItem.Payer_MDM_Id!=null ) {
            accs=[Select Id,MDMID_gne__c from Account where MDMID_gne__c=:mainItem.Payer_MDM_Id];
            if(accs.size()==1) mainItem.Account.Payer_gne=accs[0].Id;
            else {
                ResponseAccountErrorStatus responseItem=new ResponseAccountErrorStatus();
                response.ResponseErrorItems.add(responseItem);
                responseItem.SourceSystemIdentifier=mainItem.SourceSystemIdentifier;
                responseItem.ErrorDetails.add('MDM_Id=' + mainItem.Payer_MDM_Id);
                if(accs.size()>1) {
                    responseItem.ErrorMessage='Multiple Active MDM XREF present (ie Null RecordEffectiveDate ). '+mainItem.Payer_MDM_Id+' for Payer';
                    responseItem.ErrorCode.add('SFA-I-6_E3');
                } else {
                    responseItem.ErrorMessage='SFDC Account Missing for Payer MDM record ' + mainItem.Payer_MDM_Id;
                    responseItem.ErrorCode.add('SFA-I-6_E7');
                }
                handleUpsertError(response,sp);
                return;
            }
        }
        //Init the list of the Person Accounts Recordtypes;
        Set<Id> personAccountsRecordtypes=new Map<ID, RecordType>([Select Id,Name from RecordType where IsPersonType=true]).keySet();
        try{
            //          Get all the MDM Ids in this call into one object
            Set<string> MDMIdsOnThisCall=new Set<string>();
            Set<string> SFDCIdsOnThisCall=new Set<string>();
            
            for(RequestAccountFoundationItem item:Request.RequestItems){
                MDMIdsOnThisCall.add(item.Account.MDMID_gne);
                if(item.Account.Id!=null) 
                    SFDCIdsOnThisCall.add(item.Account.Id);
            }

            List<Account> accountsToUpdateList=[ Select a.Account_Type_gne__c, a.AMS_ID_gne__c, a.Carrier_gne__c, 
                                                a.Cell_Phone_gne__c, a.Credentials_gne__c, a.Date_of_Birth_gne__c, 
                                                a.Fax, a.FirstName, a.Gender_vod__c, a.Id, a.LastName, 
                                                a.MDM_Update_Date_gne__c, a.MDM_plan_product_id_gne__c, a.MDMID_Status_gne__c, 
                                                a.middle_vod__c, a.Name, a.Payer_gne__c, a.Phone, a.Plan_gne__c, 
                                                a.Plan_Product_Type_gne__c, a.Plan_Type_gne__c,   
                                                a.Professional_Type_gne__c, a.RecordTypeId, a.Salutation, 
                                                a.Specialties_gne__c, a.Suffix_gne__c, a.Website,
                                                a.Account_Level_gne__c, a.Lives_Medical_gne__c, a.Lives_Pharmacy_gne__c
                                                from Account a where 
                                                a.MDM_plan_product_id_gne__c in:MDMIdsOnThisCall or 
                                                a.Id in:SFDCIdsOnThisCall for update]; //Calling lock on selected accounts //pftD5

            Map<string,Id> MDMIdsAlreadyInSFDC=new Map<string,Id>();                       
            Map<Id,Account> accountsToUpdateMap= new Map<Id,Account>();
            for(Account acct:accountsToUpdateList){
                accountsToUpdateMap.put(acct.Id,acct);
                
                if (acct.MDM_Plan_Product_Id_gne__c != null )
                    MDMIdsAlreadyInSFDC.put(acct.MDM_Plan_Product_Id_gne__c, acct.Id);
            }
            
            for(RequestAccountFoundationItem item:Request.RequestItems){
                //  Recreate the request tree:add a RequestAccountFoundationItem_mirror to the tree Map
                RequestAccountFoundationItem_mirror item_mirror=new RequestAccountFoundationItem_mirror();
                internalTreeMap.put(item.Account.MDMID_gne,item_mirror);
                item_mirror.requestItem=item;
                

                if( ( item.Account.Id!=null && accountsToUpdateMap.containsKey(item.Account.Id) )  || 
                    MDMIdsAlreadyInSFDC.containsKey(item.Account.MDMID_gne) ){

                    //This Account's MDM id is already contained in SFDC
                    if ( item.Account.Id != null && accountsToUpdateMap.containsKey(item.Account.Id) )   
                        item_mirror.Account_obj=accountsToUpdateMap.get(item.Account.Id);
                    else 
                        item_mirror.Account_obj=accountsToUpdateMap.get(MDMIdsAlreadyInSFDC.get(item.Account.MDMID_gne));

                    //Store the item by id as well in the internal mapping (will be used during the upsert process)
                    internalTreeMap.put(item_mirror.Account_obj.Id,item_mirror);
                    // Updating Accounts
                    ResponseAccountFoundationItem responseAccountItem=populateRequestAccountFoundationItemMirror(item_mirror,item,serializedAccounts,serializedAccountsExtIds,personAccountsRecordtypes.contains(item.Account.RecordTypeId),true);                                  
                    if(responseAccountItem!=null) response.ResponseItems.add(responseAccountItem);

                } else {
                    //This Account's MDM ID was not contained in SFDC
                    populateRequestAccountFoundationItemMirror(item_mirror,item,serializedAccounts,serializedAccountsExtIds,personAccountsRecordtypes.contains(item.Account.RecordTypeId),true);    
                }
            }
        } catch( Exception e){
            handleGenericError(response,e,sp,'SFA-I-6_E99','Unhandled Error during PlanProduct Record processing for CADS Id ' + Request.RequestItems[0].SourceSystemIdentifier);
            return;
        }
        //
        //      Upserting Records
        Database.UpsertResult[] lsr;
        integer exceptionsCount;
        integer itemsCount;
        Map<string,ResponseAccountErrorStatus> ResponseItemMapByAccountId=new Map<string,ResponseAccountErrorStatus>();
        try{
            lsr = Utilities_BulkDMLOperationsUtils.batchDMLupsert(serializedAccounts,false);
        }catch(Exception e){
            handleGenericError(response,e,sp,'SFA-I-6_E99','Unhandled Error during PlanProduct Record processing for CADS Id ' + Request.RequestItems[0].SourceSystemIdentifier);
            return;
        }
        //  Error Verification
        exceptionsCount=0;
        itemsCount=0;
        for(Database.UpsertResult sr : lsr){
            RequestAccountFoundationItem_mirror currentInternalTreeMapNode=internalTreeMap.get(serializedAccounts[itemsCount].MDM_plan_product_id_gne__c);
            if(!sr.isSuccess()){
                exceptionsCount++;
                //Create a responseItem
                ResponseAccountErrorStatus responseItem=new ResponseAccountErrorStatus();
                response.ResponseErrorItems.add(responseItem);
                responseItem.MDMId=serializedAccounts[itemsCount].MDM_plan_product_id_gne__c;
                if(isDisabled) {
                    responseItem.ErrorMessage='Disable SFDC Account failed for  PlanProduct Identifier ' + serializedAccounts[itemsCount].MDM_plan_product_id_gne__c;
                    responseItem.ErrorCode.add('SFA-I-6_E14');
                } else if(!sr.isCreated()) {
                    responseItem.ErrorMessage='Update SFDC Account failed for  PlanProduct Identifier ' + serializedAccounts[itemsCount].MDM_plan_product_id_gne__c;
                    responseItem.ErrorCode.add('SFA-I-6_E13');
                } else {
                    responseItem.ErrorMessage='Create SFDC Account failed for  PlanProduct Identifier ' + serializedAccounts[itemsCount].MDM_plan_product_id_gne__c;
                    responseItem.ErrorCode.add('SFA-I-6_E11');
                }
                responseItem.ErrorDetails.add('MDM_Id=' + serializedAccounts[itemsCount].MDM_plan_product_id_gne__c);
                for(Database.Error err:sr.getErrors()){
                    responseItem.ErrorCode.add(err.getStatusCode().name());
                    responseItem.ErrorDetails.add(err.getMessage());
                }
                responseItem.SourceSystemIdentifier=currentInternalTreeMapNode.requestItem.SourceSystemIdentifier;
            } else if(exceptionsCount==0) {
                //If no error yet occurred
                //Use the current internalTreeMap to store addresses by Address SFDC Id
                internalTreeMap.put(sr.getId(),currentInternalTreeMapNode);
                //Add Address Id to Address External Id
                for(Address_stub_mirror addressStub:currentInternalTreeMapNode.Addresses){
                    if(sr.isCreated()) addressStub.Address.Account_vod__c=sr.getId();
                }
                for(Account_External_Id_gne__c AccountExternalId:currentInternalTreeMapNode.Account_External_Ids){
                    if(sr.isCreated()) AccountExternalId.Account_gne__c=sr.getId();
                }
                if(sr.isCreated()){
                    ResponseAccountFoundationItem status=new ResponseAccountFoundationItem();
                    status.Account.MDM_Id=serializedAccounts[itemsCount].MDM_plan_product_id_gne__c;
                    status.Account.Id=sr.getId();
                    status.Account.Operation=OperationType.created;
                    response.ResponseItems.add(status);
                }
            }
            itemsCount++;
        }
        if(exceptionsCount>0) {
            handleUpsertError(response,sp);
            return;
        }
    }    
}