/**
*  @author: Przemek Giszczak
*  Date: 2014-09-01
*  This is a test class for GNE_SFA2_ART_Issue_Ext and GNE_SFA2_ART_Issue_Edit_Create_Ext
*  
*  Modification History
*  Date        Name        Description
 */
@isTest
public with sharing class GNE_SFA2_ART_Issue_Test {

	static testMethod void test_GNE_SFA2_ART_Issue_Ext() {
		ART_Site_gne__c asg = new ART_Site_gne__c( Name = 'Test site local' );
		insert asg;
		ART_Issue_gne__c aig = new ART_Issue_gne__c( Name = 'Test issue', Type_gne__c = 'Issue', Issue_Status_gne__c = 'Closed', Resolution_Type_gne__c = 'Test resolution tytpe', ART_Site_Local_gne__c = asg.Id );
		insert aig;
		ART_Team_gne__c atg = new ART_Team_gne__c( ART_Site_gne__c = asg.Id , Team_Member_gne__c = Userinfo.getUserId() );
		insert atg;
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController( aig );

		GNE_SFA2_ART_Issue_Ext testCtrl = new GNE_SFA2_ART_Issue_Ext( stdCtrl );

		system.assertEquals( aig, testCtrl.myObject );
		system.assertEquals( false, testCtrl.visualforceIncludesMap.get('GNE_SFA2_Record_History_Page') );

		// edit()
		PageReference pr = testCtrl.edit();
		system.assertEquals( true, pr.getredirect() );
		system.assert( pr.getUrl().contains('GNE_SFA2_ART_Issue_Edit_Create_Layout') );
		system.assertEquals( aig.Id, pr.getParameters().get('id') );

		// cloneARTIssue()
		pr = testCtrl.cloneARTIssue();
		system.assertEquals( true, pr.getredirect() );
		system.assert( pr.getUrl().contains('GNE_SFA2_ART_Issue_Edit_Create_Layout') );
		system.assertEquals( aig.Id, pr.getParameters().get('id') );
		system.assertEquals( 'true', pr.getParameters().get('isClone') );

		// deleteARTIssue()
		pr = testCtrl.deleteARTIssue();
		system.assertEquals( true, pr.getredirect() );
		system.assert( pr.getUrl().contains('GNE_SFA2_My_ART_Issues') );

		// addAttachmentsClick()
		pr = testCtrl.addAttachmentsClick();
		system.assertEquals( true, pr.getredirect() );
		system.assert( pr.getUrl().contains('GNE_SFA2_UploadAttachment') );
		system.assertEquals( aig.Id, pr.getParameters().get('id') );
		system.assertEquals( '/'+aig.Id, pr.getParameters().get('retURL') );

		// viewAttachment()
		pr = testCtrl.viewAttachment();
		system.assertEquals( true, pr.getredirect() );
		system.assert( pr.getUrl().contains('GNE_SFA2_Attachment_layout') );
		system.assertEquals( aig.Id, pr.getParameters().get('retURL') );

		// createNote()
		pr = testCtrl.createNote();
		system.assertEquals( true, pr.getredirect() );
		system.assert( pr.getUrl().contains('GNE_SFA2_Test') );
		system.assertEquals( aig.Id, pr.getParameters().get('parentId') );
		system.assertEquals( aig.Id, pr.getParameters().get('retURL') );

		// updateAttachment()
		pr = testCtrl.updateAttachment();
		system.assert( pr.getUrl().contains('gne_sfa2_exception_layout') );

		// getcancreate()
		GNE_SFA2_User_App_Context_gne__c u = new GNE_SFA2_User_App_Context_gne__c();
		u.Role_gne__c = 'manager';
		insert u;
		system.assertEquals( true, testCtrl.getcancreate() );

		u.Role_gne__c = 'mcl-manager';
		update u;
		system.assertEquals( false, testCtrl.getcancreate() );

		stdCtrl = new ApexPages.StandardController( asg );
		testCtrl = new GNE_SFA2_ART_Issue_Ext( stdCtrl );
		system.assertEquals( true, testCtrl.getcancreate() );
	}

	static testMethod void test_GNE_SFA2_ART_Issue_Edit_Create_Ext() {
		ART_Site_gne__c asg = new ART_Site_gne__c( Name = 'Test site local' );
		insert asg;
		ART_Issue_gne__c aig = new ART_Issue_gne__c( Name = 'Test issue', Type_gne__c = 'Issue', Issue_Status_gne__c = 'Closed', Resolution_Type_gne__c = 'Test resolution tytpe', ART_Site_Local_gne__c = asg.Id );
		//insert aig;
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController( aig );

		PageReference pr = Page.GNE_SFA2_ART_Issue_Layout;
		pr.getParameters().put( 'objectId', asg.Id );
		Test.setCurrentPage( pr );
        Test.startTest();
            GNE_SFA2_ART_Issue_Edit_Create_Ext testCtrl = new GNE_SFA2_ART_Issue_Edit_Create_Ext( stdCtrl );
    
            ART_Issue_gne__c x = (ART_Issue_gne__c) testCtrl.myObject;
            system.assertEquals( asg.Id, x.get('ART_Site_Local_gne__c') );
            system.assertEquals( aig.Id, testCtrl.myObject.Id );
            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
            User adminUser = new User(Alias = 'TesAdmin', Email='standardAdminuser@roche.com', 
                EmailEncodingKey='UTF-8', LastName='TestingAdmin', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p.Id, 
                TimeZoneSidKey='America/Los_Angeles', UserName='TestingAdmin@roche.com');
            System.runAs(adminUser){
    
                insert aig;
                
                testCtrl = new GNE_SFA2_ART_Issue_Edit_Create_Ext( stdCtrl );
        
                system.assertEquals( aig.Id, testCtrl.myObject.Id );
        
                // null pointer exc catch by try catch block in init method, no data in UserRecordAccess
                pr = testCtrl.init();                               
        	}
        Test.stopTest(); 
		system.assert( pr.getUrl().contains( asg.Id ) );
	}
}