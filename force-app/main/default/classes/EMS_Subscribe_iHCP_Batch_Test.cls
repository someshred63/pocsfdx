@isTest
private class EMS_Subscribe_iHCP_Batch_Test {

    private static Integer recordsCount = 201;

    @isTest
    static void testInsertOperation() {
        List<Stg_EMS_iHCP_gne__c> testScope = prepareTestData('testFirstName', recordsCount, 'I');
        EMS_Subscribe_iHCP_Batch subsribeBatch = new EMS_Subscribe_iHCP_Batch();

        Test.startTest();

        subsribeBatch.start(null);
        subsribeBatch.execute(null, testScope);
        subsribeBatch.finish(null);

        Test.stopTest();

        Integer internationalSpeakersCount = [SELECT count() FROM EMS_International_Speaker_gne__c];
        System.assertEquals(internationalSpeakersCount, recordsCount);

        for (Stg_EMS_iHCP_gne__c stgRecord : testScope) {
            System.assertEquals(stgRecord.Subscribe_Status_gne__c, 'Processed');
        }

    }

    @isTest
    static void testInvalidOperation() {
        List<Stg_EMS_iHCP_gne__c> testScope = prepareTestData('testFirstName', recordsCount, 'X');
        EMS_Subscribe_iHCP_Batch subsribeBatch = new EMS_Subscribe_iHCP_Batch();

        Test.startTest();

        subsribeBatch.start(null);
        subsribeBatch.execute(null, testScope);
        subsribeBatch.finish(null);

        Test.stopTest();

        Integer internationalSpeakersCount = [SELECT count() FROM EMS_International_Speaker_gne__c];
        System.assertEquals(internationalSpeakersCount, 0);

        for (Stg_EMS_iHCP_gne__c stgRecord : [
                SELECT First_Name_gne__c, Last_Name_gne__c, Middle_Name_gne__c, Email_gne__c, IHCP_ID_gne__c, IHCP_Created_Date_gne__c, IHCP_Last_Modified_Date_gne__c, IHCP_Name_gne__c,
                        Inactive_Indicator_gne__c, Institution_gne__c, Phone_gne__c, Position_gne__c, Profession_gne__c, Speciality_gne__c, Speciality_MS_gne__c, State_Province_gne__c, Subscribe_Status_gne__c, Title_gne__c, Zip_gne__c,
                        Address_gne__c, Address_2_gne__c, Affiliation_gne__c, City_gne__c, Country_gne__c, Delta_Instruction_gne__c
                FROM Stg_EMS_iHCP_gne__c
        ]) {

            System.assertEquals('Failed', stgRecord.Subscribe_Status_gne__c);
        }

    }

    @isTest
    static void testInvalidIhcpIdForUpdateOperation() {
        List<Stg_EMS_iHCP_gne__c> testScope = prepareTestData('testFirstName', recordsCount, 'I');
        EMS_Subscribe_iHCP_Batch subsribeBatch = new EMS_Subscribe_iHCP_Batch();

        subsribeBatch.start(null);
        subsribeBatch.execute(null, testScope);
        subsribeBatch.finish(null);

        Integer internationalSpeakersCount = [SELECT count() FROM EMS_International_Speaker_gne__c];
        System.assertEquals(internationalSpeakersCount, recordsCount);
        for (Stg_EMS_iHCP_gne__c stgRecord : testScope) {
            System.assertEquals(stgRecord.Subscribe_Status_gne__c, 'Processed');
        }

        List<Stg_EMS_iHCP_gne__c> processedScope = [
                SELECT First_Name_gne__c, Last_Name_gne__c, Middle_Name_gne__c, Email_gne__c, IHCP_ID_gne__c, IHCP_Created_Date_gne__c, IHCP_Last_Modified_Date_gne__c, IHCP_Name_gne__c,
                        Inactive_Indicator_gne__c, Institution_gne__c, Phone_gne__c, Position_gne__c, Profession_gne__c, Speciality_gne__c, Speciality_MS_gne__c, State_Province_gne__c, Subscribe_Status_gne__c, Title_gne__c, Zip_gne__c,
                        Address_gne__c, Address_2_gne__c, Affiliation_gne__c, City_gne__c, Country_gne__c, Delta_Instruction_gne__c
                FROM Stg_EMS_iHCP_gne__c
        ];

        for (Stg_EMS_iHCP_gne__c stagingRecord : processedScope) {
            stagingRecord.Subscribe_Status_gne__c = 'Not Processed';
            stagingRecord.First_Name_gne__c = 'changedFirstName';
            stagingRecord.Delta_Instruction_gne__c = 'U';
            stagingRecord.IHCP_ID_gne__c = 'aACn00000008OoE';    //specify invalid iHCP id
        }

        update processedScope;

        Test.startTest();

        subsribeBatch.start(null);
        subsribeBatch.execute(null, processedScope);
        subsribeBatch.finish(null);

        Test.stopTest();


        for (Stg_EMS_iHCP_gne__c stgRecord : [SELECT Subscribe_Status_gne__c, First_Name_gne__c, Delta_Instruction_gne__c FROM Stg_EMS_iHCP_gne__c]) {
            System.assertEquals('Failed', stgRecord.Subscribe_Status_gne__c);
        }

        internationalSpeakersCount = [SELECT count() FROM EMS_International_Speaker_gne__c];
        System.assertEquals(internationalSpeakersCount, recordsCount);
        for (EMS_International_Speaker_gne__c internationalSpealer : [SELECT First_Name_gne__c FROM EMS_International_Speaker_gne__c]) {
            System.assertNotEquals('changedFirstName', internationalSpealer.First_Name_gne__c);
        }
    }

    @isTest
    static void testUpdateOperation() {
        List<EMS_International_Speaker_gne__c> internationalSpeakers = prepareInternationalSpeakers(recordsCount);

        Integer internationalSpeakersCount = [SELECT count() FROM EMS_International_Speaker_gne__c];
        System.assertEquals(internationalSpeakersCount, recordsCount);

        List<Stg_EMS_iHCP_gne__c> testScope = prepareTestData('testFirstName', recordsCount, 'U');
        EMS_Subscribe_iHCP_Batch subscribeBatch = new EMS_Subscribe_iHCP_Batch();

        Test.startTest();

        //Database.executeBatch(subscribeBatch);

        subscribeBatch.start(null);
        subscribeBatch.execute(null, testScope);
        subscribeBatch.finish(null);

        Test.stopTest();


        for (Stg_EMS_iHCP_gne__c stgRecord : [SELECT Subscribe_Status_gne__c, First_Name_gne__c, Delta_Instruction_gne__c FROM Stg_EMS_iHCP_gne__c WHERE Id IN :testScope]) {
            System.assertEquals('Processed', stgRecord.Subscribe_Status_gne__c);
        }

        internationalSpeakersCount = [SELECT count() FROM EMS_International_Speaker_gne__c];
        System.assertEquals(internationalSpeakersCount, recordsCount);
        for (EMS_International_Speaker_gne__c internationalSpeaker : [SELECT First_Name_gne__c FROM EMS_International_Speaker_gne__c WHERE Id IN :internationalSpeakers]) {
            System.assertEquals('testFirstName', internationalSpeaker.First_Name_gne__c);
        }
    }

    @isTest
    static void testDeleteOperation() {
        List<EMS_International_Speaker_gne__c> internationalSpeakers = prepareInternationalSpeakers(recordsCount);

        Integer internationalSpeakersCount = [SELECT count() FROM EMS_International_Speaker_gne__c];
        System.assertEquals(internationalSpeakersCount, recordsCount);

        List<Stg_EMS_iHCP_gne__c> testScope = prepareTestData('testFirstName', recordsCount, 'U');
        EMS_Subscribe_iHCP_Batch subscribeBatch = new EMS_Subscribe_iHCP_Batch();

        for (Stg_EMS_iHCP_gne__c stgRecord : testScope) {
            stgRecord.Inactive_Indicator_gne__c = 1;
        }

        update testScope;

        Test.startTest();

        //Database.executeBatch(subscribeBatch);

        subscribeBatch.start(null);
        subscribeBatch.execute(null, testScope);
        subscribeBatch.finish(null);

        Test.stopTest();


        for (Stg_EMS_iHCP_gne__c stgRecord : [SELECT Subscribe_Status_gne__c, First_Name_gne__c, Delta_Instruction_gne__c FROM Stg_EMS_iHCP_gne__c WHERE Id IN :testScope]) {
            System.assertEquals('Processed', stgRecord.Subscribe_Status_gne__c);
        }

        internationalSpeakersCount = [SELECT count() FROM EMS_International_Speaker_gne__c];
        System.assertEquals(internationalSpeakersCount, recordsCount);
        for (EMS_International_Speaker_gne__c internationalSpeaker : [SELECT Is_Active_gne__c FROM EMS_International_Speaker_gne__c WHERE Id IN :internationalSpeakers]) {
            System.assertEquals(false, internationalSpeaker.Is_Active_gne__c);
        }
    }

    private static List<Stg_EMS_iHCP_gne__c> prepareTestData(String firstName, Integer count, String operation) {
        List<Stg_EMS_iHCP_gne__c> testDataToAdd = new List<Stg_EMS_iHCP_gne__c>();
        for (Integer i = 0; i < count; i++) {
            testDataToAdd.add(prepareStagingRecord(firstName, i, operation));
        }
        insert testDataToAdd;
        return testDataToAdd;
    }

    private static String rightPad(String text, String paddingChar, Integer length) {
        while (text.length() < length) {
            text = paddingChar + text;
        }
        return text;
    }

    private static Stg_EMS_iHCP_gne__c prepareStagingRecord(String firstName, Integer i, String operation) {
        Stg_EMS_iHCP_gne__c stagingRecord = new Stg_EMS_iHCP_gne__c();
        stagingRecord.First_Name_gne__c = firstName;
        stagingRecord.Last_Name_gne__c = 'testLastName';
        stagingRecord.Middle_Name_gne__c = 'testMiddleName';
        stagingRecord.Email_gne__c = 'testMail@testtest.tes';
        stagingRecord.Address_gne__c = 'testAddress1';
        stagingRecord.Address_2_gne__c = 'testAddress2';
        stagingRecord.City_gne__c = 'testCity';
        stagingRecord.Country_gne__c = 'testCountry';
        stagingRecord.Delta_Instruction_gne__c = operation;
        stagingRecord.IHCP_Created_Date_gne__c = System.today();
        stagingRecord.IHCP_Last_Modified_Date_gne__c = System.today();
        stagingRecord.IHCP_Name_gne__c = 'HCO-1312376';
        stagingRecord.IHCP_ID_gne__c = rightPad(String.valueOf(i), '0', 18);
        return stagingRecord;
    }

    private static List<EMS_International_Speaker_gne__c> prepareInternationalSpeakers(Integer count) {
        List<EMS_International_Speaker_gne__c> testDataToAdd = new List<EMS_International_Speaker_gne__c>();
        for (Integer i = 0; i < count; i++) {

            EMS_International_Speaker_gne__c speaker = new EMS_International_Speaker_gne__c();

            speaker.Name = 'firstName lastName';
            speaker.First_Name_gne__c = 'firstName';
            speaker.Last_Name_gne__c = 'lastName';
            speaker.Middle_Name_gne__c = 'middle';
            speaker.Address_gne__c = 'addr';
            speaker.Address_2_gne__c = 'addr2';
            speaker.Affiliation_gne__c = 'affiliation';
            speaker.State_Province_gne__c = 'province';
            speaker.Zip_gne__c = 'zip';
            speaker.City_gne__c = 'city';
            speaker.Country_gne__c = 'country';
            speaker.Email_gne__c = 'email@email.com';
            speaker.Phone_gne__c = 'phone';
            speaker.Institution_gne__c = 'institution';
            speaker.Position_gne__c = 'position';
            speaker.Profession_gne__c = 'profession';
            speaker.Speciality_gne__c = 'specialty';
            speaker.Speciality_MS_gne__c = 'speciality_ms';
            speaker.Title_gne__c = 'title';

            // fill iHCP system details
            speaker.IHCP_ID_gne__c = rightPad(String.valueOf(i), '0', 18);
            speaker.IHCP_Name_gne__c = 'ihcpname';
            speaker.IHCP_Created_Date_gne__c = Date.today();
            speaker.IHCP_Last_Modified_Date_gne__c = Date.today();

            // mark inactive iHCPs
            speaker.Is_Active_gne__c = true;

            testDataToAdd.add(speaker);
        }

        insert testDataToAdd;
        return testDataToAdd;
    }
}