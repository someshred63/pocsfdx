/************************************************************
*  @author: Bartosz Osowiecki, Roche
*  Date: 2012-03-14
*  Description:
*  Unit Tests for process which populates/depopulates Zip_to_Territory_gne__c records.
*************************************************************/

@isTest
public class GNE_ZipToTerritoryAssignment_Batch_Test {
    private static final String STG_ALIGNMENT_NEW_STATE = 'Loaded';
    private static final String STG_ALIGNMENT_ERROR_STATE = 'Error Processing';
    private static final String STG_ALIGNMENT_SUCCESS_STATE = 'Processed';

    private static final String ACTIVATION_DATE_FN = 'Activaction_Date_gne__c';
    private static final String BRAND_CODE_FN = 'Brand_Code_gne__c';
    private static final String BRAND_NAME_FN = 'Brand_Name_gne__c';
    private static final String COMMENT_FN = 'Comment_gne__c';
    private static final String STATUS_FN = 'Status_gne__c';
    private static final String DEACTIVATION_DATE_FN = 'Unalign_Date_gne__c';
    private static final String TERRITORY_KEY_FN = 'Territory_Key_gne__c';
    private static final String ZIP_CODE_FN = 'Zip_Code_gne__c';

    private static final String ZIP_CODE_VALUE = 'TT9999';

    private static Set<Id> insertStagingZipToTerrs(List<Map<String,Object>> insertValues) {
        List<Staging_Zip_2_Terr_gne__c> recsToInsert = new List<Staging_Zip_2_Terr_gne__c>();
        for(Map<String,Object> values : insertValues) {
            Staging_Zip_2_Terr_gne__c newSZTRec = new Staging_Zip_2_Terr_gne__c();
            for(String fieldName : values.keySet()) {
                newSZTRec.put(fieldName, values.get(fieldName));
            }
            recsToInsert.add(newSZTRec);
        }

        insert recsToInsert;

        Set<ID> ids = new Set<Id>();
        for(Staging_Zip_2_Terr_gne__c rec : recsToInsert) {
            ids.add(rec.Id);
        }
        return ids;
    }

    private static Set<Id> insertValidStagingZipToTerrs() {
        Territory2 terr = createTerritory('00AB-Test Territory','root;00AB-Test Territory','root');
        return insertStagingZipToTerrs(new List<Map<String, Object>>{
                new Map<String,Object>{ ACTIVATION_DATE_FN => Date.today()-3,
                                        BRAND_NAME_FN => 'Actemra',
                                        STATUS_FN => STG_ALIGNMENT_NEW_STATE,
                                        TERRITORY_KEY_FN => terr.Name,
                                        ZIP_CODE_FN => ZIP_CODE_VALUE
                                        },
                new Map<String,Object>{ ACTIVATION_DATE_FN => Date.today()-2,
                                        BRAND_NAME_FN => 'Xeloda',
                                        STATUS_FN => STG_ALIGNMENT_NEW_STATE,
                                        DEACTIVATION_DATE_FN => Date.today()+3,
                                        TERRITORY_KEY_FN => terr.Name,
                                        ZIP_CODE_FN => ZIP_CODE_VALUE
                                        }
            });
    }

    private static Set<Id> insertInvalidStagingZipToTerrs() {
        Territory2 terr = createTerritory('00AB-Test Territory','root;00AB-Test Territory','root');
        return insertStagingZipToTerrs(new List<Map<String, Object>>{
                new Map<String,Object>{ ACTIVATION_DATE_FN => Date.today()-3,
                                        BRAND_NAME_FN => 'Xeloda',
                                        STATUS_FN => STG_ALIGNMENT_NEW_STATE,
                                        TERRITORY_KEY_FN => terr.Name,
                                        ZIP_CODE_FN => ZIP_CODE_VALUE
                                        },
                new Map<String,Object>{ ACTIVATION_DATE_FN => Date.today()-2,
                                        BRAND_NAME_FN => 'Xeloda',
                                        STATUS_FN => STG_ALIGNMENT_NEW_STATE,
                                        DEACTIVATION_DATE_FN => Date.today()+3,
                                        TERRITORY_KEY_FN => terr.Name,
                                        ZIP_CODE_FN => ZIP_CODE_VALUE
                                        }
            });
    }

    static testMethod void processInsertValidTerritoryTest() {
        Set<Id> scopeIds = insertValidStagingZipToTerrs();

        executeBatchJob(false);

        List<Staging_Zip_2_Terr_gne__c> sZip2Terrs = [SELECT Id, Activaction_Date_gne__c, Brand_Code_gne__c,
                                Brand_Name_gne__c, Comment_gne__c, Status_gne__c,
                                Territory_Key_gne__c, Unalign_Date_gne__c, Zip_Code_gne__c
                                FROM Staging_Zip_2_Terr_gne__c WHERE Id in :scopeIds];

        List<Zip_to_Territory_gne__c> addedT2Zs = [SELECT Id, (SELECT Id FROM Staging_Zips_2_Terrs_gne__r )
                                                    FROM Zip_to_Territory_gne__c
                                                    WHERE Zip_Code_gne__c = :ZIP_CODE_VALUE];
        // Test amount of inserted records
        System.assertEquals(2, addedT2Zs.size());

        // Test connection to staging records
        for (Zip_to_Territory_gne__c z2T : addedT2Zs) {
            System.assert(!z2T.Staging_Zips_2_Terrs_gne__r.isEmpty());
            System.debug('[BOS][TEST]:: Associated stage Zip2Territory: ' + z2T.Staging_Zips_2_Terrs_gne__r.get(0));
        }

        System.assertNotEquals(0,sZip2Terrs.size());
        // Test Status for Staging records
        for (Staging_Zip_2_Terr_gne__c sZipToTerr : sZip2Terrs) {
            System.assertEquals(sZipToTerr.Status_gne__c, STG_ALIGNMENT_SUCCESS_STATE);
        }
    }

    static testMethod void processInsertValidTerritoryInPreviewModeTest() {
        Set<Id> scopeIds = insertValidStagingZipToTerrs();

        executeBatchJob(true);

        List<Staging_Zip_2_Terr_gne__c> sZip2Terrs = [SELECT Id, Activaction_Date_gne__c, Brand_Code_gne__c,
                                Brand_Name_gne__c, Comment_gne__c, Status_gne__c,
                                Territory_Key_gne__c, Unalign_Date_gne__c, Zip_Code_gne__c
                                FROM Staging_Zip_2_Terr_gne__c WHERE Id in :scopeIds];

        List<Zip_to_Territory_gne__c> addedT2Zs = [SELECT Id, (SELECT Id FROM Staging_Zips_2_Terrs_gne__r )
                                                    FROM Zip_to_Territory_gne__c
                                                    WHERE Zip_Code_gne__c = :ZIP_CODE_VALUE];
        // Test amount of inserted records
        System.assertEquals(0, addedT2Zs.size());
        System.assertNotEquals(0,sZip2Terrs.size());

        // Test Status for Staging records
        for (Staging_Zip_2_Terr_gne__c sZipToTerr : sZip2Terrs) {
            System.assertEquals(sZipToTerr.Status_gne__c, STG_ALIGNMENT_NEW_STATE);
        }

    }

    static testMethod void processInsertInvalidTerritoryTest() {
        Set<Id> scopeIds = insertInvalidStagingZipToTerrs();

        executeBatchJob(false);

        List<Staging_Zip_2_Terr_gne__c> sZip2Terrs = [SELECT Id, Activaction_Date_gne__c, Brand_Code_gne__c,
                                Brand_Name_gne__c, Comment_gne__c, Status_gne__c,
                                Territory_Key_gne__c, Unalign_Date_gne__c, Zip_Code_gne__c
                                FROM Staging_Zip_2_Terr_gne__c WHERE Id in :scopeIds];

        List<Zip_to_Territory_gne__c> addedT2Zs = [SELECT Id, (SELECT Id FROM Staging_Zips_2_Terrs_gne__r )
                                                    FROM Zip_to_Territory_gne__c
                                                    WHERE Zip_Code_gne__c = :ZIP_CODE_VALUE];
        // Test amount of inserted records
        System.assertEquals(1, addedT2Zs.size());

        Integer processedRecsCount = 0;
        Integer errorRecsCount = 0;
        System.assertNotEquals(0,sZip2Terrs.size());

        for (Staging_Zip_2_Terr_gne__c sZipToTerr : sZip2Terrs) {
            if (sZipToTerr.Status_gne__c == STG_ALIGNMENT_SUCCESS_STATE)
                processedRecsCount++;
            else if (sZipToTerr.Status_gne__c == STG_ALIGNMENT_ERROR_STATE) {
                errorRecsCount++;
                System.debug('[BOS][TEST]:: Staging record error processing comment: ' + sZipToTerr.Comment_gne__c);
            }
        }

        // Test amount of Processed staging records
        System.assertEquals(1, processedRecsCount);

        // Test amount of staging records processed with errors
        System.assertEquals(1, errorRecsCount);

    }

    static testMethod void processInsertInvalidTerritoryInPreviewModeTest() {
        Set<Id> scopeIds = insertInvalidStagingZipToTerrs();

        executeBatchJob(true);

        List<Staging_Zip_2_Terr_gne__c> sZip2Terrs = [
            SELECT Id, Activaction_Date_gne__c, Brand_Code_gne__c,
                Brand_Name_gne__c, Comment_gne__c, Status_gne__c,
                Territory_Key_gne__c, Unalign_Date_gne__c, Zip_Code_gne__c
            FROM Staging_Zip_2_Terr_gne__c
            WHERE Id in :scopeIds
        ];

        List<Zip_to_Territory_gne__c> addedT2Zs = [
            SELECT Id, (SELECT Id FROM Staging_Zips_2_Terrs_gne__r )
            FROM Zip_to_Territory_gne__c
            WHERE Zip_Code_gne__c = :ZIP_CODE_VALUE
        ];
        // Test amount of inserted records
        System.assertEquals(0, addedT2Zs.size());

        System.assertNotEquals(0,sZip2Terrs.size());

        for (Staging_Zip_2_Terr_gne__c sZipToTerr : sZip2Terrs) {
            System.assertEquals(sZipToTerr.Status_gne__c, STG_ALIGNMENT_NEW_STATE);
        }
    }

    static testMethod void processUpdateValidTerritoryTest() {

        Set<Id> scopeIds = insertValidStagingZipToTerrs();

        List<Staging_Zip_2_Terr_gne__c> sZip2Terrs = [
            SELECT Id, Activaction_Date_gne__c, Brand_Code_gne__c,
            Brand_Name_gne__c, Comment_gne__c, Status_gne__c,
            Territory_Key_gne__c, Unalign_Date_gne__c, Zip_Code_gne__c
            FROM Staging_Zip_2_Terr_gne__c
            WHERE Id in :scopeIds
        ];

        (new GNE_ZipToTerritoryAssignment_Batch(false)).execute(null, sZip2Terrs);

        sZip2Terrs = [
            SELECT Id, Activaction_Date_gne__c, Brand_Code_gne__c,
            Brand_Name_gne__c, Comment_gne__c, Status_gne__c,
            Territory_Key_gne__c, Unalign_Date_gne__c, Zip_Code_gne__c
            FROM Staging_Zip_2_Terr_gne__c
            WHERE Id in :scopeIds
        ];

        final String newTerrNbrConst = '007F108';
        final String newTerrKeyConst = newTerrNbrConst + '-Southeast';
        String newTerrKey = newTerrKeyConst;

        for (Staging_Zip_2_Terr_gne__c sZtT : sZip2Terrs) {
            sZtT.Territory_Key_gne__c = newTerrKey;
            // Put corrent Number only for the first record
            newTerrKey = newTerrKeyConst + '!BAD';
            sZtT.Status_gne__c = STG_ALIGNMENT_NEW_STATE;
        }

        update sZip2Terrs;
        
        Territory2 terr = createTerritory('007F108-Southeast','root;007F108-Southeast','root');
        executeBatchJob(false);

        sZip2Terrs = [
            SELECT Id, Activaction_Date_gne__c, Brand_Code_gne__c,
                Brand_Name_gne__c, Comment_gne__c, Status_gne__c,
                Territory_Key_gne__c, Unalign_Date_gne__c, Zip_Code_gne__c
            FROM Staging_Zip_2_Terr_gne__c
            WHERE Id in :scopeIds
        ];
            
        List<Zip_to_Territory_gne__c> updatedT2Zs = [
            SELECT Id, (SELECT Id FROM Staging_Zips_2_Terrs_gne__r )
            FROM Zip_to_Territory_gne__c
            WHERE Zip_Code_gne__c = :ZIP_CODE_VALUE
                AND Territory_Number_gne__c = :newTerrNbrConst
        ];
        // Test ammount of updated records
        System.assertEquals(1, updatedT2Zs.size());

        // Test connection to staging records
        for (Zip_to_Territory_gne__c z2T : updatedT2Zs) {
            System.assert(!z2T.Staging_Zips_2_Terrs_gne__r.isEmpty());
            System.debug('[BOS][TEST]:: Associated stage Zip2Territory: ' + z2T.Staging_Zips_2_Terrs_gne__r.get(0));
        }

        Integer processedRecsCount = 0;
        Integer errorRecsCount = 0;
        System.assertNotEquals(0,sZip2Terrs.size());

        for (Staging_Zip_2_Terr_gne__c sZipToTerr : sZip2Terrs) {
            if (sZipToTerr.Status_gne__c == STG_ALIGNMENT_SUCCESS_STATE)
                processedRecsCount++;
            else if (sZipToTerr.Status_gne__c == STG_ALIGNMENT_ERROR_STATE) {
                errorRecsCount++;
                System.debug('[BOS][TEST]:: Staging record error processing comment: ' + sZipToTerr.Comment_gne__c);
            }
        }

        // Test amount of Processed staging records
        System.assertEquals(1, processedRecsCount);

        // Test amount of staging records processed with errors
        System.assertEquals(1, errorRecsCount);
    }

    static testMethod void processDeleteValidTerritoryTest() {
        Set<Id> scopeIds = insertValidStagingZipToTerrs();

        List<Staging_Zip_2_Terr_gne__c> sZip2Terrs = [
            SELECT Id, Activaction_Date_gne__c, Brand_Code_gne__c,
                Brand_Name_gne__c, Comment_gne__c, Status_gne__c,
                Territory_Key_gne__c, Unalign_Date_gne__c, Zip_Code_gne__c
            FROM Staging_Zip_2_Terr_gne__c
            WHERE Id in :scopeIds
        ];

        (new GNE_ZipToTerritoryAssignment_Batch(false)).execute(null, sZip2Terrs);

        sZip2Terrs = [
            SELECT Id, Activaction_Date_gne__c, Brand_Code_gne__c,
            Brand_Name_gne__c, Comment_gne__c, Status_gne__c,
            Territory_Key_gne__c, Unalign_Date_gne__c, Zip_Code_gne__c
            FROM Staging_Zip_2_Terr_gne__c
            WHERE Id in :scopeIds
        ];

        final Date newDeactiveDate = Date.today()-1;

        for (Staging_Zip_2_Terr_gne__c sZtT : sZip2Terrs) {
            sZtT.Status_gne__c = STG_ALIGNMENT_NEW_STATE;
            sZtT.Unalign_Date_gne__c = newDeactiveDate;
        }

        update sZip2Terrs;

        executeBatchJob(false);

        sZip2Terrs = [
            SELECT Id, Activaction_Date_gne__c, Brand_Code_gne__c,
                Brand_Name_gne__c, Comment_gne__c, Status_gne__c,
                Territory_Key_gne__c, Unalign_Date_gne__c, Zip_Code_gne__c
            FROM Staging_Zip_2_Terr_gne__c
            WHERE Id in :scopeIds
        ];

        List<Zip_to_Territory_gne__c> deletedT2Zs = [SELECT Id
                                                     FROM Zip_to_Territory_gne__c WHERE Zip_Code_gne__c = :ZIP_CODE_VALUE];
        // Check if all deactivated Zip2Terrs was removed.
        System.assertEquals(0, deletedT2Zs.size());

        System.assertNotEquals(0,sZip2Terrs.size());

        // Test Status for Staging records
        for (Staging_Zip_2_Terr_gne__c sZipToTerr : sZip2Terrs) {
            System.assertEquals(STG_ALIGNMENT_SUCCESS_STATE, sZipToTerr.Status_gne__c);
        }

    }


    static testMethod void bigAmountDataTest() {
        Set<Id> scopeIds = insertBigAmountStagingZipToTerrs();

        executeBatchJob(false, 1000, true);

        List<Staging_Zip_2_Terr_gne__c> sZip2Terrs = [
            SELECT Id, Activaction_Date_gne__c, Brand_Code_gne__c,
                Brand_Name_gne__c, Comment_gne__c, Status_gne__c,
                Territory_Key_gne__c, Unalign_Date_gne__c, Zip_Code_gne__c, Zip_to_Territory_gne__c
            FROM Staging_Zip_2_Terr_gne__c
            WHERE Id in :scopeIds
        ];

        System.assertNotEquals(0,sZip2Terrs.size());

        for(Staging_Zip_2_Terr_gne__c sz : sZip2Terrs){
            System.assertEquals(sz.Status_gne__c,STG_ALIGNMENT_SUCCESS_STATE);
            System.assertNotEquals(sz.Zip_to_Territory_gne__c,null);
        }
    }

    private static Set<Id> insertBigAmountStagingZipToTerrs() {
        Territory2 terr = createTerritory('00AB-Test Territory','root;00AB-Test Territory','root');
        List<Staging_Zip_2_Terr_gne__c> listOfStagings = new List<Staging_Zip_2_Terr_gne__c>();
        for(Integer i=0;i<1000;i++){
            Staging_Zip_2_Terr_gne__c stagingObj = new Staging_Zip_2_Terr_gne__c();
            stagingObj.Activaction_Date_gne__c = Date.today()-2;
            stagingObj.Unalign_Date_gne__c = Date.Today() + 3;
            stagingObj.Brand_Name_gne__c = 'Xeloda';
            stagingObj.Territory_Key_gne__c = terr.Name;
            stagingObj.Zip_Code_gne__c = 'XX9999XX' + i;
            listOfStagings.add(stagingObj);
        }

        insert listOfStagings;
        Set<Id> scopeIds = new Set<Id>();
        for (Staging_Zip_2_Terr_gne__c stgRec : listOfStagings) {
            scopeIds.add(stgRec.Id);
        }

        return scopeIds;
    }

    private static void executeBatchJob(Boolean previewMode) {
        executeBatchJob(previewMode, null, false);
    }

    private static void executeBatchJob(Boolean previewMode, Integer batchSize, Boolean turnOffFinishBatch) {
        GNE_ZipToTerritoryAssignment_Batch batchJob = new GNE_ZipToTerritoryAssignment_Batch(previewMode, turnOffFinishBatch);

        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs (thisUser) {
            Test.StartTest();
            if(batchSize==null) {
                DataBase.executeBatch(batchJob);
            } else {
                DataBase.executeBatch(batchJob, batchSize);
            }

            Test.StopTest();
        }
    }

    static private Territory2 createTerritory(String territoryName, String externalId, String parentExternalId) {
        return createTerritory(territoryName, externalId, parentExternalId, null, null, null);
    }

    static private Territory2 createTerritory(String territoryName, String externalId, String parentExternalId, String description, Date endDate, String source ) {

        User thisUser = [ SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        Territory2 territory;
        Id terrModelId = [SELECT Id FROM Territory2Model LIMIT 1].Id;
        Id terrTypeId = [SELECT Id FROM Territory2Type LIMIT 1].Id;

        System.runAs (thisUser) {
            territory = new Territory2();
            territory.Name = territoryName;
            territory.DeveloperName = 'DM_' + territoryName.replaceAll('[|\\,| |\\.|\\,|\\"|\\:|\\~|\\!|\\@|\\#|\\$|\\%|\\^|\\&|\\*|\\-|\\_|\\+|\\=|\\<|\\>|\\?|\\(|\\)|\\{|\\}|\\;|\\\'"]', '');
            territory.Territory2ModelId = terrModelId;
            territory.Territory2TypeId = terrTypeId;
            territory.external_id_gne__c = externalId;
            territory.parent_external_id_gne__c = parentExternalId;
            territory.Description = description;
            territory.End_Date__c = endDate;
            territory.Source_gne__c = source;

            insert territory;
        }

        return territory;
    }
}