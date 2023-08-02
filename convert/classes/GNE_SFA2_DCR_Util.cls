public without sharing class GNE_SFA2_DCR_Util {
	public enum ConfigurationType {Main, FieldMapping}
	private enum MainConfigType {ParentUpdateEnabled, ParentBlockEnabled, DcrDataAdminProfileMask, ParentUpdateDcrApprovalStatuses, ParentBlockDcrApprovalStatuses, DcrClosedStatuses, ParentUpdateDcrRecordTypes, AddressInactivateRecordTypes, AccountInactivateRecordTypes, DaysForValidDcrs, BrandTeams}

	public static final String HCO_REMOVE_DUPLICATE_ORGANIZATION_TYPE = 'HCO Remove Duplicate Organization';
	public static final String LIST_DELIMETER = '::';
	public static final String LIST_COMMA_DELIMETER = ',';
	public static final String ARRAY_OPEN_MARK = '[';
	public static final String ARRAY_CLOSE_MARK = ']';

	private static final String FIELD_MAPPING_VALUE_PATTERN = '^\\{\\{(.*)\\}\\}$';
	public static final String FRM_ACCOUNT_RT = 'FRM_HCO';

	private static Map<String,String> mainConfig;
	public static Map<String,List<FieldMapping>> fieldMappings;
	private static Map<String,Set<String>> parentObjectFieldNames;
	private static Map<String,Set<String>> dcrFieldNames;
	private static Map<String,Id> dcrRecordTypesIdMap;
	private static Map<Id,String> dcrRecordTypesNameMap;
	private static Map<String,String> dcrRecordTypesToObjectNameMap;
	private static Map<String,Set<String>> dcrObjectNamesToRecordTypeMap;
	private static Map<String,String> dcrRecordTypesToObjectLookupFieldMap;
	private static Boolean isParentUpdateEnabled;
	private static Boolean isParentBlockEnabled;
	private static Boolean isUserDcrDataAdmin;
	private static Map<String, Set<String>> dcrValidApprovalStatuses;
	private static Set<String> dcrBlockValidApprovalStatuses;
	private static Set<String> dcrClosedStatuses;
	private static Set<Id> parentUpdateValidDcrRecorTypeIds;
	private static Set<Id> addressInactivateRecordTypeIds;
	private static Set<Id> accountInactivateRecordTypeIds;
	private static Integer daysForValidDcrs;
	private static Set<String> brandTeams;

	private static Map<String,Map<Id,SObject>> parentsCache;

	public static Boolean isApprovedForParentUpdate(Change_Request_gne__c cr, String accountRecordType) {
		String approvalState = cr.Approval_State__c!=null ? cr.Approval_State__c.toUpperCase() : null;
		if(getDcrValidApprovalStatuses().containsKey(approvalState)){
			Set<String> recordTypes = getDcrValidApprovalStatuses().get(approvalState);
			if(recordTypes == null || recordTypes.contains(accountRecordType)){
				return true;
			}
		}
		return false;
	}

	public static Boolean isApprovedForParentUpdate(Change_Request_gne__c cr) {
		return isApprovedForParentUpdate(cr, cr.Account_gne__r.RecordType.DeveloperName);
	}

	public static Boolean isApprovedForBlocking(Change_Request_gne__c cr) {
		String approvalState = cr.Approval_State__c!=null ? cr.Approval_State__c.toUpperCase() : null;
		return getDcrBlockValidApprovalStatuses().contains(approvalState);
	}

	public static Boolean isValidForParentUpdate(Change_Request_gne__c cr) {
		return getParentUpdateValidDcrRecordTypeIds().contains(cr.RecordTypeId);
	}

	public static Boolean isOpen(Change_Request_gne__c cr) {
		String status = cr.Status_gne__c!=null ? cr.Status_gne__c.toUpperCase() : null;
		return !getDcrClosedStatuses().contains(status);
	}

	public static Boolean isValidForUpdateListOfChangedFields(Change_Request_gne__c crOld, Change_Request_gne__c crNew) {
		if(crOld != null && GNE_SFA2_Util.isFrmDataSteward(UserInfo.getUserId()) && !isApprovedForBlocking(crOld) && isOpen(crOld) && isValidForParentUpdate(crNew)){
			return true;
		}
		return (GNE_SFA2_Util.isFrmDataSteward(UserInfo.getUserId()) || UserInfo.getUserType() == 'Standard') && !isApprovedForBlocking(crNew) && isOpen(crNew) && isValidForParentUpdate(crNew);
	}

	public static void updateListOfChangedFields(List<Change_Request_gne__c> crs) {
		if(GNE_SFA2_DCR_Util.isParentUpdateEnabled()) {
			cacheParentRecords(crs);

			for(Change_Request_gne__c cr : crs) {
				Map<String,ChangedField> changedFields = getChangedFields(cr, null);
				cr.Changed_Fields_gne__c = !changedFields.isEmpty() ? JSON.serialize(changedFields) : null;
			}
		}
	}

	private static Map<String,ChangedField> getChangedFields(Change_Request_gne__c cr, SObject parentRec) {
		Map<String,ChangedField> result = new Map<String,ChangedField>();
		String objName = getParentObjectName(cr);
		String lookupFieldName = getLookupFieldName(cr);

		if(String.isNotBlank(objName) && String.isNotBlank(lookupFieldName)) {
			String dcrRecTypeName = dcrRecordTypesNameMap.get(cr.RecordTypeId);
			SObject parentRecOld;
			try {
				parentRecOld = parentsCache != null ? parentsCache.get(objName).get((Id)cr.get(lookupFieldName)) : null;
			} catch(Exception ex) {
				Integer.valueOf(new Map<String,Object>{'parentsCache' => parentsCache, 'objName' => objName, 'cr' => cr, 'lookupFieldName' => lookupFieldName});
			}

			if(parentRecOld != null) {
				Boolean inactivatePrimaryAddress = getAddressInactivateRecordTypeIds().contains(cr.RecordTypeId) && ((Address_vod__c)parentRecOld).Primary_vod__c==true;

				if(!inactivatePrimaryAddress) {

					for(FieldMapping fm : fieldMappings.get(dcrRecTypeName)) {
						if(!fm.isReadOnly && fm.isAutoParentUpdate) {
							Object oldValue = parentRecOld.get(fm.fieldName);
							Object newValue = parentRec!=null ? parentRec.get(fm.fieldName) : String.isNotBlank(fm.dcrFieldName) ? cr.get(fm.dcrFieldName) : fm.fieldValue;
							if(isFieldValueChanged(oldValue, newValue)) {
								result.put(fm.fieldName, new ChangedField(fm.fieldName, parentRec!=null ? null : fm.dcrFieldName, parentRec!=null ? newValue : fm.fieldValue));
							}
						}
					}
				}
			}
		}
		return result;
	}

	public static Map<Id,List<DmlResult>> updateParentRecords(List<Change_Request_gne__c> crs) {
		readConfiguration();
		Map<Id,List<DmlResult>> result = new Map<Id,List<DmlResult>>();
		List<SObject> parentsToUpdate = new List<SObject>();
		Map<Id,Id> parentToCrMap = new Map<Id,Id>();
		List<Change_Request_gne__c> inactiveAccountCRs = new List<Change_Request_gne__c>();

		for(Change_Request_gne__c cr : crs) {
			SObject parentRec = updateParentRecord(cr);
			if(parentRec!=null) {
				parentsToUpdate.add(parentRec);
				parentToCrMap.put(parentRec.Id,cr.Id);
			}

			if(getAccountInactivateRecordTypeIds().contains(cr.RecordTypeId)) {
			    inactiveAccountCRs.add(cr);
			}
		}

		if(!parentsToUpdate.isEmpty()) {
			GNE_SFA2_Account_Trigger_Helper.setAccountTrig(true);
			GNE_SFA2_Address_Trigger_Helper.setAddressTrig(true);
			Database.SaveResult[] sResults = Database.update(parentsToUpdate, false);
			GNE_SFA2_Account_Trigger_Helper.setAccountTrig(false);
			GNE_SFA2_Address_Trigger_Helper.setAddressTrig(false);

			for(Database.SaveResult sr : sResults) {
			    Id crId = parentToCrMap.get(sr.getId());

			    if(!result.containsKey(crId)) {
                    result.put(crId, new List<DmlResult>());
			    }

				result.get(crId).add(new DmlResult(sr));
			}
		}

		if(!inactiveAccountCRs.isEmpty()) {
            Map<Id,List<DmlResult>> partialResult = modifyUsersAccountsList(inactiveAccountCRs);

            for(Id crId : partialResult.keySet()) {
                if(!result.containsKey(crId)) {
                    result.put(crId, new List<DmlResult>());
                }

                result.get(crId).addAll(partialResult.get(crId));
            }
		}


		return result;
	}

	//The System will automatically remove the physician from Min List (for all the other reps too) after 'Remove/Inactivate HCP' DCR (HCP is Dead, HCP is Retired, and HCP is fake) is approved
	private static Map<Id,List<DmlResult>> modifyUsersAccountsList(List<Change_Request_gne__c> crs){
	    Map<Id,List<DmlResult>> result = new Map<Id,List<DmlResult>>();
		List<Id>accountIds = new List<Id>();
		Set<String>teams = getBrandTeams();
        List<TSF_vod__c>tsfToDelete = new List<TSF_vod__c>();
        List<Sharing_Mgmt_gne__c>sharingManagments = new List<Sharing_Mgmt_gne__c>();
        Map<Id,Id> crMap = new Map<Id,Id>();

		for(Change_Request_gne__c cr : crs) {
		    crMap.put(cr.Account_gne__c, cr.Id);
			accountIds.add(cr.Account_gne__c);
		}

		if(!teams.isEmpty() && !accountIds.isEmpty()) {
            //remove tsf'es
            List<Tsf_vod__c>tsfes = [SELECT id, Territory_vod__c, Account_vod__c FROM Tsf_vod__c WHERE Account_vod__c IN :accountIds AND Territory_vod__c <> null];
            List<String>terrNames = new List<String>();

            for(Tsf_vod__c tsf: tsfes){
                terrNames.add(tsf.Territory_vod__c);
            }

            Set<String>validTerritories = new Set<String>();

            if(!terrNames.isEmpty()) {
		        for(Territory2 terr: [SELECT Name FROM Territory2 WHERE Salesforce_Code_gne__c IN :teams AND Name IN :terrNames]) {
                    validTerritories.add(terr.Name);
                }

                for(Tsf_vod__c tsf: tsfes){
                    if(validTerritories.contains(tsf.Territory_vod__c)) {
                        sharingManagments.add(new Sharing_Mgmt_gne__c(Object_Name_gne__c = 'AccountShare', Account_Id_gne__c = tsf.Account_vod__c, Territory_Name_gne__c = tsf.Territory_vod__c, Schedule_Date_Time_gne__c = System.Today(), Operation_gne__c = 'Delete', Status_gne__c = 'New'));
                        tsfToDelete.add(tsf);
                    }
                }


            }
		}

		if(!sharingManagments.isEmpty()) {
            Database.SaveResult[] sharingSaveResults = Database.insert(sharingManagments, false);
            Database.DeleteResult[] tsfDeleteResults = Database.delete(tsfToDelete, false);

            Integer idx=0;
            for(Database.SaveResult sr : sharingSaveResults) {
                Sharing_Mgmt_gne__c sm = sharingManagments[idx++];
                Id crId = crMap.get(sm.Account_Id_gne__c);

                if(!result.containsKey(crId)) {
                    result.put(crId, new List<DmlResult>());
                }

                result.get(crId).add(new DmlResult(sr));
            }

            idx=0;
            for(Database.DeleteResult dr : tsfDeleteResults) {
                TSF_vod__c tsf = tsfToDelete[idx++];
                Id crId = crMap.get(tsf.Account_vod__c);

                if(!result.containsKey(crId)) {
                    result.put(crId, new List<DmlResult>());
                }

                result.get(crId).add(new DmlResult(dr));
            }
        }

		return result;
	}

	private static void cacheParentRecords(List<Change_Request_gne__c> crs) {
		Set<Id> parentIds = new Set<Id>();
		Map<String,String> queries = new Map<String,String>();

		for(Change_Request_gne__c cr : crs) {
			String lookupFieldName = getLookupFieldName(cr);
			String objName = getParentObjectName(cr);

			if(String.isNotBlank(lookupFieldName)) {
				parentIds.add((Id)cr.get(lookupFieldName));

				if(!queries.containsKey(objName)) {
					Set<String> fieldNames = parentObjectFieldNames.get(objName).clone();
					fieldNames.add('ID');
					queries.put(objName, String.format('SELECT {0} FROM {1} WHERE ID IN :parentIds', new String[]{
						String.join(new List<String>(fieldNames),','),
						objName
					}));
				}
			}
		}
		for(String objName : queries.keySet()) {
			cacheParentRecords(objName, Database.query(queries.get(objName)));
		}
	}

	private static void cacheParentRecords(String sObjType, List<SObject> parentRecs) {
		if(parentsCache==null) {
			parentsCache = new Map<String,Map<Id,SObject>>();
		}

		parentsCache.put(sObjType, new Map<Id,SObject>(parentRecs));

	}

	private static String getLookupFieldName(Change_Request_gne__c cr) {
		return dcrRecordTypesToObjectLookupFieldMap.get(dcrRecordTypesNameMap.get(cr.RecordTypeId));
	}

	private static String getParentObjectName(Change_Request_gne__c cr) {
		return dcrRecordTypesToObjectNameMap.get(dcrRecordTypesNameMap.get(cr.RecordTypeId));
	}

	private static SObject updateParentRecord(Change_Request_gne__c cr) {
		SObject parentRec = null;
		String objName = getParentObjectName(cr);
		String lookupFieldName = getLookupFieldName(cr);
		Boolean somethingChanged = false;

		if(String.isNotBlank(objName) && String.isNotBlank(lookupFieldName) && cr.get(lookupFieldName)!=null) {
			parentRec = (SObject)Type.forName(objName).newInstance();
			parentRec.Id = (Id)cr.get(lookupFieldName);
			String dcrRecTypeName = dcrRecordTypesNameMap.get(cr.RecordTypeId);
			Set<String> changedFields = String.isNotBlank(cr.Changed_Fields_gne__c)
				? ((Map<String,ChangedField>)JSON.deserialize(cr.Changed_Fields_gne__c, Map<String,ChangedField>.class)).keySet()
				: new Set<String>();

			for(FieldMapping fm : fieldMappings.get(dcrRecTypeName)) {
				if(changedFields.contains(fm.fieldName) && !fm.isReadOnly && fm.isAutoParentUpdate) {
					if(String.isNotBlank(fm.dcrFieldName)) {
						parentRec.put(fm.fieldName, cr.get(fm.dcrFieldName));
					} else {
						parentRec.put(fm.fieldName, fm.fieldValue);
					}
					somethingChanged= true;

					if(objName == String.valueOf(Account.sObjectType) && fm.fieldName == String.valueOf(Account.Account_Type_gne__c)) {
					    setAccountType(cr, (Account)parentRec);
					}
				}
			}
		}

		return somethingChanged ? parentRec : null;
	}

	private static void setAccountType(Change_Request_gne__c cr, Account acc) {
	    String accType = acc.Account_Type_gne__c!=null ? acc.Account_Type_gne__c.toUpperCase() : null;
        GNE_SFA2_Account_Trigger_Helper.AccountTypeWrapper accTypeWrapper = GNE_SFA2_Account_Trigger_Helper.getAccountTypesMap(cr.Created_By_Profile__c).get(accType);

        if(accTypeWrapper!=null) {
            accTypeWrapper.updateAccount(acc);
        }
	}

	public static Boolean isFieldValueChanged(Object oldValue, Object newValue) {
		return !String.valueOf(oldValue!=null ? oldValue : '').equals(String.valueOf(newValue!=null ? newValue : ''));
	}

	public static void onBeforeUpdateParent(List<SObject> parentRecs) {
		rollbackDcrChangesOnParent(parentRecs);
	}

	public static void onAfterUpdateParent(List<SObject> parentRecsOld, List<SObject> parentRecs) {
		onAfterUpdateParent(parentRecsOld, parentRecs, true);
	}

	public static void onAfterUpdateParent(List<SObject> parentRecsOld, List<SObject> parentRecs, Boolean triggerMode) {
		cacheParentRecords(parentRecsOld.getSObjectType().getDescribe().getName().toUpperCase(), parentRecsOld);
		Map<Id,List<Database.SaveResult>> saveResults = updateDcrChanges(parentRecs, triggerMode);

		if(triggerMode==true && saveResults!=null) {
			Map<Id,SObject> parentsMap = new Map<Id,SObject>(parentRecs);

			for(Id parentId : saveResults.keySet()) {
				SObject parentRec = parentsMap.get(parentId);

				for(Database.SaveResult sr : saveResults.get(parentId)) {
					if(!sr.isSuccess()) {
						for(Database.Error err : sr.getErrors()) {
							parentRec.addError(err.getMessage());
						}
					}
				}
			}
		}

	}

	private static Map<Id,List<Database.SaveResult>> updateDcrChanges(List<SObject> parentRecs, Boolean triggerMode) {
		Map<Id,List<Database.SaveResult>> result;

		if(!parentRecs.isEmpty() && isParentUpdateEnabled() && isUserDcrDataAdmin()) {
			Map<Id, List<Change_Request_gne__c>> crsMap = getDCRsForParents(parentRecs);
			Map<Id, SObject> parentRecsMap = new Map<Id, SObject>(parentRecs);
			List<Change_Request_gne__c> crsToUpdate = new List<Change_Request_gne__c>();
			Map<Id, Id> crIdToParentIdMap = new Map<Id, Id>();

			for(Id parentRecId : crsMap.keySet()) {
				sObject parentRec = parentRecsMap.get(parentRecId);
				for(Change_Request_gne__c cr : crsMap.get(parentRecId)) {
					Map<String,ChangedField> changedFields = getChangedFields(cr, parentRec);
					if(isApprovedForParentUpdate(cr)) {
						Map<String,ChangedField> prevChangedFields = (Map<String,ChangedField>)JSON.deserialize(cr.Changed_Fields_gne__c, Map<String, ChangedField>.class);
						prevChangedFields.putAll(changedFields);
						changedFields = prevChangedFields;
					}

					if(!changedFields.isEmpty()) {
						cr.Changed_Fields_gne__c = JSON.serialize(changedFields);
						crsToUpdate.add(new Change_Request_gne__c(Id = cr.Id, Changed_Fields_gne__c = cr.Changed_Fields_gne__c));
						crIdToParentIdMap.put(cr.Id, parentRec.Id);
					}
				}
			}

			if(!crsToUpdate.isEmpty()) {
				result = new Map<Id,List<Database.SaveResult>>();
				Database.SaveResult[] saveResults = Database.update(crsToUpdate, triggerMode!=true);

				Integer idx = 0;
				for(Database.SaveResult sr : saveResults) {
					Change_Request_gne__c cr = crsToUpdate[idx];
					Id parentId = crIdToParentIdMap.get(cr.Id);

					if(!result.containsKey(parentId)) {
						result.put(parentId, new List<Database.SaveResult>());
					}

					result.get(parentId).add(sr);
					idx++;
				}
			}
		}

		return result;
	}

	private static Boolean isSubcribeMode(){
		return  CORE_Subscribe_Util.isSubscribeProcess();
	}

	private static void rollbackDcrChangesOnParent(List<SObject> parentRecs) {
		if(!parentRecs.isEmpty() && isSubcribeMode() && isParentUpdateEnabled() && isParentBlockEnabled()) {
			Map<Id, List<Change_Request_gne__c>> crsMap = getDCRsForParents(parentRecs);
			Map<Id, SObject> parentRecsMap = new Map<Id, SObject>(parentRecs);

			for(Id parentRecId : crsMap.keySet()) {
				sObject parentRec = parentRecsMap.get(parentRecId);
				for(Change_Request_gne__c cr : crsMap.get(parentRecId)) {
					Map<String,ChangedField> changedFields = (Map<String, ChangedField>)JSON.deserialize(cr.Changed_Fields_gne__c, Map<String, ChangedField>.class);

					for(String parentFieldName : changedFields.keySet()) {
						ChangedField cfld = changedFields.get(parentFieldName);
						String dcrFieldName = cfld.dcrFieldName;
						Object oldValue = String.isNotBlank(dcrFieldName) ? cr.get(dcrFieldName) : cfld.getFieldValue();
						Object newValue = parentRec.get(parentFieldName);

						if(isFieldValueChanged(oldValue,newValue)) {
							parentRec.put(parentFieldName, oldValue);

							if(parentRec instanceof Account && parentFieldName == String.valueOf(Account.Account_Type_gne__c)) {
							    setAccountType(cr, (Account)parentRec);
							}
						}
					}
				}
			}
		}
	}

	private static Map<Id, List<Change_Request_gne__c>> getDCRsForParents(List<SObject> parentRecs) {
		Map<Id, List<Change_Request_gne__c>> result = new Map<Id, List<Change_Request_gne__c>>();
		readConfiguration();
		Set<String> dcrFields = new Set<String>();
		Set<Id> parentIds = new Set<Id>();
		Set<String> lookupFieldNames = new Set<String>();
		Set<String> parentWhereStatements = new Set<String>();

		for(SObject pRec : parentRecs) {
			String objName = pRec.getSObjectType().getDescribe().getName().toUpperCase();
			Set<String> dcrRecTypeNames = dcrObjectNamesToRecordTypeMap.get(objName);
			for(String dcrRecTypeName : dcrRecTypeNames) {
				String lookupFieldName = dcrRecordTypesToObjectLookupFieldMap.get(dcrRecTypeName);

				if(String.isNotBlank(lookupFieldName) && pRec.Id!=null) {
					parentIds.add(pRec.Id);
					lookupFieldNames.add(lookupFieldName);
					dcrFields.addAll(dcrFieldNames.get(dcrRecTypeName));
					parentWhereStatements.add(String.format('({0} IN :parentIds AND RecordType.DeveloperName = \'\'{1}\'\')', new String[] {lookupFieldName, dcrRecTypeName}));

				}
			}
		}

		dcrFields.addAll(new Set<String>{'Id', 'RecordTypeId', 'RecordType.DeveloperName', 'Account_gne__r.RecordType.DeveloperName',
			String.valueOf(Change_Request_gne__c.Approval_State__c),
			String.valueOf(Change_Request_gne__c.Changed_Fields_gne__c),
			String.valueOf(Change_Request_gne__c.Created_By_Profile__c)
		});
		dcrFields.addAll(lookupFieldNames);
		Set<String> approvalStatuses = getDcrBlockValidApprovalStatuses();
		Set<Id> validRecordTypeIds = getParentUpdateValidDcrRecordTypeIds();
		Integer validDcrDays = getDaysForValidDcrs();
		Set<String> closedStatuses = getDcrClosedStatuses();
		String query = String.format(
				'SELECT {0} FROM Change_Request_gne__c WHERE ({1}) AND {2} AND {3} AND {4} AND {5} ORDER BY {6}', new String[]{
					String.join(new List<String>(dcrFields), ','), 							//0
					String.join(new List<String>(parentWhereStatements), ' OR '),			//1
					'Approval_State__c IN :approvalStatuses', 								//2
					'CreatedDate = LAST_N_DAYS:' + validDcrDays,	 						//3
					'RecordTypeId IN :validRecordTypeIds', 									//4
					'Status_gne__c NOT IN :closedStatuses',									//5
					'CreatedDate ASC'														//6
		});
		Map<Id, SObject> parentRecsMap = new Map<Id, SObject>(parentRecs);
		System.debug('TK query ' + query);
		for(Change_Request_gne__c cr : Database.query(query)) {
			if(String.isNotBlank(cr.Changed_Fields_gne__c)) {
				String lookupFieldName = getLookupFieldName(cr);
				Id parentId = (Id)cr.get(lookupFieldName.toLowerCase());

				if(!result.containsKey(parentId)) {
					result.put(parentId, new List<Change_Request_gne__c>());
				}
				result.get(parentId).add(cr);
			}
		}
		return result;
	}

	/*Return map with mapping from address or account fields to dcr field name */
    public static Map<String, String>getAddressDCRFieldMapping(String dcrRecordTypeDeveloperName){
    	Map<String, String>result = new Map<String, String>();

		for(GNE_SFA2_DCR_Config_Items_gne__c ci : GNE_SFA2_DCR_Config_Items_gne__c.getAll().values()) {
			String ciType = ci.Configuration_Type_gne__c;
			String key = ci.Key_gne__c.toUpperCase();

			if(ci.Is_Active_gne__c) {
				if(ciType == GNE_SFA2_DCR_Util.ConfigurationType.FieldMapping.name()) {
					String[] keyData = key.split(GNE_SFA2_DCR_Util.LIST_DELIMETER, 3);
					String recType = !keyData.isEmpty() ? keyData.remove(0) : null;
					if(recType == dcrRecordTypeDeveloperName){
						if(ci.Value_gne__c != null){
							String[] fieldMappingData = ci.Value_gne__c.split(GNE_SFA2_DCR_Util.LIST_DELIMETER,2);
							if(!String.isEmpty(fieldMappingData[0]) && !String.isEmpty(fieldMappingData[1])){
								result.put(fieldMappingData[0], fieldMappingData[1]);
							}
						}
					}
				}
			}
		}
		return result;
    }

	private static void readConfiguration() {
		if(mainConfig==null) {
			mainConfig = new Map<String,String>();
			fieldMappings = new Map<String,List<FieldMapping>>();
			parentObjectFieldNames = new Map<String,Set<String>>();
			dcrFieldNames = new Map<String,Set<String>>();
			dcrRecordTypesIdMap = new Map<String,Id>();
			dcrRecordTypesNameMap = new Map<Id,String>();
			dcrRecordTypesToObjectNameMap = new Map<String,String>();
			dcrObjectNamesToRecordTypeMap = new Map<String,Set<String>>();
			dcrRecordTypesToObjectLookupFieldMap = new Map<String,String>();
			Map<String,GNE_SFA2_DCR_Config_Items_gne__c> configItems = GNE_SFA2_DCR_Config_Items_gne__c.getAll();
			List<String> orderedItemNames = new List<String>(configItems.keySet());
			orderedItemNames.sort();

			for(String iName : orderedItemNames) {
				GNE_SFA2_DCR_Config_Items_gne__c ci = configItems.get(iName);
				String ciType = ci.Configuration_Type_gne__c;
				String key = ci.Key_gne__c.toUpperCase();

				if(ci.Is_Active_gne__c) {
					if(ciType == ConfigurationType.Main.name() && String.isNotBlank(ci.Value_gne__c)) {
						mainConfig.put(key, (mainConfig.containsKey(key) ? mainConfig.get(key) : '')  + ci.Value_gne__c);
					} else if(ciType == ConfigurationType.FieldMapping.name()) {
						String[] keyData = key.split(LIST_DELIMETER, 3);
						String recType = !keyData.isEmpty() ? keyData.remove(0) : null;
						String objName = !keyData.isEmpty() ? keyData.remove(0) : null;
						String lookupFieldName = !keyData.isEmpty() ? keyData.remove(0) : null;

						if(String.isNotBlank(recType) && String.isNotBlank(objName) && String.isNotBlank(lookupFieldName)) {
							dcrRecordTypesToObjectNameMap.put(recType, objName);
							dcrRecordTypesToObjectLookupFieldMap.put(recType, lookupFieldName);

							if(!dcrObjectNamesToRecordTypeMap.containsKey(objName)) {
								dcrObjectNamesToRecordTypeMap.put(objName, new Set<String>());
							}

							dcrObjectNamesToRecordTypeMap.get(objName).add(recType);

							if(!fieldMappings.containsKey(recType)) {
								fieldMappings.put(recType, new List<FieldMapping>());
							}

							FieldMapping fm = new FieldMapping(recType, objName, ci);
							fieldMappings.get(recType).add(fm);

							if(!parentObjectFieldNames.containsKey(objName)) {
								parentObjectFieldNames.put(objName, new Set<String>());
							}

							if(String.isNotBlank(fm.fieldName)) {
								parentObjectFieldNames.get(objName).add(fm.fieldName);
							}

							if(!dcrFieldNames.containsKey(recType)) {
								dcrFieldNames.put(recType, new Set<String>());
							}

							if(String.isNotBlank(fm.dcrFieldName)) {
								dcrFieldNames.get(recType).add(fm.dcrFieldName);
							}
						}
					}
				}
			}
        	for(RecordType rtInfo : [SELECT id, DeveloperName, Name FROM RecordType WHERE sobjecttype ='change_request_gne__c']) {
	            Id rtId = rtInfo.id;
	            String rtName = rtInfo.DeveloperName.toUpperCase();
	            dcrRecordTypesIdMap.put(rtName, rtId);
	            dcrRecordTypesNameMap.put(rtId, rtName);
	        }
		}
	}

	public static Boolean isParentUpdateEnabled() {
		if(isParentUpdateEnabled==null) {
			readConfiguration();
			String enabledInString = mainConfig.get(MainConfigType.ParentUpdateEnabled.name().toUpperCase());
			isParentUpdateEnabled = new Set<String>{'1', 'YES', 'TRUE'}.contains(enabledInString!=null ? enabledInString.toUpperCase() : '');
		}
		return isParentUpdateEnabled;
	}

	public static Boolean isParentBlockEnabled() {
		if(isParentBlockEnabled==null) {
			readConfiguration();
			String enabledInString = mainConfig.get(MainConfigType.ParentBlockEnabled.name().toUpperCase());
			isParentBlockEnabled = new Set<String>{'1', 'YES', 'TRUE'}.contains(enabledInString!=null ? enabledInString.toUpperCase() : '');
		}

		return isParentBlockEnabled;
	}

	public static Boolean isUserDcrDataAdmin() {
		if(isUserDcrDataAdmin==null) {
			readConfiguration();
			String dcrAdminProfileMask = mainConfig.get(MainConfigType.DcrDataAdminProfileMask.name().toUpperCase());
			String profileName = GNE_SFA2_Util.getCurrentUserProfileName();
			isUserDcrDataAdmin = String.isNotBlank(dcrAdminProfileMask) && String.isNotBlank(profileName) && Pattern.matches(dcrAdminProfileMask, profileName);
		}

		return isUserDcrDataAdmin;
	}
	/*Return map: dcr status -> List of account record types.
	If list of record types is empty it means that this status is valid for all record types, otherwise it is only valid for specific record types.
	*/
	private static Map<String, Set<String>> getDcrValidApprovalStatuses() {
		if(dcrValidApprovalStatuses==null) {
			readConfiguration();
			String asInString = mainConfig.get(MainConfigType.ParentUpdateDcrApprovalStatuses.name().toUpperCase());
			dcrValidApprovalStatuses = new Map<String, Set<String>>();
			for(String statusWithRT : asInString.toUpperCase().split(LIST_DELIMETER)){
				if(statusWithRT.startsWith(ARRAY_OPEN_MARK)){
					Set<String> recordTypes = new Set<String>(statusWithRT.substring(1, statusWithRT.indexOf(ARRAY_CLOSE_MARK)).split(LIST_COMMA_DELIMETER));
					String status = statusWithRT.substring(statusWithRT.indexOf(ARRAY_CLOSE_MARK)+1).trim();
					dcrValidApprovalStatuses.put(status, recordTypes);
				}else {
					dcrValidApprovalStatuses.put(statusWithRT, null);
				}
			}
		}

		return dcrValidApprovalStatuses;
	}

	private static Set<String> getDcrBlockValidApprovalStatuses() {
		if(dcrBlockValidApprovalStatuses==null) {
			readConfiguration();
			String asInString = mainConfig.get(MainConfigType.ParentBlockDcrApprovalStatuses.name().toUpperCase());
			dcrBlockValidApprovalStatuses = new Set<String>((asInString!=null ? asInString.toUpperCase() : '').split(LIST_DELIMETER));
		}

		return dcrBlockValidApprovalStatuses;
	}

	private static Set<String> getDcrClosedStatuses() {
		if(dcrClosedStatuses==null) {
			readConfiguration();
			String csInString = mainConfig.get(MainConfigType.DcrClosedStatuses.name().toUpperCase());
			dcrClosedStatuses = new Set<String>((csInString!=null ? csInString.toUpperCase() : '').split(LIST_DELIMETER));
		}

		return dcrClosedStatuses;
	}

	private static Set<Id> getParentUpdateValidDcrRecordTypeIds() {
		if(parentUpdateValidDcrRecorTypeIds==null) {
			readConfiguration();
			parentUpdateValidDcrRecorTypeIds = new Set<Id>();
			String rtInString = mainConfig.get(MainConfigType.ParentUpdateDcrRecordTypes.name().toUpperCase());
			Set<String> dcrValidRecordTypes = new Set<String>((rtInString!=null ? rtInString.toUpperCase() : '').split(LIST_DELIMETER));

			for(String validRecordType : dcrValidRecordTypes) {
				parentUpdateValidDcrRecorTypeIds.add(dcrRecordTypesIdMap.get(validRecordType));
			}
		}

		return parentUpdateValidDcrRecorTypeIds;
	}

	private static Set<Id> getAddressInactivateRecordTypeIds() {
		if(addressInactivateRecordTypeIds==null) {
			readConfiguration();
			addressInactivateRecordTypeIds = new Set<Id>();
			String rtInString = mainConfig.get(MainConfigType.AddressInactivateRecordTypes.name().toUpperCase());
			Set<String> recordTypes = new Set<String>((rtInString!=null ? rtInString.toUpperCase() : '').split(LIST_DELIMETER));

			for(String validRecordType : recordTypes) {
				addressInactivateRecordTypeIds.add(dcrRecordTypesIdMap.get(validRecordType));
			}
		}
		return addressInactivateRecordTypeIds;
	}

	private static Set<Id> getAccountInactivateRecordTypeIds() {
		if(accountInactivateRecordTypeIds==null) {
			readConfiguration();
			accountInactivateRecordTypeIds = new Set<Id>();
			String rtInString = mainConfig.get(MainConfigType.AccountInactivateRecordTypes.name().toUpperCase());
			Set<String> recordTypes = new Set<String>((rtInString!=null ? rtInString.toUpperCase() : '').split(LIST_DELIMETER));

			for(String validRecordType : recordTypes) {
				accountInactivateRecordTypeIds.add(dcrRecordTypesIdMap.get(validRecordType));
			}
		}
		return accountInactivateRecordTypeIds;
	}

	private static Integer getDaysForValidDcrs() {
		if(daysForValidDcrs==null) {
			readConfiguration();
			String daysInString = mainConfig.get(MainConfigType.DaysForValidDcrs.name().toUpperCase());
			daysForValidDcrs = String.isNotBlank(daysInString) && daysInString.isNumericSpace() ? Integer.valueOf(daysInString) : 90;
		}

		return daysForValidDcrs;
	}

	private static Set<String> getBrandTeams() {
	    if(brandTeams==null) {
            readConfiguration();
            String brandTeamsInString = mainConfig.get(MainConfigType.BrandTeams.name().toUpperCase());
            brandTeams = new Set<String>((brandTeamsInString!=null ? brandTeamsInString : '').split(LIST_COMMA_DELIMETER));
        }

        return brandTeams;
	}

	private class FieldMapping {
		private String recordType;
		private String objectName;
		private String fieldName;
		private Object fieldValue;
		private String dcrFieldName;
		private String label;
		private Boolean isReadOnly;
		private Boolean isAutoParentUpdate;
		private String userPattern;

		private FieldMapping(String recType, String objName, GNE_SFA2_DCR_Config_Items_gne__c ci) {
			recordType = recType;
			objectName = objName;
			String[] fieldMappingData = (ci.Value_gne__c!=null ? ci.Value_gne__c : '').split(LIST_DELIMETER,2);
			fieldName = !fieldMappingData.isEmpty() ? fieldMappingData.remove(0) : null;
			dcrFieldName = !fieldMappingData.isEmpty() ? fieldMappingData.remove(0) : null;

			if(String.isNotBlank(dcrFieldName) && Pattern.matches(FIELD_MAPPING_VALUE_PATTERN, dcrFieldName)) {
				String fieldValueAsString = dcrFieldName.replaceAll(FIELD_MAPPING_VALUE_PATTERN,'$1');
				fieldValue = String.isNotBlank(fieldValueAsString) ? JSON.deserializeUntyped(fieldValueAsString) : null;
				dcrFieldName = null;
			}

			label = ci.Field_Label_gne__c;
			isReadOnly = ci.Is_Read_Only_gne__c;
			isAutoParentUpdate = ci.Update_Parent_gne__c;
			userPattern = ci.User_Pattern_gne__c;
		}
	}

	private class ChangedField {
		private String fieldName;
		private String dcrFieldName;
		private String fieldValue;

		private ChangedField(String fieldName, String dcrFieldName, Object fieldValue) {
			setFieldValue(fieldValue);
			this.fieldName = fieldName;
			this.dcrFieldName = dcrFieldName;
		}

		private Object getFieldValue() {
			return String.isNotBlank(fieldValue) ? JSON.deserializeUntyped(fieldValue) : null;
		}

		private void setFieldValue(Object value) {
			this.dcrFieldName=null;
			this.fieldValue = JSON.serialize(value);
		}
	}

	public static Change_Request_gne__c getDCR(Id dcrId){
		return [SELECT Id, Name, createdbyid, lastmodifiedbyid, ownerid, recordTypeId, RecordType.Name, RecordType.DeveloperName, First_Name_DCR_gne__c, last_name_dcr_gne__c, professional_type_dcr_gne__c,
						suffix_dcr_gne__c, new_value_2_gne__c, credentials_dcr_gne__C, specialties_hcp_dcr_gne__c, New_Organization_Name_gne__c, account_type_dcr_Gne__c,Specialties_HCO_DCR_gne__c,
						notes_gne__c, new_note_gne__c, current_address_glid_gne__c, reason_dcr_gne__c, remove_inactive_address_gne__c, current_address_gne__c, current_address_gne__r.Name,
					 	Duplicate_Address_2_gne__c, Duplicate_Address_2_gne__r.Name, Duplicate_Address_3_gne__c, Duplicate_Address_3_gne__r.Name, address_line_1_gne__c, city_gne__c, state_gne__c, zip_gne__c,
						address_line_2_gne__c, address_line_3_gne__c, address_Line_4_gne__c, vendor_notes_gne__c, new_vendor_note_gne__c, createddate, lastmodifieddate, approval_state__c, status_gne__c, status_cs_gne__c,
						assigned_analyst_gne__c,assigned_analyst_gne__r.Name, createdby.Name, lastmodifiedby.name, type_gne__c, Data_Vendor_Changes_gne__c,
						ams_id_1_gne__c, ams_id_gne__c, Account_gne__c, Account_gne__r.Name, Account_gne__r.RecordType.DeveloperName, Account_gne__r.MDMID_gne__c,
						Duplicate_Account_2_gne__c, ams_id_2_gne__c, Duplicate_Account_2_gne__r.Name, Duplicate_Account_2_gne__r.MDMID_gne__c,
						Duplicate_Account_3_gne__c, ams_id_3_gne__c, Duplicate_Account_3_gne__r.Name, Duplicate_Account_3_gne__r.MDMID_gne__c,
						Duplicate_Account_4_gne__c, ams_id_4_gne__c, Duplicate_Account_4_gne__r.Name, Duplicate_Account_4_gne__r.MDMID_gne__c,
						Duplicate_Account_5_gne__c, ams_id_5_gne__c, Duplicate_Account_5_gne__r.Name, Duplicate_Account_5_gne__r.MDMID_gne__c,
						description_gne__c, vendor_type_gne__c, load_status_gne__c, account_mdmid_gne__C, current_address_MDMId_gne__c,
						verify_hcp_credentials_gne__c, verify_hcp_specialties_gne__c, Verify_HCO_Specialties_gne__c, Duplicate_Account_Roche_ID_can_gne__c, Current_Address_Roche_ID_can_gne__c, Account_Roche_ID_can_gne__c, Account_Group_gne__c,
						Province_can_gne__c, Postal_Code_can_gne__c, License_State_gne__c, License_Number_gne__c, HCP_National_Provider_Id_gne__c
				FROM Change_Request_gne__c
				WHERE id =:dcrId];
	}

	public class DmlResult {
         private Boolean isSuccess;
         private Database.Error[] errors;

         public DmlResult(Database.SaveResult sr) {
             this.isSuccess = sr.isSuccess();
             this.errors = sr.getErrors();
         }

         public DmlResult(Database.DeleteResult dr) {
             this.isSuccess = dr.isSuccess();
             this.errors = dr.getErrors();
         }

         public Boolean isSuccess() {
             return isSuccess;
         }

         public Database.Error[] getErrors() {
             return errors;
         }
    }
}