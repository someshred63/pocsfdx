@RestResource(urlMapping='/AP/getAppData/*')
global without sharing class GNE_AP_GetAppData_Webservice {
	
	@HttpPost 
    global static RestResponse processRequest(String unixId) {
        RestResponse response = new RestResponse();
        try {            
            response.addResults('COSResources', getCOSResourcesDocumentsInfo());
            response.setSuccessStatus();
        } catch (Exception ex) {
            response.setErrorStatus(ex);
        }
        return response;
    }
    
    private static List<COSResourceDocument> getCOSResourcesDocumentsInfo(){
    	List<COSResourceDocument> cosDocuments = new List<COSResourceDocument>();
    	
    	for (Document doc : GNE_AP_COS_Resources_Controller.getAvailableCOSDocuments()){
    		cosDocuments.add(new COSResourceDocument(doc.Id, doc.Name));
    	}
    	
    	return cosDocuments;
    }
    
    public class COSResourceDocument extends RestResponseRecord {
    	public String Name { get; private set; }
    	
    	public COSResourceDocument(Id docId, String docName){
    		Id = docId;
    		this.Name = docName;
    	}
    }
               
    global class RestResponse {
        public Boolean success = false;
        public ExceptionInfo error;     
        public Map<String, String> debugInfo { get; private set; }
        public Map<String, List<RestResponseRecord>> records { get; private set; }
        
        public RestResponse(){
        	this.debugInfo = new Map<String,String>();
        	this.records = new Map<String, List<RestResponseRecord>>();
        }
        
        public void addResults(String responseName, List<RestResponseRecord> responseRecords){
        	if (String.isNotBlank(responseName)){        		
        		this.records.put(responseName, responseRecords);
        	}
        }
        
        public void setSuccessStatus() {    
            this.success = true;
            setDebugInfo();                                    
        }
        
        public void setErrorStatus(Exception ex) {      
            this.success = false;
            
            if (this.records != null){
            	for (String key : this.records.keyset()){
            		if (this.records.get(key) != null){
            			this.records.get(key).clear();
            		}
            	}
            	this.records.clear();
            }
                        
            setDebugInfo();                                                
            this.error = new ExceptionInfo(ex);
        }
        
        private void setDebugInfo(){
        	this.debugInfo.put('scriptStatements', Limits.getScriptStatements() + '/' + Limits.getLimitScriptStatements());
            this.debugInfo.put('queryStatements', Limits.getQueries() + '/' + Limits.getLimitQueries());
            this.debugInfo.put('queryRows', Limits.getQueryRows() + '/' + Limits.getLimitQueryRows());
            this.debugInfo.put('dmlStatements', Limits.getDmlStatements() + '/' + Limits.getLimitDmlStatements());
            this.debugInfo.put('dmlRows', Limits.getDmlRows() + '/' + Limits.getLimitDmlRows());
            this.debugInfo.put('cpuTime', Limits.getCpuTime() + '/' + Limits.getLimitCpuTime());         
        }                           
    }
    
    public virtual class RestResponseRecord {
    	public String Id { get; set; }
    	
    	public RestResponseRecord(){}
    }
    
    public class ExceptionInfo {
        public String stackTrace;
        public String typeName;
        public String cause;
        public Integer lineNumber;
        public String message;
        
        public ExceptionInfo(Exception ex) {
            Exception cEx = ex.getCause();            
            this.stackTrace = ex.getStackTraceString();
            this.typeName = ex.getTypeName();
            this.cause = cEx!=null ? cEx.getMessage() : '';
            this.lineNumber = ex.getLineNumber();
            this.message = ex.getMessage();
        }
    }      
}