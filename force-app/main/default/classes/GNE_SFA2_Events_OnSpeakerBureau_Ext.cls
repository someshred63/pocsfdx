public class GNE_SFA2_Events_OnSpeakerBureau_Ext{  
    private Id speakerBureauId;
    private Event_Bureaus_gne__c[] spList;
    private Event_Attendee_vod__c[] eventList;    
    private Map<Id,String> mapEvntCity = new Map<Id,String>();
    private Map<Id,String> mapEvntState = new Map<Id,String>();
    private Map<Id,String> mapEvntSpkr = new Map<Id,String>();    
    private Set<Id> parentEvntIds = new Set<Id>();
    public ID delId {get;set;}
    public String all {get;set;}
    
    private static final Integer NUMBER_OF_EVENTS_IN_BATCH = 5;
    private static final Integer NUMBER_OF_EVENTS_TOTAL = 100;  
    public GNE_SFA2_Events_OnSpeakerBureau_Ext(ApexPages.StandardController controller) {        
        all = System.currentPageReference().getParameters().get('all');
        speakerBureauId = controller.getRecord().Id; 
        //speakerBureauId = System.currentPageReference().getParameters().get('id');
        evnts = new List<eventWrapper>();
        evnts = getAllSpeakerBureauEvents();
        offset = 0;
        currentPage = 1;  
        mapEvntCity = null;
        mapEvntState = null; 
        mapEvntSpkr = null;   
    } 
    
    private List<eventWrapper> evnts = new List<eventWrapper>();
    // Page Nvagation
    private integer offset;
    public integer currentPage { get; set;}
    public integer totalPages { 
        get{
            System.debug('*********************' + evnts.size());
            Decimal temp = (1.0 * evnts.size()/NUMBER_OF_EVENTS_IN_BATCH);
            return temp.round(System.RoundingMode.UP).intValue();
        } 
        set;
    }
    public Boolean hasNext {
        get{
            if(currentPage < totalPages) return true;
            else return false;  
        }
    }
    public Boolean hasPrevious {
        get{
            if(currentPage > 1) return true;
            else return false;  
        }
    }
    
    public PageReference next(){
        offset += NUMBER_OF_EVENTS_IN_BATCH;
        currentpage += 1;
        return null;
    }
    
    public PageReference previous(){
        offset -=NUMBER_OF_EVENTS_IN_BATCH;
        currentpage -= 1;
        return null;
    }
    public PageReference first(){
        offset = 0;
        currentpage = 1;
        return null;
    }
    public PageReference last(){
        offset = (totalpages -1)* NUMBER_OF_EVENTS_IN_BATCH;
        currentpage = totalpages;
        return null;
    }
    public PageReference changePage(){
        offset = (currentpage -1)* NUMBER_OF_EVENTS_IN_BATCH;
        return null;
    }
    
     
    private void setParentIds(String calledFrom){
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
    }
    
    private void childEventDetails(){         
        List<Medical_Event_vod__c> childEvnts = [Select 
        parent_medical_event_gne__c, City_Name_gne__c, State_Province_Code_gne__c, 
        Speakers_Name_gne__c From Medical_Event_vod__c
        Where Parent_Event_gne__c = 'False'
        And parent_medical_event_gne__c in :parentEvntIds];
        
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
    }

    public eventWrapper[] getRecords(){

        List<eventWrapper> batchEvts = new List<eventWrapper>();

        for(integer idx = offset; ((idx < offset + NUMBER_OF_EVENTS_IN_BATCH) && (idx  < evnts.size())); idx++){
            batchEvts.add(evnts.get(idx));
        }

        return batchEvts;
    }
    
    public eventWrapper[] getAllSpeakerBureauEvents(){    
        String city;
        String spkr;
        evnts.clear();   
        parentEvntIds.clear();     
        spList = [Select Id, Medical_Event_gne__r.Name, 
        Medical_Event_gne__r.Start_Date_vod__c, Medical_Event_gne__r.Start_Time_gne__c,
        Event_Status_gne__c, Medical_Event_gne__r.event_medium_type_gne__c, Medical_Event_gne__r.Speakers_Name_gne__c                      
        FROM Event_Bureaus_gne__c  
        Where Speaker_Bureau_gne__c = :speakerBureauId 
        and Medical_Event_gne__r.Parent_Event_gne__c = 'True'
        Order By createdDate desc, Event_Status_gne__c limit :NUMBER_OF_EVENTS_TOTAL];      
        
        setParentIds('SpkrBureau');          
        if(spList.size() == 0){
            evnts = new List<eventWrapper>();
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
    
    
    
    
    public class eventWrapper{
    
        public String Id {get;set;}
        public String EventId {get;set;}
        public String EventName {get;set;}
        public String EventStartDate {get;set;}
        public String EventStartTime {get;set;}
        public String EventMedium {get;set;}
        public String City {get;set;}
        public String Status {get;set;}
        public String Speaker {get;set;}
        public eventWrapper(Event_Attendee_vod__c ea, String eCity, String eState){      
            Id = ea.Id;
            EventId = ea.Medical_Event_vod__c;
            EventName = ea.Medical_Event_vod__r.Name;
            EventStartDate = ea.Start_Date_gne__c.month() + '/' + ea.Start_Date_gne__c.day() + '/' + ea.Start_Date_gne__c.year();
            EventStartTime = ea.Medical_Event_vod__r.Start_Time_gne__c;
            EventMedium = ea.Medical_Event_vod__r.event_medium_type_gne__c;
            City = eCity;
            Status = ea.Status_vod__c;      
            Speaker= ea.Medical_Event_vod__r.Speakers_Name_gne__c;    
        }
        
        public eventWrapper(Medical_event_vod__c me, String eCity, String eState){
            Id = null;
            EventId = me.id;
            EventName = me.Name;
            EventStartDate = me.Start_Date_vod__c.month() + '/' + me.Start_Date_vod__c.day() + '/' + me.Start_Date_vod__c.year();
            EventStartTime = me.Start_Time_gne__c;
            EventMedium = me.event_medium_type_gne__c;
            City = eCity;
            Status = '';
            Speaker = me.Speakers_Name_gne__c; 
        }
        
        public eventWrapper(Event_Bureaus_gne__c sb, String eCity, String eSpkr){
            Id = sb.id;
            EventId = sb.Medical_Event_gne__c;
            EventName = sb.Medical_Event_gne__r.Name;
            EventStartDate = sb.Medical_Event_gne__r.Start_Date_vod__c.month() + '/' + sb.Medical_Event_gne__r.Start_Date_vod__c.day() + '/' + sb.Medical_Event_gne__r.Start_Date_vod__c.year();
            EventStartTime = sb.Medical_Event_gne__r.Start_Time_gne__c;
            EventMedium = sb.Medical_Event_gne__r.event_medium_type_gne__c;
            City = eCity;
            Status = sb.Event_Status_gne__c;
            Speaker = eSpkr;
        }
    }

}