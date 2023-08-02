public with sharing class CMT_InformationController
{    
    private ApexPages.StandardController ctrl;
    public CMT_Information_gne__c info { get; set; }
    public String meetingId { get; set; }
    public String objectId { get; set; }
    public List<CMT_Information_gne__c> objects { get; set; }
    public Boolean addInfo {get; set;}
    
    public CMT_InformationController (ApexPages.StandardController ctrl)
    {
        this.ctrl = ctrl;
        info = (CMT_Information_gne__c)ctrl.getRecord();    
    }
    
    public PageReference view()
    {
    	ctrl.view();
    	return CMT_MiscUtils.viewLinkPageRef(objectId);
    }
    
     public PageReference add()
    {
    	return CMT_MiscUtils.sObjectEditPageRef(CMT_Information_gne__c.sObjectType, 'meetingId=' + meetingId);
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
    	
    	objects = [SELECT Id, Name_gne__c, Description_gne__c FROM CMT_Information_gne__c WHERE Meeting_gne__c = :meetingId];
    	if(objects.size() == 0)
    	{
    		addInfo = true;
    	}
    	else
    	{
    		addInfo = false;
    	}
    	return null;
    }
    
    public PageReference deleteById()
    {
    	CMT_Information_gne__c p = [SELECT Id FROM CMT_Information_gne__c WHERE Id = :objectId];
    	delete p;
    	return showList();
    }
}