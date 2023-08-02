public with sharing class EDM_ExeSum_Edit_Create_Ex extends GNE_SFA2_Dynamic_VF_Edit_Create {
	
	public Integer PULLTHROUGHDOCUMENTATION_LIMIT { get { return 50; } }

	public EDM_IABP_gne__c currentExeSum { get; set; }

	public String PrimaryABLeadName { get; set; }
	public String SecondABLeadName { get; set; }
	public String ThirdABLeadName { get; set; }
	public String AdminName { get; set; }
	public String PrimaryVendorName { get; set; }
	public String SecondVendorName { get; set; }
	public String AbsManagerName { get; set; }
	public List<SelectOption> LogisticVendors { get; set; }
	public List<SelectOption> ContentVendors { get; set; }

	public transient List<EDM_Objective_gne__c> objectives {get; set;}
	public List<EDM_Session_gne__c> sessions {get; set;}
	public String IABPGroup { get; set; }

	public Questionnaire absAuditData {get; set;}
	public Questionnaire absLiveMonitoring {get; set;}
	
	public EDM_Attachment_gne__c newPullThroughDocumentation {get; set;}
	public List<EDM_Attachment_gne__c> pullThroughDocuments {get; set;}
	public List<SelectOption> getYearsForNewPullThroughDoc() {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('', '--None--'));
		options.add(new SelectOption(String.valueOf(System.Today().year()), String.valueOf(System.Today().year())));
		options.add(new SelectOption(String.valueOf(System.Today().addYears(1).year()), String.valueOf(System.Today().addYears(1).year())));
		options.add(new SelectOption(String.valueOf(System.Today().addYears(2).year()), String.valueOf(System.Today().addYears(2).year())));
		return options;
	}
	public List<SelectOption> getYearsForEditedPullThroughDoc() {
		List<SelectOption> options = new List<SelectOption>();
		if(newPullThroughDocumentation.createdDate != null){
			options.add(new SelectOption('', '--None--'));
			options.add(new SelectOption(String.valueOf(newPullThroughDocumentation.createdDate.year()), String.valueOf(newPullThroughDocumentation.createdDate.year())));
			options.add(new SelectOption(String.valueOf(newPullThroughDocumentation.createdDate.addYears(1).year()), String.valueOf(newPullThroughDocumentation.createdDate.addYears(1).year())));
			options.add(new SelectOption(String.valueOf(newPullThroughDocumentation.createdDate.addYears(2).year()), String.valueOf(newPullThroughDocumentation.createdDate.addYears(2).year())));
		}
		return options;
	}
	public String PTDResponsiblePartyName { get; set; }
	public String PTDIdToRemove {get; set;}
	public String PTDIdToEdit {get; set;}
	public String PTDGroupName {get; set;}

	public transient List<EDM_Attachment_gne__c> agendaFromIABP {get; set;}

	private Boolean performRecordTypeCheck;

	private ParentIABP parentIABP;

	public Boolean downloadDocumentsStarted {get; set;}
	public String downloadDocumentId {get; set;}
	public String sessionIDForDrawLoop { get; private set; }
	public String blueTextValue {get; set; }
	public String blueTextSectionHeader { get; set; }

	public String UserRole { get; set; }
	public List<SelectOption> UsersToShareWith {
		get {
			List<SelectOption> selectOptions = new List<SelectOption>();
			List<User> availableUsers = EDM_ABM_Utils.getUsersToShareWith(UserRole);
			Set<Id> uSet = new Set<Id>();
			for (SelectOption so : UsersSharedWith) {
				uSet.add(so.getValue());
			}

			for (User u : availableUsers) {
				if (!uSet.contains(u.Id)) {
					selectOptions.add(new SelectOption(u.Id, u.Name));
				} 
			}
			return selectOptions;
		}

		set;
	}
	public List<SelectOption> UsersSharedWith { get; set; }

	public Map<String, String> BlueTexts { get; set; }

	public Boolean showAuditReminder { get; set; }

	public Id compareId { get; set; }

	public Boolean forceViewMode { get; private set; }

	private Map<String, Integer> rtFieldLengths;

	public EDM_ExeSum_Edit_Create_Ex(ApexPages.StandardController controller) {
		super(controller,'/apex/EDM_ExeSum_Edit_Create');
		newPullThroughDocumentation = new EDM_Attachment_gne__c();
		currentExeSum = (EDM_IABP_gne__c)controller.getRecord();

		showAuditReminder = false;

		rtFieldLengths = populateRtFieldLengths();
	}

	protected override void initController(ApexPages.StandardController controller) {
		super.initController(controller);
	}

	public override PageReference init() {
		ExecutiveSummary exeSum;
		String parentIABPId;

		forceViewMode = ApexPages.currentPage().getParameters().get('forceViewMode') == '1';

		if(controller.getRecord().Id == null) {
			
			parentIABPId = ApexPages.currentPage().getParameters().get('parentIABPId');
 
			if(parentIABPId != null) {
				exeSum = new ExecutiveSummary(parentIABPId);

				if (exeSum.alreadyExisiting()) {
					if(exeSum.getRecord().EDM_Status_gne__c == 'Event Occurred' && exeSum.getRecord().EDM_Parent_IABP_gne__r.EDM_Status_gne__c == 'Executive Summary in Progress') {
						this.pullThroughDocuments = getPullThroughDocumentation(exeSum.getRecord().Id, false);
						if(this.pullThroughDocuments.isEmpty()) {
							exeSum.createPullThroughDocuments();
						}
					}
					return redirectToExeSumRecord(exeSum.getRecord().Id);
				}
			} else {
				Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, 'IABP ID parameter were not passed.'));
			}
		}

		if (ApexPages.currentPage().getParameters().get('Id') == null) {
			if (exeSum != null && !exeSum.alreadyExisiting()) {

				if (!getIsABPlanner() && !getIsAbsUser()) {
					return GNE_SFA2_Util.redirectToAccessDeniedPage();
				}

				Id newExeSumId = exeSum.makeCloneFromIABP();
				exeSum.createPullThroughDocuments();
				if (newExeSumId == null) {
					return GNE_SFA2_Util.redirectToErrorPage('Record not found or Id parameter missing.', Apexpages.currentPage().getUrl(), '');
				}

				parentIABP = new ParentIABP(parentIABPId, null);
				parentIABP.changeStatus('Executive Summary in Progress');
				parentIABP.updateIABP();

				return redirectToExeSumRecord(newExeSumId);
			}
		}

		if (!currentExeSum.EDM_Executive_Summary_gne__c) {
			return GNE_SFA2_Util.redirectToErrorPage('This record is not Executive Summary', Apexpages.currentPage().getUrl(), '');
		}

		additionalQueryFields.addAll(new Set<String>{'EDM_Parent_IABP_gne__c', 'EDM_Executive_Summary_gne__c', 
			'EDM_ExeSum_Status_gne__c', 'EDM_ExeSum_Final_Agenda_Source_gne__c',
			'EDM_Primary_AB_Lead_gne__r.Name', 'EDM_Secondary_AB_Lead_gne__r.Name', 'EDM_Third_AB_Lead_gne__r.Name', 
			'EDM_Admin_gne__r.Name', 'EDM_Primary_Vendor_Lead_gne__r.Name', 'EDM_Second_Vendor_Lead_gne__r.Name',
			'EDM_Parent_AABP_gne__r.EDM_Group_gne__c', 'EDM_Parent_AABP_gne__c', 'EDM_Audit_Findings_gne__c', 'EDM_Est_nr_of_Other_Attendees_gne__c',
			'EDM_Actual_Nr_of_Advisors_gne__c', 'EDM_Actual_Nr_of_Gene_Reps_gne__c', 'EDM_Explanation_of_Att_Changes_gne__c',
			'EDM_Parent_IABP_gne__r.Name', 'EDM_Share_Comment_gne__c', 'EDM_MCS_Manager_gne__c', 'EDM_Parent_IABP_gne__r.EDM_End_Date_gne__c',
			'EDM_Strategic_Context_gne__c', 'EDM_ABS_to_Live_Monitor_gne__c','EDM_Event_Focus_gne__c','EDM_ABS_Manager_gne__r.Name'});

		if(Test.isRunningTest()) {
			additionalQueryFields.addAll(new Set<String>{ 'EDM_ExeSum_Submitted_gne__c', 'EDM_ExeSum_Finalized_gne__c' });
		}

		PageReference pageRef = super.init();
		if (pageRef == null) {
			currentExeSum = (EDM_IABP_gne__c)myObject;
			this.pullThroughDocuments = getPullThroughDocumentation();

			if (!getIsABPlanner() && !getIsAbsUser() && !getIsABApprover()) {
				return GNE_SFA2_Util.redirectToAccessDeniedPage();
			}

			parentIABP = new ParentIABP(currentExeSum.EDM_Parent_IABP_gne__c, getFieldsToSynchronizeToIABP());
			initAndRetrieveRelatedDataList();
			initUsersVariables();
			initIABPGroup();
			UserRole = EDM_ABM_Utils.getUserRole(UserInfo.getUserId());
			UsersSharedWith = EDM_ABM_Utils.populateSharedWith(currentExeSum.Id, UserRole);
			downloadDocumentId = currentExeSum.Id;

			if (currentExeSum.EDM_ExeSum_Final_Agenda_Source_gne__c == null) {
				currentExeSum.EDM_ExeSum_Final_Agenda_Source_gne__c = agendaFromIABP.size() > 0 ? 'IABP' : 'ExeSum';
			}

			LogisticVendors = new List<SelectOption>();
			LogisticVendors.add(new SelectOption('', '--None--'));
			for (VDST_EventProvider_gne__c ep : EDM_ABM_Utils.getLogisticVendors()) {
				LogisticVendors.add(new SelectOption(ep.VendorName_gne__c, ep.VendorName_gne__c));
			}

			ContentVendors = new List<SelectOption>();
			ContentVendors.add(new SelectOption('', '--None--'));
			for (VDST_EventProvider_gne__c ep : EDM_ABM_Utils.getContentVendors()) {
				ContentVendors.add(new SelectOption(ep.VendorName_gne__c, ep.VendorName_gne__c));
			}

			compareId = getSnapshotToCompareTo();
			
		}
		BlueTexts = EDM_IABP_Utils.getBlueTexts('ExeSum', 'Both');	

		return pageRef;
	}

	private PageReference redirectToExeSumRecord(Id exeSumId) {
		String retURL = System.currentPageReference().getParameters().get('retURL');
		String newURL = viewPage + '?id=' + exeSumId;
		if (forceViewMode) {
			newURL += '&forceViewMode=1';
		}
		if (String.isNotBlank(retURL)) {
			newURL += '&retURL=' + retURL;
		}

		PageReference pageRef = new PageReference(newURL);
		pageref.setredirect(true);
		return pageRef;
	}

	public Boolean getIsEditMode() {
		return EDM_ExeSum_Utils.isInEditMode(currentExeSum, forceViewMode);
	}

	private void initAndRetrieveRelatedDataList() {
		String parentIABPId;
		EDM_IABP_Utils.validateImgMarker(currentExeSum.Id, currentExeSum.EDM_Executive_Summary_gne__c);
		absAuditData = new Questionnaire(controller.getId(), 'ABS Audit');
		if (currentExeSum.EDM_ABS_to_Live_Monitor_gne__c) {
			absLiveMonitoring = new Questionnaire(controller.getId(), 'ABS Live Monitoring');
		}

		parentIABPId = currentExeSum.EDM_Parent_IABP_gne__c;

		
		sessions = retrieveSessions(currentExeSum.Id);
		populateTransientProperties();
	}

	private static List<EDM_Objective_gne__c> retrieveObjectives(Id exeSumId) {
		return [SELECT Id, EDM_Group_gne__c, EDM_Number_gne__c, EDM_Description_gne__c, EDM_Projected_Output_gne__c
				FROM EDM_Objective_gne__c 
				WHERE EDM_Parent_IABP_gne__c = :exeSumId
				ORDER BY EDM_Group_gne__c, EDM_Number_gne__c];
	}

	private static List<EDM_Session_gne__c> retrieveSessions(Id exeSumId) {
		return [SELECT Id, EDM_Title_gne__c, EDM_Information_Gained_gne__c,
				EDM_Session_Objectives_gne__c, EDM_Advisory_Board_Question_gne__c
				FROM EDM_Session_gne__c 
				WHERE EDM_Parent_IABP_gne__c = :exeSumId AND EDM_Is_Break_gne__c = false
				ORDER BY CreatedDate];
	}

	private static List<EDM_Session_gne__c> retrieveSessionsForClone(Id exeSumId) {
		return [SELECT Id, EDM_Description_gne__c, EDM_Discussion_End_Time_gne__c, EDM_Discussion_Start_Time_gne__c, 
						EDM_Information_Gained_gne__c, EDM_Is_Break_gne__c, EDM_No_Discussion_gne__c, EDM_No_Presentation_gne__c, 
						EDM_Parent_IABP_gne__c, EDM_Presentation_End_Time_gne__c, EDM_Presentation_Start_Time_gne__c, EDM_Presenter_gne__c, 
						EDM_Sort_Field_for_DDP_gne__c, EDM_Title_gne__c,
						EDM_Session_Objectives_gne__c, EDM_Session_Date_gne__c
				FROM EDM_Session_gne__c 
				WHERE EDM_Parent_IABP_gne__c = :exeSumId
				ORDER BY CreatedDate];
	}

	private static List<EDM_ABS_Comment_gne__c> retrieveABSCommentsForClone(Id exeSumId) {
		return [SELECT CreatedDate, CreatedById, ABS_Comment_gne__c, EDM_Attachment_gne__c, EDM_Parent_ABS_Comment_gne__c
		FROM EDM_ABS_Comment_gne__c
		WHERE EDM_Parent_IABP_gne__c = :exeSumId
		ORDER BY CreatedDate];
	}

	public List<EDM_Attachment_gne__c> getPullThroughDocumentation() {
		this.pullThroughDocuments = getPullThroughDocumentation(currentExeSum.Id, getIsFinalizedOrComplete());
		return this.pullThroughDocuments;
	}

	private static List<EDM_Attachment_gne__c> getPullThroughDocumentation(Id pId, Boolean isFinalizedOrComplete) {
		String ptdQuery = 'SELECT Id, EDM_Document_Name_gne__c, EDM_Responsible_Party_gne__c, EDM_Responsible_Party_gne__r.Name, EDM_Parent_IABP_gne__c, EDM_Estimated_Quarter_gne__c, EDM_Year_gne__c, EDM_Due_Date_gne__c, EDM_Group_gne__c, EDM_Complete_gne__c';
		ptdQuery +=		 	' FROM EDM_Attachment_gne__c ';
		ptdQuery +=			' WHERE EDM_Parent_IABP_gne__c = :pId AND EDM_Pull_Through_Doc_gne__c = true ';
		if (isFinalizedOrComplete) {
			ptdQuery += ' AND EDM_System_Type_gne__c = \'PTD_Snapshot\'';
			ptdQuery += ' ORDER BY EDM_PreSnap_Attachment__r.CreatedDate';
		}
		else {
			ptdQuery += ' AND EDM_System_Type_gne__c = null';
			ptdQuery += ' ORDER BY CreatedDate';
		}
		
		return (List<EDM_Attachment_gne__c>)Database.query(ptdQuery);
	}

	@RemoteAction
	public static Integer getPullThroughDocumentationCount(Id pId, Boolean isFinalizedOrComplete) { 
		return getPullThroughDocumentation(pId, isFinalizedOrComplete).size();
	}

	public String getExeSumTitle() {
		String title = 'Update ExeSum';

		if (forceViewMode) {
			title = 'View ExeSum';
		} else if (getIsInReviewStage()) {
			title = 'Review ExeSum';
		} else if (getIsFinalizedOrComplete()) {
			title = 'View ExeSum';
		}
		
		return title;
	}

	private void initUsersVariables() {
		Map<String, String> plannerNames = EDM_ABM_Utils.getIABPNames(currentExeSum.Id);
		PrimaryABLeadName = plannerNames.get('EDM_Primary_AB_Lead_gne__c');
		SecondABLeadName = plannerNames.get('EDM_Secondary_AB_Lead_gne__c');
		ThirdABLeadName = plannerNames.get('EDM_Third_AB_Lead_gne__c');
		AdminName = plannerNames.get('EDM_Admin_gne__c');
		PrimaryVendorName = plannerNames.get('EDM_Primary_Vendor_Lead_gne__c');
		SecondVendorName = plannerNames.get('EDM_Second_Vendor_Lead_gne__c');
		AbsManagerName = plannerNames.get('EDM_ABS_Manager_gne__c');
	}

	public Boolean getIsFinalized() {
		return currentExeSum.EDM_ExeSum_Status_gne__c == 'Finalized';
	}

	public Boolean getIsComplete() {
		return currentExeSum.EDM_ExeSum_Status_gne__c == 'Complete';
	}

	public Boolean getIsFinalizedOrComplete() {
		return currentExeSum.EDM_ExeSum_Status_gne__c == 'Finalized' || currentExeSum.EDM_ExeSum_Status_gne__c == 'Complete';
	}

	public Boolean getIsInUpdateExeSumStage() {
		return EDM_ExeSum_Utils.isInUpdateExeSumStage(currentExeSum);
	}

	public Boolean getIsInReviewStage() {
		return EDM_ExeSum_Utils.isInReviewExeSumStage(currentExeSum);
	}

	public override PageReference save() {		
		if (anyRTFieldSizeExceeded()) {
			return null;
		}
		Database.SaveResult[] saveResults = Database.update(this.pullThroughDocuments, false);
		saveFinalAgenda();

		if (currentExeSum.EDM_ExeSum_Status_gne__c == 'Not Started') {
			currentExeSum.EDM_ExeSum_Status_gne__c = 'Started';
		} else if (getIsFinalized() && absAuditData.isAllAnswered() &&
				(!currentExeSum.EDM_ABS_to_Live_Monitor_gne__c || absLiveMonitoring.isAllAnswered())) {
			currentExeSum.EDM_ExeSum_Status_gne__c = 'Complete';
			showAuditReminder = false;
		}

		
		if (!Apexpages.hasMessages(ApexPages.Severity.ERROR)) {
			update sessions;
			absAuditData.save(currentExeSum.Id);
			if (currentExeSum.EDM_ABS_to_Live_Monitor_gne__c) {
				absLiveMonitoring.save(currentExeSum.Id);
			}

			parentIABP.synchronizeToIABPFrom(currentExeSum);
			parentIABP.updateIABP();
			update currentExeSum;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Executive Summary has been saved.'));
		}
		this.pullThroughDocuments = getPullThroughDocumentation();
		populateTransientProperties();
		return null;//redirectToExeSumRecord(currentExeSum.Id);
	}

	public PageReference saveAndGoBack() {
		save();
		if (!Apexpages.hasMessages(ApexPages.Severity.ERROR)) {
			return goBack();
		}
		return null;
	}

	private void saveFinalAgenda() {
		if (currentExeSum.EDM_ExeSum_Final_Agenda_Source_gne__c == 'IABP') {
			EDM_AddAttachment_Ctrl.removeExeSumFinalAgendaFor(currentExeSum.Id);
		}
	}

	public PageReference submitToAbs() {
		return submitToAbs(true);
	}

	public PageReference forceSubmitToAbs() {
		return submitToAbs(false);
	}

	private PageReference submitToAbs(Boolean validate) {
		if(!validatePullThroughDocumentation()) {
			return null;
		}

		currentExeSum.EDM_ExeSum_Status_gne__c = 'In Review';
		parentIABP.changeStatus('Executive Summary in Review');

		if (currentExeSum.EDM_ExeSum_Submitted_gne__c == null) {
			currentExeSum.EDM_ExeSum_Submitted_gne__c = System.today();
		}
		
		save();
		Database.SaveResult[] saveResults = Database.update(this.pullThroughDocuments, false);
		if (!Apexpages.hasMessages(ApexPages.Severity.ERROR)) {
			return goBack();
		}
		return null;
	}

	private Boolean validatePullThroughDocumentation() {
		if(getIsInUpdateExeSumStage() && this.pullThroughDocuments.size() == 0 && (IABPGroup != 'gRED' && IABPGroup != 'PD')) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'At least one document is required in Pull Through Documentation.'));
			return false;
		}
		return true;
	}
	
	public PageReference finalizeExecutiveSummary() {
		populateTransientProperties();

		currentExeSum.EDM_ExeSum_Status_gne__c = 'Finalized';
		currentExeSum.EDM_ExeSum_Finalized_gne__c = System.today();
		EDM_ABM_Utils.removeAllComments(currentExeSum.Id);
		if(getPullThroughDocumentation(currentExeSum.Id, false).isEmpty() && (currentExeSum.EDM_Parent_AABP_gne__r.EDM_Group_gne__c == 'gRED' || currentExeSum.EDM_Parent_AABP_gne__r.EDM_Group_gne__c == 'PD')) {
            parentIABP.changeStatus('PTD complete');
        } else {
		parentIABP.changeStatus('PTD in Progress');
        }
		showAuditReminder =  true;

		return save();
	}

	private void populateTransientProperties() {
		objectives = retrieveObjectives(currentExeSum.Id);
		agendaFromIABP = getAgendaFromIABP(currentExeSum.EDM_Parent_IABP_gne__c);
	}

	public PageReference returnToABLead() {
		currentExeSum.EDM_ExeSum_Status_gne__c = 'Started';
		parentIABP.changeStatus('Executive Summary in Progress');
		save();
		if (!Apexpages.hasMessages(ApexPages.Severity.ERROR)) {
			return goBack();
		}
		return null;
	}

	public PageReference goBack() {
		PageReference pr;
		String retURL = System.currentPageReference().getParameters().get('retURL');

		if (retURL == null) {
			pr = new PageReference('/apex/EDM_AABP_Layout?id=' + currentExeSum.EDM_Parent_AABP_gne__c);
			pr.setRedirect(true);
		}
		else {
			pr = new PageReference(retURL);
			pr.setRedirect(true);
		}
		return pr;
	}

	public PageReference updateAndRedirectToDocuments() {
		save();
		if (!ApexPages.hasMessages(ApexPages.Severity.ERROR)) {
			return redirectToDocuments();
		}
		return null;
	}

	public PageReference redirectToDocuments() {
		String retURL = System.currentPageReference().getParameters().get('retURL');
		String prevRetURL = retURL == null ? '' : '&prevRetURL=' + retURL;
		PageReference pr = new PageReference('/apex/EDM_Attendees_Documents?parentId=' + currentExeSum.Id + '&retURL=/apex/EDM_ExeSum_Edit_Create?id=' + currentExeSum.Id + prevRetURL);
		pr.setAnchor('doc');
		pr.setRedirect(true);
		return pr;
	}

	public PageReference viewDocuments(){
		String retURL = System.currentPageReference().getParameters().get('retURL');
		String prevRetURL = retURL == null ? '' : '&prevRetURL=' + retURL;
		String forceViewModeStr = '&forceViewMode=1';
		PageReference pr = new PageReference('/apex/EDM_Attendees_Documents?parentId=' + currentExeSum.Id + forceViewModeStr + '&retURL=/apex/EDM_ExeSum_Edit_Create?id=' + currentExeSum.Id + prevRetURL);
		pr.setAnchor('doc');
		pr.setRedirect(true);
		return pr;
	}

	public PageReference shareExeSum() {
		if (currentExeSum != null && currentExeSum.Id != null) {
			Set<Id> uIdList = new Set<Id>();
			for (SelectOption so : UsersSharedWith) {
				uIdList.add(so.getValue());
			}
			EDM_ABM_Utils.setSharing(currentExeSum.Id, uIdList, UserRole);
			EDM_ABM_Utils.setSharing(currentExeSum.EDM_Parent_IABP_gne__c, uIdList, UserRole);
		}
		
		return null;
	}

	public PageReference delPullThroughDocumentation() {
		//delete [SELECT Id FROM EDM_Attachment_gne__c WHERE id = :PTDIdToRemove];
		try {
			EDM_ABM_Utils.deleteAttachement(PTDIdToRemove);
			this.pullThroughDocuments = getPullThroughDocumentation();
		}
		catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Could not delete document! ' + ex.getMessage()));
		}
		return null;
	}

	public PageReference editPullThroughDocumentation() {
		newPullThroughDocumentation = [SELECT Id, EDM_Document_Name_gne__c, EDM_Responsible_Party_gne__c, EDM_Responsible_Party_gne__r.Name, EDM_Estimated_Quarter_gne__c, EDM_Year_gne__c, createdDate
				FROM EDM_Attachment_gne__c 
				WHERE id = :PTDIdToEdit LIMIT 1];
		PTDResponsiblePartyName = newPullThroughDocumentation.EDM_Responsible_Party_gne__r.Name;
		return null;
	}

	public PageReference cancelPullThroughDocumentation() {
		newPullThroughDocumentation = new EDM_Attachment_gne__c();
		PTDResponsiblePartyName = null;
		PTDGroupName = null;
		return null;
	}

	public PageReference addPullThroughDocumentation() {
		newPullThroughDocumentation.EDM_Parent_IABP_gne__c = currentExeSum.Id;
		newPullThroughDocumentation.EDM_Pull_Through_Doc_gne__c = true;
		if(currentExeSum.EDM_Parent_IABP_gne__r.EDM_End_Date_gne__c != null)
			newPullThroughDocumentation.EDM_Due_Date_gne__c = currentExeSum.EDM_Parent_IABP_gne__r.EDM_End_Date_gne__c + 180;
		if (newPullThroughDocumentation.EDM_ID_For_Comparator_gne__c == null) {
			newPullThroughDocumentation.EDM_ID_For_Comparator_gne__c = currentExeSum.Name + '_' + EDM_ABM_Utils.getRandomID();
		}
		upsert newPullThroughDocumentation;
		newPullThroughDocumentation = new EDM_Attachment_gne__c();
		PTDResponsiblePartyName = null;
		PTDGroupName = null;
		this.pullThroughDocuments = getPullThroughDocumentation();
		return null;
	}

	private Date getPullThroughDocumentationDueDate(String year, String quarter) {
		Map<String, Integer> quarterMonth = new Map<String, Integer> {
			'Q1' => 3, 'Q2' => 6, 'Q3' => 9, 'Q4' => 12}; 
		Map<String, Integer> quarterDay = new Map<String, Integer> {
			'Q1' => 31, 'Q2' => 30, 'Q3' => 30, 'Q4' => 31}; 
		return Date.newInstance(Integer.valueof(year), quarterMonth.get(quarter), quarterDay.get(quarter));
	}

	private class ExecutiveSummary {
		private EDM_IABP_gne__c exeSumRecord;
		private Id parentId;

		public ExecutiveSummary(Id parentId) {
			this.parentId = parentId;
			retrieveExisitngExeSumByParentId();
		}

		private void retrieveExisitngExeSumByParentId() {
			List<EDM_IABP_gne__c> exeSumRecords = [
					SELECT Id, EDM_Parent_IABP_gne__c, EDM_End_Date_gne__c, EDM_Status_gne__c, EDM_Parent_IABP_gne__r.EDM_Status_gne__c
					FROM EDM_IABP_gne__c 
					WHERE EDM_Executive_Summary_gne__c = true AND
						EDM_Historical_gne__c = false AND
						EDM_Parent_IABP_gne__c = :parentId LIMIT 1];
			if (!exeSumRecords.isEmpty()) {
				exeSumRecord = exeSumRecords[0];
			}
		}

		public EDM_IABP_gne__c getRecord() {
			return exeSumRecord;
		}

		public Boolean alreadyExisiting() {
			return exeSumRecord != null && exeSumRecord.Id != null;
		}

		public Id makeCloneFromIABP() {
			if (cloneExeSumFromIABP()) {
				EDM_ABM_Utils.dupliacateSharings(parentId, exeSumRecord.Id);
				makeCloneOfAttendees();
				makeCloneOfObjectives();
				makeCloneOfSessions();
				makeCloneOfABSComments();
				convertQuestionsToSessionsForiAdvise();
				return exeSumRecord.Id;
			}
			return null;
		}

		private Boolean cloneExeSumFromIABP() {
			exeSumRecord = retrieveParentIABP(parentId);
			if (exeSumRecord != null) {
				exeSumRecord = exeSumRecord.clone(false, false);
				exeSumRecord.EDM_Parent_IABP_gne__c = parentId;
				exeSumRecord.EDM_Executive_Summary_gne__c = true;
				exeSumRecord.EDM_Type_for_Doc_gne__c = exeSumRecord.EDM_Meeting_Approach_gne__c == 'iAdvise' ? 'iAdvise ExeSum' : 'ExeSum';
				Id recTypeId = Schema.SObjectType.EDM_IABP_gne__c.getRecordTypeInfosByName().get('ExeSum').getRecordTypeId();
				exeSumRecord.RecordTypeId = recTypeId;

				exeSumRecord.ownerId = UserInfo.getUserId();

				insert exeSumRecord;
				return true;
			}
			return false;
		}

		private EDM_IABP_gne__c retrieveParentIABP(Id parentId) {
			String queryString = EDM_ABM_Utils.getCreatableFieldsSOQL('EDM_IABP_gne__c', parentId);
			
			List<EDM_IABP_gne__c> results = Database.query(queryString);
			return results.isEmpty() ? null : results.get(0);
		}

		private void makeCloneOfAttendees() {
			List<EDM_Attendee_gne__c> attendees = retrieveAttendeesFromIABP();

			List<EDM_Attendee_gne__c> copyAttendeesOnExeSum = attendees.deepClone();

			for (Integer i = 0; i < copyAttendeesOnExeSum.size(); i++) {
				copyAttendeesOnExeSum.get(i).EDM_Parent_IABP_gne__c = exeSumRecord.Id;
				copyAttendeesOnExeSum.get(i).EDM_Parent_Attendee_gne__c = attendees.get(i).Id;
			}

			insert copyAttendeesOnExeSum;
		}

		private List<EDM_Attendee_gne__c> retrieveAttendeesFromIABP() {
			return [SELECT Id, Name, EDM_Account_gne__c, EDM_Business_Classification_gne__c, EDM_Clinical_Classification_gne__c, 
						EDM_Contact_gne__c, EDM_Exclusion_Status_gne__c, EDM_Country_gne__c, EDM_Observer_gne__c,
						EDM_Name_gne__c, EDM_Role_gne__c, Originate_from_ExeSum_gne__c,
						EDM_System_Type_gne__c, is_deleted_gne__c, EDM_Parent_IABP_gne__c, EDM_Type_gne__c, 
						EDM_First_Name_gne__c, EDM_Last_Name_gne__c, EDM_Purpose_gne__c, EDM_Is_Cross_Functional_gne__c, EDM_Company_gne__c,
						EDM_Current_Business_Classification_gne__c, EDM_Current_Business_Class_Role_gne__c, EDM_Current_Clinical_Classification_gne__c,
                        EDM_Current_Exclusion_Status_gne__c, EDM_Current_Business_Classif_Date_gne__c,
                        EDM_Current_Clinical_Classif_Date_gne__c, EDM_Current_Exclusion_Checked_Date_gne__c,
                        EDM_Current_Clinical_Specialties_gne__c
				FROM EDM_Attendee_gne__c
				WHERE EDM_Parent_IABP_gne__c = :parentId and
				EDM_System_Type_gne__c in (
						:EDM_IABP_Utils.AttendeeSystemType.Genentech.name(),
						:EDM_IABP_Utils.AttendeeSystemType.Advisor.name(),
						:EDM_IABP_Utils.AttendeeSystemType.Other.name(),
						:EDM_IABP_Utils.AttendeeSystemType.NonUSAdvisor.name())
				ORDER BY CreatedDate];
		}

		private void makeCloneOfObjectives() {
			List<EDM_Objective_gne__c> objectives = EDM_ExeSum_Edit_Create_Ex.retrieveObjectives(parentId);
			objectives = objectives.deepClone();

			for (EDM_Objective_gne__c objective : objectives) {
				objective.EDM_Parent_IABP_gne__c = exeSumRecord.Id;
			}

			insert objectives;
		}

		private void makeCloneOfSessions() {
			List<EDM_Session_gne__c> sessions = EDM_ExeSum_Edit_Create_Ex.retrieveSessionsForClone(parentId);
			sessions = sessions.deepClone();

			for (EDM_Session_gne__c session : sessions) {
				session.EDM_Parent_IABP_gne__c = exeSumRecord.Id;
			}

			insert sessions;
		}

		private void makeCloneOfABSComments() {
			List<EDM_ABS_Comment_gne__c> absComments = retrieveABSCommentsForClone(parentId);

			for (EDM_ABS_Comment_gne__c absComment : absComments) {
				absComment.Id = null;
				absComment.EDM_Parent_IABP_gne__c = exeSumRecord.Id;
				absComment.EDM_Date_Added_gne__c = absComment.CreatedDate;
				absComment.CreatedDate = null;
			}

			insert absComments;
		}

		private void convertQuestionsToSessionsForiAdvise() {
			if (exeSumRecord.EDM_Meeting_Approach_gne__c == 'iAdvise') {
				List<EDM_Session_gne__c> sessionsToInsert = new List<EDM_Session_gne__c>();
				List<EDM_IABP_Utils.ABQuestionsWrapper> ABQuestions = EDM_IABP_Utils.poplateABQuestions(parentId);

				for (EDM_IABP_Utils.ABQuestionsWrapper question : ABQuestions) {
					sessionsToInsert.add(
							new EDM_Session_gne__c(
								EDM_Parent_IABP_gne__c = exeSumRecord.Id,
								EDM_Advisory_Board_Question_gne__c = question.Question.EDM_Value_gne__c,
								EDM_Is_Break_gne__c = false));
				}

				if (!sessionsToInsert.isEmpty()) {
					insert sessionsToInsert;
				}
			}
		}

		public void createPullThroughDocuments() {
			if(String.isNotBlank(exeSumRecord.Id) && String.isNotBlank(exeSumRecord.EDM_Parent_IABP_gne__c)) {

				EDM_IABP_gne__c parentIABP = getParentIABPB(exeSumRecord.EDM_Parent_IABP_gne__c);
				List<String> teams = new List<String>();

				if(parentIABP.EDM_Group_gne__c == 'PD' || parentIABP.EDM_Group_gne__c == 'gRED') {
					teams = parentIABP.EDM_Team_gne__c.split(';');
				}

				Set<String> aabpGroupsToCreatePtdDocs = new Set<String> {
						'Commercial', 'Miscellaneous', 'USMA', 'CMG'
				};

				if((aabpGroupsToCreatePtdDocs.contains(parentIABP.EDM_Group_gne__c)) || ((parentIABP.EDM_Group_gne__c == 'PD' || parentIABP.EDM_Group_gne__c == 'gRED') && teams.size() > 1)) {
                List<EDM_Attachment_gne__c > ptdListToInsert = new List<EDM_Attachment_gne__c >();
					Set<String> pullThroughDocsGroupsBasedOnadvisoryBoardObjectiveGroups = EDM_ExeSum_Utils.getPTDGroupsBasedOnObjectives(exeSumRecord.EDM_Parent_IABP_gne__c);
                for(String grp : pullThroughDocsGroupsBasedOnadvisoryBoardObjectiveGroups) {
                    ptdListToInsert.add(new EDM_Attachment_gne__c (
								EDM_Parent_IABP_gne__c = exeSumRecord.Id , EDM_Pull_Through_Doc_gne__c = true,
								EDM_Group_gne__c = grp, EDM_Due_Date_gne__c = getDueDateBasedOnEndDate()
                    ));
                }
                if(!ptdListToInsert.isEmpty()) {
                    insert ptdListToInsert;
                }
            }
		}
	}

		private EDM_IABP_gne__c getParentIABPB(String parentIabpId) {
			List<EDM_IABP_gne__c> iabpList = [Select Id, EDM_Group_gne__c, EDM_Team_gne__c
			From EDM_IABP_gne__c Where Id=: parentIabpId];
			return iabpList.size() == 1 ? iabpList.get(0) : null;
		}

		private Date getEndDateValueFromExeSum() {
			return exeSumRecord.EDM_End_Date_gne__c != null ? exeSumRecord.EDM_End_Date_gne__c : null;
		}

		private Date getDueDateBasedOnEndDate() {
			return getEndDateValueFromExeSum() + 180;
		}
	}


	public class Questionnaire {
		private String typeOfQuestions;
		public List<EDM_Response_gne__c> responses {get; set;}

		public List<SelectOption> possibleAnswer {
			get {
				List<SelectOption> options = new List<SelectOption>();
				if (typeOfQuestions == 'ABS Audit' || typeOfQuestions == 'ABS Live Monitoring') {
					options.add(new SelectOption('','--None--'));
					options.add(new SelectOption('Yes','Yes'));
					options.add(new SelectOption('No','No'));
				}
				if (typeOfQuestions == 'Feedback Responses') {
					options.add(new SelectOption('','--None--'));
					for (Decimal d = 7.0; d >= 1.0; d-= 0.1) {
						options.add(
							new SelectOption(
									String.valueOf(d), 
									String.valueOf(d)
									)
							);
					}
					options.add(new SelectOption('n/a','n/a'));
				}
				return options;
			}
		}

		public Questionnaire(Id exeSumId, String typeOfQuestions) {
			this.typeOfQuestions = typeOfQuestions;

			if (exeSumId != null) {
				responses = [
						SELECT Id, EDM_Question_gne__c, EDM_Question_Text_gne__c, EDM_Parent_Exe_Summary_gne__c, EDM_Response_gne__c, EDM_ID_For_Comparator_gne__c
						FROM EDM_Response_gne__c
						WHERE EDM_Parent_Exe_Summary_gne__c = :exeSumId and
							EDM_Question_gne__r.EDM_Type_gne__c = :typeOfQuestions
						ORDER BY EDM_Question_gne__r.EDM_Order_gne__c];
			} else {
				responses = new List<EDM_Response_gne__c>();
			}

			if (responses.isEmpty()) {
				updateListofQuestions(exeSumId, typeOfQuestions);
			}
		}

		private void updateListofQuestions(Id exeSumId, String typeOfQuestions) {
			Set<Id> existingQuestions = new Set<Id>();

			for (EDM_Response_gne__c response : responses) {
				existingQuestions.add(response.EDM_Question_gne__c);
			}
			List<EDM_Question_gne__c> questions = [
					SELECT Id, EDM_Value_gne__c 
					FROM EDM_Question_gne__c
					WHERE (EDM_Parent_Exe_Summary_gne__c = null or EDM_Parent_Exe_Summary_gne__c = :exeSumId) and 
						EDM_Type_gne__c = :typeOfQuestions and
						Id not in :existingQuestions
					ORDER BY EDM_Order_gne__c];

			for (EDM_Question_gne__c question : questions) {
				responses.add(
					new EDM_Response_gne__c (
						EDM_Question_gne__c = question.Id,
						EDM_Question_Text_gne__c = question.EDM_Value_gne__c,
						EDM_ID_For_Comparator_gne__c = exeSumId + '_' + EDM_ABM_Utils.getRandomID())
				);
			}
		}

		public Boolean isAllAnswered() {
			for (EDM_Response_gne__c response : responses) {
				if (String.isBlank(response.EDM_Response_gne__c)) {
					return false;
				}
			}
			return true;
		}

		public void save(Id exeSumId) {
			for (EDM_Response_gne__c response : responses) {
				if (response.EDM_Parent_Exe_Summary_gne__c == null) {
					response.EDM_Parent_Exe_Summary_gne__c = exeSumId;					
				}

				if (response.EDM_ID_For_Comparator_gne__c == null) {
					response.EDM_ID_For_Comparator_gne__c = exeSumId + '_' + EDM_ABM_Utils.getRandomID();
				}				
			}
			upsert responses;
		}
	}

	public EDM_Attachment_gne__c getFinalAgendaAttach() {
		return EDM_ExeSum_Utils.getFinalAgendaAttach(currentExeSum.Id);
	}

	private List<EDM_Attachment_gne__c> getAgendaFromIABP(String parentIABPId) {
		return EDM_ExeSum_Utils.getAgendaFromIABP(parentIABPId);
	}

	public Boolean getIsAbsUser() {
		return EDM_ABM_Utils.hasPermissionSet(EDM_ABM_Utils.ABS);
	}

	public Boolean getIsABPlanner() {
		return EDM_ABM_Utils.hasPermissionSet(EDM_ABM_Utils.ABLEAD) || EDM_ABM_Utils.hasPermissionSet(EDM_ABM_Utils.VDST_ABM);
	}

	private Boolean getIsABApprover() {
		return EDM_ABM_Utils.hasPermissionSet(EDM_ABM_Utils.ABAPPROVER) || EDM_ABM_Utils.hasPermissionSet(EDM_ABM_Utils.ABAPPROVER_NO_LIC);
	}

	public List<User> getABPlanners() {
		return EDM_ABM_Utils.getUsersForRoles(new List<String> {EDM_ABM_Utils.ABLEAD, EDM_ABM_Utils.VDST_ABM});
	}

	public List<User> getABSManagers() {
		return EDM_ABM_Utils.getUsersForRoles(new List<String> {EDM_ABM_Utils.ABS});
	}

	public List<String> getPTDGroups() {
		return new List<String>(EDM_ExeSum_Utils.getPTDGroupsBasedOnObjectives(currentExeSum.EDM_Parent_IABP_gne__c));
	}

	private void initIABPGroup() {
		List<String> IABPGroups = getIABPGroups();
		IABPGroup = 'Multiple';
		if (IABPGroups.size() == 1) {
			IABPGroup = IABPGroups[0];
		}
		else {
			for (String gr : IABPGroups) {
				if (gr == 'Commercial') {
					IABPGroup = 'C';
					break;
				}
				if (gr == 'Medical Affairs') {
					IABPGroup = 'M';
					break;
				}
				if (gr == 'Other') {
					IABPGroup = 'O';
					break;
				}
			}
		}
		System.debug(IABPGroup);
	}

	private List<String> getIABPGroups() {
		List<String> groups = new List<String>();
		List<String> jointGroups = new List<String>();

		String parentGroup = currentExeSum.EDM_Parent_AABP_gne__r.EDM_Group_gne__c;
		groups.add(parentGroup);

		List<EDM_AABP_gne__c> jointAABPs = EDM_IABP_Utils.getJointAABPs(currentExeSum);
		if (jointAABPs != null) {
			for (EDM_AABP_gne__c aabp : jointAABPs) {
				jointGroups.add(aabp.EDM_Group_gne__c);
			}
		}
		
		groups.addAll(jointGroups);

		return groups;
	}

	private class ParentIABP {
		private EDM_IABP_gne__c iabp;
		private Set<String> fieldNamesToSynchronize;

		public ParentIABP(Id parentId, Set<String> fieldNamesToSynchronize) {
			this.fieldNamesToSynchronize = fieldNamesToSynchronize;
			this.iabp = new EDM_IABP_gne__c();
			this.iabp.Id = parentId;
		}

		public void changeStatus(String status) {
			iabp.EDM_Status_gne__c = status;
		}

		public void updateIABP() {
			update iabp;
		}

		public void synchronizeToIABPFrom(EDM_IABP_gne__c currentExeSum) {
			for (String fieldName : fieldNamesToSynchronize) {
				iabp.put(fieldName, currentExeSum.get(fieldName));
			}
		}
	}

	private Set<String> getFieldsToSynchronizeToIABP() {
		Set<String> sectionsToSynchronize = new Set<String> {'Event Details', 'Logistics Vendor', 'Content Vendor'};
		Set<String> fieldNamesToSynchronize = new Set<String>();

		for (String fieldSet : fieldSetList) {
			if (sectionsToSynchronize.contains(fieldSetHeadings.get(fieldSet))) {
				for (SFA2_Configuration_Object_Detail_gne__c layoutDetails : fieldSetMap.get(fieldSet)) {
					if(layoutDetails.Type_gne__c == FIELD && !layoutDetails.API_Name_gne__c.equalsIgnoreCase('RecordType.Name')) {
						fieldNamesToSynchronize.add(layoutDetails.API_Name_gne__c.toUpperCase());
					}
				}
			}
		}

		fieldNamesToSynchronize.remove('NAME');
		fieldNamesToSynchronize.addAll(new Set<String> {
			'EDM_ExeSum_Finalized_gne__c', 'EDM_ExeSum_Submitted_gne__c'});

		System.debug('fieldNamesToSynchronize: ' + fieldNamesToSynchronize.size());
		System.debug(fieldNamesToSynchronize);

		return fieldNamesToSynchronize;
	}

	public List<SelectOption> getDownloadDocumentIds() {
		return EDM_IABP_Utils.getDownloadDocumentIds(
				currentExeSum.EDM_Parent_AABP_gne__c, 
				currentExeSum.EDM_Parent_IABP_gne__c,
				currentExeSum.Id);
	}

	public PageReference startDownloadDocuments() {
		EDM_IABP_Review_Ext.updateExclusionDate4Drawloop(downloadDocumentId);
		EDM_IABP_Review_Ext.updateDateAdded4Drawloop(downloadDocumentId);
		downloadDocumentsStarted = true;
		sessionIDForDrawLoop = UserInfo.getSessionId();
		return null;
	}

	public PageReference closeDownloadDocuments() {
		downloadDocumentsStarted = false;
		return null;
	}

	public String getAttachAgendaParam() {
		if (downloadDocumentId == currentExeSum.Id) {
			return EDM_ExeSum_Utils.getAttachAgendaParam(
					currentExeSum.Id, 
					currentExeSum.EDM_Parent_IABP_gne__c, 
					currentExeSum.EDM_ExeSum_Final_Agenda_Source_gne__c);
		}
		return '';
	}

	public PageReference updateAttendees() {
		save();
		
		return updateAttendeesWithoutSave();
	}	

	public PageReference updateAttendeesWithoutSave() {
		String retURL = System.currentPageReference().getParameters().get('retURL');
		String prevRetURL = retURL == null ? '' : '&prevRetURL=' + retURL;
		PageReference pr = new PageReference('/apex/EDM_Attendees_Documents?parentId=' + currentExeSum.Id + '&retURL=/apex/EDM_ExeSum_Edit_Create?id=' + currentExeSum.Id + prevRetURL);
		pr.setRedirect(true);
		return pr;
	}

	public PageReference viewAttendees(){
		String retURL = System.currentPageReference().getParameters().get('retURL');
		String prevRetURL = retURL == null ? '' : '&prevRetURL=' + retURL;
		String forceViewModeStr = '&forceViewMode=1';
		PageReference pr = new PageReference('/apex/EDM_Attendees_Documents?parentId=' + currentExeSum.Id + forceViewModeStr + '&retURL=/apex/EDM_ExeSum_Edit_Create?id=' + currentExeSum.Id + prevRetURL);
		pr.setRedirect(true);
		return pr;
	}

	public Integer getTotalActual() {
		Integer total = 0;
		if (currentExeSum.EDM_Actual_Nr_of_Advisors_gne__c != null) {
			total += getActualAdvisorsCount();
		}
		if (currentExeSum.EDM_Actual_Nr_of_Gene_Reps_gne__c != null) {
			total += Integer.valueOf(currentExeSum.EDM_Actual_Nr_of_Gene_Reps_gne__c);
		}
		return total;
	}

	public Integer getActualAdvisorsCount() {
		return EDM_IABP_Utils.getActualAdvisorsCountById(currentExeSum.Id);
	}

	private Id getSnapshotToCompareTo() {
		List<EDM_IABP_gne__c> snaps = new List<EDM_IABP_gne__c>();
		if (currentExeSum != null && currentExeSum.Id != null) {
			snaps = [SELECT Id FROM EDM_IABP_gne__c 
					 WHERE EDM_History_Parent_IABP_gn__c = :currentExeSum.Id 
					 AND (EDM_ExeSum_Status_gne__c != :currentExeSum.EDM_ExeSum_Status_gne__c)
					 ORDER BY CreatedDate DESC];
			if (snaps.size() > 0) {
				return snaps[0].Id;
			}
			else {
				return null;
			}
		}
		else {
			return null;
		}
	}

	public PageReference compareVersions() {
		save();
		if (ApexPages.hasMessages(ApexPages.Severity.ERROR)) {
			return null;
		}

		String compareURL = '/apex/EDM_IABP_Version_Compare';
		compareURL += '?idOld=' + compareId;
		compareURL += '&idNew=' + currentExeSum.Id;
		compareURL += '&retURL=/apex/EDM_ExeSum_Edit_Create?Id=' + currentExeSum.Id;
		PageReference pr = new PageReference(compareURL);
		pr.setRedirect(true);
		return pr;
	}

	public PageReference compareVersionsWithoutSave() {
		String compareURL = '/apex/EDM_IABP_Version_Compare';
		compareURL += '?idOld=' + compareId;
		compareURL += '&idNew=' + currentExeSum.Id;
		compareURL += '&retURL=/apex/EDM_ExeSum_Edit_Create?Id=' + currentExeSum.Id;
		PageReference pr = new PageReference(compareURL);
		pr.setRedirect(true);
		return pr;
	}

	private Map<String, Integer> populateRtFieldLengths() {
		Map<String, Integer> fieldToLength = new Map<String, Integer>();
		fieldToLength.put('EDM_Explanation_of_Att_Changes_gne__c', SObjectType.EDM_IABP_gne__c.Fields.EDM_Explanation_of_Att_Changes_gne__c.Length);
		fieldToLength.put('EDM_Information_Gained_gne__c', SObjectType.EDM_Session_gne__c.Fields.EDM_Information_Gained_gne__c.Length);
		return fieldToLength;
	}

	private Boolean anyRTFieldSizeExceeded() {
		if (currentExeSum.EDM_Explanation_of_Att_Changes_gne__c != null && currentExeSum.EDM_Explanation_of_Att_Changes_gne__c.length() > rtFieldLengths.get('EDM_Explanation_of_Att_Changes_gne__c')) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Explanation of Attendee Changes field size exceeded'));
		}

		for (EDM_Session_gne__c session : sessions) {
			if (session.EDM_Information_Gained_gne__c != null &&  session.EDM_Information_Gained_gne__c.length() > rtFieldLengths.get('EDM_Information_Gained_gne__c')) {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Information Gained field size exceeded'));
				break;
			}
		}
		return ApexPages.hasMessages(ApexPages.Severity.ERROR);
	}

	public List<SelectOption> getCountries() {
		List<SelectOption> countries = new List<SelectOption>();
		for (String country : EDM_IABP_Utils.getCountries()) {
			countries.add(new SelectOption(country, country));
		}
		return countries;
	}

	public Boolean getForceSubmitToABSVisible() {
		return getIsAbsUser() && EDM_ExeSum_Utils.isInUpdateExeSumStage(currentExeSum);
	}

	public PageReference updateBlueText() {
		EDM_Blue_Text_gne__c blueTextToUpdate = [
				SELECT  Id
				FROM EDM_Blue_Text_gne__c
				WHERE EDM_Parent_Section_gne__c =: blueTextSectionHeader
				AND EDM_Document_Type_gne__c = 'ExeSum' LIMIT 1
		];
		blueTextToUpdate.EDM_Value_gne__c = blueTextValue;
		BlueTexts.put(blueTextSectionHeader, blueTextValue);
		update blueTextToUpdate;
		return null;
	}
}