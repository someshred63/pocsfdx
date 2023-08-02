public without sharing class Concur_WebServicesCalls {

    private static HttpResponse sendRequestToConcur(HttpRequest req, String token) {
        req.setHeader('Authorization', 'Bearer ' + token);
        req.setTimeout(60000);
        Http http = new Http();
        return http.send(req);
    }

    private static ConcurUtil.ConcurWebserviceResponse sendRequestToConcur(HttpRequest req) {
        Concur_Oauth.ConcurOauthResponse oauthResponse = Concur_Oauth.getAccessToken();
        HttpResponse response = sendRequestToConcur(req, oauthResponse.access_token);
        System.debug(req);
        System.debug(response);
        if (isTokenExpired(response)) {
            oauthResponse = Concur_Oauth.getAccessToken(true, false);
            response = sendRequestToConcur(req, oauthResponse.access_token);
            if (isTokenExpired(response)) {
                oauthResponse = Concur_Oauth.getAccessToken(true, true);
                response = sendRequestToConcur(req, oauthResponse.access_token);
            }
        }
        ConcurUtil.updateConcurSettingsIfNeeded(oauthResponse);
        if (response.getStatusCode() != 200) {
            ConcurUtil.logError('HttpRequest', 'Concur_WebServicesCalls', 'sendRequestToConcur', 'webService', req, response);
        }
        return new ConcurUtil.ConcurWebserviceResponse(response.getStatusCode(), response.getBody());
    }

    private static Boolean isTokenExpired(HttpResponse response) {
        return response.getStatusCode() == 403 && response.getBody().contains('token is expired') || response.getStatusCode() == 401;
    }

    public static ConcurUtil.ConcurWebserviceResponse getExpense(String reportId, String entryId) {
        Concur_Settings_gne__c concurSettings = ConcurUtil.getConcurSettingsForSite();
        String endpoint = concurSettings.End_Point__c + '/api/expense/expensereport/v1.1/report/' + reportId + '/entry/' + entryId;
        String method = 'GET';
        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        req.setEndpoint(endpoint);
        ConcurUtil.ConcurWebserviceResponse response = sendRequestToConcur(req);
        return response;
    }

    public static Map<String, String> expenseEntryDetails(String XUserID, String entryEndpoint) {
        String reportId = entryEndpoint.substringBetween('/report/', '/entry/');
        String entryId = entryEndpoint.substringAfterLast('/entry/');

        String body = '';

        Map<String, String> responseParameters = new Map<String, String>();
        if (String.isNotBlank(XUserID) && String.isNotBlank(entryEndpoint)) {
            ConcurUtil.ConcurWebserviceResponse response = getExpense(reportId, entryId);

            if (response.getStatusCode() == 200) {
                body = response.getBody();
                System.debug('-------------body' + body);
                XmlStreamReader reader = new XmlStreamReader(body);
                if (reader != null) {
                    while (reader.hasNext()) {
                        if (reader.getEventType() == XmlTag.START_ELEMENT) {
                            if (reader.getLocalName() == 'Custom4') {
                                reader.next();
                                if (reader.getEventType() == XmlTag.CHARACTERS) {
                                    responseParameters.put('OwnerWs', reader.getText().toLowerCase());
                                }
                            }
                        }
                        if (reader.getEventType() == XmlTag.START_ELEMENT) {
                            if (reader.getLocalName() == 'ExpenseName') {
                                reader.next();
                                if (reader.getEventType() == XmlTag.CHARACTERS) {
                                    responseParameters.put('ExpenseName', reader.getText());
                                }
                            }
                        }
                        if (reader.getEventType() == XmlTag.START_ELEMENT) {
                            if (reader.getLocalName() == 'TransactionDate') {
                                reader.next();
                                if (reader.getEventType() == XmlTag.CHARACTERS) {
                                    responseParameters.put('TransactionDate', reader.getText());
                                }
                            }
                        }
                        if (reader.getEventType() == XmlTag.START_ELEMENT) {
                            if (reader.getLocalName() == 'PostedAmount') {
                                reader.next();
                                if (reader.getEventType() == XmlTag.CHARACTERS) {
                                    responseParameters.put('PostedAmount', reader.getText());
                                }
                            }
                        }
                        if (reader.getEventType() == XmlTag.START_ELEMENT) {
                            if (reader.getLocalName() == 'ExpenseKey') {
                                reader.next();
                                if (reader.getEventType() == XmlTag.CHARACTERS) {
                                    responseParameters.put('ExpenseKey', reader.getText());
                                }
                            }
                        }
                        if (reader.getEventType() == XmlTag.START_ELEMENT) {
                            if (reader.getLocalName() == 'TransactionAmount') {
                                reader.next();
                                if (reader.getEventType() == XmlTag.CHARACTERS) {
                                    responseParameters.put('TransactionAmount', reader.getText());
                                }
                            }
                        }
                        if (reader.getEventType() == XmlTag.START_ELEMENT) {
                            if (reader.getLocalName() == 'TransactionCurrencyName') {
                                reader.next();
                                if (reader.getEventType() == XmlTag.CHARACTERS) {
                                    responseParameters.put('TransactionCurrencyName', reader.getText());
                                }
                            }
                        }
                        if (reader.getEventType() == XmlTag.START_ELEMENT) {
                            if (reader.getLocalName() == 'LocationName') {
                                reader.next();
                                if (reader.getEventType() == XmlTag.CHARACTERS) {
                                    responseParameters.put('LocationName', reader.getText());
                                }
                            }
                        }
                        reader.next();
                    }
                }
            }
        }
        return responseParameters;
    }

    public String postExpenseReport(Concur_Expense_Post_gne__c postExpense, String creatorPersId, String ownerPersId) {
        String body = '';
        try {
            String status = 'FAILED';
            if (postExpense != null) {
                String postParam = createExpenseXml(postExpense);

                ConcurUtil.ConcurWebserviceResponse concurWebserviceResponse = sendExpenseToConcur(postExpense.Item_Url_gne__c, postParam);
                body = concurWebserviceResponse.getBody();
                System.debug('---------------post body' + body);
                if (concurWebserviceResponse.getStatusCode() == 200) {
                    XmlStreamReader reader = new XmlStreamReader(body);
                    while (reader.hasNext()) {
                        if (reader.getEventType() == XmlTag.START_ELEMENT) {
                            if (reader.getLocalName() == 'Status') {
                                reader.next();
                                if (reader.getEventType() == XmlTag.CHARACTERS) {
                                    status = reader.getText();
                                }
                            }
                        }
                        reader.next();
                    }
                }
                if (status == 'FAILED') {
                    Concur_Error_Log_gne__c error = new Concur_Error_Log_gne__c(Class_Name_gne__c = 'Concur_WebServicesCalls', Error_Category_gne__c = 'webservice',
                            Error_Message_gne__c = 'Problem with post method', Method_Name_gne__c = 'postExpenseReport', Object_Name_gne__c = 'HttpRequest', System_Error_Message_gne__c = 'Failed POST', Content_gne__c = body, Item_Url_gne__c = postExpense.Item_Url_gne__c, XUserID_gne__c = postExpense.XUserID_gne__c, Error_Code_gne__c = '900');
                    insert error;
                }
            }
            return status;
        } catch (Exception e) {
            Concur_Error_Log_gne__c error = new Concur_Error_Log_gne__c(Class_Name_gne__c = 'Concur_WebServicesCalls', Error_Category_gne__c = 'webservice',
                    Error_Message_gne__c = 'Problem with post method', Method_Name_gne__c = 'postExpenseReport', Object_Name_gne__c = 'HttpRequest', System_Error_Message_gne__c = e.getMessage(), Content_gne__c = body, Item_Url_gne__c = postExpense.Item_Url_gne__c, XUserID_gne__c = postExpense.XUserID_gne__c, Error_Code_gne__c = '900');
            insert error;
            return 'FAILED';
        }
    }

    private String createExpenseXml(Concur_Expense_Post_gne__c postExpense) {
        String postParam = '<ReportEntries xmlns="http://www.concursolutions.com/api/expense/expensereport/2011/03">';
        postParam += '<Expense>';
        postParam += '<ExpKey>' + postExpense.ExpKey_gne__c + '</ExpKey>';
        postParam += '<TransactionAmount>' + postExpense.Transaction_Amount_gne__c + '</TransactionAmount>';
        postParam += '<PostedAmount>' + postExpense.Amount_gne__c + '</PostedAmount>';
        if (postExpense.Business_Purpose__c != null) {
            if (postExpense.Business_Purpose__c.length() < 64) {
                String business_purpose = postExpense.Business_Purpose__c;
                business_purpose = business_purpose.replace('&', '&amp;');
                business_purpose = business_purpose.replace('<', '&lt;');
                business_purpose = business_purpose.replace('>', '&gt;');
                business_purpose = business_purpose.replace('\'', '&apos;');
                business_purpose = business_purpose.replace('"', '&quot;');
                postParam += '<Description>' + business_purpose + '</Description>';
            } else {
                String business_purpose = postExpense.Business_Purpose__c.substring(0, 63);
                business_purpose = business_purpose.replace('&', '&amp;');
                business_purpose = business_purpose.replace('<', '&lt;');
                business_purpose = business_purpose.replace('>', '&gt;');
                business_purpose = business_purpose.replace('\'', '&apos;');
                business_purpose = business_purpose.replace('"', '&quot;');
                postParam += '<Description>' + business_purpose + '</Description>';
            }
        } else {
            postParam += '<Description></Description>';
        }
        if (postExpense.SFDC_Expense_Type_gne__c == 'Business Meal with HCPs') {
            postParam += '<Custom1>Link Complete</Custom1>';
        } else {
            postParam += '<Custom2>Link Complete</Custom2>';
        }
        postParam += '<Custom17>' + postExpense.Interaction_Name_Aprimo_Site_ID_gne__c + '</Custom17>';
        postParam += '<Custom18>' + postExpense.Amount_gne__c + '</Custom18>';
        postParam += '<Custom19>' + postExpense.SFDC_Expense_Type_gne__c + '</Custom19>';
        postParam += '<Custom21>' + postExpense.SFDC_Transaction_Date_gne__c + '</Custom21>';
        if (postExpense.SFDC_Attendee_Count_gne__c != null) {
            postParam += '<Custom5>' + postExpense.SFDC_Attendee_Count_gne__c + '</Custom5>';
        } else {
            postParam += '<Custom5>0</Custom5>';
        }
        postParam += '</Expense>';
        postParam += '</ReportEntries>';
        return postParam;
    }

    private static ConcurUtil.ConcurWebserviceResponse sendExpenseToConcur(String endpoint, String body) {
        HttpRequest req = new HttpRequest();
        req.setTimeout(60000);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/xml');
        req.setEndpoint(endpoint);
        req.setBody(body);
        return sendRequestToConcur(req);
    }
}