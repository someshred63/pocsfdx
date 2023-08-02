/** @date 2/16/2013
* @Author Pawel Sprysak
* @description Test Class for Event Detail Controller
*/
@isTest
public class VDST_EventDetailController_Test {

    /** @date 2/4/2014
    * @Author Pawel Sprysak
    * @description Test Method - Testing controller variables and most of methods which are triggered from constructor - part 1
    */
    @IsTest(SeeAllData=false)
    static void controller1_Test() {
        // Prepare data
        VDST_Settings__c custSet = new VDST_Settings__c(Name = 'prod', Admin_Username__c = 'gssptestuser@gene.com');
        insert custSet;
        List<VDST_EventField_gne__c> efToAdd = new List<VDST_EventField_gne__c>();
        VDST_EventField_gne__c ef1 = new VDST_EventField_gne__c(EventStatus_gne__c = 'Transactions', EventType_gne__c = 'CFF',
            FieldLabel_gne__c = 'Event Total Food and Beverages', FieldName_gne__c = 'EVTMEALS', IsRequired_gne__c = true, IsVisible_gne__c = true);
        efToAdd.add(ef1);
        VDST_EventField_gne__c ef2 = new VDST_EventField_gne__c(EventStatus_gne__c = 'Transactions', EventType_gne__c = 'CFF',
            FieldLabel_gne__c = 'Total Event Spend', FieldName_gne__c = 'TOTALEVENT', IsRequired_gne__c = true, IsVisible_gne__c = true);
        efToAdd.add(ef2);
        insert efToAdd;
        VDST_EventProvider_gne__c ep = new VDST_EventProvider_gne__c(VendorName_gne__c = 'Genentech', VendorCode_gne__c = 'GNE');
        insert ep;
        // Anonymous user
        User u = prepareUser(1);
        Test.startTest();
        // Run test
        System.runAs(u) {
            // Set parameters for CFF - no access
            setEventAndTypeParams(null, 'CFF');
            VDST_EventDetailController edc = new VDST_EventDetailController(); // Run controller and test some parameters after controller creation
            edc.initData();
            // Test data
            System.assertEquals(edc.commonUtils.eventType, 'CFF');
            System.assertEquals(edc.editId, null);
            System.assertEquals(edc.commonUtils.isStdEvent, true);
            System.assertEquals(edc.commonUtils.isSSEvent, false);
            System.assertEquals(edc.appState, 'Create');
            System.assertEquals(edc.eventCreateObject.CurrentStatus_gne__c, 'PENDING');
            System.assertEquals(edc.venueObject.City_gne__c, null);
            System.assertEquals(edc.eventCreateStep, 2);
            System.assertEquals(edc.vendorCodeList.get(0).getLabel(), '-Select-');
            System.assert(edc.vendorCodeList.size() > 1);
            System.assert(edc.totalSpendMap.values().size() > 0);
            System.assertEquals(edc.privileges.hasPrivileges, false);
            System.assertEquals(edc.commonUtils.vendorLoggedVal, null);
            System.assertEquals(edc.prtcpntUtils.commonUtils, edc.commonUtils);
            System.assertEquals(edc.prtcpntUtils.eventDates, 0);
            System.assertEquals(edc.eventAttachment, null);
            System.assertEquals(edc.hasEditPriv, false);
            System.assertEquals(edc.privileges.hasPrivileges, false);
            // Set parameters for Non-Research - no access
            setEventAndTypeParams(null, 'INDVSPND');
            // Run controller and test some parameters after controller creation
            edc = new VDST_EventDetailController();
            edc.initData();
            System.assertEquals(edc.commonUtils.eventType, 'INDVSPND');
            System.assertEquals(edc.commonUtils.isNonResearchEvent, true);
            System.assertEquals(edc.venueObject.City_gne__c, 'South San Francisco');
            // Test Virtual flag
            System.assertEquals(edc.isVirtualAddress, true); // by default should be true - because it's Non-Research Event
            edc.venueObject.AddressType_gne__c = 'Physical';
            System.assertEquals(edc.isVirtualAddress, false);
            // Reverse order
            edc.isVirtualAddress = true;
            System.assertEquals(edc.venueObject.AddressType_gne__c, 'Virtual');
            edc.isVirtualAddress = false;
            System.assertEquals(edc.venueObject.AddressType_gne__c, 'Physical');
            // Test isSuperAdmin flag
            System.assertEquals(edc.isSuperAdmin, true);
            custSet.Admin_Username__c = 'OtherAdminName@gene.com';
            update custSet;
            System.assertEquals(edc.isSuperAdmin, false);
        }
        Test.stopTest();
    }

    /** @date 2/24/2014
    * @Author Pawel Sprysak
    * @description Test Method - Testing controller variables and most of methods which are triggered from constructor - part 2
    */
    @IsTest(SeeAllData=false)
    static void controller2_Test() {
        // Prepare data
        VDST_Settings__c custSet = new VDST_Settings__c(Name = 'prod', Admin_Username__c = 'gssptestuser@gene.com');
        insert custSet;
        List<VDST_EventField_gne__c> efToAdd = new List<VDST_EventField_gne__c>();
        VDST_EventField_gne__c ef1 = new VDST_EventField_gne__c(EventStatus_gne__c = 'Transactions', EventType_gne__c = 'CFF',
            FieldLabel_gne__c = 'Event Total Food and Beverages', FieldName_gne__c = 'EVTMEALS', IsRequired_gne__c = true, IsVisible_gne__c = true);
        efToAdd.add(ef1);
        VDST_EventField_gne__c ef2 = new VDST_EventField_gne__c(EventStatus_gne__c = 'Transactions', EventType_gne__c = 'CFF',
            FieldLabel_gne__c = 'Total Event Spend', FieldName_gne__c = 'TOTALEVENT', IsRequired_gne__c = true, IsVisible_gne__c = true);
        efToAdd.add(ef2);
        insert efToAdd;
        VDST_EventProvider_gne__c ep = new VDST_EventProvider_gne__c(VendorName_gne__c = 'Genentech', VendorCode_gne__c = 'GNE');
        insert ep;
        VDST_EventPrtcpntRole_gne__c epr = new VDST_EventPrtcpntRole_gne__c(EventType_gne__c = 'ADBOARD', EventParticipantRoleCode_gne__c = 'ATND',
            EventParticipantRoleName__c = 'Attendee');
        insert epr;
        VDST_EventPrtcpntField_gne__c epf = new VDST_EventPrtcpntField_gne__c(VDST_EventPrtcpntRole__c = epr.Id,
            FieldLabel_gne__c = 'Item Name', FieldName_gne__c = 'ItemName_gne', IsRequired_gne__c = true, IsVisible_gne__c = true);
        insert epf;
        // Logged user
        User u = prepareUser(2);
        Test.startTest();
        System.runAs(u) {
            // Set parameters for ADBOARD - with access to edit
            //insert u;
            VDST_User_gne__c usr = new VDST_User_gne__c(Role_gne__c = 'Provisioner', User_gne__c = u.Id, VDST_Event_Provider__c = ep.Id);
            insert usr;
            VDST_Event_gne__c ev = new VDST_Event_gne__c(CurrentStatus_gne__c = 'PENDING',
                CurrentStatusDate_gne__c = Date.today(), EventType_gne__c = 'ADBOARD',
                EventStartDate_gne__c = Date.today(), EventEndDate_gne__c = Date.today(),
                ContentVendor_gne__c = ep.Id, LogisticVendor_gne__c = ep.Id);
            insert ev;
            VDST_Address_gne__c adr = new VDST_Address_gne__c(VDST_Event_gne__c = ev.Id, City_gne__c = 'Lublin');
            insert adr;
            VDST_EventSite_gne__c es = new VDST_EventSite_gne__c(VDST_Address_gne__c = adr.Id, VDST_Event_gne__c = ev.Id);
            insert es;
            setEventAndTypeParams(ev.Id, null);
            // Run controller and test some parameters after controller creation
            VDST_EventDetailController edc = new VDST_EventDetailController();
            edc.initData();
            System.assertEquals(edc.commonUtils.eventType, 'ADBOARD');
            System.assertEquals(edc.editId, ev.Id);
            System.assertEquals(edc.commonUtils.isStdEvent, true);
            System.assertEquals(edc.commonUtils.isSSEvent, false);
            System.assertEquals(edc.appState, 'Edit');
            System.assertEquals(edc.eventCreateObject.CurrentStatus_gne__c, 'PENDING');
            System.assertEquals(edc.hasEditPriv, true);
            System.assertEquals(edc.privileges.hasPrivileges, true);
            System.assert(edc.vendorCodeList.size() > 1);                      //Test setVendorCodes() method
            System.assertEquals(edc.actualContentVen.VendorCode_gne__c, 'GNE');     //Test setVendorCodes() method
            System.assert(edc.actualMap.values().size() > 0);                                //Test setActualStatusMap() method
            System.assert(edc.statusFieldMap.values().size() > 0);                           //Test setStatusFieldsMap() method
            System.assert(edc.prtcpntFieldMap.values().size() > 0);                          //Test setPrtcpntRoleFieldsMap() method
            System.assertEquals(edc.venueObject.City_gne__c, 'Lublin');
            // Set parameters for Research - with access and OCCURRED status
            ev = new VDST_Event_gne__c(CurrentStatus_gne__c = 'OCCURRED',
                CurrentStatusDate_gne__c = Date.today(), EventType_gne__c = 'RSCH',
                EventStartDate_gne__c = Date.today(), EventEndDate_gne__c = Date.today(),
                LogisticVendor_gne__c = ep.Id);
            insert ev;
            setEventAndTypeParams(ev.Id, null);
            // Run controller and test some parameters after controller creation
            edc = new VDST_EventDetailController();
            edc.initData();
            System.assertEquals(edc.commonUtils.eventType, 'RSCH');
            System.assertEquals(edc.commonUtils.isNonResearchEvent, false);
            System.assertEquals(edc.commonUtils.isResearchEvent, true);
            System.assertEquals(edc.commonUtils.isStdEvent, false);
            System.assert(edc.actualMap.values().size() > 0);                                //Test setActualStatusMap() method
            // Set parameters for Non-Research - with edit access and attachment
            ev = new VDST_Event_gne__c(CurrentStatus_gne__c = 'PENDING',
                CurrentStatusDate_gne__c = Date.today(), EventType_gne__c = 'INDVSPND',
                EventStartDate_gne__c = Date.today(), EventEndDate_gne__c = Date.today(),
                LogisticVendor_gne__c = ep.Id);
            insert ev;
            Attachment att = new Attachment(ParentId = ev.Id, Name = 'testFile', Body = Blob.valueOf('testFile'));
            insert att;
            setEventAndTypeParams(ev.Id, null);
            // Run controller and test some parameters after controller creation
            edc = new VDST_EventDetailController();
            edc.initData();
            System.assertEquals(edc.commonUtils.eventType, 'INDVSPND');
            System.assertEquals(edc.commonUtils.isNonResearchEvent, true);
            System.assertEquals(edc.commonUtils.isResearchEvent, false);
            System.assertEquals(edc.commonUtils.isStdEvent, false);
            System.assertNotEquals(edc.commonUtils.nonResTransaction, null);        //Object should be created
            System.assertNotEquals(edc.eventAttachment, null);
            // Set parameters for Single Spend - with read-only access and no Logistic Vendor Code
            usr.Role_gne__c = 'Monitoring';
            update usr;
            ev = new VDST_Event_gne__c(CurrentStatus_gne__c = 'PENDING',
                CurrentStatusDate_gne__c = Date.today(), EventType_gne__c = 'ECOUPON',
                EventStartDate_gne__c = Date.today(), EventEndDate_gne__c = Date.today());
            insert ev;
            setEventAndTypeParams(ev.Id, null);
            // Run controller and test some parameters after controller creation
            edc = new VDST_EventDetailController();
            edc.initData();
            System.assertEquals(edc.commonUtils.eventType, 'ECOUPON');
            System.assertEquals(edc.commonUtils.isNonResearchEvent, false);
            System.assertEquals(edc.commonUtils.isResearchEvent, false);
            System.assertEquals(edc.commonUtils.isSSEvent, true);
            System.assertEquals(edc.commonUtils.vendorLoggedVal, 'GNE');
            System.assertEquals(edc.hasEditPriv, false);
            System.assertEquals(edc.privileges.hasPrivileges, true);
        }
        Test.stopTest();
    }

    /** @date 2/6/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for isValidEventType() method
    */
    @IsTest(SeeAllData=false)
    static void isValidEventType_Test() {
        // Prepare data
        setEventAndTypeParams(null, null);
        VDST_EventDetailController edc = new VDST_EventDetailController();
        edc.initData();
        // Test data
        System.assertEquals(edc.isValidEventType(), false);
        edc.commonUtils.eventType = 'NOTVALID';
        System.assertEquals(edc.isValidEventType(), false);
        edc.commonUtils.eventType = 'CFF';
        System.assertEquals(edc.isValidEventType(), true);
    }

    /** @date 2/6/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for goToListPage() method
    */
    @IsTest(SeeAllData=false)
    static void goToListPage_Test() {
        // Prepare data
        VDST_EventDetailController edc = new VDST_EventDetailController();
        edc.initData();
        // Test data
        PageReference pr = edc.goToListPage();
        System.assertEquals(pr.getRedirect(), true);
        System.assertEquals(pr.getUrl(), '/apex/VDST_EventList');
    }

    /** @date 2/6/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for setSummaryMap() method
    */
    @IsTest(SeeAllData=false)
    static void setSummaryMap_Test() {
        Test.startTest();
        // Prepare DB data
        VDST_EventField_gne__c ef = new VDST_EventField_gne__c(EventStatus_gne__c = 'Transactions', EventType_gne__c = 'ADBOARD',
            FieldLabel_gne__c = 'Total Food', FieldName_gne__c = 'EVTMEALS', IsRequired_gne__c = true, IsVisible_gne__c = true);
        insert ef;
        VDST_Event_gne__c ev = new VDST_Event_gne__c(CurrentStatus_gne__c = 'PENDING',
            CurrentStatusDate_gne__c = Date.today(), EventType_gne__c = 'ADBOARD',
            EventStartDate_gne__c = Date.today().addDays(-3), EventEndDate_gne__c = Date.today().addDays(-2));
        insert ev;
        VDST_EventTransactionSummary_gne__c ets = new VDST_EventTransactionSummary_gne__c(
            EventTransactionTypeCode_gne__c = 'EVTMEALS', EventTransactionLevel_gne__c = 'EVNT',
            EventTransactionAmount_gne__c = 231.12, VDST_Event_gne__c = ev.Id);
        insert ets;
        // Set - getter and controller
        setEventAndTypeParams(ev.Id, null);
        VDST_EventDetailController edc = new VDST_EventDetailController();
        edc.initData();
        // Start test
        System.assertEquals(edc.totalSpendMap.get('EVTMEALS').FieldLabel_gne__c, 'Total Food');    // Check first part of method
        System.assertEquals(edc.totalSpendMap.get('EVTMEALS').DefaultValue_gne__c, '231.12');        // Check second part of method
        Test.stopTest();
    }

    /** @date 2/6/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for getIsAlreadyOccurred() method
    */
    @IsTest(SeeAllData=false)
    static void getIsAlreadyOccurred_Test() {
        Test.startTest();
        // Past date
        VDST_Event_gne__c ev = new VDST_Event_gne__c(CurrentStatus_gne__c = 'PENDING',
                CurrentStatusDate_gne__c = Date.today(), EventType_gne__c = 'RSCH',
                EventStartDate_gne__c = Date.today().addDays(-3), EventEndDate_gne__c = Date.today().addDays(-2));
        insert ev;
        setEventAndTypeParams(ev.Id, null);
        VDST_EventDetailController edc = new VDST_EventDetailController();
        edc.initData();
        System.assertEquals(edc.getIsAlreadyOccurred(), true);
        // Todays date
        ev = new VDST_Event_gne__c(CurrentStatus_gne__c = 'PENDING',
                CurrentStatusDate_gne__c = Date.today(), EventType_gne__c = 'RSCH',
                EventStartDate_gne__c = Date.today().addDays(-3), EventEndDate_gne__c = Date.today());
        insert ev;
        setEventAndTypeParams(ev.Id, null);
        edc = new VDST_EventDetailController();
        edc.initData();
        System.assertEquals(edc.getIsAlreadyOccurred(), true);
        // Future date
        ev = new VDST_Event_gne__c(CurrentStatus_gne__c = 'PENDING',
                CurrentStatusDate_gne__c = Date.today(), EventType_gne__c = 'RSCH',
                EventStartDate_gne__c = Date.today().addDays(-1), EventEndDate_gne__c = Date.today().addDays(2));
        insert ev;
        setEventAndTypeParams(ev.Id, null);
        edc = new VDST_EventDetailController();
        edc.initData();
        System.assertEquals(edc.getIsAlreadyOccurred(), false);
        Test.stopTest();
    }

    /** @date 2/7/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for get label methods
    */
    @IsTest(SeeAllData=false)
    static void getLabelMethods_Test() {
        Test.startTest();
        // Prepare DB data - with USA Country
        VDST_Event_gne__c ev = new VDST_Event_gne__c(CurrentStatus_gne__c = 'PENDING',
            CurrentStatusDate_gne__c = Date.today(), EventType_gne__c = 'CFF',
            EventStartDate_gne__c = Date.today(), EventEndDate_gne__c = Date.today(),
            Function_gne__c = 'BMACO', SupplementStatusCode_gne__c = 'SUPPLMT', TotalAudioVisual_gne__c = 100);
        insert ev;
        VDST_Address_gne__c adr = new VDST_Address_gne__c(VDST_Event_gne__c = ev.Id, City_gne__c = 'Lublin',
            Country_gne__c = 'USA', StateProvince_gne__c = 'CA', StatesNameHolder_gne__c = null);
        insert adr;
        VDST_EventSite_gne__c es = new VDST_EventSite_gne__c(VDST_Address_gne__c = adr.Id, VDST_Event_gne__c = ev.Id);
        insert es;
        List<VDST_Mapping_gne__c> mapsToInsert = new List<VDST_Mapping_gne__c>();
        VDST_Mapping_gne__c map1 = new VDST_Mapping_gne__c(Name = 'CFF', LabelValue_gne__c = 'Contracted Field Force');
        mapsToInsert.add(map1);
        VDST_Mapping_gne__c map2 = new VDST_Mapping_gne__c(Name = 'PENDING', LabelValue_gne__c = 'Pending');
        mapsToInsert.add(map2);
        VDST_Mapping_gne__c map3 = new VDST_Mapping_gne__c(Name = 'SUPPLMT', LabelValue_gne__c = 'Supplement');
        mapsToInsert.add(map3);
        VDST_Mapping_gne__c map4 = new VDST_Mapping_gne__c(Name = 'USA', LabelValue_gne__c = 'United States');
        mapsToInsert.add(map4);
        VDST_Mapping_gne__c map5 = new VDST_Mapping_gne__c(Name = 'CA', LabelValue_gne__c = 'California');
        mapsToInsert.add(map5);
        VDST_Mapping_gne__c map6 = new VDST_Mapping_gne__c(Name = 'BMACO', LabelValue_gne__c = 'BMACO-Label');
        mapsToInsert.add(map6);
        insert mapsToInsert;
        // Set - getter and controller
        setEventAndTypeParams(ev.Id, null);
        VDST_EventDetailController edc = new VDST_EventDetailController();
        edc.initData();
        // Start test - different methods
        System.assertEquals(edc.getEventTypeLabel(), 'Contracted Field Force');
        System.assertEquals(edc.getCurrentStatusLabel(), 'Pending');
        System.assertEquals(edc.getFunctionLabel(), 'BMACO-Label');
        System.assertEquals(edc.getSupplementStatusLabel(), 'Supplement');
        System.assertEquals(edc.getVenueCountryLabel(), 'United States');
        System.assertEquals(edc.getVenueStateLabel(), 'California');
        // Prepare DB data - outside USA and wrong/null function
        adr.Country_gne__c = 'POL';
        adr.StateProvince_gne__c = 'ANY';
        adr.StatesNameHolder_gne__c = 'TestedState';
        update adr;
        ev.Function_gne__c = 'OTHERCODE';
        update ev;
        edc = new VDST_EventDetailController();
        edc.initData();
        // Start test
        System.assertEquals(edc.getVenueStateLabel(), 'TestedState');
        System.assertEquals(edc.getFunctionLabel(), '');
        System.assertEquals(edc.stateHolder, 'ANY'); // Test UI flag
        // Test AV getter
        System.assertEquals(edc.avMapping, '100.00');
        edc.avMapping = '120';
        System.assertEquals(edc.eventCreateObject.TotalAudioVisual_gne__c, 120);
        edc.avMapping = 'XXX'; // Wrong type test
        System.assertEquals(edc.eventCreateObject.TotalAudioVisual_gne__c, null);
        Test.stopTest();
    }

    /** @date 2/7/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for getSummaryTransactions() method
    */
    @IsTest(SeeAllData=false)
    static void getSummaryTransactions_Test() {
        // Prepare data
        setEventAndTypeParams(null, null);
        VDST_EventDetailController edc = new VDST_EventDetailController();
        edc.initData();
        edc.totalSpendMap = null;
        // No transactions to sort
        List<VDST_EventField_gne__c> efList = edc.getSummaryTransactions();
        System.assertEquals(efList.size(), 0);
        // Unsorted transactions
        Map<String, VDST_EventField_gne__c> transMap = new Map<String, VDST_EventField_gne__c>();
        transMap.put('A', new VDST_EventField_gne__c(EventStatus_gne__c = 'Transactions', EventType_gne__c = 'ADBOARD',
            FieldLabel_gne__c = 'BBB Label', FieldName_gne__c = 'FFF Code', IsRequired_gne__c = true, IsVisible_gne__c = true));
        transMap.put('B', new VDST_EventField_gne__c(EventStatus_gne__c = 'Transactions', EventType_gne__c = 'ADBOARD',
            FieldLabel_gne__c = 'AAA Label', FieldName_gne__c = 'CCC Code', IsRequired_gne__c = true, IsVisible_gne__c = true));
        transMap.put('C', new VDST_EventField_gne__c(EventStatus_gne__c = 'Transactions', EventType_gne__c = 'ADBOARD',
            FieldLabel_gne__c = 'CCC Label', FieldName_gne__c = 'AAA Code', IsRequired_gne__c = true, IsVisible_gne__c = true));
        edc.totalSpendMap = transMap;
        System.assertEquals(edc.totalSpendMap.values().get(0).FieldLabel_gne__c, 'BBB Label');
        System.assertEquals(edc.totalSpendMap.values().get(1).FieldLabel_gne__c, 'AAA Label');
        System.assertEquals(edc.totalSpendMap.values().get(2).FieldLabel_gne__c, 'CCC Label');
        // Sorted transactions
        List<VDST_EventField_gne__c> sortedList = edc.getSummaryTransactions();
        System.assertEquals(sortedList.get(0).FieldLabel_gne__c, 'AAA Label');
        System.assertEquals(sortedList.get(1).FieldLabel_gne__c, 'BBB Label');
        System.assertEquals(sortedList.get(2).FieldLabel_gne__c, 'CCC Label');
    }

    /** @date 2/7/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for Select Option lists getter methods
    */
    @IsTest(SeeAllData=false)
    static void selectOptionLists_Test() {
        Test.startTest();
        // Prepare DB data
        List<VDST_Mapping_gne__c> mapsToInsert = new List<VDST_Mapping_gne__c>();
        VDST_Mapping_gne__c map1 = new VDST_Mapping_gne__c(Name = 'CFF', LabelValue_gne__c = 'Contracted Field Force');
        mapsToInsert.add(map1); // Event Type
        VDST_Mapping_gne__c map2 = new VDST_Mapping_gne__c(Name = 'BMACO', LabelValue_gne__c = 'BMaCo');
        mapsToInsert.add(map2); // Function
        VDST_Mapping_gne__c map3 = new VDST_Mapping_gne__c(Name = 'NOMLPRVD', LabelValue_gne__c = 'No Meal Provided');
        mapsToInsert.add(map3); // Consumption Status
        VDST_Mapping_gne__c map4 = new VDST_Mapping_gne__c(Name = 'POL', LabelValue_gne__c = 'Poland');
        mapsToInsert.add(map4); // Countries
        insert mapsToInsert;
        setEventAndTypeParams(null, null);
        VDST_EventDetailController edc = new VDST_EventDetailController();
        edc.initData();
        // Test method: getEventTypes()
        List<SelectOption> soList = edc.getEventTypes();
        String prevValue = '';
        for(SelectOption so : soList) {
            System.assert(so.getValue() >= prevValue);
            prevValue = so.getValue();
            // for only one which has mapping it should prepare correct SelectOption
            if('CFF'.equals(so.getValue())) {
                System.assertEquals(so.getLabel(), 'Contracted Field Force');
            } else {
                System.assertEquals(so.getLabel(), so.getValue());
            }
        }
        // Test method: getFunctions()
        soList = edc.getFunctions();
        System.assertEquals(soList.get(0).getValue(), '');
        System.assertEquals(soList.get(0).getLabel(), '-Select-');
        System.assert(soList.size() > 1);
        prevValue = '';
        for(SelectOption so : soList) {
            System.assert(so.getValue() >= prevValue);
            prevValue = so.getValue();
            // for only one which has mapping it should prepare correct SelectOption
            if('BMACO'.equals(so.getValue())) {
                System.assertEquals(so.getLabel(), 'BMaCo');
            } else if(''.equals(so.getValue())) {
                System.assertEquals(so.getLabel(), '-Select-');
            } else {
                System.assertEquals(so.getLabel(), so.getValue());
            }
        }
        // Test method: getConsumptionStatus()
        soList = edc.getConsumptionStatus();
        prevValue = '';
        for(SelectOption so : soList) {
            System.assert(so.getValue() >= prevValue);
            prevValue = so.getValue();
            // for only one which has mapping it should prepare correct SelectOption
            if('NOMLPRVD'.equals(so.getValue())) {
                System.assertEquals(so.getLabel(), 'No Meal Provided');
            } else {
                System.assertEquals(so.getLabel(), so.getValue());
            }
        }
        // Test method: getSourceExpenseTypes()
        soList = edc.getSourceExpenseTypes();
        System.assertEquals(soList.get(0).getValue(), '');
        System.assertEquals(soList.get(0).getLabel(), '-Select-');
        System.assert(soList.size() > 1);
        // Test method: getCountries()
        soList = edc.getCountries();
        System.assertEquals(soList.get(0).getValue(), '');
        System.assertEquals(soList.get(0).getLabel(), '-Select-');
        System.assert(soList.size() > 1);
        prevValue = '';
        for(SelectOption so : soList) {
            if('Poland'.equals(so.getValue())) {
                System.assert(so.getLabel() < prevValue);
                prevValue = so.getLabel();
            }
            // for only one which has mapping it should prepare correct SelectOption
            if('POL'.equals(so.getValue())) {
                System.assertEquals(so.getLabel(), 'Poland');
            } else if(''.equals(so.getValue())) {
                System.assertEquals(so.getLabel(), '-Select-');
            } else {
                System.assertEquals(so.getLabel(), so.getValue());
            }
        }
        // Test method: getStates()
        soList = edc.getStates();
        System.assert(soList.size() > 1);
        for(SelectOption so : soList) {
            if('CA'.equals(so.getValue())) {
                System.assertEquals(so.getLabel(), 'California');
                break;
            }
        }
        // Test method: getResearchPaymentTypes()
        soList = edc.getResearchPaymentTypes();
        System.assertEquals(soList.get(0).getValue(), '');
        System.assertEquals(soList.get(0).getLabel(), '-Select-');
        System.assert(soList.size() > 1);
        // Test method: getTrialStatus()
        soList = edc.getTrialStatus();
        System.assertEquals(soList.get(0).getValue(), '');
        System.assertEquals(soList.get(0).getLabel(), '-Select-');
        System.assert(soList.size() > 1);
        Test.stopTest();
    }

    /** @date 2/7/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for getResearchPaymentTypesMap() method
    */
    @IsTest(SeeAllData=false)
    static void getResearchPaymentTypesMap_Test() {
        // Prepare data
        setEventAndTypeParams(null, null);
        VDST_EventDetailController edc = new VDST_EventDetailController();
        edc.initData();
        // Test data
        Map<String, String> valMap = edc.getResearchPaymentTypesMap();
        System.assertEquals(valMap.get(null), '');
        System.assertEquals(valMap.get(''), '');
        System.assertEquals(edc.getResearchPaymentTypes().get(1).getLabel(), valMap.get(edc.getResearchPaymentTypes().get(1).getValue()));
    }

    /** @date 2/7/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for setStatusHistory() method
    */
    @IsTest(SeeAllData=false)
    static void setStatusHistory_Test() {
        Test.startTest();
        // Prepare data
        VDST_Event_gne__c ev = new VDST_Event_gne__c(CurrentStatus_gne__c = 'PENDING',
                CurrentStatusDate_gne__c = Date.today(), EventType_gne__c = 'RSCH',
                EventStartDate_gne__c = Date.today().addDays(-3), EventEndDate_gne__c = Date.today().addDays(-2));
        insert ev;
        setEventAndTypeParams(ev.Id, null);
        VDST_EventDetailController edc = new VDST_EventDetailController();
        edc.initData();
        edc.setStatusHistory();
        // TODO: check
        /* Method only exist to cover code test - in SFDC test there is no possibility to test _History objects
        // Test at the beggining
        System.assertEquals(edc.statusHistoryList.size(), 1);
        // Test after update
        ev.CurrentStatus_gne__c = 'OCCURRED';
        ev.Function_gne__c = 'TEST';
        update ev;
        System.assertEquals(edc.statusHistoryList.size(), 2);
        */
        Test.stopTest();
    }

    /** @date 2/7/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for button action methods
    */
    @IsTest(SeeAllData=false)
    static void buttonActionMethods_Test() {
        // Prepare data
        VDST_Event_gne__c ev = new VDST_Event_gne__c(CurrentStatus_gne__c = 'PENDING',
            CurrentStatusDate_gne__c = Date.today(), EventType_gne__c = 'ADBOARD',
            EventStartDate_gne__c = Date.today(), EventEndDate_gne__c = Date.today(),
            VendorEventID_gne__c = 'DuplicateValue', GNE_EventId_gne__c = 'DuplicateGNEValue');
        insert ev;
        setEventAndTypeParams(ev.Id, null);
        VDST_EventDetailController edc = new VDST_EventDetailController();
        edc.initData();
        edc.changeDrugName = false;
        // Test data
        System.assertEquals(edc.eventCreateStep, 2); // main screen
        edc.selectBrands();
        System.assertEquals(edc.eventCreateStep, 3); // brands screen
        edc.cancelBrands();
        System.assertEquals(edc.eventCreateStep, 2); // back to main screen by canceling
        edc.selectBrands();
        System.assertEquals(edc.eventCreateStep, 3); // brands screen
        System.assertEquals(edc.changeDrugName, false);
        edc.setBrands();
        System.assertEquals(edc.eventCreateStep, 2); // back to main screen by setting new values
        System.assertEquals(edc.changeDrugName, true);
        // Test edit buttons
        edc.editActionMessages = 'test action message';
        edc.editErrorMessages = 'test error message';
        edc.editableMode = false;
        edc.editEvent();
        edc.appState = 'Edit';
        System.assertEquals(edc.editActionMessages, '');
        System.assertEquals(edc.editErrorMessages, '');
        System.assertEquals(edc.editableMode, true);
        System.assertEquals(edc.isEditable, true);
        edc.cancelEvent();
        System.assertEquals(edc.editableMode, false);
        System.assertEquals(edc.isEditable, false);
        edc.appState = 'Create';
        PageReference pr = edc.cancelEvent();
        System.assertEquals(pr.getUrl(), '/apex/VDST_EventList');
    }

    /** @date 2/7/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for setBrandValues() method
    */
    @IsTest(SeeAllData=false)
    static void setBrandValues_Test() {
        Test.startTest();
        // Prepare data
        Product_vod__c pro1 = new Product_vod__c(Product_Type_vod__c = 'Detail', Detail_Product_Subtype_Code_gne__c = 'Brand',
            Brand_Code_gne__c = 'AVASTIN', Name = 'Avastin');
        insert pro1;
        Product_vod__c pro2 = new Product_vod__c(Product_Type_vod__c = 'Detail', Detail_Product_Subtype_Code_gne__c = 'Brand',
            Brand_Code_gne__c = 'ACTEMRA_CODE', Name = 'Actemra');
        insert pro2;
        setEventAndTypeParams(null, null);
        ApexPages.currentPage().getParameters().put('type', 'CFF');
        VDST_EventDetailController edc = new VDST_EventDetailController();
        edc.initData();
        // Test - No brands selected
        edc.setBrandValues();
        System.assertEquals(edc.newDrugNames, '');
        // Test - With one brand selected
        edc.multiDrugNames = new List<String>{pro1.Id};
        edc.setBrandValues();
        System.assertEquals(edc.newDrugNames, 'Avastin');
        // Test - With brands selected
        edc.multiDrugNames = new List<String>{pro1.Id, pro2.Id};
        edc.setBrandValues();
        System.assertEquals(edc.newDrugNames, 'Avastin, Actemra');
        Test.stopTest();
    }

    /** @date 2/7/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for saving methods - PART 1 (in parts because of limits)
    */
    @IsTest(SeeAllData=false)
    static void saveMethods1_Test() {
        Test.startTest();
        // Prepare data
        User u = prepareUser(1);
        VDST_EventProvider_gne__c ep = new VDST_EventProvider_gne__c(VendorCode_gne__c = 'GNE', VendorName_gne__c = 'Genentech');
        insert ep;
        VDST_User_gne__c usr = new VDST_User_gne__c(Role_gne__c = 'Provisioner', User_gne__c = u.Id, VDST_Event_Provider__c = ep.Id);
        insert usr;
        System.runAs(u) {
            VDST_Event_gne__c ev = new VDST_Event_gne__c(CurrentStatus_gne__c = 'PENDING',
                CurrentStatusDate_gne__c = Date.today(), EventType_gne__c = 'ADBOARD',
                EventStartDate_gne__c = Date.today(), EventEndDate_gne__c = Date.today(),
                VendorEventID_gne__c = 'DuplicateValue', GNE_EventId_gne__c = 'DuplicateGNEValue');
            insert ev;
            setEventAndTypeParams(null, 'ECOUPON');
            VDST_EventDetailController edc = new VDST_EventDetailController();
            edc.initData();
            // CREATE Single Spend
            // Test - Duplicate Vendor Event Id
            edc.eventCreateObject.ItemName_gne__c = 'Test Name';
            //edc.eventCreateObject.VendorEventID_gne__c = 'DuplicateValue';
            //edc.saveAndCloseEvent(); // Run method
            //System.assert(edc.editErrorMessages.contains('duplicate'));
            // Test - Duplicate GNE Event Id
            edc.eventCreateObject.VendorEventID_gne__c = 'UpperTest';
            //edc.eventCreateObject.GNE_EventId_gne__c = 'DuplicateGNEValue';
            //edc.saveAndCloseEvent(); // Run method
            //System.assert(edc.editErrorMessages.contains('duplicate'));
            // Test - Stard Date after End Date
            edc.eventCreateObject.GNE_EventId_gne__c = 'NoDuplicate';
            //edc.eventCreateObject.EventStartDate_gne__c = Date.today().addDays(-1);
            //edc.eventCreateObject.EventEndDate_gne__c = Date.today().addDays(-3);
            //edc.saveAndCloseEvent(); // Run method
            //System.assertEquals(edc.editErrorMessages, 'Create failed. Event Start Date must be earlier than Event End Date.');
            // Test - More than 5 days
            //edc.eventCreateObject.EventStartDate_gne__c = Date.today().addDays(-8);
            //edc.eventCreateObject.EventEndDate_gne__c = Date.today().addDays(-1);
            //edc.saveAndCloseEvent(); // Run method
            //System.assertEquals(edc.editErrorMessages, 'Create failed. Event End Date could be max 4 days after Event End Date.');
            // Test - Create event
            edc.eventCreateObject.EventStartDate_gne__c = Date.today().addDays(-3);
            edc.eventCreateObject.EventEndDate_gne__c = null;
            edc.saveAndCloseEvent(); // Run method
            System.assertEquals(edc.eventCreateStep, 2);
            System.assertEquals(edc.eventCreateObject.EventEndDate_gne__c, Date.today().addDays(-3));
            System.assertEquals(edc.eventCreateObject.EventMeetingName_gne__c, 'Test Name');
            System.assertEquals(edc.venueObject.City_gne__c, 'South San Francisco');
            System.assertEquals(edc.eventCreateObject.CurrentStatus_gne__c, 'PENDING');
            System.assertEquals(edc.eventCreateObject.VendorEventID_gne__c, 'UPPERTEST');
            System.assertNotEquals(edc.eventCreateObject.VendorEventID_gne__c, 'UpperTest');
            System.assertEquals(edc.appState, 'Edit');
            System.assertEquals(edc.editActionMessages, 'Event Created successfully');
            System.assertNotEquals(edc.eventInfoKeeper.LastModifiedDate, null);
            System.assertEquals(edc.editableMode, false);
            System.assertEquals(edc.evDateTransList.size(), 1); // Single Spend - only 1 day
            System.assertEquals(edc.prtcpntUtils.commonUtils, edc.commonUtils);
            // EDIT - Single Spend
            edc.eventCreateObject.VendorEventID_gne__c = 'UpperTest';
            edc.venueObject.PostalCode_gne__c = 'Test-123';
            edc.onlySaveEvent(); // Run method
            System.assertEquals(edc.editableMode, true);
            System.assertEquals(edc.eventCreateStep, 2);
            System.assertEquals(edc.eventCreateObject.VendorEventID_gne__c, 'UPPERTEST');
            System.assertNotEquals(edc.eventCreateObject.VendorEventID_gne__c, 'UpperTest');
            System.assertEquals(edc.venueObject.PostalCode_gne__c, 'TEST-123');
            System.assertNotEquals(edc.venueObject.PostalCode_gne__c, 'Test-123');
            System.assertEquals(edc.editActionMessages, 'Event Saved successfully');
            System.assertEquals(edc.evDateTransList.size(), 1); // Single Spend - only 1 day
        }
        Test.stopTest();
    }

    /** @date 2/11/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for saving methods - PART 2 (in parts because of limits)
    */
    @IsTest(SeeAllData=false)
    static void saveMethods2_Test() {
        Test.startTest();
        // Prepare data
        User u = prepareUser(2);
        VDST_EventProvider_gne__c ep = new VDST_EventProvider_gne__c(VendorCode_gne__c = 'GNE', VendorName_gne__c = 'Genentech');
        insert ep;
        VDST_User_gne__c usr = new VDST_User_gne__c(Role_gne__c = 'Provisioner', User_gne__c = u.Id, VDST_Event_Provider__c = ep.Id);
        insert usr;
        System.runAs(u) {
            // CREATE - ADBOARD
            //setEventAndTypeParams(null, 'ADBOARD');
            VDST_Event_gne__c event = new VDST_Event_gne__c();
            PageReference pageRef = Page.VDST_EventDetail;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('event','');
            pageRef.getParameters().put('type', 'ADBOARD');
            ApexPages.StandardController sc = new ApexPages.standardController(event);
            VDST_EventDetailController edc = new VDST_EventDetailController();
            edc.siteObject = new VDST_EventSite_gne__c();
            VDST_Event_gne__c ev         = new VDST_Event_gne__c();
            edc.eventCreateObject        = ev ;
            edc.commonUtils              = new VDST_EventDetailCommon();
            VDST_Address_gne__c ven      = new VDST_Address_gne__c();
            edc.venueObject              = ven;
            edc.appState                 = 'null';
            edc.privileges               = new VDST_Utils.PrivilegesWrapper();
            edc.privileges.hasPrivileges = false;
            edc.multiDrugNames           = new List<String>();
            edc.setVendorCodes();
            edc.eventCreateObject.EventStartDate_gne__c = Date.today().addDays(-3);
            edc.eventCreateObject.EventEndDate_gne__c   = Date.today().addDays(-3);
            edc.venueObject.PostalCode_gne__c           = 'Test-123';
            edc.eventCreateObject.ContentVendor_gne__c  = ep.Id;
            edc.onlySaveEvent();
            System.assertEquals(edc.venueObject.PostalCode_gne__c, 'TEST-123');
            System.assertNotEquals(edc.venueObject.PostalCode_gne__c, 'Test-123');
            System.assertEquals(edc.actualContentVen.VendorCode_gne__c, 'GNE');
            // CREATE - CFF
            setEventAndTypeParams(null, 'CFF');
            edc = new VDST_EventDetailController();
            edc.initData();
            edc.eventCreateObject.EventStartDate_gne__c = Date.today().addDays(-3);
            edc.eventCreateObject.EventEndDate_gne__c = Date.today().addDays(-2);
            edc.onlySaveEvent(); // Create transactions
            System.assert(edc.evDateTransList.size() > 0); // Should be 2 days
            edc.evDateTransList.get(0).inputTotalFaB = 'notDouble';
            edc.onlySaveEvent(); // Check conversion
            System.assertEquals(edc.evDateTransList.get(0).inputTotalFaB, '0.00');
            for(VDST_Utils.EventDateTransactions edtWrap : edc.evDateTransList) {
                System.assertNotEquals(edtWrap.inputTotalFaB, null);
            }
            // CREATE - Non-Research
            setEventAndTypeParams(null, 'INDVSPND');
            edc = new VDST_EventDetailController();
            edc.initData();
            edc.eventCreateObject.EventStartDate_gne__c = Date.today().addDays(-3);
            edc.eventCreateObject.EventEndDate_gne__c = Date.today().addDays(-3);
            edc.eventCreateObject.ItemAmount_gne__c = 23.12;
            edc.eventCreateObject.ItemCode_gne__c = 'ITEM_CODE';
            System.assertEquals(edc.commonUtils.isNonResearchEvent, true);
            System.assertEquals(edc.appState, 'Create');
            edc.onlySaveEvent(); // Create
            System.debug(edc.editActionMessages);
            System.debug(edc.editErrorMessages);
            System.assertEquals(edc.editActionMessages, 'Event Created successfully');
            System.assertEquals(edc.commonUtils.nonResTransaction.nonResPayment, 23.12);
            System.assertEquals(edc.commonUtils.nonResTransaction.sourceExpType, 'ITEM_CODE');
            System.assertEquals(edc.eventCreateObject.ResearchPaymentTypeCode_gne__c, 'NON-CLINICAL');
            edc.eventCreateObject.ItemAmount_gne__c = 22.12;
            edc.onlySaveEvent(); // Edit
            System.assertEquals(edc.commonUtils.nonResTransaction.nonResPayment, 22.12);
        }
        Test.stopTest();
    }

    /** @date 2/11/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for insertBrandTopic() method
    */
    @IsTest(SeeAllData=false)
    static void insertBrandTopic_Test() {
        Test.startTest();
        // Prepare data
        List<Product_vod__c> proList = new List<Product_vod__c>();
        Product_vod__c pro1 = new Product_vod__c(Product_Type_vod__c = 'Detail', Detail_Product_Subtype_Code_gne__c = 'Brand',
            Brand_Code_gne__c = 'AVASTIN_CODE', Name = 'Avastin');
        proList.add(pro1);
        Product_vod__c pro2 = new Product_vod__c(Product_Type_vod__c = 'Detail', Detail_Product_Subtype_Code_gne__c = 'Brand',
            Brand_Code_gne__c = 'ACTEMRA_CODE', Name = 'Actemra');
        proList.add(pro2);
        Product_vod__c pro3 = new Product_vod__c(Product_Type_vod__c = 'Detail', Detail_Product_Subtype_Code_gne__c = 'Brand',
            Brand_Code_gne__c = 'TARCEVA_CODE', Name = 'Tarceva');
        proList.add(pro3);
        Product_vod__c pro4 = new Product_vod__c(Product_Type_vod__c = 'Detail', Detail_Product_Subtype_Code_gne__c = 'Brand',
            Brand_Code_gne__c = 'TAMIFLU_CODE', Name = 'Tamiflu');
        proList.add(pro4);
        insert proList;
        VDST_Event_gne__c ev = new VDST_Event_gne__c(CurrentStatus_gne__c = 'PENDING',
            CurrentStatusDate_gne__c = Date.today(), EventType_gne__c = 'ADBOARD',
            EventStartDate_gne__c = Date.today(), EventEndDate_gne__c = Date.today(),
            VendorEventID_gne__c = 'DuplicateValue', GNE_EventId_gne__c = 'DuplicateGNEValue');
        insert ev;
        VDST_EventBrandTopic_gne__c ebt1 = new VDST_EventBrandTopic_gne__c(Product_Catalog_gne__c = pro1.Id, VDST_Event_gne__c = ev.Id);
        insert ebt1;
        VDST_EventBrandTopic_gne__c ebt2 = new VDST_EventBrandTopic_gne__c(Product_Catalog_gne__c = pro2.Id, VDST_Event_gne__c = ev.Id);
        insert ebt2;
        // Test data
        setEventAndTypeParams(ev.Id, null);
        VDST_EventDetailController edc = new VDST_EventDetailController();
        edc.initData();
        edc.multiDrugNames = new List<String>{pro2.Id, pro3.Id};
        edc.changeDrugName = true;
        edc.insertBrandTopic();
        System.assertEquals(edc.changeDrugName, false);
        List<VDST_EventBrandTopic_gne__c> ebtList = VDST_Utils.getBrandTopicList(ev.Id);
        System.assertEquals(ebtList.size(), 2);
        for(VDST_EventBrandTopic_gne__c ebt : ebtList) {
            System.assert(ebt.Product_Catalog_gne__c == pro2.Id || ebt.Product_Catalog_gne__c == pro3.Id);
        }
        Test.stopTest();
    }

    /** @date 2/24/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for supplementation methods
    */
    @IsTest(SeeAllData=false) // TODO
    static void supplementation_Test() {
        Test.startTest();
        // Prepare data
        VDST_EventPrtcpntRole_gne__c epr1 = new VDST_EventPrtcpntRole_gne__c(EventType_gne__c = 'RSCH', EventParticipantRoleCode_gne__c = 'PI',
            EventParticipantRoleName__c = 'PI');
        insert epr1;
        VDST_EventPrtcpntRole_gne__c epr2 = new VDST_EventPrtcpntRole_gne__c(EventType_gne__c = 'RSCH', EventParticipantRoleCode_gne__c = 'PAYEE',
            EventParticipantRoleName__c = 'Payee');
        insert epr2;
        VDST_EventProvider_gne__c ep = new VDST_EventProvider_gne__c(VendorName_gne__c = 'Genentech', VendorCode_gne__c = 'GNE');
        insert ep;
        VDST_Event_gne__c ev = new VDST_Event_gne__c(CurrentStatus_gne__c = 'PENDING',
            CurrentStatusDate_gne__c = Date.today(), EventType_gne__c = 'RSCH', LogisticVendor_gne__c = ep.Id,
            EventStartDate_gne__c = Date.today().addDays(-2), EventEndDate_gne__c = Date.today(),
            EventMeetingName_gne__c = 'Test Name', ItemAmount_gne__c = 23.32, VendorEventID_gne__c = 'GNE_abc');
        insert ev;
        VDST_EventPrtcpntRole_gne__c role    = new VDST_EventPrtcpntRole_gne__c();
        role.EventParticipantRoleCode_gne__c = 'CHAIR';
        role.EventParticipantRoleName__c     = 'Chairperson';
        role.EventType_gne__c                = 'ADBOARD';
        insert role;
        VDST_Address_gne__c adr  = new VDST_Address_gne__c();
        adr.PostalCode_gne__c    = '74162';
        adr.VDST_Event_gne__c    = ev.Id;
        adr.Country_gne__c       = 'United States';
        adr.StateProvince_gne__c = 'State';
        adr.City_gne__c = 'City';
        insert adr;
        VDST_EventPrtcpntAccnt_gne__c act = new VDST_EventPrtcpntAccnt_gne__c(ParticipantAffiliation_gne__c = 'N/A', ParticipantContractStatus_gne__c= 'CNTRCTD',VDST_Event_gne__c = ev.Id, VDST_Address_gne__c = adr.Id, PartyType_gne__c = 'PENDING', EventParticipantRole_gne__c = role.Id);
        insert act;
        AGS_CCO_Case_Recipient_gne__c recip1 = new AGS_CCO_Case_Recipient_gne__c(Last_Name_gne__c = 'LN', First_Name_gne__c = 'FN', State_gne__c = 'CA', Zip_gne__c = '20-000');
        insert recip1;
        AGS_CCO_Case_Recipient_gne__c recip2 = new AGS_CCO_Case_Recipient_gne__c(Last_Name_gne__c = 'INST', State_gne__c = 'CA', Zip_gne__c = '20-000');
        insert recip2;
        AGS_Spend_Expense_Transaction_gne__c spend1 = new AGS_Spend_Expense_Transaction_gne__c(REPORT_CODE_GNE__C = 'XC_MON',
            LogicalDeleteFlag_gne__c=false, Research_Pymt_Typ_Cd_gne__c = 'CLINICAL', Source_Transaction_ID_gne__c = 'trans1',Po_Number_gne__c = '12345',
            Primary_Recipient_gne__c = recip1.Id);
        insert spend1;
        AGS_Spend_Expense_Transaction_gne__c spend2 = new AGS_Spend_Expense_Transaction_gne__c(REPORT_CODE_GNE__C = 'XC_MON',
            LogicalDeleteFlag_gne__c=false, Research_Pymt_Typ_Cd_gne__c = 'PRECLINICAL', Source_Transaction_ID_gne__c = 'trans2',
            Primary_Recipient_gne__c = recip2.Id);
        insert spend2;
        Test.setFixedSearchResults(new List<Id>{spend1.Id, spend2.Id});
        // Test data
        setEventAndTypeParams(ev.Id, null);
        VDST_EventDetailController edc = new VDST_EventDetailController();
        edc.initData();
        edc.eventCreateObject.SupplementStatusCode_gne__c = 'SUPPLMT';
        edc.eventCreateObject.TransactionID_gne__c = 'trans';
        edc.insertSupplementedParticipants();
        System.assertEquals(edc.ttlPlanAttCnt, 1); // insertSupplementedParticipants() method test
        // Test - inner methods
        List<VDST_EventPrtcpntAccnt_gne__c> accntList = [SELECT ParticipantContractStatus_gne__c, ParticipantAffiliation_gne__c, VDST_Event_gne__c FROM VDST_EventPrtcpntAccnt_gne__c WHERE VDST_Event_gne__c = :ev.Id];
        System.assertEquals(accntList.get(0).ParticipantContractStatus_gne__c, 'CNTRCTD');
        System.assertEquals(accntList.get(0).ParticipantAffiliation_gne__c, 'N/A');
        System.assertEquals(accntList.get(0).VDST_Event_gne__c, ev.Id);
        // Supplementation remote method test: getTransactionData()
        VDST_SuplementData.SuplementedTransaction st = VDST_EventDetailController.getTransactionData('trans1', 'RSCH');
        System.assertEquals(st.TransactionID, 'trans1');
        System.assertEquals(st.PoNumber, '12345');
        Test.stopTest();
    }

    /** @date 2/13/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for updateDataEventTransactionData() method
    */
    @IsTest(SeeAllData=false)
    static void updateDataEventTransactionData_Test() {
        Test.startTest();
        // Prepare data
        VDST_Event_gne__c ev = new VDST_Event_gne__c(CurrentStatus_gne__c = 'PENDING',
            CurrentStatusDate_gne__c = Date.today(), EventType_gne__c = 'RSCH',
            EventStartDate_gne__c = Date.today().addDays(-2), EventEndDate_gne__c = Date.today());
        insert ev;
        // Test data
        setEventAndTypeParams(ev.Id, null);
        VDST_EventDetailController edc = new VDST_EventDetailController();
        edc.initData();
        edc.prtcpntUtils.showParticipantList = true;
        edc.updateTransactionViews();
        VDST_EventPrtcpntAccnt_gne__c epa = new VDST_EventPrtcpntAccnt_gne__c(VDST_Event_gne__c = ev.Id);
        insert epa;
        edc.updateTransactionViews();
        System.assertEquals(edc.prtcpntUtils.showParticipantList, false);
        System.assertEquals(edc.ttlPlanAttCnt, 1);
        System.assertEquals(edc.evDateTransList.get(0).attendeesCount, 1);
        Test.stopTest();
    }

    /** @date 2/17/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for EventDateTransactions inner class
    */
    @IsTest(SeeAllData=false)
    static void EventDateTransactions_Test() {
        // Test null values
        VDST_Utils.EventDateTransactions edt = new VDST_Utils.EventDateTransactions(null, null, null, null, null);
        System.assertEquals(edt.totalFaB, 0.00);
        System.assertEquals(edt.inputTotalFaB, '0.00');
        System.assertEquals(edt.attendeesCount, 0);
        // Test correct values
        edt = new VDST_Utils.EventDateTransactions(String.valueOf(Date.today()), 12.23, 7, 'CFF', '1 meal/break');
        System.assertEquals(edt.totalFaB, 12.23);
        System.assertEquals(edt.inputTotalFaB, '12.23');
        System.assertEquals(edt.attendeesCount, 7);
        System.assertEquals(edt.eventType, 'CFF');
        System.assertEquals(edt.numberOfMeals, '1 meal/break');
    }

    /** @date 2/17/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for showParticipantList() method
    */
    @IsTest(SeeAllData=false)
    static void showParticipantList_Test() {
        // Prepare data
        ApexPages.currentPage().getParameters().put('type', 'CFF');
        VDST_EventDetailController edc = new VDST_EventDetailController();
        edc.initData();
        edc.prtcpntUtils.showParticipantList = false;
        // Test data
        edc.showParticipantList();
        System.assertEquals(edc.prtcpntUtils.showParticipantList, true);
    }

    /** @date 2/17/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for set status methods - part 1
    */
    @IsTest(SeeAllData=false)
    static void setStatusMethods1_Test() {
        Test.startTest();
        // Prepare data
        VDST_EventProvider_gne__c ep = new VDST_EventProvider_gne__c(VendorName_gne__c = 'Genentech', VendorCode_gne__c = 'GNE');
        insert ep;
        User u = prepareUser(2);
        System.runAs(u) {
            // Set parameters for ADBOARD - with access to edit
            VDST_User_gne__c usr = new VDST_User_gne__c(Role_gne__c = 'Provisioner', User_gne__c = u.Id, VDST_Event_Provider__c = ep.Id);
            insert usr;
            List<VDST_EventField_gne__c> efList = new List<VDST_EventField_gne__c>();
            // Wrong event type
            VDST_EventField_gne__c ef1 = new VDST_EventField_gne__c(EventType_gne__c = 'ADBOARD', EventStatus_gne__c = 'OCCURRED',
                FieldName_gne__c = 'EventEndDate_gne', FieldLabel_gne__c = 'Event End Date');
            efList.add(ef1);
            // Correct data
            VDST_EventField_gne__c ef2 = new VDST_EventField_gne__c(EventType_gne__c = 'CFF', EventStatus_gne__c = 'OCCURRED',
                FieldName_gne__c = 'VDST_Address_gne.Country_gne', FieldLabel_gne__c = 'Venue Country',
                IsRequired_gne__c = true, IsVisible_gne__c = true);
            efList.add(ef2);
            VDST_EventField_gne__c ef3 = new VDST_EventField_gne__c(EventType_gne__c = 'CFF', EventStatus_gne__c = 'OCCURRED',
                FieldName_gne__c = 'VDST_EventSite_gne.EventSiteName_gne', FieldLabel_gne__c = 'Venue Name',
                IsRequired_gne__c = true, IsVisible_gne__c = true);
            efList.add(ef3);
            VDST_EventField_gne__c ef4 = new VDST_EventField_gne__c(EventType_gne__c = 'CFF', EventStatus_gne__c = 'CLOSED',
                FieldName_gne__c = 'NOT_EXISTING_FIELD', FieldLabel_gne__c = 'Event End Date',
                IsRequired_gne__c = true, IsVisible_gne__c = true);
            efList.add(ef4);
            VDST_EventField_gne__c ef5 = new VDST_EventField_gne__c(EventType_gne__c = 'CFF', EventStatus_gne__c = 'CLOSED',
                FieldName_gne__c = 'EventStartDate_gne', FieldLabel_gne__c = 'Event Start Date',
                IsRequired_gne__c = true, IsVisible_gne__c = true);
            efList.add(ef5);
            VDST_EventField_gne__c ef6 = new VDST_EventField_gne__c(EventType_gne__c = 'CFF', EventStatus_gne__c = 'CLOSED',
                FieldName_gne__c = 'EventMeetingName_gne', FieldLabel_gne__c = 'Meeting Name',
                IsRequired_gne__c = true, IsVisible_gne__c = true);
            efList.add(ef6);
            insert efList;
            // Event
            VDST_Event_gne__c ev = new VDST_Event_gne__c(CurrentStatus_gne__c = 'PENDING',
                CurrentStatusDate_gne__c = Date.today(), EventType_gne__c = 'CFF', LogisticVendor_gne__c = ep.Id,
                EventStartDate_gne__c = Date.today().addDays(-2), EventEndDate_gne__c = Date.today());
            insert ev;
            setEventAndTypeParams(ev.Id, null);
            // Test setStatusToDropped()
            VDST_EventDetailController edc = new VDST_EventDetailController();
            edc.initData();
            PageReference pr = edc.setStatusToDropped();
            System.assertEquals(edc.eventCreateObject.CurrentStatus_gne__c, 'DROPPED');
            System.assertEquals(edc.eventCreateObject.CurrentStatusDate_gne__c, Date.today());
            System.assertEquals(pr.getUrl(), '/apex/VDST_EventList');
            System.assertEquals(edc.statusFieldMap.values().size(), 2);
            System.assertEquals(edc.actualMap.values().size(), 7);
            System.assertEquals(edc.actualMap.get('VDST_Address_gne.Country_gne').IsVisible_gne__c, true);
            // Test setStatusToCancel()
            //edc.setStatusToCanceled(); // Should not pass validation
            System.assertEquals(edc.eventCreateObject.CurrentStatus_gne__c, 'DROPPED');
            // Test setStatusToReopened()
            edc.setStatusToReopened();
            System.assertEquals(edc.eventCreateObject.CurrentStatus_gne__c, 'PENDING');
            System.assertEquals(edc.actualMap.values().size(), 7);
            System.assertEquals(edc.editableMode, true);
            edc.editableMode = false; // go back to RO mode
        }
        Test.stopTest();
    }

    /** @date 2/17/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for set status methods - part 2
    */
    @IsTest(SeeAllData=false)
    static void setStatusMethods2_Test() {
        Test.startTest();
        // Prepare data
        VDST_EventProvider_gne__c ep = new VDST_EventProvider_gne__c(VendorName_gne__c = 'Genentech', VendorCode_gne__c = 'GNE');
        insert ep;
        Product_vod__c pro1 = new Product_vod__c(Product_Type_vod__c = 'Detail', Detail_Product_Subtype_Code_gne__c = 'Brand',
            Brand_Code_gne__c = 'AVASTIN', Name = 'Avastin');
        insert pro1;
        VDST_EventPrtcpntRole_gne__c epr = new VDST_EventPrtcpntRole_gne__c(EventParticipantRoleCode_gne__c = 'VNDSTAFF',
            EventParticipantRoleName__c = 'Vendor Staff', EventType_gne__c = 'CFF');
        insert epr;
        VDST_EventPrtcpntField_gne__c epf = new VDST_EventPrtcpntField_gne__c(VDST_EventPrtcpntRole__c = epr.Id,
            FieldName_gne__c = 'FirstName_gne', FieldLabel_gne__c = 'First Name',
            IsRequired_gne__c = true, IsVisible_gne__c = true);
        insert epf;
        User u = prepareUser(2);
        System.runAs(u) {
            // Set parameters for ADBOARD - with access to edit
            VDST_User_gne__c usr = new VDST_User_gne__c(Role_gne__c = 'Provisioner', User_gne__c = u.Id, VDST_Event_Provider__c = ep.Id);
            insert usr;
            List<VDST_EventField_gne__c> efList = new List<VDST_EventField_gne__c>();
            // Wrong event type
            VDST_EventField_gne__c ef1 = new VDST_EventField_gne__c(EventType_gne__c = 'ADBOARD', EventStatus_gne__c = 'OCCURRED',
                FieldName_gne__c = 'EventEndDate_gne', FieldLabel_gne__c = 'Event End Date');
            efList.add(ef1);
            // Correct data
            VDST_EventField_gne__c ef2 = new VDST_EventField_gne__c(EventType_gne__c = 'CFF', EventStatus_gne__c = 'OCCURRED',
                FieldName_gne__c = 'VDST_Address_gne.Country_gne', FieldLabel_gne__c = 'Venue Country',
                IsRequired_gne__c = true, IsVisible_gne__c = true);
            efList.add(ef2);
            VDST_EventField_gne__c ef3 = new VDST_EventField_gne__c(EventType_gne__c = 'CFF', EventStatus_gne__c = 'OCCURRED',
                FieldName_gne__c = 'VDST_EventSite_gne.EventSiteName_gne', FieldLabel_gne__c = 'Venue Name',
                IsRequired_gne__c = true, IsVisible_gne__c = true);
            efList.add(ef3);
            VDST_EventField_gne__c ef4 = new VDST_EventField_gne__c(EventType_gne__c = 'CFF', EventStatus_gne__c = 'CLOSED',
                FieldName_gne__c = 'NOT_EXISTING_FIELD', FieldLabel_gne__c = 'Event End Date',
                IsRequired_gne__c = true, IsVisible_gne__c = true);
            efList.add(ef4);
            VDST_EventField_gne__c ef5 = new VDST_EventField_gne__c(EventType_gne__c = 'CFF', EventStatus_gne__c = 'CLOSED',
                FieldName_gne__c = 'EventStartDate_gne', FieldLabel_gne__c = 'Event Start Date',
                IsRequired_gne__c = true, IsVisible_gne__c = true);
            efList.add(ef5);
            VDST_EventField_gne__c ef6 = new VDST_EventField_gne__c(EventType_gne__c = 'CFF', EventStatus_gne__c = 'CLOSED',
                FieldName_gne__c = 'EventMeetingName_gne', FieldLabel_gne__c = 'Meeting Name',
                IsRequired_gne__c = true, IsVisible_gne__c = true);
            efList.add(ef6);
            insert efList;
            // Event
            VDST_Event_gne__c ev = new VDST_Event_gne__c(CurrentStatus_gne__c = 'PENDING',
                CurrentStatusDate_gne__c = Date.today(), EventType_gne__c = 'CFF', LogisticVendor_gne__c = ep.Id,
                EventStartDate_gne__c = Date.today().addDays(-2), EventEndDate_gne__c = Date.today());
            insert ev;
            VDST_Address_gne__c adr = new VDST_Address_gne__c();
            insert adr;
            VDST_EventSite_gne__c es = new VDST_EventSite_gne__c(VDST_Address_gne__c = adr.Id, VDST_Event_gne__c = ev.Id);
            insert es;
            setEventAndTypeParams(ev.Id, null);
            // Test setStatusToOccurred()
            VDST_EventDetailController edc = new VDST_EventDetailController();
            edc.initData();
            edc.setStatusToOccurred(); // Should not pass validation
            System.assertNotEquals(edc.eventCreateObject.CurrentStatus_gne__c, 'OCCURRED');
            System.assert(edc.editErrorMessages.contains('Empty Participants List'));
            VDST_EventPrtcpntAccnt_gne__c epa = new VDST_EventPrtcpntAccnt_gne__c(VDST_Event_gne__c = ev.Id,
                PartyType_gne__c = 'INDV');
            insert epa;
            edc.siteObject.EventSiteName_gne__c = 'Site name';
            edc.venueObject.Country_gne__c = 'USA';
            edc.setStatusToOccurred(); // Now it should pass validation
            System.assert(edc.editErrorMessages.contains('Participant Role'));
            epa.EventParticipantRole_gne__c = epr.Id;
            update epa;
            edc.setStatusToOccurred(); // Now it should pass validation
            System.debug(edc.editErrorMessages);
            System.assert(edc.editErrorMessages.contains('First Name'));
            epa.FirstName_gne__c = 'John';
            update epa;
            edc.setStatusToOccurred(); // Now it should pass validation
            System.debug(edc.editErrorMessages);
            System.assertEquals(edc.eventCreateObject.CurrentStatus_gne__c, 'OCCURRED');
        }
        Test.stopTest();
    }

    /** @date 2/17/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for set status methods - part 3
    */
    @IsTest(SeeAllData=false)
    static void setStatusMethods3_Test() {
        // Prepare data
        VDST_EventProvider_gne__c ep = new VDST_EventProvider_gne__c(VendorName_gne__c = 'Genentech', VendorCode_gne__c = 'GNE');
        insert ep;
        Product_vod__c pro1 = new Product_vod__c(Product_Type_vod__c = 'Detail', Detail_Product_Subtype_Code_gne__c = 'Brand',
            Brand_Code_gne__c = 'AVASTIN', Name = 'Avastin');
        insert pro1;
        List<VDST_EventPrtcpntRole_gne__c> eprList = new List<VDST_EventPrtcpntRole_gne__c>();
        VDST_EventPrtcpntRole_gne__c epr1 = new VDST_EventPrtcpntRole_gne__c(EventParticipantRoleCode_gne__c = 'VNDSTAFF',
            EventParticipantRoleName__c = 'Vendor Staff', EventType_gne__c = 'CFF');
        eprList.add(epr1);
        VDST_EventPrtcpntRole_gne__c epr2 = new VDST_EventPrtcpntRole_gne__c(EventParticipantRoleCode_gne__c = 'ATND',
            EventParticipantRoleName__c = 'Attendee', EventType_gne__c = 'CFF');
        eprList.add(epr2);
        VDST_EventPrtcpntRole_gne__c epr3 = new VDST_EventPrtcpntRole_gne__c(EventParticipantRoleCode_gne__c = 'ATND',
            EventParticipantRoleName__c = 'Attendee', EventType_gne__c = 'ADBOARD');
        eprList.add(epr3);
        insert eprList;
        List<VDST_EventPrtcpntField_gne__c> epfList = new List<VDST_EventPrtcpntField_gne__c>();
        VDST_EventPrtcpntField_gne__c epf1 = new VDST_EventPrtcpntField_gne__c(VDST_EventPrtcpntRole__c = epr1.Id,
            FieldName_gne__c = 'FirstName_gne', FieldLabel_gne__c = 'First Name',
            IsRequired_gne__c = true, IsVisible_gne__c = true);
        epfList.add(epf1);
        VDST_EventPrtcpntField_gne__c epf2 = new VDST_EventPrtcpntField_gne__c(VDST_EventPrtcpntRole__c = epr1.Id,
            FieldName_gne__c = 'LastName_gne', FieldLabel_gne__c = 'Last Name',
            IsRequired_gne__c = true, IsVisible_gne__c = true);
        epfList.add(epf2);
        VDST_EventPrtcpntField_gne__c epf3 = new VDST_EventPrtcpntField_gne__c(VDST_EventPrtcpntRole__c = epr2.Id,
            FieldName_gne__c = 'FirstName_gne', FieldLabel_gne__c = 'First Name',
            IsRequired_gne__c = true, IsVisible_gne__c = true);
        epfList.add(epf3);
        VDST_EventPrtcpntField_gne__c epf4 = new VDST_EventPrtcpntField_gne__c(VDST_EventPrtcpntRole__c = epr3.Id,
            FieldName_gne__c = 'FirstName_gne', FieldLabel_gne__c = 'First Name',
            IsRequired_gne__c = true, IsVisible_gne__c = true);
        epfList.add(epf4);
        insert epfList;
        User u = prepareUser(2);
        System.runAs(u) {
            // Set parameters for ADBOARD - with access to edit
            VDST_User_gne__c usr = new VDST_User_gne__c(Role_gne__c = 'Provisioner', User_gne__c = u.Id, VDST_Event_Provider__c = ep.Id);
            insert usr;
            List<VDST_EventField_gne__c> efList = new List<VDST_EventField_gne__c>();
            // Wrong event type
            VDST_EventField_gne__c ef1 = new VDST_EventField_gne__c(EventType_gne__c = 'ADBOARD', EventStatus_gne__c = 'OCCURRED',
                FieldName_gne__c = 'EventEndDate_gne', FieldLabel_gne__c = 'Event End Date');
            efList.add(ef1);
            // Correct data
            VDST_EventField_gne__c ef2 = new VDST_EventField_gne__c(EventType_gne__c = 'CFF', EventStatus_gne__c = 'OCCURRED',
                FieldName_gne__c = 'VDST_Address_gne.Country_gne', FieldLabel_gne__c = 'Venue Country',
                IsRequired_gne__c = true, IsVisible_gne__c = true);
            efList.add(ef2);
            VDST_EventField_gne__c ef3 = new VDST_EventField_gne__c(EventType_gne__c = 'CFF', EventStatus_gne__c = 'OCCURRED',
                FieldName_gne__c = 'VDST_EventSite_gne.EventSiteName_gne', FieldLabel_gne__c = 'Venue Name',
                IsRequired_gne__c = true, IsVisible_gne__c = true);
            efList.add(ef3);
            VDST_EventField_gne__c ef4 = new VDST_EventField_gne__c(EventType_gne__c = 'CFF', EventStatus_gne__c = 'CLOSED',
                FieldName_gne__c = 'NOT_EXISTING_FIELD', FieldLabel_gne__c = 'Event End Date',
                IsRequired_gne__c = true, IsVisible_gne__c = true);
            efList.add(ef4);
            VDST_EventField_gne__c ef5 = new VDST_EventField_gne__c(EventType_gne__c = 'CFF', EventStatus_gne__c = 'CLOSED',
                FieldName_gne__c = 'EventStartDate_gne', FieldLabel_gne__c = 'Event Start Date',
                IsRequired_gne__c = true, IsVisible_gne__c = true);
            efList.add(ef5);
            VDST_EventField_gne__c ef6 = new VDST_EventField_gne__c(EventType_gne__c = 'CFF', EventStatus_gne__c = 'CLOSED',
                FieldName_gne__c = 'EventMeetingName_gne', FieldLabel_gne__c = 'Meeting Name',
                IsRequired_gne__c = true, IsVisible_gne__c = true);
            efList.add(ef6);
            VDST_EventField_gne__c ef7 = new VDST_EventField_gne__c(EventType_gne__c = 'CFF', EventStatus_gne__c = 'AttMealStatus',
                FieldName_gne__c = 'MealStatus', FieldLabel_gne__c = 'Meal Status',
                IsRequired_gne__c = true, IsVisible_gne__c = true);
            efList.add(ef7);
            insert efList;
            // Event
            VDST_Event_gne__c ev = new VDST_Event_gne__c(CurrentStatus_gne__c = 'PENDING',
                CurrentStatusDate_gne__c = Date.today(), EventType_gne__c = 'CFF', LogisticVendor_gne__c = ep.Id,
                EventStartDate_gne__c = Date.today().addDays(-2), EventEndDate_gne__c = Date.today());
            insert ev;
            VDST_Address_gne__c adr = new VDST_Address_gne__c(Country_gne__c = 'USA');
            insert adr;
            VDST_EventSite_gne__c es = new VDST_EventSite_gne__c(VDST_Address_gne__c = adr.Id, VDST_Event_gne__c = ev.Id,
                EventSiteName_gne__c = 'Site name');
            insert es;
            VDST_EventPrtcpntAccnt_gne__c epa = new VDST_EventPrtcpntAccnt_gne__c(VDST_Event_gne__c = ev.Id,
                PartyType_gne__c = 'INDV', FirstName_gne__c = 'John', LastName_gne__c = 'Walker',
                EventParticipantRole_gne__c = epr1.Id);
            insert epa;
            setEventAndTypeParams(ev.Id, null);
            VDST_EventDetailController edc = new VDST_EventDetailController();
            edc.initData();
            // Test setPrtcpntRoleFIeldsMap() Method
            System.assertEquals(edc.prtcpntFieldMap.size(), 2);
            System.assertEquals(edc.prtcpntFieldMap.get(epr1.Id).size(), 2);
            // Test setStatusFieldsMap() Method
            System.assertEquals(edc.statusFieldMap.size(), 3);
            System.assertEquals(edc.statusFieldMap.get('CLOSED').size(), 8); // Extra values
            System.assertEquals(edc.showMealStatus, true);
            // Test setStatusToClosed()
            edc.setStatusToClosed(); // Should not pass validation
            System.assert(edc.editErrorMessages.contains('Meeting Name'));
            System.assert(edc.editErrorMessages.contains('Can not find field'));
            System.assert(edc.editErrorMessages.contains('Brand(s)'));
            System.assertNotEquals(edc.eventCreateObject.CurrentStatus_gne__c, 'CLOSED');
            ev.EventMeetingName_gne__c = 'Test Name';
            update ev;
            delete ef4;
            Test.startTest();
            edc = new VDST_EventDetailController(); // Need to run constructor for reloading data
            edc.initData();
            edc.multiDrugNames = new List<String>{pro1.Id};
            edc.setBrandValues();
            System.debug(edc.editErrorMessages);
            edc.setStatusToClosed(); // Now it should pass validation
            System.assertEquals(edc.eventCreateObject.CurrentStatus_gne__c, 'CLOSED');
            // Test setStatusToReopened()
            edc.setStatusToReopened();
            System.assertEquals(edc.eventCreateObject.CurrentStatus_gne__c, 'OCCURRED');
            Test.stopTest();
        }
    }

    /** @date 2/19/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for set status methods - part 4
    */
    @IsTest(SeeAllData=false)
    static void setStatusMethods4_Test() {
        // Prepare data
        Product_vod__c pro1 = new Product_vod__c(Product_Type_vod__c = 'Detail', Detail_Product_Subtype_Code_gne__c = 'Brand',
            Brand_Code_gne__c = 'AVASTIN', Name = 'Avastin');
        insert pro1;
        VDST_EventProvider_gne__c ep = new VDST_EventProvider_gne__c(VendorName_gne__c = 'Genentech', VendorCode_gne__c = 'GNE');
        insert ep;
        List<VDST_EventPrtcpntRole_gne__c> eprList = new List<VDST_EventPrtcpntRole_gne__c>();
        VDST_EventPrtcpntRole_gne__c epr1 = new VDST_EventPrtcpntRole_gne__c(EventParticipantRoleCode_gne__c = 'PAYEE',
            EventParticipantRoleName__c = 'Payee', EventType_gne__c = 'INDVSPND');
        eprList.add(epr1);
        VDST_EventPrtcpntRole_gne__c epr2 = new VDST_EventPrtcpntRole_gne__c(EventParticipantRoleCode_gne__c = 'PI',
            EventParticipantRoleName__c = 'PI', EventType_gne__c = 'INDVSPND');
        eprList.add(epr2);
        insert eprList;
        VDST_EventPrtcpntField_gne__c epf = new VDST_EventPrtcpntField_gne__c(VDST_EventPrtcpntRole__c = epr1.Id,
            FieldName_gne__c = 'FirstName_gne', FieldLabel_gne__c = 'First Name',
            IsRequired_gne__c = true, IsVisible_gne__c = true);
        User u = prepareUser(2);
        System.runAs(u) {
            // Set parameters for ADBOARD - with access to edit
            VDST_User_gne__c usr = new VDST_User_gne__c(Role_gne__c = 'Provisioner', User_gne__c = u.Id, VDST_Event_Provider__c = ep.Id);
            insert usr;
            // Event
            VDST_Event_gne__c ev = new VDST_Event_gne__c(CurrentStatus_gne__c = 'PENDING',
                CurrentStatusDate_gne__c = Date.today(), EventType_gne__c = 'INDVSPND', LogisticVendor_gne__c = ep.Id,
                EventStartDate_gne__c = Date.today().addDays(-2), EventEndDate_gne__c = Date.today(),
                EventMeetingName_gne__c = 'Test Name', SupplementStatusCode_gne__c = 'SUPPLMT');
            insert ev;
            VDST_Address_gne__c adr = new VDST_Address_gne__c();
            insert adr;
            VDST_EventSite_gne__c es = new VDST_EventSite_gne__c(VDST_Address_gne__c = adr.Id, VDST_Event_gne__c = ev.Id);
            insert es;
            VDST_EventPrtcpntAccnt_gne__c epa = new VDST_EventPrtcpntAccnt_gne__c(VDST_Event_gne__c = ev.Id,
                PartyType_gne__c = 'INDV', FirstName_gne__c = 'John', EventParticipantRole_gne__c = epr2.Id);
            insert epa;
            Test.startTest();
            setEventAndTypeParams(ev.Id, null);
            VDST_EventDetailController edc = new VDST_EventDetailController();
            edc.initData();
            // Test setStatusToClosed()
            edc.setStatusToClosed(); // Should not pass validation
            System.assertNotEquals(edc.eventCreateObject.CurrentStatus_gne__c, 'CLOSED');
            ev.ItemAmount_gne__c = 12.23;
            update ev;
            System.assert(edc.editErrorMessages.contains('at least one Expense Amount'));
            VDST_EventTransactionSummary_gne__c ets = new VDST_EventTransactionSummary_gne__c(EventTransactionAmount_gne__c = 23.32,
                EventTransactionLevel_gne__c = 'EVNT', EventTransactionTypeCode_gne__c = 'EVTOOPLODG', VDST_Event_gne__c = ev.Id);
            insert ets;
            System.assert(edc.editErrorMessages.contains('Payee Participant Role is required'));
            epa.EventParticipantRole_gne__c = epr1.Id;
            update epa;
            System.assert(edc.editErrorMessages.contains('Missing configuration'));
            insert epf;
            edc = new VDST_EventDetailController(); // Reload data
            edc.initData();
            // Should not pass validation
            edc.setStatusToClosed();
            System.assert(edc.editErrorMessages.contains('Amount Balance must'));
            ev.ItemAmount_gne__c = 23.32;
            update ev;
            System.assert(edc.editErrorMessages.contains('Postal Code is required for Out Of Pocket'));
            es.EventSiteName_gne__c = 'Site Name';
            update es;
            adr.City_gne__c = 'South San Francisco';
            adr.Country_gne__c = 'USA';
            adr.PostalCode_gne__c = '10-232';
            adr.StateProvince_gne__c = 'CA';
            adr.StreetAddress_gne__c = '1DNA';
            update adr;
            edc = new VDST_EventDetailController(); // Reload data
            edc.initData();
            edc.multiDrugNames = new List<String>{pro1.Id};
            edc.setBrandValues();
            // Now it should pass validation
            edc.setStatusToClosed();
            System.assertEquals(edc.eventCreateObject.CurrentStatus_gne__c, 'CLOSED');
            Test.stopTest();
        }
    }

    /** @date 2/19/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for set status methods - part 5
    */
    @IsTest(SeeAllData=false)
    static void setStatusMethods5_Test() {
        // Prepare data
        Product_vod__c pro1 = new Product_vod__c(Product_Type_vod__c = 'Detail', Detail_Product_Subtype_Code_gne__c = 'Brand',
            Brand_Code_gne__c = 'AVASTIN', Name = 'Avastin');
        insert pro1;
        VDST_EventProvider_gne__c ep = new VDST_EventProvider_gne__c(VendorName_gne__c = 'Genentech', VendorCode_gne__c = 'GNE');
        insert ep;
        List<VDST_EventPrtcpntRole_gne__c> eprList = new List<VDST_EventPrtcpntRole_gne__c>();
        VDST_EventPrtcpntRole_gne__c epr1 = new VDST_EventPrtcpntRole_gne__c(EventParticipantRoleCode_gne__c = 'PAYEE',
            EventParticipantRoleName__c = 'Payee', EventType_gne__c = 'RSCH');
        eprList.add(epr1);
        VDST_EventPrtcpntRole_gne__c epr2 = new VDST_EventPrtcpntRole_gne__c(EventParticipantRoleCode_gne__c = 'PI',
            EventParticipantRoleName__c = 'PI', EventType_gne__c = 'RSCH');
        eprList.add(epr2);
        VDST_EventPrtcpntRole_gne__c epr3 = new VDST_EventPrtcpntRole_gne__c(EventParticipantRoleCode_gne__c = 'PAYEEPI',
            EventParticipantRoleName__c = 'Payee-PI', EventType_gne__c = 'RSCH');
        eprList.add(epr3);
        insert eprList;
        List<VDST_EventPrtcpntField_gne__c> epfList = new List<VDST_EventPrtcpntField_gne__c>();
        VDST_EventPrtcpntField_gne__c epf1 = new VDST_EventPrtcpntField_gne__c(VDST_EventPrtcpntRole__c = epr1.Id,
            FieldName_gne__c = 'FirstName_gne', FieldLabel_gne__c = 'First Name',
            IsRequired_gne__c = true, IsVisible_gne__c = true);
        epfList.add(epf1);
        VDST_EventPrtcpntField_gne__c epf2 = new VDST_EventPrtcpntField_gne__c(VDST_EventPrtcpntRole__c = epr1.Id,
            FieldName_gne__c = 'WRONG_FIELD_NAME', FieldLabel_gne__c = 'Wrong Field',
            IsRequired_gne__c = true, IsVisible_gne__c = true);
        epfList.add(epf2);
        VDST_EventPrtcpntField_gne__c epf3 = new VDST_EventPrtcpntField_gne__c(VDST_EventPrtcpntRole__c = epr3.Id,
            FieldName_gne__c = 'FirstName_gne', FieldLabel_gne__c = 'First Name',
            IsRequired_gne__c = true, IsVisible_gne__c = true);
        epfList.add(epf3);
        insert epfList;
        User u = prepareUser(2);
        System.runAs(u) {
            // Set parameters for Research - with access to edit
            VDST_User_gne__c usr = new VDST_User_gne__c(Role_gne__c = 'Provisioner', User_gne__c = u.Id, VDST_Event_Provider__c = ep.Id);
            insert usr;
            // Event
            VDST_Event_gne__c ev = new VDST_Event_gne__c(CurrentStatus_gne__c = 'PENDING',
                CurrentStatusDate_gne__c = Date.today(), EventType_gne__c = 'RSCH', LogisticVendor_gne__c = ep.Id,
                EventStartDate_gne__c = Date.today().addDays(-2), EventEndDate_gne__c = Date.today(),
                EventMeetingName_gne__c = 'Test Name', ItemAmount_gne__c = 23.32);
            insert ev;
            VDST_Address_gne__c adr = new VDST_Address_gne__c(Country_gne__c = 'USA');
            insert adr;
            VDST_EventSite_gne__c es = new VDST_EventSite_gne__c(VDST_Address_gne__c = adr.Id, VDST_Event_gne__c = ev.Id,
                EventSiteName_gne__c = 'Site name');
            insert es;
            VDST_Address_gne__c accAdr = new VDST_Address_gne__c(City_gne__c = 'South San Francisco', Country_gne__c = 'USA', PostalCode_gne__c = '10-232', StateProvince_gne__c = 'CA', StreetAddress_gne__c = '1DNA');
            insert accAdr;
            VDST_EventPrtcpntAccnt_gne__c epa = new VDST_EventPrtcpntAccnt_gne__c(VDST_Event_gne__c = ev.Id, VDST_Address_gne__c = accAdr.Id,
                PartyType_gne__c = 'INDV', FirstName_gne__c = 'John', EventParticipantRole_gne__c = epr1.Id);
            insert epa;
            VDST_EventTransactionSummary_gne__c ets = new VDST_EventTransactionSummary_gne__c(EventTransactionAmount_gne__c = 23.32,
                EventTransactionLevel_gne__c = 'EVNT', EventTransactionTypeCode_gne__c = 'EVTOOPLODG', VDST_Event_gne__c = ev.Id);
            insert ets;
            Test.startTest();
            setEventAndTypeParams(ev.Id, null);
            VDST_EventDetailController edc = new VDST_EventDetailController();
            edc.initData();
            // Test setStatusToClosed()
            edc.setStatusToClosed(); // Should not pass validation
            System.assert(edc.editErrorMessages.contains('Participant with PI Participant'));
            epa.EventParticipantRole_gne__c = epr3.Id;
            update epa;
            edc = new VDST_EventDetailController(); // Reload data
            edc.initData();
            edc.multiDrugNames = new List<String>{pro1.Id};
            edc.setBrandValues();
            edc.setStatusToClosed(); // Now it should pass validation
            System.assertEquals(edc.venueObject.City_gne__c, 'South San Francisco');
            System.assertEquals(edc.eventCreateObject.CurrentStatus_gne__c, 'CLOSED');
            Test.stopTest();
        }
    }

    /** @date 2/23/2014
    * @Author Pawel Sprysak
    * @description Test Method - test generateVendorEventId(VDST_Event_gne__c) method
    */
    @IsTest(SeeAllData=false)
    static void generateVendorEventId_Test() {
        Test.startTest();
        // Prepare test data
        VDST_Event_gne__c ev_noCode = new VDST_Event_gne__c(CurrentStatus_gne__c = 'PENDING',
            CurrentStatusDate_gne__c = Date.today(), EventType_gne__c = 'RSCH',
            EventStartDate_gne__c = Date.today().addDays(-2), EventEndDate_gne__c = Date.today(),
            EventMeetingName_gne__c = 'Test Name', ItemAmount_gne__c = 23.32);
        insert ev_noCode;
        setEventAndTypeParams(ev_noCode.Id, null);
        VDST_EventDetailController edc = new VDST_EventDetailController();
        edc.initData();
        // should return false (no Logistic Code and assigned user)
        edc.setStatusToCanceled();
        System.assertEquals(edc.eventCreateObject.VendorEventID_gne__c, null);
        // Prepare test data
        User u = prepareUser(2);
        System.runAs(u) {
            // Set parameters for Research - with access to edit
            VDST_EventProvider_gne__c ep = new VDST_EventProvider_gne__c(VendorName_gne__c = 'Genentech', VendorCode_gne__c = 'GNE');
            insert ep;
            VDST_User_gne__c usr = new VDST_User_gne__c(Role_gne__c = 'Provisioner', User_gne__c = u.Id, VDST_Event_Provider__c = ep.Id);
            insert usr;
            VDST_Event_gne__c ev = new VDST_Event_gne__c(CurrentStatus_gne__c = 'PENDING',
                CurrentStatusDate_gne__c = Date.today(), EventType_gne__c = 'RSCH', LogisticVendor_gne__c = ep.Id,
                EventStartDate_gne__c = Date.today().addDays(-2), EventEndDate_gne__c = Date.today(),
                EventMeetingName_gne__c = 'Test Name', ItemAmount_gne__c = 23.32);
            insert ev;
            VDST_Address_gne__c addressObject = new VDST_Address_gne__c();
            insert addressObject;
            VDST_EventSite_gne__c siteObject = new VDST_EventSite_gne__c(VDST_Address_gne__c = addressObject.Id, VDST_Event_gne__c = ev.Id);
            insert siteObject;
            setEventAndTypeParams(ev.Id, null);
            edc = new VDST_EventDetailController();
            edc.initData();
            // Test generateVendorEventId() method
            // should generate via util method
            edc.setStatusToCanceled();
            System.assertNotEquals(edc.eventCreateObject.VendorEventID_gne__c, null);
            System.assert(edc.eventCreateObject.VendorEventID_gne__c.startsWith('GNE_'));
            // should add prefix
            edc.eventCreateObject.VendorEventID_gne__c = '146099162154030285';
            ev.VendorEventID_gne__c = '146099162154030285';
            update ev;
            edc.setStatusToCanceled();
            System.debug(edc.editErrorMessages);
            System.assertEquals(edc.eventCreateObject.VendorEventID_gne__c, 'GNE_146099162154030285');
        }
        Test.stopTest();
    }

    /** @date 2/23/2014
    * @Author Pawel Sprysak
    * @description Test Method - test generateVendorParticipantIds(List<VDST_EventPrtcpntAccnt_gne__c>) method
    */
    @IsTest(SeeAllData=false)
    static void generateVendorParticipantIds_Test() {
        Test.startTest();
        // Prepare test data
        User u = prepareUser(2);
        System.runAs(u) {
            // Set parameters for Research - with access to edit
            VDST_EventProvider_gne__c ep = new VDST_EventProvider_gne__c(VendorName_gne__c = 'Genentech', VendorCode_gne__c = 'GNE');
            insert ep;
            VDST_User_gne__c usr = new VDST_User_gne__c(Role_gne__c = 'Provisioner', User_gne__c = u.Id, VDST_Event_Provider__c = ep.Id);
            insert usr;
            VDST_Event_gne__c ev = new VDST_Event_gne__c(CurrentStatus_gne__c = 'PENDING',
                CurrentStatusDate_gne__c = Date.today(), EventType_gne__c = 'RSCH', LogisticVendor_gne__c = ep.Id,
                EventStartDate_gne__c = Date.today().addDays(-2), EventEndDate_gne__c = Date.today(),
                EventMeetingName_gne__c = 'Test Name', ItemAmount_gne__c = 23.32);
            insert ev;
            VDST_Address_gne__c addressObject = new VDST_Address_gne__c();
            insert addressObject;
            VDST_EventSite_gne__c siteObject = new VDST_EventSite_gne__c(VDST_Address_gne__c = addressObject.Id, VDST_Event_gne__c = ev.Id);
            insert siteObject;
            VDST_Address_gne__c epa1AdrObj = new VDST_Address_gne__c();
            insert epa1AdrObj;
            VDST_EventPrtcpntAccnt_gne__c epa1 = new VDST_EventPrtcpntAccnt_gne__c(VDST_Event_gne__c = ev.Id, VDST_Address_gne__c = epa1AdrObj.Id);
            insert epa1;
            VDST_EventPrtcpntAccnt_gne__c epa2 = new VDST_EventPrtcpntAccnt_gne__c(VDST_Event_gne__c = ev.Id,
                VendorParticipantID_gne__c = 'test123', VDST_Address_gne__c = epa1AdrObj.Id);
            insert epa2;
            System.debug(epa1.Id);
            setEventAndTypeParams(ev.Id, null);
            VDST_EventDetailController edc = new VDST_EventDetailController();
            edc.initData();
            // Test generateVendorParticipantIds() method
            edc.setStatusToCanceled();
            VDST_EventPrtcpntAccnt_gne__c firstPrtcpnt = [SELECT VendorParticipantID_gne__c FROM VDST_EventPrtcpntAccnt_gne__c WHERE Id = :epa1.Id];
            VDST_EventPrtcpntAccnt_gne__c secondPrtcpnt = [SELECT VendorParticipantID_gne__c FROM VDST_EventPrtcpntAccnt_gne__c WHERE Id = :epa2.Id];
            System.debug(edc.editErrorMessages);
            System.assertNotEquals(firstPrtcpnt.VendorParticipantID_gne__c, null);
            System.assert(firstPrtcpnt.VendorParticipantID_gne__c.startsWith('GNE_'));
            System.assertEquals(secondPrtcpnt.VendorParticipantID_gne__c, 'GNE_test123');
            // Only one change - one blank Participant, other remain unchanged
            VDST_EventPrtcpntAccnt_gne__c epa3 = new VDST_EventPrtcpntAccnt_gne__c(VDST_Event_gne__c = ev.Id,
                VendorParticipantID_gne__c = 'test1234');
            insert epa3;
            edc.setStatusToCanceled();
            VDST_EventPrtcpntAccnt_gne__c thirdPrtcpnt = [SELECT VendorParticipantID_gne__c FROM VDST_EventPrtcpntAccnt_gne__c WHERE Id = :epa3.Id];
            System.assertEquals(thirdPrtcpnt.VendorParticipantID_gne__c, 'GNE_test1234');
        }
        Test.stopTest();
    }

    /** @date 2/19/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for set attachment methods
    */
    @IsTest(SeeAllData=false)
    static void setEventAttachmentMethods_Test() {
        Test.startTest();
        // Prepare test data
        VDST_Event_gne__c ev = new VDST_Event_gne__c(CurrentStatus_gne__c = 'PENDING',
            CurrentStatusDate_gne__c = Date.today(), EventType_gne__c = 'RSCH',
            EventStartDate_gne__c = Date.today().addDays(-2), EventEndDate_gne__c = Date.today(),
            EventMeetingName_gne__c = 'Test Name', ItemAmount_gne__c = 23.32);
        insert ev;
        Attachment att = new Attachment(ParentId = ev.Id, Name = 'testFile', Body = Blob.valueOf('testFile'));
        insert att;
        setEventAndTypeParams(null, 'CFF');
        VDST_EventDetailController edc = new VDST_EventDetailController();
        edc.initData();
        // Test setEventAttachment() method
        // Create event mode
        edc.setEventAttachment();
        System.assertEquals(edc.eventAttachment, null);
        // Edit event mode
        setEventAndTypeParams(ev.Id, null);
        edc = new VDST_EventDetailController();
        edc.initData();
        edc.setEventAttachment();
        System.assertNotEquals(edc.eventAttachment, null);
        // Test insertAttachmentJS() method
        delete att; // Reset attachment data and start checking methods
        ApexPages.currentPage().getParameters().put('fileContent', '12345');
        ApexPages.currentPage().getParameters().put('fileName', 'testFile.csv');
        edc.insertAttachmentJS(); // TODO: problem with this
        System.assertEquals(edc.eventAttachment.Name, 'testFile.csv');
        Id idValue = edc.eventAttachment.Id; // TODO: Null Pointer
        // Test overwriteAttachmentJS() method
        ApexPages.currentPage().getParameters().put('fileContent', '12345');
        ApexPages.currentPage().getParameters().put('fileName', 'testFile2.csv');
        edc.overwriteAttachmentJS();
        System.assertEquals(edc.eventAttachment.Name, 'testFile2.csv');
        System.assertEquals(edc.eventAttachment.Id, idValue);
        // Test deleteAttachment() method - before next insert
        edc.deleteAttachment();
        System.assertEquals(edc.eventAttachment, null);
        // Test insertAttachmentController() method
        ApexPages.currentPage().getParameters().put('fileContent', null);
        ApexPages.currentPage().getParameters().put('fileName', null);
        edc.FileBody = Blob.valueOf('testFile3');
        edc.FileName = 'testFile3.csv';
        edc.insertAttachmentController();
        System.assertEquals(edc.eventAttachment.Name, 'testFile3.csv');

        // Test overwriteAttachmentController() method
        edc.FileBody = Blob.valueOf('testFile4');
        edc.FileName = 'testFile4.csv';
        edc.overwriteAttachmentController();
        System.assertEquals(edc.eventAttachment.Name, 'testFile4.csv');
        // Test deleteAttachment() method
        edc.deleteAttachment();
        System.assertEquals(edc.eventAttachment, null);
        Test.stopTest();
    }

    /** @date 2/23/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for setBrandIds() method
    */
    @IsTest(SeeAllData=false)
    static void setBrandIds_Test() {
        // Prepare data
        VDST_EventDetailController edc = new VDST_EventDetailController();
        edc.initData();
        // no data test
        edc.multiDrugNamesTxt = '';
        edc.multiDrugNamesIds = '';
        edc.setBrandIds();
        System.assert(edc.multiDrugNames == null || edc.multiDrugNames.isEmpty());
        // with data test
        edc.multiDrugNamesTxt = 'Avastin,Actemra';
        edc.multiDrugNamesIds = 'someId,someId2';
        edc.setBrandIds();
        System.assertEquals(edc.multiDrugNames.size(), 2);
    }

    /** @date 2/23/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for getUserData() method
    */
    @IsTest(SeeAllData=false)
    static void getUserData_Test() {
        // Test data
        All_User_Hierarchy_gne__c uh = new All_User_Hierarchy_gne__c(FirstName_gne__c = 'FN', LastName_gne__c = 'LN',
            User_External_Id_gne__c = 'unixId');
        insert uh;
        // null user
        VDST_EventDetailController.UserWrapper uw = VDST_EventDetailController.getUserData('');
        System.assertNotEquals(uw, null);
        System.assertEquals(uw.firstName, '');
        // incorrect user
        uw = VDST_EventDetailController.getUserData('abc');
        System.assertEquals(uw, null);
        // correct data
        uw = VDST_EventDetailController.getUserData('unixId');
        System.assertNotEquals(uw, null);
        System.assertEquals(uw.firstName, 'FN');
    }

    /** @date 2/23/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for isVendorEventIdUnique() method
    */
    @IsTest(SeeAllData=false)
    static void isVendorEventIdUnique_Test() {
        // Prepare data
        VDST_EventProvider_gne__c ep = new VDST_EventProvider_gne__c(VendorName_gne__c = 'Genentech', VendorCode_gne__c = 'GNE');
        insert ep;
        VDST_Event_gne__c ev = new VDST_Event_gne__c(CurrentStatus_gne__c = 'PENDING',
            CurrentStatusDate_gne__c = Date.today(), EventType_gne__c = 'RSCH', LogisticVendor_gne__c = ep.Id,
            EventStartDate_gne__c = Date.today().addDays(-2), EventEndDate_gne__c = Date.today(),
            EventMeetingName_gne__c = 'Test Name', ItemAmount_gne__c = 23.32, VendorEventID_gne__c = 'GNE_abc');
        insert ev;
        // test data - unique
        System.assertEquals(VDST_EventDetailController.isVendorEventIdUnique('abc', 'abc', 'GNE', 'GNE'), false);
        System.assertEquals(VDST_EventDetailController.isVendorEventIdUnique('abe', 'abe', 'GNE', 'GNE'), true);
    }

    /** @date 2/23/2014
    * @Author Pawel Sprysak
    * @description Test Method - Test for isVendorParticipantIdUnique() method
    */
    @IsTest(SeeAllData=false)
    static void isVendorParticipantIdUnique_Test() {
        // Prepare data
        VDST_EventProvider_gne__c ep = new VDST_EventProvider_gne__c(VendorName_gne__c = 'Genentech', VendorCode_gne__c = 'GNE');
        insert ep;
        VDST_Event_gne__c ev = new VDST_Event_gne__c(CurrentStatus_gne__c = 'PENDING',
            CurrentStatusDate_gne__c = Date.today(), EventType_gne__c = 'RSCH', LogisticVendor_gne__c = ep.Id,
            EventStartDate_gne__c = Date.today().addDays(-2), EventEndDate_gne__c = Date.today(),
            EventMeetingName_gne__c = 'Test Name', ItemAmount_gne__c = 23.32, VendorEventID_gne__c = 'GNE_abc');
        insert ev;
        VDST_EventPrtcpntAccnt_gne__c epa = new VDST_EventPrtcpntAccnt_gne__c(VDST_Event_gne__c = ev.Id,
            VendorParticipantID_gne__c = 'GNE_test123');
        insert epa;
        // test data - unique
        System.assertEquals(VDST_EventDetailController.isVendorParticipantIdUnique('test123', 'test123', 'GNE', 'GNE'), false);
        System.assertEquals(VDST_EventDetailController.isVendorParticipantIdUnique('test124', 'test124', 'GNE', 'GNE'), true);
    }
    
    @IsTest(SeeAllData=false)
    static void CheckSupplemntTransaction_Test() {
        // Prepare data
        PageReference myVfPage = Page.VDST_EventDetail;
        Test.setCurrentPage(myVfPage);
        AGS_Spend_Expense_Transaction_gne__c agSSPEND = new AGS_Spend_Expense_Transaction_gne__c(LogicalDeleteFlag_gne__c = false,Source_System_Code_gne__c = 'SAPBW',REPORT_CODE_GNE__C='XC_MON',Research_Pymt_Typ_Cd_gne__c='CLINICAL');
        insert agSSPEND;
        VDST_EventDetailController vdstEventDetail = new VDST_EventDetailController();
        System.currentPageReference().getParameters().put('srcTxnId', agSSPEND.Event_ID_gne__c);
        Test.startTest();
        vdstEventDetail.initData();
        Test.stopTest();
        System.assertEquals(vdstEventDetail.eventCreateObject.TransactionID_gne__c,agSSPEND.Event_ID_gne__c);
    }
    
    /** @date 2/11/2014
    * @Author Pawel Sprysak
    * @description Internal method for preparing user data
    */
    private static User prepareUser(Integer userNo) {
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
    private static void setEventAndTypeParams(String evId, String evType) {
        ApexPages.currentPage().getParameters().put('event', evId);
        ApexPages.currentPage().getParameters().put('type', evType);
    }
}