global class GNE_Subscribe_LOA_WS {
	
	WebService static String executeProcess(Boolean prevMode) {
		GNE_Subscribe_LOA_Batch targetBatch = new GNE_Subscribe_LOA_Batch(prevMode);
		GNE_Batch_Runner.ExecuteResult result = GNE_Batch_Runner.executeBatch(targetBatch, GNE_Subscribe_LOA_Batch.class, 10);
		return result.getStatus();
	}

}