public without sharing class EMS_Concur_Webservice {

    public EMS_Concur_Webservice() {

    }

    private static void logError(String endpoint, Decimal errorCode, String errorMessage, String requestBody, String method) {
        EMS_Concur_Log_gne__c errorLog = new EMS_Concur_Log_gne__c(End_Point_gne__c = endpoint, Error_Code_gne__c = errorCode,
                Error_Message_gne__c = errorMessage, Request_Body_gne__c = requestBody, Method_gne__c = method);
        insert errorLog;
    }


    public static EMS_Concur_Util.ConcurWebserviceResponse getExpense(String reportId, String entryId) {
        EMS_Concur_Settings_gne__c concurSettings = EMS_Concur_Util.getConcurSettingsForSite();

        String endpoint = concurSettings.End_Point_gne__c + '/api/expense/expensereport/v1.1/report/' + reportId + '/entry/' + entryId;
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

    public static String postExpense(String reportId, String entryId, String expenseKey, Decimal transactionAmount, String eventInteractionId, String costCenter, String eventName, String hcpName, Integer attendeeCount) {
        EMS_Concur_Settings_gne__c concurSettings = EMS_Concur_Util.getConcurSettings();

        String endpoint = concurSettings.End_Point_gne__c + '/api/expense/expensereport/v1.1/report/' + reportId + '/entry/' + entryId;
        String method = 'POST';
        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        req.setEndpoint(endpoint);
        req.setHeader('Authorization', 'OAuth ' + concurSettings.Access_Token_gne__c);

        XmlStreamWriter w = new XmlStreamWriter();
        w.writeStartElement(null, 'ReportEntries', null);
        w.writeAttribute(null, null, 'xmlns', 'http://www.concursolutions.com/api/expense/expensereport/2011/03');
        w.writeStartElement(null, 'Expenses', null);
        w.writeStartElement(null, 'Expense', null);

        w.writeStartElement(null, 'ExpKey', null);
        w.writeCharacters(expenseKey);
        w.writeEndElement();

        w.writeStartElement(null, 'TransactionAmount', null);
        w.writeCharacters(String.valueOf(transactionAmount));
        w.writeEndElement();

        if (eventInteractionId != null && eventInteractionId.startsWith('E')) {
            // event
            w.writeStartElement(null, 'Description', null);
            w.writeCharacters('Event Name: ' + eventName.left(51));
            w.writeEndElement();

            w.writeStartElement(null, 'Custom3', null);
            w.writeCharacters(eventInteractionId + ' / ' + costCenter);
            w.writeEndElement();
        } else if (eventInteractionId != null && eventInteractionId.startsWith('C')) {
            // interaction
            w.writeStartElement(null, 'Description', null);
            w.writeCharacters(hcpName.left(58) + ' / ' + attendeeCount);
            w.writeEndElement();

            w.writeStartElement(null, 'Custom3', null);
            w.writeCharacters(eventInteractionId);
            w.writeEndElement();
        }

        w.writeEndElement();
        w.writeEndElement();
        w.writeEndElement();
        String requestBody = w.getXmlString();
        w.close();

        req.setBody(requestBody);

        Http http = new Http();
        HttpResponse response = http.send(req);

        if (response.getStatusCode() != 200) {
            logError(endpoint, Decimal.valueOf(response.getStatusCode()), response.getStatus(), req.getBody(), method);
            return null;
        } else {
            return response.getBody();
        }
    }
}