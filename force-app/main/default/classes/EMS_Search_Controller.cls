/**
 * Created by nakoniej on 1/8/16.
 */

public with sharing class EMS_Search_Controller {
    private List<SFA2_Search_Settings_gne__c> searchSettings;
    private String searchQuery;

    public List<Tab> tabs {
        get {
            if (tabs == null) {
                tabs = new List<Tab>();
            }
            return tabs;
        }
        set;
    }

    public String initialSearchValue { get; private set; }
    public String exceptionMsg { get; private set; }

    // used for List_View component
    public String selectedObjectApiName { get; private set; }
    public String listViewPageName { get; private set; }
    public String selectedObjectIds { get; private set; }
    public EMS_Search_View_Controller listViewController { get; private set; }
    public Map<String, String> objectNamesMap {
        get {
            if (objectNamesMap == null) {
                objectNamesMap = new Map<String, String>();
            }
            return objectNamesMap;
        }
        private set;
    }

    public EMS_Search_Controller() {

    }

    public void initialize() {
        try {
            initialSearchValue = System.currentPageReference().getParameters().get('searchString');

            searchSettings = getSearchSettings();
            if (searchSettings.isEmpty()) {
                throw new CustomException('You need to set up your search preferences in "SFA2_Search_Settings_gne__c" object.');
            }

            buildSearchQuery();
            buildResultMap();

            System.debug(LoggingLevel.ERROR, '### tabs : ' + tabs);

            if (!tabs.isEmpty()) {
                setSearchResult(tabs[0]);
            }
        } catch (Exception ex) {
            exceptionMsg = ex.getMessage();
        }
    }

    private void buildSearchQuery() {
        String searchValue = initialSearchValue;
        searchValue = searchValue.replace('\\', '\\\\');
        searchValue = searchValue.replace('\'', '\\\'');
        searchValue = searchValue.replace('\\\\?', '?');
        searchValue = searchValue.replace('\\\\-', '-');

        searchQuery = 'FIND \'' + searchValue + '*\' IN ALL FIELDS RETURNING ';
        List<String> returningObjects = new List<String>();

        if (searchSettings.isEmpty()) {
            throw new CustomException('Search preferences in "SFA2_Search_Settings_gne__c" object are not set properly.');
        }

        for (SFA2_Search_Settings_gne__c settings : searchSettings) {
            String fieldsString = settings.Fields_gne__c.replace(';', ',');
            String filterString = String.isBlank(settings.Filter_gne__c) ? '' : ' WHERE ' + settings.Filter_gne__c;
            returningObjects.add(settings.Object_gne__c + ' ( ' + fieldsString + filterString + ' ORDER BY CreatedDate ASC )');
        }

        searchQuery += String.join(returningObjects, ', ');
    }

    private void buildResultMap() {
        List<List<SObject>> resultObjects = Search.query(searchQuery);

        for (List<SObject> objects :resultObjects) {
            if (objects.isEmpty()) {
                continue;
            }

            Schema.DescribeSObjectResult objectDescribe = objects.getSObjectType().getDescribe();
            tabs.add(new Tab(
                    '',
                    objectDescribe.getName(),
                    objectDescribe.getLabelPlural().removeStart('EMS ') + ' (' + objects.size() + ')',
                    (new Map<Id, SObject>(objects)).keySet()
            ));

            objectNamesMap.put(objectDescribe.getName(), objectDescribe.getLabelPlural().removeStart('EMS ')); // DELETE THIS
        }
    }

    public void changeSearchresult() {
        String sObjectAPIName = System.currentPageReference().getParameters().get('sTab');

        for (Tab t :tabs) {
            if (t.objectApiName.toLowerCase() == sObjectAPIName.toLowerCase()) {
                setSearchResult(t);
            } else {
                t.removeActive();
            }
        }

    }

    public Boolean getNoRecordsFound() {
        return (tabs.isEmpty() == true);
    }

    private void setSearchResult(Tab openedTab) {
        selectedObjectApiName = openedTab.objectApiName;
        listViewController = new EMS_Search_View_Controller(openedTab.objectApiName);
        listViewPageName = 'Search ' + openedTab.objectApiName;
        selectedObjectIds = String.join((new List<Id>(openedTab.foundEntriesIDs)), ',');
        openedTab.addActive();
    }

    private List<SFA2_Search_Settings_gne__c> getSearchSettings() {
        GNE_SFA2_User_App_Context_gne__c userApplicationContext = GNE_SFA2_Application_Cache.userApplicationContext;
        return [
                SELECT Id, Object_gne__c, Fields_gne__c, Header_Label_gne__c, Filter_gne__c
                FROM SFA2_Search_Settings_gne__c
                WHERE Product_gne__c = :userApplicationContext.Brand_gne__c
                AND Role_gne__c = :userApplicationContext.Role_gne__c
                AND Application_Name_gne__c = :userApplicationContext.App_Name_gne__c
                ORDER BY Order_gne__c
        ];
    }


    public class Tab {
        public String styles { get; set; }
        public String linkLabel { get; set; }
        public String objectApiName { get; set; }
        public Set<Id> foundEntriesIDs { get; set; }

        public Tab(String styles, String objectApiName, String linkLabel, Set<Id> foundEntriesIDs) {
            this.styles = styles;
            this.linkLabel = linkLabel;
            this.objectApiName = objectApiName;
            this.foundEntriesIDs = foundEntriesIDs;
        }

        public void addActive() {
            this.styles = 'active';
        }

        public void removeActive() {
            this.styles = '';
        }
    }

    public class CustomException extends Exception {
    }

    public class EMS_Search_View_Controller extends List_View_Base_Controller {
        public EMS_Search_View_Controller(String objectType) {
            super(objectType);
        }
    }
}