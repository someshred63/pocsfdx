global class GNE_UserToTerritoryAssignment_WS {
    
    WebService static String executeUserToTerritoryAssignmentProcess(Boolean isPreview, String userName) {
    	GNE_UserToTerritoryAssignment_Batch userToTerritoryBatch = new GNE_UserToTerritoryAssignment_Batch(isPreview, userName);
    	GNE_Batch_Runner.ExecuteResult result = GNE_Batch_Runner.executeBatch(userToTerritoryBatch, GNE_UserToTerritoryAssignment_Batch.class, 10);
		return result.getStatus();
	}
}