/**
 * ****** CONFIGURATION *****
 *  1. add java script to your page:
 *  @see GNE_SFA2_FRMAccountDCRController.vfp
 *     <script>    
    function openLookup(baseURL, width, modified, searchParam){
        var originalbaseURL = baseURL;
        var originalwidth = width;
        var originalmodified = modified;
        var originalsearchParam = searchParam;    
        var lookupType = baseURL.substr(baseURL.length-3, 3);
        if (modified == '1') baseURL = baseURL + searchParam;    
        var isCustomLookup = false;

        if(lookupType == "001"){ //1.1 change to Id prefix of your Object   
          var urlArr = baseURL.split("&");
          var txtId = '';
          if(urlArr.length > 2) {
            urlArr = urlArr[1].split('=');
            txtId = urlArr[1];
          }
          
          baseURL = "/apex/GNE_SFA2_FRM_StandUI_Lookup?txt=" + txtId; //1.2 change to your VFP
          baseURL = baseURL + "&conf=FRMAccountDCRLookup"; //1.3 change to name of GNE_Foun_Misc_Config_Items_gne__c record
          baseURL = baseURL + "&title=Select Duplicate Account"; //1.4 remove or change title of page
          baseURL = baseURL + "&frm=" + escapeUTF("{!$Component.DCRForm}"); //1.5 change to your id of form
		  baseURL = baseURL + "&master=Match_Winner_SfdcId__c";  //1.6 if you want change object in lookup to other you can mask 'Name' field by this field (ref lookup instance of Id)
          baseURL = baseURL + "&masterLbl=Match_Winner_SfdcId__r.Name";  //1.7 displayed value for master (which is instance of Id)

          if (modified == '1') {
            baseURL = baseURL + "&lksearch=" + searchParam;
          }
          baseURL = baseURL + "&condition= and Account_Type_gne__c='Physician Practice'"; //add  condition to query
          //1.6 change to your id of field where you want to use custom lookup
          //can be more than one ex: txtId.indexOf('duplicate_02') > -1 || txtId.indexOf('duplicate_03') > -1 
          if(txtId.indexOf('duplicate_02') > -1 ){
              isCustomLookup = true;
          }
        }

        if(isCustomLookup == true){
          openPopup(baseURL, "lookup", 350, 480, "width="+width+",height=480,toolbar=no,status=no,directories=no,menubar=no,resizable=yes,scrollable=no,location=no", true);
        }
        else {
          if (modified == '1') originalbaseURL = originalbaseURL + originalsearchParam;
          openPopup(originalbaseURL, "lookup", 350, 480, "width="+originalwidth+",height=480,toolbar=no,status=no,directories=no,menubar=no,resizable=yes,scrollable=no", true);
        } 
      }
</script>
 * 
 * 2. Add record of GNE_Foun_Misc_Config_Items_gne__c
 *    Name = your name (will be used in js look at 1.3)
 *    Configuration Value:
 *      {"obNa":"Account","fs":[{"n":"Name","s":"Y"},{"n":"Account_Type_gne__c"},{"n":"Name_and_Address_gne__c"},{"n":"MDMID_gne__c"}],"wc":"WHERE RecordType.Name='FRM_HCO'","rfs":[{"n":"RecordType.Name","l":"Record Type"}],"lim":"20"}
 *    2.1 obNa => api name of object for custom lookup
 *    2.2 fs   => fiels we want to display on page (text field will be avilable for query), Order of fields are the same as we added to JSON n =>field api name, s => if "Y" we can search by this field (it must be text type)
 *    2.3 wc   => conditions for WHERE clause (can be moved to url params)
 *    2.4 rfs  => fields form reference object each field is an instance of class fields. apiN => api name of field, label => this will displayed in header as label of this field
 *    2.5 lim  => query limit 
 */ 
public with sharing class GNE_SFA2_FRM_StandUI_LookupCntr {
    public List<sObject> results            {get;set;} 
    public String searchString              {get;set;} 
    public String condition                 {get;set;} 
    public String objectName                {get;private set;}
    public String masterIdfield             {get;private set;}
    public String masterFieldLabel          {get;private set;}
    public List<String> fieldsOrdered       {get;private set;}
    public Map<String, String> apiFieldsMap {get;private set;}
    private final static String DEFAULT_OBJECT_NAME = 'Account';
    private final static String DEFAULT_LIMIT = '25';
    private final static String DEFAULT_TITLE = 'Search ';
    private final static List<String> DEFAULT_FIELDS = new List<String>{'Name'};
    private final static Map<String, String> DEFAULT_SEARCH_FIELDS = new Map<String, String> {'Name'=>'Y'};
    private List<String> fields;
    private List<String> apiFields;
    private String whereClause = '';
    private String soqlLimit = '';
    private PageConfiguration pageConfig;
    private Boolean isWhereAdded = false;
      
    public GNE_SFA2_FRM_StandUI_LookupCntr() {
        setDeafaultValues();
        readConfiguration();
        fieldsOrdered = fetchFields();
        searchString = System.currentPageReference().getParameters().get('lksrch');
        condition = System.currentPageReference().getParameters().get('condition');
        masterIdfield = getMasterField();
        masterFieldLabel = getMasterFieldLabel();
        runSearch();  
    }
    
    private String getMasterField() {
        masterIdfield = 'Name';
        if(System.currentPageReference().getParameters().get('master') != null){
            masterIdfield = System.currentPageReference().getParameters().get('master');
        }
        return masterIdfield;
    }
    
    private String getMasterFieldLabel() {
        masterFieldLabel = masterIdfield;
        if(System.currentPageReference().getParameters().get('masterLbl') != null){
            masterFieldLabel = System.currentPageReference().getParameters().get('masterLbl');
        }
        return masterFieldLabel;
    }
    
    public String getTitle(){
        String title = DEFAULT_TITLE + objectName;
        if(System.currentPageReference().getParameters().get('title') != null){
            title = System.currentPageReference().getParameters().get('title');
        }
        return title;
    }
    
    private void readConfiguration() {
        String confObjectName = System.currentPageReference().getParameters().get('conf');
        if(confObjectName != null){          
            readObjectConfiguration(confObjectName);
        }      
    }
    
    private void setDeafaultValues(){
        objectName = DEFAULT_OBJECT_NAME;
        fields     = DEFAULT_FIELDS;
        soqlLimit  = DEFAULT_LIMIT;
    }

    private void readObjectConfiguration(String confObjectName) {
        if(GNE_Foun_Misc_Config_Items_gne__c.getValues(confObjectName) != null){
            String confString = GNE_Foun_Misc_Config_Items_gne__c.getValues(confObjectName).Configuration_Value_gne__c;
            if(String.isNotBlank(confString)){
                try{
                    pageConfig  = (PageConfiguration)JSON.deserializeStrict(confString, PageConfiguration.class);
                    System.debug('pageConfig >>> ' + pageConfig);
                    objectName  = String.isBlank(pageConfig.obNa) ? DEFAULT_OBJECT_NAME : pageConfig.obNa;
                    List<String> tempList = pageConfig.getfieldsToString();
                    fields      = tempList == null || tempList.isEmpty() ? DEFAULT_FIELDS : tempList;
                    whereClause = String.isBlank(pageConfig.wc) ? whereClause : pageConfig.wc;
                    soqlLimit   = String.isBlank(pageConfig.lim) ? DEFAULT_LIMIT : pageConfig.lim;
                } catch (Exception ex){
                    throw new applicationException('Problem details: ' + ex.getMessage() + '. Please, check JSON in configuration object.');
                }
            } 
        }
    }
       
    public PageReference search() {
        runSearch();
        return null;
    }
  
    private void runSearch() {
        String listType = 'List<' + objectName + '>';
        try{
            results = (List<SObject>)Type.forName(listType).newInstance();   
        } catch (Exception ex){
            throw new ApplicationException('Problem with object name: '+objectName+ '. Please, check object name in JSON in configuration object.');
        }
        results = performSearch(searchString);    
    } 

    private List<sObject> performSearch(String searchString) {
        String fieldNames =  createFieldsString();
        String soql = 'SELECT ' + fieldNames + ' FROM '+ objectName +' '+whereClause;
        
        if(String.isNotBlank(condition)){
            if(String.isBlank(whereClause)){
                isWhereAdded = true;
                whereClause += ' WHERE ';
                soql += ' WHERE '+condition;
            } else if(isWhereAdded){
                soql += condition;
            } else {
                soql += ' AND '+condition;
            }
        }
        if(String.isNotBlank(searchString)){
            soql +=  completeQuery(searchString);
        }
        soql += ' LIMIT ' + soqlLimit;
        System.debug('soql >>> '+soql);
        try{
            return Database.query(soql);
        } catch(Exception ex){
            throw new ApplicationException('Problem details: '+ ex.getMessage());
        } 
    }
    
    private String createFieldsString() {
        String fieldsToQuery = '';
        for(String s :fieldsOrdered){
            fieldsToQuery += s +', ';
        }
        fieldsToQuery += 'Id ';
        if(masterIdfield != 'Name' && String.isNotBlank(masterFieldLabel)) {
            fieldsToQuery += ',' + masterFieldLabel + ' ';
        }
        
        return fieldsToQuery;
    }
    
    private String completeQuery(String searchString) {
        sObject sObj = Schema.getGlobalDescribe().get(objectName).newSObject() ;
        Schema.sObjectType objType = sObj.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();       
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
        Boolean isFirstIteraction = true;
        String soql = String.isBlank(whereClause) ? 'WHERE (' : ' AND (';
        Map<String,String> searchFields = pageConfig == null || pageConfig.getSearchFields() == null ? DEFAULT_SEARCH_FIELDS : pageConfig.getSearchFields();
        Integer fieldCounter = 0;
        if(masterIdfield != 'Name' && String.isNotBlank(masterFieldLabel) ){
            soql += masterFieldLabel + ' LIKE \'%' + searchString + '%\'';
            isFirstIteraction = false;
            fieldCounter ++;
        }
        for(String field :searchFields.keySet()){
            if(field.contains('.')|| searchFields.get(field) != 'Y'){
                continue;
            }
            Schema.SObjectField f = fieldMap.get(field);
            Schema.DisplayType fldType = f.getDescribe().getType();
            
            if(fldType == Schema.DisplayType.STRING ){
                fieldCounter ++;
                if(isFirstIteraction){
                    soql += field + ' LIKE \'%' + searchString + '%\'';
                    isFirstIteraction = false;
                } else {
                    soql += ' OR ' + field + ' LIKE \'%' + searchString + '%\'';
                }
            }
        }
        soql += ')';
        if(fieldCounter == 0) soql = '';
        return soql;
    }

    public String getFormTag() {
        return System.currentPageReference().getParameters().get('frm');
    }

    public String getTextBox() {
        return System.currentPageReference().getParameters().get('txt');
    }

    public List<String> fetchFields() {
        List<String> fieldsOrdered = new List<String>();
        apiFieldsMap = new Map<String, String>();
        if(pageConfig != null) {
            for(Field field : pageConfig.getFields()){
                if(!field.n.contains('.')){
                    if(field.l == null){
                        apiFieldsMap.put(field.n, objectName);
                    } else {
                        apiFieldsMap.put(field.n, field.l);
                    }
                    fieldsOrdered.add(field.n);
                } 
            }
        
            for(ReferenceField rf : pageConfig.getRefFields()){
                apiFieldsMap.put(rf.n, rf.l);
                fieldsOrdered.add(rf.n);
            }
        } else {
            fieldsOrdered.addAll(fields);
            for(string f : fields) {
                apiFieldsMap.put(f, objectName);
            }
        }
        
        return fieldsOrdered;
    }
    
    private class PageConfiguration{
        private String obNa;              // objectName       
        private String wc;                // whereClause
        private String lim;               // query limit
        private List<Field> fs;           // object's fields
        private List<ReferenceField> rfs; // fields from ref objects
        private List<String> fieldsToString;
        
        public List<String> getfieldsToString(){
            if(fs != null){
                fieldsToString = new List<String>();
                for(Field f:fs){
                    fieldsToString.add(f.n);
                }
            }  
            return fieldsToString;
        }
        
        public Map<String, String> getSearchFields(){
            Map<String, String> searchFields = new Map<String, String>();
            for(Field f:fs){
                if(searchFields == null){
                    searchFields = new Map<String, String>();
                }
                searchFields.put(f.n, f.s);
            }
            return searchFields;
        }
        
        public List<ReferenceField> getRefFields(){
            if(rfs == null){
                rfs = new List<ReferenceField>();
            }
            return rfs;
        }
        
        public List<Field> getFields(){
            if(fs == null){
                fs = new List<Field>();
            }
            return fs;
        }
    }
    
    private class Field{
        String n; //field's api name
        String l; //field's label
        String s = 'N'; //searchable, default = N (NOT)
        Boolean masterField = false; //is field is master instead name
    }

    private class ReferenceField{
        String n; //field's api name
        String l; //field's label
    }
    
    public class ApplicationException extends Exception {}
}