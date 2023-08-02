public without sharing class EMS_Attendee_Field_Updates {

    /*
    when duplicating events and changing the sub-type the FMV values should be removed. 
    When duplicating without changing the sub-type, then FMV values should be preserved.
    */
    public static void onBeforeUpdate(Map<Id, EMS_Attendee_gne__c> oldAttendees, Map<Id, EMS_Attendee_gne__c> newAttendees) {
        clearFMVOnRoleStatusChange(oldAttendees, newAttendees);
    }

    public static void onBeforeInsert(List<EMS_Event__c> newAttendees) {

    }

    private static void clearFMVOnRoleStatusChange(Map<Id, EMS_Attendee_gne__c> oldAttendees, Map<Id, EMS_Attendee_gne__c> newAttendees) {
        for (EMS_Attendee_gne__c attendeeNew : newAttendees.values()) {
            // clear FMV on role change
            String oldRole = oldAttendees.get(attendeeNew.Id).Role_gne__c;
            String newRole = attendeeNew.Role_gne__c;
            if (oldRole != null && oldRole != newRole) {
                clearAttendeeFieldsValues(attendeeNew);
            }
        }
    }

    public static void clearAttendeeFieldsValues(EMS_Attendee_gne__c attendee) {
        attendee.Preparation_Time_1_gne__c = null;
        attendee.Preparation_Time_2_gne__c = null;
        attendee.Preparation_Time_3_gne__c = null;
        attendee.Preparation_Time_4_gne__c = null;
        attendee.Preparation_Time_5_gne__c = null;
        attendee.Preparation_Time_6_gne__c = null;
        attendee.Talk_Prep_Amount_gne__c = null;
        attendee.Prep_Amount_gne__c = null;
        attendee.Prep_Time_gne__c = null;

        attendee.Activity_Time_gne__c = null;
        attendee.Activity_Time_1_gne__c = null;
        attendee.Activity_Time_2_gne__c = null;
        attendee.Activity_Time_3_gne__c = null;
        attendee.Activity_Time_4_gne__c = null;
        attendee.Activity_Time_5_gne__c = null;
        attendee.Activity_Time_6_gne__c = null;
        attendee.Activity_Amount_gne__c = null;

        attendee.Topic_and_Intent_1_gne__c = null;
        attendee.Topic_and_Intent_2_gne__c = null;
        attendee.Topic_and_Intent_3_gne__c = null;
        attendee.Topic_and_Intent_4_gne__c = null;
        attendee.Topic_and_Intent_5_gne__c = null;
        attendee.Topic_and_Intent_6_gne__c = null;
        attendee.Topic_and_Intent_gne__c = null;

        attendee.Disturbance_Fee__c = null;
        attendee.Disturbance_Fee_Amount_gne__c = null;

        attendee.km_gne__c = null;
        attendee.Type_of_HCP_other_gne__c = null;
        attendee.HCP_hourly_rate_table_gne__c = null;
        attendee.Hourly_Rate_of_HCP_gne__c = null;
        attendee.Type_of_HCP_gne__c = null;
        attendee.Total_Honoraria_gne__c = null;

        attendee.Address_gne__c = null;
        attendee.Email_address_gne__c = null;
        attendee.Event_End_Time_gne__c = null;
        attendee.Event_Start_Time_gne__c = null;
        attendee.Name_and_email_of_the_contact_person_gne__c = null;
        attendee.Payable_To_Name_gne__c = null;
        attendee.Preferred_way_to_contact_the_speaker_gne__c = null;
        attendee.Special_Request_additional_inf_gne__c = null;
        attendee.Telephone_number_gne__c = null;
    }
}