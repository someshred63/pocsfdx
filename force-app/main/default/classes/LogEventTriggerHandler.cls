public class LogEventTriggerHandler {

    public static void insertLogs(List<Log__e> logEvents) {
        List<Error_Log_gne__c> logs = new List<Error_Log_gne__c>();
        for (Log__e event : logEvents) {
            logs.add(getErrorLogRecord(event));
        }
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.allowFieldTruncation = true;
        dml.optAllOrNone = false;
        Database.insert(logs, dml);
    }

    private static Error_Log_gne__c getErrorLogRecord(Log__e logEvent) {
        Error_Log_gne__c errorLog = new Error_Log_gne__c();
        errorLog.Error_Description__c = logEvent.Description__c;
        errorLog.Error_Level_gne__c = logEvent.Type__c == Logger.LogType.ERROR.name() ? 'High' : 'Low';
        errorLog.Apex_Class__c = logEvent.ApexClass__c;
        errorLog.Stack_Trace__c = logEvent.StackTrace__c;
        errorLog.User_Name__c = logEvent.UserName__c;
        errorLog.Snippet_Name__c = logEvent.MethodName__c;
        errorLog.Login_Time__c = System.now();
        errorLog.Code_Type__c = 'Apex Class';
        return errorLog;
    }
}