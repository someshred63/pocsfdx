public with sharing class GNE_SFA2_PFG_Interaction_Ctrl {
  private transient GNE_SFA2_Interaction_Ctrl mainCtrl;
  private transient String distributionMethod;
  private transient List<Call_PFG_Detail_gne__c> inputPfgDetails;
  private transient GNE_SFA2_Base_Ctrl.Section pfgSection;
  
  public GNE_SFA2_PFG_Interaction_Ctrl(GNE_SFA2_Interaction_Ctrl mainCtrl) {
    this.mainCtrl = mainCtrl;
    this.distributionMethod = 'DTP';
  }
  
  public GNE_SFA2_Interaction_Ctrl.DataWrapper init(GNE_SFA2_Interaction_Ctrl.DataWrapper dataWrapper) {
    List<GNE_SFA2_Base_Ctrl.Field> pfgColumns = getPfgColumns();
    PfgWrapper pfgTemplate = getPfgTemplate(pfgColumns);
      List<PfgWrapper> pfgWrappers = getPfgWrappers(pfgColumns);
      Map<String,PfgLimit> pfgLimits = getPfgLimits();
      dataWrapper.pfgData = new PfgData(pfgColumns, pfgTemplate, pfgWrappers, pfgLimits, isDtp());
      return dataWrapper;
  }
  
  public String getPfgSubQuery() {
    Set<String> fieldNames = new Set<String>{
      String.valueOf(Call_PFG_Detail_gne__c.Call_gne__c).toLowerCase(),
      String.valueOf(Call_PFG_Detail_gne__c.Product_gne__c).toLowerCase(),
      'product_gne__r.name',
      'product_gne__r.ndc_number_gne__c',
      'product_gne__r.uom_gne__c',
      String.valueOf(Call_PFG_Detail_gne__c.Distribution_Method_gne__c).toLowerCase(),
      String.valueOf(Call_PFG_Detail_gne__c.Lot_No_gne__c).toLowerCase(),
      String.valueOf(Call_PFG_Detail_gne__c.Quantity_gne__c).toLowerCase(),
      String.valueOf(Call_PFG_Detail_gne__c.Order_Status_gne__c).toLowerCase(),
      String.valueOf(Call_PFG_Detail_gne__c.Shipment_ID_gne__c).toLowerCase(),
      String.valueOf(Call_PFG_Detail_gne__c.DTP_AOC_Status_gne__c).toLowerCase(),
      String.valueOf(Call_PFG_Detail_gne__c.iPhone_Request_Id_gne__c).toLowerCase()
    };
    
    GNE_SFA2_Interaction_Ctrl.DataWrapper saveData = (GNE_SFA2_Interaction_Ctrl.DataWrapper)mainCtrl.inputDataWrapper;
    if(saveData!=null) {
      fieldNames.addAll(mainCtrl.getFieldNamesFromRows(saveData.pfgData.rows));
    }
    
    return String.format('(SELECT {0} FROM Call_PFG_Details__r)', new String[]{
      String.join(new List<String>(fieldNames), ',')
    });
  }
  
  private Boolean isDTP() {
    return getDistributionMethod()==GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP;
  }
  
  private String getDistributionMethod() {
    if(distributionMethod==null) {
      GNE_SFA2_Interaction_Ctrl.DataWrapper saveData = (GNE_SFA2_Interaction_Ctrl.DataWrapper)mainCtrl.inputDataWrapper;
        GNE_SFA2_Interaction_Ctrl.DataWrapper dataWrapper = (GNE_SFA2_Interaction_Ctrl.DataWrapper)mainCtrl.dataWrapper;
      Id userId = saveData!=null ? saveData.appContext.currentUser.id : dataWrapper.appContext.currentUser.id;
      Boolean isDtpActive = GNE_SFA2_PFG_Util.isDtpActiveForUser(userId);
      Boolean isHcActive = GNE_SFA2_PFG_Util.isHcActiveForUser(userId);
      
      distributionMethod = isDtpActive && !isHcActive 
        ? GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP : 
        !isDtpActive && isHcActive
        ? GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC :
        null;
    }
    
    return distributionMethod;
  }
  
  public void setPfgSectionFields(GNE_SFA2_Base_Ctrl.Section section) {
    pfgSection = section;
    pfgSection.fields = new List<GNE_SFA2_Base_Ctrl.Field>{
      new GNE_SFA2_Base_Ctrl.Field(String.valueOf(Call_PFG_Detail_gne__c.Order_Status_gne__c), 'DTP Order Status'),
        new GNE_SFA2_Base_Ctrl.Field(String.valueOf(Call_PFG_Detail_gne__c.Shipment_ID_gne__c), 'DTP Shipment ID'),
        new GNE_SFA2_Base_Ctrl.Field(String.valueOf(Call_PFG_Detail_gne__c.DTP_AOC_Status_gne__c), 'DTP AOC Status')
    };
  }
  
  private List<GNE_SFA2_Base_Ctrl.Field> getPfgColumns() {
      return new List<GNE_SFA2_Base_Ctrl.Field>{
          new GNE_SFA2_Base_Ctrl.Field('Product_gne__c', 'NDC', null, null, null, null, false, true, null, 
              new GNE_SFA2_Base_Ctrl.FieldDescribe(Call_PFG_Detail_gne__c.Product_gne__c.getDescribe(), 'Call_PFG_Detail_gne__c')),
          new GNE_SFA2_Base_Ctrl.Field('productName', 'Product Name'),
          new GNE_SFA2_Base_Ctrl.Field('Lot_No_gne__c', 'Lot #', null, null, null, null, false, false, null, 
              new GNE_SFA2_Base_Ctrl.FieldDescribe(Call_PFG_Detail_gne__c.Lot_No_gne__c.getDescribe(), 'Call_PFG_Detail_gne__c')),
          new GNE_SFA2_Base_Ctrl.Field('Quantity_gne__c', 'Quantity', null, null, null, null, false, true, null, 
              new GNE_SFA2_Base_Ctrl.FieldDescribe(Call_PFG_Detail_gne__c.Quantity_gne__c.getDescribe(), 'Call_PFG_Detail_gne__c'))
      };
    }
    
    private List<PfgWrapper> getPfgWrappers(List<GNE_SFA2_Base_Ctrl.Field> columns) {
      List<PfgWrapper> result = new List<PfgWrapper>();
      
      Call2_vod__c call = (Call2_vod__c)mainCtrl.record;
      
      if(call.Call_PFG_Details__r!=null) {
        Integer idx = 0;
        for(Call_PFG_Detail_gne__c cpd : call.Call_PFG_Details__r) {
          if(idx==0) {
            for(GNE_SFA2_Base_Ctrl.Field fld : pfgSection.fields) {
              fld.setValue(cpd.get(fld.name));
            }
          }
          PfgWrapper pw = new PfgWrapper('call-pfg-' + String.valueOf(idx++), cpd, columns);
          result.add(pw);
        }
      }
      
      return result;
    }
    
    private PfgWrapper getPfgTemplate(List<GNE_SFA2_Base_Ctrl.Field> columns) {
      return new PfgWrapper('0', new Call_PFG_Detail_gne__c(Quantity_gne__c = 0), columns);
    }
    
    private Map<String,PfgLimit> getPfgLimits() {
      GNE_SFA2_Interaction_Ctrl.DataWrapper dataWrapper = (GNE_SFA2_Interaction_Ctrl.DataWrapper)mainCtrl.dataWrapper;
      Map<String,PfgLimit> result = new Map<String,PfgLimit>();
      String currentTerrName = mainCtrl.getCurrentTerrName(mainCtrl.currentUser.id);
      Territory2 terr = GNE_SFA2_PFG_Util.getTerritoryByName(currentTerrName);
      
      if(terr!=null) {
        Integer currentYear = GNE_SFA2_PFG_Util.getYear();
        Set<Integer> years = new Set<Integer>{currentYear-1, currentYear, currentYear+1};
        Set<Id> callHcpIds = new Set<Id>{dataWrapper.callAccount.id};
        
        List<SFA2_PFG_to_Territory_Detail_gne__c> tDetails = GNE_SFA2_PFG_Util.getPFGToTerrDetailsActiveForTerrNamesFlat(new Set<String>{terr.Name}, years);
        List<Id> productIds = new List<Id>();
        List<Id> accIds = new List<Id>();
        List<String> yearsAsString = new List<String>();
        
        for(SFA2_PFG_to_Territory_Detail_gne__c tDetail : tDetails) {
          for(Id hcpId : callHcpIds) {
            productIds.add(tDetail.Product_gne__c);
            accIds.add(hcpId);
            yearsAsString.add(String.valueOf(tDetail.Year_gne__c));
          }
        }
        
        GNE_SFA2_PFG_Util.cacheProductLimits(productIds, yearsAsString);
        GNE_SFA2_PFG_Util.cacheAccLimitExceptions(accIds, productIds, yearsAsString);
        GNE_SFA2_PFG_Util.cachePfgToAccountDetails(accIds, productIds, yearsAsString);
        
        for(SFA2_PFG_to_Territory_Detail_gne__c tDetail : tDetails) {
          Id productId = tDetail.Product_gne__c;
          String ndcNumber = tDetail.Product_gne__r.NDC_Number_gne__c;
          String prodName = tDetail.Product_gne__r.Name;
          String uom = tDetail.UOM_gne__c;
          Integer year = tDetail.Year_gne__c.intValue();
          String yearAsString = String.valueOf(year);
          Integer callLimit = GNE_SFA2_PFG_Util.getInteractionQtyLimit(productId, getDistributionMethod());
          
          for(Id hcpId : callHcpIds) {
            Integer productLimitQty = GNE_SFA2_PFG_Util.getProductMaxQuantity(productId, yearAsString);
            Integer userLimit = tDetail.Qty_Total_Available_gne__c.intValue();
            Integer hcpLimit = GNE_SFA2_PFG_Util.getHcpMaxQuantity(hcpId, productId, yearAsString);
            hcpLimit = productLimitQty!=null ? Math.min(productLimitQty, hcpLimit!=null ? hcpLimit : productLimitQty) : null;
            result.put(getLimitKey(productId, hcpId, year), new PfgLimit(new PfgProductWrapper(productId, ndcNumber, prodName, uom), hcpId, year, userLimit, hcpLimit, callLimit));
          }
        }
      }
      
      return result;
    }
    
    private String getLimitKey(Id productId, Id hcpId, Integer year) {
      return String.format('{0}_{1}_{2}', new String[]{productId, hcpId, String.valueOf(year)});
    }
    
    
  public Boolean validate() {
    Boolean isValid = true;
    GNE_SFA2_Interaction_Ctrl.DataWrapper saveData = (GNE_SFA2_Interaction_Ctrl.DataWrapper)mainCtrl.inputDataWrapper;
    GNE_SFA2_Interaction_Ctrl.DataWrapper dataWrapper = (GNE_SFA2_Interaction_Ctrl.DataWrapper)mainCtrl.dataWrapper;
    Call2_vod__c call = (Call2_vod__c)mainCtrl.record;
    
    if(isValidationNeeded()) {
      if(saveData.isCompleted==true || saveData.completeMode==true) {
        mainCtrl.handleException(mainCtrl.createException(new PfgCannotCompleteWithoutSignatureException()));
      } else {
        Id userId = saveData.appContext.currentUser.id;
        validateUser(userId);
        validateAddress(call.Parent_Address_vod__c);
        
        if(dataWrapper.success==true) {
          Integer callYear = call.Date_Completed_gne__c!=null ? call.Date_Completed_gne__c.year() : System.today().year();
          // Validate fields
          validateCallPfgDetails(userId, callYear);
        }
      }
    }
    
    return isValid;
  }
  
  private void validateUser(Id userId) {
    Boolean isLOA = GNE_SFA2_PFG_Util.checkIsUserLOA(userId);
    Boolean isCertified = GNE_SFA2_PFG_Util.checkIsUserCertified(userId);
    
    if(isLOA && !isCertified) {
      mainCtrl.handleException(mainCtrl.createException(new PfgUserOnLoaAndUncertifiedException()));
    }else if(isLOA) {
      mainCtrl.handleException(mainCtrl.createException(new PfgUserOnLoaException()));
    }else if(!isCertified) {
      mainCtrl.handleException(mainCtrl.createException(new PfgUserUncertifiedException()));
    }
  }
  
  private void validateAddress(Id addrId) {
    Boolean isSlnValid = GNE_SFA2_PFG_Util.checkIsSlnValid(addrId);
      
    if(!isSlnValid) {
      mainCtrl.handleException(mainCtrl.createException(new PfgAddressSlnNotValidException()));
    }
  }
  
  private List<Call_PFG_Detail_gne__c> getInputPfgDetails() {
    if(inputPfgDetails==null) {
      inputPfgDetails = new List<Call_PFG_Detail_gne__c>();
      GNE_SFA2_Interaction_Ctrl.DataWrapper saveData = (GNE_SFA2_Interaction_Ctrl.DataWrapper)mainCtrl.inputDataWrapper;
    
      for(PfgWrapper pw : saveData.pfgData.rows) {
        Call_PFG_Detail_gne__c cDetail = (Call_PFG_Detail_gne__c)pw.getRecord(Call_PFG_Detail_gne__c.class);
        inputPfgDetails.add(cDetail);
      }
    }
    
    return inputPfgDetails;
  }
  
  
  
  private void validateCallPfgDetails(Id userId, Integer callYear) {
    GNE_SFA2_Interaction_Ctrl.DataWrapper saveData = (GNE_SFA2_Interaction_Ctrl.DataWrapper)mainCtrl.inputDataWrapper;
    Id hcpId = saveData.callAccount.id;
    Integer i = 0;
    Boolean isSingleMode = getInputPfgDetails().size() == 1;
    Set<Id> prodIds = new Set<Id>();
    Set<String> lotNos = new Set<String>();
    
    for(Call_PFG_Detail_gne__c cDetail : getInputPfgDetails()) {
      PfgWrapper pfgWrapper = saveData.pfgData.rows[i];
      String rowPrefix = 'PFG' + (isSingleMode ? '' : (' #' + ++i)) + ': ';
      
      if(isDTP()) {
        if(prodIds.contains(cDetail.Product_gne__c)) {
          mainCtrl.handleException(mainCtrl.createException(
            new PfgAlreadyInUseException(i-1, rowPrefix, String.valueOf(Call_PFG_Detail_gne__c.Product_gne__c)), 
            new Object[]{pfgWrapper.getField(String.valueOf(Call_PFG_Detail_gne__c.Product_gne__c)).label}
          ));
        }
        
        prodIds.add(cDetail.Product_gne__c);
      } else {
        if(lotNos.contains(cDetail.Lot_No_gne__c)) {
          mainCtrl.handleException(mainCtrl.createException(
            new PfgAlreadyInUseException(i-1, rowPrefix, String.valueOf(Call_PFG_Detail_gne__c.Lot_No_gne__c)), 
            new Object[]{pfgWrapper.getField(String.valueOf(Call_PFG_Detail_gne__c.Lot_No_gne__c)).label}
          ));
        }
        
        lotNos.add(cDetail.Lot_No_gne__c);
      }
      
      setCallDetailDate(cDetail);
      String currentTerrName = mainCtrl.getCurrentTerrName(saveData.appContext.currentUser.id);
      Integer pfgQty = cDetail.Quantity_gne__c.intValue();
      PfgLimit pfgLimit = saveData.pfgData.pfgLimits!=null ? saveData.pfgData.pfgLimits.get(getLimitKey(cDetail.Product_gne__c, hcpId, callYear)) : null;
      String qtyFieldName = String.valueOf(Call_PFG_Detail_gne__c.Quantity_gne__c);
      if(pfgQty<=0) {
          mainCtrl.handleException(mainCtrl.createException(new PfgQuantityMustBeGreaterException(i-1, rowPrefix, qtyFieldName), new Object[]{1}));
      } else if(pfgLimit!=null) {
        if(pfgLimit.userLimit==0) {
            mainCtrl.handleException(mainCtrl.createException(new PfgQuantityNotAvailableException(i-1, rowPrefix, qtyFieldName)));
        } else if(pfgLimit.userLimit==1 && pfgLimit.userLimit<pfgQty) {
          mainCtrl.handleException(mainCtrl.createException(new PfgQuantityMustBeEqualException(i-1, rowPrefix, qtyFieldName), new Object[]{pfgLimit.userLimit}));
        } else if(pfgLimit.userLimit<pfgQty) {
          mainCtrl.handleException(mainCtrl.createException(new PfgQuantityMustBeBetweenException(i-1, rowPrefix, qtyFieldName), new Object[]{0, pfgLimit.userLimit}));
          }
        
          if(pfgLimit.hcpLimit!=null && pfgLimit.hcpLimit<pfgQty) {
            mainCtrl.handleException(mainCtrl.createException(new PfgQuantityHcpLimitReachedException(i-1, rowPrefix, qtyFieldName), new Object[]{pfgLimit.hcpLimit}));
          }
        
          if(pfgLimit.callLimit!=null && pfgLimit.callLimit<pfgQty) {
            String ndc = pfgWrapper.getField(String.valueOf(Call_PFG_Detail_gne__c.Product_gne__c)).displayValue;
            mainCtrl.handleException(mainCtrl.createException(new PfgQuantityCallLimitReachedException(i-1, rowPrefix, qtyFieldName), new Object[]{ndc, pfgLimit.callLimit}));
          }
      }
    }
  }
  
  public void savePfgs() {
    GNE_SFA2_PFG_Util.addSessionLabel(GNE_SFA2_Interaction_Ctrl.class.getName());
    if(isSomethingChanged()) {
      Call2_vod__c call = (Call2_vod__c)mainCtrl.record;
      mainCtrl.pfgDetailsToUpsert = new List<Call_PFG_Detail_gne__c>();
      GNE_SFA2_Interaction_Ctrl.DataWrapper saveData = (GNE_SFA2_Interaction_Ctrl.DataWrapper)mainCtrl.inputDataWrapper;
      
      Integer idx = 0;
        for(Call_PFG_Detail_gne__c cDetail : getInputPfgDetails()) {
          PfgWrapper pw = saveData.pfgData.rows[idx];
          cDetail.Call_gne__c = call.Id;
          cDetail.Account_gne__c = call.Account_vod__c;
          cDetail.Distribution_Method_gne__c = getDistributionMethod();
          cDetail.Is_Completed_gne__c = call.Completed_gne__c;
          setCallDetailDate(cDetail);
          mainCtrl.setRecordIdFromExisting(cDetail, pw);
          mainCtrl.pfgDetailsToUpsert.add(cDetail);
          idx++;
        }
      } 
  }
    
  private void setCallDetailDate(Call_PFG_Detail_gne__c cDetail) {
    cDetail.Date_gne__c = getCallDetailDate();
  }
  
  private Date getCallDetailDate() {
    Call2_vod__c call = (Call2_vod__c)mainCtrl.record;
    return call.Date_Completed_gne__c!=null ? call.Date_Completed_gne__c : System.today();
  }
    
  private Boolean isSomethingChanged() {
    GNE_SFA2_Interaction_Ctrl.DataWrapper saveData = (GNE_SFA2_Interaction_Ctrl.DataWrapper)mainCtrl.inputDataWrapper;
    return saveData.pfgData!=null && saveData.pfgData.somethingChanged!=false;
  }
  
  private Boolean isValidationNeeded() {
    GNE_SFA2_Interaction_Ctrl.DataWrapper saveData = (GNE_SFA2_Interaction_Ctrl.DataWrapper)mainCtrl.inputDataWrapper;
    return isSomethingChanged() && saveData.pfgData.rows!=null && !saveData.pfgData.rows.isEmpty();
  }
    
  public class PfgData {
      public List<GNE_SFA2_Base_Ctrl.Field> columns;
      public PfgWrapper rowTemplate;
      public List<PfgWrapper> rows;
      public Map<String,PfgLimit> pfgLimits;
      public Boolean somethingChanged;
      public Boolean isDtp;
    
      public PfgData(List<GNE_SFA2_Base_Ctrl.Field> columns, PfgWrapper rowTemplate, List<PfgWrapper> rows, Map<String,PfgLimit> pfgLimits, Boolean isDtp) {
        this.columns = columns;
        this.rowTemplate = rowTemplate;
        this.rows = rows;
        this.pfgLimits = pfgLimits;
        this.isDtp = isDtp;
      }
    }
  
  public virtual class PfgWrapper extends GNE_SFA2_Interaction_Ctrl.TableRowWrapper {
      public PfgWrapper() {}

      public PfgWrapper(String rowId, Call_PFG_Detail_gne__c cpd, List<GNE_SFA2_Base_Ctrl.Field> columns) {
          this.rowId = rowId;
          this.fields = new List<GNE_SFA2_Base_Ctrl.Field>();
        
          for(GNE_SFA2_Base_Ctrl.Field column : columns) {
            GNE_SFA2_Base_Ctrl.Field field = new GNE_SFA2_Base_Ctrl.Field(column);
            Object fieldValue;
            
            if(column.name == 'productName') {
              fieldValue = String.isNotBlank(cpd.Product_gne__c) ? cpd.Product_gne__r.Name : null;  
            } else {
              fieldValue = cpd.get(field.name);
            }
            
            if(column.name == String.valueOf(Call_PFG_Detail_gne__c.Quantity_gne__c)) {
              column.describe.length = 4;
            }
            
            if(column.describe!=null && column.describe.type == 'reference' && cpd.getSObject(column.describe.relationshipName)!=null) {
              field.displayValue = (String)cpd.getSObject(column.describe.relationshipName).get(column.name=='Product_gne__c' ? 'NDC_Number_gne__c' : 'Name');
            }
            
            field.setValue(fieldValue);
            this.fields.add(field);
          }
        }
      
      protected override SObject getRecord(System.Type sObjectType) {
          Call_PFG_Detail_gne__c result = (Call_PFG_Detail_gne__c)super.getRecord(sObjectType);
          return result; 
        }
    }
    
    private class PfgLimit {
      private PfgProductWrapper pfg;
      private Id hcpId;
      private Integer year;
      private String lot;
      private Integer userLimit;
      private Integer hcpLimit;
      private Integer callLimit;
      private Integer overallLimit;
      
      private PfgLimit(PfgProductWrapper pfg, Id hcpId, Integer year, Integer userLimit, Integer hcpLimit, Integer callLimit) {
        this(pfg, hcpId, year, null, userLimit, hcpLimit, callLimit);
      }
      
      private PfgLimit(PfgProductWrapper pfg, Id hcpId, Integer year, String lot, Integer userLimit, Integer hcpLimit, Integer callLimit) {
        this.pfg = pfg;
        this.hcpId = hcpId;
        this.year = year;
        this.lot = lot;
        this.userLimit = userLimit;
        this.hcpLimit = hcpLimit;
        this.callLimit = callLimit;
        this.overallLimit = Math.min(this.userLimit, Math.min(this.hcpLimit!=null ? this.hcpLimit : this.userLimit, this.callLimit!=null ? this.callLimit : this.userLimit));
      }
    }
    
    private class PfgProductWrapper {
      private Id id;
      private String ndc;
      private String name;
      private String uom;
      
      public PfgProductWrapper(Id prodId, String ndc, String name, String uom) {
        this.id = prodId;
        this.ndc = ndc;
        this.name = name;
        this.uom = uom;
      }
    }
    
    private class PfgCannotCompleteWithoutSignatureException extends GNE_SFA2_Base_Ctrl.BaseException {
      protected override void init() {
        type = GNE_SFA2_Base_Ctrl.ErrorTypes.Error.name();
        subType = 'PfgCannotCompleteWithoutSignature';
        label = System.Label.GNE_SFA2_PFG_CANNOT_COMPLETE_INTERACTION_WITHOUT_SIGNATURE;  
      }
    }
    
    private class PfgUserOnLoaAndUncertifiedException extends GNE_SFA2_Base_Ctrl.BaseException {
      protected override void init() {
        type = GNE_SFA2_Base_Ctrl.ErrorTypes.Error.name();
        subType = 'PfgUserOnLoaAndUncertified';
        label = System.Label.PFG_USER_ON_LOA_AND_UNCERTIFIED; 
      }
    }
    
    private class PfgUserOnLoaException extends GNE_SFA2_Base_Ctrl.BaseException {
      protected override void init() {
        type = GNE_SFA2_Base_Ctrl.ErrorTypes.Error.name();
        subType = 'PfgUserOnLoa';
        label = System.Label.PFG_USER_ON_LOA; 
      }
    }
    
    
    private class PfgUserUncertifiedException extends GNE_SFA2_Base_Ctrl.BaseException {
      protected override void init() {
        type = GNE_SFA2_Base_Ctrl.ErrorTypes.Error.name();
        subType = 'PfgUserUncertified';
        label = System.Label.PFG_USER_UNCERTIFIED;  
      }
    }
    
    private class PfgAddressSlnNotValidException extends GNE_SFA2_Base_Ctrl.BaseException {
      protected override void init() {
        type = GNE_SFA2_Base_Ctrl.ErrorTypes.Error.name();
        subType = 'PfgAddressSlnNotValid';
        label = System.Label.GNE_SFA2_PFG_ADDRESS_SLN_NOT_VALID;  
      }
    }
    
    private virtual class PfgDetailException extends GNE_SFA2_Base_Ctrl.BaseException {
      protected transient String rowPrefix;
      
      protected PfgDetailException(Integer rowIdx, String rowPrefix, String fieldName) {
        this.type = ErrorTypes.Error.name();
        this.fieldId = String.valueOf(rowIdx);
        this.fieldName = fieldName;
        this.sObjectType = 'Call_PFG_Detail_gne__c';
        this.rowPrefix = rowPrefix;
      }
      
      protected override void init(List<String> labelParams) {
        super.init(labelParams);
        this.fieldMessage = labelParams.isEmpty() ? fieldMessage : String.format(fieldMessage, labelParams);
      }
    }
    
    private class PfgAlreadyInUseException extends PfgDetailException {
      private PfgAlreadyInUseException(Integer rowIdx, String rowPrefix, String fieldName) { super(rowIdx, rowPrefix, fieldName); }
      
      protected override void init() {
        type = GNE_SFA2_Base_Ctrl.ErrorTypes.Error.name();
        subType = 'PfgAlreadyInUse';
        label = rowPrefix + (fieldMessage = '{0} ' + System.Label.GNE_SFA2_PFG_VALUE_ALREADY_IN_USE); 
      }
    }
    
    private class PfgQuantityIsTooLargeException extends PfgDetailException {
      private PfgQuantityIsTooLargeException(Integer rowIdx, String rowPrefix, String fieldName) { super(rowIdx, rowPrefix, fieldName); }
      
      protected override void init() {
        type = GNE_SFA2_Base_Ctrl.ErrorTypes.Error.name();
        subType = 'PfgQuantityIsTooLarge';
        label = rowPrefix + (fieldMessage = System.Label.GNE_SFA2_PFG_QUANTITY_IS_TOO_LARGE); 
      }
    }
    
    private class PfgQuantityMustBeGreaterException extends PfgDetailException {
      private PfgQuantityMustBeGreaterException(Integer rowIdx, String rowPrefix, String fieldName) { super(rowIdx, rowPrefix, fieldName); }
      
      protected override void init() {
        type = GNE_SFA2_Base_Ctrl.ErrorTypes.Error.name();
        subType = 'PfgQuantityMustBeGreater';
        label = rowPrefix + (fieldMessage = System.Label.GNE_SFA2_PFG_QUANTITY_MUST_BE_GREATER);  
      }
    }
    
    private class PfgQuantityNotAvailableException extends PfgDetailException {
      private PfgQuantityNotAvailableException(Integer rowIdx, String rowPrefix, String fieldName) { super(rowIdx, rowPrefix, fieldName); }
      
      protected override void init() {
        type = GNE_SFA2_Base_Ctrl.ErrorTypes.Error.name();
        subType = 'PfgQuantityNotAvailable';
        label = rowPrefix + (fieldMessage = System.Label.GNE_SFA2_PFG_QUANTITY_NOT_AVAILABLE);  
      }
    }
    
    private class PfgQuantityMustBeBetweenException extends PfgDetailException {
      private PfgQuantityMustBeBetweenException(Integer rowIdx, String rowPrefix, String fieldName) { super(rowIdx, rowPrefix, fieldName); }
      
      protected override void init() {
        type = GNE_SFA2_Base_Ctrl.ErrorTypes.Error.name();
        subType = 'PfgQuantityMustBeBetween';
        label = rowPrefix + (fieldMessage = System.Label.GNE_SFA2_PFG_QUANTITY_MUST_BE_BETWEEN);  
      }
    }
    
    private class PfgQuantityMustBeEqualException extends PfgDetailException {
      private PfgQuantityMustBeEqualException(Integer rowIdx, String rowPrefix, String fieldName) { super(rowIdx, rowPrefix, fieldName); }
      
      protected override void init() {
        type = GNE_SFA2_Base_Ctrl.ErrorTypes.Error.name();
        subType = 'PfgQuantityMustBeEqual';
        label = rowPrefix + (fieldMessage = System.Label.GNE_SFA2_PFG_QUANTITY_MUST_BE_EQUAL);  
      }
    }
    
    private class PfgQuantityHcpLimitReachedException extends PfgDetailException {
      private PfgQuantityHcpLimitReachedException(Integer rowIdx, String rowPrefix, String fieldName) { super(rowIdx, rowPrefix, fieldName); }
      
      protected override void init() {
        type = GNE_SFA2_Base_Ctrl.ErrorTypes.Error.name();
        subType = 'PfgQuantityHcpLimitReached';
        label = rowPrefix + (fieldMessage = System.Label.PFG_HCP_QUANTITY_LIMIT_REACHED); 
      }
    }
    
    private class PfgQuantityCallLimitReachedException extends PfgDetailException {
      private PfgQuantityCallLimitReachedException(Integer rowIdx, String rowPrefix, String fieldName) { super(rowIdx, rowPrefix, fieldName); }
      
      protected override void init() {
        type = GNE_SFA2_Base_Ctrl.ErrorTypes.Error.name();
        subType = 'PfgQuantityCallLimitReached';
        label = rowPrefix + (fieldMessage = System.Label.GNE_SFA2_PFG_HCP_CALL_QUANTITY_LIMIT_REACHED); 
      }
    }
}