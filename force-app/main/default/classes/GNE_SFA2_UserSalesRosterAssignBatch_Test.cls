/************************************************************
*  @author: Lukasz Bieniawski, Roche
*  Date: 2013-12-20
*  Description: Test Class for GNE_SFA2_User_Sales_Roster_Assign_Batch
*  
*  Modification History
*  Date            Name               Description
*************************************************************/
@isTest
public class GNE_SFA2_UserSalesRosterAssignBatch_Test {
	
	static testMethod void testCreateSFABrandUserConfiguration(){		
		List<UserConfiguration> userConfigurations = new List<UserConfiguration>{
			new UserConfiguration('SFA-US', 'GNE-Field', 'Nutropin', 'CS')
		};		
		Map<Id, UserConfiguration> mapOfUsers = prepareEnvironment(userConfigurations);	
		List<SObject> scopeOfUsers = getUserScope(mapOfUsers);
		runBatch(scopeOfUsers);
		checkResult(mapOfUsers, userConfigurations.size());			
	}
	
	static testMethod void testCreateSFAMultiBrandUserConfiguration(){
		List<UserConfiguration> userConfigurations = new List<UserConfiguration>{
			new UserConfiguration('SFA-US', 'GNE-Field', 'Avastin_Tarceva', 'OCC')			
		};		
		Map<Id, UserConfiguration> mapOfUsers = prepareEnvironment(userConfigurations);	
		List<SObject> scopeOfUsers = getUserScope(mapOfUsers);
		runBatch(scopeOfUsers);
		checkResult(mapOfUsers, userConfigurations.size());
	}	
	
	static testMethod void testCreateSFACanadaUserConfiguration(){
		List<UserConfiguration> userConfigurations = new List<UserConfiguration>{
			new UserConfiguration('SFA-Canada', 'RCanada-SFA-Manager', null, 'Manager')
		};		
		Map<Id, UserConfiguration> mapOfUsers = prepareEnvironment(userConfigurations);	
		List<SObject> scopeOfUsers = getUserScope(mapOfUsers);
		runBatch(scopeOfUsers);
		checkResult(mapOfUsers, userConfigurations.size());
	}
	
	static testMethod void testCreateMCCOUserConfiguration(){
		List<UserConfiguration> userConfigurations = new List<UserConfiguration>{
			new UserConfiguration('MCCO', 'GNE-Field', null, 'FRM-OPS')			
		};		
		Map<Id, UserConfiguration> mapOfUsers = prepareEnvironment(userConfigurations);	
		List<SObject> scopeOfUsers = getUserScope(mapOfUsers);
		runBatch(scopeOfUsers);
		checkResult(mapOfUsers, userConfigurations.size());
	}
	
	static testMethod void testCreateTLCRMUserConfiguration(){
		List<UserConfiguration> userConfigurations = new List<UserConfiguration>{
			new UserConfiguration('TLCRM', 'GNE-TLS', null, null),
			new UserConfiguration('TLCRM', 'GNE-TLS-Manager', null, 'Manager')	
		};		
		Map<Id, UserConfiguration> mapOfUsers = prepareEnvironment(userConfigurations);	
		List<SObject> scopeOfUsers = getUserScope(mapOfUsers);
		runBatch(scopeOfUsers);
		checkResult(mapOfUsers, userConfigurations.size());
	}
	
	static testMethod void testCreateGFRSUserConfiguration(){
		List<UserConfiguration> userConfigurations = new List<UserConfiguration>{
			new UserConfiguration('gFRS', 'GNE-TLS', null, null),
			new UserConfiguration('gFRS', 'GNE-TLS-Manager', null, 'Manager')
		};		
		Map<Id, UserConfiguration> mapOfUsers = prepareEnvironment(userConfigurations);	
		List<SObject> scopeOfUsers = getUserScope(mapOfUsers);
		runBatch(scopeOfUsers);
		checkResult(mapOfUsers, userConfigurations.size());
	}
	
	static testMethod void testCreateMedAffairsUserConfiguration(){
		List<UserConfiguration> userConfigurations = new List<UserConfiguration>{
			new UserConfiguration('MedAffairs', 'GNE-MedAffairs-MSL-Manager', null, 'MSL-Manager')
		};		
		Map<Id, UserConfiguration> mapOfUsers = prepareEnvironment(userConfigurations);	
		List<SObject> scopeOfUsers = getUserScope(mapOfUsers);
		runBatch(scopeOfUsers);
		checkResult(mapOfUsers, userConfigurations.size());
	}

	static testMethod void testManageGroupMembersHelper() {
		Test.startTest();
			GNE_SFA2_User_Sales_Roster_Assign_Batch.ManageGroupMembersHelper mgmh =
				new GNE_SFA2_User_Sales_Roster_Assign_Batch.ManageGroupMembersHelper();
		Test.stopTest();
	}

	static testMethod void testInsertGroupMembers() {
		Test.startTest();

			Group grp = createGroup('EDM_Users_Group_TST', 'Regular');

			GNE_SFA2_User_Sales_Roster_Assign_Batch userSalesRosterAssignmentBatch = new GNE_SFA2_User_Sales_Roster_Assign_Batch();

			GNE_SFA2_User_Sales_Roster_Assign_Batch.InsertGroupMemberRecordsQueueable igmrq =
				new GNE_SFA2_User_Sales_Roster_Assign_Batch.InsertGroupMemberRecordsQueueable(userSalesRosterAssignmentBatch, new Set<Id> {UserInfo.getUserId()}, grp.Id);
			System.enqueueJob(igmrq);

		Test.stopTest();
	}

	static testMethod void testDeleteGroupMembers() {
		Test.startTest();

			Group grp = createGroup('EDM_Users_Group_TST', 'Regular');
			List<GroupMember> groupMembers = createGroupMember(new Set<Id> {UserInfo.getUserId()}, grp.Id);

			GNE_SFA2_User_Sales_Roster_Assign_Batch userSalesRosterAssignmentBatch = new GNE_SFA2_User_Sales_Roster_Assign_Batch();

			GNE_SFA2_User_Sales_Roster_Assign_Batch.DeleteGroupMemberRecordsQueueable dgmrq =
				new GNE_SFA2_User_Sales_Roster_Assign_Batch.DeleteGroupMemberRecordsQueueable(userSalesRosterAssignmentBatch, new Set<Id> { UserInfo.getUserId() }, grp.Id);
			System.enqueueJob(dgmrq);

		Test.stopTest();
	}
	
	/*
	static testMethod void testCreateGFRSUserConfigurationWithPermissionSetAssigned(){
		List<UserConfiguration> userConfigurations = new List<UserConfiguration>{
			new UserConfiguration('gFRS', 'GNE-TLS', null, null),
			new UserConfiguration('gFRS', 'GNE-TLS-Manager', null, 'Manager')
		};		
		Map<Id, UserConfiguration> mapOfUsers = prepareEnvironment(userConfigurations);
		List<SObject> scopeOfUsers = getUserScope(mapOfUsers);
		assignPermissionSets(scopeOfUsers);
		runBatch(scopeOfUsers);
		checkResult(mapOfUsers, userConfigurations.size());
	}
	
	private static void assignPermissionSets(List<SObject> scopeOfUsers){
		if (scopeOfUsers.isEmpty()){
			return;
		}
		PermissionSet permissionSet = [SELECT ID From PermissionSet WHERE Name = 'GNE_Standard_User_Delegation' LIMIT 1];
		List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>();
		for(SObject oUser : scopeOfUsers){
			User testUser = (User)oUser;			
			if(testUser.PermissionSetAssignments.size() == 0) {
				permissionSetAssignments.add(
					new PermissionSetAssignment(
						AssigneeId = testUser.Id,
						PermissionSetId = permissionSet.ID
					)
				);
				System.debug('Permission set added for user: ' + testUser);
			}
		}
		if (!permissionSetAssignments.isEmpty()){		
			insert permissionSetAssignments;
			System.debug('Permission set assigned: ' + permissionSetAssignments);
		}
	}
	*/
	
	private static void checkResult(Map<Id, UserConfiguration> mapOfUsers, Integer inputConfigurationSize){
		Integer totalFullConfigurationCreated = 0;
		if (mapOfUsers.size() > 0){
			for (Id userId : mapOfUsers.keyset()){
				UserConfiguration uc = mapOfUsers.get(userId);
				Boolean isMultibrand = String.isNotEmpty(uc.brandName) && uc.brandName.contains('_');			
				List <SFA2_User_Sales_Roster_gne__c> salesRostersCreated = [Select Id From SFA2_User_Sales_Roster_gne__c 
					Where User_gne__c = :userId AND Sales_Roster_gne__r.Type_gne__c = :uc.applicationName 
					AND Role_gne__c = :uc.roleName AND Profile_Name_gne__c = :uc.profileName AND Is_Active_gne__c = true];
				List<GNE_SFA2_User_App_Context_gne__c> appContextCreated = [SELECT Id FROM GNE_SFA2_User_App_Context_gne__c 
					WHERE SetupOwnerId = :userId AND Role_gne__c = :uc.roleName AND Brand_gne__c = :uc.brandName
					AND App_Name_gne__c = :uc.applicationName AND SFA2_Mode_gne__c = true];
				System.assertEquals(isMultibrand ? uc.brandName.Split('_').size() : 1, salesRostersCreated.size());
				System.assertEquals(1, appContextCreated.size());
				totalFullConfigurationCreated++;			
			}
		}	
		System.assertEquals(inputConfigurationSize, totalFullConfigurationCreated);
	}
			
	private static List<SObject> getUserScope(Map<Id, UserConfiguration> mapOfUsers){
		List<SObject> userScope = new List<SObject>();
		if (mapOfUsers.size() > 0){
			for (UserConfiguration uc : mapOfUsers.values()){
				userScope.add(uc.User);
			}
		}
		return userScope;
	}
	
	private static void runBatch(List<SObject> scope){
		GNE_SFA2_User_Sales_Roster_Assign_Batch batch = new GNE_SFA2_User_Sales_Roster_Assign_Batch();		
		Test.startTest();
		batch.execute(null, scope);
		Test.stopTest();
	}	
	
	private static Map<Id, UserConfiguration> prepareEnvironment(List<UserConfiguration> userConfigurations) {
		Map<Id, UserConfiguration> mapOfUsers = prepareUsers(userConfigurations);
		prepareICCalcSalesRosterConfiguration(mapOfUsers);
		prepareUserGroupMappingConfiguration(mapOfUsers);		
		return mapOfUsers;
	}
	
	private static Map<Id, UserConfiguration> prepareUsers(List<UserConfiguration> userConfigurations){
		Map<Id, UserConfiguration> mapOfUsers = new Map<Id, UserConfiguration>();		
		for (UserConfiguration userConfiguration : userConfigurations){
			System.debug('Reading configuration for profile: ' + userConfiguration.profileName);						
			List<User> userList = [Select Id, ProfileId, isActive From User Where Profile.Name = :userConfiguration.profileName LIMIT 1];
			User testUser = null;
			if (userList.isEmpty()){				
				testUser = createTestUser(userConfiguration.profileName);
			} else {
				testUser = userList[0];
			}
			if (testUser != null){
				userConfiguration.user = testUser;
				mapOfUsers.put(testUser.Id, userConfiguration);
				System.debug('Configuration added for profile: ' + userConfiguration.profileName);
			} 
		}				
		return mapOfUsers;
	}
	
	private static User createTestUser(String profileName){	
		User testUser = null;	
		for(Profile p : [ SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1]) {
			testUser = new User(
				Alias = 'testUser', 
				Email='testuser@test.gene.com', 
         		EmailEncodingKey='UTF-8',
         		FirstName = 'FirstName', 
         		LastName='LastName', 
         		LanguageLocaleKey='en_US', 
         		LocaleSidKey='en_US',
         		ProfileId = p.Id, 
         		TimeZoneSidKey='America/Los_Angeles', 
         		UserName=profileName + 'testuser@gene.com'         		
         	);
         	insert testUser;
         	System.debug('Test user added for profile: ' + profileName);
         	System.debug('Test user added: ' + testUser);
		}
		return testUser;
	}
	
	private static void prepareICCalcSalesRosterConfiguration(Map<Id, UserConfiguration> mapOfUsers){
		if (mapOfUsers.size() == 0) {
			return;
		}		 
		Map<String, IC_Calc_Sales_Roster_gne__c> icCalcMap = new Map<String, IC_Calc_Sales_Roster_gne__c>();
		for (UserConfiguration userConfiguration : mapOfUsers.values()){
			List<String> brandList = new List<String>();			
			if (String.isNotEmpty(userConfiguration.brandName)) {
				if (userConfiguration.brandName.contains('_')){					
				 	List<String> multibrands = userConfiguration.brandName.split('_');
			 		for (String multibrand : multibrands){
			 			brandList.add(multibrand);
			 		}
				 } else {
				 	brandList.add(userConfiguration.brandName);
				 }	
			}
						 
			if (brandList.isEmpty()){
				String icKey = userConfiguration.applicationName;
				if (String.isNotBlank(userConfiguration.brandName)){
					icKey += userConfiguration.brandName;
				}
				if (!icCalcMap.containsKey(icKey)){
					IC_Calc_Sales_Roster_gne__c icCalc = createICCalcSalesRosterConfiguration(userConfiguration.applicationName, userConfiguration.brandName);
					icCalcMap.put(icKey, icCalc);
				}
			} else {
				for (String brand : brandList){
					String icKey = userConfiguration.applicationName + brand;
					if (!icCalcMap.containsKey(icKey)){
						IC_Calc_Sales_Roster_gne__c icCalc = createICCalcSalesRosterConfiguration(userConfiguration.applicationName, brand);
						icCalcMap.put(icKey, icCalc);
					}					
				}
			}
		}
		if (icCalcMap.size() > 0){
			insert icCalcMap.values();
			System.debug('Test IC Calc Sales Rosters added: ' + icCalcMap.size());
			System.debug('Test IC Calc Sales Rosters added: ' + icCalcMap.values());
		}
	}
	
	private static IC_Calc_Sales_Roster_gne__c createICCalcSalesRosterConfiguration(String applicationName, String brandName){
		IC_Calc_Sales_Roster_gne__c icCalc = new IC_Calc_Sales_Roster_gne__c(
			Type_gne__c = applicationName,
			Brand_Name_gne__c = brandName										
		);
		return icCalc;
	}
	
	private static void prepareUserGroupMappingConfiguration(Map<Id, UserConfiguration> mapOfUsers){
		if (mapOfUsers.size() == 0){
			return;
		}
		Map<String, SFA2_User_Group_Mapping_gne__c> userGroupMappings = new Map<String, SFA2_User_Group_Mapping_gne__c>();
		for (UserConfiguration userConfiguration : mapOfUsers.values()){
			String mapKey = userConfiguration.applicationName + userConfiguration.profileName;
			if (!userGroupMappings.containsKey(mapKey)){
				SFA2_User_Group_Mapping_gne__c userMapping = new SFA2_User_Group_Mapping_gne__c(
					Application_gne__c = userConfiguration.applicationName,
					Brand_gne__c = userConfiguration.brandName,
					Profile_Name_gne__c = userConfiguration.profileName,
					Role_gne__c = userConfiguration.roleName
				);
				userGroupMappings.put(mapKey, userMapping);
			}			
		} 
		if (userGroupMappings.size() > 0){
			insert userGroupMappings.values();
			System.debug('Test User group mappings added: ' + userGroupMappings.size());
			System.debug('Test User group mappings added: ' + userGroupMappings.values());
		}
	}

	private static Group createGroup(String name, String type) {
		Group grp = new Group();
		grp.name = name;
		grp.Type = type;
		Insert grp;
		return grp;
	}

	private static List<GroupMember> createGroupMember(Set<Id> usersAddToGroup, Id groupId) {
		List<GroupMember> groupMembers = new List<GroupMember>();
		for(Id userId : usersAddToGroup) {
			GroupMember grpMem1 = new GroupMember();
			grpMem1.UserOrGroupId = userId;
			grpMem1.GroupId = groupId;
			groupMembers.add(grpMem1);
		}
		Insert groupMembers;
		return groupMembers;
	}
	
	private class UserConfiguration{	
		public String applicationName { get; private set; }	
		public String profileName { get; private set; }
		public String brandName { get; private set; }
		public String roleName { get; private set; }
		public User user { get; set; }
		
		public UserConfiguration(String applicationName, String profileName, String brandName, String roleName){
			this.applicationName = applicationName;
			this.profileName = profileName;
			this.brandName = brandName;
			this.roleName = roleName;
		}
	}
}