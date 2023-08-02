public with sharing class CMT_ShuttleController
{    
    private ApexPages.StandardController ctrl;
    public CMT_Shuttle_gne__c shuttle { get; set; }
    public String meetingId { get; set; }
    public String objectId { get; set; }
    public List<CMT_Shuttle_gne__c> objects { get; set; }
    public List<SelectOption> shuttleTypes { get; private set; }
    public boolean isAddingShuttlePossible { get; private set; }
    
    public CMT_ShuttleController (ApexPages.StandardController ctrl)
    {
    	isAddingShuttlePossible = true;
        this.ctrl = ctrl;
        shuttle = (CMT_Shuttle_gne__c)ctrl.getRecord();
    }
    
    public PageReference init()
    {
    	meetingId = System.currentPageReference().getParameters().get('meetingId');
    	
    	if (meetingId == null)
    	{
    		throw new CMT_Exception('Meeting ID parameter not passed');
    	}
    	
    	initShuttleTypes(meetingId, null);
    	
    	return null;
    }
    
    // Initializes shuttles type with possible values
    private void initShuttleTypes(Id meetingId, Id shuttleId)
    {
    	List<CMT_Shuttle_gne__c> existingShuttles = [SELECT Id, Type_gne__c FROM CMT_Shuttle_gne__c WHERE Meeting_gne__c = :meetingId];
    	if (existingShuttles == null)
    	{
    		existingShuttles = new List<CMT_Shuttle_gne__c>(); 
    	}
    	
    	List<Schema.PicklistEntry> ple = CMT_Shuttle_gne__c.Type_gne__c.getDescribe().getPicklistValues();
                
        shuttleTypes = new List<SelectOption>();
        
        
	    for (Schema.PicklistEntry entry : ple)
	    {
	    	boolean typeExists = false;
	    	
	    	for (CMT_Shuttle_gne__c existingShuttle : existingShuttles)
	    	{
	    		// if a shuttle of this type already exists, do not add it and continue to the next type
	    		if (existingShuttle.Type_gne__c == entry.getValue() && shuttleId != existingShuttle.Id)
	    		{
	    			typeExists = true;
	    			break;
	    		}
	    	}
	    	
	    	if (!typeExists)
	    	{
	    		// add this type to the possible options only if there are not shuttles of this type in the meeting
	        	shuttleTypes.add(new SelectOption(entry.getLabel(), entry.getValue()));
	    	}
	    }
    }
    
    public PageReference edit()
    {
    	ctrl.edit();
    	meetingId = ((CMT_Shuttle_gne__c)ctrl.getRecord()).Meeting_gne__c;
    	initShuttleTypes(meetingId, ((CMT_Shuttle_gne__c)ctrl.getRecord()).Id);
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
    	return CMT_MiscUtils.sObjectEditPageRef(CMT_Shuttle_gne__c.sObjectType, 'meetingId=' + meetingId);
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
    	
    	objects = [SELECT Id, Name, Description_gne__c, Type_gne__c FROM CMT_Shuttle_gne__c WHERE Meeting_gne__c = :meetingId];
    	isAddingShuttlePossible = objects == null || objects.size() < 2;    	
    	
    	return null;
    }
    
    public PageReference deleteById()
    {
    	CMT_Shuttle_gne__c p = [SELECT Id FROM CMT_Shuttle_gne__c WHERE Id = :objectId];
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