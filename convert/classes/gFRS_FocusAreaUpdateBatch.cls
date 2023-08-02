/**
 * @author golisk
 * @date 10/01/2018
 * @description Batch Apex class for updating Focus Area field for historical Funding Requests.
 *
 * Usage (in anonymous apex) :
 * gFRS_FocusAreaUpdateBatch batch = new gFRS_FocusAreaUpdateBatch();
 * Database.executeBatch(batch);
 */

global class gFRS_FocusAreaUpdateBatch implements Database.Batchable<SObject>, Database.Stateful {
    public Integer numberOfRecordsProcessed = 0;
    global List<String> recordsNotUpdated = new List<String>();

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Name, RecordTypeId, Social_Impact_Goals_CEG__c, Focus_Area__c FROM GFRS_Funding_Request__c ' +
                'WHERE RecordType.Name IN (' +
                +'\'' + gFRS_Util.TYPE_HC_CHAR_NAME + '\', ' +
                +'\'' + gFRS_Util.TYPE_PHILANTHROPIC_NAME + '\', ' +
                +'\'' + gFRS_Util.TYPE_FELLOWSHIPS_NAME + '\', ' +
                +'\'' + gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME + '\')';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<GFRS_Funding_Request__c> records) {

        GFRS_OrgSettings__c myOrgCS = GFRS_OrgSettings__c.getOrgDefaults();
        myOrgCS.Funding_Request_Trigger_Enabled__c = false;
        update myOrgCS;

        try {

            gFRS_Util.getListOfFundingRequestsWithFocusAreaField(records);
            for (GFRS_Funding_Request__c record : records) {
                if (String.isBlank(record.Focus_Area__c)) {
                    recordsNotUpdated.add(record.Name + ' was not updated.');
                }
            }
            List<Database.SaveResult> results = Database.update(records, false);
            for (Database.SaveResult result : results) {
                if (!result.isSuccess()) {
                    for (Database.Error err : result.getErrors()) {
                        System.debug(LoggingLevel.ERROR, 'Error [Social Goals Mapping] Save failed: ' + result.getId() + ';' + err.getStatusCode() + '; ' + err.getMessage());
                    }
                }
            }

            numberOfRecordsProcessed += records.size();

        } catch(Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
        } finally {
            myOrgCS = GFRS_OrgSettings__c.getOrgDefaults();
            myOrgCS.Funding_Request_Trigger_Enabled__c = true;
            update myOrgCS;
        }

    }

    global void finish(Database.BatchableContext bc) {
        System.debug('INFO [Social Goals Mapping] Finished processing. Records processed = ' + numberOfRecordsProcessed);
        AsyncApexJob job = [
                SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems
                FROM AsyncApexJob
                WHERE Id = :bc.getJobId()
        ];
        System.debug('INFO [Social Goals Mapping] Job: ' + job);
        if (recordsNotUpdated.size() > 0) {
            for (String str : recordsNotUpdated) {
                System.debug(str);
            }
        }
    }
}