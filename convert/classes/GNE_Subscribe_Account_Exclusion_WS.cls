global class GNE_Subscribe_Account_Exclusion_WS {
	
	Webservice static String executeProcess(Boolean prevMode){
		GNE_Subscribe_Account_Exclusion targetBatch = new GNE_Subscribe_Account_Exclusion(prevMode);
		GNE_Batch_Runner.ExecuteResult result = GNE_Batch_Runner.executeBatch(targetBatch, GNE_Subscribe_Account_Exclusion.class, 100);
		return result.getStatus();
	}

}