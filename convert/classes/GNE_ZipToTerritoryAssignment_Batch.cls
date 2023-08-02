/************************************************************
*  @author: Bartosz Osowiecki, Roche
*  Date: 2012-03-14
*  Description:
*  This batch class processes Staging_Zip_2_Terr_gne__c records and basing on Activation_Date_gne__c, Deactivation_Date_gne__c and
*  Status_gne__c fields, populates and depopulates Zip_to_Territory_gne__c table.
*  Business Rules:
*  BR01: Record is omitted from processing if:
*   1. batch process execution date is before the Activation_Date_gne__c
*   2. Status_gne__c is different than 'Loaded'.
*  BR02: Create new Zip_to_Territory_gne__c record if batch process execution date is on or after the Activation_Date_gne__c and
*        current Staging_Zip_2_Terr_gne__c record doesn't have related Zip_to_Territory_gne__c record.
*  BR03: Update matching Zip_to_Territory_gne__c record if batch process execution date is on or after the Activation_Date_gne__c.
*  BR04: Remove matching Zip_to_Territory_gne__c if batch process execution date is after the Deactivation_Date_gne__c.
*************************************************************/

global class GNE_ZipToTerritoryAssignment_Batch implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    private static final String STATUS_LOADED = 'Loaded';
    private static final String STATUS_PROCESSED = 'Processed';
    private static final String STATUS_ERROR = 'Error Processing';
    private Map<String, Territory2> terrName2Territory = new Map<String, Territory2>();
    private Map <String, Object> params = new Map <String, Object>();
    private Integer updatedRecords = 0;
    private Integer errors = 0;
    private Integer inserted = 0;
    private Integer deleted = 0;
    private Integer totalProcessedRecords = 0;

    global Boolean previewMode;
    public Boolean turnOffFinishBatch;

    public GNE_ZipToTerritoryAssignment_Batch(){}

    global GNE_ZipToTerritoryAssignment_Batch(Boolean preview) {
        this(preview, false);
    }

    /*
    * constructor because of some tests reason
    * can be used also to turnOff run batch from finish method
    */
    public GNE_ZipToTerritoryAssignment_Batch(Boolean preview, Boolean turnOffFinishBatch) {
        this.previewMode = preview;
        this.turnOffFinishBatch = turnOffFinishBatch;
        params.put('startTime', System.now());
    }

    public void execute(SchedulableContext sc){
        GNE_ZipToTerritoryAssignment_Batch batch = new GNE_ZipToTerritoryAssignment_Batch(false);
        Database.executeBatch(batch);
    }

    public String getQuery() {
        return 'SELECT Id, Activaction_Date_gne__c, Brand_Code_gne__c, ' +
            'Brand_Name_gne__c, Comment_gne__c, Status_gne__c, ' +
            'Territory_Key_gne__c, Unalign_Date_gne__c, Zip_Code_gne__c ' +
            'FROM Staging_Zip_2_Terr_gne__c ' +
            'WHERE Status_gne__c = \'' + STATUS_LOADED + '\' ' +
                'AND Activaction_Date_gne__c <= Today';
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(getQuery());
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        totalProcessedRecords += scope.size();
        Map<Id,Zip_to_Territory_gne__c> id2zipToTerritoryUpsert = new Map<Id,Zip_to_Territory_gne__c>();
        List<Zip_to_Territory_gne__c> zipTerrsToUpsert = new List<Zip_to_Territory_gne__c>();
        Map<Id,Zip_to_Territory_gne__c> id2zipToTerritoryDelete= new Map<Id,Zip_to_Territory_gne__c>();
        List<Zip_to_Territory_gne__c> zipTerrsToDelete = new List<Zip_to_Territory_gne__c>();

        List<Staging_Zip_2_Terr_gne__c> sZipsToTerrs = (List<Staging_Zip_2_Terr_gne__c>)scope;

        Set<String> scopeTerrsNames = new Set<String>();

        for (Staging_Zip_2_Terr_gne__c sZipToTerr : sZipsToTerrs) {
            if (!scopeTerrsNames.contains(sZipToTerr.Territory_Key_gne__c))
                scopeTerrsNames.add(sZipToTerr.Territory_Key_gne__c);
        }

        // Get Territory records used in this scope
        List<Territory2> terrs  = [
            SELECT Id, Name, Territory_Number_gne__c, Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c
            FROM Territory2
            WHERE Name IN :scopeTerrsNames
        ];

        terrName2Territory.clear();

        for(Territory2 terr : terrs) {
            terrName2Territory.put(terr.Name.toUpperCase(),terr);
        }

        // Helper dictionary to map Brand Code and Zip Code to Zip To Territory records.
        // It will be used to find Zip2Territory record by Brand_Zip_Id_gne__c field value.
        Map<String, Zip_to_Territory_gne__c> brandZipCodeIdToRecMap = getBrandZipCodeIdMapping(sZipsToTerrs);

        // Helper collection to remember relation between Staging and Zip2Territories records
        Map<String, Staging_Zip_2_Terr_gne__c> brandZipIdToStgRecMap = new Map<String, Staging_Zip_2_Terr_gne__c>();

        // Helper collection of already visited Zip to Terrs.
        // We don't want to put the same record on update list.
        Set<Id> visitedZipToTerrIds = new Set<Id>();

        for (Staging_Zip_2_Terr_gne__c sZipToTerr : sZipsToTerrs) {
            System.debug('BOS:: Staging_Zip_2_Terr_gne__c : '+sZipToTerr + ' ('+sZipToTerr.Brand_Code_gne__c+')');

            // Check if given Territory Name is valid.
            if (sZipToTerr.Territory_Key_gne__c == null || !terrName2Territory.containsKey(sZipToTerr.Territory_Key_gne__c.toUpperCase())) {
                updateStatusAndComment(sZipToTerr, STATUS_ERROR, 'Territory with given name does not exist.');
                continue;
            }
            Territory2 terr = terrName2Territory.get(sZipToTerr.Territory_Key_gne__c.toUpperCase()) != null ? terrName2Territory.get(sZipToTerr.Territory_Key_gne__c.toUpperCase()) : null;
            String terrNumber = terr != null ? terr.Territory_Number_gne__c : null;
            String sfCode = terr != null ? terr.Salesforce_Code_gne__c : null;
            String sfSubTeamCode = terr != null ? terr.Salesforce_SubTeam_Code_gne__c : null;

            String brandZipCodeId = getBrandZipCodeId(sZipToTerr);
            brandZipIdToStgRecMap.put(brandZipCodeId,sZipToTerr);
            Zip_to_Territory_gne__c matchingZipToTerr = brandZipCodeIdToRecMap.get(brandZipCodeId);

            if (sZipToTerr.Unalign_Date_gne__c!=null && sZipToTerr.Unalign_Date_gne__c < Date.today()) { // deactivation date has passed, remove Zip2Territory record
                if (matchingZipToTerr!=null) { // remove only if staging record has matching Zip2Territory record
                    id2zipToTerritoryDelete.put(matchingZipToTerr.Id, matchingZipToTerr);
                    updateStatusAndComment(sZipToTerr, STATUS_PROCESSED,null);
                    System.debug('BOS:: Zip_to_Territory_gne__c to delete: '+matchingZipToTerr);
                } else {
                    updateStatusAndComment(sZipToTerr, STATUS_ERROR,'Deactivation failed. No matching Zip To Territory2 record found.');
                    System.debug('BOS:: Zip_to_Territory_gne__c to delete failed: '+sZipToTerr.Comment_gne__c);
                }
            }
            else if (matchingZipToTerr!=null) { // update existing Zip2Territory record
                if (!visitedZipToTerrIds.contains(matchingZipToTerr.Id)) {
                    id2zipToTerritoryUpsert.put(matchingZipToTerr.Id, matchingZipToTerr);
                    visitedZipToTerrIds.add(matchingZipToTerr.Id);
                }

                updateStatusAndComment(sZipToTerr, STATUS_PROCESSED,null);
                System.debug('BOS:: Zip_to_Territory_gne__c to update: '+matchingZipToTerr);
            }
            else { // if we are here it means that we need to create new Zip2Territory record
                Zip_to_Territory_gne__c zipToTerr = new Zip_to_Territory_gne__c(
                    STARS_BrandCode_gne__c = sZipToTerr.Brand_Code_gne__c,
                    Territory_Number_gne__c = terrNumber,
                    Zip_Code_gne__c = sZipToTerr.Zip_Code_gne__c,
                    Salesforce_Code_gne__c = sfCode,
                    Salesforce_SubTeam_Code_gne__c = sfSubTeamCode
                );
                inserted++;
                zipTerrsToUpsert.add(zipToTerr);
                updateStatusAndComment(sZipToTerr, STATUS_PROCESSED,null);
                System.debug('BOS:: Zip_to_Territory_gne__c to insert: '+zipToTerr);
            }
        }

        zipTerrsToUpsert.addAll(id2zipToTerritoryUpsert.values());
        zipTerrsToDelete.addAll(id2zipToTerritoryDelete.values());
        
        if(previewMode) {
            Savepoint sp = Database.setSavepoint();

            upsertZipsToTerrs(zipTerrsToUpsert,brandZipIdToStgRecMap);
            deleteZipsToTerrs(zipTerrsToDelete,brandZipIdToStgRecMap);

            Database.rollback(sp);

            for(Staging_Zip_2_Terr_gne__c stgTerr:sZipsToTerrs) {

                stgTerr.Comment_gne__c = '[PREVIEW Status:' + stgTerr.Status_gne__c+ ']' + (stgTerr.Comment_gne__c==null ? '' : ' || ' + stgTerr.Comment_gne__c);
                stgTerr.Status_gne__c  = STATUS_LOADED;
            }
        } else {
            upsertZipsToTerrs(zipTerrsToUpsert,brandZipIdToStgRecMap);
            deleteZipsToTerrs(zipTerrsToDelete,brandZipIdToStgRecMap);
        }
        // For safety reason - if Comment text is too long.
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.allowFieldTruncation = true;
        dml.optAllOrNone = false;

        Database.Saveresult[] results = Database.update(sZipsToTerrs, dml);

        if (results != null) {
            Integer iCount = 0;
            for (Database.Saveresult result : results) {
                Staging_Zip_2_Terr_gne__c sZipToTerr = sZipsToTerrs[iCount++];

                if (result.isSuccess()) {

                } else {
                    Database.Error[] errs = result.getErrors();
                    for(Database.Error err : errs)
                        System.debug('BOS:: [STG ERROR] ' + sZipToTerr.Id + ': ' + err.getStatusCode() + ' - ' + err.getMessage());
                }
            }
        }

    }

    global void finish(Database.BatchableContext BC) {
        if(!previewMode && !turnOffFinishBatch) {
            params.put('inserted', inserted);
            params.put('total', totalProcessedRecords);
            params.put('errors', errors);
            params.put('deleted', deleted);
            GNE_ZipToTerritoryCodeUpdate_Batch batch = new GNE_ZipToTerritoryCodeUpdate_Batch(false, params);
            Database.executeBatch(batch);
        }
    }

    private Map<String,Zip_to_Territory_gne__c> getBrandZipCodeIdMapping(List<Staging_Zip_2_Terr_gne__c> sZipsToTerrs) {
        List<String> brandZipValues = new List<String>();

        for (Staging_Zip_2_Terr_gne__c sZipToTerr : sZipsToTerrs) {
            brandZipValues.add(getBrandZipCodeId(sZipToTerr));
        }

        List<Zip_to_Territory_gne__c> matchingZipTerrs = [
            SELECT Id, STARS_BrandCode_gne__c, Territory_Number_gne__c, Zip_Code_gne__c,Brand_Zip_Id_gne__c
            FROM Zip_to_Territory_gne__c
            WHERE Brand_Zip_Id_gne__c in :brandZipValues
        ];

        Map<String,Zip_to_Territory_gne__c> brandZipToRecMap = new Map<String,Zip_to_Territory_gne__c>();

        for (Zip_to_Territory_gne__c zipToTerr :matchingZipTerrs) {
            brandZipToRecMap.put(zipToTerr.Brand_Zip_Id_gne__c,zipToTerr);
        }

        return brandZipToRecMap;
    }

    private String getBrandZipCodeId(Staging_Zip_2_Terr_gne__c sZipToTerr) {
        String terrNumber = '';
        if(sZipToTerr.Territory_Key_gne__c!=null) {
            Territory2 terr = terrName2Territory.get(sZipToTerr.Territory_Key_gne__c.toUpperCase()) != null ? terrName2Territory.get(sZipToTerr.Territory_Key_gne__c.toUpperCase()) : null;
            terrNumber = terr != null ? terr.Territory_Number_gne__c : null;
        }

        return sZipToTerr.Brand_Code_gne__c + '_' + sZipToTerr.Zip_Code_gne__c + '_' + terrNumber;
    }

    private String getBrandZipCodeId(Zip_to_Territory_gne__c zipToTerr) {
        return zipToTerr.STARS_BrandCode_gne__c + '_' +
            zipToTerr.Zip_Code_gne__c + '_' + zipToTerr.Territory_Number_gne__c;
    }

    private void updateStatusAndComment(Staging_Zip_2_Terr_gne__c sZipToTerr, String status, String comment) {
        sZipToTerr.Status_gne__c = status;
        sZipToTerr.Comment_gne__c = comment;
    }

    private void upsertZipsToTerrs(List<Zip_to_Territory_gne__c> zipToTerrs,
                                    Map<String, Staging_Zip_2_Terr_gne__c> brandZipIdToStgRecMap) {

        Database.UpsertResult[] results = Database.upsert(zipToTerrs, false);

        if (results != null) {
            Integer iCount = 0;
            for (Database.UpsertResult result : results) {
                Zip_to_Territory_gne__c zipToTerr = zipToTerrs[iCount++];

                Staging_Zip_2_Terr_gne__c sZipToTerr = null;
                String brandZipId = getBrandZipCodeId(zipToTerr);

                if (brandZipIdToStgRecMap.containsKey(brandZipId)) {
                    sZipToTerr = brandZipIdToStgRecMap.get(brandZipId);
                }

                if (sZipToTerr == null) continue;

                if (result.isSuccess()) {
                    if(!previewMode) //we cannot save Id of newly created Zip To Territory rec in preview mode
                        sZipToTerr.Zip_to_Territory_gne__c = zipToTerr.Id;
                } else {
                    errors++;
                    sZipToTerr.Status_gne__c = STATUS_ERROR;
                    String errorMsg = 'Error while upserting Zip To Territory:';
                    Database.Error[] errs = result.getErrors();
                    for(Database.Error err : errs)
                        errorMsg = errorMsg + ' ' + err.getStatusCode() + ' - ' + err.getMessage();
                    sZipToTerr.Comment_gne__c = errorMsg;
                }
            }
        }
    }

    private void deleteZipsToTerrs(List<Zip_to_Territory_gne__c> zipToTerrs,
                                    Map<String, Staging_Zip_2_Terr_gne__c> brandZipIdToStgRecMap) {

        Database.DeleteResult[] results = Database.delete(zipToTerrs, false);

        if (results != null) {
            Integer iCount = 0;
            for (Database.DeleteResult result : results) {
                Zip_to_Territory_gne__c zipToTerr = zipToTerrs[iCount++];
                Staging_Zip_2_Terr_gne__c sZipToTerr = null;
                String brandZipId = getBrandZipCodeId(zipToTerr);
                if (brandZipIdToStgRecMap.containsKey(brandZipId)) {
                    sZipToTerr = brandZipIdToStgRecMap.get(brandZipId);
                }

                if (sZipToTerr == null) continue;

                if (!result.isSuccess()) {
                    errors++;
                    sZipToTerr.Status_gne__c = STATUS_ERROR;
                    String errorMsg = 'Error while removing Zip To Territory:';
                    Database.Error[] errs = result.getErrors();
                    for(Database.Error err : errs)
                        errorMsg = errorMsg + ' ' + err.getStatusCode() + ' - ' + err.getMessage();
                    sZipToTerr.Comment_gne__c = errorMsg;
                } else {
                    deleted++;
                }
            }
        }
    }
}