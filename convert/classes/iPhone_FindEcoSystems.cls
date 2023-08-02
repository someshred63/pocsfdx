@RestResource(urlMapping='/OTR/findEcoSystems/*')
global class iPhone_FindEcoSystems {
    private static final Integer QUERY_LIMIT = 10000;
    @HttpPost
     global static iPhone_Commons_gne.RestResponse processPostRequest(EcoSystemPattern request) {
        return iPhone_Commons_gne.buildResponse(
                new SearchForEcoSystems(),
                new RequestArgs(request)
        );
    }
    
    class SearchForEcoSystems implements iPhone_Commons_gne.ResponseBuilder {
        public iPhone_Commons_gne.RestResponse build(Object args) {
            RequestArgs reqArgs = (RequestArgs)args;
            EcoSystemPattern searchParams = reqArgs.request;
            String query = buildQuery(searchParams);
            System.debug(query);
            return new RecordsResponse(Database.query(query));
        }
        
    }
    
    public class RecordsResponse extends iPhone_Commons_gne.RestResponse {
        public List<Ecosystem_Details_gne__c> result; 
        public RecordsResponse(List<Ecosystem_Details_gne__c> result) {
            this.result = result;
        }
    }
    
    public class RequestArgs extends iPhone_Commons_gne.DeltaArgs {
        public EcoSystemPattern request;
        public RequestArgs(EcoSystemPattern request) {
            super(null, getUnixId(UserInfo.getUserId()), null, null, null);
            this.request = request;
        }
    }
    
    global class EcoSystemPattern {
        public String ecoCode;
        public String ecoName;
        public String zipCode;
        public String city;
        public String state;  
        public Integer recordLimit;
    }
    
    private static String getUnixId(String userId) {
        return [SELECT External_Id_gne__c FROM User WHERE Id = :userId LIMIT 1].External_Id_gne__c;
    }
    
    private static String buildQuery(EcoSystemPattern params) {
        String query = 'SELECT Id, ECO_CD_gne__c, ECO_City_gne__c, ECO_Name_gne__c, ECO_State_gne__c, ECO_ZIP_Code_gne__c  FROM Ecosystem_Details_gne__c WHERE Is_Valid_gne__c=true {0} ';
        String whereClause = '';
        if(String.isNotBlank(params.ecoCode)) {
            whereClause += ' ECO_CD_gne__c=\''+params.ecoCode + '\' AND';
        }
        if(String.isNotBlank(params.ecoName)) {
            whereClause += ' ECO_Name_gne__c=\''+params.ecoName + '\'AND';
        }
        if(String.isNotBlank(params.zipCode)) {
            whereClause += ' ECO_ZIP_Code_gne__c=\''+params.zipCode + '\' AND';
        }
        if(String.isNotBlank(params.city)) {
            whereClause += ' ECO_City_gne__c=\''+params.city + '\' AND';
        }
        if(String.isNotBlank(params.state)) {
            whereClause += ' ECO_State_gne__c=\''+params.state + '\' AND';
        }
        whereClause = whereClause.removeEnd('AND');
        if(String.isNotBlank(whereClause)) whereClause = ' AND ' +whereClause ;
        if (params.recordLimit != null ) {
            params.recordLimit = params.recordLimit > QUERY_LIMIT ? QUERY_LIMIT : params.recordLimit;
        } else {
            params.recordLimit = QUERY_LIMIT;
        }
        whereClause += ' LIMIT '+params.recordLimit;
        
        return String.format(query, new List<String> {whereClause});
    }

}