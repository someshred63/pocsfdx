/* 
 * Staging_User_Assignments_Ctrl
 *
 * Created By :         Tomasz Kosecki (tomasz.kosecki@contractors.roche.com)
 * Last Modified By :   Tomasz Kosecki (tomasz.kosecki@contractors.roche.com)
 * Last Modified Date : 01/19/2017
 *
 * Comment:
 * - Controller for Staging_User_Assignments page
 * 
 */
public with sharing class Staging_User_Assignments_Ctrl {
	
	public Id batchProcessId {get; set;}
	private String status;
	private Integer recordCount;
	private Integer currentPercentProgress = 0;
	public String refreshStatus {get; set; }
	public Boolean showStatus { get; set; }
	private String jobStatus = '';

	public Staging_User_Assignments_Ctrl() {
		refreshShow();
	}

	public PageReference startAssignment() {
		refreshStatus = 'progress';
		batchProcessId = null;		
		currentPercentProgress = 0;
		recordCount = Database.countQuery('Select count() From Staging_User_Assignment_gne__c where Status_gne__c = \'Processed\' AND SFDC_User_gne__c <> null AND SFDC_UserTerritory_gne__c <> null');
		if (recordCount > 0) {
			Staging_User_Assignments_Batch batch = new Staging_User_Assignments_Batch(UserInfo.getSessionId(), UserInfo.getUserName());
			batchProcessId = Database.executeBatch(batch, 1);			
		} else {
			refreshStatus = 'done';
		}

		refreshShow();

		return null;
	}

	public PageReference calculateJobProgress() {
		if (batchProcessId != null) {
			AsyncApexJob job = [select TotalJobItems, JobItemsProcessed, Status from AsyncApexJob WHERE Id = :batchProcessId];
			if (job.TotalJobItems > 0) {
				currentPercentProgress = (Integer)((Double)job.JobItemsProcessed / (Double)job.TotalJobItems * 100);				
			} else {
				currentPercentProgress = 0;
			}
			if (job.Status == 'Completed' || job.Status == 'Aborted' || job.Status == 'Failed') {
				currentPercentProgress = 100;
				jobStatus = job.Status;
				refreshStatus = 'done';
			}
		}  else {
			currentPercentProgress = 100;
			refreshStatus = 'done';
		}

		refreshShow();

		return null;
	}

	public String getStatus() {
		String result = '';
		if (recordCount == 0) {
			return 'No records for processing';
		}
		if (batchProcessId == null) {
			return '';
		}
		if (currentPercentProgress < 100) {
			result = 'Assigning/Unassigning users ('+ recordCount + '), please wait... ' + (Integer)currentPercentProgress + '%';
		} else {
			result = 'Assigning/Unassigning users ' + (jobStatus == null ? 'completed.' : jobStatus.toLowerCase() + '.');			
			if (timeoutOccured()) {
				result += '<br/>Some of the assignments require long time processing and are performed in the background with ' +
				'unchanged status. Please rerun assignment process after some time to update assignment status.';
			}
		}
		
		return result;
	}

	private void refreshShow() {
		showStatus = String.isNotBlank(getStatus());
	}

	private Boolean timeoutOccured() {
		return Staging_User_Assignments_Batch.timeoutOccured(batchProcessId);
	}
}