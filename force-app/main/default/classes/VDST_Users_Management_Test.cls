/** @date 2/11/2014
* @Author Konrad Malinowski
* @description Test Class for Users Management Controller
*/
@isTest
private class VDST_Users_Management_Test {

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for logging as genentech, provisioner user
	*/
	@isTest static void shouldUserBeLoggedInAsGeneProvisioner() {
		// GIVEN
		VDST_EventProvider_gne__c evProvider = VDST_TestUtils.createEventProviders()[0];
		VDST_TestUtils.createVdstUser(evProvider);

		// WHEN
		VDST_Users_Management usrMgmtCtrl = new VDST_Users_Management();

		// THEN
		System.assert( usrMgmtCtrl.isGene );
		System.assert( usrMgmtCtrl.canAccessPage );
	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for logging as cadent, provisioner user
	*/
	@isTest static void shouldUserBeLoggedInAsCdntProvisioner() {
		// GIVEN
		VDST_EventProvider_gne__c evProvider = VDST_TestUtils.createEventProviders()[1];
		VDST_TestUtils.createVdstUser(evProvider);

		// WHEN
		VDST_Users_Management usrMgmtCtrl = new VDST_Users_Management();

		// THEN
		System.assert( !usrMgmtCtrl.isGene );
		System.assert( usrMgmtCtrl.canAccessPage );
	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for user with no privileges to User Management page
	*/
	@isTest static void shouldUserDoNotHaveAccessToPage() {
		// GIVEN
		VDST_EventProvider_gne__c evProvider = VDST_TestUtils.createEventProviders()[1];
		VDST_User_gne__c user = VDST_TestUtils.createVdstUser(evProvider);
		user.Role_gne__c = null;
		update user;

		// WHEN
		VDST_Users_Management usrMgmtCtrl = new VDST_Users_Management();

		// THEN
		System.assert( !usrMgmtCtrl.isGene );
		System.assert( !usrMgmtCtrl.canAccessPage );
	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for going to apex pages
	*/
	@isTest static void shouldGoToPages() {
		// GIVEN
		VDST_Users_Management usrMgmtCtrl = new VDST_Users_Management();

		// WHEN
		PageReference prEventsList 	= usrMgmtCtrl.goToEventList();
		PageReference prLogOut 		= usrMgmtCtrl.logOut();

		// THEN
		System.assertEquals( '/apex/VDST_EventList',	prEventsList.getUrl() );
		System.assertEquals( '/secur/logout.jsp', 		prLogOut.getUrl() );

		System.assert( prEventsList.getRedirect() && prLogOut.getRedirect() );
	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for assigning proxy user
	*/
	@isTest static void shouldAssignProxyUser() {
		// GIVEN
		List<VDST_EventProvider_gne__c> providers = VDST_TestUtils.createEventProviders();
		VDST_EventProvider_gne__c geneProvider = providers[0];
		VDST_TestUtils.createVdstUser(geneProvider);
		Id cdntProviderId = providers[1].Id;

		// WHEN
		VDST_Users_Management usrMgmtCtrl = new VDST_Users_Management();
		usrMgmtCtrl.selectedBehalfGroup = cdntProviderId;
		usrMgmtCtrl.assignUserProxy();

		// THEN
		VDST_User_gne__c currentUser = [SELECT VDST_Proxy_gne__c FROM VDST_User_gne__c WHERE User_gne__c =: UserInfo.getUserId() LIMIT 1];
		System.assertEquals( cdntProviderId, currentUser.VDST_Proxy_gne__c );
	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for unassigning proxy user
	*/
	@isTest static void shouldUnassignProxyUser() {
		// GIVEN
		List<VDST_EventProvider_gne__c> providers = VDST_TestUtils.createEventProviders();
		VDST_EventProvider_gne__c geneProvider = providers[0];
		VDST_User_gne__c user = VDST_TestUtils.createVdstUser(geneProvider);
		Id cdntProviderId = providers[1].Id;
		user.VDST_Proxy_gne__c = cdntProviderId;
		update user;
		VDST_User_gne__c currentUser = [SELECT VDST_Proxy_gne__c FROM VDST_User_gne__c WHERE User_gne__c =: UserInfo.getUserId() LIMIT 1];
		System.assertEquals( cdntProviderId, currentUser.VDST_Proxy_gne__c );

		// WHEN
		VDST_Users_Management usrMgmtCtrl = new VDST_Users_Management();
		usrMgmtCtrl.unassignUserProxy();

		// THEN
		currentUser = [SELECT VDST_Proxy_gne__c FROM VDST_User_gne__c WHERE User_gne__c =: UserInfo.getUserId() LIMIT 1];
		System.assertEquals( null, currentUser.VDST_Proxy_gne__c );
	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for  creating successfully new group
	*/
	@isTest static void shouldSuccessfullyCreateNewGroup() {
		// GIVEN
		List<VDST_EventProvider_gne__c> providers = VDST_TestUtils.createEventProviders();
		VDST_EventProvider_gne__c geneProvider = providers[0];
		VDST_TestUtils.createVdstUser(geneProvider);

		VDST_Users_Management usrMgmtCtrl = new VDST_Users_Management();
		usrMgmtCtrl.newProvider.VendorName_gne__c = 'NewProviderName';
		usrMgmtCtrl.newProvider.VendorCode_gne__c = 'NewProviderCode';

		// WHEN
		usrMgmtCtrl.saveNewGroup();

		// THEN
		System.assertNotEquals( null, usrMgmtCtrl.selectedGroup );
	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for failure of creating new group due to blank provider name
	*/
	@isTest static void shouldFaiDuringCreateNewGroupDueToBlankProviderName() {
		// GIVEN
		List<VDST_EventProvider_gne__c> providers = VDST_TestUtils.createEventProviders();
		VDST_EventProvider_gne__c geneProvider = providers[0];
		VDST_TestUtils.createVdstUser(geneProvider);

		VDST_Users_Management usrMgmtCtrl = new VDST_Users_Management();
		usrMgmtCtrl.newProvider.VendorName_gne__c = '';

		// WHEN
		usrMgmtCtrl.saveNewGroup();
		ApexPages.Message[] apexPageMessages = ApexPages.getMessages();

		// THEN
		System.assertEquals( 1, apexPageMessages.size() );
		System.assert( apexPageMessages[0].getSummary().containsIgnoreCase('Vendor Name is mandatory') );
	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for failure of creating new group due to blank provider code
	*/
	@isTest static void shouldFaiDuringCreateNewGroupDueToBlankProviderCode() {
		// GIVEN
		List<VDST_EventProvider_gne__c> providers = VDST_TestUtils.createEventProviders();
		VDST_EventProvider_gne__c geneProvider = providers[0];
		VDST_TestUtils.createVdstUser(geneProvider);

		VDST_Users_Management usrMgmtCtrl = new VDST_Users_Management();
		usrMgmtCtrl.newProvider.VendorName_gne__c = 'NewProviderName';
		usrMgmtCtrl.newProvider.VendorCode_gne__c = '';

		// WHEN
		usrMgmtCtrl.saveNewGroup();
		ApexPages.Message[] apexPageMessages = ApexPages.getMessages();

		// THEN
		System.assertEquals( 1, apexPageMessages.size() );
		System.assert( apexPageMessages[0].getSummary().containsIgnoreCase('Vendor Code is mandatory') );
	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for failure of creating new group due to not unique provider code
	*/
	@isTest static void shouldFaiDuringCreateNewGroupDueToNotUniqueProviderCode() {
		// GIVEN
		List<VDST_EventProvider_gne__c> providers = VDST_TestUtils.createEventProviders();
		VDST_EventProvider_gne__c geneProvider = providers[0];
		VDST_TestUtils.createVdstUser(geneProvider);

		VDST_Users_Management usrMgmtCtrl = new VDST_Users_Management();
		usrMgmtCtrl.newProvider.VendorName_gne__c = 'Genentech';
		usrMgmtCtrl.newProvider.VendorCode_gne__c = 'GNE';

		// WHEN
		usrMgmtCtrl.saveNewGroup();
		ApexPages.Message[] apexPageMessages = ApexPages.getMessages();

		// THEN
		System.assertEquals( 1, apexPageMessages.size() );
		System.assert( apexPageMessages[0].getSummary().containsIgnoreCase('Please enter unique Vendor Code') );
	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for assigning user to group
	*/
	@isTest static void shouldSuccessfullyAssignUserToGroup() {
		// GIVEN
		List<VDST_EventProvider_gne__c> providers = VDST_TestUtils.createEventProviders();
		VDST_EventProvider_gne__c geneProvider = providers[0];
		VDST_TestUtils.createVdstUser(geneProvider);

		User userForAssignation = VDST_TestUtils.createUser('Standard User');
		insert userForAssignation;

		VDST_EventProvider_gne__c cdntProvider = providers[1];
		VDST_Users_Management usrMgmtCtrl = new VDST_Users_Management();
		usrMgmtCtrl.selectedGroupObj = cdntProvider;
		usrMgmtCtrl.selectedGroup = cdntProvider.Id;
		usrMgmtCtrl.newUserAssignment.Role_gne__c = 'Monitor';
		usrMgmtCtrl.newUserAssignment.User_gne__c = userForAssignation.Id;

		// WHEN
		User usr = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
     	System.runAs(usr) {
			Test.startTest();
			usrMgmtCtrl.saveAssignment();
			Test.stopTest();
     	}

		// THEN
		VDST_User_gne__c assignedVdstUser = [ SELECT Role_gne__c, VDST_Event_Provider__c FROM VDST_User_gne__c WHERE User_gne__c = :userForAssignation.Id LIMIT 1 ];
		System.assertEquals( 'Monitor', assignedVdstUser.Role_gne__c );
		System.assertEquals( cdntProvider.Id, assignedVdstUser.VDST_Event_Provider__c );
	}

	/** @date 2/12/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for failure of assigning user to group due to missing user info
	*/
	@isTest static void shouldFailDuringAssigningUserToGroupDueToMissingUserInfo() {
		// GIVEN
		List<VDST_EventProvider_gne__c> providers = VDST_TestUtils.createEventProviders();
		VDST_EventProvider_gne__c geneProvider = providers[0];
		VDST_TestUtils.createVdstUser(geneProvider);

		User userForAssignation = VDST_TestUtils.createUser('Standard User');
		insert userForAssignation;

		VDST_EventProvider_gne__c cdntProvider = providers[1];
		VDST_Users_Management usrMgmtCtrl = new VDST_Users_Management();
		usrMgmtCtrl.selectedGroupObj = cdntProvider;
		usrMgmtCtrl.selectedGroup = cdntProvider.Id;
		usrMgmtCtrl.newUserAssignment.Role_gne__c = null;
		usrMgmtCtrl.newUserAssignment.User_gne__c = null;

		// WHEN
		usrMgmtCtrl.saveAssignment();
		ApexPages.Message[] apexPageMessages = ApexPages.getMessages();

		// THEN
		System.assertEquals( 1, apexPageMessages.size() );
		System.assert( apexPageMessages[0].getSummary().containsIgnoreCase('Invalid data') );
	}

	/** @date 2/12/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for failure of assigning user to group due to existing assignation
	*/
	@isTest static void shouldFailDuringAssigningUserToGroupDueToExistingAssignation() {
		// GIVEN
		List<VDST_EventProvider_gne__c> providers = VDST_TestUtils.createEventProviders();
		VDST_EventProvider_gne__c geneProvider = providers[0];
		VDST_TestUtils.createVdstUser(geneProvider);

		User userForAssignation = VDST_TestUtils.createUser('Standard User');
		insert userForAssignation;
		VDST_User_gne__c userAlreadyAssigned = VDST_TestUtils.createVdstUser(geneProvider);
		userAlreadyAssigned.User_gne__c = userForAssignation.Id;
		update userAlreadyAssigned;

		VDST_EventProvider_gne__c cdntProvider = providers[1];
		VDST_Users_Management usrMgmtCtrl = new VDST_Users_Management();
		usrMgmtCtrl.selectedGroupObj = cdntProvider;
		usrMgmtCtrl.selectedGroup = cdntProvider.Id;
		usrMgmtCtrl.newUserAssignment.Role_gne__c = 'Monitor';
		usrMgmtCtrl.newUserAssignment.User_gne__c = userForAssignation.Id;

		// WHEN
		usrMgmtCtrl.saveAssignment();
		ApexPages.Message[] apexPageMessages = ApexPages.getMessages();

		// THEN
		System.assertEquals( 1, apexPageMessages.size() );
		System.assert( apexPageMessages[0].getSummary().containsIgnoreCase('User already assigned to') );
	}

	/** @date 2/12/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for failure of assigning user to group due to missing selected group
	*/
	@isTest static void shouldFailDuringAssigningUserToGroupDueToMissingSelectedGroup() {
		// GIVEN
		List<VDST_EventProvider_gne__c> providers = VDST_TestUtils.createEventProviders();
		VDST_EventProvider_gne__c geneProvider = providers[0];
		VDST_TestUtils.createVdstUser(geneProvider);

		User userForAssignation = VDST_TestUtils.createUser('Standard User');
		insert userForAssignation;

		VDST_Users_Management usrMgmtCtrl = new VDST_Users_Management();
		usrMgmtCtrl.selectedGroupObj = null;
		usrMgmtCtrl.selectedGroup = null;
		usrMgmtCtrl.newUserAssignment.Role_gne__c = 'Monitor';
		usrMgmtCtrl.newUserAssignment.User_gne__c = userForAssignation.Id;

		// WHEN
		usrMgmtCtrl.saveAssignment();
		ApexPages.Message[] apexPageMessages = ApexPages.getMessages();

		// THEN
		System.assertEquals( 1, apexPageMessages.size() );
		System.assert( apexPageMessages[0].getSummary().containsIgnoreCase('Error during User Assignment') );
	}

	/** @date 2/12/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for cancel actions and retrieve values from getters
	*/
	@isTest static void shouldCancelActionsAndRetrieveGetters() {
		// GIVEN
		List<VDST_EventProvider_gne__c> providers = VDST_TestUtils.createEventProviders();
		VDST_EventProvider_gne__c geneProvider = providers[0];
		VDST_TestUtils.createVdstUser(geneProvider);

		VDST_Users_Management usrMgmtCtrl = new VDST_Users_Management();

		// WHEN
		usrMgmtCtrl.cancelAssignment();
		usrMgmtCtrl.cancelPortalUser();

		usrMgmtCtrl.selectedGroupObj = geneProvider;
		usrMgmtCtrl.selectedGroup = geneProvider.Id;
		List<SelectOption> roleMapping = usrMgmtCtrl.getRoleMapping();

		// THEN
		System.assertNotEquals( null, usrMgmtCtrl.newUserAssignment );
		System.assertEquals( null, usrMgmtCtrl.newUserAssignment.Id );

		System.assert( usrMgmtCtrl.getIsGroupSelected() );
		System.assertEquals( 4, roleMapping.size() );
		System.assertEquals( 'Monitoring', 		roleMapping[0].getValue() ); System.assertEquals( 'Monitor', 		 roleMapping[0].getLabel() );
		System.assertEquals( 'Vendor', 			roleMapping[1].getValue() ); System.assertEquals( 'Submitter', 		 roleMapping[1].getLabel() );
		System.assertEquals( 'Provisioner', 	roleMapping[2].getValue() ); System.assertEquals( 'Provisioner', 	 roleMapping[2].getLabel() );
		System.assertEquals( 'Proxy Submitter', roleMapping[3].getValue() ); System.assertEquals( 'Proxy Submitter', roleMapping[3].getLabel() );
	}

	/** @date 2/12/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for unassigning user from group
	*/
	@isTest static void shouldSuccessfullyUnassignUserFromGroup() {
		// GIVEN
		List<VDST_EventProvider_gne__c> providers = VDST_TestUtils.createEventProviders();
		VDST_EventProvider_gne__c geneProvider = providers[0];
		VDST_TestUtils.createVdstUser(geneProvider);

		User userForAssignation = VDST_TestUtils.createUser('Standard User');
		insert userForAssignation;
		VDST_User_gne__c userAlreadyAssigned = VDST_TestUtils.createVdstUser(geneProvider);
		userAlreadyAssigned.User_gne__c = userForAssignation.Id;
		update userAlreadyAssigned;

		VDST_Users_Management usrMgmtCtrl = new VDST_Users_Management();
		usrMgmtCtrl.userId = userAlreadyAssigned.Id;

		// WHEN
		usrMgmtCtrl.unassignUser();

		// THEN
		List<VDST_User_gne__c> notAssignedUser = [ SELECT Id FROM VDST_User_gne__c WHERE User_gne__c = :userForAssignation.Id ];
		System.assertEquals( 0, notAssignedUser.size() );
	}

	/** @date 2/12/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for failing during create portal user due to errors occurence
	*/
	@isTest static void shouldFailDuringCreatePortalUserDueToErrorsOccurence() {
		// GIVEN
		List<VDST_EventProvider_gne__c> providers = VDST_TestUtils.createEventProviders();
		VDST_EventProvider_gne__c geneProvider = providers[0];
		VDST_TestUtils.createVdstUser(geneProvider);

		VDST_Users_Management usrMgmtCtrl = new VDST_Users_Management();
		usrMgmtCtrl.newPortalUser.firstName = '';
		usrMgmtCtrl.newPortalUser.lastName = '';
		usrMgmtCtrl.newPortalUser.emailAddress = '';
		usrMgmtCtrl.newUserAssignment.Role_gne__c = '';

		// WHEN
		usrMgmtCtrl.createPortalUser();
		ApexPages.Message[] apexPageMessages = ApexPages.getMessages();

		// THEN
		System.assertEquals( 4, apexPageMessages.size() );
		System.assert( apexPageMessages[0].getSummary().containsIgnoreCase('User First Name is mandatory') );
		System.assert( apexPageMessages[1].getSummary().containsIgnoreCase('User Last Name is mandatory') );
		System.assert( apexPageMessages[2].getSummary().containsIgnoreCase('User Email Address is mandatory') );
		System.assert( apexPageMessages[3].getSummary().containsIgnoreCase('Role is mandatory') );
	}

	/** @date 2/13/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for creating SFDC user
	*/
	@isTest static void shouldSuccessfullyCreateSfdcUser() {
		// GIVEN
		List<VDST_EventProvider_gne__c> providers = VDST_TestUtils.createEventProviders();
		VDST_EventProvider_gne__c geneProvider = providers[0];
		VDST_TestUtils.createVdstUser(geneProvider);

		List<User> ownerUser = [SELECT Id FROM User WHERE Name LIKE 'AGGS Case Monitor'];
		if(ownerUser.size() == 0) {
			User userForAssignation = VDST_TestUtils.createUser('Standard User');
			insert userForAssignation;
		}
		VDST_TestUtils.createVdstSetting();

		VDST_Users_Management usrMgmtCtrl = new VDST_Users_Management();
		usrMgmtCtrl.newPortalUser.firstName 		= 'FirstName';
		usrMgmtCtrl.newPortalUser.lastName 			= 'LastName';
		usrMgmtCtrl.newPortalUser.emailAddress 		= 'email@gmail.com';
		usrMgmtCtrl.newUserAssignment.Role_gne__c 	= 'Monitor';
		usrMgmtCtrl.selectedGroupObj 				= geneProvider;
		usrMgmtCtrl.selectedGroup 					= geneProvider.Id;

		// WHEN
		User usr = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
     	System.runAs(usr) {
			Test.startTest();
			usrMgmtCtrl.createSFDCUser(true);
			Test.stopTest();
     	}
	}

	/** @date 2/13/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for creating user wrapper object
	*/
	@isTest static void shouldCreateUserWrapperObject() {
		// GIVEN
		String firstName 	= 'FirstName';
		String lastName 	= 'LastName';
		String email 		= 'email@gmail.com';
		String phone 		= '123456789';

		// WHEN
		VDST_Users_Management.UserWrapper usrWrap = new VDST_Users_Management.UserWrapper(
			firstName,
			lastName,
			email,
			phone
		);

		// THEN
		System.assertEquals( firstName, usrWrap.firstName 		);
		System.assertEquals( lastName, 	usrWrap.lastName  		);
		System.assertEquals( email, 	usrWrap.emailAddress  	);
		System.assertEquals( phone, 	usrWrap.phone  			);
	}
}