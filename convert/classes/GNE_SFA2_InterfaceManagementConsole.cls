/*
 * TODO add logic to dispaly US OR Canada only
 */
global class GNE_SFA2_InterfaceManagementConsole {    
    public String classToRun {get;set;} 
    public Integer recordSize {get;set;}
    
    private static String myURL = URL.getSalesforceBaseUrl().getHost();
    private static final String PREFIX_OBJ_QUERY = 'SELECT Id FROM ';
    private static final String PREFIX_COUNT_QUERY = 'SELECT+Count()+FROM+';       
    private static final String STATUS_SUCCESS = 'Success';
    private static final String STATUS_ERROR = 'Error';
    private static final String LAST_BATCH_QUERY = 'SELECT CreatedDate, CompletedDate FROM AsyncApexJob  WHERE ApexClass.Name = \'######\' AND ParentJobId = null AND Status = \'Completed\' AND JobType = \'BatchApex\' ORDER BY CompletedDate DESC LIMIT 1';
    private static final String CONFIGURATION_QUERY = 'SELECT Batch_Class_Name__c, Console_Page__c, Count_Query__c, Country__c, Main_Object_Query__c, MasterLabel, Object_API_Name__c, Runable__c, Operating_Mode__c, KeyAndOrder__c,Last_Execute_Query__c FROM GNE_Interface_Management__mdt ';
    private static final String LAST_EXECUTE_QUERY = 'SELECT LastModifiedDate FROM '; 
    private Map <Decimal, BatchWrapper> mapWrappers = new Map <Decimal, BatchWrapper> ();
    private Map<String, CountryWrapper> country2CW = new Map<String, CountryWrapper>();
    public Map<Integer, Decimal> order2configKey{get;set;}
    public String jsonMap{get;set;} 

    private List<GNE_Interface_Management__mdt>  configurationData;
           
    private List<GNE_Interface_Management__mdt> getConfigurationData() {
        if(configurationData == null){
            configurationData = DataBase.query(CONFIGURATION_QUERY + ' WHERE isActive__c = true ORDER BY KeyAndOrder__c');
        }
        return configurationData;
    }       
    
    public GNE_SFA2_InterfaceManagementConsole() {
        createObjectsToDisplay();
        dispachObjectsToContry();    
        recordSize = mapWrappers.size();
        jsonMap = JSON.serialize(order2configKey);
    }
    
    public PageReference runBatch() {
        Type customType = Type.forName(classToRun);
        IBatch instance;
        try{
            Type t = Type.forName(classToRun);
            instance = (IBatch)t.newInstance();
            instance.runCustomLogic(); 
        }catch(Exception ex){
            System.debug(':: Exception '+ex.getMessage());
        }    
        
        return null;        
    }
        
    private void dispachObjectsToContry() {
        for(BatchWrapper bw : mapWrappers.values()){
            if(country2CW.get(bw.country) == null){
                CountryWrapper cw = new CountryWrapper();
                cw.countryKey = bw.country;
                cw.wrappers = new BatchWrapper[]{};
                country2CW.put(bw.country, cw);
            }
            CountryWrapper cw = country2CW.get(bw.country);
            cw.wrappers.add(bw);
        }
    }
    
    private static QueryResponse getApiResponse(String countQuery) {
        QueryResponse response = new QueryResponse();

        try{
            HttpRequest req = new HttpRequest();
            countQuery = countQuery.replace(' ','+');
            countQuery = countQuery.replace('%', '%25');
                                   
            req.setEndpoint('https://'+URL.getSalesforceBaseUrl().getHost()+'/services/data/v41.0/query/?q='+countQuery);
            req.setMethod('GET');
            String autho = 'Bearer '+ UserInfo.getSessionId();
            req.setHeader('Authorization', autho);
            req.setTimeout(120000);
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug(' :: API RESPONSE :: '+res.getBody());
			response.response = res.getBody();
            if(res.getStatusCode() == 200){
                response.status = STATUS_SUCCESS; 
            } else {
                response.status = STATUS_ERROR;
            }
        } catch (Exception ex) {
            response.status = STATUS_ERROR;
            response.excep = ex.getMessage();
        }
         
        return response ;
    }
    
    public class QueryResponse {
        public String status {get;set;}
        public String response {get;set;}
        public String excep {get;set;}
        public QueryResponse(){
            status = '';
            response = '';
        }
    }
    
    private void createObjectsToDisplay() {
        Integer order = 1;
        order2configKey = new Map<Integer, Decimal>();
        for(GNE_Interface_Management__mdt mdt : getConfigurationData()) {
            BatchWrapper nsbw = new BatchWrapper(mdt,order);
            nsbw.waitnigForProces = '<img class="waitingImage" src="/img/loading.gif" title="refreshing..." />';
            nsbw.lastRun = '<img class="waitingImage" src="/img/loading.gif" title="refreshing..." />';
            nsbw.isActionVisible = false;
            nsbw.updateDetails();

            if(nsbw.runable != null){
                nsbw.isActionVisible |= nsbw.runable;
            }

            mapWrappers.put(nsbw.wrapperId, nsbw);
            order2configKey.put(order, nsbw.wrapperId);
            order++;
        }
    }
    
    public CountryWrapper[] getObjectsToDisplay() {        
        return country2CW.values();
    }
    
    @remoteAction
    public static String getBatchResponse(Integer param){        
        return fetchAsyncApexJob(param, true); 
    } 
    
    private static String fetchAsyncApexJob(Integer param, Boolean isLastRun) {
        GNE_Interface_Management__mdt[] config = DataBase.query(CONFIGURATION_QUERY + ' WHERE KeyAndOrder__c = '+param);
        String resp = '----';
        if(!config.isEmpty()){  
            ApiResponse apiResp;
            if(String.isNotBlank(config[0].Batch_Class_Name__c)){
                String batchQuery = LAST_BATCH_QUERY.replace('######', config[0].Batch_Class_Name__c);
                QueryResponse qResp = getApiResponse(batchQuery);
                if(qResp.status == STATUS_SUCCESS){
                    apiResp = (ApiResponse) JSON.deserialize(qResp.response, ApiResponse.class);                    
                    if(apiResp.totalSize > 0){
                        if(isLastRun) {
                            resp = String.valueOf(apiResp.records[0].CompletedDate); 
                        } else {
                            resp = String.valueOf(apiResp.records[0].CreatedDate); 
                        }          
                    } 
                }
            } 
            Boolean runNextQuery = String.isBlank(config[0].Batch_Class_Name__c) || apiResp.totalSize  == 0;
            if(String.isNotBlank(config[0].Last_Execute_Query__c) && runNextQuery) {
                String queryToExecute = LAST_EXECUTE_QUERY + config[0].Last_Execute_Query__c;
                QueryResponse qResp = getApiResponse(queryToExecute);
                if(qResp.status == STATUS_SUCCESS){
	                apiResp = (ApiResponse) JSON.deserialize(qResp.response, ApiResponse.class);
	                if(apiResp.totalSize > 0){
	                    resp = String.valueOf(apiResp.records[0].LastModifiedDate );                        
	                } 
                }
            }
        }
        
        return resp ;
        
    }
    
    @remoteAction
    public static String getQueryResponse(Integer param){       
        String result = '----';
        GNE_Interface_Management__mdt[] config = DataBase.query(CONFIGURATION_QUERY + ' WHERE KeyAndOrder__c = '+param);
        if(!config.isEmpty()){
            System.debug(config[0].Count_Query__c);
            if(String.isNotBlank(config[0].Count_Query__c)){
                String query = config[0].Count_Query__c;
                if(query.contains('::LASTRUN::')){
                    String lastRuned = fetchAsyncApexJob(param, true);
                    try{
                        DateTime dt = DateTime.valueOf(lastRuned);
                        String dateTimeFormat = dt.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                        query = query.replace('::LASTRUN::', dateTimeFormat);
                    } catch (Exception ex){
                        System.debug('Exception :: ' + ex.getMessage());
                        return 'Please run batch';
                    }
                    
                }
                QueryResponse resp = getApiResponse(PREFIX_COUNT_QUERY + query);
                if(resp.status == STATUS_SUCCESS){
                    ApiResponse apiResp = (ApiResponse) JSON.deserialize(resp.response, ApiResponse.class);
                	result = apiResp.totalSize != null ? String.valueOf(apiResp.totalSize) : 'unknown respones' ;
                } else {
                    result = resp.excep != null ? resp.excep : resp.status;
                }
            } else {
                result = 'No query in conf';
            }
        }
        
        return result;
    } 
    
    public class ApiResponse{
        Integer totalSize;
        Boolean done;
        APIRecord [] records;
    }
    
    public class APIRecord{
        DateTime CreatedDate;
        DateTime LastModifiedDate;
        DateTime CompletedDate;
    }
    
    public class CountryWrapper{
        public String countryKey {get;set;}
        public BatchWrapper[] wrappers {get;set;}
        public Integer listSize {get;set;}
    }
    
    public class BatchWrapper {
        public Boolean runable {get;set;}    //it means we can run the batchclasss
        public Boolean isActionVisible {get;set;}    
        public Boolean hasConsole {get;set;}  
        public String consolePage {get;set;}
        public String batchclasss {get;private set;}  
		public Decimal wrapperId {get;private set;}
        public Integer order {get;private set;}

        public String country  {get;set;}
        public String interfaceName {get;set;}
        public String operatingMode {get;set;}
        public String details {get;set;}   
        public String actionDetails {get;set;}  

        public String lastRun {get;set;}  
        public String waitnigForProces {get;set;}  
        private String countQuery;
        private String mainObjectQuery;
        private String sObjectApiName;  
        public String urlToPageDetail  {get;set;}  
        
        public BatchWrapper(){}
        
        public BatchWrapper(GNE_Interface_Management__mdt mdtConfiguration, Integer order){
            wrapperId = mdtConfiguration.KeyAndOrder__c;
            runable = mdtConfiguration.Runable__c;
            consolePage = mdtConfiguration.Console_Page__c;
            country = mdtConfiguration.Country__c;      
            interfaceName = mdtConfiguration.MasterLabel;
            operatingMode = mdtConfiguration.Operating_Mode__c;
            consolePage = mdtConfiguration.Console_Page__c;
            mainObjectQuery = mdtConfiguration.Main_Object_Query__c;
            countQuery = mdtConfiguration.Count_Query__c;
            sObjectApiName = mdtConfiguration.Object_API_Name__c;
            this.order = order;   
            batchclasss = mdtConfiguration.Batch_Class_Name__c;
        }
        
               
        private void updateDetails() {
            if(details == null)details='';
            //case : hase console page
            if(consolePage != null) {
                details += '<a href="https://'+myURL+'/apex/'+consolePage+'" target="blank">Open Detail Page</a>';
                urlToPageDetail = '/apex/'+consolePage;
            } else if(mainObjectQuery != null){
                try{  
                    sObject [] records = Database.query(PREFIX_OBJ_QUERY + mainObjectQuery);
                    if(hasConsole != null && hasConsole){                        
                        String myIdPrefix = String.valueOf(records[0].Id).substring(0,3);
                        urlToPageDetail = '/'+myIdPrefix;                        
                    } else {                        
                    	urlToPageDetail = '/'+records[0].Id;
                    }
                } catch (QueryException ex) {
                    system.debug(ex.getMessage());
                }                  
            } else if(String.isNotEmpty(sObjectApiName)) {
                try{
                    Schema.SObjectType convertType = Schema.getGlobalDescribe().get(sObjectApiName);
                    String prefixID = convertType.getDescribe().getKeyPrefix();
                    urlToPageDetail= '/'+prefixID;
                }catch(Exception ex){
                    system.debug(ex.getMessage());
                }                 
            }
        }
    }
}