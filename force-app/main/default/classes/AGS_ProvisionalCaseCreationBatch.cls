public class AGS_ProvisionalCaseCreationBatch extends AGS_AbstractCaseBatch implements Database.Stateful {
    
    private String AGS_SRC_Txn_ID_Stateful = '';
    
    public AGS_ProvisionalCaseCreationBatch(final String query) {
        super('AGS_CreateCaseAndIniActionsSchedulable', 'AGS Case Creation', query);
    }
    
    public AGS_ProvisionalCaseCreationBatch() {
        this(
            'SELECT Name, AGS_Staging_Key_gne__c, AGS_Type_Flag_gne__c, AGS_Txn_Amount_gne__c, AGS_SRC_Txn_ID_gne__c, AGS_RuleID_gne__c, AGS_MDM_ID_gne__c, AGS_Brand_gne__c ' +
            'FROM AGSCaseStagingTable_gne__c WHERE AGS_TxnAmountCheck_Status_gne__c = \'None\' ' +
            'AND AGS_ProvisionalCaseCreateStatus_gne__c = \'Unprocessed\' ' +
            'ORDER BY AGS_SRC_Txn_ID_gne__c'
        );
    }
    
    public override DateTime getNextJobScheduledRun() {
        final DateTime nextJobRun = super.getNextJobScheduledRun();
        return Test.isRunningTest() || nextJobRun.hour() < 20 ? nextJobRun : null;
    }
    
    public override void execute(final Database.BatchableContext ctx, final List<sObject> scope) {
        Savepoint Savepoint = Database.setSavepoint();
        List<AGS_Error_Log__c> ErrorLogFailure = new List<AGS_Error_Log__c>();
        List<AGS_Provisional_Case_gne__c> dummyCaseList = new List <AGS_Provisional_Case_gne__c>();
        List<AGSCaseStagingTable_gne__c> duplicatesList = new List <AGSCaseStagingTable_gne__c>();
        List<AGSCaseStagingTable_gne__c> agsObj = (List <AGSCaseStagingTable_gne__c >) scope;
        Map <String, AGSCaseStagingTable_gne__c> noDupsAgs = new Map <String, AGSCaseStagingTable_gne__c>();
        Map <String, AGSCaseStagingTable_gne__c> noDupsAgsInstance = new Map <String, AGSCaseStagingTable_gne__c>();
        List<AGSCaseStagingTable_gne__c> dupsAgsInstance = new List<AGSCaseStagingTable_gne__c>();
        try {
            for (AGSCaseStagingTable_gne__c ags : agsObj ) {
                if (ags.AGS_Type_Flag_gne__c == 'INS') {
                    if (ags.AGS_SRC_Txn_ID_gne__c != AGS_SRC_Txn_ID_Stateful) {
                        if (!noDupsAgsInstance.keySet().contains(ags.AGS_SRC_Txn_ID_gne__c)) {
                            noDupsAgsInstance.put(ags.AGS_SRC_Txn_ID_gne__c, ags);
                        } else {
                            dupsAgsInstance.add(ags);
                        }
                    } else {
                        dupsAgsInstance.add(ags);
                    }
                }
                if (ags.AGS_Type_Flag_gne__c == 'AGG') {
                    if (!noDupsAgs.keySet().contains(ags.AGS_Staging_Key_gne__c )) {
                        noDupsAgs.put(ags.AGS_Staging_Key_gne__c, ags);
                    }
                }
                AGS_SRC_Txn_ID_Stateful = ags.AGS_SRC_Txn_ID_gne__c;
            }
            for (AGSCaseStagingTable_gne__c s : noDupsAgs.values() ) {
                AGS_Provisional_Case_gne__c dummyCase = new AGS_Provisional_Case_gne__c();
                dummyCase.AGS_PC_Type_Flag_gne__c = 'AGG';
                dummyCase.AGS_PC_MDM_ID_gne__c = s.AGS_MDM_ID_gne__c;
                dummyCase.AGS_PC_Rule_ID_gne__c = s.AGS_RuleID_gne__c;
                dummyCaseList.add(dummyCase);
            }
            for (AGSCaseStagingTable_gne__c s : noDupsAgsInstance.values() ) {
                AGS_Provisional_Case_gne__c dummyCase = new AGS_Provisional_Case_gne__c();
                dummyCase.AGS_PC_Type_Flag_gne__c = 'INS';
                dummyCase.AGS_PC_Src_Txn_ID_gne__c = s.AGS_SRC_Txn_ID_gne__c;
                dummyCase.AGS_PC_MDM_ID_gne__c = s.AGS_MDM_ID_gne__c;
                dummyCase.AGS_PC_Rule_ID_gne__c = s.AGS_RuleID_gne__c;
                dummyCaseList.add(dummyCase);
            }
            insert(dummyCaseList);
            List <AGSCaseStagingTable_gne__c > staging = new List <AGSCaseStagingTable_gne__c >();
            List<AGS_Provisional_Case_gne__c> provisional = new List<AGS_Provisional_Case_gne__c>([Select  Id, Name, AGS_PC_Key_gne__c from  AGS_Provisional_Case_gne__c where Id in :dummyCaseList]);
            for (AGS_Provisional_Case_gne__c pc : provisional) {
                for (AGSCaseStagingTable_gne__c  ags : agsObj ) {
                    if (pc.AGS_PC_Key_gne__c.equals(ags.AGS_Staging_Key_gne__c)) {
                        ags.AGS_ProvisionalCaseCreateStatus_gne__c = 'Processed';
                        ags.AGS_Provisional_Case__c = pc.Id;
                        staging.add(ags);
                    }
                }
            }
            set<AGSCaseStagingTable_gne__c> stagingSet = new set<AGSCaseStagingTable_gne__c>();
            for (AGSCaseStagingTable_gne__c stagingRecord : staging) {
                stagingSet.add(stagingRecord);
            }
            List<AGSCaseStagingTable_gne__c> uniqueList = new List<AGSCaseStagingTable_gne__c>();
            uniqueList.addAll(stagingSet);
            update(uniqueList);
            if (dupsAgsInstance.size() >= 0) {
                for (AGSCaseStagingTable_gne__c s : dupsAgsInstance) {
                    AGSCaseStagingTable_gne__c duplicate = s;
                    duplicate.AGS_ProvisionalCaseCreateStatus_gne__c = 'Duplicate';
                    duplicate.AGS_Provisional_Case__c = null;
                    duplicate.AGS_Case_Creation_status_gne__c = 'Duplicate';
                    duplicatesList.add(duplicate);
                }
                update(duplicatesList);
            }
        } catch (Exception e) {
            for ( AGSCaseStagingTable_gne__c stagingRecord : noDupsAgs.values() ) {
                AGS_Error_Log__c el = new AGS_Error_Log__c(
                    Class_Name__c = 'AGS_ProvisionalCaseCreationBatch',
                    System_Error_Message__c = e.getMessage(),
                    Custom_Error_Message__c = 'Could Not Create Provisional Case: ' + stagingRecord.name + ' Id = ' + stagingRecord.Id,
                    Error_Type__c = 'Failure',
                    Method_Name__c = 'Execute',
                    Object_Name__c = 'AGS Case Staging Table'
                );
                ErrorLogFailure.add(el);
            }
            Database.rollback ( savePoint );
            insert ErrorLogFailure;
        }
    }
}