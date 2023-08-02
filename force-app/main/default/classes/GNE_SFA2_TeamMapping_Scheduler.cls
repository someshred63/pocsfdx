global class GNE_SFA2_TeamMapping_Scheduler implements Schedulable{

	Boolean isCanada = false;
	Integer scopeSize = 5;
	Integer mySetupScopeSize = 5;

	public GNE_SFA2_TeamMapping_Scheduler() {

	}

	public GNE_SFA2_TeamMapping_Scheduler(Boolean isCanada, Integer scopeSize, Integer mySetupScopeSize) {
		this.isCanada = isCanada;
		this.scopeSize = scopeSize;
		this.mySetupScopeSize = mySetupScopeSize;
	}
	
	global void execute(SchedulableContext SC) {
		ProductAssigmentBatch paBatch;
		if(isCanada) {
			paBatch = new ProductAssigmentBatch(true, mySetupScopeSize);
			Database.executeBatch(paBatch, scopeSize);
		}
		else {
	    	paBatch = new ProductAssigmentBatch();
	    	Database.executeBatch(paBatch);
    	}
    }  
}