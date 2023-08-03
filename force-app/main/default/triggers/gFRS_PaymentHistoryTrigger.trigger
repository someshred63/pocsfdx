trigger gFRS_PaymentHistoryTrigger on GFRS_Payment_History__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {

    if (Trigger.isBefore) {
        if (Trigger.isUpdate) {
            gFRS_FundingProcess.CheckESBPaymentUpdate(Trigger.new, Trigger.oldMap);
            gFRS_PaymentUtil.setSubStatusAndBlockForPayments(Trigger.newMap, Trigger.oldMap);
        }
    }

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            gFRS_Util_NoShare.updateFinanceReportJunctionPaymentHistoryOnInsert(Trigger.new);
            gFRS_PaymentUtil.setApprovedFiscalYearAfterRefundPaymentSubmitted(Trigger.new);
        } else if (Trigger.isUpdate) {
            /*Releases the paymentHistory if the ESB sets the status into released, and sets the status of the
             funding request to approved.*/
            gFRS_FundingProcess.releasePaymentHistoryApprovesFR(Trigger.new, Trigger.oldMap);

            gFRS_FundingProcess.updateRefundedAmountAfterRefundHistorySuccess(Trigger.new, Trigger.oldMap);
            // NOTE: Below line was commented to interim fix issues with Payment Reversal after 5.3 deployment. It breaks gFRS Finance Report Functionality.
            //gFRS_Util_NoShare.updateFinanceReportJunctionPaymentHistoryUpdate( Trigger.new, Trigger.oldMap );
        } else if (Trigger.isDelete) {
            gFRS_FundingProcess.updateRefundedAmountAfterRefundHistoryDeleted(Trigger.old);
        }
    }
}