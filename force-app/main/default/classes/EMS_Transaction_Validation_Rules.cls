public without sharing class EMS_Transaction_Validation_Rules {

    public static boolean onBeforeInsertUpdate(List<EMS_Transaction_gne__c> triggerNew) {
        boolean result = false;
        result = (runValidationRulesOnInsertUpdate(triggerNew));
        return result;
    }

    private static boolean runValidationRulesOnInsertUpdate(List<EMS_Transaction_gne__c> triggerNew) {
        for (EMS_Transaction_gne__c trans : triggerNew) {
            if (validateAmount(trans)) {
                return true;
            }
        }
        return false;
    }

    private static boolean validateAmount(EMS_Transaction_gne__c trans) {
        if (trans.Fee_Amount_gne__c == null || trans.Fee_Amount_gne__c <= 0) {
            trans.addError('Amount must be greater than 0.');
            return true;
        }
        return false;
    }
}