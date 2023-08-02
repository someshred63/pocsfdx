@isTest
private class EMS_Related_List_Controller_Test {

    private static final Integer recordsLimit = 10;

    @isTest static void eventLayout_relatedlist_test_updateGenerationTimestamp() {
        Decimal amount = 100;
        String etype = 'Sponsorship';
        String esubtype = 'Sponsorship of Events';

        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        GNE_SFA2_User_App_Context_gne__c appContext = new GNE_SFA2_User_App_Context_gne__c(
                Name = 'GNE SFA2 User Application Context (User)',
                SetupOwnerId = UserInfo.getUserId(),
                App_Name_gne__c = 'EMS-Canada',
                Role_gne__c = 'Admin',
                Run_in_SFA2_UI_gne__c = true,
                SFA2_Mode_gne__c = true,
                Brand_gne__c = 'My Brand'
        );
        insert appContext;

        SFA2_Configuration_Object_gne__c configObject = new SFA2_Configuration_Object_gne__c(
                Name = 'EMS_Event__c_rl',
                Role_gne__c = 'Admin',
                Object_Name_gne__c = 'EMS_Event__c',
                Record_Type_gne__c = 'EMS_Event',
                Configuration_Type_gne__c = 'Page',
                Brand_gne__c = 'My Brand',
                Order_gne__c = 0,
                Style_gne__c = '',
                Attributes_gne__c = '',
                Is_Active_gne__c = true,
                Application_Type__c = 'EMS-Canada'
        );
        insert configObject;

        SFA2_Configuration_Object_Detail_gne__c configObjectDetail = new SFA2_Configuration_Object_Detail_gne__c(
                Configuration_Object_ref_gne__c = configObject.Id,
                Name = 'EMS_Speaker_Role_gne__c',
                API_Name_gne__c = 'EMS_Speaker_Role_gne__c',
                Label_gne__c = 'Payment Requests',
                Attributes_gne__c = 'fieldsCSV=Name#/,HCP_HCO_iHCP_gne__c,Account_Type_gne__c,Total_Amount_gne__c,Payment_Date_gne__c,Status_gne__c;orderByFieldName=NAME;hideEditLink=false;hideDeleteLink=false;pageSize=5;parentFieldName=EMS_Event_gne__c;sortDirection=DESC;hideButtons=true;',
                Is_Read_Only_gne__c = false,
                Is_Required_gne__c = false,
                Order_gne__c = 3,
                Type_gne__c = 'Related List',
                Availability_Mode_gne__c = 'View',
                Is_Active_gne__c = true
        );
        insert configObjectDetail;

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 10 * amount, pmUser, costCenters);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(etype, esubtype, costCenters[0]);
        EMS_Event__c event = EMS_Test_Util.prepareEvent('Unplanned', pmUser, etype, esubtype, Date.today(), Date.today() + 1, amount * 2, null, null);

        event.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'EMS_Event__c' AND DeveloperName = 'EMS_Event' LIMIT 1].Id;
        insert event;

        Account accountHCP = EMS_Test_util.createAndInsertAccount('New HCP Account', 'Account');
        Id rtID = [SELECT Id FROM RecordType WHERE SObjectType = 'EMS_Speaker_Role_gne__c' AND Name = 'HCP/HCO Payment Request' LIMIT 1].Id;
        EMS_Speaker_Role_gne__c paymentRequest = EMS_Test_Util.createPaymentRequest(rtID, event.Id, accountHCP.Id);

        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.standardController(event);
        EMS_Event_Ext ctrl = new EMS_Event_Ext(sc);

        List<String> rfslo = ctrl.getRelatedFieldSetListOverwritten();
        System.assertEquals(rfslo.size(), (new List<SFA2_Configuration_Object_gne__c>{
                configObject
        }).size());
        Map<String, GNE_SFA2_RL_Component_AttributesWrapper> attrs = ctrl.relatedListAttributes;
        System.assert(attrs.size() != 0);
        Map<String, List<SFA2_Configuration_Object_Detail_gne__c>> rfsm = ctrl.relatedFieldSetMap;
        List<SFA2_Configuration_Object_Detail_gne__c> details = rfsm.get(rfslo[0]);
        System.assertEquals(details.size(), (new List<SFA2_Configuration_Object_Detail_gne__c>{
                configObjectDetail
        }).size());

        EMS_Related_List_Controller rlsCtrl = new EMS_Related_List_Controller();
        rlsCtrl.pageController = ctrl.currentController;
        rlsCtrl.objectName = details[0].API_Name_gne__c;
        rlsCtrl.fieldsCSV = attrs.get(details[0].API_Name_gne__c).fieldsCSV;
        rlsCtrl.filter = attrs.get(details[0].API_Name_gne__c).filter;
        rlsCtrl.editEnabled = attrs.get(details[0].API_Name_gne__c).hideEditLink;
        rlsCtrl.deleteEnabled = attrs.get(details[0].API_Name_gne__c).hideDeleteLink;
        rlsCtrl.orderByFieldName = attrs.get(details[0].API_Name_gne__c).orderByFieldName;
        rlsCtrl.pageSize = attrs.get(details[0].API_Name_gne__c).pageSize;
        rlsCtrl.parentFieldId = ctrl.myObject.Id;
        rlsCtrl.parentFieldName = attrs.get(details[0].API_Name_gne__c).parentFieldName;
        rlsCtrl.sortDirection = attrs.get(details[0].API_Name_gne__c).sortDirection;
        rlsCtrl.urlForNewRecord = attrs.get(details[0].API_Name_gne__c).urlForNewRecord;
        rlsCtrl.relatedListLabel = details[0].Label_gne__c;
        rlsCtrl.recordsLimit = recordsLimit;

        Boolean isRecordLimitReached = ((new List<EMS_Speaker_Role_gne__c>{
                paymentRequest
        }).size() >= rlsCtrl.recordsLimit);

        System.assertEquals(rlsCtrl.loadData, false);
        rlsCtrl.showRelatedList();
        System.assertEquals(rlsCtrl.loadData, true);
        List<sObject> relatedRecords = rlsCtrl.getRecordsList();
        System.assertEquals(rlsCtrl.isRecordLimitReached, isRecordLimitReached);
        System.assertEquals(true, rlsCtrl.getShowNewButton());

        System.assertEquals('Payment Request', rlsCtrl.getObjectLabel());
        PageReference overrideuserviewpage = rlsCtrl.overrideUserViewLink();
        System.assert(overrideuserviewpage.getUrl().toLowerCase().startsWith(Page.EMS_User_Layout.getUrl()));
        System.assertEquals(details[0].API_Name_gne__c, rlsCtrl.getActionObjectName());

        PageReference viewallpage = rlsCtrl.viewAllClick();
        System.assertEquals(configObject.Object_Name_gne__c, viewallpage.getParameters().get('parentObjectName'));

        Datetime siGeneratedDate = [SELECT Self_invoice_generated_at__c FROM EMS_Speaker_Role_gne__c WHERE Id = :paymentRequest.Id LIMIT 1].Self_invoice_generated_at__c;
        System.assert(siGeneratedDate == null);


        String paymentRequestIDs = JSON.serialize(new Set<String>{
                paymentRequest.Id
        });
        EMS_Remote_Response result = EMS_Related_List_Controller.updateGenerationTimestamp(paymentRequestIDs);
        System.assert(result.isSuccess == true);
        Test.stopTest();

        siGeneratedDate = [SELECT Self_invoice_generated_at__c FROM EMS_Speaker_Role_gne__c WHERE Id = :paymentRequest.Id LIMIT 1].Self_invoice_generated_at__c;
        System.assert(String.isNotBlank(siGeneratedDate.format()));
    }

    @isTest static void eventLayout_relatedlist_test_coverFieldRelationsWith_R() {
        Decimal amount = 100;
        String etype = 'Sponsorship';
        String esubtype = 'Sponsorship of Events';

        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        GNE_SFA2_User_App_Context_gne__c appContext = new GNE_SFA2_User_App_Context_gne__c(
                Name = 'GNE SFA2 User Application Context (User)',
                SetupOwnerId = UserInfo.getUserId(),
                App_Name_gne__c = 'EMS-Canada',
                Role_gne__c = 'Admin',
                Run_in_SFA2_UI_gne__c = true,
                SFA2_Mode_gne__c = true,
                Brand_gne__c = 'My Brand'
        );
        insert appContext;

        SFA2_Configuration_Object_gne__c configObject = new SFA2_Configuration_Object_gne__c(
                Name = 'EMS_Budget_Product_gne__c_rl',
                Role_gne__c = 'Admin',
                Object_Name_gne__c = 'EMS_Budget_Product_gne__c',
                Record_Type_gne__c = 'EMS_Canada_Product_Budget_gne',
                Configuration_Type_gne__c = 'Page',
                Brand_gne__c = 'My Brand',
                Order_gne__c = 0,
                Style_gne__c = '',
                Attributes_gne__c = '',
                Is_Active_gne__c = true,
                Application_Type__c = 'EMS-Canada'
        );
        insert configObject;

        SFA2_Configuration_Object_Detail_gne__c configObjectDetail1 = new SFA2_Configuration_Object_Detail_gne__c(
                Configuration_Object_ref_gne__c = configObject.Id,
                Name = 'EMS_Budget_Region_gne__c',
                API_Name_gne__c = 'EMS_Budget_Region_gne__c',
                Label_gne__c = 'Region Budgets',
                Attributes_gne__c = 'fieldsCSV=Product_Indication_gne__c,Name#/,Assigned_to_gne__c,Total_Region_Funds_Approved_gne__c,Region_Balance_gne__c,Status_gne__c;orderByFieldName=Name;hideEditLink=false;hideDeleteLink=false;pageSize=5;urlForNewRecord=/apex/EMS_Budget_Region_Edit_Create_Layout;parentFieldName=EMS_Budget_Product_gne__c;sortDirection=Asc;hideButtons=true;customButtons=New Region Budget#action>newRegionBudgetClick;',
                Is_Read_Only_gne__c = false,
                Is_Required_gne__c = false,
                Order_gne__c = 1,
                Type_gne__c = 'Related List',
                Availability_Mode_gne__c = 'View',
                Is_Active_gne__c = true
        );
        SFA2_Configuration_Object_Detail_gne__c configObjectDetail2 = new SFA2_Configuration_Object_Detail_gne__c(
                Configuration_Object_ref_gne__c = configObject.Id,
                Name = 'EMS_Fund_Request_gne__c',
                API_Name_gne__c = 'EMS_Fund_Request_gne__c',
                Label_gne__c = 'Fund Requests',
                Attributes_gne__c = 'fieldsCSV=Name#/,Requested_Amount_gne__c,Reason_gne__c,Approver_gne__c,Required_By_Date_gne__c,Status_gne__c;orderByFieldName=NAME;hideEditLink=true;hideDeleteLink=true;pageSize=5;urlForNewRecord=/apex/EMS_Fund_Request_Edit_Create_Layout;parentFieldName=Related_Product_Budget_gne__c;sortDirection=DESC;hideButtons=true;',
                Is_Read_Only_gne__c = false,
                Is_Required_gne__c = false,
                Order_gne__c = 3,
                Type_gne__c = 'Related List',
                Availability_Mode_gne__c = 'View',
                Is_Active_gne__c = true
        );
        SFA2_Configuration_Object_Detail_gne__c configObjectDetail3 = new SFA2_Configuration_Object_Detail_gne__c(
                Configuration_Object_ref_gne__c = configObject.Id,
                Name = 'EMS_Budget_Allocation_gne__c',
                API_Name_gne__c = 'EMS_Budget_Allocation_gne__c',
                Label_gne__c = 'Event Budget Allocation',
                Attributes_gne__c = 'fieldsCSV=EMS_Event_gne__c,EMS_Event_gne__r.Event_Name_gne__c,Allocated_Budget_gne__c,Percentage_Contribution_gne__c,Budget_Deductions_gne__c,EMS_Event_gne__r.Overall_Status_gne__c;orderByFieldName=NAME;hideEditLink=true;hideDeleteLink=true;pageSize=5;urlForNewRecord=/apex/EMS_Budget_Allocation_Page;parentFieldName=EMS_Product_Budget_gne__c;sortDirection=DESC;hideButtons=true;',
                Is_Read_Only_gne__c = false,
                Is_Required_gne__c = false,
                Order_gne__c = 5,
                Type_gne__c = 'Related List',
                Availability_Mode_gne__c = 'View',
                Is_Active_gne__c = true
        );
        List<SFA2_Configuration_Object_Detail_gne__c> detList = new List<SFA2_Configuration_Object_Detail_gne__c>{
                configObjectDetail1, configObjectDetail2, configObjectDetail3
        };
        insert detList;

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Budget_Product_gne__c productBudget = EMS_Test_Util.createMultipleProductBudgets(0.0, 10 * amount, pmUser, costCenters)[0];

        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.standardController(productBudget);
        EMS_Budget_Product_Ext ctrl = new EMS_Budget_Product_Ext(sc);
        ctrl.init();
        System.assertEquals(ctrl.relatedListAttributes.size(), detList.size());

        List<String> rfslo = ctrl.getRelatedFieldSetListOverwritten();
        System.assertEquals(rfslo.size(), (new List<SFA2_Configuration_Object_gne__c>{
                configObject
        }).size());

        Map<String, List<SFA2_Configuration_Object_Detail_gne__c>> rfsm = ctrl.relatedFieldSetMap;
        List<SFA2_Configuration_Object_Detail_gne__c> details = rfsm.get(rfslo[0]);
        System.assertEquals(details.size(), detList.size());
        Map<String, GNE_SFA2_RL_Component_AttributesWrapper> attrs = ctrl.relatedListAttributes;
        System.assert(attrs.size() != 0);

        List<EMS_Related_List_Controller> rlsCtrlList = new List<EMS_Related_List_Controller>();
        for (SFA2_Configuration_Object_Detail_gne__c detail :details) {
            EMS_Related_List_Controller rlsCtrl = new EMS_Related_List_Controller();
            rlsCtrl.pageController = ctrl.currentController;
            rlsCtrl.objectName = detail.API_Name_gne__c;
            rlsCtrl.fieldsCSV = attrs.get(detail.API_Name_gne__c).fieldsCSV;
            rlsCtrl.filter = attrs.get(detail.API_Name_gne__c).filter;
            rlsCtrl.editEnabled = attrs.get(detail.API_Name_gne__c).hideEditLink;
            rlsCtrl.deleteEnabled = attrs.get(detail.API_Name_gne__c).hideDeleteLink;
            rlsCtrl.orderByFieldName = attrs.get(detail.API_Name_gne__c).orderByFieldName;
            rlsCtrl.pageSize = attrs.get(detail.API_Name_gne__c).pageSize;
            rlsCtrl.parentFieldId = ctrl.myObject.Id;
            rlsCtrl.parentFieldName = attrs.get(detail.API_Name_gne__c).parentFieldName;
            rlsCtrl.sortDirection = attrs.get(detail.API_Name_gne__c).sortDirection;
            rlsCtrl.urlForNewRecord = attrs.get(detail.API_Name_gne__c).urlForNewRecord;
            rlsCtrl.relatedListLabel = detail.Label_gne__c;
            rlsCtrl.recordsLimit = recordsLimit;

            rlsCtrl.showRelatedList();
            List<sObject> relatedRecords = rlsCtrl.getRecordsList();
            System.assert(relatedRecords.isEmpty()); // there are no region budgets, fund request and budget allocations
            rlsCtrlList.add(rlsCtrl);
        }
        Test.stopTest();
    }

    @isTest static void eventLayout_relatedlist_test_deleteRecordByID() {
        Decimal amount = 100;
        String etype = 'Sponsorship';
        String esubtype = 'Sponsorship of Events';

        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        GNE_SFA2_User_App_Context_gne__c appContext = new GNE_SFA2_User_App_Context_gne__c(
                Name = 'GNE SFA2 User Application Context (User)',
                SetupOwnerId = UserInfo.getUserId(),
                App_Name_gne__c = 'EMS-Canada',
                Role_gne__c = 'Admin',
                Run_in_SFA2_UI_gne__c = true,
                SFA2_Mode_gne__c = true,
                Brand_gne__c = 'My Brand'
        );
        insert appContext;

        SFA2_Configuration_Object_gne__c configObject = new SFA2_Configuration_Object_gne__c(
                Name = 'EMS_Event__c_rl',
                Role_gne__c = 'Admin',
                Object_Name_gne__c = 'EMS_Event__c',
                Record_Type_gne__c = 'EMS_Event',
                Configuration_Type_gne__c = 'Page',
                Brand_gne__c = 'My Brand',
                Order_gne__c = 0,
                Style_gne__c = '',
                Attributes_gne__c = '',
                Is_Active_gne__c = true,
                Application_Type__c = 'EMS-Canada'
        );
        insert configObject;

        SFA2_Configuration_Object_Detail_gne__c configObjectDetail = new SFA2_Configuration_Object_Detail_gne__c(
                Configuration_Object_ref_gne__c = configObject.Id,
                Name = 'EMS_Speaker_Role_gne__c',
                API_Name_gne__c = 'EMS_Speaker_Role_gne__c',
                Label_gne__c = 'Payment Requests',
                Attributes_gne__c = 'fieldsCSV=Name#/,HCP_HCO_iHCP_gne__c,Account_Type_gne__c,Total_Amount_gne__c,Payment_Date_gne__c,Status_gne__c;orderByFieldName=NAME;hideEditLink=false;hideDeleteLink=false;pageSize=5;parentFieldName=EMS_Event_gne__c;sortDirection=DESC;hideButtons=true;',
                Is_Read_Only_gne__c = false,
                Is_Required_gne__c = false,
                Order_gne__c = 3,
                Type_gne__c = 'Related List',
                Availability_Mode_gne__c = 'View',
                Is_Active_gne__c = true
        );
        insert configObjectDetail;

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 10 * amount, pmUser, costCenters);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(etype, esubtype, costCenters[0]);
        EMS_Event__c event = EMS_Test_Util.prepareEvent('Unplanned', pmUser, etype, esubtype, Date.today(), Date.today() + 1, amount * 2, null, null);

        event.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'EMS_Event__c' AND DeveloperName = 'EMS_Event' LIMIT 1].Id;
        insert event;

        Account accountHCP = EMS_Test_util.createAndInsertAccount('New HCP Account', 'Account');
        Id rtID = [SELECT Id FROM RecordType WHERE SObjectType = 'EMS_Speaker_Role_gne__c' AND Name = 'HCP/HCO Payment Request' LIMIT 1].Id;
        EMS_Speaker_Role_gne__c paymentRequest = EMS_Test_Util.createPaymentRequest(rtID, event.Id, accountHCP.Id);

        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.standardController(event);
        EMS_Event_Ext ctrl = new EMS_Event_Ext(sc);

        List<String> rfslo = ctrl.getRelatedFieldSetListOverwritten();
        System.assertEquals(rfslo.size(), (new List<SFA2_Configuration_Object_gne__c>{
                configObject
        }).size());
        Map<String, GNE_SFA2_RL_Component_AttributesWrapper> attrs = ctrl.relatedListAttributes;
        System.assert(attrs.size() != 0);
        Map<String, List<SFA2_Configuration_Object_Detail_gne__c>> rfsm = ctrl.relatedFieldSetMap;
        List<SFA2_Configuration_Object_Detail_gne__c> details = rfsm.get(rfslo[0]);
        System.assertEquals(details.size(), (new List<SFA2_Configuration_Object_Detail_gne__c>{
                configObjectDetail
        }).size());

        EMS_Related_List_Controller rlsCtrl = new EMS_Related_List_Controller();
        rlsCtrl.pageController = ctrl.currentController;
        rlsCtrl.objectName = details[0].API_Name_gne__c;
        rlsCtrl.fieldsCSV = attrs.get(details[0].API_Name_gne__c).fieldsCSV;
        rlsCtrl.filter = attrs.get(details[0].API_Name_gne__c).filter;
        rlsCtrl.editEnabled = attrs.get(details[0].API_Name_gne__c).hideEditLink;
        rlsCtrl.deleteEnabled = attrs.get(details[0].API_Name_gne__c).hideDeleteLink;
        rlsCtrl.orderByFieldName = attrs.get(details[0].API_Name_gne__c).orderByFieldName;
        rlsCtrl.pageSize = attrs.get(details[0].API_Name_gne__c).pageSize;
        rlsCtrl.parentFieldId = ctrl.myObject.Id;
        rlsCtrl.parentFieldName = attrs.get(details[0].API_Name_gne__c).parentFieldName;
        rlsCtrl.sortDirection = attrs.get(details[0].API_Name_gne__c).sortDirection;
        rlsCtrl.urlForNewRecord = attrs.get(details[0].API_Name_gne__c).urlForNewRecord;
        rlsCtrl.relatedListLabel = details[0].Label_gne__c;
        rlsCtrl.recordsLimit = recordsLimit;

        Boolean isRecordLimitReached = ((new List<EMS_Speaker_Role_gne__c>{
                paymentRequest
        }).size() >= rlsCtrl.recordsLimit);

        System.assertEquals(rlsCtrl.loadData, false);
        rlsCtrl.showRelatedList();
        System.assertEquals(rlsCtrl.loadData, true);
        List<sObject> relatedRecords = rlsCtrl.getRecordsList();
        System.assertEquals(rlsCtrl.isRecordLimitReached, isRecordLimitReached);

        EMS_Remote_Response result = EMS_Related_List_Controller.deleteRecordByID(paymentRequest.Id, String.valueOf(paymentRequest.getSobjectType()));
        System.assert(result.isSuccess == true);
        Test.stopTest();

        System.assert([SELECT Id FROM EMS_Speaker_Role_gne__c WHERE Id = :paymentRequest.Id].isEmpty());
    }


    // ***********************************************
    //  Covering "EMS_Related_Budgets_Controller.cls"
    // ***********************************************
    @isTest static void ems_related_budgets_controller_test_productBudget() {
        Decimal amount = 100;
        String etype = 'Sponsorship';
        String esubtype = 'Sponsorship of Events';
        String costCeterType = 'Commercial Department';

        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        GNE_SFA2_User_App_Context_gne__c appContext = new GNE_SFA2_User_App_Context_gne__c(
                Name = 'GNE SFA2 User Application Context (User)',
                SetupOwnerId = UserInfo.getUserId(),
                App_Name_gne__c = 'EMS-Canada',
                Role_gne__c = 'Admin',
                Run_in_SFA2_UI_gne__c = true,
                SFA2_Mode_gne__c = true,
                Brand_gne__c = 'My Brand'
        );
        insert appContext;

        SFA2_Configuration_Object_gne__c configObject = new SFA2_Configuration_Object_gne__c(
                Name = 'EMS_Budget_Product_gne__c_rl',
                Role_gne__c = 'Admin',
                Object_Name_gne__c = 'EMS_Budget_Product_gne__c',
                Record_Type_gne__c = 'EMS_Canada_Product_Budget_gne',
                Configuration_Type_gne__c = 'Page',
                Brand_gne__c = 'My Brand',
                Order_gne__c = 0,
                Style_gne__c = '',
                Attributes_gne__c = '',
                Is_Active_gne__c = true,
                Application_Type__c = 'EMS-Canada'
        );
        insert configObject;

        SFA2_Configuration_Object_Detail_gne__c configObjectDetail = new SFA2_Configuration_Object_Detail_gne__c(
                Configuration_Object_ref_gne__c = configObject.Id,
                Name = 'EMS_Budget_Region_gne__c',
                API_Name_gne__c = 'EMS_Budget_Region_gne__c',
                Label_gne__c = 'Region Budgets',
                Attributes_gne__c = 'fieldsCSV=Product_Indication_gne__c,Name#/,Assigned_to_gne__c,Total_Region_Funds_Approved_gne__c,Region_Balance_gne__c,Status_gne__c;orderByFieldName=Name;hideEditLink=false;hideDeleteLink=false;pageSize=5;urlForNewRecord=/apex/EMS_Budget_Region_Edit_Create_Layout;parentFieldName=EMS_Budget_Product_gne__c;sortDirection=Asc;hideButtons=true;customButtons=New Region Budget#action>newRegionBudgetClick;',
                Is_Read_Only_gne__c = false,
                Is_Required_gne__c = false,
                Order_gne__c = 1,
                Type_gne__c = 'Related List',
                Availability_Mode_gne__c = 'View',
                Is_Active_gne__c = true
        );
        insert configObjectDetail;

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters(costCeterType, 1, true);
        EMS_Budget_Product_gne__c productBudget = EMS_Test_Util.createMultipleProductBudgets(0.0, 10 * amount, pmUser, costCenters)[0];

        Test.startTest();
        EMS_Related_Budgets_Controller.parentId = productBudget.Id;


        String jsonString = '';
        jsonString = EMS_Related_Budgets_Controller.parentJSON;
        System.assert(jsonString != '');

        System.assertEquals(EMS_Related_Budgets_Controller.parentCostCenterType, costCeterType);
        System.assertEquals(EMS_Related_Budgets_Controller.isParentProductBudget, true);
        System.assertEquals(EMS_Related_Budgets_Controller.isParentRegionBudget, false);
        System.assertEquals(EMS_Related_Budgets_Controller.isAdmin, true);
        System.assertEquals(EMS_Related_Budgets_Controller.canCreate, true);
        System.assertEquals(EMS_Related_Budgets_Controller.canDelete, true);
        System.assertEquals(EMS_Related_Budgets_Controller.canUpdate, true);
        System.assertEquals(EMS_Related_Budgets_Controller.objectApiName, 'EMS_Budget_Region_gne__c');

        System.assertEquals(EMS_Related_Budgets_Controller.objectsName, 'Region Budgets');
        System.assertEquals(EMS_Related_Budgets_Controller.objectName, 'Region Budget');
        System.assertEquals(EMS_Related_Budgets_Controller.balance, 10 * amount);
        System.assertEquals(EMS_Related_Budgets_Controller.balanceString, EMS_Util.formatCurrency(10 * amount));
        System.assertEquals(EMS_Related_Budgets_Controller.transferBalanceField, 'Region_Balance_gne__c');


        Sobject regionbudget = EMS_Related_Budgets_Controller.newBudget(productBudget.Id);
        System.assert(regionbudget.get('Total_Region_Funds_Approved_gne__c') == 0.00);

        //Allowed_Owners_gne__c
        List<User> usrs = EMS_Related_Budgets_Controller.getUsers(String.valueOf(regionbudget.getSobjectType()), costCeterType);
        List<Id> userIDs = new List<Id>();
        for (User u :usrs) {
            userIDs.add(u.Id);
        }
        Map<Id, List<EMS_Util.EMS_Territory>> terrs = EMS_Related_Budgets_Controller.availableTerritories(userIDs);
        regionbudget.put('Assigned_To_Territory_Id_gne__c', terrs.get(usrs[0].Id)[0].Id);
        regionbudget.put('Assigned_To_Territory_gne__c', terrs.get(usrs[0].Id)[0].Name);

        // TODO: revert after merge
//        Database.UpsertResult result = EMS_Related_Budgets_Controller.saveBudget(String.valueOf(regionbudget.getSobjectType()), JSON.serialize(regionbudget));
//        System.assert(result.isSuccess() == true);


//        List<SObject> budgets = EMS_Related_Budgets_Controller.getBudgets('EMS_Budget_Region_gne__c', productBudget.getSObjectType().getDescribe().getName(), productBudget.Id);
//        System.assert(budgets.size() == (new List<Sobject>{regionbudget}).size());
        Test.stopTest();
    }

    @isTest static void ems_related_budgets_controller_test_regionBudget() {
        Decimal amount = 100;
        String etype = 'Sponsorship';
        String esubtype = 'Sponsorship of Events';
        String costCeterType = 'Commercial Department';

        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        GNE_SFA2_User_App_Context_gne__c appContext = new GNE_SFA2_User_App_Context_gne__c(
                Name = 'GNE SFA2 User Application Context (User)',
                SetupOwnerId = UserInfo.getUserId(),
                App_Name_gne__c = 'EMS-Canada',
                Role_gne__c = 'Admin',
                Run_in_SFA2_UI_gne__c = true,
                SFA2_Mode_gne__c = true,
                Brand_gne__c = 'My Brand'
        );
        insert appContext;

        SFA2_Configuration_Object_gne__c configObject = new SFA2_Configuration_Object_gne__c(
                Name = 'EMS_Budget_Region_gne__c_rl',
                Role_gne__c = 'Admin',
                Object_Name_gne__c = 'EMS_Budget_Region_gne__c',
                Record_Type_gne__c = 'EMS_Canada_Region_Budget_gne',
                Configuration_Type_gne__c = 'Page',
                Brand_gne__c = 'My Brand',
                Order_gne__c = 0,
                Style_gne__c = '',
                Attributes_gne__c = '',
                Is_Active_gne__c = true,
                Application_Type__c = 'EMS-Canada'
        );
        insert configObject;

        SFA2_Configuration_Object_Detail_gne__c configObjectDetail1 = new SFA2_Configuration_Object_Detail_gne__c(
                Configuration_Object_ref_gne__c = configObject.Id,
                Name = 'EMS_Budget_Territory_gne__c',
                API_Name_gne__c = 'EMS_Budget_Territory_gne__c',
                Label_gne__c = 'Territory Budgets',
                Attributes_gne__c = 'fieldsCSV=Product_Indication_gne__c,Name#/,Assigned_to_gne__c,Total_Territory_Funds_Approved_gne__c,Territory_Balance_gne__c,Status_gne__c;orderByFieldName=Name;hideEditLink=false;hideDeleteLink=false;pageSize=5;urlForNewRecord=/apex/EMS_Budget_Territory_Edit_Create_Layout;parentFieldName=EMS_Budget_Region_gne__c;sortDirection=Asc;hideButtons=true;customButtons=New Territory Budget#action>newTerritoryBudgetClick;',
                Is_Read_Only_gne__c = false,
                Is_Required_gne__c = false,
                Order_gne__c = 1,
                Type_gne__c = 'Related List',
                Availability_Mode_gne__c = 'View',
                Is_Active_gne__c = true
        );
        SFA2_Configuration_Object_Detail_gne__c configObjectDetail2 = new SFA2_Configuration_Object_Detail_gne__c(
                Configuration_Object_ref_gne__c = configObject.Id,
                Name = 'EMS_Budget_Allocation_gne__c',
                API_Name_gne__c = 'EMS_Budget_Allocation_gne__c',
                Label_gne__c = 'Event Budget Allocation',
                Attributes_gne__c = 'fieldsCSV=EMS_Event_gne__c,EMS_Event_gne__r.Event_Name_gne__c,Allocated_Budget_gne__c,Percentage_Contribution_gne__c,Budget_Deductions_gne__c,EMS_Event_gne__r.Overall_Status_gne__c;orderByFieldName=NAME;hideEditLink=true;hideDeleteLink=true;pageSize=5;urlForNewRecord=/apex/EMS_Budget_Allocation_Page;parentFieldName=EMS_Region_Budget_gne__c;sortDirection=DESC;hideButtons=true;',
                Is_Read_Only_gne__c = false,
                Is_Required_gne__c = false,
                Order_gne__c = 3,
                Type_gne__c = 'Related List',
                Availability_Mode_gne__c = 'View',
                Is_Active_gne__c = true
        );
        SFA2_Configuration_Object_Detail_gne__c configObjectDetail3 = new SFA2_Configuration_Object_Detail_gne__c(
                Configuration_Object_ref_gne__c = configObject.Id,
                Name = 'EMS_Fund_Request_gne__c',
                API_Name_gne__c = 'EMS_Fund_Request_gne__c',
                Label_gne__c = 'Fund Requests',
                Attributes_gne__c = 'fieldsCSV=Name#/,Requested_Amount_gne__c,Reason_gne__c,Approver_gne__c,Required_By_Date_gne__c,Status_gne__c;orderByFieldName=NAME;hideEditLink=true;hideDeleteLink=true;pageSize=5;urlForNewRecord=/apex/EMS_Fund_Request_Edit_Create_Layout;parentFieldName=Related_Region_Budget_gne__c;sortDirection=DESC;hideButtons=true;customButtons=New Fund Request#action>newFundRequestClick;',
                Is_Read_Only_gne__c = false,
                Is_Required_gne__c = false,
                Order_gne__c = 5,
                Type_gne__c = 'Related List',
                Availability_Mode_gne__c = 'View',
                Is_Active_gne__c = true
        );
        List<SFA2_Configuration_Object_Detail_gne__c> detList = new List<SFA2_Configuration_Object_Detail_gne__c>{
                configObjectDetail1, configObjectDetail2, configObjectDetail3
        };
        insert detList;

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters(costCeterType, 1, true);
        EMS_Budget_Product_gne__c productBudget = EMS_Test_Util.createMultipleProductBudgets(0.0, 10 * amount, pmUser, costCenters)[0];
        EMS_Budget_Region_gne__c regionBudget = EMS_Test_Util.createOneRegionBudgetForEachPB(new List<EMS_Budget_Product_gne__c>{
                productBudget
        }, 0.0, amount * 5, rsmUser)[0];

        Test.startTest();
        EMS_Related_Budgets_Controller.parentId = regionBudget.Id;
        String objectApiName = EMS_Related_Budgets_Controller.objectApiName;
        GNE_SFA2_RL_Component_AttributesWrapper budgConfig = EMS_Related_Budgets_Controller.budgetsConfiguration;

        List<SObject> objs = EMS_Related_Budgets_Controller.getBudgetsForTransfer(objectApiName, budgConfig.parentFieldName, regionBudget.Id);
        System.assert(objs.size() == (new List<Sobject>{
                regionBudget
        }).size());

        Id sourceBudgetId = productBudget.Id;
        Id targetBudgetId = regionBudget.Id;
        Decimal transferAmount = amount / 10;

        // TODO: revert after merge
//        Database.SaveResult result = EMS_Related_Budgets_Controller.requestTransfer(sourceBudgetId, targetBudgetId, transferAmount);
//        System.assert(result.isSuccess() == true);
//        EMS_Fund_Request_gne__c fr = [SELECT Requested_Amount_gne__c FROM EMS_Fund_Request_gne__c WHERE Related_Region_Budget_gne__c =: targetBudgetId LIMIT 1];
//        System.assertEquals(fr.Requested_Amount_gne__c, transferAmount);

        /*sourceBudgetId = productBudget.Id;
        targetBudgetId = productBudget.Id; 
        transferAmount = amount/5;
        result = EMS_Related_Budgets_Controller.requestTransfer(sourceBudgetId, targetBudgetId, transferAmount);
        System.assert(result.isSuccess() == true);
        fr = [SELECT Requested_Amount_gne__c FROM EMS_Fund_Request_gne__c WHERE Related_Product_Budget_gne__c =: targetBudgetId LIMIT 1];
        System.assertEquals(fr.Requested_Amount_gne__c, -1*transferAmount);*/
        Test.stopTest();
    }

}