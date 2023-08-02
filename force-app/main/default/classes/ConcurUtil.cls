public inherited sharing class ConcurUtil {

    private static Concur_Settings_gne__c concurSettings;

    public static Concur_Settings_gne__c getConcurSettings() {
        System.debug('getConcurSettings domain: ' + System.Url.getSalesforceBaseUrl().toExternalForm());
        if (concurSettings == null) {
            List<Concur_Settings_gne__c> cs = [
                    SELECT Access_Token__c, Refresh_Token__c, Token_Expires__c, Consumer_Key__c, Consumer_Secret__c, End_Point__c,
                            Domain_URL__c, Username__c, Password__c, Refresh_Token_Expires__c, Site_Domain_URL__c, Token_Id__c, Authorization_End_Point__c
                    FROM Concur_Settings_gne__c
                    WHERE Domain_URL__c = :System.Url.getSalesforceBaseUrl().toExternalForm()
            ];

            if (cs.size() > 0) {
                concurSettings = cs[0];
            } else {
                throw new ConcurException('Configuration missing');
            }
        }
        return concurSettings;
    }

    public static Concur_Settings_gne__c getConcurSettingsForSite() {
        System.debug('getConcurSettingsForSite domain: ' + System.Url.getSalesforceBaseUrl().toExternalForm());
        if (concurSettings == null) {
            List<Concur_Settings_gne__c> cs = [
                    SELECT Access_Token__c, Refresh_Token__c, Token_Expires__c, Consumer_Key__c, Consumer_Secret__c, End_Point__c,
                            Domain_URL__c, Username__c, Password__c, Refresh_Token_Expires__c, Site_Domain_URL__c, Token_Id__c, Authorization_End_Point__c
                    FROM Concur_Settings_gne__c
                    WHERE Site_Domain_URL__c = :System.Url.getSalesforceBaseUrl().toExternalForm()
            ];

            if (cs.size() > 0) {
                concurSettings = cs[0];
            } else {
                throw new ConcurException('Configuration missing');
            }
        }
        return concurSettings;
    }

    private static void updateConcurSettings(String accessToken, String refreshToken, String expiresIn, String refreshExpiresIn, String tokenId) {
        Concur_Settings_gne__c settings = getConcurSettings();
        settings.Access_Token__c = accessToken;
        settings.Refresh_Token__c = refreshToken;
        settings.Token_Expires__c = System.now().addSeconds(Integer.valueOf(expiresIn));
        Long et = Long.valueOf(refreshExpiresIn) * 1000;
        settings.Refresh_Token_Expires__c = Datetime.newInstance(et);
        settings.Token_Id__c = tokenId;
        String jsonSettings = JSON.serialize(settings);
        ConcurUtilUpdate.updateConcurSettings(jsonSettings);

    }
    
    public static void updateConcurSettingsIfNeeded(Concur_Oauth.ConcurOauthResponse oauthResponse) {
        if (!oauthResponse.equals(new Concur_Oauth.ConcurOauthResponse(getConcurSettings()))) {
            updateConcurSettings(oauthResponse.access_token, oauthResponse.refresh_token, oauthResponse.expires_in, oauthResponse.refresh_expires_in, oauthResponse.id_token);
    }
    }
	  

    public static void logError(String objectName, String className, String methodName, String errorCategory, HttpRequest request, HttpResponse resp) {
        logError(objectName, className, methodName, errorCategory, resp.getStatus(), String.valueOf(resp.getStatusCode()), request.getEndpoint(), UserInfo.getUserName(), request.getBody(), resp.getBody());
    }

    public static void logError(String objectName, String className, String methodName, String errorCategory, String errorMessage, String errorCode, String endpoint, String userId, String requestBody, String responseBody) {
        Concur_Error_Log_gne__c errorLog = new Concur_Error_Log_gne__c(Object_Name_gne__c = objectName, Class_Name_gne__c = className, Error_Category_gne__c = errorCategory,
                Error_Message_gne__c = errorMessage, Method_Name_gne__c = methodName, System_Error_Message_gne__c = errorMessage,
                Content_gne__c = requestBody, Item_Url_gne__c = endpoint, XUserID_gne__c = userId, Response_Body_gne__c = responseBody);
        insert errorLog;
    }


    public static void logError(String endpoint, String errorCode, String errorMessage, String requestBody, String method) {
        Concur_Error_Log_gne__c errorLog = new Concur_Error_Log_gne__c(Item_Url_gne__c = endpoint, Error_Code_gne__c = errorCode,
                Error_Message_gne__c = errorMessage, Content_gne__c = requestBody, Method_Name_gne__c = method);
        insert errorLog;
    }

    public class ConcurWebserviceResponse {
        private Integer statusCode;
        private String body;

        public ConcurWebserviceResponse(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body = body;
        }

        public Integer getStatusCode() {
            return statusCode;
        }

        public String getBody() {
            return body;
        }
    }

    public class ConcurException extends Exception {

    }
}