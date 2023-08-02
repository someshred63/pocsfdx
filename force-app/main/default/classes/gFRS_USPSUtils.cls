/**
 * @author GFRS Dev Team
 * @date 25/05/2018
 * @description Utilities class for handling USPS API.
 *                  This class allows to call API, get response as String and parse response to USPSAddress object
 */

public with sharing class gFRS_USPSUtils {

    public Enum uspsApiType {
        Verify, CityStateLookup, ZipCodeLookup
    }

    public transient static String defaultUspsApiEndpoint {
        get {
            return GFRS_OrgSettings__c.getOrgDefaults().USPS_Endpoint__c;
        }
        set;
    }
    public transient static String defaultUspsUsername {
        get {
            return GFRS_OrgSettings__c.getOrgDefaults().USPS_Username__c;
        }
        set;
    }

    /**
     * Method to build XML request parameters for ZipCodeLookup API.
     *
     * @param uspsUserId USPS Username for API usage.
     * @param params Parameters map for ZipCodeLookup USPS API (address1, address2, city, state).
     *
     * @return XML request as String.
     */
    public static String buildZipCodeLookupRequest(String uspsUserId, Map<String, String> params) {
        String result = '<ZipCodeLookupRequest USERID="' + uspsUserId + '"><Address>';
        result += '<Address1>' + (params.containsKey('address1') && String.isNotBlank(params.get('address1')) ? params.get('address1') : '') + '</Address1>';
        result += '<Address2>' + (params.containsKey('address2') && String.isNotBlank(params.get('address2')) ? params.get('address2') : '') + '</Address2>';
        result += '<City>' + (params.containsKey('city') && String.isNotBlank(params.get('city')) ? params.get('city') : '') + '</City>';
        result += '<State>' + (params.containsKey('state') && String.isNotBlank(params.get('state')) ? params.get('state') : '') + '</State>';
        result += '</Address></ZipCodeLookupRequest>';
        return result;
    }

    /**
     * Method to build XML request parameters for CityStateLookup API
     *
     * @param uspsUserId USPS Username for API usage.
     * @param zipCode zipCode String.
     *
     * @return XML request as String.
     */
    public static String buildCityStateLookupRequest(String uspsUserId, String zipCode) {
        String result = '<CityStateLookupRequest USERID="' + uspsUserId + '"><ZipCode ID="0">';
        result += '<Zip5>' + (String.isNotBlank(zipCode) ? zipCode : '') + '</Zip5>';
        result += '</ZipCode></CityStateLookupRequest>';
        return result;
    }

    public class USPSAddress {
        public String address1;
        public String address2;
        public String city;
        public String state;
        public String zip5;
        public String zip4;
        public String errorDescription;
        public Boolean error;
    }

    /**
     * Method to call USPS API.
     *
     * @param apiName One of allowed API names (use for example String.valueOf(gFRS_USPSUtils.uspsApiType.ZipCodeLookup) ).
     * @param request XML as String request.
     *
     * @return Response Body from API call.
     */
    public static String callUSPSApi(String apiName, String request) {
        HttpRequest req = new HttpRequest();

        String endpoint = getApiEndpoint(apiName, request);

        req.setEndpoint(endpoint);
        req.setMethod('GET');

        Http http = new Http();
        HTTPResponse res = http.send(req);

        return res.getStatusCode() == 200 ? res.getBody() : '';
    }

    /**
     * Method to parse XML response from USPS API.
     *
     * @param responseBody String with response body from API call.
     *
     * @return parsed data stored in USPSAddress object.
     */
    public static USPSAddress parseUSPSApiCallResponse(String responseBody) {
        USPSAddress address = new USPSAddress();

        Dom.Document doc = new Dom.Document();
        doc.load(responseBody);

        Dom.XmlNode response = doc.getRootElement();

        if (String.isNotBlank(getXmlError(response))) {
            address.error = true;
            address.errorDescription = getXmlError(response);
        } else {
            if (checkXmlRoot(response, 'Address')) {
                String root = 'Address';
                address.error = false;
                address.address1 = getXmlElement(response, root, 'Address1');
                address.address2 = getXmlElement(response, root, 'Address2');
                address.city = getXmlElement(response, root, 'City');
                address.state = getXmlElement(response, root, 'State');
                address.zip5 = getXmlElement(response, root, 'Zip5');
                address.zip4 = getXmlElement(response, root, 'Zip4');
                address.errorDescription = getXmlElement(response, root, 'ReturnText');
            } else if (checkXmlRoot(response, 'ZipCode')) {
                String root = 'ZipCode';
                address.city = getXmlElement(response, root, 'City');
                address.state = getXmlElement(response, root, 'State');
                address.error = false;
            }
        }
        return address;
    }

    private static String getXmlElement(Dom.XmlNode node, String root, String child) {
        Dom.XmlNode element = node.getChildElement(root, null).getChildElement(child, null);
        return element == null ? '' : element.getText();
    }

    private static String getXmlError(Dom.XmlNode node) {
        Dom.XmlNode element;
        if (checkXmlRoot(node, 'Address')) {
            return getErrorMessage(node, 'Address');
        } else if (checkXmlRoot(node, 'ZipCode')) {
            return getErrorMessage(node, 'ZipCode');
        }
        return '';
    }

    private static Boolean checkXmlRoot(Dom.XmlNode node, String root) {
        return node.getChildElement(root, null) == null ? false : true;
    }

    private static String getErrorMessage(Dom.XmlNode node, String root) {
        Dom.XmlNode element = node.getChildElement(root, null).getChildElement('Error', null);
        return element == null ? '' : element.getChildElement('Description', null).getText();
    }

    private static String getApiEndpoint(String apiName, String request) {
        return defaultUspsApiEndpoint + '?API=' + apiName + '&XML=' + EncodingUtil.urlEncode(request, 'UTF-8');
    }
}