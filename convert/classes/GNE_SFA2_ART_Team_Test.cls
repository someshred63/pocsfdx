/**
*  @author: Przemek Giszczak
*  Date: 2014-09-08
*  This is a test class for GNE_SFA2_ART_Team_Ext and GNE_SFA2_ART_Team_Edit_Create_Ext
*  
*  Modification History
*  Date        Name        Description
 */
@isTest
public with sharing class GNE_SFA2_ART_Team_Test {

	static testMethod void test_GNE_SFA2_ART_Team_Edit_Create_Ext() {
		ART_Site_gne__c asg = new ART_Site_gne__c( Name = 'Test site local' );
		insert asg;
		ART_Team_gne__c atg = new ART_Team_gne__c( ART_Site_gne__c = asg.Id );
		//insert atg;
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController( atg );

		PageReference pr = Page.GNE_SFA2_ART_Team_Layout;
		pr.getParameters().put( 'objectId', asg.Id );
		Test.setCurrentPage( pr );
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User adminUser = new User(Alias = 'TesAdmin', Email='standardAdminuser@roche.com', 
                                  EmailEncodingKey='UTF-8', LastName='TestingAdmin', LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId = p.Id, 
                                  TimeZoneSidKey='America/Los_Angeles', UserName='TestingAdmin@roche.com');
        
        Test.startTest();
        	System.runAs(adminUser){

                GNE_SFA2_ART_Team_Edit_Create_Ext testCtrl = new GNE_SFA2_ART_Team_Edit_Create_Ext( stdCtrl );
        
                ART_Team_gne__c atg_test = (ART_Team_gne__c) testCtrl.myObject;
                system.assertEquals( asg.Id, atg_test.get('ART_Site_gne__c') );
                system.assertEquals( atg, testCtrl.myObject );
        
                testCtrl.availabilityMode = 'New';
                pr = testCtrl.init();
                system.assert( pr.getUrl().contains( 'gne_sfa2_access_denied' ),  pr.getUrl() );
        
                testCtrl.availabilityMode = '';
                pr = testCtrl.init();
            }
        Test.stopTest();
		system.assert( pr.getUrl().contains( asg.Id ) );
		system.assert( pr.getUrl().contains( 'GNE_SFA2_Exception_Layout' ) );
	}

	static testMethod void test_GNE_SFA2_ART_Team_Ext() {
		ART_Site_gne__c asg = new ART_Site_gne__c( Name = 'Test site local' );
		insert asg;
		ART_Team_gne__c atg = new ART_Team_gne__c( ART_Site_gne__c = asg.Id );
		insert atg;
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController( atg );
		GNE_SFA2_ART_Team_Ext testCtrl = new GNE_SFA2_ART_Team_Ext( stdCtrl );

		system.assertEquals( atg.Id, testCtrl.myObject.Id );

		PageReference pr = testCtrl.editARTIssue();
		system.assertEquals( true, pr.getredirect() );
		system.assert( pr.getUrl().contains('GNE_SFA2_ART_Team_Edit_Create_Layout') );
		system.assertEquals( atg.Id, pr.getParameters().get('id') );

		pr = testCtrl.deleteARTIssue();
		system.assertEquals( true, pr.getredirect() );
		system.assert( pr.getUrl().contains('GNE_SFA2_MCCO_ART_Tab') );
	}
}