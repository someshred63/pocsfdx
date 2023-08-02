@RestResource(urlMapping='/iPhoneManageInteraction/*')
global with sharing class iPhone_ManageInteraction extends GNE_SFA2_Interaction_Ctrl implements iPhone_Commons_gne.Runnable {
  private ManageInteractionRequest args;
  private transient Map<Id,Id> loserToWinnerMap;
  
  @HttpPost 
  global static iPhone_Commons_gne.RestResponse processRequest(ManageInteractionRequest request) {
    GNE_SFA2_Interaction_Trigger_Helper.setIsOtrRequest(true);
    return iPhone_Commons_gne.executeAlterData(
      new iPhone_ManageInteraction(), 
      request
    );                                                      
  }
  
  global class ManageInteractionRequest implements iPhone_Commons_gne.BaseArgs, iPhoneBase.RequestTestable2 {
    public String unixId;
    public Boolean isPfgMode;
    public InteractionWrapper record;
    
    public String getIPhoneRequestId(){
      return record!=null ? record.rid : null;
    }
    
    public void testRequest() {
      new iPhone_ManageInteraction().run(this);
    }
    
    public System.Type getRequestType() {
      return ManageInteractionRequest.class;
    }
  }
  
  public Object run(Object obj) {
    this.args = (ManageInteractionRequest)obj;
    this.dataWrapper = getDataWrapperInstance();
    String unixId = this.args.unixId;
    InteractionWrapper recordWrapper = this.args.record;
    this.sObjectType = 'Call2_vod__c';
    Boolean isCompleted = false;
    
    List<Call2_vod__c> calls = String.isNotBlank(recordWrapper.id) ? 
     [SELECT Id, Interaction_Status_gne__c FROM Call2_vod__c WHERE Id = :recordWrapper.id LIMIT 1] :
     String.isNotBlank(recordWrapper.rid) ? 
       [SELECT Id, Interaction_Status_gne__c FROM Call2_vod__c WHERE iPhone_Request_Id_gne__c = :recordWrapper.rid LIMIT 1] :
       new List<Call2_vod__c>();
    
    for(Call2_vod__c call : calls) {
      this.recordId = call.Id;  
      isCompleted = call.Interaction_Status_gne__c == 'Completed';
    }
    
    this.appContext = getAppContext();
    this.recordType = getRecordType(String.isBlank(this.recordId));
    this.loserToWinnerMap = getLoserToWinnerMap(recordWrapper);
    DataWrapper saveData = (DataWrapper)(this.inputDataWrapper = new DataWrapper(this));
    saveData.isCompleted = isCompleted;
    saveData.isSfaBrandUser = this.appContext.currentUser.isSfaBrand();
    this.dataWrapper = intSaveRecord();
    return buildResponse();
  }
  
  protected override GNE_SFA2_Base_Ctrl.DataWrapper getDataWrapperInstance() {
    return new DataWrapper();
  }
  
  private Response buildResponse() {
    Call2_vod__c callAfterSave = (Call2_vod__c)this.recordAfterSave;
    List<ResponseItem> responseItems = new List<ResponseItem>{new ResponseItem(callAfterSave.iPhone_Request_Id_gne__c, callAfterSave.Id, this.sObjectType, callAfterSave.Name)};
    
    if(this.attendeesToUpsert!=null) {
      for(Call2_vod__c att : this.attendeesToUpsert) {
        responseItems.add(new ResponseItem(att.iPhone_Request_Id_gne__c, att.Id, 'Call2_vod__c'));
      }
    }
    
    if(this.detailsToUpsert!=null) {
      for(Call2_Detail_vod__c cd : this.detailsToUpsert) {
        if(cd.Call2_vod__c==this.recordId) {
          responseItems.add(new ResponseItem(cd.iPhone_Request_Id_gne__c, cd.Id, 'Call2_Detail_vod__c'));
        }
      }
    }
    
    if(this.materialsToUpsert!=null) {
      for(Call2_Sample_vod__c cs : this.materialsToUpsert) {
        responseItems.add(new ResponseItem(cs.iPhone_Request_Id_gne__c, cs.Id, 'Call2_Sample_vod__c'));
      }
    }
    
    if(this.pfgDetailsToUpsert!=null) {
      for(Call_PFG_Detail_gne__c pfg : this.pfgDetailsToUpsert) {
        responseItems.add(new ResponseItem(pfg.iPhone_Request_Id_gne__c, pfg.Id, 'Call_PFG_Detail_gne__c'));
      }
    }
    
    return new Response(responseItems);
  }
  
  private GNE_SFA2_Base_Ctrl.UserWrapper getCurrentUser(String unixId) {
    if(currentUser==null) {
      User result = null;
      String profileName = null;
      
      if(String.isNotBlank(this.args.unixId)) {
        for(User u : [SELECT Id, FirstName, LastName, ProfileId, Profile.Name, TimeZoneSidKey FROM User WHERE External_Id_gne__c = :unixId LIMIT 1]) {
          result = u;
          profileName = u.Profile.Name;
        }
      }
      
      if(result==null) {
        result = new User(Id = UserInfo.getUserId(), FirstName = UserInfo.getFirstName(), LastName = UserInfo.getLastName(), ProfileId = UserInfo.getProfileId(), TimeZoneSidKey = String.valueOf(UserInfo.getTimeZone()));
        profileName = GNE_SFA2_Util.getCurrentUserProfileName();
      }
      
      currentUser = new UserWrapper(result);
      currentUser.setProfileName(profileName);
    }
    
    return currentUser;
  }
  
  protected override GNE_SFA2_Base_Ctrl.AppContext getAppContext() {
    if(appContext==null) {
      String appName = 'SFA-US';
      String brand, role;
      currentUser = getCurrentUser(this.args.unixId);
      
      List<SFA2_User_Sales_Roster_gne__c> uRosters = [
        SELECT Role_gne__c, Sales_Roster_gne__r.Brand_Name_gne__c
        FROM SFA2_User_Sales_Roster_gne__c
        WHERE User_gne__c = :currentUser.id 
          AND Sales_Roster_gne__r.Type_gne__c = :appName
          AND Sales_Roster_gne__r.Runs_in_SFA2_Mode_gne__c = true
          AND Is_Active_gne__c = true
        LIMIT 1
      ];
      
      for(SFA2_User_Sales_Roster_gne__c uRoster : uRosters) {
        brand = uRoster.Sales_Roster_gne__r.Brand_Name_gne__c;
        role = uRoster.Role_gne__c;
      }
    
      appContext = new GNE_SFA2_Base_Ctrl.AppContext(currentUser, appName, brand, role, true);
    }
    
    return appContext;
  }
  
  private Map<Id,Id> getLoserToWinnerMap(InteractionWrapper recordWrapper) {
    Map<Id,Id> result = new Map<Id,Id>();
    
    if(String.isNotBlank(recordWrapper.addid)) {
      List<Address_vod__c> objAddr = (new iPhoneBase.WithoutSharingQueryExecutor()).getArchivedLoserAddresses(new Set<Id>{(Id)recordWrapper.addid});
      
      for(Address_vod__c adr : objAddr){
        result.put(adr.DCH_Previous_Id_gne__c, adr.DCH_Parent_Id_gne__c);
      }
    }
    
    Set<Id> accIds = new Set<Id>();
    
    if(String.isNotBlank(recordWrapper.aid)) {
      accIds.add(recordWrapper.aid);
    }
    
    for(AttendeeWrapper attWrapper : (recordWrapper.attendeeRows!=null ? recordWrapper.attendeeRows : new List<AttendeeWrapper>())) {
      Boolean hcpOrUser = attWrapper.type == 'PERSONACCOUNT';
      
      if(hcpOrUser && String.isNotBlank(attWrapper.aid)) {
        accIds.add(attWrapper.aid);
      }
    }
    
    if(!accIds.isEmpty()) {
      List<Account> accs = (new iPhoneBase.WithoutSharingQueryExecutor()).getArchivedLoserAccounts(accIds);
      
      for(Account acc : accs){
        result.put(acc.DCH_Previous_Id_gne__c, acc.DCH_Parent_Id_gne__c);
      }
    }
    
    return result;
  }
  
  private Id getWinnerId(Id recId) {
    return loserToWinnerMap.containsKey(recId) ? loserToWinnerMap.get(recId): recId;
  }
  
  protected override Boolean validateRecord() {
    return true;
  }
  
  protected override void upsertChildRecords() {
    if(detailsToUpsert!=null) {
        Integer idx = 0;
        for(Call2_Detail_vod__c cd : detailsToUpsert) {
            if(cd.Call2_vod__c==this.recordId) {
          DetailWrapper cdw = this.args.record.detailRows[idx++];
          cd.iPhone_Request_Id_gne__c = cdw.rid;
            }
        }
    }
    
    GNE_SFA2_PFG_CPD_Trigger_Helper.setIsOtrRequest(true);
    super.upsertChildRecords();
    GNE_SFA2_PFG_CPD_Trigger_Helper.setIsOtrRequest(false);
  }
  
  private class DataWrapper extends GNE_SFA2_Interaction_Ctrl.DataWrapper {
    
    private DataWrapper() {}
    
    private DataWrapper(iPhone_ManageInteraction engine) {
      this.appContext = engine.appContext;
      InteractionWrapper recordWrapper = engine.args.record;
      Schema.DescribeSObjectResult sObjectDescribe = Call2_vod__c.sObjectType.getDescribe();
      String sObjectType = sObjectDescribe.getName();
      Map<String, Schema.SObjectField> objectFields = sObjectDescribe.fields.getMap();
      this.recordDescribe = new GNE_SFA2_Base_Ctrl.RecordDescribe(engine.recordId, null, sObjectType, null, engine.recordType, new RecordAccess(true, true, true));
      this.config = new GNE_SFA2_Base_Ctrl.Config(String.isBlank(engine.recordId) ? 'New' : 'Edit', null, null, null);
      this.config.fieldsToRefresh = new Map<String,GNE_SFA2_Base_Ctrl.Field>();
      this.completeMode = recordWrapper.isComplete==true;
      
      this.callAccount = new GNE_SFA2_Interaction_Ctrl.AccountWrapper(new Account(Id = engine.getWinnerId(recordWrapper.aid)));
      this.addresses = new List<GNE_SFA2_Interaction_Ctrl.AddressWrapper>();
      
      if(String.isNotBlank(recordWrapper.addid)) {
        List<Address_vod__c> addrs = [
          SELECT Id, Name, Address_line_2_vod__c, City_vod__c, State_vod__c, Zip_vod__c, Zip_4_vod__c, Province_can_gne__c, Postal_Code_can_gne__c,
            PFG_BDTD_gne__c, PFG_BDTD_calc_gne__c, Location_gne__Latitude__s, Location_gne__Longitude__s
          FROM Address_vod__c
          WHERE Id = :engine.getWinnerId(recordWrapper.addid)
          LIMIT 1
        ];
        
        for(Address_vod__c addr : addrs) {
            this.addresses.add(new GNE_SFA2_Interaction_Ctrl.AddressWrapper(addr));
        }
      }
      
      this.inputFields = new List<GNE_SFA2_Base_Ctrl.Field>();
      addInputField(this.inputFields, recordWrapper.rid, String.valueOf(Call2_vod__c.iPhone_Request_Id_gne__c), sObjectType, objectFields);
      addInputField(this.inputFields, engine.getWinnerId(recordWrapper.addid), String.valueOf(Call2_vod__c.Parent_Address_vod__c), sObjectType, objectFields);
      addInputField(this.inputFields, getTime(recordWrapper.dTime), String.valueOf(Call2_vod__c.Call_Datetime_vod__c), sObjectType, objectFields);
      addOptionalInputField(this.inputFields, recordWrapper.type, String.valueOf(Call2_vod__c.Interaction_Type_gne__c), sObjectType, objectFields);
      addInputField(this.inputFields, 'Person_Account_vod', String.valueOf(Call2_vod__c.Attendee_Type_vod__c), sObjectType, objectFields);
      addInputField(this.inputFields, 'Detail Only', String.valueOf(Call2_vod__c.Call_Type_vod__c), sObjectType, objectFields);
      addInputField(this.inputFields, recordWrapper.terrName, String.valueOf(Call2_vod__c.Territory_vod__c), sObjectType, objectFields);
      addInputField(this.inputFields, recordWrapper.terrId, String.valueOf(Call2_vod__c.Territory_Id_gne__c), sObjectType, objectFields);
      if(iPhoneBase.validateCoordinates(recordWrapper.latitude, recordWrapper.longitude, iPhone_ManageInteraction.class, 'Record Interaction', 'OTR', recordWrapper.rid )){
          addInputField(this.inputFields, recordWrapper.latitude, String.valueOf(Call2_vod__c.Geolocation_gne__Latitude__s), sObjectType, objectFields);
          addInputField(this.inputFields, recordWrapper.longitude, String.valueOf(Call2_vod__c.Geolocation_gne__Longitude__s), sObjectType, objectFields);            
      }
      
      Boolean mealEnabled = 
        recordWrapper.mooPlannedAttendees!=null && recordWrapper.mooPlannedAttendees>0 &&
        recordWrapper.mooActualAttendees!=null && recordWrapper.mooActualAttendees>0;
      
      addInputField(this.inputFields, mealEnabled, String.valueOf(Call2_vod__c.Meal_Expense_gne__c), sObjectType, objectFields);
      addInputField(this.inputFields, 0.0, String.valueOf(Call2_vod__c.Meal_Amount_gne__c), sObjectType, objectFields);
      addInputField(this.inputFields, recordWrapper.moo, String.valueOf(Call2_vod__c.HCP_Account_Meal_Opt_Out_gne__c), sObjectType, objectFields);
      addInputField(this.inputFields, mealEnabled ? recordWrapper.mooPlannedAttendees : 0, String.valueOf(Call2_vod__c.Planned_Attendees_gne__c), sObjectType, objectFields);
      addInputField(this.inputFields, mealEnabled ? recordWrapper.mooActualAttendees : 0, String.valueOf(Call2_vod__c.Actual_Attendees_gne__c), sObjectType, objectFields);
      
      //PFG Signatures
      addInputField(this.inputFields, recordWrapper.reqSig, String.valueOf(Call2_vod__c.Request_Signature_gne__c), sObjectType, objectFields);
      addInputField(this.inputFields, getTime(recordWrapper.reqSigDate), String.valueOf(Call2_vod__c.Request_Signature_Date_gne__c), sObjectType, objectFields);
      addInputField(this.inputFields, recordWrapper.sig, String.valueOf(Call2_vod__c.Signature_vod__c), sObjectType, objectFields);
      addInputField(this.inputFields, getTime(recordWrapper.sigDate), String.valueOf(Call2_vod__c.Signature_Date_vod__c), sObjectType, objectFields);
      addInputField(this.inputFields, recordWrapper.licenseNumber, String.valueOf(Call2_vod__c.License_vod__c), sObjectType, objectFields);
      addInputField(this.inputFields, recordWrapper.disclaimer, String.valueOf(Call2_vod__c.Disclaimer_vod__c), sObjectType, objectFields);
      addInputField(this.inputFields, recordWrapper.hcpSpec, String.valueOf(Call2_vod__c.HCP_Specialty_gne__c), sObjectType, objectFields);
      addInputField(this.inputFields, recordWrapper.prepStatus, String.valueOf(Call2_vod__c.PREP_Status_gne__c), sObjectType, objectFields);
      
      prepareAttendeeData(recordWrapper, engine, objectFields);
      prepareProductData(recordWrapper, engine);
      prepareSampleData(recordWrapper, engine);
      
      if(engine.args.isPfgMode==true) {
        preparePfgData(recordWrapper);
      }
    }
    
    private GNE_SFA2_Base_Ctrl.Field addInputField(List<GNE_SFA2_Base_Ctrl.Field> fieldsList, Object value, String fieldName, String sObjectType, Map<String, Schema.SObjectField> objectFields) {
      GNE_SFA2_Base_Ctrl.Field fld = null;
      
      if(value!=null && (!(value instanceof String) || String.isNotBlank((String)value))) {
        fieldsList.add(fld = new GNE_SFA2_Base_Ctrl.Field(null, value, false, false, objectFields.get(fieldName).getDescribe(), sObjectType));
      }
      
      return fld;
    }
    
    private GNE_SFA2_Base_Ctrl.Field addOptionalInputField(List<GNE_SFA2_Base_Ctrl.Field> fieldsList, Object value, String fieldName, String sObjectType, Map<String, Schema.SObjectField> objectFields) {
      GNE_SFA2_Base_Ctrl.Field fld = null;
      
      if(value!=null && (!(value instanceof String) || String.isNotBlank((String)value))) {
        fieldsList.add(fld = new GNE_SFA2_Base_Ctrl.Field(null, value, false, false, objectFields.get(fieldName).getDescribe(), sObjectType));
      } else {
        fieldsList.add(fld = new GNE_SFA2_Base_Ctrl.Field(null, null, false, false, objectFields.get(fieldName).getDescribe(), sObjectType));
      }
      
      return fld;
    }    
    
    private Long getTime(String dateTimeString) {
        return String.isNotBlank(dateTimeString) ? ((DateTime)JSON.deserialize('"' + dateTimeString + '"', DateTime.class)).getTime() : null; 
    }
    
    private void prepareAttendeeData(InteractionWrapper recordWrapper, iPhone_ManageInteraction engine, Map<String, Schema.SObjectField> objectFields) {
        String sObjectType = engine.sObjectType;
        
        List<GNE_SFA2_Interaction_Ctrl.AttendeeWrapper> rows = new List<GNE_SFA2_Interaction_Ctrl.AttendeeWrapper>(); 
      
      for(AttendeeWrapper attWrapper : (recordWrapper.attendeeRows!=null ? recordWrapper.attendeeRows : new List<AttendeeWrapper>())) {
        Id attendeeId = engine.getWinnerId(attWrapper.aid);
        
        if(String.isNotBlank(attendeeId)) {
            GNE_SFA2_Interaction_Ctrl.AttendeeWrapper attendee = new GNE_SFA2_Interaction_Ctrl.AttendeeWrapper();
          attendee.fields = new List<GNE_SFA2_Base_Ctrl.Field>();
            Boolean hcpOrUser = attWrapper.type == 'PERSONACCOUNT';
            
            addInputField(attendee.fields, attWrapper.rid, String.valueOf(Call2_vod__c.iPhone_Request_Id_gne__c), sObjectType, objectFields);
            addInputField(attendee.fields, attendeeId, hcpOrUser ? String.valueOf(Call2_vod__c.Account_vod__c) : String.valueOf(Call2_vod__c.User_vod__c), sObjectType, objectFields);
            addInputField(attendee.fields, hcpOrUser ? 'Person_Account_vod' : 'User_vod', String.valueOf(Call2_vod__c.Attendee_Type_vod__c), sObjectType, objectFields);
            addInputField(attendee.fields, attWrapper.moo, String.valueOf(Call2_vod__c.HCP_Attendee_Meal_Opt_Out_gne__c), sObjectType, objectFields);
            
            rows.add(attendee);
        }
      }
      
      this.attendeeData = new GNE_SFA2_Interaction_Ctrl.AttendeeData(null, null, null, rows);
    }
    
    private void prepareProductData(InteractionWrapper recordWrapper, iPhone_ManageInteraction engine) {
        Schema.DescribeSObjectResult sObjectDescribe = Call2_Discussion_vod__c.sObjectType.getDescribe();
      Map<String, Schema.SObjectField> objectFields = sObjectDescribe.fields.getMap();
      String sObjectType = sObjectDescribe.getName();
      Set<Id> productIds = new Set<Id>();
      
      for(DetailWrapper dWrapper : (recordWrapper.detailRows!=null ? recordWrapper.detailRows : new List<DetailWrapper>())) {
        if(String.isNotBlank(dWrapper.pid)) {
          productIds.add(dWrapper.pid);
        }
      }
      
      Map<Id,Product_vod__c> productsMap = new Map<Id,Product_vod__c>(new iPhoneBase.WithoutSharingQueryExecutor().getProducts(productIds));
      List<GNE_SFA2_Interaction_Ctrl.ProductWrapper> rows = new List<GNE_SFA2_Interaction_Ctrl.ProductWrapper>(); 
      
      for(DetailWrapper dWrapper : (recordWrapper.detailRows!=null ? recordWrapper.detailRows : new List<DetailWrapper>())) {
        Id productId = dWrapper.pid;
        
        if(String.isNotBlank(productId)) {
            GNE_SFA2_Interaction_Ctrl.ProductWrapper productWrapper = new GNE_SFA2_Interaction_Ctrl.ProductWrapper();
          productWrapper.fields = new List<GNE_SFA2_Base_Ctrl.Field>();
            addInputField(productWrapper.fields, dWrapper.rid, String.valueOf(Call2_Discussion_vod__c.iPhone_Request_Id_gne__c), sObjectType, objectFields);
            GNE_SFA2_Base_Ctrl.Field fld = addInputField(productWrapper.fields, productId, String.valueOf(Call2_Discussion_vod__c.Product_vod__c), sObjectType, objectFields);
            fld.displayValue = productsMap.containsKey(productId) ? productsMap.get(productId).Name : null;
            productWrapper.recordTypeId = engine.getCallDiscussionRecordTypeId();
            rows.add(productWrapper);
        }
      }
      
      this.productData = new GNE_SFA2_Interaction_Ctrl.ProductData(null, null, null, rows, null);
      this.productData.objectiveOrProductMode = true;
    }
    
    private void prepareSampleData(InteractionWrapper recordWrapper, iPhone_ManageInteraction engine) {
      Schema.DescribeSObjectResult sObjectDescribe = Call2_Sample_vod__c.sObjectType.getDescribe();
      Map<String, Schema.SObjectField> objectFields = sObjectDescribe.fields.getMap();
      String sObjectType = sObjectDescribe.getName();
      List<GNE_SFA2_Interaction_Ctrl.MaterialWrapper> rows = new List<GNE_SFA2_Interaction_Ctrl.MaterialWrapper>();
      
      for(SampleWrapper sWrapper : (recordWrapper.sampleRows!=null ? recordWrapper.sampleRows : new List<SampleWrapper>())) {
        Id productId = sWrapper.pid;
        ID attendeeId = engine.getWinnerId(sWrapper.aid);
        if(String.isNotBlank(productId) && String.isNotBlank(attendeeId)) {
          GNE_SFA2_Interaction_Ctrl.MaterialWrapper material = new GNE_SFA2_Interaction_Ctrl.MaterialWrapper(); 
          material.fields = new List<GNE_SFA2_Base_Ctrl.Field>();
          addInputField(material.fields, sWrapper.rid, String.valueOf(Call2_Sample_vod__c.iPhone_Request_Id_gne__c), sObjectType, objectFields);
          addInputField(material.fields, productId, String.valueOf(Call2_Sample_vod__c.Product_vod__c), sObjectType, objectFields);
          addInputField(material.fields, attendeeId, String.valueOf(Call2_Sample_vod__c.Account_vod__c), sObjectType, objectFields);
          addInputField(material.fields, sWrapper.qty, String.valueOf(Call2_Sample_vod__c.Quantity_vod__c), sObjectType, objectFields);
          rows.add(material);
        }
      }
      
      this.materialData = new GNE_SFA2_Interaction_Ctrl.MaterialData(null, null, rows, null);
    }
    
    private void preparePfgData(InteractionWrapper recordWrapper) {
      Schema.DescribeSObjectResult sObjectDescribe = Call_PFG_Detail_gne__c.sObjectType.getDescribe();
      Map<String, Schema.SObjectField> objectFields = sObjectDescribe.fields.getMap();
      String sObjectType = sObjectDescribe.getName();
      List<GNE_SFA2_PFG_Interaction_Ctrl.PfgWrapper> rows = new List<GNE_SFA2_PFG_Interaction_Ctrl.PfgWrapper>(); 
      
      for(PfgDetailWrapper pfgWrapper : (recordWrapper.pfgRows!=null ? recordWrapper.pfgRows : new List<PfgDetailWrapper>())) {
        Id productId = pfgWrapper.pid;
        
        if(String.isNotBlank(productId)) {
            GNE_SFA2_PFG_Interaction_Ctrl.PfgWrapper pfg = new GNE_SFA2_PFG_Interaction_Ctrl.PfgWrapper(); 
            pfg.fields = new List<GNE_SFA2_Base_Ctrl.Field>();
            addInputField(pfg.fields, pfgWrapper.rid, String.valueOf(Call_PFG_Detail_gne__c.iPhone_Request_Id_gne__c), sObjectType, objectFields);
            addInputField(pfg.fields, productId, String.valueOf(Call_PFG_Detail_gne__c.Product_gne__c), sObjectType, objectFields);
            addInputField(pfg.fields, pfgWrapper.qty, String.valueOf(Call_PFG_Detail_gne__c.Quantity_gne__c), sObjectType, objectFields);
            addInputField(pfg.fields, pfgWrapper.dMethod, String.valueOf(Call_PFG_Detail_gne__c.Distribution_Method_gne__c), sObjectType, objectFields);
            
            if(pfgWrapper.dMethod == GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP && String.isNotBlank(recordWrapper.sig)) {
                addInputField(pfg.fields, GNE_SFA2_PFG_Util.TRANSACTION_SIGNATURE_COMPLETE, String.valueOf(Call_PFG_Detail_gne__c.DTP_AOC_Status_gne__c), sObjectType, objectFields);
            }
    
            rows.add(pfg);
        }
      }
      
      this.pfgData = new GNE_SFA2_PFG_Interaction_Ctrl.PfgData(null, null, rows, null, true);
      this.pfgData.somethingChanged = true;
    }
  }
  
  global class InteractionWrapper extends RecordWrapper {
    private String aid;
    private String addid;
    private String dTime;
    private Boolean isComplete;
    private String terrName;
    private String terrId;
    private String type;
    //PREP fields
    private String prepStatus;
    //Compliance
    private Boolean moo;
    private Integer mooPlannedAttendees;
    private Integer mooActualAttendees;
    //PFG fields
    private String sig;
    private String sigDate;
    private String reqSig;
    private String reqSigDate;
    private String disclaimer;
    private String licenseNumber;
    private String hcpSpec;
    //Geolocation
    private Decimal latitude;
    private Decimal longitude;
    //Children
    private List<AttendeeWrapper> attendeeRows;
    private List<DetailWrapper> detailRows;
    private List<SampleWrapper> sampleRows;
    private List<PfgDetailWrapper> pfgRows;
  }
  
  private class AttendeeWrapper extends RecordWrapper {
    private String aid;
    private String type; // user or account
    private Boolean moo;
  }
  
  private class DetailWrapper extends RecordWrapper {
    private String pid;
    private Integer prio;
  }
  
  private class SampleWrapper extends RecordWrapper {
    private String aid;
    private String pid;
    private Integer qty;
  }
  
  private class PfgDetailWrapper extends RecordWrapper {
    private String pid;
    private String dMethod;
    private Integer qty;
  }
  
  private virtual class RecordWrapper {
    private String id;
    private String rid;
  }
  
  public class Response extends iPhone_Commons_gne.AlterDataResponse {
      public List<ResponseItem> responseItems;
      
      public Response(List<ResponseItem> responseItems) {
          this.responseItems = responseItems;
      }
  }
  
  private class ResponseItem extends iPhone_Commons_gne.AlterDataResponseItem {
    private String objectType;
    private String objectName;
    
    public ResponseItem(String rid, Id id, String objectType) {
      this(rid, id, objectType, null); 
    }
    
    public ResponseItem(String rid, Id id, String objectType, String objectName) {
        super(rid, id);
        this.objectType = objectType;
        this.objectName = objectName;
    }
  }
}