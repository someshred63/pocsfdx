public without sharing class EDM_IABP_Review_Ext extends GNE_SFA2_DynamicVFLoader {

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

	public EDM_IABP_gne__c currentIABP { get; set; }

	public List<EDM_Objective_gne__c> objectives { get; set; }
	public List<EDM_Session_gne__c> sessions { get; set; }
	public List<User> UserShareList { get; set; }

	public EDM_IABP_AgendaSummary agendaSummary { get; set; }

	public String iabpTitleStatus { get; set; }
	public String iabpType { get; set; }
	public String iabpGroup { get; set; }
	public Integer presentationTime;
	public Integer discussionTime;
	public Boolean isNotCommMA { get; set; }
	public Integer totalQuestionMinutes { get; set; }
	public Boolean isUserSubmitter { get; set; }
	public Boolean isABS { get; set; }
	public String approverSelection { get; set; }
	public String approverComment { get; set; }
	public String UserRole { get; set;}
	public List<String> Teams { get; set; }
	public Map<String, String> BlueTexts { get; set; }
	public Boolean CanAddComment { get; set; }
	public Id compareId { get; set; }

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

	private Integer numberOfApprovers;

	public Boolean downloadDocumentsStarted {get; set;}
	public String downloadDocumentId {get; set;}
	public String sessionIDForDrawLoop { get; private set; }

	public EDM_IABP_Review_Ext(ApexPages.StandardController controller) {
		super(controller,'/apex/EDM_IABP_Review_Layout');

		UserRole = EDM_ABM_Utils.getUserRole(UserInfo.getUserId());


		currentIABP = [SELECT Id, Name, CreatedById, CreatedDate, EDM_Ad_Hoc_Event_gne__c, EDM_Admin_gne__c,
				EDM_Advisor_Selection_Duties_gne__c, EDM_Affiliated_w_Meeting_Congress_gne__c, EDM_Approval_Status_gne__c, EDM_Approved_By_gne__c,
				EDM_Approver_1_Comment_gne__c, EDM_Approver_1_gne__c, EDM_Approver_1_Status_gne__c, EDM_Approver_2_Comment_gne__c, EDM_Approver_2_gne__c,
				EDM_Approver_2_Status_gne__c, EDM_Approver_3_Comment_gne__c, EDM_Approver_3_gne__c, EDM_Approver_3_Status_gne__c, EDM_Approver_4_Comment_gne__c,
				EDM_Approver_4_gne__c, EDM_Approver_4_Status_gne__c, EDM_Approver_5_Comment_gne__c, EDM_Approver_5_gne__c, EDM_Approver_5_Status_gne__c,
				EDM_Brand_gne__c,  EDM_Chair_Selection_Duties_gne__c, EDM_City_gne__c, EDM_Status_gne__c,
				EDM_Cl_Expert_Selection_Duties_gne__c, EDM_Cont_Vendor_Company_Name_gne__c, EDM_Cont_Vendor_Contact_Email_gne__c, EDM_Cont_Vendor_Contact_Name_gne__c,
				EDM_Discussion_Time_Percent_gne__c, EDM_End_Date_gne__c, EDM_Est_nr_of_Attendees_gne__c, EDM_Est_nr_of_Gne_Attendees_gne__c,
				EDM_Estimated_Quarter_gne__c, EDM_Event_Name_gne__c, EDM_Exception_Rationale_gne__c, EDM_Exception_Type_gne__c, EDM_Executive_Summary_gne__c,
				EDM_ExeSum_Finalized_gne__c, EDM_ExeSum_Status_gne__c, EDM_ExeSum_Submitted_gne__c, EDM_Historical_gne__c, EDM_Historical_Version_Number_gne__c,
				EDM_History_Parent_IABP_gn__c, EDM_History_Previous_IABP_gne__c, EDM_IABP_Approved_gne__c, EDM_IABP_Submitted_gne__c, EDM_IABP_Version_gne__c,
				EDM_Joint_AABP_gne__c, EDM_Joint_Approach_gne__c, EDM_Log_Vendor_Company_Name_gne__c, EDM_Log_Vendor_Contact_Email_gne__c, EDM_Est_nr_of_Other_Attendees_gne__c,
				EDM_Log_Vendor_Contact_Name_gne__c, EDM_Meeting_Approach_gne__c, EDM_Meeting_Date_gne__c,
				EDM_Moderator_Selection_Duties_gne__c, EDM_Optional_Detail_gne__c, EDM_Parent_AABP_gne__c, EDM_Parent_IABP_gne__c, EDM_Country_gne__c,
				EDM_Presentation_Time_Percent_gne__c, EDM_Primary_AB_Lead_gne__c, EDM_Primary_Vendor_Lead_gne__c, EDM_Second_Vendor_Lead_gne__c,
				EDM_Secondary_AB_Lead_gne__c, EDM_Start_Date_gne__c, EDM_State_gne__c, EDM_Strategic_Context_gne__c, EDM_Team_gne__c, EDM_Third_AB_Lead_gne__c,
				EDM_Total_Meetings_Time__c, EDM_Type_of_Event_gne__c, EDM_Venue_gne__c, EDM_Version_Validated_gne__c, EDM_Year_gne__c, IsDeleted, IsLocked,
				LastActivityDate, LastModifiedById, LastModifiedDate, MayEdit, Region_Code_gne__c, SystemModstamp, EDM_Parent_AABP_gne__r.EDM_Group_gne__c,
				EDM_Primary_AB_Lead_gne__r.Name, EDM_Secondary_AB_Lead_gne__r.Name, EDM_Third_AB_Lead_gne__r.Name, EDM_Admin_gne__r.Name, EDM_MCS_Manager_gne__c,
				EDM_Primary_Vendor_Lead_gne__r.Name, EDM_Second_Vendor_Lead_gne__r.Name, EDM_Total_Presentation_Time_gne__c, EDM_Total_Discussion_Time_gne__c,
				EDM_Actual_Nr_of_Gene_Reps_gne__c, EDM_Actual_Nr_of_Advisors_gne__c, EDM_Withdrawal_Comment_gne__c,EDM_Advisor_Selection_Criteria_gne__c,EDM_Moderator_Selection_Criteria_gne__c,
				EDM_Chair_Selection_Criteria_gne__c,EDM_Cl_Expert_Selection_Criteria_gne__c,EDM_Request_ratio_exception_gne__c,EDM_Request_location_exception_gne__c,EDM_Location_exception_rationale_gne__c,
				EDM_ABS_to_Live_Monitor_gne__c, EDM_Zip_gne__c, EDM_Sent_For_Approval_Date_gne__c, EDM_Event_Focus_gne__c, EDM_ABS_Manager_gne__c, EDM_ABS_Manager_gne__r.Name
		FROM EDM_IABP_gne__c
		WHERE Id = :controller.getRecord().Id];

		System.debug('$$' + currentIABP);


		UsersSharedWith = EDM_ABM_Utils.populateSharedWith(currentIABP.Id, UserRole);

		iabpTitleStatus = 'View IABP';

		iabpType = currentIABP.EDM_Meeting_Approach_gne__c; //Face to Face, Telecon / Video, iAdvise
		iabpGroup = EDM_IABP_Utils.getIABPGroup(currentIABP); //currentIABP.EDM_Parent_AABP_gne__r.EDM_Group_gne__c; //C, M, gRED, PD
		isNotCommMA = (iabpGroup == 'gRED' || iabpGroup == 'PD');

		objectives = [SELECT Id, EDM_Parent_IABP_gne__c, EDM_Projected_Output_gne__c, EDM_Description_gne__c, EDM_Number_gne__c, EDM_Group_gne__c
		FROM EDM_Objective_gne__c WHERE EDM_Parent_IABP_gne__c = :currentIABP.Id
		ORDER BY EDM_Group_gne__c, EDM_Number_gne__c];

		sessions = [SELECT Id, EDM_Description_gne__c, EDM_Discussion_End_Time_gne__c, EDM_Discussion_Start_Time_gne__c, EDM_Parent_IABP_gne__c,
				EDM_Presentation_End_Time_gne__c, EDM_Presentation_Start_Time_gne__c, EDM_Presenter_gne__c, EDM_Title_gne__c,
				EDM_No_Presentation_gne__c, EDM_No_Discussion_gne__c, EDM_Is_Break_gne__c ,
				EDM_Session_Date_gne__c
		FROM EDM_Session_gne__c WHERE EDM_Parent_IABP_gne__c = :currentIABP.Id
		ORDER BY EDM_Session_Date_gne__c, EDM_Sort_Field_for_DDP_gne__c];

		agendaSummary = new EDM_IABP_AgendaSummary(currentIABP.EDM_Start_Date_gne__c, currentIABP.EDM_End_Date_gne__c, iabpGroup, sessions);

		List<AggregateResult> totalQuestionMinutesAR = [SELECT sum(EDM_Estimated_Minutes_gne__c) totalTime FROM EDM_Question_gne__c
		WHERE EDM_Parent_Exe_Summary_gne__c = :currentIABP.Id];
		if (totalQuestionMinutesAR.size() > 0) {
			totalQuestionMinutes = Integer.valueOf(totalQuestionMinutesAR[0].get('totalTime'));
		}
		else {
			totalQuestionMinutes = 0;
		}

		isUserSubmitter = (UserRole == EDM_ABM_Utils.ABS || UserRole == EDM_ABM_Utils.ABREVIEWER || UserRole == EDM_ABM_Utils.ABREVIEWER_NO_LIC);
		isABS = (UserRole == EDM_ABM_Utils.ABS);
		CanAddComment = (UserRole == EDM_ABM_Utils.ABS || UserRole == EDM_ABM_Utils.ABREVIEWER || UserRole == EDM_ABM_Utils.ABREVIEWER_NO_LIC);
		Teams = EDM_ABM_Utils.getSortedTeams(currentIABP);
		String eType = (String.isBlank(currentIABP.EDM_Joint_AABP_gne__c) ? 'Standalone' : 'Shared');
		BlueTexts = EDM_IABP_Utils.getBlueTexts('IABP', eType);

		currentIABP.EDM_Share_Comment_gne__c = null;
		currentIABP.EDM_Approval_Request_Comment_gne__c = null;
		downloadDocumentId = currentIABP.Id;
	}

	public override PageReference init() {
		PageReference pr;
		if (currentIABP.EDM_Executive_Summary_gne__c) {
			pr = new PageReference('/apex/EDM_ExeSum_Edit_Create?id=' + currentIABP.Id);
		}
		else {
			pr = super.init();
		}
		compareId = getSnapshotToCompareTo();
		System.debug('$$ fieldSetHeadings ' + fieldSetHeadings);
		return pr;
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

	public PageReference sendForApproval() {

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
			currentIABP.EDM_Approval_Status_gne__c = 'Submitted';
			currentIABP.EDM_Version_Validated_gne__c = Date.today();

			update currentIABP;

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

			EDM_ABM_Utils.removeAllComments(currentIABP.Id);
			currentIABP.EDM_Approval_Request_Comment_gne__c = null;
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

	private Boolean approvalProcessSubmitted(){
		currentIABP.EDM_Approval_Status_gne__c = [SELECT EDM_Approval_Status_gne__c FROM EDM_IABP_gne__c WHERE Id = :currentIABP.Id LIMIT 1].EDM_Approval_Status_gne__c;
		return currentIABP.EDM_Approval_Status_gne__c == 'Submitted';
	}

	public PageReference cancelApprovalProcess() {
		if(approvalProcessSubmitted()){
			EDM_ABM_Utils.setApprovalStatus(currentIABP, 'Canceled');
			List<ProcessInstanceWorkitem> piWorkItems = [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :currentIABP.Id];
			if (piWorkItems.size() > 0) {
				Approval.ProcessWorkitemRequest approval1 = new Approval.ProcessWorkitemRequest();
				approval1.setAction('Removed');
				approval1.setWorkitemId(piWorkItems[0].Id);
				Approval.ProcessResult result =  Approval.process(approval1);
			}

			PageReference pr = new PageReference('/apex/EDM_IABP_Edit_Create?id=' + currentIABP.Id );
			pr.setRedirect(true);
			return pr;
		}
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Approval Process has been already completed.'));
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

	public Boolean getIsUserApprover() {
		if (getApproverIdSet().contains(UserInfo.getUserId())) {
			return true;
		}
		else {
			return false;
		}
	}

	public Boolean getShowCompareButton() {
		return compareId != null && !hasUserApproverRole();
	}

	private Boolean hasUserApproverRole() {
		Set<Id> approverIdSet = EDM_ABM_Utils.getUserIdsForRoles(new List<String> {EDM_ABM_Utils.ABAPPROVER, EDM_ABM_Utils.ABAPPROVER_NO_LIC});
		return approverIdSet.contains(UserInfo.getUserId());
	}

	public Boolean getIsUserResponded() {
		List<Approver> approvers = getApproverList();
		if (currentIABP.EDM_Approval_Status_gne__c == 'Submitted' && approvers.size() > 0) {
			for (Approver app : approvers) {
				if(app.Status != null) {
					if (app.ApproverId == UserInfo.getUserId() && !app.Status.Contains('Sent for approval')) return true;
				}
			}
		}
		return false;
	}

	private Boolean approvalProcessNotCanceled(){
		currentIABP.EDM_Approval_Status_gne__c = [SELECT EDM_Approval_Status_gne__c FROM EDM_IABP_gne__c WHERE Id = :currentIABP.Id LIMIT 1].EDM_Approval_Status_gne__c;
		return currentIABP.EDM_Approval_Status_gne__c != 'Canceled';
	}

	public PageReference submitApproverResponse() {
		if(approvalProcessNotCanceled() && approverSelection != null && approverSelection != ''){
			String approverStatus = (approverSelection == 'Approve' ? 'Approved' : 'Rejected');

			if (currentIABP.EDM_Approver_1_gne__c == UserInfo.getUserId()) {
				currentIABP.EDM_Approver_1_Status_gne__c = approverStatus + ' on ' + Datetime.now();
				currentIABP.EDM_Approver_1_Comment_gne__c = approverComment;
				update currentIABP;

				for (ProcessInstanceWorkitem workItem : [SELECT Id FROM ProcessInstanceWorkitem
				WHERE ProcessInstance.TargetObjectId = :currentIABP.Id
				AND OriginalActorId = :UserInfo.getUserId()]) {
					Approval.ProcessWorkitemRequest approval1 = new Approval.ProcessWorkitemRequest();
					approval1.setAction(approverSelection);
					approval1.setWorkitemId(workItem.Id);
					approval1.setComments(approverComment);
					Approval.ProcessResult result =  Approval.process(approval1);
				}
			}

			if (currentIABP.EDM_Approver_2_gne__c == UserInfo.getUserId()) {
				currentIABP.EDM_Approver_2_Status_gne__c = approverStatus + ' on ' + Datetime.now();
				currentIABP.EDM_Approver_2_Comment_gne__c = approverComment;
				update currentIABP;

				for (ProcessInstanceWorkitem workItem : [SELECT Id FROM ProcessInstanceWorkitem
				WHERE ProcessInstance.TargetObjectId = :currentIABP.Id
				AND OriginalActorId = :UserInfo.getUserId()]) {
					Approval.ProcessWorkitemRequest approval1 = new Approval.ProcessWorkitemRequest();
					approval1.setAction(approverSelection);
					approval1.setWorkitemId(workItem.Id);
					approval1.setComments(approverComment);
					Approval.ProcessResult result =  Approval.process(approval1);
				}
			}

			if (currentIABP.EDM_Approver_3_gne__c == UserInfo.getUserId()) {
				currentIABP.EDM_Approver_3_Status_gne__c = approverStatus + ' on ' + Datetime.now();
				currentIABP.EDM_Approver_3_Comment_gne__c = approverComment;
				update currentIABP;

				for (ProcessInstanceWorkitem workItem : [SELECT Id FROM ProcessInstanceWorkitem
				WHERE ProcessInstance.TargetObjectId = :currentIABP.Id
				AND OriginalActorId = :UserInfo.getUserId()]) {
					Approval.ProcessWorkitemRequest approval1 = new Approval.ProcessWorkitemRequest();
					approval1.setAction(approverSelection);
					approval1.setWorkitemId(workItem.Id);
					approval1.setComments(approverComment);
					Approval.ProcessResult result =  Approval.process(approval1);
				}
			}

			if (currentIABP.EDM_Approver_4_gne__c == UserInfo.getUserId()) {
				currentIABP.EDM_Approver_4_Status_gne__c = approverStatus + ' on ' + Datetime.now();
				currentIABP.EDM_Approver_4_Comment_gne__c = approverComment;
				update currentIABP;

				for (ProcessInstanceWorkitem workItem : [SELECT Id FROM ProcessInstanceWorkitem
				WHERE ProcessInstance.TargetObjectId = :currentIABP.Id
				AND OriginalActorId = :UserInfo.getUserId()]) {
					Approval.ProcessWorkitemRequest approval1 = new Approval.ProcessWorkitemRequest();
					approval1.setAction(approverSelection);
					approval1.setWorkitemId(workItem.Id);
					approval1.setComments(approverComment);
					Approval.ProcessResult result =  Approval.process(approval1);
				}
			}

			if (currentIABP.EDM_Approver_5_gne__c == UserInfo.getUserId()) {
				currentIABP.EDM_Approver_5_Status_gne__c = approverStatus + ' on ' + Datetime.now();
				currentIABP.EDM_Approver_5_Comment_gne__c = approverComment;
				update currentIABP;

				for (ProcessInstanceWorkitem workItem : [SELECT Id FROM ProcessInstanceWorkitem
				WHERE ProcessInstance.TargetObjectId = :currentIABP.Id
				AND OriginalActorId = :UserInfo.getUserId()]) {
					Approval.ProcessWorkitemRequest approval1 = new Approval.ProcessWorkitemRequest();
					approval1.setAction(approverSelection);
					approval1.setWorkitemId(workItem.Id);
					approval1.setComments(approverComment);
					Approval.ProcessResult result =  Approval.process(approval1);
				}
			}
		}
		return null;
	}

	public List<SelectOption> getAvailableApprovers() {
		//TODO - restrict list of approvers
		List<SelectOption> availableApproversOptions = new List<SelectOption>();
		Set<Id> approverIdSet = EDM_ABM_Utils.getUserIdsForRoles(new List<String> {EDM_ABM_Utils.ABAPPROVER, EDM_ABM_Utils.ABAPPROVER_NO_LIC});
		approverIdSet.removeAll(getApproverIdSet());

		List<User> availableApprovers  =
		[SELECT Id, Name, FirstName, LastName
		FROM User
		WHERE isActive = true AND
		Id in :approverIdSet
		ORDER BY LastName, FirstName];

		for (User u : availableApprovers) {
			availableApproversOptions.add(new SelectOption(u.Id, u.LastName + ', ' + u.FirstName));
		}

		return availableApproversOptions;
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
		currentIABP.EDM_Approval_Request_Comment_gne__c = null;
		return null;
	}

	@RemoteAction
	public static Boolean isWaitingForDrawloopDocuments(ID iabpId) {
		EDM_IABP_gne__c iabp = [SELECT EDM_Status_gne__c FROM EDM_IABP_gne__c WHERE id = :iabpId LIMIT 1];
		if (iabp.EDM_Status_gne__c == 'IABP Approved') {
			return EDM_IABP_DrawLoop.getActualNumberOfSystemGeneratedDocuments(iabpId) < getExpectedNumberOfSystemGeneratedDocuments(iabpId);
		}
		return false;
	}

	@RemoteAction
	public static Integer getExpectedNumberOfSystemGeneratedDocuments(ID iabpId) {
		return EDM_IABP_DrawLoop.getExpectedNumberOfSystemGeneratedDocuments(iabpId);
	}

	public PageReference refreshPageAfertWaitingForDrawloopDocuments() {
		return null;
	}

	public Boolean getIsUserABS() {
		return (UserRole == EDM_ABM_Utils.ABS);
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

	public PageReference compareVersions() {
		String compareURL = '/apex/EDM_IABP_Version_Compare';
		compareURL += '?idOld=' + compareId;
		compareURL += '&idNew=' + currentIABP.Id;
		compareURL += '&retURL=/apex/EDM_IABP_Edit_Create?Id=' + currentIABP.Id;
		PageReference pr = new PageReference(compareURL);
		pr.setRedirect(true);
		return pr;
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

	public PageReference returnToABL() {
		Set<Id> abLeads = new Set<Id> {
				currentIABP.EDM_Primary_AB_Lead_gne__c,
				currentIABP.EDM_Secondary_AB_Lead_gne__c,
				currentIABP.EDM_Third_AB_Lead_gne__c
		};
		currentIABP.EDM_Status_gne__c = 'IABP In Progress';
		update currentIABP;

		//EDM_ABM_Utils.notifyByEmail([SELECT Id, Name FROM User WHERE Id IN :abLeads], EDM_ABM_Utils.NotifyReason.IABP_RETURNED_TO_ABL);
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'IABP has been sent to ABL.'));

		return null;
	}

	public PageReference validateUpdatedIABP() {
		currentIABP.EDM_Version_Validated_gne__c = Date.today();
		currentIABP.EDM_IABP_Version_gne__c += 1;
		currentIABP.EDM_Status_gne__c = 'IABP Approved';
		update currentIABP;

		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'IABP has been revalidated.'));
		regenerateSystemDocuments();
		//EDM_ABM_Utils.notifyAboutStatusChange(currentIABP);
		return null;
	}

	private void regenerateSystemDocuments() {
		EDM_ABM_Utils.deleteSystemGeneratedDocuments(currentIABP.Id);
		EDM_IABP_DrawLoop.generate(currentIABP.Id);
	}

	public List<String> getBrands() {
		List<String> sList = new List<String>();
		if (!String.isBlank(currentIABP.EDM_Brand_gne__c)) {
			List<String> opts = currentIABP.EDM_Brand_gne__c.split(';');

			for (String o : opts) {
				sList.add(o);
			}
		}
		return sList;
	}

	public Boolean getCanValidate() {
		return (UserRole == EDM_ABM_Utils.ABS && currentIABP.EDM_Approval_Status_gne__c == 'Approved');
	}

	public List<SelectOption> getDownloadDocumentIds() {
		return EDM_IABP_Utils.getDownloadDocumentIds(
				currentIABP.EDM_Parent_AABP_gne__c,
				currentIABP.Id,
				getExeSumId());
	}

	private Id getExeSumId() {
		List<EDM_IABP_gne__c> exeSum = getExeSum();
		return exeSum.isEmpty() ? null : exeSum[0].Id;
	}

	private List<EDM_IABP_gne__c> getExeSum() {
		return [SELECT Id, Name, EDM_ExeSum_Final_Agenda_Source_gne__c
		FROM EDM_IABP_gne__c
		WHERE EDM_Parent_IABP_gne__c = :currentIABP.Id AND EDM_Historical_gne__c = false];
	}

	public PageReference startDownloadDocuments() {
		updateExclusionDate4Drawloop(downloadDocumentId);
		updateDateAdded4Drawloop(downloadDocumentId);
		upadateActualAdvisorsCount4Drawloop(downloadDocumentId);
		downloadDocumentsStarted = true;
		sessionIDForDrawLoop = UserInfo.getSessionId();
		return null;
	}

	public PageReference closeDownloadDocuments() {
		downloadDocumentsStarted = false;
		return null;
	}

	public String getAttachAgendaParam() {
		List<EDM_IABP_gne__c> exeSum = getExeSum();

		if (exeSum.isEmpty()) {
			return '';
		}

		if (downloadDocumentId == exeSum[0].Id) {
			return EDM_ExeSum_Utils.getAttachAgendaParam(
					exeSum[0].Id,
					currentIABP.Id,
					exeSum[0].EDM_ExeSum_Final_Agenda_Source_gne__c);
		}
		return '';
	}

	public PageReference updateAttendees() {
		String targetURL = getURLForAttendeesAndDocuments();
		PageReference pr = new PageReference(targetURL);
		pr.setRedirect(true);
		return pr;
	}

	public PageReference redirectToDocuments() {
		String targetURL = getURLForAttendeesAndDocuments();
		PageReference pr = new PageReference(targetURL);
		pr.setRedirect(true);
		pr.setAnchor('doc');
		return pr;
	}

	private String getURLForAttendeesAndDocuments() {
		String retURL = System.currentPageReference().getParameters().get('retURL');
		String targetURL = '/apex/EDM_Attendees_Documents?parentId=' + currentIABP.Id;
		String pageName;
		if (System.currentPageReference().getParameters().get('pageType') == 'review'
				|| EDM_ABM_Utils.getUserRole(UserInfo.getUserId()) == EDM_ABM_Utils.ABAPPROVER
				|| EDM_ABM_Utils.getUserRole(UserInfo.getUserId()) == EDM_ABM_Utils.ABAPPROVER_NO_LIC
				|| ApexPages.currentPage().getURL().contains('EDM_IABP_Review_Layout')) {
			pageName = 'EDM_IABP_Review_Layout';
		}
		else {
			pageName = 'EDM_IABP_View_Layout';
		}
		if (retURL != null) {
			targetURL += '&retURL=/apex/' + pageName + '?id=' + currentIABP.Id + '&prevRetURL=' + retURL;
		} else {
			targetURL += '&retURL=/apex/' + pageName + '?id=' + currentIABP.Id;
		}
		return targetURL;
	}

	public String SessionId { get; set; }
	public EDM_Session_gne__c SessionToShow { get; set; }
	public PageReference getSessionDetails() {
		if (!String.isBlank(SessionId) && EDM_ABM_Utils.isValidId(SessionId)) {
			SessionToShow = [SELECT EDM_Description_gne__c, EDM_Discussion_End_Time_gne__c,
					EDM_Discussion_Start_Time_gne__c,
					EDM_Is_Break_gne__c, EDM_No_Discussion_gne__c,
					EDM_No_Presentation_gne__c, EDM_Parent_IABP_gne__c,
					EDM_Presentation_End_Time_gne__c,
					EDM_Presentation_Start_Time_gne__c,
					EDM_Presenter_gne__c, EDM_Session_Type_gne__c,
					EDM_Sort_Field_for_DDP_gne__c,
					EDM_Title_gne__c, Region_Code_gne__c,
					EDM_Session_Objectives_gne__c, EDM_Representative_AB_Questions_gne__c,
					EDM_Content_Description_gne__c,
					EDM_Session_Date_gne__c
			FROM EDM_Session_gne__c
			WHERE Id = :SessionId];
		}
		return null;
	}

	public Boolean getForceSubmitToABSVisible() {
		return isABS && (currentIABP.EDM_Status_gne__c == 'IABP In Progress' || currentIABP.EDM_Status_gne__c == 'Revising Approved IABP');
	}

	public PageReference forceSubmitToABS() {
		currentIABP.EDM_Status_gne__c = 'IABP Under Review';

		if (currentIABP.EDM_IABP_Submitted_gne__c == null) {
			currentIABP.EDM_IABP_Submitted_gne__c = Date.today();
		}

		if (currentIABP.EDM_Approval_Status_gne__c == 'Approved') {
			currentIABP.EDM_Status_gne__c = 'Re-Reviewing Approved IABP';
		}
		update currentIABP;
		return goBack();
	}

	public void validateBeforeDownload(){
		EDM_IABP_Utils.validateImgMarker(currentIABP.Name, currentIABP.EDM_Executive_Summary_gne__c);
	}

	public static void updateExclusionDate4Drawloop(Id iabpId) {
		List<EDM_IABP_Utils.AttendeesWrapper> advisors = EDM_IABP_Utils.populateAdvisors(iabpId);

		if (advisors == null || advisors.size() == 0) {
			return;
		}

		List<Id> accIds = new List<Id>();
		for (EDM_IABP_Utils.AttendeesWrapper att : advisors) {
			accIds.add(att.attendee.EDM_Account_gne__c);
		}

		List<AGS_EX_Exclusion_Request_gne__c> existingExclusionRequests = [SELECT Id, AGS_EX_Account_Name_gne__c,CreatedDate
		FROM AGS_EX_Exclusion_Request_gne__c
		WHERE
		(AGS_EX_Request_Status_gne__c = 'Pending' OR AGS_EX_Request_Status_gne__c = 'In Progress')
		AND AGS_EX_Account_Name_gne__c in :accIds];

		Map<Id, AGS_EX_Exclusion_Request_gne__c> account2ExclusionReqMap = new Map<Id, AGS_EX_Exclusion_Request_gne__c>();
		for (AGS_EX_Exclusion_Request_gne__c req : existingExclusionRequests) {
			if (!account2ExclusionReqMap.containsKey(req.AGS_EX_Account_Name_gne__c)) {
				account2ExclusionReqMap.put(req.AGS_EX_Account_Name_gne__c, req);
			}
		}

		Map<Id, Account> account2AccountMap = new Map<Id, Account>([SELECT id, AGS_EX_Exclusion_Status_gne__c, AGS_EX_Date_Checked_Exclusion_gne__c
		FROM Account
		WHERE id IN :accIds]);

		List<EDM_Attendee_gne__c> toUpdate = new List<EDM_Attendee_gne__c>();
		for (EDM_IABP_Utils.AttendeesWrapper att : advisors) {
			Date excDate = account2AccountMap.get(att.attendee.EDM_Account_gne__c).AGS_EX_Date_Checked_Exclusion_gne__c;

			if (account2AccountMap.get(att.attendee.EDM_Account_gne__c).AGS_EX_Exclusion_Status_gne__c == 'Request Pending' ||
					account2AccountMap.get(att.attendee.EDM_Account_gne__c).AGS_EX_Exclusion_Status_gne__c == 'In Process') {

				if(account2ExclusionReqMap.containsKey(att.attendee.EDM_Account_gne__c)) {
					DateTime dT = account2ExclusionReqMap.get(att.attendee.EDM_Account_gne__c).CreatedDate;
					excDate = Date.newInstance(dT.year(), dT.month(), dT.day());
				}
			} else if (account2AccountMap.get(att.attendee.EDM_Account_gne__c).AGS_EX_Exclusion_Status_gne__c == 'Not Checked') {
				excDate = null;
			}

			att.attendee.EDM_Exclusion_Checked_Date_Drawloop_gne__c = excDate;
			toUpdate.add(att.attendee);
		}

		update toUpdate;
	}

	public static void updateDateAdded4Drawloop(Id iabpId) {
		List<EDM_IABP_Utils.AttendeesWrapper> attendees = EDM_IABP_Utils.populateAdvisors(iabpId);
		attendees.addAll(EDM_IABP_Utils.populateGeneRepresentatives(iabpId));
		attendees.addAll(EDM_IABP_Utils.populateNonUSAdvisors(iabpId));
		attendees.addAll(EDM_IABP_Utils.populateOtherAttendees(iabpId));

		if (attendees == null || attendees.size() == 0) {
			return;
		}

		mapDateAdded4Attendees(iabpId, attendees);

		List<EDM_Attendee_gne__c> toUpdate = new List<EDM_Attendee_gne__c>();
		for (EDM_IABP_Utils.AttendeesWrapper att : attendees) {
			toUpdate.add(att.attendee);
		}

		update toUpdate;
	}

	public static void mapDateAdded4Attendees(Id iabpId, List<EDM_IABP_Utils.AttendeesWrapper> attendees) {
		Map<String, Date> histDates = new Map<String, Date>();
		List<EDM_IABP_gne__c> iabp = [select id, EDM_Historical_gne__c, EDM_History_Parent_IABP_gn__c from EDM_IABP_gne__c where id = :iabpId];
		if (iabp.size() > 0 && iabp[0].EDM_Historical_gne__c && iabp[0].EDM_History_Parent_IABP_gn__c != null) {
			//historical iabp, we have to get date added from parent iabp and attendees
			List<EDM_IABP_Utils.AttendeesWrapper> attendeesHist = EDM_IABP_Utils.populateAdvisors(iabp[0].EDM_History_Parent_IABP_gn__c);
			attendeesHist.addAll(EDM_IABP_Utils.populateGeneRepresentatives(iabp[0].EDM_History_Parent_IABP_gn__c));
			attendeesHist.addAll(EDM_IABP_Utils.populateNonUSAdvisors(iabp[0].EDM_History_Parent_IABP_gn__c));
			attendeesHist.addAll(EDM_IABP_Utils.populateOtherAttendees(iabp[0].EDM_History_Parent_IABP_gn__c));

			for (EDM_IABP_Utils.AttendeesWrapper att : attendeesHist) {
				Date d = att.getDateAdded();
				histDates.put(att.attendee.EDM_ID_For_Comparator_gne__c, d);
			}

		}
		for (EDM_IABP_Utils.AttendeesWrapper att : attendees) {
			if (histDates.containsKey(att.attendee.EDM_ID_For_Comparator_gne__c)) {
				att.attendee.EDM_Date_Added_Snapshot_gne__c = histDates.get(att.attendee.EDM_ID_For_Comparator_gne__c);
			} else {
				att.attendee.EDM_Date_Added_Snapshot_gne__c = att.getDateAdded();
			}
		}
	}

	public void upadateActualAdvisorsCount4Drawloop(Id iabpId) {
		Integer advCount = EDM_IABP_Utils.getActualAdvisorsCountById(iabpId);
		List<EDM_IABP_gne__c> iabp = [select id, EDM_Actual_Nr_of_Advisors_Drawloop_gne__c from EDM_IABP_gne__c where id = :iabpId];
		if (iabp.size() > 0) {
			iabp[0].EDM_Actual_Nr_of_Advisors_Drawloop_gne__c = advCount;
			update iabp[0];
		}
	}
}