public with sharing class CMT_Franchise_Sessions_View 
{
	private ApexPages.StandardController controller;
	public String franchiseId;
	public String sessionId;
	public String meetingId;
	public CMT_Session_gne__c session {get; set;}
	public CMT_Franchise_gne__c franchise {get; set;}
	public String StartTime {get; set;}
	public String EndTime {get; set;}
	
	public CMT_Franchise_Sessions_View (ApexPages.StandardController controller)
	{
		PageReference pageRef = System.currentPageReference();
		franchiseId = pageRef.getParameters().get('fid');
		sessionId = pageRef.getParameters().get('sid');
		meetingId = pageRef.getParameters().get('mid');
		getSession(sessionId);
		getFranchise(franchiseId);
		if(session != null)
		{
			if(session.Start_Time_gne__c != null)
			{
				StartTime = session.Start_Time_gne__c.formatGMT('MM/dd/yyyy hh:mm a'); 
			}
			if(session.End_Time_gne__c != null)
			{
				EndTime = session.End_Time_gne__c.formatGMT('MM/dd/yyyy hh:mm a');
			}
		}
	}
	private CMT_Session_gne__c getSession(String sessionId)
	{
		session = new CMT_Session_gne__c();
		List<CMT_Session_gne__c> sessions = [Select Name, Start_Time_gne__c, End_Time_gne__c, Location_gne__c, Room_Name_gne__c, Description_gne__c, Commercial_Meeting_gne__c from CMT_Session_gne__c where Id =: sessionId];
		if (sessions != null && !sessions.isEmpty())
		{
			session = sessions.get(0);
		}
		return session;
	}
	private CMT_Franchise_gne__c getFranchise(String franchiseId)
	{
		franchise = new CMT_Franchise_gne__c();
		franchise = [Select Id from CMT_Franchise_gne__c where Id =: franchiseId];
		return franchise;
	}
	public PageReference backToSessions()
	{
		String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);
        String redirectURL = partOneURL + 'apex/CMT_Franchise_Sessions?mid='+meetingId+ '&fid='+franchiseId;
        if((meetingId != null || meetingId !='') && (franchiseId != null || franchiseId !=''))
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
		delete session;
		String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);
        String redirectURL = partOneURL + 'apex/CMT_Franchise_Sessions?mid='+meetingId+ '&fid='+franchiseId;
        if((meetingId != null || meetingId !='') && (franchiseId != null || franchiseId !=''))
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