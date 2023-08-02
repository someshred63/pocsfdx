/************************************************************
*  @author: Jakub Lewandowski, Roche
*  Date: 2012-11-19
*  This is a Search page controller
*    
*  Modification History
*  Date         Name             Description
* 08.05.2013  Lukasz Bieniawski  Handle User references, object and field permissions, new classes: ViewObjectDescribe and ViewColumnDescribe
*************************************************************/

public with sharing class GNE_SFA2_Search_Controller {
    public Map<String, List<ViewColumnDescribe>> viewColumnsMap {get; set;}
    public Map<String, List<sObject>> sObjectsMap {get; set;}
    public List<ViewObjectDescribe> objectDescribes {get; set;}
    public Map<String, String> sectionHeadersMap {get; set;}
    public String initialSearchValue {get; set;}
    private static final Set<String>largeCollections = new Set<String>{'Account', 'Contact', 'Task', 'Call2_vod__c', 'TSF_vod__c', 'Address_vod__c', 'Survey_gne__c', 'Affiliation_vod__c', 'Medical_Event_vod__c', 'Change_Request_gne__c', 'Medical_Communication_gne__c', 'Referral_Assignment_gne__c', 'Event_Attendee_vod__c'};
    
    public GNE_SFA2_Search_Controller(){
        objectDescribes = new List<ViewObjectDescribe>();
        List<SFA2_Search_Settings_gne__c> searchSettings = getSearchSettings(GNE_SFA2_Application_Cache.userApplicationContext);
        sObjectsMap = getsObjectsMap(buildListOfSearchQueries(searchSettings), searchSettings);
        sectionHeadersMap = getSectionHeadersMap(searchSettings);            
    }
    
    public Boolean getResultsFound(){
        return !sObjectsMap.isEmpty();
    }
  
  	@testVisible
    private List<SFA2_Search_Settings_gne__c> getSearchSettings(GNE_SFA2_User_App_Context_gne__c userApplicationContext){
        return [SELECT Id, Object_gne__c, Fields_gne__c, Header_Label_gne__c, Filter_gne__c, Field_Header_gne__c
            FROM SFA2_Search_Settings_gne__c 
            WHERE Product_gne__c = :userApplicationContext.Brand_gne__c 
            AND Role_gne__c = :userApplicationContext.Role_gne__c 
            AND Application_Name_gne__c = :userApplicationContext.App_Name_gne__c
            ORDER BY Order_gne__c];
    }
    
  	@testVisible
    private List<List<SObject>> getRecordsBySearchCriteria(List<String> searchQueries){
        List<List<SObject>> results = new List<List<SObject>>();
        for(String searchQuery : searchQueries){
            system.debug('searchQuery: '+searchQuery);
            for(List<SObject> SObjectList : search.query(searchQuery)){
                results.add(SObjectList);
            }
        }
        return results;
    }
  
    //Generate the list of SOSL queries
    @testVisible
    private List<String> buildListOfSearchQueries(List<SFA2_Search_Settings_gne__c> searchSettings){
        String searchValue = System.currentPageReference().getParameters().get('searchString');
        initialSearchValue = searchValue;
        String searchValueReplaceString = '_###_';
        
        searchValue = searchValue.replace('\\', '\\\\');
        searchValue = searchValue.replace('\'', '\\\'');
        searchValue = searchValue.replace('\\\\?', '?');
        searchValue = searchValue.replace('\\\\-', '-');
        
        List<String> searchQueries = new List<String>();
        
        viewColumnsMap = new Map<String, List<ViewColumnDescribe>>();
        
        String searchQuery = 'FIND \''+searchValueReplaceString+'*\' IN ALL FIELDS RETURNING ';
        Boolean addSearchQuery = false;
            
        for(SFA2_Search_Settings_gne__c searchSetting : searchSettings){
            if(largeCollections.contains(searchSetting.Object_gne__c)){
                String singleSearchQuery = 'FIND \''+searchValueReplaceString+'*\' IN ALL FIELDS RETURNING ';
                singleSearchQuery = buildSearchQuery(singleSearchQuery, searchSetting);
                singleSearchQuery = singleSearchQuery.removeEnd(', ').replaceAll('\\|',' LIMIT 25)');
                singleSearchQuery = singleSearchQuery.replace(searchValueReplaceString, searchValue);
                searchQueries.add(singleSearchQuery);
            }else{
                addSearchQuery = true;
                searchQuery = buildSearchQuery(searchQuery, searchSetting);
            }
        }
        if(addSearchQuery){              
            searchQuery = searchQuery.removeEnd(', ').replaceAll('\\|',' LIMIT 25)');
            searchQuery = searchQuery.replace(searchValueReplaceString, searchValue);
            searchQueries.add(searchQuery);
        }
        system.debug('searchQueries: '+searchQueries);
        return searchQueries;
    }
    
    private String buildSearchQuery(String searchQuery, SFA2_Search_Settings_gne__c searchSetting){
        Schema.DescribeSObjectResult sObjectDescribe = GNE_SFA2_Application_Cache.describeObject(searchSetting.Object_gne__c);
        Map<String, Schema.SObjectField> sObjectFieldMap = sObjectDescribe.fields.getMap();
        Set<String> columns = new Set<String>();
        columns.addAll(searchSetting.Fields_gne__c.split(';'));         
        List<ViewColumnDescribe> viewColumns = new List<ViewColumnDescribe>();            
        
        Boolean containsId = false;
        Boolean containsIsPersonAccount = false;
        
        searchQuery += searchSetting.Object_gne__c;
        searchQuery += '(' + String.join(new List<String> ( columns ), ', ') + '|';
        
        // check if columns have id and if not, add it. Needed to render link for object name column
        for(String column : columns){
            if(column.equalsIgnoreCase('Id')){
                containsId = true;
            }
            if(column.equalsIgnoreCase('IsPersonAccount') && searchSetting.Object_gne__c == 'Account'){
                containsIsPersonAccount = true;
            }
            // Build viewColumns
            Schema.SObjectField sObjectField = sObjectFieldMap.get(column);
            ViewColumnDescribe viewColumn = new ViewColumnDescribe(sObjectField.getDescribe());
                       
            if ((viewColumn.hasUserReference || viewColumn.hasGroupReference) && !columns.contains(viewColumn.displayName)){
                searchQuery = searchQuery.removeEnd('|');
                searchQuery += ', ' + viewColumn.displayName + '|';
            }                          
            viewColumns.add(viewColumn);
        }

        if(!containsId){
            searchQuery = searchQuery.removeEnd('|');
            searchQuery += ', Id|';
        }
        if(!containsIsPersonAccount && searchSetting.Object_gne__c == 'Account'){
            searchQuery = searchQuery.removeEnd('|');
            searchQuery += ', IsPersonAccount|';
        }
        
        if (String.isNotBlank(searchSetting.Filter_gne__c)) {
            searchQuery = searchQuery.removeEnd('|');
            searchQuery += ' WHERE ' + searchSetting.Filter_gne__c + '|';
        }

        searchQuery += ', ';
        updateViewColumnLabels(viewColumns, searchSetting); 
        viewColumnsMap.put(searchSetting.Object_gne__c, viewColumns);
        return searchQuery;
    }
    
	@testVisible 
    private Map<String, List<sObject>> getsObjectsMap(List<String> searchQueries, List<SFA2_Search_Settings_gne__c> searchSettings){
        List<List<sObject>> searchResults = getRecordsBySearchCriteria(searchQueries);
        Map<String, List<sObject>> sObjectsMap = new Map<String, List<sObject>>();
        Map<String, ViewObjectDescribe> unorderedObjectDescribes = new Map<String, ViewObjectDescribe>();
        
        for(List<sObject>searchResult : searchResults){
            if(searchResult.size() > 0){
                Schema.Describesobjectresult objectDescribe = GNE_SFA2_Application_Cache.describeObject(String.valueOf(searchResult[0].getsObjectType()));
                sObjectsMap.put(objectDescribe.getName(), searchResult);
                unorderedObjectDescribes.put(objectDescribe.getName(), new ViewObjectDescribe(objectDescribe));
            }
        }
        for(SFA2_Search_Settings_gne__c searchSetting : searchSettings){
            if(unorderedObjectDescribes.containsKey(searchSetting.Object_gne__c)){
                objectDescribes.add(unorderedObjectDescribes.get(searchSetting.Object_gne__c));
            }
        }
        return sObjectsMap;
    }
     
	@testVisible     
    private Map<String, String> getSectionHeadersMap(List<SFA2_Search_Settings_gne__c> searchSettings){
        Map<String, String> sectionHeadersMap = new Map<String, String>();
        for(SFA2_Search_Settings_gne__c searchSetting : searchSettings){
            sectionHeadersMap.put(searchSetting.Object_gne__c, searchSetting.Header_Label_gne__c);
        }
        return sectionHeadersMap;
    }

    //update column label on the basis of the Field_Header_gne__c field
    //Format of the Field_Header_gne__c is:
    //field_name1=new label 1;field_name2=new label 2;
    @testVisible 
    private void updateViewColumnLabels(List<ViewColumnDescribe> viewDescList, SFA2_Search_Settings_gne__c searchSetting) {
        Map<String, String> columnLabels = new Map<String, String>();
        if (String.isNotBlank(searchSetting.Field_Header_gne__c)) {
            Set<String> headers = new Set<String>();
            headers.addAll(searchSetting.Field_Header_gne__c.split(';'));    
            for (String h : headers) {
                try {
                    columnLabels.put(h.split('=')[0].trim(), h.split('=')[1].trim());
                } catch (Exception e) {
                    //do nothing
                }
            }
        }    
        for (String key : columnLabels.keySet()) {
            for (ViewColumnDescribe viewDesc : viewDescList) {
                if (key == viewDesc.name) {
                    viewDesc.label = columnLabels.get(key);                    
                }
            }
        }        
    }   

    class ViewObjectDescribe{
        public String name { get; private set; }
        public Boolean isAccessible { get; private set; }
        
        public ViewObjectDescribe(Schema.DescribeSObjectResult objectDescribe){
            this.name = objectDescribe.getName();
            this.isAccessible = objectDescribe.isAccessible();
        }
    }
    
    @testVisible 
    class ViewColumnDescribe{
        public String name { get; private set; }
        public Boolean hasUserReference { get; private set; }
        public Boolean hasGroupReference { get; private set; }
        public String displayName { get; private set; }
        public Boolean isAccessible { get; private set; }
        public String label { get; set; }
        
        public ViewColumnDescribe(Schema.DescribeFieldResult columnDescribe){
            this.name = columnDescribe.getName();
            this.label = columnDescribe.getLabel();         
            this.hasUserReference = false;
            this.hasGroupReference = false;
            this.displayName = this.name;           
            this.isAccessible = columnDescribe.isAccessible();
            prepareUserReferenceDescribe(columnDescribe);
        }
        
        private void prepareUserReferenceDescribe(Schema.DescribeFieldResult columnDescribe){
            Set<Schema.sObjectType> referenceSet = new Set<Schema.sObjectType> (columnDescribe.getReferenceTo());
            if (referenceSet.size() > 0) {
                this.hasUserReference = referenceSet.contains(User.sobjecttype);
                this.hasGroupReference = referenceSet.contains(Group.sobjecttype);
                this.displayName = columnDescribe.getRelationshipName() + '.Name';
                referenceSet.clear(); 
            } 
        }       
    }
}