public without sharing class EMS_Email_EventAttTable_Ctrl {
    public Id eventId { get; set; }

    public EMS_Email_EventAttTable_Ctrl() {

    }

    public List<Attendee> getAttendeeList() {
        List<Attendee> attendees = new List<Attendee>();

        List<EMS_Attendee_gne__c> ems_attendees = [
                SELECT Account_gne__r.Name, Role_gne__c, Status_gne__c, Contract_gne__c, EMS_International_Speaker_gne__r.Name
                FROM EMS_Attendee_gne__c
                WHERE (Account_gne__c != null OR EMS_International_Speaker_gne__c != null)
                AND EMS_Event_gne__c = :eventId
        ];
        for (EMS_Attendee_gne__c ems_a : ems_attendees) {
            if (ems_a.Account_gne__c != null) {
                attendees.add(new Attendee(
                        ems_a.Account_gne__r.Name,
                        ems_a.Role_gne__c,
                        ems_a.Status_gne__c,
                        ems_a.Contract_gne__c,
                        'HCP'
                ));
            }

            if (ems_a.EMS_International_Speaker_gne__c != null) {
                attendees.add(new Attendee(
                        ems_a.EMS_International_Speaker_gne__r.Name,
                        ems_a.Role_gne__c,
                        ems_a.Status_gne__c,
                        ems_a.Contract_gne__c,
                        'iHCP'
                ));
            }
        }

        return attendees;
    }

    public class Attendee {
        public String name { get; set; }
        public String role { get; set; }
        public String status { get; set; }
        public String contract { get; set; }
        public String type { get; set; } //iHCP or HCP

        public Attendee(String name, String role, String status, String contract, String type) {
            this.name = name;
            this.role = role;
            this.status = status;
            this.contract = contract;
            this.type = type;
        }
    }
}