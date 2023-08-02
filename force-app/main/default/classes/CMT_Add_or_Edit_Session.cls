public with sharing class CMT_Add_or_Edit_Session 
{
    private ApexPages.StandardController controller;
    public CMT_Session_gne__c session;
    public List<CMT_FranchiseToSession_gne__c> frToSess {get; set;}
    public CMT_FranchiseToSession_gne__c frToSession {get; set;}
    public String sessionsStart {get; set;}
    public String sessionsEnd {get; set;}
    public String meetingId; 
    public String franchiseId;
    public String frId
    {
        get
        {
            return franchiseId;
        }
        set;
    }
    public String sessionId;
    
    public List<CMT_Agenda_gne__c> agendas {get; set;}
    
    public CMT_Add_or_Edit_Session(ApexPages.StandardController controller)
    {
        Integer timezoneOffset = CMT_MiscUtils.getCurrentUserTimezoneOffset();
        PageReference pageRef = System.currentPageReference();
        String url = pageRef.getUrl();
        franchiseId = pageRef.getParameters().get('fid');
        meetingId = pageRef.getParameters().get('mid');
        sessionId = pageRef.getParameters().get('id');
        if(sessionId == null)
        {
            session = new CMT_Session_gne__c();
            frToSess = new List<CMT_FranchiseToSession_gne__c>();
            frToSession = new CMT_FranchiseToSession_gne__c();
        }
        else
        {
            session = [Select Id, Name, Start_Time_gne__c, Room_Name_gne__c, Location_gne__c, End_Time_gne__c, Description_gne__c from CMT_Session_gne__c where Id =:sessionId];
            frToSess = [Select Id,CMT_Intermediate_Level_gne__c, CMT_Intermediate_Level_gne__r.Name from CMT_FranchiseToSession_gne__c where Session_gne__c =:sessionId AND  Franchise_gne__c =: franchiseId AND Meeting_gne__c =: meetingId];
            frToSession = new CMT_FranchiseToSession_gne__c(CMT_Intermediate_Level_gne__c = frToSess[0].CMT_Intermediate_Level_gne__c);
            //session = CMT_MiscUtils.convertSessionTimezonesForDisplay(session, timezoneOffset);
            system.debug('----session.Start_Time_gne__c'+session.Start_Time_gne__c);
            if(session.Start_Time_gne__c != null)
                sessionsStart = session.Start_Time_gne__c.formatGMT('MM/dd/yyyy hh:mm a').toLowerCase();
            if(session.End_Time_gne__c != null)
                sessionsEnd = session.End_Time_gne__c.formatGMT('MM/dd/yyyy hh:mm a').toLowerCase();
        }
        
        agendas = [Select Id from CMT_Agenda_gne__c where Meeting_gne__c =:meetingId];
    }
    public CMT_Session_gne__c getSession()
    {
        return this.session;
    }
    public void setSession(CMT_Session_gne__c ses)
    {
        this.session = ses;
    }
    public PageReference save()
    {
        // assign meetingId only if session is not saved, otherwise the master-detail 
        // Commercial_Meeting_gne__c field will not be writeable
        if (sessionId == null)
        {
            session.Commercial_Meeting_gne__c = meetingId;
        }
        if(sessionsStart != '')
        {
            String[] datetimesplitStart = sessionsStart.split(' ');
            String[] datesplitStart = datetimesplitStart[0].split('/');
            String[] timesplitStart = datetimesplitStart[1].split(':');
            Integer hourStart;
            if(datetimesplitStart[2]=='PM' && timesplitStart[0] != '12')
                hourStart = integer.valueof(timesplitStart[0]) + 12;
            else if(datetimesplitStart[2]=='AM' && timesplitStart[0] == '12')
                hourStart = integer.valueof(timesplitStart[0]) - 12;
            else
                hourStart = integer.valueof(timesplitStart[0]);
            session.Start_Time_gne__c = datetime.newInstanceGmt(integer.valueof(datesplitStart[2]), integer.valueof(datesplitStart[0]), integer.valueof(datesplitStart[1]), hourStart, integer.valueof(timesplitStart[1]), 0);
        }
        else
            session.Start_Time_gne__c = null;

        if(sessionsEnd != '')
        {
            String[] datetimesplitEnd = sessionsEnd.split(' ');
            String[] datesplitEnd = datetimesplitEnd[0].split('/');
            String[] timesplitEnd = datetimesplitEnd[1].split(':');
            Integer hourEnd;            
            if(datetimesplitEnd[2]=='PM' && timesplitEnd[0] != '12')
                hourEnd = integer.valueof(timesplitEnd[0]) + 12;
            else if(datetimesplitEnd[2]=='AM' && timesplitEnd[0] == '12')
                hourEnd = integer.valueof(timesplitEnd[0]) - 12;
            else
                hourEnd = integer.valueof(timesplitEnd[0]);
            session.End_Time_gne__c = datetime.newInstanceGmt(integer.valueof(datesplitEnd[2]), integer.valueof(datesplitEnd[0]), integer.valueof(datesplitEnd[1]), hourEnd, integer.valueof(timesplitEnd[1]), 0);
        }
        else
            session.End_Time_gne__c = null;
        if(session.Start_Time_gne__c > session.End_Time_gne__c)
        {
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR ,'Start time cannot be greater than end time.'));
            return null;
        }    
        upsert session;
     
        system.debug('----------------'+frToSession);
        if (frToSess.size()==0)
        {
            CMT_FranchiseToSession_gne__c tmpFTS = new CMT_FranchiseToSession_gne__c();
            tmpFTS.Meeting_gne__c = meetingId;
            tmpFTS.Session_gne__c = session.Id;
            tmpFTS.Franchise_gne__c = franchiseId;
            tmpFTS.Agenda_gne__c = agendas[0].Id;
            tmpFTS.CMT_Intermediate_Level_gne__c = frToSession.CMT_Intermediate_Level_gne__c;
            insert tmpFTS;
        }
        else if(frToSession.CMT_Intermediate_Level_gne__c != null)
        {
            frToSess[0].CMT_Intermediate_Level_gne__c = frToSession.CMT_Intermediate_Level_gne__c;
            update frToSess;
        }
        
        String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);
        String redirectURL = partOneURL + 'apex/CMT_Franchise_Sessions?mid='+meetingId+'&fid='+franchiseId;
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
    public PageReference cancel()
    {
        String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);
        String redirectURL = partOneURL + 'apex/CMT_Franchise_Sessions?mid='+meetingId+'&fid='+franchiseId;
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