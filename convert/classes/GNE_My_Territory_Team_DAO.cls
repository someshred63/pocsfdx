public class GNE_My_Territory_Team_DAO {
    public static List<My_Territory_Team_gne__c> getVisibleTerritoryTeamByTerritory(String territoryNumber) {
        return [
            SELECT 
                Id, Is_User_Active_calc_gne__c, Territory_Number_gne__c, User_Business_Role_calc_gne__c, User_First_Name_calc_gne__c, isManuallyRemoved_gne__c,
                User_Last_Name_calc_gne__c, User_Profile_calc_gne__c, User_Unix_ID_calc_gne__c, UserId_gne__c, OwnerId, isManualAdded_gne__c, Common_Terriotires_gne__c,
                Unix_User_Id_gne__c
            FROM 
                My_Territory_Team_gne__c
            WHERE 
                Territory_Number_gne__c = : territoryNumber
            AND
                isManuallyRemoved_gne__c = false    
        ];
    }
    public static List<My_Territory_Team_gne__c> getTerritoryTeamByTerritory(String territoryNumber) {
        return [
            SELECT 
                Id, Is_User_Active_calc_gne__c, Territory_Number_gne__c, User_Business_Role_calc_gne__c, User_First_Name_calc_gne__c, isManuallyRemoved_gne__c,
                User_Last_Name_calc_gne__c, User_Profile_calc_gne__c, User_Unix_ID_calc_gne__c, UserId_gne__c, OwnerId, isManualAdded_gne__c, Common_Terriotires_gne__c,
                Unix_User_Id_gne__c
            FROM 
                My_Territory_Team_gne__c
            WHERE 
                Territory_Number_gne__c = : territoryNumber
        ];
    }
    
    public static List<My_Territory_Team_gne__c> getTerritoryTeamByUserId(String userId) {
        return [
            SELECT 
                Id, Is_User_Active_calc_gne__c, Territory_Number_gne__c, User_Business_Role_calc_gne__c, User_First_Name_calc_gne__c, isManuallyRemoved_gne__c,
                User_Last_Name_calc_gne__c, User_Profile_calc_gne__c, User_Unix_ID_calc_gne__c, UserId_gne__c, OwnerId, isManualAdded_gne__c, Common_Terriotires_gne__c,
                Unix_User_Id_gne__c
            FROM 
                My_Territory_Team_gne__c
            WHERE 
                UserId_gne__c = : userId
        ];
    }
    
    public static List<My_Territory_Team_gne__c> getTerritoryTeamByTerritoryAndUnixId(String territoryNumber, String unixId) {
        return [
            SELECT 
                Id, Is_User_Active_calc_gne__c, Territory_Number_gne__c, User_Business_Role_calc_gne__c, User_First_Name_calc_gne__c, isManuallyRemoved_gne__c,
                User_Last_Name_calc_gne__c, User_Profile_calc_gne__c, User_Unix_ID_calc_gne__c, UserId_gne__c, OwnerId, isManualAdded_gne__c, Common_Terriotires_gne__c,
                Unix_User_Id_gne__c
            FROM 
                My_Territory_Team_gne__c
            WHERE 
                Territory_Number_gne__c = : territoryNumber
            AND (Unix_User_Id_gne__c = :unixId OR User_Unix_ID_calc_gne__c = :unixId)
        ];
    }
    
    public static List<My_Territory_Team_gne__c> getTerritoryTeamByTerritoryAndUserId(String territoryNumber, String userId) {
        return [
            SELECT 
                Id, Is_User_Active_calc_gne__c, Territory_Number_gne__c, User_Business_Role_calc_gne__c, User_First_Name_calc_gne__c, isManuallyRemoved_gne__c,
                User_Last_Name_calc_gne__c, User_Profile_calc_gne__c, User_Unix_ID_calc_gne__c, UserId_gne__c, OwnerId, isManualAdded_gne__c, Common_Terriotires_gne__c,
                Unix_User_Id_gne__c
            FROM 
                My_Territory_Team_gne__c
            WHERE 
                Territory_Number_gne__c = : territoryNumber
            AND UserId_gne__c = :userId
        ];
    }
    
    public static My_Territory_Team_gne__c getById(String recordId) {
        return [
            SELECT 
                Id, Is_User_Active_calc_gne__c, Territory_Number_gne__c, User_Business_Role_calc_gne__c, User_First_Name_calc_gne__c, isManuallyRemoved_gne__c,
                User_Last_Name_calc_gne__c, User_Profile_calc_gne__c, User_Unix_ID_calc_gne__c, UserId_gne__c, OwnerId, isManualAdded_gne__c, Common_Terriotires_gne__c
            FROM 
                My_Territory_Team_gne__c
            WHERE Id = : recordId
        ];
    }
    
    public static iPhone_Commons_gne.AlterDataResponse setVisibility(String recordId) {
        My_Territory_Team_gne__c mtt = getById(recordId);
        mtt.isManuallyRemoved_gne__c = !mtt.isManuallyRemoved_gne__c;
        iPhone_Commons_gne.AlterDataResponse result; 
        try {
            update mtt;
            result = new iPhone_Commons_gne.AlterDataResponse(recordId);
        } catch (Exception ex){
            result = new iPhone_Commons_gne.AlterDataResponse(ex);
        }
        return result;
    }
}