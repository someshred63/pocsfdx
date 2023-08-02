@isTest
private class GNE_SFA2_PushNotificationsTest {
    static final String ALERT_ALL_RT_ID = Schema.SObjectType.Sfa_Alert_gne__c.getRecordTypeInfosByName().get('Broadcast All Users').getRecordTypeId();
    static final String ALERT_SINGLE_RT_ID = Schema.SObjectType.Sfa_Alert_gne__c.getRecordTypeInfosByName().get('Broadcast Single User').getRecordTypeId();
    static final String ALERT_PROFILE_RT_ID = Schema.SObjectType.Sfa_Alert_gne__c.getRecordTypeInfosByName().get('Broadcast to profile').getRecordTypeId();

    @testSetup
    static void testData() {
        Map<String, Id> name2RtId = GNE_FRM_TestUtilities.getAccountRecordTypes();
        Map<String, Id> ids2ProfilesMap = GNE_FRM_TestUtilities.getProfiles();
        User afrmManager = GNE_FRM_TestUtilities.createUser('afrmManagert', ids2ProfilesMap.get('GNE-Field'), true); 

        Sfa_Alert_gne__c alert = new Sfa_Alert_gne__c();
        alert.isAllUserNotification_gne__c = true;
        alert.Description_gne__c = 'Test description';
        alert.Title_gne__c = 'Title 1';
        alert.RecordTypeId = ALERT_ALL_RT_ID;
        
        Sfa_Alert_gne__c alert1 = new Sfa_Alert_gne__c();
        alert1.User_gne__c = afrmManager.Id;
        alert1.Description_gne__c = 'Test description';
        alert1.Title_gne__c = 'Title 2';
        alert1.RecordTypeId = ALERT_SINGLE_RT_ID;
        
        Sfa_Alert_gne__c alert2 = new Sfa_Alert_gne__c();
        alert2.Send_To_Profiles__c = 'GNE-MCCO-FRM-BFRM';
        alert2.Description_gne__c = 'Test description';
        alert2.Title_gne__c = 'Title 3';
        alert2.Send_Date_gne__c = System.now();
        alert2.RecordTypeId = ALERT_PROFILE_RT_ID;
        
        insert new List<Sfa_Alert_gne__c>{alert, alert1,alert2};
            
        GNE_Foun_Misc_Config_Items_gne__c conf1p = new GNE_Foun_Misc_Config_Items_gne__c(Configuration_Value_gne__c = 'xxx', Name='PROD_OTR_BUNDLE_ID_GOOGLEAPI');
        GNE_Foun_Misc_Config_Items_gne__c conf1d = new GNE_Foun_Misc_Config_Items_gne__c(Configuration_Value_gne__c = 'xxx', Name='DEV_OTR_BUNDLE_ID_GOOGLEAPI');
        GNE_Foun_Misc_Config_Items_gne__c conf1s = new GNE_Foun_Misc_Config_Items_gne__c(Configuration_Value_gne__c = 'xxx', Name='SQA_OTR_BUNDLE_ID_GOOGLEAPI');
        GNE_Foun_Misc_Config_Items_gne__c conf1u = new GNE_Foun_Misc_Config_Items_gne__c(Configuration_Value_gne__c = 'xxx', Name='UAT_OTR_BUNDLE_ID_GOOGLEAPI');
        GNE_Foun_Misc_Config_Items_gne__c conf2 = new GNE_Foun_Misc_Config_Items_gne__c(Configuration_Value_gne__c = 'rrr', Name='OTR_KEY_GOOGLEAPI');
        GNE_Foun_Misc_Config_Items_gne__c conf3 = new GNE_Foun_Misc_Config_Items_gne__c(Configuration_Value_gne__c = 'sss', Name='OTR_ENDPOINT_GOOGLEAPI');
        insert new List<GNE_Foun_Misc_Config_Items_gne__c>{conf1p, conf1d, conf1s, conf1u, conf2, conf3};
    }
    
    @isTest
    static void testsendNotificationAllUserSuccesed() {
        GNE_FRM_TestUtilities.CalloutMock callMock = new GNE_FRM_TestUtilities.CalloutMock();
        callMock.response = '{"message_id":4666622979323958007}';       
        Test.setMock(HttpCalloutMock.class, callMock);
        Sfa_Alert_gne__c alert = [SELECT Id FROM Sfa_Alert_gne__c WHERE Title_gne__c = 'Title 1'];
        Test.startTest();
            GNE_SFA2_PushNotifications.sendPushNotification(alert.Id);
        Test.stopTest();   
        alert = [SELECT Send_Date_gne__c, Response_Status_gne__c FROM Sfa_Alert_gne__c WHERE Id = :alert.Id];

        System.assertEquals(true, alert.Send_Date_gne__c != null);
        System.assertEquals('Status code: 200:: Status: OK', alert.Response_Status_gne__c);
    }
    
    @isTest
    static void testsendNotificationSelectedUserSuccesed() {
        GNE_FRM_TestUtilities.CalloutMock callMock = new GNE_FRM_TestUtilities.CalloutMock();
        callMock.response = '{"message_id":4666622979323958007}';       
        Test.setMock(HttpCalloutMock.class, callMock);
        Sfa_Alert_gne__c alert = [SELECT Id FROM Sfa_Alert_gne__c WHERE Title_gne__c = 'Title 2'];
        Test.startTest();
            GNE_SFA2_PushNotifications.sendPushNotification(alert.Id);
        Test.stopTest();   
        alert = [SELECT Send_Date_gne__c, Response_Status_gne__c FROM Sfa_Alert_gne__c WHERE Id = :alert.Id];
        
        System.assertEquals(true, alert.Send_Date_gne__c != null);
        System.assertEquals('Status code: 200:: Status: OK', alert.Response_Status_gne__c);
    }
    
    @isTest
    static void testUnknowRecordError() {    
        String fakeId = GNE_FRM_TestUtilities.getFakeId(Sfa_Alert_gne__c.SObjectType);
        fakeId += 'GAA';

        Test.startTest();
            String result = GNE_SFA2_PushNotifications.sendPushNotification(fakeId);
        Test.stopTest();   
 
        System.assertEquals('Unknown record for Id: '+fakeId, result);
    }
    
    @isTest
    static void testAlreadySentError() {    
        GNE_FRM_TestUtilities.CalloutMock callMock = new GNE_FRM_TestUtilities.CalloutMock();
        callMock.response = '{"message_id":4666622979323958007}';       
        Test.setMock(HttpCalloutMock.class, callMock);
        Sfa_Alert_gne__c alert = [SELECT Id FROM Sfa_Alert_gne__c WHERE Title_gne__c = 'Title 3'];

        alert = [SELECT Send_Date_gne__c, Response_Status_gne__c FROM Sfa_Alert_gne__c WHERE Id = :alert.Id];  
        Test.startTest();
            String result = GNE_SFA2_PushNotifications.sendPushNotification(alert.Id);
        Test.stopTest();          
 
        System.assertEquals('Record already sent at '+alert.Send_Date_gne__c, result);
    }
    
    @isTest
    static void testMissingConf_BUNDLE_ID() {    
        delete [SELECT Id FROM GNE_Foun_Misc_Config_Items_gne__c WHERE Name LIKE '%OTR_BUNDLE_ID_GOOGLEAPI'];
        GNE_FRM_TestUtilities.CalloutMock callMock = new GNE_FRM_TestUtilities.CalloutMock();
        callMock.response = '{"message_id":4666622979323958007}';       
        Test.setMock(HttpCalloutMock.class, callMock);
        
        Sfa_Alert_gne__c alert = [SELECT Id FROM Sfa_Alert_gne__c WHERE Title_gne__c = 'Title 2'];

        Test.startTest();
            String result = GNE_SFA2_PushNotifications.sendPushNotification(alert.Id);
        Test.stopTest();          
 
        System.assertEquals('Missing configuration for bundle id, please report this issue to your application administarator.', result);
    }
    
    @isTest
    static void testMissingConf_KEY() {    
        delete [SELECT Id FROM GNE_Foun_Misc_Config_Items_gne__c WHERE Name='OTR_KEY_GOOGLEAPI'];
        GNE_FRM_TestUtilities.CalloutMock callMock = new GNE_FRM_TestUtilities.CalloutMock();
        callMock.response = '{"message_id":4666622979323958007}';       
        Test.setMock(HttpCalloutMock.class, callMock);
        
        Sfa_Alert_gne__c alert = [SELECT Id FROM Sfa_Alert_gne__c WHERE Title_gne__c = 'Title 2'];

        Test.startTest();
            String result = GNE_SFA2_PushNotifications.sendPushNotification(alert.Id);
        Test.stopTest();          
 
        System.assertEquals('Missing configuration for authorization, please report this issue to your application administarator.', result);
    }
    
    @isTest
    static void testMissingConf_BUNDLE_ENDPOINT() {    
        delete [SELECT Id FROM GNE_Foun_Misc_Config_Items_gne__c WHERE Name='OTR_ENDPOINT_GOOGLEAPI'];
        GNE_FRM_TestUtilities.CalloutMock callMock = new GNE_FRM_TestUtilities.CalloutMock();
        callMock.response = '{"message_id":4666622979323958007}';       
        Test.setMock(HttpCalloutMock.class, callMock);
        
        Sfa_Alert_gne__c alert = [SELECT Id FROM Sfa_Alert_gne__c WHERE Title_gne__c = 'Title 2'];

        Test.startTest();
            String result = GNE_SFA2_PushNotifications.sendPushNotification(alert.Id);
        Test.stopTest();          
 
        System.assertEquals('Missing configuration for endpoint, please report this issue to your application administarator.', result);
    }

}