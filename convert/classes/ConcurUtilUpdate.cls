public without sharing class ConcurUtilUpdate {
    
    public static void updateConcurSettings(String jsonSettings) {
        if(System.isBatch() || System.isFuture() || System.isQueueable() || System.isScheduled()) {
            runUpdateConcurSettings(jsonSettings);
        } else {
            runAsyncUpdateConcurSettings(jsonSettings);
        }
    }
    
    private static void runUpdateConcurSettings(String jsonSettings) {
        Concur_Settings_gne__c settings = (Concur_Settings_gne__c) JSON.deserialize(jsonSettings, Concur_Settings_gne__c.class);

        update settings;
    }    
    
    @future
    private static void runAsyncUpdateConcurSettings(String jsonSettings) {
        runUpdateConcurSettings(jsonSettings);
    }    
}