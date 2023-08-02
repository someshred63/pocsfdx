global class CFAR_TrialIMPShippedBatch implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext context) {
        Id dollarOnlyId = [SELECT Id FROM CFAR_Dollar_and_Drug_gne__c WHERE Name = '$ Only'].Id;
        return Database.getQueryLocator('SELECT Id, IMP_Shipped_Multi_gne__c, Other_GNE_Agents_Multi_gne__c FROM CFAR_Trial_gne__c WHERE frm_Trial_Status_ref_gne__c != \'Concluded\' AND IMP_Shipped_Multi_gne__c = null AND Other_GNE_Agents_Multi_gne__c != null AND Other_GNE_Agents_Multi_gne__c != \'N/A\' AND Dollar_and_Drug_ref_gne__c != \'' + dollarOnlyId + '\'');
    }

    global void execute(Database.BatchableContext context, List<CFAR_Trial_gne__c> trials) {
        List<CFAR_Trial_IMP_Shipped__c> impShippedToInsert = new List<CFAR_Trial_IMP_Shipped__c>();
        List<CFAR_Trial_Other_GNE_Agent_gne__c> studiedProducts = new List<CFAR_Trial_Other_GNE_Agent_gne__c>([SELECT CFAR_Trial_ref_gne__c,Other_GNE_Agent_ref_gne__c FROM CFAR_Trial_Other_GNE_Agent_gne__c WHERE CFAR_Trial_ref_gne__c IN :trials]);
        for(CFAR_Trial_Other_GNE_Agent_gne__c studiedProd : studiedProducts) {       
            impShippedToInsert.add(new CFAR_Trial_IMP_Shipped__c(CFAR_Trial_ref_gne__c = studiedProd.CFAR_Trial_ref_gne__c, IMP_Shipped_ref__c = studiedProd.Other_GNE_Agent_ref_gne__c));
        }
        insert impShippedToInsert;

        for(CFAR_Trial_gne__c trial : trials) {
            trial.IMP_Shipped_Multi_gne__c = trial.Other_GNE_Agents_Multi_gne__c;                 
        }
        CFAR_ConfigUtil.setDisabled('Disabled_Triggers_gne__c', new List<String> {'CFAR_TrialTrigger'});
        update trials;
        CFAR_ConfigUtil.setDisabled('Disabled_Triggers_gne__c', new List<String>());
        

    }
    global void finish(Database.BatchableContext context) {
        
    }
}