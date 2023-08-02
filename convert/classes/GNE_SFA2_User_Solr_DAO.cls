public with sharing class GNE_SFA2_User_Solr_DAO {

    private transient String solrEndPoint;
    private transient String solrToken;

    public GNE_SFA2_User_Solr_DAO() {
    }

    public SolrServiceResponse searchUsers(SearchParams searchParams, GNE_SFA2_SBC_DAO.PaginationDataWrapper paginationData, Integer pageSize) {
        GNE_SFA2_SBC_Profiler.logActionStart('SolrSearchUsers');
        SolrServiceResponse result = null;

        try {
            result = intSearchUsers(searchParams, paginationData, pageSize);
        } catch (GNE_SFA2_SBC_DAO.ServiceException sse) {
            GNE_SFA2_SBC_Profiler.logActionStart('SolrSearch.ServiceError');
            GNE_SFA2_SBC_Profiler.setLogActionDescription('SolrSearch.ServiceError', sse.getMessage());
            GNE_SFA2_SBC_Profiler.logActionEnd('SolrSearch.ServiceError');
            throw sse;
        } finally {
            GNE_SFA2_SBC_Profiler.logActionEnd('SolrSearchUsers');
        }
        return result;
    }

    private SolrServiceResponse intSearchUsers(SearchParams searchParams, GNE_SFA2_SBC_DAO.PaginationDataWrapper paginationInputData, Integer pageSize) {
        System.debug('#### ' + searchParams);
        GNE_SFA2_SBC_DAO.PaginationDataWrapper paginationData = null;
        String endpoint = getSolrEndPoint();
        GNE_SFA2_SBC_DAO.PaginationRequest pr = (paginationInputData != null) ? new GNE_SFA2_SBC_DAO.PaginationRequest(paginationInputData) : null;
        SolrServiceRequest ssRequest = new SolrServiceRequest(searchParams, pageSize, pr);

        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Auth-Key', getSolrToken());
        req.setTimeout(120000);
        Integer startIndex = ssRequest.getOffset();
        String params = '?start=' + startIndex + '&rows=' + ssRequest.recordsToReturn;

        String restMethod = 'searchUser';
        req.setEndpoint(endpoint + restMethod + params);
        req.setBody(JSON.serialize(ssRequest.toJSON()).replaceAll('"([^"]+)":', '"' + '$1":'));
        System.debug('Request body: ' + req.getBody());
        System.debug('Request endpoint: ' + req.getEndpoint());
        HttpResponse res;
        GNE_SFA2_SBC_Profiler.logActionStart('SolrSearch.ServiceCallout');
        try {
            res = h.send(req);
        } finally {
            GNE_SFA2_SBC_Profiler.logActionEnd('SolrSearch.ServiceCallout');
        }
        System.debug('intSearchUserSolr response ' + (res != null ? res.getBody() : 'null'));
        SolrServiceResponse ssResponse;
        if (res.getStatusCode() == 200) {
            GNE_SFA2_SBC_Profiler.logActionStart('SolrSearch.PrepareResults');

            try {
//                String bodyInJSON = res.getBody().replaceAll('"' + '([^"]+)":', '"$1":');
                String bodyInJSON = res.getBody();
                System.debug(bodyInJSON);
                GNE_SFA2_SBC_DAO.PaginationResponse paginationResponse;
                ssResponse = (SolrServiceResponse) JSON.deserialize(bodyInJSON, SolrServiceResponse.class);
                if (ssResponse == null) {
                    throw new GNE_SFA2_SBC_DAO.ServiceException('No response for ||' + JSON.serialize(ssRequest.toJSON()), 200, restMethod);
                } else if (ssResponse.error != null) {
                    String message = String.isNotBlank(ssResponse.error.message) ? ssResponse.error.message : '';
                    Integer code = String.isNotBlank(ssResponse.error.code) ? Integer.valueOf(ssResponse.error.code) : 500;

                    if (!Pattern.matches('(?i)^\\s*(there are ){0,1}no records with provided.*$', message)) {
                        throw new GNE_SFA2_SBC_DAO.ServiceException(ssResponse.error.message, code, restMethod);
                    }
                } else if (ssResponse.records != null) {
                    paginationResponse = ssResponse.getPaginationResponse();
                }
                paginationData = new GNE_SFA2_SBC_DAO.PaginationDataWrapper(paginationResponse, pageSize);
                paginationData.tokenId = 'solr';
                GNE_SFA2_SBC_Profiler.setSiperianData(paginationData.size, paginationData.totalSize, paginationData.pageNumber, paginationData.pageSize, paginationData.pageTotalCount, paginationData.queryMore);
            } finally {
                GNE_SFA2_SBC_Profiler.logActionEnd('SolrSearch.PrepareResults');
            }
        } else {
            String status = res.getStatus();
            Integer statusCode = res.getStatusCode();
            throw new GNE_SFA2_SBC_DAO.ServiceException(status, statusCode, restMethod);
        }
        return ssResponse;
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

    private class SolrServiceRequest {
        private SearchParams searchParams;
        private Integer recordsToReturn;
        private GNE_SFA2_SBC_DAO.PaginationRequest paginationRequest;

        private SolrServiceRequest(SearchParams searchParams, Integer recordsToReturn, GNE_SFA2_SBC_DAO.PaginationRequest paginationRequest) {
            this.searchParams = searchParams;
            this.recordsToReturn = recordsToReturn;
            this.paginationRequest = paginationRequest;
        }

        private Map<String, Object> toJSON() {
            return searchParams.toMap();
        }

        Integer getOffset() {
            Integer result = 0;
            if (paginationRequest != null) {
                result = paginationRequest.getRecordStartNumber();
            }
            return result;
        }
    }

    public class SolrServiceResponse {
        private String status;
        private Integer numFound;
        private Integer start;
        private SolrError error;
        private String[] suggestedKeywords;
        private UserInfo[] records;

        public SolrServiceResponse() {

        }

        public String getStatus() {
            return status;
        }

        public Integer getNumberOfFoundRecords() {
            return numFound;
        }
        public Integer getStart() {
            return start;
        }
        public SolrError getError() {
            return error;
        }
        public String[] getSuggestedKeywords() {
            return suggestedKeywords;
        }

        public UserInfo[] getUsers() {
            return records;
        }

        public GNE_SFA2_SBC_DAO.PaginationResponse getPaginationResponse() {
            Boolean hasMore = numFound > start + records.size();
            return new GNE_SFA2_SBC_DAO.PaginationResponse(String.valueOf(hasMore), 'solrUsers', String.valueOf(numFound), String.valueOf(start + records.size()), String.valueOf(start), String.valueOf(records.size()));
        }
    }

    public class UserInfo extends iPhone_Commons_gne.RestRecord {
        private String userId;
        private String unixId;
        private String firstName;
        private String middleName;
        private String lastName;
        private String fullName;
        private String email;
        private String userType;

        private String userRole;
        private String mobilePhone;
        private String officePhone;
        private String jobTitle;
        private String attribute1;
        private String attribute2;
        private String reportsToUserId;
        private String reportsToUserUnixId;
        private String reportsToUserEmail;
        private String regionCode;
        private String regionName;
        private String team;

        private String reportsToUserFirstName;
        private String reportsToUserMiddleName;
        private String reportsToUserLastName;

        private String territory;
        private String businessUnit;
        private String zipCode;
        private String state;
        private String city;

        public UserInfo() {

        }
    }

    public class SearchParams {
        public String fullName;
        public String[] unixId;
        public String territoryCode;
        public String businessUnit;
        public String zipCode;
        public String state;
        public String city;
        public String regionCode;
        public String userRole;
        public String team;
        public String fieldForceType;

        private Map<String, Object> toMap() {
            System.debug(JSON.serialize(this, true));
            return (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(this, true));
        }
    }

    private class SolrError {
        private String status;
        private String message;
        private String code;
        private UserInfo[] records;
    }

}