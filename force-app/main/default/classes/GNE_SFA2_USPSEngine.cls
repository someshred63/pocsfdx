global with sharing class GNE_SFA2_USPSEngine {
	
	private Enum apiType {Verify, CityStateLookup, ZipCodeLookup}
	private transient static String uspsUserId = '079GENEN5934';
    private transient static String uspsApiUrl = 'https://production.shippingapis.com/ShippingAPITest.dll';

    public static String addressValidate(Map<String, String> params) {
    	String request = GNE_SFA2_USPSUtil.buildAddressValidateRequest(uspsUserId, params);
    	return callUspsApi(String.valueOf(apiType.Verify), request);
    }

    public static String cityStateLookup(Map<String, String> params) {
    	String request = GNE_SFA2_USPSUtil.buildCityStateLookupRequest(uspsUserId, params);
    	return callUspsApi(String.valueOf(apiType.CityStateLookup), request);
    }

    public static String zipCodeLookup(Map<String, String> params) {
    	String request = GNE_SFA2_USPSUtil.buildZipCodeLookupRequest(uspsUserId, params);
    	return callUspsApi(String.valueOf(apiType.ZipCodeLookup), request);
    }

    private static String callUspsApi(String apiName, String request) {
    	HttpRequest req = new HttpRequest();
        String endPoint = uspsApiUrl + '?API=' + apiName + '&XML=' + EncodingUtil.urlEncode(request, 'UTF-8');
        System.debug('##### USPS Endpoint = ' + endPoint);
        req.setEndpoint(endPoint);
        req.setMethod('GET');
        req.setTimeout(120000);
        
        HTTPResponse res = (new Http()).send(req);
        System.debug('##### Status = ' + res.getStatus());
        System.debug('##### Status Code = ' + res.getStatusCode());
        System.debug('##### Body = ' + res.getBody());
        return GNE_SFA2_USPSUtil.parseResponse(res);
    }

    @RemoteAction
    @ReadOnly
    global static Set<String> getCityToAutoComplete(String searchValue) {
        Set<String> result = new Set<String>();
        for(USPS_Address_gne__c uspsAddr : Database.query('SELECT City_gne__c FROM USPS_Address_gne__c WHERE City_gne__c like \'%searchValue%\' GROUP BY City_gne__c')) {
            result.add(uspsAddr.City_gne__c);
        }

        return result;
    }

}