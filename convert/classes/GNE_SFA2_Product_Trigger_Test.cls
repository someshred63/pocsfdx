/************************************************************
*  @author: Michal Hrycenko, Roche
*  Date: 2012-09-21
*  Description: This is a test class for GNE_SFA2_Product_Trigger trigger.
*  
*  Modification History
*  Date        	Name        		Description
*  2014-01-30	Piotr Przesmycki    Removed seeAllData annotation
*  2014-02-21   Piotr Przesmycki    Using GNE_SFA2_Trigger_Test_Util to prepare data
*************************************************************/
@isTest
private class GNE_SFA2_Product_Trigger_Test {

	
	public static testMethod void testTherapeuticAreaFieldUpdateWhenProductInsert() {
		GNE_SFA2_Util.switchAdminMode(false);
		insert new Product_vod__c(Product_Type_vod__c='testType', Detail_Product_Subtype_Code_gne__c = 'Therapeutic Area');
		List<Product_vod__c> getReferenceTAProduct = GNE_SFA2_Product_Test_Helper.referenceTAProduct();	
		List<Product_vod__c> referenceTAProducts = GNE_SFA2_Product_Test_Helper.insertTestProducts(null, new Map<String, Object>{'Name' => 'Test', 'Product_Type_vod__c' => GNE_SFA2_Product_Test_Helper.getProductType(), 'Therapeutic_Area_Reference__c' => getReferenceTAProduct[0].id});
			
		referenceTAProducts = [Select Id, Name, Therapeutic_Area_vod__c, Therapeutic_Area_Reference__c from Product_vod__c where Id IN :referenceTAProducts];
			
		for(Product_vod__c refTAProd : referenceTAProducts){
			System.assertEquals(getReferenceTAProduct[0].Name, refTAProd.Therapeutic_Area_vod__c);	
		}
    }
    
    public static testMethod void testTherapeuticAreaFieldUpdateWhenProductUpdate() {
		GNE_SFA2_Util.switchAdminMode(false);
		insert new Product_vod__c(Product_Type_vod__c='testType', Detail_Product_Subtype_Code_gne__c = 'Therapeutic Area');
		insert new Product_vod__c(Product_Type_vod__c='testType2', Detail_Product_Subtype_Code_gne__c = 'Therapeutic Area');
		List<Product_vod__c> getReferenceTAProduct = GNE_SFA2_Product_Test_Helper.referenceTAProduct();
		List<Product_vod__c> referenceTAProducts = GNE_SFA2_Product_Test_Helper.insertTestProducts(null, new Map<String, Object>{'Name' => 'Test', 'Product_Type_vod__c' => GNE_SFA2_Product_Test_Helper.getProductType(), 'Therapeutic_Area_Reference__c' => getReferenceTAProduct[0].id});
			
		referenceTAProducts = [Select Id, Name, Therapeutic_Area_vod__c, Therapeutic_Area_Reference__c from Product_vod__c where Id IN :referenceTAProducts];
		
		for(Integer i = 0; i < referenceTAProducts.size(); i++){
			referenceTAProducts[i].Therapeutic_Area_Reference__c = getReferenceTAProduct[1].Id;	
		}
		
		Test.startTest();
		try {
			update referenceTAProducts;
		} catch (DMLException ex) {
			for(Product_vod__c refTAProd : referenceTAProducts){
				System.assertEquals(getReferenceTAProduct[1].Name, refTAProd.Therapeutic_Area_vod__c);	
			}
		}
		Test.stopTest();	
    }
    
    public static testMethod void testPreventDeletionWhenInteractionIsExist() {
		GNE_SFA2_Util.switchAdminMode(true);
		insert new Product_vod__c(Product_Type_vod__c='testType');
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('test');
		insert acc;

    	Call2_vod__c call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
    	insert call;
		
		Product_vod__c product = new Product_vod__c(Name = 'Test', Product_Type_vod__c = GNE_SFA2_Product_Test_Helper.getProductType());
		insert product;
		
		Call2_Detail_vod__c callDetails = GNE_SFA2_Triggers_Test_Util.prepareCall2_Detail_vod(call.Id);
		callDetails.Product_vod__c = product.Id;
		insert callDetails;
		
		Call2_Discussion_vod__c callDiscussion = GNE_SFA2_Triggers_Test_Util.prepareCall2_Discussion_vod(call.Id);
		callDiscussion.Product_vod__c = product.Id;
		insert callDiscussion;
		
		Call2_Key_Message_vod__c callKeyMessage = GNE_SFA2_Triggers_Test_Util.prepareCall2_Key_Message_vod(call.Id);
		callKeyMessage.Product_vod__c = product.Id;
		insert callKeyMessage;
		
		Call2_Sample_vod__c callSample = GNE_SFA2_Triggers_Test_Util.prepareCall2_Sample_vod(call.Id, 1);
		callSample.Product_vod__c = product.Id;
		insert callSample;
	
		Test.startTest();
		try {
			delete product;
		} catch (DMLException ex) {
			System.assert(ex.getMessage().contains(System.Label.Cannot_Delete_Object_Call_References), ex.getMessage());
			System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
		}
		Test.stopTest();	
    }
    
    public static testMethod void testAdminModeValidationWhenProductDelete() {
		GNE_SFA2_Util.switchAdminMode(false);
		insert new Product_vod__c(Product_Type_vod__c='testType');
		Product_vod__c product = new Product_vod__c(Name = 'Test', Product_Type_vod__c = GNE_SFA2_Product_Test_Helper.getProductType());
		insert product;
	
		Test.startTest();
		try {
			delete product;
		} catch (DMLException ex) {
			System.assert(ex.getMessage().contains(System.Label.GNE_SFA2_Admin_Mode), ex.getMessage());
			System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
		}
		Test.stopTest();	
    }
}