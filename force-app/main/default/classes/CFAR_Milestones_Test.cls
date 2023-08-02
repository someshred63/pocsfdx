@isTest
private class CFAR_Milestones_Test {

    @testSetup
    static void setup() {
        User cfarUser = CFAR_TestUtils.createTestAverageUser();
        System.runAs(cfarUser) {
            CFAR_TestUtils.createTestTrial();
        }
        System.assert(true);
    }

    static testMethod void unitTest_Basic() {
        User cfarUser = [SELECT Id FROM USER WHERE alias = 'testAvg'];
        System.runAs(cfarUser)
        {
            //GIVEN
            CFAR_Trial_gne__c trial = [SELECT Id, Name FROM CFAR_Trial_gne__c LIMIT 1];
            
            Test.startTest();
            CFAR_MilestonesController ctrl = new CFAR_MilestonesController();
            ctrl.trialWrapper.innerObject = trial;

            ctrl.trial.Planned_Enrollment_gne__c = 20;
            ctrl.save();
            ctrl.refreshTrialChildObjects();
                        
            CFAR_Milestone_Activity_gne__c[] milestoneActivities = ctrl.getMilestoneActivities();

            system.assert(!milestoneActivities.isEmpty() && Integer.valueOf(ctrl.getMilestonesSize()) > 0);

            CFAR_Milestone_Activity_gne__c fpi, lpi = null;

            for(CFAR_Milestone_Activity_gne__c milestoneActivity : milestoneActivities) {
                if(milestoneActivity.name == 'FPI') {
                    fpi = milestoneActivity;
                }
                if(milestoneActivity.name == 'LPI') {
                    lpi = milestoneActivity;
                }
            }

            system.assert(fpi != null);
            system.assert(lpi != null);

            Date fpiPlanedDate = System.today();
            Date lpiPlanedDate = fpiPlanedDate.addYears(3);

            //WHEN
            ctrl.milestoneActivityId = fpi.Id;
            ctrl.editMilestoneActivity();
            ctrl.currentMilestoneActivity.Planned_Date_gne__c = fpiPlanedDate;
            ctrl.submitMilestoneActivity();
            system.assert(!ctrl.isError);

            ctrl.milestoneActivityId = lpi.Id;
            ctrl.editMilestoneActivity();
            ctrl.currentMilestoneActivity.Planned_Date_gne__c = lpiPlanedDate;
            ctrl.submitMilestoneActivity();
            system.assert(!ctrl.isError);

            ctrl.createNewEnrollment();
            ctrl.currentEnrollment.Enrolled_Num_gne__c = 20;
            ctrl.submitEnrollment();

            ctrl.createNewMilestoneActivity();
            system.assert(ctrl.addEditMilestoneActivity);
            ctrl.cancelCreateMilestoneActivity();
            system.assert(!ctrl.addEditMilestoneActivity);

            //THEN
            system.assert(!ctrl.getLpiError());
            system.assert(!ctrl.getTotalProjectedAccrualNotEqualPlannedEnrolledError());
            Test.stopTest();
        }
    }

    static testMethod void unitTest_EntollmentAndProjectedAccruals() {
        User cfarUser = [SELECT Id FROM USER WHERE alias = 'testAvg'];
        System.runAs(cfarUser)
        {
            //GIVEN
            CFAR_Trial_gne__c trial = [SELECT Id, Name FROM CFAR_Trial_gne__c LIMIT 1];
            
            Test.startTest();
            CFAR_MilestonesController ctrl = new CFAR_MilestonesController();
            ctrl.trialWrapper.innerObject = trial;
            
            CFAR_Milestone_Activity_gne__c[] milestoneActivities = ctrl.getMilestoneActivities();

            system.assert(!milestoneActivities.isEmpty());

            CFAR_Milestone_Activity_gne__c fpi, lpi = null;

            
            for(CFAR_Milestone_Activity_gne__c milestoneActivity : milestoneActivities) {
                if(milestoneActivity.name == 'FPI') {
                    fpi = milestoneActivity;
                }
                if(milestoneActivity.name == 'LPI') {
                    lpi = milestoneActivity;
                }
            }

            system.assert(fpi != null);
            system.assert(lpi != null);

            Date fpiPlanedDate = System.today();
            Date lpiPlanedDate = fpiPlanedDate.addYears(3);

            //WHEN
            ctrl.milestoneActivityId = fpi.Id;
            ctrl.editMilestoneActivity();
            ctrl.currentMilestoneActivity.Planned_Date_gne__c = fpiPlanedDate;
            ctrl.submitMilestoneActivity();
            system.assert(!ctrl.isError);

            ctrl.milestoneActivityId = lpi.Id;
            ctrl.editMilestoneActivity();
            ctrl.currentMilestoneActivity.Planned_Date_gne__c = lpiPlanedDate;
            ctrl.submitMilestoneActivity();
            system.assert(!ctrl.isError);

            ctrl.createNewEnrollment();
            ctrl.currentEnrollment.Enrolled_Num_gne__c = 20;
            ctrl.submitEnrollment();

            //THEN
            List<CFAR_AccrualWrapper> projectedSubjectAccruals = ctrl.objectListProjectedSubjectAccrual; 
            system.assert(!projectedSubjectAccruals.isEmpty() 
                    && (projectedSubjectAccruals.size() == (lpiPlanedDate.year() - fpiPlanedDate.year() + 1)));

            CFAR_Actual_Enrollment_gne__c[] actualEnrollments = ctrl.getActualEnrollments();
            system.assert(!actualEnrollments.isEmpty());
            CFAR_Projected_Subject_Accrual_gne_ref__c projSubjectAccrual = (CFAR_Projected_Subject_Accrual_gne_ref__c) ctrl.objectListProjectedSubjectAccrual[0].innerObject;
            system.assert(projSubjectAccrual != null);
            system.assert(projSubjectAccrual.CFAR_Year_gne__c == fpiPlanedDate.year());
            system.assert(projSubjectAccrual.Actual_gne__c == ctrl.currentEnrollment.Enrolled_Num_gne__c);
            Test.stopTest();
        }
    }

    static testMethod void unitTest_EntollmentNumOfMonthsChanged() {
        User cfarUser = [SELECT Id FROM USER WHERE alias = 'testAvg'];
        System.runAs(cfarUser)
        {
            //GIVEN
            CFAR_Trial_gne__c trial = [SELECT Id, Name FROM CFAR_Trial_gne__c LIMIT 1];
            
            Test.startTest();
            CFAR_MilestonesController ctrl = new CFAR_MilestonesController();
            ctrl.trialWrapper.innerObject = trial;
            
            CFAR_Milestone_Activity_gne__c[] milestoneActivities = ctrl.getMilestoneActivities();

            system.assert(!milestoneActivities.isEmpty());

            CFAR_Milestone_Activity_gne__c fpi, lpi = null;

            
            for(CFAR_Milestone_Activity_gne__c milestoneActivity : milestoneActivities) {
                if(milestoneActivity.name == 'FPI') {
                    fpi = milestoneActivity;
                }
                if(milestoneActivity.name == 'LPI') {
                    lpi = milestoneActivity;
                }
            }

            system.assert(fpi != null);
            system.assert(lpi != null);

            Date fpiPlanedDate = System.today();
            Date lpiPlanedDate = fpiPlanedDate.addYears(3);

            //WHEN
            ctrl.milestoneActivityId = fpi.Id;
            ctrl.editMilestoneActivity();
            ctrl.currentMilestoneActivity.Planned_Date_gne__c = fpiPlanedDate;
            ctrl.submitMilestoneActivity();
            system.assert(!ctrl.isError);

            ctrl.milestoneActivityId = lpi.Id;
            ctrl.editMilestoneActivity();
            ctrl.currentMilestoneActivity.Planned_Date_gne__c = lpiPlanedDate;
            ctrl.submitMilestoneActivity();
            system.assert(!ctrl.isError);

            ctrl.createNewEnrollment();
            ctrl.currentEnrollment.Discontinued_Num_gne__c = 10;
            ctrl.currentEnrollment.Completed_Trial_Num_gne__c = 10;
            ctrl.currentEnrollment.Enrolled_Num_gne__c = 20;
            ctrl.submitEnrollment();
            ctrl.cancelCreateEnrollment();
            system.assert(ctrl.addEditEnrollment == false);
            system.assert(ctrl.getDiscontinuedPlusCompletedEqualsEnrolled());

            ctrl.trial.Number_Of_Months_Of_Enrollment__c = 12;
            ctrl.save();

            //THEN
            List<CFAR_AccrualWrapper> projectedSubjectAccruals = ctrl.objectListProjectedSubjectAccrual; 
            system.assert(!projectedSubjectAccruals.isEmpty() 
                    && (projectedSubjectAccruals.size() == (fpiPlanedDate.addMonths(Integer.valueOf(ctrl.trial.Number_Of_Months_Of_Enrollment__c)).year() - fpiPlanedDate.year() + 1)));

            
            CFAR_Actual_Enrollment_gne__c[] actualEnrollments = ctrl.getActualEnrollments();
            system.assert(!actualEnrollments.isEmpty());
            CFAR_Projected_Subject_Accrual_gne_ref__c firstProjSubjectAccrual = (CFAR_Projected_Subject_Accrual_gne_ref__c) ctrl.objectListProjectedSubjectAccrual[0].innerObject;
            system.assert(firstProjSubjectAccrual != null);
            system.assert(firstProjSubjectAccrual.CFAR_Year_gne__c == fpiPlanedDate.year());
            integer index = ctrl.objectListProjectedSubjectAccrual.size() - 1;
            CFAR_Projected_Subject_Accrual_gne_ref__c lastProjSubjectAccrual = (CFAR_Projected_Subject_Accrual_gne_ref__c) ctrl.objectListProjectedSubjectAccrual[index].innerObject;
            system.assert(lastProjSubjectAccrual != null);
            system.assert(lastProjSubjectAccrual.CFAR_Year_gne__c == fpiPlanedDate.addMonths(Integer.valueOf(ctrl.trial.Number_Of_Months_Of_Enrollment__c)).year());
            system.assert(ctrl.getLpiError());
            system.assert(ctrl.LPI_MESSAGE != null);
            Test.stopTest();
        }
    }

    // static testMethod void Baseline_ReBaseline_shouldUpdateBaselineDates() {
    //     User cfarUser = [SELECT Id FROM USER WHERE alias = 'testAvg'];
    //     System.runAs(cfarUser)
    //     {
    //         //GIVEN
    //         CFAR_Trial_gne__c trial = [SELECT Id, Name FROM CFAR_Trial_gne__c LIMIT 1];
            
    //         Test.startTest();
    //         CFAR_MilestonesController ctrl = new CFAR_MilestonesController();
    //         ctrl.trialWrapper.innerObject = trial;

    //         ctrl.trial.Planned_Enrollment_gne__c = 20;
    //         ctrl.save();

    //         CFAR_Milestone_Activity_gne__c[] milestoneActivities = ctrl.getMilestoneActivities();
    //         system.assert(!milestoneActivities.isEmpty() && Integer.valueOf(ctrl.getMilestonesSize()) > 0);

    //         CFAR_Milestone_Activity_gne__c fpi, lpi = null;

    //         for(CFAR_Milestone_Activity_gne__c milestoneActivity : milestoneActivities) {
    //             if(milestoneActivity.name == 'FPI') {
    //                 fpi = milestoneActivity;
    //             }
    //             if(milestoneActivity.name == 'LPI') {
    //                 lpi = milestoneActivity;
    //             }
    //             milestoneActivity.Planned_Date_gne__c = System.today();
    //         }
    //         update milestoneActivities;

    //         Date fpiPlanedDate = System.today();
    //         Date lpiPlanedDate = System.today();

    //         //WHEN
    //         ctrl.milestoneActivityId = fpi.Id;
    //         ctrl.editMilestoneActivity();
    //         ctrl.currentMilestoneActivity.Planned_Date_gne__c = fpiPlanedDate.addDays(1);
    //         ctrl.submitMilestoneActivity();
    //         system.assert(!ctrl.isError);

    //         ctrl.milestoneActivityId = lpi.Id;
    //         ctrl.editMilestoneActivity();
    //         ctrl.currentMilestoneActivity.Planned_Date_gne__c = lpiPlanedDate.addDays(1);
    //         ctrl.submitMilestoneActivity();
    //         system.assert(!ctrl.isError);

    //         ctrl.createNewEnrollment();
    //         ctrl.currentEnrollment.Enrolled_Num_gne__c = 20;
    //         ctrl.submitEnrollment();

    //         //THEN
    //         system.assert(ctrl.getAllowBaseline());
    //         ctrl.baseline();
    //         milestoneActivities = ctrl.getMilestoneActivities();

    //         for(CFAR_Milestone_Activity_gne__c milestoneActivity : milestoneActivities) {
    //             system.assertEquals(milestoneActivity.Planned_Date_gne__c, milestoneActivity.Baselined_Date_gne__c);
    //         }

    //         //WHEN
    //         ctrl.milestoneActivityId = fpi.Id;
    //         ctrl.editMilestoneActivity();
    //         ctrl.currentMilestoneActivity.Planned_Date_gne__c = fpiPlanedDate.addDays(2);
    //         ctrl.submitMilestoneActivity();
    //         system.assert(!ctrl.isError);

    //         ctrl.milestoneActivityId = lpi.Id;
    //         ctrl.editMilestoneActivity();
    //         ctrl.currentMilestoneActivity.Planned_Date_gne__c = lpiPlanedDate.addDays(3);
    //         ctrl.submitMilestoneActivity();
    //         system.assert(!ctrl.isError);

    //         System.assertEquals(true, ctrl.getAllowReBaseline());
    //         ctrl.rebaseline();

    //         milestoneActivities = ctrl.getMilestoneActivities();
    //         for (CFAR_Milestone_Activity_gne__c milestoneActivity : milestoneActivities) {
    //             if (milestoneActivity.name == 'FPI') {
    //                 system.assertEquals(fpiPlanedDate.addDays(2), milestoneActivity.Baselined_Date_gne__c);
    //             } else if (milestoneActivity.name == 'LPI') {
    //                 system.assertEquals(fpiPlanedDate.addDays(3), milestoneActivity.Baselined_Date_gne__c);
    //             } else
    //                 system.assertEquals(milestoneActivity.Planned_Date_gne__c, milestoneActivity.Baselined_Date_gne__c);
    //         }
    //         Test.stopTest();
    //     }
    // }

    static testMethod void unitTest_ProjectedSubjectAccruals() {
        User cfarUser = [SELECT Id FROM USER WHERE alias = 'testAvg'];
        System.runAs(cfarUser)
        {
            //GIVEN
            CFAR_Trial_gne__c trial = [SELECT Id, Name FROM CFAR_Trial_gne__c LIMIT 1];
            
            Test.startTest();
            CFAR_MilestonesController ctrl = new CFAR_MilestonesController();
            ctrl.trialWrapper.innerObject = trial;
            
            CFAR_Milestone_Activity_gne__c[] milestoneActivities = ctrl.getMilestoneActivities();

            system.assert(!milestoneActivities.isEmpty());

            CFAR_Milestone_Activity_gne__c fpi, lpi = null;

            
            for(CFAR_Milestone_Activity_gne__c milestoneActivity : milestoneActivities) {
                if(milestoneActivity.name == 'FPI') {
                    fpi = milestoneActivity;
                }
                if(milestoneActivity.name == 'LPI') {
                    lpi = milestoneActivity;
                }
            }

            system.assert(fpi != null);
            system.assert(lpi != null);

            Date fpiPlanedDate = System.today();
            Date lpiPlanedDate = fpiPlanedDate.addYears(20);

            //WHEN
            ctrl.milestoneActivityId = fpi.Id;
            ctrl.editMilestoneActivity();
            ctrl.currentMilestoneActivity.Planned_Date_gne__c = fpiPlanedDate;
            ctrl.submitMilestoneActivity();
            system.assert(!ctrl.isError);

            ctrl.milestoneActivityId = lpi.Id;
            ctrl.editMilestoneActivity();
            ctrl.currentMilestoneActivity.Planned_Date_gne__c = lpiPlanedDate;
            ctrl.submitMilestoneActivity();
            system.assert(!ctrl.isError);

            ctrl.createNewEnrollment();
            ctrl.currentEnrollment.Enrolled_Num_gne__c = 20;
            ctrl.submitEnrollment();

            //THEN
            List<CFAR_AccrualWrapper> projectedSubjectAccruals = ctrl.objectListProjectedSubjectAccrual; 
            system.assert(!projectedSubjectAccruals.isEmpty());
            system.assert(ctrl.hasNextProjectedSubjectAccrual);
            ctrl.nextProjectedSubjectAccrual();
            system.assert(ctrl.hasPreviousProjectedSubjectAccrual);
            ctrl.previousProjectedSubjectAccrual();
            system.assert(ctrl.hasNextProjectedSubjectAccrual);
            ctrl.firstProjectedSubjectAccrual();
            system.assert(!ctrl.hasPreviousProjectedSubjectAccrual);
            ctrl.lastProjectedSubjectAccrual();
            system.assert(!ctrl.hasNextProjectedSubjectAccrual);

            ctrl.objectId = ctrl.objectListProjectedSubjectAccrual[0].innerObject.Id;
            ctrl.editProjectedSubjectAccrual();
            CFAR_Projected_Subject_Accrual_gne_ref__c editedProjSubject = (CFAR_Projected_Subject_Accrual_gne_ref__c)ctrl.objectListProjectedSubjectAccrual[0].innerObject;
            editedProjSubject.Projected_Accrual_gne__c = 1;
            ctrl.saveProjectedSubjectAccrual();
            system.assert(!ctrl.isError);
            ctrl.cancelCreateProjectedSubjectAccrual();
            system.assert(ctrl.objectMapProjectedSubjectAccrual.get(ctrl.objectId).selected == false);

            integer index = ctrl.objectListProjectedSubjectAccrual.size();
            ctrl.objectId = ctrl.objectListProjectedSubjectAccrual[index-1].innerObject.Id;
            ctrl.editProjectedSubjectAccrual();
            editedProjSubject = (CFAR_Projected_Subject_Accrual_gne_ref__c)ctrl.objectListProjectedSubjectAccrual[0].innerObject;
            editedProjSubject.Projected_Accrual_gne__c = 2;
            ctrl.saveProjectedSubjectAccrual();

            ctrl.createNewEnrollment();
            Date newDate = Date.newInstance(Integer.valueOf(editedProjSubject.CFAR_Year_gne__c), 2, 17);
            ctrl.currentEnrollment.Date_gne__c = newDate;
            ctrl.currentEnrollment.Discontinued_Num_gne__c = 10;
            ctrl.currentEnrollment.Completed_Trial_Num_gne__c = 10;
            ctrl.currentEnrollment.Enrolled_Num_gne__c = 20;
            ctrl.submitEnrollment();
            ctrl.cancelCreateEnrollment();
            system.assert(ctrl.addEditEnrollment == false);

            system.assert(!ctrl.getLastProjectedAccrualNotEqualActualsError());

            system.assert(ctrl.TOTAL_PROJECTED_ACCRUAL_NOT_EQUAL_PLANNED_ENROLLED_MESSAGE != null);
            system.assert(ctrl.LAST_PROJECTED_ACCRUAL_NOT_EQUAL_ACTUAL_MESSAGE != null);

        }
    }

    static testMethod void saveAllMilestoneActivities_shouldSaveMas() {
        User cfarUser = [SELECT Id FROM USER WHERE alias = 'testAvg'];
        System.runAs(cfarUser) {
            //GIVEN
            CFAR_Trial_gne__c trial = [SELECT  name, Received_Date_gne__c, MSL_ref_gne__c, Investigator_ref_gne__c, Original_Amount_gne__c,
            CFAR_Specific_Indication_ref_gne__c, CFAR_General_Indication_ref_gne__c, Subject_Type__c, CTMS_gne__c,
            Study_Phase_gne__c, Genentech_Primary_Contact_ref_gne__c, Product_ref_gne__c, Other_Trial_gne_Id__c,
            Has_Amendment_Amount_gne__c, frm_Amendment_Amount_gne__c, frm_Current_Amount_gne__c FROM CFAR_Trial_gne__c WHERE frm_Is_Closed_gne__c = false LIMIT 1];

            Test.startTest();
            CFAR_MilestonesController ctrl = new CFAR_MilestonesController();
            ctrl.trialWrapper.innerObject = trial;
            CFAR_Milestone_Activity_gne__c[] milestoneActivities = ctrl.getMilestoneActivities();
            for (CFAR_Milestone_Activity_gne__c activity : milestoneActivities) {
                activity.Comments_gne__c = activity.Id;
            }

            ctrl.initialMilestoneActivities.clear();
            for(CFAR_Milestone_Activity_gne__c ma : milestoneActivities){
                CFAR_Milestone_Activity_gne__c clonedMa = new CFAR_Milestone_Activity_gne__c(Comments_gne__c = ma.Comments_gne__c + 'test');
                ctrl.initialMilestoneActivities.put(ma.Id, clonedMa);
            }

            //WHEN
            ctrl.saveAllMilestoneActivities();

            //THEN
            for (CFAR_Milestone_Activity_gne__c activity : [SELECT Id, Comments_gne__c FROM CFAR_Milestone_Activity_gne__c WHERE CFAR_Trial_ref_gne__c = : trial.Id]) {
                System.assertEquals(activity.Comments_gne__c, activity.Id);
            }
        }
    }

    static testMethod void getActiveMonths_shouldReturnNumberOfMonths() {
        User cfarUser = [SELECT Id FROM USER WHERE alias = 'testAvg'];
        System.runAs(cfarUser) {
            //GIVEN
            CFAR_Trial_gne__c trial = [SELECT Id, Name FROM CFAR_Trial_gne__c LIMIT 1];
            Test.startTest();
            CFAR_MilestonesController ctrl = new CFAR_MilestonesController();
            ctrl.trialWrapper.innerObject = trial;

            CFAR_Milestone_Activity_gne__c[] milestoneActivities = ctrl.getMilestoneActivities();

            for (CFAR_Milestone_Activity_gne__c activity : milestoneActivities) {
                if (activity.name == 'Activation') {
                    activity.Actual_Date_gne__c = Date.today().addMonths(-2);
                    update activity;
                }
            }

            //WHEN
            Integer activeMonths = ctrl.getActiveMonths();

            //THEN
            System.assertEquals(2, activeMonths, 'Should return number of active months, meaning months between today, and Activation MA Actual Date');
            Test.stopTest();
        }
    }
}