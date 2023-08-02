public class GNE_SFA2_RL_Component_AttributesWrapper{
	private static final String FIELDS_CSV = 'fieldsCSV';
	private static final String ADDL_FILTER = 'filter';
	private static final String ORDER_BY_FIELD = 'orderByFieldName';
	private static final String HIDE_EDIT_LINK = 'hideEditLink';
	private static final String HIDE_DELETE_LINK = 'hideDeleteLink';
	private static final String URL_NEW_RECORD = 'urlForNewRecord';
	private static final String URL_VIEW_RECORD = 'urlForViewRecord';
	private static final String PAGE_SIZE = 'pageSize';
	private static final String PARENT_FIELD = 'parentFieldName';
	private static final String HIDE_BUTTONS = 'hideButtons';
	private static final String SORT_DIRECTION = 'sortDirection';
	private static final String CUSTOM_BUTTONS= 'customButtons';
	private static final String ONCLICK= 'onClick';
	private static final String IMMEDIATE= 'immediate';
	private static final String HELPTEXT= 'helpText';
	private static final String RERENDER= 'rerender';
	private static final String ACTION= 'action';
	private static final String RECORDS_LIMIT= 'recordsLimit';
	private static final String ALWAYS_DISPLAY_VIEW_ALL= 'alwaysDisplayViewAll';
	private static final String INITIALLY_COLLAPSED = 'initiallyCollapsed';
	

	public String fieldsCSV {get;set;}
	public String filter {get;set;}
	public String orderByFieldName {get;set;}
	public Boolean hideEditLink {get;set;}
	public Boolean hideDeleteLink {get;set;}
	public String urlForNewRecord {get;set;}
	public String urlForViewRecord {get;set;}
	public Integer pageSize {get;set;}
	public Integer recordsLimit {get;set;}
	public String parentFieldName {get;set;}
	public Boolean hideButtons {get;set;}
	public String sortDirection {get;set;}
	public Map<String, String> onClickButtonsMap {get;set;}
	public Map<String, String> immediateButtonsMap {get;set;}
	public Map<String, String> rerenderButtonsMap {get;set;}
	public Map<String, String> actionButtonsMap {get;set;}
	public Map<String, String> helpTextButtonsMap {get;set;}
	public List<String> customButtonsList {get;set;}
	public Map<String, String> urlParametersMap {get;set;}
	public Boolean alwaysDisplayViewAll {get;set;}
	public Boolean initiallyCollapsed {get;set;}
	
	
	public GNE_SFA2_RL_Component_AttributesWrapper(String attributeString){
		fieldsCSV = '';
		filter = null;
		orderByFieldName = '';
		hideEditLink = false;
		hideDeleteLink = false;
		urlForNewRecord ='';
		urlForViewRecord ='';
		pageSize = 3;
		recordsLimit = getRelatedListRecordsLimit();
		parentFieldName = '';
		hideButtons = false;
		sortDirection = '';
		customButtonsList = new List<String>();
		onClickButtonsMap = new Map<String, String>();
		immediateButtonsMap = new Map<String, String>();
		rerenderButtonsMap = new Map<String, String>();
		helpTextButtonsMap = new Map<String, String>();
		actionButtonsMap = new Map<String, String>();
		urlParametersMap  = new Map<String, String>();
		urlParametersMap.put('objectId', 'id');
		alwaysDisplayViewAll = false;
		initiallyCollapsed = false;
		
		Map<String,String> attributeMap = parseRelatedListAttributes(attributeString);
		for(String key:attributeMap.keySet()){
			if(key.equals(FIELDS_CSV)) {
				fieldsCSV = attributeMap.get(key);
			}else if(key.equals(ADDL_FILTER)) {
				filter = attributeMap.get(key);
				if (filter.contains('#')){
					filter = filter.replaceAll('#','=');
				}
			}else if(key.equals(ORDER_BY_FIELD)) {
				orderByFieldName = attributeMap.get(key);
			}else if(key.equals(HIDE_EDIT_LINK)) {
				hideEditLink = !attributeMap.get(key).toLowerCase().equals('false');
			}else if(key.equals(HIDE_DELETE_LINK)) {
				hideDeleteLink = !attributeMap.get(key).toLowerCase().equals('false');
			}else if(key.equals(URL_NEW_RECORD)) {
				urlForNewRecord =  attributeMap.get(key);
				if(urlForNewRecord.contains('url#')){
					for(String f : attributeMap.get(key).split(',')){
						String[] values = f.split('#');
						if(values.size() == 2){
							if(values[0].compareTo('url') == 0){
								urlForNewRecord = values[1];
							}else{
								urlParametersMap.put(values[0], values[1]);
							}
						}
					}
				}
			}else if(key.equals(URL_VIEW_RECORD)) {
				urlForViewRecord = attributeMap.get(key);
			}else if(key.equals(PAGE_SIZE)) {
				pageSize = Integer.valueof(attributeMap.get(key));
			}else if(PARENT_FIELD.compareTo(key) == 0) {
				parentFieldName = attributeMap.get(key);
			}else if(key.equals(HIDE_BUTTONS)) {
				hideButtons = attributeMap.get(key).toLowerCase().compareTo('false') != 0;
			}else if(key.equals(SORT_DIRECTION)) {
				sortDirection = attributeMap.get(key);
			}else if(key.equals(RECORDS_LIMIT)) {
				recordsLimit = Integer.valueof(attributeMap.get(key));
			}else if(key.equals(ALWAYS_DISPLAY_VIEW_ALL)) {
				alwaysDisplayViewAll = !attributeMap.get(key).toLowerCase().equals('false');
			}else if(key.equals(INITIALLY_COLLAPSED)) {
				initiallyCollapsed = !attributeMap.get(key).toLowerCase().equals('false');
			}else if(key.equals(CUSTOM_BUTTONS)) {

				for(String f: attributeMap.get(key).split(',')) {
					List<String> values = f.split('#');
					if(values.size() == 2){
						customButtonsList.add(values.get(0));
						actionButtonsMap.put(values.get(0), '');
						onClickButtonsMap.put(values.get(0), '');
						immediateButtonsMap.put(values.get(0), '');
						helpTextButtonsMap.put(values.get(0), '');
						for(String g: values.get(1).split(':')) {
							List<String> actionTypes = g.split('>');
							if(actionTypes.size() == 2){
								if(actionTypes.get(0).compareTo(ACTION) == 0) {
									actionButtonsMap.put(values.get(0), actionTypes.get(1));
								}else if(actionTypes.get(0).compareTo(ONCLICK) == 0) {
									onClickButtonsMap.put(values.get(0), actionTypes.get(1));
								}else if(actionTypes.get(0).compareTo(IMMEDIATE) == 0) {
									immediateButtonsMap.put(values.get(0), actionTypes.get(1));
								}else if(actionTypes.get(0).compareTo(RERENDER) == 0) {
									rerenderButtonsMap.put(values.get(0), actionTypes.get(1));
								}else if(actionTypes.get(0).compareTo(HELPTEXT) == 0) {
									helpTextButtonsMap.put(values.get(0), actionTypes.get(1));
								}
							}
						}
					}
				}
			}
		}
		//System.debug('**********actionButtonsMap'+actionButtonsMap);
		//System.debug('**********customButtonsList'+customButtonsList);
	}
	
	public Boolean shouldUpdateURL(){
		return urlParametersMap.size()!= 0;
	}
	
	private static Map<String,String> parseRelatedListAttributes(String attributesString){
		Map<String, String> attributeMap = new Map<String, String>();
		if(attributesString != null ){
			for(String keyValuePair : attributesString.split(';', 0)) {
				List<String> values = keyValuePair.trim().split('=', 0);
				if(values.size() == 2) {
					attributeMap.put(values.get(0), values.get(1));
				}
			}
		}
		return attributeMap;
	}
	
    private Integer getRelatedListRecordsLimit(){
    	Integer rlimit = 100;
    	try { rlimit = Integer.valueOf(GNE_SFA2_RelatedList_Limit__c.getInstance('GNE_SFA2_RelatedList_Limit').GNE_SFA2_RelatedList_Limit__c); } 
    	catch (Exception e){ System.debug(e); }    	
		return rlimit;
	}
}