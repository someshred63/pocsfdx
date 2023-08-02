/************************************************************
*  @author: Bartosz Osowiecki, Roche
*  Date: 2012-03-14
*  Description: 
*  Web service class used to start batch process for populating/depopulating Zip_to_Territory_gne__c records.
*  For more info see public comment of batch process class (GNE_ZipToTerritoryAssignment_Batch).
*************************************************************/ 
global class GNE_ZipToTerritoryAssignment_WS {
	
	webService static String executeZipToTerritoryAssignmentProcess(Boolean isPreview) {
		GNE_ZipToTerritoryAssignment_Batch zipToTerritoryBatch = new GNE_ZipToTerritoryAssignment_Batch(isPreview);
    	GNE_Batch_Runner.ExecuteResult result = GNE_Batch_Runner.executeBatch(zipToTerritoryBatch, GNE_ZipToTerritoryAssignment_Batch.class, 100);
		return result.getStatus();
	}
}