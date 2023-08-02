/************************************************************
*  @author: Michal Hrycenko
*  Date: 20/02/2014
*  Description: This class GNE_SFA2_Interaction_Adv_Future handles all future calls on Call2_vod__c object on DML operations. This class is being used in GNE_SFA2_Interaction_Trigger trigger.
*
*  Modification History
*  Date        Name        Description
*
*************************************************************/
public without sharing class GNE_SFA2_Interaction_Adv_Future {

    @TestVisible
    private static Set<String> additionalUserTerritoriesForTest = new Set<String>(); //DML not allowed on userterritory, and user chosen for tests may not have the test territory

    public static void onAfterInsert (List<Call2_vod__c> triggerNew) {
        if (!GNE_SFA2_Util.isMergeMode()) {
            if (GNE_SFA2_Interaction_Util.PARENT_CALL_UPDATE_MODE != true) {
                createGneNotificationsAfterInsert(triggerNew);
            }
            insertIndependentInsightsFuture(JSON.serialize(triggerNew));
            updateTSF(JSON.serialize(triggerNew), null, true, false, false);
        }
    }

    public static void onAfterUpdate (Map<Id,Call2_vod__c> triggerOldMap,  Map<Id,Call2_vod__c> triggerNewMap) {
        if (!GNE_SFA2_Util.isMergeMode()) {
            if (GNE_SFA2_Interaction_Util.PARENT_CALL_UPDATE_MODE != true) {
                createGneNotificationsAfterUpdate(triggerOldMap.values(), triggerNewMap.values());
            }
            updateIndependentInsightsFuture(JSON.serialize(triggerOldMap), JSON.serialize(triggerNewMap));
            updateTSF(JSON.serialize(triggerNewMap.values()), JSON.serialize(triggerOldMap.values()), false, true, false);

        }
    }

    public static void onAfterDelete (List<Call2_vod__c> triggerOld) {
        if (!GNE_SFA2_Util.isMergeMode()) {
            if (GNE_SFA2_Interaction_Util.PARENT_CALL_UPDATE_MODE != true) {
                createGneNotificationsAfterDelete(triggerOld);
            }
            updateTSF(null, JSON.serialize(triggerOld), false, false, true);
        }
    }

    private static void createGneNotificationsAfterInsert(List<Call2_vod__c> triggerNew) {
        createGneNotifications(JSON.serialize(triggerNew), true, false, false);
    }

    private static void createGneNotificationsAfterUpdate(List<Call2_vod__c> triggerOld, List<Call2_vod__c> triggerNew) {
        List<Call2_vod__c> callsToNotifications = new List<Call2_vod__c>();
        for (Integer i = 0; i < triggerNew.size(); i++) {
            if (String.isEmpty(triggerNew.get(i).Parent_Call_vod__c) && ((triggerNew.get(i).Attendees_vod__c != triggerOld.get(i).Attendees_vod__c) || (triggerNew.get(i).Call_Datetime_vod__c != triggerOld.get(i).Call_Datetime_vod__c) || (triggerNew.get(i).Interaction_Location_gne__c != triggerOld.get(i).Interaction_Location_gne__c) || (triggerNew.get(i).Address_vod__c != triggerOld.get(i).Address_vod__c))) {
                callsToNotifications.add(triggerNew.get(i));
            }
        }

        if (!callsToNotifications.isEmpty()) {
            createGneNotifications(JSON.serialize(callsToNotifications), false, true, false);
        }
    }

    private static void createGneNotificationsAfterDelete(List<Call2_vod__c> triggerOld) {
        List<Call2_vod__c> callsToNotifications = new List<Call2_vod__c>();
        for (Call2_vod__c call : triggerOld) {
            if (String.isEmpty(call.Parent_Call_vod__c))  {
                callsToNotifications.add(call);
            }
        }

        if (!callsToNotifications.isEmpty()) {
            createGneNotifications(JSON.serialize(callsToNotifications), false, false, true);
        }
    }

    private static void createGneNotifications(String calls, Boolean isInsert, Boolean isUpdate, Boolean isDelete) {
        if(!System.isBatch() && !System.isFuture() && !System.isQueueable() && !System.isScheduled()) {
            createGneNotificationsFuture(calls, isInsert, isUpdate, isDelete);
        }
    }

    @future
    private static void createGneNotificationsFuture(String calls, Boolean isInsert, Boolean isUpdate, Boolean isDelete) {

        if (isCurrentUserExcludedFromNotifications()) {
            return;
        }

        String callObjectName = 'Call2_vod__c';
        List<GNE_Notification__c> gneNotifications = new List<GNE_Notification__c>();

        for (Call2_vod__c call : (List<Call2_vod__c>)JSON.deserialize(calls, List<Call2_vod__c>.class)) {

            GNE_Notification__c notification = new GNE_Notification__c();

            if (String.isEmpty(call.Parent_Call_vod__c)) {
                notification.objectId__c = call.Id;
            } else {
                notification.objectId__c = call.Parent_Call_vod__c;
            }

            notification.objectName__c = callObjectName;
            notification.objectType__c = callObjectName;
            notification.transactionId__c = call.Id + '_' + System.now().format('YYYYMMDDhhmmss.ssZ');

            if (isInsert) {
                if (call.gCal_Event_Edit_URL__c != null) {
                    notification.transactionType__c = 'MAKEINTERACTION';
                } else {
                    notification.transactionType__c = 'CREATE';
                }
            } else if (isUpdate) {
                notification.transactionType__c = 'UPDATE';
            } else if (isDelete) {
                notification.transactionType__c = 'DELETE';
            }

            gneNotifications.add(notification);

        }

        try {
            insert gneNotifications;
        } catch (System.DmlException ex) {
            insert GNE_SFA2_Interaction_Util.createError('Call2_vod__c', 'Low', 'GNE_SFA2_Interaction_Adv_Future', 'Trigger', ex);
        }
    }

    private static Boolean isCurrentUserExcludedFromNotifications() {        
        return GNE_Notifications_Exclusion__c.getInstance().Id != null || GNE_Notifications_Exclusion__c.getInstance(UserInfo.getProfileId()).Id != null;
    }
    
    private static void updateTSF(String newCalls, String oldCalls, Boolean isInsert, Boolean isUpdate, Boolean isDelete){
        if(!System.isBatch() && !System.isFuture() && !System.isQueueable() && !System.isScheduled()) {
            updateTSFfuture(newCalls,oldCalls, isInsert, isUpdate, isDelete);
        }
    }

    @future
    private static void updateTSFfuture(String newCalls, String oldCalls, Boolean isInsert, Boolean isUpdate, Boolean isDelete) {
        List<Call2_vod__c> triggerNew = String.isNotBlank(newCalls) ? (List<Call2_vod__c>)JSON.deserialize(newCalls, List<Call2_vod__c>.class) : null;
        List<Call2_vod__c> triggerOld = String.isNotBlank(oldCalls) ? (List<Call2_vod__c>)JSON.deserialize(oldCalls, List<Call2_vod__c>.class) : null;
        List<TSF_vod__c> tsfsToUpdate = new List<TSF_vod__c>();
        Map<String, Call2_vod__c> callsMap = new Map<String, Call2_vod__c>();
        Map<String, Integer> callsYTDMap;
        Map<String, Date> latestCallDates = new Map<String, Date>();
        Set<String> userTerritories = new Set<String>();
        List<Call2_vod__c> completedCalls = new List<Call2_vod__c>();

        for(Territory2 t : GNE_SFA2_Util.getUserTerritories(UserInfo.getUserId())) {
            userTerritories.add(t.Name);
        }
        userTerritories.addAll(additionalUserTerritoriesForTest);

        if(triggerOld != null && isDelete) {
            Set<Id> accountIds = new Set<Id>();
            for(Call2_vod__c call : triggerOld) {
                if(call.Completed_gne__c == true) {
                    accountIds.add(call.Account_vod__c);
                    if(!callsMap.containsKey(call.Account_vod__c)) {
                        callsMap.put(call.Account_vod__c, call);
                    }
                    completedCalls.add(call);
                }
            }

            latestCallDates = getLatestCallDates(accountIds, userTerritories);
            callsYTDMap = getCallsYTD(completedCalls, false);
        }

        if(triggerNew != null && isInsert) {
            for(Call2_vod__c call : triggerNew) {
                if(call.Completed_gne__c == true) {
                    if(!callsMap.containsKey(call.Account_vod__c)) {
                        callsMap.put(call.Account_vod__c, call);
                    }
                    completedCalls.add(call);
                }
            }

            callsYTDMap = getCallsYTD(completedCalls, true);
        }

        if(triggerOld != null && triggerNew != null && isUpdate) {
            Map<Id, Call2_vod__c> triggerOldMap = new Map<Id, Call2_vod__c>(triggerOld);
            for(Call2_vod__c call : triggerNew) {
                Call2_vod__c oldCall = triggerOldMap.get(call.Id);
                if(!oldCall.Completed_gne__c && call.Completed_gne__c) {
                    if(!callsMap.containsKey(call.Account_vod__c)) {
                        callsMap.put(call.Account_vod__c, call);
                    }
                    completedCalls.add(call);
                }
            }

            callsYTDMap = getCallsYTD(completedCalls, true);
        }

        for(TSF_vod__c tsf : [SELECT Id, Account_vod__c, Territory_vod__c, Address_vod__c, External_Id_vod__c, YTD_Activity_vod__c, Last_Interaction_Date_gne__c, Last_Activity_Date_vod__c FROM TSF_vod__c WHERE Account_vod__c IN : callsMap.keyset() AND Territory_vod__c IN : userTerritories]) {
            tsf.Address_vod__c = callsMap.get(tsf.Account_vod__c).Parent_Address_vod__c;

            if(tsf.YTD_Activity_vod__c == null) {
                tsf.YTD_Activity_vod__c = 0;
            }
            String tsfKey = (callsMap.get(tsf.Account_vod__c).Account_vod__c + '_' + tsf.Territory_vod__c).toUpperCase();
            tsf.YTD_Activity_vod__c += callsYTDMap.containsKey(tsfKey) ? callsYTDMap.get(tsfKey) : 0;

            if(!isDelete) {
                tsf.Last_Interaction_Date_gne__c = callsMap.get(tsf.Account_vod__c).Call_Date_vod__c;
                if(tsf.Last_Activity_Date_vod__c < callsMap.get(tsf.Account_vod__c).Call_Date_vod__c) {
                    tsf.Last_Activity_Date_vod__c = callsMap.get(tsf.Account_vod__c).Call_Date_vod__c;
                }
            } else {
                tsf.Last_Interaction_Date_gne__c = latestCallDates.get(tsf.Account_vod__c);
                if(tsf.Last_Activity_Date_vod__c < latestCallDates.get(tsf.Account_vod__c)) {
                    tsf.Last_Activity_Date_vod__c = latestCallDates.get(tsf.Account_vod__c);
                }
            }

            tsfsToUpdate.add(tsf);
        }

        if(!tsfsToUpdate.isEmpty()) {
            try {
                update tsfsToUpdate;
            } catch (System.DMLException ex) {
                for (Integer i = 0; i < ex.getNumDml(); i++) {
                    insert GNE_SFA2_Interaction_Util.createError('Call2_vod__c', 'Low', 'GNE_SFA2_Interaction_Adv_Future', 'Trigger', ex.getDmlMessage(i));
                }
            }
        }
    }

    private static Map<String, Integer> getCallsYTD(List<Call2_vod__c> calls, Boolean isInsert) {
        Map<String, Integer> result = new Map<String, Integer>();
        for(Call2_vod__c call : calls) {
            String key = (call.Account_vod__c + '_' + call.Territory_vod__c).toUpperCase();
            if(!result.containsKey(key)) {
                result.put(key, isInsert ? 1 : -1);
            } else {
                result.put(key, result.get(key) + (isInsert ? 1 : -1));
            }
        }

        return result;
    }

    private static Map<String, Date> getLatestCallDates(Set<Id> accountIds, Set<String> territoryNames) {
        Map<String, Date> result = new Map<String, Date>();
        for(Call2_vod__c call : [SELECT Account_vod__c, Territory_vod__c, Call_Date_vod__c FROM Call2_vod__c WHERE Account_vod__c IN : accountIds AND Territory_vod__c IN : territoryNames and Completed_gne__c = true ORDER BY LastModifiedDate DESC]) {
            if(!result.containsKey(call.Account_vod__c)) {
                result.put(call.Account_vod__c, call.Call_Date_vod__c);
            }
        }

        return result;
    }

    @future
    private static void insertIndependentInsightsFuture(String serializedTriggerNewList) {
        Set<String> enabledProfilesSet = new Set<String> {
             'RCanada-SFA-Ops', 'RCanada-SFA-Manager', 'RCanada-SFA-TS', 'RCanada-SFA-RAMA'
        };
        String userProfileName = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
        try {
            if(enabledProfilesSet.contains(userProfileName)) {
                Set<Id> callcreatedByIdSet = new Set<Id>();
                Set<String> callIdsSet = new Set<String>();
                Map<Id, String> userIdToTerritoryMap = new Map<Id, String>();
                List<Independent_Insight_vod__c> independentInsightsToInsert = new List<Independent_Insight_vod__c>();
                List<Call2_vod__c> callList = (List<Call2_vod__c>) JSON.deserialize(serializedTriggerNewList, List<Call2_vod__c>.class);

                for (Call2_vod__c call : callList) {
                    callcreatedByIdSet.add(call.CreatedById);
                    callIdsSet.add(call.Id);
                }

                ProductHelper ph = new ProductHelper(callIdsSet);
                Map<Id, Id> callIdToTherapeuticAreaIdMap = ph.callIdToTherapeuticAreaIdMap;
                Map<Id, String> callIdToDetailProductsMap = ph.callIdToDetailProductsMap;

                List<UserTerritory2Association > usersTerritoriesAss = [Select Territory2.Name, Territory2Id, UserId from UserTerritory2Association where UserId IN :callcreatedByIdSet];
                for (UserTerritory2Association usrterrAss : usersTerritoriesAss) {
                    userIdToTerritoryMap.put(usrterrAss.UserId, usrterrAss.Territory2.Name);
                }

                for (Call2_vod__c call : callList) {
                    independentInsightsToInsert.add(new Independent_Insight_vod__c(
                            Account_gne__c = String.valueOf(call.Account_vod__c + ';'),
                            Territory_gne__c = String.valueOf(userIdToTerritoryMap.get(call.CreatedById)),
                            Insight_Status_gne__c = call.Interaction_Status_gne__c,
                            Title_gne__c = call.Name,
                            Call2_vod__c = call.Id,
                            Therapeutic_Area_gne__c = callIdToTherapeuticAreaIdMap.containsKey(call.Id) ? callIdToTherapeuticAreaIdMap.get(call.Id) : null,
                            Product_and_Indication_gne__c = callIdToDetailProductsMap.containsKey(call.Id) ? callIdToDetailProductsMap.get(call.Id) : null,
                            Hide_Record_gne__c = String.isBlank(call.Insight_gne__c) ? true : false
                    ));
                }

                if (!independentInsightsToInsert.isEmpty()) {
                    Database.insert(independentInsightsToInsert);
                }
            }
        } catch(System.DmlException ex) {
            insert GNE_SFA2_Interaction_Util.createError('Independent_Insight_vod__c', 'Low', 'GNE_SFA2_Interaction_Adv_Future', 'Trigger', ex);
        }
    }

    @future
    private static void updateIndependentInsightsFuture(String serializedOldMap,  String serializedNewMap) {
        Set<String> enabledProfilesSet = new Set<String> {
                'RCanada-SFA-Ops', 'RCanada-SFA-Manager', 'RCanada-SFA-TS', 'RCanada-SFA-RAMA'
        };
        String userProfileName = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
        try {
            if(enabledProfilesSet.contains(userProfileName)) {
                List<Independent_Insight_vod__c> independentInsightsToUpsert = new List<Independent_Insight_vod__c>();
                Map<Id, Call2_vod__c> oldMap = (Map<Id, Call2_vod__c>)JSON.deserialize(serializedOldMap, Map<Id, Call2_vod__c>.class);
                Map<Id, Call2_vod__c> newMap = (Map<Id, Call2_vod__c>)JSON.deserialize(serializedNewMap, Map<Id, Call2_vod__c>.class);
                Set<String> callIdsSet = new Set<String>();
                Set<String> callcreatedByIdSet = new Set<String>();
                Map<Id, String> userIdToTerritoryMap = new Map<Id, String>();
                for(Call2_vod__c newCallRec : newMap.values()) {
                    Call2_vod__c oldCallRec = oldMap.get(newCallRec.Id);
                    if(newCallRec.Insight_gne__c != oldCallRec.Insight_gne__c ||
                            newCallRec.Interaction_Description_gne__c != oldCallRec.Interaction_Description_gne__c ||
                            newCallRec.Next_Interaction_Objective_gne__c != oldCallRec.Next_Interaction_Objective_gne__c) {
                        callIdsSet.add(newCallRec.Id);
                        callcreatedByIdSet.add(newCallRec.CreatedById);
                    }
                }

                ProductHelper ph = new ProductHelper(callIdsSet);
                Map<Id, Id> callIdToTherapeuticAreaIdMap = ph.callIdToTherapeuticAreaIdMap;
                Map<Id, String> callIdToDetailProductsMap = ph.callIdToDetailProductsMap;

                List<UserTerritory2Association > usersTerritoriesAss = [Select Territory2.Name, Territory2Id, UserId from UserTerritory2Association where UserId IN :callcreatedByIdSet];
                for(UserTerritory2Association usrterrAss : usersTerritoriesAss) {
                    userIdToTerritoryMap.put(usrterrAss.UserId, usrterrAss.Territory2.Name);
                }

                List<Independent_Insight_vod__c> IndependentInsightsList = [
                        Select Insight_Description_gne__c, Call2_vod__c, Insight_Status_gne__c
                        From Independent_Insight_vod__c
                        Where Call2_vod__c IN: callIdsSet];

                for(Independent_Insight_vod__c iiToUpdate : IndependentInsightsList) {
                    iiToUpdate.Insight_Status_gne__c=newMap.get(iiToUpdate.Call2_vod__c).Interaction_Status_gne__c;
                    iiToUpdate.Account_gne__c=String.valueOf(newMap.get(iiToUpdate.Call2_vod__c).Account_vod__c+';');
                    iiToUpdate.Territory_gne__c=String.valueOf(userIdToTerritoryMap.get(newMap.get(iiToUpdate.Call2_vod__c).CreatedById));
                    iiToUpdate.Therapeutic_Area_gne__c = callIdToTherapeuticAreaIdMap.containsKey(iiToUpdate.Call2_vod__c) ? callIdToTherapeuticAreaIdMap.get(iiToUpdate.Call2_vod__c) : null;
                    iiToUpdate.Product_and_Indication_gne__c = callIdToDetailProductsMap.containsKey(iiToUpdate.Call2_vod__c) ? callIdToDetailProductsMap.get(iiToUpdate.Call2_vod__c) : null;
                    iiToUpdate.Hide_Record_gne__c = String.isBlank(newMap.get(iiToUpdate.Call2_vod__c).Insight_gne__c) ? true: false;
                    independentInsightsToUpsert.add(iiToUpdate);
                    callIdsSet.remove(iiToUpdate.Call2_vod__c);
                }

                if(!callIdsSet.isEmpty()) {
                    for(Call2_vod__c call : newMap.values()) {
                        if(callIdsSet.contains(call.Id)) {
                            independentInsightsToUpsert.add(
                                    new Independent_Insight_vod__c(
                                            Insight_Status_gne__c = call.Interaction_Status_gne__c,
                                            Account_gne__c = String.valueOf(call.Account_vod__c+';'),
                                            Territory_gne__c = String.valueOf(userIdToTerritoryMap.get(call.CreatedById)),
                                            Call2_vod__c=call.Id,
                                            Therapeutic_Area_gne__c = callIdToTherapeuticAreaIdMap.containsKey(call.Id) ? callIdToTherapeuticAreaIdMap.get(call.Id) : null,
                                            Product_and_Indication_gne__c = callIdToDetailProductsMap.containsKey(call.Id) ? callIdToDetailProductsMap.get(call.Id) : null,
                                            Hide_Record_gne__c = String.isBlank(call.Insight_gne__c) ? true : false
                                    )
                            );
                        }
                    }
                }

                if(!independentInsightsToUpsert.isEmpty()) {
                    Database.update(independentInsightsToUpsert);
                }
            }
        } catch(System.DmlException ex) {
            insert GNE_SFA2_Interaction_Util.createError('Independent_Insight_vod__c', 'Low', 'GNE_SFA2_Interaction_Adv_Future', 'Trigger', ex);
        }
    }

    class ProductHelper {
        Map<Id, Id> callIdToTherapeuticAreaIdMap {get; private set;}
        Map<Id, String> callIdToDetailProductsMap {get; private set;}
        Set<String> callIdsSet {get; private set;}
        List<Call2_Discussion_vod__c> callDiscussions {get; private set;}

        public ProductHelper(Set<String> callIdsSet) {
            this.callIdsSet = callIdsSet;
            this.callDiscussions = this.getCallDiscussions();
            this.callIdToTherapeuticAreaIdMap = this.getCallIdToTherapeuticAreaIdMap();
            this.callIdToDetailProductsMap = this.getCallIdToDetailProductsMap();
        }

        private List<Call2_Discussion_vod__c> getCallDiscussions() {
            return [
                    SELECT Id, Call2_vod__c, Product_vod__c, Product_vod__r.Product_Type_vod__c, Product_vod__r.Name, Product_vod__r.Therapeutic_Area_Reference__c, Product_vod__r.Therapeutic_Area_Reference__r.Name
                    FROM Call2_Discussion_vod__c
                    WHERE Call2_vod__c IN : this.callIdsSet
                    ORDER By Call2_vod__c
            ];
        }

        private Map<Id, Id> getCallIdToTherapeuticAreaIdMap() {
            Map<Id, Id> callIdToTherapeuticAreaIdMapTmp = new Map<Id, Id>();
            for(Call2_Discussion_vod__c cd : this.callDiscussions) {
                if(cd.Product_vod__r.Product_Type_vod__c == 'Therapeutic Area') {
                    if(callIdToTherapeuticAreaIdMapTmp.containsKey(cd.Call2_vod__c)) {
                        if(callIdToTherapeuticAreaIdMapTmp.get(cd.Call2_vod__c) != cd.Product_vod__r.Id) {
                            System.debug('Another value for cd.Call2_vod__c: ' + cd.Call2_vod__c);
                        }
                    } else {
                        callIdToTherapeuticAreaIdMapTmp.put(cd.Call2_vod__c, cd.Product_vod__r.Id);
                    }
                } else if(cd.Product_vod__r.Product_Type_vod__c == 'Detail') {
                    if(callIdToTherapeuticAreaIdMapTmp.containsKey(cd.Call2_vod__c)) {
                        if(callIdToTherapeuticAreaIdMapTmp.get(cd.Call2_vod__c) != cd.Product_vod__r.Therapeutic_Area_Reference__c) {
                            System.debug('Another value for cd.Call2_vod__c: ' + cd.Call2_vod__c);
                        }
                    } else {
                        callIdToTherapeuticAreaIdMapTmp.put(cd.Call2_vod__c, cd.Product_vod__r.Therapeutic_Area_Reference__c);
                    }
                }
            }
            return callIdToTherapeuticAreaIdMapTmp;
        }

        private Map<Id, String> getCallIdToDetailProductsMap() {
            Map<Id, String> callIdToDetailProductsMapTmp = new Map<Id, String>();
            for(Call2_Discussion_vod__c cd : this.callDiscussions) {
                if(cd.Product_vod__r.Product_Type_vod__c == 'Detail') {
                    if(callIdToDetailProductsMapTmp.containsKey(cd.Call2_vod__c)) {
                        if(String.isNotBlank(cd.Product_vod__c)) {
                            String productString = callIdToDetailProductsMapTmp.get(cd.Call2_vod__c);
                            productString += String.valueOf(cd.Product_vod__c) + ';';
                            callIdToDetailProductsMapTmp.put(cd.Call2_vod__c, productString);
                        }
                    } else {
                        if(String.isNotBlank(cd.Product_vod__c)) {
                            String productString = String.valueOf(cd.Product_vod__c)  + ';';
                            callIdToDetailProductsMapTmp.put(cd.Call2_vod__c, productString);
                        }
                    }
                }
            }
            return callIdToDetailProductsMapTmp;
        }

    }
}