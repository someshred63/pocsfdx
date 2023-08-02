global without sharing class GNE_SFA2_HCPtoFRMHCOMappingBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {

    Datetime startTime;
    Datetime finishTime;
    private Boolean runMultipleTimes = true;

    global GNE_SFA2_HCPtoFRMHCOMappingBatch() {}

    global GNE_SFA2_HCPtoFRMHCOMappingBatch(DateTime startTime, DateTime finishTime) {
        this.startTime = startTime;
        this.finishTime = finishTime;    
    }

    global GNE_SFA2_HCPtoFRMHCOMappingBatch(Boolean runMultipleTimes) {
        this.runMultipleTimes = runMultipleTimes;
    }


    global Database.QueryLocator start(Database.BatchableContext bc) {
        Boolean isStillMappingBatchRuning = [
            SELECT Id
            FROM AsyncApexJob 
            WHERE ApexClass.Name = 'GNE_SFA2_HCPtoFRMHCOMappingBatch'
            AND Status IN ('Processing')
        ].size() > 0;

        Boolean isStillAddrLocationBatchRuning = [
            SELECT Id
            FROM AsyncApexJob 
            WHERE ApexClass.Name = 'GNE_SFA2_AddressLocation_Batch'
            AND Status IN ('Processing')
        ].size() > 0;

        if (!isStillMappingBatchRuning && !isStillAddrLocationBatchRuning) {
            if(startTime != null && finishTime != null) {
            	String sTime = startTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
            	String fTime = finishTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''); 
                String query = 'SELECT Id, HCP_Prescriber_First_Name__c, HCP_Prescriber_Last_Name__c, HCP_Prescriber_Middle_Name__c, HCP_MDM_ID__c, HCP_PACT_ID__c, HCP_Status__c, HCP_Professional_Type__c, HCP_Credentials__c, HCP_Prescriber_Address_Line_1__c, HCP_Prescriber_Address_Line_2__c, HCP_City__c, HCP_State__c, HCP_Zip__c, HCP_Address_MDM_ID__c, HCP_Address_PACT_ID__c, HCP_Prescriber_Phone__c, Products_List__c, PACT_Practice_Name__c FROM Case__x WHERE HCP_PACT_ID__c != null AND HCP_Address_PACT_ID__c != null AND CreatedDate__c >= ' + sTime + ' AND CreatedDate__c < ' + fTime;
            	return Database.getQueryLocator(query);
            } else {
                DateTime lastProcessExecutionTime = getLastProcessExecutionTime(bc);
                String timeStamp = lastProcessExecutionTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''); 
                String query = 'SELECT Id, HCP_Prescriber_First_Name__c, HCP_Prescriber_Last_Name__c, HCP_Prescriber_Middle_Name__c, HCP_MDM_ID__c, HCP_PACT_ID__c, HCP_Status__c, HCP_Professional_Type__c, HCP_Credentials__c, HCP_Prescriber_Address_Line_1__c, HCP_Prescriber_Address_Line_2__c, HCP_City__c, HCP_State__c, HCP_Zip__c, HCP_Address_MDM_ID__c, HCP_Address_PACT_ID__c, HCP_Prescriber_Phone__c, Products_List__c, PACT_Practice_Name__c FROM Case__x WHERE HCP_PACT_ID__c != null AND HCP_Address_PACT_ID__c != null AND (CreatedDate__c >= ' + timeStamp + ' OR SR_Prescriber_Address_Changed__c >= ' + timeStamp + ')';
            	return Database.getQueryLocator(query);
            }
        } else {
            System.abortJob(bc.getJobId());
            return Database.getQueryLocator('SELECT Id FROM Case__x LIMIT 1');
        } 
        
    }


    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Case__x> serviceRequests = (List<Case__x>)scope;
        (new GNE_SFA2_HCPtoFRMHCOMappingEngine()).init(serviceRequests);
    }
    
    global void finish(Database.BatchableContext BC) {
        if(this.runMultipleTimes) {
            GNE_Batch_Runner.scheduleBatchBasedOnSettings(
                    new GNE_SFA2_HCPtoFRMHCOMapping_Scheduler(),
                    'GNE_SFA2_HCPtoFRMHCOMapping', 'FRM Mapping Batch');
        }

        Id frmHCORecTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'FRM_HCO' LIMIT 1].Id;
        List<Address_vod__c> frmHCOAddressesWithoutCoordinates = [SELECT Id, Force_Location_Update_gne__c FROM Address_vod__c WHERE Account_vod__r.RecordTypeId = :frmHCORecTypeId AND (Location_gne__Latitude__s = null OR Location_gne__Longitude__s = null)];

        if (!frmHCOAddressesWithoutCoordinates.isEmpty()) {
            for (Address_vod__c addr : frmHCOAddressesWithoutCoordinates) {
                addr.Force_Location_Update_gne__c = true;
            }

            update frmHCOAddressesWithoutCoordinates;
        }

        Database.executeBatch(new GNE_SFA2_AddressLocation_Batch(true, true, true), 5);
    }

    global System.Type getSelfClass() {
        return GNE_SFA2_HCPtoFRMHCOMappingBatch.class;
    }

    private DateTime getLastProcessExecutionTime(Database.BatchableContext bc) {
        DateTime result = null;
        Id currentJobId = bc != null ? bc.getJobId() : null;
        
        for(AsyncApexJob job : [SELECT CreatedDate 
                                FROM AsyncApexJob
                                WHERE ApexClass.Name = :getSelfClass().getName()
                                    AND Id != :currentJobId
                                    AND ParentJobId = null
                                    AND JobType = 'BatchApex'
                                    AND Status = 'Completed'
                                    AND NumberOfErrors = 0
                                ORDER BY CreatedDate desc
                                LIMIT 1]) {
            result = job.CreatedDate; 
        }

        return result != null ? result : DateTime.now().addDays(-60);        
    }
  
}