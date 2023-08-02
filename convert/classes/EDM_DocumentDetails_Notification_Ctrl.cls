public without sharing class EDM_DocumentDetails_Notification_Ctrl {
    public Id eventID {get;set;}

    public EDM_DocumentDetails_Notification_Ctrl() {}

    public List<EDM_Attachment_gne__c> getEventAttachments() {
        return [
                SELECT Id, EDM_Type_gne__c, EDM_Description_gne__c, IsDeleted, LastModifiedDate
                FROM EDM_Attachment_gne__c
                WHERE EDM_Parent_IABP_gne__c = :eventID AND
                EDM_Parent_IABP_gne__r.EDM_Historical_gne__c = false AND
                (CreatedDate = YESTERDAY OR (LastModifiedDate = YESTERDAY AND IsDeleted = true)) AND
                EDM_Parent_IABP_gne__c != null
                AND EDM_System_Type_gne__c = 'Event Document'
                order by LastModifiedDate ASC
                ALL ROWS
                ];
    }

}