public without sharing class EDM_AB_Events_List_View_Ext{

	public String accountId { get; set; }
	public Boolean areValid { get; set; }
	public String selected { get; set; }

	private List<EDM_IABP_gne__c> selectedIABPs;
	private List<EDM_IABP_gne__c> exeSum;

	public EDM_AB_Events_List_View_Ext (EDM_AB_Events_List_View_Controller controller) {
		accountId = ApexPages.currentPage().getParameters().get('account');
	}

	public PageReference goBack() {
		PageReference pr;
		String retURL = System.currentPageReference().getParameters().get('retURL');

		if (retURL == null) {
			pr = new PageReference('/apex/gne_sfa2_account_layout?id=' + accountId);
			pr.setRedirect(true);
		}
		else {
			pr = new PageReference(retURL);
			pr.setRedirect(true);
		}
		return pr;
	}

	public void saveAdvisors() {
		areValid=true;

		List<String> iabpIds = selected.split(';');
		List<EDM_Attendee_gne__c> attendees = [SELECT EDM_Parent_IABP_gne__c FROM EDM_Attendee_gne__c 
												 WHERE EDM_Account_gne__c != null 
												 AND EDM_Account_gne__c != '' 
												 AND EDM_Type_gne__c = 'HCP/Business Professional'
												 AND EDM_Parent_IABP_gne__c IN :iabpIds];

		

		selectedIABPs = [SELECT Id, Name, EDM_Parent_IABP_gne__c, EDM_Executive_Summary_gne__c FROM EDM_IABP_gne__c WHERE Id IN :iabpIds];
		exeSum = [SELECT Id, Name, EDM_Parent_IABP_gne__c FROM EDM_IABP_gne__c WHERE EDM_Parent_IABP_gne__c IN :iabpIds AND EDM_Executive_Summary_gne__c = true AND EDM_Historical_gne__c = false];

		List<EDM_Recently_Chosen_IABP_gne__c> recentlyChosen = retrieveRecentlyChosenWith(getIdSetFromList('Id', selectedIABPs));
		Set<Id> iabpsIdsInRecentlyChosen = getIdSetFromList('EDM_IABP_gne__c', recentlyChosen);

		List<EDM_Attendee_gne__c> attendeesToInsert = new List<EDM_Attendee_gne__c>();
		List<EDM_Attendee_gne__c> syncAttendeesToInsert = new List<EDM_Attendee_gne__c>();

		Map<Id, Id> iabpToExeSum = new Map<Id, Id>();

		for (EDM_IABP_gne__c iabp : selectedIABPs) {            
			if (hasEventReachedMaxAdvisors(attendees, iabp.Id)) {
				areValid = false;
				break;
			} 
			else {
				if (!iabpsIdsInRecentlyChosen.contains(iabp.Id)) {
					recentlyChosen.add(new EDM_Recently_Chosen_IABP_gne__c(
												EDM_IABP_gne__c = iabp.Id, 
												EDM_User_gne__c = UserInfo.getUserId()
											));
				}

				String exeSumEvent = hasEventExeSum(exeSum, iabp.Id);
				String address = EDM_IABP_Utils.getAddress(accountId);

				EDM_Attendee_gne__c att1 = new EDM_Attendee_gne__c();
				att1.EDM_Account_gne__c = accountId;
				att1.EDM_Parent_IABP_gne__c = iabp.Id;
				att1.EDM_Address_gne__c = address;
				att1.EDM_Type_gne__c = 'HCP/Business Professional';
				att1.EDM_System_Type_gne__c = 'Advisor';
				att1.EDM_Role_gne__c = 'Advisor';
				att1.Originate_from_ExeSum_gne__c = exeSumEvent != '';
				att1.EDM_ID_For_Comparator_gne__c = iabp.Name + '_' + EDM_ABM_Utils.getRandomID();
				attendeesToInsert.add(att1);

				if (exeSumEvent != '') { //if IABP has ExeSum -> add Account to ExeSum as well                    
					EDM_Attendee_gne__c att = new EDM_Attendee_gne__c();
					att.EDM_Account_gne__c = accountId;
					att.EDM_Parent_IABP_gne__c = exeSumEvent;
					att.EDM_Address_gne__c = address;
					att.EDM_Type_gne__c = 'HCP/Business Professional';
					att.EDM_System_Type_gne__c = 'Advisor';
					att.EDM_Role_gne__c = 'Advisor';
					att.Originate_from_ExeSum_gne__c = exeSumEvent != '';
					att.EDM_ID_For_Comparator_gne__c = iabp.Name + '_' + EDM_ABM_Utils.getRandomID();
					syncAttendeesToInsert.add(att);
					iabpToExeSum.put(iabp.Id, exeSumEvent);
				} 
			}
		}

		if (areValid) {
			List<EDM_Attendee_gne__c> newAttendeeRecords = new List<EDM_Attendee_gne__c>();
			newAttendeeRecords.addAll(attendeesToInsert);
			newAttendeeRecords.addAll(syncAttendeesToInsert);
			insert newAttendeeRecords;
			
			saveCachedComments(newAttendeeRecords);

			Map<Id, EDM_Attendee_gne__c> attendeeRecordByParentEvent = new Map<Id, EDM_Attendee_gne__c>();
			for (EDM_Attendee_gne__c att : newAttendeeRecords) {
				attendeeRecordByParentEvent.put(att.EDM_Parent_IABP_gne__c, att);
			}

			for (EDM_Attendee_gne__c att : newAttendeeRecords) {
				if (att.Originate_from_ExeSum_gne__c) {
				   if (!isEventExeSum(att.EDM_Parent_IABP_gne__c)) {
						Id exeSumID = iabpToExeSum.get(att.EDM_Parent_IABP_gne__c);
						att.EDM_Parent_Attendee_gne__c = attendeeRecordByParentEvent.get(exeSumID).Id;
					} 
				}
			}

			update newAttendeeRecords;

			upsert recentlyChosen;
		}
	}

	private void saveCachedComments(List<EDM_Attendee_gne__c> newAttendees) {

		AttendeeChangeReasonForMultipleIABP attReasonHandler = new AttendeeChangeReasonForMultipleIABP();
		Map<Id, EDM_Attendee_gne__c> attendeesByParentIABP = getAttendeeWithAccountNameByParentIABP(newAttendees);

		for (String iabpId : attendeesByParentIABP.keyset()) {
			EDM_Attendees_Documents_Ctr.AttendeeChangeReasonCache reasonCache = new EDM_Attendees_Documents_Ctr.AttendeeChangeReasonCache();
			EDM_Attendees_Documents_Ctr.AttendeeChangeReason cachedChangeReason = reasonCache.getForIABPIdAndRemove(iabpId);
			if (cachedChangeReason != null) {
				cachedChangeReason.attendee = attendeesByParentIABP.get(iabpId);
				attReasonHandler.addReason(cachedChangeReason);
			}
		}

		attReasonHandler.save();
	}

	private Map<Id, EDM_Attendee_gne__c> getAttendeeWithAccountNameByParentIABP(List<EDM_Attendee_gne__c> newAttendees) {
		List<EDM_Attendee_gne__c> attendeesWithAccountName = [SELECT Id, EDM_Account_gne__r.FirstName, EDM_Account_gne__r.LastName, EDM_Parent_IABP_gne__c 
																FROM EDM_Attendee_gne__c WHERE Id IN :newAttendees];
		Map<Id, EDM_Attendee_gne__c> result = new Map<Id, EDM_Attendee_gne__c>();
		for (EDM_Attendee_gne__c attendee : attendeesWithAccountName) {
			result.put(attendee.EDM_Parent_IABP_gne__c, attendee);
		}
		return result;
	}

	public Boolean hasEventReachedMaxAdvisors(List<EDM_Attendee_gne__c> attendees, String event){
		Integer attCount=0;
		for(EDM_Attendee_gne__c att : attendees){
			if(att.EDM_Parent_IABP_gne__c==event){
				attCount++;
			}
		}
		
		return attCount >= 100;
	}

	public String hasEventExeSum(List<EDM_IABP_gne__c> exeSum, String event){
		for(EDM_IABP_gne__c evt : exeSum){
			if(evt.EDM_Parent_IABP_gne__c==event){
				return evt.Id;
			}
		}
		return '';
	}

	private Boolean isEventExeSum(Id eventId) {
		Set<Id> exeSumIDs = new Set<Id>();
		for (EDM_IABP_gne__c exe : exeSum) {
			exeSumIDs.add(exe.Id);
		}

		for (EDM_IABP_gne__c exe : selectedIABPs) {
			if (exe.EDM_Executive_Summary_gne__c) {
				exeSumIDs.add(exe.Id);
			}
		}

		return exeSumIDs.contains(eventId);
	}

	private List<EDM_Recently_Chosen_IABP_gne__c> retrieveRecentlyChosenWith(Set<Id> includedIds) {
		return [SELECT EDM_IABP_gne__c, EDM_User_gne__c,
					EDM_IABP_gne__r.EDM_Group_gne__c, EDM_IABP_gne__r.EDM_Name_gne__c, EDM_IABP_gne__r.EDM_Parent_AABP_gne__r.EDM_Team_gne__c,
					EDM_IABP_gne__r.EDM_Parent_AABP_gne__r.EDM_Unit_gne__c, EDM_IABP_gne__r.EDM_Year_gne__c,
					EDM_IABP_gne__r.EDM_Type_of_Event_gne__c, EDM_IABP_gne__r.EDM_Start_Date_gne__c, EDM_IABP_gne__r.EDM_Location_gne__c
				FROM EDM_Recently_Chosen_IABP_gne__c 
				WHERE EDM_User_gne__c = :UserInfo.getUserId()
					AND EDM_IABP_gne__c IN :includedIds
				ORDER BY CreatedDate DESC];
	}

	private Set<Id> getIdSetFromList(String idFieldName, List<SObject> objList) {
		Set<Id> result = new Set<Id>();
		for (SObject item : objList) {
			result.add((Id)item.get(idFieldName));
		}
		return result;
	}

	private class AttendeeChangeReasonForMultipleIABP {
		private Map<Id, EDM_Attendees_Documents_Ctr.AttendeeChangeReason> iabpToChangeReason;

		public AttendeeChangeReasonForMultipleIABP() {
			iabpToChangeReason = new Map<Id, EDM_Attendees_Documents_Ctr.AttendeeChangeReason>();
		}

		public void addReason(EDM_Attendees_Documents_Ctr.AttendeeChangeReason changeReason) {
			if (changeReason != null && changeReason.parentIABP != null && changeReason.parentIABP.Id != null) {
				iabpToChangeReason.put(changeReason.parentIABP.Id, changeReason);
			}
		}

		public void save() {
			List<EDM_IABP_gne__c> iabpsToAddCommentTo = new List<EDM_IABP_gne__c>();

			for (String iabpId : iabpToChangeReason.keySet()) {
				EDM_Attendees_Documents_Ctr.AttendeeChangeReason changeReason = iabpToChangeReason.get(iabpId);
				EDM_IABP_gne__c iabp = changeReason.parentIABP;
				if (iabp != null) {
					iabp.EDM_Explanation_of_Att_Changes_gne__c = addCommentToFieldValue(iabp.EDM_Explanation_of_Att_Changes_gne__c, iabpToChangeReason.get(iabpId).getFormattedComment());
					iabpsToAddCommentTo.add(iabp);
				}
			}

			if (!iabpsToAddCommentTo.isEmpty()) {
				update iabpsToAddCommentTo;
			}
		}

		private String addCommentToFieldValue(String fieldValue, String commentToAdd) {
			fieldValue = setToEmptyStringIfNull(fieldValue);
			fieldValue = ('<p>' + commentToAdd + '</p>' + fieldValue);
			return fieldValue;
		}

		private String setToEmptyStringIfNull(String strToDenullify) {
			if (strToDenullify == null) {
				strToDenullify = '';
			}
			return strToDenullify;
		}
	}
}