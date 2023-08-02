public without sharing class EDM_Classification_Related_List_Ctrl {
	
	public GNE_SFA2_DynamicVFLoader pageController {get; set;}
	public List<String> fieldNames {get; set;}
	public Map<String, String> fieldOfUserReferenceMap {get; set;}
	public Map<String, Boolean> userReferenceHasExist {get; set;}
	public Map<String, String> fieldOfGroupReferenceMap {get; set;}
	public Map<String, Boolean> groupReferenceHasExist {get; set;}
	public Map<String, String> fieldAlignMap {get; set;}
	public Map<String, String> nameLabelMap {get; set;}
	public Id deleteRecordId {get; set;}
	public String sortByField {get; set;}
	public String sortDirection {
        get;
        set {
            //Ensure sortDirection attribute has value of 'asc' or 'desc'
            sortDirection = 'desc';
            if(String.isNotEmpty(value) && (value.equalsIgnoreCase('asc') || value.equalsIgnoreCase('desc'))){
                    sortDirection = value.toLowerCase();
            }
        }
    }
	public Boolean editEnabledCalc { get; set; }
	public Boolean deleteEnabledCalc { get; set; }
	public String relatedListLabel{get; set;}
	public String urlForNewRecord{get; set;}
	
	//----Variables set from attributes defined in the component----
	public String objectName {get; set;}
	public String fieldsCSV {get; set;}
	public List<String> fieldsList {get; set;}
	public String parentFieldName {get; set;}
	public Id parentFieldId {get; set;}
	public String filter {get; set;}
	public String orderByFieldName {get; set;}
	public List<String> fieldsType {get; set;}

	public Integer pageSize {get; set;}
	public Map<String, String> fieldSetMap{get; set;}
	public Map<String, Boolean> isLinkField{get; set;}
	public Map<String, Boolean> isDynamicLinkField{get; set;}
	public String commandButtonAction{get; set;}
	public String methodName {get; set;}
	public String userIdToViewLink {get; set;}
	public Boolean editEnabled { get; set; }
	public Boolean deleteEnabled { get; set; }
	public Boolean listRendered { get; set; }
	public Integer recordsLimit { get; set; }
	
	public Boolean initRecords {get; set; }
	
	public Boolean isRecordLimitReached {get; set; }
	
	public Boolean loadData {get; set;}
	
	public EDM_Classification_Related_List_Ctrl(){
		initRecords = false;
		loadData = false;
		isRecordLimitReached = false;
	}
	
	public PageReference showRelatedList() {
		loadData = true;
		return null;
	}
	
	private List<sObject> getRecordsLst(){
		if(objectName != null && objectName.contains('(')){
			objectName = objectName.substring(0,objectName.indexOf('('));
		}
		
		editEnabledCalc = !editEnabled && GNE_SFA2_Application_Cache.describeObject(objectName).isUpdateable();
		deleteEnabledCalc = !deleteEnabled && GNE_SFA2_Application_Cache.describeObject(objectName).isDeletable();
		
		String queryString = 'SELECT ';
		
		fieldSetMap = new Map<String,String>();
		isLinkField = new Map<String,Boolean>();
		isDynamicLinkField =  new Map<String,Boolean>();
		
		if(fieldsList == null && fieldsCSV == null){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'fieldList or fieldsCSV attribute must be defined.'));
			return null;
		}
		
		//Ensure parentFieldId is not null
		if(parentFieldId == null){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'parentFieldId attribute can not be null'));
			return null;
		}
		fieldsType = new List<String>();
		if(editEnabledCalc || deleteEnabledCalc){
			fieldsType.add('actionCol');
		}
		
		/*If field CSV was defined use this and also add fields to the fieldNames
		List so they can be used with Visualforce dynamic binding to define coloumns*/
		if(fieldsCSV != null){
			String temp = '';
			for(String f: fieldsCSV.split(',')) {
				List<String> values = f.split('#');
				String field = null;
				if(values.size() >=1){
					if(temp != '') {
						temp += ',';
					}
					field= values.get(0);
					temp += field;
					isLinkField.put(field,false);
					isDynamicLinkField.put(field,false);
					if(values.size() == 2) {
						fieldSetMap.put(field, values.get(1));
						Integer index = field.indexOf('__r.');
						if(index >= 0){
							isDynamicLinkField.put(field,true);
							String newField = field.subString(0,index+4) + 'Id';
							fieldSetMap.put(field, newField);
							if(!fieldsCSV.toLowerCase().contains(newField.toLowerCase())){
								queryString += newField + ',';
							}
						}
						isLinkField.put(field, true);
					}
				}
			}
			queryString += temp ;
			fieldNames = temp.split(',');
		}else{
			//Add fields to fieldNames list so it can be used with VF dynamic binding to define coloumns
			fieldNames = fieldsList.clone();
			
			//Loop through list of field names in fieldList and add to query
			for(String fld : fieldsList){
				queryString += fld + ',';
			}
			
			//Remove the very last comma that was added to the end of the field selection part of the query string
			queryString = queryString.substring(0,queryString.length() - 1);
		}
		
		System.debug('*************fieldCSV****>>>'+fieldsCSV);
		
		
		// Check If Field Has User or Group Reference
		fieldOfUserReferenceMap = new Map<String, String>();
		userReferenceHasExist = new Map<String, Boolean>();
		fieldOfGroupReferenceMap = new Map<String, String>();
		groupReferenceHasExist = new Map<String, Boolean>();
		
		for(String fieldName : fieldNames) {
			if (fieldName.contains('.')) {
				userReferenceHasExist.put(fieldName, false);
				groupReferenceHasExist.put(fieldName, false);
				List<String> tmp = fieldName.split('\\.');
				String objName = tmp.get(tmp.size()-2);
				objName = objName.endsWith('__r') ? objName.replace('__r', '__c') : objName;
				String fldName = tmp.get(tmp.size()-1);
				try{
					Map<String,Schema.SObjectField> sObjectFieldMap = GNE_SFA2_Application_Cache.describeObject(objName).fields.getMap();
					Schema.SObjectField sObjectField = sObjectFieldMap.get(fldName);
					Schema.DescribeFieldResult sObjectFieldDescribe = sObjectField.getDescribe();
					String fieldType = sObjectFieldDescribe.getType().name();
					if(sObjectFieldDescribe.autonumber){
						fieldsType.add('AUTONUMBER');
					}else{
						fieldsType.add(fieldType);
					}
				}catch(Exception e){
					fieldsType.add('STRING');
				}
			} else {
				try {
					Map<String,Schema.SObjectField> sObjectFieldMap = GNE_SFA2_Application_Cache.describeObject(objectName).fields.getMap();
					Schema.SObjectField sObjectField = sObjectFieldMap.get(fieldName);
					Schema.DescribeFieldResult sObjectFieldDescribe = sObjectField.getDescribe();
					String fieldType = sObjectFieldDescribe.getType().name();
					if(sObjectFieldDescribe.autonumber){
						fieldsType.add('AUTONUMBER');
					}else{
						fieldsType.add(fieldType);
					}
					Set<Schema.sObjectType> fieldReference = new Set<Schema.sObjectType>(sObjectFieldDescribe.getReferenceTo());
					if (fieldReference.size() > 0) {
						Boolean hasUserReference = fieldReference.contains(User.sobjecttype);
						Boolean hasGroupReference = fieldReference.contains(Group.sobjecttype);
						String relationName = sObjectFieldDescribe.getRelationshipName() + '.Name';
						userReferenceHasExist.put(fieldName, hasUserReference && !hasGroupReference);
						groupReferenceHasExist.put(fieldName, hasGroupReference);
						if (hasUserReference && !hasGroupReference){
							fieldOfUserReferenceMap.put(fieldName, relationName);
							queryString += ',' + relationName;
						} else if (hasGroupReference){
							fieldOfGroupReferenceMap.put(fieldName, relationName);
							queryString += ',' + relationName;
						}
						fieldReference.clear();
					} else {
						userReferenceHasExist.put(fieldName, false);
						groupReferenceHasExist.put(fieldName, false);
					}
				} catch (Exception ex) {
					system.debug(Logginglevel.ERROR, ex);
				}
			}
		}
		
		if (!queryString.contains('CreatedDate')) {
			queryString += ', CreatedDate';
		}
		
		if (!queryString.contains('LastModifiedDate')) {
			queryString += ', LastModifiedDate';
		}
		
		//add from object and parent criteria
		queryString += ' FROM ' + objectName + ' WHERE ' + parentFieldName + ' = \'' + parentFieldId + '\'';
		
		//Add any addtional filter criteria to query string if it was defined in component
		if(filter != null){
			queryString += ' AND ' + filter;
		}
		
			
		if(String.isEmpty(orderByFieldName)){
			orderByFieldName = 'LastModifiedDate';
		}
        sortByField = orderByFieldName;
       	queryString += ' ORDER BY ' + orderByFieldName;
        queryString += ' ' + sortDirection;
		queryString += ' LIMIT ' + recordsLimit;
		
		System.debug('##### Query String === ' + queryString);
		/*For the fields that will be displayed identify the field type and set styleClass for
		cell alignment. Numbers, Currency, %, etc should align right in table. put in map FieldName -> class name*/
		//Get the meta data info for the fields is the related object
		Map<String, Schema.SObjectField> fieldMap = GNE_SFA2_Application_Cache.describeObject(objectName).fields.getMap();
		
		//For the fields in the related list populate fieldAlignMap map with the name of the correct style class. Also populate name->label map for header display
		fieldAlignMap = new Map<String,String>();
		nameLabelMap = new Map<String,STring>();
		for(String fld : fieldNames){
			String fieldType =''; //fieldMap.get(fld).getDescribe().getType().name();
			if(fieldMap.get(fld) != null){
				fieldType = fieldMap.get(fld).getDescribe().getType().name();
			}
			if(fieldType == 'CURRENCY' || fieldType == 'DOUBLE' || fieldType == 'PERCENT' || fieldType == 'INTEGER'){
				fieldAlignMap.put(fld,'alignRight');
			}else{
				fieldAlignMap.put(fld,'alignLeft');
			}
			
			//Add to name->label map
			String label = '';//fieldMap.get(fld).getDescribe().getLabel();
			if(fieldMap.get(fld)!=null){
				label = fieldMap.get(fld).getDescribe().getLabel();
				if(fld == 'CreatedById') {
					label = 'Created By';
				} else if(fld == 'LastModifiedById') {
					label = 'Last Modified By';
				}
				nameLabelMap.put(fld,label);
			}else if(fld.contains('__r')){
				//Added by Kishore to get the related object field label name
				//What with standard relation like Owner.Name?
				
				String apiName,rlFldLabel,parentObjApiName;
				if(fld.indexOf('__r')!=-1){
					String rlObjName=fld.substring(0,fld.indexOf('__r'))+'__c';
					if(fld!=null && fld.contains('.')){
						apiName=fld.substring(fld.indexOf('.')+1,fld.length());
					}
					Map<String, Schema.SObjectField> fldObjMap = GNE_SFA2_Application_Cache.describeObject(objectName).fields.getMap();
					if(fldObjMap!=null && fldObjMap.get(rlObjName)!=null){
						Schema.DescribeFieldResult fieldDescribe = fldObjMap.get(rlObjName).getDescribe();
						parentObjApiName=fieldDescribe.getReferenceTo()[0].getDescribe().getName();
					}
					
					Map<String, Schema.SObjectField> prntfldObjMap = GNE_SFA2_Application_Cache.describeObject(parentObjApiName).fields.getMap();
					if(apiName!=null && prntfldObjMap.get(apiName)!=null){
						rlFldLabel=prntfldObjMap.get(apiName).getDescribe().getLabel();
					}else{
						rlFldLabel=fld;
					}
					nameLabelMap.put(fld,rlFldLabel);
				} else{
					nameLabelMap.put(fld,fld);
				}
			} else {
				nameLabelMap.put(fld,fld);
			}
		}
		List<sObject>result = Database.query(queryString);
		isRecordLimitReached = result.size() == recordsLimit;
		return result;
	}
	
	public Boolean getShowNewButton(){
		if(objectName != null && objectName.contains('(')){
			objectName = objectName.substring(0,objectName.indexOf('('));
		}
		return GNE_SFA2_Application_Cache.describeObject(objectName).isCreateable();
	}
	
	public String getObjectLabel(){
		if(objectName != null && objectName.contains('(')){
			objectName = objectName.substring(0,objectName.indexOf('('));
		}
		return GNE_SFA2_Application_Cache.describeObject(objectName).Label;
	}
	
	public PageReference deleteRecord(){
		String interactionStatus = 'Planned';
		try{
			sObject objToDelete = Database.query('SELECT Id FROM ' + objectName + ' WHERE Id=\'' + deleteRecordId + '\' LIMIT 1');
			if(objectName.contains('Call2_vod__c')){
				List<Call2_vod__c> getStatus = [SELECT Interaction_Status_gne__c FROM Call2_vod__c WHERE Id=: deleteRecordId];
				if (getStatus.size()>0){
					interactionStatus = getStatus[0].Interaction_Status_gne__c;
				}
			}
			delete objToDelete;
		} catch (Exception ex){
			if(objectName.contains('Call2_vod__c') && interactionStatus == 'Completed'){
				return GNE_SFA2_Util.redirectToErrorPage('You cannot delete a completed interaction!', Apexpages.currentPage().getUrl(), ex.getMessage());
			}
			return GNE_SFA2_Util.redirectToAccessDeniedPage();
		}
		return null;
	}
	
	public class RelatedListButton {
		public String action {get; set;}
		public String label {get; set;}
		
		public RelatedListButton(String action, String label) {
			this.action = action;
			this.label = label;
		}
	}
	
	public PageReference overrideUserViewLink() {
		PageReference pageref = new PageReference('/apex/GNE_SFA2_User_Layout?Id=' + userIdToViewLink);
		pageref.setredirect(true);
		return pageref;
	}
	
	public Pagereference callActionMethod(){
		if(pageController!= null){
			return pageController.callMethod(methodName);
		}
		return null;
	}
	
	public String getActionObjectName() {
		String result = '';
		if(objectName != null && objectName.contains('(')){
			result = objectName.substringBefore('(');
		} else {
			result = objectName;
		}
		return result;
	}
	
	public PageReference viewAllClick(){
		PageReference pageref = new PageReference('/apex/GNE_SFA2_ViewAll?parentObjectName='+pageController.myObjectType+
		'&parentRecordType='+pageController.recordTypeName+
		'&viewObjectName='+objectName+
		'&viewParentId='+parentFieldId+
		'&viewPageSize=50'+
		'&viewParentFieldName='+parentFieldName+
		'&viewOrderByFieldName='+orderByFieldName+
		'&viewHideButtons=true'+
		'&viewHideEditLink='+ !editEnabledCalc+
		'&viewHideDeleteLink='+ !deleteEnabledCalc+
		'&viewRelatedListLabel='+relatedListLabel+
		'&viewUrlForNewRecord='+EncodingUtil.urlEncode(urlForNewRecord, 'UTF-8'));
		pageref.setredirect(true);
		return pageref;
	}
	
	public List<SObject> getRecordsList(){
		if(initRecords || loadData){
			return getRecordsLst();
		}
		return new List<sObject>();
	}
}