/** @date 8/31/2013
* @Author Paweł Sprysak
* @description Util Class for SIMS Service
*/
public with sharing class VDST_SIMS_Service {

    public final String SIMS_WEBSERVICE_ENDPOINT;
    public final String SIMS_WEBSERVICE_USERNAME;
    public final String SIMS_WEBSERVICE_PASSWORD;
    public final String SIMS_APP;

    /** @date 8/31/2013
    * @Author Paweł Sprysak
    * @description VDST_SIMS_Service constructor
    */
    public VDST_SIMS_Service() {
        SIMS_WEBSERVICE_ENDPOINT = VDST_Utils.getCustomSettingsIntExt().SIMS_Endpoint__c;
        SIMS_WEBSERVICE_USERNAME = VDST_Utils.getCustomSettingsIntExt().SIMS_Username__c;
        SIMS_WEBSERVICE_PASSWORD = VDST_Utils.getCustomSettingsIntExt().SIMS_Password__c;
        SIMS_APP = 'gssp';
    }

    /** @date 8/31/2013
    * @Author Paweł Sprysak
    * @description Register SIMS User by User Id
    * @param String userId
    * @return Boolean
    */
    public Boolean registerSIMSUser(String userId) {
        System.debug('---------- registerSIMSUser() Start');
        User usr = findUserById(userId);
        if(usr == null) {
            System.debug('---------- registerSIMSUser() User not found Id - ' + userId);
            return false;
        }
        Boolean result = createSimsUser(usr.FirstName, usr.LastName, '0', usr.Email);
        System.debug('---------- registerSIMSUser() Result - ' + result);
        return result;
    }

    /** @date 8/31/2013
    * @Author Paweł Sprysak
    * @description Register SIMS User by User object
    * @param User usr
    * @return Boolean
    */
    public Boolean registerSIMSUser(User usr) {
        System.debug('---------- registerSIMSUser() Start');
        if(usr == null) {
            System.debug('---------- registerSIMSUser() null User');
            return false;
        }
        Boolean result = createSimsUser(usr.FirstName, usr.LastName, '0', usr.Email);
        System.debug('---------- registerSIMSUser() Result - ' + result);
        return result;
    }

    /** @date 8/31/2013
    * @Author Paweł Sprysak
    * @description Create SIMS User
    * @param String firstName
    * @param String lastName
    * @param String phone
    * @param String email
    * @return Boolean
    */
    public Boolean createSimsUser(String firstName, String lastName, String phone, String email) {
        System.debug('---------- createSimsUser() Start');
        try {
            String jsonContent = prepareJsonRequestContent(firstName, lastName, phone, email);
            HttpResponse response = doJsonWsRequest(jsonContent);
            Boolean status = checkSimsWsResponseStatus(response);
            return status;
        }
        catch(Exception e) {
            System.debug('----------------- CREATE SIMS USER ERROR.');
            System.debug(Logginglevel.ERROR, e);
            return false;
        }
    }

    /** @date 8/31/2013
    * @Author Paweł Sprysak
    * @description Prepare JSON Request content for SIMS User Creation
    * @param String firstName
    * @param String lastName
    * @param String phone
    * @param String email
    * @return String
    */
    private String prepareJsonRequestContent(String firstName, String lastName, String phone, String email) {
        System.debug('-------------- Preparing JSON request content for SIMS webservice');

        SimsCreateUserData simsCreateUserData = new SimsCreateUserData(
            firstName,
            lastName,
            phone,
            email,
            SIMS_APP
        );

        String reqBodyJson = JSON.serialize(simsCreateUserData);
        return reqBodyJson;
    }

    /** @date 8/31/2013
    * @Author Paweł Sprysak
    * @description Send HTTP Request with JSON for SIMS User Creation
    * @param String jsonContent
    * @return HttpResponse
    */
    private HttpResponse doJsonWsRequest(String jsonContent) {
        System.debug('----------------- JSON request content: ' + jsonContent);

        HttpRequest req = new HttpRequest();
        req.setEndpoint(this.SIMS_WEBSERVICE_ENDPOINT);
        req.setBody(jsonContent);
        req.setMethod('POST');
        req.setHeader('Content-type', 'application/json');
        req.setHeader('Content-length', String.valueOf(req.getBody().length()));

        Blob headerValue = Blob.valueOf(SIMS_WEBSERVICE_USERNAME + ':' + SIMS_WEBSERVICE_PASSWORD);
        String authorizationHeader = 'Basic ' +
        EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        //req.setHeader('Authorization', 'Basic Z29yZG9uLmZyZWVtYW5AbWFpbGluYXRvci5jb206bGV0bWVpbg==');
        //req.setCompressed(true); Causes 'char(31) error'.

        System.debug('SIMS webservice request ready, url: ' + this.SIMS_WEBSERVICE_ENDPOINT);
        Http httpr = new Http();
        HttpResponse res = httpr.send(req);
        return res;
    }

    /** @date 8/31/2013
    * @Author Paweł Sprysak
    * @description Check Sent HTTP Request with JSON for SIMS User Creation Status
    * @param HttpResponse response
    * @return Boolean
    */
    private Boolean checkSimsWsResponseStatus(HttpResponse response) {
        if (response.getBody().contains('exception')) {
            System.debug('-------------- SIMS RESPONSE EXCEPTION');
            SimsExceptionResponse ser = (SimsExceptionResponse) JSON.deserialize(response.getBody(), SimsExceptionResponse.class);
            System.debug(Logginglevel.ERROR, response.getBody());
            String content = subString(ser.exceptionObj.stackTrace);
            //AGS_ST_Utils.logRegistrationError('AGS_ST_SIMSRegistrationHelper__gne', content, ser.exceptionObj.message, 'checkSimsWsResponseStatus', null, null, null);
            return false;
        }
        if ((response.getStatusCode() != 200) && (response.getStatusCode() != 201)) {
            System.debug('-------------- SIMS RESPONSE NOT SUCCESS');
            String content = subString(response.getBody());
            String errorMessage = 'Error ' + response.getStatusCode() + ':' + response.getStatus();
            System.debug(Logginglevel.ERROR, errorMessage);
            //AGS_ST_Utils.logRegistrationError('AGS_ST_SIMSRegistrationHelper__gne', content, errorMessage, 'checkSimsWsResponseStatus', null, null, null);
            return false;
        }

        System.debug('-------------- SIMS user creating WS response: statusCode: ' + response.getStatusCode() + ', status: ' + response.getStatus() + ', user sims id (body): ' + response.getBody());
        return true;
    }

    /** @date 8/31/2013
    * @Author Paweł Sprysak
    * @description Get User by Id
    * @param String userId
    * @return User
    */
    public User findUserById(String userId) {
        try {
            return [SELECT Email,FirstName,Id,IsActive,LastName,Phone FROM User where id=:userId];
        }
        catch(Exception e) {
            System.debug('--------- UserId Search Error ' + e.getMessage());
        }
        return null;
    }

    /** @date 8/31/2013
    * @Author Paweł Sprysak
    * @description Util method for trimming String values with length exceeding 254 characters
    * @param String s
    * @return String
    */
    public String subString(String s) {
        if(s == null)
            return '';
        if(s.length()>254)
            return s.substring(254);
        return s;
    }

    /** @date 8/31/2013
    * @Author Paweł Sprysak
    * @description Wrapper class for User
    */
    public class SimsCreateUserData {
        public List<String> apps    {get;set;}
        public String firstName     {get;set;}
        public String lastName      {get;set;}
        public String phone         {get;set;}
        public String email         {get;set;}

        public SimsCreateUserData(String firstName, String lastName, String phone, String email, String app) {
            this.apps = new List<String>();
            this.apps.add(app);
            //this.apps.add('mas');
            //this.apps.add('elib');

            this.firstName = firstName;
            this.lastName = lastName;
            this.phone = phone;
            this.email = email;
        }
    }

    /** @date 8/31/2013
    * @Author Paweł Sprysak
    * @description Wrapper class for SIMS Exception Response
    */
    public class SimsExceptionResponse {
        public SimsExceptionClass exceptionObj;

        public SimsExceptionResponse() {
            exceptionObj = new SimsExceptionClass();
        }
    }

    /** @date 8/31/2013
    * @Author Paweł Sprysak
    * @description SIMS Exception class
    */
    public class SimsExceptionClass {
        public String message;
        public String stackTrace;

        public SimsExceptionClass() {
            this.message = '';
            this.stackTrace = '';
        }
    }
}