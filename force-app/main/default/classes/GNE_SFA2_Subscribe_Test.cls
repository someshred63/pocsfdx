@isTest
public with sharing class GNE_SFA2_Subscribe_Test {
	
	@testSetup 
	static void init() {
        String userExtId = 'uniqueemail@gene.com';
        User user = CORE_Subscribe_Test_Util.insertDefaultRecordOwner(userExtId);
        user.External_ID_gne__c = userExtId;
        update user;
        CORE_Subscribe_Test_Util.initCustomSettings();
        CORE_Subscribe_Test_Util.initMappingConfig(user.External_ID_gne__c);
        initPublishData();
	}    
    
	private static void initPublishData() {
		CORE_Pub_Party__c party = new CORE_Pub_Party__c(Party_Id_gne__c='1612170', MDM_Id_gne__c='2308068', Status_gne__c='R', FirstName_gne__c='MICHELLE', MiddleName_gne__c='LAM CHING-WEN', LastName_gne__c='CHU', Salutation_gne__c='Dr.', Suffix_gne__c='V', Gender_gne__c='F', PDRP_Opt_Out_gne__c='Y');
		party.Mdm_Updt_Date_gne__c = DateTime.newInstance(2015, 7, 12, 15, 20, 35);
		party.Birthdate_gne__c = Date.newInstance(1982, 1, 1);
		party.PDRP_Opt_Out_Date_gne__c = Date.newInstance(2014, 1, 14);
		party.Type_gne__c='IND';
		party.Prof_Type_json_gne__c = '[{"Code" : "MD"}, {"Code" : "CLNCL"}, {"Code" : "PSCR"}]';
		party.Education_json_gne__c = '[{"Code" : "MD"}, {"Code" : "LVT"}]';
		party.Comm_Channel_json_gne__c = '[{"Code" : "BUS_PHN", "Value" : "6505231432"}, {"Code" : "EML", "Value" : "test@test.com"}, {"Code" : "FAX",  "Value" : "5231234321"}]';
		party.Spend_Rest_json_gne__c = '[{ "Code": "MN"}, {"Code": "VT" }]';
		party.Credentials_json_gne__c = '[{"Code" : "MD"}, {"Code" : "MBA"}, {"Code" : "MPT"}]';
		party.Specialties_json_gne__c = '[{"Code" : "A"}, {"Code" : "DEN"}, {"Code" : "ACA"}]';
		party.Alt_Names_json_gne__c = '[{"Value" : "MICHELLE CHING-WEN LAM"}, {"Value" : "MICHELLE CHING-W CHU"}, {"Value" : "MICHELLE CHING-W LAM"}, {"Value" : "MICHELLE L CHU"} ]';
		party.Do_Not_Contact_gne__c = 'Y';
		insert party;
		
		CORE_Pub_Party__c party2 = new CORE_Pub_Party__c(Party_Id_gne__c='1682933', MDM_Id_gne__c='2439927', Status_gne__c='A', Org_Name_gne__c='POTOMAC CENTER FOR MEDICAL EDUCATION');
		party2.Mdm_Updt_Date_gne__c = DateTime.newInstance(2015, 7, 12, 15, 20, 35);
		party2.Type_gne__c='ORG';
		party2.Org_Type_json_gne__c = '[{"Code" : "MISC", "Value" : "Miscellaneous"}]';
		party2.Comm_Channel_json_gne__c = '[{"Code" : "BUS_PHN", "Value" : "6503231432",  "Extension" : "x123"}, {"Code" : "URL", "Value" : "www.google.com"}]';
		party2.Do_Not_Contact_gne__c = 'N';
		insert party2;
		
		CORE_Pub_Location__c location = new CORE_Pub_Location__c(Bldg_Desc_gne__c='BLDG 200', Bldg_Fl_Desc_gne__c='FL 2', City_gne__c='MODESTO', Country_gne__c='UNITED STATES', Default_gne__c=true, Latitude_gne__c='40.9183', Longitude_gne__c='-74.1443', MDM_Id_gne__c='55291861', MDM_Status_gne__c='A', Party_Id_gne__c='1612170', Party_Location_Id_gne__c='11301658', State_gne__c='CA', Street_gne__c='1541 FLORIDA AVE', Unit_Type_gne__c='STE', Unit_Value_gne__c='200', Zip_gne__c='95350');
		location.Comm_Chan_json_gne__c = '[{"Code" : "FAX", "Value" : "6502231432"}]';	
		location.Loc_Use_json_gne__c = '[{"Code" : "OFC"}, {"Code" : "DEA"}, {"Code" : "AMS_GOLD"}, {"Code" : "BUS"}]';
		
		CORE_Pub_Location__c location2 = new CORE_Pub_Location__c(Bldg_Desc_gne__c='BLDG 205', Bldg_Fl_Desc_gne__c='FL 2', City_gne__c='MODESTO', Country_gne__c='UNITED STATES', Default_gne__c=false, Latitude_gne__c='40.9183', Longitude_gne__c='-74.1433', MDM_Id_gne__c='55291843', MDM_Status_gne__c='A', Party_Id_gne__c='1612170', Party_Location_Id_gne__c='11301659', State_gne__c='CA', Street_gne__c='1541 SOUTH AVE', Unit_Type_gne__c='STE', Unit_Value_gne__c='205', Zip_gne__c='95354');
		location2.Comm_Chan_json_gne__c = '[{"Code" : "FAX", "Value" : "6502231465"}]';	
		location2.Loc_Use_json_gne__c = '[{"Code" : "OFC"}, {"Code" : "DEA"}, {"Code" : "BUS"}]';
		
		CORE_Pub_Location__c location3 = new CORE_Pub_Location__c(City_gne__c='COLUMBIA', Country_gne__c='UNITED STATES', Default_gne__c=true, Latitude_gne__c='39.1772', Longitude_gne__c='-76.87023', MDM_Id_gne__c='13737910', MDM_Status_gne__c='A', Party_Id_gne__c='1682933', Party_Location_Id_gne__c='3636340', State_gne__c='MD', Street_gne__c='8335 GUILFORD RD', Unit_Type_gne__c='STE', Unit_Value_gne__c='A', Zip_gne__c='21046', Zip_4_gne__c='7050');
		location3.Comm_Chan_json_gne__c = '[{"Code" : "BUS", "Value" :  "4103090690", "Extension" : "x123"}]';	
		location3.Loc_Use_json_gne__c = '[{"Code" : "AMS_GOLD"}, {"Code" : "BUS"}]';
		insert new List<CORE_Pub_Location__c>{location, location2, location3};
		
		CORE_Pub_License__c license = new CORE_Pub_License__c(Party_Id_gne__c='1612170', License_Number_gne__c='A115513', License_State_gne__c='CA', Grace_Period_gne__c='90', Designation_gne__c='MD', License_Status_gne__c='Valid', Smpl_Ovrl_Elig_Flag_gne__c='Y');
		license.Adj_Lic_Exp_Date_gne__c =  Date.newInstance(2017, 3, 31);
		license.Exp_Date_gne__c = Date.newInstance(2017, 12, 31);
		license.External_Id_gne__c = license.Party_Id_gne__c + license.License_Number_gne__c;  
		insert license; 
		
		CORE_Pub_License__c license2 = new CORE_Pub_License__c(Party_Id_gne__c='1612170', License_Number_gne__c='A115515', License_State_gne__c='CA', Grace_Period_gne__c='90', Designation_gne__c='MD', License_Status_gne__c='Valid', Smpl_Ovrl_Elig_Flag_gne__c='Y');
		license2.Adj_Lic_Exp_Date_gne__c =  Date.newInstance(2016, 3, 31);
		license2.Exp_Date_gne__c = Date.newInstance(2016, 12, 31);
		license2.External_Id_gne__c = license2.Party_Id_gne__c + license2.License_Number_gne__c;  
		insert license2;  
		
		List<CORE_Pub_External_Id__c>extIds = new List<CORE_Pub_External_Id__c>();
		extIds.add(new CORE_Pub_External_Id__c(Party_Id_gne__c='1612170', Ctrb_Src_gne__c='AMS', Ctrb_Src_Id_gne__c='6712852', Cnncl_Enty_Type_gne__c='PTY', External_Id_gne__c='1612170_6712852'));
		extIds.add(new CORE_Pub_External_Id__c(Party_Id_gne__c='1612170', Ctrb_Src_gne__c='BOT', Ctrb_Src_Id_gne__c='67128543', Cnncl_Enty_Type_gne__c='PTY', External_Id_gne__c='1612170_67128543'));
		
		extIds.add(new CORE_Pub_External_Id__c(Party_Id_gne__c='1612170', Ctrb_Src_gne__c='MDM', Ctrb_Src_Id_gne__c='2308068', Cnncl_Enty_Type_gne__c='PTY', External_Id_gne__c='1612170_2308068'));
		extIds.add(new CORE_Pub_External_Id__c(Party_Id_gne__c='1612170', Party_Location_Id_gne__c='11301658', Ctrb_Src_gne__c='MDM', Ctrb_Src_Id_gne__c='55291861', Cnncl_Enty_Type_gne__c='PTYLOC', External_Id_gne__c='11301658_55291861'));
		
		extIds.add(new CORE_Pub_External_Id__c(Party_Id_gne__c='1612170', Party_Location_Id_gne__c='11301659', Ctrb_Src_gne__c='MDM', Ctrb_Src_Id_gne__c='55291843', Cnncl_Enty_Type_gne__c='PTYLOC', External_Id_gne__c='11301659_55291843'));
		
		//extIds.add(new CORE_Pub_External_Id__c(Party_Id_gne__c='1612170', Party_Location_Id_gne__c='11301658', Ctrb_Src_gne__c='BOT', Ctrb_Src_Id_gne__c='55294341861', Cnncl_Enty_Type_gne__c='PTYLOC', External_Id_gne__c='11301658_55294341861'));
		
		extIds.add(new CORE_Pub_External_Id__c(Party_Id_gne__c='1682933', Ctrb_Src_gne__c='MDM', Ctrb_Src_Id_gne__c='2308077', Cnncl_Enty_Type_gne__c='PTY', External_Id_gne__c='1682933_2308077'));
		extIds.add(new CORE_Pub_External_Id__c(Party_Id_gne__c='1682933', Ctrb_Src_gne__c='TSG', Ctrb_Src_Id_gne__c='564555', Cnncl_Enty_Type_gne__c='PTY', External_Id_gne__c='1682933_564555'));
		extIds.add(new CORE_Pub_External_Id__c(Party_Id_gne__c='1682933', Party_Location_Id_gne__c='3636340', Ctrb_Src_gne__c='MDM', Ctrb_Src_Id_gne__c='55291862', Cnncl_Enty_Type_gne__c='PTYLOC', External_Id_gne__c='3636340_55291862'));
		//extIds.add(new CORE_Pub_External_Id__c(Party_Id_gne__c='1682933', Party_Location_Id_gne__c='3636340', Ctrb_Src_gne__c='BOT', Ctrb_Src_Id_gne__c='4363472', Cnncl_Enty_Type_gne__c='PTYLOC', External_Id_gne__c='11301658_4363472'));
		insert extIds; 
	}
	
    static testMethod void 	subscribeBase() {
    	Map<String, CORE_Pub_Party__c> parties = CORE_Subscribe_Test_Util.getParties();
    								
		CORE_Subscribe_Object__c subscribeObject = [SELECT id FROM CORE_Subscribe_Object__c];
		Core_Subscribe_Job__c subscribeJob = [SELECT id FROM Core_Subscribe_Job__c];
		
		Set<String>partyIds = new Set<String>();
		for (CORE_Pub_Party__c party: parties.values()) {
			partyIds.add(party.Party_Id_gne__c);
		} 
		    										
		Map<String, List<CORE_Subscribe_Mapping_Configuration__c>> mappingConfiguration = CORE_Subscribe_DAO.getMappingConfiguration(subscribeObject.id);    										
    	CORE_Subscribe_Metrics metrics = new CORE_Subscribe_Process().executeSubscribe(partyIds, subscribeJob.Id);
    	
    	for (CORE_Pub_Party__c party: [SELECT Comments_gne__c, Last_Sub_Exec_gne__c, Sub_Exec_Status_gne__c FROM CORE_Pub_Party__c]) {
    		System.assertEquals(null, party.Comments_gne__c);
    		System.assert(party.Last_Sub_Exec_gne__c != null);
    		System.assertEquals('Success', party.Sub_Exec_Status_gne__c);
    	}
    	
    	parties = CORE_Subscribe_Test_Util.getParties();
		
    	List<Account> accounts = getAccounts();
    	System.assertEquals(parties.size(), accounts.size());
    	
    	Map<String, Account>mdmToAccount = new Map<String, Account>();
    	for (Account account: accounts) {
    		mdmToAccount.put(account.MDMID_gne__c, account);
    	}
    	for (CORE_Pub_Party__c party: parties.values()) {
		    Account account = mdmToAccount.get(party.MDM_Id_gne__c);						
	    	System.assertEquals(party.MDM_Id_gne__c, account.MDMID_gne__c);
	    	System.assertEquals(party.Mdm_Updt_Date_gne__c, account.MDM_Update_Date_gne__c);
	    	System.assertEquals(party.Salutation_gne__c, account.Salutation);
	    	System.assertEquals(party.Suffix_gne__c, account.Suffix_vod__c);
	    	System.assertEquals(party.FirstName_gne__c, account.Firstname);
	    	System.assertEquals(party.MiddleName_gne__c, account.Middle_vod__c);
	    	System.assertEquals(party.LastName_gne__c, account.Lastname);
	    	System.assertEquals(party.Gender_gne__c, account.Gender_vod__c);
	    	
	    	if (party.MDM_Id_gne__c=='2308068') {
	    		System.assertEquals('Professional_vod', account.RecordType.developerName);
	    		System.assertEquals('Medical Doctor', account.Professional_Type_gne__c);
	    		System.assert(account.Alternate_Name_vod__c.contains('MICHELLE CHING-WEN LAM'));
	    		System.assertEquals('Retired', account.Status_gne__c);
	    		System.assertEquals('Inactive', account.MDMID_Status_gne__c);
	    		System.assertEquals('5231234321', account.Fax);
	    	}
	    	
	    	if (party.MDM_Id_gne__c=='2439927') {
	    		System.assertEquals('Practice_vod', account.RecordType.developerName);
	    		System.assertEquals('ams', account.Stewardship_System_Name_gne__c);
	    		System.assertEquals('Miscellaneous', account.Account_Type_gne__c);
	    		System.assertEquals('Active', account.MDMID_Status_gne__c);
	    		System.assertEquals('Active', account.Status_gne__c);
	    		System.assertEquals('www.google.com', account.Website);
	    	}
	    	//System.assertEquals(String.valueOf(party.Birthdate_gne__c), account.Date_of_Birth_gne__c);
	
	    	String credentials= CORE_Subscribe_Test_Util.getListValues(party.Credentials_json_gne__c, CORE_Subscribe_DAO.getCodeMapping('CORE_Pub_Prof_Typ__c', 'Value_gne__c'));
	    	String specialties= CORE_Subscribe_Test_Util.getListValues(party.Specialties_json_gne__c, CORE_Subscribe_DAO.getCodeMapping('CORE_Pub_Spcl_Typ__c', 'Value_gne__c'));
	    	String spendRestrictions = CORE_Subscribe_Test_Util.getListValuesForSpendRest(party.Spend_Rest_json_gne__c);
	    	//String profTypes= getListValues(party.Prof_Type_json_gne__c, getCodeMapping());
	    	
	    	System.assertEquals(party.PDRP_Opt_Out_gne__c=='Y', account.PDRP_Opt_Out_vod__c);
	    	System.assertEquals(party.PDRP_Opt_Out_Date_gne__c, account.PDRP_Opt_Out_Date_vod__c);
	    	
	    	System.assertEquals(credentials, account.Credentials_gne__c);
	    	System.assertEquals(specialties, account.Specialties_gne__c);
	    	System.assertEquals(spendRestrictions, account.Spend_Rest_gne__c);
    	}
    	
    	Map<Id, CORE_Pub_Location__c> locations = CORE_Subscribe_Test_Util.getPublishPartyLocations(parties.keySet());
    	List<Address_vod__c> addresses = [SELECT id, Name, City_vod__c, Latitude_vod__c, Longitude_vod__c, Country_vod__c, Country_gen__c, Zip_vod__c, Zip_4_vod__c, Address_Line_3_gne__c, MDM_Status_gne__c, MDM_Address_ID_gne__c,
    											Designation_gne__c, License_Expiration_Date_vod__c,  License_vod__c, License_Status_vod__c FROM Address_vod__c];
    	Map<String, Address_vod__c>mdmToAddress = new Map<String, Address_vod__c>();
    	for (Address_vod__c address: addresses) {
    		mdmToAddress.put(address.MDM_Address_ID_gne__c, address);
    	}
    	for (CORE_Pub_Location__c location: locations.values()) {
    		Address_vod__c address = mdmToAddress.get(location.MDM_Id_gne__c);
	    	System.assertEquals(location.Street_gne__c, address.Name);
	    	System.assertEquals(location.City_gne__c, address.City_vod__c);
	    	System.assertEquals(location.Country_gne__c, address.Country_gen__c);
	    	System.assertEquals(location.MDM_Id_gne__c, address.MDM_Address_ID_gne__c);
	    	System.assertEquals(Decimal.valueOf(location.Latitude_gne__c), address.Latitude_vod__c);
	    	System.assertEquals(Decimal.valueOf(location.Longitude_gne__c), address.Longitude_vod__c);
	    	String addressLine3 = null;
	    	if (!String.isEmpty(location.Bldg_Desc_gne__c)) {
	    		addressLine3 = location.Bldg_Desc_gne__c;
	    	}
	    	if (!String.isEmpty(location.Bldg_Fl_Desc_gne__c)) {
	    		addressLine3 += ' ' + location.Bldg_Fl_Desc_gne__c;
	    	}
	    	System.assertEquals(addressLine3, address.Address_Line_3_gne__c);
	    	
	    	if (location.MDM_Id_gne__c == '55291861') {
	    		System.assertEquals('A115513', address.License_vod__c);
	    		System.assertEquals('MD', address.Designation_gne__c);
	    		System.assertEquals('Valid', address.License_Status_vod__c);
	    		System.assertEquals(Date.newInstance(2017, 3, 31), address.License_Expiration_Date_vod__c);
	    	}
    	}
    	
    	List<Prescriber_License_gne__c> licenses = [SELECT name, Account_gne__c, License_Expiration_Date_gne__c, License_State_gne__c, License_Status_gne__c, License_Valid_To_Sample_gne__c FROM Prescriber_License_gne__c];
    	system.assertEquals(1, licenses.size());
    	
    	List<Account_External_Id_gne__c> accExternalIds = [SELECT Id, Name, Account_gne__c, Address_gne__c, MDMID_gne__c, Region_Code_gne__c, Third_Party_gne__c, Third_Party_Id_gne__c, Third_Party_Index_gne__c, Unique_Key_Calc_gne__c FROM Account_External_Id_gne__c];
    	List<Address_External_Id_gne__c> addressExternalIds = [SELECT Id, Name, Address_gne__c, Region_Code_gne__c, Third_Party_gne__c, Third_Party_Id_gne__c, Third_Party_Index_gne__c FROM Address_External_Id_gne__c];
    	Map<Id, CORE_Pub_External_Id__c> publishExternals = CORE_Subscribe_Test_Util.getPublishExternalIds(parties.keySet());
    	system.assertEquals(2, accExternalIds.size() + addressExternalIds.size());
    	
    	List<CORE_Pub_Party__c> processedParties = [SELECT Last_Sub_Exec_gne__c, Sub_Exec_Status_gne__c FROM CORE_Pub_Party__c];
    	for (CORE_Pub_Party__c party: processedParties) {
    		System.assert(party.Last_Sub_Exec_gne__c != null);
    		System.assertEquals('Success', party.Sub_Exec_Status_gne__c);
    	}
    }
    
    static List<Account> getAccounts() {
    	return [SELECT id, MDMID_gne__c, MDM_Update_Date_gne__c, Salutation, Suffix_vod__c, Firstname, Middle_vod__c, Lastname, Gender_vod__c, Date_of_Birth_gne__c, 
    									Credentials_gne__c, Specialties_gne__c, PDRP_Opt_Out_Date_vod__c, Professional_Type_gne__c, Status_gne__c, Spend_Rest_gne__c, MDMID_Status_gne__c, PDRP_Opt_Out_vod__c,
    									 RecordType.developerName, Alternate_Name_vod__c, Stewardship_System_Name_gne__c, Account_Type_gne__c, Pager_gne__c, Website, Fax FROM Account];
    }
    
    static testMethod void 	subscribeUpdateAccount() {
    	Account acc = new Account(MDMID_gne__c = '2308068', Firstname='MICHELLE', Lastname='CHU', Middle_vod__c='LAM CHING-WEN');
    	insert acc;
    	
		Map<String, CORE_Pub_Party__c> parties = CORE_Subscribe_Test_Util.getParties();
    	
		CORE_Subscribe_Object__c subscribeObject = [SELECT id FROM CORE_Subscribe_Object__c];
		Core_Subscribe_Job__c subscribeJob = [SELECT id FROM Core_Subscribe_Job__c];     										
		Map<String, List<CORE_Subscribe_Mapping_Configuration__c>> mappingConfiguration = CORE_Subscribe_DAO.getMappingConfiguration(subscribeObject.id);
		
		Set<String>partyIds = new Set<String>();
		for (CORE_Pub_Party__c party: parties.values()) {
			partyIds.add(party.Party_Id_gne__c);
		}
		    										
    	new CORE_Subscribe_Process().executeSubscribe(partyIds, subscribeJob.Id);

    	List<Account> accounts = getAccounts();
    	System.assertEquals(parties.size(), accounts.size());
    	
    	Map<String, Account>mdmToAccount = new Map<String, Account>();
    	for (Account account: accounts) {
    		mdmToAccount.put(account.MDMID_gne__c, account);
    	}
    	
    	for (CORE_Pub_Party__c party: parties.values()) {
		    Account account = mdmToAccount.get(party.MDM_Id_gne__c);
	    	System.assertEquals(party.MDM_Id_gne__c, account.MDMID_gne__c);
	    	System.assertEquals(party.Mdm_Updt_Date_gne__c, account.MDM_Update_Date_gne__c);
	    	System.assertEquals(party.Salutation_gne__c, account.Salutation);
	    	System.assertEquals(party.Suffix_gne__c, account.Suffix_vod__c);
	    	System.assertEquals(party.FirstName_gne__c, account.Firstname);
	    	System.assertEquals(party.MiddleName_gne__c, account.Middle_vod__c);
	    	System.assertEquals(party.LastName_gne__c, account.Lastname);
	    	System.assertEquals(party.Gender_gne__c, account.Gender_vod__c);
	    	//System.assertEquals(String.valueOf(party.Birthdate_gne__c), account.Date_of_Birth_gne__c);
	
	    	String credentials= CORE_Subscribe_Test_Util.getListValues(party.Credentials_json_gne__c, CORE_Subscribe_DAO.getCodeMapping('CORE_Pub_Prof_Typ__c', 'Value_gne__c'));
	    	String specialties= CORE_Subscribe_Test_Util.getListValues(party.Specialties_json_gne__c, CORE_Subscribe_DAO.getCodeMapping('CORE_Pub_Spcl_Typ__c', 'Value_gne__c'));
	    	//String profTypes= getListValues(party.Prof_Type_json_gne__c, getCodeMapping());
	    	
	    	System.assertEquals(party.PDRP_Opt_Out_gne__c=='Y', account.PDRP_Opt_Out_vod__c);
	    	System.assertEquals(party.PDRP_Opt_Out_Date_gne__c, account.PDRP_Opt_Out_Date_vod__c);
	    	
	    	System.assertEquals(credentials, account.Credentials_gne__c);
	    	System.assertEquals(specialties, account.Specialties_gne__c);
	    	//System.assertEquals(profTypes, account.Professional_Type_gne__c);
	    	
	    	if (party.MDM_Id_gne__c=='2308068') {
	    		System.assertEquals('Professional_vod', account.RecordType.developerName);
	    		System.assertEquals('Medical Doctor', account.Professional_Type_gne__c);
	    		System.assert(account.Alternate_Name_vod__c.contains('MICHELLE CHING-WEN LAM'));
	    		System.assertEquals('Retired', account.Status_gne__c);
	    		System.assertEquals('Inactive', account.MDMID_Status_gne__c);
	    	}
	    	
	    	if (party.MDM_Id_gne__c=='2439927') {
	    		System.assertEquals('Practice_vod', account.RecordType.developerName);
	    		System.assertEquals('ams', account.Stewardship_System_Name_gne__c);
	    		System.assertEquals('Miscellaneous', account.Account_Type_gne__c);
	    		System.assertEquals('Active', account.Status_gne__c);
	    		System.assertEquals('Active', account.MDMID_Status_gne__c);
	    	}
    	}
    }
    
    static testMethod void 	subscribeUpdateAddress() {
    	Account acc = new Account(MDMID_gne__c = '2308068', Firstname='MICHELLE', Lastname='CHU', Middle_vod__c='LAM CHING-WEN');
    	insert acc;
    	Address_vod__c add1 = new Address_vod__c(Account_vod__c=acc.Id, MDM_Address_ID_gne__c = '55291861', MDM_Status_gne__c='A', Name='1541 FLORIDA AVE', City_vod__c='MODESTO', State_vod__c='CA', Zip_vod__c='95350', Country_gen__c='UNITED STATES', Inactive_vod__c=false, Primary_vod__c=false);
    	Address_vod__c add2 = new Address_vod__c(Account_vod__c=acc.Id, MDM_Address_ID_gne__c = '55291843', MDM_Status_gne__c='A', Name='1541 SOUTH AVE', City_vod__c='MODESTO', State_vod__c='CA', Zip_vod__c='95354', Country_gen__c='UNITED STATES', Inactive_vod__c=false, Primary_vod__c=true);
    	insert new List<Address_vod__c>{add1, add2};
    	add1.Inactive_vod__c = true;
    	add1.Inactivate_Reason_gne__c = 'test';
    	//update add1;

		Map<String, CORE_Pub_Party__c> parties = CORE_Subscribe_Test_Util.getParties();
    	
		CORE_Subscribe_Object__c subscribeObject = [SELECT id FROM CORE_Subscribe_Object__c];
		Core_Subscribe_Job__c subscribeJob = [SELECT id FROM Core_Subscribe_Job__c];     										
		Map<String, List<CORE_Subscribe_Mapping_Configuration__c>> mappingConfiguration = CORE_Subscribe_DAO.getMappingConfiguration(subscribeObject.id);
		
		Set<String>partyIds = new Set<String>();
		for (CORE_Pub_Party__c party: parties.values()) {
			partyIds.add(party.Party_Id_gne__c);
		}
		    										
    	new CORE_Subscribe_Process().executeSubscribe(partyIds, subscribeJob.Id);

    	List<Account> accounts = getAccounts();
    	System.assertEquals(parties.size(), accounts.size());
    	
    	Map<String, Account>mdmToAccount = new Map<String, Account>();
    	for (Account account: accounts) {
    		mdmToAccount.put(account.MDMID_gne__c, account);
    	}
    	
    	for (CORE_Pub_Party__c party: parties.values()) {
		    Account account = mdmToAccount.get(party.MDM_Id_gne__c);
	    	System.assertEquals(party.MDM_Id_gne__c, account.MDMID_gne__c);
	    	System.assertEquals(party.Mdm_Updt_Date_gne__c, account.MDM_Update_Date_gne__c);
	    	System.assertEquals(party.Salutation_gne__c, account.Salutation);
	    	System.assertEquals(party.Suffix_gne__c, account.Suffix_vod__c);
	    	System.assertEquals(party.FirstName_gne__c, account.Firstname);
	    	System.assertEquals(party.MiddleName_gne__c, account.Middle_vod__c);
	    	System.assertEquals(party.LastName_gne__c, account.Lastname);
	    	System.assertEquals(party.Gender_gne__c, account.Gender_vod__c);
	    	//System.assertEquals(String.valueOf(party.Birthdate_gne__c), account.Date_of_Birth_gne__c);
	
	    	String credentials= CORE_Subscribe_Test_Util.getListValues(party.Credentials_json_gne__c, CORE_Subscribe_DAO.getCodeMapping('CORE_Pub_Prof_Typ__c', 'Value_gne__c'));
	    	String specialties= CORE_Subscribe_Test_Util.getListValues(party.Specialties_json_gne__c, CORE_Subscribe_DAO.getCodeMapping('CORE_Pub_Spcl_Typ__c', 'Value_gne__c'));
	    	//String profTypes= getListValues(party.Prof_Type_json_gne__c, getCodeMapping());
	    	
	    	System.assertEquals(party.PDRP_Opt_Out_gne__c=='Y', account.PDRP_Opt_Out_vod__c);
	    	System.assertEquals(party.PDRP_Opt_Out_Date_gne__c, account.PDRP_Opt_Out_Date_vod__c);
	    	
	    	System.assertEquals(credentials, account.Credentials_gne__c);
	    	System.assertEquals(specialties, account.Specialties_gne__c);
	    	//System.assertEquals(profTypes, account.Professional_Type_gne__c);
	    	
	    	if (party.MDM_Id_gne__c=='2308068') {
	    		System.assertEquals('Professional_vod', account.RecordType.developerName);
	    		System.assertEquals('Medical Doctor', account.Professional_Type_gne__c);
	    		System.assert(account.Alternate_Name_vod__c.contains('MICHELLE CHING-WEN LAM'));
	    		System.assertEquals('Retired', account.Status_gne__c);
	    		System.assertEquals('Inactive', account.MDMID_Status_gne__c);
	    	}
	    	
	    	if (party.MDM_Id_gne__c=='2439927') {
	    		System.assertEquals('Practice_vod', account.RecordType.developerName);
	    		System.assertEquals('ams', account.Stewardship_System_Name_gne__c);
	    		System.assertEquals('Miscellaneous', account.Account_Type_gne__c);
	    		System.assertEquals('Active', account.Status_gne__c);
	    		System.assertEquals('Active', account.MDMID_Status_gne__c);
	    	}
    	}
    	
    	
    	Map<Id, CORE_Pub_Location__c> locations = CORE_Subscribe_Test_Util.getPublishPartyLocations(parties.keySet());
    	List<Address_vod__c> addresses = [SELECT id, Name, City_vod__c, Latitude_vod__c, Longitude_vod__c, Country_vod__c, Country_gen__c, Zip_vod__c, Zip_4_vod__c, Address_Line_3_gne__c, MDM_Status_gne__c, MDM_Address_ID_gne__c,
    											Designation_gne__c, License_Expiration_Date_vod__c,  License_vod__c, License_Status_vod__c FROM Address_vod__c];
    											
		system.assertEquals(locations.size(), addresses.size());    											
    	Map<String, Address_vod__c>mdmToAddress = new Map<String, Address_vod__c>();
    	for (Address_vod__c address: addresses) {
    		mdmToAddress.put(address.MDM_Address_ID_gne__c, address);
    	}
    	for (CORE_Pub_Location__c location: locations.values()) {
    		Address_vod__c address = mdmToAddress.get(location.MDM_Id_gne__c);
	    	System.assertEquals(location.Street_gne__c, address.Name);
	    	System.assertEquals(location.City_gne__c, address.City_vod__c);
	    	System.assertEquals(location.Country_gne__c, address.Country_gen__c);
	    	System.assertEquals(location.MDM_Id_gne__c, address.MDM_Address_ID_gne__c);
	    	System.assertEquals(Decimal.valueOf(location.Latitude_gne__c), address.Latitude_vod__c);
	    	System.assertEquals(Decimal.valueOf(location.Longitude_gne__c), address.Longitude_vod__c);
	    	String addressLine3 = null;
	    	if (!String.isEmpty(location.Bldg_Desc_gne__c)) {
	    		addressLine3 = location.Bldg_Desc_gne__c;
	    	}
	    	if (!String.isEmpty(location.Bldg_Fl_Desc_gne__c)) {
	    		addressLine3 += ' ' + location.Bldg_Fl_Desc_gne__c;
	    	}
	    	
	    	if (location.MDM_Id_gne__c == '55291861') {
	    		System.assertEquals('A115513', address.License_vod__c);
	    		System.assertEquals('MD', address.Designation_gne__c);
	    		System.assertEquals('Valid', address.License_Status_vod__c);
	    		System.assertEquals(Date.newInstance(2017, 3, 31), address.License_Expiration_Date_vod__c);
	    	}
    	}
    }

    static testMethod void 	subscribeUpdatePatientAbassadorAccount(){
    	Account acc = new Account(MDMID_gne__c = '2308068', Firstname='MICHELLE', Lastname='CHU', Middle_vod__c='LAM CHING-WEN', Credentials_gne__c = 'NONC');
    	insert acc;
    	
		Map<String, CORE_Pub_Party__c> parties = CORE_Subscribe_Test_Util.getParties();
    	
		CORE_Subscribe_Object__c subscribeObject = [SELECT id FROM CORE_Subscribe_Object__c];
		Core_Subscribe_Job__c subscribeJob = [SELECT id FROM Core_Subscribe_Job__c];     										
		Map<String, List<CORE_Subscribe_Mapping_Configuration__c>> mappingConfiguration = CORE_Subscribe_DAO.getMappingConfiguration(subscribeObject.id);
		
		Set<String>partyIds = new Set<String>();
		for(CORE_Pub_Party__c party: parties.values()){
			if(party.MDM_Id_gne__c == '2308068') {
				partyIds.add(party.Party_Id_gne__c);
				party.Credentials_json_gne__c = '';
				party.Prof_Type_json_gne__c = '[{"Code":"HBP"},{"Code":"PATIENTAMB"}]';
				update party;
			}
		}
		    										
    	new CORE_Subscribe_Process().executeSubscribe(partyIds, subscribeJob.Id);

    	List<Account> accounts = getAccounts();
    	
    	Map<String, Account>mdmToAccount = new Map<String, Account>();
    	for(Account account: accounts){
    		mdmToAccount.put(account.MDMID_gne__c, account);
    	}
    	
    	for(CORE_Pub_Party__c party: parties.values()){
	    	if(party.MDM_Id_gne__c == '2308068'){
		    	Account account = mdmToAccount.get(party.MDM_Id_gne__c);						
	    		System.assertEquals('NONC', account.Credentials_gne__c);
	    		System.assertEquals('Patient Ambassador', account.Professional_Type_gne__c);
	    		System.assertEquals('ams', account.Stewardship_System_Name_gne__c);
	    		System.assertEquals('Contracted_Patient_gne', account.RecordType.developerName);
	    	}
    	}
    }
    
    static testMethod void subscribeError() {
    	CORE_Pub_Location__c location = [SELECT id, Longitude_gne__c FROM CORE_Pub_Location__c WHERE MDM_Id_gne__c='55291861'];
    	location.Longitude_gne__c='wrong value';
    	update location;
    	location = [SELECT id, Longitude_gne__c, Party_Id_gne__c FROM CORE_Pub_Location__c WHERE MDM_Id_gne__c='55291861'];
    	system.assertEquals('wrong value', location.Longitude_gne__c);
    	
		Map<String, CORE_Pub_Party__c> parties = CORE_Subscribe_Test_Util.getParties();
    	
		CORE_Subscribe_Object__c subscribeObject = [SELECT id FROM CORE_Subscribe_Object__c];   
		Core_Subscribe_Job__c subscribeJob = [SELECT id FROM Core_Subscribe_Job__c]; 										
		Map<String, List<CORE_Subscribe_Mapping_Configuration__c>> mappingConfiguration = CORE_Subscribe_DAO.getMappingConfiguration(subscribeObject.id);
		
		Set<String>partyIds = new Set<String>();
		for (CORE_Pub_Party__c party: parties.values()) {
			partyIds.add(party.Party_Id_gne__c);
		}
    	new CORE_Subscribe_Process().executeSubscribe(partyIds, subscribeJob.id);
    	
    	parties = CORE_Subscribe_Test_Util.getParties(); 
 
		for (CORE_Pub_Party__c party: parties.values()) {
    		System.assert(party.Last_Sub_Exec_gne__c != null);
			if (party.Party_Id_gne__c == location.Party_Id_gne__c) {
				system.assertEquals('Error', party.Sub_Exec_Status_gne__c);
			} else {
				system.assertEquals(null, party.Comments_gne__c);
    			system.assertEquals('Success', party.Sub_Exec_Status_gne__c);
			}
		}								
    }
    
    static testMethod void subscribeAsiMode() {
    	CORE_Subscribe_Object__c subscribeObject = [SELECT id FROM CORE_Subscribe_Object__c];
		Core_Subscribe_Job__c subscribeJob = [SELECT id FROM Core_Subscribe_Job__c];     	
    	Map<String, List<CORE_Subscribe_Mapping_Configuration__c>> mappingConfiguration = CORE_Subscribe_DAO.getMappingConfiguration(subscribeObject.id);

    	Map<String, Set<String>> partyIdToPartyLocIdMap = new Map<String, Set<String>>();
    	for (CORE_Pub_Location__c location:  [Select Party_Location_Id_gne__c, Party_Id_gne__c FROM CORE_Pub_Location__c]) {
    		if (!partyIdToPartyLocIdMap.containsKey(location.Party_Id_gne__c)) {
    			partyIdToPartyLocIdMap.put(location.Party_Id_gne__c, new Set<String>());
    		}
    		partyIdToPartyLocIdMap.get(location.Party_Id_gne__c).add(location.Party_Location_Id_gne__c);
    	}
    	new CORE_Subscribe_Process().executeSubscribe(partyIdToPartyLocIdMap, subscribeJob.id);
    	
    	Map<String, CORE_Pub_Party__c> parties = CORE_Subscribe_Test_Util.getParties();
		
    	List<Account> accounts = getAccounts();
    	System.assertEquals(parties.size(), accounts.size());
    	
    	Map<String, Account>mdmToAccount = new Map<String, Account>();
    	for (Account account: accounts) {
    		mdmToAccount.put(account.MDMID_gne__c, account);
    	}
    	for (CORE_Pub_Party__c party: parties.values()) {
		    Account account = mdmToAccount.get(party.MDM_Id_gne__c);						
	    	System.assertEquals(party.MDM_Id_gne__c, account.MDMID_gne__c);
	    	System.assertEquals(party.Mdm_Updt_Date_gne__c, account.MDM_Update_Date_gne__c);
	    	System.assertEquals(party.Salutation_gne__c, account.Salutation);
	    	System.assertEquals(party.Suffix_gne__c, account.Suffix_vod__c);
	    	System.assertEquals(party.FirstName_gne__c, account.Firstname);
	    	System.assertEquals(party.MiddleName_gne__c, account.Middle_vod__c);
	    	System.assertEquals(party.LastName_gne__c, account.Lastname);
	    	System.assertEquals(party.Gender_gne__c, account.Gender_vod__c);
	    	
	    	if (party.MDM_Id_gne__c=='2308068') {
	    		System.assertEquals('Professional_vod', account.RecordType.developerName);
	    		System.assertEquals('Medical Doctor', account.Professional_Type_gne__c);
	    		System.assert(account.Alternate_Name_vod__c.contains('MICHELLE CHING-WEN LAM'));
	    		System.assertEquals('Retired', account.Status_gne__c);
	    		System.assertEquals('Inactive', account.MDMID_Status_gne__c);
	    		System.assertEquals('5231234321', account.Fax);
	    	}
	    	
	    	if (party.MDM_Id_gne__c=='2439927') {
	    		System.assertEquals('Practice_vod', account.RecordType.developerName);
	    		System.assertEquals('ams', account.Stewardship_System_Name_gne__c);
	    		System.assertEquals('Miscellaneous', account.Account_Type_gne__c);
	    		System.assertEquals('Active', account.MDMID_Status_gne__c);
	    		System.assertEquals('Active', account.Status_gne__c);
	    		System.assertEquals('www.google.com', account.Website);
	    	}
	    	//System.assertEquals(String.valueOf(party.Birthdate_gne__c), account.Date_of_Birth_gne__c);
	
	    	String credentials= CORE_Subscribe_Test_Util.getListValues(party.Credentials_json_gne__c, CORE_Subscribe_DAO.getCodeMapping('CORE_Pub_Prof_Typ__c', 'Value_gne__c'));
	    	String specialties= CORE_Subscribe_Test_Util.getListValues(party.Specialties_json_gne__c, CORE_Subscribe_DAO.getCodeMapping('CORE_Pub_Spcl_Typ__c', 'Value_gne__c'));
	    	//String profTypes= getListValues(party.Prof_Type_json_gne__c, getCodeMapping());
	    	
	    	System.assertEquals(party.PDRP_Opt_Out_gne__c=='Y', account.PDRP_Opt_Out_vod__c);
	    	System.assertEquals(party.PDRP_Opt_Out_Date_gne__c, account.PDRP_Opt_Out_Date_vod__c);
	    	
	    	System.assertEquals(credentials, account.Credentials_gne__c);
	    	System.assertEquals(specialties, account.Specialties_gne__c);
	    	//System.assertEquals(profTypes, account.Professional_Type_gne__c);
    	}
    	
    	Map<Id, CORE_Pub_Location__c> locations = CORE_Subscribe_Test_Util.getPublishPartyLocations(parties.keySet());
    	List<Address_vod__c> addresses = [SELECT id, Name, City_vod__c, Latitude_vod__c, Longitude_vod__c, Country_vod__c, Country_gen__c, Zip_vod__c, Zip_4_vod__c, Address_Line_3_gne__c, MDM_Status_gne__c, MDM_Address_ID_gne__c,
    											Designation_gne__c, License_Expiration_Date_vod__c,  License_vod__c, License_Status_vod__c FROM Address_vod__c];
    	Map<String, Address_vod__c>mdmToAddress = new Map<String, Address_vod__c>();
    	for (Address_vod__c address: addresses) {
    		mdmToAddress.put(address.MDM_Address_ID_gne__c, address);
    	}
    	
    	for (CORE_Pub_Party__c party: parties.values()) {
    		system.assert(party.Last_Sub_Exec_gne__c != null);
			system.assertEquals(null, party.Comments_gne__c);
    		system.assertEquals('Success', party.Sub_Exec_Status_gne__c);
		}	
		
    	for (CORE_Pub_Location__c location: locations.values()) {
    		Address_vod__c address = mdmToAddress.get(location.MDM_Id_gne__c);
	    	System.assertEquals(location.Street_gne__c, address.Name);
	    	System.assertEquals(location.City_gne__c, address.City_vod__c);
	    	System.assertEquals(location.Country_gne__c, address.Country_gen__c);
	    	System.assertEquals(location.MDM_Id_gne__c, address.MDM_Address_ID_gne__c);
	    	System.assertEquals(Decimal.valueOf(location.Latitude_gne__c), address.Latitude_vod__c);
	    	System.assertEquals(Decimal.valueOf(location.Longitude_gne__c), address.Longitude_vod__c);
	    	String addressLine3 = null;
	    	if (!String.isEmpty(location.Bldg_Desc_gne__c)) {
	    		addressLine3 = location.Bldg_Desc_gne__c;
	    	}
	    	if (!String.isEmpty(location.Bldg_Fl_Desc_gne__c)) {
	    		addressLine3 += ' ' + location.Bldg_Fl_Desc_gne__c;
	    	}
	    	System.assertEquals(addressLine3, address.Address_Line_3_gne__c);
	    	
	    	if (location.MDM_Id_gne__c == '55291861') {
	    		System.assertEquals('A115513', address.License_vod__c);
	    		System.assertEquals('MD', address.Designation_gne__c);
	    		System.assertEquals('Valid', address.License_Status_vod__c);
	    		System.assertEquals(Date.newInstance(2017, 3, 31), address.License_Expiration_Date_vod__c);
	    	}
    	}
    	
    	List<Account_External_Id_gne__c> accExternalIds = [SELECT Id, Name, Account_gne__c, Address_gne__c, MDMID_gne__c, Region_Code_gne__c, Third_Party_gne__c, Third_Party_Id_gne__c, Third_Party_Index_gne__c, Unique_Key_Calc_gne__c FROM Account_External_Id_gne__c];
    	List<Address_External_Id_gne__c> addressExternalIds = [SELECT Id, Name, Address_gne__c, Region_Code_gne__c, Third_Party_gne__c, Third_Party_Id_gne__c, Third_Party_Index_gne__c FROM Address_External_Id_gne__c];
    	Map<Id, CORE_Pub_External_Id__c> publishExternals = CORE_Subscribe_Test_Util.getPublishExternalIds(parties.keySet());
    	system.assertEquals(2, accExternalIds.size() + addressExternalIds.size());
    	
    	List<CORE_Pub_Party__c> processedParties = [SELECT Last_Sub_Exec_gne__c, Sub_Exec_Status_gne__c FROM CORE_Pub_Party__c];
    	for (CORE_Pub_Party__c party: processedParties) {
    		System.assert(party.Last_Sub_Exec_gne__c != null);
    		System.assertEquals('Success', party.Sub_Exec_Status_gne__c);
    	}
    }
    
    static testMethod void fullSynchronizationTest() {
    	Account acc = new Account(MDMID_gne__c = '2308068', Firstname = 'MICHELLE', Lastname = 'CHU', Middle_vod__c = 'LAM CHING-WEN');
    	insert acc;
    	Prescriber_License_gne__c lic1 = new Prescriber_License_gne__c(name = 'Lic1_Test', Account_gne__c = acc.id, License_Expiration_Date_gne__c = Date.newInstance(2017, 2, 11), License_State_gne__c = 'CA', License_Status_gne__c='Valid_vod');
    	Prescriber_License_gne__c lic2 = new Prescriber_License_gne__c(name = 'Lic2_Test', Account_gne__c = acc.id, License_Expiration_Date_gne__c = Date.newInstance(2018, 2, 11), License_State_gne__c = 'WE', License_Status_gne__c='Valid_vod');
    	insert new List<Prescriber_License_gne__c> {lic1, lic2};
    	
    	
    	List<Prescriber_License_gne__c> licenses = [SELECT name, Account_gne__c, License_Expiration_Date_gne__c , License_State_gne__c, License_Status_gne__c, License_Valid_To_Sample_gne__c FROM Prescriber_License_gne__c];
    	System.assertEquals(2, licenses.size());

		Map<String, CORE_Pub_Party__c> parties = CORE_Subscribe_Test_Util.getParties();
    	
		CORE_Subscribe_Object__c subscribeObject = [SELECT id FROM CORE_Subscribe_Object__c];
		Core_Subscribe_Job__c subscribeJob = [SELECT id FROM Core_Subscribe_Job__c];     										
		
		Set<String>partyIds = new Set<String>();
		for (CORE_Pub_Party__c party: parties.values()) {
			partyIds.add(party.Party_Id_gne__c);
		}
		Test.startTest();
    	new CORE_Subscribe_Process().executeSubscribe(partyIds, subscribeJob.Id);

    	List<Account> accounts = getAccounts();
    	System.assertEquals(parties.size(), accounts.size());
    	
    	licenses = [SELECT name, Account_gne__c, License_Expiration_Date_gne__c , License_State_gne__c, License_Status_gne__c, License_Valid_To_Sample_gne__c FROM Prescriber_License_gne__c];
    	System.assertEquals(1, licenses.size());
    	System.assertEquals('A115513', licenses.get(0).Name);
		System.assertEquals('Valid_vod', licenses.get(0).License_Status_gne__c);
		System.assertEquals('CA', licenses.get(0).License_State_gne__c);
		System.assertEquals(Date.newInstance(2017, 3, 31), licenses.get(0).License_Expiration_Date_gne__c);
		
		delete [SELECT id FROM CORE_Pub_License__c];
		
		new CORE_Subscribe_Process().executeSubscribe(partyIds, subscribeJob.Id);
		
		String jobName = 'Test job2';
    	Core_Subscribe_Job__c subscribeJob2 = new Core_Subscribe_Job__c(Name= jobName, Status_gne__c='New', Subscribe_Object_gne__c = subscribeObject.Id);
    	insert subscribeJob2;
    	
    	new CORE_Subscribe_Process().executeSubscribe(partyIds, subscribeJob2.Id);
    	licenses = [SELECT name, Account_gne__c, License_Expiration_Date_gne__c , License_State_gne__c, License_Status_gne__c, License_Valid_To_Sample_gne__c FROM Prescriber_License_gne__c];
    	System.assertEquals(0, licenses.size());
    	Test.stopTest();
    }
}