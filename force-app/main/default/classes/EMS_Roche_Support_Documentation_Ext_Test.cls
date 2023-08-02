@isTest
private class EMS_Roche_Support_Documentation_Ext_Test {

    private static Integer BATCH_SIZE { get; set; }
    private static String etype { get; set; }
    private static String esubtype { get; set; }
    private static Decimal amount { get; set; }
    private static Id mmUser { get; set; }
    private static List<EMS_Cost_Center_gne__c> costCenters { get; set; }

    private static void prepare() {
        etype = 'Learning Programs';
        esubtype = 'OLA Implementation';
        amount = 1000;
        BATCH_SIZE = 11;

        mmUser = EMS_Test_Util.findExistingUser('MM', null)[0];
        System.assertNotEquals(null, mmUser);

        costCenters = EMS_Test_Util.createCostCenters('Medical Product', BATCH_SIZE, true);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(etype, esubtype, costCenters[0]);

        EMS_Test_Util.createBPSMailbox();

        // make current user an admin
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
    }


    @isTest static void agreeWithSupportDocumentation_withoutResponses() {
        prepare();

        EMS_Budget_Product_gne__c productBudget = EMS_Test_Util.createMultipleProductBudgets(0, amount * 10, mmUser, costCenters)[0];
        EMS_Event__c event = EMS_Test_Util.createEvents('Unplanned', mmUser, etype, esubtype, Date.today() + 1, Date.today() + 3, amount * 2, BATCH_SIZE)[0];

        EMS_Checklist_gne__c documentation = new EMS_Checklist_gne__c(
                Event_Type_gne__c = etype,
                Event_Sub_Type_gne__c = esubtype,
                Type_gne__c = 'Documentation for Roche Support',
                Is_Active_gne__c = true,
                Index_gne__c = 1,
                Is_Note_gne__c = false, // for simple checkbox record
                Is_One_Choice_gne__c = true,
                Depends_On_gne__c = null,
                Has_Depending_Items_gne__c = false,
                Has_Parent_gne__c = false,
                Is_Checked_gne__c = false,
                Parent_Index_gne__c = null,
                Is_All_Choice_gne__c = false,
                Is_Multi_Choice_gne__c = false,
                Is_Parent_gne__c = false,
                Item_gne__c = 'Is Roche the only company supporting this event, or are more companies involved?',
                Requires_Input_gne__c = false,
                Start_Date_gne__c = Date.today().addDays(-5),
                End_Date_gne__c = null // means the record is actual untill now
        );
        EMS_Checklist_gne__c documentationNote = new EMS_Checklist_gne__c(
                Event_Type_gne__c = etype,
                Event_Sub_Type_gne__c = esubtype,
                Type_gne__c = 'Documentation for Roche Support',
                Is_Active_gne__c = true,
                Index_gne__c = 1,
                Is_Note_gne__c = true, // for notes
                Is_One_Choice_gne__c = false,
                Depends_On_gne__c = null,
                Has_Depending_Items_gne__c = false,
                Has_Parent_gne__c = false,
                Is_Checked_gne__c = false,
                Parent_Index_gne__c = null,
                Is_All_Choice_gne__c = false,
                Is_Multi_Choice_gne__c = false,
                Is_Parent_gne__c = false,
                Item_gne__c = 'The support for this learning program is not directed to product promotion purposes.',
                Requires_Input_gne__c = false,
                Start_Date_gne__c = Date.today().addDays(-5),
                End_Date_gne__c = null // means the record is actual untill now
        );
        insert (new List<EMS_Checklist_gne__c>{
                documentation, documentationNote
        });

        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(event);
        EMS_Roche_Support_Documentation_Ext ctrl;
        User mmU = [SELECT Id FROM User WHERE Id = :mmUser LIMIT 1];
        // run as MM User - it's an Event_Requestor_gne__c
        System.runAs(mmU) {
            ctrl = new EMS_Roche_Support_Documentation_Ext(stdCtrl);
            System.assertEquals(true, ctrl.getCanEditDocumentation());
        }
        // run as current User - it's an admin in EMS
        ctrl = new EMS_Roche_Support_Documentation_Ext(stdCtrl);
        System.assertEquals(true, ctrl.getCanEditDocumentation());
        System.assertEquals(event.Id, ctrl.eventID);

        EMS_Remote_Response response = EMS_Roche_Support_Documentation_Ext.prepareSupportDocumentation(etype, esubtype, event.Id);
        System.assertEquals(true, response.isSuccess);
        List<EMS_Event_Ext.ComplianceRecord> docs = response.supportDocumentation;
        System.assertEquals((new List<EMS_Checklist_gne__c>{
                documentation, documentationNote
        }).size(), docs.size());

        response = EMS_Roche_Support_Documentation_Ext.agreeWithSupportDocumentation(new List<String>{
                documentation.Id
        }, event.Id, true, '');
        System.assertEquals(true, response.isSuccess);
        Test.stopTest();

        response = EMS_Roche_Support_Documentation_Ext.validateSupportDocumentation(etype, esubtype, event.Id);
        System.assertEquals(true, response.isSuccess);
    }

    @isTest static void agreeWithSupportDocumentation_withResponses() {
        prepare();

        EMS_Budget_Product_gne__c productBudget = EMS_Test_Util.createMultipleProductBudgets(0, amount * 10, mmUser, costCenters)[0];
        EMS_Event__c event = EMS_Test_Util.createEvents('Unplanned', mmUser, etype, esubtype, Date.today() + 1, Date.today() + 3, amount * 2, BATCH_SIZE)[0];

        EMS_Checklist_gne__c documentation = new EMS_Checklist_gne__c(
                Event_Type_gne__c = etype,
                Event_Sub_Type_gne__c = esubtype,
                Type_gne__c = 'Documentation for Roche Support',
                Is_Active_gne__c = true,
                Index_gne__c = 1,
                Is_Note_gne__c = false, // for simple checkbox record
                Is_One_Choice_gne__c = true,
                Depends_On_gne__c = null,
                Has_Depending_Items_gne__c = false,
                Has_Parent_gne__c = false,
                Is_Checked_gne__c = false,
                Parent_Index_gne__c = null,
                Is_All_Choice_gne__c = false,
                Is_Multi_Choice_gne__c = false,
                Is_Parent_gne__c = false,
                Item_gne__c = 'Is Roche the only company supporting this event, or are more companies involved?',
                Requires_Input_gne__c = false,
                Start_Date_gne__c = Date.today().addDays(-5),
                End_Date_gne__c = null // means the record is actual untill now
        );
        insert documentation;

        EMS_Checklist_Response_gne__c docResponse = new EMS_Checklist_Response_gne__c(
                EMS_Event_gne__c = event.Id,
                EMS_Checklist_gne__c = documentation.Id,
                Is_Checked_gne__c = false,
                Text_gne__c = documentation.Item_gne__c
        );
        insert docResponse;

        Test.startTest();
        EMS_Remote_Response response = EMS_Roche_Support_Documentation_Ext.agreeWithSupportDocumentation(new List<String>{
                documentation.Id
        }, event.Id, true, '');
        System.assertEquals(true, response.isSuccess);
        Test.stopTest();
    }

    @isTest static void validateSupportDocumentation_withParentChild() {
        prepare();

        EMS_Budget_Product_gne__c productBudget = EMS_Test_Util.createMultipleProductBudgets(0, amount * 10, mmUser, costCenters)[0];
        EMS_Event__c event = EMS_Test_Util.createEvents('Unplanned', mmUser, etype, esubtype, Date.today() + 1, Date.today() + 3, amount * 2, BATCH_SIZE)[0];

        EMS_Checklist_gne__c documentationParent = new EMS_Checklist_gne__c(
                Event_Type_gne__c = etype,
                Event_Sub_Type_gne__c = esubtype,
                Type_gne__c = 'Documentation for Roche Support',
                Is_Active_gne__c = true,
                Index_gne__c = 1,
                Is_Note_gne__c = false, // for simple checkbox record
                Is_One_Choice_gne__c = true,
                Depends_On_gne__c = null,
                Has_Depending_Items_gne__c = false,
                Has_Parent_gne__c = false,
                Is_Checked_gne__c = false,
                Parent_Index_gne__c = null,
                Is_All_Choice_gne__c = false,
                Is_Multi_Choice_gne__c = false,
                Is_Parent_gne__c = true, // parent flag
                Item_gne__c = 'Is Roche the only company supporting this event, or are more companies involved?',
                Requires_Input_gne__c = false,
                Start_Date_gne__c = Date.today().addDays(-5),
                End_Date_gne__c = null // means the record is actual untill now
        );

        EMS_Checklist_gne__c documentationChild1 = new EMS_Checklist_gne__c(
                Event_Type_gne__c = etype,
                Event_Sub_Type_gne__c = esubtype,
                Type_gne__c = 'Documentation for Roche Support',
                Is_Active_gne__c = true,
                Index_gne__c = 2,
                Is_Note_gne__c = false, // for simple checkbox record
                Is_One_Choice_gne__c = true,
                Depends_On_gne__c = null,
                Has_Depending_Items_gne__c = false,
                Has_Parent_gne__c = true,
                Is_Checked_gne__c = false,
                Parent_Index_gne__c = 1, // parent index
                Is_All_Choice_gne__c = false,
                Is_Multi_Choice_gne__c = false,
                Is_Parent_gne__c = false,
                Item_gne__c = 'Roche Only',
                Requires_Input_gne__c = false,
                Start_Date_gne__c = Date.today().addDays(-5),
                End_Date_gne__c = null // means the record is actual untill now
        );

        EMS_Checklist_gne__c documentationChild2 = new EMS_Checklist_gne__c(
                Event_Type_gne__c = etype,
                Event_Sub_Type_gne__c = esubtype,
                Type_gne__c = 'Documentation for Roche Support',
                Is_Active_gne__c = true,
                Index_gne__c = 3,
                Is_Note_gne__c = false, // for simple checkbox record
                Is_One_Choice_gne__c = true,
                Depends_On_gne__c = null,
                Has_Depending_Items_gne__c = false,
                Has_Parent_gne__c = true,
                Is_Checked_gne__c = false,
                Parent_Index_gne__c = 1, // parent index
                Is_All_Choice_gne__c = false,
                Is_Multi_Choice_gne__c = false,
                Is_Parent_gne__c = false,
                Item_gne__c = 'Additional companies involved. <br/>If yes, number of additional companies involved',
                Requires_Input_gne__c = true,
                Start_Date_gne__c = Date.today().addDays(-5),
                End_Date_gne__c = null // means the record is actual untill now
        );
        List<EMS_Checklist_gne__c> documentations = new List<EMS_Checklist_gne__c>{
                documentationParent, documentationChild1, documentationChild2
        };
        insert documentations;

        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(event);
        EMS_Roche_Support_Documentation_Ext ctrl = new EMS_Roche_Support_Documentation_Ext(stdCtrl);


        EMS_Remote_Response response = EMS_Roche_Support_Documentation_Ext.prepareSupportDocumentation(etype, esubtype, event.Id);
        System.assertEquals(true, response.isSuccess);
        List<EMS_Event_Ext.ComplianceRecord> docs = response.supportDocumentation;
        System.assertEquals(documentations.size(), docs.size());

        // clicking parent chebox
        response = EMS_Roche_Support_Documentation_Ext.agreeWithSupportDocumentation(new List<String>{
                documentationParent.Id
        }, event.Id, true, '');
        System.assertEquals(true, response.isSuccess);

        // putting some text
        response = EMS_Roche_Support_Documentation_Ext.agreeWithSupportDocumentation(new List<String>{
                documentationChild2.Id
        }, event.Id, true, '1');
        System.assertEquals(true, response.isSuccess);
        Test.stopTest();

        response = EMS_Roche_Support_Documentation_Ext.validateSupportDocumentation(etype, esubtype, event.Id);
        System.assertEquals(true, response.isSuccess);
    }


    @isTest static void validateSupportDocumentation_exception_onlyoneitem() {
        prepare();

        EMS_Budget_Product_gne__c productBudget = EMS_Test_Util.createMultipleProductBudgets(0, amount * 10, mmUser, costCenters)[0];
        EMS_Event__c event = EMS_Test_Util.createEvents('Unplanned', mmUser, etype, esubtype, Date.today() + 1, Date.today() + 3, amount * 2, BATCH_SIZE)[0];

        EMS_Checklist_gne__c documentationParent = new EMS_Checklist_gne__c(
                Event_Type_gne__c = etype,
                Event_Sub_Type_gne__c = esubtype,
                Type_gne__c = 'Documentation for Roche Support',
                Is_Active_gne__c = true,
                Index_gne__c = 1,
                Is_Note_gne__c = false, // for simple checkbox record
                Is_One_Choice_gne__c = true,
                Depends_On_gne__c = null,
                Has_Depending_Items_gne__c = false,
                Has_Parent_gne__c = false,
                Is_Checked_gne__c = false,
                Parent_Index_gne__c = null,
                Is_All_Choice_gne__c = false,
                Is_Multi_Choice_gne__c = false,
                Is_Parent_gne__c = true, // parent flag
                Item_gne__c = 'Is Roche the only company supporting this event, or are more companies involved?',
                Requires_Input_gne__c = false,
                Start_Date_gne__c = Date.today().addDays(-5),
                End_Date_gne__c = null // means the record is actual untill now
        );

        EMS_Checklist_gne__c documentationChild1 = new EMS_Checklist_gne__c(
                Event_Type_gne__c = etype,
                Event_Sub_Type_gne__c = esubtype,
                Type_gne__c = 'Documentation for Roche Support',
                Is_Active_gne__c = true,
                Index_gne__c = 2,
                Is_Note_gne__c = false, // for simple checkbox record
                Is_One_Choice_gne__c = true,
                Depends_On_gne__c = null,
                Has_Depending_Items_gne__c = false,
                Has_Parent_gne__c = true,
                Is_Checked_gne__c = false,
                Parent_Index_gne__c = 1, // parent index
                Is_All_Choice_gne__c = false,
                Is_Multi_Choice_gne__c = false,
                Is_Parent_gne__c = false,
                Item_gne__c = 'Roche Only',
                Requires_Input_gne__c = false,
                Start_Date_gne__c = Date.today().addDays(-5),
                End_Date_gne__c = null // means the record is actual untill now
        );

        EMS_Checklist_gne__c documentationChild2 = new EMS_Checklist_gne__c(
                Event_Type_gne__c = etype,
                Event_Sub_Type_gne__c = esubtype,
                Type_gne__c = 'Documentation for Roche Support',
                Is_Active_gne__c = true,
                Index_gne__c = 3,
                Is_Note_gne__c = false, // for simple checkbox record
                Is_One_Choice_gne__c = true,
                Depends_On_gne__c = null,
                Has_Depending_Items_gne__c = false,
                Has_Parent_gne__c = true,
                Is_Checked_gne__c = false,
                Parent_Index_gne__c = 1, // parent index
                Is_All_Choice_gne__c = false,
                Is_Multi_Choice_gne__c = false,
                Is_Parent_gne__c = false,
                Item_gne__c = 'Additional companies involved. <br/>If yes, number of additional companies involved',
                Requires_Input_gne__c = true,
                Start_Date_gne__c = Date.today().addDays(-5),
                End_Date_gne__c = null // means the record is actual untill now
        );
        List<EMS_Checklist_gne__c> documentations = new List<EMS_Checklist_gne__c>{
                documentationParent, documentationChild1, documentationChild2
        };
        insert documentations;

        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(event);
        EMS_Roche_Support_Documentation_Ext ctrl = new EMS_Roche_Support_Documentation_Ext(stdCtrl);


        EMS_Remote_Response response = EMS_Roche_Support_Documentation_Ext.prepareSupportDocumentation(etype, esubtype, event.Id);
        System.assertEquals(true, response.isSuccess);
        List<EMS_Event_Ext.ComplianceRecord> docs = response.supportDocumentation;
        System.assertEquals(documentations.size(), docs.size());

        // clicking parent chebox
        response = EMS_Roche_Support_Documentation_Ext.agreeWithSupportDocumentation(new List<String>{
                documentationParent.Id, documentationChild1.Id
        }, event.Id, true, '');
        System.assertEquals(true, response.isSuccess);

        // putting some text
        response = EMS_Roche_Support_Documentation_Ext.agreeWithSupportDocumentation(new List<String>{
                documentationChild2.Id
        }, event.Id, true, '1');
        System.assertEquals(true, response.isSuccess);
        Test.stopTest();

        response = EMS_Roche_Support_Documentation_Ext.validateSupportDocumentation(etype, esubtype, event.Id);
        System.assertEquals(false, response.isSuccess);
        System.assert(response.errorMessages[0].contains('Only one item needs to be checked'));
    }

    @isTest static void validateSupportDocumentation_exception_valuetobechecked() {
        prepare();

        EMS_Budget_Product_gne__c productBudget = EMS_Test_Util.createMultipleProductBudgets(0, amount * 10, mmUser, costCenters)[0];
        EMS_Event__c event = EMS_Test_Util.createEvents('Unplanned', mmUser, etype, esubtype, Date.today() + 1, Date.today() + 3, amount * 2, BATCH_SIZE)[0];

        EMS_Checklist_gne__c documentationParent = new EMS_Checklist_gne__c(
                Event_Type_gne__c = etype,
                Event_Sub_Type_gne__c = esubtype,
                Type_gne__c = 'Documentation for Roche Support',
                Is_Active_gne__c = true,
                Index_gne__c = 1,
                Is_Note_gne__c = false, // for simple checkbox record
                Is_One_Choice_gne__c = true,
                Depends_On_gne__c = null,
                Has_Depending_Items_gne__c = false,
                Has_Parent_gne__c = false,
                Is_Checked_gne__c = false,
                Parent_Index_gne__c = null,
                Is_All_Choice_gne__c = false,
                Is_Multi_Choice_gne__c = false,
                Is_Parent_gne__c = true, // parent flag
                Item_gne__c = 'Is Roche the only company supporting this event, or are more companies involved?',
                Requires_Input_gne__c = false,
                Start_Date_gne__c = Date.today().addDays(-5),
                End_Date_gne__c = null // means the record is actual untill now
        );

        EMS_Checklist_gne__c documentationChild1 = new EMS_Checklist_gne__c(
                Event_Type_gne__c = etype,
                Event_Sub_Type_gne__c = esubtype,
                Type_gne__c = 'Documentation for Roche Support',
                Is_Active_gne__c = true,
                Index_gne__c = 2,
                Is_Note_gne__c = false, // for simple checkbox record
                Is_One_Choice_gne__c = true,
                Depends_On_gne__c = null,
                Has_Depending_Items_gne__c = false,
                Has_Parent_gne__c = true,
                Is_Checked_gne__c = false,
                Parent_Index_gne__c = 1, // parent index
                Is_All_Choice_gne__c = false,
                Is_Multi_Choice_gne__c = false,
                Is_Parent_gne__c = false,
                Item_gne__c = 'Roche Only',
                Requires_Input_gne__c = false,
                Start_Date_gne__c = Date.today().addDays(-5),
                End_Date_gne__c = null // means the record is actual untill now
        );

        List<EMS_Checklist_gne__c> documentations = new List<EMS_Checklist_gne__c>{
                documentationParent, documentationChild1
        };
        insert documentations;

        Test.startTest();
        EMS_Remote_Response response = EMS_Roche_Support_Documentation_Ext.validateSupportDocumentation(etype, esubtype, event.Id);
        System.assertEquals(false, response.isSuccess);
        System.assert(response.errorMessages[0].contains('value should be checked'));

        User mmU = [SELECT Id FROM User WHERE Id = :mmUser LIMIT 1];
        System.runAs(mmU) {
            response = EMS_Roche_Support_Documentation_Ext.agreeWithSupportDocumentation(new List<String>{
                    documentationParent.Id, documentationChild1.Id
            }, event.Id, true, '');
            System.assertEquals(false, response.isSuccess);
            System.assert(response.errorMessages[0].contains('Error occured while saving the Roche Support Documentation:'));
        }
        Test.stopTest();
    }

    @isTest static void validateSupportDocumentation_exception_allchoice() {
        prepare();

        EMS_Budget_Product_gne__c productBudget = EMS_Test_Util.createMultipleProductBudgets(0, amount * 10, mmUser, costCenters)[0];
        EMS_Event__c event = EMS_Test_Util.createEvents('Unplanned', mmUser, etype, esubtype, Date.today() + 1, Date.today() + 3, amount * 2, BATCH_SIZE)[0];

        EMS_Checklist_gne__c documentationParent = new EMS_Checklist_gne__c(
                Event_Type_gne__c = etype,
                Event_Sub_Type_gne__c = esubtype,
                Type_gne__c = 'Documentation for Roche Support',
                Is_Active_gne__c = true,
                Index_gne__c = 1,
                Is_Note_gne__c = false, // for simple checkbox record
                Is_One_Choice_gne__c = false,
                Depends_On_gne__c = null,
                Has_Depending_Items_gne__c = false,
                Has_Parent_gne__c = false,
                Is_Checked_gne__c = false,
                Parent_Index_gne__c = null,
                Is_All_Choice_gne__c = true,
                Is_Multi_Choice_gne__c = false,
                Is_Parent_gne__c = true, // parent flag
                Item_gne__c = 'Is Roche the only company supporting this event, or are more companies involved?',
                Requires_Input_gne__c = false,
                Start_Date_gne__c = Date.today().addDays(-5),
                End_Date_gne__c = null // means the record is actual untill now
        );

        EMS_Checklist_gne__c documentationChild1 = new EMS_Checklist_gne__c(
                Event_Type_gne__c = etype,
                Event_Sub_Type_gne__c = esubtype,
                Type_gne__c = 'Documentation for Roche Support',
                Is_Active_gne__c = true,
                Index_gne__c = 2,
                Is_Note_gne__c = false, // for simple checkbox record
                Is_One_Choice_gne__c = true,
                Depends_On_gne__c = null,
                Has_Depending_Items_gne__c = false,
                Has_Parent_gne__c = true,
                Is_Checked_gne__c = false,
                Parent_Index_gne__c = 1, // parent index
                Is_All_Choice_gne__c = false,
                Is_Multi_Choice_gne__c = false,
                Is_Parent_gne__c = false,
                Item_gne__c = 'Roche Only',
                Requires_Input_gne__c = false,
                Start_Date_gne__c = Date.today().addDays(-5),
                End_Date_gne__c = null // means the record is actual untill now
        );

        EMS_Checklist_gne__c documentationChild2 = new EMS_Checklist_gne__c(
                Event_Type_gne__c = etype,
                Event_Sub_Type_gne__c = esubtype,
                Type_gne__c = 'Documentation for Roche Support',
                Is_Active_gne__c = true,
                Index_gne__c = 3,
                Is_Note_gne__c = false, // for simple checkbox record
                Is_One_Choice_gne__c = true,
                Depends_On_gne__c = null,
                Has_Depending_Items_gne__c = false,
                Has_Parent_gne__c = true,
                Is_Checked_gne__c = false,
                Parent_Index_gne__c = 1, // parent index
                Is_All_Choice_gne__c = false,
                Is_Multi_Choice_gne__c = false,
                Is_Parent_gne__c = false,
                Item_gne__c = 'Not Roche Only',
                Requires_Input_gne__c = false,
                Start_Date_gne__c = Date.today().addDays(-5),
                End_Date_gne__c = null // means the record is actual untill now
        );

        List<EMS_Checklist_gne__c> documentations = new List<EMS_Checklist_gne__c>{
                documentationParent, documentationChild1, documentationChild2
        };
        insert documentations;

        Test.startTest();
        //check parent
        EMS_Remote_Response response;
        response = EMS_Roche_Support_Documentation_Ext.agreeWithSupportDocumentation(new List<String>{
                documentationParent.Id
        }, event.Id, true, '');
        System.assertEquals(true, response.isSuccess);

        // validate with error
        response = EMS_Roche_Support_Documentation_Ext.validateSupportDocumentation(etype, esubtype, event.Id);
        System.assertEquals(false, response.isSuccess);
        System.assert(response.errorMessages[0].contains('All the items need to be checked'));
        Test.stopTest();
    }
}