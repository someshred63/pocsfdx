@IsTest
private class CFAR_EnrollmentWrapper_Test {

    @IsTest
    static void shouldGetIsFrozen() {
        CFAR_Trial_gne__c trial = CFAR_DataFactory.createTrial(0);
        trial.Frozen_Accruals_JSON_gne__c = '[2014,2015]';
        insert trial;
        CFAR_Actual_Enrollment_gne__c ae = new CFAR_Actual_Enrollment_gne__c();
        ae.CFAR_Trial_ref_gne__c = trial.Id;
        ae.Date_gne__c = Date.newInstance(2015, 1, 1);
        insert ae;
        ae = [SELECT Trials_Frozen_Accrual_Years_JSON_gne__c, Date_gne__c FROM CFAR_Actual_Enrollment_gne__c WHERE Id = :ae.Id];
        System.assert(new CFAR_EnrollmentWrapper(ae, true).getIsFrozen());
    }

    @IsTest
    static void shouldGetIsFrozen2() {
        CFAR_Actual_Enrollment_gne__c ae = new CFAR_Actual_Enrollment_gne__c();
        System.assert(!new CFAR_EnrollmentWrapper(ae, true).getIsFrozen());
    }

    @IsTest
    static void shouldGetIsFrozen3() {
        CFAR_Trial_gne__c trial = CFAR_DataFactory.createTrial(0);
        trial.Frozen_Accruals_JSON_gne__c = '[2014,2015]';
        insert trial;
        CFAR_Actual_Enrollment_gne__c ae = new CFAR_Actual_Enrollment_gne__c();
        ae.CFAR_Trial_ref_gne__c = trial.Id;
        insert ae;
        ae = [SELECT Trials_Frozen_Accrual_Years_JSON_gne__c, Date_gne__c FROM CFAR_Actual_Enrollment_gne__c WHERE Id = :ae.Id];
        System.assert(!new CFAR_EnrollmentWrapper(ae, true).getIsFrozen());
    }
}