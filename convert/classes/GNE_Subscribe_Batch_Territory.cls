global class GNE_Subscribe_Batch_Territory extends GNE_Subscribe_Batchable implements Database.Batchable<sObject>, Database.Stateful {

	private static final String STG_TERRITORY_NEW_STATE = 'Loaded';
	private static final String STG_TERRITORY_ERROR_STATE = 'Error Processing';
	private static final String STG_TERRITORY_SUCCESS_STATE = 'Processed';

	public static final String COMMENT_RESULT_STATUS_NEW 		= '[Result: New]';
	public static final String COMMENT_RESULT_STATUS_UPDATE 	= '[Result: Update]';
	public static final String COMMENT_RESULT_STATUS_NOCHANGE 	= '[Result: No Change]';
	public static final String COMMENT_RESULT_STATUS_DEACTIVATE	= '[Result: Deactivate]';
	public static final String COMMENT_RESULT_STATUS_ERROR 		= '[Result: Error]';
	public static final String COMMENT_DELIMETER		 		= '|';
	public static final String COMMENT_FIELD_LIST_DELIMETER		= ',';
	public static final String COMMENT_PREVIEW_MODE_PREFIX		= 'PREVIEW';

	public static final String US_ROOT_TERRITORY_NAME = 'GNE-US';
	public static String INACTIVE_ROOT_TERRITORY_NAME = 'INACTIVE TERRITORIES';

	public static final String ACCOUNT_ACCESS_LEVEL = 'Edit';

	private integer upsertedTerrCount = 0;
	private integer errorTerrCount = 0;
	private integer updatedStgTerrCount = 0;
	private integer errorStgTerrCount = 0;

	global Boolean previewMode = false;

	private List<Staging_Territory_Def_gne__c> stgTerritories = new List<Staging_Territory_Def_gne__c>();
	private Set<String> alreadyDeactivatedTerritoriesExternalIds = new Set<String>();
	private Map<String, Territory2> territoryCache = new Map<String, Territory2>();
	private Map<String, Set<String>> parentTerritoryToDirectChildrenCache = new Map<String, Set<String>>();
	private Territory2 inactiveTerritory;
	private Id terrModelId = [SELECT Id FROM Territory2Model LIMIT 1].Id;
	private Id terrTypeId = [SELECT Id FROM Territory2Type LIMIT 1].Id;

	global GNE_Subscribe_Batch_Territory(Boolean prevMode) {
		previewMode = prevMode;
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		System.debug('Starting subscribe batch update');
		initTerritoryCache();
		// select all territories in Loaded state and activation or deactivaion date <= Today
		return Database.getQueryLocator ([
		                                     SELECT Id, Territory_External_ID_gne__c, Territory_Nbr_gne__c, Territory_Name_gne__c, Parent_Territory_External_ID_gne__c, Activation_Date_gne__c,
		                                     Territory_Description_gne__c, Territory_Source_gne__c, End_Date_gne__c,
		                                     Territory_ID_gne__c, Status_gne__c, Comment_gne__c, Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c
		                                     FROM Staging_Territory_Def_gne__c
		                                     WHERE Status_gne__c = :STG_TERRITORY_NEW_STATE
		                                             AND (Activation_Date_gne__c <= Today or End_Date_gne__c <= Today)
		                                             ORDER BY Parent_Territory_External_ID_gne__c, Territory_Nbr_gne__c, Territory_Name_gne__c asc
		                                 ]);
	}

	private void initTerritoryCache() {
		Map<Id, Territory2> territories = new Map<Id, Territory2>([
		            SELECT Id, ParentTerritory2Id, Name, Description,
		            Territory_Number_gne__c, Source_gne__c, End_Date__c,
		            Parent_External_Id_gne__c, External_Id_gne__c, Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c
		            FROM Territory2
		        ]);

		Map<String, Territory2> terrTempCache = new Map<String, Territory2>();
		Map<String, Set<String>> parentToDirectChildrenTempMap = new Map<String, Set<String>>();

		for (Territory2 tempTerr : territories.values()) {
			if (tempTerr.Name.equalsIgnoreCase(INACTIVE_ROOT_TERRITORY_NAME)) {
				inactiveTerritory = tempTerr;
				continue;
			}

			// Cache only US Territories
			Territory2 currentTerr = tempTerr;
			terrTempCache.clear();
			parentToDirectChildrenTempMap.clear();

			while (true) {
				if (currentTerr.External_Id_gne__c != null) {
					terrTempCache.put(currentTerr.External_Id_gne__c.toUpperCase(), currentTerr);
				}

				if ((currentTerr.External_Id_gne__c != null && territoryCache.containsKey(currentTerr.External_Id_gne__c.toUpperCase())) ||
				        (currentTerr.ParentTerritory2Id == null && currentTerr.Name == 'GNE-US')) {
					territoryCache.putAll(terrTempCache);

					// Merge parent to direct children into global cache
					for (String parentExtId : parentToDirectChildrenTempMap.keySet()) {
						if (!parentTerritoryToDirectChildrenCache.containsKey(parentExtId)) {
							parentTerritoryToDirectChildrenCache.put(parentExtId, parentToDirectChildrenTempMap.get(parentExtId));
						} else {
							parentTerritoryToDirectChildrenCache.get(parentExtId).addAll(parentToDirectChildrenTempMap.get(parentExtId));
						}
					}

					break;
				} else if (currentTerr.ParentTerritory2Id == null) {
					break;
				} else {
					Territory2 parentTerr = territories.get(currentTerr.ParentTerritory2Id);

					// Remember parent-child relation
					if (parentTerr.External_Id_gne__c != null && currentTerr.External_Id_gne__c != null) {
						String parentExtId = parentTerr.External_Id_gne__c.toUpperCase();
						if (!parentToDirectChildrenTempMap.containsKey(parentExtId))
							parentToDirectChildrenTempMap.put(parentExtId, new Set<String>());
						parentToDirectChildrenTempMap.get(parentExtId).add(currentTerr.External_Id_gne__c.toUpperCase());
					}
					currentTerr = parentTerr;
				}
			}
		}
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		System.debug('Executing subscribe batch update, scope: ' + scope.size());
		String dbgMsg = '';

		// exit if scope is empty
		if (scope.size() == 0) {
			return;
		}

		stgTerritories.addAll((List<Staging_Territory_Def_gne__c>) scope);

		List<Territory2> territoriesToUpsert = new List<Territory2>();
		Map<String, Staging_Territory_Def_gne__c> terrIdToStgTerritory = new Map<String, Staging_Territory_Def_gne__c>();

		// here begins actual territory assignement and unassigment
		for (Staging_Territory_Def_gne__c stgTerr : (List<Staging_Territory_Def_gne__c>) scope) {
			System.debug('BOS:: Staging record: ' + stgTerr);
			stgTerr.Comment_gne__c = '';
			stgTerr.Territory_ID_gne__c = '';
			Boolean isTerritoryDeactivation = stgTerr.End_Date_gne__c <= date.today();

			// if it is not territory deactivation and there is no parent territory in sfdc and in batch
			if (!isTerritoryDeactivation && String.isNotBlank(stgTerr.Parent_Territory_External_ID_gne__c) && !territoryCache.containsKey(stgTerr.Parent_Territory_External_ID_gne__c.toUpperCase())) {
				markStagingTerrWithError(stgTerr, 'Parent territory with external id = \'' + stgTerr.Parent_Territory_External_ID_gne__c + '\' not exist.');
			} else if (stgTerr.Activation_Date_gne__c > stgTerr.End_Date_gne__c) { // activation date is after deactivation date
				markStagingTerrWithError(stgTerr, 'Acivation Date cannot be greater than End Date.');
			} else {
				String territoryExternalId = String.isNotBlank(stgTerr.Territory_External_ID_gne__c) ? stgTerr.Territory_External_ID_gne__c : generateTerritoryExternalId(stgTerr);
				String terrExtIdUC = territoryExternalId.toUpperCase();

				if (isTerritoryDeactivation) {	// territory deactivation
					Boolean territoryExists = territoryCache.containsKey(terrExtIdUC);

					if (territoryExists) {
						Territory2 tmpTerritory = territoryCache.get(terrExtIdUC);
						terrIdToStgTerritory.put(tmpTerritory.Id, stgTerr);
						if (alreadyDeactivatedTerritoriesExternalIds.contains(terrExtIdUC)) {
							// territory was already deactivated by parent
							markStagingTerrWithError(stgTerr, 'Territory ' + territoryExternalId + ' was already deactiavted by parent.');
						} else {
							deactivateTerritoryHierarchy(tmpTerritory, stgTerr);
							territoriesToUpsert.add(tmpTerritory);
						}
					} else {
						markStagingTerrWithError(stgTerr, 'Territory with external id = \'' + territoryExternalId + '\' not exist.');
					}
				} else {		// creating/updating territories
					Boolean territoryExists = territoryCache.containsKey(terrExtIdUC);
					Territory2 tmpTerritory = territoryExists ? territoryCache.get(terrExtIdUC) : createTerritoryFromStagingTerritory(stgTerr, territoryExternalId);

					if (territoryExists) {
						terrIdToStgTerritory.put(tmpTerritory.Id, stgTerr);

						if (updateTerritoryFromStagingTerritory(tmpTerritory, stgTerr)) {
							territoriesToUpsert.add(tmpTerritory);
						}
					} else {
						territoriesToUpsert.add(tmpTerritory);
						terrIdToStgTerritory.put(generateUniqueTerritoryId(tmpTerritory), stgTerr);
					}

					// Cache newly inserted or changed territory
					if (!territoryCache.containsKey(tmpTerritory.External_Id_gne__c.toUpperCase())) {
						territoryCache.put(tmpTerritory.External_Id_gne__c.toUpperCase(), tmpTerritory);
					}
				}
			}
		}

		// upsert territories
		if (previewMode) {
			Savepoint sp = Database.setSavepoint();
			upsertTerritories(territoriesToUpsert, terrIdToStgTerritory);
			Database.rollback(sp);
		} else {
			upsertTerritories(territoriesToUpsert, terrIdToStgTerritory);
		}
	}

	global void finish(Database.BatchableContext BC) {
		for (Staging_Territory_Def_gne__c stgTerr : (List<Staging_Territory_Def_gne__c>) stgTerritories) {
			if (stgTerr.Status_gne__c != STG_TERRITORY_ERROR_STATE) {
				stgTerr.Status_gne__c = STG_TERRITORY_SUCCESS_STATE;
			}

			if (previewMode) {
				stgTerr.Comment_gne__c = '[' + COMMENT_PREVIEW_MODE_PREFIX + ' ' + (stgTerr.Comment_gne__c != '' ?
				                         stgTerr.Comment_gne__c.substring(1) :
				                         ']');
				stgTerr.Status_gne__c  = STG_TERRITORY_NEW_STATE;
			}
		}

		// For safety reason - if Comment text is too long.
		Database.DMLOptions dml = new Database.DMLOptions();
		dml.allowFieldTruncation = true;
		dml.optAllOrNone = false;
		Database.SaveResult[] stgTerrResults = Database.update(stgTerritories, dml);
		if (stgTerrResults != null) {
			Integer iCount = 0;
			for (Database.SaveResult result : stgTerrResults) {
				Staging_Territory_Def_gne__c stgTerr = (Staging_Territory_Def_gne__c) stgTerritories[iCount];

				if (!result.isSuccess()) {
					errorStgTerrCount++;
					Database.Error[] errs = result.getErrors();

					for (Database.Error err : errs) {
						System.debug('BOS:: ' + stgTerr.Id + ': ' + err.getStatusCode() + ' - ' + err.getMessage());
					}
				} else {
					updatedStgTerrCount++;
				}

				iCount++;
			}
		}
		System.debug('Finishing subscribe batch update.');
	}

	private void upsertTerritories(List<Territory2> territoriesToUpsert, Map<String, Staging_Territory_Def_gne__c> terrIdToStgTerritory) {
		Database.UpsertResult[] results = Database.upsert(territoriesToUpsert, false);

		if (results != null) {
			Integer iCount = 0;
			for (Database.UpsertResult result : results) {
				Territory2 tmpTerritory = territoriesToUpsert[iCount];
				Staging_Territory_Def_gne__c stgTerr = null;

				if (terrIdToStgTerritory.containsKey(tmpTerritory.Id)) {
					stgTerr = terrIdToStgTerritory.get(tmpTerritory.Id);
				} else if (terrIdToStgTerritory.containsKey(generateUniqueTerritoryId(tmpTerritory))) {
					stgTerr = terrIdToStgTerritory.get(generateUniqueTerritoryId(tmpTerritory));
				}

				if (stgTerr == null) {
					iCount++;
					System.debug(LoggingLevel.ERROR, 'BOS:: Matching Staging record not found. Something not right. Territory unique key: ' );
					continue;
				}

				if (result.isSuccess()) {
					if (stgTerr.Territory_ID_gne__c == '') {
						stgTerr.Territory_ID_gne__c = tmpTerritory.Id;
					}
					upsertedTerrCount++;

				} else {
					Database.Error[] errs = result.getErrors();

					// This is preview mode. Sometimes parent can be missing, bacause it could be inserted
					// in the same batch process. In that case, before reporting an error make sure that
					// Parent Territory is also missing in cache, because in cache we are storing all existing
					// and newly inseted Territories.
					if (previewMode &&
					        errs.size() == 1 && errs[0].getMessage().contains('Could not find the Parent Territory') &&
					        territoryCache.containsKey(tmpTerritory.Parent_External_Id_gne__c.toUpperCase())) {

						upsertedTerrCount++;
					} else {
						// Remove from cache. We don't want to store territories that failed
						if (territoryCache.containsKey(tmpTerritory.External_Id_gne__c.toUpperCase()) &&
						        tmpTerritory.Id == null) {
							territoryCache.remove(tmpTerritory.External_Id_gne__c.toUpperCase());
						}

						String errorMsg = '';
						for (Database.Error err : errs) {
							if (errorMsg != '') errorMsg += '|';
							errorMsg += err.getStatusCode() + ' - ' + err.getMessage();
						}

						markStagingTerrWithError(stgTerr, errorMsg);
						errorTerrCount++;
					}
				}
				iCount++;
			}
		}
	}

	private String generateUniqueTerritoryId(Territory2 tmpTerritory) {
		return tmpTerritory.External_Id_gne__c.toUpperCase();
	}

	private String generateTerritoryExternalId(Staging_Territory_Def_gne__c stgTerr) {
		return '' + stgTerr.Parent_Territory_External_ID_gne__c + ';' + generateTerritoryName(stgTerr);
	}

	private String generateTerritoryName(Staging_Territory_Def_gne__c stgTerr) {

		Boolean nameContainsOnlyNumber = stgTerr.Territory_Name_gne__c.equals(stgTerr.Territory_Nbr_gne__c) &&
		                                 stgTerr.Territory_Name_gne__c.startsWith('0') &&
		                                 !stgTerr.Territory_Name_gne__c.contains('-');

		if (!nameContainsOnlyNumber &&
		        stgTerr.Territory_Name_gne__c.indexOf(stgTerr.Territory_Nbr_gne__c) == 0) {
			return stgTerr.Territory_Name_gne__c;
		}
		return '' + stgTerr.Territory_Nbr_gne__c + '-' + stgTerr.Territory_Name_gne__c;
	}

	private void deactivateTerritoryHierarchy(Territory2 rootTerritory, Staging_Territory_Def_gne__c stgTerr) {

		List<Territory2> territoriesToUpsert = new List<Territory2> {rootTerritory};

		rootTerritory.Name = generateTerritoryName(stgTerr);
		rootTerritory.Description = stgTerr.Territory_Description_gne__c;
		rootTerritory.source_gne__c = stgTerr.Territory_Source_gne__c;
		rootTerritory.End_Date__c = stgTerr.End_Date_gne__c;

		Integer idx = 0;
		while (true) {
			if (territoriesToUpsert.size() == idx)
				break;
			Territory2 currentTerr = territoriesToUpsert.get(idx++);
			if (parentTerritoryToDirectChildrenCache.containsKey(currentTerr.External_Id_gne__c.toUpperCase())) {
				for (String childExtId : parentTerritoryToDirectChildrenCache.get(currentTerr.External_Id_gne__c.toUpperCase())) {
					if (territoryCache.containsKey(childExtId)) {
						Territory2 childTerr = territoryCache.get(childExtId);
						territoriesToUpsert.add(childTerr);
					}
				}
			}

			alreadyDeactivatedTerritoriesExternalIds.add(currentTerr.external_id_gne__c.toUpperCase());
			// Root Territory - change the parent to INACTIVE TERRITORIES
			if (idx == 1) {
				currentTerr.parent_external_id_gne__c = inactiveTerritory.external_id_gne__c;
				currentTerr.ParentTerritory2Id = inactiveTerritory.Id;
			} else {
				currentTerr.parent_external_id_gne__c = inactiveTerritory.Name + '-' + currentTerr.parent_external_id_gne__c + '_OLD';
			}

			currentTerr.external_id_gne__c = inactiveTerritory.Name + '-' + currentTerr.external_id_gne__c + '_OLD';
		}

		// Root territory will be updated in upsertTerritories() method
		territoriesToUpsert.remove(0);

		if (previewMode) {
			Savepoint sp = Database.setSavepoint();
			Database.update(territoriesToUpsert);
			Database.rollback(sp);
		} else {
			Database.update(territoriesToUpsert);
		}

		stgTerr.Territory_ID_gne__c = rootTerritory.Id;
		stgTerr.Comment_gne__c = COMMENT_RESULT_STATUS_DEACTIVATE;
	}

	private Boolean updateTerritoryFromStagingTerritory(Territory2 terr, Staging_Territory_Def_gne__c stgTerr) {
		Map<String, Object> proposedValues = new Map<String, Object> {
			'Name' => generateTerritoryName(stgTerr),
			'Parent_External_Id_gne__c' => stgTerr.Parent_Territory_External_ID_gne__c,
			'Description' => stgTerr.Territory_Description_gne__c,
			'Source_gne__c' => stgTerr.Territory_Source_gne__c,
			'External_Id_gne__c' => generateTerritoryExternalId(stgTerr),
			'End_Date__c' => stgTerr.End_Date_gne__c,
			'Salesforce_Code_gne__c' => stgTerr.Salesforce_Code_gne__c,
			'Salesforce_SubTeam_Code_gne__c' => stgTerr.Salesforce_SubTeam_Code_gne__c
		};

		List<String> changedFieldNames = new List<String>();

		for (String fieldName : proposedValues.keySet()) {
			Object oldValue = terr.get(fieldName);
			Object newValue = proposedValues.get(fieldName);
			if (oldValue != newValue) {
				changedFieldNames.add(fieldName);
				terr.put(fieldName, newValue);
			}
		}

		String comment;
		if (!changedFieldNames.isEmpty()) {
			changedFieldNames.sort();
			comment = '';
			for (String fieldName : changedFieldNames) {
				if (comment != '') comment += COMMENT_FIELD_LIST_DELIMETER;
				comment += fieldName;
			}
			comment = COMMENT_RESULT_STATUS_UPDATE + COMMENT_DELIMETER + comment;
		} else {
			comment = COMMENT_RESULT_STATUS_NOCHANGE;
		}

		stgTerr.Territory_ID_gne__c = terr.Id;
		stgTerr.Comment_gne__c = comment;

		return !changedFieldNames.isEmpty();
	}

	private Territory2 createTerritoryFromStagingTerritory(Staging_Territory_Def_gne__c stgTerr, String territoryExternalId) {
		// 12-07-2013 Dominik Wasilewski: added Salesforce_Code_gne__c and Salesforce_SubTeam_Code_gne__c to creation logic
		Territory2 tmpTerritory = new Territory2(
		    Territory2ModelId = terrModelId,
			Territory2TypeId = terrTypeId,
			Name = generateTerritoryName(stgTerr),
			DeveloperName = 'DN_' + generateTerritoryName(stgTerr).replaceAll('[|\\,|\\.|\\,||"||\\:|\\~|\\!|\\/|\\@|\\#|\\$|\\%|\\^|\\&|\\*|\\-|\\_|\\+|\\=|\\<|\\>|\\?|\\(|\\)|\\{|\\}|\\;|\\\'"]', '').replaceAll(' ', ''),
		    AccountAccessLevel = ACCOUNT_ACCESS_LEVEL,
		    parent_external_id_gne__c = stgTerr.Parent_Territory_External_ID_gne__c,
		    Description = stgTerr.Territory_Description_gne__c,
		    source_gne__c = stgTerr.Territory_Source_gne__c,
		    external_id_gne__c = territoryExternalId,
		    End_Date__c = stgTerr.End_Date_gne__c,
		    Salesforce_Code_gne__c = stgTerr.Salesforce_Code_gne__c,
		    Salesforce_SubTeam_Code_gne__c = stgTerr.Salesforce_SubTeam_Code_gne__c
		);
		stgTerr.Comment_gne__c = COMMENT_RESULT_STATUS_NEW;
		return tmpTerritory;
	}

	private void markStagingTerrWithError(Staging_Territory_Def_gne__c stgTerr, String errorMsg) {
		stgTerr.Status_gne__c = STG_TERRITORY_ERROR_STATE;
		stgTerr.Comment_gne__c = COMMENT_RESULT_STATUS_ERROR + COMMENT_DELIMETER + errorMsg;
	}

}