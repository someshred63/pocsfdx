public with sharing class CMT_AbstractCategoryController
{    
    private ApexPages.StandardController ctrl;
    public CMT_Abstract_Category_gne__c abstractCategory { get; set; }
    public String meetingId { get; set; }
    private List<CMT_Abstract_Category_gne__c> abstractCategories;
    public String objectId { get; set; }
    public List<CMT_Abstract_Category_gne__c> objects { get; set; }
    
    public CMT_AbstractCategoryController (ApexPages.StandardController ctrl)
    {
        this.ctrl = ctrl;
        abstractCategory = (CMT_Abstract_Category_gne__c)ctrl.getRecord();
        abstractCategories = [ select Meeting_gne__c, Id from CMT_Abstract_Category_gne__c where id = :abstractCategory.Id];
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
    
    public PageReference addNewAbstract()
    {
        String redirectURL = '/apex/' + CMT_Config.NEW_ABSTRACT_PAGE + '?mId=' + abstractCategories[0].Meeting_gne__c  + '&cId=' + abstractCategories[0].Id;
        PageReference pageRef = new PageReference(redirectURL);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference save()
    {
        if (abstractCategory.Meeting_gne__c == null)
        {
            abstractCategory.Meeting_gne__c = meetingId;
        }
        upsert abstractCategory;
        
        objectId = abstractCategory.Id;
        return this.view();
    }
    
    public PageReference edit()
    {
        ctrl.edit();
        meetingId = ((CMT_Abstract_Category_gne__c)ctrl.getRecord()).Meeting_gne__c;
        return null;
    }
    
    public PageReference add()
    {
        return CMT_MiscUtils.sObjectEditPageRef(CMT_Abstract_Category_gne__c.sObjectType, 'meetingId=' + meetingId);
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
        
        objects = [SELECT Id, Category_Name_gne__c FROM CMT_Abstract_Category_gne__c WHERE Meeting_gne__c = :meetingId];
        return null;
    }
    
    public PageReference deleteById()
    {
        CMT_Abstract_Category_gne__c p = [SELECT Id FROM CMT_Abstract_Category_gne__c WHERE Id = :objectId];
        delete p;
        return showList();
    }
}