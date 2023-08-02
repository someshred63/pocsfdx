@isTest
private class GNE_CRM_340B_Google_Connect_Test {

    @testSetup 
    private static void setup() {

        List<GNE_Foun_Misc_Config_Items_gne__c> configItemsToInsert = new List<GNE_Foun_Misc_Config_Items_gne__c>();
        configItemsToInsert.add(new GNE_Foun_Misc_Config_Items_gne__c(Name='GOOGLE_CLIENT_ID', Configuration_Value_gne__c = '21388330633-urgt6f5eh6vcvrfte87ng2c4ama2smh4.apps.googleusercontent.com'));
        configItemsToInsert.add(new GNE_Foun_Misc_Config_Items_gne__c(Name='GOOGLE_SECRET_CODE', Configuration_Value_gne__c = '6YOnmyi5mJ1I2OqZOvVRcGBF'));
        insert configItemsToInsert;

        Id profileId = [SELECT Name FROM Profile WHERE Profile.Name = 'GNE-MCCO-340B' ].Id;

        User user = new User(
            Alias = 'standt',
            Email = 'example1user@veevasystems.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profileId,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'example1user@veevasystems.com'
        );
        insert user;

        Blob aeskey = Crypto.generateAesKey(128);
        String aesKeyAsString = EncodingUtil.base64Encode(aeskey);
        GNE_MCCO_CRM_340B_Google_Tokens__c gt = new GNE_MCCO_CRM_340B_Google_Tokens__c();
        gt.Name = 'example1user@veevasystems.com';
        gt.Access_Token__c = GNE_CRM_340B_Google_Utlis.encriptToken('ya29.Gl0IBltPhG38exELU8wYn646Jk-GFvwVKBmTj_asXu7_cAmBQGSJlbP8nLMBdaedFNeiLxl-92tf6YVhJxTFysfhbQ6TvPIQJg3bgIezmlc2aVbxwZWqUURw54EQR8Q', aesKeyAsString, String.valueOf(user.Id));
        gt.Authorization_Code__c = GNE_CRM_340B_Google_Utlis.encriptToken('4/AADdBglygTPUKq7Gudu0hx8wG_a-FO2mAFHuoNXwfc22Ad72fVn1NqPLftXkuJCglQ1XVEDFsswRsij1r4K5MEg', aesKeyAsString, String.valueOf(user.Id));
        gt.Expires_In__c = string.valueofGmt(system.now().addMinutes(5));
        gt.Label__c = 'Label_1';
        gt.Last_Sync__c = '1517586126';
        gt.Next_Page__c = '';
        gt.Refresh_Token__c = GNE_CRM_340B_Google_Utlis.encriptToken('1/38rLHGp5MHc8h0dOStZnjxYX6pqumbclCB2eZ9gkqDU', aesKeyAsString, String.valueOf(user.Id));
        gt.Token_Type__c = 'type123';
        gt.Aes_Key__c = EncodingUtil.base64Encode(aeskey);
        insert gt;

        GNE_MCCO_CRM_340B_Google_Tokens__c gt2 = new GNE_MCCO_CRM_340B_Google_Tokens__c();
        gt2.Name = 'example2user@veevasystems.com';
        gt2.Access_Token__c = GNE_CRM_340B_Google_Utlis.encriptToken('ya29.Gl0IBltPhG38exELU8wYn646Jk-GFvwVKBmTj_asXu7_cAmBQGSJlbP8nLMBdaedFNeiLxl-92tf6YVhJxTFysfhbQ6TvPIQJg3bgIezmlc2aVbxwZWqUURw54EQR8Q', aesKeyAsString, String.valueOf(user.Id));
        gt2.Authorization_Code__c = GNE_CRM_340B_Google_Utlis.encriptToken('4/AADdBglygTPUKq7Gudu0hx8wG_a-FO2mAFHuoNXwfc22Ad72fVn1NqPLftXkuJCglQ1XVEDFsswRsij1r4K5MEg', aesKeyAsString, String.valueOf(user.Id));
        gt2.Expires_In__c = '2018-02-01 16:42:04 ';
        gt2.Label__c = 'Label_1';
        gt2.Last_Sync__c = '1517586125';
        gt2.Next_Page__c = '';
        gt2.Refresh_Token__c = GNE_CRM_340B_Google_Utlis.encriptToken('1/38rLHGp5MHc8h0dOStZnjxYX6pqumbclCB2eZ9gkqDU', aesKeyAsString, String.valueOf(user.Id));
        gt2.Token_Type__c = 'type123';
        gt2.Aes_Key__c = EncodingUtil.base64Encode(aeskey);
        insert gt2;
    }
    
    private class CalloutMock implements HttpCalloutMock {
        public String response {get; set;}
        public String status {get; set;}
        public Integer statusCode {get; set;}
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            if(String.isBlank(status)) {
                res.setStatus('OK');
            } else {
                res.setStatus(status);
            }
            if(statusCode == null) {
                res.setStatusCode(200);
            } else {
                res.setStatusCode(statusCode);
            }
            res.setBody(response);
            return res;
        }
    }
    
    private static testMethod void testController() {
        PageReference pageRef = Page.GNE_CRM_340B_Google_Connect;
        Test.setCurrentPage(pageRef);
        User u = [Select Id From User Where UserName =: 'example1user@veevasystems.com' Limit 1];
        CalloutMock callMock = new CalloutMock();
        callMock.response = '{ "auth_code":"atc"}';
        Test.setMock(HttpCalloutMock.class, callMock);

        system.runAs(u) {
            Test.startTest();
	            GNE_CRM_340B_Google_Connect ctrl = new GNE_CRM_340B_Google_Connect();
                ctrl.setCustomSettingGoogleTokens('changedAuth', 'changedaccessToken', 'changedexpiresIn', 'changedrefreshToken', 'changedtokenType');
	            ctrl.retrieveGoogleAutorizationCode();
		        GNE_MCCO_CRM_340B_Google_Tokens__c gt = [ SELECT Name, Access_Token__c, Authorization_Code__c,
                 Expires_In__c, Refresh_Token__c, Token_Type__c, Aes_Key__c FROM GNE_MCCO_CRM_340B_Google_Tokens__c WHERE Name = 'example1user@veevasystems.com' ];
                System.assertNotEquals(gt.Access_Token__c, 'changedaccessToken');
                System.assertNotEquals(gt.Authorization_Code__c, 'changedAuth');
                System.assertEquals(gt.Expires_In__c, 'changedexpiresIn');
                System.assertNotEquals(gt.Refresh_Token__c, 'changedrefreshToken');
                System.assertEquals(gt.Token_Type__c, 'changedtokenType');
            Test.stopTest();
        }
    }
    
    private static testMethod void testRetrieveGoogleAccessToken() {
        PageReference pageRef = Page.GNE_CRM_340B_Google_Connect;
        Test.setCurrentPage(pageRef);
        User u = [Select Id From User Where UserName =: 'example1user@veevasystems.com' Limit 1];
        CalloutMock callMock = new CalloutMock();
        callMock.response = '{ "access_token":"acx", "expires_in":3920, "token_type":"Bearer", "refresh_token":"rsh"}';
        Test.setMock(HttpCalloutMock.class, callMock);

        system.runAs(u) {
            Test.startTest();
	            GNE_CRM_340B_Google_Connect ctrl = new GNE_CRM_340B_Google_Connect();
	            ctrl.retrieveGoogleAccessToken('changedAuthCode');
	
		        System.assertEquals(ctrl.accessToken, 'acx');
		        System.assertEquals(ctrl.refreshToken, 'rsh');
		        System.assertEquals(ctrl.tokenType, 'Bearer');
            Test.stopTest();
        }
    }
    
    private static testMethod void testIsValidGoogleAccessTokenOnline() {
        PageReference pageRef = Page.GNE_CRM_340B_Google_Connect;
        Test.setCurrentPage(pageRef);
        User u = [Select Id From User Where UserName =: 'example1user@veevasystems.com' Limit 1];
        CalloutMock callMock = new CalloutMock();
        callMock.status = 'KO';
        callMock.statusCode = 400;
        callMock.response = '{ "error":"invalid_token" }';
        Test.setMock(HttpCalloutMock.class, callMock);

        system.runAs(u) {
            Test.startTest();
                GNE_CRM_340B_Google_Connect ctrl = new GNE_CRM_340B_Google_Connect();
                Integer resStatusCode = GNE_CRM_340B_Google_Utlis.getAccessTokenInfo(ctrl.gt);
                System.assertEquals(400, resStatusCode);
            Test.stopTest();
        }
    }
    
    private static testMethod void testRefreshGoogleAccessToken() {
        PageReference pageRef = Page.GNE_CRM_340B_Google_Connect;
        Test.setCurrentPage(pageRef);
        User u = [Select Id From User Where UserName =: 'example1user@veevasystems.com' Limit 1];
        CalloutMock callMock = new CalloutMock();
        callMock.response = '{ "access_token":"acx", "expires_in":"3600", "token_type":"Bearer" }';
        Test.setMock(HttpCalloutMock.class, callMock);

        system.runAs(u) {
            Test.startTest();
                GNE_CRM_340B_Google_Connect ctrl = new GNE_CRM_340B_Google_Connect();
                HttpResponse res = GNE_CRM_340B_Google_Utlis.refreshAccessToken(ctrl.gt);
                ctrl.processRefreshAccessTokenResponse(res);
                System.assertEquals(ctrl.accessToken, 'acx');
            Test.stopTest();
        }
    }
    
    private static testMethod void testSaveTokensInCustomSetting() {
        PageReference pageRef = Page.GNE_CRM_340B_Google_Connect;
        Test.setCurrentPage(pageRef);
        User u = [Select Id From User Where UserName =: 'example1user@veevasystems.com' Limit 1];
        CalloutMock callMock = new CalloutMock();
        callMock.response = '{ "access_token":"acx", "expires_in":, "token_type":"Bearer" }';
        Test.setMock(HttpCalloutMock.class, callMock);

        system.runAs(u) {
            Test.startTest();
                GNE_CRM_340B_Google_Connect ctrl = new GNE_CRM_340B_Google_Connect();
                ctrl.saveTokensInCustomSetting();
            Test.stopTest();
        }
    }
    
    private static testMethod void testRetrieveEmails() {
        PageReference pageRef = Page.GNE_CRM_340B_Google_Connect;
        Test.setCurrentPage(pageRef);
        User u = [Select Id From User Where UserName =: 'example1user@veevasystems.com' Limit 1];
        CalloutMock callMock = new CalloutMock();
        callMock.response = '{ "messages": [ { "id": "16165c4e6a31ee3e", "threadId": "16165c4e6a31ee3e" }, { "id": "1615590dde6d23f4", "threadId": "1615590dde6d23f4" }, { "id": "160f9dffffe0752e", "threadId": "15ef5f5d7da5559c" } ], "nextPageToken": "07576236511399902315", "resultSizeEstimate": 4 }';
        Test.setMock(HttpCalloutMock.class, callMock);

        system.runAs(u) {
            Test.startTest();
                GNE_CRM_340B_Google_Connect ctrl = new GNE_CRM_340B_Google_Connect();
                ctrl.retrieveEmails();
            Test.stopTest();
        }
    }
    
    private static testMethod void testRetrieveEmailInfo() {
        PageReference pageRef = Page.GNE_CRM_340B_Google_Connect;
        Test.setCurrentPage(pageRef);
        User u = [Select Id From User Where UserName =: 'example1user@veevasystems.com' Limit 1];
        CalloutMock callMock = new CalloutMock();
        callMock.response = '{ "id": "15ef5f5d7da5559c", "threadId": "15ef5f5d7da5559c", "labelIds": [ "Label_1" ], "snippet": "test -- Pozdrawiam Grzegorz Skaruz", "payload": { "partId": "", "mimeType": "", "filename": "", "headers": [ { "name": "To", "value": "TestSyncProject@gmail.com" }, { "name": "From", "value": "Grzegorz Skaruz \u003cgrzegorz@skaruz.com\u003e" }, { "name": "Subject", "value": "test 1" }, { "name": "Date", "value": "Sat, 7 Oct 2017 10:31:30 +0200" }, { "name": "Content-Language", "value": "pl" } ], "body": { "size": 0 }, "parts": [ { "partId": "0", "mimeType": "text/plain", "filename": "", "headers": [ { "name": "Content-Type", "value": "text/plain; charset=iso-8859-2; format=flowed" }, { "name": "Content-Transfer-Encoding", "value": "7bit" } ], "body": { "size": 44, "data": "dGVzdA0KDQotLSANClBvemRyYXdpYW0NCkdyemVnb3J6IFNrYXJ1eg0KDQo=" } }, { "partId": "1", "mimeType": "text/html", "filename": "", "headers": [ { "name": "Content-Type", "value": "text/html; charset=iso-8859-2" }, { "name": "Content-Transfer-Encoding", "value": "7bit" } ], "body": { "size": 283, "data": "PGh0bWw-DQogIDxoZWFkPg0KDQogICAgPG1ldGEgaHR0cC1lcXVpdj0iY29udGVudC10eXBlIiBjb250ZW50PSJ0ZXh0L2h0bWw7IGNoYXJzZXQ9aXNvLTg4NTktMiI-DQogIDwvaGVhZD4NCiAgPGJvZHkgdGV4dD0iIzAwMDAwMCIgYmdjb2xvcj0iI0ZGRkZGRiI-DQogICAgPHA-dGVzdCA8YnI-DQogICAgPC9wPg0KICAgIDxwcmUgY2xhc3M9Im1vei1zaWduYXR1cmUiIGNvbHM9IjcyIj4tLSANClBvemRyYXdpYW0NCkdyemVnb3J6IFNrYXJ1eg0KPC9wcmU-DQogIDwvYm9keT4NCjwvaHRtbD4NCg==" } } ] }, "sizeEstimate": 3828}';
        Test.setMock(HttpCalloutMock.class, callMock);

        system.runAs(u) {
            Test.startTest();
                GNE_CRM_340B_Google_Connect ctrl = new GNE_CRM_340B_Google_Connect();
                ctrl.retrieveEmailInfo();
            Test.stopTest();
        }
    }
    
    private static testMethod void testRetrieveAttachmentInfo() {
        PageReference pageRef = Page.GNE_CRM_340B_Google_Connect;
        Test.setCurrentPage(pageRef);
        User u = [Select Id From User Where UserName =: 'example1user@veevasystems.com' Limit 1];
        CalloutMock callMock = new CalloutMock();
        callMock.response = '{ "size": 80582, "data": "JVBERi0xLjUNCiW1tbW1DQoxIDAFT0Y="}';
        Test.setMock(HttpCalloutMock.class, callMock);

        system.runAs(u) {
            Test.startTest();
                GNE_CRM_340B_Google_Connect ctrl = new GNE_CRM_340B_Google_Connect();
                ctrl.retrieveAttachmentInfo();
            Test.stopTest();
        }
    }
    
    private static testMethod void testRetrieveLabels() {
        PageReference pageRef = Page.GNE_CRM_340B_Google_Connect;
        Test.setCurrentPage(pageRef);
        User u = [Select Id From User Where UserName =: 'example1user@veevasystems.com' Limit 1];
        CalloutMock callMock = new CalloutMock();
        callMock.response = '{ "labels": [ { "id": "Label_3", "name": "TestLabel2340B", "type": "user" }, { "id": "Label_2", "name": "TestLabel1", "type": "user" } ]}';
        Test.setMock(HttpCalloutMock.class, callMock);

        system.runAs(u) {
            Test.startTest();
                GNE_CRM_340B_Google_Connect ctrl = new GNE_CRM_340B_Google_Connect();
                ctrl.retrieveLabels();
            Test.stopTest();
        }
    }
    
}