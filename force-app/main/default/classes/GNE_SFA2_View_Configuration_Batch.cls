/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2013-02-04
*  Description: This is a batch to convert old Veeva views to the new SFA2 framework
*    
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
global without sharing class GNE_SFA2_View_Configuration_Batch implements Database.Batchable<sObject> {
	
	private Map<String, Profile> profilesMap;
	private Map<Id, String> accountRecordTypeIdToName = new Map<Id, String>();
	private Map<Id, String> personAccountRecordTypeIdToName = new Map<Id, String>();
	private Map<Id, User> usersMap;
	private Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
	private Map<String, Schema.SObjectField> accountFieldsDescribe = Schema.SObjectType.Account.fields.getMap();
	private Map<String, Schema.SObjectField> addressFieldsDescribe = Schema.SObjectType.Address_vod__c.fields.getMap();
	private Map<String, Schema.SObjectField> brandAffiliationFieldsDescribe = Schema.SObjectType.Product_Metrics_vod__c.fields.getMap();
	private Map<String, Schema.SObjectField> tsfFieldsDescribe = Schema.SObjectType.TSF_vod__c.fields.getMap();
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator('SELECT Address_Scope_vod__c,Columns_vod__c,CreatedById,CreatedDate,Criteria_vod__c,External_ID_vod__c,Id,IsDeleted,IsLocked,LastModifiedById,LastModifiedDate,MayEdit,Name,OwnerId,Ownership_Scope_vod__c,Profile_vod__c,Public_vod__c,Statement_vod__c,SystemModstamp,Type_vod__c,User_vod__c FROM View_vod__c');
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		usersMap = new Map<Id, User>([SELECT Id, IsActive FROM User]);
		profilesMap = new Map<String, Profile>([ SELECT Id, Name FROM Profile ]);
		// fill record type info maps
		for(RecordType rt : [SELECT Id, DeveloperName, IsPersonType FROM RecordType WHERE SobjectType = 'Account']){
        	if(rt.IsPersonType){
            	personAccountRecordTypeIdToName.put(rt.Id, rt.DeveloperName);
            }else{
                accountRecordTypeIdToName.put(rt.Id, rt.DeveloperName);
            }
        }
        
		List<SFA2_View_Config_gne__c> newViews = new List<SFA2_View_Config_gne__c>();
		for(View_vod__c view : (List<View_vod__c>) scope) {
			String viewName = view.Name;
			String viewVisibility;
			String recordsVisibility;
			String visibleColumns = '';
			String personAccountRecordTypes = '';
			String accountRecordTypes = '';
			List<GNE_SFA2_My_Accounts_View_Setup_Ext.ConditionItem> conditionItems = new List<GNE_SFA2_My_Accounts_View_Setup_Ext.ConditionItem>();
						
			// handle visibility
			if(view.Public_vod__c) {
				viewVisibility = 'restricted';
			} else {
				viewVisibility = 'private';
			}
			//handle record visibility
			if(view.Ownership_Scope_vod__c == 'mine') {
				recordsVisibility = 'My Records';
			} else {
				recordsVisibility = 'All Records';
			}
			
			// handle view columns
			if(view.Columns_vod__c != null) {
				List<String> viewColumns = view.Columns_vod__c.split(',');
				for(String viewColumn : viewColumns) {
					if(viewColumn.contains('Product_Metrics_vod__c')) {
						visibleColumns += 'BrandAffiliation.' + viewColumn.substringAfterLast('.') +  '.' + viewColumn.substringBetween('.') + ';';
					} else if (viewColumn.contains('TSF_vod__c')) {
						visibleColumns += viewColumn.replace('TSF_vod__c', 'TSF') + ';';
					} else if (viewColumn.contains('Address_vod__c')){
						visibleColumns += viewColumn.replace('Address_vod__c', 'Address') + ';';
					} else {
						visibleColumns += viewColumn + ';';
					}
				}
				// remove last ';'
				visibleColumns = visibleColumns.removeEnd(';');
			}
			
			// handle criteria
			if(view.Criteria_vod__c != null) {
				List<String> conditionsList = view.Criteria_vod__c.split(';;;');
				for(String condition : conditionsList) {
					List<String> splitCondition = condition.split(':::');
					GNE_SFA2_My_Accounts_View_Setup_Ext.ConditionItem conditionItem  = new GNE_SFA2_My_Accounts_View_Setup_Ext.ConditionItem(null, null, null, null, null, null, null);
					if(splitCondition[0].substringBefore('.') == 'Account' && splitCondition[0].substringAfter('.') == 'RecordTypeId') {
						//handle record types
						for(String recordTypeId :  splitCondition[2].split(',,')) {
							if(personAccountRecordTypeIdToName.containsKey(recordTypeId.trim())) {
								personAccountRecordTypes += personAccountRecordTypeIdToName.get(recordTypeId.trim()) + ', ';
							} else if(accountRecordTypeIdToName.containsKey(recordTypeId.trim())) {
								accountRecordTypes += accountRecordTypeIdToName.get(recordTypeId.trim()) + ', ';
							}
						}
					} else {
						if(splitCondition[0].substringBefore('.') == 'Product_Metrics_vod__c') {
							conditionItem.record = 'BrandAffiliation';
							conditionItem.brand = splitCondition[0].substringAfterLast('.');
							conditionItem.field = splitCondition[0].substringBetween('.');
						} else if(splitCondition[0].substringBefore('.') == 'Address_vod__c') {
							conditionItem.record = 'Address';
							conditionItem.brand = null;
							conditionItem.field = splitCondition[0].substringAfter('.');
						} else if(splitCondition[0].substringBefore('.') == 'TSF_vod__c') {
							conditionItem.record = 'TSF';
							conditionItem.brand = null;
							conditionItem.field = splitCondition[0].substringAfter('.');
						} else if(splitCondition[0].substringBefore('.') == 'Account') {
							conditionItem.record = 'Account';
							conditionItem.brand = null;
							conditionItem.field = splitCondition[0].substringAfter('.');
						}
										
						//conditionItem.operator = splitCondition[1];
						//System.debug('kwiatkol operator ' + conditionItem.operator);
						//System.debug('kwiatkol record ' + splitCondition[0].substringBefore('.'));
						//System.debug('kwiatkol field ' + conditionItem.field);
						System.debug('kwiatkol current view id: ' + view.Id);
						Schema.DescribeFieldResult fieldDescribe = globalDescribe.get(splitCondition[0].substringBefore('.')).getDescribe().fields.getMap().get(conditionItem.field).getDescribe();
			            Schema.DisplayType fieldType = fieldDescribe.getType();
			            conditionItem.valueType = fieldType.name();
			            // suport multiple version of conditions based on field type
			            if(conditionItem.valueType == 'PICKLIST' || conditionItem.valueType == 'MULTIPICKLIST') {
			            	if(splitCondition.size() > 2 && splitCondition[2] != null) {
			            		conditionItem.multiValue = splitCondition[2].split(',,');
			            	} else {
			            		conditionItem.multiValue = null;
			            	}
			            	
			            	if(splitCondition[1] == 'eq') {
			            		conditionItem.operator = 'inc';
			            	} else if(splitCondition[1] == 'ne'){
			            		conditionItem.operator = 'ecl';
			            	} else {
			            		conditionItem.operator = splitCondition[1];
			            	}
			            } else {
			            	if(splitCondition.size() > 2) {
			            		conditionItem.value = splitCondition[2];
			            	} else {
			            		conditionItem.value = null;
			            	}
			            	conditionItem.operator = splitCondition[1];
			            }
			            conditionItems.add(conditionItem);
					}
				}
			}
			
			if(view.Public_vod__c && view.Profile_vod__c != null) {
				List<String> profileList = view.Profile_vod__c.split(',');
				Boolean toInsert;
				for(String profileId : profileList) {
					System.debug('kwiatkol ' + profileId);
					Profile profile = profilesMap.get(profileId);
					System.debug('kwiatkol ' + profile);
					String applicationName;
					String brand;
					String role;
					toInsert = false;
					// handle SFA profiles
					if(profile != null && profile.Name != null && profile.Name.startsWith('GNE-SFA') && !profile.Name.startsWith('GNE-SFA2') && !profile.Name.startsWith('GNE-SFA-Primary-Care') && !profile.Name.contains('temp')) {
						applicationName = 'SFA-US';
						List<String> splitProfileName = new List<String>();
						splitProfileName = profile.Name.split('-');
						if(profile.Name.equalsIgnoreCase('GNE-SFA-CC')) {
							brand = null;
							role = 'CC';
						} else if(profile.Name.equalsIgnoreCase('GNE-SFA-CC-Manager')) {
							brand = null;
							role = 'CC-Manager';
						} else if(profile.Name.equalsIgnoreCase('GNE-SFA-CC-Oncology')) {
							brand = 'Oncology';
							role = 'CC';
						} else if(profile.Name.equalsIgnoreCase('GNE-SFA-CC-Rheumatoid')) {
							brand = 'Rheumatoid';
							role = 'CC';
						} else if(profile.Name.equalsIgnoreCase('GNE-SFA-OCC-Avastin/Tarceva')) {
							brand = 'Avastin_Tarceva';
							role = 'OCC';
						} else if(profile.Name.equalsIgnoreCase('GNE-SFA-OCC-Avastin/Tarceva-Manager')) {
							brand = 'Avastin_Tarceva';
							role = 'OCC-Manager';
						} else if(profile.Name.equalsIgnoreCase('GNE-SFA-OCC-Herceptin')) {
							brand = 'Herceptin';
							role = 'OCC';
						} else if(profile.Name.equalsIgnoreCase('GNE-SFA-OCC-Herceptin-Manager')) {
							brand = 'Herceptin';
							role = 'OCC-Manager';
						} else if(profile.Name.equalsIgnoreCase('GNE-SFA-OCC-Rituxan')) {
							brand = 'Rituxan';
							role = 'OCC';
						} else if(profile.Name.equalsIgnoreCase('GNE-SFA-OCC-Rituxan-Manager')) {
							brand = 'Rituxan';
							role = 'OCC-Manager';
						} else if(profile.Name.startsWith('GNE-SFA-Rituxan')) {
							brand = splitProfileName[2] + '-' + splitProfileName[3];
							if(splitProfileName.size() > 4) {
								role = splitProfileName[4];
							} else {
								role = null;
							}
						} else {
							// handle the rest of GNE-SFA profiles
							brand = splitProfileName[2];
							if(splitProfileName.size() > 3) {
								role = splitProfileName[3];
							} else {
								role = null;
							} 
						}
						
						toInsert = true;
						
					}
					// MCCO
					if(profile != null && profile.Name != null && profile.Name.startsWith('GNE-MCCO')) {
						applicationName = 'MCCO';
						if(profile.Name.equalsIgnoreCase('GNE-MCCO-AM')) {
							role = 'AM';
						} else {
							List<String> splitProfileName = new List<String>();
							splitProfileName = profile.Name.split('-');
							role = '';
							for(Integer i = 2; i < splitProfileName.size(); i++) {
								role += splitProfileName[i] + '-';
							}
							// remove last '-'
							role = role.removeEnd('-');
						}
						brand = null;
						toInsert = true;
					}
					// CANADA
					if(profile != null && profile.Name != null && profile.Name.startsWith('RCanada')) {
						List<String> splitProfileName = new List<String>();
						splitProfileName = profile.Name.split('-');
						applicationName = 'SFA-Canada';
						if(splitProfileName.size() > 3){
							role = splitProfileName[2] + '-' + splitProfileName[3];
						} else {
							role = splitProfileName[2];
						}
						brand = null;
						toInsert = true;
					}
					// TLCRM (TLS)
					if(profile != null && profile.Name != null && profile.Name.startsWith('GNE-TLS') && !profile.Name.contains('test')) {
						List<String> splitProfileName = new List<String>();
						splitProfileName = profile.Name.split('-');
						applicationName = 'TLCRM';
						if(splitProfileName.size() > 2){
							role = splitProfileName[2];
						} else {
							role = null;
						}
						brand = null;
						toInsert = true;
						
					}
					// MedAffaits
					if(profile != null && profile.Name != null && (profile.Name.startsWith('GNE-MedAffairs') || profile.Name.startsWith('zOld_GNE-MedAffairs'))) {
						List<String> splitProfileName = new List<String>();
						splitProfileName = profile.Name.split('-');
						applicationName = 'MedAffairs';
						if(splitProfileName.size() > 3){
							role = splitProfileName[2] + '-' + splitProfileName[3];
						} else {
							role = splitProfileName[2];
						}
						brand = null;
						toInsert = true;
					}
				 	System.debug('##### Brand === ' + brand);
				 	System.debug('##### Role === ' + Role);
					if(toInsert) {
						SFA2_View_Config_gne__c newView = new SFA2_View_Config_gne__c();
						newView.View_Name_gne__c = viewName;
						newView.Visibility_gne__c = viewVisibility;
						newView.Records_Visibility__c = recordsVisibility;
						newView.View_Fields_gne__c = visibleColumns;
						newView.Filter_Statement_gne__c = JSON.serialize(conditionItems);
						newView.Account_Record_Types_gne__c = accountRecordTypes;
						newView.Person_Record_Types_gne__c = personAccountRecordTypes;
						newView.Application_Type_gne__c = applicationName;
						newView.Brand_gne__c = brand;
						newView.Role_gne__c = role;
						newView.Object_Type_gne__c = 'Account';
						newView.Page_Name_gne__c = 'My Accounts';
						newView.Sorting_Field_gne__c = 'Account.Name';
						newViews.add(newView);
					}
				}
			} else {
				// private view
				if(usersMap.containsKey(view.OwnerId) && usersMap.get(view.OwnerId).IsActive) {
				SFA2_View_Config_gne__c newView = new SFA2_View_Config_gne__c();
					newView.View_Name_gne__c = viewName;
					newView.Visibility_gne__c = viewVisibility;
					newView.Records_Visibility__c = recordsVisibility;
					newView.View_Fields_gne__c = visibleColumns;
					newView.Account_Record_Types_gne__c = accountRecordTypes;
					newView.Person_Record_Types_gne__c = personAccountRecordTypes;
					newView.Filter_Statement_gne__c = JSON.serialize(conditionItems);
					newView.OwnerId = view.OwnerId;
					newView.Object_Type_gne__c = 'Account';
					newView.Page_Name_gne__c = 'My Accounts';
					newView.Sorting_Field_gne__c = 'Account.Name';
					newViews.add(newView);
				}
			}
		}
		//insert newViews;
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
}