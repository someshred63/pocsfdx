/**
 * This class is used to seperate user access to data based on their profile
 * This is configure by the table Profile_to_Group_Map_gne which maps p
Position:    Ln 17, Ch 61   Total:   Ln 245, Ch 9071    
Search  rofiles to specific groups
 * Profiles can be in many groups or none based on this mapping
 * The basis of this class is to move users between to be in the profile groups and only the profile groups 
 * specified. Profile groups are identified by  the PRF_GRP_ prefix and this class affects only those group member ships
 * The initial purpose for this is to seperate all system data based on group membership between Canada and Users
 */
global without sharing class sysUserToGroupUtil{

   /** Prefix for groups that are mapped to profiles, all groups mapped to profiles must have this prefix */
   static string prfGrpPrefix = 'PRF_GRP_';
   
   /** License type to be included in this trigger */
   static string licSFDC_UNLIMITED = 'Salesforce';
   static string licFDC_UNLIMITED = 'Salesforce Platform';
   
   static boolean debug = true;
   
   public static Boolean inAssignUserGroupsFuture = false;
   
  /**
    * Return set of Group IDs that are assigned the example profile
    */
   public static SET<Id> getGroupsForProfile(String profileName){
   	   System.debug('Pratik Code Inside getGroupsForProfile');
       Map<String, Set<String>> profileMasksToGroupsMap = getProfileMasksToGroupsMappings();
       Set<String> profileGroups = getGroupsForProfile(profileName, profileMasksToGroupsMap);
        
       if (debug) {
       		System.debug('All Groups:' + profileMasksToGroupsMap);
       		System.debug('Group Names for profile: '+ profileName + '  ;  ' + profileGroups);
       }
       
       Map<Id, Group> grpIds = new Map<Id, Group>();
       if (profileGroups.size() > 0){
       		grpIds = new Map<Id, Group>([Select Id, name from Group where name in :profileGroups]);
       		if (debug){
       			System.debug('Groups for user list:' + grpIds.size());
         		for(Id gId : grpIds.keySet()){
            		System.debug('Groups for profile: ' + profileName + ' : ' + grpIds.get(gId).name);
         		}
       		}
       }
       return grpIds.keySet();
   }
   
   /**
    * Returns set of Profil-Groups that are not assigned for this profile
    * @Input - Set of Group Ids profile is assigned to 
    */ 
   public static Set<Id> getGroupsNotForProfile(Set<ID> grpsForProfile){
       System.debug('Pratik Code Inside getGroupsNotForProfile');    
       Map<Id, GROUP> grps = new Map<Id, GROUP>([Select Id, Name from GROUP where Name like :prfGrpPrefix+'%']);
       Set<Id> grpsNotForProfile = new Set<Id>(grps.keySet());
       if (grpsForProfile != null) {
        	grpsNotForProfile.removeAll(grpsForProfile);
       }
       
       if (debug){
           System.debug('List Profile Groups:' + grps.size());
           for(Group grp : grps.values()){
              System.debug('Profile Group :' + grp.name);
           }
           System.debug('List Groups not for Profile :' + grpsNotForProfile.size());
           for(Id grpID : grpsNotForProfile){
              System.debug('GroupId Not for profile: ' + grpID);
           }
       }
       return grpsNotForProfile;
   }   
   
    public static Map<Id, User> userIdToProfileAndLicenseMap;
    public static Map<String,Set<Id>> profileNameToEnabledGroupIdsMap;
    
    public static Map<Id,List<GroupMember>> userIdToEnabledGroupMembersMap;
    public static Map<Id,List<GroupMember>> userIdToDisabledGroupMembersMap;
    public static Map<Id,Set<Id>> userIdToAssignedGroupIdsMap;
   
    private static void initCache(List<User> users) {
       System.debug('Pratik Code Inside initCache');    
       if (userIdToProfileAndLicenseMap != null) {
            System.debug('Cached users: ' + userIdToProfileAndLicenseMap.keySet());
            boolean allUsersInCache = true; 
            for (User u : users) {
                if (!userIdToProfileAndLicenseMap.containsKey(u.Id)) {
                    allUsersInCache = false;
                    break;
                }
            } 
            // Use existing cache only if all users in scope are included in this cache
            // Otherwise  re-init cache for new scope.
            if (allUsersInCache) {
            	return;
            }
        }
        
        Set<Id> uIds = new Set<Id>();
        for (User u : users){
        	uIds.add(u.Id);
        }
        
        userIdToProfileAndLicenseMap = new Map<Id, User>([Select profile.name, profile.userlicense.name from user where user.id in :uIds]);
        
        // Get profile names from given Users
        Set<String> profileNames = new Set<String>();
        for(User u : userIdToProfileAndLicenseMap.values()) {
        	profileNames.add(u.profile.name);
        }
        
        Map<String, Set<String>> profileMasksToGroupsMap = getProfileMasksToGroupsMappings();
        Map<String,Set<String>> groupNameToProfileNamesMap = new Map<String,Set<String>>();        
        // Calculate profiles which mapped to group names 
        for (String profileName : profileNames) {
			for (String groupName : getGroupsForProfile(profileName, profileMasksToGroupsMap)){
				if(!groupNameToProfileNamesMap.containsKey(groupName)){
    				groupNameToProfileNamesMap.put(groupName, new Set<String>());
    			}            
    			groupNameToProfileNamesMap.get(groupName).add(profileName);
			}	
        }
        System.debug('[BOS] Enabled Groups: ' + groupNameToProfileNamesMap.keySet());
        List<Group> groups = [Select Id, name from Group where name in :groupNameToProfileNamesMap.keySet()];
        
        profileNameToEnabledGroupIdsMap = new Map<String,Set<Id>>();
        
        Set<Id> allGroupIds = new Set<Id>();
        
        // Calculate group ids available for each profile
        for(Group grp : groups) {
            if(!groupNameToProfileNamesMap.containsKey(grp.name)){ 
            	continue;
            }
            allGroupIds.add(grp.Id);
            for (String profileName :groupNameToProfileNamesMap.get(grp.name)) {
                if (!profileNameToEnabledGroupIdsMap.containsKey(profileName)) {
                    profileNameToEnabledGroupIdsMap.put(profileName, new Set<Id>());
                }
                profileNameToEnabledGroupIdsMap.get(profileName).add(grp.id);
            }
        }
        
        // Get all PRF Groups
        Set<Id> prfGroupsIds = (new Map<Id, GROUP>([Select Id, Name from GROUP where Name like :prfGrpPrefix+'%'])).keySet();
        allGroupIds.addAll(prfGroupsIds);
        
        userIdToDisabledGroupMembersMap = new Map<Id,List<GroupMember>>();
        userIdToEnabledGroupMembersMap = new Map<Id,List<GroupMember>>();
        userIdToAssignedGroupIdsMap = new Map<Id,Set<Id>>();
        
        // For each user: calculate GroupMembers that need to be removed 
        // and those which are valid for this user 
        for (GroupMember gm : [Select id, Group.Name, GroupId, UserOrGroupId from GroupMember where GroupId in :allGroupIds and UserOrGroupId = :uIds]) {
            Id userId = gm.UserOrGroupId;
            Id groupId = gm.GroupId;
            String profileName = userIdToProfileAndLicenseMap.get(userId).profile.name;
            
            if(profileNameToEnabledGroupIdsMap.containsKey(profileName) && 
               profileNameToEnabledGroupIdsMap.get(profileName).contains(groupId)) {
                if (!userIdToEnabledGroupMembersMap.containsKey(userId))
                    userIdToEnabledGroupMembersMap.put(userId,new List<GroupMember>());
                userIdToEnabledGroupMembersMap.get(userId).add(gm);
                
                if(!userIdToAssignedGroupIdsMap.containsKey(userId))
                    userIdToAssignedGroupIdsMap.put(userId,new Set<Id>());
                userIdToAssignedGroupIdsMap.get(userId).add(groupId);
            } else {
                if (!userIdToDisabledGroupMembersMap.containsKey(userId))
                    userIdToDisabledGroupMembersMap.put(userId,new List<GroupMember>());
                userIdToDisabledGroupMembersMap.get(userId).add(gm);
            }                   
        }
    }
    
    private static Map<String, Set<String>> getProfileMasksToGroupsMappings(){    	
    	Map<String, Set<String>> profileMasksToGroupsMap = new Map<String, Set<String>>();
		for (Profile_to_Group_Map_gne__c ritem : [Select Group_Name_gne__c, Profile_Mask_gne__c from Profile_to_Group_Map_gne__c Order By Profile_Mask_gne__c]){	
			if (String.isNotBlank(ritem.Profile_Mask_gne__c) && String.isNotBlank(ritem.Group_Name_gne__c)){		
				if (!profileMasksToGroupsMap.containsKey(ritem.Profile_Mask_gne__c.toUpperCase())){
					profileMasksToGroupsMap.put(ritem.Profile_Mask_gne__c.toUpperCase(), new Set<String>());
				} 
				profileMasksToGroupsMap.get(ritem.Profile_Mask_gne__c.toUpperCase()).add(ritem.Group_Name_gne__c);
			}
		}
		return profileMasksToGroupsMap;
    }
    
    private static Set<String> getGroupsForProfile(String profileName, Map<String, Set<String>> profileMasksToGroupsMap){
       	Set<String> groupsResult = new Set<String>();
       	Integer coveridx = 0;
		String bestMask = '';
		// get best fitted/covered mask
		for (String mask : profileMasksToGroupsMap.keyset()){
			if (profileName.toUpperCase().startsWith(mask) && profileName.toUpperCase().substring(0, mask.length()).length() > coveridx){
				bestMask = mask;			
				coveridx = profileName.toUpperCase().substring(0, mask.length()).length();
				if (coveridx == profileName.length()){				
					break;
				}
			}		
		}
		if (String.isNotBlank(bestMask)){
			groupsResult = profileMasksToGroupsMap.get(bestMask);			
		}
		return groupsResult;
    }
    
    @future
    public static void assignUserGroupsFuture(List<String> userIds){
        System.debug('Pratik Code Inside assignUserGroupsFuture');    
        List<User> users = [ SELECT Id FROM USER WHERE Id IN :userIds ];
        assignUserGroups(users);
    }
    
    /**
    * To be called from Triggero user update / insert
    * Assigns user to appropriate groups based on profile
    */
    public static integer assignUserGroups(List<user> users){
        initCache(users);
        System.debug('Pratik Code Inside assignUserGroups');    
           
        integer count = 0;
        
        List<GroupMember> grpMembersToDelete = new List<GroupMember>();
        List<GroupMember> grpMembersToInsert = new List<GroupMember>();
        
        for(user u: users){
            // Only apply this to user with Unlimited License to exclude Portal users
            if ((licSFDC_UNLIMITED == userIdToProfileAndLicenseMap.get(u.id).profile.userlicense.name) || (licFDC_UNLIMITED == userIdToProfileAndLicenseMap.get(u.id).profile.userlicense.name)) {
                count += assignUserGroups(u, userIdToProfileAndLicenseMap.get(u.id).profile.name, grpMembersToDelete, grpMembersToInsert);
            }
        }/* for users */
        
        if (!grpMembersToDelete.isEmpty()){
            delete grpMembersToDelete;
        }
            
        if (!grpMembersToInsert.isEmpty()) {
            insert grpMembersToInsert;
        }
              
        return count;
    }
    /**
    * Passed User and users Profile. Assigned user to apprropriate Groups as defined in Profiles to Group Map
    * object for specified profile.
    */
    private static integer assignUserGroups(User u, String prfName, List<GroupMember> allGrpMembersToDelete, List<GroupMember> allGrpMembersToInsert){
        /* Right now we don't need this statement, but if this method will be called from different place 
           than assignUserGroups(LIST), we need to init cache for given User.
        initCache(new List<User>{u});
        */
        System.debug('Pratik Code Inside assignUserGroups');    
 
        Set<Id> grpsForUser = profileNameToEnabledGroupIdsMap.containsKey(prfName) ?
                                    profileNameToEnabledGroupIdsMap.get(prfName) : new Set<Id>(); 

        // First Remove User from Group
        List<GroupMember> grpMembers = userIdToDisabledGroupMembersMap.containsKey(u.Id) ?
                                    userIdToDisabledGroupMembersMap.get(u.Id) : new List<GroupMember>();
        if(allGrpMembersToDelete!=null) {
            allGrpMembersToDelete.addAll(grpMembers);
        } else {
            if (!grpMembers.isEmpty()){
                delete grpMembers;
            }
        }
        
        // Add User to valid Groups
        grpMembers = userIdToEnabledGroupMembersMap.containsKey(u.Id) ?
                                    userIdToEnabledGroupMembersMap.get(u.Id) : new List<GroupMember>();
        Set<Id> existingAssignedGroupId = userIdToAssignedGroupIdsMap.containsKey(u.Id) ?
                                    userIdToAssignedGroupIdsMap.get(u.Id) : new Set<Id>();
        
        List<GroupMember> grpMembersToInsert = new List<GroupMember>(); 
        for(Id grpId : grpsForUser) {
            // check if this user is already added to this group
            if(existingAssignedGroupId.contains(grpId)){ 
            	continue;
            }
            
            GroupMember grpMember = new GroupMember();
            grpMember.UserOrGroupId = u.Id;
            grpMember.GroupId = grpId;
            grpMembersToInsert.add(grpMember);
        }
        
        if(allGrpMembersToInsert!=null) {
            allGrpMembersToInsert.addAll(grpMembersToInsert);
        } else {
            if (!grpMembersToInsert.isEmpty()) {
                insert grpMembersToInsert;
            }
        }
            
        return grpMembersToInsert.size() + existingAssignedGroupId.size();
    }
    
    private static integer assignUserGroups(User u, String prfName){
        System.debug('Pratik Code Inside assignUserGroups');
        return assignUserGroups(u, prfName, null, null);
    }
   
   public static string IdentifyProfilesToGroups(){
     System.debug('Pratik Code Inside IdentifyProfilesToGroups');
     List<String> inProfiles = new List<String>();
     List<String> outProfiles = new List<String>();
     String statusMsg;

     IdentifyProfilesToGroups(inProfiles, outProfiles);
     statusMsg = 'In Profiles Mapped to Groups: ' + inProfiles;
     statusMsg += '\r\nProfiles not Mapped to Groups: ' + outProfiles;
     return statusMsg;
   }  
   
   /**
    * Show which profiles have been organized to a group and those that have not
    *
    */
   public static void IdentifyProfilesToGroups(List<String> inProfiles, List<String> outProfiles){
	    System.debug('Pratik Code Inside IdentifyProfilesToGroups');
    	Map<String, Set<String>> profileMasksToGroupsMap = getProfileMasksToGroupsMappings();   
     	for(Profile prof : [Select Id, Name from Profile Order By Name]){
        	if (getGroupsForProfile(prof.Name, profileMasksToGroupsMap).size() > 0){
        		inProfiles.add(prof.Name);
        	} else {
        		outProfiles.add(prof.Name);
        	}
     	}
     	System.debug('In Profiles Mapped to Groups: ' + inProfiles);
     	System.debug('In Profiles Mapped to Groups size: ' + inProfiles.size());
     	System.debug('Profiles not Mapped to Groups: ' + outProfiles);
     	System.debug('Profiles not Mapped to Groups size: ' + outProfiles.size());
   }
          
   public static testMethod void testMe(){
        System.debug('Pratik Code Inside testMe');
        debug = true;
        string User = 'DAVIDRB@gene.com.mig';
        string Profile = 'GNE-MedAffairs-MSL';
        List<User> us = new List<User>([Select Id, Name, Profile.Name from User where username like :User]);		
        assignUserGroups(us[0], Profile);
   }
   
   public static void showProfileGroups(){
       System.debug('Pratik Code Inside showProfileGroups');
       Set<Id> prfGroups = getGroupsNotForProfile(null);
       List<Group> grps = [Select id, name from Group where id in :prfGroups];
       for(Group grp: grps) {
       		System.debug(grp.name);
       }
   }    
   
   // oct 18 2011
   // user, profile Id
   // unique key concatenated profile Id + user Id
   // 0. user list (id, profile, isactive) 
   // 1. get profile Id list
   // 2. get profile Id - group Id map
   // 3. compute what it needs to be 
   // 4. extract what exists 
   // insert 3-4 
   // delete 4-3   
   /*
    public static integer assignUserToProfileGroups(List<user> users){
        
        Set<String> profileNameList                     = getProfileNameList(users); // 1
        Map<String, Set<String>> profileToGroupIdList   = getProfileToGroupIdList(profileNameList); // 2
        Set<String> userGroupCurrentSet                 = getUserProfileToGroupSet (users, profleToGrupIdList); // 4
        Set<String> userGroupNewSet                     = computeUserProfileToGroupSet(users, profileToGroupIdList); // 3                
        return true;
    }
    */
}