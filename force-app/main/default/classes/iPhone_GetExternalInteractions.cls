@RestResource(urlMapping='/iPhoneGetExternalInteractions/*')
global without sharing class iPhone_GetExternalInteractions {

    private static final List<String> supportedProfiles = new List<String>{
            'GNE Field', 'GNE Medical'
    };
    private static final String EMPLOYEE_TYPE = 'Employee';

    @HttpPost
    global static iPhone_Commons_gne.RestResponse processRequest(String unixId) {
        return iPhone_Commons_gne.buildResponse(
                new ExternalInteractionsResponseBuilder(),
                new iPhone_Commons_gne.DefaultDeltaArgs(null, unixId) // Can't use 'Delta' feature here (Territory object does not have CreatedDate field)
        );
    }

    class ExternalInteractionsResponseBuilder implements iPhone_Commons_gne.ResponseBuilder {

        public iPhone_Commons_gne.RestResponse build(Object args) {
            Map<String, ExternalInteractionRecord> callIdToCall = new Map<String, ExternalInteractionRecord>();
            return new DeltaRecordsResponse(callIdToCall.values());
        }
    }

    class ExternalInteractionRecord extends iPhone_Commons_gne.DeltaRecord {
        public String nm; //name
        public String an; //account name
        public String ai; //account id
        public String ad; //address
        public String du;//duration
        public String ch;//channel
        public String dt;//interaction datetime
        public String st;//interaction status
        public List<CallAttendee> attendees;//interaction attendees
        public List<CallDetail> details;//interaction status
    }

    class CallDetail {
        public String id;
        public String product;
        public String priority;
        public List<CallDiscussion> discussions;
    }

    class CallDiscussion {
        public String id;
        public String topic;
        public String notes;
    }

    class CallAttendee {
        public String id;
        public String ai;
        public String name;
        public String type;
        public String isPersonAccount;
    }

    public class DeltaRecordsResponse extends iPhone_Commons_gne.RestResponse {
        public final List<DeltaRecord> records;

        public DeltaRecordsResponse(List<iPhone_Commons_gne.DeltaRecord> records) {
            this.records = records;
        }
    }
}