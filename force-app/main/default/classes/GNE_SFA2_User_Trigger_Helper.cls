/************************************************************
*  @author: Michal Hrycenko, Roche
*  Date: 2015-07-16
*  Description: Helper class for GNE_SFA2_User_Trigger
*  Test class: GNE_SFA2_User_Trigger_Test
*  
*  Modification History
*  Date        Name        Description
*  2016-10-20 kozminsl    Fix problems with deleteting users from group and to not create duplicates on insert. Add profiles ecluded from assigning groups.
*  2017-05-22 lanieckj    Fix problem when we remove group and don't add the same (ex: change profile form IFRM to BFRM)
*            
*************************************************************/

public without sharing class GNE_SFA2_User_Trigger_Helper {

    private static final Set<String> excludedProfiles = new Set<String>{'GNE-SYS-No-Access'};
    private static Map <String, Set<String>> profileName2mappedGroups;
	public static final String CAN_INFU_PROFILE_NAME = 'RCanada-SFA-INFU';
	private static Id canInfuProfileId;

	@future
	public static void assignUsersToGroups(String oldUsers, String newUsers, Boolean isUpdate) {
		Map<Id, User> triggerOldMap = String.isNotBlank(oldUsers) ? (Map<Id, User>)JSON.deserialize(oldUsers, Map<Id, User>.class) : null;
		List<User> triggerNew = String.isNotBlank(newUsers) ? (List<User>)JSON.deserialize(newUsers, List<User>.class) : null;

        Map<String, Set<String>> profilesMaskToGroupsMap = prepareProfilesMaskToGroupsMap();
        
        List<GroupMember> groupsMembersToDelete = triggerOldMap != null ? getGroupsMembersToDelete(triggerOldMap, triggerNew, profilesMaskToGroupsMap) : new List<GroupMember>();
        List<GroupMember> groupsMembersToInsert = getGroupsMembersToInsert(triggerNew, profilesMaskToGroupsMap);
        
        if(!groupsMembersToDelete.isEmpty()) {
            delete groupsMembersToDelete;
        }

        if(!groupsMembersToInsert.isEmpty()) {
            insert groupsMembersToInsert;
        }
	}

    public static List<GroupMember> getGroupsMembersToInsert(List<User> triggerNew, Map<String, Set<String>> profilesMaskToGroupsMap) {
		List<GroupMember> result = new List<GroupMember>();
		Map<String, Id> groupsIdsMap = getGroupsIdsMap(profilesMaskToGroupsMap);

        List<Id> userIds = new List<Id>();  
        for(User u : triggerNew){
            userIds.add(u.Id);
        }
        
        Map<Id, Set<Id>> usersGroupsMap = getUsersGroups(userIds);        

		for(User u : triggerNew) {
			for(String pm : profilesMaskToGroupsMap.keySet()) {
                if(!excludedProfiles.contains(u.Profile_Name_gne__c) && u.Profile_Name_gne__c.toUpperCase().startsWith(pm.toUpperCase())) {
					for(String groupName : profilesMaskToGroupsMap.get(pm)) {
                        if(groupsIdsMap.containsKey(groupName) && (usersGroupsMap.get(u.Id) == null || !usersGroupsMap.get(u.Id).contains(groupsIdsMap.get(groupName)))) {
							GroupMember groupMember = new GroupMember(
								UserOrGroupId = u.Id,
								GroupId = groupsIdsMap.get(groupName)
							);
							result.add(groupMember);
						}
					}
				}
			}
		}

		return result; 
	}

    public static List<GroupMember> getGroupsMembersToInsert(List<User> triggerNew) {
        return getGroupsMembersToInsert(triggerNew, prepareProfilesMaskToGroupsMap()); 
    }
    
    public static List<GroupMember> getGroupsMembersToDelete(Map<Id, User> triggerOld, List<User> triggerNew, Map<String, Set<String>> profilesMaskToGroupsMap) {
		List<GroupMember> result = new List<GroupMember>();
        Map<Id, User> newUsersMap = new Map<Id, User>();
        
		List<Id> usersIdsWhichChangeProfile = new List<Id>();
        Map<Id, List<GroupMember>> userId2groupsMembers = new Map<Id, List<GroupMember>>();

		for(User u : triggerNew) {
            if(u.Profile_Name_gne__c != triggerOld.get(u.Id).Profile_Name_gne__c) {
				usersIdsWhichChangeProfile.add(u.Id);
                newUsersMap.put(u.Id,u);
			}
		}

		if(!usersIdsWhichChangeProfile.isEmpty()) {
            userId2groupsMembers = getGroupsMembersMap(usersIdsWhichChangeProfile);
		}

        if(!userId2groupsMembers.isEmpty()) {
            Set<Id> uniqueIds = new Set<Id>();
			for(Id uId : usersIdsWhichChangeProfile) {
				User u = triggerOld.get(uId);
                User newUser = newUsersMap.get(uId);
                profileName2mappedGroups = processProfileName(newUser.Profile_Name_gne__c.toUpperCase(), profilesMaskToGroupsMap);
                Set<String> mappedGroupsForNewProfile = profileName2mappedGroups.get(newUser.Profile_Name_gne__c.toUpperCase());
				for(String pm : profilesMaskToGroupsMap.keySet()) {
                    if(u.Profile_Name_gne__c.toUpperCase().startsWith(pm.toUpperCase()) && userId2groupsMembers.containsKey(u.Id)) {
							for(String groupName : profilesMaskToGroupsMap.get(pm)) {
                            for(GroupMember gm : userId2groupsMembers.get(u.Id)) {
                                if(gm.Group.DeveloperName == groupName && !mappedGroupsForNewProfile.contains(groupName) && uniqueIds.add(gm.Id)) {
										result.add(gm);
									}
								} 
							}
						}
					}
				}
			}

        return result;    
		}

    private static Map<String, Set<String>> processProfileName(String profileName, Map<String, Set<String>> profilesMaskToGroupsMap) {
        if (profileName2mappedGroups == null) {
            profileName2mappedGroups = new Map<String,Set<String>>();
        }
        if (!profileName2mappedGroups.containsKey(profileName)) {
            Set<String> groupNames = new Set<String>();
            for (String pm : profilesMaskToGroupsMap.keySet()) {
                if (profileName.startsWith(pm.toUpperCase())) {
                    groupNames.addAll(profilesMaskToGroupsMap.get(pm));
                }
            }
            profileName2mappedGroups.put(profileName, groupNames);
        }
        
        return profileName2mappedGroups;
	}

    public static List<GroupMember> getGroupsMembersToDelete(Map<Id, User> triggerOld, List<User> triggerNew) {
        return getGroupsMembersToDelete(triggerOld, triggerNew, prepareProfilesMaskToGroupsMap());
    }

	private static Map<String, Set<String>> prepareProfilesMaskToGroupsMap() {
		Map<String, Set<String>> result = new Map<String, Set<String>>();
		for(Profile_to_Group_Map_gne__c ptg : [SELECT Group_Name_gne__c, Profile_Mask_gne__c FROM Profile_to_Group_Map_gne__c]) {
			if(!result.containsKey(ptg.Profile_Mask_gne__c)) {
				result.put(ptg.Profile_Mask_gne__c, new Set<String>());
            } 
				result.get(ptg.Profile_Mask_gne__c).add(ptg.Group_Name_gne__c);
			}

		return result;
	}

	private static Map<String, Id> getGroupsIdsMap(Map<String, Set<String>> profilesMaskToGroupsMap) {
		Map<String, Id> result = new Map<String, Id>();
		Set<String> groupsNames = new Set<String>();
		for(String pm : profilesMaskToGroupsMap.keySet()) {
			groupsNames.addAll(profilesMaskToGroupsMap.get(pm));
		}

		for(Group g : [SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN : groupsNames]) {
			result.put(g.DeveloperName, g.Id);
		}

		return result;
	}

	private static Map<Id, List<GroupMember>> getGroupsMembersMap(List<Id> usersIds) {
		Map<Id, List<GroupMember>> result = new Map<Id, List<GroupMember>>();
		for(GroupMember gm : [SELECT Id, UserOrGroupId, Group.DeveloperName FROM GroupMember WHERE UserOrGroupId IN : usersIds]) {
			if(!result.containsKey(gm.UserOrGroupId)) {
				result.put(gm.UserOrGroupId, new List<GroupMember>());
            }
				result.get(gm.UserOrGroupId).add(gm);
			}
        return result;
		}

    /*
        Return userId to list of group ids map.
    */
    private static Map<Id, Set<Id>> getUsersGroups(List<Id> usersIds) {
        Map<Id, Set<Id>> result = new Map<Id, Set<Id>>();
        for(GroupMember gm : [SELECT UserOrGroupId, GroupId FROM GroupMember WHERE UserOrGroupId IN : usersIds]) {
            if(!result.containsKey(gm.UserOrGroupId)) {
                result.put(gm.UserOrGroupId, new Set<Id>());
            }
            result.get(gm.UserOrGroupId).add(gm.GroupId);
        }
		return result;
	}
	
	public static Id getCanInfuProfileId() {
		if (canInfuProfileId == null) {
			canInfuProfileId = [SELECT Id FROM Profile WHERE Name = :CAN_INFU_PROFILE_NAME LIMIT 1].Id;
		}

		return canInfuProfileId;
	}
}