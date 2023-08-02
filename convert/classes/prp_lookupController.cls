/*
* @File Name:   prp_lookupController
* @Description: Controller class for custom lwc Lookup component i.e prp_customLookup
* @group:       Apex Class
* @Modification Log  :
______________________________________________________________________________________
* Ver       Date         Modification
* 1.0       2022-06-09   Created the Component
*/
public class prp_lookupController {
    public final static String DELIMITER = ' - ';
    private final static Integer MAX_RESULTS = 5;

    //search database
    //type   --  sobject type
    //searchString  --  search term
    //recordTypes  --  record types filters optional
    //fields  -- fields to query optional
    //filters  --  extra filters optional
@AuraEnabled(Cacheable=true)
public static List<Account> searchAccounts() {
return [SELECT Id, Name ,Type FROM Account];        
}
@AuraEnabled(Cacheable=true)
    public static List<prp_lookupSearchResult> search(String type, String searchString,String[] recordTypes, String[] fields, String[] filters) {
		return search(type, searchString, recordTypes,  fields,  filters,null);
	}

 
    public static List<prp_lookupSearchResult> search(String type, String searchString,String[] recordTypes, String[] fields, String[] filters,String searchingfield) {
        // Prepare query paramters
        System.debug('fldsvalues'+searchingfield);
       searchString += '*';
        String value;
        
        if(searchingfield ==null && searchingfield != 'NAME' && searchingfield != 'PHONE'&& searchingfield != 'EMAIL '&& searchingfield != 'SIDEBAR'  ){
             value = 'ALL';
        }else{
              value = searchingfield;
        }
      String whereClause = constructWhereClause(recordTypes, filters, true);

        SObjectType objType = Schema.getGlobalDescribe().get(type);
        if(objType == null){
            return null;
        }
        String nameField = getSobjectNameField(objType);
        if(fields == null)
            fields = new List<String>();

        if(!fields.contains(nameField)){
            fields.add(nameField);
        }

        String qStrDis = String.join(fields, ',');
            

        // Execute search query
        String query = 'FIND :searchString IN '+value+' FIELDS RETURNING '
                          + type +'(Id, ' + qStrDis + ' ' 
                          + whereClause + ' ORDER BY Name ASC NULLS last) LIMIT 20';
        List<List<SObject>> results =  Search.query(query);
        List<SObject> records;  
         System.debug('+++++++++++++records results:' + results);
        if(results.size()>0){
            records = results[0];
        }else{
            return null;
        }

        // Prepare results
        List<prp_lookupSearchResult> ret = new List<prp_lookupSearchResult>();
        for(SObject sobj : records){
            String n = fields.size() > 0 ? getDisplayName(sobj, fields) : (String)sobj.get(nameField);
            prp_lookupSearchResult sr = new prp_lookupSearchResult(
                (String)sobj.get('Id'), type, getIcon(type), n, '');

            ret.add(sr);
        }

        return ret;
    }

    //list recent view record
    //record type filter applied
    @AuraEnabled
    public static List<prp_lookupSearchResult> searchRecentViewed(String type, String[] recordTypes, String[] fields, String[] filters){
        Set<Id> ids = new Set<Id>();
        for(RecentlyViewed rv : [Select Id, LastViewedDate From RecentlyViewed Where type = :type order by LastViewedDate Desc]){
            ids.add(rv.Id);
        }
        SObjectType objType = Schema.getGlobalDescribe().get(type);
        if(objType == null){
            return null;
        }
        String nameField = getSobjectNameField(objType);
        if(fields == null)
            fields = new List<String>();
        String qStrDis = String.join(fields, ',') + 
            (fields.contains(nameField) ? '' : nameField);

        if(ids.size() == 0)
            return null;

        else{
            List<prp_lookupSearchResult> ret = new List<prp_lookupSearchResult>();
            String whereClause = constructWhereClause(recordTypes, filters, false);
            String q = 'Select Id, ' + qStrDis + ' From ' + type + ' Where Id in :ids ' + whereClause + ' limit 10';
         System.debug('--------------The query is - ' + q);
            List<SObject> qRes = Database.query(q);
            for(SObject sobj : qRes){
                String n = fields.size() > 0 ? getDisplayName(sobj, fields) : (String)sobj.get(nameField);
                prp_lookupSearchResult sr = new prp_lookupSearchResult(
                    (String)sobj.get('Id'), type, getIcon(type), n, '');
                ret.add(sr);
            }

            return ret;
        }
    }

    //consturct where clause
    private static String constructWhereClause(String[] recordTypes, String[] filters, Boolean startWhere){
        if(
            (recordTypes == null || recordTypes.size() == 0) && (filters == null || filters.size() == 0)
        ){
            return '';
        }

        String whereClause = '';
        if(recordTypes != null && recordTypes.size() > 0)
            whereClause = 'RecordType.DeveloperName in :recordTypes';

        if(filters != null && filters.size() > 0){
            whereClause = String.isBlank(whereClause) ? '' : ' And ';
            whereClause += String.join(filters, ' And ');
        }

        if(String.isNotBlank(whereClause) && startWhere == true)
            whereClause = 'Where ' + whereClause;

        if(startWhere == false && String.isNotBlank(whereClause) )
            whereClause = ' And ' + whereClause;

        String ret = whereClause.replace('And And', 'And').replace('And  And', 'And').replace('Where And', 'Where').replace('Where  And', 'Where').replace('AndAnd', 'And').replace('WhereAnd', 'Where');
        return ret;
    }

    //get icon type
    public static String getIcon(String type){
        if(type == 'Account')
            return 'standard:account';
         if(type == 'PRP_Contract__c')
            return 'custom:custom67';
        if(type == 'SPCM_CARS_Contract_Summary_Form__c')
            return 'custom:custom31';

        
        return String.isNotBlank(type) ? 'standard:' + type.toLowerCase() : '';
    }

    /*
     * Returns the "Name" field for a given SObject (e.g. Case has CaseNumber, Account has Name)
	*/
    private static String getSobjectNameField(SobjectType sobjType){
        
        //describes lookup obj and gets its name field
        String nameField = 'Name';
        Schema.DescribeSObjectResult dfrLkp = sobjType.getDescribe();
        for(schema.SObjectField sotype : dfrLkp.fields.getMap().values()){
            Schema.DescribeFieldResult fieldDescObj = sotype.getDescribe();
            if(fieldDescObj.isNameField() ){
            	nameField = fieldDescObj.getName();
                break;
            }
        }
        return nameField;
    }

    /*
     * get a string for display
	*/
    public static String getDisplayName(SObject record, String[] fields){
        if(fields == null || fields.size() == 0){
            return '';
        }

        String[] arr = new List<String>();
        for(String f : fields){
            //arr.add((String)record.get(f));
            arr.add((String)returnString(record,f));
        }

        return String.join(arr, DELIMITER);
    }
    
    public static string returnString(sobject sobj,string fieldname){
        string result='';
        if(string.isNotEmpty(string.valueOf(sobj))){
            if(fieldname.contains('.')){
                list<string> fields = fieldname.split('\\.', 2);
                return returnString(sobj.getSObject(fields[0]),fields[1]);
            }else{
                result=(string)sobj.get(fieldname);
            }
        }       
        return result;
    }

    @AuraEnabled
    public static prp_lookupSearchResult getCurrentValue(String type, String value, String[] fields){
        List<SObject> oList = getByIds(type, new List<String>{value}, fields);
        if(oList == null || oList.size()==0) {
            return null;
        }

        SObjectType objType = Schema.getGlobalDescribe().get(type);
        if(objType == null){
            return null;
        }

        String nameField = getSobjectNameField(objType);
        SObject sobj = oList[0];
        System.debug('sobj - ' + sobj);
        // System.debug('fields - ' + fields);
        // System.debug('getDisplayName - ' + getDisplayName(sobj, fields));
        String n = (fields != null && fields.size() > 0)? getDisplayName(sobj, fields) : (String)sobj.get(nameField);
        prp_lookupSearchResult sr = new prp_lookupSearchResult(
            (String)sobj.get('Id'), type, getIcon(type), n, '');

		return sr;
    }


    //get all values
    @AuraEnabled
    public static List<prp_lookupSearchResult> searchByIds(String type, String[] ids, String[] fields){
        List<SObject> oList = getByIds(type, ids, fields);
        if(oList == null || oList.size()==0) {
            return null;
        }

        SObjectType objType = Schema.getGlobalDescribe().get(type);
        if(objType == null){
            return null;
        }
        
        String nameField = getSobjectNameField(objType);
        List<prp_lookupSearchResult> ret = new List<prp_lookupSearchResult>();
        for(SObject sObj : oList){
            String n = (fields != null && fields.size() > 0) ? getDisplayName(sobj, fields) : (String)sobj.get(nameField);
            ret.add(new prp_lookupSearchResult(
                (String)sobj.get('Id'), type, getIcon(type), n, '')
            );
        }

        return ret;

    }

    //query by ids
    private static List<SObject> getByIds(String type, String[] ids, String[] fields){
        if(String.isBlank(type)){
            return null;
        }
        
        SObjectType objType = Schema.getGlobalDescribe().get(type);
        if(objType == null){
            return null;
        }

        String nameField = getSobjectNameField(objType);
        if(fields == null)
            fields = new List<String>();
        String qStrDis = String.join(fields, ',') + 
            (fields.contains(nameField) ? '' : nameField);

        String query = 'Select Id, '+qStrDis+' From '+type+' Where Id = :ids';
        // System.debug('### Query: '+query);
        return Database.query(query);
    }
}