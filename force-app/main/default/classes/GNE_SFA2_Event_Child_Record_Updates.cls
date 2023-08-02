public with sharing class GNE_SFA2_Event_Child_Record_Updates
{
    public static void OnAfterUpdate(Map<Id,Event> oldMap,Map<Id,Event> newMap){
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
        eventTriggerAfterUpdate(idSet,oldEvents,newEvents);
       
    }

    public static void OnAfterDelete(Map<Id,Event> oldMap){
        List<Event> events = new List<Event>();
        List<Id> idSet = new List<Id>();
        if(oldMap.size() > 0) {
            events .addAll(oldMap.values());
            idSet.addAll(oldMap.keySet());
        }
        deleteToTDayRecordsOnEventsDelete(idSet,events);
        deletEventReplicaAfterEventDelete(idSet);
        eventTriggerAfterDelete(idSet,events);
    }
    private static void deletEventReplicaAfterEventDelete (List<Id> idSet){
        if(idSet != null && idSet.size() > 0){
            try {
              database.delete ( [select id from Event_Replica_gne__c where Id_gne__c in :idSet], false);
            } catch (Exception e) {
                GNE_SFA2_ErrorBundle_Util.writeErrorLog('Task', 'deletEventReplicaAfterEventDelete', e);           
            }
        }
    }
    
    private static void deleteToTDayRecordsOnEventsDelete(List<Id> ids,List<Event> events) {
       try{
            if(events != null && events.size() > 0){
                List<Time_Off_Territory_Day_gne__c> totsd=[select id from Time_Off_Territory_Day_gne__c where id in :ids];
                delete totsd;
            }
        }
        catch(Exception ex){
            GNE_SFA2_ErrorBundle_Util.writeErrorLog('Event', 'deleteToTDayRecordsOnEventsDelete', ex); 
       }
    }
    
    private static void eventTriggerAfterUpdate(List<Id> ids,List<Event> oldEvents,List<Event> newEvents)
    {
        if (GNE_SFA2_EventTriggerUtil.getCallTrig()){
            return;
        }
        GNE_SFA2_EventTriggerUtil.setCalendarTrig(true);
        RecordType recType = [Select Id from RecordType where SobjectType = 'Event' and Name = 'Call_vod'];
        List<Call2_vod__c> callList= new List<Call2_vod__c>();
        for (Integer i = 0; i < newEvents.size(); i++)   {
            String recId = newEvents.get(i).RecordTypeId;
            if (recType.Id  == recId ) {
                if (newEvents.get(i).ActivityDateTime == oldEvents.get(i).ActivityDateTime 
                    && newEvents.get(i).ActivityDate == oldEvents.get(i).ActivityDate ){
                    continue;
                }
                String id =  newEvents.get(i).WhatId;
                Integer callCount = [Select Count() from Call2_vod__c where ID =:id];
                Date cDate = null;
                if (callCount > 0) {
                    if (newEvents[i].ActivityDateTime != null ){
                        cDate = Date.newInstance (newEvents[i].ActivityDateTime.year(), 
                                newEvents[i].ActivityDateTime.month(),
                                newEvents[i].ActivityDateTime.day());
                    }
                    else{ 
                        cDate = System.today();
                    }
                    Call2_vod__c call = new Call2_vod__c (Id = newEvents[i].WhatId,
                                             Call_Datetime_vod__c= newEvents[i].ActivityDateTime,
                                             Call_Date_vod__c = cDate);
                    callList.add(call);
               }
            }
        }
        try 
        {
            if (callList.size() > 0)
               update callList;
        }    
        catch (System.DmlException e) 
        {
           newEvents.get(0).Id.addError(System.Label.Event_Associated_With_Call_Lock_Label); 
        }
        finally{
            GNE_SFA2_EventTriggerUtil.setCalendarTrig(false);
        }
    }
    
    private static void eventTriggerAfterDelete(List<Id> ids,List<event> events)
    {
        if (GNE_SFA2_EventTriggerUtil.getCallTrig()){
            return;
        }
        GNE_SFA2_EventTriggerUtil.setCalendarTrig(true);
        RecordType recType = [Select Id from RecordType where SobjectType = 'Event' and Name = 'Call_vod'];
        List<Call2_vod__c> delList = new List<Call2_vod__c>();
        for (Integer i = 0; i < events.size(); i++)   {
          String recId =  events.get(i).RecordTypeId;
          if (recType.Id  == recId ) {
            String id = events.get(i).WhatId;
            Integer callCount = [Select Count() from Call2_vod__c where ID =:id and Status_vod__c = 'Planned_vod'];
            if (callCount > 0) {
                  Call2_vod__c delCall = new Call2_vod__c (Id = id);
                  delList.add(delCall);
            }
         } 
        }
        try {
            if (delList.size() > 0)
                delete delList;
        }    
        catch (System.DmlException e) {
            events.get(0).Id.addError(System.Label.Event_Associated_With_Call_Lock_Label); 
        }
        finally{
            GNE_SFA2_EventTriggerUtil.setCalendarTrig(false);
        }
     }
     
}