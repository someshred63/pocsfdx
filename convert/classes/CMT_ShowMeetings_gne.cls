public with sharing class CMT_ShowMeetings_gne extends CMT_PaginationBase
{
    private List<CMT_Meeting_gne__c> comMeetings;
    public CMT_Meeting_gne__c proxyMtg {get; set;}
    private Map<String, Boolean> sortDirection;
    private String startDate_Search {get; set;}
    private String endDate_Search {get; set;}
    public String location_Search {get; set;}
    public Boolean isActive_Search {get; set;}
    public Boolean isArchived_Search {get; set;}
    public String sortImage {get; set;}
    public String sortField {get; set;}
    public List<CMT_Meeting_gne__c> pagedMeetings
    {
        get
        {
            ApexPages.Standardsetcontroller mtgSet = getSetController();
            List<CMT_Meeting_gne__c> results = new List<CMT_Meeting_gne__c>();
            for(CMT_Meeting_gne__c mtg : (List<CMT_Meeting_gne__c>)mtgSet.getRecords())
            {
                results.add(mtg);
            }
            return results;
        }
        private set;
    }
    public String passId{get; set;}
    
    public CMT_ShowMeetings_gne()
    {
        sortDirection = new Map<String, Boolean>();
        proxyMtg = new CMT_Meeting_gne__c();
        getMeetings();
    }
    public PageReference getAllMeetings(){
    	    proxyMtg = new CMT_Meeting_gne__c();
            location_Search = '';
            isActive_Search = null;
            isArchived_Search = null;
    		getMeetings();
    		return null;
    
    }
    public void getMeetings()
    {
        PageReference pageRef = System.currentPageReference();
        String url = pageRef.getUrl();
        if(proxyMtg != null)
        {
            startDate_Search = String.valueof(proxyMtg.Start_Date_gne__c);
        }
        if(proxyMtg != null)
        {
            endDate_Search = String.valueOf(proxyMtg.End_Date_gne__c);
        }
        String basicQuerry = 'Select Id, Title_gne__c, Meeting_Type_gne__c, Is_Meeting_Active_gne__c, Start_Date_gne__c, End_Date_gne__c, Location_gne__c, Is_Archived__c'
                                        +' from CMT_Meeting_gne__c';
        if(startDate_Search == null && endDate_Search == null && location_Search == null && isActive_Search == null && isArchived_Search == null)
        {
            basicQuerry = basicQuerry;
        }
        else if(startDate_Search != null && endDate_Search != null)
        {
            String startDateCondition = ' (Start_Date_gne__c >= '+String.escapeSingleQuotes(startDate_Search)+' AND Start_Date_gne__c <= '+String.escapeSingleQuotes(endDate_Search)+')';
            String endDateCondition = ' (End_Date_gne__c >= '+String.escapeSingleQuotes(startDate_Search)+' AND End_Date_gne__c <= '+String.escapeSingleQuotes(endDate_Search)+')';
             
            if(basicQuerry.contains('Where'))
            {
                basicQuerry += ' AND' + startDateCondition + ' AND '+endDateCondition;
            }
            else
            {
                basicQuerry += ' Where '+ startDateCondition + ' AND '+endDateCondition;
            }
        }
        else if(startDate_Search != null && endDate_Search == null)
        {
            String startDateCondition = ' Start_Date_gne__c >= '+String.escapeSingleQuotes(startDate_Search);
            String endDateCondition = ' End_Date_gne__c >= '+String.escapeSingleQuotes(startDate_Search);
            if(basicQuerry.contains('Where'))
            {
                basicQuerry += ' AND' + startDateCondition +' AND '+endDateCondition;
            }
            else
            {
                basicQuerry += ' Where '+ startDateCondition +' AND '+ endDateCondition;
            }
        }
        else if(startDate_Search == null && endDate_Search != null)
        {
            String endDateCondition = ' End_Date_gne__c <= '+String.escapeSingleQuotes(endDate_Search);
            String startDateCondition = ' Start_Date_gne__c <= '+String.escapeSingleQuotes(endDate_Search);
            if(basicQuerry.contains('Where'))
            {
                basicQuerry += ' AND' + startDateCondition +' AND '+ endDateCondition;
            }
            else
            {
                basicQuerry += ' Where '+ startDateCondition +' AND '+ endDateCondition;
            }   
        }
        
        if(location_Search != null && location_Search !='')
        {
            String locationCondition = ' Location_gne__c = \'' + String.escapeSingleQuotes(location_Search) + '\'';
            if(basicQuerry.contains('Where'))
            {
                basicQuerry += ' AND' + locationCondition;
            }
            else
            {
                basicQuerry += ' Where '+ locationCondition;
            }
        }
       
       if(isActive_Search != null)
        {
            String activeCondition = ' Is_Meeting_Active_gne__c = '+ String.escapeSingleQuotes(String.valueOf(isActive_Search));
            if(basicQuerry.contains('Where'))
            {
                basicQuerry += ' AND' + activeCondition;
            }
            else
            {
                basicQuerry += ' Where '+ activeCondition;
            }
        }
       if(isArchived_Search != null)
        {
            String activeCondition = ' Is_Archived__c = '+ String.escapeSingleQuotes(String.valueOf(isArchived_Search));
            if(basicQuerry.contains('Where'))
            {
                basicQuerry += ' AND' + activeCondition;
            }
            else
            {
                basicQuerry += ' Where '+ activeCondition;
            }
        }
        system.debug('>>>>>>>>>>>>>>basicQuerry= '+basicQuerry);
        comMeetings = Database.query(basicQuerry);
        initSetController(comMeetings, 4);
    }
    public void doSort()
    {       
        String sortingOrder;        
        if(getSortDirection(sortField))
        {
            sortingOrder = 'asc';
            sortImage='/resource/CMT_Images/CMT_Images/asc.gif';
        }
        else
        {
            sortingOrder = 'desc';
            sortImage = '/resource/CMT_Images/CMT_Images/desc.gif';
        }
        SuperSort.sortList(comMeetings, sortField, sortingOrder);
        initSetController(comMeetings, 4);
    }
    private Boolean getSortDirection(String sortField)    
    {       
        if(sortDirection.keySet().contains(sortField))
        {
            Boolean isAsc = !sortDirection.get(sortField);
            sortDirection.put(sortField, isAsc);
        }
        else
        {
            sortDirection.put(sortField, false);
        }
        return sortDirection.get(sortField);    
    }
    public PageReference deleteMeeting()
    {
        PageReference pageRef = System.currentPageReference();
        String meetingId = passId;//pageRef.getParameters().get('mId');
        if(meetingId != null || meetingId !='')
        {
            CMT_Meeting_gne__c meeting = [Select Id from CMT_Meeting_gne__c where Id =: meetingId];
            delete meeting;
        }
        pageRef.setRedirect(true);
        return pageRef;
    }
        
    public PageReference archiveMeeting()
    {
        PageReference pageRef = ApexPages.currentPage();
        String meetingId = passId;//pageRef.getParameters().get('mId');
        System.debug('Archive ______________________'+meetingId);
        if(meetingId != null || meetingId !='')
        {
            CMT_Meeting_gne__c meeting = [Select Id, Is_Archived__c from CMT_Meeting_gne__c where Id =: meetingId];
            meeting.Is_Archived__c=true;
            update meeting;
        }
        pageRef.setRedirect(true);
        return pageRef;
    }
   
   public PageReference restoreMeeting(){
        PageReference pageRef = ApexPages.currentPage();
 	    String meetingId = passId;//pageRef.getParameters().get('mId');
 	    System.debug('Restore ______________________'+meetingId);
        if(meetingId != null || meetingId !='')
        {
            CMT_Meeting_gne__c meeting = [Select Id, Is_Archived__c from CMT_Meeting_gne__c where Id =: meetingId];
            meeting.Is_Archived__c=false;
            update meeting;
        }
      pageRef.setRedirect(true);
      return pageRef;      
    }   
     
    public PageReference viewDetails()
    {
        String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);  
        PageReference currentPageRef = System.currentPageReference();
        String meetingId = passId;//currentPageRef.getParameters().get('mId');
        String redirectURL = partOneURL + 'apex/CMT_Event_Summary_Page?id='+meetingId;
        if(meetingId != null || meetingId !='')
        {
            PageReference pageRef = new PageReference(redirectURL);
            pageRef.setRedirect(true);
            return pageRef;
        }
        else
        {
            return null;
        }
    }
    public PageReference addNewMeeting()
    {
        String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);
        String redirectURL = partOneURL + 'apex/CMT_New_Meeting';
        PageReference pageRef = new PageReference(redirectURL);
        pageRef.setRedirect(true);
        return pageRef;
    }
    public PageReference editMeeting()
    {
        String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);  
        PageReference currentPageRef = System.currentPageReference();
        String meetingId = passId;//currentPageRef.getParameters().get('mId');
        String redirectURL = partOneURL + 'apex/CMT_New_Meeting?id='+meetingId;
        if(meetingId != null || meetingId !='')
        {
            PageReference pageRef = new PageReference(redirectURL);
            pageRef.setRedirect(true);
            return pageRef;
        }
        else
        {
            return null;
        }
    }    
}