public with sharing class CMT_MeetGreenController
{    
    private ApexPages.StandardController ctrl;
    public CMT_Meet_Green_gne__c shuttle { get; set; }
    public String meetingId { get; set; }
    public String objectId { get; set; }
    public String meetGreenGroupId { get; private set; }
    public List<CMT_Meet_Green_gne__c> objects { get; set; }
    
    // Tells whether adding more meet green objects is allowed for this meeting
    public Boolean isAddingMeetGreenPossible { get; private set; }
    
    public CMT_MeetGreenController (ApexPages.StandardController ctrl)
    {
        this.ctrl = ctrl;
        shuttle = (CMT_Meet_Green_gne__c)ctrl.getRecord();
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
    
    public PageReference edit()
    {
    	ctrl.edit();
    	meetingId = ((CMT_Meet_Green_gne__c)ctrl.getRecord()).Meeting_gne__c;
    	return null;
    }
    
    public PageReference save()
    {
    	shuttle.Meeting_gne__c = meetingId;
    	//shuttle.Transportation_gne__c = transportationId;
    	return ctrl.save();
    }
    
    public PageReference add()
    {
    	return CMT_MiscUtils.sObjectEditPageRef(CMT_Meet_Green_gne__c.sObjectType, 'meetingId=' + meetingId);
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
    	
    	List<CMT_Meet_Green_Group_gne__c> meetGreenGroups = [SELECT Id FROM CMT_Meet_Green_Group_gne__c WHERE Meeting_gne__c = :meetingId LIMIT 1];
    	
    	if (meetGreenGroups == null || meetGreenGroups.isEmpty())
    	{
    		// The expo list displays a component for adding attachments to the Expo Group object,
	    	// so even if there are no expos on the list, the group object needs to exist. It is however created only when an expo is
	    	// added, therefore we need to add it manually on entering the screen.
	    	CMT_Meet_Green_Group_gne__c meetGreenGroup = new CMT_Meet_Green_Group_gne__c();
	    	meetGreenGroup.Name = CMT_Config.MEET_GREEN_GROUP_NAME;
	    	meetGreenGroup.Meeting_gne__c = meetingId;
	    	
	    	insert meetGreenGroup;
	    	meetGreenGroupId = meetGreenGroup.Id;
    	}
    	else
    	{
    		meetGreenGroupId = meetGreenGroups.get(0).Id;
    	}
    	
    	objects = [SELECT Id, Name_gne__c FROM CMT_Meet_Green_gne__c WHERE Meeting_gne__c = :meetingId];
    	
    	// adding meet greens is only possible when there exist none
    	isAddingMeetGreenPossible = (objects == null || objects.isEmpty());
    	
    	return null;
    }
    
    public PageReference deleteById()
    {
    	CMT_Meet_Green_gne__c p = [SELECT Id FROM CMT_Meet_Green_gne__c WHERE Id = :objectId];
    	delete p;
    	return showList();
    }
}