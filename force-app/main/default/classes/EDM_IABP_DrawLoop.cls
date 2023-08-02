public with sharing class EDM_IABP_DrawLoop {

    @TestVisible
    private static Integer loopMessageRequestCount = 0;

    private static Integer NUMBER_OF_NOT_CUSTOMIZED_DOCUMENTS = 2;

    private static String BUDGET_TYPE_PATIENT_ADVISOR = 'Patient Advisor';
    
    private static String DOC_TYPE_AGREEMENT = 'Agreement';
    private static String DOC_TYPE_INVITE = 'Invite';

    private static String EDM_TYPE_MODERATOR = 'Moderator';
    private static String EDM_TYPE_CLINICAL_EXPERT = 'Clinical Expert';
    private static String EDM_TYPE_CHAIR = 'Chair';
    private static String EDM_TYPE_PATIENT = 'Patient';
    private static String EDM_TYPE_ADVISOR = 'Advisor';
    private static String EDM_TYPE_IADVISE = 'iAdvise';
    private static String EDM_TYPE_SYSTEM_GENERATED = 'System Generated';

    private static String EDM_STATUS_IABP_SUBMITTED_FOR_APPROVAL = 'IABP Submitted for Approval';
    private static String EDM_STATUS_IABP_APPROVED = 'IABP Approved';

    private static String STANDARD_INVITE = 'Standard Invite';
    private static String STANDARD_AGREEMENT = 'Standard Agreement';
    private static String IADVISE_INVITE = 'iAdvise Invite';
    private static String IADVISE_AGREEMENT = 'iAdvise Agreement';

    public static void onAfterUpdate(List<EDM_IABP_gne__c> triggerOld, Map<Id,EDM_IABP_gne__c> triggerNew) {
        Set<Id> approvedIABPIds = new Set<Id>();
        for (EDM_IABP_gne__c oldIABP : triggerOld) {
            EDM_IABP_gne__c newIABP = triggerNew.get(oldIABP.Id);
            if (oldIABP.EDM_Status_gne__c == EDM_STATUS_IABP_SUBMITTED_FOR_APPROVAL && newIABP.EDM_Status_gne__c == EDM_STATUS_IABP_APPROVED) {
                approvedIABPIds.add(newIABP.Id);
            }
        }
        if (!approvedIABPIds.isEmpty()) {
            process(approvedIABPIds);
        }
    }

    private static void process(Set<Id> approvedIABPIds) {
        updateDutiesOnBudgetsBeforeFutureCall(approvedIABPIds);
        generateInvitationsAndAgreementsFutureCall(approvedIABPIds, UserInfo.getSessionId());
    }

    public static void generate(Id iabpId) {
        //for delete is responsible calling class, because of sharing rules
        process(new Set<Id> {iabpId});
    }

    @Future(callout=true)
    public static void generateInvitationsAndAgreementsFutureCall(Set<Id> approvedIABPIds, String sessionId) {
        generateInvitations(approvedIABPIds, sessionId);
        generateAgreements(approvedIABPIds, sessionId);
    }

    public static void generateInvitations(Set<Id> approvedIABPIds, String sessionId) {
        final String DDP_NAME_INVITATION = 'EDM IABP Invitation by Budget';

        EDM_IABP_DDPs invitationDDPs = new EDM_IABP_DDPs(DDP_NAME_INVITATION);

        Loop.loopMessage lm = new Loop.loopMessage();
        lm.sessionId = sessionId;
        //lm.batchNotification = Loop.loopMessage.Notification.ON_ERROR; //default is None

        if (invitationDDPs.ddpId != null) {
            addLoopMessageRequestForBudgets(lm, getBudgetsWithoutChairForiAdvise(approvedIABPIds), invitationDDPs);
            addLoopMessageRequestForBudgets(lm, getBudgetsForPatient(approvedIABPIds), invitationDDPs);
        }

        if (!lm.requests.isEmpty()) {
            loopMessageRequestCount = lm.requests.size();
            lm.sendAllRequests();
        }
    }

    private static void addLoopMessageRequestForBudgets(Loop.loopMessage lm, List<EDM_Budget_gne__c> budgets, EDM_IABP_DDPs ddp) {
        Map<String, String> variables = new Map<String, String> { 
                            'deploy' => ddp.getDeliveryOptionId('Output')};

         for (EDM_Budget_gne__c budget : budgets) {
            lm.requests.add(new Loop.loopMessage.loopMessageRequest(budget.Id, ddp.ddpId, variables));
            System.debug('loopMessage send: budget.Id=' + budget.Id + ', ddpId=' + ddp.ddpId + ', deploy:' + variables.get('deploy'));
        }
    }

    public static void generateAgreements(Set<Id> approvedIABPIds, String sessionId) {
        final String DDP_NAME_AGREEMENT = 'EDM IABP Agreement by Budget';
        final String DDP_NAME_AGREEMENT_PATIENTS  = 'EDM IABP Advisory Board Consulting Agreement - Patients and Patient Advocates';

        EDM_IABP_DDPs agreementDDPs = new EDM_IABP_DDPs(DDP_NAME_AGREEMENT);
        EDM_IABP_DDPs agreementPatientsDDPs = new EDM_IABP_DDPs(DDP_NAME_AGREEMENT_PATIENTS);

        Loop.loopMessage lm = new Loop.loopMessage();
        lm.sessionId = sessionId;
        //lm.batchNotification = Loop.loopMessage.Notification.ON_ERROR; //default is None

        if (agreementDDPs.ddpId != null) {
            addLoopMessageRequestForBudgets(lm, getBudgetsWithoutChairForiAdvise(approvedIABPIds), agreementDDPs);
        }

        if (agreementPatientsDDPs.ddpId != null) {
            addLoopMessageRequestForBudgets(lm, getBudgetsForPatient(approvedIABPIds), agreementPatientsDDPs);
        }

        if (!lm.requests.isEmpty()) {
            loopMessageRequestCount = lm.requests.size();
            lm.sendAllRequests();
        }
    }

    private static List<EDM_Budget_gne__c> getBudgetsWithoutChairForiAdvise(Set<Id> approvedIABPIds) {
        List<EDM_Budget_gne__c> results = new List<EDM_Budget_gne__c>();
        List<EDM_Budget_gne__c> budgets = getBudgets(approvedIABPIds);

        Map<Id, EDM_IABP_gne__c> iabps = new Map<Id, EDM_IABP_gne__c> ([
                SELECT Id, EDM_Type_for_Doc_gne__c 
                FROM EDM_IABP_gne__c
                WHERE Id in :approvedIABPIds]);

        for (EDM_Budget_gne__c budget : budgets) {
            if (budget.EDM_Type_gne__c == EDM_TYPE_CHAIR && 
                    iabps.get(budget.EDM_Parent_IABP_gne__c).EDM_Type_for_Doc_gne__c == EDM_TYPE_IADVISE) {
                continue;
            }
            results.add(budget);
        }

        return results;
    }

    private static List<EDM_Budget_gne__c> getBudgets(Set<Id> approvedIABPIds) {
        Set<String> budgetTypes = new Set<String> {EDM_TYPE_MODERATOR, EDM_TYPE_CLINICAL_EXPERT, EDM_TYPE_CHAIR, EDM_TYPE_ADVISOR};

        return [SELECT ID, EDM_Type_gne__c, EDM_Parent_IABP_gne__c 
                    FROM EDM_Budget_gne__c 
                    WHERE EDM_Parent_IABP_gne__c = :approvedIABPIds AND                        
                        EDM_Type_gne__c in :budgetTypes];
    }

    private static List<EDM_Budget_gne__c> getBudgetsForPatient(Set<Id> approvedIABPIds) {
        Set<String> budgetTypes = new Set<String> {BUDGET_TYPE_PATIENT_ADVISOR};

        return [SELECT ID, EDM_Type_gne__c, EDM_Parent_IABP_gne__c 
                    FROM EDM_Budget_gne__c 
                    WHERE EDM_Parent_IABP_gne__c = :approvedIABPIds AND                        
                        EDM_Type_gne__c in :budgetTypes];
    }


    private static void updateDutiesOnBudgetsBeforeFutureCall(Set<Id> approvedIABPIds) {
        List<EDM_Budget_gne__c> budgets = getBudgetsWithDuties(approvedIABPIds);
        List<EDM_Budget_gne__c> budgetsToUpdate = new List<EDM_Budget_gne__c>();

        for (EDM_Budget_gne__c budget : budgets) {
            if (budget.EDM_Type_gne__c == EDM_TYPE_MODERATOR) {
                if (budget.EDM_Drawloop_Duties_gne__c != budget.EDM_Parent_IABP_gne__r.EDM_Moderator_Selection_Duties_gne__c) {
                    budget.EDM_Drawloop_Duties_gne__c = budget.EDM_Parent_IABP_gne__r.EDM_Moderator_Selection_Duties_gne__c;
                    budgetsToUpdate.add(budget);
                }
            } else if (budget.EDM_Type_gne__c == EDM_TYPE_CHAIR) {
                if (budget.EDM_Drawloop_Duties_gne__c != budget.EDM_Parent_IABP_gne__r.EDM_Chair_Selection_Duties_gne__c) {
                    budget.EDM_Drawloop_Duties_gne__c = budget.EDM_Parent_IABP_gne__r.EDM_Chair_Selection_Duties_gne__c;
                    budgetsToUpdate.add(budget);
                }
            } else if (budget.EDM_Type_gne__c == EDM_TYPE_CLINICAL_EXPERT) {
                if (budget.EDM_Drawloop_Duties_gne__c != budget.EDM_Parent_IABP_gne__r.EDM_Cl_Expert_Selection_Duties_gne__c) {
                    budget.EDM_Drawloop_Duties_gne__c = budget.EDM_Parent_IABP_gne__r.EDM_Cl_Expert_Selection_Duties_gne__c;
                    budgetsToUpdate.add(budget);
                }
            } else {
                if (budget.EDM_Drawloop_Duties_gne__c != null) {
                    budget.EDM_Drawloop_Duties_gne__c = null;
                    budgetsToUpdate.add(budget);
                }
            }
        }

        if (!budgetsToUpdate.isEmpty()) {
            update budgetsToUpdate;
        }
    }

    private static List<EDM_Budget_gne__c> getBudgetsWithDuties(Set<Id> approvedIABPIds) {
        Set<String> budgetTypes = new Set<String> {EDM_TYPE_MODERATOR, EDM_TYPE_CLINICAL_EXPERT, EDM_TYPE_CHAIR, EDM_TYPE_ADVISOR};

        return [SELECT ID, EDM_Type_gne__c, EDM_Parent_IABP_gne__c, EDM_Drawloop_Duties_gne__c,
                    EDM_Parent_IABP_gne__r.EDM_Moderator_Selection_Duties_gne__c,
                    EDM_Parent_IABP_gne__r.EDM_Chair_Selection_Duties_gne__c,
                    EDM_Parent_IABP_gne__r.EDM_Cl_Expert_Selection_Duties_gne__c
                                            FROM EDM_Budget_gne__c 
                                            WHERE EDM_Parent_IABP_gne__c = :approvedIABPIds AND                                               
                                                EDM_Type_gne__c in :budgetTypes];
    }

    private class EDM_IABP_DDPs {
        public Id ddpId {get; private set;}
        private Map<String, Id> deliveryOptions;

        public EDM_IABP_DDPs (String ddpName) {
            List<Loop__DDP__c> ddps = [
                    SELECT Id, (SELECT Id, Name FROM Loop__Custom_Integration_Options__r)
                    FROM Loop__DDP__c 
                    WHERE Name = :ddpName];
            if (!ddps.isEmpty()) {
                ddpId  = ddps.get(0).Id;
                deliveryOptions = new Map<String, Id>();
                for (Loop__DDP_Integration_Option__c deliveryOption : ddps.get(0).Loop__Custom_Integration_Options__r) {
                    deliveryOptions.put(deliveryOption.Name.toUpperCase(), deliveryOption.Id);
                }
            }
        }

        public Id getDeliveryOptionId(String name) {
            return deliveryOptions.get(name.toUpperCase());
        }
    }

    public static void reparentAttachmentsToEDMAttachments(List<Attachment> attachments) {
        List<EDM_Attachment_gne__c> edmAttachments = new List<EDM_Attachment_gne__c>();

        //double check if other type of attachments was passed
        List<Attachment> attachmentsIABP = filterAttachmentsBy(attachments, EDM_IABP_gne__c.SobjectType);

        List<Attachment> attachmentsBudget = filterAttachmentsBy(attachments, EDM_Budget_gne__c.SobjectType);

        if (!attachmentsBudget.isEmpty()) {
            Set<Id> budgetIds = new Set<Id>();
            for (Attachment att : attachmentsBudget) {
                budgetIds.add(att.parentId);
            }
            Map<Id, EDM_Budget_gne__c> budgets = new Map<Id, EDM_Budget_gne__c>([SELECT Id, EDM_Parent_IABP_gne__c, EDM_Description_gne__c FROM EDM_Budget_gne__c WHERE Id in :budgetIds]);
            for (Attachment att : attachmentsBudget) {
                att.Description = budgets.get(att.parentId).EDM_Description_gne__c;
                att.parentId = budgets.get(att.parentId).EDM_Parent_IABP_gne__c;                
            }

            attachmentsIABP.addAll(attachmentsBudget);
        }


        for (Attachment att : attachmentsIABP) {
            String type = getTypeOfSystemGeneratedDocument(att.Name);
            edmAttachments.add(new EDM_Attachment_gne__c(
                    EDM_Parent_IABP_gne__c = att.ParentId,
                    Name = att.Name,
                    EDM_Document_Name_gne__c = att.Name,
                    EDM_Description_gne__c = getAttendeeType(att.Name) + (String.isNotEmpty(att.Description) ? ' (' + att.Description + ')' : '') + ', ' + getDollarAmount(att.Name),
                    EDM_Type_gne__c = type,
                    EDM_System_Type_gne__c = EDM_TYPE_SYSTEM_GENERATED));
        }

        if (!edmAttachments.isEmpty()) {
            insert edmAttachments;
            Integer edmAttachIdx = 0;
            for (Attachment att : attachmentsIABP) {
                att.ParentId = edmAttachments.get(edmAttachIdx).Id;
                edmAttachIdx++;
            }
        }
    }

    private static String getAttendeeType(String name) {
        Set<String> types = new Set<String> {EDM_TYPE_MODERATOR, EDM_TYPE_CLINICAL_EXPERT, EDM_TYPE_CHAIR, EDM_TYPE_PATIENT, EDM_TYPE_ADVISOR};
        for (String type : types) {
            if (name.contains(type))
                return type;
        }
        return null;
    }

    private static String getTypeOfSystemGeneratedDocument(String name) {
        Set<String> types = new Set<String> {STANDARD_INVITE, STANDARD_AGREEMENT, IADVISE_INVITE, IADVISE_AGREEMENT};
        for (String type : types) {
            if (name.contains(type))
                return type;
        }

        if (name.contains(DOC_TYPE_AGREEMENT)) {
            return STANDARD_AGREEMENT;
        }

        if (name.contains(DOC_TYPE_INVITE)) {
            return STANDARD_INVITE;
        }

        if (name.contains(EDM_TYPE_PATIENT)) {
            return STANDARD_AGREEMENT;
        }

        return null;
    }

    private static String getDollarAmount(String name) {
        return name.substringAfterLast(' ').substringBefore('.docx');
    }


    public static List<Attachment> filterAttachmentsBy(List<Attachment> attachments, Schema.sObjectType sObjType) {
        return filterAttachmentsBy(attachments, new Set<Schema.sObjectType> {sObjType});
    }

    public static List<Attachment> filterAttachmentsBy(List<Attachment> attachments, Set<Schema.sObjectType> sObjTypes) {
        List<Attachment> attachmentsFiltered = new List<Attachment>();
        for (Attachment att : attachments) {
            if (att.ParentId != null && sObjTypes.contains(att.ParentId.getSobjectType())) {
                attachmentsFiltered.add(att);
             }
        }
        return attachmentsFiltered;
    }

    public static void updateEDMAttachmentLinks(List<Attachment> attachments) {
        Map<Id, Attachment> attachmentsByEdmAttachmentIds = new Map<Id, Attachment>();

        //double check if other type of attachments was passed
        List<Attachment> attachmentsEDM = filterAttachmentsBy(attachments, EDM_Attachment_gne__c.SobjectType);

        for (Attachment att : attachmentsEDM) {
            attachmentsByEdmAttachmentIds.put(att.ParentId, att);
        }

        if (!attachmentsEDM.isEmpty()) {
            Set<Id> edmAttachmentIds = attachmentsByEdmAttachmentIds.keySet();
            List<EDM_Attachment_gne__c> edmAttachments = [SELECT Id, EDM_Link_gne__c FROM EDM_Attachment_gne__c WHERE Id in :edmAttachmentIds];
            for (EDM_Attachment_gne__c edmAttachment : edmAttachments) {
                edmAttachment.EDM_Link_gne__c = prepareLinkToAttachmentInTriggerContext(attachmentsByEdmAttachmentIds.get(edmAttachment.Id));
            }

            update edmAttachments;
        }
    }

    public static String prepareLinkToAttachmentInTriggerContext(Attachment attach) {
        String viewURL = '/servlet/servlet.FileDownload?file=';
        return viewURL + attach.Id;
    }

    public static void sendNotificationsWhenAllSystemGeneretedDocumentsReady(List<Attachment> attachments) {
        Map<Id, List<EDM_Attachment_gne__c>> iabpIdsWithAllSystemGeneretedDocumentsReady = getIABPSWithAllSystemGeneretedDocumentsReady(attachments);
        
        if (!iabpIdsWithAllSystemGeneretedDocumentsReady.isEmpty()) {
            EDM_ABM_Email_Notifications.sendNotificationsForApprovedIABP(iabpIdsWithAllSystemGeneretedDocumentsReady);
        }
    }

    private static Map<Id, List<EDM_Attachment_gne__c>> getIABPSWithAllSystemGeneretedDocumentsReady(List<Attachment> attachments) {
        Map<Id, Attachment> attachmentsByEdmAttachmentIds = new Map<Id, Attachment>();
        Set<Id> iabpIds = new Set<Id>();
        Map<Id, List<EDM_Attachment_gne__c>> readyIABPIdsWithEDMAttachments = new Map<Id, List<EDM_Attachment_gne__c>>();

        //double check if other type of attachments was passed
        List<Attachment> attachmentsEDM = filterAttachmentsBy(attachments, EDM_Attachment_gne__c.SobjectType);

        for (Attachment att : attachmentsEDM) {
            attachmentsByEdmAttachmentIds.put(att.ParentId, att);
        }

        if (!attachmentsEDM.isEmpty()) {
            Set<Id> edmAttachmentIds = attachmentsByEdmAttachmentIds.keySet();
            List<EDM_Attachment_gne__c> edmSystemGeneratedAttachments = [SELECT Id, EDM_Parent_IABP_gne__c FROM EDM_Attachment_gne__c WHERE Id in :edmAttachmentIds and EDM_System_Type_gne__c =: EDM_TYPE_SYSTEM_GENERATED];
            
            for (EDM_Attachment_gne__c edmAttach : edmSystemGeneratedAttachments) {
                iabpIds.add(edmAttach.EDM_Parent_IABP_gne__c);
            }

        }

        if (!iabpIds.isEmpty()) {
            //Map<Id, Set<String>> participantTypesByIABP = getParticipantTypesByIABP(iabpIds);
            //Map<Id, List<EDM_Attachment_gne__c>> edmAttachmentSysGenByIABP = getEDMAttachmentSysGenByIABP(iabpIds);

            //for (Id iabpId : iabpIds) {
            //    List<EDM_Attachment_gne__c> edmAttachments = edmAttachmentSysGenByIABP.get(iabpId);
            //    if (edmAttachments != null && edmAttachments.size() == getExpectedNumberOfSystemGeneratedDocuments(iabpId, participantTypesByIABP)) {
            //        System.debug('LIMIT HIT');
            //        readyIABPIdsWithEDMAttachments.put(iabpId, edmAttachments);
            //    } else {
            //        System.debug('NOT YET');
            //    }
            //}
        }

        return readyIABPIdsWithEDMAttachments;
    }

    private static Map<Id, List<EDM_Attachment_gne__c>> getEDMAttachmentSysGenByIABP(Set<Id> approvedIABPIds) {
        Map<Id, List<EDM_Attachment_gne__c>> edmAttachmentSysGenByIABP = new Map<Id, List<EDM_Attachment_gne__c>>();

        for (EDM_Attachment_gne__c edmAttach : [SELECT Id, EDM_Parent_IABP_gne__c FROM EDM_Attachment_gne__c WHERE EDM_Parent_IABP_gne__c in :approvedIABPIds and EDM_System_Type_gne__c =: EDM_TYPE_SYSTEM_GENERATED ]) {
            if (edmAttachmentSysGenByIABP.get(edmAttach.EDM_Parent_IABP_gne__c) == null) {
                edmAttachmentSysGenByIABP.put(edmAttach.EDM_Parent_IABP_gne__c, new List<EDM_Attachment_gne__c> {edmAttach});
            } else {
                edmAttachmentSysGenByIABP.get(edmAttach.EDM_Parent_IABP_gne__c).add(edmAttach);
            }
        }

        return edmAttachmentSysGenByIABP;
    }


    public static Integer getExpectedNumberOfSystemGeneratedDocuments(Id iabpId) {
        Set<Id> iabpIds = new Set<Id> {iabpId};
        Integer expectedNumberOfAgreements = getBudgetsWithoutChairForiAdvise(iabpIds).size() + getBudgetsForPatient(iabpIds).size();
        Integer expectedNumberOfInvitations= getBudgets(iabpIds).size() + getBudgetsForPatient(iabpIds).size();
        
        return NUMBER_OF_NOT_CUSTOMIZED_DOCUMENTS + expectedNumberOfAgreements + expectedNumberOfInvitations;
    }

    public static Integer getActualNumberOfSystemGeneratedDocuments(Id iabpId) {
        return [SELECT Count() 
                FROM EDM_Attachment_gne__c 
                WHERE EDM_Parent_IABP_gne__c = :iabpId AND EDM_System_Type_gne__c =: EDM_TYPE_SYSTEM_GENERATED];
    }
}