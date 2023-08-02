global class SCM_WSLogger {
	@future
    public static void InsertLog(string MethodName, string Parameters){
   
  	SCM_WebServiceCallLogger__c log = new SCM_WebServiceCallLogger__c();
  	log.MethodName__c = MethodName;
  	log.Parameters__c = Parameters;
  	log.user__c = Userinfo.getUserId();
  	log.sessionID__c = Userinfo.getSessionId();
  	insert log;
  	system.debug('Inserted Log');
  }	
}