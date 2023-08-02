/**
* @author: GFRS Dev Team
* @date: 18/06/2013
* @description: gFRS_UnitTestIMEDHelper class - helper class used to create IMED requests with all its children. We will use methods from controllers to 
* fully reproduce the process of request creation.
*
*/
public with sharing class gFRS_UnitTestIMEDHelper extends gFRS_UnitTestHelper{
	
	private static id FR_RECORD_TYPE_IMED = [select id from RecordType where SobjectType = 'GFRS_Funding_Request__c' and DeveloperName='IMED'].id;
	
	/**
	* @author: GFRS Dev Team
	* @date: 19/06/2013
	* @description: Creates IMED funding request for unit tests purposes.
	*/
	public static GFRS_Funding_Request__c createIMEDFundingRequestDecisionStep(Id organizationId, Id localizationId) {
		GFRS_Funding_Request__c resultRequest = new GFRS_Funding_Request__c(
			RecordTypeId = FR_RECORD_TYPE_IMED,
			Organization__c = organizationId,
			Location__c = localizationId,
			Status__c = gFRS_UnitTestHelper.REQUEST_STATUS_INTAKE,
			Sub_Status__c = gFRS_UnitTestHelper.REQUEST_STATUS_NOT_SUBMITTED,
			External_Sub_status__c = gFRS_UnitTestHelper.REQUEST_STATUS_NOT_SUBMITTED
		);
		
		
		
		insert resultRequest;
    	
    	gFRS_UnitTestHelper.createFundingAllocation(resultRequest);
    	
    	return resultRequest;
		
	}

	
	/**
	* @author: GFRS Dev Team
	* @date: 19/06/2013
	* @description: Creates IMED funding request for unit tests purposes. Creates funding request as it would ba after Application Step on UI.
	*/
	public static GFRS_Funding_Request__c createIMEDFundingRequestApplicationStep(Id organizationId, Id localizationId) {
		
		GFRS_Funding_Request__c resultRequest = createIMEDFundingRequestDecisionStep(organizationId, localizationId);
		
		resultRequest.Business_Unit_2__c = gFRS_UnitTestHelper.REQUEST_BUSINESS_UNIT_IMPACT;
		resultRequest.Requested_Amount__c = 10000;
		resultRequest.Therapeutic_Area_Parent__c = gFRS_UnitTestHelper.REQUEST_THERAPEUTIC_AREA_PARENT_CARDIOLOGY; 	//therapeutic area
		resultRequest.Therapeutic_Area__c = gFRS_UnitTestHelper.REQUEST_THERAPEUTIC_AREA_CARDIOLOGY;					//disease state
		resultRequest.Educational_Objectives_1__c = gFRS_UnitTestHelper.TEST_TEXT;
		resultRequest.External_Tracking_Code_optional__c = gFRS_UnitTestHelper.REQUEST_TEST_EXTERNAL_TRACING_CODE;
		resultRequest.Event_Project_type__c = gFRS_UnitTestHelper.REQUEST_EVENT_PROGRAM_TYPE;
		resultRequest.Support_Purpose_Program_Description__c = gFRS_UnitTestHelper.TEST_TEXT;
		resultRequest.Intended_Audience__c = gFRS_UnitTestHelper.TEST_TEXT;
		resultRequest.Needs_Assessment__c = gFRS_UnitTestHelper.TEST_TEXT;
		resultRequest.If_Yes_Please_Describe_Opt_In_Process__c = gFRS_UnitTestHelper.TEST_TEXT;
		resultRequest.If_known_List_Other_Supporters__c = gFRS_UnitTestHelper.TEST_TEXT;
		resultRequest.Opt_In_Process_for_Enduring_Materials__c = gFRS_UnitTestHelper.ANSWER_POSITIVE;
		resultRequest.Roche_Observer__c = gFRS_UnitTestHelper.ANSWER_POSITIVE;
		resultRequest.Secondary_Invitations_BRC_s_Help_Request__c = gFRS_UnitTestHelper.ANSWER_POSITIVE;
		resultRequest.Exhibits_or_Displays_Allowed__c = gFRS_UnitTestHelper.ANSWER_POSITIVE;
		resultRequest.Clinical_Practice_Guideline_Development__c = gFRS_UnitTestHelper.ANSWER_POSITIVE;
		resultRequest.Is_Your_Organization_HCP_Accredited__c = gFRS_UnitTestHelper.ANSWER_POSITIVE;
		resultRequest.Is_this_program_accredited__c = gFRS_UnitTestHelper.ANSWER_NEGATIVE;
		resultRequest.Other_Commercial_Supporters__c = gFRS_UnitTestHelper.ANSWER_NEGATIVE;
		resultRequest.Competencies_to_be_Achieved__c = gFRS_UnitTestHelper.REQUEST_TEST_COMPETENCIES_TO_BE_ACHIVED;
		resultRequest.Outcomes_Levels__c = gFRS_UnitTestHelper.REQUEST_TEST_OUTCOME_LEVELS;
		resultRequest.Request_for_Additional_Funding__c = gFRS_UnitTestHelper.ANSWER_NEGATIVE;
		resultRequest.Resubmission__c = gFRS_UnitTestHelper.ANSWER_NEGATIVE;
		resultRequest.Additional_Funding_Name__c = gFRS_UnitTestHelper.TEST_TEXT;
		resultRequest.Resubmission_Request_Name__c = gFRS_UnitTestHelper.TEST_TEXT;			
		
		update resultRequest;
    
    	return resultRequest;
		
	}
	
	/**
	* @author: GFRS Dev Team
	* @date: 19/06/2013
	* @description: Creates IMED funding request for unit tests purposes. Creates funding request as it would ba after Program Step on UI.
	*/
	public static GFRS_Funding_Request__c createIMEDFundingRequestProgramStep(Id organizationId, Id localizationId, Date programStartDate, Date programStopDate,Integer ExpectedAttendeesThatAreHCPs,Integer ExpectedAttendeesUSBasedHCPs) {
		
		GFRS_Funding_Request__c resultRequest = createIMEDFundingRequestApplicationStep(organizationId, localizationId);
		
		List<GFRS_Program_Audience_Group__c> audienceGroupList = new List<GFRS_Program_Audience_Group__c>(); 
		
		List<GFRS_Program__c> programList=gFRS_DAO.getProgramListByRequestId(resultRequest.id);
 		for(GFRS_Program__c program : programList){ 
 			program.Start_Date__c = programStartDate; 
			program.End_Date__c = programStopDate; 
			program.Program_Subtype__c = gFRS_UnitTestHelper.PROGRAM_SUBTYPE_LIVE_GRAND_ROUNDS;
			program.Expected_of_attendees_that_are_HCPs__c = ExpectedAttendeesThatAreHCPs;
			program.Expected_of_Attendees_US_Based_HCPs__c = ExpectedAttendeesUSBasedHCPs;
			program.Venue_Name__c = gFRS_UnitTestHelper.TEST_TEXT;
			program.Venue_City__c = gFRS_UnitTestHelper.TEST_TEXT;
			program.Venue_Province_Region__c = gFRS_UnitTestHelper.TEST_TEXT;		
			program.Venue_Zip_Code__c = gFRS_UnitTestHelper.TEST_TEXT;
			program.Venue_Country__c = gFRS_UnitTestHelper.TEST_TEXT;
			program.Speakers_Faculty__c = 5;
			program.Number_of_Activities__c = 5;		
 		}
 		
 		if(programList.size()>0){
 			update programList;
 			
 			insertAudienceGroup(programList.get(0).Id);
 		}
    
    	
		
    	update resultRequest;
    	return resultRequest;	
	}
	
	@future
	private static void insertAudienceGroup(Id programId){
		GFRS_Program_Audience_Group__c audienceGruop = new GFRS_Program_Audience_Group__c(
			Intended_Audience__c = 'Allied Health Professional',
			Specialty__c = 'Allergy & Immunology',
			Category_of_Credit__c = 'AAFP',
			Credit_Hours__c = 5,
			Number_of_Participants__c = 5,
			Expected_Learners__c = 5,
			Expected_Learners_Credit__c = 5,
			Program__c = programId
		);
		insert audienceGruop;	
	}
	
	
	
	/**
	* @author: GFRS Dev Team
	* @date: 19/06/2013
	* @description: Creates IMED funding request for unit tests purposes. Creates funding request as it would ba after Budget Step on UI.
	*/
	public static GFRS_Funding_Request__c createIMEDFundingRequestBudgetStep(Id organizationId, Id localizationId, Date programStartDate, Date programStopDate,Integer ExpectedAttendeesThatAreHCPs,Integer ExpectedAttendeesUSBasedHCPs) {
		
		GFRS_Funding_Request__c resultRequest = createIMEDFundingRequestProgramStep(organizationId, localizationId, programStartDate, programStopDate,ExpectedAttendeesThatAreHCPs,ExpectedAttendeesUSBasedHCPs);
		resultRequest.Total_Program_Budget__c = 10000;
		
		List<GFRS_Program__c> programList=gFRS_DAO.getProgramListByRequestId(resultRequest.id);
		
		if(programList.size()>0){
			insertBudget(programList.get(0).Id, resultRequest.id);
		}
		
		update resultRequest;   
    	return resultRequest;	
	}
	
	/**
	* @author: GFRS Dev Team
	* @date: 19/06/2013
	* @description: Creates bugdet and budget line item for given Funding Request.
	*/
	private static void insertBudget(Id programId, Id requestId){
		GFRS_RequestBudget__c budget = new GFRS_RequestBudget__c();
		budget.Type__c = 'Live';
		budget.Request_Delivery_Format__c = programId;
		budget.Grant_Request__c = requestId;
		insert budget;
		
		GFRS_Request_Budget_Line_Item__c budgetLineItem = new GFRS_Request_Budget_Line_Item__c(	
			Amount__c = 10000, 
			Budget_Category__c = 'Accreditation', 
			Budget_Subcategory__c = 'Accreditation Fees', 
			Comments_Clarification__c = gFRS_UnitTestHelper.TEST_TEXT,
			Budget__c = budget.id
		);
		insert budgetLineItem;
	}
	
	/**
	* @author: GFRS Dev Team
	* @date: 19/06/2013
	* @description: Creates IMED funding request for unit tests purposes. Creates funding request as it would ba after Confirmation Step on UI.
	*/
	public static GFRS_Funding_Request__c createIMEDFundingRequestConfirmationStep(Id organizationId, Id localizationId, Date programStartDate, Date programStopDate, User user,Integer ExpectedAttendeesThatAreHCPs,Integer ExpectedAttendeesUSBasedHCPs) {
		
		GFRS_Funding_Request__c resultRequest = createIMEDFundingRequestBudgetStep(organizationId, localizationId, programStartDate, programStopDate,ExpectedAttendeesThatAreHCPs,ExpectedAttendeesUSBasedHCPs);
		resultRequest.Authorized_Signer__c = user.Id;
		resultRequest.Signing_Authority_Email__c = user.Email;
		resultRequest.Signing_Authority_First_Name__c = user.FirstName;
		resultRequest.Signing_Authority_Last_Name__c = user.LastName;
		resultRequest.Refunded_Amount__c =0.0;
		resultRequest.Total_Activity_Cost_per_Attendee__c = 2000.0;

		
		update resultRequest;
    
    	return resultRequest;	
	}

}