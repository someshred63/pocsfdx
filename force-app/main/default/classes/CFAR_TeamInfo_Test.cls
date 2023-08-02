@isTest(SeeAllData=false)
private class CFAR_TeamInfo_Test {

    static testMethod void UnitTest_Base() {
        User testAvgUser = null;
		System.runAs(new User(Id = Userinfo.getUserId())) {
        	testAvgUser = CFAR_TestUtils.createTestAverageUser();
        }
        CFAR_Contact_gne__c primaryContact = CFAR_TestUtils.createTestPrimaryContact();

		system.runAs(testAvgUser)
		{
			CFAR_Trial_gne__c trial = CFAR_TestUtils.createTestTrial();

			Test.startTest();

			CFAR_Team_Controller ctrl = new CFAR_Team_Controller();
			ctrl.trialWrapper.innerObject = trial;
			ctrl.addNewMember();
			ctrl.selectedContactId = primaryContact.Id;
			ctrl.contactChanged();
			system.assert(!ctrl.memberRoles.isEmpty());
			ctrl.getContactSearchList1();
			ctrl.getContactSearchList2();
			ctrl.getContactSearchList3();
			ctrl.getContactSearchList4();
			List<CFAR_Team_Member_gne__c> teamMembers = ctrl.getTeamMembers();
            System.assertEquals(0, ctrl.getTeamMembers().size());
			Test.stopTest();
		}
    }

    static testMethod void UnitTest_Edit_OK() {
        User testAvgUser = null;
		System.runAs(new User(Id = Userinfo.getUserId())) {
        	testAvgUser = CFAR_TestUtils.createTestAverageUser();
        }
        CFAR_Contact_gne__c primaryContact = CFAR_TestUtils.createTestPrimaryContact();

		system.runAs(testAvgUser)
		{
			CFAR_Trial_gne__c trial = CFAR_TestUtils.createTestTrial();
			CFAR_Contact_gne__c contact = CFAR_TestUtils.createTestAdminContact();
            
	 		CFAR_TestUtils.createDegrees();
            
            CFAR_Parent_Organization_gne__c parent = new CFAR_Parent_Organization_gne__c();
         	parent.Name = 'testparent';
         	parent.Active_gne__c = true;
         	insert parent;
            
            CFAR_Institution_gne__c institution = new CFAR_Institution_gne__c();
        	institution.Name = 'TestInstitution';
        	institution.Parent_Organization__c = [SELECT id FROM CFAR_Parent_Organization_gne__c].get(0).id;
        	institution.Active_gne__c = true;
        	insert institution;
            
             insert new CFAR_Address_Type_gne__c(Name = 'Fedex Delivery');
    		CFAR_Contact_Address_gne__c address = new CFAR_Contact_Address_gne__c();
    		address.Address_Type_ref_gne__c = [select Id from CFAR_Address_Type_gne__c where Name = 'Fedex Delivery' order by Active_gne__c desc limit 1][0].Id;
    		address.Country_gne__c = 'Argentina';
    		address.Province_gne__c = 'TestProvince';
			address.City_gne__c = 'TestCity';
			address.Address_gne__c = 'TestAddress';
			address.Postal_Code_gne__c = '12345';
        	address.institution_gne__c = [SELECT id FROM CFAR_Institution_gne__c].get(0).id;
			insert address;

			Test.startTest();

			CFAR_Team_Controller ctrl = new CFAR_Team_Controller();
			ctrl.trialWrapper.innerObject = trial;
			ctrl.addNewMember();
            ctrl.newMember.CFAR_Trial_ref_gne__c = trial.id;
           // ctrl.newMember.Contact_address_ref_gne__c.CFAR_Contact_ref_gne__c = contact.id;
            ctrl.newMember.Function_Role_gne__c = 'Other-External';
            
          //  ctrl.newMember.Contact_address_ref_gne__r.CFAR_Contact_ref_gne__c = address.Id;
          //  ctrl.newMember.Address_Type_ref_gne__c = [SELECT id FROM CFAR_Address_Type_gne__c].get(0).id;
          //  ctrl.newMember.Active_On_gne__c = Date.today();
            //insert ctrl.newMember;
			
			List<CFAR_Team_Member_gne__c> teamMembers = ctrl.getTeamMembers();
			for(CFAR_Team_Member_gne__c t : teamMembers) {
				if(t.Is_Trial_Primary_Contact_gne__c) {
					ctrl.memberId = t.Id;
					break;
				}
			}
			
           // ctrl.newMember.Contact_Address_ref_gne__r.CFAR_Contact_ref_gne__r.Primary_Role_Function_gne__c = 'Other-External';
            //ctrl.editMember();
            ctrl.changeNotificationSetting();
			Test.stopTest();
		}
    }

    static testMethod void UnitTest_Submit_NOK() {
        User testAvgUser = null;
		System.runAs(new User(Id = Userinfo.getUserId())) {
        	testAvgUser = CFAR_TestUtils.createTestAverageUser();
        }
        CFAR_Contact_gne__c primaryContact = CFAR_TestUtils.createTestPrimaryContact();

		system.runAs(testAvgUser)
		{
			CFAR_Trial_gne__c trial = CFAR_TestUtils.createTestTrial();

			Test.startTest();

			CFAR_Team_Controller ctrl = new CFAR_Team_Controller();
			ctrl.trialWrapper.innerObject = trial;
			ctrl.addNewMember();
			ctrl.newMember.Contact_address_ref_gne__c = null;
			//ctrl.submitMember();
            ctrl.fillTeamMembers();
            ctrl.newMember.function_role_gne__c = 'SRT = Study Review Team Chair';
            System.assertEquals(false, ctrl.isExternalVendor());
            ctrl.newMember.function_role_gne__c = 'Other-External';
            System.assertEquals(true, ctrl.isExternalVendor());
            List<System.SelectOption> dAndD = ctrl.getDollarAndDrugSelectOptions();
            //ctrl.newMember.Dollar_and_Drug_ref_gne__c  = ctrl.getDollarAndDrugSelectOptions();
            //update ctrl.newMember;
            ctrl.fillTeamMembers();
			//system.assert(ctrl.isError);
			//system.assert(ctrl.errorMessage == '<b>Error:</b> Address cannot be blank. Please enter a value.');

			ctrl.addNewMember();
			ctrl.selectedContactId = primaryContact.Id;
			ctrl.submitMember();
			//system.assert(ctrl.isError);
			//system.assert(ctrl.errorMessage == 'Function/Role is required');

			ctrl.addNewMember();
			List<CFAR_Team_Member_gne__c> teamMembers = ctrl.getTeamMembers();
			for(CFAR_Team_Member_gne__c t : teamMembers) {
				if(t.Is_Trial_Primary_Contact_gne__c) {
					ctrl.newMember = t;
					ctrl.newMember.Id = null;
					ctrl.newMember.Active_On_gne__c = System.today().addDays(3);
					ctrl.newMember.Function_Role_gne__c = 'test role';
					break;
				}
			}

			ctrl.submitMember();
			//system.assert(ctrl.isError);	
			//system.assert(ctrl.errorMessage == 'This person already exists in the study');
			
			Test.stopTest();
		}
    }
    
    static testMethod void addNewTeamMember(){
        User testUser = CFAR_TestUtils.createTestAdminUser();
        System.runAs(testUser){
            CFAR_Contact_gne__c primaryContact = CFAR_TestUtils.createTestPrimaryContact();
            CFAR_Trial_gne__c trial = CFAR_TestUtils.createTestTrial();
            
            CFAR_Team_Controller ctrl = new CFAR_Team_Controller();
			Test.startTest();
            ctrl.addNewMember();
            ctrl.newMember.CFAR_Trial_ref_gne__c = trial.id;
           // ctrl.submitMember();
			
                
            
            System.assertEquals(true, ctrl.getIsAdmin());
            System.assertEquals(false, ctrl.getIsStandardUser());
            Test.stopTest();
        }
    }
    
    static testMethod void UnitTest_Activation_NOK() {
        User testAvgUser = null;
		System.runAs(new User(Id = Userinfo.getUserId())) {
        	testAvgUser = CFAR_TestUtils.createTestAverageUser();
        }
        CFAR_Contact_gne__c primaryContact = CFAR_TestUtils.createTestPrimaryContact();

		system.runAs(testAvgUser)
		{
			CFAR_Trial_gne__c trial = CFAR_TestUtils.createTestTrial();

			Test.startTest();

			CFAR_Team_Controller ctrl = new CFAR_Team_Controller();
			ctrl.trialWrapper.innerObject = trial;

			List<CFAR_Team_Member_gne__c> teamMembers = ctrl.getTeamMembers();
			for(CFAR_Team_Member_gne__c t : teamMembers) {
				if(t.Is_Trial_Primary_Contact_gne__c) {
					t.Active_On_gne__c = System.today().addDays(-1);
					t.Inactive_On_gne__c = System.today();
					break;	
				}
			}
			update teamMembers;

			ctrl.addNewMember();
			ctrl.selectedContactId = primaryContact.Id;
			ctrl.contactChanged();
			system.assert(!ctrl.memberRoles.isEmpty());
			ctrl.newMember.Function_Role_gne__c = ctrl.memberRoles[0].getValue();
			ctrl.newMember.Inactive_On_gne__c = System.today();
			ctrl.submitMember();
			system.assert(ctrl.isError);
			
			Test.stopTest();
		}
    }
    
    static testMethod void UnitTest_NewPrimaryContactActivation_NOK() {
        User testAvgUser = null;
		System.runAs(new User(Id = Userinfo.getUserId())) {
        	testAvgUser = CFAR_TestUtils.createTestAverageUser();
        }
        CFAR_Contact_gne__c primaryContact = CFAR_TestUtils.createTestPrimaryContact();

		system.runAs(testAvgUser)
		{
			CFAR_Trial_gne__c trial = CFAR_TestUtils.createTestTrial();

			Test.startTest();

			CFAR_Team_Controller ctrl = new CFAR_Team_Controller();
			ctrl.trialWrapper.innerObject = trial;
			
			List<CFAR_Team_Member_gne__c> teamMembers = ctrl.getTeamMembers();
			for(CFAR_Team_Member_gne__c t : teamMembers) {
				if(t.Is_Trial_Primary_Contact_gne__c) {
					t.Inactive_On_gne__c = System.today();
					break;
				}
			}
			update teamMembers;
			
			ctrl.addNewMember();
			ctrl.selectedContactId = primaryContact.Id;
			ctrl.contactChanged();
			system.assert(!ctrl.memberRoles.isEmpty());
			ctrl.newMember.Function_Role_gne__c = ctrl.memberRoles[0].getValue();
			ctrl.submitMember();

			trial = (CFAR_Trial_gne__c) ctrl.trialWrapper.innerObject;
			system.assert(trial.Genentech_Primary_Contact_ref_gne__c != primaryContact.Id);
			
			Test.stopTest();
		}
    }

    static testMethod void UnitTest_NewPrimaryContactActivation_OK() {

    	User testAvgUser = null;
		System.runAs(new User(Id = Userinfo.getUserId())) {
        	testAvgUser = CFAR_TestUtils.createTestAverageUser();
        }
        CFAR_Contact_gne__c primaryContact = CFAR_TestUtils.createTestPrimaryContact();

		system.runAs(testAvgUser)
		{
			CFAR_Trial_gne__c trial = CFAR_TestUtils.createTestTrial();

			Test.startTest();

			CFAR_Team_Controller ctrl = new CFAR_Team_Controller();
			ctrl.trialWrapper.innerObject = trial;
			
			List<CFAR_Team_Member_gne__c> teamMembers = ctrl.getTeamMembers();
			for(CFAR_Team_Member_gne__c t : teamMembers) {
				if(t.Is_Trial_Primary_Contact_gne__c) {
					t.Inactive_On_gne__c = System.today();
					break;	
				}
			}
			update teamMembers;
			
			ctrl.addNewMember();
			ctrl.selectedContactId = primaryContact.Id;
			ctrl.contactChanged();
			system.assert(!ctrl.memberRoles.isEmpty());
			ctrl.newMember.Function_Role_gne__c = ctrl.memberRoles[0].getValue();
			ctrl.submitMember();
			CFAR_Team_Member_gne__c pc = null;
			teamMembers = ctrl.getTeamMembers();
			for(CFAR_Team_Member_gne__c t : teamMembers) {
				if(t.Contact_address_ref_gne__r.CFAR_Contact_ref_gne__c == primaryContact.Id) {
					pc = t;
					break;
				}
			}
			//ctrl.newPCMemberId = pc.Id;
			//ctrl.setNewPrimaryContact();
			//system.assert(!ApexPages.hasMessages());
			teamMembers = ctrl.getTeamMembers();
			for(CFAR_Team_Member_gne__c t : teamMembers) {
				if(t.Is_Trial_Primary_Contact_gne__c) system.assert(t.Contact_address_ref_gne__r.CFAR_Contact_ref_gne__c == primaryContact.Id);
			}
			trial = (CFAR_Trial_gne__c) ctrl.trialWrapper.innerObject;
			//system.assert(trial.Genentech_Primary_Contact_ref_gne__c == primaryContact.Id);
			
			Test.stopTest();
		}
    }

    static testMethod void UnitTest_NewMSL_OK() {
        User testAvgUser = null;
		System.runAs(new User(Id = Userinfo.getUserId())) {
        	testAvgUser = CFAR_TestUtils.createTestAverageUser();
        }
        CFAR_Contact_gne__c msl = CFAR_TestUtils.createTestMSL();

		system.runAs(testAvgUser)
		{
			CFAR_Trial_gne__c trial = CFAR_TestUtils.createTestTrial();

			Test.startTest();

			CFAR_Team_Controller ctrl = new CFAR_Team_Controller();
			ctrl.trialWrapper.innerObject = trial;
			
			List<CFAR_Team_Member_gne__c> teamMembers = ctrl.getTeamMembers();
			for(CFAR_Team_Member_gne__c t : teamMembers) {
				if(t.Is_Trial_MSL_gne__c) {
					t.Inactive_On_gne__c = System.today();
					break;
				}
			}
			update teamMembers;
			
            
			ctrl.addNewMember();
			ctrl.selectedContactId = msl.Id;
			ctrl.contactChanged();
			system.assert(!ctrl.memberRoles.isEmpty());
			ctrl.newMember.Function_Role_gne__c = ctrl.memberRoles[0].getValue();
            ctrl.newMember.Active_On_gne__c = Date.Today();
            ctrl.cancelCreateMember();
			CFAR_Team_Member_gne__c mslTeamMember = null;
			teamMembers = ctrl.getTeamMembers();
			for(CFAR_Team_Member_gne__c t : teamMembers) {
				if(t.Contact_address_ref_gne__r.CFAR_Contact_ref_gne__c == msl.Id) {
					mslTeamMember = t;
					break;
				}
			}
			
			ctrl.setNewMSL();
			teamMembers = ctrl.getTeamMembers();
			for(CFAR_Team_Member_gne__c t : teamMembers) {
				if(t.Is_Trial_MSL_gne__c) {
					system.assert(t.Contact_address_ref_gne__r.CFAR_Contact_ref_gne__c == msl.Id);
					break;
				}
			}
			trial = (CFAR_Trial_gne__c) ctrl.trialWrapper.innerObject;
			
			Test.stopTest();
		}
    }
    
    static testMethod void TeamMemberHelperTest() {
        User itAdm = CFAR_TestUtils.createTestITAdminUser();
	 	  
        PageReference pRef = Page.CFAR_AddressBookNew;
	 	 	pRef.getParameters().put('isNew', 'true');
	 		Test.setCurrentPage(pRef);
	 		Test.startTest();
	 		System.runAs(itAdm){
             
            CFAR_Contact_gne__c contact = new CFAR_Contact_gne__c();
            contact.Primary_Role_Function_gne__c = 'PI = Primary (or Principal) Investigator';
            System.assertEquals(CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR, contact.Primary_Role_Function_gne__c);
            System.assertEquals(true, CFAR_TeamMemberHelper.isContractRole(CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR));
	 		
	 	}
	 	Test.stopTest();
    }
    
    static testMethod void testGetAndEditTeamMembers() {
    	CFAR_Team_Controller ctrl = new CFAR_Team_Controller();
    	ctrl.sortDirection = 'asc';
    	ctrl.sortExpression = null;
    	
    	CFAR_Parent_Organization_gne__c parentOrg = CFAR_DataFactory.createParentOrganization();
    	insert parentOrg;
    	CFAR_Institution_gne__c institution = CFAR_DataFactory.createInstitution(parentOrg, 'testInstitution');
    	insert institution;
    	CFAR_Contact_gne__c contact1 = CFAR_DataFactory.createContact('testX', CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_MANAGER);
    	CFAR_Contact_gne__c contact2 = CFAR_DataFactory.createContact('testXY', CFAR_TeamMemberHelper.ROLE_CLINICAL_ASSISTANT);
    	contact2.Role_Function_gne__c = CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR;
    	contact2.Tertiary_Role_Function_gne__c = CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_MANAGER;
		List<CFAR_Contact_gne__c> contacts = new List<CFAR_Contact_gne__c> ();
		contacts.add(contact1);
		contacts.add(contact2);
		insert contacts;
    	CFAR_Contact_Address_gne__c contactAddress = CFAR_DataFactory.createContactAddress(institution);
    	insert contactAddress;
    	List<CFAR_Contact_Address_JO_gne__c> contactJAs = new List<CFAR_Contact_Address_JO_gne__c> ();
    	CFAR_Contact_Address_JO_gne__c contactJoinAddress1 = CFAR_DataFactory.createContactAddressJO(contact1, contactAddress);
    	CFAR_Contact_Address_JO_gne__c contactJoinAddress2 = CFAR_DataFactory.createContactAddressJO(contact2, contactAddress);
    	contactJAs.add(contactJoinAddress1);
    	contactJAs.add(contactJoinAddress2);
    	insert contactJAs;
    	CFAR_Trial_gne__c trial = CFAR_DataFactory.createTrial(3);
    	trial.Genentech_Primary_Contact_ref_gne__c = contact2.Id;
    	insert trial;
    	List<CFAR_Team_Member_gne__c> teamMembers = new List<CFAR_Team_Member_gne__c> ();
    	CFAR_Team_Member_gne__c separatedTM = CFAR_DataFactory.createTeamMember(trial, 'testTeamMember5', contactJoinAddress2, CFAR_TeamMemberHelper.ROLE_CLINICAL_ASSISTANT);
    	teamMembers.add(CFAR_DataFactory.createTeamMember(trial, 'testTeamMember1', contactJoinAddress1, 'SRT = Study Review Team Chair'));
    	teamMembers.add(CFAR_DataFactory.createTeamMember(trial, 'testTeamMember2', contactJoinAddress1, 'MSD = Medical Science Director'));
    	teamMembers.add(CFAR_DataFactory.createTeamMember(trial, 'testTeamMember3', contactJoinAddress1, 'MSL = Medical Science Liaison'));
    	teamMembers.add(CFAR_DataFactory.createTeamMember(trial, 'testTeamMember4', contactJoinAddress1, CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_MANAGER));
    	teamMembers.add(separatedTM);
    	teamMembers.add(CFAR_DataFactory.createTeamMember(trial, 'testTeamMember6', contactJoinAddress1, CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR));
    	teamMembers.add(CFAR_DataFactory.createTeamMember(trial, 'testTeamMember7', contactJoinAddress1, CFAR_TeamMemberHelper.ROLE_SUB_INVESTIGATOR));
    	teamMembers.add(CFAR_DataFactory.createTeamMember(trial, 'testTeamMember8', contactJoinAddress1, CFAR_TeamMemberHelper.ROLE_STUDY_COORDINATOR));
    	teamMembers.add(CFAR_DataFactory.createTeamMember(trial, 'testTeamMember8', contactJoinAddress1, CFAR_TeamMemberHelper.ROLE_PHARMACIST));
    	teamMembers.add(CFAR_DataFactory.createTeamMember(trial, 'testTeamMember9', contactJoinAddress1, CFAR_TeamMemberHelper.ROLE_OTHER_EXTERNAL));
		insert teamMembers;
		
		ctrl.trial.Id = trial.Id;
    	List<CFAR_Team_Member_gne__c> result = ctrl.getTeamMembers();
    	ctrl.memberId = separatedTM.Id;
    	ctrl.editMember();
    	
    	system.assert(result.size() > 0);
    	system.assertEquals(contact2.Id , ctrl.selectedContactId);
    	system.assert(ctrl.hasMoreRoles);
    }
    
    static testMethod void testGetMemberAddress2AndAddressTypeSelectOptions2() {
		CFAR_Address_Type_gne__c addressType1 = new CFAR_Address_Type_gne__c(Name = 'addressType1', Active_gne__c = true);
		CFAR_Address_Type_gne__c addressType2 = new CFAR_Address_Type_gne__c(Name = 'addressType2', Active_gne__c = true);
		CFAR_Address_Type_gne__c addressType3 = new CFAR_Address_Type_gne__c(Name = 'addressType3', Active_gne__c = true);
		CFAR_Address_Type_gne__c addressType4 = new CFAR_Address_Type_gne__c(Name = 'addressType4', Active_gne__c = true);
        List<CFAR_Address_Type_gne__c> addTypes = new List<CFAR_Address_Type_gne__c> ();
        addTypes.add(addressType1);
        addTypes.add(addressType2);
        addTypes.add(addressType3);
        addTypes.add(addressType4);
        insert addTypes;
    	CFAR_Team_Controller ctrl = new CFAR_Team_Controller();
    	ctrl.sortDirection = 'asc';
    	ctrl.sortExpression = null;
    	
    	CFAR_Parent_Organization_gne__c parentOrg = CFAR_DataFactory.createParentOrganization();
    	insert parentOrg;
    	CFAR_Institution_gne__c institution1 = CFAR_DataFactory.createInstitution(parentOrg, 'testInstitution');
    	CFAR_Institution_gne__c institution2 = CFAR_DataFactory.createInstitution(parentOrg, 'testInstitution2');
    	List<CFAR_Institution_gne__c> institutions = new List<CFAR_Institution_gne__c> (); 
    	institutions.add(institution1);
    	institutions.add(institution2);
    	insert (institutions);
    	CFAR_Contact_gne__c contact1 = CFAR_DataFactory.createContact('testX', CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_MANAGER);
    	contact1.Role_Function_gne__c = CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR;
    	contact1.Tertiary_Role_Function_gne__c = CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_MANAGER;
		insert contact1;
    	CFAR_Contact_Address_gne__c contactAddress1 = CFAR_DataFactory.createContactAddress2(institution1, addressType1);
    	contactAddress1.Country_gne__c = 'GER';
    	CFAR_Contact_Address_gne__c contactAddress2 = CFAR_DataFactory.createContactAddress2(institution2, addressType2);
    	List<CFAR_Contact_Address_gne__c> contactAddress = new List<CFAR_Contact_Address_gne__c> ();
    	contactAddress.add(contactAddress1);
    	contactAddress.add(contactAddress2);
    	insert contactAddress;
    	List<CFAR_Contact_Address_JO_gne__c> contactJAs = new List<CFAR_Contact_Address_JO_gne__c> ();
    	CFAR_Contact_Address_JO_gne__c contactJoinAddress1 = CFAR_DataFactory.createContactAddressJO(contact1, contactAddress1);
    	CFAR_Contact_Address_JO_gne__c contactJoinAddress2 = CFAR_DataFactory.createContactAddressJO(contact1, contactAddress2);
    	contactJoinAddress2.Department_Division_gne__c = 'test department';
    	contactJAs.add(contactJoinAddress1);
    	contactJAs.add(contactJoinAddress2);
    	insert contactJAs;
    	CFAR_Trial_gne__c trial = CFAR_DataFactory.createTrial(3);
    	trial.Genentech_Primary_Contact_ref_gne__c = contact1.Id;
    	insert trial;
    	CFAR_Team_Member_gne__c tm = CFAR_DataFactory.createTeamMember(trial, 'testTeamMember5', contactJoinAddress2, CFAR_TeamMemberHelper.ROLE_CLINICAL_ASSISTANT);
		insert tm;
		
		ctrl.trial.Id = trial.Id;
		ctrl.selectedContactId = contact1.Id;
    	List<SelectOption> result = ctrl.getMemberAddresses2();
    	system.assertEquals(3,result.size());
    	
		ctrl.addNewMember();
		ctrl.newMember.Contact_Address_ref_gne__c = contactJoinAddress1.Id;
		ctrl.newMember.Address_Type_ref_gne__c = null;
		result = ctrl.getAddressTypeSelectOptions2();
    	system.assertEquals(4, result.size());
    }
    
    static testMethod void testSetNewPrimaryContact() {
    	CFAR_Team_Controller ctrl = new CFAR_Team_Controller();
    	ctrl.sortDirection = 'asc';
    	ctrl.sortExpression = null;
    	
    	CFAR_Parent_Organization_gne__c parentOrg = CFAR_DataFactory.createParentOrganization();
    	insert parentOrg;
    	CFAR_Institution_gne__c institution = CFAR_DataFactory.createInstitution(parentOrg, 'testInstitution');
    	insert (institution);
    	List<CFAR_Contact_gne__c> contacts = new List<CFAR_Contact_gne__c> ();
    	CFAR_Contact_gne__c contact1 = CFAR_DataFactory.createContact('testX', CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_MANAGER);
    	CFAR_Contact_gne__c contact2 = CFAR_DataFactory.createContact('testY', CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR);
    	contact1.Role_Function_gne__c = CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR;
    	contact2.Tertiary_Role_Function_gne__c = CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_MANAGER;
    	contacts.add(contact1);
    	contacts.add(contact2);
		insert contacts;
		List<CFAR_Contact_Address_gne__c> contactAddresses = new List<CFAR_Contact_Address_gne__c> ();
    	CFAR_Contact_Address_gne__c contactAddress1 = CFAR_DataFactory.createContactAddress(institution);
    	CFAR_Contact_Address_gne__c contactAddress2 = CFAR_DataFactory.createContactAddress(institution);
    	contactAddresses.add(contactAddress1);
    	contactAddresses.add(contactAddress2);
    	insert contactAddresses;
    	List<CFAR_Contact_Address_JO_gne__c> contactJoinAdresses = new List<CFAR_Contact_Address_JO_gne__c> ();
    	CFAR_Contact_Address_JO_gne__c contactJoinAddress1 = CFAR_DataFactory.createContactAddressJO(contact1, contactAddress1);
    	CFAR_Contact_Address_JO_gne__c contactJoinAddress2 = CFAR_DataFactory.createContactAddressJO(contact2, contactAddress2);
    	contactJoinAdresses.add(contactJoinAddress1);
    	contactJoinAdresses.add(contactJoinAddress2);
    	insert contactJoinAdresses;
    	
    	CFAR_Trial_gne__c trial = CFAR_DataFactory.createTrial(3);
    	trial.Genentech_Primary_Contact_ref_gne__c = contact1.Id;
    	insert trial;
    	List<CFAR_Team_Member_gne__c> teamMembers = new List<CFAR_Team_Member_gne__c> ();
    	CFAR_Team_Member_gne__c tm1 = CFAR_DataFactory.createTeamMember(trial, 'testTeamMember5', contactJoinAddress1, CFAR_TeamMemberHelper.ROLE_CLINICAL_ASSISTANT);
    	CFAR_Team_Member_gne__c tm2 = CFAR_DataFactory.createTeamMember(trial, 'testTeamMember6', contactJoinAddress2, CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR);
		teamMembers.add(tm1);
		teamMembers.add(tm2);
		insert teamMembers;
		
		ctrl.trial.Id = trial.Id;
		Id trialId = trial.Id;
		ctrl.getTeamMembers();
		ctrl.newPCMemberId = tm2.Id;
    	PageReference result = ctrl.SetNewPrimaryContact();
    	system.assert(CFAR_Utils.hasAlreadyProcessed());
    	trial = [SELECT Genentech_Primary_Contact_ref_gne__c FROM CFAR_Trial_gne__c WHERE Id = :trialId];
    	system.assertEquals(contact2.Id, trial.Genentech_Primary_Contact_ref_gne__c);
    }
    
    static testMethod void testSetNewPrimaryContactWithException() {
    	CFAR_Team_Controller ctrl = new CFAR_Team_Controller();
    	ctrl.sortDirection = 'asc';
    	ctrl.sortExpression = null;
    	
    	CFAR_Parent_Organization_gne__c parentOrg = CFAR_DataFactory.createParentOrganization();
    	insert parentOrg;
    	CFAR_Institution_gne__c institution = CFAR_DataFactory.createInstitution(parentOrg, 'testInstitution');
    	insert (institution);
    	List<CFAR_Contact_gne__c> contacts = new List<CFAR_Contact_gne__c> ();
    	CFAR_Contact_gne__c contact1 = CFAR_DataFactory.createContact('testX', CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_MANAGER);
    	CFAR_Contact_gne__c contact2 = CFAR_DataFactory.createContact('testY', CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR);
    	contact1.Role_Function_gne__c = CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR;
    	contact2.Tertiary_Role_Function_gne__c = CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_MANAGER;
    	contacts.add(contact1);
    	contacts.add(contact2);
		insert contacts;
		List<CFAR_Contact_Address_gne__c> contactAddresses = new List<CFAR_Contact_Address_gne__c> ();
    	CFAR_Contact_Address_gne__c contactAddress1 = CFAR_DataFactory.createContactAddress(institution);
    	CFAR_Contact_Address_gne__c contactAddress2 = CFAR_DataFactory.createContactAddress(institution);
    	contactAddresses.add(contactAddress1);
    	contactAddresses.add(contactAddress2);
    	insert contactAddresses;
    	List<CFAR_Contact_Address_JO_gne__c> contactJoinAdresses = new List<CFAR_Contact_Address_JO_gne__c> ();
    	CFAR_Contact_Address_JO_gne__c contactJoinAddress1 = CFAR_DataFactory.createContactAddressJO(contact1, contactAddress1);
    	CFAR_Contact_Address_JO_gne__c contactJoinAddress2 = CFAR_DataFactory.createContactAddressJO(contact2, contactAddress2);
    	contactJoinAdresses.add(contactJoinAddress1);
    	contactJoinAdresses.add(contactJoinAddress2);
    	insert contactJoinAdresses;
    	
    	CFAR_Trial_gne__c trial = CFAR_DataFactory.createTrial(3);
    	trial.Genentech_Primary_Contact_ref_gne__c = contact1.Id;
    	insert trial;
    	List<CFAR_Team_Member_gne__c> teamMembers = new List<CFAR_Team_Member_gne__c> ();
    	CFAR_Team_Member_gne__c tm1 = CFAR_DataFactory.createTeamMember(trial, 'testTeamMember5', contactJoinAddress1, CFAR_TeamMemberHelper.ROLE_CLINICAL_ASSISTANT);
    	CFAR_Team_Member_gne__c tm2 = CFAR_DataFactory.createTeamMember(trial, 'testTeamMember6', contactJoinAddress2, CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR);
		teamMembers.add(tm1);
		teamMembers.add(tm2);
		insert teamMembers;
		
		ctrl.trial.Id = trial.Id;
		Id trialId = trial.Id;
		ctrl.getTeamMembers();
    	PageReference result = ctrl.SetNewPrimaryContact();
    	
    	List<Apexpages.Message> msgs = ApexPages.getMessages();
    	system.assertEquals(1, msgs.size());
    }
    static testMethod void testAddressChangedAndHasMoreAddresses() {
    	CFAR_Address_Type_gne__c addressType1 = new CFAR_Address_Type_gne__c(Name = 'addressType1', Active_gne__c = true);
    	insert addressType1;
    	CFAR_Team_Controller ctrl = new CFAR_Team_Controller();
    	ctrl.sortDirection = 'asc';
    	ctrl.sortExpression = null;
    	//with no address
    	CFAR_Trial_gne__c trial = CFAR_DataFactory.createTrial(3);
    	insert trial;
		ctrl.trial.Id = trial.Id;
		ctrl.addNewMember();
		ctrl.newMember.Contact_Address_ref_gne__c = null;
		ctrl.addressChanged();
    	system.assertEquals(null, ctrl.newMember.Address_Type_ref_gne__c);
    	
    	//with address
    	CFAR_Parent_Organization_gne__c parentOrg = CFAR_DataFactory.createParentOrganization();
    	insert parentOrg;
    	CFAR_Institution_gne__c institution = CFAR_DataFactory.createInstitution(parentOrg, 'testInstitution');
    	insert (institution);
    	CFAR_Contact_gne__c contact1 = CFAR_DataFactory.createContact('testX', CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_MANAGER);
		insert contact1;
    	CFAR_Contact_Address_gne__c contactAddress1 = CFAR_DataFactory.createContactAddress2(institution, addressType1);
    	insert contactAddress1;
    	CFAR_Contact_Address_JO_gne__c contactJoinAddress1 = CFAR_DataFactory.createContactAddressJO(contact1, contactAddress1);
    	insert contactJoinAddress1;
		ctrl.newMember.Contact_Address_ref_gne__c = contactJoinAddress1.Id;
		ctrl.selectedContactId = contact1.Id;
		List<SelectOption> memAdd = ctrl.getMemberAddresses2();
		ctrl.addressChanged();
		
    	system.assertEquals(addressType1.Id, ctrl.newMember.Address_Type_ref_gne__c);
    	system.assertEquals(false, ctrl.getHasMoreAddresses());
    }
    
    static testMethod void testSubmitMemberErrorMessage() {
    	CFAR_Address_Type_gne__c addressType1 = new CFAR_Address_Type_gne__c(Name = 'addressType1', Active_gne__c = true);
    	insert addressType1;
    	CFAR_Team_Controller ctrl = new CFAR_Team_Controller();
    	ctrl.sortDirection = 'asc';
    	ctrl.sortExpression = null;
    	CFAR_Trial_gne__c trial = CFAR_DataFactory.createTrial(3);
    	insert trial;
    	CFAR_Parent_Organization_gne__c parentOrg = CFAR_DataFactory.createParentOrganization();
    	insert parentOrg;
    	CFAR_Institution_gne__c institution = CFAR_DataFactory.createInstitution(parentOrg, 'testInstitution');
    	insert (institution);
    	CFAR_Contact_gne__c contact1 = CFAR_DataFactory.createContact('testX', CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_MANAGER);
		insert contact1;
    	CFAR_Contact_Address_gne__c contactAddress1 = CFAR_DataFactory.createContactAddress2(institution, addressType1);
    	insert contactAddress1;
    	CFAR_Contact_Address_JO_gne__c contactJoinAddress1 = CFAR_DataFactory.createContactAddressJO(contact1, contactAddress1);
    	insert contactJoinAddress1;
    	CFAR_Team_Member_gne__c tm1 = CFAR_DataFactory.createTeamMember(trial, 'testTeamMember5', contactJoinAddress1, CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR);
		insert tm1;
	    CFAR_Roles_To_Users_Mapping_gne__c setting = new CFAR_Roles_To_Users_Mapping_gne__c();
	    setting.role_function_gne__c = 'Investigator';
	    setting.drop_down_value_gne__c  = CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR;
	    setting.Name = 'PI';
	    setting.Permissions_gne__c='GNE-CFAR-ReadOnlyUser';
	    insert setting;
		//member exists
		ctrl.trial.Id = trial.Id;
		ctrl.addNewMember();
		ctrl.newMember.Function_Role_gne__c = CFAR_TeamMemberHelper.ROLE_SUB_INVESTIGATOR;
		ctrl.selectedContactId = contact1.Id;
		List<CFAR_Team_Member_gne__c> teamMembers = ctrl.getTeamMembers();
		PageReference result = ctrl.submitMember();
		List<Apexpages.Message> msgs = ApexPages.getMessages();
    	system.assertEquals(ApexPages.Severity.ERROR, msgs.get(0).getSeverity());
    	system.assertEquals('This person already exists in the study', msgs.get(0).getSummary());
    	//member activeOn in future
    	ctrl.newMember.Active_On_gne__c = Date.today().addDays(3); 
		result = ctrl.submitMember();
		msgs = ApexPages.getMessages();
    	system.assertEquals(ApexPages.Severity.ERROR, msgs.get(1).getSeverity());
    	system.assertEquals('Active On cannot be in the future', msgs.get(1).getSummary());
    	//member activeOn blank
    	ctrl.newMember.Active_On_gne__c = null; 
		result = ctrl.submitMember();
		msgs = ApexPages.getMessages();
    	system.assertEquals(ApexPages.Severity.ERROR, msgs.get(2).getSeverity());
    	system.assertEquals('Active On cannot be blank. Please enter a value.', msgs.get(2).getSummary());
    	//member inactiveOn in future
    	ctrl.newMember.Active_On_gne__c = Date.today();
    	ctrl.newMember.Inactive_On_gne__c = Date.today().addDays(3);
		result = ctrl.submitMember();
		msgs = ApexPages.getMessages();
    	system.assertEquals(ApexPages.Severity.ERROR, msgs.get(3).getSeverity());
    	system.assertEquals('Inactive On cannot be in the future', msgs.get(3).getSummary());
    }
}