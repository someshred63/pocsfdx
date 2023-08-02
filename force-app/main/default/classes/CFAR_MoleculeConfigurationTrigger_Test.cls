@isTest
private class CFAR_MoleculeConfigurationTrigger_Test {

    //check System allowed to create duplicate record
    static testMethod void createDuplicateMoleculeConfiguration() {
        Test.startTest();
        List<CFAR_Molecule_Configuration_gne__c> listOfMolecules = new List<CFAR_Molecule_Configuration_gne__c>();
        
        CFAR_Theme_gne__c theme = new CFAR_Theme_gne__c();
        theme.Theme_Name_gne__c = 'testTheme';
        theme.Active_gne__c = true;
        insert theme;
        
        CFAR_Product_gne__c product = new CFAR_Product_gne__c();
        product.Other_GNE_Agent_Active_gne__c = true;
        product.Generic_Name_gne__c = 'Accutane';
        product.Theme_ref_gne__c = theme.Id;
        product.Abbreviation_gne__c = 't';
        product.Description_gne__c = 't';
        product.Active_gne__c = true;
        product.Name = 'Accutane';
        insert product;
        
        CFAR_Unit_Type_gne__c unitType = new CFAR_Unit_Type_gne__c();
        unitType.Name = 'Vial';
        unitType.Active_gne__c = true;
        insert unitType;
        System.assertEquals(1, [SELECT ID FROM CFAR_Unit_Type_gne__c].size());
        
        CFAR_Molecule_Configuration_gne__c moleculeConfiguration1 = new CFAR_Molecule_Configuration_gne__c(); 
        moleculeConfiguration1.CFAR_Unit_Type_ref_gne__c = unitType.id;
        moleculeConfiguration1.Configuration_gne__c = '100 mg';
        moleculeConfiguration1.Product_gne__c = product.id;
        moleculeConfiguration1.Active_gne__c = true;
        insert moleculeConfiguration1;
        System.assertEquals(1, [SELECT ID FROM CFAR_Molecule_Configuration_gne__c].size());
        System.assertEquals('100 mg', moleculeConfiguration1.Configuration_gne__c);
        System.assertNotEquals(null, moleculeConfiguration1.CFAR_Unit_Type_ref_gne__c);
        System.assertEquals(true, moleculeConfiguration1.Active_gne__c);
        try {
            insert moleculeConfiguration1.clone();
        } catch (Exception e) {
             System.assertEquals('Molecule Configuration already exists', e.getDmlMessage(0));
        }
        listOfMolecules = [SELECT ID FROM CFAR_Molecule_Configuration_gne__c];
        System.assertEquals(1, listOfMolecules.size());   
        Test.stopTest(); 
    }
    
    //check System allowed to create duplicate record (list)
    static testMethod void createDuplicateMoleculeConfigurationList() {
        Test.startTest();
        List<CFAR_Molecule_Configuration_gne__c> listOfMolecules = new List<CFAR_Molecule_Configuration_gne__c>();
        List<CFAR_Molecule_Configuration_gne__c> recordsToAdd = new List<CFAR_Molecule_Configuration_gne__c>();
        
        CFAR_Theme_gne__c theme = new CFAR_Theme_gne__c();
        theme.Theme_Name_gne__c = 'testTheme';
        theme.Active_gne__c = true;
        insert theme;
        
        CFAR_Product_gne__c product = new CFAR_Product_gne__c();
        product.Other_GNE_Agent_Active_gne__c = true;
        product.Generic_Name_gne__c = 'Accutane';
        product.Theme_ref_gne__c = theme.id;
        product.Abbreviation_gne__c = 't';
        product.Description_gne__c = 't';
        product.Active_gne__c = true;
        product.Name = 'Accutane';
        insert product;
        
        CFAR_Unit_Type_gne__c unitType = new CFAR_Unit_Type_gne__c();
        unitType.Active_gne__c = true;
        unitType.Name = 'Vial';
        insert unitType;
        
        CFAR_Molecule_Configuration_gne__c moleculeConfiguration1 = new CFAR_Molecule_Configuration_gne__c(); 
        moleculeConfiguration1.Product_gne__c = product.id;
        moleculeConfiguration1.Configuration_gne__c = '100 mg';
        moleculeConfiguration1.CFAR_Unit_Type_ref_gne__c = unitType.id;
        moleculeConfiguration1.Active_gne__c = true;
        
        CFAR_Molecule_Configuration_gne__c moleculeConfiguration2 = new CFAR_Molecule_Configuration_gne__c(); 
        moleculeConfiguration2.Product_gne__c = product.id;
        moleculeConfiguration2.Configuration_gne__c = '100 mg';
        moleculeConfiguration2.CFAR_Unit_Type_ref_gne__c = unitType.id;
        moleculeConfiguration2.Active_gne__c = true;
        
        recordsToAdd.add(moleculeConfiguration1);
        recordsToAdd.add(moleculeConfiguration2);
        try {
            insert recordsToAdd;
        } catch (Exception e) {
            System.assertEquals('Molecule Configuration already exists', e.getDmlMessage(0));
        }
        listOfMolecules = [SELECT ID FROM CFAR_Molecule_Configuration_gne__c];
        System.assertEquals(0, listOfMolecules.size());
        Test.stopTest();
    }
}