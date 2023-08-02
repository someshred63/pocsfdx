/** @date 3/31/2014
* @Author Pawel Sprysak
* @description Test Class for VDST_UpdateAVSummary_gne TRIGGER
*/
@isTest
private class VDST_UpdateAVSummary_gne_Test {
    @testSetup
    static void testSetup() {
        System.RunAs(AGS_ST_TestUtils.createUser('GNE-AGS-CCO-Analyst')) {
            AGS_ST_TestUtils.createDisputes('Submitted');
            AGS_ST_TestUtils.createExpenseProductsInteractions(AGS_ST_TestUtils.createBrands(), [SELECT Id FROM AGS_Spend_Expense_Transaction_gne__c].Id);
        }
    }
    /** @date 3/31/2014
    * @Author Pawel Sprysak
    * @description Test Method for Trigger BEFORE UPDATE 
    */
    @IsTest(SeeAllData=false)
    static void beforeUpdate_Test() {
        // Prepare data
        VDST_Event_gne__c ev = new VDST_Event_gne__c(CurrentStatus_gne__c = 'PENDING', 
            CurrentStatusDate_gne__c = Date.today(), EventType_gne__c = 'ADBOARD',
            EventStartDate_gne__c = Date.today().addDays(-2), EventEndDate_gne__c = Date.today().addDays(-2));
        insert ev;

        // Pre-test
        ev.VendorEventID_gne__c = 'VendID';
        ev.GNE_EventID_gne__c = 'GneID';
        update ev;
        VDST_Event_gne__c ev1 = [SELECT VendorEventID_gne__c, GNE_EventID_gne__c FROM VDST_Event_gne__c];
        System.assertEquals(ev1.VendorEventID_gne__c, 'VendID');
        System.assertEquals(ev1.GNE_EventID_gne__c, 'GneID');

        // Test changing status to 'DROPPED'
        ev.CurrentStatus_gne__c = 'DROPPED';
        update ev;
        VDST_Event_gne__c ev2 = [SELECT VendorEventID_gne__c, GNE_EventID_gne__c FROM VDST_Event_gne__c];
        System.assertNotEquals(ev2.VendorEventID_gne__c, 'VendID');
        System.assertNotEquals(ev2.GNE_EventID_gne__c, 'GneID');
        System.assertNotEquals(ev2.VendorEventID_gne__c, null);
        System.assertNotEquals(ev2.GNE_EventID_gne__c, null);
        System.assertNotEquals(ev2.VendorEventID_gne__c, 'VendID_DR');
        System.assertNotEquals(ev2.GNE_EventID_gne__c, 'GneID_DR');
        System.assert(ev2.VendorEventID_gne__c.startsWith('VendID_DR'));
        System.assert(ev2.GNE_EventID_gne__c.startsWith('GneID_DR'));
    }

    /** @date 3/31/2014
    * @Author Pawel Sprysak
    * @description Test Method for Trigger for Creating Event Date and Event Date Transactino Data
    */
    @IsTest(SeeAllData=false)
    static void prepareEventDateData_Test() {
        // Prepare data
        VDST_Event_gne__c ev = new VDST_Event_gne__c(CurrentStatus_gne__c = 'PENDING', 
            CurrentStatusDate_gne__c = Date.today(), EventType_gne__c = 'ADBOARD',
            EventEndDate_gne__c = Date.today().addDays(-2));
        try {
            insert ev;
        } catch (Exception ex) {
            System.debug(loggingLevel.Error, '*** ex.getMessage(): ' + ex.getMessage());
            Boolean cont = ex.getMessage().contains('EventStartDate or EventEndDate are required.');
            System.assert(true, cont);
        }
        ev.EventStartDate_gne__c = Date.today();
        try {
            insert ev;
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains('Event Start Date must be earlier than Event End Date'));
        }
        ev.EventStartDate_gne__c = Date.today().addDays(-12);
        try {
            insert ev;
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains('Event End Date could be max 4 days after Event Start Date'));
        }
        ev.EventStartDate_gne__c = Date.today().addDays(-3);
        insert ev;

        // Test Event Date / Event Date Transaction Creation
        List<VDST_EventDate_gne__c> edList = [SELECT Id FROM VDST_EventDate_gne__c];
        List<VDST_EventDateTransaction_gne__c> edtList = [SELECT Id FROM VDST_EventDateTransaction_gne__c];
        System.assertEquals(edList.size(), 2);
        System.assertEquals(edtList.size(), 2);

        // Add one day
        ev.EventStartDate_gne__c = Date.today().addDays(-4);
        update ev;
        edList = [SELECT Id FROM VDST_EventDate_gne__c];
        edtList = [SELECT Id FROM VDST_EventDateTransaction_gne__c];
        System.assertEquals(edList.size(), 3);
        System.assertEquals(edtList.size(), 3);

        // Remove one day
        ev.EventEndDate_gne__c = Date.today().addDays(-3);
        update ev;
        edList = [SELECT Id FROM VDST_EventDate_gne__c];
        edtList = [SELECT Id FROM VDST_EventDateTransaction_gne__c];
        System.assertEquals(edList.size(), 2);
        System.assertEquals(edtList.size(), 2);

        // Move whole date range
        ev.EventStartDate_gne__c = Date.today().addDays(-13);
        ev.EventEndDate_gne__c = Date.today().addDays(-10);
        update ev;
        edList = [SELECT Id FROM VDST_EventDate_gne__c];
        edtList = [SELECT Id FROM VDST_EventDateTransaction_gne__c];
        System.assertEquals(edList.size(), 4);
        System.assertEquals(edtList.size(), 4);
    }

    /** @date 3/31/2014
    * @Author Pawel Sprysak
    * @description Test Method for Trigger AFTER UPDATE for updating data according to Event data changes (Test changing TotPlanAttCntUser_gne__c field)
    */
    @IsTest(SeeAllData=false)
    static void updateValuesAfterChangingEventData1_Test() {
        // Prepare data - CFF
        VDST_Event_gne__c ev = new VDST_Event_gne__c(CurrentStatus_gne__c = 'PENDING', 
            CurrentStatusDate_gne__c = Date.today(), EventType_gne__c = 'CFF',
            EventStartDate_gne__c = Date.today().addDays(-2), EventEndDate_gne__c = Date.today().addDays(-2));
        insert ev;
        VDST_EventPrtcpntRole_gne__c epr = new VDST_EventPrtcpntRole_gne__c(EventType_gne__c = 'CFF', 
            EventParticipantRoleCode_gne__c = 'ATND', EventParticipantRoleName__c = 'Attendee');
        insert epr;
        List<VDST_EventPrtcpntAccnt_gne__c> epaList = new List<VDST_EventPrtcpntAccnt_gne__c>();
        VDST_EventPrtcpntAccnt_gne__c epa1 = new VDST_EventPrtcpntAccnt_gne__c(EventParticipantRole_gne__c = epr.Id, 
            VDST_Event_gne__c = ev.Id, PartyType_gne__c = 'INDV');
        epaList.add(epa1);
        insert epaList; // TotBiggerPlanAttCnt_gne__c should be equal 2
        List<VDST_EventDateTransaction_gne__c> edtList = [SELECT Id, EventDateTransactionAmount_gne__c FROM VDST_EventDateTransaction_gne__c];
        for(VDST_EventDateTransaction_gne__c edt : edtList) {
            edt.EventDateTransactionAmount_gne__c = 100;
        }
        update edtList;

        // Pre-test
        List<VDST_EventPrtcpntAttendance_gne__c> epaList1 = [SELECT Id, MealAmount_gne__c FROM VDST_EventPrtcpntAttendance_gne__c];
        System.assertEquals(epaList1.size(), 1);
        System.assertEquals(epaList1.get(0).MealAmount_gne__c, 100);

        // START Test for changing TotPlanAttCntUser_gne__c
        ev.TotPlanAttCntUser_gne__c = 4;
        update ev;
        epaList1 = [SELECT Id, MealAmount_gne__c FROM VDST_EventPrtcpntAttendance_gne__c];
        System.assertEquals(epaList1.size(), 1);
        System.assertEquals(epaList1.get(0).MealAmount_gne__c, 25);
    }

    /** @date 3/31/2014
    * @Author Pawel Sprysak
    * @description Test Method for Trigger AFTER UPDATE for updating data according to Event data changes (Test changing ItemAmount_gne__c field for Single Spends)
    */
    @IsTest(SeeAllData=false)
    static void updateValuesAfterChangingEventData2_Test() {
        // Prepare data - CFF
        VDST_Event_gne__c ev = new VDST_Event_gne__c(CurrentStatus_gne__c = 'PENDING', 
            CurrentStatusDate_gne__c = Date.today(), EventType_gne__c = 'ECOUPON', ItemAmount_gne__c = 10,
            EventStartDate_gne__c = Date.today().addDays(-2), EventEndDate_gne__c = Date.today().addDays(-2));
        insert ev;
        VDST_EventPrtcpntRole_gne__c epr = new VDST_EventPrtcpntRole_gne__c(EventType_gne__c = 'ECOUPON', 
            EventParticipantRoleCode_gne__c = 'ATND', EventParticipantRoleName__c = 'Attendee');
        insert epr;
        List<VDST_EventPrtcpntAccnt_gne__c> epaList = new List<VDST_EventPrtcpntAccnt_gne__c>();
        VDST_EventPrtcpntAccnt_gne__c epa1 = new VDST_EventPrtcpntAccnt_gne__c(EventParticipantRole_gne__c = epr.Id, 
            VDST_Event_gne__c = ev.Id, PartyType_gne__c = 'INDV');
        epaList.add(epa1);
        insert epaList; // TotBiggerPlanAttCnt_gne__c should be equal 2
        VDST_PrtcpntTransaction_gne__c pt = new VDST_PrtcpntTransaction_gne__c(ItemQuantity_gne__c = 2, 
            TransactionAmount_gne__c = 20, VDST_EventPrtcpntAccnt_gne__c = epa1.Id, VDST_PaidToParty_gne__c = epa1.Id);
        insert pt;

        // Pre-test
        List<VDST_PrtcpntTransaction_gne__c> epaList1 = [SELECT Id, ItemQuantity_gne__c, TransactionAmount_gne__c FROM VDST_PrtcpntTransaction_gne__c];
        System.assertEquals(epaList1.size(), 1);
        System.assertEquals(epaList1.get(0).ItemQuantity_gne__c, 2);
        System.assertEquals(epaList1.get(0).TransactionAmount_gne__c, 20);

        // START Test for changing TotPlanAttCntUser_gne__c
        ev.ItemAmount_gne__c = 30;
        update ev;
        epaList1 = [SELECT Id, ItemQuantity_gne__c, TransactionAmount_gne__c FROM VDST_PrtcpntTransaction_gne__c];
        System.assertEquals(epaList1.size(), 1);
        System.assertEquals(epaList1.get(0).ItemQuantity_gne__c, 2);
        System.assertEquals(epaList1.get(0).TransactionAmount_gne__c, 60);

        // Test for Medical Writing
        ev.EventType_gne__c = 'MEDWRTG';
        ev.ItemAmount_gne__c = 50;
        update ev;
        epaList1 = [SELECT Id, ItemQuantity_gne__c, TransactionAmount_gne__c FROM VDST_PrtcpntTransaction_gne__c];
        System.assertEquals(epaList1.size(), 1);
        System.assertEquals(epaList1.get(0).ItemQuantity_gne__c, 2);
        System.assertEquals(epaList1.get(0).TransactionAmount_gne__c, 50);
    }

    /** @date 3/31/2014
    * @Author Pawel Sprysak
    * @description Test Method for Trigger AFTER UPDATE for updating data according to Event data changes (Test changing ItemAmount_gne__c OR ResearchPaymentTypeCode_gne__c field for Research)
    */
    @IsTest(SeeAllData=false)
    static void updateValuesAfterChangingEventData3_Test() {
        // Prepare data - CFF
        VDST_Event_gne__c ev = new VDST_Event_gne__c(CurrentStatus_gne__c = 'PENDING',
            CurrentStatusDate_gne__c = Date.today(), EventType_gne__c = 'RSCH', ItemAmount_gne__c = 10,
            EventStartDate_gne__c = Date.today().addDays(-2), EventEndDate_gne__c = Date.today().addDays(-2));
        insert ev;
        VDST_EventPrtcpntRole_gne__c epr = new VDST_EventPrtcpntRole_gne__c(EventType_gne__c = 'RSCH', 
            EventParticipantRoleCode_gne__c = 'ATND', EventParticipantRoleName__c = 'Attendee');
        insert epr;
        List<VDST_EventPrtcpntAccnt_gne__c> epaList = new List<VDST_EventPrtcpntAccnt_gne__c>();
        VDST_EventPrtcpntAccnt_gne__c epa1 = new VDST_EventPrtcpntAccnt_gne__c(EventParticipantRole_gne__c = epr.Id, 
            VDST_Event_gne__c = ev.Id, PartyType_gne__c = 'INDV');
        epaList.add(epa1);
        insert epaList; // TotBiggerPlanAttCnt_gne__c should be equal 2
        VDST_PrtcpntTransaction_gne__c pt = new VDST_PrtcpntTransaction_gne__c(TransactionAmount_gne__c = 20,
            VDST_EventPrtcpntAccnt_gne__c = epa1.Id, VDST_PaidToParty_gne__c = epa1.Id, TransactionTypeCode_gne__c = null);
        insert pt;

        // Pre-test
        List<VDST_PrtcpntTransaction_gne__c> epaList1 = [SELECT Id, TransactionAmount_gne__c, TransactionTypeCode_gne__c FROM VDST_PrtcpntTransaction_gne__c];
        System.assertEquals(epaList1.size(), 1);
        System.assertEquals(epaList1.get(0).TransactionTypeCode_gne__c, null);
        System.assertEquals(epaList1.get(0).TransactionAmount_gne__c, 20);

        // Test for chaning Item Amount
        ev.ItemAmount_gne__c = 30;
        update ev;
        epaList1 = [SELECT Id, TransactionAmount_gne__c, TransactionTypeCode_gne__c FROM VDST_PrtcpntTransaction_gne__c];
        System.assertEquals(epaList1.size(), 1);
        System.assertEquals(epaList1.get(0).TransactionTypeCode_gne__c, 'RSCH');
        System.assertEquals(epaList1.get(0).TransactionAmount_gne__c, 30);

        // Test for changint Research Payment Code
        ev.ResearchPaymentTypeCode_gne__c = 'PRECLINICAL';
        update ev;
        epaList1 = [SELECT Id, TransactionAmount_gne__c, TransactionTypeCode_gne__c FROM VDST_PrtcpntTransaction_gne__c];
        System.assertEquals(epaList1.size(), 1);
        System.assertEquals(epaList1.get(0).TransactionTypeCode_gne__c, 'PRECLINCL');
        System.assertEquals(epaList1.get(0).TransactionAmount_gne__c, 30);
    }

    /** @date 3/31/2014
    * @Author Pawel Sprysak
    * @description Test Method for Trigger for Update AV transaction value after changing AV on Event
    */
    @IsTest(SeeAllData=false)
    static void checkAVUpdate_Test() {
        // Prepare data
        VDST_EventField_gne__c ef = new VDST_EventField_gne__c(EventStatus_gne__c = 'Transactions',
            FieldName_gne__c = 'VENUEAV', EventType_gne__c = 'ADBOARD');
        insert ef;

        // Test if Event Field is not created for this Event Type
        VDST_Event_gne__c ev1 = new VDST_Event_gne__c(CurrentStatus_gne__c = 'PENDING', 
            CurrentStatusDate_gne__c = Date.today(), EventType_gne__c = 'CFF',
            EventStartDate_gne__c = Date.today().addDays(-2), EventEndDate_gne__c = Date.today().addDays(-2));
        insert ev1;
        List<VDST_EventTransactionSummary_gne__c> etsList1 = [SELECT Id FROM VDST_EventTransactionSummary_gne__c WHERE VDST_Event_gne__c = :ev1.Id AND EventTransactionTypeCode_gne__c = 'VENUEAV'];
        System.assertEquals(etsList1.size(), 0);

        // Test if Event Field is not created for this Event Type
        VDST_Event_gne__c ev2 = new VDST_Event_gne__c(CurrentStatus_gne__c = 'PENDING', 
            CurrentStatusDate_gne__c = Date.today(), EventType_gne__c = 'ADBOARD',
            EventStartDate_gne__c = Date.today().addDays(-2), EventEndDate_gne__c = Date.today().addDays(-2));
        insert ev2;
        List<VDST_EventTransactionSummary_gne__c> etsList2 = [SELECT EventTransactionAmount_gne__c FROM VDST_EventTransactionSummary_gne__c WHERE VDST_Event_gne__c = :ev2.Id AND EventTransactionTypeCode_gne__c = 'VENUEAV'];
        System.assertEquals(etsList2.size(), 1);
        System.assertEquals(etsList2.get(0).EventTransactionAmount_gne__c, 0);

        // Test update value
        ev2.TotalAudioVisual_gne__c = 12.23;
        update ev2;
        List<VDST_EventTransactionSummary_gne__c> etsList3 = [SELECT EventTransactionAmount_gne__c FROM VDST_EventTransactionSummary_gne__c WHERE VDST_Event_gne__c = :ev2.Id AND EventTransactionTypeCode_gne__c = 'VENUEAV'];
        System.assertEquals(etsList3.size(), 1);
        System.assertEquals(etsList3.get(0).EventTransactionAmount_gne__c, 12.23);
    }

    @IsTest
    static void beforeUpdateInsert_shouldCreateDisputeIfStatusIsClosed() {

        // GIVEN
        User ccoAnalyst = [SELECT Id FROM User WHERE email = 'aggstestuser@gene.com'];
        System.RunAs(ccoAnalyst) {

            AGS_Spend_Expense_Transaction_gne__c testTransaction = [SELECT Id, Source_Transaction_ID_gne__c, LogicalDeleteFlag_gne__c , Allocated_Transaction_Amount_gne__c, Form_Of_Payment_gne__c, Nature_Of_Payment_gne__c,
            (SELECT LogicalDeleteFlag__c, AGS_Brand_gne__r.Brand_Name__c FROM AGS_expense_products_intercations1__r) FROM AGS_Spend_Expense_Transaction_gne__c LIMIT 1];

            AGS_Spend_Expense_Transaction_gne__c testTransaction2 = new AGS_Spend_Expense_Transaction_gne__c(
                Allocated_Transaction_Amount_gne__c = 10,
                Event_Date_gne__c                   = Date.today(),
                Event_ID_gne__c                     = 'EventZ',
                Form_Of_Payment_gne__c              = 'Cash',
                Home_Payment_ID_gne__c              = 'HOMEID00001_NR2',
                LogicalDeleteFlag_gne__c            = false,
                Nature_Of_Payment_gne__c            = 'Consulting Fee',
                Primary_Recipient_gne__c            = [SELECT ID FROM AGS_CCO_Case_Recipient_gne__c].Id,
                Report_Code_gne__c                  = 'XC_MON',
                SCh_Category_gne__c                 = 'Category',
                Source_System_Code_gne__c           = 'SAPBW',
                Source_Transaction_Amount_gne__c    = 5.0,
                Source_Transaction_ID_gne__c        = 'EventZ',
                Study_Name_gne__c                   = 'StudyName',
                Research_Pymt_Typ_Cd_gne__c         = 'NON-CLINICAL'
            );
            insert testTransaction2;

            VDST_Event_gne__c newEvent = new VDST_Event_gne__c(CurrentStatus_gne__c = 'PENDING', VendorEventID_gne__c = 'testVendorId',
            CurrentStatusDate_gne__c = Date.today(), EventType_gne__c = 'RSCH', EventStartDate_gne__c = Date.today().addDays(-2), EventEndDate_gne__c = Date.today().addDays(-2), TransactionID_gne__c = testTransaction.Source_Transaction_ID_gne__c,
            SourceTransactionID_gne__c = testTransaction.Source_Transaction_ID_gne__c);
            insert newEvent;

            VDST_Event_gne__c newEvent2 = new VDST_Event_gne__c(CurrentStatus_gne__c = 'PENDING', VendorEventID_gne__c = 'testVendorId2', CurrentStatusDate_gne__c = Date.today(), EventType_gne__c = 'INDVSPND', EventStartDate_gne__c = Date.today().addDays(-2), EventEndDate_gne__c = Date.today().addDays(-2), TransactionID_gne__c = testTransaction2.Source_Transaction_ID_gne__c,
            SourceTransactionID_gne__c = testTransaction2.Source_Transaction_ID_gne__c);
            insert newEvent2;

            String orgBrands = '';
            for (AGS_Expense_Products_Interaction__c spendBrand : testTransaction.AGS_expense_products_intercations1__r) {
                orgBrands += spendBrand.AGS_Brand_gne__r.Brand_Name__c + ',';
            }

            AGS_ST_DisputeManagement_gne__c existingDisputeManagement = [SELECT Internal_Status_gne__c, External_Status_gne__c FROM AGS_ST_DisputeManagement_gne__c];
            System.assertEquals(false, testTransaction.LogicalDeleteFlag_gne__c );

            //WHEN
            newEvent.CurrentStatus_gne__c = 'CLOSED';
            newEvent2.CurrentStatus_gne__c = 'CLOSED';
            update newEvent;
            update newEvent2;

            //THEN
            AGS_ST_DisputeManagement_gne__c newDisputeManagement = [SELECT Do_Not_Report_Flag_gne__c, AGS_Spend_Expense_Transaction_gne__c, Internal_Status_gne__c, Amount_gne__c, Drug_Name_gne__c, Form_Of_Payment_gne__c, Nature_Of_Payment_gne__c, External_Status_gne__c, OwnerId, Dispute_Resolver_gne__c, Preferred_communication_value_gne__c
                    FROM AGS_ST_DisputeManagement_gne__c WHERE Home_Payment_ID_gne__c = 'HOMEID00001_NR' AND Id != :existingDisputeManagement.id];

            AGS_ST_DisputeManagement_gne__c newDisputeManagement2 = [SELECT Do_Not_Report_Flag_gne__c, AGS_Spend_Expense_Transaction_gne__c, Internal_Status_gne__c, Amount_gne__c, Drug_Name_gne__c, Form_Of_Payment_gne__c, Nature_Of_Payment_gne__c, External_Status_gne__c, OwnerId, Dispute_Resolver_gne__c, Preferred_communication_value_gne__c
                    FROM AGS_ST_DisputeManagement_gne__c WHERE Home_Payment_ID_gne__c = 'HOMEID00001_NR2'];

            AGS_ST_DisputeResolver_gne__c resolver = [SELECT Id FROM AGS_ST_DisputeResolver_gne__c WHERE Id = :newDisputeManagement.Dispute_Resolver_gne__c];

            AGS_ST_DisputeResolver_gne__c resolver2 = [SELECT Id FROM AGS_ST_DisputeResolver_gne__c WHERE Id = :newDisputeManagement2.Dispute_Resolver_gne__c];

            System.assertEquals(3, [SELECT COUNT() FROM AGS_ST_DisputeManagement_gne__c]);
            System.assertEquals(testTransaction.Id, newDisputeManagement.AGS_Spend_Expense_Transaction_gne__c);
            System.assertEquals(testTransaction2.Id, newDisputeManagement2.AGS_Spend_Expense_Transaction_gne__c);
            System.assertEquals('Resolved With Correction', newDisputeManagement.Internal_Status_gne__c);
            System.assertEquals('Resolved', newDisputeManagement.External_Status_gne__c);
            System.assertEquals(testTransaction.Allocated_Transaction_Amount_gne__c, newDisputeManagement.Amount_gne__c);
            System.assertEquals(testTransaction2.Allocated_Transaction_Amount_gne__c, newDisputeManagement2.Amount_gne__c);
            System.assertEquals(orgBrands.substringBeforeLast(','), newDisputeManagement.Drug_Name_gne__c);
            System.assertEquals(true, newDisputeManagement.Do_Not_Report_Flag_gne__c);

            System.assertEquals(testTransaction.Form_Of_Payment_gne__c, newDisputeManagement.Form_Of_Payment_gne__c);
            System.assertEquals(testTransaction2.Form_Of_Payment_gne__c, newDisputeManagement2.Form_Of_Payment_gne__c);
            System.assertEquals(testTransaction.Nature_Of_Payment_gne__c, newDisputeManagement.Nature_Of_Payment_gne__c);
            System.assertEquals(resolver.Id, newDisputeManagement.Dispute_Resolver_gne__c);
            System.assertEquals(resolver2.Id, newDisputeManagement2.Dispute_Resolver_gne__c);
            System.assertEquals(UserInfo.getUserId(), newDisputeManagement.OwnerId);
            System.assertEquals(UserInfo.getUserEmail(), newDisputeManagement.Preferred_communication_value_gne__c);

            testTransaction = [SELECT LogicalDeleteFlag_gne__c    FROM AGS_Spend_Expense_Transaction_gne__c LIMIT 1];
            System.assertEquals(true, testTransaction.LogicalDeleteFlag_gne__c);

            AGS_Expense_Products_Interaction__c[] relatedProductInteractions = [SELECT LogicalDeleteFlag__c FROM AGS_Expense_Products_Interaction__c];
            System.assertEquals(3, relatedProductInteractions.size());
            for (AGS_Expense_Products_Interaction__c epi : relatedProductInteractions) {
                System.assertEquals(true, epi.LogicalDeleteFlag__c);
            }

            AGS_ST_Dispute_Note_and_Attachment_gne__c newDmNote = [SELECT Id FROM AGS_ST_Dispute_Note_and_Attachment_gne__c WHERE AGS_ST_Dispute_Management_gne__c = :newDisputeManagement.Id];

            AGS_ST_Dispute_Note_and_Attachment_gne__c newDmNote2 = [SELECT Id FROM AGS_ST_Dispute_Note_and_Attachment_gne__c WHERE AGS_ST_Dispute_Management_gne__c = :newDisputeManagement.Id];

            Note newNote = [SELECT body, Title FROM Note WHERE ParentId = :newDmNote.Id];
            Note newNote2 = [SELECT body, Title FROM Note WHERE ParentId = :newDmNote2.Id];
            System.assertEquals('testVendorId', newNote.body);
            System.assertEquals('HCP Dispute Note', newNote.Title);

            System.assertEquals('testVendorId', newNote2.body);
            System.assertEquals('HCP Dispute Note', newNote2.Title);

            System.assertEquals(3, [SELECT COUNT() FROM AGS_ST_Dispute_List_gne__c]);

            newEvent = [SELECT AGS_ST_Dispute_Management_gne__c FROM VDST_Event_gne__c WHERE Id = :newEvent.Id];
            System.assertEquals(newDisputeManagement.Id, newEvent.AGS_ST_Dispute_Management_gne__c);

            newEvent2 = [SELECT AGS_ST_Dispute_Management_gne__c FROM VDST_Event_gne__c WHERE Id = :newEvent2.Id];
            System.assertEquals(newDisputeManagement2.Id, newEvent2.AGS_ST_Dispute_Management_gne__c);
        }
    }

    @IsTest
    static void beforeUpdateInsert_shouldNotCreateDisputeIfTransactionIsDisputed() {
        User ccoAnalyst = [SELECT Id FROM User WHERE email = 'aggstestuser@gene.com'];
        System.RunAs(ccoAnalyst) {
            // GIVEN
            AGS_Spend_Expense_Transaction_gne__c testTransaction = [SELECT Id, Source_Transaction_ID_gne__c, LogicalDeleteFlag_gne__c , Allocated_Transaction_Amount_gne__c, Form_Of_Payment_gne__c, Nature_Of_Payment_gne__c, 
                (SELECT LogicalDeleteFlag__c, AGS_Brand_gne__r.Brand_Name__c FROM AGS_expense_products_intercations1__r) FROM AGS_Spend_Expense_Transaction_gne__c LIMIT 1];
            testTransaction.LogicalDeleteFlag_gne__c = true;
            update testTransaction;
            VDST_Event_gne__c newEvent = new VDST_Event_gne__c(CurrentStatus_gne__c = 'PENDING', VendorEventID_gne__c =  'testVendorId',
                CurrentStatusDate_gne__c = Date.today(), EventType_gne__c = 'ADBOARD', EventStartDate_gne__c = Date.today().addDays(-2), EventEndDate_gne__c = Date.today().addDays(-2), TransactionID_gne__c = testTransaction.Source_Transaction_ID_gne__c, 
                SourceTransactionID_gne__c = testTransaction.Source_Transaction_ID_gne__c);
            insert newEvent;

            //WHEN
            newEvent.CurrentStatus_gne__c = 'CLOSED';
            update newEvent;

            //THEN
            AGS_ST_DisputeManagement_gne__c[] existingDisputeManagement = [SELECT Internal_Status_gne__c, External_Status_gne__c FROM AGS_ST_DisputeManagement_gne__c];
            System.assertEquals('Submitted', existingDisputeManagement[0].Internal_Status_gne__c);
            System.assertEquals('In Progress', existingDisputeManagement[0].External_Status_gne__c);
            System.assertEquals(1, [SELECT COUNT() FROM AGS_ST_DisputeManagement_gne__c]);

            testTransaction = [SELECT LogicalDeleteFlag_gne__c FROM AGS_Spend_Expense_Transaction_gne__c WHERE Id = :testTransaction.Id];

            System.assertEquals(true, testTransaction.LogicalDeleteFlag_gne__c);
        }
    }
}