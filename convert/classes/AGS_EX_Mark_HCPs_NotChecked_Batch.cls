global class AGS_EX_Mark_HCPs_NotChecked_Batch implements Database.Batchable<sObject>, Database.Stateful {
    
    final static String NOT_CHECKED_STATUS = 'Not Checked';
    final static List<String> notFinalizedStatuses = new List<String> {'Not Checked', 'Check pending', 'In Process'};
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('AGS_EX_Mark_HCPs_NotChecked_Batch start.');

        //get Accounts that are from US, RT is PersonAccount and were not checked within last 365 days
        return Database.getQueryLocator([SELECT Id, AGS_EX_Exclusion_Status_base_gne__c FROM Account
                                            WHERE Region_Code_gne__c = 1
                                            AND RecordType.IsPersonType = true
                                            AND AGS_EX_Exclusion_Status_base_gne__c NOT IN :notFinalizedStatuses
                                            AND AGS_EX_Date_Checked_Exclusion_gne__c != LAST_N_DAYS:365]);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        if (scope != null && scope.size() > 0) {
            List<Account> accountsListToUpdate = new List<Account>();
            for(sObject objAccount : scope) {
                Account acc = (Account)objAccount;
                acc.AGS_EX_Exclusion_Status_base_gne__c = NOT_CHECKED_STATUS;
                accountsListToUpdate.add(acc);
            }
            update accountsListToUpdate;
        }

    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('AGS_EX_Mark_HCPs_NotChecked_Batch finished.');
    }
}