@isTest
private class CFAR_TrialTrigger_Test {

    @testSetup
    static void setup() {
        CFAR_Specific_Indication_gne__c initialSpecificIndication = CFAR_TestUtils.createSpecificIndication('initialSpecInd');
        CFAR_General_Indication_gne__c initialGeneralIndication = CFAR_TestUtils.createGeneralIndication('initialGeneralInd');

        CFAR_Product_gne__c product1 = new CFAR_Product_gne__c();
        product1.Name =  'Accutane';
        product1.Generic_Name_gne__c = 'generic';
        product1.Abbreviation_gne__c = 'ACC';

        CFAR_Product_gne__c product2 = new CFAR_Product_gne__c();
        product2.Name =  'NewProduct';
        product2.Generic_Name_gne__c = 'generic';
        product2.Abbreviation_gne__c = 'NPD';
        insert new List<CFAR_Product_gne__c> {product1, product2};

        CFAR_Trial_gne__c trial = CFAR_DataFactory.createTrial(0);
        trial.CTMS_gne__c = '09876';
        trial.Other_Trial_gne_Id__c = '09983';
        trial.Specific_Indication_Multi_gne__c = initialSpecificIndication.Id;
        trial.General_Indication_Multi_gne__c = initialGeneralIndication.Id;
        trial.Other_GNE_Agents_Multi_gne__c = product1.Id;

        insert trial;

        CFAR_Trial_Other_GNE_Agent_gne__c trialOtherGNEAgent = CFAR_DataFactory.createTrialOtherAgent(trial, product1);
        insert trialOtherGNEAgent;
        System.assert(true);
    }
    static testMethod void testTrialInsert() {
    	CFAR_Trial_gne__c trial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];
        
        List<CFAR_Milestone_Activity_gne__c> mAct = [
        	SELECT CFAR_Trial_ref_gne__c, Id, Name
        	FROM CFAR_Milestone_Activity_gne__c
        	WHERE CFAR_Trial_ref_gne__c = :trial.Id
        ];
        
        List<CFAR_Team_Member_gne__c> teamMembers = [
        	SELECT CFAR_Trial_ref_gne__c, Id, Name
        	FROM CFAR_Team_Member_gne__c
        	WHERE CFAR_Trial_ref_gne__c = :trial.Id
        ];
        
        List<CFAR_General_Indication_for_Trial_gne__c> genInd = [
        	SELECT CFAR_Trial_ref_gne__c, Id
        	FROM CFAR_General_Indication_for_Trial_gne__c
        	WHERE CFAR_Trial_ref_gne__c = :trial.Id
        ];
        
        List<CFAR_Specific_Indication_for_Trial_gne__c> specInd = [
        	SELECT CFAR_Trial_ref_gne__c, Id
        	FROM CFAR_Specific_Indication_for_Trial_gne__c
        	WHERE CFAR_Trial_ref_gne__c = :trial.Id
        ];
        
        System.assertNotEquals(null, mAct);
        System.assertNotEquals(null, teamMembers);
        System.assertNotEquals(null, genInd);
        System.assertNotEquals(null, specInd);
    }

    static testMethod void handleSpecificIndicationsChanged_ShouldCreateSpecificIndicationForTrial() {
        //GIVEN
        CFAR_Trial_gne__c trial = [SELECT Specific_Indication_Multi_gne__c FROM CFAR_Trial_gne__c LIMIT 1];
        CFAR_Specific_Indication_gne__c specificIndication1 = CFAR_DataFactory.createSpecificIndication('newSpecificIndication');
        CFAR_Specific_Indication_gne__c specificIndication2 = CFAR_DataFactory.createSpecificIndication('newSpecificIndication2');
        insert new List<CFAR_Specific_Indication_gne__c> {specificIndication1, specificIndication2};

        //WHEN
        Id existingSpecificIndToTrialId = [SELECT Id FROM CFAR_Specific_Indication_for_Trial_gne__c WHERE CFAR_Trial_ref_gne__c = :trial.Id].Id;
        trial.Specific_Indication_Multi_gne__c = specificIndication1.Id + ';' + specificIndication2.Id;
        update trial;

        //THEN
        integer oldSpecificIndToTrialCount = [SELECT Count() FROM CFAR_Specific_Indication_for_Trial_gne__c WHERE Id = :existingSpecificIndToTrialId];
        System.assertEquals(0, oldSpecificIndToTrialCount, 
            'When Specific_Indication_Multi_gne__c updated on Trial, should remove old CFAR_Specific_Indication_for_Trial_gne__c records');

        System.assertEquals(2, [SELECT COUNT() FROM CFAR_Specific_Indication_for_Trial_gne__c WHERE CFAR_Trial_ref_gne__c = :trial.Id], 
            'When Specific_Indication_Multi_gne__c updated on Trial with 2 specific indications, should create new CFAR_Specific_Indication_for_Trial_gne__c records related to that trial');
    }

    static testMethod void handleGeneralIndicationsChanged_ShouldCreateGeneralIndicationForTrial() {
        //GIVEN
        CFAR_Trial_gne__c trial = [SELECT General_Indication_Multi_gne__c FROM CFAR_Trial_gne__c LIMIT 1];
        CFAR_General_Indication_gne__c generalIndication1 = CFAR_TestUtils.createGeneralIndication('newGeneralIndication');
        CFAR_General_Indication_gne__c generalIndication2 = CFAR_TestUtils.createGeneralIndication('newGeneralIndication2');

        //WHEN
        Id existingGeneralIndToTrialId = [SELECT Id FROM CFAR_General_Indication_for_Trial_gne__c WHERE CFAR_Trial_ref_gne__c = :trial.Id].Id;
        trial.General_Indication_Multi_gne__c = generalIndication1.Id + ';' + generalIndication2.Id;
        update trial;

        //THEN
        integer oldSpecificIndToTrialCount = [SELECT Count() FROM CFAR_General_Indication_for_Trial_gne__c WHERE Id = :existingGeneralIndToTrialId];
        System.assertEquals(0, oldSpecificIndToTrialCount, 
            'When General_Indication_Multi_gne__c is updated on Trial, should remove old CFAR_General_Indication_for_Trial_gne__c records');

        System.assertEquals(2, [SELECT COUNT() FROM CFAR_General_Indication_for_Trial_gne__c WHERE CFAR_Trial_ref_gne__c = :trial.Id], 
            'When General_Indication_Multi_gne__c is updated on Trial with 2 specific indications, should create new CFAR_General_Indication_for_Trial_gne__c records related to that trial');
    }

    static testMethod void handleOtherGNEAgentsChanged_ShouldCreateTrialOtherGnaAgent() {
        //GIVEN
        CFAR_Product_gne__c oldProduct = [SELECT Id FROM CFAR_Product_gne__c WHERE Name = 'Accutane'];
        CFAR_Product_gne__c newProduct = [SELECT Id FROM CFAR_Product_gne__c WHERE Name = 'NewProduct'];
        CFAR_Trial_gne__c trial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];

        //WHEN
        trial.Other_GNE_Agents_Multi_gne__c = newProduct.Id;
        update trial;

        System.assertEquals(0, [SELECT Count() FROM CFAR_Trial_Other_GNE_Agent_gne__c WHERE Other_GNE_Agent_ref_gne__c = :oldProduct.Id],
            'When Other_GNE_Agents_Multi_gne__c is updated on Trial, should delete old CFAR_Trial_Other_GNE_Agent_gne__c junction record');
        System.assertEquals(1, [SELECT Count() FROM CFAR_Trial_Other_GNE_Agent_gne__c WHERE Other_GNE_Agent_ref_gne__c = :newProduct.Id AND CFAR_Trial_ref_gne__c = :trial.Id],
            'When Other_GNE_Agents_Multi_gne__c is updated on Trial, should create new CFAR_Trial_Other_GNE_Agent_gne__c junction record');
    }

    static testMethod void handleIMPShippedChanged_ShouldCreateTrialIMPShipped() {
        //GIVEN
        CFAR_Product_gne__c oldProduct = [SELECT Id FROM CFAR_Product_gne__c WHERE Name = 'Accutane'];
        CFAR_Product_gne__c newProduct = [SELECT Id FROM CFAR_Product_gne__c WHERE Name = 'NewProduct'];
        CFAR_Trial_gne__c trial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];

        //WHEN
        trial.IMP_Shipped_Multi_gne__c = newProduct.Id;
        update trial;

        System.assertEquals(0, [SELECT Count() FROM CFAR_Trial_IMP_Shipped__c WHERE IMP_Shipped_ref__c = :oldProduct.Id],
            'When IMP_Shipped_Multi_gne__c is updated on Trial, should delete old CFAR_Trial_IMP_Shipped__c junction record');
        System.assertEquals(1, [SELECT Count() FROM CFAR_Trial_IMP_Shipped__c WHERE IMP_Shipped_ref__c = :newProduct.Id AND CFAR_Trial_ref_gne__c = :trial.Id],
            'When IMP_Shipped_Multi_gne__c is updated on Trial, should create new CFAR_Trial_IMP_Shipped__c junction record');
    }

    static testMethod void testSetTotalStudyEnrollmentOnInsert(){
        
        CFAR_Trial_gne__c trial = CFAR_DataFactory.createTrial(0);
        trial.Planned_Enrollment_gne__c = 20;

        Test.startTest();
            insert trial;
        Test.stopTest();

        System.assertEquals(20, [SELECT Total_Study_Enrollment__c FROM CFAR_Trial_gne__c WHERE Id =: trial.Id].Total_Study_Enrollment__c);

    }

    static testMethod void testSetTotalStudyEnrollmentOnUpdate(){
        
        CFAR_Trial_gne__c trial = CFAR_DataFactory.createTrial(0);
        trial.Planned_Enrollment_gne__c = 50;
        insert trial;

        Test.startTest();
            trial.Planned_Enrollment_gne__c = 100;
            trial.Total_Study_Enrollment__c = null;
            update trial;
        Test.stopTest();

        System.assertEquals(null, [SELECT Total_Study_Enrollment__c FROM CFAR_Trial_gne__c WHERE Id =: trial.Id].Total_Study_Enrollment__c);

    }
}