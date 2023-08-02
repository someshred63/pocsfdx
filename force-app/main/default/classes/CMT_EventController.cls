public with sharing class CMT_EventController
{    
    private ApexPages.StandardController ctrl;
    public CMT_Event_gne__c event { get; set; }
    public String meetingId { get; set; }
    public String objectId { get; set; }
    public List<CMT_Event_gne__c> objects { get; set; }
    public String eventDateTime { get; set;}
    
    public CMT_EventController (ApexPages.StandardController ctrl)
    {
        this.ctrl = ctrl;
        event = (CMT_Event_gne__c)ctrl.getRecord();
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
    	if(event.Event_Time_gne__c == null)
        {
        	event.Event_Time_gne__c = '12:00 am';
        	eventDateTime = '12:00 am';
        }
    	meetingId = ((CMT_Event_gne__c)ctrl.getRecord()).Meeting_gne__c;
    	return null;
    }
    
    public PageReference save()
    {
    	if(eventDateTime != '')
    	{
  			event.Event_Time_gne__c = eventDateTime;
    	} 
    	else
    	{
    		event.Event_Time_gne__c = null;
    	}
    	if(event.Event_Time_gne__c==null || event.Event_Date_gne__c == null)
  		{
  			ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR ,'Event Time is required.'));
  			return null;
  		}

  		system.debug('----'+event.Event_Time_gne__c);
    	event.Meeting_gne__c = meetingId; 
  		return ctrl.save();
    }
    
    public PageReference add()
    {
    	return CMT_MiscUtils.sObjectEditPageRef(CMT_Event_gne__c.sObjectType, 'meetingId=' + meetingId);
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
    	
    	objects = [SELECT Id, Name_gne__c, 	Event_Date_gne__c,Event_Time_gne__c FROM CMT_Event_gne__c WHERE Meeting_gne__c = :meetingId];
    	return null;
    }
    
    public PageReference deleteById()
    {
    	CMT_Event_gne__c p = [SELECT Id FROM CMT_Event_gne__c WHERE Id = :objectId];
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