public with sharing class CORE_Subscribe_Affiliation_Batch implements Database.Batchable<SObject>, Database.Stateful {

    public static final String STATUS_LOADED = 'Loaded';
    private static final String STATUS_PROCESSED = 'Processed';
    private static final String HCO_NOT_EXISTS = 'HCO not exists';
    public static final String STAGING_ACTIVE_STATUS = 'ACTIVE';
    private static final String AFFILIATION_STATUS_ACTIVE = 'Active';
    private static final String AFFILIATION_STATUS_INACTIVE = 'Inactive';
    private static final String DEFAULT_AFFILIATION_TYPE = 'AFFILIATION';
    private static final String DEFAULT_AFFILIATION_ROLE = 'Affiliated with';
    private static String plainTextLineBreak = '\n';

    private Map<String, List<Account>> insIdToHcos;
    private Map<String, Account> mdmidToHcp;
    private Map<String, Account> sfdcIdToAccount;
    //hco_hcp to core affiliation
    private Map<String, List<Core_Staging_Affiliation__c>> keyToStagingAffiliation;
    //contains hco_hcp keys for which new affiliation has been created
    Set<String> hcoHcpWithNewAffiliation;

    private Integer createdAffiliations = 0;
    private Integer updatedAffiliations = 0;
    private Integer deactivatedAffiliations = 0;
    private Integer coreAffiliationRecords;
    private Integer createdHcps;
    private Datetime startDatetime;
    private Long affiliationQueryTime = 0;
    private Long accountQueryTime = 0;
    private Integer stagingRecordUpdateErrors;
    private Set<String> errorMessages;

    private Integer affiliationRecordUpsertErrors;
    private Set<String> affiliationErrorMessages;

    public CORE_Subscribe_Affiliation_Batch(Integer hcpCountCreatedInPreprocessing) {
        this.createdHcps = hcpCountCreatedInPreprocessing;
        startDatetime = System.now();
        coreAffiliationRecords = 0;
        hcoHcpWithNewAffiliation = new Set<String>();
        stagingRecordUpdateErrors = 0;
        errorMessages = new Set<String>();
        affiliationRecordUpsertErrors = 0;
        affiliationErrorMessages = new Set<String>();
    }

    public Database.QueryLocator start(Database.BatchableContext ctx) {
        return Database.getQueryLocator ([
                SELECT Id, Affiliation_Status__c, Affiliation_Type__c, Comments__c, HCO_INS_Id__c, HCP_MDM_Id__c, Status__c, Primary__c
                FROM Core_Staging_Affiliation__c
                WHERE Status__c = :STATUS_LOADED
        ]);
    }

    public void execute(Database.BatchableContext ctx, List<SObject> scope) {
        List<Core_Staging_Affiliation__c> stagingAffiliations = (List<Core_Staging_Affiliation__c>) scope;
        Datetime accountQueryStartTime = System.now();
        initCache(stagingAffiliations);
        accountQueryTime += (System.now().getTime() - accountQueryStartTime.getTime());
        Datetime affiliationQueryStartTime = System.now();
        Map<String, List<Affiliation_vod__c>> keyToAffiliations = getExistingAffiliations(stagingAffiliations);
        affiliationQueryTime += (System.now().getTime() - affiliationQueryStartTime.getTime());
        List<Affiliation_vod__c> affiliationsToUpsert = new List<Affiliation_vod__c>();
        Set<String>uniqueKeys = new Set<String>();
        for (Core_Staging_Affiliation__c cas : stagingAffiliations) {
            coreAffiliationRecords++;
            List<Account> hcos = insIdToHcos.get(cas.HCO_INS_Id__c);
            Account hcp = mdmidToHcp.get(cas.HCP_MDM_Id__c);
            if (hcos == null || hcos.isEmpty()) {
                cas.Comments__c = HCO_NOT_EXISTS;
            } else if (hcp != null) {
                if (cas.Affiliation_Status__c == STAGING_ACTIVE_STATUS) {
                    for (Account hco : hcos) {
                        String hcoHcpKey = getKey(hco.Id, hcp.Id);
                        List<Affiliation_vod__c> existingAffiliations = keyToAffiliations.get(hcoHcpKey);
                        if (existingAffiliations != null && !existingAffiliations.isEmpty()) {
                            for (Affiliation_vod__c affiliation : existingAffiliations) {
                                if (shouldAffiliationBeUpdated(affiliation, AFFILIATION_STATUS_ACTIVE, true, cas) && uniqueKeys.add(affiliation.Id)) {
                                    affiliationsToUpsert.add(updateAffiliation(affiliation, AFFILIATION_STATUS_ACTIVE, true, cas));
                                    updatedAffiliations++;
                                }
                            }
                        } else {
                            if (hcoHcpWithNewAffiliation.add(hcoHcpKey)) {
                                String affiliationType = keyToStagingAffiliation.get(hcoHcpKey).size() == 1 ? cas.Affiliation_Type__c : DEFAULT_AFFILIATION_TYPE;
                                String uniqueKey = getUniqueKey(hco.Id, hcp.Id, affiliationType);
                                if (uniqueKeys.add(uniqueKey)) {
                                    affiliationsToUpsert.add(createNewAffiliation(hco.Id, hcp.Id, affiliationType, cas));
                                }
                                createdAffiliations++;
                            }
                        }
                    }
                } else {
                    for (Account hco : hcos) {
                        List<Affiliation_vod__c> existingAffiliations = keyToAffiliations.get(getKey(hco.Id, hcp.Id));
                        if (existingAffiliations != null && !existingAffiliations.isEmpty()) {
                            for (Affiliation_vod__c affiliation : existingAffiliations) {
                                if (shouldAffiliationBeUpdated(affiliation, AFFILIATION_STATUS_INACTIVE, false, cas) && uniqueKeys.add(affiliation.Id)) {
                                    affiliationsToUpsert.add(updateAffiliation(affiliation, AFFILIATION_STATUS_INACTIVE, false, cas));
                                    deactivatedAffiliations++;
                                }
                            }
                        }
                    }
                }
            }
            cas.Status__c = STATUS_PROCESSED;
        }

        upsertAffiliationsRecordsAndStatistics(affiliationsToUpsert);
        updateStagingRecordsAndStatistics(stagingAffiliations);
    }

    public void finish(Database.BatchableContext ctx) {
        List<String> addresses = CORE_Found_Misc_Config__c.getInstance('SubscribeNotifyEmail').Configuration_Value_gne__c.split(',');
        sendSummaryMail(addresses, startDatetime, System.now());
    }

    private Boolean shouldAffiliationBeUpdated(Affiliation_vod__c affiliation, String newRecordStatus, Boolean newActiveFlag, Core_Staging_Affiliation__c cas) {
        if (affiliation.Record_Status_gne__c != newRecordStatus
                || affiliation.Active_for_FRM_gne__c != newActiveFlag
                || affiliation.Primary_gne__c != cas.Primary__c
                || affiliation.Core_Staging_Affiliation__c != cas.Id) {
            return true;
        }
        return false;
    }

    private Affiliation_vod__c updateAffiliation(Affiliation_vod__c affiliation, String newRecordStatus, Boolean newActiveFlag, Core_Staging_Affiliation__c cas) {
        affiliation.Record_Status_gne__c = newRecordStatus;
        affiliation.Active_for_FRM_gne__c = newActiveFlag;
        affiliation.Core_Staging_Affiliation__c = cas.Id;
        affiliation.Primary_gne__c = cas.Primary__c;
        return affiliation;
    }

    private Affiliation_vod__c createNewAffiliation(Id hcoId, Id hcpId, String affiliationType, Core_Staging_Affiliation__c cas) {
        return new Affiliation_vod__c(From_Account_vod__c = hcoId, To_Account_vod__c = hcpId,
                Affiliation_Type_gne__c = affiliationType, Role_vod__c = DEFAULT_AFFILIATION_ROLE, Core_Staging_Affiliation__c = cas.Id, Primary_gne__c = cas.Primary__c);
    }

    private void initCache(List<Core_Staging_Affiliation__c> stagingAffiliations) {
        keyToStagingAffiliation = new Map<String, List<Core_Staging_Affiliation__c>>();
        Set<String>insIds = new Set<String>();
        Set<String>mdmIds = new Set<String>();
        for (Core_Staging_Affiliation__c cas : stagingAffiliations) {
            insIds.add(cas.HCO_INS_Id__c);
            mdmIds.add(cas.HCP_MDM_Id__c);
        }

        insIdToHcos = new Map<String, List<Account>>();
        mdmidToHcp = new Map<String, Account>();
        sfdcIdToAccount = new Map<String, Account>();

        for (Account acc : [SELECT Id, MDMID_gne__c, INS_ID_gne__c FROM Account WHERE INS_ID_gne__c IN :insIds]) {
            if (!insIdToHcos.containsKey(acc.INS_ID_gne__c)) {
                insIdToHcos.put(acc.INS_ID_gne__c, new List<Account>());
            }
            insIdToHcos.get(acc.INS_ID_gne__c).add(acc);
            sfdcIdToAccount.put(acc.Id, acc);
        }

        for (Account acc : [SELECT Id, MDMID_gne__c, INS_ID_gne__c FROM Account WHERE MDMID_gne__c IN :mdmIds]) {
            mdmidToHcp.put(acc.MDMID_gne__c, acc);
            sfdcIdToAccount.put(acc.Id, acc);
        }

        for (Core_Staging_Affiliation__c cas : stagingAffiliations) {
            if (insIdToHcos.containsKey(cas.HCO_INS_Id__c)) {
                for (Account hco : insIdToHcos.get(cas.HCO_INS_Id__c)) {
                    if (mdmidToHcp.containsKey(cas.HCP_MDM_Id__c)) {
                        Account hcp = mdmidToHcp.get(cas.HCP_MDM_Id__c);
                        String key = getKey(hco.Id, hcp.Id);
                        if (!keyToStagingAffiliation.containsKey(key)) {
                            keyToStagingAffiliation.put(key, new List<Core_Staging_Affiliation__c>());
                        }
                        keyToStagingAffiliation.get(key).add(cas);
                    }
                }
            }
        }
    }

    private Map<String, List<Affiliation_vod__c>> getExistingAffiliations(List<Core_Staging_Affiliation__c> stagingAffiliations) {
        Map<String, List<Affiliation_vod__c>> keyToAffiliation = new Map<String, List<Affiliation_vod__c>>();
        Set<String> affiliationKeys = new Set<String>();
        Set<String> hcoIds = new Set<String>();
        Map<String, Core_Staging_Affiliation__c> keyToCas = new Map<String, Core_Staging_Affiliation__c>();
        for (Core_Staging_Affiliation__c cas : stagingAffiliations) {
            Account hcp = mdmidToHcp.get(cas.HCP_MDM_Id__c);
            List<Account> hcos = insIdToHcos.get(cas.HCO_INS_Id__c);
            if (hcp != null && hcos != null && !hcos.isEmpty()) {
                for (Account hco : hcos) {
                    affiliationKeys.add(getSoqlKey(hco.Id, hcp.Id, cas));
                    String key = getKey(hco.Id, hcp.Id);
                    hcoIds.add(hco.Id);
                    if (!keyToCas.containsKey(key)) {
                        keyToCas.put(key, cas);
                    }
                }
            }
        }
        for (Affiliation_vod__c affiliation : [
                SELECT Id, From_Account_vod__c, To_Account_vod__c, Role_vod__c, Record_Status_gne__c, Active_for_FRM_gne__c, Core_Staging_Affiliation__c, Primary_gne__c
                FROM Affiliation_vod__c
                WHERE From_Account_vod__c IN :hcoIds AND From_To_Key__c IN :affiliationKeys
        ]) {
            String key = getKey(affiliation.From_Account_vod__c, affiliation.To_Account_vod__c);
            if (keyToCas.containsKey(key)) {
                keyToAffiliation.put(key, new List<Affiliation_vod__c>());
            }
            keyToAffiliation.get(key).add(affiliation);
        }
        return keyToAffiliation;
    }

    private String getUniqueKey(String hcoId, String hcpId, String affiliationType) {
        return hcoId + '_' + hcpId + '_' + affiliationType;
    }

    private String getKey(String hcoId, String hcpId) {
        return 'From:' + hcoId + '_To:' + hcpId;
    }

    private String getSoqlKey(Id hcoId, Id hcpId, Core_Staging_Affiliation__c cas) {
        return hcoId + '_' + hcpId;
    }

    private String sendSummaryMail(List<String> emailAddresses, Datetime startTime, Datetime endTime) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(emailAddresses);
        String environment = GNE_SFA2_Util.getEnvironment();
        String title = 'Affiliation subscription finished';
        title = String.isNotBlank(environment) ? '(' + environment + ') ' + title : title;
        email.setSubject(title);

        String summary = 'Process start time: ' + startTime + plainTextLineBreak;
        summary += 'Process end time: ' + endTime + plainTextLineBreak;
        if (startTime != null && endTime != null) {
            summary += 'Running time: ' + CORE_Subscribe_Util.getDurationDescription(startTime, endTime) + plainTextLineBreak;
        }

        summary += plainTextLineBreak + 'Total number of records processed: ' + coreAffiliationRecords + plainTextLineBreak;
        summary += '-affiliations inserted: ' + createdAffiliations + plainTextLineBreak;
        summary += '-affiliations updated: ' + updatedAffiliations + plainTextLineBreak;
        summary += '-affiliations deactivated: ' + deactivatedAffiliations + plainTextLineBreak;

        summary += '-hcps created: ' + createdHcps + plainTextLineBreak;
        summary += '-affiliation query time: ' + affiliationQueryTime + plainTextLineBreak;
        summary += '-account query time: ' + accountQueryTime + plainTextLineBreak;

        if (stagingRecordUpdateErrors > 0) {
            summary += plainTextLineBreak;
            summary += '-staging record update errors count: ' + stagingRecordUpdateErrors + plainTextLineBreak;
            summary += 'Errors: ' + plainTextLineBreak;
            for (String errorMessage : errorMessages) {
                summary += errorMessage + plainTextLineBreak;
            }
        }

        if (affiliationRecordUpsertErrors > 0) {
            summary += plainTextLineBreak;
            summary += '-staging record update errors count: ' + affiliationRecordUpsertErrors + plainTextLineBreak;
            summary += 'Errors: ' + plainTextLineBreak;
            for (String errorMessage : affiliationErrorMessages) {
                summary += errorMessage + plainTextLineBreak;
            }
        }

        email.setPlainTextBody(summary);

        try {
            List<Messaging.SendEmailResult> result = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                    email
            });
            if (!result[0].isSuccess()) {
                System.debug('Couldn\'t send metrics summary email!');
            }
        } catch (Exception e) {
            System.debug('Couldn\'t send metrics summary email!');
        }
        return summary;
    }

    private void updateStagingRecordsAndStatistics(List<Core_Staging_Affiliation__c> stagingAffiliations) {
        List<Database.SaveResult> saveResults = Database.update(stagingAffiliations, false);
        for (Database.SaveResult saveResult : saveResults) {
            if (!saveResult.isSuccess()) {
                stagingRecordUpdateErrors++;
                for (Database.Error err : saveResult.getErrors()) {
                    String errorMessage = err.getStatusCode() + ': ' + err.getMessage();
                    if (!errorMessages.contains(errorMessage)) {
                        errorMessages.add(errorMessage);
                    }
                }
            }
        }
    }

    private void upsertAffiliationsRecordsAndStatistics(List<Affiliation_vod__c> affiliations) {
        List<Database.UpsertResult> upsertResults = Database.upsert(affiliations, false);
        for (Database.UpsertResult upsertResult : upsertResults) {
            if (!upsertResult.isSuccess()) {
                affiliationRecordUpsertErrors++;
                for (Database.Error err : upsertResult.getErrors()) {
                    String errorMessage = err.getStatusCode() + ': ' + err.getMessage();
                    if (!affiliationErrorMessages.contains(errorMessage)) {
                        affiliationErrorMessages.add(errorMessage);
                    }
                }
            }
        }
    }
}