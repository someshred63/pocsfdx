public class GNE_CommunicationPrefTriggerHandler {
    private static Map<String, Communication_Preference_gne__c> key2preference;
    private static final String VALIDATION_ERROR_UNIQE_VALUE = 'Provided {0} already exists in the database. Please enter a different value to save the record.';
    
    public static void runValidation() {
        key2preference = fetchCommunicationPreferencesMap((List<Communication_Preference_gne__c>) Trigger.new);
        for(Communication_Preference_gne__c cp : (List<Communication_Preference_gne__c>) Trigger.new){
            validateValueToBeUniqe(cp);
        }
    }
    
    private static void validateValueToBeUniqe(Communication_Preference_gne__c preference) {
        String key = prepareKey(preference);
        if(key2preference.containsKey(key)) {
            String errorMessage = String.format(VALIDATION_ERROR_UNIQE_VALUE, new List<String> {preference.Type_gne__c});
            preference.addError(errorMessage);
        }
    }
    
    private static Map<String, Communication_Preference_gne__c> fetchCommunicationPreferencesMap(List<Communication_Preference_gne__c> preferences) {
        if(key2preference == null) {
            key2preference = new Map<String, Communication_Preference_gne__c>();
            for(Communication_Preference_gne__c cp : fetchPreferences(fetchAccountsIds(preferences))){
                String key = prepareKey(cp);
                key2preference.put(key, cp);
            }
        }

        return key2preference;
    }
    
    private static String prepareKey (Communication_Preference_gne__c cp) {
        String key;
        if(cp.Is_Personal_gne__c) {
            key = cp.Account_gne__c + '_' + cp.Value_gne__c + '_' + cp.Type_gne__c + '_' + cp.OwnerId;
        } else {
            key = cp.Account_gne__c + '_' + cp.Value_gne__c + '_' + cp.Type_gne__c;
        }
        
        return key;
    }
    
    private static List<Communication_Preference_gne__c> fetchPreferences (Set<Id> accountsIds) {
        return [
            SELECT Id, Account_gne__c, Type_gne__c, Is_Personal_gne__c, Value_gne__c, OwnerId
            FROM Communication_Preference_gne__c 
            WHERE Account_gne__c IN : accountsIds
        ];
    }
    
    private static Set<Id> fetchAccountsIds(List<Communication_Preference_gne__c> preferences) {
        Set<Id> ids = new Set<Id>();
        for(Communication_Preference_gne__c cp : preferences) {
            ids.add(cp.Account_gne__c);
        }
        
        return ids;        
    }
}