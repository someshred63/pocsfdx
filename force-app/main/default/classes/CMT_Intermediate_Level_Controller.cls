public without sharing class CMT_Intermediate_Level_Controller {

	private ApexPages.StandardController controller;
	public CMT_Intermediate_Level_gne__c tumor;
    public String franchiseId;
    public String tumorParentId;
	public String tumorId;
	public List<CMT_FranchiseToSession_gne__c> frToSess {get; set;} 
	public List<String> sessions {get; set;}
	public String meetingId;
	public List<CMT_Intermediate_Level_gne__c> associatedLevels {get; set;} 
	public String isParent {get; set;}

	    
	public CMT_Intermediate_Level_Controller(ApexPages.StandardController controller)
    {
		this.controller=controller;
		PageReference pageRef = System.currentPageReference();
    	tumorId = pageRef.getParameters().get('id');
    	meetingId = pageRef.getParameters().get('mid');
        franchiseId = pageRef.getParameters().get('fid');
        tumorParentId = pageRef.getParameters().get('tid');
        isParent = pageRef.getParameters().get('isParent');
        
        frToSess = new List<CMT_FranchiseToSession_gne__c>();
        tumor = new CMT_Intermediate_Level_gne__c();
        sessions = new List<String>();
    	if(tumorId != null)
    	{
    		tumor = [Select Id, Name from CMT_Intermediate_Level_gne__c where Id =:tumorId];
    		associatedLevels = [Select Id, Name from CMT_Intermediate_Level_gne__c where Parent_Id_gne__c =:tumorId];
            frToSess = [Select Id,Session_gne__r.Name from CMT_FranchiseToSession_gne__c where CMT_Intermediate_Level_gne__c =:tumorId AND  Franchise_gne__c =: franchiseId AND Meeting_gne__c =: meetingId];
            if(frToSess.size()>0)
            {
            	for(CMT_FranchiseToSession_gne__c fts: frToSess)
            	{
            		sessions.add(fts.Session_gne__r.Name);
            	}
            }
            else
            {
            	sessions.add('No sessions associated to this sub-group/level.');
            }
    	}
    }
    
    public CMT_Intermediate_Level_gne__c getTumor()
    {
        return this.tumor;
    }
    
    public PageReference save()
    {
        if (tumorId == null)
        {
            tumor.CMT_Franchise_gne__c = franchiseId;
        }
        if(tumorParentId != null)
        {
        	tumor.Parent_Id_gne__c = tumorParentId;
        }
        upsert tumor;
		
		List<CMT_FranchiseToSession_gne__c> fts = [SELECT Id,lastmodifieddate FROM CMT_FranchiseToSession_gne__c where CMT_Intermediate_Level_gne__c=:tumor.Id];
		update fts;
		
		String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);
        String redirectURL = '';
		if(tumorParentId != null)
		{
			redirectURL = partOneURL + 'apex/CMT_Franchise_Tumors_View?mid='+meetingId+ '&fid='+franchiseId + '&id='+tumorParentId;
	        if(meetingId != null || meetingId !='')
	        {
	            PageReference pageRef = new PageReference(redirectURL);
	            pageRef.setRedirect(true);
	            return pageRef;
	        }
		}
	
        redirectURL = partOneURL + 'apex/CMT_Franchise_Sessions?mid='+meetingId+'&fid='+franchiseId;
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
        String redirectURL = '';
        PageReference current = System.currentPageReference();
		String ptumid = current.getParameters().get('ptumid');
		if(ptumid != null)
		{
			redirectURL = partOneURL + 'apex/CMT_Franchise_Tumors_View?mid='+meetingId+ '&fid='+franchiseId + '&id='+ptumid;
	        if(meetingId != null || meetingId !='')
	        {
	            PageReference pageRef = new PageReference(redirectURL);
	            pageRef.setRedirect(true);
	            return pageRef;
	        }
		}
        if(tumorParentId != null)
        {
        	redirectURL = partOneURL + 'apex/CMT_Franchise_Tumors_View?mid='+meetingId+'&fid='+franchiseId +'&id='+tumorParentId;
        }
        else
        {
        	redirectURL = partOneURL + 'apex/CMT_Franchise_Sessions?mid='+meetingId+'&fid='+franchiseId;
        }
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
    
    public PageReference addAccociateLevel()
    {
    	String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);
        String redirectURL = partOneURL + 'apex/CMT_IntermediateLevel?mid='+meetingId+ '&fid='+franchiseId+'&tid='+tumor.id;
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
    
     public PageReference editTumor()
	{
		String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);
        PageReference current = System.currentPageReference();
        String redirectURL = partOneURL + 'apex/CMT_IntermediateLevel?mid='+meetingId+ '&fid='+franchiseId + '&id='+current.getParameters().get('assLid')+'&tid='+tumorId;
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
		String assTumorId = current.getParameters().get('assLid');
		List<CMT_Intermediate_Level_gne__c> tumorToDel = [Select Id from CMT_Intermediate_Level_gne__c where Id =: assTumorId or Parent_Id_gne__c=:assTumorId];
		delete tumorToDel;
		PageReference pr = new PageReference('/apex/CMT_Franchise_Tumors_View?fid='+franchiseId+'&mid='+meetingId+'&id='+tumorId);
		pr.setRedirect(true);
		return pr;
	}
	
	 public PageReference viewTumor()
	 {
		String orgURL = ApexPages.currentPage().getUrl();
		Integer indexApex = orgURL.indexOf('apex');
		String partOneURL = orgURL.substring(0,indexApex);
		PageReference current = System.currentPageReference();
		String tumorId = current.getParameters().get('id');
		String redirectURL = partOneURL + 'apex/CMT_Franchise_Tumors_View?mid='+meetingId+ '&fid='+franchiseId + '&id='+current.getParameters().get('assLid')+'&isParent=false&ptumid='+tumorId;
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