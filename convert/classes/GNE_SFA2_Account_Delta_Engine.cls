public with sharing class GNE_SFA2_Account_Delta_Engine {
	public static final String SETTING_NAME_HCP_US_NO_MDMID = 'SBCHcpNoMDMIdType';
	public static final String SETTING_NAME_HCO_US_NO_MDMID = 'SBCHcoNoMDMIdType';
	public static final String SETTING_NAME_DELTA_MODE_ENABLED = 'SBCDeltaModeEnabled';
	
	private static final Pattern ACCOUNT_EXCLUDED_RECORD_TYPE_REGEXP = Pattern.compile('^((gFRS)|(LWO.*)|(.*Canada.*)|(Archived.*))$');
	private static final Pattern ADDRESS_EXCLUDED_RECORD_TYPE_REGEXP = Pattern.compile('^((.*Canada.*)|(Archived.*))$');
	private static final Pattern ACCOUNT_HCP_US_RECORD_TYPE_REGEXP = Pattern.compile('^((.*Professional.*)|(KOL.*))$');
	
	public static Set<Id> ACCOUNT_INCLUDED_RECORD_TYPE_IDS;
	public static Set<Id> ACCOUNT_INCLUDED_HCO_RECORD_TYPE_IDS;
	public static Set<Id> ADDRESS_INCLUDED_RECORD_TYPE_IDS;
	
	private static String hcoUsNoMdmIdType;
	private static String hcpUsNoMdmIdType;
	
	private static Map<Id,SFA2_Address_Delta_gne__c> deltaCache;
	private static Map<Id, List<SFA2_Address_Delta_gne__c>> accountDeltaCache;
	private static Map<Id,Account> accountCache;
	private static Map<Id,Address_vod__c> addressCache;
	private static Set<Id> alreadyAddedErrors;
	
	private static Boolean isDeltaModeEnabled;
	
	static {
		initStatic();
	}
	
	private static void initStatic() {
		if(ACCOUNT_INCLUDED_RECORD_TYPE_IDS==null) {
			ACCOUNT_INCLUDED_RECORD_TYPE_IDS = new Set<Id>();
			ACCOUNT_INCLUDED_HCO_RECORD_TYPE_IDS = new Set<Id>();
			ADDRESS_INCLUDED_RECORD_TYPE_IDS = new Set<Id>();
			
			List<Schema.RecordTypeInfo> rtInfos = Account.getSobjectType().getDescribe().getRecordTypeInfos();
	        
	        for(Schema.RecordTypeInfo rtInfo : rtInfos) {
	        	Id rtId = rtInfo.getRecordTypeId();
	            String rtName = rtInfo.getName();
	            
	            if(!ACCOUNT_EXCLUDED_RECORD_TYPE_REGEXP.matcher(rtName).find()) {
	            	ACCOUNT_INCLUDED_RECORD_TYPE_IDS.add(rtId);
	            	
	            	if(!ACCOUNT_HCP_US_RECORD_TYPE_REGEXP.matcher(rtName).find()) {
	            		ACCOUNT_INCLUDED_HCO_RECORD_TYPE_IDS.add(rtId);
	            	}
	            }
	        }
	        
	        rtInfos = Address_vod__c.getSobjectType().getDescribe().getRecordTypeInfos();
	        
	        for(Schema.RecordTypeInfo rtInfo : rtInfos) {
	        	Id rtId = rtInfo.getRecordTypeId();
	            String rtName = rtInfo.getName();
	            
	            if(!ADDRESS_EXCLUDED_RECORD_TYPE_REGEXP.matcher(rtName).find()) {
            		ADDRESS_INCLUDED_RECORD_TYPE_IDS.add(rtId);
            	}
	        }
		}
	}
	
	public static Boolean isDeltaModeEnabled() {
		if(isDeltaModeEnabled==null) {
			Set<String> yesValues = new Set<String>{'1','true','yes'};
			Map<String, GNE_Foun_Misc_Config_Items_gne__c> mapConfigItems = GNE_Foun_Misc_Config_Items_gne__c.getAll();
			GNE_Foun_Misc_Config_Items_gne__c setting = mapConfigItems.get(SETTING_NAME_DELTA_MODE_ENABLED);
			String settingValue = setting!=null ? setting.Configuration_Value_gne__c : null;
			isDeltaModeEnabled = String.isNotBlank(settingValue) && yesValues.contains(settingValue.toLowerCase());  
		}
		
		return isDeltaModeEnabled;
	}
		
	public static String getHcpUsNoMdmIdType() {
		if(hcpUsNoMdmIdType==null) {
			Map<String, GNE_Foun_Misc_Config_Items_gne__c> mapConfigItems = GNE_Foun_Misc_Config_Items_gne__c.getAll();
			hcpUsNoMdmIdType = mapConfigItems.containsKey(SETTING_NAME_HCP_US_NO_MDMID) ? mapConfigItems.get(SETTING_NAME_HCP_US_NO_MDMID).Configuration_Value_gne__c : 'HCP US - No MDM ID';
		}
		
		return hcpUsNoMdmIdType;
	}
	
	public static String getHcoUsNoMdmIdType() {
		if(hcoUsNoMdmIdType==null) {
			Map<String, GNE_Foun_Misc_Config_Items_gne__c> mapConfigItems = GNE_Foun_Misc_Config_Items_gne__c.getAll();
			hcoUsNoMdmIdType = mapConfigItems.containsKey(SETTING_NAME_HCO_US_NO_MDMID) ? mapConfigItems.get(SETTING_NAME_HCO_US_NO_MDMID).Configuration_Value_gne__c : 'HCO US - No MDM ID';
		}
		
		return hcoUsNoMdmIdType;
	}
	
	public static Boolean isDeltaAccount(Account acc) {
		return ACCOUNT_INCLUDED_RECORD_TYPE_IDS.contains(acc.RecordTypeId);
	}
	
	public static Boolean isDeltaAddress(Address_vod__c addr) {
		return String.isBlank(addr.MDM_Address_ID_gne__c) && ADDRESS_INCLUDED_RECORD_TYPE_IDS.contains(addr.RecordTypeId) && ACCOUNT_INCLUDED_RECORD_TYPE_IDS.contains(addr.Account_Record_Type_Id_calc_gne__c);
	}
	
	public static String getDeltaType(Account acc) {
		return isDeltaAccount(acc) 
			? (ACCOUNT_INCLUDED_HCO_RECORD_TYPE_IDS.contains(acc.RecordTypeId)
				? getHcoUsNoMdmIdType() 
				: getHcpUsNoMdmIdType())  
			: null;
	}
	
	public static String getDeltaType(Address_vod__c addr) {
		Account acc;
		return isDeltaAddress(addr)
			? (ACCOUNT_INCLUDED_HCO_RECORD_TYPE_IDS.contains(addr.Account_Record_Type_Id_calc_gne__c)
				? getHcoUsNoMdmIdType() 
				: getHcpUsNoMdmIdType()) 
			: null;
	}
	
	public static void refreshDeltaRecords(List<Account> accs) {
		refreshDeltaRecords(accs, false, null);
	}
	
	public static void refreshDeltaRecords(List<Account> accs, DeltaErrorHandler errorhandler) {
		refreshDeltaRecords(accs, false, errorhandler);
	}
	
	public static void refreshDeltaRecords(List<Account> accs, Boolean triggerMode) {
		refreshDeltaRecords(accs, triggerMode, null);
	}
	
	public static void refreshDeltaRecords(List<Address_vod__c> addrs) {
		refreshDeltaRecords(addrs, false, null);
	}
	
	public static void refreshDeltaRecords(List<Address_vod__c> addrs, DeltaErrorHandler errorhandler) {
		refreshDeltaRecords(addrs, false, errorhandler);
	}
	
	public static void refreshDeltaRecords(List<Address_vod__c> addrs, Boolean triggerMode) {
		refreshDeltaRecords(addrs, triggerMode, null);
	}
	
	public static void refreshDeltaRecords(List<Account> accs, Boolean triggerMode, DeltaErrorHandler errorhandler) {
		alreadyAddedErrors = new Set<Id>();
		Map<Id,Account> accsMap = new Map<Id,Account>(accs);
		cacheDelta(accs);
		
		List<SFA2_Address_Delta_gne__c> toUpsert = new List<SFA2_Address_Delta_gne__c>();
		List<SFA2_Address_Delta_gne__c> toDelete = new List<SFA2_Address_Delta_gne__c>();
		
		for(Account acc : accs) {
			refreshDeltaRecord(getAccount(acc.Id), toUpsert, toDelete);
		}
		
		executeDMLs(toUpsert, toDelete, accsMap, triggerMode, errorhandler);
	}
	
	public static void refreshDeltaRecords(List<Address_vod__c> addrs, Boolean triggerMode, DeltaErrorHandler errorhandler) {
		alreadyAddedErrors = new Set<Id>();
		Map<Id,Address_vod__c> addrsMap = new Map<Id,Address_vod__c>(addrs);
		cacheDelta(addrsMap.keySet());
		
		List<SFA2_Address_Delta_gne__c> toUpsert = new List<SFA2_Address_Delta_gne__c>();
		List<SFA2_Address_Delta_gne__c> toDelete = new List<SFA2_Address_Delta_gne__c>();
		
		for(Address_vod__c addr : addrs) {
			refreshDeltaRecord(getAddress(addr.Id), toUpsert, toDelete);
		}
		
		executeDMLs(toUpsert, toDelete, addrsMap, triggerMode, errorhandler);
	}
	
	private static void executeDMLs(List<SFA2_Address_Delta_gne__c> toUpsert, List<SFA2_Address_Delta_gne__c> toDelete, Map<Id,Sobject> parentRecsMap, 
			Boolean triggerMode, DeltaErrorHandler errorhandler) {
		if(!toUpsert.isEmpty()) {
			Database.UpsertResult[] upsertResults = Database.upsert(toUpsert, false);
			Integer idx=0;
			
			for(Database.UpsertResult ur : upsertResults) {
				if(!ur.isSuccess()) {
					SFA2_Address_Delta_gne__c deltaRec = toUpsert[idx];
					SObject parentRec = parentRecsMap.containsKey(deltaRec.Address_gne__c) ? parentRecsMap.get(deltaRec.Address_gne__c) : parentRecsMap.get(deltaRec.Account_gne__c);
					handleDatabaseErrors(deltaRec, parentRec, ur.getErrors(), triggerMode, errorhandler);
				}
				
				idx++;
			}
		}
		
		if(!toDelete.isEmpty()) {
			Database.DeleteResult[] deleteResults = Database.delete(toDelete, false);
			Integer idx=0;
			
			for(Database.DeleteResult dr : deleteResults) {
				if(!dr.isSuccess()) {
					SFA2_Address_Delta_gne__c deltaRec = toDelete[idx];
					SObject parentRec = parentRecsMap.containsKey(deltaRec.Address_gne__c) ? parentRecsMap.get(deltaRec.Address_gne__c) : parentRecsMap.get(deltaRec.Account_gne__c);
					handleDatabaseErrors(deltaRec, parentRec, dr.getErrors(), triggerMode, errorhandler);
				}
				
				idx++;
			}
		}
	}
	
	private static  void handleDatabaseErrors(SFA2_Address_Delta_gne__c deltaRec, SObject accOrAddr, Database.Error[] errors, 
			Boolean triggerMode, DeltaErrorHandler errorhandler) {
		if(triggerMode==true && !alreadyAddedErrors.contains(accOrAddr.Id)) {
			List<String> errorMsgs = new List<String>();
		
			for(Database.Error err : errors) {
				errorMsgs.add(err.getMessage());
			}
			
			accOrAddr.addError(String.join(errorMsgs, '||'));
			alreadyAddedErrors.add(accOrAddr.Id);
		}
		
		if(errorhandler!=null) {
			errorhandler.handleDeltaRecordErrors(deltaRec, accOrAddr, errors);
		}
	}
	
	private static void refreshDeltaRecord(Account acc, List<SFA2_Address_Delta_gne__c> toUpsert, List<SFA2_Address_Delta_gne__c> toDelete) {
		List<SFA2_Address_Delta_gne__c> deltaRecs = getDeltaRecordsForAccount(acc.Id);
		String deltaType = getDeltaType(acc);
		
		if(isDeltaAccount(acc)) {
			if(deltaRecs.isEmpty()) {
				for(Address_vod__c addr : acc.Address_vod__r) {
					refreshDeltaRecord(addr, toUpsert, toDelete);
				}
			} else {
				for(SFA2_Address_Delta_gne__c deltaRec : deltaRecs) {
					if(updateDeltaRecord(acc, deltaRec, deltaType)) {
						toUpsert.add(deltaRec);
					}
				}
			}
		} else {
			toDelete.addAll(deltaRecs);
			accountDeltaCache.put(acc.Id, new List<SFA2_Address_Delta_gne__c>());
		}
	}
	
	private static void refreshDeltaRecord(Address_vod__c addr, List<SFA2_Address_Delta_gne__c> toUpsert, List<SFA2_Address_Delta_gne__c> toDelete) {
		SFA2_Address_Delta_gne__c deltaRec = getDeltaRecord(addr.Id);
		Boolean isDeltaAddress = isDeltaAddress(addr);
		String deltaType = getDeltaType(addr);
		
		if(isDeltaAddress) {
			deltaRec = deltaRec!=null ? deltaRec : new SFA2_Address_Delta_gne__c(Address_gne__c = addr.Id, Account_gne__c = addr.Account_vod__c);
			
			if(updateDeltaRecord(addr, deltaRec, deltaType)) {
				toUpsert.add(deltaRec);
				cacheDelta(deltaRec);	
			}
		} else if(isDeltaAddress && deltaRec!=null && deltaRec.Type_gne__c!=deltaType) {
			deltaRec.Type_gne__c = deltaType;
			toUpsert.add(deltaRec);
		} else if(!isDeltaAddress && deltaRec!=null) {
			toDelete.add(deltaRec);
			deltaCache.put(addr.Id, null);
		}
	}
	
	private static Boolean updateDeltaRecord(Address_vod__c addr, SFA2_Address_Delta_gne__c deltaRec, String deltaType) {
		Boolean changed = deltaRec.Id==null;
		changed = updateDeltaRecord(addr.Account_vod__r, deltaRec, deltaType) || changed;
		
		Map<String,Object> newValues = new Map<String,Object>{
			String.valueOf(SFA2_Address_Delta_gne__c.Account_gne__c) => addr.Account_vod__c,
			String.valueOf(SFA2_Address_Delta_gne__c.Address_Name_gne__c) => addr.Name,
			String.valueOf(SFA2_Address_Delta_gne__c.Address_City_gne__c) => addr.City_vod__c,
			String.valueOf(SFA2_Address_Delta_gne__c.Address_State_gne__c) => addr.State_vod__c,
			String.valueOf(SFA2_Address_Delta_gne__c.Address_Zip_gne__c) => addr.Zip_vod__c
		};
		
		return updateDeltaRecord(deltaRec, newValues) || changed;
	}
	
	private static Boolean updateDeltaRecord(Account acc, SFA2_Address_Delta_gne__c deltaRec, String deltaType) {
		Map<String,Object> newValues = new Map<String,Object>{
			String.valueOf(SFA2_Address_Delta_gne__c.Type_gne__c) => deltaType,
			String.valueOf(SFA2_Address_Delta_gne__c.Account_Name_gne__c) => acc.Name,
			String.valueOf(SFA2_Address_Delta_gne__c.Account_First_Name_gne__c) => acc.FirstName,
			String.valueOf(SFA2_Address_Delta_gne__c.Account_Last_Name_gne__c) => acc.LastName,
			String.valueOf(SFA2_Address_Delta_gne__c.Account_Preferred_Name_gne__c) => acc.Preferred_Name_vod__c			
		};
		
		return updateDeltaRecord(deltaRec, newValues);
	}
	
	private static Boolean updateDeltaRecord(SFA2_Address_Delta_gne__c deltaRec, Map<String,Object> newValues) {
		Boolean changed = false;
		
		for(String fieldName : newValues.keySet()) {
			Object newValue = newValues.get(fieldName);
			
			if(deltaRec.get(fieldName)!=newValue) {
				deltaRec.put(fieldName, newValue);
				changed = true;
			}
		}
		
		return changed;
	}
	
	private static void cacheDelta(List<Account> accs) {
		cacheDelta(null, new Map<Id,Account>(accs).keySet());
	}
	
	private static void cacheDelta(List<Address_vod__c> addrs) {
		cacheDelta(new Map<Id,Address_vod__c>(addrs).keySet(), null);
	}
	
	private static void cacheDelta(Set<Id> addrIds) {
		cacheDelta(addrIds, null);
	}
	
	private static void cacheDelta(Set<Id> addrIds, Set<Id> accIds) {
		if(deltaCache==null) {
			deltaCache = new Map<Id,SFA2_Address_Delta_gne__c>();
			accountDeltaCache = new Map<Id,List<SFA2_Address_Delta_gne__c>>();
		}
		
		Set<Id> existingKeys = addrIds!=null ? deltaCache.keySet() : accountDeltaCache.keySet();
		Set<Id> newKeys = addrIds!=null ? addrIds.clone() : accIds.clone();
		newKeys.removeAll(existingKeys);
		
		if(addrIds!=null) {
			cacheAddresses(addrIds);
		} else {
			cacheAccounts(accIds);
		}
		
		if(!newKeys.isEmpty()) {
			for(Id newKey : newKeys) {
				if(addrIds!=null) {
					deltaCache.put(newKey, null);
				} else {
					accountDeltaCache.put(newKey, new List<SFA2_Address_Delta_gne__c>());
				}
			}
			
			List<SFA2_Address_Delta_gne__c> deltaRecs = addrIds!=null 
					? [SELECT Id, Type_gne__c, Address_gne__c, Account_gne__c,
						Account_Name_gne__c, Account_First_Name_gne__c, Account_Last_Name_gne__c, Account_Preferred_Name_gne__c,
						Address_Name_gne__c, Address_City_gne__c, Address_State_gne__c, Address_Zip_gne__c 
					   FROM SFA2_Address_Delta_gne__c WHERE Address_gne__c IN :newKeys]
					: [SELECT Id, Type_gne__c, Address_gne__c, Account_gne__c,
						Account_Name_gne__c, Account_First_Name_gne__c, Account_Last_Name_gne__c, Account_Preferred_Name_gne__c,
						Address_Name_gne__c, Address_City_gne__c, Address_State_gne__c, Address_Zip_gne__c
					   FROM SFA2_Address_Delta_gne__c WHERE Account_gne__c IN :newKeys];
					
			for(SFA2_Address_Delta_gne__c delta : deltaRecs) {
				cacheDelta(delta, accIds!=null);
			}
		}
		
		
	}
	
	private static void cacheDelta(SFA2_Address_Delta_gne__c delta) {
		cacheDelta(delta, false);
	}
	
	private static void cacheDelta(SFA2_Address_Delta_gne__c delta, Boolean cacheAccount) {
		if(deltaCache==null) {
			deltaCache = new Map<Id,SFA2_Address_Delta_gne__c>();
		}
		
		deltaCache.put(delta.Address_gne__c, delta);
		
		if(cacheAccount) {
			if(accountDeltaCache==null) {
				accountDeltaCache = new Map<Id, List<SFA2_Address_Delta_gne__c>>();
			}
			
			if(!accountDeltaCache.containsKey(delta.Account_gne__c)) {
				accountDeltaCache.put(delta.Account_gne__c, new List<SFA2_Address_Delta_gne__c>());
			}
			
			accountDeltaCache.get(delta.Account_gne__c).add(delta);
		}
	}
	
	private static void cacheAccounts(Set<Id> accIds) {
		if(accountCache==null) {
			accountCache = new Map<Id,Account>();
		}
		
		if(addressCache==null) {
			addressCache = new Map<Id,Address_vod__c>();
		}
		
		if(!accIds.isEmpty()) {
			for(Account acc : [
					SELECT Id, Name, FirstName, LastName, Preferred_Name_vod__c, RecordTypeId,
						(SELECT Id, Name, City_vod__c, State_vod__c, Zip_vod__c, RecordTypeId, MDM_Address_ID_gne__c, Account_Record_Type_Id_calc_gne__c,
							 Account_vod__r.Name, Account_vod__r.FirstName, Account_vod__r.LastName, Account_vod__r.Preferred_Name_vod__c,
							 Account_vod__r.RecordTypeId
						 FROM Address_vod__r)
					FROM Account
					WHERE Id IN :accIds]) {
				accountCache.put(acc.Id, acc);
				
				for(Address_vod__c addr : acc.Address_vod__r) {
					addressCache.put(addr.Id, addr);
				}			
			}
		}
	}
	
	private static void cacheAddresses(Set<Id> addrIds) {
		if(addressCache==null) {
			addressCache = new Map<Id,Address_vod__c>();
		}
		
		if(!addrIds.isEmpty()) {
			for(Address_vod__c addr : [
					SELECT Id, Name, City_vod__c, State_vod__c, Zip_vod__c, RecordTypeId, MDM_Address_ID_gne__c, Account_Record_Type_Id_calc_gne__c,
						Account_vod__r.Name, Account_vod__r.FirstName, Account_vod__r.LastName, Account_vod__r.Preferred_Name_vod__c,
						Account_vod__r.RecordTypeId
					FROM Address_vod__c
					WHERE Id IN :addrIds]) {
				addressCache.put(addr.Id, addr);			
			}
		}
	}
	
	private static List<SFA2_Address_Delta_gne__c> getDeltaRecordsForAccount(Id accId) {
		return accountDeltaCache!=null ? accountDeltaCache.get(accId) : new List<SFA2_Address_Delta_gne__c>();
	}
	
	private static SFA2_Address_Delta_gne__c getDeltaRecord(Id addrId) {
		return deltaCache!=null ? deltaCache.get(addrId) : null;
	}
	
	private static Account getAccount(Id accId) {
		return accountCache!=null ? accountCache.get(accId) : null;
	}
	
	private static Address_vod__c getAddress(Id addrId) {
		return addressCache!=null ? addressCache.get(addrId) : null;
	}
	
	public interface DeltaErrorHandler {
		void handleDeltaRecordErrors(SFA2_Address_Delta_gne__c deltaRec, SObject accOrAddr, Database.Error[] errors);
	}
	
}