/************************************************************
*  @author: Piotr Przesmycki
*  Date: 2014-07-29
*  This is a test class for GNE_SFA2_Account_Edit_Create_Ext
*    
*  Modification History
*  Date        Name        Description
*************************************************************/
@isTest
private class GNE_SFA2_Account_Edit_Create_Ext_Test {
	
	public static testMethod void testControllerMethods() {
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('Account Name');
		insert acc;
		Account testAcc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('Account Name');
		RecordType rt = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Account' limit 1];
		ApexPages.StandardController stdctrl = new ApexPages.StandardController(testAcc);
		GNE_SFA2_Account_Edit_Create_Ext testCtrl = new GNE_SFA2_Account_Edit_Create_Ext(stdctrl);
		system.assertEquals(null, testCtrl.myObject.get('recordTypeId'));
		system.assertEquals(null, testCtrl.myObject.get('parentId'));

		PageReference pr = Page.GNE_SFA2_Account_Layout;
		pr.getParameters().put('recordTypeName', rt.DeveloperName);
		pr.getParameters().put('sfacanadaparentId', acc.Id);
		Test.setCurrentPage(pr);
		testCtrl = new GNE_SFA2_Account_Edit_Create_Ext(stdctrl);
		system.assertEquals(rt.Id, testCtrl.myObject.get('recordTypeId'));
		system.assertEquals(acc.Id, testCtrl.myObject.get('parentId'));
		
        system.assertEquals(null, testCtrl.setPictureFile());
	}
	
	public static testMethod void testSave(){
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('Account Name');
		insert acc;
		ApexPages.StandardController stdctrl = new ApexPages.StandardController(acc);
		GNE_SFA2_Account_Edit_Create_Ext testCtrl = new GNE_SFA2_Account_Edit_Create_Ext(stdctrl);
		system.assertNotEquals(null, testCtrl.pictureFile);
		String name = 'PicName';
		Blob body = Blob.valueOf('PicBody');
		String cType = 'PicType';
		system.assertEquals(0, [SELECT Id FROM Attachment WHERE ParentId = :acc.Id].size());
		testCtrl.pictureFile.Name = name;
		testCtrl.pictureFile.Body = EncodingUtil.base64Encode(body);
		testCtrl.pictureFile.contentType = cType;
		testCtrl.saveAccount();
		system.assertEquals(1, [SELECT Id FROM Attachment WHERE ParentId = :acc.Id].size());
		testCtrl.pictureFile.Name = name;
		testCtrl.pictureFile.Body = EncodingUtil.base64Encode(body);
		testCtrl.pictureFile.contentType = cType;
		testCtrl.saveAccount();
		system.assertEquals(1, [SELECT Id FROM Attachment WHERE ParentId = :acc.Id].size());
	}
}