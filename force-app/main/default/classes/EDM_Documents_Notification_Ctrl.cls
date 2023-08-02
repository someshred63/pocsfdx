public with sharing class EDM_Documents_Notification_Ctrl {

	public String eventId { get; set; }
	public String recipientId { get; set; }
	public String tempName { get; set; }

	public List<EDM_Attachment_gne__c> getDocuments() {
		Date dt = System.today().addDays(28);
		String query = 'SELECT Id, EDM_Due_Date_gne__c, EDM_Revised_Due_Date_gne__c, EDM_Document_Name_gne__c, EDM_Resultant_Due_Date_gne__c FROM EDM_Attachment_gne__c ';
		query += 'WHERE EDM_Parent_IABP_gne__c = :eventId ';
		query += 'AND EDM_Pull_Through_Doc_gne__c = true ';
		if (tempName != 'Pull_Through_Documentation_Submitted' && String.isNotBlank(recipientId)) {
			query += 'AND EDM_Responsible_Party_gne__c = :recipientId ';
		}

		if (tempName == 'Action_Item_Assigned') {
			query += 'AND CreatedDate = YESTERDAY ';
		}				
		else if (tempName == 'Action_Item_Due') {
			query += 'AND EDM_Resultant_Due_Date_gne__c = :dt ';
			query += 'AND EDM_Upload_Date_gne__c = null ';
		}
		else if (tempName == 'Action_Item_Past_Due_Today') {
			query += 'AND EDM_Resultant_Due_Date_gne__c = TODAY ';
			query += 'AND EDM_Upload_Date_gne__c = null ';
		}
		else if (tempName == 'Action_Item_Past_Due') {
			query += 'AND Action_Item_Past_Due_Flag__c = true ';
			query += 'AND EDM_Upload_Date_gne__c = null ';
		}
		else if (tempName == 'Pull_Through_Documentation_Submitted') {
			query += 'AND EDM_Upload_Date_gne__c = TODAY ';
		}
		return (List<EDM_Attachment_gne__c>)Database.query(query);
	}

	public EDM_Documents_Notification_Ctrl() {}
}