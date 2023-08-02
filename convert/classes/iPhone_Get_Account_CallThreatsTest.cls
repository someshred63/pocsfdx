@isTest
private class iPhone_Get_Account_CallThreatsTest {
    @testSetup
    static void testData() {
        Map<String, Id> name2RtId = GNE_FRM_TestUtilities.getAccountRecordTypes();
        Map<String, Id> ids2ProfilesMap = GNE_FRM_TestUtilities.getProfiles();
        User user1 = GNE_FRM_TestUtilities.createUser('TESTUSERXXXX', ids2ProfilesMap.get('GNE-Field'), true);          
    }
    
    @isTest
    static void testResponse() {
        User amUser = [SELECT External_ID_gne__c FROM User WHERE Email = 'testuserxxxxuser@gene.com' LIMIT 1];
        
        System.runAs(amUser) {
            Product_vod__c product = new Product_Vod__c(Name='Test Prod');
			insert product;
            
            Account testAccount = GNE_FRM_TestUtilities.createAccount('Axxxx Bxxxxx', 'Pharmacy_vod', 'Pharmacy', true);
        	Call2_vod__c testCall = new Call2_vod__c(Status_vod__c = 'Submitted_vod', Account_vod__c = testAccount.Id, Call_Datetime_vod__c = System.today().addDays(-2));
            insert testCall;            
            
        	Call2_Threat_vod__c callThreat = new Call2_Threat_vod__c(
                Book_of_Business__c = 'Managed Medicaid',
                Call2_vod__c = testCall.Id,
                Risk_Level__c = 'High (LT Aware)'            
            );
            insert callThreat;
            
            Test.startTest();
            	iPhone_Commons_gne.RestResponse response = iPhone_Get_Account_CallThreats_gne.processRequest(null, amUser.External_ID_gne__c, new List<String> {testAccount.Id}, false, '7.04');
            Test.stopTest();
            
            iPhone_Commons_gne.DeltaRecordsResponse extendsResp = (iPhone_Commons_gne.DeltaRecordsResponse)response;
            
            System.assertEquals(1, extendsResp.records.size());
            iPhone_Get_Account_CallThreats_gne.GetAccountCallCallThreatRecord resRecord = (iPhone_Get_Account_CallThreats_gne.GetAccountCallCallThreatRecord)extendsResp.records[0];
            System.assertEquals('Managed Medicaid', resRecord.bob);
            System.assertEquals('High (LT Aware)', resRecord.rlvl);
        }              
    }
}