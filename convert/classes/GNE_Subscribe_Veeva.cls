global class GNE_Subscribe_Veeva implements Database.Batchable<SObject>, Database.AllowsCallouts {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        Datetime lastExecutionTime = getLastExecutionTime();
        String query = 'SELECT Account_vod_c__r.Id, GT_Stakeholder_MDM_ID__c FROM Call2_vod_c__x WHERE CreatedDate__c > {0} AND GT_Stakeholder_MDM_ID__c != NULL';
        query = String.format(query, new String[]{
                lastExecutionTime.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'')
        });
        return Database.getQueryLocator (query);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        List<Call2_vod_c__x> veevaCalls = (List<Call2_vod_c__x>) scope;
        system.debug(veevaCalls);
        Set<String> mdmIds = getVeevaAccountMdmIds(veevaCalls);
        if (!mdmIds.isEmpty()) {
            for (Account account : [SELECT MDMID_gne__c FROM Account WHERE MDMID_gne__c IN :mdmIds]) {
                mdmIds.remove(account.MDMID_gne__c);
            }
            List<Account> accounts;
            if (!mdmIds.isEmpty()) {
                accounts = new GNE_Subscribe_Util().searchAndSubscribeAccounts(mdmIds);

                for (Account account : accounts) {
                    mdmIds.remove(account.MDMID_gne__c);
                }
                addToInclusion(mdmIds);
            }
        }
    }

    private Set<String> getVeevaAccountMdmIds(List<Call2_vod_c__x> veevaCalls) {
        Set<Id> accountIds = new Set<Id>();
        for (Call2_vod_c__x call : veevaCalls) {
            accountIds.add(call.Account_vod_c__r.Id);
        }
        Set<String> mdmIds = new Set<String>();
        if (!accountIds.isEmpty()) {
            List<Account__x> veevaAccounts = [
                    SELECT Name__c, External_ID_vod_c__c, GT_Account_Record_Type_c__c
                    FROM Account__x
                    WHERE Id IN :accountIds
                    AND External_ID_vod_c__c != NULL
                    AND GT_Account_Record_Type_c__c IN ('Professional_vod')
            ];
            for (Account__x account : veevaAccounts) {
                mdmIds.add(account.External_ID_vod_c__c);
            }
        }
        return mdmIds;
    }

    private void addToInclusion(Set<String> mdmIds) {
        List<CORE_Pub_Inclusion__c> inclusionRecords = new List<CORE_Pub_Inclusion__c>();
        for (String mdmId : mdmIds) {
            inclusionRecords.add(new CORE_Pub_Inclusion__c(MDM_Id_gne__c = mdmId));
        }
        Database.insert(inclusionRecords, false);
    }

    global void finish(Database.BatchableContext BC) {

    }

    private static Datetime getLastExecutionTime() {
        Datetime lastExecutionTime = Date.today().addDays(-90);
        List<AsyncApexJob> jobs = [SELECT CompletedDate FROM AsyncApexJob WHERE ApexClass.Name='GNE_Subscribe_OCE' AND Status = 'Completed' AND JobType='BatchApex' ORDER BY CompletedDate DESC LIMIT 1];
        if(!jobs.isEmpty()){
            lastExecutionTime = jobs.get(0).CompletedDate;
        }
        return lastExecutionTime;
    }
}