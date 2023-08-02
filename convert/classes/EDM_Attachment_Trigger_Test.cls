@isTest
private class EDM_Attachment_Trigger_Test{

	public static testMethod void triggerTest(){

		Profile p_AB_Man = [Select Id From Profile Where Name = 'GNE-TLS-Manager'];
		User u = new User(
			FirstName = 'Manager',
			ProfileId = p_AB_Man.Id,
			Username = 'b@roche.com',
			LastName = 'Test', 
			Email = 'b@roche.com',
			TimeZoneSidKey = 'America/Los_Angeles', 
			LocaleSidKey = 'en_US', 
			EmailEncodingKey = 'ISO-8859-1', 
			LanguageLocaleKey = 'en_US'
		);
		insert u;

		EDM_AABP_gne__c testAABP = new EDM_AABP_gne__c(
			EDM_Plan_Year_gne__c = '2015',
			EDM_Plan_Received_gne__c = Date.today(),
			EDM_Final_Approval_Received_gne__c = Date.today(),
			EDM_ABS_Manager_gne__c = UserInfo.getUserId()
		);
		insert testAABP;
		EDM_IABP_gne__c parentIABP = new EDM_IABP_gne__c(
			EDM_Parent_AABP_gne__c = testAABP.Id,
			EDM_Executive_Summary_gne__c = true,
			EDM_Type_of_Event_gne__c = 'test event type',
			EDM_IABP_Version_gne__c = 199,
			EDM_Status_gne__c = 'PTD in Progress',
			EDM_ABS_Manager_gne__c = UserInfo.getUserId()
		);
		insert parentIABP;

		EDM_IABP_gne__c exeSumIABP = new EDM_IABP_gne__c(
			EDM_Parent_AABP_gne__c = testAABP.Id,
			EDM_Parent_IABP_gne__c = parentIABP.Id,
			EDM_Executive_Summary_gne__c = true,
			EDM_Type_of_Event_gne__c = 'test event type',
			EDM_IABP_Version_gne__c = 199,
			EDM_ABS_Manager_gne__c = UserInfo.getUserId()
		);
		insert exeSumIABP;

		List<EDM_Attachment_gne__c> atts = new List<EDM_Attachment_gne__c>();
		atts.add(new EDM_Attachment_gne__c(
			EDM_Parent_IABP_gne__c = exeSumIABP.Id,			
			EDM_Pull_Through_Doc_gne__c = true,
			EDM_Complete_gne__c = false
		));
		insert atts;
		
		atts[0].EDM_Complete_gne__c = true;
		atts[0].EDM_Responsible_Party_gne__c = u.Id;
		update atts;
	}

	public static testMethod void triggerTest2(){

		Profile p_AB_Man = [Select Id From Profile Where Name = 'GNE-TLS-Manager'];
		User u = new User(
			FirstName = 'Manager',
			ProfileId = p_AB_Man.Id,
			Username = 'b@roche.com',
			LastName = 'Test', 
			Email = 'b@roche.com',
			TimeZoneSidKey = 'America/Los_Angeles', 
			LocaleSidKey = 'en_US', 
			EmailEncodingKey = 'ISO-8859-1', 
			LanguageLocaleKey = 'en_US'
		);
		insert u;

		EDM_AABP_gne__c testAABP = new EDM_AABP_gne__c(
			EDM_Plan_Year_gne__c = '2015',
			EDM_Plan_Received_gne__c = Date.today(),
			EDM_Final_Approval_Received_gne__c = Date.today()
		);
		insert testAABP;
		EDM_IABP_gne__c parentIABP = new EDM_IABP_gne__c(
			EDM_Parent_AABP_gne__c = testAABP.Id,
			EDM_Executive_Summary_gne__c = true,
			EDM_Type_of_Event_gne__c = 'test event type',
			EDM_IABP_Version_gne__c = 199,
			EDM_Status_gne__c = 'PTD in Progress'
		);
		insert parentIABP;

		EDM_IABP_gne__c exeSumIABP = new EDM_IABP_gne__c(
			EDM_Parent_AABP_gne__c = testAABP.Id,
			EDM_Parent_IABP_gne__c = parentIABP.Id,
			EDM_Executive_Summary_gne__c = true,
			EDM_Type_of_Event_gne__c = 'test event type',
			EDM_IABP_Version_gne__c = 199
		);
		insert exeSumIABP;

		List<EDM_Attachment_gne__c> atts = new List<EDM_Attachment_gne__c>();
		atts.add(new EDM_Attachment_gne__c(
			EDM_Parent_IABP_gne__c = parentIABP.Id,			
			EDM_Pull_Through_Doc_gne__c = true,
			EDM_Complete_gne__c = false
		));
		insert atts;

		atts[0].EDM_Responsible_Party_gne__c = u.Id;
		update atts;
	}

	public static testMethod void triggerTest3(){

		Profile p_AB_Man = [Select Id From Profile Where Name = 'GNE-TLS-Manager'];
		User u = new User(
			FirstName = 'Manager',
			ProfileId = p_AB_Man.Id,
			Username = 'b@roche.com',
			LastName = 'Test', 
			Email = 'b@roche.com',
			TimeZoneSidKey = 'America/Los_Angeles', 
			LocaleSidKey = 'en_US', 
			EmailEncodingKey = 'ISO-8859-1', 
			LanguageLocaleKey = 'en_US'
		);
		insert u;

		EDM_AABP_gne__c testAABP = new EDM_AABP_gne__c(
			EDM_Plan_Year_gne__c = '2015',
			EDM_Plan_Received_gne__c = Date.today(),
			EDM_Final_Approval_Received_gne__c = Date.today()
		);
		insert testAABP;
		EDM_IABP_gne__c parentIABP = new EDM_IABP_gne__c(
			EDM_Parent_AABP_gne__c = testAABP.Id,
			EDM_Executive_Summary_gne__c = true,
			EDM_Type_of_Event_gne__c = 'test event type',
			EDM_IABP_Version_gne__c = 199,
			EDM_Status_gne__c = 'PTD in Progress'
		);
		insert parentIABP;

		EDM_IABP_gne__c exeSumIABP = new EDM_IABP_gne__c(
			EDM_Parent_AABP_gne__c = testAABP.Id,
			EDM_Parent_IABP_gne__c = parentIABP.Id,
			EDM_Executive_Summary_gne__c = true,
			EDM_Type_of_Event_gne__c = 'test event type',
			EDM_IABP_Version_gne__c = 199
		);
		insert exeSumIABP;

		List<EDM_Attachment_gne__c> atts = new List<EDM_Attachment_gne__c>();
		atts.add(new EDM_Attachment_gne__c(
			EDM_Parent_IABP_gne__c = parentIABP.Id,			
			EDM_Pull_Through_Doc_gne__c = true,
			EDM_Complete_gne__c = false
		));
		atts.add(new EDM_Attachment_gne__c(
			EDM_Parent_IABP_gne__c = parentIABP.Id,			
			EDM_Pull_Through_Doc_gne__c = true,
			EDM_Complete_gne__c = false
		));	
		insert atts;

		atts[0].EDM_Complete_gne__c = true;
		atts[0].EDM_Responsible_Party_gne__c = u.Id;
		atts[1].EDM_Responsible_Party_gne__c = u.Id;

		update atts;
	}

}