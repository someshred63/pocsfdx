public with sharing class GNE_SFA2_SpeakerBureau_Ctrl extends GNE_SFA2_Base_Ctrl {
	public GNE_SFA2_SpeakerBureau_Ctrl(ApexPages.StandardController sctrl) {
		this();
	}

	public GNE_SFA2_SpeakerBureau_Ctrl() {		
		super();		
	}

	protected override Boolean pageDispatcher() {
		return true;
	}

	protected override virtual GNE_SFA2_Base_Ctrl.DataWrapper getDataWrapperInstance() {
		return new DataWrapper();
	}
	
	protected override GNE_SFA2_Base_Ctrl.DataWrapper getDataWrapper(GNE_SFA2_Base_Ctrl.DataWrapper dataWrapper) {
		sObjectType = 'Speaker_Bureau_gne__c';
		DataWrapper result = (DataWrapper)dataWrapper;
		result = (DataWrapper)super.getDataWrapper(result);
		return result;
	}

	protected override GNE_SFA2_Base_Ctrl.DataWrapper intInit(Map<String,String> params) {
		activeMenuItem = 'More';
		pageExtId = 'speakerBureau';
		GNE_SFA2_Base_Ctrl.DataWrapper result = super.intInit(params);
		return result;
	}
  
	protected override GNE_SFA2_Base_Ctrl.DataWrapper initNewMode() {
		this.params.put('sObjectType', 'Speaker_Bureau_gne__c');
		return super.initNewMode();
	}

	protected override GNE_SFA2_Base_Ctrl.DataWrapper intPerformRemoteAction(String actionName) {
		GNE_SFA2_Base_Ctrl.DataWrapper result = null;

		if (actionName=='getAvailableCurricula') {
			result = intGetAvailableCurricula();
		} 
		else if (actionName=='saveSelectedCurricula') {
			result = intSaveSelectedCurriculaAndReturnWithFormulaValues();
		}
		else if (actionName=='getAvailableAttachments') {
			result = intGetAvailableAttachments();
		} 
		else {
			result = super.intPerformRemoteAction(actionName);
		}

		return result;
	}

	private GNE_SFA2_Base_Ctrl.DataWrapper intGetAvailableCurricula() {
		DataWrapper inputData = (DataWrapper)this.inputDataWrapper;
		DataWrapper resultData = (DataWrapper)this.dataWrapper;

		String recordId = inputData.recordDescribe.recordId;
		Boolean showInactiveCurricula = inputData.showInactiveCurricula;

		List<String> statuses = new List<String>();
		if (showInactiveCurricula) {
			statuses.add('Active');
			statuses.add('Inactive');
		}
		else {
			statuses.add('Active');
		}

		List<Curriculum_Speaker_Bureau_gne__c> alreadyAddedCurriculaJunctions = [SELECT Event_Curriculum_gne__c FROM Curriculum_Speaker_Bureau_gne__c WHERE Speaker_Bureau_gne__c = :recordId];
		Set<Id> alreadyAddedCurriculaIds = getIdSetFromList('Event_Curriculum_gne__c', alreadyAddedCurriculaJunctions);

		List<Event_Curriculum_gne__c> availableCurricula = [SELECT Id, EDM_Title_Multiselect_gne__c, Start_Date_gne__c, Curriculum_Status_gne__c, Aprimo_Id_gne__c 
																FROM Event_Curriculum_gne__c
																WHERE Id NOT IN :alreadyAddedCurriculaIds
																	AND Curriculum_Status_gne__c != 'Deleted'
																	AND Curriculum_External_Id_gne__c != null
																	AND Curriculum_Status_gne__c IN :statuses];

		List<AvailableCurriculum> availableCurriculaData = new List<AvailableCurriculum>();

		for (Event_Curriculum_gne__c curriculum : availableCurricula) {
			String approvalDate = String.valueOf(curriculum.Start_Date_gne__c != null ? curriculum.Start_Date_gne__c.format() : '');
			AvailableCurriculum ac = new AvailableCurriculum(curriculum.Id, curriculum.EDM_Title_Multiselect_gne__c, approvalDate, curriculum.Curriculum_Status_gne__c, curriculum.Aprimo_Id_gne__c);
			availableCurriculaData.add(ac);
		}

		resultData.availableCurriculaData = availableCurriculaData;
		resultData.showInactiveCurricula = showInactiveCurricula;
		return resultData;
	}

	private GNE_SFA2_Base_Ctrl.DataWrapper intSaveSelectedCurriculaAndReturnWithFormulaValues() {
		DataWrapper inputData = (DataWrapper)this.inputDataWrapper;
		DataWrapper resultData = (DataWrapper)this.dataWrapper;

		List<Curriculum_Speaker_Bureau_gne__c> newCurriculaJunctions = saveNewCurriculaJunctions(inputData);

		resultData.newCurriculumBureauJuncionsRows = retrieveInsertedDataWithFormulaValues(inputData.curriculaFieldsToQuery, newCurriculaJunctions);

		return resultData;
	}

	private List<Curriculum_Speaker_Bureau_gne__c> saveNewCurriculaJunctions(DataWrapper inputData) {
		List<Curriculum_Speaker_Bureau_gne__c> newCurriculaJunctions = new List<Curriculum_Speaker_Bureau_gne__c>();

		for (String selectedCurriculumId : inputData.curriculaIdsToAdd) {
			Curriculum_Speaker_Bureau_gne__c csb = new Curriculum_Speaker_Bureau_gne__c(
																Event_Curriculum_gne__c = selectedCurriculumId, 
																Speaker_Bureau_gne__c = inputData.recordDescribe.recordId
															);
			newCurriculaJunctions.add(csb);
		}

		insert newCurriculaJunctions;
		return newCurriculaJunctions;
	}

	private GNE_SFA2_Base_Ctrl.DataWrapper intGetAvailableAttachments() {
		DataWrapper inputData = (DataWrapper)this.inputDataWrapper;
		DataWrapper resultData = (DataWrapper)this.dataWrapper;

		String recordId = inputData.recordDescribe.recordId;

		List<RelatedListRecordWrapper> result = new List<RelatedListRecordWrapper>();

		String queryFields = String.join(inputData.attachmentsFieldsToQuery, ',');
		String query = 'SELECT Owner.Name,' + queryFields + '  FROM Attachment WHERE ParentId =: recordId';

		List<Attachment> attachments = (List<Attachment>)Database.query(query);

		Schema.DescribeSObjectResult attachmentsDescribe = GNE_SFA2_Util.getGlobalDescribe().get('Attachment').getDescribe();
		List<RelatedListField> relatedListFields = new RelatedList().getRelatedListFields(attachmentsDescribe, inputData.attachmentsFieldsToQuery, new List<String>());

		for (Attachment att : attachments) {
			//RelatedListRecordWrapper newRow = new RelatedListRecordWrapper(att, relatedListFields);
			GNE_SFA2_Base_Ctrl.RelatedListRecordWrapper row = new GNE_SFA2_Base_Ctrl.RelatedListRecordWrapper(
                att.Id,
                new Map<String,String>{
                    'createdbyid' => att.CreatedById,
                    'createddate' => String.valueOfGmt(att.LastModifiedDate),
                    'description' => null,
                    'lastmodifieddate' => String.valueOfGmt(att.LastModifiedDate),
                    'name' => String.valueOf(att.name)
                    },
                new Map<String,String>{
                    'createdbyid' => String.valueOf(att.Owner.Name),
                    'createddate' => att.LastModifiedDate.format(),
                    'name' => String.valueOf(att.name)
                }
                );
			result.add(row);
		}

		resultData.attachmentRows = result;
		
		return resultData;
	}

	private List<RelatedListRecordWrapper> retrieveInsertedDataWithFormulaValues(List<String> fieldsToQuery, List<Curriculum_Speaker_Bureau_gne__c> newCurriculaJunctions) {
		List<RelatedListRecordWrapper> result = new List<RelatedListRecordWrapper>();

		String queryFields = String.join(fieldsToQuery, ',');
		String query = 'SELECT ' + queryFields + ' FROM Curriculum_Speaker_Bureau_gne__c WHERE Id IN :newCurriculaJunctions';

		List<Curriculum_Speaker_Bureau_gne__c> newCSBs = (List<Curriculum_Speaker_Bureau_gne__c>)Database.query(query);

		Schema.DescribeSObjectResult junctionCurriculumSpeakerDescribe = GNE_SFA2_Util.getGlobalDescribe().get('Curriculum_Speaker_Bureau_gne__c').getDescribe();
		List<RelatedListField> relatedListFields = new RelatedList().getRelatedListFields(junctionCurriculumSpeakerDescribe, fieldsToQuery, new List<String>());

		for (Curriculum_Speaker_Bureau_gne__c csb : newCSBs) {
			RelatedListRecordWrapper newRow = new RelatedListRecordWrapper(csb, relatedListFields);
			result.add(newRow);
		}

		return result;
	}

	private Set<Id> getIdSetFromList(String idFieldName, List<SObject> objList) {
		Set<Id> result = new Set<Id>();
		for (SObject item : objList) {
			result.add((Id)item.get(idFieldName));
		}
		return result;
	}

	private class AvailableCurriculum {
		private String id;
		private String title;
		private String approvedDate;
		private String status;
		private String aprimoCode;

		private AvailableCurriculum(String id, String title, String approvedDate, String status, String aprimoCode) {
			this.id = id;
			this.title = title;
			this.approvedDate = approvedDate;
			this.status = status;
			this.aprimoCode = aprimoCode;
		}
	}

	public class DataWrapper extends GNE_SFA2_Base_Ctrl.DataWrapper {
		public List<AvailableCurriculum> availableCurriculaData;
		public Boolean showInactiveCurricula;
		public List<String> curriculaIdsToAdd;
		public List<String> curriculaFieldsToQuery;
		public List<String> attachmentsFieldsToQuery;
		public List<RelatedListRecordWrapper> newCurriculumBureauJuncionsRows;
		public List<RelatedListRecordWrapper> attachmentRows;
	}

	@RemoteAction
	public static DataWrapper saveRecord(String inputDataInJSON) {
		return (DataWrapper)(new GNE_SFA2_SpeakerBureau_Ctrl()).saveRecord(inputDataInJSON, GNE_SFA2_SpeakerBureau_Ctrl.DataWrapper.class);
	}

	@RemoteAction
	public static DataWrapper getAvailableCurricula(String inputDataInJSON) {
		return (DataWrapper)(new GNE_SFA2_SpeakerBureau_Ctrl()).performRemoteAction('getAvailableCurricula', inputDataInJSON, GNE_SFA2_SpeakerBureau_Ctrl.DataWrapper.class);
	}

	@RemoteAction
	public static DataWrapper saveSelectedCurricula(String inputDataInJSON) {
		return (DataWrapper)(new GNE_SFA2_SpeakerBureau_Ctrl()).performRemoteAction('saveSelectedCurricula', inputDataInJSON, GNE_SFA2_SpeakerBureau_Ctrl.DataWrapper.class);
	}

	@RemoteAction
	public static DataWrapper getAvailableAttachments(String inputDataInJSON) {
		return (DataWrapper)(new GNE_SFA2_SpeakerBureau_Ctrl()).performRemoteAction('getAvailableAttachments', inputDataInJSON, GNE_SFA2_SpeakerBureau_Ctrl.DataWrapper.class);
	}
}