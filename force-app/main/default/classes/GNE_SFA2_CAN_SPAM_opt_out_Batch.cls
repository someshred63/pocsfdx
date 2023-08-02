/**
 * Subscribe batch task which runs subscribe process.
 */
global without sharing class GNE_SFA2_CAN_SPAM_opt_out_Batch implements Database.Batchable<SObject>, Database.AllowsCallouts, IBatch {
    global void runCustomLogic() {
        GNE_SFA2_CAN_SPAM_opt_out_Batch batchable = new GNE_SFA2_CAN_SPAM_opt_out_Batch();
        Database.executeBatch(batchable);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
    	DateTime lastExecution = getLastExecutionDate();
    	retrieveStagingData(lastExecution);
        return Database.getQueryLocator([SELECT Id, Channel_gne__c, Email_gne__c, Opt_Out_Date_gne__c FROM CAN_SPAM_Email_Opt_Out_gne__c WHERE LastModifiedDate > :lastExecution AND Channel_gne__c = 'global']);
    }

    global void execute(Database.BatchableContext BC, List<CAN_SPAM_Email_Opt_Out_gne__c> scope) {
		Map<String, CAN_SPAM_Email_Opt_Out_gne__c> emailToOptOutData = new Map<String, CAN_SPAM_Email_Opt_Out_gne__c>();
		Map<String, List<Contact>> emailToContact = new Map<String, List<Contact>>();
		 		
		for (CAN_SPAM_Email_Opt_Out_gne__c oData : scope) {
			emailToOptOutData.put(oData.Email_gne__c, oData);
		}
		for (Contact con: [SELECT Has_Opted_Out_gne__c, Has_Opted_Out_Date_gne__c, Email, Id FROM Contact WHERE Email in :emailToOptOutData.keySet()]) {
			if (!emailToContact.containsKey(con.Email)) {
				emailToContact.put(con.Email, new List<Contact>());
			}
			emailToContact.get(con.Email).add(con);
		}
		List<Contact> contactsToUpdate = new List<Contact>();		
		for (CAN_SPAM_Email_Opt_Out_gne__c oData : scope) {
			if (emailToContact.containsKey(oData.Email_gne__c)) {
				for (Contact cont :emailToContact.get(oData.Email_gne__c)) {
					if (cont.Has_Opted_Out_Date_gne__c == null || oData.Opt_Out_Date_gne__c > cont.Has_Opted_Out_Date_gne__c){
						cont.Has_Opted_Out_Date_gne__c = oData.Opt_Out_Date_gne__c;
						cont.Has_Opted_Out_gne__c = true;
						contactsToUpdate.add(cont);
					}
				}
			}			
		}
		if (!contactsToUpdate.isEmpty()){
			update contactsToUpdate;
		}
    }

    global void finish(Database.BatchableContext BC) {
        
    }
    
    private void retrieveStagingData(Datetime lastExecution) {
		String lastExecutionString = lastExecution.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
		List<GNE_SFA2_CAN_SPAM_opt_out.OptOutData> optOuts = GNE_SFA2_CAN_SPAM_Get_Opt_Out.getAllUserOpts(1000, lastExecutionString);
		if (optOuts != null && optOuts.size() > 0) {
			GNE_SFA2_CAN_SPAM_opt_out.saveData(optOuts);
		}
	}
	
	private Datetime getLastExecutionDate() {
		List<CAN_SPAM_Email_Opt_Out_gne__c> emailOptOuts = [SELECT LastModifiedDate  FROM CAN_SPAM_Email_Opt_Out_gne__c ORDER BY LastModifiedDate DESC LIMIT 1];
    	DateTime lastExecution = Date.today().addDays(-1);
    	if (!emailOptOuts.isEmpty() && emailOptOuts[0].LastModifiedDate.date() < Date.today().addDays(-1)) {
			lastExecution = emailOptOuts[0].LastModifiedDate.date();
    	}
    	return lastExecution;
	}
}