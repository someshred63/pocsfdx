@isTest(seeAllData=false)
private class CFAR_AddressBookNew_Controller_Test {

	@testSetup
	static void setup() {
		CFAR_TestUtils.createTestITAdminUser();
	}

    //test New Contact Button
	static testMethod void testAddingNewContactButton() {
	 	User itAdm = [SELECT Id FROM User WHERE alias = 'testITAd'];
	 	PageReference pRef = Page.CFAR_AddressBookNew;
        Test.setCurrentPage(pRef);
        Test.startTest();
        System.runAs(itAdm){
      	CFAR_AddressBookNew_Controller cabnc = new CFAR_AddressBookNew_Controller();
      	cabnc.addNewContact();
        }
        Test.stopTest();
 }
    //Test adding new address
    static testMethod void testAddingNewAddressLW(){
        User itAdmin = [SELECT Id FROM User WHERE alias = 'testITAd'];
        System.runAs(itAdmin){ 
            CFAR_TestUtils.createRolesToUsersMapping();
            CFAR_TestUtils.createDegrees();
           	CFAR_Parent_Organization_gne__c parent = new CFAR_Parent_Organization_gne__c();
         	parent.Name = 'testparent';
         	parent.Active_gne__c = true;
         	insert parent;
            System.assertEquals(1, [SELECT ID FROM CFAR_Parent_Organization_gne__c].size());
            
            CFAR_Institution_gne__c institution = new CFAR_Institution_gne__c();
        	institution.Name = 'TestInstitution';
        	institution.Parent_Organization__c = [SELECT id FROM CFAR_Parent_Organization_gne__c].get(0).id;
        	institution.Active_gne__c = true;
        	insert institution;
             
            CFAR_Institution_gne__c institution2 = new CFAR_Institution_gne__c();
        	institution2.Name = 'TestInstitution2';
        	institution2.Parent_Organization__c = [SELECT id FROM CFAR_Parent_Organization_gne__c].get(0).id;
        	institution2.Active_gne__c = true;
        	insert institution2;
            System.assertEquals(2, [SELECT ID FROM CFAR_Institution_gne__c].size());
             
            CFAR_Address_Type_gne__c addressType = new CFAR_Address_Type_gne__c();
            addressType.Name = 'Fedex Delivery';
            insert addressType;
            System.assertEquals(1, [SELECT ID FROM CFAR_Address_Type_gne__c].size());
            
            CFAR_Contact_Address_gne__c address = new CFAR_Contact_Address_gne__c();
    		address.Address_Type_ref_gne__c = [select Id from CFAR_Address_Type_gne__c where Name = 'Fedex Delivery' order by Active_gne__c desc limit 1][0].Id;
    		address.Country_gne__c = 'Argentina';
    		address.Province_gne__c = 'TestProvince';
			address.City_gne__c = 'TestCity';
			address.Address_gne__c = 'TestAddress';
			address.Postal_Code_gne__c = '12345';
        	address.institution_gne__c = [SELECT id FROM CFAR_Institution_gne__c].get(0).id;
			insert address;
            CFAR_Contact_Address_gne__c address2 = new CFAR_Contact_Address_gne__c();
    		address2.Address_Type_ref_gne__c = [select Id from CFAR_Address_Type_gne__c where Name = 'Fedex Delivery' order by Active_gne__c desc limit 1][0].Id;
    		address2.Country_gne__c = 'Argentina2';
    		address2.Province_gne__c = 'TestProvince2';
			address2.City_gne__c = 'TestCity2';
			address2.Address_gne__c = 'TestAddress2';
			address2.Postal_Code_gne__c = '12345';
        	address2.institution_gne__c = [SELECT id FROM CFAR_Institution_gne__c].get(0).id;
			insert address2;
            System.assertEquals(2, [SELECT ID FROM CFAR_Contact_Address_gne__c].size());
        }
        
   			PageReference pRef = Page.CFAR_AddressBookNew;
	 	 	pRef.getParameters().put('isNew', 'true');
	 		Test.setCurrentPage(pRef);
	 		Test.startTest();
	 		System.runAs(itAdmin){     
   
             CFAR_AddressBookNew_Controller cabnc = new CFAR_AddressBookNew_Controller();
             
            cabnc.addNewContact();
            cabnc.contact.First_Name_gne__c = 'TestFirstName';
            cabnc.contact.Last_Name_gne__c = 'TestLastName';
            cabnc.contact.Primary_Role_Function_gne__c = 'ADMIN = Administrator';
	 		cabnc.onPrimaryRoleChange();
            cabnc.contact.Active_Date_gne__c = Date.today();
            cabnc.contactAddressUtil.selectedInstitutionId = [SELECT ID FROM CFAR_Institution_gne__c].get(0).id;
            cabnc.contactAddressUtil.institutionSelected();
            cabnc.contactAddressUtil.selectedAddressId = [SELECT ID FROM CFAR_Contact_Address_gne__c].get(0).id;
            cabnc.contactAddressUtil.addressSelected();
            cabnc.saveContact(); 
            System.assertEquals(1, [SELECT ID FROM CFAR_Contact_gne__c].size());
            System.assertEquals(1, [SELECT ID FROM CFAR_Contact_Address_JO_gne__c].size());
            cabnc.contactAddressUtil.addnewAddress();
            cabnc.contactAddressUtil.contactId = String.valueOf(cabnc.contact.id);
            cabnc.contactAddressUtil.saveAddress();
            cabnc.contactAddressUtil.selectedInstitutionId = [SELECT ID, Parent_Organization__c FROM CFAR_Institution_gne__c].get(1).id;
            cabnc.contactAddressUtil.institutionSelected();
            cabnc.contactAddressUtil.selectedAddressId = [SELECT ID FROM CFAR_Contact_Address_gne__c].get(1).id;
            cabnc.contactAddressUtil.addressSelected();
            cabnc.contactAddressUtil.saveAddress();
            System.assertEquals(2, [SELECT ID FROM CFAR_Contact_Address_JO_gne__c].size());
                
            cabnc.contactAddressUtil.editedAddressId = [SELECT ID FROM CFAR_Contact_Address_JO_gne__c].get(0).id;
            cabnc.contactAddressUtil.editAddress();
            cabnc.contactAddressUtil.cancelAddressChanges();
            cabnc.contactAddressUtil.hasLastActiveAddressWhenSaving();
            cabnc.contactAddressUtil.getInstitutionSelectOptions();
            cabnc.contactAddressUtil.getAddressSelectOptions();
            
            cabnc.contactAddressUtil.editedAddressId = [SELECT ID FROM CFAR_Contact_Address_JO_gne__c].get(0).id;
            cabnc.contactAddressUtil.deleteAddress();
            Test.stopTest();
            }
    }
    
	 //Test Adding New Contact
	 static testMethod void testAddingNewContactProcess() {
    
         User itAdm = [SELECT Id FROM User WHERE alias = 'testITAd'];
	 	 System.runAs(itAdm) {
	 		CFAR_TestUtils.createRolesToUsersMapping();
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
            
         }   
         
            PageReference pRef = Page.CFAR_AddressBookNew;
	 	 	pRef.getParameters().put('isNew', 'true');
	 		Test.setCurrentPage(pRef);
	 		Test.startTest();
	 		System.runAs(itAdm){
             
            List<CFAR_Parent_Organization_gne__c> listOforganizations = [SELECT id FROM CFAR_Parent_Organization_gne__c];
            System.assertEquals(1, listOforganizations.size());
            List<CFAR_Institution_gne__c> listOfinstitutions = [SELECT id FROM CFAR_Institution_gne__c];
            System.assertEquals(1, listOfinstitutions.size());
            
	 		CFAR_AddressBookNew_Controller cabnc = new CFAR_AddressBookNew_Controller();
            cabnc.contact.Salutation_gne__c = 'Dr';
	 		cabnc.contact.First_Name_gne__c = 'TestFirstName';
            cabnc.contact.Middle_Initials_gne__c = 'TestMiddleName';
	 		cabnc.contact.Last_Name_gne__c = 'TestLastName';
            System.assertEquals(null, cabnc.contact.User_ref_gne__c);
            System.assertEquals('Dr', cabnc.contact.Salutation_gne__c );
	 		System.assertEquals(cabnc.primaryRoles.size(), cabnc.secondaryRoles.size());
	 		System.assertEquals(cabnc.secondaryRoles.size(), cabnc.tertiaryRoles.size());
	 		cabnc.contact.Primary_Role_Function_gne__c = 'ADMIN = Administrator';
	 		cabnc.onPrimaryRoleChange();
	 		System.assertEquals(true, cabnc.isPrimaryInternal);
	 		cabnc.contact.User_ref_gne__c = itAdm.Id;
	 		cabnc.contact.Primary_Role_Function_gne__c = 'Sub-I = Sub-investigator';
	 		cabnc.onPrimaryRoleChange();
	 		System.assertEquals(null, cabnc.contact.User_ref_gne__c);
	 		cabnc.contact.Primary_Role_Function_gne__c = 'ADMIN = Administrator';
	 		cabnc.onPrimaryRoleChange();
	 		System.assertEquals(cabnc.primaryRoles.size()-1, cabnc.secondaryRoles.size());
	 		System.assertEquals(cabnc.primaryRoles.size()-1, cabnc.tertiaryRoles.size());
	 		cabnc.contact.Role_Function_gne__c = 'CM = Contracts Manager';
	 		cabnc.onSecondaryRoleChange();
	 		System.assertEquals(cabnc.primaryRoles.size(), cabnc.secondaryRoles.size());
	 		System.assertEquals(cabnc.primaryRoles.size()-1, cabnc.tertiaryRoles.size());
	 		cabnc.contact.Tertiary_Role_Function_gne__c = 'Other-External';
	 		cabnc.onTertiaryRoleChange();
	 		cabnc.contact.Other_Tertiary_Comments_gne__c = 'abc';
	 		System.assertEquals(cabnc.primaryRoles.size(), cabnc.secondaryRoles.size());
	 		System.assertEquals(cabnc.primaryRoles.size(), cabnc.tertiaryRoles.size());
	 		cabnc.contact.Tertiary_Role_Function_gne__c = 'MD = Medical Director';
	 		cabnc.onTertiaryRoleChange();
	 		System.assertEquals(null, cabnc.contact.Other_Tertiary_Comments_gne__c);
	 		cabnc.contact.Active_Date_gne__c = Date.today();
	 		List<CFAR_Degree_gne__c> degrees = [select Id from CFAR_Degree_gne__c where Name in ('MPH', 'BS', 'DVM')];
	 		cabnc.selectedDegrees = new List<String>{degrees[0].Id, degrees[1].Id, degrees[2].Id};
	 		cabnc.contact.Primary_Role_Function_gne__c = 'ADMIN = Administrator';
	 		cabnc.onPrimaryRoleChange();
	 		cabnc.contact.User_ref_gne__c = itAdm.Id;
	 		cabnc.contact.Email_gne__c= 'aaa.bbb@ccc.com';
            cabnc.contact.Suffix_gne__c = 'Sr';
            cabnc.contact.Previous_Names_gne__c = 'TestPreviousName';
            cabnc.contact.Inactive_Date_gne__c = Date.Today() + 1;
            cabnc.contact.Employee_Type_gne__c = 'Contractor';
            cabnc.contact.Phone_gne__c = '123456789';
            cabnc.contact.Alternate_Phone_gne__c = '987654321';
            cabnc.contact.Mobile_Phone_gne__c = '918273645';
            cabnc.contact.Fax_gne__c = '123987456';
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
        	List<CFAR_Contact_Address_gne__c> listOfaddresses = [SELECT id FROM CFAR_Contact_address_gne__c];
        	System.assertEquals(1, listOfAddresses.size());
            CFAR_Institution_gne__c ins  = [SELECT Id FROM CFAR_Institution_gne__c];
            cabnc.contactAddressUtil.selectedInstitutionId = ins.id;
            cabnc.contactAddressUtil.institutionSelected();
            CFAR_Contact_Address_gne__c adr = [SELECT Id FROM CFAR_Contact_Address_gne__c];
            cabnc.contactAddressUtil.selectedAddressId = adr.id;
            cabnc.contactAddressUtil.newOrEditedAddress.Contact_Address_ref_gne__c = adr.id;
            cabnc.contactAddressUtil.addressSelected();
            cabnc.saveContact();
            
                
            List<CFAR_Contact_gne__c> listOfContacts = [SELECT id FROM CFAR_Contact_gne__c];
            List<CFAR_Contact_Address_gne__c> listOfaddresses2 = [SELECT id FROM CFAR_Contact_address_gne__c];
            System.debug('llll' + listOfContacts);
            System.assertEquals(1, listOfContacts.size());

            Integer contactDegreeCount = [SELECT COUNT() FROM CFAR_Contact_Degree_gne__c WHERE CFAR_Contact_ref_gne__c = :listOfContacts[0].Id];
            System.assertEquals(3,contactDegreeCount, 'Should create 3 contact degrees');
				CFAR_AddressBookNew_Controller cabnc2 = new CFAR_AddressBookNew_Controller();
				//cabnc2.selectedContact = [SELECT ID FROM CFAR_Contact_gne__c].get(0).id;
				//cabnc2.goToSelectedContactDetailsPage();
				//cabnc2.contactId = [SELECT ID FROM CFAR_Contact_gne__c].get(0).id;
				cabnc2.contact = [SELECT ID FROM CFAR_Contact_gne__c].get(0);

				cabnc2.deleteContact();
				List<CFAR_Contact_gne__c> listOfContacts2 = [SELECT id FROM CFAR_Contact_gne__c];
				System.assertEquals(0, listOfContacts2.size());
	 	}
	 	Test.stopTest();
	 }
	
	 static testMethod void testContactSearchAndViewMode() {
	 	User itAdm = [SELECT Id FROM User WHERE alias = 'testITAd'];
 		CFAR_Contact_gne__c c1;
	 	CFAR_Contact_gne__c c2;
	 	System.runAs(itAdm) {
	 		CFAR_TestUtils.createRolesToUsersMapping();
	 		CFAR_TestUtils.createDegrees();
			List<CFAR_Degree_gne__c> degrees = [select Id from CFAR_Degree_gne__c where Name in ('MPH', 'BS', 'DVM')];
			c1 = new CFAR_Contact_gne__c(First_Name_gne__c = 'Test1', Last_Name_gne__c = 'Contact1', Primary_Role_Function_gne__c = 'ADMIN = Administrator', User_ref_gne__c = itAdm.Id, Active_Date_gne__c = Date.today());
	 		c2 = new CFAR_Contact_gne__c(First_Name_gne__c = 'Test2', Last_Name_gne__c = 'Contact2', Primary_Role_Function_gne__c = 'Sub-I = Sub-investigator', Active_Date_gne__c = Date.today());
		
	 		List<CFAR_Contact_gne__c> contacts = new List<CFAR_Contact_gne__c>();
	 		contacts.add(c1);
	 		contacts.add(c2);
	 		insert contacts;

	 		CFAR_Contact_Degree_gne__c degreeContactJunction1 = new CFAR_Contact_Degree_gne__c(CFAR_Contact_ref_gne__c = c2.Id,CFAR_Degree_ref_gne__c = degrees[0].Id);
	 		CFAR_Contact_Degree_gne__c degreeContactJunction2 = new CFAR_Contact_Degree_gne__c(CFAR_Contact_ref_gne__c = c2.Id,CFAR_Degree_ref_gne__c = degrees[1].Id);
	 		CFAR_Contact_Degree_gne__c degreeContactJunction3 = new CFAR_Contact_Degree_gne__c(CFAR_Contact_ref_gne__c = c2.Id,CFAR_Degree_ref_gne__c = degrees[2].Id);
	 		List<CFAR_Contact_Degree_gne__c> degreeJunctions = new List<CFAR_Contact_Degree_gne__c>{degreeContactJunction1, degreeContactJunction2, degreeContactJunction3};
	 		insert degreeJunctions;
	 	}
	 	PageReference pRef = Page.CFAR_AddressBookNew;
	 	Test.setCurrentPage(pRef);
	 	Test.startTest();
	 	System.runAs(itAdm) {
	 		CFAR_AddressBookNew_Controller cabnc = new CFAR_AddressBookNew_Controller();
	 		System.assertEquals(3, cabnc.getContactSearchList1().size());
	 		System.assertEquals(0, cabnc.getContactSearchList2().size());
	 		System.assertEquals(0, cabnc.getContactSearchList3().size());
	 		System.assertEquals(0, cabnc.getContactSearchList4().size());
	 		cabnc.selectedContact = c2.id;
	 		PageReference pRef1 = cabnc.goToSelectedContactDetailsPage();
	 		System.assertNotEquals(null, pRef1);
	 		Test.setCurrentPage(pRef1);
	 		CFAR_AddressBookNew_Controller cabnc1 = new CFAR_AddressBookNew_Controller();
	 		cabnc1.contactId = c2.Id;
	 		String degreesString = cabnc1.getDegreesDisplayed();
			System.assertEquals(12, degreesString.length());
			System.assert(degreesString.contains('MPH'));
			System.assert(degreesString.contains('BS'));
	 		System.assert(degreesString.contains('DVM'));
	 		System.assertEquals(2, degreesString.countMatches(', '));
	 	}
	 	Test.stopTest();
	 }

	static testMethod void checkValidations_ShouldThrowExceptionIfRequiredFieldsAreMissing() {
		User itAdm = [SELECT Id FROM User WHERE alias = 'testITAd'];
		CFAR_Contact_gne__c c1;
		System.runAs(itAdm) {
			c1 = new CFAR_Contact_gne__c(First_Name_gne__c = 'Test1', Last_Name_gne__c = 'Contact1', Primary_Role_Function_gne__c = 'ADMIN = Administrator', Active_Date_gne__c = Date.today(), User_ref_gne__c = itAdm.Id);
			insert c1;
		}
		PageReference pRef = Page.CFAR_AddressBookNew;
		pRef.getParameters().put('id', c1.Id);
		pRef.getParameters().put('isEdit', 'true');
		Test.setCurrentPage(pRef);
		Test.startTest();
		System.runAs(itAdm) {
			CFAR_AddressBookNew_Controller ctrl = new CFAR_AddressBookNew_Controller();
			ctrl.contact.First_Name_gne__c = null;
			System.assertEquals(null, ctrl.saveContact(), 'Should not redirect if exception is thrown');
			System.assertEquals(1, ApexPages.getMessages().size());
			System.assertEquals(new ApexPages.message(ApexPages.severity.ERROR, 'Error: Please enter a value.'), ApexPages.getMessages().get(0),
				'Should throw exception if First_Name_gne__c is empty');
		}
		Test.stopTest();
	}

	static testMethod void checkValidations_ShouldThrowExceptionIfEmailIsInvalid() {
		User itAdm = [SELECT Id FROM User WHERE alias = 'testITAd'];
		CFAR_Contact_gne__c c1;
		System.runAs(itAdm) {
			c1 = new CFAR_Contact_gne__c(First_Name_gne__c = 'Test1', Last_Name_gne__c = 'Contact1', Primary_Role_Function_gne__c = 'ADMIN = Administrator', Active_Date_gne__c = Date.today(), User_ref_gne__c = itAdm.Id);
			insert c1;
		}
		PageReference pRef = Page.CFAR_AddressBookNew;
		pRef.getParameters().put('id', c1.Id);
		pRef.getParameters().put('isEdit', 'true');
		Test.setCurrentPage(pRef);
		Test.startTest();
		System.runAs(itAdm) {

			CFAR_AddressBookNew_Controller cabnc3 = new CFAR_AddressBookNew_Controller();
			cabnc3.contact.Email_gne__c = 'aaa.@bbb.com';
			System.assertEquals(null, cabnc3.saveContact(), 'Should not redirect user if email does not pass validation.');
			System.assertEquals(new ApexPages.message(ApexPages.severity.ERROR, 'Email: Invalid Email Address.'), ApexPages.getMessages().get(0),
				'Should throw exception if email doesnt pass validation');
		}
		Test.stopTest();
	}

	static testMethod void checkValidations_ShouldThrowExceptionIfContactAlreadyExist() {
		User itAdm = [SELECT Id FROM User WHERE alias = 'testITAd'];
		CFAR_Contact_gne__c c1;
		System.runAs(itAdm) {
			c1 = new CFAR_Contact_gne__c(First_Name_gne__c = 'Test1', Last_Name_gne__c = 'Contact1', Primary_Role_Function_gne__c = 'ADMIN = Administrator', Active_Date_gne__c = Date.today(), User_ref_gne__c = itAdm.Id);
			insert c1;
		}
		PageReference pRef = Page.CFAR_AddressBookNew;
		pRef.getParameters().put('isNew', 'true');
		Test.setCurrentPage(pRef);
		Test.startTest();
		System.runAs(itAdm) {
			CFAR_Parent_Organization_gne__c parent = new CFAR_Parent_Organization_gne__c();
			parent.Name = 'testparent';
			parent.Active_gne__c = true;
			insert parent;

			CFAR_Institution_gne__c institution = new CFAR_Institution_gne__c();
			institution.Name = 'TestInstitution';
			institution.Parent_Organization__c = [SELECT id FROM CFAR_Parent_Organization_gne__c].get(0).id;
			institution.Active_gne__c = true;
			insert institution;

			CFAR_Contact_Address_gne__c address = new CFAR_Contact_Address_gne__c();
			CFAR_Address_Type_gne__c addressType = new CFAR_Address_Type_gne__c(Name = 'Fedex Delivery');
			insert addressType;
			address.Address_Type_ref_gne__c = addressType.Id;
			address.Country_gne__c = 'Argentina';
			address.Province_gne__c = 'TestProvince';
			address.City_gne__c = 'TestCity';
			address.Address_gne__c = 'TestAddress';
			address.Postal_Code_gne__c = '12345';
			address.institution_gne__c = [SELECT id FROM CFAR_Institution_gne__c].get(0).id;
			insert address;

			CFAR_AddressBookNew_Controller cabnc3 = new CFAR_AddressBookNew_Controller();
			cabnc3.contact.Email_gne__c = 'aaa@bbb.com';
			cabnc3.contact.First_Name_gne__c = 'Test1';
			cabnc3.contact.Last_Name_gne__c = 'Contact1';
			cabnc3.contact.Primary_Role_Function_gne__c = 'ADMIN = Administrator';
			cabnc3.contact.Active_Date_gne__c = Date.today();
			cabnc3.contact.User_ref_gne__c = itAdm.Id;
			cabnc3.contactAddressUtil.selectedInstitutionId = institution.Id;
			cabnc3.contactAddressUtil.selectedAddressId = address.Id;
			System.assertEquals(null, cabnc3.saveContact(), 'Should not redirect user Contact already exist for user.');
			System.assertEquals(new ApexPages.message(ApexPages.severity.ERROR, 
				'There is already contact Test1 Contact1 created for chosen User in the system!'), ApexPages.getMessages().get(0),
				'Should throw exception if Contact already exist for user');
		}
		Test.stopTest();
	}

	 static testMethod void testSettingContactActiveInactive() {
	 	User itAdm = [SELECT Id FROM User WHERE alias = 'testITAd'];
	 	System.runAs(itAdm) {
	 		CFAR_TestUtils.createRolesToUsersMapping();
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
            
	 	}
	 	PageReference pRef = Page.CFAR_AddressBookNew;
	 	pRef.getParameters().put('isNew', 'true');
	 	Test.setCurrentPage(pRef);
	 	Test.startTest();
	 	System.runAs(itAdm) {
	 		CFAR_AddressBookNew_Controller cabnc = new CFAR_AddressBookNew_Controller();
	 		cabnc.contact.First_Name_gne__c = 'Test';
	 		cabnc.contact.Last_Name_gne__c = 'Cnt';
	 		cabnc.contact.Primary_Role_Function_gne__c = 'ADMIN = Administrator';
	 		cabnc.onPrimaryRoleChange();
	 		cabnc.contact.Active_Date_gne__c = Date.today();
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
            
        		List<CFAR_Contact_Address_gne__c> listOfaddresses = [SELECT id FROM CFAR_Contact_address_gne__c];
        		System.assertEquals(1, listOfAddresses.size());
            	CFAR_Institution_gne__c ins  = [SELECT Id FROM CFAR_Institution_gne__c];
            	cabnc.contactAddressUtil.selectedInstitutionId = ins.id;
            	CFAR_Contact_Address_gne__c adr = [SELECT Id FROM CFAR_Contact_Address_gne__c];
            	cabnc.contactAddressUtil.selectedAddressId = adr.id;
            	cabnc.contactAddressUtil.newOrEditedAddress.Contact_Address_ref_gne__c = adr.id;

			pRef = cabnc.saveContact();
	 		System.assertNotEquals(null, pRef);
	 		System.assertEquals(true, [select Active_gne__c from CFAR_Contact_gne__c where Id = :cabnc.contact.Id][0].Active_gne__c);
	 		Test.setCurrentPage(pRef);
	 		cabnc = new CFAR_AddressBookNew_Controller();
			pRef = cabnc.editContact();
	 		Test.setCurrentPage(pRef);
	 		cabnc = new CFAR_AddressBookNew_Controller();
	 		cabnc.contact.Inactive_Date_gne__c = Date.today().addDays(2);
	 		pRef = cabnc.saveContact();
	 		System.assertEquals(true, [select Active_gne__c from CFAR_Contact_gne__c where Id = :cabnc.contact.Id][0].Active_gne__c);
			Test.setCurrentPage(pRef);
	 		cabnc = new CFAR_AddressBookNew_Controller();
	 		pRef = cabnc.editContact();
	 		Test.setCurrentPage(pRef);
	 		cabnc = new CFAR_AddressBookNew_Controller();
	 		cabnc.contact.Active_Date_gne__c = Date.today().addDays(-2);
	 		cabnc.contact.Inactive_Date_gne__c = Date.today();
	 		pRef = cabnc.saveContact();
	 		System.assertEquals(false, [select Active_gne__c from CFAR_Contact_gne__c where Id = :cabnc.contact.Id][0].Active_gne__c);
	 		Test.setCurrentPage(pRef);
	 		cabnc = new CFAR_AddressBookNew_Controller();
	 		pRef = cabnc.editContact();
	 		Test.setCurrentPage(pRef);
	 		cabnc = new CFAR_AddressBookNew_Controller();
	 		cabnc.contact.Inactive_Date_gne__c = Date.today().addDays(-1);
	 		pRef = cabnc.saveContact();
			System.assertEquals(false, [select Active_gne__c from CFAR_Contact_gne__c where Id = :cabnc.contact.Id][0].Active_gne__c);
	 	}
	 	Test.stopTest();
	 }

	static testMethod void goToTrialReassign() {
		//GIVEN
		CFAR_Contact_gne__c testContact = new CFAR_Contact_gne__c(First_Name_gne__c = 'Test2', Last_Name_gne__c = 'Contact2', Primary_Role_Function_gne__c = 'Sub-I = Sub-investigator', Active_Date_gne__c = Date.today());
		insert testContact;
		CFAR_AddressBookNew_Controller ctrl = new CFAR_AddressBookNew_Controller();
		ctrl.selectedContact = testContact.Id;

		//WHEN
		PageReference pr = ctrl.goToTrialReassign();

		//THEN
		System.assertEquals('/apex/CFAR_TrialReassign?id=' + testContact.Id, pr.getUrl(),
			'Should redirect user to CFAR_TrialReassign page with Id of selected contact as param.');
	 }

	static testMethod void checkIfReferencedOrLastActive() {
		User itAdm = [SELECT Id FROM User WHERE alias = 'testITAd'];
		System.runAs(itAdm) {
			//GIVEN
			CFAR_Trial_gne__c trial = CFAR_DataFactory.createTrial(0);
			trial.CTMS_gne__c = '09876';
			trial.Other_Trial_gne_Id__c = '09983';
			trial.IIS_Portal_RO_Number_gne__c = 'RO-IIS-2017-12345';
			insert trial;
			CFAR_Contact_gne__c contact = CFAR_DataFactory.createContact('contact test one', CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_MANAGER);
			contact.Last_Name_gne__c = 'testlastname1234xx';
			insert contact;

			CFAR_Parent_Organization_gne__c parentOrg = CFAR_DataFactory.createParentOrganization();
			insert parentOrg;
			CFAR_Institution_gne__c institution = CFAR_DataFactory.createInstitution(parentOrg, 'testName123xx');
			insert institution;
			CFAR_Contact_Address_gne__c contactAddress  = CFAR_DataFactory.createContactAddress(institution);
			insert contactAddress;
			CFAR_Contact_Address_JO_gne__c caJO = CFAR_DataFactory.createContactAddressJO(contact, contactAddress);
			insert caJO;

			CFAR_Team_Member_gne__c tm = CFAR_DataFactory.createTeamMember(trial, 'testTM123xxx', caJO, CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR);
			insert tm;

			//WHEN
			String returnValue = CFAR_AddressBookNew_Controller.checkIfReferencedOrLastActive(caJO.Id);

			//THEN
			System.assertEquals('isReferencedInTrial', returnValue);

			//WHEN
			delete tm;
			returnValue = CFAR_AddressBookNew_Controller.checkIfReferencedOrLastActive(caJO.Id);

			//THEN
			System.assertEquals('isLastActiveAddress', returnValue);

			//WHEN
			caJO.Active_gne__c = false;
			update caJO;
			returnValue = CFAR_AddressBookNew_Controller.checkIfReferencedOrLastActive(caJO.Id);

			//THEN
			System.assertEquals('canDelete', returnValue);
		}
	}
}