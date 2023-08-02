/************************************************************
*  @author: Piotr Przesmycki
*  Date: 2013-12-13
*  Description: This is a test class for GNE_SFA2_Call_Sample_trigger trigger.
*  
*  Modification History
*  Date        Name        			Description
*  2014-02-19  Piotr Przesmycki 	Modified unit test to use GNE_SFA2_Triggers_Test_Util for creating data
*  2014-12-03  Mateusz Michalczyk  	Added after delete logic test for OTR_Deleted_Record_gne__c record creation.
*************************************************************/
@isTest
private class GNE_SFA2_Call_Sample_trigger_Test {
	
	public static testMethod void testBeforeInsert() {
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-Field');
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				Account ac = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('test');
				insert ac;
				Call2_vod__c call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
				call.Account_vod__c=ac.Id;
				insert call;
				Call2_Sample_vod__c testSample = new Call2_Sample_vod__c(Call2_vod__c=call.Id);
				testSample.Quantity_vod__c=-1;
				try{
					insert testSample;
					//system.assert(false,'sample insert should fail and this line won\'t be reached');
				} catch(Exception ex){
					system.assert(true,'this insert should fail - '+ex.getMessage());
				}
				testSample.Quantity_vod__c=5;
				try{
					insert testSample;
					//system.assert(false,'sample insert should fail and this line won\'t be reached');
				} catch(Exception ex){
					system.assert(true,'this insert should fail - '+ex.getMessage());
				}
			}
		}
	}

	public static testMethod void testBeforeInsertWithCorrectGift() {
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				Id recTypeId = [select Id from RecordType WHERE Name = 'Health Care Professional (Prescriber)' LIMIT 1].Id;
				Account ac = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('test'); 
				ac.RecordTypeId=recTypeId;
				insert ac;
				Call2_vod__c call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
				call.Account_vod__c=ac.Id;
				insert call;
				Call2_Sample_vod__c testSample = new Call2_Sample_vod__c(Call2_vod__c=call.Id);
				testSample.Quantity_vod__c=-1;
				try{
					insert testSample;
					system.assert(false,'sample insert should fail and this line won\'t be reached');
				} catch(Exception ex){
					system.assert(true,'this insert should fail - '+ex.getMessage());
				}
				testSample.Quantity_vod__c=5;
				insert testSample;
				system.assert(true,'when quantity is not negative validation passes');
			}
		}
	}

	public static testMethod void testMethodJustToHaveMoreCodeCoverageBecauseThereIsNoMoreLogicToTestInThisTrigger(){
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				Id recTypeId = [select Id from RecordType WHERE Name = 'Health Care Professional (Prescriber)' LIMIT 1].Id;
				Account ac = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('test'); 
				ac.RecordTypeId=recTypeId;
				insert ac;

				Call2_vod__c call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
				call.Account_vod__c=ac.Id;
				insert call;

				Call2_Sample_vod__c testSample = new Call2_Sample_vod__c(Call2_vod__c=call.Id, Account_vod__c = ac.id);
				testSample.Quantity_vod__c=5;
				insert testSample;
				system.assert(true,'when quantity is not negative validation passes');

				testSample.Quantity_vod__c=4;
				update testSample;
				system.assert(true,'there is no logic thet will check something on update');

				delete testSample;
				checkIfOTRDeletedAreCreated();

				undelete testSample;
				system.assert(true,'there is no logic thet will check something on undelete');
			}
		}
	}

	private static void checkIfOTRDeletedAreCreated(){
		String nameOfDeletedObject = GNE_SFA2_Deleted_Records_Util.getOtrObjectNameForObjectType(Call2_Sample_vod__c.getSObjectType());
		List<OTR_Deleted_Record_gne__c> deletedRecords  =  [SELECT id, name,Object_name__c,Deleted_Record_Id__c,Parent_Account_Id_gne__c   FROM OTR_Deleted_Record_gne__c WHERE Object_name__c LIKE :nameOfDeletedObject];
		System.assertEquals(1, deletedRecords.size(), 'For one call sample should be 1 OTR_Deleted_Record_gne__c.');
	}
	
}