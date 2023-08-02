@IsTest
public with sharing class CORE_Subscribe_Process_Test {

    @TestSetup
    static void init() {
        String userExtId = 'uniqueemail@gene.com';
        CORE_Subscribe_Test_Util.initCustomSettings();
        CORE_Subscribe_Test_Util.insertDefaultRecordOwner(userExtId);
        initMappingConfig(userExtId);
        initPublishData();
    }

    private static void initMappingConfig(String defaultRecordOwner) {
        //person account
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
        fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = accConfInd.Id, Source_Field_gne__c = 'Credentials_json_gne__c', Target_Field_gne__c = 'Description', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c = false, Order_gne__c = 3, Active_gne__c = true, Reference_CustomSetting_gne__c = 'CORE_Pub_Prof_Typ__c', Reference_Field_gne__c = 'Value_gne__c'));
        fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = accConfInd.Id, Source_Field_gne__c = 'Alt_Names_json_gne__c', Target_Field_gne__c = 'Website', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c = false, Order_gne__c = 4, Active_gne__c = true, Handler_gne__c = 'CORE_Subscribe_Field_Handler_JsonList'));
        fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = accConfInd.Id, Source_Field_gne__c = 'Salutation_gne__c', Target_Field_gne__c = 'Site', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c = false, Order_gne__c = 6, Active_gne__c = true));
        fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = accConfInd.Id, Source_Field_gne__c = 'Suffix_gne__c', Target_Field_gne__c = 'Site', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c = false, Order_gne__c = 7, Active_gne__c = true, Handler_gne__c = 'CORE_Subscribe_Field_Handler_Concatenate'));

        CORE_Subscribe_Mapping_Configuration__c productConf = new CORE_Subscribe_Mapping_Configuration__c(Subscribe_Object_gne__c = subscribeObject.Id, Source_Object_gne__c = 'CORE_Pub_Location__c', Target_Object_gne__c = 'Product2', Order_gne__c = 3, Create_New_Record_gne__c = true);
        insert productConf;
        fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = productConf.Id, Source_Field_gne__c = 'MDM_Id_gne__c', Target_Field_gne__c = 'ProductCode', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c = true, Order_gne__c = 1, Active_gne__c = true));
        fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = productConf.Id, Source_Field_gne__c = 'Default_gne__c', Target_Field_gne__c = 'IsActive', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c = false, Order_gne__c = 2, Active_gne__c = true));
        fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = productConf.Id, Source_Field_gne__c = 'Street_gne__c', Target_Field_gne__c = 'Description', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c = false, Order_gne__c = 3, Active_gne__c = true));
        fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = productConf.Id, Source_Field_gne__c = 'Bldg_Desc_gne__c', Target_Field_gne__c = 'Name', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_NULL, Is_External_Id_gne__c = false, Order_gne__c = 4, Active_gne__c = true));
        fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = productConf.Id, Source_Field_gne__c = 'Bldg_Fl_Desc_gne__c', Target_Field_gne__c = 'Name', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_NULL, Is_External_Id_gne__c = false, Order_gne__c = 5, Active_gne__c = true, Handler_gne__c = 'CORE_Subscribe_Field_Handler_Concatenate'));

        CORE_Subscribe_Mapping_Configuration__c licenseConf = new CORE_Subscribe_Mapping_Configuration__c(Subscribe_Object_gne__c = subscribeObject.Id, Source_Object_gne__c = 'CORE_Pub_License__c', Target_Object_gne__c = 'Solution', Order_gne__c = 4, Create_New_Record_gne__c = true);
        insert licenseConf;
        fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = licenseConf.Id, Source_Field_gne__c = 'Designation_gne__c', Target_Field_gne__c = 'SolutionName', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c = false, Order_gne__c = 1, Active_gne__c = true));
        fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = licenseConf.Id, Source_Field_gne__c = 'License_Number_gne__c', Target_Field_gne__c = 'SolutionNote', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c = false, Order_gne__c = 3, Active_gne__c = true));
        fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = licenseConf.Id, Source_Field_gne__c = 'License_Status_gne__c', Target_Field_gne__c = 'Status', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c = false, Order_gne__c = 4, Active_gne__c = true));
        /*

        CORE_Subscribe_Mapping_Configuration__c externalIdConf = new CORE_Subscribe_Mapping_Configuration__c(Subscribe_Object_gne__c=subscribeObject.Id, Source_Object_gne__c='CORE_Pub_External_Id__c', Target_Object_gne__c='Account_External_Id_gne__c', Type_gne__c='PTY', Order_gne__c=5, Create_New_Record_gne__c=true);
        insert externalIdConf;

        fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = externalIdConf.id, Source_Field_gne__c = 'Party_Id_ref_gne__c', Target_Field_gne__c='Account_gne__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_NULL, Is_External_Id_gne__c=false, Order_gne__c=1, Active_gne__c=true, Parent_Object_gne__c='Account', Parent_External_Field_Name_gne__c='AccountNumber'));
        fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = externalIdConf.id, Source_Field_gne__c = 'Ctrb_Src_gne__c', Target_Field_gne__c='Third_Party_gne__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=3, Active_gne__c=true));
        fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = externalIdConf.id, Source_Field_gne__c = 'Ctrb_Src_Id_gne__c', Target_Field_gne__c='Third_Party_Id_gne__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=4, Active_gne__c=true));


        CORE_Subscribe_Mapping_Configuration__c testContactExternalIdConf = new CORE_Subscribe_Mapping_Configuration__c(Subscribe_Object_gne__c=subscribeObject.Id, Source_Object_gne__c='CORE_Pub_External_Id__c', Target_Object_gne__c='testContact_External_Id_gne__c', Type_gne__c='PTYLoc', Order_gne__c=6, Create_New_Record_gne__c=true);
        insert testContactExternalIdConf;

        fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = testContactExternalIdConf.id, Source_Field_gne__c = 'Party_Location_Id_ref_gne__c', Target_Field_gne__c='testContact_gne__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_NULL, Is_External_Id_gne__c=false, Order_gne__c=2, Active_gne__c=true, Parent_Object_gne__c='Contact', Parent_External_Field_Name_gne__c='MDM_testContact_ID_gne__c'));
        fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = testContactExternalIdConf.id, Source_Field_gne__c = 'Ctrb_Src_gne__c', Target_Field_gne__c='Third_Party_gne__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=3, Active_gne__c=true));
        fieldsConfig.add(new CORE_Subscribe_Field_Configuration_gne__c(Mapping_Configuration_gne__c = testContactExternalIdConf.id, Source_Field_gne__c = 'Ctrb_Src_Id_gne__c', Target_Field_gne__c='Third_Party_Id_gne__c', Overwrite_Type_gne__c = CORE_Subscribe_Process.OVERWRITE_ALWAYS, Is_External_Id_gne__c=false, Order_gne__c=4, Active_gne__c=true));
        */

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
        party2.Org_Type_json_gne__c = '[{"Code" : "MISC", "Value" : "Miscellaneous"}]';
        party2.Comm_Channel_json_gne__c = '[{"Code" : "BUS_PHN", "Value" : "6503231432",  "Extension" : "x123"}, {"Code" : "URL", "Value" : "www.google.com"}]';
        party2.Do_Not_Contact_gne__c = 'N';
        party2.Alt_Names_json_gne__c = '[{"Value" : "POTOMAC CENTER"}]';

        insert new List<CORE_Pub_Party__c>{
                party, party2
        };

        CORE_Pub_Location__c location = new CORE_Pub_Location__c(City_gne__c = 'COLUMBIA', Country_gne__c = 'UNITED STATES', Default_gne__c = true, Latitude_gne__c = '39.1772', Longitude_gne__c = '-76.87023', MDM_Id_gne__c = '13737910', MDM_Status_gne__c = 'A', Party_Id_gne__c = '1682933', Party_Location_Id_gne__c = '3636340', State_gne__c = 'MD', Street_gne__c = '8335 GUILFORD RD', Unit_Type_gne__c = 'STE', Unit_Value_gne__c = 'A', Zip_gne__c = '21046', Zip_4_gne__c = '7050');
        location.Bldg_Desc_gne__c = 'BLDG 200';
        location.Bldg_Fl_Desc_gne__c = 'FL 2';
        location.Comm_Chan_json_gne__c = '[{"Code" : "BUS", "Value" :  "4103090690", "Extension" : "x123"}]';
        location.Loc_Use_json_gne__c = '[{"Code" : "AMS_GOLD"}, {"Code" : "BUS"}]';
        insert new List<CORE_Pub_Location__c>{
                location
        };

        CORE_Pub_License__c license4 = new CORE_Pub_License__c(Party_Id_gne__c = '1612170', License_Number_gne__c = 'A115519', License_State_gne__c = 'CA', Grace_Period_gne__c = '90', Designation_gne__c = 'MD', License_Status_gne__c = 'Valid', Smpl_Ovrl_Elig_Flag_gne__c = 'N', Profsnl_Dsgt_Rk_Nbr_gne__c = '1');
        license4.Adj_Lic_Exp_Date_gne__c = Date.newInstance(2019, 3, 31);
        license4.Exp_Date_gne__c = Date.newInstance(2019, 12, 31);
        license4.External_Id_gne__c = license4.Party_Id_gne__c + license4.License_Number_gne__c;
        insert license4;

        CORE_Pub_License__c license = new CORE_Pub_License__c(Party_Id_gne__c = '1612170', License_Number_gne__c = 'A115513', License_State_gne__c = 'CA', Grace_Period_gne__c = '90', Designation_gne__c = 'MD', License_Status_gne__c = 'Valid', Smpl_Ovrl_Elig_Flag_gne__c = 'Y', Profsnl_Dsgt_Rk_Nbr_gne__c = '1');
        license.Adj_Lic_Exp_Date_gne__c = Date.newInstance(2018, 3, 31);
        license.Exp_Date_gne__c = Date.newInstance(2018, 12, 31);
        license.External_Id_gne__c = license.Party_Id_gne__c + license.License_Number_gne__c;
        insert license;

        CORE_Pub_License__c license2 = new CORE_Pub_License__c(Party_Id_gne__c = '1612170', License_Number_gne__c = 'A115515', License_State_gne__c = 'CA', Grace_Period_gne__c = '90', Designation_gne__c = 'MD', License_Status_gne__c = 'Valid', Smpl_Ovrl_Elig_Flag_gne__c = 'Y', Profsnl_Dsgt_Rk_Nbr_gne__c = '1');
        license2.Adj_Lic_Exp_Date_gne__c = Date.newInstance(2017, 3, 31);
        license2.Exp_Date_gne__c = Date.newInstance(2017, 12, 31);
        license2.External_Id_gne__c = license2.Party_Id_gne__c + license2.License_Number_gne__c;
        insert license2;

        CORE_Pub_License__c license3 = new CORE_Pub_License__c(Party_Id_gne__c = '1612170', License_Number_gne__c = 'A115517', License_State_gne__c = 'CA', Grace_Period_gne__c = '90', Designation_gne__c = 'MD', License_Status_gne__c = 'Valid', Smpl_Ovrl_Elig_Flag_gne__c = 'Y', Profsnl_Dsgt_Rk_Nbr_gne__c = '5');
        license3.Adj_Lic_Exp_Date_gne__c = Date.newInstance(2017, 3, 31);
        license3.Exp_Date_gne__c = Date.newInstance(2017, 12, 31);
        license3.External_Id_gne__c = license3.Party_Id_gne__c + license3.License_Number_gne__c;
        insert license3;

        List<CORE_Pub_External_Id__c>extIds = new List<CORE_Pub_External_Id__c>();
        extIds.add(new CORE_Pub_External_Id__c(Party_Id_gne__c = '1612170', Ctrb_Src_gne__c = 'AMS', Ctrb_Src_Id_gne__c = '6712852', Cnncl_Enty_Type_gne__c = 'PTY', External_Id_gne__c = '1612170_6712852'));

        extIds.add(new CORE_Pub_External_Id__c(Party_Id_gne__c = '1612170', Ctrb_Src_gne__c = 'MDM', Ctrb_Src_Id_gne__c = '2308068', Cnncl_Enty_Type_gne__c = 'PTY', External_Id_gne__c = '1612170_2308068'));

        extIds.add(new CORE_Pub_External_Id__c(Party_Id_gne__c = '1682933', Ctrb_Src_gne__c = 'MDM', Ctrb_Src_Id_gne__c = '2308077', Cnncl_Enty_Type_gne__c = 'PTY', External_Id_gne__c = '1682933_2308077'));
        extIds.add(new CORE_Pub_External_Id__c(Party_Id_gne__c = '1682933', Party_Location_Id_gne__c = '3636340', Ctrb_Src_gne__c = 'MDM', Ctrb_Src_Id_gne__c = '55291862', Cnncl_Enty_Type_gne__c = 'PTYLoc', External_Id_gne__c = '3636340_55291862'));
        insert extIds;

    }

    static testMethod void subscribeBase() {
        Map<String, CORE_Pub_Party__c> parties = CORE_Subscribe_Test_Util.getParties();

        CORE_Subscribe_Object__c subscribeObject = [SELECT Id FROM CORE_Subscribe_Object__c];
        CORE_Subscribe_Job__c subscribeJob = [SELECT Id FROM CORE_Subscribe_Job__c];

        Map<String, List<CORE_Subscribe_Mapping_Configuration__c>> mappingConfiguration = CORE_Subscribe_DAO.getMappingConfiguration(subscribeObject.Id);
        Set<String>partyIds = new Set<String>();
        for (CORE_Pub_Party__c party : parties.values()) {
            partyIds.add(party.Party_Id_gne__c);
        }

        CORE_Subscribe_Metrics metrics = new CORE_Subscribe_Process().executeSubscribe(partyIds, subscribeJob.Id);
        parties = CORE_Subscribe_Test_Util.getParties();

        for (CORE_Pub_Party__c party : parties.values()) {
            System.assertEquals(null, party.Comments_gne__c);
            System.assert(party.Last_Sub_Exec_gne__c != null);
            System.assertEquals('Success', party.Sub_Exec_Status_gne__c);
        }

        List<Account> accounts = getAccounts();
        System.assertEquals(2, accounts.size());

        Map<String, Account>mdmToAccount = new Map<String, Account>();
        for (Account account : accounts) {
            mdmToAccount.put(account.AccountNumber, account);
        }
        for (CORE_Pub_Party__c party : parties.values()) {
            if (party.Mdm_Id_gne__c == '2439927') {
                Account account = mdmToAccount.get(party.Mdm_Id_gne__c);
                System.assertEquals(party.Org_Name_gne__c, account.Name);
                System.assertEquals(party.Mdm_Id_gne__c, account.AccountNumber);
                System.assertEquals('ams', account.Description);
                System.assertEquals('POTOMAC CENTER', account.Website);
            }
            if (party.Mdm_Id_gne__c == '2308068') {
                String credentials = CORE_Subscribe_Test_Util.getListValues(party.Credentials_json_gne__c, CORE_Subscribe_DAO.getCodeMapping('CORE_Pub_Prof_Typ__c', 'Value_gne__c'));
                Account account = mdmToAccount.get(party.Mdm_Id_gne__c);
                System.assertEquals(party.LastName_gne__c, account.Name);
                System.assertEquals(party.Mdm_Id_gne__c, account.AccountNumber);
                System.assertEquals(credentials, account.Description);
                System.assertEquals('MICHELLE CHING-WEN LAM;MICHELLE CHING-W CHU;MICHELLE CHING-W LAM;MICHELLE L CHU', account.Website);
                System.assertEquals(party.Salutation_gne__c + ' ' + party.Suffix_gne__c, account.Site);
            }
        }

        Map<Id, CORE_Pub_Location__c> locations = CORE_Subscribe_Test_Util.getPublishPartyLocations(parties.keySet());
        List<Contact> contacts = [SELECT Id, Name, AccountId, Title, Department, Description FROM Contact];

        Map<String, Contact>mdmToContacts = new Map<String, Contact>();
        for (Contact testContact : contacts) {
            mdmToContacts.put(testContact.Title, testContact);
        }
        for (CORE_Pub_Location__c location : locations.values()) {
            Contact testContact = mdmToContacts.get(location.MDM_Id_gne__c);
        }

        CORE_Pub_License__c license = [SELECT Party_Id_gne__c, License_Number_gne__c, License_State_gne__c, Grace_Period_gne__c, Designation_gne__c, License_Status_gne__c, Smpl_Ovrl_Elig_Flag_gne__c FROM CORE_Pub_License__c WHERE License_Number_gne__c = 'A115513'];
        Solution solution = [SELECT Id, SolutionName, SolutionNote, Status FROM Solution];
        System.assertEquals(license.Designation_gne__c, solution.SolutionName);
        System.assertEquals(license.License_Number_gne__c, solution.SolutionNote);
        System.assertEquals(license.License_Status_gne__c, solution.Status);

        System.assertNotEquals(null, CORE_Subscribe_Base.printMetrics(metrics));
    }

    static List<Account> getAccounts() {
        return [SELECT Id, Name, AccountNumber, Site, AnnualRevenue, Description, Phone, Website FROM Account];
    }

    static testMethod void subscribeUpdateAccount() {
        Account acc = new Account(AccountNumber = '2439927', Name = 'POTOMAC');
        insert acc;

        Map<String, CORE_Pub_Party__c> parties = CORE_Subscribe_Test_Util.getParties();

        CORE_Subscribe_Object__c subscribeObject = [SELECT Id FROM CORE_Subscribe_Object__c];
        CORE_Subscribe_Job__c subscribeJob = [SELECT Id FROM CORE_Subscribe_Job__c];
        Map<String, List<CORE_Subscribe_Mapping_Configuration__c>> mappingConfiguration = CORE_Subscribe_DAO.getMappingConfiguration(subscribeObject.Id);

        Set<String>partyIds = new Set<String>();
        for (CORE_Pub_Party__c party : parties.values()) {
            partyIds.add(party.Party_Id_gne__c);
        }

        new CORE_Subscribe_Process().executeSubscribe(partyIds, subscribeJob.Id);

        List<Account> accounts = getAccounts();
        System.assertEquals(2, accounts.size());

        Map<String, Account>mdmToAccount = new Map<String, Account>();
        for (Account account : accounts) {
            mdmToAccount.put(account.AccountNumber, account);
        }

        for (CORE_Pub_Party__c party : parties.values()) {
            if (party.Mdm_Id_gne__c == '2439927') {
                Account account = mdmToAccount.get(party.Mdm_Id_gne__c);
                System.assertEquals(party.Mdm_Id_gne__c, account.AccountNumber);
                System.assertEquals('ams', account.Description);
                System.assertEquals('POTOMAC CENTER', account.Website);
            }
        }
    }

    public class RecordRetriever implements CORE_Subscribe_Interface.Record_Retriever {

        public void init(List<CORE_Pub_Party__c>parties, Map<Id, List<CORE_Pub_External_Id__c>> partyToExtIds, Map<Id, List<CORE_Pub_Location__c>> partyToLocations, Map<Id, List<CORE_Pub_Plan_Product__c>>partyToProdPlans) {

        }

        public List<SObject> getExistingObjects(CORE_Pub_Party__c parentParty, SObject publishRecord, CORE_Subscribe_Mapping_Configuration__c configuration, Set<SObject>subscribeRecords) {
            if (publishRecord instanceof CORE_Pub_Party__c) {
                CORE_Pub_Party__c party = (CORE_Pub_Party__c) publishRecord;
                return [SELECT Id, Name, AccountNumber, Site, AnnualRevenue, Description, Phone, Website FROM Account WHERE AccountNumber = :party.Mdm_Id_gne__c];
            }
            return new List<SObject>();
        }

        public CORE_Subscribe_Interface.ExistingRecodsWrapper getExistingObjects(CORE_Pub_Party__c parentParty, List<SObject> publishRecord, CORE_Subscribe_Mapping_Configuration__c configuration, Set<SObject> subscribeRecords) {
            return null;
        }

        public List<User> fetchUsers(List<String> externalUserIds) {
            return [SELECT Id FROM User WHERE Email IN :externalUserIds];
        }
    }

    public class SubscribeValidation implements CORE_Subscribe_Interface.Validator {
        public Map<Id, CORE_Subscribe_Error__c> validate(List<CORE_Pub_Party__c>parties, Map<Id, List<CORE_Pub_External_Id__c>> partyToExtIds, Map<Id, List<CORE_Pub_Location__c>> partyToLocations, Map<Id, List<CORE_Pub_Plan_Product__c>>partyToProdPlans, CORE_Subscribe_Base.SubscribeMode mode) {
            return new Map<Id, CORE_Subscribe_Error__c>();
        }

        public Boolean canCreateNewObject(CORE_Pub_Party__c parentParty, SObject publishRecord, CORE_Subscribe_Mapping_Configuration__c configuration, CORE_Subscribe_Base.SubscribeMode mode) {
            return true;
        }

        public Boolean canUpdateRecord(CORE_Pub_Party__c parentParty, SObject publishRecord, CORE_Subscribe_Mapping_Configuration__c configuration, List<SObject> existingRecords, CORE_Subscribe_Base.SubscribeMode mode) {
            return true;
        }

        public String getConfigurationType(SObject stagingRecord) {
            String confType;
            if (stagingRecord instanceof CORE_Pub_Party__c) {
                confType = ((CORE_Pub_Party__c) stagingRecord).Type_gne__c;
            } else if (stagingRecord instanceof CORE_Pub_External_Id__c) {
                confType = ((CORE_Pub_External_Id__c) stagingRecord).Cnncl_Enty_Type_gne__c;
            }
            return confType;
        }
    }

    public class SubscribePostprocess implements CORE_Subscribe_Interface.Postporcessor {
        public void processRecords(List<CORE_Pub_Party__c> parties, Map<Id, List<CORE_Pub_External_Id__c>>partyToExtIds, Map<Id, List<CORE_Pub_Plan_Product__c>>partyToProdPlans, Map<String, Map<String, List<SObject>>>partyToRecords, Map<String, Map<String, List<SObject>>>partyLocationToRecords,
                Map<String, Map<String, List<SObject>>>extIdToRecords, Map<String, Map<String, List<SObject>>>licenseToRecords, Map<String, Map<String, List<SObject>>>productToRecords) {

        }
    }
}