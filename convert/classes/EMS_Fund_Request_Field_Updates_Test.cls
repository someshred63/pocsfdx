@isTest
private class EMS_Fund_Request_Field_Updates_Test {

    private static final Integer BATCH_SIZE = 1;//10;

/**
 * 1. overrideApprover
 * 2. escalateFundRequest
 * 3. overrideApproveRejectComment
 * 
 */

    // 1. overrideApprover
    // 1.1 overrideApprover. Territory Fund Allocation RegionBudget Assigned_to_gne__c not empty
    static testmethod void overrideApprover_TerritoryFundAllocationAndRBAssignedToNotEmpty_shouldOverrideApproverFromRB_test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        Id repUser = EMS_Test_Util.findExistingUser('Rep', rsmUser)[0];
        System.assertNotEquals(null, repUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser);
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0, 300, repUser);
        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachTB('Territory Fund Allocation', territoryBudgets, 50, 1, true);

        User testU = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        system.runAs(testU) {
            Test.startTest();
            for (EMS_Budget_Product_gne__c pb : productBudgets) {
                system.assertNotEquals(null, pb.Assigned_To_gne__c);
            }
            for (EMS_Budget_Region_gne__c rb : regionBudgets) {
                system.assertNotEquals(null, rb.Assigned_To_gne__c);
            }

            fundRequests = [SELECT Id, Approver_gne__c FROM EMS_Fund_Request_gne__c WHERE id IN :fundRequests];
            for (EMS_Fund_Request_gne__c fr : fundRequests) {
                system.assertEquals(null, fr.Approver_gne__c);
            }

            for (EMS_Fund_Request_gne__c fr : fundRequests) {
                fr.Status_gne__c = 'Submitted';
            }
            update fundRequests;

            fundRequests = [SELECT Id, Approver_gne__c FROM EMS_Fund_Request_gne__c WHERE id IN :fundRequests];
            for (EMS_Fund_Request_gne__c fr : fundRequests) {
                system.assertEquals(rsmUser, fr.Approver_gne__c);
            }

            Test.stopTest();
        }
    }

    //1.3 overrideApprover. Region Fund Allocation
    private static testMethod void overrideApprover_RegionFundAllocation_shouldOverrideApproverFromPB_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser);
        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachRB('Region Fund Allocation', regionBudgets, 50, 1, false);

        User testU = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        system.runAs(testU) {
            Test.startTest();
            try {
                insert fundRequests;

                for (EMS_Fund_Request_gne__c fr : fundRequests) {
                    fr.Status_gne__c = 'Submitted';
                }
                update fundRequests;

            } catch (DMLException ex) {
                System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
            }
            Test.stopTest();

            for (EMS_Fund_Request_gne__c fr : [SELECT Id, Approver_gne__c FROM EMS_Fund_Request_gne__c WHERE id IN :fundRequests]) {
                system.assertEquals(pmUser, fr.Approver_gne__c);
            }

        }
    }

    //1.4 overrideApprover. Region Fund De-Allocation
    private static testMethod void overrideApprover_RegionFundDeAllocation_shouldOverrideApproverFromPB_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser);
        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachRB('Region Fund De-Allocation', regionBudgets, -50, 1, false);

        User testU = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        system.runAs(testU) {
            Test.startTest();
            try {
                insert fundRequests;

                for (EMS_Fund_Request_gne__c fr : fundRequests) {
                    fr.Status_gne__c = 'Submitted';
                }
                update fundRequests;

            } catch (DMLException ex) {
                System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
            }
            Test.stopTest();

            for (EMS_Fund_Request_gne__c fr : [SELECT Id, Approver_gne__c FROM EMS_Fund_Request_gne__c WHERE id IN :fundRequests]) {
                system.assertEquals(rsmUser, fr.Approver_gne__c);
            }

        }
    }

    //1.5 overrideApprover. Territory Fund De-Allocation
    private static testMethod void overrideApprover_TerritoryFundDeAllocation_shouldOverrideApproverFromTB_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        Id repUser = EMS_Test_Util.findExistingUser('Rep', rsmUser)[0];
        System.assertNotEquals(null, repUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser);
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0, 300, repUser);
        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachTB('Territory Fund De-Allocation', territoryBudgets, -50, 1, false);

        User testU = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        system.runAs(testU) {
            Test.startTest();
            try {
                insert fundRequests;

                for (EMS_Fund_Request_gne__c fr : fundRequests) {
                    fr.Status_gne__c = 'Submitted';
                }
                update fundRequests;

            } catch (DMLException ex) {
                System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
            }
            Test.stopTest();

            for (EMS_Fund_Request_gne__c fr : [SELECT Id, Approver_gne__c FROM EMS_Fund_Request_gne__c WHERE id IN :fundRequests]) {
                system.assertEquals(repUser, fr.Approver_gne__c);
            }
        }
    }

    //1.6 overrideApprover. Territory Fund De-Allocation. With user Delgation
    private static testMethod void overrideApprover_TerritoryFundDeAllocation_shouldOverrideApproverFromTBAndUseDelegatedApprover_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        Id repUser = EMS_Test_Util.findExistingUser('Rep', rsmUser)[0];
        System.assertNotEquals(null, repUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        EMS_Test_Util.createUserDelegation(repUser, pmUser, Date.today() - 1, Date.today() + 1, 'Test delegation');

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser);
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0, 300, repUser);
        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachTB('Territory Fund De-Allocation', territoryBudgets, -50, 1, false);

        User testU = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        system.runAs(testU) {
            Test.startTest();
            try {
                insert fundRequests;

                for (EMS_Fund_Request_gne__c fr : fundRequests) {
                    fr.Status_gne__c = 'Submitted';
                }
                update fundRequests;

            } catch (DMLException ex) {
                System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
            }
            Test.stopTest();

            for (EMS_Fund_Request_gne__c fr : [SELECT Id, Approver_gne__c FROM EMS_Fund_Request_gne__c WHERE id IN :fundRequests]) {
                system.assertEquals(pmUser, fr.Approver_gne__c);
            }
        }
    }

    // ??
    //1.2 overrideApprover. Territory Fund Allocation RegionBudget Assigned_to_gne__c empty
    static testmethod void overrideApprover_TerritoryFundAllocationAndRBAssignedToEmpty_shouldOverrideApproverFromPB_test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        List<Id> repUsers = EMS_Test_Util.findExistingUser('Rep', rsmUser);
        System.assertNotEquals(0, repUsers.size());
        System.assertNotEquals(1, repUsers.size());
        Id repUser = repUsers[0];
        Id repUserTempId = repUsers[1];

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        EMS_Product_Budget_Helper.skipTriggerValidationRules = TRUE;
        EMS_Region_Budget_Helper.skipTriggerValidationRules = TRUE;
        EMS_Territory_Budget_Helper.skipTriggerValidationRules = TRUE;

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, repUserTempId);
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0, 300, repUserTempId);
        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachTB('Territory Fund Allocation', territoryBudgets, 50, 1, true);

        User testU = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        system.runAs(testU) {
            Test.startTest();
            // Check if only Product has assignedTo
            for (EMS_Budget_Product_gne__c pb : productBudgets) {
                System.assertNotEquals(null, pb.Assigned_To_gne__c);
            }
            for (EMS_Budget_Region_gne__c rb : regionBudgets) {
                System.assertEquals(repUserTempId, rb.Assigned_To_gne__c);
            }
            for (EMS_Budget_Territory_gne__c tb : territoryBudgets) {
                System.assertEquals(repUserTempId, tb.Assigned_To_gne__c);
            }

            // update status to submitted
            List<Approval.ProcessSubmitRequest> apprRequests = new List<Approval.ProcessSubmitRequest>();
            for (EMS_Fund_Request_gne__c fr : fundRequests) {
                fr.Status_gne__c = 'Submitted';
            }
            update fundRequests;

            //for (Approval.ProcessResult res : results) {
            //	System.assertEquals(true, res.isSuccess());
            //	System.assertEquals('Pending', res.getInstanceStatus(), 'Wrong instance Status: ' + res.getInstanceStatus());
            //}

            fundRequests = [SELECT Id, Approver_gne__c FROM EMS_Fund_Request_gne__c WHERE id IN :fundRequests];
            for (EMS_Fund_Request_gne__c fr : fundRequests) {
                system.assertEquals(repUserTempId, fr.Approver_gne__c);
            }

            Test.stopTest();
        }
    }

    //3. overrideApproveRejectComment
    //3.1 Approval comment not null
    private static testMethod void overrideApproveRejectComment_arCommentsNotNullStepCommentsNotNull_ApprovalComentNotNull_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser);
        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachRB('Region Fund Allocation', regionBudgets, 50, 1, false);

        User testU = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        system.runAs(testU) {
            insert fundRequests;

            Test.startTest();
            try {
                // Submit for approval
                List<Approval.ProcessSubmitRequest> apprRequests = new List<Approval.ProcessSubmitRequest>();
                for (EMS_Fund_Request_gne__c fr : fundRequests) {
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    req.setObjectId(fr.Id);
                    req.setComments('Submit step comment.');
                    req.setNextApproverIds(new Id[]{
                            UserInfo.getUserId()
                    });
                    apprRequests.add(req);
                }

                List<Approval.ProcessResult> apprRequestsResults = Approval.process(apprRequests);
                for (Approval.ProcessResult res : apprRequestsResults) {
                    System.assertEquals(true, res.isSuccess());
                    System.assertEquals('Pending', res.getInstanceStatus(), 'Wrong instance Status: ' + res.getInstanceStatus());
                }

                // Approve submitted requests
                List<Approval.ProcessWorkitemRequest> wiProcessRequests = new List<Approval.ProcessWorkitemRequest>();
                for (Approval.ProcessResult arr : apprRequestsResults) {
                    List<Id> newWorkItemIds = arr.getNewWorkitemIds(); // Get ID of newly created item

                    Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                    req2.setWorkitemId(newWorkItemIds.get(0));
                    req2.setComments('Approval step comment.');
                    req2.setAction('Approve');
                    req2.setNextApproverIds(new Id[]{
                            UserInfo.getUserId()
                    });
                    wiProcessRequests.add(req2);
                }
                List<Approval.ProcessResult> wiProcessResults = Approval.process(wiProcessRequests);

                for (Approval.ProcessResult res : wiProcessResults) {
                    System.assertEquals(true, res.isSuccess());
                    System.assertEquals('Approved', res.getInstanceStatus(), 'Wrong instance Status: ' + res.getInstanceStatus());
                }
            } catch (DMLException ex) {
                System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
            }
            Test.stopTest();

            for (EMS_Fund_Request_gne__c fr : [SELECT Id, Approval_Rejection_Comments_gne__c FROM EMS_Fund_Request_gne__c WHERE id IN :fundRequests]) {
                system.assertEquals(null, fr.Approval_Rejection_Comments_gne__c);
            }
        }
    }

    // 2. escalateFundRequest
    // 2.1 Territory Fund Allocation
    private static testMethod void escalateFundRequest_TerritoryFundAllocation_shouldOverrideApproverFromPBAssignedTo_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        Id repUser = EMS_Test_Util.findExistingUser('Rep', rsmUser)[0];
        System.assertNotEquals(null, repUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser);
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0, 300, repUser);
        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachTB('Territory Fund Allocation', territoryBudgets, 50, 1, false);

        User testU = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        system.runAs(testU) {
            insert fundRequests;

            EMS_Fund_Request_Trigger_Helper.clearProcessedSet();
            EMS_Fund_Request_Trigger_Helper.inFundRequestTrigger = false;

            Test.startTest();
            try {
                for (EMS_Fund_Request_gne__c fr : fundRequests) {
                    fr.Escalated_gne__c = true;
                }
                update fundRequests;

            } catch (DMLException ex) {
                System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
            }
            Test.stopTest();

            for (EMS_Fund_Request_gne__c fr : [SELECT Id, Approver_gne__c FROM EMS_Fund_Request_gne__c WHERE id IN :fundRequests]) {
                system.assertEquals(pmUser, fr.Approver_gne__c);
            }
        }
    }

    // 2.2 Region Fund Allocation
    private static testMethod void escalateFundRequest_RegionFundAllocation_shouldSetTopLevelApprovalToTrue_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser);
        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachRB('Region Fund Allocation', regionBudgets, 50, 1, false);

        User testU = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        system.runAs(testU) {
            insert fundRequests;

            EMS_Fund_Request_Trigger_Helper.clearProcessedSet();
            EMS_Fund_Request_Trigger_Helper.inFundRequestTrigger = false;

            Test.startTest();
            try {
                for (EMS_Fund_Request_gne__c fr : [SELECT Id, Top_Level_Approval_gne__c FROM EMS_Fund_Request_gne__c WHERE id IN :fundRequests]) {
                    system.assertEquals(false, fr.Top_Level_Approval_gne__c);
                }
                for (EMS_Fund_Request_gne__c fr : fundRequests) {
                    fr.Escalated_gne__c = true;
                }
                update fundRequests;
            } catch (DMLException ex) {
                System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
            }
            Test.stopTest();

            for (EMS_Fund_Request_gne__c fr : [SELECT Id, Top_Level_Approval_gne__c FROM EMS_Fund_Request_gne__c WHERE id IN :fundRequests]) {
                system.assertEquals(true, fr.Top_Level_Approval_gne__c);
            }
        }
    }

    // 2.4 Territory Fund De-Allocation
    private static testMethod void escalateFundRequest_TerritoryFundDeAllocation_shouldOverrideApproverFromPBAssignedTo_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        Id repUser = EMS_Test_Util.findExistingUser('Rep', rsmUser)[0];
        System.assertNotEquals(null, repUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser);
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0, 300, repUser);
        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachTB('Territory Fund De-Allocation', territoryBudgets, -50, 1, false);

        User testU = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        system.runAs(testU) {
            insert fundRequests;

            EMS_Fund_Request_Trigger_Helper.clearProcessedSet();
            EMS_Fund_Request_Trigger_Helper.inFundRequestTrigger = false;

            Test.startTest();
            try {
                for (EMS_Fund_Request_gne__c fr : fundRequests) {
                    fr.Escalated_gne__c = true;
                }
                update fundRequests;
            } catch (DMLException ex) {
                System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
            }
            Test.stopTest();

            for (EMS_Fund_Request_gne__c fr : [SELECT Id, Approver_gne__c FROM EMS_Fund_Request_gne__c WHERE id IN :fundRequests]) {
                system.assertEquals(repUser, fr.Approver_gne__c);
            }
        }
    }

    //3.1 Approval comment null
    private static testMethod void overrideApproveRejectComment_arCommentsNotNullStepCommentsNotNull_ApprovalCommentNull_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser);
        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachRB('Region Fund Allocation', regionBudgets, 50, 1, false);

        User testU = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        system.runAs(testU) {
            insert fundRequests;

            Test.startTest();
            try {
                // Submit for approval
                List<Approval.ProcessSubmitRequest> apprRequests = new List<Approval.ProcessSubmitRequest>();
                for (EMS_Fund_Request_gne__c fr : fundRequests) {
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    req.setObjectId(fr.Id);
                    req.setComments('Submit step comment.');
                    req.setNextApproverIds(new Id[]{
                            UserInfo.getUserId()
                    });
                    apprRequests.add(req);
                }
                List<Approval.ProcessResult> apprRequestsResults = Approval.process(apprRequests);

                for (Approval.ProcessResult res : apprRequestsResults) {
                    System.assertEquals(true, res.isSuccess());
                    System.assertEquals('Pending', res.getInstanceStatus(), 'Wrong instance Status: ' + res.getInstanceStatus());
                }
                // Approve submitted requests
                List<Approval.ProcessWorkitemRequest> wiProcessRequests = new List<Approval.ProcessWorkitemRequest>();

                for (Approval.ProcessResult arr : apprRequestsResults) {
                    List<Id> newWorkItemIds = arr.getNewWorkitemIds(); // Get ID of newly created item

                    Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                    req2.setWorkitemId(newWorkItemIds.get(0));
                    //req2.setComments('Approval step comment.'); // comment is null
                    req2.setAction('Approve');
                    req2.setNextApproverIds(new Id[]{
                            UserInfo.getUserId()
                    });
                    wiProcessRequests.add(req2);
                }
                List<Approval.ProcessResult> wiProcessResults = Approval.process(wiProcessRequests);

                for (Approval.ProcessResult res : wiProcessResults) {
                    System.assertEquals(true, res.isSuccess());
                    System.assertEquals('Approved', res.getInstanceStatus(), 'Wrong instance Status: ' + res.getInstanceStatus());
                }
            } catch (DMLException ex) {
                System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
            }
            Test.stopTest();

            for (EMS_Fund_Request_gne__c fr : [SELECT Id, Approval_Rejection_Comments_gne__c FROM EMS_Fund_Request_gne__c WHERE id IN :fundRequests]) {
                system.assertEquals(null, fr.Approval_Rejection_Comments_gne__c);
            }
        }
    }

}