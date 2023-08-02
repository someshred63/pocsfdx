@RestResource(urlMapping='/S2S/UserList/*')
global without sharing class GNE_SFA2_S2S_RestUserList implements GNE_SFA2_S2S_Interface.RestServiceExecuteInterface {
    private static final String S2S_FEATURE_NAME = 'UserList';
    private static final String ATTRIBUTE_PROFILE_MASK = 'profileMask';
    private static final String S2S_ERROR_MISSING_PROFILE_MASK = 'UserListMissingProfileMask';
    private static final String S2S_ERROR_INVALID_PROFILE_MASK = 'UserListInvalidProfileMask';
    private static final Integer RESPONSE_LIST_LIMIT = 1000;
    
    @HttpGet 
    global static RestResponse processRequest() {
        return (RestResponse)GNE_SFA2_S2S_ServiceEngine.executeRestGetMethod(null, S2S_FEATURE_NAME, new GNE_SFA2_S2S_RestUserList(), RestResponse.class);
    }
    
    public virtual System.Type getSelfClass() {
        return GNE_SFA2_S2S_RestUserList.class;
    }
    
    public void executeRestMethod(GNE_SFA2_S2S_Interface.EngineInterface engine) {
        Map<String,String> params = engine.getParams();
        validateParams(params);
        RestResponse res = (RestResponse)engine.getResponse();
        String profileMask = String.escapeSingleQuotes(params.get(ATTRIBUTE_PROFILE_MASK).replaceAll('\\*','%').trim());
        
        List<User> users = [
            SELECT 
                Id, Alias, External_Id_gne__c, FirstName, LastName, UserName, Name, Email, Phone, Profile.Name, Business_Role_gne__c
            FROM User
            WHERE Profile.Name like :profileMask
                AND IsActive = true
            ORDER BY LastName, FirstName
            LIMIT :(RESPONSE_LIST_LIMIT+1)
        ];
        
        for(User u : users) {
            if(res.getRecords().size()==RESPONSE_LIST_LIMIT) {
                res.setIsMore(true);
            } else {
                res.getRecords().add(new UserWrapper(u));    
            }
        }
    }
    
    private void validateParams(Map<String,String> params) {
        if(params==null || !params.containsKey(ATTRIBUTE_PROFILE_MASK)) {
            throw GNE_SFA2_S2S_Util.createException(S2S_ERROR_MISSING_PROFILE_MASK);
        } else if(params.get(ATTRIBUTE_PROFILE_MASK).trim().replaceAll('\\*', '').length()<3) {
            throw GNE_SFA2_S2S_Util.createException(S2S_ERROR_INVALID_PROFILE_MASK);
        }
    }
    
    global class RestResponse extends GNE_SFA2_S2S_Util.Response {
        private Boolean isMore;
        private List<UserWrapper> records;
        
        public RestResponse() {
            this.isMore = false;
            this.records = (List<UserWrapper>)getRecords();
        }
        
        public override List<GNE_SFA2_S2S_Interface.RecordInterface> getRecords() {
            if(this.records==null) {
                this.records = new List<UserWrapper>();
            }
            
            return this.records;
        }
        
        private void setIsMore(Boolean isMore) {
            this.isMore = isMore;
        }
    }
    
    private class UserWrapper extends GNE_SFA2_S2S_Util.Record {
        protected String unixId;
        protected String userName;
        protected String name;
        protected String firstName;
        protected String lastName;
        protected String email;
        protected String phone;
        protected String profileName;
        protected String role;
        
        private UserWrapper(User u) {
            super(u.Id, null);
            this.unixId = u.External_Id_gne__c;
            this.userName = u.UserName;
            this.firstName = u.FirstName;
            this.lastName = u.LastName;
            this.name = u.Name;
            this.email = u.Email;
            this.phone = u.Phone;
            this.profileName = u.Profile.Name;
            this.role = u.Business_Role_gne__c;
        }
        
    }
}