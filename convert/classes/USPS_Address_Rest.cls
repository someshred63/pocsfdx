@RestResource(urlMapping='/uspsAddress')
global without sharing class USPS_Address_Rest  {

    @HttpPost 
    global static Map<String, List<String>> processRequest(Map<String, String> params) {
        List<String> result = new List<String>();
        if(params.containsKey('citySearchValue')) {
            for(AggregateResult addr : Database.query('SELECT City_gne__c FROM USPS_Address_gne__c WHERE City_gne__c LIKE \'' + params.get('citySearchValue') + '%\' ' + (params.containsKey('state') ? 'AND State_gne__c = \'' + params.get('state') + '\' ' : '') + 'GROUP BY City_gne__c LIMIT 200')) {
                result.add(String.valueOf(addr.get('City_gne__c')));
            }
        } else {
            List<USPS_Address_gne__c> ua = new List<USPS_Address_gne__c>();
            if(params.containsKey('city')) {
                String city = params.get('city');
                ua = Database.query('SELECT Id FROM USPS_Address_gne__c WHERE City_gne__c = \'' + city + '\' ' + (params.containsKey('state') ? 'AND State_gne__c = \'' + params.get('state') + '\' ' : '') + 'LIMIT 1');
            }
            for(USPS_Address_gne__c addr : Database.query('SELECT Zip_gne__c FROM USPS_Address_gne__c WHERE Zip_gne__c LIKE \'%' + params.get('zipSearchValue') + '%\' ' + ( !ua.isEmpty() ? 'AND City_gne__c = \'' + params.get('city') + '\' ' : '') + (params.containsKey('state') ? 'AND State_gne__c = \'' + params.get('state') + '\' ' : '') + 'ORDER BY Zip_gne__c ASC LIMIT 200')) {
                result.add(addr.Zip_gne__c);
            }
        }

        return new Map<String, List<String>>{'responseItems' => result};
    }

}