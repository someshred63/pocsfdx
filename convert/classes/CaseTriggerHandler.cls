/**********************************************************************************************************************
Purpose: CaseTriggerHandler class is used to implement the business logic on DML events.
=======================================================================================================================
History                                                            
-------                                                            
VERSION  AUTHOR        DATE            DETAIL                       
1.0     Raheem       07/07/2020      INITIAL DEVELOPMENT
            
***********************************************************************************************************************/
public with sharing class CaseTriggerHandler {

    private static Boolean isBeforeUpdate = false;
    private static Boolean isAfterUpdate = false;
    /*********************************************************************************************
     Purpose: This method accepts the list of cases and process the before insert business logic
    **********************************************************************************************/    
    public void onBeforeInsert(List<Case> caseList){
        assignContactOnGCSCases(caseList);
    }

    public void onBeforeUpdate(List<Case> caseList, Map<Id,Case> oldCaseMap, Map<Id,Case> CaseMap){
        if(!isBeforeUpdate){
            updateCaseStatus(caseList, oldCaseMap);        
        }
        isBeforeUpdate = true;
     
    }

    public void onAfterUpdate(List<Case> caseList, Map<Id,Case> oldCaseMap, Map<Id,Case> CaseMap){
        if(!isAfterUpdate){
            sendNotifcationToUser(caseList, oldCaseMap);
            sendNotifcationToUserWhenVoiceCallRecived(caseList);
        }
      
    }
    public void onAfterInsert(List<Case> caseList){
       
    }
    /*********************************************************************************************
     Purpose: This method accepts the list of cases and identify the GCS case and assign the GCS 
     Contact on case base on the email address.
    **********************************************************************************************/    
   private void assignContactOnGCSCases(List<Case> CaseList){
        String GCSCaseRecTypeId = GCS_Util.getCaseReocrdTypeId(GCS_Util.GCS_CASE_RECORDTYPE_DEV_NAME);
        system.debug('GCSCaseRecTypeId-------'+GCSCaseRecTypeId);
        Set<String> emailAddresses = new Set<String>();
                
        for (Case caseObj:CaseList) {             
            if(caseObj.RecordTypeId == GCSCaseRecTypeId){ 
                if(caseObj.Origin == GCS_Util.GCS_CASE_ORIGIN_EMAIL && String.isNotBlank(caseObj.SuppliedEmail)){
                    emailAddresses.add(caseObj.SuppliedEmail); 
                }
                //capture the reviewed date
                if(caseObj.OwnerId != null && String.valueOf(caseObj.OwnerId).startsWith(GCS_Util.USER_ID_PREFIX)){
                    caseObj.GCS_Date_Reviewed__c = Date.today();
                }
            }
        }
        Map<String,Contact> contactMap = new Map<String,Contact>();

        if(!emailAddresses.isEmpty()){
            List<Contact> contactList = [Select Id, Email, GCS_Case_Priority__c From Contact Where Email in:emailAddresses AND RecordType.DeveloperName =: GCS_Util.GCS_CONTACT_RECORDTYPE_DEV_NAME];
            if(!contactList.isEmpty()){
                for(Contact contactObj : contactList){
                    if(String.isNotBlank(contactObj.Email)){
                        contactMap.put(contactObj.Email.toLowerCase(),contactObj);
                    }
                }
            }
        }else{
            return;
        }

        for (Case caseObj: CaseList) {  
            if(caseObj.RecordTypeId == GCSCaseRecTypeId && caseObj.Origin == GCS_Util.GCS_CASE_ORIGIN_EMAIL &&
                String.isNotBlank(caseObj.SuppliedEmail)){       
                if(contactMap.containsKey(caseObj.SuppliedEmail.toLowerCase())){
                    system.debug('-------Assignment-------');
                    caseObj.ContactId = contactMap.get(caseObj.SuppliedEmail.toLowerCase()).id;
                    if(String.isNotBlank(contactMap.get(caseObj.SuppliedEmail.toLowerCase()).GCS_Case_Priority__c)){
                        caseObj.Priority = contactMap.get(caseObj.SuppliedEmail.toLowerCase()).GCS_Case_Priority__c;
                    }
                }else{
                    caseObj.ContactId = null;
                }
            }
        }        
    }

    private void updateCaseStatus(List<Case> caseList, Map<Id, Case> caseOldMap){
        String GCSCaseRecTypeId = GCS_Util.getCaseReocrdTypeId(GCS_Util.GCS_CASE_RECORDTYPE_DEV_NAME);
        system.debug('GCSCaseRecTypeId-------'+GCSCaseRecTypeId);
        for (Case caseObj:CaseList) {             
            if(caseObj.RecordTypeId == GCSCaseRecTypeId){
                system.debug('caseObj.IsEscalated -------'+caseObj.IsEscalated );
                system.debug('caseObj.Status -------'+caseObj.Status );
                system.debug('caseOldMap.get(caseObj.Id).Status -------'+ caseOldMap.get(caseObj.Id).Status);
                if(caseObj.IsEscalated && caseOldMap.get(caseObj.Id).Status != GCS_Util.GCS_CASE_STATUS_ALERT){
                    caseObj.Status = GCS_Util.GCS_CASE_STATUS_ALERT;
                    system.debug('caseObj.ownerId -------'+ caseObj.ownerId );
                    system.debug('caseObj.OldownerId -------'+ caseOldMap.get(caseObj.Id).OwnerId);

                    if(caseObj.ownerId != caseOldMap.get(caseObj.Id).OwnerId){
                        caseObj.ownerId = caseOldMap.get(caseObj.Id).OwnerId;
                    }
                }else if(caseOldMap.get(caseObj.Id).Status == GCS_Util.GCS_CASE_STATUS_ALERT && caseOldMap.get(caseObj.Id).Status != caseObj.Status){
                    system.debug('In else if loop caseOb.Status -------'+ caseObj.Status);
                    caseObj.isEscalated = false;
                } 
                
                //capture the reviewed date
                if(caseObj.OwnerId != null && String.valueOf(caseOldMap.get(caseObj.Id).OwnerId).startsWith(GCS_Util.GROUP_ID_PREFIX) && String.valueOf(caseObj.OwnerId).startsWith(GCS_Util.USER_ID_PREFIX)){
                    caseObj.GCS_Date_Reviewed__c = Date.today();
                }
            }
        }        
    }

    /**  Purpose: Send notification to User when case Escalated equals True **/
    private void sendNotifcationToUser(List<Case> CaseList, Map<Id, Case> caseOldMap){
      
        Id notificationTypeId = GCS_Util.getCustomNotificationTypeId();
        if(notificationTypeId == null){
            return;
        }
        Id GCSCaseRecTypeId = GCS_Util.getCaseReocrdTypeId(GCS_Util.GCS_CASE_RECORDTYPE_DEV_NAME);
        
        try{
            for (Case caseObj:CaseList) {
                Messaging.CustomNotification notification = null; 
                if(caseObj.RecordTypeId == GCSCaseRecTypeId && caseObj.IsEscalated &&
                caseObj.Status == GCS_Util.GCS_CASE_STATUS_ALERT && caseObj.Status != caseOldMap.get(caseObj.Id).Status
                && caseObj.OwnerId != null && String.valueOf(caseObj.OwnerId).startsWith(GCS_Util.USER_ID_PREFIX)){
                    notification = new Messaging.CustomNotification();
                    // Set the contents for the notification
                    notification.setTitle('Case Alert');
                    notification.setBody( caseObj.CaseNumber + 'case status has changed to Alert. Please look into this case.');

                    // Set the notification type and target
                    notification.setNotificationTypeId(notificationTypeId);
                    notification.setTargetId(caseObj.Id); 
                }else if(caseObj.RecordTypeId == GCSCaseRecTypeId && caseObj.Origin == GCS_Util.GCS_CASE_ORIGIN_EMAIL &&
                        caseObj.GCS_Email_Status__c == GCS_Util.GCS_CASE_EMAIL_STATUS_NEW && caseObj.OwnerId != null &&
                        String.valueOf(caseObj.OwnerId).startsWith(GCS_Util.USER_ID_PREFIX)){
                    notification = new Messaging.CustomNotification();
                    // Set the contents for the notification
                    notification.setTitle('New email on Case '+ caseObj.CaseNumber);
                    notification.setBody( caseObj.Subject);
    
                    // Set the notification type and target
                    notification.setNotificationTypeId(notificationTypeId);
                    notification.setTargetId(caseObj.Id);     
                }
                if(notification != null){
                    notification.send(new Set<String>{caseObj.OwnerId});
                    isAfterUpdate = true;
                }
            }       
        }catch(Exception e){
            System.debug('Exception in sendNotifcationToUser method CaseTriggerHandler Class'+e);
        }
    }
    private void sendNotifcationToUserWhenVoiceCallRecived(List<Case> CaseList){
        set<String> userIds = new set<String>();
        Id notificationTypeId = GCS_Util.getVoiceCustomNotificationTypeId();
        
        if(notificationTypeId == null){
            return;
        }
        Id GCSCaseRecTypeId = GCS_Util.getCaseReocrdTypeId(GCS_Util.GCS_CASE_RECORDTYPE_DEV_NAME);
     
        Group gp = [SELECT (SELECT UserOrGroupId FROM GroupMembers) FROM Group WHERE Name = 'GCS General Queue'];
        
        for (GroupMember gm : gp.GroupMembers) {
            userIds.add(gm.UserOrGroupId);
        }
        List<User> userList = [SELECT Id,Email FROM User WHERE Id IN :userIds];
        try{
            for (Case caseObj:CaseList) {
                Messaging.CustomNotification notification = null; 
                 system.debug('CaseList'+CaseList);
                 if(caseObj.RecordTypeId == GCSCaseRecTypeId &&
                     caseObj.Origin =='Phone' && caseObj.Voicemail_Link__c !=null){
                      notification = new Messaging.CustomNotification();   
                      notification.setTitle('Case Voice Mail Alert');
                      notification.setBody( caseObj.CaseNumber + ' Voice Mail Recived. Please look into this case.');
                      
                      // Set the notification type and target
                      notification.setNotificationTypeId(notificationTypeId);
                      notification.setTargetId(caseObj.Id);   
                  }
                system.debug('notification'+notification);
                 if(notification != null){
                    notification.send(userIds);
                     system.debug('notification'+notification);
                }
            }
        }catch(Exception e){
            System.debug('Exception in sendNotifcationToUser method CaseTriggerHandler Class'+e);
            system.debug('lineNumber'+e.getLineNumber());
            system.debug('lineNumber'+e.getMessage());
        }
    }
}