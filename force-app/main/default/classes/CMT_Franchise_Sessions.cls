public with sharing class CMT_Franchise_Sessions
{
	private ApexPages.StandardController controller;
	public String meetingId;
	public String franchiseId;
	public CMT_Franchise_gne__c franchise;
	public List<CMT_Session_gne__c> sessions {get; set;}
	public List<WrappedSession> wrappedSessions {get; set;}
	public List<CMT_Intermediate_Level_gne__c> tumors {get; set;}
	public List<CMT_FranchiseToSession_gne__c> franToSess {get; set;}
	public List<CMT_Franchise_gne__c> frList {get; set;}
	private String sessionSortExp = 'CreatedDate';
	private String sessionSortDirection = 'ASC';
	
	public CMT_Franchise_Sessions(ApexPages.StandardController controller)
	{
		PageReference pageRef = System.currentPageReference();
		franchiseId = pageRef.getParameters().get('fid');
		meetingId = pageRef.getParameters().get('mid');
		frList = [Select Name from CMT_Franchise_gne__c where Id =: franchiseId];
		if(frList != null && frList.size()>0)
		{
	    	franchise = frList[0];
		}
		franchiseSessions(franchiseId);
		getTumorsForFranchise(franchiseId);
	}
	public CMT_Franchise_gne__c getFranchise()
	{
		return this.franchise;
	}
	public void setFranchise(CMT_Franchise_gne__c frc)
	{
		this.franchise = frc;
	}
	public PageReference addSession()
	{
		String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);
        String redirectURL = partOneURL + 'apex/CMT_Session?mid='+meetingId+ '&fid='+franchiseId;
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
	public PageReference editSession()
	{
		String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);
        PageReference current = System.currentPageReference();
		String sessionId = current.getParameters().get('sid');
        String redirectURL = partOneURL + 'apex/CMT_Session?mid='+meetingId+ '&fid='+franchiseId + '&id='+sessionId;
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
	public PageReference deleteSession()
	{
		PageReference current = System.currentPageReference();
		String sessionId = current.getParameters().get('sid');
		CMT_Session_gne__c sessionToDel = [Select Id from CMT_Session_gne__c where Id =: sessionId];
		delete sessionToDel;
		PageReference pr = new PageReference('/apex/CMT_Franchise_Sessions?fid='+franchiseId+'&mid='+meetingId);
		pr.setRedirect(true);
		return pr;
	}
	

	public PageReference viewSession()
	{
		String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);
        PageReference current = System.currentPageReference();
		String sessionId = current.getParameters().get('sid');
        String redirectURL = partOneURL + 'apex/CMT_Franchise_Sessions_View?mid='+meetingId+ '&fid='+franchiseId + '&sid='+sessionId;
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
	
	public PageReference addTumor()
	{
		String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);
        String redirectURL = partOneURL + 'apex/CMT_SubGroup?mid='+meetingId+ '&fid='+franchiseId;
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
	private List<CMT_Session_gne__c> franchiseSessions(String frId)
	{
		franToSess = [Select Session_gne__c,CMT_Intermediate_Level_gne__r.Name,CMT_Intermediate_Level_gne__r.Parent_Id_gne__r.Name from CMT_FranchiseToSession_gne__c where Franchise_gne__c =:frId];
		Map<Id,CMT_FranchiseToSession_gne__c> tmpSessIds = new Map<Id,CMT_FranchiseToSession_gne__c>();
		for(CMT_FranchiseToSession_gne__c fts : franToSess)
		{
			tmpSessIds.put(fts.Session_gne__c,fts);
		}
		sessions = [Select Name, Start_Time_gne__c, End_Time_gne__c, Location_gne__c, Room_Name_gne__c, Description_gne__c, Commercial_Meeting_gne__c from CMT_Session_gne__c where Id IN: tmpSessIds.keySet()];
		/*
		Integer timezoneOffset = CMT_MiscUtils.getCurrentUserTimezoneOffset();
		
		if (sessions != null)
		{
			for (CMT_Session_gne__c session : sessions)
			{
				session = CMT_MiscUtils.convertSessionTimezonesForDisplay(session, timezoneOffset);
			}
		}*/  
		wrappedSessions = new List<WrappedSession>();
		for(CMT_Session_gne__c session: sessions)
		{
			WrappedSession ws = new WrappedSession(); 
			ws.id = session.Id;
			ws.sessionName = session.Name;
			if(session.Start_Time_gne__c != null)
				ws.startTime = session.Start_Time_gne__c.formatGMT('MM/dd/yyyy hh:mm a');
			if(session.End_Time_gne__c != null)
				ws.endTime = session.End_Time_gne__c.formatGMT('MM/dd/yyyy hh:mm a'); 
			ws.location = session.Location_gne__c;
			ws.roomName = session.Room_Name_gne__c;
			ws.description = session.Description_gne__c;
			if(tmpSessIds.get(session.Id).CMT_Intermediate_Level_gne__r.Parent_Id_gne__r.Name != null)
			{
				ws.tumorName = tmpSessIds.get(session.Id).CMT_Intermediate_Level_gne__r.Parent_Id_gne__r.Name + ',' + tmpSessIds.get(session.Id).CMT_Intermediate_Level_gne__r.Name;
			}
			else if(tmpSessIds.get(session.Id).CMT_Intermediate_Level_gne__r.Name != null)
			{
				ws.tumorName = tmpSessIds.get(session.Id).CMT_Intermediate_Level_gne__r.Name;
			}
			else
			{
				ws.tumorName = '';
			}
			wrappedSessions.add(ws);
		}
		
		return sessions;
	}
	
	private void getTumorsForFranchise(String frId)
	{
		tumors = [Select Name from CMT_Intermediate_Level_gne__c where CMT_Franchise_gne__c  =: franchiseId and Parent_Id_gne__c = null];
	}
	
	
	public String sessionSortExpression
    {
        get
        {
            return sessionSortExp;
        }
        set
        {
            //if the column is clicked on then switch between Ascending and Descending modes
            if (value == sessionSortExp) {
                sessionSortDirection = (sessionSortDirection == 'ASC')? 'DESC' : 'ASC';
            } else {
                sessionSortDirection = 'ASC';
            }
            sessionSortExp = value;
        }
    }
    public String getSessionSortDirection()
    {
        //if no column is selected 
        if (sessionSortExpression == null || sessionSortExpression == '') {
            return 'ASC';
        } else {
            return sessionSortDirection;
        }
    }

    public void setSessionSortDirection(String value)
    {  
        sessionSortDirection = value;
    }
    public PageReference sortSession() 
    {
        SuperSort.sortList(wrappedSessions, sessionSortExp, sessionSortDirection);
        return null;
    }
    
    public PageReference editTumor()
	{
		String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);
        PageReference current = System.currentPageReference();
		String tumorId = current.getParameters().get('tid');
        String redirectURL = partOneURL + 'apex/CMT_IntermediateLevel?mid='+meetingId+ '&fid='+franchiseId + '&id='+tumorId;
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
	public PageReference deleteTumor()
	{
		PageReference current = System.currentPageReference();
		String tumorId = current.getParameters().get('tid');
		List<CMT_Intermediate_Level_gne__c> tumorToDel = [Select Id from CMT_Intermediate_Level_gne__c where Id =: tumorId or Parent_Id_gne__c=:tumorId];
		delete tumorToDel;
		PageReference pr = new PageReference('/apex/CMT_Franchise_Sessions?fid='+franchiseId+'&mid='+meetingId);
		pr.setRedirect(true);
		return pr;
	}
	

	public PageReference viewTumor()
	{
		String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);
        PageReference current = System.currentPageReference();
		String tumorId = current.getParameters().get('tid');
        String redirectURL = partOneURL + 'apex/CMT_Franchise_Tumors_View?mid='+meetingId+ '&fid='+franchiseId + '&id='+tumorId;
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
	
	public class WrappedSession implements IReflection
	{
		public String id{get;set;}
        public String sessionName{get;set;}
        public String startTime{get;set;}
        public String endTime{get;set;}
        public String location{get;set;}
        public String roomName{get;set;}
        public String description{get;set;}   
        public String tumorName{get;set;}
        
        public object getValue(String name)
        {
            object result = null;
            if(name == 'id')
            {
                result = id;
            }
            if(name == 'sessionName')
            {
                result = sessionName;
            }
            else if(name == 'startTime')
            {
                result = startTime;
            }
            else if(name == 'endTime')
            {
                result = endTime;
            } 
            else if(name == 'location')
            {
                result = location;
            } 
            else if(name == 'roomName')
            {
                result = roomName;
            } 
            else if(name == 'tumorName')
            {
                result = tumorName;
            } 
            else if(name == 'description')
            {
                result = description;
            }            
            return result;
       }
        
	}
}