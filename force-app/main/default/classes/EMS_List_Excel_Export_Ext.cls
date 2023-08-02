public with sharing class EMS_List_Excel_Export_Ext {
    public String fileName { get; set; }
    public List<RecordWrapper> sobjects { get; set; }
    public Map<Integer, String> headerLabels { get; private set; }

    private View_Config_gne__c view;
    private Map<Integer, String> fields;
    private Schema.DescribeSObjectResult sobjectDescribe;

    private Boolean lastmodifiedbyExists = false;
    private Boolean createdbyExists = false;
    private Boolean recordtypeExists = false;
    private Map<String, User> userMap;
    private Map<String, RecordType> recordTypeMap;

    public Boolean renderColumn1 { get; set; }
    public Boolean renderColumn2 { get; set; }
    public Boolean renderColumn3 { get; set; }
    public Boolean renderColumn4 { get; set; }
    public Boolean renderColumn5 { get; set; }
    public Boolean renderColumn6 { get; set; }
    public Boolean renderColumn7 { get; set; }
    public Boolean renderColumn8 { get; set; }
    public Boolean renderColumn9 { get; set; }

    public string bom {
        get {
            return EncodingUtil.base64decode('77u/').tostring();
        }
    }

    public List<Sobject> recordsToExport { get; set; }
    public EMS_List_Excel_Export_Ext() {
        String ids = ApexPages.currentPage().getParameters().get('ids');
        String viewId = ApexPages.currentPage().getParameters().get('viewId');
        String sortField = ApexPages.currentPage().getParameters().get('srtf');
        String sortOrder = ApexPages.currentPage().getParameters().get('srto');
        fileName = ApexPages.currentPage().getParameters().get('fn') + ' Export ' + Datetime.now().format('MM_dd_yyyy h:mm a');

        view = getView(viewId);
        if (view == null) {
            return;
        }

        sobjectDescribe = getSObjectDescirbe(view.Object_Type_gne__c);
        String query = generateQuery(ids, sortField, sortOrder);

        List<Sobject> sobjectList = Database.query(query);
        userMap = prepareUserMap(sobjectList);
        recordTypeMap = prepareRecordTypeMap(sobjectList);

        Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get(view.Object_Type_gne__c).getDescribe().fields.getMap();
        Integer counter = 0;
        headerLabels = new Map<Integer, String>();
        fields = new Map<Integer, String>();
        for (String field : view.View_Fields_gne__c.split(';')) {
            // Populate label's map 
            if (field.contains('.')) {
                // Special case for owner.allias, owner.firstname, owner.lastname and etc.
                if (field.equalsIgnoreCase('owner.firstname')) {
                    headerLabels.put(counter, 'Owner First Name');
                } else if (field.equalsIgnoreCase('owner.lastname')) {
                    headerLabels.put(counter, 'Owner Last Name');
                } else if (field.equalsIgnoreCase('owner.alias')) {
                    headerLabels.put(counter, 'Owner Alias');
                } else if (field.equalsIgnoreCase('createdby.alias')) {
                    headerLabels.put(counter, 'Created By Alias');
                } else if (field.equalsIgnoreCase('lastmodifiedby.alias')) {
                    headerLabels.put(counter, 'Last Modified By Alias');
                } 
                /*else if (field.equalsIgnoreCase('account.name')) {
                    headerLabels.put(counter, 'Name');
                } else if (field.equalsIgnoreCase('account.parentid')) {
                    headerLabels.put(counter, 'Account Parent Account');
                } else if (field.equalsIgnoreCase('reportsto.lastname')) {
                    headerLabels.put(counter, 'Reports To Last Name');
                } else if (field.equalsIgnoreCase('reportsto.firstname')) {
                    headerLabels.put(counter, 'Reports To First Name');
                }*/
            } else {
                headerLabels.put(counter, fieldsMap.get(field).getDescribe().getLabel());
            }


            // Populate field's map
            Boolean isReference = checkIfReference(field);
            if (isReference) {
                field = field.replace('__c', '__r');
            }
            fields.put(counter, field);
            counter++;
        }

        Integer columnCount = fields.size();
        sobjects = new List<RecordWrapper>();
        for (Integer i = 0; i < sobjectList.size(); i++) {
            String value0 = String.valueOf(sobjectList.get(i).get(fields.get(0)));
            RecordWrapper record = new RecordWrapper(value0);
            if (fields.containsKey(1)) {
                record.value1 = getValue(1, sobjectList.get(i));
                renderColumn1 = true;
            }
            if (fields.containsKey(2)) {
                record.value2 = getValue(2, sobjectList.get(i));
                renderColumn2 = true;
            }
            if (fields.containsKey(3)) {
                record.value3 = getValue(3, sobjectList.get(i));
                renderColumn3 = true;
            }
            if (fields.containsKey(4)) {
                record.value4 = getValue(4, sobjectList.get(i));
                renderColumn4 = true;
            }
            if (fields.containsKey(5)) {
                record.value5 = getValue(5, sobjectList.get(i));
                renderColumn5 = true;
            }
            if (fields.containsKey(6)) {
                record.value6 = getValue(6, sobjectList.get(i));
                renderColumn6 = true;
            }
            if (fields.containsKey(7)) {
                record.value7 = getValue(7, sobjectList.get(i));
                renderColumn7 = true;
            }
            if (fields.containsKey(8)) {
                record.value8 = getValue(8, sobjectList.get(i));
                renderColumn8 = true;
            }
            if (fields.containsKey(9)) {
                record.value9 = getValue(9, sobjectList.get(i));
                renderColumn9 = true;
            }
            sobjects.add(record);
        }
    }

    private String getValue(Integer index, Sobject objectItem) {
        String field = fields.get(index);
        String returnValue = '';
        if (field.endsWith('__r')) {
            Sobject relationObj = objectItem.getSObject(field);
            if (relationObj != null) {
                returnValue = String.valueOf(relationObj.get('name'));
            }
        } else {
            if (checkIfDateTime(field)) {
                returnValue = DateTime.valueOf(objectItem.get(field)).format();
            } else if (checkIfDate(field)) {
                // Check if the Date field is not empty
                if (objectItem.get(field) != null) {
                    returnValue = Date.valueOf(objectItem.get(field)).format();
                }
            } else if (checkIfCurrency(field)) {
                returnValue = '$' + String.valueOf(objectItem.get(field));
            } else if (checkIfReference(field)) {
                if (field.contains('.')) {
                    // Special case for owner.allias, owner.firstname, owner.lastname and etc.
                    if (field.equalsIgnoreCase('owner.firstname')) {
                        field = 'Owner';
                        String subField = 'FirstName';
                        Sobject relationObj = objectItem.getSObject(field);
                        returnValue = String.valueOf(relationObj.get(subField));
                    } else if (field.equalsIgnoreCase('owner.lastname')) {
                        field = 'Owner';
                        String subField = 'LastName';
                        Sobject relationObj = objectItem.getSObject(field);
                        returnValue = String.valueOf(relationObj.get(subField));
                    } else if (field.equalsIgnoreCase('owner.alias')) {
                        field = 'Owner';
                        String subField = 'Alias';
                        Sobject relationObj = objectItem.getSObject(field);
                        returnValue = String.valueOf(relationObj.get(subField));
                    } else if (field.equalsIgnoreCase('createdby.alias')) {
                        field = 'CreatedBy';
                        String subField = 'Alias';
                        Sobject relationObj = objectItem.getSObject(field);
                        returnValue = String.valueOf(relationObj.get(subField));
                    } else if (field.equalsIgnoreCase('lastmodifiedby.alias')) {
                        field = 'LastModifiedBy';
                        String subField = 'Alias';
                        Sobject relationObj = objectItem.getSObject(field);
                        returnValue = String.valueOf(relationObj.get(subField));
                    } else {
                        returnValue = '## ERROR';
                    }
                    /*else if (field.equalsIgnoreCase('account.name')) {

                    } else if (field.equalsIgnoreCase('account.parentid')) {

                    } else if (field.equalsIgnoreCase('reportsto.lastname')) {

                    } else if (field.equalsIgnoreCase('reportsto.firstname')) {

                    }*/
                } else {
                    String idField = (String) objectItem.get(field);
                    if (field.toLowerCase() == 'lastmodifiedbyid' || field.toLowerCase() == 'createdbyid') {
                        returnValue = (userMap.containsKey(idField)) ? userMap.get(idField).Name : idField;
                    }
                    if (field.toLowerCase() == 'recordtypeid') {
                        returnValue = (recordTypeMap.containsKey(idField)) ? recordTypeMap.get(idField).Name : idField;
                    }
                }
            } else {
                returnValue = String.valueOf(objectItem.get(field));
            }
        }
        return returnValue;
    }

    private String generateQuery(String ids, String sortField, String sortOrder) {
        // FROM 
        String fromPart = ' FROM ' + String.valueOf(view.Object_Type_gne__c);

        // SELECT
        String fieldsSelectString = '';
        Integer counter = 0;
        for (String field : view.View_Fields_gne__c.split(';')) {
            Boolean isReference = checkIfReference(field);
            if (isReference) {
                field = field.replace('__c', '__r');
                if (field.endsWith('__r')) {
                    field += '.name';
                } else {
                    // lastmodifiedby or createdby fields are detected
                    if (field.toLowerCase() == 'lastmodifiedbyid') {
                        lastmodifiedbyExists = true;
                    }
                    if (field.toLowerCase() == 'createdbyid') {
                        createdbyExists = true;
                    }
                    // recordtype field is detected
                    if (field.toLowerCase() == 'recordtypeid') {
                        recordtypeExists = true;
                    }
                }
            }
            if (counter == 0) {
                fieldsSelectString += field;
            } else {
                fieldsSelectString += ',' + field;
            }
            counter++;
        }
        String selectPart = 'SELECT ' + fieldsSelectString;

        // WHERE 
        String wherePart = '';
        if (String.isEmpty(ids)) {
            // Current view WHERE condition(s)
            String whereParam = ApexPages.currentPage().getParameters().get('where');
            if (String.isNotEmpty(whereParam)) {
                wherePart = ' WHERE ' + whereParam;
            }
        } else {
            List<String> idsList = ids.split(',');
            String idsString = '(';
            for (Integer i = 0; i < idsList.size(); i++) {
                if (i == idsList.size() - 1) {
                    idsString += '\'' + idsList.get(i) + '\') ';
                } else {
                    idsString += '\'' + idsList.get(i) + '\',';
                }
            }
            wherePart = ' WHERE id IN ' + idsString;
        }

        // ORDER BY
        String orderbyPart = '';
        if (!String.isBlank(sortField)) {
            // Sorting by clicking header of the column
            if (String.isBlank(sortOrder)) {
                sortOrder = 'ASC';
            }
            orderbyPart = ' ORDER BY ' + sortField + ' ' + sortOrder + ' NULLS LAST';
        } else if (view.Sorting_Field_gne__c != null) {
            sortOrder = (view.Sorting_Order_gne__c != null) ? view.Sorting_Order_gne__c : '' ;
            orderbyPart = ' ORDER BY ' + view.Sorting_Field_gne__c + ' ' + sortOrder + ' NULLS LAST';
        }
        return selectPart + fromPart + wherePart + orderbyPart + ' LIMIT 1000';
    }

    private static View_Config_gne__c getView(String viewId) {
        View_Config_gne__c view = null;
        if (String.isNotEmpty(viewId)) {
            view = [SELECT View_Fields_gne__c, Object_Type_gne__c, Sorting_Order_gne__c, Sorting_Field_gne__c FROM View_Config_gne__c WHERE Id = :viewId];
        }
        return view;
    }

    private Map<String, User> prepareUserMap(List<Sobject> sobjectList) {
        if (lastmodifiedbyExists || createdbyExists) {
            Set<Id> userIds = new Set<Id>();
            for (Sobject sobjectItem :sobjectList) {
                if (lastmodifiedbyExists) {
                    userIds.add((Id) sobjectItem.get('LastModifiedById'));
                }
                if (createdbyExists) {
                    userIds.add((Id) sobjectItem.get('CreatedById'));
                }
            }
            if (!userIds.isEmpty()) {
                return new Map<String, User>([SELECT Id, Name FROM User WHERE Id IN:userIds LIMIT 45000]);
            }
        }
        return new Map<String, User>();
    }

    private Map<String, RecordType> prepareRecordTypeMap(List<Sobject> sobjectList) {
        if (recordtypeExists) {
            Set<Id> rtIds = new Set<Id>();
            for (Sobject sobjectItem :sobjectList) {
                rtIds.add((Id) sobjectItem.get('RecordTypeId'));
            }
            if (!rtIds.isEmpty()) {
                return new Map<String, RecordType>([SELECT Name FROM RecordType WHERE Id IN:rtIds LIMIT 45000]);
            }
        }
        return new Map<String, RecordType>();
    }

    private Boolean checkIfReference(String fieldName) {
        String fieldType = getFieldType(fieldName);
        return fieldType.toLowerCase() == 'reference';
    }

    private Boolean checkIfDateTime(String fieldName) {
        String fieldType = getFieldType(fieldName);
        return fieldType.toLowerCase() == 'datetime';
    }

    private Boolean checkIfDate(String fieldName) {
        String fieldType = getFieldType(fieldName);
        return fieldType.toLowerCase() == 'date';
    }

    private Boolean checkIfCurrency(String fieldName) {
        String fieldType = getFieldType(fieldName);
        return fieldType.toLowerCase() == 'currency';
    }

    private String getFieldType(String fieldName) {
        if (fieldName.contains('.')) {
            // This condition is used for the following fields: owner.allias, owner.firstname, owner.lastname and others 
            return 'reference';
        }
        Schema.DescribeFieldResult fieldDescribe = sobjectDescribe.fields.getMap().get(fieldName).getDescribe();
        return String.valueOf(fieldDescribe.getType());
    }

    private Schema.DescribeSObjectResult getSObjectDescirbe(String sobjectName) {
        return Schema.getGlobalDescribe().get(sobjectName).getDescribe();
    }

    public class RecordWrapper {
        public String value0 { get; set; }
        public String value1 { get; set; }
        public String value2 { get; set; }
        public String value3 { get; set; }
        public String value4 { get; set; }
        public String value5 { get; set; }
        public String value6 { get; set; }
        public String value7 { get; set; }
        public String value8 { get; set; }
        public String value9 { get; set; }

        public RecordWrapper(String value0) {
            this.value0 = value0;
        }
    }
}