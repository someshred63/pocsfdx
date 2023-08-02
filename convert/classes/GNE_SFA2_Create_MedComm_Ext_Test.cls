/**
*  @author: Przemek Giszczak
*  Date: 2014-08-28
*  This is a test class for GNE_SFA2_Create_MedComm_Ext
*  
*  Modification History
*  Date        Name        Description
 */
@isTest
public with sharing class GNE_SFA2_Create_MedComm_Ext_Test {

	static testMethod void test_init() {
		Medical_Communication_gne__c mc = new Medical_Communication_gne__c();
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController( mc );

		GNE_SFA2_Create_MedComm_Ext testCtrl = new GNE_SFA2_Create_MedComm_Ext( stdCtrl );

		// try catch account fail
		PageReference pr = testCtrl.init();
		system.assert( pr.getUrl().contains('GNE_SFA2_Exception_Layout') );
		system.assertEquals( true, pr.getredirect() );

		Account acc = new Account( Name = 'Test account' );
		insert acc;
		pr = Page.GNE_SFA2_Med_Comm_Layout;
		pr.getParameters().put( 'AcctId', acc.Id );
		Test.setCurrentPage( pr );
		system.assertEquals( null, testCtrl.init() );

		// cancel()
		pr = testCtrl.cancel();
		system.assertEquals( true, pr.getredirect() );
		//system.assertEquals( '1', pr.getParameters().get('id') );
		system.debug( 'pr: ' + pr );
	}

	static testMethod void test_getMethods() {
		Medical_Communication_gne__c mc = new Medical_Communication_gne__c();
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController( mc );

		GNE_SFA2_Create_MedComm_Ext testCtrl = new GNE_SFA2_Create_MedComm_Ext( stdCtrl );

		Account acc = new Account( Name = 'Test account', Secondary_Email_gne__c = 'test_secondary@abc.com' );
		insert acc;
		Address_vod__c add = new Address_vod__c( Name = 'Test address', Account_vod__c = acc.Id, Phone_vod__c = '111', Phone_2_vod__c =  '222', Fax_vod__c = '(999) 999-9998', Fax_2_vod__c = '(999) 999-9999' );
		insert add;
		Product_vod__c prod = new Product_vod__c( Name = 'Test product', Product_Type_vod__c = 'Detail' );
		insert prod;
		Product_vod__c molecule = new Product_vod__c( Name = 'Test molecule', Detail_Product_Subtype_Code_gne__c = 'Molecule' );
		insert molecule;

		PageReference pr = Page.GNE_SFA2_Med_Comm_Layout;
		pr.getParameters().put( 'AcctId', acc.Id );
		Test.setCurrentPage( pr );
 
		testCtrl.init();

		// getAccountInfo()
		system.assertEquals( acc.Id, testCtrl.getAccountInfo().Id );

		// getUserHasCanadianProfile() - need test for canada
		system.assertEquals( false, testCtrl.getUserHasCanadianProfile() );

		// getUserHasMedAffairProfile()
		//system.assertEquals( false, testCtrl.getUserHasMedAffairProfile() );

		List<SelectOption> opt_list = new List<SelectOption>();

		// getProductList()
		opt_list = testCtrl.getProductList();
		system.assertEquals( 1, opt_list.size() );
		system.assertEquals( 'Test product', opt_list[0].getLabel() );

		// getMoleculeList()
		opt_list = testCtrl.getMoleculeList();
		system.assertEquals( 1, opt_list.size() );
		system.assertEquals( 'Test molecule', opt_list[0].getLabel() );

		// getAddressesList()
		opt_list = testCtrl.getAddressesList();
		system.assertEquals( 1, opt_list.size() );
		system.assertEquals( true, opt_list[0].getLabel().contains('Test address') );

		// getEmailsList()
		opt_list = testCtrl.getEmailsList();
		system.assertEquals( 1, opt_list.size() );
		system.assertEquals( 'test_secondary@abc.com', opt_list[0].getLabel() );

		// getPhonesList()
		opt_list = testCtrl.getPhonesList();
		system.assertEquals( 2, opt_list.size() );
		system.assertEquals( '111', opt_list[0].getLabel() );

		// getFaxesList()
		opt_list = testCtrl.getFaxesList();
		system.assertEquals( 2, opt_list.size() );
		system.assertEquals( '(999) 999-9998', opt_list[0].getLabel() );

		// getPreferenceLangList()
		opt_list = testCtrl.getPreferenceLangList();
		system.assertEquals( true, opt_list.size() > 0 );

		// getActiveMenuItem()
		system.assertEquals( '', testCtrl.getActiveMenuItem() );
	}

	static testMethod void test_method_availableType() {
		Medical_Communication_gne__c mc = new Medical_Communication_gne__c();
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController( mc );

		GNE_SFA2_Create_MedComm_Ext testCtrl = new GNE_SFA2_Create_MedComm_Ext( stdCtrl );

		Account acc = new Account( Name = 'Test account' );
		insert acc;

		PageReference pr = Page.GNE_SFA2_Med_Comm_Layout;
		pr.getParameters().put( 'AcctId', acc.Id );
		Test.setCurrentPage( pr );

		testCtrl.init();

		testCtrl.followName = 'Normal Mail';
		system.assertEquals( null, testCtrl.availableType() );
		system.assertEquals( 'addAddress', testCtrl.sectionVisible );
		system.assertEquals( true, testCtrl.sectionItemVisible );

		testCtrl.followName = 'Email';
		system.assertEquals( null, testCtrl.availableType() );
		system.assertEquals( 'addEmail', testCtrl.sectionVisible );
		system.assertEquals( true, testCtrl.sectionItemVisible );

		testCtrl.followName = 'Email';
		system.assertEquals( null, testCtrl.availableType() );
		system.assertEquals( 'addEmail', testCtrl.sectionVisible );
		system.assertEquals( true, testCtrl.sectionItemVisible );

		testCtrl.followName = 'Phone';
		system.assertEquals( null, testCtrl.availableType() );
		system.assertEquals( 'addPhone', testCtrl.sectionVisible );
		system.assertEquals( true, testCtrl.sectionItemVisible );

		testCtrl.followName = 'Fax';
		system.assertEquals( null, testCtrl.availableType() );
		system.assertEquals( 'addFax', testCtrl.sectionVisible );
		system.assertEquals( true, testCtrl.sectionItemVisible );

		testCtrl.followName = 'Memo';
		system.assertEquals( null, testCtrl.availableType() );
		system.assertEquals( '', testCtrl.sectionVisible );
		system.assertEquals( false, testCtrl.sectionItemVisible );
	}

	static testMethod void test_method_create() {
		Medical_Communication_gne__c mc = new Medical_Communication_gne__c();
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController( mc );

		GNE_SFA2_Create_MedComm_Ext testCtrl = new GNE_SFA2_Create_MedComm_Ext( stdCtrl );

		Account acc = new Account( Name = 'Test account', Secondary_Email_gne__c = 'test_secondary@abc.com' );
		insert acc;
		Address_vod__c add = new Address_vod__c( Name = 'Test address', Account_vod__c = acc.Id, Phone_vod__c = '111', Phone_2_vod__c =  '222', Fax_vod__c = '(999) 999-9998', Fax_2_vod__c = '(999) 999-9999' );
		insert add;
		Product_vod__c prod = new Product_vod__c( Name = 'Test product', Product_Type_vod__c = 'Detail' );
		insert prod;
        
		PageReference pr = Page.GNE_SFA2_Med_Comm_Layout;
		pr.getParameters().put( 'AcctId', acc.Id );
		Test.setCurrentPage( pr );

		testCtrl.followName = 'Email';
		system.assertEquals( null, testCtrl.create() );

		testCtrl.followName = 'Phone';
		system.assertEquals( null, testCtrl.create() );

		testCtrl.followName = 'Fax';
		system.assertEquals( null, testCtrl.create() );

		testCtrl.followName = '';
		system.assertEquals( null, testCtrl.create() );

		// saveMedCommRequest()
		testCtrl.init();
		testCtrl.medCommQuestion = 'Test question';
		testCtrl.product = 'Test product';
		testCtrl.address = add.Id;

		testCtrl.followName = 'Normal Mail';
		pr = testCtrl.create();
		system.assertNotEquals( null, pr );

		testCtrl.followName = 'Phone';
		testCtrl.phone = '111';
		pr = testCtrl.create();
		system.assertNotEquals( null, pr );

		testCtrl.followName = 'Fax';
		testCtrl.fax = '(999) 999-9998';
		pr = testCtrl.create();
		system.assertNotEquals( null, pr );

		testCtrl.followName = 'Memo';
		pr = testCtrl.create();
		system.assertNotEquals( null, pr );
	}

	static testMethod void test_methods_forCanadaProfile() {
		Medical_Communication_gne__c mc = new Medical_Communication_gne__c();
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController( mc );
		Product_vod__c prod;
		List<User> usr_list = [ SELECT Id, Profile_Name_gne__c, Name FROM USER WHERE isActive = true AND Profile_Name_gne__c like '%canada%' LIMIT 1];
       	
        Group canadaQueue = [SELECT Id FROM Group WHERE Name = 'GNE-SFA-CANADA-Queue' AND Type = 'Queue' LIMIT 1];
        prod = new Product_vod__c( Name = 'Test product', Product_Type_vod__c = 'Detail', OwnerId = canadaQueue.Id);
		insert prod;
    
		if( usr_list.size() > 0 ) {
			String profile = usr_list[0].Profile_Name_gne__c;
			GNE_SFA2_Canadian_Users__c new_Canada_User = new GNE_SFA2_Canadian_Users__c( Name = profile, GNE_SFA2_Profile_Name__c = profile );
			insert new_Canada_User;
          
			system.runAs( usr_list[0] ) {
				GNE_SFA2_Create_MedComm_Ext testCtrl = new GNE_SFA2_Create_MedComm_Ext( stdCtrl );

				Account acc = new Account( Name = 'Test account', Secondary_Email_gne__c = 'test_secondary@abc.com' );
				insert acc;
				Address_vod__c add = new Address_vod__c( Name = 'Test address', Account_vod__c = acc.Id, Phone_vod__c = '111', Phone_2_vod__c =  '222', Fax_vod__c = '(999) 999-9998', Fax_2_vod__c = '(999) 999-9999', Postal_Code_can_gne__c = 'A0A 1B1' );
				insert add;

				PageReference pr = Page.GNE_SFA2_Med_Comm_Layout;
				pr.getParameters().put( 'AcctId', acc.Id );
				Test.setCurrentPage( pr );

				// init buildFollowUpMethodList()
				system.assertEquals( null, testCtrl.init() );

				List<SelectOption> opt_list = new List<SelectOption>();

				// create()
				testCtrl.init();
				testCtrl.medCommQuestion = 'Test question';
				testCtrl.product = 'Test product';
				testCtrl.address = add.Id;
		
				testCtrl.followName = 'Normal Mail';
				pr = testCtrl.create();
				system.assertNotEquals( null, pr );

				testCtrl.followName = 'Phone';
				testCtrl.phone = '111';
				pr = testCtrl.create();
				system.assertNotEquals( null, pr );

				testCtrl.followName = 'Fax';
				testCtrl.fax = '(999) 999-9998';
				pr = testCtrl.create();
				system.assertNotEquals( null, pr );

				testCtrl.followName = 'Memo';
				testCtrl.email = null;
				pr = testCtrl.create();
				system.assertNotEquals( null, pr );
			}            
		} else {
			system.assert( false, 'User with canada profile doesn`t exists!' );
		}
	}
}