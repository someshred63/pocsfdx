public with sharing class CMT_ContactCategoryController
{    
    private ApexPages.StandardController ctrl;
    public CMT_Contact_Category_gne__c contactCategory { get; set; }
    public String meetingId { get; set; }
    private List<CMT_Contact_Category_gne__c> contactCategories;
    public String objectId { get; set; }
    public List<CMT_Contact_Category_gne__c> objects { get; set; }
    
    public CMT_ContactCategoryController (ApexPages.StandardController ctrl)
    {
        this.ctrl = ctrl;
        contactCategory = (CMT_Contact_Category_gne__c)ctrl.getRecord();
        contactCategories = [select Meeting_gne__c, Id, Name from CMT_Contact_Category_gne__c where id = :contactCategory.Id];
    }
    
    public PageReference init()
    {
        meetingId = System.currentPageReference().getParameters().get('meetingId');
        return null;
    }
    
    public PageReference save()
    {
    	if (contactCategory.Meeting_gne__c == null)
    	{
        	contactCategory.Meeting_gne__c = meetingId;
    	}
    	upsert contactCategory;
    	
    	objectId = contactCategory.Id;
        return this.view();
    }
    
    public PageReference edit()
    {
    	ctrl.edit();
    	meetingId = ((CMT_Contact_Category_gne__c)ctrl.getRecord()).Meeting_gne__c;
    	return null;
    }
    
    public PageReference addNewContact()
    {
        String redirectURL = '/apex/' + CMT_Config.NEW_CONTACT_PAGE + '?mId=' + contactCategories[0].Meeting_gne__c  + '&cId=' + contactCategories[0].Id;
        PageReference pageRef = new PageReference(redirectURL);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference add()
    {
    	return CMT_MiscUtils.sObjectEditPageRef(CMT_Contact_Category_gne__c.sObjectType, 'meetingId=' + meetingId);
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
    	
    	objects = [SELECT Id, Name FROM CMT_Contact_Category_gne__c WHERE Meeting_gne__c = :meetingId];
    	return null;
    }
    
    public PageReference deleteById()
    {
    	CMT_Contact_Category_gne__c p = [SELECT Id FROM CMT_Contact_Category_gne__c WHERE Id = :objectId];
    	delete p;
    	return showList();
    }
    public PageReference cancel()
    {
    	String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);
        String redirectURL = partOneURL + 'apex/CMT_Event_Summary_Page?id='+meetingId;
        if(meetingId != null || meetingId !='')
        {
            PageReference pageRef = new PageReference(redirectURL);
            pageRef.setRedirect(true);
            return pageRef;
        }
        else
        {
            return null;
        }
    }
}