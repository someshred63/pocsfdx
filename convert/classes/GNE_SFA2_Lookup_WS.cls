@RestResource(urlMapping='/CustomLookupWS')
global without sharing class GNE_SFA2_Lookup_WS {

    @HttpPost 
    global static Map<String, List<sObject>> processRequest(Map<String, String> params) {
        List<sObject> result = new List<sObject>();
        String queryString = params.get('query');
        for(sObject objaccGr : Database.query(queryString)) {
            result.add(objaccGr);
        }

        return new Map<String, List<sObject>>{'responseItems' => result};
    }
}