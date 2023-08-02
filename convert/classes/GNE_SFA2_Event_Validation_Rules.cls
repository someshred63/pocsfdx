public with sharing class GNE_SFA2_Event_Validation_Rules {
   public static void OnBeforeUpdate(Map<Id,Event> oldMap,Map<Id,Event> newMap){
   
        List<Event> oldEvents = new List<Event>();
        List<Id> idSet = new List<Id>();
        if(oldMap.size() > 0) {
            oldEvents.addAll(oldMap.values());
            idSet.addAll(oldMap.keySet());
        }
        List<Event> newEvents = new List<Event>();
        if(newMap.size() > 0){
            newEvents.addAll(newMap.values());
        }
        eventTriggerBeforeUpdate(idSet,oldEvents,newEvents);
    
   }
   
   public static void OnBeforeDelete(Map<Id,Event> oldMap){
        List<Event> events = new List<Event>();
        List<Id> idSet = new List<Id>();
        if(oldMap.size() > 0) {
            events .addAll(oldMap.values());
            idSet.addAll(oldMap.keySet());
        }
       eventTriggerBeforeDelete(idSet,events);
    }
    
    private static void eventTriggerBeforeDelete(List<Id> ids,List<event> events)
    {
        if (GNE_SFA2_EventTriggerUtil.getCallTrig()){
            return;
        }
        GNE_SFA2_EventTriggerUtil.setCalendarTrig(true);
        RecordType recType = [Select Id from RecordType where SobjectType = 'Event' and Name = 'Call_vod'];
        Map <Id, Call2_vod__c> callMap = new   Map <Id, Call2_vod__c> ([Select Id, Status_vod__c from Call2_vod__c where Id in :ids]);
        for (Integer k = 0; k < events.size (); k++) {
            Call2_vod__c call = callMap.get(events.get(k).WhatId);
            if (call != null) {
                if (recType.Id == events.get(k).RecordTypeId)  {
                    if (call.Status_vod__c == 'Submitted_vod')  {
                        events.get(k).Id.addError(System.Label.Event_Associated_With_Call_Lock_Label);
                    } 
                    else if (call.Status_vod__c == 'Saved_vod') {
                        events.get(k).Id.addError(System.Label.Event_Associated_With_In_Prog_Call_Lock_Label);
                    }
                }
            }
        }
        GNE_SFA2_EventTriggerUtil.setCalendarTrig(false);
    }
    
    private static void eventTriggerBeforeUpdate(List<Id> ids,List<Event> oldEvents,List<Event> newEvents)
    {
        if (GNE_SFA2_EventTriggerUtil.getCallTrig()){
            return;
        }
        GNE_SFA2_EventTriggerUtil.setCalendarTrig(true);
        RecordType recType = [Select Id from RecordType where SobjectType = 'Event' and Name = 'Call_vod'];
        Map <Id, Call2_vod__c> callMap = new   Map <Id, Call2_vod__c> ([Select Id, Status_vod__c from Call2_vod__c
            where Id in :ids]);
        for (Integer k = 0; k < oldEvents.size (); k++) {
            Call2_vod__c call = callMap.get(oldEvents.get(k).WhatId);
            if (call != null) {
                if (recType.Id == oldEvents.get(k).RecordTypeId)  {
                    if (call.Status_vod__c == 'Submitted_vod')  {
                        newEvents.get(k).Id.addError(System.Label.Event_Associated_With_Call_Lock_Label);
                    } 
                }
            }
        }
        GNE_SFA2_EventTriggerUtil.setCalendarTrig(false);
    }

}