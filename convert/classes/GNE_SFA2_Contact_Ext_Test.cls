/************************************************************
*  @author: Piotr Przesmycki
*  Date: 2014-03-26
*  Description: This is a test class for GNE_SFA2_Contact_Ext class
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
@isTest
private class GNE_SFA2_Contact_Ext_Test {
	
	public static testMethod void testEdit(){
		Contact c = GNE_SFA2_Triggers_Test_Util.prepareContact('testLastName');
		insert c;
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController(c);
		GNE_SFA2_Contact_Ext controller = new GNE_SFA2_Contact_Ext(stdCtrl);
		system.assertNotEquals(null, controller.myObject);
		system.assertEquals(c.Id, controller.myObject.Id);

		PageReference pr = controller.edit();
		system.assertEquals(c.Id, pr.getParameters().get('id'));
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('GNE_SFA2_Contact_Edit_Create_Layout'), 'Wrong URL');
	}

	public static testMethod void testViewAndAddAttachmentClick(){
		Contact c = GNE_SFA2_Triggers_Test_Util.prepareContact('testLastName');
		insert c;
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController(c);
		GNE_SFA2_Contact_Ext controller = new GNE_SFA2_Contact_Ext(stdCtrl);
		system.assertNotEquals(null, controller.myObject);
		system.assertEquals(c.Id, controller.myObject.Id);

		PageReference pr = controller.addAttachmentsClick();
		system.assertEquals(c.Id, pr.getParameters().get('Id'));
		system.assertEquals('/'+c.Id, pr.getParameters().get('retUrl'));
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('GNE_SFA2_UploadAttachment'), 'Wrong URL');

		pr = controller.viewAttachmentsClick();
		system.assertEquals(c.Id, pr.getParameters().get('Id'));
		system.assertEquals('/'+c.Id, pr.getParameters().get('retUrl'));
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('GNE_SFA2_Attachment_layout'), 'Wrong URL');
	}
	
	public static testMethod void testRecordACall(){
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('testName');
		insert acc;
		Contact c = GNE_SFA2_Triggers_Test_Util.prepareContact('testLastName');
		c.AccountId = acc.Id;
		insert c;
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController(c);
		GNE_SFA2_Contact_Ext controller = new GNE_SFA2_Contact_Ext(stdCtrl);
		system.assertNotEquals(null, controller.myObject);
		system.assertEquals(c.Id, controller.myObject.Id);

		PageReference pr = controller.recordACallClick();
		system.assertEquals(acc.Id, pr.getParameters().get('accountId'));
		system.assertEquals(c.Id, pr.getParameters().get('contactId'));
		system.assertEquals('/'+c.Id, pr.getParameters().get('retURL'));
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('GNE_SFA2_Interaction_Edit_Create'), 'Wrong URL');
	}

	public static testMethod void testCallMethdod(){
		Contact c = GNE_SFA2_Triggers_Test_Util.prepareContact('testLastName');
		insert c;
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController(c);
		GNE_SFA2_Contact_Ext controller = new GNE_SFA2_Contact_Ext(stdCtrl);
		system.assertNotEquals(null, controller.myObject);
		system.assertEquals(c.Id, controller.myObject.Id);

		system.assertEquals(null, controller.callMethod('wrongMethodName'));

		PageReference pr = controller.callMethod('addAffiliationClick');
		system.assertEquals(c.Id, pr.getParameters().get('CF00N70000001tDNv_lkid'));
		system.assertEquals('1', pr.getParameters().get('save_new'));
		system.assertEquals('1', pr.getParameters().get('sfdc.override'));
		system.assertEquals('/'+c.Id, pr.getParameters().get('retUrl'));
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('GNE_SFA2_Affiliation_Edit_Create_Layout'), 'Wrong URL');

		pr = controller.callMethod('newSurveyClick');
		system.assertEquals(c.Id, pr.getParameters().get('objectId'));
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('GNE_SFA2_Create_Survey_Layout'), 'Wrong URL');

	}
}