public class AGS_ExecuteCreateCaseBatch {
       private final ApexPages.StandardController theController;

    public AGS_ExecuteCreateCaseBatch (ApexPages.StandardController controller){
        theController = controller;  
        System.debug('Create Gene Batch line 1');
    }   
    Public PageReference autorun(){   
    
        List<AGS_User_Activation_Finish_gne__c> status = AGS_User_Activation_Finish_gne__c.getall().values();
        status[0].Status_gne__c = 'Process';
        update status;
          
        String query = 'Select Id,Name, AGS_PC_MDM_ID_gne__c, AGS_PC_Rule_ID_gne__c,AGS_PC_Key_gne__c  from AGS_Provisional_Case_gne__c where AGS_CaseCreation_status_gne__c = \'Unprocessed\'Limit 20000';
        AGS_CreateCaseAndInitialActionsBatch geneBatchDummyTest =  new AGS_CreateCaseAndInitialActionsBatch (query);           
        ID batchprocessid = Database.executeBatch(geneBatchDummyTest,1);
        System.debug('Created GeneBatch');
        return theController.view().setRedirect(true);
    }
}