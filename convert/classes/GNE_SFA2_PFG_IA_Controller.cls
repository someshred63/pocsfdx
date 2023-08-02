public with sharing class GNE_SFA2_PFG_IA_Controller extends GNE_SFA2_PFG_Base_Controller {

  public String title {get; private set;}
  public Id currentUserId {get; private set;}
  public String currentUserName {get; private set;}
  public String userRole {get; private set;}
  public String pfgType {get; private set;}
  public Boolean isDebugMode {get; private set;}

  public Boolean isCS { get { return userRole==GNE_SFA2_PFG_Util.USER_ROLE_CS;} }
  public Boolean isDM { get { return userRole==GNE_SFA2_PFG_Util.USER_ROLE_DM;} }
  public Boolean isRM { get { return userRole==GNE_SFA2_PFG_Util.USER_ROLE_RM;} }
  public Boolean isBrandManager { get { return isDM || isRM;} }
  public Boolean isManager { get { return userRole==GNE_SFA2_PFG_Util.USER_ROLE_MANAGER;} }
  public Boolean isDTP { get { return pfgType==GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP;} }

  @TestVisible private transient String transactionRefNo;
  @TestVisible private transient String mainUserNodeId;
  @TestVisible private transient Map<String,UserQuantityNode> userNodes;
  @TestVisible private transient List<SalesRepWrapper> salesReps;
  @TestVisible private transient String currentBrand;
  @TestVisible private transient Boolean isMultiBranding;
  @TestVisible private transient Id currentProductId;
  @TestVisible private transient String productName;
  @TestVisible private transient String ndcNumber;
  @TestVisible private transient Integer currentYear;
  @TestVisible private transient Integer ytdAllocatedQty;
  @TestVisible private transient Integer totalAvailableQty;
  @TestVisible private transient Map<String, Set<String>> salesforceCodes;
  @TestVisible private transient String currentUserTerrName;
  @TestVisible private List<String> errorMessages;
  @TestVisible private List<String> infoMessages;
  @TestVisible private String debugInfoMessage;

  @TestVisible private static Map<String,UserQuantityNode> userNodesMapStatic;

  public GNE_SFA2_PFG_IA_Controller() {
  	this(UserInfo.getUserId(),
  		 UserInfo.getName(),
  		 new Set<String>{'yes', '1', 'true'}.contains((ApexPages.currentPage().getParameters().get('debugMode')!=null ? ApexPages.currentPage().getParameters().get('debugMode') : '').ToLowerCase()),
  		 ApexPages.currentPage().getParameters().get('type'),
  		 ApexPages.currentPage().getParameters().get('userRole'));

    String userId = ApexPages.currentPage().getParameters().get('userId');

    if(userId!=null) {
    	currentUserId = userId;
    }
  }

  public GNE_SFA2_PFG_IA_Controller(Id a_userId, String a_userName, Boolean a_isDebugMode, String a_pfgType, String a_userRole) {
  	currentUserId = String.isNotBlank(a_userId) ? a_userId : UserInfo.getUserId();
    currentUserName = String.isNotBlank(a_userName) ? a_userName : UserInfo.getName();
    isDebugMode = a_isDebugMode;
  	pfgType = (a_pfgType==null || a_pfgType==GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP)
  			? GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP
  			: GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC;
  	userRole = a_userRole;
  	currentYear = GNE_SFA2_PFG_Util.getYear();

  	if(String.isBlank(userRole)) {
	  	GNE_SFA2_User_App_Context_gne__c userApplicationContext = GNE_SFA2_Util.getUserApplicationContext();

	    if(userApplicationContext!=null) {
	      userRole = userApplicationContext.Role_gne__c;
	    }
  	}

  	if(userRole == GNE_SFA2_PFG_Util.USER_ROLE_CS) {
		title = String.format('Proposed Allocation ({0})',new List<String>{pfgType});
	} else {
		title = String.format('Inventory Allocation ({0})',new List<String>{pfgType});
	}

	errorMessages = new List<String>();
	infoMessages = new List<String>();
  }

  protected override PageReference intInitCotroller() {
  	PageReference pageRef = null;
  	validateUserRole();
	return pageRef;
  }

  private void validateUserRole() {
    if(String.isBlank(userRole)) {
    	throw new InitPage_Exception(System.Label.GNE_SFA2_PFG_ROLE_NOT_DEFINED);
    }
  }

  private void setMainUserNode() {
  	prepareCache();
  	populatePfgDetailsQuantities();
    UserQuantityNode mainUserNode = new UserQuantityNode(currentUserId, currentUserName, userRole, null, ytdAllocatedQty, totalAvailableQty, currentProductId, currentYear);
    mainUserNodeId = mainUserNode.nodeId;

    userNodes = new Map<String,UserQuantityNode>{mainUserNodeId => mainUserNode};
    userNodesMapStatic = new Map<String,UserQuantityNode>{mainUserNode.nodeId => mainUserNode};

    if(String.isNotBlank(currentProductId)) {
      	userNodes.putAll(mainUserNode.buildChildNodes(pfgType, salesforceCodes, currentProductId, currentYear));
    }

    userNodesMapStatic = userNodes;

    if(!isDTP) {
      // Get Ref No - it will be needed for new Alloc Transfers (Ref No should be the same as for existing ones).
      transactionRefNo = mainUserNode.getTransactionRefNo();
    }

    salesReps = mainUserNode.convertToSalesRepWrappers();
  }

  private UserQuantityNode getMainUserNode() {
  	return userNodes.get(mainUserNodeId);
  }

  private void prepareCache() {
  	GNE_SFA2_PFG_Util.clearPfgAllocationTransactionsCache();

  	Boolean isUserCS = GNE_SFA2_PFG_Util.checkIsUserCS(currentUserId);
    Boolean isUserManager = !isUserCS && GNE_SFA2_PFG_Util.checkIsUserManager(currentUserId);

  	if(String.isNotBlank(currentProductId)) {
  	  Product_vod__c pfgProd = GNE_SFA2_PFG_Util.getPfgProduct(currentProductId);
      // If we are allocating DTP, we don't need to look for Not Submitted Allocation Transfers.
      // All quantities will be gathered in PFG to Territory Detail.
      // For Hand Carry we want to get all not initiated allocations, because we can change quantities for them.
      if(!isDTP) {
      	GNE_SFA2_PFG_Util.cacheUsersHierarchy(currentUserId, userRole, pfgProd.Parent_Product_vod__r.Name);
        GNE_SFA2_PFG_Util.cachePfgAllocationTransactions(
          new Set<Id>{currentProductId},
          GNE_SFA2_PFG_Util.usersHierarchyCache.keySet());

      	if(!isUserCS) {
      		GNE_SFA2_PFG_Util.clearPfgToUserCache();
      		GNE_SFA2_PFG_Util.cachePfgToUserDetailsNoLot(new List<Id>{currentUserId}, new List<Id>{currentProductId});
      	}
      } else {
      	salesforceCodes = GNE_SFA2_PFG_UTIL.getSalesforceCodesByBrandNames(new Set<String>{pfgProd.Parent_Product_vod__r.Name});

      	Territory2 territory;
    	currentUserTerrName = isUserManager
    				? GNE_SFA2_PFG_Util.getHoTerritoryId()
    				: ((territory = GNE_SFA2_PFG_Util.getFirstTerritoryForUserBySalesforceCodes(currentUserId, salesforceCodes))!=null ? territory.Name : null);
    	cachePfgToTerritoryDetails(territory!=null ? territory.Id : null, currentUserTerrName, currentProductId, currentYear);
      }
    }
  }

  private void cachePfgToTerritoryDetails(Id mainTerrId, String mainTerrName, Id prodId, Integer year) {
  	if(mainTerrName!=null) {
	  	Set<String> terrNames = new Set<String>{mainTerrName};
	  	for(Territory2 terr : GNE_SFA2_PFG_Util.getAllChildTerritoriesBySalesforceCodes(mainTerrId, salesforceCodes)) {
	  		terrNames.add(terr.Name);
	  	}

	  	GNE_SFA2_PFG_Util.clearPfgToTerritoryCache();
	  	GNE_SFA2_PFG_Util.cachePfgToTerritoryDetails(new List<String>(terrNames), new List<Id>{prodId}, new List<Integer>{year});
  	}
  }

  private void populatePfgDetailsQuantities() {
	    ytdAllocatedQty = 0;
    	totalAvailableQty = 0;
    	Boolean isUserCS = GNE_SFA2_PFG_Util.checkIsUserCS(currentUserId);
    	Boolean isUserManager = !isUserCS && GNE_SFA2_PFG_Util.checkIsUserManager(currentUserId);

    	if(String.isNotBlank(currentProductId) && !isDTP && !isUserCS) {
    		SFA2_PFG_to_User_Detail_gne__c uDetail = GNE_SFA2_PFG_Util.getPfgToUserDetailNoLotNo(currentUserId, currentProductId);
      		if(uDetail!=null) {
        		ytdAllocatedQty = uDetail.YTD_Allocated_gne__c.intValue();
        		totalAvailableQty = uDetail.Qty_Total_Available_gne__c.intValue();
      		}
    	} else if(String.isNotBlank(currentProductId) && isDTP && salesforceCodes != null && !salesforceCodes.isEmpty()) {
    		SFA2_PFG_to_Territory_Detail_gne__c tDetail = GNE_SFA2_PFG_Util.getPfgToTerritoryDetail(currentUserTerrName, currentProductId, currentYear);

    		if(tDetail!=null) {
          		ytdAllocatedQty = tDetail.YTD_Allocated_gne__c.intValue();
          		totalAvailableQty = tDetail.Qty_Total_Available_gne__c.intValue();
        	}
    	}
  }

  public String getConfirmMessage() {
    return System.Label.GNE_SFA2_PFG_DTP_CONFIRM_ALLOCATION;
  }

  public List<KeyValueOption> getAvailableBrands() {
    List<KeyValueOption> availableBrands = new List<KeyValueOption>{new KeyValueOption('','--None--')};
    Set<String> activeUserBrands = isDTP ? GNE_SFA2_PFG_Config.ACTIVE_BRANDS_FOR_DTP : GNE_SFA2_PFG_Config.ACTIVE_BRANDS_FOR_HC;
    if(isCS || isBrandManager) {
    	Set<String> userBrands = GNE_SFA2_PFG_Util.getBrandNamesByUserTerritory(UserInfo.getUserId());
    	userBrands.RetainAll(activeUserBrands);
    	Set<String> brandsWithAvailableProducts = GNE_SFA2_PFG_Util.getBrandNames();
    	userBrands.RetainAll(brandsWithAvailableProducts);
      	if (userBrands.size() > 0){
      		String firstBrandName = null;
      		for (String brandName : userBrands){
      			if (String.isBlank(firstBrandName)){
      				firstBrandName = brandName;
      			}
        		availableBrands.add(new KeyValueOption(brandName, brandName));
      		}
      		if (userBrands.size() == 1){
      			currentBrand = firstBrandName;
      		}
      	}
    } else {
    	Set<String> userBrands = GNE_SFA2_PFG_Util.getBrandNamesBySalesforceActiveBrands(activeUserBrands);
    	Set<String> brandsWithAvailableProducts = GNE_SFA2_PFG_Util.getBrandNames();
    	userBrands.RetainAll(brandsWithAvailableProducts);
    	if (userBrands.size() > 0){
	    	for (String brandName : userBrands){
    			availableBrands.add(new KeyValueOption(brandName, brandName));
    		}
    		availableBrands.sort();
    	}
    }

    isMultiBranding = isManager || (availableBrands != null && availableBrands.size() > 2);
    return availableBrands;
  }

  private List<KeyValueOption> getAvailableProducts(String brandName) {
    List<KeyValueOption> availableProducts = new List<KeyValueOption>{new KeyValueOption('','--None--')};
    List<Product_vod__c> prods = GNE_SFA2_PFG_Util.getProductsForBrand(brandName);
    String distrMethod = getDistributionMethod();

    for(Product_vod__c prod : prods) {
      if(GNE_SFA2_PFG_Util.getDistMethodsForProduct(prod.Id).contains(distrMethod)) {
        availableProducts.add(new KeyValueOption(prod.Id,prod.Name));
      }
    }

    return availableProducts;
  }

  private List<KeyValueOption> getAvailableYears() {
  	List<KeyValueOption> availableYears;

  	if(isDTP) {
  		availableYears = new List<KeyValueOption>();

  		for(Integer i=0; i<10; i++) {
  			String val = String.valueOf(currentYear+i);
  			availableYears.add(new KeyValueOption(val, val));
  		}
  	}

  	return availableYears;
  }

  private String getDistributionMethod() {
    return pfgType;
  }

  private void productChanged(String prodId) {
  	currentProductId = String.isNotBlank(prodId) ? prodId : null;
  	Product_vod__c pfgProd = currentProductId!=null ? GNE_SFA2_PFG_Util.getPfgProduct(currentProductId) : null;
  	productName = pfgProd!=null ? pfgProd.Name : null;
  	ndcNumber = pfgProd!=null ? pfgProd.NDC_Number_gne__c : null;
  	currentBrand = pfgProd!=null ? pfgProd.Parent_Product_vod__r.Name : null;

    setMainUserNode();
  }

  public List<SalesRepWrapper> getSalesReps() {
  	return null;
  }

  public List<UserQuantityNode> getTransactionNodesToUpsertInDebugMode() {
  	return null;
  }

  private Boolean save() {
    PageReference pageRef = null;
    Boolean isOk = false;

    if(validateBeforeSave()) {
      UserQuantityNode mainUserNode = getMainUserNode();
      List<SFA2_PFG_Transaction_gne__c> trnsToUpsert = mainUserNode.getTransactionsToUpsert(pfgType);
      populateTransactionRecordsWithValues(trnsToUpsert);
      List<SFA2_PFG_Transaction_gne__c> trnsToDelete = mainUserNode.getTransactionsToDelete();

      SavePoint savePoint = Database.setSavepoint();
      try {
        delete trnsToDelete;
        GNE_SFA2_PFG_Util.saveTransaction(trnsToUpsert, transactionRefNo, !isDTP);
        isOk = true;
      } catch(Exception ex) {
        errorMessages.add(ex.getMessage() + ' [' + ex.getStackTraceString() + ']');
        Database.rollback(savePoint);
      }
    }

    if(isOk) {
    	infoMessages.add(String.format(System.Label.GNE_SFA2_PFG_IA_SAVED, new String[]{currentBrand, productName, String.valueOf(currentYear)}));
    }

    return isOk;
  }

  private Boolean validateBeforeSave() {
    Boolean isValid = true;
    if (String.isBlank(currentBrand)){
    	// It means that product is not selected also
    	isValid = false;
    	errorMessages.add(System.Label.GNE_SFA2_PFG_SALESFORCE_IS_REQUIRED);
    } else if(String.isBlank(currentProductId)) {
      	isValid = false;
      	errorMessages.add(System.Label.GNE_SFA2_PFG_PRODUCT_IS_REQUIRED);
    }

    if(!getMainUserNode().IsSomethingChanged()) {
      isValid = false;
      errorMessages.add(System.Label.GNE_SFA2_PFG_NO_CHANGES_TO_SAVE);
    }

    return isValid;
  }

  private void populateTransactionRecordsWithValues(List<SFA2_PFG_Transaction_gne__c> trnList) {
    Map<String, Schema.RecordTypeInfo> rtInfos = SFA2_PFG_Transaction_gne__c.getSobjectType().getDescribe().getRecordTypeInfosByName();
    Id allocRecTypeId = rtInfos.get(GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION).getRecordTypeId();
    Id allocTransferRecTypeId = rtInfos.get(GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION_TRANSFER).getRecordTypeId();
    String distrMethod = getDistributionMethod();
    Boolean isFutureAllocation = isDTP && currentYear!=null && currentYear!=GNE_SFA2_PFG_Util.getYear();

    for(SFA2_PFG_Transaction_gne__c trn : trnList) {
      if(trn.Id==null) {
        trn.Product_gne__c = currentProductId;
        trn.Distribution_Method_gne__c = distrMethod;
        trn.RecordTypeId = ((trn.From_User_gne__c==null && trn.From_Territory_Name_gne__c==null) ? allocRecTypeId : allocTransferRecTypeId);

        if(transactionRefNo!=null) {
          trn.Transaction_Ref_Number_gne__c = transactionRefNo;
          trn.Lot_No_gne__c = !isDTP ? transactionRefNo : null;
        }

        if(isFutureAllocation) {
        	trn.Transaction_Date_gne__c = Date.newInstance(currentYear,1,1);
        }
      }
    }
  }

  private static UserQuantityNode getUserQuantityNode(String nodeId) {
    	return userNodesMapStatic.get(nodeId);
  }

  @RemoteAction @ReadOnly
  public static ControllerData getInitData(String userId, String userName, String userRole, Boolean isDebugMode, String pfgType) {
  	ControllerData result = new ControllerData();

  	try {
  		populateQtyNodesData(result, userId, userName, userRole, isDebugMode, pfgType, null, null);
	  	result.availableBrands = result.ctrl.getAvailableBrands();
	  	result.availableYears = result.ctrl.getAvailableYears();
	  	result.copyFrom(result.ctrl);
	  	result.availableProducts = result.ctrl.getAvailableProducts(result.currentBrand);
  	} catch(Exception ex) {
  		result.retURL = getErrorPageUrl('getInitData', ex);
  	}

  	result.onActionFinish('getInitData');
  	return result;
  }

  @RemoteAction @ReadOnly
  public static ControllerData onBrandChanged(String userId, String userName, String userRole, Boolean isDebugMode, String pfgType, String brandName, Integer year) {
  	ControllerData result = new ControllerData();

  	try {
  		populateQtyNodesData(result, userId, userName, userRole, isDebugMode, pfgType, null, year);
  		result.ctrl.currentBrand = brandName;
  		result.availableProducts = result.ctrl.getAvailableProducts(brandName);
  		result.copyFrom(result.ctrl);
  	} catch(Exception ex) {
  		result.retURL = getErrorPageUrl('onBrandChanged', ex);
  	}

  	result.onActionFinish('onBrandChanged');
  	return result;
  }

  @RemoteAction @ReadOnly
  public static ControllerData onProductChanged(String userId, String userName, String userRole, Boolean isDebugMode, String pfgType, String prodId, Integer year) {
  	ControllerData result = new ControllerData();

  	try {
  		populateQtyNodesData(result, userId, userName, userRole, isDebugMode, pfgType, prodId, year);
  		result.copyFrom(result.ctrl);

  	} catch(Exception ex) {
  		result.retURL = getErrorPageUrl('onProductChanged', ex);
  	}

  	result.onActionFinish('onProductChanged');
  	return result;
  }

  @RemoteAction
  public static ControllerData onAllocationSave(String userId, String userName, String userRole, Boolean isDebugMode, String pfgType, String ctrlDataJSON) {
  	ControllerData result = new ControllerData();

  	try {
  		GNE_SFA2_PFG_IA_Controller ctrl = new GNE_SFA2_PFG_IA_Controller(userId, userName, isDebugMode, pfgType, userRole);
	  	result.ctrl = ctrl;
	  	((ControllerData)JSON.deserialize(ctrlDataJSON, ControllerData.class)).copyTo(ctrl);
	  	Boolean isOk = ctrl.save();

	  	if(isOk) {
	  		ctrl.productChanged(ctrl.currentProductId);
	  	}

	  	result.copyFrom(ctrl);
  	} catch(Exception ex) {
  		result.retURL = getErrorPageUrl('onAllocationSave', ex);
  	}

  	result.onActionFinish('onAllocationSave');
  	return result;
  }

  @RemoteAction @ReadOnly
  public static List<UserQuantityNode> getTransactionsToUpsertInDebugMode(String userId, String userName, String userRole, Boolean isDebugMode, String pfgType, String ctrlDataJSON) {
  	GNE_SFA2_PFG_IA_Controller ctrl = new GNE_SFA2_PFG_IA_Controller(userId, userName, isDebugMode, pfgType, userRole);
  	((ControllerData)JSON.deserialize(ctrlDataJSON, ControllerData.class)).copyTo(ctrl);
  	ctrl.prepareCache();
  	// Calculate transaction nodes
  	ctrl.getMainUserNode().getTransactionsToUpsert(pfgType);
  	return ctrl.getMainUserNode().getTransactionNodesToUpsert();
  }

  private static void populateQtyNodesData(ControllerData result, String userId, String userName, String userRole, Boolean isDebugMode, String pfgType, String prodId, Integer year) {
  	GNE_SFA2_PFG_IA_Controller ctrl = new GNE_SFA2_PFG_IA_Controller(userId, userName, isDebugMode, pfgType, userRole);
  	result.ctrl = ctrl;
  	result.ctrl.currentYear = year!=null ? year : result.ctrl.currentYear;
  	ctrl.productChanged(prodId);
  }

  private static String getErrorPageUrl(String actionName, Exception ex) {
  	return GNE_SFA2_PFG_Base_Controller.setErrorPageReference(
  			actionName, ex, Page.GNE_SFA2_PFG_Inventory_Allocation).getUrl();
  }

  public class ControllerData {
  	@TestVisible private String currentBrand;
  	@TestVisible private Id currentProductId;
  	@TestVisible private Integer currentYear;
  	@TestVisible private String ndcNumber;
  	@TestVisible private String productName;
  	@TestVisible private List<KeyValueOption> availableBrands;
  	@TestVisible private Boolean isMultiBranding;
  	@TestVisible private List<KeyValueOption> availableProducts;
  	@TestVisible private List<KeyValueOption> availableYears;
  	@TestVisible private String mainUserNodeId;
  	@TestVisible private Map<String,UserQuantityNode> userNodes;
  	@TestVisible private String transactionRefNo;
  	@TestVisible private List<SalesRepWrapper> salesReps;
  	@TestVisible private transient GNE_SFA2_PFG_IA_Controller ctrl;
  	@TestVisible private transient DateTime startTimeStamp;
  	@TestVisible private List<String> errorMessages;
  	@TestVisible private List<String> infoMessages;
  	@TestVisible private String retURL;
  	@TestVisible private String debugInfoMessage;

  	private ControllerData() {
  		startTimeStamp = System.now();
  	}

  	private void onActionFinish( String actionName) {
  		if(ctrl.isDebugMode == true) {
	  		Long execTimeMilis = startTimeStamp!= null ? (System.now().getTime()  - startTimeStamp.getTime()) : null;
	  		debugInfoMessage = String.format(
	  			'Action: {0}<br/>Exec Time : {1} ms | CPU Time:  {2}/{3} ms | Script Statements : {4}/{5}<br/>' +
	  			'Query Statements:  {6}/{7} | Query Rows:  {8}/{9}<br/>' +
	  			'DML Statements:  {10}/{11} | DML Rows:  {12}/{13}', new String[]{
	  				actionName, execTimeMilis.format(),
	  				Limits.getCpuTime().format(), Limits.getLimitCpuTime().format(),
	  				Limits.getScriptStatements().format(), Limits.getLimitScriptStatements().format(),
	  				Limits.getQueries().format(), Limits.getLimitQueries().format(),
	  				Limits.getQueryRows().format(), Limits.getLimitQueryRows().format(),
	  				Limits.getDmlStatements().format(), Limits.getLimitDmlStatements().format(),
	  				Limits.getDmlRows().format(), Limits.getLimitDmlRows().format()
	  		});
  		}
  	}

  	private void copyFrom(GNE_SFA2_PFG_IA_Controller a_ctrl) {
  		ndcNumber = a_ctrl.ndcNumber;
  		productName = a_ctrl.productName;
	  	currentProductId = a_ctrl.currentProductId;
	  	currentYear = a_ctrl.currentYear;
	  	transactionRefNo = a_ctrl.transactionRefNo;
	  	mainUserNodeId = a_ctrl.mainUserNodeId;
	  	userNodes = a_ctrl.userNodes;
	  	salesReps = a_ctrl.salesReps;
	  	isMultiBranding = a_ctrl.isMultiBranding;
  		currentBrand = a_ctrl.currentBrand;
  		errorMessages = a_ctrl.errorMessages;
  		infoMessages = a_ctrl.infoMessages;
  	}

  	private void copyTo(GNE_SFA2_PFG_IA_Controller a_ctrl) {
  		a_ctrl.ndcNumber = ndcNumber;
  		a_ctrl.productName = productName;
		a_ctrl.currentProductId = currentProductId;
		a_ctrl.currentYear = currentYear;
		a_ctrl.transactionRefNo = transactionRefNo;
		a_ctrl.mainUserNodeId = mainUserNodeId;
		a_ctrl.userNodes = userNodes;
		a_ctrl.salesReps = salesReps;
		a_ctrl.isMultiBranding = isMultiBranding;
		a_ctrl.currentBrand = currentBrand;

		userNodesMapStatic = userNodes;
  	}

  }

  private class KeyValueOption implements Comparable {
  	private String key;
  	private String value;

  	private KeyValueOption(String a_key, String a_value) {
  		key = a_key;
  		value = a_value;
  	}

  	public Integer compareTo(Object other) {
  		return value.compareTo(((KeyValueOption)other).value);
  	}
  }

  public class UserQuantityNode {
    @TestVisible private String nodeId;
    @TestVisible private String userOrTerritoryId;
    @TestVisible private String userName;
    @TestVisible private Integer origQuantity;
    @TestVisible private Integer ytdAllocatedQty;
    @TestVisible private String parentId;
    @TestVisible private Integer remainingQuantity;
    @TestVisible private Boolean isCS;
    @TestVisible private Boolean isDM;
    @TestVisible private Boolean isRM;
    @TestVisible private Boolean isBrandManager;
    @TestVisible private Boolean isManager;
    @TestVisible private List<String> childIds;
    @TestVisible private SFA2_PFG_Transaction_gne__c trxRec;
    @TestVisible private String prevSiblingId;
    @TestVisible private String nextSiblingId;
    @TestVisible private Boolean isTransactionChanged;
    @TestVisible private String userRole;
    @TestVisible private Integer availableQuantity;
    @TestVisible private Integer allocationQuantity;
    @TestVisible private Integer quantity;
    @TestVisible private Integer newManagerQuantity;
    @TestVisible private Integer csNodesCounter;
    @TestVisible private transient String trxRefNo;


    public UserQuantityNode(String a_userOrTerritoryId, String a_userName, String a_role, UserQuantityNode a_parent, Integer a_ytdAllocatedQty, Integer a_totalAvailableQty, Id prodId, Integer year) {
      userOrTerritoryId = a_userOrTerritoryId;
      userName = a_userName;
      userRole = a_role;
      isCS = userRole==GNE_SFA2_PFG_Util.USER_ROLE_CS;
      isDM = userRole==GNE_SFA2_PFG_Util.USER_ROLE_DM;
      isRM = userRole==GNE_SFA2_PFG_Util.USER_ROLE_RM;
      isBrandManager = isDM || isRM;
      isManager = userRole==GNE_SFA2_PFG_Util.USER_ROLE_MANAGER;
      csNodesCounter = 1;

      quantity = origQuantity = 0;
      newManagerQuantity = 0;
      nodeId = (a_parent!=null ? a_parent.userOrTerritoryId : null) + '_' + userOrTerritoryId;

      if((trxRec = getTransaction())!=null) {
      	quantity += trxRec.Requested_Quantity_gne__c.intValue();
      	trxRefNo = trxRec.Transaction_Ref_Number_gne__c;
      	trxRec = null;
      }

      if(a_parent!=null) {
        a_parent.addChild(this);
      }

      if(a_ytdAllocatedQty!=null && a_totalAvailableQty!=null) {
        ytdAllocatedQty = a_ytdAllocatedQty;
        quantity += a_totalAvailableQty;
      } else {
        ytdAllocatedQty = 0;
      }

      remainingQuantity = 0;
      origQuantity = quantity;
      setAvailableQuantity(quantity);
      isTransactionChanged = false;
    }

    public UserQuantityNode(Territory2 terr, String a_role, UserQuantityNode a_parent, Id prodId, Integer year) {
      this(terr.Id,terr.Name,a_role,a_parent,null,null,prodId, year);

      if(prodId!=null) {
      	SFA2_PFG_to_Territory_Detail_gne__c tDetail = GNE_SFA2_PFG_Util.getPfgToTerritoryDetail(terr.Name, prodId, year);

        if(tDetail!=null) {
      		remainingQuantity  = tDetail.Qty_Total_Available_gne__c.intValue();
      		setAvailableQuantity(remainingQuantity);
      	}
      }

    }

	private SFA2_PFG_Transaction_gne__c getTransaction() {
    	if(trxRec==null) {
	    	UserQuantityNode parent = getParent();

	    	for(SFA2_PFG_Transaction_gne__c trx : GNE_SFA2_PFG_Util.getPfgAllocationTransaction(
	                            (parent!=null ? parent.userOrTerritoryId : null), userOrTerritoryId)) {
	        	if(trx.Generate_Shipment_Flag__c == null || trx.Generate_Shipment_Flag__c == GNE_SFA2_PFG_Util.TRANSACTION_SHIPMENT_NOT_INITIATED) {
	          		trx.Requested_Quantity_gne__c += quantity-origQuantity;
	          		trxRec = trx;
	          		break;
	        	}
			}
		}

    	return trxRec;
    }

    private UserQuantityNode getParent() {
    	return parentId!=null ? getUserQuantityNode(parentId) : null;
    }

    private void setAvailableQuantity(Integer qty) {
    	if(availableQuantity==null) {
    		availableQuantity = 0;
    	}

    	availableQuantity += qty;
    }

    private void populateTransactionTerritoryFields() {
      String hoVirtualTerrName = GNE_SFA2_PFG_Util.getHoTerritoryId();

      if(isManager) {
        trxRec.To_User_Territory_gne__c = hoVirtualTerrName;
        trxRec.To_Territory_Name_gne__c = hoVirtualTerrName;
      } else {
      	Territory2 terr = GNE_SFA2_PFG_Util.getTerritory((Id)userOrTerritoryId);
        trxRec.To_User_gne__c = null;
        trxRec.To_User_Territory_gne__c = terr.Id;
        trxRec.To_Territory_Number_gne__c = terr.Territory_Number_gne__c;
        trxRec.To_Territory_Name_gne__c = terr.Name;
      }

      if(isRM) {
        trxRec.From_User_Territory_gne__c = hoVirtualTerrName;
        trxRec.From_Territory_Name_gne__c = hoVirtualTerrName;
      } else if(isDM || isCS) {
      	UserQuantityNode parent = getParent();
      	Territory2 parentTerr = GNE_SFA2_PFG_Util.getTerritory((Id)parent.userOrTerritoryId);

      	if(parentTerr==null) {
      		parentTerr = GNE_SFA2_PFG_Util.getTerritoryForUser((Id)parent.userOrTerritoryId);
      	}

        trxRec.From_User_gne__c = null;
        trxRec.From_User_Territory_gne__c = parentTerr.Id;
        trxRec.From_Territory_Number_gne__c = parentTerr.Territory_Number_gne__c;
        trxRec.From_Territory_Name_gne__c = parentTerr.Name;
      }

      // Reverse From and To Territories
      if(trxRec.Requested_Quantity_gne__c < 0) {
      	trxRec.Requested_Quantity_gne__c = -trxRec.Requested_Quantity_gne__c;
      	String prevTerrId = trxRec.From_User_Territory_gne__c;
      	String prevTerrNumber = trxRec.From_Territory_Number_gne__c;
      	String prevTerrName = trxRec.From_Territory_Name_gne__c;
      	String prevUserId = trxRec.From_User_gne__c;

      	trxRec.From_User_Territory_gne__c = trxRec.To_User_Territory_gne__c;
        trxRec.From_Territory_Number_gne__c = trxRec.To_Territory_Number_gne__c;
        trxRec.From_Territory_Name_gne__c = trxRec.To_Territory_Name_gne__c;
        trxRec.From_User_gne__c = trxRec.To_User_gne__c;

        trxRec.To_User_Territory_gne__c = prevTerrId;
        trxRec.To_Territory_Number_gne__c = prevTerrNumber;
        trxRec.To_Territory_Name_gne__c = prevTerrName;
        trxRec.To_User_gne__c = prevUserId;
      }
    }

    private void addChild(UserQuantityNode child) {
      child.parentId = nodeId;

      if(childIds==null) {
      	childIds = new List<String>();
      }

      if(!childIds.isEmpty()) {
        UserQuantityNode prevChild = getUserQuantityNode(childIds.get(childIds.size()-1));
        prevChild.nextSiblingId = child.nodeId;
        child.prevSiblingId = prevChild.nodeId;
      } else {
      	csNodesCounter = 0;
      }
      // Make sure it is not less than 0
      setAvailableQuantity(-Math.min(availableQuantity,child.quantity));
      childIds.add(child.nodeId);
      increaseCsNodesCounter(child);
    }

    private void increaseCsNodesCounter(UserQuantityNode child) {
    	csNodesCounter += child.csNodesCounter;
    	UserQuantityNode parent = getParent();

    	if(parent!=null && csNodesCounter>1) {
    		parent.increaseCsNodesCounter(child);
    	}
    }

    private Map<String,UserQuantityNode> buildChildNodes(String pfgType, Map<String, Set<String>> salesforceCodes, Id prodId, Integer year) {
    	Map<String,UserQuantityNode> childNodesMap = new Map<String,UserQuantityNode>();

    	if(pfgType==GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC) {
    		if(GNE_SFA2_PFG_Util.usersHierarchyCache!=null && GNE_SFA2_PFG_Util.usersHierarchyCache.containsKey((Id)userOrTerritoryId)) {
          		Map<String,SFA2_User_Sales_Roster_gne__c> childUsers = new Map<String,SFA2_User_Sales_Roster_gne__c>();

          		// 1. Get child user Sales Rosters
          		for(Id childId : GNE_SFA2_PFG_Util.usersHierarchyCache.get((Id)userOrTerritoryId)) {
            		SFA2_User_Sales_Roster_gne__c salesRoster = GNE_SFA2_PFG_Util.getSalesRosterForUser(childId);
            		childUsers.put(salesRoster.User_gne__r.Name,salesRoster);
          		}

          		// 2. Sort them by User Name
          		List<String> userNames = new List<String>(childUsers.keySet());
          		userNames.sort();

          		// 3. Create list of child nodes
          		for(String userName : userNames) {
            		SFA2_User_Sales_Roster_gne__c salesRoster = childUsers.get(userName);
            		UserQuantityNode childNode = new UserQuantityNode(salesRoster.User_gne__c, salesRoster.User_gne__r.Name, salesRoster.Role_gne__c, this, null, null, prodId, year);
            		childNodesMap.put(childNode.nodeId, childNode);
            		userNodesMapStatic.put(childNode.nodeId, childNode);
            		childNodesMap.putAll(childNode.buildChildNodes(pfgType, salesforceCodes, prodId, year));
          		}
        	}
      	} else if(pfgType==GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP && salesforceCodes != null && !salesforceCodes.isEmpty()) {
        	List<Territory2> childTerritories = null;

        	if(isManager) {
          		childTerritories = new List<Territory2>(GNE_SFA2_PFG_Util.getChildTerritoriesBySalesforceCodes(salesforceCodes));
        	} else if(isBrandManager && parentId==null) {
          		Territory2 terr = GNE_SFA2_PFG_Util.getFirstTerritoryForUserBySalesforceCodes(userOrTerritoryId, salesforceCodes);
          		if (terr != null){
          			childTerritories = new List<Territory2>(GNE_SFA2_PFG_Util.getChildTerritoriesForUserBySalesforceCodes(userOrTerritoryId, salesforceCodes));
          		}
        	} else {
          		childTerritories = new List<Territory2>(GNE_SFA2_PFG_Util.getChildTerritoriesBySalesforceCodes(userOrTerritoryId, salesforceCodes));
        	}

        	if (childTerritories != null){
        		childTerritories.sort();
        		for(Territory2 terr : childTerritories) {
          			UserQuantityNode childNode = new UserQuantityNode(terr, (isManager ? GNE_SFA2_PFG_Util.USER_ROLE_RM : (isRM ? GNE_SFA2_PFG_Util.USER_ROLE_DM : GNE_SFA2_PFG_Util.USER_ROLE_CS)), this, prodId, year);
          			childNodesMap.put(childNode.nodeId, childNode);
          			userNodesMapStatic.put(childNode.nodeId, childNode);
          			childNodesMap.putAll(childNode.buildChildNodes(pfgType, salesforceCodes, prodId, year));
        		}
        	}
      	}

      	return childNodesMap;
    }

    private List<UserQuantityNode> getChildren() {
    	List<UserQuantityNode> children = new List<UserQuantityNode>();

    	if(childIds!=null) {
	    	for(String childId : childIds) {
	    		children.add(getUserQuantityNode(childId));
	    	}
    	}

    	return children;
    }

    public List<UserQuantityNode> getTransactionNodesToUpsert() {
      List<UserQuantityNode> result = new List<UserQuantityNode>();
      if(isTransactionChanged) {
        result.add(this);
      }

      for(UserQuantityNode child : getChildren()) {
        result.addAll(child.getTransactionNodesToUpsert());
      }

      return result;
    }

    public List<SFA2_PFG_Transaction_gne__c> getTransactionsToUpsert(String pfgType) {
      List<SFA2_PFG_Transaction_gne__c> result = new List<SFA2_PFG_Transaction_gne__c>();

      for(UserQuantityNode node : getTransactionNodesToUpsert()) {
      	SFA2_PFG_Transaction_gne__c trx = node.getTransaction();

      	if(trx.Requested_Quantity_gne__c != 0) {
	      	if(pfgType==GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP) {
	        	node.populateTransactionTerritoryFields();
	        }

	        result.add(trx);
      	}
      }

      return result;
    }

    public List<SFA2_PFG_Transaction_gne__c> getTransactionsToDelete() {
      List<SFA2_PFG_Transaction_gne__c> result = new List<SFA2_PFG_Transaction_gne__c>();

      for(UserQuantityNode node : getTransactionNodesToUpsert()) {
      	SFA2_PFG_Transaction_gne__c trx = node.getTransaction();

        if(trx.Id!=null && trx.Requested_Quantity_gne__c == 0) {
          result.add(trx);
        }
      }

      return result;
    }

    public Boolean isSomethingChanged() {
      Boolean somethingChanged = isTransactionChanged;

      for(UserQuantityNode child : getChildren()) {
        somethingChanged = somethingChanged || child.isSomethingChanged();
      }

      return somethingChanged;
    }

    public Map<String,UserQuantityNode> getUserNodesMap() {
      Map<String,UserQuantityNode> allNodes = new Map<String,UserQuantityNode> {nodeId => this};
      for(UserQuantityNode child : getChildren()) {
        allNodes.putAll(child.getUserNodesMap());
      }

      return allNodes;
    }

    public List<SalesRepWrapper> convertToSalesRepWrappers() {
      List<SalesRepWrapper> salesReps = new List<SalesRepWrapper>();

      if(userRole == GNE_SFA2_PFG_Util.USER_ROLE_CS) {
      	UserQuantityNode dmParent = getParent();
      	UserQuantityNode rmParent = dmParent!=null ? dmParent.getParent() : null;
      	rmParent = rmParent!=null && rmParent.isRM ? rmParent : null;

      	salesReps.add(new SalesRepWrapper(
      			(rmParent!=null ? rmParent.nodeId : null), (dmParent!=null ? dmParent.nodeId : null), nodeId,
      			(rmParent!=null ? dmParent.prevSiblingId==null : false), prevSiblingId==null));
      } else if (isDM && (childIds==null || childIds.isEmpty())) {
      	UserQuantityNode rmParent = getParent();
      	rmParent = rmParent!=null && rmParent.isRM ? rmParent : null;
        salesReps.add(new SalesRepWrapper(
        		(rmParent!=null ? rmParent.nodeId : null), nodeId, null,
        		(rmParent!=null ? prevSiblingId==null : false), true));
      } else if (isRM && (childIds==null || childIds.isEmpty())) {
      	salesReps.add(new SalesRepWrapper(
        		nodeId, null, null,
        		true, false));
      } else {
        for(UserQuantityNode child : getChildren()) {
          salesReps.addAll(child.convertToSalesRepWrappers());
        }
      }

      return salesReps;
    }

    public String getTransactionRefNo() {
      String result = null;
      if(String.isNotBlank(trxRefNo)) {
        result = trxRefNo;
      } else {
        for(UserQuantityNode child : getChildren()) {
          result = child.getTransactionRefNo();

          if(result!=null) {
            break;
          }
        }
      }

      return result;
    }
  }

  public class SalesRepWrapper {
  	@TestVisible private String rmId;
    @TestVisible private String dmId;
    @TestVisible private String nodeId;
    @TestVisible private Boolean showRMLabel;
    @TestVisible private Boolean showDMLabel;

    public SalesRepWrapper(String a_rmId, String a_dmId, String a_nodeId, Boolean a_showRMLabel, Boolean a_showDMLabel) {
      rmId = a_rmId;
      dmId = a_dmId;
      nodeId = a_nodeId;
      showRMLabel = a_showRMLabel && a_showDMLabel;
      showDMLabel = a_showDMLabel;
    }
  }

  public class InitPage_Exception extends Exception {}
}