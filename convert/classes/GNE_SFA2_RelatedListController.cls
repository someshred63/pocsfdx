public with sharing class GNE_SFA2_RelatedListController {
    
    public GNE_SFA2_DynamicVFLoader pageController {get;set;}
    public GNE_SFA2_SortAndPagination_Controller ssc {get; set;}
    public List<String> fieldNames {get; set;}
    public Map<String, String> fieldOfUserReferenceMap {get;set;}
    public Map<String, Boolean> userReferenceHasExist {get;set;}
    public Map<String, String> fieldOfGroupReferenceMap {get;set;}
    public Map<String, Boolean> groupReferenceHasExist {get;set;}
    public Map<String, Boolean> sortableFieldMap {get;set;}
    public Map<String,String> fieldAlignMap {get; set;}
    public Map<String,String> nameLabelMap {get; set;}
    public Id deleteRecordId {get; set;}
    public String sortByField {get; set;}
    public Map<String,String> fieldSortDirectionMap {get; set;}
    public Boolean editEnabledCalc { get; set; }
    public Boolean deleteEnabledCalc { get; set; }
    public String relatedListLabel{get;set;}
    public String urlForNewRecord{get;set;}
    
    //----Variables set from attributes defined in the component----
    public String objectName {get;set;}
    public String fieldsCSV {get; set;}
    public List<String> fieldsList {get; set;}
    public String parentFieldName {get; set;}
    public Id parentFieldId {get; set;}
    public String filter {get; set;}
    public String orderByFieldName {get; set;}
    public String sortDirection {
        get;
        set {
            //Ensure sortDirection attribute has value of 'asc' or 'desc'
            if(String.isNotEmpty(value) && (value.equalsIgnoreCase('asc') || value.equalsIgnoreCase('desc'))){
                sortDirection = value.toLowerCase();
                recordsList = getRecordsLst();
            }else{
                if(String.isEmpty(sortDirection)){
                    sortDirection = 'desc';
                    recordsList = getRecordsLst();
                }
            }
        }
    }
    public Integer pageSize {get; set;}
    public Map<String,String> fieldSetMap{get;set;}
    public Map<String,Boolean> isLinkField{get;set;}
    public Map<String,Boolean> isDynamicLinkField{get;set;}
    public String commandButtonAction{get;set;}
    public String methodName {get;set;}
    public Integer pageNumber = 1;
    public String pageName{get;set;}
    public String userIdToViewLink {get;set;}
    public Boolean editEnabled { get; set; }
    public Boolean deleteEnabled { get; set; }
    public Boolean listRendered { get; set; }
    public List<sObject> recordsList {get; set;}
    
    //sorting related variables
    public Boolean hasNext;
    public Boolean hasPrevious;
    private static Integer DEFAULT_PAGE_SIZE = 10;
    public Boolean maxRecordReached { get; set; }
    
    private Boolean isInitialized = false;
    
    public Integer getPageNumber() {
        return pageNumber;
    }
    
    public PageReference showRelatedList() {
        listRendered = true;
        return null;
    }
    
    private List<sObject> getRecordsLst(){
        if(objectName != null && objectName.contains('(')){
            objectName = objectName.substring(0,objectName.indexOf('('));
        }
        
        editEnabledCalc = !editEnabled && GNE_SFA2_Application_Cache.describeObject(objectName).isUpdateable();
        deleteEnabledCalc = !deleteEnabled && GNE_SFA2_Application_Cache.describeObject(objectName).isDeletable();
          
        String queryString = 'SELECT ';
        
        fieldSetMap = new Map<String, String>();
        isLinkField = new Map<String, Boolean>();
        isDynamicLinkField =  new Map<String, Boolean>();
       
        if(fieldsList == null && fieldsCSV == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'fieldList or fieldsCSV attribute must be defined.'));
            return null;
        }
             
        //Ensure parentFieldId is not null
        if(parentFieldId == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'parentFieldId attribute can not be null'));
            return null;
        }
        
        /*If field CSV was defined use this and also add fields to the fieldNames
        List so they can be used with Visualforce dynamic binding to define coloumns*/
        if(fieldsCSV != null){
            String temp = '';
            for(String f: fieldsCSV.split(',')) {
                List<String> values = f.split('#');
                String field = null;
                if(values.size() >=1){
                    if(temp != '') {
                        temp += ',';
                    }
                    field= values.get(0);
                    temp += field;
                    isLinkField.put(field,false);
                    isDynamicLinkField.put(field,false);
                    if(values.size() == 2) {
                        fieldSetMap.put(field, values.get(1));
                        Integer index = field.indexOf('__r.');
                        if(index >= 0){
                            isDynamicLinkField.put(field,true);
                            String newField = field.subString(0,index+4) + 'Id';
                            fieldSetMap.put(field, newField);
                            if(!fieldsCSV.toLowerCase().contains(newField.toLowerCase())){
                                queryString += newField + ','; 
                            }
                    	}
                    	isLinkField.put(field,true);
                    }
                }
            }
            queryString += temp ;
            fieldNames = temp.split(',');
         }else{
            //Add fields to fieldNames list so it can be used with VF dynamic binding to define coloumns
            fieldNames = fieldsList.clone();
            
            //Loop through list of field names in fieldList and add to query
            for(String fld : fieldsList){
                queryString += fld + ',';
            }
            
            //Remove the very last comma that was added to the end of the field selection part of the query string
            queryString = queryString.substring(0,queryString.length() - 1);
        }
        
        System.debug('*************fieldCSV****>>>'+fieldsCSV);
        
        Map<String,Schema.SObjectField> sObjectFieldMap = GNE_SFA2_Application_Cache.describeObject(objectName).fields.getMap();
        
        // Check If Field Has User or Group Reference
        fieldOfUserReferenceMap = new Map<String, String>();
        userReferenceHasExist = new Map<String, Boolean>();
        fieldOfGroupReferenceMap = new Map<String, String>();
        groupReferenceHasExist = new Map<String, Boolean>();
        sortableFieldMap = new Map<String,Boolean>();        
        
        for(String fieldName : fieldNames) {
            sortableFieldMap.put(fieldName,true);  
            if (fieldName.contains('.')) {
                userReferenceHasExist.put(fieldName, false);
                groupReferenceHasExist.put(fieldName, false);
            } else {
                try {
                    Schema.SObjectField sObjectField = sObjectFieldMap.get(fieldName);
                    Schema.DescribeFieldResult sObjectFieldDescribe = sObjectField.getDescribe();
                    String fieldType = sObjectFieldDescribe.getType().name();
                    sortableFieldMap.put(fieldName, !('CreatedById'.equals(fieldName) || 'LastModifiedById'.equals(fieldName) ||'MULTIPICKLIST'.equals(fieldType) || 'TEXTAREA'.equals(fieldType)));
                    Set<Schema.sObjectType> fieldReference = new Set<Schema.sObjectType>(sObjectFieldDescribe.getReferenceTo());
                    if (fieldReference.size() > 0) {
                        Boolean hasUserReference = fieldReference.contains(User.sobjecttype);
                        Boolean hasGroupReference = fieldReference.contains(Group.sobjecttype);
                        String relationName = sObjectFieldDescribe.getRelationshipName() + '.Name';
                        userReferenceHasExist.put(fieldName, hasUserReference && !hasGroupReference);
                        groupReferenceHasExist.put(fieldName, hasGroupReference);
                        if (hasUserReference && !hasGroupReference){
                            fieldOfUserReferenceMap.put(fieldName, relationName);                           
                            queryString += ',' + relationName;
                        } else if (hasGroupReference){
                            fieldOfGroupReferenceMap.put(fieldName, relationName);                          
                            queryString += ',' + relationName;
                        }
                        fieldReference.clear(); 
                    } else {
                        userReferenceHasExist.put(fieldName, false);
                        groupReferenceHasExist.put(fieldName, false);
                    }                   
                } catch (Exception ex) {
                    system.debug(Logginglevel.ERROR, ex);                       
                }
            }
        }
        
        if (!queryString.contains('CreatedDate')) {
            queryString += ', CreatedDate';
        }
        
        if (!queryString.contains('LastModifiedDate')) {
            queryString += ', LastModifiedDate';
        }
        
        //add from object and parent criteria
        queryString += ' FROM ' + objectName + ' WHERE ' + parentFieldName + ' = \'' + parentFieldId + '\'';
        //Add any addtional filter criteria to query string if it was defined in component
        if (objectName == 'Affiliation_vod__c'){
			filter = GNE_SFA2_Related_List_Controller.applyAffiliationFilter(filter);
		}
        if(filter != null){
            queryString += ' AND ' + filter;
        }
        
        //Add order by field to query if defined in component
        //If sortByField != null then user has clicked a header and sort by this field
        if(sortByField != null){
            String fieldName = sortByField;
            Schema.SObjectField sObjectField = sObjectFieldMap.get(sortByField);
            if(SObjectField != null){
                String fieldType = sObjectField .getDescribe().getType().name();
                System.debug('Field Type:' + fieldType +',' + 'Field Name:' + sortByField);
                if(fieldType.contains('REFERENCE') && fieldName.indexOf('__c')!=-1){
                    if (fieldName!='Case_gne__c'){
                        fieldName =fieldName.substring(0,fieldName.indexOf('__c'))+'__r.Name';
                    }else{
                        fieldName =fieldName.substring(0,fieldName.indexOf('__c'))+'__r.CaseNumber';
                    }
                }
            }
            queryString += ' ORDER BY ' + fieldName;
            queryString += ' ' + fieldSortDirectionMap.get(sortByField);
        }else if(orderByFieldName != null){
            sortByField = orderByFieldName;
            queryString += ' ORDER BY ' + orderByFieldName;
            queryString += ' ' + sortDirection;
            if(fieldSortDirectionMap == null){
                fieldSortDirectionMap = new Map<String,String>();
            }
            fieldSortDirectionMap.put(sortByField,sortDirection);
        }
        
        List<GNE_SFA2_RelatedList_Limit__c> relatedListLimit = null;
        relatedListLimit = GNE_SFA2_RelatedList_Limit__c.getall().values();
        
        if(pageSize == null && relatedListLimit != null && relatedListLimit.size() > 0) {
            pageSize = Integer.valueOf(relatedListLimit[0].Page_Size_gne__c);
        } else if(pageSize == null){
            pageSize = DEFAULT_PAGE_SIZE;
        }
        queryString += ' LIMIT ' + (pageSize + 1) + ' OFFSET ' + ((pageNumber-1)*pageSize);
        
        System.debug('##### Query String === ' + queryString);        
        /*For the fields that will be displayed identify the field type and set styleClass for
        cell alignment. Numbers, Currency, %, etc should align right in table. put in map FieldName -> class name*/
        //Get the meta data info for the fields is the related object
        Map<String, Schema.SObjectField> fieldMap = GNE_SFA2_Application_Cache.describeObject(objectName).fields.getMap();
        
        //For the fields in the related list populate fieldAlignMap map with the name of the correct style class. Also populate name->label map for header display
        fieldAlignMap = new Map<String,String>();
        nameLabelMap = new Map<String,STring>();
        for(String fld : fieldNames){
            String fieldType =''; //fieldMap.get(fld).getDescribe().getType().name();
            if(fieldMap.get(fld) != null){
                fieldType = fieldMap.get(fld).getDescribe().getType().name();
            }
            if(fieldType == 'CURRENCY' || fieldType == 'DOUBLE' || fieldType == 'PERCENT' || fieldType == 'INTEGER'){
                fieldAlignMap.put(fld,'alignRight');
            }else{
                fieldAlignMap.put(fld,'alignLeft');
            }
            
            //Add to name->label map
            String label = '';//fieldMap.get(fld).getDescribe().getLabel();
            if(fieldMap.get(fld)!=null){
                label = fieldMap.get(fld).getDescribe().getLabel();
                if(fld == 'CreatedById') {
                    label = 'Created By';
                } else if(fld == 'LastModifiedById') {
                    label = 'Last Modified By';
                }
                nameLabelMap.put(fld,label);
            }else if(fld.contains('__r')){
                //Added by Kishore to get the related object field label name
                //What with standard relation like Owner.Name?
                
                String apiName,rlFldLabel,parentObjApiName;
                if(fld.indexOf('__r')!=-1){
                    String rlObjName=fld.substring(0,fld.indexOf('__r'))+'__c';
                    if(fld!=null && fld.contains('.')){
                        apiName=fld.substring(fld.indexOf('.')+1,fld.length());
                    }
                    Map<String, Schema.SObjectField> fldObjMap = GNE_SFA2_Application_Cache.describeObject(objectName).fields.getMap();
                    if(fldObjMap!=null && fldObjMap.get(rlObjName)!=null){
                        Schema.DescribeFieldResult fieldDescribe = fldObjMap.get(rlObjName).getDescribe();
                        parentObjApiName=fieldDescribe.getReferenceTo()[0].getDescribe().getName();
                    }
                    
                    Map<String, Schema.SObjectField> prntfldObjMap = GNE_SFA2_Application_Cache.describeObject(parentObjApiName).fields.getMap();
                    if(apiName!=null && prntfldObjMap.get(apiName)!=null){
                        rlFldLabel=prntfldObjMap.get(apiName).getDescribe().getLabel();
                    }else{
                        rlFldLabel=fld;
                    }
                    nameLabelMap.put(fld,rlFldLabel);
                } else{
                    nameLabelMap.put(fld,fld);
                }
            } else {
                nameLabelMap.put(fld,fld);
            }
        }
        
        List<sObject> queryResult = Database.query(queryString);
        if(queryResult.size() > pageSize) {
            maxRecordReached = false;
        } else {
            maxRecordReached = true;
        }
        List<sObject> result = new List<sObject>();
        for(Integer i = 0; i < queryResult.size(); i++) {
            if(i == pageSize) {
                break;
            }
            result.add(queryResult[i]);
        }
       return result;
    }
    
    public Boolean getHasPrevious() {
        return (pageNumber > 1);
    }
    
    public Boolean getHasNext() {
        return !maxRecordReached;
    }
    
    public PageReference next() {
        pageNumber++;
        recordsList = getRecordsLst();
        return null;
    }
    
    public PageReference previous() {
        pageNumber--;
        recordsList = getRecordsLst();
        return null;
    }
    
    public Boolean getShowNewButton(){
        if(objectName != null && objectName.contains('(')){
            objectName = objectName.substring(0,objectName.indexOf('('));
        }
        return GNE_SFA2_Application_Cache.describeObject(objectName).isCreateable();
    }
    
    public String getObjectLabel(){
        if(objectName != null && objectName.contains('(')){
            objectName = objectName.substring(0,objectName.indexOf('('));
        }
        return GNE_SFA2_Application_Cache.describeObject(objectName).Label;
    }
    
    public PageReference sort(){
        pageNumber = 1;
        if(fieldSortDirectionMap == null){
            fieldSortDirectionMap = new Map<String,String>();
        }
        if(fieldSortDirectionMap.get(sortByField) == null || fieldSortDirectionMap.get(sortByField) == 'desc' ){
            fieldSortDirectionMap.put(sortByField,'asc');
        }else{
        	fieldSortDirectionMap.put(sortByField,'desc');
    	}
        recordsList = getRecordsLst();
        return null;
    }
    
    public PageReference deleteRecord(){
        String interactionStatus = 'Planned';
        try{
        	sObject objToDelete = Database.query('SELECT Id FROM ' + objectName + ' WHERE Id=\'' + deleteRecordId + '\' LIMIT 1');                    
            if(objectName.contains('Call2_vod__c')){
                List<Call2_vod__c> getStatus = [SELECT Interaction_Status_gne__c FROM Call2_vod__c WHERE Id=: deleteRecordId];
                if (getStatus.size()>0){
                    interactionStatus = getStatus[0].Interaction_Status_gne__c;
                }                      
            }
            delete objToDelete;
        } catch (Exception ex){
            if(objectName.contains('Call2_vod__c') && interactionStatus == 'Completed'){
                return GNE_SFA2_Util.redirectToErrorPage('You cannot delete a completed interaction!', Apexpages.currentPage().getUrl(), ex.getMessage());
            }
        	return GNE_SFA2_Util.redirectToAccessDeniedPage();           
        }
        recordsList = getRecordsLst();
        return null;
    }
    
    public class RelatedListButton {
        public String action {get;set;}
        public String label {get;set;}
        
        public RelatedListButton(String action, String label) {
            this.action = action;
            this.label = label;
        }
    }
    
    public PageReference overrideUserViewLink() {
        PageReference pageref = new PageReference('/apex/GNE_SFA2_User_Layout?Id=' + userIdToViewLink);
        pageref.setredirect(true);
        return pageref;
    }
    
    public Pagereference callActionMethod(){
        Pagereference pageref = null;
        if(pageController!= null){
            pageref= pageController.callMethod(methodName);
        }          
        recordsList = getRecordsLst();
        return pageref;
    }
    
    public String getActionObjectName() {
        String result = '';
        if(objectName != null && objectName.contains('(')){
            result = objectName.substringBefore('(');
        } else {
            result = objectName;
        }
        return result;
    }
    
    public PageReference viewAllClick(){
        PageReference pageref = new PageReference('/apex/GNE_SFA2_ViewAll?parentObjectName='+pageController.myObjectType+
                                                    '&parentRecordType='+pageController.recordTypeName+
                                                    '&viewObjectName='+objectName+
                                                    '&viewParentId='+parentFieldId+
                                                    '&viewPageSize=50'+
                                                    '&viewParentFieldName='+parentFieldName+
                                                    '&viewOrderByFieldName='+orderByFieldName+
                                                    '&viewSortDirection='+sortDirection+
                                                    '&viewHideButtons=true'+
                                                    '&viewHideEditLink='+ !editEnabledCalc+
                                                    '&viewHideDeleteLink='+ !deleteEnabledCalc+
                                                    '&viewRelatedListLabel='+relatedListLabel+
                                                    '&viewUrlForNewRecord='+EncodingUtil.urlEncode(urlForNewRecord, 'UTF-8'));
        pageref.setredirect(true);
        return pageref;
    }
}