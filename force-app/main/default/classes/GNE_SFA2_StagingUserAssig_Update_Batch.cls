global class GNE_SFA2_StagingUserAssig_Update_Batch implements Database.Batchable<sObject>, Database.Stateful {
	
	private Map<String, String> territoryOldNameToNewName;
	
	public GNE_SFA2_StagingUserAssig_Update_Batch(Map<String, String> territoryOldNameToNewName) {
		this.territoryOldNameToNewName = territoryOldNameToNewName;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator ([
						SELECT id, Territory_Key_gne__c
						FROM Staging_User_Assignment_gne__c
						WHERE Territory_Key_gne__c in :territoryOldNameToNewName.keySet()]);
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		List<Staging_User_Assignment_gne__c> stagingRecords = (List<Staging_User_Assignment_gne__c>)scope;
		for (Staging_User_Assignment_gne__c rec: stagingRecords) {
			rec.Territory_Key_gne__c = territoryOldNameToNewName.get(rec.Territory_Key_gne__c);
		}
		if (!stagingRecords.isEmpty()) {
			Database.update(stagingRecords, false);
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		system.debug('Staging Records updated');
	}
    
}