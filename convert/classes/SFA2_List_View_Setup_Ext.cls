public with sharing class SFA2_List_View_Setup_Ext {
    /*public static final Integer VIEW_COLUMNS_COUNT = 10;
    public static final Integer FILTERS_COUNT = 5;
    
    public List<SelectOption> records{get; set;}
    
    public List<SelectOption> stringOperators {get; set;}
    public List<SelectOption> booleanOperators {get; set;}
    public List<SelectOption> picklistOperators {get; set;}
    public List<SelectOption> multipicklistOperators {get; set;}
    public List<SelectOption> numberOperators {get; set;}
    
    public Integer recordSequence {get; set;}
    public Integer filterSequence {get; set;}
    
    public String sortField {get; set;}
    public Integer sortRow {get; set;}
    public Boolean deleteEnabled { get; set; }
    public Boolean filterByOwner { get; set; }
   
    public List<String> viewFields {get; set;}
    private List<String> filterFields {get; set;}
    private List<String> filterOperators {get; set;}
    public List<String> filterErrorMessages {get; set;}
    public List<Boolean> filterErrors {get; set;}

    private List<String> filterValues {get; set;}
    private List<List<String>> filterMultiValues {get; set;}
    
    public List<String> filterFieldType {get; set;}
    private List<SelectOption> emptyFields {get; set;}
    
    public List<SelectOption> objectViewFields {get; set;}
    public List<SelectOption> objectFilterFields {get; set;}
    
    public List<List<SelectOption>> viewFieldsList {get; set;}
    public List<List<SelectOption>> filterFieldsList {get; set;}
    public List<List<SelectOption>> filterOperatorsList {get; set;}
    public List<List<SelectOption>> filterValuesList {get; set;}
    public List<SelectOption> visibilityList {get; set;}
    public String visibility {get; set;}
    public List<SelectOption> brandsList {get; set;}

    public List<SelectOption> profilesList {get; set;}
    public List<Id> selectedProfiles {get; set;}
    
    public Integer rowToMove {get; set;}
    public Integer filterToDelete {get; set;}
    public Integer rowToDelete {get; set;}
    
    public GNE_SFA2_My_Accounts_View_Setup__c view {get; set;}
    
    private GNE_SFA2_My_Accounts_Setttings__c settings;
    
    private ApexPages.StandardController controller;
    private Map<String, Schema.SObjectType> globalDescribe;
    private String retURL;
    */
    public SFA2_List_View_Setup_Ext(ApexPages.StandardController ctrl) {
        /*this.controller = ctrl;
        globalDescribe = Schema.getGlobalDescribe();
        
        controller.addFields(new List<String>{'Page_Name_gne__c', 'ObjectType_gne__c', 'Account_Record_Types_gne__c', 'Person_Record_Types_gne__c' , 'View_Fields_gne__c','Filter_Statement_gne__c', 'View_Name_gne__c', 'Visibility_gne__c', 'Profiles_gne__c', 'Sorting_Field_gne__c', 'CreatedById', 'OwnerId'});
        view = (GNE_SFA2_My_Accounts_View_Setup__c)controller.getRecord();
        
        if(view.CreatedById == UserInfo.getUserId()) {
          deleteEnabled = true;
        } else {
          deleteEnabled = false;
        }
                
        picklistOperators = new List<SelectOption>{new SelectOption('','--None--'), new SelectOption('inc','equals'), new SelectOption('ecl','not equal to')};
        multipicklistOperators = new List<SelectOption>{new SelectOption('','--None--'), new SelectOption('inc','includes'), new SelectOption('ecl','excludes')};
        booleanOperators = new List<SelectOption>{new SelectOption('','--None--'), new SelectOption('eq','equals'), new SelectOption('ne','not equals')};
        stringOperators = new List<SelectOption>{new SelectOption('','--None--'), new SelectOption('eq','equals'), new SelectOption('ne','not equal to'), new SelectOption('lt','less than'), new SelectOption('lte','less or equal'), new SelectOption('gt','greater than'), new SelectOption('gte','greater or equal'), new SelectOption('c','contains'), new SelectOption('nc','doesn not contain'), new SelectOption('sw','starts with')};
        numberOperators = new List<SelectOption>{new SelectOption('','--None--'), new SelectOption('eq','equals'), new SelectOption('ne','not equal to'), new SelectOption('lt','less than'), new SelectOption('lte','less or equal'), new SelectOption('gt','greater than'), new SelectOption('gte','greater or equal')};
        visibilityList = new List<SelectOption>{new SelectOption('private','This view is hidden from all users'), new SelectOption('public','This view is accessible by all users'), new SelectOption('restricted','This view is accessible by profile')};
        selectedProfiles = new List<Id>();
        
        profilesList = getProfiles();
        
        visibility = 'private';
        brandsList = new List<SelectOption>();
        emptyFields = new List<SelectOption>{new SelectOption('','--None--')};
        
        filterMultiValues = new List<List<String>>();

        viewFieldsList = new List<List<SelectOption>>();
        filterFieldsList = new List<List<SelectOption>>();
        filterOperatorsList = new List<List<SelectOption>>();
        filterValuesList = new List<List<SelectOption>>();
        
        viewFields = new List<String>();
        filterFields = new List<String>();
        filterOperators = new List<String>();
        filterValues = new List<String>();
        filterFieldType = new List<String>();
        filterErrorMessages = new List<String>();
        filterErrors = new List<Boolean>();
        
        settings = [Select Account_View_Columns_gne__c, Address_View_Columns_gne__c, Brand_Affiliation_View_Columns_gne__c, PageSize_gne__c, Privileged_Profiles_gne__c, TSF_View_Columns_gne__c FROM GNE_SFA2_My_Accounts_Setttings__c limit 1];
        
        if(view.ObjectType_gne__c == null) {
             view.ObjectType_gne__c = System.currentPagereference().getParameters().get('objectType');
        }
        
        if(view.Page_Name_gne__c == null) {
            view.Page_Name_gne__c = System.currentPagereference().getParameters().get('pageName');
        }
        
        retURL = System.currentPagereference().getParameters().get('retURL');
        
        objectViewFields = getObjectsViewFields(globalDescribe.get(view.ObjectType_gne__c).getDescribe().fields.getMap());
        objectFilterFields = getObjectsFilterFields(globalDescribe.get(view.ObjectType_gne__c).getDescribe().fields.getMap());
         
        for(Integer i = 0; i <VIEW_COLUMNS_COUNT; i++){
            viewFieldsList.add(emptyFields); 
            viewFields.add('');
        }
        
        for(Integer i = 0; i <FILTERS_COUNT; i++){
            filterErrorMessages.add('');
            filterErrors.add(false);
            filterMultiValues.add(new List<String>());
            filterOperators.add('');
            filterFields.add(''); 
            filterValues.add(''); 
            filterFieldType.add(Schema.DisplayType.STRING.name());
            filterFieldsList.add(emptyFields);
            filterOperatorsList.add(emptyFields);
            filterValuesList.add(emptyFields);
        }
        
        initFilters();
        
        if(view.Id!=null){
            prepareEditForm((GNE_SFA2_My_Accounts_View_Setup__c)controller.getRecord());
        }else{
            recordSequence = 0;
            filterFields.set(0, 'name');
            initViewFields();
            sortRow = 0;
        }*/
    }
    
    /*private void prepareEditForm(GNE_SFA2_My_Accounts_View_Setup__c view){
        visibility = view.Visibility_gne__c;
        if(visibility == 'restricted' && String.isNotEmpty(view.Profiles_gne__c)){
            for(Id profileId: view.Profiles_gne__c.split(',')){
                selectedProfiles.add(profileId);
            }
        }
        
        List<String> columns = view.View_Fields_gne__c.split(';', 0);
        for(Integer i=0; i< columns.size(); i++){
            this.recordSequence = i;
            prepareViewObjectFields();
            viewFields.set(i, columns.get(i));
          viewFieldsList.set(i, objectViewFields.clone());
            if(viewFields.get(i)==view.Sorting_Field_gne__c){
                sortRow = i;
            }
        }
        if(columns.size() < VIEW_COLUMNS_COUNT - 1) {
          viewFieldsList.set(columns.size(), objectViewFields.clone());
        }
        
        if(String.isNotEmpty(view.Filter_Statement_gne__c)){
            List<String> filtersExpressions = view.Filter_Statement_gne__c.split(';', 0);
            for(Integer i=0; i< filtersExpressions.size(); i++){
                if(filtersExpressions[i].indexOf('OwnerId') != -1) {
                    filterByOwner = true;
                    break;
                }
                this.filterSequence = i;
                String filtersExpression = filtersExpressions.get(i);
                String operatorNOT = '';
                if(filtersExpression.startsWith ('(NOT ') && filtersExpression.endsWith (')')) {
                    filtersExpression = filtersExpression.remove('(NOT ');
                    filtersExpression = filtersExpression.removeEnd(')');
                    operatorNOT = 'NOT ';
                }
                
                System.debug('Filters Expression === ' + filtersExpression );
                
                String field = filtersExpression.substring(0,  filtersExpression.indexOf(' '));
                filtersExpression = filtersExpression.removeStart(field+' ');
                System.debug('Filters Expression === ' + filtersExpression );
                filterFields.set(i, field);
                prepareFilterOperators();
    
                String soqlOperator = filtersExpression.substring(0,  filtersExpression.indexOf(' '));
                filtersExpression = filtersExpression.removeStart(soqlOperator+' ');
                if(soqlOperator=='NOT'){
                    String operatorPart2 = filtersExpression.substring(0, filtersExpression.indexOf(' ') );
                    filtersExpression = filtersExpression.removeStart(operatorPart2+' ');
                    soqlOperator += ' '+operatorPart2; 
                }
                
                soqlOperator = operatorNOT + soqlOperator;
                
                String value = filtersExpression;
                filterOperators.set(i,getOperatorName(soqlOperator, value));
                
                if(filterFieldType.get(i)=='MULTIPICKLIST' || filterFieldType.get(i)=='PICKLIST'){
                    value = value.removeStart('(');
                    value = value.removeEnd(')');
                    for(String val: value.split(', ')){
                        system.debug(val.removeStart('\'').removeEnd('\''));
                        filterMultiValues[i].add(val.removeStart('\'').removeEnd('\''));
                    }
                }else{
                    value = value.removeStart('\'');
                    value = value.removeEnd('\'');
                    value = value.removeStart('%');
                    value = value.removeEnd('%');
                    filterValues.set(i,value);
                }
            }
        }
    }
    
    public Boolean getHasAdditionalPriviliges(){
        String profileName = [SELECT Id, Name FROM Profile WHERE Id = :Userinfo.getProfileId()].Name;
        String privilegedProfiles = settings.Privileged_Profiles_gne__c;
        if(privilegedProfiles!=null){
            for(String privilegedProfile : privilegedProfiles.split(',')){
                if(privilegedProfile == profileName){
                    return true;
                }
            }
        }
        return false;
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
        
        filterOperatorsList.set(filterSequence, stringOperators);
        fieldType = globalDescribe.get(view.ObjectType_gne__c).getDescribe().fields.getMap().get(filterFields.get(filterSequence)).getDescribe().getType();
        fieldDescribe = globalDescribe.get(view.ObjectType_gne__c).getDescribe().fields.getMap().get(filterFields.get(filterSequence)).getDescribe();
        
        
        filterFieldType.set(filterSequence, fieldType.name());
        
        if(Schema.DisplayType.MultiPicklist == fieldType){
            List<SelectOption> options = new List<SelectOption>();
            for (Schema.PicklistEntry a : fieldDescribe.getPickListValues()) { //for all values in the picklist list
                options.add(new SelectOption(a.getLabel(), a.getValue().trim())); //add the value and label to our final list
            }
            filterValuesList.set(filterSequence, options);
            filterOperatorsList.set(filterSequence, multipicklistOperators);
        }else if(Schema.DisplayType.Picklist == fieldType){
            List<SelectOption> options = new List<SelectOption>();
            for (Schema.PicklistEntry a : fieldDescribe.getPickListValues()) { //for all values in the picklist list
                options.add(new SelectOption(a.getLabel(), a.getValue())); //add the value and label to our final list
            }
            filterValuesList.set(filterSequence, options);
            filterOperatorsList.set(filterSequence, picklistOperators);
        } else if (Schema.DisplayType.Boolean == fieldType){
            filterOperatorsList.set(filterSequence, booleanOperators);
            filterValuesList.set(filterSequence, new List<SelectOption>{new SelectOption('true', 'true'), new SelectOption('false', 'false')});
        } else if(Schema.DisplayType.String == fieldType || Schema.DisplayType.Email == fieldType || Schema.DisplayType.TextArea == fieldType || Schema.DisplayType.URL == fieldType){
            filterOperatorsList.set(filterSequence, stringOperators);
        } else if (Schema.DisplayType.Double == fieldType || Schema.DisplayType.Integer == fieldType || Schema.DisplayType.Date == fieldType || Schema.DisplayType.DateTime == fieldType || Schema.DisplayType.Currency == fieldType || Schema.DisplayType.Percent == fieldType || Schema.DisplayType.Phone == fieldType || Schema.DisplayType.Time == fieldType || Schema.DisplayType.ID == fieldType){
            filterOperatorsList.set(filterSequence, numberOperators);
        }
    }
    
    private void initViewFields() {
        List<SelectOption> options;
        options = objectViewFields.clone();
        viewFieldsList.set(0, options);
        viewFieldsList.set(1, options);
        removeFieldsAlreadySelected();
    }
    
    public PageReference prepareViewObjectFields(){
        List<SelectOption> options;
        options = objectViewFields.clone();
        Integer lastIndex = 0;
        for(Integer i =  viewFields.size() - 2; i > 0; i--) {
            if(viewFields.get(i) != null) {
                lastIndex = i;
                break;
            }
        }
        viewFieldsList.set(lastIndex + 1, options);
        
        removeFieldsAlreadySelected();
        return null;
    }
    
    //remove values already selected
    public void removeFieldsAlreadySelected(){
        List<SelectOption> options;
        for(Integer i=0; i<VIEW_COLUMNS_COUNT; i++){
            options = objectViewFields.clone();
            if(viewFieldsList.get(i).size() > 1) {
                for(Integer j=0; j<VIEW_COLUMNS_COUNT; j++){
                    if(String.isNotEmpty(viewFields.get(j)) && i!=j){
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
            if(viewFields[i] == null) {
                viewFields[i] = '';
            }
        }
    }
    
    private void initFilters()  {
        for(Integer i = 0; i < FILTERS_COUNT; i++) {
            filterFieldsList.set(i, objectFilterFields);
        }
    }
    
    private String addOwnerFilter(String queryString) {
        String result = queryString;
        if(filterByOwner) {
            result += 'OwnerId = \'' + UserInfo.getUserId() + '\';';
        }
        return result;
    }
    
    public PageReference save(){
        Boolean containsError = false;
        for(Integer i = 0; i <FILTERS_COUNT; i++){
            filterErrors.add(false);
        }
        String viewColumns='';
        for(Integer i = 0; i < viewFields.size();i++){
            if(String.isNotEmpty(viewFields.get(i))){
                viewColumns+= viewFields.get(i) + ';';
            }
        }
        view.View_Fields_gne__c = viewColumns.removeEnd(';');
        view.Sorting_Field_gne__c = viewFields.get(sortRow);
        view.Filter_Statement_gne__c='';
        view.Visibility_gne__c=visibility;
        view.Account_Record_Types_gne__c='';
        view.Person_Record_Types_gne__c='';
        
        view.Profiles_gne__c='';
        if(visibility=='restricted'){
            for(Id profile: selectedProfiles){
                view.Profiles_gne__c += profile+',';
            }
            view.Profiles_gne__c = view.Profiles_gne__c.removeEnd(',');
        }
        System.debug('filter viewFields: ' + filterFields);
        for(Integer i = 0; i < filterFields.size();i++){
            String filterExpr = '';
            if(isNotEmptyFilter(i)){
                if(isValidFilter(i)) {
                    filterExpr += filterFields.get(i);
                    
                    if(filterFieldType.get(i)=='PICKLIST'){
                        if(filterOperators.get(i)=='inc'){
                            filterExpr += ' IN '+GNE_SFA2_Util.createInListForQuery(filterMultiValues.get(i));
                        }else if(filterOperators.get(i)=='ecl'){
                            filterExpr += ' NOT IN '+GNE_SFA2_Util.createInListForQuery(filterMultiValues.get(i));
                        }
                    }else if(filterFieldType.get(i)=='MULTIPICKLIST'){
                        if(filterOperators.get(i)=='inc'){
                            filterExpr += ' INCLUDES '+GNE_SFA2_Util.createInListForQuery(filterMultiValues.get(i));
                        }else if(filterOperators.get(i)=='ecl'){
                            filterExpr += ' EXCLUDES '+GNE_SFA2_Util.createInListForQuery(filterMultiValues.get(i));
                        }
                    }else if(filterFieldType.get(i)=='BOOLEAN') {
                        if(filterOperators.get(i)=='eq'){
                            filterExpr += ' = '+filterValues.get(i);
                        }else if(filterOperators.get(i)=='ne'){
                            filterExpr += ' != '+filterValues.get(i);
                        }
                    }else if(filterFieldType.get(i)=='STRING'||filterFieldType.get(i)=='EMAIL'||filterFieldType.get(i)=='TEXTAREA'||filterFieldType.get(i)=='URL') {
                        if(filterOperators.get(i)=='eq'){
                            filterExpr += ' = \''+filterValues.get(i)+'\'';
                        }else if(filterOperators.get(i)=='ne'){
                            filterExpr += ' != \''+filterValues.get(i)+'\'';
                        }else if(filterOperators.get(i)=='lt'){
                            filterExpr += ' < \''+filterValues.get(i)+'\'';
                        }else if(filterOperators.get(i)=='lte'){
                            filterExpr += ' <= \''+filterValues.get(i)+'\'';
                        }else if(filterOperators.get(i)=='gt'){
                            filterExpr += ' > \''+filterValues.get(i)+'\'';
                        }else if(filterOperators.get(i)=='gte'){
                            filterExpr += ' >= '+filterValues.get(i)+'\'';
                        }else if(filterOperators.get(i)=='c'){
                            filterExpr += ' LIKE \'%'+filterValues.get(i)+'%\'';
                        }else if(filterOperators.get(i)=='nc'){
                            filterExpr = '(NOT ' +filterExpr+ ' LIKE \'%'+filterValues.get(i)+'%\')';
                        }else if(filterOperators.get(i)=='sw'){
                            filterExpr += ' LIKE \''+filterValues.get(i)+'%\'';
                        }                   
                    }else {
                        String value='';                    
                            try{
                                if (filterFieldType.get(i)=='DOUBLE'||filterFieldType.get(i)=='CURRENCY'||filterFieldType.get(i)=='PERCENT'){
                                    value = Double.valueOf(filterValues.get(i)).format();
                                } else if(filterFieldType.get(i)=='INTEGER'){
                                    value = Integer.valueOf(filterValues.get(i)).format();
                                } else if(filterFieldType.get(i)=='DATE'){
                                    value = Date.valueOf(filterValues.get(i)).format();
                                }else if(filterFieldType.get(i)=='DATETIME'){
                                    value = DateTime.valueOf(filterValues.get(i)).format();
                                }else if(filterFieldType.get(i)=='ID'){
                                    Id tmpId = filterValues.get(i);
                                    value = tmpId;
                                }else{
                                    value = filterValues.get(i);
                                }
                            }catch(Exception e){
                                containsError = true;
                                filterErrors.set(i, true);
                                filterErrorMessages.set(i, e.getMessage());
                            }
                        if(filterOperators.get(i)=='eq'){
                            filterExpr += ' = \''+value+'\'';
                        }else if(filterOperators.get(i)=='ne'){
                            filterExpr += ' != \''+value+'\'';
                        }else if(filterOperators.get(i)=='lt'){
                            filterExpr += ' < \''+value+'\'';
                        }else if(filterOperators.get(i)=='lte'){
                            filterExpr += ' <= \''+value+'\'';
                        }else if(filterOperators.get(i)=='gt'){
                            filterExpr += ' > \''+value+'\'';
                        }else if(filterOperators.get(i)=='gte'){
                            filterExpr += ' >= \''+value+'\'';
                        }
                    }                       
                    if(!filterErrors.get(i)){
                        view.Filter_Statement_gne__c+=filterExpr +';';
                    }
                } else {
                    containsError = true;
                    filterErrors.set(i, true);
                    filterErrorMessages.set(i, 'Filter is invalid');
                }
            }
        }
        // add owner filter
        view.Filter_Statement_gne__c = addOwnerFilter(view.Filter_Statement_gne__c);
        
        if(!containsError){
            view.Filter_Statement_gne__c = view.Filter_Statement_gne__c.removeEnd(';');
            upsert view;
            PageReference retPageRef = new PageReference(retURL);
            retPageRef.setRedirect(true);
            return retPageRef;
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error while saving the view.'));
            return null;
        }
    }
    
    private String getOperatorName(String soqlOperator, String valueExpression){
        String operatorName;
        if(soqlOperator == '='){
            operatorName = 'eq';
        }else if(soqlOperator == '!='){
            operatorName = 'ne';
        }else if(soqlOperator == '<'){
            operatorName = 'lt';
        }else if(soqlOperator== '<='){
            operatorName = 'lte';
        }else if(soqlOperator == '>'){
            operatorName = 'gt';
        }else if(soqlOperator == '>='){
            operatorName = 'gte';
        }else if(soqlOperator == 'LIKE' && valueExpression.startsWith('\'%') && valueExpression.endsWith('%\'')){
            operatorName = 'c';
        }else if(soqlOperator == 'LIKE' && valueExpression.endsWith('\'%') ){
            operatorName = 'sw';
        }else if(soqlOperator == 'NOT LIKE'){
            operatorName = 'nc';
        }else if(soqlOperator == 'IN' || soqlOperator == 'INCLUDES'){
            operatorName = 'inc';
        }else if(soqlOperator == 'NOT IN' || soqlOperator == 'EXCLUDES'){
            operatorName = 'enc';
        }
        return operatorName;
    }
    
    private Boolean isNotEmptyFilter(Integer index){
        if(filterFields.get(index) != null && filterFields.get(index) != '') {
                return true;
        } else {
            return false;
        }
    }
    
    private Boolean isValidFilter(Integer index){
        Boolean result = true;
        if(filterFields.get(index) != null && filterFields.get(index) != '') {
            if(filterOperators.get(index) == null || filterOperators.get(index) == '') {
                result = false;
            } else {
                if(((filterValues.get(index)!=null && filterValues.get(index)!='') || (filterMultiValues.get(index)!=null && filterMultiValues.get(index).size()>0))) {
                    result = true;
                } else {
                    result = false;
                }
            }
        }
        return result;
    }
    
    /*Change view column order.*
    public void moveHigher(){
        String tmpViewField = viewFields.get(rowToMove-1);
        List<SelectOption> tmpFields = viewFieldsList.get(rowToMove-1);
        
        viewFieldsList.set(rowToMove-1, viewFieldsList.get(rowToMove));
        viewFields.set(rowToMove-1, viewFields.get(rowToMove));
        
        viewFieldsList.set(rowToMove, tmpFields);
        viewFields.set(rowToMove, tmpViewField);
    }

    public PageReference deleteFilter(){
        filterFields.set(filterToDelete, null);
        filterOperators.set(filterToDelete, '');
        filterValues.set(filterToDelete, null);
        
        filterMultiValues.set(filterToDelete, null);
        filterErrorMessages.set(filterToDelete, null);
        filterErrors.set(filterToDelete, false);
        filterOperatorsList.set(filterToDelete, emptyFields);
        filterValuesList.set(filterToDelete, emptyFields);
        
        return null;
    }

    public void deleteRow(){
        viewFields.set(rowToDelete, '');
        reloadVisibleFieldsOnDelete(rowToDelete);
        removeFieldsAlreadySelected();
        if(sortRow == rowToDelete){
            sortRow = 0;
        }
    }
    
    private void reloadVisibleFieldsOnDelete(Integer deletedRowNumber) {
        Integer lastFilterIndex = 0;
        for(Integer i = viewFields.size() - 1 ; i >= 0; i--) {
            if(String.isNotEmpty(viewFields.get(i))) {
                lastFilterIndex = i;
                break;
            }
        }
        System.debug('kwiatkol last index ' + lastFilterIndex );
        System.debug('kwiatkol del row number ' + deletedRowNumber );
        // clear all filters except first
        for(Integer i = 1; i < viewFields.size(); i++) {
            viewFieldsList.set(i, emptyFields);
        }
        
        // fill filters above
        for(Integer i = 1; i <= lastFilterIndex; i++) {
            viewFieldsList.set(i, objectViewFields.clone());
        }
        // fill filters for deleted row
        viewFieldsList.set(deletedRowNumber, objectViewFields.clone());
        //fill filters one after last visible field
        if(lastFilterIndex < viewFields.size() - 1) {
            viewFieldsList.set(lastFilterIndex + 1, objectViewFields.clone());  
        }
        
        // remove duplicates
        removeFieldsAlreadySelected();
    }   
     
    private List<SelectOption>getProfiles(){
        List<SelectOption>profiles = new List<SelectOption>();
        for(Profile prof: [select Id, Name FROM Profile ORDER BY Name]){
            profiles.add(new SelectOption(prof.id, prof.Name));
        }
        return GNE_SFA2_Util.sortOptionList(profiles);
    }
    
    private List<SelectOption> getObjectsViewFields(Map<String, Schema.SObjectField> objectFieldsDescribe){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--None--'));
        for(String fieldName : objectFieldsDescribe.keySet()){
            if(objectFieldsDescribe.get(fieldName).getDescribe().isAccessible()){
                options.add(new SelectOption(fieldName,objectFieldsDescribe.get(fieldName).getDescribe().getLabel()));
            }
        }
        return GNE_SFA2_Util.sortOptionList(options);
    }
    
    private List<SelectOption> getObjectsFilterFields(Map<String, Schema.SObjectField> objectFieldsDescribe){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--None--'));
        for(String fieldName : objectFieldsDescribe.keySet()){
            if(objectFieldsDescribe.get(fieldName).getDescribe().isAccessible() && objectFieldsDescribe.get(fieldName).getDescribe().getType() != Schema.DisplayType.Reference
                    && objectFieldsDescribe.get(fieldName).getDescribe().getType() != Schema.DisplayType.Id){
                options.add(new SelectOption(fieldName,objectFieldsDescribe.get(fieldName).getDescribe().getLabel()));
            }
        }
        return GNE_SFA2_Util.sortOptionList(options);
    }
    
    public List<SelectOption> getMySetupProducts(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--None--'));
        for(My_Setup_Products_vod__c prod : [ SELECT Id, Name, Product_vod__r.Name FROM My_Setup_Products_vod__c WHERE OwnerId = :UserInfo.getUserId()]){
            options.add(new SelectOption(prod.Product_vod__r.Id, prod.Product_vod__r.Name));
        }
        return GNE_SFA2_Util.sortOptionList(options);
    }
    
    public void setViewField0(String name){
        viewFields.set(0, name);
    }
    
    public String getViewField0(){
        return viewFields.get(0);
    }
    
    public void setViewField1(String name){
        viewFields.set(1, name);
    }
    
    public String getViewField1(){
        return viewFields.get(1);
    }
    
    public void setViewField2(String name){
        viewFields.set(2, name);
    }
    
    public String getViewField2(){
        return viewFields.get(2);
    }
    
    public void setViewField3(String name){
        viewFields.set(3, name);
    }
    
    public String getViewField3(){
        return viewFields.get(3);
    }
    
    public void setViewField4(String name){
        viewFields.set(4, name);
    }
    
    public String getViewField4(){
        return viewFields.get(4);
    }
    
    public void setViewField5(String name){
        viewFields.set(5, name);
    }
    
    public String getViewField5(){
        return viewFields.get(5);
    }
    
    public void setViewField6(String name){
        viewFields.set(6, name);
    }
    
    public String getViewField6(){
        return viewFields.get(6);
    }
    
    public void setViewField7(String name){
        viewFields.set(7, name);
    }
    
    public String getViewField7(){
        return viewFields.get(7);
    }
    
    public void setViewField8(String name){
        viewFields.set(8, name);
    }
    
    public String getViewField8(){
        return viewFields.get(8);
    }
    
    public void setViewField9(String name){
        viewFields.set(9, name);
    }
    
    public String getViewField9(){
        return viewFields.get(9);
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
    }*/
}