global  with sharing class gFRS_ImedScopeChangeNotification implements Schedulable {
	global void execute(SchedulableContext sc){
        gFRS_ImedScopeChangeNotificationBatch notifications=new gFRS_ImedScopeChangeNotificationBatch();
        Database.executeBatch(notifications,10);
    }

}