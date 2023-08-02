@RestResource(urlMapping='/iPhoneReportFailedRequest/*')
global with sharing class iPhone_Report_Failed_Request_gne {

@HttpPost
  global static iPhone_Commons_gne.RestResponse processRequest(String failedRequest, String serverResponse, String requestType, String requestSignature, String aocSignature, String iPhoneRequestId) {            
    return iPhone_Commons_gne.executeAlterData(
      new ReportFailedRequestExecutor(), 
      new ReportFailedRequestArgs(failedRequest, serverResponse, requestType, requestSignature, aocSignature, iPhoneRequestId)
    );
  }
  
  class ReportFailedRequestArgs implements iPhone_Commons_gne.BaseArgs {
    final String failedRequest;       
    final String serverResponse;
    final String requestType;
    final String requestSignature;
    final String aocSignature;
    final String iPhoneRequestId;
    
    public ReportFailedRequestArgs(String failedRequest, String serverResponse, String requestType, String requestSignature, String aocSignature, String iPhoneRequestId) {
      this.failedRequest = failedRequest;
      this.serverResponse = serverResponse;
      this.requestType = requestType;
      this.requestSignature = requestSignature;
      this.aocSignature = aocSignature;
      this.iPhoneRequestId = iPhoneRequestId;
    }

	public String getIPhoneRequestId(){
		return this.iPhoneRequestId;
	}
  }
  
  class ReportFailedRequestExecutor implements iPhone_Commons_gne.Runnable {
  
  public Object run(Object args) {
      ReportFailedRequestArgs rfrArgs = (ReportFailedRequestArgs)args;
      
      return this.saveData(rfrArgs);
    }
    
    private String saveData(ReportFailedRequestArgs rfrArgs) {
      GNE_iPhone_Failed_Request__c newObj = new GNE_iPhone_Failed_Request__c();
      
      newObj.Request_gne__c = rfrArgs.failedRequest;
      newObj.Response_gne__c = rfrArgs.serverResponse;
      newObj.iPhone_Request_Id_gne__c = rfrArgs.iPhoneRequestId;
      newObj.Request_Type_gne__c = rfrArgs.requestType;
      newObj.Request_Signature_gne__c = rfrArgs.requestSignature;
      newObj.AOC_Signature__c = rfrArgs.aocSignature;
      
      insert newObj;
      return newObj.id;
    }
  
  }

}