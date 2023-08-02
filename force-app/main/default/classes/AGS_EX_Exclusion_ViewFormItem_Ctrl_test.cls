@isTest
private class AGS_EX_Exclusion_ViewFormItem_Ctrl_test{

	static testMethod void test(){

		Account acc = new Account(AGS_EX_Exclusion_Status_base_gne__c='Not Checked',Name = 'account');
        insert acc;
        insert new Contact(
            Firstname='Exclusion',
            Lastname = 'Check',
            Account = acc,
            Email='test@roche.com'
        );		
		ApexPages.currentPage().getParameters().put('id',(String)acc.Id);

		AGS_EX_Exclusion_ViewFormItem_Ctrl ext = new AGS_EX_Exclusion_ViewFormItem_Ctrl();

		ext.parentObj = [Select Id,Name,AGS_EX_Exclusion_Status_base_gne__c,AGS_EX_Exclusion_Status_gne__c From Account where id = :acc.Id LIMIT 1];

		System.assertEquals(acc.Id,ext.accountId);
		ext.createRequest();
		
		System.assertEquals(ext.isExclusionLinkVisible, false);

		ext.parentObj = [Select Id,Name,AGS_EX_Exclusion_Status_base_gne__c,AGS_EX_Exclusion_Status_gne__c From Account where Id = :acc.Id LIMIT 1];
		List<AGS_EX_Exclusion_Request_gne__c> existingExclusionRequests = [SELECT Id, AGS_EX_Account_Name_gne__c,CreatedDate 
                                                                                FROM AGS_EX_Exclusion_Request_gne__c 
                                                                                WHERE 
                                                                                AGS_EX_Request_Status_gne__c = 'Pending'
                                                                              AND AGS_EX_Account_Name_gne__c = :acc.Id];

        acc = (Account)ext.parentObj;                                                                      
		System.assertEquals('(Submitted on ' + existingExclusionRequests[0].CreatedDate.format('MM/dd/YYYY') +')',ext.getSubmittedDate(),acc.AGS_EX_Exclusion_Status_gne__c);
	}
}