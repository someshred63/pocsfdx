public class SPCM_UserBusinessRoleUtils {
    public static Set<String> permissionSetsForLvl2Approver = new Set<String>{
        'C-Ops Channel Manager',
        'C-Ops Payer Manager',
        'C-Ops Senior Payer Contract Manager',
        'C-Ops Senior Channel Contract Manager'
    };
    
    public static Set<String> permissionSetsForLvl3Approver = new Set<String> {
    	'C-Ops Group Channel Manager',
    	'C-Ops Group Payer Manager'
    };
    
    public static Set<Id> getUserIdsFromUserBusinessRoles(List<User_Business_Role_gne__c> records) {
        Set<Id> userIds = new Set<Id>();
        for (User_Business_Role_gne__c ubr : records) {
            if (permissionSetsForLvl2Approver.contains(ubr.Business_Role_gne__c)) {
                userIds.add(ubr.User_gne__c);
            }
        }
        return userIds;
    }
    
    public static Set<Id> getUserIdsFromUserBusinessRolesForLevel3(List<User_Business_Role_gne__c> records) {
        Set<Id> userIds = new Set<Id>();
        for (User_Business_Role_gne__c ubr : records) {
            if (permissionSetsForLvl3Approver.contains(ubr.Business_Role_gne__c)) {
                userIds.add(ubr.User_gne__c);
            }
        }
        return userIds;
    }
    
    private static void handleAfterInsertUpdateForLevel2(List<User_Business_Role_gne__c> records) {
    	List<SPCM_Level_2_Approver__c> level2ApproversToUpsert = new List<SPCM_Level_2_Approver__c>();
        Set<Id> userIds = getUserIdsFromUserBusinessRoles(records);
        if (!userIds.isEmpty()) {
	        List<SPCM_Level_2_Approver__c> existingApprovers = [SELECT Id, Name, User__c, User_Business_Role__c FROM SPCM_Level_2_Approver__c WHERE User__c IN :userIds];
	        Map<Id,SPCM_Level_2_Approver__c> userIdToExistingLevel2Approver = new Map<Id,SPCM_Level_2_Approver__c> ();
	        for (SPCM_Level_2_Approver__c lvl2Approver : existingApprovers) {
	            userIdToExistingLevel2Approver.put(lvl2Approver.User__c, lvl2Approver);
	        }
	        
	        Map<Id,String> userBusinessRoles = new Map<Id,String> ();
	        Map<Id,String> userToUserName = new Map<Id,String> ();
	        for (User_Business_Role_gne__c ubr : [SELECT Business_Role_gne__c, User_gne__c, User_gne__r.FirstName, User_gne__r.LastName FROM User_Business_Role_gne__c WHERE User_gne__c IN :userIds AND Business_Role_gne__c IN :permissionSetsForLvl2Approver]) {
	            if (userBusinessRoles.containsKey(ubr.User_gne__c)) {
	                userBusinessRoles.put(ubr.User_gne__c, userBusinessRoles.get(ubr.User_gne__c) + ', ' + ubr.Business_Role_gne__c);
	            } else {
	                userBusinessRoles.put(ubr.User_gne__c, ubr.Business_Role_gne__c);
	            }
	            userToUserName.put(ubr.User_gne__c, ubr.User_gne__r.FirstName + ' ' + ubr.User_gne__r.LastName);
	        }
	        for (User_Business_Role_gne__c ubr : records) {
	            if (userIdToExistingLevel2Approver.containsKey(ubr.User_gne__c)) {
	                userIdToExistingLevel2Approver.get(ubr.User_gne__c).User_Business_Role__c = userBusinessRoles.get(ubr.User_gne__c);
	                userIdToExistingLevel2Approver.get(ubr.User_gne__c).Is_Active__c = true;
	                level2ApproversToUpsert.add(userIdToExistingLevel2Approver.get(ubr.User_gne__c));
	            } else {
	                level2ApproversToUpsert.add(new SPCM_Level_2_Approver__c(Name = userToUserName.get(ubr.User_gne__c), Is_Active__c = True, User__c = ubr.User_gne__c, User_Business_Role__c = ubr.Business_Role_gne__c));
	            }
	        }
	        upsert level2ApproversToUpsert;
	    }
    }
    
    private static void handleAfterInsertUpdateForLevel3(List<User_Business_Role_gne__c> records) {
    	List<SPCM_Level_3_Approver__c> level3ApproversToUpsert = new List<SPCM_Level_3_Approver__c>();
        Set<Id> userIds = getUserIdsFromUserBusinessRolesForLevel3(records);
        if (!userIds.isEmpty()) {
	        List<SPCM_Level_3_Approver__c> existingApprovers = [SELECT Id, Name, User__c, User_Business_Role__c FROM SPCM_Level_3_Approver__c WHERE User__c IN :userIds];
	        Map<Id,SPCM_Level_3_Approver__c> userIdToExistingLevel3Approver = new Map<Id,SPCM_Level_3_Approver__c> ();
	        for (SPCM_Level_3_Approver__c lvl3Approver : existingApprovers) {
	            userIdToExistingLevel3Approver.put(lvl3Approver.User__c, lvl3Approver);
	        }
	        
	        Map<Id,String> userBusinessRoles = new Map<Id,String> ();
	        Map<Id,String> userToUserName = new Map<Id,String> ();
	        for (User_Business_Role_gne__c ubr : [SELECT Business_Role_gne__c, User_gne__c, User_gne__r.FirstName, User_gne__r.LastName FROM User_Business_Role_gne__c WHERE User_gne__c IN :userIds AND Business_Role_gne__c IN :permissionSetsForLvl3Approver]) {
	            if (userBusinessRoles.containsKey(ubr.User_gne__c)) {
	                userBusinessRoles.put(ubr.User_gne__c, userBusinessRoles.get(ubr.User_gne__c) + ', ' + ubr.Business_Role_gne__c);
	            } else {
	                userBusinessRoles.put(ubr.User_gne__c, ubr.Business_Role_gne__c);
	            }
	            userToUserName.put(ubr.User_gne__c, ubr.User_gne__r.FirstName + ' ' + ubr.User_gne__r.LastName);
	        }
	        for (User_Business_Role_gne__c ubr : records) {
	            if (userIdToExistingLevel3Approver.containsKey(ubr.User_gne__c)) {
	                userIdToExistingLevel3Approver.get(ubr.User_gne__c).User_Business_Role__c = userBusinessRoles.get(ubr.User_gne__c);
	                userIdToExistingLevel3Approver.get(ubr.User_gne__c).Is_Active__c = true;
	                level3ApproversToUpsert.add(userIdToExistingLevel3Approver.get(ubr.User_gne__c));
	            } else {
	                level3ApproversToUpsert.add(new SPCM_Level_3_Approver__c(Name = userToUserName.get(ubr.User_gne__c), Is_Active__c = True, User__c = ubr.User_gne__c, User_Business_Role__c = ubr.Business_Role_gne__c));
	            }
	        }
	        upsert level3ApproversToUpsert;
	    }
    }
    
    public static void handleAfterInsertUpdate(List<User_Business_Role_gne__c> records) {
     	handleAfterInsertUpdateForLevel2(records);
     	handleAfterInsertUpdateForLevel3(records);   
    }
    
    public static void handleBeforeDeleteForLevel2(List<User_Business_Role_gne__c> records) {
    	 Set<Id> userIds = getUserIdsFromUserBusinessRoles(records);
        Set<Id> recordsToDelete = (new Map<Id,User_Business_Role_gne__c>(records)).keySet();
        List<SPCM_Level_2_Approver__c> level2ApproversToUpsert = new List<SPCM_Level_2_Approver__c>();
        if (!userIds.isEmpty()) {
            List<SPCM_Level_2_Approver__c> existingApprovers = [SELECT Id, Name, User__c, User_Business_Role__c FROM SPCM_Level_2_Approver__c WHERE User__c IN :userIds];
            Map<Id,SPCM_Level_2_Approver__c> userIdToExistingLevel2Approver = new Map<Id,SPCM_Level_2_Approver__c> ();
            for (SPCM_Level_2_Approver__c lvl2Approver : existingApprovers) {
                userIdToExistingLevel2Approver.put(lvl2Approver.User__c, lvl2Approver);
            }
            Map<Id,String> userBusinessRoles = new Map<Id,String> ();
            for (User_Business_Role_gne__c ubr : [SELECT Id,Business_Role_gne__c, User_gne__c, User_gne__r.FirstName, User_gne__r.LastName FROM User_Business_Role_gne__c WHERE User_gne__c IN :userIds AND Business_Role_gne__c IN :permissionSetsForLvl2Approver]) {
                if (recordsToDelete.contains(ubr.Id)) {
                    continue;
                }
                if (userBusinessRoles.containsKey(ubr.User_gne__c)) {
                    userBusinessRoles.put(ubr.User_gne__c, userBusinessRoles.get(ubr.User_gne__c) + ', ' + ubr.Business_Role_gne__c);
                } else {
                    userBusinessRoles.put(ubr.User_gne__c, ubr.Business_Role_gne__c);
                }
            }
            for (User_Business_Role_gne__c ubr : records) {
                if (userIdToExistingLevel2Approver.containsKey(ubr.User_gne__c)) {
                    String role = userBusinessRoles.containsKey(ubr.User_gne__c) ? userBusinessRoles.get(ubr.User_gne__c) : '';
                    userIdToExistingLevel2Approver.get(ubr.User_gne__c).User_Business_Role__c = role;
                    if (String.isBlank(role)) {
                        userIdToExistingLevel2Approver.get(ubr.User_gne__c).Is_Active__c = false;
                    }
                    level2ApproversToUpsert.add(userIdToExistingLevel2Approver.get(ubr.User_gne__c));
                }
            }
            update level2ApproversToUpsert;
        }
    }
    
    public static void handleBeforeDeleteForLevel3(List<User_Business_Role_gne__c> records) {
    	Set<Id> userIds = getUserIdsFromUserBusinessRolesForLevel3(records);
        Set<Id> recordsToDelete = (new Map<Id,User_Business_Role_gne__c>(records)).keySet();
        List<SPCM_Level_3_Approver__c> level3ApproversToUpsert = new List<SPCM_Level_3_Approver__c>();
        if (!userIds.isEmpty()) {
            List<SPCM_Level_3_Approver__c> existingApprovers = [SELECT Id, Name, User__c, User_Business_Role__c FROM SPCM_Level_3_Approver__c WHERE User__c IN :userIds];
            Map<Id,SPCM_Level_3_Approver__c> userIdToExistingLevel3Approver = new Map<Id,SPCM_Level_3_Approver__c> ();
            for (SPCM_Level_3_Approver__c lvl3Approver : existingApprovers) {
                userIdToExistingLevel3Approver.put(lvl3Approver.User__c, lvl3Approver);
            }
            Map<Id,String> userBusinessRoles = new Map<Id,String> ();
            for (User_Business_Role_gne__c ubr : [SELECT Id,Business_Role_gne__c, User_gne__c, User_gne__r.FirstName, User_gne__r.LastName FROM User_Business_Role_gne__c WHERE User_gne__c IN :userIds AND Business_Role_gne__c IN :permissionSetsForLvl3Approver]) {
                if (recordsToDelete.contains(ubr.Id)) {
                    continue;
                }
                if (userBusinessRoles.containsKey(ubr.User_gne__c)) {
                    userBusinessRoles.put(ubr.User_gne__c, userBusinessRoles.get(ubr.User_gne__c) + ', ' + ubr.Business_Role_gne__c);
                } else {
                    userBusinessRoles.put(ubr.User_gne__c, ubr.Business_Role_gne__c);
                }
            }
            for (User_Business_Role_gne__c ubr : records) {
                if (userIdToExistingLevel3Approver.containsKey(ubr.User_gne__c)) {
                    String role = userBusinessRoles.containsKey(ubr.User_gne__c) ? userBusinessRoles.get(ubr.User_gne__c) : '';
                    userIdToExistingLevel3Approver.get(ubr.User_gne__c).User_Business_Role__c = role;
                    if (String.isBlank(role)) {
                        userIdToExistingLevel3Approver.get(ubr.User_gne__c).Is_Active__c = false;
                    }
                    Level3ApproversToUpsert.add(userIdToExistingLevel3Approver.get(ubr.User_gne__c));
                }
            }
            update Level3ApproversToUpsert;
        }
    }
    
    public static void handleBeforeDelete(List<User_Business_Role_gne__c> records) {
    	handleBeforeDeleteForLevel2(records);
    	handleBeforeDeleteForLevel3(records);
    }
}