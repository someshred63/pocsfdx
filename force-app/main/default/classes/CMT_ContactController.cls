public with sharing class CMT_ContactController
{
	public String meetingId { get; set; }
	public String categoryId { get; set; }
	public CMT_Contact_gne__c newAbstract { get; set; }
	
	private Apexpages.Standardcontroller ctrl;
	
	public CMT_ContactController (ApexPages.StandardController ctrl)
    {
        this.ctrl = ctrl;
        newAbstract = (CMT_Contact_gne__c) ctrl.getRecord();	
    }
    
    public PageReference cancel()
    {
    	if (categoryId == null)
    	{
    		throw new CMT_Exception('Category ID not passed from page');
    	}
    	return CMT_MiscUtils.viewLinkPageRef(categoryId);
    }
	
	public PageReference init()
	{
		meetingId = System.currentPageReference().getParameters().get('mId');
      	categoryId = System.currentPageReference().getParameters().get('cId');
      
		if (meetingId == null)
		{
			throw new CMT_Exception('Meeting ID parameter not passed');
		}
      
		return null;
	}
	
	public PageReference save()
	{
		newAbstract.Meeting_gne__c = meetingId;
		newAbstract.Category_gne__c = categoryId;
		return ctrl.save();
	}
}