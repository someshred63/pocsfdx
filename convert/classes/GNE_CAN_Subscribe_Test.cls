@isTest
public class GNE_CAN_Subscribe_Test {

	private static Map<Id,String> recordTypeIdToNameMap;
	private static Map<String,Id> recordTypeNameToIdMap;
		 
    public static List<GNE_CAN_PS_Fields_Mapping_can__c> createStagingFieldMapList() {
    	List<GNE_CAN_PS_Fields_Mapping_can__c> fieldList = (List<GNE_CAN_PS_Fields_Mapping_can__c>)Test.loadData(GNE_CAN_PS_Fields_Mapping_can__c.SObjectType, 'GNE_CAN_PS_Fields_Mapping');
    	System.assert(!fieldList.isEmpty());
    	return fieldList;
    }
    
    //before launching assertTargetObject -  run createStagingFieldMapList();
	private static void assertTargetObject(SObject stgObj, SObject sfdcObj, Set<String> excludedStagingFields) {
		List<GNE_CAN_PS_Fields_Mapping_can__c> fieldMappings = GNE_CAN_PS_Fields_Mapping_can__c.getAll().values();
		for(GNE_CAN_PS_Fields_Mapping_can__c mapping : fieldMappings){
			if(mapping.Active_can__c == true && mapping.isDeleted == false && 
			   mapping.Staging_Object_can__c == stgObj.getSObjectType().getDescribe().getName() &&
			   !excludedStagingFields.contains(mapping.Staging_Field_can__c.ToUpperCase())) {
				Boolean compareValues = mapping.Update_mode_gne__c == 'ALWAYS' ||
										(mapping.Update_mode_gne__c == 'SOURCE_FIELD_NOT_NULL' && stgObj.get(mapping.Staging_Field_can__c)!= null);
										
				if(compareValues) {
					System.assertEquals(stgObj.get(mapping.Staging_Field_can__c), sfdcObj.get(mapping.Target_Field_can__c), 'Staging field ' + mapping.Staging_Field_can__c + ' field has different value than target field ' + mapping.Target_Field_can__c);
				}
			}	
		}
	}
	
	private static void assertAccount(Stg_SFA_Cust_Can__c stgCustomer, Account sfdcAccount) {
		Set<String> excludedFields = new Set<String>();
		if(stgCustomer.Cust_class_can__c == GNE_CAN_Subscribe_Util.HCO_CUSTOMER_CLASS_NAME) {
			excludedFields.add('SALUTATION_CAN__C');
			excludedFields.add('LASTNAME_CAN__C');
			excludedFields.add('FIRSTNAME_CAN__C');
			excludedFields.add('GENDER_CAN__C');
			excludedFields.add('MIDDLE_CAN__C');
		} else {
			excludedFields.add('ORG_NAME_CAN__C');	
		}
		
		System.assertEquals(sfdcAccount.Region_code_gne__c, GNE_CAN_Subscribe_Util.ACOUNT_DEFAULT_REGION_CODE, 'Region code not set correctly');
		System.assertEquals(sfdcAccount.OwnerId, GNE_CAN_Subscribe_Util.RECORD_OWNER_ID, 'Account Owner not set correctly');
		System.assertEquals(stgCustomer.Prim_IMS_Id_can__c, sfdcAccount.Prim_IMS_Id_can__c, 'Account IMS ID not set correctly');
		System.assertEquals(stgCustomer.UCI_Id_can__c, sfdcAccount.UCI_Id_can__c, 'Account UCI ID not set correctly');
		
		assertTargetObject(stgCustomer, sfdcAccount, excludedFields);
	}
	private static void assertAccounts(List<Stg_SFA_Cust_Can__c> stgCustomers) {
		assertAccounts(stgCustomers, GNE_CAN_Subscribe_Util.SUBSCRIBE_STATUS_SUCCESS);
	}
	private static void assertAccounts(List<Stg_SFA_Cust_Can__c> stgCustomers, String expectedSubscribeStatus) {
		Integer i=0;
		for(Stg_SFA_Cust_Can__c stgCust : stgCustomers) {
			// SOQL inside loop, but there should be max 10 records on the list
			Stg_SFA_Cust_Can__c stgCustCache = GNE_CAN_Subscribe_DAO.getCustomersWithAddressesByIds(new Set<Id>{stgCust.Id})[0];
			
			System.assertEquals(expectedSubscribeStatus,stgCustCache.Subscribe_Status_can__c, 'Subscribe status != ' + expectedSubscribeStatus);
			System.assertNotEquals(null,stgCustCache.Last_Subscribe_Date_can__c, 'Last Subscribe Date not set');
			
			List<Account> acc = GNE_CAN_Subscribe_DAO.getAccountsBySfdcIds(new Set<String>{stgCustCache.Src_Cust_Id_can__c});
			System.assertEquals(1, acc.size());
			assertAccount(stgCustCache, acc[0]);
		}
	}
	
	//before launching assertMatchedCustObjectsFieldsEquality -  run createStagingFieldMapList();
	private static void assertAddress(Stg_SFA_Cust_Addr_Can__c stgAddr, Address_vod__c sfdcAddr) {
		Set<String> excludedFields = new Set<String>();
		
		Set<String> yesValues = new Set<String>{'Y','1','TRUE'};
		if(stgAddr.Pri_Addr_Ind_can__c!=null) {
			System.assertEquals(sfdcAddr.Primary_vod__c, yesValues.contains(stgAddr.Pri_Addr_Ind_can__c.toUpperCase()), 'Primary address flag not set correctly');
		}
		excludedFields.add('PRI_ADDR_IND_CAN__C');
		
		if(stgAddr.UAD_Ind_can__c!=null) {
			System.assertEquals(sfdcAddr.Inactive_vod__c, stgAddr.UAD_Ind_can__c.toUpperCase() == GNE_CAN_Subscribe_Util.ADDRESS_UAD_INDICATOR_INACTIVE, 'Inactive VOD flag not set correctly');
		}
		excludedFields.add('UAD_IND_CAN__C');
		
		assertTargetObject(stgAddr, sfdcAddr, excludedFields);	
	}
	
	private static void assertAddresses(List<Stg_SFA_Cust_Addr_Can__c> stgAddrs) {
		Integer i=0;
		for(Stg_SFA_Cust_Addr_Can__c stgAddr : stgAddrs) {
			// SOQL inside loop, but there should be max 10 records on the list
			Stg_SFA_Cust_Addr_Can__c stgAddrCache = GNE_CAN_Subscribe_DAO.getCustomerAddressesByIds(new Set<Id>{stgAddr.Id})[0];
			List<Address_vod__c> addr = GNE_CAN_Subscribe_DAO.getAddressesBySfdcIds(new Set<String>{stgAddrCache.Src_Addr_Id_can__c});
			System.assertEquals(1, addr.size());
			assertAddress(stgAddrCache, addr[0]);
		}
	}
	
	private static void assertFailedAccounts(List<Stg_SFA_Cust_Can__c> stgCustomers) {
		Integer i=0;
		for(Stg_SFA_Cust_Can__c stgCust : stgCustomers) {
			// SOQL inside loop, but there should be max 10 records on the list
			Stg_SFA_Cust_Can__c stgCustCache = GNE_CAN_Subscribe_DAO.getCustomersWithAddressesByIds(new Set<Id>{stgCust.Id})[0];
			
			System.assertEquals(GNE_CAN_Subscribe_Util.SUBSCRIBE_STATUS_FAILED, stgCustCache.Subscribe_Status_can__c, 'Subscribe Status != FAILED');
			System.assertNotEquals(null, stgCustCache.Last_Subscribe_Date_can__c, 'Last Subscribe Date not set');
		}
	}
	
    static List<Address_vod__c> createAddressForAccount(List<Account> accountList) {
    	return createAddressForAccount(accountList, 'Home');    	
    }
 
	static List<Address_vod__c> createAddressForAccount(List<Account> accountList, String addressType) {
    	List<Address_vod__c> addressList = new List<Address_vod__c>();
    	
    	for(Integer i = 0; i < accountList.size(); i++)
    	{
    		Id recordTypeId = (recordTypeIdToNameMap.get(accountList[i].RecordTypeId)==GNE_CAN_Subscribe_Util.RECORD_TYPE_HCP) ?
    								recordTypeNameToIdMap.get(GNE_CAN_Subscribe_Util.RECORD_TYPE_ADDRESS_HCP) :
    								recordTypeNameToIdMap.get(GNE_CAN_Subscribe_Util.RECORD_TYPE_ADDRESS_HCO);

	    	addressList.add(new Address_vod__c ( Name = 'Address ' + i, RecordTypeId = recordTypeId, account_vod__c = accountList[i].Id, city_vod__c='test city', state_vod__c='test state', Address_Type_gne__c = addressType, Postal_Code_can_gne__c = 'A0A 1B1'));	
    	}       	
    	insert addressList;	
		return addressList;    	
    }
    
    static List<Account> createPersonAccountWithoutRocheId () {
        List<Account> accountList = new List<Account>();
        Id recordTypeId = recordTypeNameToIdMap.get(GNE_CAN_Subscribe_Util.RECORD_TYPE_HCP);
        accountList.add ( new Account ( FirstName = 'FirstName 1', LastName='Test', RecordTypeId = recordTypeId, OwnerId = GNE_CAN_Subscribe_Util.RECORD_OWNER_ID, 
        								Phone='6502551000', Region_code_gne__c = 2));
        accountList.add ( new Account ( FirstName = 'FirstName 2', LastName='Test', RecordTypeId = recordTypeId, OwnerId = GNE_CAN_Subscribe_Util.RECORD_OWNER_ID,
        								Phone='6502551000', Region_code_gne__c = 2));
        insert accountList;
    	return accountList;
    }

    static List<Account> createAccountWithoutRocheId () {
        List<Account> accountList = new List<Account>();
        System.debug('PN@@: recordTypeNameToIdMap: ' + recordTypeNameToIdMap);
        System.debug('PN%%: GNE_CAN_Subscribe_Util.RECORD_TYPE_HCO: ' + GNE_CAN_Subscribe_Util.RECORD_TYPE_HCO);
        Id recordTypeId = recordTypeNameToIdMap.get(GNE_CAN_Subscribe_Util.RECORD_TYPE_HCO);
        accountList.add ( new Account ( Name ='Test Org 1', RecordTypeId = recordTypeId, OwnerId = GNE_CAN_Subscribe_Util.RECORD_OWNER_ID,
        								Phone='6502551000', Region_code_gne__c = 2));
        accountList.add ( new Account ( Name ='Test Org 2', RecordTypeId = recordTypeId, OwnerId = GNE_CAN_Subscribe_Util.RECORD_OWNER_ID,
        								Phone='6502551000', Region_code_gne__c = 2));
        insert accountList;
        return accountList;
    }
    
    static List<Account> createAccountWithRocheId () {
        List<Account> accountList = new List<Account>();
        Id recordTypeId = recordTypeNameToIdMap.get(GNE_CAN_Subscribe_Util.RECORD_TYPE_HCO);
        accountList.add ( new Account ( Name ='Test Account 1', RecordTypeId = recordTypeId, OwnerId = GNE_CAN_Subscribe_Util.RECORD_OWNER_ID,
        								Phone='6502551001', Region_code_gne__c = 2, Roche_Id_can_gne__c = 'RC-HCO-0'));
        accountList.add ( new Account ( Name ='Test Account 2', RecordTypeId = recordTypeId, OwnerId = GNE_CAN_Subscribe_Util.RECORD_OWNER_ID,
        								Phone='6502551002', Region_code_gne__c = 2, Roche_Id_can_gne__c = 'RC-HCO-1'));
        insert accountList;
        return accountList;
    }
    
    static List<Stg_SFA_Cust_Addr_Can__c> createStagingCustomerAddrRecordForAddresses (List<Stg_SFA_Cust_Can__c> stgCusts, List<Address_vod__c> addresses) {        
        return createStagingCustomerAddrRecordForAddresses(stgCusts, addresses, GNE_CAN_Subscribe_Util.UAD_INDICATOR_UPDATE);
    }

    static List<Stg_SFA_Cust_Addr_Can__c> createStagingCustomerAddrRecordForAddresses (List<Stg_SFA_Cust_Can__c> stgCusts, List<Address_vod__c> addresses, String uadFlag) {    	
    	List<Stg_SFA_Cust_Addr_Can__c> custAddrList = new List<Stg_SFA_Cust_Addr_Can__c>();
    	for(Integer i = 0; i< stgCusts.size(); i++)
    	{    		    	    	
			Stg_SFA_Cust_Addr_Can__c stgCustAddr = new Stg_SFA_Cust_Addr_Can__c(
				Roche_Addr_Id_can__c = 'XXX-RA-' + i,
				Stg_SFA_Cust_ref_can__c = stgCusts[i].id,
				Address_Line1_can__c = 'Line ' + addresses[i].Id,
				Address_Type_can__c = addresses[i].Address_Type_gne__c,
				City_can__c = addresses[i].City_vod__c,
				Country_can__c = addresses[i].Country_gen__c, 	
				Postal_Code_can__c = addresses[i].Postal_Code_can_gne__c,				
				Roche_Id_can__c = null,
				Src_Addr_Id_can__c = addresses[i].Id,
				Province_can__c = 'AB',
				UAD_Ind_can__c = uadFlag,
				LOCK_IND_can__c = (Math.mod(i,2) == 0)
			);
			custAddrList.add(stgCustAddr);
    	}    	    	    	    	    
		insert custAddrList;
    	return custAddrList;
    }
    
    static List<Stg_SFA_Cust_Addr_Can__c> createStagingCustomerAddrRecordWithNullAddrId (List<Stg_SFA_Cust_Can__c> stgCusts) {
    	return createStagingCustomerAddrRecordWithNullAddrId(stgCusts, 0);
    }
    
    static List<Stg_SFA_Cust_Addr_Can__c> createStagingCustomerAddrRecordWithNullAddrId (List<Stg_SFA_Cust_Can__c> stgCusts, Integer startNumber) {    	
    	List<Stg_SFA_Cust_Addr_Can__c> custAddrList = new List<Stg_SFA_Cust_Addr_Can__c>();
    	for(Integer i = 0; i< stgCusts.size(); i++)
    	{    		    	    	
			Stg_SFA_Cust_Addr_Can__c stgCustAddr = new Stg_SFA_Cust_Addr_Can__c(
				Roche_Addr_Id_can__c = 'XXX-RA-' + (i + startNumber),
				Stg_SFA_Cust_ref_can__c = stgCusts[i].id,
				Address_Line1_can__c = 'Line ' + stgCusts[i].id,
				Address_Type_can__c = 'Office',
				City_can__c = 'City1',
				Country_can__c = 'CANADA', 	
				Postal_Code_can__c = 'A0A 1B1',				
				Roche_Id_can__c = null,
				Src_Addr_Id_can__c = null,
				Province_can__c = 'AB',
				UAD_Ind_can__c = GNE_CAN_Subscribe_Util.UAD_INDICATOR_INSERT,
				LOCK_IND_can__c = (Math.mod(i,2) == 0)	
			);
			custAddrList.add(stgCustAddr);
    	}    	    	    	    	    
		insert custAddrList;
    	return custAddrList;
    }     

    static List<Stg_SFA_Cust_Can__c> createStagingHCPCustomerRecord (Integer nHowMany) {
    	List<Stg_SFA_Cust_Can__c> custList = new List<Stg_SFA_Cust_Can__c>();
    	for (Integer i =0; i < nHowMany; i++) {
    		Stg_SFA_Cust_Can__c cust = new Stg_SFA_Cust_Can__c (
    		  Roche_Cust_Id_can__c = 'RC-HCP-0' + i,
    		  Prim_IMS_Id_can__c = 'IMS_ID_HCP' + i,
			  UCI_Id_can__c = 'UCI_ID_HCP' + i,
    		  FirstName_can__c = 'FirstName ' + i,
    		  LastName_can__c = 'Test',
              Gender_can__c = 'M',
    		  Cust_class_can__c = 'HCP',
    		  Middle_can__c = 'M',
    		  Professional_Type_can__c = 'PHYSICIAN',
    		  Salutation_can__c = 'Mr.',
    		  Title_can__c = 'MD',
    		  MRM_Status_can__c = 'ACTIVE',
    		  Rep_Spcl_can__c = 'General Practice',
    		  cell_phone_can__c = '1000000000',
    		  personemail_can__c = 'joe@some.com',
    		  Acount_Type_can__c = 'PersonAccountType',
    		  Sub_Type_can__c = 'Independent',
    		  Specialities_can__c = 'CARDIOLOGY;FAMILY MEDICINE',
    		  Language_can__c = ((Math.mod(i,2) == 0) ? 'English' : 'French'),
    		  UAD_Ind_can__c = GNE_CAN_Subscribe_Util.UAD_INDICATOR_INSERT   		  
    		);
    		custList.add(cust);
    	}
    	upsert custList Stg_SFA_Cust_Can__c.Roche_Cust_Id_can__c;
    	return custList;
    }
     

    static List<Stg_SFA_Cust_Can__c> createStagingOrgCustomerRecord (Integer nHowMany) {
        List<Stg_SFA_Cust_Can__c> custList = new List<Stg_SFA_Cust_Can__c>();
        for (Integer i =0; i < nHowMany; i++) {
            Stg_SFA_Cust_Can__c cust = new Stg_SFA_Cust_Can__c (
              Roche_Cust_Id_can__c = 'RC-HCO-' + i,
              Prim_IMS_Id_can__c = 'IMS_ID_HCO' + i,
			  UCI_Id_can__c = 'UCI_ID_HCO' + i,
              org_name_can__c = 'Test Org ' + i,
              Cust_class_can__c = 'HCO',
              MRM_Status_can__c = 'ACTIVE',
              Acount_Type_can__c = 'Department',
    		  Sub_Type_can__c = 'Independent',
    		  Specialities_can__c = 'CARDIOLOGY;FAMILY MEDICINE',
    		  Language_can__c = ((Math.mod(i,2) == 0) ? 'English' : 'French'),
    		  UAD_Ind_can__c = GNE_CAN_Subscribe_Util.UAD_INDICATOR_INSERT
            );
            custList.add(cust);
        }
        upsert custList Stg_SFA_Cust_Can__c.Roche_Cust_Id_can__c;
        return custList;
    }

    // update use case
    static List<Stg_SFA_Cust_Can__c> createStagingHCPCustomerForSFDCAccountList (List<Account> accountList) {
        List<Stg_SFA_Cust_Can__c> custList = new List<Stg_SFA_Cust_Can__c>();
        Integer i =0;
        for (Account a : accountList) {
            Stg_SFA_Cust_Can__c cust = new Stg_SFA_Cust_Can__c (
              Roche_Cust_Id_can__c = 'RC-HCP-' + i++,
              Prim_IMS_Id_can__c = 'IMS_ID_HCO' + i,
			  UCI_Id_can__c = 'UCI_ID_HCO' + i,
              Src_Cust_Id_can__c = a.id,
              FirstName_can__c = a.firstname,
              LastName_can__c = a.lastname,
              Gender_can__c = 'M',
              Cust_class_can__c = 'HCP',
              Middle_can__c = 'M',
              Professional_Type_can__c = 'PHYSICIAN',
              Salutation_can__c = 'Mr.',
              Title_can__c = 'MD',
              MRM_Status_can__c = 'ACTIVE',
              Rep_Spcl_can__c = 'General Practice',
              cell_phone_can__c = '1000000000',
              personemail_can__c = 'joe@some.com',
              Acount_Type_can__c = (a.Account_Type_gne__c==null?'PersonAccountType':a.Account_Type_gne__c),
    		  Sub_Type_can__c = 'Independent',
    		  Specialities_can__c = 'CARDIOLOGY;FAMILY MEDICINE',
    		  Language_can__c = ((Math.mod(i,2) == 0) ? 'English' : 'French'),
    		  UAD_Ind_can__c = GNE_CAN_Subscribe_Util.UAD_INDICATOR_UPDATE             
            );
            custList.add(cust);
        }
        upsert custList Stg_SFA_Cust_Can__c.Roche_Cust_Id_can__c;
        return custList;
    }

    static List<Stg_SFA_Cust_Can__c> createStagingOrgCustomerForSFDCAccountList (List<Account> accountList) {
        List<Stg_SFA_Cust_Can__c> custList = new List<Stg_SFA_Cust_Can__c>();
        Integer i =0;
        for (Account a : accountList) {
            Stg_SFA_Cust_Can__c cust = new Stg_SFA_Cust_Can__c (
              Roche_Cust_Id_can__c = 'RC-HCO-' + i++,
              Prim_IMS_Id_can__c = 'IMS_ID_HCO' + i,
			  UCI_Id_can__c = 'UCI_ID_HCO' + i,
              Src_Cust_Id_can__c = a.id,
              org_name_can__c = a.name,
              Cust_class_can__c = 'HCO',
              MRM_Status_can__c = 'ACTIVE',
              Acount_Type_can__c = 'Department_Hospital',
    		  Sub_Type_can__c = 'Independent',
    		  Specialities_can__c = 'CARDIOLOGY;FAMILY MEDICINE',
    		  Language_can__c = ((Math.mod(i,2) == 0) ? 'English' : 'French'),
    		  UAD_Ind_can__c = GNE_CAN_Subscribe_Util.UAD_INDICATOR_UPDATE
            );
            custList.add(cust);
        }
        upsert custList Stg_SFA_Cust_Can__c.Roche_Cust_Id_can__c;
        return custList;
    }
    
    public static void setUpProps(String accountInsertMode, String addressInsertMode){
		List<GNE_CAN_Config_Items_List_can__c> props = new List<GNE_CAN_Config_Items_List_can__c>();
		
		props.add(new GNE_CAN_Config_Items_List_can__c(Name = 'DEPARTMENT_ACCOUNT_TYPE', Value_can__c = 'Department'));
		props.add(new GNE_CAN_Config_Items_List_can__c(Name = 'HCO_CUSTOMER_CLASS_NAME' , Value_can__c = 'HCO'));
		props.add(new GNE_CAN_Config_Items_List_can__c(Name = 'HCP_CUSTOMER_CLASS_NAME' , Value_can__c = 'HCP'));
		props.add(new GNE_CAN_Config_Items_List_can__c(Name = 'RECORD_TYPE_ADDRESS_HCO' , Value_can__c = 'SFA Canada Company Maintained HCO'));
		props.add(new GNE_CAN_Config_Items_List_can__c(Name = 'RECORD_TYPE_ADDRESS_HCP' , Value_can__c = 'SFA Canada Company Maintained HCP'));
		props.add(new GNE_CAN_Config_Items_List_can__c(Name = 'RECORD_TYPE_HCO' , Value_can__c = 'GNE-SFA-Roche_Canada'));
		props.add(new GNE_CAN_Config_Items_List_can__c(Name = 'RECORD_TYPE_HCO_DEPARTMENT' , Value_can__c = 'GNE-SFA-Roche_Canada_Hospital_Depatment'));
		props.add(new GNE_CAN_Config_Items_List_can__c(Name = 'RECORD_TYPE_HCP' , Value_can__c = 'HCP Canada'));
		props.add(new GNE_CAN_Config_Items_List_can__c(Name = 'SFDC_DEBUG_LOGGING_LEVEL' , Value_can__c = 'ERROR'));
		props.add(new GNE_CAN_Config_Items_List_can__c(Name = 'ACOUNT_DEFAULT_REGION_CODE' , Value_can__c = '2'));
		props.add(new GNE_CAN_Config_Items_List_can__c(Name = 'NOTIFICATION_EMAIL', Value_can__c = 'test-subscribe-group@roche.com'));
		props.add(new GNE_CAN_Config_Items_List_can__c(Name = 'BATCH_SIZE' , Value_can__c = '10'));
		props.add(new GNE_CAN_Config_Items_List_can__c(Name = 'ACCOUNT_INSERT_MODE' , Value_can__c = accountInsertMode));
		props.add(new GNE_CAN_Config_Items_List_can__c(Name = 'ADDRESS_INSERT_MODE', Value_can__c = addressInsertMode));
		props.add(new GNE_CAN_Config_Items_List_can__c(Name = 'ACCOUNT_OWNER_USER_NAME' , Value_can__c = 'etladmin_canada@gene.com'));
		
		insert props;
		
		
	}
	
	private static User prepareEnv(String accountInsertMode, String addressInsertMode) {
		
		String profileName = 'RCanada-SYS-AutomatedJob';
		//String profileName = 'RCanada-SFA-Ops'; 
		setUpProps(accountInsertMode, addressInsertMode);
		createStagingFieldMapList();
		recordTypeIdToNameMap = new Map<Id,String>();
		recordTypeNameToIdMap = new Map<String,Id>();
		
		for(RecordType rt : GNE_CAN_Subscribe_DAO.getAccountAndAddressRecordTypes()) {
			recordTypeIdToNameMap.put(rt.Id, rt.Name);
			recordTypeNameToIdMap.put(rt.Name, rt.Id);
		}
		
		return createTestUser(profileName);
	}
	
	private static User createTestUser(String profileName) {
		User result = null;
		
		for(User u : [SELECT Id FROM User WHERE Profile.Name = :profileName AND IsActive = true LIMIT 1]) {
			result = u;
		}
		
		return result;
	}
	
	private static List<Stg_SFA_Subscribe_Apex_Job_Error__c> getErrorsForStagingCustomers(List<Stg_SFA_Cust_Can__c> custList) {
		Set<String> rocheIds = new Set<String>();
		
		for(Stg_SFA_Cust_Can__c cust : custList) {
	    	rocheIds.add(cust.Roche_Cust_Id_can__c);
	    }
	    
	    return GNE_CAN_Subscribe_DAO.getErrorsByRocheIds(rocheIds);
	}
	
	private static List<Stg_SFA_Subscribe_Apex_Job_Error__c> getErrorsForStagingAddresses(List<Stg_SFA_Cust_Addr_Can__c> custAddrList) {
		Set<String> rocheIds = new Set<String>();
		
		for(Stg_SFA_Cust_Addr_Can__c addr : custAddrList) {
	    	rocheIds.add(addr.Roche_Addr_Id_can__c);
	    }
	    
	    return GNE_CAN_Subscribe_DAO.getErrorsByRocheAddressIds(rocheIds);
	}
	
	private static GNE_CAN_Subscribe_Metrics runBatch(User asUser, String custClass) {
		return runBatch(asUser, custClass, true);
	}
	
	private static GNE_CAN_Subscribe_Metrics runBatch(User asUser, String custClass, Boolean runInTestBlock) {
		GNE_CAN_Subscribe_Metrics result = null;
		System.runAs(asUser) {
			if(runInTestBlock==true) {
	    		Test.startTest();
			}
			
	    	if(custClass == 'HCP') {
	    		GNE_CAN_Subscribe_Batch_PersonAccount batch = new GNE_CAN_Subscribe_Batch_PersonAccount();
	    		if(runInTestBlock==true) {
	    			Database.executeBatch(batch,10);
	    			result = batch.mainMetrics;
	    			System.debug('[TEST]:: GNE_CAN_Subscribe_Metrics = ' + result);	
	    		} else {
	    			batch.execute(null, [SELECT Roche_Cust_Id_can__c FROM Stg_SFA_Cust_Can__c WHERE Cust_class_can__c = :GNE_CAN_Subscribe_Util.HCP_CUSTOMER_CLASS_NAME]);
	    		}
	    		
	    		
	    	} else {
	    		GNE_CAN_Subscribe_Batch_OrgAccount batch = new GNE_CAN_Subscribe_Batch_OrgAccount();
	    		if(runInTestBlock==true) {
		    		Database.executeBatch(batch,10);
		    		result = batch.mainMetrics;
		    		System.debug('[TEST]:: GNE_CAN_Subscribe_Metrics = ' + result);
	    		} else {
	    			batch.execute(null, [SELECT Roche_Cust_Id_can__c FROM Stg_SFA_Cust_Can__c WHERE Cust_class_can__c = :GNE_CAN_Subscribe_Util.HCO_CUSTOMER_CLASS_NAME]);
	    		}
	    	}
	    	
	    	if(runInTestBlock==true) {
	    		Test.stopTest();
	    	}
	    }
	    
	    return result;
	}
	
	private static void assertMetrics(GNE_CAN_Subscribe_Metrics metrics, 
		Integer accountSuccess, Integer addressSuccess, Integer accountError, Integer addressError) {
		
		System.assertEquals(accountError + addressError, metrics.errorCount, 'TOTAL Number of errors not match');
		System.assertEquals(accountSuccess + addressSuccess, metrics.upsertCount, 'TOTAL Number of success not match');
		
		GNE_CAN_Subscribe_Metrics accountMetrics = metrics.relatedSubscribeMetrics.get('ACCOUNT');
		GNE_CAN_Subscribe_Metrics addressMetrics = metrics.relatedSubscribeMetrics.get('ADDRESS');
		
		System.assertEquals(accountError, accountMetrics.errorCount, 'Account Number of errors not match');
		System.assertEquals(accountSuccess, accountMetrics.upsertCount, 'Account Number of success not match');
		
		System.assertEquals(addressError, addressMetrics.errorCount, 'Address Number of errors not match');
		System.assertEquals(addressSuccess, addressMetrics.upsertCount, 'Address Number of success not match');
	}
	
    static testMethod void testInsertHCPSubscribeBatch() {
    	System.debug('Starting: testInsertHCPSubscribeBatch');
    	User testUser = prepareEnv('true', 'true');
    	System.assertNotEquals(null,testUser);
    	List<Stg_SFA_Cust_Can__c> custList = createStagingHCPCustomerRecord(5);
		
		runBatch(testUser, 'HCP');
		
		System.assertEquals ( 0, [select count() from account]);
	    
	    assertFailedAccounts(custList);
	    
	    List<Stg_SFA_Subscribe_Apex_Job_Error__c> errors = getErrorsForStagingCustomers(custList);
	    System.assertEquals ( custList.size(), errors.size());
		
		for(Stg_SFA_Subscribe_Apex_Job_Error__c error : errors) {
			System.assert(error.Error_Description_can__c.contains(GNE_CAN_Subscribe_Util.knownExceptionDescriptions.get(GNE_CAN_Subscribe_Util.KnownException.ACCOUNT_HAS_NO_ADDRESS)));
		}
	    		
		System.debug('Finishing: testInsertHCPSubscribeBatch');
    }

    static testMethod void testInsertHCOSubscribeBatch() {
    	System.debug('Starting: testInsertHCOSubscribeBatch');
    	User testUser = prepareEnv('true', 'true');
    	System.assertNotEquals(null,testUser);
		List<Stg_SFA_Cust_Can__c> custList = createStagingORGCustomerRecord(5);
	    
	    runBatch(testUser, 'HCO');
		
		system.assertEquals ( 0, [select count() from account]);
	    
	    assertFailedAccounts(custList);
	    
	    List<Stg_SFA_Subscribe_Apex_Job_Error__c> errors = getErrorsForStagingCustomers(custList);
	    System.assertEquals ( custList.size(), errors.size());
		
		for(Stg_SFA_Subscribe_Apex_Job_Error__c error : errors) {
			System.assert(error.Error_Description_can__c.contains(GNE_CAN_Subscribe_Util.knownExceptionDescriptions.get(GNE_CAN_Subscribe_Util.KnownException.ACCOUNT_HAS_NO_ADDRESS)));
		}
		
		System.debug('Finishing: testInsertHCOSubscribeBatch');
    }
	
    static testMethod void testUpdateHCOSubscribeBatch() {
    	System.debug('Starting: testUpdateHCOSubscribeBatch');
    	User testUser = prepareEnv('true', 'true');
    	System.assertNotEquals(null,testUser);
		
		List<Account> acctList = createAccountWithoutRocheId();
	    List<Stg_SFA_Cust_Can__c> stgCusts = createStagingOrgCustomerForSFDCAccountList(acctList);
	    system.assert(stgCusts.size() == 2);
	        
		runBatch(testUser, 'HCO');
		
		assertAccounts(stgCusts);
	        
	    List<String> acctIdList = new List<String> { acctList[0].Id, acctList[1].Id};
	    acctList = [select id, Roche_Id_can_gne__c from account where Roche_Id_can_gne__c != null and id in :acctIdList ]; 
	    system.assertEquals ( 2, acctList.size());
		
		System.debug('Finishing: testUpdateHCOSubscribeBatch');
    }
    
    //Creates two HCPs without RocheId, creates stageing records for them, 
    //launches Subscribe and check if RochId field has been updated.    
    static testMethod void testUpdateHCPSubscribeBatch(){
    	System.debug('Starting: testUpdateHCPSubscribeBatch');
    	User testUser = prepareEnv('true', 'true');
    	System.assertNotEquals(null,testUser);
		
		List<Account> acctList = createPersonAccountWithoutRocheId();
		List<Stg_SFA_Cust_Can__c> stgCusts = createStagingHCPCustomerForSFDCAccountList(acctList);
	    system.assert (stgCusts.size() == 2);
	        
		runBatch(testUser, 'HCP');
		
		assertAccounts(stgCusts);
	    List<String> acctIdList = new List<String> { acctList[0].Id, acctList[1].Id};
	    acctList = [select id, Roche_Id_can_gne__c from account where Roche_Id_can_gne__c != null and id in :acctIdList ]; 
	    system.assertEquals ( 2, acctList.size());    	
		
		System.debug('Finishing: testUpdateHCPSubscribeBatch');    	
    }
   	
    
    //	Creates two stageing records: one for an HCO and one for its address, launches Subscribe process and 
    //	checks if appropriate records (new HCP + new Address) has been created.
    
    static testMethod void testInsertHCPwithAddressBatch(){    
    	System.debug('Starting: testInsertHCPwithAddressBatch');
    	User testUser = prepareEnv('true', 'true');
    	System.assertNotEquals(null,testUser);
    	List<Stg_SFA_Cust_Can__c> stgCusts = createStagingHCPCustomerRecord(1);
    	List<Stg_SFA_Cust_Addr_Can__c> stgCustsAddrs = createStagingCustomerAddrRecordWithNullAddrId(stgCusts);
		
		runBatch(testUser, 'HCP');
	    
	    String rocheIdToFind = stgCusts[0].Roche_Cust_Id_can__c;

		List<Account> accs = [SELECT Id FROM Account WHERE Roche_Id_can_gne__c =:rocheIdToFind];
		system.assertEquals (1, accs.size());
		      
		List<Address_vod__c> addrs = [SELECT Id FROM Address_vod__c WHERE Account_vod__c =:accs[0].id];
		system.assertEquals (1, addrs.size());		        
		     
		assertAccounts(stgCusts);
		assertAddresses(stgCustsAddrs);
	     
		System.debug('Finishing: testInsertHCPwithAddressBatch');    	        
    }
    
    	//Creates an HCP with an address, creates stageing records that causes address update, launches Subscribe 
    	//process and checks if the address data (addressType) has been updated.   
    
    static testMethod void testUpdateHCPAddressSubscribeBatch(){ 
    	System.debug('Starting: testUpdateHCPAddressSubscribeBatch');   	
    	User testUser = prepareEnv('true', 'true');
    	System.assertNotEquals(null,testUser);
		
		List<Account> acctList = createPersonAccountWithoutRocheId();    	    	
	    List<Address_vod__c> addressList = createAddressForAccount(acctList, 'Office');	
	    
	    List<Stg_SFA_Cust_Can__c> stgCustList = createStagingHCPCustomerForSFDCAccountList(acctList);
	    List<Stg_SFA_Cust_Addr_Can__c> stgCustAddrList = createStagingCustomerAddrRecordForAddresses(stgCustList, addressList);
		Stg_SFA_Cust_Addr_Can__c stgCustAddr = stgCustAddrList[0]; 
	    stgCustAddr.Address_Type_can__c = 'Home'; // Update from 'Office' to 'Home'.
	    update stgCustAddr;
	  
		runBatch(testUser, 'HCP');
		
		List<Address_vod__c> addrs = [select id from Address_vod__c where Account_vod__c =:acctList[0].id and Address_Type_gne__c = 'Home'];
		System.assertEquals (1, addrs.size()); 	 
		
		assertAccounts(stgCustList);
		assertAddresses(stgCustAddrList);
		
		System.debug('Finishing: testUpdateHCPAddressSubscribeBatch');   	    
    }	
            
   
    	//Creates an HCP with an address, creates a stateging records that adds new address, launches Subscribe process
    	//and checks if the HCP has 2 adresses now.
   
    static testMethod void testHCPAddAddressSubscribeBatch(){
    	System.debug('Starting: testHCPAddAddressSubscribeBatch');
   		User testUser = prepareEnv('true', 'true');
    	System.assertNotEquals(null,testUser);
		
		List<Account> acctList = createPersonAccountWithoutRocheId();    	    	
	    List<Address_vod__c> addressList = createAddressForAccount(acctList, 'Office');	
	    
	    List<Stg_SFA_Cust_Can__c> stgCustList = createStagingHCPCustomerForSFDCAccountList(acctList);
		List<Stg_SFA_Cust_Addr_Can__c> stgCustsAddrs = createStagingCustomerAddrRecordWithNullAddrId(stgCustList);            	        	        	        
	    
	    runBatch(testUser, 'HCP');
		
		List<Address_vod__c> addrs = [select id from Address_vod__c where Account_vod__c =:acctList[0].id];
		System.assertEquals (2, addrs.size());
		
		assertAccounts(stgCustList);
		assertAddresses(stgCustsAddrs);
		
		System.debug('Finishing: testHCPAddAddressSubscribeBatch');    	 	    	    	    	    	
    }   
   
    //	Creates HCP stageing record and runs batch for HCO.
    // Check validation when Staging Customer is HCO and existing Account is HCP
    static testMethod void testHCPforHCOSubscribeBatch(){
    	System.debug('Starting: testHCPforHCOSubscribeBatch');
		User testUser = prepareEnv('true', 'true');
    	System.assertNotEquals(null,testUser);
    	
		List<Account> acctList = createAccountWithoutRocheId();
		List<Stg_SFA_Cust_Can__c> stgCusts = createStagingHCPCustomerForSFDCAccountList(acctList);
		
		for(Stg_SFA_Cust_Can__c stgCust : stgCusts) {
			stgCust.FirstName_can__c = 'TEST';
			stgCust.LastName_can__c = 'TEST';
		} 
		update stgCusts;
		
	    createStagingCustomerAddrRecordWithNullAddrId(stgCusts);	    	    	  	  
	  	
		GNE_CAN_Subscribe_Metrics metrics = runBatch(testUser, 'HCP');
		
		String rocheIdToFind = stgCusts[0].Roche_Cust_Id_can__c;
	    List<Account> accs = [select id from account where Roche_Id_can_gne__c =:rocheIdToFind];
	    System.assertEquals (0, accs.size());
	    
	    assertFailedAccounts(stgCusts);
	    System.assertEquals (0, [SELECT count() FROM Address_vod__c]);
	    
	    List<Stg_SFA_Subscribe_Apex_Job_Error__c> errors = getErrorsForStagingCustomers(stgCusts);
	    System.assertEquals ( stgCusts.size(), errors.size());
		
		for(Stg_SFA_Subscribe_Apex_Job_Error__c error : errors) {
			System.assert(error.Error_Description_can__c.contains(GNE_CAN_Subscribe_Util.knownExceptionDescriptions.get(GNE_CAN_Subscribe_Util.KnownException.CANNOT_CHANGE_RECORD_TYPE)));
		}
		
		//assertMetrics(metrics,0,0,stgCusts.size(),0);
	        	  
		System.debug('Finishing: testHCPforHCOSubscribeBatch');      	    	    	    	
    }

	
    static testMethod void testStagingRecordsNoSubscribeBatch(){
    	System.debug('Starting: testStageingRecordsNoSubscribeBatch');
		User testUser = prepareEnv('true', 'true');
    	System.assertNotEquals(null,testUser);
    	List<Stg_SFA_Cust_Can__c> stgCusts = createStagingHCPCustomerRecord(2);  
	    createStagingCustomerAddrRecordWithNullAddrId(stgCusts);
	        
	    Set<Id> stgIds = new Set<Id>();
		stgIds.add(stgCusts[0].Id);
	    
	    System.runAs(testUser) {
	    	Test.startTest();
        	GNE_CAN_Subscribe_Batch_PersonAccount batch = new GNE_CAN_Subscribe_Batch_PersonAccount(stgIds);
		    Database.executeBatch(batch,10);
	        Test.stopTest();    	 
		}	
	    
	    String rocheIdToFind = stgCusts[0].Roche_Cust_Id_can__c;
	    List<Account> accs = [select id from account where Roche_Id_can_gne__c =:rocheIdToFind];
	    System.assertEquals (1, accs.size());
	    
	    assertAccounts(new List<Stg_SFA_Cust_Can__c>{stgCusts[0]});
	        	 
		System.debug('Finishing: testStageingRecordsNoSubscribeBatch');       	    	    	    	
    }       
    
    //Creates Staging customer object and run subscribe process with Insert Mode Off - no Accounts should be inserted.
    //Check if Accounts are only updated if Insert Mode is off.
    
     static testMethod void testInsertModeOffForAccountsBatch() {
    	System.debug('Starting: testInsertModeOffForAccountsBatch');
    	User testUser = prepareEnv('false', 'true');
    	System.assertNotEquals(null,testUser);
    	List<Stg_SFA_Cust_Can__c> custList = createStagingHCPCustomerRecord(5);
		createStagingCustomerAddrRecordWithNullAddrId(custList);
	    
	    runBatch(testUser, 'HCP');
		
	    System.assertEquals ( 0, [select count() from account]);
	    
	    List<Stg_SFA_Subscribe_Apex_Job_Error__c> errors = getErrorsForStagingCustomers(custList);
	    System.assertEquals ( 0, errors.size());
		
		System.debug('Finishing: testInsertModeOffForAccountsBatch');
    }
    
    
    //Creates Staging customer object with Addresses for them and run subscribe process with Addresses Insert Mode Off - no Accounts should be inserted.
    //Check if Addresses are only updated if Insert Mode is off.
    
     static testMethod void testInsertModeOffForAddressesBatch() {
  
    	System.debug('Starting: testInsertModeOffForAddressesBatch');
    	User testUser = prepareEnv('true', 'false');
    	System.assertNotEquals(null,testUser);
    	List<Stg_SFA_Cust_Can__c> stgCusts = createStagingHCPCustomerRecord(1);
    	List<Stg_SFA_Cust_Addr_Can__c> stgCustsAddrs = createStagingCustomerAddrRecordWithNullAddrId(stgCusts);
		
		runBatch(testUser, 'HCP');
	        	        
	    String rocheIdToFind = stgCusts[0].Roche_Cust_Id_can__c;
        List<Account> accs = [select id from account where Roche_Id_can_gne__c =:rocheIdToFind];
	    system.assertEquals (1, accs.size());
	    assertAccounts(stgCusts);
	        
	    List<Address_vod__c> addrs = [select id from Address_vod__c where Account_vod__c =:accs[0].id];
	    system.assertEquals (0, addrs.size());		        
	    
	    List<Stg_SFA_Subscribe_Apex_Job_Error__c> errors = getErrorsForStagingCustomers(stgCusts);
	    System.assertEquals ( 0, errors.size());     	     	        	       	        
		
		System.debug('Finishing: testInsertModeOffForAddressesBatch');    	        

    }
      
    static testMethod void testSubscribeStatusOnFailedAddress() {
    	User testUser = prepareEnv('true', 'true');
    	System.assertNotEquals(null,testUser);
    	
    	List<Stg_SFA_Cust_Can__c> stgCusts = createStagingHCPCustomerRecord(1);
    	List<Stg_SFA_Cust_Addr_Can__c> stgCustsAddrs = createStagingCustomerAddrRecordWithNullAddrId(stgCusts);
    	stgCustsAddrs[0].Address_Line1_can__c = null;
    	update stgCustsAddrs[0];
    	
    	runBatch(testUser, 'HCP');
    	
    	system.assertEquals (0, [SELECT count() FROM Account]);
    	system.assertEquals (0, [SELECT count() FROM Address_vod__c]);
    	
    	Stg_SFA_Cust_Can__c stgCust = [SELECT Subscribe_Status_can__c, Last_Subscribe_Date_can__c FROM Stg_SFA_Cust_Can__c WHERE Id = :stgCusts[0].Id];
    	System.assertEquals(GNE_CAN_Subscribe_Util.SUBSCRIBE_STATUS_FAILED, stgCust.Subscribe_Status_can__c, 'Subscribe Status != FAILED');
		System.assertNotEquals(null, stgCust.Last_Subscribe_Date_can__c, 'Last Subscribe Date not set');
		
		List<Stg_SFA_Subscribe_Apex_Job_Error__c> errors = getErrorsForStagingCustomers(new List<Stg_SFA_Cust_Can__c>{stgCusts[0]});
	    System.assertEquals( 2, errors.size());
	    Set<String> errorDescs = new Set<String>();
	    for(Stg_SFA_Subscribe_Apex_Job_Error__c error : errors) {
	    	System.assert(error.Error_Description_can__c.contains(GNE_CAN_Subscribe_Util.knownExceptionDescriptions.get(GNE_CAN_Subscribe_Util.KnownException.ADDRESS_NAME_IS_NULL))
	    		|| error.Error_Description_can__c.contains(GNE_CAN_Subscribe_Util.knownExceptionDescriptions.get(GNE_CAN_Subscribe_Util.KnownException.ACCOUNT_HAS_NO_VALID_ADDRESS)));
		}
	}
    
    static testMethod void testUpdateOfFieldsSourcedBySFDC() {
    	User testUser = prepareEnv('true', 'true');
    	System.assertNotEquals(null,testUser);
    	
    	List<Account> acctList = createPersonAccountWithoutRocheId();
    	
	    List<Stg_SFA_Cust_Can__c> stgCustList = createStagingHCPCustomerForSFDCAccountList(acctList);
		List<Stg_SFA_Cust_Addr_Can__c> stgCustsAddrs = createStagingCustomerAddrRecordWithNullAddrId(stgCustList);
    	
    	for(Account acc : acctList) {
    		acc.Cell_Phone_gne__c = '(999) 999-9999';
    	}
    	
    	update acctList;
    	
    	runBatch(testUser, 'HCP');
    	
    	System.assertEquals(stgCustList.size(), [SELECT count() FROM Account]);
    	System.assertEquals(stgCustsAddrs.size(), [SELECT count() FROM Address_vod__c]);
    	
    	assertAccounts(stgCustList);
    	assertAddresses(stgCustsAddrs);
    	
    	acctList = [SELECT Id, Cell_Phone_gne__c FROM Account WHERE Id IN :acctList];
    	
    	for(Account acc : acctList) {
    		System.assertEquals('(999) 999-9999', acc.Cell_Phone_gne__c,'Cell Phone should remain unchanged');
    	}
    }
    
    static testMethod void testFieldUpdateOnlyWhenTargetIsNull() {
    	User testUser = prepareEnv('true', 'true');
    	System.assertNotEquals(null,testUser);
    	
    	List<Account> acctList = createPersonAccountWithoutRocheId();
    	
	    List<Stg_SFA_Cust_Can__c> stgCustList = createStagingHCPCustomerForSFDCAccountList(acctList);
		List<Stg_SFA_Cust_Addr_Can__c> stgCustsAddrs = createStagingCustomerAddrRecordWithNullAddrId(stgCustList);
    	
    	acctList[0].PersonTitle = null;
    	acctList[1].PersonTitle = 'DR';
    	
    	update acctList;
    	
    	runBatch(testUser, 'HCP');
    	
    	System.assertEquals(stgCustList.size(), [SELECT count() FROM Account]);
    	System.assertEquals(stgCustsAddrs.size(), [SELECT count() FROM Address_vod__c]);
    	
    	assertAccounts(stgCustList);
    	assertAddresses(stgCustsAddrs);
    	
    	System.assertEquals(stgCustList[0].Title_can__c, [SELECT Id, PersonTitle FROM Account WHERE Id = :acctList[0].Id].PersonTitle, 'PersonTitle should be updated');
    	System.assertEquals('DR', [SELECT Id, PersonTitle FROM Account WHERE Id = :acctList[1].Id].PersonTitle, 'PersonTitle should not be updated');
    }
    
    static testMethod void testFieldUpdateOnlyIfSourceIsNotNull() {
    	User testUser = prepareEnv('true', 'true');
    	System.assertNotEquals(null,testUser);
    	
    	List<Account> acctList = createPersonAccountWithoutRocheId();
    	
	    List<Stg_SFA_Cust_Can__c> stgCustList = createStagingHCPCustomerForSFDCAccountList(acctList);
		List<Stg_SFA_Cust_Addr_Can__c> stgCustsAddrs = createStagingCustomerAddrRecordWithNullAddrId(stgCustList);
    	
    	acctList[0].Salutation = 'Mr.';
    	acctList[1].Salutation = 'Mr.';
    	
    	update acctList;
    	
    	stgCustList[0].Salutation_can__c = null;
    	stgCustList[1].Salutation_can__c = 'Miss';
    	
    	update stgCustList;
    	
    	runBatch(testUser, 'HCP');
    	
    	System.assertEquals(stgCustList.size(), [SELECT count() FROM Account]);
    	System.assertEquals(stgCustsAddrs.size(), [SELECT count() FROM Address_vod__c]);
    	
    	assertAccounts(stgCustList);
    	assertAddresses(stgCustsAddrs);
    	
    	System.assertEquals('Mr.', [SELECT Id, Salutation FROM Account WHERE Id = :acctList[0].Id].Salutation, 'Saluation should not be updated');
    	System.assertEquals(stgCustList[1].Salutation_can__c, [SELECT Id, Salutation FROM Account WHERE Id = :acctList[1].Id].Salutation, 'Salutation should be updated');
    }
    
    static testMethod void testHCPSpecificFieldsNotSetForHCO() {
    	User testUser = prepareEnv('true', 'true');
    	System.assertNotEquals(null,testUser);
    	
    	List<Stg_SFA_Cust_Can__c> stgCusts = createStagingOrgCustomerRecord(1);
    	List<Stg_SFA_Cust_Addr_Can__c> stgCustsAddrs = createStagingCustomerAddrRecordWithNullAddrId(stgCusts);
    	stgCusts[0].Gender_can__c = 'TEST';
    	stgCusts[0].Middle_can__c = 'TEST';
    	stgCusts[0].Salutation_can__c = 'TEST';
    	
    	update stgCusts[0];
    	
    	runBatch(testUser, 'HCO');
    	
    	System.assertEquals(stgCusts.size(), [SELECT count() FROM Account]);
    	System.assertEquals(stgCustsAddrs.size(), [SELECT count() FROM Address_vod__c]);
    	
    	assertAccounts(stgCusts);
    	assertAddresses(stgCustsAddrs);
    	
    	List<Account> acctList = [SELECT Salutation, Middle_vod__c, Gender_vod__c FROM Account];
    	
    	for(Account acc : acctList) {
    		System.assertEquals(null, acc.Salutation, 'Salutation should be unset for HCO');
    		System.assertEquals(null, acc.Middle_vod__c, 'Middle should be unset for HCO');
    		System.assertEquals(null, acc.Gender_vod__c, 'Gender should be unset for HCO');
    	}
    }
    
    static testMethod void testIncrementalModeNoUpdate() {
    	User testUser = prepareEnv('true', 'true');
    	System.assertNotEquals(null,testUser);
    	
    	List<Account> acctList = createPersonAccountWithoutRocheId();
    	
	    List<Stg_SFA_Cust_Can__c> stgCustList = createStagingHCPCustomerForSFDCAccountList(acctList);
		List<Stg_SFA_Cust_Addr_Can__c> stgCustsAddrs = createStagingCustomerAddrRecordWithNullAddrId(stgCustList);
    	
    	GNE_CAN_Subscribe_Batch_PersonAccount batch = new GNE_CAN_Subscribe_Batch_PersonAccount();
    	batch.start(null);
    	batch.execute(null,[SELECT Roche_Cust_Id_can__c
					 		FROM Stg_SFA_Cust_Can__c 
				 			WHERE Cust_class_can__c = 'HCP']);
    	batch.finish(null);
    	
    	System.assertEquals(stgCustList.size(), [SELECT count() FROM Account]);
    	System.assertEquals(stgCustsAddrs.size(), [SELECT count() FROM Address_vod__c]);
    	
    	assertAccounts(stgCustList);
    	assertAddresses(stgCustsAddrs);
    	
    	batch = new GNE_CAN_Subscribe_Batch_PersonAccount();
    	Database.Querylocator ql = batch.start(null);
    	System.assertEquals(false,ql.iterator().hasNext(), 'There should be nothing to update');
    	
    	List<Stg_SFA_Cust_Can__c> stgCusts = createStagingHCPCustomerRecord(1);
    	List<Stg_SFA_Cust_Addr_Can__c> stgCustsAddrs2 = createStagingCustomerAddrRecordWithNullAddrId(stgCusts, stgCustsAddrs.size());
    	
    	runBatch(testUser, 'HCP');
    	
    	assertAccounts(stgCusts);
    	assertAddresses(stgCustsAddrs2);
    }
    
    static testMethod void testAddressDeactivation() {
    	User testUser = prepareEnv('true', 'true');
    	System.assertNotEquals(null,testUser);
    	GNE_SFA2_Account_Trigger_Helper.setAccountTrig(true);
    	GNE_SFA2_Address_Trigger_Helper.setAddressTrig(true);
    	
    	List<Account> acctList = createPersonAccountWithoutRocheId();
    	acctList = new List<Account>{acctList[0]};  	    	
	    List<Address_vod__c> addressList = createAddressForAccount(acctList, 'Office');	
	    
	    List<Stg_SFA_Cust_Can__c> stgCustList = createStagingHCPCustomerForSFDCAccountList(acctList);
	    List<Stg_SFA_Cust_Addr_Can__c> stgCustAddrList;

	    // Create Address for deactivation
	    addressList = createAddressForAccount(acctList, 'Home');
		stgCustAddrList = createStagingCustomerAddrRecordForAddresses(stgCustList, addressList, GNE_CAN_Subscribe_Util.ADDRESS_UAD_INDICATOR_INACTIVE);
		List<Stg_SFA_Cust_Addr_Can__c> allCustAddrList = new List<Stg_SFA_Cust_Addr_Can__c>(stgCustAddrList);
		
        GNE_SFA2_Account_Trigger_Helper.setAccountTrig(false);
    	GNE_SFA2_Address_Trigger_Helper.setAddressTrig(false);
		
		allCustAddrList.addAll(stgCustAddrList);
    
        runBatch(testUser, 'HCP');

        assertAccounts(stgCustList);
        assertAddresses(allCustAddrList);
    }
    
    static testMethod void testHCORecordTypeDepartmentToSimpleHCO() {
    	User testUser = prepareEnv('true', 'true');
    	System.assertNotEquals(null,testUser);
    	
    	List<Account> acctList = createAccountWithoutRocheId();
    	
	    List<Stg_SFA_Cust_Can__c> stgCusts = createStagingOrgCustomerForSFDCAccountList(acctList);
	    for(Stg_SFA_Cust_Can__c stgCust : stgCusts) {
	    	stgCust.Acount_Type_can__c = GNE_CAN_Subscribe_Util.DEPARTMENT_ACCOUNT_TYPE;
	    }
	    update stgCusts;
	    
	    system.assert(stgCusts.size() == 2);
	        
		runBatch(testUser, 'HCO');
		
		assertAccounts(stgCusts);
	        
	    List<String> acctIdList = new List<String> { acctList[0].Id, acctList[1].Id};
	    acctList = [select id, Roche_Id_can_gne__c from account where Roche_Id_can_gne__c != null and id in :acctIdList ]; 
	    system.assertEquals ( 2, acctList.size());
    }
    
    static testMethod void testInsertIndicatorWithExistingRocheId() {
    	User testUser = prepareEnv('true', 'true');
    	System.assertNotEquals(null,testUser);
    	
    	List<Account> acctList = createAccountWithRocheId();
    	
	    List<Stg_SFA_Cust_Can__c> stgCusts = createStagingOrgCustomerForSFDCAccountList(acctList);
	    createStagingCustomerAddrRecordWithNullAddrId(stgCusts);
	    for(Stg_SFA_Cust_Can__c stgCust : stgCusts) {
	    	stgCust.UAD_Ind_can__c = GNE_CAN_Subscribe_Util.UAD_INDICATOR_INSERT;
	    }
	    update stgCusts;
	    
	    system.assert(stgCusts.size() == 2);
	        
		runBatch(testUser, 'HCO');
		
		system.assertEquals (2, [SELECT count() FROM Account]);
		system.assertEquals (0, [SELECT count() FROM Address_vod__c]);
    	
    	Stg_SFA_Cust_Can__c stgCust = [SELECT Subscribe_Status_can__c, Last_Subscribe_Date_can__c FROM Stg_SFA_Cust_Can__c WHERE Id = :stgCusts[0].Id];
    	System.assertEquals(GNE_CAN_Subscribe_Util.SUBSCRIBE_STATUS_FAILED, stgCust.Subscribe_Status_can__c, 'Subscribe Status != FAILED');
		System.assertNotEquals(null, stgCust.Last_Subscribe_Date_can__c, 'Last Subscribe Date not set');
		
		List<Stg_SFA_Subscribe_Apex_Job_Error__c> errors = getErrorsForStagingCustomers(stgCusts);
	    System.assertEquals ( stgCusts.size(), errors.size());
		
		for(Stg_SFA_Subscribe_Apex_Job_Error__c error : errors) {
			System.assert(error.Error_Description_can__c.contains(GNE_CAN_Subscribe_Util.knownExceptionDescriptions.get(GNE_CAN_Subscribe_Util.KnownException.TARGET_ACCOUNT_WITH_GIVEN_ROCHE_ID_ALREADY_EXISTS)));
		}
    }
    
    static testMethod void testUpdateIndicatorWithNoExistingAccount() {
    	User testUser = prepareEnv('true', 'true');
    	System.assertNotEquals(null,testUser);
    	
    	List<Stg_SFA_Cust_Can__c> stgCusts = createStagingOrgCustomerRecord(10);
    	for(Stg_SFA_Cust_Can__c stgCust : stgCusts) {
	    	stgCust.UAD_Ind_can__c = GNE_CAN_Subscribe_Util.UAD_INDICATOR_UPDATE;
	    }
	    update stgCusts;
	    
	    system.assert(stgCusts.size() == 10);
	        
		runBatch(testUser, 'HCO');
		
		system.assertEquals (0, [SELECT count() FROM Account]);
    	
    	Stg_SFA_Cust_Can__c stgCust = [SELECT Subscribe_Status_can__c, Last_Subscribe_Date_can__c FROM Stg_SFA_Cust_Can__c WHERE Id = :stgCusts[0].Id];
    	System.assertEquals(GNE_CAN_Subscribe_Util.SUBSCRIBE_STATUS_FAILED, stgCust.Subscribe_Status_can__c, 'Subscribe Status != FAILED');
		System.assertNotEquals(null, stgCust.Last_Subscribe_Date_can__c, 'Last Subscribe Date not set');
		
		List<Stg_SFA_Subscribe_Apex_Job_Error__c> errors = getErrorsForStagingCustomers(stgCusts);
	    System.assertEquals ( stgCusts.size(), errors.size());
		
		for(Stg_SFA_Subscribe_Apex_Job_Error__c error : errors) {
			System.assert(error.Error_Description_can__c.contains(GNE_CAN_Subscribe_Util.knownExceptionDescriptions.get(GNE_CAN_Subscribe_Util.KnownException.TARGET_ACCOUNT_FOR_UPDATE_NOT_FOUND)));
		}
    }
    
    static testMethod void testNotValidIndicatorForAccount() {
    	User testUser = prepareEnv('true', 'true');
    	System.assertNotEquals(null,testUser);
    	
    	List<Stg_SFA_Cust_Can__c> stgCusts = createStagingOrgCustomerRecord(10);
	    for(Stg_SFA_Cust_Can__c stgCust : stgCusts) {
	    	stgCust.UAD_Ind_can__c = 'Z';
	    }
	    update stgCusts;
	    
	    system.assert(stgCusts.size() == 10);
	        
		runBatch(testUser, 'HCO');
		
		system.assertEquals (0, [SELECT count() FROM Account]);
    	
    	Stg_SFA_Cust_Can__c stgCust = [SELECT Subscribe_Status_can__c, Last_Subscribe_Date_can__c FROM Stg_SFA_Cust_Can__c WHERE Id = :stgCusts[0].Id];
    	System.assertEquals(GNE_CAN_Subscribe_Util.SUBSCRIBE_STATUS_FAILED, stgCust.Subscribe_Status_can__c, 'Subscribe Status != FAILED');
		System.assertNotEquals(null, stgCust.Last_Subscribe_Date_can__c, 'Last Subscribe Date not set');
		
		List<Stg_SFA_Subscribe_Apex_Job_Error__c> errors = getErrorsForStagingCustomers(stgCusts);
	    System.assertEquals ( stgCusts.size(), errors.size());
		
		for(Stg_SFA_Subscribe_Apex_Job_Error__c error : errors) {
			System.assert(error.Error_Description_can__c.contains(GNE_CAN_Subscribe_Util.knownExceptionDescriptions.get(GNE_CAN_Subscribe_Util.KnownException.ACCOUNT_UAD_INDICATOR_NOT_VALID)));
		}
    }
    
    static testMethod void testInsertIndicatorWithExistingRocheAddressId() {
    	User testUser = prepareEnv('true', 'true');
    	System.assertNotEquals(null,testUser);
    	
    	List<Account> acctList = createPersonAccountWithoutRocheId();    	    	
	    List<Address_vod__c> addressList = createAddressForAccount(acctList, 'Office');
	    
	    List<Stg_SFA_Cust_Can__c> stgCustList = createStagingHCPCustomerForSFDCAccountList(acctList);
		List<Stg_SFA_Cust_Addr_Can__c> stgCustsAddrs = createStagingCustomerAddrRecordForAddresses(stgCustList,addressList);
		
		Integer i = 0;
	    for(Address_vod__c addr : addressList) {
	    	addr.Roche_Address_Id_can__c = stgCustsAddrs[i].Roche_Addr_Id_can__c;
	    	if(i==0) {
	    		acctList[i].Roche_Id_can_gne__c = stgCustList[i].Roche_Cust_Id_can__c;
	    	}
	    	stgCustsAddrs[i].UAD_Ind_can__c = GNE_CAN_Subscribe_Util.UAD_INDICATOR_INSERT;
	    	i++;
	    }
	    
	    update acctList;
	    update addressList;
	    update stgCustsAddrs;
	    
	    runBatch(testUser, 'HCP');
		
		List<Address_vod__c> addrs = [select id from Address_vod__c];
		System.assertEquals (2, addrs.size());
		
		Stg_SFA_Cust_Can__c stgCust = [SELECT Subscribe_Status_can__c, Last_Subscribe_Date_can__c FROM Stg_SFA_Cust_Can__c WHERE Id = :stgCustList[0].Id];
    	System.assertEquals(GNE_CAN_Subscribe_Util.SUBSCRIBE_STATUS_FAILED_ON_ADDRESS, stgCust.Subscribe_Status_can__c, 'Subscribe Status != FAILED ON ADDRESS');
		System.assertNotEquals(null, stgCust.Last_Subscribe_Date_can__c, 'Last Subscribe Date not set');
		
		List<Stg_SFA_Subscribe_Apex_Job_Error__c> errors = getErrorsForStagingAddresses(stgCustsAddrs);
	    System.assertEquals( stgCustsAddrs.size(), errors.size());
	    
	    for(Stg_SFA_Subscribe_Apex_Job_Error__c error : errors) {
			System.assert(error.Error_Description_can__c.contains(GNE_CAN_Subscribe_Util.knownExceptionDescriptions.get(GNE_CAN_Subscribe_Util.KnownException.TARGET_ADDRESS_WITH_GIVEN_ROCHE_ID_ALREADY_EXISTS)));
		}
    }
    
    static testMethod void testUpdateIndicatorWithNoExistingAddress() {
    	User testUser = prepareEnv('true', 'true');
    	System.assertNotEquals(null,testUser);
    	
    	List<Account> acctList = createPersonAccountWithoutRocheId();    	    	
	    List<Address_vod__c> addressList = createAddressForAccount(acctList, 'Office');
	    
	    List<Stg_SFA_Cust_Can__c> stgCustList = createStagingHCPCustomerForSFDCAccountList(acctList);
		List<Stg_SFA_Cust_Addr_Can__c> stgCustsAddrs = createStagingCustomerAddrRecordWithNullAddrId(stgCustList);
		
		for(Stg_SFA_Cust_Addr_Can__c stgCustsAddr : stgCustsAddrs) {
	    	stgCustsAddr.UAD_Ind_can__c = GNE_CAN_Subscribe_Util.UAD_INDICATOR_UPDATE;
	    }
	    update stgCustsAddrs;
	    
	    runBatch(testUser, 'HCP');
		
		List<Address_vod__c> addrs = [select id from Address_vod__c];
		System.assertEquals (2, addrs.size());
		
		Stg_SFA_Cust_Can__c stgCust = [SELECT Subscribe_Status_can__c, Last_Subscribe_Date_can__c FROM Stg_SFA_Cust_Can__c WHERE Id = :stgCustList[0].Id];
    	System.assertEquals(GNE_CAN_Subscribe_Util.SUBSCRIBE_STATUS_FAILED_ON_ADDRESS, stgCust.Subscribe_Status_can__c, 'Subscribe Status != FAILED ON ADDRESS');
		System.assertNotEquals(null, stgCust.Last_Subscribe_Date_can__c, 'Last Subscribe Date not set');
		
		List<Stg_SFA_Subscribe_Apex_Job_Error__c> errors = getErrorsForStagingAddresses(stgCustsAddrs);
	    System.assertEquals( stgCustsAddrs.size(), errors.size());
	    
	    for(Stg_SFA_Subscribe_Apex_Job_Error__c error : errors) {
			System.assert(error.Error_Description_can__c.contains(GNE_CAN_Subscribe_Util.knownExceptionDescriptions.get(GNE_CAN_Subscribe_Util.KnownException.TARGET_ADDRESS_FOR_UPDATE_NOT_FOUND)));
		}
    }
    
    static testMethod void testNotValidIndicatorForAddress() {
    	User testUser = prepareEnv('true', 'true');
    	System.assertNotEquals(null,testUser);
    	
    	List<Account> acctList = createPersonAccountWithoutRocheId();    	    	
	    List<Address_vod__c> addressList = createAddressForAccount(acctList, 'Office');
	    
	    List<Stg_SFA_Cust_Can__c> stgCustList = createStagingHCPCustomerForSFDCAccountList(acctList);
		List<Stg_SFA_Cust_Addr_Can__c> stgCustsAddrs = createStagingCustomerAddrRecordWithNullAddrId(stgCustList);
		
		for(Stg_SFA_Cust_Addr_Can__c stgCustsAddr : stgCustsAddrs) {
	    	stgCustsAddr.UAD_Ind_can__c = 'Z';
	    }
	    update stgCustsAddrs;
	    
	    runBatch(testUser, 'HCP');
		
		List<Address_vod__c> addrs = [select id from Address_vod__c];
		System.assertEquals (2, addrs.size());
		
		Stg_SFA_Cust_Can__c stgCust = [SELECT Subscribe_Status_can__c, Last_Subscribe_Date_can__c FROM Stg_SFA_Cust_Can__c WHERE Id = :stgCustList[0].Id];
    	System.assertEquals(GNE_CAN_Subscribe_Util.SUBSCRIBE_STATUS_FAILED_ON_ADDRESS, stgCust.Subscribe_Status_can__c, 'Subscribe Status != FAILED ON ADDRESS');
		System.assertNotEquals(null, stgCust.Last_Subscribe_Date_can__c, 'Last Subscribe Date not set');
		
		List<Stg_SFA_Subscribe_Apex_Job_Error__c> errors = getErrorsForStagingAddresses(stgCustsAddrs);
	    System.assertEquals( stgCustsAddrs.size(), errors.size());
	    
	    for(Stg_SFA_Subscribe_Apex_Job_Error__c error : errors) {
			System.assert(error.Error_Description_can__c.contains(GNE_CAN_Subscribe_Util.knownExceptionDescriptions.get(GNE_CAN_Subscribe_Util.KnownException.ADDRESS_UAD_INDICATOR_NOT_VALID)));
		}
    }
    
    static testMethod void testSubscribeStatusOnFailedAddressPostalCode() {
    	User testUser = prepareEnv('true', 'true');
    	System.assertNotEquals(null,testUser);
    	
    	List<Stg_SFA_Cust_Can__c> stgCusts = createStagingHCPCustomerRecord(1);
    	List<Stg_SFA_Cust_Addr_Can__c> stgCustsAddrs = createStagingCustomerAddrRecordWithNullAddrId(stgCusts);
    	stgCustsAddrs.addAll(createStagingCustomerAddrRecordWithNullAddrId(stgCusts,1));
    	stgCustsAddrs[0].Postal_Code_can__c = null;
    	stgCustsAddrs[1].Postal_Code_can__c = '1B1';
    	update stgCustsAddrs;
    	
    	runBatch(testUser, 'HCP');
    	
    	system.assertEquals (0, [SELECT count() FROM Account]);
    	system.assertEquals (0, [SELECT count() FROM Address_vod__c]);
    	
    	Stg_SFA_Cust_Can__c stgCust = [SELECT Subscribe_Status_can__c, Last_Subscribe_Date_can__c FROM Stg_SFA_Cust_Can__c WHERE Id = :stgCusts[0].Id];
    	System.assertEquals(GNE_CAN_Subscribe_Util.SUBSCRIBE_STATUS_FAILED, stgCust.Subscribe_Status_can__c, 'Subscribe Status != FAILED');
		System.assertNotEquals(null, stgCust.Last_Subscribe_Date_can__c, 'Last Subscribe Date not set');
		
		List<Stg_SFA_Subscribe_Apex_Job_Error__c> errors = getErrorsForStagingCustomers(new List<Stg_SFA_Cust_Can__c>{stgCusts[0]});
	    System.assertEquals( 3, errors.size());
	    Set<String> errorDescs = new Set<String>();
	    for(Stg_SFA_Subscribe_Apex_Job_Error__c error : errors) {
	    	System.assert(error.Error_Description_can__c.contains(GNE_CAN_Subscribe_Util.knownExceptionDescriptions.get(GNE_CAN_Subscribe_Util.KnownException.ADDRESS_POSTAL_CODE_IS_NULL))
	    		|| error.Error_Description_can__c.contains(GNE_CAN_Subscribe_Util.knownExceptionDescriptions.get(GNE_CAN_Subscribe_Util.KnownException.ADDRESS_POSTAL_CODE_WRONG_VALUE))
	    		|| error.Error_Description_can__c.contains(GNE_CAN_Subscribe_Util.knownExceptionDescriptions.get(GNE_CAN_Subscribe_Util.KnownException.ACCOUNT_HAS_NO_VALID_ADDRESS)));
		}
	}
	
	static testMethod void testSubscribeStatusOnFailedOnlyOneAddress() {
    	User testUser = prepareEnv('true', 'true');
    	System.assertNotEquals(null,testUser);
    	
    	List<Stg_SFA_Cust_Can__c> stgCusts = createStagingHCPCustomerRecord(1);
    	List<Stg_SFA_Cust_Addr_Can__c> stgCustsAddrs = createStagingCustomerAddrRecordWithNullAddrId(stgCusts);
    	stgCustsAddrs.addAll(createStagingCustomerAddrRecordWithNullAddrId(stgCusts,1));
    	stgCustsAddrs[1].Postal_Code_can__c = '1B1';
    	stgCustsAddrs[1].Address_Line1_can__c = null;
    	update stgCustsAddrs[1];
    	
    	runBatch(testUser, 'HCP');
    	
    	system.assertEquals (1, [SELECT count() FROM Account]);
    	system.assertEquals (1, [SELECT count() FROM Address_vod__c]);
    	
    	Stg_SFA_Cust_Can__c stgCust = [SELECT Subscribe_Status_can__c, Last_Subscribe_Date_can__c FROM Stg_SFA_Cust_Can__c WHERE Id = :stgCusts[0].Id];
    	
		List<Stg_SFA_Subscribe_Apex_Job_Error__c> errors = getErrorsForStagingAddresses(new List<Stg_SFA_Cust_Addr_Can__c>{stgCustsAddrs[1]});
	    System.assertEquals( 2, errors.size());
	    Set<String> errorDescs = new Set<String>();
	    for(Stg_SFA_Subscribe_Apex_Job_Error__c error : errors) {
	    	System.assert(error.Error_Description_can__c.contains(GNE_CAN_Subscribe_Util.knownExceptionDescriptions.get(GNE_CAN_Subscribe_Util.KnownException.ADDRESS_NAME_IS_NULL))
	    		|| error.Error_Description_can__c.contains(GNE_CAN_Subscribe_Util.knownExceptionDescriptions.get(GNE_CAN_Subscribe_Util.KnownException.ADDRESS_POSTAL_CODE_WRONG_VALUE)));
		}
		
		assertAccounts(stgCusts,GNE_CAN_Subscribe_Util.SUBSCRIBE_STATUS_FAILED_ON_ADDRESS);
    	assertAddresses(new List<Stg_SFA_Cust_Addr_Can__c>{stgCustsAddrs[0]});
	}
	
	static testMethod void testCaseSensitiveFieldUpdate() {
    	User testUser = prepareEnv('true', 'true');
    	System.assertNotEquals(null,testUser);
    	
    	List<Stg_SFA_Cust_Can__c> stgCusts = createStagingHCPCustomerRecord(1);
    	List<Stg_SFA_Cust_Addr_Can__c> stgCustsAddrs = createStagingCustomerAddrRecordWithNullAddrId(stgCusts);
    	runBatch(testUser, 'HCP', false);
    	
    	List<Stg_SFA_Subscribe_Apex_Job_Error__c> errors = getErrorsForStagingAddresses(stgCustsAddrs);
    	
    	for(Stg_SFA_Subscribe_Apex_Job_Error__c error : errors) {
	    	System.assertEquals(null,error.Error_Description_can__c, 'No erros should be raised.');
		}
		
		List<Address_vod__c> addrs = [select id, Account_vod__c, City_vod__c from Address_vod__c];
	    
		for(Stg_SFA_Cust_Can__c stgCust : stgCusts) {
	    	stgCust.Subscribe_Status_can__c = null;
	    	stgCust.UAD_Ind_can__c = GNE_CAN_Subscribe_Util.UAD_INDICATOR_UPDATE;
	    	stgCust.Src_Cust_Id_can__c = addrs[0].Account_vod__c;
	    }
		
		for(Stg_SFA_Cust_Addr_Can__c stgCustsAddr : stgCustsAddrs) {
	    	stgCustsAddr.City_can__c = stgCustsAddr.City_can__c.toUpperCase();
	    	stgCustsAddr.UAD_Ind_can__c = GNE_CAN_Subscribe_Util.UAD_INDICATOR_UPDATE;
	    	stgCustsAddr.Src_Addr_Id_can__c = addrs[0].Id;
	    }
		
		System.assert(!stgCustsAddrs[0].City_can__c.equals(addrs[0].City_vod__c), 'Case Sensitive compare should return false');
		
	    update stgCusts;
	    update stgCustsAddrs;
	    
	    runBatch(testUser, 'HCP');
	    
	    errors = getErrorsForStagingAddresses(stgCustsAddrs);
	    
	    for(Stg_SFA_Subscribe_Apex_Job_Error__c error : errors) {
	    	System.assertEquals(null,error.Error_Description_can__c, 'No erros should be raised.');
		}
		
		addrs = [select id, City_vod__c from Address_vod__c];
		System.assertEquals(1, addrs.size());
		System.assert(stgCustsAddrs[0].City_can__c.equals(addrs[0].City_vod__c), 'Case Sensitive compare should return true');
		
		Stg_SFA_Cust_Can__c stgCust = [SELECT Subscribe_Status_can__c, Last_Subscribe_Date_can__c FROM Stg_SFA_Cust_Can__c WHERE Id = :stgCusts[0].Id];
    	System.assertEquals(GNE_CAN_Subscribe_Util.SUBSCRIBE_STATUS_SUCCESS, stgCust.Subscribe_Status_can__c, 'Subscribe Status != SUCCESS');
		System.assertNotEquals(null, stgCust.Last_Subscribe_Date_can__c, 'Last Subscribe Date not set');
	}
}