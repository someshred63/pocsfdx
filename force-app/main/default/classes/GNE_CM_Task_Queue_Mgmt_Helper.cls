/************************************************************
*  @author: Krzysztof Wilczek, Roche
*  Date: 2011-04-06
*  Description: 
*  Helper class for Task Queue Building R3 project  
*  Modification History
*  Date        Name        Description
*  2013-07-15  James Hou   PFS-704: Update Queue MGMT to using batch jobs chaining (v26)
*                          Obsoleting:
*                           - getJobToRun() - this is offloaded into chained batch apex
*						   Modified:
*							- getCurrentJobCount() taken from other Scheduler class
*							- verifyStatus() taken from other Scheduler class
*                
*************************************************************/

public without sharing class GNE_CM_Task_Queue_Mgmt_Helper 
{
	public enum ProcessingStatuses { InProgress, Failed, Successful }
	public enum QueueBatchTypes { Unassign, Build, Restamping, Notification }
	public enum QueueNames { Regular, Today, Urgent, Processing, RS_Regular, RS_Today, RS_Urgent }
	public static final String QUEUE_TASK_SUBJECT_EXCLUDE = 'GNE_CM_Queue_Task_Subject_Exclude';
	public static final String QUEUE_TASK_SUBJECT_URGENT = 'GNE_CM_Queue_Task_Subject_Urgent';
	public static final String QUEUE_UNASSIGN_START_TIME = 'GNE_CM_Queue_Unassign_Start_Time';
	public static final String QUEUE_UNASSIGN_END_TIME = 'GNE_CM_Queue_Unassign_End_Time';
	public static final String QUEUE_UNASSIGN_STATUS = 'GNE_CM_Queue_Unassign_Status';	
	public static final String QUEUE_BUILD_START_TIME = 'GNE_CM_Queue_Build_Start_Time';
	public static final String QUEUE_BUILD_END_TIME = 'GNE_CM_Queue_Build_End_Time';
	public static final String QUEUE_BUILD_STATUS = 'GNE_CM_Queue_Build_Status';
	public static final String QUEUE_RESTAMPING_START_TIME = 'GNE_CM_Queue_Restamping_Start_Time';
	public static final String QUEUE_RESTAMPING_END_TIME = 'GNE_CM_Queue_Restamping_End_Time';
	public static final String QUEUE_RESTAMPING_STATUS = 'GNE_CM_Queue_Restamping_Status';	
	public static final String GATCF_RECORD_TYPE = 'GATCF - Standard Case';
	public static final String GES_RECORD_TYPE = 'GATCF - Eligibility Screening';
	public static final String PAE_REQUEST_ASSIGNMENT_NOT_COUNT = 'CM_PAE_TASK_SUBJECT_NOT_COUNTED';
	
	
	public static GNE_CM_Task_Queue_Config__c currentConfig=CustomSettingsHelper.taskQueueSelf().getQueueConfig().get(CustomSettingsHelper.CM_TASK_QUEUE_CONFIG);

	// return the STAT BI type with Hyphen not dash
	public static String getStatBIActvityType()
	{		
		return getStatBIActvityTypePrefix() + ' Perform BI';
	}

	public static String getStatBIReviewActvityType()
	{		
		return 'STAT BI - New Enrollment Review';
	}

	public static String getStatBIActvityTypePrefix()
	{
        Schema.DescribeFieldResult fld=Task.Activity_Type_gne__c.getDescribe();
		String retVal=null;
		
        for (Schema.PicklistEntry f : fld.getPicklistValues())
        {
            if (f.getValue().startsWith('STAT BI') && f.getValue().endsWith('Perform BI') && f.getValue().length()==20) 
            {
                retVal=f.getValue().substring(0,9);
            }
        }
		
		return retVal;
	}

	public static Set<String> getRXSerialStates()
	{
	    Set<String> rxSerialStates = new Set<String>();

        String setting=GNE_CM_CustomSettingsHelper.self().getCMConfig().Rx_Serial_States__c;

        if (setting!=null) 
        {
            for (String s : setting.split(';')) 
            {
                rxSerialStates.add(s);
            }
        }
        return rxSerialStates;
	}

	public static Set<String> getNonStarterProducts()
	{
	    Set<String> nonStarterProds = new Set<String>();

        String setting=GNE_CM_CustomSettingsHelper.self().getCMConfig().Non_Starter_Products__c;

        if (setting!=null) 
        {
            for (String s : setting.split(';')) 
            {
                nonStarterProds.add(s);
            }
        }
        return nonStarterProds;
	}

	public static Boolean subjectContainsInUrgentQueue(String product, String subject, List<GNE_CM_QMUrgentActivities> urgentActivities) {
		if(urgentActivities != null && urgentActivities.size() > 0) {
			for(GNE_CM_QMUrgentActivities urgentActivity : urgentActivities) {
				if(urgentActivity.product.toUpperCase().equals(product) && 
						(urgentActivity.subject.toUpperCase().equals(subject) ||
							urgentActivity.subject.toUpperCase().equals('ALL')) ) {
					return true;
				}
			}
		}
		return false;
	}
	
	public static List<GNE_CM_QMUrgentActivities> getUrgentSubjects()
	{
		List<GNE_CM_QMUrgentActivities> result = new List<GNE_CM_QMUrgentActivities>();  
		List<QM_Urgent_Activities__c> urgentActivityRecords = [select product__c, Activity_Subject__c from QM_Urgent_Activities__c limit 1000];
		if(urgentActivityRecords != null && urgentActivityRecords.size() > 0) {
			for(QM_Urgent_Activities__c urgentActivityRecord : urgentActivityRecords) {
				result.add(new GNE_CM_QMUrgentActivities(urgentActivityRecord.product__c, urgentActivityRecord.Activity_Subject__c));
			}
		}
		return result;
	}
	
	public Static List<String> getAllSubjectProducts() {
		List<QM_Urgent_Activities__c> allSubjectUrgentActivities = [select Product__c from QM_Urgent_Activities__c where Activity_Subject__c = 'All'];
		List<String> allSubjectProducts = new List<String>();
		for(QM_Urgent_Activities__c urgentSubjectActivity : allSubjectUrgentActivities) {
			allSubjectProducts.add(urgentSubjectActivity.Product__c);
		}
		return allSubjectProducts;
	}
	
	public static String getGenericUserId()
	{
		String queueOwner = currentConfig.Queue_Generic_Owner_gne__c;
		return [SELECT Id FROM User WHERE Name =: queueOwner].Id;
	}
	
	public static String getRSGenericUserId()
	{
		GNE_CM_Task_Queue_Config__c oldConfig=currentConfig;

		// use RS Config and call base implementation
		currentConfig=CustomSettingsHelper.taskQueueSelf().getQueueConfig().get(CustomSettingsHelper.CM_RS_TASK_QUEUE_CONFIG);

		String retId = getGenericUserId();

		// restore default config
		currentConfig=oldConfig;

		return retId;
	}

    /**
     * Helper to fetch the created date limit from Task Queue settings to be used to filter Task queries and improve performance
     */
	public static Date getStartCreatedDate()
	{
		Date startCreatedDate=system.today().addDays(-365);	
		Decimal maxDays=currentConfig.Queue_Task_Max_Age_Days__c;
		if (maxDays!=null) 
		{
			startCreatedDate=system.today().addDays(Integer.valueOf(-1 * maxDays));
		}
		return startCreatedDate;
	}

    /**
     * Helper to fetch the created date limit from Task Queue settings to be used to filter Task queries and improve performance
     */
	public static Date getRSStartCreatedDate()
	{
		//  save default config
		GNE_CM_Task_Queue_Config__c oldConfig=currentConfig;

		// use RS Config and call base implementation
		currentConfig=CustomSettingsHelper.taskQueueSelf().getQueueConfig().get(CustomSettingsHelper.CM_RS_TASK_QUEUE_CONFIG);

		Date dRet=getStartCreatedDate();

		// restore default config
		currentConfig=oldConfig;

		return dRet;
	}

	public static Boolean isRSQueueDisabled()
	{
		 return CustomSettingsHelper.taskQueueSelf().getQueueConfig().get(CustomSettingsHelper.CM_RS_TASK_QUEUE_CONFIG).Queue_Disabled_gne__c;
	}


	public static Boolean isRSQueueDownTime(Integer cHour)
	{
		//  save default config
		GNE_CM_Task_Queue_Config__c oldConfig=currentConfig;

		// use RS Config and call base implementation
		currentConfig=CustomSettingsHelper.taskQueueSelf().getQueueConfig().get(CustomSettingsHelper.CM_RS_TASK_QUEUE_CONFIG);

		Boolean bRet=isQueueDownTime(cHour);

		// restore default config
		currentConfig=oldConfig;

		return bRet;
	}

	public static String formatHour(Integer cHour)
	{
		String strRet='Error';

        if (cHour==12) 
        {
            strRet='12PM';
        }
        else if (cHour>12 && cHour<24) 
        {
            strRet='' + (cHour-12) + 'PM';
        }
        else if (cHour>0 && cHour<12)
        {
            strRet='' + cHour + 'AM';
        }
        else if (cHour==0)
        {
        	strRet='12AM';
        }
        return strRet;
	}

	public static String formatDate(Date dte)
	{
		return (dte==null ? '' : (dte.month() + '/' + dte.day() + '/' + dte.year()));
	}
	
	public static List<Integer> getQueueDownTimeHours()
	{
		List<Integer> lstRet=new List<Integer>();

		//  save default config
		GNE_CM_Task_Queue_Config__c oldConfig=currentConfig;

		// use RS Config and call base implementation
		currentConfig=CustomSettingsHelper.taskQueueSelf().getQueueConfig().get(CustomSettingsHelper.CM_RS_TASK_QUEUE_CONFIG);

		lstRet.add(Integer.valueOf(currentConfig.Queue_Down_Start_Time_gne__c==null ? '0' : currentConfig.Queue_Down_Start_Time_gne__c));
		lstRet.add(Integer.valueOf(currentConfig.Queue_Down_End_Time_gne__c==null ? '2' : currentConfig.Queue_Down_End_Time_gne__c));

		// restore default config
		currentConfig=oldConfig;

		return lstRet;
	}

	/*
	 * given settings, calculate the effective Activity Date for an RS BI task 
	 */
	public static Date getRSPrioritizedDate(String product, Date aDOT)
	{
		Date tday=System.today();
		Date ret=tday;

		//  save default config
		GNE_CM_Task_Queue_Config__c oldConfig=currentConfig;

		// use RS Config
		currentConfig=CustomSettingsHelper.taskQueueSelf().getQueueConfig().get(CustomSettingsHelper.CM_RS_TASK_QUEUE_CONFIG);

		Date blzdEnd=GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).ADOT_Schedule_End_Date__c;
		Date blzdStart=GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).ADOT_Schedule_Start_Date__c;

		String blzdProducts=currentConfig.Blizzard_Products__c;
		
		if (!String.isEmpty(blzdProducts))
		{
			Set<String> setProds=new Set<String>();
			setProds.addAll(blzdProducts.split(','));

			if (aDOT!=null && aDOT>=tday && 
						aDOT>=blzdStart && aDOT<=blzdEnd && 
						tday>=blzdStart && tday<=blzdEnd && 
						setProds.contains(product))
			{
						ret = aDOT;
		        /*Integer antDate = aDOT.day();
		        Integer antMonth = aDOT.month();
		        Integer antYear = aDOT.year();

		        if (antMonth == 1 && antDate < 9)
		        {
		            ret = date.newInstance(antYear, 1, 2);
		        }
		        else
		        {
		            ret = aDOT.addDays(Integer.valueOf(-1 * currentConfig.Blizzard_ADOT_Offset__c));
		        	
		        }*/
			}
		}

		// restore default config
		currentConfig=oldConfig;

		return ret;
	}

	/*
	 * given settings, calculate the effective Activity Date for an RS BI task
	 */
	public static Date getADOTOffsetDate(Date aDOT)
	{
		Date tday=System.today();
		Date ret=tday;

		//  save default config
		GNE_CM_Task_Queue_Config__c oldConfig=currentConfig;

		// use RS Config
		currentConfig=CustomSettingsHelper.taskQueueSelf().getQueueConfig().get(CustomSettingsHelper.CM_RS_TASK_QUEUE_CONFIG);

		if (aDOT!=null)
		{
	        /*Integer antDate = aDOT.day();
	        Integer antMonth = aDOT.month();
	        Integer antYear = aDOT.year();

	        if(antMonth == 1 && antDate < 9 && antYear == (system.Today().year() + 1))
	        {
	            ret = date.newInstance(antYear, 1, 2);
	        }
	        else
	        {
	            ret = aDOT.addDays(Integer.valueOf(-1 * currentConfig.Blizzard_ADOT_Offset__c));
	        }*/
	        ret = aDOT;
		}

		// restore default config
		currentConfig=oldConfig;

		return ret;
	}

	public static GNE_CM_RS_Queue_Config__c getRSQueueConfig()
	{
		return getRSQueueConfig(UserInfo.getProfileId(), UserInfo.getUserId());
	}
	
	public static GNE_CM_RS_Queue_Config__c getRSQueueConfig(String profileId, String userId)
	{
		GNE_CM_RS_Queue_Config__c retObj=new GNE_CM_RS_Queue_Config__c(
				Open_Task_Threshold__c=2,
				Grouping_Days_in_Future__c=1,
				Min_Tasks_per_Assignment__c=5,
				Max_Tasks_per_Assignment__c=7,
				Today_Tasks_per_Assignment__c=0,
				Urgent_Tasks_per_Assignment__c=1,
				Product_gne__c='',
				Activity_Types_gne__c='');

   		for(Schema.PicklistEntry f : GNE_CM_RS_Queue_Config__c.Product_gne__c.getDescribe().getPicklistValues())
   		{
      		if (!String.isEmpty(retObj.Product_gne__c))
      		{
      			retObj.Product_gne__c+=';';
      		}
      		retObj.Product_gne__c+=f.getValue();
   		}       

   		for(Schema.PicklistEntry f : GNE_CM_RS_Queue_Config__c.Activity_Types_gne__c.getDescribe().getPicklistValues())
   		{
      		if (!String.isEmpty(retObj.Activity_Types_gne__c))
      		{
      			retObj.Activity_Types_gne__c+=';';
      		}
      		retObj.Activity_Types_gne__c+=f.getValue();
   		}       

		Profile pf=[SELECT Id, Name FROM Profile WHERE Id=:profileId];
		for (GNE_CM_RS_Queue_Config__c qc : [SELECT Activity_Types_gne__c,Id,Product_gne__c,Profile__c,Open_Task_Threshold__c,Grouping_Days_in_Future__c,Min_Tasks_per_Assignment__c,Max_Tasks_per_Assignment__c,Today_Tasks_per_Assignment__c,Urgent_Tasks_per_Assignment__c,User__c,Bracket_Start_Date__c,Bracket_End_Date__c  
												FROM GNE_CM_RS_Queue_Config__c 
												WHERE Profile__c=:pf.Name OR User__c=:userId])
		{
			if (pf.Name==qc.Profile__c)
			{
				retObj=qc;
			}

			if (UserInfo.getUserId()==qc.User__c)
			{
				retObj=qc;
				break;
			}
		}
		if (retObj!=null && retObj.Activity_Types_gne__c!=null)
		{
			retObj.Activity_Types_gne__c=retObj.Activity_Types_gne__c.Replace('Follow-up on Requested PA/PreD', 'Follow-up on Requested Prior Authorization/PreD');
			retObj.Activity_Types_gne__c=retObj.Activity_Types_gne__c.Replace('Follow-up on Requested PA/Pre-D Form', 'Follow-up on Requested Prior Authorization/Pre-D Form');
			retObj.Activity_Types_gne__c=retObj.Activity_Types_gne__c.Replace('Follow-up on Submitted PA/PreD', 'Follow-up on Submitted Prior Authorization/PreD');
			retObj.Activity_Types_gne__c=retObj.Activity_Types_gne__c.Replace('Perform Benefit Investigation for AR', 'Perform Benefit Investigation for Appeals Referral');
		}
		return retObj;
	}


	private static Set<Id> EXCLUDED_USERS_CACHE = new Set<Id>();
	public static Set<Id> getExcludedUsers()
	{
		Set<Id> result = new Set<Id>();
		
		if (!EXCLUDED_USERS_CACHE.isEmpty())
		{
			result.addAll(EXCLUDED_USERS_CACHE);
		}
		else
		{
			String excludedUsers = currentConfig.GNE_CM_Monitoring_User_Name__c;
			if(excludedUsers != null && excludedUsers.length() > 0)
			{
				if(excludedUsers.indexOf(',') != -1)
				{	
					List<String> excldUsersList = new List<String>();
					for(String userName : excludedUsers.split(',', -1))
					{
						excldUsersList.add(userName.trim());
					}		
					Map<Id, User> excludedUsersMap = new Map<Id, User>([SELECT Id FROM User WHERE Name IN: excldUsersList]);
					result.addAll(excludedUsersMap.keySet());
					EXCLUDED_USERS_CACHE.addAll(excludedUsersMap.keySet());
				}
				else
				{
					List<User> excludedUser = [SELECT Id FROM User WHERE Name =: excludedUsers];
					if(excludedUser.size() > 0)
					{
						Id excludedUserId = excludedUser[0].Id;
						result.add(excludedUserId);
						EXCLUDED_USERS_CACHE.add(excludedUserId);
					}
				}
			}
		}
		
		return result;
	}
	
	public static void flagTasksWithChangedAddress(List<Case> cases)
	{
		Set<Id> caseIds = new Set<Id>();
		for(Case c : cases)
		{
			caseIds.add(c.Id);
		}
		List<Task> tasksWithChangedAddr = [SELECT id FROM Task WHERE Isclosed = false AND Case_Id_gne__c IN: caseIds];
		for(Task t : tasksWithChangedAddr)
		{
			t.CM_Queue_Case_AddressID_Changed_gne__c = true;
		}
		update tasksWithChangedAddr;
	}
	
	public static void flagTasksWithChangedInsurance(Set<String> caseIds)
	{
		// touch tasks to recalc the payer id
		List<Task> tasksWithChangedIns = [SELECT id FROM Task WHERE Isclosed = false AND Case_Id_gne__c IN: caseIds];
		update tasksWithChangedIns;
	}
	
	public static List<String> filterAlertsDuringRestamping(Map<String, List<Task>> alertTaskMap)
	{		
		List<String> result = new List<String>();
		for(String alertId : alertTaskMap.keySet())
		{
			Boolean addToResult = true;
			for(Task taskItem : alertTaskMap.get(alertId))
			{				
				if(taskItem.Is_In_Restamping_Process_gne__c)
				{
					addToResult = false;
					break;
				}
			}
			if(addToResult)
			{
				result.add(alertId);
			}
		}
		return result;
	}
	
    public static Integer getCurrentJobCount()
    {
    	return [SELECT count()
                FROM AsyncApexJob 
                WHERE status in ('Processing', 'Queued', 'Preparing') 
                AND JobType = 'BatchApex'];
    }

	/* JH 2013-07-15 Obsolete per comments in header
	//1. restamping
	//2. unassignment
	//3. building
	public static QueueBatchTypes getJobToRun(Map<String, List<Environment_Variables__c>> envVarMultiValues, Integer currentHour)
	{	
		System.debug('############ getJobToRun in hour: ' + currentHour);
		QueueBatchTypes result = null;
    	String taskRestampingTime = CustomSettingsHelper.taskQueueSelf().getQueueConfig().get(CustomSettingsHelper.CM_TASK_QUEUE_CONFIG).Scheduled_Run_Hour_Task_Restamping__c;
    	String taskUnassignTime = CustomSettingsHelper.taskQueueSelf().getQueueConfig().get(CustomSettingsHelper.CM_TASK_QUEUE_CONFIG).Scheduled_Run_Hour_Task_Unassign__c;
    	String taskQueueBuildTime = CustomSettingsHelper.taskQueueSelf().getQueueConfig().get(CustomSettingsHelper.CM_TASK_QUEUE_CONFIG).Scheduled_Run_Hour_Task_Queue_Build__c;
    	Integer taskQueueNotificationTime = Integer.valueOf(CustomSettingsHelper.taskQueueSelf().getQueueConfig().get(CustomSettingsHelper.CM_TASK_QUEUE_CONFIG).Scheduled_Run_Hour_Queue_Notification__c);    	    	
		String unassignmentStatus = envVarMultiValues.get(GNE_CM_Task_Queue_Mgmt_Helper.QUEUE_UNASSIGN_STATUS)[0].Value__c;
		String buildStatus = envVarMultiValues.get(GNE_CM_Task_Queue_Mgmt_Helper.QUEUE_BUILD_STATUS)[0].Value__c;
		String restampingStatus = envVarMultiValues.get(GNE_CM_Task_Queue_Mgmt_Helper.QUEUE_RESTAMPING_STATUS)[0].Value__c;
    	Datetime lastRestampingEnd = getLastRunDateTime(envVarMultiValues.get(GNE_CM_Task_Queue_Mgmt_Helper.QUEUE_RESTAMPING_END_TIME)[0].Value__c);
    	Datetime lastUnassignEnd = getLastRunDateTime(envVarMultiValues.get(GNE_CM_Task_Queue_Mgmt_Helper.QUEUE_UNASSIGN_END_TIME)[0].Value__c);
    	Datetime lastBuildEnd = getLastRunDateTime(envVarMultiValues.get(GNE_CM_Task_Queue_Mgmt_Helper.QUEUE_BUILD_END_TIME)[0].Value__c);
    	    	    	
    	if(isTimeForRunning(currentHour, getListOfHours(taskRestampingTime), lastRestampingEnd, restampingStatus))
		{
			result = QueueBatchTypes.Restamping;
		}
		else if(isTimeForRunning(currentHour, getListOfHours(taskUnassignTime), lastUnassignEnd, unassignmentStatus))
		{
			result = QueueBatchTypes.Unassign;
		}
		else if(isTimeForRunning(currentHour, getListOfHours(taskQueueBuildTime), lastBuildEnd, buildStatus))
		{
			result = QueueBatchTypes.Build;
		}
		else if(currentHour == taskQueueNotificationTime)
		{
			result = QueueBatchTypes.Notification;
		}
		return result;
	}
	*/
	
	private static List<Integer> getListOfHours(String hours)
	{
		List<Integer> result = new List<Integer>();
		for(String hour : hours.split(','))
		{
			result.add(Integer.valueOf(hour.trim()));
		}
		return result;
	}
	
	private static DateTime getLastRunDateTime(String value)
	{
		DateTime result;
		try
		{
			result = Datetime.valueOfGMT(value);
		}
		catch(Exception ex)
		{
			//default to 1 Jan 2000
			result = Datetime.newInstanceGMT(2000, 1, 1);
		}		
		return result;		
	}
	
	//the function verifies if this is valid time for running specific job - checks currentHour match, lastrun was in the past and not today and if job is not currently in progress 
	private static Boolean isTimeForRunning(Integer currentHour, List<Integer> jobHours, Datetime lastEndTime, String status)
	{
		Boolean result = false;
		for(Integer jobHour : jobHours)
		{
			if(currentHour == jobHour && 
				isQueueDownTime(currentHour) &&
				isLastEndTimeBeforeCurrentPeriod(lastEndTime, currentHour) && 
				status != GNE_CM_Task_Queue_Mgmt_Helper.ProcessingStatuses.InProgress.name())
			{
				result = true;
			}
		}
		return result;
	}
	
	private static Boolean isQueueDownTime(Integer cHour)
	{
		Integer startOffHour = Integer.valueOf(currentConfig.Queue_Down_Start_Time_gne__c);
		Integer endOffHour = Integer.valueOf(currentConfig.Queue_Down_End_Time_gne__c);
		
		if(startOffHour == endOffHour)
		{
			return false;
		}
		else if(startOffHour < endOffHour) //ex. 8-10
		{
			if(cHour >= startOffHour && cHour <= endOffHour) return true;				
		}
		else if(startOffHour > endOffHour) //ex. 21-5
		{
			if(cHour >= startOffHour || cHour <= endOffHour) return true;				
		}
		return false;
	}
	
	private static Boolean isLastEndTimeBeforeCurrentPeriod(Datetime lastEndTime, Integer cHour)
	{
		Integer startOffHour = Integer.valueOf(currentConfig.Queue_Down_Start_Time_gne__c);
		Integer endOffHour = Integer.valueOf(currentConfig.Queue_Down_End_Time_gne__c);
		Datetime beginOffHourTime;
		
		if(lastEndTime >= Datetime.now())
		{
			return false;
		}
		
		if(startOffHour == endOffHour)
		{
			return false;
		}
		else if(startOffHour < endOffHour) //ex. 8-10
		{
			beginOffHourTime = Datetime.newInstanceGMT(Datetime.now().year(), Datetime.now().month(), Datetime.now().day(), startOffHour, 0, 0);
		}
		else if(startOffHour > endOffHour) //ex. 21-5
		{
			if(cHour >= startOffHour)
			{
				beginOffHourTime = Datetime.newInstanceGMT(Datetime.now().year(), Datetime.now().month(), Datetime.now().day(), startOffHour, 0, 0);
			}
			else if(cHour <= endOffHour)
			{
				beginOffHourTime = Datetime.newInstanceGMT(Datetime.now().year(), Datetime.now().month(), Datetime.now().day() - 1, startOffHour, 0, 0);
			}
		}
		
		if(lastEndTime >= beginOffHourTime)
		{
			return false;
		}
		
		return true;
	}
	
    public static Set<String> getNotCountPAESubjects()
    {
        Set<String> envVarNameSet = new Set<String>{PAE_REQUEST_ASSIGNMENT_NOT_COUNT};
        Map<String, List<Environment_Variables__c>> envVarMultiValues = GNE_CM_Task_Queue_Mgmt_Helper.populateEnvVariables(envVarNameSet);
    
        return getSetOfValuesFromEnvVariable(envVarMultiValues, PAE_REQUEST_ASSIGNMENT_NOT_COUNT);
    }

	
	public static void flagProcessing(Map<String, List<Environment_Variables__c>> flags, GNE_CM_Monitoring_Auditing_gne__c monitoringEntry, ProcessingStatuses status, QueueBatchTypes batchType)
	{		
		if(batchType == QueueBatchTypes.Unassign)
		{   
			updateEnvVariables(flags.get(QUEUE_UNASSIGN_START_TIME)[0],
								flags.get(QUEUE_UNASSIGN_END_TIME)[0],
								flags.get(QUEUE_UNASSIGN_STATUS)[0],
								monitoringEntry, QueueBatchTypes.Unassign.name(), status);
		}
		else if(batchType == QueueBatchTypes.Build)
		{
			updateEnvVariables(flags.get(QUEUE_BUILD_START_TIME)[0],
								flags.get(QUEUE_BUILD_END_TIME)[0],
								flags.get(QUEUE_BUILD_STATUS)[0],
								monitoringEntry, QueueBatchTypes.Build.name(), status);
		}
		else if(batchType == QueueBatchTypes.Restamping)
		{
			updateEnvVariables(flags.get(QUEUE_RESTAMPING_START_TIME)[0],
								flags.get(QUEUE_RESTAMPING_END_TIME)[0],
								flags.get(QUEUE_RESTAMPING_STATUS)[0],
								monitoringEntry, QueueBatchTypes.Restamping.name(), status);	
		}
	}
	
	private static void updateEnvVariables(Environment_Variables__c startTime, 
											Environment_Variables__c endTime, 
											Environment_Variables__c statusEV,
											GNE_CM_Monitoring_Auditing_gne__c monitoringEntry, 
											String processName,
											ProcessingStatuses status)
	{
		List<Environment_Variables__c> envVar2Update = new List<Environment_Variables__c>();		
		monitoringEntry.Name_gne__c = processName;
		if(status == ProcessingStatuses.InProgress)
		{
			statusEV.Value__c = ProcessingStatuses.InProgress.name();
			envVar2Update.add(statusEV);
			startTime.Value__c = String.valueOf(datetime.now());
			envVar2Update.add(startTime);
			monitoringEntry.Status_gne__c = ProcessingStatuses.InProgress.name();
			monitoringEntry.Time_Start_Date_Time_gne__c = datetime.now();
		}
		else if(status == ProcessingStatuses.Failed)
		{
			statusEV.Value__c = ProcessingStatuses.Failed.name();
			envVar2Update.add(statusEV);
			endTime.Value__c = String.valueOf(datetime.now());
			envVar2Update.add(endTime);
			monitoringEntry.Status_gne__c = ProcessingStatuses.Failed.name();
			monitoringEntry.Time_End_Date_Time_gne__c = datetime.now();
		}
		else if(status == ProcessingStatuses.Successful)
		{
			statusEV.Value__c = ProcessingStatuses.Successful.name();
			envVar2Update.add(statusEV);
			endTime.Value__c = String.valueOf(datetime.now());
			envVar2Update.add(endTime);
			monitoringEntry.Status_gne__c = ProcessingStatuses.Successful.name();
			monitoringEntry.Time_End_Date_Time_gne__c = datetime.now();
		}
		
		upsert monitoringEntry;
		if(envVar2Update.size() > 0)
			update envVar2Update;
	}
	
	public static Map<String, List<Environment_Variables__c>> populateEnvVariables(Set<String> envVarNameSet)
    {
    	Map<String, List<Environment_Variables__c>> result = new Map<String, List<Environment_Variables__c>>();
        for (Environment_Variables__c envVar : GNE_CM_Environment_variable.get_env_variable(envVarNameSet))
        {
        	if(result.containsKey(envVar.Key__c))
        	{
        		result.get(envVar.Key__c).add(envVar);
        	}
        	else
        	{
        		List<Environment_Variables__c> variables = new List<Environment_Variables__c>();
        		variables.add(envVar);
        		result.put(envVar.Key__c, variables);
        	}        
        }
        return result;
    }
    
    public static TaskUpdateResult restampTasksAddresses(List<Task> tasks, Integer currentCount)
    { 
    	TaskForUpdate tasksForRestamping = getRestampingTask2Update(tasks, currentCount);  	
    	tasksForRestamping.errorIds.addAll(safeUpdate(tasksForRestamping.task2Update, 'restampTasks'));
    	return new TaskUpdateResult(tasksForRestamping.counter, tasksForRestamping.errorIds);    	
    }
    
    public static TaskForUpdate getRestampingTask2Update(List<Task> tasks, Integer currentCount)
    {
    	Set<Id> caseIds = new Set<Id>();
    	Set<Id> errorIds = new Set<Id>();
    	List<Error_Log_gne__c> errorLogList = new List<Error_Log_gne__c>();
    	String errMessage;
    	List<Task> tasks2Update = new List<Task>();
    	for(Task t : tasks)
    	{
    		caseIds.add(t.Case_Id_gne__c);
    	}
    	
    	Map<Id, Case> taskCases = new Map<Id, Case>([SELECT Address_gne__c, State_Treating_Physician_gne__c, RecordType.Name FROM Case WHERE Id IN : caseIds]);
    	for(Task taskItem : tasks)
    	{
			if(taskItem.Case_Id_gne__c != null && taskCases.get(taskItem.Case_Id_gne__c) != null)
			{
				taskItem.CM_Case_AddressId_gne__c = taskCases.get(taskItem.Case_Id_gne__c).Address_gne__c;
				taskItem.CM_Queue_TimeZone_Number_gne__c = getStateTimeZone(taskCases.get(taskItem.Case_Id_gne__c).State_Treating_Physician_gne__c);
				taskItem.CM_Case_Record_Type_Name_gne__c = taskCases.get(taskItem.Case_Id_gne__c).RecordType.Name;
				currentCount++;
			}
			else
			{
				//default time zone
				taskItem.CM_Queue_TimeZone_Number_gne__c = Integer.valueOf(currentConfig.Queue_Default_Time_Zone_Number_gne__c);
				errorIds.add(taskItem.Id);
				errMessage = 'Task with id: ' + taskItem.Id + ' did not have matching Case to pull address from';
				errorLogList.add(new Error_Log_gne__c(Object_Name__c = 'GNE_CM_Task_Queue_Mgmt_Helper', 
												Error_Level_gne__c = 'High',
												Snippet_Name__c = 'restampTasksAddresses', 
												Code_Type__c = 'Apex Batch Class', 
												Error_Description__c = errMessage, 
												User_Name__c = GNE_CM_MPS_Utils.getUserName()));
			}
    		taskItem.CM_Queue_Case_AddressID_Changed_gne__c = false;
    		taskItem.Is_In_Restamping_Process_gne__c = true;
    		tasks2Update.add(taskItem);    		
    	}
    	if(errorLogList.size() > 0)
    	{
    		insert errorLogList;
    	}
    	return new TaskForUpdate(tasks2Update, currentCount, errorIds);
    }
    
    public static TaskUpdateResult reassignTasks(List<Task> tasks, List<GNE_CM_QMUrgentActivities> urgentActivities, Id newOwner, Integer limit4Processing, Date nDaysInFuture, Integer currentCount)
	{	
		List<Task> task2Update = new List<Task>();		
		for(Task t : tasks)
		{
			t.OwnerId = newOwner;
			t.CM_Queue_Group_Assignment_Number_gne__c = null;
			t.CM_Queue_Group_Due_Date_gne__c = null;
			if(t.CM_Queue_Name_gne__c != QueueNames.Urgent.name())
			{				
				//limit for processing has been reapplied
				if(t.ActivityDate <= nDaysInFuture && currentCount < limit4Processing)
				{
					t.CM_Queue_Name_gne__c = QueueNames.Processing.name();
					currentCount++;
				}
				else
				{
					t.CM_Queue_Name_gne__c = null;
				}			
			}
			//stamping urgent tasks
			if(t.Subject != null && subjectContainsInUrgentQueue(t.Product_gne__c.toUpperCase(), t.Subject.toUpperCase(), urgentActivities))
			{
				t.CM_Queue_Name_gne__c = GNE_CM_Task_Queue_Mgmt_Helper.QueueNames.Urgent.name();
			}
			task2Update.add(t);
		}		
		Set<Id> errorIds = safeUpdate(task2Update, 'reassignTasks');
		return new TaskUpdateResult(currentCount, errorIds);				
	}
	
	public static TaskQueueBuildResult createWorkAssignments(List<Task> tasks,
														Integer targetNumberActivitiesInWA,
														Integer maxNumberActivitiesInWA,
														PrescriberGroup notFullPrescriberGroup, 
														WorkAssignment notFullWorkAssignment,
														Integer workAssignmentCounter,
														Integer taskCounter,
														Integer totalNumberOfTasks)
	{
		Map<String, PrescriberGroup> prescriberGroupsMap = new Map<String, PrescriberGroup>();		
		WorkAssignment previousWA = null;
		String previousPGKey = null;
		Set<Id> errorIds = new Set<Id>();
		List<Task> taskWithEmptyAddress = new List<Task>();		
		
		if(notFullPrescriberGroup != null)
		{
			prescriberGroupsMap.put(notFullPrescriberGroup.key, notFullPrescriberGroup);
			previousPGKey = notFullPrescriberGroup.key;
			prescriberGroupsMap.get(previousPGKey).wasSplit = false;
		}
		if(notFullWorkAssignment != null)
		{
			previousWA = notFullWorkAssignment;
			previousWA.isSliced = true;			
		}			
		
		//process tasks into Prescriber Groups		
		for(Task t : tasks)
		{
			String key = t.CM_Case_AddressId_gne__c;
			if(key == null) //the logic for treating tasks with addressId null as one prescriber group
			{
				key = 'empty';
				taskWithEmptyAddress.add(t);
			}
			if(prescriberGroupsMap.containsKey(key))
			{		
				prescriberGroupsMap.get(key).addTask(t);
				//the functionality for splitting extremely large prescriber groups
				if(prescriberGroupsMap.get(key).tasksCount() > 1000 && !prescriberGroupsMap.get(key).wasSplit)
				{
					List<PrescriberGroup> splittedGroups = GNE_CM_Task_Queue_Mgmt_Helper.splitPrescriberGroup(prescriberGroupsMap.get(key), maxNumberActivitiesInWA);
					Integer counterLastPG = 0;
					for(PrescriberGroup pg : splittedGroups)
					{						
						prescriberGroupsMap.put(pg.key, pg);						
						counterLastPG++;
					}
					PrescriberGroup lastPrescriberGroup = splittedGroups[counterLastPG - 1];					
					//remove original prescriber group
					prescriberGroupsMap.remove(key);
					//remove last splitted prescriber group
					prescriberGroupsMap.remove(lastPrescriberGroup.key);
					//add again last prescriber group flagged as non-full as original prescriber group
					lastPrescriberGroup.isFull = false;
					lastPrescriberGroup.key = key;
					if(lastPrescriberGroup.tasksCount() > 900)
					{
						lastPrescriberGroup.wasSplit = true;
					}
					prescriberGroupsMap.put(lastPrescriberGroup.key, lastPrescriberGroup); 
				}
			}
			else
			{
				if(previousPGKey != null)
				{
					if(prescriberGroupsMap.get(previousPGKey).tasksCount() > maxNumberActivitiesInWA)
					{						
						List<PrescriberGroup> splittedGroups = GNE_CM_Task_Queue_Mgmt_Helper.splitPrescriberGroup(prescriberGroupsMap.get(previousPGKey), maxNumberActivitiesInWA);
						for(PrescriberGroup pg : splittedGroups)
						{
							prescriberGroupsMap.put(pg.key, pg);
						}
						prescriberGroupsMap.remove(previousPGKey);
					}
					else
					{
						prescriberGroupsMap.get(previousPGKey).isFull = true;
					}
				}		
				PrescriberGroup newPG = new PrescriberGroup(t);
				newPG.key = key;							
				prescriberGroupsMap.put(key, newPG);				
			}
			previousPGKey = key;			
			taskCounter++;
		}
		
		//for last task in batch flag prescriberGroup as full or split the prescriber group if needed	
		if(previousPGKey != null && taskCounter == totalNumberOfTasks)
		{
			if(prescriberGroupsMap.get(previousPGKey).tasksCount() > maxNumberActivitiesInWA)
			{				
				List<PrescriberGroup> splittedGroups = GNE_CM_Task_Queue_Mgmt_Helper.splitPrescriberGroup(prescriberGroupsMap.get(previousPGKey), maxNumberActivitiesInWA);
				for(PrescriberGroup pg : splittedGroups)
				{
					prescriberGroupsMap.put(pg.key, pg);
				}
				prescriberGroupsMap.remove(previousPGKey);
			}
			else
			{
				prescriberGroupsMap.get(previousPGKey).isFull = true;
			}
		}
		
		//process Prescriber Groups into Work Assignments
		List<Task> task2Update = new List<Task>();
		System.debug('wilczekk prescriberGroupsMap size: ' + prescriberGroupsMap.values().size());		
		//sort prescriber groups by due date to be sure during testing which group is created first and which number does it have	
		List<PrescriberGroup> sortedByDueDate = prescriberGroupsMap.values();
		GlobalUtils.qsort(sortedByDueDate, new GNE_CM_Task_Queue_Mgmt_Helper.PrescriberGroupComparator());
			
		for(PrescriberGroup pg : sortedByDueDate)
		{
			System.debug('wilczekk sortedByDueDate: ' + pg.dueDate);
			System.debug('wilczekk sortedByDueDate is full: ' + pg.isFull);
			System.debug('wilczekk sortedByDueDate tasksCount: ' + pg.tasksCount());			
		}
		
		for(PrescriberGroup pg : sortedByDueDate)
		{
			if(pg.isFull)
			{
				System.debug('wilczekk sortedByDueDate processing following: ' + pg.dueDate);
				if(pg.tasksCount() < targetNumberActivitiesInWA)				
				{					
					System.debug('wilczekk pres group with tasks < target: ' + pg.dueDate);
					if(previousWA != null && 
						previousWA.timeZone == pg.timeZone &&
						previousWA.tasksCount() + pg.tasksCount() <= maxNumberActivitiesInWA) 
					{	
						if(!previousWA.isSliced || previousWA.dueDate == pg.dueDate) //wilczekk: additional condition added for issue with content with different due dates in one prescriber group (SFDC-1150)
						{
							System.debug('wilczekk add to previous pres group: ' + pg.dueDate);					
							previousWA.addAllTasks(pg);
							continue;
						}					
					}																								
				}
				else
				{
					if(previousWA != null && !previousWA.isCompleted)
					{
						workAssignmentCounter = GNE_CM_Task_Queue_Mgmt_Helper.completeWorkAssignment(previousWA, task2Update, workAssignmentCounter);
						previousWA = null;						
					}
					workAssignmentCounter = GNE_CM_Task_Queue_Mgmt_Helper.completeWorkAssignment(new WorkAssignment(pg), task2Update, workAssignmentCounter);					
					continue;
				}
				
				if(previousWA != null)
				{
					System.debug('wilczekk complete previous: ' + pg.dueDate);
					workAssignmentCounter = GNE_CM_Task_Queue_Mgmt_Helper.completeWorkAssignment(previousWA, task2Update, workAssignmentCounter);
				}					
				previousWA = new WorkAssignment(pg);
				System.debug('wilczekk next: ' + pg.dueDate);
			}
		}
		
		//for last batch complete last Work Assignment if not completed already	
		if(previousWA != null && taskCounter == totalNumberOfTasks && !previousWA.isCompleted)
			{
				workAssignmentCounter = GNE_CM_Task_Queue_Mgmt_Helper.completeWorkAssignment(previousWA, task2Update, workAssignmentCounter);
			}
				
		if(task2Update.size() > 0)
		{					
			errorIds = safeUpdate(task2Update, 'createWorkAssignments');
		}
		
		PrescriberGroup previousPG = null;
		if(previousPGKey != null && 
		prescriberGroupsMap.containsKey(previousPGKey) &&
		prescriberGroupsMap.get(previousPGKey).isFull == false)
		{
			previousPG = prescriberGroupsMap.get(previousPGKey);
		}
		
		TaskQueueBuildResult result = new TaskQueueBuildResult(workAssignmentCounter, taskCounter, errorIds, previousWA, previousPG);
		result.updatedQueueCounter = task2Update.size() - errorIds.size();
		result.tasksWithEmptyAddress = taskWithEmptyAddress;
		return result;
	}
	
	public static Integer getStateTimeZone(String stateCode)
	{
		Integer resultTimeZone = Integer.valueOf(currentConfig.Queue_Default_Time_Zone_Number_gne__c);

		if(stateCode != null && stateCode.length() > 0)
		{
			List<GNE_CM_TimeZone_Mapping_gne__c> timeZones = [SELECT CM_TimeZone_Number_gne__c FROM GNE_CM_TimeZone_Mapping_gne__c WHERE CM_TimeZone_Mapping_State_gne__c =: stateCode];
			if(timeZones.size() > 0)
			{
				resultTimeZone = Integer.valueOf(timeZones[0].CM_TimeZone_Number_gne__c);
			}
		}
		return resultTimeZone;
	} 
  	
	
	private static Integer completeWorkAssignment(WorkAssignment wa, List<Task> tasks, Integer workAssignmentCounter)
	{
		System.debug('wilczekk workAssignment completed due date: ' + wa.dueDate);
		System.debug('wilczekk workAssignment completed wa number: ' + workAssignmentCounter);
		for(Task t : wa.tasks)
		{
			t.CM_Queue_Name_gne__c = GNE_CM_Task_Queue_Mgmt_Helper.QueueNames.Regular.name();
			t.CM_Queue_Group_Assignment_Number_gne__c = workAssignmentCounter;
			t.CM_Queue_Group_Due_Date_gne__c = wa.dueDate;
			t.CM_Queue_Timezone_Number_gne__c = wa.timeZone;
			tasks.add(t);
		}
		workAssignmentCounter++;
		wa.isCompleted = true;
		return workAssignmentCounter;
	}
	
	private static List<PrescriberGroup> splitPrescriberGroup(PrescriberGroup presG, Integer maxNumberActivitiesInWA)
	{
		Map<String, PrescriberGroup> presGrpFromCaseGrpMap = new Map<String, PrescriberGroup>();	
		Map<String, CaseGroup> caseGroupsMap = new Map<String, CaseGroup>();		
		
		for(Task t : presG.tasks)
		{
			String key = t.CM_Case_Number_gne__c;
			if(caseGroupsMap.containsKey(key))
			{
				caseGroupsMap.get(key).addTask(t);
			}
			else
			{
				CaseGroup caseG = new CaseGroup(t);
				caseGroupsMap.put(caseG.key, caseG);
			}		
		}
		
		List<CaseGroup> sortedByDueDate = caseGroupsMap.values();
		GlobalUtils.qsort(sortedByDueDate, new GNE_CM_Task_Queue_Mgmt_Helper.CaseGroupComparator());		
				
		Integer counter = 1;
		String previousPGKey = null;
		for(CaseGroup cg : sortedByDueDate)
		{
			if(cg.tasksCount() <= maxNumberActivitiesInWA)			
			{
				if(previousPGKey != null && presGrpFromCaseGrpMap.get(previousPGKey).tasksCount() + cg.tasksCount() < maxNumberActivitiesInWA)
				{
					presGrpFromCaseGrpMap.get(previousPGKey).addAllTasks(cg.tasks);
					continue;
				}
			}
			
			PrescriberGroup presGrpFromCaseGroup = new PrescriberGroup(cg);
			presGrpFromCaseGroup.key = presG.key + counter;
			presGrpFromCaseGrpMap.put(presGrpFromCaseGroup.key, presGrpFromCaseGroup);
			previousPGKey = presGrpFromCaseGroup.key;					
			counter++;
		}
	
		//mark newly created prescriber groups as full
		for(PrescriberGroup presGFromCaseG : presGrpFromCaseGrpMap.values())
		{
			presGFromCaseG.isFull = true;
		}		
		
		return presGrpFromCaseGrpMap.values();
	}	

	public static Set<Id> safeUpdate(List<Task> tasks, String snippetName)
	{
		return safeUpdate(tasks, snippetName, 'GNE_CM_Task_Queue_Mgmt_Helper');
	}
	
	public static Set<Id> safeUpdate(List<Task> tasks, String snippetName, String objectName)
	{
		String errMessage;
		List<Task> task2Update = new List<Task>();
		List<Error_Log_gne__c> errorLogList = new List<Error_Log_gne__c>();
		Set<Id> errorIds = new Set<Id>();
		Set<Id> tasksWithSuccess = new Set<Id>();
		
		List<Database.Saveresult> results = Database.update(tasks, false);
		for(Integer idx=0; idx<results.size(); idx++)
		{
			Database.Saveresult res=results[idx];
			if(!res.isSuccess())
			{
				for(Database.Error err : res.getErrors())
				{	
					if(Limits.getHeapSize() + 500000 < Limits.getLimitHeapSize())
					{					
						errMessage = 'Failed to update Task (' + tasks[idx].Id + ') ' + err.getMessage();
						errorLogList.add(new Error_Log_gne__c(Object_Name__c = objectName, 
														Error_Level_gne__c = 'High',
														Snippet_Name__c = snippetName, 
														Code_Type__c = 'Apex Batch Class', 
														Error_Description__c = errMessage, 
														User_Name__c = GNE_CM_MPS_Utils.getUserName()));
					}
					else
					{						
						break;
					}
				}									
			}
			else
			{
				tasksWithSuccess.add(res.getId());
			}			   
		}		
		for(Task t : tasks)
		{
			if(!tasksWithSuccess.contains(t.Id))
			{
				errorIds.add(t.Id);
			}
		}
		if(errorLogList.size() > 0)
		{
			//insert only as many error logs as governor limits allow
			Integer numberOfDMLLeft = Limits.getLimitDmlRows() - Limits.getDmlRows();
			if(numberOfDMLLeft > errorLogList.size())
			{
				insert errorLogList;
			}
			else
			{
				List<Error_Log_gne__c> limitedErrors = new List<Error_Log_gne__c>();
				for(Error_Log_gne__c err : errorLogList)
				{
					if(numberOfDMLLeft > limitedErrors.size() && 
						Limits.getHeapSize() + 100000 < Limits.getLimitHeapSize())
					{
						limitedErrors.add(err);
					}
					else
					{
						insert limitedErrors;
						break;
					}
				}
			}
		}		
		return errorIds;
	}
	
	public static Boolean hasFailedJobs(Database.BatchableContext BC)
	{
		Boolean result = true;
		List<AsyncApexJob> buildJob = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
								      TotalJobItems, CreatedBy.Email
								      from AsyncApexJob where Id =
								      :BC.getJobId()];
		if(buildJob.size() > 0 && buildJob[0].NumberOfErrors == 0)
		{			
			result = false;
		}
		return result;
	}
	
	public static String getEmailAddress(ProcessingStatuses status)
	{
		String result;
		String environment = GlobalUtils.getEnvironment();
		
		if(status == ProcessingStatuses.Successful)
		{
			if(environment == 'prod')
			{
				result = currentConfig.Queue_Build_Summary_Email_PROD__c;
			}
			else
			{
				result = currentConfig.Queue_Build_Summary_Email_Dist_List__c;
			}
		}
		else if(status == ProcessingStatuses.Failed)
		{
			if(environment == 'prod')
			{
				result = currentConfig.Queue_Build_Failed_User_Email_PROD__c;
			}
			else
			{
				result = currentConfig.Queue_Build_Failed_User_Email_Dist_List__c;
			}
		}
		return result;
	}
        
    public static void sendEmailNotification(Set<Id> tasksWithErrors,
												String toAddress, 
												String subject,
												String senderDisplayName,
												String sourceClass,
												Integer numberOfAllTasks,
												Integer flaggedToProcess,
												Integer numberOfUnhandledExceptionTasks,
												QueueBatchTypes typeOfJob)
	{		
		try
		{
			Integer numberOfErrors = tasksWithErrors.size();				
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setToAddresses(new String[]{toAddress});
			mail.setSubject(subject);
			mail.setSenderDisplayName(senderDisplayName);		    
						
			String mailText = 'The batch Apex job processed ' + (numberOfAllTasks - numberOfErrors - numberOfUnhandledExceptionTasks) + ' tasks from total number of ' + numberOfAllTasks +
			' tasks with ' + numberOfErrors + ' failures.';			
			if(typeOfJob == QueueBatchTypes.Build)
			{
				mailText += '\n' + flaggedToProcess + ' tasks have been put into Regular Queue.';
			}
			else if(typeOfJob == QueueBatchTypes.Unassign)
			{
				mailText += '\n' + flaggedToProcess + ' tasks were flagged to be processed by queue building process.';
			}
			else if(typeOfJob == QueueBatchTypes.Restamping)
			{
				mailText += '\n' + flaggedToProcess + ' tasks had their address data restamped.';
			}
			if(numberOfErrors > 0)
			{
				mailText += '\n' + numberOfErrors + ' tasks were not updated. Review Error Log for details.';
				mailText += '\n\nError task ids with errors on update operation: ';
				for(Id errorTaskId :tasksWithErrors)
				{
					mailText += '\'' + errorTaskId + '\', '; 	
				}
				mailText = mailText.substring(0, mailText.length()-2);
			}
			if(numberOfUnhandledExceptionTasks > 0)
			{
				mailText += '\nThere were ' + numberOfUnhandledExceptionTasks + ' tasks that were not updated due to some unhandled exceptions. Review Error Log for details.';
			}		    
			mailText = applyEnvironmentStamp(mailText);
			mail.setPlainTextBody(mailText);
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
		catch(Exception ex)
		{
			String errMessageForEmail = 'Failed to send Notification Email ' + ex.getMessage();						
			Error_Log_gne__c error = new Error_Log_gne__c(Object_Name__c = sourceClass, 
												Error_Level_gne__c = 'High',
												Snippet_Name__c = sourceClass + '.finish', 
												Code_Type__c = 'Apex Batch Class', 
												Error_Description__c = errMessageForEmail, 
												User_Name__c = GNE_CM_MPS_Utils.getUserName());
												
			insert error;
		}
	}
	
	private static String applyEnvironmentStamp(String text)
	{
		String result = text;
		String environment = GlobalUtils.getUserTail(UserInfo.getUserName());
		if(environment != 'prod')
		{
			result += '\nThe source environment was: ' + environment;
		}
		return result;
	}
	
	public static void sendErrorNotification(Set<Id> tasksWithErrors,
												String toAddress, 
												String subject,
												String senderDisplayName,
												String sourceClass,
												Integer numberOfAllTasks,
												Integer numberOfUnhandledExceptionTasks,
												QueueBatchTypes typeOfJob)
	{		
		try
		{							
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setToAddresses(new String[]{toAddress});
			mail.setSubject(subject);
			mail.setSenderDisplayName(senderDisplayName);		    
						
			String mailText = 'Dear GATCF Supervisors,';
			mailText += '\nThe system was unable to build the GATCF Work Assignment Queue for today. As a result, when the "Request Assignment" feature is used, the Foundation Specialist will be assigned the next oldest 15 GATCF activities to work on. These activities will not be grouped by Prescriber or Case.';
			mailText += '\n\nUrgent and "Today" GATCF Activities will still be assigned per the normal process.';
			mailText += '\n\nTo minimize further disruption, the queue will not be rebuilt during working hours.  The next queue build will take place tonight at midnight.';
			mailText += '\n\nNo further action is required at this time. If you need technical assistance, please submit a gRemedy help desk ticket.';
			mailText += '\n\nThank you.';
			if(tasksWithErrors != null)
			{
				Integer numberOfErrors = tasksWithErrors.size();
				mailText += '\n\nAdditional Information: \nThere were ' + numberOfErrors + ' tasks that failed to be updated by unassign process out of total number ' + numberOfAllTasks + ' tasks.';			
				if(typeOfJob == QueueBatchTypes.Build)
				{
					mailText += '\nThe build process has been flagged as FAILED.';
				}
				else if(typeOfJob == QueueBatchTypes.Unassign)
				{
					mailText += '\nThe unassign process has been flagged as FAILED.';
				}					
				if(numberOfErrors > 0)
				{
					mailText += '\n' + numberOfErrors + ' tasks were not updated. Review Error Log for details.';
					mailText += '\n\nError task ids with errors on update operation: ';
					for(Id errorTaskId :tasksWithErrors)
					{
						mailText += '\'' + errorTaskId + '\', '; 	
					}
					mailText = mailText.substring(0, mailText.length()-2);
				}
				if(numberOfUnhandledExceptionTasks > 0)
				{
					mailText += '\nThere were ' + numberOfUnhandledExceptionTasks + ' tasks that were not updated due to some unhandled exceptions. Review Error Log for details.';
				}
			}		    
			mailText = applyEnvironmentStamp(mailText);
			mail.setPlainTextBody(mailText);
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
		catch(Exception ex)
		{
			String errMessageForEmail = 'Failed to send Notification Email ' + ex.getMessage();						
			Error_Log_gne__c error = new Error_Log_gne__c(Object_Name__c = sourceClass, 
												Error_Level_gne__c = 'High',
												Snippet_Name__c = sourceClass + '.finish', 
												Code_Type__c = 'Apex Batch Class', 
												Error_Description__c = errMessageForEmail, 
												User_Name__c = GNE_CM_MPS_Utils.getUserName());
												
			insert error;
		}			
	}
	
	public static void logCurrentStatus(String info, String sourceClass, String sourceMethod)
	{
		String logMessage = ' Current Limit Status: ';	
		logMessage += 'DML Rows: ' + Limits.getDmlRows() + ' out of ' + Limits.getLimitDmlRows() + ' ';
		logMessage += 'DML Statements: ' + Limits.getDMLStatements() + ' out of ' + Limits.getLimitDMLStatements() + ' ';
		logMessage += 'Heap Size: ' + Limits.getHeapSize() + ' out of ' + Limits.getLimitHeapSize() + ' ';
		logMessage += 'Queries: ' + Limits.getQueries() + ' out of ' + Limits.getLimitQueries() + ' ';
		logMessage += 'Query Rows: ' + Limits.getQueryRows() + ' out of ' + Limits.getLimitQueryRows() + ' ';								
		Error_Log_gne__c error = new Error_Log_gne__c(Object_Name__c = sourceClass, 
											Error_Level_gne__c = 'Low',
											Snippet_Name__c = sourceMethod, 
											Code_Type__c = 'Apex Batch Class', 
											Error_Description__c = info + logMessage, 
											User_Name__c = GNE_CM_MPS_Utils.getUserName());
											
		insert error;
	}
	
	public static Set<String> getSetOfValuesFromEnvVariable(Map<String, List<Environment_Variables__c>> envVarMultiValues, String envVarName)
	{
		Set<String> result = new Set<String>();
		List<Environment_Variables__c> envVariables = envVarMultiValues.get(envVarName);
		if(envVariables != null)
		{
			for(Environment_Variables__c envVar : envVariables)
			{
				result.add(envVar.Value__c.toUpperCase());
			}
		}
		return result;
	}
	
	public static List<Task> getTasksNotPutInRegularQueue(Map<String, List<Environment_Variables__c>> envVarMultiValues)
	{
		Set<String> recordTypeNames = new Set<String>{GNE_CM_Task_Queue_Mgmt_Helper.GATCF_RECORD_TYPE, GNE_CM_Task_Queue_Mgmt_Helper.GES_RECORD_TYPE};
		Set<Id> excludedUsers = GNE_CM_Task_Queue_Mgmt_Helper.getExcludedUsers();
		Set<String> excludedSubjects = GNE_CM_Task_Queue_Mgmt_Helper.getSetOfValuesFromEnvVariable(envVarMultiValues, GNE_CM_Task_Queue_Mgmt_Helper.QUEUE_TASK_SUBJECT_EXCLUDE);
		Set<String> queueNames = new Set<String>{GNE_CM_Task_Queue_Mgmt_Helper.QueueNames.Processing.name(), 
												GNE_CM_Task_Queue_Mgmt_Helper.QueueNames.Regular.name(), 
												GNE_CM_Task_Queue_Mgmt_Helper.QueueNames.Urgent.name()};
		Date startCreatedDate=GNE_CM_Task_Queue_Mgmt_Helper.getStartCreatedDate();												
		
		Integer numberOfDaysInTheFuture = Integer.valueOf(currentConfig.Queue_Next_N_Days_gne__c);
		Date nDaysInFuture = system.today().addDays(numberOfDaysInTheFuture);
		List<Task> tasks = [SELECT id
							FROM Task WHERE IsClosed = false AND CM_Case_Record_Type_Name_gne__c IN : recordTypeNames
							AND CM_Queue_Name_gne__c NOT IN : queueNames
							AND CreatedById NOT IN : excludedUsers
							AND Subject NOT IN : excludedSubjects
							AND ActivityDate <: nDaysInFuture
							AND ActivityDate > :startCreatedDate
							LIMIT 250];
		return tasks;
	}

    public static void verifyStatus(Map<String, List<Environment_Variables__c>> envVarMultiValues)
    {       
        String toAddress = currentConfig.Queue_Build_Failed_User_Email_Dist_List__c;
        String subject = 'Build Failure - GATCF Work Assignment Queue';
        String senderDisplayName = 'GNE_CM_Task_Queue_Mgmt_Status_Notify';
        Integer numberOfUnhandledExceptionTasks = 0;
        String unassignmentStatus = envVarMultiValues.get(GNE_CM_Task_Queue_Mgmt_Helper.QUEUE_UNASSIGN_STATUS)[0].Value__c;
        String buildStatus = envVarMultiValues.get(GNE_CM_Task_Queue_Mgmt_Helper.QUEUE_BUILD_STATUS)[0].Value__c;
        GNE_CM_Monitoring_Auditing_gne__c monitorBuild = new GNE_CM_Monitoring_Auditing_gne__c();
        System.debug('wilczekk unassignment status: ' + unassignmentStatus);
        if(unassignmentStatus.compareTo(GNE_CM_Task_Queue_Mgmt_Helper.ProcessingStatuses.Successful.name()) != 0)
        {           
            GNE_CM_Task_Queue_Mgmt_Helper.flagProcessing(envVarMultiValues, 
                                                        monitorBuild,
                                                        GNE_CM_Task_Queue_Mgmt_Helper.ProcessingStatuses.Failed, 
                                                        GNE_CM_Task_Queue_Mgmt_Helper.QueueBatchTypes.Unassign);            
            GNE_CM_Task_Queue_Mgmt_Helper.sendErrorNotification(null, 
                                                                toAddress, 
                                                                subject, 
                                                                senderDisplayName, 
                                                                'GNE_CM_Task_Queue_Mgmt_Status_Notify', 
                                                                null,
                                                                numberOfUnhandledExceptionTasks,
                                                                GNE_CM_Task_Queue_Mgmt_Helper.QueueBatchTypes.Unassign);
        }
        else if(buildStatus.compareTo(GNE_CM_Task_Queue_Mgmt_Helper.ProcessingStatuses.Successful.name()) != 0)
        {
            GNE_CM_Task_Queue_Mgmt_Helper.flagProcessing(envVarMultiValues, 
                                                        monitorBuild,
                                                        GNE_CM_Task_Queue_Mgmt_Helper.ProcessingStatuses.Failed, 
                                                        GNE_CM_Task_Queue_Mgmt_Helper.QueueBatchTypes.Build);           
            GNE_CM_Task_Queue_Mgmt_Helper.sendErrorNotification(null, 
                                                                toAddress, 
                                                                subject, 
                                                                senderDisplayName, 
                                                                'GNE_CM_Task_Queue_Mgmt_Status_Notify', 
                                                                null,
                                                                numberOfUnhandledExceptionTasks,
                                                                GNE_CM_Task_Queue_Mgmt_Helper.QueueBatchTypes.Build);
        }
    }  

	public class CaseGroupComparator implements GlobalUtils.ObjectComparator
	{
		public Integer compare(Object object1, Object object2)
		{
			if(object1==null || !(object1 instanceof CaseGroup)
	        	|| object2==null || !(object2 instanceof CaseGroup))
	        {
	            throw new GlobalUtils.IllegalArgumentException();
	        }
	        Date dueDate1 = ((CaseGroup) object1).dueDate;
	        Date dueDate2 = ((CaseGroup) object2).dueDate;
	        if(dueDate1 < dueDate2)
	        {
	            return -1;
	        } 
	        else if(dueDate1 == dueDate2)
	        {
	            return 0;
	        }
	        else
	        {
	            return 1;
	        }
		}
	}
	
	public class PrescriberGroupComparator implements GlobalUtils.ObjectComparator
	{
		public Integer compare(Object object1, Object object2)
		{
			if(object1==null || !(object1 instanceof PrescriberGroup)
	        	|| object2==null || !(object2 instanceof PrescriberGroup))
	        {
	            throw new GlobalUtils.IllegalArgumentException();
	        }
	        Date dueDate1 = ((PrescriberGroup) object1).dueDate;
	        Date dueDate2 = ((PrescriberGroup) object2).dueDate;
	        if(dueDate1 < dueDate2)
	        {
	            return -1;
	        } 
	        else if(dueDate1 == dueDate2)
	        {
	            return 0;
	        }
	        else
	        {
	            return 1;
	        }
		}
	}
	
	public class TaskUpdateResult
	{
		public Integer toProcessCounter {get; private set;}
		public Set<Id> failedTasks {get; private set;}
		
		public TaskUpdateResult(Integer counter, Set<Id> failedList)
		{
			toProcessCounter = counter;
			failedTasks = failedList;
		}
	}
	
	public class TaskForUpdate
	{
		public List<Task> task2Update {get; private set;}
		public Integer counter {get; private set;}
		public Set<Id> errorIds {get; private set;}
		
		public TaskForUpdate(List<Task> task2Update, Integer counter, Set<Id> errorIds)
		{
			this.task2Update = task2Update;
			this.counter = counter;
			this.errorIds = errorIds;
		}
	}
	
	public class TaskQueueBuildResult
	{
		public Integer workAssignmentCounter {get; private set;}
		public Integer taskCounter {get; private set;}
		public WorkAssignment previousWorkAssignment {get; private set;}
		public PrescriberGroup previousPresGroup {get; private set;}
		public Set<Id> failedTasks {get; private set;}
		public List<Task> tasksWithEmptyAddress {get; set;}
		public Integer updatedQueueCounter {get; set;}
		
		public TaskQueueBuildResult(Integer waCounter, Integer tCounter, Set<Id> failedList, WorkAssignment wa, PrescriberGroup pg)
		{
			workAssignmentCounter = waCounter;
			failedTasks = failedList;
			previousWorkAssignment = wa;
			previousPresGroup = pg;
			taskCounter = tCounter;
		}
	}
	
	public class WorkAssignment
	{		
		public List<Task> tasks {get; private set;}
		public Integer timeZone {get; private set;}
		public Date dueDate {get; private set;}
		public Boolean isCompleted {get; set;}
		public Boolean isSliced {get; set;}
		
		public WorkAssignment(PrescriberGroup pg)
		{
			tasks = new List<Task>();
			addAllTasks(pg);
			dueDate = pg.dueDate;
			timeZone = pg.timeZone;
			isCompleted = false;
			isSliced = false;
		}
		
		public void addAllTasks(PrescriberGroup pg)
		{			
			for(Task t : pg.tasks)
			{
				addTask(t);
			}			
		}
		
		public Integer tasksCount()
		{
			return tasks.size();
		}
		
		private void addTask(Task t)
		{
			tasks.add(t);
			if(t.activityDate < dueDate)
		{
				dueDate = t.activityDate;
			}
		}
	}
	
	public class PrescriberGroup
	{
		private Date dueDate;
		public List<Task> tasks {get; private set;}			
		public Integer timeZone {get; private set;}	
		public String key {get; set;}	
		public Boolean isFull {get; set;}
		public Boolean wasSplit {get; set;}
		
		public PrescriberGroup(Task t)
		{
			tasks = new List<Task>();
			tasks.add(t);
			key = t.CM_Case_AddressId_gne__c;
			dueDate = t.activityDate;
			timeZone = Integer.valueOf(t.CM_Queue_TimeZone_Number_gne__c);			
			isFull = false;
			wasSplit = false;
		}
		
		public PrescriberGroup(CaseGroup cg)
		{
			tasks = new List<Task>();
			addAllTasks(cg.tasks);	
			dueDate = cg.dueDate;		
			timeZone = cg.timeZone;
			isFull = false;
		}
		
		public void addAllTasks(List<Task> tasks)
		{
			for(Task t : tasks)
			{
				addTask(t);
			}
		}
		
		public void addTask(Task t)
		{
			tasks.add(t);
			if(t.activityDate < dueDate)
			{
				dueDate = t.activityDate;
			}			
		}
		
		public Integer tasksCount()
		{
			return tasks.size();
		}
	}
	
	//the class is public for GlobalUtils.qsort method testing
	public class CaseGroup
	{
		public Date dueDate {get; private set;}
		public List<Task> tasks {get; private set;}
		public Integer timeZone {get; private set;}
		public String key {get; private set;}
		
		public CaseGroup(Task t)
		{
			tasks = new List<Task>();
			tasks.add(t);
			timeZone = Integer.valueOf(t.CM_Queue_TimeZone_Number_gne__c);
			dueDate = t.activityDate;
			key = t.CM_Case_Number_gne__c;
		}
		
		public void addTask(Task t)
		{
			tasks.add(t);
			if(t.activityDate < dueDate)
			{
				dueDate = t.activityDate;
			}
		}
		
		public Integer tasksCount()
		{
			return tasks.size();
		}
	}
}