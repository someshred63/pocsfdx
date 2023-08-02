global class GNE_CRM_340B_EmailsInLabels_Batch implements Database.batchable<sObject>, Database.AllowsCallouts {
    
    global GNE_CRM_340B_EmailsInLabels_Batch(){}
    
    global Database.QueryLocator start(Database.batchableContext info){
        Set<String> userSet = new Set<String>();
        List<GNE_MCCO_CRM_340B_Google_Tokens__c> userList = [ SELECT Name FROM GNE_MCCO_CRM_340B_Google_Tokens__c ];
        for (GNE_MCCO_CRM_340B_Google_Tokens__c u : userList) {
            userSet.add(u.Name);
        }

        List<GNE_MCCO_CRM_340B_Google_Tokens__c> gtList = GNE_CRM_340B_Google_Utlis.refreshSelectedGoogleAccessTokens(userSet);
        if (!gtList.isEmpty()) {
            update gtList;
        }
        
        return Database.getQueryLocator('SELECT Id, Name, Access_Token__c, Authorization_Code__c, Expires_In__c, Label__c, Last_Sync__c, Next_Page__c, Refresh_Token__c, Token_Type__c, Aes_Key__c FROM GNE_MCCO_CRM_340B_Google_Tokens__c WHERE Access_Token__c != NULL');
    }
    
    global void execute(Database.batchableContext info, List<sObject> scope){
        GNE_CRM_340B_Google_Utlis.retrieveEmailsInLabels((List<GNE_MCCO_CRM_340B_Google_Tokens__c>)scope);
    }

    global void finish(Database.batchableContext info){}

}