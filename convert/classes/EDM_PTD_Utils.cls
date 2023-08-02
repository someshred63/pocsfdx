public with sharing class EDM_PTD_Utils {
    
private static Set<String> TemplateNames = new Set<String> {'Action_Item_Assigned'};
private static Map<String,EmailTemplate> EdmABMTemplates = new Map<String,EmailTemplate>();

static {

    for(EmailTemplate tmpET : [Select id,Name,developername from EmailTemplate where developername IN :TemplateNames]) {
                
                EdmABMTemplates.put(tmpET.developername,tmpET);
    }
}


    public static void onBeforeUpdate(List<EDM_Attachment_gne__c> triggerOld, Map<Id, EDM_Attachment_gne__c> triggerNew) {
        setPTDCompleteStatus(triggerOld, triggerNew);
        resetABSReviewValue(triggerOld, triggerNew);
        sendEmailNotify(triggerOld, triggerNew);
    }

    private static void setPTDCompleteStatus(List<EDM_Attachment_gne__c> triggerOld, Map<Id, EDM_Attachment_gne__c> triggerNew) {
        Set<Id> exeSumIdsToCheck = new Set<Id>();
        Set<Id> ptdCompletedNow = new Set<Id>();
        for (EDM_Attachment_gne__c oldPTD : triggerOld) {
            EDM_Attachment_gne__c newPTD = triggerNew.get(oldPTD.Id);
            if (newPTD.EDM_Complete_gne__c && oldPTD.EDM_Complete_gne__c != newPTD.EDM_Complete_gne__c) {
                exeSumIdsToCheck.add(newPTD.EDM_Parent_IABP_gne__c);
                ptdCompletedNow.add(newPTD.Id);
            }
        }

        if (exeSumIdsToCheck.isEmpty()) {
            return;
        }

        Set<Id> completedExeSumIds = getCompletedExeSumIds(exeSumIdsToCheck, ptdCompletedNow);

        if (!completedExeSumIds.isEmpty()) {
            changeStatusToPTDCompleteForParentOfExeSums(completedExeSumIds);
        }
    }
    private static void sendEmailNotify(List<EDM_Attachment_gne__c> triggerOld, Map<Id, EDM_Attachment_gne__c> triggerNew) {

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (EDM_Attachment_gne__c oldPTD : triggerOld) {
            EDM_Attachment_gne__c newPTD = triggerNew.get(oldPTD.Id);
            if (oldPTD.EDM_Responsible_Party_gne__c != newPTD.EDM_Responsible_Party_gne__c) {
                Messaging.SingleEmailMessage email = EDM_ABM_Utils.prepEmail(newPTD.EDM_Responsible_Party_gne__c,newPTD.EDM_Parent_IABP_gne__c,EdmABMTemplates.get('Action_Item_Assigned').Id,null);
                emails.add(email);
            }
        }

        if(emails.size()>0){
            try{
                Messaging.SendEmailResult[] results = Messaging.sendEmail(emails, false);
            } catch(Exception e) {
                System.debug('Exception: ' + e);
                String errorMessage = e.getMessage()+'\n'+e.getStackTraceString();
                System.debug('Error message: ' + errorMessage);
            }
        }
    }
    private static void resetABSReviewValue(List<EDM_Attachment_gne__c> triggerOld, Map<Id, EDM_Attachment_gne__c> triggerNew) {
        for (EDM_Attachment_gne__c oldPTD : triggerOld) {
            EDM_Attachment_gne__c newPTD = triggerNew.get(oldPTD.Id);
            if (oldPTD.EDM_Pull_Through_Doc_gne__c == true && oldPTD.EDM_Link_gne__c != newPTD.EDM_Link_gne__c) {
                newPTD.EDM_ABS_Review_Status_gne__c = null;
            }
        }
    }
    private static Set<Id> getCompletedExeSumIds(Set<Id> exeSumIdsToCheck, Set<Id> ptdCompletedNow) {
        List<EDM_Attachment_gne__c> inProgressPTDs = [
                SELECT Id, EDM_Parent_IABP_gne__c 
                FROM EDM_Attachment_gne__c
                WHERE EDM_Parent_IABP_gne__c in :exeSumIdsToCheck and
                    Id not in :ptdCompletedNow and
                    EDM_Pull_Through_Doc_gne__c = true and
                    EDM_System_Type_gne__c = null and
                    EDM_Complete_gne__c = false];

        Set<Id> inProgressExeSumIds = new Set<Id>();
        for (EDM_Attachment_gne__c ptd : inProgressPTDs) {
            inProgressExeSumIds.add(ptd.EDM_Parent_IABP_gne__c);
        }

        System.debug('exeSumIdsToCheck = ' + inProgressExeSumIds);
        System.debug('inProgressExeSumIds = ' + inProgressExeSumIds);

        Set<Id> completedExeSumIds = exeSumIdsToCheck.clone();
        if (!inProgressExeSumIds.isEmpty()) {
            completedExeSumIds.removeAll(inProgressExeSumIds);
        }

        return completedExeSumIds;
    }

    private static void changeStatusToPTDCompleteForParentOfExeSums(Set<Id> completedExeSumIds) {
        List<EDM_IABP_gne__c> completedExeSums = [
                SELECT Id, EDM_Parent_IABP_gne__c
                FROM EDM_IABP_gne__c 
                WHERE Id in :completedExeSumIds and 
                    EDM_Parent_IABP_gne__r.EDM_Status_gne__c = 'PTD in Progress'];

        List<EDM_IABP_gne__c> listOfParentIABPs = new List<EDM_IABP_gne__c>();
        for (EDM_IABP_gne__c exesum : completedExeSums) {
            EDM_IABP_gne__c iabp = new EDM_IABP_gne__c(
                    id = exesum.EDM_Parent_IABP_gne__c,
                    EDM_Status_gne__c = 'PTD complete');
            listOfParentIABPs.add(iabp);
        }

        update listOfParentIABPs;
    }
}