/** @date 18/10/2016
* @Author Gabriel Juriewicz
* @description Utils for AGS unit tests
*/
public class AGS_TestUtil {

	// CONSTANTS
	public static String AGS_CASEACTION_SACTION_DETERMINE_CASE_ACTION_LATENCY = 'Determine Case Action Latency';
	public static String AGS_CASEACTION_SACTION_ACTION_REQUIRED_REMINDER = 'Action Required - Reminder';
	public static String AGS_CASEACTION_SACTION_ACTION_REQUIRED_OVERDUE = 'Action Required - Overdue';
	public static String AGS_CASEACTION_SACTION_ACTION_REQUIRED_MANAGER_ESCALATED = 'Action Required - Manager Escalated';
	public static String AGS_CASEACTION_SACTION_PER_INSTANCE_CASE_CREATION = 'Create Per Instance Case Post Case Creation';
	public static String AGS_CASEACTION_SACTION_SYSTEM_REOPEN = 'System Reopen Per Instance Case Post Case Creation';
	public static String AGS_CASEACTION_SACTION_ANALYST_REOPEN = 'Analyst Reopen Case';
	public static String AGS_CASEACTION_SACTION_CREATE_AGGREGATION_CASE = 'Create Aggregation Case Post Case Creation';
	public static String AGS_CASEACTION_SACTION_ACKNOWLEDGE_STOP_SPENDING = 'Acknowledge Stop Spending Limit';
	public static String AGS_CASEACTION_SACTION_PER_INSTANCE_PROBLEM = 'Determine Per Instance Problem Severity';
	public static String AGS_CASEACTION_SACTION_CREATE_MANUAL_CASE = 'Create Manual Case';
	public static String AGS_CASEACTION_SACTION_PLEASE_VALIDATE_DATA = 'Please Validate Data';
	public static String AGS_CASEACTION_SACTION_PLEASE_VALIDATE_DATA_FOLLOWUP = 'Please Validate Data - Follow Up';
	public static String AGS_CASEACTION_SACTION_CONFIRM_COMPILANCE_UNDERSTANDING = 'Confirm Compliance Understanding';
	public static String AGS_CASEACTION_SACTION_ALERT = 'Alert';
	public static String AGS_CASEACTION_SACTION_CLOSE_CASE_NO_ISSUE =  'Close Case - No Issue';
	public static String AGS_CASEACTION_SACTION_CLOSE_CASE_ISSUE_RESOLVED = 'Close Case - Issue Resolved';
	public static String AGS_CASEACTION_SACTION_CLOSE_CASE_HCO_TO_RESOLVE = 'Close Case - HCO To Resolve';
	public static String AGS_CASEACTION_SACTION_CLOSE_CASE_NO_NOTIFICATION = 'Close Case - No Notification';
	public static String AGS_CASEACTION_SACTION_AGGREGATE_RECOMMENDED_LIMIT = 'Aggregate Recommended Spending Limit Reached';
	public static String AGS_CASEACTION_SACTION_ACKNOWLEDGE_AGGREGATE_LIMIT = 'Acknowledge Aggregate Spending Limit Reached';
	public static String AGS_CASEACTION_SACTION_ACKNOWLEDGE_AGGREGATE_LEGAL_LIMIT = 'Acknowledge Aggregate Legal Spending Limit Reached';
	public static String AGS_CASEACTION_SACTION_MANAGER_ESCALATED = 'Confirm Compliance Understanding - Manager Escalated';

	public static String AGS_CASEACTION_RT_VALIDATE_DATA = 'AGS Case Action-ValidateData-Edit-Rect';
	public static String AGS_CASEACTION_RT_VALIDATE_DATA_FOLLOWUP = 'AGS Case Action-ValidateDataFollowUp-Edit-Rect';
	public static String AGS_CASEACTION_RT_CONFIRM_COMPLIANCE = 'AGS Case Action-ConfirmCompliance-Edit-Rect';
	public static String AGS_CASEACTION_RT_SEND_CUSTOM_NOTIFICATION = 'AGS Case Action-SendCustomNotification-Edit-Rect';
	public static String AGS_CASEACTION_RT_CLOSE_CASE = 'AGS Case Action-CloseCase-Readonly-Rect';
	public static String AGS_CASEACTION_RT_SEND_NOTIFICATION_READONLY = 'AGS Case Action-SendCustomNotification-ReadOnly-Rect';
	public static String AGS_CASEACTION_RT_CLOSE_SEND_AGGREGATION_LIMIT = 'AGS Case Action-SendAggregationLimit-Edit-Rect';
	public static String AGS_CASEACTION_RT_CLOSE_ACKNOWLEDGE_STOP_SPENDING = 'AGS Case Action-AcknowledgeStopSpending-Edit-Rect';
	public static String AGS_CASEACTION_RT_ESCALATED_CONFIRM_COMPLIANCE = 'AGS Case Action-EscalatedConfirmCompliance-Edit-Rect';

	public static String AGS_CASEACTION_REASONTYPE_INSTANCE_RULE = 'Instance Rule';
	public static String AGS_CASEACTION_REASONTYPE_AGGREGATION_RULE = 'Aggregation Rule';
	public static String AGS_CASEACTION_REASONTYPE_MANUAL = 'Manual';

	public static String AGS_CASE_STATUS_OPEN_PENDING_MANUAL = 'Open - Pending Manual Analysis';
	public static String AGS_CASE_STATUS_CLOSED = 'Closed';
	public static String AGS_CASE_STATUS_OPEN = 'Open';

	public static String AGS_CASE_CLOSED_REASON_NOISSUE = 'No Issue';
	public static String AGS_CASE_CLOSED_REASON_ISSUERESOLVED = 'Issue Resolved';
	public static String AGS_CASE_CLOSED_REASON_HCO = 'HCO to Resolve';
	public static String AGS_CASE_CLOSED_REASON_NONOTIFICATION = 'No Notification';

	public static  String AGS_EXEXCLUSION_STATUS_NOT_CHECKED = 'Not Checked';
	public static  String AGS_EXEXCLUSION_STATUS_REQUEST_PENDING = 'Check pending';
	public static  String AGS_EXEXCLUSION_STATUS_IN_PROCESS = 'In Process';
	public static  String AGS_EXEXCLUSION_STATUS_EXCLUDED = 'Excluded';

	public static  String AGS_EXEXCLUSIONCHECK_STATUS_SANCTIONED = 'Sanctioned but legal approved';
	public static  String AGS_EXEXCLUSIONCHECK_STATUS_VERIFIED = 'Verified and clear';
	public static  String AGS_EXEXCLUSIONCHECK_STATUS_EXCLUDED = 'Excluded';

	public static String AGS_EXCLUSION_REQUEST_STATUS_COMPLETED = 'Completed';

	public static String ACCOUNT_EXCLUSION_STATUS_PENDING = 'Request Pending';
	public static String ACCOUNT_EXCLUSION_STATUS_NOTCHECKED = 'Not Checked';
	public static String ACCOUNT_EXCLUSION_STATUS_INPROCESS = 'In Process';

	// TEST VARIABLES
	public static Integer versionId = 1000000001;


	/** @date 28/11/2016
	* @Author Gabriel Juriewicz
	* @description Util Method - Create AGS Spend Recipient
	* @param String recipientName
	* @return AGS_CCO_Case_Recipient_gne__c
	*/
	public static AGS_CCO_Case_Recipient_gne__c createSpendRecipient(String recipientName) {
		AGS_CCO_Case_Recipient_gne__c  r = new AGS_CCO_Case_Recipient_gne__c(
		    Name                    =  recipientName,
		    First_Name_gne__c 		= 'FirstName',
		    Last_Name_gne__c 		= 'LastName',
		    Tax_Id_gne__c 			= '123456789',
		    Address_Line_1_gne__c 	= '312 6TH AVE',
		    Address_Line_2_gne__c 	= '312 6TH AVE',
		    City_gne__c 			= 'CHARLESTON',
		    State_gne__c 			= 'West Virginia',
		    Zip_gne__c 				= '11518'
		);
		insert r;
		return r;
	}

	/** @date 3/3/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create AGS Spend Recipient
	* @return AGS_CCO_Case_Recipient_gne__c
	*/
	public static AGS_CCO_Case_Recipient_gne__c createSpendRecipient() {
		AGS_CCO_Case_Recipient_gne__c  r = createSpendRecipient('12345');
		return r;
	}

	/** @date 7/20/2016
	* @Author Pawel Sprysak
	* @description Util Method - Create AGS Spend Expense Transaction
	* @param AGS_CCO_Case_Recipient_gne__c recipient
	* @return AGS_Spend_Expense_Transaction_gne__c
	*/
	public static AGS_Spend_Expense_Transaction_gne__c createSpendExpenseTrans(AGS_CCO_Case_Recipient_gne__c recipient) {
		return createSpendExpenseTrans(recipient, null);
	}

	/** @date 13/10/2016
	* @Author Gabriel Juriewicz
	* @description Util Method - Create AGS Spend Expense Transaction with spend User
	* @param AGS_CCO_Case_Recipient_gne__c recipient, String spendUser
	* @return AGS_Spend_Expense_Transaction_gne__c
	*/
	public static AGS_Spend_Expense_Transaction_gne__c createSpendExpenseTrans(AGS_CCO_Case_Recipient_gne__c recipient, Id spendUser) {
		AGS_Spend_Expense_Transaction_gne__c t = createSpendExpenseTrans(recipient, spendUser, 'transId');
		return t;
	}

	/** @date 15/11/2016
	* @Author Gabriel Juriewicz
	* @description Util Method - Create AGS Spend Expense Transaction with spend User
	* @param AGS_CCO_Case_Recipient_gne__c recipient, Id spendUser, String sourceTransactionId
	* @return AGS_Spend_Expense_Transaction_gne__c
	*/
	public static AGS_Spend_Expense_Transaction_gne__c createSpendExpenseTrans(AGS_CCO_Case_Recipient_gne__c recipient, Id spendUser, String sourceTransactionId) {
		AGS_Spend_Expense_Transaction_gne__c t = new AGS_Spend_Expense_Transaction_gne__c(
		    Allocated_Transaction_Amount_gne__c = 5,
		    Event_Date_gne__c 					= Date.today(),
		    Event_ID_gne__c 					= 'EventId',
		    Form_Of_Payment_gne__c 				= 'Cash or cash equivalent',
		    Home_Payment_ID_gne__c 				= 'HOMEID00001_NR',
		    LogicalDeleteFlag_gne__c			= false,
		    Nature_Of_Payment_gne__c 			= 'Consulting Fee',
		    Primary_Recipient_gne__c 			= recipient.Id,
		    Report_Code_gne__c 					= 'XC_MON',
		    SCh_Category_gne__c 				= 'Category',
		    Source_System_Code_gne__c			= 'SAPBW',
		    Source_Transaction_Amount_gne__c 	= 5.0,
		    Source_Transaction_ID_gne__c 		= sourceTransactionId,
		    Study_Name_gne__c 					= 'StudyName',
		    Research_Pymt_Typ_Cd_gne__c         = 'CLINICAL',
		    Spend_User_gne__c					= spendUser
		);
		insert t;
		return t;
	}

	/** @date 17/10/2016
		* @Author Gabriel Juriewicz
		* @description Util Method - create AGS Case
		* @return AGS_Case_gne__c
		*/
	public static AGS_Case_gne__c createAgsCase() {
		return createAgsCase(AGS_CASEACTION_REASONTYPE_INSTANCE_RULE);
	}

	/** @date 10/10/2016
	* @Author Gabriel Juriewicz
	* @description Util Method - create AGS Case
	* @param String reasonType
	* @return AGS_Case_gne__c
	*/
	public static AGS_Case_gne__c createAgsCase(String reasonType) {
		AGS_CCO_Case_Reason__c reason = createAgsCcoCaseReason(reasonType);
		User ccoAnalyst = createCcoAnalystUser();
		All_User_Hierarchy_gne__c inactiveResolver = createAllUserHierarchyGssp();
		AGS_Case_gne__c agsCase = new AGS_Case_gne__c(
		    Reason_gne__c 			= reason.Id,
		    Case_Status_gne__c 		= AGS_CASE_STATUS_OPEN_PENDING_MANUAL,
		    Analyst_gne__c 			= ccoAnalyst.Id,
		    OwnerId 				= ccoAnalyst.Id,
		    Inactive_resolver__c 	= inactiveResolver.Id,
		    Resolver_gne__c 		= UserInfo.getUserId()
		);
		insert agsCase;
		return agsCase;
	}

	/** @date 18/11/2016
	* @Author Gabriel Juriewicz
	* @description Util Method - create AGS Case
	* @param AGS_CCO_Case_Reason__c reason
	* @return AGS_Case_gne__c
	*/
	public static AGS_Case_gne__c createAgsCase(AGS_CCO_Case_Reason__c reason) {
		User ccoAnalyst = createCcoAnalystUser();
		All_User_Hierarchy_gne__c inactiveResolver = createAllUserHierarchyGssp();
		AGS_Case_gne__c agsCase = new AGS_Case_gne__c(
		    Reason_gne__c 			= reason.Id,
		    Case_Status_gne__c 		= AGS_CASE_STATUS_OPEN_PENDING_MANUAL,
		    Analyst_gne__c 			= ccoAnalyst.Id,
		    OwnerId 				= ccoAnalyst.Id,
		    Inactive_resolver__c 	= inactiveResolver.Id,
		    Resolver_gne__c 		= UserInfo.getUserId()
		);
		insert agsCase;
		return agsCase;
	}

	/** @date 01/12/2016
	* @Author Gabriel Juriewicz
	* @description Util Method - create AGS Case
	* @param AGS_CCO_Case_Reason__c reason, User u
	* @return AGS_Case_gne__c
	*/
	public static AGS_Case_gne__c createAgsCase(AGS_CCO_Case_Reason__c reason, User u, All_User_Hierarchy_gne__c auh, recordtype rt) {
		AGS_Case_gne__c agsCase = new AGS_Case_gne__c(
		    Reason_gne__c = reason.Id,
		    Case_Status_gne__c = AGS_CASE_STATUS_OPEN_PENDING_MANUAL,
		    Analyst_gne__c = u.Id,
		    OwnerId = u.Id,
		    Inactive_resolver__c = auh.Id,
		    Resolver_gne__c = UserInfo.getUserId()
		);
		if (rt != null) {
			agsCase.recordtypeId = rt.Id;
		}
		insert agsCase;
		return agsCase;
	}

	/** @date 15/11/2016
	* @Author Gabriel Juriewicz
	* @description Util Method - create AGS CCO Case Reason
	* @param String reasonType
	* @return AGS_CCO_Case_Reason__c
	*/
	public static AGS_CCO_Case_Reason__c createAgsCcoCaseReason(String reasonType) {
		AGS_CCO_Case_Reason__c reason = createAgsCcoCaseReason(reasonType, 'testCCOReason');
		return reason;
	}

	/** @date 10/10/2016
	* @Author Gabriel Juriewicz
	* @description Util Method - create AGS CCO Case Reason
	* @param String reasonType
	* @return AGS_CCO_Case_Reason__c
	*/
	public static AGS_CCO_Case_Reason__c createAgsCcoCaseReason(String reasonType, String reasonName) {
		AGS_CCO_Case_Reason__c reason = new AGS_CCO_Case_Reason__c(
		    AGS_Reason_Name__c 			= 'reasonName',
		    AGS_Reason_Description__c 	= 'reasonDescription',
		    Reason_Type__c 				= reasonType,
		    Name = reasonName
		);
		insert reason;
		return reason;
	}

	/** @date 10/10/2016
	* @Author Gabriel Juriewicz
	* @description Util Method - create User with 'GNE-AGS-CCO-Analyst' profile
	* @return User
	*/
	public static User createCcoAnalystUser() {
		return createCcoAnalystUser('AGGS', 'Case Monitor');
	}

	/** @date 27/12/2016
	* @Author Gabriel Juriewicz
	* @description Util Method - create User with 'GNE-AGS-CCO-Analyst' profile
	* @return User
	*/
	public static User createCcoAnalystUser(String FirstName, String LastName) {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'GNE-AGS-CCO-Analyst' LIMIT 1];
		User u = new User(
		    FirstName 			= FirstName,
		    Alias 				= 'gssptest',
		    Email 				= 'gssptestuser@gene.com',
		    EmailEncodingKey 	= 'UTF-8',
		    LastName 			= LastName,
		    LanguageLocaleKey 	= 'en_US',
		    LocaleSidKey 		= 'en_US',
		    ProfileId 			= p.Id,
		    TimeZoneSidKey 		= 'America/Los_Angeles',
		    Username 			= 'gssptestuser@gene.com.' + System.now().getTime(),
		    External_ID_gne__c  = 'gssptestuser'
		);
		insert u;
		return u;
	}

	/** @date 10/10/2016
	* @Author Gabriel Juriewicz
	* @description Util Method - create All User Hierarchy
	* @return All_User_Hierarchy_gne__c
	*/
	public static All_User_Hierarchy_gne__c createAllUserHierarchyGssp() {
		All_User_Hierarchy_gne__c inactiveResolver = new All_User_Hierarchy_gne__c(
		    User_External_Id_gne__c = 'gssptestuser',
		    FirstName_gne__c 		= 'AGGS',
		    LastName_gne__c 		= 'Case Monitor',
		    Active_gne__c 			= true,
		    email_id__c				= 'test@gene.com'
		);
		insert inactiveResolver;
		return inactiveResolver;
	}

	/** @date 14/11/2016
	* @Author Gabriel Juriewicz
	* @description Util Method - create All User Hierarchy
	* @return All_User_Hierarchy_gne__c
	*/
	public static All_User_Hierarchy_gne__c createAllUserHierarchyccoManager() {
		All_User_Hierarchy_gne__c inactiveResolver = new All_User_Hierarchy_gne__c(
		    User_External_Id_gne__c =  Utilities.ccoManager,
		    FirstName_gne__c 		= 'AGGS',
		    LastName_gne__c 		= 'Case Monitor',
		    Active_gne__c 			= true,
		    email_id__c				= 'test@gene.com'
		);
		insert inactiveResolver;
		return inactiveResolver;
	}

	/** @date 10/10/2016
	* @Author Gabriel Juriewicz
	* @description Util Method - create All User Hierarchy
	* @return All_User_Hierarchy_gne__c
	*/
	public static All_User_Hierarchy_gne__c createAllUserHierarchyDummy() {
		All_User_Hierarchy_gne__c dummy = new All_User_Hierarchy_gne__c(
		    User_External_Id_gne__c = Utilities.noSpendUser,
		    FirstName_gne__c = 'No Spend'
		);
		insert dummy;
		return dummy;
	}

	/** @date 18/11/2016
	* @Author Gabriel Juriewicz
	* @description Util Method - create AGGS Spend CCO Case
	* @param AGS_Case_gne__c agsCase, AGS_Spend_Expense_Transaction_gne__c spendTransaction
	* @return AGSSpendCCOCase_gne__c
	*/
	public static AGSSpendCCOCase_gne__c createAGSSpendCCOCase(AGS_Case_gne__c agsCase, AGS_Spend_Expense_Transaction_gne__c spendTransaction) {
		AGSSpendCCOCase_gne__c spendCase = new AGSSpendCCOCase_gne__c(
		    AGS_Case_gne__c = agsCase.Id,
		    AGS_Spend_Expense_Transaction_gne__c = spendTransaction.Id,
		    User_from_AllUserHeirarchy__c = agsCase.Inactive_resolver__c
		);
		insert spendCase;
		return spendCase;
	}

	/** @date 10/10/2016
	* @Author Gabriel Juriewicz
	* @description Util Method - create AGGS Spend CCO Case
	* @param AGS_Case_gne__c agsCase
	* @return AGSSpendCCOCase_gne__c
	*/
	public static AGSSpendCCOCase_gne__c createAGSSpendCCOCase(AGS_Case_gne__c agsCase) {
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = createSpendExpenseTrans(createSpendRecipient());
		AGSSpendCCOCase_gne__c spendCase =  createAGSSpendCCOCase(agsCase, agsTransaction);
		return spendCase;
	}

	/** @date 17/10/2016
	* @Author Gabriel Juriewicz
	* @description Util Method - create AGGS Case Action
	* @param AGS_Case_gne__c agsCase
	* @return AGS_Case_Action_gne__c
	*/
	public static AGS_Case_Action_gne__c createActionCase(AGS_Case_gne__c agsCase) {
		return createActionCase(agsCase, AGS_CASEACTION_SACTION_AGGREGATE_RECOMMENDED_LIMIT, AGS_CASEACTION_RT_CLOSE_CASE);
	}

	/** @date 14/10/2016
	* @Author Gabriel Juriewicz
	* @description Util Method - create AGGS Case Action
	* @param AGS_Case_gne__c agsCase
	* @param String sAction
	* @param String recordTypeName
	* @return AGS_Case_Action_gne__c
	*/
	public static AGS_Case_Action_gne__c createActionCase(AGS_Case_gne__c agsCase, String sAction, String recordTypeName) {
		RecordType rt = [select Id from RecordType where Name = : recordTypeName];
		AGS_Case_Action_gne__c newCaseAction = new AGS_Case_Action_gne__c();
		newCaseAction.ownerId = agsCase.OwnerId;
		newCaseAction.AGS_Case_gne__c = agsCase.Id;
		newCaseAction.Action_gne__c = sAction;
		newCaseAction.Action_Status_internal_gne__c = 'Open';
		newCaseAction.recordtypeid = rt.Id;
		insert newCaseAction;
		return newCaseAction;
	}

	/** @date 18/10/2016
	* @Author Gabriel Juriewicz
	* @description Util Method - create AGS Reporting Configuration Version
	* @return AGS_Reporting_Configuration_Version__c
	*/
	public static AGS_Reporting_Configuration_Version__c createReportingConfigurationVersion() {
		AGS_Reporting_Configuration_Version__c version =  createReportingConfigurationVersion (versionId);
		return version;
	}

	/** @date 25/10/2016
	* @Author Gabriel Juriewicz
	* @description Util Method - create AGS Reporting Configuration Version
	* @return AGS_Reporting_Configuration_Version__c
	*/
	public static AGS_Reporting_Configuration_Version__c createReportingConfigurationVersion(Integer vId) {
		AGS_Reporting_Configuration_Version__c version = new AGS_Reporting_Configuration_Version__c(
		    Version_ID_gne__c = vId,
		    VERSION_MINOR_NUM_gne__c = '1'
		);
		insert version;
		return version;
	}

	/** @date 18/10/2016
	* @Author Gabriel Juriewicz
	* @description Util Method - create AGS Env Distribution Lists
	* @return AGS_Env_Distribution_Lists_gne__c
	*/
	public static AGS_Env_Distribution_Lists_gne__c createEnvDistributionLists() {
		String Enviromental = GlobalUtils.getEnvironment();
		//if(Enviromental.length() > 10){
		//	Enviromental = Enviromental.substring(0,10);
		//}
		AGS_Env_Distribution_Lists_gne__c EnvDistribution = new AGS_Env_Distribution_Lists_gne__c(
		    Name = 'testName', Email_gne__c = 'testEmailThat@DoesntExistIRL.it',
		    Environment_gne_del__c = Enviromental
		);

		System.debug('Enviromental NUMBER = ' + Enviromental);
		insert EnvDistribution;
		return EnvDistribution;
	}

	/** @date 24/10/2016
	* @Author Gabriel Juriewicz
	* @description Util Method - create AGS Spend Correction
	* @return AGS_Spend_Correction_gne__c
	*/
	public static AGS_Spend_Correction_gne__c createSpendCorrection(AGS_Spend_Expense_Transaction_gne__c agsTransaction) {
		AGS_Spend_Correction_gne__c correction = new AGS_Spend_Correction_gne__c(
		    AGS_Spend_Expense_Transaction_gne__c        = agsTransaction.Id,
		    Corrected_Source_Transaction_Amount_gne__c  = agsTransaction.Source_Transaction_Amount_gne__c,
		    Corrected_SAP_T_E_Interaction_Name_gne__c   = agsTransaction.Event_ID_gne__c,
		    Corrected_Spend_Transaction_Date_gne__c     = agsTransaction.Event_Date_gne__c,
		    Source_Transaction_ID_gne__c                = 'CO_' + agsTransaction.Source_Transaction_ID_gne__c);
		insert correction;
		return correction;
	}

	/** @date 24/10/2016
	* @Author Gabriel Juriewicz
	* @description Util Method - create AGS Brand Classification
	* @return AGS_Brand_Classification__c
	*/
	public static AGS_Brand_Classification__c createBrandClassification() {
		AGS_Brand_Classification__c brandClassification = new AGS_Brand_Classification__c(
		    Brand_Category_Name_gne__c = 'Product Specific: Prescription',
		    Brand_Name_gne__c = 'Xolair',
		    Brand_Name_Config_Spec_Braces_gne__c = 'Xolair [Omalizumab]',
		    END_DATE_gne__c = Datetime.now().addDays(3),
		    Formulary_Inclusion_End_Date_gne__c = Datetime.now().addDays(12),
		    Formulary_Inclusion_Start_Date_gne__c = Datetime.now(),
		    Generic_Indicator_gne__c = false,
		    Generic_Name_gne__c = 'Omalizumab',
		    Is_Reportable_gne__c = true,
		    Report_Code_gne__c = 'ME_SUP',
		    Source_System_Date_gne__c = null,
		    START_DATE_gne__c = Datetime.now(),
		    State_Code_gne__c = 'ME',
		    Version_ID_gne__c = versionId);
		insert brandClassification;
		return brandClassification;
	}

	/** @date 25/10/2016
	* @Author Gabriel Juriewicz
	* @description Util Method - create AGS Allocation
	* @return AGS_Allocation_gne__c
	*/
	public static AGS_Allocation_gne__c createAllocation() {
		AGS_Allocation_gne__c allocation = new AGS_Allocation_gne__c(
		    Allocation_Method_Description_gne__c = 'Per Person Allocation Methodology',
		    Version_ID_gne__c = versionId);
		insert allocation;
		return allocation;
	}

	/** @date 25/10/2016
	* @Author Gabriel Juriewicz
	* @description Util Method - create AGS Contact Business Unit
	* @return AGS_Contact_Business_Unit_gne__c
	*/
	public static AGS_Contact_Business_Unit_gne__c createContactBusinessUnit() {
		AGS_Contact_Business_Unit_gne__c unit = new AGS_Contact_Business_Unit_gne__c(
		    Source_System_Date_gne__c = null,
		    Version_ID_gne__c = versionId);
		insert unit;
		return unit;
	}

	/** @date 25/10/2016
	* @Author Gabriel Juriewicz
	* @description Util Method - create AGS Descrete Threshold
	* @return AGS_Descrete_Threshold__c
	*/
	public static AGS_Descrete_Threshold__c createDescreteThreshold() {
		AGS_Descrete_Threshold__c threshold = new AGS_Descrete_Threshold__c(
		    LIMIT_AMOUNT_gne__c = 2,
		    Version_ID_gne__c = versionId);
		insert threshold;
		return threshold;
	}

	/** @date 25/10/2016
	* @Author Gabriel Juriewicz
	* @description Util Method - create AGS Threshold
	* @return AGS_Threshold_gne__c
	*/
	public static AGS_Threshold_gne__c createThreshold() {
		AGS_Threshold_gne__c threshold = new AGS_Threshold_gne__c(
		    Threshold_Type_Name_gne__c = 'testTypeName',
		    Version_ID_gne__c = versionId);
		insert threshold;
		return threshold;
	}

	/** @date 25/10/2016
	* @Author Gabriel Juriewicz
	* @description Util Method - create AGS Threshold Band
	* @return AGS_Threshold_Band_gne__c
	*/
	public static AGS_Threshold_Band_gne__c createThresholdBand() {
		AGS_Threshold_Band_gne__c thresholdBand = new AGS_Threshold_Band_gne__c(
		    Threshold_Type_Name_gne__c = 'testTypeName',
		    Version_ID_gne__c = versionId);
		insert thresholdBand;
		return thresholdBand;
	}

	/** @date 26/10/2016
	* @Author Gabriel Juriewicz
	* @description Util Method - create AGS Relabel Brand Classification
	* @return AGS_Relabel_Brand_Classification_gne__c
	*/
	public static AGS_Relabel_Brand_Classification_gne__c createRelabelBrandClassification() {
		AGS_Relabel_Brand_Classification_gne__c relabel = new AGS_Relabel_Brand_Classification_gne__c(
		    Is_Reportable_gne__c = false,
		    Version_ID_gne__c = versionId);
		insert relabel;
		return relabel;
	}

	/** @date 26/10/2016
	* @Author Gabriel Juriewicz
	* @description Util Method - create AGS Recipient Classification
	* @return AGS_Recipient_Classification_gne__c
	*/
	public static AGS_Recipient_Classification_gne__c createRecipientClassification() {
		AGS_Recipient_Classification_gne__c rClassification = new AGS_Recipient_Classification_gne__c(
		    Relabel1_For_Credential_gne__c = 'STUDENT OF OSTEOPATHIC MEDICINE',
		    Version_ID_gne__c = versionId);
		insert rClassification;
		return rClassification;
	}

	/** @date 27/10/2016
	* @Author Gabriel Juriewicz
	* @description Util Method - create AGS Inclusion
	* @return AGS_Inclusion_gne__c
	*/
	public static AGS_Inclusion_gne__c createInclusion() {
		AGS_Inclusion_gne__c inclusion = new AGS_Inclusion_gne__c(
		    P_AND_T_CMTE_IND_gne__c = 'Y',
		    Version_ID_gne__c = versionId);
		insert inclusion;
		return inclusion;
	}

	/** @date 27/10/2016
	* @Author Gabriel Juriewicz
	* @description Util Method - create AGS EX Exclusion Check
	* @return AGS_EX_Exclusion_Check_gne__c
	*/
	public static AGS_EX_Exclusion_Check_gne__c createExExclusionCheck(AGS_EX_Exclusion_Request_gne__c req, String exStatus) {
		AGS_EX_Exclusion_Check_gne__c exclusionCheck = new AGS_EX_Exclusion_Check_gne__c(
		    AGS_EX_Exclusion_Request_gne__c = req.Id,
		    AGS_EX_Status_gne__c = exStatus,
		    AGS_EX_Check_Date_gne__c = Date.Today());
		insert exclusionCheck;
		return exclusionCheck;
	}

	/** @date 27/10/2016
	* @Author Gabriel Juriewicz
	* @description Util Method - create AGS EX Exclusion Request
	* @return AGS_EX_Exclusion_Request_gne__c
	*/
	public static AGS_EX_Exclusion_Request_gne__c createExExclusionRequest(Account acc) {
		AGS_EX_Exclusion_Request_gne__c request = new AGS_EX_Exclusion_Request_gne__c(
		    AGS_EX_Account_Name_gne__c = acc.Id,
		    AGS_EX_Account_Primary_Address_gne__c = 'test address');
		insert request;
		return request;
	}

	/** @date 02/11/2016
	* @Author Gabriel Juriewicz
	* @description Util Method - create Affiliation
	* @return Affiliation_vod__c
	*/
	public static Affiliation_vod__c createAffiliation(Account fromAccount, Account toAccount) {
		Affiliation_vod__c affiliation = new Affiliation_vod__c(
		    From_account_vod__c = fromAccount.Id,
		    To_Account_vod__c = toAccount.Id,
		    Role_vod__c = 'Affiliated with',
		    Web_Order_Enabled_gne__c = true);

		insert affiliation;
		return affiliation;
	}

	/** @date 02/11/2016
	* @Author Gabriel Juriewicz
	* @description Util Method - create AGS EX Exclusion Requestor
	* @return AGS_EX_Exclusion_Requestor_gne__c
	*/
	public static AGS_EX_Exclusion_Requestor_gne__c createAGSExclusionRequestor(AGS_EX_Exclusion_Request_gne__c request) {
		AGS_EX_Exclusion_Requestor_gne__c requestor = new AGS_EX_Exclusion_Requestor_gne__c(
		    AGS_EX_Exclusion_Request_gne__c = request.Id,
		    AGS_EX_Requestor_Name_gne__c = UserInfo.getUserId());

		insert requestor;
		return requestor;
	}

	/** @date 09/11/2016
	* @Author Gabriel Juriewicz
	* @description Util Method - create AGS Case Staging Table
	* @return AGSCaseStagingTable_gne__c
	*/
	public static AGSCaseStagingTable_gne__c createAGSCaseStagingTable(String typeFlag, String txn_Id, String mdmId, String ruleId, Decimal txnAmount) {
		AGSCaseStagingTable_gne__c stagingTable = new AGSCaseStagingTable_gne__c(
		    AGS_TxnAmountCheck_Status_gne__c = 'None',
		    AGS_ProvisionalCaseCreateStatus_gne__c = 'Unprocessed',
		    AGS_Type_Flag_gne__c = typeFlag,
		    AGS_SRC_Txn_ID_gne__c = txn_Id,
		    AGS_MDM_ID_gne__c = mdmId,
		    AGS_RuleID_gne__c = ruleId,
		    AGS_Txn_Amount_gne__c = txnAmount,
		    AGS_Brand_gne__c = 'testBrand'
		);

		insert stagingTable;
		return stagingTable;
	}

	/** @date 09/11/2016
	* @Author Gabriel Juriewicz
	* @description Util Method - create AGS Provisional Case
	* @return AGS_Provisional_Case_gne__c
	*/
	public static AGS_Provisional_Case_gne__c createAGSProvisionalCase(String typeFlag, String sourceTransactionId, String mdmId, String ruleId) {
		AGS_Provisional_Case_gne__c provisionalCase = new AGS_Provisional_Case_gne__c();
		provisionalCase.AGS_PC_Type_Flag_gne__c = typeFlag;
		provisionalCase.AGS_PC_MDM_ID_gne__c = mdmId;
		provisionalCase.AGS_PC_Rule_ID_gne__c = ruleId;
		if (typeFlag == 'INS') {
			provisionalCase.AGS_PC_Src_Txn_ID_gne__c = sourceTransactionId;
		}

		insert provisionalCase;
		return provisionalCase;
	}

	/** @date 09/11/2016
	* @Author Gabriel Juriewicz
	* @description Util Method - create AGS_User_Activation_Finish
	* @return AGS_User_Activation_Finish_gne__c
	*/
	public static AGS_User_Activation_Finish_gne__c createAGSUserActivationFinish() {
		AGS_User_Activation_Finish_gne__c activationFinish = createAGSUserActivationFinish('Process');
		return activationFinish;
	}

	/** @date 30/11/2016
	* @Author Gabriel Juriewicz
	* @description Util Method - create AGS_User_Activation_Finish
	* @return AGS_User_Activation_Finish_gne__c
	*/
	public static AGS_User_Activation_Finish_gne__c createAGSUserActivationFinish(String status) {
		AGS_User_Activation_Finish_gne__c activationFinish = new AGS_User_Activation_Finish_gne__c(
		    Name = 'test finish',
		    Status_gne__c = status);

		insert activationFinish;
		return activationFinish;
	}

	/** @date 27/12/2016
	* @Author Gabriel Juriewicz
	* @description Util Method - create Ags_Email_Links__c
	* @return Ags_Email_Links__c
	*/
	public static Ags_Email_Links__c createAgsEmailLinks(String recordName) {
		Ags_Email_Links__c emailLinks = new Ags_Email_Links__c(
		    name = recordName,
		    ags_Training_Link__c = 'www.testTrainingLink.com',
		    AGS_commportal_link__c = 'www.testCommportalLink.com');
		insert emailLinks;
		return emailLinks;
	}
}