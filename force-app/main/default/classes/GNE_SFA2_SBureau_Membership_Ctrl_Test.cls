@isTest
private class GNE_SFA2_SBureau_Membership_Ctrl_Test{

	public static testMethod void setValidationVariablesOtherTest(){

		Speaker_Bureau_gne__c bureau = new Speaker_Bureau_gne__c(Name='BusinessBureau',Speaker_Bureau_Type_gne__c = 'Business');
		insert bureau;
		Account a = new Account(Name = 'TestAccount1');
		insert a;
		Speaker_Bureau_Membership_gne__c sbm1 = new Speaker_Bureau_Membership_gne__c(
			Speaker_Status_gne__c = 'Pending',
			Speaker_Bureau_Id_gne__c = bureau.Id,
			Bureau_Member_gne__c = a.Id
		);
		insert sbm1;
		Account b = new Account(Name = 'TestAccount2');
		insert b;
		Speaker_Bureau_Membership_gne__c sbm2 = new Speaker_Bureau_Membership_gne__c(
			Speaker_Status_gne__c = 'Pending',
			Speaker_Bureau_Id_gne__c = bureau.Id,
			Bureau_Member_gne__c = b.Id
		);
		insert sbm2;
		
		Speaker_Bureau_gne__c targetbureau = new Speaker_Bureau_gne__c(Name='TargetBureau',Speaker_Bureau_Type_gne__c = 'Business');
		insert targetbureau;

		ApexPages.currentPage().getParameters().put('br_id',targetbureau.Id);

		GNE_SFA2_SBureau_Membership_Ctrl ctrl = new GNE_SFA2_SBureau_Membership_Ctrl();
		
		ctrl.selected = sbm1.Id;
		ctrl.setValidationVariablesForOther();

		List<ApexPages.Message> msgs = ApexPages.getMessages();
		System.assertEquals(1,msgs.size());
		System.assertEquals('All but one of the selected accounts are already members of target bureau. To nominate an individual speaker please start from the speaker�s account detail page.',msgs[0].getDetail());
	
		ctrl.selected = '';
		ctrl.setValidationVariablesForOther();

		msgs = ApexPages.getMessages();
		System.assertEquals(2,msgs.size());
		System.assertEquals('All of the selected accounts are already members of target bureau.',msgs[1].getDetail());
		
		ctrl.selected = sbm1.Id+';'+sbm2.Id;
		ctrl.setValidationVariablesForOther();

		System.assertEquals('Done',ctrl.exclusionStatus);
	}

	public static testMethod void setValidationVariablesNextYearTest(){

		Speaker_Bureau_gne__c bureau = new Speaker_Bureau_gne__c(Name='BusinessBureau',Speaker_Bureau_Type_gne__c = 'Business');
		insert bureau;
		Speaker_Bureau_gne__c nextYearBureau = new Speaker_Bureau_gne__c(
			Name='nextYearBureau',
			Speaker_Bureau_Type_gne__c = 'Business',
			Last_Year_Speaker_Bureau_gne__c = bureau.Id
		);
		insert nextYearBureau;
		Account a = new Account(Name = 'TestAccount1');
		insert a;
		Speaker_Bureau_Membership_gne__c sbm1 = new Speaker_Bureau_Membership_gne__c(
			Speaker_Status_gne__c = 'Pending',
			Speaker_Bureau_Id_gne__c = bureau.Id,
			Bureau_Member_gne__c = a.Id
		);
		insert sbm1;
		Account b = new Account(Name = 'TestAccount2');
		insert b;
		Speaker_Bureau_Membership_gne__c sbm2 = new Speaker_Bureau_Membership_gne__c(
			Speaker_Status_gne__c = 'Pending',
			Speaker_Bureau_Id_gne__c = bureau.Id,
			Bureau_Member_gne__c = b.Id
		);
		insert sbm2;
		Account c = new Account(Name = 'TestAccount2');
		insert c;
		Speaker_Bureau_Membership_gne__c sbm3 = new Speaker_Bureau_Membership_gne__c(
			Speaker_Status_gne__c = 'Pending',
			Speaker_Bureau_Id_gne__c = bureau.Id,
			Bureau_Member_gne__c = c.Id
		);
		insert sbm3;
		Speaker_Bureau_Membership_gne__c sbm4 = new Speaker_Bureau_Membership_gne__c(
			Speaker_Status_gne__c = 'Pending',
			Speaker_Bureau_Id_gne__c = nextYearBureau.Id,
			Bureau_Member_gne__c = c.Id
		);
		insert sbm4;		

		ApexPages.currentPage().getParameters().put('br_id',bureau.Id);

		GNE_SFA2_SBureau_Membership_Ctrl ctrl = new GNE_SFA2_SBureau_Membership_Ctrl();
		
		Test.startTest();
		ctrl.selected = sbm1.Id+';'+sbm2.Id+';'+sbm3.Id;
		ctrl.setValidationVariablesForNextYear();

		System.assertEquals('Done',ctrl.exclusionStatus);

		a.AGS_EX_Exclusion_Status_base_gne__c = 'In Process';
		update a;

		ctrl.setValidationVariablesForNextYear();

		System.assertEquals('Request Submitted',ctrl.exclusionStatus);

		a.AGS_EX_Exclusion_Status_base_gne__c = 'Check pending';
		update a;
		b.AGS_EX_Exclusion_Status_base_gne__c = 'Not checked';
		update b;

		ctrl.setValidationVariablesForNextYear();
		Test.stopTest();

		System.assertEquals('To Be Completed',ctrl.exclusionStatus);
	}

	public static testMethod void checkValidationForRemoveTest(){

		Speaker_Bureau_gne__c bureau = new Speaker_Bureau_gne__c(Name='BusinessBureau',Speaker_Bureau_Type_gne__c = 'Business');
		insert bureau;
		Account a = new Account(Name = 'TestAccount1');
		insert a;
		Speaker_Bureau_Membership_gne__c sbm1 = new Speaker_Bureau_Membership_gne__c(
			Speaker_Status_gne__c = 'Nominated',
			Speaker_Bureau_Id_gne__c = bureau.Id,
			Bureau_Member_gne__c = a.Id
		);
		insert sbm1;
		Account b = new Account(Name = 'TestAccount2');
		insert b;
		Speaker_Bureau_Membership_gne__c sbm2 = new Speaker_Bureau_Membership_gne__c(
			Speaker_Status_gne__c = 'Approved',
			Speaker_Bureau_Id_gne__c = bureau.Id,
			Bureau_Member_gne__c = b.Id
		);
		insert sbm2;
		
		Speaker_Bureau_gne__c targetbureau = new Speaker_Bureau_gne__c(Name='TargetBureau',Speaker_Bureau_Type_gne__c = 'Business');
		insert targetbureau;

		ApexPages.currentPage().getParameters().put('br_id',targetbureau.Id);

		GNE_SFA2_SBureau_Membership_Ctrl ctrl = new GNE_SFA2_SBureau_Membership_Ctrl();
		
		ctrl.selected = sbm1.Id+';'+sbm2.Id;
		ctrl.checkValidationForRemove();

		List<Speaker_Bureau_Membership_gne__c> sbms = new List<Speaker_Bureau_Membership_gne__c>([
			Select id From Speaker_Bureau_Membership_gne__c Where Speaker_Status_gne__c = 'Removed'
		]);
		System.assertEquals(2,sbms.size());
	}

	public static testMethod void checkValidationForApproveTest(){

		Speaker_Bureau_gne__c bureau = new Speaker_Bureau_gne__c(Name='BusinessBureau',Speaker_Bureau_Type_gne__c = 'Business');
		insert bureau;
		Account a = new Account(Name = 'TestAccount1');
		insert a;

		insert new Contact(
			Firstname='Exclusion',
			Lastname = 'Check',
			Account = a,
			Email='test@roche.com'
		);

		Speaker_Bureau_Membership_gne__c sbm1 = new Speaker_Bureau_Membership_gne__c(
			Speaker_Status_gne__c = 'Removed',
			Speaker_Bureau_Id_gne__c = bureau.Id,
			Bureau_Member_gne__c = a.Id
		);
		insert sbm1;
		Account b = new Account(Name = 'TestAccount2');
		insert b;
		Speaker_Bureau_Membership_gne__c sbm2 = new Speaker_Bureau_Membership_gne__c(
			Speaker_Status_gne__c = 'Removed',
			Speaker_Bureau_Id_gne__c = bureau.Id,
			Bureau_Member_gne__c = b.Id
		);
		insert sbm2;
		
		Speaker_Bureau_gne__c targetbureau = new Speaker_Bureau_gne__c(Name='TargetBureau',Speaker_Bureau_Type_gne__c = 'Business');
		insert targetbureau;

		ApexPages.currentPage().getParameters().put('br_id',targetbureau.Id);

		GNE_SFA2_SBureau_Membership_Ctrl ctrl = new GNE_SFA2_SBureau_Membership_Ctrl();
		
		ctrl.selected = sbm1.Id+';'+sbm2.Id;
		ctrl.checkValidationForApprove();

		List<Speaker_Bureau_Membership_gne__c> sbms = new List<Speaker_Bureau_Membership_gne__c>([
			Select id From Speaker_Bureau_Membership_gne__c Where Speaker_Status_gne__c = 'Approved'
		]);
		System.assertEquals(2,sbms.size());
	}

	public static testMethod void existingWrapperTest(){

		Speaker_Bureau_gne__c bureau = new Speaker_Bureau_gne__c(Name='BusinessBureau',Speaker_Bureau_Type_gne__c = 'Business');
		insert bureau;
		Account a = new Account(Name = 'TestAccount1');
		insert a;
		Speaker_Bureau_Membership_gne__c sbm1 = new Speaker_Bureau_Membership_gne__c(
			Speaker_Status_gne__c = 'Pending',
			Speaker_Bureau_Id_gne__c = bureau.Id,
			Bureau_Member_gne__c = a.Id
		);
		insert sbm1;
		Account b = new Account(Name = 'TestAccount2');
		insert b;
		Speaker_Bureau_Membership_gne__c sbm2 = new Speaker_Bureau_Membership_gne__c(
			Speaker_Status_gne__c = 'Pending',
			Speaker_Bureau_Id_gne__c = bureau.Id,
			Bureau_Member_gne__c = b.Id
		);
		insert sbm2;
		
		Speaker_Bureau_gne__c targetbureau = new Speaker_Bureau_gne__c(Name='TargetBureau',Speaker_Bureau_Type_gne__c = 'Business');
		insert targetbureau;

		EDM_Multiple_Nomination_Wrapper__c wpr = new EDM_Multiple_Nomination_Wrapper__c(
			EDM_Multiple_Nomination_Ids__c = sbm1.Id+';'+sbm2.Id
		);
		insert wpr;

		ApexPages.currentPage().getParameters().put('wrapperId',wpr.Id);
		ApexPages.currentPage().getParameters().put('br_id',targetbureau.Id);

		GNE_SFA2_SBureau_Membership_Ctrl ctrl = new GNE_SFA2_SBureau_Membership_Ctrl();
		
		System.assertEquals(wpr.EDM_Multiple_Nomination_Ids__c,ctrl.selected);
	}
}