public with sharing class EDM_IABP_Edit_Create_Ex extends GNE_SFA2_Dynamic_VF_Edit_Create {

	public Integer OBJECTIVES_LIMIT { get { return 50; } }
	public Integer SESSIONS_LIMIT { get { return 30; } }
	public Integer AB_QUESTIONS_LIMIT { get { return 50; } }
	public Integer BUDGET_LIMIT { get { return 50; } }
	public EDM_IABP_gne__c currentIABP { get; set; }

	private List<EDM_Objective_gne__c> deletedObjectives;
	private List<EDM_Question_gne__c> deletedQuestions;
	private List<EDM_Budget_gne__c> deletedBudgetItems;

	public List<EDM_IABP_Utils.ABObjWrapper> Objectives { get; set; }
	public List<EDM_IABP_Utils.AgendaWrapper> Agenda { get; set; }
	public List<EDM_IABP_Utils.ABQuestionsWrapper> ABQuestions { get; set; }
	public List<EDM_IABP_Utils.BudgetWrapper> Budget { get; set; }

	public EDM_IABP_AgendaSummary agendaSummary { get; set; }

	public EDM_Session_gne__c newSession { get; set; }
	public String PrimaryABLeadName { get; set; }
	public String SecondABLeadName { get; set; }
	public String ThirdABLeadName { get; set; }
	public String AdminName { get; set; }
	public String PrimaryVendorName { get; set; }
	public String SecondVendorName { get; set; }
	public String AbsManagerName { get; set; }
	public Integer RowToDel { get; set; }
	public String IABPGroup { get; set; }
	public String oGroup { get; set; }
	public Boolean isBreak { get; set; }
	public String ExceptionTriggered { get; set; }
	public List<String> Teams { get; set; }
	public List<SelectOption> SelectedBrands { get; set; }
	public Boolean isABLead { get; set; }
	public Boolean isABS { get; set; }
	public Boolean canValidate { get; set; }
	public List<SelectOption> LogisticVendors { get; set; }
	public List<SelectOption> ContentVendors { get; set; }
	public List<SelectOption> EventTypes { get; set; }
	
	public String UserRole { get; set; }
	public String newAdvisorName { get; set; }

	public EDM_IABP_Utils.TimeWrapper PresentationStart { get; set; }
	public EDM_IABP_Utils.TimeWrapper PresentationEnd { get; set; }
	public EDM_IABP_Utils.TimeWrapper DiscussionStart { get; set; }
	public EDM_IABP_Utils.TimeWrapper DiscussionEnd { get; set; }

	public Map<String, String> BlueTexts { get; set; }
	public String popupMessageAfterSubmit { get; set; }
	private Map<String, String> BlueTextsInputs { get; set; }

	private String currentMeetingApproach;

	public String objectiveGroupNameBeforeChange { get; set; }
	
	public List<SelectOption> selectedAABPs { get; set; }
	public List<SelectOption> jointAABPsToSelect { get; set; }

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

	public Boolean downloadDocumentsStarted {get; set;}
	public String downloadDocumentId {get; set;}
	public String sessionIDForDrawLoop { get; private set; }
	public String blueTextValue {get; set; }
	public String blueTextSectionHeader { get; set; }

	public Id compareId { get; set; }

	private String currentEventType;
	private Map<String, Integer> rtFieldLengths;

	public EDM_IABP_Edit_Create_Ex(ApexPages.StandardController controller) {
		super(controller,'/apex/EDM_IABP_Edit_Create');
		currentIABP = (EDM_IABP_gne__c)controller.getRecord();
		downloadDocumentId = currentIABP.Id;

		isBreak = false;
		
		selectedAABPs = new List<SelectOption>();
		jointAABPsToSelect = new List<SelectOption>();

		newSession = new EDM_Session_gne__c();
		PresentationStart = new EDM_IABP_Utils.TimeWrapper();
		PresentationEnd = new EDM_IABP_Utils.TimeWrapper();
		DiscussionStart = new EDM_IABP_Utils.TimeWrapper();
		DiscussionEnd = new EDM_IABP_Utils.TimeWrapper();

		deletedObjectives = new List<EDM_Objective_gne__c>();
		deletedQuestions = new List<EDM_Question_gne__c>();
		deletedBudgetItems = new List<EDM_Budget_gne__c>();

		popupMessageAfterSubmit = '';

        rtFieldLengths = populateRtFieldLengths();
	}

	public override PageReference init() {
		additionalQueryFields.addAll(new Set<String> {
				'EDM_Parent_AABP_gne__r.EDM_Group_gne__c',	'EDM_Approver_1_gne__c',
				'EDM_Status_gne__c', 						'EDM_Approver_2_gne__c',
				'EDM_Primary_AB_Lead_gne__r.Name',			'EDM_Approver_3_gne__c',
				'EDM_Secondary_AB_Lead_gne__r.Name',		'EDM_Approver_4_gne__c', 
				'EDM_Third_AB_Lead_gne__r.Name',			'EDM_Approver_5_gne__c',
				'EDM_Admin_gne__r.Name',					'EDM_Approver_1_Status_gne__c',
				'EDM_Primary_Vendor_Lead_gne__r.Name',		'EDM_Approver_2_Status_gne__c',
				'EDM_Second_Vendor_Lead_gne__r.Name',		'EDM_Approver_3_Status_gne__c',
				'EDM_MCS_Manager_gne__c',					'EDM_Approver_4_Status_gne__c',
				'EDM_Joint_AABP_gne__c',					'EDM_Approver_5_Status_gne__c',
				'EDM_Ad_Hoc_Event_gne__c',					'EDM_Approver_1_Comment_gne__c',
															'EDM_Approver_2_Comment_gne__c',
															'EDM_Approver_3_Comment_gne__c',
				'EDM_Approval_Status_gne__c',				'EDM_Approver_4_Comment_gne__c',
				'Name',										'EDM_Approver_5_Comment_gne__c',
				'EDM_Parent_AABP_gne__r.EDM_Plan_Year_gne__c',
				'EDM_Parent_AABP_gne__r.Id',
				'EDM_Withdrawal_Comment_gne__c',
				'EDM_Review_Timestamp_gne__c',
				'EDM_Total_Presentation_Time_gne__c',
				'EDM_Total_Discussion_Time_gne__c',
				'EDM_History_Previous_IABP_gne__c',
				'EDM_Request_ratio_exception_gne__c',
				'EDM_Request_location_exception_gne__c',
				'EDM_Share_Comment_gne__c', 'EDM_Approval_Request_Comment_gne__c',
				'EDM_Location_exception_rationale_gne__c',
				'EDM_Canceled_gne__c', 
				'EDM_ABS_to_Live_Monitor_gne__c',
				'EDM_Zip_gne__c',
				'EDM_Sent_For_Approval_Date_gne__c',
				'EDM_Event_Focus_gne__c',
				'EDM_Parent_AABP_gne__c',
				'EDM_ABS_Manager_gne__r.Name'
				});



		PageReference pageRef = super.init();

		if (pageRef == null) {
			currentIABP = (EDM_IABP_gne__c)myObject;
			currentEventType = currentIABP.EDM_Type_of_Event_gne__c;
			Map<String, String> plannerNames = EDM_ABM_Utils.getIABPNames(currentIABP.Id);
			PrimaryABLeadName = plannerNames.get('EDM_Primary_AB_Lead_gne__c');
			SecondABLeadName = plannerNames.get('EDM_Secondary_AB_Lead_gne__c');
			ThirdABLeadName = plannerNames.get('EDM_Third_AB_Lead_gne__c');
			AdminName = plannerNames.get('EDM_Admin_gne__c');
			PrimaryVendorName = plannerNames.get('EDM_Primary_Vendor_Lead_gne__c');
			SecondVendorName = plannerNames.get('EDM_Second_Vendor_Lead_gne__c');
			AbsManagerName = plannerNames.get('EDM_ABS_Manager_gne__c');

			UserRole = EDM_ABM_Utils.getUserRole(UserInfo.getUserId());
			isABLead = (UserRole == EDM_ABM_Utils.ABLEAD || UserRole == EDM_ABM_Utils.VDST_ABM);
			isABS = (UserRole == EDM_ABM_Utils.ABS);
			canValidate = (isABS && currentIABP.EDM_Approval_Status_gne__c == 'Approved');
			ExceptionTriggered = EDM_IABP_Utils.checkExceptionRules(currentIABP);
			Teams = EDM_ABM_Utils.getSortedTeams(currentIABP);
			SelectedBrands = EDM_IABP_Utils.getSelectedBrands(currentIABP.EDM_Brand_gne__c);
			UsersSharedWith = EDM_ABM_Utils.populateSharedWith(currentIABP.Id, UserRole);


			Objectives = EDM_IABP_Utils.populateABObjectives(currentIABP.Id);
			Agenda = EDM_IABP_Utils.populateAgenda(currentIABP.Id);
			ABQuestions = EDM_IABP_Utils.poplateABQuestions(currentIABP.Id);
			Budget = EDM_IABP_Utils.populateBudget(currentIABP);

			IABPGroup = EDM_IABP_Utils.getIABPGroup(currentIABP);
			oGroup = EDM_IABP_Utils.getIABPGroupForObjective(currentIABP);
			String eType = (String.isBlank(currentIABP.EDM_Joint_AABP_gne__c) ? 'Standalone' : 'Shared');
			BlueTexts = EDM_IABP_Utils.getBlueTexts('IABP', eType);
			BlueTextsInputs = EDM_IABP_Utils.getBlueTexts(null,'Both');

			recalculateAgendaSummary();

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

			EventTypes = populateEventTypes();

			currentMeetingApproach = currentIABP.EDM_Meeting_Approach_gne__c;

			populateDuties();

			compareId = getSnapshotToCompareTo();

			currentIABP.EDM_Approval_Request_Comment_gne__c = '';

			populateJointAABPs();
		}
		

		return pageRef;
	}

	public void validateBeforeDownload(){
		EDM_IABP_Utils.validateImgMarker(currentIABP.Name, currentIABP.EDM_Executive_Summary_gne__c);
	}

	public void populateJointAABPs() {
		selectedAABPs = new List<SelectOption>();
		jointAABPsToSelect = getJointAABPs();
	}

	public List<SelectOption> getJointAABPs() {
		Set<Id> alreadySelectedAABPsIds = new Set<Id>();

		for (SelectOption selectedAABP : selectedAABPs) {
			alreadySelectedAABPsIds.add(selectedAABP.getValue());
		}

		List<SelectOption> aabpsSelectOptions = new List<SelectOption>();
		String year = currentIABP.EDM_Parent_AABP_gne__r.EDM_Plan_Year_gne__c;
		List<EDM_AABP_gne__c> listAABPs = [
						SELECT 
							Id, Name,
							EDM_Group_gne__c, 
							EDM_Unit_gne__c, 
							EDM_Team_gne__c
						FROM 
							EDM_AABP_gne__c
						WHERE 
							EDM_Plan_Year_gne__c = :year AND 
							Id != :currentIABP.EDM_Parent_AABP_gne__r.Id AND 
							Id NOT IN :alreadySelectedAABPsIds];

		for (EDM_AABP_gne__c aabp : listAABPs) {
			aabpsSelectOptions.add(new SelectOption(aabp.Id, aabp.EDM_Group_gne__c + ' ' + aabp.EDM_Unit_gne__c + ' ' + aabp.EDM_Team_gne__c + ' ' + aabp.Name));
		}

		return aabpsSelectOptions;
	}

	public PageReference saveIABP() {
		return saveIABP(false);
	}

	private PageReference saveIABPAndGoBack(String succesMessage) {
		saveIABP(true);
		if (!ApexPages.hasMessages(ApexPages.Severity.ERROR)) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, succesMessage));
			if(succesMessage == 'IABP has been revalidated.') {
				regenerateSystemDocuments();
			}
		}
		if (String.isNotBlank(popupMessageAfterSubmit)) {
			return null;
		}
		return goBackWhenNoErrorsAndWarnings();
	}

	public PageReference saveAndGoBack() {
		saveIABP(false);
		if (!ApexPages.hasMessages(ApexPages.Severity.ERROR)) {
			return goBack();
		}
		return null;
	}

	private void regenerateSystemDocuments() {
		EDM_ABM_Utils.deleteSystemGeneratedDocuments(currentIABP.Id);
		EDM_IABP_DrawLoop.generate(currentIABP.Id);		
	}

	public Boolean datesAreIncorrect(){
		//currentIABP.EDM_Start_Date_gne__c, currentIABP.EDM_End_Date_gne__c, currentIABP.EDM_Meeting_Date_gne__c
		if(getIsSuperuserUpdate()){
			Date today = Date.today();
			EDM_IABP_gne__c beforeChange = [SELECT EDM_Start_Date_gne__c, EDM_End_Date_gne__c, EDM_Meeting_Date_gne__c
											FROM EDM_IABP_gne__c WHERE Id = :currentIABP.Id];
			if((beforeChange.EDM_Start_Date_gne__c < today && currentIABP.EDM_Start_Date_gne__c >= today) ||
				(beforeChange.EDM_Start_Date_gne__c >= today && currentIABP.EDM_Start_Date_gne__c < today)){
				currentIABP.EDM_Start_Date_gne__c = beforeChange.EDM_Start_Date_gne__c;
				return true;
			}
			if((beforeChange.EDM_End_Date_gne__c < today && currentIABP.EDM_End_Date_gne__c >= today) ||
				(beforeChange.EDM_End_Date_gne__c >= today && currentIABP.EDM_End_Date_gne__c < today)){
				currentIABP.EDM_End_Date_gne__c = beforeChange.EDM_End_Date_gne__c;
				return true;
			}
			if((beforeChange.EDM_Meeting_Date_gne__c < today && currentIABP.EDM_Meeting_Date_gne__c >= today) ||
				(beforeChange.EDM_Meeting_Date_gne__c >= today && currentIABP.EDM_Meeting_Date_gne__c < today)){
				currentIABP.EDM_Meeting_Date_gne__c = beforeChange.EDM_Meeting_Date_gne__c;
				return true;
			}
		}
		return false;
	}

	private PageReference saveIABP(Boolean fromOperationWithWillRedirectAfterSuccess) {
		if (anyRTFieldSizeExceeded()) {
			return null;
		}

		if (mcsManagersFieldIsInWrongFormat()) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Email of SES Manager field is in a wrong format. Only list of comma-separated email addresses is allowed.'));
			return null;
		}

		SavePoint sp = Database.setSavepoint(); 
		try {
			List<User> shareWith = [SELECT Id, Name, IsActive FROM User WHERE Id IN (:currentIABP.EDM_Primary_AB_Lead_gne__c, :currentIABP.EDM_Secondary_AB_Lead_gne__c, :currentIABP.EDM_Third_AB_Lead_gne__c,
																				:currentIABP.EDM_Admin_gne__c, :currentIABP.EDM_Primary_Vendor_Lead_gne__c, :currentIABP.EDM_Second_Vendor_Lead_gne__c )];
			EDM_ABM_Utils.shareRecord(currentIABP.Id, shareWith, EDM_ABM_Utils.AL_EDIT, EDM_ABM_Utils.SHARE_DIRECT);
			currentIABP.EDM_Brand_gne__c = EDM_IABP_Utils.saveSelectedBrands(SelectedBrands);
			if (currentIABP.EDM_Status_gne__c == 'IABP Not Started') {
				currentIABP.EDM_Status_gne__c = isABS ? 'IABP Under Review' : 'IABP In Progress';
			}
			currentIABP.EDM_Total_Question_Minutes_gne__c = Integer.valueOf(getSumOfQuestionMinutes());
			currentIABP.EDM_Type_for_Doc_gne__c = EDM_IABP_Utils.getTypeForDoc(currentIABP);

			recalculateAgendaSummary();

			currentIABP.EDM_Total_Presentation_Time_gne__c = agendaSummary.getPresentationTime();
			currentIABP.EDM_Total_Discussion_Time_gne__c = agendaSummary.getDiscussionTime();
			currentIABP.EDM_Total_Break_Time_gne__c = agendaSummary.getBreakTime();
			currentIABP.EDM_Team_gne__c = String.join(Teams, ';');
			currentIABP.EDM_Share_Comment_gne__c = null;

			if (currentIABP.EDM_Request_ratio_exception_gne__c == false) {
				currentIABP.EDM_Exception_Rationale_gne__c = null;
			}

			if (currentIABP.EDM_Request_location_exception_gne__c == false) {
				currentIABP.EDM_Location_exception_rationale_gne__c = null;
			}
			Boolean isEventTypeChange = !currentIABP.EDM_Type_of_Event_gne__c.equalsIgnoreCase(currentEventType);

			if(isEventTypeChange){
				onEventTypeChange();
			}

			if(datesAreIncorrect()){
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Past dates cannot be changed to future dates, and vice versa'));
			}

			//save objectives
			List<EDM_Objective_gne__c> objs = new List<EDM_Objective_gne__c>();
			for (EDM_IABP_Utils.ABObjWrapper aobW : Objectives) {
				if (aobW.Objective.EDM_Parent_IABP_gne__c == null) {
					aobW.Objective.EDM_Parent_IABP_gne__c = currentIABP.Id;
					aobW.Objective.EDM_ID_For_Comparator_gne__c = currentIABP.Name + '_' + getRandomID();
				}
				aobW.Objective.EDM_Description_gne__c = aobW.Description;
				objs.add(aobW.Objective);
			}
			delete deletedObjectives;
			deletedObjectives.clear();
			upsert objs;

			//save questions
			List<EDM_Question_gne__c> qsts = new List<EDM_Question_gne__c>();
			for (EDM_IABP_Utils.ABQuestionsWrapper abqW : ABQuestions) {
				if (abqW.Question.EDM_Parent_Exe_Summary_gne__c == null) {
					abqW.Question.EDM_Parent_Exe_Summary_gne__c = currentIABP.Id;
					abqW.Question.EDM_ID_For_Comparator_gne__c = currentIABP.Name + '_' + getRandomID();
				}
				qsts.add(abqW.Question);
			}
			delete deletedQuestions;
			deletedQuestions.clear();
			upsert qsts;			

			//save budget
			List<EDM_Budget_gne__c> biWs = new List<EDM_Budget_gne__c>();
			for (EDM_IABP_Utils.BudgetWrapper biW : Budget) {
				if (biW.BudgetItem.EDM_Parent_IABP_gne__c == null) {
					biW.BudgetItem.EDM_Parent_IABP_gne__c = currentIABP.Id;
					biW.BudgetItem.EDM_ID_For_Comparator_gne__c = currentIABP.Name + '_' + getRandomID();
				}
				biWs.add(biW.BudgetItem);
			}
			delete deletedBudgetItems;
			deletedBudgetItems.clear();
			upsert biWs;

			super.save();

			if (!ApexPages.hasMessages(ApexPages.Severity.ERROR)) {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'IABP has been saved.'));
			}
			if(isEventTypeChange){
				currentEventType = currentIABP.EDM_Type_of_Event_gne__c;
				currentIABP.EDM_Event_Name_gne__c = [SELECT EDM_Event_Name_gne__c FROM EDM_IABP_gne__c WHERE Id = :currentIABP.Id LIMIT 1].EDM_Event_Name_gne__c;
			}
		}

		catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Could not save IABP! ' + ex.getMessage()));
			System.debug('Could not save IABP: ' + ex.getStackTraceString());
			Database.rollback(sp);
		}
		
		return null;
	}

	private void onEventTypeChange(){
		EDM_AABP_gne__c parentAABP = [SELECT Id, EDM_Canceled_gne__c, EDM_Ad_Hoc_gne__c, EDM_CAB_gne__c, EDM_NAB_gne__c, EDM_Other_gne__c, 
										EDM_RAB_gne__c, EDM_Combo_gne__c 
										FROM EDM_AABP_gne__c 
										WHERE Id = :currentIABP.EDM_Parent_AABP_gne__c 
										LIMIT 1
									  ];
		recalculateEvents(parentAABP);
	}

	private void recalculateEvents(EDM_AABP_gne__c currentAABP){
		currentAABP.EDM_Canceled_gne__c = 0;
		currentAABP.EDM_Ad_Hoc_gne__c = 0;
		currentAABP.EDM_CAB_gne__c = 0;
		currentAABP.EDM_NAB_gne__c = 0;
		currentAABP.EDM_Other_gne__c = 0;
		currentAABP.EDM_RAB_gne__c = 0;
		currentAABP.EDM_Combo_gne__c = 0;
		for(EDM_IABP_gne__c relatedIABP : EDM_ABM_Utils.retrieveRelatedIABPsWithoutSharing(currentAABP.Id)) {
			EDM_IABP_gne__c iabp = relatedIABP.Id == currentIABP.Id ? currentIABP : relatedIABP;
			if(iabp.EDM_Canceled_gne__c){
				currentAABP.EDM_Canceled_gne__c ++;
			} else if (iabp.EDM_Ad_Hoc_Event_gne__c){
				currentAABP.EDM_Ad_Hoc_gne__c ++;
			} else if(iabp.EDM_Type_of_Event_gne__c == 'CAB'){
				currentAABP.EDM_CAB_gne__c ++;
			} else if(iabp.EDM_Type_of_Event_gne__c == 'NAB'){
				currentAABP.EDM_NAB_gne__c ++;
			} else if(iabp.EDM_Type_of_Event_gne__c == 'Other'){
				currentAABP.EDM_Other_gne__c ++;
			} else if(iabp.EDM_Type_of_Event_gne__c == 'RAB'){
				currentAABP.EDM_RAB_gne__c ++;
			} else if(iabp.EDM_Type_of_Event_gne__c == 'Combo'){
				currentAABP.EDM_Combo_gne__c ++;
			}
		}
		update currentAABP;
	}

	public PageReference validateUpdatedIABP() {
		currentIABP.EDM_Version_Validated_gne__c = Date.today();
		currentIABP.EDM_IABP_Version_gne__c += 1;
		currentIABP.EDM_Status_gne__c = 'IABP Approved';

		return saveIABPAndGoBack('IABP has been revalidated.');
	}

	public PageReference returnToABL() {
		Set<Id> abLeads = new Set<Id> { 
			currentIABP.EDM_Primary_AB_Lead_gne__c,
			currentIABP.EDM_Secondary_AB_Lead_gne__c,
			currentIABP.EDM_Third_AB_Lead_gne__c 
		};

		if (currentIABP.EDM_Approval_Status_gne__c == 'Approved') {
			currentIABP.EDM_Status_gne__c = 'Revising Approved IABP';
		}
		else {
			currentIABP.EDM_Status_gne__c = 'IABP In Progress';
		}

		currentIABP.EDM_Review_Timestamp_gne__c = DateTime.now();
		
		return saveIABPAndGoBack('IABP has been returned to ABL.');
	}

	public PageReference submitToABS() {
		currentIABP.EDM_Status_gne__c = 'IABP Under Review';
	
		if (currentIABP.EDM_IABP_Submitted_gne__c == null) {
			currentIABP.EDM_IABP_Submitted_gne__c = Date.today();
		}

		if (currentIABP.EDM_Approval_Status_gne__c == 'Approved') {
			currentIABP.EDM_Status_gne__c = 'Re-Reviewing Approved IABP';
		}
		currentIABP.EDM_Review_Timestamp_gne__c = DateTime.now();
		EDM_ABM_Utils.shareRecord(currentIABP.Id, EDM_ABM_Utils.getUsersForRole(EDM_ABM_Utils.ABS), EDM_ABM_Utils.AL_EDIT, EDM_ABM_Utils.SHARE_DIRECT);

		return saveAndGoBack();
	}

	@RemoteAction
	public Static String checkWarnings(Id iabpId, String eventType, Integer estimatedGeneAttendees, Integer estimatedAdvisorsAttendees) {
		Boolean classificationError = false;
		Boolean missingExclusionError = false;
		Boolean excludedError = false;
		Boolean ratioError = false;
		Boolean discusionError = false;
		Boolean errorFound = false;
		String errorMessage = '';

		for(EDM_Attendee_gne__c attendee :[SELECT Id, EDM_Exclusion_Status_gne__c, EDM_Business_Classification_gne__c, EDM_Clinical_Classification_gne__c
											FROM EDM_Attendee_gne__c
											WHERE EDM_Parent_IABP_gne__c = :iabpId AND
												is_deleted_gne__c = false AND
												(EDM_Exclusion_Status_gne__c in ('Not Checked', 'Request Pending', 'In Process', 'Excluded') OR 
											(EDM_Business_Classification_gne__c = 'Not Classified' AND EDM_Clinical_Classification_gne__c = 'Not Classified'))
											]){
			if(!missingExclusionError && (attendee.EDM_Exclusion_Status_gne__c.equalsIgnoreCase('Not Checked') || attendee.EDM_Exclusion_Status_gne__c.equalsIgnoreCase('Request Pending')
					|| attendee.EDM_Exclusion_Status_gne__c.equalsIgnoreCase('In Process'))){
				missingExclusionError = true;
				errorFound = true;
			} else if(!excludedError && attendee.EDM_Exclusion_Status_gne__c.equalsIgnoreCase('Excluded')){
				excludedError = true;
				errorFound = true;
			}
			if(!classificationError && attendee.EDM_Business_Classification_gne__c.equalsIgnoreCase('Not Classified') && attendee.EDM_Clinical_Classification_gne__c.equalsIgnoreCase('Not Classified')){
				classificationError = true;
				errorFound = true;
			}
		}
		EDM_IABP_gne__c iabpToCheck = [SELECT 
											Id, EDM_Type_of_Event_gne__c, EDM_Est_nr_of_Gne_Attendees_gne__c
										FROM EDM_IABP_gne__c WHERE Id = :iabpId LIMIT 1];

		iabpToCheck.EDM_Type_of_Event_gne__c = eventType;
		iabpToCheck.EDM_Est_nr_of_Gne_Attendees_gne__c = estimatedGeneAttendees;
		iabpToCheck.EDM_Est_nr_of_Attendees_gne__c = estimatedAdvisorsAttendees;
		if(EDM_IABP_Utils.checkExceptionRules(iabpToCheck) != ''){
			ratioError = true;
			errorFound = true;
		}

		EDM_IABP_AgendaSummary agendaSummary = new EDM_IABP_AgendaSummary(iabpId);
		if(!agendaSummary.meetHCOPolicyDiscussionTime()) {
			discusionError = true;
			errorFound = true;
		}

		if(errorFound){
			errorMessage = classificationError +'_' + missingExclusionError +'_' + excludedError +'_' + ratioError +'_' + discusionError;
		}

		return errorMessage;
	}

	public PageReference goBack() {
		PageReference pr;
		String retURL = System.currentPageReference().getParameters().get('retURL');

		if (retURL == null) {
			pr = new PageReference('/apex/EDM_AABP_Layout?id=' + currentIABP.EDM_Parent_AABP_gne__c);
			pr.setRedirect(true);
		}
		else {
			pr = new PageReference(retURL);
			pr.setRedirect(true);
		}
		return pr;
	}

	public PageReference goBackWhenNoErrorsAndWarnings() {
		if (!ApexPages.hasMessages(ApexPages.Severity.ERROR) && !ApexPages.hasMessages(ApexPages.Severity.WARNING)) {
			return goBack();
		}
		return null;
	}

	public PageReference shareIABP() {
		if (currentIABP != null && currentIABP.Id != null) {
			Set<Id> uIdList = new Set<Id>();
			for (SelectOption so : UsersSharedWith) {
				uIdList.add(so.getValue());
			}
			List<Id> uShareAdd = EDM_ABM_Utils.setSharing(currentIABP.Id, uIdList, UserRole);
			List<EDM_IABP_gne__c> exeSum = [SELECT Id FROM EDM_IABP_gne__c WHERE EDM_Parent_IABP_gne__c = :currentIABP.Id];
			if (exeSum.size() > 0) {
				EDM_ABM_Utils.setSharing(exeSum[0].Id, uIdList, UserRole);
			}
			if (!uShareAdd.isEmpty()) {
				update currentIABP; //save share comment for notification
				
				EDM_ABM_Email_Notifications.onIABPShare(currentIABP, uShareAdd);
			}
			//clear comment, because it is only needed for notification and new share should not show previous comment
			currentIABP.EDM_Share_Comment_gne__c = null;
			update currentIABP;
		}
		
		return null;
	}

	public String getIABPTitle() {
		if(getIsSuperuserUpdate()){
			return 'Superuser Update';
		}
		return EDM_IABP_Utils.getIABPTitle(currentIABP.EDM_Status_gne__c);
	}
	
	public Boolean getIsSuperuserUpdate(){
		if(System.currentPageReference().getParameters().get('eaction') == 'superuserUpdate' && isABS &&
			isStatusAfterIABPInProgress()){

			return true;
		}
		return false;
	}

	public Boolean isStatusAfterIABPInProgress(){
		if(currentIABP.EDM_Status_gne__c != 'Canceled' && currentIABP.EDM_Status_gne__c != 'IABP Not Started' ){
			return true;
		}
		return false;
	}

	public PageReference addObjective() {
		if (Objectives.size() < OBJECTIVES_LIMIT) {
			Objectives.add(new EDM_IABP_Utils.ABObjWrapper(Objectives.size(), new EDM_Objective_gne__c()));

			if (oGroup.startsWith('Multiple')) {
				List<String> groups = oGroup.split(';');
				Objectives[Objectives.size() - 1].Objective.EDM_Group_gne__c = groups[1];
			}
			else {
				Objectives[Objectives.size() - 1].Objective.EDM_Group_gne__c = oGroup;
			}
			
			assignNewNumberInGroupForObjective(Objectives[Objectives.size() - 1]);
		}
		else {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'You cannot add more than ' + String.valueOf(OBJECTIVES_LIMIT) + ' Objectives!'));
		}
		
		return null;
	}

	private void assignNewNumberInGroupForObjective(EDM_IABP_Utils.ABObjWrapper newObjective) {
		String groupName = newObjective.Objective.EDM_Group_gne__c;
		Decimal maxNumber = 0;

		for (EDM_IABP_Utils.ABObjWrapper w : Objectives) {
			if (w.Objective.EDM_Group_gne__c == groupName && maxNumber < w.Objective.EDM_Number_gne__c) {
				maxNumber = w.Objective.EDM_Number_gne__c;
			}
		}
		newObjective.Objective.EDM_Number_gne__c = maxNumber + 1;
		sortAndupdateObjectivesCount();
	}

	public List<SelectOption> getPossibleGroups() {
		List<SelectOption> selectOptions = new List<SelectOption>();
		List<String> groups;
		if (oGroup.startsWith('Multiple')) {
			String groupList = oGroup.substringAfter('Multiple;');
			groups = groupList.split(';');
		} else {
			groups = new List<String> {oGroup};
		}

		for (String gr : groups) {
			selectOptions.add(new SelectOption(gr, gr));
		}
		return selectOptions;
	}

	public PageReference delObjective() {
		moveUpObjectivesNumbers(Objectives[RowToDel]);

		if (Objectives[RowToDel].Objective.Id != null) {
			deletedObjectives.add(Objectives[RowToDel].Objective);
		}

		Objectives.remove(RowToDel);

		return null;
	}

	private void moveUpObjectivesNumbers(EDM_IABP_Utils.ABObjWrapper deletedObjective) {
		String groupName = deletedObjective.Objective.EDM_Group_gne__c;
		Decimal startFrom = deletedObjective.Objective.EDM_Number_gne__c + 1;

		moveUpObjectivesNumbers(groupName, startFrom);
	}

	private void moveUpObjectivesNumbers(String groupName, Decimal startFrom) {
		for (EDM_IABP_Utils.ABObjWrapper w : Objectives) {
			if (w.Objective.EDM_Group_gne__c == groupName && w.Objective.EDM_Number_gne__c >= startFrom) {
				w.Objective.EDM_Number_gne__c--;
			}
		}

		sortAndupdateObjectivesCount();
	}

	private void sortAndupdateObjectivesCount() {
		Objectives.sort();
		
		Integer i = 0;
		for (EDM_IABP_Utils.ABObjWrapper w : Objectives) {
			w.Count = i;
			i++;
		}
	}

	public PageReference addQuestion() {

		if (ABQuestions.size() < AB_QUESTIONS_LIMIT) {
			ABQuestions.add(new EDM_IABP_Utils.ABQuestionsWrapper(ABQuestions.size(), new EDM_Question_gne__c()));
		}
		else {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'You cannot add more than ' + String.valueOf(AB_QUESTIONS_LIMIT) + ' Session Objectives!'));
		}
		
		return null;
	}

	public PageReference delQuestion() {
		if (ABQuestions[RowToDel].Question.Id != null) {
			deletedQuestions.add(ABQuestions[RowToDel].Question);
		}
		
		ABQuestions.remove(RowToDel);
		Integer i = 0;
		for (EDM_IABP_Utils.ABQuestionsWrapper w : ABQuestions) {
			w.Count = i;
			i++;
		}		
		return null;
	}	

	public PageReference addBudgetItem() {

		if (Budget.size() < BUDGET_LIMIT) {
			Budget.add(new EDM_IABP_Utils.BudgetWrapper(Budget.size(), new EDM_Budget_gne__c()));
		}
		else {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'You cannot add more than ' + String.valueOf(BUDGET_LIMIT) + ' Budget Items!'));
		}
		
		return null;
	}

	public PageReference delBudgetItem() {
		if (Budget[RowToDel].BudgetItem.Id != null) {
			deletedBudgetItems.add(Budget[RowToDel].BudgetItem);
		}		
		Budget.remove(RowToDel);
		Integer i = 0;
		for (EDM_IABP_Utils.BudgetWrapper w : Budget) {
			w.Count = i;
			i++;
		}		
		return null;
	}

	public PageReference renumberObjectives() {
		Integer movedRow = RowToDel;
		Decimal numberBeforeChange = Objectives[movedRow].Objective.EDM_Number_gne__c;

		Objectives[movedRow].Objective.EDM_Number_gne__c = 0;
		assignNewNumberInGroupForObjective(Objectives[movedRow]);

		moveUpObjectivesNumbers(objectiveGroupNameBeforeChange, numberBeforeChange + 1);

		return null;
	}


	private String getRandomID() {
		final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
	    String randStr = '';
	    while (randStr.length() < 20) {
	       Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), 62);
	       randStr += chars.substring(idx, idx+1);
	    }
	    return randStr; 
	}

	public PageReference addSession() {
		Boolean isSessionEdit = (newSession.Id == null ? false : true);
		if (Agenda.size() < SESSIONS_LIMIT) {
			Savepoint sp = Database.setSavepoint();
			EDM_Session_gne__c oldSession;
			if (isSessionEdit) {
				for (EDM_IABP_Utils.AgendaWrapper a : Agenda) {
					if (a.Session.Id == newSession.Id) {
						oldSession = a.Session;
						break;
					}
				}
			}
			try {
				if (!isSessionEdit) { 
					newSession.EDM_Parent_IABP_gne__c = currentIABP.Id;
					newSession.EDM_Is_Break_gne__c = isBreak;
					newSession.EDM_ID_For_Comparator_gne__c = currentIABP.Name + '_' + getRandomID();
				}
				
				newSession.EDM_Presentation_Start_Time_gne__c = PresentationStart.toString();
				newSession.EDM_Presentation_End_Time_gne__c = PresentationEnd.toString();
				newSession.EDM_Discussion_Start_Time_gne__c = DiscussionStart.toString();
				newSession.EDM_Discussion_End_Time_gne__c = DiscussionEnd.toString();
				if (newSession.EDM_No_Discussion_gne__c  || sessionWithOnlyPresentationTime()) {
					newSession.EDM_Discussion_Start_Time_gne__c = null;
					newSession.EDM_Discussion_End_Time_gne__c = null;
				}
				if (newSession.EDM_No_Presentation_gne__c) {
					newSession.EDM_Presentation_Start_Time_gne__c = null;
					newSession.EDM_Presentation_End_Time_gne__c = null;
				}
				
				

				if (!isSessionEdit) {
					Agenda.add(new EDM_IABP_Utils.AgendaWrapper(Agenda.size(), newSession));					
				}
				else {
					for (EDM_IABP_Utils.AgendaWrapper a : Agenda) {
						if (a.Session.Id == newSession.Id) {
							a.Session = newSession;
							break;
						}
					}
				}
				
				saveIABP();
				upsert newSession;
				Agenda.sort();
				for (Integer i = 0; i < Agenda.size(); i++) {
					Agenda[i].Count = i;
				}
			}
			catch (Exception ex) {
				Database.rollback(sp);
				if (!isSessionEdit) {
					Agenda.remove(Agenda.size()-1);					
				}
				else {
					for (EDM_IABP_Utils.AgendaWrapper a : Agenda) {
						if (a.Session.Id == newSession.Id) {
							a.Session = oldSession;
							break;
						}
					}
				}
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Could not save session! ' + ex.getMessage()));
				System.debug('$$ Save session: ' + ex.getMessage());
			}
			newSession = new EDM_Session_gne__c();

			PresentationStart = new EDM_IABP_Utils.TimeWrapper();
			PresentationEnd = new EDM_IABP_Utils.TimeWrapper();
			DiscussionStart = new EDM_IABP_Utils.TimeWrapper();
			DiscussionEnd = new EDM_IABP_Utils.TimeWrapper();
			
		}
		else {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'You cannot add more than ' + String.valueOf(SESSIONS_LIMIT) + ' Sessions!'));
		}
		
		return null;
	}

	public void recalculateAgendaSummary() {
		agendaSummary = new EDM_IABP_AgendaSummary(currentIABP.EDM_Start_Date_gne__c, currentIABP.EDM_End_Date_gne__c, IABPGroup, EDM_IABP_Utils.unwrapAgendaWrapper(Agenda));
	}

	private Boolean sessionWithOnlyPresentationTime() {
		return isBreak || IABPGroup == 'PD' || IABPgroup == 'gRED';
	}

	public PageReference delSession() {
		Savepoint sp = Database.setSavepoint();
		try {
			delete Agenda[RowToDel].Session;
			Agenda.remove(RowToDel);
			Agenda.sort();
			Integer i = 0;
			for (EDM_IABP_Utils.AgendaWrapper w : Agenda) {
				w.Count = i;
				i++;
			}
			saveIABP();
		}
		catch (Exception ex) {
			Database.rollback(sp);
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Could not delete session! ' + ex.getMessage()));
			System.debug('$$ Delete session: ' + ex.getMessage());
		}
		
		return null;
	}

	public List<User> getABPlanners() {
		return EDM_ABM_Utils.getUsersForRoles(new List<String> {EDM_ABM_Utils.ABLEAD, EDM_ABM_Utils.VDST_ABM});
	}

	public List<User> getABSManagers() {
		return EDM_ABM_Utils.getUsersForRoles(new List<String> {EDM_ABM_Utils.ABS});
	}

	public List<SelectOption> getSessionDates() {
		List<SelectOption> dates = new List<SelectOption>();
		dates.add(new SelectOption('', '--None--'));

		Date d = currentIABP.EDM_Meeting_Date_gne__c;
		if (d != null) {
			Date endDate = currentIABP.EDM_End_Date_gne__c != null ? currentIABP.EDM_End_Date_gne__c : d;
			do {
				dates.add(new SelectOption(d.format(), d.format()));
				d = d.addDays(1);
			} while (d <= endDate);
		}

		return dates;
	}

	public List<SelectOption> getHours() {
		List<SelectOption> hours = new List<SelectOption>();
		for (Integer i = 1; i <= 12; i++) {
			String val = (i < 10 ? '0' + String.valueOf(i) : String.valueOf(i));
			hours.add(new SelectOption(val, val));
		}

		return hours;
	}

	public List<SelectOption> getMinutes() {
		List<SelectOption> minutes = new List<SelectOption>();
		for (Integer i = 0; i <= 55; i+=5) {
			String val = (i < 10 ? '0' + String.valueOf(i) : String.valueOf(i));
			minutes.add(new SelectOption(val, val));
		}

		return minutes;
	}

	public List<SelectOption> getPeriods() {
		List<SelectOption> periods = new List<SelectOption>();
		periods.add(new SelectOption('AM', 'AM'));
		periods.add(new SelectOption('PM', 'PM'));
		return periods;
	}

	public PageReference populateSessionForEdit() {
		String sessionId = Apexpages.currentPage().getParameters().get('sessionId');
		newSession = [SELECT Id, Name, EDM_Description_gne__c, EDM_Discussion_Start_Time_gne__c, 
						EDM_Parent_IABP_gne__c, EDM_Presentation_End_Time_gne__c, EDM_Presentation_Start_Time_gne__c, EDM_Presenter_gne__c, 
						EDM_Title_gne__c, Region_Code_gne__c, EDM_Discussion_End_Time_gne__c, EDM_Is_Break_gne__c,
						EDM_No_Presentation_gne__c, EDM_No_Discussion_gne__c, 
						EDM_Content_Description_gne__c, EDM_Session_Objectives_gne__c, EDM_Representative_AB_Questions_gne__c,
						EDM_Session_Type_gne__c, EDM_Session_Date_gne__c
					  FROM EDM_Session_gne__c
					  WHERE Id = :sessionId];
		isBreak = newSession.EDM_Is_Break_gne__c;

		PresentationStart.setFromString(newSession.EDM_Presentation_Start_Time_gne__c);
		PresentationEnd.setFromString(newSession.EDM_Presentation_End_Time_gne__c);
		DiscussionStart.setFromString(newSession.EDM_Discussion_Start_Time_gne__c);
		DiscussionEnd.setFromString(newSession.EDM_Discussion_End_Time_gne__c);

		return null;
	}

	public PageReference initSession() {
		isBreak = (ApexPages.currentPage().getParameters().get('isBreakParam') == 'true' ? true : false);
		newSession = new EDM_Session_gne__c();

		PresentationStart = new EDM_IABP_Utils.TimeWrapper();
		PresentationStart.Hour = '07';
		PresentationEnd = new EDM_IABP_Utils.TimeWrapper();
		PresentationEnd.Hour = '07';
		DiscussionStart = new EDM_IABP_Utils.TimeWrapper();
		DiscussionStart.Hour = '07';
		DiscussionEnd = new EDM_IABP_Utils.TimeWrapper();
		DiscussionEnd.Hour = '07';
		newSession.EDM_Presenter_gne__c = '';
		newSession.EDM_Title_gne__c = '';

		if (currentIABP.EDM_Meeting_Date_gne__c == currentIABP.EDM_End_Date_gne__c) {
			newSession.EDM_Session_Date_gne__c = currentIABP.EDM_Meeting_Date_gne__c;
		}

		return null;
	}

	public Integer getSumOfQuestionMinutes() {
		Integer sum = 0;
		for (EDM_IABP_Utils.ABQuestionsWrapper w : ABQuestions) {
			if (w.Question.EDM_Estimated_Minutes_gne__c != null) {
				sum += Integer.valueOf(w.Question.EDM_Estimated_Minutes_gne__c);
			}			
		}
		return sum;
	}

	public List<SelectOption> getCountries() {
		List<SelectOption> countries = new List<SelectOption>();
		for (String country : EDM_IABP_Utils.getCountries()) {
			countries.add(new SelectOption(country, country));
		}
		return countries;
	}

	public List<SelectOption> getStates() {
		List<SelectOption> states = new List<SelectOption>();
		states.add(new SelectOption('', '--None--'));
		for (String state : EDM_IABP_Utils.getUSStates()) {
			states.add(new SelectOption(state, state));
		}
		return states;
	}

	public List<SelectOption> getProvinces() {
		List<SelectOption> provinces = new List<SelectOption>();
		provinces.add(new SelectOption('', '--None--'));
		for (String province : EDM_IABP_Utils.getCanadianProvinces()) {
			provinces.add(new SelectOption(province, province));
		}
		return provinces;
	}

	public Integer getTotalEstimated() {
		Integer total = 0;
		if (currentIABP.EDM_Est_nr_of_Attendees_gne__c != null) {
			total += Integer.valueOf(currentIABP.EDM_Est_nr_of_Attendees_gne__c);
		}
		if (currentIABP.EDM_Est_nr_of_Gne_Attendees_gne__c != null) {
			total += Integer.valueOf(currentIABP.EDM_Est_nr_of_Gne_Attendees_gne__c);
		}
		if (currentIABP.EDM_Est_nr_of_Other_Attendees_gne__c != null) {
			total += Integer.valueOf(currentIABP.EDM_Est_nr_of_Other_Attendees_gne__c);
		}
		return total;
	}

	public Integer getTotalActual() {
		Integer total = 0;
		if (currentIABP.EDM_Actual_Nr_of_Advisors_gne__c != null) {
			total += getActualAdvisorsCount();
		}
		if (currentIABP.EDM_Actual_Nr_of_Gene_Reps_gne__c != null) {
			total += Integer.valueOf(currentIABP.EDM_Actual_Nr_of_Gene_Reps_gne__c);
		}
		return total;
	}

	public Integer getActualAdvisorsCount() {
		return EDM_IABP_Utils.getActualAdvisorsCountById(currentIABP.Id);
	}

	public List<SelectOption> getBrands() {
		List<String> brands = new List<String>();
		brands.addAll(EDM_ABM_Utils.getListOfBrands());

		List<SelectOption> brandsToSelect = new List<SelectOption>();
		Set<String> selectedSet = new Set<String>();
		for (SelectOption o : SelectedBrands) {
			selectedSet.add(o.getValue());
		}

		for (String b : brands) {
			if (!selectedSet.contains(b)) {
				brandsToSelect.add(new SelectOption(b, b));
			}
		}

		return brandsToSelect;
	}

	public List<SelectOption> getEventFocus() {
		List<SelectOption> eventFocuses = new List<SelectOption>();
		Schema.DescribeFieldResult fieldResult = EDM_IABP_gne__c.EDM_Event_Focus_gne__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
			eventFocuses.add(new SelectOption(pickListVal.getValue(), pickListVal.getLabel()));
        }
		return eventFocuses;
	}

	public PageReference compareVersions() {
		saveIABP(false);
		if (ApexPages.hasMessages(ApexPages.Severity.ERROR)) {
			return null;
		}

		return redirectToCompare();
	}

	public PageReference redirectToCompare(){
		EDM_IABP_gne__c iabp = [SELECT Id, EDM_History_Previous_IABP_gne__c FROM EDM_IABP_gne__c WHERE Id = :currentIABP.Id];
		String compareURL = '/apex/EDM_IABP_Version_Compare';
		compareURL += '?idOld=' + compareId;
		compareURL += '&idNew=' + iabp.Id;
		compareURL += '&retURL=/apex/EDM_IABP_Edit_Create?Id=' + iabp.Id;
		PageReference pr = new PageReference(compareURL);
		pr.setRedirect(true);
		return pr;
	}

	

	public List<SelectOption> getDownloadDocumentIds() {
		Id aabpId = currentIABP.EDM_Parent_AABP_gne__c;
		return EDM_IABP_Utils.getDownloadDocumentIds(
				aabpId, 
				currentIABP.Id, 
				getExeSumId());
	}

	private Id getExeSumId() {
		List<EDM_IABP_gne__c> exeSum = [SELECT Id, Name 
				FROM EDM_IABP_gne__c 
				WHERE EDM_Parent_IABP_gne__c = :currentIABP.Id];
		return exeSum.isEmpty() ? null : exeSum[0].Id;
	}

	public PageReference startDownloadDocuments() {
		saveIABP();
		downloadDocumentsStarted = true;
		sessionIDForDrawLoop = UserInfo.getSessionId();
		return null;
	}

	public PageReference closeDownloadDocuments() {
		downloadDocumentsStarted = false;
		return null;
	}

	public PageReference updateAttendees() {
		saveIABP();
		if (!ApexPages.hasMessages(ApexPages.Severity.ERROR)) {
			return redirectToAttendees();
		}
		return null;
	}

	public PageReference redirectToAttendees() {
		String retURL = System.currentPageReference().getParameters().get('retURL');
		String prevRetURL = retURL == null ? '' : '&prevRetURL=' + retURL;
		PageReference pr = new PageReference('/apex/EDM_Attendees_Documents?parentId=' + currentIABP.Id + '&retURL=/apex/EDM_IABP_Edit_Create?id=' + currentIABP.Id + prevRetURL);
		pr.setRedirect(true);
		return pr;
	}

	public PageReference updateAndRedirectToDocuments() {
		saveIABP();
		if (!ApexPages.hasMessages(ApexPages.Severity.ERROR)) {
			return redirectToDocuments();
		}
		return null;
	}

	public PageReference redirectToDocuments() {
		String retURL = System.currentPageReference().getParameters().get('retURL');
		String prevRetURL = retURL == null ? '' : '&prevRetURL=' + retURL;
		PageReference pr = new PageReference('/apex/EDM_Attendees_Documents?parentId=' + currentIABP.Id + '&retURL=/apex/EDM_IABP_Edit_Create?id=' + currentIABP.Id + prevRetURL);
		pr.setAnchor('doc');
		pr.setRedirect(true);
		return pr;
	}


	private void populateDuties() {
		if (String.isBlank(currentIABP.EDM_Advisor_Selection_Duties_gne__c) && currentIABP.EDM_Status_gne__c == 'IABP Not Started') {
			
			String val = BlueTextsInputs.get('Advisor Selection Duties');
			currentIABP.EDM_Advisor_Selection_Duties_gne__c = val;
		}

		if (String.isBlank(currentIABP.EDM_Chair_Selection_Duties_gne__c) && currentIABP.EDM_Status_gne__c == 'IABP Not Started') {
			String val = BlueTextsInputs.get('Chair Duties');
			currentIABP.EDM_Chair_Selection_Duties_gne__c = val;
		}

		if (String.isBlank(currentIABP.EDM_Cl_Expert_Selection_Duties_gne__c) && currentIABP.EDM_Status_gne__c == 'IABP Not Started') {
			String val = BlueTextsInputs.get('Clinical Expert Duties');
			currentIABP.EDM_Cl_Expert_Selection_Duties_gne__c = val;
		}

		if (String.isBlank(currentIABP.EDM_Moderator_Selection_Duties_gne__c) && currentIABP.EDM_Status_gne__c == 'IABP Not Started') {
			String val = BlueTextsInputs.get('Moderator Duties');
			currentIABP.EDM_Moderator_Selection_Duties_gne__c = val;
		}
	}

	class Approver {
		public Id ApproverId { get; set; }
		public String Name { get; set; }
		public String FirstName { get; set; }
		public String LastName { get; set; }
		public String Status { get; set; }
		public String Comment { get; set; }

		public Approver(User u, String Status, String Comment) {
			this.ApproverId = u.Id;
			this.Name = u.Name;
			this.FirstName = u.FirstName;
			this.LastName = u.LastName;
			this.Status = Status;
			this.Comment = Comment;
		}
	}

	class ApprovalHistory {
		public Id ProcessId { get; set; }
		public Datetime Created { get; set; }
		public String Status { get; set; }
		
	}

	public List<SelectOption> selectedApprovers { 
		get {
			if (selectedApprovers == null) {
				selectedApprovers = new List<SelectOption>();
				List<Approver> selectedApproversList = getApproverList();

				for (Approver approver : selectedApproversList) {
					selectedApprovers.add(new SelectOption(approver.ApproverId, approver.LastName + ', ' + approver.FirstName));
				}
			}

			return selectedApprovers;
		}
		set;
	}
	private Integer numberOfApprovers;

	private void saveSelectedOptionsToCurrentIABP() {
		Set<String> selectedApproversSet = new Set<String>();

		Boolean setApprover = false;
		setApprover = selectedApprovers.size() > 0 ? selectedApproversSet.add(selectedApprovers.get(0).getValue()) : null;
		setApprover = selectedApprovers.size() > 1 ? selectedApproversSet.add(selectedApprovers.get(1).getValue()) : null;
		setApprover = selectedApprovers.size() > 2 ? selectedApproversSet.add(selectedApprovers.get(2).getValue()) : null;
		setApprover = selectedApprovers.size() > 3 ? selectedApproversSet.add(selectedApprovers.get(3).getValue()) : null;
		setApprover = selectedApprovers.size() > 4 ? selectedApproversSet.add(selectedApprovers.get(4).getValue()) : null;

		clearApproverValues(selectedApproversSet);

		currentIABP.EDM_Approver_1_gne__c = (selectedApprovers.size() > 0 ? selectedApprovers.get(0).getValue() : null);
		currentIABP.EDM_Approver_2_gne__c = (selectedApprovers.size() > 1 ? selectedApprovers.get(1).getValue() : null);
		currentIABP.EDM_Approver_3_gne__c = (selectedApprovers.size() > 2 ? selectedApprovers.get(2).getValue() : null);
		currentIABP.EDM_Approver_4_gne__c = (selectedApprovers.size() > 3 ? selectedApprovers.get(3).getValue() : null);
		currentIABP.EDM_Approver_5_gne__c = (selectedApprovers.size() > 4 ? selectedApprovers.get(4).getValue() : null);
	}

	private void clearApproverValues(Set<String> selectedApproversSet) {
		if (currentIABP.EDM_Approver_1_Status_gne__c != null && !selectedApproversSet.contains(currentIABP.EDM_Approver_1_gne__c)) {
			currentIABP.EDM_Approver_1_gne__c = null;
			currentIABP.EDM_Approver_1_Status_gne__c = null;
		}

		if (currentIABP.EDM_Approver_2_Status_gne__c != null && !selectedApproversSet.contains(currentIABP.EDM_Approver_2_gne__c)) {
			currentIABP.EDM_Approver_2_gne__c = null;
			currentIABP.EDM_Approver_2_Status_gne__c = null;
		}

		if (currentIABP.EDM_Approver_3_Status_gne__c != null && !selectedApproversSet.contains(currentIABP.EDM_Approver_3_gne__c)) {
			currentIABP.EDM_Approver_3_gne__c = null;
			currentIABP.EDM_Approver_3_Status_gne__c = null;
		}

		if (currentIABP.EDM_Approver_4_Status_gne__c != null && !selectedApproversSet.contains(currentIABP.EDM_Approver_4_gne__c)) {
			currentIABP.EDM_Approver_4_gne__c = null;
			currentIABP.EDM_Approver_4_Status_gne__c = null;
		}

		if (currentIABP.EDM_Approver_5_Status_gne__c != null && !selectedApproversSet.contains(currentIABP.EDM_Approver_5_gne__c)) {
			currentIABP.EDM_Approver_5_gne__c = null;
			currentIABP.EDM_Approver_5_Status_gne__c = null;
		}
	}

	public PageReference cancelSelectApprovers() {
		selectedApprovers = null;
		currentIABP.EDM_Approval_Request_Comment_gne__c = '';
		return null;
	}

	public List<Approver> getApproverList() {

		List<Approver> approverList = new List<Approver>();
		Set<Id> approverIdsFromFields = getApproverIdSet();
		approverIdsFromFields.remove(null);

		Map<Id, User> usersFromApproverFieldsById = new Map<Id, User>(EDM_ABM_Utils.getUsers(approverIdsFromFields));

		if (currentIABP.EDM_Approver_1_gne__c != null && usersFromApproverFieldsById.containsKey(currentIABP.EDM_Approver_1_gne__c)) {
			approverList.add(new Approver(usersFromApproverFieldsById.get(currentIABP.EDM_Approver_1_gne__c), 
											currentIABP.EDM_Approver_1_Status_gne__c, 
											currentIABP.EDM_Approver_1_Comment_gne__c));
		}

		if (currentIABP.EDM_Approver_2_gne__c != null && usersFromApproverFieldsById.containsKey(currentIABP.EDM_Approver_2_gne__c)) { 
			approverList.add(new Approver(usersFromApproverFieldsById.get(currentIABP.EDM_Approver_2_gne__c), 
											currentIABP.EDM_Approver_2_Status_gne__c, 
											currentIABP.EDM_Approver_2_Comment_gne__c));
		}

		if (currentIABP.EDM_Approver_3_gne__c != null && usersFromApproverFieldsById.containsKey(currentIABP.EDM_Approver_3_gne__c)) {
			approverList.add(new Approver(usersFromApproverFieldsById.get(currentIABP.EDM_Approver_3_gne__c), 
											currentIABP.EDM_Approver_3_Status_gne__c, 
											currentIABP.EDM_Approver_3_Comment_gne__c));
		}

		if (currentIABP.EDM_Approver_4_gne__c != null && usersFromApproverFieldsById.containsKey(currentIABP.EDM_Approver_4_gne__c)) {
			approverList.add(new Approver(usersFromApproverFieldsById.get(currentIABP.EDM_Approver_4_gne__c), 
											currentIABP.EDM_Approver_4_Status_gne__c, 
											currentIABP.EDM_Approver_4_Comment_gne__c));
		}

		if (currentIABP.EDM_Approver_5_gne__c != null && usersFromApproverFieldsById.containsKey(currentIABP.EDM_Approver_5_gne__c)) {
			approverList.add(new Approver(usersFromApproverFieldsById.get(currentIABP.EDM_Approver_5_gne__c), 
											currentIABP.EDM_Approver_5_Status_gne__c, 
											currentIABP.EDM_Approver_5_Comment_gne__c));
		}

		return approverList;
	}

	private Integer getNumberOfApprovers(EDM_IABP_gne__c iabp) {
		Integer numberOfApprovers = 0;
		if (iabp.EDM_Approver_1_gne__c != null) numberOfApprovers++;
		if (iabp.EDM_Approver_2_gne__c != null) numberOfApprovers++;
		if (iabp.EDM_Approver_3_gne__c != null) numberOfApprovers++;
		if (iabp.EDM_Approver_4_gne__c != null) numberOfApprovers++;
		if (iabp.EDM_Approver_5_gne__c != null) numberOfApprovers++;
		return numberOfApprovers;
	}

	private Set<Id> getApproverIdSet() {
		Set<Id> ids = new Set<Id> {
				currentIABP.EDM_Approver_1_gne__c,
				currentIABP.EDM_Approver_2_gne__c,
				currentIABP.EDM_Approver_3_gne__c,
				currentIABP.EDM_Approver_4_gne__c,
				currentIABP.EDM_Approver_5_gne__c
		};

		return ids;
	}

	public List<SelectOption> getAvailableApprovers() {
		List<SelectOption> availableApproversOptions = new List<SelectOption>();
		Set<Id> approverIdSet = EDM_ABM_Utils.getUserIdsForRoles(new List<String> {EDM_ABM_Utils.ABAPPROVER, EDM_ABM_Utils.ABAPPROVER_NO_LIC});
		approverIdSet.removeAll(getApproverIdSet());

		List<User> availableApprovers  =
				[SELECT Id, Name, FirstName, LastName
				 FROM User
				 WHERE (isActive = true AND Id in :approverIdSet) OR
				 (IsActive = false AND (Profile.Name = 'GNE-Field' OR Profile.Name Like 'GNE-MedAffairs%') AND Id in :approverIdSet)
				 ORDER BY LastName, FirstName];

		for (User u : availableApprovers) {
			availableApproversOptions.add(new SelectOption(u.Id, u.LastName + ', ' + u.FirstName));
		}

		return availableApproversOptions;
	}

	public PageReference sendForApproval() {
		if (anyRTFieldSizeExceeded()) {

			return null;
		}
		Map<Id, String> approvedApproversSnapshot = new Map<Id, String>();
		String approverAdded;
		approverAdded = currentIABP.EDM_Approver_1_Status_gne__c != null && currentIABP.EDM_Approver_1_Status_gne__c.contains('Approved') ? approvedApproversSnapshot.put(currentIABP.EDM_Approver_1_gne__c, currentIABP.EDM_Approver_1_Status_gne__c) : null;
		approverAdded = currentIABP.EDM_Approver_2_Status_gne__c != null && currentIABP.EDM_Approver_2_Status_gne__c.contains('Approved') ? approvedApproversSnapshot.put(currentIABP.EDM_Approver_2_gne__c, currentIABP.EDM_Approver_2_Status_gne__c) : null;
		approverAdded = currentIABP.EDM_Approver_3_Status_gne__c != null && currentIABP.EDM_Approver_3_Status_gne__c.contains('Approved') ? approvedApproversSnapshot.put(currentIABP.EDM_Approver_3_gne__c, currentIABP.EDM_Approver_3_Status_gne__c) : null;
		approverAdded = currentIABP.EDM_Approver_4_Status_gne__c != null && currentIABP.EDM_Approver_4_Status_gne__c.contains('Approved') ? approvedApproversSnapshot.put(currentIABP.EDM_Approver_4_gne__c, currentIABP.EDM_Approver_4_Status_gne__c) : null;
		approverAdded = currentIABP.EDM_Approver_5_Status_gne__c != null && currentIABP.EDM_Approver_5_Status_gne__c.contains('Approved') ? approvedApproversSnapshot.put(currentIABP.EDM_Approver_5_gne__c, currentIABP.EDM_Approver_5_Status_gne__c) : null;
		saveSelectedOptionsToCurrentIABP();
		Boolean approverRejected = getRejectedStatusForApprovers();
		String approvalRequestCommentsStr = currentIABP.EDM_Approval_Request_Comment_gne__c;
		currentIABP.EDM_Withdrawal_Comment_gne__c = '';
		
		String approverStatus;
		numberOfApprovers = getNumberOfApprovers(currentIABP);

		if(numberOfApprovers > 0) {
			currentIABP.EDM_Sent_For_Approval_Date_gne__c = Date.today();
			approverStatus = 'Sent for approval ' + currentIABP.EDM_Sent_For_Approval_Date_gne__c.format();
		}

		if (numberOfApprovers == 0) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'At least one Approver needs to be selected.'));
			return null;
		} else if (numberOfApprovers == 1) {
			setApprover1Status(approvedApproversSnapshot, approverStatus, approverRejected);

			EDM_ABM_Utils.shareRecord(currentIABP.Id,
			[SELECT Id, IsActive FROM User WHERE Id IN (:currentIABP.EDM_Approver_1_gne__c)],
					'Edit',
					'EDM_DirectShare__c');
		} else if (numberOfApprovers == 2) {
			setApprover1Status(approvedApproversSnapshot, approverStatus, approverRejected);
			setApprover2Status(approvedApproversSnapshot, approverStatus, approverRejected);

			EDM_ABM_Utils.shareRecord(currentIABP.Id,
			[
					SELECT Id, IsActive
					FROM User
					WHERE Id IN (:currentIABP.EDM_Approver_1_gne__c,
							:currentIABP.EDM_Approver_2_gne__c)
			],
					'Edit',
					'EDM_DirectShare__c');
		} else if (numberOfApprovers == 3) {
			setApprover1Status(approvedApproversSnapshot, approverStatus, approverRejected);
			setApprover2Status(approvedApproversSnapshot, approverStatus, approverRejected);
			setApprover3Status(approvedApproversSnapshot, approverStatus, approverRejected);

			EDM_ABM_Utils.shareRecord(currentIABP.Id,
			[
					SELECT Id, IsActive
					FROM User
					WHERE Id IN (:currentIABP.EDM_Approver_1_gne__c,
							:currentIABP.EDM_Approver_2_gne__c,
							:currentIABP.EDM_Approver_3_gne__c)
			],
					'Edit',
					'EDM_DirectShare__c');
		} else if (numberOfApprovers == 4) {
			setApprover1Status(approvedApproversSnapshot, approverStatus, approverRejected);
			setApprover2Status(approvedApproversSnapshot, approverStatus, approverRejected);
			setApprover3Status(approvedApproversSnapshot, approverStatus, approverRejected);
			setApprover4Status(approvedApproversSnapshot, approverStatus, approverRejected);

			EDM_ABM_Utils.shareRecord(currentIABP.Id,
			[
					SELECT Id, IsActive
					FROM User
					WHERE Id IN (:currentIABP.EDM_Approver_1_gne__c,
							:currentIABP.EDM_Approver_2_gne__c,
							:currentIABP.EDM_Approver_3_gne__c,
							:currentIABP.EDM_Approver_4_gne__c)
			],
					'Edit',
					'EDM_DirectShare__c');
		} else if (numberOfApprovers == 5) {
			setApprover1Status(approvedApproversSnapshot, approverStatus, approverRejected);
			setApprover2Status(approvedApproversSnapshot, approverStatus, approverRejected);
			setApprover3Status(approvedApproversSnapshot, approverStatus, approverRejected);
			setApprover4Status(approvedApproversSnapshot, approverStatus, approverRejected);
			setApprover5Status(approvedApproversSnapshot, approverStatus, approverRejected);

			EDM_ABM_Utils.shareRecord(currentIABP.Id,
			[
					SELECT Id, IsActive
					FROM User
					WHERE Id IN (:currentIABP.EDM_Approver_1_gne__c,
							:currentIABP.EDM_Approver_2_gne__c,
							:currentIABP.EDM_Approver_3_gne__c,
							:currentIABP.EDM_Approver_4_gne__c,
							:currentIABP.EDM_Approver_5_gne__c)
			],
					'Edit',
					'EDM_DirectShare__c');
		}

		if (numberOfApprovers > 0) {
			currentIABP.EDM_Version_Validated_gne__c = Date.today();
			currentIABP.EDM_Approval_Status_gne__c = 'Submitted';

			saveIABP(true);

			if(numberOfApprovers > 0) {
				Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
				req1.setComments(approvalRequestCommentsStr);
				req1.setObjectId(currentIABP.Id);
				req1.setProcessDefinitionNameOrId(numberOfApprovers == 1 ? 'EDM_IABP_Approval_gne' : 'EDM_IABP_Approval_' + numberOfApprovers + '_gne');
				Approval.process(req1);

				if(!approverRejected) {
					for (ProcessInstanceWorkitem workItem : [
							SELECT Id
							FROM ProcessInstanceWorkitem
							WHERE ProcessInstance.TargetObjectId = :currentIABP.Id
							AND OriginalActorId IN :approvedApproversSnapshot.keySet()
					]) {
						Approval.ProcessWorkitemRequest approval1 = new Approval.ProcessWorkitemRequest();
						approval1.setAction('Approve');
						approval1.setWorkitemId(workItem.Id);
						Approval.ProcessResult result = Approval.process(approval1);
					}
				}
			}

			EDM_ABM_Utils.removeAllComments(currentIABP.Id);
			return goBackWhenNoErrorsAndWarnings();
		}

		return null;
	}

	private Boolean getRejectedStatusForApprovers() {
		Boolean approverRejected = false;
		approverRejected = currentIABP.EDM_Approver_1_Status_gne__c != null && currentIABP.EDM_Approver_1_Status_gne__c.contains('Rejected') ? true : false;
		if(!approverRejected) {
			approverRejected = currentIABP.EDM_Approver_2_Status_gne__c != null && currentIABP.EDM_Approver_2_Status_gne__c.contains('Rejected') ? true : false;
		} else {
			return approverRejected;
		}
		if(!approverRejected) {
			approverRejected = currentIABP.EDM_Approver_3_Status_gne__c != null && currentIABP.EDM_Approver_3_Status_gne__c.contains('Rejected') ? true : false;
		} else {
			return approverRejected;
		}

		if(!approverRejected) {
			approverRejected = currentIABP.EDM_Approver_4_Status_gne__c != null && currentIABP.EDM_Approver_4_Status_gne__c.contains('Rejected') ? true : false;
		} else {
			return approverRejected;
		}

		if(!approverRejected) {
			approverRejected = currentIABP.EDM_Approver_5_Status_gne__c != null && currentIABP.EDM_Approver_5_Status_gne__c.contains('Rejected') ? true : false;
		} else {
			return approverRejected;
		}
		return approverRejected;
	}

	private void setApprover1Status(Map<Id, String> approvedApproversSnapshot, String approverStatus, Boolean approverRejected) {
		if (!approvedApproversSnapshot.containsKey(currentIABP.EDM_Approver_1_gne__c) || approverRejected) {
			currentIABP.EDM_Approver_1_Status_gne__c = approverStatus;
		} else {
			currentIABP.EDM_Approver_1_Status_gne__c = approvedApproversSnapshot.get(currentIABP.EDM_Approver_1_gne__c);
		}
	}

	private void setApprover2Status(Map<Id, String> approvedApproversSnapshot, String approverStatus, Boolean approverRejected) {
		if (!approvedApproversSnapshot.containsKey(currentIABP.EDM_Approver_2_gne__c)  || approverRejected) {
			currentIABP.EDM_Approver_2_Status_gne__c = approverStatus;
		} else {
			currentIABP.EDM_Approver_2_Status_gne__c = approvedApproversSnapshot.get(currentIABP.EDM_Approver_2_gne__c);
		}
	}

	private void setApprover3Status(Map<Id, String> approvedApproversSnapshot, String approverStatus, Boolean approverRejected) {
		if (!approvedApproversSnapshot.containsKey(currentIABP.EDM_Approver_3_gne__c) || approverRejected) {
			currentIABP.EDM_Approver_3_Status_gne__c = approverStatus;
		} else {
			currentIABP.EDM_Approver_3_Status_gne__c = approvedApproversSnapshot.get(currentIABP.EDM_Approver_3_gne__c);
		}
	}

	private void setApprover4Status(Map<Id, String> approvedApproversSnapshot, String approverStatus, Boolean approverRejected) {
		if (!approvedApproversSnapshot.containsKey(currentIABP.EDM_Approver_4_gne__c) || approverRejected) {
			currentIABP.EDM_Approver_4_Status_gne__c = approverStatus;
		} else {
			currentIABP.EDM_Approver_4_Status_gne__c = approvedApproversSnapshot.get(currentIABP.EDM_Approver_4_gne__c);
		}
	}

	private void setApprover5Status(Map<Id, String> approvedApproversSnapshot, String approverStatus, Boolean approverRejected) {
		if (!approvedApproversSnapshot.containsKey(currentIABP.EDM_Approver_5_gne__c) || approverRejected) {
			currentIABP.EDM_Approver_5_Status_gne__c = approverStatus;
		} else {
			currentIABP.EDM_Approver_5_Status_gne__c = approvedApproversSnapshot.get(currentIABP.EDM_Approver_5_gne__c);
		}
	}

	public PageReference cancelApprovalProcess() {
		EDM_ABM_Utils.setApprovalStatus(currentIABP, 'Canceled');
		List<ProcessInstanceWorkitem> piWorkItems = [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :currentIABP.Id];
		if (piWorkItems.size() > 0) {
			Approval.ProcessWorkitemRequest approval1 = new Approval.ProcessWorkitemRequest();
			approval1.setAction('Removed');
			approval1.setWorkitemId(piWorkItems[0].Id);
			Approval.ProcessResult result =  Approval.process(approval1);
		}	
		
		return null;
	}

	private Id getSnapshotToCompareTo() {
		List<EDM_IABP_gne__c> snaps = new List<EDM_IABP_gne__c>();
		if (currentIABP != null && currentIABP.Id != null) {
			snaps = [SELECT Id FROM EDM_IABP_gne__c 
					 WHERE EDM_History_Parent_IABP_gn__c = :currentIABP.Id 
					 AND EDM_IABP_Version_gne__c = :currentIABP.EDM_IABP_Version_gne__c
					 AND (EDM_Status_gne__c != :currentIABP.EDM_Status_gne__c OR EDM_Status_gne__c = 'IABP Approved')
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

	private Boolean anyRTFieldSizeExceeded() {
		for (EDM_IABP_Utils.ABObjWrapper aobW : Objectives) {
			if (aobW.Description.length() > rtFieldLengths.get('EDM_Description_gne__c')) {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Objective Description field size exceeded'));				
			}
		}

		if (currentIABP.EDM_Advisor_Selection_Criteria_gne__c != null && currentIABP.EDM_Advisor_Selection_Criteria_gne__c.length() > rtFieldLengths.get('EDM_Advisor_Selection_Duties_gne__c')) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Advisor Selection Criteria field size exceeded'));
		}

		if (currentIABP.EDM_Advisor_Selection_Duties_gne__c != null && currentIABP.EDM_Advisor_Selection_Duties_gne__c.length() > rtFieldLengths.get('EDM_Advisor_Selection_Duties_gne__c')) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Advisor Selection Duties field size exceeded'));
		}

		if (currentIABP.EDM_Affiliated_w_Meeting_Congress_gne__c != null && currentIABP.EDM_Affiliated_w_Meeting_Congress_gne__c.length() > rtFieldLengths.get('EDM_Affiliated_w_Meeting_Congress_gne__c')) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Affiliated with Meeting or Congress field size exceeded'));
		}

		if (currentIABP.EDM_Chair_Selection_Criteria_gne__c != null && currentIABP.EDM_Chair_Selection_Criteria_gne__c.length() > rtFieldLengths.get('EDM_Chair_Selection_Criteria_gne__c')) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Chair Selection Criteria field size exceeded'));
		}

		if (currentIABP.EDM_Chair_Selection_Duties_gne__c != null && currentIABP.EDM_Chair_Selection_Duties_gne__c.length() > rtFieldLengths.get('EDM_Chair_Selection_Duties_gne__c')) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Chair Selection Duties field size exceeded'));
		}

		if (currentIABP.EDM_Cl_Expert_Selection_Criteria_gne__c != null && currentIABP.EDM_Cl_Expert_Selection_Criteria_gne__c.length() > rtFieldLengths.get('EDM_Cl_Expert_Selection_Criteria_gne__c')) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Clinical Expert Selection Criteria field size exceeded'));
		}

		if (currentIABP.EDM_Cl_Expert_Selection_Duties_gne__c != null && currentIABP.EDM_Cl_Expert_Selection_Duties_gne__c.length() > rtFieldLengths.get('EDM_Cl_Expert_Selection_Duties_gne__c')) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Clinical Expert Selection Duties field size exceeded'));
		}

		if (currentIABP.EDM_Exception_Rationale_gne__c != null && currentIABP.EDM_Exception_Rationale_gne__c.length() > rtFieldLengths.get('EDM_Exception_Rationale_gne__c')) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Exception Rationale field size exceeded'));
		}

		if (currentIABP.EDM_Location_exception_rationale_gne__c != null && currentIABP.EDM_Location_exception_rationale_gne__c.length() > rtFieldLengths.get('EDM_Location_exception_rationale_gne__c')) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Location exception rationale field size exceeded'));
		}

		if (currentIABP.EDM_Moderator_Selection_Criteria_gne__c != null && currentIABP.EDM_Moderator_Selection_Criteria_gne__c.length() > rtFieldLengths.get('EDM_Moderator_Selection_Criteria_gne__c')) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Moderator Selection Criteria field size exceeded'));
		}

		if (currentIABP.EDM_Moderator_Selection_Duties_gne__c != null && currentIABP.EDM_Moderator_Selection_Duties_gne__c.length() > rtFieldLengths.get('EDM_Moderator_Selection_Duties_gne__c')) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Moderator Selection Duties field size exceeded'));
		}

		if (currentIABP.EDM_Strategic_Context_gne__c != null && currentIABP.EDM_Strategic_Context_gne__c.length() > rtFieldLengths.get('EDM_Strategic_Context_gne__c')) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Strategic Context field size exceeded'));
		}

		if (ApexPages.hasMessages(ApexPages.Severity.ERROR)) {
			return true;
		}
		else {
			return false;
		}		
	}

	private Boolean mcsManagersFieldIsInWrongFormat() {
		if (String.isNotBlank(currentIABP.EDM_MCS_Manager_gne__c)) {
			List<String> addressesSplit = currentIABP.EDM_MCS_Manager_gne__c.split(',');
			for (String address : addressesSplit) {
				if (!validEmail(address.trim())) {
					return true;
				}
			}
		}
		return false;
	}

	private Boolean validEmail(String email) {
		Boolean result = true;	
		String emailRegex = '^(([^<>()\\[\\]\\.,;:\\s@"]+(\\.[^<>()\\[\\]\\.,;:\\s@"]+)*)|(".+"))@(([[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}])|(([a-zA-Z\\-0-9]+\\.)+[a-zA-Z]{2,}))$';
		Pattern myPattern = Pattern.compile(emailRegex);
		Matcher myMatcher = MyPattern.matcher(email);

		if (!myMatcher.matches()) 
		    result = false;
		return result;	
	}

	private Map<String, Integer> populateRtFieldLengths() {
		Map<String, Integer> fieldToLength = new Map<String, Integer>();
		fieldToLength.put('EDM_Description_gne__c', SObjectType.EDM_Objective_gne__c.Fields.EDM_Description_gne__c.Length);
		fieldToLength.put('EDM_Advisor_Selection_Criteria_gne__c', SObjectType.EDM_IABP_gne__c.Fields.EDM_Advisor_Selection_Criteria_gne__c.Length); 
		fieldToLength.put('EDM_Advisor_Selection_Duties_gne__c', SObjectType.EDM_IABP_gne__c.Fields.EDM_Advisor_Selection_Duties_gne__c.Length); 
		fieldToLength.put('EDM_Affiliated_w_Meeting_Congress_gne__c', SObjectType.EDM_IABP_gne__c.Fields.EDM_Affiliated_w_Meeting_Congress_gne__c.Length); 
		fieldToLength.put('EDM_Chair_Selection_Criteria_gne__c', SObjectType.EDM_IABP_gne__c.Fields.EDM_Chair_Selection_Criteria_gne__c.Length); 
		fieldToLength.put('EDM_Chair_Selection_Duties_gne__c', SObjectType.EDM_IABP_gne__c.Fields.EDM_Chair_Selection_Duties_gne__c.Length); 
		fieldToLength.put('EDM_Cl_Expert_Selection_Criteria_gne__c', SObjectType.EDM_IABP_gne__c.Fields.EDM_Cl_Expert_Selection_Criteria_gne__c.Length); 
		fieldToLength.put('EDM_Cl_Expert_Selection_Duties_gne__c', SObjectType.EDM_IABP_gne__c.Fields.EDM_Cl_Expert_Selection_Duties_gne__c.Length); 
		fieldToLength.put('EDM_Exception_Rationale_gne__c', SObjectType.EDM_IABP_gne__c.Fields.EDM_Exception_Rationale_gne__c.Length); 
		fieldToLength.put('EDM_Location_exception_rationale_gne__c', SObjectType.EDM_IABP_gne__c.Fields.EDM_Location_exception_rationale_gne__c.Length); 
		fieldToLength.put('EDM_Moderator_Selection_Criteria_gne__c', SObjectType.EDM_IABP_gne__c.Fields.EDM_Moderator_Selection_Criteria_gne__c.Length); 
		fieldToLength.put('EDM_Moderator_Selection_Duties_gne__c', SObjectType.EDM_IABP_gne__c.Fields.EDM_Moderator_Selection_Duties_gne__c.Length); 
		fieldToLength.put('EDM_Strategic_Context_gne__c', SObjectType.EDM_IABP_gne__c.Fields.EDM_Strategic_Context_gne__c.Length); 
		return fieldToLength;
	}

	public PageReference changeMeetingApproach() {
		currentMeetingApproach = currentIABP.EDM_Meeting_Approach_gne__c;

		if (currentIABP.EDM_Meeting_Approach_gne__c != 'Face to Face') {
			currentIABP.EDM_Venue_gne__c = null;
			currentIABP.EDM_Country_gne__c = null;
			currentIABP.EDM_State_gne__c = null;
			currentIABP.EDM_City_gne__c = null;
			currentIABP.EDM_Zip_gne__c = null;
		}

		if (currentIABP.EDM_Meeting_Approach_gne__c == 'iAdvise') {
			currentIABP.EDM_Meeting_Date_gne__c = null;
			currentIABP.EDM_Log_Vendor_Company_Name_gne__c = null;
			currentIABP.EDM_Log_Vendor_Contact_Name_gne__c = null;
			currentIABP.EDM_Log_Vendor_Contact_Email_gne__c = null;
			EDM_ABM_Utils.removeAllCommentsForSection(currentIABP.Id, 'Logistics Vendor');
			delAgenda();
			EDM_ABM_Utils.removeAllCommentsForSection(currentIABP.Id, 'Agenda');
		} else {
			delABQuestions();
			EDM_ABM_Utils.removeAllCommentsForSection(currentIABP.Id, 'Agenda (Advisory Board Questions)');
		}
		return null;
	}

	private void delAgenda() {
		Savepoint sp = Database.setSavepoint();
		try {
			List<EDM_Session_gne__c> sessionsToDel = new List<EDM_Session_gne__c>();
			for (EDM_IABP_Utils.AgendaWrapper w : Agenda) {
				sessionsToDel.add(w.session);
			}

			delete sessionsToDel;
			Agenda.clear();
		}
		catch (Exception ex) {
			Database.rollback(sp);
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Could not delete agenda! ' + ex.getMessage()));
			System.debug('$$ Delete session: ' + ex.getMessage());
		}
	}

	private void delABQuestions() {
		Savepoint sp = Database.setSavepoint();
		try {
			List<EDM_Question_gne__c> abQuestionsToDel = new List<EDM_Question_gne__c>();

			for (EDM_IABP_Utils.ABQuestionsWrapper w : ABQuestions) {
				abQuestionsToDel.add(w.question);
			}

			delete abQuestionsToDel;
			ABQuestions.clear();
		}
		catch (Exception ex) {
			Database.rollback(sp);
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Could not delete AB Questions! ' + ex.getMessage()));
			System.debug('$$ Delete AB Questions: ' + ex.getMessage());
		}
	}

	public PageReference cancelMeetingApproachChange() {
		if (currentIABP.Id != null) {
			currentIABP.EDM_Meeting_Approach_gne__c = currentMeetingApproach;
		}
		return null;
	}

	private List<SelectOption> populateEventTypes() {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('CAB', 'CAB'));
		options.add(new SelectOption('RAB', 'RAB'));
		options.add(new SelectOption('NAB', 'NAB'));
		options.add(new SelectOption('Other', 'Other'));
		options.add(new SelectOption('Combo', 'Combo'));
		return options;
	}

	public Boolean getShowApprovalStatusOnCancelReject() {
		if ((currentIABP.EDM_Approval_Status_gne__c == 'Canceled' || currentIABP.EDM_Approval_Status_gne__c == 'Rejected') && isABS
				|| currentIABP.EDM_Approval_Status_gne__c == 'Rejected' && isABLead) {
			return true;
		}
		else {
			return false;
		}
	}

	public PageReference approvedByABS() {
		try {
			EDM_ABM_Utils.removeAllComments(currentIABP.Id);
      		currentIABP.EDM_Approval_Request_Comment_gne__c = null;

			currentIABP.EDM_Approval_Status_gne__c = 'Submitted';
			currentIABP.EDM_Status_gne__c = 'IABP Submitted for Approval';
			currentIABP.EDM_Approver_1_gne__c = UserInfo.getUserId();
			currentIABP.EDM_Sent_For_Approval_Date_gne__c = Date.today();
			currentIABP.EDM_Approver_1_Status_gne__c = 'Sent for approval ' + Date.today().format();
			currentIABP.EDM_IABP_Submitted_gne__c = Date.today();
			currentIABP.EDM_Version_Validated_gne__c = Date.today();
			saveIABP();

			currentIABP.EDM_Approval_Status_gne__c = 'Approved';
			currentIABP.EDM_Approved_By_gne__c = UserInfo.getName();
			currentIABP.EDM_IABP_Approved_gne__c = Date.today();
			currentIABP.EDM_Status_gne__c = 'IABP Approved';
			currentIABP.EDM_IABP_Version_gne__c = currentIABP.EDM_IABP_Version_gne__c + 1;
			currentIABP.EDM_Approver_1_Status_gne__c = 'Approved on ' + Datetime.now();
			update currentIABP;

			return goBack();
		}
		catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'ABS Approval: ' + ex.getMessage()));
			return null;
		}
	}

	public PageReference convertToSingleEvent() {
		try {
			List<EDM_IABP_gne__c> toUpdate = new List<EDM_IABP_gne__c>();
			EDM_AABP_gne__c currentABP = [SELECT Id, EDM_AB_Lead_gne__c, EDM_Vendor_Lead_gne__c
                                                FROM EDM_AABP_gne__c 
                                                WHERE Id =: currentIABP.EDM_Parent_AABP_gne__c LIMIT 1];

			List<EDM_IABP_gne__c> childIABP = [SELECT Id
                                                FROM EDM_IABP_gne__c 
                                                WHERE EDM_Parent_IABP_gne__c =: currentIABP.Id];

            Set<Id> uShareIds = EDM_ABM_Utils.getUserIdsToShareWithBaseOnAABPs(currentABP, currentIABP.EDM_Joint_AABP_gne__c.contains(',') ? currentIABP.EDM_Joint_AABP_gne__c.split(',') : new List<String> { currentIABP.EDM_Joint_AABP_gne__c });
			uShareIds.add(UserInfo.getUserId()); //add current user for ad-hoc in case when current user is not ab lead or vandor 
			uShareIds.addAll(EDM_ABM_Utils.getUserIdsForRole(EDM_ABM_Utils.ABS));
			List<User> uShare = EDM_ABM_Utils.getUsers(uShareIds);
			EDM_ABM_Utils.unShareRecord(new Set<Id> {currentIABP.Id}, uShare, EDM_ABM_Utils.SHARE_DIRECTCHILD);
			currentIABP.EDM_Joint_AABP_gne__c = '';
			Teams = EDM_ABM_Utils.getSortedTeams(currentIABP);
			currentIABP.EDM_Team_gne__c = Teams[0];
			toUpdate.add(currentIABP);

			for(EDM_IABP_gne__c child: childIABP) {
				child.EDM_Team_gne__c = currentIABP.EDM_Team_gne__c;
				child.EDM_Joint_AABP_gne__c = '';
				toUpdate.add(child);
			}

			update toUpdate;
			
			return null;
		}
		catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Convert to Single Event: ' + ex.getMessage()));
			return null;
		}
	}

	public PageReference convertToJointEvent(){
		try {
			List<EDM_IABP_gne__c> toUpdate = new List<EDM_IABP_gne__c>();

			List<String> jointAABPsIds = new List<String>();
			for (SelectOption sso : selectedAABPs) {
				jointAABPsIds.add(sso.getValue());
			}

			EDM_AABP_gne__c currentABP = [SELECT Id, EDM_AB_Lead_gne__c, EDM_Vendor_Lead_gne__c
                                                FROM EDM_AABP_gne__c 
                                                WHERE Id =: currentIABP.EDM_Parent_AABP_gne__c LIMIT 1];

           
			currentIABP.EDM_Joint_AABP_gne__c = String.join(jointAABPsIds, ',');
			currentIABP.EDM_Joint_Approach_gne__c = '';
			Teams = EDM_ABM_Utils.getSortedTeams(currentIABP);
			currentIABP.EDM_Team_gne__c = String.join(Teams, ';');

			toUpdate.add(currentIABP);

			Set<Id> uShareIds = EDM_ABM_Utils.getUserIdsToShareWithBaseOnAABPs(currentABP, currentIABP.EDM_Joint_AABP_gne__c.contains(',') ? currentIABP.EDM_Joint_AABP_gne__c.split(',') : new List<String> { currentIABP.EDM_Joint_AABP_gne__c });
			uShareIds.add(UserInfo.getUserId()); //add current user for ad-hoc in case when current user is not ab lead or vandor 
			uShareIds.addAll(EDM_ABM_Utils.getUserIdsForRole(EDM_ABM_Utils.ABS));

			List<User> uShare = EDM_ABM_Utils.getUsers(uShareIds);
			EDM_ABM_Utils.shareRecord(currentIABP.Id, uShare, EDM_ABM_Utils.AL_EDIT, EDM_ABM_Utils.SHARE_DIRECTCHILD);

			List<EDM_IABP_gne__c> childIABP = [SELECT Id
                                               FROM EDM_IABP_gne__c 
                                               WHERE EDM_Parent_IABP_gne__c =: currentIABP.Id];

            for(EDM_IABP_gne__c child : childIABP) {
				child.EDM_Team_gne__c = currentIABP.EDM_Team_gne__c;
				child.EDM_Joint_AABP_gne__c = currentIABP.EDM_Joint_AABP_gne__c;
				toUpdate.add(child);
			}

			update toUpdate;

	        return null;
		} catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Convert to Joint Event: ' + ex.getMessage()));
			return null;
		}
		
	}

	public PageReference updateBlueText() {
		EDM_Blue_Text_gne__c blueTextToUpdate = [
				SELECT  Id
				FROM EDM_Blue_Text_gne__c
				WHERE EDM_Parent_Section_gne__c =: blueTextSectionHeader
				AND EDM_Document_Type_gne__c = 'IABP' LIMIT 1
		];
		blueTextToUpdate.EDM_Value_gne__c = blueTextValue;
		BlueTexts.put(blueTextSectionHeader, blueTextValue);
		update blueTextToUpdate;
		return null;
	}
}