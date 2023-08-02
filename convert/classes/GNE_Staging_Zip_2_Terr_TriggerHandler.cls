public with sharing class GNE_Staging_Zip_2_Terr_TriggerHandler {
    private static Boolean isBatchRunning;
    
    public static void runValidation () {
        isBatchRunning = fetchBatchIsRunning();
        for(Staging_Zip_2_Terr_gne__c szt :(List<Staging_Zip_2_Terr_gne__c>)Trigger.new) {
            if(isBatchRunning){
                szt.addError('Insert records during batch running is suspended. Please, wait until it ends.');
            }
        }
    }
    
    public static void clearOldData() {
        for(Staging_Zip_2_Terr_gne__c szt :(List<Staging_Zip_2_Terr_gne__c>)Trigger.new) {
            if(isRecordApplicable(szt)){
                szt.Comment_gne__c = '';
                szt.Zip_to_Territory_gne__c = null;
            }
        }
    }
    
    private static Boolean isRecordApplicable(Staging_Zip_2_Terr_gne__c szt){
        Staging_Zip_2_Terr_gne__c oldRecord = (Staging_Zip_2_Terr_gne__c)Trigger.oldMap.get(szt.Id);
        return szt.Status_gne__c == 'Loaded' && (oldRecord.Status_gne__c == 'Processed' || oldRecord.Status_gne__c == 'Error Processing');
    }
    
    private static Boolean fetchBatchIsRunning() {
        if(isBatchRunning == null){
            isBatchRunning = ![
                SELECT Id 
                FROM AsyncApexJob 
                WHERE ApexClass.Name = 'GNE_ZipToTerritoryAssignment_Batch'
                    AND ParentJobId = null
                    AND Status In ('Processing','Preparing')
            ].isEmpty();
        }
        return isBatchRunning;
    }
}