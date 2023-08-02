global class GNE_Subscribe_Brand_2_Salesforce_WS {
	
	WebService static String executeProcess(Boolean prevMode) {
		GNE_Subscribe_Brand_2_Salesforce targetBatch = new GNE_Subscribe_Brand_2_Salesforce(prevMode);
		GNE_Batch_Runner.ExecuteResult result = GNE_Batch_Runner.executeBatch(targetBatch, GNE_Subscribe_Brand_2_Salesforce.class, 100);
		return result.getStatus();
	}

}