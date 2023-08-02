@isTest
public class GNE_SFA2_PFG_TestHelper {

	private static final String US_HCP_RECORD_TYPE_NAME = 'Health Care Professional';
    private static final String US_HCO_RECORD_TYPE_NAME = 'Hospital';
    private static final String US_ADDRESS_RECORD_TYPE_NAME = 'Rep Maintained';

    private static final String ENCODING_KEY = 'UTF-8';
	private static final String LANGUAGE_LOCALE_KEY = 'en_US';
	private static final String TIMEZONE_SIDKEY = 'America/Los_Angeles';

	@TestVisible private static UserHelper userHelper;
	@TestVisible private static AccountHelper accountHelper;
	@TestVisible private static ConfigurationObjectHelper configurationObjectHelper;
	@TestVisible public static Map<String,Object> cache;
	@TestVisible private static Map<String, SFA2_PFG_Transaction_gne__c> allocTransfersCache;
    @TestVisible private static Integer soqlCount;
    @TestVisible private static Integer allocationYear;
    @TestVisible private static User currentUser;

    public static void init() {
    	prepareEnvWithTerrs('CS1');
    }

    public static void init(String userName) {
    	prepareEnvWithTerrs(userName);
    }

	private static void initCache() {
		if(cache==null) {
			cache = new Map<String,Object>();
		}
	}

	public static User prepareEnvWithTerrs(String userName) {
		User result = prepareEnv(userName);
		prepareTerritoriesForUsers();
		return result;
	}

	public static User prepareEnv(String userName) {
        soqlCount = 0;
        preparePfgSettings();
        prepareBrand2Salesforce();
        userHelper = new UserHelper();
        preparePfgProducts(userName);
        //prepareCustomSettings('GNE-SFA-PFG-Management');
        prepareLotCatalog(userName);
        prepareStorageLocations(new Set<String>{'CS1'});
        allocationYear = GNE_SFA2_PFG_Util.getYear();
        accountHelper = new AccountHelper();
        configurationObjectHelper = new ConfigurationObjectHelper();
        currentUser = userHelper.getUserFromCache(userName);
        return currentUser;
    }

    public static User prepareEnv(String profileNamePrefix, String triggerName, String email, String userName, String lastName, Boolean disable) {
		//prepareCustomSettings(profileNamePrefix);
        GNE_SFA2_Util.setTriggerDisabled(triggerName, disable);
        return createUser(profileNamePrefix, false, email, userName, lastName);
    }

    private static User createUser(String profileNamePrefix, Boolean runDbOperation, String email, String userName, String lastName) {
        for(Profile p : [ SELECT Id FROM Profile WHERE Name LIKE :profileNamePrefix ]) {
            User u2 = new User(Alias = 'testUser', Email=email,
                EmailEncodingKey=ENCODING_KEY, LastName=lastName, LanguageLocaleKey=LANGUAGE_LOCALE_KEY,
                LocaleSidKey=LANGUAGE_LOCALE_KEY, ProfileId = p.Id,
                TimeZoneSidKey=TIMEZONE_SIDKEY, UserName=(runDbOperation ? email : userName) + getUserTail(GlobalUtils.getEnvironment()));

            if(runDbOperation) {
                insert u2;
            }
            return u2;
        }
        return null;
    }

    public static Account createAccount() {
		Account acc = new Account();
		acc.RecordTypeId = [Select Id from RecordType where SobjectType = 'Account' AND Name= 'Professional_vod' limit 1].Id;
		acc.FirstName = 'Johnny';
		acc.LastName = 'Bravo';
		return acc;
	}

    private static String getUserTail(String environment) {
		String tail = '';
		if(environment != '' && environment != 'prod') {
			tail = '.' + environment;
		}
		return tail;
	}

    public static User getCurrentUser() {
    	return currentUser;
    }

    public static User getUser(String userName) {
    	return userHelper.getUserFromCache(userName);
    }

    public static Territory2 getTerritory(String userName) {
    	return ((Map<String,Territory2>)cache.get('territories')).get(userName);
    }

	/*public static void prepareCustomSettings(String profileNamePrefix) {
    	GNE_SFA2_Util.switchAdminMode(false);
        List<GNE_SFA2_ALL_Profiles_Prefix__c> prefixCustomSettingList = [SELECT Id, GNE_SFA2_ALL_Profiles_Prefix__c FROM GNE_SFA2_ALL_Profiles_Prefix__c];

        if(prefixCustomSettingList.isEmpty()) {
            GNE_SFA2_ALL_Profiles_Prefix__c prefixCustomSetting = new GNE_SFA2_ALL_Profiles_Prefix__c();
            prefixCustomSetting.GNE_SFA2_ALL_Profiles_Prefix__c = profileNamePrefix;
            insert prefixCustomSetting;
        } else {
            prefixCustomSettingList[0].GNE_SFA2_ALL_Profiles_Prefix__c = profileNamePrefix;
            update prefixCustomSettingList;
        }
    }*/

    public static SFA2_PFG_Product_Limit_gne__c createLimit(Product_vod__c product)
    {
    	SFA2_PFG_Product_Limit_gne__c prodLimit = new SFA2_PFG_Product_Limit_gne__c();
    	prodLimit.Product_gne__c = product.Id;
		prodLimit.Limit_Year_gne__c = String.valueOf(Date.today().year());
		prodLimit.Limit_Quantity_gne__c = 1000;
		return prodLimit;
    }

	public static Product_vod__c createPFGproduct(String distributionMethod)
	{
		Product_vod__c product = new Product_vod__c();
		product.Name = 'Test PFG Product X';
		product.NDC_Number_gne__c = '12345NDC';
		product.Product_Type_vod__c = 'PFG';
		product.UOM_gne__c = '12345UOM';
		//product.Distribution_Method_gne__c = distributionMethod;
		return product;
	}
	public static Call2_vod__c createCall(Account hcp)
	{
		Call2_vod__c call = new Call2_vod__c();
		call.Account_vod__c = hcp.Id;
		return call;
	}

	public static List<SFA2_PFG_Transaction_gne__c> insertTrxRecords(Integer numberOfRecords, String rtName, Boolean isDtp, String fromName, String toName) {
		List<SFA2_PFG_Transaction_gne__c> trxs = new List<SFA2_PFG_Transaction_gne__c>();
		Product_vod__c pfgProd;
		SFA2_Lot_Catalog_gne__c lot;
		User fromUser, toUser;
		Territory2 fromTerr, toTerr;

		if(isDtp) {
			Map<String,Product_vod__c> pfgProds = (Map<String,Product_vod__c>)cache.get('pfgProducts');
			pfgProd = pfgProds.get('DTP1');
			fromTerr = GNE_SFA2_PFG_TestHelper.getTerritory(fromName);
			toTerr = GNE_SFA2_PFG_TestHelper.getTerritory(toName);
		} else {
			List<SFA2_Lot_Catalog_gne__c> lots = ((Map<Id,SFA2_Lot_Catalog_gne__c>)cache.get('lotCatalogs')).values();
			lot = lots[0];
			pfgProd = new Product_vod__c(Id = lot.Product_gne__c);
			fromUser = GNE_SFA2_PFG_TestHelper.getUser(fromName);
			toUser = GNE_SFA2_PFG_TestHelper.getUser(toName);
		}

		for(Integer i=0; i<numberOfRecords; i++) {
			SFA2_PFG_Transaction_gne__c trx = new SFA2_PFG_Transaction_gne__c(
				RecordTypeId = GNE_SFA2_PFG_Util.getTransactionRecordTypeId(rtName),
				Product_gne__c = pfgProd.Id,
				Lot_No_gne__c = (lot!=null ? lot.Name : null),
				Requested_Quantity_gne__c = 1
			);

			if(isDtp) {
				trx.From_User_Territory_gne__c = fromTerr!=null ? fromTerr.Id : null;
				trx.From_Territory_Name_gne__c = fromTerr!=null ? fromTerr.Name : null;
				trx.To_User_Territory_gne__c = toTerr!=null ? toTerr.Id : null;
				trx.To_Territory_Name_gne__c = toTerr!=null ? toTerr.Name : null;
				trx.Distribution_Method_gne__c = GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP;
			} else {
				trx.From_User_gne__c = fromUser!=null ? fromUser.Id : null;
				trx.To_User_gne__c = toUser!=null ? toUser.Id : null;
				trx.Distribution_Method_gne__c = GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC;
			}

			if(accountHelper.accountsCache!=null && (rtName == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_DISBURSEMENT || rtName == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RFF)) {
        		Id hcpId = new List<Id>(accountHelper.accountsByTypeCache.get('US_HCP'))[0];
				trx.Account_gne__c = hcpId;
			} else if(cache.containsKey('vendor') && rtName == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RETURN) {
				Vendor_gne__c vendor = (Vendor_gne__c)cache.get('vendor');
				trx.Vendor_gne__c = vendor.Id;
			}

			if(isDtp && rtName == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RFF) {
				trx.From_User_gne__c = GNE_SFA2_PFG_TestHelper.getUser(fromName).Id;
			}

			trxs.add(trx);
		}

		insert trxs;
		return trxs;
	}

	public static List<SFA2_PFG_Inventory_Count_gne__c> insertInventoryCounts(Integer numberOfRecords, Set<String> csNames) {
		List<SFA2_PFG_Inventory_Count_gne__c> invs = new List<SFA2_PFG_Inventory_Count_gne__c>();
		List<SFA2_Lot_Catalog_gne__c> lots = ((Map<Id,SFA2_Lot_Catalog_gne__c>)GNE_SFA2_PFG_TestHelper.cache.get('lotCatalogs')).values();
		Map<String,SFA2_PFG_Storage_Location_gne__c> sLocs = (Map<String,SFA2_PFG_Storage_Location_gne__c>)cache.get('storageLocations');
		System.debug('SEG test');
		for(SFA2_Lot_Catalog_gne__c lot : lots) {
			for(String csName : csNames) {
				for(Integer i=0; i<numberOfRecords; i++) {
					System.debug('SEG check: '+sLocs.get(csName).Id);
					SFA2_PFG_Inventory_Count_gne__c inv = new SFA2_PFG_Inventory_Count_gne__c(
						Inventory_For_gne__c = getUser(csName).Id,
						PFG_Storage_Location_gne__c = sLocs.get(csName).Id,
						PFG_Storage_Location_gne__r = sLocs.get(csName),
						Product_gne__c = lot.Product_gne__c,
						Lot_gne__c = lot.Name,
						Count_gne__c = 100,
						Expiration_Date_gne__c = System.today().addDays(360),
						Submitted_Date_gne__c = System.today()
					);

					invs.add(inv);
				}
			}
		}
		GNE_SFA2_Admin_Mode__c adminModeSetting = GNE_SFA2_Admin_Mode__c.getInstance();
		adminModeSetting.GNE_SFA2_Is_Admin_Mode__c = true;
		upsert adminModeSetting;
		insert invs;
		adminModeSetting.GNE_SFA2_Is_Admin_Mode__c = false;
		update adminModeSetting;
		return invs;

	}

	public static List<PFG_Staging_Account_Limit_Exception_gne__c> insertAccQtyLimits() {
		List<PFG_Staging_Account_Limit_Exception_gne__c> aLimits = new List<PFG_Staging_Account_Limit_Exception_gne__c>();
		Set<Id> hcpIds = accountHelper.accountsByTypeCache.get('US_HCP');
		Map<String,Product_vod__c> pfgProds = (Map<String,Product_vod__c>)cache.get('pfgProducts');

		for(Id hcpId : hcpIds) {
			for(Product_vod__c pfgProd : pfgProds.values()) {
				PFG_Staging_Account_Limit_Exception_gne__c aLimit = new PFG_Staging_Account_Limit_Exception_gne__c(
					Account_gne__c = hcpId,
					Product_gne__c = pfgProd.Id,
					Limit_Year_gne__c = String.valueOf(GNE_SFA2_PFG_Util.getYear()),
					Exception_Quantity_gne__c = 100,
					Logical_Delete_Flag_gne__c = false
				);
				aLimits.add(aLimit);
			}
		}

		insert aLimits;
		return aLimits;
	}



	public static Call_PFG_Detail_gne__c createCallPFGdetail(Call2_vod__c call, Account hcp, Product_vod__c product, String Lot_No)
	{
		Call_PFG_Detail_gne__c callPFG = new Call_PFG_Detail_gne__c();
		callPFG.Account_gne__c = hcp.Id;
		callPFG.Call_gne__c = call.Id;
		callPFG.Date_gne__c = Date.today();
		callPFG.Lot_No_gne__c = Lot_No;
		callPFG.Product_gne__c = product.Id;
		callPFG.Quantity_gne__c = 100;
		return callPFG;
	}
	public static sObject createRecord(Map<sObject, Map<String, object>> sObjectConfig)
	{
		sObject newRecord = null;
		system.debug('sObjectConfig= '+sObjectConfig);
		for(sObject myObject : sObjectConfig.keySet())
		{
			Schema.SObjectType targetType = myObject.getSObjectType();
			newRecord = targetType.newSObject();
			for(String field : sObjectConfig.get(myObject).keySet())
			{
				object fieldValue = sObjectConfig.get(myObject).get(field);
				newRecord.put(field, fieldValue);
			}
		}
		system.debug('newRecord= '+newRecord);
		return newRecord;
	}
	public static SFA2_PFG_to_User_Detail_gne__c createPFGtoUserDetail(Product_vod__c product, User pfgUser)
	{
		SFA2_PFG_to_User_Detail_gne__c pfgToUserDetail = new SFA2_PFG_to_User_Detail_gne__c();
		pfgToUserDetail.Active_gne__c = true;
		//pfgToUserDetail.Distribution_Method_gne__c = product.Distribution_Method_gne__c;
		pfgToUserDetail.Product_gne__c = product.Id;
		pfgToUserDetail.User_gne__c = pfgUser.Id;
		return pfgToUserDetail;
	}
	public static SFA2_PFG_to_Account_Detail_gne__c createPFGtoAccountDetail(Account acc, Product_vod__c product)
	{
		SFA2_PFG_to_Account_Detail_gne__c pfgToAccountDetail = new SFA2_PFG_to_Account_Detail_gne__c();
		pfgToAccountDetail.Account_gne__c = acc.Id;
		pfgToAccountDetail.Product_gne__c = product.Id;
		pfgToAccountDetail.Limit_Year_gne__c = String.valueOf(Date.today().year());
		pfgToAccountDetail.Max_Quantity_gne__c = 1000;
		return pfgToAccountDetail;
	}
	public static String getRecordTypeId(String recordTypeName, String sObjectType)
	{
		RecordType recordType = Database.query('Select Id from RecordType where SobjectType = \''+sObjectType+'\'' + ' AND Name = \''+recordTypeName+'\'');
		String recordTypeId = recordType.Id;
		return recordTypeId;
	}

	public static void preparePfgSettings() {
		List<GNE_SFA2_PFG_Config_Items_gne__c> settings = new List<GNE_SFA2_PFG_Config_Items_gne__c>{
			new GNE_SFA2_PFG_Config_Items_gne__c(Name = 'ActiveBrandsForDTP', Value_gne__c = 'Nutropin;Actemra'),
			new GNE_SFA2_PFG_Config_Items_gne__c(Name = 'ActiveBrandsForHC', Value_gne__c = 'Nutropin;Actemra'),
			new GNE_SFA2_PFG_Config_Items_gne__c(Name = 'HoTerritoryName', Value_gne__c = 'Home Office Territory2 Name')
		};

		insert settings;
	}

	public static void prepareBrand2Salesforce() {
		List<Brand_2_Salesforce_gne__c> b2ss = new List<Brand_2_Salesforce_gne__c>{
			new Brand_2_Salesforce_gne__c(
				CDM_Brand_Code_gne__c = 'NUT',
				CDM_Salesforce_Code_gne__c = 'NUT',
				CDM_Salesforce_SubTeam_Code_gne__c = 'NUT',
				Salesforce_Name_gne__c = 'Nutropin',
				Salesforce_SubTeam_Name_gne__c = 'NUTROPIN',
				SFA_Brand_Name_gne__c = 'Nutropin'),
			new Brand_2_Salesforce_gne__c(
				CDM_Brand_Code_gne__c = 'ACT',
				CDM_Salesforce_Code_gne__c = 'RA',
				CDM_Salesforce_SubTeam_Code_gne__c = 'ACTRA',
				Salesforce_Name_gne__c = 'RHEUMATOID ARTHRITIS',
				Salesforce_SubTeam_Name_gne__c = 'ACTEMRA RA',
				SFA_Brand_Name_gne__c = 'Actemra'),
			new Brand_2_Salesforce_gne__c(
				CDM_Brand_Code_gne__c = 'ACT',
				CDM_Salesforce_Code_gne__c = 'RA',
				CDM_Salesforce_SubTeam_Code_gne__c = 'FRAN',
				Salesforce_Name_gne__c = 'RHEUMATOID ARTHRITIS',
				Salesforce_SubTeam_Name_gne__c = 'FRANCHISE',
				SFA_Brand_Name_gne__c = 'Actemra')
		};

		insert b2ss;
	}

	public static void prepareTerritoriesForUsers() {
		initCache();

		Map<String, User> users = userHelper.userCache;
		Map<String,Territory2> terrs = new Map<String,Territory2>();
		Set<String> salesforceCodes = new Set<String>{'NUT','RA'};

		Map<Id,String> userIdToKeyMap = new Map<Id,String>();

		for(String userKey : users.keySet()) {
			userIdToKeyMap.put(users.get(userKey).Id, userKey);
		}

		Map<Id,Set<Id>> terrToUserMap = new Map<Id,Set<Id>>();

		for(UserTerritory2Association ut :[SELECT UserId, Territory2Id FROM UserTerritory2Association WHERE UserId IN :userIdToKeyMap.keySet() AND IsActive = true]) {
			if(!terrToUserMap.containsKey(ut.Territory2Id)) {
				terrToUserMap.put(ut.Territory2Id,new Set<Id>());
			}

			terrToUserMap.get(ut.Territory2Id).add(ut.UserId);
		}

		Map<Id,Territory2> terrsMap = new Map<Id,Territory2>([SELECT Id, Name, Territory_Number_gne__c, External_Id_gne__c, ParentTerritory2Id,
				Is_Root_gne__c, Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c
			FROM Territory2
			WHERE Salesforce_Code_gne__c IN :salesforceCodes
				AND Id IN :terrToUserMap.keySet()]);

		for(Territory2 terr : terrsMap.values()) {
			if(terrToUserMap.containsKey(terr.Id)) {
				for(Id userId : terrToUserMap.get(terr.Id)) {
					String userKey = userIdToKeyMap.get(userId);
					terrs.put(userKey, terr);
				}
			}
		}

		terrs.put('HO1',new Territory2 (Name = GNE_SFA2_PFG_Util.getHoTerritoryId()));
		cache.put('territories', terrs);
	}

	public static void preparePfgProducts(String userName) {
		initCache();
		Id ownerId = userName!=null ? userHelper.userCache.get(userName).Id : null;

		List<Product_vod__c> brandsToInsert = new List<Product_vod__c>{
			new Product_vod__c(
				Name = 'Nutropin',
				Product_Type_vod__c = 'Brand',
				Company_Product_vod__c = true,
				OwnerId = ownerId),
			new Product_vod__c(
				Name = 'Actemra',
				Product_Type_vod__c = 'Brand',
				Company_Product_vod__c = true,
				OwnerId = ownerId)
		};

		insert brandsToInsert;

		cache.put('brands', brandsToInsert);

		Map<String,Product_vod__c> brandToPfgProd = new Map<String,Product_vod__c> {
			'HC1' => brandsToInsert[0],
			'DTP1' => brandsToInsert[0],
			'HC2' => brandsToInsert[0],
			'DTP2' => brandsToInsert[0],
			'HC3' => brandsToInsert[1],
			'DTP3' => brandsToInsert[1],
			'HC4' => brandsToInsert[1],
			'DTP4' => brandsToInsert[1]
		};

		List<Product_vod__c> pfgProdsToInsert = new List<Product_vod__c>();
		Map<String,Product_vod__c> products = new Map<String,Product_vod__c>();

		Integer i=1;
		String distMethod = GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC;
		for(String pfgProdName : brandToPfgProd.keySet()) {
			i++;
			Product_vod__c parentProd = brandToPfgProd.get(pfgProdName);
			Product_vod__c pfgProd = new Product_vod__c(
				Name = pfgProdName,
				OwnerId = ownerId,
				Product_Type_vod__c = 'PFG',
				NDC_Number_gne__c = '042-102-00' + i,
				UOM_gne__c = 'TEST',
				Company_Product_vod__c = true,
				Parent_Product_vod__c = parentProd.Id
			);
			pfgProdsToInsert.add(pfgProd);
			products.put(pfgProd.Name, pfgProd);
		}

		insert pfgProdsToInsert;

		List<SFA2_PFG_Product_Limit_gne__c> prodLimits = new List<SFA2_PFG_Product_Limit_gne__c>();

		for(Product_vod__c pfgProd : pfgProdsToInsert) {
			prodLimits.add(createLimit(pfgProd));
		}

		insert prodLimits;

		cache.put('pfgProducts',products);
	}

	public static Product_vod__c getPfgProduct(String prodName) {
		return ((Map<String,Product_vod__c>)cache.get('pfgProducts')).get(prodName);
	}

	public static void prepareLotCatalog(String userName) {
		initCache();

		String lotNo = 'TEST LOT';
		Id ownerId = userName!=null ? userHelper.userCache.get(userName).Id : null;

		Map<String,Product_vod__c> products = (Map<String,Product_vod__c>)GNE_SFA2_PFG_TestHelper.cache.get('pfgProducts');

		List<String> prodNames = new List<String>(products.keySet());
		prodNames.sort();

		Map<Id,SFA2_Lot_Catalog_gne__c> lotCatalogs = new Map<Id,SFA2_Lot_Catalog_gne__c>();

		Integer idx = 0;
		for(String prodName : prodNames) {
			if(prodName.startsWith('HC')) {
				Product_vod__c prod = products.get(prodName);
				SFA2_Lot_Catalog_gne__c lotC =
				new SFA2_Lot_Catalog_gne__c(
					Name=lotNo + '-' + (idx+1),
					Active_gne__c = true,
					Distribution_Method_gne__c = GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC,
					Expiration_Date_gne__c = (Date.today() + 356 + idx*10),
					Product_gne__c = prod.Id,
					U_M_gne__c = prod.UOM_gne__c);
				lotCatalogs.put(prod.Id,lotC);
				idx++;
			}
		}

		insert lotCatalogs.values();
		cache.put('lotCatalogs',lotCatalogs);
	}

	public static void prepareStorageLocations(Set<String> userNames) {
		initCache();
		List<SFA2_PFG_Storage_Location_gne__c> sls = new List<SFA2_PFG_Storage_Location_gne__c>();
		Map<String,User> users = userHelper.userCache;
		for(String key: users.keySet()){
			system.debug(key);
		}
		Map<String,SFA2_PFG_Storage_Location_gne__c> sLocs = new Map<String,SFA2_PFG_Storage_Location_gne__c>();
		for(String userName : userNames){
			system.debug(userName);
			SFA2_PFG_Storage_Location_gne__c sl = new SFA2_PFG_Storage_Location_gne__c(
				User_gne__c = users.get(userName).Id,
				Manager_gne__c = users.get(userName).ManagerId,
				Status_gne__c = GNE_SFA2_PFG_Util.STORAGE_LOCATION_STATUS_APPROVED,
				State_gne__c = 'NY',
				City_gne__c = 'TEST',
				Address_Line_1_gne__c = 'TEST',
				Zip_gne__c = '99999',
				Phone_gne__c = '(999) 999-9999'
			);

			sls.add(sl);
			sLocs.put(userName, sl);
		}
		GNE_SFA2_PFG_SL_Trigger_Helper.setSLTrig(true);
		insert sls;
		GNE_SFA2_PFG_SL_Trigger_Helper.setSLTrig(false);
		cache.put('storageLocations', sLocs);
	}

	public static void insertPfgToUserDetails() {
		Map<Id,SFA2_Lot_Catalog_gne__c> lotCatalogs = (Map<Id,SFA2_Lot_Catalog_gne__c>)cache.get('lotCatalogs');
		List<SFA2_PFG_to_User_Detail_gne__c> userDetailsToInsert = new List<SFA2_PFG_to_User_Detail_gne__c>();

		for(String userName : userHelper.userCache.keySet()) {
			if(userName.startsWith('CS')) {
				for(SFA2_Lot_Catalog_gne__c lotCatalog : lotCatalogs.values()) {
					SFA2_PFG_to_User_Detail_gne__c uDetail = new SFA2_PFG_to_User_Detail_gne__c(
						Active_gne__c = true,
            			User_gne__c = userHelper.userCache.get(userName).Id,
            			Distribution_Method_gne__c = GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC,
            			Product_gne__c = lotCatalog.Product_gne__c,
            			Lot_NO_gne__c = lotCatalog.Name,
            			UOM_gne__c = lotCatalog.U_M_gne__c,
            			Expiration_Date_gne__c = lotCatalog.Expiration_Date_gne__c,
            			Qty_Total_Allocated_gne__c = 100,
            			YTD_Allocated_gne__c = 100
					);
					userDetailsToInsert.add(uDetail);
				}
			}
		}

		insert userDetailsToInsert;
	}

	public static void insertPfgToTerritoryDetails() {
		List<SFA2_PFG_to_Territory_Detail_gne__c> terrDetailsToInsert = new List<SFA2_PFG_to_Territory_Detail_gne__c>();
		Map<String,Product_vod__c> products = (Map<String,Product_vod__c>)GNE_SFA2_PFG_TestHelper.cache.get('pfgProducts');
		Map<String,Territory2> terrs = (Map<String,Territory2>)cache.get('territories');
		for(String userName : terrs.keySet()) {
			if(userName.startsWith('CS')) {
				for(String prodName : products.keySet()) {
					if(prodName.startsWith('DTP')) {
						Territory2 terr = terrs.get(userName);
						Product_vod__c pfgProd = products.get(prodName);
						SFA2_PFG_to_Territory_Detail_gne__c tDetail = new SFA2_PFG_to_Territory_Detail_gne__c(
							Active_gne__c = true,
							Distribution_Method_gne__c = GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP,
							Lot_NO_gne__c = GNE_SFA2_PFG_Util.LOT_NO_NA_VALUE,
	            			Product_gne__c = pfgProd.Id,
	            			Year_gne__c = GNE_SFA2_PFG_Util.getYear(),
	            			Qty_Total_Allocated_gne__c = 100,
	            			YTD_Allocated_gne__c = 100,
	            			Territory_gne__c = terr.Id,
	            			Territory_Name_gne__c = terr.Name,
	            			Territory_Number_gne__c = terr.Territory_Number_gne__c,
	            			UOM_gne__c = pfgProd.UOM_gne__c
						);
						terrDetailsToInsert.add(tDetail);
					}
				}
			}
		}

		insert terrDetailsToInsert;
	}

	public static Vendor_gne__c insertVendor() {
		Vendor_gne__c vendor = new Vendor_gne__c (
			Name = 'Knipper',
			Active_Flag_gne__c = true,
			Address_Line_1_gne__c = 'One Healthcare Way',
			City_gne__c = 'Lakewood',
			State_gne__c = 'NJ',
			Vendor_Name_gne__c = 'Knipper',
			Zip_gne__c = '08701'
		);
		insert vendor;

		cache.put('vendor', vendor);

		List<Product_vod__c> brands = (List<Product_vod__c>)cache.get('brands');
		List<BrandVendor_gne__c> brandVendors = new List<BrandVendor_gne__c>();

		for(Product_vod__c brand : brands) {
			BrandVendor_gne__c bv = new BrandVendor_gne__c(
				Accountability_Vendor_Flag_gne__c = true,
				Active_Flag_gne__c = true,
				Backup_Shipper_Flag_gne__c = true,
				Brand_gne__c = brand.Id,
				Primary_Shipper_Flag_gne__c = true,
				Program_gne__c = 'PFG',
				Vendor_Name_gne__c = vendor.Id
			);
			brandVendors.add(bv);
		}

		insert brandVendors;
		return vendor;
	}

	public static void insertAllocationTransfers(String pfgType) {
        insertAllocationTransfers(pfgType, new Set<String>{pfgType + '1'});
    }

    public static void insertAllocationTransfers(String pfgType, Set<String> prodNames) {
        insertAllocationTransfers(pfgType, prodNames, new Map<String,Integer>{
            'null:HO1' => 500,
            'HO1:DM1' => 200,
            'DM1:CS1' => 100
//            'DM1:CS2' => 50
        });
    }

    public static void insertAllocationTransfers(String pfgType, Set<String> prodNames, Map<String,Integer> transactionData) {
        GNE_SFA2_PFG_Util.clearPfgToUserCache();
        allocTransfersCache = new Map<String, SFA2_PFG_Transaction_gne__c>();
        List<SFA2_PFG_Transaction_gne__c> trnListAll = new List<SFA2_PFG_Transaction_gne__c>();
        Date trxDate = allocationYear!=GNE_SFA2_PFG_Util.getYear() ? Date.newInstance(allocationYear,1,1) : null;

        for(String prodName : prodNames) {
        	List<SFA2_PFG_Transaction_gne__c> trnList = new List<SFA2_PFG_Transaction_gne__c>();

			if(pfgType=='DTP') {
				Map<String, Territory2> terrs = (Map<String, Territory2>)cache.get('territories');
				for(String key : transactionData.keySet()) {
					String[] terrData = key.split(':');
					Territory2 fromTerr =  terrData[0]!='null' ? terrs.get(terrData[0]) : null;
					Territory2 toTerr =  terrs.get(terrData[1]);

					SFA2_PFG_Transaction_gne__c trx = new SFA2_PFG_Transaction_gne__c(
						Requested_Quantity_gne__c = transactionData.get(key),
						Transaction_Date_gne__c = trxDate);

					if(fromTerr!=null) {
						trx.From_Territory_Name_gne__c = fromTerr.Name;
						trx.From_User_Territory_gne__c = fromTerr.Id!=null ? (String)fromTerr.Id : fromTerr.Name;
					}

					trx.To_Territory_Name_gne__c = toTerr.Name;
					trx.To_User_Territory_gne__c = toTerr.Id!=null ? (String)toTerr.Id : toTerr.Name;

					if(allocationYear!=GNE_SFA2_PFG_Util.getYear()) {

					}

					trnList.add(trx);

					allocTransfersCache.put(key + ':' + prodName, trx );
				}
			} else {
		        Map<String, User> users = userHelper.userCache;
		        for(String key : transactionData.keySet()) {
		            String[] userData = key.split(':');
		            Id fromUId = userData[0]!='null' ? users.get(userData[0]).Id : null;
		            Id toUId = users.get(userData[1]).Id;
		            SFA2_PFG_Transaction_gne__c trx = new SFA2_PFG_Transaction_gne__c(
		            	From_User_gne__c=fromUId, To_User_gne__c=toUId,
		                Requested_Quantity_gne__c = transactionData.get(key));
		            trnList.add(trx);

		            allocTransfersCache.put(key + ':' + prodName, trx );
		        }
			}

	        Product_vod__c currentProduct = ((Map<String,Product_vod__c>)cache.get('pfgProducts')).get(prodName);

	        Map<String, Schema.RecordTypeInfo> rtInfos = SFA2_PFG_Transaction_gne__c.getSobjectType().getDescribe().getRecordTypeInfosByName();
	        Id allocRecTypeId = rtInfos.get(GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION).getRecordTypeId();
	        Id allocTransferRecTypeId = rtInfos.get(GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION_TRANSFER).getRecordTypeId();

	        for(SFA2_PFG_Transaction_gne__c trn : trnList) {
	            trn.Product_gne__c = currentProduct.Id;
	            trn.Distribution_Method_gne__c = (pfgType=='DTP'
	            		? GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP
	            		: GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC);
				trn.RecordTypeId = ((trn.From_User_gne__c==null && trn.From_Territory_Name_gne__c==null) ? allocRecTypeId : allocTransferRecTypeId);
	        }

	        trnListAll.addAll(trnList);
        }

        Integer beforeCount = Limits.getQueries();
        GNE_SFA2_PFG_Util.saveTransaction(trnListAll, null, pfgType=='HC');
        soqlCount += Limits.getQueries() - beforeCount;
    }

    public static void clearPFGCache() {
    	iPhoneApex_PFG_Util.proposedCallPfgDetailMap = null;
		GNE_SFA2_PFG_Util.callDetailsCache = null;
		GNE_SFA2_PFG_Util.callDetailTransactionsCache = null;
		GNE_SFA2_PFG_Util.pfgToAccountDetailsCache = null;
		GNE_SFA2_PFG_Util.pfgToTerritoryDetailsCache = null;
    }

    public class UserHelper {
		@TestVisible private Map<String,User> userCache;
		@TestVisible private Map<Id,Id> userToTerritoryIdCache;

		public UserHelper() {
			userCache = new Map<String,User>();
			userToTerritoryIdCache = new Map<Id,Id>();
			Set<Id> pfgUsersInTerrs = new Set<Id>();

			for(UserTerritory2Association ut : [SELECT UserId FROM UserTerritory2Association WHERE UserId IN (SELECT Id FROM User WHERE Profile.Name like 'GNE-SFA-Actemra-%' OR Profile.Name like 'GNE-SFA-Rituxan-RA-%')]) {
				pfgUsersInTerrs.add(ut.UserId);
			}

			List<User> hoUsers = [SELECT Id, Name, FirstName, LastName, External_Id_gne__c, Profile.Name
					FROM User WHERE IsActive = true AND Profile.Name = 'GNE-SFA-PFG-Management' ORDER BY Name LIMIT 1];

			userCache.put('HO1', hoUsers[0]);

			List<User> csUsers = [SELECT Id, Name, FirstName, LastName, External_Id_gne__c, Profile.Name
									FROM User WHERE IsActive = true AND Profile.Name IN ('GNE-SFA-Actemra-CS', 'GNE-SFA-Rituxan-RA-CS')
										AND Id IN :pfgUsersInTerrs
									ORDER BY Name
									LIMIT 2
								];
			List<User> dmUsers = [SELECT Id, Name, FirstName, LastName, External_Id_gne__c, Profile.Name
				FROM User WHERE IsActive = true AND Profile.Name IN ('GNE-SFA-Actemra-DM', 'GNE-SFA-Rituxan-RA-DM')
					AND Id IN :pfgUsersInTerrs
				ORDER BY Name
				LIMIT 2
			];

			Integer dmCounter = 1, csCounter = 1;
			for(User dmUser : dmUsers) {
				userCache.put('DM' + dmCounter++, dmUser);
			}

			for(User csUser : csUsers) {
				csUser.ManagerId = userCache.get('DM'+csCounter).Id;
				userCache.put('CS' + csCounter++, csUser);
			}
			update csUsers;

			Integer rmCounter = 1;
			for(User rmUser : [SELECT Id, Name, FirstName, LastName, External_Id_gne__c, Profile.Name
					FROM User WHERE IsActive = true
						AND Profile.Name IN ('GNE-SFA-Actemra-Manager', 'GNE-SFA-Rituxan-RA-Manager')
						AND Id IN :pfgUsersInTerrs
					ORDER BY Name]) {
				userCache.put('RM' + rmCounter++, rmUser);
			}

			for(User esbUser : [SELECT Id, Name, FirstName, LastName, External_Id_gne__c, Profile.Name
					FROM User WHERE IsActive = true
						AND Profile.Name IN ('Super-SYS-AutomatedJob')
					ORDER BY Name
					LIMIT 1]) {
				userCache.put('ESB1', esbUser);
				userCache.put('usOwner', esbUser);
			}

			for(UserTerritory2Association ut : [SELECT UserId, Territory2Id FROM UserTerritory2Association WHERE UserId IN :userCache.values()]) {
            	userToTerritoryIdCache.put(ut.UserId, ut.Territory2Id);
            }

            Map<String,IC_Calc_Sales_Roster_gne__c> rosterMap = insertSalesRosters();
            insertUserSalesRostersAndAppContext(rosterMap);
            insertUserPreferences();
        }

        public User getUserFromCache() {
        	return getUserFromCache('CS1');
        }

        public User getUserFromCache(String role) {
        	return userCache.get(role);
        }

        public Set<Id> getUserIds() {
        	Set<Id> ids = new Set<Id>();

        	for(User u : userCache.values()) {
        		ids.add(u.Id);
        	}

        	return ids;
        }

        public Map<String,IC_Calc_Sales_Roster_gne__c> insertSalesRosters() {
			Map<String,IC_Calc_Sales_Roster_gne__c> rosterMap = new Map<String,IC_Calc_Sales_Roster_gne__c>();

			for(String brandName : new Set<String>{null, 'Actemra', 'Rituxan-RA'}) {
				rosterMap.put(brandName, new IC_Calc_Sales_Roster_gne__c(Brand_Name_gne__c = brandName, Salesforce_gne__c = brandName, Type_gne__c = 'SFA-US'));
			}

			insert rosterMap.values();
			return rosterMap;
		}

        private void insertUserSalesRostersAndAppContext(Map<String, IC_Calc_Sales_Roster_gne__c> rosterMap) {
        	List<SFA2_User_Sales_Roster_gne__c> uSRstoInsert = new List<SFA2_User_Sales_Roster_gne__c>();
        	List<GNE_SFA2_User_App_Context_gne__c> appContextsToInsert = new List<GNE_SFA2_User_App_Context_gne__c>();
        	Pattern brandRolePattern = Pattern.compile('GNE-SFA-(.{0}|.*[^-])-{0,1}(CS|DM|Manager|PFG-Management)');

        	for(String userName : userCache.keySet()) {
        		User u = userCache.get(userName);
        		Matcher m = brandRolePattern.matcher(u.Profile.Name);

				if(m.matches()) {
					String brandName = m.group(1);
					String role = m.group(2);
					IC_Calc_Sales_Roster_gne__c roster = rosterMap.get(String.isNotBlank(brandName) ? brandName : null);

					SFA2_User_Sales_Roster_gne__c uSR = new SFA2_User_Sales_Roster_gne__c(
						Sales_Roster_gne__c = roster.Id,
						Role_gne__c = role,
						User_gne__c = u.Id
					);
					uSRstoInsert.add(uSR);

					GNE_SFA2_User_App_Context_gne__c appContext = new GNE_SFA2_User_App_Context_gne__c(
						SetupOwnerId = u.Id,
						App_Name_gne__c = 'SFA-US',
						Brand_gne__c = brandName,
						Role_gne__c = role,
						Run_in_SFA2_UI_gne__c = true,
						SFA2_Mode_gne__c = true
					);

					appContextsToInsert.add(appContext);
				}
			}

			insert uSRstoInsert;
			insert appContextsToInsert;
        }

        private void insertUserPreferences() {
        	List<SFA2_User_Preferences_gne__c> prefs = new List<SFA2_User_Preferences_gne__c>();

        	for(User u : userCache.values()) {
        		prefs.add(new SFA2_User_Preferences_gne__c(User_gne__c = u.Id));
        	}

        	insert prefs;
        }
	}

	public class AccountHelper {
        private final String US_CODE = 'US';

        public Map<Id,Account> accountsCache;
        public Map<String,Set<Id>> accountsByTypeCache;
        public Map<Id,Address_vod__c> addressCache;

        private Map<String,Id> accRecTypesCache;
    	private Map<String,Id> addrRecTypesCache;


        public void insertAccountsWithAddresses(Integer numberOfAccts) {
        	cacheRecordTypes();
            GNE_SFA2_Account_Trigger_Helper.setAccountTrig(true);
            GNE_SFA2_Address_Trigger_Helper.setAddressTrig(true);

            List<Account> accountsToInsert = new List<Account>();
            List<Address_vod__c> addressesToInsert = new List<Address_vod__c>();

            String hcpFirstName = 'JOHN', hcpLastName = 'SMITH', hcoName = 'MEDICAL CENTER';
            String addressName = 'TEST STREET', addressLine2 = 'STE', city = 'SAN FRANCISCO', state = 'CA', zip = '99999', zip4 = '1111';

            Integer idx = 0;
            for(String mode : new String[]{'US_HCP','US_HCO'}) {
                Id recTypeId = accRecTypesCache.get(mode);

                for(Integer i = 0; i < numberOfAccts; i++) {
                    idx++;
                    Account acc = new Account(
                        RecordTypeId = recTypeId,
                        OwnerId = getUser('usOwner').Id);

                    if(mode.endsWith('HCP')) {
                        acc.FirstName = hcpFirstName + idx;
                        acc.LastName = hcpLastName + idx;
                    } else {
                        acc.Name = hcoName;
                    }

                    accountsToInsert.add(acc);
                }
            }

            insert accountsToInsert;

            idx = 0;
            for(Account acc : accountsToInsert) {
                idx++;
                Id recTypeId = addrRecTypesCache.get(getAccountType(acc));

                Address_vod__c addr = new Address_vod__c(
                    RecordTypeId = recTypeId,
                    Account_vod__c = acc.Id,
                    Name = addressName + ' ' + idx,
                    Address_Line_2_vod__c = addressLine2 + ' ' + idx,
                    Primary_vod__c = true,
                    City_vod__c = city,
                    State_vod__c = state,
                    Zip_vod__c = zip,
                    Zip_4_vod__c = zip4);
                addressesToInsert.add(addr);
            }

            insert addressesToInsert;

            cacheAccounts(new Map<Id,Account>(accountsToInsert).keySet());

            GNE_SFA2_Account_Trigger_Helper.setAccountTrig(false);
            GNE_SFA2_Address_Trigger_Helper.setAddressTrig(false);
        }

        public void cacheAccounts(Set<Id> accIds) {
            List<Account> accs = [
                SELECT Id, Name, OwnerId, FirstName, LastName, IsPersonAccount, RecordTypeId, RecordType.Name,
                    (SELECT Id, Primary_vod__c, Account_vod__c, Name, Address_Line_2_vod__c, City_vod__c, State_vod__c, Zip_vod__c, Zip_4_vod__c, Province_can_gne__c, Postal_Code_can_gne__c
                     FROM Address_vod__r)
                FROM Account
                WHERE Id IN :accIds
            ];

            for(Account acc : accs) {
                cacheAccount(acc);

                for(Address_vod__c addr : acc.Address_vod__r) {
                    cacheAddress(addr);
                }
            }
        }

        public void cacheAccount(Account acc) {
            if(accountsCache==null) {
                accountsCache = new Map<Id,Account>();
                accountsByTypeCache = new Map<String,Set<Id>>{
                    'US_HCP' => new Set<Id>(),
                    'US_HCO' => new Set<Id>()
                };
            }

            accountsCache.put(acc.Id, acc);
            String accType = getAccountType(acc);
            accountsByTypeCache.get(accType).add(acc.Id);
        }

        public void cacheAddress(Address_vod__c addr) {
            if(addressCache==null) {
                addressCache = new Map<Id,Address_vod__c>();
            }

            addressCache.put(addr.Id, addr);
        }

        private void cacheRecordTypes() {
	        accRecTypesCache = new Map<String,Id>();
	        List<Schema.RecordTypeInfo> rtInfos = Account.getSobjectType().getDescribe().getRecordTypeInfos();

	        for(Schema.RecordTypeInfo rtInfo : rtInfos) {
	            Id rtId = rtInfo.getRecordTypeId();
	            String rtName = rtInfo.getName();
	            if(rtName == US_HCP_RECORD_TYPE_NAME) {
	                accRecTypesCache.put('US_HCP', rtId);
	            } else if(rtName == US_HCO_RECORD_TYPE_NAME) {
	                accRecTypesCache.put('US_HCO', rtId);
	            }
	        }

	        addrRecTypesCache = new Map<String,Id>();
	        rtInfos = Address_vod__c.getSobjectType().getDescribe().getRecordTypeInfos();

	        for(Schema.RecordTypeInfo rtInfo : rtInfos) {
	            Id rtId = rtInfo.getRecordTypeId();
	            String rtName = rtInfo.getName();
	            if(rtName == US_ADDRESS_RECORD_TYPE_NAME) {
	                addrRecTypesCache.put('US_HCP', rtId);
	                addrRecTypesCache.put('US_HCO', rtId);
	            }
	        }
	    }

        private String getAccountType(Account acc) {
            String region = US_CODE;
            String accMode = acc.RecordTypeId == accRecTypesCache.get(region + '_HCP') ? 'HCP' : 'HCO';
            return region + '_' + accMode;
        }

        private void createAccountShares(User u) {
        	Id terrId = userHelper.userToTerritoryIdCache.get(u.Id);
        	List<ObjectTerritory2Association> territoryAssociations = new List<ObjectTerritory2Association>();
        	
            for(Account acc : accountsCache.values()) {
            	ObjectTerritory2Association territoryAssociation = new ObjectTerritory2Association(ObjectId = acc.Id, Territory2Id = terrId, AssociationCause='Territory2Manual');
    			territoryAssociations.add(territoryAssociation);
    		}

        	insert territoryAssociations;
        }
    }

    public class ConfigurationObjectHelper {
    	private Set<String> roleBrandSet = new Set<String>{
    		'PFG-Management;',
			'CS;Actemra',
			'DM;Actemra',
			'Manager;Actemra',
			'CS;Rituxan-RA',
			'DM;Rituxan-RA',
			'Manager;Rituxan-RA'
		};

		private Set<String> brandNames = new Set<String>();
		private Set<String> roleNames = new Set<String>();

		public ConfigurationObjectHelper() {
			for(String roleBrandName : roleBrandSet) {
				String[] roleBrandList = roleBrandName.split(';',2);
				String roleName = roleBrandList[0];
				String brandName = roleBrandList[1];
				brandNames.add(brandName);
				roleNames.add(roleName);
			}
		}

		public void insertCosForRecordTypeNames(Set<String> rtNames) {
			for(String rtName : rtNames) {
				if(rtName == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION_TRANSFER) {
					insertTrxAllocationTransfer();
				} else if(rtName == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RFF) {
					insertTrxRff();
				} else if(rtName == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_TRANSFER) {
					insertTrxTransfer();
				} else if(rtName == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ADJUSTMENT) {
					insertTrxAdjustment();
				} else if(rtName == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_DISBURSEMENT) {
					insertTrxDisbursement();
				} else if(rtName == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ORDER) {
					insertTrxOrder();
				} else if(rtName == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RETURN) {
					insertTrxReturn();
				}
			}
		}

    	public void insertTrxAllocationTransfer() {
    		String coName = 'AllocationTransferDetail';
    		String objName = 'SFA2_PFG_Transaction_gne__c';
    		String rtName = 'Allocation_Transfer';

			Map<String,List<SFA2_Configuration_Object_Detail_gne__c>> codsMap = new Map<String,List<SFA2_Configuration_Object_Detail_gne__c>>{
				'Information|New' =>
					new List<SFA2_Configuration_Object_Detail_gne__c>{
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'From_User_Territory_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=true, Label_gne__c='Transferred From'),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Transaction_Date_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=true, Label_gne__c='Transferred Date')
					},
				'Information|View' =>
					new List<SFA2_Configuration_Object_Detail_gne__c>{
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Name', Type_gne__c = 'Field', Is_Required_gne__c=false, Label_gne__c='Transaction ID'),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Transaction_Date_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false, Label_gne__c='Transferred Date'),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Allocated_from_Calc_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false, Label_gne__c='Transferred From')
					},
				'Transfer To Information|New' =>
					new List<SFA2_Configuration_Object_Detail_gne__c>{
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'To_User_Territory_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=true, Label_gne__c='Transfer To')
					},
				'Transfer To Information|View' =>
					new List<SFA2_Configuration_Object_Detail_gne__c>{
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Allocated_to_Calc_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=true, Label_gne__c='Transfer To')
					}
				};

			insertCos(coName, objName, new Set<String>{rtName}, codsMap);
    	}

    	public void insertTrxRff() {
    		String coName = 'RffDetail';
    		String objName = 'SFA2_PFG_Transaction_gne__c';
    		String rtName = 'Request_for_Fulfillment';

    		Map<String,List<SFA2_Configuration_Object_Detail_gne__c>> codsMap = new Map<String,List<SFA2_Configuration_Object_Detail_gne__c>> {
				'View Order Details|View' =>
					new List<SFA2_Configuration_Object_Detail_gne__c>{
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Transaction_Ref_Number_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false, Is_Read_Only_gne__c = true, Label_gne__c='Order ID',Order_gne__c=1),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Shipment_Id_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false, Is_Read_Only_gne__c = true, Label_gne__c='Shipment ID',Order_gne__c=2),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Call_Name_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false, Is_Read_Only_gne__c = true, Label_gne__c='Interaction ID',Order_gne__c=3),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Delivery_Status_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false, Is_Read_Only_gne__c = true, Label_gne__c='Order Status',Order_gne__c=4),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Distribution_Method_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false, Is_Read_Only_gne__c = true, Label_gne__c='Order Type',Order_gne__c=5),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Shipment_Status_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false, Is_Read_Only_gne__c = true, Label_gne__c='Shipment Status',Order_gne__c=6),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Created_By_Info_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false, Is_Read_Only_gne__c = true, Label_gne__c='Created By',Order_gne__c=7),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Ship_to_Name_Calc_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false, Is_Read_Only_gne__c = true, Label_gne__c='Ship to Name',Order_gne__c=8),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Last_Modified_By_Info_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false, Is_Read_Only_gne__c = true, Label_gne__c='Last Modified By',Order_gne__c=9),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Location_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false, Is_Read_Only_gne__c = true, Label_gne__c='Ship To Address',Order_gne__c=10)
					}
			};

    		insertCos(coName, objName, new Set<String>{rtName}, codsMap);
    	}

    	public void insertTrxTransfer() {
    		String coName = 'TransferDetail';
    		String objName = 'SFA2_PFG_Transaction_gne__c';
    		String rtName = 'Transfer';

    		Map<String,List<SFA2_Configuration_Object_Detail_gne__c>> codsMap = new Map<String,List<SFA2_Configuration_Object_Detail_gne__c>>{
				'Information|New' =>
					new List<SFA2_Configuration_Object_Detail_gne__c>{
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'From_User_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=true, Is_Read_Only_gne__c = false, Label_gne__c='Transferred from', Order_gne__c=1),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Transaction_Date_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=true, Is_Read_Only_gne__c = false, Label_gne__c='Transferred Date', Order_gne__c=2)
					},
				'Information|View' =>
					new List<SFA2_Configuration_Object_Detail_gne__c>{
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Transaction_Ref_Number_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false, Is_Read_Only_gne__c = true, Label_gne__c='Transaction ID',Order_gne__c=1),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Transaction_Date_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false, Is_Read_Only_gne__c = true, Label_gne__c='Transferred Date', Order_gne__c=2),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'From_User_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false, Is_Read_Only_gne__c = true, Label_gne__c='Transferred from', Order_gne__c=3),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Receipt_Date_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false, Is_Read_Only_gne__c = true, Label_gne__c='Transferred Received Date', Order_gne__c=4)

					},
				'Transfer to Information|New' =>
					new List<SFA2_Configuration_Object_Detail_gne__c>{
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'To_User_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=true, Label_gne__c='Transfer To',Order_gne__c=1),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'City_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=true, Label_gne__c='City', Order_gne__c=2),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Address_Line_1_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=true,Label_gne__c='Address Line 1', Order_gne__c=3),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'State_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=true, Label_gne__c='State', Order_gne__c=4),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Address_Line_2_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false, Label_gne__c='Address Line 2', Order_gne__c=5),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Zip_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=true, Label_gne__c='Zip', Order_gne__c=6)
					},
				'Transfer to Information|View' =>
					new List<SFA2_Configuration_Object_Detail_gne__c>{
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'To_User_gne__c', Type_gne__c = 'Field', Is_Read_Only_gne__c=true, Label_gne__c='Transfer To',Order_gne__c=1),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'City_gne__c', Type_gne__c = 'Field', Is_Read_Only_gne__c=true, Label_gne__c='City', Order_gne__c=2),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Address_Line_1_gne__c', Type_gne__c = 'Field', Is_Read_Only_gne__c=true,Label_gne__c='Address Line 1', Order_gne__c=3),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'State_gne__c', Type_gne__c = 'Field', Is_Read_Only_gne__c=true, Label_gne__c='State', Order_gne__c=4),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Address_Line_2_gne__c', Type_gne__c = 'Field', Is_Read_Only_gne__c=true, Label_gne__c='Address Line 2', Order_gne__c=5),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Zip_gne__c', Type_gne__c = 'Field', Is_Read_Only_gne__c=true, Label_gne__c='Zip', Order_gne__c=6)
					}
			};

    		insertCos(coName, objName, new Set<String>{rtName}, codsMap);
    	}

    	public void insertTrxAdjustment() {
    		String coName = 'TransactionDetail';
    		String objName = 'SFA2_PFG_Transaction_gne__c';
    		String rtName = 'Adjustment';

    		Map<String,List<SFA2_Configuration_Object_Detail_gne__c>> codsMap = new Map<String,List<SFA2_Configuration_Object_Detail_gne__c>>{
				'Information|View' =>
					new List<SFA2_Configuration_Object_Detail_gne__c>{
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Name', Type_gne__c = 'Field', Is_Required_gne__c=false, Is_Read_Only_gne__c = true, Label_gne__c='Transaction ID',Order_gne__c=1),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Call_Name_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false, Label_gne__c='Interaction ID',Order_gne__c=2),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Adjust_For_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=true, Label_gne__c='Adjust For',Order_gne__c=3),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Submitted_Date_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=true, Label_gne__c='Submitted Date',Order_gne__c=4),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Transaction_Date_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=true, Label_gne__c='Adjusted Date',Order_gne__c=5),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Transaction_Reason_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=true, Label_gne__c='Reason',Order_gne__c=6)
					},
				'Information|New' =>
					new List<SFA2_Configuration_Object_Detail_gne__c>{
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'From_User_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=true, Label_gne__c='User ID',Order_gne__c=1),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Transaction_Date_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=true, Label_gne__c='Adjusted Date',Order_gne__c=2),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Call_PFG_Detail_ID_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false, Is_Read_Only_gne__c = false, Label_gne__c='Interaction ID',Order_gne__c=3),

						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Transaction_Reason_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=true,  Is_Read_Only_gne__c = false, Label_gne__c='Reason',Order_gne__c=4)
					}
			};

    		insertCos(coName, objName, new Set<String>{rtName}, codsMap);
    	}

    	public void insertTrxDisbursement() {
    		String coName = 'DisbursementDetail';
    		String objName = 'SFA2_PFG_Transaction_gne__c';
    		String rtName = 'Disbursement';

    		Map<String,List<SFA2_Configuration_Object_Detail_gne__c>> codsMap = new Map<String,List<SFA2_Configuration_Object_Detail_gne__c>> {
				'Information|View' =>
					new List<SFA2_Configuration_Object_Detail_gne__c>{
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Transaction_Ref_Number_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false, Is_Read_Only_gne__c = true, Label_gne__c='Transaction ID',Order_gne__c=1),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Signature_Date_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false, Is_Read_Only_gne__c = true, Label_gne__c='Signature Date',Order_gne__c=2),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Call_Name_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false, Is_Read_Only_gne__c = true, Label_gne__c='Interaction ID',Order_gne__c=3),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Submitted_Date_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false, Is_Read_Only_gne__c = true, Label_gne__c='Submitted Date',Order_gne__c=4),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Created_By_Info_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false, Is_Read_Only_gne__c = true, Label_gne__c='Created By',Order_gne__c=5),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Disbursed_to_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false, Is_Read_Only_gne__c = true, Label_gne__c='Disbursed To',Order_gne__c=6)
					}
			};

    		insertCos(coName, objName, new Set<String>{rtName}, codsMap);
    	}

    	public void insertTrxOrder() {
    		String coName = 'AdditionalRequestDetail';
    		String objName = 'SFA2_PFG_Transaction_gne__c';
    		String rtName = 'Order';

    		Map<String,List<SFA2_Configuration_Object_Detail_gne__c>> codsMap = new Map<String,List<SFA2_Configuration_Object_Detail_gne__c>> {
				'View Order Details|View' =>
					new List<SFA2_Configuration_Object_Detail_gne__c>{
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Transaction_Ref_Number_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false, Is_Read_Only_gne__c = true, Label_gne__c='Order ID',Order_gne__c=1),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Shipment_Id_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false, Is_Read_Only_gne__c = true, Label_gne__c='Shipment ID',Order_gne__c=2),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Call_Name_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false, Is_Read_Only_gne__c = true, Label_gne__c='Interaction ID',Order_gne__c=3),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Delivery_Status_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false, Is_Read_Only_gne__c = true, Label_gne__c='Order Status',Order_gne__c=4),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Distribution_Method_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false, Is_Read_Only_gne__c = true, Label_gne__c='Order Type',Order_gne__c=5),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Shipment_Status_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false, Is_Read_Only_gne__c = true, Label_gne__c='Shipment Status',Order_gne__c=6),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Created_By_Info_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false, Is_Read_Only_gne__c = true, Label_gne__c='Created By',Order_gne__c=7),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Ship_to_Name_Calc_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false, Is_Read_Only_gne__c = true, Label_gne__c='Ship to Name',Order_gne__c=8),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Last_Modified_By_Info_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false, Is_Read_Only_gne__c = true, Label_gne__c='Last Modified By',Order_gne__c=9),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Location_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false, Is_Read_Only_gne__c = true, Label_gne__c='Ship To Address',Order_gne__c=10)
					}
			};

    		insertCos(coName, objName, new Set<String>{rtName}, codsMap);
    	}

    	public void insertTrxReturn() {
    		String coName = 'TransactionReturnDetail';
    		String objName = 'SFA2_PFG_Transaction_gne__c';
    		String rtName = 'Return';

    		Map<String,List<SFA2_Configuration_Object_Detail_gne__c>> codsMap = new Map<String,List<SFA2_Configuration_Object_Detail_gne__c>>{
				'Information|View' =>
					new List<SFA2_Configuration_Object_Detail_gne__c>{
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Name', Type_gne__c = 'Field', Is_Required_gne__c=false, Is_Read_Only_gne__c = true, Label_gne__c='Transaction ID',Order_gne__c=1),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Shipment_Id_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false, Label_gne__c='Shipment ID', Order_gne__c=2),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'From_User_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false, Label_gne__c='Return by', Order_gne__c=3),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Submitted_Date_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false, Label_gne__c='Submitted Date', Order_gne__c=4),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Transaction_Date_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=true, Is_Read_Only_gne__c = false,  Label_gne__c='Return Date', Order_gne__c=5)/*,
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Transaction_Reason_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false,  Is_Read_Only_gne__c = false, Label_gne__c='Reason',Order_gne__c=6)*/
					},

				'Information|New' =>
					new List<SFA2_Configuration_Object_Detail_gne__c>{
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'From_User_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=true, Label_gne__c='User ID', Order_gne__c=1),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Transaction_Date_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false,  Is_Read_Only_gne__c = false, Label_gne__c='Return Date',Order_gne__c=2),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Shipment_Id_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false, Is_Read_Only_gne__c = false, Label_gne__c='Shipment ID', Order_gne__c=3)
					},

				'Return Address Information|View' =>
					new List<SFA2_Configuration_Object_Detail_gne__c>{
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Vendor_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=true, Label_gne__c='Return To',Order_gne__c=1),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'City_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=true, Label_gne__c='City', Order_gne__c=2),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Address_Line_1_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false,Label_gne__c='Address Line 1', Order_gne__c=3),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'State_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false, Label_gne__c='State', Order_gne__c=4),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Address_Line_2_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false, Label_gne__c='Address Line 2', Order_gne__c=5),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Zip_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false, Label_gne__c='Zip', Order_gne__c=6)
					},
				'Return Address Information|New' =>
					new List<SFA2_Configuration_Object_Detail_gne__c>{
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Vendor_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=true, Label_gne__c='Return To',Order_gne__c=1),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'City_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=true, Label_gne__c='City', Order_gne__c=2),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Address_Line_1_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=true,Label_gne__c='Address Line 1', Order_gne__c=3),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'State_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=true, Label_gne__c='State', Order_gne__c=4),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Address_Line_2_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=false, Label_gne__c='Address Line 2', Order_gne__c=5),
						new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'Zip_gne__c', Type_gne__c = 'Field', Is_Required_gne__c=true, Label_gne__c='Zip', Order_gne__c=6)
					}
			};

    		insertCos(coName, objName, new Set<String>{rtName}, codsMap);
    	}

		private void insertCos(String coName, String objName, Set<String> rtNames, Map<String,List<SFA2_Configuration_Object_Detail_gne__c>> codsMap) {
			SFA2_Configuration_Object_gne__c tmplCoRec = new SFA2_Configuration_Object_gne__c(
					Configuration_Type_gne__c='Page',
					Is_Active_gne__c=true,
					Name=coName,
					Application_Type__c='SFA-US',
					Object_Name_gne__c=objName
			);

			Map<String,Integer> sectionOrders = new Map<String,Integer>();

			Integer idx=0;
			for(String sectionKey : codsMap.keySet()) {
				sectionOrders.put(sectionKey.split('\\|')[0],idx++);
			}

			List<SFA2_Configuration_Object_gne__c> cosToInsert = new List<SFA2_Configuration_Object_gne__c>();

			for(String sectionName : sectionOrders.keySet()) {
				for(String roleName : roleNames) {
					for(String brandName : brandNames) {
						for(String rtName : rtNames) {
							SFA2_Configuration_Object_gne__c co = tmplCoRec.clone();
							co.Role_gne__c = roleName;
							co.Brand_gne__c = brandName;
							co.Record_Type_gne__c = rtName;
							co.Section_Header_gne__c = sectionName;
							co.Order_gne__c = sectionOrders.get(sectionName);
							cosToInsert.add(co);
						}
					}
				}
			}

			insert cosToInsert;

			List<SFA2_Configuration_Object_Detail_gne__c> codsToInsert = new List<SFA2_Configuration_Object_Detail_gne__c>();

			for(String sectionHeaderInfo : codsMap.keySet()) {
				List<SFA2_Configuration_Object_Detail_gne__c> codsTemplates = codsMap.get(sectionHeaderInfo);

				List<String> sectionInfo = sectionHeaderInfo.split('\\|');

				String sectionName = sectionInfo[0];
				String availabilityMode = sectionInfo[1];
				for(SFA2_Configuration_Object_gne__c coRec : cosToInsert) {
					if(sectionName!=coRec.Section_Header_gne__c) {
						continue;
					}
					Integer orderIdx = 1;
					for(SFA2_Configuration_Object_Detail_gne__c codTmpl : codsTemplates) {
						SFA2_Configuration_Object_Detail_gne__c cod = codTmpl.clone();
						cod.Name = coRec.Name;
						cod.Order_gne__c = orderIdx;
						cod.Availability_Mode_gne__c = availabilityMode;
						cod.Is_Active_gne__c = true;
						cod.Configuration_Object_ref_gne__c = coRec.Id;


						codsToInsert.add(cod);
						orderIdx++;
					}
				}
			}

			insert codsToInsert;
    	}
    }

    public static List<String> getPageMessages() {
		List<String> pageMsgs = new List<String>();

		for(ApexPages.Message msg : ApexPages.getMessages()) {
			pageMsgs.add(msg.getSummary());
		}

		return pageMsgs;
	}
}