public without sharing class EMS_Attendee_Email_Notifications {

    private static final EMS_Email_Boxes__c bpsMailbox = EMS_Email_Boxes__c.getValues('BPS');
    private static final EMS_Email_Boxes__c tierExceptionMailbox = EMS_Email_Boxes__c.getValues('Business Ethics');
    private static Set<String> approveStatuses = new Set<String>{
            'Committee Approved',
            'Director / Manager Approved',
            'MAC Committee Approved',
            'Manager Approved',
            'Medical Manager Approved',
            'Awaiting Signature from HCP',
            'Signed Agreement Received',
            'Payment Request Initiated',
            'Approved',
            'Budget Approved'
    };
    private static Set<String> fmvFields = new Set<String>{
            'Preparation_Time_1_gne__c',
            'Preparation_Time_2_gne__c',
            'Preparation_Time_3_gne__c',
            'Preparation_Time_4_gne__c',
            'Preparation_Time_5_gne__c',
            'Preparation_Time_6_gne__c',
            'Talk_Prep_Amount_gne__c',
            'Prep_Amount_gne__c',
            'Prep_Time_gne__c',
            'Activity_Amount_gne__c',
            'Activity_Time_gne__c',
            'Activity_Time_1_gne__c',
            'Activity_Time_2_gne__c',
            'Activity_Time_3_gne__c',
            'Activity_Time_4_gne__c',
            'Activity_Time_5_gne__c',
            'Activity_Time_6_gne__c',
            'Disturbance_Fee__c',
            'Disturbance_Fee_Amount_gne__c',
            'km_gne__c',
            'Type_of_HCP_other_gne__c',
            'HCP_hourly_rate_table_gne__c',
            'Hourly_Rate_of_HCP_gne__c',
            'Type_of_HCP_gne__c',
            'Total_Honoraria_gne__c',
            'Address_gne__c',
            'Email_address_gne__c',
            'Payable_To_Name_gne__c',
            'Preferred_way_to_contact_the_speaker_gne__c',
            'Special_Request_additional_inf_gne__c',
            'Telephone_number_gne__c',
            'Topic_and_Intent_gne__c',
            'Event_End_Time_gne__c',
            'Event_Start_Time_gne__c',
            'Name_and_email_of_the_contact_person_gne__c'
    };

    private static Boolean isFMVChaned(EMS_Attendee_gne__c oldAttendee, EMS_Attendee_gne__c newAttendee) {
        for (String fmvField :fmvFields) {
            try {
                if (oldAttendee.get(fmvField) != newAttendee.get(fmvField)) {
                    return true;
                }
            } catch (System.SObjectException e) {
                System.debug(LoggingLevel.ERROR, '### isFMVChaned \'' + fmvField + '\' FAILED: ' + e.getMessage());
            }
        }
        return false;
    }

    public static void isAfter(Map<Id, EMS_Attendee_gne__c> oldAttendees, Map<Id, EMS_Attendee_gne__c> newAttendees) {
        Set<Id> eventIDsForContracts = new Set<Id>();
        Set<Id> attendeesForExceptionIDs = new Set<Id>();
        for (EMS_Attendee_gne__c attendee_new : newAttendees.values()) {
            String oldContract = oldAttendees.get(attendee_new.Id).Contract_gne__c;
            String newContract = attendee_new.Contract_gne__c;
            
               DateTime oldExceptionRequestDate = oldAttendees.get(attendee_new.Id).Exception_requested_at_gne__c;
               DateTime newExceptionRequestDate = attendee_new.Exception_requested_at_gne__c;

            if (oldContract != newContract || isFMVChaned(oldAttendees.get(attendee_new.Id), attendee_new)) {
                eventIDsForContracts.add(attendee_new.EMS_Event_gne__c);
            }
            
            if(oldExceptionRequestDate != newExceptionRequestDate) {
                attendeesForExceptionIDs.add(attendee_new.Id);
            }
        }
        if (!eventIDsForContracts.isEmpty()) {
            List<EMS_Event__c> events = [SELECT Status_gne__c, Event_Owner_gne__c FROM EMS_Event__c WHERE Id IN:eventIDsForContracts];
    
            List<Messaging.SingleEmailMessage> emailsToBeSent = new List<Messaging.SingleEmailMessage>();
            for (EMS_Event__c event: events) {
                if (approveStatuses.contains(event.Status_gne__c)) {
                    EMS_Email.prepareSingleEmail('EMS_AARC_Notification', event.Id, new List<String>{
                            bpsMailbox.Main_Address__c
                    });
                }
            }
            EMS_Email.send();
        }
        
        if (!attendeesForExceptionIDs.isEmpty()) {
            List<String> mails = getExceptionEmails();
            
            List<Messaging.SingleEmailMessage> emailsToBeSent = new List<Messaging.SingleEmailMessage>();
            for (Id attendee : attendeesForExceptionIDs) {
                EMS_Email.prepareSingleEmail('EMS_Exception_Notification', attendee, mails);
            }
            EMS_Email.send();
        }
    }

    public static List<String> getExceptionEmails() {
        List<String> result = new List<String>();

        if(tierExceptionMailbox != null) {
            result.add(tierExceptionMailbox.Main_Address__c);
        }

        return result;
    }
}