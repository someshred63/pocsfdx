public class GNE_Subscribe_Process_TestDataPrepare {
	    
	public static final String PARTY_EXTERNAL_ID = 'someid';
    public static final String XREF_ID_BOT = 'botid';
    public static final String XREF_ID_PW = 'pwid';
    public static final String XREF_ID_SFDC = 'sfdcid';
    
    public static final String PARTY_LOCATION_MDMID_PW = 'locationidpw';
    public static final String XREF_ID_AMS = 'amsid';
    public static final String PARTY_TYPE_INDIVIDUAL = 'IND';
    public static final String PARTY_TYPE_ORGANIZATION = 'ORG';
    public static final String GENERATIONAL_SUFIX = 'gsufix';
    public static final String PROFESSIONAL_SUFIX = 'psufix';
    
    public static final String INDIVIDUAL_GENDER_VALUE = 'M';
    public static final String INDIVIDUAL_SALUTATION = 'Mr.';
    public static final String INDIVIDUAL_FIRST_NAME = 'Obi';
    public static final String INDIVIDUAL_MIDDLE_NAME = 'One';
    public static final String INDIVIDUAL_LAST_NAME = 'Kenobi';
    public static final Date INDIVIDUAL_BIRTH_DATE = Date.newInstance(1975, 2, 3);
    public static final String INDIVIDUAL_BIRTH_DATE_STR = '1975-2-3';
    
    public static final String ORG_NAME = 'POTOMAC CENTER FOR MEDICAL EDUCATION';
    
    public static final String LOCATION_EXTERNAL_ID = 'externalptylocid';
    public static final String LOCATION_PHYSICAL_ADDR_ID = 'phyaddrid';
    public static final String PHYSICAL_ADDR_PRIAMRY = 'PRIM ADDRESS';
    public static final String PHYSICAL_ADDR_CITY = 'Poznan';
    public static final String PHYSICAL_ADDR_NAME = 'physicaladdr';
    public static final String CANNONICAL_TYPE_PARTY = 'PTY';
    public static final String CANNONICAL_TYPE_LOCATION = 'PTYLOC';
    public static final String CONTRIBUTOR_SOURCE_BOT = 'BOT';
    public static final String CONTRIBUTOR_SOURCE_PW = 'PW';
    public static final String CONTRIBUTOR_SOURCE_SFDC = 'SFDC';
    public static final String CONTRIBUTOR_SOURCE_MDM = 'MDM';
    public static final String CONTRIBUTOR_SOURCE_AMS = 'AMS';
    public static final String POSTAL_AREA_NAME = 'postalarea';
    public static final String POSTAL_AREA_CODE = 'pstl';
    public static final String PROFESSIONAL_SUFIX_TYPE_DO = 'DO';
    public static final String PROFESSIONAL_SUFIX_TYPE_MD = 'MD';
    public static final String ACCOUNT_CREDENTIALS = 'DO;MD';
    public static final String ROLE_NURSE_PRACTITIONER = 'NRSPSCR';
    public static final String ROLE_PHARMACIST = 'PHARM';
    public static final String ROLE_SOCIAL_WORKER = 'SOCWK';
    public static final String ROLE_MEDICAL_DOCTOR = 'MD';
    public static final String SPECIALITY_1 = 'SPEC_1';
    public static final String SPECIALITY_2 = 'SPEC_2';
    public static final String COMM_CHANNEL_TYPE_CELL = 'CELL_PHN';
    public static final String COMM_CHANNEL_TYPE_URL = 'URL';
    public static final String COMM_CHANNEL_TYPE_PHONE = 'BUS_PHN';
    public static final String COMM_CHANNEL_TYPE_FAX = 'FAX';
    public static final String CELL_PHONE = '+48 345 432 111';
    public static final String PHONE = '+48 14 728 42 91';
    public static final String PHONE2 = '1234567890';
    public static final String PHONE3 = '12345';
    public static final String FAX_NUM = '6233628867';
    public static final String STATE_PROVINCE = 'state/province';
    public static final String COUNTRY = 'POLAND';
    public static final String COUNTRY_DEFAULT = 'UNITED STATES';
    public static final String COUNTRY_CODE = 'PL';
    public static final String USAGE_TYPE_GOLD = 'AMS_GOLD';
    public static final String USAGE_TYPE_SHIP = 'SHIP';
    public static final String USAGE_TYPE_MAIL = 'MAIL';
    public static final String USAGE_TYPE_BILL = 'BILL';
    public static final String USAGE_TYPE_BUS = 'BUS';
    public static final String USAGE_TYPE_OFC = 'OFC';
    public static final String USAGE_TYPE_HOSP = 'HOSP';
    public static final String SECONDARY_ADDRESS_UNIT_TYPE_CODE = 'sautc';
    public static final String SECONDARY_ADDRESS_VALUE = 'sav';
    public static final String BLDG_DESC = 'BldgDesc';
    public static final String BLDG_FL_DESC = 'BldgFlDesc';
    public static final String ORGANIZATION_NAME = 'orgname';
    public static final String ORGANIZATION_ROLE_TYPE_HBO = 'HBO';
    public static final String ORGANIZATION_ROLE_TYPE_HOSP = 'HOSP';
    public static final String ORGANIZATION_WEBSITE = 'http://website.com';
    public static final String LICENSE_NUMBER = 'sdjkfhlk513l452345';
    public static final String LICENSE_NUMBER2 = 'sdjkfhlk513l4523452';
    public static final String LICENSE_NUMBER3 = 'sdjkfhlk513l4523453';
    public static final String DESIGNATION_DESCR = 'designation descr';
    public static final String DESIGNATION_CODE = 'designation code';
    
    
    public static final String PARTY_ID_1 = '1612170';
    public static final String PARTY_LOCATION_ID_1 = '15615484';
    public static final String PARTY_MDMID = '564645545';
    public static final String PARTY_LOCATION_MDMID = '41121515';

	public static final String PARTY_ID_2 = '1682933';
    public static final String PARTY_LOCATION_ID_2 = '3636340';    
    public static final String PARTY_MDMID_2 = '2439927';
    public static final String PARTY_LOCATION_MDMID_2 = '13737910';
    
    public void insertPartyStructureForSubscribeUpdate() {
    	insertPartyStructureForSubscribeCreate();
    }
    
    public void insertPartyStructureForSubscribeCreate() {
    	CORE_Pub_Party__c party = new CORE_Pub_Party__c(Party_Id_gne__c=PARTY_ID_1, MDM_Id_gne__c=PARTY_MDMID, Status_gne__c='R', FirstName_gne__c=INDIVIDUAL_FIRST_NAME, MiddleName_gne__c=INDIVIDUAL_MIDDLE_NAME, LastName_gne__c=INDIVIDUAL_LAST_NAME, Salutation_gne__c=INDIVIDUAL_SALUTATION, Suffix_gne__c='V', Gender_gne__c=INDIVIDUAL_GENDER_VALUE, PDRP_Opt_Out_gne__c='Y');
		party.Mdm_Updt_Date_gne__c = DateTime.newInstance(2015, 7, 12, 15, 20, 35);
		party.Birthdate_gne__c = INDIVIDUAL_BIRTH_DATE;
		party.PDRP_Opt_Out_Date_gne__c = Date.newInstance(2014, 1, 14);
		party.Type_gne__c='IND';
		party.Prof_Type_json_gne__c = '[{"Code" : "MD"}, {"Code" : "CLNCL"}, {"Code" : "PSCR"}]';
		party.Education_json_gne__c = '[{"Code" : "MD"}, {"Code" : "LVT"}]';
		party.Comm_Channel_json_gne__c = '[{"Code" : "BUS_PHN", "Value" : "6505231432"}, {"Code" : "EML", "Value" : "test@test.com"}, {"Code" : "FAX",  "Value" : "5231234321"}]';
		party.Credentials_json_gne__c = '[{"Code" : "MD"}, {"Code" : "MBA"}, {"Code" : "MPT"}]';
		party.Specialties_json_gne__c = '[{"Code" : "A"}, {"Code" : "DEN"}, {"Code" : "ACA"}]';
		party.Alt_Names_json_gne__c = '[{"Value" : "MICHELLE CHING-WEN LAM"}, {"Value" : "MICHELLE CHING-W CHU"}, {"Value" : "MICHELLE CHING-W LAM"}, {"Value" : "MICHELLE L CHU"} ]';
		party.Do_Not_Contact_gne__c = 'Y';
		insert party;
		
		CORE_Pub_Party__c party2 = new CORE_Pub_Party__c(Party_Id_gne__c=PARTY_ID_2, MDM_Id_gne__c=PARTY_MDMID_2, Status_gne__c='A', Org_Name_gne__c=ORG_NAME);
		party2.Mdm_Updt_Date_gne__c = DateTime.newInstance(2015, 7, 12, 15, 20, 35);
		party2.Type_gne__c='ORG';
		party2.Org_Type_json_gne__c = '[{"Code" : "'+ORGANIZATION_ROLE_TYPE_HOSP+'", "Value" : "Miscellaneous"}]';
		party2.Comm_Channel_json_gne__c = '[{"Code" : "BUS_PHN", "Value" : "6503231432",  "Extension" : "x123"}, {"Code" : "URL", "Value" : "www.google.com"}]';
		party2.Do_Not_Contact_gne__c = 'N';
		insert party2;
		
		CORE_Pub_Location__c location = new CORE_Pub_Location__c(Bldg_Desc_gne__c='BLDG 200', Bldg_Fl_Desc_gne__c='FL 2', City_gne__c='MODESTO', Country_gne__c='UNITED STATES', Default_gne__c=true, Latitude_gne__c='40.9183', Longitude_gne__c='-74.1443', MDM_Id_gne__c=PARTY_LOCATION_MDMID, MDM_Status_gne__c='A', Party_Id_gne__c=PARTY_ID_1, Party_Location_Id_gne__c=PARTY_LOCATION_ID_1, State_gne__c='CA', Street_gne__c='1541 FLORIDA AVE', Unit_Type_gne__c='STE', Unit_Value_gne__c='200', Zip_gne__c='95350');
		location.Comm_Chan_json_gne__c = '[{"Code" : "FAX", "Value" : "6502231432"}]';	
		location.Loc_Use_json_gne__c = '[{"Code" : "OFC"}, {"Code" : "DEA"}, {"Code" : "AMS_GOLD"}, {"Code" : "BUS"}]';
		
		CORE_Pub_Location__c location2 = new CORE_Pub_Location__c(Bldg_Desc_gne__c='BLDG 205', Bldg_Fl_Desc_gne__c='FL 2', City_gne__c='MODESTO', Country_gne__c='UNITED STATES', Default_gne__c=false, Latitude_gne__c='40.9183', Longitude_gne__c='-74.1433', MDM_Id_gne__c='55291843', MDM_Status_gne__c='A', Party_Id_gne__c=PARTY_ID_1, Party_Location_Id_gne__c='11301659', State_gne__c='CA', Street_gne__c='1541 SOUTH AVE', Unit_Type_gne__c='STE', Unit_Value_gne__c='205', Zip_gne__c='95354');
		location2.Comm_Chan_json_gne__c = '[{"Code" : "FAX", "Value" : "6502231465"}]';	
		location2.Loc_Use_json_gne__c = '[{"Code" : "OFC"}, {"Code" : "DEA"}, {"Code" : "BUS"}]';
		
		CORE_Pub_Location__c location3 = new CORE_Pub_Location__c(City_gne__c='COLUMBIA', Country_gne__c='UNITED STATES', Default_gne__c=true, Latitude_gne__c='39.1772', Longitude_gne__c='-76.87023', MDM_Id_gne__c=PARTY_LOCATION_MDMID_2, MDM_Status_gne__c='A', Party_Id_gne__c=PARTY_ID_2, Party_Location_Id_gne__c=PARTY_LOCATION_ID_2, State_gne__c='MD', Street_gne__c='8335 GUILFORD RD', Unit_Type_gne__c='STE', Unit_Value_gne__c='A', Zip_gne__c='21046', Zip_4_gne__c='7050');
		location3.Comm_Chan_json_gne__c = '[{"Code" : "BUS", "Value" :  "4103090690", "Extension" : "x123"}]';	
		location3.Loc_Use_json_gne__c = '[{"Code" : "AMS_GOLD"}, {"Code" : "BUS"}]';
		insert new List<CORE_Pub_Location__c>{location, location2, location3};
		
		CORE_Pub_License__c license = new CORE_Pub_License__c(Party_Id_gne__c=PARTY_ID_1, License_Number_gne__c='A115513', License_State_gne__c='CA', Grace_Period_gne__c='90', Designation_gne__c='MD', License_Status_gne__c='Valid', Smpl_Ovrl_Elig_Flag_gne__c='Y');
		license.Adj_Lic_Exp_Date_gne__c =  Date.newInstance(2017, 3, 31);
		license.Exp_Date_gne__c = Date.newInstance(2017, 12, 31);
		license.External_Id_gne__c = license.Party_Id_gne__c + license.License_Number_gne__c;  
		insert license; 
		
		CORE_Pub_License__c license2 = new CORE_Pub_License__c(Party_Id_gne__c=PARTY_ID_1, License_Number_gne__c='A115515', License_State_gne__c='CA', Grace_Period_gne__c='90', Designation_gne__c='MD', License_Status_gne__c='Valid', Smpl_Ovrl_Elig_Flag_gne__c='Y');
		license2.Adj_Lic_Exp_Date_gne__c =  Date.newInstance(2016, 3, 31);
		license2.Exp_Date_gne__c = Date.newInstance(2016, 12, 31);
		license2.External_Id_gne__c = license2.Party_Id_gne__c + license2.License_Number_gne__c;  
		insert license2;  
		
		List<CORE_Pub_External_Id__c>extIds = new List<CORE_Pub_External_Id__c>();
		extIds.add(new CORE_Pub_External_Id__c(Party_Id_gne__c=PARTY_ID_1, Ctrb_Src_gne__c='AMS', Ctrb_Src_Id_gne__c='6712852', Cnncl_Enty_Type_gne__c='PTY', External_Id_gne__c = PARTY_ID_1 + '_6712852'));
		extIds.add(new CORE_Pub_External_Id__c(Party_Id_gne__c=PARTY_ID_1, Ctrb_Src_gne__c='BOT', Ctrb_Src_Id_gne__c='67128543', Cnncl_Enty_Type_gne__c='PTY', External_Id_gne__c = PARTY_ID_1 + '_67128543'));
		
		extIds.add(new CORE_Pub_External_Id__c(Party_Id_gne__c=PARTY_ID_1, Ctrb_Src_gne__c='MDM', Ctrb_Src_Id_gne__c=PARTY_MDMID, Cnncl_Enty_Type_gne__c='PTY', External_Id_gne__c = PARTY_ID_1 + '_' + PARTY_MDMID));
		extIds.add(new CORE_Pub_External_Id__c(Party_Id_gne__c=PARTY_ID_1, Party_Location_Id_gne__c=PARTY_LOCATION_ID_1, Ctrb_Src_gne__c='MDM', Ctrb_Src_Id_gne__c=PARTY_LOCATION_MDMID, Cnncl_Enty_Type_gne__c='PTYLOC', External_Id_gne__c=PARTY_LOCATION_ID_1 + '_'+PARTY_LOCATION_MDMID));
		
		extIds.add(new CORE_Pub_External_Id__c(Party_Id_gne__c=PARTY_ID_1, Party_Location_Id_gne__c='11301659', Ctrb_Src_gne__c='MDM', Ctrb_Src_Id_gne__c='55291843', Cnncl_Enty_Type_gne__c='PTYLOC', External_Id_gne__c='11301659_55291843'));
		
		//extIds.add(new CORE_Pub_External_Id__c(Party_Id_gne__c=PARTY_ID_1, Party_Location_Id_gne__c=PARTY_LOCATION_ID_1, Ctrb_Src_gne__c='BOT', Ctrb_Src_Id_gne__c='55294341861', Cnncl_Enty_Type_gne__c='PTYLOC', External_Id_gne__c=PARTY_LOCATION_ID_1_+'55294341861'));
		
		extIds.add(new CORE_Pub_External_Id__c(Party_Id_gne__c=PARTY_ID_2, Ctrb_Src_gne__c='MDM', Ctrb_Src_Id_gne__c=PARTY_MDMID_2, Cnncl_Enty_Type_gne__c='PTY', External_Id_gne__c=PARTY_ID_2 + '_' + PARTY_MDMID_2));
		extIds.add(new CORE_Pub_External_Id__c(Party_Id_gne__c=PARTY_ID_2, Ctrb_Src_gne__c='TSG', Ctrb_Src_Id_gne__c='564555', Cnncl_Enty_Type_gne__c='PTY', External_Id_gne__c=PARTY_ID_2+'_564555'));
		extIds.add(new CORE_Pub_External_Id__c(Party_Id_gne__c=PARTY_ID_2, Party_Location_Id_gne__c=PARTY_LOCATION_ID_2, Ctrb_Src_gne__c='MDM', Ctrb_Src_Id_gne__c=PARTY_LOCATION_MDMID_2, Cnncl_Enty_Type_gne__c='PTYLOC', External_Id_gne__c=PARTY_LOCATION_ID_2 + '_'+PARTY_LOCATION_MDMID_2));
		extIds.add(new CORE_Pub_External_Id__c(Party_Id_gne__c=PARTY_ID_2, Party_Location_Id_gne__c=PARTY_LOCATION_ID_2, Ctrb_Src_gne__c='BOT', Ctrb_Src_Id_gne__c='4363472', Cnncl_Enty_Type_gne__c='PTYLOC', External_Id_gne__c=PARTY_LOCATION_ID_2+'4363472'));
		insert extIds; 
    }
}