public class AGS_ExecuteProvisionalCaseCreationBatch {
    private final ApexPages.StandardController theController;
   
    public AGS_ExecuteProvisionalCaseCreationBatch(ApexPages.StandardController controller){
        theController = controller;  
    }    
    Public PageReference autorun(){   
        string query = ' select Name,ID,AGS_Staging_Key_gne__c,AGS_Type_Flag_gne__C,AGS_Txn_Amount_gne__c,AGS_SRC_Txn_ID_gne__c,AGS_RuleID_gne__c,AGS_MDM_ID_gne__c,AGS_Brand_gne__c From AGSCaseStagingTable_gne__c where AGS_TxnAmountCheck_Status_gne__c = \'None\'and AGS_ProvisionalCaseCreateStatus_gne__c =\'Unprocessed\' order by AGS_SRC_Txn_ID_gne__c';
        system.debug('Query' + query);
        AGS_ProvisionalCaseCreationBatch DummyCaseTest =  new AGS_ProvisionalCaseCreationBatch(query);          
        ID batchprocessid = Database.executeBatch(DummyCaseTest);
        System.debug('Created DummyCase ');
        return theController.view().setRedirect(true);
    }
}