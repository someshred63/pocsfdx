/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-10-09
*  Description: This is a test class for GNE_SFA2_Call_Detail_Trigger trigger
*    
*  Modification History
*  Date        Name        			Description
*  2014-12-03   Mateusz Michalczyk  Added after delete logic test for OTR_Deleted_Record_gne__c record creation. (testCallDetailOTRDeletedRecordCreation)
*************************************************************/
@isTest
public with sharing class GNE_SFA2_Call_Detail_Trigger_Test {
	
	public static testMethod void testValidationRulesOnInsert() {
		GNE_SFA2_Util.switchAdminMode(false);
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Call_Detail_Trigger', false);
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				Call2_vod__c testCall = GNE_SFA2_Call_Test_Helper.insertTestCall('Submitted_vod');
				try {
					List<Call2_Detail_vod__c> testCallDetails = GNE_SFA2_Call_Test_Helper.insertTestCallDetails(testCall);
					System.assert(false, 'Call detail objects should not be added.');
				} catch (DMLException ex) {
					System.assert(ex.getMessage().contains(System.Label.GNE_SFA2_Submitted_Call_Update_error), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
				}
			}
		}
	}
	
	public static testMethod void testValidationRulesOnUpdate() {
		GNE_SFA2_Util.switchAdminMode(false);
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Call_Detail_Trigger', false);
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				Call2_vod__c testCall = GNE_SFA2_Call_Test_Helper.insertTestCall('test');
				List<Call2_Detail_vod__c> testCallDetails = GNE_SFA2_Call_Test_Helper.insertTestCallDetails(testCall);
				testCall.Status_vod__c = 'Submitted_vod';
				update testCall;
				
				for(Call2_Detail_vod__c callDetail : testCallDetails) {
					callDetail.Indication_gne__c = 'test';
				}
				
				try {
					update testCallDetails;
					System.assert(false, 'Call detail objects should not be updated.');
				} catch (DMLException ex) {
					System.assert(ex.getMessage().contains(System.Label.GNE_SFA2_Submitted_Call_Update_error), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
				}
			}
		}
	}
	
	public static testMethod void testValidationRulesOnDelete() {
		GNE_SFA2_Util.switchAdminMode(false);
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Call_Detail_Trigger', false);
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				Call2_vod__c testCall = GNE_SFA2_Call_Test_Helper.insertTestCall('test');
				List<Call2_Detail_vod__c> testCallDetails = GNE_SFA2_Call_Test_Helper.insertTestCallDetails(testCall);
				testCall.Status_vod__c = 'Submitted_vod';
				update testCall;
				
				try {
					delete testCallDetails;
					System.assert(false, 'Call detail objects should not be updated.');
				} catch (DMLException ex) {
					System.assert(ex.getMessage().contains(System.Label.GNE_SFA2_Submitted_Call_Delete_Error), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
				}
			}
		}
	}

	public static testMethod void testCallDetailOTRDeletedRecordCreation(){
		GNE_SFA2_Util.switchAdminMode(false);
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Call_Detail_Trigger', false);
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('test');
				insert acc;
				Call2_vod__c call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('test salesCollateral');
				call.Account_vod__c = acc.id;
				insert call;
				List<Call2_Detail_vod__c> testCallDetails = GNE_SFA2_Call_Test_Helper.insertTestCallDetails(call);
				Test.startTest();
					delete testCallDetails;
				Test.stopTest();
			}
		}
		String nameOfDeletedObject = GNE_SFA2_Deleted_Records_Util.getOtrObjectNameForObjectType(Call2_Detail_vod__c.getSObjectType());
		List<OTR_Deleted_Record_gne__c> deletedRecords  =  [SELECT id, name,Object_name__c,Deleted_Record_Id__c,Parent_Account_Id_gne__c   FROM OTR_Deleted_Record_gne__c WHERE Object_name__c LIKE :nameOfDeletedObject];
		System.assertEquals(201, deletedRecords.size());
	}
	
}