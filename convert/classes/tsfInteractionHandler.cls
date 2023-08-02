global without sharing class tsfInteractionHandler {
    
    public static void handleLastInteractionDate (List<String> trigger_info) {
       
        Set<Id> accountIds         = new Set<Id>();
        Set<String> territoryNames = new Set<String>();
        
        // Query Call records
        List<Call2_vod__c> callList = new List<Call2_vod__c>([SELECT
                                                                Id, 
                                                                Call_Date_vod__c,
                                                                LastModifiedDate, 
                                                                Account_vod__c, 
                                                                Territory_vod__c 
                                                               FROM 
                                                                Call2_vod__c 
                                                               WHERE 
                                                                Id in :trigger_info]);                                                                    
        
        for (Call2_vod__c call : callList) {
            accountIds.add(call.Account_vod__c);
            if (call.Territory_vod__c != null && call.Territory_vod__c != '')
                territoryNames.add(call.Territory_vod__c);
        }
        
        // Query related TSFs
        List<TSF_vod__c> allTSFs = [SELECT 
                                       Id, 
                                       Account_vod__c,
                                       Territory_vod__c,
                                       Last_Interaction_Date_gne__c,                                       
                                       CreatedDate                                     
                                    FROM 
                                       TSF_vod__c 
                                    WHERE
                                       Account_vod__c IN :accountIds AND
                                       Territory_vod__c IN :territoryNames];
                
        List<TSF_vod__c> finalTSFList = new List<TSF_vod__c>();
        Map<String, TSF_vod__c> createTSFMap = new Map<String, TSF_vod__c>();
        for (Call2_vod__c call : callList) {   
            Integer i = 0;
            Boolean isFound = false;
            while ((i < allTSFs.size()) && (!isFound)) {        
                if (allTSFs[i].Account_vod__c == call.Account_vod__c && allTSFs[i].Territory_vod__c == call.Territory_vod__c) 
                    isFound = true;
                i++;
            }
            if (isFound) {
                // Update
                if (allTSFs[i-1].Last_Interaction_Date_gne__c < call.Call_Date_vod__c || 
                    allTSFs[i-1].Last_Interaction_Date_gne__c == null) {
                        allTSFs[i-1].Last_Interaction_Date_gne__c = call.Call_Date_vod__c;
                        finalTSFList.add(allTSFs[i-1]);                     
                }
            } else {
                // Insert
                 if (createTSFMap.containsKey(call.Account_vod__c + '__' + call.Territory_vod__c)) {
                    if (createTSFMap.get(call.Account_vod__c + '__' + call.Territory_vod__c).Last_Interaction_Date_gne__c < call.Call_Date_vod__c ||
                        createTSFMap.get(call.Account_vod__c + '__' + call.Territory_vod__c).Last_Interaction_Date_gne__c == null) 
                            createTSFMap.get(call.Account_vod__c + '__' + call.Territory_vod__c).Last_Interaction_Date_gne__c = call.Call_Date_vod__c;
                 } else {
                    createTSFMap.put(call.Account_vod__c + '__' + call.Territory_vod__c, new TSF_vod__c(Account_vod__c = call.Account_vod__c,
                                                                                                        Territory_vod__c = call.Territory_vod__c,
                                                                                                        Last_Interaction_Date_gne__c = call.Call_Date_vod__c,
                                                                                                        External_Id_vod__c = call.Account_vod__c + '__' + call.Territory_vod__c
                                                                                                        ));
                 }
            }
        }
        if (!createTSFMap.isEmpty()) {
            finalTSFList.addAll(createTSFMap.values());
        }
        if (finalTSFList.size() > 0)
            Database.UpsertResult[] results = Database.upsert(finalTSFList, false);
    }  
}