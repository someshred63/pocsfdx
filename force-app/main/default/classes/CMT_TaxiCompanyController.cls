public with sharing class CMT_TaxiCompanyController
{    
    private ApexPages.StandardController ctrl;
    public CMT_Taxi_Company_gne__c shuttle { get; set; }
    public String meetingId { get; set; }
    public String objectId { get; set; }
    public List<CMT_Taxi_Company_gne__c> objects { get; set; }
    
    public CMT_TaxiCompanyController (ApexPages.StandardController ctrl)
    {
        this.ctrl = ctrl;
        shuttle = (CMT_Taxi_Company_gne__c)ctrl.getRecord();
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
    	meetingId = ((CMT_Taxi_Company_gne__c)ctrl.getRecord()).Meeting_gne__c;
    	return null;
    }
    
    public PageReference save()
    {
    	shuttle.Meeting_gne__c = meetingId;
    	return ctrl.save();
    }
    
    public PageReference add()
    {
    	return CMT_MiscUtils.sObjectEditPageRef(CMT_Taxi_Company_gne__c.sObjectType, 'meetingId=' + meetingId);
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
    	
    	objects = [SELECT Id, Company_Name_gne__c FROM CMT_Taxi_Company_gne__c WHERE Meeting_gne__c = :meetingId];
    	return null;
    }
    
    public PageReference deleteById()
    {
    	CMT_Taxi_Company_gne__c p = [SELECT Id FROM CMT_Taxi_Company_gne__c WHERE Id = :objectId];
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