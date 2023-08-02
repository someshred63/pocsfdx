public with sharing class CMT_Yelp_View 
{
	private ApexPages.StandardController controller;
	public String meetingId;
	public String infoId;
	public String yelpId;
	public CMT_Yelp_Address_gne__c yelp {get; set;}
	
	public CMT_Yelp_View(ApexPages.StandardController controller)
	{
		PageReference pageRef = System.currentPageReference();
		meetingId = pageRef.getParameters().get('mid');
		infoId = pageRef.getParameters().get('iid');
		yelpId = pageRef.getParameters().get('yid');
		if(yelpId != '' && yelpId != null)
		{
			getYelp(yelpId);
		}
	}
	private CMT_Yelp_Address_gne__c getYelp(String yelpId)
	{
		yelp = new CMT_Yelp_Address_gne__c();
		yelp = [Select Id, City_gne__c, Latitude_gne__c, Longitude_gne__c,Phone_gne__c, State_gne__c, Country_gne__c, Street_gne__c, Zip_gne__c from CMT_Yelp_Address_gne__c where Id =: yelpId];
		return yelp;
	}
	public PageReference backToInfo()
	{
		String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);
        String redirectURL = partOneURL + 'apex/CMT_Info_View?mid='+meetingId+'&iid='+infoId;
        if(meetingId != null && meetingId !='' && infoId !='' && infoId !='')
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
	public PageReference editYelp()
	{
		String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);
        String redirectURL = partOneURL + 'apex/CMT_Add_or_Edit_Yelp?mid='+meetingId+'&iid='+infoId+'&yid='+yelpId;
        if(meetingId != null && meetingId !='' && infoId !='' && infoId !='' && yelpId !='' && yelpId !='')
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
	public PageReference deleteYelp()
	{
		delete yelp;
		String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);
        String redirectURL = partOneURL + 'apex/CMT_Info_View?mid='+meetingId+'&iid='+infoId;
        if(meetingId != null && meetingId !='' && infoId !='' && infoId !='')
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