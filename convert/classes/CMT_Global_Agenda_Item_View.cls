public with sharing class CMT_Global_Agenda_Item_View 
{
    private ApexPages.StandardController controller;
    public String meetingId;
    public String sessionId;
    public String franchises {get; set;}
    public CMT_Session_gne__c session {get; set;}
    
    public CMT_Global_Agenda_Item_View(ApexPages.StandardController controller)
    {
        PageReference pageRef = System.currentPageReference();
        meetingId = pageRef.getParameters().get('mid');
        sessionId = pageRef.getParameters().get('sid');
        returnSession(sessionId);
        returnFranchises(sessionId);
    }
    private CMT_Session_gne__c returnSession(String sessionId)
    {
        session = new CMT_Session_gne__c();
        session = [Select Name, Start_Time_gne__c, End_Time_gne__c, Location_gne__c, Room_Name_gne__c, Description_gne__c, Commercial_Meeting_gne__c from CMT_Session_gne__c where Id =: sessionId];
        
        // convert timezones for display
        Integer timezoneOffset = CMT_MiscUtils.getCurrentUserTimezoneOffset();
        session = CMT_MiscUtils.convertSessionTimezonesForDisplay(session, timezoneOffset);
        
        return session;
    }
    private String returnFranchises(String sessionId)
    {
        franchises = '';
        List<CMT_FranchiseToSession_gne__c> tmpFTS = [Select Franchise_gne__r.Name from CMT_FranchiseToSession_gne__c where Session_gne__c =: sessionId];
        for(CMT_FranchiseToSession_gne__c fts : tmpFTS)
        {
            franchises += fts.Franchise_gne__r.Name+', ';
        }
        Integer lastComa = franchises.lastIndexOf(',');
        franchises = franchises.trim();
        franchises = franchises.substring(0, lastComa);
        return franchises;
    }
    public PageReference editSession()
    {
        String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);
        String redirectURL = partOneURL + 'apex/CMT_Global_Agenda?sid='+sessionId+'&mid='+meetingId;
        if((meetingId != null || meetingId !='')&&(sessionId != null || sessionId !=''))
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
    public PageReference deleteSession()
    {
        delete session;
        String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);
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
    public PageReference backToMeeting()
    {
        String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);
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
}