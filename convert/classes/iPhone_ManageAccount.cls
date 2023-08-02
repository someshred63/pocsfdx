@RestResource(urlMapping='/iPhoneManageAccount/*')
global with sharing class iPhone_ManageAccount extends GNE_SFA2_SBC_Ctrl implements iPhone_Commons_gne.Runnable {
  private transient ManageAccountRequest request;
  private transient Map<Id,Id> loserToWinnerMap;
  private transient Address_vod__c cachedAddress;
  private static Map<String,AddressWrapper> addrWrappersMap;
  private static Map<Id,Address_vod__c> upsertedAddrDataMap;
  private static Map<String,String> requestIdMap;

  @HttpPost
  global static iPhone_Commons_gne.RestResponse processRequest(ManageAccountRequest request) {
    iPhone_Commons_gne.setStartTimeStamp();
    iPhone_ManageAccount engine = new iPhone_ManageAccount();
    engine.calculateAddressLocations(request);
    return iPhone_Commons_gne.executeAlterData(engine, request);
  }

  private void calculateAddressLocations(ManageAccountRequest request) {
    try {
      addrWrappersMap = new Map<String,AddressWrapper>();
      Integer maxCallouts = Limits.getLimitCallouts()-3;

      if(request.addresses!=null) {
        for(AddressWrapper addrWrapper : request.addresses) {
          if((addrWrapper.latitude==null || addrWrapper.longitude==null) && (maxCallouts-Limits.getCallouts())>0) {
            Address_vod__c addr = addrWrapper.getAddress(null);
            addr.Force_Location_Update_gne__c = true;
            GNE_SFA2_AddressLocation_Util.setAddressLocation(addr);
            addrWrapper.latitude = addr.Location_gne__Latitude__s;
            addrWrapper.longitude = addr.Location_gne__Longitude__s;
          }

          addrWrappersMap.put(addrWrapper.rid, addrWrapper);
        }
      }
    } catch(Exception ex) {
      iPhoneBase.handleException(ex, UserInfo.getUserId(), 'OTR', '[iPhone REST] iPhoneManageAccount',
        request!=null ? request.getRequestType() : null,
        request!=null ? request.getIPhoneRequestId() : null,
        request,
        '[iPhone REST] Error while calculating address location');
    }
  }

  public Object run(Object obj) {
    this.request = (ManageAccountRequest)obj;
    if(isAssignMode()) {
      Id queriedOrCreatedTsf = assignTerritoryToAccount(request);
      return buildAssignModeResponse(queriedOrCreatedTsf);
    }
    this.loserToWinnerMap = getLoserToWinnerMap();
    this.dataWrapper = getDataWrapperInstance();
    this.inputDataWrapper = new DataWrapper(this);
    this.dataWrapper = this.request.isNewMode==true ? intInsertAccount() : this.request.isEditAddressMode==true ? intUpdateAccount() : intUpsertAccount();
    return buildResponse();
  }

  private Boolean isAssignMode() {
    if(this.request != null) {
      if(this.request.isAssignMode != null) {
        if(this.request.isAssignMode) {
          return true;
        }
      }
    }
    return false;
  }

  private Id assignTerritoryToAccount(ManageAccountRequest request) {
    Id accountId, territoryId, tsfId;
    String requestId, tsfRequestId;

    accountId = request.territory.aid;
    territoryId = request.territory.tid;
    requestId = request.territory.rid;
    tsfRequestId = request.territory.tsfRid;

    List<Territory2> requestedTerritory = [SELECT Id, Name FROM Territory2 WHERE Id = :territoryId];
    List<TSF_vod__c> existingTerritoryMapping = [SELECT Id FROM TSF_vod__c WHERE Account_vod__c =: accountId AND
                                           Territory_vod__c =: requestedTerritory[0].Name];
    List<Account> requestedAccount = [SELECT Id, Name FROM Account WHERE Id = :accountId];
    if(existingTerritoryMapping.size() > 0) {
      tsfId = existingTerritoryMapping[0].Id;
    } else {
      List<ObjectTerritory2Association> existingAssociation = [SELECT Id FROM ObjectTerritory2Association WHERE ObjectId = :requestedAccount[0].Id AND Territory2Id = :requestedTerritory[0].Id 
                                                              AND AssociationCause='Territory2Manual']; 
      if(existingAssociation.isEmpty()) {
        ObjectTerritory2Association territoryAssociation = new ObjectTerritory2Association(ObjectId = requestedAccount[0].Id, Territory2Id = requestedTerritory[0].Id, AssociationCause='Territory2Manual');
        insert territoryAssociation;
      }
      TSF_vod__c tsf = new TSF_vod__c(Account_vod__c = accountId, Account_vod__r = requestedAccount[0],
                                      Territory_vod__c = requestedTerritory[0].Name,
                                      iPhone_Request_Id_gne__c = tsfRequestId);
      insert tsf;
      tsfId = tsf.Id;
    }

    return tsfId;
  }

  private AssignModeResponse buildAssignModeResponse(Id tsfId) {
    if(tsfId == null) {
      return new AssignModeResponse();
    }
    return new AssignModeResponse(tsfId);
  }

  protected override GNE_SFA2_Base_Ctrl.DataWrapper getDataWrapperInstance() {
    return new DataWrapper();
  }

  private Map<Id,Id> getLoserToWinnerMap() {
    Map<Id,Id> result = new Map<Id,Id>();

    if(request.account!=null && String.isNotBlank(request.account.id)) {
      Set<Id> accIds = new Set<Id>{request.account.id};
      List<Account> accs = (new iPhoneBase.WithoutSharingQueryExecutor()).getArchivedLoserAccounts(accIds);

      for(Account acc : accs){
        result.put(acc.DCH_Previous_Id_gne__c, acc.DCH_Parent_Id_gne__c);
      }
    }

    if(request.addresses!=null) {
      Set<Id> addrIds = new Set<Id>();

      for(AddressWrapper addrWrapper : request.addresses) {
        if(String.isNotBlank(addrWrapper.id)) {
          addrIds.add(addrWrapper.id);
        }
      }

      if(!addrIds.isEmpty()) {
        List<Address_vod__c> objAddr = (new iPhoneBase.WithoutSharingQueryExecutor()).getArchivedLoserAddresses(addrIds);

        for(Address_vod__c addr : objAddr){
          result.put(addr.DCH_Previous_Id_gne__c, addr.DCH_Parent_Id_gne__c);
        }
      }
    }

    return result;
  }

  private Id getWinnerId(Id recId) {
    return loserToWinnerMap.containsKey(recId) ? loserToWinnerMap.get(recId): recId;
  }

  private Boolean checkIsCompanyMaintained(Id addrId) {
    cacheAddress(getWinnerId(addrId));
    return cachedAddress!=null && cachedAddress.RecordType.DeveloperName == GNE_SFA2_Address_Field_Updates.ADDRESS_COMPANY_MAINTEINED_REC_TYPE;
  }

  private void cacheAddress(Id addrId) {
    if(cachedAddress==null && String.isNotBlank(addrId)) {
      List<Address_vod__c> addrs = [
        SELECT Id, RecordType.DeveloperName, Name, City_vod__c, State_vod__c, Zip_vod__c
        FROM Address_vod__c
        WHERE Id = :addrId
        LIMIT 1
      ];

      for(Address_vod__c addr : addrs) {
        cachedAddress = addr;
      }
    }
  }

  protected override GNE_SFA2_SBC_Ctrl.DataWrapper intInsertAccount() {
    if(request.isAddressMode!=true && String.isNotBlank(request.account.rid)) {
      List<Account> existingAccs = [
        SELECT Id, iPhone_Request_Id_gne__c, MDMID_gne__c, IsPersonAccount, stewardship_system_name_gne__c,
          (SELECT Id, iPhone_Request_Id_gne__c, MDM_Address_ID_gne__c FROM Address_vod__r),
          (SELECT Id, iPhone_Request_Id_gne__c FROM TSF_vod__r)
        FROM Account
        WHERE iPhone_Request_Id_gne__c = :request.account.rid
        LIMIT 1
      ];

      for(Account eAcc : existingAccs) {
        this.upsertedAccount = eAcc;
        this.upsertedAddresses = eAcc.Address_vod__r;
        this.upsertedTSFs = eAcc.TSF_vod__r;
      }
    } else if(request.isAddressMode==true && request.addresses!=null && !request.addresses.isEmpty() && String.isNotBlank(request.addresses[0].rid)) {
      List<Address_vod__c> existingAddrs = [
        SELECT Id, iPhone_Request_Id_gne__c, MDM_Address_ID_gne__c
        FROM Address_vod__c
        WHERE iPhone_Request_Id_gne__c = :request.addresses[0].rid
        LIMIT 1
      ];

      this.upsertedAddresses = existingAddrs;
    }

    return this.upsertedAddresses==null || this.upsertedAddresses.isEmpty() ? super.intInsertAccount() : (GNE_SFA2_SBC_Ctrl.DataWrapper)dataWrapper;
  }

  private Response buildResponse() {
    List<ResponseItem> responseItems = new List<ResponseItem>();

    if(request.isNewMode!=true || request.isAddressMode!=true) {
      responseItems.add(new ResponseItem(getRequestId(this.upsertedAccount.iPhone_Request_Id_gne__c), this.upsertedAccount.Id, this.upsertedAccount.iPhone_Request_Id_gne__c, this.upsertedAccount.MDMID_gne__c));
    }

    if (this.upsertedAddresses.size() > 0) {
      cacheUpsertedAddrDataMap();
      for(Address_vod__c addr : this.upsertedAddresses) {
        responseItems.add(new ResponseItem(getRequestId(addr.iPhone_Request_Id_gne__c), addr.Id, addr.iPhone_Request_Id_gne__c, addr.MDM_Address_ID_gne__c, true));
      }
    }

    if(this.upsertedTSFs!=null) {
      for(TSF_vod__c tsf : this.upsertedTSFs) {
        responseItems.add(new ResponseItem(getRequestId(tsf.iPhone_Request_Id_gne__c), tsf.Id, tsf.iPhone_Request_Id_gne__c, null));
      }
    }

    Boolean isAMS = iPhone_REST_Utils.isAMSAccount(this.upsertedAccount);

    Response resp = new Response(responseItems);
    resp.isAMS = isAMS;

    return resp;
  }

  private void cacheUpsertedAddrDataMap(){
    if (this.upsertedAddresses == null || this.upsertedAddresses.size() == 0){
      return;
    }
    upsertedAddrDataMap = new Map<Id, Address_vod__c>();
    Set<Id> addrIds = new Set<Id>();
    for (Address_vod__c addr : this.upsertedAddresses){
      if (String.isNotBlank(addr.Id)){
        addrIds.add(addr.Id);
      }
    }
    if (addrIds.size() > 0){
      for (Address_vod__c addr : [SELECT Id, RecordType.DeveloperName FROM Address_vod__c WHERE Id In: addrIds]){
        upsertedAddrDataMap.put(addr.Id, addr);
      }
    }
  }

  protected override GNE_SFA2_Base_Ctrl.UserWrapper getCurrentUser() {
    if(currentUser==null) {
      User result = null;

      if(String.isNotBlank(this.request.unixId)) {
        for(User u : [SELECT Id, FirstName, LastName, ProfileId, TimeZoneSidKey FROM User WHERE External_Id_gne__c = :this.request.unixId LIMIT 1]) {
          result = u;
        }
      }

      if(result==null) {
        result = new User(Id = UserInfo.getUserId(), FirstName = UserInfo.getFirstName(), LastName = UserInfo.getLastName(), ProfileId = UserInfo.getProfileId(), TimeZoneSidKey = String.valueOf(UserInfo.getTimeZone()));
      }

      currentUser = new UserWrapper(result);
    }

    return currentUser;
  }

  protected override void validateBeforeUpsert(Account newAccount, Address_vod__c newAddress) {}

  protected override void fetchExistingAccountAndAddress(Account acc, List<Address_vod__c> addrs) {
    DataWrapper saveData = (DataWrapper)inputDataWrapper;
    fetchExistingAccountAndAddress(acc, addrs, saveData.territoriesMap!=null ? saveData.territoriesMap.get(request.account.tid) : null);
  }

  protected override void fetchExistingAccount(Account acc, Account eAcc) {
    super.fetchExistingAccount(acc, eAcc);
    String prevRequestId = acc.iPhone_Request_Id_gne__c;
    String newRequestId = String.isNotBlank(eAcc.iPhone_Request_Id_gne__c) ? eAcc.iPhone_Request_Id_gne__c : prevRequestId;
    acc.iPhone_Request_Id_gne__c = newRequestId;
    cacheRequestId(newRequestId, prevRequestId);
  }

    protected override void fetchExistingAddress(Address_vod__c addr, Address_vod__c eAddr) {
      super.fetchExistingAddress(addr, eAddr);
      String prevRequestId = addr.iPhone_Request_Id_gne__c;
      String newRequestId = String.isNotBlank(eAddr.iPhone_Request_Id_gne__c) ? eAddr.iPhone_Request_Id_gne__c : prevRequestId;
      addr.iPhone_Request_Id_gne__c = newRequestId;
      cacheRequestId(newRequestId, prevRequestId);
    }

    protected override void fetchExistingTSF(TSF_vod__c tsf, TSF_vod__c eTsf) {
      super.fetchExistingTSF(tsf, eTsf);
      String prevRequestId = tsf.iPhone_Request_Id_gne__c;
      String newRequestId = String.isNotBlank(eTsf.iPhone_Request_Id_gne__c) ? eTsf.iPhone_Request_Id_gne__c : prevRequestId;
      tsf.iPhone_Request_Id_gne__c = newRequestId;
      cacheRequestId(newRequestId, prevRequestId);
    }

    private Boolean isLWOUser(){
      return getCurrentUserProfileName().toUpperCase().contains('LWO');
    }

  protected override void upsertTerritoryRecords(Id terrId, Account acc, Address_vod__c addr, Boolean newAccountMode) {
    super.upsertTerritoryRecords(newAccountMode ? terrId : this.request.account.tid, acc, addr, newAccountMode);
  }

  protected override TSF_vod__c getTSF(TerritoryWrapper tWrapper, Account acc) {
    TSF_vod__c tsf = super.getTSF(tWrapper, acc);
    tsf.iPhone_Request_Id_gne__c = request.account.tsfrid;
    return tsf;
  }

  protected override void upsertTSF(TSF_vod__c tsf) {
    super.upsertTSF(tsf);

    if(!existingTSFs.isEmpty()) {
        TSF_vod__c existingTsf = existingTSFs.get(tsf.Territory_vod__c.toUpperCase());

        if(tsf.iPhone_Request_Id_gne__c!=existingTsf.iPhone_Request_Id_gne__c) {
            executeDML(GNE_SFA2_Base_Ctrl.DmlOperations.UPS, new TSF_vod__c(Id=existingTsf.Id, iPhone_Request_Id_gne__c = tsf.iPhone_Request_Id_gne__c), false);
        }
    }
  }

  private static void cacheRequestId(String nrid, String rid) {
    if(requestIdMap==null) {
      requestIdMap = new Map<String,String>();
    }

    requestIdMap.put(nrid, rid);
  }

  private static String getRequestId(String rid) {
    return requestIdMap!=null && requestIdMap.containsKey(rid) ? requestIdMap.get(rid) : rid;
  }

  global class ManageAccountRequest implements iPhone_Commons_gne.BaseArgs, iPhoneBase.RequestTestable2 {
    public String unixId;
    public Boolean isNewMode;
    public Boolean isAddressMode;
    public Boolean isEditAccountMode;
    public Boolean isEditAddressMode;
    public Boolean isPfg;
    public Boolean isAssignMode;
    public AccountWrapper account;
    public List<AddressWrapper> addresses;
    public AssignModeWrapper territory;

    public String getIPhoneRequestId(){
      return account!=null && String.isNotBlank(account.rid) ? account.rid : (addresses!=null && !addresses.isEmpty() ? addresses[0].rid : null);
    }

    public void testRequest() {
      new iPhone_ManageAccount().run(this);
    }

    public System.Type getRequestType() {
      return ManageAccountRequest.class;
    }
  }

  private class DataWrapper extends GNE_SFA2_SBC_Ctrl.DataWrapper {

    private DataWrapper() {
      super();
    }

    private DataWrapper(iPhone_ManageAccount ctrl) {
      if(ctrl.request.isNewMode==true) {
        this.sbcMode = 'hcpCreate';
        setInputFields(ctrl);
      } else if(ctrl.request.isEditAccountMode==true || ctrl.request.isEditAddressMode==true) {
        this.sbcMode = 'hcpEdit';
        setInputFields(ctrl);
      } else {
        GNE_SFA2_SBC_Ctrl.SearchData sData = new GNE_SFA2_SBC_Ctrl.SearchData(null, null);
        sData.selectedAccountRow = ctrl.request.account;
        sData.selectedAddressRows = ctrl.request.addresses;
        this.searchData = new Map<String, GNE_SFA2_SBC_Ctrl.SearchData>{'hcp' => sData};
        this.sbcMode = 'hcpSearch';
      }

      this.isCreateAddressMode = ctrl.request.isAddressMode;
      this.isEditAccountMode = ctrl.request.isEditAccountMode;
      this.isEditAddressMode = ctrl.request.isEditAddressMode;
      this.accountTypesMap = ctrl.getAccountTypesMap();

      if(ctrl.request.account!=null && String.isNotBlank(ctrl.request.account.tid)) {
        this.territoriesMap = new Map<Id,GNE_SFA2_SBC_Ctrl.TerritoryWrapper>();
        List<Territory2> terrs = [SELECT Id, Name FROM Territory2 WHERE Id = :ctrl.request.account.tid];
        List<Group> groups = [SELECT Id, RelatedId FROM Group WHERE RelatedId IN :terrs AND Type = 'Territory'];
        Map<Id,Id> terrIdToGroupIdMap = new Map<Id,Id>();

        for(Group grp : groups) {
          terrIdToGroupIdMap.put(grp.RelatedId, grp.Id);
        }

        for(Territory2 terr : terrs) {
          this.territoriesMap.put(terr.Id, new GNE_SFA2_SBC_Ctrl.TerritoryWrapper(terr, terrIdToGroupIdMap.get(terr.Id)));
        }
      }
    }

    private void setInputFields(iPhone_ManageAccount ctrl) {
      this.createInputFields = new List<GNE_SFA2_Base_Ctrl.Field>();
      Boolean includeEmptyValues = ctrl.request.isEditAddressMode==true;
      Boolean isPfg = ctrl.request.isPfg==true;

      Schema.DescribeSObjectResult sObjectDescribe = Account.sObjectType.getDescribe();
      String sObjectType = sObjectDescribe.getName();
      Map<String, Schema.SObjectField> objectFields = sObjectDescribe.fields.getMap();
      AccountWrapper acw = ctrl.request.account;

      if(ctrl.request.isEditAccountMode==true || ctrl.request.isAddressMode==true) {
        addInputField(this.createInputFields, ctrl.getWinnerId(acw.id), String.valueOf(Account.Id), sObjectType, objectFields);
      }

      if(acw!=null) {
        addInputField(this.createInputFields, acw.rid, String.valueOf(Account.iPhone_Request_Id_gne__c), sObjectType, objectFields);
        addInputField(this.createInputFields, acw.firstName, String.valueOf(Account.FirstName), sObjectType, objectFields);
        addInputField(this.createInputFields, acw.middleName, String.valueOf(Account.Middle_vod__c), sObjectType, objectFields);
        addInputField(this.createInputFields, acw.lastName, String.valueOf(Account.LastName), sObjectType, objectFields);
        addInputField(this.createInputFields, acw.suffix, String.valueOf(Account.Suffix_vod__c), sObjectType, objectFields);
        addInputField(this.createInputFields, acw.type, String.valueOf(Account.Professional_Type_gne__c), sObjectType, objectFields);
        addInputField(this.createInputFields, (acw.credentials!=null && !acw.credentials.isEmpty()) ? acw.credentials[0] : null, String.valueOf(Account.Credentials_vod__c), sObjectType, objectFields);
        addInputField(this.createInputFields, acw.specialties, String.valueOf(Account.Specialties_gne__c), sObjectType, objectFields);
        addInputField(this.createInputFields, acw.tid, 'territory', null, null);
        addInputField(this.createInputFields, acw.email, String.valueOf(Account.PersonEmail), sObjectType, objectFields);
        addInputField(this.createInputFields, acw.email2, String.valueOf(Account.Secondary_Email_gne__c), sObjectType, objectFields);
      }

      sObjectDescribe = Address_vod__c.sObjectType.getDescribe();
      sObjectType = sObjectDescribe.getName();
      objectFields = sObjectDescribe.fields.getMap();



      for(AddressWrapper adw : ctrl.request.addresses) {
        Boolean isCompanyMaintained = ctrl.request.isEditAddressMode==true && ctrl.checkIsCompanyMaintained(adw.id);

        if(ctrl.request.isEditAddressMode==true) {
          addInputField(this.createInputFields, ctrl.getWinnerId(adw.id), String.valueOf(Address_vod__c.Id), sObjectType, objectFields);
        }

        if(!isCompanyMaintained) {
          addInputField(this.createInputFields, adw.street, String.valueOf(Address_vod__c.Name), sObjectType, objectFields);
          addInputField(this.createInputFields, adw.city, String.valueOf(Address_vod__c.City_vod__c), sObjectType, objectFields);
          addInputField(this.createInputFields, adw.state, String.valueOf(Address_vod__c.State_vod__c), sObjectType, objectFields);
          addInputField(this.createInputFields, adw.zip, String.valueOf(Address_vod__c.Zip_vod__c), sObjectType, objectFields);
        }

        addInputField(this.createInputFields, adw.rid, String.valueOf(Address_vod__c.iPhone_Request_Id_gne__c), sObjectType, objectFields);
        addInputField(this.createInputFields, adw.suite, String.valueOf(Address_vod__c.Address_Line_2_vod__c), sObjectType, objectFields, includeEmptyValues);
        addInputField(this.createInputFields, adw.phone, String.valueOf(Address_vod__c.Phone_vod__c), sObjectType, objectFields, includeEmptyValues);
        addInputField(this.createInputFields, adw.phone2, String.valueOf(Address_vod__c.Phone_2_vod__c), sObjectType, objectFields, includeEmptyValues);
        addInputField(this.createInputFields, adw.fax, String.valueOf(Address_vod__c.Fax_vod__c), sObjectType, objectFields, includeEmptyValues);
        addInputField(this.createInputFields, adw.fax2, String.valueOf(Address_vod__c.Fax_2_vod__c), sObjectType, objectFields, includeEmptyValues);
        addInputField(this.createInputFields, adw.designation, String.valueOf(Address_vod__c.Designation_gne__c), sObjectType, objectFields, includeEmptyValues);
        addInputField(this.createInputFields, adw.latitude, String.valueOf(Address_vod__c.Location_gne__Latitude__s), sObjectType, objectFields);
        addInputField(this.createInputFields, adw.longitude, String.valueOf(Address_vod__c.Location_gne__Longitude__s), sObjectType, objectFields);
        addInputField(this.createInputFields, adw.latitude, String.valueOf(Address_vod__c.Latitude_vod__c), sObjectType, objectFields);
        addInputField(this.createInputFields, adw.longitude, String.valueOf(Address_vod__c.Longitude_vod__c), sObjectType, objectFields);
        addInputField(this.createInputFields, adw.businessName, String.valueOf(Address_vod__c.Business_Name_gne__c), sObjectType, objectFields);
        addInputField(this.createInputFields, adw.changedAddress, String.valueOf(Address_vod__c.Changed_Address_gne__c), sObjectType, objectFields);
        addInputField(this.createInputFields, adw.businessAddressType, String.valueOf(Address_vod__c.Business_Address_Type_gne__c), sObjectType, objectFields);

        if(isPfg) {
          addInputField(this.createInputFields, adw.bestDays, String.valueOf(Address_vod__c.PFG_BDTD_gne__c), sObjectType, objectFields, includeEmptyValues);
        }

        break;
      }
    }

    private GNE_SFA2_Base_Ctrl.Field addInputField(List<GNE_SFA2_Base_Ctrl.Field> fieldsList, Object value, String fieldName, String sObjectType, Map<String, Schema.SObjectField> objectFields) {
      return addInputField(fieldsList, value, fieldName, sObjectType, objectFields, false);
    }

    private GNE_SFA2_Base_Ctrl.Field addInputField(List<GNE_SFA2_Base_Ctrl.Field> fieldsList, Object value, String fieldName, String sObjectType, Map<String, Schema.SObjectField> objectFields, Boolean forceNulls) {
      GNE_SFA2_Base_Ctrl.Field fld = null;

      if(forceNulls==true || (value!=null && (!(value instanceof String) || String.isNotBlank((String)value)))) {
        if(objectFields==null) {
          fld = new GNE_SFA2_Base_Ctrl.Field(null, value, false, false);
          fld.name = fieldName;
        } else {
          fld = new GNE_SFA2_Base_Ctrl.Field(null, value, false, false, objectFields.get(fieldName).getDescribe(), sObjectType);
        }

        fieldsList.add(fld);
      }

      return fld;
    }
  }

  private class AccountWrapper extends GNE_SFA2_SBC_Ctrl.SearchAccountWrapper {
    private String rid;
    private String suffix;
    private String tid;
    private String tsfrid;
    private String email;
    private String email2;

    public override Account getAccount() {
      Account acc = super.getAccount();
      acc.iPhone_Request_Id_gne__c = rid;
      return acc;
    }
  }

  private class AddressWrapper extends GNE_SFA2_SBC_Ctrl.SearchAddressWrapper {
    private String rid;
    private String phone;
    private String phone2;
    private String fax;
    private String fax2;
    private String bestDays;
    private String designation;
    private String businessName;
    private String businessAddressType;
    private Boolean changedAddress;

    public override Address_vod__c getAddress(Map<String,List<GNE_SFA2_SBC_Ctrl.LicenseWrapper>> licensesMap) {
      Address_vod__c addr = super.getAddress(licensesMap);
      addr.iPhone_Request_Id_gne__c = rid;
      return addr;
    }
  }

  public class Response extends iPhone_Commons_gne.AlterDataResponse {
      public List<ResponseItem> responseItems;
      public Boolean isAMS;

      public Response(List<ResponseItem> responseItems) {
          this.responseItems = responseItems;
      }
  }

  private virtual class ResponseItem extends iPhone_Commons_gne.AlterDataResponseItem {
    private String nrid;
    private String mid;
    private Double latitude;
    private Double longitude;
    private String isAddrCm; //isAddressCompanyMaintained

    private ResponseItem(String rid, Id id, String nrid, String mid) {
      this(rid, id, nrid, mid, false);
    }

    private ResponseItem(String rid, Id id, String nrid, String mid, Boolean isAddress) {
        super(rid, id);
        this.nrid = nrid;
        this.mid = mid;

        if(isAddress==true) {
          if (addrWrappersMap!=null && addrWrappersMap.containsKey(rid)) {
            AddressWrapper addrWrapper = addrWrappersMap.get(rid);
            this.latitude = addrWrapper.latitude;
            this.longitude = addrWrapper.longitude;
          }
          if (upsertedAddrDataMap != null && upsertedAddrDataMap.containsKey(id)){
            Address_vod__c addrData = upsertedAddrDataMap.get(id);
            this.isAddrCm = iPhone_StringUtil.getString(GNE_SFA2_Address_Field_Updates.isRecordCompanyMaintained(addrData.RecordType.DeveloperName));
          } else {
            this.isAddrCm = iPhone_StringUtil.getString(String.isNotBlank(mid));
          }
        }
    }
  }

  private class AssignModeWrapper {
    private Id aid;
    private String rid;
    private String tid;
    private String tsfrid;

    public AssignModeWrapper(Id aid, String rid, String tid, String tsfrid) {
      this.aid = aid;
      this.rid = rid;
      this.tid = tid;
      this.tsfrid = tsfrid;
    }
  }

  public class AssignModeResponse extends iPhone_Commons_gne.AlterDataResponse {
    public AssignModeResponse() {

    }

    public AssignModeResponse(String tsfId) {
      this.sfdcId = tsfId;
    }
  }
}