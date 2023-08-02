public with sharing class GNE_MCCO_CRM_Field_Intelligence_Ctrl {

    public String viewId { get; private set; }
    private List<SFA2_View_Config_gne__c> viewsList { get; set; }
    private SFA2_User_Preferences_gne__c preferences { get; set; }

    public Boolean hasViews { get; private set; }

    public String viewsJson { get; private set; }
    public String preferencesJson { get; private set; }
    public String accountIds { get; private set; }

    public Set<String> territoriesNames { get; private set; }

    public String userTimeZone { get; private set; }

    public String iconBase64 { get; private set; }

    public Boolean isAccount { get; private set; }
    public Boolean accountValid { get; private set; }
    private Id accountId { get; set; }
    public Account account { get; private set; }
    private String profileName { get; private set; }

    public GNE_MCCO_CRM_Field_Intelligence_Ctrl() {

        isAccount = false;
        hasViews = false;

        viewId = (ApexPages.currentPage().getParameters().get('view') != null && ApexPages.currentPage().getParameters().get('view') != '') ? ApexPages.currentPage().getParameters().get('view') : null;
        accountId = (ApexPages.currentPage().getParameters().get('accountId') != null && ApexPages.currentPage().getParameters().get('accountId') != '') ? ApexPages.currentPage().getParameters().get('accountId') : null;

        iconBase64 = GNE_MCCO_CRM_Util.getDocumentBase64('GNE_MCCO_CRM_Survey_Builder_Icon');
        userTimeZone = String.valueOf(UserInfo.getTimeZone());
        profileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1].Name;
        if (accountId == null) {
            viewsList = GNE_MCCO_CRM_Util.getViews('Field Intelligence');
            preferences = GNE_MCCO_CRM_Util.getUserPreferences('Field Intelligence');
            territoriesNames = getUserTerritories();
            preferencesJson = JSON.serializePretty(preferences);
            viewsJson = JSON.serializePretty(viewsList);
            accountIds = getUserAccountIds();

            if (viewsList.size() > 0) {
                hasViews = true;
            }

        } else {
            isAccount = true;
            try {
                account = [SELECT Id, Name FROM Account WHERE Id = :accountId LIMIT 1][0];
                accountValid = true;
            } catch (Exception ex) {
                accountValid = false;
            }
        }
    }

    public Boolean getisPanelVisible() {
        return GNE_SFA2_Util.isCCCrmUser() || GNE_SFA2_Util.isCrmFrmUser();

    }

    private Set<String> getUserTerritories() {
        Set<String> result = new Set<String>();
        List<Territory2> userTopTerritories = [SELECT Id, Name FROM Territory2 WHERE Id IN (SELECT Territory2Id FROM UserTerritory2Association WHERE UserId = :UserInfo.getUserId()) ORDER BY Name DESC];
        if (userTopTerritories.size() > 0) {
            for (Territory2 t : userTopTerritories) {
                result.add(t.Name);
            }
            result.addAll(getChildrenTerritories(userTopTerritories));
        }
        return result;
    }

    private Set<String> getChildrenTerritories(List<Territory2> parentTerritories) {
        Set<String> result = new Set<String>();
        List<Territory2> childrenTerritories = [SELECT Id, Name, ParentTerritory2Id FROM Territory2 WHERE ParentTerritory2Id IN :parentTerritories ORDER BY ParentTerritory2Id];
        if (childrenTerritories.size() > 0) {
            for (Territory2 t : childrenTerritories) {
                result.add(t.Name);
            }
            result.addAll(getChildrenTerritories(childrenTerritories));
        }
        return result;
    }

    @RemoteAction
    public static Boolean updateViewPreference(String viewId) {
        return GNE_MCCO_CRM_Util.updateViewPreference(viewId, 'Field Intelligence');
    }

    @RemoteAction
    @ReadOnly
    public static FieldIntelligenceWrapper loadFieldIntelligence(String selectedViewJson, String territoriesJson, Integer page, String sortColumn, String sortDirection, String searchValue) {
        SettingsWrapper settings = new SettingsWrapper(selectedViewJson, territoriesJson, page, sortColumn, sortDirection, searchValue);

        List<String> filterStatements = GNE_MCCO_CRM_Util.getFiltersBySelectedView(settings.selectedView);

        String query = createQuery(settings, filterStatements, searchValue);
        List<GNE_MCCO_CRM_Field_Intelligence__c> items;
        if (query != null) {
            items = Database.query(query);
        } else {
            items = new List<GNE_MCCO_CRM_Field_Intelligence__c>();
        }

        if (items.size() > 0) {
            Boolean hasNextPage = (items.size() > settings.pageSize) ? true : false;
            return new FieldIntelligenceWrapper(hasNextPage, items, settings.columnsHeaders, settings.columnsHeadersType);
        } else {
            return new FieldIntelligenceWrapper(false, null, settings.columnsHeaders, settings.columnsHeadersType);
        }

    }

    @RemoteAction
    @ReadOnly
    public static FieldIntelligenceWrapper loadFieldIntelligenceByAccount(String accountId, Integer page, Integer pageSize, String sortColumn, String sortDirection) {
        if (accountId != '') {
            Integer offset = (pageSize * page) - pageSize;

            String query = 'SELECT Id, Name, Survey_gne__r.Record_Type_gne__c, User_gne__c, User_gne__r.Name, Survey_Status_gne__c, Title_gne__c, LastModifiedBy.Id, LastModifiedBy.Name, LastModifiedDate, CreatedBy.Id, CreatedBy.Name, CreatedDate';

            query += ' FROM GNE_MCCO_CRM_Field_Intelligence__c WHERE Account_gne__c = \'' + accountId + '\' AND Survey_gne__r.Ready_To_Use_gne__c = true AND Available_gne__c = true';

            query += ' ORDER BY ' + sortColumn + ' ' + sortDirection + setNullsBySortDirection(sortDirection);
            query += ' LIMIT ' + (pageSize + 1) + ' OFFSET ' + offset;

            List<GNE_MCCO_CRM_Field_Intelligence__c> items = Database.query(query);

            Boolean hasNextPage = (items.size() > pageSize) ? true : false;

            return new FieldIntelligenceWrapper(hasNextPage, items, null, null);
        } else {
            return new FieldIntelligenceWrapper(false, null, null, null);
        }
    }

    private static String createQuery(SettingsWrapper settings, List<String> filterStatements, String searchValue) {
        Integer offset = (settings.pageSize * settings.page) - settings.pageSize;
        String accountIds = settings.accountIds;
        if (String.isNotBlank(searchValue)) {
            accountIds = '';
            String query = 'SELECT Id FROM ACCOUNT WHERE Id IN (' + settings.accountIds + ') AND Name LIKE \'%' + searchValue + '%\'';
            System.debug(query);
            for (Account account : Database.query(query)) {
                accountIds += '\'' + account.Id + '\',';
            }
            accountIds = accountIds.removeEnd(',');
        }
        System.debug('accountIds after: ' + accountIds);
        String query = 'SELECT ';

        for (String val : settings.selectedView.View_Fields_gne__c.split(';')) {
            if (val == 'CreatedById') {
                query += 'CreatedBy.Name, CreatedDate, ';
            } else if (val == 'LastModifiedById') {
                query += 'LastModifiedBy.Name, LastModifiedDate, ';
            }
            query += val + ', ';
        }
        query = query.removeEnd(', ');

        query += ' FROM GNE_MCCO_CRM_Field_Intelligence__c WHERE ';

        if (String.isNotBlank(searchValue)) {
            if (String.isNotBlank(accountIds)) {
                query += 'User_gne__c = \'' + UserInfo.getUserId() + '\' AND Account_gne__c IN (' + accountIds + ')';
            } else {
                return null;
            }
        } else if (String.isNotBlank(accountIds)) {
            query += '(User_gne__c = \'' + UserInfo.getUserId() + '\' OR (Account_gne__c IN (' + accountIds + ') AND User_gne__c = \'' + UserInfo.getUserId() + '\'))';
        }
        query += ' AND Survey_gne__r.Ready_To_Use_gne__c = true AND Available_gne__c = true AND ';

        if (filterStatements.size() > 0) {
            for (String filterColumn : filterStatements) {
                query += GNE_MCCO_CRM_Util.getFilterStatement(filterColumn);
            }
        }

        query = query.removeEnd(' AND ');

        query += ' ORDER BY ' + settings.sortColumn + ' ' + settings.sortDirection + setNullsBySortDirection(settings.sortDirection);
        query += ' LIMIT ' + (settings.pageSize + 1) + ' OFFSET ' + offset;

        System.debug(' # QUERY #');
        System.debug(query);

        return query;
    }

    private String getUserAccountIds() {
        String result = '';

        Set<Id> territoriesIds = new Set<Id>();
        List<TSF_vod__c> tsfs;
        if (profileName != 'GNE-SFA-CC') {
            tsfs = [SELECT Account_vod__c FROM TSF_vod__c WHERE External_Id_vod__c != NULL AND Address_vod__c != NULL AND Territory_vod__c IN :territoriesNames AND Account_vod__r.IsPersonAccount = FALSE LIMIT :GNE_MCCO_CRM_Util.RECORDS_LIMIT];
        } else {
            tsfs = [SELECT Account_vod__c FROM TSF_vod__c WHERE External_Id_vod__c != NULL AND Address_vod__c != NULL AND Territory_vod__c IN :territoriesNames LIMIT :GNE_MCCO_CRM_Util.RECORDS_LIMIT];
        }
        for (TSF_vod__c tsf : tsfs) {
            result += '\'' + tsf.Account_vod__c + '\',';
        }

        result = result.removeEnd(',');

        return result;
    }

    private static String setNullsBySortDirection(String sortDirection) {
        return sortDirection == 'DESC' ? ' NULLS LAST ' : ' NULLS FIRST ';
    }

    @TestVisible
    private class FieldIntelligenceWrapper {

        public Boolean hasNextPage { get; private set; }
        public List<GNE_MCCO_CRM_Field_Intelligence__c> items { get; private set; }

        public Map<String, String> columnsHeaders { get; private set; }
        public Map<String, String> columnsHeadersType { get; private set; }

        public FieldIntelligenceWrapper(Boolean hasNextPage, List<GNE_MCCO_CRM_Field_Intelligence__c> items, Map<String, String> columnsHeaders, Map<String, String> columnsHeadersType) {
            this.hasNextPage = hasNextPage;
            this.items = items;
            this.columnsHeaders = columnsHeaders;
            this.columnsHeadersType = columnsHeadersType;
        }

    }

    private class SettingsWrapper {

        public SFA2_View_Config_gne__c selectedView { get; private set; }
        public String accountIds { get; private set; }
        public Integer page { get; private set; }
        public Integer pageSize = GNE_MCCO_CRM_Util.PAGE_SIZE;
        public String sortColumn { get; private set; }
        public String sortDirection { get; private set; }
        public String searchValue { get; private set; }

        public Map<String, String> columnsHeaders { get; private set; }
        public Map<String, String> columnsHeadersType { get; private set; }

        public SettingsWrapper(String selectedViewJson, String accountIds, Integer page, String sortColumn, String sortDirection, String searchValue) {
            this.selectedView = this.encodeSelectedView(selectedViewJson);
            this.accountIds = accountIds;
            this.page = page;

            if (sortColumn == 'LastModifiedById') {
                this.sortColumn = 'LastModifiedDate';
            } else if (sortColumn == 'CreatedById') {
                this.sortColumn = 'CreatedDate';
            } else {
                this.sortColumn = sortColumn;
            }

            this.sortDirection = sortDirection;
            this.columnsHeaders = this.getViewColumnsHeaders(this.selectedView);
            this.columnsHeadersType = this.getViewColumnsHeadersType(this.selectedView);
            this.searchValue = searchValue;
        }

        private SFA2_View_Config_gne__c encodeSelectedView(String jsonString) {
            JSONParser parser = JSON.createParser(jsonString);
            SFA2_View_Config_gne__c result = (SFA2_View_Config_gne__c) parser.readValueAs(SFA2_View_Config_gne__c.class);
            return result;
        }

        private Map<String, String> getViewColumnsHeaders(SFA2_View_Config_gne__c view) {
            Map<String, String> columnHeaders = new Map<String, String>();

            for (String column : view.View_Fields_gne__c.split(';', 0)) {
                String fieldName = column.substring(column.indexOf('.') + 1);
                if (column.startsWith('Survey_gne__r')) {
                    if (column == 'Survey_gne__r.Record_Type_gne__c') {
                        columnHeaders.put(column, 'Survey Type');
                    } else {
                        Schema.DescribeFieldResult fieldDescribe = Schema.getGlobalDescribe().get('GNE_MCCO_CRM_Survey__c').getDescribe().fields.getMap().get(fieldName).getDescribe();
                        columnHeaders.put(column, fieldDescribe.getLabel());
                    }
                } else if (column.startsWith('Account_gne__r')) {
                    if (column == 'Account_gne__r.Name') {
                        columnHeaders.put(column, 'Account');
                    } else {
                        Schema.DescribeFieldResult fieldDescribe = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().get(fieldName).getDescribe();
                        columnHeaders.put(column, fieldDescribe.getLabel());
                    }
                } else {
                    if (column == 'LastModifiedById') {
                        columnHeaders.put(column, 'Last Modified By');
                    } else if (column == 'CreatedById') {
                        columnHeaders.put(column, 'Created By');
                    } else {
                        Schema.DescribeFieldResult fieldDescribe = Schema.getGlobalDescribe().get('GNE_MCCO_CRM_Field_Intelligence__c').getDescribe().fields.getMap().get(fieldName).getDescribe();
                        columnHeaders.put(column, fieldDescribe.getLabel());
                    }
                }

            }

            return columnHeaders;
        }

        private Map<String, String> getViewColumnsHeadersType(SFA2_View_Config_gne__c view) {
            Map<String, String> columnHeaders = new Map<String, String>();

            for (String column : view.View_Fields_gne__c.split(';', 0)) {
                String fieldName = column.substring(column.indexOf('.') + 1);
                if (column.startsWith('Survey_gne__r')) {
                    Schema.DisplayType type = Schema.getGlobalDescribe().get('GNE_MCCO_CRM_Survey__c').getDescribe().fields.getMap().get(fieldName).getDescribe().getType();
                    columnHeaders.put(column, type.name());
                } else if (column.startsWith('Account_gne__r')) {
                    Schema.DisplayType type = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().get(fieldName).getDescribe().getType();
                    columnHeaders.put(column, type.name());
                } else {
                    Schema.DisplayType type = Schema.getGlobalDescribe().get('GNE_MCCO_CRM_Field_Intelligence__c').getDescribe().fields.getMap().get(fieldName).getDescribe().getType();
                    columnHeaders.put(column, type.name());
                }

            }

            return columnHeaders;
        }

    }

}