global class GNE_SFA2_PFG_toTerritoryBatch implements Database.Batchable<SObject>, Database.Stateful 
{
	public static String executeBatch() {
		GNE_SFA2_PFG_toTerritoryBatch targetBatch = new GNE_SFA2_PFG_toTerritoryBatch();
		GNE_Batch_Runner.ExecuteResult result = GNE_Batch_Runner.executeBatch(targetBatch, GNE_SFA2_PFG_toTerritoryBatch.class);
		return result.getStatus();	
	}
	
	global Database.Querylocator start(Database.BatchableContext context) 
	{
		  return Database.getQueryLocator([Select Id, YTD_Allocated_gne__c from SFA2_PFG_to_Territory_Detail_gne__c where Active_gne__c = true]);
	}
	global void execute(Database.BatchableContext context, List<SObject> scope) 
	{
		for(SObject uDetail : scope)
		{
			uDetail.put('YTD_Allocated_gne__c', 0);
		}
		update scope;
	}
	global void finish(Database.BatchableContext context) 
	{
		
	}
}