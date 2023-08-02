/* 
 * global class GNE_MCCO_CRM_Field_Intelligence_Batch implements Database.Batchable<sObject>, Database.Stateful
 *
 * This batch update all Field Intelligence in 24h job
 */
global class GNE_MCCO_CRM_Field_Intelligence_Batch implements Database.Batchable<sObject>, Database.Stateful {

	global final Map<String, Set<Id>> TERRITORY_NAME_TO_USER_IDS_MAP;
	global final Boolean IS_NEW_MODE;

	global Map<Id, List<TSF_vod__c>> surveyToTSFsMap;
	global Map<Id, Set<String>> tsfsForAccountsAndUsersMap;
	global Map<Id, Set<Id>> surveyIdToUserIdMap;
	
	global Map<Id, String> surveyIdToRecordTypeMap;
	global Map<Id, List<String>> surveyIdToTerritoriesMap;
	
	global GNE_MCCO_CRM_Field_Intelligence_Batch() {
		surveyIdToRecordTypeMap 	= new Map<Id, String>();
		surveyIdToTerritoriesMap 	= new Map<Id, List<String>>();
		surveyIdToUserIdMap 		= new Map<Id, Set<Id>>();
		IS_NEW_MODE 				= false;

		TERRITORY_NAME_TO_USER_IDS_MAP = GNE_MCCO_CRM_Survey_Util.getUsersTerrs();
		
		prepareTSFForSurveys();
		prepareTSFsForAcctAndUsersMap(surveyToTSFsMap);
		
		System.debug('# SurveyId to RecordType');
		System.debug(surveyIdToRecordTypeMap);
		
		System.debug('# SurveyId to Set<Account+UserId>');
		for(Id key : tsfsForAccountsAndUsersMap.keySet()) {
			System.debug('# Survey : ' + key);
			System.debug('### User : ' + tsfsForAccountsAndUsersMap.get(key).size());
		}
		
		System.debug('# SurveyId to Set<UserId>');
		for(Id key : surveyIdToUserIdMap.keySet()) {
			System.debug('# Survey : ' + key);
			System.debug('### User : ' + surveyIdToUserIdMap.get(key).size());
		}
	}
	
	global GNE_MCCO_CRM_Field_Intelligence_Batch(String tsfsForAccountsAndUsersMapJson, String surveyIdToUserIdMapJson) {
		IS_NEW_MODE = true;
		tsfsForAccountsAndUsersMap = (Map<Id, Set<String>>)JSON.deserialize(tsfsForAccountsAndUsersMapJson, Map<Id, Set<String>>.class);
		surveyIdToUserIdMap = (Map<Id, Set<Id>>)JSON.deserialize(surveyIdToUserIdMapJson, Map<Id, Set<Id>>.class);
	}
	
	global Database.QueryLocator start(Database.BatchableContext bc) {
		String query = '';
		
		if(!IS_NEW_MODE) {
			query += 'SELECT Id, Account_gne__c, User_gne__c, Available_gne__c, Comment_gne__c, Survey_gne__c, Survey_gne__r.Account_Ids_gne__c, Survey_gne__r.Ready_To_Use_gne__c, Survey_gne__r.Territories_gne__c, Survey_gne__r.Territories_Names_gne__c, Survey_gne__r.Record_Type_gne__c FROM GNE_MCCO_CRM_Field_Intelligence__c';
		} else {
			Set<Id> surveyIds = tsfsForAccountsAndUsersMap.keySet();
			Set<Id> surveyGeneralIds = surveyIdToUserIdMap.keySet();
			query += 'SELECT Id, Record_Type_gne__c, Close_Survey_gne__c FROM GNE_MCCO_CRM_Survey__c WHERE (Id IN :surveyIds OR Id IN :surveyGeneralIds) AND Ready_To_Use_gne__c = true';
		}
		
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		
		if(!IS_NEW_MODE) {
			updateFieldIntelligence(scope);
		} else {
			insertFieldIntelligence(scope);
		}
		
	}

	global void finish(Database.BatchableContext BC) {

		if(!IS_NEW_MODE && ((tsfsForAccountsAndUsersMap != null && !tsfsForAccountsAndUsersMap.isEmpty()) || (surveyIdToUserIdMap != null && !surveyIdToUserIdMap.isEmpty()))) {
			
		if((tsfsForAccountsAndUsersMap != null && !tsfsForAccountsAndUsersMap.isEmpty())) {
			System.debug('### Account Field Intelligence To Insert ###');
			for(Id key : tsfsForAccountsAndUsersMap.keySet()) {
				System.debug('# Survey : ' + key);
				System.debug('### User : ' + tsfsForAccountsAndUsersMap.get(key).size());
			}
		}
		
		if((surveyIdToUserIdMap != null && !surveyIdToUserIdMap.isEmpty())) {
			System.debug('### General Field Intelligence To Insert ###');
			for(Id key : surveyIdToUserIdMap.keySet()) {
				System.debug('# Survey : ' + key);
				System.debug('### User : ' + surveyIdToUserIdMap.get(key).size());
			}
		}
			
			Database.executeBatch(new GNE_MCCO_CRM_Field_Intelligence_Batch(JSON.serializePretty(tsfsForAccountsAndUsersMap), JSON.serializePretty(surveyIdToUserIdMap)), 200);
		} else {
			System.debug('No Field Intelligence to add.');
		}
	}
	
	global void updateFieldIntelligence(List<sObject> scope) {
		
		List<GNE_MCCO_CRM_Field_Intelligence__c> fiToUpdate = new List<GNE_MCCO_CRM_Field_Intelligence__c>();

		for(sObject s : scope) {

			GNE_MCCO_CRM_Field_Intelligence__c fi = (GNE_MCCO_CRM_Field_Intelligence__c) s;
			
			if(fi.Survey_gne__r.Record_Type_gne__c == 'Account') { 
				
				String au = fi.Account_gne__c + '_' + fi.User_gne__c;
				
				if(tsfsForAccountsAndUsersMap.get(fi.Survey_gne__c) != null && tsfsForAccountsAndUsersMap.get(fi.Survey_gne__c).contains(au)) {
					if(!fi.Available_gne__c) {
						fi.Available_gne__c = true;
						fi.Comment_gne__c = null;
						fiToUpdate.add(fi);
					}
				} else if(fi.Available_gne__c) {
					fi.Available_gne__c = false;
					fi.Comment_gne__c = System.now().format('MM/dd/yyyy') + ' - survey hidden as user / account should no longer see the survey.';
					fiToUpdate.add(fi);
				}
	
				if(tsfsForAccountsAndUsersMap.get(fi.Survey_gne__c) != null) {
					tsfsForAccountsAndUsersMap.get(fi.Survey_gne__c).remove(au);
					if(tsfsForAccountsAndUsersMap.get(fi.Survey_gne__c) != null && tsfsForAccountsAndUsersMap.get(fi.Survey_gne__c).isEmpty()) {
						tsfsForAccountsAndUsersMap.remove(fi.Survey_gne__c);
					}
				}
			
			} else if(fi.Survey_gne__r.Record_Type_gne__c == 'General') {
				
				if(surveyIdToUserIdMap.get(fi.Survey_gne__c) != null && surveyIdToUserIdMap.get(fi.Survey_gne__c).contains(fi.User_gne__c)) {
					if(!fi.Available_gne__c) {
						fi.Available_gne__c = true;
						fi.Comment_gne__c = null;
						fiToUpdate.add(fi);
					}
				} else if(fi.Available_gne__c) {
					fi.Available_gne__c = false;
					fi.Comment_gne__c = System.now().format('MM/dd/yyyy') + ' - survey hidden as user / account should no longer see the survey.';
					fiToUpdate.add(fi);
				}
				
				if(surveyIdToUserIdMap.get(fi.Survey_gne__c) != null) {
					surveyIdToUserIdMap.get(fi.Survey_gne__c).remove(fi.User_gne__c);
					if(surveyIdToUserIdMap.get(fi.Survey_gne__c) != null && surveyIdToUserIdMap.get(fi.Survey_gne__c).isEmpty()) {
						surveyIdToUserIdMap.remove(fi.Survey_gne__c);
					}
				}
				
			}

		}

		if(!fiToUpdate.isEmpty()) {
			update fiToUpdate;
		}
		
	}	
	
	global void insertFieldIntelligence(List<sObject> scope) {
		
		List<GNE_MCCO_CRM_Field_Intelligence__c> fiToInsert = new List<GNE_MCCO_CRM_Field_Intelligence__c>();

		for(sObject s : scope) {

			GNE_MCCO_CRM_Survey__c survey = (GNE_MCCO_CRM_Survey__c) s;
			
			if(survey.Record_Type_gne__c == 'Account') {
				
				if(tsfsForAccountsAndUsersMap != null && tsfsForAccountsAndUsersMap.containsKey(survey.Id)) {
		
					for(String tau : tsfsForAccountsAndUsersMap.get(survey.Id)) {
						
		                fiToInsert.add(
			                new GNE_MCCO_CRM_Field_Intelligence__c(
			                    Available_gne__c     = true,
			                    Account_gne__c       = tau.split('_').get(0),
			                    User_gne__c          = tau.split('_').get(1),
			                    Survey_gne__c        = survey.Id,
			                    Survey_Status_gne__c = (survey.Close_Survey_gne__c) ? 'Closed' : 'Not started'
			                )
		                );
		
					}
					
					tsfsForAccountsAndUsersMap.remove(s.Id);
					
				}
			
			}
						
			if(survey.Record_Type_gne__c == 'General') {
				
				if(surveyIdToUserIdMap != null && surveyIdToUserIdMap.containsKey(survey.Id)) {
	
					for(Id userId : surveyIdToUserIdMap.get(survey.Id)) {
						
		                fiToInsert.add(
			                new GNE_MCCO_CRM_Field_Intelligence__c(
			                    Available_gne__c    	= true,
			                    User_gne__c         	= userId,
			                    Survey_gne__c       	= survey.Id,
			                    Survey_Status_gne__c 	= (survey.Close_Survey_gne__c) ? 'Closed' : 'Not started'
			                )
		                );
		                
					}
					
					surveyIdToUserIdMap.remove(s.Id);
					
				}

			}			

		}

		if(!fiToInsert.isEmpty()) {
			insert fiToInsert;
		}
		
	}

	global void prepareTSFsForAcctAndUsersMap(Map<Id, List<TSF_vod__c>> surveyToTSFsMap) {
		tsfsForAccountsAndUsersMap = new Map<Id, Set<String>>();
		surveyIdToUserIdMap = new Map<Id, Set<Id>>();
		
		// GENERAL 
		for(GNE_MCCO_CRM_Survey__c survey : [SELECT Id, Territories_gne__c, Territories_Names_gne__c FROM GNE_MCCO_CRM_Survey__c WHERE Record_Type_gne__c = 'General' AND Ready_To_Use_gne__c = true]) {
			
			for(String terrName : surveyIdToTerritoriesMap.get(survey.Id)) {
					
				if(TERRITORY_NAME_TO_USER_IDS_MAP.containsKey(terrName)) {
					
					for(Id userId : TERRITORY_NAME_TO_USER_IDS_MAP.get(terrName)) {
						
						if(surveyIdToUserIdMap.containsKey(survey.Id)) {
							surveyIdToUserIdMap.get(survey.Id).add(userId);
						} else {
							surveyIdToUserIdMap.put(survey.Id, new Set<Id>{ userId });
						}
							
					}
					
				}

			}
				
		}
		
		// ACCOUNT
		for(Id key : surveyToTSFsMap.keySet()) {
					
			for(TSF_vod__c tsf : surveyToTSFsMap.get(key)) {
				if(TERRITORY_NAME_TO_USER_IDS_MAP.containsKey(tsf.Territory_vod__c)) {
					for(Id uId : TERRITORY_NAME_TO_USER_IDS_MAP.get(tsf.Territory_vod__c)) {

						if(tsfsForAccountsAndUsersMap.containsKey(key)) {
							tsfsForAccountsAndUsersMap.get(key).add(tsf.Account_vod__c + '_' + uId);
						} else {
							tsfsForAccountsAndUsersMap.put(key, new Set<String>{ tsf.Account_vod__c + '_' + uId });
						}
						
					}
				}
			}

		}
	}
	
	global void prepareTSFForSurveys() {
		Map<Id, List<TSF_vod__c>> result = new Map<Id, List<TSF_vod__c>>();
		Map<Id, Set<String>> surveyToAccountIdsMap = new Map<Id, Set<String>>();
		Map<Id, Set<String>> surveyToTerritoryNamesMap = new Map<Id, Set<String>>();
		Set<String> allAccountIds = new Set<String>();
		Set<String> allTerritoryNames = new Set<String>();
		Map<String, List<String>> allTerritoryIdsMap = new Map<String, List<String>>();
		Set<String> allTerritoryIds = new Set<String>();
		String accountId = '';

		for(GNE_MCCO_CRM_Survey__c s : [SELECT Id, Account_Ids_gne__c, Territories_gne__c, Territories_Names_gne__c, Record_Type_gne__c FROM GNE_MCCO_CRM_Survey__c WHERE Ready_To_Use_gne__c = true]) {
			if(!String.isEmpty(s.Account_Ids_gne__c)) {
				surveyToAccountIdsMap.put(s.Id, new Set<String>(s.Account_Ids_gne__c.split(';')));
				allAccountIds.addAll(s.Account_Ids_gne__c.split(';'));
			}

			if(!String.isEmpty(s.Territories_gne__c)) {
				allTerritoryIdsMap.put(s.Id, s.Territories_gne__c.split(';'));
				allTerritoryIds.addAll(s.Territories_gne__c.split(';'));
			}
			surveyIdToRecordTypeMap.put(s.Id, s.Record_Type_gne__c);
		}

		Map<String, Territory2> allTerritoryNamesMap = new Map<String, Territory2> (
		[SELECT Id, Name FROM Territory2 WHERE Id IN :allTerritoryIds]);

		for (Id surveyId : allTerritoryIdsMap.keySet()) {
			Set<String> currentTerritoryNames = new Set<String>();
			for (String terrId : allTerritoryIdsMap.get(surveyId)) {
				if(allTerritoryNamesMap.get(terrId) != null) {
					currentTerritoryNames.add(allTerritoryNamesMap.get(terrId).Name);
				}
			}
			surveyIdToTerritoriesMap.put(surveyId, new List<String> (currentTerritoryNames));
			surveyToTerritoryNamesMap.put(surveyId, currentTerritoryNames);
			allTerritoryNames.addAll(currentTerritoryNames);

			if(surveyIdToTerritoriesMap.size() == 0) {
				surveyIdToTerritoriesMap.put(surveyId, new List<String>());
			}
		}

		for(TSF_vod__c tsf : [SELECT Account_vod__c, Territory_vod__c FROM TSF_vod__c WHERE (Territory_vod__c IN :allTerritoryNames OR Account_vod__c IN :allAccountIds) AND External_Id_vod__c != null AND Address_vod__c != null]) {
			
			for(Id key : surveyToAccountIdsMap.keySet()) {
				
				accountId = String.valueOf(tsf.Account_vod__c);
				
				if(surveyIdToRecordTypeMap.containsKey(key) && surveyIdToRecordTypeMap.get(key) == 'Account') {
			
					if(surveyToAccountIdsMap.get(key).contains(accountId.substring(0, accountId.length() - 3))) {
						
						if(result.containsKey(key)) {
							result.get(key).add(tsf);
						} else {
							result.put(key, new List<TSF_vod__c> { tsf });
						}
						
					}
					
				}
				
			}
			
			for(Id key : surveyToTerritoryNamesMap.keySet()) {
				
				if(surveyIdToRecordTypeMap.containsKey(key) && surveyIdToRecordTypeMap.get(key) == 'Account') {
				
					if(surveyToTerritoryNamesMap.get(key).contains(tsf.Territory_vod__c)) {
						
						if(result.containsKey(key)) {
							result.get(key).add(tsf);
						} else {
							result.put(key, new List<TSF_vod__c> { tsf });
						}
						
					}
				
				}
				
			}
			
		}

		surveyToTSFsMap = result;
	}

}