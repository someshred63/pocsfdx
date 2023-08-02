public class Concur_Oauth {

    public static ConcurOauthResponse getAccessToken(Boolean forceRefresh, Boolean forceRequestNewToken) {
        Integer tokenTimeBuffer = -60;
        ConcurOauthResponse result = null;
        Concur_Settings_gne__c concurSettings = ConcurUtil.getConcurSettings();
        if (forceRequestNewToken) {
            result = Concur_Oauth.requestAccessToken(concurSettings);
        } else if (forceRefresh && String.isNotBlank(concurSettings.Refresh_Token__c)) {
            result = Concur_Oauth.refreshToken(concurSettings);
        } else if (String.isNotBlank(concurSettings.Access_Token__c) && concurSettings.Token_Expires__c != null && concurSettings.Token_Expires__c > System.now().addSeconds(tokenTimeBuffer)) {
            result = new ConcurOauthResponse(concurSettings);
        } else if (String.isNotBlank(concurSettings.Refresh_Token__c) && concurSettings.Refresh_Token_Expires__c != null && concurSettings.Refresh_Token_Expires__c > System.now().addSeconds(tokenTimeBuffer)) {
            result = Concur_Oauth.refreshToken(concurSettings);
        } else {
            result = Concur_Oauth.requestAccessToken(concurSettings);
        }
        return result;
    }

    public static ConcurOauthResponse getAccessToken() {
        return getAccessToken(false, false);
    }

    private static ConcurOauthResponse requestAccessToken(Concur_Settings_gne__c concurSettings) {
        String payload = 'client_id=' + EncodingUtil.urlEncode(concurSettings.Consumer_Key__c, 'UTF-8') +
                '&client_secret=' + EncodingUtil.urlEncode(concurSettings.Consumer_Secret__c, 'UTF-8') +
                '&grant_type=password' +
                '&username=' + EncodingUtil.urlEncode(concurSettings.Username__c, 'UTF-8') +
                '&password=' + EncodingUtil.urlEncode(concurSettings.Password__c, 'UTF-8');

        HttpRequest req = getTokenRequest(concurSettings.Authorization_End_Point__c, payload);
        Http http = new Http();
        HttpResponse resp = http.send(req);

        if (resp.getStatusCode() != 200) {
            ConcurUtil.logError(null, 'Concur_Oauth', 'requestAccessToken', 'authentication', req, resp);
            throw new ConcurUtil.ConcurException('Connection issue: ' + resp.getBody());
        }
        return new ConcurOauthResponse(resp.getBody());
    }

    private static ConcurOauthResponse refreshToken(Concur_Settings_gne__c concurSettings) {
        String payload = 'client_id=' + EncodingUtil.urlEncode(concurSettings.Consumer_Key__c, 'UTF-8') +
                '&client_secret=' + EncodingUtil.urlEncode(concurSettings.Consumer_Secret__c, 'UTF-8') +
                '&refresh_token=' + EncodingUtil.urlEncode(concurSettings.Refresh_Token__c, 'UTF-8') +
                '&grant_type=refresh_token';
        HttpRequest req = getTokenRequest(concurSettings.Authorization_End_Point__c, payload);
        Http http = new Http();
        HttpResponse resp = http.send(req);
        if (resp.getStatusCode() != 200) {
            ConcurUtil.logError(null, 'Concur_Oauth', 'refreshToken', 'authentication', req, resp);
            throw new ConcurUtil.ConcurException('Connection issue');
        }
        return new ConcurOauthResponse(resp.getBody());
    }

    private static HttpRequest getTokenRequest(String endpoint, String body) {
        endpoint = endpoint + '/oauth2/v0/token';
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(endpoint);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody(body);
        return req;
    }

    public class ConcurOauthResponse {
        public String expires_in;
        public String scope;
        public String token_type;
        public String access_token;
        public String refresh_token;
        public String refresh_expires_in;
        public String geolocation;
        public String id_token;

        public ConcurOauthResponse(String jsonString) {
            ConcurOauthResponse c = (ConcurOauthResponse) JSON.deserialize(jsonString, ConcurOauthResponse.class);
            this.expires_in = c.expires_in;
            this.scope = c.scope;
            this.token_type = c.token_type;
            this.access_token = c.access_token;
            this.refresh_token = c.refresh_token;
            this.refresh_expires_in = c.refresh_expires_in;
            this.geolocation = c.geolocation;
            this.id_token = c.id_token;
        }

        public ConcurOauthResponse(Concur_Settings_gne__c concurSettings) {
            this.expires_in = concurSettings.Token_Expires__c != null ? String.valueOf(concurSettings.Token_Expires__c.getTime()) : null;
            this.access_token = concurSettings.Access_Token__c;
            this.refresh_token = concurSettings.Refresh_Token__c;
            this.refresh_expires_in = concurSettings.Refresh_Token_Expires__c != null ? String.valueOf(concurSettings.Refresh_Token_Expires__c.getTime()) : null;
            this.id_token = concurSettings.Token_Id__c;
        }

        public Boolean equals(Object o) {
            if (o instanceof ConcurOauthResponse) {
                ConcurOauthResponse oauth = (ConcurOauthResponse) o;
                return expires_in == oauth.expires_in &&
                        access_token == oauth.access_token &&
                        refresh_token == oauth.refresh_token
                        && refresh_expires_in == oauth.refresh_expires_in &&
                        id_token == oauth.id_token;
            }
            return false;
        }
    }
}