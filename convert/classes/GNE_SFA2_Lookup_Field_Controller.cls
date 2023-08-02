public with sharing class GNE_SFA2_Lookup_Field_Controller {
	
	public String fieldId {get; set;}
	public String recordId {get; private set;}
	public String displayValue {get; set;}
	public String columns {get; private set;}
	public String columnNames {get; set;}
	public String columnLabels {get; set;}
	public String whereExpressions {get; private set;}
	public String orderFields {get; set;}
	public String recordIdsInText {get; private set;}
	public String searchFields {get; set;}
	public String displayFieldName {get; private set;}
	public String objectTypeName {get; private set;}
	public String lookupPage {get; set;}
	public String onChangeMethod {get; set;}
	public Boolean disabled {get; set;}
	public List<SObject> virtualRecords {get; private set;}
	public String virtualRecordsInJSON {get; private set;}
	public Integer autocompleteSize {get; set;}
	public Boolean autocompleteEnabled {get; set;}
	public Boolean standardLookupEnabled {get; set;}
	public Boolean popupModeEnabled {get; set;}
    public Boolean searchWithoutSharings {get; set;}
	
	public static Map<String,Map<String,String>> fieldLabelsCache;
	
	public static final String LABEL_ATTRIBUTE_NAME = 'label';
	public static final String SEARCH_BY_ATTRIBUTE_NAME = 'searchby';
	public static final String DISPLAY_ATTRIBUTE_NAME = 'display';
	
	private Boolean isWhereExpressionsSet;
	private Boolean isRecordIdsInTextSet;
	
	public GNE_SFA2_Lookup_Field_Controller() {}
	
	public void setRecordId(String a_recordId) {
		recordId = a_recordId;
		initController();
	}
	
	public void setDisplayFieldName(String a_displayFieldName) {
		displayFieldName = a_displayFieldName;
		initController();
	}
	
	public void setObjectTypeName(String a_objectTypeName) {
		objectTypeName = a_objectTypeName;
		initController();
	}
	
	public void setWhereExpressions(String a_whereExpressions) {
		whereExpressions = a_whereExpressions;
		isWhereExpressionsSet = true;
		initController();
	}
	
	public void setRecordIdsInText(String a_recordIdsInText) {
		recordIdsInText = a_recordIdsInText;
		isRecordIdsInTextSet = true;
		initController();
	}
	
	public void setVirtualRecords(List<SObject> a_virtualRecords) {
		virtualRecords = a_virtualRecords;
		initController();
	}
	
	private void initController() {
		if(String.isNotBlank(objectTypeName) && String.isNotBlank(columns) && columnNames==null) {
			List<String> columnNamesList = new List<String>();
			List<String> columnLabelsList = new List<String>();
			List<String> columnSearchByList = new List<String>();
			Map<String,Map<String,String>> columnAttrs = new Map<String,Map<String,String>>(); 
			
			List<String> columnList = columns.split(',');
			
			Set<String> yesValues = new Set<String>{'1','Y','TRUE','YES'};
			
			for(String columnData : columnList) {
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
				
				columnNamesList.add(columnName);
				columnAttrs.put(columnName,attrs);
				
	        	if(attrs.containsKey(SEARCH_BY_ATTRIBUTE_NAME)) {
	        		if(yesValues.contains(attrs.get(SEARCH_BY_ATTRIBUTE_NAME).toUpperCase())) {
	        			columnSearchByList.add(columnName);	
	        		}
	        	} else {
	        		columnSearchByList.add(columnName);
	        	}
	        	
	        	if(attrs.containsKey(DISPLAY_ATTRIBUTE_NAME)) {
	        		displayFieldName = columnName;
	        	}
	        }
	        
	        if(columnSearchByList.isEmpty()) {
	        	columnSearchByList.add('Name');
	        }
	        
	        cacheFieldsDescriptors(objectTypeName,columnNamesList);
	        Map<String,String> fieldLabels = fieldLabelsCache.get(objectTypeName);
	        
	        for(String columnName : columnNamesList) {
	        	Map<String, String> attrs = columnAttrs.get(columnName);
	        	
	        	if(attrs.containsKey(LABEL_ATTRIBUTE_NAME)) {
	        		columnLabelsList.add(attrs.get(LABEL_ATTRIBUTE_NAME));
	        	} else if(fieldLabels.containsKey(columnName)) {
	        		columnLabelsList.add(fieldLabels.get(columnName));
	        	} else {
	        		columnLabelsList.add(columnName);
	        	}
	        }
	        
	        columnNames = String.join(columnNamesList,',');
	        columnLabels = String.join(columnLabelsList,',');
	        searchFields = String.join(columnSearchByList,',');
	        
	        if(String.isBlank(displayFieldName)) {
	        	displayFieldName = 'Name';
	        }
		}
		
		if(virtualRecords!=null && virtualRecordsInJSON==null) {
			virtualRecordsInJSON = JSON.serialize(virtualRecords);
		}
	}
	
	private static void cacheFieldsDescriptors(String objectTypeName, List<String> columnNames) {
		if(fieldLabelsCache == null) {
			fieldLabelsCache = new Map<String,Map<String,String>>();
		}
		
		if(!fieldLabelsCache.containsKey(objectTypeName)) {
			fieldLabelsCache.put(objectTypeName, new Map<String,String>());
		}
		Map<String,String> fieldLabels = fieldLabelsCache.get(objectTypeName);
		Set<String> cachedColumns = fieldLabels.keySet();
		
		Set<String> notCachedColumns = new Set<String>();
		for(String columnName : columnNames) {
	        if(!columnName.contains('.') && !cachedColumns.contains(columnName)) {
	        	notCachedColumns.add(columnName);
	        }
		}
		
		if(!notCachedColumns.isEmpty()) {
			Map<String,Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();  
	        Schema.SObjectType sObjectType = globalDescribeMap.get(objectTypeName);  
	        Schema.DescribeSObjectResult result = sObjectType.getDescribe();  
	        Map<String,Schema.SObjectField> sObjectFieldMap = result.fields.getMap();
	        
	        for(String columnName : notCachedColumns) {
	        	if(sObjectFieldMap.containsKey(columnName)) {
	        		fieldLabels.put(columnName, sObjectFieldMap.get(columnName).getDescribe().getLabel());
	        	}
	        }
		}
	}
	
	private Object getValueForField(SObject sObj, String columnName) {
        Object result = null;
        	
        if(columnName.contains('.')) {
        	Map<String,Object> objAttrs = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(sObj));
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
         	result = sObj.get(columnName);
        }
        
        return result;
	}
	
	public void setColumns(String newValue) {
		columns = newValue;
		initController();
	}
}