public with sharing class CMT_Info_View 
{
	private ApexPages.StandardController controller;
	public String meetingId;
	public String infoId;
	public CMT_Information_gne__c info {get; set;}
	public List<CMT_Information_Address_gne__c> infoAddresses {get; set;}
	public List<CMT_Yelp_Address_gne__c> yelpList {get; set;}
	public Boolean yelpButton {get; set;}
	
	public CMT_Info_View(ApexPages.StandardController controller)
	{
		PageReference pageRef = System.currentPageReference();
		infoId = pageRef.getParameters().get('id');
		getYelpList(infoId);
		getInfoAddresses(infoId);
		if(yelpList.size()==0)
		{
			yelpButton = true;
		}
		else
		{
			yelpButton = false;
		}
		info = getInfo();
		getInfoAddresses(infoId);
		meetingId = info.Meeting_gne__c;
	}
	private CMT_Information_gne__c getInfo()
	{
		info = new CMT_Information_gne__c();
		if(infoId != null && infoId != '')
		{
			info = [Select Id, Description_gne__c, Meeting_gne__c from CMT_Information_gne__c where Id =:infoId];
		}
		return info;
	}
	private List<CMT_Information_Address_gne__c> getInfoAddresses(String infoId)
	{
		infoAddresses = new List<CMT_Information_Address_gne__c>();
		infoAddresses = [Select Id, City_gne__c,Name_gne__c, Street_gne__c, Phone_gne__c, State_gne__c, Zip_gne__c from CMT_Information_Address_gne__c where Information_gne__c =:infoId];
		return infoAddresses;
	}
	private List<CMT_Yelp_Address_gne__c> getYelpList(String infoId)
	{
		yelpList = new List<CMT_Yelp_Address_gne__c>();
		yelpList = [Select Id, City_gne__c, Latitude_gne__c, Longitude_gne__c,Phone_gne__c, State_gne__c, Street_gne__c, Zip_gne__c from CMT_Yelp_Address_gne__c where 	Information_gne__c =:infoId];
		return yelpList;
	}
	public PageReference editInformation()
	{
		String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);
        String redirectURL = partOneURL + 'apex/CMT_Add_or_Edit_Info?meetingId='+meetingId+'&id='+infoId;
        if(meetingId != null && meetingId !='' && infoId != null && infoId != '')
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
	public PageReference deleteInformation()
	{
		delete info;
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
	public PageReference addAddress()
	{
		String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);
        String redirectURL = partOneURL + 'apex/CMT_Add_or_Edit_Info_Address?mid='+meetingId+'&iid='+infoId;
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
	public PageReference addYelp()
	{
		String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);
        String redirectURL = partOneURL + 'apex/CMT_Add_or_Edit_Yelp?mid='+meetingId+'&iid='+infoId;
        if(meetingId != null && meetingId !='' && infoId != null && infoId !='')
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
	public PageReference editAddress()
	{
		PageReference current = System.currentPageReference();
		String addressId = current.getParameters().get('adrId');
		String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);
        String redirectURL = partOneURL + 'apex/CMT_Add_or_Edit_Info_Address?mid='+meetingId+'&iid='+infoId+'&aid='+addressId;
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
	public PageReference editYelp()
	{
		PageReference current = System.currentPageReference();
		String yelpId = current.getParameters().get('yId');
		String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);
        String redirectURL = partOneURL + 'apex/CMT_Add_or_Edit_Yelp?mid='+meetingId+'&iid='+infoId+'&yid='+yelpId;
        if(meetingId != null && meetingId !='' && infoId != null && infoId !='')
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
	public PageReference viewAddress()
	{
		PageReference current = System.currentPageReference();
		String addressId = current.getParameters().get('adrId');
		String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);
        String redirectURL = partOneURL + 'apex/CMT_Info_Address_View?mid='+meetingId+'&iid='+infoId+'&aid='+addressId;
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
	public PageReference viewYelp()
	{
		PageReference current = System.currentPageReference();
		String yelpId = current.getParameters().get('yId');
		String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);
        String redirectURL = partOneURL + 'apex/CMT_Yelp_View?mid='+meetingId+'&iid='+infoId+'&yid='+yelpId;
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
	public PageReference deleteAddress()
	{
		PageReference current = System.currentPageReference();
		String addressId = current.getParameters().get('adrId');
		CMT_Information_Address_gne__c addressToDel = new CMT_Information_Address_gne__c();
		addressToDel = [Select Id from CMT_Information_Address_gne__c where Id =: addressId];
		delete addressToDel;
		current.setRedirect(true);
		return current;
	}
	public PageReference deleteYelp()
	{
		PageReference current =  System.currentPageReference();
		String yelpId = current.getParameters().get('yId');
		CMT_Yelp_Address_gne__c yelpToDel = new CMT_Yelp_Address_gne__c();
		yelpToDel = [Select Id from CMT_Yelp_Address_gne__c where Id =: yelpId];
		delete yelpToDel;
		yelpList = new List<CMT_Yelp_Address_gne__c>();
		current.setRedirect(true);
		return current;
	}
	
}