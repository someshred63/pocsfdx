@RestResource(urlMapping='/OTR/manageFieldRosters/*')
global class iPhone_Manage_Field_Rosters {
    public enum ReqType {FETCH, MANAGE}
    @HttpPost
     global static iPhone_Commons_gne.RestResponse processPostRequest( ManageFieldRosterRequest request) {
        return iPhone_Commons_gne.buildResponse(
                new ManageFieldRosterResponseBuilder(),
                new RequestArgs(request)
        );
    }
    
    @HttpGet
     global static iPhone_Commons_gne.RestResponse processGetRequest() {
        return iPhone_Commons_gne.buildResponse(
            new ManageFieldRosterResponseBuilder(),
            new RequestArgs()
        );
    }
    
    class ManageFieldRosterResponseBuilder implements iPhone_Commons_gne.ResponseBuilder {
        public iPhone_Commons_gne.RestResponse build(Object args) {
            RequestArgs reqArgs = (RequestArgs)args;
            if(reqArgs.rType == ReqType.MANAGE) {
                Set<Id> toRemove = new Set<Id>();
                Set<Id> toUpsert = new Set<Id>();
                Map<String, OTR_Field_Roster_gne__c> rid2Record = new  Map<String, OTR_Field_Roster_gne__c>();
                for(RecordWrapper wr :reqArgs.records) {
                    OTR_Field_Roster_gne__c rec = createFieldRosterEntry(wr);
                    rid2Record.put(wr.rid, rec);
                }
                delete [SELECT Id  FROM OTR_Field_Roster_gne__c WHERE User_gne__c = :UserInfo.getUserId() AND iPhone_Request_Id_gne__c NOT IN : rid2Record.keySet() ];
                
                Database.upsert(rid2Record.values(), OTR_Field_Roster_gne__c.iPhone_Request_Id_gne__c);
            }
            
            return new DeltaRecordsResponse([
                SELECT iPhone_Request_Id_gne__c, Order_gne__c, Name, UnixIds_gne__c, User_gne__c
                FROM OTR_Field_Roster_gne__c 
                WHERE User_gne__c = :UserInfo.getUserId() 
            ]);                        
        }
        
        private OTR_Field_Roster_gne__c createFieldRosterEntry(RecordWrapper wr) {
            OTR_Field_Roster_gne__c record = new OTR_Field_Roster_gne__c();
            record.iPhone_Request_Id_gne__c = wr.rid;
            record.User_gne__c = UserInfo.getUserId();
            record.UnixIds_gne__c = wr.ids;
            record.Name = wr.name;
            record.Order_gne__c = wr.order;
            
            return record;
        }
    }
    
    global class ManageFieldRosterRequest {
        public List<RecordWrapper> rosters;
    }
    
    private virtual class RecordWrapper {
        private String id;
        private String rid; //iPhone_Request_Id_gne__c
        private Integer order; //Order_gne__c
        private String ids; //UnixIds_gne__c
        private String userId; //User_gne__c
        private String name; //Name
    }    
    
    public class DeltaRecordsResponse extends iPhone_Commons_gne.RestResponse {
        public List<OTR_Field_Roster_gne__c> records;
        public DeltaRecordsResponse(List<OTR_Field_Roster_gne__c> records) {
            this.records = records;           
        }
        public DeltaRecordsResponse(Exception ex) {
            this.setErrorStatus(ex);
        }
    }
    
    public class RequestArgs extends iPhone_Commons_gne.DeltaArgs {
        public List<RecordWrapper> records;
        public ReqType rType;
        public RequestArgs(ManageFieldRosterRequest request) {
            super(null, getUnixId(UserInfo.getUserId()), null, null, null);
            this.records = request.rosters;
            this.rType = ReqType.MANAGE;
        }
        public RequestArgs(){
            super(null, getUnixId(UserInfo.getUserId()), null, null, null);            
            this.rType = ReqType.FETCH;
        }
    } 
    
    private static String getUnixId(String userId) {
        return [SELECT External_Id_gne__c FROM User WHERE Id = :userId LIMIT 1].External_Id_gne__c;
    }
}