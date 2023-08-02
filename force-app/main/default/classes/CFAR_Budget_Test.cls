@isTest(SeeAllData=false)
private class CFAR_Budget_Test {

    @testSetup
    static void setup() {
        User cfarUser = CFAR_TestUtils.createTestAverageUser();
        CFAR_TestUtils.createTestAdminUser();
        CFAR_TestUtils.createTestReadOnlyUser();
        System.runAs(cfarUser) {
            CFAR_Trial_gne__c trial = CFAR_TestUtils.createTestTrial();
            CFAR_TestUtils.createContractTypes();
            CFAR_TestUtils.createPaymentStatuses();
            CFAR_TestUtils.createTrialStatuses();
            CFAR_TestUtils.createTestWBS();
            CFAR_DataFactory.TeamMemberWithOrgInstAddrAggregate teamMemberStr = new CFAR_DataFactory.TeamMemberWithOrgInstAddrAggregate(trial);
            teamMemberStr.createTeamMemberWithRandomStructure();
            teamMemberStr.createAnotherTeamMemberWithSameAddr(CFAR_TeamMemberHelper.ROLE_SPECIALTY_LAB_CONTACT);
        }
    }

    static testMethod void unitTest_Basic() {
        User cfarUser = [SELECT Id FROM User WHERE alias = 'testAvg' LIMIT 1];
        User adminUser = [SELECT Id FROM User WHERE alias = 'testAdm' LIMIT 1];
        System.runAs(cfarUser) {
            CFAR_Trial_gne__c trial = [SELECT Id, Name FROM CFAR_Trial_gne__c LIMIT 1];
            CFAR_Utils.setActualTrialId(trial.Id);
            CFAR_Budget_Controller ctrl = new CFAR_Budget_Controller();
            ctrl.trialWrapper.innerObject = trial;
            ctrl.currentPaymentSchedule = new CFAR_Budget_CPS_Payments_gne__c(name = 'testPayment');

            ctrl.edit();
            system.assert(ctrl.editMode);
            system.assert(!ctrl.getWBSes().isEmpty());
            ctrl.trial.CFAR_WBS_ref_gne__c = ctrl.getWBSes()[0].getValue();
            ctrl.saveTrial();
            system.assert(!ctrl.editMode);
            system.assert(ctrl.trial.CFAR_WBS_ref_gne__c != null);
            system.assert(!ctrl.isError);
            system.assert(String.isBlank(ctrl.errorMessage));

            ctrl.edit();
            system.assert(ctrl.editMode);
            ctrl.cancel();
            system.assert(!ctrl.editMode);

            ctrl.createNewContractTracking();
            system.assert(!ctrl.getContractTypes().isEmpty());
            system.assert(!ctrl.getPaymentScheduleStatuses().isEmpty());
        }
    }

    static testMethod void submitContractTracking_validationErrores() {
        User cfarUser = [SELECT Id FROM User WHERE alias = 'testAvg' LIMIT 1];
        System.runAs(cfarUser) {
            CFAR_Trial_gne__c trial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];
            CFAR_Utils.setActualTrialId(trial.Id);
            CFAR_Budget_Controller ctrl = new CFAR_Budget_Controller();
            Test.startTest();
            //Planned Contract
            ctrl.createNewContractTracking();
            String originalType = Label.CFAR_GSTARS_CONTRACT_TRACKING_ORGINAL_TYPE;
            CFAR_Budget_Contract_Type_gne__c t = [select Id, Name from CFAR_Budget_Contract_Type_gne__c 
                        where Name = :originalType limit 1];
            ctrl.currentContractTracking.Type_ref_gne__c = t.Id;
            ctrl.currentContractTracking.Type_ref_gne__r = t;
            Date executedDate = System.today();
            Date expiryDate = executedDate.addYears(3);
            ctrl.currentContractTracking.Amount_gne__c = 200000;
            ctrl.currentContractTracking.Fully_Executed_Date_gne__c = executedDate;
            ctrl.currentContractTracking.Contract_Expiry_Date_gne__c = expiryDate;
            ctrl.currentContractTracking.Contract_ID_gne__c = '1234';
            CFAR_Team_Member_gne__c member = [SELECT Id FROM CFAR_Team_Member_gne__c LIMIT 1];
            ctrl.selectedInvestigatorId = member.Id;
            ctrl.selectedInvestigator2 = member;
            system.assert(ctrl.selectedInvestigator2.Id != null);
            ctrl.submitContractTracking();

            //WHEN
            CFAR_Budget_Contract_Tracking_gne__c contractTrackingClone = ctrl.currentContractTracking.clone();
            ctrl.currentContractTracking.Type_ref_gne__c = null;
            ctrl.submitContractTracking();

            //THEN
            System.assertEquals(true, ctrl.contractTrackingErrorMessagesList.contains(Label.CFAR_GSTARS_CONTRACT_TYPE_REQUIRED),
                'Should throw error when Type_ref_gne__c of submitted contract tracking is null');

            //WHEN
            ctrl.contractTrackingErrorMessagesList = new List<String>();
            ctrl.currentContractTracking = contractTrackingClone.clone();
            ctrl.currentContractTracking.Contract_Requested_Date__c = null;
            ctrl.submitContractTracking();

            //THEN
            System.assertEquals(true, ctrl.contractTrackingErrorMessagesList.contains(Label.CFAR_GSTARS_CONTRACT_REQUESTED_DATE_REQUIRED),
                'Should throw error requested date is null');

            //WHEN
            ctrl.contractTrackingErrorMessagesList = new List<String>();
            delete [SELECT Id FROM CFAR_Budget_Contract_Tracking_gne__c];
            ctrl.currentContractTracking = contractTrackingClone.clone();
            ctrl.selectedInvestigator2 = member;
            t =[select Id, Name from CFAR_Budget_Contract_Type_gne__c where Name = :label.CFAR_GSTARS_CONTRACT_TRACKING_DECREASE_TYPE limit 1]; 
            ctrl.currentContractTracking.Type_ref_gne__r  = t;
            ctrl.currentContractTracking.Type_ref_gne__c  = t.Id;
            ctrl.currentContractTracking.Contract_Requested_Date__c = null;
            ctrl.submitContractTracking();

            //THEN
            System.assertEquals(true, ctrl.contractTrackingErrorMessagesList.contains(Label.CFAR_CONTRACT_ORGINAL_REQUIRED),
                'Should throw error if submitting contract tracking is not of planned or original, and theres no original contract tracking type on contract');

            //WHEN
            ctrl.contractTrackingErrorMessagesList = new List<String>();
            ctrl.currentContractTracking = contractTrackingClone.clone();
            ctrl.currentContractTracking.Amount_gne__c = null;
            ctrl.submitContractTracking();

            //THEN
            System.assertEquals(true, ctrl.contractTrackingErrorMessagesList.contains(Label.CFAR_GSTARS_TOTAL_CONTRACT_AMOUNT_REQUIRED),
                'Should throw error if submitting contract tracking has Amount_gne__c empty');

            //WHEN
            ctrl.contractTrackingErrorMessagesList = new List<String>();
            ctrl.currentContractTracking = contractTrackingClone.clone();
            ctrl.currentContractTracking.Type_ref_gne__c = null;
            ctrl.currentContractTracking.Contract_ID_gne__c = null;
            ctrl.submitContractTracking();

            //THEN
            System.assertEquals(true, ctrl.contractTrackingErrorMessagesList.contains(Label.CFAR_GSTARS_CONTRACT_ID_REQUIRED),
                'Should throw error if Contract_ID_gne__c is empty');

            //WHEN
            ctrl.contractTrackingErrorMessagesList = new List<String>();
            ctrl.currentContractTracking = contractTrackingClone.clone();
            ctrl.currentContractTracking.Fully_Executed_Date_gne__c = System.today().addDays(5);
            ctrl.submitContractTracking();

            //THEN
            System.assertEquals(true, ctrl.contractTrackingErrorMessagesList.contains(Label.CFAR_GSTARS_FULLY_EXECUTED_DATE_FUTURE),
                'Should throw error if Fully_Executed_Date_gne__c of contract tracking is future date');

            //WHEN
            ctrl.contractTrackingErrorMessagesList = new List<String>();
            ctrl.currentContractTracking = contractTrackingClone.clone();
            ctrl.currentContractTracking.Fully_Executed_Date_gne__c = null;
            ctrl.submitContractTracking();

            //THEN
            System.assertEquals(true, ctrl.contractTrackingErrorMessagesList.contains(Label.CFAR_GSTARS_FULLY_EXECUTED_DATE_REQUIRED),
                'Should throw error if Fully_Executed_Date_gne__c of contract tracking is empty');

            //WHEN
            ctrl.contractTrackingErrorMessagesList = new List<String>();
            ctrl.currentContractTracking = contractTrackingClone.clone();
            ctrl.currentContractTracking.Contract_Expiry_Date_gne__c = null;
            ctrl.submitContractTracking();

            //THEN
            System.assertEquals(true, ctrl.contractTrackingErrorMessagesList.contains(Label.CFAR_GSTARS_CONTRACT_EXPIRY_DATE_REQUIRED),
                'Should throw error if Contract_Expiry_Date_gne__c of contract tracking is empty');

            //WHEN
            ctrl.contractTrackingErrorMessagesList = new List<String>();
            ctrl.currentContractTracking = contractTrackingClone.clone();
            ctrl.currentContractTracking.Fully_Executed_Date_gne__c = System.today();
            ctrl.currentContractTracking.Contract_Expiry_Date_gne__c = System.today().addDays(-5);
            ctrl.submitContractTracking();

            //THEN
            System.assertEquals(true, ctrl.contractTrackingErrorMessagesList.contains(Label.CFAR_GSTARS_CONTRACT_EXPIRY_AFTER_FULLY_EXECUTED),
                'Should throw error if Fully_Executed_Date_gne__c is larger or equal than Contract_Expiry_Date_gne__c');

            //WHEN
            ctrl.contractTrackingErrorMessagesList = new List<String>();
            ctrl.currentContractTracking = contractTrackingClone.clone();
            t =[select Id, Name from CFAR_Budget_Contract_Type_gne__c where Name = :Label.CFAR_GSTARS_CONTRACT_TRACKING_DECREASE_TYPE limit 1]; 
            ctrl.currentContractTracking.Type_ref_gne__r  = t;
            ctrl.currentContractTracking.Type_ref_gne__c  = t.Id;
            ctrl.currentContractTracking.Amendment_Number_gne__c = -44;
            ctrl.submitContractTracking();

            //THEN
            System.assertEquals(true, ctrl.contractTrackingErrorMessagesList.contains(Label.CFAR_GSTARS_AMENDMENT_NUMBER_NEGATIVE),
                'Should throw error if Amendment_Number_gne__c is negative');

        }
    }

    static testMethod void unitTest_ContractTrackingPlanned() {
        User cfarUser = [SELECT Id FROM User WHERE alias = 'testAvg' LIMIT 1];
        System.runAs(cfarUser) {
            CFAR_Trial_gne__c trial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];
            CFAR_Utils.setActualTrialId(trial.Id);
            CFAR_Budget_Controller ctrl = new CFAR_Budget_Controller();

            system.assert(ctrl.hasNotDrugOnly);

            Test.startTest();
            //Planned Contract
            ctrl.createNewContractTracking();
            String plannedType = Label.CFAR_GSTARS_CONTRACT_TRACKING_PLANNED_TYPE;
            CFAR_Budget_Contract_Type_gne__c t = [select Id, Name from CFAR_Budget_Contract_Type_gne__c 
                        where Name = :plannedType limit 1];
            ctrl.currentContractTracking.Type_ref_gne__c = t.Id;
            ctrl.currentContractTracking.Type_ref_gne__r = t;
            
            Date executedDate = System.today();
            Date expiryDate = executedDate.addYears(3);
            ctrl.currentContractTracking.Amount_gne__c = 200000;
            ctrl.currentContractTracking.Fully_Executed_Date_gne__c = executedDate;
            ctrl.currentContractTracking.Contract_Expiry_Date_gne__c = expiryDate;
            ctrl.currentContractTracking.Contract_ID_gne__c = '1234';
            CFAR_Team_Member_gne__c member = [SELECT Id FROM CFAR_Team_Member_gne__c LIMIT 1];
            ctrl.selectedInvestigatorId = member.Id;
            ctrl.selectedInvestigator2 = member;
            system.assert(ctrl.selectedInvestigator2.Id != null);
            ctrl.submitContractTracking();

            System.debug('#Errors#: '+ctrl.getContractTrackingErrors());
            
            system.assert(!ctrl.isError);
            system.assert(String.isBlank(ctrl.errorMessage));

            system.assertEquals(1, ctrl.getContractTrackings().size());
            
            CFAR_Budget_CPS_Projection_gne__c[] projs = ctrl.getProjections();
            system.assert(!projs.isEmpty());
                            
            ctrl.currentContractTracking.Type_ref_gne__c = [select Id, Name from CFAR_Budget_Contract_Type_gne__c 
                    where Name = :plannedType limit 1][0].Id;

            system.assert(ctrl.getHasPlanning());

            CFAR_Budget_Contract_Tracking_gne__c[] ctrlTrackings =  ctrl.getContractTrackings();
            system.assert(!ctrlTrackings.isEmpty() && ctrlTrackings.size() == 1);
            ctrl.contractTrackingId = ctrlTrackings[0].Id;
            ctrl.editContractTracking();

            String originalType = Label.CFAR_GSTARS_CONTRACT_TRACKING_ORGINAL_TYPE;
            ctrl.currentContractTracking.Type_ref_gne__c = [select Id, Name from CFAR_Budget_Contract_Type_gne__c 
                    where Name = :originalType limit 1][0].Id;
            ctrl.currentContractTracking.Comments_gne__c = 'test comment';
            ctrl.contractTypeChanged();
            executedDate = executedDate.addMonths(0);
            expiryDate = expiryDate.addYears(2);
            ctrl.currentContractTracking.Amount_gne__c = 300000;
            ctrl.currentContractTracking.Contract_ID_gne__c = '1234';
            ctrl.currentContractTracking.Fully_Executed_Date_gne__c = executedDate;
            ctrl.currentContractTracking.Contract_Expiry_Date_gne__c = expiryDate;
            ctrl.submitContractTracking();

            System.debug('#Error: '+ctrl.getContractTrackingErrors());

            system.assert(!ctrl.isError);
            system.assert(String.isBlank(ctrl.errorMessage));
            
            projs = ctrl.getProjections();
            system.assert(!projs.isEmpty());

            system.assert(!ctrl.getContractTrackings().isEmpty());
            system.assertEquals(1, ctrl.getContractTrackings().size());
        }
    }

    static testMethod void unitTest_ContractTrackingOrginalAndAmendments() {
        User cfarUser = [SELECT Id FROM User WHERE alias = 'testAvg' LIMIT 1];
        System.runAs(cfarUser) {
            CFAR_Trial_gne__c trial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];
            CFAR_Utils.setActualTrialId(trial.Id);
            CFAR_Budget_Controller ctrl = new CFAR_Budget_Controller();

            system.assert(ctrl.hasNotDrugOnly);
            
            Test.startTest();
            //Orginal Contract
            ctrl.createNewContractTracking();
            String originalType = Label.CFAR_GSTARS_CONTRACT_TRACKING_ORGINAL_TYPE;
            CFAR_Budget_Contract_Type_gne__c t = [select Id, Name from CFAR_Budget_Contract_Type_gne__c 
                        where Name = :originalType limit 1];
            ctrl.currentContractTracking.Type_ref_gne__c = t.Id;
            ctrl.currentContractTracking.Type_ref_gne__r = t;
            
            ctrl.contractTypeChanged();
            
            Date executedDate = System.today();
            Date expiryDate = executedDate.addYears(3);
            ctrl.currentContractTracking.Amount_gne__c = 300000;
            ctrl.currentContractTracking.Contract_ID_gne__c = '1234';
            ctrl.currentContractTracking.Contract_Requested_Date__c = Date.Today();
            ctrl.currentContractTracking.Fully_Executed_Date_gne__c = executedDate;
            ctrl.currentContractTracking.Contract_Expiry_Date_gne__c = expiryDate;
            CFAR_Team_Member_gne__c member = [SELECT Id FROM CFAR_Team_Member_gne__c LIMIT 1];
            ctrl.selectedInvestigator2 = member;
            ctrl.submitContractTracking();
 
            system.assert(!ctrl.isError);
            system.assert(String.isBlank(ctrl.errorMessage));

            CFAR_Budget_Contract_Tracking_gne__c[] ctrlTrackings = ctrl.getContractTrackings();
            for(CFAR_Budget_Contract_Tracking_gne__c c : ctrlTrackings) {
                if(c.Type_ref_gne__r.Name == originalType) {
                    ctrl.contractTrackingId = c.Id;
                }
            }
            system.assert(ctrl.contractTrackingId != null);
            ctrl.editContractTracking();
            system.assert(ctrl.getIsOrginal());
            ctrl.cancelCreateContractTracking();
            
            
            CFAR_Budget_CPS_Projection_gne__c[] projs = ctrl.getProjections();
            system.assert(!projs.isEmpty());

            system.assert(!ctrlTrackings.isEmpty() && ctrlTrackings.size() == 1);
            
            Integer min, max = null;
            Decimal contractSum = 0;
            for(CFAR_Budget_CPS_Projection_gne__c c : projs) {
                if(min == null) min = Integer.valueOf(c.Year_gne__c);
                min = Math.min(min, Integer.valueOf(c.Year_gne__c));
                if(max == null) max = Integer.valueOf(c.Year_gne__c);
                max = Math.max(max, Integer.valueOf(c.Year_gne__c));
                
                contractSum += c.frm_Total_Amount_gne__c;
            }
            
            system.assert(min == executedDate.year());
            system.assert(max == expiryDate.year());
            system.assert(contractSum > ctrl.currentContractTracking.Amount_gne__c - 10
                && contractSum < ctrl.currentContractTracking.Amount_gne__c + 10); // for straight line method there is rounding

            executedDate = Date.today();
            expiryDate = expiryDate.addYears(2);
            
            ctrl.createNewContractTracking();
             String increaseType = Label.CFAR_GSTARS_CONTRACT_TRACKING_INCREASE_TYPE;
            t = [select Id, Name from CFAR_Budget_Contract_Type_gne__c 
                        where Name = :increaseType limit 1];
            ctrl.currentContractTracking.Type_ref_gne__c = t.Id;
            ctrl.currentContractTracking.Type_ref_gne__r = t;
            
            ctrl.contractTypeChanged();
            
            ctrl.currentContractTracking.Amount_gne__c = 500000;
            ctrl.currentContractTracking.Contract_ID_gne__c = '5678';
            ctrl.currentContractTracking.Fully_Executed_Date_gne__c = executedDate;
            ctrl.currentContractTracking.Contract_Expiry_Date_gne__c = expiryDate;
            ctrl.currentContractTracking.Contract_Requested_Date__c = Date.Today();
            ctrl.submitContractTracking();

            system.assert(!ctrl.getContractTrackings().isEmpty());
            system.assert(ctrl.getContractTrackings().size() == 2);
            
            projs = ctrl.getProjections();
            system.assert(!projs.isEmpty());
            
            min = null;
            max = null;
            contractSum = 0;
            for(CFAR_Budget_CPS_Projection_gne__c c : projs) {
                if(min == null) min = Integer.valueOf(c.Year_gne__c);
                min = Math.min(min, Integer.valueOf(c.Year_gne__c));
                if(max == null) max = Integer.valueOf(c.Year_gne__c);
                max = Math.max(max, Integer.valueOf(c.Year_gne__c));
                
                contractSum += c.frm_Total_Amount_gne__c;
            }
            
            system.assert(min == executedDate.year());

            ctrlTrackings = ctrl.getContractTrackings();
            for(CFAR_Budget_Contract_Tracking_gne__c c : ctrlTrackings) {
                if(c.Type_ref_gne__r.Name == increaseType) {
                    ctrl.contractTrackingId = c.Id;
                }
            }
            system.assert(ctrl.contractTrackingId != null);
            ctrl.editContractTracking();
            system.assert(ctrl.getIsAmendment());
            system.assert(ctrl.getHasAmendment());

            ctrl.cancelCreateContractTracking();

            system.assert(!ctrl.getContractTrackings().isEmpty() 
                && ctrl.getContractTrackings().size() == 2);

            Test.stopTest();
        }
    }

    static testMethod void unitTest_ContractTrackingOrginalAndAmendments2() {
        User cfarUser = [SELECT Id FROM User WHERE alias = 'testAvg' LIMIT 1];
        System.runAs(cfarUser) {
            CFAR_Trial_gne__c trial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];
            CFAR_Utils.setActualTrialId(trial.Id);
            CFAR_Budget_Controller ctrl = new CFAR_Budget_Controller();

            system.assert(ctrl.hasNotDrugOnly);

            Test.startTest();
            //Orginal Contract
            ctrl.createNewContractTracking();
             String originalType = Label.CFAR_GSTARS_CONTRACT_TRACKING_ORGINAL_TYPE;
            CFAR_Budget_Contract_Type_gne__c t = [select Id, Name from CFAR_Budget_Contract_Type_gne__c 
                        where Name = :originalType limit 1];
            ctrl.currentContractTracking.Type_ref_gne__c = t.Id;
            ctrl.currentContractTracking.Type_ref_gne__r = t;
            
            Date executedDate = System.today();
            Date expiryDate = executedDate.addYears(3);
            ctrl.currentContractTracking.Amount_gne__c = 300000;
            ctrl.currentContractTracking.Contract_ID_gne__c = '1234';
            ctrl.currentContractTracking.Contract_Requested_Date__c = Date.Today();
            ctrl.currentContractTracking.Fully_Executed_Date_gne__c = executedDate;
            ctrl.currentContractTracking.Contract_Expiry_Date_gne__c = expiryDate;
            CFAR_Team_Member_gne__c member = [SELECT Id FROM CFAR_Team_Member_gne__c LIMIT 1];
            ctrl.selectedInvestigator2 = member;
            ctrl.submitContractTracking();
            
            system.assert(!ctrl.isError);
            system.assert(String.isBlank(ctrl.errorMessage));

            CFAR_Budget_Contract_Tracking_gne__c[] ctrlTrackings = ctrl.getContractTrackings();
            for(CFAR_Budget_Contract_Tracking_gne__c c : ctrlTrackings) {
                if(c.Type_ref_gne__r.Name == originalType) {
                    ctrl.contractTrackingId = c.Id;
                }
            }
            system.assert(ctrl.contractTrackingId != null);
            ctrl.editContractTracking();
            system.assert(ctrl.getIsOrginal());
            ctrl.cancelCreateContractTracking();
            
            
            CFAR_Budget_CPS_Projection_gne__c[] projs = ctrl.getProjections();
            system.assert(!projs.isEmpty());

            system.assert(!ctrlTrackings.isEmpty() && ctrlTrackings.size() == 1);
            
            Integer min, max = null;
            Decimal contractSum = 0;
            for(CFAR_Budget_CPS_Projection_gne__c c : projs) {
                if(min == null) min = Integer.valueOf(c.Year_gne__c);
                min = Math.min(min, Integer.valueOf(c.Year_gne__c));
                if(max == null) max = Integer.valueOf(c.Year_gne__c);
                max = Math.max(max, Integer.valueOf(c.Year_gne__c));
                
                contractSum += c.frm_Total_Amount_gne__c;
            }
            
            system.assert(min == executedDate.year());
            system.assert(max == expiryDate.year());
            system.assert(contractSum > ctrl.currentContractTracking.Amount_gne__c - 10
                && contractSum < ctrl.currentContractTracking.Amount_gne__c + 10);
            

            executedDate = System.today();
            //Amendment Decrease
            expiryDate = expiryDate.addYears(-2);
            
            ctrl.createNewContractTracking();
             String decreaseType = Label.CFAR_GSTARS_CONTRACT_TRACKING_DECREASE_TYPE;
            t = [select Id, Name from CFAR_Budget_Contract_Type_gne__c 
                        where Name = :decreaseType limit 1];
            ctrl.currentContractTracking.Type_ref_gne__c = t.Id;
            ctrl.currentContractTracking.Type_ref_gne__r = t;

            ctrl.currentContractTracking.Amount_gne__c = 400000;
            ctrl.currentContractTracking.Contract_ID_gne__c = '9012';
            ctrl.currentContractTracking.Amendment_Number_gne__c = 2;
            ctrl.currentContractTracking.Fully_Executed_Date_gne__c = executedDate;
            ctrl.currentContractTracking.Contract_Requested_Date__c = Date.Today();
            ctrl.currentContractTracking.Contract_Expiry_Date_gne__c = expiryDate;
            ctrl.submitContractTracking();
            
            system.assert(!ctrl.getContractTrackings().isEmpty() 
                && ctrl.getContractTrackings().size() == 2);

            projs = ctrl.getProjections();
            system.assert(!projs.isEmpty());
            
            min = null;
            max = null;
            contractSum = 0;
            for(CFAR_Budget_CPS_Projection_gne__c c : projs) {
                if(min == null) min = Integer.valueOf(c.Year_gne__c);
                min = Math.min(min, Integer.valueOf(c.Year_gne__c));
                if(max == null) max = Integer.valueOf(c.Year_gne__c);
                max = Math.max(max, Integer.valueOf(c.Year_gne__c));
                
                contractSum += c.frm_Total_Amount_gne__c;
            }

            system.assert(min == executedDate.year());
            Test.stopTest();
        }
    }
    
    static testMethod void unitTest_Projections() {
        User cfarUser = [SELECT Id FROM User WHERE alias = 'testAvg' LIMIT 1];
        System.runAs(cfarUser) {
            CFAR_Trial_gne__c trial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];
            CFAR_Utils.setActualTrialId(trial.Id);
            CFAR_Budget_Controller ctrl = new CFAR_Budget_Controller();

            Test.startTest();
            ctrl.createNewContractTracking();
            ctrl.currentPaymentSchedule = new CFAR_Budget_CPS_Payments_gne__c(name = 'testPayment');
            system.assert(!ctrl.getContractTypes().isEmpty());
            system.assert(!ctrl.getPaymentScheduleStatuses().isEmpty());
            system.assert(ctrl.hasNotDrugOnly);

            //Orginal Contract
            String originalType = Label.CFAR_GSTARS_CONTRACT_TRACKING_ORGINAL_TYPE;
            CFAR_Budget_Contract_Type_gne__c t = [select Id, Name from CFAR_Budget_Contract_Type_gne__c
                where Name = :originalType limit 1];
            ctrl.currentContractTracking.Type_ref_gne__c = t.Id;
            ctrl.currentContractTracking.Type_ref_gne__r = t;

            Date executedDate = System.today();
            Date expiryDate = executedDate.addYears(3);
            ctrl.currentContractTracking.Contract_Requested_date__c = Date.Today();
            ctrl.currentContractTracking.Amount_gne__c = 300000;
            ctrl.currentContractTracking.Contract_ID_gne__c = '1234';
            ctrl.currentContractTracking.Fully_Executed_Date_gne__c = executedDate;
            ctrl.currentContractTracking.Contract_Expiry_Date_gne__c = expiryDate;
            CFAR_Team_Member_gne__c member = [SELECT Id FROM CFAR_Team_Member_gne__c LIMIT 1];
            ctrl.selectedInvestigator2 = member;
            ctrl.submitContractTracking();

            system.assert(!ctrl.isError);
            system.assert(String.isBlank(ctrl.errorMessage));

            CFAR_Budget_CPS_Projection_gne__c[] projs = ctrl.getProjections();
            system.assert(!projs.isEmpty());
            ctrl.projectionId = projs[0].Id;
            ctrl.editProjection();
            ctrl.currentProjection.Comments_gne__c = 'test comment';
            ctrl.submitProjection();
            projs = ctrl.getProjections();
            ctrl.projectionId = projs[0].Id;
            ctrl.editProjection();
            system.assert(ctrl.currentProjection.Comments_gne__c == 'test comment');
            system.assert(ctrl.addEditProjection);
            ctrl.cancelEditProjection();
            system.assert(!ctrl.addEditProjection);

            Test.stopTest();
        }
    }

    static testMethod void unitTest_Payments() {
        User cfarUser = [SELECT Id FROM User WHERE alias = 'testAvg' LIMIT 1];
        System.runAs(cfarUser) {
            CFAR_Trial_gne__c trial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];
            CFAR_Utils.setActualTrialId(trial.Id);
            CFAR_Budget_Controller ctrl = new CFAR_Budget_Controller();
            ctrl.currentPaymentSchedule = new CFAR_Budget_CPS_Payments_gne__c(name='testPayment');
            CFAR_Payment_Schedule_Status_gne__c paymentStatus = [SELECT Id, NAme FROM CFAR_Payment_Schedule_Status_gne__c WHERE Name =: Label.CFAR_GSTARS_PAYMENT_SCHEDULE_SUBMITTED_STATUS];

            //Orginal Contract
            ctrl.createNewContractTracking();
            system.assert(!ctrl.getContractTypes().isEmpty());
            system.assert(!ctrl.getPaymentScheduleStatuses().isEmpty());
            system.assert(ctrl.hasNotDrugOnly);
            String originalType = Label.CFAR_GSTARS_CONTRACT_TRACKING_ORGINAL_TYPE;
            CFAR_Budget_Contract_Type_gne__c t = [select Id, Name from CFAR_Budget_Contract_Type_gne__c 
                        where Name = :originalType limit 1];
            ctrl.currentContractTracking.Type_ref_gne__c = t.Id;
            ctrl.currentContractTracking.Type_ref_gne__r = t;
            Test.startTest();
            Date executedDate = System.today();
            Date expiryDate = executedDate.addYears(3);
            ctrl.currentContractTracking.Amount_gne__c = 200000;
            ctrl.currentContractTracking.Contract_Requested_Date__c = Date.Today();
            ctrl.currentContractTracking.Contract_ID_gne__c = '1234';
            ctrl.currentContractTracking.Fully_Executed_Date_gne__c = executedDate;
            ctrl.currentContractTracking.Contract_Expiry_Date_gne__c = expiryDate;
            CFAR_Team_Member_gne__c member = [SELECT Id FROM CFAR_Team_Member_gne__c LIMIT 1];
            ctrl.selectedInvestigator2 = member;
            ctrl.submitContractTracking();
            system.assert(ctrl.trial.Is_Budget_Straight_Line__c);

            system.assert(!ctrl.isError);
            system.assert(String.isBlank(ctrl.errorMessage));
            
            CFAR_Budget_CPS_Projection_gne__c[] projs = ctrl.getProjections();
            system.assert(!projs.isEmpty());
            List<SelectOption> paymentExplanations = ctrl.getPaymentExplanations();
            ctrl.createNewPaymentSchedule();
            ctrl.currentPaymentSchedule.Payment_Explanation_Text_gne__c = paymentExplanations.get(1).getValue();
            ctrl.currentPaymentSchedule.Payment_Status_ref_gne__c = paymentStatus.Id;
            ctrl.currentPaymentSchedule.Planned_Date_gne__c = System.today();
            ctrl.currentPaymentSchedule.Planned_Amount_gne__c = 100000;
            ctrl.onPlannedDateChanged();
            ctrl.currentPaymentSchedule.Invoice_Date_gne__c = System.today();
            ctrl.currentPaymentSchedule.Invoice_Submitted_Date_gne__c = System.today();
            ctrl.currentPaymentSchedule.Check_Num_gne__c = '12334';
            ctrl.currentPaymentSchedule.Invoice_gne__c = '1';
            ctrl.onCheckChanged();
            ctrl.currentPaymentSchedule.Paid_On_gne__c = System.today();
            ctrl.onPaindOnChanged();
            ctrl.paymentStatusChanged();
            ctrl.currentPaymentSchedule.Invoice_Amount_gne__c = 100000;
            System.assertEquals(1, ctrl.getPaymentInvestigatorsOptions().size());
            ctrl.submitPaymentSchedule();

            System.debug('#Errors#: '+ctrl.getPaymentErrors());
            CFAR_Budget_Utils.setAlreadyProcessedPayment(false);

            ctrl.createNewPaymentSchedule();
            ctrl.currentPaymentSchedule.Payment_Explanation_Text_gne__c = paymentExplanations.get(1).getValue();
            ctrl.currentPaymentSchedule.Payment_Status_ref_gne__c = paymentStatus.Id;
            ctrl.currentPaymentSchedule.Planned_Date_gne__c = System.today();
            ctrl.currentPaymentSchedule.Planned_Amount_gne__c = 100000;
            ctrl.onPlannedDateChanged();
            ctrl.currentPaymentSchedule.Invoice_Date_gne__c = System.today();
            ctrl.currentPaymentSchedule.Invoice_Submitted_Date_gne__c = System.today();
            ctrl.currentPaymentSchedule.Check_Num_gne__c = '56789';
            ctrl.currentPaymentSchedule.Invoice_gne__c = '1';
            ctrl.onCheckChanged();
            ctrl.currentPaymentSchedule.Paid_On_gne__c = System.today();
            ctrl.onPaindOnChanged();
            ctrl.paymentStatusChanged();
            ctrl.currentPaymentSchedule.Invoice_Amount_gne__c = 100000;
            ctrl.submitPaymentSchedule();

            System.debug('#Errors#: '+ctrl.getPaymentErrors());

            CFAR_Budget_CPS_Payments_gne__c[] payments = ctrl.getPayments();
            ctrl.paymentScheduleId = payments[0].id;
            ctrl.editPaymentSchedule();
            ctrl.currentPaymentSchedule.Payment_Status_ref_gne__c = paymentStatus.Id;
            ctrl.currentPaymentSchedule.Invoice_Submitted_Date_gne__c = System.today();
            ctrl.currentPaymentSchedule.Invoice_Amount_gne__c = 100000;
            System.debug('#PSs#: '+ctrl.currentPaymentSchedule);
            ctrl.submitPaymentSchedule();

            system.assert(!payments.isEmpty());
            system.assertEquals(2, payments.size());

            //FIXME: Iteration2 MultiContract - broken test
            system.assert(CFAR_Budget_Utils.hasPayments(trial.id));
            ctrl.paymentScheduleId = payments[0].Id;
            ctrl.editPaymentSchedule();
            system.assert(ctrl.addEditPaymentSchedule);
            ctrl.cancelCreatePaymentSchedule();
            system.assert(!ctrl.addEditPaymentSchedule);

            ctrl.usePaymentsAsProjections();
            system.assert(!ApexPages.hasMessages());

            projs = ctrl.getProjections();
            system.assert(!projs.isEmpty());
            
            Decimal contractSum = 0;
            for(CFAR_Budget_CPS_Projection_gne__c c : projs) {
                contractSum += c.frm_Total_Amount_gne__c;
            }

            system.assert(!ctrl.hasPaymentPlannedAbove250K);
            system.assert(!ctrl.hasPaymentPlannedNotEqualToCurrentAmount);

            //GIVEN - test assignInvestigatorAndSetWithholdRelatedFields
            CFAR_ConfigUtil.setDisabled('Disabled_Triggers_gne__c', new List<String> {'CFAR_RateTableTrigger'});
            CFAR_Rate_Table_gne__c rateTable1 = new CFAR_Rate_Table_gne__c(Budget_Contract_ref_gne__c = ctrl.selectedInvestigatorsBudgetContractId, Payment_Type_gne__c = 'Subject', Status_gne__c = 'Active', Cost_gne__c = 200, Unit_gne__c = 10, Contract_Term_gne__c = 'Total');
            insert rateTable1;

            //WHEN
            ctrl.currentPaymentSchedule.Payment_Explanation_Text_gne__c = 'Total';
            ctrl.assignInvestigatorAndSetWithholdRelatedFields();

            //THEN
            System.assertEquals(rateTable1.Id, ctrl.currentPaymentSchedule.Rate_Table_ref_gne__c);
            System.assertEquals('No', ctrl.currentPaymentSchedule.Withhold_Indicator_gne__c);
            Test.stopTest();
        }
    }

    static testMethod void submitPaymentSchedule_validateErrors() {
        User cfarUser = [SELECT Id FROM User WHERE alias = 'testAvg' LIMIT 1];
        System.runAs(cfarUser) {
            CFAR_Trial_gne__c trial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];
            CFAR_Utils.setActualTrialId(trial.Id);
            CFAR_Budget_Controller ctrl = new CFAR_Budget_Controller();
            ctrl.currentPaymentSchedule = new CFAR_Budget_CPS_Payments_gne__c(name = 'testPayment');

            Test.startTest();
            ctrl.createNewContractTracking();
            String originalType = Label.CFAR_GSTARS_CONTRACT_TRACKING_ORGINAL_TYPE;
            CFAR_Budget_Contract_Type_gne__c t = [select Id, Name from CFAR_Budget_Contract_Type_gne__c
            where Name = :originalType limit 1];
            ctrl.currentContractTracking.Type_ref_gne__c = t.Id;
            ctrl.currentContractTracking.Type_ref_gne__r = t;
            ctrl.currentContractTracking.Amount_gne__c = 200000;
            ctrl.currentContractTracking.Contract_Requested_Date__c = Date.Today();
            ctrl.currentContractTracking.Contract_ID_gne__c = '1234';
            ctrl.currentContractTracking.Fully_Executed_Date_gne__c = System.today();
            ctrl.currentContractTracking.Contract_Expiry_Date_gne__c = System.today().addYears(3);
            ctrl.submitContractTracking();

            ctrl.createNewPaymentSchedule();
            List<SelectOption> paymentExplanations = ctrl.getPaymentExplanations();
            ctrl.currentPaymentSchedule.Payment_Explanation_Text_gne__c = paymentExplanations.get(1).getValue();
            ctrl.currentPaymentSchedule.Payment_Status_ref_gne__c = [SELECT Id FROM CFAR_Payment_Schedule_Status_gne__c WHERE Name =: Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PAID_STATUS].Id;
            ctrl.currentPaymentSchedule.Planned_Date_gne__c = System.today();
            ctrl.currentPaymentSchedule.Planned_Amount_gne__c = 100000;
            ctrl.currentPaymentSchedule.Invoice_Date_gne__c = System.today();
            ctrl.currentPaymentSchedule.Invoice_Submitted_Date_gne__c = System.today();
            ctrl.currentPaymentSchedule.Check_Num_gne__c = '12334';
            ctrl.currentPaymentSchedule.Paid_On_gne__c = System.today();
            ctrl.paymentStatusChanged();
            ctrl.currentPaymentSchedule.Invoice_Amount_gne__c = 100000;
            ctrl.submitPaymentSchedule();
            CFAR_Budget_CPS_Payments_gne__c currentPaymentScheduleClone = ctrl.currentPaymentSchedule.clone();
            System.assertEquals(true, ctrl.isPaymentError);
            System.assertEquals(true, ctrl.paymentErrorMessagesList.contains(Label.CFAR_GSTARS_INVOICE_NUMBER_REQUIRED),
                'Should throw error when Payment_Status_ref_gne__c = ' + Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PAID_STATUS + ' and Invoice # is empty.');

            ctrl.paymentErrorMessagesList = new Set<String>();
            ctrl.currentPaymentSchedule.Payment_Status_ref_gne__c = [SELECT Id FROM CFAR_Payment_Schedule_Status_gne__c WHERE Name =: Label.CFAR_GSTARS_PAYMENT_SCHEDULE_SUBMITTED_STATUS].Id;
            ctrl.submitPaymentSchedule();

            System.assertEquals(true, ctrl.paymentErrorMessagesList.contains(Label.CFAR_GSTARS_INVOICE_NUMBER_REQUIRED),
                'Should throw error when Payment_Status_ref_gne__c = ' + Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PAID_STATUS + ' and Invoice # is empty.');

            //WHEN
            ctrl.paymentErrorMessagesList = new Set<String>();
            ctrl.currentPaymentSchedule.Paid_On_gne__c = null;
            ctrl.submitPaymentSchedule();

            //THEN
            System.assertEquals(true, ctrl.paymentErrorMessagesList.contains(Label.CFAR_GSTARS_PAID_ON_DATE_REQUIRED),
                'Should throw error when Paid_On_gne__c = null and Payment_Status_ref_gne__r.Name =' + Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PAID_STATUS);

            ctrl.currentPaymentSchedule = currentPaymentScheduleClone;

            //WHEN
            ctrl.paymentErrorMessagesList = new Set<String>();
            ctrl.currentPaymentSchedule.Planned_Date_gne__c = null;
            ctrl.currentPaymentSchedule.Payment_Status_ref_gne__r.Name = Label.CFAR_GSTARS_PAYMENT_SCHEDULE_UNPAID_STATUS;
            ctrl.submitPaymentSchedule();

            //THEN
            System.assertEquals(true, ctrl.paymentErrorMessagesList.contains(Label.CFAR_GSTARS_PAYMENT_PLANNED_DATE_REQUIRED),
                'Should throw error when  Planned_Date_gne__c = null and Payment_Status_ref_gne__c = ' + Label.CFAR_GSTARS_PAYMENT_SCHEDULE_UNPAID_STATUS);

            //WHEN
            ctrl.paymentErrorMessagesList = new Set<String>();
            ctrl.currentPaymentSchedule = currentPaymentScheduleClone;
            ctrl.currentPaymentSchedule.Planned_Amount_gne__c = null;
            ctrl.currentPaymentSchedule.Payment_Status_ref_gne__r.Name = Label.CFAR_GSTARS_PAYMENT_SCHEDULE_UNPAID_STATUS;
            ctrl.submitPaymentSchedule();

            //THEN
            System.assertEquals(true, ctrl.paymentErrorMessagesList.contains(Label.CFAR_GSTARS_PLANNED_AMOUNT_REQUIRED),
                'Should throw error when Planned_Amount_gne__c = null and Payment_Status_ref_gne__c = ' + Label.CFAR_GSTARS_PAYMENT_SCHEDULE_UNPAID_STATUS);

            //WHEN
            ctrl.paymentErrorMessagesList = new Set<String>();
            ctrl.currentPaymentSchedule = currentPaymentScheduleClone;
            ctrl.currentPaymentSchedule.Invoice_Submitted_Date_gne__c = null;
            ctrl.currentPaymentSchedule.Payment_Status_ref_gne__r.Name = Label.CFAR_GSTARS_PAYMENT_SCHEDULE_REFUND_STATUS;
            ctrl.submitPaymentSchedule();

            //THEN
            System.assertEquals(true, ctrl.paymentErrorMessagesList.contains(Label.CFAR_GSTARS_INVOICE_SUBMITTED_DATE_REQUIRED),
                'Should throw error when Invoice_Submitted_Date_gne__c = null and Payment_Status_ref_gne__c = ' + Label.CFAR_GSTARS_PAYMENT_SCHEDULE_REFUND_STATUS );

            //WHEN
            ctrl.paymentErrorMessagesList = new Set<String>();
            ctrl.currentPaymentSchedule = currentPaymentScheduleClone;
            ctrl.currentPaymentSchedule.Invoice_Submitted_Date_gne__c = System.Today();
            ctrl.currentPaymentSchedule.Invoice_Amount_gne__c = 100;
            ctrl.currentPaymentSchedule.Payment_Status_ref_gne__r.Name = Label.CFAR_GSTARS_PAYMENT_SCHEDULE_REFUND_STATUS;
            ctrl.currentPaymentSchedule.Payment_Explanation_Text_gne__c = Label.CFAR_GSTARS_PAYMENT_SCHEDULE_REFUND_STATUS;
            CFAR_ConfigUtil.setDisabled('Disabled_Triggers_gne__c', new List<String> {'CFAR_RateTableTrigger'});
            CFAR_Rate_Table_gne__c rateTable1 = new CFAR_Rate_Table_gne__c(Budget_Contract_ref_gne__c = ctrl.selectedInvestigatorsBudgetContractId, Payment_Type_gne__c = 'Subject', Status_gne__c = 'Active', Cost_gne__c = 200, Unit_gne__c = 10, Contract_Term_gne__c = Label.CFAR_GSTARS_PAYMENT_SCHEDULE_REFUND_STATUS);
            insert rateTable1;
            ctrl.submitPaymentSchedule();

            //THEN
            System.assertEquals(true, ctrl.paymentErrorMessagesList.contains(Label.CFAR_GSTARS_REMAINING_BALANCE_GREATER_THAN_TOTAL_AMOUNT));
            System.assertEquals(true, ctrl.paymentErrorMessagesList.contains(Label.CFAR_GSTARS_PAID_UNITS_NOT_MULTIPLIER_OF_NET_UNIT_COST));

            //WHEN
            ctrl.paymentErrorMessagesList = new Set<String>();
            ctrl.currentPaymentSchedule = currentPaymentScheduleClone;
            ctrl.currentPaymentSchedule.Invoice_Amount_gne__c = null;
            ctrl.currentPaymentSchedule.Payment_Status_ref_gne__r.Name = Label.CFAR_GSTARS_PAYMENT_SCHEDULE_REFUND_STATUS;
            ctrl.submitPaymentSchedule();

            //THEN
            System.assertEquals(true, ctrl.paymentErrorMessagesList.contains(Label.CFAR_GSTARS_INVOICE_AMOUNT_REQUIRED),
                'Should throw error when Invoice_Amount_gne__c = null and Payment_Status_ref_gne__c = ' + Label.CFAR_GSTARS_PAYMENT_SCHEDULE_REFUND_STATUS);

            //WHEN
            ctrl.paymentErrorMessagesList = new Set<String>();
            ctrl.currentPaymentSchedule = currentPaymentScheduleClone;
            ctrl.currentPaymentSchedule.Invoice_Date_gne__c = null;
            ctrl.currentPaymentSchedule.Payment_Status_ref_gne__r.Name = Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PAID_STATUS;
            ctrl.submitPaymentSchedule();

            //THEN
            System.assertEquals(true, ctrl.paymentErrorMessagesList.contains(Label.CFAR_GSTARS_INVOICE_DATE_REQUIRED),
                'Should throw error when Invoice_Date_gne__c = null and Payment_Status_ref_gne__c = ' + Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PAID_STATUS );

            //WHEN
            ctrl.paymentErrorMessagesList = new Set<String>();
            ctrl.currentPaymentSchedule = currentPaymentScheduleClone;
            ctrl.currentPaymentSchedule.Payment_Explanation_Text_gne__c = '--None--';
            ctrl.submitPaymentSchedule();

            //THEN
            System.assertEquals(true, ctrl.paymentErrorMessagesList.contains(Label.CFAR_GSTARS_PAYMENT_EXPLANATION_REQUIRED),
                'Should throw error when Payment_Explanation_Text_gne__c = null or --None-- ');

            //WHEN
            ctrl.paymentErrorMessagesList = new Set<String>();
            ctrl.currentPaymentSchedule = currentPaymentScheduleClone;
            ctrl.currentPaymentSchedule.Payment_Status_ref_gne__r.Name = '--None--';
            ctrl.submitPaymentSchedule();

            //THEN
            System.assertEquals(true, ctrl.paymentErrorMessagesList.contains(Label.CFAR_GSTARS_PAYMENT_STATUS_REQUIRED),
                'Should throw error when Payment_Status_ref_gne__r.Name = null or --None-- ');

            //WHEN
            ctrl.paymentErrorMessagesList = new Set<String>();
            ctrl.currentPaymentSchedule = currentPaymentScheduleClone;
            ctrl.currentPaymentSchedule.Check_Num_gne__c = '';
            ctrl.currentPaymentSchedule.Payment_Status_ref_gne__r.Name = Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PAID_STATUS;
            ctrl.submitPaymentSchedule();

            //THEN
            System.assertEquals(true, ctrl.paymentErrorMessagesList.contains(Label.CFAR_GSTARS_CHECK_NUMBER_REQUIRED),
                'Should throw error when Check_Num_gne__c is blanks and Payment_Status_ref_gne__c = ' + Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PAID_STATUS);

            //WHEN
            ctrl.paymentErrorMessagesList = new Set<String>();
            ctrl.currentPaymentSchedule = currentPaymentScheduleClone;
            ctrl.currentPaymentSchedule.Invoice_Date_gne__c = System.Today();
            ctrl.selectedInvestigatorContract.Contract_End_Date_gne__c = System.Today().addDays(-2);
            ctrl.currentPaymentSchedule.Invoice_Submitted_Date_gne__c = System.Today();
            ctrl.submitPaymentSchedule();

            //THEN
            System.assertEquals(true, ctrl.paymentErrorMessagesList.contains(Label.CFAR_GSTARS_INVOICE_DATE_AFTER_CONTRACT_EXPIRY_DATE),
                'Should throw error when currentPaymentSchedule.Invoice_Submitted_Date_gne__c  is bigger than selectedInvestigatorContract.Contract_End_Date_gne__c.');

            //WHEN
            ctrl.paymentErrorMessagesList = new Set<String>();
            ctrl.currentPaymentSchedule = currentPaymentScheduleClone;
            ctrl.currentPaymentSchedule.Planned_Date_gne__c = System.Today().addDays(-2);
            ctrl.currentPaymentSchedule.Payment_Status_ref_gne__r.Name = Label.CFAR_GSTARS_PAYMENT_SCHEDULE_UNPAID_STATUS;
            ctrl.submitPaymentSchedule();

            //THEN
            System.assertEquals(true, ctrl.paymentErrorMessagesList.contains(Label.CFAR_GSTARS_PLANNED_DATE_IS_A_PAST_DATE),
                'Should throw error when currentPaymentSchedule.Planned_Date_gne__c is smaller than today, and Payment_Status_ref_gne__r.Name = ' + Label.CFAR_GSTARS_PAYMENT_SCHEDULE_UNPAID_STATUS);

            //WHEN
            ctrl.paymentErrorMessagesList = new Set<String>();
            ctrl.currentPaymentSchedule = currentPaymentScheduleClone;
            ctrl.currentPaymentSchedule.Invoice_Submitted_Date_gne__c = System.Today().addDays(4);
            ctrl.submitPaymentSchedule();

            //THEN
            System.assertEquals(true, ctrl.paymentErrorMessagesList.contains(Label.CFAR_GSTARS_INVOICE_SUBMITTED_DATE_IS_A_FUTURE_DATE),
                'Should throw error when ccurrentPaymentSchedule.Invoice_Submitted_Date_gne__c is bigger than today.');

            //WHEN
            ctrl.paymentErrorMessagesList = new Set<String>();
            ctrl.currentPaymentSchedule = currentPaymentScheduleClone;
            ctrl.currentPaymentSchedule.Paid_On_gne__c = System.Today().addDays(4);
            ctrl.submitPaymentSchedule();

            //THEN
            System.assertEquals(true, ctrl.paymentErrorMessagesList.contains(Label.CFAR_GSTARS_PAID_ON_DATE_IS_A_FUTURE_DATE),
                'Should throw error when ccurrentPaymentSchedule.Paid_On_gne__c is bigger than today.');

            //WHEN
            ctrl.paymentErrorMessagesList = new Set<String>();
            ctrl.currentPaymentSchedule = currentPaymentScheduleClone;
            ctrl.currentPaymentSchedule.Invoice_Date_gne__c = System.Today().addDays(4);
            ctrl.submitPaymentSchedule();

            //THEN
            System.assertEquals(true, ctrl.paymentErrorMessagesList.contains(Label.CFAR_GSTARS_INVOICE_DATE_IS_A_FUTURE_DATE),
                'Should throw error when ccurrentPaymentSchedule.Invoice_Date_gne__c is bigger than today.');

            //WHEN
            ctrl.paymentErrorMessagesList = new Set<String>();
            ctrl.currentPaymentSchedule = currentPaymentScheduleClone;
            ctrl.currentPaymentSchedule.Planned_Date_gne__c = System.Today().addDays(4);
            ctrl.selectedInvestigatorContract.Contract_End_Date_gne__c = System.Today();
            ctrl.submitPaymentSchedule();

            //THEN
            System.assertEquals(true, ctrl.paymentErrorMessagesList.contains(Label.CFAR_GSTARS_PLANNED_DATE_AFTER_CONTRACT_EXPIRY_DATE),
                'Should throw error when currentPaymentSchedule.Planned_Date_gne__c is bigger than selectedInvestigatorContract.Contract_End_Date_gne__c.');

            //WHEN
            ctrl.paymentErrorMessagesList = new Set<String>();
            ctrl.currentPaymentSchedule = currentPaymentScheduleClone;
            ctrl.currentPaymentSchedule.Invoice_Date_gne__c = System.Today().addDays(-4);
            ctrl.selectedInvestigatorContract.Original_Contract_Execution_Date_gne__c = System.Today();
            ctrl.submitPaymentSchedule();

            //THEN
            System.assertEquals(true, ctrl.paymentErrorMessagesList.contains(Label.CFAR_GSTARS_INVOICE_DATE_PRIOR_FULLY_EXECUTED_DATE),
                'Should throw error when selectedInvestigatorContract.Original_Contract_Execution_Date_gne__c is bigger than currentPaymentSchedule.Invoice_Date_gne__c .');

            //WHEN
            ctrl.paymentErrorMessagesList = new Set<String>();
            ctrl.currentPaymentSchedule = currentPaymentScheduleClone;
            ctrl.currentPaymentSchedule.Invoice_Submitted_Date_gne__c = System.Today().addYears(-1);
            ctrl.currentPaymentSchedule.Payment_Status_ref_gne__r.Name = Label.CFAR_GSTARS_PAYMENT_SCHEDULE_REFUND_STATUS;
            ctrl.submitPaymentSchedule();

            //THEN
            System.assertEquals(true, ctrl.paymentErrorMessagesList.contains(Label.CFAR_GSTARS_INVOICE_SUBMITTED_DATE_WITHIN_CURRENT_YEAR),
                'Should throw error when Invoice_Submitted_Date_gne__c is not equal current year, and Payment_Status_ref_gne__c = ' + Label.CFAR_GSTARS_INVOICE_SUBMITTED_DATE_WITHIN_CURRENT_YEAR);

            //WHEN
            ctrl.paymentErrorMessagesList = new Set<String>();
            ctrl.currentPaymentSchedule = currentPaymentScheduleClone;
            ctrl.currentPaymentSchedule.Planned_Amount_gne__c = 0;
            ctrl.submitPaymentSchedule();

            //THEN
            System.assertEquals(true, ctrl.paymentErrorMessagesList.contains(Label.CFAR_GSTARS_PLANNED_AMOUNT_GREATER_THAN_ZERO),
                'Should throw error when Planned Amount equals 0');

            //WHEN
            ctrl.paymentErrorMessagesList = new Set<String>();
            ctrl.currentPaymentSchedule = currentPaymentScheduleClone;
            ctrl.currentPaymentSchedule.Invoice_Submitted_Date_gne__c = System.Today().addDays(-5);
            ctrl.selectedInvestigatorContract.Original_Contract_Execution_Date_gne__c = System.Today();
            ctrl.currentPaymentSchedule.Payment_Status_ref_gne__r.Name = Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PAID_STATUS;
            ctrl.submitPaymentSchedule();

            //THEN
            System.assertEquals(true, ctrl.paymentErrorMessagesList.contains(Label.CFAR_GSTARS_INVOICE_SUBMITTED_DATE_PRIOR_FULLY_EXECUTED_DATE),
                'Should throw error when Original Contract Execution Date is bigger than Invoice Submitted date, and Payment Status = ' + Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PAID_STATUS);

            //WHEN
            ctrl.paymentErrorMessagesList = new Set<String>();
            ctrl.currentPaymentSchedule = currentPaymentScheduleClone;
            ctrl.currentPaymentSchedule.Invoice_Submitted_Date_gne__c = System.Today().addDays(5);
            ctrl.selectedInvestigatorContract.Original_Contract_Execution_Date_gne__c = System.Today();
            ctrl.selectedInvestigatorContract.Contract_End_Date_gne__c = System.today();
            ctrl.currentPaymentSchedule.Payment_Status_ref_gne__r.Name = Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PAID_STATUS;
            ctrl.validatePaymentInvoiceSubmittedDate();

            //THEN
            System.assertEquals(true, ctrl.paymentErrorMessagesList.contains(Label.CFAR_GSTARS_INVOICE_SUBMITTED_DATE_AFTER_CONTRACT_EXPIRY_DATE),
                'Should throw error when submitted date is after contract expiry date');

            //WHEN
            ctrl.paymentErrorMessagesList = new Set<String>();
            ctrl.currentPaymentSchedule = currentPaymentScheduleClone;
            ctrl.currentPaymentSchedule.Invoice_Submitted_Date_gne__c = System.Today().addDays(5);
            ctrl.validatePaymentInvoiceSubmittedDate();

            //THEN
            System.assertEquals(true, ctrl.paymentErrorMessagesList.contains(Label.CFAR_GSTARS_INVOICE_SUBMITTED_DATE_IS_A_FUTURE_DATE),
                'Should throw error when submitted date is after today');

            //WHEN
            ctrl.paymentErrorMessagesList = new Set<String>();
            ctrl.currentPaymentSchedule = currentPaymentScheduleClone;
            ctrl.currentPaymentSchedule.Invoice_Submitted_Date_gne__c = System.Today().addDays(5);
            ctrl.selectedInvestigatorContract.Original_Contract_Execution_Date_gne__c = System.Today().addDays(19);
            ctrl.selectedInvestigatorContract.Contract_End_Date_gne__c = System.today();
            ctrl.currentPaymentSchedule.Payment_Status_ref_gne__r.Name = Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PAID_STATUS;
            ctrl.validatePaymentInvoiceSubmittedDate();

            //THEN
            System.assertEquals(true, ctrl.paymentErrorMessagesList.contains(Label.CFAR_GSTARS_INVOICE_SUBMITTED_DATE_PRIOR_FULLY_EXECUTED_DATE),
                'Should throw error if Original_Contract_Execution_Date_gne__c of investigator is not prior to Invoice submitted date');

            //WHEN
            ctrl.paymentErrorMessagesList = new Set<String>();
            ctrl.currentPaymentSchedule = currentPaymentScheduleClone;
            ctrl.currentPaymentSchedule.Invoice_Submitted_Date_gne__c =null;
            ctrl.validatePaymentInvoiceDate();

            //THEN
            System.assertEquals(false, ctrl.paymentErrorMessagesList.contains(Label.CFAR_GSTARS_INVOICE_SUBMITTED_DATE_PRIOR_FULLY_EXECUTED_DATE),
                'Should remove messages from paymentErrorMessagesList if error criteria are not met');

            //WHEN
            ctrl.paymentErrorMessagesList = new Set<String>();
            ctrl.currentPaymentSchedule = currentPaymentScheduleClone;
            ctrl.currentPaymentSchedule.Invoice_Date_gne__c = System.today().addDays(12);
            ctrl.validatePaymentInvoiceDate();

            //THEN
            System.assertEquals(true, ctrl.paymentErrorMessagesList.contains(Label.CFAR_GSTARS_INVOICE_DATE_IS_A_FUTURE_DATE),
                'Should throw error if invocie date is a future date');

            //WHEN
            ctrl.paymentErrorMessagesList = new Set<String>();
            ctrl.currentPaymentSchedule = currentPaymentScheduleClone;
            ctrl.currentPaymentSchedule.Invoice_Date_gne__c = System.today().addDays(2);
            ctrl.selectedInvestigatorContract.Original_Contract_Execution_Date_gne__c  = System.today().addDays(12);
            ctrl.validatePaymentInvoiceDate();

            //THEN
            System.assertEquals(true, ctrl.paymentErrorMessagesList.contains(Label.CFAR_GSTARS_INVOICE_DATE_PRIOR_FULLY_EXECUTED_DATE),
                'Should throw error if invocie date is smaller than contracr execution date');

            //WHEN
            ctrl.paymentErrorMessagesList = new Set<String>();
            ctrl.currentPaymentSchedule = currentPaymentScheduleClone;
            ctrl.currentPaymentSchedule.Planned_Amount_gne__c = 0;
            ctrl.validatePaymentPlannedAmount();

            //THEN
            System.assertEquals(true, ctrl.paymentErrorMessagesList.contains(Label.CFAR_GSTARS_PLANNED_AMOUNT_GREATER_THAN_ZERO),
                'Should throw error if Planned_Amount_gne__c is zero or smaller');

            //WHEN
            ctrl.paymentErrorMessagesList = new Set<String>();
            ctrl.currentPaymentSchedule = currentPaymentScheduleClone;
            ctrl.currentPaymentSchedule.Planned_Amount_gne__c = 2;
            ctrl.validatePaymentPlannedAmount();

            //THEN
            System.assertEquals(false, ctrl.paymentErrorMessagesList.contains(Label.CFAR_GSTARS_PLANNED_AMOUNT_GREATER_THAN_ZERO),
                'Should remove error from paymentErrorMessagesList if Planned_Amount_gne__c is not zero or smaller');
        }
    }

    static testMethod void unitTest_getPaymentScheduleStatuses() {
        User cfarUser = [SELECT Id FROM User WHERE alias = 'testAvg' LIMIT 1];
        System.runAs(cfarUser) {
            CFAR_Budget_Controller ctrl = new CFAR_Budget_Controller();
            ctrl.currentPaymentSchedule = new CFAR_Budget_CPS_Payments_gne__c(name = 'testPayment');

            ctrl.currentPaymentSchedule.Payment_Explanation_Text_gne__c = Label.CFAR_GSTARS_PAYMENT_EXPLANATION_STATUS;
            List<SelectOption> paymentStatuses = ctrl.getPaymentScheduleStatuses();
            system.assertEquals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PLANNED_STATUS, paymentStatuses[0].getLabel(),
            'If Payment Explenation = Projected Spend, only available status should be ' + Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PLANNED_STATUS);

            ctrl.originalPaymentStatus = Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PLANNED_STATUS;
            paymentStatuses = ctrl.getPaymentScheduleStatuses();

            Set<String> expectedStatuses = new Set<String> {label.CFAR_GSTARS_PAYMENT_SCHEDULE_PLANNED_STATUS,  label.CFAR_GSTARS_PAYMENT_SCHEDULE_UNPAID_STATUS};
            System.assertEquals(2, paymentStatuses.size());
            for (SelectOption status : paymentStatuses) {
                system.assert(expectedStatuses.contains(status.getLabel()));
            }

            ctrl.currentPaymentSchedule.Payment_Explanation_Text_gne__c = '';
            paymentStatuses = ctrl.getPaymentScheduleStatuses();

            expectedStatuses = new Set<String> {label.CFAR_GSTARS_PAYMENT_SCHEDULE_CANCELLED_STATUS, label.CFAR_GSTARS_PAYMENT_SCHEDULE_DUE_NO_INVOICE_SUBMITTED_STATUS,
                                                label.CFAR_GSTARS_PAYMENT_SCHEDULE_PAID_STATUS, label.CFAR_GSTARS_PAYMENT_SCHEDULE_PLANNED_STATUS, label.CFAR_GSTARS_PAYMENT_SCHEDULE_REFUND_STATUS,
                                                label.CFAR_GSTARS_PAYMENT_SCHEDULE_SUBMITTED_STATUS, label.CFAR_GSTARS_PAYMENT_SCHEDULE_UNPAID_STATUS
                                               };
            for (SelectOption status : paymentStatuses) {
                system.assert(expectedStatuses.contains(status.getLabel()));
            }
        }
    }

    static testMethod void deletePaymentSchedule_shouldDeletePayment() {
        //GIVEN
        User cfarUser = [SELECT Id FROM User WHERE alias = 'testAvg' LIMIT 1];
        CFAR_Team_Member_gne__c member = [SELECT Id FROM CFAR_Team_Member_gne__c LIMIT 1];
        CFAR_Trial_gne__c trial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];
        CFAR_Utils.setActualTrialId(trial.Id);
        CFAR_Budget_Controller ctrl = new CFAR_Budget_Controller();
        CFAR_ConfigUtil.setDisabled('Disabled_Triggers_gne__c', new List<String> {'CFAR_RateTableTrigger'});
        CFAR_Budget_Contract_gne__c bc = CFAR_DataFactory.createBudgetContract(member);
        insert bc;
        CFAR_Rate_Table_gne__c rateTable = CFAR_DataFactory.createRateTable(bc);
        rateTable.Payment_Type_gne__c = 'Subject';
        insert rateTable;
        CFAR_Payment_Schedule_Status_gne__c paymentSchedule = CFAR_DataFactory.createPaymentScheduleStatus('Planned');
        insert paymentSchedule;
        CFAR_Budget_CPS_Payments_gne__c bCPSPayment = CFAR_DataFactory.createBudgePayments(rateTable, bc, paymentSchedule);
        insert bCPSPayment;

        //WHEN
        ctrl.paymentScheduleId = bCPSPayment.Id;
        ctrl.deletePaymentSchedule();

        //THEN
        System.assertEquals(0, [SELECT Count() FROM CFAR_Budget_CPS_Payments_gne__c WHERE Id = :bCPSPayment.Id],
                            'Should delete Payment if user has sufficient privileges ');
    }

    static testMethod void unitTest_RateTables() {
        User cfarUser = [SELECT Id FROM User WHERE alias = 'testAvg' LIMIT 1];
        System.runAs(cfarUser) {
            CFAR_Trial_gne__c trial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];
            CFAR_Utils.setActualTrialId(trial.Id);
            CFAR_Budget_Controller ctrl = new CFAR_Budget_Controller();
            ctrl.currentPaymentSchedule = new CFAR_Budget_CPS_Payments_gne__c(name='testPayment');


            //Orginal Contract
            ctrl.createNewContractTracking();
            
            system.assert(!ctrl.getContractTypes().isEmpty());
            system.assert(!ctrl.getPaymentScheduleStatuses().isEmpty());
            system.assert(ctrl.hasNotDrugOnly);
            
            String originalType = Label.CFAR_GSTARS_CONTRACT_TRACKING_ORGINAL_TYPE;
            CFAR_Budget_Contract_Type_gne__c t = [select Id, Name from CFAR_Budget_Contract_Type_gne__c 
                        where Name = :originalType limit 1];
            ctrl.currentContractTracking.Type_ref_gne__c = t.Id;
            ctrl.currentContractTracking.Type_ref_gne__r = t;
            Test.startTest();
            Date executedDate = System.today();
            Date expiryDate = executedDate.addYears(3);
            ctrl.currentContractTracking.Amount_gne__c = 300000;
            ctrl.currentContractTracking.Contract_ID_gne__c = '1234';
            ctrl.currentContractTracking.Contract_Requested_date__c = Date.Today();
            ctrl.currentContractTracking.Fully_Executed_Date_gne__c = executedDate;
            ctrl.currentContractTracking.Contract_Expiry_Date_gne__c = expiryDate;
            CFAR_Team_Member_gne__c member = [SELECT Id FROM CFAR_Team_Member_gne__c LIMIT 1];
            ctrl.selectedInvestigator2 = member;
            System.assertEquals(1, ctrl.getRTInvestigatorsOptions().size());
            ctrl.submitContractTracking();
            
            system.assert(!ctrl.isError);
            system.assert(String.isBlank(ctrl.errorMessage));
            
            CFAR_Budget_CPS_Projection_gne__c[] projs = ctrl.getProjections();
            system.assert(!projs.isEmpty());
            List<SelectOption> paymentExplanations = ctrl.getPaymentExplanations();
            List<SelectOption> paymentStatuses = ctrl.getPaymentScheduleStatuses();

            ctrl.createNewPaymentSchedule();
            ctrl.currentPaymentSchedule.Payment_Explanation_Text_gne__c = paymentExplanations.get(1).getValue();
            ctrl.currentPaymentSchedule.Payment_Status_ref_gne__c = paymentStatuses.get(1).getValue();
            ctrl.currentPaymentSchedule.Planned_Date_gne__c = System.today();
            ctrl.currentPaymentSchedule.Planned_Amount_gne__c = 150000;
            ctrl.currentPaymentSchedule.Invoice_gne__c = '1';
            ctrl.onPlannedDateChanged();
            ctrl.currentPaymentSchedule.Invoice_Date_gne__c = System.today();
            ctrl.validatePaymentInvoiceDate();
            ctrl.currentPaymentSchedule.Invoice_Submitted_Date_gne__c = System.today();
            ctrl.validatePaymentInvoiceSubmittedDate();
            ctrl.currentPaymentSchedule.Check_Num_gne__c = '12334';
            ctrl.onCheckChanged();
            ctrl.currentPaymentSchedule.Paid_On_gne__c = System.today();
            ctrl.onPaindOnChanged();
            ctrl.paymentStatusChanged();
            ctrl.currentPaymentSchedule.Invoice_Amount_gne__c = 150000;
            ctrl.submitPaymentSchedule();
            System.debug('#Errors#: '+ctrl.getPaymentErrors());
            CFAR_Budget_Utils.setAlreadyProcessedPayment(false);

            ctrl.createNewRateTable();
            system.assert(ctrl.getIsAddRT());
            ctrl.currentRateTable.Payment_Type_gne__c = 'Subject';
            ctrl.currentRateTable.Contract_Term_gne__c = 'test term';
            ctrl.validateRateTableContractTerm();
            ctrl.currentRateTable.Cost_gne__c = 15000;
            ctrl.currentRateTable.Unit_gne__c = 10;
            ctrl.currentRateTable.Withhold_Value_gne__c = 0;
            ctrl.currentRateTable.Withhold_Type_gne__c = '';
            ctrl.validateRateTableStatus();
            ctrl.submitRateTable();

            ctrl.validateRateTableStatus();
            System.assert(ctrl.getRTErrors().isEmpty());

            List<CFAR_Budget_Controller.RateTableWrapper> rateTables = ctrl.getRateTables();
            system.assert(!rateTables.isEmpty());
            ctrl.rateTableId = rateTables[0].Id;
            system.assert(ctrl.getIsRTEditPossible());
            ctrl.editRateTable();
            system.assert(ctrl.getIsEditRT());
            ctrl.cancelRateTable();
            system.assert(!ctrl.addEditRateTable);

            paymentStatuses = ctrl.getPaymentScheduleStatuses();

            CFAR_Budget_CPS_Payments_gne__c[] payments = ctrl.getPayments();
            ctrl.paymentScheduleId = payments[0].id;
            ctrl.editPaymentSchedule();
            ctrl.currentPaymentSchedule.Payment_Explanation_Text_gne__c = ctrl.getPaymentExplanations().get(1).getLabel();
            ctrl.currentPaymentSchedule.Payment_Status_ref_gne__c = paymentStatuses.get(paymentStatuses.size()-1).getValue();
            System.debug('#PSs#: '+ctrl.currentPaymentSchedule);
            ctrl.submitPaymentSchedule();
            System.debug('#Errors#: '+ctrl.getPaymentErrors());
        }
    }

    static testMethod void submitRateTable_shouldUpdateEditedRateTable() {
        User cfarUser = [SELECT Id FROM User WHERE alias = 'testAvg' LIMIT 1];
        System.runAs(cfarUser) {
            //GIVEN
            CFAR_Trial_gne__c trial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];
            CFAR_Utils.setActualTrialId(trial.Id);
            CFAR_Budget_Controller ctrl = new CFAR_Budget_Controller();
            Test.startTest();
            CFAR_Team_Member_gne__c member = [SELECT Id FROM CFAR_Team_Member_gne__c LIMIT 1];
            ctrl.selectedInvestigator2 = member;
            ctrl.createNewRateTable();
            ctrl.currentRateTable.Payment_Type_gne__c = 'Subject';
            ctrl.currentRateTable.Contract_Term_gne__c = 'test term';
            ctrl.validateRateTableContractTerm();
            ctrl.currentRateTable.Cost_gne__c = 15000;
            ctrl.currentRateTable.Unit_gne__c = 10;
            ctrl.currentRateTable.Withhold_Value_gne__c = 0;
            ctrl.submitRateTable();

            //WHEN
            CFAR_ConfigUtil.setDisabled('Disabled_Triggers_gne__c', new List<String> {'CFAR_RateTableTrigger'});
            ctrl.rateTableId = ctrl.currentRateTable.Id;
            ctrl.editRateTable();
            ctrl.currentRateTable.Cost_gne__c = 13;
            ctrl.submitRateTable();

            //THEN
            CFAR_Rate_Table_gne__c editedRateTable = [SELECT Cost_gne__c FROM CFAR_Rate_Table_gne__c WHERE Id = :ctrl.currentRateTable.Id];
            System.assertEquals(13, ctrl.currentRateTable.Cost_gne__c, 'Should update edited Rate Table');
            Test.stopTest();
        }
    }

    static testMethod void submitRateTable_validationErrors() {
        User cfarUser = [SELECT Id FROM User WHERE alias = 'testAvg' LIMIT 1];
        System.runAs(cfarUser) {
            CFAR_Trial_gne__c trial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];
            CFAR_Utils.setActualTrialId(trial.Id);
            CFAR_Budget_Controller ctrl = new CFAR_Budget_Controller();
            ctrl.currentPaymentSchedule = new CFAR_Budget_CPS_Payments_gne__c(name = 'testPayment');

            //Orginal Contract
            ctrl.createNewContractTracking();

            String originalType = Label.CFAR_GSTARS_CONTRACT_TRACKING_ORGINAL_TYPE;
            CFAR_Budget_Contract_Type_gne__c t = [select Id, Name from CFAR_Budget_Contract_Type_gne__c
            where Name = :originalType limit 1];
            ctrl.currentContractTracking.Type_ref_gne__c = t.Id;
            ctrl.currentContractTracking.Type_ref_gne__r = t;
            Test.startTest();
            Date executedDate = System.today();
            Date expiryDate = executedDate.addYears(3);
            ctrl.currentContractTracking.Amount_gne__c = 300000;
            ctrl.currentContractTracking.Contract_ID_gne__c = '1234';
            ctrl.currentContractTracking.Contract_Requested_date__c = Date.Today();
            ctrl.currentContractTracking.Fully_Executed_Date_gne__c = executedDate;
            ctrl.currentContractTracking.Contract_Expiry_Date_gne__c = expiryDate;
            CFAR_Team_Member_gne__c member = [SELECT Id FROM CFAR_Team_Member_gne__c LIMIT 1];
            ctrl.selectedInvestigator2 = member;
            ctrl.submitContractTracking();


            ctrl.createNewRateTable();
            system.assert(ctrl.getIsAddRT());
            ctrl.currentRateTable.Payment_Type_gne__c = 'Subject';
            ctrl.currentRateTable.Contract_Term_gne__c = 'test term';
            ctrl.validateRateTableContractTerm();
            ctrl.currentRateTable.Cost_gne__c = 15000;
            ctrl.currentRateTable.Unit_gne__c = 10;
            ctrl.currentRateTable.Withhold_Value_gne__c = 0;
            ctrl.currentRateTable.Withhold_Type_gne__c = 'Unit';
            CFAR_Rate_Table_gne__c rateTableClone = ctrl.currentRateTable.clone();

            //WHEN
            ctrl.currentRateTable.Payment_Type_gne__c = null;
            ctrl.submitRateTable();

            //THEN
            System.assertEquals(true, ctrl.rtErrorMessagesList.contains(Label.CFAR_GSTARS_PAYMENT_TYPE_REQUIRED),
            'Should throw error when Payment_Type_gne__c of submitting tate table is blank');

            //WHEN
            ctrl.rtErrorMessagesList = new Set<String>();
            ctrl.currentRateTable = rateTableClone.clone();
            ctrl.currentRateTable.Contract_Term_gne__c = null;
            ctrl.submitRateTable();

            //THEN
            System.assertEquals(true, ctrl.rtErrorMessagesList.contains(Label.CFAR_GSTARS_CONTRACT_TERM_REQUIRED),
            'Should throw error when Contract_Term_gne__c of submitting tate table is blank');

            //WHEN
            ctrl.rtErrorMessagesList = new Set<String>();
            ctrl.currentRateTable = rateTableClone.clone();
            ctrl.currentRateTable.Unit_gne__c = null;
            ctrl.submitRateTable();

            //THEN
            System.assertEquals(true, ctrl.rtErrorMessagesList.contains(Label.CFAR_GSTARS_NUMBER_OF_UNITS_REQUIRED),
            'Should throw error when Unit_gne__c of submitting tate table is blank');

            //WHEN
            ctrl.rtErrorMessagesList = new Set<String>();
            ctrl.currentRateTable = rateTableClone.clone();
            ctrl.currentRateTable.Cost_gne__c = -2;
            ctrl.submitRateTable();

            //THEN
            System.assertEquals(true, ctrl.rtErrorMessagesList.contains(Label.CFAR_GSTARS_UNIT_COST_GREATER_ZERO),
            'Should throw error when Cost_gne__c of submitting tate table is smaller than zero');

            //WHEN
            ctrl.rtErrorMessagesList = new Set<String>();
            ctrl.currentRateTable = rateTableClone.clone();
            ctrl.currentRateTable.Cost_gne__c = null;
            ctrl.submitRateTable();

            //THEN
            System.assertEquals(true, ctrl.rtErrorMessagesList.contains(Label.CFAR_GSTARS_UNIT_COST_REQUIRED),
            'Should throw error when Cost_gne__c of submitting tate table is blank');

            //WHEN
            ctrl.rtErrorMessagesList = new Set<String>();
            ctrl.currentRateTable = rateTableClone.clone();
            ctrl.currentRateTable.WithHold_Value_gne__c = null;
            ctrl.submitRateTable();

            //THEN
            System.assertEquals(true, ctrl.rtErrorMessagesList.contains(Label.CFAR_GSTARS_WITHHOLD_VALUE_REQUIRED),
            'Should throw error when WithHold_Value_gne__c of submitting tate table is null and WithHold_Type_gne__c is not blank');

            //WHEN
            ctrl.rtErrorMessagesList = new Set<String>();
            ctrl.currentRateTable = rateTableClone.clone();
            ctrl.currentRateTable.WithHold_Value_gne__c = 101;
            ctrl.currentRateTable.Withhold_Type_gne__c = 'Percent';
            ctrl.submitRateTable();

            //THEN
            System.assertEquals(true, ctrl.rtErrorMessagesList.contains(Label.CFAR_GSTARS_WITHHOLD_VALUE_GREATER_100_PERCENT),
            'Should throw error when Withhold_Type_gne__c is Percent, and value is greater than 100');

            //WHEN
            ctrl.rtErrorMessagesList = new Set<String>();
            ctrl.currentRateTable = rateTableClone.clone();
            ctrl.currentRateTable.Unit_gne__c = 10;
            ctrl.currentRateTable.WithHold_Value_gne__c = 100;
            ctrl.submitRateTable();

            //THEN
            System.assertEquals(true, ctrl.rtErrorMessagesList.contains(Label.CFAR_GSTARS_WITHHOLD_VALUE_GREATER_NUMBER_OF_UNITS),
            'Should throw error when Withhold_Type_gne__c is Unit, and WithHold_Value_gne__c is greater than Unit_gne__c.');

            //WHEN
            ctrl.rtErrorMessagesList = new Set<String>();
            ctrl.currentRateTable = rateTableClone.clone();
            CFAR_Rate_Table_gne__c rateTable1 = new CFAR_Rate_Table_gne__c(Budget_Contract_ref_gne__c = ctrl.selectedInvestigatorsBudgetContractId, Payment_Type_gne__c = 'Subject', Status_gne__c = 'Active', Cost_gne__c = 200, Unit_gne__c = 10, Contract_Term_gne__c = ctrl.currentRateTable.Contract_Term_gne__c);
            insert rateTable1;
            ctrl.submitRateTable();
            //THEN

            System.assertEquals(true, ctrl.rtErrorMessagesList.contains(Label.CFAR_GSTARS_CONTRACT_TERM_IS_NOT_UNIQUE),
            'Should throw error when Contract tracking with same type (Contract_Term_gne__c) already exists for contract');

            //WHEN
            ctrl.rtErrorMessagesList = new Set<String>();
            ctrl.currentRateTable = rateTableClone.clone();
            ctrl.currentRateTable.Budget_Contract_ref_gne__c = ctrl.selectedInvestigatorsBudgetContractId;
            ctrl.currentRateTable.Status_gne__c = 'Not Active';
            insert ctrl.currentRateTable;
            List<SelectOption> paymentStatuses = ctrl.getPaymentScheduleStatuses();
            CFAR_Budget_CPS_Payments_gne__c paymentSchedule = new CFAR_Budget_CPS_Payments_gne__c(Rate_Table_ref_gne__c = ctrl.currentRateTable.Id, Payment_Status_ref_gne__c = paymentStatuses.get(paymentStatuses.size() - 1).getValue(), Budget_Contract_ref_gne__c = ctrl.selectedInvestigatorsBudgetContractId);
            insert paymentSchedule;
            ctrl.submitRateTable();

            //THEN
            System.assertEquals(true, ctrl.rtErrorMessagesList.contains(Label.CFAR_GSTARS_UNABLE_TO_SET_NOT_ACTIVE_STATUS_IN_RATE_TABLE),
            'Should throw error when Status_gne__c of rate table is Not Active and there are payments related to this rate table');

            System.assertEquals(true, ctrl.rtErrorMessagesList.contains(Label.CFAR_GSTARS_CONTRACT_TERM_USED_IN_PAYMENTS),
            'Should throw error when Contract_Term_gne__c of current reate table is different than initialContractTerm and there are payments related to this rate table');

            //WHEN
            ctrl.rtErrorMessagesList = new Set<String>();
            ctrl.currentRateTable.WithHold_Type_gne__c = 'Percent';
            update ctrl.currentRateTable;
            ctrl.rateTableId = ctrl.currentRateTable.Id;
            ctrl.editRateTable();
            ctrl.currentRateTable.WithHold_Type_gne__c = 'Unit';
            ctrl.submitRateTable();

            //THEN
            System.assertEquals(true, ctrl.rtErrorMessagesList.contains(Label.CFAR_GSTARS_CANT_CHANGE_WITHOLD_TYPE_IF_PAYMENTS_EXIST_FOR_RT),
            'Should throw error when user attempts to change WithHold_Type_gne__c while payments already exist for this rate table. ');

            //WHEN
            ctrl.rtErrorMessagesList = new Set<String>();
            ctrl.currentRateTable.WithHold_Type_gne__c = 'Unit';
            update ctrl.currentRateTable;
            paymentSchedule.Withhold_Indicator_gne__c = 'Yes';
            update paymentSchedule;
            ctrl.rateTableId = ctrl.currentRateTable.Id;
            ctrl.editRateTable();
            ctrl.currentRateTable.WithHold_Type_gne__c = 'Percent';
            ctrl.submitRateTable();

            //THEN
            System.assertEquals(true, ctrl.rtErrorMessagesList.contains(Label.CFAR_GSTARS_CANT_CHANGE_WITHOLD_TYPE_IF_PAYMENTS_EXIST_FOR_RT),
            'Should throw error when user attempts to change WithHold_Type_gne__c while payments already exist for this rate table. ');
        }
    }

    static testMethod void test_isWBSRequired() {
        User cfarUser = [SELECT Id FROM User WHERE alias = 'testAvg' LIMIT 1];
        System.runAs(cfarUser) {
            CFAR_Trial_gne__c trial = [SELECT Id, Trial_Status_ref_gne__c FROM CFAR_Trial_gne__c LIMIT 1];
            CFAR_Budget_Controller ctrl = new CFAR_Budget_Controller();
            CFAR_Utils.setActualTrialId(trial.Id);

            Test.startTest();
            trial = CFAR_TestUtils.setTrialStatus(trial, Label.CFAR_GSTARS_TRIAL_STATUS_FOLLOWUP);
            System.assertEquals(Label.CFAR_GSTARS_TRIAL_STATUS_FOLLOWUP, trial.Trial_Status_ref_gne__r.Name);
            system.assert(ctrl.isWBSRequired);
            system.assert(ctrl.getRenderEditWbs());
            
            trial = CFAR_TestUtils.setTrialStatus(trial, Label.CFAR_GSTARS_TRIAL_STATUS_CLOSURE_PENDING);
            ctrl.trial = trial;
            System.assertEquals(Label.CFAR_GSTARS_TRIAL_STATUS_CLOSURE_PENDING, trial.Trial_Status_ref_gne__r.Name);
            system.assert(!ctrl.isWBSRequired);
            system.assert(ctrl.getRenderEditWbs());

            CFAR_TestUtils.createComment(trial, system.today().addDays(-20), 'testing');
            trial = CFAR_TestUtils.setTrialStatus(trial, Label.CFAR_GSTARS_TRIAL_STATUS_CANCELLED);
            ctrl.trial = trial;
            System.assertEquals(Label.CFAR_GSTARS_TRIAL_STATUS_CANCELLED, trial.Trial_Status_ref_gne__r.Name);
            system.assert(ctrl.isWBSRequired);
            system.assert(!ctrl.getRenderEditWbs());

            Test.stopTest();
        }
    }

    static testMethod void test_ReassignContract() {
        User cfarUser = [SELECT Id FROM User WHERE alias = 'testAvg' LIMIT 1];
        System.runAs(cfarUser) {
            CFAR_Trial_gne__c trial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];

            CFAR_Budget_Controller ctrl = new CFAR_Budget_Controller();
            CFAR_Team_Member_gne__c pi = [SELECT Id FROM CFAR_Team_Member_gne__c LIMIT 1];

            CFAR_Utils.setActualTrialId(trial.Id);
            System.assertEquals(trial.Id, ctrl.trial.Id);

            Test.startTest();
            system.assertEquals(2, ctrl.getInvestigatorOptions().size());
            ctrl.createNewContractTracking();

            system.assert(!ctrl.getContractTypes().isEmpty());
            system.assert(ctrl.hasNotDrugOnly);

            CFAR_Budget_Contract_Type_gne__c t = [select Id, Name from CFAR_Budget_Contract_Type_gne__c where Name = :Label.CFAR_GSTARS_CONTRACT_TRACKING_ORGINAL_TYPE limit 1];
            ctrl.currentContractTracking.Type_ref_gne__c = t.Id;
            ctrl.currentContractTracking.Type_ref_gne__r = t;

            ctrl.currentContractTracking.Amount_gne__c = 300000;
            ctrl.currentContractTracking.Contract_ID_gne__c = '1234';
            ctrl.currentContractTracking.Contract_Requested_Date__c = Date.Today();
            ctrl.currentContractTracking.Fully_Executed_Date_gne__c = System.today();
            ctrl.currentContractTracking.Contract_Expiry_Date_gne__c = System.today().addYears(3);
            ctrl.selectedInvestigator2 = pi;
            ctrl.submitContractTracking();
            ctrl.sortContractTrackings();
            ctrl.sortContractTrackings();

            System.assert(!ctrl.isContractTrackingError);
            System.assert(!ctrl.isError);
            System.assert(String.isBlank(ctrl.errorMessage));
            System.assertNotEquals(null, ctrl.PAYMENT_VALIDATION_MESSAGE);

            System.assertEquals(2, ctrl.getInvestigatorToReassign().size()); //there is also "--None--" option

            ctrl.editContractAssignment();
            ctrl.selectedInvestigatorToReassign = pi.Id;
            ctrl.reassignContract();
            System.assert(!ctrl.isAssignmentError);
            System.assertEquals(pi.id, ctrl.selectedInvestigatorId);
            System.assertEquals(pi.id, ctrl.selectedInvestigator2.Id);

            Test.stopTest();
        }
    }

    static testMethod void test_ReassignContractFailed() {
        User cfarUser = [SELECT Id FROM User WHERE alias = 'testAvg' LIMIT 1];
        System.runAs(cfarUser) {

            CFAR_Trial_gne__c trial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];
            CFAR_Utils.setActualTrialId(trial.Id);
            CFAR_Budget_Controller ctrl = new CFAR_Budget_Controller();

            Test.startTest();

            ctrl.createNewContractTracking();
            CFAR_Budget_Contract_Type_gne__c t = [select Id, Name from CFAR_Budget_Contract_Type_gne__c where Name = :Label.CFAR_GSTARS_CONTRACT_TRACKING_ORGINAL_TYPE limit 1];
            ctrl.currentContractTracking.Type_ref_gne__c = t.Id;
            ctrl.currentContractTracking.Type_ref_gne__r = t;

            ctrl.currentContractTracking.Amount_gne__c = 300000;
            ctrl.currentContractTracking.Contract_ID_gne__c = '1234';
            ctrl.currentContractTracking.Contract_Requested_Date__c = Date.Today();
            ctrl.currentContractTracking.Fully_Executed_Date_gne__c = System.today();
            ctrl.currentContractTracking.Contract_Expiry_Date_gne__c = System.today().addYears(3);
            CFAR_Team_Member_gne__c member = [SELECT Id FROM CFAR_Team_Member_gne__c LIMIT 1];
            ctrl.selectedInvestigator2 = member;
            ctrl.submitContractTracking();

            System.assert(!ctrl.isContractTrackingError);
            System.assert(!ctrl.isError);
            System.assert(String.isBlank(ctrl.errorMessage));

            System.assertEquals(2, ctrl.getInvestigatorToReassign().size());

            ctrl.editContractAssignment();
            ctrl.selectedInvestigatorToReassign = '--None--';
            ctrl.reassignContract();

            Test.stopTest();
            System.assert(ctrl.isAssignmentError);
        }
    }

    static testMethod void test_budgetSortExpression() {
        User cfarUser = [SELECT Id FROM User WHERE alias = 'testAvg' LIMIT 1];
        System.runAs(cfarUser) {

            Test.startTest();

            CFAR_Budget_Controller ctrl = new CFAR_Budget_Controller();
            System.assertEquals('CreatedDate', ctrl.budgetSortExpression);
            System.assertEquals(null, ctrl.budgetSortDirection);
            ctrl.budgetsortExpression = 'Name';
            System.assertEquals('Name', ctrl.budgetSortExpression);
            System.assertEquals('desc', ctrl.budgetSortDirection);
            ctrl.budgetsortExpression = 'Name';
            System.assertEquals('Name', ctrl.budgetSortExpression);
            System.assertEquals('asc', ctrl.budgetSortDirection);

            ctrl.budgetsortExpression = 'Amount_gne__c';
            System.assertEquals('Amount_gne__c', ctrl.budgetSortExpression);
            System.assertEquals('desc', ctrl.budgetSortDirection);

            Test.stopTest();
        }
    }

    static testMethod void test_fillCov() {
        User cfarUser = [SELECT Id FROM User WHERE alias = 'testAvg' LIMIT 1];
        System.runAs(cfarUser) {

            Test.startTest();

            CFAR_Trial_gne__c trial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];
            CFAR_Utils.setActualTrialId(trial.Id);
            CFAR_Budget_Controller ctrl = new CFAR_Budget_Controller();
            // This is cruacial and normally is called from CFAR_Trial.page
            System.assertNotEquals(null, ctrl.AMOUNT_LEFT_TO_PROJECT_PROJECTIONS_ERROR);
            System.assert(ctrl.getWBSUnsetOrRequested());
            System.assertEquals(2, ctrl.getInvestigatorsOptionsReport().size());
            System.assert(!ctrl.showPaymentWillLockWithholdTypePopup);
            System.assert(!ctrl.showRTWillLockWithholdTypePopup);

            ctrl.sortContractTrackings();
            ctrl.sortContractTrackings();

            ctrl.sortRateTables();
            ctrl.sortRateTables();

            ctrl.sortProjections();
            ctrl.sortProjections();

            ctrl.sortPaymentSchedule();
            ctrl.sortPaymentSchedule();

            Test.stopTest();
        }
    }

    static testMethod void unitTest_PaymentsRefund() {
        User cfarUser = [SELECT Id FROM User WHERE alias = 'testAvg' LIMIT 1];
        System.runAs(cfarUser) {

            CFAR_Trial_gne__c trial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];
            CFAR_Utils.setActualTrialId(trial.Id);
            CFAR_Budget_Controller ctrl = new CFAR_Budget_Controller();
            ctrl.currentPaymentSchedule = new CFAR_Budget_CPS_Payments_gne__c(name='testPayment');

            Test.startTest();
            //Orginal Contract
            ctrl.createNewContractTracking();
            system.assert(!ctrl.getContractTypes().isEmpty());
            system.assert(!ctrl.getPaymentScheduleStatuses().isEmpty());
            system.assert(ctrl.hasNotDrugOnly);
            String originalType = Label.CFAR_GSTARS_CONTRACT_TRACKING_ORGINAL_TYPE;
            CFAR_Budget_Contract_Type_gne__c t = [select Id, Name from CFAR_Budget_Contract_Type_gne__c 
                        where Name = :originalType limit 1];
            ctrl.currentContractTracking.Type_ref_gne__c = t.Id;
            ctrl.currentContractTracking.Type_ref_gne__r = t;
            
            Decimal contractAmount = 200000;
            Date executedDate = System.today();
            Date expiryDate = executedDate.addYears(3);
            ctrl.currentContractTracking.Amount_gne__c = contractAmount;
            ctrl.currentContractTracking.Contract_Requested_Date__c = Date.Today();
            ctrl.currentContractTracking.Contract_ID_gne__c = '1234';
            ctrl.currentContractTracking.Fully_Executed_Date_gne__c = executedDate;
            ctrl.currentContractTracking.Contract_Expiry_Date_gne__c = expiryDate;
            CFAR_Team_Member_gne__c member = [SELECT Id FROM CFAR_Team_Member_gne__c LIMIT 1];
            ctrl.selectedInvestigator2 = member;
            ctrl.submitContractTracking();
            system.assert(ctrl.trial.Is_Budget_Straight_Line__c);
            System.assertEquals(contractAmount, ctrl.selectedInvestigatorContract.Amount_Left_to_Project_gne__c);
            
            Id budgetContractId = ctrl.currentContractTracking.Budget_Contract_ref_gne__c;

            system.assert(!ctrl.isError);
            system.assert(String.isBlank(ctrl.errorMessage));
            
            CFAR_Budget_CPS_Projection_gne__c[] projs = ctrl.getProjections();
            system.assert(!projs.isEmpty());
            List<SelectOption> paymentExplanations = ctrl.getPaymentExplanations();
            List<SelectOption> paymentStatuses = ctrl.getPaymentScheduleStatuses();

            Decimal invAmount = 50000;
            //create payment with paid status
            ctrl.createNewPaymentSchedule();
            ctrl.currentPaymentSchedule.Payment_Explanation_Text_gne__c = paymentExplanations.get(1).getValue();
            ctrl.currentPaymentSchedule.Planned_Date_gne__c = System.today();
            ctrl.currentPaymentSchedule.Planned_Amount_gne__c = 2 * invAmount;
            CFAR_Payment_Schedule_Status_gne__c InvoiceSubmittedStatus = [select Id from CFAR_Payment_Schedule_Status_gne__c where Name = 'Invoice Submitted' limit 1];
            ctrl.currentPaymentSchedule.Payment_Status_ref_gne__c = InvoiceSubmittedStatus.Id;
            ctrl.currentPaymentSchedule.Invoice_gne__c = '1';
            ctrl.onPlannedDateChanged();
            ctrl.paymentStatusChanged();
            ctrl.currentPaymentSchedule.Invoice_Date_gne__c = System.today();
            ctrl.currentPaymentSchedule.Invoice_Submitted_Date_gne__c = System.today();
            ctrl.currentPaymentSchedule.Check_Number_gne__c = Decimal.valueOf(12334);
            ctrl.currentPaymentSchedule.Check_Num_gne__c = '12334';
            ctrl.onCheckChanged();
            ctrl.currentPaymentSchedule.Paid_On_gne__c = System.today();
            ctrl.onPaindOnChanged();
            ctrl.currentPaymentSchedule.Invoice_Amount_gne__c = 2 * invAmount;
            System.assertEquals(1, ctrl.getPaymentInvestigatorsOptions().size());
            ctrl.submitPaymentSchedule();
            System.debug('#Errors#: '+ctrl.getPaymentErrors());
            //check for amount left to project
            System.assertEquals(contractAmount - 2 * invAmount, ctrl.selectedInvestigatorContract.Amount_Left_to_Project_gne__c);
            CFAR_Budget_Utils.setAlreadyProcessedPayment(false);

            //create payment with refund status
            ctrl.createNewPaymentSchedule();
            ctrl.currentPaymentSchedule.Payment_Explanation_Text_gne__c = paymentExplanations.get(1).getValue();
            CFAR_Payment_Schedule_Status_gne__c refundStatus = [select Id from CFAR_Payment_Schedule_Status_gne__c where Name = 'Refund' limit 1];
            ctrl.currentPaymentSchedule.Payment_Status_ref_gne__c = refundStatus.Id;
            ctrl.paymentStatusChanged();
            ctrl.currentPaymentSchedule.Invoice_Date_gne__c = System.today();
            ctrl.currentPaymentSchedule.Invoice_Submitted_Date_gne__c = System.today();
            ctrl.currentPaymentSchedule.Paid_On_gne__c = System.today();
            ctrl.currentPaymentSchedule.Invoice_Amount_gne__c = invAmount;
            ctrl.currentPaymentSchedule.Comments_gne__c = 'test Refund';
            System.assertEquals(1, ctrl.getPaymentInvestigatorsOptions().size());
            ctrl.submitPaymentSchedule();
            System.debug('#Errors#: '+ctrl.getPaymentErrors());
            //check for amount left to project
            System.assertEquals(contractAmount - invAmount, ctrl.selectedInvestigatorContract.Amount_Left_to_Project_gne__c);

            CFAR_Budget_CPS_Payments_gne__c refundPayment = [select Invoice_Amount_gne__c FROM CFAR_Budget_CPS_Payments_gne__c 
                    where Budget_Contract_ref_gne__r.Team_Member_ref_gne__c = :member.Id
                    AND Payment_Status_ref_gne__c = :refundStatus.Id];
            // check if refund was saved with negative amount
            System.assertEquals(-invAmount, refundPayment.Invoice_Amount_gne__c);
            CFAR_Budget_Utils.setAlreadyProcessedPayment(false);
            
            // check if refund was selected from repo with positive amount
            ctrl.paymentScheduleId = refundPayment.Id;
            ctrl.editPaymentSchedule();
            system.assertEquals(invAmount, ctrl.currentPaymentSchedule.Invoice_Amount_gne__c);

            //find Refund on the list
            CFAR_Budget_CPS_Payments_gne__c checkRefundPayment = null;
            for(CFAR_Budget_CPS_Payments_gne__c payment : ctrl.getPayments()) {
                if (payment.Payment_Status_ref_gne__r.Name.equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_REFUND_STATUS)) {
                    checkRefundPayment = payment;
                }
            }
            //check if there is Refund payment on the payments list
            System.assertNotEquals(null, checkRefundPayment);
            //and if it's properly saved
            System.assertEquals(-invAmount, checkRefundPayment.Invoice_Amount_gne__c);

            Test.stopTest();
        }
    }

    static testMethod void getBudgetMainErrorMessages_ShouldThrowMessageIfOldPiHasContracts() {
        User cfarUser = [SELECT Id FROM User WHERE alias = 'testAvg' LIMIT 1];
        System.runAs(cfarUser) {
            //GIVEN
            CFAR_Trial_gne__c trial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];
            CFAR_Team_Member_gne__c oldPi = [SELECT Id FROM CFAR_Team_Member_gne__c LIMIT 1];
            CFAR_Budget_Contract_gne__c bc = new CFAR_Budget_Contract_gne__c(Team_Member_ref_gne__c = oldPi.Id);
            insert bc;
            oldPi.Inactive_On_gne__c = System.Today();
            update oldPi;

            CFAR_DataFactory.TeamMemberWithOrgInstAddrAggregate teamMemberStr = new CFAR_DataFactory.TeamMemberWithOrgInstAddrAggregate(trial);
            teamMemberStr.createTeamMemberWithRandomStructure();
            CFAR_Team_Member_gne__c newPi = [SELECT Id FROM CFAR_Team_Member_gne__c WHERE Function_Role_gne__c = : CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR AND Id != :oldPi.Id LIMIT 1];

            CFAR_Budget_Controller ctrl = new CFAR_Budget_Controller();
            CFAR_Utils.setActualTrialId(trial.Id);

            //WHEN
            ctrl.selectedInvestigator2 = newPi;
            List<String> errorMesagess = ctrl.getBudgetMainErrorMessages();

            //THEN
            System.assertEquals(Label.CFAR_REASSIGN_CONTRACT, errorMesagess[0],
            'Should throw error message if user is reassigning PI, and old PI has contracts');
        }
    }

    static testMethod void getBudgetMainErrorMessages_ShouldThrowMessageIfContractNotEqualPayments() {
        User cfarUser = [SELECT Id FROM User WHERE alias = 'testAvg' LIMIT 1];
        System.runAs(cfarUser) {
            //GIVEN
            CFAR_Trial_gne__c trial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];
            CFAR_Team_Member_gne__c oldPi = [SELECT Id FROM CFAR_Team_Member_gne__c LIMIT 1];
            CFAR_Budget_Contract_gne__c bc = new CFAR_Budget_Contract_gne__c(Team_Member_ref_gne__c = oldPi.Id, Total_Payments_gne__c = 20);
            insert bc;
            CFAR_Budget_Controller ctrl = new CFAR_Budget_Controller();
            CFAR_Utils.setActualTrialId(trial.Id);

            //WHEN
            ctrl.createNewContractTracking();
            String plannedType = Label.CFAR_GSTARS_CONTRACT_TRACKING_PLANNED_TYPE;
            CFAR_Budget_Contract_Type_gne__c t = [select Id, Name from CFAR_Budget_Contract_Type_gne__c
            where Name = :plannedType limit 1];
            ctrl.currentContractTracking.Type_ref_gne__c = t.Id;
            ctrl.currentContractTracking.Type_ref_gne__r = t;

            Date executedDate = System.today();
            Date expiryDate = executedDate.addYears(3);
            ctrl.currentContractTracking.Amount_gne__c = 200000;
            ctrl.currentContractTracking.Fully_Executed_Date_gne__c = executedDate;
            ctrl.currentContractTracking.Contract_Expiry_Date_gne__c = expiryDate;
            ctrl.currentContractTracking.Contract_ID_gne__c = '1234';
            List<String> errorMesagess = ctrl.getBudgetMainErrorMessages();

            //THEN
            System.assertEquals(Label.CFAR_GSTARS_TOTAL_PAYMENTS_NOT_EQUAL_CONTRACT, errorMesagess[0],
            'Should throw error message if total payments is not equal to contract Amount');
        }
    }

    static testMethod void getBudgetMainErrorMessages_ShouldThrowMessageIfInactiveInvestigator() {
        User cfarUser = [SELECT Id FROM User WHERE alias = 'testAvg' LIMIT 1];
        System.runAs(cfarUser) {
            //GIVEN
            CFAR_Trial_gne__c trial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];
            CFAR_Team_Member_gne__c oldPi = [SELECT Id FROM CFAR_Team_Member_gne__c LIMIT 1];
            oldPi.Inactive_On_gne__c = System.Today();
            update oldPi;
            CFAR_Budget_Contract_gne__c bc = new CFAR_Budget_Contract_gne__c(Team_Member_ref_gne__c = oldPi.Id, Total_Payments_gne__c = 20);
            insert bc;
            CFAR_Budget_Controller ctrl = new CFAR_Budget_Controller();
            CFAR_Utils.setActualTrialId(trial.Id);

            //WHEN
            ctrl.createNewContractTracking();
            List<String> errorMesagess = ctrl.getBudgetMainErrorMessages();

            //THEN
            System.assertEquals(Label.CFAR_INVESTIGATOR_VENDOR_IS_NOT_ACTIVE, errorMesagess[1],
            'Should throw error if Selected investigator is not active');
        }
    }

    static testMethod void getIsUserReadOnly() {
        User readOnlyUser = [SELECT Id FROM User WHERE alias = 'testRO' LIMIT 1];
        System.runAs(readOnlyUser) {
            CFAR_Budget_Controller ctrl = new CFAR_Budget_Controller();
            Boolean isReadOnly = ctrl.getIsUserReadOnly();
            System.assertEquals(true, isReadOnly);
        }
    }

    static testMethod void savePoNumber_shouldSavePoNumber(){
        User cfarUser = [SELECT Id FROM User WHERE alias = 'testAvg' LIMIT 1];
        System.runAs(cfarUser) {
            CFAR_Trial_gne__c trial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];
            CFAR_Utils.setActualTrialId(trial.Id);
            CFAR_Budget_Controller ctrl = new CFAR_Budget_Controller();
            ctrl.currentPaymentSchedule = new CFAR_Budget_CPS_Payments_gne__c(name = 'testPayment');
            Test.startTest();
            ctrl.createNewContractTracking();
            String originalType = Label.CFAR_GSTARS_CONTRACT_TRACKING_ORGINAL_TYPE;
            CFAR_Budget_Contract_Type_gne__c t = [select Id, Name from CFAR_Budget_Contract_Type_gne__c
            where Name = :originalType limit 1];
            ctrl.currentContractTracking.Type_ref_gne__c = t.Id;
            ctrl.currentContractTracking.Type_ref_gne__r = t;
            ctrl.currentContractTracking.Amount_gne__c = 200000;
            ctrl.currentContractTracking.Contract_Requested_Date__c = Date.Today();
            ctrl.currentContractTracking.Contract_ID_gne__c = '1234';
            ctrl.currentContractTracking.Fully_Executed_Date_gne__c = System.today();
            ctrl.currentContractTracking.Contract_Expiry_Date_gne__c = System.today().addYears(3);
            ctrl.submitContractTracking();

            //WHEN
            ctrl.poNumberValue = '1231231231223';
            ctrl.savePoNumber();

            //THEN
            System.assertEquals(false, ctrl.poNumberCorrect, 'Should throw exception if PO number is too long.');

            //WHEN
            ctrl.poNumberValue = '123456789';
            ctrl.savePoNumber();

            //THEN
            System.assertEquals(true, ctrl.poNumberCorrect, 'Should not throw exception if PO number is less than 10 characters long.');
            CFAR_Budget_Contract_gne__c updatedContract = [SELECT Po_Number_gne__c FROM CFAR_Budget_Contract_gne__c LIMIT 1];
            System.assertEquals('123456789', updatedContract.Po_Number_gne__c, 'Should update PO Number');
        }
    }
}