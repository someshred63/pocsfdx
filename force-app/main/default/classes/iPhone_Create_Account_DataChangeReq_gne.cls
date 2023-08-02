/******************************************************************************************
*  @author: Sebastian Karczmarski, Roche (contractor)
*  @email: sebastian.karczmarski@contractors.roche.com
*  Created: 2013-05-24
*  Project: OTR2
*  Description: REST Webservice, creates a DataChangeRequest for the specified account.
*******************************************************************************************/
@RestResource(urlMapping='/iPhoneCreateAccountDataChangeRequest/*')
global with sharing class iPhone_Create_Account_DataChangeReq_gne {

    @HttpPost
    global static iPhone_Commons_gne.RestResponse processRequest(String unixId, String accountId, String addressId, String iPhoneRequestId, String requestType, List<DCRAttribute> requestAttributes) {
        return iPhone_Commons_gne.executeAlterData(
            new CreateAccountDataChangeExecutor(),
            new CreateAccountDataChangeRequestArgs(unixId, accountId, addressId, iPhoneRequestId, requestType, requestAttributes)
        );
    }

    class CreateAccountDataChangeRequestArgs implements iPhone_Commons_gne.BaseArgs{
        final String unixId;
        final String accountId;
        final String addressId;
        final String iPhoneRequestId;
        final String requestType;
        final List<DCRAttribute> requestAttributes;

        public CreateAccountDataChangeRequestArgs(String unixId, String accountId, String addressId, String iPhoneRequestId, String requestType, List<DCRAttribute> requestAttributes) {
            this.unixId = unixId;
            this.accountId = accountId;
            this.addressId = addressId;
            this.iPhoneRequestId = iPhoneRequestId;
            this.requestType = requestType;
            this.requestAttributes = requestAttributes;
        }

        public String getIPhoneRequestId(){
            return this.iPhoneRequestId;
        }
    }

    class CreateAccountDataChangeExecutor implements iPhone_Commons_gne.Runnable {

        Boolean isLicenseInfoUpdateRequest;
        Boolean isAccountInfoUpdateRequest;
        Boolean isAccountRemoveDuplicatesRequest;
        Boolean isAccountRemoveInactivateRequest;
        Boolean isAccountReactivateRequest;
        Boolean isAddressInfoUpdateRequest;
        Boolean isAddressRemoveInactivateRequest;
        Boolean isAddressReactivateRequest;
        Boolean isAddressRemoveDuplicatesRequest;
        Boolean isAccountRequest;
        Boolean isAddressRequest;
        Boolean isUsLicensedPhysicianRequest;

        Boolean isAmsHCO;
        Boolean isCanadaUser;
        Boolean isPersonAccount;

        Map<String, String> attributes;
        Change_Request_gne__c dataChangeRequest = new Change_Request_gne__c();
        DCRAttributeKeys attributesKey = new DCRAttributeKeys();

        public Object run(Object args) {
            CreateAccountDataChangeRequestArgs dcrArgs = (CreateAccountDataChangeRequestArgs)args;
            if (String.isNotBlank(dcrArgs.iPhoneRequestId)){
            	List<Change_Request_gne__c> currentDcrs = [SELECT Id FROM Change_Request_gne__c WHERE iPhone_Request_Id_gne__c = :dcrArgs.iPhoneRequestId];
            	if (!currentDcrs.isEmpty()){
            		return String.valueOf(currentDcrs[0].Id);
            	}
        	}
            initProperties(dcrArgs);

            Change_Request_gne__c changeRequest = buildChangeRequest();
            System.debug('ChangeRequest: ' + changeRequest);
            insert changeRequest;

            return String.valueOf(changeRequest.id);
        }

        private void initProperties(CreateAccountDataChangeRequestArgs dcrArgs) {
            Account account = iPhone_DAO.getAccountById(dcrArgs.accountId);
            User user = iPhone_DAO.getUserByExternalId(dcrArgs.unixId);

            this.isCanadaUser = getIsCanadaUser(user.profileId);
            this.isAmsHCO = isAmsHCO(account);
            this.isPersonAccount = account.IsPersonAccount;
            this.attributes = getAttributes(dcrArgs.requestAttributes);

            this.isLicenseInfoUpdateRequest = dcrArgs.requestType.equalsIgnoreCase('LicenseInfoUpdate');
            this.isAccountInfoUpdateRequest = dcrArgs.requestType.equalsIgnoreCase('AccountInfoUpdate');
            this.isAccountRemoveDuplicatesRequest = dcrArgs.requestType.equalsIgnoreCase('AccountRemoveDuplicates');
            this.isAccountRemoveInactivateRequest = dcrArgs.requestType.equalsIgnoreCase('AccountRemoveInactivate');
            this.isAccountReactivateRequest = dcrArgs.requestType.equalsIgnoreCase('AccountReactivate');


            this.isAddressInfoUpdateRequest = dcrArgs.requestType.equalsIgnoreCase('AddressInfoUpdate');
            this.isAddressRemoveInactivateRequest = dcrArgs.requestType.equalsIgnoreCase('AddressRemoveInactivate');
            this.isAddressReactivateRequest = dcrArgs.requestType.equalsIgnoreCase('AddressReactivate');
            this.isAddressRemoveDuplicatesRequest = dcrArgs.requestType.equalsIgnoreCase('AddressRemoveDuplicates');
            this.isUsLicensedPhysicianRequest = dcrArgs.requestType.equalsIgnoreCase('UsLicensedPhysician');


            this.isAccountRequest = this.isAccountInfoUpdateRequest || this.isAccountRemoveDuplicatesRequest || this.isAccountRemoveInactivateRequest || this.isAccountReactivateRequest;
            this.isAddressRequest = this.isAddressInfoUpdateRequest || this.isAddressRemoveInactivateRequest || this.isAddressReactivateRequest || this.isAddressRemoveDuplicatesRequest;

            this.initDCRrecord(user.id, dcrArgs.addressId, account, dcrArgs.iPhoneRequestId);
            system.debug('Object initialized: ' + this);
        }

        private Change_Request_gne__c buildChangeRequest() {
            if(this.isAccountInfoUpdateRequest) {
                if(this.isPersonAccount) {
                    buildDCRforAccountInfoUpdateHCPRequest();
                } else {
                    buildDCRforAccountInfoUpdateHCORequest();
                }
            } else if(this.isLicenseInfoUpdateRequest) {
                buildDCRforLicenseInfoUpdateRequest();
            } else if(this.isAccountRemoveInactivateRequest) {
                buildDCRforAccountRemoveInactivateRequest();
            } else if(this.isAccountRemoveDuplicatesRequest) {
                buildDCRforAccountRemoveDuplicatesRequest();
            } else if(this.isAddressRemoveInactivateRequest) {
                buildDCRforAddressRemoveInactivateRequest();
            } else if(this.isAddressInfoUpdateRequest) {
                buildDCRforAddressInfoUpdateRequest();
            } else if(this.isAddressReactivateRequest) {
                buildDCRforAddressReactivateRequest();
            } else if(this.isAccountReactivateRequest) {
                buildDCRforAccountReactivateRequest();
            } else if(this.isAddressRemoveDuplicatesRequest) {
                buildDCRforAddressRemoveDuplicatesRequest();
            } else if(this.isUsLicensedPhysicianRequest) {
                buildDCRforUsLicensedPhysicianRequest();
            }

            return this.dataChangeRequest;
        }

        private void initDCRrecord(String userId, String addressId, Account account, String iPhoneRequestId) {

            this.dataChangeRequest.OwnerId = userId;
            this.dataChangeRequest.Account_gne__c = account.id;
            this.dataChangeRequest.RecordTypeId = getRecordTypeId();
            this.dataChangeRequest.Reason_dcr_gne__c = '';

            if (String.isNotBlank(iPhoneRequestId)){
                this.dataChangeRequest.iPhone_Request_Id_gne__c = iPhoneRequestId;
            }

            if(this.isAccountRequest) {
                if(this.isPersonAccount) {
                    this.dataChangeRequest.first_name_dcr_gne__c        = account.firstName;
                    this.dataChangeRequest.last_name_dcr_gne__c         = account.lastname;
                    this.dataChangeRequest.suffix_DCR_gne__c            = account.suffix_vod__c != null? account.suffix_vod__c : account.suffix_Gne__c;
                    this.dataChangeRequest.new_value_2_Gne__c           = account.middle_vod__c;
                    this.dataChangeRequest.professional_type_dcr_gne__c = account.professional_type_gne__c;
                    this.dataChangeRequest.account_type_dcr_gne__c      = account.account_type_gne__c;
                    this.dataChangeRequest.credentials_dcr_gne__c       = account.credentials_gne__c;
                    this.dataChangeRequest.specialties_hcp_dcr_gne__c   = this.isCanadaUser ? account.Specialties_can_gne__c : account.specialties_gne__c;
                } else {
                    this.dataChangeRequest.New_Organization_Name_gne__c = account.name;
                    this.dataChangeRequest.account_type_dcr_gne__c      = account.account_type_gne__c;
                    this.dataChangeRequest.specialties_hco_dcr_gne__c   = account.group_specialty_1_vod__c;
                }
            } else if (this.isAddressRequest) {
                Address_vod__c address = iPhone_DAO.getAddressById(addressId);
                this.dataChangeRequest.current_address_gne__c = address.Id;
                this.dataChangeRequest.address_line_1_gne__c  = address.name;
                this.dataChangeRequest.city_gne__c            = address.city_vod__c;
                this.dataChangeRequest.state_gne__c           = address.state_vod__c;
                this.dataChangeRequest.zip_gne__c             = address.zip_vod__c;
                this.dataChangeRequest.province_can_gne__c    = address.province_can_gne__c;
                this.dataChangeRequest.postal_Code_can_gne__c = address.postal_Code_can_gne__c;
                this.dataChangeRequest.address_line_2_gne__c  = address.address_line_2_vod__c;
                this.dataChangeRequest.address_line_3_gne__c  = address.address_line_3_gne__c;
                this.dataChangeRequest.address_line_4_gne__c  = address.address_line_4_gne__c;
            }
        }

        private void buildDCRforAccountInfoUpdateHCPRequest() {
            setDCRFieldStringValue('First_Name_DCR_gne__c', attributesKey.HCP_UPDATE_INFO_FIRST_NAME);
            setDCRFieldStringValue('New_Value_2_gne__c', attributesKey.HCP_UPDATE_INFO_MIDDLE_NAME);
            setDCRFieldStringValue('Last_Name_DCR_gne__c', attributesKey.HCP_UPDATE_INFO_LAST_NAME);
            if(this.isCanadaUser) {
                setDCRFieldStringValue('Account_Type_DCR_gne__c', attributesKey.HCP_UPDATE_INFO_ACCOUNT_TYPE);
                setDCRFieldBooleanValue('Verify_Gender_can_gne__c', attributesKey.HCP_UPDATE_INFO_VERIFY_GENDER);
            } else {
                setDCRFieldStringValue('Suffix_DCR_gne__c', attributesKey.HCP_UPDATE_INFO_SUFFIX);
                setDCRFieldStringValue('Professional_Type_DCR_gne__c', attributesKey.HCP_UPDATE_INFO_PROFESSIONAL_TYPE);

                setDCRFieldBooleanValue('verify_HCP_credentials_gne__c', attributesKey.HCP_UPDATE_INFO_VERIFY_CREDENTIALS);
                setDCRFieldBooleanValue('Verify_HCP_Specialties_gne__c', attributesKey.HCP_UPDATE_INFO_VERIFY_SPECIALTIES);
                if(this.dataChangeRequest.verify_HCP_credentials_gne__c){
	                setDCRFieldStringValue('credentials_dcr_gne__c', attributesKey.HCP_UPDATE_INFO_CREDENTIALS);
                }
                if(this.dataChangeRequest.Verify_HCP_Specialties_gne__c){
                	system.debug(attributesKey.HCP_UPDATE_INFO_SPECIALTIES);
                	setDCRFieldStringValue('specialties_hcp_dcr_gne__c', attributesKey.HCP_UPDATE_INFO_SPECIALTIES);
                }
            }
        }

        private void buildDCRforAccountInfoUpdateHCORequest() {
            setDCRFieldStringValue('New_Organization_Name_gne__c', attributesKey.HCO_UPDATE_INFO_ACCOUNT_NAME);
            setDCRFieldStringValue('Account_Group_gne__c', attributesKey.HCO_UPDATE_GROUP_VALUE);
            setDCRFieldStringValue('Account_Type_DCR_gne__c', attributesKey.HCO_UPDATE_INFO_ACCOUNT_TYPE);
            if(!this.isCanadaUser) {
                if(this.isAmsHCO) {
                    setDCRFieldBooleanValue('Verify_HCO_Specialties_gne__c', attributesKey.HCO_UPDATE_INFO_VERIFY_SPECIALTIES);
                } else {
                    setDCRFieldStringValue('Description_gne__c', attributesKey.HCO_UPDATE_INFO_DESCRIPTION);
                }
            }
        }

        private void buildDCRforLicenseInfoUpdateRequest() {
            setDCRFieldStringValue('License_State_gne__c', attributesKey.LICENSE_UPDATE_LICENSE_STATE);
            setDCRFieldStringValue('License_Number_gne__c', attributesKey.LICENSE_UPDATE_LICENSE_NUMBER);
            setDCRFieldStringValue('License_Designation_gne__c', attributesKey.LICENSE_UPDATE_PROF_DESIGNATION_FAMILY);
            setDCRFieldStringValue('Status_gne__c', attributesKey.LICENSE_UPDATE_STATUS);
            setDCRFieldDateValue('Adjusted_License_Expiration_Date_gne__c', attributesKey.LICENSE_UPDATE_ADJUST_LICENCE_EXPIR_DATE);
            setDCRFieldDateValue('License_Overwrite_Expiration_Date_gne__c', attributesKey.LICENSE_UPDATE_LICENCE_OVERWRITE_EXPIR_DATE);
            setDCRFieldBooleanValue('License_Sample_ability_gne__c', attributesKey.LICENSE_UPDATE_LICENCE_SAMPLEABILITY);
            setDCRFieldStringValue('Reason_dcr_gne__c', attributesKey.LICENSE_UPDATE_REASON_FOR_CHANGE_REQUEST);
            setDCRFieldStringValue('Description_gne__c', attributesKey.LICENSE_UPDATE_DESCRIPTION_FOR_CHANGE);
            setDCRFieldStringValue('New_Note_gne__c', attributesKey.LICENSE_UPDATE_NEW_NOTE);
        }

        private void buildDCRforAddressRemoveInactivateRequest() {
            //setDCRFieldStringValue('Reason_dcr_gne__c', attributesKey.ADDRESS_REMOVE_INACTIVATE_REASON);
            setDCRFieldStringValue('Remove_Inactive_Address_gne__c', attributesKey.ADDRESS_REMOVE_INACTIVATE_REASON);
        }

        private void buildDCRforAddressReactivateRequest() {
            //setDCRFieldStringValue('Remove_Inactive_Address_gne__c', attributesKey.ADDRESS_REACTIVATE_REASON);
            setDCRFieldStringValue('Reason_dcr_gne__c', attributesKey.ADDRESS_REACTIVATE_REASON);
        }

        private void buildDCRforAccountRemoveInactivateRequest() {
            setDCRFieldStringValue('Reason_dcr_gne__c', attributesKey.ACCOUNT_INACTIVATE_REASON);
        }

        private void buildDCRforAccountReactivateRequest() {
            setDCRFieldStringValue('Reason_dcr_gne__c', attributesKey.ACCOUNT_REACTIVATE_REASON);
        }

        private void buildDCRforAccountRemoveDuplicatesRequest() {
            setDCRFieldStringValue('Duplicate_Account_2_gne__c', attributesKey.ACCOUNT_REMOVE_DUPLICATE_2);
            setDCRFieldStringValue('Duplicate_Account_3_gne__c', attributesKey.ACCOUNT_REMOVE_DUPLICATE_3);
            setDCRFieldStringValue('Duplicate_Account_4_gne__c', attributesKey.ACCOUNT_REMOVE_DUPLICATE_4);
            setDCRFieldStringValue('Duplicate_Account_5_gne__c', attributesKey.ACCOUNT_REMOVE_DUPLICATE_5);
        }

        private void buildDCRforAddressRemoveDuplicatesRequest() {
            setDCRFieldStringValue('Duplicate_Address_2_gne__c', attributesKey.ADDRESS_REMOVE_DUPLICATE_2);
            setDCRFieldStringValue('Duplicate_Address_3_gne__c', attributesKey.ADDRESS_REMOVE_DUPLICATE_3);
        }

        private void buildDCRforAddressInfoUpdateRequest()  {
            setDCRFieldStringValue('Address_Line_1_gne__c', attributesKey.ADDRESS_UPDATE_STREET_NAME);
            setDCRFieldStringValue('Address_Line_2_gne__c', attributesKey.ADDRESS_SUITE_FLOOR_UNIT);
            setDCRFieldStringValue('City_gne__c', attributesKey.ADDRESS_UPDATE_CITY_NAME);
            if(this.isCanadaUser) {
                setDCRFieldStringValue('Province_can_gne__c', attributesKey.ADDRESS_UPDATE_PROVINCE);
                setDCRFieldStringValue('Postal_Code_can_gne__c', attributesKey.ADDRESS_UPDATE_POSTAL_CODE);
            } else {
                setDCRFieldStringValue('State_gne__c', attributesKey.ADDRESS_UPDATE_STATE_NAME);
                setDCRFieldStringValue('Zip_gne__c', attributesKey.ADDRESS_UPDATE_ZIP_CODE);
            }
        }

        private void buildDCRforUsLicensedPhysicianRequest() {
            setDCRFieldStringValue('License_State_gne__c', attributesKey.LICENSE_UPDATE_LICENSE_STATE);
            setDCRFieldStringValue('License_Number_gne__c', attributesKey.LICENSE_UPDATE_LICENSE_NUMBER);
            setDCRFieldStringValue('HCP_National_Provider_Id_gne__c', attributesKey.US_PHYSICIAN_NATIONAL_PROVIDER_ID);
        }

        // ### Helper methods ###

        private Map<String, String> getAttributes(List<DCRAttribute> requestAttributes) {
            Map<String, String> attributesMap = new Map<String, String>();
            for(DCRAttribute requestAttribute: requestAttributes) {
                attributesMap.put(requestAttribute.name, requestAttribute.value);
            }
            return attributesMap;
        }

        private void setDCRFieldStringValue(String dcrFieldName, String attributesKey) {
            String value = this.attributes.get(attributesKey);
            if(value != null) {
                system.debug('DCR, key:' + attributesKey + ', field: ' + dcrFieldName + ', value: ' + value);
                this.dataChangeRequest.put(dcrFieldName, value);
            }
        }

        private void setDCRFieldDateValue(String dcrFieldName, String attributesKey) {
            String value = this.attributes.get(attributesKey);
            if(value != null) {
                system.debug('DCR, key:' + attributesKey + ', field: ' + dcrFieldName + ', value: ' + value);
                Date d = iPhone_StringUtil.hasValue(value) ? Date.valueof(value) : null;
                this.dataChangeRequest.put(dcrFieldName, d);
            }
        }

        private void setDCRFieldBooleanValue(String dcrFieldName, String attributesKey) {
            String value = this.attributes.get(attributesKey);
            if(value != null) {
                system.debug('DCR, key:' + attributesKey + ', field: ' + dcrFieldName + ', value: ' + value);
                this.dataChangeRequest.put(dcrFieldName, Boolean.valueOf(value));
            }
        }

        private Boolean isAmsHCO(Account account) {
            return  (account.IsPersonAccount == false) &&
                    (account.stewardship_system_name_gne__c != null) &&
                    (account.stewardship_system_name_gne__c.equalsIgnoreCase('ams') == true);
        }

        private String getRecordTypeId() {
            String recordTypeDeveloperName = getRecordTypeDeveloperName();
            system.debug('RecordType DeveloperName: ' + recordTypeDeveloperName);

            Id recordTypeId = iPhone_DAO.getRecordTypeIdByDeveloperName(recordTypeDeveloperName, 'change_request_gne__c');
            system.debug('RecordTypeId: ' + recordTypeId);
            return recordTypeId;
        }

        private String getRecordTypeDeveloperName() {
            if(this.isPersonAccount) {
                if(this.isAccountInfoUpdateRequest){
                    return 'HCP_Change_HCP_Info';
                }
                if(this.isAccountRemoveDuplicatesRequest){
                    return 'HCP_Remove_Duplicate';
                }
                if(this.isAccountRemoveInactivateRequest){
                    return 'HCP_Remove_Inactivate_HCP';
                }
                if(this.isAddressInfoUpdateRequest){
                    return 'HCP_Existing_Address_Typo_Missing_Info';
                }
                if(this.isAddressRemoveInactivateRequest){
                    return 'HCP_Remove_Inactivate_Address';
                }
                if(this.isLicenseInfoUpdateRequest){
                    return 'License_Sampleability_Info_gne';
                }
                if(this.isLicenseInfoUpdateRequest){
                    return 'License_Sampleability_Info_gne';
                }
                if(this.isAccountReactivateRequest){
                    return 'HCP_Reactivate_HCP';
                }
                if(this.isAddressReactivateRequest){
                    return 'HCP_Reactivate_Address';
                }
                if(this.isAddressRemoveDuplicatesRequest){
                    return 'Duplicate_Address';
                }
                if(this.isUsLicensedPhysicianRequest){
                    return 'US_Licensed_Physician';
                }
            } else {
                if(this.isAccountInfoUpdateRequest){
                    return 'HCO_Change_Organization_Info';
                }
                if(this.isAccountRemoveDuplicatesRequest){
                    return 'HCO_Remove_Duplicate_Organization';
                }
                if(this.isAccountRemoveInactivateRequest){
                    return 'HCO_Remove_Inactivate_Organization';
                }
                if(this.isAddressInfoUpdateRequest){
                	 // Ams & NonAms
                    return 'HCO_Change_Address';
                }
                if(this.isAddressRemoveInactivateRequest){
                    return 'HCP_Remove_Inactivate_Address';
                }
                if(this.isLicenseInfoUpdateRequest){
                    return 'License_Sampleability_Info_gne';
                }
                if(this.isUsLicensedPhysicianRequest){
                    return 'US_Licensed_Physician';
                }
            }
            system.debug('RecordType DeveloperName not found !');
            return null;
        }

        private Boolean getIsCanadaUser(String profileId) {
            Profile profile = iPhone_DAO.getProfileById(profileId);
            String profileName = profile.Name;
            if (profileName != null && profileName.toUpperCase().contains('CANADA')) {
                return true;
            } else {
                return false;
            }
        }
    }

    global class DCRAttribute {
        public String name;
        public String value;
    }

    public class DCRAttributeKeys {
        // HCP CHANGE INFO:
        public final String HCP_UPDATE_INFO_FIRST_NAME          = 'pfn';
        public final String HCP_UPDATE_INFO_MIDDLE_NAME         = 'pmn';
        public final String HCP_UPDATE_INFO_LAST_NAME           = 'pln';
        public final String HCP_UPDATE_INFO_ACCOUNT_TYPE        = 'pat';    // CanadaOnly
        public final String HCP_UPDATE_INFO_VERIFY_GENDER       = 'pvg';    // CanadaOnly

        public final String HCP_UPDATE_INFO_SUFFIX              = 'psx';    // NonCanada
        public final String HCP_UPDATE_INFO_PROFESSIONAL_TYPE   = 'ppt';    // NonCanada
        public final String HCP_UPDATE_INFO_VERIFY_CREDENTIALS  = 'pvc';    // NonCanada
        public final String HCP_UPDATE_INFO_VERIFY_SPECIALTIES  = 'pvs';    // NonCanada

        public final String HCP_UPDATE_INFO_CREDENTIALS  = 'pcr';    // NonCanada
        public final String HCP_UPDATE_INFO_SPECIALTIES  = 'psp';    // NonCanada

        // HCO CHANGE INFO:
        public final String HCO_UPDATE_INFO_ACCOUNT_NAME        = 'oan';
        public final String HCO_UPDATE_INFO_ACCOUNT_TYPE        = 'oat';
        public final String HCO_UPDATE_INFO_VERIFY_SPECIALTIES  = 'ovs';    // NonCanada
        public final String HCO_UPDATE_INFO_DESCRIPTION         = 'od';     // NonCanada
        public final String HCO_UPDATE_GROUP_VALUE              = 'gv';

        // HCP & HCO INACTIVATE:
        public final String ACCOUNT_INACTIVATE_REASON           = 'air';

        // HCP REACTIVATE:
        public final String ACCOUNT_REACTIVATE_REASON           = 'arr';

        // HCP & HCO DEDUPLICATE
        public final String ACCOUNT_REMOVE_DUPLICATE_2          = 'da2';
        public final String ACCOUNT_REMOVE_DUPLICATE_3          = 'da3';
        public final String ACCOUNT_REMOVE_DUPLICATE_4          = 'da4';
        public final String ACCOUNT_REMOVE_DUPLICATE_5          = 'da5';

        // ADDRESS DEDUPLICATE
        public final String ADDRESS_REMOVE_DUPLICATE_2          = 'dad2';
        public final String ADDRESS_REMOVE_DUPLICATE_3          = 'dad3';

        // CHANGE ADDRESS: AMS_HCO & NON_AMS_HCO & HCP:
        public final String ADDRESS_UPDATE_STREET_NAME          = 'asn';
        public final String ADDRESS_SUITE_FLOOR_UNIT            = 'asf';
        public final String ADDRESS_UPDATE_CITY_NAME            = 'acn';
        public final String ADDRESS_UPDATE_STATE_NAME           = 'ast';    // NonCanada
        public final String ADDRESS_UPDATE_ZIP_CODE             = 'azc';    // NonCanada
        public final String ADDRESS_UPDATE_PROVINCE             = 'ap';     // CanadaOnly
        public final String ADDRESS_UPDATE_POSTAL_CODE          = 'apc';    // CanadaOnly

        // REMOVE/INACTIVATE ADDRESS
        public final String ADDRESS_REMOVE_INACTIVATE_REASON    = 'arir';

        // REACTIVATE ADDRESS
        public final String ADDRESS_REACTIVATE_REASON    = 'arrr';

        // UPDATE_LICENSE INFORMATION
        public final String LICENSE_UPDATE_LICENSE_STATE                = 'lse';
        public final String LICENSE_UPDATE_LICENSE_NUMBER               = 'ln';
        public final String LICENSE_UPDATE_PROF_DESIGNATION_FAMILY      = 'lpdf';
        public final String LICENSE_UPDATE_STATUS                       = 'lss';
        public final String LICENSE_UPDATE_ADJUST_LICENCE_EXPIR_DATE    = 'laed';
        public final String LICENSE_UPDATE_LICENCE_OVERWRITE_EXPIR_DATE = 'loed';
        public final String LICENSE_UPDATE_LICENCE_SAMPLEABILITY        = 'lsa';
        public final String LICENSE_UPDATE_REASON_FOR_CHANGE_REQUEST    = 'lrcr';
        public final String LICENSE_UPDATE_DESCRIPTION_FOR_CHANGE       = 'ldc';
        public final String LICENSE_UPDATE_NEW_NOTE                     = 'lnn';

        public final String US_PHYSICIAN_NATIONAL_PROVIDER_ID= 'npi';    // CanadaOnly
    }
}