public with sharing class CONGA_EventProperties {
    
    
    //TODO check if timezone is required if so, please check for CMT_Meeting_PropertiesTimeZone
    public ID id { get; set; }
    public String name { get; set; }
    public DateTime startDate { get; set; }
    public DateTime endDate { get; set; }
    public ID locationId{get;set;}     
    public List<String> eventCategories{ get; set; }    
    public List<String> keyTargetAudience {get;set;}
    public String description{get;set;}
    public Boolean isActive; 
    public String isGlobalOncology {get;set;}
    public String businessUnit {get;set;}
    
    public CONGA_EventProperties (CONGA_Event_gne__c e)
    {
        init(e);
    }
    
    public void init (CONGA_Event_gne__c e)
    {
        id = e.id; 
        Name = e.name; 
        StartDate = e.Start_Date__c;
        EndDate = e.End_Date__c; 
        if(e.Global_Oncology__c == 'Yes'){
        	this.isGlobalOncology = '1';
        }
        if(e.Global_Oncology__c == 'No'){
        	this.isGlobalOncology = '0';
        }
        if(e.BU__c == '-- None --'){
        	e.BU__c = null;
        } else {
        	this.businessUnit = e.BU__c;	
        }
        if (e.Event_Category__c!= null){
            EventCategories = new List<String>(); 

            for (String cat : e.Event_Category__c.split(';') )
                EventCategories.add(cat); 
        }

        if (e.Key_Target_Audience__c!= null){
            KeyTargetAudience = new List<String>(); 

            for (String targetAudience : e.Key_Target_Audience__c.split(';') )
                KeyTargetAudience.add(targetAudience); 
        }
        this.locationId = e.Event_Location__c; 
        this.description = e.Description__c; 
        this.isActive = e.isActive__c; 
    }

}