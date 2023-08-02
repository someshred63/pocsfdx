@isTest
public with sharing class GNE_SFA2_PFG_IA_Controller_Test {
	public static TestMethod void testInitControllerDtpHO() {
		intInitController('HO1', GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP);
	}
	/*
	public static TestMethod void testInitControllerDtpRM() {
		intInitController('RM1', GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP);
	}
	
	public static TestMethod void testInitControllerDtpDM() {
		intInitController('DM1', GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP);
	}
	
	public static TestMethod void testInitControllerDtpCS() {
		intInitController('CS1', GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP);
	}
	*/
	public static TestMethod void testInitControllerHcHO() {
		intInitController('HO1', GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC);
	}
	/*
	public static TestMethod void testInitControllerHcDM() {
		intInitController('DM1', GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC);
	}
	
	public static TestMethod void testInitControllerHcCS() {
		intInitController('CS1', GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC);
	}
	*/
	private static void intInitController(String userName, String pfgType) {
		User u = prepareEnv(userName);
		
		System.runAs(u) {
			Test.startTest();
			GNE_SFA2_PFG_IA_Controller.ControllerData ctrlData = GNE_SFA2_PFG_IA_Controller.getInitData(null, null, null, false, pfgType);
			Test.stopTest();
			
			if(userName.startsWith('HO')) {
				System.assertEquals(GNE_SFA2_PFG_Util.getBrandNames().size(), ctrlData.availableBrands.size()-1, 'Wrong Number of available Brands');
				System.assertEquals(null, ctrlData.currentBrand, 'Brand shouldn\'t be set');
			} else {
				//System.assertEquals(1, ctrlData.availableBrands.size()-1, 'Wrong Number of available Brands');
				System.assertNotEquals(null, ctrlData.currentBrand, 'Brand not set');
				System.assertEquals(2, ctrlData.availableProducts.size()-1, 'Wrong Number of available Products');
			}
		}
	}
	
	public static TestMethod void testBrandChangedDtpHO() {
		intBrandChanged('HO1', GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP, System.today().year(), 'Nutropin');
	}
	
	public static TestMethod void testBrandChangedHcHO() {
		intBrandChanged('HO1', GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC, System.today().year(), 'Actemra');
	}
	
	private static void intBrandChanged(String userName, String pfgType, Integer year, String brandName) {
		User u = prepareEnv(userName);
		
		System.runAs(u) {
			Test.startTest();
			GNE_SFA2_PFG_IA_Controller.ControllerData ctrlData = GNE_SFA2_PFG_IA_Controller.onBrandChanged(null, null, null, false, pfgType, brandName, year);
			Test.stopTest();
			
			System.assertNotEquals(null, ctrlData.currentBrand, 'Brand not set');
			System.assertEquals(2, ctrlData.availableProducts.size()-1, 'Wrong Number of available Products');
		}
	}
	/*
	public static TestMethod void testProductChangedDtpHO() {
		intProductChanged('HO1', GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP, System.today().year(), 'DTP1');
	}
	
	public static TestMethod void testProductChangedHcHO() {
		intProductChanged('HO1', GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC, System.today().year(), 'HC1');
	}
	
	public static TestMethod void testProductChangedDtpRM() {
		intProductChanged('RM1', GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP, System.today().year(), 'DTP1');
	}
	
	public static TestMethod void testProductChangedDtpDM() {
		intProductChanged('DM1', GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP, System.today().year(), 'DTP1');
	}
	
	public static TestMethod void testProductChangedHcDM() {
		intProductChanged('DM1', GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC, System.today().year(), 'HC1');
	}
	*/
	private static void intProductChanged(String userName, String pfgType, Integer year, String prodName) {
		User u = prepareEnv(userName);
		
		System.runAs(u) {
			Test.startTest();
			GNE_SFA2_PFG_IA_Controller.ControllerData ctrlData = GNE_SFA2_PFG_IA_Controller.onProductChanged(null, null, null, false, pfgType, 
					GNE_SFA2_PFG_TestHelper.getPfgProduct(prodName).Id, year);
			Test.stopTest();
			
			System.assertNotEquals(null, ctrlData.currentProductId, 'Product not set');
			System.assert(ctrlData.salesReps.size()>0, 'No Quantity rows');
			System.assert(ctrlData.userNodes.size()>1, 'Wrong number of User Quantity Nodes - ' + ctrlData.userNodes.size());
		}
	}
	
	private static User prepareEnv(String userName) {
		return GNE_SFA2_PFG_TestHelper.prepareEnvWithTerrs(userName);
    }
}