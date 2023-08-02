/**
 * @author GFRS Dev Team
 * @date 25/05/2018
 * @description Main controller for gFRS_AddressAutocomplete.component
 *                  This class uses Google Maps API for autocomplete feature and USPS API to validate Zip Code with Po Box
 *                  according to address.
 */

global with sharing class gFRS_AddressAutocompleteController {

    private transient String uspsUsername { get; set; }
    private transient String uspsEndpoint { get; set; }
    public Boolean uspsApiEnabled { get; set; }

    public String googleMapsApiEndpoint { get; set; }
    public String googleMapsApiKey { get; private set; }

    public Id recordId { get; set; }
    public String objName { get; set; }
    public Boolean internal { get; set; }

    public String streetName { get; set; }
    public String cityName { get; set; }
    public String stateName { get; set; }
    public String postalCodeNumber { get; set; }
    public String countryName { get; set; }
    public String provinceName { get; set; }
    public String poBox { get; set; }

    public sObject obj {
        get {
            if (obj == null) {
                String objectQuery = 'Select Name,';
                objectQuery += String.isNotBlank(streetName) ? streetName + ',' : '';
                objectQuery += String.isNotBlank(provinceName) ? provinceName + ',' : '';
                objectQuery += String.isNotBlank(cityName) ? cityName + ',' : '';
                objectQuery += String.isNotBlank(stateName) ? stateName + ',' : '';
                objectQuery += String.isNotBlank(postalCodeNumber) ? postalCodeNumber + ',' : '';
                objectQuery += String.isNotBlank(countryName) ? countryName : '';

                objectQuery += ' From ' + objName + ' Where Id = \'' + recordId + '\'';

                obj = database.query(objectQuery);
            }
            return obj;
        }
        set;
    }

    public gFRS_AddressAutocompleteController() {
        loadApi();
    }

    @RemoteAction
    global static Map<String, String> validateUSPSZipCode(String zip5) {
        gFRS_USPSUtils.USPSAddress uspsAddress = new gFRS_USPSUtils.USPSAddress();
        String request = gFRS_USPSUtils.buildCityStateLookupRequest(gFRS_USPSUtils.defaultUspsUsername, zip5);
        String response = gFRS_USPSUtils.callUSPSApi(String.valueOf(gFRS_USPSUtils.uspsApiType.CityStateLookup), request);
        uspsAddress = gFRS_USPSUtils.parseUSPSApiCallResponse(response);

        Map<String, String> result = new Map<String, String>();
        if (String.isNotBlank(uspsAddress.city)) {
            result.put('city', uspsAddress.city);
        }
        if (String.isNotBlank(uspsAddress.state)) {
            result.put('state', uspsAddress.state);
        }
        if (!String.isBlank(uspsAddress.errorDescription)) {
            result.put('error', uspsAddress.errorDescription);
        }
        result.put('xmlResponse', response);
        return result;
    }

    public void loadApi() {
        GFRS_OrgSettings__c settings = GFRS_OrgSettings__c.getOrgDefaults();
        uspsUsername = gFRS_USPSUtils.defaultUspsUsername;
        uspsEndpoint = gFRS_USPSUtils.defaultUspsApiEndpoint;

        googleMapsApiKey = settings.Google_Maps_API_Key__c;
        googleMapsApiEndpoint = String.format(settings.Google_Maps_API_Endpoint__c, new List<String>{
                googleMapsApiKey
        });

        //uspsApiEnabled = isUSPSApiActive();
    }

    public PageReference save() {

        try {
            update obj;
            return new PageReference('/' + obj.Id);
        } catch (Exception ex) {

            if (!ApexPages.hasMessages()) {
                ApexPages.addMessages(ex);
            }

            system.debug(LoggingLevel.ERROR, 'Autocomplete Error while saving object: ' + ex);
            return null;
        }
    }

    public PageReference cancel() {
        return new PageReference('/' + obj.Id);
    }

    private Boolean isUSPSApiActive() {
        String request = gFRS_USPSUtils.buildZipCodeLookupRequest(uspsUsername, new Map<String, String>{
                'address2' => '1600 Pennsylvania Ave., NW', 'city' => 'Washington', 'state' => 'DC', 'zip5' => '20500'
        });
        return String.isBlank(gFRS_USPSUtils.callUSPSApi(String.valueOf(gFRS_USPSUtils.uspsApiType.ZipCodeLookup), request)) ? false : true;
    }

}