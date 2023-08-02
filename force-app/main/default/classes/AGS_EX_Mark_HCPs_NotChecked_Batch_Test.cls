@isTest(seeAllData=false)
private class AGS_EX_Mark_HCPs_NotChecked_Batch_Test{

	static testmethod void batchTest(){

		String NOT_CHECKED_STATUS = 'Not checked';

		RecordType rt = [SELECT Id, IsPersonType FROM RecordType WHERE SObjectType = 'Account' AND IsPersonType = true limit 1];
		Account acc = new Account(FirstName='test',LastName='account',
								  AGS_EX_Exclusion_Status_base_gne__c='Verified and clear', 
								  AGS_EX_Date_Checked_Exclusion_gne__c = Date.today()-370,Region_Code_gne__c = 1,
								  RecordTypeId = rt.Id);
		insert acc;
		
		Test.startTest();
			AGS_EX_Mark_HCPs_NotChecked_Batch b = new AGS_EX_Mark_HCPs_NotChecked_Batch();
			Database.executeBatch(b);
		Test.stopTest();

		acc = [Select id,AGS_EX_Exclusion_Status_base_gne__c from account where FirstName='test' and LastName='account'];
		System.assertEquals(NOT_CHECKED_STATUS,acc.AGS_EX_Exclusion_Status_base_gne__c);
	}
}