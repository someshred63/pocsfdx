public with sharing class CMT_Info_Address_View 
{
	private ApexPages.StandardController controller;
	public String meetingId;
	public String infoId;
	public String addressId;
	public CMT_Information_Address_gne__c address {get; set;}
	
	public CMT_Info_Address_View(ApexPages.StandardController controller)
	{
		PageReference pageRef = System.currentPageReference();
		meetingId = pageRef.getParameters().get('mid');
		infoId = pageRef.getParameters().get('iid');
		addressId = pageRef.getParameters().get('aid');
		getAddress(addressId);
	}
	private CMT_Information_Address_gne__c getAddress(String addressId)
	{
		address = new CMT_Information_Address_gne__c();
		address = [Select Id, City_gne__c,Name_gne__c, Street_gne__c, Phone_gne__c, State_gne__c, Zip_gne__c from CMT_Information_Address_gne__c where Id =:addressId];
		return address;
	}
	public PageReference backToInformation()
	{
		String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);
        String redirectURL = partOneURL + 'apex/CMT_Info_View?mid='+meetingId+'&id='+infoId;
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
	public PageReference deleteAddress()
	{
		delete address;
		String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);
        String redirectURL = partOneURL + 'apex/CMT_Info_View?mid='+meetingId+'&iid='+infoId;
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
		String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);
        String redirectURL = partOneURL + 'apex/CMT_Add_or_Edit_Info_Address?mid='+meetingId+'&iid='+infoId+'&aid='+addressId;
        if(meetingId != null && meetingId !='' && infoId != null && infoId !='' && addressId != null && addressId !='')
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