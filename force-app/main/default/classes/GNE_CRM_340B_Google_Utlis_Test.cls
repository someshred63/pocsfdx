@isTest
private class GNE_CRM_340B_Google_Utlis_Test {
    
    @testSetup 
    private static void setup() {
        List<GNE_Foun_Misc_Config_Items_gne__c> configItemsToInsert = new List<GNE_Foun_Misc_Config_Items_gne__c>();
        configItemsToInsert.add(new GNE_Foun_Misc_Config_Items_gne__c(Name='GOOGLE_CLIENT_ID', Configuration_Value_gne__c = '21388330633-urgt6f5eh6vcvrfte87ng2c4ama2smh4.apps.googleusercontent.com'));
        configItemsToInsert.add(new GNE_Foun_Misc_Config_Items_gne__c(Name='GOOGLE_SECRET_CODE', Configuration_Value_gne__c = '6YOnmyi5mJ1I2OqZOvVRcGBF'));
        insert configItemsToInsert;
        
        GNE_MCCO_CRM_340B_Google_Tokens__c gt = new GNE_MCCO_CRM_340B_Google_Tokens__c();
        gt.Name = 'example1user@veevasystems.com';
        gt.Access_Token__c = 'ya29.Gl0IBltPhG38exELU8wYn646Jk-GFvwVKBmTj_asXu7_cAmBQGSJlbP8nLMBdaedFNeiLxl-92tf6YVhJxTFysfhbQ6TvPIQJg3bgIezmlc2aVbxwZWqUURw54EQR8Q';
        gt.Authorization_Code__c = '4/AADdBglygTPUKq7Gudu0hx8wG_a-FO2mAFHuoNXwfc22Ad72fVn1NqPLftXkuJCglQ1XVEDFsswRsij1r4K5MEg';
        gt.Expires_In__c = '2018-02-02 16:42:04 ';
        gt.Label__c = 'Label_1';
        gt.Last_Sync__c = '1517586126';
        gt.Next_Page__c = '';
        gt.Refresh_Token__c = '1/38rLHGp5MHc8h0dOStZnjxYX6pqumbclCB2eZ9gkqDU';
        gt.Token_Type__c = 'type123';
        gt.Aes_Key__c = EncodingUtil.base64Encode(Crypto.generateAesKey(128));
        insert gt;

        GNE_MCCO_CRM_340B_Google_Tokens__c gt2 = new GNE_MCCO_CRM_340B_Google_Tokens__c();
        gt2.Name = 'example2user@veevasystems.com';
        gt2.Access_Token__c = 'ya29.Gl0IBltPhG38exELU8wYn646Jk-GFvwVKBmTj_asXu7_cAmBQGSJlbP8nLMBdaedFNeiLxl-92tf6YVhJxTFysfhbQ6TvPIQJg3bgIezmlc2aVbxwZWqUURw54EQR8Q';
        gt2.Authorization_Code__c = '4/AADdBglygTPUKq7Gudu0hx8wG_a-FO2mAFHuoNXwfc22Ad72fVn1NqPLftXkuJCglQ1XVEDFsswRsij1r4K5MEg';
        gt2.Expires_In__c = '2018-02-01 16:42:04 ';
        gt2.Label__c = 'Label_1';
        gt2.Last_Sync__c = '1517586125';
        gt2.Next_Page__c = '';
        gt2.Refresh_Token__c = '1/38rLHGp5MHc8h0dOStZnjxYX6pqumbclCB2eZ9gkqDU';
        gt2.Token_Type__c = 'type123';
        gt.Aes_Key__c = EncodingUtil.base64Encode(Crypto.generateAesKey(128));
        insert gt2;
    }
    

    private static User createUser(String name, Id profileId, Boolean toInsert) {
        User user = new User(
            Alias = 'standt',
            Email = name + 'user@veevasystems.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profileId,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = name + 'user@veevasystems.com'
        );
        system.debug(user);
        if (toInsert) insert user;
        return user;
    }    
    
    private class CalloutMock implements HttpCalloutMock {
        public String response {get; set;}
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody(response);
            return res;
        }
    }
    
    private static testMethod void testRetrieveEmails() {
        Id profileId = [SELECT Name FROM Profile WHERE Profile.Name = 'GNE-MCCO-340B' ].Id;
        User u = createUser('example1', profileId, true);
        
        CalloutMock callMock = new CalloutMock();
        callMock.response = '{ "messages": [ { "id": "16165c4e6a31ee3e", "threadId": "16165c4e6a31ee3e" }, { "id": "1615590dde6d23f4", "threadId": "1615590dde6d23f4" }, { "id": "160f9dffffe0752e", "threadId": "15ef5f5d7da5559c" } ], "nextPageToken": "07576236511399902315", "resultSizeEstimate": 4 }';
        Test.setMock(HttpCalloutMock.class, callMock);

        System.runAs(u) {        
            GNE_MCCO_CRM_340B_Google_Tokens__c gt = [ SELECT Name, Access_Token__c, Last_Sync__c, Next_Page__c, Aes_Key__c FROM GNE_MCCO_CRM_340B_Google_Tokens__c WHERE Name =: UserInfo.getUserName()];
            Test.startTest();
                System.assertEquals(0, [ SELECT Id FROM GNE_CRM_340B_Email__c ].size());
                GNE_CRM_340B_Google_Utlis.retrieveEmails(gt);
                System.assertEquals(3, [ SELECT Id FROM GNE_CRM_340B_Email__c ].size());
            Test.stopTest();
        }
    }
    
    private static testMethod void testProcessEmailInfo() {
        
        Id profileId = [SELECT Name FROM Profile WHERE Profile.Name = 'GNE-MCCO-340B' ].Id;
        User u = createUser('example1', profileId, true);

        System.runAs(u) {
            GNE_CRM_340B_Email__c email = new GNE_CRM_340B_Email__c();
            email.Username__c = 'example1user@veevasystems.com';
            email.Message_ID__c = '123';
            insert email;
            
            CalloutMock callMock = new CalloutMock();
            callMock.response = '{ "id": "15ef5f5d7da5559c", "threadId": "15ef5f5d7da5559c", "labelIds": [ "Label_1" ], "snippet": "test -- Pozdrawiam Grzegorz Skaruz", "payload": { "partId": "", "mimeType": "", "filename": "", "headers": [ { "name": "To", "value": "TestSyncProject@gmail.com" }, { "name": "From", "value": "Grzegorz Skaruz \u003cgrzegorz@skaruz.com\u003e" }, { "name": "Subject", "value": "test 1" }, { "name": "Date", "value": "Sat, 7 Oct 2017 10:31:30 +0200" }, { "name": "Content-Language", "value": "pl" } ], "body": { "size": 0 }, "parts": [ { "partId": "0", "mimeType": "text/plain", "filename": "", "headers": [ { "name": "Content-Type", "value": "text/plain; charset=iso-8859-2; format=flowed" }, { "name": "Content-Transfer-Encoding", "value": "7bit" } ], "body": { "size": 44, "data": "dGVzdA0KDQotLSANClBvemRyYXdpYW0NCkdyemVnb3J6IFNrYXJ1eg0KDQo=" } }, { "partId": "1", "mimeType": "text/html", "filename": "", "headers": [ { "name": "Content-Type", "value": "text/html; charset=iso-8859-2" }, { "name": "Content-Transfer-Encoding", "value": "7bit" } ], "body": { "size": 283, "data": "PGh0bWw-DQogIDxoZWFkPg0KDQogICAgPG1ldGEgaHR0cC1lcXVpdj0iY29udGVudC10eXBlIiBjb250ZW50PSJ0ZXh0L2h0bWw7IGNoYXJzZXQ9aXNvLTg4NTktMiI-DQogIDwvaGVhZD4NCiAgPGJvZHkgdGV4dD0iIzAwMDAwMCIgYmdjb2xvcj0iI0ZGRkZGRiI-DQogICAgPHA-dGVzdCA8YnI-DQogICAgPC9wPg0KICAgIDxwcmUgY2xhc3M9Im1vei1zaWduYXR1cmUiIGNvbHM9IjcyIj4tLSANClBvemRyYXdpYW0NCkdyemVnb3J6IFNrYXJ1eg0KPC9wcmU-DQogIDwvYm9keT4NCjwvaHRtbD4NCg==" } } ] }, "sizeEstimate": 3828}';
            Test.setMock(HttpCalloutMock.class, callMock);
            Test.startTest();
                    GNE_CRM_340B_Google_Utlis.processEmailInfo(new List<GNE_CRM_340B_Email__c>{email});
                    GNE_CRM_340B_Email__c resultEmail = [ SELECT Body_HTML__c, Body__c, Date__c, From__c, Labels__c, Subject_Line__c, To__c, User_Labels__c FROM GNE_CRM_340B_Email__c WHERE Message_ID__c = '123' ];
                    System.assertEquals(resultEmail.Date__c, 'Sat, 7 Oct 2017 10:31:30 +0200');
                    System.assertEquals(resultEmail.From__c, 'Grzegorz Skaruz \u003cgrzegorz@skaruz.com\u003e');
                    System.assertEquals(resultEmail.Labels__c, 'Label_1');
                    System.assertEquals(resultEmail.Subject_Line__c, 'test 1');
                    System.assertEquals(resultEmail.To__c, 'TestSyncProject@gmail.com');
                    System.assertEquals(resultEmail.User_Labels__c, 'Label_1');
            Test.stopTest();
        }
    }
    
    private static testMethod void testProcessAttachmentInfo() {
        Id profileId = [SELECT Name FROM Profile WHERE Profile.Name = 'GNE-MCCO-340B' ].Id;
        User u = createUser('example1', profileId, true);

        System.runAs(u) {
            GNE_CRM_340B_Email__c email = new GNE_CRM_340B_Email__c();
            email.Username__c = 'example1user@veevasystems.com';
            email.Message_ID__c = '123';
            insert email;
            
            GNE_CRM_340B_Attachment__c att = new GNE_CRM_340B_Attachment__c();
            att.Username__c = 'example1user@veevasystems.com';
            att.X340B_Email__c = email.Id;
            att.Attachment_ID__c = '456';
            att.FileName__c = 'Sample.txt';
            att.MIME_Type__c = 'text/plain';
            insert att;

            CalloutMock callMock = new CalloutMock();
            callMock.response = '{ "size": 80582, "data": "JVBERi0xLjUNCiW1tbW1DQoxIDAFT0Y="}';
            Test.setMock(HttpCalloutMock.class, callMock);
        
            Test.startTest();
                System.assertEquals(1, [ SELECT Id FROM GNE_CRM_340B_Attachment__c ].size());
                GNE_CRM_340B_Google_Utlis.processAttachmentInfo(new List<GNE_CRM_340B_Attachment__c>{att});
                System.assertEquals(0, [ SELECT Id FROM GNE_CRM_340B_Attachment__c ].size());
                List<Attachment> attList =  [ SELECT Id, ParentId, Name, ContentType FROM Attachment ];
                System.assertEquals(1, attList.size());
                System.assertEquals(att.X340B_Email__c, attList.get(0).ParentId);
                System.assertEquals(att.MIME_Type__c, attList.get(0).ContentType);
                System.assertEquals(att.FileName__c, attList.get(0).Name);
            Test.stopTest();
        }
    }
    
    private static testMethod void testGetOldestGoogleTokens() {
       GNE_MCCO_CRM_340B_Google_Tokens__c gt1 = GNE_CRM_340B_Google_Utlis.getOldestGoogleTokens();
        System.assertEquals(gt1.Name, 'example2user@veevasystems.com');
        
        GNE_MCCO_CRM_340B_Google_Tokens__c gt2 = [ SELECT Name, Last_Sync__c FROM GNE_MCCO_CRM_340B_Google_Tokens__c WHERE Name = 'example1user@veevasystems.com' ];
        gt2.Last_Sync__c = null;
        update gt2;
        GNE_MCCO_CRM_340B_Google_Tokens__c gt3 = GNE_CRM_340B_Google_Utlis.getOldestGoogleTokens();
        System.assertEquals(gt3.Name, 'example1user@veevasystems.com');
    }
}