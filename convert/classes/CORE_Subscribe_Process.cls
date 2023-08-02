public without sharing class CORE_Subscribe_Process extends CORE_Subscribe_Base {

    private enum MetricType {
        INSERT_TYPE, UPDATE_TYPE, DELETE_TYPE
    }

    public static final Integer OVERWRITE_ALWAYS = 1;
    public static final Integer OVERWRITE_NULL = 3;

    private static final String PARTY_REFERENCE_API_NAME = 'Party_Id_ref_gne__c';
    private static final String PARTY_LOCATION_REFERENCE_API_NAME = 'Party_Location_Id_ref_gne__c';

    private Map<String, User> userCache;
    private Map<String, Object> interfaceCache;

    private Map<Id, CORE_Pub_Party__c> partiesMap;
    private Map<Id, List<CORE_Subscribe_Error__c>> partyToErrors;
    private Id jobId;
    private CORE_Subscribe_Metrics totalMetrics;
    private Map<Id, List<CORE_Pub_External_Id__c>> partyToExtIds;
    private Map<Id, List<CORE_Pub_Plan_Product__c>> partyToProductPlans;
    private Map<Id, List<CORE_Pub_TDDD_License__c>> partyToTdddLicenses;
    private Map<Id, List<CORE_Pub_License__c>> partyToLicenses;
    private Map<Id, List<CORE_Pub_Location__c>> partyToLocations;

    private CORE_Subscribe_Interface.Record_Retriever recordRetriever;
    private CORE_Subscribe_Interface.Validator validator;
    private SubscribeMode subMode;
    private Map<String, Map<String, Schema.SObjectField>> globalCache;

    /* Methods used mainly in batches. Metrics are passed to callect resulst between execution. */
    public CORE_Subscribe_Metrics executeSubscribe(List<CORE_Pub_Party__c> parties, Map<String, List<CORE_Subscribe_Mapping_Configuration__c>> mappingConfigurations, CORE_Subscribe_Job__c job, CORE_Subscribe_Metrics metrics) {
        return executeSubscribe(parties, mappingConfigurations, job, SubscribeMode.NORMAL, metrics);
    }

    public CORE_Subscribe_Metrics executeSubscribe(Set<String> partyIds, Map<String, List<CORE_Subscribe_Mapping_Configuration__c>> mappingConfigurations, CORE_Subscribe_Job__c job, CORE_Subscribe_Metrics metrics) {
        List<CORE_Pub_Party__c> parties = CORE_Subscribe_DAO.getPublishParties(partyIds, new Set<String>(), VALID_SOURCES);
        return executeSubscribe(parties, mappingConfigurations, job, SubscribeMode.NORMAL, metrics);
    }

    public CORE_Subscribe_Metrics executeSubscribe(Set<String> partyIds, Id jobId) {
        List<CORE_Pub_Party__c> parties = CORE_Subscribe_DAO.getPublishParties(partyIds, new Set<String>(), VALID_SOURCES);
        return executeSubscribe(parties, jobId);
    }

    public CORE_Subscribe_Metrics executeSubscribeASI(Set<String> partyIds, Id jobId) {
        List<CORE_Pub_Party__c> parties = CORE_Subscribe_DAO.getPublishParties(partyIds, new Set<String>(), VALID_SOURCES);
        return executeSubscribe(parties, jobId, SubscribeMode.ASI);
    }

    public CORE_Subscribe_Metrics executeSubscribeMDM(Set<String> partyMdmIds, Id jobId) {
        List<CORE_Pub_Party__c> parties = CORE_Subscribe_DAO.getPublishParties(new Set<String>(), partyMdmIds, VALID_SOURCES);
        return executeSubscribe(parties, jobId);
    }

    public CORE_Subscribe_Metrics executeSubscribe(Map<String, Set<String>> partyIdToPartyLocIdMap, Id jobId) {
        return executeSubscribe(partyIdToPartyLocIdMap, new Map<String, Set<String>>(), jobId);
    }

    public CORE_Subscribe_Metrics executeSubscribeMDM(Map<String, Set<String>> partyMdmIdToPartyLocMdmIdMap, Id jobId) {
        return executeSubscribe(new Map<String, Set<String>>(), partyMdmIdToPartyLocMdmIdMap, jobId);
    }

    /* Methods used mainly in batches. Metrics are passed to collect results between execution. */
    public CORE_Subscribe_Metrics executeSubscribe(Map<String, Set<String>> partyIdToPartyLocIdMap, Map<String, Set<String>> partyMdmIdToPartyLocMdmIdMap, Map<String, List<CORE_Subscribe_Mapping_Configuration__c>>mappingConfigurations, CORE_Subscribe_Job__c job, CORE_Subscribe_Metrics metrics) {
        List<CORE_Pub_Party__c> parties = CORE_Subscribe_DAO.getPublishParties(partyIdToPartyLocIdMap, partyMdmIdToPartyLocMdmIdMap, VALID_SOURCES);
        Map<Id, List<CORE_Pub_Location__c>> partyToLocationsASI = new Map<Id, List<CORE_Pub_Location__c>>();
        for (CORE_Pub_Party__c party : parties) {
            if (!partyToLocationsASI.containsKey(party.Id)) {
                partyToLocationsASI.put(party.Id, new List<CORE_Pub_Location__c>());
            }
            for (CORE_Pub_Location__c loc : (List<CORE_Pub_Location__c>) party.Publish_Party_Locations__r) {
                partyToLocationsASI.get(party.Id).add(loc);
            }
        }
        return executeSubscribe(parties, partyToLocationsASI, mappingConfigurations, job, SubscribeMode.ASI, metrics);
    }

    public CORE_Subscribe_Metrics executeSubscribe(Map<String, Set<String>> partyIdToPartyLocIdMap, Map<String, Set<String>> partyMdmIdToPartyLocMdmIdMap, Id jobId) {
        List<CORE_Pub_Party__c> parties = CORE_Subscribe_DAO.getPublishParties(partyIdToPartyLocIdMap, partyMdmIdToPartyLocMdmIdMap, VALID_SOURCES);
        Map<Id, List<CORE_Pub_Location__c>> partyToLocationsASI = new Map<Id, List<CORE_Pub_Location__c>>();
        for (CORE_Pub_Party__c party : parties) {
            if (!partyToLocationsASI.containsKey(party.Id)) {
                partyToLocationsASI.put(party.Id, new List<CORE_Pub_Location__c>());
            }
            for (CORE_Pub_Location__c loc : (List<CORE_Pub_Location__c>) party.Publish_Party_Locations__r) {
                partyToLocationsASI.get(party.Id).add(loc);
            }
        }
        CORE_Subscribe_Job__c job = CORE_Subscribe_DAO.getSubscribeJob(jobId);
        Map<String, List<CORE_Subscribe_Mapping_Configuration__c>> mappingConfigurations = CORE_Subscribe_DAO.getMappingConfiguration(job.Subscribe_Object_gne__c);
        CORE_Subscribe_Metrics metrics;
        try {
            metrics = executeSubscribe(parties, partyToLocationsASI, mappingConfigurations, job, SubscribeMode.ASI, new CORE_Subscribe_Metrics());
            CORE_Subscribe_Util.finishJob(job, metrics);
        } catch (Exception e) {
            String summary = e.getMessage() + '\n' + e.getStackTraceString();
            job.Summary_gne__c = summary;
            job.Status_gne__c = 'Error';
        }
        update job;
        return metrics;
    }

    public CORE_Subscribe_Metrics executeSubscribe(List<CORE_Pub_Party__c> parties, Id jobId) {
        return executeSubscribe(parties, jobId, null);
    }

    public CORE_Subscribe_Metrics executeSubscribe(List<CORE_Pub_Party__c> parties, Id jobId, SubscribeMode mode) {
        CORE_Subscribe_Job__c job = CORE_Subscribe_DAO.getSubscribeJob(jobId);
        Map<String, List<CORE_Subscribe_Mapping_Configuration__c>>mappingConfigurations = CORE_Subscribe_DAO.getMappingConfiguration(job.Subscribe_Object_gne__c);
        CORE_Subscribe_Metrics metrics;
        try {
            if (mode != null && mode == SubscribeMode.ASI) {
                metrics = executeSubscribe(parties, mappingConfigurations, job, SubscribeMode.ASI, new CORE_Subscribe_Metrics());
            } else {
                metrics = executeSubscribe(parties, mappingConfigurations, job, new CORE_Subscribe_Metrics());
            }
            CORE_Subscribe_Util.finishJob(job, metrics);
        } catch (Exception e) {
            String summary = e.getMessage() + '\n' + e.getStackTraceString();
            job.Summary_gne__c = summary;
            job.Status_gne__c = 'Error';
        }
        update job;
        return metrics;
    }

    private CORE_Subscribe_Metrics executeSubscribe(List<CORE_Pub_Party__c> parties, Map<String, List<CORE_Subscribe_Mapping_Configuration__c>> mappingConfigurations, CORE_Subscribe_Job__c job, SubscribeMode mode, CORE_Subscribe_Metrics metrics) {
        Set<Id> partyIds = new Set<Id>();
        for(CORE_Pub_Party__c party : parties) {
            partyIds.add(party.Id);
        }
        Map<Id, List<CORE_Pub_Location__c>> partyToLocs = CORE_Subscribe_DAO.getLocations(partyIds);
        return executeSubscribe(parties, partyToLocs, mappingConfigurations, job, mode, metrics);
    }

    private CORE_Subscribe_Metrics executeSubscribe(List<CORE_Pub_Party__c> parties, Map<Id, List<CORE_Pub_Location__c>> partyToLocations, Map<String, List<CORE_Subscribe_Mapping_Configuration__c>> mappingConfigurations, CORE_Subscribe_Job__c job, SubscribeMode mode, CORE_Subscribe_Metrics metrics) {
        //init
        globalCache = new Map<String, Map<String, Schema.SObjectField>>();
        CORE_Subscribe_Util.setSubscribeProcess(true);
        this.jobId = job.Id;
        this.subMode = mode;
        partiesMap = new Map<Id, CORE_Pub_Party__c>();
        for (CORE_Pub_Party__c party : parties) {
            resetParty(party);
            partiesMap.put(party.Id, party);
        }
        partyToExtIds = new Map<Id, List<CORE_Pub_External_Id__c>>();
        this.partyToLocations = partyToLocations;
        partyToLicenses = CORE_Subscribe_DAO.getLicenses(partiesMap.keySet());
        partyToProductPlans = CORE_Subscribe_DAO.getProductPlans(partiesMap.keySet());
        partyToTdddLicenses = CORE_Subscribe_DAO.getTdddLicenses(partiesMap.keySet());

        Map<String, List<SObject>> recordsToDelete = new Map<String, List<SObject>>();

        for (CORE_Pub_External_Id__c extId : [
                SELECT Id, Party_Id_ref_gne__c, Party_Id_gne__c, Cnncl_Enty_Type_gne__c, Ctrb_Src_gne__c, Ctrb_Src_Id_gne__c, Party_Location_Id_gne__c, Party_Location_Id_ref_gne__c
                FROM CORE_Pub_External_Id__c
                WHERE Party_Id_ref_gne__c IN :partiesMap.keySet()
        ]) {
            if (!partyToExtIds.containsKey(extId.Party_Id_ref_gne__c)) {
                partyToExtIds.put(extId.Party_Id_ref_gne__c, new List<CORE_Pub_External_Id__c>());
            }
            if (mode != SubscribeMode.ASI || extId.Cnncl_Enty_Type_gne__c == CNNCL_PARTY) {
                partyToExtIds.get(extId.Party_Id_ref_gne__c).add(extId);
            } else if (extId.Cnncl_Enty_Type_gne__c == CNNCL_PARTY_LOC) {
                Set<String>locations = new Set<String>();
                if (partyToLocations.containsKey(extId.Party_Id_ref_gne__c)) {
                    for (CORE_Pub_Location__c loc : partyToLocations.get(extId.Party_Id_ref_gne__c)) {
                        locations.add(loc.Party_Location_Id_gne__c);
                    }
                    if (locations.contains(extId.Party_Location_Id_gne__c)) {
                        partyToExtIds.get(extId.Party_Id_ref_gne__c).add(extId);
                    }
                }
            }
        }

        userCache = new Map<String, User>();
        interfaceCache = new Map<String, Object>();

        String retrieverClass = job.Subscribe_Object_gne__r.Retriever_Interface_gne__c;
        String validationClass = job.Subscribe_Object_gne__r.Validation_Interface_gne__c;
        String postprocessorClass = job.Subscribe_Object_gne__r.Postprocess_Interface_gne__c;

        partyToErrors = new Map<Id, List<CORE_Subscribe_Error__c>>();

        totalMetrics = metrics;
        totalMetrics.partiesNumber += parties.size();

        //validate
        validator = getValidator(validationClass);
        Map<Id, CORE_Subscribe_Error__c> validationErrors = validator.validate(parties, partyToExtIds, partyToLocations, partyToProductPlans, subMode);
        if (validationErrors != null) {
            if (totalMetrics.partyToValidationErrors == null) {
                totalMetrics.partyToValidationErrors = validationErrors;
            } else {
                totalMetrics.partyToValidationErrors.putAll(validationErrors);
            }
        }

        recordRetriever = getRecordRetriever(retrieverClass);
        recordRetriever.init(parties, partyToExtIds, partyToLocations, partyToProductPlans);
        Map<String, Map<String, Set<SObject>>>partyToAllRecords = new Map<String, Map<String, Set<SObject>>>();

        Map<String, Map<String, List<SObject>>> partyToRecords = new Map<String, Map<String, List<SObject>>>();
        Map<String, Map<String, List<SObject>>> partyLocationToRecords = new Map<String, Map<String, List<SObject>>>();
        Map<String, Map<String, List<SObject>>> licenseToRecords = new Map<String, Map<String, List<SObject>>>();
        Map<String, Map<String, List<SObject>>> extIdToRecords = new Map<String, Map<String, List<SObject>>>();
        Map<String, Map<String, List<SObject>>> productToRecords = new Map<String, Map<String, List<SObject>>>();

        for (CORE_Pub_Party__c party : parties) {
            Map<String, Set<SObject>> recordsToUpsert = new Map<String, Set<SObject>>();
            if (!validationErrors.containsKey(party.Id)) {
                if (mappingConfigurations.containsKey('CORE_Pub_Party__c')) {
                    Map<String, List<SObject>> objectNameToRecords = new Map<String, List<SObject>>();
                    for (CORE_Subscribe_Mapping_Configuration__c configuration : mappingConfigurations.get('CORE_Pub_Party__c')) {
                        if (String.isEmpty(configuration.Type_gne__c) || configuration.Type_gne__c == getConfigurationType(party)) {
                            List<SObject> existingRecords = getExistingRecords(null, party, configuration, objectNameToRecords.get(configuration.Target_Object_gne__c));
                            debug('Party: ' + party.Id + '. Existing records for party: ' + existingRecords);
                            List<SObject> records = processRecord(party, configuration, existingRecords, null, null);
                            if (records != null) {
                                if (!objectNameToRecords.containsKey(configuration.Target_Object_gne__c)) {
                                    objectNameToRecords.put(configuration.Target_Object_gne__c, new List<SObject>());
                                }
                                objectNameToRecords.get(configuration.Target_Object_gne__c).addAll(records);
                            }
                        }
                    }
                    partyToRecords.put(party.Id, objectNameToRecords);
                    addAllFromMapToMap(objectNameToRecords, recordsToUpsert);
                }

                if (mappingConfigurations.containsKey('CORE_Pub_Location__c') && !partyToErrors.containsKey(party.Id)) {
                    Map<String, List<SObject>> objectNameToRecords = new Map<String, List<SObject>>();
                    if (partyToLocations.containsKey(party.Id)) {
                        for (CORE_Pub_Location__c loc : partyToLocations.get(party.Id)) {
                            Map<String, List<SObject>> objectNameToRecordsForLoc = new Map<String, List<SObject>>();
                            for (CORE_Subscribe_Mapping_Configuration__c configuration : mappingConfigurations.get('CORE_Pub_Location__c')) {
                                List<SObject> existingRecords = getExistingRecords(party, loc, configuration, objectNameToRecords.get(configuration.Target_Object_gne__c));
                                debug('Party locaction: ' + loc.Id + '. Existing records for party location: ' + existingRecords);
                                List<SObject> records = processRecord(loc, configuration, existingRecords, partyToRecords.get(party.Id), null);
                                if (records != null) {
                                    if (!objectNameToRecords.containsKey(configuration.Target_Object_gne__c)) {
                                        objectNameToRecords.put(configuration.Target_Object_gne__c, new List<SObject>());
                                    }
                                    objectNameToRecords.get(configuration.Target_Object_gne__c).addAll(records);

                                    if (!objectNameToRecordsForLoc.containsKey(configuration.Target_Object_gne__c)) {
                                        objectNameToRecordsForLoc.put(configuration.Target_Object_gne__c, new List<SObject>());
                                    }
                                    objectNameToRecordsForLoc.get(configuration.Target_Object_gne__c).addAll(records);
                                }
                            }
                            partyLocationToRecords.put(loc.Id, objectNameToRecordsForLoc);
                        }
                    }
                    addAllFromMapToMap(objectNameToRecords, recordsToUpsert);
                }

                if (mappingConfigurations.containsKey('CORE_Pub_External_Id__c') && !partyToErrors.containsKey(party.Id) && partyToExtIds.containsKey(party.Id)) {
                    Map<String, List<SObject>> objectNameToRecords = new Map<String, List<SObject>>();
                    if (partyToExtIds.containsKey(party.Id)) {
                        for (CORE_Pub_External_Id__c extId : partyToExtIds.get(party.Id)) {
                            for (CORE_Subscribe_Mapping_Configuration__c configuration : mappingConfigurations.get('CORE_Pub_External_Id__c')) {
                                if (String.isEmpty(configuration.Type_gne__c) || configuration.Type_gne__c == getConfigurationType(extId)) {
                                    List<SObject>existingRecords = getExistingRecords(party, extId, configuration, objectNameToRecords.get(configuration.Target_Object_gne__c));
                                    debug('Publish external Id: ' + extId + '. Existing records for publish external Id: ' + existingRecords);

                                    List<SObject> records = processRecord(extId, configuration, existingRecords, partyToRecords.get(party.Id), partyLocationToRecords.get(extId.Party_Location_Id_ref_gne__c));

                                    if (records != null) {
                                        if (!objectNameToRecords.containsKey(configuration.Target_Object_gne__c)) {
                                            objectNameToRecords.put(configuration.Target_Object_gne__c, new List<SObject>());
                                        }
                                        objectNameToRecords.get(configuration.Target_Object_gne__c).addAll(records);
                                    }
                                }
                            }
                            //partyExtIdsRecords.put(extId.id, objectNameToRecords);
                        }
                    }
                    addAllFromMapToMap(objectNameToRecords, recordsToUpsert);
                }

                if (mappingConfigurations.containsKey('CORE_Pub_License__c') && !partyToErrors.containsKey(party.Id)) {
                    Map<String, List<SObject>> objectNameToRecords = new Map<String, List<SObject>>();
                    List<CORE_Pub_License__c> validLicenses = getValidLicenses(partyToLicenses.get(party.Id));

                    for (CORE_Pub_License__c license : validLicenses) {
                        for (CORE_Subscribe_Mapping_Configuration__c configuration : mappingConfigurations.get('CORE_Pub_License__c')) {
                            if (!configuration.Is_Full_Synchronization_gne__c) {
                                List<SObject> existingRecords = getExistingRecords(party, license, configuration, recordsToUpsert.get(configuration.Target_Object_gne__c));
                                List<SObject> records = processRecord(license, configuration, existingRecords, partyToRecords.get(party.Id), null);
                                if (records != null) {
                                    if (!objectNameToRecords.containsKey(configuration.Target_Object_gne__c)) {
                                        objectNameToRecords.put(configuration.Target_Object_gne__c, new List<SObject>());
                                    }
                                    objectNameToRecords.get(configuration.Target_Object_gne__c).addAll(records);
                                }
                            }
                        }
                    }
                    for (CORE_Subscribe_Mapping_Configuration__c configuration : mappingConfigurations.get('CORE_Pub_License__c')) {
                        if (configuration.Is_Full_Synchronization_gne__c) {
                            CORE_Subscribe_Interface.ExistingRecodsWrapper existingRecordsWrapper = getExistingRecords(party, validLicenses, configuration, recordsToUpsert.get(configuration.Target_Object_gne__c));
                            addRecordsToDelete(configuration.Target_Object_gne__c, recordsToDelete, existingRecordsWrapper.notMatchingRecords);
                            for (CORE_Pub_License__c license : validLicenses) {
                                List<SObject> existingRecords = null;
                                if (existingRecordsWrapper.existingRecords.containsKey(license.License_Number_gne__c)) {
                                    existingRecords = existingRecordsWrapper.existingRecords.get(license.License_Number_gne__c);
                                }
                                List<SObject> records = processRecord(license, configuration, existingRecords, partyToRecords.get(party.Id), null);
                                if (records != null) {
                                    if (!objectNameToRecords.containsKey(configuration.Target_Object_gne__c)) {
                                        objectNameToRecords.put(configuration.Target_Object_gne__c, new List<SObject>());
                                    }
                                    objectNameToRecords.get(configuration.Target_Object_gne__c).addAll(records);
                                }
                            }
                        }
                    }
                    addAllFromMapToMap(objectNameToRecords, recordsToUpsert);
                }

                if (mappingConfigurations.containsKey('CORE_Pub_Plan_Product__c') && !partyToErrors.containsKey(party.Id) && partyToProductPlans.containsKey(party.Id)) {
                    Map<String, List<SObject>>objectNameToRecords = new Map<String, List<SObject>>();
                    if (partyToProductPlans.containsKey(party.Id)) {
                        for (CORE_Pub_Plan_Product__c product : partyToProductPlans.get(party.Id)) {
                            for (CORE_Subscribe_Mapping_Configuration__c configuration : mappingConfigurations.get('CORE_Pub_Plan_Product__c')) {

                                List<SObject>existingRecords = getExistingRecords(party, product, configuration, recordsToUpsert.get(configuration.Target_Object_gne__c));
                                //debug('Publish product: ' + product.id + '. Existing records for publish product: ' + existingRecords);

                                List<SObject> records = processRecord(product, configuration, existingRecords, partyToRecords.get(party.Id), null);
                                //dirty hack to fix problem with inserting parent accounts and child accounts in one transaction
                                String objectName = 'CORE_Pub_Plan_Product__c' + configuration.Target_Object_gne__c;
                                if (records != null) {
                                    if (!objectNameToRecords.containsKey(objectName)) {
                                        objectNameToRecords.put(objectName, new List<SObject>());
                                    }
                                    objectNameToRecords.get(objectName).addAll(records);
                                }
                            }
                        }
                    }
                    addAllFromMapToMap(objectNameToRecords, recordsToUpsert);
                }

                if (mappingConfigurations.containsKey('CORE_Pub_TDDD_License__c') && !partyToErrors.containsKey(party.Id)) {
                    Map<String, List<SObject>> objectNameToRecords = new Map<String, List<SObject>>();
                    List<CORE_Pub_TDDD_License__c> validLicenses = getValidLicenses(partyToTdddLicenses.get(party.Id));
                    for (CORE_Pub_TDDD_License__c license : validLicenses) {
                        for (CORE_Subscribe_Mapping_Configuration__c configuration : mappingConfigurations.get('CORE_Pub_TDDD_License__c')) {
                            if (!configuration.Is_Full_Synchronization_gne__c) {
                                List<SObject> existingRecords = getExistingRecords(party, license, configuration, recordsToUpsert.get(configuration.Target_Object_gne__c));
                                List<SObject> records = processRecord(license, configuration, existingRecords, partyToRecords.get(party.Id), null);
                                if (records != null) {
                                    if (!objectNameToRecords.containsKey(configuration.Target_Object_gne__c)) {
                                        objectNameToRecords.put(configuration.Target_Object_gne__c, new List<SObject>());
                                    }
                                    objectNameToRecords.get(configuration.Target_Object_gne__c).addAll(records);
                                }
                            }
                        }
                    }
                    for (CORE_Subscribe_Mapping_Configuration__c configuration : mappingConfigurations.get('CORE_Pub_TDDD_License__c')) {
                        if (configuration.Is_Full_Synchronization_gne__c) {
                            CORE_Subscribe_Interface.ExistingRecodsWrapper existingRecordsWrapper = getExistingRecords(party, validLicenses, configuration, recordsToUpsert.get(configuration.Target_Object_gne__c));
                            addRecordsToDelete(configuration.Target_Object_gne__c, recordsToDelete, existingRecordsWrapper.notMatchingRecords);
                            for (CORE_Pub_TDDD_License__c license : validLicenses) {
                                List<SObject> existingRecords = null;
                                if (existingRecordsWrapper.existingRecords.containsKey(license.License_Number_gne__c)) {
                                    existingRecords = existingRecordsWrapper.existingRecords.get(license.License_Number_gne__c);
                                }
                                List<SObject> records = processRecord(license, configuration, existingRecords, partyToRecords.get(party.Id), null);
                                if (records != null) {
                                    if (!objectNameToRecords.containsKey(configuration.Target_Object_gne__c)) {
                                        objectNameToRecords.put(configuration.Target_Object_gne__c, new List<SObject>());
                                    }
                                    objectNameToRecords.get(configuration.Target_Object_gne__c).addAll(records);
                                }
                            }
                        }
                    }
                    addAllFromMapToMap(objectNameToRecords, recordsToUpsert);
                }

                partyToAllRecords.put(party.Id, recordsToUpsert);
            }
        }

        //posprocessor
        if (postprocessorClass != null) {
            CORE_Subscribe_Interface.Postporcessor postprocesssor = getPostprocessor(postprocessorClass);
            postprocesssor.processRecords(parties, partyToExtIds, partyToProductPlans, partyToRecords, partyLocationToRecords, extIdToRecords, licenseToRecords, productToRecords);
        }

        //Records have to be inserted in specific order - this two collections is used to create such order
        List<String>objectsToInsert = new List<String>();
        Set<String>objectsToInsertSet = new Set<String>();

        List<String>subscribeObjects = new List<String>{
                'CORE_Pub_Party__c', 'CORE_Pub_Location__c', 'CORE_Pub_External_Id__c', 'CORE_Pub_License__c', 'CORE_Pub_Plan_Product__c', 'CORE_Pub_TDDD_License__c'
        };

        //resolve the upsertion order
        for (String subscribeObject : subscribeObjects) {
            if (mappingConfigurations.containsKey(subscribeObject)) {
                for (CORE_Subscribe_Mapping_Configuration__c configuration : mappingConfigurations.get(subscribeObject)) {
                    String objectName = configuration.Target_Object_gne__c;
                    if (subscribeObject == 'CORE_Pub_Plan_Product__c') {
                        objectName = subscribeObject + objectName;
                    }
                    if (objectsToInsertSet.add(objectName)) {
                        objectsToInsert.add(objectName);
                    }
                }
            }
        }
        upsertRecords(partyToAllRecords, objectsToInsert);
        deleteRecords(recordsToDelete);
        updateParties(parties, validationErrors, partyToErrors);
        saveErrors(parties);
        if (totalMetrics.partyToErrors != null) {
            totalMetrics.partyToErrors.putAll(partyToErrors);
        } else {
            totalMetrics.partyToErrors = partyToErrors;
        }
        totalMetrics.errorsCount += partyToErrors.size();
        return totalMetrics;
    }

    private void addRecordsToDelete(String objectName, Map<String, List<SObject>> recordsToDeleteContainer, List<SObject> recordsToDelete) {
        if (!recordsToDeleteContainer.containsKey(objectName)) {
            recordsToDeleteContainer.put(objectName, recordsToDelete);
        } else {
            recordsToDeleteContainer.get(objectName).addAll(recordsToDelete);
        }
    }

    private List<CORE_Pub_License__c> getValidLicenses(List<CORE_Pub_License__c>licenses) {
        Map<String, CORE_Pub_License__c>validLicenses = new Map<String, CORE_Pub_License__c>();
        if (licenses != null) {
            for (CORE_Pub_License__c license : licenses) {
                if (!validLicenses.containsKey(license.License_State_gne__c)) {
                    validLicenses.put(license.License_State_gne__c, license);
                } else {
                    validLicenses.put(license.License_State_gne__c, getBestLicense(validLicenses.get(license.License_State_gne__c), license));
                }
            }
        }
        return validLicenses.values();
    }

    private CORE_Pub_License__c getBestLicense(CORE_Pub_License__c lic1, CORE_Pub_License__c lic2) {
        CORE_Pub_License__c license = lic1;
        if (lic1.Smpl_Ovrl_Elig_Flag_gne__c != 'Y' && lic2.Smpl_Ovrl_Elig_Flag_gne__c == 'Y') {
            license = lic2;
        } else if (lic1.Smpl_Ovrl_Elig_Flag_gne__c == 'Y' && lic2.Smpl_Ovrl_Elig_Flag_gne__c == 'Y') {
            if (lic2.Profsnl_Dsgt_Rk_Nbr_gne__c <= lic1.Profsnl_Dsgt_Rk_Nbr_gne__c && lic2.Exp_Date_gne__c >= lic1.Exp_Date_gne__c) {
                license = lic2;
            }
        }
        return license;
    }

    private List<CORE_Pub_TDDD_License__c> getValidLicenses(List<CORE_Pub_TDDD_License__c>licenses) {
        if (licenses == null) {
            return new List<CORE_Pub_TDDD_License__c>();
        }
        return licenses;
    }

    private void addAllFromMapToMap(Map<String, List<SObject>>srcMap, Map<String, Set<SObject>>targetMap) {
        for (String obj : srcMap.keySet()) {
            if (!targetMap.containsKey(obj)) {
                targetMap.put(obj, new Set<SObject>());
            }
            targetMap.get(obj).addAll(srcMap.get(obj));
        }
    }

    /*
    * partyToAllRecords - records to upsert
    * objectsToInsert - list with name of objects to insert - records have to be inserted in defined order
    */
    private void upsertRecords(Map<String, Map<String, Set<SObject>>>partyToAllRecords, List<String>objectsToInsert) {
        Set<UniqueObjectHelper>uniqueObjects = new Set<UniqueObjectHelper>();

        Map<String, Map<String, List<SObject>>>objectToRecords = new Map<String, Map<String, List<SObject>>>();
        for (String party : partyToAllRecords.keySet()) {
            for (String objName : partyToAllRecords.get(party).keySet()) {
                List<SObject>records = new List<SObject>();
                for (SObject obj : partyToAllRecords.get(party).get(objName)) {
                    UniqueObjectHelper uo = new UniqueObjectHelper(obj);
                    if (uniqueObjects.add(uo)) {
                        records.add(obj);
                    }
                }
                if (!records.isEmpty()) {
                    if (!objectToRecords.containsKey(objName)) {
                        objectToRecords.put(objName, new Map<String, List<SObject>>());
                    }
                    objectToRecords.get(objName).put(party, records);
                }
            }
        }

        for (String objName : objectsToInsert) {
            Map<Integer, String>indexesToPartyIdForInsert = new Map<Integer, String>();
            Map<Integer, String>indexesToPartyIdForUpdate = new Map<Integer, String>();
            List<SObject>recordsToInsert = new List<SObject>();
            List<SObject>recordsToUpdate = new List<SObject>();
            if (objectToRecords.containsKey(objName)) {
                for (String party : objectToRecords.get(objName).keySet()) {
                    //if there is no errors for party
                    if (!partyToErrors.containsKey(party) || partyToErrors.get(party).isEmpty()) {
                        for (SObject record : objectToRecords.get(objName).get(party)) {
                            if (record.Id != null) {
                                indexesToPartyIdForUpdate.put(recordsToUpdate.size(), party);
                                recordsToUpdate.add(record);
                            } else {
                                indexesToPartyIdForInsert.put(recordsToInsert.size(), party);
                                recordsToInsert.add(record);
                            }
                        }
                    }
                }
            }
            if (!recordsToUpdate.isEmpty()) {
                List<Database.SaveResult> updateResults = Database.update(recordsToUpdate, false);
                updateMetrics(objName, recordsToUpdate, updateResults, indexesToPartyIdForUpdate, MetricType.UPDATE_TYPE);
            }

            if (!recordsToInsert.isEmpty()) {
                List<Database.SaveResult> insertResults = Database.insert(recordsToInsert, false);
                updateMetrics(objName, recordsToInsert, insertResults, indexesToPartyIdForInsert, MetricType.INSERT_TYPE);
            }
        }
    }

    private void deleteRecords(Map<String, List<SObject>> recordsToDelete) {
        for (String objectName : recordsToDelete.keySet()) {
            if (!recordsToDelete.get(objectName).isEmpty()) {
                List<Database.DeleteResult> results = Database.delete(recordsToDelete.get(objectName), false);
                updateMetrics(objectName, recordsToDelete.get(objectName), results, null);
            }
        }
    }

    private void updateMetrics(String objName, List<SObject> upsertedRecords, List<Database.SaveResult> saveResults, Map<Integer, String> indexesToPartyId, MetricType mType) {
        List<CORE_Subscribe_Error__c>errors = new List<CORE_Subscribe_Error__c>();
        Integer iCount = 0;
        for (Database.SaveResult result : saveResults) {
            if (!result.isSuccess()) {
                String sErrorMsg = '';
                for (Database.Error err : result.getErrors()) {
                    if (String.isEmpty(sErrorMsg)) {
                        sErrorMsg = err.getStatusCode() + ' - ' + err.getMessage();
                    } else {
                        sErrorMsg += ' | ' + err.getStatusCode() + ' - ' + err.getMessage();
                    }
                }
                String title = sErrorMsg.abbreviate(255);
                sErrorMsg = sErrorMsg + ' | Record details >  ' + upsertedRecords[iCount];
                CORE_Pub_Party__c party = partiesMap.get(indexesToPartyId.get(iCount));
                CORE_Subscribe_Error__c error = createError(objName, upsertedRecords[iCount].Id, title, sErrorMsg, 'High');
                errors.add(error);
                addError(party, error);
            }
            iCount++;
        }

        CORE_Subscribe_Metrics metrics;
        for (CORE_Subscribe_Metrics m : totalMetrics.relatedMetrics) {
            if (m.targetObject == objName) {
                metrics = m;
            }
        }

        if (metrics == null) {
            metrics = new CORE_Subscribe_Metrics();
            metrics.mType = CORE_Subscribe_Metrics.MetricType.DETAIL;
            metrics.targetObject = objName;
            totalMetrics.relatedMetrics.add(metrics);
        }
        if (mType == MetricType.UPDATE_TYPE) {
            metrics.updateCount += (upsertedRecords.size() - errors.size());
        } else if (mType == MetricType.INSERT_TYPE) {
            metrics.insertCount += (upsertedRecords.size() - errors.size());
        }
        metrics.errorsCount += errors.size();
        metrics.upsertedRecords = upsertedRecords;
    }

    private void updateMetrics(String objName, List<SObject> deleteRecords, List<Database.DeleteResult> deleteResults, Map<Integer, String> indexesToPartyId) {
        List<CORE_Subscribe_Error__c>errors = new List<CORE_Subscribe_Error__c>();
        Integer iCount = 0;
        for (Database.DeleteResult result : deleteResults) {
            if (!result.isSuccess()) {
                String sErrorMsg = '';
                for (Database.Error err : result.getErrors()) {
                    if (String.isEmpty(sErrorMsg)) {
                        sErrorMsg = err.getStatusCode() + ' - ' + err.getMessage();
                    } else {
                        sErrorMsg += ' | ' + err.getStatusCode() + ' - ' + err.getMessage();
                    }
                }
                String title = sErrorMsg.abbreviate(255);
                sErrorMsg = sErrorMsg + ' | Record details >  ' + deleteRecords[iCount];
                //CORE_Pub_Party__c party = partiesMap.get(indexesToPartyId.get(iCount));
                CORE_Subscribe_Error__c error = createError(objName, deleteRecords[iCount].Id, title, sErrorMsg, 'High');
                errors.add(error);
                //addError(party, error);
            }
            iCount++;
        }

        CORE_Subscribe_Metrics metrics;
        for (CORE_Subscribe_Metrics m : totalMetrics.relatedMetrics) {
            if (m.targetObject == objName) {
                metrics = m;
            }
        }

        if (metrics == null) {
            metrics = new CORE_Subscribe_Metrics();
            metrics.mType = CORE_Subscribe_Metrics.MetricType.DETAIL;
            metrics.targetObject = objName;
            totalMetrics.relatedMetrics.add(metrics);
        }

        metrics.deleteCount += (deleteRecords.size() - errors.size());
        metrics.errorsCount += errors.size();
    }

    private void saveErrors(List<CORE_Pub_Party__c> parties) {
        List<CORE_Subscribe_Error__c>errors = new List<CORE_Subscribe_Error__c>();
        for (CORE_Pub_Party__c party : parties) {
            if (partyToErrors.containsKey(party.Id)) {
                for (CORE_Subscribe_Error__c error : partyToErrors.get(party.Id)) {
                    error.Party_gne__c = party.Id;
                    error.Subscribe_Job_gne__c = jobId;
                    errors.add(error);
                }
            }
        }
        Database.insert(errors, false);
    }

    private List<SObject> getExistingRecords(CORE_Pub_Party__c parentParty, SObject publishRecord, CORE_Subscribe_Mapping_Configuration__c configuration, List<SObject>subscribeRecords) {
        Set<SObject> subscribeRecordsSet;
        if (subscribeRecords != null) {
            subscribeRecordsSet = new Set<SObject>(subscribeRecords);
        } else {
            subscribeRecordsSet = new Set<SObject>();
        }
        return getExistingRecords(parentParty, publishRecord, configuration, subscribeRecordsSet);
    }

    private List<SObject> getExistingRecords(CORE_Pub_Party__c parentParty, SObject publishRecord, CORE_Subscribe_Mapping_Configuration__c configuration, Set<SObject>subscribeRecords) {
        try {
            return recordRetriever.getExistingObjects(parentParty, publishRecord, configuration, subscribeRecords);
        } catch (Exception e) {
            debug('Exceptions occurs: ' + e.getMessage() + '\n' + e.getStackTraceString());
            debug('Exceptions occurs: ' + publishRecord);
            addError(publishRecord, e);
        }
        return null;
    }

    private CORE_Subscribe_Interface.ExistingRecodsWrapper getExistingRecords(CORE_Pub_Party__c parentParty, List<SObject> publishRecords, CORE_Subscribe_Mapping_Configuration__c configuration, List<SObject>subscribeRecords) {
        Set<SObject> subscribeRecordsSet;
        if (subscribeRecords != null) {
            subscribeRecordsSet = new Set<SObject>(subscribeRecords);
        } else {
            subscribeRecordsSet = new Set<SObject>();
        }
        return getExistingRecords(parentParty, publishRecords, configuration, subscribeRecordsSet);
    }

    private CORE_Subscribe_Interface.ExistingRecodsWrapper getExistingRecords(CORE_Pub_Party__c parentParty, List<SObject> publishRecords, CORE_Subscribe_Mapping_Configuration__c configuration, Set<SObject>subscribeRecords) {
        try {
            return recordRetriever.getExistingObjects(parentParty, publishRecords, configuration, subscribeRecords);
        } catch (Exception e) {
            debug('Exceptions occurs: ' + e.getMessage() + '\n' + e.getStackTraceString());
            addError(parentParty, e);
        }
        return null;
    }

    private CORE_Pub_Party__c getParentParty(SObject publishRecord) {
        CORE_Pub_Party__c party;
        if (publishRecord instanceof CORE_Pub_Party__c) {
            party = (CORE_Pub_Party__c) publishRecord;
        } else {
            String partyId = (String) publishRecord.get(PARTY_REFERENCE_API_NAME);
            party = partiesMap.get(partyId);
        }
        return party;
    }

    /*Return records created or updated based on passing arguments. Can return null. */
    private List<SObject> processRecord(SObject publishRecord, CORE_Subscribe_Mapping_Configuration__c configuration, List<SObject> existingRecords, Map<String, List<SObject>>partyRecords, Map<String, List<SObject>>partyLocationRecords) {
        List<SObject>recordsToUpsert;
        try {
            if (existingRecords != null && !existingRecords.isEmpty()) {
                if (validator.canUpdateRecord(getParentParty(publishRecord), publishRecord, configuration, existingRecords, subMode)) {
                    recordsToUpsert = updateRecords(publishRecord, existingRecords, configuration);
                }
            } else if (configuration.Create_New_Record_gne__c && validator.canCreateNewObject(getParentParty(publishRecord), publishRecord, configuration, subMode)) {
                SObject rec = createNewObject(publishRecord, configuration, partyRecords, partyLocationRecords);
                if (rec != null) {
                    recordsToUpsert = new List<SObject>{
                            rec
                    };
                }
            }
        } catch (Exception e) {
            debug('Exceptions occurs: ' + e.getMessage() + '\n' + e.getStackTraceString());
            debug('Exceptions occurs publishRecord: ' + publishRecord);
            addError(publishRecord, e);
        }
        return recordsToUpsert;
    }

    private void updateParties(List<CORE_Pub_Party__c> parties, Map<Id, CORE_Subscribe_Error__c>validationErrors, Map<Id, List<CORE_Subscribe_Error__c>> partyToErrors) {
        Integer maxLength = 254;
        Datetime now = Datetime.now();
        for (CORE_Pub_Party__c party : parties) {
            party.Last_Sub_Exec_gne__c = now;

            if (validationErrors.containsKey(party.Id)) {
                party.Sub_Exec_Status_gne__c = STATUS_ERROR;
                if (validationErrors.get(party.Id).Description_gne__c.length() > maxLength) {
                    party.Comments_gne__c = validationErrors.get(party.Id).Description_gne__c.substring(0, maxLength);
                } else {
                    party.Comments_gne__c = validationErrors.get(party.Id).Description_gne__c;
                }
            }

            if (partyToErrors.containsKey(party.Id)) {
                party.Sub_Exec_Status_gne__c = STATUS_ERROR;
                if (partyToErrors.get(party.Id).get(0).Description_gne__c.length() > maxLength) {
                    party.Comments_gne__c = partyToErrors.get(party.Id).get(0).Description_gne__c.substring(0, maxLength);
                } else {
                    party.Comments_gne__c = partyToErrors.get(party.Id).get(0).Description_gne__c;
                }
            }
        }
        Database.update(parties, false);
    }

    /*Reset comments and set status to success, if error occurs it will be changed to error.*/
    private void resetParty(CORE_Pub_Party__c party) {
        party.Comments_gne__c = '';
        party.Sub_Exec_Status_gne__c = STATUS_SUCCESS;
    }

    private void addError(SObject publishRecord, Exception e) {
        CORE_Pub_Party__c party = getParentParty(publishRecord);
        String objectName = publishRecord.getSObjectType().getDescribe().getName();
        CORE_Subscribe_Error__c error = createError(objectName, publishRecord.Id, e.getLineNumber() + ': ' + e.getMessage() + '\n' + e.getStackTraceString(), 'High');
        addError(party, error);
    }

    private CORE_Subscribe_Interface.Validator getValidator(String className) {
        return (CORE_Subscribe_Interface.Validator) getInterfaceImplementation(className);
    }

    private CORE_Subscribe_Interface.Record_Retriever getRecordRetriever(String className) {
        return (CORE_Subscribe_Interface.Record_Retriever) getInterfaceImplementation(className);
    }

    private CORE_Subscribe_Interface.Postporcessor getPostprocessor(String className) {
        return (CORE_Subscribe_Interface.Postporcessor) getInterfaceImplementation(className);
    }

    private CORE_Subscribe_Interface.Record_Handler getRecordHandler(String className) {
        return (CORE_Subscribe_Interface.Record_Handler) getInterfaceImplementation(className);
    }

    private CORE_Subscribe_Interface.Field_Handler getFieldHandler(String className) {
        return (CORE_Subscribe_Interface.Field_Handler) getInterfaceImplementation(className);
    }

    private Object getInterfaceImplementation(String className) {
        if (!interfaceCache.containsKey(className)) {
            interfaceCache.put(className, Type.forName(className).newInstance());
        }
        return interfaceCache.get(className);
    }

    private List<SObject> updateRecords(SObject sourceObject, List<SObject> targetObjects, CORE_Subscribe_Mapping_Configuration__c configuration) {
        if (configuration.Handler_gne__c != null) {
            for (SObject targetObject : targetObjects) {
                handleRecord(sourceObject, targetObject, configuration);
            }
        }
        for (CORE_Subscribe_Field_Configuration_gne__c fc : configuration.Field_Configurations__r) {
            for (SObject targetObject : targetObjects) {
                setValue(sourceObject, targetObject, fc, true, null);
            }
        }
        //debug('Updated record: ' + targetObjects);
        return targetObjects;
    }

    private SObject createNewObject(SObject sourceObject, CORE_Subscribe_Mapping_Configuration__c configuration, Map<String, List<SObject>>partyRecords, Map<String, List<SObject>>partyLocationRecords) {
        SObject parentRecord;
        SObject record = (SObject) Type.forName(configuration.Target_Object_gne__c).newInstance();
        if (configuration.Handler_gne__c != null) {
            handleRecord(sourceObject, record, configuration);
        }
        setRecordOwner(record, configuration);
        for (CORE_Subscribe_Field_Configuration_gne__c fc : configuration.Field_Configurations__r) {

            if (isParentChildRelation(fc)) {
                if (fc.Source_Field_gne__c == PARTY_REFERENCE_API_NAME) {
                    List<SObject>parents = partyRecords.get(fc.Parent_Object_gne__c);
                    parentRecord = parents.get(0);
                } else if (fc.Source_Field_gne__c == PARTY_LOCATION_REFERENCE_API_NAME) {
                    //skip record
                    if (partyLocationRecords == null || partyLocationRecords.get(fc.Parent_Object_gne__c) == null) {
                        debug('Cannot create record for source object: ' + sourceObject + ' and configuration: ' + configuration + '. Reason - parent record not found');
                        return null;
                    }
                    parentRecord = partyLocationRecords.get(fc.Parent_Object_gne__c).get(0);
                }
            }
            setValue(sourceObject, record, fc, false, parentRecord);
        }
//		debug('New record: ' + record);
        return record;
    }

    private void handleRecord(SObject sourceObject, SObject targetObject, CORE_Subscribe_Mapping_Configuration__c configuration) {
        //debug('Handle record: ' + configuration.Handler_gne__c);
        CORE_Subscribe_Interface.Record_Handler handler = getRecordHandler(configuration.Handler_gne__c);
        handler.handle(sourceObject, targetObject);
    }

    private void setValue(SObject sourceObject, SObject targetObject, CORE_Subscribe_Field_Configuration_gne__c fc, Boolean isUpdate, SObject parentRecord) {
        Boolean enableUpdate = fc.Overwrite_Type_gne__c != OVERWRITE_NULL || targetObject.get(fc.Target_Field_gne__c) == null || (!isUpdate && fc.Handler_gne__c == 'CORE_Subscribe_Field_Handler_Concatenate');
        if (enableUpdate) {
            if (!isUpdate && isParentChildRelation(fc) && sourceObject.get(fc.Source_Field_gne__c) != null) {
                if (parentRecord != null) {
                    if (parentRecord.Id == null) {
                        SObject tmp = (SObject) Type.forName(fc.Parent_Object_gne__c).newInstance();
                        tmp.put(fc.Parent_External_Field_Name_gne__c, parentRecord.get(fc.Parent_External_Field_Name_gne__c));

                        Map<String, Schema.SObjectField> fsMap = globalCache.get(fc.Mapping_Configuration_gne__r.Target_Object_gne__c);
                        if (fsMap == null) {
                            fsMap = Schema.getGlobalDescribe().get(fc.Mapping_Configuration_gne__r.Target_Object_gne__c).getDescribe().fields.getMap();
                            globalCache.put(fc.Mapping_Configuration_gne__r.Target_Object_gne__c, fsMap);
                        }
                        String relationshipName = fsMap.get(fc.Target_Field_gne__c).getDescribe().getRelationshipName();
                        targetObject.putSObject(relationshipName, tmp);
                    } else {
                        targetObject.put(fc.Target_Field_gne__c, parentRecord.Id);
                    }
                }
            } else if (isHandler(fc)) {
                targetObject.put(fc.Target_Field_gne__c, getHandlerValue(sourceObject, targetObject, fc));
            } else if (isReference(fc)) {
                targetObject.put(fc.Target_Field_gne__c, getReferenceValue(fc, sourceObject));
            } else {
                targetObject.put(fc.Target_Field_gne__c, getConvertedValue(sourceObject.get(fc.Source_Field_gne__c), fc.Mapping_Configuration_gne__r.Target_Object_gne__c, fc.Target_Field_gne__c));
            }
        }
    }

    private Object getConvertedValue(Object value, String objectName, String fieldName) {
        Map<String, Schema.SObjectField> fsMap = globalCache.get(objectName);
        if (fsMap == null) {
            fsMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
            globalCache.put(objectName, fsMap);
        }
        Schema.DisplayType fType = fsMap.get(fieldName).getDescribe().getType();

        if (fType == Schema.DisplayType.DOUBLE) {
            value = Double.valueOf(value);
        } else if (fType == Schema.DisplayType.STRING) {
            if (value == null) {
                value = '';
            } else {
                value = String.valueOf(value);
            }
        }
        return value;
    }

    private void setRecordOwner(SObject record, CORE_Subscribe_Mapping_Configuration__c configuration) {
        if (String.isNotEmpty(configuration.Default_Record_Owner_gne__c)) {
            record.put('OwnerId', getUserId(configuration.Default_Record_Owner_gne__c));
        }
    }

    private String getUserId(String exteranlId) {
        if (!userCache.containsKey(exteranlId)) {
            List<User> sfdcUserIdList = recordRetriever.fetchUsers(new List<String>{
                    exteranlId
            });
            if (sfdcUserIdList.size() > 0) {
                userCache.put(exteranlId, sfdcUserIdList[0]);
            }
        }
        return userCache.get(exteranlId).Id;
    }

    private Boolean isParentChildRelation(CORE_Subscribe_Field_Configuration_gne__c fieldConfiguration) {
        return !String.isEmpty(fieldConfiguration.Parent_Object_gne__c);
    }

    private Boolean isHandler(CORE_Subscribe_Field_Configuration_gne__c fieldConfiguration) {
        return !String.isEmpty(fieldConfiguration.Handler_gne__c);
    }

    private Boolean isReference(CORE_Subscribe_Field_Configuration_gne__c fieldConfiguration) {
        return !String.isEmpty(fieldConfiguration.Reference_CustomSetting_gne__c);
    }

    private Object getConfigurationType(SObject sourceObject) {
        return validator.getConfigurationType(sourceObject);
    }

    /**
    Return value using reference tables to translate codes.
    @param fc	field configuration contains refenece table name and column
    @param sourceObject	source value
    @return translated value
    */
    public static String getReferenceValue(CORE_Subscribe_Field_Configuration_gne__c fc, SObject sourceObject) {
        String result = '';
        if (sourceObject.get(fc.Source_Field_gne__c) == null) {
            result = '';
        } else if (fc.Source_Field_gne__c.contains('_json')) {
            List<JsonList>values = (List<JsonList>) JSON.deserialize((String) sourceObject.get(fc.Source_Field_gne__c), List<JsonList>.class);
            Map<String, Object> codeMapping = CORE_Subscribe_DAO.getCodeMapping(fc.Reference_CustomSetting_gne__c, fc.Reference_Field_gne__c);
            for (JsonList value : values) {
                result += codeMapping.containsKey(value.code) ? codeMapping.get(value.code) : value.code;
                result += ';';
            }
            result = result.substring(0, result.length() - 1);
        } else {
            Map<String, Object> codeMapping = CORE_Subscribe_DAO.getCodeMapping(fc.Reference_CustomSetting_gne__c, fc.Reference_Field_gne__c);
            Object mappingValue = codeMapping.get((String) sourceObject.get(fc.Source_Field_gne__c));
            result = mappingValue != null ? (String) mappingValue : (String) sourceObject.get(fc.Source_Field_gne__c);
        }
        //debug('Field confinguration: ' + fc);
        //debug('sourceObject: ' + sourceObject);
        //debug('Reference value: ' + result);
        return result;
    }

    /**
    Return source value transofrmed by handler. Handler name is set in configuration.
    @param fc	field configuration contains handler name
    @param sourceObject	source value being transformed by handler
    @return value tranformed by handler
    */
    private Object getHandlerValue(SObject sourceObject, SObject targetObject, CORE_Subscribe_Field_Configuration_gne__c fc) {
        CORE_Subscribe_Interface.Field_Handler handler = getFieldHandler(fc.Handler_gne__c);
        return handler.handle(sourceObject, targetObject, fc);
    }

    private void addError(CORE_Pub_Party__c party, CORE_Subscribe_Error__c error) {
        if (!partyToErrors.containsKey(party.Id)) {
            partyToErrors.put(party.Id, new List<CORE_Subscribe_Error__c>());
        }
        partyToErrors.get(party.Id).add(error);
    }

    public class UniqueObjectHelper {
        public SObject myObject;

        public UniqueObjectHelper(SObject obj) {
            this.myObject = obj;
        }

        public Boolean equals(Object obj) {
            UniqueObjectHelper tmp = (UniqueObjectHelper) obj;
            if (myObject.Id != null && tmp.myObject.Id != null && myObject.Id == tmp.myObject.Id) {
                return true;
            }
            return myObject === tmp.myObject;
        }

        public Integer hashCode() {
            Integer result;
            if (myObject.Id != null) {
                result = System.hashCode(String.valueOf(myObject.Id));
            } else {
                result = System.hashCode(myObject.getSObjectType().getDescribe().getName());
            }
            return result;
        }
    }
}