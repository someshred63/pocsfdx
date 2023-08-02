global class GNE_SFA2_Tsf_Update_Batch implements Database.Batchable<sObject>, Database.Stateful {
	
	private Map<String, String> territoryOldNameToNewName;
	
	public GNE_SFA2_Tsf_Update_Batch(Map<String, String> territoryOldNameToNewName) {
		this.territoryOldNameToNewName = territoryOldNameToNewName;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator ([
						SELECT id, Territory_vod__c
						FROM TSF_vod__c
						WHERE Territory_vod__c in :territoryOldNameToNewName.keySet()]);
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		List<Tsf_vod__c> tsfes = (List<Tsf_vod__c>)scope;
		for (Tsf_vod__c tsf: tsfes) {
			tsf.Territory_vod__c = territoryOldNameToNewName.get(tsf.Territory_vod__c);
		}
		if (!tsfes.isEmpty()) {
			Database.update(tsfes, false);
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		system.debug('Tsfes updated');
	}
    
}