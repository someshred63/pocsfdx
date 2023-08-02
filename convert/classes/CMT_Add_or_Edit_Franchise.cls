public with sharing class CMT_Add_or_Edit_Franchise 
{
	private ApexPages.StandardController controller;
	public CMT_Franchise_gne__c franchise;	
	public String meetingId;
	
	public CMT_Add_or_Edit_Franchise (ApexPages.StandardController controller)
	{
		PageReference pageRef = System.currentPageReference();
        String url = pageRef.getUrl();
        String franchiseId = pageRef.getParameters().get('id');
        meetingId = pageRef.getParameters().get('mid');
        if(franchiseId == null)
        {
        	franchise = new CMT_Franchise_gne__c();
        }
        else
        {
        	franchise = [Select Id, Name, Meeting_gne__c from CMT_Franchise_gne__c where Id =:franchiseId];
        }
	}
	public CMT_Franchise_gne__c getFranchise()
	{
		return this.franchise;
	}
	public void setFranchise(CMT_Franchise_gne__c frc)
	{
		this.franchise = frc;
	}
	public PageReference save()
	{
		franchise.Meeting_gne__c = meetingId;
		upsert franchise;
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
	
}