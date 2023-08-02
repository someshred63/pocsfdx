global class TimeOffTerritory_WS {
    WebService static id createToT(string reason,Date startDate, Date endDate, String hrs) {
        Time_Off_Territory_gne__c tot=new Time_Off_Territory_gne__c(
             Approval_Status_gne__c='Pending',
             Description_gne__c=reason
        );
        insert tot;
        List<Actual_Working_Days_gne__c> awd=[Select Date_gne__c, Id from Actual_Working_Days_gne__c 
                                                where Date_gne__c>=:startDate and Date_gne__c<=:endDate];
        List<Time_Off_Territory_Day_gne__c> totds=new List<Time_Off_Territory_Day_gne__c>();        
        for(Actual_Working_Days_gne__c ad:awd){
            Time_Off_Territory_Day_gne__c totd=new Time_Off_Territory_Day_gne__c(
                Date_gne__c=ad.Date_gne__c,
                Reason_gne__c=reason,
                Time_Off_Territory_gne__c=tot.id,
                Hours_Off_Territory__c=hrs
            );
            totds.Add(totd);
        }
        insert totds;
        return tot.id;
    }
    WebService static boolean deleteToTDayRecordsOnEventsDelete(List<Event> events) {
        List<id> ids=new List<id>();
        for(Event ev:events) ids.add(ev.WhatId);
        List<Time_Off_Territory_Day_gne__c> totsd=[select id from Time_Off_Territory_Day_gne__c where id in :ids];
        delete totsd;
        return true;
    }
    WebService static boolean deleteEventsOnToTDayRecordsDelete(List<Time_Off_Territory_Day_gne__c> TOTsDays) {
        List<id> ids=new List<id>();
        for(Time_Off_Territory_Day_gne__c totd:TOTsDays) ids.add(totd.id);
        List<Event> evs=[select id from Event where WhatId in :ids];
        delete evs;
        return true; 
    }
     WebService static boolean createEventsOnToTDayRecordCreation(List<Time_Off_Territory_Day_gne__c> TOTsDays) {
        List<Event> events=new List<Event>();
        for(Time_Off_Territory_Day_gne__c totd:TOTsDays){
            events.add(new Event( 
                    ActivityDate=totd.Date_gne__c, 
                    IsAllDayEvent=true, 
                    Type='Other', 
                    Subject='Day out of territory',
                    WhatId=totd.id));
        }
        insert events;
        return true; 
    }   
    WebService static boolean isToTId(id ToTId) {
        Time_Off_Territory_gne__c tot=[select id from Time_Off_Territory_gne__c where id=:ToTId];
        return (tot!=null); 
    }
}