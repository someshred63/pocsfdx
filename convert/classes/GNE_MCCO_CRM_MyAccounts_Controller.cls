/*
 * GNE_MCCO_CRM_MyAccounts_Controller
 *
 * Created By :         Tadeusz Hyzy (tadeusz.hyzy@contractors.roche.com)
 * Last Modified By :   Lukasz Kozminski (lukasz.kozminski@contractors.roche.com)
 * Last Modified Date : 12/13/2016
 *
 * Comment:
 * - a lot of helping methods was taken from GNE_SFA2_MyAccounts_Controller
 *
 */
 public with sharing class GNE_MCCO_CRM_MyAccounts_Controller {

    /* Init variables */
    public String iconBase64 { get; private set; }
    private static final Integer RECORDS_LIMIT = 40000;

    public String tsfToAccountRelName { get; private set; }
    public String tsfToAddressRelName { get; private set; }

    public String settingsJson { get; private set; }
    public String preferencesJson { get; private set; }

    private Territory2 firstTerritory { get; set; }
    public String firstTerritoryJson { get; private set; }

    public Boolean hasTerritories { get; set; }
    public Boolean hasViews { get; set; }

	private Set<String> territoryNames { get; set; }

	public String territoriesJson { get; private set; }
	public String territoryNamesJson { get; private set; }
    public String buttonsListJson { get; private set; }
    public String viewsJson { get; private set; }

    public SFA2_View_Config_gne__c selectedView { get; private set; }

    /* Init export variables */
    private Boolean isExport { get; set; }

    private String selectedViewId { get; set; }
    private String selectedTerritoryNames { get; set; }
    private String selectedSortColumn { get; set; }
    private String selectedSortDirection { get; set; }
    private String selectedLetter { get; set; }
    private String searchValue { get; set; }

    public String selectedViewJson { get; private set; }

    public GNE_SFA2_My_Accounts_Setttings__c settings { get; private set; }
    public SFA2_User_Preferences_gne__c preferences { get; private set; }

    private Map<String, TerritoryWrapper> territoriesList { get; set; }
    private List<SFA2_View_Config_gne__c> viewsList { get; set; }

    public AccountWrapper accountWrapperExport { get; private set; }

    public String fileName { get; private set; }
    public String hostName { get; private set; }

    public SettingsWrapper settingsExport { get; private set; }

    public String userTimeZone { get; private set; }

    public Boolean isMccoCrmUser { get { return GNE_SFA2_Util.isMccoCrmUser(); } }

    public Boolean isFrmUser { get { return GNE_SFA2_Util.isFrmUser(); } }

     public Boolean isBamUser { get { return GNE_SFA2_Util.getCurrentUserProfileName().contains('BAM'); } }

    public Boolean checkboxesEnabled {get; set;}

    /*
     * Constructor
     *
     * Initiate all variables
     */
    public GNE_MCCO_CRM_MyAccounts_Controller() {
    	isExport 			= (ApexPages.currentPage().getParameters().get('export') != null && ApexPages.currentPage().getParameters().get('export') != '') ? true : false;

        tsfToAccountRelName = TSF_vod__c.Account_vod__c.getDescribe().getRelationshipName();
        tsfToAddressRelName = TSF_vod__c.Address_vod__c.getDescribe().getRelationshipName();

        userTimeZone 		= String.valueOf(UserInfo.getTimeZone());
        iconBase64			= '/img/icon/accounts32.png';

		if(!isExport) {
			initVariables();
		} else {
			initExportVariables();
		}

        checkboxesEnabled = !(GNE_SFA2_Util.isBamCrmUser());
    }

    private void initVariables() {
        Map<String, TerritoryWrapper> userTerritoriesMap = getTerritories();
        String subTeamCode= '';
    	territoriesJson 		= JSON.serializePretty(userTerritoriesMap);
		territoryNamesJson		= JSON.serializePretty(territoryNames);
    	settingsJson 			= JSON.serializePretty(GNE_MCCO_CRM_Util.getUserSettings());
    	preferences				= GNE_MCCO_CRM_Util.getUserPreferences('My Accounts');
        preferencesJson 		= JSON.serializePretty(preferences);
        if(userTerritoriesMap != null && userTerritoriesMap.size() > 0) {
            for(TerritoryWrapper tw : userTerritoriesMap.values()) {
                subTeamCode = tw.subTeamCode != null && tw.subTeamCode == 'OPM' ? tw.subTeamCode : '';
                break;
            }
        }
        if(subTeamCode == 'OPM') {
            viewsList = GNE_MCCO_CRM_Util.getViews('My Accounts', subTeamCode);
        } else {
    	viewsList				= GNE_MCCO_CRM_Util.getViews('My Accounts');
        }
    	viewsJson 				= JSON.serializePretty(viewsList);
        buttonsListJson 		= JSON.serializePretty(GNE_MCCO_CRM_Util.getButtonsList('Account'));

        if(!viewsList.isEmpty()) {
        	hasViews = true;
        } else {
        	hasViews = false;
        }

    }

    private void initExportVariables() {

        viewsList				= GNE_MCCO_CRM_Util.getViews('My Accounts');
        territoriesList 		= getTerritories();
    	settings 				= GNE_MCCO_CRM_Util.getUserSettings();
        preferences 			= GNE_MCCO_CRM_Util.getUserPreferences('My Accounts');

		selectedViewId 			= (ApexPages.currentPage().getParameters().get('selectedViewId') != null && ApexPages.currentPage().getParameters().get('selectedViewId') != '') ? ApexPages.currentPage().getParameters().get('selectedViewId') : preferences.Last_View_Used_gne__c;
		selectedTerritoryNames 	= (ApexPages.currentPage().getParameters().get('selectedTerritoryNames') != null && ApexPages.currentPage().getParameters().get('selectedTerritoryNames') != '') ? ApexPages.currentPage().getParameters().get('selectedTerritoryNames') : preferences.Last_Territory_Used_gne__c;
		selectedSortColumn 		= (ApexPages.currentPage().getParameters().get('selectedSortColumn') != null && ApexPages.currentPage().getParameters().get('selectedSortColumn') != '') ? ApexPages.currentPage().getParameters().get('selectedSortColumn') : 'Account.Name';
		selectedSortDirection 	= (ApexPages.currentPage().getParameters().get('selectedSortDirection') != null && ApexPages.currentPage().getParameters().get('selectedSortDirection') != '') ? ApexPages.currentPage().getParameters().get('selectedSortDirection') : 'ASC';
		selectedLetter		 	= (ApexPages.currentPage().getParameters().get('selectedLetter') != null && ApexPages.currentPage().getParameters().get('selectedLetter') != '') ? ApexPages.currentPage().getParameters().get('selectedLetter') : 'ALL';
		searchValue		 		= (ApexPages.currentPage().getParameters().get('searchValue') != null && ApexPages.currentPage().getParameters().get('searchValue') != '') ? ApexPages.currentPage().getParameters().get('searchValue') : '';

		SFA2_View_Config_gne__c selectedView = GNE_MCCO_CRM_Util.getView(selectedViewId);

		selectedViewJson		= JSON.serializePretty(selectedView);

		settingsExport 			= new SettingsWrapper(tsfToAccountRelName, tsfToAddressRelName, selectedViewJson, selectedTerritoryNames, 1, 2000, selectedLetter, selectedSortColumn, selectedSortDirection, searchValue);

		accountWrapperExport 	= getAccountWrapers(settingsExport);
		hostName				= URL.getSalesforceBaseUrl().toExternalForm();
		fileName				= selectedView.View_Name_gne__c + '.xls';

    }

    /*
     * getTerritories()
     *
     * Get all avaible territories to User
     *
     * return Map<String, TerritoryWrapper>
     */
    private Map<String, TerritoryWrapper> getTerritories() {
        Map<String, TerritoryWrapper> result = new  Map<String, TerritoryWrapper>();
        Set<Id> parentTerritoriesIds = new Set<Id>();

        territoryNames = new Set<String>();

        List<Territory2> territoriesList = [ SELECT Id, Name, External_id_gne__c, ParentTerritory2Id, Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c FROM Territory2 WHERE Id IN (SELECT Territory2Id FROM UserTerritory2Association WHERE UserId = :Userinfo.getUserId()) ORDER BY Name DESC ];

        if(!territoriesList.isEmpty()){

            firstTerritory = territoriesList[0];
        	firstTerritoryJson = JSON.serializePretty(firstTerritory);

            for(Territory2 territory : territoriesList) {
                parentTerritoriesIds.add(territory.Id);
            }

            Map<String, TerritoryWrapper> childrenList = getChildrenTerritories(parentTerritoriesIds);

            for(Territory2 territory : territoriesList) {
            	territoryNames.add(territory.Name);
                result.put(territory.Id, new TerritoryWrapper(territory.Id, territory.ParentTerritory2Id, territory.Name, territory.Salesforce_SubTeam_Code_gne__c, childrenList));
            }
            hasTerritories = true;

            return filterTerritories(result);
        } else {
            result = null;
            hasTerritories = false;
            return result;
        }

    }

    private Map<String, TerritoryWrapper> filterTerritories(Map<String, TerritoryWrapper> territoriesWrapper) {
    	Map<String, TerritoryWrapper> result = new  Map<String, TerritoryWrapper>();
    	Set<String> parentTerritories = new Set<String>();
    	Set<String> idsToRemove = new Set<String>();

    	for(String territoryId : territoriesWrapper.keySet()) {
    		parentTerritories.add(territoryId);
    	}

    	for(TerritoryWrapper tw : territoriesWrapper.values()) {
    		String tmpResult = checkChildrenTerritories(parentTerritories, tw);
    		if(!String.isEmpty(tmpResult)) {
    			idsToRemove.add(tmpResult);
    		}
    	}

    	for(String territoryId : territoriesWrapper.keySet()) {
    		if(idsToRemove.contains(territoryId)) {
    			territoriesWrapper.remove(territoryId);
    		}
    	}

    	return territoriesWrapper;
    }

    private String checkChildrenTerritories(Set<String> searchIds, TerritoryWrapper tw) {

    	if(tw.territoryChildren != null && !tw.territoryChildren.isEmpty()) {

	    	for(String territoryId : tw.territoryChildren.keySet()) {

		    	if(searchIds.contains(territoryId)) {
		    		return territoryId;
		    	}

	    		if(!String.isEmpty(checkChildrenTerritories(searchIds, tw.territoryChildren.get(territoryId)))) {
	    			return territoryId;
	    		}

	    	}

	    	return '';

    	} else {

    		return '';

    	}
    }

    /*
     * getChildrenTerritories(Set<Id> parentTerritoriesIds)
     *
     * Get all avaible children territories based on parent id
     *
     * return Map<String, TerritoryWrapper>
     */
    private Map<String, TerritoryWrapper> getChildrenTerritories(Set<Id> parentTerritoriesIds) {
        Map<String, TerritoryWrapper> result = new Map<String, TerritoryWrapper>();

        List<Territory2> territoriesList = [ SELECT Id, Name, External_id_gne__c, ParentTerritory2Id, Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c FROM Territory2 WHERE ParentTerritory2Id IN :parentTerritoriesIds ORDER BY Name ];

        if(!territoriesList.isEmpty()) {
            parentTerritoriesIds = new Set<Id>();

            for(Territory2 territory : territoriesList) {
                parentTerritoriesIds.add(territory.Id);
            }

            Map<String, TerritoryWrapper> childrenList = getChildrenTerritories(parentTerritoriesIds);

            for(Territory2 territory : territoriesList) {
            	territoryNames.add(territory.Name);
                result.put(territory.Id, new TerritoryWrapper(territory.Id, territory.ParentTerritory2Id, territory.Name, territory.Salesforce_SubTeam_Code_gne__c, childrenList));
            }
        }

        return result;
    }

    /*
     * loadAccounts(String tsfToAccountRelName, String tsfToAddressRelName, String selectedViewJson, String selectedTerritoriesNamesJson, Integer page, Integer pageSize, String letter, String sortColumn, String sortDirection)
     *
     * Load all account based on JSON settings
     *
     * return List<Account>
     */
    @RemoteAction
    @ReadOnly
    public static AccountWrapper loadAccounts(String tsfToAccountRelName, String tsfToAddressRelName, String selectedViewJson, String selectedTerritoriesNamesJson, Integer page, Integer pageSize, String letter, String sortColumn, String sortDirection, String searchValue) {
        SettingsWrapper settings = new SettingsWrapper(tsfToAccountRelName, tsfToAddressRelName, selectedViewJson, selectedTerritoriesNamesJson, page, pageSize, letter, sortColumn, sortDirection, searchValue);
        return getAccountWrapers(settings);
    }

    @RemoteAction
    public static void hideAccounts(List<String>accountIds, String territoryJSON) {
    	JSONParser parser = JSON.createParser(territoryJSON);
        TerritoryWrapper territory = (TerritoryWrapper)parser.readValueAs(TerritoryWrapper.class);
    	Map<Id, TSF_vod__c>tsfes = new Map<Id, TSF_vod__c>([SELECT id FROM TSF_vod__c WHERE account_vod__c in :(accountIds) and Territory_vod__c = :territory.name]);
        GNE_SFA2_HCP_Helper.hideAccounts(new List<Id>(tsfes.keySet()), territory.territoryId);
    }

    /*
     * updateViewPreference(String viewId)
     *
     * Update user preference with new last view
     *
     * return boolean
     */
    @RemoteAction
    public static Boolean updateViewPreference(String viewId) {
        SFA2_User_Preferences_gne__c preference  = new SFA2_User_Preferences_gne__c( User_gne__c = UserInfo.getUserId(), Last_View_Used_gne__c = viewId );

        try {
            preference = [ SELECT Last_View_Used_gne__c FROM  SFA2_User_Preferences_gne__c WHERE Last_View_Used_gne__r.Page_Name_gne__c = 'My Accounts' AND User_gne__c = :Userinfo.getUserId() LIMIT 1 ];
            preference.Last_View_Used_gne__c = viewId;
        } catch(Exception e) {}

        try {
            upsert preference;
            return true;
        } catch(DMLException e) {
            return false;
        }
    }

    /*
     * updateTerritoryPreference(String territoryId)
     *
     * Update user preference with new last territory
     *
     * return boolean
     */
    @RemoteAction
    public static Boolean updateTerritoryPreference(String territoryId, String viewId) {
        SFA2_User_Preferences_gne__c preference  = new SFA2_User_Preferences_gne__c( User_gne__c = UserInfo.getUserId(), Last_Territory_Used_gne__c = territoryId, Last_View_Used_gne__c = viewId );

        try {
            preference = [ SELECT Last_Territory_Used_gne__c FROM SFA2_User_Preferences_gne__c WHERE Last_View_Used_gne__r.Page_Name_gne__c = 'My Accounts' AND User_gne__c = :Userinfo.getUserId() LIMIT 1 ];
            preference.Last_Territory_Used_gne__c = territoryId;
        } catch(Exception e) {}

        try {
            upsert preference;
            return true;
        } catch(DMLException e) {
        	System.debug(e.getMessage());
            return false;
        }
    }

    /*
     * getAccountWrapers()
     *
     * Get account wrapper based on sent settings from JS
     *
     * return AccountWrapper
     */
    private static AccountWrapper getAccountWrapers(SettingsWrapper settings) {
        String tsfWhereCondition = getTsfWhereCondition(settings, getRecordTypes(settings.selectedView));

        Set<Id> accountIds = getAccountsIdsByTerritory(tsfWhereCondition, settings);


        List<AccountWrapperItem> items = new List<AccountWrapperItem>();

        if(accountIds.size() == 0){
            return new AccountWrapper(0, null, settings.columnsHeaders, settings.columnsHeadersType);
        }

        String accountsToInQuery = GNE_SFA2_Util.createInListForQuery(accountIds);
        String tsfSelectStatement = getTsfSelectStatementByViewColumns(settings);

        if(settings.sortColumn.startsWith('TSF') || settings.sortColumn.startsWith('Account') || settings.sortColumn.startsWith('Address')){
            List<TSF_vod__c> tsfes = getSortedTSFsByViewColumns(settings, tsfSelectStatement, tsfWhereCondition, accountsToInQuery);
            String accountsIdsAsString = GNE_SFA2_Util.createInListForQuery(getAccountsIds(tsfes));
            Map<Id, Map<Id, Product_Metrics_vod__c>> brandAffiliationsMap = getBrandAffiliationsByViewColumns(settings, accountsIdsAsString);
            items = prepareWrappers(tsfes, brandAffiliationsMap);
        } else if(settings.sortColumn.startsWith('BrandAffiliation')){
            List<AccountWithBrandAffiliations> sortedBrandAffiliations = getSortedBrandAffiliationsByViewColumns(settings, accountsToInQuery);

            if(!sortedBrandAffiliations.isEmpty()){
                Map<Id, TSF_vod__c> tsfMap = getTsfByViewColumns(GNE_SFA2_Util.createInListForQuery(getAccountIdsFromAccountWithBrandAffiliations(sortedBrandAffiliations)), tsfSelectStatement, tsfWhereCondition);
                items = prepareWrappers(sortedBrandAffiliations, tsfMap);
            }
        }

        return new AccountWrapper(accountIds.size(), items, settings.columnsHeaders, settings.columnsHeadersType);

    }

    /*
     * getTsfByViewColumns()
     *
     * Get TSF_vod__c based on selected view configuration
     *
     * return Map<Id, TSF_vod__c>
     */
    private static Map<Id, TSF_vod__c> getTsfByViewColumns(String accountsIdsAsString, String tsfSelectStatement, String tsfWhereCondition){
        String query = tsfSelectStatement + ' WHERE ' + tsfWhereCondition;
        query += ' AND Account_vod__c IN ' + accountsIdsAsString;

        Map<Id, TSF_vod__c> result = new Map<Id, TSF_vod__c>();
        for(TSF_vod__c tsf : Database.query(query)){
            result.put(tsf.Account_vod__c, tsf);
        }
        return result;
    }

    private static Set<Id> getAccountIdsFromAccountWithBrandAffiliations(List<AccountWithBrandAffiliations> accountsWithBAs){
        Set<Id> result = new Set<Id>();
        for(AccountWithBrandAffiliations accountWithBAs : accountsWithBAs) {
            result.add(accountWithBAs.getAccountId());
        }
        return result;
    }

    private static List<AccountWrapperItem> prepareWrappers(List<TSF_vod__c> tsfes, Map<Id, Map<Id, Product_Metrics_vod__c>> brandAffiliations){
        List<AccountWrapperItem> result = new List<AccountWrapperItem>();
        Set<String>uniqueAccounts = new Set<String>();
        if(tsfes != null && tsfes.size() > 0){
            for(TSF_vod__c tsf : tsfes){
            	if(uniqueAccounts.add(tsf.Account_vod__c)){
                	result.add(new AccountWrapperItem(tsf.Account_vod__c, tsf.Account_vod__r, tsf.Address_vod__r, brandAffiliations.get(tsf.Account_vod__c), tsf));
            	}
            }
        }
        return result;
    }

    private static List<AccountWrapperItem> prepareWrappers(List<AccountWithBrandAffiliations> brandAffiliations, Map<Id, TSF_vod__c> tsfMap){
        List<AccountWrapperItem> result = new List<AccountWrapperItem>();
        if(!brandAffiliations.isEmpty()){
        	Set<String>uniqueAccounts = new Set<String>();
            for(AccountWithBrandAffiliations ba : brandAffiliations){
            	if(uniqueAccounts.add(ba.getAccountId())){
                	result.add(new AccountWrapperItem((Id)ba.getAccountId(), tsfMap.get(ba.getAccountId()).Account_vod__r, tsfMap.get(ba.getAccountId()).Address_vod__r, ba.getBrandAffiliations(), tsfMap.get(ba.getAccountId())));
            	}
            }
        }
        return result;
    }

    private static List<AccountWithBrandAffiliations> getSortedBrandAffiliationsByViewColumns(SettingsWrapper settings, String accountsIdsAsString){
        List<AccountWithBrandAffiliations> result = new List<AccountWithBrandAffiliations>();
        if(!settings.objectsToQuery.contains('BrandAffiliation')){
            return new List<AccountWithBrandAffiliations>();
        }
        List<Product_Metrics_vod__c> brandAffiliations;
        List<Product_Metrics_vod__c> resultBrandAffiliations = new List<Product_Metrics_vod__c>();
        String brandAffiliationQuery;

        if(settings.brandAffiliationFilterColumns != null && settings.brandAffiliationFilterColumns.size() > 0) {
            brandAffiliationQuery = getSelectStatementForBrandAffiliations(settings);
            brandAffiliationQuery += ' FROM Product_Metrics_vod__c WHERE Products_vod__c = \'' + settings.brandsInFiltersList[0] + '\'';
            brandAffiliationQuery += ' AND Account_vod__c IN ' + accountsIdsAsString;
            for(String filterColumn : settings.brandAffiliationFilterColumns) {
                brandAffiliationQuery += getFilterStatement(filterColumn);
            }
            brandAffiliations = Database.query(brandAffiliationQuery);
        }

        String sortColumnProduct = settings.sortColumn.substringBetween('.');

        Integer offset = (settings.pageSize * settings.page) - settings.pageSize;

        for(String productInViewColumn : settings.productsInViewColumns) {
            if(productInViewColumn == sortColumnProduct) {
                brandAffiliationQuery = getSelectStatementForBrandAffiliations(settings);
                brandAffiliationQuery += ' FROM Product_Metrics_vod__c WHERE Products_vod__c = \'' + productInViewColumn + '\'';
                if(brandAffiliations != null) {
                    brandAffiliationQuery += ' AND Account_vod__c IN  ' + GNE_SFA2_Util.createInListForQuery(getAccountIdsFromBrandAffiliations(brandAffiliations));
                } else {
                    brandAffiliationQuery += ' AND Account_vod__c IN  ' + accountsIdsAsString;
                }
                brandAffiliationQuery += ' ORDER BY ' + settings.sortColumn.substringAfterLast('.') + ' ' + settings.sortDirection + setNullsBySortDirection(settings.sortDirection);
                brandAffiliationQuery += ' LIMIT ' + settings.pageSize  +' OFFSET '+ offset;
                brandAffiliations = Database.query(brandAffiliationQuery);
                resultBrandAffiliations.addAll(brandAffiliations);
                break;
            }
        }

        // query all other BA at the end
        if(resultBrandAffiliations != null && resultBrandAffiliations.size() > 0) {
            Set<String> otherProducts = new Set<String>(settings.productsInViewColumns);
            if (otherProducts != null && otherProducts.size() > 0){
                if (settings.brandsInFilters != null && settings.brandsInFilters.size() > 0){
                    otherProducts.removeAll(settings.brandsInFilters);
                }
                otherProducts.remove(sortColumnProduct);

                if (otherProducts.size() > 0){
                    String productsAsAString = GNE_SFA2_Util.createInListForQuery(new List<String>(otherProducts));
                    brandAffiliationQuery = getSelectStatementForBrandAffiliations(settings);
                    brandAffiliationQuery += ' FROM Product_Metrics_vod__c WHERE Products_vod__c In ' + productsAsAString;
                    brandAffiliationQuery += ' AND Account_vod__c IN  ' + GNE_SFA2_Util.createInListForQuery(getAccountIdsFromBrandAffiliations(brandAffiliations));
                    brandAffiliations = Database.query(brandAffiliationQuery);
                }
            }
        }

        for(Product_Metrics_vod__c brandAffiliation : resultBrandAffiliations) {
            AccountWithBrandAffiliations accWithBA = new AccountWithBrandAffiliations(brandAffiliation.Account_vod__c);
            accWithBA.getBrandAffiliations().put(brandAffiliation.Products_vod__c, brandAffiliation);
            result.add(accWithBA);
        }

        //add selected BA to the result
        if(result != null && result.size() > 0) {
            for(Product_Metrics_vod__c brandAffiliation : brandAffiliations) {
                for(AccountWithBrandAffiliations accWithBA : result) {
                    if(brandAffiliation.Account_vod__c == accWithBA.getAccountId()) {
                        // if we already have an account on the list just add a new BA
                        accWithBA.getBrandAffiliations().put(brandAffiliation.Products_vod__c, brandAffiliation);
                        break;
                    }
                }
            }
        }

        //fill missing BA on the list
        for(String productId : settings.productsInViewColumns) {
            for(AccountWithBrandAffiliations accWithBA : result){
                if(!accWithBA.getBrandAffiliations().containsKey(productId)) {
                    accWithBA.getBrandAffiliations().put(productId, new Product_Metrics_vod__c());
                }
            }
        }

        return result;
    }

    private static String getSelectStatementForBrandAffiliations(SettingsWrapper settings) {
        String brandAffiliationQuery = ' SELECT Account_vod__c ';
        Set<String> fieldsToSelect = new Set<String>();
        for(String viewColumn : settings.viewColumns){
            if(viewColumn.startsWith('BrandAffiliation') && viewColumn.substringAfterLast('.').toLowerCase() != 'id') {
                fieldsToSelect.add(viewColumn.substringAfterLast('.'));
            }

            if(!fieldsToSelect.contains('Products_vod__c')) {
                fieldsToSelect.add('Products_vod__c');
            }

            if(viewColumn.startsWith('BrandAffiliation') && settings.fieldReferenceMaps.fieldReferenceToExportMap.containsKey(viewColumn)) {
                String referenceField = settings.fieldReferenceMaps.fieldReferenceToExportMap.get(viewColumn).substringAfter('.');
                fieldsToSelect.add(referenceField.substringAfter('.'));
            }
        }
        for(String fieldToSelect : fieldsToSelect) {
            brandAffiliationQuery += ', ' + fieldToSelect;
        }
        System.debug('##### BA Query === ' + brandAffiliationQuery);
        return brandAffiliationQuery;
    }

    private static Map<Id, Map<Id, Product_Metrics_vod__c>> getBrandAffiliationsByViewColumns(SettingsWrapper settings, String accountsIdsAsString){

        if(!settings.objectsToQuery.contains('BrandAffiliation')){
            return new Map<Id, Map<Id, Product_Metrics_vod__c>>();
        }

        List<Product_Metrics_vod__c> brandAffiliations;
        List<Product_Metrics_vod__c> filteredBrandAffiliations;
        List<Product_Metrics_vod__c> resultbrandAffiliations;

        Map<Id, Map<Id,Product_Metrics_vod__c>> result = new Map<Id, Map<Id, Product_Metrics_vod__c>>();

        String brandAffiliationQuery = getSelectStatementForBrandAffiliations(settings);
        brandAffiliationQuery += ' FROM Product_Metrics_vod__c WHERE Account_vod__c IN ' + accountsIdsAsString;

        if(settings.brandAffiliationFilterColumns != null && settings.brandAffiliationFilterColumns.size() > 0) {
            brandAffiliationQuery += ' AND Products_vod__c = \'' + settings.brandsInFiltersList[0] + '\'';
            for(String brandAffiliationFilerColumn : settings.brandAffiliationFilterColumns) {
                brandAffiliationQuery += getFilterStatement(brandAffiliationFilerColumn);
            }
        }

        filteredBrandAffiliations = Database.query(brandAffiliationQuery);
        putBrandAffiliationsToMap(filteredBrandAffiliations, result);

        Set<String> otherProducts = new Set<String>(settings.productsInViewColumns);

        if (otherProducts != null && otherProducts.size() > 0){
            if (settings.brandsInFilters != null && settings.brandsInFilters.size() > 0){
                otherProducts.removeAll(settings.brandsInFilters);
            }

            if (otherProducts.size() > 0){
                brandAffiliationQuery = getSelectStatementForBrandAffiliations(settings);
                String productsAsAString = GNE_SFA2_Util.createInListForQuery(new List<String>(otherProducts));
                brandAffiliationQuery += ' FROM Product_Metrics_vod__c WHERE Products_vod__c In ' + productsAsAString;
                if(filteredBrandAffiliations != null && filteredBrandAffiliations.size() > 0) {
                    brandAffiliationQuery += ' AND Account_vod__c IN  ' + GNE_SFA2_Util.createInListForQuery(getAccountIdsFromBrandAffiliations(filteredBrandAffiliations));
                } else {
                    brandAffiliationQuery += ' AND Account_vod__c IN  ' + accountsIdsAsString;
                }

                brandAffiliations = Database.query(brandAffiliationQuery);
                putBrandAffiliationsToMap(brandAffiliations, result);
            }
        }

        for(String productId : settings.productsInViewColumns) {
            for(Product_Metrics_vod__c ba : filteredBrandAffiliations){
                if(!result.get(ba.Account_vod__c).containsKey(productId)) {
                    result.get(ba.Account_vod__c).put(productId, new Product_Metrics_vod__c());
                }
            }
        }

        return result;
    }

    private static void putBrandAffiliationsToMap(List<Product_Metrics_vod__c> brandAffiliationsList, Map<Id, Map<Id,Product_Metrics_vod__c>> resultMap){
        for(Product_Metrics_vod__c ba : brandAffiliationsList){
            if(!resultMap.containsKey(ba.Account_vod__c)){
                resultMap.put(ba.Account_vod__c, new Map<Id, Product_Metrics_vod__c>());
            }
            resultMap.get(ba.Account_vod__c).put(ba.Products_vod__c, ba);
        }
    }

    private static List<Id> getAccountIdsFromBrandAffiliations(List<Product_Metrics_vod__c> brandAffiliations) {
        List<Id> result = new List<Id>();
        for(Product_Metrics_vod__c ba : brandAffiliations) {
            result.add(ba.Account_vod__c);
        }
        return result;
    }

    private static Set<Id> getAccountsIds(List<TSF_vod__c> tsfes){
        Set<Id> result = new Set<Id>();
        for(TSF_vod__c tsf: tsfes) {
            result.add(tsf.Account_vod__c);
        }
        return result;
    }

    private static List<TSF_vod__c> getSortedTSFsByViewColumns(SettingsWrapper settings, String tsfSelectStatement, String tsfWhereCondition, String territoryAccountsIdsAsString){
        String query = tsfSelectStatement + ' WHERE ' + tsfWhereCondition;
        if (GNE_SFA2_Util.isMccoCrmUser()){
        	query += ' AND Account_vod__r.IsPersonAccount = false ';
        }
        query += ' AND External_Id_vod__c != null AND Address_vod__c != null AND Account_vod__c In ' + territoryAccountsIdsAsString;

        Integer offset = (settings.pageSize * settings.page) - settings.pageSize;

        if (settings.sortColumn.startsWith('Account') || settings.sortColumn.startsWith('Address') || settings.sortColumn.startsWith('TSF')){
            String sortColumnParent, sortStatement = '';
            if (settings.sortColumn.startsWith('Account')){
                sortColumnParent = settings.tsfToAccountRelName;
            } else if (settings.sortColumn.startsWith('Address')){
                sortColumnParent = settings.tsfToAddressRelName;
            }
            if (String.isNotBlank(sortColumnParent)){
                sortStatement += sortColumnParent + '.';
            }
            sortStatement += settings.sortColumn.substring(settings.sortColumn.indexOf('.')+1)+ ' '+ settings.sortDirection + setNullsBySortDirection(settings.sortDirection);
            query += ' ORDER BY ' + sortStatement;
        }

        query += ' LIMIT ' + settings.pageSize + ' OFFSET ' + offset;
        System.debug('TSF query: ' + query);
        List<TSF_vod__c> result = Database.query(query);

        return result;
    }

    private static String setNullsBySortDirection(String sortDirection){
        return sortDirection == 'DESC' ? ' NULLS LAST ' : ' NULLS FIRST ';
    }

    private static String getTsfSelectStatementByViewColumns(SettingsWrapper settings){
        String query = 'SELECT Id, Account_vod__c';

        for(String viewColumn : settings.viewColumns){
            // TSF
            if(viewColumn.startsWith('TSF') && viewColumn.substring(viewColumn.indexOf('.')+1).toLowerCase() != 'id' && viewColumn.substring(viewColumn.indexOf('.')+1) != 'Account_vod__c'){
                query += ', ' + viewColumn.substring(viewColumn.indexOf('.')+1);
            }
            if(viewColumn.startsWith('TSF') && settings.fieldReferenceMaps.fieldReferenceToExportMap.containsKey(viewColumn)) {
                query += ', ' + settings.fieldReferenceMaps.fieldReferenceToExportMap.get(viewColumn).substring(viewColumn.indexOf('.')+1);
            }

            // Related Accounts information
            if(viewColumn.startsWith('Account') && viewColumn.substring(viewColumn.indexOf('.')+1).toLowerCase() != 'id'){
                if(viewColumn.substring(viewColumn.indexOf('.')+1)=='RecordTypeId'){
                    query += ', toLabel(' + settings.tsfToAccountRelName + '.RecordType.Name)';
                } else {
                    query += ', ' + settings.tsfToAccountRelName + '.' + viewColumn.substring(viewColumn.indexOf('.')+1);
                }
            }
            if(viewColumn.startsWith('Account') && settings.fieldReferenceMaps.fieldReferenceToExportMap.containsKey(viewColumn)) {
                query += ', ' + settings.tsfToAccountRelName + '.' + settings.fieldReferenceMaps.fieldReferenceToExportMap.get(viewColumn).substring(viewColumn.indexOf('.')+1);
            }

            // Related Addresses information
            if(viewColumn.startsWith('Address') && viewColumn.substring(viewColumn.indexOf('.')+1).toLowerCase() != 'id'){
                query += ', ' + settings.tsfToAddressRelName + '.' + viewColumn.substring(viewColumn.indexOf('.')+1);
            }
            if(viewColumn.startsWith('Address') && settings.fieldReferenceMaps.fieldReferenceToExportMap.containsKey(viewColumn)) {
                query += ', ' + settings.tsfToAddressRelName + '.' + settings.fieldReferenceMaps.fieldReferenceToExportMap.get(viewColumn).substring(viewColumn.indexOf('.')+1);
            }
        }

        // Set Account required fields
        for (String accountRequiredField : new List<String> {'Id', 'isPersonAccount', 'Name'}){
            String fullName = settings.tsfToAccountRelName + '.' + accountRequiredField;
            if (!query.containsIgnoreCase(fullName)){
                query += ', ' + fullName;
            }
        }

        // Set Address required fields
        for (String addressRequiredField : new List<String> {'Id', 'Account_vod__c'}){
            String fullName = settings.tsfToAddressRelName + '.' + addressRequiredField;
            if (!query.containsIgnoreCase(fullName)){
                query += ', ' + fullName;
            }
        }

        query += ' FROM TSF_vod__c ';
        return query;
    }

    private static Set<Id> getAccountsIdsByTerritory(String tsfWhereCondition, SettingsWrapper settings){
        String tsfQuery = 'SELECT Account_vod__c FROM TSF_vod__c WHERE ' + tsfWhereCondition;

        Set<Id> accountsIds = new Set<Id>();

        if(settings.brandAffiliationFilterColumns == null || settings.brandAffiliationFilterColumns.isEmpty()) {

            if (settings.sortColumn.startsWith('Account') || settings.sortColumn.startsWith('Address') || settings.sortColumn.startsWith('TSF')){
                String sortColumnParent, sortStatement = '';
                if (settings.sortColumn.startsWith('Account')){
                    sortColumnParent = settings.tsfToAccountRelName;
                } else if (settings.sortColumn.startsWith('Address')){
                    sortColumnParent = settings.tsfToAddressRelName;
                }
                if (String.isNotBlank(sortColumnParent)){
                    sortStatement += sortColumnParent + '.';
                }
                sortStatement += settings.sortColumn.substring(settings.sortColumn.indexOf('.') + 1)+ ' '+settings.sortDirection;
                tsfQuery += ' ORDER BY ' + sortStatement;
            }

            tsfQuery += ' LIMIT ' + RECORDS_LIMIT;

            for (TSF_vod__c tsf : Database.query(tsfQuery)){
                accountsIds.add(tsf.Account_vod__c);
            }

            System.debug(tsfQuery);

        } else {

            String baQuery = 'SELECT Account_vod__c FROM Product_Metrics_vod__c WHERE Products_vod__c = \'' + settings.brandsInFiltersList[0] + '\'';

            for(String filterColumn : settings.brandAffiliationFilterColumns) {
                baQuery += getFilterStatement(filterColumn);
            }

            baQuery += ' AND Account_vod__c IN (' + tsfQuery + ')';

            if (settings.sortColumn.startsWith('BrandAffiliation')){
                baQuery += ' ORDER BY ' + settings.sortColumn.substringAfterLast('.');
            }

            baQuery += ' LIMIT ' + RECORDS_LIMIT;

            for(Product_Metrics_vod__c brandAffiliation : Database.query(baQuery)) {
                accountsIds.add(brandAffiliation.Account_vod__c);
            }

            System.debug(baQuery);

        }

        return accountsIds;
    }

    private static String getTsfWhereCondition(SettingsWrapper settings, List<String> recordTypes) {
        String qin = GNE_SFA2_Util.createInListForQueryNotEscaping(settings.selectedTerritoriesNames);
        String query = ' Territory_vod__c IN '+ qin;

        if (settings.tsfFilterColumns != null && settings.tsfFilterColumns.size() > 0){
            for(String filterColumn : settings.tsfFilterColumns){
                query += getFilterStatement(filterColumn);
            }
        }

        for (String tsfStatement : new Set<String>{'Address_vod__c <> null', 'Account_vod__c <> null', 'External_Id_vod__c <> null'}){
            if (!query.containsIgnoreCase(tsfStatement)){
                query += getFilterStatement(tsfStatement);
            }
        }

        if (settings.accountFilterColumns != null && settings.accountFilterColumns.size() > 0){
            for(String filterColumn : settings.accountFilterColumns){
                if(filterColumn.trim().startsWith('(NOT')){
                    query += ' AND (NOT ' + settings.tsfToAccountRelName + '.' + filterColumn.trim().removeStart('(NOT ');
                } else {
                    query += ' AND ' + settings.tsfToAccountRelName + '.' + filterColumn;
                }
            }
        }

        if (settings.addressFilterColumns != null && settings.addressFilterColumns.size() > 0){
            for (String filterColumn : settings.addressFilterColumns){
                if(filterColumn.trim().startsWith('(NOT')){
                    query += ' AND (NOT ' + settings.tsfToAddressRelName + '.' + filterColumn.trim().removeStart('(NOT ');
                } else {
                    query += ' AND ' + settings.tsfToAddressRelName + '.' + filterColumn;
                }
            }
        }

        if(String.isNotBlank(settings.letter) && settings.letter != 'All'){
            query += ' AND ((' + settings.tsfToAccountRelName + '.Name like \''+settings.letter+'%\') OR (' + settings.tsfToAccountRelName + '.LastName like \''+settings.letter+'%\')) ';
        }

        if(String.isNotBlank(settings.searchValue)){
            query += ' AND ((' + settings.tsfToAccountRelName + '.Name like \'%'+settings.searchValue+'%\')) ';
        }

        if(!recordTypes.isEmpty()){
            query += ' AND ' + settings.tsfToAccountRelName + '.RecordTypeId In '+GNE_SFA2_Util.createInListForQuery(getRecordTypesIds(recordTypes, settings.recordTypeNameToId));
        }

        if (GNE_SFA2_Util.isMccoCrmUser()){
        	query += ' AND ' + settings.tsfToAccountRelName + '.isPersonAccount = false';
        }

        System.debug(query);

        return query;
    }

    private static String getFilterStatement(String filterColumn){
        String query = ' AND ' + filterColumn;
        return query;
    }

    private static List<String> getRecordTypesIds(List<String> recordTypesNames, Map<String, Id> recordTypeNameToId){
        List<String> result = new List<String>();
        for(String recordTypeName : recordTypesNames){
            if (recordTypeNameToId.containsKey(recordTypeName.trim())){
                result.add(recordTypeNameToId.get(recordTypeName.trim()));
            }
        }
        return result;
    }

    private static List<String>getRecordTypes(SFA2_View_Config_gne__c selectedView){
        List<String> recordTypes = new List<String>();
        if(String.isNotEmpty(selectedView.Person_Record_Types_gne__c)){
            recordTypes.addAll(selectedView.Person_Record_Types_gne__c.split(','));
        }
        if(String.isNotEmpty(selectedView.Account_Record_Types_gne__c)){
            recordTypes.addAll(selectedView.Account_Record_Types_gne__c.split(','));
        }
        return recordTypes;
    }

    /*
     * WrapperClass SettingsWrapper
     *
     * Kepp all the settings send from Ajax
     */
    public class SettingsWrapper {

        public String tsfToAccountRelName { get; private set; }
        public String tsfToAddressRelName { get; private set; }
        public SFA2_View_Config_gne__c selectedView { get; private set; }
        public List<String> selectedTerritoriesNames { get; private set; }
        public Integer page { get; private set; }
        public Integer pageSize { get; private set; }
        public String letter { get; private set; }
        public String sortColumn { get; private set; }
        public String sortDirection { get; private set; }
        public Boolean containsBrandAffiliationColumn { get; private set; }
        public Set<String> productsInViewColumns { get; private set; }
        public Set<String> brandsInFilters { get; private set; }
        public List<String> brandsInFiltersList { get; private set; }
        public List<String> viewColumns { get; private set; }
        public FieldReference fieldReferenceMaps { get; private set; }
        public Map<String, String> columnsHeaders { get; private set; }
        public Map<String, String> columnsHeadersType { get; private set; }
        public List<String> accountFilterColumns { get; private set; }
        public List<String> addressFilterColumns { get; private set; }
        public List<String> brandAffiliationFilterColumns { get; private set; }
        public List<String> tsfFilterColumns { get; private set; }
        public Set<String> objectsToQuery { get; private set; }
        public Map<String, Id> recordTypeNameToId { get; private set; }
        public String searchValue { get; private set; }

        public SettingsWrapper(String tsfToAccountRelName, String tsfToAddressRelName, String selectedViewJson, String selectedTerritoriesNamesJson, Integer page, Integer pageSize, String letter, String sortColumn, String sortDirection, String searchValue) {

            this.tsfToAccountRelName        = tsfToAccountRelName;
            this.tsfToAddressRelName        = tsfToAddressRelName;
            this.selectedView               = this.encodeSelectedView(selectedViewJson);
            this.selectedTerritoriesNames   = this.encodeTerritories(selectedTerritoriesNamesJson);
            this.page                       = page;
            this.pageSize                   = pageSize;
            this.letter                     = letter;
            this.sortColumn                 = sortColumn;
            this.sortDirection              = sortDirection;

            if(this.selectedView.View_Fields_gne__c.containsIgnoreCase('BrandAffiliation')){
                this.containsBrandAffiliationColumn = true;
            } else {
                this.containsBrandAffiliationColumn = false;
            }

            this.productsInViewColumns          = this.getBrandNamesByViewColumns(this.selectedView);
            this.brandsInFilters                = this.getBrandNamesByFilterColumns(this.selectedView);
            this.brandsInFiltersList            = new List<String>(this.brandsInFilters);

            this.viewColumns                    = this.getViewColumnsBySelectedView(this.selectedView);
            this.fieldReferenceMaps             = this.prepareFieldReferenceMaps(this.viewColumns);
           	this.columnsHeaders                 = this.getViewColumnsHeaders(this.selectedView, this.viewColumns);

            this.columnsHeadersType             = this.getViewColumnsHeadersType(this.viewColumns);

            this.accountFilterColumns           = this.getFilterColumnsBySelectedView(this.selectedView, 'Account');
            this.addressFilterColumns           = this.getFilterColumnsBySelectedView(this.selectedView, 'Address');
            this.brandAffiliationFilterColumns  = this.getFilterColumnsBySelectedView(this.selectedView, 'BrandAffiliation');
            this.tsfFilterColumns               = this.getFilterColumnsBySelectedView(this.selectedView, 'TSF');

            if(String.isEmpty(this.sortColumn)) {
                this.sortColumn                 = this.getSortColumnBySelectedView(this.selectedView);
            }

            this.objectsToQuery                 = this.getObjectsToQueryByAllColumns(this.viewColumns, this.accountFilterColumns, this.addressFilterColumns, this.brandAffiliationFilterColumns, this.sortColumn);
            this.recordTypeNameToId             = this.initializeAccountRecordTypes();
            this.searchValue                    = searchValue;

        }

        private SFA2_View_Config_gne__c encodeSelectedView(String jsonString) {
            JSONParser parser = JSON.createParser(jsonString);
            SFA2_View_Config_gne__c result = (SFA2_View_Config_gne__c)parser.readValueAs(SFA2_View_Config_gne__c.class);
            return result;
        }

        private List<String> encodeTerritories(String jsonString) {
            JSONParser parser = JSON.createParser(jsonString);
            List<String> result = (List<String>)parser.readValueAs(List<String>.class);
            return result;
        }

        private Set<String> getBrandNamesByViewColumns(SFA2_View_Config_gne__c selectedView){
            List<String> columns = new List<String>();
            Set<String> result = new Set<String>();
            if(selectedView.View_Fields_gne__c != null && selectedView.View_Fields_gne__c != ''){
                columns = selectedView.View_Fields_gne__c.split(';', 0);
            }
            for(String column : columns){
                if(column.startsWith('BrandAffiliation')){
                    result.add(column.substringBetween('.'));
                }
            }
            return result;
        }

        private Set<String> getBrandNamesByFilterColumns(SFA2_View_Config_gne__c selectedView){
            List<String> columns = new List<String>();
            Set<String> result = new Set<String>();
            if(selectedView.Filter_Statement_gne__c != null && selectedView.Filter_Statement_gne__c != ''){
                List<GNE_SFA2_My_Accounts_View_Setup_Ext.ConditionItem> conditionItems = (List<GNE_SFA2_My_Accounts_View_Setup_Ext.ConditionItem>)JSON.deserializeStrict(selectedView.Filter_Statement_gne__c,  List<GNE_SFA2_My_Accounts_View_Setup_Ext.ConditionItem>.class);
                for(Integer i=0; i<conditionItems.size(); i++){
                    if(conditionItems[i].record == 'BrandAffiliation') {
                        result.add(conditionItems[i].brand);
                    }
                }
            }
            return result;
        }

        private List<String> getViewColumnsBySelectedView(SFA2_View_Config_gne__c selectedView){
            List<String> columns = new List<String>();
            if(selectedView.View_Fields_gne__c != null && selectedView.View_Fields_gne__c != ''){
                columns = selectedView.View_Fields_gne__c.split(';', 0);
            }
            return columns;
        }

        public FieldReference prepareFieldReferenceMaps(List<String> viewColumns) {

            Map<String,String> fieldOfUserReferenceMap = new Map<String,String>();
            Map<String,Boolean> userReferenceHasExist = new Map<String,Boolean>();
            Map<String,String> fieldReferenceToExportMap = new Map<String,String>();
            Map<String,Boolean> fieldReferenceToExportHasExist = new Map<String,Boolean>();

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

            // BrandAffiliation Global Describe Map
            Map<String,Schema.SObjectType> brandAffiliationGlobalDescribeMap = Schema.getGlobalDescribe();
            Schema.SObjectType brandAffiliationsObjectType = brandAffiliationGlobalDescribeMap.get('Product_Metrics_vod__c');
            Schema.DescribeSObjectResult brandAffiliationResult = brandAffiliationsObjectType.getDescribe();
            Map<String,Schema.SObjectField> brandAffiliationObjectFieldMap = brandAffiliationResult.fields.getMap();

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
                } else if(viewcolumn.contains('BrandAffiliation.')) {
                    String fieldName = viewColumn.substringAfterLast('.');
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
                                    fieldOfUserReferenceMap.put(viewColumn, viewColumn.substringBeforeLast('.') + '.' + relationName + '.Name');
                                    fieldReferenceToExportMap.put(viewColumn, viewColumn.substringBeforeLast('.') + '.' + relationName + '.Name');
                                    userReferenceHasExist.put(viewColumn, true);
                                    fieldReferenceToExportHasExist.put(viewColumn, true);
                                } else if(!referenceSet.contains('RecordType')) {
                                    String relationName = sObjectField.getDescribe().getRelationshipName();
                                    fieldReferenceToExportMap.put(viewColumn, viewColumn.substringBeforeLast('.') + '.' + relationName + '.Name');
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
                }
            }

            return new FieldReference(fieldOfUserReferenceMap, userReferenceHasExist, fieldReferenceToExportMap, fieldReferenceToExportHasExist);
        }


        private Map<String, String> getViewColumnsHeaders(SFA2_View_Config_gne__c selectedView, List<String> columnsNames){
            Map<String, String> result = new Map<String, String>();
           	if(!String.isEmpty(this.selectedView.Fields_Labels_gne__c)){
            	Integer i = 0;
            	for(String label: this.selectedView.Fields_Labels_gne__c.split(';')){
            		result.put(columnsNames.get(i++), label);
            	}
            }else{
	            Map<Id, Product_vod__c> productIdToProduct = new Map<Id, Product_vod__c>([ SELECT Id, Name FROM Product_vod__c WHERE Id IN :productsInViewColumns ]);
	            for(String columnName: columnsNames){
	                String fieldName = columnName.substring(columnName.indexOf('.')+1);
	                if(columnName.startsWith('Account')){
	                    String label = Schema.SObjectType.Account.fields.getMap().get(fieldName).getDescribe().getLabel();
	                    result.put(columnName, label);
	                }else if(columnName.startsWith('Address')){
	                    String label = Schema.SObjectType.Address_vod__c.fields.getMap().get(fieldName).getDescribe().getLabel();
	                    result.put(columnName, label);
	                }else if(columnName.startsWith('BrandAffiliation')){
	                    fieldName = columnName.substringAfterLast('.');
	                    String label = Schema.SObjectType.Product_Metrics_vod__c.fields.getMap().get(fieldName).getDescribe().getLabel();
	                    result.put(columnName, productIdToProduct.get(columnName.substringBetween('.')).Name + ' - ' + label);
	                }else if(columnName.startsWith('TSF')){
	                    String label = Schema.SObjectType.TSF_vod__c.fields.getMap().get(fieldName).getDescribe().getLabel();
	                    result.put(columnName, label);
	                }
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
                }else if(columnName.startsWith('BrandAffiliation')){
                    fieldName = columnName.substringAfterLast('.');
                    Schema.DisplayType type = Schema.SObjectType.Product_Metrics_vod__c.fields.getMap().get(fieldName).getDescribe().getType();
                    result.put(columnName, type.Name());
                }else if(columnName.startsWith('TSF')){
                    Schema.DisplayType type = Schema.SObjectType.TSF_vod__c.fields.getMap().get(fieldName).getDescribe().getType();
                    result.put(columnName, type.Name());
                }
            }
            return result;
        }

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

                                if(conditionItem.value == 'CURRENT_USER') {
                                	filterExpr += 'Id = \''+ String.valueof(UserInfo.getUserId()) +'\'';
                                } else {
                                	filterExpr += conditionItemValueIsNull ? '.Name = null' : '.Name = \''+ String.escapeSingleQuotes(conditionItem.value) +'\'';
                                }

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


        private String getSortColumnBySelectedView(SFA2_View_Config_gne__c selectedView){
            String sortingField = '';
            if(selectedView.Sorting_Field_gne__c != null && selectedView.Sorting_Field_gne__c != ''){
                sortingField = selectedView.Sorting_Field_gne__c;
            }
            return sortingField;
        }

        private Set<String> getObjectsToQueryByAllColumns(List<String> viewColumns, List<String> accountFilterColumns, List<String> addressFilterColumns, List<String> brandAffiliationFilterColumns, String sortColumn){
            Set<String> objectsToQuery = new Set<String>();

            for(String wrapperViewColumn : viewColumns){
            	if(wrapperViewColumn.indexOf('.') >= 0) {
                	objectsToQuery.add(wrapperViewColumn.substring(0,wrapperViewColumn.indexOf('.')));
            	}
            }
            if(!accountFilterColumns.isEmpty()){
                objectsToQuery.add('Account');
            }
            if(!addressFilterColumns.isEmpty()){
                objectsToQuery.add('Address');
            }
            if(!brandAffiliationFilterColumns.isEmpty()){
                objectsToQuery.add('BrandAffiliation');
            }

	    	if(sortColumn.indexOf('.') >= 0) {
	            objectsToQuery.add(sortColumn.substring(0, sortColumn.indexOf('.')));
	    	}

            return objectsToQuery;
        }


        private Map<String, Id> initializeAccountRecordTypes(){
            Map<String, Id> result = new Map<String, Id>();
            Map<Id, Schema.RecordTypeInfo> recordTypeInfos = Schema.SObjectType.Account.getRecordTypeInfosByID();
            for(RecordType rt : [ SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Account' ]){
                result.put(rt.DeveloperName, rt.Id);
            }
            return result;
        }

    }

    /*
     * WrapperClass FieldReference
     *
     * It will help build cascade (parent > child) select options
     */
    private class FieldReference {

        public Map<String,String> fieldOfUserReferenceMap { get; private set; }
        public Map<String,Boolean> userReferenceHasExist { get; private set; }
        public Map<String,String> fieldReferenceToExportMap { get; private set; }
        public Map<String,Boolean> fieldReferenceToExportHasExist { get; private set; }

        public FieldReference(Map<String,String> fieldOfUserReferenceMap, Map<String,Boolean> userReferenceHasExist, Map<String,String> fieldReferenceToExportMap, Map<String,Boolean> fieldReferenceToExportHasExist){
            this.fieldOfUserReferenceMap = fieldOfUserReferenceMap;
            this.userReferenceHasExist = userReferenceHasExist;
            this.fieldReferenceToExportMap = fieldReferenceToExportMap;
            this.fieldReferenceToExportHasExist = fieldReferenceToExportHasExist;
        }

    }

    /*
     * WrapperClass TerritoryWrapper
     *
     * It will help build cascade (parent > child) select options
     */
    private class TerritoryWrapper {

        public String territoryId { get; private set; }
        public String parentId { get; private set; }
        public String name { get; private set; }
        public String subTeamCode { get; private set; }
        public Map<String, TerritoryWrapper> territoryChildren { get; private set; }

        public TerritoryWrapper(String territoryId, String parentId, String name, String subTeamCode, Map<String, TerritoryWrapper> territoryChildren) {
            this.territoryId = territoryId;
            this.parentId = parentId;
            this.name = name;
            this.subTeamCode = subTeamCode;
            if(!territoryChildren.isEmpty()) {
                this.territoryChildren = this.setTerritoryChildren(territoryChildren);
            } else {
                this.territoryChildren = null;
            }
        }

        private Map<String, TerritoryWrapper> setTerritoryChildren(Map<String, TerritoryWrapper> territoryChildren) {
            Map<String, TerritoryWrapper> result = new Map<String, TerritoryWrapper>();

            for(TerritoryWrapper child : territoryChildren.values()) {
                if(child.parentId == this.territoryId) {
                    result.put(child.territoryId, child);
                }
            }

            return result;
        }

    }

    /*
     * WrapperClass AccountWrapper
     *
     * It keeps concat data from Account, Brand, TSF and Addreses
     */
    public class AccountWrapper {

        public Integer countItems { get; private set; }
        public List<AccountWrapperItem> items { get; private set; }
        public Map<String, String> columnsHeaders { get; private set; }
        public Map<String, String> columnsHeadersType { get; private set; }
        public List<String> columnNames { get; private set; }

        public AccountWrapper(Integer countItems, List<AccountWrapperItem> items, Map<String, String> columnsHeaders, Map<String, String> columnsHeadersType){
            this.countItems         = countItems;
            this.items              = items;
            this.columnsHeaders     = columnsHeaders;
            this.columnsHeadersType = columnsHeadersType;
            this.columnNames = new List<String>();
            for(String name : columnsHeaders.keySet()){
            	columnNames.add(name);
            }
        }

    }

    /*
     * WrapperClass AccountWrapperItem
     *
     * It keeps concat data from Account, Brand, TSF and Addreses
     */
    public class AccountWrapperItem {
        public Boolean selected {get; set;}
        public Id accountId {get; set;}
        public Account account {get; set;}
        public Address_vod__c address {get; set;}
        public Map<Id, Product_Metrics_vod__c> brandAffiliation {get; set;}
        public TSF_vod__c tsf {get; set;}

        public AccountWrapperItem(){}

        public AccountWrapperItem(Id accountId, Account account, Address_vod__c address, Map<Id, Product_Metrics_vod__c> brandAffiliation, TSF_vod__c tsf){
            this.selected = false;
            this.accountId = accountId;
            this.account = account;
            this.address = address;
            this.brandAffiliation = brandAffiliation;
            this.tsf = tsf;
        }
    }

    /*
     * WrapperClass AccountIdsQuery
     *
     * Both getting accounts ids and query for count all records
     */
    public class AccountIdsQuery {

        public Set<Id> ids { get; private set; }
        public String accountsCountQuery { get; private set; }

        public AccountIdsQuery(Set<Id> ids, String accountsCountQuery){
            this.ids                = ids;
            this.accountsCountQuery = accountsCountQuery;
        }

    }

    /*
     * WrapperClass AccountWithBrandAffiliations
     */
    public class AccountWithBrandAffiliations {

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
    
    public Boolean getRedirectToCustomDetailPage() {
    	return isFrmUser || GNE_SFA2_Util.isEsbrietCrmUser() || GNE_SFA2_Util.isBamCrmUser() || GNE_SFA2_Util.isCCCrmUser();
    }
}