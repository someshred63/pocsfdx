global class GNE_CRM_340B_ProcessEmails_Batch implements Database.batchable<sObject>, Database.AllowsCallouts {
    
    global GNE_CRM_340B_ProcessEmails_Batch(){
    }

    global Database.QueryLocator start(Database.batchableContext info){
        Set<String> userSet = new Set<String>();
        List<AggregateResult> agUserList = [ SELECT Count(Id), Username__c FROM GNE_CRM_340B_Email__c WHERE To__c = NULL GROUP BY Username__c ];
        for (AggregateResult agu : agUserList) {
            userSet.add(String.valueOf(agu.get('Username__c')));
        }

        List<GNE_MCCO_CRM_340B_Google_Tokens__c> gtList = GNE_CRM_340B_Google_Utlis.refreshSelectedGoogleAccessTokens(userSet);
        if (!gtList.isEmpty()) {
            update gtList;
        }

        return Database.getQueryLocator('SELECT Id, Body__c, Date__c, From__c, Message_ID__c, Subject_Line__c, To__c, Username__c FROM GNE_CRM_340B_Email__c WHERE To__c = NULL');
    }

    global void execute(Database.batchableContext info, List<sObject> scope){
        GNE_CRM_340B_Google_Utlis.processEmailInfo((List<GNE_CRM_340B_Email__c>)scope);
    }

    global void finish(Database.batchableContext info){
    }
}