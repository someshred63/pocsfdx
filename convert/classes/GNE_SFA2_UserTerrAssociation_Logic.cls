public without sharing class GNE_SFA2_UserTerrAssociation_Logic {
	
	public static void addMembersToGroup(List<UserTerritory2Association> terrAssociations) {
		List<Id> territoryIds = new List<Id>();
		for (UserTerritory2Association ua : terrAssociations) {
			territoryIds.add(ua.Territory2Id);
		}
		Map<Id, List<Territory_Group_Mapping_gne__c>> terrGroupMappingMap = new Map<Id, List<Territory_Group_Mapping_gne__c>>();
		for (Territory_Group_Mapping_gne__c mapping : [SELECT Group_Id_gne__c, Territory_Id_gne__c FROM Territory_Group_Mapping_gne__c WHERE Territory_Id_gne__c IN :territoryIds AND Type_gne__c = :GNE_SFA2_Territory2_Trigger_Logic.TERRITORY_GROUP_TYPE]) {
			if (!terrGroupMappingMap.containsKey(mapping.Territory_Id_gne__c)) {
				terrGroupMappingMap.put(mapping.Territory_Id_gne__c, new List<Territory_Group_Mapping_gne__c>());
			}
			terrGroupMappingMap.get(mapping.Territory_Id_gne__c).add(mapping);
		}
		List<GroupMember> groupMembersToInsert = new List<GroupMember>();
		for (UserTerritory2Association ua : terrAssociations) {
			if (terrGroupMappingMap.containsKey(ua.Territory2Id)) {
				for (Territory_Group_Mapping_gne__c mapping : terrGroupMappingMap.get(ua.Territory2Id)) {
					groupMembersToInsert.add(new GroupMember(UserOrGroupId=ua.UserId, GroupId=mapping.Group_Id_gne__c));
				}
			}
		}
		if (!groupMembersToInsert.isEmpty()) {
			insert groupMembersToInsert;
		}
	}
	
	public static void removeMembersFromGroup(List<UserTerritory2Association> terrAssociations) {
		List<Id> territoryIds = new List<Id>();
		List<Id> userIds = new List<Id>();
		Map<Id, Set<Id>> terrToUsers = new Map<Id, Set<Id>>(); 
		for (UserTerritory2Association ua : terrAssociations) {
			territoryIds.add(ua.Territory2Id);
			userIds.add(ua.UserId);
			if (!terrToUsers.containsKey(ua.Territory2Id)) {
				terrToUsers.put(ua.Territory2Id, new Set<Id>{ua.UserId});
			} else {
				terrToUsers.get(ua.Territory2Id).add(ua.UserId);
			}
		}
		Map<Id, List<Territory_Group_Mapping_gne__c>> terrGroupMappingMap = new Map<Id, List<Territory_Group_Mapping_gne__c>>();
		List<Id> groupIds = new List<Id>();
		for (Territory_Group_Mapping_gne__c mapping : [SELECT Group_Id_gne__c, Territory_Id_gne__c FROM Territory_Group_Mapping_gne__c WHERE Territory_Id_gne__c IN :territoryIds AND Type_gne__c = :GNE_SFA2_Territory2_Trigger_Logic.TERRITORY_GROUP_TYPE]) {
			if (!terrGroupMappingMap.containsKey(mapping.Territory_Id_gne__c)) {
				terrGroupMappingMap.put(mapping.Territory_Id_gne__c, new List<Territory_Group_Mapping_gne__c>());
			}
			terrGroupMappingMap.get(mapping.Territory_Id_gne__c).add(mapping);
			groupIds.add(mapping.Group_Id_gne__c);
		}
		
		Map<String, GroupMember> userGroupKeyToGroupMember = new Map<String, GroupMember>();
		for(GroupMember member : [SELECT id, UserOrGroupId, GroupId FROM GroupMember WHERE UserOrGroupId IN :userIds AND GroupId IN :groupIds]) {
			userGroupKeyToGroupMember.put(member.UserOrGroupId + '_' + member.GroupId, member);
		}
		
		List<GroupMember>  groupMembersToDelete = new List<GroupMember>();
		for (UserTerritory2Association ua : terrAssociations) {
			if (terrGroupMappingMap.containsKey(ua.Territory2Id)) {
				for (Territory_Group_Mapping_gne__c mapping : terrGroupMappingMap.get(ua.Territory2Id)) {
					Id groupId = mapping.Group_Id_gne__c;
					if (userGroupKeyToGroupMember.containsKey(ua.UserId + '_' + groupId)) {
						groupMembersToDelete.add(userGroupKeyToGroupMember.get(ua.UserId + '_' + groupId));
					}
				}
			}
		}
		if (!groupMembersToDelete.isEmpty()) {
			delete groupMembersToDelete;
		}
	}
    
}