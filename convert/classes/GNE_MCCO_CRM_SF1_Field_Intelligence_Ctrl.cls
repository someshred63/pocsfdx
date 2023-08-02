public with sharing class GNE_MCCO_CRM_SF1_Field_Intelligence_Ctrl {

	public static final String ACCT_PREFIX = '001';

    private final static Integer RECORDS_LIMIT = 45000;
    public final Integer PAGE_SIZE { get; private set; }

    private final List<SFA2_View_Config_gne__c> VIEWS_LIST { get; set; }
    private final List<Territory2> TERRITORIES_LIST { get; set; }
    public final Set<String> TERRITORY_NAMES_SET { get; private set; }
    public final String ACCOUNT_IDS { get; private set; }

    public Boolean hasViews { get; private set; }
    public String viewsJson { get; private set; }
    public Id fieldIntelligenceLogoId { get; private set; }
    public SFA2_View_Config_gne__c selectedView { get; private set; }
    public String selectedViewId { get; private set; }
    public String selectedViewJson { get; private set; }

    public String userTimeZone { get; private set; }

    public GNE_MCCO_CRM_SF1_Field_Intelligence_Ctrl() {

        hasViews = false;

        try {

            selectedViewId      = (ApexPages.currentPage().getParameters().get('view') != null && ApexPages.currentPage().getParameters().get('view') != '') ? ApexPages.currentPage().getParameters().get('view') : null;

            PAGE_SIZE           = 25;
            VIEWS_LIST          = GNE_MCCO_CRM_Util.getViews('Field Intelligence');
            TERRITORIES_LIST    = GNE_SFA2_Util.getUserTerritories(UserInfo.getUserId());
            TERRITORY_NAMES_SET = getTerritoryNames();
            ACCOUNT_IDS         = JSON.serializePretty(getUserAccountIds());

            userTimeZone        = String.valueOf(UserInfo.getTimeZone());
            viewsJson           = JSON.serializePretty(VIEWS_LIST);

            fieldIntelligenceLogoId = [SELECT Id FROM Document WHERE DeveloperName = 'GNE_MCCO_CRM_SF1_Field_Intelligence_Tab' LIMIT 1].Id;

            if(VIEWS_LIST.size() > 0) {
                hasViews = true;
            }

            if(hasViews) {

                for(SFA2_View_Config_gne__c view : VIEWS_LIST) {
                    if(selectedViewId == view.Id) {
                        selectedView = view;
                    }
                }

                if(selectedView == null) {
                    selectedView = VIEWS_LIST[3];
                }

                selectedViewJson = JSON.serializePretty(selectedView);

            } else {

                selectedViewJson = JSON.serializePretty(new SFA2_View_Config_gne__c());

            }

        } catch(Exception ex) {
            hasViews = false;
            System.debug(Logginglevel.ERROR, ex.getMessage());
        }

    }

    private Set<String> getTerritoryNames() {
        Set<String> result = new Set<String>();
        for(Territory2 t : TERRITORIES_LIST) {
            result.add(t.Name);
        }
        return result;
    }

    private Set<String> getUserAccountIds() {
        Set<String> result = new Set<String>();
        for(TSF_vod__c tsf : [SELECT Account_vod__c FROM TSF_vod__c WHERE External_Id_vod__c != null AND Address_vod__c != null AND Territory_vod__c IN :TERRITORY_NAMES_SET AND Account_vod__r.IsPersonAccount = false LIMIT :RECORDS_LIMIT]) {
    		String minAcctId = String.valueOf(tsf.Account_vod__c).substring(3, 4) + String.valueOf(tsf.Account_vod__c).substring(8, 18);
            if (!result.contains(minAcctId)) {
                result.add(minAcctId);
            }
        }
        return result;
    }

    @RemoteAction
    public static Integer getFieldIntelligenceCount(String accountIdsJson, String viewJson, String searchValue) {

        Id userId = UserInfo.getUserId();

        SFA2_View_Config_gne__c selectedView = (SFA2_View_Config_gne__c)JSON.deserialize(viewJson, SFA2_View_Config_gne__c.class);
        Set<String> accountIds = (Set<String>)JSON.deserialize(accountIdsJson, Set<String>.class);

        List<String> acctIds = new List<String>();
        for (String s : accountIds) {
            acctIds.add(ACCT_PREFIX + s.substring(0, 1) + '0000' + s.substring(1));
        }

        List<String> filterStatements = GNE_MCCO_CRM_Util.getFiltersBySelectedView(selectedView);

        String query = 'SELECT COUNT() FROM GNE_MCCO_CRM_Field_Intelligence__c WHERE (User_gne__c = :userId OR (Account_gne__c IN :acctIds AND User_gne__c = :userId)) AND Survey_gne__r.Ready_To_Use_gne__c = true AND Available_gne__c = true AND ';

        if (!String.isEmpty(searchValue)) {
            query += ' (';
            query += 'Name LIKE \'%' + searchValue + '%\'';
            query += ' OR Account_gne__r.Name LIKE \'%' + searchValue + '%\'';
            query += ' OR Title_gne__c LIKE \'%' + searchValue + '%\'';
            query += ' OR Survey_gne__r.Record_Type_gne__c LIKE \'%' + searchValue + '%\'';
            query += ') AND ';
        }

        if(filterStatements.size() > 0) {
            for(String filterColumn : filterStatements){
                query += GNE_MCCO_CRM_Util.getFilterStatement(filterColumn);
            }
        }

        query = query.removeEnd(' AND ');

        System.debug('##### Query === ' + query);

        return Database.countQuery(query);
    }

    @RemoteAction
    public static List<FieldIntelligenceWrapper> getFieldIntelligences(String accountIdsJson, Integer displayLength, Integer displayStart, String viewJson, String searchValue) {

        List<FieldIntelligenceWrapper> result = new List<FieldIntelligenceWrapper>();

        Id userId = UserInfo.getUserId();

        SFA2_View_Config_gne__c selectedView = (SFA2_View_Config_gne__c)JSON.deserialize(viewJson, SFA2_View_Config_gne__c.class);
        Set<String> accountIds = (Set<String>)JSON.deserialize(accountIdsJson, Set<String>.class);

        List<String> acctIds = new List<String>();
        for (String s : accountIds) {
            acctIds.add(ACCT_PREFIX + s.substring(0, 1) + '0000' + s.substring(1));
        }

        List<String> filterStatements = GNE_MCCO_CRM_Util.getFiltersBySelectedView(selectedView);

        String query = 'SELECT Id, Name, Title_gne__c, Account_gne__r.Name, Account_gne__c, Survey_Status_gne__c, Survey_gne__r.Record_Type_gne__c, LastModifiedDate FROM GNE_MCCO_CRM_Field_Intelligence__c WHERE (User_gne__c = :userId OR (Account_gne__c IN :acctIds AND User_gne__c = :userId)) AND Survey_gne__r.Ready_To_Use_gne__c = true AND Available_gne__c = true AND ';

        if (!String.isEmpty(searchValue)) {
            query += ' (';
            query += 'Name LIKE \'%' + searchValue + '%\'';
            query += ' OR Account_gne__r.Name LIKE \'%' + searchValue + '%\'';
            query += ' OR Title_gne__c LIKE \'%' + searchValue + '%\'';
            query += ' OR Survey_gne__r.Record_Type_gne__c LIKE \'%' + searchValue + '%\'';
            query += ') AND ';
        }

        if(filterStatements.size() > 0) {
            for(String filterColumn : filterStatements){
                query += GNE_MCCO_CRM_Util.getFilterStatement(filterColumn);
            }
        }

        query = query.removeEnd(' AND ');

        query += ' ORDER BY LastModifiedDate DESC';
        query += ' LIMIT ' +  displayLength;
        if (displayStart > 0) {
            query += ' OFFSET ' + displayStart;
        }

        System.debug('##### Query === ' + query);

        for (GNE_MCCO_CRM_Field_Intelligence__c fi : Database.query(query)) {
            result.add(new FieldIntelligenceWrapper(fi.Id, fi.Name, fi.Title_gne__c, fi.Account_gne__r.Name, fi.Account_gne__c, fi.Survey_Status_gne__c, fi.Survey_gne__r.Record_Type_gne__c, fi.LastModifiedDate));
        }

        return result;
    }


    /* WRAPPER CLASS */

    public class FieldIntelligenceWrapper {

        private Id id {get; set;}
        private String name {get; set;}
        private String title {get; set;}
        private String accountName {get; set;}
        private Id accountId {get; set;}
        private String status {get; set;}
        private String surveyType {get; set;}
        private Datetime lastModifiedDate {get; set;}

        public FieldIntelligenceWrapper(Id id, String name, String title, String accountName, Id accountId, String status, String surveyType, Datetime lastModifiedDate) {
            this.id             = id;
            this.name           = name;
            this.title          = title;
            this.accountName    = accountName;
            this.accountId      = accountId;
            this.status         = status;
            this.surveyType     = surveyType;
            this.lastModifiedDate = lastModifiedDate;
        }
    }
}