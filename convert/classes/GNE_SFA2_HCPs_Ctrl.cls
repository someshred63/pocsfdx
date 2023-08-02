/************************************************************
*  @author: Lukasz Kozminski, Roche
*  Date: 2012-08-13
*  This is a My Accounts Page (tab) controller
*
*  Modification History
*  Date        Name        Description
*************************************************************/

public with sharing class GNE_SFA2_HCPs_Ctrl {

    private static final Integer CLIENT_SIDE_LIMIT = 2000;

    public Boolean isServerSide {get; set;}
    public List<SelectOption> territoriesSelectOptions {get; set;}
    public String territoryId {get; set;}
    public Boolean userTerritoriesExist {get; set;}
    public List<TSF_vod__c> tsfsInExport {get; set;}
    private Boolean isExportToExcel = false;
    private SFA2_User_Preferences_gne__c myPreferences;

    // ONBOARDING
    public RequestWrapper request {get; set;}
    public Boolean hasProducts {get; private set;}
    public String webBrowser { get; set; }

    public GNE_SFA2_HCPs_Ctrl() {
        this(false);
    }

    public GNE_SFA2_HCPs_Ctrl(Boolean isExportToExcel) {
        this.isExportToExcel = isExportToExcel;
        List<Territory2> userTerritories = GNE_SFA2_Util.getUserTerritories(UserInfo.getUserId());

        Set<Id> userTerritoriesIds = new Set<Id>();
        List<String>territories = new List<String>();

        for (Territory2 terr : userTerritories) {
            userTerritoriesIds.add(terr.Id);
            territories.add(terr.Name);
        }
        userTerritoriesExist =  userTerritories != null && userTerritories.size() > 0;

        if(!userTerritoriesExist) {
            request = new RequestWrapper([SELECT Id, FirstName, LastName, Email, Phone, External_ID_gne__c FROM User WHERE Id = : Userinfo.getUserId() LIMIT 1]);
        }

        SFA2_User_Preferences_gne__c myPreferences;
        try {
            myPreferences = [SELECT Last_Territory_Used_gne__c FROM  SFA2_User_Preferences_gne__c WHERE Last_View_Used_gne__r.Page_Name_gne__c = 'My Accounts' AND User_gne__c = :Userinfo.getUserId() LIMIT 1];
        } catch (Exception e) {
            //ignore
        }
        if (userTerritoriesExist) {
            if (myPreferences != null && String.isNotEmpty(myPreferences.Last_Territory_Used_gne__c) && userTerritoriesIds.contains(myPreferences.Last_Territory_Used_gne__c)) {
                territoryId = myPreferences.Last_Territory_Used_gne__c;
            } else {
                territoryId = userTerritories.get(0).id;
            }
        }
        territoriesSelectOptions = prepareSelectOptions(userTerritories);

        Integer accountsInTerritories = getAccountsInTerritoriesNumber(territories);
        isServerSide = accountsInTerritories > CLIENT_SIDE_LIMIT;

        if(!userTerritoriesExist) {
            onboardingVariablesInit();
        }
    }

    private Integer getAccountsInTerritoriesNumber(List<String> territories) {
        return [SELECT count() FROM TSF_vod__c WHERE Territory_vod__c In :territories AND Address_vod__c <> null AND Account_vod__c <> null AND External_Id_vod__c <> null AND Account_vod__r.IsPersonAccount = true LIMIT 40000];
    }

    @RemoteAction
    @ReadOnly
    public static Response getDataServerSide(List<Map<String, Object>> request) {
        Params p = new Params(request);
        List<String>territories = GNE_SFA2_HCP_Helper.getTerritoriesHierarchicalNames(p.territoryId);
        String searchCondition = '';
        if (!String.isEmpty(p.searchText)) {
            String sText = '%' + p.searchText + '%';
            List<String>searchTerms = new List<String>();
            Boolean isFirstTerm = true;
            if (!String.isEmpty(sText)) {
                searchCondition = ' AND (';
                for (String term : sText.split('\\s+')) {
                    if (!isFirstTerm) {
                        searchCondition += ' OR ';
                    }
                    searchCondition += ' Account_vod__r.LastName LIKE \'' + term + '\' OR Account_vod__r.FirstName LIKE \'' + term + '\' OR Address_vod__r.Name LIKE \'' + term + '\' OR Address_vod__r.City_vod__c LIKE \'' + term + '\' OR Address_vod__r.State_vod__c  LIKE \'' + term + '\'';
                    isFirstTerm = false;
                }
                searchCondition += ' )';
            }

        }

        if (!String.isEmpty(p.sSearch_1)) {
            String sText = p.sSearch_1 + '%';
            searchCondition += ' AND Account_vod__r.LastName LIKE \'' + sText + '\'';
        }
        String orderBy = String.join(orderBys(p), ', ');
        String orderByColumn = orderBy.substring(0, orderBy.indexOf(' '));

        String soql = 'SELECT Account_vod__c FROM TSF_vod__c'
                      + ' WHERE Territory_vod__c In :territories AND Address_vod__c <> null AND Account_vod__c <> null AND External_Id_vod__c <> null AND Account_vod__r.IsPersonAccount=true'
                      + searchCondition
                      + ' GROUP BY Account_vod__c, ' + orderByColumn
                      + ' ORDER BY ' + orderBy
                      + ' LIMIT :length'
                      + ' OFFSET :start';


        String countQueryStr = 'SELECT COUNT_DISTINCT(Account_vod__c) FROM TSF_vod__c WHERE Territory_vod__c In :territories AND Address_vod__c <> null AND Account_vod__c <> null AND External_Id_vod__c <> null AND Account_vod__r.IsPersonAccount=true'
                               + searchCondition;

        Integer length = p.length;
        Integer start = p.start;

        Set<Id>accountIds = new Set<Id>();
        for (AggregateResult ar :  Database.query(soql)) {
            accountIds.add((Id)ar.get('Account_vod__c'));
        }

        String soqlQuery = 'SELECT Id, Account_vod__c, Account_vod__r.LastName, Account_vod__r.FirstName, Address_vod__r.Name, Address_vod__r.City_vod__c, Address_vod__r.State_vod__c, Account_vod__r.Status_gne__c, Last_Interaction_Date_gne__c, Address_vod__c FROM TSF_vod__c';
        soqlQuery += ' WHERE Account_vod__c In :accountIds AND Territory_vod__c In :territories AND Address_vod__c <> null AND Account_vod__c <> null AND External_Id_vod__c <> null AND Account_vod__r.IsPersonAccount=true'
                     + searchCondition + ' ORDER BY ' + orderBy;

        List<TSF_vod__c> result = preparaTSFResult(Database.query(soqlQuery), territories);
        Integer countResult = (Integer)Database.query(countQueryStr).get(0).get('expr0');
        return new Response(p.echo, countResult, result);
    }

    @RemoteAction
    @ReadOnly
    public static Response getDataClientSide(List<Map<String, Object>> request) {
        String territoryId;
        for (Map<String, Object> r : request) {
            String name = (String) r.get('name');
            if (name == 'territoryId') {
                territoryId = (String) r.get('value');
            }
        }
        List<String>territories = GNE_SFA2_HCP_Helper.getTerritoriesHierarchicalNames(territoryId);

        List<TSF_vod__c> tsfs = [
                                    SELECT Id, Account_vod__c, Account_vod__r.LastName, Account_vod__r.FirstName, Address_vod__r.Name, Address_vod__r.City_vod__c, Address_vod__r.State_vod__c, Account_vod__r.Status_gne__c, Last_Interaction_Date_gne__c, Address_vod__c
                                    FROM TSF_vod__c
                                    WHERE Territory_vod__c In :territories
                                    AND Address_vod__c <> null
                                    AND Account_vod__c <> null
                                    AND External_Id_vod__c <> null
                                    AND Account_vod__r.IsPersonAccount = true
                                            LIMIT :CLIENT_SIDE_LIMIT
                                ];

        List<TSF_vod__c> result = preparaTSFResult(tsfs, territories);
        return new Response(result);
    }

    @RemoteAction
    public static void updateUserPreferences(Id territoryId) {
        SFA2_User_Preferences_gne__c myPreferences;
        try {
            myPreferences = [SELECT Last_Territory_Used_gne__c FROM SFA2_User_Preferences_gne__c WHERE Last_View_Used_gne__r.Page_Name_gne__c = 'My Accounts' AND User_gne__c = :Userinfo.getUserId() LIMIT 1];
        } catch (Exception e) {
            List<SFA2_View_Config_gne__c>views = [SELECT Id FROM SFA2_View_Config_gne__c WHERE Page_Name_gne__c = 'My Accounts' LIMIT 1];
            Id viewId = views.isEmpty() ? null : views.get(0).Id;
            myPreferences = new SFA2_User_Preferences_gne__c(User_gne__c = Userinfo.getUserId(), Last_View_Used_gne__c = viewId);
        }
        if (myPreferences.Last_Territory_Used_gne__c != territoryId) {
            myPreferences.Last_Territory_Used_gne__c = territoryId;
            upsert myPreferences;
        }
    }

    private static List<TSF_vod__c> preparaTSFResult(List<TSF_vod__c> tsfs, List<String> territories) {
        List<TSF_vod__c>result = new List<TSF_vod__c>();
        Id currentUserId = UserInfo.getUserId();
        GNE_SFA2_UserPreference_Ctrl upsCtrl = new GNE_SFA2_UserPreference_Ctrl();
        Set<Id> accIds = new Set<Id>();

        for (TSF_vod__c tsf : tsfs) {
            if (accIds.add(tsf.Account_vod__c)) {
                result.add(tsf);
            }
        }

        if (upsCtrl.hasHiddenAddresses(currentUserId, accIds)) {
            Set<Id> hiddenAddrIds = upsCtrl.getHiddenAddressIds(currentUserId, accIds);
            Map<Id, TSF_vod__c> tsfWithHiddenAddresses = new Map<Id, TSF_vod__c>();

            for (TSF_vod__c tsf : result) {
                if (hiddenAddrIds.contains(tsf.Address_vod__c)) {
                    tsfWithHiddenAddresses.put(tsf.Account_vod__c, tsf);
                }
            }

            if (!tsfWithHiddenAddresses.isEmpty()) {
                List<Account> accs = [
                                         SELECT Id, (SELECT Id, Name, City_vod__c, State_vod__c FROM Address_vod__r WHERE ID NOT IN :hiddenAddrIds ORDER BY Name LIMIT 1)
                                         FROM Account
                                         WHERE ID IN :tsfWithHiddenAddresses.keySet()
                                     ];

                for (Account acc : accs) {
                    Address_vod__c addr = acc.Address_vod__r.isEmpty() ? new Address_vod__c() : acc.Address_vod__r[0];
                    TSF_vod__c tsf = tsfWithHiddenAddresses.get(acc.Id);
                    tsf.Address_vod__c = addr.Id;
                    tsf.Address_vod__r = addr;
                }
            }
        }

        return result;
    }

    // prepare select options for territories
    private List<SelectOption> prepareSelectOptions(List<Territory2> territories) {
        List<SelectOption> territoriesSelectOptions = new List<SelectOption>();
        for (Territory2 territory : territories) {
            territoriesSelectOptions.add(new SelectOption(territory.Id, territory.Name));
        }
        return territoriesSelectOptions;
    }

    private String getTerritoryName(String terriotryId) {
        return [SELECT Name FROM Territory2 where id = :terriotryId].Name;
    }

    private String getTerritoryId(String terriotryName) {
        return [SELECT Id FROM Territory2 where Name = :terriotryName LIMIT 1].Id;
    }

    @RemoteAction
    public static void hideAccounts(List<String>tsfIds, String territoryId) {
        GNE_SFA2_HCP_Helper.hideAccounts(tsfIds, territoryId);
    }

    public PageReference exportToExcelClick() {
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_HCPs_Export');
        pageRef.setredirect(false);
        pageRef.getParameters().put('territoryId', territoryId);
        return pageRef;
    }

    // Export to excel methods
    public void exportToExcel() {
        GNE_SFA2_HCPs_Ctrl myAccountsController = new GNE_SFA2_HCPs_Ctrl(true);
        List<String>territories = GNE_SFA2_HCP_Helper.getTerritoriesHierarchicalNames(territoryId);
        tsfsInExport = [SELECT Id, Account_vod__c, Account_vod__r.LastName, Account_vod__r.FirstName, Address_vod__r.Name, Address_vod__r.City_vod__c, Address_vod__r.State_vod__c, Account_vod__r.Status_gne__c, Last_Interaction_Date_gne__c, Address_vod__c FROM TSF_vod__c
                        WHERE Territory_vod__c In :territories AND Address_vod__c <> null AND Account_vod__c <> null AND External_Id_vod__c <> null AND Account_vod__r.IsPersonAccount = true ORDER BY Account_vod__r.LastName LIMIT 1000];

        tsfsInExport = preparaTSFResult(tsfsInExport, territories);
    }

    public String getHostName() {
        String host = ApexPages.CurrentPage().getHeaders().get('host');
        return host;
    }

    public String getFileName() {
        String fileName = 'Customers - ' + String.valueOf(Date.Today());
        return fileName ;
    }

    public String getWorkbookProperties() {
        String workbook = '<x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet><x:Name>My Customers</x:Name><x:WorksheetOptions><x:DisplayGridlines/></x:WorksheetOptions></x:ExcelWorksheet></x:ExcelWorksheets></x:ExcelWorkbook>';
        return workbook;
    }

    public String getActiveMenuItem() {
        String result = 'Customers';
        return result;
    }

    //****SERVER SIDE PROCESSING****//

    // Defines shape of JSON response
    public class Response {
        public Integer sEcho;
        public Integer iTotalRecords;
        public Integer iTotalDisplayRecords;

        public SObject[] aaData;
        Response(Integer echo, Integer total, SObject[] sobs) {
            this.sEcho = echo;
            this.iTotalRecords = total;
            this.iTotalDisplayRecords = total;
            this.aaData = sobs;
        }

        Response(SObject[] sobs) {
            this.aaData = sobs;
        }
    }

    // DataTable passes JSON definition of what server should do
    private class Params {
        Map<String, Object> m = new Map<String, Object>();
        Integer echo;
        Integer start;
        Integer length;
        String[] columns;
        Integer[] sortColumns;
        String[] sortDirections;
        String sSearch_1;
        String searchText;
        Id territoryId;

        Params(List<Map<String, Object>> request) {
            for (Map<String, Object> r : request) {
                m.put((String) r.get('name'), r.get('value'));
            }
            echo = integer('sEcho');
            start = integer('iDisplayStart');
            length = integer('iDisplayLength');
            columns = stringArray('mDataProp');
            sortColumns = integerArray('iSortCol');
            sortDirections = stringArray('sSortDir');
            searchText = toString('sSearch');
            sSearch_1 = toString('sSearch_1');
            territoryId = toString('territoryId');
        }

        String[] stringArray(String prefix) {
            String[] strings = new String[] {};
            for (Object o : array(prefix)) {
                strings.add(o != null ? esc(String.valueOf(o)) : null);
            }
            return strings;
        }

        String toString(String name) {
            Object o = m.get(name);
            if (o instanceof String) {
                return (String) o;
            } else {
                return null;
            }
        }

        Integer[] integerArray(String prefix) {
            Integer[] integers = new Integer[] {};
            for (Object o : array(prefix)) {
                integers.add(o != null ? Integer.valueOf(o) : null);
            }
            return integers;
        }

        Object[] array(String prefix) {
            Object[] objects = new Object[] {};
            for (Integer i = 0; true; i++) {
                Object o = m.get(prefix + '_' + i);
                if (o != null) {
                    objects.add(o);
                } else {
                    break;
                }
            }
            return objects;
        }

        Integer integer(String name) {
            Object o = m.get(name);
            if (o instanceof Decimal) {
                return ((Decimal) o).intValue();
            } else if (o instanceof Integer) {
                return (Integer) o;
            } else {
                return null;
            }
        }

        // Guard against SOQL injection
        String esc(String s) {
            return s != null ? String.escapeSingleQuotes(s) : null;
        }
    }

    private static String[] orderBys(Params p) {
        Map<String, String> soqlDirections = new Map<String, String> {
            'asc' => 'asc nulls last',
            'desc' => 'desc nulls first'
        };
        String[] orderBys = new String[] {};
        Integer min = Math.min(p.sortColumns.size(), p.sortDirections.size());
        for (Integer i = 0; i < min; i++) {
            orderBys.add(''
                         + p.columns[p.sortColumns[i]]
                         + ' '
                         + soqlDirections.get(p.sortDirections[i])
                        );
        }
        return orderBys;
    }

    /**
     *  ONBOARDING PROCCESS LOGIC
     */

    private void onboardingVariablesInit() {
        hasProducts = ([SELECT Product_vod__c FROM My_Setup_Products_vod__c WHERE OwnerId = : UserInfo.getUserId()]).size() > 0 ? true : false;
    }

    public List<SelectOption> getTopics() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Access Issue','Access Issue'));
        return options;
    }

    public List<SelectOption> getTerritories() {
        List<SelectOption> options = new List<SelectOption>();
        for(Territory2 terr : [SELECT Id, Name, External_id_gne__c FROM Territory2 WHERE External_id_gne__c Like 'GNE-US;SFA%' AND (NOT External_id_gne__c Like 'INACTIVE TERRITORIES%') ORDER BY External_id_gne__c LIMIT 200]) {
            options.add(new SelectOption(terr.Id,terr.Name));
        }
        return options;
    }

    public List<SelectOption> getProducts() {
        List<SelectOption> options = new List<SelectOption>();

        String profileName = GNE_SFA2_Util.getCurrentUserProfileName();
        Integer userRegionCode = 0;

        if(!profileName.contains('Canada')) {
            userRegionCode = 1;
        } else {
            userRegionCode = 2;
        }

        Map<String, GNE_SFA2_TheraDisease_Users__c> profilesMap = GNE_SFA2_TheraDisease_Users__c.getAll();
        List<Product_vod__c> products = new List<Product_vod__c>();

        if(profilesMap.containsKey(profileName)){
            products = [SELECT Id, Name
                        FROM Product_vod__c
                        WHERE Product_Type_vod__c = 'Detail'
                        AND (Detail_Product_Subtype_Code_gne__c = 'TheraDisease' OR Detail_Product_Subtype_Code_gne__c = 'Molecule')
                        AND Region_Code_gne__c =: userRegionCode
                        ORDER BY Name
                       ];
        } else {
            products = [SELECT Id, Name
                        FROM Product_vod__c
                        WHERE Product_Type_vod__c = 'Detail'
                        AND (Detail_Product_Subtype_Code_gne__c != 'Molecule' AND Detail_Product_Subtype_Code_gne__c != 'TheraDisease')
                        AND Region_Code_gne__c =: userRegionCode
                        ORDER BY Name
                       ];
        }

        for(Product_vod__c product : products) {
            options.add(new SelectOption(product.Id,product.Name.normalizeSpace()));
        }
        return options;
    }

    public class RequestWrapper {
        public String userId {get; set;}
        public String firstName {get; set;}
        public String lastName {get; set;}
        public String email {get; set;}
        public String phone {get; set;}
        public String unixId {get; set;}
        public String topic {get; set;}
        public String territory {get; set;}
        public String products {get; set;}

        public RequestWrapper(User user) {
            this.userId = user.Id;
            this.firstName = user.FirstName;
            this.lastName = user.LastName;
            this.email = user.Email;
            this.phone = user.Phone;
            this.unixId = user.External_ID_gne__c;
            this.topic = 'Access Issue';
        }
    }

    public Boolean getFoimRequestExist() {
        List<GNE_CRM_HPSM_Incident__c> inc = [Select Id FROM GNE_CRM_HPSM_Incident__c WHERE CreatedById =: UserInfo.getUserId() AND Summary_gne__c = 'Access Issue' AND Closed_Date_gne__c = null];
        if(inc.isEmpty()) {
            return false;
        } else {
            return true;
        }
    }

    public PageReference submitTicket() {
        GNE_CRM_HPSM_Incident__c incident = new GNE_CRM_HPSM_Incident__c();
        incident.Details_gne__c = prepareAccessIssueDescription();
        incident.Origin_gne__c = 'CRM';
        incident.Phone_Number_gne__c = request.phone;
        incident.Status_gne__c = 'Assigned';
        incident.Summary_gne__c = request.topic;
        incident.Web_Browser_gne__c = webBrowser;
        incident.Unix_Id_gne__c = request.unixId;
        insert incident;
        Database.executeBatch(new GNE_CRM_HPSM_Create_Incident_Batch(), 200);

        User currentUser = [SELECT Id, Phone FROM User where Id =: UserInfo.getUserId() LIMIT 1];
        if(String.isBlank(currentUser.Phone)) {
            currentUser.Phone = request.phone;
            try {
                update currentUser;
            } catch (Exception ex) {
                System.debug(ex);
            }
        }

        PageReference pr = new PageReference('/apex/GNE_SFA2_HCPs');
        pr.setRedirect(true);
        return pr;
    }

    private String prepareAccessIssueDescription() {
        String result = '';
        result += 'Territory: ' + request.territory;
        if(String.isNotBlank(request.products)) {
            result += '\n\nProduct(s): ';
            List<String> productsIds = request.products.split(', ');
            for(Product_vod__c p : [SELECT Id, Name FROM Product_vod__c where Id IN : productsIds]) {
                result += '\n' + p.Name + ' (' + p.Id + ')';
            }        }

        result += '\n\nExtended Information:';
        result += '\nContact Phone Number: ' + request.phone;
        result += '\nUser Profile: ' + GNE_SFA2_Util.getCurrentUserProfileName();
        result += '\nWeb Browser: ' + webBrowser;

        return result;
    }
}