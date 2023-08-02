public with sharing class EDM_MultiselectPicklistWithSearch_Ctrl {
    private Boolean initialized = false;
    public List<String> defApiFields {get; private set;}
    public Map<String, String> labelFor {get; private set;}
    private List<String> queryCols = null;

    public String objectTypeName {get; set;}
    public String columnFields {get; set;}
    public String columnLabels {get; set;}
    public String whereExpr {get; set;}
    public String checkboxField {get; set;}
    public String itemsString {get;set;}
    private String query;

    transient private List<SObject> availableItems {get; set;}
    
    public EDM_MultiselectPicklistWithSearch_Ctrl () {
        System.debug('##-CONTROLLER START-##');
    }

    private void initComp() {
        System.debug('##-INIT START-##');
        queryCols = new List<String>();

        defApiFields = getListFromString(columnFields, new List<String> {'Name'});

        // Get from user defined cols
        if (defApiFields != null) {
            queryCols.addAll(new Set<String>(defApiFields));
        }

        initLabelsMapForFields();
        availableItems = new List<SObject>();
        initialized = true;
    }

    private void initLabelsMapForFields() {
        System.debug('##-INIT LABELS START-##');
        labelFor = new Map<String, String>();
        List<String> defLabelFields = getListFromString(columnLabels, new List<String> ());

        for(Integer i = 0; i < defApiFields.size(); i++) {
            if (i < defLabelFields.size() && String.isNotBlank(defLabelFields[i])) {
                labelFor.put(defApiFields[i], defLabelFields[i] + ': ');
            } else {
                labelFor.put(defApiFields[i], '');
            }
        }
    }

    private List<String> getListFromString(String paramStr, List<String> defaultValueList) {
        String[] paramSplited = paramStr!=null ? paramStr.split(',') : defaultValueList;
        List<string> results = new List<string>();
        for (String param : paramSplited){
            results.add(param.trim());
        }
        return results;
    }

    public void retrieveAvailable() {
        System.debug('##-REVIEW AVAILABLE START-##');
        if (!initialized) {
            initComp();
        }

           
        query = 'SELECT ' + String.join(queryCols, ',') + ', ' + checkboxField
                        + ' FROM ' + objectTypeName
                        + (String.isNotBlank(whereExpr) ? (' WHERE ' + whereExpr) : '');

        System.debug('MULTIPICKLIST QUERY: '+query);
        availableItems = Database.query(query);
        //}

        Integer i = 0;
        Integer j = 0;
        Integer fieldsSize = defApiFields.size()-1;
        itemsString = '';
        for(SObject obj : availableItems){
            if(i>0){
                itemsString += ';';
            }
            for(String field : defApiFields){
                try{
                    Date s = Date.valueOf(obj.get(field));
                    String dateStr = '';
                    if(s!=null){
                        dateStr = s.format();
                    }
                    itemsString += 'Approved: ' + dateStr + ' - ' + String.valueOf(obj.get('Curriculum_Status_gne__c')) + '|';
                }catch(Exception e){
                    itemsString += String.valueOf(obj.get(field)) + '|';
                }               
            }
            itemsString += String.valueOf(obj.get(checkboxField));
            i++;
        }
        System.debug(itemsString);
    }
}