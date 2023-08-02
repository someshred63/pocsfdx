/* 
 * GNE_MCCO_CRM_Interactions_Controller
 *
 * Created By :         Tadeusz Hyzy (tadeusz.hyzy@contractors.roche.com)
 * Last Modified By :   Tadeusz Hyzy (tadeusz.hyzy@contractors.roche.com)
 * Last Modified Date : 01/13/2015
 */
public with sharing class GNE_MCCO_CRM_Interactions_Controller {
	
	private static final Integer RECORDS_LIMIT = 50000;
	
	public Boolean hasViews { get; private set; }
	
	public Boolean isAccount { get; private set; }
	public Boolean accountValid { get; private set; }
	private Id accountId { get; set; }
	public Account account { get; private set; }

    public SFA2_User_Preferences_gne__c preferences { get; private set; }
    private List<SFA2_View_Config_gne__c> viewsList { get; set; }
    
    public String iconBase64 { get; private set; }
    
    public String userTimeZone { get; private set; }
    
    // JSONs
    public String settingsJson { get; private set; }
    public String preferencesJson { get; private set; }
    public String viewsJson { get; private set; }
    public String buttonsListJson { get; private set; }

    public Boolean isMCCOCrmUser {
        get { return GNE_SFA2_Util.isMCCOCrmUser(); }
    }
    
    public Boolean isFrmUser {
        get { return GNE_SFA2_Util.isFrmUser(); }
    }
    
	public GNE_MCCO_CRM_Interactions_Controller() {
		
		isAccount = false;
		accountId = (ApexPages.currentPage().getParameters().get('accountId') != null && ApexPages.currentPage().getParameters().get('accountId') != '') ? ApexPages.currentPage().getParameters().get('accountId') : null;
		
		iconBase64	= '/img/icon/hands32.png';
    	        
        userTimeZone = String.valueOf(UserInfo.getTimeZone());
        
    	if(accountId == null) {
    		
	    	settingsJson 		= JSON.serializePretty(GNE_MCCO_CRM_Util.getUserSettings());
	    	preferences			= GNE_MCCO_CRM_Util.getUserPreferences('My Interactions');
	        preferencesJson 	= JSON.serializePretty(preferences);
	    	viewsList			= GNE_MCCO_CRM_Util.getViews('My Interactions');
	    	viewsJson 			= JSON.serializePretty(viewsList);    	
	    	buttonsListJson 	= JSON.serializePretty(GNE_MCCO_CRM_Util.getButtonsList('Call2_vod__c'));
	
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

    @RemoteAction 
    @ReadOnly
    public static InteractionsWrapper loadInteractions(String selectedViewJson, Integer page, Integer pageSize, String sortColumn, String sortDirection, String letter, String searchValue) {
        SettingsWrapper settings = new SettingsWrapper(selectedViewJson, page, pageSize, sortColumn, sortDirection, letter, searchValue);
    	List<String> filterStatements = GNE_MCCO_CRM_Util.getFiltersBySelectedView(settings.selectedView);
        List<Call2_vod__c> items = Database.query(createQuery(settings, filterStatements));

        Boolean hasNextPage = (items.size() > pageSize) ? true : false;
        return new InteractionsWrapper(hasNextPage, items, settings.columnsHeaders, settings.columnsHeadersType);
    }
    		    
    @RemoteAction
    @ReadOnly
    public static InteractionsWrapper loadInteractionsByAccount(String accountId, Integer page, Integer pageSize, String sortColumn, String sortDirection, String selectedLetter) {
		if(accountId != '') {
			Integer offset = (pageSize * page) - pageSize;
			
			String query = 'SELECT Id, Name, Subject_vod__c, Interaction_Status_gne__c, Owner.Name, CreatedDate, Date_of_Interaction_gne__c, CreatedBy.Name FROM Call2_vod__c WHERE Parent_Call_vod__c = null AND Account_vod__c = \'' + accountId + '\'';
	        
	        if(String.isNotBlank(selectedLetter) && selectedLetter != 'All'){
	            query += ' AND Name like \''+selectedLetter+'%\'';
	        }
	        
			query += ' ORDER BY ' + sortColumn + ' ' + sortDirection + setNullsBySortDirection(sortDirection);
			query += ' LIMIT ' + (pageSize + 1) + ' OFFSET ' + offset;
			
			List<Call2_vod__c> items = Database.query(query);
			    	
    		Boolean hasNextPage = (items.size() > pageSize) ? true : false;
    	
			return new InteractionsWrapper(hasNextPage, items, null, null);
		} else {
			return new InteractionsWrapper(false, null, null, null);
		}
    }
/*    
    @RemoteAction 
    @ReadOnly
    public static List<RecentlyViewedItem> loadRecentlyViewedInteractions() {
    	List<RecentlyViewedItem> recentlyViewedInteractions = new List<RecentlyViewedItem>();
		Map<Id, DateTime> interactionsIdsMap = GNE_MCCO_CRM_Util.getRecentylViewedMap('Call2_vod__c');
    	for(Call2_vod__c c : [SELECT Id, Name, Subject_vod__c, Interaction_Status_gne__c, Owner.Name, CreatedDate, Date_of_Interaction_gne__c, CreatedBy.Name FROM Call2_vod__c WHERE Id IN :interactionsIdsMap.keySet() AND Parent_Call_vod__c = null]) {
    		recentlyViewedInteractions.add(new RecentlyViewedItem(c.Id, c.Name, c.Subject_vod__c, c.Interaction_Status_gne__c, c.Owner.Name, c.Owner.Id, c.CreatedDate, c.Date_of_Interaction_gne__c, c.CreatedBy.Name, c.CreatedBy.Id, interactionsIdsMap.get(c.Id)));
    	}
    	recentlyViewedInteractions.sort();
		return recentlyViewedInteractions;
    }
    		
    @RemoteAction
    @ReadOnly
    public static List<Call2_vod__c> loadRecentlyCreatedInteractions() {
		return [SELECT Id, Name, Subject_vod__c, Interaction_Status_gne__c, Owner.Name, CreatedDate, Date_of_Interaction_gne__c, CreatedBy.Name FROM Call2_vod__c WHERE Parent_Call_vod__c = null AND CreatedById = :UserInfo.getUserId() ORDER BY CreatedDate DESC LIMIT 25];
    }
        		
    @RemoteAction
    @ReadOnly
    public static List<Call2_vod__c> loadRecentlyModifiedInteractions() {
		return [SELECT Id, Name, Subject_vod__c, Interaction_Status_gne__c, Owner.Name, LastModifiedDate, Date_of_Interaction_gne__c, CreatedBy.Name FROM Call2_vod__c WHERE Parent_Call_vod__c = null AND LastModifiedById = :UserInfo.getUserId() ORDER BY LastModifiedDate DESC LIMIT 25];
    }
    
    public class RecentlyViewedItem implements Comparable {
    	
    	public Id Id { get; private set; }
    	public Id OwnerId { get; private set; }
    	public Id createdById { get; private set; }
    	
    	public String Name { get; private set; }
    	public String Subject { get; private set; }
    	public String Status { get; private set; }
    	public String OwnerName { get; private set; }
    	public String CreatedByName { get; private set; }
    	
    	public DateTime CreatedDate { get; private set; }
    	public Date DateOfInteracion { get; private set; }

    	private DateTime LastViewedDate { get; set; }

    	public RecentlyViewedItem(Id id, String name, String subject, String status, String ownerName, Id ownerId, DateTime createdDate, Date dateOfInteracion, String createdByName, Id createdById, DateTime lastViewedDate) {
    		this.Id 				= id;
    		this.Name 				= name;
    		this.Subject 			= subject;
    		this.Status 			= status;
    		this.OwnerName 			= ownerName;
    		this.OwnerId 			= ownerId;
    		this.CreatedDate 		= createdDate;
    		this.DateOfInteracion 	= dateOfInteracion;
    		this.CreatedByName 		= createdByName;
    		this.CreatedById 		= createdById;
    		this.LastViewedDate 	= lastViewedDate;
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
            preference = [ SELECT Last_View_Used_gne__c FROM  SFA2_User_Preferences_gne__c WHERE Last_View_Used_gne__r.Page_Name_gne__c = 'My Interactions' AND User_gne__c = :Userinfo.getUserId() LIMIT 1 ];
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
    			query += 'Account_vod__r.Recordtype.DeveloperName, ';
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
    	
    	query += ' FROM Call2_vod__c ';
    	
		query += ' WHERE Parent_Call_vod__c = null AND ';

    	if(filterStatements.size() > 0) {
            if (settings.recordsVisibility=='My Records'){
                query += ' OwnerId = \''+UserInfo.getUserId()+'\' AND ';
            }

            for(String filterColumn : filterStatements){
                query += GNE_MCCO_CRM_Util.getFilterStatement(filterColumn);
            }
        }
        
        query = query.removeEnd(' AND ');

        if(String.isNotBlank(settings.letter) && settings.letter != 'All'){
            query += ' AND (Name LIKE \''+settings.letter+'%\' OR Subject_vod__c LIKE \''+settings.letter+'%\' OR Interaction_Status_gne__c LIKE \''+settings.letter+'%\' OR Owner.Name LIKE \''+settings.letter+'%\')';
        }
                
        if(String.isNotBlank(settings.searchValue)){
        	query += ' AND (Name LIKE \'%'+settings.searchValue+'%\' OR Subject_vod__c LIKE \'%'+settings.searchValue+'%\' OR Interaction_Status_gne__c LIKE \'%'+settings.searchValue+'%\' OR Owner.Name LIKE \'%'+settings.searchValue+'%\')';
        }

		// ORDER BY is slowing SOQL by 1000% to enormous time
		if(!String.isBlank(settings.sortColumn)) {
			query += ' ORDER BY ' + setOrderBy(settings) + ' ' + settings.sortDirection + setNullsBySortDirection(settings.sortDirection);
		}
        
    	query += ' LIMIT ' + (settings.pageSize + 1) + ' OFFSET ' + offset;
		        
		System.debug('## QUERY ##');
		System.debug(query);

    	return query;
    }
    
    private static String setOrderBy(SettingsWrapper settings) {
    	String result = settings.sortColumn;
    	if (settings.columnsHeadersType.get(settings.sortColumn) == 'REFERENCE') {
    		result = settings.sortColumn.replace('__c', '__r') + '.Name';
    	}
    	return result;
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
    	public String letter { get; private set; }
    	public String searchValue { get; private set; }
        public String recordsVisibility { get; private set; }
    	
   		public Map<String, String> columnsHeaders { get; private set; }
        public Map<String, String> columnsHeadersType { get; private set; }
    	
    	public SettingsWrapper(String selectedViewJson, Integer page, Integer pageSize, String sortColumn, String sortDirection, String letter, String searchValue) {
    		this.selectedView 		= this.encodeSelectedView(selectedViewJson);
    		this.page 				= page;
    		this.pageSize			= pageSize;
    		this.sortColumn 		= sortColumn;
    		this.sortDirection 		= sortDirection;
            this.columnsHeaders		= this.getViewColumnsHeaders(this.selectedView);
            this.columnsHeadersType = this.getViewColumnsHeadersType(this.selectedView);
            this.letter	 			= letter;
    		this.searchValue 		= searchValue;
            this.recordsVisibility  = this.selectedView.Records_Visibility__c;
    	}

        private SFA2_View_Config_gne__c encodeSelectedView(String jsonString) {
            JSONParser parser = JSON.createParser(jsonString);
            SFA2_View_Config_gne__c result = (SFA2_View_Config_gne__c)parser.readValueAs(SFA2_View_Config_gne__c.class);
            return result;
        }   
        
        private Map<String, String> getViewColumnsHeaders(SFA2_View_Config_gne__c view){
        	Map<String, String> columnHeaders = new Map<String, String>();
        	for(String column : view.View_Fields_gne__c.split(';', 0)) {
        		
        		if(column.contains('.')) {
        			
        			List<String> splitColumn = column.split('\\.');

		            Schema.DescribeFieldResult fieldDescribe = Schema.getGlobalDescribe().get('Call2_vod__c').getDescribe().fields.getMap().get(splitColumn[0]).getDescribe();
		            columnHeaders.put(column, fieldDescribe.getLabel());
		            Schema.DisplayType fieldType = fieldDescribe.getType();
	            
        		} else {
	
		            Schema.DescribeFieldResult fieldDescribe = Schema.getGlobalDescribe().get('Call2_vod__c').getDescribe().fields.getMap().get(column).getDescribe();
		            columnHeaders.put(column, fieldDescribe.getLabel());
		            Schema.DisplayType fieldType = fieldDescribe.getType();
	            
        		}
	            
        	}

            return columnHeaders;
        }
        
        private Map<String, String> getViewColumnsHeadersType(SFA2_View_Config_gne__c view){
			Map<String, String> columnHeaders = new Map<String, String>();
        	for(String column : view.View_Fields_gne__c.split(';', 0)) {
        		
        		if(column.contains('.')) {
        			
        			List<String> splitColumn = column.split('\\.');

		            Schema.DisplayType type = Schema.getGlobalDescribe().get('Call2_vod__c').getDescribe().fields.getMap().get(splitColumn[0]).getDescribe().getType();
		            columnHeaders.put(column, type.Name());
	            
        		} else {
	
		            Schema.DisplayType type = Schema.getGlobalDescribe().get('Call2_vod__c').getDescribe().fields.getMap().get(column).getDescribe().getType();
		            columnHeaders.put(column, type.Name());
	            
        		}
	            
        	}

            return columnHeaders;
        }

    }
    
    @TestVisible
    private class InteractionsWrapper {
    	
    	public Boolean hasNextPage { get; private set; }
    	public List<Call2_vod__c> items { get; private set; }
    	    	
   		public Map<String, String> columnsHeaders { get; private set; }
        public Map<String, String> columnsHeadersType { get; private set; }
    	
    	public InteractionsWrapper(Boolean hasNextPage, List<Call2_vod__c> items, Map<String, String> columnsHeaders, Map<String, String> columnsHeadersType) {
    		this.hasNextPage 		= hasNextPage;
    		this.items 				= items;
    		this.columnsHeaders 	= columnsHeaders;
    		this.columnsHeadersType = columnsHeadersType;
    	}
    	
    }
    
}