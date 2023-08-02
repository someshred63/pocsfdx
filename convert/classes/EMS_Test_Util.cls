@isTest
public class EMS_Test_Util {
    /**
     * This class contains test data generation methods for EMS-Canada.
     *  Order of apperance:
     *  1. System User (User)
     *  2. Territory (Territory)
     *  3. User delegations (GNE_User_Delegation__c)
     *  4. Account (Account)
     *  5. IHCP International Speaker (EMS_International_Speaker_gne__c)
     *  6. Cost Center (EMS_Cost_Center_gne__c)
     *  7. Product Budget (EMS_Budget_Product_gne__c)
     *  8. Region Budget (EMS_Budget_Region_gne__c)
     *  9. Territory Budget (EMS_Budget_Territory_gne__c)
     *  10. Budget Allocation (EMS_Budget_Allocation_gne__c)
     *  11. Event (EMS_Event__c)
     *  12. Event Product (EMS_Event_Product_gne__c)
     *  13. Attendee (EMS_Attendee_gne__c)
     *  14. Interaction (EMS_Interaction_gne__c)
     *  14. Roche Attendee (EMS_Roche_Attendee_gne__c)
     *  15. Fund Request (EMS_Fund_Request_gne__c)
     *  16. Travel (EMS_Travel_gne__c)
     *  17. GSDDetail (EMS_GSD_Detail__c)
     *  18. Investeent (EMS_Investment_gne__c)
     *  19. Expense (EMS_Expense_gne__c)
     *  20. Transaction (EMS_Transaction_gne__c)
     *  21. Payment Requests (EMS_Speaker_Role_gne__c)
     *  22. Attachment (EMS_Attachment_gne__c)
     *  23. Data Change Request (EMS_Data_Change_Request_gne__c)
     *  24. Meeting Request (EMS_Meeting_Request_gne__c)
     *
     *  -= Not implemented yet =-
     *  EMS Checklist (EMS_Checklist_gne__c)
     *  EMS Checklist Response (EMS_Checklist_Response_gne__c)
     *  EMS International Speaker Staging
     */


    public static String SYSTEM_ADMINISTRATOR_PROFILE_NAME = 'System Administrator';
    public static String COMPANY_ACCOUT_RECORDTYPE_NAME = 'Company';
    public static String TERRITORY_NAME = 'ROCHE-Canada';
    public static String CURRENT_YEAR = String.valueOf(Date.today().year());
    public static String GSD_EVENT_TYPES = 'GD;Sponsorship;Grants,Donation;Sponsorships';

    public static Map<Id, Set<Id>> userTerritoryMap = new Map<Id, Set<Id>>();
    private static Map<Id, String> territoryNames = new Map<Id, String>();

    public static Map<String, Id> pbRecordTypesMap;
    public static Map<String, Id> rbRecordTypesMap;
    public static Map<String, Id> tbRecordTypesMap;
    public static Map<String, Id> frRecordTypesMap;
    public static Map<String, Id> baRecordTypesMap;
    public static Map<String, Id> raRecordTypesMap;

    static {
        if (pbRecordTypesMap == null) pbRecordTypesMap = getRecordTypesMap('EMS_Budget_Product_gne__c');
        if (rbRecordTypesMap == null) rbRecordTypesMap = getRecordTypesMap('EMS_Budget_Region_gne__c');
        if (tbRecordTypesMap == null) tbRecordTypesMap = getRecordTypesMap('EMS_Budget_Territory_gne__c');
        if (frRecordTypesMap == null) frRecordTypesMap = getRecordTypesMap('EMS_Fund_Request_gne__c');
        if (baRecordTypesMap == null) baRecordTypesMap = getRecordTypesMap('EMS_Budget_Allocation_gne__c');
        if (raRecordTypesMap == null) raRecordTypesMap = getRecordTypesMap('EMS_Roche_Attendee_gne__c');

        createGSDEventTypes();
        fetchTerritoryNames();
        createTerritoryGroups();
    }


	/**************************************************************************
	********************* USER WITH TERRITORIES *******************************
	**************************************************************************/

    public static void createTerritoryGroups() {
        Map<Id, Territory2> territoriesMap = new Map<Id, Territory2>([SELECT ID, Name from Territory2]);

        Map<Id, Territory_Group_Mapping_gne__c> terrGroupMappingMap = new Map<Id, Territory_Group_Mapping_gne__c>();
        for (Territory_Group_Mapping_gne__c mapping : [SELECT Group_Id_gne__c, Territory_Id_gne__c FROM Territory_Group_Mapping_gne__c WHERE Territory_Id_gne__c IN :territoriesMap.keySet()]) {
            terrGroupMappingMap.put(mapping.Territory_Id_gne__c, mapping);
        }

        Map<Id, Group> terrToGroup = new Map<Id, Group>();
        for (Id terrId : territoriesMap.keySet()) {
            if (!terrGroupMappingMap.containsKey(terrId)) {
                Group terrGroup = new Group(Name = territoriesMap.get(terrId).Id);
                terrToGroup.put(terrId, terrGroup);
            }
        }
        if (!terrToGroup.isEmpty()) {
            insert terrToGroup.values();
        }
        Map<Id, Territory_Group_Mapping_gne__c> newTerrGroupMappingMap = new Map<Id, Territory_Group_Mapping_gne__c>();
        for (Id terrId : terrToGroup.keySet()) {
            newTerrGroupMappingMap.put(terrId, new Territory_Group_Mapping_gne__c(Territory_Id_gne__c = terrId, Group_Id_gne__c = terrToGroup.get(terrId).Id));
        }
        insert newTerrGroupMappingMap.values();
    }

    public static List<Id> findExistingUser(String role, Id managerId) {

        Set<Id> usersWithTerritory = new Set<Id>();
        List<Id> userIds = new List<Id>();

        // Find users that have territories
        for (UserTerritory2Association ut : [SELECT UserId, Territory2Id FROM UserTerritory2Association WHERE IsActive = true]) {
            usersWithTerritory.add(ut.UserId);
        }

        if (role == 'PM') {
            Set<Id> pmUserIds = new Set<Id>();
            // select user based on permission set assignments
            for (List<PermissionSetAssignment> permSetAssignments : [SELECT Id, AssigneeId, PermissionSetId, SystemModstamp FROM PermissionSetAssignment WHERE PermissionSet.Name = 'EMS_Canada_PM' AND AssigneeId IN :usersWithTerritory]) {
                for (PermissionSetAssignment permSetAssignment : permSetAssignments) {
                    pmUserIds.add(permSetAssignment.AssigneeId);
                }
            }

            Map<Id, Territory2> topLevelTerritories = new Map<Id, Territory2>([SELECT Id, Name FROM Territory2 WHERE ParentTerritory2Id = null]);
            List<UserTerritory2Association> utList = [SELECT UserId, Territory2Id FROM UserTerritory2Association WHERE IsActive = true AND Territory2Id IN :topLevelTerritories.keySet() AND UserId IN (SELECT Id FROM User WHERE IsActive = true and Id IN :pmUserIds)];
            for (UserTerritory2Association ut : utList) {

                userIds.add(ut.UserId);

                if (userTerritoryMap.get(ut.UserId) == null) {
                    userTerritoryMap.put(ut.UserId, new Set<Id>());
                }
                userTerritoryMap.get(ut.UserId).add(ut.Territory2Id);
            }
        } else {
            String permissionSetName = 'EMS_Canada_' + role;

            Set<Id> roleUserIds = new Set<Id>();
            // select user based on permission set assignments
            for (List<PermissionSetAssignment> permSetAssignments : [SELECT Id, AssigneeId, PermissionSetId, SystemModstamp FROM PermissionSetAssignment WHERE PermissionSet.Name = :permissionSetName AND AssigneeId IN :usersWithTerritory]) {
                for (PermissionSetAssignment permSetAssignment : permSetAssignments) {
                    roleUserIds.add(permSetAssignment.AssigneeId);
                }
            }

            if (managerId != null) {
                // select manager territories
                Set<Id> mangerTerritoryIds = new Set<Id>();
                for (UserTerritory2Association ut : [SELECT UserId, Territory2Id FROM UserTerritory2Association WHERE IsActive = true AND UserId = :managerId]) {
                    mangerTerritoryIds.add(ut.Territory2Id);
                }

                Map<Id, Territory2> childTerritories = new Map<Id, Territory2>([SELECT Id, Name FROM Territory2 WHERE ParentTerritory2Id IN :mangerTerritoryIds]);
                List<UserTerritory2Association> utList = [SELECT UserId, Territory2Id FROM UserTerritory2Association WHERE IsActive = true AND Territory2Id IN :childTerritories.keySet() AND UserId IN (SELECT Id FROM User WHERE IsActive = true and Id IN :roleUserIds)];
                for (UserTerritory2Association ut : utList) {
                    userIds.add(ut.UserId);

                    if (userTerritoryMap.get(ut.UserId) == null) {
                        userTerritoryMap.put(ut.UserId, new Set<Id>());
                    }
                    userTerritoryMap.get(ut.UserId).add(ut.Territory2Id);
                }
            } else {
                for (UserTerritory2Association ut : [SELECT UserId, Territory2Id FROM UserTerritory2Association WHERE IsActive = true AND UserId IN :roleUserIds]) {
                    userIds.add(ut.UserId);

                    if (userTerritoryMap.get(ut.UserId) == null) {
                        userTerritoryMap.put(ut.UserId, new Set<Id>());
                    }
                    userTerritoryMap.get(ut.UserId).add(ut.Territory2Id);
                }
                userIds = new List<Id>(roleUserIds);
            }
        }

        if (userIds != null) {
            // create sales roster for the user
            createUserSalesRosters(userIds, role);
        }

        return userIds;
    }

    // As there is not possible to insert territory assigement we need to use existing ones
    public static List<Id> findExistingUser(String role, Id managerId, Set<Id> excludedUsers) {

        Set<Id> usersWithTerritory = new Set<Id>();
        List<Id> userIds = new List<Id>();

        // Find users that have territories
        for (UserTerritory2Association ut : [SELECT UserId, Territory2Id FROM UserTerritory2Association WHERE IsActive = true AND UserId NOT IN :excludedUsers]) {
            usersWithTerritory.add(ut.UserId);
        }

        if (role == 'PM') {
            Set<Id> pmUserIds = new Set<Id>();
            // select user based on permission set assignments
            for (List<PermissionSetAssignment> permSetAssignments : [SELECT Id, AssigneeId, PermissionSetId, SystemModstamp FROM PermissionSetAssignment WHERE PermissionSet.Name = 'EMS_Canada_PM' AND AssigneeId IN :usersWithTerritory]) {
                for (PermissionSetAssignment permSetAssignment : permSetAssignments) {
                    pmUserIds.add(permSetAssignment.AssigneeId);
                }
            }

            Map<Id, Territory2> topLevelTerritories = new Map<Id, Territory2>([SELECT Id, Name FROM Territory2 WHERE ParentTerritory2Id = null]);
            List<UserTerritory2Association> utList = [SELECT UserId, Territory2Id FROM UserTerritory2Association WHERE IsActive = true AND Territory2Id IN :topLevelTerritories.keySet() AND UserId IN (SELECT Id FROM User WHERE IsActive = true and Id IN :pmUserIds)];
            for (UserTerritory2Association ut : utList) {

                userIds.add(ut.UserId);

                if (userTerritoryMap.get(ut.UserId) == null) {
                    userTerritoryMap.put(ut.UserId, new Set<Id>());
                }
                userTerritoryMap.get(ut.UserId).add(ut.Territory2Id);
            }
        } else {
            String permissionSetName = 'EMS_Canada_' + role;

            Set<Id> roleUserIds = new Set<Id>();
            // select user based on permission set assignments
            for (List<PermissionSetAssignment> permSetAssignments : [SELECT Id, AssigneeId, PermissionSetId, SystemModstamp FROM PermissionSetAssignment WHERE PermissionSet.Name = :permissionSetName AND AssigneeId IN :usersWithTerritory]) {
                for (PermissionSetAssignment permSetAssignment : permSetAssignments) {
                    roleUserIds.add(permSetAssignment.AssigneeId);
                }
            }

            if (managerId != null) {
                // select manager territories
                Set<Id> mangerTerritoryIds = new Set<Id>();
                for (UserTerritory2Association ut : [SELECT UserId, Territory2Id FROM UserTerritory2Association WHERE IsActive = true AND UserId = :managerId]) {
                    mangerTerritoryIds.add(ut.Territory2Id);
                }

                Map<Id, Territory2> childTerritories = new Map<Id, Territory2>([SELECT Id, Name FROM Territory2 WHERE ParentTerritory2Id IN :mangerTerritoryIds]);
                List<UserTerritory2Association> utList = [SELECT UserId, Territory2Id FROM UserTerritory2Association WHERE IsActive = true AND Territory2Id IN :childTerritories.keySet() AND UserId IN (SELECT Id FROM User WHERE IsActive = true and Id IN :roleUserIds)];
                for (UserTerritory2Association ut : utList) {
                    userIds.add(ut.UserId);

                    if (userTerritoryMap.get(ut.UserId) == null) {
                        userTerritoryMap.put(ut.UserId, new Set<Id>());
                    }
                    userTerritoryMap.get(ut.UserId).add(ut.Territory2Id);
                }
            } else {
                for (UserTerritory2Association ut : [SELECT UserId, Territory2Id FROM UserTerritory2Association WHERE IsActive = true AND UserId IN :roleUserIds]) {
                    userIds.add(ut.UserId);

                    if (userTerritoryMap.get(ut.UserId) == null) {
                        userTerritoryMap.put(ut.UserId, new Set<Id>());
                    }
                    userTerritoryMap.get(ut.UserId).add(ut.Territory2Id);
                }
                userIds = new List<Id>(roleUserIds);
            }
        }

        if (userIds != null) {
            // create sales roster for the user
            createUserSalesRosters(userIds, role);
        }

        return userIds;
    }

    public static List<Id> findDependentUserUnderSpecificRole(String roleParent, String roleChild) {
        List<Id> userIds = new List<Id>();
        roleParent = 'EMS_Canada_' + roleParent;
        roleChild = 'EMS_Canada_' + roleChild;

        Set<Id> usersWithTerritory = new Set<Id>();
        for (UserTerritory2Association ut : [SELECT UserId FROM UserTerritory2Association WHERE IsActive = true]) {
            usersWithTerritory.add(ut.UserId);
        }

        Set<Id> pmUserIds = new Set<Id>();
        Set<Id> desiredUserIds = new Set<Id>();
        for (List<PermissionSetAssignment> permSetAssignments : [SELECT AssigneeId, PermissionSet.Name FROM PermissionSetAssignment WHERE (PermissionSet.Name = :roleParent OR PermissionSet.Name = :roleChild) AND AssigneeId IN :usersWithTerritory]) {
            for (PermissionSetAssignment permSetAssignment : permSetAssignments) {
                if (permSetAssignment.PermissionSet.Name == roleParent) {
                    pmUserIds.add(permSetAssignment.AssigneeId);
                }
                if (permSetAssignment.PermissionSet.Name == roleChild) {
                    desiredUserIds.add(permSetAssignment.AssigneeId);
                }
            }
        }

        Map<Id, Id> pmUserIdsTerritoryIdsMap = new Map<Id, Id>();
        List<UserTerritory2Association> pmUserTerritories = [SELECT UserId, Territory2Id FROM UserTerritory2Association WHERE IsActive = true AND UserId IN (SELECT Id FROM User WHERE IsActive = true and Id IN :pmUserIds)];

        for (UserTerritory2Association pmUt : pmUserTerritories) {
            pmUserIdsTerritoryIdsMap.put(pmUt.Territory2Id, pmUt.UserId);

            if (userTerritoryMap.get(pmUt.UserId) == null) {
                userTerritoryMap.put(pmUt.UserId, new Set<Id>());
            }
            userTerritoryMap.get(pmUt.UserId).add(pmUt.Territory2Id);
        }

        Map<Id, Territory2> childTerritories = new Map<Id, Territory2>([SELECT Id, Name, ParentTerritory2Id FROM Territory2 WHERE ParentTerritory2Id IN :pmUserIdsTerritoryIdsMap.keySet()]);
        List<UserTerritory2Association> desiredUserTerritories = [SELECT UserId, Territory2Id FROM UserTerritory2Association WHERE IsActive = true AND UserId IN (SELECT Id FROM User WHERE IsActive = true and Id IN :desiredUserIds) AND Territory2Id IN :childTerritories.keySet()];
        // Parent User
        userIds.add(pmUserIdsTerritoryIdsMap.get(childTerritories.get(desiredUserTerritories[0].Territory2Id).ParentTerritory2Id));
        // Child User
        userIds.add(desiredUserTerritories[0].UserId);
        for (UserTerritory2Association desiredUTt : desiredUserTerritories) {
            if (userTerritoryMap.get(desiredUTt.UserId) == null) {
                userTerritoryMap.put(desiredUTt.UserId, new Set<Id>());
            }
            userTerritoryMap.get(desiredUTt.UserId).add(desiredUTt.Territory2Id);
        }

        if (userIds.size() == 2) {
            // Saving some Limits.getQueries() here
            List<IC_Calc_Sales_Roster_gne__c> emsCanadaSalesRoster = [SELECT Id FROM IC_Calc_Sales_Roster_gne__c WHERE Type_gne__c = 'EMS-Canada'];
            IC_Calc_Sales_Roster_gne__c icCalc = (emsCanadaSalesRoster.size() > 0) ? emsCanadaSalesRoster[0] : createICcalculator();

            List<SFA2_User_Sales_Roster_gne__c> salesRosters = new List<SFA2_User_Sales_Roster_gne__c>();
            salesRosters.add(new SFA2_User_Sales_Roster_gne__c(
                    User_gne__c = userIds[0],
                    Is_Active_gne__c = true,
                    Role_gne__c = roleParent.split('EMS_Canada_')[1],
                    Sales_Roster_gne__c = icCalc.Id
            ));

            salesRosters.add(new SFA2_User_Sales_Roster_gne__c(
                    User_gne__c = userIds[1],
                    Is_Active_gne__c = true,
                    Role_gne__c = roleChild.split('EMS_Canada_')[1],
                    Sales_Roster_gne__c = icCalc.Id
            ));
            insert salesRosters;
        }

        return userIds;
    }


    public static List<Id> findDependentUserUnderSpecificRole(String roleTop, String roleMiddle, String roleBottom) {
        // PM, RSM, Rep
        roleTop = 'EMS_Canada_' + roleTop;
        roleMiddle = 'EMS_Canada_' + roleMiddle;
        roleBottom = 'EMS_Canada_' + roleBottom;

        // Users should be active and have active territories
        Set<Id> usersWithTerritory = new Set<Id>();
        for (UserTerritory2Association ut : [SELECT UserId FROM UserTerritory2Association WHERE IsActive = true AND UserId IN (SELECT Id FROM User WHERE IsActive = true)]) {
            usersWithTerritory.add(ut.UserId);
        }

        Set<Id> topUserIDs = new Set<Id>(),
                middleUserIDs = new Set<Id>(),
                bottomUserIDs = new Set<Id>(),
                commonUserIDs = new Set<Id>();

        for (List<PermissionSetAssignment> permSetAssignments : [SELECT AssigneeId, PermissionSet.Name FROM PermissionSetAssignment WHERE (PermissionSet.Name = :roleTop OR PermissionSet.Name = :roleMiddle OR PermissionSet.Name = :roleBottom) AND AssigneeId IN :usersWithTerritory]) {
            for (PermissionSetAssignment permSetAssignment : permSetAssignments) {
                if (permSetAssignment.PermissionSet.Name == roleTop) {
                    topUserIDs.add(permSetAssignment.AssigneeId);
                }
                if (permSetAssignment.PermissionSet.Name == roleMiddle) {
                    middleUserIDs.add(permSetAssignment.AssigneeId);
                }
                if (permSetAssignment.PermissionSet.Name == roleBottom) {
                    bottomUserIDs.add(permSetAssignment.AssigneeId);
                }
                commonUserIDs.add(permSetAssignment.AssigneeId);
            }
        }

        Map<Id, Id> territoriesToTopUserIDs = new Map<Id, Id>();
        Map<Id, Id> territoriesToMiddleUserIDs = new Map<Id, Id>();
        Map<Id, UserTerritory2Association> relatedUserTerritories = new Map<Id, UserTerritory2Association>([SELECT UserId, Territory2Id FROM UserTerritory2Association WHERE IsActive = true AND UserId IN (SELECT Id FROM User WHERE IsActive = true AND Id IN :commonUserIDs)]);
        for (UserTerritory2Association ut : relatedUserTerritories.values()) {
            if (userTerritoryMap.get(ut.UserId) == null) {
                userTerritoryMap.put(ut.UserId, new Set<Id>());
            }
            userTerritoryMap.get(ut.UserId).add(ut.Territory2Id);

            if (topUserIDs.contains(ut.UserId)) {
                territoriesToTopUserIDs.put(ut.Territory2Id, ut.UserId);
            }
            if (middleUserIDs.contains(ut.UserId)) {
                territoriesToMiddleUserIDs.put(ut.Territory2Id, ut.UserId);
            }
        }

        List<Id> topMiddleBottomUserIDs = new List<Id>();
        Map<Id, Territory2> middleBottomTerritories = new Map<Id, Territory2>([SELECT Name, ParentTerritory2Id FROM Territory2 WHERE ParentTerritory2Id IN :territoriesToTopUserIDs.keySet() OR ParentTerritory2Id IN :territoriesToMiddleUserIDs.keySet()]);
        for (UserTerritory2Association ut : relatedUserTerritories.values()) {
            // try to find bottom user territory
            Id uBottomID = ut.UserId;
            Id tBottomID = ut.Territory2Id;
            if (String.isBlank(uBottomID) || String.isBlank(tBottomID)) {
                // go to the next iteration if variable is blank
                continue;
            }

            // try to find middle territory which is related to bottom one
            if (middleBottomTerritories.containsKey(tBottomID) && territoriesToMiddleUserIDs.containsKey(middleBottomTerritories.get(tBottomID).ParentTerritory2Id)) {
                Id uMiddleID = territoriesToMiddleUserIDs.get(middleBottomTerritories.get(tBottomID).ParentTerritory2Id);
                Id tMiddleID = middleBottomTerritories.get(tBottomID).ParentTerritory2Id;
                if (String.isBlank(uMiddleID) || String.isBlank(tMiddleID)) {
                    // go to the next iteration if variable is blank
                    continue;
                }

                // try to find top territory which is related to middle one
                if (middleBottomTerritories.containsKey(tMiddleID) && territoriesToTopUserIDs.containsKey(middleBottomTerritories.get(tMiddleID).ParentTerritory2Id)) {
                    Id uTopID = territoriesToTopUserIDs.get(middleBottomTerritories.get(tMiddleID).ParentTerritory2Id);
                    if (String.isNotBlank(uTopID)) {
                        // Tree user IDs are found
                        topMiddleBottomUserIDs.add(uTopID);     // [0]
                        topMiddleBottomUserIDs.add(uMiddleID);  // [1]
                        topMiddleBottomUserIDs.add(uBottomID);  // [2]
                        break;
                    }
                }
            }
        }

        if (topMiddleBottomUserIDs.size() == 3) {
            List<IC_Calc_Sales_Roster_gne__c> emsCanadaSalesRoster = [SELECT Id FROM IC_Calc_Sales_Roster_gne__c WHERE Type_gne__c = 'EMS-Canada'];
            IC_Calc_Sales_Roster_gne__c icCalc = (emsCanadaSalesRoster.size() > 0) ? emsCanadaSalesRoster[0] : createICcalculator();

            List<SFA2_User_Sales_Roster_gne__c> salesRosters = new List<SFA2_User_Sales_Roster_gne__c>();
            salesRosters.add(new SFA2_User_Sales_Roster_gne__c(
                    User_gne__c = topMiddleBottomUserIDs[0],
                    Is_Active_gne__c = true,
                    Role_gne__c = roleTop.split('EMS_Canada_')[1],
                    Sales_Roster_gne__c = icCalc.Id
            ));

            salesRosters.add(new SFA2_User_Sales_Roster_gne__c(
                    User_gne__c = topMiddleBottomUserIDs[1],
                    Is_Active_gne__c = true,
                    Role_gne__c = roleMiddle.split('EMS_Canada_')[1],
                    Sales_Roster_gne__c = icCalc.Id
            ));

            salesRosters.add(new SFA2_User_Sales_Roster_gne__c(
                    User_gne__c = topMiddleBottomUserIDs[2],
                    Is_Active_gne__c = true,
                    Role_gne__c = roleBottom.split('EMS_Canada_')[1],
                    Sales_Roster_gne__c = icCalc.Id
            ));
            insert salesRosters;
        }

        return topMiddleBottomUserIDs;

        /*
        Map<Id,Territory2> middleTerritories = new Map<Id,Territory2>([SELECT Name, ParentTerritory2Id FROM Territory2 WHERE ParentTerritory2Id IN :territoriesToTopUserIDs.keySet()]);
        List<UserTerritory2Association> middleUserTerritories = [SELECT UserId, Territory2Id FROM UserTerritory2Association WHERE IsActive = true AND UserId IN (SELECT Id FROM User WHERE IsActive = true and Id IN :middleUserIDs) AND Territory2Id IN :middleTerritories.keySet()];
        hierarchyUserIDs.add(
            territoriesToTopUserIDs.get(middleTerritories.get(middleUserTerritories[0].Territory2Id).ParentTerritory2Id)
        );
        hierarchyUserIDs.add(middleUserTerritories[0].UserId);*/
    }

	/**************************************************************************
	********************** USER data generation *******************************
	**************************************************************************/

    public static User createEMSTestuser(String role) {
        User emsUser = createTestUser ('RCanada-EMS-Meeting', 'PMtestuser');
        SFA2_User_Sales_Roster_gne__c sr = getUserSalesRoster(emsUser, role);
        GNE_SFA2_User_App_Context_gne__c ac = getUserApplicationContext(emsUser, true, role, '', 'EMS-Canada');
        return emsUser;
    }

    public static User getSystemAdministratorUser() {
        return createTestUser(SYSTEM_ADMINISTRATOR_PROFILE_NAME, 'testuser');
    }

    public static User createEMSUser(String profileName) {
        return createTestUser (profileName, 'EMS_tester');
    }

    public static User createTestUser(String profileName, String userName) {
        for (Profile p : [SELECT Id FROM Profile WHERE Name LIKE :profileName LIMIT 1]) {
            userName = userName + String.valueOf(Math.random()).substring(0, 4) + '@gene.com';
            User user = new User(
                    Alias = 'testUser',
                    Email = userName,
                    EmailEncodingKey = 'UTF-8',
                    LastName = 'Testing',
                    LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_US',
                    ProfileId = p.Id,
                    TimeZoneSidKey = 'America/Los_Angeles',
                    UserName = userName);
            insert user;
            return user;
        }
        return null;
    }

    // User configuration objects
    public static IC_Calc_Sales_Roster_gne__c createICcalculator() {
        IC_Calc_Sales_Roster_gne__c ic = new IC_Calc_Sales_Roster_gne__c(
                Is_SFA2_Available_gne__c = true,
                Runs_in_SFA2_Mode_gne__c = true,
                Type_gne__c = 'EMS-Canada'
        );
        try {
            insert ic;
        } catch (System.DmlException e) {
            // If two or more thest methods are runned at teh same time
            //UNABLE_TO_LOCK_ROW, unable to obtain exclusive access to this record
            ic = [SELECT Is_SFA2_Available_gne__c, Runs_in_SFA2_Mode_gne__c, Type_gne__c FROM IC_Calc_Sales_Roster_gne__c WHERE Is_SFA2_Available_gne__c = true AND Runs_in_SFA2_Mode_gne__c = true AND Type_gne__c = 'EMS-Canada' LIMIT 1];
        }
        return ic;
    }

    public static List<SFA2_User_Sales_Roster_gne__c> createUserSalesRosters(List<Id> userIds, String role) {
        IC_Calc_Sales_Roster_gne__c icCalc;

        List<IC_Calc_Sales_Roster_gne__c> emsCanadaSalesRoster = [SELECT Id FROM IC_Calc_Sales_Roster_gne__c WHERE Type_gne__c = 'EMS-Canada'];
        if (emsCanadaSalesRoster.size() > 0) {
            icCalc = emsCanadaSalesRoster[0];
        } else {
            icCalc = createICcalculator();
        }

        List<SFA2_User_Sales_Roster_gne__c> salesRosters = new List<SFA2_User_Sales_Roster_gne__c>();
        for (Id userId : userIds) {
            salesRosters.add(new SFA2_User_Sales_Roster_gne__c(
                    User_gne__c = userId,
                    Is_Active_gne__c = true,
                    Role_gne__c = role, /* ('AARC','Admin','MP','MedOps','PM','RSM','Rep','MM','ML','FC') */
                    Sales_Roster_gne__c = icCalc.Id
            ));
        }
        insert salesRosters;
        return salesRosters;
    }

    // User configuration objects
    public static IC_Calc_Sales_Roster_gne__c getICcalculator() {
        IC_Calc_Sales_Roster_gne__c ic = new IC_Calc_Sales_Roster_gne__c(
                Is_SFA2_Available_gne__c = true,
                Runs_in_SFA2_Mode_gne__c = true,
                Type_gne__c = 'EMS-Canada'
        );
        insert ic;
        return ic;
    }

    public static SFA2_User_Sales_Roster_gne__c createUserSalesRoster(Id userId, String role) {
        SFA2_User_Sales_Roster_gne__c sr = new SFA2_User_Sales_Roster_gne__c(
                User_gne__c = userId,
                Is_Active_gne__c = true,
                Role_gne__c = role, /* ('AARC','Admin','MP','MedOps','PM','RSM','Rep','MM','ML','FC') */
                Sales_Roster_gne__c = getICcalculator().Id
        );

        insert sr;
        return sr;
    }

    public static SFA2_User_Sales_Roster_gne__c getUserSalesRoster(User testU, String role) {
        SFA2_User_Sales_Roster_gne__c sr = new SFA2_User_Sales_Roster_gne__c(
                User_gne__c = testU.Id,
                Is_Active_gne__c = true,
                Profile_Name_gne__c = testU.Profile.Name,
                Role_gne__c = role, /* ('AARC','Admin','MP','MedOps','PM','RSM','Rep','MM','ML','FC') */
                Sales_Roster_gne__c = getICcalculator().Id
        );

        return sr;
    }

    public static GNE_SFA2_User_App_Context_gne__c getUserApplicationContext(User testU, Boolean sfaMode, String role, String brand, String appType) {
        GNE_SFA2_User_App_Context_gne__c apCon = new GNE_SFA2_User_App_Context_gne__c();
        apCon.SetupOwnerId = testU.id;
        apCon.SFA2_Mode_gne__c = sfaMode;
        apCon.Role_gne__c = role;
        apCon.Brand_gne__c = brand;
        apCon.App_Name_gne__c = appType;
        insert apCon;
        return apCon;
    }

	/**************************************************************************
	********************* TERRITORY data generation ***************************
	**************************************************************************/

    public static void createTerritoryHierarchy(Integer howMany) {
        Integer i;
        for (i = 0; i <= howMany; i++) {
            // Master territory (for PB)
            Territory2 topTr = new Territory2(
                    Name = 'PBTerritory_' + i,
                    ParentTerritory2Id = null
            );
            insert topTr;

            // First child (for RB)
            Territory2 firstChildTr = new Territory2(
                    Name = 'RBTerritory_' + i,
                    ParentTerritory2Id = topTr.Id
            );
            insert firstChildTr;

            // Second child (for TB)
            Territory2 secondChildTr = new Territory2(
                    Name = 'TBTerritory_' + i,
                    ParentTerritory2Id = firstChildTr.Id
            );
            insert secondChildTr;
        }
    }

	/**************************************************************************
	****************** USER DELEGATIONS data generation ***********************
	**************************************************************************/

    private static final RecordType emsUserDelegationRT = [SELECT Id FROM RecordType WHERE SObjectType = 'GNE_User_Delegation__c' AND DeveloperName = 'EMS'];
    public static GNE_User_Delegation__c createUserDelegation(Id userId, Id delegatedUser, Date startDate, Date endDate, String comments) {
        GNE_User_Delegation__c userDelegation = new GNE_User_Delegation__c(
                Username__c = userId,
                Delegated_User__c = delegatedUser,
                Start_Date__c = startDate,
                End_Date__c = endDate,
                Comments__c = comments,
                RecordTypeId = emsUserDelegationRT.Id
        );
        insert userDelegation;
        return userDelegation;
    }

	/**************************************************************************
	********************* ACCOUNT data generation *****************************
	**************************************************************************/

    // Testdata Account
    public static Account createAccount(String recordTypeName) {
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = :recordTypeName limit 1];
        if (rt == null) {
            return createAccount();
        }
        return new Account(
                RecordTypeId = rt.Id,
                FirstName = 'firstName',
                LastName = 'Test Account ' + String.valueOf(DateTime.now())
        );
    }

    public static Account createAccount() {
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' limit 1];
        return new Account(
                recordTypeId = rt.Id,
                FirstName = 'firstName',
                LastName = 'SomeAccount'
        );
    }

    public static Account createAndInsertAccount(String recordTypeName) {
        Account accountData = createAccount(recordTypeName);
        insert accountData;
        return accountData;
    }

    public static Account createAndInsertAccount(String firstName, String lastName) {
        Account accountData = createAccount('HCP Canada');
        accountData.FirstName = firstName;
        accountData.LastName = lastName;

        insert accountData;
        return accountData;
    }

	/**************************************************************************
	********************* IHCP data generation *****************************
	**************************************************************************/
    public static EMS_International_Speaker_gne__c createIHCP(String firstName, String lastName) {
        return new EMS_International_Speaker_gne__c(
                Name = firstName + ' ' + lastName,
                First_Name_gne__c = 'firstName',
                Last_Name_gne__c = 'lastName',
                Is_Active_gne__c = true
        );
    }

    public static EMS_International_Speaker_gne__c createAndInsertIHCP(String firstName, String lastName) {
        EMS_International_Speaker_gne__c ihcp = createIHCP(firstName, lastName);

        insert ihcp;
        return ihcp;
    }

	/**************************************************************************
	********************** COST CENTER data generation ************************
	**************************************************************************/

    public static List<EMS_Cost_Center_gne__c> createCostCenters(String costCeterType, Integer howMany, boolean makeInsert) {
		/* Possible values: Medical Product, Commercial Product, Medical Department, Commercial Department, GM Budget/Corp Comm department budget */
        Map<String, String> allowedRoles = new Map<String, String>{
                'Commercial Product' => 'PM; RSM; Rep', 'Commercial Department' => 'PM; RSM; Rep',
                'Medical Product' => 'MM; ML', 'Medical Department' => 'MM; ML', 'GM Budget/Corp Comm department budget' => 'MM', 'Medical Phase IV' => 'MM; ML',
                'Corporate Relations' => 'MM'
        };

        EMS_Cost_Center_Type_gne__c cctype = new EMS_Cost_Center_Type_gne__c();
        cctype.Name = costCeterType;
        cctype.External_Id_gne__c = costCeterType;
        cctype.Allowed_Owners_gne__c = allowedRoles.get(costCeterType);
        insert cctype;

        List<EMS_Cost_Center_gne__c> ccToInsert = new List<EMS_Cost_Center_gne__c>();

        Integer i;
        for (i = 0; i < howmany; i++) {
            EMS_Cost_Center_gne__c cc = new EMS_Cost_Center_gne__c(
                    Name = 'CostCenter-' + i,
                    //OwnerId = null,
                    Cost_Center_External_ID_gne__c = '8' + i + String.valueOf(Math.random()).substring(0, 4),
                    Cost_Center_Type_gne__c = cctype.Id,
                    Is_Active_gne__c = true,
                    Product_Indication_Department_gne__c = 'ProductIndication' + i
            );
            ccToInsert.add(cc);
        }

        if (makeInsert) insert ccToInsert;
        return ccToInsert;
    }

	/**************************************************************************
	******************** PRODUCT BUDGET data generation ***********************
	**************************************************************************/
	/* childBudgetsAllocatedAmount = 0 for new budgets */

    public static EMS_Budget_Product_gne__c prepareProductBudget(Decimal childBudgetsAllocatedAmount, Decimal totalFundsApproved, User assignedTo, Id costCenterId) {
        return prepareProductBudget(childBudgetsAllocatedAmount, totalFundsApproved, null, null, null, assignedTo.Id, costCenterId);
    }

    public static EMS_Budget_Product_gne__c prepareProductBudget(Decimal childBudgetsAllocatedAmount, Decimal totalFundsApproved, Date startDate, Date endDate, String year, Id assignedToId, Id costCenterId) {
		/* Unique Name_gne__c is autogenerated form: 'PB' + Year_gne__c + Cost_Center_External_ID_gne__c + Product_Indication_gne__c + Assigned_To_Territory_gne__c */
        String recordType = 'EMS Canada Product Budget';
        EMS_Budget_Product_gne__c budgetProduct = new EMS_Budget_Product_gne__c(
                Status_gne__c = 'Active',
                RecordTypeId = pbRecordTypesMap.get(recordType),
                Start_Date_gne__c = startDate != null ? startDate : getStartDate(),
                End_Date_gne__c = endDate != null ? endDate : getStartDate() + 15,
                Assigned_To_gne__c = assignedToId,
                Assigned_To_Territory_gne__c = territoryNames.get(new List<Id>(userTerritoryMap.get(assignedToId))[0]),
                Child_Budgets_Allocated_Amount_gne__c = childBudgetsAllocatedAmount,
                Total_Product_Funds_Approved_gne__c = totalFundsApproved,
                Cost_Center_gne__c = costCenterId,
                Year_gne__c = year != null ? year : CURRENT_YEAR
        );
        return budgetProduct;
    }

    public static EMS_Budget_Product_gne__c createProductBudget(Decimal childBudgetsAllocatedAmount, Decimal totalFundsApproved, User assignedTo, Id costCenterId) {
        EMS_Budget_Product_gne__c budgetProduct = prepareProductBudget(childBudgetsAllocatedAmount, totalFundsApproved, null, null, null, assignedTo.Id, costCenterId);
        insert budgetProduct;
        return budgetProduct;
    }

    public static EMS_Budget_Product_gne__c createProductBudget(Decimal childBudgetsAllocatedAmount, Decimal totalFundsApproved, Id assignedToId, Id costCenterId) {
        EMS_Budget_Product_gne__c budgetProduct = prepareProductBudget(childBudgetsAllocatedAmount, totalFundsApproved, null, null, null, assignedToId, costCenterId);
        insert budgetProduct;
        return budgetProduct;
    }

    public static EMS_Budget_Product_gne__c createProductBudget(Decimal childBudgetsAllocatedAmount, Decimal totalFundsApproved, Date startDate, Date endDate, String year, Id assignedToId, Id costCenterId) {
        EMS_Budget_Product_gne__c budgetProduct = prepareProductBudget(childBudgetsAllocatedAmount, totalFundsApproved, startDate, endDate, year, assignedToId, costCenterId);
        insert budgetProduct;
        return budgetProduct;
    }

    public static List<EMS_Budget_Product_gne__c> createProductBudget(Decimal childBudgetsAllocatedAmount, Decimal totalFundsApproved, Date startDate, Date endDate, String year, Id assignedToId, List<EMS_Cost_Center_gne__c> costCenters) {
        List<EMS_Budget_Product_gne__c> budgetProducts = new List<EMS_Budget_Product_gne__c>();
        for (Integer i = 0; i < costCenters.size(); i++) {
            budgetProducts.add(prepareProductBudget(childBudgetsAllocatedAmount, totalFundsApproved, startDate, endDate, year, assignedToId, costCenters.get(i).Id));
        }
        insert budgetProducts;
        return budgetProducts;
    }



    /**
    createMultipleProductBudgets
    */

    public static List<EMS_Budget_Product_gne__c> createMultipleProductBudgets(Decimal childBudgetsAllocatedAmount, Decimal totalFundsApproved, User assignedTo, String costCenterType, Integer howMany) {
        return createMultipleProductBudgets(
                childBudgetsAllocatedAmount,
                totalFundsApproved,
                assignedTo.Id,
                costCenterType,
                howMany
        );
    }

    public static List<EMS_Budget_Product_gne__c> createMultipleProductBudgets(Decimal childBudgetsAllocatedAmount, Decimal totalFundsApproved, Id assignedToId, String costCenterType, Integer howMany) {
        List<EMS_Budget_Product_gne__c> recordsList = new List<EMS_Budget_Product_gne__c>();
        List<EMS_Cost_Center_gne__c> ccList = createCostCenters(costCenterType, howMany, true);

        for (Integer i = 0; i < howMany; i++) {
            recordsList.add(prepareProductBudget(
                    childBudgetsAllocatedAmount,
                    totalFundsApproved,
                    null,
                    null,
                    null,
                    assignedToId,
                    ccList.get(i).Id
            ));
        }
        insert recordsList;
        return recordsList;
    }

    public static List<EMS_Budget_Product_gne__c> createMultipleProductBudgets(Decimal childBudgetsAllocatedAmount, Decimal totalFundsApproved, Id assignedToId, List<EMS_Cost_Center_gne__c> ccList) {
        List<EMS_Budget_Product_gne__c> recordsList = new List<EMS_Budget_Product_gne__c>();
        for (EMS_Cost_Center_gne__c cc: ccList) {
            recordsList.add(prepareProductBudget(
                    childBudgetsAllocatedAmount,
                    totalFundsApproved,
                    null,
                    null,
                    null,
                    assignedToId,
                    cc.Id
            ));
        }
        insert recordsList;
        return recordsList;
    }

    public static List<EMS_Budget_Product_gne__c> createMultipleProductBudgets(Decimal childBudgetsAllocatedAmount, Decimal totalFundsApproved, Id assignedToId, String costCenterType, Integer howMany, Boolean doInsert) {
        List<EMS_Budget_Product_gne__c> recordsList = new List<EMS_Budget_Product_gne__c>();
        List<EMS_Cost_Center_gne__c> ccList = createCostCenters(costCenterType, howMany, true);

        for (Integer i = 0; i < howMany; i++) {
            recordsList.add(prepareProductBudget(childBudgetsAllocatedAmount, totalFundsApproved, null, null, null, assignedToId, ccList.get(i).Id));
        }
        if (doInsert) {
            insert recordsList;
        }
        return recordsList;
    }

    public static List<EMS_Budget_Product_gne__c> createMultipleProductBudgets(Decimal childBudgetsAllocatedAmount, Decimal totalFundsApproved, Id assignedToId, String costCenterType, Date startDate, Date endDate, Integer howMany) {
        List<EMS_Budget_Product_gne__c> recordsList = new List<EMS_Budget_Product_gne__c>();
        List<EMS_Cost_Center_gne__c> ccList = createCostCenters(costCenterType, howMany, true);

        for (Integer i = 0; i < howMany; i++) {
            EMS_Budget_Product_gne__c pb = prepareProductBudget(childBudgetsAllocatedAmount, totalFundsApproved, null, null, null, assignedToId, ccList.get(i).Id);
            pb.Start_Date_gne__c = startDate;
            pb.End_Date_gne__c = endDate;
            recordsList.add(pb);
        }
        insert recordsList;
        return recordsList;
    }

    public static List<EMS_Budget_Product_gne__c> createMultipleProductBudgets(Decimal childBudgetsAllocatedAmount, Decimal totalFundsApproved, Id assignedToId, String costCenterType, Date startDate, Date endDate, String year, Integer howMany) {
        List<EMS_Budget_Product_gne__c> recordsList = new List<EMS_Budget_Product_gne__c>();
        List<EMS_Cost_Center_gne__c> ccList = createCostCenters(costCenterType, howMany, true);

        for (Integer i = 0; i < howMany; i++) {
            EMS_Budget_Product_gne__c pb = prepareProductBudget(childBudgetsAllocatedAmount, totalFundsApproved, null, null, null, assignedToId, ccList.get(i).Id);
            pb.Start_Date_gne__c = startDate;
            pb.End_Date_gne__c = endDate;
            pb.Year_gne__c = year;
            recordsList.add(pb);
        }
        insert recordsList;
        return recordsList;
    }


    /**************************************************************************
    ******************** REGION BUDGET data generation ***********************
    **************************************************************************/
	/* regionAllocatedAmount = 0 for new budgets */

    public static EMS_Budget_Region_gne__c prepareRegionBudget(Id productBudgetId, Decimal regionAllocatedAmount, Decimal totalFundsApproved, User assignedTo) {
        return prepareRegionBudget(productBudgetId, regionAllocatedAmount, totalFundsApproved, null, null, null, assignedTo.Id);
    }

    public static EMS_Budget_Region_gne__c prepareRegionBudget(Id productBudgetId, Decimal regionAllocatedAmount, Decimal totalFundsApproved, Date startDate, Date endDate, String year, Id assignedToId) {
		/* Unique Name_gne__c is autogenerated form: 'RB' + Year_gne__c + Cost_Center_External_ID_gne__c + Product_Indication_gne__c + Assigned_To_Territory_gne__c */
        String recordType = 'EMS Canada Region Budget';
        String territoryId = (assignedToId != null && userTerritoryMap.get(assignedToId) != null) ? territoryNames.get(new List<Id>(userTerritoryMap.get(assignedToId))[0]) : null;

        EMS_Budget_Region_gne__c regionBudget = new EMS_Budget_Region_gne__c(
                Status_gne__c = 'Active',
                RecordTypeId = rbRecordTypesMap.get(recordType),
                Start_Date_gne__c = startDate != null ? startDate : getStartDate(),
                End_Date_gne__c = endDate != null ? endDate : getStartDate() + 10,
                Assigned_To_gne__c = assignedToId,
                Assigned_To_Territory_gne__c = territoryId,
                Child_Budgets_Allocated_Amount_gne__c = regionAllocatedAmount,
                Total_Region_Funds_Approved_gne__c = totalFundsApproved,
                EMS_Budget_Product_gne__c = productBudgetId,
                Year_gne__c = year != null ? year : CURRENT_YEAR
        );

        return regionBudget;
    }

    public static EMS_Budget_Region_gne__c createRegionBudget(Id productBudgetId, Decimal regionAllocatedAmount, Decimal totalFundsApproved, User assignedTo) {
        EMS_Budget_Region_gne__c regionBudget = prepareRegionBudget(productBudgetId, regionAllocatedAmount, totalFundsApproved, null, null, null, assignedTo.Id);
        insert regionBudget;
        return regionBudget;
    }

    public static EMS_Budget_Region_gne__c createRegionBudget(Id productBudgetId, Decimal regionAllocatedAmount, Decimal totalFundsApproved, Id assignedToId) {
        EMS_Budget_Region_gne__c regionBudget = prepareRegionBudget(productBudgetId, regionAllocatedAmount, totalFundsApproved, null, null, null, assignedToId);
        insert regionBudget;
        return regionBudget;
    }

    public static EMS_Budget_Region_gne__c createRegionBudget(Id productBudgetId, Decimal regionAllocatedAmount, Decimal totalFundsApproved, Date startDate, Date endDate, String year, Id assignedToId) {
        EMS_Budget_Region_gne__c regionBudget = prepareRegionBudget(productBudgetId, regionAllocatedAmount, totalFundsApproved, startDate, endDate, year, assignedToId);
        insert regionBudget;
        return regionBudget;
    }

    public static List<EMS_Budget_Region_gne__c> createSomeRegionBudgets(Id productBudgetId, Decimal regionAllocatedAmount, Decimal totalFundsApproved, User assignedTo, Integer howMany) {
        List<EMS_Budget_Region_gne__c> regionBudgets = new List<EMS_Budget_Region_gne__c>();
        for (Integer i = 0; i < howMany; i++) {
            regionBudgets.add(prepareRegionBudget(productBudgetId, regionAllocatedAmount, totalFundsApproved, null, null, null, assignedTo.Id));
        }

        insert regionBudgets;
        return regionBudgets;
    }

    public static List<EMS_Budget_Region_gne__c> createSomeRegionBudgets(List<EMS_Budget_Product_gne__c> budgetProducts, Decimal regionAllocatedAmount, Decimal totalFundsApproved, Date startDate, Date endDate, String year, Id assignedTo) {
        List<EMS_Budget_Region_gne__c> regionBudgets = new List<EMS_Budget_Region_gne__c>();
        for (Integer i = 0; i < budgetProducts.size(); i++) {
            regionBudgets.add(prepareRegionBudget(budgetProducts.get(i).Id, regionAllocatedAmount, totalFundsApproved, startDate, endDate, year, assignedTo));
        }

        insert regionBudgets;
        return regionBudgets;
    }

    public static List<EMS_Budget_Region_gne__c> createRegionBudgetForEachPB(Integer budgetsCount, List<EMS_Budget_Product_gne__c> productBudgetsList, Decimal regionAllocatedAmount, Decimal totalFundsApproved, Id assignedToId) {
        List<EMS_Budget_Region_gne__c> regionBudgets = new List<EMS_Budget_Region_gne__c>();
        for (EMS_Budget_Product_gne__c pb : productBudgetsList) {
            for (Integer i = 0; i < budgetsCount; i++) {
                regionBudgets.add(prepareRegionBudget (pb.Id, regionAllocatedAmount, totalFundsApproved, null, null, null, assignedToId));
            }
        }

        insert regionBudgets;
        return regionBudgets;
    }

    public static EMS_Budget_Region_gne__c createRegionBudget(EMS_Budget_Product_gne__c productBudget, Decimal regionAmount, Decimal totalFundsApproved, User assignedTo) {
        return createOneRegionBudgetForEachPB(new List<EMS_Budget_Product_gne__c>{
                productBudget
        }, regionAmount, totalFundsApproved, assignedTo.Id)[0];
    }

    public static List<EMS_Budget_Region_gne__c> createOneRegionBudgetForEachPB(List<EMS_Budget_Product_gne__c> productBudgetsList, Decimal regionAllocatedAmount, Decimal totalFundsApproved, User assignedTo) {
        return createOneRegionBudgetForEachPB (productBudgetsList, regionAllocatedAmount, totalFundsApproved, assignedTo.Id);
    }

    public static List<EMS_Budget_Region_gne__c> createOneRegionBudgetForEachPB(List<EMS_Budget_Product_gne__c> productBudgetsList, Decimal regionAllocatedAmount, Decimal totalFundsApproved, Id assignedToId) {
        List<EMS_Budget_Region_gne__c> regionBudgets = new List<EMS_Budget_Region_gne__c>();
        for (EMS_Budget_Product_gne__c pb : productBudgetsList) {
            regionBudgets.add(prepareRegionBudget (pb.Id, regionAllocatedAmount, totalFundsApproved, null, null, null, assignedToId));
        }

        insert regionBudgets;
        return regionBudgets;
    }

    public static List<EMS_Budget_Region_gne__c> createOneRegionBudgetForEachPB_WOInsert(List<EMS_Budget_Product_gne__c> productBudgetsList, Decimal regionAllocatedAmount, Decimal totalFundsApproved, Id assignedToId) {
        List<EMS_Budget_Region_gne__c> regionBudgets = new List<EMS_Budget_Region_gne__c>();
        for (EMS_Budget_Product_gne__c pb : productBudgetsList) {
            regionBudgets.add(prepareRegionBudget (pb.Id, regionAllocatedAmount, totalFundsApproved, null, null, null, assignedToId));
        }

        return regionBudgets;
    }

    public static List<EMS_Budget_Region_gne__c> createOneRegionBudgetForEachPB(List<EMS_Budget_Product_gne__c> productBudgetsList, Decimal regionAllocatedAmount, Decimal totalFundsApproved, Id assignedToId, Date startDate, Date endDate) {
        List<EMS_Budget_Region_gne__c> regionBudgets = new List<EMS_Budget_Region_gne__c>();
        for (EMS_Budget_Product_gne__c pb : productBudgetsList) {
            EMS_Budget_Region_gne__c rb = prepareRegionBudget (pb.Id, regionAllocatedAmount, totalFundsApproved, null, null, null, assignedToId);
            rb.Start_Date_gne__c = startDate;
            rb.End_Date_gne__c = endDate;
            regionBudgets.add(rb);
        }

        insert regionBudgets;
        return regionBudgets;
    }

    public static List<EMS_Budget_Region_gne__c> createOneRegionBudgetForEachPB(List<EMS_Budget_Product_gne__c> productBudgetsList, Decimal regionAllocatedAmount, Decimal totalFundsApproved, Id assignedToId, Date startDate, Date endDate, String year) {
        List<EMS_Budget_Region_gne__c> regionBudgets = new List<EMS_Budget_Region_gne__c>();
        for (EMS_Budget_Product_gne__c pb : productBudgetsList) {
            EMS_Budget_Region_gne__c rb = prepareRegionBudget (pb.Id, regionAllocatedAmount, totalFundsApproved, null, null, null, assignedToId);
            rb.Start_Date_gne__c = startDate;
            rb.End_Date_gne__c = endDate;
            rb.Year_gne__c = year;
            regionBudgets.add(rb);
        }

        insert regionBudgets;
        return regionBudgets;

    }

	/**************************************************************************
	******************* TERRITORY BUDGET data generation **********************
	**************************************************************************/
	/* territoryAllocatedAmount = 0 for new budgets */

    public static EMS_Budget_Territory_gne__c prepareTerritoryBudget(Id regionBudgetId, Decimal territoryAllocatedAmount, Decimal totalFundsApproved, User assignedTo) {
        return prepareTerritoryBudget(regionBudgetId, territoryAllocatedAmount, totalFundsApproved, null, null, null, assignedTo.Id);
    }

    public static EMS_Budget_Territory_gne__c prepareTerritoryBudget(Id regionBudgetId, Decimal territoryAllocatedAmount, Decimal totalFundsApproved, Date startDate, Date endDate, String year, Id assignedToId) {
		/* Unique Name_gne__c is autogenerated form: 'TB' + Year_gne__c + Cost_Center_External_ID_gne__c + Product_Indication_gne__c + Assigned_To_Territory_gne__c */
        String recordType = 'EMS Canada Territory Budget';
        EMS_Budget_Territory_gne__c territoryBudget = new EMS_Budget_Territory_gne__c(
                Status_gne__c = 'Active',
                RecordTypeId = tbRecordTypesMap.get(recordType),
                Start_Date_gne__c = startDate != null ? startDate : getStartDate(),
                End_Date_gne__c = endDate != null ? endDate : getStartDate() + 5,
                Assigned_To_gne__c = assignedToId,
                Assigned_To_Territory_gne__c = territoryNames.get(new List<Id>(userTerritoryMap.get(assignedToId))[0]),
                Events_Allocated_Amount_gne__c = territoryAllocatedAmount,
                Total_Territory_Funds_Approved_gne__c = totalFundsApproved,
                EMS_Budget_Region_gne__c = regionBudgetId,
                Year_gne__c = year != null ? year : CURRENT_YEAR
        );

        return territoryBudget;
    }

    public static EMS_Budget_Territory_gne__c createTerritoryBudget(Id regionBudgetId, Decimal territoryAllocatedAmount, Decimal totalFundsApproved, User assignedTo) {
        EMS_Budget_Territory_gne__c territoryBudget = prepareTerritoryBudget (regionBudgetId, territoryAllocatedAmount, totalFundsApproved, null, null, null, assignedTo.Id);

        insert territoryBudget;
        return territoryBudget;
    }

    public static EMS_Budget_Territory_gne__c createTerritoryBudget(Id regionBudgetId, Decimal territoryAllocatedAmount, Decimal totalFundsApproved, Id assignedToId) {
        EMS_Budget_Territory_gne__c territoryBudget = prepareTerritoryBudget (regionBudgetId, territoryAllocatedAmount, totalFundsApproved, null, null, null, assignedToId);

        insert territoryBudget;
        return territoryBudget;
    }

    public static List<EMS_Budget_Territory_gne__c> createSomeTerritoryBudgets(Id regionBudgetId, Decimal territoryAllocatedAmount, Decimal totalFundsApproved, User assignedTo, Integer howMany) {
        List<EMS_Budget_Territory_gne__c> regionTerritory = new List<EMS_Budget_Territory_gne__c>();
        for (Integer i = 0; i < howMany; i++) {
            regionTerritory.add(prepareTerritoryBudget (regionBudgetId, territoryAllocatedAmount, totalFundsApproved, null, null, null, assignedTo.Id));
        }

        insert regionTerritory;
        return regionTerritory;
    }

    public static List<EMS_Budget_Territory_gne__c> createSomeTerritoryBudgets(Id regionBudgetId, Decimal territoryAllocatedAmount, Decimal totalFundsApproved, Id assignedToId, Integer howMany) {
        List<EMS_Budget_Territory_gne__c> regionTerritory = new List<EMS_Budget_Territory_gne__c>();
        for (Integer i = 0; i < howMany; i++) {
            regionTerritory.add(prepareTerritoryBudget (regionBudgetId, territoryAllocatedAmount, totalFundsApproved, null, null, null, assignedToId));
        }

        insert regionTerritory;
        return regionTerritory;
    }

    public static List<EMS_Budget_Territory_gne__c> createSomeTerritoryBudgets(Id regionBudgetId, Decimal territoryAllocatedAmount, Decimal totalFundsApproved, Date startDate, Date endDate, String year, Id assignedToId, Integer howMany) {
        List<EMS_Budget_Territory_gne__c> regionTerritory = new List<EMS_Budget_Territory_gne__c>();
        for (Integer i = 0; i < howMany; i++) {
            regionTerritory.add(prepareTerritoryBudget (regionBudgetId, territoryAllocatedAmount, totalFundsApproved, startDate, endDate, year, assignedToId));
        }

        insert regionTerritory;
        return regionTerritory;
    }

    public static List<EMS_Budget_Territory_gne__c> createSomeTerritoryBudgets(List<EMS_Budget_Region_gne__c> regionBudgets, Decimal territoryAllocatedAmount, Decimal totalFundsApproved, Date startDate, Date endDate, String year, Id assignedToId) {
        List<EMS_Budget_Territory_gne__c> regionTerritory = new List<EMS_Budget_Territory_gne__c>();
        for (Integer i = 0; i < regionBudgets.size(); i++) {
            EMS_Budget_Territory_gne__c tbItem = prepareTerritoryBudget(regionBudgets.get(i).Id, territoryAllocatedAmount, totalFundsApproved, startDate, endDate, year, assignedToId);
            regionTerritory.add(tbItem);
        }

        insert regionTerritory;
        return regionTerritory;
    }

    public static EMS_Budget_Territory_gne__c createTerritoryBudget(EMS_Budget_Region_gne__c regionBudget, Decimal territoryAmount, Decimal totalFundsApproved, User assignedTo) {
        return createOneTerritoryBudgetForEachRB(new List<EMS_Budget_Region_gne__c>{
                regionBudget
        }, territoryAmount, totalFundsApproved, assignedTo.Id)[0];
    }

    public static List<EMS_Budget_Territory_gne__c> createOneTerritoryBudgetForEachRB(List<EMS_Budget_Region_gne__c> regionBudgetsList, Decimal territoryAllocatedAmount, Decimal totalFundsApproved, User assignedTo) {
        return createOneTerritoryBudgetForEachRB (regionBudgetsList, territoryAllocatedAmount, totalFundsApproved, assignedTo.Id);
    }

    public static List<EMS_Budget_Territory_gne__c> createOneTerritoryBudgetForEachRB(List<EMS_Budget_Region_gne__c> regionBudgetsList, Decimal territoryAllocatedAmount, Decimal totalFundsApproved, Id assignedToId) {
        List<EMS_Budget_Territory_gne__c> territoryBudgets = new List<EMS_Budget_Territory_gne__c>();
        for (EMS_Budget_Region_gne__c rb : regionBudgetsList) {
            territoryBudgets.add(prepareTerritoryBudget (rb.Id, territoryAllocatedAmount, totalFundsApproved, null, null, null, assignedToId));
        }

        insert territoryBudgets;
        return territoryBudgets;
    }

    public static List<EMS_Budget_Territory_gne__c> createTerritoryBudgetForEachRB(Integer budgetsCount, List<EMS_Budget_Region_gne__c> regionBudgetsList, Decimal territoryAllocatedAmount, Decimal totalFundsApproved, Id assignedToId) {
        List<EMS_Budget_Territory_gne__c> territoryBudgets = new List<EMS_Budget_Territory_gne__c>();
        for (EMS_Budget_Region_gne__c rb : regionBudgetsList) {
            for (Integer i = 0; i < budgetsCount; i++) {
                territoryBudgets.add(prepareTerritoryBudget (rb.Id, territoryAllocatedAmount, totalFundsApproved, null, null, null, assignedToId));
            }
        }

        insert territoryBudgets;
        return territoryBudgets;
    }

    public static List<EMS_Budget_Territory_gne__c> createOneTerritoryBudgetForEachRB(List<EMS_Budget_Region_gne__c> regionBudgetsList, Decimal territoryAllocatedAmount, Decimal totalFundsApproved, Id assignedToId, Date startDate, Date endDate) {
        List<EMS_Budget_Territory_gne__c> territoryBudgets = new List<EMS_Budget_Territory_gne__c>();
        for (EMS_Budget_Region_gne__c rb : regionBudgetsList) {
            EMS_Budget_Territory_gne__c tb = prepareTerritoryBudget (rb.Id, territoryAllocatedAmount, totalFundsApproved, null, null, null, assignedToId);
            tb.Start_Date_gne__c = startDate;
            tb.End_Date_gne__c = endDate;
            territoryBudgets.add(tb);
        }

        insert territoryBudgets;
        return territoryBudgets;
    }

    public static List<EMS_Budget_Territory_gne__c> createOneTerritoryBudgetForEachRB(List<EMS_Budget_Region_gne__c> regionBudgetsList, Decimal territoryAllocatedAmount, Decimal totalFundsApproved, Id assignedToId, Date startDate, Date endDate, String year) {
        List<EMS_Budget_Territory_gne__c> territoryBudgets = new List<EMS_Budget_Territory_gne__c>();
        for (EMS_Budget_Region_gne__c rb : regionBudgetsList) {
            EMS_Budget_Territory_gne__c tb = prepareTerritoryBudget (rb.Id, territoryAllocatedAmount, totalFundsApproved, null, null, null, assignedToId);
            tb.Start_Date_gne__c = startDate;
            tb.End_Date_gne__c = endDate;
            tb.Year_gne__c = year;
            territoryBudgets.add(tb);
        }

        insert territoryBudgets;
        return territoryBudgets;

    }

    /**************************************************************************
    ****************** BUDGET ALLOCATION data generation **********************
    **************************************************************************/

    public static EMS_Budget_Allocation_gne__c createBudgetAllocation(String recordTypeName, Decimal allocatedAmount, Id budgetOwnerId, Id eventId, Id productBudgetId, Id regionBudgetId, Id territoryBudgetId) {
        return createBudgetAllocation(baRecordTypesMap.get(recordTypeName), allocatedAmount, budgetOwnerId, eventId, productBudgetId, regionBudgetId, territoryBudgetId);
    }

    public static EMS_Budget_Allocation_gne__c createBudgetAllocation(Id recordTypeId, Decimal allocatedAmount, Id budgetOwnerId, Id eventId, Id productBudgetId, Id regionBudgetId, Id territoryBudgetId) {
        EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                Allocated_Budget_gne__c = allocatedAmount,
                Budget_Deductions_gne__c = 0,
                //Percentage_Contribution_gne__c = allocatedAmount / event.Planned_Expenses_gne__c,
                Budget_Owner_gne__c = budgetOwnerId,
                EMS_Event_gne__c = eventId,
                RecordTypeId = recordTypeId,
                EMS_Product_Budget_gne__c = productBudgetId,
                EMS_Region_Budget_gne__c = regionBudgetId,
                EMS_Territory_Budget_gne__c = territoryBudgetId
        );
        insert budgetAllocation;
        return budgetAllocation;
    }

    public static List<EMS_Budget_Allocation_gne__c> createBudgetAllocation(String recordTypeName, Decimal allocatedAmount, Id budgetOwnerId, List<EMS_Event__c> events, Id productBudgetId, Id regionBudgetId, Id territoryBudgetId) {
        List<EMS_Budget_Allocation_gne__c> budgetAllocations = prepareBudgetAllocations(baRecordTypesMap.get(recordTypeName), allocatedAmount, budgetOwnerId, events, productBudgetId, regionBudgetId, territoryBudgetId);
        insert budgetAllocations;
        return budgetAllocations;
    }

    public static List<EMS_Budget_Allocation_gne__c> createBudgetAllocations(Id recordTypeId, Decimal allocatedAmount, Id budgetOwnerId, List<EMS_Event__c> events, Id productBudgetId, Id regionBudgetId, Id territoryBudgetId) {
        List<EMS_Budget_Allocation_gne__c> budgetAllocations = prepareBudgetAllocations(recordTypeId, allocatedAmount, budgetOwnerId, events, productBudgetId, regionBudgetId, territoryBudgetId);
        insert budgetAllocations;
        return budgetAllocations;
    }

    public static List<EMS_Budget_Allocation_gne__c> prepareBudgetAllocations(Id recordTypeId, Decimal allocatedAmount, Id budgetOwnerId, List<EMS_Event__c> events, Id productBudgetId, Id regionBudgetId, Id territoryBudgetId) {
        List<EMS_Budget_Allocation_gne__c> budgetAllocations = new List<EMS_Budget_Allocation_gne__c>();
        for (EMS_Event__c event : events) {
            EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                    Allocated_Budget_gne__c = allocatedAmount,
                    Budget_Deductions_gne__c = 0,
                    Percentage_Contribution_gne__c = allocatedAmount / event.Planned_Expenses_gne__c,
                    Budget_Owner_gne__c = budgetOwnerId,
                    EMS_Event_gne__c = event.Id,
                    RecordTypeId = recordTypeId,
                    EMS_Product_Budget_gne__c = productBudgetId,
                    EMS_Region_Budget_gne__c = regionBudgetId,
                    EMS_Territory_Budget_gne__c = territoryBudgetId
            );
            budgetAllocations.add(budgetAllocation);
        }
        return budgetAllocations;
    }

    public static List<EMS_Budget_Allocation_gne__c> createBudgetAllocations(Id recordTypeId, Decimal allocatedAmount, Id budgetOwnerId, List<EMS_Event__c> events, List<EMS_Budget_Product_gne__c> productBudgets) {
        List<EMS_Budget_Allocation_gne__c> budgetAllocations = new List<EMS_Budget_Allocation_gne__c>();
        for (EMS_Budget_Product_gne__c pb : productBudgets) {
            for (EMS_Event__c event : events) {
                EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                        Allocated_Budget_gne__c = allocatedAmount,
                        Budget_Deductions_gne__c = 0,
                        Percentage_Contribution_gne__c = allocatedAmount / event.Planned_Expenses_gne__c,
                        Budget_Owner_gne__c = budgetOwnerId,
                        EMS_Event_gne__c = event.Id,
                        RecordTypeId = recordTypeId,
                        EMS_Product_Budget_gne__c = pb.Id
                );
                budgetAllocations.add(budgetAllocation);
            }
        }
        insert budgetAllocations;
        return budgetAllocations;
    }

    public static List<EMS_Budget_Allocation_gne__c> createBudgetAllocations(Id recordTypeId, Decimal allocatedAmount, Id budgetOwnerId, List<EMS_Event__c> events, List<EMS_Budget_Region_gne__c> regionBudgets) {
        List<EMS_Budget_Allocation_gne__c> budgetAllocations = new List<EMS_Budget_Allocation_gne__c>();
        for (EMS_Budget_Region_gne__c rb : regionBudgets) {
            for (EMS_Event__c event : events) {
                EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                        Allocated_Budget_gne__c = allocatedAmount,
                        Budget_Deductions_gne__c = 0,
                        Percentage_Contribution_gne__c = allocatedAmount / event.Planned_Expenses_gne__c,
                        Budget_Owner_gne__c = budgetOwnerId,
                        EMS_Event_gne__c = event.Id,
                        RecordTypeId = recordTypeId,
                        EMS_Region_Budget_gne__c = rb.Id
                );
                budgetAllocations.add(budgetAllocation);
            }
        }
        insert budgetAllocations;
        return budgetAllocations;
    }

    public static List<EMS_Budget_Allocation_gne__c> createBudgetAllocations(Id recordTypeId, Decimal allocatedAmount, Id budgetOwnerId, List<EMS_Event__c> events, List<EMS_Budget_Territory_gne__c> territoryBudgets) {
        List<EMS_Budget_Allocation_gne__c> budgetAllocations = new List<EMS_Budget_Allocation_gne__c>();
        for (EMS_Budget_Territory_gne__c tb : territoryBudgets) {
            for (EMS_Event__c event : events) {
                EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                        Allocated_Budget_gne__c = allocatedAmount,
                        Budget_Deductions_gne__c = 0,
                        Percentage_Contribution_gne__c = allocatedAmount / event.Planned_Expenses_gne__c,
                        Budget_Owner_gne__c = budgetOwnerId,
                        EMS_Event_gne__c = event.Id,
                        RecordTypeId = recordTypeId,
                        EMS_Territory_Budget_gne__c = tb.Id
                );
                budgetAllocations.add(budgetAllocation);
            }
        }
        insert budgetAllocations;
        return budgetAllocations;
    }

	/**************************************************************************
	************************* EVENT data generation ***************************
	**************************************************************************/

    public static EMS_Event__c createEvent(String status, Id userId, Date startDate, Date endDate) {
        EMS_Event__c e = prepareEvent(status, userId, startDate, endDate);
        insert e;
        return e;
    }

    public static List<EMS_Event__c> createEvents(String status, Id userId, Date startDate, Date endDate, Integer howMany) {
        List<EMS_Event__c> e = prepareEvents(status, userId, startDate, endDate, howMany);
        insert e;
        return e;
    }

    public static EMS_Event__c createEvent(String status, Id userId, String eventType, String eventSubtype, Date startDate, Date endDate) {
        EMS_Event__c e = prepareEvent(status, userId, eventType, eventSubtype, startDate, endDate, null, null, null);
        insert e;
        return e;
    }

    public static List<EMS_Event__c> createEvents(String status, Id userId, String eventType, String eventSubtype, Date startDate, Date endDate, Integer howMany) {
        List<EMS_Event__c> e = prepareEvents(status, userId, eventType, eventSubtype, startDate, endDate, null, null, null, howMany);
        insert e;
        return e;
    }

    public static List<EMS_Event__c> createEvents(String status, Id userId, String eventType, String eventSubtype, Date startDate, Date endDate, String investment, Integer howMany) {
        List<EMS_Event__c> e = prepareEvents(status, userId, eventType, eventSubtype, startDate, endDate, null, null, investment, howMany);
        insert e;
        return e;
    }

    public static EMS_Event__c createEvent(String status, Id userId, String eventType, String eventSubtype, Date startDate, Date endDate, Decimal plannedExpenses) {
        EMS_Event__c e = prepareEvent(status, userId, eventType, eventSubtype, startDate, endDate, plannedExpenses, null, null);
        insert e;
        return e;
    }

    public static List<EMS_Event__c> createEvents(String status, Id userId, String eventType, String eventSubtype, Date startDate, Date endDate, Decimal plannedExpenses, Integer howMany) {
        List<EMS_Event__c> e = prepareEvents(status, userId, eventType, eventSubtype, startDate, endDate, plannedExpenses, null, null, howMany);
        insert e;
        return e;
    }

    public static EMS_Event__c createEvent(String status, Id userId, String eventType, String eventSubtype, Date startDate, Date endDate, Decimal plannedExpenses, String assignedToTerritory) {
        EMS_Event__c e = prepareEvent(status, userId, eventType, eventSubtype, startDate, endDate, plannedExpenses, assignedToTerritory, null);
        insert e;
        return e;
    }

    public static List<EMS_Event__c> createEvents(String status, Id userId, String eventType, String eventSubtype, Date startDate, Date endDate, Decimal plannedExpenses, String assignedToTerritory, Integer howMany) {
        List<EMS_Event__c> e = prepareEvents(status, userId, eventType, eventSubtype, startDate, endDate, plannedExpenses, assignedToTerritory, null, howMany);
        insert e;
        return e;
    }

    public static EMS_Event__c prepareEvent(String status, Id userId, Date startDate, Date endDate) {
        return prepareEvent(status, userId, 'Consulting Meetings', 'CHE Accredited', startDate, endDate, null, null, null);
    }

    public static List<EMS_Event__c> prepareEvents(String status, Id userId, Date startDate, Date endDate, Integer howMany) {
        List<EMS_Event__c> events = new List<EMS_Event__c>();

        for (Integer i = 0; i < howMany; i++) {
            events.add(prepareEvent(status, userId, 'Consulting Meetings', 'CHE Accredited', startDate, endDate, null, null, null));
        }
        return events;
    }

    public static EMS_Event__c prepareEvent(String status, Id userId, String eventType, String eventSubtype, Date startDate, Date endDate, Decimal plannedExpenses, String assignedToTerritory, String investment) {
        EMS_Event__c e = new EMS_Event__c(
                Event_Name_gne__c = 'New Event',
                Address_gne__c = 'ul. Alternatywy 4, 02-775 Warszawa',
                Agenda_Comments_gne__c = 'We make big event',
                City_gne__c = 'Warszawa',
                Contact_Name_Phone_number_gne__c = '600666000',
                End_Date_gne__c = endDate,
                Event_Owner_gne__c = userId,
                Event_Requestor_gne__c = userId,
                Event_Sub_Type_gne__c = eventSubtype,
                Event_Type_gne__c = eventType,
                Facility_Name_Venue_gne__c = 'TTest text',
                Hours_of_Event_gne__c = '55',
                Language_gne__c = 'French',
                Maximum_Attendees__c = 100,
                Meeting_Room_Names_gne__c = 'French Meeting room',
                Non_HCP_Attendees_gne__c = 2,
                Start_Date_gne__c = startDate,
                Status_gne__c = status,
                Planned_Expenses_gne__c = (plannedExpenses != null) ? plannedExpenses : 0,
                Assigned_To_Territory_Requestor_gne__c = assignedToTerritory,
                Assigned_To_Territory_Owner_gne__c = assignedToTerritory,
                Investment_gne__c = investment != null ? investment : 'National',
                Province_gne__c = 'testprov',
                Country_gne__c = 'Poland',
                Pending_Budget_Approval_gne__c = false
        );

        if (eventType == 'Grants') {
            e.Therapeutic_Area_gne__c = 'test';
        }

        return e;
    }

    public static List<EMS_Event__c> prepareEvents(String status, Id userId, String eventType, String eventSubtype, Date startDate, Date endDate, Decimal plannedExpenses, String assignedToTerritory, String investment, Integer howMany) {
        List<EMS_Event__c> events = new List<EMS_Event__c>();
        for (Integer i = 0; i < howMany; i++) {
            events.add(prepareEvent(status, userId, eventType, eventSubtype, startDate, endDate, plannedExpenses, assignedToTerritory, investment));
        }
        return events;
    }


	/**************************************************************************
	********************* EVENT PRODUCT data generation ***********************
	**************************************************************************/
    public static EMS_Event_Product_gne__c prepareEventProduct(Id eventId, Id productID, Id productStrategyId) {

        EMS_Event_Product_gne__c evProd = new EMS_Event_Product_gne__c(
                Event_gne__c = eventId,
                Product_Indication_gne__c = productID,
                Product_Strategy_gne__c = productStrategyId
        );
        return evProd;
    }

    public static EMS_Event_Product_gne__c createEventProduct(Id eventId, Id productID, Id productStrategyId, Id productTacticId) {

        EMS_Event_Product_gne__c evProd = new EMS_Event_Product_gne__c(
                Event_gne__c = eventId,
                Product_Indication_gne__c = productID,
                Product_Strategy_gne__c = productStrategyId
        );
        insert evProd;
        return evProd;
    }

    public static List<EMS_Event_Product_gne__c> createEventProducts(List<EMS_Event__c> events, Id productID, Id productStrategyId) {
        List<EMS_Event_Product_gne__c> eventProducts = new List<EMS_Event_Product_gne__c>();

        for (EMS_Event__c event : events) {
            eventProducts.add(prepareEventProduct(event.Id, productID, productStrategyId));
        }
        insert eventProducts;
        return eventProducts;
    }

    public static List<EMS_Event_Product_gne__c> createEventProducts(List<EMS_Event__c> events, Id productID, Id productStrategyId, Integer howMany) {
        List<EMS_Event_Product_gne__c> eventProducts = new List<EMS_Event_Product_gne__c>();

        for (Integer i = 0; i < howMany; i++) {
            for (EMS_Event__c event : events) {
                eventProducts.add(prepareEventProduct(event.Id, productID, productStrategyId));
            }
        }

        insert eventProducts;
        return eventProducts;
    }

    public static Product_vod__c getProductIndication() {
        Product_vod__c prod = new Product_vod__c(Name = 'name ' + Date.today());

        insert prod;
        return prod;
    }

    public static Product_Strategy_vod__c getProductStrategy() {
        Product_Strategy_vod__c prodStr = new Product_Strategy_vod__c(Name = 'name ' + Date.today());

        insert prodStr;
        return prodStr;
    }

    public static Product_Tactic_vod__c getProductTactic() {
        Product_Tactic_vod__c prodTac = new Product_Tactic_vod__c(Name = 'name ' + Date.today());

        insert prodTac;
        return prodTac;
    }

	/**************************************************************************
	************************ ATTENDEE data generation *************************
	**************************************************************************/

    public static EMS_Attendee_gne__c createAttendee(Id eventId) {
        EMS_Attendee_gne__c att = new EMS_Attendee_gne__c(EMS_Event_gne__c = eventId);
        insert att;
        return att;
    }

    public static List<EMS_Attendee_gne__c> createAttendees(List<EMS_Event__c> events) {
        List<EMS_Attendee_gne__c> attendees = new List<EMS_Attendee_gne__c>();
        for (EMS_Event__c event : events) {
            EMS_Attendee_gne__c att = new EMS_Attendee_gne__c(EMS_Event_gne__c = event.Id, Status_gne__c = 'Attended');
            attendees.add(att);
        }
        insert attendees;
        return attendees;
    }

    public static List<EMS_Attendee_gne__c> createAttendees(Account account, List<EMS_Event__c> events) {
        List<EMS_Attendee_gne__c> attendees = new List<EMS_Attendee_gne__c>();
        for (EMS_Event__c event : events) {
            EMS_Attendee_gne__c att = new EMS_Attendee_gne__c(Account_gne__c = account.Id, EMS_Event_gne__c = event.Id, Status_gne__c = 'Attended');
            attendees.add(att);
        }
        insert attendees;
        return attendees;
    }

    public static List<EMS_Attendee_gne__c> createStaticFMVAttendees(List<EMS_Event__c> events, Account account) {
        List<EMS_Attendee_gne__c> attendees = new List<EMS_Attendee_gne__c>();
        for (EMS_Event__c event : events) {
            EMS_Attendee_gne__c att = new EMS_Attendee_gne__c(
                    EMS_Event_gne__c = event.Id,
                    Status_gne__c = 'Attended',
                    Role_gne__c = 'Speaker',
                    Address_gne__c = 'Address',
                    Talk_Prep_Amount_gne__c = 500.00,
                    Disturbance_Fee_Amount_gne__c = 310.00,
                    Activity_Amount_gne__c = 350.00,
                    Disturbance_Fee__c = 'Flight (Event held in Canada/US and over 6hrs, return trip)',
                    Email_address_gne__c = 'email@email.com',
                    Event_Start_Time_gne__c = '1AM',
                    Event_End_Time_gne__c = '2AM',
                    HCP_hourly_rate_table_gne__c = '100',
                    Payable_To_Name_gne__c = 'Name X',
                    Total_Honoraria_gne__c = 1600.00,
                    Preparation_Time_1_gne__c = '1',
                    Preparation_Time_2_gne__c = '3',
                    Preparation_Time_3_gne__c = '1',
                    Activity_Time_1_gne__c = '1',
                    Activity_Time_2_gne__c = '1.5',
                    Activity_Time_3_gne__c = '1',
                    Account_gne__c = account.Id,
                    Type_of_HCP_gne__c = 'PhD Researchers/Psychologists'
            );
            attendees.add(att);
        }
        insert attendees;
        return attendees;
    }

    public static List<EMS_Attendee_gne__c> createIHCPAttendee(EMS_International_Speaker_gne__c ihcp, List<EMS_Event__c> events) {
        List<EMS_Attendee_gne__c> attendees = new List<EMS_Attendee_gne__c>();
        for (EMS_Event__c event : events) {
            EMS_Attendee_gne__c att = new EMS_Attendee_gne__c(EMS_International_Speaker_gne__c = ihcp.Id, EMS_Event_gne__c = event.Id, Status_gne__c = 'Attended');
            attendees.add(att);
        }
        insert attendees;
        return attendees;
    }

    public static EMS_Attendee_gne__c prepareAttendee(Id eventId) {
        EMS_Attendee_gne__c att = new EMS_Attendee_gne__c(EMS_Event_gne__c = eventId);
        return att;
    }


    /**************************************************************************
    ******************** INTERACTION data generation ***********************
    **************************************************************************/

    // Testdata Attendee Interaction
    public static EMS_Interaction_gne__c createAttendeeInteraction(Id eventId, EMS_Attendee_gne__c attendee, Id rocheAttendeeId, Id territoryId, Id productId, Id strategyId, String reaction, Id toolId, Integer quantity) {
        EMS_Interaction_gne__c interaction = new EMS_Interaction_gne__c(
                EMS_Event__c = eventId, EMS_Attendee_gne__c = attendee.Id, EMS_Roche_Attendee__c = rocheAttendeeId, Territory_gne__c = territoryId, Product_gne__c = productId, Product_Strategy_gne__c = strategyId,
                Reaction_gne__c = reaction, Tool_gne__c = toolId, Quantity_gne__c = quantity
        );
        insert interaction;
        return interaction;
    }

    // Testdata Attendee Interaction
    public static List<EMS_Interaction_gne__c> createAttendeeInteractions(List<EMS_Event__c> events, List<EMS_Attendee_gne__c> attendees, List<EMS_Roche_Attendee_gne__c> rocheAttendees, Id territoryId, Id productId, Id strategyId, String reaction, Id toolId, Integer quantity) {
        List<EMS_Interaction_gne__c> interactions = new List<EMS_Interaction_gne__c>();
        for (Integer i = 0; i < events.size(); i++) {
            EMS_Interaction_gne__c interaction = new EMS_Interaction_gne__c(
                    EMS_Event__c = events[i].Id,
                    EMS_Attendee_gne__c = attendees[i].Id,
                    EMS_Roche_Attendee__c = rocheAttendees[i].Id,
                    Territory_gne__c = territoryId,
                    Product_gne__c = productId,
                    Product_Strategy_gne__c = strategyId,
                    Reaction_gne__c = reaction,
                    Tool_gne__c = toolId,
                    Quantity_gne__c = quantity
            );
            interactions.add(interaction);
        }

        insert interactions;
        return interactions;
    }

	/**************************************************************************
	******************** ROCHE ATTENDEE data generation ***********************
	**************************************************************************/

    public static EMS_Roche_Attendee_gne__c createRocheAttendee(Id eventId, Id userId) {
        EMS_Roche_Attendee_gne__c rocheAttendee = prepareRocheAttendee (eventId, UserId);
        insert rocheAttendee;
        return rocheAttendee;
    }

    public static EMS_Roche_Attendee_gne__c createRocheAttendee(Id eventId, User user) {
        EMS_Roche_Attendee_gne__c rocheAttendee = prepareRocheAttendee (eventId, user.Id);
        insert rocheAttendee;
        return rocheAttendee;
    }


    public static List<EMS_Roche_Attendee_gne__c> createRocheAttendees(List<EMS_Event__c> events, User user) {
        return createRocheAttendees(events, user.Id);
    }

    public static List<EMS_Roche_Attendee_gne__c> createRocheAttendees(List<EMS_Event__c> events, Id userId) {
        return createRocheAttendees(events, userId, null);
    }

    public static List<EMS_Roche_Attendee_gne__c> createRocheAttendees(List<EMS_Event__c> events, Id userId, Id territoryId) {
        List<EMS_Roche_Attendee_gne__c> rocheAttendeeds = new List<EMS_Roche_Attendee_gne__c>();

        for (EMS_Event__c event : events) {
            EMS_Roche_Attendee_gne__c rAtt = prepareRocheAttendee (event.Id, userId, territoryId);
            rocheAttendeeds.add(rAtt);
        }

        insert rocheAttendeeds;
        return rocheAttendeeds;
    }


    public static EMS_Roche_Attendee_gne__c prepareRocheAttendee(Id eventId, Id userId) {
        return prepareRocheAttendee(eventId, userId, null);
    }

    public static EMS_Roche_Attendee_gne__c prepareRocheAttendee(Id eventId, Id userId, Id territoryId) {
        EMS_Roche_Attendee_gne__c rocheAttendee = new EMS_Roche_Attendee_gne__c(
                RecordTypeId = raRecordTypesMap.get('EMS Roche Attendee'),
                EMS_Event_gne__c = eventId,
                User_gne__c = userId,
                Territory_Id_gne__c = territoryId
        );
        return rocheAttendee;
    }

	/**************************************************************************
	********************** FUND REQUEST data generation ***********************
	**************************************************************************/

    public static EMS_Fund_Request_gne__c prepareFundRequest(Id rtID, Id pbID, Id rbID, Id tbID, Decimal amount, Date requiredBy) {
        EMS_Fund_Request_gne__c fr = new EMS_Fund_Request_gne__c(
                RecordTypeId = rtID,
                Related_Product_Budget_gne__c = pbID,
                Related_Region_Budget_gne__c = rbID,
                Related_Territory_Budget_gne__c = tbID,
                Requested_Amount_gne__c = amount,
                Status_gne__c = 'New',
                Required_By_Date_gne__c = requiredBy,
                Reason_gne__c = 'A reason...'
        );
        return fr;
    }

    public static EMS_Fund_Request_gne__c prepareFundRequest(String rtName, Id pbID, Id rbID, Id tbID, Decimal amount, Date requiredBy) {
        Id rtID = frRecordTypesMap.get(rtName);
        return prepareFundRequest(rtID, pbID, rbID, tbID, amount, requiredBy);
    }

    public static EMS_Fund_Request_gne__c prepareFundRequest(Id rtId, Id pbID, Id rbID, Id tbID, Decimal amount) {
        return prepareFundRequest(rtID, pbID, rbID, tbID, amount, Date.Today().addDays(1));
    }

    public static EMS_Fund_Request_gne__c prepareFundRequest(String rtName, Id pbID, Id rbID, Id tbID, Decimal amount) {
        return prepareFundRequest(frRecordTypesMap.get(rtName), pbID, rbID, tbID, amount);
    }

    public static EMS_Fund_Request_gne__c createFundRequest(Id rtId, Id pbID, Id rbID, Id tbID, Decimal amount) {
        EMS_Fund_Request_gne__c fr = prepareFundRequest(rtId, pbID, rbID, tbID, amount);
        insert fr;
        return fr;
    }

    public static EMS_Fund_Request_gne__c createFundRequest(String rtName, Id pbID, Id rbID, Id tbID, Decimal amount) {
        EMS_Fund_Request_gne__c fr = prepareFundRequest(frRecordTypesMap.get(rtName), pbID, rbID, tbID, amount);
        insert fr;
        return fr;
    }

    public static List<EMS_Fund_Request_gne__c> createFundRequestsForGivenRegions(Id recordTypeId, Id productBudgetId, List<EMS_Budget_Region_gne__c> budgetRegions, Decimal requestedAmount) {
        List<EMS_Fund_Request_gne__c> toInsert = new List<EMS_Fund_Request_gne__c>();
        for (EMS_Budget_Region_gne__c region : budgetRegions) {
            toInsert.add(prepareFundRequest(recordTypeId, productBudgetId, region.Id, null, requestedAmount));
        }
        insert toInsert;
        return toInsert;
    }

    public static List<EMS_Fund_Request_gne__c> createFundRequestsForEachRB(String recordTypeName, List<EMS_Budget_Region_gne__c> budgetRegions, Decimal requestedAmount, Integer howManyFrPerBudget) {
        return createFundRequestsForEachRB (recordTypeName, budgetRegions, requestedAmount, Date.Today() + 1, howManyFrPerBudget);
    }

    public static List<EMS_Fund_Request_gne__c> createFundRequestsForEachRB(String recordTypeName, List<EMS_Budget_Region_gne__c> budgetRegions, Decimal requestedAmount, Date requiredBy, Integer howManyFrPerBudget) {
        return createFundRequestsForEachRB (recordTypeName, budgetRegions, requestedAmount, requiredBy, howManyFrPerBudget, true);
    }

    public static List<EMS_Fund_Request_gne__c> createFundRequestsForEachRB(String recordTypeName, List<EMS_Budget_Region_gne__c> budgetRegions, Decimal requestedAmount, Integer howManyFrPerBudget, Boolean makeInsert) {
        return createFundRequestsForEachRB (recordTypeName, budgetRegions, requestedAmount, Date.Today() + 1, howManyFrPerBudget, makeInsert);
    }

    public static List<EMS_Fund_Request_gne__c> createFundRequestsForEachRB(String recordTypeName, List<EMS_Budget_Region_gne__c> budgetRegions, Decimal requestedAmount, Date requiredBy, Integer howManyFrPerBudget, Boolean makeInsert) {
        List<EMS_Fund_Request_gne__c> toInsert = new List<EMS_Fund_Request_gne__c>();
        Integer i;

        for (EMS_Budget_Region_gne__c rb : budgetRegions) {
            for (i = 0; i < howManyFrPerBudget; i++) {
                toInsert.add(prepareFundRequest(frRecordTypesMap.get(recordTypeName), rb.EMS_Budget_Product_gne__c, rb.Id, null, requestedAmount, requiredBy));
            }
        }

        if (makeInsert) insert toInsert;
        return toInsert;
    }

    public static List<EMS_Fund_Request_gne__c> createFundRequestsForEachRB(String recordTypeName, List<EMS_Budget_Territory_gne__c> territoryBudgets, Decimal requestedAmount, Integer howManyFrPerBudget, Boolean makeInsert) {
        List<EMS_Fund_Request_gne__c> toInsert = new List<EMS_Fund_Request_gne__c>();
        Integer i;

        for (EMS_Budget_Territory_gne__c tb : territoryBudgets) {
            for (i = 0; i < howManyFrPerBudget; i++) {
                toInsert.add(prepareFundRequest(frRecordTypesMap.get(recordTypeName),
                        tb.EMS_Budget_Region_gne__r.EMS_Budget_Product_gne__c,
                        tb.EMS_Budget_Region_gne__c,
                        tb.Id,
                        requestedAmount,
                        Date.Today() + 1)
                );
            }
        }

        if (makeInsert) insert toInsert;
        return toInsert;
    }

    // FR for Territories
    public static List<EMS_Fund_Request_gne__c> createFundRequestsForGivenTerritories(Id recordTypeId, Id regionBudgetId, List<EMS_Budget_Territory_gne__c> territoryRegions, Decimal requestedAmount) {
        List<EMS_Fund_Request_gne__c> toInsert = new List<EMS_Fund_Request_gne__c>();
        for (EMS_Budget_Territory_gne__c territory : territoryRegions) {
            toInsert.add(prepareFundRequest(recordTypeId, null, regionBudgetId, territory.Id, requestedAmount));
        }
        insert toInsert;
        return toInsert;
    }

    public static List<EMS_Fund_Request_gne__c> createFundRequestsForEachTB(String recordTypeName, List<EMS_Budget_Territory_gne__c> territoryBudgets, Decimal requestedAmount, Integer howManyFrPerBudget) {
        return createFundRequestsForEachTB (recordTypeName, territoryBudgets, requestedAmount, Date.Today() + 1, howManyFrPerBudget);
    }

    public static List<EMS_Fund_Request_gne__c> createFundRequestsForEachTB(String recordTypeName, List<EMS_Budget_Territory_gne__c> territoryBudgets, Decimal requestedAmount, Integer howManyFrPerBudget, Boolean makeInsert) {
        return createFundRequestsForEachTB (recordTypeName, territoryBudgets, requestedAmount, Date.Today() + 1, howManyFrPerBudget, makeInsert);
    }

    public static List<EMS_Fund_Request_gne__c> createFundRequestsForEachTB(String recordTypeName, List<EMS_Budget_Territory_gne__c> territoryBudgets, Decimal requestedAmount, Date requiredBy, Integer howManyFrPerBudget) {
        return createFundRequestsForEachTB (recordTypeName, territoryBudgets, requestedAmount, requiredBy, howManyFrPerBudget, true);
    }

    public static List<EMS_Fund_Request_gne__c> createFundRequestsForEachTB(String recordTypeName, List<EMS_Budget_Territory_gne__c> territoryBudgets, Decimal requestedAmount, Date requiredBy, Integer howManyFrPerBudget, Boolean makeInsert) {
        List<EMS_Fund_Request_gne__c> toInsert = new List<EMS_Fund_Request_gne__c>();
        Integer i;

        for (EMS_Budget_Territory_gne__c tb : territoryBudgets) {
            for (i = 0; i < howManyFrPerBudget; i++) {
                toInsert.add(prepareFundRequest(frRecordTypesMap.get(recordTypeName), null, tb.EMS_Budget_Region_gne__c, tb.Id, requestedAmount, requiredBy));
            }
        }

        if (makeInsert) insert toInsert;
        return toInsert;
    }

	/**************************************************************************
	*************************** TRAVEL methods ********************************
	**************************************************************************/

    public static EMS_Travel_gne__c createTravel(EMS_Event__c event) {
        EMS_Travel_gne__c travel = new EMS_Travel_gne__c(EMS_Event_gne__c = event.Id);
        insert travel;
        return travel;
    }

    public static List<EMS_Travel_gne__c> createTravels(List<EMS_Event__c> events) {
        List<EMS_Travel_gne__c> travels = new List<EMS_Travel_gne__c>();
        for (EMS_Event__c event : events) {
            EMS_Travel_gne__c travel = new EMS_Travel_gne__c(EMS_Event_gne__c = event.Id);
            travels.add(travel);
        }
        insert travels;
        return travels;
    }

	/**************************************************************************
	************************** GSDDetail methods ******************************
	**************************************************************************/

    public static EMS_GSD_Detail__c prepareGSDDetail(EMS_Event__c event, Account acc, String postalCode, String url) {
        EMS_GSD_Detail__c gsdDetail = new EMS_GSD_Detail__c(
                EMS_Event__c = event.Id,
                Date_of_Request_Letter_gne__c = System.today(),
                HCP_HCO_Name__c = acc.Id,
                City_gne__c = 'Alberta',
                Country_gne__c = 'Canada',
                Institution_gne__c = 'Acme',
                Postal_Code_gne__c = postalCode,
                Province_gne__c = 'Alberta',
                Recipient_Job_Title_gne__c = 'Test',
                Street_1_gne__c = 'Street1',
                Street_2_gne__c = 'Street2',
                Phone_Number_gne__c = '8899633225',
                Email_Address_gne__c = 'email@testaddress.com',
                Name_of_Vendor_Signatory_gne__c = 'Name of Vandor',
                Email_Address_Vendor_Signatory_gne__c = 'email-diff@testaddress.com',
                Website_URL_gne__c = url
        );
        return gsdDetail;
    }

    // Testdata GSD Details
    public static EMS_GSD_Detail__c prepareGSDDetail(Id eventId, Date requestLetterDate, Id accountId) {
        EMS_GSD_Detail__c gsdDetail = new EMS_GSD_Detail__c(
                EMS_Event__c = eventId,
                Date_of_Request_Letter_gne__c = requestLetterDate,
                HCP_HCO_Name__c = accountId,
                City_gne__c = 'Alberta',
                Country_gne__c = 'Canada',
                Institution_gne__c = 'Acme',
                Postal_Code_gne__c = 'A1A 2B2',
                Province_gne__c = 'Alberta',
                Recipient_Job_Title_gne__c = 'Test',
                Street_1_gne__c = 'Street1',
                Street_2_gne__c = 'Street2',
                Phone_Number_gne__c = '8899633225',
                Email_Address_gne__c = 'email@testaddress.com',
                Name_of_Vendor_Signatory_gne__c = 'Name of Vandor',
                Email_Address_Vendor_Signatory_gne__c = 'email-diff@testaddress.com',
                Website_URL_gne__c = 'www.test-website.com'
        );
        return gsdDetail;
    }

    public static EMS_GSD_Detail__c createGSDDetail(EMS_Event__c event) {
        Account acc = createAndInsertAccount('HCP Canada');
        EMS_GSD_Detail__c gsdDetail = prepareGSDDetail(event.Id, System.today(), acc.Id);

        insert gsdDetail;
        return gsdDetail;
    }

    public static List<EMS_GSD_Detail__c> createGSDDetails(List<EMS_Event__c> events) {

        // create some account
        Account acc = createAndInsertAccount('HCP Canada');

        List<EMS_GSD_Detail__c> gsdDetails = new List<EMS_GSD_Detail__c>();
        for (EMS_Event__c event : events) {
            EMS_GSD_Detail__c gsdDetail = new EMS_GSD_Detail__c(
                    EMS_Event__c = event.Id,
                    Date_of_Request_Letter_gne__c = System.today(),
                    HCP_HCO_Name__c = acc.Id,
                    City_gne__c = 'Alberta',
                    Country_gne__c = 'Canada',
                    Institution_gne__c = 'Acme',
                    Postal_Code_gne__c = 'A0A 1B1',
                    Province_gne__c = 'Alberta',
                    Recipient_Job_Title_gne__c = 'test',
                    Street_1_gne__c = 'street1',
                    Street_2_gne__c = 'street2',
                    Phone_Number_gne__c = '8899633225',
                    Email_Address_gne__c = 'email@testaddress.com',
                    Name_of_Vendor_Signatory_gne__c = 'Name of Vandor',
                    Email_Address_Vendor_Signatory_gne__c = 'email-diff@testaddress.com'
            );
            gsdDetails.add(gsdDetail);
        }

        insert gsdDetails;
        return gsdDetails;
    }

    public static List<EMS_GSD_Detail__c> createGSDDetails(List<EMS_Event__c> events, String postalCode, String url) {

        // create some account
        Account acc = createAndInsertAccount('HCP Canada');

        List<EMS_GSD_Detail__c> gsdDetails = new List<EMS_GSD_Detail__c>();
        for (EMS_Event__c event : events) {
            gsdDetails.add(prepareGSDDetail(event, acc, postalCode, url));
        }

        insert gsdDetails;
        return gsdDetails;
    }

    public static List<EMS_GSD_Detail__c> createGSDDetails(Account acc, List<EMS_Event__c> events) {

        List<EMS_GSD_Detail__c> gsdDetails = new List<EMS_GSD_Detail__c>();
        for (EMS_Event__c event : events) {
            EMS_GSD_Detail__c gsdDetail = new EMS_GSD_Detail__c(
                    EMS_Event__c = event.Id,
                    Date_of_Request_Letter_gne__c = System.today(),
                    HCP_HCO_Name__c = acc.Id,
                    City_gne__c = 'Alberta',
                    Country_gne__c = 'Canada',
                    Institution_gne__c = 'Acme',
                    Postal_Code_gne__c = 'A0A 1B1',
                    Province_gne__c = 'Alberta',
                    Recipient_Job_Title_gne__c = 'test',
                    Street_1_gne__c = 'street1',
                    Street_2_gne__c = 'street2',
                    Phone_Number_gne__c = '8899633225',
                    Email_Address_gne__c = 'email@testaddress.com',
                    Name_of_Vendor_Signatory_gne__c = 'Name of Vandor',
                    Email_Address_Vendor_Signatory_gne__c = 'email-diff@testaddress.com'
            );
            gsdDetails.add(gsdDetail);
        }

        insert gsdDetails;
        return gsdDetails;
    }

	/**************************************************************************
	************************* INVESTMENT methods ******************************
	**************************************************************************/

    public static EMS_Investment_gne__c prepareInvestment(EMS_Event__c event) {

        EMS_Investment_gne__c investment = new EMS_Investment_gne__c(EMS_Event_gne__c = event.Id);
        return investment;
    }

    public static List<EMS_Investment_gne__c> createInvestments(EMS_Event__c event, Integer howMany) {
        List<EMS_Investment_gne__c> investementsToAdd = new List<EMS_Investment_gne__c>();

        for (Integer i = 0; i < howmany; i++) {
            investementsToAdd.add(prepareInvestment(event));
        }

        insert investementsToAdd;
        return investementsToAdd;
    }

    public static List<EMS_Investment_gne__c> createInvestmentsForMultipleEvents(List<EMS_Event__c> events, Integer howMany) {
        List<EMS_Investment_gne__c> investementsToAdd = new List<EMS_Investment_gne__c>();

        for (EMS_Event__c event : events) {
            for (Integer i = 0; i < howmany; i++) {
                investementsToAdd.add(prepareInvestment(event));
            }
        }
        insert investementsToAdd;
        return investementsToAdd;
    }

	/**************************************************************************
	*************************** EXPENSE methods *******************************
	**************************************************************************/

    public static EMS_Expense_gne__c createExpense(Id eventId, Decimal amount) {
        EMS_Expense_gne__c expense = new EMS_Expense_gne__c(EMS_Event_gne__c = eventId, Country_Expense_Amount_gne__c = amount, Expense_Date_gne__c = Date.today());

        insert expense;
        return expense;
    }

    public static List<EMS_Expense_gne__c> createExpenses(List<EMS_Event__c> events, Decimal amount, Integer howManyPerEvent, EMS_Cost_Center_gne__c costCenter) {
        List<EMS_Expense_gne__c> expenses = new List<EMS_Expense_gne__c>();
        for (Integer i = 0; i < howManyPerEvent; i++) {
            for (EMS_Event__c event : events) {
                EMS_Expense_gne__c expense = new EMS_Expense_gne__c(EMS_Event_gne__c = event.Id, Country_Expense_Amount_gne__c = amount, Expense_Date_gne__c = Date.today(), EMS_Cost_Center_gne__c = costCenter.Id);
                expenses.add(expense);
            }
        }

        insert expenses;
        return expenses;
    }

    public static List<EMS_Expense_gne__c> createExpenses(List<EMS_Event__c> events, Decimal amount, EMS_Cost_Center_gne__c costCenter) {
        List<EMS_Expense_gne__c> expenses = new List<EMS_Expense_gne__c>();
        for (EMS_Event__c event : events) {
            EMS_Expense_gne__c expense = new EMS_Expense_gne__c(EMS_Event_gne__c = event.Id, Country_Expense_Amount_gne__c = amount, Expense_Date_gne__c = Date.today(), EMS_Cost_Center_gne__c = costCenter.Id);
            expenses.add(expense);
        }

        insert expenses;
        return expenses;
    }

	/**************************************************************************
	*************************** TRANSACTION methods ***************************
	**************************************************************************/

    public static EMS_Transaction_gne__c prepareTransaction(EMS_Speaker_Role_gne__c paymentRequest) {
        EMS_Transaction_gne__c trans = new EMS_Transaction_gne__c(EMS_Speaker_Role_gne__c = paymentRequest.Id, Fee_Amount_gne__c = 1.0, EMS_Event_gne__c = paymentRequest.EMS_Event_gne__c);

        return trans;
    }

    public static EMS_Transaction_gne__c prepareTransaction(EMS_Speaker_Role_gne__c paymentRequest, Decimal feeAmount) {
        EMS_Transaction_gne__c trans = new EMS_Transaction_gne__c(EMS_Speaker_Role_gne__c = paymentRequest.Id, Fee_Amount_gne__c = feeAmount, EMS_Event_gne__c = paymentRequest.EMS_Event_gne__c);

        return trans;
    }

    public static EMS_Transaction_gne__c createTransaction(EMS_Speaker_Role_gne__c paymentRequest) {
        EMS_Transaction_gne__c trans = prepareTransaction(paymentRequest);

        insert trans;
        return trans;
    }

    public static EMS_Transaction_gne__c createTransaction(EMS_Speaker_Role_gne__c paymentRequest, Decimal feeAmount) {
        EMS_Transaction_gne__c trans = prepareTransaction(paymentRequest, feeAmount);

        insert trans;
        return trans;
    }

    public static List<EMS_Transaction_gne__c> createTransactions(List<EMS_Speaker_Role_gne__c> paymentRequests) {
        List<EMS_Transaction_gne__c> transactions = new List<EMS_Transaction_gne__c>();

        for (EMS_Speaker_Role_gne__c paymentRequest : paymentRequests) {
            transactions.add(prepareTransaction(paymentRequest));
        }

        insert transactions;
        return transactions;
    }

    public static List<EMS_Transaction_gne__c> createTransactions(List<EMS_Speaker_Role_gne__c> paymentRequests, Decimal feeAmount) {
        List<EMS_Transaction_gne__c> transactions = new List<EMS_Transaction_gne__c>();

        for (EMS_Speaker_Role_gne__c paymentRequest : paymentRequests) {
            transactions.add(prepareTransaction(paymentRequest, feeAmount));
        }

        insert transactions;
        return transactions;
    }

	/**************************************************************************
	**************************** PAYMENT REQUESTS methods *********************
	**************************************************************************/
    public class CustomException extends Exception {
    }

    private static Map<String, RecordType> transactionsRecordTypes {
        get {
            if (transactionsRecordTypes == null) {
                transactionsRecordTypes = new Map<String, RecordType>();
                List<RecordType> rts = [SELECT Name, DeveloperName FROM RecordType WHERE SObjectType = 'EMS_Transaction_gne__c'];
                for (RecordType rt: rts) {
                    transactionsRecordTypes.put(rt.Name, rt);
                }
            }
            return transactionsRecordTypes;
        }
        set;
    }

    public static EMS_Transaction_gne__c createTransaction(String rtName, Id prID, Id evID, Decimal amount, Id parentTransID, Id ccID) {
        if (!transactionsRecordTypes.containsKey(rtName)) {
            throw new CustomException('\'' + rtName + '\' RecordType does not exist');
        }
        RecordType rt = transactionsRecordTypes.get(rtName);
        EMS_Transaction_gne__c transactionRecord = null;

        if (rt.DeveloperName.toLowerCase() == 'transaction_group') {
            transactionRecord = new EMS_Transaction_gne__c(
                    EMS_Speaker_Role_gne__c = prID,
                    RecordTypeId = rt.Id,
                    EMS_Event_gne__c = evID,
                    Fee_Amount_gne__c = amount,
                    Tax_Code_gne__c = 'I0 (Tax - Exempt)',
                    Tax_Amount_gne__c = 0,
                    Tax_gne__c = 0,
                    Cost_Element_gne__c = '41811617' // is taken from tax code
            );
        } else if (rt.DeveloperName.toLowerCase() == 'transaction') {
            transactionRecord = new EMS_Transaction_gne__c(
                    EMS_Speaker_Role_gne__c = prID,
                    RecordTypeId = rt.Id,
                    EMS_Event_gne__c = evID,
                    Cost_Center_gne__c = ccID,
                    Parent_Transaction_gne__c = parentTransID,
                    Fee_Amount_gne__c = amount,
                    Tax_Code_gne__c = 'I0 (Tax - Exempt)',
                    Tax_Amount_gne__c = 0,
                    Tax_gne__c = 0,
                    Cost_Element_gne__c = '41811617' // is taken from tax code
            );
        }

        return transactionRecord;
    }


    public static EMS_Speaker_Role_gne__c createPaymentRequest(Id rtID, Id eventID, Id accountID) {
        EMS_Speaker_Role_gne__c paymentRequest = new EMS_Speaker_Role_gne__c(
                RecordTypeId = rtID,
                EMS_Event_gne__c = eventId,
                HCP_gne__c = accountId,
                Recipient_Vendor_Name_gne__c = 'DR SYED ANEES MEDICINE PROF CORP',
                Vendor_Address_gne__c = '1720 HOWARD AVE STE 164, WINDSOR, ON N8X 5A6',
                Vendor_ID_gne__c = '90329858',
                GST_HST_gne__c = '884282369',
                Payment_Terms_gne__c = 'Next 15 days',
                QST_gne__c = '118778091',
                Payment_Date_gne__c = Date.today()
        );

        insert paymentRequest;
        return paymentRequest;
    }

    public static EMS_Speaker_Role_gne__c createPaymentRequest(String rtName, Id eventId, Id accountId) {
        Id rtID = [SELECT Id FROM RecordType WHERE SObjectType = 'EMS_Speaker_Role_gne__c' AND Name = :rtName LIMIT 1].Id;

        EMS_Speaker_Role_gne__c paymentRequest = new EMS_Speaker_Role_gne__c(
                RecordTypeId = rtID,
                EMS_Event_gne__c = eventId,
                HCP_gne__c = accountId
        );

        insert paymentRequest;
        return paymentRequest;
    }

    public static List<EMS_Speaker_Role_gne__c> createPaymentRequests(String recordTypeName, List<EMS_Event__c> events, Id accountId, Id ihcpId, Date paymentDate) {
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'EMS_Speaker_Role_gne__c' AND Name = :recordTypeName LIMIT 1];
        List<EMS_Speaker_Role_gne__c> paymentRequests = new List<EMS_Speaker_Role_gne__c>();
        for (EMS_Event__c event : events) {
            paymentRequests.add(
                    new EMS_Speaker_Role_gne__c(
                            RecordTypeId = rt.Id,
                            EMS_Event_gne__c = event.Id,
                            EMS_International_Speaker_gne__c = ihcpId,
                            HCP_gne__c = accountId,
                            Payment_Date_gne__c = paymentDate
                    )
            );
        }

        insert paymentRequests;
        return paymentRequests;
    }

    /**************************************************************************
    *************************** ATTACHMENT methods ********************************
    **************************************************************************/

    public static EMS_Attachment_gne__c prepareAttachment(EMS_Event__c event, String type) {
        EMS_Attachment_gne__c attachment = new EMS_Attachment_gne__c(EMS_Event_gne__c = event.Id, Type_gne__c = type);
        return attachment;
    }

    public static EMS_Attachment_gne__c createAttachment(EMS_Event__c event, String type) {

        EMS_Attachment_gne__c attachment = prepareAttachment(event, type);

        insert attachment;
        return attachment;
    }

    public static List<EMS_Attachment_gne__c> createAttachments(List<EMS_Event__c> events, String type) {

        List<EMS_Attachment_gne__c> attachments = new List<EMS_Attachment_gne__c>();

        for (EMS_Event__c event : events) {
            attachments.add(prepareAttachment(event, type));
        }

        insert attachments;
        return attachments;
    }

	/**************************************************************************
	******************** DATA CHANGE REQUEST methods **************************
	**************************************************************************/

    public static EMS_Data_Change_Request_gne__c prepareDCR() {
        EMS_Data_Change_Request_gne__c dcr = new EMS_Data_Change_Request_gne__c();
        return dcr;
    }

    public static List<EMS_Data_Change_Request_gne__c> createDCRs(Integer howMany) {
        List<EMS_Data_Change_Request_gne__c> dcrs = new List<EMS_Data_Change_Request_gne__c>();

        for (Integer i = 0; i < howMany; i++) {
            dcrs.add(prepareDCR());
        }

        insert dcrs;
        return dcrs;
    }


	/**************************************************************************
	*************************** Products methods ******************************
	**************************************************************************/

    public static Product_vod__c createProduct(String productName) {
        Product_vod__c prod = new Product_vod__c(Name = productName);

        insert prod;
        return prod;
    }

    public static Product_Strategy_vod__c createStrategy(Id parentProductId, String strategyName) {
        Product_Plan_vod__c productPlan = new Product_Plan_vod__c(Product_vod__c = parentProductId);
        insert productPlan;

        Product_Strategy_vod__c strategy = new Product_Strategy_vod__c(Name = strategyName, Product_Plan_vod__c = productPlan.Id);

        insert strategy;
        return strategy;
    }

    public static List<My_Setup_Products_vod__c> createMySetupProducts(List<Product_vod__c> productList) {

        List<My_Setup_Products_vod__c> myProdList = new List<My_Setup_Products_vod__c>();
        My_Setup_Products_vod__c msp;
        for (Product_vod__c product : productList) {
            msp = new My_Setup_Products_vod__c(Name = 'pname', Product_vod__c = product.Id);
            myProdList.add(msp);
        }
        insert myProdList;
        return myProdList;
    }

	/**************************************************************************
	**************************** Meeting Request *******************************
	**************************************************************************/
    public static List<EMS_Meeting_Request_gne__c> createMeetingRequests(List<EMS_Event__c> events) {
        List<EMS_Meeting_Request_gne__c> meetingRequests = new List<EMS_Meeting_Request_gne__c>();

        for (EMS_Event__c event : events) {
            meetingRequests.add(new EMS_Meeting_Request_gne__c(EMS_Event_gne__c = event.Id, Requestor_Name__c = 'test'));
        }
        insert meetingRequests;
        return meetingRequests;
    }

	/**************************************************************************
	**************************** Meeting Room *******************************
	**************************************************************************/
    public static List<EMS_Meeting_Room_gne__c> createMeetingRooms(List<EMS_Meeting_Request_gne__c> meetingRequests) {
        List<EMS_Meeting_Room_gne__c> meetingRooms = new List<EMS_Meeting_Room_gne__c>();

        for (EMS_Meeting_Request_gne__c meetingRequest : meetingRequests) {
            meetingRooms.add(new EMS_Meeting_Room_gne__c(EMS_Meeting_Request_gne__c = meetingRequest.Id, Break_Out_Room_gne__c = 'test'));
        }
        insert meetingRooms;
        return meetingRooms;
    }

	/**************************************************************************
	**************************** Other methods *******************************
	**************************************************************************/

    public static RecordType getRecordTypeByDeveloperName(String recordType) {
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName LIKE :recordType limit 1];
        return rt;
    }

    public static ProcessInstanceWorkitem createProcessInstanceWorkItem(EMS_Fund_Request_gne__c fundRequest) {
        Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
        request.setObjectId(fundRequest.id);
        request.setComments('Submitting request for approval.');
        Approval.ProcessResult result = Approval.process(request);
        ProcessInstanceWorkitem processInstanceWorkitem = [Select id from ProcessInstanceWorkitem where ProcessInstance.TargetObject.Id = :fundRequest.id limit 1];
        return processInstanceWorkitem;
    }

    public static Group createFinanceController() {
        Group financeController = [SELECT id, name FROM Group WHERE Type = 'Queue' AND Name = 'EMS Finance Controller Queue' LIMIT 1];
        return financeController;
    }


    public static Product_vod__c createTool(Id parentProductId, String toolName) {
        Product_vod__c prod = new Product_vod__c(Name = toolName, Parent_Product_vod__c = parentProductId, Product_Type_vod__c = 'Gift');

        insert prod;
        return prod;
    }

    public static EMS_Event_Configuration_gne__c createEventConfiguration(String eventType, String eventSubtype) {
        EMS_Event_Configuration_gne__c config = new EMS_Event_Configuration_gne__c(
                Event_Type_gne__c = eventType,
                Event_Sub_Type_gne__c = eventSubtype,
                External_Id_gne__c = eventType + '_' + eventSubtype
        );
        insert config;
        return config;
    }

    public static EMS_Event_Configuration_gne__c createEventConfiguration(String eventType, String eventSubtype, String pendingBudgetApprovalLabel) {
        EMS_Event_Configuration_gne__c config = new EMS_Event_Configuration_gne__c(
                Event_Type_gne__c = eventType,
                Event_Sub_Type_gne__c = eventSubtype,
                External_Id_gne__c = eventType + '_' + eventSubtype,
                Pending_Budget_Approval_Label_gne__c = pendingBudgetApprovalLabel
        );
        insert config;
        return config;
    }

    public static List<EMS_Event_Configuration_gne__c> createEventConfigurations(String eventType, String eventSubtype, Integer howMany) {
        List<EMS_Event_Configuration_gne__c> configs = new List<EMS_Event_Configuration_gne__c>();
        for (Integer i = 0; i < howMany; i++) {
            configs.add(new EMS_Event_Configuration_gne__c(Event_Type_gne__c = eventType, Event_Sub_Type_gne__c = eventSubtype));
        }
        insert configs;
        return configs;
    }

    public static EMS_Possible_Budget_Allocation_gne__c preparePossibleBudgetAllocationMapping(EMS_Event_Configuration_gne__c config, EMS_Cost_Center_gne__c costCenter) {
        EMS_Possible_Budget_Allocation_gne__c pba = new EMS_Possible_Budget_Allocation_gne__c(
                EMS_Event_Configuration_gne__c = config.Id,
                Budget_Type_gne__c = costCenter.Cost_Center_Type_gne__c
        );
        return pba;
    }

    public static EMS_Possible_Budget_Allocation_gne__c createPossibleBudgetAllocationMapping(String eType, String eSubType, EMS_Cost_Center_gne__c costCenter) {
        EMS_Event_Configuration_gne__c config = createEventConfiguration(eType, eSubType);
        EMS_Possible_Budget_Allocation_gne__c pba = new EMS_Possible_Budget_Allocation_gne__c(
                EMS_Event_Configuration_gne__c = config.Id,
                Budget_Type_gne__c = costCenter.Cost_Center_Type_gne__c
        );
        insert pba;
        return pba;
    }

    public static EMS_Possible_Budget_Allocation_gne__c createPossibleBudgetAllocationMapping(String eType, String eSubType, String costCenterType) {
        List<EMS_Cost_Center_gne__c> costCenters = createCostCenters(costCenterType, 1, true);
        EMS_Event_Configuration_gne__c config = createEventConfiguration(eType, eSubType);

        EMS_Possible_Budget_Allocation_gne__c pba = new EMS_Possible_Budget_Allocation_gne__c(
                EMS_Event_Configuration_gne__c = config.Id,
                Budget_Type_gne__c = costCenters[0].Cost_Center_Type_gne__c
        );
        insert pba;
        return pba;
    }

    public static EMS_GSD_Event_Types_gne__c createGSDEventTypes() {
        EMS_GSD_Event_Types_gne__c gsdTypes = EMS_GSD_Event_Types_gne__c.getInstance();
        if (gsdTypes.GSD_Events_names__c == null) {
            gsdTypes = new EMS_GSD_Event_Types_gne__c(GSD_Events_names__c = GSD_EVENT_TYPES);
            try {
                insert gsdTypes;
            } catch (Exception e) {
                // Error occurs when two test methods are runned synchronously
                // UNABLE_TO_LOCK_ROW, unable to obtain exclusive access to this record
                System.debug(LoggingLevel.ERROR, '### EXCEPTION EMS_Test_Util.createGSDEventTypes(): ' + e.getMessage());
            }
        }

        return gsdTypes;
    }

	/**************************************************************************
	**************************** HELPER methods *******************************
	**************************************************************************/
    public static Date getStartDate() {
        Integer dayDifference = 15;
        Date startDate = Date.newInstance(Date.today().year(), Date.today().month(), Date.today().day());
        Date endDate = startDate.addDays(dayDifference);

        if (startDate.year() != endDate.year()) {
            startDate = startDate.addDays(-1 * dayDifference);
        }
        return startDate;
    }

    public static Map<String, Id> getRecordTypesMap(String objectName) {
        Map<String, Id> rtNameIdMap = new Map<String, Id>();

        Schema.DescribeSObjectResult describeResults = Schema.GetGlobalDescribe().get(objectName).getDescribe();
        List<Schema.RecordTypeInfo> schemaRTInfo = describeResults.getRecordTypeInfos();

        for (Schema.RecordTypeInfo rt : schemaRTInfo) {
            rtNameIdMap.put (rt.getName(), rt.getRecordTypeId()); //Schema gives access to Name only it shpuld be changed to Developer Name as soon as SF will add this.
        }

        return rtNameIdMap;
    }

    private static void fetchTerritoryNames() {
        for (List<Territory2> territories : [SELECT Id, Name FROM Territory2]) {
            for (Territory2 terr : territories) {
                territoryNames.put(terr.Id, terr.Name);
            }
        }
    }

    public static void recallApproval(List<Id> recordIds, String comments) {
        List<Id> processInstanceWorkitemIds = new List<Id>();

        List<ProcessInstance> processInstanceList = [
                SELECT Id, TargetObject.Name, TargetObjectID, TargetObject.Type, Status, CreatedDate, (SELECT Id, CreatedDate, CreatedById, Actor.Name, Actor.Id, OriginalActor.Id, OriginalActor.Name FROM WorkItems ORDER BY CreatedDate DESC), (SELECT id, Actor.Name, CreatedDate, Comments, StepStatus, OriginalActor.Id, OriginalActor.Name FROM Steps ORDER BY CreatedDate DESC)
                FROM ProcessInstance
                WHERE TargetObject.Id IN :recordIds
                ORDER BY CreatedDate DESC
        ];

        for (ProcessInstance pi : processInstanceList) {
            if (pi.Workitems != null && pi.Workitems.size() != 0) {
                for (ProcessInstanceWorkitem piw : pi.Workitems) {
                    processInstanceWorkitemIds.add(piw.Id); //Only one item can be in pending status.
                }
            }
        }
        List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();

        for (Id processInstanceWorkitemId : processInstanceWorkitemIds) {
            Approval.ProcessWorkitemRequest request = new Approval.ProcessWorkitemRequest();
            request.setComments(comments);
            request.setAction('Removed');
            request.setWorkitemId(processInstanceWorkitemId);
            requests.add(request);
        }

        Approval.process(requests);
    }

    public static void createBPSMailbox() {
        insert new EMS_Email_Boxes__c(Name = 'BPS', Main_Address__c = 'email@test.com');
    }
}