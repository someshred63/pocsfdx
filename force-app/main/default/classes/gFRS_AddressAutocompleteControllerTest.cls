/**
 * Created by golisk on 20.12.2017.
 */

@IsTest
private class gFRS_AddressAutocompleteControllerTest {

    public class USPSApiResponseMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/xml');
            res.setBody('<?xml version="1.0" encoding="UTF-8"?><CityStateLookupResponse><ZipCode ID="0"><Zip5>20500</Zip5><City>WASHINGTON</City><State>DC</State></ZipCode></CityStateLookupResponse>');
            res.setStatusCode(200);
            return res;
        }
    }

    @TestSetup
    static void setupCustomSettings() {
        GFRS_OrgSettings__c cs = GFRS_OrgSettings__c.getOrgDefaults();
        cs.Google_Maps_API_Key__c = 'KEY1';
        cs.Google_Maps_API_Endpoint__c = 'https://api.example.com/?key={0}';
        insert cs;

        Account account = gFRS_TestCreationUtils.createAccount('Test Account');
        insert account;
        GFRS_Organization__c org = gFRS_TestCreationUtils.createOrganization('Test Org', account);
        insert org;
        GFRS_Location__c location = gFRS_TestCreationUtils.createLocation('Test Location', org.id);
        location.Department_Chapter_Country__c = 'United States';
        insert location;
    }

    @IsTest
    static void testLoadAPIKeysCustomSettingsOK() {
        Test.setMock(HttpCalloutMock.class, new USPSApiResponseMock());

        Test.startTest();
        gFRS_AddressAutocompleteController controller = new gFRS_AddressAutocompleteController();
        Test.stopTest();

        GFRS_OrgSettings__c cs = GFRS_OrgSettings__c.getOrgDefaults();

        String googleEndpoint = cs.Google_Maps_API_Endpoint__c.remove('{0}') + cs.Google_Maps_API_Key__c;

        System.assertEquals(cs.Google_Maps_API_Key__c, controller.googleMapsApiKey);
        System.assertEquals(googleEndpoint, controller.googleMapsApiEndpoint);
        //System.assert(controller.uspsApiEnabled);
    }

    @IsTest
    static void testSave() {
        Test.setMock(HttpCalloutMock.class, new USPSApiResponseMock());

        Test.startTest();
        gFRS_AddressAutocompleteController controller = new gFRS_AddressAutocompleteController();
        Test.stopTest();

        GFRS_OrgSettings__c cs = GFRS_OrgSettings__c.getOrgDefaults();
        GFRS_Location__c location = [SELECT Id, State__c, Zip__c, Department_Chapter_Country__c FROM GFRS_Location__c LIMIT 1];

        controller.stateName = 'State__c';
        controller.postalCodeNumber = 'Zip__c';
        controller.countryName = 'Department_Chapter_Country__c';
        controller.recordId = location.Id;
        controller.objName = 'GFRS_Location__c';

        controller.save();

        System.assertEquals(location.Zip__c, controller.obj.get('Zip__c'));
        System.assertEquals(location.State__c, controller.obj.get('State__c'));
        System.assertEquals(location.Department_Chapter_Country__c, controller.obj.get('Department_Chapter_Country__c'));

        controller.cancel();
    }

    @IsTest
    static void testRemoteAction() {
        Test.setMock(HttpCalloutMock.class, new USPSApiResponseMock());

        Test.startTest();
        Map<String, String> response = gFRS_AddressAutocompleteController.validateUSPSZipCode('20500');
        System.assertEquals('WASHINGTON', response.get('city'));
        System.assertEquals('DC', response.get('state'));
        Test.stopTest();
    }
}