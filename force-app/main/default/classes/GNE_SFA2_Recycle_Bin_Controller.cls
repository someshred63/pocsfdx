/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-11-26
*  Description: This is a controller class for GNE_SFA2_Recycle_Bin
*  
*  Modification History
*  Date        Name        Description
*           Lukasz Bieniawski   List is filtered by master-detail relationships 
                                (hide child object if its master is in recycle bin also)                                
*************************************************************/

public with sharing class GNE_SFA2_Recycle_Bin_Controller {
    public List<RecycleBinItem> recycleBinItems;
    public String sortColumn {get; set;}
    public String sortDirection {get; set;}
    
    private String oldSortColumn {get; set;}
    private List<SFA2_Search_Settings_gne__c> searchSettings;
    private static Integer PAGE_SIZE; 
    private CustomSetController setController;
    private String whereExpr = ' WHERE IsDeleted = true AND LastModifiedDate >= LAST_N_DAYS:15 ';
    
    public GNE_SFA2_Recycle_Bin_Controller() {}
    
    public PageReference init(){
        PageReference result = null;
                
        try{            
            initSortingSettings();
            loadConfiguration();
            recycleBinItems = new List<RecycleBinItem>();
                
            setController = new CustomSetController(getDeletedRecords(searchSettings), PAGE_SIZE);            
        }catch(Exception ex){
            System.debug('init error: ' + ex);
            result = GNE_SFA2_Util.redirectToErrorPage('', Apexpages.currentPage().getUrl(), ex.getMessage());                      
        }
        return result;
    }
  
    private void initSortingSettings() {
        sortColumn = 'lastmodifieddate';
        oldSortColumn = sortColumn;
        sortDirection = 'DESC';
    }
  
    private void loadConfiguration() {
        GNE_SFA2_My_Accounts_Setttings__c settings;
        try{
            settings = [ SELECT PageSize_gne__c FROM GNE_SFA2_My_Accounts_Setttings__c LIMIT 1 ];
        }catch(Exception e){
            settings = new GNE_SFA2_My_Accounts_Setttings__c(PageSize_gne__c=50, Privileged_Profiles_gne__c='');
        }
        
        PAGE_SIZE = Integer.valueOf(settings.PageSize_gne__c);
        searchSettings = getSearchSettings();
    }
    
    private List<RecycleBinItem> getDeletedRecords(List<SFA2_Search_Settings_gne__c> searchSettings) {
        Set<String> scopeOfObjects = new Set<String>();         
        for(SFA2_Search_Settings_gne__c searchSetting : searchSettings){            
            if (!scopeOfObjects.contains(searchSetting.Object_gne__c)){
                scopeOfObjects.add(searchSetting.Object_gne__c);
            }                       
        }
        
        // Prepare relations descriptions between deleted objects to check master-detail relationships and hide child objects
        // Restoring master detail relationship is managed by Salesforce
        Set<RelationDescription> listOfRelationDescription = prepareRecycleBinRelationList(scopeOfObjects);
        
        List<sObject> queriedObjects = null;
        String query = null;
        String queryFrom = null;        
        List<RecycleBinItem> result = new List<RecycleBinItem>();
        List<String> whereDependentQueryList = new List<String>();
        
        // These variables are used to avoid governor limit for SOQL queries (50 000)
        Integer rowsLimit = Limits.getLimitQueryRows();
        Integer limitQueries = Limits.getLimitQueries();
        Integer currentQueriesCount = Limits.getQueries();
        Boolean checkQueryCount = (currentQueriesCount + (scopeOfObjects.size() * 2 )) < limitQueries;
        Integer recordsCount = 0;
        System.debug('limitQueries: ' + limitQueries + '; currentQueriesCount: ' + currentQueriesCount 
        	+ '; scopeOfObjects.size: ' + scopeOfObjects.size() + '; checkQueryCount: ' + checkQueryCount
        	+ '; rowsLimit: ' + rowsLimit);
        	
        for(String targetType : scopeOfObjects){        	
            if(targetType == 'Task') {
                query = ' SELECT Subject, LastModifiedDate, LastModifiedById ';
            } else {
                query = ' SELECT Name, LastModifiedDate, LastModifiedById ';
            }
            
            // Loop to include master fields in query and check if they are not deleted
            for (RelationDescription relationDescription : listOfRelationDescription){
                // If object has master relationship, check if master object is not deleted
                if (relationDescription.childObjType == targetType){
                    // To avoid multiple selection (i.e for Task object for WhoId and WhatId fields)
                    if (!query.containsIgnoreCase(relationDescription.masterFieldToSoql)){
                        query += ', ' + relationDescription.masterFieldToSoql;
                        whereDependentQueryList.add(relationDescription.masterFieldIsDeletedToSoql + ' = false');
                    }
                }
            } 
            
            queryFrom = ' FROM ' + targetType + whereExpr
            	+ (whereDependentQueryList.size() > 0 ? (' AND ' + String.join(whereDependentQueryList, ' AND ')) : '')
            	+ ' AND LastModifiedById = \'' + Userinfo.getUserId() + '\''
            	+ ' ORDER BY LastModifiedDate DESC ALL ROWS ';
            query += queryFrom;
            System.debug('query: ' + query);
            
            if (checkQueryCount){
            	recordsCount += Database.countQuery('SELECT Count() ' + queryFrom.remove('ORDER BY LastModifiedDate DESC'));
            	if (recordsCount >= rowsLimit) {
            		Apexpages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Note: Too many rows, results truncated.'));
            		break;
            	}
            }         
            queriedObjects = Database.query(query);
            if (queriedObjects != null && queriedObjects.size() > 0){
            	result.addAll(wrapDeletedRecords(queriedObjects));
	           	queriedObjects.clear();
            }                         
            whereDependentQueryList.clear();            
        }

        if (scopeOfObjects != null){
        	scopeOfObjects.clear();
        }
        if (listOfRelationDescription != null){
        	listOfRelationDescription.clear();
        }
        
        return result;
    }
  
    private Set<RelationDescription> prepareRecycleBinRelationList(Set<String> scopeOfObjects){
        Set<RelationDescription> listOfRelationDescription = new Set<RelationDescription>();
        
        // Buffor variables to avoid getDescribe limit
        Map<String, List<Schema.ChildRelationship>> parentToChildMap = new Map<String, List<Schema.ChildRelationship>>();        
        
        // Variables stored outside of the loop to minimalize heap size
        Map<String, Schema.SObjectField> mapOfFields = null;
        Schema.DescribeFieldResult sfield = null;
        List<Schema.ChildRelationship> childRelationships = null;
        Schema.Describesobjectresult targetObjectDescribe = null;
        String parentObjType = null;
        
        // Foreach objects we are looking for master fields to include in query        
        for(String targetType : scopeOfObjects){
           	targetObjectDescribe = GNE_SFA2_Application_Cache.describeObject(targetType);            		
            mapOfFields = targetObjectDescribe.fields.getMap();
            
            // Check object fields, we are looking for referenced fields
            for (Schema.SObjectField sObjField : mapOfFields.values()){
                  sfield = sObjField.getDescribe();
                  // If field type is reference, if getRelationshipOrder equal 0 it is child
                  if (sfield.isCascadeDelete() && sfield.getRelationshipOrder() == 0 && sfield.getType() == Schema.DisplayType.Reference && String.isNotBlank(sfield.getRelationshipName())){
                        // Foreach referenced objects                 
                        for (Schema.sObjectType parentObj : sfield.getReferenceTo()){
                        	parentObjType = String.valueOf(parentObj);
                            if (!scopeOfObjects.contains(parentObjType)){
                                continue;
                            }
                            // Get child relationships                                                        
                            if (parentToChildMap.containsKey(parentObjType)){
                                childRelationships = parentToChildMap.get(parentObjType); 
                            } else {
                            	// Limit 100 callouts
                                childRelationships = GNE_SFA2_Application_Cache.describeObject(parentObjType).getChildRelationships();
                                parentToChildMap.put(parentObjType, childRelationships);
                            }
                            // We are looking for master-detail relationships
                            for (Schema.ChildRelationship childRelationship : childRelationships){
                                if (childRelationship.getField() == sObjField && childRelationship.isCascadeDelete()){
                                    // If found add new relation description (masterObject, childObject, masterRelationshipName, childMasterKeyFieldName)
                                    RelationDescription relationDescription = new RelationDescription(parentObjType, targetType, sfield.getRelationshipName(), sfield.getName());
                                    listOfRelationDescription.add(relationDescription);
                                    break;
                                }
                            }
                            if (childRelationships != null){
                            	childRelationships.clear();
                            	childRelationships = null;
                            }
                        }                        
                  }
            }
            if (mapOfFields != null){
        		mapOfFields.clear();
        		mapOfFields = null;
        	}
        } 
        
        if (parentToChildMap != null && parentToChildMap.size() > 0){
        	for (List<Schema.ChildRelationship> mapList : parentToChildMap.values()){
        		if (mapList != null){
        			mapList.clear();
        		}        			
        	}
        	parentToChildMap.clear();
        	parentToChildMap = null;
        }
            
        return listOfRelationDescription;
    }
    
    private List<RecycleBinItem> wrapDeletedRecords(List<sObject> recordsToWrap) {
        List<RecycleBinItem> result = new List<RecycleBinItem>();
        for(sObject record : recordsToWrap) {
        	result.add(new RecycleBinItem(record, ((Datetime)record.get('LastModifiedDate')).format()));            
        }
        return result;
    }
  
    private List<SFA2_Search_Settings_gne__c> getSearchSettings(){
       return [ SELECT Id, Object_gne__c FROM SFA2_Search_Settings_gne__c WHERE Application_Name_gne__c = :GNE_SFA2_Application_Cache.userApplicationContext.App_Name_gne__c AND Product_gne__c = :GNE_SFA2_Application_Cache.userApplicationContext.Brand_gne__c 
            AND Role_gne__c = :GNE_SFA2_Application_Cache.userApplicationContext.Role_gne__c ORDER BY Order_gne__c ];
    }
  
    public List<RecycleBinItem> getRecycleBinItems() {
        if (recycleBinItems == null){
            return null;
        }
        
        recycleBinItems.clear();        
        for(Object o : setController.getRecords()) {
            recycleBinItems.add((RecycleBinItem) o);
        }
        
        // do sorting
        SuperSort.sortList(recycleBinItems, sortColumn, sortDirection);
        return recycleBinItems;
    }
        
    public PageReference undeleteRecords() {
        if (recycleBinItems == null){
            return null;
        }
        
        PageReference result = null;       
        Integer count_errors=0;                                   
       	Boolean showErrorMessage=false;        
        String undeleteErrorMessage='&nbsp;&nbsp;The record may have already been undeleted or removed from the Recycle Bin<BR>'+
                                   '&nbsp;&nbsp;The record may have been orphaned by the deletion of the custom object<BR>'+
                                   '&nbsp;&nbsp;You may no longer have access to undelete the record(s)<BR>'+
                                   '&nbsp;&nbsp;A data integrity rule or Apex trigger would fail if the record was undeleted<BR>';		                                          
        
        try{            
            List<sObject> itemsToUndelete = new List<sObject>();
            for(RecycleBinItem deletedItem : recycleBinItems) {
                if(deletedItem.selected) {
                    itemsToUndelete.add(deletedItem.deletedObject);
                }
            }
            
            Database.UndeleteResult[] UDR_Dels = Database.undelete(itemsToUndelete, false);
            if(UDR_Dels != null && UDR_Dels.size() > 0){
            	List<Database.Error> errors = null;
            	String errString = ''; 
            	for(integer i = 0; i < UDR_Dels.size(); i++){
            		errors = UDR_Dels[i].getErrors(); 
            		if(errors != null && errors.size() > 0){
            			for (Database.Error error : errors){
        					errString += error.getMessage() + '; ';        					
        				}   
            			showErrorMessage = true;            			
            			count_errors++;
            		}
            	}
            	System.debug('errString: ' + errString);
          	}
          	
          	if(showErrorMessage){
          		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Unable to undelete '+ count_errors+' of the record(s) because:'+'<br>'+undeleteErrorMessage));
          	}   
                
            // refresh deleted items list
            setController.setObjectList(getDeletedRecords(searchSettings));
        } catch(Exception ex){
            System.debug('undeleteRecords error: ' + ex);
            result = GNE_SFA2_Util.redirectToErrorPage('', Apexpages.currentPage().getUrl(), ex.getMessage());                      
        }       
        return result;
    }
  
    public PageReference changeSorting() {
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
               
        return null;
    }
  
    public Boolean getHasPrevious() {
        if (setController == null){
            return false;
        }
        return setController.hasPrevious();
    }
  
    public Boolean getHasNext() {
        if (setController == null){
            return false;
        }
        return setController.hasNext();
    }
  
    public Integer getPageNumber() {
        if (setController == null){
            return 0;
        }
        return setController.getPageNumber();
    }
  
    public Integer getRecordsCount() {
        if (setController == null){
            return 0;
        }
        return setController.getCurrentPageSize();
    }
  
    public Integer getPageNumbers() {
        if (setController == null){
            return 0;
        }
        return setController.getTotalPageNumbers();
    }
  
    public PageReference nextPage() {
        setController.next();
        return null;
    }
  
    public PageReference previousPage() {
        setController.previous();
        return null;
    }
      
    public class RecycleBinItem implements IReflection {
        public String name { get; private set; }
        public String label { get; private set; }
        public String sObjType { get; private set; }
        public String deletionDate { get; private set; }
        public sObject deletedObject { get; private set; }
        public Boolean selected { get; set; }        
    
        public RecycleBinItem(sObject deletedObject, String deletionDate) {
        	this.deletedObject = deletedObject;
        	this.deletionDate = deletionDate;
        	this.sObjType = String.valueOf(deletedObject.getSObjectType());
        	if(this.sObjType == 'Task') {
        	 	this.name = (String)deletedObject.get('Subject');
            } else {
            	this.name = (String)deletedObject.get('Name');
            }
            this.label = GNE_SFA2_Application_Cache.describeObject(this.sObjType).getLabel();                      
        }
    
        public Object getValue(String fieldName) {
            if(fieldName == 'name') {
                return name;
            } else if(fieldName == 'type') {
                return label;
            } else if(fieldName == 'lastmodifieddate') {
                return deletionDate;
            } else {
                return null;
            }
        }
    }
  
    private class RelationDescription{
        public String masterObjName { get; private set; }
        public String childObjName { get; private set; }
        public String masterObjType { get; private set; }
        public String childObjType { get; private set; }
        public String masterRelationshipName { get; private set; }
        public String masterFieldToSoql { get; private set; }
        public String masterFieldIsDeletedToSoql { get; private set; }
        public String childMasterKeyFieldName { get; private set; }
        
        public RelationDescription(String masterObjType, String childObjType, String masterRelationshipName, String childMasterKeyFieldName){
            this.masterObjName = GNE_SFA2_Application_Cache.describeObject(masterObjType).getName();
            this.childObjName = GNE_SFA2_Application_Cache.describeObject(childObjType).getName();
            this.masterObjType = masterObjType;
            this.childObjType = childObjType;
            this.masterRelationshipName = masterRelationshipName;
            this.masterFieldToSoql = masterRelationshipName + '.Id';
            this.masterFieldIsDeletedToSoql = masterRelationshipName + '.isDeleted';
            this.childMasterKeyFieldName = childMasterKeyFieldName;
        }
    }
}