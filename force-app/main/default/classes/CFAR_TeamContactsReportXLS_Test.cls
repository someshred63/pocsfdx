@isTest(SeeAllData=false)
private class CFAR_TeamContactsReportXLS_Test {

    static testMethod void testCreateXLSData() {
    	ApexPages.currentPage().getParameters().put('products', '');
    	ApexPages.currentPage().getParameters().put('tmNames', '');
    	ApexPages.currentPage().getParameters().put('csm', '');
    	ApexPages.currentPage().getParameters().put('csa', '');
    	ApexPages.currentPage().getParameters().put('parentOrganizations', '');
    	ApexPages.currentPage().getParameters().put('studyStatus', '');
    	ApexPages.currentPage().getParameters().put('institutions', '');
    	ApexPages.currentPage().getParameters().put('ctmsNo', '');
    	ApexPages.currentPage().getParameters().put('gstarsNo', '');
    	ApexPages.currentPage().getParameters().put('tmStatus', '');
    	ApexPages.currentPage().getParameters().put('internalExternal', 'External');
    	ApexPages.currentPage().getParameters().put('functionRoles', '' + CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR);
    	
    	CFAR_Address_Type_gne__c addressType1 = new CFAR_Address_Type_gne__c(Name = 'addressType1', Active_gne__c = true);
    	insert addressType1;
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
    	
    	CFAR_TeamContactsReportXLS_Ctrl ctrl = new CFAR_TeamContactsReportXLS_Ctrl();
    	
    	system.assertEquals(1, ctrl.teamContactsXLSData.size());
    }
    
    static testMethod void testCSMFilter() {
    	ApexPages.currentPage().getParameters().put('products', '');
    	ApexPages.currentPage().getParameters().put('tmNames', '');
    	ApexPages.currentPage().getParameters().put('csa', '');
    	ApexPages.currentPage().getParameters().put('parentOrganizations', '');
    	ApexPages.currentPage().getParameters().put('studyStatus', '');
    	ApexPages.currentPage().getParameters().put('institutions', '');
    	ApexPages.currentPage().getParameters().put('ctmsNo', '');
    	ApexPages.currentPage().getParameters().put('gstarsNo', '');
    	ApexPages.currentPage().getParameters().put('tmStatus', '');
    	ApexPages.currentPage().getParameters().put('internalExternal', 'All');
    	ApexPages.currentPage().getParameters().put('functionRoles', '');
    	
    	CFAR_Address_Type_gne__c addressType1 = new CFAR_Address_Type_gne__c(Name = 'addressType1', Active_gne__c = true);
    	insert addressType1;
    	CFAR_Contact_gne__c contact1 = CFAR_DataFactory.createContact2('testX', CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_MANAGER, 'TestFirstName', 'TestLastName', Date.today());
    	contact1.Mobile_Phone_gne__c = '650-438-9131';
    	CFAR_Contact_gne__c contact2 = CFAR_DataFactory.createContact2('testX2', CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR, 'TestFirstName2', 'TestLastName2', Date.today());
		List<CFAR_Contact_gne__c> contacts = new List<CFAR_Contact_gne__c> ();
		contacts.add(contact1);
		contacts.add(contact2);
		insert contacts;
		
        ApexPages.currentPage().getParameters().put('csm', 'TestLastName, TestFirstName');
		
    	CFAR_Trial_gne__c trial1 = CFAR_DataFactory.createTrial(3);
    	trial1.Genentech_Primary_Contact_ref_gne__c = contact1.Id;
    	trial1.CTMS_gne__c = 'TESTCTMS123';
    	CFAR_Trial_gne__c trial2 = CFAR_DataFactory.createTrial(3);
    	List<CFAR_Trial_gne__c> trials = new List<CFAR_Trial_gne__c> ();
    	trials.add(trial1);
    	trials.add(trial2);
    	insert trials;
    	CFAR_Parent_Organization_gne__c parentOrg = CFAR_DataFactory.createParentOrganization();
    	insert parentOrg;
    	CFAR_Institution_gne__c institution = CFAR_DataFactory.createInstitution(parentOrg, 'testInstitution');
    	insert (institution);
    	CFAR_Contact_Address_gne__c contactAddress1 = CFAR_DataFactory.createContactAddress2(institution, addressType1);
    	CFAR_Contact_Address_gne__c contactAddress2 = CFAR_DataFactory.createContactAddress2(institution, addressType1);
    	List<CFAR_Contact_Address_gne__c> contactAddresses = new List<CFAR_Contact_Address_gne__c> ();
    	contactAddresses.add(contactAddress1);
    	contactAddresses.add(contactAddress2);
    	insert contactAddresses;
    	CFAR_Contact_Address_JO_gne__c contactJoinAddress1 = CFAR_DataFactory.createContactAddressJO(contact1, contactAddress1);
    	CFAR_Contact_Address_JO_gne__c contactJoinAddress2 = CFAR_DataFactory.createContactAddressJO(contact2, contactAddress2);
    	List<CFAR_Contact_Address_JO_gne__c> contactJoinObjects = new List<CFAR_Contact_Address_JO_gne__c> ();
    	contactJoinObjects.add(contactJoinAddress1);
    	contactJoinObjects.add(contactJoinAddress2);
    	insert contactJoinObjects;
    	CFAR_Team_Member_gne__c tm1 = CFAR_DataFactory.createTeamMember(trial1, 'testTeamMember1', contactJoinAddress1, CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_MANAGER);
    	CFAR_Team_Member_gne__c tm2 = CFAR_DataFactory.createTeamMember(trial2, 'testTeamMember2', contactJoinAddress2, CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR);
    	List<CFAR_Team_Member_gne__c> teamMembers = new List<CFAR_Team_Member_gne__c> ();
    	teamMembers.add(tm1);
    	teamMembers.add(tm2);
		insert teamMembers;
    	
    	CFAR_TeamContactsReportXLS_Ctrl ctrl = new CFAR_TeamContactsReportXLS_Ctrl();
    	
    	system.assertEquals(1, ctrl.teamContactsXLSData.size());
    }
    
    static testMethod void testCSAFilter() {
    	ApexPages.currentPage().getParameters().put('products', '');
    	ApexPages.currentPage().getParameters().put('tmNames', '');
    	ApexPages.currentPage().getParameters().put('csm', '');
    	ApexPages.currentPage().getParameters().put('parentOrganizations', '');
    	ApexPages.currentPage().getParameters().put('studyStatus', '');
    	ApexPages.currentPage().getParameters().put('institutions', '');
    	ApexPages.currentPage().getParameters().put('ctmsNo', '');
    	ApexPages.currentPage().getParameters().put('gstarsNo', '');
    	ApexPages.currentPage().getParameters().put('tmStatus', '');
    	ApexPages.currentPage().getParameters().put('internalExternal', 'Internal');
    	ApexPages.currentPage().getParameters().put('functionRoles', '');
    	
    	CFAR_Address_Type_gne__c addressType1 = new CFAR_Address_Type_gne__c(Name = 'addressType1', Active_gne__c = true);
    	insert addressType1;
    	CFAR_Contact_gne__c contact1 = CFAR_DataFactory.createContact2('testX', CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_ASSOCIATE, 'TestFirstName', 'TestLastName', Date.today());
    	contact1.Phone_gne__c = '650-438-9131';
    	CFAR_Contact_gne__c contact2 = CFAR_DataFactory.createContact2('testX2', CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR, 'TestFirstName2', 'TestLastName2', Date.today());
		List<CFAR_Contact_gne__c> contacts = new List<CFAR_Contact_gne__c> ();
		contacts.add(contact1);
		contacts.add(contact2);
		insert contacts;
		
        ApexPages.currentPage().getParameters().put('csa', 'TestLastName, TestFirstName');
		
    	CFAR_Trial_gne__c trial1 = CFAR_DataFactory.createTrial(3);
    	trial1.Other_Trial_gne_Id__c = 'TESTTRIAL123';
    	CFAR_Trial_gne__c trial2 = CFAR_DataFactory.createTrial(3);
    	List<CFAR_Trial_gne__c> trials = new List<CFAR_Trial_gne__c> ();
    	trials.add(trial1);
    	trials.add(trial2);
    	insert trials;
    	CFAR_Parent_Organization_gne__c parentOrg = CFAR_DataFactory.createParentOrganization();
    	insert parentOrg;
    	CFAR_Institution_gne__c institution = CFAR_DataFactory.createInstitution(parentOrg, 'testInstitution');
    	insert (institution);
    	CFAR_Contact_Address_gne__c contactAddress1 = CFAR_DataFactory.createContactAddress2(institution, addressType1);
    	CFAR_Contact_Address_gne__c contactAddress2 = CFAR_DataFactory.createContactAddress2(institution, addressType1);
    	List<CFAR_Contact_Address_gne__c> contactAddresses = new List<CFAR_Contact_Address_gne__c> ();
    	contactAddresses.add(contactAddress1);
    	contactAddresses.add(contactAddress2);
    	insert contactAddresses;
    	CFAR_Contact_Address_JO_gne__c contactJoinAddress1 = CFAR_DataFactory.createContactAddressJO(contact1, contactAddress1);
    	CFAR_Contact_Address_JO_gne__c contactJoinAddress2 = CFAR_DataFactory.createContactAddressJO(contact2, contactAddress2);
    	List<CFAR_Contact_Address_JO_gne__c> contactJoinObjects = new List<CFAR_Contact_Address_JO_gne__c> ();
    	contactJoinObjects.add(contactJoinAddress1);
    	contactJoinObjects.add(contactJoinAddress2);
    	insert contactJoinObjects;
    	CFAR_Team_Member_gne__c tm1 = CFAR_DataFactory.createTeamMember(trial1, 'testTeamMember1', contactJoinAddress1, CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_ASSOCIATE);
    	CFAR_Team_Member_gne__c tm2 = CFAR_DataFactory.createTeamMember(trial2, 'testTeamMember2', contactJoinAddress2, CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR);
    	List<CFAR_Team_Member_gne__c> teamMembers = new List<CFAR_Team_Member_gne__c> ();
    	teamMembers.add(tm1);
    	teamMembers.add(tm2);
		insert teamMembers;
    	
    	CFAR_TeamContactsReportXLS_Ctrl ctrl = new CFAR_TeamContactsReportXLS_Ctrl();
    	
    	system.assertEquals(1, ctrl.teamContactsXLSData.size());
    }
}