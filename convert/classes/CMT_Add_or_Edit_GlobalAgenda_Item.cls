public with sharing class CMT_Add_or_Edit_GlobalAgenda_Item 
{
     
    public List<CMT_Franchise_gne__c> allFranchises {get; set;}
    public List<CMT_FranchiseToSession_gne__c> frToSessList {get; set;}
    public Set<String> assignedFranchises {get; set;}
    public CMT_Session_gne__c session;
    public String meetingId { get; set; }
    public String sessionId;
    public CMT_Agenda_gne__c agenda;
    public List<String> franchisesIds {get; set;}
    public String sessionsStart {get; set;}
    public String sessionsEnd {get; set;}
    
    public CMT_Add_or_Edit_GlobalAgenda_Item(ApexPages.StandardController controller)
    {
        PageReference pageRef = System.currentPageReference();
        meetingId = pageRef.getParameters().get('mid');
        sessionId = pageRef.getParameters().get('sid');
        List<CMT_Agenda_gne__c> agendas = [Select Id from CMT_Agenda_gne__c where Meeting_gne__c =: meetingId LIMIT 1];
        
        if (agendas != null && !agendas.isEmpty())
        {
            agenda = agendas.get(0);
        }
        
        allFranchises = [Select Id, Name from CMT_Franchise_gne__c where Meeting_gne__c =: meetingId];
        if(sessionId == null || sessionId=='')
        {
            session = new CMT_Session_gne__c();
            assignedFranchises = new Set<String>(); 
            franchisesIds = new List<String>(); 
        }
        else
        {
            session = [Select Id, Name, Start_Time_gne__c, End_Time_gne__c, Location_gne__c, Room_Name_gne__c, Description_gne__c, Commercial_Meeting_gne__c from CMT_Session_gne__c where Id =: sessionId];
            
            // convert timezones for display
            //Integer timezoneOffset = CMT_MiscUtils.getCurrentUserTimezoneOffset();
            //session = CMT_MiscUtils.convertSessionTimezonesForDisplay(session, timezoneOffset);
            if(session.Start_Time_gne__c != null)
                sessionsStart = session.Start_Time_gne__c.formatGMT('MM/dd/yyyy hh:mm a').toLowerCase();
            if(session.End_Time_gne__c != null)
                sessionsEnd = session.End_Time_gne__c.formatGMT('MM/dd/yyyy hh:mm a').toLowerCase();
                
            List<CMT_FranchiseToSession_gne__c> tmp = [Select Franchise_gne__c from CMT_FranchiseToSession_gne__c where Session_gne__c =: sessionId];
            assignedFranchises = new Set<String>();
            franchisesIds = new List<String>();
            for(CMT_FranchiseToSession_gne__c item : tmp)
            {
                assignedFranchises.add(item.Franchise_gne__c);
            }
            for(String fts : assignedFranchises)
            {
                franchisesIds.add(fts);
            }
            system.debug('franchisesIds= '+franchisesIds);
        }
    }
    
    public CMT_Session_gne__c getSession()
    {
        return this.session;
    }
    public void setSession(CMT_Session_gne__c ses)
    {
        this.session = ses;
    }
    public List<SelectOption> getItems()
    {
         List<SelectOption> options = new List<SelectOption>();
         for(CMT_Franchise_gne__c fr : allFranchises)
         {
            options.add(new SelectOption(fr.Id,fr.Name));
         }
         return options;
    }
    
    /*public String[] getFranchisesIds()
    {
        
        return franchisesIds;
    }
    public void setFranchisesIds(String[] franchisesIds)
    {
        this.franchisesIds = franchisesIds;
    }*/
    public PageReference addSession()
    {
        if (franchisesIds == null || franchisesIds.isEmpty())
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please select at least one franchise'));
            return null;
        }
        
        if(assignedFranchises.size() == 0)
        {   
            session.Commercial_Meeting_gne__c = meetingId;
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
            insert session; 
            frToSessList = new List<CMT_FranchiseToSession_gne__c>();
            for(String fr : franchisesIds)
            {
                CMT_FranchiseToSession_gne__c tmpFrToSess = new CMT_FranchiseToSession_gne__c();
                tmpFrToSess.Agenda_gne__c = agenda.Id;
                tmpFrToSess.Franchise_gne__c = fr;
                tmpFrToSess.Meeting_gne__c = meetingId;
                tmpFrToSess.Session_gne__c = session.Id;
                frToSessList.add(tmpFrToSess);
            }
            insert frToSessList;
        }
        else
        {
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
            frToSessList = new List<CMT_FranchiseToSession_gne__c>();
            List<String> frToSessIdDel = new List<String>();
            Set<String> franchisesIdSet = new Set<String>();
            for(String frId : franchisesIds)
            {
                franchisesIdSet.add(frId);
            }
            for(String fid1 : franchisesIdSet)
            {
                if(!assignedFranchises.contains(fid1))
                {
                    CMT_FranchiseToSession_gne__c tmpFrToSess = new CMT_FranchiseToSession_gne__c();
                    tmpFrToSess.Agenda_gne__c = agenda.Id;
                    tmpFrToSess.Franchise_gne__c = fid1;
                    tmpFrToSess.Meeting_gne__c = meetingId;
                    tmpFrToSess.Session_gne__c = session.Id;
                    frToSessList.add(tmpFrToSess);
                }
            }
            for(String fid2 : assignedFranchises)
            {
                if(!franchisesIdSet.contains(fid2))
                {
                    frToSessIdDel.add(fid2);
                }
            }
            insert frToSessList;
            List<CMT_FranchiseToSession_gne__c> ftsDel = [Select Id from CMT_FranchiseToSession_gne__c where Session_gne__c =: session.Id AND Franchise_gne__c IN :frToSessIdDel];
            delete ftsDel;
        }
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
    public PageReference cancel()
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
    public PageReference selectAll()
    {
        return null;
    }
}