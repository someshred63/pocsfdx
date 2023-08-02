public class GNE_SFA2_AddressTriggerHandlerLogic {
    private static Boolean isFeatureEnabled = GNE_Foun_Misc_Config_Items_gne__c.getValues('SyncMdmEnabled') != null 
            && GNE_Foun_Misc_Config_Items_gne__c.getValues('SyncMdmEnabled').Configuration_Value_gne__c == 'Enabled';
    private static Map<Id, RecordType> recordTypesMap = new Map<Id, RecordType>([
        SELECT Id, DeveloperName 
        FROM RecordType 
        WHERE SobjectType = 'Account' 
            AND DeveloperName = :GNE_SFA2_Account_Trigger_Helper.REC_TYPE_FRM_HCO
    ]);
    private static final List<String> FIELDS = new List<String> {'Name', 'Address_line_2_vod__c', 'City_vod__c', 'State_vod__c', 'Zip_vod__c'};
        
    public static void updateMDMSynchStatus() {
        if(isFeatureEnabled){
            Set<Id> accIds = fetchAccountsIds();
            Map<Id, Account> accountsMap = fetchAccountMap(accIds);
            List<Account> toUpdate = new List<Account>();
            for(Address_vod__c addr : (Address_vod__c[])Trigger.newMap.values()) {
                Address_vod__c oldAddr = (Address_vod__c)Trigger.oldMap.get(addr.Id);
                Account acc = fetchAccount(addr, accountsMap);
                
                if(acc != null && isRecordApplicable(acc, addr, oldAddr)) {
                    acc.MDM_Synch_Status_gne__c = GNE_SFA2_Account_Trigger_Helper.MDM_SYNCH_STATUS_PENDING;
                    toUpdate.add(acc);
                }
            }    
            Database.update(toUpdate);
        }        
    } 

    private static Account fetchAccount(Address_vod__c addr, Map<Id, Account> accountsMap) {
        Account acc;
        if(accountsMap.get(addr.Account_vod__c) != null) {
            acc = accountsMap.get(addr.Account_vod__c);
        }
        return acc;
    }    
    
    private static Set<Id> fetchAccountsIds() {
        Set<Id> accIds = new Set<Id>();
        for(Address_vod__c addr : (Address_vod__c[])Trigger.newMap.values()){
            accIds.add(addr.Account_vod__c);
        }
        return accIds;
    }
    
    private static Map<Id, Account> fetchAccountMap(Set<Id> accIds) {
        return new Map<Id, Account>([
            SELECT RecordTypeId, MDM_Synch_Status_gne__c
            FROM Account
            WHERE Id IN : accIds
        ]);
    }
    
    private static Boolean isRecordApplicable(Account acc, Address_vod__c newAdd, Address_vod__c oldAddr) {
        Boolean isRecordApplicable = false;
        if(!recordTypesMap.containsKey(acc.RecordTypeId)){
            return isRecordApplicable;
        }
        
        for(String field :FIELDS){
            Object newValue = newAdd.get(field);
            Object oldValue = oldAddr.get(field);
            if(oldValue != newValue){
                isRecordApplicable = true;
                break;
            }
        }
        
        return isRecordApplicable;
    }
}