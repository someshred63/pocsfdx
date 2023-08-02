@isTest
private class EMS_Budget_Allocation_Child_Rec_Upd_Test {

    private static Integer BATCH_SIZE = 1;
    private static final Id productBudgetRTID = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1].Id;

    private static testMethod void approveBudgetAllocations_test() {
        String type = 'Program';
        String subtype = 'Product Promo';

        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0 * BATCH_SIZE, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(type, subtype, costCenters[0]);

        List<EMS_Event_Configuration_gne__c> configs = [
                SELECT Budget_Approved_Label_gne__c
                FROM EMS_Event_Configuration_gne__c
                WHERE Event_Type_gne__c = :type AND Event_Sub_Type_gne__c = :subtype
        ];
        System.assertEquals(1, configs.size());
        if (String.isBlank(configs[0].Budget_Approved_Label_gne__c)) {
            configs[0].Budget_Approved_Label_gne__c = 'Label of approving';
            update configs;
        }

        EMS_Budget_Allocation_Trigger_Helper.skipTriggerValidationRules = true;
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Pending Approval', pmUsers[0], 'Program', 'Product Promo', Date.today(), Date.today() + 7, 100.0, BATCH_SIZE);
        for (EMS_Event__c event :events) {
            event.Pending_Budget_Approval_gne__c = true;
        }
        update events;
        List<EMS_Budget_Allocation_gne__c> baList = EMS_Test_Util.createBudgetAllocations(productBudgetRTID, 100.0, pb.Assigned_to_gne__c, events, pb.Id, null, null);

        Test.startTest();
        for (EMS_Budget_Allocation_gne__c baItem : baList) {
            baItem.Status_gne__c = 'Approved';
        }
        EMS_Budget_Allocation_Trigger_Helper.clearProcessedSet();
        update baList;

        for (EMS_Event__c event : [SELECT Status_gne__c FROM EMS_Event__c WHERE Id IN:events]) {
            System.assertEquals(configs[0].Budget_Approved_Label_gne__c, event.Status_gne__c);
        }
        Test.stopTest();
    }

    private static testMethod void recallBudgetAllocations_test() {
        String etype = 'Program';
        String esubtype = 'Product Promo';
        Decimal amount = 100;
        String recallActionName = 'Removed'; // Recall == "Removed", defined in EventPopup.js
        List<EMS_Event__c> events;
        List<EMS_Budget_Allocation_gne__c> bas;

        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, amount * BATCH_SIZE, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(etype, esubtype, costCenters[0]);
        EMS_Test_Util.createEventConfiguration(etype, esubtype, 'Pending Approval');

        // create events
        EMS_Budget_Allocation_Trigger_Helper.skipTriggerValidationRules = true;
        events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], etype, esubtype, Date.today(), Date.today() + 7, amount, BATCH_SIZE);

        bas = EMS_Test_Util.prepareBudgetAllocations(productBudgetRTID, amount, pb.Assigned_to_gne__c, events, pb.Id, null, null);
        List<String> amounts = new List<String>();
        for (EMS_Budget_Allocation_gne__c ba : bas) {
            ba.Status_gne__c = 'New';
            amounts.add(String.valueOf(ba.Allocated_Budget_gne__c));

        }
        insert bas;
        // Get IDs after records insertion
        List<String> basIDs = new List<String>();
        for (EMS_Budget_Allocation_gne__c ba : bas) {
            basIDs.add(String.valueOf(ba.Id));
        }

        EMS_Event_Trigger_Helper.clearProcessedSet();
        // Send events for approval
        events = [SELECT Pending_Budget_Approval_gne__c, Status_gne__c FROM EMS_Event__c WHERE Id IN :events];
        for (EMS_Event__c event :events) {
            event.Pending_Budget_Approval_gne__c = true;
            event.Status_gne__c = 'Pending Approval';
            event.Submitted_Date_gne__c = System.today();
            event.Submitted_By_gne__c = UserInfo.getUserId();
        }
        update events;
        // Check the status of budgets allocations
        for (EMS_Budget_Allocation_gne__c ba : [SELECT Status_gne__c FROM EMS_Budget_Allocation_gne__c WHERE Id IN:bas]) {
            System.assertEquals('Submitted', ba.Status_gne__c);
        }

        // Get process workitems
        List<ProcessInstance> processInstanceList = [
                SELECT Id, (SELECT Id FROM WorkItems ORDER BY CreatedDate DESC)
                FROM ProcessInstance
                WHERE TargetObject.Id IN :basIDs
                ORDER BY CreatedDate DESC
        ];
        List<Id> processInstanceWorkitemIds = new List<Id>();
        for (ProcessInstance pi : processInstanceList) {
            if (pi.Workitems != null && pi.Workitems.size() != 0) {
                for (ProcessInstanceWorkitem piw : pi.Workitems) {
                    processInstanceWorkitemIds.add(piw.Id);
                }
            }
        }

        String recallComment = 'Nothing to say, RECALL!';
        Test.startTest();
        // Recall. It is better to call Recall action being logged as a budget owner user.
        EMS_Event_Ext.approveRejectRecallBudgetAllocations(
                recallActionName,
                basIDs,
                processInstanceWorkitemIds,
                amounts,
                recallComment
        );
        Test.stopTest();

        for (EMS_Budget_Allocation_gne__c ba : [SELECT Status_gne__c, Comments_gne__c FROM EMS_Budget_Allocation_gne__c WHERE Id IN:bas]) {
            System.assertEquals('New', ba.Status_gne__c);
            System.assertEquals(recallComment, ba.Comments_gne__c);
        }
    }

    // private static testMethod void recallOtherBudgetAllocations__test() { } // NEED TO BE ADDED

    private static testMethod void rejectBudgetAllocations_test() {
        String etype = 'Program';
        String esubtype = 'Product Promo';
        Decimal amount = 100;
        String rejectActionName = 'Reject'; // Reject == Removed in EventPopup.js
        List<EMS_Event__c> events;
        List<EMS_Budget_Allocation_gne__c> bas;

        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(etype, esubtype, costCenters[0]);
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, amount * 10, pmUsers[0], costCenters[0].Id);

        // create events
        EMS_Budget_Allocation_Trigger_Helper.skipTriggerValidationRules = true;
        events = EMS_Test_Util.prepareEvents('Pending Approval', pmUsers[0], etype, esubtype, Date.today(), Date.today() + 7, amount, null, null, BATCH_SIZE);
        for (EMS_Event__c event :events) {
            event.Pending_Budget_Approval_gne__c = true;
        }
        insert events;

        bas = EMS_Test_Util.createBudgetAllocations(productBudgetRTID, amount, pb.Assigned_to_gne__c, events, pb.Id, null, null);
        List<String> basIDs = new List<String>();
        List<String> amounts = new List<String>();
        for (EMS_Budget_Allocation_gne__c ba : bas) {
            basIDs.add(String.valueOf(ba.Id));
            amounts.add(String.valueOf(ba.Allocated_Budget_gne__c));
        }

        // Get process workitems
        List<ProcessInstance> processInstanceList = [
                SELECT Id, (SELECT Id FROM WorkItems ORDER BY CreatedDate DESC)
                FROM ProcessInstance
                WHERE TargetObject.Id IN :basIDs
                ORDER BY CreatedDate DESC
        ];
        List<Id> processInstanceWorkitemIds = new List<Id>();
        for (ProcessInstance pi : processInstanceList) {
            if (pi.Workitems != null && pi.Workitems.size() != 0) {
                for (ProcessInstanceWorkitem piw : pi.Workitems) {
                    processInstanceWorkitemIds.add(piw.Id);
                }
            }
        }
        // Confirm that budgets allocations are not rejected
        for (EMS_Budget_Allocation_gne__c ba : [SELECT Status_gne__c FROM EMS_Budget_Allocation_gne__c WHERE Id IN:bas]) {
            System.assertNotEquals('Rejected', ba.Status_gne__c);
        }

        Test.startTest();
        String rejectComment = 'Nothing to say, REJECT!';
        EMS_Budget_Allocation_Trigger_Helper.clearProcessedSet();
        // Reject. It is better to call Reject action being logged as a budget owner user.
        EMS_Event_Ext.approveRejectRecallBudgetAllocations(
                rejectActionName,
                basIDs,
                processInstanceWorkitemIds,
                amounts,
                rejectComment
        );
        Test.stopTest();

        for (EMS_Budget_Allocation_gne__c ba : [SELECT Status_gne__c, Comments_gne__c FROM EMS_Budget_Allocation_gne__c WHERE Id IN:bas]) {
            System.assertEquals('Rejected', ba.Status_gne__c);
            System.assertEquals(rejectComment, ba.Comments_gne__c);
        }
    }

    private static testMethod void calculateBudgetDeductions_productBudget_Test() {
        String etype = 'Program';
        String esubtype = 'Product Promo';
        Decimal amount = 100;
        EMS_Event__c event;
        List<EMS_Budget_Allocation_gne__c> bas;

        Id pmUser = EMS_Test_Util.findExistingUser('PM', null)[0];
        System.assertNotEquals(null, pmUser);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, amount * 10, pmUser, costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(etype, esubtype, costCenters[0]);
        event = EMS_Test_Util.createEvents('Planned', pmUser, etype, esubtype, Date.today(), Date.today() + 3, amount * 2, 1)[0];

        bas = new List<EMS_Budget_Allocation_gne__c>();
        Integer i;
        Id reordTypeid = EMS_Test_Util.baRecordTypesMap.get('Product Budget Allocation');
        Decimal coefForBudgets = 0.2;
        EMS_Budget_Allocation_gne__c ba1 = new EMS_Budget_Allocation_gne__c(
                Allocated_Budget_gne__c = amount * coefForBudgets,
                Budget_Deductions_gne__c = 0,
                Percentage_Contribution_gne__c = amount / event.Planned_Expenses_gne__c,
                EMS_Event_gne__c = event.Id,
                RecordTypeId = reordTypeid,
                EMS_Product_Budget_gne__c = pb.Id
        );
        bas.add(ba1);

        EMS_Budget_Allocation_gne__c ba2 = new EMS_Budget_Allocation_gne__c(
                Allocated_Budget_gne__c = amount - (amount * coefForBudgets),
                Budget_Deductions_gne__c = 0,
                Percentage_Contribution_gne__c = amount / event.Planned_Expenses_gne__c,
                EMS_Event_gne__c = event.Id,
                RecordTypeId = reordTypeid,
                EMS_Product_Budget_gne__c = pb.Id
        );
        bas.add(ba2);
        insert bas;

        Decimal expenseAmount = 20.0;
        List<EMS_Expense_gne__c> expenses = EMS_Test_Util.createExpenses(new List<EMS_Event__c>{
                event
        }, expenseAmount, 1, costCenters[0]);

        Test.startTest();
        // Run future method
        EMS_Budget_Allocation_Child_Rec_Update.recalculateBudgetDeductionsFuture(new Set<Id>{
                event.Id
        });
        Test.stopTest();

        bas = [SELECT Id, Budget_Deductions_gne__c FROM EMS_Budget_Allocation_gne__c WHERE Id IN:bas];
        for (EMS_Budget_Allocation_gne__c ba :bas) {
            if (ba.Id == ba1.Id) {
                System.assertEquals(expenseAmount * coefForBudgets, ba.Budget_Deductions_gne__c);
            } else {
                System.assertEquals(expenseAmount - (expenseAmount * coefForBudgets), ba.Budget_Deductions_gne__c);
            }
        }
    }

    private static testMethod void updateAllocatedAmountOnBudget_productBudget_Test_InsertUpdate() {
        String etype = 'Program';
        String esubtype = 'Product Promo';
        Decimal amount = 100;

        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Product', BATCH_SIZE, true);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(etype, esubtype, costCenters[0]);

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0, amount * 5, pmUsers[0], costCenters);
        List<EMS_Event__c> events = EMS_Test_Util.createEvents ('Planned', pmUsers[0], etype, esubtype, Date.today() + 1, Date.today() + 3, amount * 2, BATCH_SIZE) ;

        Test.startTest();
        List<EMS_Budget_Allocation_gne__c> budgetAllocations = new List<EMS_Budget_Allocation_gne__c>();
        Integer i;
        for (i = 0; i < BATCH_SIZE; i++) {
            EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                    Allocated_Budget_gne__c = amount,
                    Percentage_Contribution_gne__c = 1,
                    Budget_Deductions_gne__c = 0,
                    EMS_Event_gne__c = events.get(i).Id,
                    RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Product Budget Allocation'),
                    EMS_Product_Budget_gne__c = productBudgets.get(i).Id
            );
            budgetAllocations.add(budgetAllocation);
        }
        insert budgetAllocations;
        for (EMS_Budget_Product_gne__c pb : [SELECT Events_Allocated_Amount__c FROM EMS_Budget_Product_gne__c WHERE Id IN :productBudgets]) {
            System.assertEquals(amount, pb.Events_Allocated_Amount__c);
        }

        // amount is updated
        for (EMS_Budget_Allocation_gne__c ba : budgetAllocations) {
            ba.Allocated_Budget_gne__c = amount + 50;
        }
        update budgetAllocations;

        for (EMS_Budget_Product_gne__c pb : [SELECT Events_Allocated_Amount__c FROM EMS_Budget_Product_gne__c WHERE Id IN :productBudgets]) {
            System.assertEquals(amount + 50, pb.Events_Allocated_Amount__c);
        }
        Test.stopTest();
    }

    private static testMethod void updateAllocatedAmountOnBudget_regionBudget_Test_InsertUpdate() {
        String etype = 'Program';
        String esubtype = 'Product Promo';
        Decimal amount = 100;

        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Product', BATCH_SIZE, true);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(etype, esubtype, costCenters[0]);

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, amount * 10, pmUser, costCenters);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, amount * 5, rsmUser);
        List<EMS_Event__c> events = EMS_Test_Util.createEvents ('Planned', pmUser, etype, esubtype, Date.today() + 1, Date.today() + 3, amount * 2, BATCH_SIZE) ;

        Test.startTest();
        Integer i;
        List<EMS_Budget_Allocation_gne__c> budgetAllocations = new List <EMS_Budget_Allocation_gne__c>();
        for (i = 0; i < BATCH_SIZE; i++) {
            EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                    Allocated_Budget_gne__c = amount,
                    Percentage_Contribution_gne__c = 1,
                    Budget_Deductions_gne__c = 0,
                    EMS_Event_gne__c = events.get(i).Id,
                    RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Region Budget Allocation'),
                    EMS_Region_Budget_gne__c = regionBudgets.get(i).Id
            );
            budgetAllocations.add(budgetAllocation);
        }
        insert budgetAllocations;
        for (EMS_Budget_Region_gne__c rb : [SELECT Events_Allocated_Amount_gne__c FROM EMS_Budget_Region_gne__c WHERE Id IN :regionBudgets]) {
            System.assertEquals(amount, rb.Events_Allocated_Amount_gne__c);
        }

        // update amount
        for (EMS_Budget_Allocation_gne__c ba : budgetAllocations) {
            ba.Allocated_Budget_gne__c = amount + 50;
        }
        update budgetAllocations;
        for (EMS_Budget_Region_gne__c rb : [SELECT Events_Allocated_Amount_gne__c FROM EMS_Budget_Region_gne__c WHERE Id IN :regionBudgets]) {
            System.assertEquals(amount + 50, rb.Events_Allocated_Amount_gne__c);
        }
        Test.stopTest();
    }

    private static testMethod void updateAllocatedAmountOnDelete_productBudget_Test() {
        String etype = 'Program';
        String esubtype = 'Product Promo';
        Decimal amount = 100;

        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Product', BATCH_SIZE, true);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(etype, esubtype, costCenters[0]);

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, amount * 10, pmUsers[0], costCenters);
        List<EMS_Event__c> events = EMS_Test_Util.createEvents ('Planned', pmUsers[0], etype, esubtype, Date.today() + 1, Date.today() + 3, amount * 2, BATCH_SIZE);

        Test.startTest();
        Integer i;
        List<EMS_Budget_Allocation_gne__c> budgetAllocations = new List<EMS_Budget_Allocation_gne__c>();
        for (i = 0; i < BATCH_SIZE; i++) {
            EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                    Allocated_Budget_gne__c = amount,
                    Percentage_Contribution_gne__c = 1,
                    Budget_Deductions_gne__c = 0,
                    EMS_Event_gne__c = events.get(i).Id,
                    RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Product Budget Allocation'),
                    EMS_Product_Budget_gne__c = productBudgets.get(i).Id
            );
            budgetAllocations.add(budgetAllocation);
        }
        insert budgetAllocations;
        for (EMS_Budget_Product_gne__c pb : [SELECT Events_Allocated_Amount__c FROM EMS_Budget_Product_gne__c WHERE Id IN :productBudgets]) {
            System.assertEquals(amount, pb.Events_Allocated_Amount__c);
        }

        // delete
        delete budgetAllocations;
        for (EMS_Budget_Product_gne__c pb : [SELECT Events_Allocated_Amount__c FROM EMS_Budget_Product_gne__c WHERE Id IN :productBudgets]) {
            System.assertEquals(0, pb.Events_Allocated_Amount__c);
        }
        Test.stopTest();
    }

    private static testMethod void updateAllocatedAmountOnDelete_regionBudget_Test() {
        String etype = 'Program';
        String esubtype = 'Product Promo';
        Decimal amount = 100;

        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Product', BATCH_SIZE, true);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(etype, esubtype, costCenters[0]);

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0, amount * 10, pmUser, costCenters);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, amount * 5, rsmUser);
        List<EMS_Event__c> events = EMS_Test_Util.createEvents ('Planned', pmUser, etype, esubtype, Date.today() + 1, Date.today() + 3, amount * 2, BATCH_SIZE) ;

        Test.startTest();
        // Insert
        List<EMS_Budget_Allocation_gne__c> budgetAllocations = new List<EMS_Budget_Allocation_gne__c>();
        Integer i;
        for (i = 0; i < BATCH_SIZE; i++) {
            EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                    Allocated_Budget_gne__c = amount,
                    Percentage_Contribution_gne__c = 1,
                    Budget_Deductions_gne__c = 0,
                    EMS_Event_gne__c = events.get(i).Id,
                    RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Region Budget Allocation'),
                    EMS_Region_Budget_gne__c = regionBudgets.get(i).Id
            );
            budgetAllocations.add(budgetAllocation);
        }
        insert budgetAllocations;
        for (EMS_Budget_Region_gne__c rb : [SELECT Events_Allocated_Amount_gne__c FROM EMS_Budget_Region_gne__c WHERE Id IN :regionBudgets]) {
            System.assertEquals(amount, rb.Events_Allocated_Amount_gne__c);
        }

        // delete
        delete budgetAllocations;
        for (EMS_Budget_Region_gne__c rb : [SELECT Events_Allocated_Amount_gne__c FROM EMS_Budget_Region_gne__c WHERE Id IN :regionBudgets]) {
            System.assertEquals(0, rb.Events_Allocated_Amount_gne__c);
        }
        Test.stopTest();
    }

    private static testMethod void shareWithBudgetOwner_InsertBa_Test() {
        String etype = 'Program';
        String esubtype = 'Product Promo';
        Decimal amount = 100;
        String shareRowCause = Schema.EMS_Event__Share.RowCause.Budget_Owner__c;

        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Product', BATCH_SIZE, true);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(etype, esubtype, costCenters[0]);

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, amount * 10, pmUsers[0], costCenters);
        List<EMS_Event__c> events = EMS_Test_Util.createEvents ('Planned', pmUsers[0], etype, esubtype, Date.today() + 1, Date.today() + 3, amount * 2, BATCH_SIZE) ;

        Test.startTest();
        Integer i;
        List<EMS_Budget_Allocation_gne__c> budgetAllocations = new List <EMS_Budget_Allocation_gne__c>();
        for (i = 0; i < BATCH_SIZE; i++) {
            EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                    Allocated_Budget_gne__c = amount,
                    Percentage_Contribution_gne__c = 1,
                    Budget_Deductions_gne__c = 0,
                    EMS_Event_gne__c = events.get(i).Id,
                    RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Product Budget Allocation'),
                    EMS_Product_Budget_gne__c = productBudgets.get(i).Id
            );
            budgetAllocations.add(budgetAllocation);
        }
        insert budgetAllocations;

        Set<Id> evendIDs = new Map<Id, SObject>(events).keySet();
        List<EMS_Event__Share> eventShares = [SELECT RowCause, ParentId, AccessLevel FROM EMS_Event__Share WHERE UserOrGroupId = :pmUsers[0]];
        System.assertEquals(productBudgets.size(), eventShares.size());

        for (EMS_Event__Share eventShare : eventShares) {
            System.assertEquals(shareRowCause, eventShare.RowCause);
            System.assertEquals('Read', eventShare.AccessLevel);
            System.assert(evendIDs.contains(eventShare.ParentId));
        }
        Test.stopTest();
    }

    private static testMethod void removeSharingWithBudgetOwner_DeleteBa_Test() {
        String etype = 'Program';
        String esubtype = 'Product Promo';
        Decimal amount = 100;
        String shareRowCause = Schema.EMS_Event__Share.RowCause.Budget_Owner__c;

        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Product', BATCH_SIZE, true);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(etype, esubtype, costCenters[0]);

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, amount * 10, pmUsers[0], costCenters);
        List<EMS_Event__c> events = EMS_Test_Util.createEvents ('Planned', pmUsers[0], etype, esubtype, Date.today() + 1, Date.today() + 3, amount * 2, BATCH_SIZE) ;

        Test.startTest();
        Integer i;
        List<EMS_Budget_Allocation_gne__c> budgetAllocations = new List <EMS_Budget_Allocation_gne__c>();
        for (i = 0; i < BATCH_SIZE; i++) {
            EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                    Allocated_Budget_gne__c = amount,
                    Percentage_Contribution_gne__c = 1,
                    Budget_Deductions_gne__c = 0,
                    EMS_Event_gne__c = events.get(i).Id,
                    RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Product Budget Allocation'),
                    EMS_Product_Budget_gne__c = productBudgets.get(i).Id
            );
            budgetAllocations.add(budgetAllocation);
        }
        insert budgetAllocations;

        Set<Id> evendIDs = new Map<Id, SObject>(events).keySet();
        List<EMS_Event__Share> eventShares = [SELECT RowCause, ParentId, AccessLevel FROM EMS_Event__Share WHERE UserOrGroupId = :pmUsers[0]];
        System.assertEquals(productBudgets.size(), eventShares.size());

        for (EMS_Event__Share eventShare : eventShares) {
            System.assertEquals(shareRowCause, eventShare.RowCause);
            System.assertEquals('Read', eventShare.AccessLevel);
            System.assert(evendIDs.contains(eventShare.ParentId));
        }

        delete budgetAllocations;
        eventShares.clear();
        eventShares = [SELECT RowCause, ParentId, AccessLevel FROM EMS_Event__Share WHERE UserOrGroupId = :pmUsers[0]];
        System.assertEquals(0, eventShares.size());
        Test.stopTest();
    }

    private static testMethod void updateAllocatedBudgetOnUpdate_territory_test() {
        String etype = 'Program';
        String esubtype = 'Product Promo';
        Decimal amount = 100;

        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM', 'Rep');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        Id repUser = ids[2];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);
        System.assertNotEquals(null, repUser);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(etype, esubtype, costCenters[0]);

        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, amount * 10, pmUser, costCenters[0].Id);
        EMS_Budget_Region_gne__c rb = EMS_Test_Util.createRegionBudget(pb.Id, 0.0, amount * 5, rsmUser);
        EMS_Budget_Territory_gne__c tb = EMS_Test_Util.createTerritoryBudget(rb.Id, 0.0, amount * 2, repUser);

        EMS_Budget_Allocation_Trigger_Helper.skipTriggerValidationRules = true;
        EMS_Event__c event = EMS_Test_Util.prepareEvents('Pending Approval', pmUser, etype, esubtype, Date.today(), Date.today() + 7, amount, null, null, 1)[0];
        event.Pending_Budget_Approval_gne__c = true;
        insert event;
        // Limits.getQueries() // SOQLs number is 97

        Test.startTest();
        EMS_Budget_Allocation_gne__c ba = new EMS_Budget_Allocation_gne__c(
                Allocated_Budget_gne__c = amount,
                Percentage_Contribution_gne__c = 1,
                Budget_Deductions_gne__c = 0,
                EMS_Event_gne__c = event.Id,
                RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Territory Budget Allocation'),
                EMS_Territory_Budget_gne__c = tb.Id
        );
        insert ba;

        // update amount
        EMS_Budget_Allocation_Trigger_Helper.clearProcessedSet();
        ba.Allocated_Budget_gne__c = amount + 50;
        update ba;

        tb = [SELECT Events_Allocated_Amount_gne__c FROM EMS_Budget_Territory_gne__c WHERE Id = :tb.Id LIMIT 1];
        System.assertEquals(amount + 50, tb.Events_Allocated_Amount_gne__c);
        Test.stopTest();
    }

    private static testMethod void updateAllocatedAmountOnDelete_territoryBudget_Test() {
        String etype = 'Program';
        String esubtype = 'Product Promo';
        Decimal amount = 100;

        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM', 'Rep');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        Id repUser = ids[2];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);
        System.assertNotEquals(null, repUser);


        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(etype, esubtype, costCenters[0]);

        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, amount * 10, pmUser, costCenters[0].Id);
        EMS_Budget_Region_gne__c rb = EMS_Test_Util.createRegionBudget(pb.Id, 0.0, amount * 5, rsmUser);
        EMS_Budget_Territory_gne__c tb = EMS_Test_Util.createTerritoryBudget(rb.Id, 0.0, amount * 2, repUser);

        EMS_Budget_Allocation_Trigger_Helper.skipTriggerValidationRules = true;
        EMS_Event__c event = EMS_Test_Util.prepareEvents('Pending Approval', pmUser, etype, esubtype, Date.today(), Date.today() + 7, amount, null, null, 1)[0];
        event.Pending_Budget_Approval_gne__c = true;
        insert event;

        Test.startTest();
        EMS_Budget_Allocation_gne__c ba = new EMS_Budget_Allocation_gne__c(
                Allocated_Budget_gne__c = amount,
                Percentage_Contribution_gne__c = 1,
                Budget_Deductions_gne__c = 0,
                EMS_Event_gne__c = event.Id,
                RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Territory Budget Allocation'),
                EMS_Territory_Budget_gne__c = tb.Id
        );
        insert ba;

        EMS_Budget_Allocation_Trigger_Helper.clearProcessedSet();
        delete ba;
        tb = [SELECT Events_Allocated_Amount_gne__c FROM EMS_Budget_Territory_gne__c WHERE Id = :tb.Id LIMIT 1];
        System.assertEquals(0, tb.Events_Allocated_Amount_gne__c);
        Test.stopTest();
    }

    private static testMethod void updateAllocatedAmountOnUpdateForClosedEvents_territoryBudget_Test() {
        String etype = 'Program';
        String esubtype = 'Product Promo';
        Decimal amount = 100;

        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM', 'Rep');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        Id repUser = ids[2];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);
        System.assertNotEquals(null, repUser);


        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(etype, esubtype, costCenters[0]);

        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, amount * 10, pmUser, costCenters[0].Id);
        EMS_Budget_Region_gne__c rb = EMS_Test_Util.createRegionBudget(pb.Id, 0.0, amount * 5, rsmUser);
        EMS_Budget_Territory_gne__c tb = EMS_Test_Util.createTerritoryBudget(rb.Id, 0.0, amount * 2, repUser);

        EMS_Budget_Allocation_Trigger_Helper.skipTriggerValidationRules = true;
        EMS_Event__c event = EMS_Test_Util.prepareEvents('Closed', pmUser, etype, esubtype, Date.today(), Date.today() + 7, amount, null, null, 1)[0];
        event.Pending_Budget_Approval_gne__c = true;
        EMS_Event_Trigger_Helper.skipTriggerValidationRules = true;
        insert event;

        Test.startTest();
        EMS_Budget_Allocation_gne__c ba = new EMS_Budget_Allocation_gne__c(
                Allocated_Budget_gne__c = amount,
                Percentage_Contribution_gne__c = 1,
                Budget_Deductions_gne__c = 0,
                EMS_Event_gne__c = event.Id,
                RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Territory Budget Allocation'),
                EMS_Territory_Budget_gne__c = tb.Id
        );
        insert ba;

        // update amount
        EMS_Budget_Allocation_Trigger_Helper.clearProcessedSet();
        ba.Allocated_Budget_gne__c = amount + 50;
        update ba;

        tb = [SELECT Events_Allocated_Amount_gne__c FROM EMS_Budget_Territory_gne__c WHERE Id = :tb.Id LIMIT 1];
        System.assertEquals(0, tb.Events_Allocated_Amount_gne__c);
        Test.stopTest(); // 482
    }

    private static testMethod void updateAllocatedAmountOnUpdateForClosedEvents_regionBudget_Test() {
        String etype = 'Program';
        String esubtype = 'Product Promo';
        Decimal amount = 100;

        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Product', BATCH_SIZE, true);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(etype, esubtype, costCenters[0]);

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0, amount * 10, pmUser, costCenters);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, amount * 5, rsmUser);
        EMS_Budget_Allocation_Trigger_Helper.skipTriggerValidationRules = true;
        EMS_Event_Trigger_Helper.skipTriggerValidationRules = true;
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Closed', pmUser, etype, esubtype, Date.today() + 1, Date.today() + 3, amount * 2, BATCH_SIZE) ;

        Test.startTest();
        // Insert
        List<EMS_Budget_Allocation_gne__c> budgetAllocations = new List<EMS_Budget_Allocation_gne__c>();
        Integer i;
        for (i = 0; i < BATCH_SIZE; i++) {
            EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                    Allocated_Budget_gne__c = amount,
                    Percentage_Contribution_gne__c = 1,
                    Budget_Deductions_gne__c = 0,
                    EMS_Event_gne__c = events.get(i).Id,
                    RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Region Budget Allocation'),
                    EMS_Region_Budget_gne__c = regionBudgets.get(i).Id
            );
            budgetAllocations.add(budgetAllocation);
        }
        insert budgetAllocations;

        // update amount
        for (EMS_Budget_Allocation_gne__c ba :budgetAllocations) {
            ba.Allocated_Budget_gne__c = amount + 50;
        }
        update budgetAllocations;

        for (EMS_Budget_Region_gne__c rb : [SELECT Events_Allocated_Amount_gne__c FROM EMS_Budget_Region_gne__c WHERE Id IN :regionBudgets]) {
            System.assertEquals(0, rb.Events_Allocated_Amount_gne__c);
        }
        Test.stopTest();
    }

    private static testMethod void updateAllocatedAmountOnUpdateForClosedEvents_productBudget_Test() {
        String etype = 'Program';
        String esubtype = 'Product Promo';
        Decimal amount = 100;

        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Product', BATCH_SIZE, true);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(etype, esubtype, costCenters[0]);

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, amount * 10, pmUsers[0], costCenters);
        EMS_Budget_Allocation_Trigger_Helper.skipTriggerValidationRules = true;
        EMS_Event_Trigger_Helper.skipTriggerValidationRules = true;
        List<EMS_Event__c> events = EMS_Test_Util.createEvents ('Closed', pmUsers[0], etype, esubtype, Date.today() + 1, Date.today() + 3, amount * 2, BATCH_SIZE);

        Test.startTest();
        Integer i;
        List<EMS_Budget_Allocation_gne__c> budgetAllocations = new List<EMS_Budget_Allocation_gne__c>();
        for (i = 0; i < BATCH_SIZE; i++) {
            EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                    Allocated_Budget_gne__c = amount,
                    Percentage_Contribution_gne__c = 1,
                    Budget_Deductions_gne__c = 0,
                    EMS_Event_gne__c = events.get(i).Id,
                    RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Product Budget Allocation'),
                    EMS_Product_Budget_gne__c = productBudgets.get(i).Id
            );
            budgetAllocations.add(budgetAllocation);
        }
        insert budgetAllocations;

        // update amount
        for (EMS_Budget_Allocation_gne__c ba :budgetAllocations) {
            ba.Allocated_Budget_gne__c = amount + 50;
        }
        update budgetAllocations;

        for (EMS_Budget_Product_gne__c pb : [SELECT Events_Allocated_Amount__c FROM EMS_Budget_Product_gne__c WHERE Id IN :productBudgets]) {
            System.assertEquals(0, pb.Events_Allocated_Amount__c);
        }
        Test.stopTest();
    }

    private static testMethod void changeEventStatusIfNeed_test() { //614
        String etype = 'Program';
        String esubtype = 'Product Promo';
        Decimal amount = 100;

        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(etype, esubtype, costCenters[0]);

        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, amount * 10, pmUsers[0], costCenters[0].Id);

        EMS_Event__c event = EMS_Test_Util.prepareEvents('Unplanned', pmUsers[0], etype, esubtype, Date.today(), Date.today() + 7, amount, null, null, 1)[0];
        event.Pending_Budget_Approval_gne__c = true;
        EMS_Event_Trigger_Helper.skipTriggerValidationRules = true;
        insert event;

        Test.startTest();
        EMS_Budget_Allocation_gne__c ba1 = new EMS_Budget_Allocation_gne__c(
                Allocated_Budget_gne__c = amount * (0.546),
                Percentage_Contribution_gne__c = 1,
                Budget_Deductions_gne__c = 0,
                EMS_Event_gne__c = event.Id,
                RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Product Budget Allocation'),
                EMS_Product_Budget_gne__c = pb.Id
        );
        EMS_Budget_Allocation_gne__c ba2 = new EMS_Budget_Allocation_gne__c(
                Allocated_Budget_gne__c = amount * (1 - 0.546),
                Percentage_Contribution_gne__c = 1,
                Budget_Deductions_gne__c = 0,
                EMS_Event_gne__c = event.Id,
                RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Product Budget Allocation'),
                EMS_Product_Budget_gne__c = pb.Id
        );
        insert new List<EMS_Budget_Allocation_gne__c>{
                ba1, ba2
        };

        EMS_Budget_Allocation_Trigger_Helper.clearProcessedSet();
        delete ba1;
        // nothing has changed, cannot make isBudgetOK == false
        Test.stopTest();
    }

    private static testMethod void updateAllocatedBudgetOnDelete_product_test() { //719
        String etype = 'Program';
        String esubtype = 'Product Promo';
        Decimal amount = 100;

        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Product', BATCH_SIZE, true);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(etype, esubtype, costCenters[0]);

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, amount * 10, pmUsers[0], costCenters);
        EMS_Budget_Allocation_Trigger_Helper.skipTriggerValidationRules = true;
        EMS_Event_Trigger_Helper.skipTriggerValidationRules = true;
        List<EMS_Event__c> events = EMS_Test_Util.createEvents ('Closed', pmUsers[0], etype, esubtype, Date.today() + 1, Date.today() + 3, amount * 2, BATCH_SIZE);

        Test.startTest();
        Integer i;
        List<EMS_Budget_Allocation_gne__c> budgetAllocations = new List<EMS_Budget_Allocation_gne__c>();
        for (i = 0; i < BATCH_SIZE; i++) {
            EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                    Allocated_Budget_gne__c = amount,
                    Percentage_Contribution_gne__c = 1,
                    Budget_Deductions_gne__c = 0,
                    EMS_Event_gne__c = events.get(i).Id,
                    RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Product Budget Allocation'),
                    EMS_Product_Budget_gne__c = productBudgets.get(i).Id
            );
            budgetAllocations.add(budgetAllocation);
        }
        insert budgetAllocations;

        // delete
        EMS_Budget_Allocation_Trigger_Helper.clearProcessedSet();
        delete budgetAllocations;

        for (EMS_Budget_Product_gne__c pb : [SELECT Events_Allocated_Amount__c FROM EMS_Budget_Product_gne__c WHERE Id IN :productBudgets LIMIT 1]) {
            System.assertEquals(0, pb.Events_Allocated_Amount__c);
        }
        Test.stopTest();
    }

    private static testMethod void updateAllocatedBudgetOnDelete_region_test() { //728
        String etype = 'Program';
        String esubtype = 'Product Promo';
        Decimal amount = 100;

        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Product', BATCH_SIZE, true);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(etype, esubtype, costCenters[0]);

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0, amount * 10, pmUser, costCenters);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, amount * 5, rsmUser);
        EMS_Budget_Allocation_Trigger_Helper.skipTriggerValidationRules = true;
        EMS_Event_Trigger_Helper.skipTriggerValidationRules = true;
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Closed', pmUser, etype, esubtype, Date.today() + 1, Date.today() + 3, amount * 2, BATCH_SIZE) ;

        Test.startTest();
        // Insert
        List<EMS_Budget_Allocation_gne__c> budgetAllocations = new List<EMS_Budget_Allocation_gne__c>();
        Integer i;
        for (i = 0; i < BATCH_SIZE; i++) {
            EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                    Allocated_Budget_gne__c = amount,
                    Percentage_Contribution_gne__c = 1,
                    Budget_Deductions_gne__c = 0,
                    EMS_Event_gne__c = events.get(i).Id,
                    RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Region Budget Allocation'),
                    EMS_Region_Budget_gne__c = regionBudgets.get(i).Id
            );
            budgetAllocations.add(budgetAllocation);
        }
        insert budgetAllocations;

        // delete
        EMS_Budget_Allocation_Trigger_Helper.clearProcessedSet();
        delete budgetAllocations;

        for (EMS_Budget_Region_gne__c rb : [SELECT Events_Allocated_Amount_gne__c FROM EMS_Budget_Region_gne__c WHERE Id IN :regionBudgets LIMIT 1]) {
            System.assertEquals(0, rb.Events_Allocated_Amount_gne__c);
        }
        Test.stopTest();
    }

    private static testMethod void updateAllocatedBudgetOnDelete_territory_test() { //739
        String etype = 'Program';
        String esubtype = 'Product Promo';
        Decimal amount = 100;

        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM', 'Rep');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        Id repUser = ids[2];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);
        System.assertNotEquals(null, repUser);


        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(etype, esubtype, costCenters[0]);

        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, amount * 10, pmUser, costCenters[0].Id);
        EMS_Budget_Region_gne__c rb = EMS_Test_Util.createRegionBudget(pb.Id, 0.0, amount * 5, rsmUser);
        EMS_Budget_Territory_gne__c tb = EMS_Test_Util.createTerritoryBudget(rb.Id, 0.0, amount * 2, repUser);

        EMS_Budget_Allocation_Trigger_Helper.skipTriggerValidationRules = true;
        EMS_Event__c event = EMS_Test_Util.prepareEvents('Closed', pmUser, etype, esubtype, Date.today(), Date.today() + 7, amount, null, null, 1)[0];
        event.Pending_Budget_Approval_gne__c = true;
        EMS_Event_Trigger_Helper.skipTriggerValidationRules = true;
        insert event;

        Test.startTest();
        EMS_Budget_Allocation_gne__c ba = new EMS_Budget_Allocation_gne__c(
                Allocated_Budget_gne__c = amount,
                Percentage_Contribution_gne__c = 1,
                Budget_Deductions_gne__c = 0,
                EMS_Event_gne__c = event.Id,
                RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Territory Budget Allocation'),
                EMS_Territory_Budget_gne__c = tb.Id
        );
        insert ba;

        // delete
        EMS_Budget_Allocation_Trigger_Helper.clearProcessedSet();
        delete ba;

        tb = [SELECT Events_Allocated_Amount_gne__c FROM EMS_Budget_Territory_gne__c WHERE Id = :tb.Id LIMIT 1];
        System.assertEquals(0, tb.Events_Allocated_Amount_gne__c);
        Test.stopTest();
    }
}