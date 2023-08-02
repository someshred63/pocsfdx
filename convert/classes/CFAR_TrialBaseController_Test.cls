@IsTest
private class CFAR_TrialBaseController_Test {

    @TestSetup
    private static void setup() {
        CFAR_TestUtils.createProfileUsers(new List<String>{'GNE-CFAR-User-New', 'GNE-CFAR-IT-Admin-New', 'GNE-CFAR-Admin-New', 'GNE-CFAR-ReadOnlyUser-New'});
    }

    @IsTest
    static void shouldCheckIsTrialNotAvailable() {
        CFAR_TrialBaseController ctrl = new CFAR_TrialBaseController();
        ctrl.trial = new CFAR_Trial_gne__c();
        System.assertEquals(false, ctrl.trialNotAvailable);

        ctrl.trial = null;
        ApexPages.currentPage().getParameters().put('id', 'testId');
        System.assertEquals(true, ctrl.trialNotAvailable);
    }

    @IsTest
    static void shouldPrintTrialName() {
        CFAR_TrialBaseController ctrl = new CFAR_TrialBaseController();
        ctrl.trial = null;
        System.assertEquals('Trial has no name ', ctrl.printTrialName());
        ctrl.trial = new CFAR_Trial_gne__c(Name = 'TestName');
        System.assertEquals('TestName', ctrl.printTrialName());
    }

    @IsTest
    static void shouldGetTrialWrapper() {
        CFAR_TrialBaseController ctrl = new CFAR_TrialBaseController();
        ctrl.trialWrapper = null;
        System.assertNotEquals(null, ctrl.getTrialWrapper());

        CFAR_Trial_gne__c trial = CFAR_DataFactory.createTrial(0);
        insert trial;
        ctrl.trialWrapper.innerObject = trial;
        CFAR_TrialWrapper results = ctrl.getTrialWrapper();
        System.assertNotEquals(null, results);
        System.assertEquals(trial, results.innerObject);
        System.assertEquals(trial.Id, CFAR_Utils.getActualTrialId());

        CFAR_Trial_gne__c trial2 = CFAR_DataFactory.createTrial(0);
        insert trial2;
        CFAR_Utils.setActualTrialId(trial2.Id);
        ctrl.isFromTab = true;
        results = ctrl.getTrialWrapper();
        System.assertNotEquals(null, results);
        System.assertEquals(trial2.Id, CFAR_Utils.getActualTrialId());
        System.assertEquals(trial2.Id, results.innerObject.Id);
        System.assertEquals(false, ctrl.editMode);
        System.assertEquals(trial2.Id, ctrl.oldTrialId);
    }

    @IsTest
    private static void shouldSetTrialWrapper() {
        CFAR_TrialBaseController ctrl = new CFAR_TrialBaseController();
        CFAR_Trial_gne__c trial = CFAR_DataFactory.createTrial(0);
        insert trial;
        CFAR_TrialWrapper wrapper = new CFAR_TrialWrapper();
        wrapper.innerObject = trial;
        wrapper.innerObject.Id = trial.Id;
        // when
        ctrl.setTrialWrapper(wrapper);
        // then
        System.assertEquals(false, ctrl.editMode);
        System.assertEquals(trial.Id, ctrl.oldTrialId);
        System.assertEquals(trial.Id, CFAR_Utils.getActualTrialId());
    }

    @IsTest
    private static void shouldInitController() {
        CFAR_Trial_gne__c trial = CFAR_DataFactory.createTrial(0);
        insert trial;
        ApexPages.currentPage().getParameters().put('id', trial.Id);
        // when
        CFAR_TrialBaseController ctrl = new CFAR_TrialBaseController();
        // then
        System.assertEquals(false, ctrl.editMode);
        System.assertEquals(false, ctrl.isFromTab);
        System.assertEquals(trial.Id, ctrl.trial.Id);
        System.assertEquals(0, ctrl.dollarAndDrugMap.size());
    }

    @IsTest
    private static void shouldInitControllerFromTab() {
        CFAR_TrialBaseController ctrl = new CFAR_TrialBaseController(true);
        System.assertEquals(true, ctrl.isFromTab);
    }

    @IsTest
    private static void shouldRefreshTrial() {
        CFAR_Trial_gne__c trial = CFAR_DataFactory.createTrial(0);
        insert trial;
        CFAR_TrialWrapper wrapper = new CFAR_TrialWrapper();
        wrapper.innerObject = trial;
        wrapper.innerObject.Id = trial.Id;

        CFAR_TrialBaseController ctrl = new CFAR_TrialBaseController();
        ctrl.setTrialWrapper(wrapper);
        ctrl.refreshTrial();
        System.assertEquals(trial.Id, ctrl.trial.Id);
    }

    @IsTest
    private static void shouldPrepareDollarAndDrugMap() {
        insert new CFAR_Dollar_and_Drug_gne__c(
                Active_gne__c = true
        );
        CFAR_TrialBaseController ctrl = new CFAR_TrialBaseController();
        ctrl.prepareDollarAndDrugMap();
        System.assertEquals(1, ctrl.dollarAndDrugMap.size());
    }

    @IsTest
    private static void shouldSave() {
        CFAR_Trial_gne__c trial = CFAR_DataFactory.createTrial(0);
        insert trial;
        CFAR_TrialWrapper wrapper = new CFAR_TrialWrapper();
        wrapper.innerObject = trial;
        wrapper.innerObject.Id = trial.Id;
        CFAR_TrialBaseController ctrl = new CFAR_TrialBaseController();
        ctrl.setTrialWrapper(wrapper);

        System.assertEquals(1, [SELECT count() FROM CFAR_Trial_gne__c WHERE Planned_Enrollment_gne__c = 100]);
        trial.Planned_Enrollment_gne__c = 99;
        ctrl.save();
        System.assertEquals(1, [SELECT count() FROM CFAR_Trial_gne__c WHERE Planned_Enrollment_gne__c = 99]);
    }

    @IsTest
    private static void shouldEdit() {
        CFAR_TrialBaseController ctrl = new CFAR_TrialBaseController();
        ctrl.edit();
        System.assertEquals(true, ctrl.editMode);
    }

    @IsTest
    private static void shouldCancel() {
        CFAR_TrialBaseController ctrl = new CFAR_TrialBaseController();
        PageReference res = ctrl.cancel();
        System.assertEquals(false, ctrl.editMode);
        System.assertEquals(null, res);
    }

    @IsTest
    private static void shouldGetRenderTrialClosedAndUserIsAdmin() {
        CFAR_Trial_Status_gne__c status = new CFAR_Trial_Status_gne__c(
                Name = 'Cancelled'
        );
        insert status;
        CFAR_Trial_gne__c trial = CFAR_DataFactory.createTrial(0);
        trial.Trial_Status_ref_gne__c = status.Id;
        insert trial;
        trial = [SELECT frm_Is_Closed_gne__c FROM CFAR_Trial_gne__c WHERE Id = :trial.Id];

        User admin = [SELECT Id FROM User WHERE Alias = 'testITAd' LIMIT 1];
        System.runAs(admin) {
            CFAR_TrialWrapper wrapper = new CFAR_TrialWrapper();
            wrapper.innerObject = trial;
            wrapper.innerObject.Id = trial.Id;
            CFAR_TrialBaseController ctrl = new CFAR_TrialBaseController();
            System.assertEquals(false, ctrl.getRenderTrialClosedAndUserIsAdmin());
            ctrl.setTrialWrapper(wrapper);
            System.assertEquals(true, ctrl.getRenderTrialClosedAndUserIsAdmin());
        }
    }

    @IsTest
    private static void shouldGetRenderTrialClosed() {
        CFAR_TrialBaseController ctrl = new CFAR_TrialBaseController();
        System.assertEquals(false, ctrl.getRenderTrialClosed());

        CFAR_Trial_Status_gne__c status = new CFAR_Trial_Status_gne__c(
                Name = 'Cancelled'
        );
        insert status;
        CFAR_Trial_gne__c trial = CFAR_DataFactory.createTrial(0);
        trial.Trial_Status_ref_gne__c = status.Id;
        insert trial;
        trial = [SELECT frm_Is_Closed_gne__c FROM CFAR_Trial_gne__c WHERE Id = :trial.Id];
        CFAR_TrialWrapper wrapper = new CFAR_TrialWrapper();
        wrapper.innerObject = trial;
        wrapper.innerObject.Id = trial.Id;
        ctrl.setTrialWrapper(wrapper);
        System.assertEquals(true, ctrl.getRenderTrialClosed());
    }

    @IsTest
    private static void shouldGetRerenderTrialClosedAndUserNotAdmin() {
        CFAR_Trial_Status_gne__c status = new CFAR_Trial_Status_gne__c(
                Name = 'Cancelled'
        );
        insert status;
        CFAR_Trial_gne__c trial = CFAR_DataFactory.createTrial(0);
        trial.Trial_Status_ref_gne__c = status.Id;
        insert trial;
        trial = [SELECT frm_Is_Closed_gne__c FROM CFAR_Trial_gne__c WHERE Id = :trial.Id];

        User noAdmin = [SELECT Id FROM User WHERE Alias = 'testAvg'];
        System.runAs(noAdmin) {
            CFAR_TrialWrapper wrapper = new CFAR_TrialWrapper();
            wrapper.innerObject = trial;
            wrapper.innerObject.Id = trial.Id;
            CFAR_TrialBaseController ctrl = new CFAR_TrialBaseController();
            System.assertEquals(false, ctrl.getRerenderTrialClosedAndUserNotAdmin());
            ctrl.setTrialWrapper(wrapper);
            System.assertEquals(true, ctrl.getRerenderTrialClosedAndUserNotAdmin());
        }
    }

    @IsTest
    private static void shouldGetIsReadOnlyOrAdminFixStatus() {
        CFAR_Trial_Status_gne__c status = new CFAR_Trial_Status_gne__c(
                Name = Label.CFAR_GSTARS_TRIAL_STATUS_ADMIN_FIX
        );
        insert status;
        CFAR_Trial_gne__c trial = CFAR_DataFactory.createTrial(0);
        trial.Trial_Status_ref_gne__c = status.Id;
        insert trial;
        trial = [SELECT frm_Trial_Status_ref_gne__c FROM CFAR_Trial_gne__c WHERE Id = :trial.Id];
        for (User u :[SELECT Id, Alias FROM User ORDER BY Alias]) {
            System.debug(u);
        }
        //System.debug([SELECT Id, Alias FROM User]);
        User readOnlyUsr = [SELECT Id FROM User WHERE Alias = 'testRO' LIMIT 1];
        System.runAs(readOnlyUsr) {
            CFAR_TrialWrapper wrapper = new CFAR_TrialWrapper();
            wrapper.innerObject = trial;
            wrapper.innerObject.Id = trial.Id;
            CFAR_TrialBaseController ctrl = new CFAR_TrialBaseController();
            System.assertEquals(true, ctrl.getIsReadOnlyOrAdminFixStatus());
            ctrl.setTrialWrapper(wrapper);
            System.assertEquals(true, ctrl.getIsReadOnlyOrAdminFixStatus());
        }
    }

    @IsTest
    private static void shouldGetIsAdminFixStatus() {
        CFAR_TrialBaseController ctrl = new CFAR_TrialBaseController();
        System.assertEquals(false, ctrl.getIsAdminFixStatus());

        CFAR_Trial_Status_gne__c status = new CFAR_Trial_Status_gne__c(
                Name = Label.CFAR_GSTARS_TRIAL_STATUS_ADMIN_FIX
        );
        insert status;
        CFAR_Trial_gne__c trial = CFAR_DataFactory.createTrial(0);
        trial.Trial_Status_ref_gne__c = status.Id;
        insert trial;
        trial = [SELECT frm_Trial_Status_ref_gne__c FROM CFAR_Trial_gne__c WHERE Id = :trial.Id];
        CFAR_TrialWrapper wrapper = new CFAR_TrialWrapper();
        wrapper.innerObject = trial;
        wrapper.innerObject.Id = trial.Id;
        ctrl.setTrialWrapper(wrapper);
        System.assertEquals(true, ctrl.getIsAdminFixStatus());
    }

}