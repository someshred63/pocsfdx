/**
 * Utility class grouping methods used in triggers on case.
 * @author Radek Krawiec
 * @created 12/05/2012
 */
public without sharing class GNE_CM_Case_Trigger_Util
{   
    private static String[] months = new String[] { 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December' };
    
    public static final String GATCF_STANDARD_RECORD_TYPE = 'GATCF - Standard Case';
    public static final String CONTINUOUS_CARE_RECORD_TYPE = 'C&R - Continuous Care Case';
    public static final String GATCF_ELIGIBILITY_SCREENING_RECORD_TYPE = 'GATCF - Eligibility Screening';
    public static final String CR_STANDARD_RECORD_TYPE = 'C&R - Standard Case';
    
    public static final String TASK_RULE_FOLLOWUP_GATCF = 'Follow Up on GATCF Documents';
    public static final String TASK_RULE_REVIEW_GATCF = 'Review - received GATCF documents';
    public static final String TASK_RULE_PERFORM_NEW = 'Perform New Enrollment Review';
    private static String  cmTaskRTId = Task.SObjectType.getDescribe().getRecordTypeInfosByName().get('CM Task').getRecordTypeID();


    public static List<Patient_gne__c> getUpdatePatientVenclexta (Map<Id, Datetime> patientMap) 
    {
        List<Patient_gne__c> lstPats = [SELECT Id, Venclexta_Patient_Date_gne__c FROM Patient_gne__c WHERE Id IN :patientMap.keyset()];

        for (Patient_gne__c p : lstPats) 
        {
            if (p.Venclexta_Patient_Date_gne__c==null || p.Venclexta_Patient_Date_gne__c>patientMap.get(p.Id)) 
            {
                p.Venclexta_Patient_Date_gne__c = patientMap.get(p.Id);
            }
        }
        return lstPats;
    }

    public static List<Patient_gne__c> getUpdatePatientGATCFStatus (Set<Id> patientIds, Id gatcfRecordTypeId)
    {
        // get all GATCF cases for patients
        List<Case> GATCFCases = [SELECT Id, Patient_gne__c, Patient_gne__r.Active_GATCF_Case__c, Status FROM Case WHERE patient_gne__c IN :patientIds AND RecordTypeId = :gatcfRecordTypeId];
        
        system.debug('Found GATCF cases: ' + GATCFCases.size());
        
        Set<Patient_gne__c> patientsToUpdate = new Set<Patient_gne__c>();
        Set<Id> patientsWithActiveCases = new Set<Id>();
    
        System.debug('patient ids====='+patientIds);
        // for each patient, check if they have an active GATCF case                
        for (Case gatcfCase : GATCFCases)
        {   
            if (gatcfCase.Status == 'Active')
            {
                patientsWithActiveCases.add(gatcfCase.Patient_gne__c);
            }
        }
        
        System.debug('patient with active cases====='+patientsWithActiveCases);

        // iterate through the case again, and for each patient check if their status has changed
        for (Case gatcfCase : GATCFCases)
        {
            Patient_gne__c patient = gatcfCase.Patient_gne__r;
            if (patient !=null
                && ((patientsWithActiveCases.contains(patient.Id) && patient.Active_GATCF_Case__c != true) 
                    || (!patientsWithActiveCases.contains(patient.Id) && patient.Active_GATCF_Case__c != false)))
            {
                patient.Active_GATCF_Case__c = !patient.Active_GATCF_Case__c;
                patientsToUpdate.add(patient);
            }
        }
    
        System.debug('patients to update====='+patientsToUpdate);

        if (!patientsToUpdate.isEmpty())
        {
            System.debug('Updating patients with GATCF cases: ' + patientsToUpdate);
            //update new List<Patient_gne__c>(patientsToUpdate);
        }
        return new List<Patient_gne__c>(patientsToUpdate);
    }

    /**
     * Updates field Active_GATCF_Case__c depending on whether a patient has at least one active GATCF case. If they have, the property is set to true,
     * otherwise it's set to false.
     *
     * Method created to be used in trigger GNE_CM_case_post_processing.
     */
    public static void updatePatientGATCFStatus (Set<Id> patientIds, Id gatcfRecordTypeId)
    {
        update getUpdatePatientGATCFStatus(patientIds, gatcfRecordTypeId);
    }
    
    /**
     * This method creates tasks that are to be added when a case is inserted/updated.
     * It implements logic executed before in three workflow rules on the case object: 
     * 'Follow Up on GATCF Documents', 'Perform New Enrollment Review' and 'Review - received GATCF documents'.
     *
     * @param isInsert - tells whether this method has been called from a trigger fired after case creation
     */
    public static List<Task> getTasksOnCaseInsertUpdate(List<Case> cases, Map<Id,Case> oldCasesById, boolean isInsert)
    {
        if (!isInsert && oldCasesById == null)
        {
            throw new GNE_CM_Exception('A map of old cases needs to be passed to method getTasksOnCaseInsertUpdate when it is called from an ON UPDATE trigger');   
        }
        
        List<Task> newTasks = new List<Task>();
        
        Map<Id,Schema.RecordTypeInfo> caseRecordTypes = new Map<Id,Schema.RecordTypeInfo>(Schema.SObjectType.Case.getRecordTypeInfosById());
        
        //AS Changes 2/07/2013
        Set<Id> caseIds = new Set<Id>(); 
        if(cases != null && cases.size() > 0)
        {
        	for(Case cas :cases)
        	{
        		caseIds.add(cas.id);
        	}
        }
        Map<Id,Case> mapPERSource = new Map<Id,Case>([Select id,Patient_Enrollment_Request_gne__r.Secondary_Insurance_Carrier_Name_gne__c, Patient_Enrollment_Request_gne__r.PER_Source_gne__c , Patient_Enrollment_Request_gne__r.Primary_Insurance_Carrier_Name_gne__c, Patient_Enrollment_Request_gne__r.Anticipated_Date_of_Treatment_gne__c,Patient_Enrollment_Request_gne__r.Primary_Payer_gne__r.Name from Case where id in:caseIds and Patient_Enrollment_Request_gne__c != null]);
        integer dateSec  = 2;
        integer MonthJan = 1;
        for (Case c : cases)
        {
            Boolean oldConditionStatus = false;
            Case oldCase = null;
            
            if (!isInsert)
            {
                oldCase = oldCasesById.get(c.Id);
                oldConditionStatus = caseRecordTypes.get(oldCase.RecordTypeId).getName() == GATCF_STANDARD_RECORD_TYPE && oldCase.Financial_Checklist_Mailed_Date_gne__c != null;
            }
            
            // Rule : Follow Up on GATCF Documents
            // Apply the rules only if it has been edited to fulfill the conditions now - i.e. it had not fulfilled them before.
            if (caseRecordTypes.get(c.RecordTypeId).getName() == GATCF_STANDARD_RECORD_TYPE && c.Financial_Checklist_Mailed_Date_gne__c != null && !oldConditionStatus)
            {
                newTasks.add(new Task(
                    ActivityDate = c.Financial_Checklist_Mailed_Date_gne__c.addDays(7),
                    Description = TASK_RULE_FOLLOWUP_GATCF,
                    OwnerId = c.OwnerId,
                    Priority = 'Normal',
                    Status = 'Not Started',
                    Subject = TASK_RULE_FOLLOWUP_GATCF,
                    WhatId = c.Id
                ));
            }
            
            oldConditionStatus = false;
            if (!isInsert)
            {
                oldConditionStatus = caseRecordTypes.get(oldCase.RecordTypeId).getName() == GATCF_STANDARD_RECORD_TYPE && oldCase.Received_Date_gne__c != null;
            }
            
            // Rule : Review - received GATCF documents
            // Apply the rules only if it has been edited to fulfill the conditions now - i.e. it had not fulfilled them before.
            if (caseRecordTypes.get(c.RecordTypeId).getName() == GATCF_STANDARD_RECORD_TYPE && c.Received_Date_gne__c != null  && !oldConditionStatus)
            {
                newTasks.add(new Task(
                    ActivityDate = Date.today(),
                    Description = TASK_RULE_REVIEW_GATCF,
                    OwnerId = c.OwnerId,
                    Priority = 'Normal',
                    Status = 'Not Started',
                    Subject = TASK_RULE_REVIEW_GATCF,
                    WhatId = c.Id
                ));
            }
        
            // Rule : Perform New Enrollment Review
            if (isInsert && caseRecordTypes.get(c.RecordTypeId).getName() != CONTINUOUS_CARE_RECORD_TYPE
                && caseRecordTypes.get(c.RecordTypeId).getName() != GATCF_ELIGIBILITY_SCREENING_RECORD_TYPE
                && c.Create_Activity_gne__c == true
                && c.Combo_Therapy_Case_Flag_gne__c == false)
            {
                	/*newTasks.add(new Task(
                     ActivityDate = Date.today(),
                    Description = TASK_RULE_PERFORM_NEW,
                    OwnerId = c.OwnerId,
                    Priority = 'Normal',
                    Status = 'Not Started',
                    Subject = TASK_RULE_PERFORM_NEW,
                    WhatId = c.Id                   
                ));*/
                Task tsk = new Task(ActivityDate = Date.today(),
				                    Description = TASK_RULE_PERFORM_NEW,
				                    OwnerId = c.OwnerId,
				                    Priority = 'Normal',
				                    Status = 'Not Started',
				                    Subject = TASK_RULE_PERFORM_NEW,
				                    WhatId = c.Id        
                					);
                //AS Changes
                if(mapPERSource != null && mapPERSource.size() > 0)
                {
                	system.debug('------------------mapPERSource'+mapPERSource);
                	system.debug('------------------mapPERSource'+mapPERSource.get(c.id).Patient_Enrollment_Request_gne__r.PER_Source_gne__c+c.Product_gne__c);
                	if(mapPERSource.get(c.id).Patient_Enrollment_Request_gne__r.PER_Source_gne__c == 'Benefits Reverification' && (c.Product_gne__c == 'Lucentis' || c.Product_gne__c == 'Actemra') && c.case_referral_reason_gne__c == 'Proactive BI' && c.Enroll_Comp_Original_Receipt_gne__c == 'Yes')
	                {
	                	if(mapPERSource.get(c.id).Patient_Enrollment_Request_gne__r.Anticipated_Date_of_Treatment_gne__c != null)
	                	{
                            tsk.description='';//we don't want the task description to contain the task name in case of BR Tasks
                            updateTaskFieldsForBR(tsk,mapPERSource.get(c.id).Patient_Enrollment_Request_gne__r);
	                	}
	                }
                }
                newTasks.add(tsk);
            }
        }
        
        return newTasks;
    }
    
    // added input monthName normalization - Wojciech Twardowski
    public static Integer getMonthNumber (String monthName)
    {
        if (monthName == null || monthName == '')
        {
            return null;
        }
        monthName = monthName.toLowerCase().capitalize();
        
        for (Integer i = 0; i < months.size(); i++)
        {
            if (months[i] == monthName)
            {
                // return 1-based number, not 0-based
                return i+1;
            }
        }
        
        return null;
    }

    /*
        Updates Task ActivityDate based on ADOT on PER and Task Description based on other fields on PER.
        This is for Benefit Reverification (BR) tasks only.
    */
    public static Task updateTaskFieldsForBR(Task t, Patient_Enrollment_Request_gne__c per)
    {
        return updateTaskFieldsForBR(t, per.Anticipated_Date_of_Treatment_gne__c, per);
    
    }
    
    public static Task updateTaskFieldsForBR(Task t, Date adot, Patient_Enrollment_Request_gne__c per)
    {
        if(adot !=null)
        {
            Integer adotDay = adot.day();
            Integer adotMonth = adot.month();
            Integer adotYear = adot.year();

            //t.ActivityDate = getTaskDueDateBasedOnADOT(adot);
            t.ActivityDate = GNE_CM_Task_Queue_Mgmt_Helper.getADOTOffsetDate(adot);
            //For BR tasks, set this flag, so they are visible to Customer Portal Users
            t.IsVisibleInSelfService = true;
            //this flag is used to select tasks that are updated when ADOT on BR/PER is updated during Blizzard
            t.ADOT_Set_by_BR_gne__c = true;

            system.debug('description before==='+t.description);
            
            if (String.isBlank(t.Description)) {
            	t.Description = '';
            }
            t.Description  += ' Proactive BI '+ adotMonth +'/' + adotDay + '/' + adotYear ;
        }
		if (per != null) {
            if (String.isBlank(t.Description)) {
                t.Description = '';
            }
            t.Description += getTaskDescriptionBasedOnPER(per);
        }
        system.debug('description after==='+t.description);
        return t;
    }

    public static String getTaskDescriptionBasedOnPER(Patient_Enrollment_Request_gne__c per)
    {
        String description='';
        if((per.Primary_Insurance_Carrier_Name_gne__c != '' && per.Primary_Insurance_Carrier_Name_gne__c != null) && (per.Secondary_Insurance_Carrier_Name_gne__c != '' && per.Secondary_Insurance_Carrier_Name_gne__c != null))
        {
            description = description + ' '+per.Primary_Insurance_Carrier_Name_gne__c +'; '+per.Secondary_Insurance_Carrier_Name_gne__c;
        }
        else if(per.Primary_Insurance_Carrier_Name_gne__c != '' && per.Primary_Insurance_Carrier_Name_gne__c != null)
        {
            description = description + ' '+per.Primary_Insurance_Carrier_Name_gne__c;
        }
        else if(per.Secondary_Insurance_Carrier_Name_gne__c != '' && per.Secondary_Insurance_Carrier_Name_gne__c != null)
        {
            description = description + ' '+per.Secondary_Insurance_Carrier_Name_gne__c;
        }
        return description;
    }

    public static Task constructBaseTaskForCase(Case c, String activityType, String processCategory)
    {
        Task t = new Task (OwnerId =  c.OwnerId, 
                            WhatId = c.Id, 
                            Status = 'Not Started',
                            ActivityDate = System.today(), 
                            Activity_Type_gne__c = activityType,
                            Process_Category_gne__c = processCategory,
                            RecordTypeId = cmTaskRTId
                            );  
        return t;
    }

    public static Task constructGATCFAnnualReviewTask(Case c, String creatorComments){
        Task performAnnualRenewalTask = constructBaseTaskForCase(c,'Perform GATCF Annual Renewal','Managing a Case');
        performAnnualRenewalTask.OwnerId = c.Foundation_Specialist_gne__c;
        performAnnualRenewalTask.Creator_Comments_gne__c = creatorComments;
        performAnnualRenewalTask.ActivityDate = Date.valueof(c.Approval_Date_gne__c).addDays(335);
        return performAnnualRenewalTask;            
    }

    public static Task constructGATCFEnrollmentCompleteTask(Case c, String creatorComments){
        Task gatcfEnrollmentCompleteTask = constructBaseTaskForCase(c,'GATCF Service Update: Enrollment Complete','Access to Care');
        gatcfEnrollmentCompleteTask.Status = 'Completed';
        gatcfEnrollmentCompleteTask.OwnerId =  UserInfo.getUserId();
        return gatcfEnrollmentCompleteTask;
    }

    public static Task constructFollowUpOnInsuranceTask(Case c, String genericUserID)
    {
        Task followUpOnInsuranceTask = constructBaseTaskForCase(c,'Follow-up on Insurance Information','Access to Care');
        followUpOnInsuranceTask.OwnerId = genericUserID;
        followUpOnInsuranceTask.ActivityDate = c.Date_Discussed_gne__c.addMonths(3);
        return followUpOnInsuranceTask;
    }

    public static Task constructGATCFContingentEligibilityTask(Case c)
    {
        Task gatcfContingentEligibilityTask = GNE_CM_Case_Trigger_Util.constructBaseTaskForCase(c,'GATCF Service Update: Contingent Eligibility','Access to Care');
        gatcfContingentEligibilityTask.OwnerId =  UserInfo.getUserId();
        gatcfContingentEligibilityTask.Status = 'Completed';
        return gatcfContingentEligibilityTask;
    }

    public static Task constructGATCFFinancialObtainedTask(Case c)
    {
        Task gatcfFinancialObtainedTask = GNE_CM_Case_Trigger_Util.constructBaseTaskForCase(c,'GATCF Service Update: Financial Obtained','Access to Care');
        gatcfFinancialObtainedTask.OwnerId =  UserInfo.getUserId();
        gatcfFinancialObtainedTask.Status = 'Completed';
        return gatcfFinancialObtainedTask;
    }

    public static Task constructGATCFEligibilityEstablishedTask(Case c)
    {
        Task gatcfEligibilityEstablishedTask = GNE_CM_Case_Trigger_Util.constructBaseTaskForCase(c,'GATCF Service Update: Eligibility Established','Access to Care');
        gatcfEligibilityEstablishedTask.OwnerId =  UserInfo.getUserId();
        gatcfEligibilityEstablishedTask.Status = 'Completed';
        return gatcfEligibilityEstablishedTask;
    }

    public static Task constructGATCFPendingAppealTask(Case c)
    {
        Task gatcfPendingAppealTask = GNE_CM_Case_Trigger_Util.constructBaseTaskForCase(c,'GATCF Service Update: Pending Appeal Outcome','Access to Care');
        gatcfPendingAppealTask.OwnerId =  UserInfo.getUserId();
        gatcfPendingAppealTask.Status = 'Completed';
        return gatcfPendingAppealTask;
    }

    public static Task constructGESEligibilityApprovedTask(Case c)
    {
        Task gesEligibilityApprovedTask = GNE_CM_Case_Trigger_Util.constructBaseTaskForCase(c,'GES Service Update: Eligibility Established: Approved','Access to Care');
        gesEligibilityApprovedTask.OwnerId =  UserInfo.getUserId();
        gesEligibilityApprovedTask.Status = 'Completed';
        return gesEligibilityApprovedTask;
    }

    public static Task constructGESEligibilityDeniedTask(Case c)
    {
        Task gesEligibilityDeniedTask = GNE_CM_Case_Trigger_Util.constructBaseTaskForCase(c,'GES Service Update: Eligibility Established: Denied','Access to Care');
        gesEligibilityDeniedTask.OwnerId =  UserInfo.getUserId();
        gesEligibilityDeniedTask.Status = 'Completed';
        return gesEligibilityDeniedTask;
     }

    public static Task constructContinuousCareEligibilityConfirmTask(Case c, String creatorComments)
    {
        Task ccEligibilityConfirmTask = GNE_CM_Case_Trigger_Util.constructBaseTaskForCase(c,'Confirm eligibility of the Continuous Care Program','Managing a Case');
        ccEligibilityConfirmTask.Creator_Comments_gne__c = creatorComments; 
        ccEligibilityConfirmTask.ActivityDate = System.today().addDays(7);

        if (c.Product_gne__c == system.label.GNE_CM_OCRE_Product_Name)
        {
            ccEligibilityConfirmTask.ActivityDate = System.today().addDays(45);
        }
        return ccEligibilityConfirmTask;
    }
    
    public static Task constructAPAEligibilityTask(Case c,String activityType)
    {
        Task apaEligibilityPendingTask = GNE_CM_Case_Trigger_Util.constructBaseTaskForCase(c,activityType,'Managing a Case');
        apaEligibilityPendingTask.OwnerId =  UserInfo.getUserId();
        apaEligibilityPendingTask.Status = 'Completed';
        return apaEligibilityPendingTask;
    }

    public static Task constructStarterServiceTask(Case c, String activityType)
    {
        Task starterServEnrollReceivedTask = GNE_CM_Case_Trigger_Util.constructBaseTaskForCase(c,activityType,'Managing a Case');
        starterServEnrollReceivedTask.OwnerId =  UserInfo.getUserId();
        starterServEnrollReceivedTask.Status = 'Completed';
        return starterServEnrollReceivedTask;
    }

    public static Task constructNutropinReviewBITask(Case c, String subject, String description)
    {
        Task reviewUploadedBIPATask = GNE_CM_Case_Trigger_Util.constructBaseTaskForCase(c,null,null);
        reviewUploadedBIPATask.Priority = 'Normal';
        reviewUploadedBIPATask.Description = description;
        reviewUploadedBIPATask.Subject = subject;
        return reviewUploadedBIPATask;
    }
}