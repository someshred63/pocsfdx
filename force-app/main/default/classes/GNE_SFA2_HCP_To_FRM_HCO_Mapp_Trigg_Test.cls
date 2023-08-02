@isTest
private class GNE_SFA2_HCP_To_FRM_HCO_Mapp_Trigg_Test {
    @testSetup
    static void initData() {
        Account aHCO = GNE_FRM_TestUtilities.createAccount('Test Clinic HCO', 'FRM_HCO', 'Clinic', false);
        Account aHCP = GNE_FRM_TestUtilities.createAccount('Prof HCP', 'Professional_vod', 'Health Care Professional', false, true);
        insert new List<Account> {aHCO, aHCP};

        Address_vod__c hcpAddress1 = GNE_FRM_TestUtilities.createAddress('514 East Alvin Avenue', aHCP.Id, 'SANTA MARIA', 'CA', '93454', false);
        Address_vod__c hcpAddress2 = GNE_FRM_TestUtilities.createAddress('515 East Alvin Avenue', aHCP.Id, 'SANTA MARIA', 'CA', '93454', false);
        insert new List<Address_vod__c> {hcpAddress1, hcpAddress2};

        FRM_HCO_Mapping_gne__c p1 = new FRM_HCO_Mapping_gne__c(FRM_HCO_Account_gne__c = aHCO.Id, HCP_Account_gne__c = aHCP.Id, HCP_Address_gne__c = hcpAddress1.Id, PACT_Prescriber_Id_gne__c = '00163000001vRjs', PACT_Prescriber_Address_Id_gne__c = 'a0063000000qemZ');
        insert new List<FRM_HCO_Mapping_gne__c> {p1};

        HCP_To_FRM_HCO_Mapping_gne__c sm1 = new HCP_To_FRM_HCO_Mapping_gne__c(HCP_Account_gne__c = aHCP.Id, HCP_Address_gne__c = hcpAddress2.Id, PACT_Prescriber_Id_gne__c = '00163000001vRjg', PACT_Prescriber_Address_Id_gne__c = 'a0063000000qemV');
        insert new List<HCP_To_FRM_HCO_Mapping_gne__c> {sm1};
    }

    @isTest
    static void testAvoidMappingsDuplicate() {
        List<HCP_To_FRM_HCO_Mapping_gne__c> sm = [SELECT HCP_Account_gne__c, HCP_Address_gne__c FROM HCP_To_FRM_HCO_Mapping_gne__c];
        List<FRM_HCO_Mapping_gne__c> fhm = [SELECT HCP_Account_gne__c, HCP_Address_gne__c FROM FRM_HCO_Mapping_gne__c];

        HCP_To_FRM_HCO_Mapping_gne__c newSMDuplicateWithSM = new HCP_To_FRM_HCO_Mapping_gne__c(HCP_Account_gne__c = sm[0].HCP_Account_gne__c,
                HCP_Address_gne__c = sm[0].HCP_Address_gne__c
            );

        HCP_To_FRM_HCO_Mapping_gne__c newSMDuplicateWithFHM = new HCP_To_FRM_HCO_Mapping_gne__c(HCP_Account_gne__c = fhm[0].HCP_Account_gne__c,
                HCP_Address_gne__c = fhm[0].HCP_Address_gne__c
            );

        Test.startTest();
        try {
            insert newSMDuplicateWithSM;
        } catch(Exception e) {
            System.AssertEquals(e.getMessage().contains(System.Label.GNE_SFA2_ErrMsg_Mapping_Duplicate), true);  
        } 

        try {
            insert newSMDuplicateWithFHM;
        } catch(Exception e) {
            System.AssertEquals(e.getMessage().contains(System.Label.GNE_SFA2_ErrMsg_Mapping_Duplicate), true);  
        } 
        Test.stopTest();
    }
}