public class AGSNotificationActions extends AGSCaseAction {

	public static AGS_Case_Action_gne__c runAction(AGS_Case_Action_gne__c caseAction, AGS_Case_gne__c caseInfo) {
		if (AGSCaseAction.isLatencyAction(caseAction)) { 
        	//Latency Reminder
            //Call the Latency Reminder Tasks
            //1.  Call Add Email to send                
            /* TODO can't we just pass the caseInfo object into the method? */
            AGS_Case_Action_gne__c caseActionToClose = new AGS_Case_Action_gne__c(Id=caseAction.Id);
            agsWorkflow.addEmailAndTaskToAGSCaseAction(caseAction,
                                                        caseInfo.Name,
                                                        caseInfo.Resolver_gne__r.Name,
                                                        caseInfo.Expense_Transaction_Total_gne__c,
                                                        caseInfo.Reason_gne__r.Name,
                                                        caseInfo.Reason_gne__r.AGS_Reason_Name__c,
                                                        caseInfo.Resolver_gne__r.Email,
                                                        caseInfo.Analyst_gne__r.Email);  
            //Auto Close Case Action
            AGSCaseAction.setCaseActionClosed(caseActionToClose);            
            //Set Case Action to Readonly
            AGSCaseAction.setCaseActionReadOnly(caseActionToClose);
      	}
		return caseAction;
	}
}