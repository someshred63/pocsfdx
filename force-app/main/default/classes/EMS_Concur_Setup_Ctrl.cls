public with sharing class EMS_Concur_Setup_Ctrl {

    public EMS_Concur_Settings_gne__c concurSettings { get; set; }
    public transient String username { get; set; }
    public transient String password { get; set; }

    public EMS_Concur_Setup_Ctrl(ApexPages.StandardController controller) {
        concurSettings = EMS_Concur_Util.getConcurSettings();
        ApexPages.currentPage().getParameters().put('Id', concurSettings.Id);
    }

    public PageReference upsertConcurSettings() {
        upsert concurSettings;
        return null;
    }

    public PageReference authenticate() {
        try {
            EMS_Concur_Util.ConcurWebserviceResponse response = EMS_Concur_OAuth.requestAccessToken(username, password);
            Dom.Document doc = new Dom.Document();
            doc.load(response.body);
            Dom.XMLNode root = doc.getRootElement();

            if (response.statusCode == 200) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Authenticated sucessfully.'));

                // parse details
                String token = root.getChildElement('Token', null).getText();
                String expirationDate = root.getChildElement('Expiration_date', null).getText();
                String refreshToken = root.getChildElement('Refresh_Token', null).getText();

                // update settings
                concurSettings.Access_Token_gne__c = token;
                concurSettings.Refresh_Token_gne__c = refreshToken;
                concurSettings.Expires_gne__c = expirationDate;

                upsert concurSettings;
            } else {
                // parse error message
                String errorMessage = root.getChildElement('Message', null).getText();
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
            }
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }

        return null;
    }

    public PageReference refreshToken() {
        try {
            EMS_Concur_Util.ConcurWebserviceResponse response = EMS_Concur_OAuth.refreshToken();
            Dom.Document doc = new Dom.Document();
            doc.load(response.body);
            Dom.XMLNode root = doc.getRootElement();

            if (response.statusCode == 200) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Token sucessfully refreshed.'));

                String token = root.getChildElement('Token', null).getText();
                String expirationDate = root.getChildElement('Expiration_date', null).getText();

                // update settings
                concurSettings.Access_Token_gne__c = token;
                concurSettings.Expires_gne__c = expirationDate;

                upsert concurSettings;
            } else {
                // parse error message
                String errorMessage = root.getChildElement('Message', null).getText();
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
            }
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
        return null;
    }
}