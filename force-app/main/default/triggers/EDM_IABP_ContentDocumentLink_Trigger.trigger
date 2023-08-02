/**
 * Created by pigulaks on 2022-07-22.
 */

trigger EDM_IABP_ContentDocumentLink_Trigger on ContentDocumentLink (after insert) {
    Set<Id> contentDocIds = new Set<Id>();
    Map<String, String> contDocId2LinkedEntityId = new Map<String, String>();
    for (ContentDocumentLink cdl : Trigger.new) {
        if ((cdl.LinkedEntityId.getSobjectType() == EDM_Budget_gne__c.SObjectType ||
                cdl.LinkedEntityId.getSobjectType() == EDM_IABP_gne__c.SobjectType) && cdl.Visibility == 'InternalUsers')
            contentDocIds.add(cdl.ContentDocumentId);
            contDocId2LinkedEntityId.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
        }

    if (!contentDocIds.isEmpty()) {
        List<ContentVersion> cvs = [
            SELECT PathOnClient, VersionData, Description, OwnerId, ContentDocumentId
            FROM ContentVersion
            WHERE ContentDocumentId IN :contentDocIds];

        List<Attachment> attToInsert = new List<Attachment>();
        for (ContentVersion cv : cvs) {
            if(contentDocIds.contains(cv.ContentDocumentId)) {
                Attachment att = new Attachment();
                att.Body = cv.VersionData;
                att.Name = cv.PathOnClient;
                att.Description = cv.Description;
                att.ParentId = contDocId2LinkedEntityId.get(cv.ContentDocumentId);
                att.isPrivate = false;
                att.ownerId = cv.OwnerId;
                attToInsert.add(att);
            }
        }

        insert attToInsert;
    }
}