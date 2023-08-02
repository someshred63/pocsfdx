/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2013-03-27
*  Description: This is a batch for updating user sales roster assignments upon user creation / delete
*  Test Class: GNE_SFA2_UserSalesRosterAssignBatch_Test
*  
*  Modification History
*  Date            Name               Description
*  29-10-2013	   Konrad Russa       Exception for CFAR       
*  09-12-2013	   Bartosz Osowiecki  Remove hard coded time interval (60 minutes) - now it depends when last batch process was executed.
*  18-12-2013      Lukasz Kwiatkowski Added a logic in updateUserSalesRostersBasedPerrSet to insert/update GNE_SFA2_User_App_Context_gne__c records
*  02-01-2014      Bartosz Osowiecki  Added Exception and DML Error hadling. GNE_Batch_Runner is used to log errors and send email notifications
*  19-12-2014	   Lukasz Bieniawski  Added a logic in updateUserSalesRostersBasedPerrSet to insert/delete SFA2_Configuration_Object_Detail_gne__c records
*************************************************************/

public without sharing class GNE_SFA2_User_Sales_Roster_Assign_Batch implements Database.Batchable<sObject>, Database.Stateful, GNE_Batch_Runner.Batchable {
	
	private static System.Type BATCH_CLASS = GNE_SFA2_User_Sales_Roster_Assign_Batch.class;
	private static String OTR_SUPPORT_PERMISSION_SET_NAME = 'GNE_SFA_OTR_Support_Permission_Set';
	
	private Map<String, IC_Calc_Sales_Roster_gne__c> appBrandToSalesRosterMap = new Map<String, IC_Calc_Sales_Roster_gne__c>();
	private Map<Id,User> userCache = new Map<Id,User>();
	
    public Database.QueryLocator start(Database.BatchableContext BC) {
    	return GNE_Batch_Runner.doStart(this,BC);
    }
    
    public Database.QueryLocator intStart(Database.BatchableContext BC) {
        Datetime lastProcessTimeStamp = getLastProcessExecutionTime(BC);
    	System.debug('Starting User Sales Roster batch. lastProcessTimeStamp: ' + lastProcessTimeStamp);
        updateUserSalesRostersBasedPerrSet();
        Map<Id, UserLicense> licenses = new Map<Id, UserLicense>([SELECT Id FROM UserLicense WHERE name IN ('Salesforce Platform', 'Salesforce', 'Salesforce Platform One')]);
        Set<Id> licenseIds = licenses.keySet();
        return Database.getQueryLocator('Select Id, ProfileId, isActive FROM User WHERE Profile.UserLicenseId IN :licenseIds ' + (lastProcessTimeStamp != null ? ' AND LastModifiedDate >= :lastProcessTimeStamp' : ''));
    }
    
    private DateTime getLastProcessExecutionTime(Database.BatchableContext BC) {
    	DateTime lastProcessExecutionTime = null;
    	Id currentJobId = BC.getJobId();
    	String className = GNE_SFA2_User_Sales_Roster_Assign_Batch.class.getName();
    	
    	for(AsyncApexJob job : [SELECT CreatedDate 
								FROM AsyncApexJob
								WHERE ApexClass.Name = :className
									AND Id <> :currentJobId
									AND ParentJobId = null
									AND JobType = 'BatchApex'
									AND Status = 'Completed'
								ORDER BY CreatedDate desc
								LIMIT 1]) {
			lastProcessExecutionTime = job.CreatedDate;	
		}

		System.debug('lastProcessDateTime = ' + lastProcessExecutionTime);
        return lastProcessExecutionTime;    	
    }
    
    private void removeUserSalesRosters(List<User> users) {
        List<SFA2_User_Sales_Roster_gne__c> rostersToDelete = [ SELECT Id, User_gne__c FROM SFA2_User_Sales_Roster_gne__c WHERE User_gne__c in :users ];
        executeDML(rostersToDelete, GNE_Batch_Runner.DMLType.DELETE_DML, 'Delete Existing User Sales Roster');
        
        List<GNE_SFA2_User_App_Context_gne__c> userContextToDelete = [ SELECT Id, SetupOwnerId FROM GNE_SFA2_User_App_Context_gne__c WHERE SetupOwnerId in :users ];
        executeDML(userContextToDelete, GNE_Batch_Runner.DMLType.DELETE_DML, 'Delete Existing User App Context');
    }

    private Map<String,IC_Calc_Sales_Roster_gne__c> createAppRole() {
    	if(appBrandToSalesRosterMap.isEmpty()) {
	        for(IC_Calc_Sales_Roster_gne__c salesRoster : [ SELECT Id, Type_gne__c, Brand_Name_gne__c, User_Role_gne__c FROM IC_Calc_Sales_Roster_gne__c ]) {
	        	String key = salesRoster.Type_gne__c + (String.isNotBlank(salesRoster.Brand_Name_gne__c) ? salesRoster.Brand_Name_gne__c : '');
                if (String.isNotBlank(salesRoster.User_Role_gne__c)){
                    key += '-' + salesRoster.User_Role_gne__c;
                }
	        	appBrandToSalesRosterMap.put(key, salesRoster);
	        }
    	}
        
        return appBrandToSalesRosterMap;
        
    }
    
    private void updateUserSalesRostersBasedPerrSet() {
        Map<String, IC_Calc_Sales_Roster_gne__c> appRoleToSalesRoster = createAppRole();
        
        List<SFA2_User_Sales_Roster_gne__c> userSalesRostersToInsert = new List<SFA2_User_Sales_Roster_gne__c>();
        List<SFA2_User_Sales_Roster_gne__c> userSalesRostersToDelete = new List<SFA2_User_Sales_Roster_gne__c>();
        List<GNE_SFA2_User_App_Context_gne__c> appContextToInsert = new List<GNE_SFA2_User_App_Context_gne__c>();
        List<SFA2_Configuration_Object_Detail_gne__c> configurationObjDetailsToInsert = new List<SFA2_Configuration_Object_Detail_gne__c>();        
       	List<SFA2_Configuration_Object_Detail_gne__c> configurationObjDetailsToDelete = new List<SFA2_Configuration_Object_Detail_gne__c>();
        
        Map<String,SFA2_User_Group_Mapping_gne__c> permissionSetNameToAppMap = new Map<String,SFA2_User_Group_Mapping_gne__c>();
        List<SFA2_User_Group_Mapping_gne__c> listOfOtrSupportGroups = new List<SFA2_User_Group_Mapping_gne__c>();
        Set<String> gFRSDefaultProfilesFromMappingSet = new Set<String>();  
        Set<String> cfarDefaultProfilesFromMappingSet = new Set<String>();
        Set<String> contentDefaultProfilesFromMappingSet = new Set<String>();
        Map<String,Id> allPermissiontSetAssignmentMap = new Map<String,Id>(); 
        Set<String> userSalesRosterSet = new Set<String>();
        Set<Id> alreadyAddedContexts = new Set<Id>();   // store the set of already added GNE_SFA2_User_App_Context_gne__c records to avoid duplicate entries

        Set<Id> allUserIdsWithEdmPermissionSet = new Set<Id>();
        Set<Id> userIdsToBeAddedToEdmUsersGroup = new Set<Id>();
        //ManageGroupMembersHelper manageGroupMembersHlp = new ManageGroupMembersHelper();
        Set<String> edmUsersPermissionNamesSet = new Set<String> {
            'EDM_AB_Approver',
            'EDM_AB_Approver_no_license',
            'EDM_AB_Reviewer',
            'EDM_AB_Reviewer_no_license',
            'EDM_ABM_AB_Lead_no_license',
            'EDM_ABS_Manager',
            'EDM_Classification_Review',
            'EDM_VDST_Partner_External_ABM'
        };        

        Id systemAdminProfileId = [select Id from Profile where Name = 'System Administrator'].Id;
        
        List<SFA2_User_Group_Mapping_gne__c> groupMappingList = [
                SELECT Id, Profile_Name_gne__c, Application_gne__c, Brand_gne__c, Role_gne__c, Permission_Set_Name_gne__c 
                FROM SFA2_User_Group_Mapping_gne__c WHERE Application_gne__c != 'MPS'
        ];
        Set<String> perrSetNames = new Set<String>();
        for(SFA2_User_Group_Mapping_gne__c ugm : groupMappingList) {
            perrSetNames.add(ugm.Permission_Set_Name_gne__c);
        } 

        List<PermissionSetAssignment> permissionSetAssignmentList = [SELECT AssigneeId, Assignee.Profile.Name, PermissionSet.Name
                                                                    FROM PermissionSetAssignment
                                                                    WHERE PermissionSet.isOwnedByProfile = false
                                                                    AND PermissionSet.Name IN : perrSetNames
                                                                    AND Assignee.Profile.Id != :systemAdminProfileId];
        List<SFA2_User_Sales_Roster_gne__c> userSalesRosterList = [SELECT Id, User_gne__c, Sales_Roster_gne__r.Type_gne__c, Profile_Name_gne__c 
                                                                   FROM SFA2_User_Sales_Roster_gne__c 
                                                                   WHERE User_gne__r.ProfileId != :systemAdminProfileId 
                                                                       AND Sales_Roster_gne__r.Type_gne__c != 'ICCalc' 
                                                                       AND Sales_Roster_gne__r.Type_gne__c != 'SFA-US' 
                                                                       AND Sales_Roster_gne__r.Type_gne__c != 'MedAffairs' 
                                                                       AND Sales_Roster_gne__r.Type_gne__c != 'MCCO' 
                                                                       AND Sales_Roster_gne__r.Type_gne__c != 'SFA-Canada' 
                                                                       AND Sales_Roster_gne__r.Type_gne__c != 'TLCRM'
                                                                       AND Sales_Roster_gne__r.Type_gne__c != 'PROSPECT'
                                                                       AND Sales_Roster_gne__r.Type_gne__c != 'MCCO CRM'
                                                                       AND Sales_Roster_gne__r.Type_gne__c != 'MPS'
                                                                   ];
        
        for(SFA2_User_Group_Mapping_gne__c userGroupMapping : groupMappingList) {
            if(String.isNotBlank(userGroupMapping.Permission_Set_Name_gne__c)) {
                permissionSetNameToAppMap.put(userGroupMapping.Permission_Set_Name_gne__c, userGroupMapping);
                if (userGroupMapping.Permission_Set_Name_gne__c == OTR_SUPPORT_PERMISSION_SET_NAME){
                	listOfOtrSupportGroups.add(userGroupMapping);
                }
            }
            
            if(userGroupMapping.Application_gne__c == 'gFRS' && String.isNotBlank(userGroupMapping.Profile_Name_gne__c)) {
                gFRSDefaultProfilesFromMappingSet.add(userGroupMapping.Profile_Name_gne__c);
            }
            
            if(userGroupMapping.Application_gne__c == 'CFAR' && String.isNotBlank(userGroupMapping.Profile_Name_gne__c)) {
                cfarDefaultProfilesFromMappingSet.add(userGroupMapping.Profile_Name_gne__c);
            }

            if(userGroupMapping.Application_gne__c == 'Content' && String.isNotBlank(userGroupMapping.Profile_Name_gne__c)) {
                contentDefaultProfilesFromMappingSet.add(userGroupMapping.Profile_Name_gne__c);
            }
                                                                                   
        }
        
        for(SFA2_User_Sales_Roster_gne__c userSalesRoster : userSalesRosterList) {
            userSalesRosterSet.add(userSalesRoster.Sales_Roster_gne__r.Type_gne__c + userSalesRoster.User_gne__c);          
        }
        
        for(PermissionSetAssignment permissionSetAssignment : permissionSetAssignmentList) {
            String permissiontSetAssignmentMapKey = '';
            
            permissiontSetAssignmentMapKey = permissionSetNameToAppMap.get(permissionSetAssignment.PermissionSet.Name).Application_gne__c + permissionSetAssignment.AssigneeId;
            allPermissiontSetAssignmentMap.put(permissiontSetAssignmentMapKey, permissionSetAssignment.AssigneeId);
        
            if(!userSalesRosterSet.contains(permissiontSetAssignmentMapKey) && appRoleToSalesRoster.containsKey(permissionSetNameToAppMap.get(permissionSetAssignment.PermissionSet.Name).Application_gne__c)) {
                SFA2_User_Sales_Roster_gne__c newUserSalesRoster = new SFA2_User_Sales_Roster_gne__c();
                newUserSalesRoster.User_gne__c = permissionSetAssignment.AssigneeId;
                newUserSalesRoster.Role_gne__c = permissionSetNameToAppMap.get(permissionSetAssignment.PermissionSet.Name).Role_gne__c;
                newUserSalesRoster.Is_Active_gne__c = true;
                newUserSalesRoster.Profile_Name_gne__c = permissionSetAssignment.Assignee.Profile.Name;
                String appName = permissionSetNameToAppMap.get(permissionSetAssignment.PermissionSet.Name).Application_gne__c;
                
                if(!setSalesRosterId(newUserSalesRoster, appName, appRoleToSalesRoster)) {
                	// IC Sales Roster doesn't exist. Report an error an continue to next record
                    continue;
                }
                
                userSalesRostersToInsert.add(newUserSalesRoster);
                userSalesRosterSet.add(appName + newUserSalesRoster.User_gne__c);
                
                GNE_SFA2_User_App_Context_gne__c userAppContext = GNE_SFA2_User_App_Context_gne__c.getInstance(permissionSetAssignment.AssigneeId);
                userAppContext.App_Name_gne__c = permissionSetNameToAppMap.get(permissionSetAssignment.PermissionSet.Name).Application_gne__c;
                userAppContext.Brand_gne__c = permissionSetNameToAppMap.get(permissionSetAssignment.PermissionSet.Name).Brand_gne__c;
                userAppContext.Role_gne__c = permissionSetNameToAppMap.get(permissionSetAssignment.PermissionSet.Name).Role_gne__c;
                userAppContext.SFA2_Mode_gne__c = true;
                
                if (!alreadyAddedContexts.contains(permissionSetAssignment.AssigneeId) && userAppContext.Id == null) {
                    appContextToInsert.add(userAppContext);
                    alreadyAddedContexts.add(permissionSetAssignment.AssigneeId);
                }
            }

            //if(manageGroupMembersHlp.edmUsersPermissionNamesSet.contains(permissionSetAssignment.PermissionSet.Name)) {
            if(edmUsersPermissionNamesSet.contains(permissionSetAssignment.PermissionSet.Name)) {
                allUserIdsWithEdmPermissionSet.add(permissionSetAssignment.AssigneeId);
                //if(!manageGroupMembersHlp.edmUserGroupMemberIdSet.contains(permissionSetAssignment.AssigneeId)) {
                //    userIdsToBeAddedToEdmUsersGroup.add(permissionSetAssignment.AssigneeId);
                //}
            }
        }
        
        for(SFA2_User_Sales_Roster_gne__c userSalesRoster : userSalesRosterList) {
            String salesRosterMapKey = userSalesRoster.Sales_Roster_gne__r.Type_gne__c + userSalesRoster.User_gne__c;
            if(userSalesRoster.Sales_Roster_gne__r.Type_gne__c != 'gFRS' && userSalesRoster.Sales_Roster_gne__r.Type_gne__c != 'CFAR' && userSalesRoster.Sales_Roster_gne__r.Type_gne__c != 'Chatter' && userSalesRoster.Sales_Roster_gne__r.Type_gne__c != 'Content') {
                if(!allPermissiontSetAssignmentMap.containsKey(salesRosterMapKey)) {
                    userSalesRostersToDelete.add(userSalesRoster);
                }
            } else if (userSalesRoster.Sales_Roster_gne__r.Type_gne__c == 'gFRS'){
                if(!gFRSDefaultProfilesFromMappingSet.contains(userSalesRoster.Profile_Name_gne__c)) {
                    if(!allPermissiontSetAssignmentMap.containsKey(salesRosterMapKey)) {
                        userSalesRostersToDelete.add(userSalesRoster);
                    }       
                }
            } else if (userSalesRoster.Sales_Roster_gne__r.Type_gne__c == 'CFAR'){
                if(!cfarDefaultProfilesFromMappingSet.contains(userSalesRoster.Profile_Name_gne__c)) {
                    if(!allPermissiontSetAssignmentMap.containsKey(salesRosterMapKey)) {
                        userSalesRostersToDelete.add(userSalesRoster);
                    }       
                }
            } else if (userSalesRoster.Sales_Roster_gne__r.Type_gne__c == 'Chatter'){
                if(!GNE_SFA2_Util.isUserHasAccessToChatter(userSalesRoster.Profile_Name_gne__c, userSalesRoster.User_gne__c)) {
                    if(!allPermissiontSetAssignmentMap.containsKey(salesRosterMapKey)) {
                        userSalesRostersToDelete.add(userSalesRoster);
                    }       
                }
            } else if (userSalesRoster.Sales_Roster_gne__r.Type_gne__c == 'Content'){
                if(!contentDefaultProfilesFromMappingSet.contains(userSalesRoster.Profile_Name_gne__c)) {
                    if(!allPermissiontSetAssignmentMap.containsKey(salesRosterMapKey)) {
                        userSalesRostersToDelete.add(userSalesRoster);
                    }       
                }
            }
        }
        
        // Add or remove "OTR / SFA Support Dashboard" menu more item button if needed
       	configurationObjDetailsToInsert.addAll(getNewItemConfigurationsForOTRSupportGroup(listOfOtrSupportGroups, configurationObjDetailsToDelete));
       	
       	System.debug('##### User Sales Roster To Add === ' + userSalesRostersToInsert);
        System.debug('##### User Sales Roster To Delete === ' + userSalesRostersToDelete);
        System.debug('##### Application Context To Insert === ' + appContextToInsert);
        System.debug('configurationObjDetailsToInsert === ' + configurationObjDetailsToInsert);
       	System.debug('configurationObjDetailsToDelete === ' + configurationObjDetailsToDelete);
        
        if(!userSalesRostersToInsert.isEmpty()) {
        	executeDML(userSalesRostersToInsert, GNE_Batch_Runner.DMLType.INSERT_DML, 'Insert Non-SFA User Sales Roster based on Permission Sets');
        }
        
        if(!userSalesRostersToDelete.isEmpty()) {
        	executeDML(userSalesRostersToDelete, GNE_Batch_Runner.DMLType.DELETE_DML, 'Delete Non-SFA User Sales Roster based on Permission Sets');
        }
        
        if(!appContextToInsert.isEmpty()) {
			executeDML(appContextToInsert, GNE_Batch_Runner.DMLType.INSERT_DML, 'Insert Non-SFA User App Context based on Permission Sets');
        }
        
        if (!configurationObjDetailsToInsert.isEmpty()){
       		executeDML(configurationObjDetailsToInsert, GNE_Batch_Runner.DMLType.INSERT_DML, 'Insert Configuration Object Details based on Permission Sets');
       	}
       	
       	if (!configurationObjDetailsToDelete.isEmpty()){
       		executeDML(configurationObjDetailsToDelete, GNE_Batch_Runner.DMLType.DELETE_DML, 'Delete Configuration Object Details based on Permission Sets');
       	}
/*
        if(!userIdsToBeAddedToEdmUsersGroup.isEmpty()) {
            System.enqueueJob(new InsertGroupMemberRecordsQueueable(this, userIdsToBeAddedToEdmUsersGroup, manageGroupMembersHlp.edmUserGroupId));
        } else {
            if(manageGroupMembersHlp.edmUserGroupMemberIdSet.removeAll(allUserIdsWithEdmPermissionSet)) {
                if(!manageGroupMembersHlp.edmUserGroupMemberIdSet.isEmpty()) {
                    System.enqueueJob(new DeleteGroupMemberRecordsQueueable(this, manageGroupMembersHlp.edmUserGroupMemberIdSet, manageGroupMembersHlp.edmUserGroupId));
                }
            }
        }
*/
        if(Math.mod(Datetime.now().hour(), 2) == 0) {
            System.enqueueJob(new UpdateUserSalesRostersBasedPerrSetForMPS(this));
        } else {
            System.enqueueJob(new ManageEDMUsersGroupMembersQueueable(this, allUserIdsWithEdmPermissionSet));
        }

    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope) {
    	GNE_Batch_Runner.doExecute(this,BC, scope);
    }
    
    public void intExecute(Database.BatchableContext BC, List<sObject> scope) {
        System.debug('Executing User Sales Roster batch with scope: ' + scope);
        cacheUsers((new Map<Id,SObject>(scope)).keySet());
        
        // first remove all current user sales roster 
        removeUserSalesRosters((List<User>) scope);
        
        Map<Id, String> profileIdToName = new Map<Id, String>();
        for(Profile p : [ SELECT Id, Name FROM Profile WHERE Id IN (SELECT ProfileId FROM User WHERE Id IN :scope) ] ) {
            profileIdToName.put(p.Id, p.Name);
        }
        
        Set<String> mapUserToApplication = new Set<String>();
        
        // retrieve existing permission sets for new user
        List<String> permissionSetNames = new List<String>();
        Map<Id, List<PermissionSetAssignment>> permissionSetAssignmentMap = new Map<Id, List<PermissionSetAssignment>>();
        for(PermissionSetAssignment assignment : [ SELECT AssigneeId, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId IN :scope]) {
            permissionSetNames.add(assignment.PermissionSet.Name);
            if(permissionSetAssignmentMap.get(assignment.AssigneeId) == null) {
                permissionSetAssignmentMap.put(assignment.AssigneeId, new List<PermissionSetAssignment>());
            }
            permissionSetAssignmentMap.get(assignment.AssigneeId).add(assignment);
        }
        
        // retrieve mappings 
        Map<String, List<SFA2_User_Group_Mapping_gne__c>> profileNameToUserGroup = new Map<String, List<SFA2_User_Group_Mapping_gne__c>>();
        Map<String, List<SFA2_User_Group_Mapping_gne__c>> permissionSetNameToUserGroup = new Map<String, List<SFA2_User_Group_Mapping_gne__c>>();
        
        for(SFA2_User_Group_Mapping_gne__c userGroupMapping : [ SELECT Id, Profile_Name_gne__c, Permission_Set_Name_gne__c, Application_gne__c, Brand_gne__c, Role_gne__c FROM SFA2_User_Group_Mapping_gne__c WHERE (Profile_Name_gne__c IN :profileIdToName.values() OR Permission_Set_Name_gne__c IN :permissionSetNames) ]) {
            if(String.isNotBlank(userGroupMapping.Profile_Name_gne__c)) {
                if(profileNameToUserGroup.get(userGroupMapping.Profile_Name_gne__c) == null) {
                    profileNameToUserGroup.put(userGroupMapping.Profile_Name_gne__c, new List<SFA2_User_Group_Mapping_gne__c>());
                }
                profileNameToUserGroup.get(userGroupMapping.Profile_Name_gne__c).add(userGroupMapping);    
            } else {
                if(permissionSetNameToUserGroup.get(userGroupMapping.Permission_Set_Name_gne__c) == null) {
                    permissionSetNameToUserGroup.put(userGroupMapping.Permission_Set_Name_gne__c, new List<SFA2_User_Group_Mapping_gne__c>());
                }
                permissionSetNameToUserGroup.get(userGroupMapping.Permission_Set_Name_gne__c).add(userGroupMapping);
            }
            
        }
        
        // create app role to IC Calc Sales Roster
        Map<String, IC_Calc_Sales_Roster_gne__c> appRoleToSalesRoster = createAppRole();

        List<SFA2_User_Sales_Roster_gne__c> userSalesRostersToInsert = new List<SFA2_User_Sales_Roster_gne__c>();
        List<GNE_SFA2_User_App_Context_gne__c> appContextToInsert = new List<GNE_SFA2_User_App_Context_gne__c>();
        Set<String> userSalesRosterSet = new Set<String>();   
        Set<Id> alreadyAddedContexts = new Set<Id>();	// store the set of already added GNE_SFA2_User_App_Context_gne__c records to avoid duplicate entries
        
        for(User newUser : (List<User>) scope) {
            // handle assignments based on profile
            if(profileNameToUserGroup.size() > 0) {                                     
                if(profileNameToUserGroup.containsKey(profileIdToName.get(newUser.ProfileId))) {
                    for(SFA2_User_Group_Mapping_gne__c userGroupMapping : profileNameToUserGroup.get(profileIdToName.get(newUser.ProfileId))) {
                        // insert user sales roster
                        SFA2_User_Sales_Roster_gne__c newUserSalesRoster = new SFA2_User_Sales_Roster_gne__c();
                        if(userGroupMapping.Application_gne__c == 'gFRS') {
                            newUserSalesRoster.User_gne__c = newUser.Id;
                            newUserSalesRoster.Role_gne__c = userGroupMapping.Role_gne__c;
                            newUserSalesRoster.Is_Active_gne__c = true;
                            newUserSalesRoster.Profile_Name_gne__c = profileIdToName.get(newUser.ProfileId);
                            if(!setSalesRosterId(newUserSalesRoster, userGroupMapping.Application_gne__c, appRoleToSalesRoster)) {
                                // IC Sales Roster doesn't exist. Report an error an continue to next record
                                continue;
	                        }
                        } else if(userGroupMapping.Application_gne__c == 'CFAR') {
                            newUserSalesRoster.User_gne__c = newUser.Id;
                            newUserSalesRoster.Role_gne__c = userGroupMapping.Role_gne__c;
                            newUserSalesRoster.Is_Active_gne__c = true;
                            newUserSalesRoster.Profile_Name_gne__c = profileIdToName.get(newUser.ProfileId);
                            if(!setSalesRosterId(newUserSalesRoster, userGroupMapping.Application_gne__c, appRoleToSalesRoster)) {
                                // IC Sales Roster doesn't exist. Report an error an continue to next record
                                continue;
	                        }
                        } else {
                            if(userGroupMapping.Brand_gne__c != 'Avastin_Tarceva') {
                                newUserSalesRoster.User_gne__c = newUser.Id;
                                newUserSalesRoster.Role_gne__c = userGroupMapping.Role_gne__c;
                                newUserSalesRoster.Is_Active_gne__c = true;
                                newUserSalesRoster.Profile_Name_gne__c = profileIdToName.get(newUser.ProfileId);
                                String icKeyByBrand = userGroupMapping.Application_gne__c + (String.isNotBlank(userGroupMapping.Brand_gne__c) ? userGroupMapping.Brand_gne__c : '');
                                Boolean icCalcFound = false;
                                if (String.isNotBlank(userGroupMapping.Role_gne__c)){
                                    String icKeyByRole = icKeyByBrand + '-' + userGroupMapping.Role_gne__c;
                                    if(appRoleToSalesRoster.containsKey(icKeyByRole)) {
                                        if (!setSalesRosterId(newUserSalesRoster, icKeyByRole, appRoleToSalesRoster)) {
                                            // IC Sales Roster doesn't exist. Report an error an continue to next record
                                            continue;
                                        } else {
                                            icCalcFound = true;
                                        }
                                    }
                                }
                                if (!icCalcFound){
                                    if (String.isNotBlank(userGroupMapping.Brand_gne__c) && appRoleToSalesRoster.containsKey(icKeyByBrand)) {
                                        if(!setSalesRosterId(newUserSalesRoster, icKeyByBrand, appRoleToSalesRoster)) {
                                		  // IC Sales Roster doesn't exist. Report an error an continue to next record
                                		  continue;
	                                   }
                                    } else {
                                	   if(!setSalesRosterId(newUserSalesRoster, userGroupMapping.Application_gne__c, appRoleToSalesRoster)) {
                                		  // IC Sales Roster doesn't exist. Report an error an continue to next record
                                		  continue;
	                                   }
                                    }
                                }
                            } else {
                                SFA2_User_Sales_Roster_gne__c newUserSalesRosterAvastin = new SFA2_User_Sales_Roster_gne__c();
                                newUserSalesRosterAvastin.User_gne__c = newUser.Id;
                                newUserSalesRosterAvastin.Role_gne__c = userGroupMapping.Role_gne__c;
                                newUserSalesRosterAvastin.Is_Active_gne__c = true;
                                newUserSalesRosterAvastin.Profile_Name_gne__c = profileIdToName.get(newUser.ProfileId);
                                newUserSalesRosterAvastin.Sales_Roster_gne__c = appRoleToSalesRoster.get(userGroupMapping.Application_gne__c + 'Avastin').Id;
                                userSalesRostersToInsert.add(newUserSalesRosterAvastin);   
                                
                                SFA2_User_Sales_Roster_gne__c newUserSalesRosterTarceva = new SFA2_User_Sales_Roster_gne__c();
                                newUserSalesRosterTarceva.User_gne__c = newUser.Id;
                                newUserSalesRosterTarceva.Role_gne__c = userGroupMapping.Role_gne__c;
                                newUserSalesRosterTarceva.Is_Active_gne__c = true;
                                newUserSalesRosterTarceva.Profile_Name_gne__c = profileIdToName.get(newUser.ProfileId);
                                
                                if(!setSalesRosterId(newUserSalesRosterTarceva, userGroupMapping.Application_gne__c + 'Tarceva', appRoleToSalesRoster)) {
                                	// IC Sales Roster doesn't exist. Report an error an continue to next record
                                	continue;
                                }
                                
                                userSalesRostersToInsert.add(newUserSalesRosterTarceva);
                            }
                        }

                        if(newUserSalesRoster != null && !userSalesRosterSet.contains(String.valueOf(newUserSalesRoster.Sales_Roster_gne__c) + String.valueOf(newUserSalesRoster.User_gne__c))) {
                            userSalesRostersToInsert.add(newUserSalesRoster);
                            userSalesRosterSet.add(String.valueOf(newUserSalesRoster.Sales_Roster_gne__c) + String.valueOf(newUserSalesRoster.User_gne__c));
                        }
                        
                        GNE_SFA2_User_App_Context_gne__c userAppContext = GNE_SFA2_User_App_Context_gne__c.getInstance(newUser.Id);
                        userAppContext.App_Name_gne__c = userGroupMapping.Application_gne__c;
                        userAppContext.Brand_gne__c = userGroupMapping.Brand_gne__c;
                        userAppContext.Role_gne__c = userGroupMapping.Role_gne__c;
                        userAppContext.SFA2_Mode_gne__c = true;
                        
                        mapUserToApplication.add(newUser.Id + userGroupMapping.Application_gne__c);
                        
                        if(!alreadyAddedContexts.contains(newUser.Id) && userAppContext.Id == null) {
                        	appContextToInsert.add(userAppContext);
                        	alreadyAddedContexts.add(newUser.Id);
                        }
                    }
                    
                }
            }

            // handle assignments based on permission set
            if(permissionSetNameToUserGroup.size() > 0 && permissionSetAssignmentMap.containsKey(newUser.Id)) {
            	for(PermissionSetAssignment permissionAssignment : permissionSetAssignmentMap.get(newUser.Id)) {
                	for(String permissionSetName : permissionSetNameToUserGroup.keySet()) {
                    	for(SFA2_User_Group_Mapping_gne__c userGroupMapping : permissionSetNameToUserGroup.get(permissionSetName)) {
                        	if(permissionAssignment.PermissionSet.Name.equalsIgnoreCase(permissionSetName)) {
                            	// insert user sales roster
                                SFA2_User_Sales_Roster_gne__c newUserSalesRoster = new SFA2_User_Sales_Roster_gne__c();
                                newUserSalesRoster.User_gne__c = newUser.Id;
                                newUserSalesRoster.Role_gne__c = userGroupMapping.Role_gne__c;
                                newUserSalesRoster.Is_Active_gne__c = true;
                                newUserSalesRoster.Profile_Name_gne__c = profileIdToName.get(newUser.ProfileId);
                                if(!setSalesRosterId(newUserSalesRoster, userGroupMapping.Application_gne__c, appRoleToSalesRoster)) {
                                	// IC Sales Roster doesn't exist. Report an error an continue to next record
                                	continue;
                                }
                                
                                if(!mapUserToApplication.contains(newUser.Id + userGroupMapping.Application_gne__c)) {
                                	if(!userSalesRosterSet.contains(String.valueOf(newUserSalesRoster.Sales_Roster_gne__c) + String.valueOf(newUserSalesRoster.User_gne__c))) {
                                        userSalesRostersToInsert.add(newUserSalesRoster);
                                        userSalesRosterSet.add(String.valueOf(newUserSalesRoster.Sales_Roster_gne__c) + String.valueOf(newUserSalesRoster.User_gne__c));
                                    }
                                }
                                   
                                GNE_SFA2_User_App_Context_gne__c userAppContext = GNE_SFA2_User_App_Context_gne__c.getInstance(newUser.Id);
			                    userAppContext.App_Name_gne__c = userGroupMapping.Application_gne__c;
			                    userAppContext.Brand_gne__c = userGroupMapping.Brand_gne__c;
			                    userAppContext.Role_gne__c = userGroupMapping.Role_gne__c;
			                    userAppContext.SFA2_Mode_gne__c = true;
			                    if(!alreadyAddedContexts.contains(newUser.Id) && userAppContext.Id == null) {
				                  	appContextToInsert.add(userAppContext);
				                  	alreadyAddedContexts.add(newUser.Id);
			                    }
                           }
                       }
                   }
               }
            }
        }
        
        System.debug('##### User Sales Roster To Add === ' + userSalesRostersToInsert);
        System.debug('##### Application Context To Insert === ' + appContextToInsert);
        
        if(!userSalesRostersToInsert.isEmpty()) {
        	executeDML(userSalesRostersToInsert, GNE_Batch_Runner.DMLType.INSERT_DML, 'Insert User Sales Rosters');
        }

        if(!appContextToInsert.isEmpty()) {
        	executeDML(appContextToInsert, GNE_Batch_Runner.DMLType.INSERT_DML, 'Insert User App Context');
        }
    }
    
    private Boolean setSalesRosterId(SFA2_User_Sales_Roster_gne__c userSalesRoster, String appBrandKey, Map<String, IC_Calc_Sales_Roster_gne__c> appRoleToSalesRoster) {
    	Boolean salesRosterExists = false;
    	
    	if(!(salesRosterExists = appRoleToSalesRoster.containsKey(appBrandKey))) {
    		GNE_Batch_Runner.handleException(this, 
    				new MissingSalesRosterException('Sales Roster is missing for Application(Brand) key: ' + appBrandKey),
    				userSalesRoster);		
    	} else {
    		userSalesRoster.Sales_Roster_gne__c = appRoleToSalesRoster.get(appBrandKey).Id;
    	}
    	
    	return salesRosterExists;
    }
    
    private void executeDML(List<SObject> sObjs, GNE_Batch_Runner.DMLType dType, String actionDescription) {
    	GNE_Batch_Runner.executeDML(this, SObjs, dType, null, actionDescription);
    }
    
    private User getUserForRecord(SObject sObj) {
    	String userId = getKeyForRecord(sObj);
    	return userCache.get((Id)userId);  
    }
    
    // START GNE_Batch_Runner.Batchable interface methods
    public System.Type getBatchClass() {
    	return BATCH_CLASS;
    }
    
    public String getBatchName() {
    	return 'User Sales Roster Batch';
    }
    
    public String getKeyForRecord(SObject sObj) {
    	String userId = null;
    	if(sObj.getSObjectType() == SFA2_User_Sales_Roster_gne__c.sObjectType) {
    		userId = ((SFA2_User_Sales_Roster_gne__c)sObj).User_gne__c;
    	} else if(sObj.getSObjectType() == GNE_SFA2_User_App_Context_gne__c.sObjectType) {
    		userId = ((GNE_SFA2_User_App_Context_gne__c)sObj).SetupOwnerId;
    	}
    	
    	return userId;
    }
    
    public void processDatabaseErrors(List<SObject> sObjs, Map<String,List<Database.Error>> recToErrorsMap, String actionId, String actionDescription) {
    	Set<Id> userIds = new Set<Id>();
	    	
	   	for(SObject sObj : sObjs) {
	   		String userId = getKeyForRecord(sObj);
	   		
	   		if(recToErrorsMap.containsKey(userId) && !recToErrorsMap.get(userId).isEmpty()) {
	   			userIds.add((Id)userId);
	   		}
	   	}
	   	
	   	cacheUsers(userIds);
	}
	
	public String getErrorEmailDescription(String actionId, SObject sObj, Database.Error err) {
		String sObjId = sObj.Id!=null ? (String)sObj.Id : ('New ' + sObj.getSObjectType().getDescribe().getName());
    	return String.format('{0} [{1}]: {2}', new String[]{getRecordDescription(sObj), sObjId, err.getMessage()});
	}
	
	public String getRecordDescription(SObject sObj) {
		String result = null;
    	User user = getUserForRecord(sObj);
    	 
    	if(user!=null) {
    		result = String.format('{0} ({1}, {2}, {3})', new String[]{user.Name, user.Id, user.Email, user.Profile.Name});
    	} else {
    		result = getKeyForRecord(sObj);
    	}
    	
    	return result;
	}
	// END GNE_Batch_Runner.Batchable interface methods
    
    private void cacheUsers(Set<Id> userIds) {
    	if(!userIds.isEmpty()) {
    		Set<Id> newIds = userIds.clone();
    		newIds.removeAll(userCache.keySet());
    		
    		if(!newIds.isEmpty()) {
    			userCache.putAll(new Map<Id,User>([SELECT Id, Name, Email, Profile.Name FROM User WHERE Id IN :newIds]));
    		}
    	}
    }
    
    private List<SFA2_Configuration_Object_Detail_gne__c> getNewItemConfigurationsForOTRSupportGroup(List<SFA2_User_Group_Mapping_gne__c> userGroupMappingsAuthorized, List<SFA2_Configuration_Object_Detail_gne__c> configurationObjDetailsToDelete){
    	List<SFA2_Configuration_Object_Detail_gne__c> result = new List<SFA2_Configuration_Object_Detail_gne__c>();
    	String otrSupportDashboardButtonName = 'OTR / SFA Support Dashboard';
    	Set<String> appExtIdsAuthorized = new Set<String>();
    	if (!userGroupMappingsAuthorized.isEmpty()){
    		Set<String> applicationsNames = new Set<String>();
       		Set<String> brandsNames = new Set<String>();
       		Set<String> rolesNames = new Set<String>();       		        
       		for (SFA2_User_Group_Mapping_gne__c userGroupMapping : userGroupMappingsAuthorized){
       			applicationsNames.add(userGroupMapping.Application_gne__c);
       			brandsNames.add(userGroupMapping.Brand_gne__c);
       			rolesNames.add(userGroupMapping.Role_gne__c);
       			appExtIdsAuthorized.add(getConfigurationExternalIdUC(userGroupMapping.Application_gne__c, userGroupMapping.Brand_gne__c, userGroupMapping.Role_gne__c));
       		}
       		result = getConfigurationsForOTRSupportGroupToEnable(applicationsNames, brandsNames, rolesNames, appExtIdsAuthorized, otrSupportDashboardButtonName);    		
    	}    	
    	configurationObjDetailsToDelete.addAll(getConfigurationsForOTRSupportGroupToDisable(appExtIdsAuthorized, otrSupportDashboardButtonName));
		return result;
    }
    
    private List<SFA2_Configuration_Object_Detail_gne__c> getConfigurationsForOTRSupportGroupToEnable(Set<String> applications, Set<String> brands, Set<String> roles, Set<String> appExtIds, String otrSupportDashboardButtonName){
    	List<SFA2_Configuration_Object_Detail_gne__c> result = new List<SFA2_Configuration_Object_Detail_gne__c>();
    	for (SFA2_Configuration_Object_gne__c menuItem : [SELECT Id, Application_Type__c, Brand_gne__c, Role_gne__c, 
       		(SELECT Label_gne__c, Order_gne__c, API_Name_gne__c FROM Configuration_Objects__r WHERE Type_gne__c = 'Menu Item' AND Name = 'External Links' Order BY Order_gne__c ASC) 
			FROM SFA2_Configuration_Object_gne__c WHERE Configuration_Type_gne__c = 'Menu Layout' AND Name = 'More' AND Application_Type__c IN :applications AND Brand_gne__c IN :brands AND Role_gne__c IN :roles
			ORDER BY Application_Type__c, Brand_gne__c, Role_gne__c]){
			String appExtId = getConfigurationExternalIdUC(menuItem.Application_Type__c, menuItem.Brand_gne__c, menuItem.Role_gne__c);
			if (!appExtIds.contains(appExtId)){
				continue;
			}
			Double lastItemOrder = 1;				
			Boolean buttonFound = false;
			Boolean newItemOrderFound = false;		
			for (SFA2_Configuration_Object_Detail_gne__c menuMoreItem : menuItem.Configuration_Objects__r){
				if (menuMoreItem.Label_gne__c == otrSupportDashboardButtonName){
					buttonFound = true;
					break;
				}
				if (newItemOrderFound == false){
					if (menuMoreItem.API_Name_gne__c == 'ApplicationsList' && menuMoreItem.Order_gne__c != null && menuMoreItem.Order_gne__c - lastItemOrder > 1){
						newItemOrderFound = true;						
					} else {
						lastItemOrder = menuMoreItem.Order_gne__c;
					}
				}
			}
			if (buttonFound == true){
				continue;
			}
			lastItemOrder++;
			result.add(new SFA2_Configuration_Object_Detail_gne__c(
				Configuration_Object_ref_gne__c = menuItem.Id,
				Is_Active_gne__c = true,
				Name = 'External Links',
				Type_gne__c = 'Menu Item',					
				Order_gne__c = lastItemOrder,
				Label_gne__c = otrSupportDashboardButtonName,
				Attributes_gne__c = '/apex/OTR_Crash_Email_Stats'					
			));		
		}
		return result;
    }
    
    private List<SFA2_Configuration_Object_Detail_gne__c> getConfigurationsForOTRSupportGroupToDisable(Set<String> appExtIdsAuthorized, String otrSupportDashboardButtonName){
    	List<SFA2_Configuration_Object_Detail_gne__c> result = new List<SFA2_Configuration_Object_Detail_gne__c>();
    	for (SFA2_Configuration_Object_Detail_gne__c menuItem : [SELECT Id, Configuration_Object_ref_gne__r.Application_Type__c, Configuration_Object_ref_gne__r.Brand_gne__c, Configuration_Object_ref_gne__r.Role_gne__c
    		FROM SFA2_Configuration_Object_Detail_gne__c WHERE Type_gne__c = 'Menu Item' AND Name = 'External Links' AND Label_gne__c = :otrSupportDashboardButtonName]){
    		String appExtId = getConfigurationExternalIdUC(menuItem.Configuration_Object_ref_gne__r.Application_Type__c, menuItem.Configuration_Object_ref_gne__r.Brand_gne__c, menuItem.Configuration_Object_ref_gne__r.Role_gne__c);
			if (appExtIdsAuthorized.size() == 0 || !appExtIdsAuthorized.contains(appExtId)){
				result.add(menuItem);
			}
    	}
    	return result;
    }
    
    private String getConfigurationExternalIdUC(String applicationName, String brandName, String roleName){
    	String app = String.isNotBlank(applicationName) ? applicationName.toUpperCase() : null;
    	String brand = String.isNotBlank(brandName) ? brandName.toUpperCase() : null;
    	String role = String.isNotBlank(roleName) ? roleName.toUpperCase() : null;
    	return String.format('{0}_{1}_{2}',
    		new String[]{app, brand, role}
    	);
    }
    
    public void finish(Database.BatchableContext BC) {
        GNE_Batch_Runner.doFinish(this,BC);
    }
    
    public void intFinish(Database.BatchableContext BC) {
        System.debug('User Sales Roster assignment batch finished.');
    }
    
    private class MissingSalesRosterException extends Exception {}

    public virtual class ManageGroupMembersQueueable implements Queueable {
        public GNE_Batch_Runner.Batchable batch {get; private set;}
        public Set<Id> userIdToInsert {get; private set;}
        public Set<Id> userIdTodelete {get; private set;}
        public String groupId {get; private set;}
        public Set<Id> allUserIdsWithEdmPs {get; private set;}
        public virtual void execute (QueueableContext context) {}
        private virtual void createGroupMembersToInsert() {}
        private virtual void createGroupMembersToDelete() {}
        private virtual void insertGroupMembers() {}
        private virtual void deleteGroupMembers() {}
    }

    public class InsertGroupMemberRecordsQueueable extends ManageGroupMembersQueueable {
        public List<GroupMember> edmUserGroupMembersToInsert {get; private set;}
        public InsertGroupMemberRecordsQueueable(GNE_Batch_Runner.Batchable batch, Set<Id> userIdToInsert, String groupId) {
            this.batch = batch;
            this.userIdToInsert = userIdToInsert;
            this.groupId = groupId;
        }

        public override void execute(QueueableContext context) {
            this.createGroupMembersToInsert();
            if(!this.edmUserGroupMembersToInsert.isEmpty()) {
                this.insertGroupMembers();
            }
        }

        private override void createGroupMembersToInsert() {
            this.edmUserGroupMembersToInsert = new List<GroupMember>();
            for(Id userId : this.userIdToInsert) {
                GroupMember gm = new GroupMember(
                        UserOrGroupId = userId,
                        GroupId = groupId
                );
                this.edmUserGroupMembersToInsert.add(gm);
            }
        }

        private override void insertGroupMembers() {
            GNE_Batch_Runner.executeDML(this.batch, this.edmUserGroupMembersToInsert, GNE_Batch_Runner.DMLType.INSERT_DML, null, 'Insert GroupMembers based on Permission Sets');
        }
    }

    public class ManageEDMUsersGroupMembersQueueable extends ManageGroupMembersQueueable {
        public Set<Id> edmGroupMembersIdsSet {get; private set;}
        public Set<Id> edmGroupMembersIdsToInsertSet {get; private set;}
        public List<GroupMember> edmUserGroupMembersToInsert {get; private set;}
        public Set<Id> edmGroupMembersIdsToDeleteSet {get; private set;}
        public List<GroupMember> edmUsersGroupMembersToDelete {get; private set;}
        public ManageEDMUsersGroupMembersQueueable(GNE_Batch_Runner.Batchable batch, Set<Id> allUserIdsWithEdmPs) {
            this.batch = batch;
            this.allUserIdsWithEdmPs = allUserIdsWithEdmPs;
        }
        public override void execute(QueueableContext context) {
            this.getEdmUsersGroupId();
            this.getEdmUsersGroup();
            this.getEdmUserGroupMembersIdsToInsert();
            if(!this.edmGroupMembersIdsToInsertSet.isEmpty()) {
                this.createGroupMembersToInsert();
                this.insertGroupMembers();
            } else {
                this.getEdmUserGroupMembersIdsToDelete();
                this.createGroupMembersToDelete();
                this.deleteGroupMembers();
            }

        }
        private void getEdmUsersGroupId() {
            groupId = [SELECT Id FROM Group WHERE Name = 'EDM_Users_Group'].Id;
        }
        private void getEdmUsersGroup() {
            this.edmGroupMembersIdsSet = new Set<Id>();
            for(GroupMember gm : [SELECT GroupId, UserOrGroupId FROM GroupMember WHERE Group.Name = 'EDM_Users_Group']) {
                this.edmGroupMembersIdsSet.add(gm.UserOrGroupId);
            }
        }
        private void getEdmUserGroupMembersIdsToInsert() {
            this.edmGroupMembersIdsToInsertSet = new Set<Id>();
            if(!this.edmGroupMembersIdsSet.containsAll(this.allUserIdsWithEdmPs)) {
                this.allUserIdsWithEdmPs.removeAll(this.edmGroupMembersIdsSet);
                this.edmGroupMembersIdsToInsertSet = this.allUserIdsWithEdmPs;    
            }
        }
        private override void createGroupMembersToInsert() {
            this.edmUserGroupMembersToInsert = new List<GroupMember>();
            if(!this.edmGroupMembersIdsToInsertSet.isEmpty()) {
                for(Id userId : this.edmGroupMembersIdsToInsertSet) {
                    GroupMember gm = new GroupMember(
                            GroupId = groupId,
                            UserOrGroupId = userId
                    );
                    this.edmUserGroupMembersToInsert.add(gm);
                    if(this.edmUserGroupMembersToInsert.size()>49) {
                        break;
                    }
                }
            }
        }
        private override void insertGroupMembers() {
            GNE_Batch_Runner.executeDML(this.batch, this.edmUserGroupMembersToInsert, GNE_Batch_Runner.DMLType.INSERT_DML, null, 'Insert GroupMembers based on Permission Sets');
        }
        private void getEdmUserGroupMembersIdsToDelete() {
            this.edmGroupMembersIdsToDeleteSet = new Set<Id>();
            this.edmGroupMembersIdsSet.removeAll(this.allUserIdsWithEdmPs);
            this.edmGroupMembersIdsToDeleteSet = this.edmGroupMembersIdsSet;
        }
        private override void createGroupMembersToDelete() {
            this.edmUsersGroupMembersToDelete = [Select Id from GroupMember where UserOrGroupID in :this.edmGroupMembersIdsToDeleteSet and Group.Id = :groupId];
        }
        private override void deleteGroupMembers() {
            GNE_Batch_Runner.executeDML(this.batch, this.edmUsersGroupMembersToDelete, GNE_Batch_Runner.DMLType.DELETE_DML, null, 'Delete GroupMembers based on Permission Sets');
        }
    }

    public class DeleteGroupMemberRecordsQueueable extends ManageGroupMembersQueueable {
        public List<GroupMember> edmUsersGroupMembersToDelete {get; private set;}
        public DeleteGroupMemberRecordsQueueable(GNE_Batch_Runner.Batchable batch, Set<Id> userIdTodelete, String groupId) {
            this.batch = batch;
            this.userIdTodelete = userIdTodelete;
            this.groupId = groupId;
        }

        public override void execute(QueueableContext context) {
            this.createGroupMembersToDelete();
            if(!edmUsersGroupMembersToDelete.isEmpty()) {
                deleteGroupMembers();
            }
        }

        private override void createGroupMembersToDelete() {
            this.edmUsersGroupMembersToDelete = [Select Id from GroupMember where UserOrGroupID in :this.userIdTodelete and Group.Id = :this.groupId];
        }

        private override void deleteGroupMembers() {
            GNE_Batch_Runner.executeDML(this.batch, this.edmUsersGroupMembersToDelete, GNE_Batch_Runner.DMLType.DELETE_DML, null, 'Delete GroupMembers based on Permission Sets');
        }
    }

    public class ManageGroupMembersHelper {
        public Set<String> edmUsersPermissionNamesSet = new Set<String> {
                'EDM_AB_Approver',
                'EDM_AB_Approver_no_license',
                'EDM_AB_Reviewer',
                'EDM_AB_Reviewer_no_license',
                'EDM_ABM_AB_Lead_no_license',
                'EDM_ABS_Manager',
                'EDM_Classification_Review',
                'EDM_VDST_Partner_External_ABM'
        };
        public String edmUsersGroupName = 'EDM_Users_Group';
        public Set<Id> edmUserGroupMemberIdSet {get; private set;}
        public String edmUserGroupId {get; private set;}

        public ManageGroupMembersHelper() {
            this.getGroupMembers();
        }

        private void getGroupMembers() {
            this.edmUserGroupMemberIdSet = new Set<Id>();
            for(GroupMember gm : [SELECT GroupId, UserOrGroupId From GroupMember Where Group.Name = :edmUsersGroupName]) {
                this.edmUserGroupMemberIdSet.add(gm.UserOrGroupId);
                if(String.isBlank(this.edmUserGroupId)) {
                    this.edmUserGroupId = gm.GroupId;
                }
            }
        }
    }

    public class UpdateUserSalesRostersBasedPerrSetForMPS implements Queueable {

        public GNE_Batch_Runner.Batchable batch {get; private set;}

        public UpdateUserSalesRostersBasedPerrSetForMPS(GNE_Batch_Runner.Batchable batch) {
            this.batch = batch;
        }

        private void executeDML(List<SObject> sObjs, GNE_Batch_Runner.DMLType dType, String actionDescription) {
            GNE_Batch_Runner.executeDML(this.batch, SObjs, dType, null, actionDescription);
        }

        private Boolean setSalesRosterId(SFA2_User_Sales_Roster_gne__c userSalesRoster, String appBrandKey, Map<String, IC_Calc_Sales_Roster_gne__c> appRoleToSalesRoster) {
            Boolean salesRosterExists = false;

            if(!(salesRosterExists = appRoleToSalesRoster.containsKey(appBrandKey))) {
                GNE_Batch_Runner.handleException(this.batch,
                        new MissingSalesRosterException('Sales Roster is missing for Application(Brand) key: ' + appBrandKey),
                        userSalesRoster);
            } else {
                userSalesRoster.Sales_Roster_gne__c = appRoleToSalesRoster.get(appBrandKey).Id;
            }

            return salesRosterExists;
        }

        public void execute(QueueableContext context) {
            Map<String, IC_Calc_Sales_Roster_gne__c> appRoleToSalesRoster = new Map<String, IC_Calc_Sales_Roster_gne__c>();
            for(IC_Calc_Sales_Roster_gne__c salesRoster : [ SELECT Id, Type_gne__c, Brand_Name_gne__c, User_Role_gne__c FROM IC_Calc_Sales_Roster_gne__c ]) {
                String key = salesRoster.Type_gne__c + (String.isNotBlank(salesRoster.Brand_Name_gne__c) ? salesRoster.Brand_Name_gne__c : '');
                if (String.isNotBlank(salesRoster.User_Role_gne__c)){
                    key += '-' + salesRoster.User_Role_gne__c;
                }
                appRoleToSalesRoster.put(key, salesRoster);
            }

            List<SFA2_User_Sales_Roster_gne__c> userSalesRostersToInsert = new List<SFA2_User_Sales_Roster_gne__c>();
            List<GNE_SFA2_User_App_Context_gne__c> appContextToInsert = new List<GNE_SFA2_User_App_Context_gne__c>();

            Map<String,SFA2_User_Group_Mapping_gne__c> permissionSetNameToAppMap = new Map<String,SFA2_User_Group_Mapping_gne__c>();

            Map<String,Id> allPermissiontSetAssignmentMap = new Map<String,Id>();
            Set<String> userSalesRosterSet = new Set<String>();
            Set<Id> alreadyAddedContexts = new Set<Id>();   // store the set of already added GNE_SFA2_User_App_Context_gne__c records to avoid duplicate entries

            Id systemAdminProfileId = [select Id from Profile where Name = 'System Administrator'].Id;

            List<SFA2_User_Group_Mapping_gne__c> groupMappingList = [
                    SELECT Id, Profile_Name_gne__c, Application_gne__c, Brand_gne__c, Role_gne__c, Permission_Set_Name_gne__c
                    FROM SFA2_User_Group_Mapping_gne__c WHERE Application_gne__c = 'MPS'
            ];

            Set<String> perrSetNames = new Set<String>();
            for(SFA2_User_Group_Mapping_gne__c ugm : groupMappingList) {
                perrSetNames.add(ugm.Permission_Set_Name_gne__c);
            }

            List<PermissionSetAssignment> permissionSetAssignmentList = [
                    SELECT AssigneeId, Assignee.Profile.Name, PermissionSet.Name
                    FROM PermissionSetAssignment
                    WHERE PermissionSet.isOwnedByProfile = false
                    AND PermissionSet.Name IN : perrSetNames
                    AND Assignee.Profile.Id != :systemAdminProfileId];

            List<SFA2_User_Sales_Roster_gne__c> userSalesRosterList = [
                    SELECT Id, User_gne__c, Sales_Roster_gne__r.Type_gne__c, Profile_Name_gne__c
                    FROM SFA2_User_Sales_Roster_gne__c
                    WHERE User_gne__r.ProfileId != :systemAdminProfileId
                    AND Sales_Roster_gne__r.Type_gne__c = 'MPS'
            ];

            for(SFA2_User_Group_Mapping_gne__c userGroupMapping : groupMappingList) {
                if(String.isNotBlank(userGroupMapping.Permission_Set_Name_gne__c)) {
                    permissionSetNameToAppMap.put(userGroupMapping.Permission_Set_Name_gne__c, userGroupMapping);
                }
            }

            for(SFA2_User_Sales_Roster_gne__c userSalesRoster : userSalesRosterList) {
                userSalesRosterSet.add(userSalesRoster.Sales_Roster_gne__r.Type_gne__c + userSalesRoster.User_gne__c);
            }

            for(PermissionSetAssignment permissionSetAssignment : permissionSetAssignmentList) {
                String permissiontSetAssignmentMapKey = '';

                permissiontSetAssignmentMapKey = permissionSetNameToAppMap.get(permissionSetAssignment.PermissionSet.Name).Application_gne__c + permissionSetAssignment.AssigneeId;
                allPermissiontSetAssignmentMap.put(permissiontSetAssignmentMapKey, permissionSetAssignment.AssigneeId);

                if(!userSalesRosterSet.contains(permissiontSetAssignmentMapKey) && appRoleToSalesRoster.containsKey(permissionSetNameToAppMap.get(permissionSetAssignment.PermissionSet.Name).Application_gne__c)) {
                    SFA2_User_Sales_Roster_gne__c newUserSalesRoster = new SFA2_User_Sales_Roster_gne__c();
                    newUserSalesRoster.User_gne__c = permissionSetAssignment.AssigneeId;
                    newUserSalesRoster.Role_gne__c = permissionSetNameToAppMap.get(permissionSetAssignment.PermissionSet.Name).Role_gne__c;
                    newUserSalesRoster.Is_Active_gne__c = true;
                    newUserSalesRoster.Profile_Name_gne__c = permissionSetAssignment.Assignee.Profile.Name;
                    String appName = permissionSetNameToAppMap.get(permissionSetAssignment.PermissionSet.Name).Application_gne__c;

                    if(!setSalesRosterId(newUserSalesRoster, appName, appRoleToSalesRoster)) {
                    // IC Sales Roster doesn't exist. Report an error an continue to next record
                        continue;
                    }

                    userSalesRostersToInsert.add(newUserSalesRoster);
                    userSalesRosterSet.add(appName + newUserSalesRoster.User_gne__c);

                    GNE_SFA2_User_App_Context_gne__c userAppContext = GNE_SFA2_User_App_Context_gne__c.getInstance(permissionSetAssignment.AssigneeId);
                    userAppContext.App_Name_gne__c = permissionSetNameToAppMap.get(permissionSetAssignment.PermissionSet.Name).Application_gne__c;
                    userAppContext.Brand_gne__c = permissionSetNameToAppMap.get(permissionSetAssignment.PermissionSet.Name).Brand_gne__c;
                    userAppContext.Role_gne__c = permissionSetNameToAppMap.get(permissionSetAssignment.PermissionSet.Name).Role_gne__c;
                    userAppContext.SFA2_Mode_gne__c = true;

                    if (!alreadyAddedContexts.contains(permissionSetAssignment.AssigneeId) && userAppContext.Id == null) {
                        appContextToInsert.add(userAppContext);
                        alreadyAddedContexts.add(permissionSetAssignment.AssigneeId);
                    }
                }
            }

            System.debug('##### User Sales Roster To Add === ' + userSalesRostersToInsert);
            System.debug('##### Application Context To Insert === ' + appContextToInsert);

            if(!userSalesRostersToInsert.isEmpty()) {
                executeDML(userSalesRostersToInsert, GNE_Batch_Runner.DMLType.INSERT_DML, 'Insert Non-SFA User Sales Roster based on Permission Sets');
            }

            if(!appContextToInsert.isEmpty()) {
                executeDML(appContextToInsert, GNE_Batch_Runner.DMLType.INSERT_DML, 'Insert Non-SFA User App Context based on Permission Sets');
            }
        }

    }
}