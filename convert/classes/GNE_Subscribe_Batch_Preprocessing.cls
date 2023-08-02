global with sharing class GNE_Subscribe_Batch_Preprocessing implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {

    private Integer index = 0;
    private Map<String, Integer> territoryToBatchIndex = new Map<String, Integer>();
    private Boolean prevMode;
    private Boolean isSystemMode;

    public GNE_Subscribe_Batch_Preprocessing(Boolean prevMode) {
        this(prevMode, false);
    }

    public GNE_Subscribe_Batch_Preprocessing(Boolean prevMode, Boolean isSystemMode) {
        this.prevMode = prevMode;
        this.isSystemMode = isSystemMode;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator ([
                SELECT Id, Territory_Key_gne__c, MDM_ID_gne__c, Account_ID_gne__c
                FROM Staging_Alignment_gne__c
                WHERE Status_gne__c = :GNE_Subscribe_Batch_Base.STATUS_LOADED
                AND Activaction_Date_gne__c <= TODAY
        ]);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        Integer numberOfBatches = GNE_Subscribe_Alignment_Auto.getNumberOfAutoSubBatches();
        Set<String> mdmIds = new Set<String>();
        Set<Id> accountIds = new Set<Id>();
        Map<String, Id> mdmIdToSfdcId = new Map<String, Id>();

        for (Staging_Alignment_gne__c sa : (List<Staging_Alignment_gne__c>) scope) {
            if (!territoryToBatchIndex.containsKey(sa.Territory_Key_gne__c)) {
                index = Math.mod(++index, numberOfBatches);
                territoryToBatchIndex.put(sa.Territory_Key_gne__c, index);
            }
            sa.Batch_Index_gne__c = territoryToBatchIndex.get(sa.Territory_Key_gne__c);
            if (sa.MDM_ID_gne__c != null) {
                mdmIds.add(sa.MDM_ID_gne__c);
            } else if (sa.Account_ID_gne__c != null) {
                try {
                    Id sfdcId = Id.valueOf(sa.Account_ID_gne__c);
                    accountIds.add(sfdcId);
                } catch (Exception e) {
                    mdmIds.add(sa.Account_ID_gne__c);
                }
            }
        }
        if (!mdmIds.isEmpty()) {
            for (Account account : [SELECT Id, MDMID_gne__c FROM Account WHERE MDMID_gne__c != NULL AND MDMID_gne__c IN :mdmIds]) {
                mdmIds.remove(account.MDMID_gne__c);
                accountIds.add(account.Id);
                mdmIdToSfdcId.put(account.MDMID_gne__c, account.Id);
            }

            for (CORE_Pub_Party__c party : [SELECT Mdm_Id_gne__c FROM CORE_Pub_Party__c WHERE Mdm_Id_gne__c IN :mdmIds]) {
                mdmIds.remove(party.Mdm_Id_gne__c);
            }
            //search and create missing accounts
            new GNE_Subscribe_Util().searchAndSubscribeAccounts(mdmIds);
        }
        update scope;
        Map<Id, Id> looserToWinner = new Map<Id, Id>();
        for (Account acc : [SELECT Id, DCH_Previous_Id_gne__c, DCH_Parent_Id_gne__c FROM Account WHERE DCH_Parent_Id_gne__r.Id != NULL AND DCH_Previous_Id_gne__c IN :accountIds]) {
            looserToWinner.put(acc.DCH_Previous_Id_gne__c, acc.DCH_Parent_Id_gne__c);
        }
        if (!looserToWinner.isEmpty()) {
            for (Staging_Alignment_gne__c sa : (List<Staging_Alignment_gne__c>) scope) {
                Id accountSfdcId = null;
                if (sa.MDM_ID_gne__c != null) {
                    accountSfdcId = mdmIdToSfdcId.get(sa.MDM_ID_gne__c);
                } else if (sa.Account_ID_gne__c != null) {
                    try {
                        accountSfdcId = Id.valueOf(sa.Account_ID_gne__c);
                    } catch (Exception e) {
                        accountSfdcId = mdmIdToSfdcId.get(sa.Account_ID_gne__c);
                    }
                }
                if (accountSfdcId != null) {
                    if (looserToWinner.containsKey(accountSfdcId)) {
                        sa.Account_ID_gne__c = looserToWinner.get(accountSfdcId);
                        sa.Comment_gne__c = 'Previous account: ' + accountSfdcId;
                    }
                }
            }
        }
        Database.update(scope, false);
    }

    global void finish(Database.BatchableContext BC) {
        new GNE_Subscribe_Alignment_Auto().execute(prevMode, isSystemMode);
    }

}