global with sharing class GNE_Subscribe_Territory {
    // Staging territory data states
    private static final String STG_TERRITORY_NEW_STATE = 'Loaded';
	private static final String STG_TERRITORY_ERROR_STATE = 'Error Processing';
	private static final String STG_TERRITORY_SUCCESS_STATE = 'Processed';

	// Process variables
	public static final String COMMENT_RESULT_STATUS_NEW = '[Result: New]';
	public static final String COMMENT_RESULT_STATUS_UPDATE = '[Result: Update]';
	public static final String COMMENT_RESULT_STATUS_NOCHANGE = '[Result: No Change]';
	public static final String COMMENT_RESULT_STATUS_DEACTIVATE = '[Result: Deactivate]';
	public static final String COMMENT_RESULT_STATUS_ERROR = '[Result: Error]';
	public static final String COMMENT_DELIMETER = '|';
	public static final String COMMENT_FIELD_LIST_DELIMETER = ', ';
	public static final String COMMENT_PREVIEW_MODE_PREFIX = 'PREVIEW';
	public static final String US_ROOT_TERRITORY_NAME = 'GNE-US';
	public static String INACTIVE_ROOT_TERRITORY_NAME = 'INACTIVE TERRITORIES';
	public static final String TERRITORY_NAME_SEPARATOR = '-';
    public static final String TERRITORY_EXTID_SEPARATOR = ';';
	public static final String OLD_MARKER = '_OLD';
	public static final String ACCOUNT_ACCESS_LEVEL = 'Edit';

	global Boolean previewMode = false;

	private List<Staging_Territory_Def_gne__c> stgTerritories = new List<Staging_Territory_Def_gne__c>();
	private Set<String> alreadyDeactivatedTerritoriesExternalIds = new Set<String>();
	private Set<String> tempDeactivatedTerritoriesExternalIds = new Set<String>();
	private Map<String, Territory2> territoryCache = new Map<String, Territory2>();
	private Map<String, Set<String>> parentTerritoryToDirectChildrenCache = new Map<String, Set<String>>();
	private Territory2 inactiveTerritory;
	private Map<String, Territory2> territoriesToUpsert = new Map<String, Territory2>();
	private Id terrModelId = [SELECT Id FROM Territory2Model LIMIT 1].Id;
	private Id terrTypeId = [SELECT Id FROM Territory2Type LIMIT 1].Id;
	private Date currentDate = Date.today();

    private List<ErrorWrapper> validationErrors = new List<ErrorWrapper>();
    private List<ErrorWrapper> runtimeErrors = new List<ErrorWrapper>();
    private static String myURL = URL.getSalesforceBaseUrl().getHost();

	global GNE_Subscribe_Territory(Boolean prevMode) {
		this.previewMode = prevMode;
		stgTerritories = fetchStgTerritoriesToProceed();
		if(!stgTerritories.isEmpty()) {
			if(previewMode) {
				GNE_SFA2_Territory2_Trigger_Helper.setSubPrevMode(true);
			}
			prepareDataToProceed();
			GNE_SFA2_Territory2_Trigger_Helper.setSubscribeMode(true);
			execute();
			GNE_SFA2_Territory2_Trigger_Helper.setSubscribeMode(false);
			if(!previewMode) {
				GNE_SFA2_Territory2_Trigger_Helper.setRunOnlyAfterEvents(true);			
				updateParentTerritoryReferences();
				GNE_SFA2_Territory2_Trigger_Helper.setRunOnlyAfterEvents(false);
			}
			updateResultsInStgTerritories(previewMode, JSON.serialize(stgTerritories), JSON.serialize(validationErrors), JSON.serialize(runtimeErrors));
			if(previewMode) {
				GNE_SFA2_Territory2_Trigger_Helper.setSubPrevMode(false);
			}
		}
	}
	
	private List<Staging_Territory_Def_gne__c> fetchStgTerritoriesToProceed() {
		return [
				SELECT 
					Id, Name,
					Territory_External_ID_gne__c, 
					Territory_Nbr_gne__c, 
					Territory_Name_gne__c, 
					Parent_Territory_External_ID_gne__c, 
					Activation_Date_gne__c,
		            Territory_Description_gne__c, 
		            Territory_Source_gne__c, 
		            End_Date_gne__c,
		            Territory_ID_gne__c, 
		            Status_gne__c, 
		            Comment_gne__c, 
		            Salesforce_Code_gne__c, 
		            Salesforce_SubTeam_Code_gne__c
		        FROM 
		        	Staging_Territory_Def_gne__c
		        WHERE 
		        	Status_gne__c =: STG_TERRITORY_NEW_STATE
		        AND (Activation_Date_gne__c <= Today OR End_Date_gne__c <= Today)
		        ORDER BY Parent_Territory_External_ID_gne__c, Territory_Nbr_gne__c, Territory_Name_gne__c, End_Date_gne__c
			];
	}
	
	private void prepareDataToProceed() {
		initTerritoryCache();
		reorderStgTerritoriesByHierarchy();
	}

	private void initTerritoryCache() {
		Map<Id, Territory2> territories = new Map<Id, Territory2>([
		        SELECT
		            Id,
		            ParentTerritory2Id,
		            Name,
					DeveloperName,
		            Description,
		            Territory_Number_gne__c,
		            Source_gne__c,
		            End_Date__c,
		            Parent_External_Id_gne__c,
		            External_Id_gne__c,
		            Salesforce_Code_gne__c,
		            Salesforce_SubTeam_Code_gne__c
		        FROM
		            Territory2
		    ]);
	
		Map<String, Territory2> terrTempCache = new Map<String, Territory2>();
		Map<String, Set<String>> parentToDirectChildrenTempMap = new Map<String, Set<String>>();
	
		for (Territory2 tempTerr : territories.values()) {
			if (tempTerr.Name.equalsIgnoreCase(INACTIVE_ROOT_TERRITORY_NAME)) {
				inactiveTerritory = tempTerr;
				continue;
			}
			
			Territory2 currentTerr = tempTerr;
			terrTempCache.clear();
			parentToDirectChildrenTempMap.clear();
	
			while (true) {
				if (currentTerr.External_Id_gne__c != null) {
					terrTempCache.put(currentTerr.External_Id_gne__c.toUpperCase(), currentTerr);
				}
	
				if ((currentTerr.External_Id_gne__c != null && territoryCache.containsKey(currentTerr.External_Id_gne__c.toUpperCase())) || (currentTerr.ParentTerritory2Id == null && currentTerr.Name == 'GNE-US')) {
					territoryCache.putAll(terrTempCache);
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
	
	private void reorderStgTerritoriesByHierarchy() {
		Map<Integer, List<Staging_Territory_Def_gne__c>> orderedStgTerritories = new Map<Integer, List<Staging_Territory_Def_gne__c>>();
		for(Staging_Territory_Def_gne__c stg : stgTerritories) {
			Integer extIdSplitCount = 0;
			if(String.isBlank(stg.Territory_External_Id_gne__c)) {
				stg.Territory_External_Id_gne__c = generateTerritoryExternalId(stg);
			}
			extIdSplitCount = stg.Territory_External_Id_gne__c.split(';').size();
			
			if(!orderedStgTerritories.containsKey(extIdSplitCount)) {
				orderedStgTerritories.put(extIdSplitCount, new List<Staging_Territory_Def_gne__c>{stg});
			} else {
				orderedStgTerritories.get(extIdSplitCount).add(stg);
			}
		}
		
		stgTerritories = new List<Staging_Territory_Def_gne__c>();
		List<Integer> orders = new List<Integer>(orderedStgTerritories.keySet());
		orders.sort();
		for(Integer i : orders) {
			stgTerritories.addAll(orderedStgTerritories.get(i));
		}
	}
	
	private void execute() {
		Map<String, Staging_Territory_Def_gne__c> terrIdToStgTerritory = new Map<String, Staging_Territory_Def_gne__c>();
		
		for (Staging_Territory_Def_gne__c stgTerr : stgTerritories) {
			if(stgTerr.Status_gne__c == STG_TERRITORY_NEW_STATE) {
				stgTerr.Comment_gne__c = '';
				stgTerr.Territory_Id_gne__c = '';
				Boolean isTerritoryDeactivation = stgTerr.End_Date_gne__c <= date.today();
				if(!stgTerr.Territory_External_Id_gne__c.startsWith(stgTerr.Parent_Territory_External_Id_gne__c)) {
					markStagingTerrWithError(stgTerr, 'Territory external id should start with the parent external id.');
				} else if (!isTerritoryDeactivation && String.isNotBlank(stgTerr.Parent_Territory_External_Id_gne__c) && (!territoryCache.containsKey(stgTerr.Parent_Territory_External_Id_gne__c.toUpperCase()) || tempDeactivatedTerritoriesExternalIds.contains(stgTerr.Parent_Territory_External_Id_gne__c.toUpperCase()))) {
					markStagingTerrWithError(stgTerr, 'Parent territory with external id = \'' + stgTerr.Parent_Territory_External_Id_gne__c + '\' does not exist.');
				} else if (stgTerr.Activation_Date_gne__c > stgTerr.End_Date_gne__c) {
					markStagingTerrWithError(stgTerr, 'Acivation Date cannot be greater than End Date.');
				} else {
					String territoryExternalId = stgTerr.Territory_External_Id_gne__c;
					String terrExtIdUC = territoryExternalId.toUpperCase();
		
					if (isTerritoryDeactivation) {
						Boolean territoryExists = territoryCache.containsKey(terrExtIdUC);
		
						if (territoryExists) {
							Territory2 tmpTerritory = territoryCache.get(terrExtIdUC);
							terrIdToStgTerritory.put(tmpTerritory.Id, stgTerr);
							if (alreadyDeactivatedTerritoriesExternalIds.contains(terrExtIdUC)) {
								markStagingTerrWithError(stgTerr, 'Territory ' + territoryExternalId + ' was already deactiavated by parent.');
							} else {
								deactivateTerritoryHierarchy(tmpTerritory, stgTerr);
								territoriesToUpsert.put(tmpTerritory.Id, tmpTerritory);
							}
						} else {
							markStagingTerrWithError(stgTerr, 'Territory with external id = \'' + territoryExternalId + '\' does not exist and cannot be deactivated.');
							tempDeactivatedTerritoriesExternalIds.add(stgTerr.Territory_External_Id_gne__c.toUpperCase());
						}
					} else {
						Boolean territoryExists = territoryCache.containsKey(terrExtIdUC);
						Territory2 tmpTerritory = territoryExists ? territoryCache.get(terrExtIdUC) : createTerritoryFromStagingTerritory(stgTerr, territoryExternalId);
		
						if(!alreadyDeactivatedTerritoriesExternalIds.contains(terrExtIdUC) && !alreadyDeactivatedTerritoriesExternalIds.contains(tmpTerritory.Parent_External_Id_gne__c.toUpperCase())) {
							if (territoryExists) {
								terrIdToStgTerritory.put(tmpTerritory.Id, stgTerr);
			
								if (updateTerritoryFromStagingTerritory(tmpTerritory, stgTerr)) {
									territoriesToUpsert.put(tmpTerritory.Id, tmpTerritory);
								}
							} else {
								String uniqueTerritoryId = generateUniqueTerritoryId(tmpTerritory);
								territoriesToUpsert.put(uniqueTerritoryId, tmpTerritory);
								terrIdToStgTerritory.put(uniqueTerritoryId, stgTerr);
							}
			
							if (!territoryCache.containsKey(tmpTerritory.External_Id_gne__c.toUpperCase())) {
								territoryCache.put(tmpTerritory.External_Id_gne__c.toUpperCase(), tmpTerritory);
							}
						} else {
							if(!territoryExists && alreadyDeactivatedTerritoriesExternalIds.contains(stgTerr.Parent_Territory_External_Id_gne__c.toUpperCase())) {
								markStagingTerrWithError(stgTerr, 'Parent territory with external id = \'' + stgTerr.Parent_Territory_External_Id_gne__c + '\' is already deactivated.');
							} else {
								stgTerr.Comment_gne__c = COMMENT_RESULT_STATUS_DEACTIVATE;
								if(territoryExists) {
									stgTerr.Territory_Id_gne__c = tmpTerritory.Id;
								}
							}
						}
					}
				}
			}

            if(stgTerr.Status_gne__c == STG_TERRITORY_ERROR_STATE) {
                ErrorWrapper ew = new ErrorWrapper(stgTerr);
                validationErrors.add(ew);   
            }
		}
		
		if (previewMode) {
			Savepoint sp = Database.setSavepoint();
			upsertTerritories(territoriesToUpsert, terrIdToStgTerritory);
			Database.rollback(sp);
		} else {
			upsertTerritories(territoriesToUpsert, terrIdToStgTerritory);
		}
	}
	
	private void updateParentTerritoryReferences() {
		Map<String, Id> parentExtIdToId = new Map<String, Id>();
		List<Territory2> territoriesToParentReferenceUpdate = new List<Territory2>();
		for(Territory2 terr : territoriesToUpsert.values()) {
			parentExtIdToId.put(terr.Parent_External_Id_gne__c.toUpperCase(), null);
		}
		
		for(Territory2 terr : [SELECT Id, External_Id_gne__c FROM Territory2 WHERE External_Id_gne__c IN: parentExtIdToId.keySet()]) {
			parentExtIdToId.put(terr.External_Id_gne__c.toUpperCase(), terr.Id);
		}
		
		for(Territory2 terr : territoriesToUpsert.values()) {
			if(terr.Id != null && parentExtIdToId.get(terr.Parent_External_Id_gne__c.toUpperCase()) != null) {
				terr.ParentTerritory2Id = parentExtIdToId.get(terr.Parent_External_Id_gne__c.toUpperCase());
				territoriesToParentReferenceUpdate.add(terr);
			}
		}
		
		if(!territoriesToParentReferenceUpdate.isEmpty()) {
			update territoriesToParentReferenceUpdate;
		}
	}

	@future
	private static void updateResultsInStgTerritories(Boolean previewMode, String stgTerritoriesSerialized, String validationsErrorsSerialized, String runtimeErrorsSerialized) {
		List<Staging_Territory_Def_gne__c> stgTerritories = (List<Staging_Territory_Def_gne__c>)JSON.deserialize(stgTerritoriesSerialized, List<Staging_Territory_Def_gne__c>.class);
        List<ErrorWrapper> validationsErrors = (List<ErrorWrapper>)JSON.deserialize(validationsErrorsSerialized, List<ErrorWrapper>.class);
        List<ErrorWrapper> runtimeErrors = (List<ErrorWrapper>)JSON.deserialize(runtimeErrorsSerialized, List<ErrorWrapper>.class);
		for (Staging_Territory_Def_gne__c stgTerr : stgTerritories) {
			if (stgTerr.Status_gne__c != STG_TERRITORY_ERROR_STATE) {
				stgTerr.Status_gne__c = STG_TERRITORY_SUCCESS_STATE;
			}

			if (previewMode) {
				stgTerr.Comment_gne__c = '[' + COMMENT_PREVIEW_MODE_PREFIX + ' ' + (stgTerr.Comment_gne__c != '' ? stgTerr.Comment_gne__c.substring(1) : ']');
				stgTerr.Status_gne__c  = STG_TERRITORY_NEW_STATE;
			}
		}

		Database.DMLOptions dml = new Database.DMLOptions();
		dml.allowFieldTruncation = true;
		dml.optAllOrNone = false;
		List<Database.SaveResult> stgTerrResults = Database.update(stgTerritories, dml);
		if (stgTerrResults != null) {
			Integer iCount = 0;
			for (Database.SaveResult result : stgTerrResults) {
				Staging_Territory_Def_gne__c stgTerr = (Staging_Territory_Def_gne__c) stgTerritories[iCount];

				if (!result.isSuccess()) {
					List<Database.Error> errs = result.getErrors();
					for (Database.Error err : errs) {
						System.debug('Subscribe Territory:: ' + stgTerr.Id + ': ' + err.getStatusCode() + ' - ' + err.getMessage());
					}
                    ErrorWrapper ew = new ErrorWrapper(stgTerr);
                    runtimeErrors.add(ew);
				}

				iCount++;
			}
		}

		sendEmail(previewMode, validationsErrors, runtimeErrors);
	}
	
	private void upsertTerritories(Map<String, Territory2> territoriesToUpsert, Map<String, Staging_Territory_Def_gne__c> terrIdToStgTerritory) {
		List<Database.UpsertResult> results = Database.upsert(territoriesToUpsert.values(), false);
	
		if (results != null) {
			Integer iCount = 0;
			for (Database.UpsertResult result : results) {
				Territory2 tmpTerritory = territoriesToUpsert.values()[iCount];
				Staging_Territory_Def_gne__c stgTerr = null;
	
				if (terrIdToStgTerritory.containsKey(tmpTerritory.Id)) {
					stgTerr = terrIdToStgTerritory.get(tmpTerritory.Id);
				} else if (terrIdToStgTerritory.containsKey(generateUniqueTerritoryId(tmpTerritory))) {
					stgTerr = terrIdToStgTerritory.get(generateUniqueTerritoryId(tmpTerritory));
				}
	
				if (stgTerr == null) {
					iCount++;
					System.debug(LoggingLevel.ERROR, 'Subscribe Territory:: Matching Staging record not found. Something not right. Territory unique key: ' );
					continue;
				}
	
				if (result.isSuccess()) {
					if (String.isBlank(stgTerr.Territory_Id_gne__c)) {
						stgTerr.Territory_Id_gne__c = tmpTerritory.Id;
					}
				} else {
					List<Database.Error> errs = result.getErrors();
					if (!previewMode && errs.isEmpty() && !errs[0].getMessage().contains('Could not find the Parent Territory') && !territoryCache.containsKey(tmpTerritory.Parent_External_Id_gne__c.toUpperCase())) {
						if (territoryCache.containsKey(tmpTerritory.External_Id_gne__c.toUpperCase()) && tmpTerritory.Id == null) {
							territoryCache.remove(tmpTerritory.External_Id_gne__c.toUpperCase());
						}
	
						String errorMsg = '';
						for (Database.Error err : errs) {
							if (String.isNotBlank(errorMsg)) {
								errorMsg += COMMENT_DELIMETER;
							}
							errorMsg += err.getStatusCode() + ' - ' + err.getMessage();
						}
	
						markStagingTerrWithError(stgTerr, errorMsg);
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
		return stgTerr.Parent_Territory_External_Id_gne__c + TERRITORY_EXTID_SEPARATOR + generateTerritoryName(stgTerr);
	}
	
	private String generateTerritoryName(Staging_Territory_Def_gne__c stgTerr) {
	
		Boolean nameContainsOnlyNumber = stgTerr.Territory_Name_gne__c.equals(stgTerr.Territory_Nbr_gne__c) &&
		                                 stgTerr.Territory_Name_gne__c.startsWith('0') &&
		                                 !stgTerr.Territory_Name_gne__c.contains(TERRITORY_NAME_SEPARATOR);
	
		if (!nameContainsOnlyNumber && stgTerr.Territory_Name_gne__c.indexOf(stgTerr.Territory_Nbr_gne__c) == 0) {
			return stgTerr.Territory_Name_gne__c;
		}
		return '' + stgTerr.Territory_Nbr_gne__c + TERRITORY_NAME_SEPARATOR + stgTerr.Territory_Name_gne__c;
	}
	
	private void deactivateTerritoryHierarchy(Territory2 rootTerritory, Staging_Territory_Def_gne__c stgTerr) {
	
		List<Territory2> territoriesToDeactivate = new List<Territory2> {rootTerritory};
	
		rootTerritory.Name = generateTerritoryName(stgTerr);
		rootTerritory.Description = stgTerr.Territory_Description_gne__c;
		rootTerritory.source_gne__c = stgTerr.Territory_Source_gne__c;
		rootTerritory.End_Date__c = stgTerr.End_Date_gne__c;
	
		Integer idx = 0;
		while (true) {
			if (territoriesToDeactivate.size() == idx) {
				break;
			}
			Territory2 currentTerr = territoriesToDeactivate.get(idx++);
			if (parentTerritoryToDirectChildrenCache.containsKey(currentTerr.External_Id_gne__c.toUpperCase())) {
				for (String childExtId : parentTerritoryToDirectChildrenCache.get(currentTerr.External_Id_gne__c.toUpperCase())) {
					if (territoryCache.containsKey(childExtId)) {
						Territory2 childTerr = territoryCache.get(childExtId);
						territoriesToDeactivate.add(childTerr);
					}
				}
			}
	
			alreadyDeactivatedTerritoriesExternalIds.add(currentTerr.external_id_gne__c.toUpperCase());
			if (idx == 1) {
				currentTerr.Parent_External_Id_gne__c = inactiveTerritory.External_Id_gne__c;
				currentTerr.ParentTerritory2Id = inactiveTerritory.Id;
			} else {
				currentTerr.parent_external_id_gne__c = inactiveTerritory.Name + TERRITORY_EXTID_SEPARATOR + currentTerr.parent_external_id_gne__c + OLD_MARKER;
			}
	
			currentTerr.external_id_gne__c = inactiveTerritory.Name + TERRITORY_EXTID_SEPARATOR + currentTerr.external_id_gne__c + OLD_MARKER;
			currentTerr.DeveloperName = currentTerr.DeveloperName + '_' + String.valueOf(currentDate.day()) + String.valueOf(currentDate.month()) + String.valueOf(currentDate.year()) + String.valueOf(Math.random()).substring(2,6) + OLD_MARKER;
		}
		
		territoriesToDeactivate.remove(0);
		for(Territory2 terr : territoriesToDeactivate) {
			territoriesToUpsert.put(generateUniqueTerritoryId(terr), terr);	
		}
		stgTerr.Territory_Id_gne__c = rootTerritory.Id;
		stgTerr.Comment_gne__c = COMMENT_RESULT_STATUS_DEACTIVATE;
	}
	
	private Boolean updateTerritoryFromStagingTerritory(Territory2 terr, Staging_Territory_Def_gne__c stgTerr) {
		Map<String, Object> proposedValues = new Map<String, Object> {
			'Name' => generateTerritoryName(stgTerr),
			'Parent_External_Id_gne__c' => stgTerr.Parent_Territory_External_Id_gne__c,
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
	
		stgTerr.Territory_Id_gne__c = terr.Id;
		stgTerr.Comment_gne__c = comment;
	
		return !changedFieldNames.isEmpty();
	}
	
	private Territory2 createTerritoryFromStagingTerritory(Staging_Territory_Def_gne__c stgTerr, String territoryExternalId) {
		Territory2 tmpTerritory = new Territory2(
		    Territory2ModelId = terrModelId,
		    Territory2TypeId = terrTypeId,
		    Name = generateTerritoryName(stgTerr),
		    DeveloperName = 'X' + generateTerritoryName(stgTerr).replaceAll('[|\\,|\\.|\\,||"||\\:|\\~|\\!|\\/|\\@|\\#|\\$|\\%|\\^|\\&|\\*|\\-|\\_|\\+|\\=|\\<|\\>|\\?|\\(|\\)|\\{|\\}|\\;|\\\'"]', '').replaceAll(' ', ''),
		    AccountAccessLevel = ACCOUNT_ACCESS_LEVEL,
		    Parent_External_Id_gne__c = stgTerr.Parent_Territory_External_Id_gne__c,
		    Description = stgTerr.Territory_Description_gne__c,
		    Source_gne__c = stgTerr.Territory_Source_gne__c,
		    External_Id_gne__c = territoryExternalId,
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

	public static void sendEmail(Boolean previewMode, List<ErrorWrapper> vErrors, List<ErrorWrapper> rErrors) {
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		email.setSubject('Subscribe Territory');
		email.setToAddresses(new List<String>{UserInfo.getUserEmail()});
		String textBody = 'Subscribe Territory process';
		if(previewMode) {
			textBody += ' in preview mode';
		}
		textBody += ' has been finished.';
        if(!vErrors.isEmpty()) {
            textBody += '<BR><BR>Validation errors:';
            textBody += buildErrorTable(vErrors);
        }
        if(!rErrors.isEmpty()) {
            textBody += '<BR><BR>Runtime errors:';
            textBody += buildErrorTable(rErrors);
        }
		email.setHtmlBody(textBody);
		List<Messaging.SendEmailResult> sendResults = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
	}
    
    private static String buildErrorTable(List<ErrorWrapper> errors) {
        String tableTxt = '<TABLE border="1" ><TH style="background:rgb(242,243,243)">Staging User Assignment ID</TH>'+
            '<TH style="background:rgb(242,243,243)">Territory Key</TH><TH style="background:rgb(242,243,243)">Activaction Date</TH>'+
            '<TH style="background:rgb(242,243,243)">Unassignment Date</TH><TH style="background:rgb(242,243,243)">Status</TH><TH style="background:rgb(242,243,243)">Comment</TH>';
        for(ErrorWrapper ew : errors) {
            tableTxt += '<TR><TD><a href="https://'+myURL+'/'+ew.assignmentId+'">'+ew.name+'</a></TD><TD>'+ ew.territoryKey +'</TD><TD>'+ ew.activationDate +'</TD><TD>'+ ew.unassignmentDate +'</TD><TD>'+ ew.status+'</TD><TD>'+ ew.comment +'</TD></TR>';
        }
        tableTxt += '</TABLE>';
        return tableTxt;
    }
    
    class ErrorWrapper {
        String name;
        String assignmentId;
        String territoryKey;
        String activationDate;
        String unassignmentDate;
        String status;
        String comment;        
        
        public ErrorWrapper(Staging_Territory_Def_gne__c record) {
            assignmentId = record.Id;
            name = record.Name;            
            territoryKey = record.Territory_External_ID_gne__c;
            Date da = record.Activation_Date_gne__c;
            if(da != null) activationDate = da.month() +'/' + da.day() +'/'+ da.year() ;
            Date du = record.End_Date_gne__c;
            if(du != null) unassignmentDate = du.month() +'/' + du.day() +'/'+ du.year() ;
            status = record.Status_gne__c;
            comment = record.Comment_gne__c;            
        }
    }
}