public class Logger {

    public enum LogType {
        DEBUG, INFO, ERROR
    }

    private String className;

    private Logger(String className) {
        this.className = className;
    }

    public static Logger getInstance(String className) {
        return new Logger(className);
    }

    public void logException(String methodName, Exception e) {
        Log__e event = new Log__e();
        event.Title__c = e.getTypeName();
        event.Type__c = LogType.ERROR.name();
        event.UserName__c = UserInfo.getUserName();
        event.ApexClass__c = this.className;
        event.Description__c = e.getMessage();
        event.MethodName__c = methodName;
        event.StackTrace__c = e.getStackTraceString();
        EventBus.publish(event);
    }

    public void log(String methodName, String title, String message) {
        Log__e event = new Log__e();
        event.ApexClass__c = this.className;
        event.MethodName__c = methodName;
        event.Title__c = title;
        event.Type__c = LogType.INFO.name();
        event.UserName__c = UserInfo.getUserName();
        event.Description__c = message;
        EventBus.publish(event);
    }
}