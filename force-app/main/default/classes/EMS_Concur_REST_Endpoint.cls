@RestResource(urlMapping='/system/v1.0/testconnection/*')
global with sharing class EMS_Concur_REST_Endpoint {
    public EMS_Concur_REST_Endpoint() {

    }

    @HttpGet
    global static void testConnection() {
    }
}