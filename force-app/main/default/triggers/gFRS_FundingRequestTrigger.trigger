trigger gFRS_FundingRequestTrigger on GFRS_Funding_Request__c (after delete, after insert,
after update, before delete, before insert, before update)
{
    String debugPrefix = ' ** gFRS_FundingRequestTrigger ** ';
    String debugPrefixBefore = ' ** BEFORE ** ';
    String debugPrefixAfter = ' ** AFTER ** ';
    String debugPrefixInsert = ' ** Insert ** ';
    String debugPrefixUpdate = ' ** Update ** ';
    
    GFRS_OrgSettings__c myOrgCS = GFRS_OrgSettings__c.getOrgDefaults();
    
    if (!GFRS_Actions_Scheduler.editEnabled()) {
        throw new gFRS_Util.CustomException(System.Label.GFRS_Act_Sch_Upd_Not_Allowed_Error);
    }
    if (myOrgCS.Funding_Request_Trigger_Enabled__c) {
        System.debug('GFRS DEV DEBUG: gFRS Funding Request Trigger ENABLED');
        /*** BEFORE SECTION ***/
        if (Trigger.isBefore) {
            System.debug( debugPrefix + debugPrefixBefore + ' : ' + Trigger.new);
            if (Trigger.isInsert) {
                System.debug( debugPrefix + debugPrefixInsert );
                /***Put here your befor instert methods***/
                clearOtherHealthcareAudience(); // GFRS-758
                clearOtherEventProgramSubtype(); // GFRS-800
                clearOtherIssueType(); // GFRS-825
                clearGNEAlignmentOther(); //GFRS-831
                gFRS_Util.updateStatusLastModifiedDate2( Trigger.new, Trigger.oldMap );
                gFRS_Util_NoShare.setLastGrantStatus(Trigger.new, Trigger.oldMap);
                //SFDC-3513 BU-TA defaulting
                gFRS_Util.SetBusinessUnit(Trigger.new, Trigger.oldMap);
            }
            else if (Trigger.isUpdate) {
                System.debug( debugPrefix + debugPrefixUpdate );
                gFRS_Util.validateFundingTypeChange(Trigger.new, Trigger.oldMap);
                //***Put here your before Update methods
                clearOtherHealthcareAudience(); // GFRS-758
                    clearOtherEventProgramSubtype(); // GFRS-800
                    clearOtherIssueType(); // GFRS-825
                    clearGNEAlignmentOther(); //GFRS-831
                    gFRS_Util_NoShare.foundationBA1ApproveSubStatusUpdate(Trigger.newMap, Trigger.oldMap);
                    //SFDC-3513 BU-TA defaulting
                    gFRS_Util.SetBusinessUnit(Trigger.new, Trigger.oldMap);
                    //
                    gFRS_Util.setBiogenIdecLogo(Trigger.newMap, Trigger.new, myOrgCS,trigger.oldMap);
                    //
                    gFRS_Util_NoShare.setLastGrantStatus(Trigger.new, Trigger.oldMap);
                    //
                    gFRS_Util_NoShare.setClosedDate(Trigger.new, Trigger.oldMap);
                    //
                    gFRS_Util_NoShare.resetSysRequestApprovedToNo(Trigger.new, Trigger.oldMap);
                    //
                    gFRS_Util_NoShare.setProcessPaymentStatusDate(Trigger.new, Trigger.oldMap);
                    //
                    gFRS_Util.autoPopulateCCOOwnerIfNeeded(Trigger.new, Trigger.oldMap);
                    //SFDC-1457
                    gFRS_Util.updateUnixID(Trigger.new, Trigger.oldMap);
                    //SFDC-1468
                    gFRS_Util.RfiResetInformationNeeded(Trigger.new);
                    //
                    gFRS_Util.setApprovalOptionalStepStatus(Trigger.new, Trigger.OldMap);
                    //
                    gFRS_Util.transferApprovalSteps(Trigger.new, Trigger.oldMap );
                    //
                    gFRS_Util.updateStatusLastModifiedDate2(Trigger.new, Trigger.oldMap);
                    //
                    gFRS_Util.updateFundingTypeName(Trigger.new, Trigger.oldMap);
                    //
                    gFRS_Util.resetFieldsAfterRecall(Trigger.new, Trigger.oldMap);

                    gFRS_Util.setRecallDate(Trigger.new, Trigger.oldMap);
                    //
                    gFRS_Util.beforeUpdateFundingRequestLogic(Trigger.new, Trigger.oldMap);
                    //
                    gFRS_Util_NoShare.setDeliveryMethodForFundationOrNo(Trigger.new, Trigger.oldMap);
                    //
                    gFRS_Util.setFundingSubTypeForInternalFundingTypes(Trigger.new, Trigger.oldMap);
                    //
                    gFRS_InternalCancellationProcess.processRejectedRequest(Trigger.new, Trigger.oldMap);
                    // GFRS-983
                    gFRS_Util_NoShare.updateSubstatusOnProgramDatesChange(Trigger.new, Trigger.oldMap);
                    // GFRS-1023
                    gFRS_Util.updateFocusAreaField(Trigger.new);
                    // GFRS-1083
                    if(GFRS_CheckRecursive.runOnce()) {
                        gFRS_Util_NoShare.validateIfExceededOrganizationBudgetOrRevenue(Trigger.newMap, Trigger.oldMap);
                        // GFRSME2-3
                        gFRS_Util.cleanupRequestFieldsAfterFundingTypeChange(Trigger.new, Trigger.oldMap);
                    }
                gFRS_Util_NoShare.populateAcknowledgeBudgetOrRevenueForApprovedRequests(Trigger.newMap, Trigger.oldMap);
                // GFRS-1102
                //gFRS_Util.sendApprovalNotificationEmailsToFundingRequestOwner(Trigger.new, Trigger.oldMap);
            }
        }
        /*** AFTER SECTION ***/
        if (Trigger.isAfter) {
            System.debug( debugPrefix + debugPrefixAfter + ' : ' + Trigger.new);
            if (Trigger.isInsert) {
                System.debug( debugPrefix + debugPrefixInsert );
                /* new implementation of creating default Funding allocation. */
                Type t = Type.forName('gFRS_PaymentProcess');
                gFRS_FundingProcess paymentProcess = (gFRS_FundingProcess)t.newInstance();
                paymentProcess.createFundingAllocation(Trigger.newMap, Trigger.oldMap);
                gFRS_Util.createDefaultFRPrograms( Trigger.new );
                gFRS_Util.assignFinancialApprovers( Trigger.new);
                gFRS_Util.upsertFundingRequestStatusHistory(Trigger.newMap, null);
                gFRS_Util_NoShare.updateOutcomesSubmisson(Trigger.new);
            }
            else if (Trigger.isUpdate) {
                //gFRS_Util_NoShare.restrictBA1FromEditting(Trigger.newMap, Trigger.oldMap);
                gFRS_Util_NoShare.stopQCOApprovalIfTaskOpen(Trigger.newMap, Trigger.oldMap);
                gFRS_Util_NoShare.validateBA1Approval(Trigger.newMap, Trigger.oldMap);                
                gFRS_Util_NoShare.validateFA1Approval(Trigger.newMap, Trigger.oldMap);
                gFRS_Util_NoShare.validateFA3Approval(Trigger.newMap, Trigger.oldMap);
                gFRS_Util_NoShare.stopApprovalProcessIFBADidntSetApprovedAmount(Trigger.newMap, Trigger.oldMap);
                gFRS_Util_NoShare.stopApprovalProcessIFBADidntSetFA4(Trigger.newMap, Trigger.oldMap);                
                gFRS_Util_NoShare.stopApprovalProcessIFFA3DidntSetComAcitvity(Trigger.newMap, Trigger.oldMap);
                gFRS_Util_NoShare.stopApprovalProcessIfGCDidntSetApprovers(Trigger.newMap, Trigger.oldMap);
                if (myOrgCS.gFRS_Legal_Reviewer_Fields_Required__c){
                    gFRS_Util_NoShare.stopApprovalIfLRNotSpecified(Trigger.newMap, Trigger.oldMap);
                    gFRS_Util_NoShare.stopApprovalIfLRNeedToBeSpecifiedWhenComplianceRed(Trigger.newMap, Trigger.oldMap);
                }
                gFRS_Util_NoShare.stopApprovalIfBA1IsRequired(Trigger.newMap, Trigger.oldMap);
                gFRS_Util_NoShare.addSharingForBrBaApproversForFoundation(Trigger.newMap, Trigger.oldMap);
                gFRS_Util_NoShare.addSharingForChangedApprovers(Trigger.newMap, Trigger.oldMap); // GFRS-979
                gFRS_Util.upsertFundingRequestStatusHistory(Trigger.newMap, Trigger.oldMap);
                System.debug('Check how many times its executed');
                gFRS_gCalEventsUtil.addProgramsToGcalUnderFundingRequest(Trigger.newMap, Trigger.oldMap);
                /*** SFDC-1996 New Payment/Refund Processing ***/
                Type t = Type.forName('gFRS_PaymentProcess');
                gFRS_FundingProcess paymentProcess = (gFRS_FundingProcess)t.newInstance();
                paymentProcess.createFundingAllocation(Trigger.newMap, Trigger.oldMap);
                paymentProcess.updateFieldInitiatedExhibitsSplits(Trigger.new, Trigger.oldMap, Trigger.newMap);
                paymentProcess.resetFALITotalAmount(Trigger.new, Trigger.oldMap );
                paymentProcess.updateFALIFundingRequestType( Trigger.new, Trigger.oldMap );
                /***/

                gFRS_Util_NoShare.createAppropriateTask(Trigger.new, Trigger.oldMap);
                if(GFRS_CheckRecursive.runOnceAfter()) {
                    gFRS_Util.sendNotification(Trigger.New, Trigger.oldMap);
                    gFRS_Util.cleanupFieldsAfterFundingTypeChange(Trigger.New, Trigger.oldMap);
                }
                gFRS_Util_NoShare.submitHC_Programs(Trigger.new, Trigger.oldMap);
                gFRS_Util.createActivities(Trigger.new, Trigger.oldMap);
                gFRS_Util.changeStatusOnApproval(Trigger.new, Trigger.oldMap);
                gFRS_Util.submitForApproval(Trigger.newMap, Trigger.oldMap);
                gFRS_PaymentUtil.setSubStatusForPaymentsWhenLoaChanged(Trigger.newMap, Trigger.oldMap);
                gFRS_Util_NoShare.updateOutcomesSubmisson(Trigger.new, Trigger.oldMap);
                gFRS_Util_NoShare.resetToSunshineAfterReconTaskStarted(Trigger.new, Trigger.oldMap);
                // GFRS-1083
                gFRS_Util_NoShare.calculateOrganizationTotalApprovedCurrentYear(
                    Trigger.isUpdate,
                    Trigger.isDelete,
                    Trigger.New, Trigger.oldMap);
                // GFRSME2-7
                gFRS_Util_NoShare.setFiscalYear(Trigger.New, Trigger.oldMap);
                // GFRSME2-11
                gFRS_Util_NoShare.checkForBAApprovalAndWBSCode(Trigger.newMap, Trigger.oldMap);
                // GFRSME2-4
                gFRS_Util_NoShare.deleteStatusUpdateTask(Trigger.new, Trigger.oldMap);
                gFRS_Util_NoShare.statusUpdateTaskReminder(Trigger.new, Trigger.oldMap);                

            } else if(Trigger.isDelete) {
                // GFRS-1083
                gFRS_Util_NoShare.calculateOrganizationTotalApprovedCurrentYear(
                    Trigger.isUpdate,
                    Trigger.isDelete,
                    Trigger.New, Trigger.oldMap);
            }

        }
    } else {
        System.debug('GFRS DEV DEBUG: gFRS Funding Request Trigger DISABLED');
    }
    /**
     * Clears comments provided for Other value on Healthcare Audience picklist while its deselection.
     */
    void clearOtherHealthcareAudience() {
        for (GFRS_Funding_Request__c req : Trigger.isBefore ? Trigger.new : new GFRS_Funding_Request__c[]{ }) {
            if ((Trigger.isInsert || Trigger.isUpdate && (
                req.Healthcare_Audience_other__c != Trigger.oldMap.get(req.Id).Healthcare_Audience_other__c ||
                req.Healthcare_Audience__c != Trigger.oldMap.get(req.Id).Healthcare_Audience__c
            )) && (';' + req.Healthcare_Audience__c + ';').indexOf(';Other;') < 0 && String.isNotBlank(
                req.Healthcare_Audience_other__c
            )) {
                req.Healthcare_Audience_other__c = null;
            }
        }
    }
    /**
     * Clears comments provided for Other value on Event / program subtype picklist while its deselection.
     */
    void clearOtherEventProgramSubtype() {
        for (GFRS_Funding_Request__c req : Trigger.isBefore ? Trigger.new : new GFRS_Funding_Request__c[]{ }) {
            if ((Trigger.isInsert || Trigger.isUpdate && (
                req.Event_Project_sub_type_other__c != Trigger.oldMap.get(req.Id).Event_Project_sub_type_other__c ||
                req.Event_Project_sub_type__c != Trigger.oldMap.get(req.Id).Event_Project_sub_type__c
            )) && (';' + req.Event_Project_sub_type__c + ';').indexOf(';Other;') < 0 && String.isNotBlank(
                req.Event_Project_sub_type_other__c
            )) {
                req.Event_Project_sub_type_other__c = null;
            }
        }
    }
     /**
     * Clears comments provided for Other value on Issue type picklist while its deselection.
     */
    void clearOtherIssueType() {
        for (GFRS_Funding_Request__c req : Trigger.isBefore ? Trigger.new : new GFRS_Funding_Request__c[]{ }) {
            if ((Trigger.isInsert || Trigger.isUpdate && (
                req.Issue_type_other__c != Trigger.oldMap.get(req.Id).Issue_type_other__c ||
                req.Issue_type__c != Trigger.oldMap.get(req.Id).Issue_type__c
            )) && (';' + req.Issue_type__c + ';').indexOf(';Other;') < 0 && String.isNotBlank(
                req.Issue_type_other__c
            )) {
                req.Issue_type_other__c = null;
            }
        }
    }
    /**
     * Clears comments provided for Other value on GNE Alignment picklist while its deselection.
     */
    void clearGNEAlignmentOther() {
        for (GFRS_Funding_Request__c req : Trigger.isBefore ? Trigger.new : new GFRS_Funding_Request__c[]{ }) {
            if ((Trigger.isInsert || Trigger.isUpdate && (
                req.GNE_Alignment_other__c != Trigger.oldMap.get(req.Id).GNE_Alignment_other__c ||
                req.GNE_Alignment__c != Trigger.oldMap.get(req.Id).GNE_Alignment__c
            )) && (';' + req.GNE_Alignment__c + ';').indexOf(';Other;') < 0 && String.isNotBlank(
                req.GNE_Alignment_other__c
            )) {
                req.GNE_Alignment_other__c = null;
            }
        }
    }
}