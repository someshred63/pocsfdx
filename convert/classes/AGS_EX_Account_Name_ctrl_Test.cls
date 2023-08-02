@isTest
private class AGS_EX_Account_Name_ctrl_Test{

	public static testMethod void getAccountNameTest(){

		Account a = new Account(
			Name = 'TestAccount'
		);
		insert a;

		AGS_EX_Exclusion_Request_gne__c req = new AGS_EX_Exclusion_Request_gne__c(
			AGS_EX_Account_Name_gne__c = a.Id,
			AGS_EX_Account_Primary_Address_gne__c = 'Los Angeles, USA'
		);
		insert req;

		AGS_EX_Exclusion_Check_gne__c exCheck = new AGS_EX_Exclusion_Check_gne__c(
			AGS_EX_Exclusion_Request_gne__c = req.Id,
			AGS_EX_Status_gne__c = 'Sanctioned but legal approved',
			AGS_EX_Check_Date_gne__c =Date.today()
		);
		insert exCheck;

		AGS_EX_Account_Name_ctrl ctrl = new AGS_EX_Account_Name_ctrl();
		ctrl.requestId = exCheck.Id;
		System.assertEquals('TestAccount',ctrl.getAccountName());
	}

	public static testMethod void getAccountNameExceptionTest(){

		AGS_EX_Account_Name_ctrl ctrl = new AGS_EX_Account_Name_ctrl();
		ctrl.requestId = 'WrongId';
		System.assertEquals('',ctrl.getAccountName());
	}

	public static testMethod void getExcludedAccountNameTest(){

		Account a = new Account(
			Name = 'TestAccount'
		);
		insert a;

		AGS_EX_Account_Name_ctrl ctrl = new AGS_EX_Account_Name_ctrl();
		ctrl.requestId = a.Id;
		System.assertEquals('TestAccount',ctrl.getExcludedAccountName());
	}

	public static testMethod void getExcludedAccountNameExceptionTest(){

		AGS_EX_Account_Name_ctrl ctrl = new AGS_EX_Account_Name_ctrl();
		ctrl.requestId = 'WrongId';
		System.assertEquals('',ctrl.getExcludedAccountName());
	}
}