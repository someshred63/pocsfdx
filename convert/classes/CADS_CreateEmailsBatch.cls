global class CADS_CreateEmailsBatch implements Database.Batchable<sObject>{

	global  string Query; 
	
	global CADS_CreateEmailsBatch(String passedQuery)
	{  
		Query = passedQuery;
	}

	global Database.QueryLocator start(Database.BatchableContext BC)
	{
		return Database.getQueryLocator(Query);
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope)
	{ 
		Savepoint Savepoint = Database.setSavepoint();
		try
		{
			integer noOfInserts;
			integer noOfEmails;
			noOfEmails = Integer.valueOf(system.label.CADS_NoOf_Emails);
			noOfInserts=0;
			
			List<CADS_Account_Address_Issues_gne__c> issuesScope = (List<CADS_Account_Address_Issues_gne__c>) scope;
			Set<String> emails = new Set<String>();
			for(CADS_Account_Address_Issues_gne__c issue:issuesScope)
			{
				if(noOfInserts==noOfEmails)
				{
					break;
				}
				if(!emails.contains(issue.Alert_User_Email_Id_gne__c))
				{
					emails.add(issue.Alert_User_Email_Id_gne__c);
					noOfInserts++;
				}				
			}
			system.debug('----emails'+emails);
			List<CADS_Account_Address_Issues_gne__c> issues = [Select Id,Name, Current_Action_Owner_gne__c,Alert_User_Email_Id_gne__c,Alert_the_User_gne__c, Current_Action_Email_Status_gne__c from CADS_Account_Address_Issues_gne__c  where Alert_the_User_gne__c = 'yes' and Current_Action_Email_Status_gne__c='Not Sent' and Alert_User_Email_Id_gne__c != null and Alert_User_Email_Id_gne__c IN :emails];                                               
		    system.debug('----issues'+issues);
			Map<String,List<CADS_Account_Address_Issues_gne__c>> issuesMap = new Map<String,List<CADS_Account_Address_Issues_gne__c>>();
			for(String email: emails)
			{
				List<CADS_Account_Address_Issues_gne__c> issuesList = new List<CADS_Account_Address_Issues_gne__c>();
				for(CADS_Account_Address_Issues_gne__c issue:issues)
				{
					if(issue.Alert_User_Email_Id_gne__c == email)
					{
						issuesList.add(issue);
					}
				}
				issuesMap.put(email,issuesList);
			}
			
			List<Stewardship_Issue_Action_History_gne__c> updateActions = [Select Id, Issue_Id_gne__c,Email_Address_gne__c,Email_Created_Date_gne__c, Email_Status_gne__c From Stewardship_Issue_Action_History_gne__c 
		    Where Email_Status_gne__c = 'Not Sent' and Issue_Id_gne__c in :issues]; 
			system.debug('------updateActions'+updateActions);
			Map<Id,Stewardship_Issue_Action_History_gne__c> actionsMap = new Map<Id,Stewardship_Issue_Action_History_gne__c>();
			for(Stewardship_Issue_Action_History_gne__c action:updateActions)
			{
				actionsMap.put(action.Issue_Id_gne__c,action);
			}
			Set<string> variable = new Set<string>{'PortalURL'};
			List<Environment_Variables__c> env_var = new List<Environment_Variables__c>();
			env_var = GNE_CM_Environment_variable.get_env_variable(variable);
			string urlString = env_var.get(0).Value__c;
			string loginURL='http://'+env_var.get(0).Value__c;
			List<CADS_Issue_Alerter_gne__c> alerts = new List<CADS_Issue_Alerter_gne__c>();
			List<EmailAlertsWrapper> alertWrappers = new List<EmailAlertsWrapper>();
			for(String email:emails)
			{
				CADS_Issue_Alerter_gne__c alerter = new CADS_Issue_Alerter_gne__c();
				alerter.Alert_Sent_gne__c = true;
				alerter.User_Login_URL_gne__c = loginURL;
				alerter.Alert_User_Email_gne__c = email;
				Map<Id,Stewardship_Issue_Action_History_gne__c> actionsAlerterMap = new Map<Id,Stewardship_Issue_Action_History_gne__c>();
				List<CADS_Account_Address_Issues_gne__c> issuesToAlertList = new List<CADS_Account_Address_Issues_gne__c>();
				for(CADS_Account_Address_Issues_gne__c issue:issuesMap.get(email))
				{
					if(issue.Alert_the_User_gne__c =='YES')
					{
						if(issue.Alert_User_Email_Id_gne__c == actionsMap.get(issue.id).Email_Address_gne__c)
						{
							issue.Current_Action_Email_Status_gne__c = 'Sent';
							issue.Current_Action_Email_Date_gne__c=system.today();
							issuesToAlertList.add(issue);
							actionsMap.get(issue.id).Email_Status_gne__c = 'Sent';
							actionsMap.get(issue.id).Email_Created_Date_gne__c = system.today();
							actionsAlerterMap.put(issue.id,actionsMap.get(issue.id));
						}
					}
				}
				system.debug('-----issuesToAlertList'+issuesToAlertList);
				system.debug('-----actionsAlerterMap'+actionsAlerterMap);
				if(actionsAlerterMap.size() > 0)
				{
					EmailAlertsWrapper wrapper = new EmailAlertsWrapper();
					alerts.add(alerter);
					wrapper.alert = alerter;
					wrapper.issuesList = issuesToAlertList;
					wrapper.actionsList = actionsAlerterMap;
					alertWrappers.add(wrapper);
				}
			}
			
			insert alerts;
			system.debug('----alertWrappers'+alertWrappers);
			List<CADS_Email_Audit_Trail_gne__c> auditTrailTmp = new List<CADS_Email_Audit_Trail_gne__c>();
			List<CADS_Account_Address_Issues_gne__c> updateIssues = new List<CADS_Account_Address_Issues_gne__c>();
			List<Stewardship_Issue_Action_History_gne__c> actionsToUpdate = new List<Stewardship_Issue_Action_History_gne__c>();
			for(EmailAlertsWrapper alertWrapper:alertWrappers)
			{
				updateIssues.addAll(alertWrapper.issuesList);
				for(CADS_Account_Address_Issues_gne__c issue:alertWrapper.issuesList)
				{
					CADS_Email_Audit_Trail_gne__c audit = new CADS_Email_Audit_Trail_gne__c();
					audit.CADS_Account_Address_Issues_gne__c = issue.id;
					audit.CADS_Issue_Alerter_gne__c = alertWrapper.alert.id;
					audit.Stewardship_Issue_Action_History_gne__c = alertWrapper.actionsList.get(issue.id).id;
					actionsToUpdate.add(alertWrapper.actionsList.get(issue.id));
					auditTrailTmp.add(audit);
				}				
			}
			system.debug('----updateIssues'+updateIssues);
			system.debug('----updateActions'+actionsToUpdate);
			system.debug('----auditTrailTmp'+auditTrailTmp);
			update updateIssues;
			update actionsToUpdate;
			insert auditTrailTmp;
			
			boolean issuesError = false;
			for(CADS_Account_Address_Issues_gne__c issue:updateIssues)
			{
				if(issue.Current_Action_Email_Status_gne__c != 'Sent')
				{
					issuesError = true;
					break;
				}		
			}
			boolean actionsError = false;
			for(Stewardship_Issue_Action_History_gne__c action:actionsToUpdate)
			{
				if(action.Email_Status_gne__c != 'Sent')
				{
					actionsError = true;
					break;
				}
			}
			if(issuesError || actionsError)
			{
				Database.rollback ( savePoint );
			}
		}
		catch(Exception e)
		{
			System.debug('Could not Insert Emails , Actions, History');
			Database.rollback ( savePoint ); 
		}
	}
	
	public class EmailAlertsWrapper
	{
		public CADS_Issue_Alerter_gne__c alert {get;set;} 
		public List<CADS_Account_Address_Issues_gne__c> issuesList {get;set;}
		public Map<Id,Stewardship_Issue_Action_History_gne__c> actionsList {get;set;}
	}
	
	global void finish(Database.BatchableContext BC)
	{ 
		List<CADS_Email_Batch_Process_gne__c> batchStatus = CADS_Email_Batch_Process_gne__c.getall().values();
		batchStatus[0].Status_gne__c = 'Completed';
		update batchStatus;
		
		system.debug('Finished Batch'); 
		// Get the ID of the AsyncApexJob representing this batch job from Database.BatchableContext.  
		// Query the AsyncApexJob object to retrieve the current job's information.  
		AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
		TotalJobItems, CreatedBy.Email
		from AsyncApexJob where Id =:BC.getJobId()];
		// Send an email to the Apex job's submitter notifying of job completion.  
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {a.CreatedBy.Email};
		mail.setToAddresses(toAddresses);
		mail.setSubject('Email Creation Batch Job  : ' + a.Status);
		mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +' batches with '+ a.NumberOfErrors + ' failures..');
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
	}
}