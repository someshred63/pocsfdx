public without sharing class CORE_Subscribe_Util {

    public static final Integer DEFAULT_AUTO_SUB_BATCH_NUMBER_IND = 8;
    public static final Integer DEFAULT_AUTO_SUB_BATCH_NUMBER_ORG = 2;

    private static Boolean isSubscribeProcess;
    private static Integer numberOfAutoSubBatches;

    public static void setSubscribeProcess(Boolean isSubscribe) {
        isSubscribeProcess = isSubscribe;
    }

    public static Boolean isSubscribeProcess() {
        return isSubscribeProcess == true;
    }

    public static Integer getNumberOfAutoSubBatches() {
        if (numberOfAutoSubBatches != null) {
            return numberOfAutoSubBatches;
        } else {
            Integer numberOfAutoSubBatchesInd = CORE_Found_Misc_Config__c.getValues('NumberOfParallelAutoSubBatchesInd') != null ? Integer.valueOf(CORE_Found_Misc_Config__c.getValues('NumberOfParallelAutoSubBatchesInd').Configuration_Value_gne__c) : DEFAULT_AUTO_SUB_BATCH_NUMBER_IND;
            Integer numberOfAutoSubBatchesOrg = CORE_Found_Misc_Config__c.getValues('NumberOfParallelAutoSubBatchesOrg') != null ? Integer.valueOf(CORE_Found_Misc_Config__c.getValues('NumberOfParallelAutoSubBatchesOrg').Configuration_Value_gne__c) : DEFAULT_AUTO_SUB_BATCH_NUMBER_ORG;
            numberOfAutoSubBatches = numberOfAutoSubBatchesInd + numberOfAutoSubBatchesOrg;
            return numberOfAutoSubBatches;
        }
    }

    public static Id prepareSubscribeJobId(String jobName) {
        Id subscribeObjectId = [SELECT Id FROM CORE_Subscribe_Object__c LIMIT 1].Id;
        Core_Subscribe_Job__c subscribeJob = new Core_Subscribe_Job__c(
                Name = jobName + ' ' + Datetime.now().format('MM/dd/yyyy hh:mm a'),
                Status_gne__c = 'In Progress',
                Subscribe_Object_gne__c = subscribeObjectId
        );

        insert subscribeJob;

        return subscribeJob.Id;
    }

    /*
    * Prepare base string query for Party
    */
    public static String getPartyBaseQuery() {
        return 'SELECT Id, Alt_Names_json_gne__c, Birthdate_gne__c, Comm_Channel_json_gne__c, Credentials_json_gne__c, Do_Not_Contact_gne__c, ' +
                'Education_json_gne__c, FirstName_gne__c, Gender_gne__c, LastName_gne__c, Mdm_Id_gne__c, Mdm_Updt_Date_gne__c, ' +
                'MiddleName_gne__c, Org_Name_gne__c, Org_Type_json_gne__c, Party_Id_gne__c, PDRP_Opt_Out_Date_gne__c, PDRP_Opt_Out_gne__c, ' +
                'Prof_Type_json_gne__c, Salutation_gne__c, Specialties_json_gne__c, Status_gne__c, Suffix_gne__c, Type_gne__c, ' +
                '(SELECT Id,  Party_Id_gne__c, Party_Id_ref_gne__c, Bldg_Desc_gne__c, Bldg_Fl_Desc_gne__c, City_gne__c, Comm_Chan_json_gne__c, Country_gne__c, Default_gne__c, ' +
                'Latitude_gne__c, Loc_Use_json_gne__c, Longitude_gne__c, MDM_Id_gne__c, MDM_Status_gne__c, Party_Location_Id_gne__c, State_gne__c, Street_gne__c, ' +
                'Unit_Type_gne__c, Unit_Value_gne__c, Zip_4_gne__c, Zip_gne__c FROM Publish_Party_Locations__r), ' +
                '(SELECT Id, Party_Id_ref_gne__c, Party_Id_gne__c, Party_Id_ref_gne__r.MDM_Id_gne__c, Adj_Lic_Exp_Date_gne__c, Designation_gne__c, Exp_Date_gne__c, Grace_Period_gne__c, Name, License_Number_gne__c, License_State_gne__c, License_Status_gne__c, Smpl_Ovrl_Elig_Flag_gne__c, Profsnl_Dsgt_Rk_Nbr_gne__c, Profsnl_Dsgt_Fm_gne__c FROM Publish_Licenses__r) ' +
                'FROM CORE_Pub_Party__c';
    }

    public static Database.QueryLocator fetchPartiesByTimestamp(Datetime startTimestamp, Datetime endTimestamp) {
        String query = getPartyBaseQuery();

        if (startTimestamp != null || endTimestamp != null) {
            query += ' WHERE ';

            if (startTimestamp != null) {
                query += 'Last_Pub_Upsert_Date_gne__c >= :startTimestamp ';
            }
            if (endTimestamp != null && startTimestamp != null) {
                query += 'AND Last_Pub_Upsert_Date_gne__c <= :endTimestamp ';
            } else if (endTimestamp != null) {
                query += 'Last_Pub_Upsert_Date_gne__c <= :endTimestamp ';
            }
        }

        return Database.getQueryLocator(query);
    }

    public static Database.QueryLocator fetchPartiesByTimestampAndType(Datetime startTimestamp, Datetime endTimestamp, String partyType) {
        String query = getPartyBaseQuery();

        if (startTimestamp != null || endTimestamp != null || String.isNotBlank(partyType)) {
            query += ' WHERE ';

            if (startTimestamp != null) {
                query += 'Last_Pub_Upsert_Date_gne__c >= :startTimestamp ';
            }

            if (endTimestamp != null && startTimestamp != null) {
                query += 'AND Last_Pub_Upsert_Date_gne__c <= :endTimestamp ';
            } else if (endTimestamp != null) {
                query += 'Last_Pub_Upsert_Date_gne__c <= :endTimestamp ';
            }

            if (startTimestamp != null && endTimestamp != null && String.isNotBlank(partyType)) {
                query += 'AND Type_gne__c = :partyType ';
            } else if ((startTimestamp != null && String.isNotBlank(partyType)) || (endTimestamp != null && String.isNotBlank(partyType))) {
                query += 'AND Type_gne__c = :partyType ';
            } else if (String.isNotBlank(partyType)) {
                query += 'Type_gne__c = :partyType ';
            }

        }

        return Database.getQueryLocator(query);
    }

    public static Database.QueryLocator fetchPartiesByIds(Set<Id> partyIds) {
        String query = getPartyBaseQuery() + ' WHERE Id IN :partyIds';
        return Database.getQueryLocator(query);
    }

    public static String getDurationDescription(DateTime startDate, DateTime endDate) {
        Long diffMillis = endDate.getTime() - startDate.getTime();
        DateTime diffDate = DateTime.newInstance(diffMillis);
        List<String> listOfDateComponents = new List<String>{
                'day', 'hour', 'minute', 'second'
        };
        Map<String, Integer> componentValues = new Map<String, Integer>{
                'day' => diffDate.dayGmt() - 1,
                'hour' => diffDate.hourGmt(),
                'minute' => diffDate.minuteGmt(),
                'second' => diffDate.secondGmt()
        };

        List<String> componentValuesList = new List<String>();
        Boolean isSomethingAdded = false;

        for (String componentType : listOfDateComponents) {
            Integer componentValue = componentValues.get(componentType);
            if (componentValue != 0 || (isSomethingAdded == false && componentType == 'second')) {
                isSomethingAdded = true;
                componentValuesList.add(String.format('{0} {1}{2}', new String[]{
                        String.valueOf(componentValue), componentType, componentValue > 1 ? 's' : ''
                }));
            }
        }

        return String.join(componentValuesList, ' ');
    }

    public static void addIdToJSONBatchIds(Id subscribeJobId, Id batchId) {
        Core_Subscribe_Job__c sJob = [SELECT Batch_Ids_json_gne__c FROM Core_Subscribe_Job__c WHERE Id = :subscribeJobId LIMIT 1];

        if (String.isBlank(sJob.Batch_Ids_json_gne__c)) {
            sJob.Batch_Ids_json_gne__c = '["' + batchId + '"]';
        } else {
            List<String> bIds = (List<String>) JSON.deserialize(sJob.Batch_Ids_json_gne__c, List<String>.class);
            bIds.add(batchId);

            sJob.Batch_Ids_json_gne__c = JSON.serialize(bIds);
        }

        update sJob;

    }

    /*Check how many subscribe auto batches is running. If only one than return true */
    public static Boolean isLastAutoBatch(Core_Subscribe_Job__c sJob) {
        if (String.isNotBlank(sJob.Batch_Ids_json_gne__c)) {
            List<String> bIds = (List<String>) JSON.deserialize(sJob.Batch_Ids_json_gne__c, List<String>.class);
            List<AsyncApexJob> apexJobs = [SELECT Id FROM AsyncApexJob WHERE Id IN :bIds AND Status NOT IN ('Aborted', 'Completed', 'Failed')];
            return bIds.size() == getNumberOfAutoSubBatches() && apexJobs.isEmpty();
        } else {
            return false;
        }
    }

    public static void addJSONMetricsToSubJob(Core_Subscribe_Job__c subscribeJob, CORE_Subscribe_Metrics metrics) {
        if (String.isNotBlank(subscribeJob.Subscribe_Metrics_json_gne__c)) {
            subscribeJob.Subscribe_Metrics_json_gne__c += ',' + JSON.serialize(metrics);
        } else {
            subscribeJob.Subscribe_Metrics_json_gne__c = JSON.serialize(metrics);
        }
        update subscribeJob;
    }

    /*Methods change job status, update status fields and metrics fields.*/
    public static void finishJob(Core_Subscribe_Job__c subscribeJob, CORE_Subscribe_Metrics metrics) {
        metrics.endTime = Datetime.now();
        subscribeJob.Subscribe_Metrics_json_gne__c = JSON.serialize(metrics);
        subscribeJob.Parties_Count_gne__c = metrics.partiesNumber;
        subscribeJob.Success_Count_gne__c = metrics.partiesNumber - (metrics.validationErrors + metrics.errorsCount);
        subscribeJob.Validation_Errors_Count_gne__c = metrics.validationErrors;
        subscribeJob.Summary_gne__c = CORE_Subscribe_Base.printMetrics(metrics);
        subscribeJob.Status_gne__c = 'Completed';
        update subscribeJob;
    }

    public static CORE_Subscribe_Metrics mergeMetrics(Core_Subscribe_Job__c sJob) {
        CORE_Subscribe_Metrics allMetrics = new CORE_Subscribe_Metrics();
        allMetrics.mType = CORE_Subscribe_Metrics.MetricType.TOTAL;

        Map<String, CORE_Subscribe_Metrics>objectToMetrics = new Map<String, CORE_Subscribe_Metrics>();

        for (CORE_Subscribe_Metrics metrics : (List<CORE_Subscribe_Metrics>) JSON.deserialize('[' + sJob.Subscribe_Metrics_json_gne__c + ']', List<CORE_Subscribe_Metrics>.class)) {
            if (metrics.partyToErrors == null) {
                metrics.partyToErrors = new Map<Id, List<CORE_Subscribe_Error__c>>();
            }
            if (metrics.partyToValidationErrors == null) {
                metrics.partyToValidationErrors = new Map<Id, CORE_Subscribe_Error__c>();
            }
            if (CORE_Subscribe_Metrics.MetricType.TOTAL == metrics.mType) {
                allMetrics.partiesNumber += metrics.partiesNumber;
                allMetrics.validationErrors += metrics.validationErrors;
                allMetrics.insertCount += metrics.insertCount;
                allMetrics.updateCount += metrics.updateCount;
                allMetrics.errorsCount += metrics.errorsCount;
                if (allMetrics.endTime == null || metrics.endTime > allMetrics.endTime) {
                    allMetrics.endTime = metrics.endTime;
                }
                if (allMetrics.startTime == null || metrics.startTime < allMetrics.startTime) {
                    allMetrics.startTime = metrics.startTime;
                }
                for (CORE_Subscribe_Metrics detailMetrics : metrics.relatedMetrics) {
                    if (detailMetrics.partyToErrors == null) {
                        detailMetrics.partyToErrors = new Map<Id, List<CORE_Subscribe_Error__c>>();
                    }
                    if (detailMetrics.partyToValidationErrors == null) {
                        detailMetrics.partyToValidationErrors = new Map<Id, CORE_Subscribe_Error__c>();
                    }
                    if (objectToMetrics.containsKey(detailMetrics.sourceObject + detailMetrics.targetObject)) {
                        CORE_Subscribe_Metrics m = objectToMetrics.get(detailMetrics.sourceObject + detailMetrics.targetObject);
                        m.insertCount += detailMetrics.insertCount;
                        m.updateCount += detailMetrics.updateCount;
                        m.errorsCount += detailMetrics.errorsCount;
                    } else {
                        objectToMetrics.put(detailMetrics.sourceObject + detailMetrics.targetObject, detailMetrics);
                    }
                }
            }
        }
        allMetrics.relatedMetrics.addAll(objectToMetrics.values());
        return allMetrics;
    }

    /*Merge mainMetrics with metrics and return mainMetrics */
    public static CORE_Subscribe_Metrics mergeMetrics(CORE_Subscribe_Metrics metrics, CORE_Subscribe_Metrics mainMetrics) {

        Map<String, CORE_Subscribe_Metrics>objectToMetrics = new Map<String, CORE_Subscribe_Metrics>();

        mainMetrics.partiesNumber += metrics.partiesNumber;
        mainMetrics.validationErrors += metrics.validationErrors;
        mainMetrics.insertCount += metrics.insertCount;
        mainMetrics.updateCount += metrics.updateCount;
        mainMetrics.errorsCount += metrics.errorsCount;
        mainMetrics.deleteCount += metrics.deleteCount;
        mainMetrics.summary += metrics.summary;
        if (metrics.partyToErrors != null) {
            for (Id partyId : metrics.partyToErrors.keySet()) {
                if (mainMetrics.partyToErrors.containsKey(partyId)) {
                    mainMetrics.partyToErrors.get(partyId).addAll(metrics.partyToErrors.get(partyId));
                } else {
                    mainMetrics.partyToErrors.put(partyId, metrics.partyToErrors.get(partyId));
                }
            }
        }
        if (metrics.partyToValidationErrors != null) {
            mainMetrics.partyToValidationErrors.putAll(metrics.partyToValidationErrors);
        }
        if (metrics.upsertedRecords != null) {
            mainMetrics.upsertedRecords.addAll(metrics.upsertedRecords);
        }

        if (mainMetrics.endTime == null || metrics.endTime > mainMetrics.endTime) {
            mainMetrics.endTime = metrics.endTime;
        }

        if (mainMetrics.startTime == null || metrics.startTime < mainMetrics.startTime) {
            mainMetrics.startTime = metrics.startTime;
        }
        if (metrics.relatedMetrics != null) {
            for (CORE_Subscribe_Metrics detailMetrics : metrics.relatedMetrics) {
                Boolean contains = false;
                for (CORE_Subscribe_Metrics detailMetrics2 : mainMetrics.relatedMetrics) {
                    if (detailMetrics.sourceObject == detailMetrics2.sourceObject && detailMetrics.targetObject == detailMetrics2.targetObject) {
                        detailMetrics2.insertCount += detailMetrics.insertCount;
                        detailMetrics2.updateCount += detailMetrics.updateCount;
                        detailMetrics2.errorsCount += detailMetrics.errorsCount;
                        detailMetrics2.upsertCount += detailMetrics.upsertCount;
                        detailMetrics2.deleteCount += detailMetrics.deleteCount;
                        contains = true;
                    }
                }
                if (!contains) {
                    mainMetrics.relatedMetrics.add(detailMetrics);
                }
            }
        }
        return mainMetrics;
    }
}