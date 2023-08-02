public with sharing class GNE_SFA2_FasterListView_Controller {

	public static Integer MAX_RECORD_COUNT { get { return 1000; } }

	public String sObjectAPIName { 
			get; 
			set {
				sObjectAPIName = value;
				initConfig();
			}
	}

	public transient String configJSON { get; set; }
	public transient String pageName { get; set; }

	public void initConfig() {
		GNE_SFA2_ListViewConfig lvConfig = new GNE_SFA2_ListViewConfig(pageName);
		PageConfig pageConfig = new PageConfig(lvConfig);   
		configJSON = JSON.serialize(pageConfig);
	}

	@RemoteAction
	public static Response getRecords(List<Map<String, Object>> request) {
	 
		Params params = new Params(request);
		String nameFilter = '';
		if (!String.isBlank(params.search)) {
			nameFilter = ' WHERE Name LIKE \'%' + params.search + '%\' ';
		}

		Integer start = params.start;
		Integer length = params.length;

		for (Integer i = params.columns.size() - 1; i >= 0; i--) {
			if (params.columns[i] == 'Action') {
				params.columns.remove(i);
			}
		}
 
		String soql = ''
				+ params.queryString
				+ nameFilter
				+ ' ORDER BY ' + String.join(orderBys(params), ', ')
				+ ' LIMIT ' + length
				+ ' OFFSET ' + start;

		return new Response(
					params.echo,
					Database.countQuery(params.countQueryString),
					Database.query(soql)
				);
	}
	 
	private static List<String> orderBys(Params params) {
		Map<String, String> soqlDirections = new Map<String, String>{
					'asc' => 'ASC NULLS LAST',
					'desc' => 'DESC NULLS FIRST'
				};
		List<String> orderBys = new List<String>();
		Integer min = Math.min(params.sortColumns.size(), params.sortDirections.size());
		Integer sortColumnOffset = params.actionColumnVisible ? 1 : 0;
		for (Integer i = 0; i < min; i++) {
			String columnName = params.columns[params.sortColumns[i] - sortColumnOffset];
			if (params.currentConfig.findFieldByName(columnName).describe.type == 'reference') {
				columnName = params.currentConfig.findFieldByName(columnName).describe.relationshipName + '.Name';
			}
			String sortDir = soqlDirections.get(params.sortDirections[i]);
			orderBys.add(''
					+ columnName
					+ ' '
					+ sortDir
					);
		}
		return orderBys;
	}

	@RemoteAction
	public static ActionResponse updateLastSeenView(String viewId, String pageName) {
		SFA2_User_Preferences_gne__c userPreferences;
		try{
			userPreferences = [SELECT Last_View_Used_gne__c, Last_Territory_Used_gne__c 
								FROM  SFA2_User_Preferences_gne__c 
								WHERE Last_View_Used_gne__r.Page_Name_gne__c = :pageName 
									AND User_gne__c = :Userinfo.getUserId() LIMIT 1];
		} 
		catch(Exception e) {
			userPreferences = new SFA2_User_Preferences_gne__c(User_gne__c = UserInfo.getUserId());
		}
		userPreferences.Last_View_Used_gne__c = viewId;
		upsert userPreferences;
		return new ActionResponse('Success', 'Last Seen View Updated.');
	}

	@RemoteAction
	public static ActionResponse deleteRecord(String recordId) {	
		if (String.isNotBlank(recordId)) {
			try {
				Database.delete(recordId);
				return new ActionResponse('Success', 'Record has been deleted.');
			}
			catch (Exception ex) {
				System.debug(' DEL EXCEPTION ' + ex);
				return new ActionResponse('Error', 'Record could not be deleted. You may have insufficient access rights.');
			}
		}
		else {
			return new ActionResponse('Error', 'Record ID to delete was empty.');
		}
	}

	private class PageConfig {
		List<ViewConfig> availableViews;
		String selectedViewId;
		String userTimeZone;

		public PageConfig(GNE_SFA2_ListViewConfig lvConfig) {
			this.userTimeZone = UserInfo.getTimeZone().getID();
			this.selectedViewId = lvConfig.getCurrentView().Id;
			this.availableViews = new List<ViewConfig>();

			for (SFA2_View_Config_gne__c view : lvConfig.getViews()) {
				String queryStringForView = lvConfig.getQueryString(view);
				String countQueryStringForView = lvConfig.getCountQueryString(view, MAX_RECORD_COUNT);
				List<GNE_SFA2_Base_Ctrl.Field> fieldsForView = lvConfig.getFieldList(view);
				Boolean editable = lvConfig.checkIfViewEditable(view);
				availableViews.add(new ViewConfig(view, queryStringForView, countQueryStringForView, fieldsForView, editable));
			}
		}
	}

	private class ViewConfig {
		private String id;
		private String name;
		private String queryString;
		private String countQueryString;
		private List<GNE_SFA2_Base_Ctrl.Field> selectedFields;
		private Boolean editable;
		private String sortColumn;
		private String sortDirection;

		public ViewConfig(SFA2_View_Config_gne__c view, String queryString, String countQueryString, List<GNE_SFA2_Base_Ctrl.Field> selectedFields, Boolean editable) {
			this.id = view.Id;
			this.name = view.View_Name_gne__c;
			this.queryString = queryString;
			this.countQueryString = countQueryString;
			this.selectedFields = selectedFields;
			this.editable = editable;
			this.sortColumn = view.Sorting_Field_gne__c;
			this.sortDirection = view.Sorting_Order_gne__c;
		}

		public GNE_SFA2_Base_Ctrl.Field findFieldByName(String name) {
			if (String.isNotBlank(name) && selectedFields != null) {
				for (GNE_SFA2_Base_Ctrl.Field field : selectedFields) {
					if (field.describe.name == name) {
						return field;
					}
				}
			}
			return null;
		}
	}

	public class Response {
		public Integer sEcho;
		public Integer iTotalRecords;
		public Integer iTotalDisplayRecords;
		public List<SObject> aaData;

		Response(Integer echo, Integer total, List<SObject> queriedSobjects) {
			this.sEcho = echo;
			this.iTotalRecords = total;
			this.iTotalDisplayRecords = total;
			this.aaData = queriedSobjects;
		}
	}
 
	private class Params {	 
		private Map<String, Object> paramToValueMap = new Map<String, Object>();     
		private Integer echo;
		private Integer start;
		private Integer length;
		private List<String> columns;
		private List<Integer> sortColumns;
		private List<String> sortDirections;
		public String search;
		public String sObjectType;
		public String queryString;
		public String countQueryString;
		public Boolean actionColumnVisible;
		public ViewConfig currentConfig;
		 
		Params(List<Map<String, Object>> request) {
			paramToValueMap = new Map<String, Object>();
			for (Map<String, Object> requestItem : request) {
				paramToValueMap.put((String)requestItem.get('name'), requestItem.get('value'));
			}

			echo = integer('sEcho');
			start = integer('iDisplayStart');
			length = integer('iDisplayLength');
			columns = stringArray('mDataProp');
			sortColumns = integerArray('iSortCol');
			sortDirections = stringArray('sSortDir');
			search = (String)paramToValueMap.get('sSearch');
			sObjectType = (String)paramToValueMap.get('sObject');
			queryString = (String)paramToValueMap.get('queryString');
			countQueryString = (String)paramToValueMap.get('countQueryString');
			actionColumnVisible = (Boolean)paramToValueMap.get('actionColumnVisible');
			currentConfig = (ViewConfig)JSON.deserialize((String)paramToValueMap.get('currentConfig'), ViewConfig.class);
		}
		 
		List<String> stringArray(String prefix) {
			List<String> strings = new List<String>();
			for (Object o : array(prefix)) {
				strings.add(o != null ? soqlInjectionGuard(String.valueOf(o)) :null);
			}
			return strings;
		}
		 
		List<Integer> integerArray(String prefix) {
			List<Integer> integers = new List<Integer>();
			for (Object o : array(prefix)) {
				integers.add(o != null ? Integer.valueOf(o) : null);
			}
			return integers;
		}
 
		List<Object> array(String prefix) {
			List<Object> objects = new List<Object>();
			for (Integer i = 0; true; i++) {
				Object o = paramToValueMap.get(prefix + '_' + i);
				if (o != null) {
					objects.add(o);
				} else {
					break;
				}
			}
			return objects;
		}
		 
		Integer integer(String name) {
		   Object o = paramToValueMap.get(name);
		   if (o instanceof Decimal) {
			   return ((Decimal) o).intValue();
		   } else if (o instanceof Integer) {
			   return (Integer) o;
		   } else {
			   return null;
		   }
		}
		 
		String soqlInjectionGuard(String s) {
			return s != null ? String.escapeSingleQuotes(s) : null;
		}
	}	

	private class ActionResponse {
		String type;
		String message;

		public ActionResponse(String type, String message) {
			this.type = type;
			this.message = message;
		}
	}
}