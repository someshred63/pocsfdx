/**
*  @author: Przemek Giszczak
*  Date: 2014-09-05
*  This is a test class for GNE_SFA2_ART_Site_Ext and GNE_SFA2_ART_Site_Edit_Create_Ext
*  
*  Modification History
*  Date        Name        Description
 */
@isTest
public with sharing class GNE_SFA2_ART_Site_Test {

	static testMethod void test_GNE_SFA2_ART_Site_Ext() {
		ART_Site_gne__c asg = new ART_Site_gne__c( Name = 'Test site local' );
		insert asg;
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController( asg );

		GNE_SFA2_ART_Site_Ext testCtrl = new GNE_SFA2_ART_Site_Ext( stdCtrl );
		system.assertEquals( asg, testCtrl.myObject );

		PageReference pr = testCtrl.editARTSite();
		system.assert( pr.getUrl().contains('GNE_SFA2_ART_Site_Edit_Create_Layout') );
		system.assertEquals( true, pr.getredirect() );
		system.assertEquals( asg.Id, pr.getParameters().get('id') );

		pr = testCtrl.addAttachment();
		system.assert( pr.getUrl().contains('GNE_SFA2_UploadAttachment') );
		system.assertEquals( true, pr.getredirect() );
		system.assertEquals( '/' + asg.Id, pr.getParameters().get('retURL') );

		pr = testCtrl.viewAttachment();
		system.assert( pr.getUrl().contains('GNE_SFA2_Attachment_layout') );
		system.assertEquals( true, pr.getredirect() );
		system.assertEquals( asg.Id, pr.getParameters().get('retURL') );

		pr = testCtrl.updateAttachment();
		system.assert( pr.getUrl().contains('GNE_SFA2_UploadAttachment') );
		system.assertEquals( true, pr.getredirect() );
		system.assertEquals( asg.Id, pr.getParameters().get('retURL') );

		pr = testCtrl.deleteARTSite();
		system.assert( pr.getUrl().contains('GNE_SFA2_MCCO_ART_Tab') );
		system.assertEquals( true, pr.getredirect() );
	}

	static testMethod void test_GNE_SFA2_ART_Site_Edit_Create_Ext() {
		ART_Site_gne__c asg = new ART_Site_gne__c( Name = 'Test site local' );
		insert asg;
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController( asg );

		GNE_SFA2_ART_Site_Edit_Create_Ext testCtrl = new GNE_SFA2_ART_Site_Edit_Create_Ext( stdCtrl );
		system.assertEquals( asg, testCtrl.myObject );
	}
}