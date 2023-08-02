public with sharing class CORE_Subscribe_Interface {

    public interface Validator {
        /*Return map partyId to error */
        Map<Id, CORE_Subscribe_Error__c> validate(List<CORE_Pub_Party__c>parties, Map<Id, List<CORE_Pub_External_Id__c>>partyToExtIds, Map<Id, List<CORE_Pub_Location__c>> partyToLocations, Map<Id, List<CORE_Pub_Plan_Product__c>>partyToProdPlans, CORE_Subscribe_Base.SubscribeMode mode);

        /*Return true if new record can be created otherwise return true (eg. we would like to create account only when is contributed by specific source system).
        */
        Boolean canCreateNewObject(CORE_Pub_Party__c parentParty, SObject publishRecord, CORE_Subscribe_Mapping_Configuration__c configuration, CORE_Subscribe_Base.SubscribeMode mode);

        Boolean canUpdateRecord(CORE_Pub_Party__c parentParty, SObject publishRecord, CORE_Subscribe_Mapping_Configuration__c configuration, List<SObject> existingRecords, CORE_Subscribe_Base.SubscribeMode mode);

        String getConfigurationType(SObject stagingRecord);
    }

    public interface Field_Handler {
        Object handle(SObject sourceObject, SObject targetObject, CORE_Subscribe_Field_Configuration_gne__c fc);
    }

    public interface Record_Retriever {

        /*Method is used to init service. Because of governor limits we have to passed child records as separate params. Parties doesn't contains CORE_Pub_External_Id__c and CORE_Pub_Plan_Product__c child records.*/
        void init(List<CORE_Pub_Party__c> parties, Map<Id, List<CORE_Pub_External_Id__c>> partyToExtIds, Map<Id, List<CORE_Pub_Location__c>> partyToLocations, Map<Id, List<CORE_Pub_Plan_Product__c>> partyToProdPlans);

        /*
        * Methods should return existing objects for publishRecord and configuration given as methods parameters.
        * parentParty - parent party object for publish record
        * publish record - publish record (it have to be one of this types: (CORE_Pub_Party__c than parent party is null, CORE_Pub_Location__c, CORE_Pub_Plan_Product__c, CORE_Pub_License__c, CORE_Pub_External_Id__c)
        * configuration - publish process configuration
        * subscribeRecords - records processed so far in subscribe process for specific object type
        */
        List<SObject> getExistingObjects(CORE_Pub_Party__c parentParty, SObject publishRecord, CORE_Subscribe_Mapping_Configuration__c configuration, Set<SObject> subscribeRecords);

        /*
        * Methods should return existing objects for publishRecords and configuration given as methods parameters.
        * parentParty - parent party object for publish records
        * publishs record - publish records (it have to be one of this types: (CORE_Pub_Party__c than parent party is null, CORE_Pub_Location__c, CORE_Pub_Plan_Product__c, CORE_Pub_License__c, CORE_Pub_External_Id__c)
        * configuration - publish process configuration
        * subscribeRecords - records processed so far in subscribe process for specific object type
        */
        ExistingRecodsWrapper getExistingObjects(CORE_Pub_Party__c parentParty, List<SObject> publishRecord, CORE_Subscribe_Mapping_Configuration__c configuration, Set<SObject> subscribeRecords);

        /*Retrieve users base on external Id. */
        List<User> fetchUsers(List<String> externalUserIds);
    }

    public interface Postporcessor {

        void processRecords(List<CORE_Pub_Party__c> parties, Map<Id, List<CORE_Pub_External_Id__c>> partyToExtIds, Map<Id, List<CORE_Pub_Plan_Product__c>> partyToProdPlans, Map<String, Map<String, List<SObject>>> partyToRecords, Map<String, Map<String, List<SObject>>> partyLocationToRecords,
                Map<String, Map<String, List<SObject>>> extIdToRecords, Map<String, Map<String, List<SObject>>> licenseToRecords, Map<String, Map<String, List<SObject>>> productToRecords);

    }

    public interface Record_Handler {
        void handle(SObject sourceObject, SObject targetObject);
    }

    /*Helper class for returning existing records for coresponding publish records.*/
    public class ExistingRecodsWrapper {
        public Map<String, List<SObject>> existingRecords;
        public List<SObject> notMatchingRecords;

        public ExistingRecodsWrapper() {
            existingRecords = new Map<String, List<SObject>>();
            notMatchingRecords = new List<SObject>();
        }
    }
}