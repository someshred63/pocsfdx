/* 
 * GNE_MCCO_CRM_Questionnaires_Controller
 *
 * Created By :         Tadeusz Hyzy (tadeusz.hyzy@contractors.roche.com)
 * Last Modified By :   Tadeusz Hyzy (tadeusz.hyzy@contractors.roche.com)
 * Last Modified Date : 01/13/2015
 * 
 */
 public with sharing class GNE_MCCO_CRM_Questionnaires_Controller {
    
    /* Init variables */
    private static final Integer RECORDS_LIMIT = 49000;

    public String settingsJson { get; private set; }
    public String preferencesJson { get; private set; }

    public Boolean hasQuestioneries { get; set; }
    public Boolean hasViews { get; set; }

    public String buttonsListJson { get; private set; }
    public String viewsJson { get; private set; }
    
    public SFA2_View_Config_gne__c selectedView { get; private set; }

    private String selectedViewId { get; set; }
    private String selectedSortColumn { get; set; }
    private String selectedSortDirection { get; set; }
    
    public String selectedViewJson { get; private set; }
        
    public GNE_SFA2_My_Accounts_Setttings__c settings { get; private set; }
    public SFA2_User_Preferences_gne__c preferences { get; private set; }
    
    private List<SFA2_View_Config_gne__c> viewsList { get; set; }

    public GNE_MCCO_CRM_Questionnaires_Controller() {
		initVariables();
    }
    
    private void initVariables() {
    	
    	viewsList			= GNE_MCCO_CRM_Util.getViews('Questionnaires');
    	viewsJson 			= JSON.serializePretty(viewsList);
    	settingsJson 		= JSON.serializePretty(GNE_MCCO_CRM_Util.getUserSettings());
        preferencesJson 	= JSON.serializePretty(GNE_MCCO_CRM_Util.getUserPreferences('Questionnaires'));
        buttonsListJson 	= JSON.serializePretty(GNE_MCCO_CRM_Util.getButtonsList('Questionnaire_gne__c'));
        
        if(!viewsList.isEmpty()) {
        	hasViews = true;
        } else {
        	hasViews = false;
        }
        
        hasQuestioneries = true;

    }

    @RemoteAction
    @ReadOnly
    public static QuestionnaireWrapper loadQuestionnaires(String selectedViewJson, Integer page, Integer pageSize, String sortColumn, String sortDirection) {
        SettingsWrapper settings = new SettingsWrapper(selectedViewJson, page, pageSize, sortColumn, sortDirection);
        
    	List<String> filterStatements = GNE_MCCO_CRM_Util.getFiltersBySelectedView(settings.selectedView);

    	List<Questionnaire_gne__c> items = Database.query(createQuery(settings, filterStatements));
    	
        return new QuestionnaireWrapper(countQuestionnairies(settings, filterStatements), items, settings.columnsHeaders, settings.columnsHeadersType);
    }

    @RemoteAction
    public static Boolean deleteQuestionnaire(String questionnaireId) {
		try {
			Questionnaire_gne__c questionnaireToDelete = [SELECT Id FROM Questionnaire_gne__c WHERE Id = :questionnaireId LIMIT 1][0];
			delete questionnaireToDelete;
			return true;
		} catch (DMLException ex) {
			return false;
		}
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
                
    private static String createQuery(SettingsWrapper settings, List<String> filterStatements) {
    	Integer offset = (settings.pageSize * settings.page) - settings.pageSize;
    	String query = 'SELECT ';
    	for(String val : settings.selectedView.View_Fields_gne__c.split(';')) {
    		if(val == 'recordtypeid') {
    			query += 'RecordType.Name, ';
    		} else if(val =='lastmodifiedbyid') {
    			query += 'LastModifiedBy.Name, ';
    		} else if(val =='createdbyid') {
    			query += 'CreatedBy.Name, ';
    		}
			query += val + ', ';
    	}
    	query = query.removeEnd(', ');
    	
    	query += ' FROM Questionnaire_gne__c WHERE ';
    	query += ' CreatedById = \'' + UserInfo.getUserId() + '\'';
    	
    	if(filterStatements.size() > 0) {
    		query += ' AND ';
            for(String filterColumn : filterStatements){
                query += GNE_MCCO_CRM_Util.getFilterStatement(filterColumn);
            }
            query = query.removeEnd(' AND ');
        }
        
    	query += ' ORDER BY ' + settings.sortColumn + ' ' + settings.sortDirection + ' ';
    	query += ' LIMIT ' + settings.pageSize + ' OFFSET ' + offset;

    	return query;
    }
    
    private static Integer countQuestionnairies(SettingsWrapper settings, List<String> filterStatements) {
    	String query = 'SELECT COUNT() FROM Questionnaire_gne__c WHERE';
    	query += ' CreatedById = \'' + UserInfo.getUserId() + '\'';
    	
    	if(filterStatements.size() > 0) {
    		query += ' AND ';
            for(String filterColumn : filterStatements){
                query += GNE_MCCO_CRM_Util.getFilterStatement(filterColumn);
            }
            query = query.removeEnd(' AND ');
        }
        
        return Database.countQuery(query);
    }
    
    private class SettingsWrapper {
    	
    	public SFA2_View_Config_gne__c selectedView { get; private set; }
    	public Integer page { get; private set; }
    	public Integer pageSize { get; private set; }
    	public String sortColumn { get; private set; }
    	public String sortDirection { get; private set; }
    	
   		public Map<String, String> columnsHeaders { get; private set; }
        public Map<String, String> columnsHeadersType { get; private set; }
    	
    	public SettingsWrapper(String selectedViewJson, Integer page, Integer pageSize, String sortColumn, String sortDirection) {
    		this.selectedView 	= this.encodeSelectedView(selectedViewJson);
    		this.page 			= page;
    		this.pageSize		= pageSize;
    		this.sortColumn 	= sortColumn;
    		this.sortDirection 	= sortDirection;
            this.columnsHeaders	= this.getViewColumnsHeaders(this.selectedView);
            this.columnsHeadersType = this.getViewColumnsHeadersType(this.selectedView);
    	}

        private SFA2_View_Config_gne__c encodeSelectedView(String jsonString) {
            JSONParser parser = JSON.createParser(jsonString);
            SFA2_View_Config_gne__c result = (SFA2_View_Config_gne__c)parser.readValueAs(SFA2_View_Config_gne__c.class);
            return result;
        }   
        
        private Map<String, String> getViewColumnsHeaders(SFA2_View_Config_gne__c view){
        	Map<String, String> columnHeaders = new Map<String, String>();
        	for(String column : view.View_Fields_gne__c.split(';', 0)) {

				if(column.equalsIgnoreCase('recordtypeid')){
	                columnHeaders.put(column, 'Record Type');
	                continue;
	            }else if(column.equalsIgnoreCase('owner.firstname')){
	                columnHeaders.put(column, 'Owner First Name');
	                
	                continue;
	            } else if(column.equalsIgnoreCase('owner.lastname')){
	                columnHeaders.put(column, 'Owner Last Name');
	                
	                continue;
	            } else if(column.equalsIgnoreCase('owner.alias')){
	                columnHeaders.put(column, 'Owner Alias');
	                
	                continue;
	            } else if(column.equalsIgnoreCase('createdby.alias')){
	                columnHeaders.put(column, 'Created By Alias');
	                
	                continue;
	            } else if(column.equalsIgnoreCase('createdbyid')){
	                columnHeaders.put(column, 'Created By');
	                
	                continue;
	            } else if(column.equalsIgnoreCase('lastmodifiedby.alias')){
	                columnHeaders.put(column, 'Last Modified By Alias');
	                
	                continue;
	            } else if(column.equalsIgnoreCase('lastmodifiedbyId')){
	                columnHeaders.put(column, 'Last Modified By');
	                
	                continue;
	            } else if(column.equalsIgnoreCase('account.name')){
	                columnHeaders.put(column, 'Name');
	                
	                continue;
	            } else if(column.equalsIgnoreCase('accountid')){
	                columnHeaders.put(column, 'Account ID');
	                
	                continue;
	            } else if(column.equalsIgnoreCase('account.parentid')){
	                columnHeaders.put(column, 'Account Parent Account');
	                
	                continue;
	            } else if(column.equalsIgnoreCase('reportstoid')){
	                columnHeaders.put(column, 'Reports To');
	                
	                continue;
	            } else if(column.equalsIgnoreCase('reportsto.lastname')){
	                columnHeaders.put(column, 'Reports To Last Name');
	                
	                continue;
	            } else if(column.equalsIgnoreCase('reportsto.firstname')){
	                columnHeaders.put(column, 'Reports To First Name');
	                
	                continue;
	            } 

	            Schema.DescribeFieldResult fieldDescribe = Schema.getGlobalDescribe().get('Questionnaire_gne__c').getDescribe().fields.getMap().get(column).getDescribe();
	            columnHeaders.put(column, fieldDescribe.getLabel());
	            Schema.DisplayType fieldType = fieldDescribe.getType();
	            
        	}

            return columnHeaders;
        }
        
        private Map<String, String> getViewColumnsHeadersType(SFA2_View_Config_gne__c view){
			Map<String, String> columnHeaders = new Map<String, String>();
        	for(String column : view.View_Fields_gne__c.split(';', 0)) {

				if(column.equalsIgnoreCase('recordtypeid')){
	                columnHeaders.put(column, 'STRING');
	                continue;
	            }else if(column.equalsIgnoreCase('owner.firstname')){
	                columnHeaders.put(column, 'STRING');
	                
	                continue;
	            } else if(column.equalsIgnoreCase('owner.lastname')){
	                columnHeaders.put(column, 'STRING');
	                
	                continue;
	            } else if(column.equalsIgnoreCase('owner.alias')){
	                columnHeaders.put(column, 'STRING');
	                
	                continue;
	            } else if(column.equalsIgnoreCase('createdby.alias')){
	                columnHeaders.put(column, 'STRING');
	                
	                continue;
	            } else if(column.equalsIgnoreCase('createdbyid')){
	                columnHeaders.put(column, 'STRING');
	                
	                continue;
	            } else if(column.equalsIgnoreCase('lastmodifiedby.alias')){
	                columnHeaders.put(column, 'STRING');
	                
	                continue;
	            } else if(column.equalsIgnoreCase('lastmodifiedbyId')){
	                columnHeaders.put(column, 'STRING');
	                
	                continue;
	            } else if(column.equalsIgnoreCase('account.name')){
	                columnHeaders.put(column, 'STRING');
	                
	                continue;
	            } else if(column.equalsIgnoreCase('accountid')){
	                columnHeaders.put(column, 'STRING');
	                
	                continue;
	            } else if(column.equalsIgnoreCase('account.parentid')){
	                columnHeaders.put(column, 'STRING');
	                
	                continue;
	            } else if(column.equalsIgnoreCase('reportstoid')){
	                columnHeaders.put(column, 'STRING');
	                
	                continue;
	            } else if(column.equalsIgnoreCase('reportsto.lastname')){
	                columnHeaders.put(column, 'STRING');
	                
	                continue;
	            } else if(column.equalsIgnoreCase('reportsto.firstname')){
	                columnHeaders.put(column, 'STRING');
	                
	                continue;
	            } 

	            Schema.DisplayType type = Schema.getGlobalDescribe().get('Questionnaire_gne__c').getDescribe().fields.getMap().get(column).getDescribe().getType();
	            columnHeaders.put(column, type.Name());
	            
        	}

            return columnHeaders;
        }

    }
    
    private class QuestionnaireWrapper {
    	
    	public Integer countItems { get; private set; }
    	public List<Questionnaire_gne__c> items { get; private set; }
    	    	
   		public Map<String, String> columnsHeaders { get; private set; }
        public Map<String, String> columnsHeadersType { get; private set; }
    	
    	public QuestionnaireWrapper(Integer countItems, List<Questionnaire_gne__c> items, Map<String, String> columnsHeaders, Map<String, String> columnsHeadersType) {
    		this.countItems 		= countItems;
    		this.items 				= items;
    		this.columnsHeaders 	= columnsHeaders;
    		this.columnsHeadersType = columnsHeadersType;
    	}
    	
    }
    
 }