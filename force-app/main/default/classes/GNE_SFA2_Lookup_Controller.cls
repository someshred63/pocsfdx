public with sharing class GNE_SFA2_Lookup_Controller {
    
    private List<String> defApiFields = null;
    private List<String> defLabelFields = null;
    private List<ColumnDescription> displayColumns = null;
    private List<String> orderFieldsList = null;
    private List<String> searchFieldsList = null;
    private List<String> queryCols = null;
    private List<String> recordIdsList = null;
    private List<SObject> virtualRecords = null;
    private Transient Component.Apex.PageBlockTable recordTable = null;
    private List<SObject> recordList = null;
    private Sorter sorter = new Sorter();
    private Boolean sortingRequired = false;
    private Boolean ieBrowser = false;
    private String sortDirection = 'ASC';
    private Integer iMaxSearch = 200;
    private Integer ieSearchLimit = 200;
    private Boolean isCanadaUser {get; set;}
    
    public String sortField {
        get;
        set {
            if (sortField == value)
                sortDirection = (sortDirection == 'ASC') ? 'DESC' : 'ASC';
            else {
                sortDirection = 'ASC';
                sortField = value;
            }
        }
    }
    
    public String sErrMessage { get; set; }
    public String searchValue { get; set; }
    public String objectType {get; set;}
    public String browserType {get; set;}
    public String columnFields {get; set;}
    public String columnLabels {get; set;}
    public String whereExpr {get; set;}
    public String recordIds {get; set;}
    public String searchFields {get; set;}
    public String displayField {get; set;}
    public String orderFields {get; set;}
    public String virtualRecordsInJSON {get; set;}
    public Boolean searchWithoutSharings {get; set;}
    public String openerId {get; set;}
    
    public GNE_SFA2_Lookup_Controller() {
        // Creating one list of all displayable columns 
        displayColumns = new List<ColumnDescription>();
        //Creating one list of all columns to query
        queryCols = new List<string>();
        this.isCanadaUser = GNE_SFA2_Util.isCanadaUser();
    }
    
    public PageReference initLookupController() {
    	displayColumns.clear();
        queryCols.clear();
        sortingRequired = false;
        sortDirection = 'ASC';
        
        sErrMessage = '';
        ieBrowser = browserType == 'IE';
        
        String[] columns = columnFields!=null ? columnFields.split(',') : new String[]{'Name'};
        defApiFields = new List<string>();
        for (String val : columns){
            defApiFields.add(val);
        }
        
        String[] labels = columnLabels!=null ? columnLabels.split(',') : new String[]{'Name'};
        defLabelFields = new List<string>();
        for (String val : labels){
            defLabelFields.add(val);
        }
        
        String[] searchFieldsParam = searchFields!=null ? searchFields.split(',') : new String[]{'Name'};
        searchFieldsList = new List<string>();
        for (String val : searchFieldsParam){
            searchFieldsList.add(val);
        }
        
        String[] orderFieldsParam = orderFields!=null ? orderFields.split(',') : new String[]{'Name asc'};
        orderFieldsList = new List<string>();
        for (String val : orderFieldsParam){
            orderFieldsList.add(val);
        }
        
        String[] recordIdsParam = String.isNotBlank(recordIds) ? recordIds.split(',') : new String[]{};
        recordIdsList = new List<string>();
        for (String val : recordIdsParam){
            recordIdsList.add(val);
        }
    
        // Get from user defined cols
        if (defApiFields != null){
            Integer counter = 0;
            for (String fieldName : defApiFields){
                if (!containsValue(queryCols, fieldName)){
                    queryCols.add(fieldName);
                }
                ColumnDescription cd = new ColumnDescription();
                cd.ApiName = fieldName;
                cd.LabelName = defLabelFields[counter];
                displayColumns.add(cd);
                counter++;
            }
        }
        
        if (displayColumns.size() > 0)
            sortField = displayColumns[0].LabelName;
        
        if(String.isNotBlank(virtualRecordsInJSON)) {
            Type recType = Type.forName(objectType);
            virtualRecords = (List<SObject>)JSON.deserialize(virtualRecordsInJSON, Type.forName('List<' + objectType + '>'));
        } else {
            virtualRecords = new List<SObject>();
        }
        
        return null;
    }
    
    public List<SObject> getRecords() {
        List<SObject> result;
        if (!sortingRequired) {             
            result = lookupRecords();
        } else {
            result = recordList;
        }
        return result;
    }       
            
    public Component.Apex.PageBlockTable getRecordTable(){
        recordTable = new Component.Apex.PageBlockTable(var = 'rec');
        recordTable.id = 'table';
        recordTable.expressions.value = '{!records}';
            
        Integer counter = 0;
        for (ColumnDescription colDesc : displayColumns) {
            String expVal = '{!rec.' + colDesc.ApiName + '}';
                                        
            Component.Apex.Column column = new Component.Apex.Column();
            
            Component.Apex.CommandLink headerLink = new Component.Apex.CommandLink();
            headerLink.value = colDesc.LabelName;
            if (sortField == colDesc.ApiName){  
                if (sortDirection == 'ASC'){
                    headerLink.value += '?';
                } else {
                    headerLink.value += '?';
                }
            }   
                            
            headerLink.onclick = 'sort(\'' + colDesc.ApiName + '\'); return false;';                
            column.facets.header = headerLink;              
                        
            if (counter == 0){
                Component.Apex.OutputText rowText = new Component.Apex.OutputText();
                rowText.expressions.value = '{!rec.' + displayField + '}';
                
                Component.Apex.OutputLink rowLink = new Component.Apex.OutputLink();
                rowLink.expressions.value = '{!IF(ISBLANK(rec.Id),\'/#\',rec.Id)}';
                rowLink.onclick = 'return returnDataValue(this);';
                rowLink.styleClass = 'rowId-link';
                rowLink.childComponents.add(rowText);
                column.childComponents.add(rowLink);
            } else {
                Component.Apex.OutputText rowLink = new Component.Apex.OutputText();
                rowLink.expressions.value = expVal;
                column.childComponents.add(rowLink);
            }
            
            recordTable.childComponents.add(column);
            counter++;
        }       
        return recordTable;    
    }
    
    private List<SObject> lookupRecords() {
        sortingRequired = false;
        sErrMessage = '';
        integer size = 0;
        
        try {   
            List<String> qWhereExpr = String.isNotBlank(whereExpr) ? new List<String>{whereExpr} : new List<String>();
            
            String srchValue = getSearchString();
            if (String.isNotBlank(srchValue))   {
                List<String> fieldExprs = new List<String>();
                for (String searchField : searchFieldsList) {
                    fieldExprs.add(searchField + ' like \'%' + srchValue + '%\'');
                }
                qWhereExpr.add('(' + String.join(fieldExprs,' OR ') + ')'); 
            }
            
            if(!recordIdsList.isEmpty()) {
                qWhereExpr.add('Id IN :recordIdsList'); 
            }

            if(objectType == 'User') {
                String openerId = getOpenerId() != null ? getOpenerId() : '';
                if(this.isCanadaUser && openerId.contains('Primary_Point_Of_Contact_gne__c')) {
                    qWhereExpr.add('IsActive = true AND Profile_Name_gne__c IN ' +
                            '(\'RCanada-SFA-Manager\', \'RCanada-SFA-TS\', \'RCanada-SFA-RAMA\', \'RCanada-SFA-Ops\')');
                } else {
                    qWhereExpr.add('IsActive = true AND Profile_Name_gne__c != \'GNE-INFREQUENT-USER\'');
                }
            }
            
            String query = 'SELECT ' + String.join(queryCols, ',')
                        + ' FROM ' + objectType
                        + (!qWhereExpr.isEmpty() ? (' WHERE ' + String.join(qWhereExpr,' AND ')) : '')
                        + ' ORDER BY ' + String.join(orderFieldsList,',')
                        + ' LIMIT ' + (ieBrowser ? ieSearchLimit : iMaxSearch);


            // Matching virtual records will be at the beginning of the list
            recordList = getMatchingVirtualRecords();
            
            System.debug('Query: ' + query);
            if(searchWithoutSharings) {
                recordList.addAll(GNE_SFA2_Util.getDbWithoutSharingExecutor().executeQuery(query));                 
            } else {
                recordList.addAll(Database.query(query));
            }
            
            if(recordList != null && recordList.size() > 0) {               
                Map<Id, SObject> mapRecord = new Map<Id, SObject>();
                for(SObject sObj : recordList) {
                    mapRecord.put(sObj.id, sObj);                   
                }
                               
                List<SObject> recordListClone = recordList.clone();     
                recordList.clear();             
                size=0;
                
                if(recordListClone.size() <= (ieBrowser ? ieSearchLimit : iMaxSearch)) {
                    size = recordListClone.size();
                } else {
                    size = ieBrowser ? ieSearchLimit - 1 : iMaxSearch - 1;
                }
                
                for(integer i = 0; i < size; i++) {
                    recordList.add(recordListClone[i]);
                }
                       
                if (recordListClone != null && recordListClone.size() > (ieBrowser ? ieSearchLimit : iMaxSearch)) {
                    sErrMessage='The search returned more than the maximum number of rows (' + String.valueOf(ieBrowser ? ieSearchLimit : iMaxSearch) + '). Please refine your search criteria.';
                }          
            }
        }
        catch(exception e) {
        	sErrMessage=e.getMessage();
        }
        return recordList; 
   }
   
   private List<SObject> getMatchingVirtualRecords() {
        List<SObject> vRecs = null;
        String srchValue = getSearchString();
        
        if(String.isNotBlank(srchValue)) {
            vRecs = new List<SObject>();
            for(SObject obj : virtualRecords) {
                for (String searchField : searchFieldsList) {
                    Object fieldValueObj = obj.get(searchField);
                    String fieldValue = fieldValueObj!=null ? String.valueOf(fieldValueObj) : '';
                    if(fieldValue.containsIgnoreCase(srchValue)) {
                        vRecs.add(obj);
                        break;
                    }
                }
            }
        } else {
            vRecs = virtualRecords.clone();
        }
        return vRecs;
   }
   
   private String getSearchString() {
        String srchValue = null;
            
        if (String.isNotBlank(searchValue)) {
            srchValue = searchValue.trim();
                
            if(srchValue.startsWith('*')) {
                srchValue = srchValue.substring(1);
            }
            if(srchValue.endsWith('*')) {
                srchValue = srchValue.substring(0,srchValue.length()-1);
            }
        }
        return srchValue;
   }

   private String getOpenerId() {
       String tmpOpenerId = null;
       if(String.isNotBlank(openerId)) {
           tmpOpenerId = openerId;
       }
       return tmpOpenerId;
   }

   public void runSearch() {        
        sortingRequired = false;
        sErrMessage = '';
    }
     
   public Pagereference rerunSearch() {
       sErrMessage='';
       return null;
   }
   
   public void doSort() {
        if (recordList != null && recordList.size() > 1){
            recordList = sorter.getSortedList(recordList, sortField, sortDirection == 'ASC');
        }
        sortingRequired = true;
   }
    
   private Boolean containsValue(List<string> listOfValues, string value){
        Boolean result = false;     
        for(String val : listOfValues){
            if (val == value){
                result = true;
                break;
            }
        }
        return result;
   }
   
   // CLASSES   
   private class ColumnDescription{
        public String ApiName { get; set; }
        public String LabelName { get; set; }
        public Double Width { get; set; }
        
        public ColumnDescription(){}
        public ColumnDescription(String fieldName, String label){
            ApiName = fieldName;
            LabelName = label;
        }       
    }
   
   private class Sorter {
        private Map<String, Integer> listPosition = null;    // <FieldName, <FieldValues>>
        private Map<String, List<String>> sortedFieldValuesPerFieldName = null;     // <FieldName, <FieldValue, <IDs>>>
        private Map<String, Map<String, List<String>>> sObjectIDsPerFieldNames = null;
        private List<sObject> originalList = null;
    
        public Sorter() {}
    
        public List<sObject> getSortedList(List<sObject> originalList, String fieldName, Boolean ascending) {
            this.originalList = originalList;
            sortedFieldValuesPerFieldName = null;
            return getSortedList(fieldName, ascending);
        }
        
        private List<sObject> getSortedList(String fieldName, Boolean ascending) {          
            fieldName = fieldName.toUpperCase();
            return makeSortedList(fieldName, ascending);
        }
        
        private List<sObject> makeSortedList(String fieldName, Boolean ascending) {
            Integer position;
            List<String> sObjectIDs = null;
            List<String> valuesForFieldList = null;
            InitializeFieldName(fieldName);        // Get a list of the same type as the "originalList"
            List<sObject> outputList = originalList.clone();
            outputList.clear();        // Get a list of sorted values
            valuesForFieldList = sortedFieldValuesPerFieldName.get(fieldName);
        
            // for each sorted value
            for (String fieldValue : valuesForFieldList) {
                // Get lisft of IDs
                sObjectIDs = sObjectIDsPerFieldNames.get(fieldName).get(fieldValue);
            
                // for each ID
                for (String ID : sObjectIDs) {
                    // Get position in originalList
                    position = listPosition.get(ID);                // Add each sObject to the list.
                    if ((ascending) || (outputList.size()==0)) {
                        outputList.add(originalList[position]);
                    } else {
                        outputList.add(0, originalList[position]);
                    }
                }
            }   
            return outputList;
        }
    
        private void InitializeFieldName(String fieldName) {
            String sObjectID;
            Integer position;
            String fieldValue;
            List<String> sObjectIDs = null;
            Set<String> valuesForFieldSet = null;    // Sets automatically omit duplicate values 
            List<String> valuesForFieldList = null;
            Map<String, List<String>> sObjectIDsPerFieldValues = null;
        
            // Make sortedFieldValuesPerFieldName
            if (sortedFieldValuesPerFieldName == null) {
                listPosition = new Map<String, Integer>();
                sortedFieldValuesPerFieldName = new Map<String, List<String>>();
                sObjectIDsPerFieldNames = new Map<String, Map<String, List<String>>>();
            }
        
            // Get (or create) map of sObjectIDsPerFieldValues
            sObjectIDsPerFieldValues = sObjectIDsPerFieldNames.get(fieldName);
            if (sObjectIDsPerFieldValues == null) {
                sObjectIDsPerFieldValues = new Map<String, List<String>>();
                sObjectIDsPerFieldNames.put(fieldName, sObjectIDsPerFieldValues);
            }
        
            if (!sortedFieldValuesPerFieldName.keySet().contains(fieldName)) {
                // Objects need to be initialized
                position = 0;
                valuesForFieldSet = new Set<String>();
                listPosition = new Map<String, Integer>();
            
                for (sObject sObj : originalList) {
                    sObjectID = sObj.ID;
                    fieldValue = getValue(sObj, fieldName);
                
                    // Add position to list
                    listPosition.put(sObjectID, position++);
                
                    // Add the value to the set (sets rather than lists to prevent duplicates)
                    valuesForFieldSet.add(fieldValue);
                
                    // Get (or create) map of sObjectIDs
                    sObjectIDs = sObjectIDsPerFieldValues.get(fieldValue);
                    if (sObjectIDs == null) {
                        sObjectIDs = new List<String>();
                        sObjectIDsPerFieldValues.put(fieldValue, sObjectIDs);
                    }
                
                    // Add ID to sObjectIDs
                    sObjectIDs.add(sObjectID);
                }
            
                // Sort set items (Need to convert to list)
                valuesForFieldList = new List<String>();
                valuesForFieldList.addAll(valuesForFieldSet);
                valuesForFieldList.sort();
            
                // Now add it to the map.
                sortedFieldValuesPerFieldName.put(fieldName, valuesForFieldList);
            }
        }
    
        private String getValue(sObject sObj, String fieldName) {
            // This returns the sObject desired in case the fieldName refers to a linked object.
            Integer pieceCount;
            String[] fieldNamePieces;
        
            fieldNamePieces = fieldName.split('\\.');           
            pieceCount = fieldNamePieces.size();            
            for (Integer i = 0; i < (pieceCount-1); i++) {  
                sObj = sObj.getSObject(fieldNamePieces[i]);
                if (sObj == null)
                    break;        
            }
            
            if (sObj != null){
                object resultFromObject = sObj.get(fieldNamePieces[pieceCount-1]);
                String result = resultFromObject != null ? String.valueOf(resultFromObject) : '';           
                return result;
            } else {
                return '';
            }
        }
    }   
}