public class GNE_AP_Territory_Planning extends GNE_AP_Base_Class{

	private static final Integer MAX_VALUES_PER_CATEGORY = 50;

	public final Map<String,List<Row>> terrPlansMap{get; set;}
	public String tpCategory{get; set;}
	public Integer saveRowId{get; set;}
	public String selectedResource{get;set;}
	public AP_Territory_Planning_gne__c territoryPlan{get; set;}
	public List<ApAttachment> attachments{get; set;}
	public Map<String, String>categoryLabels {get; private set;} 
	public AP_Account_Planning_gne__c accountPlanning {get; set;}
	
	private Integer counter;
	private String commaSepratedTerritories;

	public GNE_AP_Territory_Planning(ApexPages.StandardController controller){
		super();
		territoryPlan = new AP_Territory_Planning_gne__c();
		terrPlansMap = new Map<String, List<Row>>();
		commaSepratedTerritories = '';

		if(GNE_AP_Util.isFE()){
			for(Territory2 terr: GNE_FCR_DAO.getTerritories(Userinfo.getUserId())){
				commaSepratedTerritories += terr.Name + ',' ;
			}
			commaSepratedTerritories = commaSepratedTerritories.subString(0, commaSepratedTerritories.length());
		}

		if(String.isEmpty(accountPlanId)){
			accountPlanning = GNE_AP_DAO.getActiveAccountPlan(Userinfo.getUserId());
			if(accountPlanning != null){
				accountPlanId = accountPlanning.Id;
			}
		}else{
	        accountPlanning = GNE_AP_DAO.getAccountPlan(accountPlanId);
		}
		
		List<AP_Territory_Planning_gne__c> terrPlanList = null;
		if(accountPlanId != null){
			terrPlanList = [SELECT Id, Name, CS_User_gne__c, DM_User_gne__c, AP_Account_Planning_gne__c, Message_gne__c, Territory_Name_gne__c, TP_Category_gne__c, Title_gne__c FROM AP_Territory_Planning_gne__c WHERE AP_Account_Planning_gne__c=:accountPlanId];
		}else if(GNE_AP_Util.isFM()){
			terrPlanList = [SELECT Id, Name, CS_User_gne__c, DM_User_gne__c, AP_Account_Planning_gne__c, Message_gne__c, Territory_Name_gne__c, TP_Category_gne__c, Title_gne__c FROM AP_Territory_Planning_gne__c WHERE AP_Account_Planning_gne__r.DM_User_gne__c = :UserInfo.getUserId() AND AP_Account_Planning_gne__r.Status_gne__c In (:GNE_AP_Util.AP_SUBMITTED, :GNE_AP_Util.AP_APPROVED)];
		}
		counter = 0;
		for(AP_Territory_Planning_gne__c terrPlan : terrPlanList){
			String categoryName = terrPlan.TP_Category_gne__c;
			if(!terrPlansMap.containsKey(categoryName)){
				terrPlansMap.put(categoryName, new List<Row>());
			}
			terrPlansMap.get(categoryName).add(new Row(counter++, terrPlan));
		}
		createDefaultRows();
		setAttachments();
		categoryLabels = initializeCategoryLabels();
	}
	
	public static Map<String, String> initializeCategoryLabels(){
		Map<String, String>categoryLabels = new Map<String, String>();
		categoryLabels.put('Current State', 'Current State');
		categoryLabels.put('Opportunity', 'Opportunity');
		categoryLabels.put('Obstacles', 'Obstacles');
		categoryLabels.put('Resource Request', 'Resource Being Planned for Usage');
		categoryLabels.put('Attachments', 'Attachments');
		
		List<Territory2> territories = GNE_AP_Util.getUserTerritories(UserInfo.getUserId());
		if(territories.size()>0){
			Map<String, String> customLabels = GNE_AP_Util.getCustomLabel(new List<String>(categoryLabels.keySet()), territories.get(0).Salesforce_Code_gne__c, territories.get(0).Salesforce_SubTeam_Code_gne__c);
			for(String key: categoryLabels.keySet()){
				if(customLabels.containsKey(key)){
					categoryLabels.put(key, customLabels.get(key));
				}
			}
		}
		return categoryLabels;
	}

	// Function to return different categories available in the Territory Planning object
	public List<String> getCategories(){
		List<String> categories = null;
		if(terrPlansMap != null){
			categories = new List<String>(terrPlansMap.keySet());
			categories.sort();
		}
		return categories;
	}

	// Function should ensure that the categories Current State, Opportunity, Obstacles has N rows
	public void createDefaultRows(){
		Integer rowsNumber = 6;
		Integer resourceRequestRowsNumber = 4;
		
		if(!terrPlansMap.containsKey('Current State')){
			terrPlansMap.put('Current State', new List<Row>());
		}
		if(!terrPlansMap.containsKey('Opportunity')){
			terrPlansMap.put('Opportunity', new List<Row>());
		}
		if(!terrPlansMap.containsKey('Obstacles')){
			terrPlansMap.put('Obstacles', new List<Row>());
		}
		if(!terrPlansMap.containsKey('Resource Request')){
			terrPlansMap.put('Resource Request', new List<Row>());
		}

		Integer size = terrPlansMap.get('Current State').size();
		for(Integer i = 0 ; i < rowsNumber - size ; i++){
			AP_Territory_Planning_gne__c newTerritory = new AP_Territory_Planning_gne__c();
			newTerritory.TP_Category_gne__c = 'Current State';
			newTerritory.AP_Account_Planning_gne__c = accountPlanId;
			newTerritory.Territory_Name_gne__c = commaSepratedTerritories;
			terrPlansMap.get('Current State').add(new Row(counter++, newTerritory));
		}
		size = terrPlansMap.get('Opportunity').size();
		for(Integer i = 0 ; i < rowsNumber - size ; i++){
			AP_Territory_Planning_gne__c newTerritory = new AP_Territory_Planning_gne__c();
			newTerritory.TP_Category_gne__c = 'Opportunity';
			newTerritory.AP_Account_Planning_gne__c = accountPlanId;
			newTerritory.Territory_Name_gne__c = commaSepratedTerritories;
			terrPlansMap.get('Opportunity').add(new Row(counter++, newTerritory));
		}
		size = terrPlansMap.get('Obstacles').size();
		for(Integer i = 0 ; i<rowsNumber - size ; i++){
			AP_Territory_Planning_gne__c newTerritory = new AP_Territory_Planning_gne__c();
			newTerritory.TP_Category_gne__c = 'Obstacles';
			newTerritory.AP_Account_Planning_gne__c = accountPlanId;
			newTerritory.Territory_Name_gne__c = commaSepratedTerritories;
			terrPlansMap.get('Obstacles').add(new Row(counter++, newTerritory));
		}
		size = terrPlansMap.get('Resource Request').size();
		for(Integer i = 0 ; i < resourceRequestRowsNumber-size ; i++){
			AP_Territory_Planning_gne__c newTerritory = new AP_Territory_Planning_gne__c();
			newTerritory.TP_Category_gne__c = 'Resource Request';
			newTerritory.AP_Account_Planning_gne__c = accountPlanId;
			newTerritory.Territory_Name_gne__c = commaSepratedTerritories;
			terrPlansMap.get('Resource Request').add(new Row(counter++, newTerritory));
		}
	}

	public Franchise_Goal_gne__c getFranchiseGoal(){
		List<SFA2_User_Sales_Roster_gne__c> franchise = GNE_AP_Util.getFranchiseId(Userinfo.getUserId());
		if(!franchise.isEmpty()){
			List<Franchise_Goal_gne__c>result = GNE_AP_Util.getFranchiseGoal(franchise.get(0).Sales_Roster_gne__r.Franchise__r.Id);
			if(!result.isEmpty()){
				return result.get(0);
			}
		} else {
			Id franchiseId = GNE_AP_Util.getFranchiseIdFromTerritoryMapping(Userinfo.getUserId());
			if(franchiseId != null){
				List<Franchise_Goal_gne__c>result = GNE_AP_Util.getFranchiseGoal(franchiseId);
				if(!result.isEmpty()){
					return result.get(0);
				}
			}
		}
		return null;
	}

	public List<SelectOption> getAllResources(){
		List<SFA2_User_Sales_Roster_gne__c> franchise = GNE_AP_Util.getFranchiseId(Userinfo.getUserId());
		List<SelectOption> options = new List<SelectOption>();
		if(!franchise.isEmpty()){
			for(AP_ResourceRequest_gne__c apResource: GNE_AP_Util.getResourceRequest(franchise.get(0).Sales_Roster_gne__r.Franchise__r.Id)){
				options.add(new SelectOption(apResource.Name, apResource.Name));
			}
		} else {
			Id franchiseId = GNE_AP_Util.getFranchiseIdFromTerritoryMapping(Userinfo.getUserId());
			if(franchiseId != null){
				for(AP_ResourceRequest_gne__c apResource: GNE_AP_Util.getResourceRequest(franchiseId)){
					options.add(new SelectOption(apResource.Name, apResource.Name));
				}
			}
		}
		return options;
	}

	public Boolean getHasResources(){
		return !getAllResources().isEmpty();
	}

	public PageReference saveRow(){
		Boolean savedRecord = false;
		try{            
			for(List<Row> rowList: terrPlansMap.values()){
				Integer deletedRowId = -1;
				for(Row row : rowList){
					deletedRowId++;
					
					if(row.rowId == saveRowId){
						if(selectedResource == 'Select a Resource'){
							selectedResource = null;
							rowList.remove(deletedRowId);
							Database.delete(row.record);
							savedRecord = true;
							terrPlansMap.get('Resource Request').add(new Row(counter++, new AP_Territory_Planning_gne__c(TP_Category_gne__c = tpCategory, AP_Account_Planning_gne__c = accountPlanId, Territory_Name_gne__c = commaSepratedTerritories)));
							break;
						}

						if(selectedResource != null){
							row.record.Title_gne__c = selectedResource;
							selectedResource = null;
						}
						row.record.Territory_Name_gne__c = commaSepratedTerritories;
						Database.upsert(row.record);
						savedRecord = true;
						break;
					}
				}
				if(savedRecord){
					break;
				}
			}
		}catch (Exception ex){
			return GNE_AP_Util.redirectToErrorPage(Label.GNE_AP_Territory_Element_Error, Apexpages.currentPage().getUrl(), ex.getMessage());
		}
		return null;
	}

	public PageReference addRow(){
        if(terrPlansMap.get(tpCategory).size() < MAX_VALUES_PER_CATEGORY){
			terrPlansMap.get(tpCategory).add(new Row(counter++, new AP_Territory_Planning_gne__c(TP_Category_gne__c=tpCategory, AP_Account_Planning_gne__c = accountPlanId, Territory_Name_gne__c = commaSepratedTerritories)));
			terrPlansMap.get(tpCategory).add(new Row(counter++, new AP_Territory_Planning_gne__c(TP_Category_gne__c=tpCategory, AP_Account_Planning_gne__c = accountPlanId, Territory_Name_gne__c = commaSepratedTerritories)));
		}else{
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.GNE_AP_Plan_Max_Elements);
			ApexPages.addMessage(myMsg);
		}
		return null;
	}

	public class Row{
		public Integer rowId {get; set;}
		public AP_Territory_Planning_gne__c record{get; set;}
		
		public Row(Integer rowId, AP_Territory_Planning_gne__c record){
			this.rowId = rowId;
			this.record = record;
		}
	}

	public void setAttachments() {		
		this.attachments = new List<ApAttachment>();
		if(accountPlanId != null){
			for (AP_Attachment_gne__c apAttachment : [
				SELECT Id, (SELECT Id, Name, CreatedDate FROM Attachments)
				FROM AP_Attachment_gne__c
				WHERE ID IN (SELECT AP_Attachment_gne__c FROM AP_Attachment_Detail_gne__c WHERE AP_Account_Planning_gne__c = :accountPlanId)
				ORDER BY Name ASC]){
				attachments.add(new ApAttachment(apAttachment));
			}
		}
	}
	
	public PageReference refreshAttachments(){
		setAttachments();
		return null;
	}

	public PageReference deleteAttachments(){
		String attachId = System.currentPageReference().getParameters().get('attachmentIdToRemove');		
		
		List<AP_Attachment_gne__c> attachToDel = [SELECT Id, OwnerId FROM AP_Attachment_gne__c WHERE Id = :attachId];
		if(!attachToDel.isEmpty()){
			if(attachToDel[0].OwnerId == UserInfo.getUserId()){ 
				delete attachToDel;
			}else{
				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.GNE_AP_ERROR_delete_attachment);
				ApexPages.addMessage(myMsg);
			}
		}
		setAttachments();
		return null;
	}
		
	public Boolean getIsSubmitButtonEnabled(){
		return GNE_AP_DAO.isPlanContainsDetails(accountPlanId);
	}
    
    // Not in use anymore - can be removed
    public PageReference cancelAttachments(){ 
    	return null;
    }
    
    // Not in use anymore - can be removed
    public Boolean getIsDocAttached(){
     	return false;   
    }
	
	private class ApAttachment{
		public String Id { get; private set; }
		public String AttachId { get; private set; }
		public String Name { get; private set; }
		public DateTime CreatedDate { get; private set; }
		
		public ApAttachment(AP_Attachment_gne__c rec){
			this.Id = rec.Id;
			if (rec.Attachments != null && rec.Attachments.size() == 1){
				Attachment attached = rec.Attachments[0];
				this.AttachId = attached.Id;
				this.Name = attached.Name;
				this.CreatedDate = attached.CreatedDate;
			}
		}
	}
}