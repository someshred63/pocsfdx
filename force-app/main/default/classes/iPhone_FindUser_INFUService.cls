@RestResource(urlMapping='/INFU/findUser/*')
global class iPhone_FindUser_INFUService {
    private final static Integer MAX_RECORD_LIMIT = 50;
    @HttpPost
    global static iPhone_Commons_gne.RestResponse processRequest(String searchText, Integer maxRecordCount) {
        return iPhone_Commons_gne.buildResponse(
            new GetUserResponseBuilder(),
            new RequestArgs(searchText, getUnixId(), maxRecordCount)            
        );
    }
    
    private static String getUnixId() {
        return [SELECT External_Id_gne__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].External_Id_gne__c;
    }
 
    class GetUserResponseBuilder implements iPhone_Commons_gne.ResponseBuilder {
        public iPhone_Commons_gne.RestResponse build(Object args) {
            RequestArgs reqArgs = (RequestArgs)args;
            Integer limitRecord = reqArgs.maxRecordCount != null ? reqArgs.maxRecordCount : MAX_RECORD_LIMIT;
            List<List<SObject>> searchList = [
                FIND :reqArgs.searchTxt
                IN NAME FIELDS
                RETURNING
                All_User_Hierarchy_gne__c (Id, Name, email_id__c, User_External_Id_gne__c WHERE Active_gne__c = TRUE ORDER BY Name LIMIT :limitRecord + 1)
            ];
            List<UserClass> responseResult = new List<UserClass>();
            Map<String, All_User_Hierarchy_gne__c> unixIds = processRecords((List<All_User_Hierarchy_gne__c>) searchList[0]);
            Map<String, User> existingUsers = fechUserMap(unixIds.keySet());
            bulidResponse(responseResult, unixIds, existingUsers);
            RecordsResponse result = new RecordsResponse(responseResult);
            
            return result;
        }
    }
    
    private static void bulidResponse(List<UserClass> responseResult, Map<String, All_User_Hierarchy_gne__c> unixIds, Map<String, User> existingUsers) {
        for(String unixId :unixIds.keySet()) {
            UserClass uc = existingUsers.containsKey(unixId) ? new UserClass(unixIds.get(unixId), existingUsers.get(unixId)) : new UserClass(unixIds.get(unixId));
            responseResult.add(uc);
            
        }
        
    }
    
    private static Map<String, User> fechUserMap(Set<String> unixIds) {
        Map<String, User> existingUsers = new Map<String, User>();
        for(User u: [SELECT Id, External_Id_gne__c FROM User WHERE External_Id_gne__c IN :unixIds]) {
            existingUsers.put(u.External_Id_gne__c, u);
        }
        return existingUsers;
    }
    
    private static Map<String, All_User_Hierarchy_gne__c> processRecords(List<All_User_Hierarchy_gne__c> records) {
        System.debug('size '+records.size());
        Map<String, All_User_Hierarchy_gne__c> result = new Map<String, All_User_Hierarchy_gne__c>();
        for(All_User_Hierarchy_gne__c record:records ) {
            result.put(record.User_External_Id_gne__c, record);
        }
        return result;
    }
    
    public class UserClass {
        public String name;
        public String email;
        public String externalId;
        public String userId;
        
        public UserClass(All_User_Hierarchy_gne__c uh) {
            this.name = uh.Name;
            this.email = uh.email_id__c;
            this.externalId = uh.User_External_Id_gne__c;
        }
        
        public UserClass(All_User_Hierarchy_gne__c uh, User u) {
            this.name = uh.Name;
            this.email = uh.email_id__c;
            this.externalId = uh.User_External_Id_gne__c;
            this.userId = u.Id;
        }
    }
    
    public class RequestArgs extends iPhone_Commons_gne.DeltaArgs {
		private String searchTxt;
        private Integer maxRecordCount;
        public RequestArgs(String searchTxt, String unixId, Integer maxRecordCount) {
            super(null, unixId, null, null, null);
            this.searchTxt = searchTxt;
            this.maxRecordCount = maxRecordCount;
        }               
    } 
    
    public class RecordsResponse extends iPhone_Commons_gne.RestResponse {
        public List<UserClass> usersHierarchy;
        public RecordsResponse(List<UserClass> usersHierarchy) {
            this.usersHierarchy = usersHierarchy;           
        }
    }
}