/*
 * GNE_MCCO_CRM_Interactions_Controller
 *
 * Created By :         Tadeusz Hyzy (tadeusz.hyzy@contractors.roche.com)
 * Last Modified By :   Tadeusz Hyzy (tadeusz.hyzy@contractors.roche.com)
 * Last Modified Date : 01/13/2015
 */
public with sharing class GNE_MCCO_CRM_Contacts_Controller {

	private static final Integer RECORDS_LIMIT = 40000;

	public Boolean hasViews { get; private set; }

	public Boolean isAccount { get; private set; }
	public Boolean accountValid { get; private set; }
	private Id accountId { get; set; }
	public Account account { get; private set; }

    public SFA2_User_Preferences_gne__c preferences { get; private set; }
    private List<SFA2_View_Config_gne__c> viewsList { get; set; }
    private Set<Id> accountSetIds { get; set; }

    public String iconBase64 { get; private set; }

    // JSONs
    public String settingsJson { get; private set; }
    public String preferencesJson { get; private set; }
    public String viewsJson { get; private set; }
    public String buttonsListJson { get; private set; }
    public String accountIds { get; private set; }

    public String userTimeZone { get; private set; }

	public GNE_MCCO_CRM_Contacts_Controller() {

		isAccount = false;
		accountId = (ApexPages.currentPage().getParameters().get('accountId') != null && ApexPages.currentPage().getParameters().get('accountId') != '') ? ApexPages.currentPage().getParameters().get('accountId') : null;

    	iconBase64	= GNE_MCCO_CRM_Util.getDocumentBase64('Contact_Tab_Icon');

    	userTimeZone = String.valueOf(UserInfo.getTimeZone());

    	if(accountId == null) {

	    	settingsJson 		= JSON.serializePretty(GNE_MCCO_CRM_Util.getUserSettings());
	    	preferences			= GNE_MCCO_CRM_Util.getUserPreferences('Contacts');
	        preferencesJson 	= JSON.serializePretty(preferences);
	    	viewsList			= GNE_MCCO_CRM_Util.getViews('Contacts');
	    	viewsJson 			= JSON.serializePretty(viewsList);
	    	buttonsListJson 	= JSON.serializePretty(GNE_MCCO_CRM_Util.getButtonsList('Contact'));
	    	accountSetIds		= getAccountsIdsByTerritories();
	    	accountIds			= getAccountsIdsString();

	    	System.debug(accountIds);

	        if(!viewsList.isEmpty()) {
	        	hasViews = true;
	        } else {
	        	hasViews = false;
	        }

    	} else {

    		isAccount = true;

    		try {
    			account = [SELECT Id, Name FROM Account WHERE Id = :accountId LIMIT 1][0];
    			accountValid = true;
    		} catch(Exception ex) {
    			accountValid = false;
    		}

    	}

	}

    private String getAccountsIdsString() {
    	String result = '(';

        for (Id accountId : accountSetIds){
            result += '\'' + accountId + '\',';
        }

        result = result.removeEnd(',');

        result += ')';

    	return result;
    }

    private Set<Id> getAccountsIdsByTerritories() {
    	Set<Id> result = new Set<Id>();
    	Set<String> territoriesNameSet = new Set<String>();
    	Set<Territory2> lsTerritory = getUserTerritories();

    	for(Territory2 tr : lsTerritory) {
    		territoriesNameSet.add(tr.Name);
    	}

    	for(TSF_vod__c tsf : [SELECT Id, Account_vod__c FROM TSF_vod__c WHERE Territory_vod__c IN :territoriesNameSet AND Account_vod__r.IsPersonAccount = false AND External_Id_vod__c != null AND Address_vod__c != null LIMIT :RECORDS_LIMIT]) {
    		result.add(tsf.Account_vod__c);
    	}

    	System.debug('# AccountsIdsByTerritories #');
    	System.debug(result);

    	return result;
    }

	private Set<Territory2> getUserTerritories(){
		Set<Territory2> result = new Set<Territory2>();
		List<Territory2> userTopTerritories = [ SELECT Name FROM Territory2 WHERE Id IN (SELECT Territory2Id FROM UserTerritory2Association WHERE UserId = :Userinfo.getUserId()) ORDER BY Name DESC ];
		if(userTopTerritories.size() > 0) {
			result.addAll(userTopTerritories);
			result.addAll(getChildrenTerritories(userTopTerritories));
		}

    	System.debug('# UserTerritories #');
    	System.debug(result);

		return result;
	}

	private Set<Territory2> getChildrenTerritories(List<Territory2> parentTerritories) {
		Set<Territory2> result = new Set<Territory2>();
		List<Territory2> childrenTerritories = [ SELECT Id, Name, External_id_gne__c, ParentTerritory2Id FROM Territory2 WHERE ParentTerritory2Id in :parentTerritories ORDER BY ParentTerritory2Id ];
		if(childrenTerritories.size() > 0) {
			result.addAll(childrenTerritories);
			result.addAll(getChildrenTerritories(childrenTerritories));
		}
		return result;
	}

    @RemoteAction
    @ReadOnly
    public static ContactsWrapper loadContacts(String selectedViewJson, Integer page, Integer pageSize, String sortColumn, String sortDirection, String accountIds, String letter, String searchValue) {
        SettingsWrapper settings = new SettingsWrapper(selectedViewJson, page, pageSize, sortColumn, sortDirection, accountIds, letter, searchValue);

    	List<String> filterStatements = GNE_MCCO_CRM_Util.getFiltersBySelectedView(settings.selectedView);

		if(settings.accountIds != '()') {
	    	List<Contact> items = Database.query(createQuery(settings, filterStatements));

    		Boolean hasNextPage = (items.size() > settings.pageSize) ? true : false;

	    	return new ContactsWrapper(hasNextPage, items, settings.columnsHeaders, settings.columnsHeadersType);
		} else {
			return new ContactsWrapper(false, null, settings.columnsHeaders, settings.columnsHeadersType);
		}
    }

    @RemoteAction
    @ReadOnly
    public static ContactsWrapper loadContactsByAccount(String accountId, Integer page, Integer pageSize, String sortColumn, String sortDirection, String selectedLetter) {
		if(accountId != '') {
			Integer offset = (pageSize * page) - pageSize;

			String query = 'SELECT Id, Name, LastName, FirstName, Developer_Title_gne__c, Phone, Email, CreatedDate, CreatedById, CreatedBy.Name, LastModifiedDate, LastModifiedById, LastModifiedBy.Name FROM Contact WHERE AccountId = \'' + accountId + '\' AND Active_gne__c = true ';

	        if(String.isNotBlank(selectedLetter) && selectedLetter != 'All'){
	            query += ' AND (LastName LIKE \''+selectedLetter+'%\')';
	        }
	        
			Profile p = [ SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId() ];
	        if (p.Name == 'GNE-MCCO-340B') {
	            query += ' AND X340B_Contact__c = true ';
	        }

			query += ' ORDER BY ' + sortColumn + ' ' + sortDirection + setNullsBySortDirection(sortDirection);
			query += ' LIMIT ' + (pageSize + 1) + ' OFFSET ' + offset;

			List<Contact> items = Database.query(query);

    		Boolean hasNextPage = (items.size() > pageSize) ? true : false;

			return new ContactsWrapper(hasNextPage, items, null, null);
		} else {
			return new ContactsWrapper(false, null, null, null);
		}
    }
/*
    @RemoteAction
    @ReadOnly
    public static List<RecentlyViewedItem> loadRecentlyViewedContacts() {
    	List<RecentlyViewedItem> recentlyViewedContacts = new List<RecentlyViewedItem>();
		Map<Id, DateTime> contactIdsMap = GNE_MCCO_CRM_Util.getRecentylViewedMap('Contact');
    	for(Contact c : [SELECT Id, LastName, FirstName, Developer_Title_gne__c, Developer_Function_gne__c, Phone, Email, DO_NOT_CONTACT_gne__c, CreatedDate FROM Contact WHERE Id IN :contactIdsMap.keySet() AND Active_gne__c = true ]) {
    		recentlyViewedContacts.add(new RecentlyViewedItem(c.Id, c.LastName, c.FirstName, c.Developer_Title_gne__c, c.Developer_Function_gne__c, c.Phone, c.Email, c.DO_NOT_CONTACT_gne__c, c.CreatedDate, contactIdsMap.get(c.Id)));
    	}
    	recentlyViewedContacts.sort();
		return recentlyViewedContacts;
    }

    @RemoteAction
    @ReadOnly
    public static List<Contact> loadRecentlyCreatedContacts() {
		return [SELECT Id, LastName, FirstName, Developer_Title_gne__c, Developer_Function_gne__c, Phone, Email, DO_NOT_CONTACT_gne__c, CreatedDate FROM Contact WHERE CreatedById = :UserInfo.getUserId() AND Active_gne__c = true ORDER BY CreatedDate DESC LIMIT 25];
    }

    @RemoteAction
    @ReadOnly
    public static List<Contact> loadRecentlyModifiedContacts() {
		return [SELECT Id, LastName, FirstName, Developer_Title_gne__c, Developer_Function_gne__c, Phone, Email, DO_NOT_CONTACT_gne__c, LastModifiedDate FROM Contact WHERE LastModifiedById = :UserInfo.getUserId() AND Active_gne__c = true ORDER BY LastModifiedDate DESC LIMIT 25];
    }

    public class RecentlyViewedItem implements Comparable {

    	public Id Id { get; private set; }
    	public String LastName { get; private set; }
    	public String FirstName { get; private set; }
    	public String Title { get; private set; }
    	public String Function { get; private set; }
    	public String Phone { get; private set; }
    	public String Email { get; private set; }
    	public Boolean Dnc { get; private set; }
    	public DateTime CreatedDate { get; private set; }

    	private DateTime LastViewedDate { get; set; }

    	public RecentlyViewedItem(Id id, String lastName, String firstName, String title, String function, String phone, String email, Boolean dnc, DateTime createdDate, DateTime lastViewedDate) {
    		this.Id 			= id;
    		this.LastName 		= lastName;
    		this.FirstName 		= firstName;
    		this.Title 			= title;
    		this.Function 		= function;
    		this.Phone 			= phone;
    		this.Email 			= email;
    		this.Dnc 			= dnc;
    		this.CreatedDate 	= createdDate;
    		this.LastViewedDate = lastViewedDate;
    	}

        public Integer compareTo(Object compareTo) {
            RecentlyViewedItem comparableData = (RecentlyViewedItem)compareTo;
            Integer result = 0;
            if (this.LastViewedDate == comparableData.LastViewedDate) {
                result = 0;
            } else if (this.LastViewedDate < comparableData.LastViewedDate) {
                result = 1;
            } else {
                result = -1;
            }
            return result;
        }

    }
*/
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
            preference = [ SELECT Last_View_Used_gne__c FROM  SFA2_User_Preferences_gne__c WHERE Last_View_Used_gne__r.Page_Name_gne__c = 'Contacts' AND User_gne__c = :Userinfo.getUserId() LIMIT 1 ];
            preference.Last_View_Used_gne__c = viewId;
        } catch(Exception e) {}

        try {
            upsert preference;
            return true;
        } catch(DMLException e) {
            return false;
        }
    }

    private static String createQuery(SettingsWrapper settings, List<String> filterStatements) {
    	Integer offset = (settings.pageSize * settings.page) - settings.pageSize;

    	String query = 'SELECT ';
    	for(String val : settings.selectedView.View_Fields_gne__c.split(';')) {
    		if(val == 'Account_vod__c') {
    			query += 'Account_vod__r.Name, ';
    		} else if(val =='Contact_vod__c') {
    			query += 'Contact_vod__r.Name, ';
    		} else if(val =='CreatedById') {
    			query += 'CreatedBy.Name, CreatedDate, ';
    		} else if(val =='OwnerId') {
    			query += 'Owner.Name, ';
    		}
			query += val + ', ';
    	}
    	query = query.removeEnd(', ');

    	query += ' FROM Contact WHERE AccountId IN ' + settings.accountIds + ' AND ';

    	if(filterStatements.size() > 0) {
            for(String filterColumn : filterStatements){
                query += GNE_MCCO_CRM_Util.getFilterStatement(filterColumn);
            }
        }

        query = query.removeEnd(' AND ');

        if(String.isNotBlank(settings.letter) && settings.letter != 'All'){
            //query += ' AND (FirstName LIKE \''+settings.letter+'%\' OR LastName LIKE \''+settings.letter+'%\' OR Account.FirstName LIKE \''+settings.letter+'%\' OR Account.LastName LIKE \''+settings.letter+'%\' OR Account.Name LIKE \''+settings.letter+'%\')';
            query += ' AND (LastName LIKE \''+settings.letter+'%\')';
        }

        if(String.isNotBlank(settings.searchValue)){
            query += ' AND (FirstName LIKE \'%'+settings.searchValue+'%\' OR LastName LIKE \'%'+settings.searchValue+'%\' OR Account.FirstName LIKE \'%'+settings.searchValue+'%\' OR Account.LastName LIKE \'%'+settings.searchValue+'%\' OR Account.Name LIKE \'%'+settings.searchValue+'%\' OR Developer_Title_gne__c LIKE \'%'+settings.searchValue+'%\')';
        }
        
    	query += ' ORDER BY ' + settings.sortColumn + ' ' + settings.sortDirection + setNullsBySortDirection(settings.sortDirection);
    	query += ' LIMIT ' + (settings.pageSize + 1) + ' OFFSET ' + offset;

		System.debug(' # QUERY #');
		System.debug(query);

    	return query;
    }

    private static String setNullsBySortDirection(String sortDirection){
        return sortDirection == 'DESC' ? ' NULLS LAST ' : ' NULLS FIRST ';
    }

    private class SettingsWrapper {

    	public SFA2_View_Config_gne__c selectedView { get; private set; }
    	public Integer page { get; private set; }
    	public Integer pageSize { get; private set; }
    	public String sortColumn { get; private set; }
    	public String sortDirection { get; private set; }
    	public String accountIds { get; private set; }
    	public String letter { get; private set; }
    	public String searchValue { get; private set; }

   		public Map<String, String> columnsHeaders { get; private set; }
        public Map<String, String> columnsHeadersType { get; private set; }

    	public SettingsWrapper(String selectedViewJson, Integer page, Integer pageSize, String sortColumn, String sortDirection, String accountIds, String letter, String searchValue) {
    		this.selectedView 		= this.encodeSelectedView(selectedViewJson);
    		this.page 				= page;
    		this.pageSize			= pageSize;
    		this.sortColumn 		= sortColumn;
    		this.sortDirection 		= sortDirection;
            this.columnsHeaders		= this.getViewColumnsHeaders(this.selectedView);
            this.columnsHeadersType = this.getViewColumnsHeadersType(this.selectedView);
            this.accountIds 		= accountIds;
            this.letter 			= letter;
            this.searchValue 		= searchValue;
    	}

        private SFA2_View_Config_gne__c encodeSelectedView(String jsonString) {
            JSONParser parser = JSON.createParser(jsonString);
            SFA2_View_Config_gne__c result = (SFA2_View_Config_gne__c)parser.readValueAs(SFA2_View_Config_gne__c.class);
            return result;
        }

        private Map<String, String> getViewColumnsHeaders(SFA2_View_Config_gne__c view){
        	Map<String, String> columnHeaders = new Map<String, String>();
        	for(String column : view.View_Fields_gne__c.split(';', 0)) {

        		String fieldName = column.substring(column.indexOf('.')+1);

				if(column.startsWith('Account')) {
	            	Schema.DescribeFieldResult fieldDescribe = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().get(fieldName).getDescribe();
	            	columnHeaders.put(column, 'Account');
				} else {
					Schema.DescribeFieldResult fieldDescribe = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap().get(column).getDescribe();
					columnHeaders.put(column, fieldDescribe.getLabel());
				}

        	}

            return columnHeaders;
        }

        private Map<String, String> getViewColumnsHeadersType(SFA2_View_Config_gne__c view){
			Map<String, String> columnHeaders = new Map<String, String>();
        	for(String column : view.View_Fields_gne__c.split(';', 0)) {

				String fieldName = column.substring(column.indexOf('.')+1);

				if(column.startsWith('Account')) {
	            	Schema.DisplayType type = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().get(fieldName).getDescribe().getType();
	            	columnHeaders.put(column, type.Name());
				} else {
					Schema.DisplayType type = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap().get(column).getDescribe().getType();
					columnHeaders.put(column, type.Name());
				}

        	}

            return columnHeaders;
        }

    }

	@TestVisible
    private class ContactsWrapper {

    	public Boolean hasNextPage { get; private set; }
    	public List<Contact> items { get; private set; }

   		public Map<String, String> columnsHeaders { get; private set; }
        public Map<String, String> columnsHeadersType { get; private set; }

    	public ContactsWrapper(Boolean hasNextPage, List<Contact> items, Map<String, String> columnsHeaders, Map<String, String> columnsHeadersType) {
    		this.hasNextPage 		= hasNextPage;
    		this.items 				= items;
    		this.columnsHeaders 	= columnsHeaders;
    		this.columnsHeadersType = columnsHeadersType;
    	}

    }

}