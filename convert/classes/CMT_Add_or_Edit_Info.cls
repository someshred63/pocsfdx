public with sharing class CMT_Add_or_Edit_Info 
{
	private ApexPages.StandardController controller;
	public String meetingId;
	public String infoId;
	public CMT_Information_gne__c info {get; set;}
	
	public CMT_Add_or_Edit_Info(ApexPages.StandardController controller)
	{
		PageReference pageRef = System.currentPageReference();
		meetingId = pageRef.getParameters().get('meetingId');
		infoId = pageRef.getParameters().get('id');
		if(infoId == null || infoId == '')
		{
			info = new CMT_Information_gne__c();
		}
		else
		{
			info = [Select Id, Description_gne__c, Name_gne__c, Meeting_gne__c from CMT_Information_gne__c where Id =: infoId];
		}
	}
	public CMT_Information_gne__c getInfo()
	{
		return this.info;
	}
	public void setInfo(CMT_Information_gne__c inf)
	{
		this.info = inf;
	}
	public PageReference saveInfo()
	{
		String description = info.Description_gne__c;
		if(description != '' && description != null)
		{
			Integer DescLenght = description.length();
			info.Name_gne__c = description.substring(0,Math.min(25, DescLenght))+'...';
		}
		else
		{
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Description is required'));
            return null;
		}
		if(infoId == null || infoId == '')
		{
			info.Meeting_gne__c = meetingId;
			insert info;
		}
		else
		{
			meetingId = info.Meeting_gne__c;
			upsert info;
		}
		String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);
        String redirectURL = partOneURL + 'apex/CMT_Info_View?id='+info.id;
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
		if(infoId == null || infoId == '')
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
		else
		{
			String orgURL = ApexPages.currentPage().getUrl();
	        Integer indexApex = orgURL.indexOf('apex');
	        String partOneURL = orgURL.substring(0,indexApex);
	        String redirectURL = partOneURL + 'apex/CMT_Info_View?id='+infoId;
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
}