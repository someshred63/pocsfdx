public with sharing class GT_SObjectUtil {

    public static Map<Id,SObject> getRecords(Id[] Ids) {
      Map<String, List<Id>> objToId = new  Map<String, List<Id>>();
    
      for(Id id:Ids){
        String sObjName = id.getSObjectType().getDescribe().getName();
        if(objToId.get(sObjName)==null){
            objToId.put(sObjName, new List<Id>());
        }
        objToId.get(sObjName).add(id);
      }
      Map<Id,SObject> allRecords = new  Map<Id,SObject>();
      for(String objectName: objToId.keySet()){
        List<Id> idlist = objToId.get(objectName);
        List<String> fields = getFields(objectName);
        String qry = 'select ' +String.join(fields,',') +' from '+objectName + ' where Id in :idlist';
System.debug(qry);
        allRecords.putAll(new Map<Id, sobject>((List<SObject>)Database.query(qry)));
      }
      return allRecords;
    }

    public static List<string> getFields(String selectedObject){
        List<String> reqFields = new List<String>();
        Map <String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sobjType = gd.get(selectedObject);
        Schema.DescribeSObjectResult r = sobjType.getDescribe();
        Map<String, Schema.SObjectField> MapofField = r.fields.getMap();
        
        for(String fieldName : MapofField.keySet()) {
            Schema.SObjectField field = MapofField.get(fieldName);
            Schema.DescribeFieldResult f = field.getDescribe();
            
	         reqFields.add(f.getName());
        }
       
        return reqFields;
    }
    
}