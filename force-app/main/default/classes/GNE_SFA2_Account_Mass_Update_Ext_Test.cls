/************************************************************
*  @author: Piotr Przesmycki
*  Date: 2014-09-12
*  Description: This is test for GNE_SFA2_Account_Mass_Update_Ext class
*    
*  Modification History
*  Date        Name        Description
*************************************************************/
@isTest
private class GNE_SFA2_Account_Mass_Update_Ext_Test{
	
	public static testMethod void testRemoteActions(){
		GNE_SFA2_Account_Mass_Update_Ext ext = new GNE_SFA2_Account_Mass_Update_Ext(new GNE_SFA2_MyAccounts_Controller());
		ext = new GNE_SFA2_Account_Mass_Update_Ext(new ApexPages.StandardController(GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('HCO name')));

		List<GNE_SFA2_Account_Mass_Update_Ext.SelectOptionClass> availableValues = GNE_SFA2_Account_Mass_Update_Ext.getPicklistValues('Account', 'Distributor_Type_gne__c');
		system.assertEquals(13, availableValues.size());

		system.assertEquals('Boolean', GNE_SFA2_Account_Mass_Update_Ext.refreshFieldType('Account', 'X340B_Eligible_gne__c'));
		system.assertEquals('Date', GNE_SFA2_Account_Mass_Update_Ext.refreshFieldType('Account', 'LastActivityDate'));
		system.assertEquals('Picklist', GNE_SFA2_Account_Mass_Update_Ext.refreshFieldType('Account', 'Distributor_Type_gne__c'));
		system.assertEquals('Double', GNE_SFA2_Account_Mass_Update_Ext.refreshFieldType('Account', 'Targeting_Score_gne__c'));
		system.assertEquals('Other', GNE_SFA2_Account_Mass_Update_Ext.refreshFieldType('Account', 'Special_Instructions_gne__c'));

		Product_vod__c product = GNE_SFA2_Triggers_Test_Util.prepareProduct_vod();
		insert product;
		My_Setup_Products_vod__c myProducts = new My_Setup_Products_vod__c(Product_vod__c = product.Id);
		insert myProducts;
		List<GNE_SFA2_Account_Mass_Update_Ext.SelectOptionClass> availableProducts = GNE_SFA2_Account_Mass_Update_Ext.refreshProducts(UserInfo.getUserId());
		system.assertEquals(1, availableProducts.size());

		createConfiguration();
		List<GNE_SFA2_Account_Mass_Update_Ext.SelectOptionClass> fieldNames = GNE_SFA2_Account_Mass_Update_Ext.refreshFieldNames('TSF_vod__c');
		system.assertEquals(1, fieldNames.size());
		fieldNames = GNE_SFA2_Account_Mass_Update_Ext.refreshFieldNames('Account');
		system.assertEquals(1, fieldNames.size());
		fieldNames = GNE_SFA2_Account_Mass_Update_Ext.refreshFieldNames('Product_Metrics_vod__c');
		system.assertEquals(0, fieldNames.size());
	}

	private static void createConfiguration(){
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = false, SetupOwnerId = UserInfo.getUserId());
        insert new GNE_SFA2_My_Accounts_Setttings__c(Account_View_Columns_gne__c = 'X340B_Eligible_gne__c,LastActivityDate', Brand_Affiliation_View_Columns_gne__c = 'Name,CreatedDate');
	}
}