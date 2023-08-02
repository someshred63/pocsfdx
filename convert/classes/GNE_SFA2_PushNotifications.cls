global with sharing class GNE_SFA2_PushNotifications {
    private final static String MISSING_CONFIG_ERROR = 'Missing configuration for {0}, please report this issue to your application administarator.';
    private final static Id CHILD_RT = Schema.SObjectType.Sfa_Alert_gne__c.getRecordTypeInfosByName().get('Child Alert').getRecordTypeId();
    webservice static String sendPushNotification(Id objectId) {
        Sfa_Alert_gne__c recordToUpdate;
        Sfa_Alert_gne__c [] alerts = [
            SELECT Data__c,Description_gne__c, Title_gne__c, isAllUserNotification_gne__c, User_gne__c, Send_Date_gne__c, Send_To_Profiles__c, RecordTypeId
            FROM Sfa_Alert_gne__c
            WHERE Id  = :objectId
        ];
        if(alerts.isEmpty()) {
            return 'Unknown record for Id: '+objectId;
        } 
        recordToUpdate = alerts[0];
        if(recordToUpdate.Send_Date_gne__c != null){
            return 'Record already sent at ' + recordToUpdate.Send_Date_gne__c ;
        } 
        String bundleId = getBundleId();
        if(GNE_Foun_Misc_Config_Items_gne__c.getValues(bundleId.toUpperCase()) == null){
            return String.format(MISSING_CONFIG_ERROR, new String[]{'bundle id'});
        }
        if(GNE_Foun_Misc_Config_Items_gne__c.getValues('OTR_KEY_GOOGLEAPI') == null){
            return String.format(MISSING_CONFIG_ERROR, new String[]{'authorization'});
        }
        if(GNE_Foun_Misc_Config_Items_gne__c.getValues('OTR_ENDPOINT_GOOGLEAPI') == null){
            return String.format(MISSING_CONFIG_ERROR, new String[]{'endpoint'});
        }
        
        Notification notif = new Notification();
        notif.title = recordToUpdate.Title_gne__c != null ? recordToUpdate.Title_gne__c : 'Notification';
        notif.body = recordToUpdate.Description_gne__c != null ? recordToUpdate.Description_gne__c  : 'Missing notification text. Please report this issue to your administrator!';
        
        String result;
        String userID;
        
        if(recordToUpdate.isAllUserNotification_gne__c){
            userID = 'allUsers';
            result = sendNotification(userID, notif, recordToUpdate, bundleId, true);
        } else if(String.isNotBlank(recordToUpdate.User_gne__c)){
            try {
                userID = [SELECT External_ID_gne__c FROM User WHERE Id = : recordToUpdate.User_gne__c LIMIT 1].External_ID_gne__c;
                result = sendNotification(userID, notif, recordToUpdate, bundleId, true);
            } catch (QueryException ex) {
                return ex.getMessage();
            }
        } else if(String.isNotBlank(recordToUpdate.Send_To_Profiles__c)){
            createChildAlerts(recordToUpdate);
            GNE_SFA2_PushNotificationBatch batch = new GNE_SFA2_PushNotificationBatch(recordToUpdate);
            Database.executeBatch(batch, 5);
            result = 'Notifications created and will be send in background. Please refresh this page in few minutes and check related list';
        } else {
            return 'Missing Receiver';
        }

        return result;
    }    
    
    private static void createChildAlerts(Sfa_Alert_gne__c recordToUpdate) {
        Sfa_Alert_gne__c [] toInsert = new Sfa_Alert_gne__c[]{};
        for(String profile : recordToUpdate.Send_To_Profiles__c.split(';')){
            toInsert.add(createAlert(recordToUpdate, profile));
        }
        recordToUpdate.Send_Date_gne__c = System.now();
        toInsert.add(recordToUpdate);
        upsert toInsert;
    }
    
    private static Sfa_Alert_gne__c createAlert(Sfa_Alert_gne__c recordToUpdate, String profile) {
        return new Sfa_Alert_gne__c(
            Send_To_Profiles__c = profile,
            Description_gne__c = recordToUpdate.Description_gne__c,
            Title_gne__c = recordToUpdate.Title_gne__c,
            Alert__c = recordToUpdate.Id,
            RecordTypeId = CHILD_RT,
            Data__c = recordToUpdate.Data__c
        );
    }
    
    public static String sendNotification(String userID, Notification notif, Sfa_Alert_gne__c recordToUpdate, String bundleId, Boolean runDML) {
        PushNotification push = new PushNotification();
        push.to = '/topics/'+userID;
        push.priority = 'high';
        push.restricted_package_name = GNE_Foun_Misc_Config_Items_gne__c.getValues(bundleId.toUpperCase()).Configuration_Value_gne__c;
        push.notification = notif;
        if(String.isNotBlank(recordToUpdate.Data__c)){
            String trimed = recordToUpdate.Data__c.replaceAll('<[^>]+>',' ');
            trimed = trimed.replaceAll('\r','').replaceAll('\n','').replaceAll('\t','');
            trimed = trimed.trim();
            push.datax = JSON.deserializeUntyped(trimed);
        }
        
        String jsonStr = JSON.serialize(push);
        jsonStr = jsonStr.replace('"datax":', '"data":');
        System.debug('JSON :: '+jsonStr);
        
        String result;
        
        String url = GNE_Foun_Misc_Config_Items_gne__c.getValues('OTR_ENDPOINT_GOOGLEAPI').Configuration_Value_gne__c  ;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', GNE_Foun_Misc_Config_Items_gne__c.getValues('OTR_KEY_GOOGLEAPI').Configuration_Value_gne__c);
        req.setTimeout(120000);
        req.setBody(jsonStr);
        Http http = new Http();
        HttpResponse res;       
        res = http.send( req );
        
        if(res.getStatusCode() == 200){
            result = 'Notification send';
            recordToUpdate.Send_Date_gne__c = System.now();
            
        } else {
            result = res.getStatus();
        }
        
        recordToUpdate.Response_Status_gne__c = 'Status code: '+res.getStatusCode() + ':: Status: '+ res.getStatus();
        if(runDML)update recordToUpdate;
        
        return result;
    }
    
    public static String getBundleId() {
        String bundleName = 'OTR_BUNDLE_ID_GOOGLEAPI';
        if(isProductionEnv()){
            bundleName = 'PROD_'+bundleName;
        } else {
            String sandboxName = UserInfo.getUserName().substringAfterLast('.');
            bundleName = sandboxName + '_' + bundleName;
        }

        return bundleName;
    }
    
    private static Boolean isProductionEnv() {
        return ![SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    
    global class PushNotification{
        global String to;
        global String priority;
        global String restricted_package_name;
        global Notification notification;
        global Object datax;
    }
    
    global class Notification{
        global String title;
        global String body;
    }
}