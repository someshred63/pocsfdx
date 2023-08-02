public class GNE_FCR_DAO {

    public static final Integer MAX_RECORD_COUNT = Integer.valueOf(Utilities.getGlobalVariable('GNE_FCR_History_Records_Limit'));

    public static List<Territory2> getUserChildTerritories(Id userId) {
        return [SELECT Id FROM Territory2 WHERE ParentTerritory2Id IN (SELECT Territory2Id FROM UserTerritory2Association WHERE UserId = :userId)];
    }

    public static Boolean isUserAssignedToTerritory(Id userId) {
        List<UserTerritory2Association>userTerritories = getUserTerritories(userId);
        return !userTerritories.isEmpty();
    }

    private static List<UserTerritory2Association> getUserTerritories(String userId) {
        return [SELECT Territory2Id FROM UserTerritory2Association WHERE IsActive = TRUE AND UserId = :userId];
    }

    public static List<Territory2> getTerritories(List<String> territoriesIds) {
        return [SELECT Id, Name, Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c FROM Territory2 WHERE Id IN :territoriesIds ORDER BY Name];
    }

    public static List<Territory2> getTerritories(String userId) {
        List<UserTerritory2Association> userTerritories = getUserTerritories(userId);
        if (userTerritories.isEmpty()) {
            return new List<Territory2>();
        } else {
            List<String> userTerritoryIds = GNE_FCR_Util.buildStringList(userTerritories, 'Territory2Id');
            return getTerritories(userTerritoryIds);
        }
    }

    public static List<FCR_PTP_Summary_gne__c>getPerformance(Id fcrId) {
        return [
                SELECT Id, Name, Division_Product1_gne__c, Division_Product2_gne__c, Division_Product3_gne__c, Geography_Product1_gne__c, Geography_Product2_gne__c,
                        Geography_Product3_gne__c, Nation_Product1_gne__c, Nation_Product2_gne__c, Nation_Product3_gne__c, Notes_gne__c, Region_Product1_gne__c,
                        Region_Product2_gne__c, Region_Product3_gne__c, Territory_Product1_gne__c, Territory_Product2_gne__c, Territory_Product3_gne__c
                FROM FCR_PTP_Summary_gne__c
                WHERE FCR_Days_Plan_gne__c = :fcrId
        ];
    }

    public static List<AP_Account_User_gne__c>getAvailableAccounts(Id userId) {
        return [SELECT Id, Name, Account_CSUser_gne__c, CS_User_gne__c, AP_Account_gne__r.Name, AP_Account_gne__r.OrgId_gne__c, AP_Account_gne__r.Address_gne__c, AP_Account_gne__c FROM AP_Account_User_gne__c WHERE CS_User_gne__c = :userId ORDER BY AP_Account_gne__r.Name LIMIT 100];
    }

    public static List<FCR_Days_Plan_gne__c> getUserFCRs(Id userId) {
        String archivedStatus = GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_ARCHIVED_STATUS);
        String newStatus = GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_NEW_STATUS);
        String updatedStatus = GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_AWAITING_UPDATE_STATUS);

        String query = 'SELECT Id, Name, Information_Backup_gne__c, Previous_Action_Plan_CS_Comments__c, DM_Action_Plan__c, GPM_Objective_Comments_gne__c, Other_Accounts_gne__c, ' +
                'CreatedById, CreatedDate, DM_Comments_gne__c, Version_gne__c, Franchise_Obj_fcr__c, Territory_gne__c, Territory_Name_gne__c, Job_Competency_gne__c, ' +
                'CS_User_gne__c, CS_User_gne__r.Name, Date_Field_Visit_gne__c, DM_User_gne__c, DM_User_Name_gne__c, Field_Objectives_gne__c, LastModifiedById, ' +
                'LastModifiedDate, OwnerId, Action_gne__c, Status_Action_Key__c, Status_gne__c, Summary_Comments_gne__c, GPM_Objective_gne__c, FR_User_gne__c, ' +
                'FR_User_gne__r.Name ' +
                'FROM FCR_Days_Plan_gne__c WHERE ';

        String whereCondition;
        List<Integer> versions = null;
        if (GNE_FCR_Util.getIsFE()) {
            versions = GNE_FCR_Util.getSupportedFCRVersions(userId);
            whereCondition = 'Version_gne__c IN :versions AND ';
            whereCondition += 'CS_User_gne__c =: userId AND Status_gne__c != :archivedStatus ORDER BY Date_Field_Visit_gne__c desc';
        } else if (GNE_FCR_Util.getIsFR()) {
            versions = GNE_FCR_Util.getAvailableFCRVersions();
            whereCondition = 'Version_gne__c IN :versions AND ';
            whereCondition += 'FR_User_gne__c =: userId AND Status_gne__c != :newStatus AND Status_gne__c != :updatedStatus AND Status_gne__c != :archivedStatus ORDER BY Date_Field_Visit_gne__c desc';
        } else {
            versions = new List<Integer>{
                    GNE_FCR_Util.getFCRWorkingVersion(userId)
            };
            whereCondition = 'Version_gne__c IN :versions AND ';
            whereCondition += 'Status_gne__c != :archivedStatus ORDER BY Date_Field_Visit_gne__c desc limit :MAX_RECORD_COUNT';
        }
        return Database.query(query + whereCondition);
    }

    public static FCR_Days_Plan_gne__c getFCR(Id fcrId) {
        return [
                SELECT Id, Name, Information_Backup_gne__c, Previous_Action_Plan_CS_Comments__c, DM_Action_Plan__c, Territory_gne__c, Territory_Name_gne__c, CS_User_gne__r.Name,
                        Other_Accounts_gne__c, CreatedById, CreatedDate, DM_Comments_gne__c, Version_gne__c, Franchise_Obj_fcr__c, Franchise_Objective_gne__r.Franchise_gne__c, CS_User_gne__c,
                        Date_Field_Visit_gne__c, DM_User_gne__c, DM_User_Name_gne__c, Field_Objectives_gne__c, LastModifiedById, LastModifiedDate, OwnerId, Job_Competency_gne__c, Performance_gne__c,
                        Action_gne__c, Status_Action_Key__c, Status_gne__c, Summary_Comments_gne__c, FR_User_gne__c, GPM_Objective_gne__c, Previous_Action_Plan_gne__c, GPM_Objective_Comments_gne__c,
                        Job_Competency_Comments_gne__c, CheckInComment_gne__c, Development_gne__c
                FROM FCR_Days_Plan_gne__c
                WHERE Id = :fcrId
        ];
    }

    public static FCR_Days_Plan_gne__c getPreviousActionPlan(Id userId) {
        String completedStatus = GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_COMPLETED_STATUS);
        String archivedStatus = GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_ARCHIVED_STATUS);

        List<Integer> availableVersions = GNE_FCR_Util.getAvailableFCRVersions();

        List<FCR_Days_Plan_gne__c> previousPlans = [
                SELECT Id, Name, Summary_Comments_gne__c, CheckInComment_gne__c, Development_gne__c, (SELECT Description_gne__c, Name, Order_gne__c, Status_gne__c, Title_gne__c FROM GNE_FCR_Action_Item__r ORDER BY Order_gne__c LIMIT 3)
                FROM FCR_Days_Plan_gne__c
                WHERE CS_User_gne__c = :userId AND (Status_gne__c = :completedStatus OR Status_gne__c = :archivedStatus) AND Version_gne__c IN :availableVersions
                ORDER BY Date_Field_Visit_gne__c DESC
                LIMIT 1
        ];
        if (!previousPlans.isEmpty()) {
            return previousPlans.get(0);
        }
        return null;
    }

    public static FCR_Days_Plan_gne__c getPreviousDaysPlan(Id fcrId) {
        return [
                SELECT Id, Name, Summary_Comments_gne__c, (SELECT Description_gne__c, Name, Order_gne__c, Status_gne__c, Title_gne__c FROM GNE_FCR_Action_Item__r ORDER BY Order_gne__c LIMIT 3)
                FROM FCR_Days_Plan_gne__c
                WHERE Id = :fcrId
        ];
    }

    public static Franchise_Objective_gne__c getFranchiseObjective(String salesforceCode, String subTeamCode) {
        List<Franchise_gne__c>franchises = [SELECT Id FROM Franchise_gne__c WHERE Parent_gne__r.Code_gne__c = :salesforceCode AND Code_gne__c = :subTeamCode];
        Franchise_Objective_gne__c result = null;
        if (!franchises.isEmpty()) {
            result = getFranchiseObjective(franchises.get(0).Id);
        } else {
            franchises = [SELECT Id FROM Franchise_gne__c WHERE Code_gne__c = :salesforceCode];
            if (!franchises.isEmpty()) {
                result = getFranchiseObjective(franchises.get(0).Id);
            }
        }
        return result;
    }

    public static Franchise_Objective_gne__c getFranchiseObjective(Id franchiseId) {
        Franchise_Objective_gne__c result = null;
        List<Franchise_Objective_gne__c> tmp = [
                SELECT Name, Objective_gne__c, Franchise_gne__r.Name
                FROM Franchise_Objective_gne__c
                WHERE Franchise_gne__c = :franchiseId
                ORDER BY LastModifiedDate DESC
                LIMIT 1
        ];
        if (!tmp.isEmpty()) {
            result = tmp.get(0);
        }
        return result;
    }

    public static List<User> getAvailableFRs(Id user) {
        Map<Id, User>userMap = new Map<Id, User>([SELECT LastName, Id, Name, Profile_Name_gne__c FROM User WHERE IsActive = TRUE AND Profile_Name_gne__c LIKE 'GNE-SFA-%' AND (NOT Profile_Name_gne__c LIKE 'GNE-SFA-%-CS') AND (NOT Profile_Name_gne__c LIKE 'GNE-SFA%PS') AND (NOT Profile_Name_gne__c LIKE 'GNE-SFA%Specialist')]);

        Map<Id, Set<Id>>territoryToUsers = new Map<Id, Set<Id>>();
        Set<Id>usersWithTerritory = new Set<Id>();

        for (UserTerritory2Association ut : [SELECT Id, Territory2Id, UserId FROM UserTerritory2Association WHERE UserId IN :userMap.keySet()]) {
            usersWithTerritory.add(ut.UserId);
            if (!territoryToUsers.containsKey(ut.Territory2Id)) {
                territoryToUsers.put(ut.Territory2Id, new Set<Id>());
            }
            territoryToUsers.get(ut.Territory2Id).add(ut.UserId);
        }

        Set<User>result = new Set<User>();
        for (Territory2 terr : [SELECT Id, ParentTerritory2Id FROM Territory2 WHERE ParentTerritory2Id IN :territoryToUsers.keySet()]) {
            for (Id userId : territoryToUsers.get(terr.ParentTerritory2Id)) {
                result.add(userMap.get(userId));
            }
        }
        Set<Id>userIds = new Set<Id>(userMap.keySet());
        userIds.removeAll(usersWithTerritory);

        for (Id userId : userIds) {
            result.add(userMap.get(userId));
        }

        List<User>sortedResult = new List<User>(result);
        sortedResult.sort();
        return sortedResult;
    }

    public static List<FCR_Days_Plan_Account_gne__c>getFcrAccounts(Id daysPlanId) {
        return [SELECT Id, Account_gne__c, AP_Account_gne__c, AP_Account_gne__r.Name, AP_Account_gne__r.Address_gne__c, Territory_gne__c, Notes_gne__c FROM FCR_Days_Plan_Account_gne__c WHERE FCR_Days_Plan_gne__c = :daysPlanId];
    }

    public static List<FCR_Days_Objective_gne__c>getFcrDaysObjectives(Id daysPlanId) {
        return [SELECT Id, Objective_gne__c, Objective_Date_gne__c FROM FCR_Days_Objective_gne__c WHERE FCR_Days_Plan_gne__c = :daysPlanId];
    }

    public static List<FCR_Daysplan_Job_Accountability_gne__c>getFcrJobAccountabilities(Id daysPlanId) {
        return [SELECT Id, FCR_Days_Plan_gne__c, Job_Accountability_Description_fcr__c, Job_Accountability_gne__c, Job_Accountability_Title_fcr__c, Rating_gne__c, Comment_gne__c FROM FCR_Daysplan_Job_Accountability_gne__c WHERE FCR_Days_Plan_gne__c = :daysPlanId ORDER BY Display_Order_fcr__c];
    }

    public static List<FCR_DaysPlan_Job_Competency_gne__c> getDaysPlanJobCompetency(Id daysPlanId) {
        return [
                SELECT Id, Name, Assess_Comments_gne__c, Assess_Gather_Insights_gne__c, Assess_Identifying_Shifts_gne__c, Assess_Strategic_Account_Planning_gne__c, Clarify_Check_Assumptions_gne__c, Clarify_Comments_gne__c, Clarify_Effective_Probing_gne__c, Clarify_Reflective_Listening_gne__c, Execute_Aligning_Information_gne__c, Execute_Closing_gne__c, Execute_Comments_gne__c, Execute_Objection_Handling_gne__c
                FROM FCR_DaysPlan_Job_Competency_gne__c
                WHERE FCR_Days_Plan_gne__c = :daysPlanId
                ORDER BY LastModifiedDate DESC
        ];
    }

    public static List<Product_vod__c>getUserBrands(Id userId) {
        List<My_Setup_Products_vod__c>setupProducts = [
                SELECT Product_vod__c
                FROM My_Setup_Products_vod__c
                WHERE OwnerId = :userId
                AND Product_vod__c IN (SELECT Id FROM Product_vod__c WHERE Product_Type_vod__c = 'Detail')
        ];
        Set<Id>productIds = new Set<Id>();
        for (My_Setup_Products_vod__c setupProduct : setupProducts) {
            productIds.add(setupProduct.Product_vod__c);
        }
        return [SELECT Id, Name FROM Product_vod__c WHERE Id IN :productIds];
    }

    public static List<FCR_PTP_gne__c>getPTP(Id fcrId) {
        return [SELECT Id, Division_Month_gne__c, Division_Quarter_gne__c, Division_Year_gne__c, Franchise_Month_gne__c, Franchise_Quarter_gne__c, Franchise_Year_gne__c, Product_gne__c, Region_Month_gne__c, Region_Quarter_gne__c, Region_Year_gne__c, Territory_Month_gne__c, Territory_Quarter_gne__c, Territory_Year_gne__c FROM FCR_PTP_gne__c WHERE FCR_Days_Plan_gne__c = :fcrId];
    }
}