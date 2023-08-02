public class GNE_ReltioCreateRequestDefaultImpl extends GNE_SchedulableInterface {
    public static void sendToReltio(String resource, String method, String body, String objId) {
        GNE_ScheduleQueuableClassUtility scheduleUtility = new GNE_ScheduleQueuableClassUtility('GNE_ReltioCreateRequestDefaultImpl', 0, objId, resource, method, body);
        scheduleUtility.scheduleQueuableClass();
    }
    
    public void execute(SchedulableContext context) {
        String scheduleInfoId = context.getTriggerId();
        List<GNE_Schedule_Information__c> scheduleInfo = [
            SELECT Id, Name, GNE_ReferenceRecord_ID__c, Request_Source__c, Request_Body__c, Request_Method__c
            FROM GNE_Schedule_Information__c 
            WHERE Name =:scheduleInfoId
        ];    
        try {
            createQueue( scheduleInfo[0]?.Request_Source__c, scheduleInfo[0]?.Request_Method__c, scheduleInfo[0]?.Request_Body__c, scheduleInfo[0]?.GNE_ReferenceRecord_ID__c );
        } catch (Exception e) {
            System.debug(e.getStackTraceString()); //add logger here
        } finally {
            delete scheduleInfo;
        }
    }
    
    public static void createQueue(String resource,String method, String body,  String objId) {
        System.enqueueJob(new GNE_ReltioCreateRequestDefaultImplQueue(resource, method, body, objId));
    }
}