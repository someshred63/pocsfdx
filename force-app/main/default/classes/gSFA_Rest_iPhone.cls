@RestResource(urlMapping='/gSFA_Rest_iPhone/*')
global with sharing class gSFA_Rest_iPhone {
	
	global class ResultSet {
        public Boolean success = false;
        public iPhone_REST_Utils.ExceptionInfo error;
        public Map<String, String> debugInfo = new Map<String,String>();
        public String recJSON;
        public transient DateTime startTimeStamp = System.now();
    }
	
	@HttpPost
    global static ResultSet executeQuery(String queryString) {    	
    	ResultSet result = new ResultSet();    	
    	try {
    		if (String.isNotBlank(queryString)){
            	List<SObject> records = Database.query(queryString);
            	result.recJSON = JSON.serializePretty(records);
            	result.success = true;
    		}
        } catch(Exception ex) {            
            result.error = new iPhone_REST_Utils.ExceptionInfo(ex);
        } finally {
        	if(result.debugInfo!=null) {
                result.debugInfo.put('scriptStatements', Limits.getScriptStatements() + '/' + Limits.getLimitScriptStatements());
                result.debugInfo.put('queryStatements', Limits.getQueries() + '/' + Limits.getLimitQueries());
                result.debugInfo.put('cpuTime', Limits.getCpuTime() + '/' + Limits.getLimitCpuTime());
                result.debugInfo.put('queryRows', Limits.getQueryRows() + '/' + Limits.getLimitQueryRows());
                result.debugInfo.put('execTime', String.valueOf(System.now().getTime() - result.startTimeStamp.getTime()));
            }
        }        
    	return result;        
    }
    
}