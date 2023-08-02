global without sharing class GNE_SFA2_CAN_SPAM_Get_Opt_Out_Batch implements Database.Batchable<sObject>,  Database.AllowsCallouts, Database.Stateful {
	
    private static final String SELECT_QUERY = 'SELECT Id, Email_gne__c, Channel_gne__c, Opt_Out_Date_gne__c, LastModifiedDate ' +
    											'FROM CAN_SPAM_Email_Opt_Out_gne__c ORDER BY LastModifiedDate DESC LIMIT 1';
  	private static Boolean isInitialLoad = true;
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(SELECT_QUERY);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		List<GNE_SFA2_CAN_SPAM_opt_out.OptOutData> optOuts = new List<GNE_SFA2_CAN_SPAM_opt_out.OptOutData>();
		List<CAN_SPAM_Email_Opt_Out_gne__c> emailOptOuts = (List<CAN_SPAM_Email_Opt_Out_gne__c>)scope;
		DateTime lastExecution = emailOptOuts[0].LastModifiedDate.date() > Date.today().addDays(-1) ? Date.today().addDays(-1) : emailOptOuts[0].LastModifiedDate.date();
		String lastExecutionString = lastExecution.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
		optOuts = GNE_SFA2_CAN_SPAM_Get_Opt_Out.getAllUserOpts(1000, lastExecutionString);
		if(optOuts != null && optOuts.size() > 0){
			GNE_SFA2_CAN_SPAM_opt_out.saveData(optOuts);
		}
		isInitialLoad = false;
	}
	
	global void finish(Database.BatchableContext BC) {
		if(isInitialLoad){
			List<GNE_SFA2_CAN_SPAM_opt_out.OptOutData> optOuts = new List<GNE_SFA2_CAN_SPAM_opt_out.OptOutData>();
			optOuts = GNE_SFA2_CAN_SPAM_Get_Opt_Out.getAllUserOpts(1000);
			if(optOuts != null && optOuts.size() > 0){
				GNE_SFA2_CAN_SPAM_opt_out.saveData(optOuts);
			}
		}
		Database.executeBatch(new GNE_SFA2_CAN_SPAM_opt_out_Batch());
	}
	
}