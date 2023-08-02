@isTest
private class AGS_Close_Related_Cases_Ctrl_Test {
	
	static testMethod void shouldAutoRunAndSaveActionWithEventIdsInTransaction() {
		Boolean isEventIdInTransaction = true;
		shouldAutoRunAndSaveAction(isEventIdInTransaction);
	}
	
	static testMethod void shouldAutoRunAndSaveActionWithoutEventIdsInTransaction() {
		Boolean isEventIdInTransaction = false;
		shouldAutoRunAndSaveAction(isEventIdInTransaction);
	}
	
    static void shouldAutoRunAndSaveAction(Boolean isEventIdInTransaction) {
    	// GIVEN
    	AGS_CCO_Case_Reason__c reason = new AGS_CCO_Case_Reason__c(
    		AGS_Reason_Name__c 			= 'reasonName',
    		AGS_Reason_Description__c 	= 'reasonDescription',
    		Reason_Type__c 				= 'Instance Rule'
    	);
    	insert reason;
    	User ccoAnalyst = createCcoAnalystUser();
    	All_User_Hierarchy_gne__c inactiveResolver = new All_User_Hierarchy_gne__c(
    		User_External_Id_gne__c = 'gssptestuser',
    		FirstName_gne__c 		= ccoAnalyst.FirstName,
    		LastName_gne__c 		= ccoAnalyst.LastName,
    		Active_gne__c 			= true
    	);
    	insert inactiveResolver;
    	AGS_Case_gne__c agsCase = new AGS_Case_gne__c(
    	    Reason_gne__c 			= reason.Id,
    		Case_Status_gne__c 		= 'Open - Pending Manual Analysis',
    		Analyst_gne__c 			= ccoAnalyst.Id,
    		OwnerId 				= ccoAnalyst.Id,
    		Inactive_resolver__c 	= inactiveResolver.Id,
    		Resolver_gne__c 		= UserInfo.getUserId()
    	);
    	insert agsCase;
    	List<AGS_Spend_Expense_Transaction_gne__c> agsTransactions = new List<AGS_Spend_Expense_Transaction_gne__c>{
	    	new AGS_Spend_Expense_Transaction_gne__c(
	    		Event_ID_gne__c  = (isEventIdInTransaction ? 'eventId1' : null)
	    	),
	    	new AGS_Spend_Expense_Transaction_gne__c(
	    		Event_ID_gne__c  = (isEventIdInTransaction ? 'eventId2' : null)
	    	)
    	};
    	insert agsTransactions;
    	List<AGSSpendCCOCase_gne__c> spendCases = new List<AGSSpendCCOCase_gne__c>{
    		new AGSSpendCCOCase_gne__c(
    			AGS_Case_gne__c = agsCase.Id,
    			AGS_Spend_Expense_Transaction_gne__c = agsTransactions[0].Id
    		),
    		new AGSSpendCCOCase_gne__c(
    			AGS_Case_gne__c = agsCase.Id,
    			AGS_Spend_Expense_Transaction_gne__c = agsTransactions[1].Id
    		)
    	};
    	insert spendCases;
    	
    	All_User_Hierarchy_gne__c dummy = new All_User_Hierarchy_gne__c(
    		User_External_Id_gne__c = Utilities.noSpendUser,
    		FirstName_gne__c = 'No Spend'
    	);
    	insert dummy;
    	
    	ApexPages.currentPage().getParameters().put('id', agsCase.Id);
    	AGS_Close_Related_Cases_Cotroller ctrl = new AGS_Close_Related_Cases_Cotroller(
    		new ApexPages.StandardController(agsCase)
    	);
    	
    	// WHEN
    	ctrl.autoRun();
    	ctrl.sActionPicklist = 'Close Case - No Issue';
    	ctrl.saveAction();
    	
    	// THEN
    	RecordType rtCloseCase = [SELECT Id FROM RecordType WHERE Name = 'AGS Case Action-CloseCase-Readonly-Rect' LIMIT 1];
    	List<AGS_Case_Action_gne__c> caCloseCase = [
    		SELECT Id 
    		FROM AGS_Case_Action_gne__c 
    		WHERE RecordTypeId = :rtCloseCase.Id
    		AND AGS_Case_gne__c = :agsCase.Id
    		AND Action_gne__c = :ctrl.sActionPicklist
    	];
    	Integer numberOfClosedCasesActions = (isEventIdInTransaction ? 1 : 2);
    	System.assertEquals( numberOfClosedCasesActions, caCloseCase.size() );
    }
    
    static User createCcoAnalystUser() {
    	Test.startTest();
    	Profile p = [SELECT Id FROM Profile WHERE Name = 'GNE-AGS-CCO-Analyst' LIMIT 1];
        User u = new User(
        	FirstName 			= 'AGGS',
        	Alias 				= 'gssptest', 
        	Email 				= 'gssptestuser@gene.com',
            EmailEncodingKey 	= 'UTF-8', 
            LastName 			= 'Case Monitor', 
            LanguageLocaleKey 	= 'en_US',
            LocaleSidKey 		= 'en_US', 
            ProfileId 			= p.Id, 
            TimeZoneSidKey 		= 'America/Los_Angeles', 
            Username 			= 'gssptestuser@gene.com'
        );
        insert u;
        Test.stopTest();
        return u;
    }
}