public without sharing class GNE_SFA2_Interaction_Util {

	public static boolean PARENT_CALL_UPDATE_MODE {get; set;}
	public static boolean insertAction {get; set;}
	public static boolean submitCheck {get; set;}
	public static boolean sampleCancel {get; set;}
	public static boolean updateAction {get; set;}
	private static Map<id, Call2_vod__c> beforeCalls;
	public static boolean UpdateSampleTransactionAction { get; set; }
	private static Map<Id, Territory2> interactionTerritory;
	private static Boolean isMSLORMCLUser = null;
	private static Set<String> CANADA_EXTENDED_PROFILES = new Set<String> {'RCanada-SFA-TS', 'RCanada-SFA-Manager', 'RCanada-SFA-MSL', 'RCanada-SFA-SAM', 'RCanada-SFA-RAMA'};

	public static String selectInteractionTerritory() {
		return selectInteractionTerritory(Userinfo.getUserId(), true);
	}

	public static Territory2 getInteractionTerritory() {
		return getInteractionTerritory(Userinfo.getUserId(), true);
	}

	public static String selectInteractionTerritory(Id userId, Boolean dmlAllowed) {
		Territory2 terr = getInteractionTerritory(userId, dmlAllowed);
		if(terr != null){
			return terr.Name;
		}
		return null;
	}

	public static Territory2 getInteractionTerritory(Id userId, Boolean dmlAllowed) {
		Territory2 territory = null;

		if(interactionTerritory==null) {
			interactionTerritory = new Map<Id, Territory2>();
		}

		if(interactionTerritory.containsKey(userId)) {
			territory = interactionTerritory.get(userId);
		} else {
			List<SFA2_User_Preferences_gne__c> userPreferences = [SELECT Last_Territory_Used_gne__c FROM  SFA2_User_Preferences_gne__c WHERE Last_View_Used_gne__r.Page_Name_gne__c = 'My Accounts' AND OwnerId = :userId LIMIT 1];
			List<Territory2> userTerritories = getUserTerritories(userId);
			Set<Id> userTerritoriesIds = new Set<Id>();
			for(Territory2 terr : userTerritories) {
				userTerritoriesIds.add(terr.Id);
			}
			/*first case - user selected territory on My Accounts - we get this territory*/
			if (!userPreferences.isEmpty() && !String.isEmpty(userPreferences.get(0).Last_Territory_Used_gne__c) && userTerritoriesIds.contains(userPreferences.get(0).Last_Territory_Used_gne__c)) {
				territory = [SELECT id, Name FROM Territory2 WHERE Id = :userPreferences.get(0).Last_Territory_Used_gne__c LIMIT 1];
			} else if(!userPreferences.isEmpty() && !String.isEmpty(userPreferences.get(0).Last_Territory_Used_gne__c) && !userTerritories.isEmpty() && !userTerritoriesIds.contains(userPreferences.get(0).Last_Territory_Used_gne__c)) {
				userPreferences.get(0).Last_Territory_Used_gne__c = userTerritories.get(0).Id;
				if(dmlAllowed==true) {
					upsert userPreferences;
				}
				territory = [SELECT id, Name FROM Territory2 WHERE Id = :userPreferences.get(0).Last_Territory_Used_gne__c LIMIT 1];
			} else {
				/*second case - user don't have any territory selected on My Accounts - we return first master user territory we find*/
				if (!userTerritoriesIds.isEmpty()) {
					territory = [SELECT id, Name FROM Territory2 WHERE Id in :userTerritoriesIds ORDER BY External_id_gne__c ASC].get(0);
				} /*third case - user don't have any territory*/
			}
			interactionTerritory.put(userId, territory);
		}
		return territory;
	}

	public static List<Territory2> getUserTerritories(Id userId){
		return GNE_SFA2_Util.getUserTerritories(userId);
	}

	/*Return map account -> territory name base on user territories and tsfs*/
	public static Map<Id, String> getCallSelectedTerritories(Set<Id>accountIds) {
		Map<Id, String> accountToTerritory = new Map<Id, String>();

		String currentUserId = UserInfo.getUserId();
		List<String> allUserTerritoryIds = new List<String>();
		List<String> allUserTerritoryNames = new List<String>();

		for (UserTerritory2Association ut : [SELECT Territory2Id FROM UserTerritory2Association  WHERE UserId = :currentUserId AND IsActive = true]) {
			allUserTerritoryIds.add(ut.Territory2Id);
		}
		for (Territory2 territory : [SELECT Name FROM Territory2 WHERE Id in :allUserTerritoryIds ORDER BY External_id_gne__c DESC]) {
			allUserTerritoryNames.add(territory.Name);
		}

		// Stamp the territory that the user is assigned to and the account is aligned
		// Sort them descending to retrieve child territory as first element in case of more than one match found
		if (accountIds != null && !accountIds.isEmpty() && !allUserTerritoryNames.isEmpty()) {
			for (TSF_vod__c tsf : [SELECT Territory_vod__c, Account_vod__c FROM TSF_vod__c WHERE Account_vod__c in :accountIds AND Territory_vod__c in :allUserTerritoryNames ORDER BY Territory_vod__c DESC]) {
				if (!accountToTerritory.containsKey(tsf.Account_vod__c)) {
					accountToTerritory.put(tsf.Account_vod__c,  tsf.Territory_vod__c);
				}
			}
		}

		// If the account is not aligned to any of the user's territories, then stamp the territory user is asigned to
		// When user is asigned to more then one territory, select child one
		if (!allUserTerritoryNames.isEmpty()) {
			for (Id accountId : accountIds) {
				if (!accountToTerritory.containsKey(accountId)) {
					accountToTerritory.put(accountId,  allUserTerritoryNames[0]);
				}
			}
		}
		return accountToTerritory;
	}

	public static RecordType[] interactionRecordTypes {
		get{
			if (interactionRecordTypes == null) {
				interactionRecordTypes = [Select Id, toLabel(Name), SobjectType from RecordType where (SobjectType = 'Event' and Name = 'Call_vod') or (SobjectType = 'Sample_Transaction_vod__c' and Name = 'Disbursement_vod') or (SobjectType = 'Call2_vod__c')];
			}
			return interactionRecordTypes;
		}
	}

	public static void setMap (Map <Id, Call2_vod__c> pMap) {
		if (beforeCalls != null) {
			beforeCalls.putAll(pMap);
		} else {
			beforeCalls = pMap;
		}
	}

	public static  Map<Id, Call2_vod__c> getMap () {
		return beforeCalls;
	}

	public static void updateEvent (Call2_vod__c [] calls, Map <Id, Call2_vod__c> callMap, String eventRecTypeId) {
		String eveID = null;
		List<Event> updEveList = new List<Event>();

		for (Call2_vod__c callHead : calls) {
			if (callHead.Call_Datetime_vod__c == null || callHead.Parent_Call_vod__c != null) {
				continue;
			}
			eveID = null;
			for (Event eve : callMap.get(callHead.Id).Events) {
				eveID = eve.Id;
				System.debug('eve.ID = ' + eve.Id);
			}

			if (eveID != null) {
				Event updEve = new Event(Id = eveID, ActivityDateTime = callHead.Call_Datetime_vod__c);
				updEveList.add(updEve);
			}
		}

		if (updEveList.size() > 0) {
			update updEveList;
		}
	}

	public static void insertEvent (Call2_vod__c [] calls, Map <Id, Account> accounts, String eventRecTypeId) {
		String callStubText = System.label.Call_Event_Label;
		String useRecordTypeLabel  = System.label.Call_Event_RecordType_Label;
		Boolean bUseRecordType = false;

		if (String.isEmpty(callStubText)) {
			callStubText = 'Call';
		}
		if ('true'.equalsIgnoreCase(useRecordTypeLabel)) {
			bUseRecordType = true;
		}

		Set<Id> medEventIds = new Set<Id>();
		for (Call2_vod__c aCall : calls) {
			if (aCall.Medical_Event_vod__c != null) {
				medEventIds.add(aCall.Medical_Event_vod__c);
			}
		}
		Map<Id, Medical_Event_vod__c> medEvents = null;
		if (medEventIds.size() > 0) {
			medEvents = new Map<Id, Medical_Event_vod__c>([Select Id, Name From Medical_Event_vod__c Where Id In :medEventIds]);
		}

		List<Event> eveList = new List<Event>();
		Account acct = null;
		for (Call2_vod__c callHead : calls) {
			if (callHead.Parent_Call_vod__c != null || callHead.Call_Datetime_vod__c == null) {
				continue;
			}

			if (bUseRecordType == true) {
				for (RecordType rect : interactionRecordTypes) {
					if (rect.Id == callHead.RecordTypeId) {
						callStubText = rect.Name;
						break;
					}
				}
			}
			acct = accounts.get(callHead.Account_vod__c);
			if (acct == null) {
				continue;
			}
			Event newEvent = new Event();
			//  newEvent.AccountId = callHead.Account_vod__c;
			newEvent.OwnerId = callHead.CreatedById;
			newEvent.WhatId = callHead.Id;
			newEvent.Subject = callStubText + '-';
			if (acct != null) {
				newEvent.Subject += acct.Name;
			} else if ((callHead.Medical_Event_vod__c != null) && (medEvents != null)) {
				Medical_Event_vod__c me = medEvents.get(callHead.Medical_Event_vod__c);
				if (me != null) {
					newEvent.Subject += me.Name;
				}
			}
			newEvent.DurationInMinutes = 15;
			newEvent.Location = callHead.Address_vod__c;
			newEvent.RecordTypeId = eventRecTypeId;
			newEvent.ActivityDateTime = callHead.Call_Datetime_vod__c;
			eveList.add (newEvent);
		}
		try {
			if (eveList.size() > 0) {
				insert eveList;
			}
		} catch (System.DmlException e) {
			for (Integer er = 0; er < calls.size(); er++)
			calls[er].Id.addError('Cannot_Add_Event_Label');
		}
	}

	public static Error_Log_gne__c createError(String objectName, String errorLevel, String snippetName, String codeType, Database.Error e) {
		String errorDescription = e.getMessage().length() > 4000 ? e.getMessage().substring(0, 4000) : e.getMessage();
		return createError(objectName, errorLevel, snippetName, codeType, errorDescription);
	}

	public static Error_Log_gne__c createError(String objectName, String errorLevel, String snippetName, String codeType, Exception e) {
		String errorDescription = GlobalUtils.getExceptionDescription(e).length() > 4000 ? GlobalUtils.getExceptionDescription(e).substring(0, 4000) : GlobalUtils.getExceptionDescription(e);
		return createError(objectName, errorLevel, snippetName, codeType, errorDescription);
	}

	public static Error_Log_gne__c createError(String objectName, String errorLevel, String snippetName, String codeType, String errMessage) {
		return new Error_Log_gne__c(Object_Name__c = objectName, Error_Level_gne__c = errorLevel,   Snippet_Name__c = snippetName, Code_Type__c = codeType,
		Error_Description__c = errMessage.length() > 4000 ? errMessage.substring(0, 4000) : errMessage, User_Name__c = getUserName());
	}

	// Check if user can edit value in the Unsolicited_Request_gne__c field.
	// This priviledge must be enabled even after interaction is completed.
	public static Boolean getHasUnsolicitedFieldEditAvailibleCanada() {
		Boolean result = false;
		String userProfile = GNE_SFA2_Util.getCurrentUserProfileName().toUpperCase();
		Set<String> priviledgedProfiles = new Set<String> {
			'RCANADA-SFA-MSL',
			'RCANADA-SFA-OPS'
		};
		if (priviledgedProfiles.contains(userProfile)) {
			result = true;
		}
		return result;
	}

	private static String getUserName() {
		String userName = UserInfo.getUserName();
		if (userName.length() > 30) {
			userName = userName.subString(0, 30);
		}
		return userName;
	}

	public static Boolean getIsMSLORMCLUser(){
		if (isMSLORMCLUser != null){
			return isMSLORMCLUser;
		}
		isMSLORMCLUser = false;
		String userProfile = GNE_SFA2_Util.getCurrentUserProfileName();
		for (String profileMask : new Set<String> {'GNE-MEDAFFAIRS-MSL', 'GNE-MEDAFFAIRS-MCL'}){
			if (userProfile.startsWithIgnoreCase(profileMask)){
				isMSLORMCLUser = true;
				break;
			}
		}
		return isMSLORMCLUser;
	}

	public static boolean isExtendedCanadaUser(String profileName) {
		return CANADA_EXTENDED_PROFILES.contains(profileName);
	}

	/* This methods are used to check if TLL interaction has proper values for new speaker trainig */
	public static Boolean isTLLInteractionForSBT( Call2_Discussion_vod__c cd ) {
		return GNE_SFA2_Util.getCurrentUserProfileName().startsWith('GNE-TLS') && (cd.Activity_gne__c == 'Training/Annual Compliance' || cd.Activity_gne__c == 'Training/Deck Content');
	}
}