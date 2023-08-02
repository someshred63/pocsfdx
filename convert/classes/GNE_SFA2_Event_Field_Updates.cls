public with sharing class GNE_SFA2_Event_Field_Updates{
    
    public static void onBeforeInsert(List<Event> newEvents){
        eventTriggerBeforeInsert(newEvents);
    }
    private static void eventTriggerBeforeInsert(List<event> events){
        if (GNE_SFA2_EventTriggerUtil.getCallTrig()){
            return;
        }
        GNE_SFA2_EventTriggerUtil.setCalendarTrig(true);
        RecordType recType = [Select Id from RecordType where SobjectType = 'Event' and Name = 'GNE-SFA-Roche_Canada_Event'];
        if(GNE_SFA2_Util.isCanadaUser()) {
            for(Event e : events) {
                e.RecordTypeId = recType.Id;
            }
        }
    }
}