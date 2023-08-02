public without sharing class EDM_Curriculum_Submission_Ctrl {

	private New_Event_Curriculum_WS.New_Curriculum requestDetails;

	public String approvalDate { get; set; }
	public List<SelectOption> retrainingOptions {get;set;}
	public List<SelectOption> targetAudiences {get;set;}
	public List<SelectOption> selectedTargetAudiences {get; set;}
	public String bureauId { get; set; }
	public String prcCode { get; set; }
	public String replacing { get; set; }
	public String retraining { get; set; }
	public String selectedTargetAudience {get; set;}
	public String systemTitle { get; set; }
	public String title { get; set; }
	
	public String brandsJSON { get; set; }
	public Map<String, List<SelectOption>> brandsMap;
	public String jsonResult { get; set; }
	public Map<String, List<String>> selectedBrandsAndIndications;

	public Boolean errorsPresent { get; set;}

	public PicklistField materialPresentationField { get; set; }

	public EDM_Curriculum_Submission_Ctrl(){
		materialPresentationField = new PicklistField('Event_Curriculum_gne__c', 'Material_Presentation_Type__c');
		selectedTargetAudiences = new List<SelectOption>();
		clearData();
	}

	private List<SelectOption> setTargetAudiencesMultipicklist(){
		return em3_utils.getTargetAudiencePicklistValues();
	}

	private List<SelectOption> setRetrainingOptions(){
		List<SelectOption> retrainingList = new List<SelectOption>();
		retrainingList.add(new SelectOption('Select', 'Select'));
		retrainingList.add(new SelectOption('Yes', 'Yes'));
		retrainingList.add(new SelectOption('No', 'No'));
		return retrainingList;
	}

	public PageReference cancel() {
		clearData();
		PageReference pr = Page.EDM_Curriculum_Submission;
		pr.setRedirect(true);
		return pr;
	}

	public void validateBeforeSave() {
		Boolean invalidData = wrapData();
		if(!validateData() || invalidData){
			errorsPresent = true;
		} else {
			errorsPresent = false;
		}
	}

	public PageReference save() {
		if(errorsPresent){
			return null;
		}
		New_Event_Curriculum_WS.Messages result = processRequest();
		if(result.Status == 'SUCCESS'){
			errorsPresent = false;
			Event_Curriculum_gne__c newCurriculum = [SELECT Id FROM Event_Curriculum_gne__c WHERE aprimo_id_gne__c = :prcCode LIMIT 1];
			PageReference pr = Page.GNE_SFA2_EventCurclmBureau_Layout;
			pr.getParameters().put('id', newCurriculum.Id);
			pr.setRedirect(true);
			return pr;
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, result.Message));
			errorsPresent = true;
		}

		return null;
	}

	private Boolean validateData(){
		Boolean hasNoErrors = true;
		hasNoErrors = checkIfRequiredFieldsAreFilled();
		if(hasNoErrors){
			if(!em3_utils.bureau_Check(requestDetails)){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Bureau Id not found.'));
				hasNoErrors = false;
			}
			if(String.isNotBlank(replacing) && !em3_utils.checkIfPreviousPRCExists(replacing)){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Previous PRC Code not found.'));
				hasNoErrors = false;
			}
		}
		return hasNoErrors;
	}

	private Boolean checkIfRequiredFieldsAreFilled(){
		Boolean allAreFilled = true;
		if(String.isBlank(systemTitle)){
			if(allAreFilled){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Fill all mandatory fields before submitting request:'));
			}
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '"System Title" field is required'));
			allAreFilled = false;
		}
		if(String.isBlank(retraining) || retraining == 'Select'){
			if(allAreFilled){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Fill all mandatory fields before submitting request:'));
			}
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '"Retraining" field is required'));
			allAreFilled = false;
		}
		if(String.isBlank(prcCode)){
			if(allAreFilled){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Fill all mandatory fields before submitting request:'));
			}
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '"PRC Code" field is required'));
			allAreFilled = false;
		}
		if(String.isBlank(bureauId)){
			if(allAreFilled){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Fill all mandatory fields before submitting request:'));
			}
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '"Bureau ID" field is required'));
			allAreFilled = false;
		}
		if(String.isBlank(materialPresentationField.value) || materialPresentationField.value == 'Select') {
			if(allAreFilled){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Fill all mandatory fields before submitting request:'));
			}
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '"Material/Presentation Type" field is required'));
			allAreFilled = false;
		}
		if(String.isBlank(requestDetails.Target_Audience)){
			if(allAreFilled){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Fill all mandatory fields before submitting request:'));
			}
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '"Target Audience" field is required'));
			allAreFilled = false;
		}
		if(!isValidBrandsAndIndications()){
			if(allAreFilled){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Fill all mandatory fields before submitting request:'));
			}
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '"Brands and Indications" fields are required'));
			allAreFilled = false;
		}
		if(isNoneAmongIndications()) {
			if(allAreFilled){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Fill all mandatory fields before submitting request:'));
			}
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Chosen Indications must not include "None" value'));
			allAreFilled = false;
		}

		return allAreFilled;
	}

	private Boolean wrapData(){
		Boolean errorOccured = false;

		requestDetails.Target_Audience = convertPicklistToString(selectedTargetAudiences, ';');

		String brandList = '';

		this.selectedBrandsAndIndications = parseJsonMap(this.jsonResult);
		if(this.selectedBrandsAndIndications != null){
			for(String brand: this.selectedBrandsAndIndications.keySet()){
				if(brandList == ''){
					brandList = brand;
				} else {
					brandList += ';' + brand;
				}
			}
		} 
		
		if(String.isNotBlank(approvalDate)){
			try{
				Date dt = Date.parse(approvalDate);
				requestDetails.Approval_date = dt;
				requestDetails.start_date = dt;
			} catch(Exception ex){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid date in "Approval Date" field'));
				errorOccured = true;
			}
		}
		requestDetails.brandsWithIndications = jsonResult;
		requestDetails.brands = brandList;
		requestDetails.Speaker_bureau_IDs = bureauId;
		requestDetails.Previous_Version_Regulatory_Code = replacing;
		requestDetails.PRC_Code = prcCode;
		requestDetails.Speaker_Retraining_Required = retraining;
		requestDetails.name = systemTitle;
		return errorOccured;
	}

	private void clearData(){
		requestDetails = new New_Event_Curriculum_WS.New_Curriculum();
		requestDetails.Deactivation_Date = null;
		requestDetails.Disposition = 'SUBMITTED';
		requestDetails.SpeakerBureauCurriculum = 'Y';
		this.targetAudiences = setTargetAudiencesMultipicklist();
		this.selectedTargetAudiences.clear();
		this.selectedTargetAudience = '';
		this.retrainingOptions = setRetrainingOptions();
		this.approvalDate = null;
		this.bureauId = null;
		this.replacing = null;
		this.prcCode = null;
		this.retraining = 'Select';
		this.systemTitle = null;
		this.title = null;
		this.materialPresentationField.value = null;
		this.brandsJSON = JSON.serialize(buildBrandsMap());
		system.debug(this);
	}

	private String removeVerticalTabsAndFormFeeds(String text){
		if(text != null){
			List<Integer> verticalTabChar = new List<Integer> {11};
			List<Integer> formFeedChar = new List<Integer> {12};
			List<Integer> verticalTabChar2 = new List<Integer> {9794};
			List<Integer> formFeedChar2 = new List<Integer> {9792};
			String verticalTab = String.fromCharArray(verticalTabChar);
			String formFeed = String.fromCharArray(formFeedChar);
			String verticalTab2 = String.fromCharArray(verticalTabChar2);
			String formFeed2 = String.fromCharArray(formFeedChar2);

			text = text.replace(verticalTab, '');
			text = text.replace(formFeed, '');
			text = text.replace(verticalTab2, '');
			text = text.replace(formFeed2, '');
		}

		return text;
	}

	private Boolean isValidBrandsAndIndications() {
		if(this.selectedBrandsAndIndications == null) {
			return false;
		}
		for(String brand : this.selectedBrandsAndIndications.keySet()) {
			if(brand != 'undefined') {
				List<String> indications = this.selectedBrandsAndIndications.get(brand);
				if(indications.isEmpty()) {
					return false;
				} 
			} else {
				return false;
			}
		}
		return true;
	}

	private Boolean isNoneAmongIndications() {
		if(this.selectedBrandsAndIndications != null){
			for(String brand : this.selectedBrandsAndIndications.keySet()) {
				if(brand != 'undefined') {
					List<String> indications = this.selectedBrandsAndIndications.get(brand);
					if(indications.size() > 1) {
						for(String indication : indications) {
							if(indication == 'None') 
								return true; 
						}
					}
				}
			}
		}
		return false;
	}

	private Map<String, List<String>> parseJsonMap(String jsonString) {
		try{
			Map<String, List<String>> choosenBrandAndIndications = (Map<String, List<String>>) JSON.deserialize(jsonString,Map<String,List<String>>.class);
			return choosenBrandAndIndications;
			}
		catch(Exception ex){
			return null;
		}	
	}

	private Map<String, List<String>> buildBrandsMap(){
		Map<String, List<String>> result = new Map<String, List<String>>();
		
		List<EDM_SBM_Brand_To_Indications_gne__c> sortedBrands = [SELECT Name, Indications__c FROM EDM_SBM_Brand_To_Indications_gne__c ORDER BY Name DESC];
		Map<String, EDM_SBM_Brand_To_Indications_gne__c> customSettingBrandMapping = new Map<String, EDM_SBM_Brand_To_Indications_gne__c>();
		for(EDM_SBM_Brand_To_Indications_gne__c brand : sortedBrands){
			customSettingBrandMapping.put(brand.Name, brand);
		}

		Set<String> allIndications = new Set<String>();
		for(String brandName : customSettingBrandMapping.keySet()){
			String indicationsString = customSettingBrandMapping.get(brandName).Indications__c;
			List<String> indications;
			if(String.isNotBlank(indicationsString)){
				indications = indicationsString.split(';');
				sortCaseInsensitive(indications);
				allIndications.addAll(indications);				
				}
			
			result.put(brandName, indications);
		}
		setAllBrandIndicationsForNoProduct(result, allIndications);
		
		return result;
	}

	private void sortCaseInsensitive(List<String> listToSort) {
		Map<String, String> mapper = new Map<String, String>();

		for (Integer i = 0; i < listToSort.size(); i++) {
			mapper.put(listToSort[i].toUpperCase(), listToSort[i]);
			listToSort[i] = listToSort[i].toUpperCase();
		}

		listToSort.sort();

		for (Integer i = 0; i < listToSort.size(); i++) {
			listToSort[i] = mapper.get(listToSort[i]);
		}
	}

	private void setAllBrandIndicationsForNoProduct(Map<String, List<String>> brandMap, Set<String> allIndications) {
		if (allIndications.size() > 0) {
			List<String> allIndicationsListToSort = new List<String>();
			allIndicationsListToSort.addAll(allIndications);
			sortCaseInsensitive(allIndicationsListToSort);
			allIndicationsListToSort.add(0, 'None');
			brandMap.put('No Product Discussed', allIndicationsListToSort);
		}
	}

	private New_Event_Curriculum_WS.Messages processRequest(){
		/*Description of new logic:
		 *   Disposition    |   SpeakerBureauCurriculum    |    Speaker Bureau Id  |    Action on Curriculum
		 *      NEW  -> Y -> Yes -> insert/update + create training records if applicable /fill replacing/replaced by fields
		 *      NEW  -> N -> No action
		 *   UPDATE  -> Y -> Yes -> insert/update + create training records if applicable /fill replacing/replaced by fields
		 *   UPDATE  -> N -> Don't check -> set curriculum status to deleted + set training records if applicable status to deleted / remove replacing/replaced by fields / deleted curriculums should be hidden in UI
		 * WITHDRAW  -> Y -> Yes -> update
		 * WITHDRAW  -> N -> No action
		 *    other  -> Y -> Yes -> insert/update + don't create training records /fill replacing/replaced by fields
		 *    other  -> N -> No action
		*/

		Boolean isInsert = true;
		New_Event_Curriculum_WS.Messages msg = new New_Event_Curriculum_WS.Messages();
		if(requestDetails != null && requestDetails.name != null){
			requestDetails.name = em3_utils_2.getLocation(requestDetails.name);
		}
		Event_Curriculum_gne__c curriculum = new Event_Curriculum_gne__c();
		
		Savepoint sp = Database.setSavepoint();
		try{
			if(String.isNotBlank(replacing)) {
				curriculum.User_Defined_Predecessor_gne__c = true;
			}

			curriculum = em3_utils.ins_upd_Curriculum(requestDetails, curriculum);
			if(curriculum.Id != null){
				isInsert = false;
			}
		} catch(Exception e){
			msg.status='FAILURE';
			msg.message='MODULES ERROR:'+e.getMessage(); //if the parent event has problems return e2 instead of e3
			Database.rollback( sp );
			return msg;
		}

		//may not want to update this now - maybe after everything is successful
		try {
			try{
				User esbAdmin = [SELECT Id FROM User WHERE Name = 'ESB Admin' LIMIT 1];
				curriculum.OwnerId = esbAdmin.Id;
			} catch(Exception ex){
				system.debug('User not found');
			}
			curriculum.Material_Presentation_Type__c = materialPresentationField.value;
			if (!String.isBlank(title)) {
				title = removeVerticalTabsAndFormFeeds(title);
				curriculum.Description_gne__c = title;
			}

			if(String.isNotBlank(em3_utils.getPreviousPRCCode(requestDetails))) {
				curriculum.User_Defined_Predecessor_gne__c = true;
			}

			upsert curriculum;
			New_Event_Curriculum_WS.remediateCurriculumBrands(curriculum, requestDetails.brands, requestDetails.brandsWithIndications);

			if(String.isNotBlank(replacing) && curriculum.Approval_Date_gne__c != null && retraining == 'No') {
				List<Speaker_Training_gne__c> trainings = em3_utils.ins_trainings(curriculum, curriculum.Approval_Date_gne__c, replacing);
				if (trainings.size() > 0) {
					upsert trainings;
				}
				System.enqueueJob(new EDM_CurriculumSuccessorCrawler(curriculum.Id));
			}
		} catch(System.DmlException e){
			system.debug(e.getMessage());
			msg.status='FAILURE';
			msg.message='CURRICULUM ERROR:'+e.getMessage();
			Database.rollback( sp );
			return msg;
		}


		try{
			List<Curriculum_Speaker_Bureau_gne__c> curr_spk_bur = em3_utils.create_bur_relationships(requestDetails,curriculum);

			if(curr_spk_bur.size() > 0){
				try{
					insert(curr_spk_bur);
				} catch(System.DmlException e){
					msg.status='FAILURE';
					msg.message='CURR SPK BUR ERROR:'+e.getMessage();
					Database.rollback( sp );
					return msg;
				}
			}

		} catch(Exception e){
			msg.status='FAILURE';
			msg.message='CREATE BUREAU ERROR:'+e.getMessage();
			Database.rollback( sp );
			return msg;
		}

		
		if(replacing != ''){
			try{
				update em3_utils.upd_replacing_curr(replacing, curriculum.Aprimo_ID_gne__c);
			} catch(Exception ex){
				msg.status='FAILURE';
				msg.message='UPDATE REPLACING/REPLACED BY ERROR:'+ex.getMessage();
				Database.rollback( sp );
				return msg;
			}
		}

		if (isInsert && (String.isBlank(curriculum.Description_gne__c) || '<Title Needed>'.equals(curriculum.Description_gne__c))) {
			em3_utils.sendCurriculumCreateEmail(curriculum.Id, requestDetails.Speaker_bureau_IDs);
		}
			
		msg.Status = 'SUCCESS';
		msg.Message = '';
		return msg;
	}

	private String convertPicklistToString(List<SelectOption> picklistToConvert, String separator) {
		String picklistAsString = '';
		for(SelectOption so : picklistToConvert) {
			picklistAsString += so.getValue() + separator;
		}

		picklistAsString = picklistAsString.removeEnd(';');
		return picklistAsString;
	}

	@TestVisible private class PicklistField {
		public String label { get; set; }
		public List<SelectOption> picklistValues { get; set; }
		public String value { get; set; }

		public PicklistField(String objectName, String fieldName) {
			Map<String, Schema.DescribeFieldResult> allFieldsDescribe = GNE_SFA2_Util.getFieldDescribeMap(objectName);
			Schema.DescribeFieldResult fieldDescribe = allFieldsDescribe.get(fieldName.toLowerCase());
			label = fieldDescribe.getLabel();
			picklistValues = new List<SelectOption>();
			for (Schema.PicklistEntry picklistEntry : fieldDescribe.getPicklistValues()) {
				picklistValues.add(new SelectOption(picklistEntry.getLabel(), picklistEntry.getLabel()));
			}
		}
	}

}