public with sharing class EDM_Deactivate_Utils {
    
    private static String edmDontDeactUsersWithThesePs = [SELECT Configuration_Value_gne__c FROM GNE_Foun_Misc_Config_Items_gne__c Where Name = 'EDM_Dont_Deact_Users_With_These_Ps' Limit 1].Configuration_Value_gne__c;
    private static Set<String> permissionSetsForAbsApproversSet =
            String.isNotBlank(edmDontDeactUsersWithThesePs) ?
                    new Set<String>(edmDontDeactUsersWithThesePs.split(',')) :
                    new Set<String>();

    public static String getAbsApproversIdsToNotDeactivate() {
        List<String> absApproversIds = new List<String>();
        for(PermissionSetAssignment psa : [
                SELECT AssigneeId
                FROM PermissionSetAssignment
                WHERE Assignee.IsActive = true
                AND PermissionSet.Name IN :permissionSetsForAbsApproversSet]) {
            absApproversIds.add('\''+psa.AssigneeId+'\'');
        }
        return String.join(absApproversIds,',') ;
    }

}