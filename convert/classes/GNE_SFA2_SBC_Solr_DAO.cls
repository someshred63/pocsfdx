public with sharing class GNE_SFA2_SBC_Solr_DAO extends GNE_SFA2_SBC_DAO {

    private static final String FRM_TEAM_CODE = 'FRM';
    private static final String INS_ID_CODE = 'INS';
    private static final String ADDRESS_MDM_CODE = 'SFDC_ADDRESS_MDM';

    private transient String solrEndPoint;
    private transient String solrToken;
    private transient Set<String> supportedTeamCode;

    public GNE_SFA2_SBC_Solr_DAO() {
    }

    public override DataWrapper searchAccounts(String accType, String searchMode, Map<String, String> searchParams, PaginationDataWrapper paginationData, Set<String> teamCodes, Integer pageSize) {
        GNE_SFA2_SBC_Profiler.logActionStart('MDMSearch');
        DataWrapper result = null;

        try {
            result = intSearchAccountsSolr(accType, searchMode, searchParams, paginationData, teamCodes, pageSize);
        } catch (ServiceException sse) {
            GNE_SFA2_SBC_Profiler.logActionStart('MDMSearch.ServiceError');
            GNE_SFA2_SBC_Profiler.setLogActionDescription('MDMSearch.ServiceError', sse.getMessage());
            GNE_SFA2_SBC_Profiler.logActionEnd('MDMSearch.ServiceError');
            throw sse;
        } finally {
            GNE_SFA2_SBC_Profiler.logActionEnd('MDMSearch');
        }
        return result;
    }

    private Boolean useTeamCode(Set<String> teamCodes) {
        Set<String> supportedTeamCodes = getSupportedTeamCodes();
        Boolean useTeamCode = false;
        if (teamCodes != null) {
            for (String tc : teamCodes) {
                if (supportedTeamCodes.contains(tc)) {
                    useTeamCode = true;
                }
            }
        }
        return useTeamCode;
    }

    private DataWrapper intSearchAccountsSolr(String accType, String searchMode, Map<String, String> searchParams, PaginationDataWrapper paginationInputData, Set<String> teamCodes, Integer pageSize) {
        System.debug('#### MDM === ' + accType + ' >>> ' + searchMode + ' >>> ' + searchParams);
        List<AccountWrapper> resultRows = new List<AccountWrapper>();
        PaginationDataWrapper paginationData = null;
        String endpoint = getSolrEndPoint();
        PaginationRequest pr = (paginationInputData != null) ? new PaginationRequest(paginationInputData) : null;
        teamCodes = useTeamCode(teamCodes) ? teamCodes : new Set<String>();
        SolrServiceRequest ssRequest = new SolrServiceRequest(searchMode, searchParams, teamCodes, pageSize, pr);

        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Auth-Key', getSolrToken());
        req.setTimeout(120000);
        Integer startIndex = ssRequest.getOffset();
        String params = '?start=' + startIndex + '&rows=' + ssRequest.recordsToReturn;

        String restMethod = (accType == 'hcp' ? 'searchCustomers' : 'searchBusiness');
        req.setEndpoint(endpoint + restMethod + params);
        req.setBody(JSON.serialize(ssRequest.toJSON()).replaceAll('"([^"]+)":', '"' + '$1":'));
        System.debug('Request body: ' + req.getBody());
        HttpResponse res;
        GNE_SFA2_SBC_Profiler.logActionStart('SolrSearch.ServiceCallout');
        try {
            res = h.send(req);
        } finally {
            GNE_SFA2_SBC_Profiler.logActionEnd('SolrSearch.ServiceCallout');
        }
        System.debug('intSearchAccountsSolr response ' + (res != null ? res.getBody() : 'null'));
        if (res.getStatusCode() == 200) {
            GNE_SFA2_SBC_Profiler.logActionStart('SolrSearch.PrepareResults');

            try {
                String bodyInJSON = res.getBody().replaceAll('"' + '([^"]+)":', '"$1":');
                PaginationResponse paginationResponse;
                if (accType == 'hcp') {
                    SolrServiceResponseInd ssResponse = (SolrServiceResponseInd) JSON.deserialize(bodyInJSON, SolrServiceResponseInd.class);
                    if (ssResponse == null) {
                        throw new ServiceException('No response for ||' + JSON.serialize(ssRequest.toJSON()), 200, restMethod);
                    } else if (ssResponse.error != null) {
                        String message = String.isNotBlank(ssResponse.error.message) ? ssResponse.error.message : '';
                        Integer code = String.isNotBlank(ssResponse.error.code) ? Integer.valueOf(ssResponse.error.code) : 500;

                        if (!Pattern.matches('(?i)^\\s*(there are ){0,1}no records with provided.*$', message)) {
                            throw new ServiceException(ssResponse.error.message, code, restMethod);
                        }
                    } else if (ssResponse.records != null) {
                        paginationResponse = ssResponse.getPaginationResponse();

                        for (Prescriber presc : ssResponse.getPrescribers()) {
                            resultRows.add(new AccountWrapper(presc));
                        }
                    }
                } else if (accType == 'hco') {
                    SolrServiceResponseOrg ssResponse = (SolrServiceResponseOrg) JSON.deserialize(bodyInJSON, SolrServiceResponseOrg.class);
                    if (ssResponse == null) {
                        throw new ServiceException('No response for ||' + JSON.serialize(ssRequest.toJSON()), 200, restMethod);
                    } else if (ssResponse.error != null) {
                        String message = String.isNotBlank(ssResponse.error.message) ? ssResponse.error.message : '';
                        Integer code = String.isNotBlank(ssResponse.error.code) ? Integer.valueOf(ssResponse.error.code) : 500;

                        if (!Pattern.matches('(?i)^\\s*(there are ){0,1}no records with provided.*$', message)) {
                            throw new ServiceException(ssResponse.error.message, code, restMethod);
                        }
                    } else if (ssResponse.records != null) {
                        paginationResponse = ssResponse.getPaginationResponse();
                        for (Organization org : ssResponse.getOrganizations()) {
                            resultRows.add(new AccountWrapper(org));
                        }
                    }
                }
                paginationData = new PaginationDataWrapper(paginationResponse, pageSize);
                paginationData.tokenId = 'solr';
                GNE_SFA2_SBC_Profiler.setSiperianData(paginationData.size, paginationData.totalSize, paginationData.pageNumber, paginationData.pageSize, paginationData.pageTotalCount, paginationData.queryMore);
            } finally {
                GNE_SFA2_SBC_Profiler.logActionEnd('SolrSearch.PrepareResults');
            }
        } else {
            String status = res.getStatus();
            Integer statusCode = res.getStatusCode();
            throw new ServiceException(status, statusCode, restMethod);
        }
        return new DataWrapper(resultRows, paginationData != null ? paginationData : new PaginationDataWrapper());
    }

    private String getSolrEndPoint() {
        if (solrEndPoint == null) {
            solrEndPoint = GNE_SFA2_SBC_Config.getConfigItem(GNE_SFA2_SBC_Config.ConfigItems.SBCSolrEndPoint);
        }
        return solrEndPoint;
    }

    private String getSolrToken() {
        if (solrToken == null) {
            solrToken = GNE_SFA2_SBC_Config.getConfigItem(GNE_SFA2_SBC_Config.ConfigItems.SBCSolrToken);
        }
        return solrToken;
    }

    private Set<String> getSupportedTeamCodes() {
        if (supportedTeamCode == null) {
            String teamCodes = GNE_SFA2_SBC_Config.getConfigItem(GNE_SFA2_SBC_Config.ConfigItems.SBCSolrSupportedTeamCodes);
            supportedTeamCode = String.isBlank(teamCodes) ? new Set<String>() : new Set<String>(teamCodes.split(GNE_SFA2_SolrUtil.SETTINGS_SEPARATOR));
        }
        return supportedTeamCode;
    }

    private class SolrServiceRequest {
        private String searchMode;
        private Map<String, String> searchParams;
        private Set<String> teamCodes;
        private Integer recordsToReturn;
        private PaginationRequest paginationRequest;

        private SolrServiceRequest(String searchMode, Map<String, String> searchParams, Set<String> teamCodes, Integer recordsToReturn, PaginationRequest paginationRequest) {
            this.searchMode = searchMode;
            this.searchParams = searchParams;
            this.teamCodes = teamCodes;
            this.recordsToReturn = recordsToReturn;
            this.paginationRequest = paginationRequest;
        }

        private Map<String, Object> toJSON() {
            Map<String, Object> jsonObj = new Map<String, Object>();
            if (searchParams != null && !searchParams.isEmpty()) {
                for (String param : searchParams.keySet()) {
                    String val = searchParams.get(param);
                    if (String.isNotBlank(val)) {
                        if (param == 'personName') {
                            jsonObj.put('fullName', val);
                        } else if (param == 'streetAddress') {
                            jsonObj.put('fullAddress', val);
                        } else if (param == 'stateCode') {
                            if (searchMode == 'License') {
                                jsonObj.put('license_issuedState', val);
                            } else {
                                jsonObj.put('address_stateCode', val);
                            }
                        } else if (param == 'zipCode') {
                            jsonObj.put('address_zipCode', val);
                        } else if (param == 'cityName') {
                            jsonObj.put('address_cityName', val);
                        } else if (param == 'organizationName') {
                            jsonObj.put('fullBusinessName', val);
                        } else if (param == 'orgType') {
                            //ignore
                        } else if (param == 'mdmid') {
                            TypeValue[] externalID = new TypeValue[1];
                            externalID[0] = new TypeValue(null, val);
                            jsonObj.put('externalID', externalID);
                        } else if (param == 'licenseNumber') {
                            jsonObj.put('license_licenseNumber', val);
                        } else {
                            jsonObj.put(param, val);
                        }
                    }
                }
            }
            addTeamCode(jsonObj);
            return jsonObj;
        }

        private void addTeamCode(Map<String, Object> jsonObj) {
            if (teamCodes != null && !teamCodes.isEmpty()) {
                Boolean containsFrmTeamCode = false;
                for (String teamCode : teamCodes) {
                    if (teamCode.endsWith(FRM_TEAM_CODE)) {
                        containsFrmTeamCode = true;
                    }
                }
                if (containsFrmTeamCode) {
                    teamCodes.add(FRM_TEAM_CODE);
                }
                jsonObj.put('teamCode', teamCodes);
            }
        }

        Integer getOffset() {
            Integer result = 0;
            if (paginationRequest != null) {
                result = paginationRequest.getRecordStartNumber();
            }
            return result;
        }
    }

    private abstract class SolrServiceResponse {
        private String status;
        private Integer numFound;
        private Integer start;
        private SolrError error;
        private String[] suggestedKeywords;
    }

    private class SolrServiceResponseInd extends SolrServiceResponse {
        private CustomerDetailsResource[] records;

        private Prescriber[] getPrescribers() {
            Prescriber[] result = new Prescriber[records.size()];
            Integer i = 0;
            for (CustomerDetailsResource cd : records) {
                result[i++] = cd.getPrescriber();
            }
            return result;
        }

        PaginationResponse getPaginationResponse() {
            Boolean hasMore = numFound > start + records.size();
            return new PaginationResponse(String.valueOf(hasMore), 'solr', String.valueOf(numFound), String.valueOf(start + records.size()), String.valueOf(start), String.valueOf(records.size()));
        }
    }

    private class SolrServiceResponseOrg extends SolrServiceResponse {
        private BusinessDetailsResource[] records;

        private Organization[] getOrganizations() {
            Organization[] result = new Organization[records.size()];
            Integer i = 0;
            for (BusinessDetailsResource bd : records) {
                result[i++] = bd.getOrganization();
            }
            return result;
        }

        PaginationResponse getPaginationResponse() {
            Boolean hasMore = numFound > start + records.size();
            Integer st = start == 0 ? 1 : start;
            return new PaginationResponse(String.valueOf(hasMore), 'solr', String.valueOf(numFound), String.valueOf(st + records.size()), String.valueOf(st), String.valueOf(records.size()));
        }
    }

    private class CustomerDetailsResource {
        private String firstName;
        private String middleName;
        private String lastName;
        private String mdmId;
        private String partyId;
        private String status;
        private String[] alternateName;
        private String customerType;
        private TypeValue[] externalID;
        private String[] professionalType;
        private String[] partyCredential;
        private String[] partySpecialty;
        private List<SolrAddress> addresses;
        private List<SolrLicense> licenses;
        private String[] teamCode;

        public Prescriber getPrescriber() {
            AddressData[] addressData = new AddressData[this.addresses.size()];
            Integer i = 0;
            for (SolrAddress solrAddress : this.addresses) {
                addressData[i++] = solrAddress.getAddress();
            }
            Address address = new Address(addressData);
            License license = null;
            if (this.licenses != null) {
                LicenseData[] licenseData = new LicenseData[this.licenses.size()];
                i = 0;
                for (SolrLicense sl : this.licenses) {
                    licenseData[i++] = sl.getLicense();
                }
                license = new License(licenseData);
            }
            Prescriber p = new Prescriber(mdmId, partyId, new AltrenateName(this.alternateName), status, firstName, middleName, lastName, new ProfessionalType(this.professionalType), new PartyCredential(this.partyCredential), new PartySpecialty(this.partySpecialty), license, address);
            return p;
        }
    }

    private class BusinessDetailsResource {
        private String businessName;
        private String dbaName;
        private String orgId;
        private String mdmId;
        private String status;
        private String phone;
        private String fax;
        private String webSite;
        private String accountSource;
        private String classification;
        private String facility;
        private String specialty;
        private TypeValue[] externalID;
        private String[] teamCode;
        private List<SolrAddress> addresses;

        public Organization getOrganization() {
            AddressData[] addressData = new AddressData[this.addresses.size()];
            Integer i = 0;
            for (SolrAddress solrAddress : this.addresses) {
                addressData[i++] = solrAddress.getAddress();
            }
            Address address = new Address(addressData);

            Organization org = new Organization(mdmId, orgId, null, status, businessName, phone, fax, webSite, facility, address);
            AccountType2[] accountTypes = new AccountType2[1];
            accountTypes[0] = new AccountType2('HOSPITAL - SPECIALTY GROUP', null);
            org.setAccountType(accountTypes);
            org.setInsId(getExternalId(INS_ID_CODE));
            return org;
        }

        private String getExternalId(String name) {
            String value = null;
            for (TypeValue tv : externalID) {
                if (tv.Type == name) {
                    value = tv.Value;
                }
            }
            return value;
        }
    }

    private class SolrAddress {
        private String partyId;
        private String mdmId;
        private String mdmAddressId;
        private String locationId;
        private String isDefault;
        private String streetAddress;
        private String unitType;
        private String unitValue;
        private String cityName;
        private String stateCode;
        private String zipCode;
        private String status;
        private String latitude;
        private String longitude;
        private String addressLine1;
        private String addressLine2;
        private String[] locationUsage;
        private CodeValue[] communicationChannel;
        private TypeValue[] externalID;

        public AddressData getAddress() {
            streetAddress = String.isBlank(streetAddress) ? addressLine1 : streetAddress;
            List<String> line2Split = String.isBlank(addressLine2) ? null : addressLine2.split('\\s');
            if (String.isBlank(unitType)) {
                if (line2Split != null && line2Split.size() > 1) {
                    unitType = line2Split.get(0);
                }
            }
            if (String.isBlank(unitValue)) {
                if (line2Split != null) {
                    if (line2Split.size() > 1) {
                        unitValue = line2Split.get(1);
                    } else {
                        unitValue = line2Split.get(0);
                    }
                }
            }
            String mdmId = String.isNotBlank(mdmAddressId) ? mdmAddressId : getExternalId(ADDRESS_MDM_CODE);
            return new AddressData(mdmId, locationId, streetAddress, unitType, unitValue, cityName, stateCode, zipCode, isDefault, latitude, longitude, status);
        }

        private String getExternalId(String name) {
            String value = null;
            for (TypeValue tv : externalID) {
                if (tv.Type == name) {
                    value = tv.Value;
                }
            }
            return value;
        }
    }

    private class SolrLicense {
        private String partyId;
        private String mdmId;
        private String licenseNumber;
        private String issuedState;
        private String designation;
        private String adjExpirationDate;
        private String sampleabilityFlag;

        public LicenseData getLicense() {
            return new LicenseData(issuedState, licenseNumber, adjExpirationDate, sampleabilityFlag, designation);
        }
    }

    private class SolrError {
        private String status;
        private String message;
        private String code;
        private CustomerDetailsResource[] records;
    }

    private class TypeValue {
        private String Type;
        private String Value;

        public TypeValue(String type, String value) {
            this.Type = type;
            this.Value = value;
        }
    }

    public class CodeValue {
        private String Code;
        private String Value;
    }
}