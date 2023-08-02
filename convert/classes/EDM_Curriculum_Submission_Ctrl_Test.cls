@isTest
private class EDM_Curriculum_Submission_Ctrl_Test {

    @testSetup
    private static void setupData() { 
        insert new Speaker_Bureau_gne__c(Name = 'TestBureau');
        insert new EDM_SBM_Brand_To_Indications_gne__c(Name = 'Avastin');
        List<EDM_Curriculum_Target_Audience_gne__c> CurriculumTargetAudienceToInsert = new List<EDM_Curriculum_Target_Audience_gne__c>();
        CurriculumTargetAudienceToInsert.add(new EDM_Curriculum_Target_Audience_gne__c(Name = 'Patient / Consumer', 
                                        Target_Audience_gne__c='Patient / Consumer',
                                        Order_gne__c=1));
        CurriculumTargetAudienceToInsert.add(new EDM_Curriculum_Target_Audience_gne__c(Name = 'Physician', 
                                        Target_Audience_gne__c='Physician',
                                        Order_gne__c=2));
        CurriculumTargetAudienceToInsert.add(new EDM_Curriculum_Target_Audience_gne__c(Name = 'Pharmacist', 
                                        Target_Audience_gne__c='Pharmacist',
                                        Order_gne__c=3));
        CurriculumTargetAudienceToInsert.add(new EDM_Curriculum_Target_Audience_gne__c(Name = 'Nurse', 
                                        Target_Audience_gne__c='Nurse',
                                        Order_gne__c=4));
        CurriculumTargetAudienceToInsert.add(new EDM_Curriculum_Target_Audience_gne__c(Name = 'Payers', 
                                        Target_Audience_gne__c='Payers',
                                        Order_gne__c=5));
        CurriculumTargetAudienceToInsert.add(new EDM_Curriculum_Target_Audience_gne__c(Name = 'Managed Market', 
                                        Target_Audience_gne__c='Managed Market',
                                        Order_gne__c=6));
        CurriculumTargetAudienceToInsert.add(new EDM_Curriculum_Target_Audience_gne__c(Name = 'Patient Organization/Charities', 
                                        Target_Audience_gne__c='Patient Organization/Charities',
                                        Order_gne__c=7));
        CurriculumTargetAudienceToInsert.add(new EDM_Curriculum_Target_Audience_gne__c(Name = 'Access decision makers', 
                                        Target_Audience_gne__c='Access decision makers',
                                        Order_gne__c=8));
        CurriculumTargetAudienceToInsert.add(new EDM_Curriculum_Target_Audience_gne__c(Name = 'Healthcare/Regulatory Authority', 
                                        Target_Audience_gne__c='Healthcare/Regulatory Authority',
                                        Order_gne__c=9));
        CurriculumTargetAudienceToInsert.add(new EDM_Curriculum_Target_Audience_gne__c(Name = 'Allied Health care professionals', 
                                        Target_Audience_gne__c='Allied Health care professionals',
                                        Order_gne__c=10));
        CurriculumTargetAudienceToInsert.add(new EDM_Curriculum_Target_Audience_gne__c(Name = 'Media', 
                                        Target_Audience_gne__c='Media',
                                        Order_gne__c=11));
        CurriculumTargetAudienceToInsert.add(new EDM_Curriculum_Target_Audience_gne__c(Name = 'General Public', 
                                        Target_Audience_gne__c='General Public',
                                        Order_gne__c=12));
        CurriculumTargetAudienceToInsert.add(new EDM_Curriculum_Target_Audience_gne__c(Name = 'Internal Only', 
                                        Target_Audience_gne__c='Internal Only',
                                        Order_gne__c=13));
        CurriculumTargetAudienceToInsert.add(new EDM_Curriculum_Target_Audience_gne__c(Name = 'Practice Manager (HCP)', 
                                        Target_Audience_gne__c='Practice Manager (HCP)',
                                        Order_gne__c=14));
        insert CurriculumTargetAudienceToInsert;    
    }

    @isTest
    private static void insertNewCurriculumTest() {
        String prcCode = 'Test_PRC_1';

        Test.startTest();
        EDM_Curriculum_Submission_Ctrl ctrl = getPopulatedController(prcCode);
        ctrl.validateBeforeSave();
        ctrl.save();
        Test.stopTest();

        List<Event_Curriculum_gne__c> curriculums = [SELECT Name, Aprimo_ID_gne__c FROM Event_Curriculum_gne__c];
        String firstErr = (ApexPages.hasMessages() ? ApexPages.getMessages()[0].getSummary() : '');

        System.assertEquals('', firstErr);
        System.assertEquals(1, curriculums.size());
        System.assertEquals(prcCode, curriculums.get(0).Aprimo_ID_gne__c);
    }

    @isTest
    private static void cancelSubmissionTest() {
        Test.startTest();
        EDM_Curriculum_Submission_Ctrl ctrl = getPopulatedController('Test_PRC_1');
        ctrl.replacing = 'PRC_2';
        ctrl.title = 'Description';  
        ctrl.cancel();
        Test.stopTest();

        System.assert(String.isBlank(ctrl.approvalDate));
        System.assertEquals(null, ctrl.selectedBrandsAndIndications);
        System.assert(String.isBlank(ctrl.bureauId));
        System.assert(String.isBlank(ctrl.prcCode));
        System.assert(String.isBlank(ctrl.replacing));
        System.assert(String.isBlank(ctrl.systemTitle));
        System.assertEquals('Select', ctrl.retraining);
        System.assertEquals(0, ctrl.selectedTargetAudiences.size());
        System.assert(String.isBlank(ctrl.title));
        System.assert(String.isBlank(ctrl.materialPresentationField.value));
    }

    @isTest
    private static void submitCurriculumWithWrongValuesTest() {
        Test.startTest();
        EDM_Curriculum_Submission_Ctrl ctrl = new EDM_Curriculum_Submission_Ctrl();
        ctrl.approvalDate = '99/1764/13';
        ctrl.validateBeforeSave();
        ctrl.save();
        Test.stopTest();

        List<Event_Curriculum_gne__c> curriculums = [SELECT Name FROM Event_Curriculum_gne__c];

        System.assertEquals(0, curriculums.size());
        System.assert(ApexPages.hasMessages());
        System.assertEquals(9, ApexPages.getMessages().size());
    }

    @isTest
    private static void replaceOtherCurriculumTest() {
        String prcCode_replaced = 'PRC_OLD';
        String prcCode_replacing = 'PRC_NEW';
        insert new Event_Curriculum_gne__c(Aprimo_ID_gne__c = prcCode_replaced);

        Test.startTest();
        EDM_Curriculum_Submission_Ctrl ctrl = getPopulatedController(prcCode_replacing);
        ctrl.replacing = prcCode_replaced;
        ctrl.validateBeforeSave();
        ctrl.save();
        Test.stopTest();

        Event_Curriculum_gne__c replacedEvent = [SELECT Id, Replaced_By_Curr_gne__c FROM Event_Curriculum_gne__c WHERE Aprimo_ID_gne__c = :prcCode_replaced];
        Event_curriculum_gne__c replacingEvent = [SELECT Id, Replacing_Curr_gne__c FROM Event_Curriculum_gne__c WHERE Aprimo_ID_gne__c = :prcCode_replacing];

        System.assertEquals(replacingEvent.Id, replacedEvent.Replaced_By_Curr_gne__c);
        System.assertEquals(replacedEvent.Id, replacingEvent.Replacing_Curr_gne__c );
    }

    private static EDM_Curriculum_Submission_Ctrl getPopulatedController(String prcCode) {
        EDM_Curriculum_Submission_Ctrl ctrl = new EDM_Curriculum_Submission_Ctrl();
        ctrl.approvalDate = Date.today().format();
       // ctrl.selectedBrandsAndIndications = new Map<String, List<String>>();
        ctrl.jsonResult = '{"Avastin":["Cercival Cancer", "GBM", "mCRC"]}';
       // ctrl.selectedBrandsAndIndications.put('Avastin', new List<String>{'Cercival Cancer', 'GBM', 'mCRC'});
        ctrl.bureauId = [SELECT Aprimo_Bureau_ID_gne__c FROM Speaker_Bureau_gne__c LIMIT 1].Aprimo_Bureau_ID_gne__c;
        ctrl.prcCode = prcCode;
        ctrl.replacing = '';
        ctrl.retraining = ctrl.retrainingOptions.get(2).getValue();
        ctrl.selectedTargetAudiences.add(ctrl.targetAudiences.get(2));
        ctrl.systemTitle = 'CurrTestName';
        ctrl.materialPresentationField.value = ctrl.materialPresentationField.picklistValues.get(1).getValue();

        return ctrl;
    }
}