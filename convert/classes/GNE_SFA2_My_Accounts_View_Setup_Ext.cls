public with sharing class GNE_SFA2_My_Accounts_View_Setup_Ext {
    public static final Integer VIEW_COLUMNS_COUNT = 10;
    public static final Integer FILTERS_COUNT = 5;
    
    public List<SelectOption> records{get; set;}
    
    public List<SelectOption> stringOperators {get; set;}
    public List<SelectOption> booleanOperators {get; set;}
    public List<SelectOption> picklistOperators {get; set;}
    public List<SelectOption> multipicklistOperators {get; set;}
    public List<SelectOption> numberOperators {get; set;}
    public List<SelectOption> userBrands {get; set;}
    
    public Integer recordSequence {get; set;}
    public Integer filterSequence {get; set;}
    
    public String sortRecord {get; set;}
    public String sortField {get; set;}
    //index of view column used as sort column
    public Integer sortRow {get; set;}
    
    public List<String> viewRecords {get; set;}
    public List<String> viewFields {get; set;}
    
    private List<String> filterFields {get; set;}
    private List<String> filterOperators {get; set;}
    public List<Boolean> filterErrors {get; set;}
    public Map<Integer,String> filterErrorMessagesMap {get;set;}
    

    private List<String> filterRecords;
    private List<String> filterValues {get; set;}
    private List<List<String>> filterMultiValues {get; set;}
    
    public List<String> filterFieldType {get; set;}
    public List<String> viewFieldType {get; set;}
    
    private List<SelectOption> accountFields {get; set;}
    private List<SelectOption> addressFields {get; set;}
    private List<SelectOption> brandAffiliationsFields {get; set;}
    private List<SelectOption> territoryFields {get; set;}
    private List<SelectOption> emptyFields {get; set;}
    
    public List<List<SelectOption>> viewFieldsList {get; set;}
    public List<List<SelectOption>> filterFieldsList {get; set;}
    public List<List<SelectOption>> filterOperatorsList {get; set;}
    public List<List<SelectOption>> filterValuesList {get; set;}
    
    public List<SelectOption> personRecordTypesList {get; set;}
    public List<SelectOption> accountRecordTypesList {get; set;}
    
    //public List<Id> selectedRecordTypes {get; set;}
    public List<String> selectedPersonRecordTypes {get; set;}
    public List<String> selectedAccountRecordTypes {get; set;}
    
    public Integer rowToMove {get; set;}
    public Integer filterToDelete {get; set;}
    public Integer rowToDelete {get; set;}
    
    public SFA2_View_Config_gne__c view {get; set;}
    private GNE_SFA2_My_Accounts_Setttings__c settings;
    private SFA2_User_Preferences_gne__c myPreferences;
    private GNE_SFA2_User_App_Context_gne__c userAppContext = GNE_SFA2_Util.getUserApplicationContext();
    
    private String filterMessage {get; set;}
    
    public GNE_SFA2_My_Accounts_View_Setup_Ext(ApexPages.StandardController controller){
        if(!Test.isRunningTest()){
            controller.addFields(new List<String>{'View_Fields_gne__c','Filter_Statement_gne__c', 'View_Name_gne__c', 'Visibility_gne__c', 'Sorting_Field_gne__c','Person_Record_Types_gne__c', 'Account_Record_Types_gne__c', 'Product_gne__c'});
        }
        view = (SFA2_View_Config_gne__c)controller.getRecord();
        
        try{
            myPreferences = [SELECT Last_View_Used_gne__c, Last_Territory_Used_gne__c FROM  SFA2_User_Preferences_gne__c WHERE Last_View_Used_gne__r.Page_Name_gne__c = 'My Accounts' AND User_gne__c = :Userinfo.getUserId() limit 1];
        }catch(Exception e){
            myPreferences = new SFA2_User_Preferences_gne__c(User_gne__c = UserInfo.getUserId());
        }
                
        records = new List<SelectOption>{new SelectOption('','--None--'), new SelectOption('Account','Account'), new SelectOption('Address','Address'), new SelectOption('BrandAffiliation','Brand Affiliations'), new SelectOption('TSF', 'Territory Field')};
        picklistOperators = new List<SelectOption>{new SelectOption('','--None--'), new SelectOption('inc','equals'), new SelectOption('ecl','not equal to')};
        multipicklistOperators = new List<SelectOption>{new SelectOption('','--None--'), new SelectOption('inc','includes'), new SelectOption('ecl','excludes')};
        booleanOperators = new List<SelectOption>{new SelectOption('','--None--'), new SelectOption('eq','equals'), new SelectOption('ne','not equals')};
        stringOperators = new List<SelectOption>{new SelectOption('','--None--'), new SelectOption('eq','equals'), new SelectOption('ne','not equal to'), new SelectOption('lt','less than'), new SelectOption('lte','less or equal'), new SelectOption('gt','greater than'), new SelectOption('gte','greater or equal'), new SelectOption('c','contains'), new SelectOption('nc','does not contain'), new SelectOption('sw','starts with')};
        numberOperators = new List<SelectOption>{new SelectOption('','--None--'), new SelectOption('eq','equals'), new SelectOption('ne','not equal to'), new SelectOption('lt','less than'), new SelectOption('lte','less or equal'), new SelectOption('gt','greater than'), new SelectOption('gte','greater or equal')};
        selectedPersonRecordTypes = new List<String>();
        selectedAccountRecordTypes = new List<String>();
        
        initializeAccountRecordTypes();
        
        emptyFields = new List<SelectOption>{new SelectOption('','--None--')};
        
        filterMultiValues = new List<List<String>>();

        viewFieldsList = new List<List<SelectOption>>();
        filterFieldsList = new List<List<SelectOption>>();
        filterOperatorsList = new List<List<SelectOption>>();
        filterValuesList = new List<List<SelectOption>>();
        
        viewRecords = new List<String>();
        viewFields = new List<String>();
        viewFieldType = new List<String>();
        filterRecords = new List<String>();
        filterFields = new List<String>();
        filterOperators = new List<String>();
        filterValues = new List<String>();
        filterFieldType = new List<String>();
        filterErrors = new List<Boolean>();
        filterErrorMessagesMap = new Map<Integer,String>();
        
        System.debug('Hi1 app'+userAppContext.App_Name_gne__c);
        System.debug('Hi2 app'+userAppContext.Brand_gne__c);
        System.debug('Hi3 app'+userAppContext.Role_gne__c);
                        
        settings = [Select Account_View_Columns_gne__c, Address_View_Columns_gne__c, Brand_Affiliation_View_Columns_gne__c, PageSize_gne__c, Privileged_Profiles_gne__c, TSF_View_Columns_gne__c FROM GNE_SFA2_My_Accounts_Setttings__c WHERE Application_Type__c = :userAppContext.App_Name_gne__c AND (Brand_gne__c = :userAppContext.Brand_gne__c OR Brand_gne__c = NULL) AND Role_gne__c = :userAppContext.Role_gne__c ];

        accountFields = getObjectsFields(settings.Account_View_Columns_gne__c.split(','), Schema.SObjectType.Account.fields.getMap());
        addressFields = getObjectsFields(settings.Address_View_Columns_gne__c.split(','), Schema.SObjectType.Address_vod__c.fields.getMap());
        brandAffiliationsFields = getBrandAffiliationObjectsFields(settings.Brand_Affiliation_View_Columns_gne__c.split(','), Schema.SObjectType.Product_Metrics_vod__c.fields.getMap());
        territoryFields = getObjectsFields(settings.TSF_View_Columns_gne__c.split(','), Schema.SObjectType.TSF_vod__c.fields.getMap());
        
        for(Integer i = 0; i <VIEW_COLUMNS_COUNT; i++){
            viewFieldsList.add(emptyFields); 
            viewRecords.add(''); 
            viewFields.add('');
            viewFieldType.add('');
            
        }
        
        for(Integer i = 0; i <FILTERS_COUNT; i++){
            filterErrors.add(false);
            filterMultiValues.add(new List<String>());
            filterRecords.add(''); 
            filterOperators.add('');
            filterFields.add(''); 
            filterValues.add(''); 
            filterFieldType.add(Schema.DisplayType.STRING.name());
            filterFieldsList.add(emptyFields);
            filterOperatorsList.add(emptyFields);
            filterValuesList.add(emptyFields);
            
            filterErrorMessagesMap.put(i, '');
        }
        
        if(view.Id!=null){
            prepareEditForm((SFA2_View_Config_gne__c)controller.getRecord());
        }else{
            //set default column
            viewRecords.set(0, 'Account');
            this.recordSequence = 0;
            prepareViewObjectFields();
            viewFields.set(0, 'Name');
            sortRow = 0;
        }
        
        System.debug('##### View Fields === ' + viewFields);
        System.debug('##### View Fields Type  === ' + viewFieldType);
    }
    
    private void prepareEditForm(SFA2_View_Config_gne__c view){
        if(String.isNotEmpty(view.Account_Record_Types_gne__c)){
            for(String recordTypeDeveloperName: view.Account_Record_Types_gne__c.split(',')){
                selectedAccountRecordTypes.add(recordTypeDeveloperName.trim());
            }
        }
        if(String.isNotEmpty(view.Person_Record_Types_gne__c)){
            for(String recordTypeDeveloperName : view.Person_Record_Types_gne__c.split(',')){
                selectedPersonRecordTypes.add(recordTypeDeveloperName.trim());
            }
        }
        
        List<String> columns = view.View_Fields_gne__c.split(';', 0);
        for(Integer i=0; i< columns.size(); i++){
            viewRecords.set(i, columns.get(i).substring(0, columns.get(i).indexOf('.')));
            this.recordSequence = i;
            prepareViewObjectFields();
            viewFields.set(i, columns.get(i).substring(columns.get(i).indexOf('.')+1, columns.get(i).length()));
            if((viewRecords.get(i)+'.'+viewFields.get(i))==view.Sorting_Field_gne__c){
                sortRow=i;
            }
        }
        prepareViewObjectFieldsType();
        removeFieldsAlreadySelected();
        if(String.isNotEmpty(view.Filter_Statement_gne__c)){
            List<ConditionItem>conditionItems = (List<ConditionItem>)JSON.deserializeStrict(view.Filter_Statement_gne__c,  List<ConditionItem>.class);
            for(Integer i=0; i<conditionItems.size(); i++){
                filterRecords.set(i, conditionItems.get(i).record);
                filterSequence = i;
                prepareFilterObjectFields();
                if(filterRecords.get(i) == 'BrandAffiliation') {
                    filterFields.set(i, conditionItems.get(i).brand + '.' + conditionItems.get(i).field);
                } else {
                    filterFields.set(i, conditionItems.get(i).field);
                }
                filterFieldType.set(i, conditionItems.get(i).valueType);
                prepareFilterOperators(i);
                filterOperators.set(i, conditionItems.get(i).operator);
                filterValues.set(i, conditionItems.get(i).value);
                filterMultiValues.set(i, conditionItems.get(i).multiValue);
            } 
        }
    }
    
    private void prepareFilterOperators(Integer filterSequence){
        Schema.DescribeFieldResult fieldDescribe;
        Schema.DisplayType fieldType;
        /*
        * SREEDHAR: To handle reference type field, Value in the picklist will be like "ReferenceName.Name" and  label in the picklist will be Label of the picklist
        */
        String fieldName = filterFields.get(filterSequence);
        if(filterFields.get(filterSequence).endsWith('.Name')){
            fieldName= filterFields.get(filterSequence).split('\\.Name')[0];
            if(fieldName.contains('__r')) fieldName = fieldName.replace('__r', '__c');
            else fieldName = fieldName+'Id';
        }
        System.debug('SREEDHAR : field Name AFRER ' + fieldName);
        filterOperatorsList.set(filterSequence, stringOperators);
        
        if(filterRecords.get(filterSequence)=='Account'){
            fieldType = Schema.SObjectType.Account.fields.getMap().get(filterFields.get(filterSequence)).getDescribe().getType();
            fieldDescribe = Schema.SObjectType.Account.fields.getMap().get(filterFields.get(filterSequence)).getDescribe();
        }else if(filterRecords.get(filterSequence)=='Address'){
            fieldType = Schema.SObjectType.Address_vod__c.fields.getMap().get(filterFields.get(filterSequence)).getDescribe().getType();
            fieldDescribe = Schema.SObjectType.Address_vod__c.fields.getMap().get(filterFields.get(filterSequence)).getDescribe();
        }else if(filterRecords.get(filterSequence)=='BrandAffiliation'){
            fieldType = Schema.SObjectType.Product_Metrics_vod__c.fields.getMap().get(filterFields.get(filterSequence).substringAfterLast('.')).getDescribe().getType();
            fieldDescribe = Schema.SObjectType.Product_Metrics_vod__c.fields.getMap().get(filterFields.get(filterSequence).substringAfterLast('.')).getDescribe();
        }else if(filterRecords.get(filterSequence)=='TSF'){
            fieldType = Schema.SObjectType.TSF_vod__c.fields.getMap().get(filterFields.get(filterSequence)).getDescribe().getType();
            fieldDescribe = Schema.SObjectType.TSF_vod__c.fields.getMap().get(filterFields.get(filterSequence)).getDescribe();
        }
        
        filterFieldType.set(filterSequence, fieldType.name());
        
        if(Schema.DisplayType.MultiPicklist == fieldType){
            List<SelectOption> options = new List<SelectOption>();
            for (Schema.PicklistEntry a : fieldDescribe.getPickListValues()) { //for all values in the picklist list
                options.add(new SelectOption(a.getValue(), a.getLabel())); //add the value and label to our final list
            }
            filterValuesList.set(filterSequence, options);
            filterOperatorsList.set(filterSequence, multipicklistOperators);
        }else if(Schema.DisplayType.Picklist == fieldType){
            List<SelectOption> options = new List<SelectOption>();
            for (Schema.PicklistEntry a : fieldDescribe.getPickListValues()) { //for all values in the picklist list
                options.add(new SelectOption(a.getValue(), a.getLabel())); //add the value and label to our final list
            }
            filterValuesList.set(filterSequence, options);
            filterOperatorsList.set(filterSequence, picklistOperators);
        } else if (Schema.DisplayType.Boolean == fieldType){
            filterOperatorsList.set(filterSequence, booleanOperators);
            filterValuesList.set(filterSequence, new List<SelectOption>{new SelectOption('true', 'true'), new SelectOption('false', 'false')});
        } else if(Schema.DisplayType.String == fieldType || Schema.DisplayType.Email == fieldType || Schema.DisplayType.URL == fieldType || Schema.DisplayType.Phone == fieldType){
            filterOperatorsList.set(filterSequence, stringOperators);
        } else if (Schema.DisplayType.Double == fieldType || Schema.DisplayType.Integer == fieldType || Schema.DisplayType.Date == fieldType || Schema.DisplayType.DateTime == fieldType || Schema.DisplayType.Currency == fieldType || Schema.DisplayType.Percent == fieldType || Schema.DisplayType.Time == fieldType || Schema.DisplayType.ID == fieldType){
            filterOperatorsList.set(filterSequence, numberOperators);
        }
    }
    
    public PageReference assignSortRow() {
        return null;
    }

    public void prepareFilterOperators(){
        if(filterFields.get(filterSequence) == null) {
            filterOperatorsList.set(filterSequence, emptyFields);
            filterValuesList.set(filterSequence, emptyFields);
            filterValues.set(filterSequence, '');
            return; 
        }
        Schema.DescribeFieldResult fieldDescribe;
        Schema.DisplayType fieldType;

        if(filterRecords.get(filterSequence)=='Account'){
            fieldType = Schema.SObjectType.Account.fields.getMap().get(filterFields.get(filterSequence)).getDescribe().getType();
            fieldDescribe = Schema.SObjectType.Account.fields.getMap().get(filterFields.get(filterSequence)).getDescribe();
        }else if(filterRecords.get(filterSequence)=='Address'){
            fieldType = Schema.SObjectType.Address_vod__c.fields.getMap().get(filterFields.get(filterSequence)).getDescribe().getType();
            fieldDescribe = Schema.SObjectType.Address_vod__c.fields.getMap().get(filterFields.get(filterSequence)).getDescribe();
        }else if(filterRecords.get(filterSequence)=='BrandAffiliation'){
            fieldType = Schema.SObjectType.Product_Metrics_vod__c.fields.getMap().get(filterFields.get(filterSequence).substringAfterLast('.')).getDescribe().getType();
            fieldDescribe = Schema.SObjectType.Product_Metrics_vod__c.fields.getMap().get(filterFields.get(filterSequence).substringAfterLast('.')).getDescribe();
        }else if(filterRecords.get(filterSequence)=='TSF'){
            fieldType = Schema.SObjectType.TSF_vod__c.fields.getMap().get(filterFields.get(filterSequence)).getDescribe().getType();
            fieldDescribe = Schema.SObjectType.TSF_vod__c.fields.getMap().get(filterFields.get(filterSequence)).getDescribe();
        }
        
        filterFieldType.set(filterSequence, fieldType.name());

        stringOperators = changeValuesInListForGivenField(fieldDescribe.getLabel(), stringOperators);
        filterOperatorsList.set(filterSequence, stringOperators);

        if(Schema.DisplayType.MultiPicklist == fieldType){
            List<SelectOption> options = new List<SelectOption>();
            for (Schema.PicklistEntry a : fieldDescribe.getPickListValues()) { //for all values in the picklist list
                //options.add(new SelectOption(a.getLabel(), a.getValue())); //add the value and label to our final list
                options.add(new SelectOption(a.getValue(), a.getLabel())); //add the value and label to our final list
            }
            filterValuesList.set(filterSequence, options);
            filterOperatorsList.set(filterSequence, multipicklistOperators);
        }else if(Schema.DisplayType.Picklist == fieldType){
            List<SelectOption> options = new List<SelectOption>();
            for (Schema.PicklistEntry a : fieldDescribe.getPickListValues()) { //for all values in the picklist list
                //options.add(new SelectOption(a.getLabel(), a.getValue())); //add the value and label to our final list
                options.add(new SelectOption(a.getValue(), a.getLabel())); //add the value and label to our final list
            }
            filterValuesList.set(filterSequence, options);
            filterOperatorsList.set(filterSequence, picklistOperators);
        } else if (Schema.DisplayType.Boolean == fieldType){
            filterOperatorsList.set(filterSequence, booleanOperators);
            filterValuesList.set(filterSequence, new List<SelectOption>{new SelectOption('true', 'true'), new SelectOption('false', 'false')});
        } else if(Schema.DisplayType.String == fieldType || Schema.DisplayType.Email == fieldType || Schema.DisplayType.TextArea == fieldType || Schema.DisplayType.URL == fieldType || Schema.DisplayType.Phone == fieldType){
            filterOperatorsList.set(filterSequence, stringOperators);
        } else if (Schema.DisplayType.Double == fieldType || Schema.DisplayType.Integer == fieldType || Schema.DisplayType.Date == fieldType || Schema.DisplayType.DateTime == fieldType || Schema.DisplayType.Currency == fieldType || Schema.DisplayType.Percent == fieldType || Schema.DisplayType.Time == fieldType || Schema.DisplayType.ID == fieldType){
            filterOperatorsList.set(filterSequence, numberOperators);
        }
    }

    private List<SelectOption> changeValuesInListForGivenField(String fieldLabel, List<SelectOption> listToChange) {
        return fieldLabel == 'Primary Point of Contact' ?
                new List<SelectOption>{new SelectOption('','--None--'), new SelectOption('eq','equals'), new SelectOption('ne','not equal to'), new SelectOption('c','contains'), new SelectOption('nc','does not contain'), new SelectOption('sw','starts with')} :
                new List<SelectOption>{new SelectOption('','--None--'), new SelectOption('eq','equals'), new SelectOption('ne','not equal to'), new SelectOption('lt','less than'), new SelectOption('lte','less or equal'), new SelectOption('gt','greater than'), new SelectOption('gte','greater or equal'), new SelectOption('c','contains'), new SelectOption('nc','does not contain'), new SelectOption('sw','starts with')};
    }
    
    public void prepareViewObjectFields(){
        
        // reset selected field and sort column
        viewFields.set(recordSequence, '');
        if(recordSequence == sortRow) {
            sortRow = 0;
        }
        
        Schema.DisplayType fieldType;
        List<SelectOption> options;
        if(viewRecords.get(recordSequence)=='Account'){
            options = accountFields.clone();
        }else if(viewRecords.get(recordSequence)=='Address'){
            options = addressFields.clone();
        }else if(viewRecords.get(recordSequence)=='BrandAffiliation'){ 
            options = brandAffiliationsFields.clone();
        }else if(viewRecords.get(recordSequence)=='TSF'){
            options = territoryFields.clone();
        }
        System.debug('Options === ' + options);
        System.debug('View Field === ' + viewFields);
        System.debug('Record Sequence === ' + recordSequence);
        
        prepareViewFieldsTypes();
        removeFieldsAlreadySelected();
    }
    
    public void prepareViewFieldsTypes(){
        for(Integer i = 0; i < VIEW_COLUMNS_COUNT; i++) {
            if(String.isNotEmpty(viewRecords.get(i)) && String.isNotEmpty(viewFields.get(i))){
                    Schema.DisplayType fieldType;
        
                    if(viewRecords.get(i)=='Account'){
                        fieldType = Schema.SObjectType.Account.fields.getMap().get(viewFields.get(i)).getDescribe().getType();
                    }else if(viewRecords.get(i)=='Address'){
                        fieldType = Schema.SObjectType.Address_vod__c.fields.getMap().get(viewFields.get(i)).getDescribe().getType();
                    }else if(viewRecords.get(i)=='BrandAffiliation'){
                        fieldType = Schema.SObjectType.Product_Metrics_vod__c.fields.getMap().get(viewFields.get(i).substringAfterLast('.')).getDescribe().getType();
                    }else if(viewRecords.get(i)=='TSF'){
                        fieldType = Schema.SObjectType.TSF_vod__c.fields.getMap().get(viewFields.get(i)).getDescribe().getType();
                    }
                    
                    viewFieldType.set(i, fieldType.name());
            } else {
                    viewFieldType.set(i, '');
            }
        }
    }   
    
    public void prepareViewObjectFieldsType(){
        for(Integer i = 0; i < VIEW_COLUMNS_COUNT; i++) {
            Schema.DisplayType fieldType;
            if(String.isNotEmpty(viewFields.get(i))){
                if(viewRecords.get(i)=='Account'){
                    fieldType = Schema.SObjectType.Account.fields.getMap().get(viewFields.get(i)).getDescribe().getType();
                }else if(viewRecords.get(i)=='Address'){
                    fieldType = Schema.SObjectType.Address_vod__c.fields.getMap().get(viewFields.get(i)).getDescribe().getType();
                }else if(viewRecords.get(i)=='BrandAffiliation'){
                    fieldType = Schema.SObjectType.Product_Metrics_vod__c.fields.getMap().get(viewFields.get(i).substringAfterLast('.')).getDescribe().getType();
                }else if(viewRecords.get(i)=='TSF'){
                    fieldType = Schema.SObjectType.TSF_vod__c.fields.getMap().get(viewFields.get(i)).getDescribe().getType();
                }
            }
            if(fieldType != null) {
                viewFieldType.set(i, fieldType.name());
            } else {
                viewFieldType.set(i, '');
            }
        }
    }
    
    //remove values already selected
    public PageReference removeFieldsAlreadySelected(){
        List<SelectOption>options;
        for(Integer i=0; i<VIEW_COLUMNS_COUNT; i++){
            if(viewRecords.get(i)=='Account'){
                options = accountFields.clone();
            }else if(viewRecords.get(i)=='Address'){
                options = addressFields.clone();
            }else if(viewRecords.get(i)=='BrandAffiliation'){
                options = brandAffiliationsFields.clone();
            }else if(viewRecords.get(i)=='TSF'){
                options = territoryFields.clone();
            }else{
                viewFieldsList.set(i, emptyFields);
                continue;
            }
        
            for(Integer j=0; j<VIEW_COLUMNS_COUNT; j++){
                if(String.isNotEmpty(viewRecords.get(j)) && String.isNotEmpty(viewFields.get(j)) && viewRecords.get(i)==viewRecords.get(j) && i!=j){
                    Integer indexToRemove = -1;
                     for(Integer k=0; k<options.size();k++){
                        if(options.get(k).getValue() == viewFields.get(j)){
                            indexToRemove = k;
                            break;
                        }
                    }
                    if(indexToRemove > -1){
                        options.remove(indexToRemove);
                    }
                }
            }
            viewFieldsList.set(i, options);
        }
        return null;
    }
    
    public PageReference rerenderViewFields() {
        removeFieldsAlreadySelected();
        //for(Integer i = 0; i < VIEW_COLUMNS_COUNT; i++) {
        //  recordSequence = i;
            prepareViewObjectFieldsType();
        //}
        // check if selected column can be sorted
        System.debug('JL viewRecords: '+viewRecords);
        System.debug('JL viewFields: '+viewFields);
        System.debug('JL viewFieldType: '+viewFieldType);
        System.debug('JL sortRow: '+sortRow);
        System.debug('JL viewRecords.get(sortRow): '+viewRecords.get(sortRow));
        System.debug('JL viewFields.get(sortRow): '+viewFields.get(sortRow));
        System.debug('JL viewFieldType.get(sortRow): '+viewFieldType.get(sortRow));
        if(String.isEmpty(viewRecords.get(sortRow)) || String.isEmpty(viewFields.get(sortRow)) || String.isEmpty(viewFieldType.get(sortRow)) || viewFieldType.get(sortRow) == 'TEXTAREA' || viewFieldType.get(sortRow) == 'MULTIPICKLIST') {
            sortRow = 0; 
        }
        return null;
    }

    public void prepareFilterObjectFields(){
        if(filterRecords.get(filterSequence)=='Account'){
            filterFieldsList.set(filterSequence, accountFields);
        }else if(filterRecords.get(filterSequence)=='Address'){
            filterFieldsList.set(filterSequence, addressFields);
        }else if(filterRecords.get(filterSequence)=='BrandAffiliation'){
            filterFieldsList.set(filterSequence, brandAffiliationsFields);
        }else if(filterRecords.get(filterSequence)=='TSF'){
            filterFieldsList.set(filterSequence, territoryFields);
        }else{
            filterFieldsList.set(filterSequence, emptyFields);
        }
    }
    
    public PageReference cancel(){
        return Page.GNE_SFA2_MyAccounts;
    }
    
    public PageReference deleteView(){
        delete view;
        return Page.GNE_SFA2_MyAccounts;
    }
    
    public PageReference save(){
        Boolean containsError = false;
        for(Integer i = 0; i <FILTERS_COUNT; i++){
            filterErrors.add(false);
        }
        String viewColumns='';
        for(Integer i = 0; i < viewRecords.size();i++){
            if(String.isNotEmpty(viewRecords.get(i))&&String.isNotEmpty(viewFields.get(i))){
                viewColumns+=viewRecords.get(i)+'.'+viewFields.get(i);
                viewColumns+=';';
            }
        }
        view.View_Fields_gne__c = viewColumns.removeEnd(';');
        view.Sorting_Field_gne__c = viewRecords.get(sortRow)+'.'+viewFields.get(sortRow);
        view.Filter_Statement_gne__c = '';
        view.Visibility_gne__c = 'private';
        
        String selectedRecordsTypes = '';
        for(String recordTypeDeveloperName : selectedAccountRecordTypes) {
            selectedRecordsTypes += recordTypeDeveloperName + ', '; 
        }
        view.Account_Record_Types_gne__c = selectedRecordsTypes;
        
        selectedRecordsTypes = '';
        for(String recordTypeDeveloperName : selectedPersonRecordTypes) {
            selectedRecordsTypes += recordTypeDeveloperName + ', '; 
        }
        view.Person_Record_Types_gne__c = selectedRecordsTypes;
        
        view.Page_Name_gne__c='My Accounts';
        view.Object_Type_gne__c='Account';
        
        List<ConditionItem>conditionItems = new List<ConditionItem>();
        for(Integer i = 0; i < filterFields.size();i++){
            String filterExpr = '';
            filterMessage = 'Filter is invalid';
                if(!isEmptyFilter(i)){
                    if(isValidFilter(i) && validateBrandAffiliationFilterExpression(i)) {
                        ConditionItem conditionItem;
                        if(filterRecords.get(i) == 'BrandAffiliation') {
                            conditionItem = new ConditionItem(filterRecords.get(i), filterFields.get(i).substringBefore('.'), filterFields.get(i).substringAfter('.'), filterOperators.get(i), filterValues.get(i), filterMultiValues.get(i), filterFieldType.get(i));
                        } else {
                            conditionItem = new ConditionItem(filterRecords.get(i), '', filterFields.get(i), filterOperators.get(i), filterValues.get(i), filterMultiValues.get(i), filterFieldType.get(i));
                        }
                        conditionItems.add(conditionItem);
                        filterErrors.set(i, false);
                        filterErrorMessagesMap.put(i, '');
                    } else {
                        containsError = true;
                        filterErrors.set(i, true);
                        filterErrorMessagesMap.put(i, filterMessage);
                        filterMessage = '';
                    }
                } 
        }       
                        
        if(!containsError){
            view.Filter_Statement_gne__c = JSON.serialize(conditionItems);
            System.debug('filter statement'+view.Filter_Statement_gne__c); 
            upsert view;
            
            // update selected view in user preferences
            myPreferences.Last_View_Used_gne__c = view.id;
            upsert myPreferences;
            
            return Page.GNE_SFA2_MyAccounts; 
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error while saving the view.'));
            return null;
        }
    }
    
    private Boolean isEmptyFilter(Integer index){
        if(filterRecords.get(index) == null || filterRecords.get(index) == '') {
            return true;
        } else {
            return false;
        }
    }
    
    private Boolean isValidFilter(Integer index){
        Boolean result = false;
        if(filterFields.get(index) != null && filterFields.get(index) != '') {
            if(filterOperators.get(index) == null || filterOperators.get(index) == '') {
                result = false;
            } else {
                    if (filterFieldType.get(index)=='DOUBLE'||filterFieldType.get(index)=='CURRENCY'||filterFieldType.get(index)=='PERCENT'){
                        try{
                            Double.valueOf(filterValues.get(index)).format();
                        }catch (Exception e){
                            filterMessage = filterValues.get(index) +' is not a valid ' + filterFieldType.get(index) +' type';
                            return false;
                        }
                    } else if (filterFieldType.get(index)=='INTEGER'){
                        try{
                            Integer.valueOf(filterValues.get(index)).format();
                        }catch (Exception e){
                            filterMessage = filterValues.get(index) +' is not a valid ' + filterFieldType.get(index) +' type';
                            return false;
                        }
                    } else if (filterFieldType.get(index)=='DATE'){
                        try{
                            Pattern MyPattern = Pattern.compile('(0?[1-9]|1[012])/(0?[1-9]|[12][0-9]|3[01])/[0-9]{4}');
                            Matcher MyMatcher = MyPattern.matcher(filterValues.get(index));
                            if (!MyMatcher.matches()) {
                                filterMessage = filterValues.get(index) +' is not a valid Date, Date should be in MM/DD/YYYY format' ;
                                return false;
                            }
                        }catch (Exception e){
                            filterMessage = filterValues.get(index) +' is not a valid ' + filterFieldType.get(index) +' type';
                            return false;
                        }
                    } else if (filterFieldType.get(index)=='DATETIME'){
                        try{
                            Pattern MyPattern = Pattern.compile('(0?[1-9]|1[012])/(0?[1-9]|[12][0-9]|3[01])/[0-9]{4}');
                            Matcher MyMatcher = MyPattern.matcher(filterValues.get(index));
                            if (!MyMatcher.matches()) {
                                filterMessage = filterValues.get(index) +' is not a valid Date, Date should be in MM/DD/YYYY format' ;
                                return false;
                            }
                        }catch (Exception e){
                            System.debug('EXCEPTION MESSAGE : '+e.getmessage());
                            filterMessage = filterValues.get(index) +' is not a valid ' + filterFieldType.get(index) +' type';
                            return false;
                        }
                    }else if (filterFieldType.get(index)=='TEXTAREA'){
                        filterMessage = 'Filtering by textarea fields is not possible';
                        return false;
                    }
                    result = true;
            }
        }
        return result;
    }
     
    private Boolean validateFilterExpression(Integer index){
        if(filterRecords.get(index)!=null && filterRecords.get(index)!='' && filterFields.get(index)!=null && filterFields.get(index)!='' && filterOperators.get(index)!=null && filterOperators.get(index)!='' &&
        ((filterValues.get(index)!=null && filterValues.get(index)!='') || (filterMultiValues.get(index)!=null && filterMultiValues.get(index).size()>0))){
                return true;
        }
        return false;
    }
    
    private Boolean validateBrandAffiliationFilterExpression(Integer index){
        Boolean result = true;
        if(filterRecords.get(index) == 'BrandAffiliation' && filterFields.get(index) != null) {
            String selectedBrand = filterFields.get(index).substringBefore('.');
            for(Integer i = 0; i < filterFields.size();i++){
                if(i != index && filterRecords.get(i) == 'BrandAffiliation' && filterFields.get(i) != null && filterFields.get(i) != '' && selectedBrand != filterFields.get(i).substringBefore('.')) {
                    result = false;
                    filterMessage = 'Only one brand can be used in filters';
                    break;
                }
            }
        }
        return result;
    }
    
    /*Change view column order.*/
    public void moveHigher(){
        String tmpViewRecord = viewRecords.get(rowToMove-1);
        String tmpViewField = viewFields.get(rowToMove-1);
        List<SelectOption> tmpFields = viewFieldsList.get(rowToMove-1);
        
        viewFieldsList.set(rowToMove-1, viewFieldsList.get(rowToMove));
        viewRecords.set(rowToMove-1, viewRecords.get(rowToMove));
        viewFields.set(rowToMove-1, viewFields.get(rowToMove));
        
        viewFieldsList.set(rowToMove, tmpFields);
        viewRecords.set(rowToMove, tmpViewRecord);
        viewFields.set(rowToMove, tmpViewField);
        
        if(sortRow == rowToMove) {
            sortRow = sortRow - 1;
        } else if(sortRow == rowToMove - 1) {
            sortRow = sortRow + 1;
        }
        
        prepareViewFieldsTypes();
    }

    public void deleteFilter(){
        filterRecords.set(filterToDelete, null);
        filterFields.set(filterToDelete, null);
        filterOperators.set(filterToDelete, null);
        filterValues.set(filterToDelete, null);
        filterMultiValues.set(filterToDelete, null);
        
        
        filterErrorMessagesMap.remove(filterToDelete);
        filterErrors.set(filterToDelete, false);
        
        filterFieldsList.set(filterToDelete, emptyFields);
        filterOperatorsList.set(filterToDelete, emptyFields);
        filterValuesList.set(filterToDelete, emptyFields);
    }

    public void deleteRow(){
        viewRecords.set(rowToDelete,'');
        viewFields.set(rowToDelete, '');
        viewFieldsList.set(rowToDelete, emptyFields);
        removeFieldsAlreadySelected();
        if(sortRow == rowToDelete){
            sortRow = 0;
        }
        prepareViewFieldsTypes();
    }
        
    private void initializeAccountRecordTypes(){
        personRecordTypesList = new List<SelectOption>();
        accountRecordTypesList = new List<SelectOption>();
        
        Map<Id, Schema.RecordTypeInfo> recordTypeInfos = Schema.SObjectType.Account.getRecordTypeInfosByID();
        for(RecordType rt: [SELECT Id, Name, IsPersonType, DeveloperName FROM RecordType WHERE SobjectType = 'Account' and isActive=true]){
            //if(recordTypeInfos.get(rt.Id).available){
                if(rt.IsPersonType){
                    personRecordTypesList.add(new SelectOption(rt.DeveloperName, recordTypeInfos.get(rt.Id).Name));
                }else{
                    accountRecordTypesList.add(new SelectOption(rt.DeveloperName, recordTypeInfos.get(rt.Id).Name));
                }
            //}
        }
        personRecordTypesList = GNE_SFA2_Util.sortOptionList(personRecordTypesList);
        accountRecordTypesList = GNE_SFA2_Util.sortOptionList(accountRecordTypesList);
    }   
     
    private List<SelectOption>getProfiles(){
        List<SelectOption>profiles = new List<SelectOption>();
        for(Profile prof: [select Id, Name FROM Profile ORDER BY Name]){
            profiles.add(new SelectOption(prof.id, prof.Name));
        }
        return GNE_SFA2_Util.sortOptionList(profiles);
    }
    
    private List<SelectOption> getBrandAffiliationObjectsFields(List<String> availableFields, Map<String, Schema.SObjectField> objectFieldsDescribe){
        List<My_Setup_Products_vod__c> mySetupProducts = [ SELECT Id, Name, Product_vod__c, Product_vod__r.Name FROM My_Setup_Products_vod__c WHERE OwnerId = :UserInfo.getUserId() AND Product_vod__r.Product_Type_vod__c = 'Detail' ORDER BY Name LIMIT 20 ];
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--None--'));
        for(My_Setup_Products_vod__c mySetpProduct : mySetupProducts) {
            for(String fieldName: availableFields){
                if(objectFieldsDescribe.get(fieldName).getDescribe().isAccessible()){
                    options.add(new SelectOption(mySetpProduct.Product_vod__c+'.'+fieldName, mySetpProduct.Product_vod__r.Name + ' - ' + objectFieldsDescribe.get(fieldName).getDescribe().getLabel()));
                }
            }
        }
        return GNE_SFA2_Util.sortOptionList(options);
    }
    private List<SelectOption> getObjectsFields(List<String>availableFields, Map<String, Schema.SObjectField> objectFieldsDescribe){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--None--'));
        
        for(String fieldName : availableFields){
            if(objectFieldsDescribe.get(fieldName).getDescribe().isAccessible()){
                options.add(new SelectOption(fieldName,objectFieldsDescribe.get(fieldName).getDescribe().getLabel()));
            }
        }
        
        return GNE_SFA2_Util.sortOptionList(options);
    }
    
    public void setViewRecord0(String name){
        if(name == null) name ='';
        viewRecords.set(0, name);
    }
    
    public String getViewRecord0(){
        return viewRecords.get(0);
    }
    
    public void setViewRecord1(String name){
        if(name == null) name ='';
        viewRecords.set(1, name);
    }
    
    public String getViewRecord1(){
        return viewRecords.get(1);
    }
    
    public void setViewRecord2(String name){
        if(name == null) name ='';
        viewRecords.set(2, name);
    }
    
    public String getViewRecord2(){
        return viewRecords.get(2);
    }
    
    public void setViewRecord3(String name){
        if(name == null) name ='';
        viewRecords.set(3, name);
    }
    
    public String getViewRecord3(){
        return viewRecords.get(3);
    }
    
    public void setViewRecord4(String name){
        if(name == null) name ='';
        viewRecords.set(4, name);
    }
    
    public String getViewRecord4(){
        return viewRecords.get(4);
    }
    
    public void setViewRecord5(String name){
        if(name == null) name ='';
        viewRecords.set(5, name);
    }
    
    public String getViewRecord5(){
        return viewRecords.get(5);
    }
    public void setViewRecord6(String name){
        if(name == null) name ='';
        viewRecords.set(6, name);
    }
    
    public String getViewRecord6(){
        return viewRecords.get(6);
    }
    
    public void setViewRecord7(String name){
        if(name == null) name ='';
        viewRecords.set(7, name);
    }
    
    public String getViewRecord7(){
        return viewRecords.get(7);
    }
    
    public void setViewRecord8(String name){
        if(name == null) name ='';
        viewRecords.set(8, name);
    }
    
    public String getViewRecord8(){
        return viewRecords.get(8);
    }
    public void setViewRecord9(String name){
        if(name == null) name ='';
        viewRecords.set(9, name);
    }
    
    public String getViewRecord9(){
        return viewRecords.get(9);
    }
    
    public void setViewField0(String name){
        if(name == null) name ='';
        viewFields.set(0, name);
    }
    
    public String getViewField0(){
        return viewFields.get(0);
    }
    
    public void setViewField1(String name){
        if(name == null) name ='';
        viewFields.set(1, name);
    }
    
    public String getViewField1(){
        return viewFields.get(1);
    }
    
    public void setViewField2(String name){
        if(name == null) name ='';
        viewFields.set(2, name);
    }
    
    public String getViewField2(){
        return viewFields.get(2);
    }
    
    public void setViewField3(String name){
        if(name == null) name ='';
        viewFields.set(3, name);
    }
    
    public String getViewField3(){
        return viewFields.get(3);
    }
    
    public void setViewField4(String name){
        if(name == null) name ='';
        viewFields.set(4, name);
    }
    
    public String getViewField4(){
        return viewFields.get(4);
    }
    
    public void setViewField5(String name){
        if(name == null) name ='';
        viewFields.set(5, name);
    }
    
    public String getViewField5(){
        return viewFields.get(5);
    }
    
    public void setViewField6(String name){
        if(name == null) name ='';
        viewFields.set(6, name);
    }
    
    public String getViewField6(){
        return viewFields.get(6);
    }
    
    public void setViewField7(String name){
        if(name == null) name ='';
        viewFields.set(7, name);
    }
    
    public String getViewField7(){
        return viewFields.get(7);
    }
    
    public void setViewField8(String name){
        if(name == null) name ='';
        viewFields.set(8, name);
    }
    
    public String getViewField8(){
        return viewFields.get(8);
    }
    
    public void setViewField9(String name){
        if(name == null) name ='';
        viewFields.set(9, name);
    }
    
    public String getViewField9(){
        return viewFields.get(9);
    }
    
    public void setFilterRecord0(String name){
        filterRecords.set(0, name);
    }
    
    public String getFilterRecord0(){
        return filterRecords.get(0);
    }
    
    public void setFilterRecord1(String name){
        filterRecords.set(1, name);
    }
    
    public String getFilterRecord1(){
        return filterRecords.get(1);
    }
    
    public void setFilterRecord2(String name){
        filterRecords.set(2, name);
    }
    
    public String getFilterRecord2(){
        return filterRecords.get(2);
    }
    
    public void setFilterRecord3(String name){
        filterRecords.set(3, name);
    }
    
    public String getFilterRecord3(){
        return filterRecords.get(3);
    }
    
    public void setFilterRecord4(String name){
        filterRecords.set(4, name);
    }
    
    public String getFilterRecord4(){
        return filterRecords.get(4);
    }
    
    public void setFilterField0(String name){
        filterFields.set(0, name);
    }
    
    public String getFilterField0(){
        return filterFields.get(0);
    }
    
    public void setFilterField1(String name){
        filterFields.set(1, name);
    }
    
    public String getFilterField1(){
        return filterFields.get(1);
    }
    
    public void setFilterField2(String name){
        filterFields.set(2, name);
    }
    
    public String getFilterField2(){
        return filterFields.get(2);
    }
    
    public void setFilterField3(String name){
        filterFields.set(3, name);
    }
    
    public String getFilterField3(){
        return filterFields.get(3);
    }
    
    public void setFilterField4(String name){
        filterFields.set(4, name);
    }
    
    public String getFilterField4(){
        return filterFields.get(4);
    }
    
    public void setFilterField5(String name){
        filterFields.set(5, name);
    }
    
    public void setFilterOperator0(String name){
        filterOperators.set(0, name);
    }
    
    public String getFilterOperator0(){
        return filterOperators.get(0);
    }
    
    public void setFilterOperator1(String name){
        filterOperators.set(1, name);
    }
    
    public String getFilterOperator1(){
        return filterOperators.get(1);
    }
    
    public void setFilterOperator2(String name){
        filterOperators.set(2, name);
    }
    
    public String getFilterOperator2(){
        return filterOperators.get(2);
    }
    
    public void setFilterOperator3(String name){
        filterOperators.set(3, name);
    }
    
    public String getFilterOperator3(){
        return filterOperators.get(3);
    }
    
    public void setFilterOperator4(String name){
        filterOperators.set(4, name);
    }
    
    public String getFilterOperator4(){
        return filterOperators.get(4);
    }
    
    public void setFilterOperator5(String name){
        filterOperators.set(5, name);
    }
    
    public void setFilterValue0(String name){
        filterValues.set(0, name);
    }
    
    public String getFilterValue0(){
        return filterValues.get(0);
    }
    
    public void setFilterValue1(String name){
        filterValues.set(1, name);
    }
    
    public String getFilterValue1(){
        return filterValues.get(1);
    }
    
    public void setFilterValue2(String name){
        filterValues.set(2, name);
    }
    
    public String getFilterValue2(){
        return filterValues.get(2);
    }
    
    public void setFilterValue3(String name){
        filterValues.set(3, name);
    }
    
    public String getFilterValue3(){
        return filterValues.get(3);
    }
    
    public void setFilterValue4(String name){
        filterValues.set(4, name);
    }
    
    public String getFilterValue4(){
        return filterValues.get(4);
    }
    
    public void setFilterValue5(String name){
        filterValues.set(5, name);
    }
    
    public List<String> getFilterMultiValues0(){
        return filterMultiValues.get(0);
    }
    
    public void setFilterMultiValues0(List<String> values){
        filterMultiValues.set(0, values);
    }
    
    public List<String> getFilterMultiValues1(){
        return filterMultiValues.get(1);
    }
    
    public void setFilterMultiValues1(List<String> values){
        filterMultiValues.set(1, values);
    }
    
    public List<String> getFilterMultiValues2(){
        return filterMultiValues.get(2);
    }
    
    public void setFilterMultiValues2(List<String> values){
        filterMultiValues.set(2, values);
    }
    
    public List<String> getFilterMultiValues3(){
        return filterMultiValues.get(3);
    }
    
    public void setFilterMultiValues3(List<String> values){
        filterMultiValues.set(3, values);
    }
    
    public List<String> getFilterMultiValues4(){
        return filterMultiValues.get(4);
    }
    
    public void setFilterMultiValues4(List<String> values){
        filterMultiValues.set(4, values);
    }
    
    public class ConditionItem{
        public String record {get; set;}
        public String brand {get; set;}
        public String field {get; set;}
        public String operator {get; set;}
        public String value {get; set;}
        public List<String> multiValue {get; set;}
        public String valueType{get; set;}
    
        public ConditionItem(String record, String brand, String field, String operator, String value, List<String> multiValue, String valueType){
            this.record = record;
            this.brand = brand;
            this.field = field;
            this.operator = operator;
            this.value = value;
            this.multiValue = multiValue;
            this.valueType = valueType;
        }
    }
}