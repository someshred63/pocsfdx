public with sharing class CFAR_TrialReassign_Controller {

	public CFAR_Contact_gne__c currentContact {get; set;}
	public List<SelectOption> currentContactRoles {get; set;}
	public String selectedRole {get; set;}
	public List<CFAR_Team_Member_gne__c> teamMembers {get; set;}
	public Boolean isError {get; set;}
	public Id contactToReassignId {get; set;}
	public Boolean isExternalRole {get; set;}
	public Boolean isEdit {get; set;}

	private List<SelectOption> wholeContactsSearchList;
	private transient List<SelectOption> contactSearchList1;
	private transient List<SelectOption> contactSearchList2;

	public Boolean isAdminOrITAdminProfile {
		get {
			return CFAR_Budget_Utils.isAdminOrITAdminProfile(userinfo.getProfileId());
		}
		set;
	}

	public String sortExpression {
		get;
		set {
			sortExpression = value;
			if (sortFieldOld == null) sortFieldOld = sortExpression;
			if (sortFieldOld == sortExpression) {
				if (sortDirection == 'desc') sortDirection = 'asc';
				else sortDirection = 'desc';
			} else {
				sortDirection = 'desc';
				sortFieldOld = sortExpression;
			}
		}
	}
	private String sortFieldOld;
	public String sortDirection {get; set;}

	public CFAR_TrialReassign_Controller() {
		isEdit = false;
		currentContactRoles = new List<SelectOption>();
		currentContact = [SELECT Search_Name__c, Primary_Role_Function_gne__c, Role_Function_gne__c, Tertiary_Role_Function_gne__c
			FROM CFAR_Contact_gne__c WHERE Id = :ApexPages.currentPage().getParameters().get('id')];

		if (currentContact.Primary_Role_Function_gne__c != null) {
			currentContactRoles.add(new SelectOption(currentContact.Primary_Role_Function_gne__c, currentContact.Primary_Role_Function_gne__c));
		}
		if (currentContact.Role_Function_gne__c != null) {
			currentContactRoles.add(new SelectOption(currentContact.Role_Function_gne__c, currentContact.Role_Function_gne__c));
		}
		if (currentContact.Tertiary_Role_Function_gne__c != null) {
			currentContactRoles.add(new SelectOption(currentContact.Tertiary_Role_Function_gne__c, currentContact.Tertiary_Role_Function_gne__c));
		}

		selectedRole = currentContactRoles[0].getValue();
		populateTrialTable();
	}

	public void populateTrialTable() {
		isExternalRole = CFAR_Team_Controller.externalRoles.contains(selectedRole);
		teamMembers = new List<CFAR_Team_Member_gne__c>();
		String orderBy = sortExpression == null ? 'CFAR_Trial_ref_gne__r.Name' : sortExpression;
		if(sortDirection == null) sortDirection = 'asc';
		for (CFAR_Team_Member_gne__c teamMember : Database.query('SELECT Is_Trial_Primary_Contact_gne__c, Is_Trial_MSL_gne__c, Alerts_gne__c, frm_Function_Role_gne__c, CFAR_Trial_ref_gne__c, CFAR_Trial_ref_gne__r.Name FROM CFAR_Team_Member_gne__c '
			+ 'WHERE CFAR_Trial_ref_gne__r.frm_Trial_Status_ref_gne__c NOT IN(\'' + Label.CFAR_GSTARS_TRIAL_STATUS_CONCLUDED + '\', \'' 
			+ Label.CFAR_GSTARS_TRIAL_STATUS_CANCELLED + '\', \'' 
			+ Label.CFAR_GSTARS_TRIAL_STATUS_PREMATURE_TERMINATION 
			+ '\') AND contact_address_ref_gne__r.CFAR_Contact_ref_gne__c = \'' + currentContact.Id  + '\' AND frm_Function_Role_gne__c = \'' + selectedRole 
			+ '\' AND frm_Is_Inactive_gne__c = false ORDER BY ' + orderBy + ' ' + sortDirection)) {
				teamMember.Alerts_gne__c = false;
				teamMembers.add(teamMember);
		}
	}

	public void initContactOptions() {
		isError = true;
		for (CFAR_Team_Member_gne__c tm : teamMembers) {
			if (tm.Alerts_gne__c == true) {
				isError = false;
				break;
			}
		}

		if (isError) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.CFAR_SELECT_TRIALS_TO_REASSIGN));
		}

		wholeContactsSearchList = new SelectOption[] {};

		for (CFAR_Contact_gne__c c : [SELECT Id, Search_Name__c FROM CFAR_Contact_gne__c WHERE Active_gne__c = true
			AND (Primary_Role_Function_gne__c = :selectedRole OR Role_Function_gne__c = :selectedRole OR Tertiary_Role_Function_gne__c = :selectedRole)
			AND Id != :currentContact.Id
			ORDER BY Search_Name__c]) {
				wholeContactsSearchList.add(new SelectOption(c.Id, c.Search_Name__c));
		}
	}

	public PageReference reassignSelectedTrials() {

		if(contactToReassignId == null){
			isError = true;
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.CFAR_SELECT_CONTACT_TO_REASSIGN));
			return null;
		}

		Set<Id> trialToReassignIds = new Set<Id>();
		for (CFAR_Team_Member_gne__c selectedTeamMember : teamMembers) {
			if (selectedTeamMember.Alerts_gne__c) {
				trialToReassignIds.add(selectedTeamMember.CFAR_Trial_ref_gne__c);
			}
		}

		String trialNames = '';
		CFAR_Team_Member_gne__c[] existingTeamMembers = [SELECT CFAR_Trial_ref_gne__r.Name FROM CFAR_Team_Member_gne__c 
			WHERE contact_address_ref_gne__r.CFAR_Contact_ref_gne__c = :contactToReassignId AND CFAR_Trial_ref_gne__c IN :trialToReassignIds
			AND frm_Is_Inactive_gne__c = false];

		if (!existingTeamMembers.isEmpty()) {
			for (CFAR_Team_Member_gne__c tm : existingTeamMembers) {
				trialNames += tm.CFAR_Trial_ref_gne__r.Name + ',';
			}
			trialNames = trialNames.removeEnd(',');
			isError = true;

			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Cannot update the contact because the replacement contact already exists in the following studies: ' 
				+ trialNames + '. Please un-select those studies and try again.'));
			return null;
		}

		System.Savepoint sp = Database.setSavepoint();

		try{
			CFAR_Team_Member_gne__c[] teamMembersToDeactivate = new List<CFAR_Team_Member_gne__c>();
			CFAR_Team_Member_gne__c[] teamMembersToCreate = new List<CFAR_Team_Member_gne__c>();
			Map<Id, CFAR_Team_Member_Reassign_History_gne__c> reassignmentHistory = new Map<Id, CFAR_Team_Member_Reassign_History_gne__c>();
			Map<Id, CFAR_Trial_gne__c> trialsToUpdate = new Map<Id, CFAR_Trial_gne__c>();
			Id defaultAddress;
			Id defaultAddressType;

			List<CFAR_Contact_Address_JO_gne__c> addressesJO = CFAR_Team_Controller.getActiveAddressForContact(contactToReassignId);
			if (!addressesJO.isEmpty()) {
				defaultAddress = addressesJO.get(0).Id;
				defaultAddressType = addressesJO.get(0).Contact_Address_ref_gne__r.Address_Type_ref_gne__c;
			} else {
				isError = true;
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.CFAR_ADDRESS_NOT_FOUND_FOR_CONTACT));
				return null;
			}

			for (CFAR_Team_Member_gne__c selectedTeamMember : teamMembers) {
				if (selectedTeamMember.Alerts_gne__c) {
					
					teamMembersToCreate.add(new CFAR_Team_Member_gne__c(
						Active_On_gne__c = System.Today(),
						CFAR_Trial_ref_gne__c = selectedTeamMember.CFAR_Trial_ref_gne__c,
						Is_Trial_Primary_Contact_gne__c = selectedTeamMember.Is_Trial_Primary_Contact_gne__c,
						Is_Trial_MSL_gne__c = selectedTeamMember.Is_Trial_MSL_gne__c,
						Function_Role_gne__c = selectedRole,
						contact_address_ref_gne__c = defaultAddress,
						Address_Type_ref_gne__c = defaultAddressType));

					Id trialId = selectedTeamMember.CFAR_Trial_ref_gne__c;
					if(selectedTeamMember.Is_Trial_Primary_Contact_gne__c){
						if(!trialsToUpdate.containsKey(trialId)){
							trialsToUpdate.put(trialId, new CFAR_Trial_gne__c(id = trialId,Genentech_Primary_Contact_ref_gne__c = contactToReassignId));
						} else {
							trialsToUpdate.get(trialId).Genentech_Primary_Contact_ref_gne__c = contactToReassignId;
						}
					}

					if(selectedTeamMember.Is_Trial_MSL_gne__c) {
						if(!trialsToUpdate.containsKey(trialId)){
							trialsToUpdate.put(trialId, new CFAR_Trial_gne__c(id = trialId, MSL_ref_gne__c = contactToReassignId));
						} else {
							trialsToUpdate.get(trialId).MSL_ref_gne__c = contactToReassignId;
						}
					}

					teamMembersToDeactivate.add(
						new CFAR_Team_Member_gne__c(
						Id = selectedTeamMember.Id, 
						Inactive_On_gne__c = System.Today(),
						Is_Trial_Primary_Contact_gne__c = false,
						Is_Trial_MSL_gne__c = false
						));

					reassignmentHistory.put(selectedTeamMember.CFAR_Trial_ref_gne__c, new CFAR_Team_Member_Reassign_History_gne__c(
						CFAR_Trial_ref_gne__c = selectedTeamMember.CFAR_Trial_ref_gne__c,
						Reassigned_From_ref_gne__c = selectedTeamMember.Id));
				}
			}
			CFAR_ConfigUtil.setDisabled('Disabled_Triggers_gne__c', new List<String>{'CFAR_TeamMemberTrigger'});
			update teamMembersToDeactivate;
			insert teamMembersToCreate;
			for (CFAR_Team_Member_gne__c tmToCreate : teamMembersToCreate) {
				reassignmentHistory.get(tmToCreate.CFAR_Trial_ref_gne__c).Reassigned_To_ref_gne__c = tmToCreate.Id;
			}

			insert reassignmentHistory.values();
			CFAR_Utils.setAlreadyProcessed();
			update trialsToUpdate.values();
			CFAR_ConfigUtil.setDisabled('Disabled_Triggers_gne__c', new List<String>{});
			isError = false;
			populateTrialTable();
			return null;

		} catch (Exception e) {
			Database.rollback(sp);
			isError = true;
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
			return null; 
		}
	}

	public void toggleIsEdit(){
		isEdit = !isEdit;
	}

	public List<SelectOption> getContactSearchList1() {
		contactSearchList1 = CFAR_Utils.getContactSearchListPart1(wholeContactsSearchList);
		return contactSearchList1;
	}

	public List<SelectOption> getContactSearchList2() {
		contactSearchList2 = CFAR_Utils.getContactSearchListPart2(wholeContactsSearchList);
		return contactSearchList2;
	}
}