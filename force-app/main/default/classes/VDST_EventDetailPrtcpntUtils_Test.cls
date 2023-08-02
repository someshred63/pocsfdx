/** @date 2/25/2013
* @Author Pawel Sprysak
* @description Test Class for Event Detail Participant Utils
*/
@isTest
public class VDST_EventDetailPrtcpntUtils_Test {
    /** @date 2/25/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for constructor() method
    */
    @IsTest(SeeAllData=false)
    static void controller_Test() {
        // Prepare test data
        VDST_Event_gne__c ev = prepareEvent('ADBOARD');
        VDST_EventPrtcpntRole_gne__c epr = new VDST_EventPrtcpntRole_gne__c(EventType_gne__c = 'ADBOARD', EventParticipantRoleCode_gne__c = 'ATND',
            EventParticipantRoleName__c = 'Attendee');
        insert epr;
        // Run constructor
        Test.startTest();
        VDST_EventDetailPrtcpntUtils edp = new VDST_EventDetailPrtcpntUtils(ev.Id);
        Test.stopTest();
        // Constructor test - is Event Type as in URL param
        System.assertEquals(edp.eventType, 'ADBOARD');
    }

    /** @date 3/18/2014 
    * @Author Pawel Sprysak
    * @description Test Method - Test for getRschPrtcpntBtnVisib() getter
    */
    @IsTest(SeeAllData=false)
    static void getRschPrtcpntBtnVisib_Test() {
        // Prepare data
        VDST_Event_gne__c ev = prepareEvent('RSCH');
        VDST_Address_gne__c adr = new VDST_Address_gne__c(VDST_Event_gne__c = ev.Id, City_gne__c = 'Lublin');
        insert adr;
        List<VDST_EventPrtcpntRole_gne__c> eprList = new List<VDST_EventPrtcpntRole_gne__c>();
        VDST_EventPrtcpntRole_gne__c epr1 = new VDST_EventPrtcpntRole_gne__c(EventType_gne__c = 'RSCH',
            EventParticipantRoleCode_gne__c = 'PAYEE', EventParticipantRoleName__c = 'Payee');
        eprList.add(epr1);
        VDST_EventPrtcpntRole_gne__c epr2 = new VDST_EventPrtcpntRole_gne__c(EventType_gne__c = 'RSCH',
            EventParticipantRoleCode_gne__c = 'PI', EventParticipantRoleName__c = 'PI');
        eprList.add(epr2);
        VDST_EventPrtcpntRole_gne__c epr3 = new VDST_EventPrtcpntRole_gne__c(EventType_gne__c = 'RSCH',
            EventParticipantRoleCode_gne__c = 'PAYEEPI', EventParticipantRoleName__c = 'Payee-PI');
        eprList.add(epr3);
        insert eprList;
        VDST_EventPrtcpntAccnt_gne__c epa = new VDST_EventPrtcpntAccnt_gne__c(VDST_Event_gne__c = ev.Id,
            PartyType_gne__c = 'INDV', FirstName_gne__c = 'John', LastName_gne__c = 'Wall',
            EventParticipantRole_gne__c = epr1.Id, VDST_Address_gne__c = adr.Id);
        insert epa;
        // Run constructor and methods
        setEventAndTypeParams(ev.Id, null);
        VDST_EventDetailController edc = new VDST_EventDetailController();
        edc.initData();
        Test.startTest();
        // Test method - with Payee user
        VDST_EventDetailPrtcpntUtils.AddPrtcpntBtnsVisibility apbv = edc.prtcpntUtils.getRschPrtcpntBtnVisib();
        System.assertEquals(apbv.showIndv, true);
        System.assertEquals(apbv.showOrg, false);
        // Test method - with Payee and PI user
        VDST_EventPrtcpntAccnt_gne__c epa2 = new VDST_EventPrtcpntAccnt_gne__c(VDST_Event_gne__c = ev.Id,
            PartyType_gne__c = 'INDV', FirstName_gne__c = 'John', LastName_gne__c = 'Wall',
            EventParticipantRole_gne__c = epr2.Id, VDST_Address_gne__c = adr.Id);
        insert epa2;
        apbv = edc.prtcpntUtils.getRschPrtcpntBtnVisib();
        System.assertEquals(apbv.showIndv, false);
        System.assertEquals(apbv.showOrg, false);
        // Test method - with PI user
        delete epa;
        apbv = edc.prtcpntUtils.getRschPrtcpntBtnVisib();
        System.assertEquals(apbv.showIndv, true);
        System.assertEquals(apbv.showOrg, true);
        // Test method - with Payee-PI user
        epa2.EventParticipantRole_gne__c = epr3.Id;
        update epa2;
        apbv = edc.prtcpntUtils.getRschPrtcpntBtnVisib();
        System.assertEquals(apbv.showIndv, false);
        System.assertEquals(apbv.showOrg, false);
        // Test method - with no user
        delete epa2;
        apbv = edc.prtcpntUtils.getRschPrtcpntBtnVisib();
        System.assertEquals(apbv.showIndv, true);
        System.assertEquals(apbv.showOrg, true);
        // Other Event Type
        ev.EventType_gne__c = 'CFF';
        update ev;
        edc = new VDST_EventDetailController();
        edc.initData();
        apbv = edc.prtcpntUtils.getRschPrtcpntBtnVisib();
        System.assertEquals(apbv.showIndv, true);
        System.assertEquals(apbv.showOrg, true);
        Test.stopTest();
    }

    /** @date 2/25/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for addPariticipantAttachment() and backToSelect() methods
    */
    @IsTest(SeeAllData=false)
    static void addPariticipantAttachment_Test() {
        // Prepare test data
        VDST_Event_gne__c ev = prepareEvent('ADBOARD');
        VDST_EventDetailPrtcpntUtils edp = new VDST_EventDetailPrtcpntUtils(ev.Id);
        // Test addParticipantAttachment() pre-data
        System.assertEquals(edp.showPrtcpntModal, false);
        // Run addPariticipantAttachment() method
        Test.startTest();
        edp.addPariticipantAttachment();
        Test.stopTest();
        // Test addParticipantAttachment() post-data
        System.assertEquals(edp.showPrtcpntModal, true); // should show modal window
        System.assert(edp.importValidationStatus.message.startsWith('No file to proceed')); // should throw message that no file is selected to proceed
        System.assertEquals(edp.importValidationStatus.isValid, false); // flag should be set as invalid file to proccess

        // Test backToSelect() method
        edp.backToSelect();
        System.assertEquals(edp.showPrtcpntModal, false); // modal should dissapear
    }

    /** @date 2/25/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for importCSV() method
    */
    @IsTest(SeeAllData=false)
    static void importCSV_Test() {
        // Prepare test data
        insert new List<All_User_Hierarchy_gne__c>{
            new All_User_Hierarchy_gne__c(FirstName_gne__c = 'FN1', LastName_gne__c = 'LN1', User_External_Id_gne__c = 'unixId1'),
            new All_User_Hierarchy_gne__c(FirstName_gne__c = 'FN2', LastName_gne__c = 'LN2', User_External_Id_gne__c = 'unixId2')
        };
        VDST_EventPrtcpntRole_gne__c epr = new VDST_EventPrtcpntRole_gne__c(EventType_gne__c = 'ADBOARD',
            EventParticipantRoleCode_gne__c = 'INTRNL', EventParticipantRoleName__c = 'Genentech Employee');
        insert epr;
        VDST_EventPrtcpntField_gne__c epf = new VDST_EventPrtcpntField_gne__c(VDST_EventPrtcpntRole__c = epr.Id,
            FieldLabel_gne__c = 'Contract Status', FieldName_gne__c = 'ParticipantContractStatus_gne', IsRequired_gne__c = true, IsVisible_gne__c = true);
        insert epf;
        List<VDST_Mapping_gne__c> mapsToInsert = new List<VDST_Mapping_gne__c>();
        VDST_Mapping_gne__c map1 = new VDST_Mapping_gne__c(Name = 'PHYS', LabelValue_gne__c = 'Physician');
        mapsToInsert.add(map1);
        VDST_Mapping_gne__c map2 = new VDST_Mapping_gne__c(Name = 'CA', LabelValue_gne__c = 'California');
        mapsToInsert.add(map2);
        VDST_Mapping_gne__c map3 = new VDST_Mapping_gne__c(Name = 'POL', LabelValue_gne__c = 'Poland');
        mapsToInsert.add(map3);
        insert mapsToInsert;
        VDST_Event_gne__c ev = prepareEvent('ADBOARD'); // Create ADBOARD event
        User u = prepareUser(2);
        Test.startTest();
        // Run tests in user context
        System.runAs(u) {
            // Prepare privileges and controller
            VDST_User_gne__c usr = new VDST_User_gne__c(Role_gne__c = 'Provisioner', User_gne__c = u.Id, VDST_Event_Provider__c = ev.LogisticVendor_gne__c);
            insert usr;
            setEventAndTypeParams(ev.Id, null);
            VDST_EventDetailController edc = new VDST_EventDetailController();
            edc.initData();
            // test importCSV() - invalid data
            edc.prtcpntUtils.importFile = Blob.valueOf('testFile');
            edc.prtcpntUtils.importCSV();
            System.assertEquals(edc.prtcpntUtils.importValidationStatus.isValid, false);
            System.assertEquals(edc.prtcpntUtils.importedWrappedRows.size(), 0);
            // test importCSV() - more than 200 rows
            edc.prtcpntUtils.importFile = Blob.valueOf('1\n2\n3\n4\n5\n6\n7\n8\n9\n0\n1\n2\n3\n4\n5\n6\n7\n8\n9\n0\n1\n2\n3\n4\n5\n6\n7\n8\n9\n0\n1\n2\n3\n4\n5\n6\n7\n8\n9\n0\n1\n2\n3\n4\n5\n6\n7\n8\n9\n0\n1\n2\n3\n4\n5\n6\n7\n8\n9\n0\n1\n2\n3\n4\n5\n6\n7\n8\n9\n0\n1\n2\n3\n4\n5\n6\n7\n8\n9\n0\n1\n2\n3\n4\n5\n6\n7\n8\n9\n0\n1\n2\n3\n4\n5\n6\n7\n8\n9\n0\n1\n2\n3\n4\n5\n6\n7\n8\n9\n0\n1\n2\n3\n4\n5\n6\n7\n8\n9\n0\n1\n2\n3\n4\n5\n6\n7\n8\n9\n0\n1\n2\n3\n4\n5\n6\n7\n8\n9\n0\n1\n2\n3\n4\n5\n6\n7\n8\n9\n0\n1\n2\n3\n4\n5\n6\n7\n8\n9\n0\n1\n2\n3\n4\n5\n6\n7\n8\n9\n0\n1\n2\n3\n4\n5\n6\n7\n8\n9\n0\n1\n2\n3\n4\n5\n6\n7\n8\n9\n0\n1\n2\n3\n4\n5\n6\n7\n8\n9\n0\n1\n2\n3\n4\n5\n6\n7\n8\n9\n0\n');
            edc.prtcpntUtils.importCSV();
            System.assert(edc.prtcpntUtils.importValidationStatus.message.startsWith('File truncated. You can upload up to 200'));
            System.assertEquals(edc.prtcpntUtils.importValidationStatus.isValid, false);
            System.assertEquals(edc.prtcpntUtils.importedWrappedRows.size(), 0);
            // test importCSV() - invalid row
            String fileContent = '';
            fileContent += 'SourceProviderUse,ParticipantID,ParticipantRole,LastName,FirstName,MiddleName,Suffix,BusinessPhone,Email,ParticipantAffiliation,ParticipantProfession,Credential,ContractedStatus,UnixID,NPI,DEA,StateLicenseNumber,LicenseState,ParticipantStreetAddress,ParticipantCity,ParticipantStateProvince,ParticipantPostalCode,ParticipantCountry,HCP_Travel_Amount,HCP_Lodging_Amount,OOP_Travel_Amount,OOP_Lodging_Amount,OOP_Meals_Amount,OOP_OtherAmount,HCP_Fees_Amount,Day1AttendanceStatus,Day2AttendanceStatus,Day3AttendanceStatus,Day4AttendanceStatus,Day5AttendanceStatus,Day1ConsumptionStatus,Day2ConsumptionStatus,Day3ConsumptionStatus,Day4ConsumptionStatus,Day5ConsumptionStatus\n';
            fileContent += ',abc,Genentech Employee,De Jong,John,,,212-333-4444,,Genentech,Physician,MD,Not Contracted,someid,1234567891,,,,1 DNA Way,South San Francisco,California,94 108-asdS,Poland,,,,,,,,Attended,Attended,Did Not Show,Attended,,Consumed,Consumed,Consumed,Consumed,\n';
            fileContent += 'GNE_13875933132833183,Genentech Employee,Smith,Theo,,,212-333-4444,,Genentech,Physician,MD,Not Contracted,smitht,1234567891,,,,1 DNA Way,South San Francisco,California,94 108-asdS,Poland,,,,,,,,Attended,Attended,Did Not Show,Attended,,Consumed,Consumed,Consumed,Consumed,\n'; //Invalid record
            edc.prtcpntUtils.importFile = Blob.valueOf(fileContent);
            edc.prtcpntUtils.importCSV();
            System.assert(edc.prtcpntUtils.importValidationStatus.message.contains('Correct number of columns is'));
            System.assertEquals(edc.prtcpntUtils.importValidationStatus.isValid, false);
            // test importCSV() - invalid unix Id fields (not existing value)
            fileContent = '';
            fileContent += 'SourceProviderUse,ParticipantID,ParticipantRole,LastName,FirstName,MiddleName,Suffix,BusinessPhone,Email,ParticipantAffiliation,ParticipantProfession,Credential,ContractedStatus,UnixID,NPI,DEA,StateLicenseNumber,LicenseState,ParticipantStreetAddress,ParticipantCity,ParticipantStateProvince,ParticipantPostalCode,ParticipantCountry,HCP_Travel_Amount,HCP_Lodging_Amount,OOP_Travel_Amount,OOP_Lodging_Amount,OOP_Meals_Amount,OOP_OtherAmount,HCP_Fees_Amount,Day1AttendanceStatus,Day2AttendanceStatus,Day3AttendanceStatus,Day4AttendanceStatus,Day5AttendanceStatus,Day1ConsumptionStatus,Day2ConsumptionStatus,Day3ConsumptionStatus,Day4ConsumptionStatus,Day5ConsumptionStatus\n';
            fileContent += ',abc,Genentech Employee,De Jong,John,,,212-333-4444,,Genentech,Physician,MD,Not Contracted,invalidid,1234567891,,,,1 DNA Way,South San Francisco,California,94 108-asdS,Poland,,,,,,,,Attended,Attended,Did Not Show,Attended,,Consumed,Consumed,Consumed,Consumed,\n';
            fileContent += ',GNE_13875933132833183,Genentech Employee,Smith,Theo,,,212-333-4444,,Genentech,Physician,MD,Not Contracted,invalidid,1234567891,,,,1 DNA Way,South San Francisco,California,94 108-asdS,Poland,,,,,,,,Attended,Attended,Did Not Show,Attended,,Consumed,Consumed,Consumed,Consumed,\n'; //Invalid record
            edc.prtcpntUtils.importFile = Blob.valueOf(fileContent);
            edc.prtcpntUtils.importCSV();
            System.assertEquals(edc.prtcpntUtils.importValidationStatus.isValid, false);
            System.assert(edc.prtcpntUtils.importValidationStatus.message.startsWith('Some of the records are not valid.'));
            System.assertEquals(edc.prtcpntUtils.importedWrappedRows.get(0).isValidRecord, false);
            System.assertNotEquals(edc.prtcpntUtils.importedWrappedRows.get(0).errorMsgList[13], null);
            System.assertNotEquals(edc.prtcpntUtils.importedWrappedRows.get(0).errorMsgList[13], '');
            System.assertEquals(edc.prtcpntUtils.importedWrappedRows.size(), 2);
            System.assertEquals(edc.prtcpntUtils.importedWrappedRows.get(0).evntPrtcpnt.FirstName_gne__c, 'John');
            System.assertEquals(edc.prtcpntUtils.importedWrappedRows.get(0).evntPrtcpnt.VendorParticipantID_gne__c, 'GNE_ABC');
            // test importCSV() - invalid profession
            fileContent = '';
            fileContent += 'SourceProviderUse,ParticipantID,ParticipantRole,LastName,FirstName,MiddleName,Suffix,BusinessPhone,Email,ParticipantAffiliation,ParticipantProfession,Credential,ContractedStatus,UnixID,NPI,DEA,StateLicenseNumber,LicenseState,ParticipantStreetAddress,ParticipantCity,ParticipantStateProvince,ParticipantPostalCode,ParticipantCountry,HCP_Travel_Amount,HCP_Lodging_Amount,OOP_Travel_Amount,OOP_Lodging_Amount,OOP_Meals_Amount,OOP_OtherAmount,HCP_Fees_Amount,Day1AttendanceStatus,Day2AttendanceStatus,Day3AttendanceStatus,Day4AttendanceStatus,Day5AttendanceStatus,Day1ConsumptionStatus,Day2ConsumptionStatus,Day3ConsumptionStatus,Day4ConsumptionStatus,Day5ConsumptionStatus\n';
            fileContent += ',abc,Genentech Employee,De Jong,John,,,212-333-4444,,Genentech,InvalidPhysician,MD,Not Contracted,invalidid,1234567891,,,,1 DNA Way,South San Francisco,California,94 108-asdS,Poland,,,,,,,,Attended,Attended,Did Not Show,Attended,,Consumed,Consumed,Consumed,Consumed,\n';
            fileContent += ',GNE_13875933132833183,Genentech Employee,Smith,Theo,,,212-333-4444,,Genentech,InvalidPhysician,MD,Not Contracted,invalidid,1234567891,,,,1 DNA Way,South San Francisco,California,94 108-asdS,Poland,,,,,,,,Attended,Attended,Did Not Show,Attended,,Consumed,Consumed,Consumed,Consumed,\n'; //Invalid record
            edc.prtcpntUtils.importFile = Blob.valueOf(fileContent);
            edc.prtcpntUtils.importCSV();
            System.assertEquals(edc.prtcpntUtils.importValidationStatus.isValid, false);
            System.assertEquals(edc.prtcpntUtils.importedWrappedRows.size(), 2);
            System.assertEquals(edc.prtcpntUtils.importedWrappedRows.get(0).errorMsgList[10], 'Participant Profession field is required');
            // test importCSV() - invalid profession
            fileContent = '';
            fileContent += 'SourceProviderUse,ParticipantID,ParticipantRole,LastName,FirstName,MiddleName,Suffix,BusinessPhone,Email,ParticipantAffiliation,ParticipantProfession,Credential,ContractedStatus,UnixID,NPI,DEA,StateLicenseNumber,LicenseState,ParticipantStreetAddress,ParticipantCity,ParticipantStateProvince,ParticipantPostalCode,ParticipantCountry,HCP_Travel_Amount,HCP_Lodging_Amount,OOP_Travel_Amount,OOP_Lodging_Amount,OOP_Meals_Amount,OOP_OtherAmount,HCP_Fees_Amount,Day1AttendanceStatus,Day2AttendanceStatus,Day3AttendanceStatus,Day4AttendanceStatus,Day5AttendanceStatus,Day1ConsumptionStatus,Day2ConsumptionStatus,Day3ConsumptionStatus,Day4ConsumptionStatus,Day5ConsumptionStatus\n';
            fileContent += ',,Genentech Employee,De Jong,John,,,212-333-4444,,Genentech,Physician,MD,Not Contracted,invalidid,1234567891,,,,1 DNA Way,South San Francisco,California,94 108-asdS,Poland,,,,,,,,Attended,Attended,Did Not Show,Attended,,Consumed,Consumed,Consumed,Consumed,\n';
            fileContent += ',GNE_13875933132833183,Genentech Employee,Smith,Theo,,,212-333-4444,,Genentech,Physician,MD,Not Contracted,invalidid,1234567891,,,,1 DNA Way,South San Francisco,California,94 108-asdS,Poland,,,,,,,,Attended,Attended,Did Not Show,Attended,,Consumed,Consumed,Consumed,Consumed,\n'; //Invalid record
            edc.prtcpntUtils.importFile = Blob.valueOf(fileContent);
            edc.prtcpntUtils.importCSV();
            System.assertEquals(edc.prtcpntUtils.importValidationStatus.isValid, false);
            System.assertEquals(edc.prtcpntUtils.importedWrappedRows.size(), 2);
            System.assertEquals(edc.prtcpntUtils.importedWrappedRows.get(0).errorMsgList[1], 'Vendor Participant Id field is required');
            System.assert(!edc.prtcpntUtils.importValidationStatus.message.contains('The following Participants do not appear'));
            // set to edit
            edc.prtcpntUtils.wrapperEditId = 1; // first row
            edc.prtcpntUtils.setWrapperToEdit();
            System.assertEquals(edc.prtcpntUtils.wrapperToEdit.evntPrtcpnt.FirstName_gne__c, 'John');
            // save edited record
            edc.prtcpntUtils.wrapperToEdit.evntPrtcpnt.UnixID_gne__c = 'wrongUnixId';
            edc.prtcpntUtils.savePrtcpnt();
            System.assertEquals(edc.prtcpntUtils.importValidationStatus.isValid, false);
            System.assertEquals(edc.prtcpntUtils.prtcpntListMsg, 'Participant list has been imported.');
            // prepare data - correct
            List<VDST_EventPrtcpntAccnt_gne__c> epaList = new List<VDST_EventPrtcpntAccnt_gne__c>();
            VDST_EventPrtcpntAccnt_gne__c epa1 = new VDST_EventPrtcpntAccnt_gne__c(VDST_Event_gne__c = ev.Id,
                PartyType_gne__c = 'INDV', FirstName_gne__c = 'John', LastName_gne__c = 'Wall', VendorParticipantID_gne__c = 'GNE_123notused',
                EventParticipantRole_gne__c = epr.Id);
            epaList.add(epa1);
            VDST_EventPrtcpntAccnt_gne__c epa2 = new VDST_EventPrtcpntAccnt_gne__c(VDST_Event_gne__c = ev.Id,
                PartyType_gne__c = 'INDV', FirstName_gne__c = 'Marcin', LastName_gne__c = 'Gortat', VendorParticipantID_gne__c = 'GNE_abc',
                EventParticipantRole_gne__c = epr.Id);
            epaList.add(epa2);
            insert epaList;
            // test importCSV() - correct record
            fileContent = '';
            fileContent += 'SourceProviderUse,ParticipantID,ParticipantRole,LastName,FirstName,MiddleName,Suffix,BusinessPhone,Email,ParticipantAffiliation,ParticipantProfession,Credential,ContractedStatus,UnixID,NPI,DEA,StateLicenseNumber,LicenseState,ParticipantStreetAddress,ParticipantCity,ParticipantStateProvince,ParticipantPostalCode,ParticipantCountry,HCP_Travel_Amount,HCP_Lodging_Amount,OOP_Travel_Amount,OOP_Lodging_Amount,OOP_Meals_Amount,OOP_OtherAmount,HCP_Fees_Amount,Day1AttendanceStatus,Day2AttendanceStatus,Day3AttendanceStatus,Day4AttendanceStatus,Day5AttendanceStatus,Day1ConsumptionStatus,Day2ConsumptionStatus,Day3ConsumptionStatus,Day4ConsumptionStatus,Day5ConsumptionStatus\n';
            fileContent += ',abc,Genentech Employee,De Jong,John,,,212-333-4444,,Genentech,Physician,MD,Not Contracted,unixId1,1234567891,,,,1 DNA Way,South San Francisco,California,94 108-asdS,Poland,,,,,,,,Attended,Attended,Did Not Show,Attended,,Consumed,Consumed,Consumed,Consumed,\n';
            fileContent += ',GNE_13875933132833183,Genentech Employee,Smith,Theo,,,212-333-4444,,Genentech,Physician,MD,Not Contracted,unixId2,1234567891,,,,1 DNA Way,South San Francisco,California,94 108-asdS,Poland,,,,,,,,Attended,Attended,Did Not Show,Attended,,Consumed,Consumed,Consumed,Consumed,\n'; //Invalid record
            edc.prtcpntUtils.importFile = Blob.valueOf(fileContent);
            edc.prtcpntUtils.importCSV();
            System.assertEquals(edc.prtcpntUtils.importValidationStatus.isValid, true);
            System.assertEquals(edc.prtcpntUtils.importedWrappedRows.size(), 2);
            System.assertEquals(edc.prtcpntUtils.importedWrappedRows.get(0).evntPrtcpnt.FirstName_gne__c, 'John');
            System.assertEquals(edc.prtcpntUtils.importedWrappedRows.get(0).evntPrtcpnt.VendorParticipantID_gne__c, 'GNE_ABC');
            System.assert(edc.prtcpntUtils.importValidationStatus.message.contains('The following Participants do not appear'));
            System.assert(edc.prtcpntUtils.importValidationStatus.message.contains('Wall'));
            System.assert(!edc.prtcpntUtils.importValidationStatus.message.contains('Gortat'));
        }
        Test.stopTest();
    }

    /** @date 2/25/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for saveRecords() and clearUnusedFields() methods
    */
    @IsTest(SeeAllData=false)
    static void saveRecords_Test() {
        // Prepare test data
        insert new List<All_User_Hierarchy_gne__c>{
            new All_User_Hierarchy_gne__c(FirstName_gne__c = 'FN1', LastName_gne__c = 'LN1', User_External_Id_gne__c = 'unixId1'),
            new All_User_Hierarchy_gne__c(FirstName_gne__c = 'FN2', LastName_gne__c = 'LN2', User_External_Id_gne__c = 'unixId2')
        };
        List<VDST_EventPrtcpntRole_gne__c> eprList = new List<VDST_EventPrtcpntRole_gne__c>();
        VDST_EventPrtcpntRole_gne__c epr1 = new VDST_EventPrtcpntRole_gne__c(EventType_gne__c = 'ADBOARD',
            EventParticipantRoleCode_gne__c = 'INTRNL', EventParticipantRoleName__c = 'Genentech Employee');
        eprList.add(epr1);
        VDST_EventPrtcpntRole_gne__c epr2 = new VDST_EventPrtcpntRole_gne__c(EventType_gne__c = 'ADBOARD',
            EventParticipantRoleCode_gne__c = 'ATTND', EventParticipantRoleName__c = 'Attendee');
        eprList.add(epr2);
        insert eprList;
        List<VDST_EventPrtcpntField_gne__c> prtcpntFieldsToInsert = new List<VDST_EventPrtcpntField_gne__c>();
        VDST_EventPrtcpntField_gne__c epf1 = new VDST_EventPrtcpntField_gne__c(VDST_EventPrtcpntRole__c = epr1.Id,
            FieldLabel_gne__c = 'Item Name', FieldName_gne__c = 'ItemName_gne', IsRequired_gne__c = true, IsVisible_gne__c = true);
        prtcpntFieldsToInsert.add(epf1);
        VDST_EventPrtcpntField_gne__c epf2 = new VDST_EventPrtcpntField_gne__c(VDST_EventPrtcpntRole__c = epr1.Id,
            FieldLabel_gne__c = 'DEA', FieldName_gne__c = 'Dea_gne', IsRequired_gne__c = true, IsVisible_gne__c = true);
        prtcpntFieldsToInsert.add(epf2);
        VDST_EventPrtcpntField_gne__c epf3 = new VDST_EventPrtcpntField_gne__c(VDST_EventPrtcpntRole__c = epr1.Id,
            FieldLabel_gne__c = 'hasFees', FieldName_gne__c = 'hasFees', IsRequired_gne__c = true, IsVisible_gne__c = true);
        prtcpntFieldsToInsert.add(epf3);
        VDST_EventPrtcpntField_gne__c epf4 = new VDST_EventPrtcpntField_gne__c(VDST_EventPrtcpntRole__c = epr2.Id,
            FieldLabel_gne__c = 'DEA', FieldName_gne__c = 'Dea_gne', IsRequired_gne__c = false, IsVisible_gne__c = false);
        prtcpntFieldsToInsert.add(epf4);
        VDST_EventPrtcpntField_gne__c epf5 = new VDST_EventPrtcpntField_gne__c(VDST_EventPrtcpntRole__c = epr2.Id,
            FieldLabel_gne__c = 'NPI', FieldName_gne__c = 'NPI_gne', IsRequired_gne__c = false, IsVisible_gne__c = false);
        prtcpntFieldsToInsert.add(epf5);
        VDST_EventPrtcpntField_gne__c epf6 = new VDST_EventPrtcpntField_gne__c(VDST_EventPrtcpntRole__c = epr2.Id,
            FieldLabel_gne__c = 'Unix Id', FieldName_gne__c = 'UnixID_gne', IsRequired_gne__c = false, IsVisible_gne__c = false);
        prtcpntFieldsToInsert.add(epf6);
        VDST_EventPrtcpntField_gne__c epf7 = new VDST_EventPrtcpntField_gne__c(VDST_EventPrtcpntRole__c = epr1.Id,
            FieldLabel_gne__c = 'Contract Status', FieldName_gne__c = 'ParticipantContractStatus_gne', IsRequired_gne__c = true, IsVisible_gne__c = true);
        prtcpntFieldsToInsert.add(epf7);
        VDST_EventPrtcpntField_gne__c epf8 = new VDST_EventPrtcpntField_gne__c(VDST_EventPrtcpntRole__c = epr2.Id,
            FieldLabel_gne__c = 'Contract Status', FieldName_gne__c = 'ParticipantContractStatus_gne', IsRequired_gne__c = true, IsVisible_gne__c = true);
        prtcpntFieldsToInsert.add(epf8);
        insert prtcpntFieldsToInsert;
        List<VDST_Mapping_gne__c> mapsToInsert = new List<VDST_Mapping_gne__c>();
        VDST_Mapping_gne__c map1 = new VDST_Mapping_gne__c(Name = 'PHYS', LabelValue_gne__c = 'Physician');
        mapsToInsert.add(map1);
        VDST_Mapping_gne__c map2 = new VDST_Mapping_gne__c(Name = 'CA', LabelValue_gne__c = 'California');
        mapsToInsert.add(map2);
        VDST_Mapping_gne__c map3 = new VDST_Mapping_gne__c(Name = 'POL', LabelValue_gne__c = 'Poland');
        mapsToInsert.add(map3);
        insert mapsToInsert;
        VDST_Event_gne__c ev = prepareEvent('ADBOARD');
        User u = prepareUser(2);
        // Run tests in user context
        System.runAs(u) {
            // Prepare privileges and controller
            VDST_User_gne__c usr = new VDST_User_gne__c(Role_gne__c = 'Provisioner', User_gne__c = u.Id, VDST_Event_Provider__c = ev.LogisticVendor_gne__c);
            insert usr;
            setEventAndTypeParams(ev.Id, null);
            VDST_EventDetailController edc = new VDST_EventDetailController();
            edc.initData();
            // Prepare data - correct
            VDST_Address_gne__c adr = new VDST_Address_gne__c(VDST_Event_gne__c = ev.Id, City_gne__c = 'Lublin');
            insert adr;
            List<VDST_EventPrtcpntAccnt_gne__c> epaList = new List<VDST_EventPrtcpntAccnt_gne__c>();
            VDST_EventPrtcpntAccnt_gne__c epa1 = new VDST_EventPrtcpntAccnt_gne__c(VDST_Event_gne__c = ev.Id,
                PartyType_gne__c = 'INDV', FirstName_gne__c = 'John', LastName_gne__c = 'Wall', VendorParticipantID_gne__c = '123notused',
                EventParticipantRole_gne__c = epr2.Id, UnixId_gne__c = 'unixId', VDST_Address_gne__c = adr.Id);
            epaList.add(epa1);
            VDST_EventPrtcpntAccnt_gne__c epa2 = new VDST_EventPrtcpntAccnt_gne__c(VDST_Event_gne__c = ev.Id,
                PartyType_gne__c = 'INDV', FirstName_gne__c = 'Marcin', LastName_gne__c = 'Gortat', VendorParticipantID_gne__c = 'GNE_abc',
                EventParticipantRole_gne__c = epr1.Id, UnixId_gne__c = 'unixId', VDST_Address_gne__c = adr.Id);
            epaList.add(epa2);
            insert epaList;
            // Test importCSV() - correct record
            String fileContent = '';
            fileContent += 'SourceProviderUse,ParticipantID,ParticipantRole,LastName,FirstName,MiddleName,Suffix,BusinessPhone,Email,ParticipantAffiliation,ParticipantProfession,Credential,ContractedStatus,UnixID,NPI,DEA,StateLicenseNumber,LicenseState,ParticipantStreetAddress,ParticipantCity,ParticipantStateProvince,ParticipantPostalCode,ParticipantCountry,HCP_Travel_Amount,HCP_Lodging_Amount,OOP_Travel_Amount,OOP_Lodging_Amount,OOP_Meals_Amount,OOP_OtherAmount,HCP_Fees_Amount,Day1AttendanceStatus,Day2AttendanceStatus,Day3AttendanceStatus,Day4AttendanceStatus,Day5AttendanceStatus,Day1ConsumptionStatus,Day2ConsumptionStatus,Day3ConsumptionStatus,Day4ConsumptionStatus,Day5ConsumptionStatus\n';
            fileContent += ',abc,Genentech Employee,De Jong,John,,,212-333-4444,,Genentech,Physician,MD,Not Contracted,unixId1,1234567891,CA1234432,,,1 DNA Way,South San Francisco,California,94 108-asdS,Poland,22,,,,,,,Attended,Attended,Did Not Show,Attended,,Consumed,Consumed,Consumed,Consumed,\n';
            fileContent += ',GNE_13875933132833183,Attendee,Smith,Theo,,,212-333-4444,,Genentech,Physician,MD,Not Contracted,unixId2,1234567891,CA1234432,,,1 DNA Way,South San Francisco,California,94 108-asdS,Poland,22,,,,,,,Did Not Show,Attended,Did Not Show,Attended,,Consumed,Consumed,Consumed,Consumed,\n'; //Invalid record
            edc.prtcpntUtils.importFile = Blob.valueOf(fileContent);
            edc.prtcpntUtils.importCSV();
            System.assertEquals(edc.prtcpntUtils.importValidationStatus.isValid, true);
            System.assertEquals(edc.prtcpntUtils.importedWrappedRows.size(), 2);
            System.assertEquals(edc.prtcpntUtils.importedWrappedRows.get(0).evntPrtcpnt.FirstName_gne__c, 'John');
            System.assertEquals(edc.prtcpntUtils.importedWrappedRows.get(0).evntPrtcpnt.VendorParticipantID_gne__c, 'GNE_ABC');
            System.assert(edc.prtcpntUtils.importValidationStatus.message.contains('The following Participants do not appear'));
            System.assert(edc.prtcpntUtils.importValidationStatus.message.contains('Wall'));
            System.assert(!edc.prtcpntUtils.importValidationStatus.message.contains('Gortat'));
            // Test setting transaction values
            for(VDST_PrtcpntTransaction_gne__c pt : edc.prtcpntUtils.importedWrappedRows.get(0).getPrtcpntTransactionList()) {
                if(pt.TransactionTypeCode_gne__c.equals('HCPTRVL')) {
                    System.assertEquals(pt.TransactionAmount_gne__c, 22);
                }
            }
            Test.startTest(); // Runned at this point to avoid SFDC Limits in test
            // Prepare data and start saveRecords()
            edc.prtcpntUtils.showPrtcpntModal = true;
            edc.prtcpntUtils.importedWrappedRows.get(1).evntPrtcpnt.VendorParticipantID_gne__c = '13875933132833183';
            edc.prtcpntUtils.saveRecords();
            // Test setting values
            System.assertEquals(edc.prtcpntUtils.showPrtcpntModal, false);
            System.assertEquals(edc.prtcpntUtils.importValidationStatus.isValid, true);
            // Test adding group prefix, upsert, clearing unused fields
            List<VDST_EventPrtcpntAccnt_gne__c> accList = [SELECT Id, EventParticipantRole_gne__c, LastName_gne__c, NPI_gne__c, DEA_gne__c, UnixId_gne__c, VendorParticipantID_gne__c FROM VDST_EventPrtcpntAccnt_gne__c WHERE VDST_Event_gne__c = :ev.Id];
            System.assertEquals(accList.size(), 3);
            Integer totalCheck = 0;
            for(VDST_EventPrtcpntAccnt_gne__c acc : accList) {
                if(acc.LastName_gne__c.equals('De Jong')) { // Gortat - should not clear values, because it's role with no clearing Participant Fields
                    System.assert(acc.VendorParticipantID_gne__c.contains('GNE'));
                    System.assertNotEquals(acc.NPI_gne__c, null);
                    System.assertNotEquals(acc.DEA_gne__c, null);
                    System.assertNotEquals(acc.UnixId_gne__c, null);
                    totalCheck++;
                } else if(acc.LastName_gne__c.equals('Wall')) { // should clear values, because it's role with clearing Participant Fields
                    System.assertEquals(acc.NPI_gne__c, null);
                    System.assertEquals(acc.DEA_gne__c, null);
                    System.assertNotEquals(acc.UnixId_gne__c, null); // Because it's filled before loading CSV file
                    totalCheck++;
                } else if(acc.LastName_gne__c.equals('Smith')) { // should clear values, because it's role with clearing Participant Fields
                    System.assertEquals(acc.VendorParticipantID_gne__c, 'GNE_13875933132833183');
                    totalCheck++;
                }
            }
            System.assertEquals(totalCheck, 3); // should check 3 participants
            // Test fixing and updating address
            VDST_Address_gne__c adrObj = [SELECT PostalCode_gne__c FROM VDST_Address_gne__c WHERE Id = :adr.Id];
            System.assertNotEquals(adrObj.PostalCode_gne__c, '94 108-asdS');
            System.assertEquals(adrObj.PostalCode_gne__c, '94 108-ASDS'); // check address update
            // Test setting attandence values
            List<VDST_EventPrtcpntAttendance_gne__c> attList = [SELECT Id, AttendanceStatus_gne__c, Event_PrtcpntAccnt_gne__r.VendorParticipantID_gne__c FROM VDST_EventPrtcpntAttendance_gne__c WHERE Event_PrtcpntAccnt_gne__r.LastName_gne__c = 'Smith'];
            System.assertEquals(attList.size(), 1);
            System.assertEquals(attList.get(0).AttendanceStatus_gne__c, 'DNS');
            Test.stopTest();
        }
    }

    /** @date 3/5/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for validateBatchVendorIds() method
    */
    @IsTest(SeeAllData=false)
    static void validateBatchVendorIds_Test() {
        // Prepare test data
        List<VDST_EventPrtcpntRole_gne__c> eprList = new List<VDST_EventPrtcpntRole_gne__c>();
        VDST_EventPrtcpntRole_gne__c epr1 = new VDST_EventPrtcpntRole_gne__c(EventType_gne__c = 'ADBOARD',
            EventParticipantRoleCode_gne__c = 'INTRNL', EventParticipantRoleName__c = 'Genentech Employee');
        eprList.add(epr1);
        User u = prepareUser(2);
        VDST_Event_gne__c ev = prepareEvent('ADBOARD');
        VDST_Event_gne__c otherEv = new VDST_Event_gne__c(CurrentStatus_gne__c = 'PENDING',
            CurrentStatusDate_gne__c = Date.today(), EventType_gne__c = 'CFF', LogisticVendor_gne__c = ev.LogisticVendor_gne__c,
            EventStartDate_gne__c = Date.today().addDays(-2), EventEndDate_gne__c = Date.today().addDays(-2));
        insert otherEv;
        // Run tests in user context
        System.runAs(u) {
            // Prepare privileges and controller
            VDST_User_gne__c usr = new VDST_User_gne__c(Role_gne__c = 'Provisioner', User_gne__c = u.Id, VDST_Event_Provider__c = ev.LogisticVendor_gne__c);
            insert usr;
            setEventAndTypeParams(ev.Id, null);
            VDST_EventDetailController edc = new VDST_EventDetailController();
            edc.initData();
            // Prepare data - correct
            List<VDST_EventPrtcpntAccnt_gne__c> epaList = new List<VDST_EventPrtcpntAccnt_gne__c>();
            VDST_EventPrtcpntAccnt_gne__c epa1 = new VDST_EventPrtcpntAccnt_gne__c(VDST_Event_gne__c = otherEv.Id,
                PartyType_gne__c = 'INDV', FirstName_gne__c = 'John', LastName_gne__c = 'Wall',
                VendorParticipantID_gne__c = '123NOTUSED', EventParticipantRole_gne__c = epr1.Id, UnixId_gne__c = 'unixId');
            epaList.add(epa1);
            VDST_EventPrtcpntAccnt_gne__c epa2 = new VDST_EventPrtcpntAccnt_gne__c(VDST_Event_gne__c = otherEv.Id,
                PartyType_gne__c = 'INDV', FirstName_gne__c = 'Marcin', LastName_gne__c = 'Gortat',
                VendorParticipantID_gne__c = 'ABC', EventParticipantRole_gne__c = epr1.Id, UnixId_gne__c = 'unixId');
            epaList.add(epa2);
            insert epaList;
            // Prepare wrappers
            VDST_EventDetailPrtcpntUtils.PrtcpntWrapper edp1 = new VDST_EventDetailPrtcpntUtils.PrtcpntWrapper(edc.prtcpntUtils);
            edp1.evntPrtcpnt.VendorParticipantID_gne__c = 'abc';
            edc.prtcpntUtils.importedWrappedRows.add(edp1);
            VDST_EventDetailPrtcpntUtils.PrtcpntWrapper edp2 = new VDST_EventDetailPrtcpntUtils.PrtcpntWrapper(edc.prtcpntUtils);
            edp2.evntPrtcpnt.VendorParticipantID_gne__c = 'uniqueId';
            edc.prtcpntUtils.importedWrappedRows.add(edp2);
            VDST_EventDetailPrtcpntUtils.PrtcpntWrapper edp3 = new VDST_EventDetailPrtcpntUtils.PrtcpntWrapper(edc.prtcpntUtils);
            edp3.evntPrtcpnt.VendorParticipantID_gne__c = 'origId';
            edc.prtcpntUtils.importedWrappedRows.add(edp3);
            VDST_EventDetailPrtcpntUtils.PrtcpntWrapper edp4 = new VDST_EventDetailPrtcpntUtils.PrtcpntWrapper(edc.prtcpntUtils);
            edp4.evntPrtcpnt.VendorParticipantID_gne__c = 'GNE_origId';
            edc.prtcpntUtils.importedWrappedRows.add(edp4);
            VDST_EventDetailPrtcpntUtils.PrtcpntWrapper edp5 = new VDST_EventDetailPrtcpntUtils.PrtcpntWrapper(edc.prtcpntUtils);
            edp5.evntPrtcpnt.VendorParticipantID_gne__c = '';
            edc.prtcpntUtils.importedWrappedRows.add(edp5);
            Test.startTest();
            // Run validateBatchVendorIds() method
            edc.prtcpntUtils.validateBatchVendorIds();
            // Test post-data
            Integer howMany = 0;
            for(VDST_EventDetailPrtcpntUtils.PrtcpntWrapper pw : edc.prtcpntUtils.importedWrappedRows) {
                if('GNE_UNIQUEID'.equals(pw.evntPrtcpnt.VendorParticipantID_gne__c)) {
                    System.assertEquals(pw.errorMsgList[1], '');
                    System.assertEquals(pw.isValidRecord, true);
                    howMany++;
                } else if(''.equals(pw.evntPrtcpnt.VendorParticipantID_gne__c)) {
                    System.assertEquals(pw.errorMsgList[1], 'Vendor Participant Id field is required');
                    System.assertEquals(pw.isValidRecord, false);
                    howMany++;
                } else if('GNE_ORIGID'.equals(pw.evntPrtcpnt.VendorParticipantID_gne__c)) {
                    System.assertEquals(pw.errorMsgList[1], 'Vendor Participant Id must be unique');
                    System.assertEquals(pw.isValidRecord, false);
                    howMany++;
                } else if('GNE_ABC'.equals(pw.evntPrtcpnt.VendorParticipantID_gne__c)) {
                    System.assertEquals(pw.errorMsgList[1], 'Vendor Participant Id must be unique');
                    System.assertEquals(pw.isValidRecord, false);
                    howMany++;
                }
            }
            System.assertEquals(howMany, 5);
            Test.stopTest();
        }
    }

    /** @date 2/28/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for validateWrapperValues() method
    */
    @IsTest(SeeAllData=false)
    static void validateWrapperValues_Test() {
        // Prepare test data
        List<VDST_Mapping_gne__c> mapsToInsert = new List<VDST_Mapping_gne__c>();
        VDST_Mapping_gne__c map1 = new VDST_Mapping_gne__c(Name = 'PHYS', LabelValue_gne__c = 'Physician');
        mapsToInsert.add(map1);
        VDST_Mapping_gne__c map2 = new VDST_Mapping_gne__c(Name = 'CA', LabelValue_gne__c = 'California');
        mapsToInsert.add(map2);
        VDST_Mapping_gne__c map3 = new VDST_Mapping_gne__c(Name = 'POL', LabelValue_gne__c = 'Poland');
        mapsToInsert.add(map3);
        VDST_Mapping_gne__c map4 = new VDST_Mapping_gne__c(Name = 'JR', LabelValue_gne__c = 'Jr');
        mapsToInsert.add(map4);
        insert mapsToInsert;
        VDST_Event_gne__c ev = prepareEvent('ADBOARD');
        setEventAndTypeParams(ev.Id, null);
        VDST_EventDetailController edc = new VDST_EventDetailController();
        edc.initData();
        // Test setting new values
        VDST_EventDetailPrtcpntUtils.PrtcpntWrapper wrap = new VDST_EventDetailPrtcpntUtils.PrtcpntWrapper(edc.prtcpntUtils);
        wrap.evntPrtcpnt.ParticipantProfession_gne__c = 'thisShouldBeRemoved';
        wrap.evntPrtcpnt.Credential_gne__c = 'thisShouldBeRemoved';
        wrap.evntPrtcpnt.ParticipantContractStatus_gne__c = 'CNTRCTD';
        wrap.evntPrtcpnt.LicenseState_gne__c = 'thisShouldBeRemoved';
        wrap.evntPrtcpnt.Suffix_gne__c = 'thisShouldBeRemoved';
        wrap.evntPrtcpntAddress.Country_gne__c = 'thisShouldBechangedToUSA';
        wrap.evntPrtcpntAddress.StateProvince_gne__c = 'thisShouldBeRemoved';
        edc.prtcpntUtils.validateWrapperValues(wrap);
        System.assertEquals(wrap.evntPrtcpnt.ParticipantProfession_gne__c, '');
        System.assertEquals(wrap.evntPrtcpnt.Credential_gne__c, '');
        System.assertEquals(wrap.evntPrtcpnt.ParticipantContractStatus_gne__c, 'CNTRCTD');
        System.assertEquals(wrap.evntPrtcpnt.LicenseState_gne__c, '');
        System.assertEquals(wrap.evntPrtcpnt.Suffix_gne__c, '');
        System.assertEquals(wrap.evntPrtcpntAddress.Country_gne__c, 'USA');
        System.assertEquals(wrap.evntPrtcpntAddress.StateProvince_gne__c, '');
        // Test leaving old values
        wrap = new VDST_EventDetailPrtcpntUtils.PrtcpntWrapper(edc.prtcpntUtils);
        wrap.evntPrtcpnt.ParticipantProfession_gne__c = 'PHYS';
        wrap.evntPrtcpnt.Credential_gne__c = 'FRCP';
        wrap.evntPrtcpnt.ParticipantContractStatus_gne__c = 'CNTRCTD';
        wrap.evntPrtcpnt.LicenseState_gne__c = 'CA';
        wrap.evntPrtcpnt.Suffix_gne__c = 'JR';
        wrap.evntPrtcpntAddress.Country_gne__c = 'POL';
        wrap.evntPrtcpntAddress.StateProvince_gne__c = 'XXX';
        edc.prtcpntUtils.validateWrapperValues(wrap);
        System.assertEquals(wrap.evntPrtcpnt.ParticipantProfession_gne__c, 'PHYS');
        System.assertEquals(wrap.evntPrtcpnt.Credential_gne__c, 'FRCP');
        System.assertEquals(wrap.evntPrtcpnt.ParticipantContractStatus_gne__c, 'CNTRCTD');
        System.assertEquals(wrap.evntPrtcpnt.LicenseState_gne__c, 'CA');
        System.assertEquals(wrap.evntPrtcpnt.Suffix_gne__c, 'JR');
        System.assertEquals(wrap.evntPrtcpntAddress.Country_gne__c, 'POL');
        System.assertEquals(wrap.evntPrtcpntAddress.StateProvince_gne__c, 'XXX');
    }

    /** @date 2/28/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for getRowValues() method
    */
    @IsTest(SeeAllData=false)
    static void getRowValues_Test() {
        // Prepare test data
        VDST_Event_gne__c ev = prepareEvent('ADBOARD');
        setEventAndTypeParams(ev.Id, null);
        VDST_EventDetailController edc = new VDST_EventDetailController();
        edc.initData();
        // Test setting new values
        // Blank value
        List<String> returnValue = edc.prtcpntUtils.getRowValues('');
        System.assertEquals(returnValue.size(), 0);
        // Using " in line
        returnValue = edc.prtcpntUtils.getRowValues('a,b,c,"a,b,c",d,"only value"');
        System.assertEquals(returnValue.size(), 6);
        System.assertEquals(returnValue.get(3), 'a,b,c');
        System.assertEquals(returnValue.get(4), 'd');
        System.assertEquals(returnValue.get(5), 'only value');
    }

    /** @date 2/28/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for participantList getter
    */
    @IsTest(SeeAllData=false)
    static void participantList_Test() {
        // Prepare test data
        VDST_Event_gne__c ev = prepareEvent('ADBOARD'); // ADBOARD
        VDST_EventPrtcpntRole_gne__c epr = new VDST_EventPrtcpntRole_gne__c(EventType_gne__c = 'ADBOARD', EventParticipantRoleCode_gne__c = 'ATND',
            EventParticipantRoleName__c = 'Attendee');
        insert epr;
        VDST_Address_gne__c adr = new VDST_Address_gne__c(VDST_Event_gne__c = ev.Id, City_gne__c = 'Lublin', Country_gne__c = 'USA', StateProvince_gne__c = 'CA',
            StatesNameHolder_gne__c = 'testState');
        insert adr;
        List<VDST_EventPrtcpntAccnt_gne__c> epaList = new List<VDST_EventPrtcpntAccnt_gne__c>();
        VDST_EventPrtcpntAccnt_gne__c epa1 = new VDST_EventPrtcpntAccnt_gne__c(VDST_Event_gne__c = ev.Id,
            PartyType_gne__c = 'INDV', FirstName_gne__c = 'John', LastName_gne__c = 'Wall', VendorParticipantID_gne__c = 'GNE_123notused',
            EventParticipantRole_gne__c = epr.Id, VDST_Address_gne__c = adr.Id);
        epaList.add(epa1);
        VDST_EventPrtcpntAccnt_gne__c epa2 = new VDST_EventPrtcpntAccnt_gne__c(VDST_Event_gne__c = ev.Id,
            PartyType_gne__c = 'ORG', FirstName_gne__c = 'Marcin', LastName_gne__c = 'Gortat', VendorParticipantID_gne__c = 'GNE_abc',
            EventParticipantRole_gne__c = epr.Id, VDST_Address_gne__c = adr.Id);
        epaList.add(epa2);
        insert epaList;
        setEventAndTypeParams(ev.Id, null);
        VDST_EventDetailController edc = new VDST_EventDetailController();
        edc.initData();
        Test.startTest();
        // Test setting new values
        // Do not show list
        edc.prtcpntUtils.showParticipantList = false;
        System.assertEquals(edc.prtcpntUtils.participantList, null);
        edc.prtcpntUtils.showParticipantList = true;
        // Show list for ADBOARDS (only individual accounts)
        System.assertEquals(edc.prtcpntUtils.participantList.size(), 1);
        System.assertEquals(edc.prtcpntUtils.participantList.get(0).accnt.FirstName_gne__c, 'John');
        // Show list for Research
        ev.EventType_gne__c = 'RSCH';
        update ev;
        edc = new VDST_EventDetailController();
        edc.initData();
        System.assertEquals(edc.prtcpntUtils.participantList.size(), 2); // Should also get ORG participants
        // Test wrapper method
        System.assertEquals(edc.prtcpntUtils.participantList.get(0).getStateProvince(), 'California');
        adr.Country_gne__c = 'POL';
        update adr;
        System.assertEquals(edc.prtcpntUtils.participantList.get(0).getStateProvince(), 'testState');
        Test.stopTest();
        // Test 2 records and one per page values
        edc.prtcpntUtils.prtcpntPagingUtil.perPage = 1;
        edc.prtcpntUtils.prtcpntPagingUtil.actualPage = 2;
        System.assertEquals(edc.prtcpntUtils.participantList.size(), 1);
        System.assertEquals(edc.prtcpntUtils.prtcpntPagingUtil.totalPages, 2);
    }

    /** @date 2/28/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for navigation buttons
    */
    @IsTest(SeeAllData=false)
    static void manageParticipantButtons_Test() {
        // Prepare test data
        VDST_Event_gne__c ev = prepareEvent('ECOUPON'); // ADBOARD
        VDST_EventPrtcpntRole_gne__c epr = new VDST_EventPrtcpntRole_gne__c(EventType_gne__c = 'ECOUPON', EventParticipantRoleCode_gne__c = 'ATND',
            EventParticipantRoleName__c = 'Attendee');
        insert epr;
        List<VDST_EventPrtcpntAccnt_gne__c> epaList = new List<VDST_EventPrtcpntAccnt_gne__c>();
        VDST_EventPrtcpntAccnt_gne__c epa1 = new VDST_EventPrtcpntAccnt_gne__c(VDST_Event_gne__c = ev.Id,
            PartyType_gne__c = 'INDV', FirstName_gne__c = 'John', LastName_gne__c = 'Wall', VendorParticipantID_gne__c = 'GNE_123notused',
            EventParticipantRole_gne__c = epr.Id);
        epaList.add(epa1);
        insert epaList;
        setEventAndTypeParams(ev.Id, null);
        VDST_EventDetailController edc = new VDST_EventDetailController();
        edc.initData();
        Test.startTest();
        // Test addParticipant() method
        edc.prtcpntUtils.addParticipant();
        System.assertNotEquals(edc.prtcpntUtils.prtcpnt, null);
        System.assertNotEquals(edc.prtcpntUtils.prtcpnt.evntPrtcpnt, null);
        System.assertEquals(edc.prtcpntUtils.prtcpnt.evntPrtcpnt.PartyType_gne__c, 'INDV');
        System.assertNotEquals(edc.prtcpntUtils.prtcpnt.evntPrtcpnt.EventParticipantRole_gne__c, null);
        System.assertEquals(edc.prtcpntUtils.editableState, 'Create');
        System.assertEquals(edc.prtcpntUtils.editableMode, true);
        // Test addOrgParticipant() method
        edc.prtcpntUtils.addOrgParticipant();
        System.assertNotEquals(edc.prtcpntUtils.prtcpnt, null);
        System.assertNotEquals(edc.prtcpntUtils.prtcpnt.evntPrtcpnt, null);
        System.assertEquals(edc.prtcpntUtils.prtcpnt.evntPrtcpnt.PartyType_gne__c, 'ORG');
        System.assertEquals(edc.prtcpntUtils.editableState, 'Create');
        // Test editParticipant() method
        edc.prtcpntUtils.prtcpntId = epa1.Id;
        edc.prtcpntUtils.editParticipant();
        System.assertNotEquals(edc.prtcpntUtils.prtcpnt, null);
        System.assertNotEquals(edc.prtcpntUtils.prtcpnt.evntPrtcpnt, null);
        System.assertEquals(edc.prtcpntUtils.editableState, 'Edit');
        System.assertEquals(edc.prtcpntUtils.editableMode, true);
        // Test showParticipant() method
        edc.prtcpntUtils.prtcpntId = epa1.Id;
        edc.prtcpntUtils.showParticipant();
        System.assertNotEquals(edc.prtcpntUtils.prtcpnt, null);
        System.assertNotEquals(edc.prtcpntUtils.prtcpnt.evntPrtcpnt, null);
        System.assertEquals(edc.prtcpntUtils.editableState, 'Edit');
        System.assertEquals(edc.prtcpntUtils.editableMode, false);
        // Test editParticipantMode() method
        edc.prtcpntUtils.prtcpntId = epa1.Id;
        edc.prtcpntUtils.editParticipantMode();
        System.assertEquals(edc.prtcpntUtils.editableMode, true);
        // Test cancelParticipantMode() method
        edc.prtcpntUtils.prtcpntId = epa1.Id;
        edc.prtcpntUtils.cancelParticipantMode();
        System.assertEquals(edc.prtcpntUtils.editableMode, false);
        // Test deleteParticipant() method
        // Prepare data
        ev.EventType_gne__c = 'INDVSPND';
        update ev;
        edc = new VDST_EventDetailController();
        edc.initData();
        List<VDST_EventPrtcpntAccnt_gne__c> preEpaList = [SELECT Id FROM VDST_EventPrtcpntAccnt_gne__c WHERE VDST_Event_gne__c = :ev.Id];
        System.assertEquals(preEpaList.size(), 1);
        // Prepare method
        edc.prtcpntUtils.prtcpntId = epa1.Id;
        edc.prtcpntUtils.deleteParticipant();
        Test.stopTest();
        // Test method
        System.assertEquals(edc.prtcpntUtils.prtcpntListMsg, 'Participant has been deleted.');
        List<VDST_EventPrtcpntAccnt_gne__c> postEpaList = [SELECT Id FROM VDST_EventPrtcpntAccnt_gne__c WHERE VDST_Event_gne__c = :ev.Id];
        System.assertEquals(postEpaList.size(), 0);
        System.assertEquals(edc.commonUtils.nonResTransaction.attendanceList.size(), 0);
    }

    /** @date 3/11/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for save buttons - part 1 (Incorrect Vendor Code)
    */
    @IsTest(SeeAllData=false)
    static void saveButtons1_Test() {
        // Prepare data
        VDST_Event_gne__c ev = prepareEvent('ADBOARD');
        ev.CurrentStatus_gne__c = 'OCCURRED';
        update ev;
        // Run controller
        setEventAndTypeParams(ev.Id, null);
        VDST_EventDetailController edc = new VDST_EventDetailController();
        edc.initData();
        edc.prtcpntUtils.commonUtils.vendorLoggedVal = null;
        Test.startTest();
        // Test error messages
        edc.prtcpntUtils.addParticipant();
        edc.prtcpntUtils.prtcpnt.getPrtcpntAccnt().VendorParticipantID_gne__c = 'Test';
        edc.prtcpntUtils.saveParticipant();
        Test.stopTest();
        System.assert( String.isNotBlank(edc.prtcpntUtils.editErrorMessages) );
    }

    /** @date 3/10/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for save buttons - part 2 (Create Single Spend)
    */
    @IsTest(SeeAllData=false)
    static void saveButtons2_Test() {
        // Prepare data
        VDST_Event_gne__c ev = prepareEvent('ECOUPON');
        // Run controller
        setEventAndTypeParams(ev.Id, null);
        VDST_EventDetailController edc = new VDST_EventDetailController();
        edc.initData();
        Test.startTest();
        // Test creating Participant
        edc.prtcpntUtils.addParticipant();
        edc.prtcpntUtils.prtcpnt.singleSpendTrans.ItemQuantity_gne__c = 2;
        edc.prtcpntUtils.itemAmount = 12.34;
        edc.prtcpntUtils.prtcpnt.evntPrtcpntAddress.Country_gne__c = 'POL';
        edc.prtcpntUtils.prtcpnt.evntPrtcpntAddress.PostalCode_gne__c = 'postal 1234';
        edc.prtcpntUtils.prtcpnt.getPrtcpntAccnt().VendorParticipantID_gne__c = 'vend-1234';
        edc.prtcpntUtils.saveParticipant();
        System.assertEquals(edc.prtcpntUtils.prtcpnt.evntPrtcpntAddress.PostalCode_gne__c, 'POSTAL 1234');
        System.assertEquals(edc.prtcpntUtils.prtcpnt.singleSpendTrans.TransactionAmount_gne__c, 24.68);
        System.assertEquals(edc.prtcpntUtils.prtcpnt.getPrtcpntAccnt().VendorParticipantID_gne__c, 'VEND-1234');
        // Exception for Single Spend null quantity value
        edc.prtcpntUtils.addParticipant();
        edc.prtcpntUtils.prtcpnt.singleSpendTrans.ItemQuantity_gne__c = null;
        edc.prtcpntUtils.itemAmount = 12.34;
        edc.prtcpntUtils.saveParticipant();
        Test.stopTest();
        System.assertEquals(edc.prtcpntUtils.prtcpnt.singleSpendTrans.TransactionAmount_gne__c, 0);
    }

    /** @date 3/12/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for save buttons - part 3 (Create Research)
    */
    @IsTest(SeeAllData=false)
    static void saveButtons3_Test() {
        // Prepare data
        VDST_Event_gne__c ev = prepareEvent('RSCH');
        ev.ResearchPaymentTypeCode_gne__c = 'PRECLINICAL';
        update ev;
        List<VDST_EventPrtcpntRole_gne__c> eprList = new List<VDST_EventPrtcpntRole_gne__c>();
        VDST_EventPrtcpntRole_gne__c epr1 = new VDST_EventPrtcpntRole_gne__c(EventType_gne__c = 'RSCH',
            EventParticipantRoleCode_gne__c = 'PI', EventParticipantRoleName__c = 'PI');
        eprList.add(epr1);
        VDST_EventPrtcpntRole_gne__c epr2 = new VDST_EventPrtcpntRole_gne__c(EventType_gne__c = 'RSCH',
            EventParticipantRoleCode_gne__c = 'PAYEE', EventParticipantRoleName__c = 'Payee');
        eprList.add(epr2);
        insert eprList;
        // Run controller
        setEventAndTypeParams(ev.Id, null);
        VDST_EventDetailController edc = new VDST_EventDetailController();
        edc.initData();
        // Test creating Participant - create PI for Research
        edc.prtcpntUtils.addParticipant();
        edc.prtcpntUtils.prtcpnt.evntPrtcpnt.EventParticipantRole_gne__c = epr1.Id;
        edc.prtcpntUtils.saveParticipant();
        List<VDST_PrtcpntTransaction_gne__c> exTransactions = [SELECT Id, TransactionLevel_gne__c, TransactionAllocationType_gne__c, TransactionTypeCode_gne__c FROM VDST_PrtcpntTransaction_gne__c WHERE VDST_Event_gne__c = :ev.Id];
        System.assertEquals(exTransactions.size(), 1);
        System.assertEquals(exTransactions.get(0).TransactionLevel_gne__c, 'INDV');
        System.assertEquals(exTransactions.get(0).TransactionAllocationType_gne__c, 'INDIRECT');
        System.assertEquals(exTransactions.get(0).TransactionTypeCode_gne__c, 'PRECLINCL');
        // Test creating Participant - create Payee for Research
        ev.ResearchPaymentTypeCode_gne__c = 'CLINICAL';
        update ev;
        edc = new VDST_EventDetailController(); // changing Research Payment Type Code
        edc.initData();
        // Create Participant
        edc.prtcpntUtils.addParticipant();
        edc.prtcpntUtils.prtcpnt.evntPrtcpnt.EventParticipantRole_gne__c = epr2.Id;
        edc.prtcpntUtils.saveParticipant();
        List<VDST_EventPrtcpntAccnt_gne__c> exAccnt1 = [SELECT Id FROM VDST_EventPrtcpntAccnt_gne__c ORDER BY CreatedDate ASC];
        System.assertEquals(exAccnt1.size(), 2);
        List<VDST_PrtcpntTransaction_gne__c> exTransactions1 = [SELECT Id, TransactionLevel_gne__c, TransactionAllocationType_gne__c, TransactionTypeCode_gne__c, VDST_PaidToParty_gne__c FROM VDST_PrtcpntTransaction_gne__c WHERE VDST_Event_gne__c = :ev.Id ORDER BY CreatedDate ASC];
        System.assertEquals(exTransactions1.size(), 2);
        System.assertEquals(exTransactions1.get(1).TransactionLevel_gne__c, 'INDV');
        System.assertEquals(exTransactions1.get(1).TransactionAllocationType_gne__c, 'DIRECT');
        System.assertEquals(exTransactions1.get(1).TransactionTypeCode_gne__c, 'RSCH');
        System.assertEquals(exTransactions1.get(1).VDST_PaidToParty_gne__c, exAccnt1.get(1).Id);
        System.assertEquals(exTransactions1.get(0).VDST_PaidToParty_gne__c, exAccnt1.get(1).Id);
        Test.startTest(); // for Limit prevention
        // Delete PI Participant
        edc.prtcpntUtils.prtcpntId = exAccnt1.get(0).Id;
        edc.prtcpntUtils.deleteParticipant();
        // Test creating Participant - create PI for Research after Payee (other order)
        edc.prtcpntUtils.addParticipant();
        edc.prtcpntUtils.prtcpnt.evntPrtcpnt.EventParticipantRole_gne__c = epr1.Id;
        edc.prtcpntUtils.saveParticipant();
        List<VDST_EventPrtcpntAccnt_gne__c> exAccnt2 = [SELECT Id FROM VDST_EventPrtcpntAccnt_gne__c ORDER BY CreatedDate ASC];
        System.assertEquals(exAccnt2.size(), 2);
        List<VDST_PrtcpntTransaction_gne__c> exTransactions2 = [SELECT Id, TransactionLevel_gne__c, TransactionAllocationType_gne__c, TransactionTypeCode_gne__c, VDST_PaidToParty_gne__c FROM VDST_PrtcpntTransaction_gne__c WHERE VDST_Event_gne__c = :ev.Id ORDER BY CreatedDate ASC];
        System.assertEquals(exTransactions2.size(), 2);
        System.assertEquals(exTransactions2.get(1).TransactionLevel_gne__c, 'INDV');
        System.assertEquals(exTransactions2.get(1).TransactionAllocationType_gne__c, 'INDIRECT');
        System.assertEquals(exTransactions2.get(1).TransactionTypeCode_gne__c, 'RSCH');
        System.assertEquals(exTransactions2.get(1).VDST_PaidToParty_gne__c, exAccnt2.get(0).Id);
        Test.stopTest(); // for Limit prevention
    }

    /** @date 3/12/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for save buttons - part 4 (Create Non-Research)
    */
    @IsTest(SeeAllData=false)
    static void saveButtons4_Test() {
        // Prepare data
        VDST_Event_gne__c ev = prepareEvent('INDVSPND');
        List<VDST_EventPrtcpntRole_gne__c> eprList = new List<VDST_EventPrtcpntRole_gne__c>();
        VDST_EventPrtcpntRole_gne__c epr1 = new VDST_EventPrtcpntRole_gne__c(EventType_gne__c = 'INDVSPND',
            EventParticipantRoleCode_gne__c = 'ATND', EventParticipantRoleName__c = 'Attendee');
        eprList.add(epr1);
        VDST_EventPrtcpntRole_gne__c epr2 = new VDST_EventPrtcpntRole_gne__c(EventType_gne__c = 'INDVSPND',
            EventParticipantRoleCode_gne__c = 'PAYEE', EventParticipantRoleName__c = 'Payee');
        eprList.add(epr2);
        VDST_EventPrtcpntRole_gne__c epr3 = new VDST_EventPrtcpntRole_gne__c(EventType_gne__c = 'INDVSPND',
            EventParticipantRoleCode_gne__c = 'ORG', EventParticipantRoleName__c = 'Payee');
        eprList.add(epr3);
        insert eprList;
        // Run controller
        setEventAndTypeParams(ev.Id, null);
        VDST_EventDetailController edc = new VDST_EventDetailController();
        edc.initData();
        Test.startTest();
        // Test creating Participant - create Attendee Participant
        edc.prtcpntUtils.addParticipant();
        edc.prtcpntUtils.prtcpnt.evntPrtcpnt.EventParticipantRole_gne__c = epr1.Id;
        edc.prtcpntUtils.prtcpnt.transactions.get('CHARITY').transAmount = '12.23';
        // Save Participant
        edc.prtcpntUtils.saveParticipant();
        List<VDST_EventPrtcpntAccnt_gne__c> exAccnt0 = [SELECT Id FROM VDST_EventPrtcpntAccnt_gne__c ORDER BY CreatedDate ASC];
        System.assertEquals(exAccnt0.size(), 1);
        List<VDST_PrtcpntTransaction_gne__c> exTransactions0 = [SELECT Id, TransactionLevel_gne__c, TransactionAllocationType_gne__c, TransactionTypeCode_gne__c, VDST_PaidToParty_gne__c FROM VDST_PrtcpntTransaction_gne__c WHERE VDST_Event_gne__c = :ev.Id];
        System.assertEquals(exTransactions0.size(), 1);
        System.assertEquals(exTransactions0.get(0).VDST_PaidToParty_gne__c, exAccnt0.get(0).Id);
        // Test creating Participant - create first Payee Participant
        edc.prtcpntUtils.addParticipant();
        edc.prtcpntUtils.prtcpnt.evntPrtcpnt.EventParticipantRole_gne__c = epr2.Id;
        // Save Participant
        edc.prtcpntUtils.saveParticipant();
        // Test creating Participant - create Attendee Participant
        edc.prtcpntUtils.addParticipant();
        edc.prtcpntUtils.prtcpnt.evntPrtcpnt.EventParticipantRole_gne__c = epr1.Id;
        // Save Participant
        edc.prtcpntUtils.saveParticipant();
        List<VDST_EventPrtcpntAccnt_gne__c> exAccnt1 = [SELECT Id FROM VDST_EventPrtcpntAccnt_gne__c ORDER BY CreatedDate ASC];
        System.assertEquals(exAccnt1.size(), 3);
        List<VDST_PrtcpntTransaction_gne__c> exTransactions = [SELECT Id, TransactionLevel_gne__c, TransactionAllocationType_gne__c, TransactionTypeCode_gne__c FROM VDST_PrtcpntTransaction_gne__c WHERE VDST_Event_gne__c = :ev.Id];
        System.assertEquals(exTransactions.size(), 1); // Because only one has transaction
        Test.stopTest();
    }

    /** @date 3/10/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for save buttons - part 5 (Edit AdBoard)
    */
    @IsTest(SeeAllData=false)
    static void saveButtons5_Test() {
        // Prepare test data
        VDST_Event_gne__c ev = prepareEvent('ADBOARD'); // ADBOARD
        VDST_EventPrtcpntRole_gne__c epr = new VDST_EventPrtcpntRole_gne__c(EventType_gne__c = 'ECOUPON',
            EventParticipantRoleCode_gne__c = 'ATND', EventParticipantRoleName__c = 'Attendee');
        insert epr;
        List<VDST_EventPrtcpntField_gne__c> epfList = new List<VDST_EventPrtcpntField_gne__c>();
        VDST_EventPrtcpntField_gne__c epf1 = new VDST_EventPrtcpntField_gne__c(FieldName_gne__c = 'hasTrans',
            IsRequired_gne__c = false, IsVisible_gne__c = true, VDST_EventPrtcpntRole__c = epr.Id);
        epfList.add(epf1);
        VDST_EventPrtcpntField_gne__c epf2 = new VDST_EventPrtcpntField_gne__c(FieldName_gne__c = 'hasFees',
            IsRequired_gne__c = false, IsVisible_gne__c = true, VDST_EventPrtcpntRole__c = epr.Id);
        epfList.add(epf2);
        insert epfList;
        List<VDST_Address_gne__c> adrList = new List<VDST_Address_gne__c>();
        VDST_Address_gne__c adr1 = new VDST_Address_gne__c(VDST_Event_gne__c = ev.Id, City_gne__c = 'Lublin',
            Country_gne__c = 'USA', StateProvince_gne__c = 'CA', StatesNameHolder_gne__c = 'testState',
            PostalCode_gne__c = 'cAseTest');
        adrList.add(adr1);
        VDST_Address_gne__c adr2 = new VDST_Address_gne__c(VDST_Event_gne__c = ev.Id, City_gne__c = 'Lublin',
            Country_gne__c = 'USA', StateProvince_gne__c = 'CA', StatesNameHolder_gne__c = 'testState',
            PostalCode_gne__c = 'cAseTest2');
        adrList.add(adr2);
        insert adrList;
        List<VDST_EventPrtcpntAccnt_gne__c> epaList = new List<VDST_EventPrtcpntAccnt_gne__c>();
        VDST_EventPrtcpntAccnt_gne__c epa1 = new VDST_EventPrtcpntAccnt_gne__c(VDST_Event_gne__c = ev.Id,
            PartyType_gne__c = 'INDV', FirstName_gne__c = 'John', LastName_gne__c = 'Wall',
            VendorParticipantID_gne__c = 'GNE_123notused', EventParticipantRole_gne__c = epr.Id, VDST_Address_gne__c = adr1.Id);
        epaList.add(epa1);
        VDST_EventPrtcpntAccnt_gne__c epa2 = new VDST_EventPrtcpntAccnt_gne__c(VDST_Event_gne__c = ev.Id,
            PartyType_gne__c = 'INDV', LegalName_gne__c = 'OrgName', VendorParticipantID_gne__c = 'GNE_123notusedOrg',
            EventParticipantRole_gne__c = epr.Id, VDST_Address_gne__c = adr2.Id);
        epaList.add(epa2);
        insert epaList;
        List<VDST_PrtcpntTransaction_gne__c> ptList = new List<VDST_PrtcpntTransaction_gne__c>();
        VDST_PrtcpntTransaction_gne__c pt1 = new VDST_PrtcpntTransaction_gne__c(FeePayToPartyType_gne__c = 'INDV',
            TransactionAllocationType_gne__c = 'DIRECT', TransactionAmount_gne__c = 12, TransactionLevel_gne__c = 'INDV',
            TransactionTypeCode_gne__c = 'HONORARIA', VDST_EventPrtcpntAccnt_gne__c = epa1.Id, VDST_PaidToParty_gne__c = epa2.Id);
        ptList.add(pt1);
        VDST_PrtcpntTransaction_gne__c pt2 = new VDST_PrtcpntTransaction_gne__c(FeePayToPartyType_gne__c = 'ORG',
            TransactionAllocationType_gne__c = 'INDIRECT', TransactionAmount_gne__c = 12, TransactionLevel_gne__c = 'INDV',
            TransactionTypeCode_gne__c = 'HONORARIA', VDST_EventPrtcpntAccnt_gne__c = epa2.Id, VDST_PaidToParty_gne__c = epa1.Id);
        ptList.add(pt2);
        insert ptList;
        // Run controller
        setEventAndTypeParams(ev.Id, null);
        VDST_EventDetailController edc = new VDST_EventDetailController();
        edc.initData();
        Test.startTest();
        // Set in edit mode
        edc.prtcpntUtils.prtcpntId = epa1.Id;
        edc.prtcpntUtils.editParticipant();
        System.assertEquals(edc.prtcpntUtils.editableState, 'Edit');
        System.assertEquals(edc.prtcpntUtils.editableMode, true);
        // Test onlySaveParticipant() method
        edc.prtcpntUtils.onlySaveParticipant();
        System.assertEquals(edc.prtcpntUtils.editableMode, true);
        // Test saveParticipant() method
        edc.prtcpntUtils.prtcpnt.evntPrtcpnt.MiddleName_gne__c = 'K';
        edc.prtcpntUtils.prtcpnt.evntPrtcpntAddress.City_gne__c = 'New York';
        edc.prtcpntUtils.prtcpnt.evntOrg.LegalName_gne__c = 'OrgNameNew';
        edc.prtcpntUtils.prtcpnt.evntOrgAddress.City_gne__c = 'Chicago';
        edc.prtcpntUtils.saveParticipant();
        // Validate
        System.assertEquals(edc.prtcpntUtils.editableMode, false);
        // Test changes - INDV
        System.assertEquals(edc.prtcpntUtils.prtcpnt.evntPrtcpntAddress.PostalCode_gne__c, 'CASETEST');
        VDST_EventPrtcpntAccnt_gne__c updatedEpa1 = [SELECT Id, MiddleName_gne__c, VDST_Address_gne__c FROM VDST_EventPrtcpntAccnt_gne__c WHERE Id = :epa1.Id];
        System.assertEquals(updatedEpa1.MiddleName_gne__c, 'K');
        VDST_Address_gne__c updatedAddress = [SELECT Id, City_gne__c FROM VDST_Address_gne__c WHERE Id = :updatedEpa1.VDST_Address_gne__c];
        System.assertEquals(updatedAddress.City_gne__c, 'New York');
        // Test changes - ORG
        System.assertEquals(edc.prtcpntUtils.prtcpnt.evntOrgAddress.PostalCode_gne__c, 'CASETEST2');
        VDST_EventPrtcpntAccnt_gne__c updatedEpa2 = [SELECT Id, LegalName_gne__c, VDST_Address_gne__c FROM VDST_EventPrtcpntAccnt_gne__c WHERE Id = :epa2.Id];
        System.assertEquals(updatedEpa2.LegalName_gne__c, 'OrgNameNew');
        VDST_Address_gne__c updatedAddress2 = [SELECT Id, City_gne__c FROM VDST_Address_gne__c WHERE Id = :updatedEpa2.VDST_Address_gne__c];
        System.assertEquals(updatedAddress2.City_gne__c, 'Chicago');
        Test.stopTest();
    }

    /** @date 3/14/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for save buttons - part 6 (Edit Single Spend)
    */
    @IsTest(SeeAllData=false)
    static void saveButtons6_Test() {
        // Prepare test data
        VDST_Event_gne__c ev = prepareEvent('ECOUPON');
        VDST_EventPrtcpntRole_gne__c epr = new VDST_EventPrtcpntRole_gne__c(EventType_gne__c = 'ECOUPON',
            EventParticipantRoleCode_gne__c = 'ATND', EventParticipantRoleName__c = 'Attendee');
        insert epr;
        VDST_Address_gne__c adr = new VDST_Address_gne__c(VDST_Event_gne__c = ev.Id, City_gne__c = 'Lublin', Country_gne__c = 'USA', StateProvince_gne__c = 'CA',
            StatesNameHolder_gne__c = 'testState');
        insert adr;
        List<VDST_EventPrtcpntAccnt_gne__c> epaList = new List<VDST_EventPrtcpntAccnt_gne__c>();
        VDST_EventPrtcpntAccnt_gne__c epa1 = new VDST_EventPrtcpntAccnt_gne__c(VDST_Event_gne__c = ev.Id,
            PartyType_gne__c = 'INDV', FirstName_gne__c = 'John', LastName_gne__c = 'Wall',
            VendorParticipantID_gne__c = 'GNE_123notused', EventParticipantRole_gne__c = epr.Id, VDST_Address_gne__c = adr.Id);
        epaList.add(epa1);
        insert epaList;
        VDST_PrtcpntTransaction_gne__c pt = new VDST_PrtcpntTransaction_gne__c(
            VDST_EventPrtcpntAccnt_gne__c = epa1.Id, VDST_PaidToParty_gne__c = epa1.Id,
            FeePayToPartyType_gne__c = 'INDV', ItemQuantity_gne__c = 1, TransactionAllocationType_gne__c = 'DIRECT',
            TransactionAmount_gne__c = 100.12, TransactionLevel_gne__c = 'INDV', TransactionTypeCode_gne__c = 'ECOUPON');
        insert pt;
        // Run controller
        setEventAndTypeParams(ev.Id, null);
        VDST_EventDetailController edc = new VDST_EventDetailController();
        edc.initData();
        Test.startTest();
        // Set in edit mode
        edc.prtcpntUtils.prtcpntId = epa1.Id;
        edc.prtcpntUtils.editParticipant();
        edc.prtcpntUtils.prtcpnt.singleSpendTrans.ItemQuantity_gne__c = 2;
        edc.prtcpntUtils.itemAmount = 12.34;
        // Test saveParticipant() method
        edc.prtcpntUtils.saveParticipant(); // should calculate
        System.assertEquals(edc.prtcpntUtils.prtcpnt.singleSpendTrans.TransactionAmount_gne__c, 24.68);
        edc.prtcpntUtils.prtcpnt.singleSpendTrans.ItemQuantity_gne__c = null;
        edc.prtcpntUtils.saveParticipant(); // should set 0 amount
        System.assertEquals(edc.prtcpntUtils.prtcpnt.singleSpendTrans.TransactionAmount_gne__c, 0);
        Test.stopTest();
    }

    /** @date 3/14/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for save buttons - part 7 (Edit Non-Research)
    */
    @IsTest(SeeAllData=false)
    static void saveButtons7_Test() {
        // Prepare test data
        VDST_Event_gne__c ev = prepareEvent('INDVSPND');
        List<VDST_EventPrtcpntRole_gne__c> eprList = new List<VDST_EventPrtcpntRole_gne__c>();
        VDST_EventPrtcpntRole_gne__c epr1 = new VDST_EventPrtcpntRole_gne__c(EventType_gne__c = 'INDVSPND',
            EventParticipantRoleCode_gne__c = 'ATND', EventParticipantRoleName__c = 'Attendee');
        eprList.add(epr1);
        VDST_EventPrtcpntRole_gne__c epr2 = new VDST_EventPrtcpntRole_gne__c(EventType_gne__c = 'INDVSPND',
            EventParticipantRoleCode_gne__c = 'PAYEE', EventParticipantRoleName__c = 'Payee');
        eprList.add(epr2);
        VDST_EventPrtcpntRole_gne__c epr3 = new VDST_EventPrtcpntRole_gne__c(EventType_gne__c = 'INDVSPND',
            EventParticipantRoleCode_gne__c = 'ORG', EventParticipantRoleName__c = 'Payee');
        eprList.add(epr3);
        insert eprList;
        VDST_Address_gne__c adr = new VDST_Address_gne__c(VDST_Event_gne__c = ev.Id, City_gne__c = 'Lublin', Country_gne__c = 'USA', StateProvince_gne__c = 'CA',
            StatesNameHolder_gne__c = 'testState');
        insert adr;
        List<VDST_EventPrtcpntAccnt_gne__c> epaList = new List<VDST_EventPrtcpntAccnt_gne__c>();
        VDST_EventPrtcpntAccnt_gne__c epa1 = new VDST_EventPrtcpntAccnt_gne__c(VDST_Event_gne__c = ev.Id,
            PartyType_gne__c = 'INDV', FirstName_gne__c = 'John', LastName_gne__c = 'Wall',
            VendorParticipantID_gne__c = 'GNE_123notused', EventParticipantRole_gne__c = epr1.Id, VDST_Address_gne__c = adr.Id);
        epaList.add(epa1);
        VDST_EventPrtcpntAccnt_gne__c epa2 = new VDST_EventPrtcpntAccnt_gne__c(VDST_Event_gne__c = ev.Id,
            PartyType_gne__c = 'INDV', FirstName_gne__c = 'Payee', LastName_gne__c = 'Wall',
            VendorParticipantID_gne__c = 'GNE_123notused', EventParticipantRole_gne__c = epr2.Id, VDST_Address_gne__c = adr.Id);
        epaList.add(epa2);
        insert epaList;
        List<VDST_PrtcpntTransaction_gne__c> ptList = new List<VDST_PrtcpntTransaction_gne__c>();
        VDST_PrtcpntTransaction_gne__c pt1 = new VDST_PrtcpntTransaction_gne__c(FeePayToPartyType_gne__c = 'INDV',
            TransactionAllocationType_gne__c = 'INDIRECT', TransactionAmount_gne__c = 12, TransactionLevel_gne__c = 'INDV',
            TransactionTypeCode_gne__c = 'HONORARIA', VDST_EventPrtcpntAccnt_gne__c = epa1.Id, VDST_PaidToParty_gne__c = epa1.Id);
        ptList.add(pt1);
        VDST_PrtcpntTransaction_gne__c pt2 = new VDST_PrtcpntTransaction_gne__c(FeePayToPartyType_gne__c = 'INDV',
            TransactionAllocationType_gne__c = 'INDIRECT', TransactionAmount_gne__c = 23, TransactionLevel_gne__c = 'INDV',
            TransactionTypeCode_gne__c = 'CHARITY', VDST_EventPrtcpntAccnt_gne__c = epa1.Id, VDST_PaidToParty_gne__c = epa1.Id);
        ptList.add(pt2);
        insert ptList;
        // Run controller
        setEventAndTypeParams(ev.Id, null);
        VDST_EventDetailController edc = new VDST_EventDetailController();
        edc.initData();
        Test.startTest();
        // Create another Attendee user
        edc.prtcpntUtils.addParticipant();
        edc.prtcpntUtils.prtcpnt.evntPrtcpnt.EventParticipantRole_gne__c = epr1.Id;
        edc.prtcpntUtils.saveParticipant();
        // Set in edit mode - Attendee
        edc.prtcpntUtils.prtcpntId = epa1.Id;
        edc.prtcpntUtils.editParticipant();
        // Test saveParticipant() method
        List<VDST_PrtcpntTransaction_gne__c> ptList1 = [SELECT Id FROM VDST_PrtcpntTransaction_gne__c];
        System.assertEquals(ptList1.size(), 2);
        edc.prtcpntUtils.prtcpnt.transactions.get('CHARITY').transAmount = '0.00';
        edc.prtcpntUtils.saveParticipant();
        Test.stopTest();
        List<VDST_PrtcpntTransaction_gne__c> ptList2 = [SELECT Id FROM VDST_PrtcpntTransaction_gne__c];
        System.assertEquals(ptList2.size(), 1);
        // Set in edit mode - change to Payee
        edc.prtcpntUtils.prtcpnt.evntPrtcpnt.EventParticipantRole_gne__c = epr2.Id;
        // Test saveParticipant() method
        List<VDST_PrtcpntTransaction_gne__c> tranList = [SELECT Id, VDST_PaidToParty_gne__c FROM VDST_PrtcpntTransaction_gne__c WHERE VDST_Event_gne__c = :ev.Id];
        for(VDST_PrtcpntTransaction_gne__c tran : tranList) {
            System.assertEquals(tran.VDST_PaidToParty_gne__c, epa2.Id);
        }
    }

    /** @date 3/17/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for save buttons - part 8 (Edit AdBoard with hasTrans set to false)
    */
    @IsTest(SeeAllData=false)
    static void saveButtons8_Test() {
        // Prepare test data
        VDST_Event_gne__c ev = prepareEvent('ADBOARD');
        VDST_EventPrtcpntRole_gne__c epr = new VDST_EventPrtcpntRole_gne__c(EventType_gne__c = 'ADBOARD',
            EventParticipantRoleCode_gne__c = 'ATND', EventParticipantRoleName__c = 'Attendee');
        insert epr;
        VDST_Address_gne__c adr = new VDST_Address_gne__c(VDST_Event_gne__c = ev.Id, City_gne__c = 'Lublin', Country_gne__c = 'USA', StateProvince_gne__c = 'CA',
            StatesNameHolder_gne__c = 'testState');
        insert adr;
        List<VDST_EventPrtcpntAccnt_gne__c> epaList = new List<VDST_EventPrtcpntAccnt_gne__c>();
        VDST_EventPrtcpntAccnt_gne__c epa1 = new VDST_EventPrtcpntAccnt_gne__c(VDST_Event_gne__c = ev.Id,
            PartyType_gne__c = 'INDV', FirstName_gne__c = 'John', LastName_gne__c = 'Wall',
            VendorParticipantID_gne__c = 'GNE_123notused', EventParticipantRole_gne__c = epr.Id, VDST_Address_gne__c = adr.Id);
        epaList.add(epa1);
        insert epaList;
        VDST_PrtcpntTransaction_gne__c pt = new VDST_PrtcpntTransaction_gne__c(
            VDST_EventPrtcpntAccnt_gne__c = epa1.Id, VDST_PaidToParty_gne__c = epa1.Id,
            FeePayToPartyType_gne__c = 'INDV', ItemQuantity_gne__c = 1, TransactionAllocationType_gne__c = 'DIRECT',
            TransactionAmount_gne__c = 100.12, TransactionLevel_gne__c = 'INDV', TransactionTypeCode_gne__c = 'HONORARIA');
        insert pt;
        List<VDST_EventPrtcpntField_gne__c> epfList = new List<VDST_EventPrtcpntField_gne__c>();
        VDST_EventPrtcpntField_gne__c epf1 = new VDST_EventPrtcpntField_gne__c(FieldName_gne__c = 'hasTrans',
            IsRequired_gne__c = false, IsVisible_gne__c = false, VDST_EventPrtcpntRole__c = epr.Id);
        epfList.add(epf1);
        VDST_EventPrtcpntField_gne__c epf2 = new VDST_EventPrtcpntField_gne__c(FieldName_gne__c = 'hasFees',
            IsRequired_gne__c = false, IsVisible_gne__c = false, VDST_EventPrtcpntRole__c = epr.Id);
        epfList.add(epf2);
        insert epfList;
        // Run controller
        setEventAndTypeParams(ev.Id, null);
        VDST_EventDetailController edc = new VDST_EventDetailController();
        edc.initData();
        Test.startTest();
        // set in edit mode
        edc.prtcpntUtils.prtcpntId = epa1.Id;
        edc.prtcpntUtils.editParticipant();
        // Test saveParticipant() method - pre-data
        List<VDST_PrtcpntTransaction_gne__c> ptList1 = [SELECT Id FROM VDST_PrtcpntTransaction_gne__c];
        System.assertEquals(ptList1.size(), 2); // 2 = HONORARIA + TOTAL
        // Run method
        edc.prtcpntUtils.saveParticipant(); // should calculate
        Test.stopTest();
        // Test saveParticipant() method - post-data
        List<VDST_PrtcpntTransaction_gne__c> ptList2 = [SELECT Id FROM VDST_PrtcpntTransaction_gne__c];
        System.assertEquals(ptList2.size(), 1); /// Test for removing transactions when hasTrans = false - HONORARIA should be removed
    }

    /** @date 3/17/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for setVendorId() method
    */
    @IsTest(SeeAllData=false)
    static void setVendorId_Test() {
        // Prepare data
        VDST_Event_gne__c ev = prepareEvent('ADBOARD');
        VDST_EventPrtcpntAccnt_gne__c acc = new VDST_EventPrtcpntAccnt_gne__c();
        // Run controller
        setEventAndTypeParams(ev.Id, null);
        VDST_EventDetailController edc = new VDST_EventDetailController();
        edc.initData();
        Test.startTest();
        // Test for PENDING status
        System.assertEquals( edc.prtcpntUtils.setVendorId(acc), true);
        // Test for OCCURRED with null Vendor Participant Id and incorrect Vendor Code
        ev.CurrentStatus_gne__c = 'OCCURRED';
        update ev;
        Test.stopTest();
        System.assertEquals( edc.prtcpntUtils.setVendorId(acc), false);
        // Test for OCCURRED with null Vendor Participant Id
        edc.prtcpntUtils.commonUtils.vendorLoggedVal = 'GNE';
        System.assertEquals( edc.prtcpntUtils.setVendorId(acc), true);
        System.assertNotEquals( acc.VendorParticipantID_gne__c, null);
        System.assert( acc.VendorParticipantID_gne__c.startsWith('GNE') );
        // Test for not null Vendor Code
        edc.prtcpntUtils.commonUtils.vendorLoggedVal = null;
        System.assertEquals( edc.prtcpntUtils.setVendorId(acc), false);
        // Test for adding prefix
        edc.prtcpntUtils.commonUtils.vendorLoggedVal = 'GNE';
        acc.VendorParticipantID_gne__c = 'test';
        System.assertEquals( edc.prtcpntUtils.setVendorId(acc), true);
        System.assertEquals( acc.VendorParticipantID_gne__c, 'GNE_test');
    }

    // TODO: deleteParticipantOrganization() - PRIVATE!!!
    // TODO: cloneOrganization() - PRIVATE!!!

    /** @date 3/17/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for getPrtcpntRoles() and getResearchPrtcpntRoles() methods
    */
    @IsTest(SeeAllData=false)
    static void getPrtcpntRoles_Test() {
        // Prepare data
        List<VDST_EventPrtcpntRole_gne__c> eprList = new List<VDST_EventPrtcpntRole_gne__c>();
        VDST_EventPrtcpntRole_gne__c epr1 = new VDST_EventPrtcpntRole_gne__c(EventType_gne__c = 'INDVSPND',
            EventParticipantRoleCode_gne__c = 'ATND', EventParticipantRoleName__c = 'Attendee');
        eprList.add(epr1);
        VDST_EventPrtcpntRole_gne__c epr2 = new VDST_EventPrtcpntRole_gne__c(EventType_gne__c = 'INDVSPND',
            EventParticipantRoleCode_gne__c = 'PAYEE', EventParticipantRoleName__c = 'Payee');
        eprList.add(epr2);
        VDST_EventPrtcpntRole_gne__c epr3 = new VDST_EventPrtcpntRole_gne__c(EventType_gne__c = 'INDVSPND',
            EventParticipantRoleCode_gne__c = 'ORG', EventParticipantRoleName__c = 'Payee');
        eprList.add(epr3);
        VDST_EventPrtcpntRole_gne__c epr4 = new VDST_EventPrtcpntRole_gne__c(EventParticipantRoleName__c = 'Attendee',
            EventParticipantRoleCode_gne__c = 'ATND', EventType_gne__c = 'CFF');
        eprList.add(epr4);
        VDST_EventPrtcpntRole_gne__c epr5 = new VDST_EventPrtcpntRole_gne__c(EventType_gne__c = 'RSCH',
            EventParticipantRoleCode_gne__c = 'PI', EventParticipantRoleName__c = 'PI');
        eprList.add(epr5);
        VDST_EventPrtcpntRole_gne__c epr6 = new VDST_EventPrtcpntRole_gne__c(EventType_gne__c = 'RSCH',
            EventParticipantRoleCode_gne__c = 'PAYEE', EventParticipantRoleName__c = 'Payee');
        eprList.add(epr6);
        VDST_EventPrtcpntRole_gne__c epr7 = new VDST_EventPrtcpntRole_gne__c(EventType_gne__c = 'RSCH',
            EventParticipantRoleCode_gne__c = 'PAYEEPI', EventParticipantRoleName__c = 'Payee-PI');
        eprList.add(epr7);
        insert eprList;
        // Run controller
        VDST_Event_gne__c ev = prepareEvent('CFF');
        setEventAndTypeParams(ev.Id, null);
        VDST_EventDetailController edc = new VDST_EventDetailController();
        edc.initData();
        Test.startTest();
        // Test getPrtcpntRoles_Test() method for other events than Research
        List<SelectOption> soList = edc.prtcpntUtils.getPrtcpntRoles(); // Get List
        System.assertEquals(soList.get(0).getLabel(), '-Select-');
        System.assertEquals(soList.size(), 2); // + Attendee
        // ### Below tests are using getResearchPrtcpntRoles() method ###
        // Test getPrtcpntRoles_Test() method for Research Event
        ev.EventType_gne__c = 'RSCH';
        update ev;
        edc = new VDST_EventDetailController(); // change event to RSCH
        edc.initData();
        // Test cases
        soList = edc.prtcpntUtils.getPrtcpntRoles(); // Get List
        System.debug(soList);
        System.assertEquals(soList.size(), 1); // no Participant
        // Test for Research with no additional Participant
        edc.prtcpntUtils.addParticipant();
        soList = edc.prtcpntUtils.getPrtcpntRoles(); // Get List
        System.assertEquals(soList.size(), 4); // no Participant (+ PAYEE, PI, PAYEE-PI)
        // Test for Research with PI Participant
        VDST_EventPrtcpntAccnt_gne__c acc1 = new VDST_EventPrtcpntAccnt_gne__c(EventParticipantRole_gne__c = epr5.Id,
            VDST_Event_gne__c = ev.Id);
        insert acc1;
        soList = edc.prtcpntUtils.getPrtcpntRoles(); // Get List
        System.assertEquals(soList.size(), 2); // no Participant (+ PAYEE)
        // Test for Research with Payee Participant
        acc1.EventParticipantRole_gne__c = epr6.Id;
        update acc1;
        soList = edc.prtcpntUtils.getPrtcpntRoles(); // Get List
        System.assertEquals(soList.size(), 2); // no Participant (+ PI)
        // Test getPrtcpntRoles_Test() method for Non-Research Event
        ev.EventType_gne__c = 'INDVSPND';
        update ev;
        edc = new VDST_EventDetailController(); // change event to INDVSPND
        edc.initData();
        // Test cases
        soList = edc.prtcpntUtils.getPrtcpntRoles(); // Get List
        System.assertEquals(soList.size(), 1); // no Participant
        // Test for Research with additional Participant
        edc.prtcpntUtils.addParticipant();
        soList = edc.prtcpntUtils.getPrtcpntRoles(); // Get List
        System.assertEquals(soList.size(), 2); // no Participant (+ ATTENDEE)
        // Test for Research with no additional Participant
        delete acc1;
        edc.prtcpntUtils.addParticipant();
        soList = edc.prtcpntUtils.getPrtcpntRoles(); // Get List
        System.assertEquals(soList.size(), 3); // no Participant (+ PAYEE, ATTENDEE)
        // Change to ORG Participant
        edc.prtcpntUtils.addOrgParticipant();
        // Test getPrtcpntRoles_Test() method for Non-Research Event with no additional Participant
        soList = edc.prtcpntUtils.getPrtcpntRoles(); // Get List
        System.assertEquals(soList.size(), 3); // no Participant (+ ORG, ATTENDEE)
        // Test getPrtcpntRoles_Test() method for Non-Research Event with additional Participant
        VDST_EventPrtcpntAccnt_gne__c acc2 = new VDST_EventPrtcpntAccnt_gne__c(EventParticipantRole_gne__c = epr3.Id,
            VDST_Event_gne__c = ev.Id);
        insert acc2;
        soList = edc.prtcpntUtils.getPrtcpntRoles(); // Get List
        System.assertEquals(soList.size(), 2); // no Participant (+ ORG)
        // Test getPrtcpntRoles_Test() method for Research Event
        ev.EventType_gne__c = 'RSCH';
        update ev;
        edc = new VDST_EventDetailController(); // change event to RSCH
        edc.initData();
        edc.prtcpntUtils.addOrgParticipant();
        // Test getPrtcpntRoles_Test() method for Research Event
        soList = edc.prtcpntUtils.getPrtcpntRoles(); // Get List
        System.assertEquals(soList.size(), 2); // no Participant (+ ATTENDEE)
        Test.stopTest();
    }

    /** @date 3/17/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for changeFields() methods
    */
    @IsTest(SeeAllData=false)
    static void changeFields_Test() {
        // Prepare data
        VDST_Event_gne__c ev = prepareEvent('ADBOARD');
        //update ev;
        List<VDST_EventPrtcpntRole_gne__c> eprList = new List<VDST_EventPrtcpntRole_gne__c>();
        VDST_EventPrtcpntRole_gne__c epr1 = new VDST_EventPrtcpntRole_gne__c(EventType_gne__c = 'ADBOARD',
            EventParticipantRoleCode_gne__c = 'VNDSTAFF', EventParticipantRoleName__c = 'Vendor Staff');
        eprList.add(epr1);
        VDST_EventPrtcpntRole_gne__c epr2 = new VDST_EventPrtcpntRole_gne__c(EventType_gne__c = 'ADBOARD',
            EventParticipantRoleCode_gne__c = 'INTRNL', EventParticipantRoleName__c = 'Genentech Employee');
        eprList.add(epr2);
        VDST_EventPrtcpntRole_gne__c epr3 = new VDST_EventPrtcpntRole_gne__c(EventType_gne__c = 'INDVSPND',
            EventParticipantRoleCode_gne__c = 'ATND', EventParticipantRoleName__c = 'Attendee');
        eprList.add(epr3);
        insert eprList;
        List<VDST_EventPrtcpntField_gne__c> prtcpntFieldsToInsert = new List<VDST_EventPrtcpntField_gne__c>();
        VDST_EventPrtcpntField_gne__c epf1 = new VDST_EventPrtcpntField_gne__c(VDST_EventPrtcpntRole__c = epr1.Id,
            FieldLabel_gne__c = 'Participant Profession', FieldName_gne__c = 'ParticipantProfession_gne', IsRequired_gne__c = true, IsVisible_gne__c = true);
        prtcpntFieldsToInsert.add(epf1);
        VDST_EventPrtcpntField_gne__c epf2 = new VDST_EventPrtcpntField_gne__c(VDST_EventPrtcpntRole__c = epr1.Id,
            FieldLabel_gne__c = 'DEA', FieldName_gne__c = 'PRE_INDV.Dea_gne', IsRequired_gne__c = true, IsVisible_gne__c = true);
        prtcpntFieldsToInsert.add(epf2);
        VDST_EventPrtcpntField_gne__c epf3 = new VDST_EventPrtcpntField_gne__c(VDST_EventPrtcpntRole__c = epr1.Id,
            FieldLabel_gne__c = 'Credential', FieldName_gne__c = 'Credential_gne',
            IsRequired_gne__c = true, IsVisible_gne__c = true, DefaultValue_gne__c = 'CredDef');
        prtcpntFieldsToInsert.add(epf3);
        VDST_EventPrtcpntField_gne__c epf4 = new VDST_EventPrtcpntField_gne__c(VDST_EventPrtcpntRole__c = epr1.Id,
            FieldLabel_gne__c = 'Participant Affiliation', FieldName_gne__c = 'ParticipantAffiliation_gne',
            IsRequired_gne__c = true, IsVisible_gne__c = true, DefaultValue_gne__c = 'prvdrCode');
        prtcpntFieldsToInsert.add(epf4);
        VDST_EventPrtcpntField_gne__c epf5 = new VDST_EventPrtcpntField_gne__c(VDST_EventPrtcpntRole__c = epr1.Id,
            FieldLabel_gne__c = 'City', FieldName_gne__c = 'VDST_Address_gne.City_gne',
            IsRequired_gne__c = true, IsVisible_gne__c = true, DefaultValue_gne__c = 'Lublin');
        prtcpntFieldsToInsert.add(epf5);
        VDST_EventPrtcpntField_gne__c epf6 = new VDST_EventPrtcpntField_gne__c(VDST_EventPrtcpntRole__c = epr1.Id,
            FieldLabel_gne__c = 'Participant Contract Status', FieldName_gne__c = 'ParticipantContractStatus_gne',
            IsRequired_gne__c = true, IsVisible_gne__c = true, DefaultValue_gne__c = 'PCS');
        prtcpntFieldsToInsert.add(epf6);
        VDST_EventPrtcpntField_gne__c epf7 = new VDST_EventPrtcpntField_gne__c(FieldName_gne__c = 'hasTrans',
            IsRequired_gne__c = false, IsVisible_gne__c = false, VDST_EventPrtcpntRole__c = epr3.Id);
        prtcpntFieldsToInsert.add(epf7);
        insert prtcpntFieldsToInsert;
        User u = prepareUser(2);
        // Run tests in user context
        System.runAs(u) {
            // Prepare privileges and controller
            VDST_User_gne__c usr = new VDST_User_gne__c(Role_gne__c = 'Provisioner', User_gne__c = u.Id, VDST_Event_Provider__c = ev.LogisticVendor_gne__c);
            insert usr;
            // Run controller
            setEventAndTypeParams(ev.Id, null);
            VDST_EventDetailController edc = new VDST_EventDetailController();
            edc.initData();
            Test.startTest();
            // Test creating Participant - set Role
            edc.prtcpntUtils.addParticipant();
            edc.prtcpntUtils.prtcpnt.evntPrtcpnt.EventParticipantRole_gne__c = epr1.Id;
            // Run changeFields() methods
            edc.prtcpntUtils.changeFields(); // should run another method with true param
            // Test Actual Map
            System.assertNotEquals(edc.prtcpntUtils.actualMap.get('LicenseNumber_gne'), null); // Should set default value
            System.assertEquals(edc.prtcpntUtils.actualMap.get('LicenseNumber_gne').IsRequired_gne__c, false); // Should set default value
            System.assertNotEquals(edc.prtcpntUtils.actualMap.get('Dea_gne'), null); // Should set default value
            System.assertEquals(edc.prtcpntUtils.actualMap.get('Dea_gne').IsRequired_gne__c, true); // Test removing prefix
            // Test setting default values
            System.assertEquals(edc.prtcpntUtils.prtcpnt.evntPrtcpnt.ParticipantAffiliation_gne__c, 'Genentech'); // SHould set actual user group name
            System.assertEquals(edc.prtcpntUtils.prtcpnt.evntPrtcpnt.Credential_gne__c, 'CredDef');
            System.assertEquals(edc.prtcpntUtils.prtcpnt.evntPrtcpnt.ParticipantContractStatus_gne__c, 'PCS');
            System.assertEquals(edc.prtcpntUtils.prtcpnt.evntPrtcpntAddress.City_gne__c, 'Lublin');
            // Test Non-Research exception for transactions
            ev.EventType_gne__c = 'INDVSPND';
            update ev;
            edc = new VDST_EventDetailController();
            edc.initData();
            // Test creating Participant - set Role
            edc.prtcpntUtils.addOrgParticipant();
            edc.prtcpntUtils.prtcpnt.evntPrtcpnt.EventParticipantRole_gne__c = epr3.Id;
            // Set pre-data
            edc.prtcpntUtils.prtcpnt.transactions.get('HONORARIA').transAmount = '12.23';
            edc.prtcpntUtils.prtcpnt.accountType = 'Organization';
            // Test clearing transaction
            edc.prtcpntUtils.changeFields();
            System.assertEquals(edc.prtcpntUtils.prtcpnt.transactions.get('HONORARIA').transAmount, '0.0');
            Test.stopTest();
        }
    }

    /** @date 3/17/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for getPaidTo() method
    */
    @IsTest(SeeAllData=false)
    static void getPaidTo_Test() {
        // Run constructor
        setEventAndTypeParams(null, 'CFF');
        VDST_EventDetailController edc = new VDST_EventDetailController();
        edc.initData();
        Test.startTest();
        // Test getPaidTo() method
        List<SelectOption> gpList = edc.prtcpntUtils.getPaidTo();
        Test.stopTest();
        System.assertEquals(gpList.size(), 2); // Static list
        System.assertEquals(gpList.get(0).getLabel(), 'Individual');
        System.assertEquals(gpList.get(1).getLabel(), 'Organization');
    }

    /** @date 3/17/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for PrtcpntWrapper inner class
    */
    @IsTest(SeeAllData=false)
    static void PrtcpntWrapper_Test() {
        // Prepare data
        VDST_Event_gne__c ev = prepareEvent('CFF');
        VDST_EventPrtcpntRole_gne__c epr = new VDST_EventPrtcpntRole_gne__c(EventType_gne__c = 'CFF',
            EventParticipantRoleCode_gne__c = 'INTRNL', EventParticipantRoleName__c = 'Genentech Employee');
        insert epr;
        VDST_EventPrtcpntField_gne__c epf = new VDST_EventPrtcpntField_gne__c(VDST_EventPrtcpntRole__c = epr.Id,
            FieldLabel_gne__c = 'Contract Status', FieldName_gne__c = 'ParticipantContractStatus_gne', IsRequired_gne__c = true, IsVisible_gne__c = true);
        insert epf;
        List<VDST_Mapping_gne__c> mapsToInsert = new List<VDST_Mapping_gne__c>();
        VDST_Mapping_gne__c map1 = new VDST_Mapping_gne__c(Name = 'NRSPRACTCN', LabelValue_gne__c = 'Nurse Practitioner');
        mapsToInsert.add(map1);
        VDST_Mapping_gne__c map2 = new VDST_Mapping_gne__c(Name = 'USA', LabelValue_gne__c = 'United States');
        mapsToInsert.add(map2);
        VDST_Mapping_gne__c map3 = new VDST_Mapping_gne__c(Name = 'POL', LabelValue_gne__c = 'Poland');
        mapsToInsert.add(map3);
        VDST_Mapping_gne__c map4 = new VDST_Mapping_gne__c(Name = 'JR', LabelValue_gne__c = 'Jr');
        mapsToInsert.add(map4);
        insert mapsToInsert;
        // Run constructor
        setEventAndTypeParams(ev.Id, null);
        VDST_EventDetailController edc = new VDST_EventDetailController();
        edc.initData();
        Test.startTest();
        // Test PrtcpntWrapper
        edc.prtcpntUtils.addParticipant();
        // Test contractStatus getter/setter
        edc.prtcpntUtils.prtcpnt.contractStatus = true;
        System.assertEquals(edc.prtcpntUtils.prtcpnt.evntPrtcpnt.ParticipantContractStatus_gne__c, 'CNTRCTD');
        edc.prtcpntUtils.prtcpnt.contractStatus = false;
        System.assertEquals(edc.prtcpntUtils.prtcpnt.evntPrtcpnt.ParticipantContractStatus_gne__c, 'NTCNTRCTD');
        edc.prtcpntUtils.prtcpnt.evntPrtcpnt.ParticipantContractStatus_gne__c = 'CNTRCTD';
        System.assertEquals(edc.prtcpntUtils.prtcpnt.contractStatus, true);
        edc.prtcpntUtils.prtcpnt.evntPrtcpnt.ParticipantContractStatus_gne__c = 'NTCNTRCTD';
        System.assertEquals(edc.prtcpntUtils.prtcpnt.contractStatus, false);
        System.assertEquals(edc.prtcpntUtils.prtcpnt.Id, null);
        System.assertEquals(edc.prtcpntUtils.prtcpnt.lastModifiedBy, null);
        // System.assertEquals(edc.prtcpntUtils.prtcpnt.lastModifiedDate, null); // null pointer because of format, need to test on edit event
        // Test stateHolder getter
        edc.prtcpntUtils.prtcpnt.evntPrtcpntAddress.StateProvince_gne__c = 'CA';
        System.assertEquals(edc.prtcpntUtils.prtcpnt.stateHolder, 'CA');
        // Test orgStateHolder getter
        edc.prtcpntUtils.prtcpnt.evntOrgAddress.StateProvince_gne__c = 'FL';
        System.assertEquals(edc.prtcpntUtils.prtcpnt.orgStateHolder, 'FL');
        // Test exepnseCodeTransaction getter
        System.assertEquals(edc.prtcpntUtils.prtcpnt.expenseCodeTransaction, ''); // null value so it should be ''
        // Test getProfessionRO()
        edc.prtcpntUtils.prtcpnt.evntPrtcpnt.ParticipantProfession_gne__c = 'NRSPRACTCN';
        System.assertEquals(edc.prtcpntUtils.prtcpnt.getProfessionRO(), 'Nurse Practitioner');
        // Test getParticipantStateLabel()
        edc.prtcpntUtils.prtcpnt.evntPrtcpntAddress.Country_gne__c = 'USA';
        edc.prtcpntUtils.prtcpnt.evntPrtcpntAddress.StateProvince_gne__c = 'CA';
        edc.prtcpntUtils.prtcpnt.evntPrtcpntAddress.StatesNameHolder_gne__c = 'One State';
        System.assertEquals(edc.prtcpntUtils.prtcpnt.getParticipantStateLabel(), 'California');
        edc.prtcpntUtils.prtcpnt.evntPrtcpntAddress.Country_gne__c = 'POL';
        System.assertEquals(edc.prtcpntUtils.prtcpnt.getParticipantStateLabel(), 'One State');
        // Test getParticipantCountryLabel()
        System.assertEquals(edc.prtcpntUtils.prtcpnt.getParticipantCountryLabel(), 'Poland');
        edc.prtcpntUtils.prtcpnt.evntPrtcpntAddress.Country_gne__c = 'USA';
        System.assertEquals(edc.prtcpntUtils.prtcpnt.getParticipantCountryLabel(), 'United States');
        // Test getPrtcpntOrgStateLabel()
        edc.prtcpntUtils.prtcpnt.evntPrtcpntAddress.StateProvince_gne__c = 'CA';
        edc.prtcpntUtils.prtcpnt.evntPrtcpntAddress.StatesNameHolder_gne__c = 'Test State';
        System.assertEquals(edc.prtcpntUtils.prtcpnt.getPrtcpntOrgStateLabel(), 'California');
        edc.prtcpntUtils.prtcpnt.evntPrtcpntAddress.Country_gne__c = 'POL';
        System.assertEquals(edc.prtcpntUtils.prtcpnt.getPrtcpntOrgStateLabel(), 'Test State');
        // Test getPrtcpntOrgCountryLabel()
        System.assertEquals(edc.prtcpntUtils.prtcpnt.getPrtcpntOrgCountryLabel(), 'Poland');
        // Test getLicenseStateLabel();
        edc.prtcpntUtils.prtcpnt.evntPrtcpnt.LicenseState_gne__c = 'CA';
        System.assertEquals(edc.prtcpntUtils.prtcpnt.getLicenseStateLabel(), 'California');
        // Test getSuffixLabel();
        edc.prtcpntUtils.prtcpnt.evntPrtcpnt.Suffix_gne__c = 'JR';
        System.assertEquals(edc.prtcpntUtils.prtcpnt.getSuffixLabel(), 'Jr');
        // Test getOrganizationStateLabel()
        edc.prtcpntUtils.prtcpnt.evntOrgAddress.Country_gne__c = 'USA';
        edc.prtcpntUtils.prtcpnt.evntOrgAddress.StateProvince_gne__c = 'CA';
        edc.prtcpntUtils.prtcpnt.evntOrgAddress.StatesNameHolder_gne__c = 'One State';
        System.assertEquals(edc.prtcpntUtils.prtcpnt.getOrganizationStateLabel(), 'California');
        edc.prtcpntUtils.prtcpnt.evntOrgAddress.Country_gne__c = 'POL';
        System.assertEquals(edc.prtcpntUtils.prtcpnt.getOrganizationStateLabel(), 'One State');
        // Test getOrganizationCountryLabel()
        System.assertEquals(edc.prtcpntUtils.prtcpnt.getOrganizationCountryLabel(), 'Poland');
        edc.prtcpntUtils.prtcpnt.evntOrgAddress.Country_gne__c = 'USA';
        System.assertEquals(edc.prtcpntUtils.prtcpnt.getOrganizationCountryLabel(), 'United States');
        // Test validateBatchFields() method in setValues()
        VDST_EventDetailPrtcpntUtils.PrtcpntWrapper pw = new VDST_EventDetailPrtcpntUtils.PrtcpntWrapper(edc.prtcpntUtils);
        VDST_EventDetailPrtcpntUtils.PrtcpntWrapper clonePw = new VDST_EventDetailPrtcpntUtils.PrtcpntWrapper(edc.prtcpntUtils);
        clonePw.evntPrtcpnt.LicenseNumber_gne__c = 'NO1234';
        clonePw.evntPrtcpnt.Email_gne__c = 'INCORRECT_EMAIL';
        clonePw.evntPrtcpnt.NPI_gne__c = 'INCORRECT_NPI';
        clonePw.evntPrtcpnt.DEA_gne__c = 'INCORRECT_DEA';
        clonePw.evntPrtcpntAddress.Country_gne__c = 'USA';
        clonePw.evntPrtcpntAddress.PostalCode_gne__c = 'UINCORRECT_POSTAL';
        pw.setValues(clonePw);
        System.assertEquals(pw.errorMsgList[2], 'Participant Role field is required');
        System.assertEquals(pw.errorMsgList[3], 'Last Name field is required');
        System.assertEquals(pw.errorMsgList[4], 'First Name field is required');
        System.assertEquals(pw.errorMsgList[8], 'Invalid email format');
        //System.assertEquals(pw.errorMsgList[13], 'Unix ID field is required');
        System.assertEquals(pw.errorMsgList[14], 'Invalid NPI format');
        System.assertEquals(pw.errorMsgList[15], 'Invalid DEA format');
        System.assertEquals(pw.errorMsgList[17], 'License State is required for License Number');
        System.assertEquals(pw.errorMsgList[21], 'Invalid Postal Code format');
        // Check wheather errors dissapear
        clonePw.evntPrtcpnt.EventParticipantRole_gne__c = epr.Id;
        clonePw.evntPrtcpnt.FirstName_gne__c = 'FN';
        clonePw.evntPrtcpnt.LastName_gne__c = 'LN';
        clonePw.evntPrtcpnt.Email_gne__c = 'email@test.com';
        clonePw.evntPrtcpnt.UnixID_gne__c = 'testUnixId';
        clonePw.evntPrtcpnt.NPI_gne__c = '1234567890';
        clonePw.evntPrtcpnt.DEA_gne__c = 'AZ1234567';
        clonePw.evntPrtcpnt.LicenseState_gne__c = 'CA';
        clonePw.evntPrtcpntAddress.PostalCode_gne__c = '12345';
        pw.setValues(clonePw);
        Test.stopTest();
        System.assertEquals(pw.evntPrtcpnt.FirstName_gne__c, 'FN');
        System.assertEquals(pw.errorMsgList[2], '');
        System.assertEquals(pw.errorMsgList[3], '');
        System.assertEquals(pw.errorMsgList[4], '');
        System.assertEquals(pw.errorMsgList[8], '');
        //System.assertEquals(pw.errorMsgList[13], '');
        System.assertEquals(pw.errorMsgList[14], '');
        System.assertEquals(pw.errorMsgList[15], '');
        System.assertEquals(pw.errorMsgList[17], '');
        System.assertEquals(pw.errorMsgList[21], '');
    }

    /** @date 3/18/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for ParticipantTransactionWrapper inner class
    */
    @IsTest(SeeAllData=false)
    static void ParticipantTransactionWrapper_Test() {
        // Run constructor
        setEventAndTypeParams(null, 'ADBOARD');
        VDST_Event_gne__c event = new VDST_Event_gne__c();
        PageReference pageRef           = Page.VDST_EventDetail;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('event','testid');
        pageRef.getParameters().put('type', 'ADBOARD');
        ApexPages.StandardController sc = new ApexPages.standardController(event);
        Test.startTest();
        VDST_EventDetailController edc  = new VDST_EventDetailController();
        edc.initData();
        edc.prtcpntUtils = new VDST_EventDetailPrtcpntUtils('testid');
        Test.stopTest();
        // Test PrtcpntWrapper - go through transaction, because inner class is invisible
        //edc.prtcpntUtils.addParticipant();
        //edc.prtcpntUtils.setPrtcpntUtils();
        //edc.prtcpntUtils.prtcpnt.transactionList = new List<String>{'Test'};
        //edc.prtcpntUtils.prtcpnt.setNewPrtcpntTransactionList();
        //edc.prtcpntUtils.prtcpnt.transactions.get('HCPTRVL').transAmount = '12.23';
        //System.assertEquals(edc.prtcpntUtils.prtcpnt.transactions.get('HCPTRVL').transAmount, '12.23');
        //edc.prtcpntUtils.prtcpnt.transactions.get('HCPTRVL').transAmount = 'XXX'; // should throw exception and change value to 0.00
        //System.assertEquals(edc.prtcpntUtils.prtcpnt.transactions.get('HCPTRVL').transAmount, '0.00');
        //edc.prtcpntUtils.prtcpnt.transactions.get('HCPTRVL').transAmount = '12.21';
        //System.assertEquals(edc.prtcpntUtils.prtcpnt.transactions.get('HCPTRVL').transAmount, '12.21');
        //edc.prtcpntUtils.prtcpnt.transactions.get('HCPTRVL').transAmount = null; // should change value to 0.00
        //System.assertEquals(edc.prtcpntUtils.prtcpnt.transactions.get('HCPTRVL').transAmount, '0.00');
    }

    /** @date 3/18/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for ParticipantAttendanceWrapper inner class
    */
    @IsTest(SeeAllData=false)
    static void ParticipantAttendanceWrapper_Test() {
        // Prepare data
        VDST_Event_gne__c ev = prepareEvent('ADBOARD');
        VDST_Address_gne__c adr = new VDST_Address_gne__c(VDST_Event_gne__c = ev.Id, City_gne__c = 'Lublin');
        insert adr;
        VDST_EventPrtcpntRole_gne__c epr = new VDST_EventPrtcpntRole_gne__c(EventType_gne__c = 'ADBOARD',
            EventParticipantRoleCode_gne__c = 'INTRNL', EventParticipantRoleName__c = 'Genentech Employee');
        insert epr;
        VDST_EventPrtcpntAccnt_gne__c epa = new VDST_EventPrtcpntAccnt_gne__c(VDST_Event_gne__c = ev.Id,
            PartyType_gne__c = 'INDV', FirstName_gne__c = 'John', LastName_gne__c = 'Wall',
            EventParticipantRole_gne__c = epr.Id, VDST_Address_gne__c = adr.Id);
        insert epa;
        List<VDST_EventPrtcpntAttendance_gne__c> epaAttList = [SELECT Id, MealAmount_gne__c, AttendanceStatus_gne__c, ParticipantMealConsumptionStatus_gne__c FROM VDST_EventPrtcpntAttendance_gne__c];
        System.assertEquals(epaAttList.size(), 1);
        epaAttList.get(0).MealAmount_gne__c = 12.23;
        epaAttList.get(0).AttendanceStatus_gne__c = 'DNS';
        epaAttList.get(0).ParticipantMealConsumptionStatus_gne__c = 'NOMLPRVD';
        update epaAttList;
        List<VDST_Mapping_gne__c> mapsToInsert = new List<VDST_Mapping_gne__c>();
        VDST_Mapping_gne__c map1 = new VDST_Mapping_gne__c(Name = 'NOMLPRVD', LabelValue_gne__c = 'No Meal Provided');
        mapsToInsert.add(map1);
        insert mapsToInsert;
        // Run constructor and methods
        setEventAndTypeParams(ev.Id, null);
        VDST_EventDetailController edc = new VDST_EventDetailController();
        edc.initData();
        Test.startTest();
        edc.prtcpntUtils.prtcpntId = epa.Id;
        edc.prtcpntUtils.editParticipant();
        edc.prtcpntUtils.onlySaveParticipant();
        Test.stopTest();
        // Test PrtcpntWrapper
        System.debug(edc.prtcpntUtils.prtcpnt.prtcpntAtt);
        System.assertEquals(edc.prtcpntUtils.prtcpnt.prtcpntAtt.size(), 1);
        // Test getters/setters
        System.assertEquals(edc.prtcpntUtils.prtcpnt.prtcpntAtt.get(0).attCheckbox, false); // DND should return false
        System.assertEquals(edc.prtcpntUtils.prtcpnt.prtcpntAtt.get(0).mealField, 'NOMLPRVD'); // should return code as it is
        System.assertEquals(edc.prtcpntUtils.prtcpnt.prtcpntAtt.get(0).getParticipantMealConsumptionStatus_gne(), 'No Meal Provided'); // should return label for MCS
        edc.prtcpntUtils.prtcpnt.prtcpntAtt.get(0).attCheckbox = true;
        System.assertEquals(edc.prtcpntUtils.prtcpnt.prtcpntAtt.get(0).prtcpntAtt.AttendanceStatus_gne__c, 'ATND');
        System.assertEquals(edc.prtcpntUtils.prtcpnt.prtcpntAtt.get(0).attCheckbox, true);
        System.assertEquals(edc.prtcpntUtils.prtcpnt.prtcpntAtt.get(0).prtcpntAtt.ParticipantMealConsumptionStatus_gne__c, 'CONSUMED');
        System.assertEquals(edc.prtcpntUtils.prtcpnt.prtcpntAtt.get(0).mealField, 'CONSUMED');
        edc.prtcpntUtils.prtcpnt.prtcpntAtt.get(0).attCheckbox = false;
        System.assertEquals(edc.prtcpntUtils.prtcpnt.prtcpntAtt.get(0).prtcpntAtt.AttendanceStatus_gne__c, 'DNS');
        System.assertEquals(edc.prtcpntUtils.prtcpnt.prtcpntAtt.get(0).attCheckbox, false);
        System.assertEquals(edc.prtcpntUtils.prtcpnt.prtcpntAtt.get(0).prtcpntAtt.ParticipantMealConsumptionStatus_gne__c, 'NOTAPPLI');
        System.assertEquals(edc.prtcpntUtils.prtcpnt.prtcpntAtt.get(0).mealField, 'NOTAPPLI');
        edc.prtcpntUtils.prtcpnt.prtcpntAtt.get(0).prtcpntAtt.AttendanceStatus_gne__c = 'DNS';
        edc.prtcpntUtils.prtcpnt.prtcpntAtt.get(0).mealField = 'NOMLPRVD';
        System.assertEquals(edc.prtcpntUtils.prtcpnt.prtcpntAtt.get(0).prtcpntAtt.ParticipantMealConsumptionStatus_gne__c, 'NOTAPPLI'); // should change to NOTAPPLI for DNS
        edc.prtcpntUtils.prtcpnt.prtcpntAtt.get(0).prtcpntAtt.AttendanceStatus_gne__c = 'ATND';
        edc.prtcpntUtils.prtcpnt.prtcpntAtt.get(0).mealField = 'NOMLPRVD';
        System.assertEquals(edc.prtcpntUtils.prtcpnt.prtcpntAtt.get(0).prtcpntAtt.ParticipantMealConsumptionStatus_gne__c, 'NOMLPRVD');
        edc.prtcpntUtils.prtcpnt.prtcpntAtt.get(0).prtcpntAtt.AttendanceStatus_gne__c = null;
        System.assertEquals(edc.prtcpntUtils.prtcpnt.prtcpntAtt.get(0).attCheckbox, true);
        System.assertEquals(edc.prtcpntUtils.prtcpnt.prtcpntAtt.get(0).prtcpntAtt.AttendanceStatus_gne__c, 'ATND');
    }

    /** @date 3/18/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for attPrtcpntList() getter method
    */
    @IsTest(SeeAllData=false)
    static void attPrtcpntList_Test() {
        // Prepare data
        VDST_Event_gne__c ev = prepareEvent('ADBOARD');
        ev.EventStartDate_gne__c = Date.today().addDays(-3);
        update ev;
        VDST_Address_gne__c adr = new VDST_Address_gne__c(VDST_Event_gne__c = ev.Id, City_gne__c = 'Lublin');
        insert adr;
        VDST_EventPrtcpntRole_gne__c epr = new VDST_EventPrtcpntRole_gne__c(EventType_gne__c = 'ADBOARD',
            EventParticipantRoleCode_gne__c = 'INTRNL', EventParticipantRoleName__c = 'Genentech Employee');
        insert epr;
        VDST_EventPrtcpntAccnt_gne__c epa = new VDST_EventPrtcpntAccnt_gne__c(VDST_Event_gne__c = ev.Id,
            PartyType_gne__c = 'INDV', FirstName_gne__c = 'John', LastName_gne__c = 'Wall',
            EventParticipantRole_gne__c = epr.Id, VDST_Address_gne__c = adr.Id);
        insert epa;
        Test.startTest();
        // Run constructor and methods
        setEventAndTypeParams(ev.Id, null);
        VDST_EventDetailController edc = new VDST_EventDetailController();
        edc.initData();
        edc.prtcpntUtils.prtcpntId = epa.Id;
        edc.prtcpntUtils.editParticipant();
        // Test method - open Attendance list and close participant list
        edc.prtcpntUtils.initAttendances();
        System.assertNotEquals(edc.prtcpntUtils.attPrtcpntList, null);
        System.assertEquals(edc.prtcpntUtils.attPrtcpntList.size(), 1);
        System.assertEquals(edc.prtcpntUtils.showParticipantList, false);
        // only save data, but not closing/opening dialog box
        edc.prtcpntUtils.onlySaveAttandance(); //should also run saveAttandanceProxy() and saveAttandance()
        System.assertEquals(edc.prtcpntUtils.showParticipantList, false);
        System.assertEquals(edc.prtcpntUtils.prtcpntListMsg, 'Attendance data has been saved.');
        // should close attandance box and open participant list
        edc.prtcpntUtils.saveAttandanceAndClose(); // same as above but also close list
        System.assertEquals(edc.prtcpntUtils.showParticipantList, true);
        // reopen to test other methods
        edc.prtcpntUtils.initAttendances();
        System.assertEquals(edc.prtcpntUtils.showParticipantList, false);
        // canceling window without saving
        edc.prtcpntUtils.cancelAttandance();
        System.assertEquals(edc.prtcpntUtils.showParticipantList, true);
        System.assertEquals(edc.prtcpntUtils.prtcpntListMsg, '');
        Test.stopTest();
    }

    /** @date 2/11/2014
    * @Author Pawel Sprysak
    * @description Internal method for preparing user data
    */
    public static User prepareUser(Integer userNo) {
        Profile p = [SELECT id FROM Profile WHERE Name='Standard User' LIMIT 1];
        if(userNo == 1) {
            return new User(alias = 'gssptest', email='gssptestuser@gene.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles',
                username='gssptestuser@gene.com');
        } else if(userNo == 2) {
            return new User(alias = 'gssptes2', email='gssptestuser2@gene.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles',
                username='gssptestuser2@gene.com');
        }
        return null;
    }

    /** @date 2/11/2014
    * @Author Pawel Sprysak
    * @description Internal method for setting page parameters
    */
    public static void setEventAndTypeParams(String evId, String evType) {
        ApexPages.currentPage().getParameters().put('event', evId);
        ApexPages.currentPage().getParameters().put('type', evType);
    }

    /** @date 2/25/2014
    * @Author Pawel Sprysak
    * @description Internal method for preparing event data
    */
    public static VDST_Event_gne__c prepareEvent(String eventType) {
        VDST_EventProvider_gne__c ep = new VDST_EventProvider_gne__c(VendorName_gne__c = 'Genentech', VendorCode_gne__c = 'GNE');
        insert ep;
        VDST_Event_gne__c ev = new VDST_Event_gne__c(CurrentStatus_gne__c = 'PENDING',
            CurrentStatusDate_gne__c = Date.today(), EventType_gne__c = eventType, LogisticVendor_gne__c = ep.Id,
            EventStartDate_gne__c = Date.today().addDays(-2), EventEndDate_gne__c = Date.today().addDays(-2));
        insert ev;
        return ev;
    }
}