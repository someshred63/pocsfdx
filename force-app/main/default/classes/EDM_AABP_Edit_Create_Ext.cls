public with sharing class EDM_AABP_Edit_Create_Ext extends GNE_SFA2_Dynamic_VF_Edit_Create {

	class EventWrapper implements Comparable {
		public Integer RowNr { get; set; }
		public EDM_IABP_gne__c Event { get; set; }
		public List<String> JointAABPs { get; set; }
		public String JointAABPsDisplay { get; set; }

		public EventWrapper() {
		}

		public EventWrapper(Integer rowNr, EDM_IABP_gne__c event, List<String> jointAABPs) {
			this.RowNr = rowNr;
			this.Event = event;
			this.JointAABPs = jointAABPs;
			this.JointAABPsDisplay = getJointDisplay(jointAABPs);
		}

		private String getJointDisplay(List<String> jointAABPs) {
			JointAABPsDisplay = '';
			List<EDM_AABP_gne__c> jointAABPsList = [SELECT Id, Name, EDM_Group_gne__c, EDM_Unit_gne__c, EDM_Team_gne__c 
											FROM EDM_AABP_gne__c 
											WHERE Id IN :jointAABPs];
			for (EDM_AABP_gne__c aabp : jointAABPsList) {
				JointAABPsDisplay += getJointAABPDisplayName(aabp) + ';';
			}

			return JointAABPsDisplay;
		}

		public List<SelectOption> getSelectedJointAABPsSelectOptions() {
			List<SelectOption> result = new List<SelectOption>();
			List<EDM_AABP_gne__c> listAABPs = [
						SELECT Id, EDM_Group_gne__c, EDM_Unit_gne__c, EDM_Team_gne__c, Name 
							FROM EDM_AABP_gne__c
							WHERE Id IN :this.JointAABPs];

			for (EDM_AABP_gne__c aabp : listAABPs) {
				result.add(new SelectOption(aabp.Id, getJointAABPDisplayName(aabp)));
			}

			return result;
		}

		private String getJointAABPDisplayName(EDM_AABP_gne__c aabp) {
			return aabp.EDM_Group_gne__c + ' ' + aabp.EDM_Unit_gne__c + ' ' + aabp.EDM_Team_gne__c + ' ' + aabp.Name;
		}

		public Integer compareTo(Object compareTo) {
			EventWrapper compareToEvt = (EventWrapper)compareTo;
			Integer returnValue = 0;
			if (Event.EDM_Estimated_Quarter_gne__c > compareToEvt.Event.EDM_Estimated_Quarter_gne__c) {
				returnValue = 1;
			} 
			else if (Event.EDM_Estimated_Quarter_gne__c < compareToEvt.Event.EDM_Estimated_Quarter_gne__c) {
				returnValue = -1;
			}
			else if (Event.EDM_Event_Name_gne__c > compareToEvt.Event.EDM_Event_Name_gne__c) {
				returnValue = 1;
			}
			else if (Event.EDM_Event_Name_gne__c < compareToEvt.Event.EDM_Event_Name_gne__c) {
				returnValue = -1;
			}
			
			return returnValue;
		}
	}

	private List<Id> toDelIABPs;
	private Map<String, Integer> tempValues;

	public EDM_AABP_gne__c currentAABP { get; set; }
	public Boolean isEdit { get; set; }
	public List<EventWrapper> Events { get; set; }
	public List<EDM_IABP_gne__c> IABPs  { get; set; }
	public Integer TotalMeetings { get; set; }
	public Integer CanceledEvts { get; set; }
	public Integer AdHocEvts { get; set; }
	public Integer RowToDel { get; set; }
	public Integer RowToEdit { get; set; }
	public List<SelectOption> selectedAABPs { get; set; }
	public List<SelectOption> jointAABPsToSelect { get; set; }
	public String PlanReceivedDate { get; set; }
	public String PlanApprovedDate { get; set; }
	public String ABLeadName { get;  set; }
	public String VendorLeadName { get; set; }
	public String ABSManagerName { get; set; }

	public EDM_IABP_gne__c newEvt { get; set; }

	public EDM_AABP_gne__c currentAABPToDisplayNameForJustCreatedRecords { get; set; }


	public String group2UnitMapping { get; private set; }
	public String unit2TeamMapping { get; private set; }
	public String selectedUnits { get; set; }
	public String selectedTeams { get; set; }



	public EDM_AABP_Edit_Create_Ext(ApexPages.StandardController controller) {
		super(controller,'/apex/EDM_AABP_Edit_Create');
		this.currentAABP = (EDM_AABP_gne__c)controller.getRecord();

		TotalMeetings = 0;
		CanceledEvts = 0;
		AdHocEvts = 0;
		Events = new List<EventWrapper>();
		newEvt = new EDM_IABP_gne__c();
		selectedAABPs = new List<SelectOption>();
		jointAABPsToSelect = new List<SelectOption>();
		isEdit = false;
		toDelIABPs = new List<Id>();

		tempValues = new Map<String, Integer>();
		tempValues.put('CAB', 0);
		tempValues.put('RAB', 0);
		tempValues.put('NAB', 0);
		tempValues.put('Combo', 0);
		tempValues.put('Other', 0);

		this.group2UnitMapping = EDM_ABM_Utils.retrieveGroup2UnitMapping();
		this.unit2TeamMapping = EDM_ABM_Utils.retrieveUnit2TeamMapping();

		if(myObject == null) {
			myObject = new EDM_AABP_gne__c();
		}

		if (currentAABP.Id != null) {
			
			isEdit = true;
			if (currentAABP.EDM_Plan_Received_gne__c != null) {
				PlanReceivedDate = currentAABP.EDM_Plan_Received_gne__c.format();
			}
			if (currentAABP.EDM_Final_Approval_Received_gne__c != null) {
				PlanApprovedDate = currentAABP.EDM_Final_Approval_Received_gne__c.format();
			}
			TotalMeetings = (currentAABP.EDM_Total_Number_of_Meetings_gne__c == null ? 0 : Integer.valueOf(currentAABP.EDM_Total_Number_of_Meetings_gne__c));

			populateEvents();

			populateJointAABPs();

			ABLeadName = (currentAABP.EDM_AB_Lead_gne__c != null ? currentAABP.EDM_AB_Lead_gne__r.Name : null);
			VendorLeadName = (currentAABP.EDM_Vendor_Lead_gne__c != null ? currentAABP.EDM_Vendor_Lead_gne__r.Name : null);
			ABSManagerName = (currentAABP.EDM_ABS_Manager_gne__c != null ? currentAABP.EDM_ABS_Manager_gne__r.Name : null);
		}
		else {
			IABPs = new List<EDM_IABP_gne__c>();
			currentAABP.EDM_Plan_Year_gne__c = String.valueOf(System.today().year() + 1);
		}

		currentAABPToDisplayNameForJustCreatedRecords = currentAABP;
	}

	public List<SelectOption> getPlanYears() {
		List<String> years = new List<String>();
		years.add(String.valueOf(System.Today().year()));
		years.add(String.valueOf(System.Today().year() + 1));
		years.add(String.valueOf(System.Today().year() + 2));
		years.add(String.valueOf(System.Today().year() + 3));

		List<SelectOption> yearsSelectOptions = new List<SelectOption>();
		for (String y : years) {
			yearsSelectOptions.add(new SelectOption(y, y));
		}

		return yearsSelectOptions;
	}

	public List<User> getABLeads() {
		List<User> pickList = new List<User>();
		pickList = EDM_ABM_Utils.getUsersForRoles(new List<String> { EDM_ABM_Utils.ABLEAD, EDM_ABM_Utils.VDST_ABM } );
		return pickList;
	}

	public List<User> getVendorLeads() {
		List<User> pickList = new List<User>();
		pickList = EDM_ABM_Utils.getUsersForRoles(new List<String> { EDM_ABM_Utils.ABLEAD, EDM_ABM_Utils.VDST_ABM } );
		return pickList;
	}

	public List<User> getABSManagers() {
		List<User> pickList = new List<User>();
		pickList = EDM_ABM_Utils.getUsersForRole(EDM_ABM_Utils.ABS);
		return pickList;
	}

	public Integer getOtherSum()  {
		if (currentAABP.EDM_Other_gne__c > 0) {
			return Integer.valueOf(currentAABP.EDM_Other_gne__c);
		}
		else {
			return 0;
		}
	}

	public PageReference removeEvent() {

		if (Events[RowToDel - 1].Event.Id != null) {
			delete [SELECT Id FROM EDM_IABP_gne__c WHERE Id = :Events[RowToDel - 1].Event.Id];

			currentAABP.EDM_CAB_gne__c -= tempValues.get('CAB');
			currentAABP.EDM_RAB_gne__c -= tempValues.get('RAB');
			currentAABP.EDM_NAB_gne__c -= tempValues.get('NAB');
			currentAABP.EDM_Combo_gne__c -= tempValues.get('Combo');
			currentAABP.EDM_Other_gne__c -= tempValues.get('Other');
			update currentAABP;
		}

		if (isEdit) {
			updateTempValuesForDelete(RowToDel);
		}
		
		Events.remove(RowToDel - 1);

		Integer i = 1;
		for (EventWrapper evt : Events) {
			evt.RowNr = i;
			i++;
		}

		return null;
	}

	private void updateTempValuesForDelete(Integer rowNr) {
		if (Events[rowNr - 1].Event.Id == null) {
			if (Events[rowNr - 1].Event.EDM_Type_of_Event_gne__c == 'CAB') {
				tempValues.put('CAB', tempValues.get('CAB') - 1);
			}
			else if (Events[rowNr - 1].Event.EDM_Type_of_Event_gne__c == 'RAB') {
				tempValues.put('RAB', tempValues.get('RAB') - 1);
			}
			else if (Events[rowNr - 1].Event.EDM_Type_of_Event_gne__c == 'NAB') {
				tempValues.put('NAB', tempValues.get('NAB') - 1);
			}
			else if (Events[rowNr - 1].Event.EDM_Type_of_Event_gne__c == 'Combo') {
				tempValues.put('Combo', tempValues.get('Combo') - 1);
			}
			else if (Events[rowNr - 1].Event.EDM_Type_of_Event_gne__c == 'Other') {
				tempValues.put('Other', tempValues.get('Other') - 1);
			}
		}
	}

	public PageReference addEventEDM() {
		
		List<String> jointAABPsIds = new List<String>();
		for (SelectOption sso : selectedAABPs) {
			jointAABPsIds.add(sso.getValue());
		}
		Events.add(new EventWrapper(Events.size() + 1, newEvt, jointAABPsIds));
		Events.sort();
		Integer i = 1;
		for (EventWrapper evt : Events) {
			evt.RowNr = i;
			i++;
		}

		if (isEdit) {
			updateTempValuesForAdd(newEvt);
		}
		
		selectedAABPs = new List<SelectOption>();	
		newEvt = new EDM_IABP_gne__c();
		return null;
	}

	private void updateTempValuesForAdd(EDM_IABP_gne__c newEvt) {
		if (newEvt.EDM_Type_of_Event_gne__c == 'CAB') {
			tempValues.put('CAB', tempValues.get('CAB') + 1);
		}
		else if (newEvt.EDM_Type_of_Event_gne__c == 'RAB') {
			tempValues.put('RAB', tempValues.get('RAB') + 1);
		}
		else if (newEvt.EDM_Type_of_Event_gne__c == 'NAB') {
			tempValues.put('NAB', tempValues.get('NAB') + 1);
		}
		else if (newEvt.EDM_Type_of_Event_gne__c == 'Combo') {
			tempValues.put('Combo', tempValues.get('Combo') + 1);
		}
		else if (newEvt.EDM_Type_of_Event_gne__c == 'Other') {
			tempValues.put('Other', tempValues.get('Other') + 1);
		}
	}

	public PageReference editEventEDM() {
		List<String> jointAABPsIds = new List<String>();
		for (SelectOption sso : selectedAABPs) {
			jointAABPsIds.add(sso.getValue());
		}

		if (isEdit) {
			updateTempValuesForDelete(RowToEdit);
			updateTempValuesForAdd(newEvt);
		}

		EventWrapper editedEvent = Events[RowToEdit - 1];
		newEvt.EDM_Event_Name_gne__c = '';
		Events[RowToEdit - 1] = new EventWrapper(editedEvent.RowNr, newEvt, jointAABPsIds);
		Events.sort();
		Integer i = 1;
		for (EventWrapper evt : Events) {
			evt.RowNr = i;
			i++;
		}

		selectedAABPs = new List<SelectOption>();	
		newEvt = new EDM_IABP_gne__c();
		return null;
	}

	public List<SelectOption> getJointAABPs() {
		Set<Id> alreadySelectedAABPsIds = new Set<Id>();

		for (SelectOption selectedAABP : selectedAABPs) {
			alreadySelectedAABPsIds.add(selectedAABP.getValue());
		}

		List<SelectOption> aabpsSelectOptions = new List<SelectOption>();
		List<EDM_AABP_gne__c> listAABPs = [
						SELECT Id, EDM_Group_gne__c, EDM_Unit_gne__c, EDM_Team_gne__c, Name 
						FROM EDM_AABP_gne__c
							WHERE EDM_Plan_Year_gne__c = :currentAABP.EDM_Plan_Year_gne__c
							AND Id != :currentAABP.Id
							AND Id NOT IN :alreadySelectedAABPsIds];

		for (EDM_AABP_gne__c aabp : listAABPs) {
			aabpsSelectOptions.add(new SelectOption(aabp.Id, aabp.EDM_Group_gne__c + ' ' + aabp.EDM_Unit_gne__c + ' ' + aabp.EDM_Team_gne__c + ' ' + aabp.Name));
		}

		return aabpsSelectOptions;
	}

	public void populateJointAABPs() {
		selectedAABPs = new List<SelectOption>();
		jointAABPsToSelect = getJointAABPs();
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

	public PageReference saveAndGoBack() {
		saveAABP();
		if (ApexPages.hasMessages(ApexPages.Severity.ERROR)) {
			return null;
		}
		return goBack();
	}

	public PageReference saveAABP() {

		Savepoint sp = Database.setSavepoint();
		try {
			//save AABP
			if (PlanReceivedDate != '' ) currentAABP.EDM_Plan_Received_gne__c = Date.parse(PlanReceivedDate);
			if (PlanApprovedDate != '' ) currentAABP.EDM_Final_Approval_Received_gne__c = Date.parse(PlanApprovedDate);
			if (String.isNotBlank(selectedUnits)) currentAABP.EDM_Unit_gne__c = selectedUnits;
			if (String.isNotBlank(selectedTeams)) currentAABP.EDM_Team_gne__c = selectedTeams;
			currentAABP.EDM_Canceled_gne__c = CanceledEvts;
			currentAABP.EDM_Ad_Hoc_gne__c = AdHocEvts;

			upsert currentAABP;

			currentAABPToDisplayNameForJustCreatedRecords = [SELECT Name FROM EDM_AABP_gne__c WHERE Id = :currentAABP.Id];

			//save Events
			List<EDM_IABP_gne__c> toUpsert = new List<EDM_IABP_gne__c>();

			Map<String, String> BlueTextsInputs = EDM_IABP_Utils.getBlueTexts(null,'Both');
			String RecordTypeId = [SELECT Id, SobjectType, Name FROM RecordType WHERE Name = 'IABP' and SobjectType ='EDM_IABP_gne__c' LIMIT 1].Id;
			for (EventWrapper evt : Events) {
				evt.Event.RecordTypeId = RecordTypeId;
				evt.Event.EDM_Joint_AABP_gne__c = String.join(evt.JointAABPs, ',');
				evt.Event.EDM_Parent_AABP_gne__c = currentAABP.Id;
				evt.Event.EDM_Year_gne__c = currentAABP.EDM_Plan_Year_gne__c;
				evt.Event.EDM_IABP_Version_gne__c = 0;
				evt.Event.EDM_Primary_AB_Lead_gne__c = currentAABP.EDM_AB_Lead_gne__c;
				//CFS-3155 :: EDM ABM: Contracts logic update 2023 :: Don't clean evt.Event.EDM_Event_Focus_gne__c value for all IABPs
				//if (currentAABP.EDM_Group_gne__c != 'CMG')
					//evt.Event.EDM_Event_Focus_gne__c = '';

				EDM_IABP_Utils.populateDefaultDuties(evt.Event, BlueTextsInputs);
				toUpsert.add(evt.Event);
			}
			upsert toUpsert;

			//delete Events
			List<EDM_IABP_gne__c> toDel = new List<EDM_IABP_gne__c>();
			toDel.addAll([SELECT Id FROM EDM_IABP_gne__c WHERE Id IN :toDelIABPs]);
			delete toDel;

			populateEvents();
		} 
		catch (Exception ex) { 
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Could not save AAPB! ' + + ex.getMessage()));
			System.debug('Could not save AABP: ' + ex.getMessage());
			Database.rollback(sp);
		}
		return null;
	}

	public PageReference deleteAABP() {
		if (currentAABP.Id != null) {
			List<EDM_IABP_gne__c> relatedIABPs = [SELECT Id FROM EDM_IABP_gne__c WHERE EDM_Parent_AABP_gne__c = : currentAABP.Id];
			delete relatedIABPs;
			delete currentAABP;
		}
		return goBack();
	}

	public PageReference finalizeAABP() {
		currentAABP.EDM_Finalized_gne__c = true;
		saveAABP();
		List<User> shareWith = [SELECT Id, Name, IsActive FROM User WHERE Id IN (:currentAABP.EDM_AB_Lead_gne__c, :currentAABP.EDM_Vendor_Lead_gne__c)];
		shareWith.addAll(EDM_ABM_Utils.getUsersForRole(EDM_ABM_Utils.ABS));
		EDM_ABM_Utils.shareRecord(currentAABP.Id, shareWith, EDM_ABM_Utils.AL_EDIT, EDM_ABM_Utils.SHARE_DIRECT);
		return redirectFinalized();
	}

	public PageReference redirectFinalized() {
		if (currentAABP.EDM_Finalized_gne__c == true) {
			PageReference pageRef = new PageReference('/apex/EDM_AABP_Layout?id=' + currentAABP.Id);
			pageRef.setRedirect(true);
			return pageRef;
		} 
		else {
			return super.init();
		}
		
	}

	private void populateEvents() {
		Events.clear();
		IABPs = [SELECT Id, Name, EDM_Event_Name_gne__c, EDM_Type_of_Event_gne__c, EDM_Estimated_Quarter_gne__c, 
					EDM_Optional_Detail_gne__c, EDM_Joint_AABP_gne__c, EDM_Ad_Hoc_Event_gne__c,  EDM_Canceled_gne__c,
					EDM_Name_gne__c, EDM_Executive_Summary_gne__c, EDM_Parent_AABP_gne__c, EDM_Year_gne__c, EDM_Event_Focus_gne__c
				FROM EDM_IABP_gne__c
				WHERE EDM_Parent_AABP_gne__c = :currentAABP.Id
				AND EDM_Executive_Summary_gne__c = false
				ORDER BY EDM_Start_Date_gne__c, EDM_Estimated_Quarter_gne__c, Name];

		Integer rowNr = 1;
		for (EDM_IABP_gne__c iabp : IABPs) {
			if (iabp.EDM_Ad_Hoc_Event_gne__c == true) AdHocEvts++;
			if (iabp.EDM_Canceled_gne__c == true) CanceledEvts++;

			List<String> jointAABPsIds = new List<String>();
			if (iabp.EDM_Joint_AABP_gne__c != null) jointAABPsIds = iabp.EDM_Joint_AABP_gne__c.split(',');
			Events.add(new EventWrapper(rowNr, iabp, jointAABPsIds));
			rowNr++;
		}
	}

	public PageReference loadEventByRowNr() {
		EventWrapper selectedEvent = Events[RowToEdit - 1];
		newEvt = selectedEvent.Event;		
		selectedAABPs = selectedEvent.getSelectedJointAABPsSelectOptions();
		jointAABPsToSelect = getJointAABPs();
		return null;
	}

	
}