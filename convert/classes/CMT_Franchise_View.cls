public with sharing class CMT_Franchise_View 
{
    private ApexPages.StandardController controller;
    public String meetingId;
    public String franchiseId;
    public CMT_Franchise_gne__c franchise {get; set;}
    
    public CMT_Franchise_View (ApexPages.StandardController controller)
    {
        PageReference pageRef = System.currentPageReference();
        franchiseId = pageRef.getParameters().get('id');
        meetingId = pageRef.getParameters().get('mid');
        getFranchise(franchiseId);
    }
    private CMT_Franchise_gne__c getFranchise(String franchiseId)
    {
        franchise = new CMT_Franchise_gne__c();
        List<CMT_Franchise_gne__c> franchises = [Select Id, Name from CMT_Franchise_gne__c where Id =: franchiseId];

        if (franchises != null && !franchises.isEmpty())
        {
            franchise = franchises.get(0);
        }

        return franchise;
    }
    public PageReference editFranchise()
    {
        String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);
        String redirectURL = partOneURL + 'apex/CMT_Franchise?id='+franchiseId+'&mid='+meetingId;
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
    public PageReference deleteFranchise()
    {
        delete franchise;
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
    public PageReference backToMeeting()
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