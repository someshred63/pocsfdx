public with sharing class EDM_PTD_List_View_Controller {
	public Integer PULLTHROUGHDOCUMENTATION_LIMIT { get { return 50; } }

	private enum PageMode {SingleExeSum, All}
	private PageMode currentPageMode;
	public Boolean statusOfIABPisPTDComplete {get; set;}

	private ApexPages.StandardSetController ssc;
	public Id parentExeSumId {get; set;}
	public Id attachmentIdToUpload {get; set;}

	public EDM_Attachment_gne__c newPullThroughDocumentation {get; set;}
	public String PTDResponsiblePartyName { get; set; }
	public String PTDGroupName {get; set;}
	public String ptdAttIdToDelete {get; set;}

	//paging related variables
	public Integer recordsCount { get; set; }
	public Integer pageNumbers { get; set; }
	public Boolean maxRecordsReached { get; set; }

	private static Integer PAGE_SIZE = 50;
	private static Integer MAX_RECORDS_COUNT = 9999;

	public DueDateComment newDueDateComment { get; set; }

	public Map<String, List<EDM_Comment_gne__c>> commentsByParentId { get; set; }

	public String orderBy { get; set; }
	private String sortDirection { get; set; }

	public String filterBy { get; set; }

	public List<SelectOption> inputAbsReviewOldPicklist {get; private set;}
	public List<SelectOption> inputAbsReviewNewPicklist {get; private set;}

	public EDM_PTD_List_View_Controller() {
		newPullThroughDocumentation = new EDM_Attachment_gne__c();
		maxRecordsReached = false;

		pageNumbers = 1;
		recordsCount = 0;
	}

	public PageReference init() {
		parentExeSumId = ApexPages.currentPage().getParameters().get('parentExeSumId');
		orderBy = 'EDM_Due_Date_gne__c,CreatedDate';
		sortDirection = 'ASC NULLS LAST';
		filterBy = '';

		Id parentExeSumByIABPId = ApexPages.currentPage().getParameters().get('parentExeSumByIABPId');
		if (parentExeSumByIABPId != null) {
			List<EDM_IABP_gne__c> exeSumRecords = [
					SELECT Id 
					FROM EDM_IABP_gne__c 
					WHERE EDM_Executive_Summary_gne__c = true and
						EDM_Historical_gne__c = false AND
						EDM_Parent_IABP_gne__c = :parentExeSumByIABPId LIMIT 1];
			if (!exeSumRecords.isEmpty()) {
				parentExeSumId = exeSumRecords[0].Id;
			}
		}

		if (parentExeSumId == null) {
			currentPageMode = PageMode.All;
		} else {
			currentPageMode = PageMode.SingleExeSum;
		}

		retrievePTDs();

		setStatusOfIABPisPTDComplete();

		initCommentsHandling();

		inputAbsReviewOldPicklist = getInputAbsReviewOldPicklistValues();
		inputAbsReviewNewPicklist = getInputAbsReviewNewPicklistValues();

		return null;
	}

	private void initCommentsHandling() {
		commentsByParentId = populateCommentsByParentIdMap();
		newDueDateComment = new DueDateComment(commentsByParentId, ssc);
	}

	private void setStatusOfIABPisPTDComplete() {
		if (currentPageMode == PageMode.SingleExeSum) {
			EDM_IABP_gne__c exeSum = [
				SELECT EDM_Parent_IABP_gne__r.EDM_Status_gne__c 
				FROM EDM_IABP_gne__c 
				WHERE Id = :parentExeSumId LIMIT 1];
			statusOfIABPisPTDComplete = exeSum.EDM_Parent_IABP_gne__r.EDM_Status_gne__c == 'PTD complete';
		} else {
			statusOfIABPisPTDComplete = false;
		}
	}

	public PageReference retrievePTDs() {
		List<String> queryFieldList = new List<String> {
			'Id', 'Name', 'EDM_Group_gne__c', 'EDM_Responsible_Party_gne__c', 'EDM_Responsible_Party_gne__r.Name', 'EDM_Document_Name_gne__c', 'EDM_Due_Date_gne__c',
			'EDM_Link_gne__c', 'EDM_Upload_Date_gne__c', 'EDM_ABS_Review_Status_gne__c', 'EDM_Complete_gne__c', 'EDM_File_Name_gne__c',
			'EDM_Parent_IABP_gne__c', 'EDM_Parent_IABP_gne__r.Name', 'EDM_Parent_IABP_gne__r.EDM_Name_gne__c', 'EDM_Resultant_Due_Date_gne__c',
			'EDM_Parent_IABP_gne__r.EDM_Year_gne__c', 'EDM_Parent_IABP_gne__r.EDM_Parent_AABP_gne__r.EDM_Group_gne__c',
			'EDM_Parent_IABP_gne__r.EDM_Parent_AABP_gne__r.EDM_Unit_gne__c', 'EDM_Parent_IABP_gne__r.EDM_Parent_AABP_gne__r.EDM_Team_gne__c', 
			'EDM_Parent_IABP_gne__r.EDM_Parent_IABP_gne__r.EDM_Status_gne__c', 'EDM_Parent_IABP_gne__r.EDM_Drawloop_IABP_Name_gne__c',
            'EDM_Revised_Due_Date_gne__c',
			'(SELECT Id, EDM_Parent_Attachment_gne__c, EDM_Body_gne__c, CreatedBy.Name, CreatedDate FROM EDM_Comments__r ORDER BY CreatedDate ASC)',
			'(SELECT Id, Name, CreatedDate, CreatedById FROM Attachments)'
		};

		

		String query = 'SELECT ';
		query += String.join(queryFieldList, ', ');
		query += ' FROM EDM_Attachment_gne__c';
		query += ' WHERE EDM_Pull_Through_Doc_gne__c = true';
		query += ' AND EDM_System_Type_gne__c = null';
		query += ' AND EDM_Parent_IABP_gne__r.EDM_ExeSum_Finalized_gne__c != null';
		if (currentPageMode == PageMode.SingleExeSum) {
			query += ' and EDM_Parent_IABP_gne__c = \'' + parentExeSumId + '\'';
		} else {
			query += ' and EDM_Parent_IABP_gne__c IN (Select Id from EDM_IABP_gne__c WHERE EDM_Historical_gne__c = false)';
		}

		if (String.isNotBlank(filterBy)) {
			query += createFilterByClause();
		}

		query += ' ORDER BY ' + orderBy + ' ' + sortDirection;
		query += ' LIMIT ' + (MAX_RECORDS_COUNT + 1);

		ssc = new ApexPages.StandardSetController(Database.getQueryLocator(query));
		ssc.setPageSize(PAGE_SIZE);
		recordsCount = ssc.getResultSize();
		pageNumbers = countPageNumbers();

		maxRecordsReached = recordsCount > MAX_RECORDS_COUNT;
		return null;
	}

	private String createFilterByClause() {

		List<String> querySearchableFieldList = new List<String> {
			'Name', 'EDM_Responsible_Party_gne__r.Name', 'EDM_Document_Name_gne__c', 
			'EDM_ABS_Review_Status_gne__c', 'EDM_File_Name_gne__c',
			'EDM_Parent_IABP_gne__r.Name', 'EDM_Parent_IABP_gne__r.EDM_Name_gne__c',
			'EDM_Parent_IABP_gne__r.EDM_Year_gne__c', 'EDM_Parent_IABP_gne__r.EDM_Parent_AABP_gne__r.EDM_Group_gne__c',
			'EDM_Parent_IABP_gne__r.EDM_Parent_AABP_gne__r.EDM_Unit_gne__c', 'EDM_Parent_IABP_gne__r.EDM_Parent_AABP_gne__r.EDM_Team_gne__c', 
			'EDM_Parent_IABP_gne__r.EDM_Parent_IABP_gne__r.EDM_Status_gne__c', 'EDM_Parent_IABP_gne__r.EDM_Drawloop_IABP_Name_gne__c'
		};

		String result = ' AND ( ';
		result += String.join(querySearchableFieldList, ' LIKE \'%' + filterBy + '%\' OR ');
		result += ' LIKE \'%' + filterBy + '%\'';
		result += ' ) '; 
		return result;
	}

	private Map<String, List<EDM_Comment_gne__c>> populateCommentsByParentIdMap() {
		Map<String, List<EDM_Comment_gne__c>> result = new Map<String, List<EDM_Comment_gne__c>>();
		for (EDM_Attachment_gne__c item : getPTDs()) {
			if (!result.containsKey(item.Id)) {
				result.put(item.Id, new List<EDM_Comment_gne__c>());
			}
			result.get(item.Id).addAll(item.EDM_Comments__r);
		}
		return result;
	}

	public PageReference retrievePTDsAndStayOnTheSamePage() {
		Integer currentPageNumber = pageNumber;
		PageReference pageRef = retrievePTDs();
		ssc.setPageNumber(currentPageNumber);
		return pageRef;
	}
	
	public List<EDM_Attachment_gne__c> getPTDs() {
		retrievePTDsAndStayOnTheSamePage();		
		return (List<EDM_Attachment_gne__c>) ssc.getRecords();
	}

	public Boolean getIsAbsUser() {
		return EDM_ABM_Utils.hasPermissionSet(EDM_ABM_Utils.ABS);
	}

	public Boolean getIsAblUser() {
		return EDM_ABM_Utils.hasPermissionSet(EDM_ABM_Utils.ABLEAD);
	}

	public List<User> getABPlanners() {
		return EDM_ABM_Utils.getUsersForRoles(new List<String> {EDM_ABM_Utils.ABLEAD, EDM_ABM_Utils.VDST_ABM});
	}

	public List<String> getPTDGroups() {
		return new List<String>(EDM_ExeSum_Utils.getPTDGroupsBasedOnObjectives(parentExeSumId));
	}

	public Boolean getIsTabEntry() {		
		String retURL = System.currentPageReference().getParameters().get('retURL');
		return (retURL == null);
	}

	public Boolean getIsInSingleExeSumPageMode() {
		return currentPageMode == PageMode.SingleExeSum;
	}

	public PageReference setCtrlVariable() {
		//to set attachmentIdToUpload and parentExeSumId (need for All Page Mode) and
		ApexPages.getMessages().clear();
		return null;
	}

	public PageReference cancelPullThroughDocumentation() {
		newPullThroughDocumentation = new EDM_Attachment_gne__c();
		PTDResponsiblePartyName = null;
		PTDGroupName = null;
		return null;
	}

	public PageReference addPullThroughDocumentation() {
		savePage();

		newPullThroughDocumentation.EDM_Parent_IABP_gne__c = parentExeSumId;
		newPullThroughDocumentation.EDM_Pull_Through_Doc_gne__c = true;
		upsert newPullThroughDocumentation;

		newPullThroughDocumentation = new EDM_Attachment_gne__c();
		PTDResponsiblePartyName = null;
		PTDGroupName = null;

		retrievePTDs();
		initCommentsHandling();

		return null;
	}

	public PageReference delPullThroughDocument() {
		List<Attachment> attachmentList = [SELECT Id, ParentId FROM Attachment WHERE Id =: ptdAttIdToDelete];
		if(!attachmentList.isEmpty() && attachmentList.size() == 1) {
			delete attachmentList;
		}
		retrievePTDs();
		return null;
	}

	private static List<EDM_Attachment_gne__c> getPullThroughDocumentation(Id pId) {
		return [SELECT Id, EDM_Document_Name_gne__c, EDM_Group_gne__c, EDM_Responsible_Party_gne__c, EDM_Estimated_Quarter_gne__c, EDM_Year_gne__c
				FROM EDM_Attachment_gne__c 
				WHERE EDM_Parent_IABP_gne__c = :pId and EDM_Pull_Through_Doc_gne__c = true
				ORDER BY CreatedDate];
	}

	@RemoteAction
	public static Integer getPullThroughDocumentationCount(Id pId) { 
		return getPullThroughDocumentation(pId).size();
	}

	public PageReference savePage() {
		for (EDM_Attachment_gne__c ptd : (List<EDM_Attachment_gne__c>)ssc.getRecords()) {
			if (ptd.EDM_Complete_gne__c && String.isBlank(ptd.EDM_Link_gne__c)) {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Document must be uploaded before completing item.'));
				return null;
			}
		}
		Integer currentPageNumber = pageNumber;
		ssc.save();

		if(currentPageNumber != 1) {
			ssc.setPageNumber(currentPageNumber);
		}

		setStatusOfIABPisPTDComplete();
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'PTD has been saved.'));
		initCommentsHandling();
		return null;
	}

	public PageReference goBack() {
		PageReference pr;
		String retURL = System.currentPageReference().getParameters().get('retURL');

		if (retURL == null) {
			pr = new PageReference('/apex/EDM_PTD_List_View');
			pr.setRedirect(true);
		}
		else {
			pr = new PageReference(retURL);
			pr.setRedirect(true);
		}
		return pr;
	}

	public PageReference saveAndGoBack() {
		savePage();
		if (!ApexPages.hasMessages(ApexPages.Severity.ERROR)) {
			return goBack();
		}
		return null;
	}

	public Integer countPageNumbers(){
		return recordsCount == 0 ? 1 : Math.ceil(recordsCount / (PAGE_SIZE * 1.0)).intValue();
	}

	public Boolean hasNext {
		get {
			return ssc.getHasNext();
		}
		set;
	}

	public Boolean hasPrevious {
		get {
			return ssc.getHasPrevious();
		}
		set;
	}

	public Integer pageNumber {
		get {
			return ssc.getPageNumber();
		}
		set;
	}

	public void previousPage() {		
		ssc.previous();
		initCommentsHandling();
	}

	public void nextPage() {	
		ssc.next();
		initCommentsHandling();
	}

	public PageReference exportToExcel() {
		PageReference exportPR;
		if (currentPageMode == PageMode.All) {
			exportPR = new PageReference('/apex/EDM_PTD_List_View_Export?filterBy=' + filterBy);
			exportPR.setredirect(false);
		}
		else {
			exportPR = new PageReference('/apex/EDM_PTD_List_View_Export?parentExeSumId=' + parentExeSumId + '&filterBy=' + filterBy);
			exportPR.setredirect(false);
		}
		return exportPR;
	}

	public PageReference sortByColumn() {
		sortDirection = (sortDirection == 'ASC NULLS LAST' ? 'DESC NULLS FIRST' : 'ASC NULLS LAST');
		List<String> orderByColumns = new List<String>();
		if (String.isNotBLank(orderBy)) {
			orderByColumns = orderBy.split(',');
		}
		orderBy = (orderByColumns.size() > 1 ? String.join(orderByColumns, ' ' + sortDirection + ', ') : orderBy);
		PageReference pr = retrievePTDs();
		initCommentsHandling();
		return pr;
	}

	public PageReference filter() {
		PageReference pr = retrievePTDs();
		initCommentsHandling();
		return pr;
	}

	public class DueDateComment {
		public Id parentId { get; set; }
		public Date revisedDueDate { get; set; }
		public String comment { get; set; }
		private Map<String, List<EDM_Comment_gne__c>> commentsByParentId;
		private ApexPages.StandardSetController ssc;

		public DueDateComment(Map<String, List<EDM_Comment_gne__c>> commentsByParentId, ApexPages.StandardSetController ssc) {
			this.commentsByParentId = commentsByParentId;
			this.ssc = ssc;
		}

		public PageReference save() {
			if (String.isNotBlank(comment)) {
				insertNewComment();
			}			
			setRevisedDueDate();
			return null;
		}

		private void insertNewComment() {
			if (this.commentsByParentId != null && this.commentsByParentId.containsKey(parentId)) {

				EDM_Comment_gne__c newComment = new EDM_Comment_gne__c(EDM_Parent_Attachment_gne__c = parentId, EDM_Body_gne__c = comment);									
				insert newComment;

				newComment = refreshCommentToGetCreatedByAndDate(newComment);
				addNewCommentToMap(newComment);
			}
		}

		private void setRevisedDueDate() {
			for (EDM_Attachment_gne__c item : (List<EDM_Attachment_gne__c>)this.ssc.getRecords()) {
				if (item.Id == parentId) {
					item.EDM_Revised_Due_Date_gne__c = revisedDueDate;
					update item;
					break;
				}
			}
		}

		private EDM_Comment_gne__c refreshCommentToGetCreatedByAndDate(EDM_Comment_gne__c newComment) {
			if (newComment.Id != null) {
				newComment = [SELECT Id, EDM_Parent_Attachment_gne__c, EDM_Body_gne__c, CreatedBy.Name, CreatedDate FROM EDM_Comment_gne__c WHERE Id = :newComment.Id];
			}
			return newComment;
		}

		private void addNewCommentToMap(EDM_Comment_gne__c newComment) {
			List<EDM_Comment_gne__c> rowComments = this.commentsByParentId.get(parentId);
			if (rowComments != null) {
				commentsByParentId.get(parentId).add(newComment);	
			}
		}
	}

	private List<SelectOption> getInputAbsReviewOldPicklistValues() {
		Set<String> valuesToRemoveSet = new Set<String> {'Not Reviewed', 'Returned to ABL'};
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('', '--None--'));
		Schema.DescribeFieldResult fieldResult = EDM_Attachment_gne__c.EDM_ABS_Review_Status_gne__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry f : ple)
		{
			if(!valuesToRemoveSet.contains(f.getLabel())){
				options.add(new SelectOption(f.getLabel(), f.getValue()));
			}
		}
		return options;
	}

	private List<SelectOption> getInputAbsReviewNewPicklistValues() {
		Set<String> valuesToRemoveSet = new Set<String> {'Does Not Meet'};
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('', '--None--'));
		Schema.DescribeFieldResult fieldResult = EDM_Attachment_gne__c.EDM_ABS_Review_Status_gne__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry f : ple)
		{
			if(!valuesToRemoveSet.contains(f.getLabel())){
				options.add(new SelectOption(f.getLabel(), f.getValue()));
			}
		}
		return options;
	}
}