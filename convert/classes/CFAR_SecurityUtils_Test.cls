@IsTest
private class CFAR_SecurityUtils_Test {

    @testSetup
    static void setup() {

        Id readOnlyProfileId  = [SELECT Id FROM Profile WHERE Name = 'Read Only'].Id;
        Id cfarUserNewProfileId = [SELECT Id FROM Profile WHERE Name = 'GNE-CFAR-User-New'].Id;
        Id cfarAdminNewProfileId = [SELECT Id FROM Profile WHERE Name = 'GNE-CFAR-Admin-New'].Id;

        insert new List<User> {
            new User(
                Alias = 'readOnly', Email = 'readOnly@gene.com',
                EmailEncodingKey = 'UTF-8', LastName = 'readOnly', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = readOnlyProfileId,
                TimeZoneSidKey = 'America/Los_Angeles', UserName = 'readOnly@gene.com'
            ),
            new User(
                Alias = 'userNew', Email = 'userNew@gene.com',
                EmailEncodingKey = 'UTF-8', LastName = 'userNew', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = cfarUserNewProfileId,
                TimeZoneSidKey = 'America/Los_Angeles', UserName = 'userNew@gene.com'
            ),
            new User(
                Alias = 'adminNew', Email = 'adminNew@gene.com',
                EmailEncodingKey = 'UTF-8', LastName = 'adminNew', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = cfarAdminNewProfileId,
                TimeZoneSidKey = 'America/Los_Angeles', UserName = 'adminNew@gene.com'
            )
        };
        System.assert(true);
    }

    @IsTest
    private static void shouldPreventDeleteIfNoCRUDAccess() {
        User userNoDeleteAccess = [SELECT Id FROM User WHERE Alias = 'readOnly'];
        Boolean exThrown = false;
        String message;
        // when
        System.runAs(userNoDeleteAccess) {
            CFAR_Contact_gne__c con = new CFAR_Contact_gne__c();
            insert con;
            try {
                CFAR_SecurityUtils.deleteRecord(con);
            } catch (Exception ex) {
                exThrown = true;
                message = ex.getMessage();
            }
        }
        // then
        System.assertEquals(true, exThrown);
        System.assert(String.isNotBlank(message));
        System.assertEquals(Label.CFAR_DELETE_NO_ACCESS, message);
    }

    @IsTest
    private static void shouldDeleteRecords() {
        User userWithDeleteAccess = [SELECT Id FROM User WHERE Alias = 'userNew'];
        Boolean exThrown = false;
        String message;
        // when
        System.runAs(userWithDeleteAccess) {
            CFAR_Contact_gne__c con = new CFAR_Contact_gne__c();
            CFAR_Contact_gne__c con2 = new CFAR_Contact_gne__c();
            insert con;
            insert con2;
            try {
                CFAR_SecurityUtils.deleteRecord(con);
                CFAR_SecurityUtils.deleteRecords(new List<CFAR_Contact_gne__c>{con2});
            } catch (Exception ex) {
                exThrown = true;
                message = ex.getMessage();
            }
        }
        // then
        System.assertEquals(false, exThrown);
        System.assert(String.isBlank(message));
        System.assert([SELECT Id FROM CFAR_Contact_gne__c].isEmpty());
    }

    @IsTest
    private static void shouldPreventInsertIfNoCRUDAccess () {
        //GIVEN
        User userNoInsertAccess = [SELECT Id FROM User WHERE Alias = 'readOnly'];

        Boolean exThrown = false;
        String message;

        //WHEN
        System.runAs(userNoInsertAccess) {
            CFAR_Trial_Status_gne__c status = new CFAR_Trial_Status_gne__c();
            status.Active_gne__c = true;
            try {
                CFAR_SecurityUtils.insertRecord(status);
            } catch (Exception ex) {
                exThrown = true;
                message = ex.getMessage();
            }
        }

        //THEN
        System.assertEquals(true, exThrown);
        System.assert(String.isNotBlank(message));
        System.assertEquals(Label.CFAR_INSERT_NO_ACCESS, message);
    }

    @IsTest
    private static void shouldInsertRecords () {
        //GIVEN
        User userWithInsertAccess = [SELECT Id FROM User WHERE Alias = 'adminNew'];
        Boolean exThrown = false;
        String message;

        //WHEN
        Database.SaveResult saveResult;
        System.runAs(userWithInsertAccess) {
            CFAR_Trial_Status_gne__c status = new CFAR_Trial_Status_gne__c();
            status.Active_gne__c = true;
            try {
                saveResult = CFAR_SecurityUtils.insertRecord(status)[0];
            } catch (Exception ex) {
                exThrown = true;
                message = ex.getMessage();
            }
        }

        //THEN
        System.assertEquals(false, exThrown);
        System.assertEquals(true, saveResult.isSuccess());
    }

    @IsTest
    private static void shouldPreventUpdateIfNoCRUDAccess () {
        //GIVEN
        CFAR_Trial_Status_gne__c status = new CFAR_Trial_Status_gne__c();
        status.Active_gne__c = true;
        insert status;

        User userNoUpdateAccess = [SELECT Id FROM User WHERE Alias = 'readOnly'];
        Boolean exThrown = false;
        String message;

        //WHEN
        System.runAs(userNoUpdateAccess) {
            status.Active_gne__c = false;
            try {
                CFAR_SecurityUtils.updateRecord(status);
            } catch (Exception ex) {
                exThrown = true;
                message = ex.getMessage();
            }
        }

        //THEN
        System.assertEquals(true, exThrown);
        System.assert(String.isNotBlank(message));
        System.assertEquals(Label.CFAR_UPDATE_NO_ACCESS, message);
    }

    @IsTest
    private static void shouldUpdateRecords () {
        //GIVEN
        User userWithUpdateAccess = [SELECT Id FROM User WHERE Alias = 'adminNew'];
        Boolean exThrown = false;
        String message;

        //WHEN
        Database.SaveResult saveResult;
        System.runAs(userWithUpdateAccess) {
                    CFAR_Contact_gne__c con = new CFAR_Contact_gne__c();
        insert con;
            con.Suffix_gne__c = 'testsuffix';
            try {
                saveResult = CFAR_SecurityUtils.updateRecord(con)[0];
            } catch (Exception ex) {
                exThrown = true;
                message = ex.getMessage();
            }
        }

        //THEN
        System.assertEquals(false, exThrown);
        System.assertEquals(true, saveResult.isSuccess());
    }

    @IsTest
    private static void shouldPreventUpsertIfNoCRUDAccess () {
        //GIVEN
        User userNoUpsertAccess = [SELECT Id FROM User WHERE Alias = 'readOnly'];
        Boolean exThrown = false;
        String message;

        //WHEN
        System.runAs(userNoUpsertAccess) {
            CFAR_Trial_Status_gne__c status = new CFAR_Trial_Status_gne__c();
            status.Active_gne__c = true;
            try {
                CFAR_SecurityUtils.upsertRecord(status, CFAR_Trial_Status_gne__c.getSObjectType());
            } catch (Exception ex) {
                exThrown = true;
                message = ex.getMessage();
            }
        }

        //THEN
        System.assertEquals(true, exThrown);
        System.assert(String.isNotBlank(message));
        System.assertEquals(Label.CFAR_UPSERT_NO_ACCESS, message);
    }

    @IsTest
    private static void shouldUpsertRecords () {
        //GIVEN
        User userWithUpsertAccess = [SELECT Id FROM User WHERE Alias = 'adminNew'];
        Boolean exThrown = false;
        String message;

        //WHEN
        Database.UpsertResult upsertResult;
        System.runAs(userWithUpsertAccess) {
            CFAR_Trial_Status_gne__c status = new CFAR_Trial_Status_gne__c();
            status.Active_gne__c = true;
            try {
                upsertResult = CFAR_SecurityUtils.upsertRecord(status, CFAR_Trial_Status_gne__c.getSObjectType())[0];
            } catch (Exception ex) {
                System.debug(ex.getMessage());
                exThrown = true;
                message = ex.getMessage();
            }
        }

        //THEN
        System.assertEquals(false, exThrown);
        System.assertEquals(true, upsertResult.isSuccess());
    }
}