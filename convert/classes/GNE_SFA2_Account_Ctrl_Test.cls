@isTest
private class GNE_SFA2_Account_Ctrl_Test {

    private static String TEST_USER_NAME = 'User_CtrlTest';
    private static String TEST_ACCOUNT_NAME = 'Account_CtrlTest';
    private static Integer SAMPLE_LOOP_NUMBER = 10;

    @isTest
    public static void testSFABrandUserViewMode() { //changed for Field profile
        User user = prepareUser('GNE-Field', 'MCCO', null, 'BFRM', true, false);
        GNE_SFA2_Account_Ctrl.DataWrapper dataWrapper = null;
        System.runAs(user) {
            Account account = prepareAccountHCO();
            Map<String, String> pageParameters = createPageParameters(account.Id,'1');
            Test.startTest();
            dataWrapper = getAccountDataWrapper(account, pageParameters);
            Test.stopTest();
        }
        System.assertNotEquals(null, dataWrapper);
        System.assertNotEquals(null, dataWrapper.retUrl);
        System.assertEquals(null, dataWrapper.uiType);
    }

    @isTest
    public static void testMCCOUserDispatcher(){
        User user = prepareUser('GNE-Field', 'MCCO CRM', null, 'AM', true, false);
        GNE_SFA2_Account_Ctrl.DataWrapper dataWrapper = null;
        System.runAs(user) {
            Account account = prepareAccountHCO();
            Map<String, String> pageParameters = createPageParameters(account.Id,'1');
            Test.startTest();            
            dataWrapper = getAccountDataWrapper(account, pageParameters);
            Test.stopTest();
        }
        System.assertNotEquals(null, dataWrapper);
        System.assertNotEquals(null, dataWrapper.retUrl);
    }

    @isTest
    public static void testGetTranslationsMap(){
        GNE_SFA2_Account_Ctrl controller = new GNE_SFA2_Account_Ctrl();
        Map<String,String> translationsMap = null;
        Test.startTest();
        translationsMap = controller.getTranslationsMap();
        Test.stopTest();
        System.assertEquals(System.Label.GNE_SFA2_DCR_Info_SubmissionAlert1, translationsMap.get('dcrSubmissionAlert1'));
        System.assertEquals(System.Label.GNE_SFA2_DCR_Info_SubmissionAlert2, translationsMap.get('dcrSubmissionAlert2'));
        System.assertEquals(System.Label.EDM_Cannot_be_nominated_because_of_exclusion_list, translationsMap.get('nominateToBureauError'));
        System.assertEquals(System.Label.GNE_CRM_FRM_ARA_Required, translationsMap.get('araRequiredAlert'));
        System.assertEquals(System.Label.GNE_CRM_FRM_VPN_Required, translationsMap.get('gconnectRequiredAlert'));
    }

    @isTest
    public static void testGetHiddenAddressCtrl(){
        GNE_SFA2_Account_Ctrl controller = new GNE_SFA2_Account_Ctrl();
        System.assertNotEquals(null,controller.getHiddenAddressCtrl());
    }

    @isTest
    public static void testGetRelatedListQuery(){
        GNE_SFA2_Account_Ctrl controller = new GNE_SFA2_Account_Ctrl();
        GNE_SFA2_Base_Ctrl.RelatedList rl = createRelatedList('Sample Name', null, createSampleListFields());
        rl.parentFieldName = 'Sample parent name';
        String result = controller.getRelatedListQuery(rl);
        System.assertNotEquals(null, result);
    }

    @isTest
    public static void testGetIncludedPage(){
        GNE_SFA2_Account_Ctrl controller = new GNE_SFA2_Account_Ctrl();
        SFA2_Configuration_Object_gne__c conf = createSampleConf();
        SFA2_Configuration_Object_Detail_gne__c confDetail = createSampleConfDetail('SampleConfDetail', conf.Id, null);
        GNE_SFA2_Base_Ctrl.ConfigItem item = controller.getIncludedPage(conf, confDetail, createSampleSectionsWithFields(), createMultipleRelatedList(2));
        System.assertNotEquals(null, item);
    }

    @isTest 
    public static void testGetIncludedPageWithPfgQtyLimitParameter(){
        GNE_SFA2_Account_Ctrl controller = new GNE_SFA2_Account_Ctrl();
        SFA2_Configuration_Object_gne__c conf = createSampleConf();
        SFA2_Configuration_Object_Detail_gne__c confDetail = createSampleConfDetail('SampleConfDetail', conf.Id, 'PfgQtyLimit');
        GNE_SFA2_Base_Ctrl.ConfigItem item = controller.getIncludedPage(conf, confDetail, createSampleSectionsWithFields(), createMultipleRelatedList(2));
        System.assertNotEquals(null, item);
    }

    @isTest
    public static void testQueryRelatedListRecords(){
        GNE_SFA2_Account_Ctrl controller = new GNE_SFA2_Account_Ctrl();
        SFA2_Configuration_Object_gne__c conf = createSampleConf();
        String query = 'SELECT Id FROM SFA2_Configuration_Object_gne__c';
        List<SObject> configurationSobjects = controller.queryRelatedListRecords(query);
        System.assertNotEquals(0, configurationSobjects.size());
    }

    @isTest
    public static void testGetRelatedListFilter(){
        GNE_SFA2_Account_Ctrl controller = new GNE_SFA2_Account_Ctrl();
        User user = prepareUser('GNE-Field', 'MCCO', null, 'BFRM', true, false);//prepareUser('GNE-SFA-Actemra-CS', 'SFA-US', 'Actemra', 'CS', true, true);
        GNE_SFA2_Base_Ctrl.UserWrapper userWrapper = new GNE_SFA2_Base_Ctrl.UserWrapper(user);
        Account account = prepareAccountHCO();
        GNE_SFA2_Base_Ctrl.RelatedList rlAddressVodC = createRelatedList('Address_vod__c', null, createSampleListFields());
        GNE_SFA2_Base_Ctrl.RelatedList rlMceGneC = createRelatedList('MCE_gne__c', null, createSampleListFields());
        GNE_SFA2_Base_Ctrl.RelatedList rlAffiliationVodC = createRelatedList('Affiliation_vod__c', null, createSampleListFields());
        Address_vod__c address = createSampleAddress(account);
        User_Preference_gne__c  sampleUserPreference = createSampleUserPreference(user, account, 'HIDDENADDRESS', true, address);
        GNE_SFA2_Affiliation_Calculated_Profiles__c affiliationCalculatedProfile = createSampleAffiliationProfiles('GNE-SFA-');
        controller.currentUser = userWrapper;
        controller.recordId = account.Id;
        String addressVodCFilter = null, rlAffiliationVodCFilter = null, mceGneCFilter = null;
    
        System.runAs(user){
            Test.startTest();
            addressVodCFilter = controller.getRelatedListFilter(rlAddressVodC);
            mceGneCFilter = controller.getRelatedListFilter(rlMceGneC);
            rlAffiliationVodCFilter =  controller.getRelatedListFilter(rlAffiliationVodC);
            Test.stopTest();
        }
        System.assertEquals('Id NOT IN :hiddenAddrIds', addressVodCFilter);
        System.assertEquals('Team_Code_gne__c = :currentTeamCode AND Subteam_Code_gne__c = :currentSubTeamCode', mceGneCFilter);
    }

    @isTest
    public static void testIntHideAddress(){
        GNE_SFA2_Account_Ctrl controller = new GNE_SFA2_Account_Ctrl();
        GNE_SFA2_Base_Ctrl.DataWrapper inputDataWrapper = new GNE_SFA2_Account_Ctrl.DataWrapper();
        GNE_SFA2_Base_Ctrl.DataWrapper dataWrapper = new GNE_SFA2_Account_Ctrl.DataWrapper();
        GNE_SFA2_Account_Ctrl.DataWrapper result = null;
        controller.inputDataWrapper = inputDataWrapper;
        controller.dataWrapper = dataWrapper;
        Test.startTest();
        result = controller.intHideAddress();
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    @isTest
    public static void testSaveRecordRemoteAction(){
        User user = prepareUser('GNE-Field', 'MCCO', null, 'BFRM', true, false);//prepareUser('GNE-SFA-Actemra-CS', 'SFA-US', 'Actemra', 'CS', true, true);
        GNE_SFA2_Affiliation_Calculated_Profiles__c sampleObj =  createSampleAffiliationProfiles('SampleName');
        GNE_SFA2_Account_Ctrl.DataWrapper dataWrapper = new GNE_SFA2_Account_Ctrl.DataWrapper();
        GNE_SFA2_Base_Ctrl.RecordDescribe describe = new GNE_SFA2_Base_Ctrl.RecordDescribe(sampleObj.Id, 'SampleObj', 'GNE_SFA2_Affiliation_Calculated_Profiles__c', 
            'SampleName', null, null);
        GNE_SFA2_Base_Ctrl.UserWrapper userWrapper = new GNE_SFA2_Base_Ctrl.UserWrapper(user);
        GNE_SFA2_Base_Ctrl.AppContext appContext = new GNE_SFA2_Base_Ctrl.AppContext(userWrapper, 'SFA-US', 'Sample Brand', null, null);
        GNE_SFA2_Base_Ctrl.Config config = new GNE_SFA2_Base_Ctrl.Config('some mode', null, null, null);    
        GNE_SFA2_Base_Ctrl.FieldDescribe fieldDescribe = new GNE_SFA2_Base_Ctrl.FieldDescribe();
        fieldDescribe.relationshipName = 'Name';
        GNE_SFA2_Base_Ctrl.Field field = new GNE_SFA2_Base_Ctrl.Field();
        field.describe = fieldDescribe;
        Map<String, GNE_SFA2_Base_Ctrl.Field> fields = new Map<String, GNE_SFA2_Base_Ctrl.Field>{'Name' => field};
        config.fieldsToRefresh = fields;
        dataWrapper.recordDescribe = describe;
        dataWrapper.appContext = appContext;
        dataWrapper.config = config;
        String str = JSON.serialize(dataWrapper);
        Test.startTest();
        GNE_SFA2_Account_Ctrl.DataWrapper returnedWrapper =  GNE_SFA2_Account_Ctrl.saveRecord(str);
        Test.stopTest(); 
        System.assertNotEquals(null, returnedWrapper);
        System.assertNotEquals(null, returnedWrapper.config);
        System.assertNotEquals(null, returnedWrapper.config.fieldsToRefresh);
    }

    @isTest
    public static void testRemoteActions() {
        GNE_SFA2_Account_Ctrl.DataWrapper sampleDataWrapper = new GNE_SFA2_Account_Ctrl.DataWrapper();
        String sampleDataWrapperJson = JSON.serialize(sampleDataWrapper);
        Account account = prepareAccountHCO();
        Address_vod__c address = createSampleAddress(account);
        Map<String, String> pageParameters = createPageParameters(account.Id,'1');
      
        Test.startTest();
        GNE_SFA2_Account_Ctrl.DataWrapper hideAddressReturnedWrapper =  GNE_SFA2_Account_Ctrl.hideAddress(sampleDataWrapperJson);
        GNE_SFA2_Account_Ctrl.DataWrapper changeTerritoryReturnedWrapper =  GNE_SFA2_Account_Ctrl.changeTerritoryAlignment(sampleDataWrapperJson);
        GNE_SFA2_Account_Ctrl.DataWrapper changeTierLevelReturnedWrapper =  GNE_SFA2_Account_Ctrl.changeTierLevelGoal(sampleDataWrapperJson);
        GNE_SFA2_Account_Ctrl.DataWrapper exclusionCheckReturnedWrapper =  GNE_SFA2_Account_Ctrl.exclusionCheckRequest(sampleDataWrapperJson);
        GNE_SFA2_Account_Ctrl.DataWrapper runThreeReturnedWrapper =  GNE_SFA2_Account_Ctrl.runThreeSixtyDegreeReport(sampleDataWrapperJson);
        GNE_SFA2_Account_Ctrl.DataWrapper getAccountReturnedWrapper =  GNE_SFA2_Account_Ctrl.getAccountTeam(sampleDataWrapperJson);
        GNE_SFA2_Account_Ctrl.DataWrapper changeAffiliationViewReturnedWrapper = GNE_SFA2_Account_Ctrl.changeAffiliationView(sampleDataWrapperJson);
        GNE_SFA2_Account_Ctrl.DataWrapper getClassificationHistoryReturnedWrapper = GNE_SFA2_Account_Ctrl.getClassificationHistory(sampleDataWrapperJson);
        GNE_SFA2_Account_Ctrl.DataWrapper updateAccountAttributesReturnedWrapper = GNE_SFA2_Account_Ctrl.updateAccountAttributes(sampleDataWrapperJson);
        GNE_SFA2_Account_Ctrl.DataWrapper updateProfilingReturnedWrapper = GNE_SFA2_Account_Ctrl.updateProfiling(sampleDataWrapperJson);
        List<GNE_SFA2_HCPtoFRMHCOMappingEngine.AccountMappingWrapper> getAccountMappingDataReturnedWrapper = GNE_SFA2_Account_Ctrl.getAccountMappingData(pageParameters);
        // GNE_SFA2_HCPtoFRMHCOMappingEngine.AccountMappingWrapper getNewHCPReturnedWrapper = GNE_SFA2_Account_Ctrl.getNewHCP(pageParameters);
        // GNE_SFA2_Base_Ctrl.DataWrapper getSBCConfigReturnedWrapper = GNE_SFA2_Account_Ctrl.getSBCConfig(pageParameters);

        Test.stopTest();

        System.assertNotEquals(null, hideAddressReturnedWrapper);
        System.assertNotEquals(null, changeTerritoryReturnedWrapper);
        System.assertNotEquals(null, changeTierLevelReturnedWrapper);
        System.assertNotEquals(null, exclusionCheckReturnedWrapper);
        System.assertNotEquals(null, runThreeReturnedWrapper);
        System.assertNotEquals(null, getAccountReturnedWrapper);
        System.assertNotEquals(null, changeAffiliationViewReturnedWrapper);
        System.assertNotEquals(null, getClassificationHistoryReturnedWrapper);
        System.assertNotEquals(null, updateAccountAttributesReturnedWrapper);
        System.assertNotEquals(null, updateProfilingReturnedWrapper);
        System.assertNotEquals(null, getAccountMappingDataReturnedWrapper);
        // System.assertNotEquals(null, getNewHCPReturnedWrapper); // TODO: put accId to page parameters
        // System.assertNotEquals(null, getSBCConfigReturnedWrapper); // TODO: resolve null reference

    }

    private static GNE_SFA2_Base_Ctrl.RelatedList createRelatedList(String name, String label, List<GNE_SFA2_Base_Ctrl.RelatedListField> fields){
        return new GNE_SFA2_Base_Ctrl.RelatedList(name, label, fields);
    }

    private static List<GNE_SFA2_Base_Ctrl.RelatedListField> createSampleListFields(){
        List<GNE_SFA2_Base_Ctrl.RelatedListField> relatedListFields = new List<GNE_SFA2_Base_Ctrl.RelatedListField>();
        for(Integer i=0; i<SAMPLE_LOOP_NUMBER; i++){
            relatedListFields.add(new GNE_SFA2_Base_Ctrl.RelatedListField('FieldName'+i,null,'reference',false));
        }
        return relatedListFields;
    }
    
    private static List<GNE_SFA2_Base_Ctrl.Section> createSampleSectionsWithFields(){
        List<GNE_SFA2_Base_Ctrl.Section> sections = new List<GNE_SFA2_Base_Ctrl.Section>();
        for(Integer i=0; i<SAMPLE_LOOP_NUMBER; i++){
            sections.add(new GNE_SFA2_Base_Ctrl.Section('SampleSectionName'+i,'SampleSectionLabel'+i, 0, null, createSampleFields(4)));
        }
        return sections;
    }

    private static List<GNE_SFA2_Base_Ctrl.RelatedList> createMultipleRelatedList(Integer iterations){
        List<GNE_SFA2_Base_Ctrl.RelatedList> relatedLists = new List<GNE_SFA2_Base_Ctrl.RelatedList>();
        for(Integer i=0; i<iterations; i++){
            relatedLists.add(createRelatedList('SampleName'+i, null, createSampleListFields()));
        }
        return relatedLists;
    }

    private static List<GNE_SFA2_Base_Ctrl.Field> createSampleFields(Integer iterations){
        List<GNE_SFA2_Base_Ctrl.Field> fields = new List<GNE_SFA2_Base_Ctrl.Field>();
        for(Integer i=0; i<iterations; i++){
            fields.add(new GNE_SFA2_Base_Ctrl.Field('SampleName'+i, 'SampleLabel'+i));
        }
        return fields;
    }

    private static SFA2_Configuration_Object_gne__c createSampleConf(){
        SFA2_Configuration_Object_gne__c conf = GNE_SFA2_Triggers_Test_Util.prepareSFA2_Configuration_Object_gne();
        insert conf;
        return conf;
    }

    private static SFA2_Configuration_Object_Detail_gne__c createSampleConfDetail(String name, Id confId, String APINameGne){
        SFA2_Configuration_Object_Detail_gne__c confDetail = new SFA2_Configuration_Object_Detail_gne__c(Name = name, Configuration_Object_ref_gne__c = confId, API_Name_gne__c = APINameGne);
        insert confDetail;
        return confDetail;
    }

    private static User prepareUser(String profileName, String appName, String brandName, String roleName, Boolean sfa2Mode, Boolean sfa2UIMode){
        Profile p = [SELECT Id FROM Profile WHERE Name = :profileName];
        User user = GNE_SFA2_Triggers_Test_Util.createUser(TEST_USER_NAME, p);
        insert new GNE_SFA2_User_App_Context_gne__c(
            Name = 'GNE SFA2 User Application Context (User)', 
            App_Name_gne__c = appName, 
            Brand_gne__c = brandName, 
            Role_gne__c = roleName, 
            SFA2_Mode_gne__c = sfa2Mode, 
            Run_in_SFA2_UI_gne__c = sfa2UIMode, 
            SetupOwnerId = user.Id
        );
        return user;
    }

    private static Account prepareAccountHCO(){
        Account account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO(TEST_ACCOUNT_NAME);
        insert account;
        return account;
    }

    private static Map<String, String> createPageParameters(Id accountId, String afdcOverrideFlag){
        return new Map<String, String>{
                'id' => accountId,
                'afdc.override' => afdcOverrideFlag
            };
    }

    private static GNE_SFA2_Account_Ctrl.DataWrapper getAccountDataWrapper(Account account, Map<String, String> pageParams){
        PageReference pr = Page.GNE_SFA2_Account;
        pr.getParameters().putAll(pageParams);
        Test.setCurrentPage(pr);
        GNE_SFA2_Account_Ctrl controller = new GNE_SFA2_Account_Ctrl(new ApexPages.StandardController(account));
        Map<String, String> pageParameters = ApexPages.currentPage().getParameters();
        return (GNE_SFA2_Account_Ctrl.DataWrapper)controller.init(pageParameters);
    }

    private static void createSetRelatedListRecordsSampleData(Account account, User user){
        IC_Calc_Sales_Roster_gne__c calcSalesRoster = createSampleCalcSalesRoster('ExampleBrand', 'SFA-US');
        SFA2_User_Sales_Roster_gne__c userRoster = createSampleUserRoster(user, 'PFG-Management', calcSalesRoster.Id);
        Product_vod__c parentProduct = createSampleProduct('Test', null, null, null);
        Product_vod__c childProduct = createSampleProduct(null, 'PFG', parentProduct.Id, parentProduct);
        String currentYear = GNE_SFA2_PFG_Util.currentYear();
        SFA2_PFG_Product_Limit_gne__c sampleLimit = createSampleProductLimit(currentYear, childProduct.Id, childProduct, false);
        PFG_Staging_Account_Limit_Exception_gne__c sampleAccountLimit = createSampleAccountLimit(account.Id, account, currentYear, childProduct.Id, childProduct, false, 4);
        SFA2_PFG_to_Account_Detail_gne__c sampleAccountDetail = createSampleeAccountDetail(account.Id, account, currentYear, childProduct.Id, childProduct);   
    }

    private static IC_Calc_Sales_Roster_gne__c createSampleCalcSalesRoster(String brandName, String type){
        IC_Calc_Sales_Roster_gne__c calcSalesRoster = new IC_Calc_Sales_Roster_gne__c(Brand_Name_gne__c = brandName, Type_gne__c = type);
        insert calcSalesRoster;
        return calcSalesRoster;
    }

    private static SFA2_User_Sales_Roster_gne__c createSampleUserRoster(User user, String role, Id ICCalcSalesRosterId){
        SFA2_User_Sales_Roster_gne__c userRoster = new SFA2_User_Sales_Roster_gne__c(User_gne__r = user, User_gne__c = user.Id, Role_gne__c = role,
            Sales_Roster_gne__c = ICCalcSalesRosterId);
        insert userRoster;
        return userRoster;
    }

    private static Product_vod__c createSampleProduct(String name, String type, Id parentProductId, Product_vod__c parentProductObject){
        Product_vod__c product = new Product_vod__c(Name = name, Product_Type_vod__c = type, Parent_Product_vod__c = parentProductId, Parent_Product_vod__r = parentProductObject);
        insert product;
        return product;
    }

    private static SFA2_PFG_Product_Limit_gne__c createSampleProductLimit(String year, Id productId, Product_vod__c productObject,  Boolean inactive){
        SFA2_PFG_Product_Limit_gne__c sampleLimit = new SFA2_PFG_Product_Limit_gne__c(Limit_Year_gne__c = year, Product_gne__c = productId,
            Product_gne__r = productObject, Inactive_gne__c = inactive);
        insert sampleLimit;
        return sampleLimit;
    }

    private static PFG_Staging_Account_Limit_Exception_gne__c createSampleAccountLimit(Id accountId, Account account, String year, Id productId, Product_vod__c productObject,
        Boolean logicalDeleteFlag , Integer exceptionQuantity){
        PFG_Staging_Account_Limit_Exception_gne__c sampleAccountLimit = new PFG_Staging_Account_Limit_Exception_gne__c(Account_gne__c = accountId, Account_gne__r = account, Limit_Year_gne__c = year,
            Product_gne__c = productId, Product_gne__r = productObject, Logical_Delete_Flag_gne__c = logicalDeleteFlag, Exception_Quantity_gne__c = exceptionQuantity);
        insert sampleAccountLimit;
        return sampleAccountLimit;
    }

    private static SFA2_PFG_to_Account_Detail_gne__c createSampleeAccountDetail(Id accountId, Account account, String year, Id productId, Product_vod__c productObject){
        SFA2_PFG_to_Account_Detail_gne__c sampleAccountDetail = new SFA2_PFG_to_Account_Detail_gne__c(Account_gne__c = accountId, Account_gne__r = account, Limit_Year_gne__c = year,
            Product_gne__c = productId, Product_gne__r = productObject);
        insert sampleAccountDetail;
        return sampleAccountDetail;
    }

    private static User_Preference_gne__c createSampleUserPreference(User user, Account account, String type, Boolean active, Address_vod__c address){
         User_Preference_gne__c  sampleUserPreference =  new User_Preference_gne__c(User_gne__c = user.id, User_gne__r = user, Account_gne__c = account.Id, Account_gne__r = account,
         Type_gne__c = 'HIDDENADDRESS', Active_gne__c = true, Address_gne__c = address.Id);
         insert sampleUserPreference;
         return sampleUserPreference;
    }

    private static Address_vod__c createSampleAddress(Account account){
        Address_vod__c   address =  GNE_SFA2_Triggers_Test_Util.prepareAddress_vod(account.Id, 'SampleName', true, 'SampleAddresName');
        insert address;
        return address;
    } 

    private static GNE_SFA2_Affiliation_Calculated_Profiles__c createSampleAffiliationProfiles(String name){
        GNE_SFA2_Affiliation_Calculated_Profiles__c affiliationCalculatedProfile = new GNE_SFA2_Affiliation_Calculated_Profiles__c(Name = name);
        insert affiliationCalculatedProfile;
        return affiliationCalculatedProfile;
    }
}