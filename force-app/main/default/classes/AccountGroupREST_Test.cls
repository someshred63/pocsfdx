@isTest
private class AccountGroupREST_Test {
    @testSetup
    private static void initData(){
        Account_Group_gne__c ag1 = new Account_Group_gne__c(Name = 'Group 1');
        Account_Group_gne__c ag2 = new Account_Group_gne__c(Name = 'Group 2');
        Account_Group_gne__c ag3 = new Account_Group_gne__c(Name = 'Group 3');
        Account_Group_gne__c ag4 = new Account_Group_gne__c(Name = 'Test G');
        insert new List<Account_Group_gne__c>{ag1, ag2, ag3, ag4};
    }
    
    @isTest
    static void REST_Service_Test() {
        Map<String, String> param = new Map<String, String>{
            'name' => 'Group'
        };
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/AccountGroup';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        	Map<String, List<String>> response = AccountGroupREST.processRequest(param);
        Test.stopTest();
        
        System.assertEquals(1, response.size());
        System.assertEquals(3, response.get('responseItems').size());
        for(String s: response.get('responseItems')){
            System.assert(s.contains('Group'));
        }
    }
}