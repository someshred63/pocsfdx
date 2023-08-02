/************************************************************
*  @author: Michal Hrycenko, Roche
*  Date: 2012-08-14
*  Description: This is a test class for GNE_SFA2_MedComm_Trigger trigger.
*  
*  Modification History
*  Date        	Name        		Description
*  2014-02-20   Piotr Przesmycki    Using GNE_SFA2_Trigger_Test_Util to prepare data
*  2014-12-03   Mateusz Michalczyk  Added after delete logic test for OTR_Deleted_Record_gne__c record creation.      
*************************************************************/
@isTest
public with sharing class GNE_SFA2_MedComm_Trigger_Test {
	
	public static testMethod void testAccountFiledValidationOnUpdate() {
		GNE_SFA2_Util.switchAdminMode(false);
		
		List<Profile> canadianProfiles = [Select Id from Profile where name like '%RCanada%' limit 1];
		List<User> canadianUsers = [Select Id from User where ProfileId in :canadianProfiles and isActive = true limit 1];
		
		if(canadianUsers != null && canadianUsers.size() > 0) {
			System.runAs(canadianUsers[0]){
				Account basicAcct = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('Smith');
				basicAcct.FirstName = 'John';
				insert basicAcct;
				
				Account acctToChange = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('Smith');
				acctToChange.FirstName = 'Tom';
				insert acctToChange;
				
				Medical_Communication_gne__c medComm = new Medical_Communication_gne__c(Account_gne__c = basicAcct.Id, Status_gne__c = 'Submitted');
				insert medComm;
		
				Test.startTest();
				try {
					medComm.Account_gne__c = acctToChange.Id;
					update medComm;
				} catch (DMLException ex) {
					System.assert(ex.getMessage().contains(System.Label.Account_field_cannot_be_updated), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
				}
				Test.stopTest();
			}
		}else{
			System.assert(false, 'Could not find any canadian users!');
		}
	}

	public static testMethod void testMedicalReferralValidationOnDelete() {
		GNE_SFA2_Util.switchAdminMode(false);
		
		Medical_Communication_gne__c medComm = new Medical_Communication_gne__c(RecordTypeId = GNE_SFA2_MedComm_Test_Helper.referralRecordTypeId());
		insert medComm;
		
		Test.startTest();
		try {
			delete medComm;
		} catch (DMLException ex) {
			System.assert(ex.getMessage().contains(System.Label.Medical_Referral_cannot_be_deleted), ex.getMessage());
			System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
		}
		Test.stopTest();
	}

	public static testMethod void testReferralAndMedCommAcountFieldUpdate() {
		GNE_SFA2_Util.switchAdminMode(false);
		
		Account acct = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('Smith');
		acct.FirstName = 'John';
		insert acct;
		
		List<Medical_Communication_gne__c> referrals = GNE_SFA2_MedComm_Test_Helper.insertTestMedComms(null, new Map<String, Object>{'Account_gne__c' => acct.Id, 'RecordTypeId' => GNE_SFA2_MedComm_Test_Helper.referralRecordTypeId()});
		
		List<Medical_Communication_gne__c> medComms = GNE_SFA2_MedComm_Test_Helper.insertTestMedComms(null, new Map<String, Object>{'Account_gne__c' => acct.Id, 'RecordTypeId' => GNE_SFA2_MedComm_Test_Helper.medCommRecordTypeId()}); 
		
		referrals = [Select Id, Name, Account_gne__c, Account_Referral_gne__c, Account_Medcom_gne__c from Medical_Communication_gne__c where Id in : referrals];
		
		medComms = [Select Id, Name, Account_gne__c, Account_Referral_gne__c, Account_Medcom_gne__c from Medical_Communication_gne__c where Id in : medComms];
		
		for(Medical_Communication_gne__c medComm : referrals){
			System.assertEquals(acct.Id, medComm.Account_Referral_gne__c);
			System.assertEquals(null, medComm.Account_Medcom_gne__c);	
		}
		
		for(Medical_Communication_gne__c medComm : medComms){
			System.assertEquals(acct.Id, medComm.Account_Medcom_gne__c);
			System.assertEquals(null, medComm.Account_Referral_gne__c);	
		}
	} 

	public static testMethod void testMedCommDeletedRecordsCreation(){
		GNE_SFA2_Util.switchAdminMode(false);
		Account basicAcct = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('Smith');
		basicAcct.FirstName = 'John';
		insert basicAcct;
		Medical_Communication_gne__c medComm = new Medical_Communication_gne__c(Account_gne__c = basicAcct.Id, Status_gne__c = 'Submitted');
		insert medComm;
		Test.startTest();
			delete medComm;
		Test.stopTest();
		String nameOfDeletedObject = GNE_SFA2_Deleted_Records_Util.getOtrObjectNameForObjectType(Medical_Communication_gne__c.getSObjectType());
		List<OTR_Deleted_Record_gne__c> deletedRecords  =  [SELECT id, name,Object_name__c,Deleted_Record_Id__c,Parent_Account_Id_gne__c   FROM OTR_Deleted_Record_gne__c WHERE Object_name__c LIKE :nameOfDeletedObject];
		System.assertEquals(1, deletedRecords.size());
	}
}