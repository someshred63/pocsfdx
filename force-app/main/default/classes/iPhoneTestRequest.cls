@RestResource(urlMapping='/iPhoneTestRequest/*')
global with sharing class iPhoneTestRequest {
	global class RestResponse extends iPhone_Commons_gne.RestResponse {}
	
	@HttpPost
	global static RestResponse testRequest(String errorLogId, String requestClassName, String requestJSON) {
		RestResponse result = new RestResponse();
		iPhone_Commons_gne.setStartTimeStamp();
		try {
			if(String.isNotBlank(requestClassName) && String.isNotBlank(requestJSON)) {
				iPhoneBase.testRequest(requestJSON, System.Type.forName(requestClassName));
			} else if(String.isNotBlank(errorLogId)){
				iPhoneBase.testRequest((Id)errorLogId, requestJSON);
			}
			
			result.setSuccessStatus();
		} catch (Exception ex) {
			result.setErrorStatus(ex);
			result.debugInfo.put('cpuTime', Limits.getCpuTime() + '/' + Limits.getLimitCpuTime());
		}
		
		result.debugInfo.put('dmlStatements', Limits.getDmlStatements() + '/' + Limits.getLimitDmlStatements());
		result.debugInfo.put('dmlRows', Limits.getDmlRows() + '/' + Limits.getLimitDmlRows());
		
		return result;
	}
	
}