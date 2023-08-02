/************************************************************
*  @author: Piotr Przesmycki
*  Date: 2013-12-18
*  Description: This is a test class for GNE_SFA2_Task_Trigger trigger.
*  
*  Modification History
*  Date        Name        		Description
*  2014-02-14  Piotr Przesmycki Modified unit test to use GNE_SFA2_Triggers_Test_Util for creating data          
*************************************************************/
@isTest
private class GNE_SFA2_Task_Trigger_Test {
	
	public static testMethod void testTask() {
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		User sfa2User = selectSFA2User();
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				String descript = 'sample description';
				Call2_vod__c sampleCall = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
				insert sampleCall;
				Task testTask = GNE_SFA2_Triggers_Test_Util.prepareTask( sampleCall.Id );
				testTask.Followup_Activity_Type_vod__c  = 'test';
				testTask.Subject 						= 'Other - See Comments';
				testTask.Description 					= descript;
				testTask.Override_Lock_vod__c			= true;
				insert testTask;
				testTask = [SELECT Id, Followup_Activity_Type_vod__c, Subject, Description, Creator_Comments_gne__c, WhatId FROM Task WHERE Id = :testTask.Id];
				system.assertEquals(testTask.Subject,descript);
				try{
					testTask.Creator_Comments_gne__c='changed';
					update testTask;
					system.assert(false,'this line shouldn\'t be reached due to validation');
				} catch(Exception ex){
					system.assert(ex.getMessage().contains(System.Label.Creator_Comments_Validation));
				}
				testTask = [SELECT Id, Followup_Activity_Type_vod__c, Subject, Description, Creator_Comments_gne__c, WhatId FROM Task WHERE Id = :testTask.Id];
				testTask.Description='modified description';
				update testTask;
				Task_Replica_gne__c tr = GNE_SFA2_Triggers_Test_Util.prepareTask_Replica_gne();
				tr.Id_gne__c = testTask.Id;
				insert tr;
				system.assertEquals(1, [SELECT Count() FROM Task_Replica_gne__c WHERE Id=:tr.Id]);
				delete testTask;
				system.assertEquals(0, [SELECT Count() FROM Task_Replica_gne__c WHERE Id=:tr.Id]);
			}
		}
	}

	public static testMethod void testTaskWithSubmitterdCall() {
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		User sfa2User = selectSFA2User();
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				String descript = 'sample description';
				Call2_vod__c parentCall = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
				insert parentCall;
				Call2_vod__c sampleCall = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
				sampleCall.Parent_Call_vod__c = parentCall.Id;
				insert sampleCall;
				Task testTask = GNE_SFA2_Triggers_Test_Util.prepareTask( sampleCall.Id );
				testTask.Followup_Activity_Type_vod__c  = 'test';
				testTask.Subject 						= 'Other - See Comments';
				testTask.Description 					= descript;
				insert testTask;
				parentCall.Status_vod__c='Submitted_vod';
				update parentCall;
				try{
					delete testTask;
					system.assert(false,'this line should not be reached due to validation rules');
				} catch(DmlException ex){
					system.assert(ex.getMessage().contains(System.Label.GNE_SFA2_Submitted_Call_Delete_Error),ex.getMessage());
					system.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
				}
				parentCall = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
				insert parentCall;
				testTask = GNE_SFA2_Triggers_Test_Util.prepareTask( parentCall.Id );
				testTask.Followup_Activity_Type_vod__c  = 'test';
				testTask.Subject 						= 'Other - See Comments';
				testTask.Description 					= descript;
				insert testTask;
				parentCall.Status_vod__c='Submitted_vod';
				update parentCall;
				try{
					update testTask;
					system.assert(false,'this line should not be reached due to validation rules');
				} catch(DmlException ex){
					system.assert(ex.getMessage().contains(System.Label.GNE_SFA2_Submitted_Call_Update_error),ex.getMessage());
					system.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
				}
				try{
					delete testTask;
					system.assert(false,'this line should not be reached due to validation rules');
				} catch(DmlException ex){
					system.assert(ex.getMessage().contains(System.Label.GNE_SFA2_Submitted_Call_Delete_Error),ex.getMessage());
					system.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
				}
				
			}
		}
	}

	public static User selectSFA2User() {
        List<Profile> sfa2Profiles = [ SELECT Id FROM Profile WHERE Name = 'GNE-SFA-Actemra-CS' ];
        if(sfa2Profiles != null && sfa2Profiles.size() > 0) {
            List<User> sfa2Users = [ SELECT Id FROM USER WHERE ProfileId in :sfa2Profiles AND isActive = true ];
            if(sfa2Users != null && sfa2Users.size() > 0) {
                return sfa2Users[0];
            }
        }
        return null;
    }
}