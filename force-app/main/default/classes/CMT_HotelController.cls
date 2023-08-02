public with sharing class CMT_HotelController
{    
    private ApexPages.StandardController ctrl;
    public CMT_Hotel_gne__c hotel { get; set; }
    public String meetingId { get; set; }
    public String objectId { get; set; }
    public List<CMT_Hotel_gne__c> objects { get; set; }
    public CMT_Hotel_Address_gne__c address
    { 
    	get
    	{
    		if (address == null)
    		{
    			address = new CMT_Hotel_Address_gne__c();
    		}
    		return address;
    	} 
    	
    	set; 
    }
    
    public CMT_HotelController (ApexPages.StandardController ctrl)
    {
        this.ctrl = ctrl;
        hotel = (CMT_Hotel_gne__c)ctrl.getRecord();
        
    }
    
    public PageReference init()
    {
    	meetingId = System.currentPageReference().getParameters().get('meetingId');
    	
    	if (meetingId == null)
    	{
    		throw new CMT_Exception('Meeting ID parameter not passed');
    	}
    	
    	return null;
    }
    
    public PageReference save()
    {
    	try
    	{
        	hotel.Meeting_gne__c = meetingId;
    	}
    	catch (Exception e)
    	{
    		// do nothing
    	}
    	
    	upsert hotel;
    	
    	address.Meeting_gne__c = hotel.Meeting_gne__c;
    	try
    	{
    		address.Hotel_gne__c = hotel.Id;
    		address.Name = hotel.Name_gne__c + '-Address';
    	}
    	catch (Exception e)
    	{
    		// do nothing
    	}
    	upsert address;
    	
    	hotel.Address_gne__c = address.Id;
    	update hotel;
    	
    	objectId = hotel.Id;
        return this.view();
    }
    
    public PageReference edit()
    {
    	ctrl.edit();
    	meetingId = ((CMT_Hotel_gne__c)ctrl.getRecord()).Meeting_gne__c;
    	List<CMT_Hotel_Address_gne__c> addresses = [SELECT Id, City_gne__c, Street_gne__c, Zip_gne__c, Phone_gne__c, State_gne__c, Yelp_gne__c 
    				FROM CMT_Hotel_Address_gne__c WHERE Id = : ((CMT_Hotel_gne__c)ctrl.getRecord()).Address_gne__c LIMIT 1];
    	
    	if (addresses != null && !addresses.isEmpty())
    	{
    		address = addresses.get(0);
    	}
    	else
    	{
    		address = new CMT_Hotel_Address_gne__c();
    	}
    	
    	return null;
    }
    
    public PageReference add()
    {
    	return CMT_MiscUtils.sObjectEditPageRef(CMT_Hotel_gne__c.sObjectType, 'meetingId=' + meetingId);
    }
    
    public PageReference view()
    {
    	ctrl.view();
    	return CMT_MiscUtils.viewLinkPageRef(objectId);
    }
    
    public PageReference showList()
    {
    	if (meetingId == null)
    	{
    		meetingId = System.currentPageReference().getParameters().get('meetingId');
    	}
    	
    	if (meetingId == null)
    	{
    		throw new CMT_Exception('Meeting ID parameter not passed');
    	}
    	
    	objects = [SELECT Id, Name_gne__c, Description_gne__c FROM CMT_Hotel_gne__c WHERE Meeting_gne__c = :meetingId];
    	return null;
    }
    
    public PageReference deleteById()
    {
    	CMT_Hotel_gne__c p = [SELECT Id FROM CMT_Hotel_gne__c WHERE Id = :objectId];
    	delete p;
    	return showList();
    }
    public PageReference cancel()
    {
    	if (meetingId == null)
    	{
    		meetingId = System.currentPageReference().getParameters().get('meetingId');
    	}
    	
    	if (meetingId == null)
    	{
    		throw new CMT_Exception('Meeting ID parameter not passed');
    	}
    	String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);
        String redirectURL = partOneURL + 'apex/CMT_Hotel_View?id='+hotel.Id;
        PageReference pageRef = new PageReference(redirectURL);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference cancelAdd()
    {
    	meetingId = System.currentPageReference().getParameters().get('meetingId');
    	
    	if (meetingId == null)
    	{
    		throw new CMT_Exception('Meeting ID parameter not passed');
    	}
    	
    	return CMT_MiscUtils.viewLinkPageRef(meetingId);
    }
}