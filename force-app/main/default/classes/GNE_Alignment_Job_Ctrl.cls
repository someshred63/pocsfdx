public with sharing class GNE_Alignment_Job_Ctrl {
	private Alignment_Job_gne__c job;

	public GNE_Alignment_Job_Ctrl(ApexPages.StandardController stdController) {
        this.job = (Alignment_Job_gne__c)stdController.getRecord();
    }
	
	public PageReference customClone() {
		Alignment_Job_gne__c clonnedJob = new Alignment_Job_gne__c(name = job.Name, Status_gne__c = 'Loaded', Activation_Date_gne__c = job.Activation_Date_gne__c, ETL_LastSynch_gne__c = job.ETL_LastSynch_gne__c);
		insert clonnedJob;
		List<Staging_Alignment_gne__c> alignments = [SELECT Account_ID_gne__c, Activaction_Date_gne__c, MDM_Address_Id_gne__c, MDM_ID_gne__c, SFDC_Account_gne__c, SFDC_Address_gne__c, SFDC_Group_gne__c, SFDC_TSF_gne__c, Source_gne__c, Status_gne__c, Target_gne__c, Territory_Key_gne__c, Unalign_Date_gne__c, Zip_Code_gne__c FROM Staging_Alignment_gne__c WHERE Alignment_Job_gne__c = :job.Id];
		List<Staging_Alignment_gne__c> clonedAlignments = alignments.deepClone(false, false, false);
		for(Staging_Alignment_gne__c ca : clonedAlignments) {
			ca.Status_gne__c = 'Loaded';
			ca.Alignment_Job_gne__c = clonnedJob.Id;
		}
		insert clonedAlignments;
		PageReference jobPage = new ApexPages.StandardController(job).view();
        jobPage.setRedirect(true);
        return jobPage;
	}
    
}