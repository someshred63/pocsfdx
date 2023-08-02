public class GNE_FRM_DST_MergeCandidateTriggerHandler {
    private static final Map<String, String> statuses = new Map<String, String> {
        'Processed' => 'Merged',
        'Error Processing' => 'Exception'    
    };
        
    public static void populateStatusOnDST_Match_Loser() {
        Map<Id, CORE_Merge_Candidate__c> id2candidate = fetchLosers();
        Map<Id, DST_Match_Loser__c> losersToUpdate = new Map<Id, DST_Match_Loser__c>();
        for(CORE_Merge_Candidate__c cand : (CORE_Merge_Candidate__c[])Trigger.new){
            if(isRecordApplicable(cand)){
                populateStatusOnLoosers(id2candidate, cand, losersToUpdate);
            }
        }  

        Database.SaveResult[] sResults = Database.update(losersToUpdate.values(), false);
        handleErrors(sResults);
    }
    
    private static void handleErrors(List<Database.SaveResult> sResults){
        for(Database.SaveResult sr : sResults) {
            if(!sr.isSuccess()) {
                handleException(sr.getErrors());
            }
        }        
    }
    
    private static void handleException(Database.Error[] errors) {
        for(Database.Error err : errors) {
            System.debug('DML Error: ' + err.getMessage());
        }
    }
    
    private static Boolean isRecordApplicable(CORE_Merge_Candidate__c newRecord) {
        Boolean result = false;
        if (Trigger.isUpdate) {
            CORE_Merge_Candidate__c oldRecord = (CORE_Merge_Candidate__c)Trigger.OldMap.get(newRecord.Id);
            result =  oldRecord.Status_gne__c !=  newRecord.Status_gne__c;
        } 
        
        return result;
    }
    
    private static void populateStatusOnLoosers(Map<Id, CORE_Merge_Candidate__c> id2candidate, CORE_Merge_Candidate__c cand, Map<Id, DST_Match_Loser__c> losersToUpdate ) {
        CORE_Merge_Candidate__c tempCandidate = id2candidate.get(cand.Id);
        for(DST_Match_Loser__c loser : tempCandidate.Merge_Bundles__r){
            loser.Mdm_Bundle_Status__c = statuses.get(cand.Status_gne__c) != null ? statuses.get(cand.Status_gne__c) : loser.Mdm_Bundle_Status__c;
            loser.Merge_Bundle_Exception__c = cand.Error_Codes_gne__c;
            losersToUpdate.put(loser.Id, loser);
        }
    }
    
    private static Map<Id,CORE_Merge_Candidate__c> fetchLosers(){
        Map<Id,CORE_Merge_Candidate__c> id2candidate = new Map<Id,CORE_Merge_Candidate__c>();
        for(CORE_Merge_Candidate__c cand :[
            SELECT Id, (SELECT Mdm_Bundle_Status__c, Merge_Bundle_Exception__c FROM Merge_Bundles__r) 
            FROM CORE_Merge_Candidate__c
            WHERE Id IN :Trigger.newMap.keySet()
        ]){
            id2candidate.put(cand.Id, cand);
        }
        return id2candidate;
    }
}