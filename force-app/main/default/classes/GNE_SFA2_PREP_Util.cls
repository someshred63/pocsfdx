public class GNE_SFA2_PREP_Util {
	public static final String PREP_STATUS_RED = 'Red';
	public static final String PREP_STATUS_YELLOW = 'Yellow';
	public static final String PREP_STATUS_LIGHT_GREEN = 'Light Green';
	public static final String PREP_STATUS_DARK_GREEN = 'Dark Green';
	public static final String PREP_STATUS_GREEN = 'Green';
	public static final String PREP_STATUS_GRAY = 'Gray';

	public static final String PREP_INTERACTION_RECORD_TYPE_NAME = 'PREP Interaction';

	public static final Map<String,String> StatusDescriptions = new Map<String,String> {
		PREP_STATUS_RED => 'Initial Discussion',
		PREP_STATUS_YELLOW => 'In Progress',
		PREP_STATUS_LIGHT_GREEN => 'Verified',
		PREP_STATUS_DARK_GREEN => 'Complete',
		PREP_STATUS_GRAY => 'N/A'
	};

	private static Map<String,Map<String,SFA2_PREP_MBO_gne__c>> mboCache;
	private static Map<String,SFA2_PREP_Testing_Strategy_gne__c> tStrategyCache;
	private static List<SFA2_PREP_Testing_Strategy_gne__c> tStrategyListCache;
	private static Set<Id> prepInteractionRecordTypeIds;
	private static Map<Id,Territory2> territoryCache;
    private static Map<Id,Id> groupIdToTerritoryIdCache;
    private static Map<Id,User> usersCache;

	private enum CACHE_MODE { FORACCOUNT, FORCALL, ALL }
	private static CACHE_MODE cMode;

	public static Map<Id,List<Database.SaveResult>> setMBOStatus(Set<Id> accStrategyIds) {
		Map<Id,List<Database.SaveResult>> sResults = new Map<Id,List<Database.SaveResult>>();
		List<SFA2_PREP_Account_MBO_gne__c> accMBOsToUpdate = new List<SFA2_PREP_Account_MBO_gne__c>();
		Map<Id,Id> mboToStrategyMap = new Map<Id,Id>();

		for(SFA2_PREP_Account_MBO_gne__c aMBO : getAccountMBOs(accStrategyIds)) {
			String oldValue = aMBO.Status_gne__c;
			String newValue = aMBO.Account_Testing_Strategy_gne__r.Status_gne__c;

			if(oldValue!=newValue) {
				aMBO.Status_gne__c = newValue;
				accMBOsToUpdate.add(new SFA2_PREP_Account_MBO_gne__c(Id=aMBO.Id, Status_gne__c = aMBO.Status_gne__c));
				mboToStrategyMap.put(aMBO.Id, aMBO.Account_Testing_Strategy_gne__c);
				sResults.put(aMBO.Account_Testing_Strategy_gne__c, new List<Database.SaveResult>());
			}
		}

		if(!accMBOsToUpdate.isEmpty()) {
			GNE_SFA2_PREP_Trigger_Helper.setAccMBOTrig(true);
			Database.SaveResult[] sResultsTmp = Database.update(accMBOsToUpdate,false);
			GNE_SFA2_PREP_Trigger_Helper.setAccMBOTrig(false);

			for(Database.SaveResult sResult : sResultsTmp) {
				sResults.get(mboToStrategyMap.get(sResult.getId())).add(sResult);
    		}
		}

		return sResults;
	}

	public static Database.SaveResult[] setAccountStrategyStatus(Set<Id> accStrategyIds) {
		Database.SaveResult[] sResults = null;
		List<SFA2_PREP_Account_Testing_Strategy_gne__c> accStrategiesToUpdate = new List<SFA2_PREP_Account_Testing_Strategy_gne__c>();

		for(SFA2_PREP_Account_Testing_Strategy_gne__c aStrategy : getActiveForAccountStrategiesByIds(accStrategyIds)) {
			String oldValue = aStrategy.Status_gne__c;
			String newValue = getAccountStrategyStatus(aStrategy);

			if(oldValue!=newValue) {
				aStrategy.Status_gne__c = newValue;
				accStrategiesToUpdate.add(new SFA2_PREP_Account_Testing_Strategy_gne__c(Id=aStrategy.Id, Status_gne__c = aStrategy.Status_gne__c));
			}
		}

		if(!accStrategiesToUpdate.isEmpty()) {
			sResults = Database.update(accStrategiesToUpdate,false);
		}

		return sResults;
	}

	public static Database.SaveResult[] setAccountStatus(Set<Id> accIds) {
		Database.SaveResult[] sResults = null;
		List<Account> accToUpdate = new List<Account>();
		Map<Id, List<SFA2_PREP_Account_Testing_Strategy_gne__c>> aStrategiesPerAccountMap = new Map<Id, List<SFA2_PREP_Account_Testing_Strategy_gne__c>>();
		Map<Id,String> accStatuses = new Map<Id,String>();

		for(SFA2_PREP_Account_Testing_Strategy_gne__c aStrategy : getActiveForAccountStrategies(accIds)) {
			if(!aStrategiesPerAccountMap.containsKey(aStrategy.Account_gne__c)) {
				aStrategiesPerAccountMap.put(aStrategy.Account_gne__c, new List<SFA2_PREP_Account_Testing_Strategy_gne__c>());
			}

			aStrategiesPerAccountMap.get(aStrategy.Account_gne__c).add(aStrategy);
			accStatuses.put(aStrategy.Account_gne__c, aStrategy.Account_gne__r.PREP_Status_gne__c);
		}

		for(Id accId : aStrategiesPerAccountMap.keySet()) {
			String oldValue = accStatuses.get(accId);
			String newValue = getAccountStatus(aStrategiesPerAccountMap.get(accId));

			if(oldValue!=newValue) {
				accToUpdate.add(new Account(Id=accId, PREP_Status_gne__c = newValue));
			}
		}

		if(!accToUpdate.isEmpty()) {
			GNE_SFA2_Account_Trigger_Helper.setAccountTrig(true);
			sResults = Database.update(accToUpdate,false);
			GNE_SFA2_Account_Trigger_Helper.setAccountTrig(false);
		}

		return sResults;
	}

	public static String getAccountStrategyStatus(SFA2_PREP_Account_Testing_Strategy_gne__c aStrategy) {
		Set<String> existingStatuses = new Set<String>();
		String strategyKey = getRecordKey(aStrategy.Testing_Strategy_gne__r);
		Set<String> notUsedMbosKeys = new Set<String>(getActiveForAccountMBOsMap(strategyKey).keySet());

		for(SFA2_PREP_Account_MBO_gne__c aMBO : aStrategy.Account_MBOs_gne__r) {
			notUsedMbosKeys.remove(getRecordKey(aMBO.MBO_gne__r));
			existingStatuses.add(aMBO.Status_gne__c);
		}

		// Add Default Status for all MBOs that are not yet defined for given Strategy
		if(!notUsedMbosKeys.isEmpty()) {
			for(String mboKey : notUsedMbosKeys) {
				SFA2_PREP_MBO_gne__c mbo = getActiveForAccountMBO(strategyKey, mboKey);
				existingStatuses.add(String.isNotBlank(mbo.Default_Status_gne__c) ? mbo.Default_Status_gne__c : PREP_STATUS_RED);
			}
		}

		// Replace Light Green with Green, because from Strategy perspective those statuses are treated the same
		if(existingStatuses.remove(PREP_STATUS_LIGHT_GREEN)) {
			existingStatuses.add(PREP_STATUS_DARK_GREEN);
		}

		Boolean isOnlyGray = existingStatuses.size() == 1 && existingStatuses.contains(PREP_STATUS_GRAY);
		existingStatuses.remove(PREP_STATUS_GRAY);

		return isOnlyGray
			? PREP_STATUS_GRAY
			: (existingStatuses.size()>1 || existingStatuses.contains(PREP_STATUS_YELLOW))
				? PREP_STATUS_YELLOW
				: (existingStatuses.contains(PREP_STATUS_DARK_GREEN)
						? PREP_STATUS_GREEN // in case of Light Green or Dark Green return just a Green
						: PREP_STATUS_RED);
	}

	public static String getAccountStatus(List<SFA2_PREP_Account_Testing_Strategy_gne__c> aStrategies) {
		Set<String> existingStatuses = new Set<String>();
		Set<String> notUsedStrategyKeys = new Set<String>(getActiveForAccountStrategiesMap().keySet());

		for(SFA2_PREP_Account_Testing_Strategy_gne__c aStrategy : aStrategies) {
			notUsedStrategyKeys.remove(getRecordKey(aStrategy.Testing_Strategy_gne__r));

			if(aStrategy.Status_gne__c == PREP_STATUS_GRAY) {
				continue;
			} else{
				existingStatuses.add(aStrategy.Status_gne__c);
			}
		}

		// Add Red Status for all Strategies that are not yet defined for given Account
		if(!notUsedStrategyKeys.isEmpty()) {
			existingStatuses.add(PREP_STATUS_RED);
		}

		return (existingStatuses.size()>1 || existingStatuses.contains(PREP_STATUS_YELLOW))
				? PREP_STATUS_YELLOW
				: (existingStatuses.contains(PREP_STATUS_GREEN)
						? PREP_STATUS_GREEN
						: PREP_STATUS_RED);
	}

	public static List<SFA2_PREP_Testing_Strategy_gne__c> getActiveForAccountTestingStrategiesWithMBOs() {
		cacheStrategiesWithMBOs(CACHE_MODE.FORACCOUNT);
		return tStrategyListCache;
	}

	public static List<SFA2_PREP_Testing_Strategy_gne__c> getAllTestingStrategiesWithMBOs() {
		cacheStrategiesWithMBOs(CACHE_MODE.ALL);
		return tStrategyListCache;
	}

	public static Map<String,SFA2_PREP_Testing_Strategy_gne__c> getActiveForAccountStrategiesMap() {
		cacheStrategiesWithMBOs(CACHE_MODE.FORACCOUNT);
		return tStrategyCache;
	}

	public static Map<String,SFA2_PREP_MBO_gne__c> getActiveForAccountMBOsMap(String tStrategyKey) {
		cacheStrategiesWithMBOs(CACHE_MODE.FORACCOUNT);
		return mboCache.containsKey(tStrategyKey) ? mboCache.get(tStrategyKey) : new Map<String,SFA2_PREP_MBO_gne__c>();
	}

	public static SFA2_PREP_MBO_gne__c getActiveForAccountMBO(String tStrategyKey, String mboKey) {
		return getActiveForAccountMBOsMap(tStrategyKey).get(mboKey);
	}

	private static void cacheStrategiesWithMBOs(CACHE_MODE cacheMode) {
		if(tStrategyCache == null || cMode != cacheMode) {
			tStrategyListCache = new List<SFA2_PREP_Testing_Strategy_gne__c>();
			tStrategyCache = new Map<String,SFA2_PREP_Testing_Strategy_gne__c>();
			mboCache = new Map<String,Map<String,SFA2_PREP_MBO_gne__c>>();

			Boolean activeForAccount = cacheMode == CACHE_MODE.FORACCOUNT;
			Boolean activeForCall = cacheMode == CACHE_MODE.FORCALL;

			for(SFA2_PREP_Testing_Strategy_gne__c tStrategy : GNE_SFA2_PREP_DAO.getTestingStrategiesWithMBOs(activeForAccount, activeForCall)) {
				String tStrategyKey = getRecordKey(tStrategy);
				tStrategyListCache.add(tStrategy);
				tStrategyCache.put(tStrategyKey, tStrategy);
				Map<String,SFA2_PREP_MBO_gne__c> mbos = new Map<String,SFA2_PREP_MBO_gne__c>();
				mboCache.put(tStrategyKey, mbos);

				for(SFA2_PREP_MBO_gne__c mbo : tStrategy.MBOs_gne__r) {
					mbos.put(getRecordKey(mbo), mbo);
				}
			}
			cMode = cacheMode;
		}
	}

	public static List<SFA2_PREP_Account_MBO_gne__c> getAccountMBOs(Set<Id> accStrategyIds) {
		return GNE_SFA2_PREP_DAO.getAccountMBOs(accStrategyIds);
	}

	public static List<SFA2_PREP_Account_Testing_Strategy_gne__c> getActiveForAccountStrategiesByIds(Set<Id> accStrategyIds) {
		return GNE_SFA2_PREP_DAO.getActiveForAccountStrategiesByIds(accStrategyIds);
	}

	public static List<SFA2_PREP_Account_Testing_Strategy_gne__c> getActiveForAccountStrategies(Set<Id> accIds) {
		return GNE_SFA2_PREP_DAO.getActiveForAccountStrategies(accIds);
	}

	public static List<Account> getAccountsWithStatus(Set<Id> accIds) {
		return GNE_SFA2_PREP_DAO.getAccountsWithStatus(accIds);
	}

	public static List<SFA2_PREP_Account_Testing_Info_gne__c> getTestingInfos(Set<Id> accIds) {
		return GNE_SFA2_PREP_DAO.getTestingInfos(accIds);
	}

	public static List<Account> getAccountsProfTypes(Set<Id> accIds) {
		return GNE_SFA2_PREP_DAO.getAccountsProfTypes(accIds);
	}

	public static Boolean isPrepInteraction(Call2_vod__c call) {
		return getPrepInteractionRecordTypeIds().contains(call.RecordTypeId);
	}

	@TestVisible
	private static Set<Id> getPrepInteractionRecordTypeIds() {
		if(prepInteractionRecordTypeIds==null) {
			prepInteractionRecordTypeIds = new Set<Id>();

			for(Schema.RecordTypeInfo rtInfo : Call2_vod__c.sObjectType.getDescribe().getRecordTypeInfos()) {
				if(rtInfo.getName() == PREP_INTERACTION_RECORD_TYPE_NAME) {
					prepInteractionRecordTypeIds.add(rtInfo.getRecordTypeId());
				}
			}
		}

		return prepInteractionRecordTypeIds;
	}

	public static List<Messaging.SendemailResult> sendEmailNotification(List<String> emailAddresses, List<String> ccEmailAddresses, String subject, String message) {
    	return sendEmailNotification( emailAddresses, ccEmailAddresses, subject, message, true);
    }

    public static List<Messaging.SendemailResult> sendEmailNotification(List<String> emailAddresses, List<String> ccEmailAddresses, String subject, String message, Boolean isHtmlBody) {
    	List<Messaging.SendemailResult> results = null;

    	if(!emailAddresses.isEmpty()) {
    		//Create a new single email message object
	        Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
	        emailMsg.setCharset('UTF-8');
	        //Address
	        emailMsg.setToAddresses(parseEmailAddresses(emailAddresses));
	        if(ccEmailAddresses!=null && !ccEmailAddresses.isEmpty()) {
	        	emailMsg.setCCAddresses(parseEmailAddresses(ccEmailAddresses));
	        }
	        // Subject
	        emailMsg.setSubject(subject);
	        //Content
	        if(isHtmlBody==true) {
	        	emailMsg.setHtmlBody(message!=null ? message : '');
	        } else {
	        	emailMsg.setPlainTextBody(message!=null ? message : '');
	        }
	        //Send
	        results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailMsg}, false);

		    for(Messaging.SendemailResult result : results) {
		    	if (!result.isSuccess()){
			    	for(Messaging.SendEmailError err : result.getErrors()) {
			       		System.debug('Couldn\'t send PREP Email Notification. Reason: ' + err.getMessage());
			    	}
			    }
		    }
		}

		return results;
    }

    private static List<String> parseEmailAddresses(List<String> emailAddresses) {
    	List<String> result = new List<String>();

    	Pattern emailPattern = Pattern.compile('(^|^.*\\s|^.*<)(([^\\s<]+)@([^\\s>]+)).*$');
    	for(String emailAddress : emailAddresses) {
			Matcher emailMatcher = emailPattern.matcher(emailAddress);
			if(emailMatcher.find()) {
				result.add(emailMatcher.group(2));
			}
    	}

    	return result;
    }

    public static Set<Id> getPrepTerritoriesGroupIds() {
    	cacheTerritories();
    	return groupIdToTerritoryIdCache.keySet();
    }

    private static void cacheTerritories() {
    	if(territoryCache==null) {
    		territoryCache = new Map<Id,Territory2>();
    		groupIdToTerritoryIdCache = new Map<Id,Id>();
    		Set<Id> terrIds = new Set<Id>();

    		for(Territory2 terr : GNE_SFA2_PREP_DAO.getTerritories(GNE_SFA2_PREP_Config.RootTerritoryNumber)) {
    			terrIds.add(terr.Id);
    		}

    		for(Group gr : GNE_SFA2_PREP_DAO.getGroupsForTerritoryIds(terrIds)) {
    			groupIdToTerritoryIdCache.put(gr.Id, gr.RelatedId);
    		}
    	}
    }

    public static Map<Id,Call_PREP_MBO_gne__c> getCallMbos(Id callId) {
    	return getCallMbos(GNE_SFA2_PREP_DAO.getCallMbos(callId));
    }

    public static Map<Id,Call_PREP_MBO_gne__c> getCallMbos(List<Call_PREP_MBO_gne__c> cMbos) {
    	Map<Id,Call_PREP_MBO_gne__c> result = new Map<Id,Call_PREP_MBO_gne__c>();

    	for(Call_PREP_MBO_gne__c cMbo : (cMbos!=null ? cMbos : new List<Call_PREP_MBO_gne__c>())) {
    		result.put(cMbo.Mbo_gne__c, cMbo);
    	}

    	return result;
    }

    public static void manageCallMbos(Id callId, Set<String> newMboIds, List<Call_PREP_MBO_gne__c> cMbos) {
    	manageCallMbos(callId, newMboIds, getCallMbos(cMbos));
    }

    public static void manageCallMbos(Id callId, Set<String> newMboIds, Map<Id,Call_PREP_MBO_gne__c> cMbosMap) {
    	Map<Id,Call_PREP_MBO_gne__c> existingCallMboIdsToRemove = new Map<Id,Call_PREP_MBO_gne__c>(cMbosMap);
    	List<Call_PREP_MBO_gne__c> cMbosToInsert = new List<Call_PREP_MBO_gne__c>();

    	for(String mboId : newMboIds) {
    		if(existingCallMboIdsToRemove.remove(mboId)==null) {
    			Call_PREP_MBO_gne__c newCallMbo = new Call_PREP_MBO_gne__c(
    				Call_gne__c = callId,
    				Mbo_gne__c = mboId
    			);

    			cMbosToInsert.add(newCallMbo);
    		}
    	}

    	if(!existingCallMboIdsToRemove.isEmpty()) {
    		delete existingCallMboIdsToRemove.values();
    	}

    	if(!cMbosToInsert.isEmpty()) {
    		insert cMbosToInsert;
    	}
    }

    public static Boolean isPrepUser(Id userId) {
    	return isPrepUser(getUserProfileName(userId));
    }

    public static Boolean isPrepUser(String profileName) {
    	return profileName.containsIgnoreCase('-PREP-');
    }

    public static String getUserProfileName(Id userId) {
    	cacheUser(userId);
    	return usersCache.containsKey(userId) ? usersCache.get(userId).Profile.Name : '';
    }

    public static void cacheUser(Id userId) {
    	if(usersCache==null) {
    		usersCache = new Map<Id,User>();
    	}

    	if(!usersCache.containsKey(userId)) {
    		User u = GNE_SFA2_PREP_DAO.getUser(userId);
    		usersCache.put(userId, u);
    	}
    }

	public static String getRecordKey(SFA2_PREP_MBO_gne__c mbo) {
		return mbo.Testing_Strategy_ref_gne__c +'_' +  mbo.Id;
	}

	public static String getRecordKey(SFA2_PREP_Testing_Strategy_gne__c tStrategy) {
		return tStrategy.Id;
	}

	public static String getRecordKey(SFA2_PREP_Account_Testing_Strategy_gne__c aStrategy) {
		return getRecordKey(aStrategy.Testing_Strategy_gne__r) +'_' +  aStrategy.Account_gne__c;
	}

	public static String getRecordKey(SFA2_PREP_Account_MBO_gne__c aMBO) {
		return getRecordKey(aMBO.MBO_gne__r) +'_' + aMBO.Account_Testing_Strategy_gne__r.Account_gne__c;
	}

	public static List<TestingStrategyWrapper> getPrepStrategyWrappers() {
		List<TestingStrategyWrapper> tStrategies = new List<TestingStrategyWrapper>();

		for(SFA2_PREP_Testing_Strategy_gne__c tStrategy : getAllTestingStrategiesWithMBOs()) {
			List<TestingMboWrapper> mboWrappers = new List<TestingMboWrapper>();

			for(SFA2_PREP_MBO_gne__c mbo : tStrategy.MBOs_gne__r) {
				TestingMboWrapper mboWrapper = new TestingMboWrapper(mbo);
				mboWrappers.add(mboWrapper);
			}

			mboWrappers.sort();
			tStrategies.add(new TestingStrategyWrapper(tStrategy, mboWrappers));
		}

		return tStrategies;
	}

	public virtual class TestingStrategyWrapper {
		@TestVisible public Id id;
		@TestVisible public Id pid;
		@TestVisible public String nm;
		@TestVisible public String dsc;
		@TestVisible public Integer ord;
		@TestVisible public Boolean afa;
		@TestVisible public Boolean afc;
		@TestVisible public List<TestingMboWrapper> mbos;

		public TestingStrategyWrapper(SFA2_PREP_Testing_Strategy_gne__c tStrategy, List<TestingMboWrapper> a_mbos) {
			id = tStrategy.Id;
			pid = tStrategy.Product_gne__c;
			nm = tStrategy.Name;
			dsc = null;
			ord = tStrategy.Order_gne__c!=null ? tStrategy.Order_gne__c.intValue() : null;
			afa = tStrategy.Active_for_Account_gne__c;
			afc = tStrategy.Active_for_Call_gne__c;
			mbos = a_mbos;

			if(mbos!=null) {
				Integer idx = 0;
				for(TestingMboWrapper mbo : mbos) {
					mbo.setOrder(idx++);
				}
			}
		}
	}

	public virtual class TestingMboWrapper implements Comparable {
		@TestVisible public Id id;
		@TestVisible public Id tsi;
		@TestVisible public String nm;
		@TestVisible public String dsc;
		@TestVisible public String def;
		@TestVisible public String dft;
		@TestVisible public Integer ord;
		@TestVisible public Boolean afa;
		@TestVisible public Boolean afc;

		// Deprecated
		@TestVisible public Boolean ac;

		public TestingMboWrapper(SFA2_PREP_MBO_gne__c mbo) {
			id = mbo.Id;
			tsi = mbo.Testing_Strategy_ref_gne__c;
			nm = mbo.Name;
			dsc = mbo.Short_Description_gne__c;
			def = mbo.Definition_gne__c;
			dft = String.isNotBlank(mbo.Default_Status_gne__c) ? mbo.Default_Status_gne__c : PREP_STATUS_RED;
			ord = null;
			afa = mbo.Active_for_Account_gne__c;
			afc = mbo.Active_for_Call_gne__c;
			ac = mbo.Active_gne__c;
		}

		public void setOrder(Integer newOrder) {
			ord = newOrder;
		}

		public Integer compareTo(Object compareTo) {
			Integer result=0;

			TestingMboWrapper other = (TestingMboWrapper)compareTo;
			List<String> thisStringAndNumbers = getStringAndNumbersFromName();
			List<String> otherStringAndNumbers = other.getStringAndNumbersFromName();
			Integer thisSize = thisStringAndNumbers.size();
			Integer otherSize = otherStringAndNumbers.size();

			for(Integer i=0;i<Math.max(thisStringAndNumbers.size(), otherStringAndNumbers.size()); i++) {
				String thisValue = i<thisSize ? thisStringAndNumbers[i] : '';
				String otherValue = i<otherSize ? otherStringAndNumbers[i] : '';
				Boolean isBothNumeric = thisValue.isNumeric() && otherValue.isNumeric();

				if(isBothNumeric) {
					Integer thisNumber = Integer.valueOf(thisValue);
					Integer otherNumber = Integer.valueOf(otherValue);

					result = thisNumber==otherNumber ? 0 : (thisNumber>otherNumber ? 1 : -1);
				} else {
					result = thisValue.trim().compareTo(otherValue.trim());
				}

				if(result!=0) {
					break;
				}
			}

			return result;
		}

		private List<String> getStringAndNumbersFromName() {
			String text = nm;

			List<String> elements = new List<String>();
			Integer lastIdx = null;

			for(Integer i=0;i<text.length();i++) {
				String c = text.substring(i,i+1);
				Boolean isNumber = c.isNumeric();

				if(lastIdx==null || elements[lastIdx].isNumeric() != c.isNumeric()) {
					elements.add(c);
					lastIdx = lastIdx==null ? 0 : lastIdx+1;
				} else {
					elements[lastIdx] = elements[lastIdx] + c;
				}
			}

			return elements;
		}
	}
}