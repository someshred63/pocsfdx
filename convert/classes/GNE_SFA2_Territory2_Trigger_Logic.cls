public without sharing class GNE_SFA2_Territory2_Trigger_Logic {
    
    private static final String TERRITORY_EXTID_SEPARATOR = ';';
    private static final String TERRITORY_GROUP_NAME_PREFIX = 'TerrGroup_';
    private static final String TERRITORY_SUBORDINATES_GROUP_NAME_PREFIX = 'TerrSubordinatesGroup_';
    public static final String TERRITORY_GROUP_TYPE = 'Territory';
    public static final String TERRITORY_AND_SUBORDINATES_GROUP_TYPE = 'TerritoryAndSubordinates';
    public static final String INACTIVE_PARENT_TERRITORY_EXTID = 'INACTIVE TERRITORIES';
    	
    
    public static void nameValidation(List<Territory2> triggerNew) {
        for(Territory2 terr : triggerNew) {
            if(terr.Name.contains(TERRITORY_EXTID_SEPARATOR)) {
                terr.addError('Territory name cannot contains the \'' + TERRITORY_EXTID_SEPARATOR + '\' character. The character is dedicated to external id as a node separator.');
            }
        }
    }
    
    public static void externalIdsValidation(List<Territory2> triggerNew) {
        for(Territory2 terr : triggerNew) {
            if(String.isNotBlank(terr.External_Id_gne__c) && !terr.External_Id_gne__c.endsWithIgnoreCase(terr.Name)) {
                terr.addError('Territory external id should contain territory name as the suffix.');
            } else if(String.isNotBlank(terr.Parent_External_Id_gne__c)) {
                if(!terr.External_Id_gne__c.contains(terr.Parent_External_Id_gne__c)) {
                    terr.addError('Territory external id should start with the parent external id.');
                } else if(terr.Parent_External_Id_gne__c == terr.External_Id_gne__c) {
                    terr.addError('Territory parent and external id cannot be the same.');
                } else if(!terr.External_Id_gne__c.substring((terr.External_Id_gne__c.indexOfDifference(terr.Parent_External_Id_gne__c))).startsWith(TERRITORY_EXTID_SEPARATOR)) {
                    Integer index = terr.External_Id_gne__c.indexOfDifference(terr.Parent_External_Id_gne__c);
                    String incorrectSeparator = terr.External_Id_gne__c.substring(index, index + 1);
                    terr.addError('Incorrect \'' + incorrectSeparator + '\' separator in territory external id between territory parent external id and territory name.');
                }
            }
        }
    }
    
    public static void checkCorrectnessExtIds(List<Territory2> triggerNew) {
        List<Territory2> territories;
        Map<Id, Territory2> territoryToUpdate = new Map<Id, Territory2>();
        Set<Id> territoriesIds = new Set<Id>();
        Boolean getChildTerritories = true;
        
        for(Territory2 terr : triggerNew) {
            territoriesIds.add(terr.Id);
        }
        
        territories = [SELECT Id, Name, ParentTerritory2Id, Parent_External_Id_gne__c, External_Id_gne__c FROM Territory2 WHERE Id IN: territoriesIds];
        
        while (true) {
            if (!getChildTerritories) {
                break;
            }
            
            List<Territory2> childTerritories = [SELECT Id, Name, ParentTerritory2Id, Parent_External_Id_gne__c, External_Id_gne__c FROM Territory2 WHERE ParentTerritory2Id IN: territoriesIds AND Parent_External_Id_gne__c != null];
            if(!childTerritories.isEmpty()) {
                territoriesIds = new Set<Id>();
                for(Territory2 terr : childTerritories) {
                    territoriesIds.add(terr.Id);
                }
            } else {
                getChildTerritories = false;
            }
            
            territories.addAll(childTerritories);
        }
        
        Map<Integer, List<Territory2>> orderedTerritories = GNE_SFA2_Territory2_Trigger_Helper.reorderTerritoriesByHierarchy(territories);
        Map<Id, String> idToExtId = new Map<Id, String>();
        List<Integer> orders = new List<Integer>(orderedTerritories.keySet());
        orders.sort();
        
        for(Integer i : orders) {
            for(Territory2 terr : orderedTerritories.get(i)) {
                if(String.isNotBlank(terr.Parent_External_Id_gne__c) && String.isNotBlank(terr.External_Id_gne__c)) {
                    if(idToExtId.containsKey(terr.ParentTerritory2Id) && idToExtId.get(terr.ParentTerritory2Id) != terr.Parent_External_Id_gne__c) {
                        String paretnExtId = idToExtId.get(terr.ParentTerritory2Id);
                        terr.Parent_External_Id_gne__c = paretnExtId;
                        terr.External_Id_gne__c = paretnExtId + TERRITORY_EXTID_SEPARATOR + terr.Name;
                        territoryToUpdate.put(terr.id, terr);
                    }
                    idToExtId.put(terr.Id, terr.External_Id_gne__c);
                }
            }
        }
        
        if(!territoryToUpdate.isEmpty()) {
            update territoryToUpdate.values();
        }
    }
    
    public static void deleteTerritoryGroups(Map<Id, Territory2> territoriesMap) {
		deleteGroupAndMappingForTerritories(territoriesMap.keySet());	
    }
    
    public static void deleteTerritoryGroupsForInactiveTerritories(Map<Id, Territory2> territoriesMap) {
    	Set<Id> inactiveTerritories = new Set<Id>();
    	for(Id terrId : territoriesMap.keySet()) {
    		if (territoriesMap.get(terrId).External_Id_gne__c.startsWith(INACTIVE_PARENT_TERRITORY_EXTID)) {
    			inactiveTerritories.add(terrId);
    		}
    	}
    	if (!inactiveTerritories.isEmpty()) {
			deleteGroupAndMappingForTerritories(inactiveTerritories);
    	}
    }
    
    public static void deleteUsersFromInactiveTerritories(Map<Id, Territory2> territoriesMap) {
    	Set<Id> inactiveTerritories = new Set<Id>();
    	for(Id terrId : territoriesMap.keySet()) {
    		if (territoriesMap.get(terrId).External_Id_gne__c.startsWith(INACTIVE_PARENT_TERRITORY_EXTID)) {
    			inactiveTerritories.add(terrId);
    		}
    	}
    	if (!inactiveTerritories.isEmpty()) {
			deleteUsersFromTerritories(inactiveTerritories);
    	}
    }
    
    private static void deleteUsersFromTerritories(Set<Id> territoryIds) {
    	delete [select id from UserTerritory2Association where Territory2Id in :territoryIds];
    }
    
    private static void deleteGroupAndMappingForTerritories(Set<Id> territoryIds) {
    	if (!territoryIds.isEmpty()) {
	    	List<Territory_Group_Mapping_gne__c> terrGroupMappingMap = [SELECT Group_Id_gne__c, Territory_Id_gne__c FROM Territory_Group_Mapping_gne__c WHERE Territory_Id_gne__c IN :territoryIds];
			List<Id> terrGroupMappingIds = new List<Id>();
			List<Id> groupIds = new List<Id>();
			for (Territory_Group_Mapping_gne__c mapping : terrGroupMappingMap) {
				groupIds.add(mapping.Group_Id_gne__c);
				terrGroupMappingIds.add(mapping.Id);
			}
			delete  [SELECT id FROM Group WHERE Id in :groupIds];
			deleteGroupMapping(terrGroupMappingIds);
    	}	
    }
    
    @future
    public static void deleteGroupMapping(List<Id> mappingIds) {
		delete [SELECT id FROM Territory_Group_Mapping_gne__c WHERE Id in :mappingIds];
    }
    
    public static void createTerritoryGroups(Map<Id, Territory2> territoriesMap) {
		Map<Id, Territory_Group_Mapping_gne__c> terrGroupMappingMap = new Map<Id, Territory_Group_Mapping_gne__c>();

		for (Territory_Group_Mapping_gne__c mapping : [SELECT Group_Id_gne__c, Territory_Id_gne__c FROM Territory_Group_Mapping_gne__c WHERE Territory_Id_gne__c IN :territoriesMap.keySet()]) {
			terrGroupMappingMap.put(mapping.Territory_Id_gne__c, mapping);
		}
		
		Map<Id, Group> terrToGroup = new Map<Id, Group>();
		Map<Id, Group> terrToSubordinatesGroup = new Map<Id, Group>();
		
		for (Id terrId : territoriesMap.keySet()) {
			if (!terrGroupMappingMap.containsKey(terrId)) {
				Group terrGroup = new Group(Name = TERRITORY_GROUP_NAME_PREFIX + territoriesMap.get(terrId).Id);
				terrToGroup.put(terrId, terrGroup);
				Group terrSubordinatesGroup = new Group(Name = TERRITORY_SUBORDINATES_GROUP_NAME_PREFIX + territoriesMap.get(terrId).Id);
				terrToSubordinatesGroup.put(terrId, terrSubordinatesGroup);			
			}
		}
		if (!terrToGroup.isEmpty()) {
			insert terrToGroup.values();
		}
		if (!terrToSubordinatesGroup.isEmpty()) {
			insert terrToSubordinatesGroup.values();
		}
		Map<Id, Id> terrIdToGroupId = new Map<Id, Id>();
		for (Id terrId: terrToGroup.keySet()) {
			terrIdToGroupId.put(terrId, terrToGroup.get(terrId).Id);
		}
		insertTerrGroupMapping(terrIdToGroupId, TERRITORY_GROUP_TYPE);
		
		terrIdToGroupId = new Map<Id, Id>();
		for (Id terrId: terrToSubordinatesGroup.keySet()) {
			terrIdToGroupId.put(terrId, terrToSubordinatesGroup.get(terrId).Id);
		}
		createGroupHierarchy(territoriesMap, terrToGroup, terrToSubordinatesGroup);
		insertTerrGroupMapping(terrIdToGroupId, TERRITORY_AND_SUBORDINATES_GROUP_TYPE);
    }
    
    @future
    private static void insertTerrGroupMapping(Map<Id, Id> terrToGroup, String gType) {
		List<Territory_Group_Mapping_gne__c> terrGroupMapping = new List<Territory_Group_Mapping_gne__c>();
		for (Id terrId : terrToGroup.keySet()) {
			terrGroupMapping.add(new Territory_Group_Mapping_gne__c(Territory_Id_gne__c = terrId, Group_Id_gne__c = terrToGroup.get(terrId), Type_gne__c = gType));
		}
		insert terrGroupMapping;
    }
    
    private static void createGroupHierarchy(Map<Id, Territory2> territoriesMap, Map<Id, Group> terrToGroup, Map<Id, Group> terrToSubordinatesGroup) {
    	Map<Id, Set<Territory2>> territoryToChildrenTerritories = new Map<Id, Set<Territory2>>(); 
    	Set<Id> terrIds = new Set<Id>();

    	for (Territory2 terr : [SELECT Id, ParentTerritory2Id FROM Territory2 WHERE ParentTerritory2Id in :territoriesMap.keySet()]) {
    		if (!territoryToChildrenTerritories.containsKey(terr.Id)) {
    			territoryToChildrenTerritories.put(terr.ParentTerritory2Id, new Set<Territory2>());
    		}
    		territoryToChildrenTerritories.get(terr.ParentTerritory2Id).add(terr);
    	}
    	
		for (Territory2 terr : territoriesMap.values()) {
			terrIds.add(terr.Id);
			if (terr.ParentTerritory2Id != null) {
				terrIds.add(terr.ParentTerritory2Id);
			}
		}
		
		Map<Id, Id> terrSubordinatesGroupMappingMap = getTerritoryGroupMapping(terrIds, TERRITORY_AND_SUBORDINATES_GROUP_TYPE);
		
		Map<Id, Id> terrGroupMappingMap = getTerritoryGroupMapping(terrIds, TERRITORY_GROUP_TYPE);
		/*for territory group type - group should contain parrent territory group
		for territory and subordinates group type - territory should contains terr group and children territory and subordinate groups
		*/
		List<GroupMember> groupMembers = new List<GroupMember>();
		for (Id terrId : terrToSubordinatesGroup.keySet()) {
			Territory2 terr = territoriesMap.get(terrId);
			if(terr.ParentTerritory2Id != null) {
				Id parentTerrSubordinatesGroup = terrToSubordinatesGroup.containsKey(terr.ParentTerritory2Id) ? terrToSubordinatesGroup.get(terr.ParentTerritory2Id).Id :  terrSubordinatesGroupMappingMap.get(terr.ParentTerritory2Id);
				Id parentTerrGroup = terrToGroup.containsKey(terr.ParentTerritory2Id) ? terrToGroup.get(terr.ParentTerritory2Id).Id :  terrGroupMappingMap.get(terr.ParentTerritory2Id);
				
				//parent territory and subordiantes group contains children territory and subordinates group
				groupMembers.add(new GroupMember(GroupId = parentTerrSubordinatesGroup, UserOrGroupId = terrToSubordinatesGroup.get(terrId).Id));
				// territory and subordinates group contains territory type group
				groupMembers.add(new GroupMember(GroupId = terrToSubordinatesGroup.get(terrId).Id, UserOrGroupId = terrToGroup.get(terrId).Id));
				
				// territory and subordinates group contains all direct children territory and subordinate groups
				if (territoryToChildrenTerritories.containsKey(terrId)) {
					for (Territory2 childTerr : territoryToChildrenTerritories.get(terrId)) {
						Id childTerrSubordinatesGroup = terrToSubordinatesGroup.containsKey(childTerr.Id) ? terrToSubordinatesGroup.get(childTerr.Id).Id :  terrSubordinatesGroupMappingMap.get(childTerr.Id);
						groupMembers.add(new GroupMember(GroupId = terrToSubordinatesGroup.get(terrId).Id, UserOrGroupId = childTerrSubordinatesGroup));
					}
				}
				//territory group contains parent territory group
				groupMembers.add(new GroupMember(GroupId = terrToGroup.get(terrId).Id, UserOrGroupId = parentTerrGroup));
			}
		}
		if (!groupMembers.isEmpty()) {
			insert groupMembers;
		}
    }
    
    /* Update group hierarchy if parentTerritoryId is changed for territory */
	@future
    public static void updateGroupHierarchy(String newMapJSON, String oldMapJSON) {
		Map<Id, Territory2> newMap = (Map<Id, Territory2>)JSON.deserialize(newMapJSON, Map<Id, Territory2>.class);
		Map<Id, Territory2> oldMap = (Map<Id, Territory2>)JSON.deserialize(oldMapJSON, Map<Id, Territory2>.class);
    	Map<Id, Set<Id>> groupToMembersToDelete = new Map<Id, Set<Id>>();
    	List<GroupMember> membersToInsert = new List<GroupMember>();
    	Set<Id> terrIds = new Set<Id>();
		for (Territory2 terr : newMap.values()) {
			terrIds.add(terr.Id);
			if (terr.ParentTerritory2Id != null) {
				terrIds.add(terr.ParentTerritory2Id);
			}
		}
		for (Territory2 terr : oldMap.values()) {
			if (terr.ParentTerritory2Id != null) {
				terrIds.add(terr.ParentTerritory2Id);
			}
		}
		Map<Id, Id> terrGroupMappingMap = getTerritoryGroup(terrIds, TERRITORY_GROUP_NAME_PREFIX);
		Map<Id, Id> terrSubordinatesGroupMappingMap = getTerritoryGroup(terrIds, TERRITORY_SUBORDINATES_GROUP_NAME_PREFIX);
		
    	for (Id terrId : newMap.keySet()) {
    		//skip inactive territories
    		if (!newMap.get(terrId).External_Id_gne__c.startsWith(INACTIVE_PARENT_TERRITORY_EXTID) && newMap.get(terrId).ParentTerritory2Id != oldMap.get(terrId).ParentTerritory2Id) {
    			//group type: territory
    			Id gId = terrGroupMappingMap.get(terrId);
    			if (!groupToMembersToDelete.containsKey(gId)) {
    				groupToMembersToDelete.put(gId, new Set<Id>());
    			}
    			groupToMembersToDelete.get(gId).add(terrGroupMappingMap.get(oldMap.get(terrId).ParentTerritory2Id));
    			membersToInsert.add(new GroupMember(GroupId = gId, UserOrGroupId = terrGroupMappingMap.get(newMap.get(terrId).ParentTerritory2Id)));
    			
    			//group type: territory and subordinates
    			Id parentTerritoryAndSubordintatesGroupId = terrSubordinatesGroupMappingMap.get(oldMap.get(terrId).ParentTerritory2Id);
    			
    			if (!groupToMembersToDelete.containsKey(parentTerritoryAndSubordintatesGroupId)) {
    				groupToMembersToDelete.put(parentTerritoryAndSubordintatesGroupId, new Set<Id>());
    			}
    			groupToMembersToDelete.get(parentTerritoryAndSubordintatesGroupId).add(terrGroupMappingMap.get(terrId));
    			membersToInsert.add(new GroupMember(GroupId = terrSubordinatesGroupMappingMap.get(newMap.get(terrId).ParentTerritory2Id), UserOrGroupId = terrGroupMappingMap.get(terrId)));
    		}
    	}
    	List<GroupMember> membersToDelete = new List<GroupMember>();
    	for (GroupMember gm : [SELECT id, GroupId, UserOrGroupId FROM GroupMember WHERE GroupId in :groupToMembersToDelete.keySet()]) {
    		if (groupToMembersToDelete.get(gm.GroupId).contains(gm.UserOrGroupId)) {
    			membersToDelete.add(gm);
    		}
    	}
    	if (!membersToDelete.isEmpty()) {
    		delete membersToDelete;
    	}
    	
    	if (!membersToInsert.isEmpty()) {
    		insert membersToInsert;
    	}
    }
    
    public static void updateTsfes(Map<Id, Territory2> newMap, Map<Id, Territory2> oldMap) {
    	Map<String, String> oldNameToNewName = new Map<String, String>();
    	for (Id terrId : newMap.keySet()) {
    		if (newMap.get(terrId).Name != oldMap.get(terrId).Name) {
    			oldNameToNewName.put(oldMap.get(terrId).Name, newMap.get(terrId).Name);
    		}
    	}
    	GNE_SFA2_Tsf_Update_Batch tsfUpdateBatch = new GNE_SFA2_Tsf_Update_Batch(oldNameToNewName);
    	Database.executeBatch(tsfUpdateBatch);
    }
    
    public static void updateStagingUserAssignments(Map<Id, Territory2> newMap, Map<Id, Territory2> oldMap) {
    	Map<String, String> oldNameToNewName = new Map<String, String>();
    	for (Id terrId : newMap.keySet()) {
    		if (newMap.get(terrId).Name != oldMap.get(terrId).Name) {
    			oldNameToNewName.put(oldMap.get(terrId).Name, newMap.get(terrId).Name);
    		}
    	}
    	GNE_SFA2_StagingUserAssig_Update_Batch stagingUpdateBatch = new GNE_SFA2_StagingUserAssig_Update_Batch(oldNameToNewName);
    	Database.executeBatch(stagingUpdateBatch);
    }
    
    private static Map<Id, Id> getTerritoryGroupMapping(Set<Id> territoryIds, String gType) {
    	Map<Id, Id> terrGroupMappingMap = new Map<Id, Id>();
		for (Territory_Group_Mapping_gne__c mapping : [SELECT Group_Id_gne__c, Territory_Id_gne__c FROM Territory_Group_Mapping_gne__c WHERE Territory_Id_gne__c IN :territoryIds AND Type_gne__c = :gType]) {
			terrGroupMappingMap.put(mapping.Territory_Id_gne__c, mapping.Group_Id_gne__c);
		} 
		return terrGroupMappingMap;
    }
    
    private static Map<Id, Id> getTerritoryGroup(Set<Id> territoryIds, String groupNamePrefix) {
    	Map<Id, Id> terrGroupMappingMap = new Map<Id, Id>();
    	Set<String> groupNames = new Set<String>();
    	for(Id terrId : territoryIds) {
    		groupNames.add(groupNamePrefix + terrId);
    	}
    	
    	for(Group gr : [SELECT Id, Name FROM Group WHERE Name IN : groupNames AND Type = 'Regular']) {
    		terrGroupMappingMap.put(gr.Name.replace(groupNamePrefix, ''), gr.Id);
    	}
    	
		return terrGroupMappingMap;
    }
    
    public static void populateExternalIds(List<Territory2> triggerNew) {
        Set<Id> parentTerritoryIds = new Set<Id>();
        for(Territory2 terr : triggerNew) {
            if(String.isNotBlank(terr.ParentTerritory2Id)) {
                parentTerritoryIds.add(terr.ParentTerritory2Id);
            }
        }
        
        Map<Id, String> parentIdToExtId = new Map<Id, String>();
        for(Territory2 terr : [SELECT Id, External_Id_gne__c FROM Territory2 WHERE Id IN : parentTerritoryIds]) {
            if(String.isNotBlank(terr.External_Id_gne__c)) {
                parentIdToExtId.put(terr.Id, terr.External_Id_gne__c);
            }
        }
        
        for(Territory2 terr : triggerNew) {
            if(String.isBlank(terr.External_Id_gne__c) || String.isBlank(terr.Parent_External_Id_gne__c) || (parentIdToExtId.containsKey(terr.ParentTerritory2Id) && terr.Parent_External_Id_gne__c != parentIdToExtId.get(terr.ParentTerritory2Id))) {         
                if(String.isNotBlank(terr.ParentTerritory2Id) && parentIdToExtId.containsKey(terr.ParentTerritory2Id)) {
                    String parentExtId = parentIdToExtId.get(terr.ParentTerritory2Id);
                    terr.Parent_External_Id_gne__c = parentExtId;
                    terr.External_Id_gne__c = parentExtId + ';' + terr.Name;
                }
            }
        }
    }
    
    /*If territory external id is changed than corresponding staging data should also be changed.*/
    public static void updateRepStagingData(Map<Id, Territory2> newMap, Map<Id, Territory2> oldMap) {
    	Map<String, String> oldToNewExtId = new Map<String, String>();
    	for (Id terrId : newMap.keySet()) {
    		if (newMap.get(terrId).External_Id_gne__c != oldMap.get(terrId).External_Id_gne__c) {
    			oldToNewExtId.put(oldMap.get(terrId).External_Id_gne__c, newMap.get(terrId).External_Id_gne__c);
    		}
    	}
    	updateRepStagingData(oldToNewExtId);
    }
    
	@future    
    private static void updateRepStagingData(Map<String, String> oldToNewExtId) {
    	List<String> statusesToProcess = new List<String> {'Loaded', 'Assigned'};
    	for( List<Staging_User_Assignment_gne__c> stagingData : [SELECT id, Territory_Key_gne__c FROM Staging_User_Assignment_gne__c WHERE Status_gne__c in :statusesToProcess AND Territory_Key_gne__c in :oldToNewExtId.keySet()]) {
	    	for (Staging_User_Assignment_gne__c sa : stagingData) {
	    		sa.Territory_Key_gne__c = oldToNewExtId.get(sa.Territory_Key_gne__c);
	    	}
	    	update stagingData;
    	}
    } 
}