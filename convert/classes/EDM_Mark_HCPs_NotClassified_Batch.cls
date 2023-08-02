global class EDM_Mark_HCPs_NotClassified_Batch implements Database.Batchable<sObject>, Database.Stateful {
	
	final static String NOT_CLASSIFIED_STATUS = 'Not Classified';
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		System.debug('EDM_Mark_HCPs_NotClassified_Batch start.');

		//get Accounts that are from US, RT is PersonAccount and at least one of the classifications is blank
		return Database.getQueryLocator([SELECT Id, Classification_gne__c, EDM_Business_Classification_gne__c, EDM_Clinical_Classification_gne__c 
										FROM Account
										WHERE Region_Code_gne__c = 1
										AND RecordType.IsPersonType = true
										AND (EDM_Business_Classification_gne__c = null AND EDM_Clinical_Classification_gne__c = null)]);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		if (scope != null && scope.size() > 0) {
			List<Account> accountsListToUpdate = new List<Account>();
			for(sObject objAccount : scope) {
				Account acc = (Account)objAccount;

				acc.EDM_Business_Classification_gne__c = NOT_CLASSIFIED_STATUS;

				if (acc.Classification_gne__c != null) {
					acc.EDM_Clinical_Classification_gne__c = (acc.Classification_gne__c == 'Local' ? 'Community' : acc.Classification_gne__c);
				} else {
					acc.EDM_Clinical_Classification_gne__c = NOT_CLASSIFIED_STATUS;
				}
				accountsListToUpdate.add(acc);
			}
			update accountsListToUpdate;
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		System.debug('EDM_Mark_HCPs_NotClassified_Batch finished.');
	}	
}