public with sharing class CORE_Subscribe_Affiliation_Process implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {

    private Integer createdHcps;

    public Database.QueryLocator start(Database.BatchableContext param1) {
        createdHcps = 0;
        return Database.getQueryLocator ([
                SELECT HCP_MDM_Id__c, Status__c
                FROM Core_Staging_Affiliation__c
                WHERE Status__c = :CORE_Subscribe_Affiliation_Batch.STATUS_LOADED
                AND Affiliation_Status__c = :CORE_Subscribe_Affiliation_Batch.STAGING_ACTIVE_STATUS
        ]);
    }

    public void execute(Database.BatchableContext param1, List<SObject> scope) {
        List<Core_Staging_Affiliation__c> stagingAffiliations = (List<Core_Staging_Affiliation__c>) scope;
        Set<String>mdmIds = new Set<String>();
        for (Core_Staging_Affiliation__c cas : stagingAffiliations) {
            mdmIds.add(cas.HCP_MDM_Id__c);
        }
        for (Account acc : [SELECT MDMID_gne__c FROM Account WHERE MDMID_gne__c IN :mdmIds]) {
            mdmIds.remove(acc.MDMID_gne__c);
        }
        List<Account> accounts = new GNE_Subscribe_Util().searchAndSubscribeAccounts(mdmIds);
        createdHcps += accounts.size();
    }

    public void finish(Database.BatchableContext param1) {
        CORE_Subscribe_Affiliation_Batch affiliationBatch = new CORE_Subscribe_Affiliation_Batch(createdHcps);
        GNE_Batch_Runner.executeBatch(affiliationBatch, CORE_Subscribe_Affiliation_Batch.class, 200);
    }
}