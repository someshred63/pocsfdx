@isTest
public with sharing class CORE_Subscribe_Trigger_Test {
	
	@testSetup 
	static void init() {
        initPublishData();
	}    
	
	private static void initPublishData(){
		CORE_Pub_Party__c party = new CORE_Pub_Party__c(Party_Id_gne__c='1612170', MDM_Id_gne__c='2308068', Status_gne__c='A', FirstName_gne__c='MICHELLE', MiddleName_gne__c='LAM CHING-WEN', LastName_gne__c='CHU', Salutation_gne__c='Dr.', Suffix_gne__c='V', Gender_gne__c='F', PDRP_Opt_Out_gne__c='Y');
		party.Mdm_Updt_Date_gne__c = DateTime.newInstance(2015, 7, 12, 15, 20, 35);
		party.Birthdate_gne__c = Date.newInstance(1982, 1, 1);
		party.PDRP_Opt_Out_Date_gne__c = Date.newInstance(2014, 1, 14);
		party.Type_gne__c='IND';
		party.Prof_Type_json_gne__c = '[{"Code" : "MD"}, {"Code" : "CLNCL"}, {"Code" : "PSCR"}]';
		party.Education_json_gne__c = '[{"Code" : "MD"}, {"Code" : "LVT"}]';
		party.Comm_Channel_json_gne__c = '[{"Code" : "BUS_PHN", "Value" : "6505231432"}, {"Code" : "EML", "Value" : "test@test.com"}, {"Code" : "PGR",  "Value" : "5231234321"}]';
		party.Credentials_json_gne__c = '[{"Code" : "MD"}, {"Code" : "MBA"}, {"Code" : "MPT"}]';
		party.Specialties_json_gne__c = '[{"Code" : "A"}, {"Code" : "DEN"}, {"Code" : "ACA"}]';
		party.Alt_Names_json_gne__c = '[{"Value" : "MICHELLE CHING-WEN LAM"}, {"Value" : "MICHELLE CHING-W CHU"}, {"Value" : "MICHELLE CHING-W LAM"}, {"Value" : "MICHELLE L CHU"} ]';
		party.Do_Not_Contact_gne__c = 'Y';
		insert party;
		
		CORE_Pub_Party__c party2 = new CORE_Pub_Party__c(Party_Id_gne__c='1682933', MDM_Id_gne__c='2439927', Status_gne__c='I', Org_Name_gne__c='POTOMAC CENTER FOR MEDICAL EDUCATION');
		party2.Mdm_Updt_Date_gne__c = DateTime.newInstance(2015, 7, 12, 15, 20, 35);
		party2.Type_gne__c='ORG';
		party2.Org_Type_json_gne__c = '[{"Code" : "MISC", "Value" : "Miscellaneous"}]';
		party2.Comm_Channel_json_gne__c = '[{"Code" : "BUS_PHN", "Value" : "6503231432",  "Extension" : "x123"}, {"Code" : "URL", "Value" : "www.google.com"}]';
		party2.Do_Not_Contact_gne__c = 'N';
		insert party2;
		
		CORE_Pub_Location__c location = new CORE_Pub_Location__c(Bldg_Desc_gne__c='BLDG 200', Bldg_Fl_Desc_gne__c='FL 2', City_gne__c='MODESTO', Country_gne__c='UNITED STATES', Default_gne__c=true, Latitude_gne__c='40.9183', Longitude_gne__c='-74.1443', MDM_Id_gne__c='55291861', MDM_Status_gne__c='A', Party_Id_gne__c='1612170', Party_Location_Id_gne__c='11301658', State_gne__c='CA', Street_gne__c='1541 FLORIDA AVE', Unit_Type_gne__c='STE', Unit_Value_gne__c='200', Zip_gne__c='95350');
		location.Comm_Chan_json_gne__c = '[{"Code" : "FAX", "Value" : "6502231432"}]';	
		location.Loc_Use_json_gne__c = '[{"Code" : "OFC"}, {"Code" : "DEA"}, {"Code" : "AMS_GOLD"}, {"Code" : "BUS"}]';
		
		CORE_Pub_Location__c location2 = new CORE_Pub_Location__c(City_gne__c='COLUMBIA', Country_gne__c='UNITED STATES', Default_gne__c=true, Latitude_gne__c='39.1772', Longitude_gne__c='-76.87023', MDM_Id_gne__c='13737910', MDM_Status_gne__c='A', Party_Id_gne__c='1682933', Party_Location_Id_gne__c='3636340', State_gne__c='MD', Street_gne__c='8335 GUILFORD RD', Unit_Type_gne__c='STE', Unit_Value_gne__c='A', Zip_gne__c='21046', Zip_4_gne__c='7050');
		location2.Comm_Chan_json_gne__c = '[{"Code" : "BUS", "Value" :  "4103090690", "Extension" : "x123"}]';	
		location2.Loc_Use_json_gne__c = '[{"Code" : "AMS_GOLD"}, {"Code" : "BUS"}]';
		insert new List<CORE_Pub_Location__c>{location, location2};
		
		CORE_Pub_License__c license = new CORE_Pub_License__c(Party_Id_gne__c='1612170', License_Number_gne__c='A115513', License_State_gne__c='CA', Grace_Period_gne__c='90', Designation_gne__c='MD', License_Status_gne__c='Valid', Smpl_Ovrl_Elig_Flag_gne__c='Y');
		license.Adj_Lic_Exp_Date_gne__c =  Date.newInstance(2017, 3, 31);
		license.Exp_Date_gne__c = Date.newInstance(2017, 12, 31);
		license.External_Id_gne__c = license.Party_Id_gne__c + license.License_Number_gne__c;  
		insert license; 
		
		List<CORE_Pub_External_Id__c>extIds = new List<CORE_Pub_External_Id__c>();
		extIds.add(new CORE_Pub_External_Id__c(Party_Id_gne__c='1612170', Ctrb_Src_gne__c='AMS', Ctrb_Src_Id_gne__c='6712852', Cnncl_Enty_Type_gne__c='PTY', External_Id_gne__c='1612170_6712852'));
		extIds.add(new CORE_Pub_External_Id__c(Party_Id_gne__c='1612170', Ctrb_Src_gne__c='MDM', Ctrb_Src_Id_gne__c='2308068', Cnncl_Enty_Type_gne__c='PTY', External_Id_gne__c='1612170_2308068'));
		extIds.add(new CORE_Pub_External_Id__c(Party_Id_gne__c='1612170', Party_Location_Id_gne__c='11301658', Ctrb_Src_gne__c='MDM', Ctrb_Src_Id_gne__c='55291861', Cnncl_Enty_Type_gne__c='PTYLoc', External_Id_gne__c='11301658_55291861'));
		
		extIds.add(new CORE_Pub_External_Id__c(Party_Id_gne__c='1682933', Ctrb_Src_gne__c='MDM', Ctrb_Src_Id_gne__c='2308077', Cnncl_Enty_Type_gne__c='PTY', External_Id_gne__c='1682933_2308077'));
		extIds.add(new CORE_Pub_External_Id__c(Party_Id_gne__c='1682933', Party_Location_Id_gne__c='3636340', Ctrb_Src_gne__c='MDM', Ctrb_Src_Id_gne__c='55291862', Cnncl_Enty_Type_gne__c='PTYLoc', External_Id_gne__c='3636340_55291862'));
		insert extIds; 
		
		
		List<CORE_Pub_Plan_Product__c>products = new List<CORE_Pub_Plan_Product__c>();
		CORE_Pub_Plan_Product__c productPlan =  new CORE_Pub_Plan_Product__c(Party_Id_gne__c = '1612170', Pln_Prodt_Id_gne__c='16738', Pln_Prodt_Nm_gne__c = 'HEALTH NET SENIORITY PLUS AMBER I (HMO)',  Pln_Prodt_Typ_gne__c ='ACCS_PLS', Hlth_Pln_Typ_gne__c = 'CASH', Pln_Prodt_Model_Typ_gne__c = 'PPO', Pln_Prodt_Lv_Cnt_gne__c = 1857, Pln_Prodt_W_Phmcy_BenLv_Cnt_gne__c = 1857,  Mdcr_Pdp_Intr_Flag_gne__c = true, Mdcr_Sctr_Flag_gne__c = false);
		productPlan.Pln_Prodt_Start_Dt_gne__c =  Date.newInstance(2009, 1, 31);
		productPlan.Pln_Prodt_End_Dt_gne__c =  Date.newInstance(2011, 2, 3);
		productPlan.CADS_Pln_Prodt_Id_gne__c = 'uyou329034';
		products.add(productPlan);
		insert products;
	}
    
	static testMethod void populateLookupFieldsTest(){
		Map<String, Id>partyIdToSfdcId = new Map<String, Id>();
		for(CORE_Pub_Party__c party: [SELECT Id, Party_Id_gne__c FROM CORE_Pub_Party__c]){
			partyIdToSfdcId.put(party.Party_Id_gne__c, party.Id);
		}
		Map<String, Id>partyLocIdToSfdcId = new Map<String, Id>();
		for(CORE_Pub_Location__c location: [SELECT Id, Party_Id_gne__c, Party_Id_ref_gne__c, Party_Location_Id_gne__c FROM CORE_Pub_Location__c]){
			partyLocIdToSfdcId.put(location.Party_Location_Id_gne__c, location.Id);
			system.assertEquals(partyIdToSfdcId.get(location.Party_Id_gne__c), location.Party_Id_ref_gne__c);
		}
		for(CORE_Pub_External_Id__c externalId: [SELECT Id, Party_Id_gne__c, Party_Id_ref_gne__c, Party_Location_Id_gne__c, Party_Location_Id_ref_gne__c FROM CORE_Pub_External_Id__c]){
			system.assertEquals(partyIdToSfdcId.get(externalId.Party_Id_gne__c), externalId.Party_Id_ref_gne__c);
			system.assertEquals(partyLocIdToSfdcId.get(externalId.Party_Location_Id_gne__c), externalId.Party_Location_Id_ref_gne__c);
		}
		for(CORE_Pub_License__c license: [SELECT Id, Party_Id_gne__c, Party_Id_ref_gne__c FROM CORE_Pub_License__c]){
			system.assertEquals(partyIdToSfdcId.get(license.Party_Id_gne__c), license.Party_Id_ref_gne__c);
		}
		
		for(CORE_Pub_Plan_Product__c product: [select Hlth_Pln_Typ_gne__c, Mdcr_Pdp_Intr_Flag_gne__c, Mdcr_Sctr_Flag_gne__c, Party_Id_gne__c, Party_Id_ref_gne__c, Pln_Prodt_End_Dt_gne__c, Pln_Prodt_Id_gne__c, Pln_Prodt_Lv_Cnt_gne__c, Pln_Prodt_Model_Typ_gne__c, Pln_Prodt_Nm_gne__c, Pln_Prodt_Start_Dt_gne__c, Pln_Prodt_Typ_gne__c, Pln_Prodt_W_Phmcy_BenLv_Cnt_gne__c from CORE_Pub_Plan_Product__c]){
			system.assertEquals(partyIdToSfdcId.get(product.Party_Id_gne__c), product.Party_Id_ref_gne__c);
		}
	}
}