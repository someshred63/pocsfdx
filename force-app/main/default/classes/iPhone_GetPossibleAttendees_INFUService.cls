@RestResource(urlMapping='/INFU/GetPossibleAttendees/*')
global class iPhone_GetPossibleAttendees_INFUService {
    private static final String UNIXID = getUnixId();
    @HttpPost
    global static iPhone_Commons_gne.RestResponse processRequest() {
        return iPhone_Commons_gne.buildResponse(
            new GetPossibleAttendeesResponseBuilder(),
            new RequestArgs(UNIXID)            
        );
    }
    
    private static String getUnixId() {
        return [SELECT External_Id_gne__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].External_Id_gne__c;
    }
    
    class GetPossibleAttendeesResponseBuilder implements iPhone_Commons_gne.ResponseBuilder {
        public iPhone_Commons_gne.RestResponse build(Object args) {         
            List<Attendee> possibleAttendees = new List<Attendee>();

            return new RecordsResponse(possibleAttendees);
        }
        
        private iPhoneApex_2.CallAttendee createAttendee(Account acc) {
            iPhoneApex_2.CallAttendee result = new iPhoneApex_2.CallAttendee();
            result.CallAttendeeType = iPhoneApex_2.AttendeeType.PERSONACCOUNT;
            result.Attendee = acc.Id;
            
            return result;
        }
        
    }
    
    public class Attendee {
        public String attendeeId ;
        public String attendeeFirstName ;
        public String attendeeLastName ;
        public String attendeeMiddleName ;
        public String attendeeName ;
        public String attendeeType ;
        public String iAttendeeType;
        
        public Attendee(Account account) {
            this.attendeeId = account.Id;
            this.iAttendeeType = String.valueOf(iPhoneApex_2.AttendeeType.PERSONACCOUNT);
            this.attendeeName = account.Name;
            this.attendeeFirstName = String.isNotEmpty(account.FirstName) ? account.FirstName : '';
            this.attendeeLastName = String.isNotEmpty(account.LastName) ? account.LastName : '';
            this.attendeeMiddleName = String.isNotEmpty(account.Middle_vod__c) ? account.Middle_vod__c : '';
            this.attendeeType = account.RecordType.Name;
        }
    }

    public class RequestArgs extends iPhone_Commons_gne.DeltaArgs {
        public RequestArgs(String unixId) {
            super(null, unixId, null, null, null);
        }               
    } 
    
    public class RecordsResponse extends iPhone_Commons_gne.RestResponse {
        public List<Attendee> possibleAttendees;
        public RecordsResponse(List<Attendee> possibleAttendees) {
            this.possibleAttendees = possibleAttendees;           
        }
    }

}