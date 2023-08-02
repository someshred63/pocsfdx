global class GNE_SFA2_PFG_YearJobScheduler implements Schedulable
{
	global void execute(SchedulableContext ctx)
    {
    	GNE_SFA2_PFG_toUserDetailBatch pfgToUserBatch = new GNE_SFA2_PFG_toUserDetailBatch();
    	Database.executeBatch(pfgToUserBatch);
    	
    	GNE_SFA2_PFG_toTerritoryBatch pfgToTerritoryBatch = new GNE_SFA2_PFG_toTerritoryBatch();
    	Database.executeBatch(pfgToTerritoryBatch);
    }
}