@RestResource(urlMapping='/territory')
global with sharing class Territory_Rest  {

    @HttpPost
    global static Map<String, List<String>> processRequest(Map<String, String> params) {
        List<String> result = new List<String>();
        for(Territory2 terr : Database.query('SELECT Name FROM Territory2 WHERE Name LIKE \'%' + params.get('name') + '%\' AND (NOT External_Id_gne__c like \'Inactive%\') ORDER BY Name LIMIT 200')) {
            result.add(terr.Name);
        }

        return new Map<String, List<String>>{'responseItems' => result};
    }

}