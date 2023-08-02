public class Events_RelatedList{    
    
    private Id speakerBureauId;
    private Event_Bureaus_gne__c[] spList;
    private Event_Attendee_vod__c[] eventList;    
    private Map<Id,String> mapEvntCity = new Map<Id,String>();
    private Map<Id,String> mapEvntState = new Map<Id,String>();
    private Map<Id,String> mapEvntSpkr = new Map<Id,String>();    
    private Set<Id> parentEvntIds = new Set<Id>();
    public ID delId {get;set;}
    public String all {get;set;}
    
    private static final Integer NUMBER_OF_EVENTS_TO_SHOW = 3; 
    
    private List<eventWrapper> evnts = new List<eventWrapper>();
      
    public class eventWrapper{
        public Event_Attendee_vod__c Attendee {get;set;}
        public Medical_event_vod__c evnt {get;set;}
        
        public String Id {get;set;}
        public String AttendeeName {get;set;}
        public String EventId {get;set;}
        public String EventName {get;set;}
        public String EventStartDate {get;set;}
        public String EventStartTime {get;set;}
        public String EventMedium {get;set;}
        public String City {get;set;}
        public String State {get;set;}          
        public String Role {get;set;}
        public String Status {get;set;}
        public String Speaker {get;set;}
        
        public eventWrapper(Event_Attendee_vod__c ea, String eCity, String eState){         
            Id = ea.Id;
            AttendeeName = ea.Name;
            EventId = ea.Medical_Event_vod__c;
            EventName = ea.Medical_Event_vod__r.Name;
            if(ea.Start_Date_gne__c!=null)
            {
                EventStartDate = ea.Start_Date_gne__c.month() + '/' + ea.Start_Date_gne__c.day() + '/' + ea.Start_Date_gne__c.year();
            }
            else
            {
                EventStartDate='';
            }
            EventStartTime = ea.Medical_Event_vod__r.Start_Time_gne__c;
            EventMedium = ea.Medical_Event_vod__r.event_medium_type_gne__c;
            City = eCity;
            State = eState;         
            Role = ea.Role_gne__c;
            Status = ea.Status_vod__c;          
            Speaker= ea.Medical_Event_vod__r.Speakers_Name_gne__c;      
        }
        
        public eventWrapper(Medical_event_vod__c me, String eCity, String eState){
            Id = null;
            AttendeeName = '';
            EventId = me.id;
            EventName = me.Name;
            if(me.Start_Date_vod__c!=null)
            {
                EventStartDate = me.Start_Date_vod__c.month() + '/' + me.Start_Date_vod__c.day() + '/' + me.Start_Date_vod__c.year();
            }
            else
            {
                EventStartDate='';
            }
            EventStartTime = me.Start_Time_gne__c;
            EventMedium = me.event_medium_type_gne__c;
            City = eCity;
            State = eState;         
            Role = '';
            Status = '';
            Speaker = me.Speakers_Name_gne__c;
        }
        
        public eventWrapper(Event_Bureaus_gne__c sb, String eCity, String eSpkr){
            Id = sb.id;
            AttendeeName = '';
            EventId = sb.Medical_Event_gne__c;
            EventName = sb.Medical_Event_gne__r.Name;
            if(sb.Medical_Event_gne__r.Start_Date_vod__c!=null){
                EventStartDate = sb.Medical_Event_gne__r.Start_Date_vod__c.month() + '/' + sb.Medical_Event_gne__r.Start_Date_vod__c.day() + '/' + sb.Medical_Event_gne__r.Start_Date_vod__c.year();
            }
            else
            {
                EventStartDate = '';    
            }
            EventStartTime = sb.Medical_Event_gne__r.Start_Time_gne__c;
            EventMedium = sb.Medical_Event_gne__r.event_medium_type_gne__c;
            City = eCity;
            State = '';         
            Role = '';
            Status = sb.Event_Status_gne__c;
            Speaker = eSpkr;
        }
    }
                
    public Events_RelatedList(ApexPages.StandardController controller) {        
        all = System.currentPageReference().getParameters().get('all');
        speakerBureauId = controller.getRecord().Id;            
    } 
    
    public eventWrapper[] getEvents(){
        String city;
        String state;
        List<Medical_Event_vod__c> childEvents = New List<Medical_Event_vod__c>();
        if(evnts != null){
        evnts.clear(); }         
        parentEvntIds.clear();
        eventList = [Select e.Id,e.Name, e.Start_Date_gne__c,
                        e.Medical_Event_vod__r.Id, e.Medical_Event_vod__r.Name,                         
                        e.Medical_Event_vod__r.Start_Time_gne__c,
                        e.Medical_Event_vod__r.event_medium_type_gne__c, 
                        e.Medical_Event_vod__r.City_Name_gne__c, 
                        e.Medical_Event_vod__r.State_Province_Code_gne__c,
                        e.Medical_Event_vod__r.Speakers_Name_gne__c, 
                        e.Role_gne__c,
                        e.Status_vod__c
                        from Event_Attendee_vod__c e  
                        where e.Account_vod__c = :speakerBureauId 
                        and e.Medical_Event_vod__r.Parent_Event_gne__c = 'True' 
                        order by Medical_Event_vod__c desc];
        
            setParentIds('EventAttendee');
            List<Event_Attendee_vod__c> tmpEvents = [Select e.Medical_Event_vod__r.Parent_Medical_Event_gne__c                  
                                                        from Event_Attendee_vod__c e 
                                                        where e.Account_vod__c = :speakerBureauId 
                                                        and e.Medical_Event_vod__r.Parent_Event_gne__c = 'False' 
                                                        and e.Medical_Event_vod__r.Parent_Medical_Event_gne__c not in :parentEvntIds];
            
            Set<Id> tmpParentIds = New Set<Id>();
            for( Event_Attendee_vod__c ea : tmpEvents){
                if(!tmpParentIds.contains(ea.Medical_Event_vod__r.Parent_Medical_Event_gne__c))
                    tmpParentIds.add(ea.Medical_Event_vod__r.Parent_Medical_Event_gne__c);
            }
            if(tmpParentIds.size() != 0){               
                childEvents = [Select Id,Name,Start_Time_gne__c,
                                      event_medium_type_gne__c, 
                                      City_Name_gne__c,
                                      State_Province_Code_gne__c, Start_Date_vod__c, Speakers_Name_gne__c
                                from Medical_Event_vod__c e  
                                where id in :tmpParentIds
                                order by id desc];
                
                parentEvntIds.addAll(tmpParentIds);
            }
                        
            if(eventList.size() == 0 && childEvents.size() == 0){
                evnts = null;
            }
            
            childEventDetails();
            
            if(eventList.size() != 0){                                     
                for(Event_Attendee_vod__c event : eventList){
                    if(mapEvntCity.containsKey(event.Medical_Event_vod__c)){
                        city = mapEvntCity.get(event.Medical_Event_vod__c);
                    }else{
                        city='';
                    }
                            
                    if(mapEvntState.containsKey(event.Medical_Event_vod__c)){
                        state = mapEvntState.get(event.Medical_Event_vod__c);
                    }else{
                        state='';
                    }
                      
                    evnts.add(new eventWrapper(event,city,state));              
                }
            }
                                    
            if(childEvents.size() != 0){
                for(Medical_Event_vod__c cEvent : childEvents){                 
                    if(mapEvntCity.containsKey(cEvent.Id)){
                        city = mapEvntCity.get(cEvent.Id);
                    }else{
                        city='';
                    }
                        
                    if(mapEvntState.containsKey(cEvent.Id)){
                        state = mapEvntState.get(cEvent.Id);
                    }else{
                        state='';
                    }                       
                    evnts.add(new eventWrapper(cEvent,city,state));
                }
            }
            return evnts;
        }
        
    private String setParentIds(String calledFrom){
        if(calledFrom == 'EventAttendee'){
            for( Event_Attendee_vod__c ea : eventList){
                if (! parentEvntIds.contains(ea.Medical_Event_vod__c)){
                    parentEvntIds.add(ea.Medical_Event_vod__c);
                }
            }
        }else{
            for(Event_Bureaus_gne__c ea : spList){
                if(! parentEvntIds.contains(ea.Medical_Event_gne__c)){
                    parentEvntIds.add(ea.Medical_Event_gne__c);
                }
            }
        }    
        return '';
    }
    
    private String childEventDetails(){        
        List<Medical_Event_vod__c> childEvnts = [Select 
                                                    parent_medical_event_gne__c, 
                                                    City_Name_gne__c,
                                                    State_Province_Code_gne__c, 
                                                    Speaker_gne__c,Speaker_gne__r.Name, 
                                                    Speakers_Name_gne__c
                                                From 
                                                    Medical_Event_vod__c
                                                Where 
                                                    Parent_Event_gne__c = 'False'
                                                    And 
                                                    parent_medical_event_gne__c in :parentEvntIds];
            
            
        for(Medical_Event_vod__c event : childEvnts){
            if(event.City_Name_gne__c != null){                     
                if(mapEvntCity.containsKey(event.parent_medical_event_gne__c)){
                    if(!mapEvntCity.get(event.parent_medical_event_gne__c).contains(event.City_Name_gne__c)){
                        mapEvntCity.put(event.parent_medical_event_gne__c,mapEvntCity.get(event.parent_medical_event_gne__c) + ',' + event.City_Name_gne__c);
                    }
                }else{
                    mapEvntCity.put(event.parent_medical_event_gne__c, event.City_Name_gne__c);
                }
            }
                
            if(event.State_Province_Code_gne__c != null){                       
                if(mapEvntState.containsKey(event.parent_medical_event_gne__c)){
                    if(!mapEvntState.get(event.parent_medical_event_gne__c).contains(event.State_Province_Code_gne__c)){
                        mapEvntState.put(event.parent_medical_event_gne__c,mapEvntState.get(event.parent_medical_event_gne__c) + ',' + event.State_Province_Code_gne__c);
                    }
                }else{
                    mapEvntState.put(event.parent_medical_event_gne__c, event.State_Province_Code_gne__c);
                } 
            }
            
            if(event.Speakers_Name_gne__c != null){ 
                if(mapEvntSpkr.containsKey(event.parent_medical_event_gne__c)){
                    if(!mapEvntSpkr.get(event.parent_medical_event_gne__c).contains(event.Speakers_Name_gne__c)){
                        mapEvntSpkr.put(event.parent_medical_event_gne__c,mapEvntSpkr.get(event.parent_medical_event_gne__c) + '; ' + event.Speakers_Name_gne__c);
                    }                   
                }else{
                    mapEvntSpkr.put(event.parent_medical_event_gne__c, event.Speakers_Name_gne__c);
                } 
            }
        }        
        return '';
    }
      
    public eventWrapper[] getSpeakerBureauEvents(){    
        String city;
        String spkr;
        evnts.clear();   
        parentEvntIds.clear();     
        spList = [Select Id, Medical_Event_gne__r.Name, 
                        Medical_Event_gne__r.Start_Date_vod__c,
                        Medical_Event_gne__r.Start_Time_gne__c,
                        Event_Status_gne__c,
                        Medical_Event_gne__r.event_medium_type_gne__c,
                        Medical_Event_gne__r.City_Name_gne__c,
                        Medical_Event_gne__r.Speaker_gne__r.Name  ,
                        Medical_Event_gne__r.Accountable_ID_gne__c,
                        Medical_Event_gne__r.Speakers_Name_gne__c                               
                        FROM Event_Bureaus_gne__c  
                        Where Speaker_Bureau_gne__c = :speakerBureauId 
                        and Medical_Event_gne__r.Parent_Event_gne__c = 'True'
                        Order By Event_Status_gne__c];           
            
        setParentIds('SpkrBureau');         
        if(spList.size() == 0){
            evnts = null;
        }else{       
            childEventDetails();
            for(Event_Bureaus_gne__c event : spList){     
                if(mapEvntCity.containsKey(event.Medical_Event_gne__c)){
                    city = mapEvntCity.get(event.Medical_Event_gne__c);
                }else{
                    city ='';
                }
                            
                if(mapEvntSpkr.containsKey(event.Medical_Event_gne__c)){
                    spkr = mapEvntSpkr.get(event.Medical_Event_gne__c);
                }else{
                    spkr ='';
                }
                evnts.add(new eventWrapper(event,city,spkr));       
             }
        }
        
        if(all != 'true'){
             List<eventWrapper> smallEvnts = new List<eventWrapper>();
             for(Integer i = 0; i < NUMBER_OF_EVENTS_TO_SHOW ; i++){
                smallEvnts.add(evnts.get(i));
             }
             return smallEvnts;
        }
        
        return evnts;
    }
    
    public PageReference getShowAll(){
        String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);
        String redirectURL = partOneURL + 'apex/Events_RelatedList_OnSpeakerBureau?id='+speakerBureauId+'&all=true';
        PageReference showAllPage = new PageReference(redirectURL);
        showAllPage.setRedirect(true);
        return showAllPage;
    }
    
    public PageReference getBackToSpeakerBureau(){
        PageReference speakerBureauPage = new PageReference('/'+speakerBureauId);
        speakerBureauPage.setRedirect(true);
        return speakerBureauPage;
    }

    
        
    public boolean getEventBureau_IsCreateable(){
        if (Schema.sObjectType.Event_Bureaus_gne__c.isCreateable())
            return true;
        else
            return false;
    }
    
    public boolean getEventBureau_IsUpdateable(){
        if (Schema.sObjectType.Event_Bureaus_gne__c.isUpdateable())
            return true;
        else
            return false;
    }
    
    public boolean getEventBureau_IsDeletable(){
        if (Schema.sObjectType.Event_Bureaus_gne__c.isDeletable())
            return true;
        else
            return false;
    }
        
    public boolean getEventAttendee_IsCreateable(){
        if (Schema.sObjectType.Event_Attendee_vod__c.isCreateable())
            return true;
        else
            return false;
    }
    
    public boolean getEventAttendee_IsUpdateable(){
        if (Schema.sObjectType.Event_Attendee_vod__c.isUpdateable())
            return true;
        else
            return false;
    }
    
    public boolean getEventAttendee_IsDeletable(){
        if (Schema.sObjectType.Event_Attendee_vod__c.isDeletable())
            return true;
        else
            return false;
    }
    
    public void DelSpkrEvent(){
        Event_Bureaus_gne__c[] e = [select id from Event_Bureaus_gne__c where id = :delId];
        delete e;           
        return;                 
    }
    
    public void DelEventAttd(){         
        Event_Attendee_vod__c[] e = [select id from Event_Attendee_vod__c where id=:delId];
        delete e;           
        return;                 
    }

}