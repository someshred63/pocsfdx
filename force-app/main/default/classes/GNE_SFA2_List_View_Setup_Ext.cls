/************************************************************
*  @author: 
*  Date: 
*  Description: This is a controller class for SFA2 List View Set up component.
*  
*  Modification History
*  Date         Name                Description
*  1/14/2012  Sreedhar Karukonda    Added Reference Filed type in to Filter Fields 
*  1/23/2013  Sreedhar Karukonda    Added Code to check filter field data type with Expression, If Data type dose not match sets filterMesage
									in "isValidFilter" method and corresponding handling in "save" method.
									Also, added instance variable "filterMessage"
************************************************************/

public with sharing class GNE_SFA2_List_View_Setup_Ext {
	public static final Integer VIEW_COLUMNS_COUNT = 10;
	public static final Integer FILTERS_COUNT = 5;
	
	public boolean ischecked{get;set;}
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

	public List<String> viewFields {get; set;}
	public List<Boolean> viewFieldsSortable {get; set;}
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
	
	public Integer rowToMove {get; set;}
	public Integer filterToDelete {get; set;}
	public Integer rowToDelete {get; set;}
	
	public SFA2_View_Config_gne__c view {get; set;}
	private GNE_SFA2_My_Accounts_Setttings__c settings;
	private SFA2_User_Preferences_gne__c myPreferences;
	
	private ApexPages.StandardController controller;
	private Map<String, Schema.SObjectType> globalDescribe;
	private String retURL;

	private List<GNE_SFA2_List_View_Excluded_Fields_gne__c> excludedFieldsSetting;
	private Set<String> excludedFields;
	
	/* SREEDHAR : isValidFilter sets value, save method will show this message in the UI*/
	private String filterMessage{get; set;}
	
	public GNE_SFA2_List_View_Setup_Ext(ApexPages.StandardController ctrl) {
		ischecked=false;
		this.controller = ctrl;
		globalDescribe = Schema.getGlobalDescribe();
		
		controller.addFields(new List<String>{'Application_Type_gne__c', 'Brand_gne__c', 'Role_gne__c', 'Page_Name_gne__c', 'Object_Type_gne__c', 'Account_Record_Types_gne__c', 'Person_Record_Types_gne__c' , 'View_Fields_gne__c','Filter_Statement_gne__c', 'View_Name_gne__c', 'Visibility_gne__c', 'Sorting_Field_gne__c', 'CreatedById', 'OwnerId', 'Records_Visibility__c'});
		view = (SFA2_View_Config_gne__c)controller.getRecord();

		if(view.CreatedById == UserInfo.getUserId()) {
			deleteEnabled = true;
		} else {
			deleteEnabled = false;
		}
		
		picklistOperators = new List<SelectOption>{new SelectOption('','--None--'), new SelectOption('inc','equals'), new SelectOption('ecl','not equal to')};
		multipicklistOperators = new List<SelectOption>{new SelectOption('','--None--'), new SelectOption('inc','includes'), new SelectOption('ecl','excludes')};
		booleanOperators = new List<SelectOption>{new SelectOption('','--None--'), new SelectOption('eq','equals'), new SelectOption('ne','not equals')};
		stringOperators = new List<SelectOption>{new SelectOption('','--None--'), new SelectOption('eq','equals'), new SelectOption('ne','not equal to'), new SelectOption('lt','less than'), new SelectOption('lte','less or equal'), new SelectOption('gt','greater than'), new SelectOption('gte','greater or equal'), new SelectOption('c','contains'), new SelectOption('nc','does not contain'), new SelectOption('sw','starts with')};
		numberOperators = new List<SelectOption>{new SelectOption('','--None--'), new SelectOption('eq','equals'), new SelectOption('ne','not equal to'), new SelectOption('lt','less than'), new SelectOption('lte','less or equal'), new SelectOption('gt','greater than'), new SelectOption('gte','greater or equal')};

		emptyFields = new List<SelectOption>{new SelectOption('','--None--')};
		
		filterMultiValues = new List<List<String>>();

		viewFieldsList = new List<List<SelectOption>>();
		filterFieldsList = new List<List<SelectOption>>();
		filterOperatorsList = new List<List<SelectOption>>();
		filterValuesList = new List<List<SelectOption>>();
		
		viewFields = new List<String>();
		viewFieldsSortable = new List<Boolean>();
		filterFields = new List<String>();
		filterOperators = new List<String>();
		filterValues = new List<String>();
		filterFieldType = new List<String>();
		filterErrorMessages = new List<String>();
		filterErrors = new List<Boolean>();
		
		settings = [Select Account_View_Columns_gne__c, Address_View_Columns_gne__c, Brand_Affiliation_View_Columns_gne__c, PageSize_gne__c, Privileged_Profiles_gne__c, TSF_View_Columns_gne__c FROM GNE_SFA2_My_Accounts_Setttings__c limit 1];
		
		if(view.Object_Type_gne__c == null) {
			view.Object_Type_gne__c = System.currentPagereference().getParameters().get('objectType');
		}
		
		if(view.Page_Name_gne__c == null) {
			view.Page_Name_gne__c = System.currentPagereference().getParameters().get('pageName');
		}

		excludedFieldsSetting = [SELECT Field_Name__c FROM GNE_SFA2_List_View_Excluded_Fields_gne__c WHERE Object_Name__c = :view.Object_Type_gne__c];
		excludedFields = getStringSetFromSObjectList('Field_Name__c', excludedFieldsSetting);
		
		retURL = System.currentPagereference().getParameters().get('retURL');
		
		try{
			myPreferences = [SELECT Last_View_Used_gne__c, Last_Territory_Used_gne__c FROM  SFA2_User_Preferences_gne__c WHERE Last_View_Used_gne__r.Page_Name_gne__c = :view.Page_Name_gne__c AND User_gne__c = :Userinfo.getUserId() limit 1];
		}catch(Exception e){
			myPreferences = new SFA2_User_Preferences_gne__c(User_gne__c = UserInfo.getUserId());
		}
		
		objectViewFields = getObjectsViewFields(globalDescribe.get(view.Object_Type_gne__c).getDescribe().fields.getMap());
		objectFilterFields = getObjectsFilterFields(globalDescribe.get(view.Object_Type_gne__c).getDescribe().fields.getMap());
		
		for(Integer i = 0; i <VIEW_COLUMNS_COUNT; i++){
			viewFieldsList.add(emptyFields); 
			viewFields.add('');
			viewFieldsSortable.add(true);
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
			prepareEditForm((SFA2_View_Config_gne__c)controller.getRecord());
		}else{
			if(  (System.currentPagereference().getParameters().get('objectType').trim().equals('Task'))     ||  (System.currentPagereference().getParameters().get('objectType').trim().equals('Event'))    ){
				recordSequence = 0;
				viewFields.set(0, 'activitydate');
				initViewFields();
				sortRow = 0;
			}
			else{
				recordSequence = 0;
				viewFields.set(0, 'name');
				initViewFields();
				sortRow = 0;
			}
		}
	}
	
	public PageReference selectClick() {
		return null;
	}
	
	public PageReference unselectClick() {
		return null;
	}
	
	private void prepareEditForm(SFA2_View_Config_gne__c view){
		
		List<String> columns = view.View_Fields_gne__c.split(';', 0);
		for(Integer i=0; i< columns.size(); i++){
			recordSequence = i;
			viewFields.set(i, columns.get(i));
			viewFieldsList.set(i, objectViewFields.clone());
			if(viewFields.get(i)==view.Sorting_Field_gne__c){
				sortRow = i;
			}
			prepareViewObjectFields();
		}
		if(columns.size() < VIEW_COLUMNS_COUNT - 1) {
			viewFieldsList.set(columns.size(), objectViewFields.clone());
			removeFieldsAlreadySelected();
		}
		
		if(String.isNotEmpty(view.Filter_Statement_gne__c)){
			List<ConditionItem>conditionItems = (List<ConditionItem>)JSON.deserializeStrict(view.Filter_Statement_gne__c,  List<ConditionItem>.class);
			for(Integer i=0; i<conditionItems.size(); i++){
				filterFields.set(i, conditionItems.get(i).field);
				filterFieldType.set(i, conditionItems.get(i).valueType);
				prepareFilterOperators(i);
				filterOperators.set(i, conditionItems.get(i).operator);
				filterValues.set(i, conditionItems.get(i).value);
				filterMultiValues.set(i, conditionItems.get(i).multiValue);
			} 
		}
	}
	
	public Boolean getHasAdditionalPriviliges(){
		String profileName = GNE_SFA2_Util.getCurrentUserProfileName();
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

	private void prepareFilterOperators(Integer filterSequence){
		Schema.DescribeFieldResult fieldDescribe;
		Schema.DisplayType fieldType;
		/*
		* SREEDHAR: To handle reference type field, Value in the picklist will be like "ReferenceName.Name" and  label in the picklist will be Label of the picklist
		*/
		String fieldName= filterFields.get(filterSequence);
		if(filterFields.get(filterSequence).contains('.')){
			fieldName= filterFields.get(filterSequence).split('\\.')[0];
			if(fieldName.contains('__r')) fieldName = fieldName.replace('__r', '__c');
			else fieldName = fieldName+'Id';
		}
		System.debug('SREEDHAR : field Name AFRER' + fieldName);
		filterOperatorsList.set(filterSequence, stringOperators);
		fieldType = globalDescribe.get(view.Object_Type_gne__c).getDescribe().fields.getMap().get(fieldName).getDescribe().getType();
		fieldDescribe = globalDescribe.get(view.Object_Type_gne__c).getDescribe().fields.getMap().get(fieldName).getDescribe();
		
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

	public void prepareFilterOperators(){
		if(filterFields.get(filterSequence) == null) {
			filterOperatorsList.set(filterSequence, emptyFields);
			filterValuesList.set(filterSequence, emptyFields);
			filterValues.set(filterSequence, '');
		}else{
			prepareFilterOperators(filterSequence);
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
		//System.debug('SREEDHAR viewFields : ' + ' sortRow : ' + sortRow);
		if(sortRow != null && viewFields.get(sortRow) != null && !viewFields.get(sortRow).contains('.')){
			//System.debug('SREEDHAR viewFields.get(sortRow) : '+ viewFields.get(sortRow));
			Schema.DisplayType fieldType = globalDescribe.get(view.Object_Type_gne__c).getDescribe().fields.getMap().get(viewFields.get(sortRow)).getDescribe().getType();
			if(fieldType == Schema.Displaytype.MultiPicklist || fieldType == Schema.Displaytype.TextArea){
				sortRow = 0;
				//System.debug('SREEDHAR SORT ROW : ' + sortRow);
			}
		}
		
		if(sortRow==null){
			
			sortRow=0;
			
		}
		
		if(String.isEmpty(viewFields.get(sortRow))) {   // if sort column was set to None value
			sortRow = 0;
		}
		
		viewFieldsList.set(lastIndex + 1, options);
		removeFieldsAlreadySelected();
		prepareViewFieldsSortable();
		return null;
	}
	
	public void prepareViewFieldsSortable(){
		for(Integer i = 0; i < VIEW_COLUMNS_COUNT; i++) {
			if(viewFields.get(i) != null && viewFields.get(i) != '') {
				if(viewFields.get(i).contains('.')){ //SFDC-2214
					viewFieldsSortable.set(i, true);
					continue;
				}
				Schema.DisplayType fieldType = globalDescribe.get(view.Object_Type_gne__c).getDescribe().fields.getMap().get(viewFields.get(i)).getDescribe().getType();
				if(fieldType == Schema.Displaytype.MultiPicklist || fieldType == Schema.Displaytype.TextArea) {
					viewFieldsSortable.set(i, false);   
				} else {
					viewFieldsSortable.set(i, true);
				}
			}
		}
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
		view.Filter_Statement_gne__c = '';
		view.Visibility_gne__c = 'private';
		view.Account_Record_Types_gne__c='';
		view.Person_Record_Types_gne__c='';
		
		if(view.Page_Name_gne__c == 'Classification Log' || view.Page_Name_gne__c == 'Classification Requests') {

			view.Records_Visibility__c = 'All Records';
		}

		List<ConditionItem>conditionItems = new List<ConditionItem>();
		for(Integer i = 0; i < filterFields.size();i++){
			String filterExpr = '';
			filterMessage = 'Filter is invalid';
			if(isNotEmptyFilter(i)){
				if(isValidFilter(i)) {
					ConditionItem conditionItem = new ConditionItem(filterFields.get(i), filterOperators.get(i), filterValues.get(i), filterMultiValues.get(i), filterFieldType.get(i));
					conditionItems.add(conditionItem);
					filterErrors.set(i, false);
					filterErrorMessages.set(i, '');
				} else {
					containsError = true;
					filterErrors.set(i, true);
					filterErrorMessages.set(i, filterMessage);
					filterMessage = '';
				}
			}
		}       
		
		if(!containsError){
			view.Filter_Statement_gne__c = JSON.serialize(conditionItems); 
			upsert view;
			
			// update selected view in user preferences
			myPreferences.Last_View_Used_gne__c = view.id;
			upsert myPreferences;
			
			PageReference retPageRef = new PageReference(retURL);
			retPageRef.setRedirect(true);
			return retPageRef;
		}else{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error while saving the view.'));
			return null;
		}
	}
	
	private Boolean isNotEmptyFilter(Integer index){
		if(filterFields.get(index) != null && filterFields.get(index) != '') {
			return true;
		} else {
			return false;
		}
	}
	
	/*
	* Added Code to check filter field data type with Expression, If Data type dose not match sets filterMesage
	*/
	
	private Boolean isValidFilter(Integer index){
		Boolean result = true;
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
				} else if (filterFieldType.get(index)=='ID'){
					try{
						Pattern MyPattern = Pattern.compile('[a-zA-Z0-9]{15}');
						Matcher MyMatcher = MyPattern.matcher(filterValues.get(index));
						if (!MyMatcher.matches()) {
							filterMessage = filterValues.get(index) +' is not a valid ID. ID must be exactly 15 characters.' ;
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
	
	/*Change view column order.*/
	public PageReference moveHigher(){
		System.debug('**now sort row**'+sortRow);
		String tmpViewField = viewFields.get(rowToMove-1);
		List<SelectOption> tmpFields = viewFieldsList.get(rowToMove-1);
		
		viewFieldsList.set(rowToMove-1, viewFieldsList.get(rowToMove));
		viewFields.set(rowToMove-1, viewFields.get(rowToMove));
		
		viewFieldsList.set(rowToMove, tmpFields);
		viewFields.set(rowToMove, tmpViewField);
		
		if(sortRow == rowToMove) {
			sortRow = sortRow - 1;
		} else if(sortRow == rowToMove - 1) {
			sortRow = sortRow + 1;
		}
		
		return prepareViewObjectFields();
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

	public PageReference deleteRow(){
		viewFields.set(rowToDelete, '');
		reloadVisibleFieldsOnDelete(rowToDelete);
		removeFieldsAlreadySelected();
		if(sortRow == rowToDelete){
			sortRow = 0;
		}
		
		return null;
	}
	
	private void reloadVisibleFieldsOnDelete(Integer deletedRowNumber) {
		Integer lastFilterIndex = 0;
		for(Integer i = viewFields.size() - 1 ; i >= 0; i--) {
			if(String.isNotEmpty(viewFields.get(i))) {
				lastFilterIndex = i;
				break;
			}
		}
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
	
	
	private List<SelectOption> getObjectsViewFields(Map<String, Schema.SObjectField> objectFieldsDescribe){
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('','--None--'));

		for(String fieldName : objectFieldsDescribe.keySet()){
			if(!excludedFields.contains(fieldName.toLowerCase()) && !fieldName.equalsIgnoreCase('IsDeleted') && !fieldName.equalsIgnoreCase('MayEdit') && !fieldName.equalsIgnoreCase('IsLocked') && !fieldName.equalsIgnoreCase('Description') && objectFieldsDescribe.get(fieldName).getDescribe().isAccessible()){
				
				if(fieldName.equalsIgnoreCase('AccountID') && view.Object_Type_gne__c =='Contact'){
					options.add(new SelectOption('account.name','Name'));
					options.add(new SelectOption('accountid','Account ID'));
					options.add(new SelectOption('account.parentid','Account Parent Account'));
				} else if(fieldName.equalsIgnoreCase('ReportsToId') && view.Object_Type_gne__c =='Contact'){
					options.add(new SelectOption('reportstoid','Reports To'));
					options.add(new SelectOption('reportsto.lastname','Reports To Last Name'));
					options.add(new SelectOption('reportsto.firstname','Reports To First Name'));
				} else if(fieldName.equalsIgnoreCase('RecordTypeID')){
					options.add(new SelectOption('recordtypeid','Record Type'));
				}else if(fieldName.equalsIgnoreCase('OwnerID')){
					options.add(new SelectOption('owner.alias','Owner Alias'));
					options.add(new SelectOption('owner.firstname','Owner First Name'));
					options.add(new SelectOption('owner.lastname','Owner Last Name'));
				}else if(fieldName.equalsIgnoreCase('CreatedByID')){
					options.add(new SelectOption('createdby.alias','Created By Alias'));
					options.add(new SelectOption('createdbyid','Created By'));
				}else if(fieldName.equalsIgnoreCase('LastModifiedByID')){
					options.add(new SelectOption('lastmodifiedby.alias','Last Modified By Alias'));
					options.add(new SelectOption('lastmodifiedbyid','Last Modified By'));
				}else if(fieldName.equalsIgnoreCase('SystemModstamp')){
					// System Mod time stamp is not displayed in Standard UI
				}else options.add(new SelectOption(fieldName,objectFieldsDescribe.get(fieldName).getDescribe().getLabel()));
			}
		}
		return GNE_SFA2_Util.sortOptionList(options);
	}
	
	private List<SelectOption> getObjectsFilterFields(Map<String, Schema.SObjectField> objectFieldsDescribe){
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('','--None--'));
		
		for(String fieldName : objectFieldsDescribe.keySet()){
			if (!excludedFields.contains(fieldName.toLowerCase())) {
				if(objectFieldsDescribe.get(fieldName).getDescribe().isAccessible() && objectFieldsDescribe.get(fieldName).getDescribe().getType() != Schema.DisplayType.Reference
						&& objectFieldsDescribe.get(fieldName).getDescribe().getType() != Schema.DisplayType.Id && objectFieldsDescribe.get(fieldName).getDescribe().getType() != Schema.DisplayType.TextArea
						&& !fieldName.equalsIgnoreCase('IsDeleted') && !fieldName.equalsIgnoreCase('MayEdit') && !fieldName.equalsIgnoreCase('IsLocked') && !fieldName.equalsIgnoreCase('Description') ){
					
					options.add(new SelectOption(fieldName,objectFieldsDescribe.get(fieldName).getDescribe().getLabel()));
				}
				/*
				* SREEDHAR: To handle Reference Type Picklist Item Value : ReferenceName.Name
				*/
				else if(objectFieldsDescribe.get(fieldName).getDescribe().isAccessible() && objectFieldsDescribe.get(fieldName).getDescribe().getType() == Schema.DisplayType.Reference
						&& objectFieldsDescribe.get(fieldName).getDescribe().getType() != Schema.DisplayType.Id){
					//if(fieldName.equalsIgnoreCase('RecordTypeID')){
					//options.add(new SelectOption(objectFieldsDescribe.get(fieldName).getDescribe().getRelationshipName()+'.Name', 'Record Type'));
					//}
					if(fieldName.equalsIgnoreCase('AccountID') && view.Object_Type_gne__c =='Contact'){
						options.add(new SelectOption('account.name','Name'));
						options.add(new SelectOption('accountid','Account ID'));
						options.add(new SelectOption('account.parent.name','Account Parent Account'));
					} else if(fieldName.equalsIgnoreCase('ReportsToId') && view.Object_Type_gne__c =='Contact'){
						options.add(new SelectOption('reportsto.name','Reports To'));
						options.add(new SelectOption('reportsto.lastname','Reports To Last Name'));
						options.add(new SelectOption('reportsto.firstname','Reports To First Name'));
					} else if(fieldName.equalsIgnoreCase('RecordTypeID')){
						options.add(new SelectOption('recordtype.name','Record Type'));
					}else if(fieldName.equalsIgnoreCase('OwnerID')){
						options.add(new SelectOption('owner.alias','Owner Alias'));
						options.add(new SelectOption('owner.firstname','Owner First Name'));
						options.add(new SelectOption('owner.lastname','Owner Last Name'));
					}else if(fieldName.equalsIgnoreCase('CreatedByID')){
						options.add(new SelectOption('createdby.alias','Created By Alias'));
						options.add(new SelectOption('createdby.name','Created By'));
					}else if(fieldName.equalsIgnoreCase('LastModifiedByID')){
						options.add(new SelectOption('lastmodifiedby.alias','Last Modified By Alias'));
						options.add(new SelectOption('lastmodifiedby.name','Last Modified By'));
					}else if(fieldName.equalsIgnoreCase('SystemModstamp')){
						// System Mod time stamp is not displayed in Standard UI
					} else options.add(new SelectOption(objectFieldsDescribe.get(fieldName).getDescribe().getRelationshipName()+'.Name',objectFieldsDescribe.get(fieldName).getDescribe().getLabel()));
				}else if(objectFieldsDescribe.get(fieldName).getDescribe().getType() == Schema.DisplayType.Id && fieldName.equalsIgnoreCase('id')){
					options.add(new SelectOption(fieldName,objectFieldsDescribe.get(fieldName).getDescribe().getLabel()));
				}
			}			
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
	}
	
	public PageReference radioCheck(){
		return null;
		
	}

	private Set<String> getStringSetFromSObjectList(String fieldName, List<SObject> inList) {
		Set<String> result = new Set<String>();
		for (SObject item : inList) {
			String fieldNameToAdd = (String)item.get(fieldName);
			result.add(fieldNameToAdd.toLowerCase());
		}
		return result;
	}

	public class ConditionItem{
		public String field {get; set;}
		public String operator {get; set;}
		public String value {get; set;}
		public List<String> multiValue {get; set;}
		public String valueType{get; set;}
		
		public ConditionItem(String field, String operator, String value, List<String> multiValue, String valueType){
			this.field = field;
			this.operator = operator;
			this.value = value;
			this.multiValue = multiValue;
			this.valueType = valueType;
		}
	}
}