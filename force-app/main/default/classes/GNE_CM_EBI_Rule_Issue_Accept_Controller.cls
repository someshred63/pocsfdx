public without sharing class GNE_CM_EBI_Rule_Issue_Accept_Controller {
   	ApexPages.StandardSetController setCon;
	
	public Boolean isValidUser { get; set; }
	public List<GNE_CM_EBI_Rule_Issue__c> updateLst { get; set; }
	public List<GNE_CM_EBI_Rule_Issue_Wrapper> displayLst { get; set; }
	
	class GNE_CM_EBI_Rule_Issue_Wrapper 
	{
		public GNE_CM_EBI_Rule_Issue__c issue { get; set; }
		public String message { get; set; }
		
		public GNE_CM_EBI_Rule_Issue_Wrapper(GNE_CM_EBI_Rule_Issue__c i, String m)
		{
			issue=i;
			message=m;
		}
	}
	
    public GNE_CM_EBI_Rule_Issue_Accept_Controller(ApexPages.StandardSetController controller) 
    {
        setCon = controller;
    }
    
    public PageReference returnToList()
    {
    	return null;
    }
    
    public PageReference acceptIssues()
    {
        update updateLst;

        String ListViewId='00BS0000001ms19';
        String ListViewName=GNE_CM_CustomSettingsHelper.self().getCMConfig().EBI_Accept_Issue_List_View__c;
        
        String q = 'SELECT Name FROM GNE_CM_EBI_Rule_Issue__c LIMIT 1';
        ApexPages.StandardSetController ACC = new ApexPages.StandardSetController(Database.getQueryLocator(q));
        List<SelectOption> ListViews = ACC.getListViewOptions();
        for(SelectOption w : ListViews ){
            if(w.getLabel()==ListViewName){
                ListViewId = w.getValue().left(15);
            }
        }
		return new PageReference('/' + Schema.SObjectType.GNE_CM_EBI_Rule_Issue__c.getKeyPrefix() + '?fcf=' + ListViewId);
    }
    
    public PageReference init()
    {
		// first check that user is a RuleMon or TE
		// if not then display an 'Insufficient Privileges'
		Boolean isTE=(1==[SELECT COUNT() FROM GroupMember WHERE Group.DeveloperName='GNE_CM_EBI_Vendors' AND UserOrGroupId=:Userinfo.getUserId()]);
		Boolean isGNE=(1==[SELECT COUNT() FROM GroupMember WHERE Group.DeveloperName='GNE_CM_EBI_Rule_Monitor' AND UserOrGroupId=:Userinfo.getUserId()]);

		isValidUser=(isTE || isGNE);
		
		if (!isValidUser)
		{
			return null;
		}

		// list to hold valid records and messages
		updateLst=new List<GNE_CM_EBI_Rule_Issue__c>();
		displayLst=new List<GNE_CM_EBI_Rule_Issue_Wrapper>();
		
		List<GNE_CM_EBI_Rule_Issue__c> issueLst = [SELECT Id, Name, OwnerId, Drug_gne__c, Payer_gne__c, Section_of_eBI_271_Response_gne__c, Status_gne__c FROM GNE_CM_EBI_Rule_Issue__c WHERE Id=:setCon.getSelected()];

		String vendorQueueId=[SELECT DeveloperName,Id,Name,Type FROM Group WHERE DeveloperName='GNE_CM_EBI_Vendors'].Id;
		String ruleMonQueueId=[SELECT DeveloperName,Id,Name,Type FROM Group WHERE DeveloperName='GNE_CM_EBI_Rule_Monitor'].Id;
				
        for(GNE_CM_EBI_Rule_Issue__c iss : issueLst)
        {
        	GNE_CM_EBI_Rule_Issue_Wrapper riw=new GNE_CM_EBI_Rule_Issue_Wrapper(iss, 'OK');
        	displayLst.add(riw);

			if (iss.OwnerId!=vendorQueueId && iss.OwnerId!=ruleMonQueueId)
			{
				riw.message='ERROR: Not owned by valid queue.';
			}
			
			if (iss.OwnerId==vendorQueueId)
			{
				if (!isTE)
				{
					riw.message='ERROR: Not owned by valid queue.';
				}
				else if (iss.Status_gne__c!='Assigned to Vendor')
				{
					riw.message='ERROR: Status must be Assigned to Vendor.';
				}
			}
			
			if (iss.OwnerId==ruleMonQueueId)
			{
				if (!isGNE)
				{
					riw.message='ERROR: Not owned by valid queue.';
				}
				else if (iss.Status_gne__c!='New')
				{
					riw.message='ERROR: Status must be New.';
				}
			}
			
			
			if (riw.message=='OK')
			{
				GNE_CM_EBI_Rule_Issue__c issu=new GNE_CM_EBI_Rule_Issue__c(Id=iss.Id, OwnerId=UserInfo.getUserId());
				
	        	if (isTE)
	        	{
					issu.Status_gne__c='Received by Vendor';
	        	}
	        	else
	        	{
					issu.Status_gne__c='Under GNE Review';        		
	        	}
	        	updateLst.add(issu);
			}
        }
        
        if (updateLst.size()==issueLst.size())
        {
        	// we're good and don't need anything from the user
        	return acceptIssues();
        }
        
		// we've got issues that need user attention
        return null;
    }	
}