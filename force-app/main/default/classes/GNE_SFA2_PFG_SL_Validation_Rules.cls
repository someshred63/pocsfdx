public with sharing class GNE_SFA2_PFG_SL_Validation_Rules {
    
    private static final String PHONE_REGEXP_PATTERN = '\\s*\\(\\d{3}\\)\\s*\\d{3}-\\s*\\d{4}\\s*';
    
    private static Boolean validateRequiredFields(SFA2_PFG_Storage_Location_gne__c slNew) {
        String errorLabel = GNE_SFA2_PFG_SL_Trigger_Helper.ERROR_FIELD_REQUIRED;
        Boolean failed = false;
        if(slNew.User_gne__c==null) {
            failed = true;
            slNew.User_gne__c.addError(errorLabel);
        }
        
        if(slNew.Status_gne__c==null) {
            failed = true;
            slNew.Status_gne__c.addError(errorLabel);
        }
        
        if(slNew.State_gne__c==null) {
            failed = true;
            slNew.State_gne__c.addError(errorLabel);
        }
        
        return failed;
    }
    
    private static Boolean validatePhoneNumbers(SFA2_PFG_Storage_Location_gne__c slNew) {
        Boolean failed = false;
        
        String errorLabel = GNE_SFA2_PFG_SL_Trigger_Helper.ERROR_PHONE_FORMAT_NOT_VALID;
        String regExpSring = PHONE_REGEXP_PATTERN;
    
        if(slNew.Phone_gne__c!=null && !Pattern.matches(regExpSring, slNew.Phone_gne__c)) {
            failed = true;
            slNew.Phone_gne__c.addError(errorLabel);
        }
        
        return failed;  
    }
    
    private static Boolean validateUserFieldsChanged(SFA2_PFG_Storage_Location_gne__c slOld, SFA2_PFG_Storage_Location_gne__c slNew) {
        Boolean failed = false;
        String profileName = GNE_SFA2_PFG_SL_Trigger_Helper.getCurrentUserProfileName();
        if(!profileName.containsIgnoreCase('GNE-SYS') && !profileName.containsIgnoreCase('GNE-SFA-InternalUser') && !profileName.containsIgnoreCase('System') && !profileName.startsWithIgnoreCase('GNE-SFA-OPS')) {
        
            String errorLabel = GNE_SFA2_PFG_SL_Trigger_Helper.ERROR_CANNOT_CHANGE_USER;
            
            if(slOld.User_gne__c!=slNew.User_gne__c) {
                failed = true;
                slNew.addError(errorLabel);
            }
        }
        
        return failed;  
    }
    
    private static void runValidationRulesOnUpdate(List<SFA2_PFG_Storage_Location_gne__c> triggerOld, List<SFA2_PFG_Storage_Location_gne__c> triggerNew) {
        
        Boolean validationFailed;
        
        Integer size = triggerNew.size();
        for (Integer i = 0;i<size;i++) {
            SFA2_PFG_Storage_Location_gne__c slNew = triggerNew[i];
            SFA2_PFG_Storage_Location_gne__c slOld = triggerOld[i];
            
            validationFailed = validateRequiredFields(slNew) || 
                               validatePhoneNumbers(slNew) ||
                               validateUserFieldsChanged(slOld, slNew);
                        
            if(validationFailed) {
                GNE_SFA2_PFG_SL_Trigger_Helper.setFailedValidation(slNew.Id);
            }
        }
    }

    private static void runValidationRulesOnInsert(List<SFA2_PFG_Storage_Location_gne__c> triggerNew) {
        
        Boolean validationFailed;
        
        for (SFA2_PFG_Storage_Location_gne__c slNew : triggerNew) {
            validationFailed = validateRequiredFields(slNew) || 
                               validatePhoneNumbers(slNew);
            
            if(validationFailed) {
                GNE_SFA2_PFG_SL_Trigger_Helper.setFailedValidation(slNew.Id);
            }
        }
    }
    
    public static void onBeforeUpdate(List<SFA2_PFG_Storage_Location_gne__c> triggerOld, List<SFA2_PFG_Storage_Location_gne__c> triggerNew) {
        runValidationRulesOnUpdate(triggerOld, triggerNew);
    }

    public static void onBeforeInsert(List<SFA2_PFG_Storage_Location_gne__c> triggerNew) {
        runValidationRulesOnInsert(triggerNew);
    }
    
    public static void onBeforeDelete(List<SFA2_PFG_Storage_Location_gne__c> triggerOld) {
    
    }
}