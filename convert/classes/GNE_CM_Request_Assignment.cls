/**
This is the controller class for GNE_CM_GATCF_Request_New_Assignment_Page. The page is being used to override Home Page for GATCF users so they can request
for new activities from Urgent, Today, and regular queue. User clicks on Request Assignment button and this class will assign minimum required Urgent activities, Today activities,
and reqular past due activities assigned to generic user.
**/
public class GNE_CM_Request_Assignment 
{
	public List<Task> activities {get; private set;}	
	public Integer testHour {get; set;}
	private Map<String, List<Environment_Variables__c>> envVarMultiValues;
	private Id userId;		
	private String user_profile;
	private Datetime process_start_time;
	private string process_status = 'Success';	
	public string errMessage;
	
	
	public GNE_CM_Request_Assignment()
	{
		userId = UserInfo.getUserId();
		user_profile = [select Name from profile where Id = :UserInfo.getProfileId() limit 1].Name;
		populateEnvironmentVariables();		
		try
		{			
			activities = [SELECT id, Subject, What.Name ,who.Name, OwnerId, Owner.Name, CM_Case_Number_gne__c, ActivityDate, Treating_MD_gne__c, Product_gne__c, 
				Treating_Location_State_gne__c, Case_Id_gne__c, IsVisibleInSelfService FROM Task where OwnerId =: UserId 
				and isClosed = false limit 1000];			
		}
		catch(exception e)
		{
			activities = new List<Task>();
		}		
	}

	public PageReference Assign() 
	{
		List<Task> update_task_list = new List<Task>();	
		Id genericUserId;
		Boolean page_flag = false;
		process_start_time = system.now();
		GNE_CM_Monitoring_Auditing_gne__c log;
		
		try
		{ 
			//AS Changes CMGTT-56
			
			GNE_SFA2_Util.setSkipTriggersOnlyInTests(false);
			GNE_SFA2_Util.skipTrigger('GNE_CM_Request_Assignment_Bypass_Trigger');
			
			//End Of Changes
			
			//get the ownerId for Generic Queue Owner
			genericUserId = getGenericUser();
			if(genericUserId == null)
			{				
				return null;
			}      		      	  
			//validations to be performed before displaying assigned activities
			if(!validate())
			{
				return null;
			}
			//actual call to populate user's assignment list
			log = insertMonitorData();
			update_task_list = GNE_CM_Request_Assignment_Helper.getWorkAssignments(envVarMultiValues, UserInfo.getUserId(), genericUserId, Datetime.now().hour());                        
			
			if(update_task_list != null)
			{	     
				if(update_task_list.size()>0)
				{
					//update activities so that they are assigned to logged in user            	  	
					//update update_task_list;
					Database.SaveResult[] RA_results  = Database.update(update_task_list,false); 
		
					system.debug('update_task_list >>>>>>>>>>>>>>>>>>>' + update_task_list);
					for(Database.Saveresult res : RA_results)
			    	{
			      		if(!res.isSuccess())
			      		{
			        		for(Database.Error err : res.getErrors())
			        		{            
			          			errMessage = 'Failed to update Task ' + err.getMessage();
			          			system.debug('ERROR_MESSAGE>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' + errMessage);
			        		}                  
			     		 }   
			    	}
					page_flag = true;       
				}
				else
				{
					//ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'No new activities are available for assignment.');
					ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, System.Label.GNE_CM_Request_New_Assignment_No_New_Activity);
					ApexPages.addMessage(myMsg);
					return null;
				}
			}     
		}
		catch(Exception e)
		{
			//enter data into Monitor table
			process_status = 'Process Failed due to error: '+e.getMessage();       	       	
		}
		updateMonitorData(log, update_task_list);		
		
		if(page_flag)
		{	
			PageReference Req_Page=new PageReference('/apex/GNE_CM_GATCF_Request_New_Assignment_Page');
			Req_Page.setRedirect(true);
			return Req_Page;	
		}
		else
		{
			return null;
		}
	}
	
	//navigate to selected task
	public PageReference selectTask() 
	{
		Id taskid = System.currentPageReference().getParameters().get('taskid');
		return new PageReference('/'+taskid);		
	}
	
	private GNE_CM_Monitoring_Auditing_gne__c insertMonitorData() 
	{	
		GNE_CM_Monitoring_Auditing_gne__c monitor_record = new GNE_CM_Monitoring_Auditing_gne__c();
		if(envVarMultiValues.get(GNE_CM_Request_Assignment_Helper.REQUEST_ASSIGNMENT_MONITORING)[0].Value__c == 'Yes')
		{
			monitor_record.Time_Start_Date_Time_gne__c = process_start_time;
			monitor_record.Name_gne__c = 'Request Assignment Click';
			monitor_record.Status_gne__c = 'In Progress';
			monitor_record.Request_Submitted_By_gne__c = userId;			
			insert monitor_record;
		}
		return monitor_record;		
	}
	
	private void updateMonitorData(GNE_CM_Monitoring_Auditing_gne__c log, List<Task> requestedTasks) 
	{	
		if(envVarMultiValues.get(GNE_CM_Request_Assignment_Helper.REQUEST_ASSIGNMENT_MONITORING)[0].Value__c == 'Yes')
		{
			log.Time_End_Date_Time_gne__c = system.now();
			if(process_status == 'Success')
			{       	    
				log.Status_gne__c = 'Successful';				
				Integer maxActivites = Integer.valueOf(CustomSettingsHelper.taskQueueSelf().getQueueConfig().get(CustomSettingsHelper.CM_TASK_QUEUE_CONFIG).Max_Number_Activities_Asgmt_Group_gne__c);
				if(requestedTasks.size() > maxActivites)
				{
					String errorInfo = 'Request click: ' + log.Id + ' Count: ' + requestedTasks.size() + ' Ids: ';
					for(Task t : requestedTasks)
					{
						if(errorInfo.length() < 3900)
						{
							errorInfo += t.Id + ' : ' + t.CM_Queue_Name_gne__c + '\n';
						}
						else
						{
							errorInfo += '(...)';
							break;
						}						
					}
					Error_Log_gne__c error = new Error_Log_gne__c(Object_Name__c = 'GNE_CM_Request_Assignment', 
                                                      Error_Level_gne__c = 'Low',
                                                      Snippet_Name__c = 'Assign()', 
                                                      Code_Type__c = 'Apex Class', 
                                                      Error_Description__c = errorInfo, 
                                                      User_Name__c = GNE_CM_MPS_Utils.getUserName());					
					insert error;
				}
			}
			else
			{
				log.Error_Description_gne__c = process_status;
				log.Status_gne__c = 'Failed';
			}
			update log;
		}		
	}
	
	private String getGenericUser()
	{
		String result;
		try
		{
			result = GNE_CM_Task_Queue_Mgmt_Helper.getGenericUserId();
		}
		catch(Exception e)
		{
			result = null;
			//ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Processing is stopped because Generic Owner does not exist in the system.');
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.GNE_CM_Request_New_Assignment_Generic_Owner_Error);
			ApexPages.addMessage(myMsg);
		}
		return result; 
	}
	
	private Boolean validate()
	{
		//Check User Profile
		Set<String> validProfiles = GNE_CM_Request_Assignment_Helper.getValidProfiles(envVarMultiValues);
		if(!validProfiles.contains(user_profile.toUpperCase()))
		{
			//ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You do not have permissions to request assignments.');
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.GNE_CM_Request_New_Assignment_No_Permission);			
			ApexPages.addMessage(myMsg);
			return false;
		}
		//Check the logged in timings of user, Off hours: 11pm â€“ 5am
		Integer startOffHour = Integer.valueof(CustomSettingsHelper.taskQueueSelf().getQueueConfig().get(CustomSettingsHelper.CM_TASK_QUEUE_CONFIG).Queue_Down_Start_Time_gne__c);
		Integer endOffHour = Integer.valueof(CustomSettingsHelper.taskQueueSelf().getQueueConfig().get(CustomSettingsHelper.CM_TASK_QUEUE_CONFIG).Queue_Down_End_Time_gne__c);
		Integer currentHour;		
		if(Test.isRunningTest())
		{
			currentHour = testHour;
		}
		else
		{
			currentHour = Datetime.now().hour();
		}
		Boolean off_hour_flag = GNE_CM_Request_Assignment_Helper.validateRequestTime(startOffHour, endOffHour, currentHour);
		
		if(off_hour_flag) 
		{
			//ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'GATCF work assignments can only be assigned between 5am and 11pm PST.');
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.GNE_CM_New_Request_Assignment_Time_Limit);
			ApexPages.addMessage(myMsg);
			return false;
		}

		//wilczekk - modified validation to exclude not useful code.
		//check if activities already assigned to user are greater than min allowed. ignore activities with subjects to be excluded
		/*
		Integer allwd_activity_count = 0;
		Set<String> excludedSubjects = GNE_CM_Request_Assignment_Helper.getExcludedSubjects(envVarMultiValues);
		for(Task t : activities)
		{
			//if(!excludedSubjects.contains(t.Subject))
			{
				allwd_activity_count++;
			}
		}				
		*/
		Integer min_activities = Integer.valueOf(CustomSettingsHelper.taskQueueSelf().getQueueConfig().get(CustomSettingsHelper.CM_TASK_QUEUE_CONFIG).Request_Assignment_Minimum_Activities__c);   
		if(getNumberOfEligibleActivities() >= min_activities)
		{
			//6/20/2011
			//ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'The system will assign more work if you have less than '+Integer.valueOf(min_activities)+' open activities assigned. Please contact a GATCF Supervisor if you need assistance.');
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.GNE_CM_Request_New_Assignment_Act_Number + ' ' + Integer.valueOf(min_activities)+ ' ' +System.Label.GNE_CM_Request_New_Assignment_Act_Number1);
			ApexPages.addMessage(myMsg);
			return false;
		}
		return true;
	}
	
	private Integer getNumberOfEligibleActivities()
	{
		Integer numberOfEliglibeActivities = 0;
		Set<String> notCountedSubjects = GNE_CM_Request_Assignment_Helper.getNotCountSubjects(envVarMultiValues);		
		for(Task t : activities)
		{
			if(!notCountedSubjects.contains(t.Subject.toUpperCase()))
			{
				numberOfEliglibeActivities++;
			}
		}
		return numberOfEliglibeActivities;
	}
	
	private void populateEnvironmentVariables()
	{
		//populate environment variables for the batch job
		Set<String> envVarNameSet = new Set<String>{GNE_CM_Request_Assignment_Helper.REQUEST_ASSIGNMENT_VALID_PROFILE,
													GNE_CM_Task_Queue_Mgmt_Helper.QUEUE_TASK_SUBJECT_EXCLUDE,
													GNE_CM_Task_Queue_Mgmt_Helper.QUEUE_BUILD_STATUS,
													GNE_CM_Request_Assignment_Helper.REQUEST_ASSIGNMENT_MONITORING,
													GNE_CM_Request_Assignment_Helper.REQUEST_ASSIGNMENT_NOT_COUNT};
		envVarMultiValues = GNE_CM_Task_Queue_Mgmt_Helper.populateEnvVariables(envVarNameSet);
	}
	
}