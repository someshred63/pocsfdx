/**
* @author GFRS Dev Team
* @date 25/01/2018
* @description gFRS_MigrateVendorsIdBatch class - migrate all Vendor Ids to new field Old Vendor Id, sets Partner Bank Type field
*              according to SAP feed data. It also update Vendor Account Group to PC01 or Z003 based on vendor (PC01 for new vendors)
*              See JIRA GFRS-1022 for more information.
*/
global with sharing class gFRS_MigrateVendorsIdBatch implements Database.Batchable<sObject>, Database.Stateful {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        gFRS_SOQLBuilder query = new gFRS_SOQLBuilder()
                .selectFields(new String[]{
                        'Name', 'Vendor_ID__c', 'Old_Vendor_ID__c', 'Vendor_Account_Group__c', 'Partner_Bank_Type__c', 'Payment_Method__c'
                })
                .fromObject('GFRS_Location__c');
        return query.getQueryLocator();
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {

        List<GFRS_Location__c> locationsToUpdate = new List<GFRS_Location__c>();

        Set<String> scopeIds = new Set<String>();
        for (GFRS_Location__c loc : (List<GFRS_Location__c>) scope) {
            if(String.isNotBlank(loc.Vendor_ID__c))
                scopeIds.add(loc.Vendor_ID__c);
        }

        List<GFRS_SAP_feed__c> sapFeeds = getAllSapFeeds(scopeIds);

        for (GFRS_Location__c item : (List<GFRS_Location__c>) scope) {

            if(String.isBlank(item.Vendor_ID__c))
                continue;

            GFRS_SAP_feed__c sapData = getSingleSapData(sapFeeds, item.Vendor_ID__c);

            if (sapData != null) {
                item.Old_Vendor_ID__c = item.Vendor_ID__c;
                item.Vendor_ID__c = sapData.New_Vendor_Id__c;
                item.Partner_Bank_Type__c = sapData.Partner_Bank_Type__c;
                if(String.isNotBlank(sapData.Payment_Method__c)) {
                    item.Payment_Method__c = sapData.Payment_Method__c;
                }
            }

            locationsToUpdate.add(item);
        }
        try {
            List<Database.SaveResult> results = Database.update(locationsToUpdate, false);
            for (Database.SaveResult result : results) {
                if (!result.isSuccess()) {
                    for (Database.Error err : result.getErrors()) {
                        System.debug(LoggingLevel.ERROR, 'Error [Migrate vendor Ids] Save failed: ' + result.getId() + ';' + err.getStatusCode() + '; ' + err.getMessage());
                    }
                }
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
        }
    }

    global void finish(Database.BatchableContext bc) {
        AsyncApexJob job = [
                SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems
                FROM AsyncApexJob
                WHERE Id = :bc.getJobId()
        ];
        System.debug('INFO [Migrate vendor Ids] Job: ' + job);
    }

    private static List<GFRS_SAP_feed__c> getAllSapFeeds(Set<String> uniqueIds) {
        return ([
                SELECT Id, Name, Old_Vendor_Id__c, New_Vendor_Id__c, Partner_Bank_Type__c, Payment_Method__c
                FROM GFRS_SAP_feed__c
                WHERE Old_Vendor_Id__c IN :uniqueIds
        ]);
    }

    private static GFRS_SAP_feed__c getSingleSapData(List<GFRS_SAP_feed__c> source, String vendorId) {
        for (GFRS_SAP_feed__c feed : source) {
            if (feed.Old_Vendor_Id__c.equals(vendorId)) {
                return feed;
            }
        }
        return null;
    }
}