@isTest
private class EDM_ABM_Utils_Test {
    private static EDM_AABP_gne__c aabp;
    private static EDM_IABP_gne__c iabp;

    private static void setCommonTestData() {
        List<sObject> testData = EDM_ABM_Test_Utils.insertABMStructure();

        aabp = (EDM_AABP_gne__c)testData[0];
        iabp = (EDM_IABP_gne__c)testData[1];
    }

    @isTest static void testGetUsersForRole() {
        List<USer> ABSes = EDM_ABM_Utils.getUsersForRole(EDM_ABM_Utils.ABS);
        System.assert(ABSes.size() > 0);
    }

    @isTest static void testUserRole() {
        String role;
        List<USer> ABSes = EDM_ABM_Utils.getUsersForRole(EDM_ABM_Utils.ABS);
        if (ABSes.size() > 0) {
            role = EDM_ABM_Utils.getUserRole(ABSes[0].Id);
        }
        System.assert(role == EDM_ABM_Utils.ABS);
    }

    @isTest static void testGetUserIdsForRole() {
        Set<Id> ABSes = EDM_ABM_Utils.getUserIdsForRole(EDM_ABM_Utils.ABS);
        System.assert(ABSes.size() > 0);
    }

    @isTest static void testGetTimeDifference() {
        String diff = EDM_ABM_Utils.getTimeDifference(true, '04:30 PM', '05:00 PM');
        System.assert(diff == '30');

        String diff2 = EDM_ABM_Utils.getTimeDifference(false, '04:30 PM', '05:00 PM');
        System.assert(diff2 == '0:30');
    }

    @isTest static void testHasPermissionSet() {
        Boolean b;
        List<USer> ABSes = EDM_ABM_Utils.getUsersForRole(EDM_ABM_Utils.ABS);
        if (ABSes.size() > 0) {
            System.runAs(ABSes[0]) {
                b = EDM_ABM_Utils.hasPermissionSet(EDM_ABM_Utils.ABS);
            }
        }
        System.assert(b);
    }

    @isTest static void testShares() {

        Test.startTest();
        EDM_AABP_gne__c parent = EDM_ABM_Test_Utils.getTestAABP('gRED');
        insert parent;
        EDM_IABP_gne__c child = EDM_ABM_Test_Utils.getTestIABP('iAdvice', false, '04/04/2016', parent.Id);
        insert child;
        EDM_IABP_gne__c child2 = EDM_ABM_Test_Utils.getTestIABP('Face to Face', false, '04/04/2016', parent.Id);
        insert child2;

        List<User> ableads = EDM_ABM_Utils.getUsersForRole(EDM_ABM_Utils.ABLEAD);
        Set<Id> ableadsIds = EDM_ABM_Utils.getUserIdsForRole(EDM_ABM_Utils.ABLEAD);
        EDM_ABM_Utils.setSharing(child.Id, ableadsIds, EDM_ABM_Utils.ABLEAD);

        if (ableads.size() > 0) {
            System.runAs(ableads[0]) {
                List<UserRecordAccess> acc = [SELECT HasAllAccess, HasDeleteAccess, HasEditAccess, HasReadAccess, HasTransferAccess, MaxAccessLevel, RecordId FROM UserRecordAccess
                WHERE UserId = :ableads[0].Id AND RecordId = :child.Id];
                if (acc.size() > 0) {
                    System.assert(true);
                }
                else {
                    System.assert(false);
                }
            }
        }

        List<SelectOption> lst = EDM_ABM_Utils.populateSharedWith(child.Id, EDM_ABM_Utils.ABLEAD);
        if (lst.size() > 0) {
            System.assert(true);
        }
        else {
            System.assert(false);
        }

        ableadsIds.clear();
        EDM_ABM_Utils.setSharing(child.Id, ableadsIds, EDM_ABM_Utils.ABLEAD);
        List<SelectOption> lst2 = EDM_ABM_Utils.populateSharedWith(child.Id, EDM_ABM_Utils.ABLEAD);
        if (lst2.size() > 0) {
            System.assert(false);
        }
        else {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest static void testSnapshot() {
        EDM_AABP_gne__c parent = EDM_ABM_Test_Utils.getTestAABP('gRED');
        insert parent;
        EDM_IABP_gne__c child = EDM_ABM_Test_Utils.getTestIABP('iAdvice', false, '04/04/2016', parent.Id);
        insert child;

        EDM_ABM_Utils.createSnapshot(child.Id);

        System.assert([SELECT Id FROM EDM_IABP_gne__c WHERE EDM_History_Parent_IABP_gn__c = :child.Id].size() > 0);
    }

    @isTest static void testGetMinutesFromHM() {
        Integer t = EDM_ABM_Utils.getMinutesFromHM('01:30');
        System.assert(t == 90);
    }

    @isTest static void testAABPShares() {
        EDM_AABP_gne__c parent = EDM_ABM_Test_Utils.getTestAABP('gRED');
        insert parent;
        EDM_IABP_gne__c child = EDM_ABM_Test_Utils.getTestIABP('iAdvice', false, '04/04/2016', parent.Id);
        insert child;
        List<User> abses = EDM_ABM_Utils.getUsersForRole(EDM_ABM_Utils.ABS);
        Set<Id> absesId = EDM_ABM_Utils.getUserIdsForRole(EDM_ABM_Utils.ABS);
        absesId.addAll(EDM_ABM_Utils.getUserIdsForRole(EDM_ABM_Utils.ABLEAD));
        EDM_ABM_Utils.setSharing(parent.Id, absesId, EDM_ABM_Utils.ABS);
        EDM_ABM_Utils.setSharing(child.Id, absesId, EDM_ABM_Utils.ABS);

        Test.startTest();
        if (abses.size() > 0) {
            System.runAs(abses[0]) {
                List<UserRecordAccess> acc = [SELECT HasAllAccess, HasDeleteAccess, HasEditAccess, HasReadAccess, HasTransferAccess, MaxAccessLevel, RecordId FROM UserRecordAccess
                WHERE UserId = :abses[0].Id AND RecordId = :parent.Id];
                if (acc.size() > 0) {
                    System.assert(true);
                }
                else {
                    System.assert(false);
                }
            }
        }
        else {
            System.assert(false);
        }

        List<SelectOption> lst = EDM_ABM_Utils.populateSharedWith(parent.Id, EDM_ABM_Utils.ABS);
        if (lst.size() > 0) {
            System.assert(true);
        }
        else {
            System.assert(false);
        }

        absesId.clear();
        EDM_ABM_Utils.setSharing(parent.Id, absesId, EDM_ABM_Utils.ABS);
        EDM_ABM_Utils.setSharing(child.Id, absesId, EDM_ABM_Utils.ABS);
        lst = EDM_ABM_Utils.populateSharedWith(parent.Id, EDM_ABM_Utils.ABS);
        if (lst.size() > 0) {
            System.assert(false);
        }
        else {
            System.assert(true);
        }

        lst = EDM_ABM_Utils.populateSharedWith(child.Id, EDM_ABM_Utils.ABS);
        if (lst.size() > 0) {
            System.assert(false);
        }
        else {
            System.assert(true);
        }
        Test.stopTest();
    }

    // WS:
    @isTest static void ablShoudShareWithABLsAndVDST() {
        //given
        String sharingUserRole = EDM_ABM_Utils.ABLEAD;
        List<String> roleNames = new List<String> {
                EDM_ABM_Utils.ABLEAD,
                EDM_ABM_Utils.VDST_ABM
        };
        Set<Id> userIdsForABLAndVDST = new Set<Id>();

        List<PermissionSetAssignment> permSetAssign = [SELECT Id, AssigneeId FROM PermissionSetAssignment
        WHERE PermissionSetId IN (SELECT Id FROM PermissionSet WHERE Name in :roleNames)
        AND Assignee.IsActive = true];

        for (PermissionSetAssignment psa : permSetAssign) {
            userIdsForABLAndVDST.add(psa.AssigneeId);
        }

        //when
        List<User> availableUsers = EDM_ABM_Utils.getUsersToShareWith(sharingUserRole);
        Set<Id> availableUsersIds = new Set<Id>();
        for (User u : availableUsers) {
            availableUsersIds.add(u.Id);
        }

        //then
        System.assert(availableUsersIds.containsAll(userIdsForABLAndVDST));
    }

    @isTest static void absShoudShareWithAll() {
        //given
        String sharingUserRole = EDM_ABM_Utils.ABS;
        List<String> roleNames = new List<String> {
                EDM_ABM_Utils.ABLEAD,
                EDM_ABM_Utils.ABAPPROVER,
                EDM_ABM_Utils.ABAPPROVER_NO_LIC,
                EDM_ABM_Utils.ABREVIEWER,
                EDM_ABM_Utils.ABREVIEWER_NO_LIC,
                EDM_ABM_Utils.VDST_ABM
        };
        Set<Id> userIdsForAllRoles = new Set<Id>();

        List<PermissionSetAssignment> permSetAssign = [SELECT Id, AssigneeId FROM PermissionSetAssignment
        WHERE PermissionSetId IN (SELECT Id FROM PermissionSet WHERE Name in :roleNames)
        AND Assignee.IsActive = true];

        for (PermissionSetAssignment psa : permSetAssign) {
            userIdsForAllRoles.add(psa.AssigneeId);
        }

        //when
        List<User> availableUsers = EDM_ABM_Utils.getUsersToShareWith(sharingUserRole);
        Set<Id> availableUsersIds = new Set<Id>();
        for (User u : availableUsers) {
            availableUsersIds.add(u.Id);
        }

        //then
        System.assert(availableUsersIds.containsAll(userIdsForAllRoles));
    }

    @isTest static void shoudCheckThatIdIsOK() {
        //given
        setCommonTestData();

        //when
        String realId = aabp.Id;

        //then
        System.assertEquals(EDM_ABM_Utils.isValidId(realId), true);
    }

    @isTest static void shoudCheckThatIdIsWrong() {
        String dummyId = 'AlAMakota';
        System.assertNotEquals(EDM_ABM_Utils.isValidId(dummyId), true);
    }

    @isTest static void aabpShouldNotBeSharedWithAnyone() {
        //given
        setCommonTestData();
        String checkingUserRole = EDM_ABM_Utils.ABS;

        //when
        List<User> usersSharedWith = EDM_ABM_Utils.getSharedWithUsers(aabp.Id, checkingUserRole);

        //then
        System.assertEquals(usersSharedWith.isEmpty(), true);
    }

    @isTest static void aabpAbsUsersShouldNotBeVisibleForABPlannersToUnshare() {
        //given
        setCommonTestData();
        String checkingUserRole = EDM_ABM_Utils.ABLEAD;
        Set<Id> absIds = EDM_ABM_Utils.getUserIdsForRole(EDM_ABM_Utils.ABS);

        //delete abs users' assignment to permsets ABLEAD and VDST_ABM
        //with workaround for MIXED_DML_OPERATION error when trying to delete permsets

        Profile p_AB_Man = [Select Id From Profile Where Name = 'GNE-TLS-Manager'];

        User u = new User(
                FirstName = 'Manager',
                ProfileId = p_AB_Man.Id,
                Username = 'b@roche.com',
                LastName = 'Test',
                Email = 'b@roche.com',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'ISO-8859-1',
                LanguageLocaleKey = 'en_US'
        );
        insert u;

        System.RunAs(u){
            List<PermissionSetAssignment> permSetAssignToDelete = [ SELECT Id
            FROM PermissionSetAssignment
            WHERE PermissionSet.Name
                    IN ( :EDM_ABM_Utils.ABLEAD, :EDM_ABM_Utils.VDST_ABM) AND AssigneeId IN :absIds
            ];
            if (!permSetAssignToDelete.isEmpty()){
                delete permSetAssignToDelete;
            }
        }

        //when
        EDM_ABM_Utils.setSharing(aabp.Id, absIds, EDM_ABM_Utils.ABS);
        List<User> usersSharedWith = EDM_ABM_Utils.getSharedWithUsers(aabp.Id, checkingUserRole);

        //then
        System.assertEquals(usersSharedWith.isEmpty(), true);

        checkingUserRole = EDM_ABM_Utils.VDST_ABM;
        usersSharedWith = EDM_ABM_Utils.getSharedWithUsers(aabp.Id, checkingUserRole);
        System.assertEquals(usersSharedWith.isEmpty(), true);
    }

    @isTest static void iabpAbsUsersShouldNotBeVisibleForABPlannersToUnshare() {
        //given
        setCommonTestData();
        String checkingUserRole = EDM_ABM_Utils.ABLEAD;
        Set<Id> absIds = EDM_ABM_Utils.getUserIdsForRole(EDM_ABM_Utils.ABS);

        //delete abs users' assignment to permsets ABLEAD and VDST_ABM
        //with workaround for MIXED_DML_OPERATION error when trying to delete permsets

        Profile p_AB_Man = [Select Id From Profile Where Name = 'GNE-TLS-Manager'];

        User u = new User(
                FirstName = 'Manager',
                ProfileId = p_AB_Man.Id,
                Username = 'b@roche.com',
                LastName = 'Test',
                Email = 'b@roche.com',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'ISO-8859-1',
                LanguageLocaleKey = 'en_US'
        );
        insert u;

        System.RunAs(u){
            List<PermissionSetAssignment> permSetAssignToDelete = [ SELECT Id
            FROM PermissionSetAssignment
            WHERE PermissionSet.Name
                    IN ( :EDM_ABM_Utils.ABLEAD, :EDM_ABM_Utils.VDST_ABM) AND AssigneeId IN :absIds
            ];
            if (!permSetAssignToDelete.isEmpty()) {
                delete permSetAssignToDelete;
            }
        }

        //when
        EDM_ABM_Utils.setSharing(iabp.Id, absIds, EDM_ABM_Utils.ABS);
        List<User> usersSharedWith = EDM_ABM_Utils.getSharedWithUsers(iabp.Id, checkingUserRole);

        //then
        System.assertEquals(usersSharedWith.isEmpty(), true);

        checkingUserRole = EDM_ABM_Utils.VDST_ABM;
        usersSharedWith = EDM_ABM_Utils.getSharedWithUsers(iabp.Id, checkingUserRole);
        System.assertEquals(usersSharedWith.isEmpty(), true);
    }

    @isTest static void shouldShareWithUsersFromJoinedAABPs() {
        //given
        setCommonTestData();
        List<User> absm = EDM_ABM_Utils.getUsersForRole(EDM_ABM_Utils.ABS);
        List<User> ableads = EDM_ABM_Utils.getUsersForRole(EDM_ABM_Utils.ABLEAD);
        User user1 = ableads[1];
        User user2 = ableads[2];
        EDM_AABP_gne__c joinedAABP = EDM_ABM_Test_Utils.getTestAABP('PD', absm[0], user1);
        insert joinedAABP;

        //when
        iabp.EDM_Joint_AABP_gne__c = joinedAABP.Id;
        update iabp;
        EDM_ABM_Utils.shareRecord(aabp.Id, new List<User> {user2}, EDM_ABM_Utils.AL_EDIT, EDM_ABM_Utils.SHARE_DIRECT);

        //then user1 should have access to  iabp
        System.assert(EDM_ABM_Test_Utils.userHasReadAccessToRecord(user1.Id, iabp.Id));
    }

    @isTest static void sharingIabpAlsoShouldShareParentAabp() {
        //given
        setCommonTestData();
        List<User> ableads = EDM_ABM_Utils.getUsersForRole(EDM_ABM_Utils.ABLEAD);
        User user1 = ableads[1];

        //when
        EDM_ABM_Utils.shareRecord(aabp.Id, new List<User> {user1}, EDM_ABM_Utils.AL_EDIT, EDM_ABM_Utils.SHARE_DIRECT);

        //then
        System.assertEquals(EDM_ABM_Test_Utils.userHasReadAccessToRecord(user1.Id, aabp.Id), true);

        //when
        EDM_ABM_Utils.unShareRecord(new Set<Id> {aabp.Id}, new List<User> {user1}, EDM_ABM_Utils.SHARE_DIRECT);

        //then
        System.assertNotEquals(EDM_ABM_Test_Utils.userHasReadAccessToRecord(user1.Id, aabp.Id), true);
    }
}