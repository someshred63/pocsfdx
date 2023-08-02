public with sharing class GNE_SFA2_StagingAlignmentReportCtrl {
	
	private Alignment_Job_gne__c job;
	
	public GNE_SFA2_StagingAlignmentReportCtrl(ApexPages.StandardController stdController) {
        this.job = (Alignment_Job_gne__c)stdController.getRecord();
    }
	
	
	public String getHtmlReport() {
		List<Alignment_Job_gne__c> jobs = [SELECT Comments_json_gne__c FROM Alignment_Job_gne__c WHERE id =: job.Id];
		String territoryDetails = '';
		try {
			if (!jobs.isEmpty() && jobs.get(0).Comments_json_gne__c != null) {
				territoryDetails = GNE_Subscribe_Batch_Alignment.getHtmlReport(jobs.get(0).Comments_json_gne__c);
			}
		} catch(Exception e) {
			system.debug(e.getStackTraceString());
			system.debug(e.getMessage());
			territoryDetails = 'Cannot display report';
		}
		return territoryDetails;
	}
    
}