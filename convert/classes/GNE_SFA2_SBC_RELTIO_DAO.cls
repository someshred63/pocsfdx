public class GNE_SFA2_SBC_RELTIO_DAO extends GNE_SFA2_SBC_DAO {

    public override DataWrapper searchAccounts(String accType, String searchMode, Map<String, String> searchParams, PaginationDataWrapper paginationData, Set<String> teamCodes, Integer pageSize) {
        GNE_SFA2_SBC_Profiler.logActionStart('ReltioSearch');
        DataWrapper result = null;

        try {
            result = intSearchAccountsReltio(accType, searchMode, searchParams, paginationData, teamCodes, pageSize);
        } catch (ServiceException sse) {
            GNE_SFA2_SBC_Profiler.logActionStart('ReltioSearch.ServiceError');
            GNE_SFA2_SBC_Profiler.setLogActionDescription('ReltioSearch.ServiceError', sse.getMessage());
            GNE_SFA2_SBC_Profiler.logActionEnd('ReltioSearch.ServiceError');
            throw sse;
        } finally {
            GNE_SFA2_SBC_Profiler.logActionEnd('ReltioSearch');
        }
        return result;
    }

    private DataWrapper intSearchAccountsReltio(String accType, String searchMode, Map<String, String> searchParams, PaginationDataWrapper paginationInputData, Set<String> teamCodes, Integer pageSize) {
        System.debug('#### Reltio === ' + accType + ' >>> ' + searchMode + ' >>> ' + searchParams);
        List<AccountWrapper> resultRows = new List<AccountWrapper>();
        PaginationDataWrapper paginationData = null;
        PaginationRequest pr = (paginationInputData != null) ? new PaginationRequest(paginationInputData) : null;
        String restMethod = (accType == 'hcp' ? 'searchCustomers' : 'searchBusiness');

        GNE_SFA2_SBC_Profiler.logActionStart('ReltioSearch.ServiceCallout');
        SearchParms searchParms = new SearchParms(searchParams, pr);
        GNE_SFA2_SBC_Profiler.logActionStart('ReltioSbcSearch.ServiceCallout');
        HttpResponse res = GNE_ReltioCalloutHandler.callReltioEndpoint(accType, searchMode, 'GET', '', searchParms.endpointParams, new Map<String, String>());

        if (res.getStatusCode() == 200) {
            GNE_SFA2_SBC_Profiler.logActionStart('ReltioSearch.PrepareResults');
            try {

                String bodyInJSON = res.getBody().replaceAll('"' + '([^"]+)":', '"$1":');
                PaginationResponse paginationResponse;
                if(accType == 'hcp') {
                    ReltioResponseHcp reltioResponseHcp = (ReltioResponseHcp) JSON.deserialize(bodyInJSON, ReltioResponseHcp.class);
                    if (reltioResponseHcp == null) {
                        throw new ServiceException('No response for ||' + JSON.serialize(null), 200, restMethod);
                    } else if (reltioResponseHcp.errorDetails.get(0).description != null && reltioResponseHcp.errorDetails.get(0).code != null) {
                        String message = String.isNotBlank(reltioResponseHcp.errorDetails.get(0).description) ? reltioResponseHcp.errorDetails.get(0).description : '';
                        Integer code = String.isNotBlank(reltioResponseHcp.errorDetails.get(0).code) ? Integer.valueOf(reltioResponseHcp.errorDetails.get(0).code) : 500;

                        if (!Pattern.matches('(?i)^\\s*(there are ){0,1}no records with provided.*$', message)) {
                            throw new ServiceException(reltioResponseHcp.errorDetails.get(0).description, code, restMethod);
                        }
                    } else if (reltioResponseHcp.searchDetails != null) {
                        reltioResponseHcp.start = paginationInputData != null && paginationInputData.endPageIdx != null ? paginationInputData.endPageIdx : 0;
                        paginationResponse = reltioResponseHcp.getPaginationResponse();

                        for (Prescriber presc : reltioResponseHcp.getPrescribers()) {
                            resultRows.add(new AccountWrapper(presc));
                        }
                    }

                } else if (accType == 'hco') {

                    ReltioResponseHco reltioResponseHco = (ReltioResponseHco) JSON.deserialize(bodyInJSON, ReltioResponseHco.class);

                    if (reltioResponseHco == null) {
                        throw new ServiceException('No response for ||' + JSON.serialize(null), 200, restMethod);
                    } else if (reltioResponseHco.errorDetails.get(0).description != null && reltioResponseHco.errorDetails.get(0).code != null) {
                        String message = String.isNotBlank(reltioResponseHco.errorDetails.get(0).description) ? reltioResponseHco.errorDetails.get(0).description : '';
                        Integer code = String.isNotBlank(reltioResponseHco.errorDetails.get(0).code) ? Integer.valueOf(reltioResponseHco.errorDetails.get(0).code) : 500;

                        if (!Pattern.matches('(?i)^\\s*(there are ){0,1}no records with provided.*$', message)) {
                            throw new ServiceException(reltioResponseHco.errorDetails.get(0).description, code, restMethod);
                        }
                    } else if (reltioResponseHco.searchDetails != null) {
                        reltioResponseHco.start = paginationInputData != null && paginationInputData.endPageIdx != null ? paginationInputData.endPageIdx : 0;
                        paginationResponse = reltioResponseHco.getPaginationResponse();

                        for (Organization org : reltioResponseHco.getOrganizations()) {
                            resultRows.add(new AccountWrapper(org));
                        }
                    }

                }
                paginationData = new PaginationDataWrapper(paginationResponse, pageSize);
                paginationData.tokenId = 'solr';
                GNE_SFA2_SBC_Profiler.setSiperianData(paginationData.size, paginationData.totalSize, paginationData.pageNumber, paginationData.pageSize, paginationData.pageTotalCount, paginationData.queryMore);

            } finally {
                GNE_SFA2_SBC_Profiler.logActionEnd('ReltioSearch.PrepareResults');
            }

        } else {
            String status = res.getStatus();
            Integer statusCode = res.getStatusCode();
            throw new ServiceException(status, statusCode, restMethod);
        }

        return new DataWrapper(resultRows, paginationData != null ? paginationData : new PaginationDataWrapper());
    }



    private abstract class ReltioResponseAbstract {
        public Integer start;
        ErrorDetails[] errorDetails;
        Integer totalRecordsCount;
        abstract PaginationResponse getPaginationResponse();
    }

    private class ReltioResponseHcp extends ReltioResponseAbstract {

        List<SearchDetailsHcp> searchDetails;

        private Prescriber[] getPrescribers() {
            Prescriber[] result = new Prescriber[searchDetails.size()];
            Integer i = 0;
            for (SearchDetailsHcp sd : searchDetails) {
                result[i++] = sd.getPrescriber();
            }
            return result;
        }

        override PaginationResponse getPaginationResponse() {
            this.start = this.start == null ? 0 : this.start;
            Boolean hasMore = totalRecordsCount > start + this.searchDetails.size();
            return new PaginationResponse(String.valueOf(hasMore), 'solr', String.valueOf(totalRecordsCount), String.valueOf(start + searchDetails.size()), String.valueOf(start), String.valueOf(searchDetails.size()));
        }
    }

    private class ReltioResponseHco extends ReltioResponseAbstract {

        List<SearchDetailsHco> searchDetails;

        private Organization[] getOrganizations() {
            Organization[] result = new Organization[searchDetails.size()];
            Integer i = 0;
            for (SearchDetailsHco sd : searchDetails) {
                result[i++] = sd.getOrganization();
            }
            return result;
        }

        override PaginationResponse getPaginationResponse() {
            this.start = this.start == null ? 0 : this.start;
            Boolean hasMore = totalRecordsCount > start + this.searchDetails.size();
            return new PaginationResponse(String.valueOf(hasMore), 'solr', String.valueOf(totalRecordsCount), String.valueOf(start + searchDetails.size()), String.valueOf(start), String.valueOf(searchDetails.size()));
        }

    }

    private virtual class SearchDetails {
        String mdmId;
        String[] alternateName;
        TypeValue[] externalId;
        String status;
        ReltioAddress[] address;

        private AddressData[] prepareAddressData() {
            AddressData[] addressData = new AddressData[this.address != null ? this.address.size() : 0];
            Integer i = 0;
            if(this.address != null) {
                for (ReltioAddress reltioAddress : this.address) {
                    addressData[i++] = reltioAddress.getAddress();
                }
            }
            return addressData;
        }

    }

    private class SearchDetailsHcp extends SearchDetails {
        String personName;
        String firstName;
        String middleName;
        String lastName;
        TypeValue[] externalId;
        String professionalType;
        Credential[] credential;
        Speciality[] speciality;
        ReltioLicense[] license;

        public Prescriber getPrescriber() {
            ProfessionalType professionalType = prepareProfessionalType();
            Address address = new Address(prepareAddressData());
            License license = new License(prepareLicenseData());
            PartyCredential partyCredential =  preparePartyCredential();
            PartySpecialty partySpecialty = preparePartySpecialty();
            String sfdcId = prepareSfdcId();
            Prescriber p = new Prescriber(mdmId, '', new AltrenateName(this.alternateName), status, firstName, middleName, lastName, professionalType, partyCredential, partySpecialty, license, address);
            return p;
        }

        private ProfessionalType prepareProfessionalType() {
            return new ProfessionalType(new String[]{this.ProfessionalType});
        }

        private LicenseData[] prepareLicenseData() {
            LicenseData[] licenseData = new LicenseData[this.license != null ? this.license.size() : 0];
            if(this.license != null) {
                Integer i = 0;
                for (ReltioLicense rl : this.license) {
                    String shortState = String.valueOf(rl.issuedState).left(2);
                    rl.issuedState = shortState;
                    licenseData[i++] = rl.getLicense();
                }
            }
            return licenseData;
        }

        private PartyCredential preparePartyCredential() {
            Set<String> credentials = new Set<String>();
            if(this.credential != null) {
                for(Credential crd : this.credential) {
                    if(crd.degree != null) {
                        for(Type_Degree td : crd.degree) {
                            credentials.add(td.lookupCode);
                        }
                    }
                }
            }
            return new PartyCredential(new List<String>(credentials));
        }

        private PartySpecialty preparePartySpecialty() {
            Set<String> specialties = new Set<String>();
            if(this.speciality != null) {
                for(Speciality spec : this.speciality) {
                    if(spec.Specialty != null) {
                        for(Specialty sp : spec.Specialty) {
                            if(String.isNotBlank(sp.value)) {
                                specialties.add(sp.value);
                            }
                        }
                    }
                }
            }
            return new PartySpecialty(new List<String>(specialties));
        }

        private String prepareSfdcId() {
            String sfdcId = '';
            if(this.externalId != null) {
                for(TypeValue exId : this.externalId) {
                    if('SFDC'.equalsIgnoreCase(exId.type)) {
                        sfdcId = exId.value;
                    }
                }
            }
            return sfdcId;
        }

    }

    private class SearchDetailsHco extends SearchDetails {
        String organizationName { get; set; }
        String accountType { get; set; }
        OrgType orgType { get; set; }

        public Organization getOrganization() {
            Address address = new Address(prepareAddressData());
            Organization org = new Organization(mdmId, '', null, status, organizationName, '', '', '', '', address);
            AccountType2[] accountTypes = new AccountType2[1];
            accountTypes[0] = new AccountType2('HOSPITAL - SPECIALTY GROUP', null);
            org.setAccountType(accountTypes);
            return org;
        }
    }

    private class OrgType {
        String code { get; set; }
    }

    private class ReltioAddress {
        String id;
        String streetAddress;
        String streetAddress2;
        String unitName;
        String unitValue;
        String cityName;
        String stateCode;
        String zipCode;
        String phoneNumber;
        String isDefault;
        String addressStatus;
        String latitude;
        String longitude;

        public AddressData getAddress() {
            return new AddressData(id, streetAddress, streetAddress2, unitName, unitValue, cityName, stateCode, zipCode, isDefault, latitude, longitude, addressStatus, phoneNumber);
        }
    }

    private class TypeValue {
        private String type;
        private String value;
    }

    private class Credential {
        Type_Degree[] type;
        Type_Degree[] degree;
    }

    private class Type_Degree {
        String type;
        Boolean ov;
        String value;
        String uri;
        String lookupCode;
        String lookupValue;
    }

    private class SpecialityList {
        Speciality[] speciality;
    }

    private class Speciality {
        Specialty[] specialtyType;
        Specialty[] specialty;
        Specialty[] primarySpecialtyFlag;
    }

    private class Specialty {
        String type;
        Boolean ov;
        String value;
        String lookupCode;
        String lookupRawValue;
        String uri;
    }

    private class ReltioLicense {
        String licenseNumber;
        String issuedState;
        String designation;
        String adjustedExpirationDate;
        String sampleability;

        public LicenseData getLicense() {
            return new LicenseData(issuedState, licenseNumber, adjustedExpirationDate, sampleability, designation);
        }
    }

    private class ErrorDetails {
        String code;
        String description;
    }

    public class SearchParms {
        private Map<String, String> searchParams { get; set; }
        private String endpointParams { get; set; }
        private String maxCount = GNE_ReltioSettings__c.getInstance().GET_MAX_COUNT__c != null ? GNE_ReltioSettings__c.getInstance().GET_MAX_COUNT__c : '5';
        private GNE_SFA2_SBC_DAO.PaginationRequest paginationRequest;
        private GNE_SFA2_SBC_DAO.PaginationDataWrapper paginationInputData;

        //HCP Name & Address Search
        private String personName { get; set; }
        private String street { get; set; }
        private String city { get; set; }
        private String state { get; set; }
        private String zip { get; set; }
        //HCP License Number
        private String licenseNumber { get; set; }
        //HCP MDM ID Search
        private String mdmId { get; set; }
        //HCO Name & Address Search
        private String organizationName { get; set; }

        private SearchParms(Map<String, String> searchParams, PaginationRequest paginationRequest) {
            this.searchParams = searchParams;
            this.paginationRequest = paginationRequest;
            convertSearchParamsToVariables();
            addParmas();
        }

        private void convertSearchParamsToVariables() {
            if (this.searchParams != null && !this.searchParams.isEmpty()) {
                for (String param : this.searchParams.keySet()) {
                    String val = this.searchParams.get(param) != null ? this.searchParams.get(param).trim().replace(' ', '%20') : this.searchParams.get(param);
                    if (String.isNotBlank(val)) {
                        if (param == 'personName') {
                            this.personName = val;
                        } else if(param == 'organizationName') {
                            this.organizationName = val;
                        } else if(param == 'stateCode') {
                            this.state = val;
                        } else if(param == 'cityName') {
                            this.city = val;
                        } else if(param == 'streetAddress') {
                            this.street = val;
                        } else if(param == 'zipCode') {
                            this.zip = val;
                        } else if(param == 'licenseNumber') {
                            this.licenseNumber = val;
                        } else if(param == 'MDMID') {
                            this.mdmId = val;
                        }
                    }
                }
            }
        }

        private void addParmas() {
            this.endpointParams = '?';
            if(String.isNotBlank(this.mdmId)) {
                this.endpointParams += 'mdmId=' + this.mdmId + '&';
            }
            if(String.isNotBlank(this.licenseNumber)) {
                this.endpointParams += 'licenseNumber=' + this.licenseNumber + '&';
            }
            if(String.isNotBlank(this.personName)) {
                this.endpointParams += 'personName=' + this.personName + '&';
            }
            if(String.isNotBlank(this.organizationName)) {
                this.endpointParams += 'organizationName=' + this.organizationName + '&';
            }
            if(String.isNotBlank(this.street)) {
                this.endpointParams += 'streetAddress=' + this.street + '&';
            }
            if(String.isNotBlank(this.city)) {
                this.endpointParams += 'city=' + this.city + '&';
            }
            if(String.isNotBlank(this.state)) {
                this.endpointParams += 'state=' + this.state + '&';
            }
            if(String.isNotBlank(this.zip)) {
                this.endpointParams += 'zipCode=' + this.zip + '&';
            }
            this.endpointParams += 'offsetValue=' + getOffset() + '&' + 'maxCount=' + getMaxCount();
        }

        Integer getOffset() {
            Integer result = 0;
            if (paginationRequest != null) {
                result = paginationRequest.getRecordStartNumber();
            }
            return result;
        }

        Integer getMaxCount() {
            Integer result = Integer.valueOf(maxCount);
            if (paginationRequest != null) {
                result = paginationRequest.getRecordsNumber();
            }
            return result;
        }

    }

}