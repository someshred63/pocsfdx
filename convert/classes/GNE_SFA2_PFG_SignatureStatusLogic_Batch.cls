global class GNE_SFA2_PFG_SignatureStatusLogic_Batch implements Database.Batchable<sObject>, Database.Stateful,
		GNE_Batch_Runner.Batchable, GNE_SFA2_PFG_Scheduler.SchedulerProcess {
			
	private Date CURRENT_DATE = System.today();
    
    public System.Type getBatchClass() {
		return GNE_SFA2_PFG_SignatureStatusLogic_Batch.class;
	}
	
	public String getBatchName() {
		return 'PFG SignatureStatusLogic Batch';
	}
    
    public void executeSchedulerProcess() {
        GNE_Batch_Runner.executeBatch(this, false, true, true, false);
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
    	return GNE_Batch_Runner.doStart(this,BC);
    }
    
    public Database.QueryLocator intStart(Database.BatchableContext BC) {
        Set<String> trxRecTypes = new Set<String>{GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RFF, GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_DISBURSEMENT};
        Set<String> excludedSigStatuses = new Set<String>{GNE_SFA2_PFG_Util.TRANSACTION_SIGNATURE_COMPLETE, GNE_SFA2_PFG_Util.OVERDUE_REMINDER_MORE_45};
        Set<String> excludedDeliveryStatuses = GNE_SFA2_PFG_Util.TRANSACTION_DELIVERY_ABORT_STATUSES;
        return Database.getQueryLocator([
        	SELECT Shipped_Date_gne__c,
        		Signature_Status_gne__c,
				Transaction_Date_gne__c,
				Transaction_Type_gne__c,
				From_User_gne__c,
				Signature_Date_gne__c,
				Account_gne__c,
				Product_gne__c,
				CreatedDate
				FROM SFA2_PFG_Transaction_gne__c
				WHERE	RecordType.Name IN :trxRecTypes
					AND Signature_Date_gne__c = null
					AND Shipped_Date_gne__c != null
					AND Signature_Status_gne__c NOT IN :excludedSigStatuses
					AND Delivery_Status_gne__c NOT IN :excludedDeliveryStatuses
				ORDER BY CreatedDate
		]);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope) {
    	GNE_Batch_Runner.doExecute(this,BC, scope);
    }
    
    public void intExecute(Database.BatchableContext BC, List<sObject> scope) {
    	GNE_SFA2_PFG_Util.addSessionLabel(getBatchName());
    	
    	List<SFA2_PFG_Transaction_gne__c> trxs = (List<SFA2_PFG_Transaction_gne__c>)scope;
    	List<SFA2_PFG_Transaction_gne__c> trxsToUpdate = new List<SFA2_PFG_Transaction_gne__c>();
        List<SFA2_PFG_to_Account_Detail_gne__c> accDetailsToUpdate = new List<SFA2_PFG_to_Account_Detail_gne__c>();
        
        GNE_SFA2_PFG_Util.cachePfgToAccountDetails(trxs);
        
    	for(SFA2_PFG_Transaction_gne__c trx : trxs) {
    		String overdueStatus = calculateOverdueStatus(trx);
    		
    		if(String.isNotBlank(overdueStatus)) {
    			trx.Signature_Status_gne__c = overdueStatus;
    			trxsToUpdate.add(trx);
    			
    			if(overdueStatus == GNE_SFA2_PFG_Util.OVERDUE_TYPE_FREEZ) {
    				SFA2_PFG_to_Account_Detail_gne__c aDetail = GNE_SFA2_PFG_Util.getPfgToAccountDetail(trx);
    				
    				if(aDetail!=null) {
            			aDetail.Freeze_for_Pending_AOC_gne__c = GNE_SFA2_PFG_Util.FREEZE_FOR_PENDING_AOC_YES;
            			accDetailsToUpdate.add(aDetail);
    				}
    			}
    		}
    	}
        GNE_SFA2_PFG_TransactionTrigger_Helper.setTransTrig(true);
        GNE_Batch_Runner.executeDML(this, trxsToUpdate, GNE_Batch_Runner.DMLType.UPDATE_DML, null, 'Update PFG Transactions');
        GNE_SFA2_PFG_TransactionTrigger_Helper.setTransTrig(false);
        
        GNE_Batch_Runner.executeDML(this, accDetailsToUpdate, GNE_Batch_Runner.DMLType.UPDATE_DML, null, 'Update PFG Account Details');
    }
    
    private String calculateOverdueStatus(SFA2_PFG_Transaction_gne__c trx) {
    	String status = null;
    	
    	Date shippedDate = trx.Shipped_Date_gne__c;
        Integer diffDays = shippedDate!=null ? shippedDate.daysBetween(CURRENT_DATE) : null;
            
        if(diffDays!=null && diffDays>=15 && diffDays<=30) {
           	status = GNE_SFA2_PFG_Util.OVERDUE_REMINDER_15_30;
        } else if(diffDays!=null && diffDays>30 && diffDays<=45) {
          	status = GNE_SFA2_PFG_Util.OVERDUE_REMINDER_31_45;
        } else if(diffDays!=null && diffDays>46) {
           	status = GNE_SFA2_PFG_Util.OVERDUE_REMINDER_MORE_45;
        } 
        
        return status;
    }
    
    public void finish(Database.BatchableContext BC) {
        GNE_Batch_Runner.doFinish(this,BC);
    }
    
    
    public void intFinish(Database.BatchableContext BC) {}
    
    public String getKeyForRecord(SObject sObj) {return sObj.Id;}
	public String getRecordDescription(SObject sObj) {
		return getKeyForRecord(sObj);
	}
	public void processDatabaseErrors(List<SObject> sObjs, Map<String,List<Database.Error>> recToErrorsMap, String actionId, String actionDescription) {}
	
	public String getErrorEmailDescription(String actionId, SObject sObj, Database.Error err) {
		return String.format('{0} [{1}]: {2}', new String[]{getRecordDescription(sObj), sObj.Id, err.getMessage()});
	}
}