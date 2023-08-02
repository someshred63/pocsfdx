@RestResource(urlMapping='/iPhoneManageUserPreferences/*')
global with sharing class iPhone_ManageUserPreferences extends GNE_SFA2_UserPreference_Ctrl implements iPhone_Commons_gne.Runnable {
  private transient ManageUserPreferencesRequest request;
  private transient User currentUser;
  private static Map<Id,Id> loserToWinnerMap;
  
  @HttpPost 
  global static iPhone_Commons_gne.RestResponse processRequest(ManageUserPreferencesRequest request) {
    iPhone_ManageUserPreferences engine = new iPhone_ManageUserPreferences();
    return iPhone_Commons_gne.executeAlterData(engine, request);                                                      
  }
  
  global class ManageUserPreferencesRequest implements iPhone_Commons_gne.BaseArgs, iPhoneBase.RequestTestable2 {
    public String unixId;
    public List<UserPreferenceWrapper> records;
    public Boolean gCalNotificationsExcl;
    
    public ManageUserPreferencesRequest(String unixId, List<UserPreferenceWrapper> records) {
        this.unixId = unixId;
        this.records = records;
    }

    public ManageUserPreferencesRequest(String unixId, List<UserPreferenceWrapper> records, Boolean gCalNotificationsExcl) {
      this.unixId = unixId;
      this.records = records;
      this.gCalNotificationsExcl = gCalNotificationsExcl;
    }
    
    public String getIPhoneRequestId(){
      return records!=null && !records.isEmpty() ? records[0].rid : null;
    }
    
    public void testRequest() {
      new iPhone_ManageUserPreferences().run(this);
    }
    
    public System.Type getRequestType() {
        return ManageUserPreferencesRequest.class;
    }
  }
  
  public Object run(Object obj) {
    this.request = (ManageUserPreferencesRequest)obj;
    loserToWinnerMap = getLoserToWinnerMap();
    intRun();
    return buildResponse();
  }
  
  private Map<Id,Id> getLoserToWinnerMap() {
    Map<Id,Id> result = new Map<Id,Id>();
    Set<Id> accIds = new Set<Id>();
    Set<Id> addrIds = new Set<Id>();
    
    for(UserPreferenceWrapper userPrefWrappper : (request.records!=null ? request.records : new List<UserPreferenceWrapper>())) {
      if(userPrefWrappper.active==true && String.isNotBlank(userPrefWrappper.primaryId)) {
        accIds.add((Id)userPrefWrappper.primaryId);
      }
      
      if(userPrefWrappper.active==true && String.isNotBlank(userPrefWrappper.secondaryId)) {
        addrIds.add((Id)userPrefWrappper.secondaryId);
      }
    }
    
    if(!accIds.isEmpty()) {
      List<Account> accs = (new iPhoneBase.WithoutSharingQueryExecutor()).getArchivedLoserAccounts(accIds);
      
      for(Account acc : accs){
        result.put(acc.DCH_Previous_Id_gne__c, acc.DCH_Parent_Id_gne__c);
      }
    }
    
    if(!addrIds.isEmpty()) {
      List<Address_vod__c> objAddr = (new iPhoneBase.WithoutSharingQueryExecutor()).getArchivedLoserAddresses(addrIds);
      
      for(Address_vod__c addr : objAddr){
        result.put(addr.DCH_Previous_Id_gne__c, addr.DCH_Parent_Id_gne__c);
      }
    }

    return result;
  }
  
  private void intRun() {
      User user = getCurrentUser(request.unixId);
      upsertUserPreferences(user.Id, request.records!=null ? request.records : new List<UserPreferenceWrapper>());
      if(request.gCalNotificationsExcl != null) {
          setGCalNotificationsExclusion(user.Id);
      }
  }
  
  private User getCurrentUser(String unixId) {
    if(currentUser==null) {
      currentUser = String.isNotBlank(unixId) ? iPhone_DAO.getUserByExternalId(unixId) : new User(Id = UserInfo.getUserId());
    }
            
    return currentUser;
  }

  private void setGCalNotificationsExclusion(Id userId) {
      List<GNE_Notifications_Exclusion__c> notificationsExcl = [SELECT Id FROM GNE_Notifications_Exclusion__c WHERE SetupOwnerId =: userId];
      if(request.gCalNotificationsExcl == false) {
          if(!notificationsExcl.isEmpty()) {
              delete notificationsExcl;
          }
      } else {
          if(notificationsExcl.isEmpty()) {
              insert new GNE_Notifications_Exclusion__c(SetupOwnerId = userId);
          }
      }
  }
  
  private List<iPhone_Commons_gne.AlterDataResponseItem> buildResponse() {
    List<iPhone_Commons_gne.AlterDataResponseItem> result = new List<iPhone_Commons_gne.AlterDataResponseItem>();
    return result;
  }
  
  private static Id getWinnerId(Id recId) {
    return loserToWinnerMap.containsKey(recId) ? loserToWinnerMap.get(recId): recId;
  }
  
  public class UserPreferenceWrapper extends GNE_SFA2_UserPreference_Ctrl.UserPreferenceWrapper {
    public String rid;
    
    public override User_Preference_gne__c getRecord(Id userId) {
      this.primaryId = String.isNotBlank(this.primaryId) ? getWinnerId((Id)this.primaryId) : null;
      this.secondaryId = String.isNotBlank(this.secondaryId) ? getWinnerId((Id)this.secondaryId) : null;
      return super.getRecord(userId);
    }
  }
}