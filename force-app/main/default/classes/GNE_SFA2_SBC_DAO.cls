public abstract class GNE_SFA2_SBC_DAO {

    public static final Integer SERVICE_DEFAULT_PAGE_SIZE = 25;

    public static List<SFASearchStrings_gne__c> getLastSearchHistoryRecord(String accMode, Id userId) {
        return [
                SELECT
                        Id, Name, AccountType_gne__c, FRM_Account_Type_gne__c, Mode_gne__c, FirstName_gne__c, LastName_gne__c, OrgName_gne__c, Type_gne__c,
                        Street_gne__c, City_gne__c, State_gne__c, Zip_gne__c,
                        License_Number_gne__c, License_State_gne__c, MDMID_gne__c, LastModifiedDate
                FROM SFASearchStrings_gne__c
                WHERE OwnerId = :userId
                AND AccountType_gne__c = :accMode
                LIMIT 1
        ];
    }

    public static Id getRecordTypeId(String sObjectType, String devName) {
        Map<String, Id> rtIdMap = getRecordTypeIdMap(sObjectType, new Set<String>{
                devName
        });
        return rtIdMap.isEmpty() ? null : rtIdMap.get(devName.toUpperCase());
    }

    public static Map<String, Id> getRecordTypeIdMap(String sObjectType, Set<String> devNames) {
        Map<String, Id> result = new Map<String, Id>();
        List<RecordType> rts = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = :sObjectType AND DeveloperName = :devNames];

        for (RecordType rt : rts) {
            result.put(rt.DeveloperName.toUpperCase(), rt.Id);
        }

        return result;
    }

    public static List<RecordType> getRecordTypesById(Set<Id> rtIds) {
        return [
                SELECT Id, Name, IsPersonType
                FROM RecordType
                WHERE Id IN :rtIds
        ];
    }

    public static List<Territory2> getUserTerritories(Set<Id> userIds) {
        return [
                SELECT Id, Name, Salesforce_Code_gne__c
                FROM Territory2
                WHERE Id IN (SELECT Territory2Id FROM UserTerritory2Association WHERE UserId IN :userIds)
                AND External_Id_gne__c LIKE 'GNE-US;%'
                ORDER BY Name
        ];
    }

    public static List<Territory2> getTerritoriesByParentIds(Set<Id> parentIds) {
        return [
                SELECT ParentTerritory2Id
                FROM Territory2
                WHERE ParentTerritory2Id IN :parentIds
        ];
    }

    public static List<Group> getTerritoryGroups(Set<Id> terrIds) {
        return [
                SELECT Id, RelatedId
                FROM Group
                WHERE RelatedId IN :terrIds
                AND Type = 'Territory'
        ];
    }

    public static List<Account> getAccountBySapId(String sapId) {
        return [
                SELECT Id, Name
                FROM Account
                WHERE SAP_ID_gne__c = :sapId
                LIMIT 1
        ];
    }

    public static List<Account> getAccountByMdmId(String mdmId, Set<String> mdmAddressIds, Set<String> addressExtIds, Set<Id> terrGroupIds, Set<String> terrNames) {
        return [
                SELECT Id, iPhone_Request_Id_gne__c, Account_Type_gne__c, IsPersonAccount, (
                        SELECT Id, MDM_Address_ID_gne__c, iPhone_Request_Id_gne__c, External_ID_vod__c
                        FROM Address_vod__r
                        WHERE (MDM_Address_ID_gne__c IN :mdmAddressIds) OR (External_ID_vod__c IN :addressExtIds)
                        ORDER BY CreatedDate ASC
                ), (
                        SELECT AccountId, UserOrGroupId
                        FROM Shares
                        WHERE UserOrGroupId IN :terrGroupIds
                ), (
                        SELECT Account_vod__c, Territory_vod__c, iPhone_Request_Id_gne__c
                        FROM TSF_vod__r
                        WHERE Territory_vod__c IN :terrNames
                )
                FROM Account
                WHERE MDMID_gne__c = :mdmId
                LIMIT 1
        ];
    }

    public static List<User> getUserByExternalId(String extId) {
        return [
                SELECT Id
                FROM User
                WHERE External_ID_gne__c = :extId
                LIMIT 1
        ];
    }

    public static List<Account> getAccountsByAddressIds(Set<Id> addressIds) {
        return [
                SELECT IsPersonAccount, Name, MDMID_gne__c, (
                        SELECT MDM_Address_ID_gne__c
                        FROM Address_vod__r
                        WHERE Inactive_vod__c = FALSE
                        AND MDM_Address_ID_gne__c <> NULL
                )
                FROM Account
                WHERE Id IN (SELECT Account_vod__c FROM Address_vod__c WHERE Id IN :addressIds)
        ];
    }

    public static List<Account> getAccountsByIds(Set<Id> accountIds) {
        return [
                SELECT IsPersonAccount, Name, MDMID_gne__c, (
                        SELECT MDM_Address_ID_gne__c
                        FROM Address_vod__r
                        WHERE Inactive_vod__c = FALSE
                        AND MDM_Address_ID_gne__c <> NULL
                )
                FROM Account
                WHERE Id IN :accountIds
        ];
    }

    public DataWrapper searchAccounts(String accType, String searchMode, Map<String, String> searchParams) {
        return searchAccounts(accType, searchMode, searchParams, null, null);
    }

    public DataWrapper searchAccounts(String accType, String searchMode, Map<String, String> searchParams, Set<String> teamCodes) {
        return searchAccounts(accType, searchMode, searchParams, null, teamCodes);
    }

    public DataWrapper searchAccounts(String accType, String searchMode, PaginationDataWrapper paginationData) {
        return searchAccounts(accType, searchMode, null, paginationData, null);
    }

    public DataWrapper searchAccounts(String accType, String searchMode, PaginationDataWrapper paginationData, Set<String> teamCodes) {
        return searchAccounts(accType, searchMode, null, paginationData, teamCodes);
    }

    public DataWrapper searchAccounts(String accType, String searchMode, Map<String, String> searchParams, PaginationDataWrapper paginationData, Set<String> teamCodes) {
        return searchAccounts(accType, searchMode, searchParams, paginationData, teamCodes, getServicePageSize());
    }

    public abstract DataWrapper searchAccounts(String accType, String searchMode, Map<String, String> searchParams, PaginationDataWrapper paginationData, Set<String> teamCodes, Integer pageSize);

    protected virtual Integer getServicePageSize() {
        return SERVICE_DEFAULT_PAGE_SIZE;
    }

    public class PaginationRequest {
        private String searchTokenID;
        private Integer recordStartNumber;
        private Integer recordsNumber;

        public PaginationRequest(PaginationDataWrapper paginationData) {
            this(paginationData.tokenId, paginationData.endPageIdx);
            this.recordsNumber = paginationData.pageSize;
        }

        public PaginationRequest(String searchTokenID, Integer recordStartNumber) {
            this.searchTokenID = searchTokenID;
            this.recordStartNumber = recordStartNumber;
        }

        public Map<String, Object> toJSON() {
            return new Map<String, Object>{
                    'searchTokenID' => searchTokenID,
                    'recordStartNumber' => String.valueOf(recordStartNumber)
            };
        }

        public String getSearchTokenID() {
            return searchTokenID;
        }

        public Integer getRecordStartNumber() {
            return recordStartNumber;
        }

        public Integer getRecordsNumber() {
            return recordsNumber;
        }
    }

    public class ServiceResponse {
        private ErrorData Error;
        private SearchHCPResponse searchHCPResponse;
        private SearchHCOResponse searchHCOResponse;

        public ServiceResponse(ErrorData error, SearchHCPResponse searchHCPResponse, SearchHCOResponse searchHCOResponse) {
            error = error;
            this.searchHCPResponse = searchHCPResponse;
            this.searchHCOResponse = searchHCOResponse;
        }

        public ErrorData getError() {
            return Error;
        }

        public SearchHCPResponse getSearchHCPResponse() {
            return searchHCPResponse;
        }

        public SearchHCOResponse getSearchHCOResponse() {
            return searchHCOResponse;
        }
    }

    public class SearchHCPResponse {
        private PrescriberDetails prescriberDetails;
        public PrescriberDetails getPrescriberDetails() {
            return prescriberDetails;
        }
    }

    public class SearchHCOResponse {
        private OrganizationDetails organizationDetails;

        public OrganizationDetails getOrganizationDetails() {
            return organizationDetails;
        }
    }

    public class PrescriberDetails extends PartyDetails {
        private Prescriber[] prescriber;

        public Prescriber[] getPrescribers() {
            return prescriber;
        }
    }

    public class OrganizationDetails extends PartyDetails {
        private Organization[] organization;

        public Organization[] getOrganizations() {
            return organization;
        }
    }

    private virtual class PartyDetails {
        private String message;
        private PaginationResponse paginationResponse;

        public PaginationResponse getPaginationResponse() {
            return paginationResponse;
        }

        public String getMessage() {
            return message;
        }
    }

    public class Organization extends Party {
        private String dbaName;
        private String organizationName;
        private String insId;
        private String phone;
        private String fax;
        private String website;
        private String facility;
        private AccountType2[] accountType2;
        private Address hcoAddress;

        public Organization(String mdmId, String partyId, AltrenateName alternateName, String status, String organizationName, String phone, String fax, String website, String facility, Address hcoAddress) {
            super(mdmId, partyId, alternateName, null, status);
            this.organizationName = organizationName;
            this.hcoAddress = hcoAddress;
            this.phone = phone;
            this.fax = fax;
            this.website = website;
            this.facility = facility;
        }

        public void setAccountType(AccountType2[] accountTypes) {
            this.accountType2 = accountTypes;
        }

        public void setInsId(String insId) {
            this.insId = insId;
        }
    }

    public class Prescriber extends Party {
        private String firstName;
        private String middleName;
        private String LastName;
        private ProfessionalType professionalType;
        private PartyCredential partyCredential;
        private PartySpecialty partySpecialty;
        private License license;
        private Address hcpAddress;

        public Prescriber(String mdmId, String partyId, AltrenateName alternateName, String status, String firstName, String middleName, String lastName,
                ProfessionalType professionalType, PartyCredential partyCredential, PartySpecialty partySpecialty, License license, Address hcpAddress) {
            super(mdmId, partyId, alternateName, null, status);
            this.firstName = firstName;
            this.middleName = middleName;
            this.LastName = lastName;
            this.professionalType = professionalType;
            this.partyCredential = partyCredential;
            this.partySpecialty = partySpecialty;
            this.license = license;
            this.hcpAddress = hcpAddress;
        }
    }

    private virtual class Party {
        private String mdmId;
        private String partyId;
        private AltrenateName altrenateName;
        private AccountType accountType;
        private String status;

        public Party(String mdmId, String partyId, AltrenateName altrenateName, AccountType accountType, String status) {
            this.mdmId = mdmId;
            this.partyId = partyId;
            this.altrenateName = altrenateName;
            this.accountType = accountType;
            this.status = status;
        }
    }

    public class PaginationResponse {
        private String hasMoreRecords;
        private String searchTokenID;
        private String totalRecords;
        private String recordStartNumber;
        private String previousStartNumber;
        private String recordsFetched;

        public PaginationResponse() {
        }

        public PaginationResponse(String hasMoreRecords, String searchTokenID, String totalRecords, String recordStartNumber, String previousStartNumber, String recordsFetched) {
            this.hasMoreRecords = hasMoreRecords;
            this.searchTokenID = searchTokenID;
            this.totalRecords = totalRecords;
            this.recordStartNumber = recordStartNumber;
            this.previousStartNumber = previousStartNumber;
            this.recordsFetched = recordsFetched;
        }
    }

    public class ProfessionalType {
        private String[] value;
        public ProfessionalType() {
        }
        public ProfessionalType(String[] values) {
            this.value = values;
        }
    }

    public class PartyCredential {
        private String[] value;
        public PartyCredential() {
        }
        public PartyCredential(String[] values) {
            this.value = values;
        }
    }

    public class AltrenateName {
        private String[] value;
        public AltrenateName() {
        }
        public AltrenateName(String[] values) {
            this.value = values;
        }
    }

    public class AccountType {
        private String[] value;
    }

    public class AccountType2 {
        private String value;
        private String code;

        public AccountType2() {

        }
        public AccountType2(String value, String code) {
            this.value = value;
            this.code = code;
        }
    }

    public class Address {
        private AddressData[] address;

        public Address() {

        }
        public Address(AddressData[] addressData) {
            this.address = addressData;
        }
    }

    public class PartySpecialty {
        private String[] value;
        public PartySpecialty() {
        }
        public PartySpecialty(String[] values) {
            this.value = values;
        }
    }

    public class License {
        private LicenseData[] licenseData;

        public License() {
        }

        public License(LicenseData[] licenseData) {
            this.licenseData = licenseData;
        }
    }

    public class AddressData {
        private String mdmAddressId;
        private String partyLocId;
        private String streetAddress;
        private String streetAddress2;
        private String unitType;
        private String unitValue;
        private String cityName;
        private String stateCode;
        private String zipCode;
        private String isDefault;
        private String latitude;
        private String longitude;
        private String status;
        private String phoneNumber;

        public AddressData(String mdmAddressId, String partyLocId, String streetAddress, String unitType, String unitValue, String cityName, String stateCode,
                String zipCode, String isDefault, String latitude, String longitude, String status) {
            this.mdmAddressId = mdmAddressId;
            this.partyLocId = partyLocId;
            this.streetAddress = streetAddress;
            this.unitType = unitType;
            this.unitValue = unitValue;
            this.cityName = cityName;
            this.stateCode = stateCode;
            this.zipCode = zipCode;
            this.isDefault = isDefault;
            this.latitude = latitude;
            this.longitude = longitude;
            this.status = status;
        }

        public AddressData(String mdmAddressId, String streetAddress, String streetAddress2, String unitType, String unitValue, String cityName, String stateCode, String zipCode,
                String isDefault, String latitude, String longitude, String status, String phoneNumber) {
            this.mdmAddressId = mdmAddressId;
            this.streetAddress = streetAddress;
            this.streetAddress2 = streetAddress2;
            this.unitType = unitType;
            this.unitValue = unitValue;
            this.cityName = cityName;
            this.stateCode = stateCode;
            this.zipCode = zipCode;
            this.isDefault = isDefault;
            this.latitude = latitude;
            this.longitude = longitude;
            this.status = status;
            this.phoneNumber = phoneNumber;
            this.partyLocId = String.isNotBlank(mdmAddressId) ? mdmAddressId : '';
        }

    }

    public class LicenseData {
        private String issuedState;
        private String licenseNumber;
        private String adjExpirationDate;
        private String sampleability;
        private String designation;

        public LicenseData(String issuedState, String licenseNumber, String adjExpirationDate, String sampleability, String designation) {
            this.issuedState = issuedState;
            this.licenseNumber = licenseNumber;
            this.adjExpirationDate = adjExpirationDate;
            this.sampleability = sampleability;
            this.designation = designation;
        }
    }

    public class ErrorData {
        private String code;
        private String message;
        public String getCode() {
            return code;
        }
        public String getMessage() {
            return message;
        }
    }

    public class DataWrapper {
        public List<AccountWrapper> rows;
        public PaginationDataWrapper paginationData;

        public DataWrapper(List<AccountWrapper> rows, PaginationDataWrapper paginationData) {
            this.rows = rows;
            this.paginationData = paginationData;
        }
    }

    public class AccountWrapper {
        public String mdmId;
        public String partyId;
        public String name;
        public String firstName;
        public String lastName;
        public String middleName;
        public Boolean isPersonAccount;
        public String status;
        public String insId;
        public String fax;
        public String phone;
        public String website;
        public String facility;
        public List<AccountTypeWrapper> accountTypes;
        public List<String> profTypes;
        public List<String> credentials;
        public List<String> alternateNames;
        public List<AddressWrapper> addresses;
        public List<LicenseWrapper> licenses;
        public List<String> specialties;

        public AccountWrapper(Prescriber mdmAcc) {
            this(
                    mdmAcc.mdmId, mdmAcc.partyId, null, mdmAcc.firstName, mdmAcc.LastName, mdmAcc.middleName, true, mdmAcc.status,
                    mdmAcc.accountType != null ? mdmAcc.accountType.value : null,
                    mdmAcc.professionalType != null ? mdmAcc.professionalType.value : null,
                    mdmAcc.partyCredential != null ? mdmAcc.partyCredential.value : null,
                    mdmAcc.altrenateName != null ? mdmAcc.altrenateName.value : null,
                    mdmAcc.hcpAddress != null ? mdmAcc.hcpAddress.address : null,
                    mdmAcc.partySpecialty != null ? mdmAcc.partySpecialty.value : null
            );

            setLicenses(mdmAcc.license != null ? mdmAcc.license.licenseData : null);
        }

        public AccountWrapper(Organization org) {
            this(
                    org.mdmId, org.partyId, org.organizationName, null, null, null, false, org.status,
                    org.accountType != null ? org.accountType.value : null,
                    null, null,
                    org.altrenateName != null ? org.altrenateName.value : null,
                    org.hcoAddress != null ? org.hcoAddress.address : null
            );

            if (org.accountType2 != null) {
                this.accountTypes = new List<AccountTypeWrapper>();

                for (AccountType2 at2 : org.accountType2) {
                    this.accountTypes.add(new AccountTypeWrapper(at2));
                }
            }
            this.insId = org.insId;
            this.phone = org.phone;
            this.website = org.website;
            this.fax = org.fax;
            this.facility = org.facility;
        }

        public AccountWrapper(String mdmId, String partyId, String name, String firstName, String lastName, String middleName, Boolean isPersonAccount, String status,
                List<String> accountTypes, List<String> profTypes, List<String> credentials, List<String> alternateNames, List<AddressData> addresses) {
            this.mdmId = mdmId;
            this.partyId = partyId;
            this.name = name;
            this.firstName = firstName;
            this.lastName = lastName;
            this.middleName = middleName;
            this.isPersonAccount = isPersonAccount;
            this.status = getAccountStatus(status);
            this.profTypes = profTypes != null && !profTypes.isEmpty() ? profTypes : new List<String>{
                    null
            };
            this.credentials = credentials != null ? credentials : new List<String>();
            this.alternateNames = alternateNames != null ? alternateNames : new List<String>();
            this.accountTypes = new List<AccountTypeWrapper>();

            for (String atValue : accountTypes != null ? accountTypes : new List<String>()) {
                this.accountTypes.add(new AccountTypeWrapper(atValue));
            }

            setAddresses(addresses);
        }

        public AccountWrapper(String mdmId, String partyId, String name, String firstName, String lastName, String middleName, Boolean isPersonAccount, String status,
                List<String> accountTypes, List<String> profTypes, List<String> credentials, List<String> alternateNames, List<AddressData> addresses, List<String> specialties) {
            this.mdmId = mdmId;
            this.partyId = partyId;
            this.name = name;
            this.firstName = firstName;
            this.lastName = lastName;
            this.middleName = middleName;
            this.isPersonAccount = isPersonAccount;
            this.status = getAccountStatus(status);
            this.profTypes = profTypes != null && !profTypes.isEmpty() ? profTypes : new List<String>{
                    null
            };
            this.credentials = credentials != null ? credentials : new List<String>();
            this.alternateNames = alternateNames != null ? alternateNames : new List<String>();
            this.accountTypes = new List<AccountTypeWrapper>();

            for (String atValue : accountTypes != null ? accountTypes : new List<String>()) {
                this.accountTypes.add(new AccountTypeWrapper(atValue));
            }

            setAddresses(addresses);
            this.specialties = specialties;
        }

        private void setAddresses(List<AddressData> addresses) {
            this.addresses = new List<AddressWrapper>();

            if (addresses != null) {
                for (AddressData addr : addresses) {
                    AddressWrapper addrWrapper = new AddressWrapper(addr);

                    if (addrWrapper.isDefault && !this.addresses.isEmpty()) {
                        this.addresses.add(0, addrWrapper);
                    } else {
                        this.addresses.add(addrWrapper);
                    }
                }
            }
        }

        private void setLicenses(List<LicenseData> licenses) {
            this.licenses = new List<LicenseWrapper>();

            if (licenses != null) {
                for (LicenseData license : licenses) {
                    LicenseWrapper licenseWrapper = new LicenseWrapper(license);
                    this.licenses.add(licenseWrapper);
                }
            }
        }

        private String getAccountStatus(String status) {
            String accountStatus = 'Indeterminate';
            if(String.isBlank(status) || 'A'.equalsIgnoreCase(status) || 'Active'.equalsIgnoreCase(status)) {
                accountStatus = 'Active';
            } else if('D'.equalsIgnoreCase(status)) {
                accountStatus = 'Dead';
            } else if('R'.equalsIgnoreCase(status)) {
                accountStatus = 'Retired';
            } else if('I'.equalsIgnoreCase(status)) {
                accountStatus = 'Indeterminate';
            }
            return accountStatus;
        }
    }

    public class AddressWrapper {
        public String mdmAddressId;
        public String partyLocId;
        public String streetAddress;
        public String streetAddress2;
        public String suite;
        public String cityName;
        public String stateCode;
        public String zipCode;
        public String phoneNumber;
        public Boolean isDefault;
        public Double latitude;
        public Double longitude;
        public String status;

        private AddressWrapper(AddressData address) {
            this.mdmAddressId = address.mdmAddressId != null ? address.mdmAddressId.trim() : null;
            this.partyLocId = address.partyLocId;
            this.streetAddress = address.streetAddress;
            this.streetAddress2 = address.streetAddress2;
            this.suite = String.isNotBlank(address.unitValue) ? (String.isNotBlank(address.unitType) ? address.unitType + ' ' : '') + address.unitValue : null;
            this.cityName = address.cityName;
            this.stateCode = address.stateCode;
            this.zipCode = address.zipCode;
            this.phoneNumber = address.phoneNumber;
            this.isDefault = String.isNotBlank(address.isDefault) && new Set<String>{
                    'Y', '1', 'TRUE'
            } .contains(address.isDefault.toUpperCase());
            this.latitude = String.isNotBlank(address.latitude) ? Double.valueOf(address.latitude) : null;
            this.longitude = String.isNotBlank(address.longitude) ? Double.valueOf(address.longitude) : null;
            this.status = (String.isBlank(address.status) || address.status == 'A' || address.status == 'Active') ? 'Active' : 'Inactive';
        }

        public String getFullAddressName() {
            String result = '';

            if (String.isNotBlank(this.suite)) {
                result += this.suite;
            }

            if (String.isNotBlank(this.streetAddress)) {
                result += String.isNotBlank(result) ? (' ' + this.streetAddress) : this.streetAddress;
            }

            if (String.isNotBlank(this.cityName)) {
                result += String.isNotBlank(result) ? (' ' + this.cityName) : this.cityName;
            }

            if (String.isNotBlank(this.stateCode)) {
                result += String.isNotBlank(result) ? (' ' + this.stateCode) : this.stateCode;
            }

            if (String.isNotBlank(this.zipCode)) {
                result += String.isNotBlank(result) ? (' ' + this.zipCode) : this.zipCode;
            }

            return result;
        }
    }

    public class LicenseWrapper {
        public String issuedState;
        public String licenseNumber;
        public Date expirationDate;
        public Boolean sampleability;
        public String designation;

        private LicenseWrapper(LicenseData license) {
            this.issuedState = license.issuedState;
            this.licenseNumber = license.licenseNumber;
            this.expirationDate = String.isNotBlank(license.adjExpirationDate) ? Date.valueOf(license.adjExpirationDate) : null;
            this.sampleability = String.isNotBlank(license.sampleability) && new Set<String>{
                    'Y', '1', 'TRUE'
            } .contains(license.sampleability.toUpperCase());
            this.designation = String.isNotBlank(license.designation) ? license.designation : null;
        }
    }

    public class AccountTypeWrapper {
        public String name;
        public String code;

        public AccountTypeWrapper(String value) {
            this.name = value;
        }

        public AccountTypeWrapper(AccountType2 at2) {
            this(at2.value);
            this.code = at2.code;
        }
    }

    public class PaginationDataWrapper {
        public String tokenId;
        public Integer size;
        public Integer totalSize;
        public Integer startPageIdx;
        public Integer endPageIdx;
        public Integer pageSize;
        public Integer pageNumber;
        public Integer pageTotalCount;
        public Boolean queryMore;

        public PaginationDataWrapper() {
            this(null, null);
        }

        public PaginationDataWrapper(PaginationResponse pResponse, Integer pageSize) {
            if (pResponse != null) {
                this.tokenId = String.isNotBlank(pResponse.searchTokenID) ? pResponse.searchTokenID : null;
                this.size = String.isNotBlank(pResponse.recordsFetched) ? Integer.valueOf(pResponse.recordsFetched) : null;
                this.totalSize = String.isNotBlank(pResponse.totalRecords) ? Integer.valueOf(pResponse.totalRecords) : null;
                this.startPageIdx = String.isNotBlank(pResponse.previousStartNumber) ? Integer.valueOf(pResponse.previousStartNumber) : null;
                this.endPageIdx = String.isNotBlank(pResponse.recordStartNumber) ? Integer.valueOf(pResponse.recordStartNumber) : null;
                this.pageSize = pageSize;
                this.pageNumber = this.endPageIdx != null ? (this.endPageIdx / this.pageSize) : null;
                this.pageTotalCount = this.totalSize != null ? this.totalSize / this.pageSize + (Math.mod(this.totalSize, this.pageSize) == 0 ? 0 : 1) : null;
                this.queryMore = String.isNotBlank(pResponse.hasMoreRecords) && new Set<String>{
                        '1', 'Y', 'TRUE'
                } .contains(pResponse.hasMoreRecords.toUpperCase());
            }
        }
    }

    public class ServiceException extends Exception {
        public String status;
        public Integer statusCode;
        public String restMethod;

        public ServiceException(String status, Integer statusCode, String restMethod) {
            this(String.format('Service Error [Status = {0}, Code = {1}, Method = {2}]', new String[]{
                    status, String.valueOf(statusCode), restMethod
            }));
            this.status = status;
            this.statusCode = statusCode;
            this.restMethod = restMethod;
        }
    }
}