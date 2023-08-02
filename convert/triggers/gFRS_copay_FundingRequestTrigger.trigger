trigger gFRS_copay_FundingRequestTrigger on gFRS_Copay_Funding_Request__c (
    after delete, after insert, after undelete, 
    after update, before delete, before insert, before update)
{
    
    if(Trigger.isAfter && Trigger.isUpdate)
    {
        gFRS_Utilcopay.submitForApprovalcopay(Trigger.new, Trigger.oldMap);
        gFRS_Util_NoSharecopay.createAppropriateTask(trigger.new, trigger.oldMap);
        gFRS_Utilcopay.shareRecordWithApprovers(trigger.new, trigger.oldMap);
        gFRS_Util_NoSharecopay.clearDSPaymentAmounts(Trigger.oldMap, Trigger.new);
    }
    
    else if(Trigger.isBefore && Trigger.isUpdate)
    {  
        gFRS_Util_NoSharecopay.copayApprovalValidations(Trigger.newMap, Trigger.oldMap, Trigger.new);          
        gFRS_Utilcopay.autoPopulateApproverIfNeeded(Trigger.new, Trigger.oldMap);
        gFRS_Utilcopay.RfiResetInformationNeeded(Trigger.new);
    }
    
    else if(Trigger.isAfter && Trigger.isInsert)
    {
        Type t = Type.forName('gFRS_PaymentProcess');
        gFRS_PaymentProcessCopay paymentProcess = new gFRS_PaymentProcessCopay();
        paymentProcess.createFundingAllocation(Trigger.newMap);
    }   
    
}