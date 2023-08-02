public with sharing class GNE_SFA2_PBT_Controller {
    
    public List<SObject> inputRecords {get; set;}
    
    public String objectType {get; set;}
    public String columnNamesInString {get; set;}
    public Integer pageSize {get; set;}
    public String referenceField {get;set;}
	
    public String nameOfThePage { get; set; }
    public Boolean sortingEnabled { get; set; }
    public Boolean checkboxesEnabled { get; set; }
    public Boolean editEnabled { get; set; }
    public Boolean deleteEnabled { get; set; }
    public String editURL { get; set; }
    private String queryString {get;set;}
        
    public Map<String, String> columnHeaders { get;set; }
    public Map<String, Boolean> columnSortable { get;set; }
    public Map<String, Boolean> columnIsLink { get;set; }
    public List<ListItemWrapper> records { get; set; }
    public List<String> visibleColumns { get; set; }
    public String actionListInString {get; set;}
    public List<RowActionWrapper> customActions {get; private set;}
    
    public Boolean customActionsEnabled { get {return customActions!=null && !customActions.isEmpty();}}
    
    
    //sorting related variables
    public String sortColumn {get; set;}
    public String sortDirection {get; set;}
    
    private String oldSortColumn {get; set;}
    private Map<String,String> refFieldMap;
    private Boolean isInitiated;
    private Map<String,Map<String,String>> columnAttributes;
    
    //paging related variables
    public List<String> noRecords {get { return new List<String>{''}; }} 
    public Integer recordsCount { get; set; }
    public Integer pageNumber { get; set; }
    
    public Integer pageNumbers { get; set; }
    public Boolean hasNext { get; set; }
    public Boolean hasPrevious { get; set; }
    
    public Boolean maxRecordsReached { get; set; }
    public ListenerEngine engine { get; set; }
    
    public static final String LABEL_ATTRIBUTE_NAME = 'label';
    public static final String SOURCE_ATTRIBUTE_NAME = 'source';
    public static final String SOURCE_CONTROLLER = 'controller';
    public static final String HREF_ATTRIBUTE_NAME = 'href';
    public static final String SORT_BY_ATTRIBUTE_NAME = 'sortby';
    public static final String LINK_ATTRIBUTE_NAME = 'link';
    public static final String FORMAT_ATTRIBUTE_NAME = 'format';
    
    public static final String DEFAULT_DATETIME_FORMAT = 'MM/dd/yyyy HH:mm:ss';
	public static final String DEFAULT_DATE_FORMAT = 'MM/dd/yyyy';
	
    
    public GNE_SFA2_PBT_Controller() {
    	System.debug('***********reference field*******' + referenceField);
        maxRecordsReached = false;
        sortDirection = 'ASC';
        pageNumber = 1;
        pageNumbers = 1;
        recordsCount = 0;
        columnHeaders  = new Map<String, String>();
        columnSortable = new Map<String, Boolean>();
        columnIsLink = new Map<String, Boolean>();
        visibleColumns = new List<String>();
        refFieldMap = new Map<String, String>();
        isInitiated = false;
        columnAttributes = new Map<String,Map<String,String>>();
        customActions = new List<RowActionWrapper>();
    }
    
    private void initList() {
    	if(isInitiated) {
    		return;
    	}
    	
    	isInitiated = true;
    	
        editEnabled = editEnabled && Schema.getGlobalDescribe().get(objectType).getDescribe().isUpdateable();
        deleteEnabled = deleteEnabled && Schema.getGlobalDescribe().get(objectType).getDescribe().isDeletable();
        
        if(engine!=null) {
        	engine.connectTo(this);
        }
        
        Map<String,Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();  
        Schema.SObjectType sObjectType = globalDescribeMap.get(objectType);  
        Schema.DescribeSObjectResult result = sObjectType.getDescribe();  
        Map<String,Schema.SObjectField> sObjectFieldMap = result.fields.getMap();
        Set<String> yesValues = new Set<String>{'1','Y','TRUE','YES'};
			
        
        for(String columnData : columnNamesInString.split(',')) {
			String columnName = null;
			Map<String, String> attrs = new Map<String,String>();
			
			Integer attrStartIndex = columnData.indexOf('[');
			Integer attrEndIndex = columnData.lastIndexOf(']');
			
			if(attrStartIndex!=attrEndIndex) {
				columnName = columnData.left(attrStartIndex).trim();
				for(String attrData : columnData.substring(attrStartIndex+1, attrEndIndex).split(';')) {
					String[] attrDataList = attrData.split('=');
					attrs.put(attrDataList[0].trim().toLowerCase(), attrDataList[1]);
				}
			} else {
				columnName = columnData.trim();
			}
			
        	visibleColumns.add(columnName);
        	columnAttributes.put(columnName, attrs);
        	
        	if(attrs.containsKey(LABEL_ATTRIBUTE_NAME)) {
        		columnHeaders.put(columnName, attrs.get(LABEL_ATTRIBUTE_NAME));
        	}
        	
        	if(columnName.contains('.')) { // reference field
        		String[] fieldNameAndPath = columnName.split('\\.',2);
        		refFieldMap.put(fieldNameAndPath[0].toUpperCase(), fieldNameAndPath[1]);
        		
        		if(!columnHeaders.containsKey(columnName)) {
        			columnHeaders.put(columnName, columnName);
        		}
        	} else if(!columnHeaders.containsKey(columnName) && sObjectFieldMap.containsKey(columnName)) {
        		columnHeaders.put(columnName, sObjectFieldMap.get(columnName).getDescribe().getLabel());
        	}
        	
        	columnSortable.put(columnName, !attrs.containsKey(SORT_BY_ATTRIBUTE_NAME) || 
        								   yesValues.contains(attrs.get(SORT_BY_ATTRIBUTE_NAME).toUpperCase()));
        	columnIsLink.put(columnName, attrs.containsKey(LINK_ATTRIBUTE_NAME));
        }
        
        if(String.isNotBlank(actionListInString)) {
        	for(String actionData : actionListInString.split(',')) {
        		String actionName = null;
        		String actionLabel = null;
        		String actionHref = null;
				Map<String, String> attrs = new Map<String,String>();
			
				Integer attrStartIndex = actionData.indexOf('[');
				Integer attrEndIndex = actionData.lastIndexOf(']');
			
				if(attrStartIndex!=attrEndIndex) {
					actionName = actionData.left(attrStartIndex).trim();
					for(String attrData : actionData.substring(attrStartIndex+1, attrEndIndex).split(';')) {
						String[] attrDataList = attrData.split('=');
						attrs.put(attrDataList[0].trim().toLowerCase(), attrDataList[1]);
					}
				} else {
					actionName = actionData.trim();
				}
				
				if(attrs.containsKey(LABEL_ATTRIBUTE_NAME)) {
        			actionLabel = attrs.get(LABEL_ATTRIBUTE_NAME);
        		}
        		
        		if(attrs.containsKey(HREF_ATTRIBUTE_NAME)) {
        			actionHref = attrs.get(HREF_ATTRIBUTE_NAME);
        		}
        		
        		if(actionName!=null && actionLabel!=null) {
        			customActions.add(new RowActionWrapper(actionName, actionLabel, actionHref, customActions.isEmpty()));
        		}
        	}
        }
    }
          
    public PageReference loadRecords() {
    	initList();
    	inputRecords = inputRecords!=null ? inputRecords : new List<SObject>(); 
        List<ListItemWrapper> tempRecords = wrapResults(inputRecords);
        records = new List<ListItemWrapper>();
        if(String.isNotBlank(sortColumn)) {
        	tempRecords.sort();	
        }
        
        Integer idx = 0;
        Integer startIdx = (pageNumber-1) * pageSize;
        Integer endIdx = startIdx + pageSize;
        Set<String> columnNames = new Set<String>(visibleColumns);
        for(ListItemWrapper wrapper : tempRecords) {
        	if(startIdx <= idx) {
        		if(endIdx == idx) {
        			break;
        		}
        		wrapper.init(false, columnNames, columnAttributes, engine,  customActions);
        		records.add(wrapper);
        	}
        	idx++;
        }
        
        System.debug('##### Records === ' + records);
        recordsCount = inputRecords.size();
        pageNumbers = countPageNumbers();
        hasNext = checkIfHasNext();
        hasPrevious = checkIfHasPrevious();
        
        return null;
    }
    
    public void setSelectedRecords(Set<Id> selectedRecords) {
    
    }
    
    public Boolean isAllSelected {get; set;}
    
    public PageReference checkAll() {
    	if(records!=null) {
	    	for(ListItemWrapper record : records) {
	    		record.selected = (isAllSelected == true);
	        }
    	}
    	return null;
    }
    
    public Integer countPageNumbers(){
        return Math.ceil(recordsCount / (pageSize * 1.0)).intValue();
    }
    
    private List<ListItemWrapper> wrapResults(List<sObject> sObjectsList) {
        List<ListItemWrapper> result = new List<ListItemWrapper>();
        Set<String> columnNames = new Set<String>(visibleColumns);
        for(sObject o : sObjectsList) {
            result.add(new ListItemWrapper(o, false, columnNames, columnAttributes, engine, sortColumn, sortDirection, customActions));
        }
        return result;
    }
    
    public PageReference previousPage() {
        pageNumber--;
        return loadRecords();
    }
    
    public PageReference nextPage() {
        pageNumber++;
        return loadRecords();
    }
    
    public Boolean checkIfHasNext() {
        return (pageNumber < pageNumbers);
    }
    
    public Boolean checkIfHasPrevious() {
        return (pageNumber > 1);
    }
    
    public PageReference changeSorting() {
        pageNumber = 1;
        if(sortColumn == oldSortColumn){
            if(sortDirection == 'ASC'){
                sortDirection = 'DESC';
            }else{
                sortDirection = 'ASC';
            }
        }else{
            sortDirection = 'ASC';
            oldSortColumn = sortColumn;
        }
        return loadRecords();
    }
    
    public class ListItemWrapper implements Comparable {
        public sObject obj { get; set; }
        public Boolean selected { get; set; }
        public Map<String,Object> values {get; set;}
        public Map<String,Object> displayValues {get; set;}
        private String sortColumn;
        private String sortDirection;
        public String editLink {get; private set;}
        public List<RowActionWrapper> customActions {get; private set;}
        
        public ListItemWrapper(sObject obj, Boolean selected, Set<String> columnNames,
        		Map<String,Map<String, String>> columnsAttrs,
        		ListenerEngine engine, String sortColumn, String sortDirection, List<RowActionWrapper> customActions) {
        	values = new Map<String,Object>();
        	this.obj = obj;
            this.sortColumn = sortColumn;
            this.sortDirection = sortDirection;
            
            Map<String,Object> objAttrs = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(obj));
            
            for(String columnName : columnNames) {
            	Map<String, String> columnAttrs = columnsAttrs.get(columnName);
            	Object value = getValueForColumn(columnName, columnAttrs, objAttrs, engine);
            	values.put(columnName, (value!=null ? value : ''));
            }
        }
        
        public void init(Boolean selected, Set<String> columnNames, Map<String,Map<String, String>> columnsAttrs, ListenerEngine engine, List<RowActionWrapper> customActions) {
        	displayValues = new Map<String,Object>();
        	this.selected = selected;
            this.customActions = new List<RowActionWrapper>();
            
            for(RowActionWrapper raw : customActions) {
            	this.customActions.add(raw.clone());
            }
            
            PageReference editLinkRef = new PageReference('/' + obj.Id + '/e');
            PageReference currentPage = ApexPages.currentPage();
            currentPage.getParameters().remove('AJAXREQUEST');
            currentPage.getParameters().remove('com.salesforce.visualforce.ViewStateCSRF');
            editLinkRef.getParameters().put('retURL',currentPage.getUrl());
            this.editLink = editLinkRef.getUrl();
            
            Map<String,Object> objAttrs = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(obj));
            
            for(String columnName : columnNames) {
            	Map<String, String> columnAttrs = columnsAttrs.get(columnName);
            	Object value = values.get(columnName);
            	Object displayValue = getDisplayValueForColumn(value, columnAttrs);
            	displayValues.put(columnName, (displayValue!=null ? displayValue : ''));
            	
            	if(columnAttrs.containsKey(GNE_SFA2_PBT_Controller.LINK_ATTRIBUTE_NAME)) {
            		String linkField = columnAttrs.get(GNE_SFA2_PBT_Controller.LINK_ATTRIBUTE_NAME);
            		String linkFieldValue = linkField == 'Id' 
            			? (String)obj.Id 
            			: (String)getValueForColumn(linkField, null, objAttrs, engine);
            		values.put(columnName + '__href', (linkFieldValue!=null ? ('/' + linkFieldValue) : '#')); 
            	}
            }
            
            processCustomActions(engine);
        }
        
        private Object getValueForColumn(String columnName, Map<String, String> columnAttrs, Map<String,Object> objAttrs, ListenerEngine engine) {
        	Object result = null;
        	
        	if(columnAttrs!=null 
        	   && columnAttrs.containsKey(GNE_SFA2_PBT_Controller.SOURCE_ATTRIBUTE_NAME) 
               && columnAttrs.get(GNE_SFA2_PBT_Controller.SOURCE_ATTRIBUTE_NAME)==GNE_SFA2_PBT_Controller.SOURCE_CONTROLLER) {
            	 if(engine!=null) {
            	  	result = engine.getColumnValueForRecord(obj, columnName);
            	 } 
            } else if(columnName.contains('.')) {
            	String[] refFieldPath = columnName.split('\\.');
            	
            	Object currentValue = objAttrs;
            	for(String fieldName : refFieldPath) {
            		if(currentValue==null) {
            			break;
            		}
            		currentValue = ((Map<String,Object>)currentValue).get(fieldName);
            	}
            	result = currentValue;
            } else {
            	result = obj.get(columnName);
            }
        	
        	return result;
        }
        
        private Object getDisplayValueForColumn(Object value, Map<String, String> columnAttrs) {
        	Object displayValue = value;
        	
        	if(!(value instanceof String) || String.isNotBlank((String)value)) {
        		String formatPattern = columnAttrs.get(GNE_SFA2_PBT_Controller.FORMAT_ATTRIBUTE_NAME);
        		if(value instanceof Date) {
        			String dateFormat = formatPattern!=null ? formatPattern : GNE_SFA2_PBT_Controller.DEFAULT_DATE_FORMAT;
        			displayValue = ((DateTime)value).format(dateFormat);
        		} else if(value instanceof DateTime) {
        			String dateTimeFormat = formatPattern!=null ? formatPattern : GNE_SFA2_PBT_Controller.DEFAULT_DATETIME_FORMAT;
        			displayValue = ((DateTime)value).format(dateTimeFormat);
        		} else if(formatPattern!=null) {
        			displayValue = String.format(formatPattern, new List<String>{String.valueOf(value)});
        		}
        	}
        	
        	return displayValue;
        }
        
        public Integer compareTo(Object otherObj) {
        	Integer result = 0;
    		ListItemWrapper otherWrapper = (ListItemWrapper)otherObj;
    		if(sortColumn!=null) {
    			Object myValue = values.get(sortColumn);
    			Object otherValue = otherWrapper.values.get(sortColumn);
    			if(myValue instanceof String || otherValue instanceof String) { // check also other values to handle null cells
    				result = String.valueOf(myValue).compareTo(String.valueOf(otherValue));
    			} else if(myValue instanceof Integer && myValue!=otherValue) {
    				result = (((Integer)myValue)>((Integer)otherValue)) ? 1 : -1;
    			} else if(myValue instanceof Decimal && myValue!=otherValue) {
    				result = (((Decimal)myValue)>((Decimal)otherValue)) ? 1 : -1;
    			} else if(myValue instanceof Double && myValue!=otherValue) {
    				result = (((Double)myValue)>((Double)otherValue)) ? 1 : -1;
    			} else if(myValue instanceof Date && myValue!=otherValue) {
    				result = (((Date)myValue)>((Date)otherValue)) ? 1 : -1;
    			} else if(myValue instanceof DateTime && myValue!=otherValue) {
    				result = (((DateTime)myValue)>((DateTime)otherValue)) ? 1 : -1;
    			} else if(myValue instanceof Time && myValue!=otherValue) {
    				result = (((Time)myValue)>((Time)otherValue)) ? 1 : -1;
    			} else if(myValue instanceof Boolean && myValue!=otherValue) {
    				result = ((Boolean)myValue) ? 1 : -1;
    			} else if(myValue instanceof Id && myValue!=otherValue) {
    				result = (((Id)myValue)>((Id)otherValue)) ? 1 : -1;
    			}
    		}
    		
    		if(sortDirection=='DESC') {
    			result = -result;
    		}
    		
    		return result;
    	}
        
        private void processCustomActions(ListenerEngine engine) {
        	
        	for(RowActionWrapper action : customActions) {
        		if(String.isNotBlank(action.href)) {
        			PageReference actionLinkRef = new PageReference(action.href);
        			actionLinkRef.getParameters().put('id',obj.Id);
            		actionLinkRef.getParameters().put('retURL',ApexPages.currentPage().getUrl());
            		action.href = actionLinkRef.getUrl();
        		} else if(engine!=null){
        			action.href = engine.getCustomActionLink(action.name, obj);
        		} else {
        			action.href = '#';
        		}
        	}
        }
    }
    
    public class RowActionWrapper {
    	public String name {get; private set;}
    	public String href {get; private set;}
    	public String label {get; private set;}
    	public Boolean isFirst {get; private set;}
    	
    	public RowActionWrapper(String a_name, String a_label, String a_href, Boolean a_isFirst) {
    		name = a_name;
    		href = a_href;
    		label = a_label;
    		isFirst = a_isFirst;
    	}
    }
    
    public virtual class ListenerEngine {
	    private Set<Id> selectedRecords;
	    private GNE_SFA2_PBT_Controller listController; 
	    
	    public ListenerEngine() {}
	    
	    public void connectTo(GNE_SFA2_PBT_Controller a_listController) {
	    	listController = a_listController;
	    }
	        
	    public void setSelectedRecords(Set<Id> selectedRecords) {
	        setSelectedRecords(selectedRecords, false);
	    }
	    
	    public void setSelectedRecords(Set<Id> selectedRecords, Boolean refreshList) {
	    	this.selectedRecords = selectedRecords;
	    	
	    	if(refreshList==true && listController!=null) {
	    		listController.setSelectedRecords(selectedRecords);
	    	}
	    }
	    
	    public Set<Id> getSelectedRecords() {
	    	Set<Id> ids = new Set<Id>();
	    	
	    	if(listController!=null) {
	    		for(ListItemWrapper recWrapper : listController.records) {
	    			if(recWrapper.selected) {
	    				ids.add(recWrapper.obj.Id);
	    			}
	    		}
	    	}
	    	
	    	return ids;
	        //return selectedRecords;
	    }
	    
	    public virtual Object getColumnValueForRecord(SObject obj, String columnName) {
	    	return null;
	    }
	    
	    public virtual String getCustomActionLink(String actionName, SObject obj) {
	    	return '/TBD?Id=' + obj.Id;
	    }
	}
}