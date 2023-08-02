public class GNE_FRM_Sync_Records_With_MDM_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    private Boolean runMultipleTimes = true;

    public GNE_FRM_Sync_Records_With_MDM_Batch(Boolean runMultipleTimes) {
        this.runMultipleTimes = runMultipleTimes;
    }

    public GNE_FRM_Sync_Records_With_MDM_Batch() {}

    private static Map<Id, RecordType> recordTypesMap = new Map<Id, RecordType>([
        SELECT Id, DeveloperName 
        FROM RecordType 
        WHERE SobjectType = 'Account' 
            AND DeveloperName = 'FRM_HCO'
    ]);
    
    public Database.QueryLocator start(Database.BatchableContext BC) {   
        Set <Id> recTypeIds = recordTypesMap.keySet();
        String query;
        Boolean isFeatureEnabled = GNE_Foun_Misc_Config_Items_gne__c.getValues('SyncMdmEnabled') != null 
            && GNE_Foun_Misc_Config_Items_gne__c.getValues('SyncMdmEnabled').Configuration_Value_gne__c == 'Enabled';
            
        Boolean isStillBatchRuning = [
            SELECT Id
            FROM AsyncApexJob 
            WHERE ApexClass.Name = 'GNE_FRM_Sync_Records_With_MDM_Batch'
            AND Status = 'Processing'
        ].size() > 0;
        
        if(isFeatureEnabled && !isStillBatchRuning){
            query = 
                'SELECT '+
                '    Name, Id, Primary_vod__c, MDM_Address_ID_gne__c, City_vod__c, State_vod__c, Zip_vod__c, Account_vod__c, '+
                '    Address_line_2_vod__c, Location_gne__Latitude__s, Location_gne__Longitude__s, '+
                '    Account_vod__r.MDMID_gne__c, Account_vod__r.RecordTypeId, Account_vod__r.Name, Account_vod__r.MDMID_Status_gne__c, '+
                '    Account_vod__r.Account_Type_gne__c, Account_vod__r.Stewardship_System_Name_gne__c, '+
                '    Account_vod__r.OwnerId '+
                'FROM '+
                '    Address_vod__c '+
                'WHERE '+
                '    Account_vod__r.RecordTypeId IN : recTypeIds '+
                '  AND '+
                '    ((Account_vod__r.MDMID_gne__c = null OR MDM_Address_ID_gne__c = null) '+
                       ' OR (Account_vod__r.MDM_Synch_Status_gne__c != \'' + GNE_SFA2_Account_Trigger_Helper.MDM_SYNCH_STATUS_SYNCHRONIZED + '\'))'+
                '  AND '+
                '    Region_Code_gne__c = 1';
        } else {
            query = 'SELECT Id FROM Address_vod__c LIMIT 0';
        }
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Address_vod__c> scope) {
        for(Address_vod__c addr : scope){
            if(addr.Account_vod__r.MDMID_gne__c == null || addr.MDM_Address_ID_gne__c == null){
                GNE_FRM_Synchronize_Records_With_MDM.syncOnAccountUpsert(createAccount(addr), addr, GNE_FRM_Synchronize_Records_With_MDM.DML_Type.DML_INSERT, false);
            } else {
                GNE_FRM_Synchronize_Records_With_MDM.syncOnAccountUpsert(createAccount(addr), addr, GNE_FRM_Synchronize_Records_With_MDM.DML_Type.DML_UPDATE, false);
            }
        }
    }

    public void finish(Database.BatchableContext BC){
        if(this.runMultipleTimes) {
            GNE_Batch_Runner.scheduleBatchBasedOnSettings(
                    new GNE_FRM_Sync_Records_MDM_Scheduler(),
                    'GNE_FRM_Sync_Records_MDM', 'Process Sync Records With MDM Job');
        }
    }
    
    private static Account createAccount(Address_vod__c addr){
        return new Account(
            Id = addr.Account_vod__c,
            MDMID_gne__c = addr.Account_vod__r.MDMID_gne__c, 
            RecordTypeId = addr.Account_vod__r.RecordTypeId, 
            Name = addr.Account_vod__r.Name, 
            MDMID_Status_gne__c = addr.Account_vod__r.MDMID_Status_gne__c, 
            Account_Type_gne__c = addr.Account_vod__r.Account_Type_gne__c, 
            Stewardship_System_Name_gne__c = addr.Account_vod__r.Stewardship_System_Name_gne__c,
            OwnerId = addr.Account_vod__r.OwnerId
        );
    }    
}