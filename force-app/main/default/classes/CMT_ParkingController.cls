public with sharing class CMT_ParkingController
{    
    private ApexPages.StandardController ctrl;
    public CMT_Parking_gne__c shuttle { get; set; }
    public String meetingId { get; set; }
    public String objectId { get; set; }
    public List<CMT_Parking_gne__c> objects { get; set; }
    public Boolean showAddButton { get; private set; }
    
    public CMT_ParkingController (ApexPages.StandardController ctrl)
    {
        this.ctrl = ctrl;
        shuttle = (CMT_Parking_gne__c)ctrl.getRecord();
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
    
    public PageReference cancelAdd()
    {
    	meetingId = System.currentPageReference().getParameters().get('meetingId');
    	
    	if (meetingId == null)
    	{
    		throw new CMT_Exception('Meeting ID parameter not passed');
    	}
    	
    	return CMT_MiscUtils.viewLinkPageRef(meetingId);
    }
    
    public PageReference edit()
    {
    	ctrl.edit();
    	meetingId = ((CMT_Parking_gne__c)ctrl.getRecord()).Meeting_gne__c;
    	return null;
    }
    
    public PageReference add()
    {
    	return CMT_MiscUtils.sObjectEditPageRef(CMT_Parking_gne__c.sObjectType, 'meetingId=' + meetingId);
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
    	
    	objects = [SELECT Id, Name, Description_gne__c FROM CMT_Parking_gne__c WHERE Meeting_gne__c = :meetingId];
    	showAddButton = objects == null || objects.isEmpty();
    	return null;
    }
    
    public PageReference deleteById()
    {
    	CMT_Parking_gne__c p = [SELECT Id FROM CMT_Parking_gne__c WHERE Id = :objectId];
    	delete p;
    	return showList();
    }
    
    public PageReference save()
    {
    	shuttle.Meeting_gne__c = meetingId;
    	return ctrl.save();
    }
}