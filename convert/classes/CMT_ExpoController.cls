public with sharing class CMT_ExpoController
{    
    private ApexPages.StandardController ctrl;
    public CMT_Expo_gne__c shuttle { get; set; }
    public String meetingId { get; set; }
    public String objectId { get; set; }
    public String expoGroupId { get; private set; }
    public List<CMT_Expo_gne__c> objects { get; set; }
    
    public CMT_ExpoController (ApexPages.StandardController ctrl)
    {
        this.ctrl = ctrl;
        shuttle = (CMT_Expo_gne__c)ctrl.getRecord();
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
    	shuttle.Meeting_gne__c = meetingId;
    	//shuttle.Transportation_gne__c = transportationId;
    	return ctrl.save();
    }
    
    public PageReference edit()
    {
    	ctrl.edit();
    	meetingId = ((CMT_Expo_gne__c)ctrl.getRecord()).Meeting_gne__c;
    	return null;
    }
    
    public PageReference add()
    {
    	return CMT_MiscUtils.sObjectEditPageRef(CMT_Expo_gne__c.sObjectType, 'meetingId=' + meetingId);
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
    	
    	List<CMT_Expo_Group_gne__c> expoGroups = [SELECT Id FROM CMT_Expo_Group_gne__c WHERE Meeting_gne__c = :meetingId LIMIT 1];
    	
    	if (expoGroups == null || expoGroups.isEmpty())
    	{
    		// The expo list displays a component for adding attachments to the Expo Group object,
	    	// so even if there are no expos on the list, the group object needs to exist. It is however created only when an expo is
	    	// added, therefore we need to add it manually on entering the screen.
	    	CMT_Expo_Group_gne__c expoGroup = new CMT_Expo_Group_gne__c();
	    	expoGroup.Name = CMT_Config.EXPO_GROUP_NAME;
	    	expoGroup.Meeting_gne__c = meetingId;
	    	
	    	insert expoGroup;
	    	expoGroupId = expoGroup.Id;
    	}
    	else
    	{
    		expoGroupId = expoGroups.get(0).Id;
    	}
    	
    	objects = [SELECT Id, Name, Location_gne__c, Description_gne__c FROM CMT_Expo_gne__c WHERE Meeting_gne__c = :meetingId];
    	return null;
    }
    
    public PageReference deleteById()
    {
    	CMT_Expo_gne__c p = [SELECT Id FROM CMT_Expo_gne__c WHERE Id = :objectId];
    	delete p;
    	return showList();
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