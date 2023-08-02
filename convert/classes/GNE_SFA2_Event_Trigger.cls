public class GNE_SFA2_Event_Trigger
{

    // define a method to be called from the trigger
    public static void GNE_SFA2_Events_Update_OR_Delete(Boolean isBefore,Boolean isDelete,List<Event> old,List<Event> newTrigger)
    {
        if (GNE_SFA2_Call_To_Calendar.getCallTrig() == true)
            return;
        String errorMsg = System.Label.Event_Associated_With_Call_Lock_Label;
        String errorMsg_Inprog = System.Label.Event_Associated_With_In_Prog_Call_Lock_Label;
        GNE_SFA2_Call_To_Calendar.setCalendarTrig(true);
        RecordType recType = [Select Id from RecordType where SobjectType = 'Event' and Name = 'Call_vod'];
        if (isBefore)  {
            List <String> ids = new List<String>();
            for (Event es : old) {
                ids.add(es.WhatId);
            }
            Map <Id, Call2_vod__c> callMap = new    Map <Id, Call2_vod__c> ([Select Id, Status_vod__c from Call2_vod__c where Id in :ids]);
            for (Integer k = 0; k < old.size (); k++) {
                Call2_vod__c call = callMap.get(old[k].WhatId);
                if (call != null) {
                    if (recType.Id == old[k].RecordTypeId)  {
                            if (call.Status_vod__c == 'Submitted_vod')  {
                                if (!isDelete) 
                                    newTrigger[k].Id.addError(errorMsg);
                                else
                                    old[k].Id.addError(errorMsg);
                            } else if ( call.Status_vod__c == 'Saved_vod') {
                                if (isDelete) {
                                    old[k].Id.addError(errorMsg_Inprog);
                                }
                            }
                    }
                }
            }
        } 
        else {
            List<Call2_vod__c> callList = new List<Call2_vod__c>();
            List<Call2_vod__c> delList = new List<Call2_vod__c>();
            Event [] newEvents = newTrigger;
            Event [] oldEvents = old;
        
      
            for (Integer i = 0; i < (isDelete ? old.size(): newTrigger.size()); i++)    {
                String recId = isDelete ? oldEvents[i].RecordTypeId:newEvents[i].RecordTypeId;
                if (recType.Id  == recId ) {
                    if (!isDelete) { 
                        if (newEvents[i].ActivityDateTime == oldEvents[i].ActivityDateTime && newEvents[i].ActivityDate == oldEvents[i].ActivityDate )
                            continue;
                }
                
                String id =isDelete ? oldEvents[i].WhatId : newEvents[i].WhatId;
            
                if (!isDelete) { 
                   
                    Integer callCount = [Select Count() from Call2_vod__c where ID =:id];
                    Date cDate = null;
                    if (callCount > 0) {
                      if (newEvents[i].ActivityDateTime != null )
                          cDate = Date.newInstance (newEvents[i].ActivityDateTime.year(), 
                                                    newEvents[i].ActivityDateTime.month(),
                                                    newEvents[i].ActivityDateTime.day());
                      else 
                          cDate = System.today();
                      Call2_vod__c call = new Call2_vod__c (Id = newEvents[i].WhatId,
                                                               Call_Datetime_vod__c= newEvents[i].ActivityDateTime,
                                                               Call_Date_vod__c = cDate);
                                                        
                       callList.add(call);
                    }
                }
               if (isDelete) {
                      Integer callCount = [Select Count() from Call2_vod__c where ID =:id and Status_vod__c = 'Planned_vod'];
              
                   if (callCount > 0) {
                      Call2_vod__c delCall = new Call2_vod__c (Id = oldEvents[i].WhatId);
                      delList.add(delCall);
                    }
               }
            } 
        }
        try {
            if (callList.size() > 0)
               update callList;
            if (delList.size() > 0)
               delete delList;
               
            }    catch (System.DmlException e) {
                        if (isDelete) {
                            old[0].Id.addError (errorMsg); 
                        }
                        else {
                            newTrigger[0].Id.addError(errorMsg); 
                        }
            }
            }
        
    
    }
}