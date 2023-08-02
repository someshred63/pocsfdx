public with sharing class CMT_ExhibitController
{    
    private ApexPages.StandardController ctrl;
    public CMT_Exhibit_gne__c shuttle { get; set; }
    public String meetingId { get; set; }
    public String objectId { get; set; }
    public List<CMT_Exhibit_gne__c> objects { get; set; }
    
    public CMT_ExhibitController (ApexPages.StandardController ctrl)
    {
        this.ctrl = ctrl;
        shuttle = (CMT_Exhibit_gne__c)ctrl.getRecord();
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
    
    public PageReference add()
    {
        return CMT_MiscUtils.sObjectEditPageRef(CMT_Exhibit_gne__c.sObjectType, 'meetingId=' + meetingId);
    }
    
    public PageReference edit()
    {
        ctrl.edit();
        meetingId = ((CMT_Exhibit_gne__c)ctrl.getRecord()).Meeting_gne__c;
        return null;
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
        
        objects = [SELECT Id, Name, Description_gne__c, Location_gne__c FROM CMT_Exhibit_gne__c WHERE Meeting_gne__c = :meetingId];
        return null;
    }
    
    public PageReference deleteById()
    {
        List<CMT_Exhibit_gne__c> p = [SELECT Id FROM CMT_Exhibit_gne__c WHERE Id = :objectId];
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