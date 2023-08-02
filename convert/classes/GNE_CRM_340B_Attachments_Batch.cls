global class GNE_CRM_340B_Attachments_Batch implements Database.batchable<sObject>, Database.AllowsCallouts {
    
    global GNE_CRM_340B_Attachments_Batch(){
    }

    global Database.QueryLocator start(Database.batchableContext info){
        Set<String> userSet = new Set<String>();
        List<GNE_CRM_340B_Attachment__c> userList = [ SELECT Id, Username__c FROM GNE_CRM_340B_Attachment__c ];
        for (GNE_CRM_340B_Attachment__c u : userList) {
            userSet.add(u.Username__c);
        }

        List<GNE_MCCO_CRM_340B_Google_Tokens__c> gtList = GNE_CRM_340B_Google_Utlis.refreshSelectedGoogleAccessTokens(userSet);
        if (!gtList.isEmpty()) {
            update gtList;
        }

        return Database.getQueryLocator('SELECT Id, X340B_Email__c, X340B_Email__r.Message_ID__c, Attachment_ID__c, FileName__c, MIME_Type__c, Username__c FROM GNE_CRM_340B_Attachment__c WHERE Username__c != NULL');
    }

    global void execute(Database.batchableContext info, List<sObject> scope){
        GNE_CRM_340B_Google_Utlis.processAttachmentInfo((List<GNE_CRM_340B_Attachment__c>)scope);
    }

    global void finish(Database.batchableContext info){
    }
}