public with sharing class EDM_AABP_Layout_Ext extends GNE_SFA2_DynamicVFLoader {

	class IABPWrapper {
		public Integer counter { get; set; }
		public EDM_IABP_gne__c item { get; set;}
		public Id ExeSum_Id { get; set;}
		public List<EDM_Action> actions { get; set;}
		public String exesumStatus { get; set;}
		public String spendStatus { get; set;}

		public IABPWrapper(EDM_IABP_gne__c item, Integer counter) {
			this.item = item;
			this.counter = counter;

			this.spendStatus = item.EDM_Spends__r != null && !item.EDM_Spends__r.isEmpty() ? item.EDM_Spends__r.get(0).EDM_Spend_Status_gne__c : null;
		}
	}

	private ApexPages.Standardcontroller controller;
	private String PlanYear;

	public EDM_AABP_gne__c currentAABP { get; set; }
	public List<IABPWrapper> relatedIABPs { get; set; }
	public List<EDM_Attachment_gne__c> attachments { get; set; }
	public Integer TotalMeetings { get; set; }
	public List<SelectOption> selectedAABPs { get; set; }
	public List<SelectOption> jointAABPsToSelect { get; set; }
	public EDM_IABP_gne__c newEvent { get; set; }
	public String CancelReason { get; set; }
	public String CancelId { get; set; }
	public String EventId { get; set; }
	public String attachToDel { get; set; }
	public String ABLeadName { get;  set; }
	public String VendorLeadName { get; set; }
	public String ABSManagerName { get; set; }
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


	public EDM_AABP_Layout_Ext(ApexPages.StandardController controller) {
		super(controller,'/apex/EDM_AABP_Layout');
		this.controller = controller;
		currentAABP = (EDM_AABP_gne__c)controller.getRecord();

		TotalMeetings = Integer.valueOf(currentAABP.EDM_Total_Number_of_Meetings_gne__c);
		UserRole = EDM_ABM_Utils.getUserRole(UserInfo.getUserId());
		UsersSharedWith = EDM_ABM_Utils.populateSharedWith(currentAABP.Id, UserRole);

		newEvent = new EDM_IABP_gne__c();
		selectedAABPs = new List<SelectOption>();
		jointAABPsToSelect = new List<SelectOption>();
		relatedIABPs = new List<IABPWrapper>();
		attachments = new List<EDM_Attachment_gne__c>();
		populateJointAABPs();
		PlanYear = currentAABP.EDM_Plan_Year_gne__c;

		retrieveRelatedIABPs();

		retrieveAttachments();

		Map<String, String> leadNames = EDM_ABM_Utils.getAABPNames(currentAABP.Id);
		ABLeadName = leadNames.get('EDM_AB_Lead_gne__c');
		VendorLeadName = leadNames.get('EDM_Vendor_Lead_gne__c');
		ABSManagerName = leadNames.get('EDM_ABS_Manager_gne__c');

		currentAABP.EDM_Share_Comment_gne__c = null;
	}

	public PageReference initOverride(){
		Boolean isFinalized = [SELECT EDM_Finalized_gne__c FROM EDM_AABP_gne__c WHERE Id = :currentAABP.Id LIMIT 1].EDM_Finalized_gne__c;
		if(!isFinalized){
			PageReference pr = Page.EDM_AABP_Edit_Create;
			pr.getParameters().put('id',currentAABP.Id);
			pr.getParameters().put('retURL', '/apex/EDM_AABP_List_View');
			pr.setRedirect(true);
			return pr;
		}
		return super.init();
	}

	public void populateJointAABPs() {
		jointAABPsToSelect = getJointAABPs();
		system.debug('$$jointAABPsToSelect ' + jointAABPsToSelect);
	}

	public List<SelectOption> getJointAABPs() {
		List<SelectOption> aabpsSelectOptions = new List<SelectOption>();
		List<EDM_AABP_gne__c> listAABPs = new List<EDM_AABP_gne__c>();
		listAABPs.addAll([SELECT Id, EDM_Group_gne__c, EDM_Unit_gne__c, EDM_Team_gne__c, Name 
						FROM EDM_AABP_gne__c
						WHERE EDM_Plan_Year_gne__c = :currentAABP.EDM_Plan_Year_gne__c
						AND Id != :currentAABP.Id]);
		for (EDM_AABP_gne__c aabp : listAABPs) {
			aabpsSelectOptions.add(new SelectOption(aabp.Id, aabp.EDM_Group_gne__c + ' ' + aabp.EDM_Unit_gne__c + ' ' + aabp.EDM_Team_gne__c + ' ' + aabp.Name));
		}

		return aabpsSelectOptions;
	}
    
    public List<SelectOption> getEventFocusPicklist() {
        
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('', '--None--'));

		Schema.DescribeFieldResult fieldResult = EDM_IABP_gne__c.EDM_Event_Focus_gne__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

		for(Schema.PicklistEntry f : ple)
		{
			options.add(new SelectOption(f.getValue(), f.getLabel()));
		}
		return options;
	}

	public void retrieveAttachments() {
		attachments.clear();
		attachments.addAll(retrieveAttachmentsFor(currentAABP.Id));
	}

	private static List<EDM_Attachment_gne__c> retrieveAttachmentsFor(Id aabpId) {
		return [SELECT Id, Name, EDM_Link_gne__c, CreatedDate FROM EDM_Attachment_gne__c WHERE EDM_Parent_AABP_gne__c = :aabpId];
	}

	public PageReference addEvent() {
		
		List<String> jointAABPsIds = new List<String>();
		for (SelectOption sso : selectedAABPs) {
			jointAABPsIds.add(sso.getValue());
		}
		newEvent.EDM_Ad_Hoc_Event_gne__c = getIsAbsUser() != true ? true : !newEvent.EDM_Ad_Hoc_Event_gne__c;
		newEvent.EDM_Parent_AABP_gne__c = currentAABP.Id;
		newEvent.RecordTypeId = [SELECT Id, SobjectType, Name FROM RecordType WHERE Name = 'IABP' and SobjectType ='EDM_IABP_gne__c' LIMIT 1].Id;
		newEvent.EDM_IABP_Version_gne__c = 0;
		newEvent.EDM_Status_gne__c = 'IABP Not Started';
		newEvent.EDM_Joint_AABP_gne__c = String.join(jointAABPsIds, ',');
		newEvent.EDM_Year_gne__c = currentAABP.EDM_Plan_Year_gne__c;
		newEvent.EDM_Primary_AB_Lead_gne__c = currentAABP.EDM_AB_Lead_gne__c;
		newEvent.OwnerId = currentAABP.EDM_ABS_Manager_gne__c;
		Map<String, String> BlueTextsInputs = EDM_IABP_Utils.getBlueTexts(null,'Both');
		EDM_IABP_Utils.populateDefaultDuties(newEvent, BlueTextsInputs);
		insert newEvent;

		shareIABP(jointAABPsIds);

		retrieveRelatedIABPs();
		update currentAABP;

		newEvent = new EDM_IABP_gne__c();
		selectedAABPs = new List<SelectOption>();
		return null;
	}

	private void shareIABP(List<String> jointAABPsIds) {
		Set<Id> uShareIds = EDM_ABM_Utils.getUserIdsToShareWithBaseOnAABPs(currentAABP, jointAABPsIds);
		uShareIds.add(UserInfo.getUserId()); //add current user for ad-hoc in case when current user is not ab lead or vandor 
		uShareIds.addAll(EDM_ABM_Utils.getUserIdsForRole(EDM_ABM_Utils.ABS));

		List<User> uShare = EDM_ABM_Utils.getUsers(uShareIds);
		EDM_ABM_Utils.shareRecord(newEvent.Id, uShare, EDM_ABM_Utils.AL_EDIT, EDM_ABM_Utils.SHARE_DIRECTCHILD);
	}

	public PageReference cancelEvent() {
		EDM_IABP_gne__c cancelIABP = [SELECT Id, EDM_Canceled_gne__c FROM EDM_IABP_gne__c WHERE Id = :CancelId];
		cancelIABP.EDM_Canceled_gne__c = true;
		cancelIABP.EDM_Status_gne__c = 'Canceled';
		cancelIABP.EDM_Cancel_Reason_gne__c = this.CancelReason;
		update cancelIABP;
		
		retrieveRelatedIABPs();
		update currentAABP;
		return null;
	}

	public PageReference deleteEvent() {
		List<EDM_IABP_gne__c> iabpsToDelete = new List<EDM_IABP_gne__c>(); 		
		List<EDM_IABP_gne__c> iabps = [SELECT Id, EDM_Executive_Summary_gne__c
										FROM EDM_IABP_gne__c
										WHERE Id = :EventId];

		if (iabps.size() > 0) {
			EDM_IABP_gne__c parentIABP = iabps[0];
			iabpsToDelete.add(parentIABP);
		
			List<EDM_IABP_gne__c> relatedEvents = [SELECT Id
											FROM EDM_IABP_gne__c 
											WHERE EDM_Parent_IABP_gne__c = :parentIABP.Id
											OR EDM_History_Parent_IABP_gn__c = :parentIABP.Id];
			if (relatedEvents.size() > 0) {
				iabpsToDelete.addAll(relatedEvents);
			}			
		}
		delete iabpsToDelete;
		retrieveRelatedIABPs();
		update currentAABP;
		return null;
	}

	public PageReference removeAttachment() {
		try {
			EDM_ABM_Utils.deleteAttachement(attachToDel);
		}
		catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Could not delete Attachment! ' + ex.getMessage()));
		}

		for (Integer i = 0; i < attachments.size(); i++) {
			if (attachments[i].id == attachToDel) {
				attachments.remove(i);
				break;
			}
		}
		return null;
	}

	@RemoteAction
	public static Integer getAttachmentCount(Id aabpId) {
		return retrieveAttachmentsFor(aabpId).size();
	}

	public PageReference goBack() {
		PageReference pr;
		String retURL = System.currentPageReference().getParameters().get('retURL');

		if (retURL == null) {
			pr = new PageReference('/apex/EDM_AABP_List_View');
			pr.setRedirect(true);
		}
		else {
			pr = new PageReference(retURL);
			pr.setRedirect(true);
		}
		return pr;
	}

	public PageReference shareAABP() {
		if (currentAABP != null && currentAABP.Id != null) {
			Set<Id> uIdList = new Set<Id>();
			for (SelectOption so : UsersSharedWith) {
				uIdList.add(so.getValue());
			}
			List<Id> uShareAdd = EDM_ABM_Utils.setSharing(currentAABP.Id, uIdList, UserRole);

			if (!uShareAdd.isEmpty()) {
				update currentAABP; //save share comment for notification
			
				EDM_ABM_Email_Notifications.onAABPShare(currentAABP, uShareAdd);
			}

			//clear comment, because it is only needed for notification and new share should not show previous comment
			currentAABP.EDM_Share_Comment_gne__c = null;
			update currentAABP;
		}
		
		return null;
	}

	public Boolean getIsAbsUser() {
		return UserRole == EDM_ABM_Utils.ABS;
	}

	public Boolean getIsABPlanner() {
		return UserRole == EDM_ABM_Utils.ABLEAD || UserRole == EDM_ABM_Utils.VDST_ABM;
	}

	public List<User> getABLeads() {
		List<User> pickList = EDM_ABM_Utils.getUsersForRole(EDM_ABM_Utils.ABLEAD);
		pickList.addAll(EDM_ABM_Utils.getUsersForRole(EDM_ABM_Utils.VDST_ABM));
		return pickList;
	}

	public List<User> getVendorLeads() {
		List<User> pickList = EDM_ABM_Utils.getUsersForRole(EDM_ABM_Utils.ABLEAD);
		pickList.addAll(EDM_ABM_Utils.getUsersForRole(EDM_ABM_Utils.VDST_ABM));
		return pickList;
	}

	public List<User> getABSManagers() {
		return EDM_ABM_Utils.getUsersForRole(EDM_ABM_Utils.ABS);
	}

	public PageReference updateManagers() {
		update currentAABP;
		List<User> shareWith = [SELECT Id, Name, IsActive FROM User WHERE Id IN (:currentAABP.EDM_AB_Lead_gne__c, :currentAABP.EDM_Vendor_Lead_gne__c, :currentAABP.EDM_ABS_Manager_gne__c)];
		EDM_ABM_Utils.shareRecord(currentAABP.Id, shareWith, EDM_ABM_Utils.AL_EDIT, EDM_ABM_Utils.SHARE_DIRECT);
		EDM_ABM_Utils.changeOwner(currentAABP.Id, currentAABP.EDM_ABS_Manager_gne__c);
		return null;
	}

	public PageReference updateDetail() {
		update currentAABP;
		return null;
	}

	public PageReference deleteAabp() {	
		if(TotalMeetings > 0 || currentAABP.EDM_Canceled_gne__c > 0) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Cannot delete AABP when there are related events (IABPs) present.'));
			return null;
		}

		if (currentAABP.Id != null) {
			delete currentAABP;
		}

		PageReference pr = new PageReference('/apex/EDM_AABP_List_View');
		pr.setRedirect(true);
		return pr;
	}

	public List<SelectOption> getCancelReasons()
	{
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('', '--None--'));

		Schema.DescribeFieldResult fieldResult = EDM_IABP_gne__c.EDM_Cancel_Reason_gne__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

		for(Schema.PicklistEntry f : ple)
		{
			options.add(new SelectOption(f.getValue(), f.getLabel()));
		}
		return options;
	}

	private void retrieveRelatedIABPs() {
		Integer count = 1;
		relatedIABPs.clear();
		for (EDM_IABP_gne__c rIABP : [SELECT Id, Name, EDM_Start_Date_gne__c, EDM_Estimated_Quarter_gne__c, 
												EDM_Canceled_gne__c, EDM_Optional_Detail_gne__c, EDM_Event_Name_gne__c, 
												EDM_Type_of_Event_gne__c, EDM_Ad_Hoc_Event_gne__c,
												EDM_Cancel_Reason_gne__c, EDM_Status_gne__c, EDM_Name_gne__c, EDM_Year_gne__c,
												EDM_Event_Focus_gne__c, EDM_Joint_AABP_gne__c,
												(SELECT EDM_Spend_Status_gne__c FROM EDM_Spends__r)
 										FROM EDM_IABP_gne__c
										WHERE EDM_Parent_AABP_gne__c = :currentAABP.Id
										AND EDM_History_Parent_IABP_gn__c = null										
										AND EDM_Executive_Summary_gne__c = false
										ORDER BY Name]) {
			relatedIABPs.add(new IABPWrapper(rIABP, count));
			count++;
		}
		addInfoAboutExeSumToRelatedIABPs();

		for (IABPWrapper iabp : relatedIABPs) {
			EDM_ActionManager actionManager = new EDM_ActionManager(iabp, UserRole);
			iabp.actions = actionManager.getPossibleActions();
		}

		updateCurrentAABPCount();
	}

	private void addInfoAboutExeSumToRelatedIABPs() {
		Map<Id, EDM_IABP_gne__c> relatedExeSumByIABP = new Map<Id, EDM_IABP_gne__c>();
		for (EDM_IABP_gne__c exesum : [SELECT Id, EDM_Parent_IABP_gne__c, 
								EDM_ExeSum_Status_gne__c
							FROM EDM_IABP_gne__c
							WHERE EDM_Parent_AABP_gne__c = :currentAABP.Id AND
								EDM_Historical_gne__c = false AND
								EDM_Executive_Summary_gne__c = true]) {
			relatedExeSumByIABP.put(exesum.EDM_Parent_IABP_gne__c, exesum);
		}

		for (IABPWrapper iabp : relatedIABPs) {
			EDM_IABP_gne__c exesum = relatedExeSumByIABP.get(iabp.item.id);
			if (exesum != null) {
				iabp.ExeSum_Id = exesum.Id;
				iabp.exesumStatus = exesum.EDM_ExeSum_Status_gne__c;
			}
		}
	}

	private void updateCurrentAABPCount() {
		currentAABP.EDM_Canceled_gne__c = 0;
		currentAABP.EDM_Ad_Hoc_gne__c = 0;
		currentAABP.EDM_CAB_gne__c = 0;
		currentAABP.EDM_NAB_gne__c = 0;
		currentAABP.EDM_Other_gne__c = 0;
		currentAABP.EDM_RAB_gne__c = 0;
		currentAABP.EDM_Combo_gne__c = 0;
		TotalMeetings = 0;
		for (EDM_IABP_gne__c iabp : EDM_ABM_Utils.retrieveRelatedIABPsWithoutSharing(currentAABP.Id)) {
			if (iabp.EDM_Canceled_gne__c){
				currentAABP.EDM_Canceled_gne__c ++;
			} else if (iabp.EDM_Ad_Hoc_Event_gne__c){
				currentAABP.EDM_Ad_Hoc_gne__c ++;
				TotalMeetings ++;
			} else if(iabp.EDM_Type_of_Event_gne__c == 'CAB'){
				currentAABP.EDM_CAB_gne__c ++;
				TotalMeetings ++;
			} else if(iabp.EDM_Type_of_Event_gne__c == 'NAB'){
				currentAABP.EDM_NAB_gne__c ++;
				TotalMeetings ++;
			} else if(iabp.EDM_Type_of_Event_gne__c == 'Other'){
				currentAABP.EDM_Other_gne__c ++;
				TotalMeetings ++;
			} else if(iabp.EDM_Type_of_Event_gne__c == 'RAB'){
				currentAABP.EDM_RAB_gne__c ++;
				TotalMeetings ++;
			} else if(iabp.EDM_Type_of_Event_gne__c == 'Combo'){
				currentAABP.EDM_Combo_gne__c ++;
				TotalMeetings ++;
			}
		}
	}


	class EDM_Action {
		public String name {get; private set;}
		public Boolean displayActionSeparator {get; set;}

		public EDM_Action(String name) {
			this.name = name;
			this.displayActionSeparator = true;
		}
	}


	private class EDM_ActionManager {
		private List<EDM_Action> actions;
		private IABPWrapper iabpWrapper;
		private String UserRole;

		public EDM_ActionManager(IABPWrapper iabpWrapper, String UserRole) {
			this.iabpWrapper = iabpWrapper;
			this.UserRole = UserRole;
			actions = new List<EDM_Action>();

			List<String> rolesPlanners = new  List<String> {EDM_ABM_Utils.ABLEAD, EDM_ABM_Utils.VDST_ABM};
			List<String> rolesPlannersManagers = new List<String> {EDM_ABM_Utils.ABLEAD, EDM_ABM_Utils.VDST_ABM, EDM_ABM_Utils.ABS};
			List<String> rolesReviewers = new List<String> {EDM_ABM_Utils.ABREVIEWER, EDM_ABM_Utils.ABREVIEWER_NO_LIC};
			List<String> rolesManagersReviewers = new List<String> {EDM_ABM_Utils.ABS, EDM_ABM_Utils.ABREVIEWER, EDM_ABM_Utils.ABREVIEWER_NO_LIC};
			List<String> rolesPlannersManagersReviewers = new List<String>();
			rolesPlannersManagersReviewers.addAll(rolesManagersReviewers);
			rolesPlannersManagersReviewers.addAll(rolesPlanners);

			//IABP Not Started	PMR	PM					PMR	PM		M
			addToLinksIfStatus('IABP Not Started', 'View IABP', rolesPlannersManagersReviewers);
			addToLinksIfStatus('IABP Not Started', 'Update IABP', rolesPlannersManagers);
			addToLinksIfStatus('IABP Not Started', 'View Attendees and Documents', rolesPlannersManagersReviewers);
			addToLinksIfStatus('IABP Not Started', 'Update Attendees and Documents', rolesPlannersManagers);
			addToLinksIfStatus('IABP Not Started', 'Cancel', EDM_ABM_Utils.ABS);
			addToLinksIfStatus('IABP Not Started', 'Delete Event', EDM_ABM_Utils.ABS);

			//IABP In Progress	PMR	P					PMR	PM		M
			addToLinksIfStatus('IABP In Progress', 'View IABP', rolesPlannersManagersReviewers);
			addToLinksIfStatus('IABP In Progress', 'Update IABP', rolesPlanners);
			addToLinksIfStatus('IABP In Progress', 'View Attendees and Documents', rolesPlannersManagersReviewers);
			addToLinksIfStatus('IABP In Progress', 'Update Attendees and Documents', rolesPlannersManagers);
			addToLinksIfStatus('IABP In Progress', 'Cancel', EDM_ABM_Utils.ABS);
			addToLinksIfStatus('IABP In Progress', 'Superuser Update', EDM_ABM_Utils.ABS);
			addToLinksIfStatus('IABP In Progress', 'Delete Event', EDM_ABM_Utils.ABS);

			//IABP Under Review	PMR		MR				PMR	PM		M
			addToLinksIfStatus('IABP Under Review', 'View IABP', rolesPlannersManagersReviewers);
			addToLinksIfStatus('IABP Under Review', 'ABS Review IABP', EDM_ABM_Utils.ABS); //'ABS Review IABP' open EDM_IABP_Edit_Create page with link label 'Review IABP'
			addToLinksIfStatus('IABP Under Review', 'Review IABP', rolesReviewers);
			addToLinksIfStatus('IABP Under Review', 'View Attendees and Documents', rolesPlannersManagersReviewers);
			addToLinksIfStatus('IABP Under Review', 'Update Attendees and Documents', rolesPlannersManagers);
			addToLinksIfStatus('IABP Under Review', 'Cancel', EDM_ABM_Utils.ABS);
			addToLinksIfStatus('IABP Under Review', 'Superuser Update', EDM_ABM_Utils.ABS);
			addToLinksIfStatus('IABP Under Review', 'Delete Event', EDM_ABM_Utils.ABS);

			List<String> rolesApprovers = new List<String> {EDM_ABM_Utils.ABAPPROVER, EDM_ABM_Utils.ABAPPROVER_NO_LIC};
			List<String> rolesPlannersManagersReviewersApprovers = new List<String>();
			rolesPlannersManagersReviewersApprovers.addAll(rolesPlannersManagersReviewers);
			rolesPlannersManagersReviewersApprovers.addAll(rolesApprovers);

			//IABP Submitted for Approval	PMR		A				PMRA			M
			addToLinksIfStatus('IABP Submitted for Approval', 'View IABP', rolesPlannersManagersReviewers);
			addToLinksIfStatus('IABP Submitted for Approval', 'Review IABP', rolesApprovers);
			addToLinksIfStatus('IABP Submitted for Approval', 'View Attendees and Documents', rolesPlannersManagersReviewersApprovers);
			addToLinksIfStatus('IABP Submitted for Approval', 'Cancel', EDM_ABM_Utils.ABS);
			addToLinksIfStatus('IABP Submitted for Approval', 'Superuser Update', EDM_ABM_Utils.ABS);
			addToLinksIfStatus('IABP Submitted for Approval', 'Delete Event', EDM_ABM_Utils.ABS);

			//IABP Approved	PMRA	PM					PMRA	PM		M
			addToLinksIfStatus('IABP Approved', 'View IABP', rolesPlannersManagersReviewersApprovers);
			addToLinksIfStatus('IABP Approved', 'Update IABP', rolesPlannersManagers);
			addToLinksIfStatus('IABP Approved', 'View Attendees and Documents', rolesPlannersManagersReviewersApprovers);
			addToLinksIfStatus('IABP Approved', 'Update Attendees and Documents', rolesPlannersManagers);
			addToLinksIfStatus('IABP Approved', 'Cancel', EDM_ABM_Utils.ABS);
			addToLinksIfStatus('IABP Approved', 'Superuser Update', EDM_ABM_Utils.ABS);

			//Revising Approved IABP	PMRA	P					PMRA	PM		M
			addToLinksIfStatus('Revising Approved IABP', 'View IABP', rolesPlannersManagersReviewersApprovers);
			addToLinksIfStatus('Revising Approved IABP', 'Update IABP', rolesPlanners);
			addToLinksIfStatus('Revising Approved IABP', 'View Attendees and Documents', rolesPlannersManagersReviewersApprovers);
			addToLinksIfStatus('Revising Approved IABP', 'Update Attendees and Documents', rolesPlannersManagers);
			addToLinksIfStatus('Revising Approved IABP', 'Cancel', EDM_ABM_Utils.ABS);
			addToLinksIfStatus('Revising Approved IABP', 'Superuser Update', EDM_ABM_Utils.ABS);

			//Re-Reviewing Approved IABP	PMRA		MR				PMRA	PM		M
			addToLinksIfStatus('Re-Reviewing Approved IABP', 'View IABP', rolesPlannersManagersReviewersApprovers);
			addToLinksIfStatus('Re-Reviewing Approved IABP', 'Update IABP', EDM_ABM_Utils.ABS);
			addToLinksIfStatus('Re-Reviewing Approved IABP', 'Review IABP', rolesReviewers);
			addToLinksIfStatus('Re-Reviewing Approved IABP', 'View Attendees and Documents', rolesPlannersManagersReviewersApprovers);
			addToLinksIfStatus('Re-Reviewing Approved IABP', 'Update Attendees and Documents', rolesPlannersManagers);
			addToLinksIfStatus('Re-Reviewing Approved IABP', 'Cancel', EDM_ABM_Utils.ABS);
			addToLinksIfStatus('Re-Reviewing Approved IABP', 'Superuser Update', EDM_ABM_Utils.ABS);

			List<String> rolesPlannersManagersApprovers = new List<String>();
			rolesPlannersManagersApprovers.addAll(rolesPlannersManagers);
			rolesPlannersManagersApprovers.addAll(rolesApprovers);

			//Event Occurred	PMRA			PMA	PM		PMRA	PM		
			addToLinksIfStatus('Event Occurred', 'View IABP', rolesPlannersManagersReviewersApprovers);
			addToLinksIfStatus('Event Occurred', 'View ExeSum', rolesPlannersManagersApprovers);
			addToLinksIfStatus('Event Occurred', 'Update ExeSum', rolesPlannersManagers);
			addToLinksIfStatus('Event Occurred', 'View Spend', rolesPlannersManagers);
			if (iabpWrapper.spendStatus != 'Save & Finalize') {
				addToLinksIfStatus('Event Occurred', 'Update Spend', rolesPlannersManagers);
			}
			addToLinksIfStatus('Event Occurred', 'View Attendees and Documents', rolesPlannersManagersReviewersApprovers);
			addToLinksIfStatus('Event Occurred', 'Update Attendees and Documents', rolesPlannersManagers);
			addToLinksIfStatus('Event Occurred', 'Superuser Update', EDM_ABM_Utils.ABS);

			//Executive Summary in Progress	PMRA			PMA	P		PMRA	PM		
			addToLinksIfStatus('Executive Summary in Progress', 'View IABP', rolesPlannersManagersReviewersApprovers);
			addToLinksIfStatus('Executive Summary in Progress', 'View ExeSum', rolesPlannersManagersApprovers);
			addToLinksIfStatus('Executive Summary in Progress', 'Update ExeSum', rolesPlanners);
			addToLinksIfStatus('Executive Summary in Progress', 'View Spend', rolesPlannersManagers);
			if (iabpWrapper.spendStatus != 'Save & Finalize') {
				addToLinksIfStatus('Executive Summary in Progress', 'Update Spend', rolesPlannersManagers);
			}
			addToLinksIfStatus('Executive Summary in Progress', 'View Attendees and Documents', rolesPlannersManagersReviewersApprovers);
			addToLinksIfStatus('Executive Summary in Progress', 'Update Attendees and Documents', rolesPlannersManagers);
			addToLinksIfStatus('Executive Summary in Progress', 'Superuser Update', EDM_ABM_Utils.ABS);
			
			//Executive Summary in Review	PMRA			PMA		M	PMRA	PM		
			addToLinksIfStatus('Executive Summary in Review', 'View IABP', rolesPlannersManagersReviewersApprovers);
			addToLinksIfStatus('Executive Summary in Review', 'View ExeSum', rolesPlannersManagersApprovers);
			addToLinksIfStatus('Executive Summary in Review', 'Review ExeSum', EDM_ABM_Utils.ABS);
			addToLinksIfStatus('Executive Summary in Review', 'View Spend', rolesPlannersManagers);
			if (iabpWrapper.spendStatus != 'Save & Finalize') {
				addToLinksIfStatus('Executive Summary in Review', 'Update Spend', rolesPlannersManagers);
			}
			addToLinksIfStatus('Executive Summary in Review', 'View Attendees and Documents', rolesPlannersManagersReviewersApprovers);
			addToLinksIfStatus('Executive Summary in Review', 'Update Attendees and Documents', rolesPlannersManagers);
			addToLinksIfStatus('Executive Summary in Review', 'Superuser Update', EDM_ABM_Utils.ABS);

			//PTD in Progress	PMRA			PMA		(M)	PMRA		PM	
			addToLinksIfStatus('PTD in Progress', 'View IABP', rolesPlannersManagersReviewersApprovers);
			addToLinksIfStatus('PTD in Progress', 'View ExeSum', rolesPlannersManagersApprovers);
			addToLinksIfStatusAndExeSumStatus('PTD in Progress', 'Finalized', 'Review ExeSum', EDM_ABM_Utils.ABS);
			addToLinksIfStatus('PTD in Progress', 'View Spend', rolesPlannersManagers);
			if (iabpWrapper.spendStatus != 'Save & Finalize') {
				addToLinksIfStatus('PTD in Progress', 'Update Spend', rolesPlannersManagers);
			}
			addToLinksIfStatus('PTD in Progress', 'View Attendees and Documents', rolesPlannersManagersReviewersApprovers);
			addToLinksIfStatus('PTD in Progress', 'View Pull Thru Docs', rolesPlannersManagers);
			addToLinksIfStatus('PTD in Progress', 'Update Attendees and Documents');
			addToLinksIfStatus('PTD in Progress', 'Superuser Update', EDM_ABM_Utils.ABS);


			//PTD Complete	PMRA			PMA			PRMA		PM		
			addToLinksIfStatus('PTD complete', 'View IABP', rolesPlannersManagersReviewersApprovers);
			addToLinksIfStatus('PTD complete', 'View ExeSum', rolesPlannersManagersApprovers);
			addToLinksIfStatus('PTD complete', 'View Spend', rolesPlannersManagers);
			if (iabpWrapper.spendStatus != 'Save & Finalize') {
				addToLinksIfStatus('PTD complete', 'Update Spend', rolesPlannersManagers);
			}
			addToLinksIfStatus('PTD complete', 'View Attendees and Documents', rolesPlannersManagersReviewersApprovers);
			addToLinksIfStatus('PTD complete', 'View Pull Thru Docs', rolesPlannersManagers);
			addToLinksIfStatus('PTD complete', 'Update Attendees and Documents');
			addToLinksIfStatus('PTD complete', 'Superuser Update', EDM_ABM_Utils.ABS);

			//Event Canceled	PRMA						PRMA			
			addToLinksIfStatus('Canceled', 'View IABP', rolesPlannersManagersReviewersApprovers);
			addToLinksIfStatus('Canceled', 'View Spend', rolesPlannersManagers);
			if (iabpWrapper.spendStatus == 'Save') {
				addToLinksIfStatus('Canceled', 'Update Spend', EDM_ABM_Utils.ABS);
			}
			addToLinksIfStatus('Canceled', 'View Attendees and Documents', rolesPlannersManagersReviewersApprovers);
			addToLinksIfStatus('Canceled', 'Update Attendees and Documents');
			addToLinksIfStatus('Canceled', 'Superuser Update', EDM_ABM_Utils.ABS);

			if (!actions.isEmpty()) {
				actions.get(actions.size() - 1).displayActionSeparator = false;
			}
		}

		public List<EDM_Action> getPossibleActions() {
			return actions;
		}

		/*private void addToLinksIf_StatusNot(String status, String action) {
			if (iabpWrapper.item.EDM_Status_gne__c != status) {
				actions.add(new EDM_Action(action));
			}
		}*/

		private void addToLinksIfStatus(String status, String action) {
			if (iabpWrapper.item.EDM_Status_gne__c == status) {
				actions.add(new EDM_Action(action));
			}
		}

		private void addToLinksIfStatus(String status, String action, String forRole) {
			if (UserRole == forRole && iabpWrapper.item.EDM_Status_gne__c == status) {
				actions.add(new EDM_Action(action));
			}
		}

		private void addToLinksIfStatusAndExeSumStatus(String status, String exesumStatus, String action, String forRole) {
			if (UserRole == forRole && iabpWrapper.item.EDM_Status_gne__c == status && iabpWrapper.exesumStatus == exesumStatus) {
				actions.add(new EDM_Action(action));
			}
		}

		private void addToLinksIfStatus(String status, String action, List<String> forRoles) {
			Boolean hasRole = false;
			for (String roleNeeded : forRoles) {
				if (UserRole == roleNeeded) {
					hasRole = true;
				}
			}
			if (hasRole && iabpWrapper.item.EDM_Status_gne__c == status) {
				actions.add(new EDM_Action(action));
			}
		}
	}
}