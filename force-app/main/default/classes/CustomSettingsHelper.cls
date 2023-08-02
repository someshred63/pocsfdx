/************************************************************
*  @author: Krzysztof Wilczek, Roche
*  Date: 2010-01-11
*  Description: 
*  
*  Modification History
*  Date        Name        Description
*  2013-07-15  James Hou   PFS-704: Update Queue MGMT to using batch jobs chaining (v26) - obsoletes some custom settings
*                
*************************************************************/
public class CustomSettingsHelper 
{
	public static final String PRES_LKP_ACCOUNTCASEID = 'Pres_Lkp_AccountCaseID';
	public static final String PRES_LKP_ADDRESSCASEID = 'Pres_Lkp_AddressCaseID';
	public static final String PRES_LKP_CITYCASEID = 'Pres_Lkp_CityCaseID';
	public static final String PRES_LKP_FACILITYCASEID = 'Pres_Lkp_FacilityCaseID';
	public static final String PRES_LKP_MAILBOXCASEID = 'Pres_Lkp_MailboxCaseID';
	public static final String PRES_LKP_PRACTICECASEID = 'Pres_Lkp_PracticeCaseID';
	public static final String PRES_LKP_STATECASEID = 'Pres_Lkp_StateCaseID';
	public static final String PRES_LKP_ZIPCASEID = 'Pres_Lkp_ZipCaseID';
	
	public static final String BATCH_FAX_EMAIL_RECIPIENT = 'Email_Recipient';
	public static final String CM_TERRITORY_ALIGNMENT_RUN = 'CurrentRun';
	public static final String CM_TASK_QUEUE_CONFIG = 'Queue_Configuration';			
	public static final String CM_RS_TASK_QUEUE_CONFIG = 'RS_Queue_Configuration';			
	/**
		The SINGLETON handle to the instance
	*/
	private static CustomSettingsHelper self;
	private static CustomSettingsHelper batchFaxSelf;
	private static CustomSettingsHelper CMAlignmentSelf;
	private static CustomSettingsHelper taskQueueSelf;
		
	public static CustomSettingsHelper self() 
	{
		if (self != null) return self;
		
		// To create org wide defaults in new org automatically. This
		// will prevent NPE's in future.
		
		createCustomSettings(new String[]{PRES_LKP_ACCOUNTCASEID, PRES_LKP_ADDRESSCASEID, 
		PRES_LKP_CITYCASEID, PRES_LKP_FACILITYCASEID, PRES_LKP_MAILBOXCASEID, PRES_LKP_PRACTICECASEID, 
		PRES_LKP_STATECASEID, PRES_LKP_ZIPCASEID});
		
		self = new CustomSettingsHelper();
		return self;
	}
	
	public static CustomSettingsHelper batchFaxSelf() 
	{
		if (batchFaxSelf != null) return batchFaxSelf;
		
		// To create org wide defaults in new org automatically. This
		// will prevent NPE's in future.
		
		createCustomSettingsBatchFax(new String[]{BATCH_FAX_EMAIL_RECIPIENT});
		
		batchFaxSelf = new CustomSettingsHelper();
		return batchFaxSelf;
	}
	
	public static CustomSettingsHelper CMAlignmentSelf() 
	{
		if (CMAlignmentSelf != null) return CMAlignmentSelf;
		
		// To create org wide defaults in new org automatically. This
		// will prevent NPE's in future.
		
		createCustomSettingsCMAlignment(new String[]{CM_TERRITORY_ALIGNMENT_RUN});
		
		CMAlignmentSelf = new CustomSettingsHelper();
		return CMAlignmentSelf;
	}
	
	public static CustomSettingsHelper taskQueueSelf()
	{
		if(taskQueueSelf != null)
			return taskQueueSelf;
			
		createCustomSettingsQueueBuilding(new String[]{CM_TASK_QUEUE_CONFIG, CM_RS_TASK_QUEUE_CONFIG});
		
		taskQueueSelf = new CustomSettingsHelper();
		return taskQueueSelf;
	}
	
	
	private static void createCustomSettings(List<String> names)
	{
		List<GNE_CM_Pres_Lkp_ID__c> settings = new List<GNE_CM_Pres_Lkp_ID__c>();
		for (String name : names)
		{
			if (GNE_CM_Pres_Lkp_ID__c.getInstance(name) == null) 
			{
				settings.add(new GNE_CM_Pres_Lkp_ID__c (Name = name, 
				SetupOwnerId = Userinfo.getOrganizationId()));         
			}
		}
		
		upsert settings Name; 
		return;
	}
	
	private static void createCustomSettingsBatchFax(List<String> names)
	{
		List<GNE_CM_Batch_Fax_Err_Mail_Rcp__c> settings = new List<GNE_CM_Batch_Fax_Err_Mail_Rcp__c>();
		for (String name : names)
		{
			if (GNE_CM_Batch_Fax_Err_Mail_Rcp__c.getInstance(name) == null) 
			{
				settings.add(new GNE_CM_Batch_Fax_Err_Mail_Rcp__c (Name = name, 
				SetupOwnerId = Userinfo.getOrganizationId()));         
			}
		}
		
		upsert settings Name; 
		return;
	}
	
	private static void createCustomSettingsCMAlignment(List<String> names)
	{
		List<GNE_CM_FRM_Alignment_Switch_gne__c> settings = new List<GNE_CM_FRM_Alignment_Switch_gne__c>();
		for (String name : names)
		{
			if (GNE_CM_FRM_Alignment_Switch_gne__c.getInstance(name) == null) 
			{
				settings.add(new GNE_CM_FRM_Alignment_Switch_gne__c (Name = name, 
				SetupOwnerId = Userinfo.getOrganizationId()));         
			}
		}
		
		upsert settings Name; 
		return;
	}
	
	private static void createCustomSettingsQueueBuilding(List<String> names)
	{
		List<GNE_CM_Task_Queue_Config__c> settings = new List<GNE_CM_Task_Queue_Config__c>();
		for (String name : names)
		{
			if (GNE_CM_Task_Queue_Config__c.getInstance(name) == null) 
			{
				settings.add(new GNE_CM_Task_Queue_Config__c (Name = name, 
				SetupOwnerId = Userinfo.getOrganizationId(),
				Queue_Generic_Owner_gne__c = (name==CM_TASK_QUEUE_CONFIG ? 'Genentech Access to Care Foundation' : 'Reimbursement Specialist Team'),
				Max_Number_Activities_Asgmt_Group_gne__c = 20,
				Queue_Build_Failed_User_Email_Dist_List__c = 'sfdc-cm-queue-mgmt-issues-sandbox-d@gene.com',
				Queue_Build_Fail_Tolerance_gne__c = 10,
				Queue_Build_Summary_Email_Dist_List__c = 'sfdc-cm-queue-mgmt-summary-sandbox-d@gene.com',
				Queue_Down_End_Time_gne__c = '5',
				Queue_Down_Start_Time_gne__c = '23',
				Queue_Next_N_Days_gne__c = 4,
				Queue_Size_gne__c = 15000,
				Queue_Unassign_Fail_Tolerance_gne__c = 10,
				Request_Assignment_Minimum_Activities__c = 5, 
				Request_Assignment_Num_Today_Queue_gne__c = 5,
				Request_Assignment_Num_Urgent_Queue_gne__c = 2, 
				Target_Number_Activities_Asgmt_Group_gne__c = 15,
				Queue_Default_Time_Zone_Number_gne__c = 1,
				Transfer_Workload_Confirmation_Email_gne__c = 'sfdc-cm-transfer-workload-summary-sandbox-d@gene.com',
				Transfer_Workload_Confirm_Email_Prod_gne__c = 'sfdc-cm-transfer-workload-summary-d@gene.com',
				/* JH 2013-07-16 Obsolete per PFS 704
				Scheduled_Run_Hour_Queue_Notification__c = 4,
				Scheduled_Run_Hour_Task_Queue_Build__c = '1, 2, 3',
				Scheduled_Run_Hour_Task_Restamping__c = '23',
				Scheduled_Run_Hour_Task_Unassign__c = '0, 1, 2',
				*/
				GNE_CM_Monitoring_User_Name__c = 'Monitoring User',
				Queue_Restamping_Batch_Size__c = 50,
				Queue_Unassign_Batch_Size__c = 20,
				Queue_Build_Batch_Size__c = 100
				));         
			}
		}
		
		upsert settings Name; 
		return;
	}
	
	// Nobody needs to construct it, a single reference will suffice.
	private CustomSettingsHelper() 
	{	  
	}
	
	// This method can be used to access the custom settings
	public Map<String, GNE_CM_Pres_Lkp_ID__c> getPresLkpIds() 
	{	
		return GNE_CM_Pres_Lkp_ID__c.getall();
	}	
	
	public Map<String, GNE_CM_Batch_Fax_Err_Mail_Rcp__c> getEmailRecipient() 
	{	
		return GNE_CM_Batch_Fax_Err_Mail_Rcp__c.getall();
	}
	
	public Map<String, GNE_CM_FRM_Alignment_Switch_gne__c> getCurrentRun() 
	{	
		return GNE_CM_FRM_Alignment_Switch_gne__c.getall();
	}
	
	public Map<String, GNE_CM_Task_Queue_Config__c> getQueueConfig() 
	{	
		return GNE_CM_Task_Queue_Config__c.getall();
	}
	
	public List<GNE_CM_CAB_Grid_Decisions__c> getCABGridDecisions()
	{
		return GNE_CM_CAB_Grid_Decisions__c.getAll().values();
	}
	
	public List<GNE_CM_Product_Franchise__c> getProductFranchises()
	{
		return GNE_CM_Product_Franchise__c.getAll().values();
	} 
	
	
/*	public List<GNE_CM_Case_Record_Types__c> getCaseRecordTypes()
	{
		return GNE_CM_Case_Record_Types__c.getAll().values();
	}	
	
	public String getCaseRecordType(String recordTypeKey)
	{
		return GNE_CM_Case_Record_Types__c.getInstance(recordTypeKey).Record_Type_Name__c;
	}
*/
}