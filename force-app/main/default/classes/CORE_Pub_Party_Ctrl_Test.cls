@IsTest
public with sharing class CORE_Pub_Party_Ctrl_Test {

    @TestSetup
    static void init() {
        String userExtId = 'uniqueemail@gene.com';
        CORE_Subscribe_Test_Util.initCustomSettings();
        CORE_Subscribe_Test_Util.insertDefaultRecordOwner(userExtId);
        initMappingConfig(userExtId);
        initPublishData();
    }

    private static void initMappingConfig(String defaultRecordOwner) {
        CORE_Subscribe_Object__c subscribeObject = new CORE_Subscribe_Object__c(Name = 'test object', Retriever_Interface_gne__c = 'CORE_Subscribe_Process_Test.RecordRetriever', Validation_Interface_gne__c = 'CORE_Subscribe_Process_Test.SubscribeValidation', Postprocess_Interface_gne__c = 'CORE_Subscribe_Process_Test.SubscribePostprocess');
        insert subscribeObject;

        String jobName = 'Test job';
        CORE_Subscribe_Job__c subscribeJob = new CORE_Subscribe_Job__c(Name = jobName, Status_gne__c = 'New', Subscribe_Object_gne__c = subscribeObject.Id);
        insert subscribeJob;

        CORE_Subscribe_Mapping_Configuration__c accConfOrg = new CORE_Subscribe_Mapping_Configuration__c(Subscribe_Object_gne__c = subscribeObject.Id, Source_Object_gne__c = 'CORE_Pub_Party__c', Target_Object_gne__c = 'Account', Default_Record_Owner_gne__c = defaultRecordOwner, Type_gne__c = 'ORG', Order_gne__c = 1, Create_New_Record_gne__c = true);
        insert accConfOrg;
        List<CORE_Subscribe_Field_Configuration_gne__c>fieldsConfig = new List<CORE_Subscribe_Field_Configuration_gne__c>();
        fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = accConfOrg.Id, Source_Field_gne__c = 'Org_Name_gne__c', Target_Field_gne__c = 'Name', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_NULL, Is_External_Id_gne__c = false, Order_gne__c = 1, Active_gne__c = true));
        fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = accConfOrg.Id, Source_Field_gne__c = 'MDM_Id_gne__c', Target_Field_gne__c = 'AccountNumber', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c = true, Order_gne__c = 2, Active_gne__c = true));
        fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = accConfOrg.Id, Source_Field_gne__c = 'Org_Type_json_gne__c', Target_Field_gne__c = 'Description', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c = false, Order_gne__c = 3, Active_gne__c = true, Reference_CustomSetting_gne__c = 'CORE_Pub_Org_Typ_Map__c', Reference_Field_gne__c = 'Stewardship_System_Name_gne__c'));
        fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = accConfOrg.Id, Source_Field_gne__c = 'Alt_Names_json_gne__c', Target_Field_gne__c = 'Website', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c = false, Order_gne__c = 4, Active_gne__c = true, Handler_gne__c = 'CORE_Subscribe_Field_Handler_JsonList'));

        CORE_Subscribe_Mapping_Configuration__c accConfInd = new CORE_Subscribe_Mapping_Configuration__c(Subscribe_Object_gne__c = subscribeObject.Id, Source_Object_gne__c = 'CORE_Pub_Party__c', Target_Object_gne__c = 'Account', Default_Record_Owner_gne__c = defaultRecordOwner, Type_gne__c = 'IND', Order_gne__c = 1, Create_New_Record_gne__c = true);
        insert accConfInd;
        fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = accConfInd.Id, Source_Field_gne__c = 'LastName_gne__c', Target_Field_gne__c = 'Name', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_NULL, Is_External_Id_gne__c = false, Order_gne__c = 1, Active_gne__c = true));
        fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = accConfInd.Id, Source_Field_gne__c = 'MDM_Id_gne__c', Target_Field_gne__c = 'AccountNumber', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c = true, Order_gne__c = 2, Active_gne__c = true));
        fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = accConfInd.Id, Source_Field_gne__c = 'FirstName_gne__c', Target_Field_gne__c = 'Description', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c = false, Order_gne__c = 3, Active_gne__c = true));
        fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = accConfInd.Id, Source_Field_gne__c = 'Alt_Names_json_gne__c', Target_Field_gne__c = 'Website', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c = false, Order_gne__c = 4, Active_gne__c = true, Handler_gne__c = 'CORE_Subscribe_Field_Handler_JsonList'));
        fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = accConfInd.Id, Source_Field_gne__c = 'Salutation_gne__c', Target_Field_gne__c = 'Site', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c = false, Order_gne__c = 6, Active_gne__c = true));
        fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = accConfInd.Id, Source_Field_gne__c = 'Suffix_gne__c', Target_Field_gne__c = 'Site', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c = false, Order_gne__c = 7, Active_gne__c = true, Handler_gne__c = 'CORE_Subscribe_Field_Handler_Concatenate'));

        insert fieldsConfig;
    }

    private static void initPublishData() {
        CORE_Pub_Party__c party = new CORE_Pub_Party__c(Party_Id_gne__c = '1612170', Mdm_Id_gne__c = '2308068', Status_gne__c = 'A', FirstName_gne__c = 'MICHELLE', MiddleName_gne__c = 'LAM CHING-WEN', LastName_gne__c = 'CHU', Salutation_gne__c = 'Dr.', Suffix_gne__c = 'V', Gender_gne__c = 'F', PDRP_Opt_Out_gne__c = 'Y');
        party.Mdm_Updt_Date_gne__c = Datetime.newInstance(2015, 7, 12, 15, 20, 35);
        party.Birthdate_gne__c = Date.newInstance(1982, 1, 1);
        party.PDRP_Opt_Out_Date_gne__c = Date.newInstance(2014, 1, 14);
        party.Type_gne__c = 'IND';
        party.Prof_Type_json_gne__c = '[{"Code" : "MD"}, {"Code" : "CLNCL"}, {"Code" : "PSCR"}]';
        party.Education_json_gne__c = '[{"Code" : "MD"}, {"Code" : "LVT"}]';
        party.Comm_Channel_json_gne__c = '[{"Code" : "BUS_PHN", "Value" : "6505231432"}, {"Code" : "EML", "Value" : "test@test.com"}, {"Code" : "PGR",  "Value" : "5231234321"}]';
        party.Credentials_json_gne__c = '[{"Code" : "MD"}, {"Code" : "MBA"}, {"Code" : "MPT"}]';
        party.Specialties_json_gne__c = '[{"Code" : "A"}, {"Code" : "DEN"}, {"Code" : "ACA"}]';
        party.Alt_Names_json_gne__c = '[{"Value" : "MICHELLE CHING-WEN LAM"}, {"Value" : "MICHELLE CHING-W CHU"}, {"Value" : "MICHELLE CHING-W LAM"}, {"Value" : "MICHELLE L CHU"} ]';
        party.Do_Not_Contact_gne__c = 'Y';

        CORE_Pub_Party__c party2 = new CORE_Pub_Party__c(Party_Id_gne__c = '1682933', Mdm_Id_gne__c = '2439927', Status_gne__c = 'I', Org_Name_gne__c = 'POTOMAC CENTER FOR MEDICAL EDUCATION');
        party2.Mdm_Updt_Date_gne__c = Datetime.newInstance(2015, 7, 12, 15, 20, 35);
        party2.Type_gne__c = 'ORG';
        party2.Org_Type_json_gne__c = '[{"Code" : "MISC"}]';
        party2.Comm_Channel_json_gne__c = '[{"Code" : "BUS_PHN", "Value" : "6503231432",  "Extension" : "x123"}, {"Code" : "URL", "Value" : "www.google.com"}]';
        party2.Do_Not_Contact_gne__c = 'N';
        party2.Alt_Names_json_gne__c = '[{"Value" : "POTOMAC CENTER"}]';

        insert new List<CORE_Pub_Party__c>{
                party, party2
        };

        CORE_Pub_Location__c location = new CORE_Pub_Location__c(City_gne__c = 'COLUMBIA', Country_gne__c = 'UNITED STATES', Default_gne__c = true, Latitude_gne__c = '39.1772', Longitude_gne__c = '-76.87023', MDM_Id_gne__c = '13737910', MDM_Status_gne__c = 'A', Party_Id_gne__c = '1682933', Party_Location_Id_gne__c = '3636340', State_gne__c = 'MD', Street_gne__c = '8335 GUILFORD RD', Unit_Type_gne__c = 'STE', Unit_Value_gne__c = 'A', Zip_gne__c = '21046', Zip_4_gne__c = '7050');
        location.Comm_Chan_json_gne__c = '[{"Code" : "BUS", "Value" :  "4103090690", "Extension" : "x123"}]';
        location.Loc_Use_json_gne__c = '[{"Code" : "AMS_GOLD"}, {"Code" : "BUS"}]';
        insert new List<CORE_Pub_Location__c>{
                location
        };

        CORE_Pub_License__c license = new CORE_Pub_License__c(Party_Id_gne__c = '1612170', License_Number_gne__c = 'A115513', License_State_gne__c = 'CA', Grace_Period_gne__c = '90', Designation_gne__c = 'MD', License_Status_gne__c = 'Valid', Smpl_Ovrl_Elig_Flag_gne__c = 'Y');
        license.Adj_Lic_Exp_Date_gne__c = Date.newInstance(2017, 3, 31);
        license.Exp_Date_gne__c = Date.newInstance(2017, 12, 31);
        license.External_Id_gne__c = license.Party_Id_gne__c + license.License_Number_gne__c;
        insert license;

        List<CORE_Pub_External_Id__c>extIds = new List<CORE_Pub_External_Id__c>();
        extIds.add(new CORE_Pub_External_Id__c(Party_Id_gne__c = '1612170', Ctrb_Src_gne__c = 'AMS', Ctrb_Src_Id_gne__c = '6712852', Cnncl_Enty_Type_gne__c = 'PTY', External_Id_gne__c = '1612170_6712852'));

        extIds.add(new CORE_Pub_External_Id__c(Party_Id_gne__c = '1612170', Ctrb_Src_gne__c = 'MDM', Ctrb_Src_Id_gne__c = '2308068', Cnncl_Enty_Type_gne__c = 'PTY', External_Id_gne__c = '1612170_2308068'));

        extIds.add(new CORE_Pub_External_Id__c(Party_Id_gne__c = '1682933', Ctrb_Src_gne__c = 'MDM', Ctrb_Src_Id_gne__c = '2308077', Cnncl_Enty_Type_gne__c = 'PTY', External_Id_gne__c = '1682933_2308077'));
        extIds.add(new CORE_Pub_External_Id__c(Party_Id_gne__c = '1682933', Party_Location_Id_gne__c = '3636340', Ctrb_Src_gne__c = 'MDM', Ctrb_Src_Id_gne__c = '55291862', Cnncl_Enty_Type_gne__c = 'PTYLoc', External_Id_gne__c = '3636340_55291862'));
        insert extIds;
    }

    static testMethod void executeSubscribeTest() {
        CORE_Pub_Party__c party = [SELECT Id, Last_Sub_Exec_gne__c FROM CORE_Pub_Party__c LIMIT 1];
        Test.startTest();
        CORE_Pub_Party__c processedParty = CORE_Pub_Party_Controller.executeSubscribe(party.Id);
        Test.stopTest();
        System.assertNotEquals(party.Last_Sub_Exec_gne__c, processedParty.Last_Sub_Exec_gne__c);
    }
}