@isTest
private class EDM_Nomination_Status_Update_Test{

	static testMethod void businessClassificationDeleteTest(){
		Account a = new Account(Name = 'TestAccount1');
		insert a;
		Speaker_Bureau_gne__c businessBureau = new Speaker_Bureau_gne__c(Name='BusinessBureau',Speaker_Bureau_Type_gne__c = 'Business');
		insert businessBureau;
		Speaker_Bureau_Membership_gne__c sbm1 = new Speaker_Bureau_Membership_gne__c(
			Speaker_Status_gne__c = 'Pending',
			Speaker_Bureau_Id_gne__c = businessBureau.Id,
			Bureau_Member_gne__c = a.Id
		);
		insert sbm1;
		List<EDM_Classification_Request_gne__c> triggerOld = new List<EDM_Classification_Request_gne__c>();
		EDM_Classification_Request_gne__c cr = new EDM_Classification_Request_gne__c(
			EDM_Status_gne__c = 'Pending',
			EDM_Type_of_Classification_gne__c = 'Business',
			EDM_Action_Taken_gne__c = 'Decline to Classify',
			EDM_Account_gne__c = a.Id
		);
		triggerOld.add(cr);
		insert triggerOld;

		Map<Id,EDM_Classification_Request_gne__c> triggerOldMap = new Map<Id,EDM_Classification_Request_gne__c>();
		for(EDM_Classification_Request_gne__c cre : triggerOld){
			triggerOldMap.put(cre.Id,cre);
		}

		List<EDM_Classification_Request_gne__c> triggerNew = new List<EDM_Classification_Request_gne__c>(
			[Select EDM_Status_gne__c,EDM_Type_of_Classification_gne__c,EDM_Action_Taken_gne__c,EDM_Account_gne__c From
			 EDM_Classification_Request_gne__c]
		);
		for(EDM_Classification_Request_gne__c cre : triggerNew){
			cre.EDM_Status_gne__c = 'Completed';
		}

		List<Speaker_Bureau_Membership_gne__c> sbms = new List<Speaker_Bureau_Membership_gne__c>(
			[Select Id From Speaker_Bureau_Membership_gne__c]
		);
		System.assertEquals(1,sbms.size());

		EDM_Nomination_Status_Update.onAfterUpdateClassification(triggerOldMap,triggerNew);

		sbms = new List<Speaker_Bureau_Membership_gne__c>(
			[Select Id From Speaker_Bureau_Membership_gne__c]
		);
		System.assertEquals(0,sbms.size());
	}
	static testMethod void clinicalClassificationDeleteTest(){
		Account a = new Account(Name = 'TestAccount1');
		insert a;
		Speaker_Bureau_gne__c clinicalBureau = new Speaker_Bureau_gne__c(Name='BusinessBureau',Speaker_Bureau_Type_gne__c = 'Clinical');
		insert clinicalBureau;
		Speaker_Bureau_Membership_gne__c sbm1 = new Speaker_Bureau_Membership_gne__c(
			Speaker_Status_gne__c = 'Pending',
			Speaker_Bureau_Id_gne__c = clinicalBureau.Id,
			Bureau_Member_gne__c = a.Id
		);
		insert sbm1;
		List<EDM_Classification_Request_gne__c> triggerOld = new List<EDM_Classification_Request_gne__c>();
		EDM_Classification_Request_gne__c cr = new EDM_Classification_Request_gne__c(
			EDM_Status_gne__c = 'Pending',
			EDM_Type_of_Classification_gne__c = 'Clinical',
			EDM_Action_Taken_gne__c = 'Decline to Classify',
			EDM_Account_gne__c = a.Id
		);
		triggerOld.add(cr);
		insert triggerOld;

		Map<Id,EDM_Classification_Request_gne__c> triggerOldMap = new Map<Id,EDM_Classification_Request_gne__c>();
		for(EDM_Classification_Request_gne__c cre : triggerOld){
			triggerOldMap.put(cre.Id,cre);
		}

		List<EDM_Classification_Request_gne__c> triggerNew = new List<EDM_Classification_Request_gne__c>(
			[Select EDM_Status_gne__c,EDM_Type_of_Classification_gne__c,EDM_Action_Taken_gne__c,EDM_Account_gne__c From
			 EDM_Classification_Request_gne__c]
		);
		for(EDM_Classification_Request_gne__c cre : triggerNew){
			cre.EDM_Status_gne__c = 'Completed';
		}

		List<Speaker_Bureau_Membership_gne__c> sbms = new List<Speaker_Bureau_Membership_gne__c>(
			[Select Id From Speaker_Bureau_Membership_gne__c]
		);
		System.assertEquals(1,sbms.size());

		EDM_Nomination_Status_Update.onAfterUpdateClassification(triggerOldMap,triggerNew);

		sbms = new List<Speaker_Bureau_Membership_gne__c>(
			[Select Id From Speaker_Bureau_Membership_gne__c]
		);
		System.assertEquals(0,sbms.size());
	}
	static testMethod void businessClassificationUpdateTest(){
		Account a = new Account(Name = 'TestAccount1',AGS_Ex_Exclusion_Status_base_gne__c = 'Verified and Clear');
		insert a;
		Speaker_Bureau_gne__c businessBureau = new Speaker_Bureau_gne__c(Name='BusinessBureau',Speaker_Bureau_Type_gne__c = 'Business');
		insert businessBureau;
		Speaker_Bureau_Membership_gne__c sbm1 = new Speaker_Bureau_Membership_gne__c(
			Speaker_Status_gne__c = 'Pending',
			Speaker_Bureau_Id_gne__c = businessBureau.Id,
			Bureau_Member_gne__c = a.Id
		);
		insert sbm1;
		List<EDM_Classification_Request_gne__c> triggerOld = new List<EDM_Classification_Request_gne__c>();
		EDM_Classification_Request_gne__c cr = new EDM_Classification_Request_gne__c(
			EDM_Status_gne__c = 'Pending',
			EDM_Type_of_Classification_gne__c = 'Business',
			EDM_Action_Taken_gne__c = 'Local',
			EDM_Account_gne__c = a.Id
		);
		triggerOld.add(cr);
		insert triggerOld;

		Map<Id,EDM_Classification_Request_gne__c> triggerOldMap = new Map<Id,EDM_Classification_Request_gne__c>();
		for(EDM_Classification_Request_gne__c cre : triggerOld){
			triggerOldMap.put(cre.Id,cre);
		}

		List<EDM_Classification_Request_gne__c> triggerNew = new List<EDM_Classification_Request_gne__c>(
			[Select EDM_Status_gne__c,EDM_Type_of_Classification_gne__c,EDM_Action_Taken_gne__c,EDM_Account_gne__c From
			 EDM_Classification_Request_gne__c]
		);
		for(EDM_Classification_Request_gne__c cre : triggerNew){
			cre.EDM_Status_gne__c = 'Completed';
		}

		List<Speaker_Bureau_Membership_gne__c> sbms = new List<Speaker_Bureau_Membership_gne__c>(
			[Select Id,Speaker_Status_gne__c From Speaker_Bureau_Membership_gne__c]
		);
		System.assertEquals(1,sbms.size());
		System.assertEquals('Pending',sbms[0].Speaker_Status_gne__c);

		EDM_Nomination_Status_Update.onAfterUpdateClassification(triggerOldMap,triggerNew);

		sbms = new List<Speaker_Bureau_Membership_gne__c>(
			[Select Id,Speaker_Status_gne__c From Speaker_Bureau_Membership_gne__c]
		);
		System.assertEquals(1,sbms.size());
		System.assertEquals('Nominated',sbms[0].Speaker_Status_gne__c);
	}
	static testMethod void clinicalClassificationUpdateTest(){
		Account a = new Account(Name = 'TestAccount1',AGS_Ex_Exclusion_Status_base_gne__c = 'Excluded');
		insert a;
		Speaker_Bureau_gne__c clinicalBureau = new Speaker_Bureau_gne__c(Name='BusinessBureau',Speaker_Bureau_Type_gne__c = 'Clinical');
		insert clinicalBureau;
		Speaker_Bureau_Membership_gne__c sbm1 = new Speaker_Bureau_Membership_gne__c(
			Speaker_Status_gne__c = 'Pending',
			Speaker_Bureau_Id_gne__c = clinicalBureau.Id,
			Bureau_Member_gne__c = a.Id
		);
		insert sbm1;
		List<EDM_Classification_Request_gne__c> triggerOld = new List<EDM_Classification_Request_gne__c>();
		EDM_Classification_Request_gne__c cr = new EDM_Classification_Request_gne__c(
			EDM_Status_gne__c = 'Pending',
			EDM_Type_of_Classification_gne__c = 'Clinical',
			EDM_Action_Taken_gne__c = 'Local',
			EDM_Account_gne__c = a.Id
		);
		triggerOld.add(cr);
		insert triggerOld;

		Map<Id,EDM_Classification_Request_gne__c> triggerOldMap = new Map<Id,EDM_Classification_Request_gne__c>();
		for(EDM_Classification_Request_gne__c cre : triggerOld){
			triggerOldMap.put(cre.Id,cre);
		}

		List<EDM_Classification_Request_gne__c> triggerNew = new List<EDM_Classification_Request_gne__c>(
			[Select EDM_Status_gne__c,EDM_Type_of_Classification_gne__c,EDM_Action_Taken_gne__c,EDM_Account_gne__c From
			 EDM_Classification_Request_gne__c]
		);
		for(EDM_Classification_Request_gne__c cre : triggerNew){
			cre.EDM_Status_gne__c = 'Completed';
		}

		List<Speaker_Bureau_Membership_gne__c> sbms = new List<Speaker_Bureau_Membership_gne__c>(
			[Select Id,Speaker_Status_gne__c From Speaker_Bureau_Membership_gne__c]
		);
		System.assertEquals(1,sbms.size());
		System.assertEquals('Pending',sbms[0].Speaker_Status_gne__c);

		EDM_Nomination_Status_Update.onAfterUpdateClassification(triggerOldMap,triggerNew);

		sbms = new List<Speaker_Bureau_Membership_gne__c>(
			[Select Id,Speaker_Status_gne__c From Speaker_Bureau_Membership_gne__c]
		);
		System.assertEquals(1,sbms.size());
		System.assertEquals('Excluded',sbms[0].Speaker_Status_gne__c);
	}

	static testMethod void exclusionExcludedUpdateTest(){
		Account a = new Account(
			Name = 'TestAccount1',
			EDM_Clinical_Classification_gne__c = 'Local',
			AGS_Ex_Exclusion_Status_base_gne__c = 'Excluded'
		);
		insert a;
		Speaker_Bureau_gne__c clinicalBureau = new Speaker_Bureau_gne__c(
			Name='BusinessBureau',
			Speaker_Bureau_Type_gne__c = 'Clinical',
			Speaker_Bureau_Year_gne__c = String.valueOf(Date.today().year())
		);
		insert clinicalBureau;
		Speaker_Bureau_Membership_gne__c sbm1 = new Speaker_Bureau_Membership_gne__c(
			Speaker_Status_gne__c = 'Pending',
			Speaker_Bureau_Id_gne__c = clinicalBureau.Id,
			Bureau_Member_gne__c = a.Id
		);
		insert sbm1;
		List<AGS_EX_Exclusion_Request_gne__c> triggerOld = new List<AGS_EX_Exclusion_Request_gne__c>();
		AGS_EX_Exclusion_Request_gne__c cr = new AGS_EX_Exclusion_Request_gne__c(
			AGS_EX_Account_Name_gne__c = a.Id,
			AGS_EX_Request_Status_gne__c = 'Pending',
			AGS_EX_Account_Primary_Address_gne__c = 'Los Angeles'
		);
		triggerOld.add(cr);
		insert triggerOld;

		Map<Id,AGS_EX_Exclusion_Request_gne__c> triggerOldMap = new Map<Id,AGS_EX_Exclusion_Request_gne__c>();
		for(AGS_EX_Exclusion_Request_gne__c cre : triggerOld){
			triggerOldMap.put(cre.Id,cre);
		}

		List<AGS_EX_Exclusion_Request_gne__c> triggerNew = new List<AGS_EX_Exclusion_Request_gne__c>(
			[Select id,AGS_EX_Request_Status_gne__c,AGS_EX_Account_Name_gne__c From
			 AGS_EX_Exclusion_Request_gne__c]
		);
		for(AGS_EX_Exclusion_Request_gne__c cre : triggerNew){
			cre.AGS_EX_Request_Status_gne__c = 'Completed';
		}
		List<Speaker_Bureau_Membership_gne__c> sbms = new List<Speaker_Bureau_Membership_gne__c>(
			[Select Id,Speaker_Status_gne__c From Speaker_Bureau_Membership_gne__c]
		);
		System.assertEquals(1,sbms.size());
		System.assertEquals('Pending',sbms[0].Speaker_Status_gne__c);
		EDM_Nomination_Status_Update.onAfterUpdateExclusion(triggerOldMap,triggerNew);
		sbms = new List<Speaker_Bureau_Membership_gne__c>(
			[Select Id,Speaker_Status_gne__c From Speaker_Bureau_Membership_gne__c]
		);
		System.assertEquals(1,sbms.size());
		System.assertEquals('Excluded',sbms[0].Speaker_Status_gne__c);
	}

	static testMethod void exclusionPendingUpdateTest(){
		Account a = new Account(
			Name = 'TestAccount1',
			EDM_Business_Classification_gne__c = 'Local',
			AGS_Ex_Exclusion_Status_base_gne__c = 'Verified and Clear'
		);
		insert a;
		Speaker_Bureau_gne__c businessBureau = new Speaker_Bureau_gne__c(
			Name='BusinessBureau',
			Speaker_Bureau_Type_gne__c = 'Business',
			Speaker_Bureau_Year_gne__c = String.valueOf(Date.today().year())
		);
		insert businessBureau;
		Speaker_Bureau_Membership_gne__c sbm1 = new Speaker_Bureau_Membership_gne__c(
			Speaker_Status_gne__c = 'Pending',
			Speaker_Bureau_Id_gne__c = businessBureau.Id,
			Bureau_Member_gne__c = a.Id
		);
		insert sbm1;
		List<AGS_EX_Exclusion_Request_gne__c> triggerOld = new List<AGS_EX_Exclusion_Request_gne__c>();
		AGS_EX_Exclusion_Request_gne__c cr = new AGS_EX_Exclusion_Request_gne__c(
			AGS_EX_Account_Name_gne__c = a.Id,
			AGS_EX_Request_Status_gne__c = 'Pending',
			AGS_EX_Account_Primary_Address_gne__c = 'Los Angeles'
		);
		triggerOld.add(cr);
		insert triggerOld;

		Map<Id,AGS_EX_Exclusion_Request_gne__c> triggerOldMap = new Map<Id,AGS_EX_Exclusion_Request_gne__c>();
		for(AGS_EX_Exclusion_Request_gne__c cre : triggerOld){
			triggerOldMap.put(cre.Id,cre);
		}

		List<AGS_EX_Exclusion_Request_gne__c> triggerNew = new List<AGS_EX_Exclusion_Request_gne__c>(
			[Select id,AGS_EX_Request_Status_gne__c,AGS_EX_Account_Name_gne__c From
			 AGS_EX_Exclusion_Request_gne__c]
		);
		for(AGS_EX_Exclusion_Request_gne__c cre : triggerNew){
			cre.AGS_EX_Request_Status_gne__c = 'Completed';
		}
		List<Speaker_Bureau_Membership_gne__c> sbms = new List<Speaker_Bureau_Membership_gne__c>(
			[Select Id,Speaker_Status_gne__c From Speaker_Bureau_Membership_gne__c]
		);
		System.assertEquals(1,sbms.size());
		System.assertEquals('Pending',sbms[0].Speaker_Status_gne__c);
		EDM_Nomination_Status_Update.onAfterUpdateExclusion(triggerOldMap,triggerNew);
		sbms = new List<Speaker_Bureau_Membership_gne__c>(
			[Select Id,Speaker_Status_gne__c From Speaker_Bureau_Membership_gne__c]
		);
		System.assertEquals(1,sbms.size());
		System.assertEquals('Nominated',sbms[0].Speaker_Status_gne__c);
	}

	static testMethod void exclusionPendingUpdateSBMExcludedTest(){
		Account a = new Account(
			Name = 'TestAccount1',
			EDM_Business_Classification_gne__c = 'Local',
			AGS_Ex_Exclusion_Status_base_gne__c = 'Verified and Clear'
		);
		insert a;
		Speaker_Bureau_gne__c businessBureau = new Speaker_Bureau_gne__c(
			Name='BusinessBureau',
			Speaker_Bureau_Type_gne__c = 'Business',
			Speaker_Bureau_Year_gne__c = String.valueOf(Date.today().year())
		);
		insert businessBureau;
		Speaker_Bureau_Membership_gne__c sbm1 = new Speaker_Bureau_Membership_gne__c(
			Speaker_Status_gne__c = 'Excluded',
			Speaker_Bureau_Id_gne__c = businessBureau.Id,
			Bureau_Member_gne__c = a.Id
		);
		insert sbm1;
		EDM_SpeakerBureau_Membership_History_gne__c sbmhsitory = new EDM_SpeakerBureau_Membership_History_gne__c(
			EDM_Speaker_Bureau_Membership_gne__c = sbm1.Id,
			EDM_Membership_Status_gne__c = 'Nominated',
			EDM_Created_Date_gne__c = Date.today()-1
		); 
		insert sbmhsitory;
		List<AGS_EX_Exclusion_Request_gne__c> triggerOld = new List<AGS_EX_Exclusion_Request_gne__c>();
		AGS_EX_Exclusion_Request_gne__c cr = new AGS_EX_Exclusion_Request_gne__c(
			AGS_EX_Account_Name_gne__c = a.Id,
			AGS_EX_Request_Status_gne__c = 'Pending',
			AGS_EX_Account_Primary_Address_gne__c = 'Los Angeles'
		);
		triggerOld.add(cr);
		insert triggerOld;

		Map<Id,AGS_EX_Exclusion_Request_gne__c> triggerOldMap = new Map<Id,AGS_EX_Exclusion_Request_gne__c>();
		for(AGS_EX_Exclusion_Request_gne__c cre : triggerOld){
			triggerOldMap.put(cre.Id,cre);
		}

		List<AGS_EX_Exclusion_Request_gne__c> triggerNew = new List<AGS_EX_Exclusion_Request_gne__c>(
			[Select id,AGS_EX_Request_Status_gne__c,AGS_EX_Account_Name_gne__c From
			 AGS_EX_Exclusion_Request_gne__c]
		);
		for(AGS_EX_Exclusion_Request_gne__c cre : triggerNew){
			cre.AGS_EX_Request_Status_gne__c = 'Completed';
		}
		List<Speaker_Bureau_Membership_gne__c> sbms = new List<Speaker_Bureau_Membership_gne__c>(
			[Select Id,Speaker_Status_gne__c From Speaker_Bureau_Membership_gne__c]
		);
		System.assertEquals(1,sbms.size());
		System.assertEquals('Excluded',sbms[0].Speaker_Status_gne__c);
		EDM_Nomination_Status_Update.onAfterUpdateExclusion(triggerOldMap,triggerNew);
		sbms = new List<Speaker_Bureau_Membership_gne__c>(
			[Select Id,Speaker_Status_gne__c From Speaker_Bureau_Membership_gne__c]
		);
		System.assertEquals(1,sbms.size());
		System.assertEquals('Nominated',sbms[0].Speaker_Status_gne__c);
	}
}