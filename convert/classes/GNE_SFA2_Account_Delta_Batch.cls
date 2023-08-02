global with sharing class GNE_SFA2_Account_Delta_Batch implements Database.Batchable<SObject>, Database.Stateful, GNE_SFA2_Account_Delta_Engine.DeltaErrorHandler {
	
	private Integer errorCount = 0;
	private List<String> errorsList;
	private List<String> errorsFullList = new List<String>();
	private List<String> emailsList = new List<String>();
	
	public static void executeBatch() {
		executeBatch(new List<String>());
	}
	
	public static void executeBatch(List<String> emailsList) {
		GNE_SFA2_Account_Delta_Batch batch = new GNE_SFA2_Account_Delta_Batch(emailsList);
		GNE_Batch_Runner.executeBatch(batch, GNE_SFA2_Account_Delta_Batch.class, false, true, true, false);
	}
	
	public GNE_SFA2_Account_Delta_Batch() {}
	
	public GNE_SFA2_Account_Delta_Batch(List<String> a_emailsList) {
		emailsList.addAll(GNE_Batch_Runner_Config.getEmailsForBatchWithDefault(GNE_SFA2_Account_Delta_Batch.class.getName()));
		
		if(a_emailsList!=null) {
			emailsList.addAll(a_emailsList);
		}
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		Set<Id> validRecordTypesIds = GNE_SFA2_Account_Delta_Engine.ADDRESS_INCLUDED_RECORD_TYPE_IDS;
		return Database.getQueryLocator(
			[
				SELECT Id, Name, Account_vod__c, Account_Record_Type_Id_calc_gne__c, MDM_Address_ID_gne__c, RecordTypeId
				FROM Address_vod__c 
				WHERE RecordTypeId IN :validRecordTypesIds AND MDM_Address_ID_gne__c = null
			]);
	}
	
	global void execute(Database.BatchableContext BC, List<SObject> scope) {
		errorsList = new List<String>();
		GNE_SFA2_Account_Delta_Engine.refreshDeltaRecords((List<Address_vod__c>)scope, this);
		
		if(!errorsList.isEmpty()) {
			errorsFullList.addAll(errorsList);
			sendEmailWithErrors(errorsList);
		}
	}
	
	private void sendEmailWithErrors(List<String> errorMsgs) {
		GNE_Batch_Runner.sendEmailNotification(GNE_SFA2_Account_Delta_Batch.class, emailsList,
				'Address Delta DML Error(s) Logged', 
				'List of Errors (' + errorMsgs.size() + '):\n - ' + String.join(errorMsgs,'\n - '));
	}
	
	global void finish(Database.BatchableContext BC) {
		GNE_Batch_Runner.sendEmailNotification(GNE_SFA2_Account_Delta_Batch.class, emailsList,
			'Batch Completed' + (errorCount>0 ? (' with ' + errorCount + ' Error(s).') : '.'),
			errorsFullList.isEmpty() ? null : ('List of Errors (' + errorsFullList.size() + '):\n - ' + String.join(errorsFullList,'\n - ')));
	}
	
	public void handleDeltaRecordErrors(SFA2_Address_Delta_gne__c deltaRec, SObject accOrAddr, Database.Error[] errors) {
		errorCount++;
		List<String> errorMsgs = new List<String>();
		
		for(Database.Error err : errors) {
			errorMsgs.add(err.getMessage());
		}
		
		String errorMessage = accOrAddr.get('Name') + ' (' + accOrAddr.Id + '): ' + String.join(errorMsgs, '||');
		errorsList.add(errorMessage);
	}
}