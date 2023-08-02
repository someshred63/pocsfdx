/****************************************************************************************************************
*  @author: Lukasz Bieniawski, Roche (contractor)
*  @email: lukasz.bieniawski@contractors.roche.com
*  Date: 2014-07-29
*  Description: Methods used to manage changes on All_User_Hierarchy_gne__c and User objects
*  
*  Modification History
*  Date            Name               Description
*****************************************************************************************************************/

public class GNE_SFA2_All_User_Hierarchy_Utils {
		
	private static String getBaseUserHierarchyQuery(){
		String managerRelName = All_User_Hierarchy_gne__c.All_User_Hierarchy_Level1_gne__c.getDescribe().getRelationshipName();
		return String.format('SELECT Id, {0}, {1}, {2}, {3}, {4}, {5}, {6}.{0} FROM All_User_Hierarchy_gne__c ', new String[]{
            	String.valueOf(All_User_Hierarchy_gne__c.User_External_Id_gne__c), 			// 0
            	String.valueOf(All_User_Hierarchy_gne__c.Active_gne__c),					// 1
            	String.valueOf(All_User_Hierarchy_gne__c.FirstName_gne__c),					// 2
            	String.valueOf(All_User_Hierarchy_gne__c.LastName_gne__c),					// 3
            	String.valueOf(All_User_Hierarchy_gne__c.email_id__c),						// 4
            	String.valueOf(All_User_Hierarchy_gne__c.All_User_Hierarchy_Level1_gne__c), // 5
            	managerRelName																// 6
            } 
		);
	}
	
	private static Set<String> getExternalIdsFromUsers(List<User> users){
		Set<String> extIds = new Set<String>();
		if (users == null || users.isEmpty()){
			return extIds;
		}
		for (User u : users){
			if (String.isNotBlank(u.External_ID_gne__c)){
				extIds.add(u.External_ID_gne__c);
			}
		}
		return extIds;
	}
	
	public static void SyncUserManagerForUsers(List<User> users, List<Id> excludeManagers, Boolean allowDml) {
		Set<String> userExtIds = getExternalIdsFromUsers(users);
		String queryUserHierarchy = getBaseUserHierarchyQuery();		
		queryUserHierarchy += ' Where User_External_Id_gne__c In ' + GNE_SFA2_Util.createInListForQuery(new List<String>(userExtIds));
		SyncProperties props = new SyncProperties();
		props.syncOnlyUserManager = true;
		props.allowDml = allowDml;
		props.forUsers = users;
		props.excludeManagers = excludeManagers;
		SyncUserRecord(queryUserHierarchy, props);
	}
	
	public static void SyncUserRecordByHierarchyIds(List<String> recordIds) {
		String queryUserHierarchy = getBaseUserHierarchyQuery();
		queryUserHierarchy += ' WHERE User_External_Id_gne__c <> null AND Id In ' + GNE_SFA2_Util.createInListForQuery(recordIds);
		SyncProperties props = new SyncProperties();
		props.syncOnlyUserManager = false;
		props.allowDml = true;
		props.forUsers = null;
		props.excludeManagers = null;
		SyncUserRecord(queryUserHierarchy, props);
	}
	
	private static void SyncUserRecord(String queryUserHierarchy, SyncProperties props) {
		 // retrieve record details
        Map<String, All_User_Hierarchy_gne__c> userHierarchies = new Map<String, All_User_Hierarchy_gne__c>();
        Set<String> hierarchyManagers = new Set<String>();        
        for (All_User_Hierarchy_gne__c record : Database.query(queryUserHierarchy)){
            if (String.isNotBlank(record.User_External_Id_gne__c)) {
                userHierarchies.put(record.User_External_Id_gne__c.toUpperCase(), record);
                if (record.All_User_Hierarchy_Level1_gne__c != null && String.isNotBlank(record.All_User_Hierarchy_Level1_gne__r.User_External_Id_gne__c)){
                    hierarchyManagers.add(record.All_User_Hierarchy_Level1_gne__r.User_External_Id_gne__c);
                }
            }
        }
        
        if (userHierarchies.size() == 0){
            return;
        }
        
        Map<String, Id> existedManagers = new Map<String, Id>();
        if (hierarchyManagers.size() > 0){
        	String queryManagers = 'SELECT Id, External_Id_gne__c FROM User WHERE IsActive = true AND External_Id_gne__c IN ' + GNE_SFA2_Util.createInListForQuery(new List<String>(hierarchyManagers));
        	if (props.excludeManagers != null){
        		 queryManagers += ' AND Id Not In ' + GNE_SFA2_Util.createInListForQuery(props.excludeManagers);
        	}
            for (User existedManager : Database.query(queryManagers)){
                existedManagers.put(existedManager.External_Id_gne__c.toUpperCase(), existedManager.Id);
            }
        }
        
        List<User> updates = new List<User>();
        Boolean isUpdated = false;
        All_User_Hierarchy_gne__c userHierarchy = null;        
        // loop through records - only active users!
        for (User userRecord : (props.forUsers != null ? props.forUsers 
        	: [SELECT Id, FirstName, LastName, IsActive, Email, External_Id_gne__c, Role_Mgmt_Managed_User_gne__c, ManagerId 
            FROM User WHERE External_Id_gne__c IN :userHierarchies.keyset() AND IsActive = true])) {
            if (String.isBlank(userRecord.External_Id_gne__c) || !userHierarchies.containsKey(userRecord.External_Id_gne__c.toUpperCase())){
            	continue;
            }
            userHierarchy = userHierarchies.get(userRecord.External_Id_gne__c.toUpperCase());
            isUpdated = false;
            // if user is managed by role management
            if (props.syncOnlyUserManager == false && userRecord.IsActive == true && userRecord.Role_Mgmt_Managed_User_gne__c == 'TRUE' ) {
                // update first name if different
                if (userRecord.FirstName != userHierarchy.FirstName_gne__c) {
                    userRecord.FirstName = userHierarchy.FirstName_gne__c;
                    isUpdated = true;
                }
                
                // update last name if different
                if (userRecord.LastName != userHierarchy.LastName_gne__c) {
                    userRecord.LastName = userHierarchy.LastName_gne__c;
                    isUpdated = true;
                }
                
                // user is Active - only deactivation is possible
            	if (userHierarchy.Active_gne__c == false) {
                	userRecord.IsActive = false;
                	isUpdated = true;
            	}
            }
            
            // update manager of the user
            Boolean hasManager = userHierarchy.All_User_Hierarchy_Level1_gne__c != null && 
            	String.isNotBlank(userHierarchy.All_User_Hierarchy_Level1_gne__r.User_External_Id_gne__c) &&
                existedManagers.containsKey(userHierarchy.All_User_Hierarchy_Level1_gne__r.User_External_Id_gne__c.toUpperCase());
                
            if (hasManager == true){
                Id managerIdCandidate = existedManagers.get(userHierarchy.All_User_Hierarchy_Level1_gne__r.User_External_Id_gne__c.toUpperCase());
                if (userRecord.ManagerId != managerIdCandidate){
                    userRecord.ManagerId = managerIdCandidate;
                    isUpdated = true;
                }   
            } else if (hasManager == false && userRecord.ManagerId != null){
                userRecord.ManagerId = null;
                isUpdated = true;
            }
                        
            if (props.allowDml == true && isUpdated == true) {
                updates.add(userRecord);
            }
        }

        // update records if there are any to update
       if (props.allowDml == true && updates.size() > 0) {
            // first disable user delegation functionality to prevent calling future from future scenario
            //GNE_UserDelegationUtils.DisableFutureCalls = true;            
            update updates;   
        }
	}
	
	private class SyncProperties{
		public Boolean syncOnlyUserManager { get; set; } 
		public Boolean allowDml { get; set; }
		public List<User> forUsers { get; set; }
		public List<Id> excludeManagers { get; set; }		
		
		public SyncProperties(){
			this.syncOnlyUserManager = false;
			this.allowDml = true;
			this.forUsers = null;
			this.excludeManagers = null;
		}
	}
}