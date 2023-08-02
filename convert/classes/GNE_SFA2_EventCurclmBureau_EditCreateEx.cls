public with sharing class GNE_SFA2_EventCurclmBureau_EditCreateEx extends GNE_SFA2_Dynamic_VF_Edit_Create {
	
	public String brandToIndicationsJSON { get; private set; }
	public String curriculumBrandsJSON { get; set; }

	private Set<String> existingChildBrandIds;

	public GNE_SFA2_EventCurclmBureau_EditCreateEx(ApexPages.StandardController controller) {
		super(controller,'/apex/GNE_SFA2_EventCurclmBureau_Layout');
		existingChildBrandIds = new Set<String>();
		brandToIndicationsJSON = getBrandToIndicationJSON();
		curriculumBrandsJSON = getBrandsForCurriculumJSON(controller.getId());
		additionalQueryFields.addAll(new Set<String> {
				'Previous_Version_Regulatory_Code_gne__c', 'Speaker_Retraining_Required_gne__c', 'Approval_Date_gne__c'
				});
	}

	private String getBrandToIndicationJSON() {
		return JSON.serialize(loadBrandsToIndicationsMap());
	}


	@TestVisible
	private Map<String, List<String>> loadBrandsToIndicationsMap() {
		Map<String, List<String>> result = new Map<String, List<String>>();
		
		Map<String, EDM_SBM_Brand_To_Indications_gne__c> customSettingBrandMapping = new Map<String, EDM_SBM_Brand_To_Indications_gne__c>();
		List<EDM_SBM_Brand_To_Indications_gne__c> brandsList = [SELECT Name, Indications__c FROM EDM_SBM_Brand_To_Indications_gne__c ORDER BY Name DESC];
		for(EDM_SBM_Brand_To_Indications_gne__c brand : brandsList){
			customSettingBrandMapping.put(brand.Name, brand);
		}
		Set<String> allIndications = new Set<String>();

		for (String brandName : customSettingBrandMapping.keySet()) {
			String indicationsString = customSettingBrandMapping.get(brandName).Indications__c;
			List<String> indications;
			if (String.isNotBlank(indicationsString)) {
				indications = indicationsString.split(';');
				sortCaseInsensitive(indications);
				allIndications.addAll(indications);				
			}
			
			result.put(brandName, indications);
		}

		setAllBrandIndicationsForNoProduct(result, allIndications);
		
		return result;
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

	private String getBrandsForCurriculumJSON(Id parentCurriculumId) {
		List<BrandWithIndications> brands = loadBrandsForCurriculum(parentCurriculumId);
		return JSON.serialize(brands);
	}

	private List<BrandWithIndications> loadBrandsForCurriculum(Id parentCurriculumId) {
		List<BrandWithIndications> result = new List<BrandWithIndications>();
		List<EDM_Event_Curriculum_Brand__c> brands = [SELECT Id, EDM_Brand__c, EDM_Brand_Indications__c 
														FROM EDM_Event_Curriculum_Brand__c 
														WHERE EDM_Parent_Curriculum__c = :parentCurriculumId
														ORDER BY EDM_Brand__c];
		for (EDM_Event_Curriculum_Brand__c brand : brands) {
			BrandWithIndications brandAndIndication = new BrandWithIndications();
			brandAndIndication.id = brand.Id;
			existingChildBrandIds.add(brand.Id);
			brandAndIndication.brandName = brand.EDM_Brand__c;
			if (String.isNotBlank(brand.EDM_Brand_Indications__c)) {
				brandAndIndication.indications = brand.EDM_Brand_Indications__c.split(';');
			}			
			result.add(brandAndIndication);		
		}
		return result;										
	}

	private void removeVerticalTabsAndFormFeedsFromDescription(){
		Event_Curriculum_gne__c ec = (Event_Curriculum_gne__c)myObject;
		if(ec.Description_gne__c != null){
			String title = ec.Description_gne__c;

			List<Integer> verticalTabChar = new List<Integer> {11};
			List<Integer> formFeedChar = new List<Integer> {12};
			List<Integer> verticalTabChar2 = new List<Integer> {9794};
			List<Integer> formFeedChar2 = new List<Integer> {9792};
			String verticalTab = String.fromCharArray(verticalTabChar);
			String formFeed = String.fromCharArray(formFeedChar);
			String verticalTab2 = String.fromCharArray(verticalTabChar2);
			String formFeed2 = String.fromCharArray(formFeedChar2);

			title = title.replace(verticalTab, '');
			title = title.replace(formFeed, '');
			title = title.replace(verticalTab2, '');
			title = title.replace(formFeed2, '');
			ec.Description_gne__c = title;
		}
	}

	private void setUserDefinedPredecessorFlag(){
		Event_Curriculum_gne__c ec = (Event_Curriculum_gne__c)myObject;
		if(String.isNotBlank(ec.Replacing_Curr_gne__c)) {
			ec.User_Defined_Predecessor_gne__c = true;
		}
	}

	public override PageReference save() {

		removeVerticalTabsAndFormFeedsFromDescription();
		setUserDefinedPredecessorFlag();

		Event_Curriculum_gne__c ec = (Event_Curriculum_gne__c)myObject;

		if(String.isNotBlank(ec.Replacing_Curr_gne__c) && ec.Approval_Date_gne__c != null && ec.Speaker_Retraining_Required_gne__c == 'No') {
			String aprimoId = [SELECT Aprimo_ID_gne__c FROM Event_Curriculum_gne__c WHERE Id =: ec.Replacing_Curr_gne__c LIMIT 1].Aprimo_ID_gne__c;
			ec.Previous_Version_Regulatory_Code_gne__c = aprimoId;		
			
			List<Speaker_Training_gne__c> trainings = em3_utils.ins_trainings(ec, ec.Approval_Date_gne__c, aprimoId);
			if (trainings.size() > 0) {
				upsert trainings;							
			}
			System.enqueueJob(new EDM_CurriculumSuccessorCrawler(ec.Id));
		}

		PageReference pr = super.save();

		if (!ApexPages.hasMessages(ApexPages.Severity.ERROR)) {
			remediateBrands();
		}

		return pr;
	}

	private void remediateBrands() {
		List<EDM_Event_Curriculum_Brand__c> brandsToUpdate = unwrapCurriculumBrands(curriculumBrandsJSON);
		Set<String> brandsIdsToLeave = getSetFromList(brandsToUpdate, 'Id');
		existingChildBrandIds.removeAll(brandsIdsToLeave);
		List<Id> idsToDelete = new List<Id>();
		for (String idToDel : existingChildBrandIds) {
			idsToDelete.add(idToDel);
		}
		Database.delete(idsToDelete);
		update brandsToUpdate;
	}

	private List<EDM_Event_Curriculum_Brand__c> unwrapCurriculumBrands(String inputJSON) {
		List<BrandWithIndications> curriculumBrands = (List<BrandWithIndications>)JSON.deserialize(inputJSON, List<BrandWithIndications>.class);

		List<EDM_Event_Curriculum_Brand__c> unwrappedBrands = new List<EDM_Event_Curriculum_Brand__c>();
		if (curriculumBrands != null && !curriculumBrands.isEmpty()) {
			for (BrandWithIndications brandWInd : curriculumBrands) {
				String indications;
				if (brandWInd.indications != null && !brandWInd.indications.isEmpty()) {
					indications = String.join(brandWInd.indications, ';');
				}

				EDM_Event_Curriculum_Brand__c ecb = new EDM_Event_Curriculum_Brand__c(
											Id = brandWInd.Id, 
											EDM_Brand_Indications__c = indications,
											EDM_Parent_Curriculum__c = myObject.Id
										);
				unwrappedBrands.add(ecb);
			} 
		}
		return unwrappedBrands;
	}

	private Set<String> getSetFromList(List<SObject> listToGoThrough, String fieldName) {
		Set<String> result = new Set<String>();
		for (SObject item : listToGoThrough) {
			result.add((String)item.get(fieldName));
		}
		return result;
	}

	private class BrandWithIndications {
		public String Id;
		public String brandName;
		public List<String> indications;
	}
}