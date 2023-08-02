global class EDM_IABP_DrawLoop_Data implements Loop.IApexDataSource {

	public Set<String> getGlobalDescribe() {
		return new Set<String>{
			'IABPInfo',
			'IABPComments',
			'IABPPullThroughDocumentation',
			'IABPAgendaSummary'
		};
	}

	public Set<String> getChildRelationships(string objectName) {
		return new Set<String>();
	}

	public List<Loop.ExternalData.DataObject> describeObjects(List<string> objNames) {
		List<Loop.ExternalData.DataObject> output = new List<Loop.ExternalData.DataObject>();
		for (string objName : objNames) {
			List<Loop.ExternalData.FieldInfo> outputFields = new List<Loop.ExternalData.FieldInfo>();
			if (objName == 'IABPInfo') {
				outputFields.add(new Loop.ExternalData.FieldInfo('PrimaryABLeadName', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('SecondABLeadName', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('ThirdABLeadName', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('AdminName', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('PrimaryVendorName', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('SecondVendorName', Schema.DisplayType.STRING));
			} else if (objName == 'IABPComments') {
				outputFields.add(new Loop.ExternalData.FieldInfo('Section', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('CreatedBy', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('CreatedDate', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('EDM_Body_gne', Schema.DisplayType.STRING));
			} else if (objName == 'IABPPullThroughDocumentation') {
				outputFields.add(new Loop.ExternalData.FieldInfo('DocumentName', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('ResponsibleParty', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('EstimatedQuarter', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('Year', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('Group', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('DueDate', Schema.DisplayType.STRING));
			} else if (objName == 'IABPAgendaSummary') {
				outputFields.add(new Loop.ExternalData.FieldInfo('Date', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('PresentationTime', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('PresentationTimePercent', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('DiscussionTime', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('DiscussionTimePercent', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('TotalMeetingsTime', Schema.DisplayType.STRING));
			}
			output.add(new Loop.ExternalData.DataObject(objName, outputFields));
		}
		return output;
	}

	public Loop.ExternalData.QueryResultSet query(Loop.ExternalData.QueryRequestInfo requestInfo) {
		Loop.ExternalData.QueryResultSet results = new Loop.ExternalData.QueryResultSet();

		for (String objectName : requestInfo.GetObjectNames()) {
			if (objectName == 'IABPInfo') {
				results.add(getIABPInfo(objectName, requestInfo.RecordId));
			} else if (objectName == 'IABPComments') {
				results.add(getIABPComments(objectName, requestInfo.RecordId));
			} else if (objectName == 'IABPPullThroughDocumentation') {
				results.add(getIABPPullThroughDocumentation(objectName, requestInfo.RecordId));
			} else if (objectName == 'IABPAgendaSummary') {
				results.add(getIABPAgendaSummary(objectName, requestInfo.RecordId));
			}
		}

		return results;
	}

	private Loop.ExternalData.QueryResult getIABPInfo(String objectName, Id currentIABPId) {
		Loop.ExternalData.QueryResult results = new Loop.ExternalData.QueryResult(objectName, 
				new List<String> {'PrimaryABLeadName', 'SecondABLeadName', 'ThirdABLeadName', 'AdminName', 'PrimaryVendorName', 'SecondVendorName' });

		//without sharing to retrieve names for portal user EDM VDST Partner External ABM
		Map<String, String> plannerNames = EDM_ABM_Utils.getIABPNames(currentIABPId);
		results.rows.add(new List<String>{
				plannerNames.get('EDM_Primary_AB_Lead_gne__c'),
				plannerNames.get('EDM_Secondary_AB_Lead_gne__c'),
				plannerNames.get('EDM_Third_AB_Lead_gne__c'),
				plannerNames.get('EDM_Admin_gne__c'),
				plannerNames.get('EDM_Primary_Vendor_Lead_gne__c'),
				plannerNames.get('EDM_Second_Vendor_Lead_gne__c') });

		return results;
	}

	private Loop.ExternalData.QueryResult getIABPComments(String objectName, Id currentIABPId) {
		Loop.ExternalData.QueryResult results = new Loop.ExternalData.QueryResult(objectName, 
				new List<String> {'Section', 'CreatedBy', 'CreatedDate', 'EDM_Body_gne'});

		for (EDM_Comment_gne__c comment  : (new WithoutSharingQueryExecutor()).retrieveComments(currentIABPId)) {
			results.rows.add(new List<String>{
					comment.EDM_Section_gne__c,
					comment.CreatedBy.Name,
					comment.CreatedDate.format('M/dd/yyyy'),
					comment.EDM_Body_gne__c });
		}

		return results;
	}

	private Loop.ExternalData.QueryResult getIABPPullThroughDocumentation(String objectName, Id currentIABPId) {
		Loop.ExternalData.QueryResult results = new Loop.ExternalData.QueryResult(objectName, 
				new List<String> {'DocumentName', 'ResponsibleParty', 'EstimatedQuarter', 'Year', 'Group', 'DueDate'});

		for (EDM_Attachment_gne__c ptd  : (new WithoutSharingQueryExecutor()).getPullThroughDocumentation(currentIABPId)) {
			results.rows.add(new List<String>{
					ptd.EDM_Document_Name_gne__c,
					ptd.EDM_Responsible_Party_gne__r.Name,
					ptd.EDM_Estimated_Quarter_gne__c,
					ptd.EDM_Year_gne__c,
					ptd.EDM_Group_gne__c,
					String.valueOf(ptd.EDM_Due_Date_gne__c.format())});
		}

		return results;
	}

	private without sharing class WithoutSharingQueryExecutor {
		private List<EDM_Comment_gne__c> retrieveComments(Id currentIABPId) {
			return [SELECT Id, Name, CreatedById, CreatedDate, EDM_Body_gne__c, EDM_Parent_AABP_gne__c, 
							EDM_Parent_IABP_gne__c, EDM_Section_gne__c, EDM_Type_gne__c, CreatedBy.Name 
					FROM EDM_Comment_gne__c
					WHERE EDM_Parent_IABP_gne__c = :currentIABPId
					ORDER BY CreatedDate];
		}

		private List<EDM_Attachment_gne__c> getPullThroughDocumentation(Id currentIABPId) {
			EDM_IABP_gne__c exesum = [SELECT Id, EDM_ExeSum_Status_gne__c FROM EDM_IABP_gne__c WHERE Id = :currentIABPId];
			Boolean exesumFinalizedOrComplete = (exesum.EDM_ExeSum_Status_gne__c == 'Finalized' || exesum.EDM_ExeSum_Status_gne__c == 'Complete');
			String systemType = exesumFinalizedOrComplete ? 'PTD_Snapshot' : null;
			return [SELECT Id, EDM_Document_Name_gne__c, EDM_Responsible_Party_gne__r.Name, EDM_Estimated_Quarter_gne__c, EDM_Year_gne__c,
					EDM_Group_gne__c, EDM_Due_Date_gne__c
					FROM EDM_Attachment_gne__c 
					WHERE EDM_Parent_IABP_gne__c = :currentIABPId 
						AND EDM_Pull_Through_Doc_gne__c = true
						AND EDM_System_Type_gne__c = :systemType
					ORDER BY EDM_PreSnap_Attachment__r.CreatedDate, CreatedDate];
		}
	}

	private Loop.ExternalData.QueryResult getIABPAgendaSummary(String objectName, Id currentIABPId) {
		Loop.ExternalData.QueryResult results = new Loop.ExternalData.QueryResult(objectName, 
				new List<String> {'Date', 'PresentationTime', 'PresentationTimePercent', 'DiscussionTime', 'DiscussionTimePercent', 'TotalMeetingsTime'});

		EDM_IABP_AgendaSummary agendaSummary = new EDM_IABP_AgendaSummary(currentIABPId);

		for (EDM_IABP_AgendaSummary.AgendaSummaryItem item : agendaSummary.items) {
			results.rows.add(new List<String>{
					item.getSessionsDateFormated(),
					item.getPresentationTime(),
					item.getPresentationTimePercentage() + ' %',
					item.getDiscussionTime(),
					item.getDiscussionTimePercentage() + ' %',
					item.getTotalMeetingTime()});
		}

		return results;
	}
}