trigger gFRS_Ltng_PaymentHistoryTrigger on gFRS_Ltng_Payment_History__c (before update, after update) {

    //Before Update
    if(Trigger.isUpdate && Trigger.isBefore){
        gFRS_Ltng_PaymentUtil.setBlockAndSubStatusForPayments(trigger.newMap,trigger.oldMap);
    }
    
    //After Update
    if(Trigger.isUpdate && Trigger.isAfter){
        gFRS_Ltng_PaymentUtil.handlePaymentUpdates(trigger.new, trigger.oldMap);
        gFRS_Ltng_PaymentUtil.updateAppPaymntId(trigger.new, trigger.oldMap);
    }
}