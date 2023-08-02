public class GNE_SFA2_AccountTriggerHandlerLogic {
    private static Boolean isFeatureEnabled = GNE_Foun_Misc_Config_Items_gne__c.getValues('SyncMdmEnabled') != null 
            && GNE_Foun_Misc_Config_Items_gne__c.getValues('SyncMdmEnabled').Configuration_Value_gne__c == 'Enabled';
    private static Map<Id, RecordType> recordTypesMap = new Map<Id, RecordType>([
        SELECT Id, DeveloperName 
        FROM RecordType 
        WHERE SobjectType = 'Account' 
            AND DeveloperName = 'FRM_HCO'
    ]);
    private static final List<String> FIELDS = new List<String> {'Name','Account_type_gne__c', 'MDMID_Status_gne__c'};
        
    public static void updateMDMSynchStatus(){
        if(isFeatureEnabled){
            for(Account acc : (Account[])Trigger.newMap.values()){
                Account oldAccount = (Account)Trigger.oldMap.get(acc.Id);
                if(isRecordApplicable(acc, oldAccount)){
                    acc.MDM_Synch_Status_gne__c = GNE_SFA2_Account_Trigger_Helper.MDM_SYNCH_STATUS_PENDING;
                }
            }           
        }
    }
    
    private static Boolean isRecordApplicable(Account newAccount, Account oldAccount){
        Boolean isRecordApplicable = false;
        if(!recordTypesMap.containsKey(newAccount.RecordTypeId)){
            return isRecordApplicable;
        }
        
        for(String field :FIELDS){
            Object newValue = newAccount.get(field);
            Object oldValue = oldAccount.get(field);
            if(oldValue != newValue){
                isRecordApplicable = true;
                break;
            }
        }
        
        return isRecordApplicable;
    }
}