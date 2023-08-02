global without sharing class GNE_CAN_Subscribe_Batch_OrgAccount extends GNE_CAN_Subscribe_Batchable
        implements Database.Batchable<sObject>, Database.Stateful  {
	
	public GNE_CAN_Subscribe_Batch_OrgAccount() {
		super(null,true);
	}
	
	public GNE_CAN_Subscribe_Batch_OrgAccount(Boolean incrementalMode) {
		super(null,incrementalMode);
	}
	
	public GNE_CAN_Subscribe_Batch_OrgAccount(Set<Id> stgCustIds) {
		super(stgCustIds,false);
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {		
		System.debug('Starting Canada subscribe batch update for Organization Accounts.');
		return doStart(BC, GNE_CAN_Subscribe_Util.HCO_CUSTOMER_CLASS_NAME);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
    	System.debug('Executing Canada subscribe batch update for Orgznization Accounts.');
		doExecute(BC, scope);    	
    }
    
    global void finish(Database.BatchableContext BC) {
    	System.debug('Finishing Canada subscribe batch update for Orgznization Accounts.');
    	doFinish(BC);
    }
}