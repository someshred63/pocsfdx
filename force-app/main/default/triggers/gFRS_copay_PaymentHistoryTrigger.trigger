trigger gFRS_copay_PaymentHistoryTrigger on GFRS_Copay_Payment_History__c (before update, after update) {
     if( Trigger.isBefore){
        gFRS_Util_NoSharecopay.CheckESBPaymentUpdate(Trigger.new,Trigger.oldMap);           
     }
     else{
        gFRS_Util_NoSharecopay.paymentSuccessUpdates(Trigger.new,Trigger.oldMap);       
     }

}