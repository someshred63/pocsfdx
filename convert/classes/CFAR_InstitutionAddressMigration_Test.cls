@IsTest
private class CFAR_InstitutionAddressMigration_Test {

    private static String input;

    @testSetup
    static void setup() {
        CFAR_TestUtils.createTestITAdminUser();
        System.assert(true);
    }

    private static void setupInput() {
        CFAR_Parent_Organization_gne__c parent = new CFAR_Parent_Organization_gne__c();
        parent.Name = 'testparent';
        parent.Active_gne__c = true;
        insert parent;
        System.assertEquals(1, [SELECT ID FROM CFAR_Parent_Organization_gne__c].size());

        CFAR_Institution_gne__c institution = new CFAR_Institution_gne__c();
        institution.Name = 'TestInstitution';
        institution.Parent_Organization__c = parent.Id;
        institution.Active_gne__c = true;
        insert institution;
        CFAR_Institution_gne__c institution2 = new CFAR_Institution_gne__c();
        institution2.Name = 'TestInstitution2';
        institution2.Parent_Organization__c = parent.Id;
        institution2.Active_gne__c = true;
        insert institution2;
        CFAR_Institution_gne__c institution3 = new CFAR_Institution_gne__c();
        institution3.Name = 'TestInstitution3';
        institution3.Parent_Organization__c = parent.Id;
        institution3.Active_gne__c = true;
        insert institution3;

        CFAR_Address_Type_gne__c addressType = new CFAR_Address_Type_gne__c();
        addressType.Name = 'Fedex Delivery';
        insert addressType;

        CFAR_Contact_Address_gne__c address = new CFAR_Contact_Address_gne__c();
        address.Address_Type_ref_gne__c = addressType.Id;
        address.Country_gne__c = 'Argentina';
        address.Province_gne__c = 'TestProvince';
        address.City_gne__c = 'TestCity';
        address.Address_gne__c = 'TestAddress';
        address.Postal_Code_gne__c = '12345';
        address.institution_gne__c = institution.Id;
        insert address;
        CFAR_Contact_Address_gne__c address2 = new CFAR_Contact_Address_gne__c();
        address2.Address_Type_ref_gne__c = addressType.Id;
        address2.Country_gne__c = 'Argentina2';
        address2.Province_gne__c = 'TestProvince2';
        address2.City_gne__c = 'TestCity2';
        address2.Address_gne__c = 'TestAddress2';
        address2.Postal_Code_gne__c = '12345';
        address2.institution_gne__c = institution2.Id;
        insert address2;
        CFAR_Contact_Address_gne__c address3 = new CFAR_Contact_Address_gne__c();
        address3.Address_Type_ref_gne__c = addressType.Id;
        address3.Country_gne__c = 'Argentina3';
        address3.Province_gne__c = 'TestProvince3';
        address3.City_gne__c = 'TestCity3';
        address3.Address_gne__c = 'TestAddress3';
        address3.Postal_Code_gne__c = '12345';
        address3.institution_gne__c = institution3.Id;
        insert address3;

        input = address.Id + ';Washington Medical Foundation;Kaiser Santa Clara\n' +
                +address2.Id + ';Albert Anthony;Kaiser Corporate Headquarters\n' +
                +address3.Id + ';San Francisco Research Organisation;Kaiser South San Francisco';
    }

    static testMethod void shouldValidateInput() {
        User itAdmin = [SELECT Id FROM User WHERE alias = 'testITAd'];
        System.runAs(itAdmin) {
            // given
            CFAR_InstitutionAddressMigration_Crtl ctrl = new CFAR_InstitutionAddressMigration_Crtl();
            ctrl.csvInput = 'row1 \n row2 \n row3';
            // when
            Boolean migrationExceptionThrown = false;
            String msg;
            try {
                ctrl.startMigration();
            } catch (CFAR_InstitutionAddressMigration_Crtl.MigrationException ex) {
                migrationExceptionThrown = true;
                msg = ex.getMessage();
            }
            // then
            System.assertEquals(true, migrationExceptionThrown);
            System.assert(msg.contains('Incorrect input format '));
        }
    }

    static testMethod void shouldStartMigration() {
        User itAdmin = [SELECT Id FROM User WHERE alias = 'testITAd'];
        System.runAs(itAdmin) {
        // given
        setupInput();
        System.assert(String.isNotBlank(input));
        System.assertEquals(1, [SELECT Count() FROM CFAR_Parent_Organization_gne__c]);
        System.assertEquals(3, [SELECT Id FROM CFAR_Institution_gne__c].size());
        CFAR_InstitutionAddressMigration_Crtl ctrl = new CFAR_InstitutionAddressMigration_Crtl();
        ctrl.csvInput = input;
        // when
        ctrl.startMigration();
        // then
        System.assertEquals(4, [SELECT Count() FROM CFAR_Parent_Organization_gne__c]);
        System.assertEquals(1, [SELECT Count() FROM CFAR_Parent_Organization_gne__c WHERE Name = 'Kaiser Santa Clara']);
        System.assertEquals(1, [SELECT Count() FROM CFAR_Parent_Organization_gne__c WHERE Name = 'Kaiser Corporate Headquarters']);
        System.assertEquals(1, [SELECT Count() FROM CFAR_Parent_Organization_gne__c WHERE Name = 'Kaiser South San Francisco']);
        System.assertEquals(6, [SELECT Count() FROM CFAR_Institution_gne__c]);
        System.assertEquals(1, [SELECT Count() FROM CFAR_Institution_gne__c WHERE Name = 'Albert Anthony']);
        System.assertEquals(1, [SELECT Count() FROM CFAR_Institution_gne__c WHERE Name = 'San Francisco Research Organisation']);
        System.assertEquals(1, [SELECT Count() FROM CFAR_Institution_gne__c WHERE Name = 'Washington Medical Foundation']);
    }
    }

}