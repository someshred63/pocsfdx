public without sharing class GNE_SFA2_Profile_Mapping_Utils {
    
    /* Map of Profile Name to Profile Mapping record */
    private static Map<String, ProfileMappingItem> profileMappingCache;
    
    /* Map of Role Name to Id */
    private static Map<String, Id> roleNameToIdCache;
    
    /* Map of Permission Set Name to Id */
    private static Map<String, Id> permSetToIdCache;
    
    public static void setUserFieldsByMappingFromTrigger(List<User> users) {		
    	initCache(users);    	
    	for (User user : users) {
    		if (!profileMappingCache.containsKey(user.Profile_Name_gne__c)){
    			continue;
    		}
    		ProfileMappingItem profileMappingItem = profileMappingCache.get(user.Profile_Name_gne__c);   
    		if (String.isNotBlank(profileMappingItem.userRoleId)){
    			user.UserRoleId = profileMappingItem.userRoleId;
    		}
    	}
    }
    
    public static void setUserFieldsByMapping(List<User> users){
    List<User> usersToUpdate = new List<User>();
    if (users == null || users.isEmpty() == true){
        return;
      }
      initCache(users);
      
      for (User user : users){
        if (!profileMappingCache.containsKey(user.Profile_Name_gne__c)){
          continue;
        }
        ProfileMappingItem profileMappingItem = profileMappingCache.get(user.Profile_Name_gne__c);   
        if (String.isNotBlank(profileMappingItem.userRoleId)){
          user.UserRoleId = profileMappingItem.userRoleId;
        usersToUpdate.add(user);
        }
      }

    if(!usersToUpdate.isEmpty()) {
      try {
        update usersToUpdate;
      } catch (Exception ex) {
        System.debug(ex);
      }
    }
    }

    public static void setUserFieldsByMapping(List<User> users, Boolean editMode){
        List<User> usersToUpdate = new List<User>();
        for(User u : users) {
            if(!u.SFA2_Managed_User_gne__c) {
                usersToUpdate.add(u);
            }
        }

        if(!usersToUpdate.isEmpty()) {
            setUserFieldsByMapping(usersToUpdate);
        }
    }
    
    public static void createUserPermSetsByMapping(List<User> users){
      if (users == null || users.isEmpty() == true){
        return;
      }
      initCache(users);
      
      List<PermissionSetAssignment> permSetsToInsert = new List<PermissionSetAssignment>();
      for (User user : users){
        if (!profileMappingCache.containsKey(user.Profile_Name_gne__c)){
          continue;
        }
        ProfileMappingItem profileMappingItem = profileMappingCache.get(user.Profile_Name_gne__c);
        if (profileMappingItem.assignedPermSetsIds.size() == 0){
          continue;
        }
        for (Id permSetId : profileMappingItem.assignedPermSetsIds){
          permSetsToInsert.add(
            new PermissionSetAssignment(
              AssigneeId = user.Id,
              PermissionSetId = permSetId
            )
          );
        }
      }
      if (permSetsToInsert.size() > 0){
        insert permSetsToInsert;
      }
    }
    
    private static void initCache(List<User> users){
      if (profileMappingCache == null){
        profileMappingCache = new Map<String, ProfileMappingItem>();
      }
      
      Set<String> userProfileNames = new Set<String>();
      for (User user : users){
        if (String.isNotBlank(user.Profile_Name_gne__c)){
          userProfileNames.add(user.Profile_Name_gne__c);
        }
      }
      userProfileNames.removeAll(profileMappingCache.keyset());
      if (userProfileNames.isEmpty()){
        return;
      }
      
      Map<String, Set<String>> profileToPermSetNames = new Map<String, Set<String>>();
      Map<String, String> profileToRoleNames = new Map<String, String>();
      for (GNE_SFA2_Profile_Mapping_gne__c mappingRecord : [Select Profile_Name_gne__c, Role_Developer_Name_gne__c, (Select Permission_Set_Name_gne__c From GNE_SFA2_PermSet_To_Profile_Mappings__r Where Is_Active_gne__c = true) 
        From GNE_SFA2_Profile_Mapping_gne__c Where Profile_Name_gne__c In :userProfileNames And Is_Active_gne__c = true]){
        profileMappingCache.put(mappingRecord.Profile_Name_gne__c, new ProfileMappingItem(mappingRecord.Profile_Name_gne__c));
        
        if (String.isNotBlank(mappingRecord.Role_Developer_Name_gne__c)){          
          profileToRoleNames.put(mappingRecord.Profile_Name_gne__c, mappingRecord.Role_Developer_Name_gne__c);
        }
        
        if (mappingRecord.GNE_SFA2_PermSet_To_Profile_Mappings__r != null && mappingRecord.GNE_SFA2_PermSet_To_Profile_Mappings__r.size() > 0){
          Set<String> permSetNames = new Set<String>();
          for (GNE_SFA2_PermSet_To_Profile_Mapping_gne__c permSetMappedRecord : mappingRecord.GNE_SFA2_PermSet_To_Profile_Mappings__r){
            permSetNames.add(permSetMappedRecord.Permission_Set_Name_gne__c);
          }
          profileToPermSetNames.put(mappingRecord.Profile_Name_gne__c, permSetNames);
        }
      }
      
      cacheRelatedValues(profileMappingCache, profileToRoleNames, profileToPermSetNames);
    }
            
    private static void cacheRelatedValues(Map<String, ProfileMappingItem> mappingCache, Map<String, String> profileToRoleNames, Map<String, Set<String>> profileToPermSetNames){      
      cacheRoleValues(mappingCache, profileToRoleNames);
      cachePermissionSetValues(mappingCache, profileToPermSetNames);
    }
    
    private static void cacheRoleValues(Map<String, ProfileMappingItem> mappingCache, Map<String, String> profileToRoleNames){
      if (profileToRoleNames.size() == 0){
        return;
      }
      if (roleNameToIdCache == null){
        roleNameToIdCache = new Map<String, Id>();
      }
      
      Set<String> allRoleNames = new Set<String>();
      for (String roleName : profileToRoleNames.values()){
        allRoleNames.add(roleName);
      }
      
      allRoleNames.removeAll(roleNameToIdCache.keyset());
      if (allRoleNames.size() > 0){
        for (UserRole userRole : [Select Id, DeveloperName From UserRole Where DeveloperName In :allRoleNames]){
          roleNameToIdCache.put(userRole.DeveloperName, userRole.Id);
        }
      }
      
      if (roleNameToIdCache.size() == 0){
        return;
      }
      
      String roleName;
      for (String profileName : mappingCache.keyset()){
        roleName = profileToRoleNames.containsKey(profileName) && String.isNotBlank(profileToRoleNames.get(profileName)) ? profileToRoleNames.get(profileName) : null;
        if (String.isBlank(roleName) || !roleNameToIdCache.containsKey(roleName)){
          continue;
        }        
         ProfileMappingItem profileMappingItem = mappingCache.get(profileName);
         profileMappingItem.setUserRoleId(roleNameToIdCache.get(roleName));
      }
    }
    
    private static void cachePermissionSetValues(Map<String, ProfileMappingItem> mappingCache, Map<String, Set<String>> profileToPermSetNames){
      if (profileToPermSetNames.size() == 0){
        return;
      }
      if (permSetToIdCache == null){
        permSetToIdCache = new Map<String, Id>();
      }
      
      Set<String> allPermSetNames = new Set<String>();
      for (Set<String> permSet : profileToPermSetNames.values()){
        allPermSetNames.addAll(permSet);
      }
      
      allPermSetNames.removeAll(permSetToIdCache.keyset());      
      if (allPermSetNames.size() > 0){        
        for (PermissionSet permSet : [Select Id, Name From PermissionSet Where Name In: allPermSetNames]){
          permSetToIdCache.put(permSet.Name, permSet.Id);
        }
      }
      
      if (permSetToIdCache.size() == 0){
        return;
      }
      
      for (String profileName : mappingCache.keyset()){
        if (!profileToPermSetNames.containsKey(profileName) || profileToPermSetNames.get(profileName).size() == 0){
          continue;
        }        
        ProfileMappingItem profileMappingItem = mappingCache.get(profileName);
        for (String permSetName : profileToPermSetNames.get(profileName)){                    
          if (permSetToIdCache.containsKey(permSetName)){
            profileMappingItem.addPermSetId(permSetToIdCache.get(permSetName));
          }
        }
      }
    }
    
    private class ProfileMappingItem {
      public String profileName { get; private set; }
      public String userRoleId { get; private set; }
      public Set<Id> assignedPermSetsIds { get; private set; }
      
      public ProfileMappingItem(String profileName){
        this.profileName = profileName;
        this.userRoleId = null;
        this.assignedPermSetsIds = new Set<Id>();
      }
      
      public void setUserRoleId(Id userRoleId){
        this.userRoleId = userRoleId;
      }
      
      public void addPermSetId(Id permSetId){
        this.assignedPermSetsIds.add(permSetId);
      }
    }
        
}