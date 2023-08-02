trigger CFAR_MoleculeConfigurationTrigger on CFAR_Molecule_Configuration_gne__c (before insert, before update) {
    if (CFAR_ConfigUtil.isTriggerEnabled(new List<String>{'CFAR_MoleculeConfigurationTrigger','CFAR_Molecule_Configuration_gne__c'})){
        Set<String> uniqueString = new Set<String>();
        
        for(CFAR_Molecule_Configuration_gne__c molecule : Trigger.new){
           if(uniqueString.contains(molecule.Configuration_gne__c + molecule.Product_gne__c + molecule.CFAR_Unit_Type_ref_gne__c + molecule.Active_gne__c)){
                Trigger.new[0].addError('Molecule Configuration already exists');
            }
            uniqueString.add(molecule.Configuration_gne__c + molecule.Product_gne__c + molecule.CFAR_Unit_Type_ref_gne__c + molecule.Active_gne__c);
        }
        
        List<CFAR_Molecule_Configuration_gne__c> allMolecules = new List<CFAR_Molecule_Configuration_gne__c>();
        allMolecules = [SELECT ID, Configuration_gne__c, Product_gne__c, CFAR_Unit_Type_ref_gne__c, Active_gne__c FROM CFAR_Molecule_Configuration_gne__c];
        
        for(CFAR_Molecule_Configuration_gne__c allValues : allMolecules){
           if(uniqueString.contains(allValues.Configuration_gne__c + allValues.Product_gne__c + allValues.CFAR_Unit_Type_ref_gne__c + allValues.Active_gne__c)){
               Trigger.new[0].addError('Molecule Configuration already exists');
           }
        }
    }
}