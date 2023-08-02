public without sharing class EDM_AttendeeDetails_Notification_Ctrl {
    public Id eventID { get; set; }

    public List<EDM_Attendee_History_gne__c> getModifiedAttendeeFields() {
        List<EDM_Attendee_History_gne__c> attendeeHistory = [
                SELECT id, Action__c, ChangedField_gne__c, OldValue_gne__c, NewValue_gne__c, EDM_Attendee_Name_gne__c,
                        LastModifiedBy.Name, CreatedDate
                FROM EDM_Attendee_History_gne__c
                WHERE EDM_Parent_IABP_gne__c = :eventID
                AND CreatedDate = YESTERDAY
        ];

        return attendeeHistory;
    }
}