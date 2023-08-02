public with sharing class GNE_SFA2_AffiliationManager_Ctrl {

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

    public GNE_SFA2_AffiliationManager_Ctrl() {
        tsfToAccountRelName = TSF_vod__c.Account_vod__c.getDescribe().getRelationshipName();
        tsfToAddressRelName = TSF_vod__c.Address_vod__c.getDescribe().getRelationshipName();

        userTimeZone        = String.valueOf(UserInfo.getTimeZone());

        initVariables();

    }

    private void initVariables() {

        territoriesJson         = JSON.serializePretty(getTerritories());
        territoryNamesJson      = JSON.serializePretty(territoryNames);
        settingsJson            = JSON.serializePretty(GNE_MCCO_CRM_Util.getUserSettings());
        preferences             = GNE_MCCO_CRM_Util.getUserPreferences('My Accounts');
        preferencesJson         = JSON.serializePretty(preferences);
        viewsList               = GNE_MCCO_CRM_Util.getViews('My Accounts');
        viewsJson               = JSON.serializePretty(viewsList);
        buttonsListJson         = JSON.serializePretty(GNE_MCCO_CRM_Util.getButtonsList('Account'));

        if(!viewsList.isEmpty()) {
            hasViews = true;
        } else {
            hasViews = false;
        }

    }

    private void initExportVariables() {

        viewsList               = GNE_MCCO_CRM_Util.getViews('My Accounts');
        territoriesList         = getTerritories();
        settings                = GNE_MCCO_CRM_Util.getUserSettings();
        preferences             = GNE_MCCO_CRM_Util.getUserPreferences('My Accounts');

        selectedViewId          = (ApexPages.currentPage().getParameters().get('selectedViewId') != null && ApexPages.currentPage().getParameters().get('selectedViewId') != '') ? ApexPages.currentPage().getParameters().get('selectedViewId') : preferences.Last_View_Used_gne__c;
        selectedTerritoryNames  = (ApexPages.currentPage().getParameters().get('selectedTerritoryNames') != null && ApexPages.currentPage().getParameters().get('selectedTerritoryNames') != '') ? ApexPages.currentPage().getParameters().get('selectedTerritoryNames') : preferences.Last_Territory_Used_gne__c;
        selectedSortColumn      = (ApexPages.currentPage().getParameters().get('selectedSortColumn') != null && ApexPages.currentPage().getParameters().get('selectedSortColumn') != '') ? ApexPages.currentPage().getParameters().get('selectedSortColumn') : 'Account.Name';
        selectedSortDirection   = (ApexPages.currentPage().getParameters().get('selectedSortDirection') != null && ApexPages.currentPage().getParameters().get('selectedSortDirection') != '') ? ApexPages.currentPage().getParameters().get('selectedSortDirection') : 'ASC';
        selectedLetter          = (ApexPages.currentPage().getParameters().get('selectedLetter') != null && ApexPages.currentPage().getParameters().get('selectedLetter') != '') ? ApexPages.currentPage().getParameters().get('selectedLetter') : 'ALL';
        searchValue             = (ApexPages.currentPage().getParameters().get('searchValue') != null && ApexPages.currentPage().getParameters().get('searchValue') != '') ? ApexPages.currentPage().getParameters().get('searchValue') : '';

        selectedViewJson        = JSON.serializePretty(GNE_MCCO_CRM_Util.getView(selectedViewId));

        hostName                = URL.getSalesforceBaseUrl().toExternalForm();
        fileName                = 'excel';

    }

    private Map<String, TerritoryWrapper> getTerritories() {
        Map<String, TerritoryWrapper> result = new  Map<String, TerritoryWrapper>();
        Set<Id> parentTerritoriesIds = new Set<Id>();

        territoryNames = new Set<String>();

        List<Territory2> territoriesList = [ SELECT Id, Name, External_id_gne__c, ParentTerritory2Id FROM Territory2 WHERE Id IN (SELECT Territory2Id FROM UserTerritory2Association WHERE UserId = :Userinfo.getUserId()) ORDER BY Name DESC ];

        if(!territoriesList.isEmpty()){

            firstTerritory = territoriesList[0];
            firstTerritoryJson = JSON.serializePretty(firstTerritory);

            for(Territory2 territory : territoriesList) {
                parentTerritoriesIds.add(territory.Id);
            }

            Map<String, TerritoryWrapper> childrenList = getChildrenTerritories(parentTerritoriesIds);

            for(Territory2 territory : territoriesList) {
                territoryNames.add(territory.Name);
                result.put(territory.Id, new TerritoryWrapper(territory.Id, territory.ParentTerritory2Id, territory.Name, childrenList));
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

        System.debug('# idsToRemove');
        System.debug(idsToRemove);

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

    private Map<String, TerritoryWrapper> getChildrenTerritories(Set<Id> parentTerritoriesIds) {
        Map<String, TerritoryWrapper> result = new Map<String, TerritoryWrapper>();

        List<Territory2> territoriesList = [ SELECT Id, Name, External_id_gne__c, ParentTerritory2Id FROM Territory2 WHERE ParentTerritory2Id IN :parentTerritoriesIds ORDER BY Name ];

        if(!territoriesList.isEmpty()) {
            parentTerritoriesIds = new Set<Id>();

            for(Territory2 territory : territoriesList) {
                parentTerritoriesIds.add(territory.Id);
            }

            Map<String, TerritoryWrapper> childrenList = getChildrenTerritories(parentTerritoriesIds);

            for(Territory2 territory : territoriesList) {
                territoryNames.add(territory.Name);
                result.put(territory.Id, new TerritoryWrapper(territory.Id, territory.ParentTerritory2Id, territory.Name, childrenList));
            }
        }

        return result;
    }

    @RemoteAction
    @ReadOnly
    public static AccountWrapper loadAccounts(String tsfToAccountRelName, String tsfToAddressRelName, String selectedViewJson, String selectedTerritoriesNamesJson, Integer page, Integer pageSize, String letter, String sortColumn, String sortDirection, String searchValue, String accountId) {
        SettingsWrapper settings = new SettingsWrapper(tsfToAccountRelName, tsfToAddressRelName, selectedViewJson, selectedTerritoriesNamesJson, page, pageSize, letter, sortColumn, sortDirection, searchValue);
        return getAccountWrapers(settings, accountId);
    }

    @RemoteAction
    @ReadOnly
    public static List<Affiliation_vod__c> getAffiliations(String acctId) {
        return [SELECT Id, To_Account_vod__r.Name, To_Contact_vod__r.Name, Affiliation_Type_gne__c, Role_vod__c, Influence_vod__c, Comments_vod__c FROM Affiliation_vod__c WHERE From_Account_vod__c =: acctId ORDER BY CreatedDate DESC];
    }

    @RemoteAction
    public static SObject updateAffiliation(Map<String, String> record) {
        SObject aff = new Affiliation_vod__c();
        for(String key : record.keySet()) {
            aff.put(key, record.get(key));
        }

        update aff;
        return aff;
    }

    @RemoteAction
    public static List<Affiliation_vod__c> addAffiliation (Map<String, String> toAcctOrContact, Map<String, String> record) {
        SObject aff = new Affiliation_vod__c();
        List<Affiliation_vod__c> affToInsert = new List<Affiliation_vod__c>();
        List<String> toContact = String.isNotBlank(toAcctOrContact.get('toContact')) ? toAcctOrContact.get('toContact').split(',') : new List<String>();
        List<String> toAccount = String.isNotBlank(toAcctOrContact.get('toAccount')) ? toAcctOrContact.get('toAccount').split(',') : new List<String>();

        System.debug('#### To toContact === '+ toContact);
        System.debug('#### To toAccount === '+ toAccount);
        if(!toContact.isEmpty()) {
            for(String cId : toContact) {
                Affiliation_vod__c affToContact = new Affiliation_vod__c();
                affToContact.To_Contact_vod__c = cId;
                for(String key : record.keySet()) {
                    affToContact.put(key, record.get(key));
                }

                affToInsert.add(affToContact);
            }
        }

        System.debug(toAccount.size());
        if(!toAccount.isEmpty()) {
            for(String aId : toAccount) {
                Affiliation_vod__c affToAcct = new Affiliation_vod__c();
                affToAcct.To_Account_vod__c = aId;
                for(String key : record.keySet()) {
                    affToAcct.put(key, record.get(key));
                }

                affToInsert.add(affToAcct);
            }
        }

        insert affToInsert;
        return affToInsert;
    }

    @RemoteAction
    public static Database.DeleteResult removeAffiliation (String affId) {
        return (new FullAccessWrapper()).remove(affId);
    }

    public without sharing class FullAccessWrapper {

        public FullAccessWrapper() {}

        public Database.DeleteResult remove (String recordId) {
            return Database.delete(recordId);
        }
    }

    @RemoteAction
    @ReadOnly
    public static String getAccountName(String accoutnId) {
        return [SELECT Name FROM Account WHERE Id =: accoutnId].Name;
    }

    @RemoteAction
    @ReadOnly
    public static List<Contact> searchContact(String searchValue) {
        return Database.query('SELECT Id, Name, Account.Name, Phone, Email FROM Contact WHERE Active_gne__c = true AND Account.IsPersonAccount = false AND Account.ParentId = null AND Name Like \'' + searchValue + '%\' LIMIT 25');
    }

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

    @RemoteAction
    public static Boolean updateTerritoryPreference(String territoryId, String viewId) {
        SFA2_User_Preferences_gne__c preference  = new SFA2_User_Preferences_gne__c( User_gne__c = UserInfo.getUserId(), Last_Territory_Used_gne__c = territoryId, Last_View_Used_gne__c = viewId );

        try {
            preference = [ SELECT Last_Territory_Used_gne__c FROM SFA2_User_Preferences_gne__c WHERE Last_View_Used_gne__r.Page_Name_gne__c = 'My Accounts' AND User_gne__c = :Userinfo.getUserId() LIMIT 1 ];
            preference.Last_Territory_Used_gne__c = territoryId;
        } catch(Exception e) {}

        try {
            upsert preference;
            System.debug(preference);
            return true;
        } catch(DMLException e) {
            System.debug(e.getMessage());
            return false;
        }
    }

    private static AccountWrapper getAccountWrapers(SettingsWrapper settings, String accountId) {
        String tsfWhereCondition = getTsfWhereCondition(settings/*, getRecordTypes(settings.selectedView)*/);

        Set<Id> accountIds = getAccountsIdsByTerritory(tsfWhereCondition, settings);

        List<AccountWrapperItem> items = new List<AccountWrapperItem>();

        if(accountIds.isEmpty()){
            return new AccountWrapper(0, null, settings.columnsHeaders, settings.columnsHeadersType);
        }

        String accountsToInQuery = GNE_SFA2_Util.createInListForQuery(accountIds);
        String tsfSelectStatement = getTsfSelectStatementByViewColumns(settings);

        if(settings.sortColumn.startsWith('TSF') || settings.sortColumn.startsWith('Account') || settings.sortColumn.startsWith('Address')){
            List<TSF_vod__c> tsfes = getSortedTSFsByViewColumns(accountId, settings, tsfSelectStatement, tsfWhereCondition, accountsToInQuery);
            String accountsIdsAsString = GNE_SFA2_Util.createInListForQuery(getAccountsIds(tsfes));
            items = prepareWrappers(tsfes);
        }

        return new AccountWrapper(accountIds.size(), items, settings.columnsHeaders, settings.columnsHeadersType);

    }

    private static List<AccountWrapperItem> prepareWrappers(List<TSF_vod__c> tsfes/*, Map<Id, Map<Id, Product_Metrics_vod__c>> brandAffiliations*/){
        List<AccountWrapperItem> result = new List<AccountWrapperItem>();
        if(tsfes != null && tsfes.size() > 0){
            for(TSF_vod__c tsf : tsfes){
                result.add(new AccountWrapperItem(tsf.Account_vod__c, tsf.Account_vod__r, tsf.Address_vod__r/*, brandAffiliations.get(tsf.Account_vod__c)*/, tsf));
            }
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

    private static List<TSF_vod__c> getSortedTSFsByViewColumns(String accountId, SettingsWrapper settings, String tsfSelectStatement, String tsfWhereCondition, String territoryAccountsIdsAsString){
        List<TSF_vod__c> result = new List<TSF_vod__c>();
        String query = tsfSelectStatement + ' WHERE ' + tsfWhereCondition;
        query += ' AND Account_vod__r.IsPersonAccount = false AND External_Id_vod__c != null AND Address_vod__c != null AND Account_vod__c In ' + territoryAccountsIdsAsString;

        if(String.isNotBlank(accountId)) {
            query += ' AND Account_vod__c !=: accountId ';
            if(settings.page == 1) {
                String selectedAccountQuery = tsfSelectStatement + ' WHERE ' + tsfWhereCondition + ' AND Account_vod__r.IsPersonAccount = false AND External_Id_vod__c != null AND Address_vod__c != null AND Account_vod__c =: accountId ';
                result.addAll((List<TSF_vod__c>)Database.query(selectedAccountQuery));
            }
        }

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
        result.addAll((List<TSF_vod__c>)Database.query(query));

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

        System.debug('## tsfQuery ##');
        System.debug(tsfQuery);

        return accountsIds;
    }

    private static String getTsfWhereCondition(SettingsWrapper settings/*, List<String> recordTypes*/) {
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
            query += ' AND ((' + settings.tsfToAccountRelName + '.Name like \'%'+settings.searchValue+'%\') OR (' + settings.tsfToAccountRelName + '.MDMID_gne__c like \'%'+settings.searchValue+'%\') OR (' + settings.tsfToAccountRelName + '.Name_and_Address_gne__c like \'%'+settings.searchValue+'%\') OR (' + settings.tsfToAccountRelName + '.RecordType.Name like \'%'+settings.searchValue+'%\')) ';
        }

        query += ' AND ' + settings.tsfToAccountRelName + '.isPersonAccount = false';

        System.debug('## Query ##');
        System.debug(query);

        return query;
    }

    private static String getFilterStatement(String filterColumn){
        String query = ' AND ' + filterColumn;
        return query;
    }

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
        public Set<String> productsInViewColumns { get; private set; }
        public List<String> viewColumns { get; private set; }
        public FieldReference fieldReferenceMaps { get; private set; }
        public Map<String, String> columnsHeaders { get; private set; }
        public Map<String, String> columnsHeadersType { get; private set; }
        public List<String> accountFilterColumns { get; private set; }
        public List<String> addressFilterColumns { get; private set; }
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
            this.viewColumns                    = new List<String>{'Account.Name','Account.Name_and_Address_gne__c','Account.RecordTypeId','Account.MDMID_gne__c'};
            this.fieldReferenceMaps             = this.prepareFieldReferenceMaps(this.viewColumns);
            this.columnsHeaders                 = new Map<String, String>{'Account.Name' => 'Name', 'Account.Name_and_Address_gne__c' => 'Address', 'Account.RecordTypeId' => 'Record Type', 'Account.MDMID_gne__c' => 'MDM Id'};
            this.columnsHeadersType             = this.getViewColumnsHeadersType(this.viewColumns);

            this.accountFilterColumns           = new List<String>();
            this.addressFilterColumns           = new List<String>();
            this.tsfFilterColumns               = new List<String>();

            if(String.isEmpty(this.sortColumn)) {
                this.sortColumn                 = this.getSortColumnBySelectedView(this.selectedView);
            }

            this.objectsToQuery                 = this.getObjectsToQueryByAllColumns(this.viewColumns, this.accountFilterColumns, this.addressFilterColumns, /*this.brandAffiliationFilterColumns,*/ this.sortColumn);
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
                }
            }

            return new FieldReference(fieldOfUserReferenceMap, userReferenceHasExist, fieldReferenceToExportMap, fieldReferenceToExportHasExist);
        }


        private Map<String, String> getViewColumnsHeaders(List<String> columnsNames){
            Map<Id, Product_vod__c> productIdToProduct = new Map<Id, Product_vod__c>([ SELECT Id, Name FROM Product_vod__c WHERE Id IN :productsInViewColumns ]);
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
            System.debug(Logginglevel.ERROR,'JL2 filters: '+filters);
            return filters;
        }


        private String getSortColumnBySelectedView(SFA2_View_Config_gne__c selectedView){
            String sortingField = '';
            if(selectedView.Sorting_Field_gne__c != null && selectedView.Sorting_Field_gne__c != ''){
                sortingField = selectedView.Sorting_Field_gne__c;
            }
            return sortingField;
        }

        private Set<String> getObjectsToQueryByAllColumns(List<String> viewColumns, List<String> accountFilterColumns, List<String> addressFilterColumns, /*List<String> brandAffiliationFilterColumns, */String sortColumn){
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

    private class TerritoryWrapper {

        public String territoryId { get; private set; }
        public String parentId { get; private set; }
        public String name { get; private set; }
        public Map<String, TerritoryWrapper> territoryChildren { get; private set; }

        public TerritoryWrapper(String territoryId, String parentId, String name, Map<String, TerritoryWrapper> territoryChildren) {
            this.territoryId = territoryId;
            this.parentId = parentId;
            this.name = name;
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

    public class AccountWrapper {

        public Integer countItems { get; private set; }
        public List<AccountWrapperItem> items { get; private set; }
        public Map<String, String> columnsHeaders { get; private set; }
        public Map<String, String> columnsHeadersType { get; private set; }

        public AccountWrapper(Integer countItems, List<AccountWrapperItem> items, Map<String, String> columnsHeaders, Map<String, String> columnsHeadersType){
            this.countItems         = countItems;
            this.items              = items;
            this.columnsHeaders     = columnsHeaders;
            this.columnsHeadersType = columnsHeadersType;
        }

    }

    public class AccountWrapperItem {
        public Boolean selected {get; set;}
        public Id accountId {get; set;}
        public Account account {get; set;}
        public Address_vod__c address {get; set;}
        public TSF_vod__c tsf {get; set;}

        public AccountWrapperItem(){}

        public AccountWrapperItem(Id accountId, Account account, Address_vod__c address, /*Map<Id, Product_Metrics_vod__c> brandAffiliation,*/ TSF_vod__c tsf){
            this.selected = false;
            this.accountId = accountId;
            this.account = account;
            this.address = address;
            this.tsf = tsf;
        }
    }

}