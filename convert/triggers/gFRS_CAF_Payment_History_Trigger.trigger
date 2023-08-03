trigger gFRS_CAF_Payment_History_Trigger on gFRS_CAF_Payment_Refund_History__c (after update, before update) {
    
    for(gFRS_CAF_Payment_Refund_History__c newPaymentHist : Trigger.new){
        
        gFRS_CAF_Payment_Refund_History__c oldPaymentHist = Trigger.oldMap.get(newPaymentHist.Id);
        
        //Update Payment Status to Success, if ESB populated SAP_Doc_ID__c
        if(newPaymentHist.SAP_Doc_ID__c != null && newPaymentHist.SAP_Doc_ID__c != oldPaymentHist.SAP_Doc_ID__c && Trigger.isBefore){
            newPaymentHist.Status__c = 'Success'; 
            newPaymentHist.Date__c = Date.today();
        }
        
    }
      
    
}