public without sharing class EMS_Concur_Util {

    private static EMS_Concur_Settings_gne__c concurSettings;

    public EMS_Concur_Util() {

    }

    public static EMS_Concur_Settings_gne__c getConcurSettings() {
        String salesforceBaseUrl = System.Url.getSalesforceBaseUrl().toExternalForm();
        System.debug('>> EMS_Concur_Util.getConcurSettings: ' + salesforceBaseUrl);
        if (concurSettings == null) {
            List<EMS_Concur_Settings_gne__c> settings = [
                    SELECT Access_Token_gne__c, Refresh_Token_gne__c, Expires_gne__c, Consumer_Key_gne__c, Consumer_Secret_gne__c, End_Point_gne__c, Domain_URL_gne__c,
                            Site_Domain_URL_gne__c, Event_Period_Length_gne__c, Interaction_Period_Length_gne__c, Interaction_Type_gne__c
                    FROM EMS_Concur_Settings_gne__c
                    WHERE Domain_URL_gne__c = :salesforceBaseUrl
                    OR Site_Domain_URL_gne__c = :salesforceBaseUrl
            ];

            if (settings.isEmpty()) {
                System.debug('No settings found, generating placeholder');
                concurSettings = new EMS_Concur_Settings_gne__c(Domain_URL_gne__c = salesforceBaseUrl);
            } else {
                concurSettings = settings[0];
            }
        }
        System.debug('Concur Settings: ' + concurSettings);

        return concurSettings;
    }

    public static EMS_Concur_Settings_gne__c getConcurSettingsForSite() {
        String salesforceBaseUrl = System.Url.getSalesforceBaseUrl().toExternalForm();
        System.debug('>> EMS_Concur_Util.getConcurSettingsForSite: ' + salesforceBaseUrl);
        if (concurSettings == null) {
            List<EMS_Concur_Settings_gne__c> settings = [
                    SELECT Access_Token_gne__c, Refresh_Token_gne__c, Expires_gne__c, Consumer_Key_gne__c, Consumer_Secret_gne__c, End_Point_gne__c, Domain_URL_gne__c,
                            Site_Domain_URL_gne__c, Event_Period_Length_gne__c, Interaction_Period_Length_gne__c, Interaction_Type_gne__c
                    FROM EMS_Concur_Settings_gne__c
                    WHERE Site_Domain_URL_gne__c = :salesforceBaseUrl
                    OR Site_Domain_URL_gne__c = :salesforceBaseUrl
            ];

            if(settings.isEmpty()) {
                System.debug('No settings found, generating placeholder');
                concurSettings = new EMS_Concur_Settings_gne__c(Domain_URL_gne__c = salesforceBaseUrl);
            } else {
                concurSettings = settings[0];
            }
        }

        System.debug('Concur Settings: ' + concurSettings);

        return concurSettings;
    }

    public static void logError(String endpoint, Decimal errorCode, String errorMessage, String requestBody, String method) {
        EMS_Concur_Log_gne__c errorLog = new EMS_Concur_Log_gne__c(End_Point_gne__c = endpoint, Error_Code_gne__c = errorCode,
                Error_Message_gne__c = errorMessage, Request_Body_gne__c = requestBody, Method_gne__c = method);
        insert errorLog;
    }

    public class ConcurWebserviceResponse {
        public Integer statusCode;
        public String body;

        public ConcurWebserviceResponse(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body = body;
        }
    }
}