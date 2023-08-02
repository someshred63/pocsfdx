public with sharing class EMS_Concur_OAuth {

    public EMS_Concur_OAuth() {

    }

    public static EMS_Concur_Util.ConcurWebserviceResponse requestAccessToken(String username, String password) {
        EMS_Concur_Settings_gne__c concurSettings = EMS_Concur_Util.getConcurSettings();
        String endpoint = concurSettings.End_Point_gne__c + '/net2/oauth2/accesstoken.ashx';
        String method = 'GET';
        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        req.setEndpoint(endpoint);
        req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(username + ':' + password)));
        req.setHeader('X-ConsumerKey', concurSettings.Consumer_Key_gne__c);

        Http http = new Http();
        HttpResponse resp = http.send(req);

        if (resp.getStatusCode() != 200) {
            EMS_Concur_Util.logError(endpoint, Decimal.valueOf(resp.getStatusCode()), resp.getStatus(), req.getBody(), method);
        }

        EMS_Concur_Util.ConcurWebserviceResponse response = new EMS_Concur_Util.ConcurWebserviceResponse(resp.getStatusCode(), resp.getBody());

        return response;
    }

    public static EMS_Concur_Util.ConcurWebserviceResponse refreshToken() {
        EMS_Concur_Settings_gne__c concurSettings = EMS_Concur_Util.getConcurSettings();
        String endpoint = concurSettings.End_Point_gne__c + '/net2/oauth2/getaccesstoken.ashx?refresh_token=' + concurSettings.Refresh_Token_gne__c + '&client_id=' + concurSettings.Consumer_Key_gne__c
                + '&client_secret=' + concurSettings.Consumer_Secret_gne__c;
        String method = 'GET';
        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        req.setEndpoint(endpoint);
        req.setHeader('Authorization', 'OAuth ' + concurSettings.Access_Token_gne__c);


        Http http = new Http();
        HttpResponse resp = http.send(req);

        if (resp.getStatusCode() != 200) {
            EMS_Concur_Util.logError(endpoint, Decimal.valueOf(resp.getStatusCode()), resp.getStatus(), req.getBody(), method);
        }

        EMS_Concur_Util.ConcurWebserviceResponse response = new EMS_Concur_Util.ConcurWebserviceResponse(resp.getStatusCode(), resp.getBody());

        return response;
    }

    public static EMS_Concur_Util.ConcurWebserviceResponse revokeToken() {
        EMS_Concur_Settings_gne__c concurSettings = EMS_Concur_Util.getConcurSettings();
        String endpoint = concurSettings.End_Point_gne__c + '/net2/oauth2/revoketoken.ashx?token=' + concurSettings.Access_Token_gne__c;
        String method = 'POST';
        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        req.setEndpoint(endpoint);
        req.setHeader('Authorization', 'OAuth ' + concurSettings.Access_Token_gne__c);


        Http http = new Http();
        HttpResponse resp = http.send(req);

        if (resp.getStatusCode() != 200) {
            EMS_Concur_Util.logError(endpoint, Decimal.valueOf(resp.getStatusCode()), resp.getStatus(), req.getBody(), method);
        }

        EMS_Concur_Util.ConcurWebserviceResponse response = new EMS_Concur_Util.ConcurWebserviceResponse(resp.getStatusCode(), resp.getBody());

        return response;
    }
}