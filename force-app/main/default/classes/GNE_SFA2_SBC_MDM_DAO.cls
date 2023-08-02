public class GNE_SFA2_SBC_MDM_DAO extends GNE_SFA2_SBC_DAO {
    private static final String SERVICE_DEFAULT_NAMESPACE = 'tns';
    private transient String siperianEndPoint;

    public GNE_SFA2_SBC_MDM_DAO() {
    }

    public override DataWrapper searchAccounts(String accType, String searchMode, Map<String, String> searchParams, PaginationDataWrapper paginationData, Set<String> teamCodes, Integer pageSize) {
        GNE_SFA2_SBC_Profiler.logActionStart('MDMSearch');
        DataWrapper result = null;

        try {
            result = intSearchAccounts(accType, searchMode, searchParams, paginationData, teamCodes, pageSize);
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

    private DataWrapper intSearchAccounts(String accType, String searchMode, Map<String, String> searchParams, PaginationDataWrapper paginationInputData, Set<String> teamCodes, Integer pageSize) {
        System.debug('#### MDM === ' + accType + ' >>> ' + searchMode + ' >>> ' + searchParams);
        List<AccountWrapper> resultRows = new List<AccountWrapper>();
        PaginationDataWrapper paginationData = null;
        String endpoint = getSiperianEndPoint();
        String restMethod = 'Find' + accType.toUpperCase() + 'By' + (searchMode == GNE_SFA2_SBC_Config.SearchModes.NameAddress.name() ? 'Profile' : searchMode == GNE_SFA2_SBC_Config.SearchModes.License.name() ? 'License' : 'MDMID');
        SiperianServiceRequest ssRequest = new SiperianServiceRequest(searchParams, teamCodes, pageSize, paginationInputData != null ? new PaginationRequest(paginationInputData) : null);
        String nsPrefix = getSiperianServiceNS() + ':';

        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setTimeout(120000);
        req.setEndpoint(endpoint + restMethod);
        req.setBody(JSON.serialize(ssRequest.toJSON()).replaceAll('"([^"]+)":', '"' + nsPrefix + '$1":'));
        HttpResponse res;
        GNE_SFA2_SBC_Profiler.logActionStart('MDMSearch.ServiceCallout');
        try {
            res = h.send(req);
        } finally {
            GNE_SFA2_SBC_Profiler.logActionEnd('MDMSearch.ServiceCallout');
        }
        if (res.getStatus() == 'OK' && res.getStatusCode() == 200) {
            GNE_SFA2_SBC_Profiler.logActionStart('MDMSearch.PrepareResults');

            try {
                String bodyInJSON = res.getBody().replaceAll('"' + nsPrefix + '([^"]+)":', '"$1":');
                PaginationResponse paginationResponse;
                ServiceResponse ssResponse = (ServiceResponse) JSON.deserialize(bodyInJSON, ServiceResponse.class);
                if (ssResponse == null) {
                    throw new ServiceException('No response for ||' + JSON.serialize(ssRequest.toJSON()), 200, restMethod);
                } else if (ssResponse.getError() != null) {
                    String message = String.isNotBlank(ssResponse.getError().getMessage()) ? ssResponse.getError().getMessage() : '';
                    Integer code = String.isNotBlank(ssResponse.getError().getCode()) ? Integer.valueOf(ssResponse.getError().getCode()) : 500;

                    if (!Pattern.matches('(?i)^\\s*(there are ){0,1}no records with provided.*$', message)) {
                        throw new ServiceException(ssResponse.getError().getMessage(), code, restMethod);
                    }
                } else if (ssResponse.getSearchHCPResponse() != null) {
                    PrescriberDetails hcpDetails = ssResponse.getSearchHCPResponse().getPrescriberDetails();
                    paginationResponse = hcpDetails.getPaginationResponse();
                    for (Prescriber presc : hcpDetails.getPrescribers()) {
                        resultRows.add(new AccountWrapper(presc));
                    }
                } else if (ssResponse.getSearchHCOResponse() != null) {
                    OrganizationDetails hcoDetails = ssResponse.getSearchHCOResponse().getOrganizationDetails();
                    paginationResponse = hcoDetails.getPaginationResponse();

                    for (Organization org : hcoDetails.getOrganizations()) {
                        resultRows.add(new AccountWrapper(org));
                    }
                }

                paginationData = new PaginationDataWrapper(paginationResponse, pageSize);
                GNE_SFA2_SBC_Profiler.setSiperianData(paginationData.size, paginationData.totalSize, paginationData.pageNumber, paginationData.pageSize, paginationData.pageTotalCount, paginationData.queryMore);
            } finally {
                GNE_SFA2_SBC_Profiler.logActionEnd('MDMSearch.PrepareResults');
            }
        } else {
            String status = res.getStatus();
            Integer statusCode = res.getStatusCode();
            throw new ServiceException(status, statusCode, restMethod);
        }

        return new DataWrapper(resultRows, paginationData != null ? paginationData : new PaginationDataWrapper());
    }

    private String getSiperianEndPoint() {
        if (siperianEndPoint == null) {
            siperianEndPoint = GNE_SFA2_SBC_Config.getConfigItem(GNE_SFA2_SBC_Config.ConfigItems.SBCMdmSiperianEndPoint);
            siperianEndPoint = siperianEndPoint != null ? siperianEndPoint : 'http://endpoint-not-set';
        }

        return siperianEndPoint;
    }

    private String getSiperianServiceNS() {
        String ns = GNE_SFA2_SBC_Config.getConfigItem(GNE_SFA2_SBC_Config.ConfigItems.SBCMdmSiperianServiceNS);
        return ns != null ? ns : SERVICE_DEFAULT_NAMESPACE;
    }

    protected override Integer getServicePageSize() {
        String pageSizeInString = GNE_SFA2_SBC_Config.getConfigItem(GNE_SFA2_SBC_Config.ConfigItems.SBCMdmSiperianPageSize);
        return String.isNotBlank(pageSizeInString) && pageSizeInString.isNumeric() ? Integer.valueOf(pageSizeInString) : SERVICE_DEFAULT_PAGE_SIZE;
    }

    private virtual class SiperianServiceRequest {
        private Map<String, String> searchParams;
        private Set<String> teamCodes;
        private Integer recordsToReturn;
        private PaginationRequest paginationRequest;

        private SiperianServiceRequest(Map<String, String> searchParams, Set<String> teamCodes, Integer recordsToReturn, PaginationRequest paginationRequest) {
            this.searchParams = searchParams;
            this.teamCodes = teamCodes;
            this.recordsToReturn = recordsToReturn;
            this.paginationRequest = paginationRequest;
        }

        private virtual Map<String, Object> toJSON() {
            Map<String, Object> jsonObj = new Map<String, Object>();

            if (searchParams != null && !searchParams.isEmpty()) {
                for (String param : searchParams.keySet()) {
                    String val = searchParams.get(param);

                    if (String.isNotBlank(val)) {
                        if (param != 'orgType') {
                            jsonObj.put(param, searchParams.get(param));
                        } else {
                            Map<String, List<Map<String, String>>> orgTypeMap = new Map<String, List<Map<String, String>>>();
                            orgTypeMap.put('orgTypeData', new List<Map<String, String>>{
                                    new Map<String, String>{
                                            'Code' => 'FRM_HCO', 'Value' => searchParams.get(param)
                                    }
                            });
                            jsonObj.put(param, orgTypeMap);
                        }
                    } else {
                        if (GNE_SFA2_Util.isFrmUser() && param == 'orgType') {
                            Map<String, List<Map<String, String>>> orgTypeMap = new Map<String, List<Map<String, String>>>();
                            List<Map<String, String>> tempList = new List<Map<String, String>>();
                            for (String type : GNE_SFA2_SBC_Config.getConfigItem(GNE_SFA2_SBC_Config.ConfigItems.FRM_HCOOrgTypes).split(',')) {
                                tempList.add(new Map<String, String>{
                                        'Code' => 'FRM_HCO', 'Value' => type
                                });
                            }
                            orgTypeMap.put('orgTypeData', tempList);
                            jsonObj.put(param, orgTypeMap);
                        }
                    }
                }
            }

            if (teamCodes != null && !teamCodes.isEmpty()) {
                jsonObj.put('teamCode', new Map<String, Object>{
                        'value' => teamCodes
                });
            }

            if (recordsToReturn != null) {
                jsonObj.put('recordsToReturn', String.valueOf(recordsToReturn));
            }

            if (paginationRequest != null) {
                jsonObj.put('paginationRequest', paginationRequest.toJSON());
            }

            return jsonObj;
        }
    }
}