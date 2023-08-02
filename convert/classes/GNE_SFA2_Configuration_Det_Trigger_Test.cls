/************************************************************
*  @author: Piotr Przesmycki
*  Date: 2014-02-07
*  Description: This is a test class for GNE_SFA2_Configuration_Detail_Trigger trigger.
*  
*  Modification History
*  Date        Name        		Description
*  2014-02-19  Piotr Przesmycki Modified unit test to use GNE_SFA2_Triggers_Test_Util for creating data
*************************************************************/
@isTest
private class GNE_SFA2_Configuration_Det_Trigger_Test {
	
	private static SFA2_Configuration_Object_gne__c prepareConfigurationObj(String role){
		SFA2_Configuration_Object_gne__c configObject = GNE_SFA2_Triggers_Test_Util.prepareSFA2_Configuration_Object_gne();
		configObject.Name 						= 'Test';
        configObject.Attributes_gne__c 			= 'Sample attributes';
        configObject.Configuration_type_gne__c 	= 'Sample type';
        configObject.Brand_gne__c 				= null;
        configObject.Role_gne__c 				= role;
        insert configObject;          
        return [SELECT Id, External_Id_gne__c FROM SFA2_Configuration_Object_gne__c WHERE Id = :configObject.Id LIMIT 1];
	}

	private static SFA2_Configuration_Object_Detail_gne__c prepareConfigurationObjectDet(SFA2_Configuration_Object_gne__c confMaster, SFA2_Configuration_Object_gne__c confMaster2, Boolean fillLoadExternalId){
		SFA2_Configuration_Object_Detail_gne__c configObjectDetail=new SFA2_Configuration_Object_Detail_gne__c(
	        Type_gne__c 					= 'SampleType',
	        Label_gne__c 					='TestLabel',
	        Attributes_gne__c 				='TestAttributes',
	        Configuration_Object_ref_gne__c =confMaster.Id);
		if(fillLoadExternalId){
			configObjectDetail.Load_External_Id__c=confMaster2.External_Id_gne__c;
		}
        return configObjectDetail;
	}
        
	public static testMethod void testConfigurationDetailsWithoutLoadExternalId() {
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				SFA2_Configuration_Object_gne__c confObj1 = prepareConfigurationObj('sampleRole');
				SFA2_Configuration_Object_gne__c confObj2 = prepareConfigurationObj('sampleRole2');
				SFA2_Configuration_Object_Detail_gne__c detail = prepareConfigurationObjectDet(confObj1,confObj2,false);
				system.assertEquals(detail.Load_External_Id__c,null);
				system.assertEquals(detail.Configuration_Object_ref_gne__c,confObj1.Id);
				insert detail;
				detail = [SELECT Id,Load_External_Id__c,Configuration_Object_ref_gne__c FROM SFA2_Configuration_Object_Detail_gne__c WHERE Id = :detail.Id LIMIT 1];
				system.assertEquals(detail.Load_External_Id__c,null);
				system.assertEquals(detail.Configuration_Object_ref_gne__c,confObj1.Id);
				update detail;
				detail = [SELECT Id,Load_External_Id__c,Configuration_Object_ref_gne__c FROM SFA2_Configuration_Object_Detail_gne__c WHERE Id = :detail.Id LIMIT 1];
				system.assertEquals(detail.Load_External_Id__c,null);
				system.assertEquals(detail.Configuration_Object_ref_gne__c,confObj1.Id);
			}
		}
	}
	
	public static testMethod void testConfigurationDetailsWithLoadExternalId() {
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				SFA2_Configuration_Object_gne__c confObj1 = prepareConfigurationObj('sampleRole');
				SFA2_Configuration_Object_gne__c confObj2 = prepareConfigurationObj('sampleRole2');
				SFA2_Configuration_Object_Detail_gne__c detail = prepareConfigurationObjectDet(confObj1,confObj2,true);
				system.assertEquals(detail.Load_External_Id__c,confObj2.External_ID_gne__c);
				system.assertEquals(detail.Configuration_Object_ref_gne__c,confObj1.Id);
				insert detail;
				detail = [SELECT Id,Load_External_Id__c,Configuration_Object_ref_gne__c FROM SFA2_Configuration_Object_Detail_gne__c WHERE Id = :detail.Id LIMIT 1];
				system.assertEquals(detail.Load_External_Id__c,confObj2.External_ID_gne__c);
				system.assertEquals(detail.Configuration_Object_ref_gne__c,confObj2.Id);
				detail.Load_External_Id__c=null;
				update detail;
				detail = [SELECT Id,Load_External_Id__c,Configuration_Object_ref_gne__c FROM SFA2_Configuration_Object_Detail_gne__c WHERE Id = :detail.Id LIMIT 1];
				system.assertEquals(detail.Load_External_Id__c,null);
				system.assertEquals(detail.Configuration_Object_ref_gne__c,confObj2.Id);
			}
		}
	}

}