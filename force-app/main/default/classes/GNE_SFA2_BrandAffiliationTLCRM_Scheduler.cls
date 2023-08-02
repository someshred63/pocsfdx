global class GNE_SFA2_BrandAffiliationTLCRM_Scheduler implements Schedulable{
	
	global void execute(SchedulableContext SC) {
    	GNE_SFA2_BrandAffiliationTLCRM_Batch baBatch = new GNE_SFA2_BrandAffiliationTLCRM_Batch();
    	Database.executeBatch(baBatch);
  	}  	  	  	 	
}