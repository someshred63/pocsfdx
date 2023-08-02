@RestResource(urlMapping='/AccountGroup')
global with sharing class AccountGroupREST {

    @HttpPost 
    global static Map<String, List<String>> processRequest(Map<String, String> params) {
        List<String> result = new List<String>();
        for(Account_Group_gne__c accGr : Database.query(
            'SELECT Name '+
            'FROM Account_Group_gne__c '+
            'WHERE Name LIKE \'%' + params.get('name') + '%\' ORDER BY Name LIMIT 5')
        ) {
            result.add(accGr.Name);
        }

        return new Map<String, List<String>>{'responseItems' => result};
    }
}