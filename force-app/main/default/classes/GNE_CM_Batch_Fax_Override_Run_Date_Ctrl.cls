public with sharing class GNE_CM_Batch_Fax_Override_Run_Date_Ctrl 
{
	ApexPages.StandardSetController setCon;
	boolean searchResult = false;
	boolean errRender = false;
	boolean errOverride = false;
	boolean restoreAutomatedSchedule = false;
	String formSelection = null;
	String errorMessage = 'Warning: You do not have permissions for this function, please contact System Administrator.';
	
	static String DAY_IN_MONTH = '15';
	static Integer MONTHS_IN_YEAR = 12;
	
    public GNE_CM_Batch_Fax_Override_Run_Date_Ctrl(ApexPages.StandardSetController controller) 
	{
    	setCon = controller;
    	Id batchFaxGroupId = [Select g.Id from Group g where g.Name = 'GNE-CM-Batch-Fax-Wizard-Group'].Id;
    	searchResult = checkUserInGroup(batchFaxGroupId, UserInfo.getUserId());
    	if(searchResult == true)
    	{ 
    		errRender = false;
    		errOverride = true;
    	}
    	if(searchResult == false)
    	{ 
    		errRender = true;
    		errOverride = false;
    	}    	
	}
	
	public Boolean getErrorRender()
	{
		return errRender;
	}
	
	public Boolean getOverrideRender()
	{
		return errOverride;
	}
	
    public String getErrorMessage() 
    {
        return errorMessage;
    }

	public void setErrorMessage(String message)
	{
		errorMessage = message;
	}

	public Boolean getCheckAutomatedSchedule()
	{
		return restoreAutomatedSchedule;
	}
	
	public void setCheckAutomatedSchedule(Boolean value)
	{
		restoreAutomatedSchedule = value;
	}
	
	public String getUserName()
	{
		return UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
	}
	
	public String getTodayDate()
	{
		return Date.today().month() + '/' + Date.today().day() + '/' + Date.today().year(); 
	}
	
	public Integer getNoOfCases()
	{
		return setCon.getSelected().size();
	}

    public String getSelectionListValue() 
    {
    	return this.formSelection;
    }

    public void setSelectionListValue(String formSelection) 
    {
    	this.formSelection = formSelection;
    }

    public List<SelectOption> getItems() 
    {
	    List<SelectOption> options = new List<SelectOption>();
        
        List<String> datesList = new List<String>();
        String currDate = null;
        Integer lastDay;
        for(Integer i=Date.today().month(); i <= MONTHS_IN_YEAR; i++)
        {
       		currDate = i + '/' + DAY_IN_MONTH + '/' + System.today().year();
       		datesList.add(currDate);
        	lastDay = Date.daysInMonth(System.today().year(), i);
        	currDate = i + '/' + lastDay + '/' + System.today().year();
        	datesList.add(currDate);
        }
        for(String d :datesList)
        {
        	if(date.parse(d) > date.today())
        		options.add(new SelectOption(d,d));
        }
        return options;
    }

	private boolean checkUserInGroup(Id groupId, Id userId)
	{
		boolean result = false;
		String userType = Schema.SObjectType.User.getKeyPrefix();
        String groupType = Schema.SObjectType.Group.getKeyPrefix();
		for (GroupMember m : [Select Id, UserOrGroupId From GroupMember Where GroupId = :groupId])
        {
            // If the user or group id is a user
            if (((String)m.UserOrGroupId).startsWith(userType))
            {
            	if(m.UserOrGroupId == userId)
            	{ 
            		return true;
            	}
            }
            // If the user or group id is a group
            // Note: there may be a problem with governor limits if this is called too many times
            else if (((String)m.UserOrGroupId).startsWith(groupType))
            {
                // Call this function again but pass in the group found within this group
                result = checkUserInGroup(m.UserOrGroupId, userId);
                if(result == true) 
                	return true;
            }
        }
        return result;
	}
	
	public PageReference Save()
	{
		List<Case> selectedCases = setCon.getSelected();
		Set<Id> casesWithBI = new Set<Id>();		
		if(selectedCases.size() == 0)
		{
			errorMessage = 'Warning: No cases were selected.';
    		errRender = true;
    		errOverride = false;
			return new PageReference('/apex/GNE_CM_Batch_Fax_Override_Run_Date');
		}

		Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('C&R - Standard Case').getRecordTypeId();		
		List<Id> caseIds = new List<Id>();
		for(Case c :selectedCases)
		{
			caseIds.add(c.Id);
		}
		
		Set<String> validStatuses = getValidStatuses();
		
		List<Case> casesToProcess = [select Id, Batch_Fax_AA_Maint_Sent_Date_gne__c, 
									 Batch_Fax_AA_Updated_By_gne__c, Batch_Fax_AA_Maint_Updated_Date_gne__c,
									 Batch_Fax_AA_Target_Date_gne__c,
									 Product_gne__c, RecordTypeId, Proactive_BI_Opt_In_gne__c,
									 Batch_Fax_AA_Maint_Sent_Overriden_gne__c 
									 from Case 
									 where Id in :caseIds
									 and Status in :validStatuses];
										 
		for (Benefit_Investigation_gne__c bi : [SELECT Case_BI_gne__c FROM Benefit_Investigation_gne__c
												WHERE Case_BI_gne__c IN: caseIds])
		{
			if(!casesWithBI.contains(bi.Case_BI_gne__c))
			{
				casesWithBI.add(bi.Case_BI_gne__c);
			}
		}
									 
		for(Case c :casesToProcess)
		{
			if(c.Batch_Fax_AA_Target_Date_gne__c == null)
				{
					errorMessage = 'Warning: In one or many cases Target Date equals null. Case(s) cannot be processed';
		    		errRender = true;
		    		errOverride = false;
					return new PageReference('/apex/GNE_CM_Batch_Fax_Override_Run_Date');
				}
			if(c.Batch_Fax_AA_Maint_Sent_Date_gne__c < Date.today() || c.Batch_Fax_AA_Maint_Sent_Date_gne__c == null)
				{
					errorMessage = 'Warning: One or many cases cannot be rescheduled. Please make sure to select cases with date greater than today for Batch Fax AA Maint Sent Date.';
		    		errRender = true;
		    		errOverride = false;
					return new PageReference('/apex/GNE_CM_Batch_Fax_Override_Run_Date');
				}			
			if(c.Product_gne__c != 'Rituxan RA' ||
			   c.RecordTypeId != recordTypeId ||
			   !casesWithBI.contains(c.Id))
				{
					errorMessage = 'Warning: One or many cases are not eligible to process with override run date functionality.';
		    		errRender = true;
		    		errOverride = false;
					return new PageReference('/apex/GNE_CM_Batch_Fax_Override_Run_Date');
				}
		}

		if(restoreAutomatedSchedule == true)
		{
			for(Case c :casesToProcess)
			{
				c.Batch_Fax_AA_Maint_Sent_Date_gne__c = null;
				c.Batch_Fax_AA_Updated_By_gne__c = null;
				c.Batch_Fax_AA_Maint_Updated_Date_gne__c = null;
				c.Batch_Fax_AA_Maint_Sent_Overriden_gne__c = false;	
			}
		}
		else
		{
			for(Case c :casesToProcess)
			{
				c.Batch_Fax_AA_Maint_Sent_Date_gne__c = date.parse(formSelection);
				c.Batch_Fax_AA_Updated_By_gne__c = UserInfo.getUserId();
				c.Batch_Fax_AA_Maint_Updated_Date_gne__c = Datetime.now();
				c.Batch_Fax_AA_Maint_Sent_Overriden_gne__c = true;
			}
		}
		update casesToProcess;
		return setCon.save();
	} 
	
    private static Set<String> getValidStatuses()
    {
        Set<String> validStatuses = new Set<String>();
        List<Environment_Variables__c> environmentVariables = GNE_CM_Environment_variable.get_env_variable(new Set<String>{'case_batch_fax_aa_valid_status'});
        
        for (Integer i = 0; i < environmentVariables.size(); i++)
        {
            validStatuses.add(environmentVariables[i].Value__c.toLowerCase());          
        }
        return validStatuses;
    }	
	
}