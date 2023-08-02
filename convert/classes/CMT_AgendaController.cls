public with sharing class CMT_AgendaController
{
    public List<CMT_SessionWrapper> sessions { get; private set; }
    public String meetingId { get; set; }
    public String agendaId { get; private set; }
    private String agendaSortExp = 'CreatedDate'; 
    private String agendaSortDirection = 'ASC';
    
    public PageReference init()
    {
        meetingId = System.currentPageReference().getParameters().get('meetingId');
        
        if (meetingId == null)
        {
            throw new CMT_Exception('Meeting ID is null');  
        }
        
        List<CMT_Agenda_gne__c> agendas = [SELECT Id FROM CMT_Agenda_gne__c WHERE Meeting_gne__c = :meetingId LIMIT 1];
        if (agendas == null || agendas.isEmpty())
        {
            throw new CMT_Exception('No agenda found for the meeting');
        }
        agendaId = agendas.get(0).Id;
        
        List<CMT_FranchiseToSession_gne__c> fts = [Select Franchise_gne__r.Name, 
                        Session_gne__r.Start_Time_gne__c, Session_gne__r.End_Time_gne__c, 
                        Session_gne__r.Location_gne__c, Session_gne__r.Room_Name_gne__c, Session_gne__r.Name, Session_gne__r.Description_gne__c, Session_gne__r.Id
                        from CMT_FranchiseToSession_gne__c where Agenda_gne__r.Meeting_gne__c = :meetingId];
                        
        sessions = wrapSessions(fts);
        return null;
    }
    
    // sort agenda items
    public PageReference sortAgenda()
    {
        SuperSort.sortList(sessions, agendaSortExpression, agendaSortDirection);
        return null;
    }
    public String agendaSortExpression
    {
        get
        {
            return agendaSortExp;
        }
        set
        {
            //if the column is clicked on then switch between Ascending and Descending modes
            if (value == agendaSortExp) {
                agendaSortDirection = (agendaSortDirection == 'ASC')? 'DESC' : 'ASC';
            } else {
                agendaSortDirection = 'ASC';
            }
            agendaSortExp = value;
        }
    }
    public String getAgendaSortDirection()
    {
        //if no column is selected 
        if (agendaSortExpression == null || agendaSortExpression == '') {
            return 'ASC';
        } else {
            return agendaSortDirection;
        }
    }

    public void setAgendaSortDirection(String value)
    {  
        agendaSortDirection = value;
    }
    
    private static List<CMT_SessionWrapper> wrapSessions (List<CMT_FranchiseToSession_gne__c> fts)
    {
        List<CMT_SessionWrapper> items = new List<CMT_SessionWrapper>();
        
        for (CMT_FranchiseToSession_gne__c res : fts)
        {
            CMT_SessionWrapper item = new CMT_SessionWrapper();
            
            if (res.Franchise_gne__r.Name != null)
            {
                item.franchiseName = res.Franchise_gne__r.Name; 
            }
            if (res.Session_gne__r.Name != null)
            {
                item.sessionName = res.Session_gne__r.Name; 
            }
            if (res.Session_gne__r.Start_Time_gne__c != null)
            {
                item.startTime = res.Session_gne__r.Start_Time_gne__c.format('MM/dd/yyyy hh:mm a', 'GMT'); 
            }
            if (res.Session_gne__r.End_Time_gne__c != null)
            {
                item.endTime = res.Session_gne__r.End_Time_gne__c.format('MM/dd/yyyy hh:mm a', 'GMT'); 
            }
            if (res.Session_gne__r.Location_gne__c != null)
            {
                item.location = res.Session_gne__r.Location_gne__c; 
            }
            if (res.Session_gne__r.Room_Name_gne__c!= null)
            {
                item.roomName = res.Session_gne__r.Room_Name_gne__c; 
            }
            if (res.Session_gne__r.Description_gne__c!= null)
            {
                item.description = res.Session_gne__r.Description_gne__c; 
            }
            
            items.add(item);
        }
        return items;
    }
    public PageReference goToMeeting()
    {
        String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);
        String redirectURL = partOneURL + 'apex/CMT_Event_Summary_Page?id='+meetingId;
        PageReference pageRef = new PageReference(redirectURL);
        pageRef.setRedirect(true);
        return pageRef;
    }
}