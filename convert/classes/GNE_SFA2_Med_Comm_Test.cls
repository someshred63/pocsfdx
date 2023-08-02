/**
*  @author: Przemek Giszczak
*  Date: 2014-08-25
*  This is a test class for GNE_SFA2_Med_Comm_Edit_Create and GNE_SFA2_Med_Comm_Controller
*  
*  Modification History
*  Date        Name        Description
 */
@isTest
public with sharing class GNE_SFA2_Med_Comm_Test {
    private static final Map<String, Id> ids2ProfilesMap = GNE_FRM_TestUtilities.getProfiles();
    
    
    @testSetup
    static void testData() {
        Map<String, Id> name2RtId = GNE_FRM_TestUtilities.getAccountRecordTypes();

        User user1 = GNE_FRM_TestUtilities.createUser('TESTUSERXXXX', ids2ProfilesMap.get('GNE-MedAffairs-MCL'), false);
        User user2 = GNE_FRM_TestUtilities.createUser('TESTUSERYYYY', ids2ProfilesMap.get('GNE-MedAffairs-MSL'), false);

        GNE_SFA2_Util.updateAdminSetings(true);
        
        insert new List<User> {user1,user2};
    }

	static testMethod void test_GNE_SFA2_Med_Comm_Edit_Create() {
		Medical_Communication_gne__c mc = new Medical_Communication_gne__c();
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController( mc );

		insert mc;
		GNE_SFA2_Med_Comm_Edit_Create_Ext testCtrl = new GNE_SFA2_Med_Comm_Edit_Create_Ext( stdCtrl );
		system.assertEquals( mc.Id, testCtrl.myObject.Id );
	}

	static testMethod void test_GNE_SFA2_Med_Comm_Controller() {
		Medical_Communication_gne__c mc = new Medical_Communication_gne__c();
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController( mc );

		GNE_SFA2_Med_Comm_Controller testCtrl = new GNE_SFA2_Med_Comm_Controller( stdCtrl );
		system.assertEquals( null, testCtrl.medCommuncation.Name );

		List<User> usr_list = [ SELECT Id, Profile_Name_gne__c FROM USER WHERE isActive = true AND Profile_Name_gne__c like '%canada%' LIMIT 1];
		if( usr_list.size() > 0 ) {
			system.runAs( usr_list[0] ) {
				testCtrl = new GNE_SFA2_Med_Comm_Controller( stdCtrl );
			}
			system.assert( testCtrl.sfaCanada );
		} else {
			system.assert( false, 'User with canada profile doesn`t exists!' );
		}

		usr_list = [ SELECT Id, Profile_Name_gne__c FROM USER WHERE isActive = true AND (Profile_Name_gne__c like '%GNE-MedAffairs-MCL%' or Profile_Name_gne__c like '%GNE-MedAffairs-MSL%' or Profile_Name_gne__c like '%GNE-MedAffairs-SP%') LIMIT 1];
		if( usr_list.size() > 0 ) {
			system.runAs( usr_list[0] ) {
				testCtrl = new GNE_SFA2_Med_Comm_Controller( stdCtrl );
			}
			system.assert( testCtrl.isMolecule );
		} else {
			system.assert( false, 'User with molecule profile doesn`t exists!' );
		}

		Account acc = new Account( Name = 'Test account' );
		insert acc;
		PageReference pr = Page.GNE_SFA2_User_Layout;
		pr.getParameters().put( 'accountId', acc.Id );
		Test.setCurrentPage( pr );
		testCtrl = new GNE_SFA2_Med_Comm_Controller( stdCtrl );
		system.assertEquals( 'Test account', testCtrl.accountName );

		system.assertEquals( false, testCtrl.getshowAddress() );

		pr = testCtrl.cancel();
		system.assertNotEquals( null, pr );
		system.assert( pr.getUrl().contains( '/' + acc.Id ) );
		system.assertEquals( true, pr.getredirect() );

		testCtrl.accountId = null;
		system.assertEquals( null, testCtrl.cancel() );
	}
	
	static testMethod void test_GNE_SFA2_Med_Comm_createMedComRequest() {
		Account acc = new Account( Name = 'Test account', Language_of_Preference_can_gne__c = 'French', Secondary_Email_gne__c = 'test@abc.com' );
		insert acc;
		Address_vod__c add = new Address_vod__c( Name = 'Test address', Account_vod__c = acc.Id, Phone_vod__c = '111', Phone_2_vod__c =  '222', Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999' );
		insert add;
		PageReference pr = Page.GNE_SFA2_User_Layout;
		pr.getParameters().put( 'accountId', acc.Id );
		Test.setCurrentPage( pr );
		
		Medical_Communication_gne__c mc = new Medical_Communication_gne__c();
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController( mc );

		GNE_SFA2_Med_Comm_Controller testCtrl = new GNE_SFA2_Med_Comm_Controller( stdCtrl );
		system.assertEquals( null, testCtrl.createMedComRequest() );

		testCtrl.accountId = acc.Id;
		testCtrl.accountName = acc.Name;
		system.assertEquals( null, testCtrl.createMedComRequest() );

		testCtrl.Description = 'Test description';
		testCtrl.medFollowUpMethod = null;
		system.assertEquals( null, testCtrl.createMedComRequest() );

		testCtrl.medAddress = add.Id;
		testCtrl.medFollowUpMethod = 'Mail';
		pr = testCtrl.createMedComRequest();
		system.assertEquals( true, pr.getredirect() );
		system.assert( pr.getUrl().contains( '/' + acc.Id ) );

		testCtrl.medFollowUpMethod = 'Email';
		system.assertEquals( null, testCtrl.createMedComRequest() );

		testCtrl.medFollowUpMethod = 'Phone';
		system.assertEquals( null, testCtrl.createMedComRequest() );

		testCtrl.medFollowUpMethod = 'Fax';
		system.assertEquals( null, testCtrl.createMedComRequest() );

		Product_vod__c prod = new Product_vod__c( Name = 'Non-Product/Non-Molecule', Detail_Product_Subtype_Code_gne__c = 'Molecule' );
		insert prod;
		testCtrl.medFollowUpMethod = 'Mail';
		testCtrl.isMolecule = true;
		testCtrl.medMolecule = 'N/A';
		system.assertNotEquals( null,  testCtrl.createMedComRequest() );
		//
	}
	
	static testMethod void test_GNE_SFA2_Med_Comm_createMedComRequest_canada() {
		Medical_Communication_gne__c mc = new Medical_Communication_gne__c();
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController( mc );

		List<User> usr_list = [ SELECT Id, Profile_Name_gne__c FROM USER WHERE isActive = true AND Profile_Name_gne__c like '%Rcanada%' LIMIT 1];
		if( usr_list.size() > 0 ) {
			system.runAs( usr_list[0] ) {
				Account acc = new Account( Name = 'Test account', Language_of_Preference_can_gne__c = 'English', Secondary_Email_gne__c = 'test@abc.com' );
				insert acc;
				Address_vod__c add = new Address_vod__c( Name = 'Test address', Account_vod__c = acc.Id, Phone_vod__c = '111', Phone_2_vod__c =  '222', Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999' );
				insert add;
				PageReference pr = Page.GNE_SFA2_User_Layout;
				pr.getParameters().put( 'accountId', acc.Id );
				Test.setCurrentPage( pr );

				GNE_SFA2_Med_Comm_Controller testCtrl = new GNE_SFA2_Med_Comm_Controller( stdCtrl );
				testCtrl.Description = 'Test description';
				testCtrl.medFollowUpMethod = 'Mail';
				testCtrl.medAddress = add.Id;

				testCtrl.isMolecule = true;
				testCtrl.medMolecule = '';
				testCtrl.medCCRep = 'Y';
				system.assertEquals( null,  testCtrl.createMedComRequest() );

				acc.Language_of_Preference_can_gne__c = 'French';
				update acc;
				Product_vod__c prod = new Product_vod__c( Name = 'Non-Product/Non-Molecule', Detail_Product_Subtype_Code_gne__c = 'Molecule' );
				insert prod;
				testCtrl = new GNE_SFA2_Med_Comm_Controller( stdCtrl );
				testCtrl.Description = 'Test description';
				testCtrl.medFollowUpMethod = 'Mail';
				testCtrl.medAddress = add.Id;

				testCtrl.isMolecule = true;
				testCtrl.medMolecule = 'N/A';
				system.assertNotEquals( null,  testCtrl.createMedComRequest() );
			}
		} else {
			system.assert( false, 'User with canada profile doesn`t exists!' );
		}
	}
	
	static testMethod void test_GNE_SFA2_Med_Comm_getMethods() {
		Account acc = new Account( Name = 'Test account', Language_of_Preference_can_gne__c = 'English;French', Secondary_Email_gne__c = 'test@abc.com' );
		insert acc;
		Address_vod__c add = new Address_vod__c( Name = 'Test address', Account_vod__c = acc.Id, Phone_vod__c = '111', Phone_2_vod__c =  '222', Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999' );
		insert add;
		PageReference pr = Page.GNE_SFA2_User_Layout;
		pr.getParameters().put( 'accountId', acc.Id );
		Test.setCurrentPage( pr );

		Medical_Communication_gne__c mc = new Medical_Communication_gne__c();
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController( mc );
		GNE_SFA2_Med_Comm_Controller testCtrl = null;

		List<User> usr_list = [ SELECT Id, Profile_Name_gne__c FROM USER WHERE isActive = true AND Profile_Name_gne__c like '%Rcanada%' LIMIT 1];
		if( usr_list.size() > 0 ) {
			system.runAs( usr_list[0] ) {
				testCtrl = new GNE_SFA2_Med_Comm_Controller( stdCtrl );

				List<SelectOption> opt_list = testCtrl.getFollowUpMethods();
				system.assertEquals( 'Mail', opt_list[0].getLabel() );

				opt_list = testCtrl.getPriorities();
				system.assertEquals( 'Same Day', opt_list[0].getLabel() );

				system.assert( testCtrl.sfaCanada );
			}
		} else {
			system.assert( false, 'User with canada profile doesn`t exists!' );
		}

		// without canada User
		testCtrl = new GNE_SFA2_Med_Comm_Controller( stdCtrl );

		testCtrl.isMolecule = true;
		List<SelectOption> opt_list = testCtrl.getFollowUpMethods();
		system.assertEquals( 'Normal Mail', opt_list[0].getLabel() );

		opt_list = testCtrl.getPriorities();
		system.assertEquals( 'Normal', opt_list[0].getLabel() );

		opt_list = testCtrl.getLanguages();
		system.assertEquals( 'English', opt_list[0].getLabel() );

		opt_list = testCtrl.getPhones();
		system.assertEquals( '111', opt_list[0].getLabel() );

		opt_list = testCtrl.getFaxes();
		system.assertEquals( '(999) 999-9999', opt_list[0].getLabel() );

		opt_list = testCtrl.getAddresses();
		system.assertEquals( add.Id, opt_list[0].getValue() );

		opt_list = testCtrl.getCCReps();
		system.assertEquals( 'N', opt_list[0].getLabel() );

		Contact con = new Contact( Address_gne__c = add.Id, Email = 'test_contact@abc.com', LastName = 'Test name', AccountId = acc.Id );
		insert con;
		testCtrl.accountId = acc.Id;
		opt_list = testCtrl.getEmails();
		system.assertEquals( 'test@abc.com', opt_list[0].getLabel() );
		system.assertEquals( 'test_contact@abc.com', opt_list[1].getLabel() );

		Product_vod__c prod = new Product_vod__c( Name = 'Test product', Detail_Product_Subtype_Code_gne__c = 'Molecule' );
		insert prod;
		opt_list = testCtrl.getMolecules();
		system.assertEquals( 'N/A', opt_list[0].getLabel() );
		system.assertEquals( prod.Id, opt_list[1].getValue() );

		prod = new Product_vod__c( Name = 'Test product 2', Product_Type_vod__c = 'Detail' );
		insert prod;
		opt_list = testCtrl.getProducts();
		system.assertEquals( prod.Id, opt_list[0].getValue() );
	}
}