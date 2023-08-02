/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-10-09
*  Description: This is a test class for GNE_SFA2_Call_Key_Message_Trigger trigger
*    
*  Modification History
*  Date        Name        			Description
*  2014-12-03  Mateusz Michalczyk   Added after delete logic test for OTR_Deleted_Record_gne__c record creation. 
*            
*************************************************************/
@isTest
public with sharing class GNE_SFA2_Call_Key_Message_Trigger_Test {
	
	public static testMethod void testValidationRulesOnInsert() {
		GNE_SFA2_Util.switchAdminMode(false);
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Call_Key_Message_Trigger', false);
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				Call2_vod__c testCall = GNE_SFA2_Call_Test_Helper.insertTestCall('Submitted_vod');
				try {
					List<Call2_Key_Message_vod__c> testCallKeyMessages = GNE_SFA2_Call_Test_Helper.insertTestCallKeyMessages(null, new Map<String, Object>{'Call2_vod__c' => testCall.Id, 
											'Entity_Reference_Id_vod__c' => null});
					System.assert(false, 'Call key message objects should not be added.');
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
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Call_Key_Message_Trigger', false);
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				Call2_vod__c testCall = GNE_SFA2_Call_Test_Helper.insertTestCall('test');
				List<Call2_Key_Message_vod__c> testCallKeyMessages = GNE_SFA2_Call_Test_Helper.insertTestCallKeyMessages(null, new Map<String, Object>{'Call2_vod__c' => testCall.Id, 
												'Entity_Reference_Id_vod__c' => null});
				testCall.Status_vod__c = 'Submitted_vod';
				update testCall;
				
				for(Call2_Key_Message_vod__c callKeyMessage : testCallKeyMessages) {
					callKeyMessage.Presentation_ID_vod__c = 'test';
				}
				
				try {
					update testCallKeyMessages;
					System.assert(false, 'Call key message objects should not be updated.');
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
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Call_Key_Message_Trigger', false);
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				Call2_vod__c testCall = GNE_SFA2_Call_Test_Helper.insertTestCall('test');
				List<Call2_Key_Message_vod__c> testCallKeyMessages = GNE_SFA2_Call_Test_Helper.insertTestCallKeyMessages(null, new Map<String, Object>{'Call2_vod__c' => testCall.Id,
									'Entity_Reference_Id_vod__c' => null});
				testCall.Status_vod__c = 'Submitted_vod';
				update testCall;
				
				try {
					delete testCallKeyMessages;
					System.assert(false, 'Call key message objects should not be updated.');
				} catch (DMLException ex) {
					System.assert(ex.getMessage().contains(System.Label.GNE_SFA2_Submitted_Call_Delete_Error), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
				}
			}
		}
	}
	
	public static testMethod void testFieldUpdatesAccountAttendeeOnInsert() {
		GNE_SFA2_Util.switchAdminMode(false);
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Call_Key_Message_Trigger', false);
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				Call2_vod__c testCall = GNE_SFA2_Call_Test_Helper.insertTestCall('Planned_vod');
				Account testAccount = GNE_SFA2_Call_Test_Helper.insertTestAccount();
				List<Call2_Key_Message_vod__c> testCallKeyMessages = GNE_SFA2_Call_Test_Helper.insertTestCallKeyMessages(null, new Map<String, Object>{'Call2_vod__c' => testCall.Id,
						'Attendee_Type_vod__c' => 'Person_Account_vod', 'Entity_Reference_Id_vod__c' => testAccount.Id});
				
				testCallKeyMessages = [ SELECT Account_vod__c, Entity_Reference_Id_vod__c FROM Call2_Key_Message_vod__c WHERE Id IN :testCallKeyMessages ];
				for(Call2_Key_Message_vod__c testCallKeyMessage : testCallKeyMessages) {
					System.assertEquals(testCallKeyMessage.Account_vod__c, testAccount.Id);
					System.assertEquals(null, testCallKeyMessage.Entity_Reference_Id_vod__c);
				}		
			}
		}
	}
	
	public static testMethod void testFieldUpdatesContactAttendeeOnInsert() {
		GNE_SFA2_Util.switchAdminMode(false);
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Call_Key_Message_Trigger', false);
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				Call2_vod__c testCall = GNE_SFA2_Call_Test_Helper.insertTestCall('Planned_vod');
				Contact testContact = GNE_SFA2_Call_Test_Helper.insertTestContact();
				List<Call2_Key_Message_vod__c> testCallKeyMessages = GNE_SFA2_Call_Test_Helper.insertTestCallKeyMessages(null, new Map<String, Object>{'Call2_vod__c' => testCall.Id,
						'Attendee_Type_vod__c' => 'Contact_vod', 'Entity_Reference_Id_vod__c' => testContact.Id});
				
				testCallKeyMessages = [ SELECT Contact_vod__c, Entity_Reference_Id_vod__c FROM Call2_Key_Message_vod__c WHERE Id IN :testCallKeyMessages ];
				for(Call2_Key_Message_vod__c testCallKeyMessage : testCallKeyMessages) {
					System.assertEquals(testCallKeyMessage.Contact_vod__c, testContact.Id);
					System.assertEquals(null, testCallKeyMessage.Entity_Reference_Id_vod__c);
				}		
			}
		}
	}
	
	public static testMethod void testFieldUpdatesUserAttendeeOnInsert() {
		GNE_SFA2_Util.switchAdminMode(false);
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Call_Key_Message_Trigger', false);
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		User testUser = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestUser('test_user_name@gene.com', 'System Administrator');
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				Call2_vod__c testCall = GNE_SFA2_Call_Test_Helper.insertTestCall('Planned_vod');
				
				List<Call2_Key_Message_vod__c> testCallKeyMessages = GNE_SFA2_Call_Test_Helper.insertTestCallKeyMessages(null, new Map<String, Object>{'Call2_vod__c' => testCall.Id,
						'Attendee_Type_vod__c' => 'User_vod', 'Entity_Reference_Id_vod__c' => testUser.Id});
				
				testCallKeyMessages = [ SELECT User_vod__c, Entity_Reference_Id_vod__c FROM Call2_Key_Message_vod__c WHERE Id IN :testCallKeyMessages ];
				for(Call2_Key_Message_vod__c testCallKeyMessage : testCallKeyMessages) {
					System.assertEquals(testCallKeyMessage.User_vod__c, testUser.Id);
					System.assertEquals(null, testCallKeyMessage.Entity_Reference_Id_vod__c);
				}		
			}
		}
	}
	
	public static testMethod void testOTRDeletedRecordsCreation(){
		GNE_SFA2_Util.switchAdminMode(false);
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Call_Key_Message_Trigger', false);
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				Call2_vod__c testCall = GNE_SFA2_Call_Test_Helper.insertTestCall('test');
				List<Call2_Key_Message_vod__c> testCallKeyMessages = GNE_SFA2_Call_Test_Helper.insertTestCallKeyMessages(null, new Map<String, Object>{'Call2_vod__c' => testCall.Id,
									'Entity_Reference_Id_vod__c' => null});
				Account acc = GNE_SFA2_Call_Test_Helper.insertTestAccount();
				for(Call2_Key_Message_vod__c key : testCallKeyMessages){
					key.Account_vod__c = acc.id;
				}
				update testCallKeyMessages;
				Test.startTest();
					delete testCallKeyMessages;
				Test.stopTest();
				}
			String nameOfDeletedObject = GNE_SFA2_Deleted_Records_Util.getOtrObjectNameForObjectType(Call2_Key_Message_vod__c.getSObjectType());
            List<OTR_Deleted_Record_gne__c> deletedRecords  =  [SELECT id, name,Object_name__c,Deleted_Record_Id__c,Parent_Account_Id_gne__c   FROM OTR_Deleted_Record_gne__c WHERE Object_name__c LIKE :nameOfDeletedObject];
            System.assertEquals(201, deletedRecords.size());
		}	
	}
}