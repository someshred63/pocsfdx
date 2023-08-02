public with sharing class GNE_SFA2_MyTargets_Controller {
	
	public static final Integer RECORDS_LIMIT = 2000;

	public List<SelectOption> territoriesSelectOptions {get; set;}
	public List<SelectOption> accountViewsSelectOptions {get; set;}
	public String territoryId{get; set;}
	public SFA2_View_Config_gne__c selectedView {get; set;}
	private SFA2_Configuration_Object_gne__c pageConfiguration;

	public String selectedViewId {get; set;}
	public List<ViewWrapper> viewWrappers {get; set;}
	public List<String> viewColumns {get; set;}
	public Map<String, String> columnsHeaders {get; set;}
	public Map<String, String> columnsHeadersType {get; set;}
	private Map<String, Id> recordTypeNameToId = new Map<String, Id>();

	public Integer pageNumber {get; set;}
	public String sortColumn {get; set;}
	public String sortDirection {get; set;}
	public Integer recordsCount{get; set;}
	public Integer offset {get; set;}
	private Integer remainingOffset {get; set;}

	private Set<String> objectsToQuery;
	private List<String> accountFilterColumns;
	private List<String> addressFilterColumns;
	private List<String> tsfFilterColumns;

	private Set<String> brandsInFilters;
	private List<String> brandsInFiltersList;
	private Set<String> productsInViewColumns;
	private Map<Id, Product_vod__c> productIdToProduct;

	public Integer PAGE_SIZE {get; set;}
	private SFA2_User_Preferences_gne__c myPreferences;
	private GNE_SFA2_User_App_Context_gne__c userAppContext = GNE_SFA2_Util.getUserApplicationContext();
	private GNE_SFA2_My_Accounts_Setttings__c settings;
	private Boolean isAllSelected;

	public Boolean userTerritoriesExist {get; set;}

	public List<Account> selectedAccounts {get; set;}
	public Long executingTime {get; set;}
    private Set<Id> filterdAccountIds = new Set<Id>();

	// Export to excel
	public transient List<ViewWrapper> viewWrappersInExport {get; set;}
	public transient List<String> viewColumnsInExport {get; set;}
	public transient Map<String, String> columnsHeadersInExport {get; set;}
	public transient SFA2_View_Config_gne__c selectedViewInExport {get; set;}
	public Boolean containsBrandAffiliationColumn {get; set;}
	public String filterLetter {get; set;}
	public Map<String,String> fieldReferenceToExportMap {get;set;}
	public Map<String,Boolean> fieldReferenceToExportHasExist {get;set;}
	private Boolean isExportToExcel = false;

	// Mass update
	public String selectedRecordName { get; set; }
	public String selectedProduct { get; set; }
	public String selectedFieldName { get; set; }
	public String newValue { get; set; }

	// Override User Lookup
	public Map<String,String> fieldOfUserReferenceMap {get;set;}
	public Map<String,Boolean> userReferenceHasExist {get;set;}

	// temp
	public String userIdToViewLink {get; set;}

	// TSF_vod__c relations names
	private String tsfToAccountRelName;
	private String tsfToAddressRelName;

	public String massUpdateMessage {get; set;}
	public Boolean isMedAffair{get; private set;}

	private static Map<Id, List<Id>> userMySetupProductsMap;

	// Map of territories names available to use by user for account alignment
	private static Map<Id, Set<String>> userTargetTerritoriesNamesMap;

	private static Pattern myHCPsViewNamePattern = Pattern.compile('^.(?i)My HCP.s');
    private Map<Id, ViewWrapper> viewWrappersToSubmit;
    public Boolean submitButtonVisible {get;set;}
    public String wrapperAsJson {get;set;}

	public GNE_SFA2_MyTargets_Controller(){
		this(false);
	}

	public GNE_SFA2_MyTargets_Controller(Boolean isExportToExcel){
		this.isExportToExcel = isExportToExcel;

		pageConfiguration = GNE_SFA2_Util.getListPageConfiguration('Account_MyTarget');
		GNE_SFA2_User_App_Context_gne__c userContext = GNE_SFA2_Util.getUserApplicationContext();
		isMedAffair = userContext.App_Name_gne__c == 'MedAffairs';
        viewWrappers = new List<ViewWrapper>{new ViewWrapper(), new ViewWrapper(), new ViewWrapper()};
		try{
			settings = [ SELECT PageSize_gne__c, Roles_With_Territory_Hierarchy_gne__c FROM GNE_SFA2_My_Accounts_Setttings__c WHERE Application_Type__c = :GNE_SFA2_Application_Cache.userApplicationContext.App_Name_gne__c AND Brand_gne__c = :GNE_SFA2_Application_Cache.userApplicationContext.Brand_gne__c AND Role_gne__c = :GNE_SFA2_Application_Cache.userApplicationContext.Role_gne__c ];
		} catch(Exception e) {
			settings = new GNE_SFA2_My_Accounts_Setttings__c(PageSize_gne__c=50, Privileged_Profiles_gne__c='');
		}
		PAGE_SIZE = settings.PageSize_gne__c.intValue();

		try{
			myPreferences = [ SELECT Last_View_Used_gne__c, Last_Territory_Used_gne__c FROM  SFA2_User_Preferences_gne__c WHERE Last_View_Used_gne__r.Page_Name_gne__c = 'My Targets' AND User_gne__c = :Userinfo.getUserId() LIMIT 1 ];
		} catch(Exception e){
			myPreferences = new SFA2_User_Preferences_gne__c(User_gne__c = UserInfo.getUserId());
		}

		try{
			initializePageVariables();
			initialazeControllerVariables(territoryId, selectedView);
		}catch (Exception e){
			viewWrappers = new List<ViewWrapper>();
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error during record loading. Please redefine selected view'));
			ApexPages.addMessages(e);
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getStackTraceString()));
			System.debug(e);
		}
	}

	public PageReference loadRecords() {
		upsert myPreferences;
		isAllSelected = false;
		offset = 0;
		pageNumber = 1;
		remainingOffset = 0;
		if(!String.isEmpty(selectedViewId)) {
			viewWrappers = getViewWrapers(selectedView, territoryId, true);
		} else {
			viewWrappers = new List<ViewWrapper>();
		}
		return null;
	}

	private void initializePageVariables(){
		sortDirection = 'ASC';
		filterLetter = 'All';

		tsfToAccountRelName = TSF_vod__c.Account_vod__c.getDescribe().getRelationshipName();
		tsfToAddressRelName = TSF_vod__c.Address_vod__c.getDescribe().getRelationshipName();

		// query views and territories
		List<SFA2_View_Config_gne__c> myAccountViews = getViews();
		List<Territory2> userTerritories = getUserTerritories(UserInfo.getUserId());

		Set<Id> userTerritoriesIds = new Set<Id>();
		for(Territory2 terr : userTerritories) {
			userTerritoriesIds.add(terr.Id);
		}

		userTerritoriesExist = false;
		if(userTerritories != null && userTerritories.size() > 0) {
			userTerritoriesExist = true;
		}

		// prepare views and territories select options
		accountViewsSelectOptions = prepareSelectOptions(myAccountViews);
		territoriesSelectOptions = prepareSelectOptions(userTerritories);

		if(!myAccountViews.isEmpty()){
			if(myPreferences.Last_View_Used_gne__c == null){
				myPreferences.Last_View_Used_gne__c = myAccountViews.get(0).id;
			}
			selectedView = getView(myPreferences.Last_View_Used_gne__c);
			selectedViewId = selectedView.Id;
		}

		if(!userTerritories.isEmpty()){
			if(String.isEmpty(myPreferences.Last_Territory_Used_gne__c) || (!String.isEmpty(myPreferences.Last_Territory_Used_gne__c) && !userTerritoriesIds.contains(myPreferences.Last_Territory_Used_gne__c))){
				myPreferences.Last_Territory_Used_gne__c = userTerritories.get(0).id;
			}
			territoryId = myPreferences.Last_Territory_Used_gne__c;
		}
	}

	private void initialazeControllerVariables(String territoryName, SFA2_View_Config_gne__c selectedView){
		isAllSelected = false;
		recordsCount = 0;
		offset = 0;
		pageNumber = 1;
		remainingOffset = 0;
		/*Read view configuration*/
		// determine displayed columns basing on the selected view
		if(!String.isEmpty(selectedViewId)) {
			initializeAccountRecordTypes();
			containsBrandAffiliationColumn = false;
			viewColumns = getViewColumnsBySelectedView(selectedView);
			prepareFieldReferenceMaps(viewColumns);
			columnsHeaders = getViewColumnsHeaders(viewColumns);
			columnsHeadersType = getViewColumnsHeadersType(viewColumns);
			accountFilterColumns = getFilterColumnsBySelectedView(selectedView, 'Account');
			addressFilterColumns = getFilterColumnsBySelectedView(selectedView, 'Address');
			tsfFilterColumns = getFilterColumnsBySelectedView(selectedView, 'TSF');
			sortColumn = getSortColumnBySelectedView(selectedView);
			objectsToQuery = getObjectsToQueryByAllColumns(viewColumns, accountFilterColumns, addressFilterColumns, sortColumn);
		}
	}

	private void initializeAccountRecordTypes(){
		Map<Id, Schema.RecordTypeInfo> recordTypeInfos = Schema.SObjectType.Account.getRecordTypeInfosByID();
		for(RecordType rt : [ SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Account' ]){
			recordTypeNameToId.put(rt.DeveloperName, rt.Id);
		}
	}

	private List<String> getRecordTypesIds(List<String> recordTypesNames){
		List<String> result = new List<String>();
		for(String recordTypeName : recordTypesNames){
			if (recordTypeNameToId.containsKey(recordTypeName.trim())){
				result.add(recordTypeNameToId.get(recordTypeName.trim()));
			}
		}
		return result;
	}

	private List<String> getTerritoriesHierarchicalNames(String territoryId){
		List<String> result = new List<String>();
		if (String.isNotBlank(territoryId)){
			List<Territory2> parent = new List<Territory2>([Select Id, Name From Territory2 Where Id = :territoryId]);
			if (parent.size() > 0){
				Set<Territory2> childrens = new Set<Territory2>();
				getChildrenTerritories(parent, childrens);
				result.add(parent.get(0).Name);
				if (childrens.size() > 0){
					for (Territory2 children : childrens){
						result.add(children.Name);
					}
				}
			}
		}
		return result;
	}

	private String getTsfWhereCondition(List<String> territoriesNames, List<String> recordTypes, SFA2_View_Config_gne__c selectedView){
		String qin = GNE_SFA2_Util.createInListForQueryNotEscaping(territoriesNames);
		String query = ' Territory_vod__c In '+ qin;

		for (String tsfStatement : new Set<String>{'Address_vod__c <> null', 'Account_vod__c <> null', 'External_Id_vod__c <> null'}){
			if (!query.containsIgnoreCase(tsfStatement)){
				query += getFilterStatement(tsfStatement);
			}
		}

		if (accountFilterColumns != null && accountFilterColumns.size() > 0){
			for(String filterColumn : accountFilterColumns){
				if(filterColumn.trim().startsWith('(NOT')){
					query += ' AND (NOT ' + tsfToAccountRelName + '.' + filterColumn.trim().removeStart('(NOT ');
				} else {
					query += ' AND ' + tsfToAccountRelName + '.' + filterColumn;
				}
			}
		}

		if (addressFilterColumns != null && addressFilterColumns.size() > 0){
			for (String filterColumn : addressFilterColumns){
				if(filterColumn.trim().startsWith('(NOT')){
					query += ' AND (NOT ' + tsfToAddressRelName + '.' + filterColumn.trim().removeStart('(NOT ');
				} else {
					query += ' AND ' + tsfToAddressRelName + '.' + filterColumn;
				}
			}
		}

		if(String.isNotBlank(filterLetter) && filterLetter != 'All'){
			query += ' AND ((' + tsfToAccountRelName + '.Name like \''+filterLetter+'%\' AND ' + tsfToAccountRelName + '.isPersonAccount = false) OR (' + tsfToAccountRelName + '.LastName like \''+filterLetter+'%\' AND ' + tsfToAccountRelName + '.isPersonAccount = true)) ';
		}

		if(!recordTypes.isEmpty()){
			query += ' AND ' + tsfToAccountRelName + '.RecordTypeId In '+GNE_SFA2_Util.createInListForQuery(getRecordTypesIds(recordTypes));
		}

		Boolean isCanadaMyTargetView = GNE_SFA2_Util.isCanadaUser() && selectedView.Visibility_gne__c != 'private' && String.isNotBlank(selectedView.View_Name_gne__c) && myHCPsViewNamePattern.matcher(selectedView.View_Name_gne__c).matches();
		if (isCanadaMyTargetView == true){
			query += getMyTargetAndTiersTsfQueryCondition(territoriesNames);
		}

		return query;
	}

	/* If true all child accounts are included in the My Hcp view */
	public static Boolean hasExtendedMyHcpByTargetAndTiersView(String userProfileName){
		return userProfileName == 'RCanada-SFA-Manager';
	}

	/* Method being in use by the OTR web services: iPhone_Get_User_Accounts_gne and iPhone_Get_Account_TerritoryFields_gne */
	public static String getMyTargetAndTiersTsfQueryCondition(List<String> territoriesNames){
		Set<String> userTargetTerrNames;
		if (hasExtendedMyHcpByTargetAndTiersView(GNE_SFA2_Util.getCurrentUserProfileName())){
			userTargetTerrNames = new Set<String>(territoriesNames);
		} else {
			userTargetTerrNames = getUserTargetTerritoriesNames(UserInfo.getUserId());
			userTargetTerrNames.retainAll(territoriesNames);
		}

		String targetTerritoriesNamesStr = GNE_SFA2_Util.createInListForQueryNotEscaping(new List<String>(userTargetTerrNames));
		String productIdsStr = GNE_SFA2_Util.createInListForQuery(getUserMySetupProductsIds(UserInfo.getUserId()));

		String tntQuery = String.format('SELECT Territory_Field_parent_gne__c FROM Targets_and_Tiers_can_gne__c ' +
			'WHERE Territory_gne__c In {0} AND Product_Catalog_gne__c In {1} ' +
			'AND (My_Target_gne__c <> null OR Target_gne__c <> null OR Segment_gne__c <> null OR Tier_can_gne__c <> null)',
			new String[] {
				targetTerritoriesNamesStr,
				productIdsStr
			}
		);
		return ' AND Territory_vod__c In ' + targetTerritoriesNamesStr + ' AND Id In (' + tntQuery + ') ';
	}

	/* Map of territories names available to use by user for account alignment.
	 * Need to be extended In case of MedAffairs users (not being in use actually - see GNE_SFA2_Territory_Alignment_Ext.UserContext.getUserTerritoriesMap()). */
	private static Set<String> getUserTargetTerritoriesNames(Id userId){
		if (userTargetTerritoriesNamesMap == null){
			userTargetTerritoriesNamesMap = new Map<Id, Set<String>>();
		}
		if (!userTargetTerritoriesNamesMap.containsKey(userId)){
			Set<String> targetTerritoriesNames = new Set<String>();
			for (Territory2 territory : [SELECT Name FROM Territory2 WHERE Id in (SELECT Territory2Id FROM UserTerritory2Association WHERE UserId = :userId) ORDER BY Name]){
				targetTerritoriesNames.add(territory.Name);
			}
			userTargetTerritoriesNamesMap.put(userId, targetTerritoriesNames);
		}
		return userTargetTerritoriesNamesMap.get(userId);
	}

	/* Get the list of user my setup products ids */
	private static List<Id> getUserMySetupProductsIds(Id userId){
		if (userMySetupProductsMap == null){
			userMySetupProductsMap = new Map<Id, List<Id>>();
		}
		if (!userMySetupProductsMap.containsKey(userId)){
			List<Id> productIds = new List<Id>();
			Integer userRegionCode = GNE_SFA2_Util.isCanadaUser() ? 2 : 1;
			for (Product_vod__c userProduct : [SELECT Id FROM Product_vod__c WHERE Product_Type_vod__c = 'Detail' AND (Detail_Product_Subtype_Code_gne__c != 'Molecule' AND Detail_Product_Subtype_Code_gne__c != 'TheraDisease')
					AND Region_Code_gne__c = :userRegionCode AND Id IN (SELECT Product_vod__c FROM My_Setup_Products_vod__c WHERE OwnerId = :userId)]){
				productIds.add(userProduct.Id);
			}
			userMySetupProductsMap.put(userId, productIds);
		}
		return userMySetupProductsMap.get(userId);
	}

	public String countQuery{
		get;
		private set {
			if (value != null){
				countQuery = value.replace('\'', '\\\'');
			}
		}
	}

	@RemoteAction
	@ReadOnly
	public static Integer retrieveQueryCount(String query){
		String countQuery = query.replace('\\\'', '\'');
		List<AggregateResult> aggr = Database.query(countQuery);
		Integer counter = Integer.valueOf(aggr.size());
		return counter;
	}

	/* Retrieve all account Ids from given territory, filtered by filters on TSF, Account, Address and Brand Affiliation objects.
	Total count of records is calculated using java script remoting request in calculateRecordsCount vf page method.
	Tsf query limited -> offset works only on collection less or equal 2000 records (PAGE_SIZE) */
	private Set<Id> getAccountsIdsByTerritory(String tsfWhereCondition){
		Set<Id> accounts = new Set<Id>();
		String tsfQuery = 'SELECT Account_vod__c FROM TSF_vod__c WHERE ' + tsfWhereCondition;

		
		if (sortColumn.startsWith('Account') || sortColumn.startsWith('Address') || sortColumn.startsWith('TSF')){
			String sortColumnParent, sortStatement = '';
			if (sortColumn.startsWith('Account')){
				sortColumnParent = tsfToAccountRelName;
			} else if (sortColumn.startsWith('Address')){
				sortColumnParent = tsfToAddressRelName;
			}
			if (String.isNotBlank(sortColumnParent)){
				sortStatement += sortColumnParent + '.';
			}
			sortStatement += sortColumn.substring(sortColumn.indexOf('.') + 1)+ ' '+sortDirection + setNullsBySortDirection();
			tsfQuery += ' ORDER BY ' + sortStatement;
		}

		for (TSF_vod__c tsf : Database.query(tsfQuery)){
			accounts.add(tsf.Account_vod__c);
		}		

		return accounts;
	}

	public List<ViewWrapper> getViewWrapers(SFA2_View_Config_gne__c selectedView, String territoryId, Boolean forward){
		List<ViewWrapper> result = new List<ViewWrapper>();
        
		String tsfWhereCondition = getTsfWhereCondition(getTerritoriesHierarchicalNames(territoryId), getRecordTypes(selectedView), selectedView);
		Set<Id> accounts = getAccountsIdsByTerritory(tsfWhereCondition);
        filterdAccountIds = new Set<Id>();
        String territoryName = [SELECT Name FROM Territory2 WHERE Id = :territoryId].Name;
        Set <Id> accountsWithInterractionInCurrentYear = new Set<Id>();
        Map<Id, Integer> accountId2NumberOfInteraction = new Map<Id, Integer>();
        for(Call2_vod__c cv :[
            SELECT Account_vod__c 
            FROM Call2_vod__c
            WHERE Account_vod__c IN : accounts
            	AND Date_of_Interaction_gne__c = THIS_YEAR
            	AND Territory_New_Name_gne__c = :territoryName
        ]){
            accountsWithInterractionInCurrentYear.add(cv.Account_vod__c);
            Integer numOfInter = accountId2NumberOfInteraction.get(cv.Account_vod__c) == null ? 1 : accountId2NumberOfInteraction.get(cv.Account_vod__c) + 1;
            accountId2NumberOfInteraction.put(cv.Account_vod__c, numOfInter);
            
        }
        List<Id> productIdsStr = getUserMySetupProductsIds(UserInfo.getUserId());
        Targets_and_Tiers_can_gne__c[] tats = [
            SELECT Product_Catalog_gne__r.Name, Account_can_gne__c, Account_can_gne__r.Name, Target_gne__c, My_Target_gne__c, Access_Rating__c, HCO_Account__r.Name, Submitted_DataTime_gne__c 
            FROM Targets_and_Tiers_can_gne__c 
            WHERE Account_can_gne__c IN : accounts
            	AND Territory_gne__c = :territoryName
            	AND Product_Catalog_gne__c IN : productIdsStr
            	AND (
                    (Target_gne__c = null AND My_Target_gne__c != 'Non-Target'  AND My_Target_gne__c != null) 
                     OR Target_gne__c != null 
                     OR (Target_gne__c = null AND My_Target_gne__c = null AND Account_can_gne__c IN :accountsWithInterractionInCurrentYear)
                )
        ];
        for(Targets_and_Tiers_can_gne__c tat :tats){
            filterdAccountIds.add(tat.Account_can_gne__c);
        }        	

		if(accounts.isEmpty()){
			return result;
		}
		String tsfSelectStatement = getTsfSelectStatementByViewColumns();

		/*Order by TSF field*/
		if(sortColumn.startsWith('TSF') || sortColumn.startsWith('Account') || sortColumn.startsWith('Address')){
			List<TSF_vod__c> tsfes = getSortedTSFsByViewColumns(PAGE_SIZE, offset, tsfSelectStatement, tsfWhereCondition);
			List<String> sortedPrepFieldValues = new List<String>();
			Map<String,Set<Id>> sortedPrepFieldValueToAccIdMap = new Map<String,Set<Id>>();
			Map<Id, List<TargetContainer>> products = getProductForAccount(tats);

			result = prepareWrappers(tsfes, products, accountId2NumberOfInteraction);			
		}
		
		return result;
	}

	private Map<Id, List<TargetContainer>> getProductForAccount(Targets_and_Tiers_can_gne__c[]  targets) {		
		Map<Id, List<TargetContainer>> result = new Map<Id, List<TargetContainer>>();
		if(targets != null && targets.size() > 0) {
			for(Targets_and_Tiers_can_gne__c target : targets) {
				if(target != null && target.Product_Catalog_gne__c != null && target.Account_can_gne__c != null) {
					String productName = target.Product_Catalog_gne__r.Name;
                    List<TargetContainer> targetContainers = result.containsKey(target.Account_can_gne__c) ? result.get(target.Account_can_gne__c) : new List<TargetContainer>();
                    targetContainers.add(new TargetContainer(productName, target.Target_gne__c, target.My_Target_gne__c, target.Access_Rating__c, target.HCO_Account__r.Name, target));
                    result.put(target.Account_can_gne__c, targetContainers);
				}
			}	
		}
		return result;
	}

	private List<ViewWrapper> prepareWrappers(List<TSF_vod__c> tsfes, Map<Id, List<TargetContainer>> accountProducts, Map<Id, Integer> accountId2NumberOfInteraction){
		List<ViewWrapper> viewWrappers = new List<ViewWrapper>();
        viewWrappersToSubmit = new Map<Id, ViewWrapper>();
		if(tsfes != null && tsfes.size() > 0){
			for(TSF_vod__c tsf : tsfes){
				List<TargetContainer> containers = accountProducts.get(tsf.Account_vod__c);
				if(containers != null) {
                    ViewWrapper newRow = new ViewWrapper(tsf.Account_vod__c, tsf.Account_vod__r, tsf);
                    newRow.setProductTargets(containers);
                    newRow.ytdInteractions = accountId2NumberOfInteraction.get(tsf.Account_vod__c) == null ? 0 : accountId2NumberOfInteraction.get(tsf.Account_vod__c);
					viewWrappers.add(newRow);
					if(!newRow.submited){
                        viewWrappersToSubmit.put(newRow.accountId, newRow);
                        submitButtonVisible = true;
                    }
                } else {
                    ViewWrapper newRow = new ViewWrapper(tsf.Account_vod__c, tsf.Account_vod__r, tsf);
                    viewWrappers.add(newRow);                    
                }
			}
			viewWrappers.sort();
		}
		return viewWrappers;
	}

	private String setNullsBySortDirection(){
		return sortDirection == 'DESC' ? ' NULLS LAST ' : ' NULLS FIRST ';
	}

	// Override Link When Field Has User Reference
	public void prepareFieldReferenceMaps(List<String> viewColumns) {

		fieldOfUserReferenceMap = new Map<String,String>();
		userReferenceHasExist = new Map<String,Boolean>();
		fieldReferenceToExportMap = new Map<String,String>();
		fieldReferenceToExportHasExist = new Map<String,Boolean>();

		// Account Global Describe Map
		Map<String,Schema.SObjectType> accountGlobalDescribeMap = Schema.getGlobalDescribe();
		Schema.SObjectType accountsObjectType = accountGlobalDescribeMap.get('Account');
		Schema.DescribeSObjectResult accountResult = accountsObjectType.getDescribe();
		Map<String,Schema.SObjectField> accountObjectFieldMap = accountResult.fields.getMap();

		// Address Global Describe Map
		Map<String,Schema.SObjectType> addressGlobalDescribeMap = Schema.getGlobalDescribe();
		Schema.SObjectType addresssObjectType = addressGlobalDescribeMap.get('Address_vod__c');
		Schema.DescribeSObjectResult addressResult = addresssObjectType.getDescribe();
		Map<String,Schema.SObjectField> addressObjectFieldMap = addressResult.fields.getMap();


		// TSF Global Describe Map
		Map<String,Schema.SObjectType> tsfGlobalDescribeMap = Schema.getGlobalDescribe();
		Schema.SObjectType tsfsObjectType = tsfGlobalDescribeMap.get('TSF_vod__c');
		Schema.DescribeSObjectResult tsfResult = tsfsObjectType.getDescribe();
		Map<String,Schema.SObjectField> tsfObjectFieldMap = tsfResult.fields.getMap();


		for(String viewColumn : viewColumns) {

			if(viewcolumn.contains('Account.')) {
				String fieldName = viewColumn.substringAfter('.');
				if (fieldName.contains('.')) {
					userReferenceHasExist.put(viewColumn, false);
					fieldReferenceToExportHasExist.put(viewColumn, false);
				} else {
					try {
						Schema.SObjectField sObjectField = accountObjectFieldMap.get(fieldName);
						List<Schema.sObjectType> fieldReference = sObjectField.getDescribe().getReferenceTo();
						if(fieldReference.size() > 0) {
							Set<String> referenceSet = new Set<String>();
							for(Integer i = 0; i < fieldReference.size(); i++) {
								referenceSet.add(String.valueOf(fieldReference[i]));
							}
							if(referenceSet.contains('User')) {
								String relationName = sObjectField.getDescribe().getRelationshipName();
								fieldOfUserReferenceMap.put(viewColumn, viewColumn.substringBefore('.') + '.' + relationName + '.Name');
								fieldReferenceToExportMap.put(viewColumn, viewColumn.substringBefore('.') + '.' + relationName + '.Name');
								userReferenceHasExist.put(viewColumn, true);
								fieldReferenceToExportHasExist.put(viewColumn, true);
							} else if(!referenceSet.contains('RecordType')) {
								String relationName = sObjectField.getDescribe().getRelationshipName();
								if(relationName != null && relationName != ''){
									fieldReferenceToExportMap.put(viewColumn, viewColumn.substringBefore('.') + '.' + relationName + '.Name');
									fieldReferenceToExportHasExist.put(viewColumn, true);
								}else{
									fieldReferenceToExportHasExist.put(viewColumn, false);
								}
								userReferenceHasExist.put(viewColumn, false);
							} else {
								userReferenceHasExist.put(viewColumn, false);
								fieldReferenceToExportHasExist.put(viewColumn, false);
							}
						} else {
							userReferenceHasExist.put(viewColumn, false);
							fieldReferenceToExportHasExist.put(viewColumn, false);
						}
					} catch (Exception ex) {
						userReferenceHasExist.put(viewColumn, false);
						fieldReferenceToExportHasExist.put(viewColumn, false);
					}
				}
			} else if(viewcolumn.contains('Address.')) {
				String fieldName = viewColumn.substringAfter('.');
				if (fieldName.contains('.')) {
					userReferenceHasExist.put(viewColumn, false);
				} else {
					try {
						Schema.SObjectField sObjectField = accountObjectFieldMap.get(fieldName);
						List<Schema.sObjectType> fieldReference = sObjectField.getDescribe().getReferenceTo();
						if(fieldReference.size() > 0) {
							Set<String> referenceSet = new Set<String>();
							for(Integer i = 0; i < fieldReference.size(); i++) {
								referenceSet.add(String.valueOf(fieldReference[i]));
							}
							if(referenceSet.contains('User')) {
								String relationName = sObjectField.getDescribe().getRelationshipName();
								fieldOfUserReferenceMap.put(viewColumn, viewColumn.substringBefore('.') + '.' + relationName + '.Name');
								fieldReferenceToExportMap.put(viewColumn, viewColumn.substringBefore('.') + '.' + relationName + '.Name');
								userReferenceHasExist.put(viewColumn, true);
								fieldReferenceToExportHasExist.put(viewColumn, true);
							} else if(!referenceSet.contains('RecordType')) {
								String relationName = sObjectField.getDescribe().getRelationshipName();
								fieldReferenceToExportMap.put(viewColumn, viewColumn.substringBefore('.') + '.' + relationName + '.Name');
								fieldReferenceToExportHasExist.put(viewColumn, true);
								userReferenceHasExist.put(viewColumn, false);
							} else {
								userReferenceHasExist.put(viewColumn, false);
								fieldReferenceToExportHasExist.put(viewColumn, false);
							}
						} else {
							userReferenceHasExist.put(viewColumn, false);
							fieldReferenceToExportHasExist.put(viewColumn, false);
						}
					} catch (Exception ex) {
						userReferenceHasExist.put(viewColumn, false);
						fieldReferenceToExportHasExist.put(viewColumn, false);
					}
				}
			} else if(viewcolumn.contains('TSF.')) {
				String fieldName = viewColumn.substringAfter('.');
				if (fieldName.contains('.')) {
					userReferenceHasExist.put(viewColumn, false);
				} else {
					try {
						Schema.SObjectField sObjectField = accountObjectFieldMap.get(fieldName);
						List<Schema.sObjectType> fieldReference = sObjectField.getDescribe().getReferenceTo();
						if(fieldReference.size() > 0) {
							Set<String> referenceSet = new Set<String>();
							for(Integer i = 0; i < fieldReference.size(); i++) {
								referenceSet.add(String.valueOf(fieldReference[i]));
							}
							if(referenceSet.contains('User')) {
								String relationName = sObjectField.getDescribe().getRelationshipName();
								fieldOfUserReferenceMap.put(viewColumn, viewColumn.substringBefore('.') + '.' + relationName + '.Name');
								fieldReferenceToExportMap.put(viewColumn, viewColumn.substringBefore('.') + '.' + relationName + '.Name');
								userReferenceHasExist.put(viewColumn, true);
								fieldReferenceToExportHasExist.put(viewColumn, true);
							} else if(!referenceSet.contains('RecordType')) {
								String relationName = sObjectField.getDescribe().getRelationshipName();
								fieldReferenceToExportMap.put(viewColumn, viewColumn.substringBefore('.') + '.' + relationName + '.Name');
								fieldReferenceToExportHasExist.put(viewColumn, true);
								userReferenceHasExist.put(viewColumn, false);
							} else {
								userReferenceHasExist.put(viewColumn, false);
								fieldReferenceToExportHasExist.put(viewColumn, false);
							}
						} else {
							userReferenceHasExist.put(viewColumn, false);
							fieldReferenceToExportHasExist.put(viewColumn, false);
						}
					} catch (Exception ex) {
						userReferenceHasExist.put(viewColumn, false);
						fieldReferenceToExportHasExist.put(viewColumn, false);
					}
				}
			} else if(viewColumn.contains('Product')) {
				userReferenceHasExist.put(viewColumn, true);
				fieldOfUserReferenceMap.put(viewColumn, viewColumn);
			} else if(viewColumn.contains('RocheTarget')) {
				userReferenceHasExist.put(viewColumn, true);
				fieldOfUserReferenceMap.put(viewColumn, viewColumn);
			} else if(viewColumn.contains('MyTarget')) {
				userReferenceHasExist.put(viewColumn, true);
				fieldOfUserReferenceMap.put(viewColumn, viewColumn);
			} else if(viewColumn.contains('HcoAccount')) {
				userReferenceHasExist.put(viewColumn, true);
				fieldOfUserReferenceMap.put(viewColumn, viewColumn);
			} else if(viewColumn.contains('YtdInteractions')) {
				userReferenceHasExist.put(viewColumn, true);
				fieldOfUserReferenceMap.put(viewColumn, viewColumn);
			} else if(viewColumn.contains('AccessRating')) {
				userReferenceHasExist.put(viewColumn, true);
				fieldOfUserReferenceMap.put(viewColumn, viewColumn);
			} 
		}
	}

	public PageReference overrideUserViewLink() {
		PageReference pageref = new PageReference('/apex/GNE_SFA2_User_Layout?Id=' + userIdToViewLink);
		pageref.setredirect(true);
		return pageref;
	}

	private String getTsfSelectStatementByViewColumns(){
		String query = 'SELECT Id, Account_vod__c';
		for(String viewColumn : viewColumns){
			// TSF
			if(viewColumn.startsWith('TSF') && viewColumn.substring(viewColumn.indexOf('.')+1).toLowerCase() != 'id' && viewColumn.substring(viewColumn.indexOf('.')+1) != 'Account_vod__c'){
				query += ', ' + viewColumn.substring(viewColumn.indexOf('.')+1);
			}
			if(viewColumn.startsWith('TSF') && fieldReferenceToExportMap.containsKey(viewColumn)) {
				query += ', ' + fieldReferenceToExportMap.get(viewColumn).substring(viewColumn.indexOf('.')+1);
			}

			// Related Accounts information
			if(viewColumn.startsWith('Account') && viewColumn.substring(viewColumn.indexOf('.')+1).toLowerCase() != 'id'){
				if(viewColumn.substring(viewColumn.indexOf('.')+1)=='RecordTypeId'){
					query += ', toLabel(' + tsfToAccountRelName + '.RecordType.Name)';
				} else {
					query += ', ' + tsfToAccountRelName + '.' + viewColumn.substring(viewColumn.indexOf('.')+1);
				}
			}
			if(viewColumn.startsWith('Account') && fieldReferenceToExportMap.containsKey(viewColumn)) {
				query += ', ' + tsfToAccountRelName + '.' + fieldReferenceToExportMap.get(viewColumn).substring(viewColumn.indexOf('.')+1);
			}

			// Related Addresses information
			if(viewColumn.startsWith('Address') && viewColumn.substring(viewColumn.indexOf('.')+1).toLowerCase() != 'id'){
				query += ', ' + tsfToAddressRelName + '.' + viewColumn.substring(viewColumn.indexOf('.')+1);
			}
			if(viewColumn.startsWith('Address') && fieldReferenceToExportMap.containsKey(viewColumn)) {
				query += ', ' + tsfToAddressRelName + '.' + fieldReferenceToExportMap.get(viewColumn).substring(viewColumn.indexOf('.')+1);
			}
		}

		// Set Account required fields
		for (String accountRequiredField : new List<String> {'Id', 'isPersonAccount', 'Name'}){
			String fullName = tsfToAccountRelName + '.' + accountRequiredField;
			if (!query.containsIgnoreCase(fullName)){
				query += ', ' + fullName;
			}
		}

		// Set Address required fields
		for (String addressRequiredField : new List<String> {'Id', 'Account_vod__c'}){
			String fullName = tsfToAddressRelName + '.' + addressRequiredField;
			if (!query.containsIgnoreCase(fullName)){
				query += ', ' + fullName;
			}
		}

		query += ' FROM TSF_vod__c ';
        
		return query;
	}

	private List<TSF_vod__c> getSortedTSFsByViewColumns(Integer recordLimit, Integer offset, String tsfSelectStatement, String tsfWhereCondition){
        String soql = 'SELECT Account_vod__c FROM TSF_vod__c' + ' WHERE ' + tsfWhereCondition + ' AND Account_vod__c IN : filterdAccountIds ';     
            
        countQuery = 'SELECT Account_vod__c FROM TSF_vod__c WHERE ' + tsfWhereCondition + ' AND Account_vod__c IN '+ GNE_SFA2_Util.createInListForQuery(filterdAccountIds) +' GROUP BY Account_vod__c';
		if (sortColumn.startsWith('Account') || sortColumn.startsWith('Address') || sortColumn.startsWith('TSF')){
			String sortColumnParent, sortStatement = '';
			if (sortColumn.startsWith('Account')){
				sortColumnParent = tsfToAccountRelName;
			} else if (sortColumn.startsWith('Address')){
				sortColumnParent = tsfToAddressRelName;
			}
			if (String.isNotBlank(sortColumnParent)){
				sortStatement += sortColumnParent + '.';
			}
			sortStatement += sortColumn.substring(sortColumn.indexOf('.')+1) + ' ';
			sortStatement += sortDirection + setNullsBySortDirection();
			soql += ' ORDER BY ' + sortStatement;
		}

		soql += ' LIMIT ' + recordLimit
			  + ' OFFSET ' + offset;

        List<TSF_vod__c> accts = Database.query(soql);

        List<Id> accountsIds = new List<Id>();
        for(TSF_vod__c acc : accts){
        	accountsIds.add(acc.Account_vod__c);
        }

		String accountsIdsAsString = GNE_SFA2_Util.createInListForQuery(accountsIds);       

        String query = tsfSelectStatement + ' WHERE ' + tsfWhereCondition + ' AND Account_vod__c In ' + accountsIdsAsString;
		String additionalSortField = 'Account_vod__r.Name';

		if (sortColumn.startsWith('Account') || sortColumn.startsWith('Address') || sortColumn.startsWith('TSF')){
			String sortColumnParent, sortStatement = '';
			if (sortColumn.startsWith('Account')){
				sortColumnParent = tsfToAccountRelName;
			} else if (sortColumn.startsWith('Address')){
				sortColumnParent = tsfToAddressRelName;
			}
			if (String.isNotBlank(sortColumnParent)){
				sortStatement += sortColumnParent + '.';
			}
			sortStatement += sortColumn.substring(sortColumn.indexOf('.')+1)+ ' '+sortDirection + setNullsBySortDirection();
			query += ' ORDER BY ' + sortStatement + ',' + additionalSortField;
		}

		List<TSF_vod__c> tsfs = Database.query(query);

		Set<Id> accountsIdsSet = new Set<Id>();
		List<TSF_vod__c> result = new List<TSF_vod__c>();

        for(TSF_vod__c tsf : tsfs){
        	if(accountsIdsSet.add(tsf.Account_vod__c)){
	        	result.add(tsf);
        	}
        }

        return result;
	}

	/*Returns map acountId->Tsf_vod__c*/
	private Map<Id, TSF_vod__c> getTsfByViewColumns(String accountsIdsAsString, String tsfSelectStatement, String tsfWhereCondition){
		String query = tsfSelectStatement + ' WHERE ' + tsfWhereCondition + ' AND Account_vod__c IN ' + accountsIdsAsString;

		Map<Id, TSF_vod__c> result = new Map<Id, TSF_vod__c>();
		for(TSF_vod__c tsf : Database.query(query)){
			result.put(tsf.Account_vod__c, tsf);
		}
		return result;
	}

	private Set<String> getObjectsToQueryByAllColumns(List<String> viewColumns, List<String> accountFilterColumns, List<String> addressFilterColumns, String sortColumn){
		Set<String> objectsToQuery = new Set<String>();

		for(String wrapperViewColumn : viewColumns){
			if(wrapperViewColumn != 'Product' && wrapperViewColumn != 'RocheTarget' && wrapperViewColumn != 'MyTarget' 
				&& wrapperViewColumn != 'HcoAccount' && wrapperViewColumn != 'YtdInteractions' && wrapperViewColumn != 'AccessRating') {
				objectsToQuery.add(wrapperViewColumn.substring(0,wrapperViewColumn.indexOf('.')));
			}
		}
		if(!accountFilterColumns.isEmpty()){
			objectsToQuery.add('Account');
		}
		if(!addressFilterColumns.isEmpty()){
			objectsToQuery.add('Address');
		}

		objectsToQuery.add(sortColumn.substring(0,sortColumn.indexOf('.')));
		return objectsToQuery;
	}

	private List<Territory2> getUserTerritories(Id userId){
		Set<Territory2> result = new Set<Territory2>();
		List<Territory2> userTopTerritories = [ SELECT Id, Name, External_id_gne__c, ParentTerritory2Id FROM Territory2 WHERE Id in (SELECT Territory2Id FROM UserTerritory2Association WHERE UserId = :userId) ORDER BY Name ];
		if(userTopTerritories.size() > 0) {
			result.addAll(userTopTerritories);
			getChildrenTerritories(userTopTerritories, result);
		}
		return GNE_SFA2_Util.sortTerritoriesHierarchical(result);
	}

	private void getChildrenTerritories(List<Territory2> parentTerritories, Set<Territory2> result) {
		List<Territory2> childrenTerritories = [ SELECT Id, Name, External_id_gne__c, ParentTerritory2Id FROM Territory2 WHERE ParentTerritory2Id in :parentTerritories ORDER BY ParentTerritory2Id ];
		if(childrenTerritories.size() > 0) {
			result.addAll(childrenTerritories);
			getChildrenTerritories(childrenTerritories, result);
		}
	}

	// get views defined for user
	private List<SFA2_View_Config_gne__c> getViews(){
		// select all public views
		List<SFA2_View_Config_gne__c> result = [SELECT Id, OwnerId, View_Name_gne__c, View_Fields_gne__c, Sorting_Field_gne__c, Filter_Statement_gne__c, Person_Record_Types_gne__c, Account_Record_Types_gne__c, Product_gne__c, Visibility_gne__c
		FROM SFA2_View_Config_gne__c
		WHERE ((Visibility_gne__c='private' AND OwnerId = :UserInfo.getUserId()) OR Visibility_gne__c='public') AND Page_Name_gne__c = 'My Targets' ORDER BY View_Name_gne__c];

		//select all views available for user based on sales roster
		List<SFA2_View_Config_gne__c> restricetedViews = [SELECT Id, OwnerId, View_Name_gne__c, View_Fields_gne__c, Sorting_Field_gne__c, Filter_Statement_gne__c, Person_Record_Types_gne__c, Account_Record_Types_gne__c, Product_gne__c, Application_Type_gne__c,
		Brand_gne__c, Role_gne__c, Visibility_gne__c
		FROM SFA2_View_Config_gne__c
		WHERE Visibility_gne__c = 'restricted' AND Page_Name_gne__c = 'My Targets' ORDER BY View_Name_gne__c ];

		// check all restricted views
		for(SFA2_View_Config_gne__c restrictedView : restricetedViews) {
			if(userAppContext.App_Name_gne__c == restrictedView.Application_Type_gne__c && userAppContext.Brand_gne__c == restrictedView.Brand_gne__c && userAppContext.Role_gne__c == restrictedView.Role_gne__c) {
				result.add(restrictedView);
			}
		}

		GNE_SFA2_Util.sortList(result, 'View_Name_gne__c', true);
		return result;
	}

	// get views defined for user
	private SFA2_View_Config_gne__c getView(Id viewId){
		return [SELECT Id, OwnerId, View_Name_gne__c, View_Fields_gne__c, Sorting_Field_gne__c, Filter_Statement_gne__c, Person_Record_Types_gne__c, Account_Record_Types_gne__c, Product_gne__c, Visibility_gne__c
		FROM SFA2_View_Config_gne__c
		WHERE Id =:viewId];
	}

	// prepare select options for account views
	private List<SelectOption> prepareSelectOptions(List<SFA2_View_Config_gne__c> views){
		List<SelectOption> accountViewsSelectOptions = new List<SelectOption>();
		if(views == null || views.isEmpty()){
			accountViewsSelectOptions.add(new SelectOption('', 'No Views Defined'));
		} else {
			for(SFA2_View_Config_gne__c myAccountsViewSetup : views){
				accountViewsSelectOptions.add(new SelectOption(myAccountsViewSetup.Id, myAccountsViewSetup.View_Name_gne__c));
			}
		}
		return accountViewsSelectOptions;
	}

	// prepare select options for territories
	private List<SelectOption> prepareSelectOptions(List<Territory2> territories){
		List<SelectOption> territoriesSelectOptions = new List<SelectOption>();
		for(Territory2 territory : territories){
			territoriesSelectOptions.add(new SelectOption(territory.Id, territory.Name));
		}
		return territoriesSelectOptions;
	}

	// get view columns basing on the selected view
	private List<String> getViewColumnsBySelectedView(SFA2_View_Config_gne__c selectedView){
		List<String> columns = new List<String>();
		if(selectedView.View_Fields_gne__c != null && selectedView.View_Fields_gne__c != ''){
			columns = selectedView.View_Fields_gne__c.split(';', 0);
		}

		return columns;
	}

	private Map<String, String> getViewColumnsHeaders(List<String>columnsNames){
		productIdToProduct = new Map<Id, Product_vod__c>([ SELECT Id, Name FROM Product_vod__c WHERE Id IN :productsInViewColumns ]);
		Map<String, String> result = new Map<String, String>();
		for(String columnName: columnsNames){
			String fieldName = columnName.substring(columnName.indexOf('.')+1);
			if(columnName.startsWith('Account')){
				String label = Schema.SObjectType.Account.fields.getMap().get(fieldName).getDescribe().getLabel();
				result.put(columnName, label);
			}else if(columnName.startsWith('Address')){
				String label = Schema.SObjectType.Address_vod__c.fields.getMap().get(fieldName).getDescribe().getLabel();
				result.put(columnName, label);
			}else if(columnName.startsWith('TSF')){
				String label = Schema.SObjectType.TSF_vod__c.fields.getMap().get(fieldName).getDescribe().getLabel();
				result.put(columnName, label);
			}else if(columnName.contains('Product')){
				result.put(columnName, columnName);
			}else if(columnName.contains('RocheTarget')) {
				result.put(columnName, 'Roche Target');
			} else if(columnName.contains('MyTarget')) {
				result.put(columnName, 'My Target');
			} else if(columnName.contains('HcoAccount')) {
				result.put(columnName, 'Hco Account');
			} else if(columnName.contains('YtdInteractions')) {
				result.put(columnName, 'Ytd Interactions');
			} else if(columnName.contains('AccessRating')) {
				result.put(columnName, 'Access Rating');
			}
		}
		return result;
	}

	private Map<String, String> getViewColumnsHeadersType(List<String>columnsNames){
		Map<String, String> result = new Map<String, String>();
		for(String columnName: columnsNames){
			String fieldName = columnName.substring(columnName.indexOf('.')+1);
			if(columnName.startsWith('Account')){
				Schema.DisplayType type = Schema.SObjectType.Account.fields.getMap().get(fieldName).getDescribe().getType();
				result.put(columnName, type.Name());
			}else if(columnName.startsWith('Address')){
				Schema.DisplayType type = Schema.SObjectType.Address_vod__c.fields.getMap().get(fieldName).getDescribe().getType();
				result.put(columnName, type.Name());
			}else if(columnName.startsWith('TSF')){
				Schema.DisplayType type = Schema.SObjectType.TSF_vod__c.fields.getMap().get(fieldName).getDescribe().getType();
				result.put(columnName, type.Name());
			}else if(columnName.contains('Product')) {
				result.put(columnName, 'STRING');
			}else if(columnName.contains('RocheTarget')) {
				result.put(columnName, 'STRING');
			} else if(columnName.contains('MyTarget')) {
				result.put(columnName, 'STRING');
			} else if(columnName.contains('HcoAccount')) {
				result.put(columnName, 'STRING');
			} else if(columnName.contains('YtdInteractions')) {
				result.put(columnName, 'STRING');
			} else if(columnName.contains('AccessRating')) {
				result.put(columnName, 'STRING');
			}
		}
		return result;
	}

	// get filter columns basing on the selected view
	private List<String> getFilterColumnsBySelectedView(SFA2_View_Config_gne__c selectedView, String objectName){
		List<String> filters = new List<String>();
		if(selectedView.Filter_Statement_gne__c != null && selectedView.Filter_Statement_gne__c != '') {
			List<GNE_SFA2_My_Accounts_View_Setup_Ext.ConditionItem> conditionItems = (List<GNE_SFA2_My_Accounts_View_Setup_Ext.ConditionItem>)JSON.deserializeStrict(selectedView.Filter_Statement_gne__c,  List<GNE_SFA2_My_Accounts_View_Setup_Ext.ConditionItem>.class);
			for(Integer i=0; i<conditionItems.size(); i++){
				GNE_SFA2_My_Accounts_View_Setup_Ext.ConditionItem conditionItem = conditionItems.get(i);
				Boolean conditionItemValueIsNull = conditionItem.value == null;
				if(conditionItem.record == objectName) {
					String filterExpr = conditionItem.field;
					if(conditionItem.valueType == 'PICKLIST'){
						if(conditionItem.operator=='inc'){
							filterExpr += ' IN '+GNE_SFA2_Util.createInListForQueryNotEscaping(conditionItem.multiValue);
						}else if(conditionItem.operator=='ecl'){
							filterExpr += ' NOT IN '+GNE_SFA2_Util.createInListForQueryNotEscaping(conditionItem.multiValue);
						}
					}else if(conditionItem.valueType == 'MULTIPICKLIST'){
						if(conditionItem.operator == 'inc'){
							filterExpr += ' INCLUDES '+GNE_SFA2_Util.createInListForQueryNotEscaping(conditionItem.multiValue);
						}else if(conditionItem.operator=='ecl'){
							filterExpr += ' EXCLUDES '+GNE_SFA2_Util.createInListForQueryNotEscaping(conditionItem.multiValue);
						}
					}else if(conditionItem.valueType == 'BOOLEAN') {
						if(conditionItem.operator == 'eq'){
							filterExpr += ' = '+conditionItem.value;
						}else if(conditionItem.operator == 'ne'){
							filterExpr += ' != '+conditionItem.value;
						}

					}else if(conditionItem.valueType=='REFERENCE'){
						Schema.DescribeSObjectResult objectDescribe = GNE_SFA2_Application_Cache.describeObject(objectName);
						Map<String,Schema.SObjectField> sObjectFieldMap = objectDescribe.fields.getMap();
						filterExpr = sObjectFieldMap.get(conditionItem.field).getDescribe().getRelationshipName();
						if(conditionItem.operator=='eq'){
							//filterExpr += ' = \''+ conditionItem.value.escapeEcmaScript() +'\''; //SREEDHAR: SFDC-2319 Forward Slash (/) in the filter field value resulting in error
							filterExpr += conditionItemValueIsNull ? '.Name = null' : '.Name = \''+ String.escapeSingleQuotes(conditionItem.value) +'\'';
						}else if(conditionItem.operator=='ne'){
							//filterExpr += ' != \''+conditionItem.value.escapeEcmaScript() +'\'';
							filterExpr += conditionItemValueIsNull ? '.Name != null' : '.Name != \''+String.escapeSingleQuotes(conditionItem.value) +'\'';
						}else if(conditionItem.operator=='lt'){
							//filterExpr += ' < \''+conditionItem.value.escapeEcmaScript() +'\'';
							filterExpr += '.Name < \''+String.escapeSingleQuotes(conditionItem.value) +'\'';
						}else if(conditionItem.operator=='lte'){
							//filterExpr += ' <= \''+conditionItem.value.escapeEcmaScript() +'\'';
							filterExpr += '.Name <= \''+String.escapeSingleQuotes(conditionItem.value) +'\'';
						}else if(conditionItem.operator=='gt'){
							//filterExpr += ' > \''+conditionItem.value.escapeEcmaScript() +'\'';
							filterExpr += '.Name > \''+String.escapeSingleQuotes(conditionItem.value) +'\'';
						}else if(conditionItem.operator=='gte'){
							//filterExpr += ' >= \''+conditionItem.value.escapeEcmaScript() +'\'';
							filterExpr += '.Name >= \''+String.escapeSingleQuotes(conditionItem.value) +'\'';
						}else if(conditionItem.operator=='c'){
							filterExpr += '.Name LIKE \'%'+String.escapeSingleQuotes(conditionItem.value)+'%\'';
						}else if(conditionItem.operator=='nc'){
							filterExpr =  ' (NOT ' + filterExpr + '.Name LIKE \'%'+String.escapeSingleQuotes(conditionItem.value)+'%\')';
						}else if(conditionItem.operator=='sw'){
							filterExpr += '.Name LIKE \''+String.escapeSingleQuotes(conditionItem.value)+'%\'';
						}
					}else if(conditionItem.valueType=='STRING'||conditionItem.valueType=='EMAIL'||conditionItem.valueType=='URL' || conditionItem.valueType=='PHONE') {
						if(conditionItem.operator=='eq'){
							//filterExpr += ' = \''+ conditionItem.value.escapeEcmaScript() +'\''; //SREEDHAR: SFDC-2319 Forward Slash (/) in the filter field value resulting in error
							filterExpr += conditionItemValueIsNull ? ' = null' : ' = \''+ String.escapeSingleQuotes(conditionItem.value) +'\'';
						}else if(conditionItem.operator=='ne'){
							//filterExpr += ' != \''+conditionItem.value.escapeEcmaScript() +'\'';
							filterExpr += conditionItemValueIsNull ? ' != null' : ' != \''+String.escapeSingleQuotes(conditionItem.value) +'\'';
						}else if(conditionItem.operator=='lt'){
							//filterExpr += ' < \''+conditionItem.value.escapeEcmaScript() +'\'';
							filterExpr += ' < \''+String.escapeSingleQuotes(conditionItem.value) +'\'';
						}else if(conditionItem.operator=='lte'){
							//filterExpr += ' <= \''+conditionItem.value.escapeEcmaScript() +'\'';
							filterExpr += ' <= \''+String.escapeSingleQuotes(conditionItem.value) +'\'';
						}else if(conditionItem.operator=='gt'){
							//filterExpr += ' > \''+conditionItem.value.escapeEcmaScript() +'\'';
							filterExpr += ' > \''+String.escapeSingleQuotes(conditionItem.value) +'\'';
						}else if(conditionItem.operator=='gte'){
							//filterExpr += ' >= \''+conditionItem.value.escapeEcmaScript() +'\'';
							filterExpr += ' >= \''+String.escapeSingleQuotes(conditionItem.value) +'\'';
						}else if(conditionItem.operator=='c'){
							filterExpr += ' LIKE \'%'+String.escapeSingleQuotes(conditionItem.value)+'%\'';
						}else if(conditionItem.operator=='nc'){
							filterExpr =  '(NOT ' + conditionItem.field + ' LIKE \'%'+String.escapeSingleQuotes(conditionItem.value)+'%\')';
						}else if(conditionItem.operator=='sw'){
							filterExpr += ' LIKE \''+String.escapeSingleQuotes(conditionItem.value)+'%\'';
						}
					} else {
						String value='';
						Boolean needQuotes = true;
						try{
							if (conditionItem.valueType=='DOUBLE'||conditionItem.valueType=='CURRENCY'||conditionItem.valueType=='PERCENT'){
								value = Double.valueOf(conditionItem.value).format();
								needQuotes = false;
							} else if(conditionItem.valueType=='INTEGER'){
								value = Integer.valueOf(conditionItem.value).format();
								needQuotes = false;
							} else if(conditionItem.valueType=='DATE'){
								String[] dateParts = conditionItem.value.split('/');
								DateTime dtime = DateTime.newInstance(Integer.valueOf(dateParts[2]), Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]));
								value = dtime.format('yyyy-MM-dd');
								needQuotes = false;
							} else if (conditionItem.valueType=='DATETIME'){
								String[] dateParts = conditionItem.value.split('/');
								//if field is datetime only date part is compared
								filterExpr = String.format('DAY_ONLY(CONVERTTIMEZONE({0}))', new String[]{filterExpr});
								DateTime dtime = DateTime.newInstance(Integer.valueOf(dateParts[2]), Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), 0, 0, 0);
								value = dtime.format('yyyy-MM-dd');
								needQuotes = false;
							} else if(conditionItem.valueType=='ID'){
								Id tmpId = conditionItem.value;
								value = tmpId;
							} else{
								value = conditionItem.value;
							}
						}catch(Exception e){
							system.debug(Logginglevel.ERROR, e);
							//TODO: implement
						}
						if(conditionItem.operator=='eq'){
							filterExpr +=  ' = ' + (needQuotes ? ('\''+value+'\'') : value);
						}else if(conditionItem.operator=='ne'){
							filterExpr +=  ' != ' + (needQuotes ? ('\''+value+'\'') : value);
						}else if(conditionItem.operator=='lt'){
							filterExpr +=  ' < ' + (needQuotes ? ('\''+value+'\'') : value);
						}else if(conditionItem.operator=='lte'){
							filterExpr +=  ' <= ' + (needQuotes ? ('\''+value+'\'') : value);
						}else if(conditionItem.operator=='gt'){
							filterExpr +=  ' > ' + (needQuotes ? ('\''+value+'\'') : value);
						}else if(conditionItem.operator=='gte'){
							filterExpr +=  ' >= ' + (needQuotes ? ('\''+value+'\'') : value);
						}
					}
					filters.add(filterExpr);
				}
			}
		}
		return filters;
	}

	// get filter columns basing on the selected view
	private String getSortColumnBySelectedView(SFA2_View_Config_gne__c selectedView){
		String sortingField = '';
		if(selectedView.Sorting_Field_gne__c != null && selectedView.Sorting_Field_gne__c != ''){
			sortingField = selectedView.Sorting_Field_gne__c;
		}
		return sortingField;
	}

	private Set<Id> getAccountsIds(List<TSF_vod__c>tsfes){
		Set<Id> result = new Set<Id>();
		for(TSF_vod__c tsf: tsfes){
			result.add(tsf.Account_vod__c);
		}
		return result;
	}

	private Set<Id> getAccountsIds(List<Account>accounts){
		Set<Id> result = new Set<Id>();
		for(Account account: accounts){
			result.add(account.id);
		}
		return result;
	}

	private Set<Id> getAccountsIds(List<Address_vod__c>addresses){
		Set<Id> result = new Set<Id>();
		if(addresses!=null){
			for(Address_vod__c address: addresses){
				result.add(address.Account_vod__c);
			}
		}
		return result;
	}

	public PageReference nextPage(){
		if(pageNumber == getPageNumbers()){
			return null;
		}
		pageNumber++;
		offset += PAGE_SIZE;
		viewWrappers = getViewWrapers(selectedView, territoryId, true);
		return null;
	}

	public PageReference previousPage(){
		if(pageNumber == 1){
			return null;
		}
		pageNumber--;
		offset -= PAGE_SIZE;
		viewWrappers = getViewWrapers(selectedView, territoryId, false);
		return null;
	}

	public Boolean getDisablePrevious(){
		return offset<=0;
	}

	public Boolean getDisableNext(){
		return pageNumber>=getPageNumbers();
	}

	public PageReference changeSelectedView(){
		Long st =  System.currentTimeMillis();
		offset = 0;
		pageNumber = 1;
		filterLetter = 'All';
		selectedView = getView(selectedViewId);
		myPreferences.Last_View_Used_gne__c = selectedView.id;
		myPreferences.Last_Territory_Used_gne__c = territoryId;
		upsert myPreferences;
		initialazeControllerVariables(territoryId, selectedView);
		viewWrappers = getViewWrapers(selectedView, territoryId, true);
		executingTime = (System.currentTimeMillis()-st);
		System.debug('Executing time: '+ executingTime);
		return null;
	}

	public PageReference changeFiltering(){
		Long st =  System.currentTimeMillis();
		offset = 0;
		pageNumber = 1;
		initialazeControllerVariables(territoryId, selectedView);
		viewWrappers = getViewWrapers(selectedView, territoryId, true);
		executingTime = (System.currentTimeMillis()-st);
		System.debug('Executing time: '+ executingTime);
		return null;
	}

	public PageReference changeSorting(){
		Long st =  System.currentTimeMillis();
		offset = 0;
		pageNumber = 1;
		if(sortColumn == getSortColumnBySelectedView(selectedView)){
			if(sortDirection == 'ASC'){
				sortDirection = 'DESC';
			}else{
				sortDirection = 'ASC';
			}
		}else{
			selectedView.Sorting_Field_gne__c = sortColumn;
			sortDirection = 'ASC';
		}
		viewWrappers = getViewWrapers(selectedView, territoryId, true);
		executingTime = (System.currentTimeMillis()-st);
		System.debug('Executing time: '+ executingTime);
		return null;
	}

	public Integer getPageNumbers(){
		if(recordsCount != null) {
			Integer pageNumber = Math.ceil(recordsCount / (PAGE_SIZE * 1.0)).intValue();
			return pageNumber < 1 ? 1 : pageNumber;
		}  else {
			return 1;
		}
	}

	private Boolean isLastPage(){
		return getPageNumbers()==pageNumber;
	}

	private String getTerritoryName(String terriotryId){
		return [SELECT Name FROM Territory2 where id = :terriotryId].Name;
	}

	private String getTerritoryId(String terriotryName){
		return [SELECT Id FROM Territory2 where Name = :terriotryName LIMIT 1].Id;
	}

	public Boolean getIsViewEditable(){
		String userProfileName = GNE_SFA2_Util.getCurrentUserProfileName();
		if (String.isNotBlank(userProfileName) && userProfileName.equalsIgnoreCase('GNE-SFA-CC')){
			return false;
		}
		if(selectedView != null && selectedView.OwnerId == Userinfo.getUserId()){
			return true;
		} else{
			return false;
		}
	}

	public Boolean getIsViewCreatable(){
		Boolean result = false;
		String userProfileName = GNE_SFA2_Util.getCurrentUserProfileName();
		if (String.isNotBlank(userProfileName) && (userProfileName.startsWithIgnoreCase('GNE-SFA-BAM') || userProfileName.equalsIgnoreCase('GNE-SFA-CC'))){
			result = false;
		}
		return result;
	}

	public PageReference newClick(){
		PageReference pageRef = Page.GNE_SFA2_SBC;
		pageRef.setredirect(true);
		return pageRef;
	}

	public PageReference scheduleInteractionClick(){
		PageReference pageRef = Page.GNE_SFA2_MyAccounts_InteractionScheduler;
		String ids = '';
		for(String accId : getSelectedAccounts()){
			ids += accid+',';
		}
		ids.removeEnd(',');

		pageRef.getParameters().put('selectedAccountIds', ids);
		pageRef.setRedirect(true);
		return pageRef;
	}

	public PageReference multipleInteractionClick(){
		PageReference pageRef = Page.GNE_SFA2_Interaction_Edit_Create;
		String ids = '';
		for(String accId : getSelectedAccounts()){
			ids += accid+',';
		}
		ids.removeEnd(',');

		pageRef.getParameters().put('selectedAccountIds', ids);
		pageRef.getParameters().put('retURL', 'apex/GNE_SFA2_MyAccounts');
		pageRef.setRedirect(true);
		return pageRef;
	}

	public Pagereference refreshSelectedAccounts() {
		getSelectedAccounts();
		return null;
	}

	public List<String> getSelectedAccounts(){
		List<String> selectedAccounts = new List<String>();
		if(viewWrappers != null) {
			for(ViewWrapper wrapper : viewWrappers){
				if(wrapper.selected == true){
					selectedAccounts.add(wrapper.account.Id);
				}
			}
		}
		return selectedAccounts;
	}

	public List<TSF_vod__c> getSelectedTSFs(){
		return [ SELECT Id, Account_vod__r.Name, LastModifiedById, LastModifiedBy.Profile.Name FROM TSF_vod__c WHERE Account_vod__c in :getSelectedAccounts() AND Territory_vod__c In :getTerritoriesHierarchicalNames(territoryId)];
	}

	private List<String>getRecordTypes(SFA2_View_Config_gne__c selectedView){
		List<String>recordTypes = new List<String>();
		if(String.isNotEmpty(selectedView.Person_Record_Types_gne__c)){
			recordTypes.addAll(selectedView.Person_Record_Types_gne__c.split(','));
		}
		if(String.isNotEmpty(selectedView.Account_Record_Types_gne__c)){
			recordTypes.addAll(selectedView.Account_Record_Types_gne__c.split(','));
		}
		return recordTypes;
	}

	//Butons actions
	public PageReference editView(){
		PageReference pr = Page.GNE_SFA2_My_Accounts_View_Setup;
		pr.getParameters().put('id', selectedViewId);
		pr.setRedirect(true);
		return pr;
	}

	public PageReference createView(){
		PageReference pr = Page.GNE_SFA2_My_Accounts_View_Setup;
		pr.setRedirect(true);
		return pr;
	}

	public PageReference exportToExcelClick(){
		if(!String.isEmpty(selectedViewId)) {
			PageReference pageRef = new PageReference('/apex/GNE_SFA2_MyTarget_Export');
			pageRef.setredirect(false);
			pageRef.getParameters().put('selectedViewId', selectedViewId);
			pageRef.getParameters().put('territoryId', territoryId);
			pageRef.getParameters().put('sortColumn', sortColumn);
			pageRef.getParameters().put('sortDirection', sortDirection);
			return pageRef;
		} else {
			return null;
		}
	}

	public void exportToExcel() {
		GNE_SFA2_MyTargets_Controller myAccountsController = new GNE_SFA2_MyTargets_Controller(true);
		myAccountsController.PAGE_SIZE = 1000;
		myAccountsController.offset = 0;

		selectedViewInExport = getView(ApexPages.currentPage().getParameters().get('selectedViewId'));
		viewColumnsInExport = myAccountsController.getViewColumnsBySelectedView(selectedViewInExport);
		columnsHeadersInExport = myAccountsController.getViewColumnsHeaders(viewColumnsInExport);
		viewWrappersInExport = myAccountsController.getViewWrapers(selectedViewInExport, ApexPages.currentPage().getParameters().get('territoryId'), true);
	}
    

	public String getHostName() {
		String host = ApexPages.CurrentPage().getHeaders().get('host');
		return host;
	}

	public String getFileName() {
		String fileName = selectedView.View_Name_gne__c + ' - ' + String.valueOf(Date.Today());
		fileName = fileName.replaceAll('[^a-zA-Z0-9\\s-]', '');
		return fileName ;
	}

	public String getWorkbookProperties() {
		String workbook = '<x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet><x:Name>' + selectedView.View_Name_gne__c + '</x:Name><x:WorksheetOptions><x:DisplayGridlines/></x:WorksheetOptions></x:ExcelWorksheet></x:ExcelWorksheets></x:ExcelWorkbook>';
		return workbook;
	}

	public PageReference updateAlignment() {
		massUpdateMessage = '';
		List<TSF_vod__c> tsfs = getSelectedTSFs();
		Boolean fieldValue = Boolean.valueOf(newValue);
		if(newValue=='notaligned'){
            List<TSF_vod__c> ignoredTSFs = GNE_SFA2_Territory_Alignment_Helper.removeAlignmentMassUpdate(tsfs, territoryId, GNE_SFA2_Util.getCurrentUserProfileName());
            if(!ignoredTSFs.isEmpty()){
            	massUpdateMessage = ignoredTSFs.size() +'/'+tsfs.size()+' accounts cannot be updated.\nPlease contact support with any questions.';
            }
		}else{
			Boolean myTarget = (newValue == 'myview' ? true : false);
			GNE_SFA2_Territory_Alignment_Helper.alignedAccountsMassUpdate(tsfs, territoryId, myTarget);
		}
		return null;
	}

	private String getFilterStatement(String filterColumn){
		String query = ' AND ' + filterColumn;
		return query;
	}
    
    public void submitToManager() {
        if(viewWrappersToSubmit.get(wrapperAsJson) != null) {
            User currentUser = [SELECT ManagerID, Manager.email, Manager.name FROM User WHERE Id = :UserInfo.getUserId()];
            ViewWrapper vw = viewWrappersToSubmit.get(wrapperAsJson);
            vw.submited = true; 
            Targets_and_Tiers_can_gne__c[] tatsToUpdate = findTatToUpdate(vw);
            for(Targets_and_Tiers_can_gne__c ta: tatsToUpdate){
                ta.Submitted_DataTime_gne__c = System.now();
                ta.Submitted_To_gne__c = currentUser.ManagerID == null? null : currentUser.ManagerID;
                ta.Submitted_By_gne__c = currentUser.Id;
            }
            
            update tatsToUpdate;        
        }
    }
    
    private Targets_and_Tiers_can_gne__c[]  findTatToUpdate(ViewWrapper wrapperToProcess) {
        Targets_and_Tiers_can_gne__c[] result = new Targets_and_Tiers_can_gne__c[]{};
        for(Targets_and_Tiers_can_gne__c tat :wrapperToProcess.tats){
            if(tat.Target_gne__c != tat.My_Target_gne__c){
                result.add(tat);                
            }
        }
        return result;
    }

	public class ViewWrapper implements Comparable {
		public Boolean selected {get; set;}
		public Id accountId {get; set;}
		public Account account {get; set;}
		public TSF_vod__c tsf {get; set;}
		public List<String> product {get; set;}
		public List<String> rocheTarget {get; set;}
		public List<String> myTarget {get; set;}
		public String hcoAccount {get; set;}
		public String accessRating {get; set;}
		public String firstRocheTarget {get;set;}
        public Boolean targetNotMatch {get;set;}
        public Boolean submited {get;set;}
        public Integer ytdInteractions {get; set;}
        private List<Targets_and_Tiers_can_gne__c> tats;
        
		private Map<String, Integer> order = new Map<String, Integer> {
			'SPR' => 1,
			'HI' => 2,
			'MED' => 3,
			'LOW' => 4,
			'PRS' => 5,
			'HCP' => 6,
            'XXX' => 7, //for empty values
            '---' => 7
		};
		private Map<String, Integer> accountTypeMultiplier = new Map<String, Integer> {
			'Physician' => 100,
			'Pharmacist' => 200,
			'Nurse' => 300,
			'Nurse General' => 400,
			'Nurse Specialized' => 500
		};

		public ViewWrapper(){}

		public ViewWrapper(Id accountId, Account account, TSF_vod__c tsf){
            this.tats = new List<Targets_and_Tiers_can_gne__c>();
			this.selected = false;
            this.submited = false;
            this.targetNotMatch = false;
			this.accountId = accountId;
			this.account = account;
			this.tsf = tsf;
			this.ytdInteractions = 0;
            this.hcoAccount = '';
            this.accessRating = '';
		}
        
        private void setProductTargets(TargetContainer[] containers){
            product = new List<String>();
            rocheTarget = new List<String>();
            myTarget = new List<String>();
            for(TargetContainer tc:containers){
                product.add(tc.product);
                if(tc.rocheTarget == null){
                    rocheTarget.add('---');
                } else {
                    rocheTarget.add(tc.rocheTarget);
                }

                if(tc.myTarget == null){
                	myTarget.add('---');
                } else {
                    myTarget.add(tc.myTarget);
                }

                if(String.isNotBlank(tc.accessRating))accessRating = tc.accessRating;
                if(String.isNotBlank(tc.accontName))hcoAccount = tc.accontName;
                tats.add(tc.tat);
                if(!submited){
                    submited = tc.tat.Submitted_DataTime_gne__c != null;
                }
            }
            if(!rocheTarget.isEmpty()) this.firstRocheTarget = rocheTarget[0];    
            if(rocheTarget.isEmpty() || this.firstRocheTarget == null) this.firstRocheTarget = 'XXX'; 
        }
        
        private void compareTargets(){
            if(this.myTarget.size() != this.rocheTarget.size()){
                targetNotMatch = true;
                return;
            }
            for(Integer x=0; x < this.myTarget.size(); x++ ) {
                if(this.myTarget.get(x) != this.rocheTarget.get(x)){
                    targetNotMatch = true;
                	return;
                }
            }
        }

		public Integer compareTo(Object obj) {
			ViewWrapper objToCompare = (ViewWrapper)obj;
			Integer objToCompareMultiplier = 600, currentObjMultiplier = 600;

			if(accountTypeMultiplier.containsKey(objToCompare.account.Account_Type_gne__c)) 
				objToCompareMultiplier = accountTypeMultiplier.get(objToCompare.account.Account_Type_gne__c);
			if(accountTypeMultiplier.containsKey(this.account.Account_Type_gne__c))
				currentObjMultiplier = accountTypeMultiplier.get(this.account.Account_Type_gne__c);	
			
			Integer rocheTargetPriority = getPriority(objToCompare.firstRocheTarget) == null? 500 : getPriority(objToCompare.firstRocheTarget) + objToCompareMultiplier;
            if(currentObjMultiplier == null)currentObjMultiplier = 500;
			Integer currentRocheTargetPriority = this.firstRocheTarget == null? 7: getPriority(this.firstRocheTarget) + currentObjMultiplier;            

			if(currentRocheTargetPriority < rocheTargetPriority) {
				return -1;
			} else if(currentRocheTargetPriority == rocheTargetPriority) {
				if(this.account.Name > objToCompare.account.Name) {
					return 1;
				} else {
					return 0;
				}
			}

			return 1;
		}

		private Integer getPriority(String rocheTarget) {
            rocheTarget = rocheTarget.toUpperCase();
			if(order.containsKey(rocheTarget)) {
				return order.get(rocheTarget);
			} else {
				return 7;
			}
		}
	}

	public class AccountWithBrandAffiliations{
		public Id accountId { get; set; }
		public Map<Id, Product_Metrics_vod__c> brandAffiliations { get; set; }

		public AccountWithBrandAffiliations(String accountId){
			this.accountId = accountId;
			this.brandAffiliations = new Map<Id, Product_Metrics_vod__c>();
		}

		public Map<Id, Product_Metrics_vod__c> getBrandAffiliations () {
			return brandAffiliations;
		}

		public Id getAccountId () {
			return accountId;
		}
	}

	private class TargetContainer {
		public String product;
		public String rocheTarget;
		public String myTarget;
        public String accessRating;
        public String accontName;
        public Targets_and_Tiers_can_gne__c tat;

		public TargetContainer(String product, String rocheTarget, String myTarget, String accessRating, String accontName, Targets_and_Tiers_can_gne__c tat) {
			this.product = product;
			this.rocheTarget = rocheTarget;
			this.myTarget = myTarget;
            this.accessRating = accessRating;
            this.accontName = accontName;
            this.tat = tat;
		}
	}

	public Component.Apex.PageBlockButtons getCustomButtons(){
        Component.Apex.PageBlockButtons dynamicPageBlockButtons = new Component.Apex.PageBlockButtons();
        dynamicPageBlockButtons.location = 'top';
        
        Component.Apex.CommandButton dynamicButton = new Component.Apex.CommandButton();
        dynamicButton.value = 'Export To Excel';
        dynamicButton.disabled = false;
        dynamicButton.expressions.action = '{!exportToExcelClick}';
        dynamicButton.styleClass='image-button sfa-plh sfa-plh-action-bar button export-to-excel';
        dynamicPageBlockButtons.childComponents.add(dynamicButton);
                
		return dynamicPageBlockButtons;
	}

	public String getListPageName() {
		String result;
		if(pageConfiguration != null) {
			result = pageConfiguration.Section_Header_gne__c;
		} else {
			result = '';
		}
		return result;
	}

	public String getActiveMenuItem() {
		String result = '';
		if(pageConfiguration != null && pageConfiguration.Attributes_gne__c!=null && pageConfiguration.Attributes_gne__c.contains('activeMenuItem')){
			result = pageConfiguration.Attributes_gne__c.substringBetween('activeMenuItem=',';');
		}

		return result;
	}

	private String getTerritoryName(Id terrytoryId){
		return null;
	}
}