global class GNE_Subscribe_MCE_WS {
  WebService static String executeProcess(Boolean prevMode) {
    GNE_Subscribe_MCE_Batch targetBatch = new GNE_Subscribe_MCE_Batch(prevMode);
    GNE_Batch_Runner.ExecuteResult result = GNE_Batch_Runner.executeBatch(targetBatch, GNE_Subscribe_MCE_Batch.class, 100);
    return result.getStatus();
  }
}