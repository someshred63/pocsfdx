public class GNE_SFA2_PushNotificationBatch implements Database.Batchable<sObject>, Database.Stateful,  Database.AllowsCallouts {
    private Sfa_Alert_gne__c parentNotification;
    public GNE_SFA2_PushNotificationBatch(Sfa_Alert_gne__c parentNotification){
        this.parentNotification = parentNotification;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){  
        String query = 'SELECT Data__c, Description_gne__c, Title_gne__c, isAllUserNotification_gne__c, User_gne__c, Send_Date_gne__c, Send_To_Profiles__c, RecordTypeId '+
            'FROM Sfa_Alert_gne__c '+
            'WHERE Alert__c = \''+parentNotification.Id+'\'';

        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Sfa_Alert_gne__c> scope) {
        GNE_SFA2_PushNotifications.Notification notif = new GNE_SFA2_PushNotifications.Notification();
        notif.title = parentNotification.Title_gne__c != null ? parentNotification.Title_gne__c : 'Notification';
        notif.body = parentNotification.Description_gne__c != null ? parentNotification.Description_gne__c  : 'Missing notification text. Please report this issue to your administrator!';
        String bundleId = GNE_SFA2_PushNotifications.getBundleId();
        
        for(Sfa_Alert_gne__c alert : scope){
            String userID = String.isNotBlank(alert.Send_To_Profiles__c) ? alert.Send_To_Profiles__c.split(';')[0] : null;
            if(userID == null ){
                alert.Response_Status_gne__c = 'Empty profile';
                continue;
            }
            GNE_SFA2_PushNotifications.sendNotification(userID, notif, alert, bundleId, false);
            system.debug(alert);
        }
        update scope;
    }
    public void finish(Database.BatchableContext BC){}
}