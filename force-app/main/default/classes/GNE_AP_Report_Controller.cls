public virtual class GNE_AP_Report_Controller{
	public Id accountPlanId{get; set;}
	public Id csUserId {get; set;}
	public List<AP_Detail_gne__c> accountPlanList {get; set;}
	public List<AP_Territory_Planning_gne__c> terrPlanList {get; set;}
	public List<AP_Account_gne__c> apAccountList {get; set;}
	public AP_Account_Planning_gne__c accPlansInfo {get; set;}
	public final Map<String, List<Row>> terrPlansMap{get; set;}
	public Map<String, List<String>> objectivesMap{get; set;}
	public Map<String, List<String>> tacticsMap{get; set;}
	public Map<String, List<String>> resourcesMap{get; set;}
	public Map<String, Boolean> selectedRowMap{get; set;}
	public String createdDateTime{get; set;}
	public String lastDateTime{get; set;}
	public String approvedDateTime{get; set;}
	public String territoryName {get; set;}
	public Boolean isPerformanceVisible {get; set;}

	private AP_Account_Planning_gne__c copyPlan;
	private AP_Account_Planning_gne__c currentPlan;
	private List<AP_PTP_gne__c> territoryMetrics;

	public Map<String, String> customLabels {get; set;}

	public GNE_AP_Report_Controller(){
		approvedDateTime = '';
		accountPlanId = ApexPages.currentPage().getParameters().get('planId');
		csUserId = ApexPages.currentPage().getParameters().get('csUserId');
		terrPlansMap = new Map<String, List<Row>>();
		objectivesMap = new Map<String, List<String>>();
		tacticsMap = new Map<String, List<String>>();
		resourcesMap = new Map<String, List<String>>();
		selectedRowMap = new Map<String, Boolean>();
		selectedRowMap.put('ALL', false);

		if (csUserId == null){
			csUserId = Userinfo.getUserId();
		}
		accPlansInfo = GNE_AP_DAO.getAccountPlan(accountPlanId);
		if(String.isNotEmpty(accPlansInfo.Territory_Id_gne__c)){
			territoryName = [SELECT Name FROM Territory2 WHERE id= :accPlansInfo.Territory_Id_gne__c].Name;
		}

		if(accPlansInfo.Status_gne__c == 'Approved'  || accPlansInfo.Status_gne__c == 'Archived'){
			approvedDateTime = GNE_AP_Util.getLocalDateTime(accPlansInfo.Date_Approved_gne__c);
		}
		createdDateTime = GNE_AP_Util.getLocalDateTime(accPlansInfo.CreatedDate);
		lastDateTime = GNE_AP_Util.getLocalDateTime(accPlansInfo.LastModifiedDate);

		accountPlanList = GNE_AP_DAO.getAccountPlanDetails(accountPlanId);
		terrPlanList = GNE_AP_DAO.getTerritoryPlanns(accountPlanId);
		Integer counter = 0;
		for(AP_Territory_Planning_gne__c terrPlan : terrPlanList){
			String categoryName = terrPlan.TP_Category_gne__c;
			if(!terrPlansMap.containsKey(categoryName)){
				terrPlansMap.put(categoryName, new List<Row>());
			}
			terrPlansMap.get(categoryName).add(new Row(counter++, terrPlan));
		}

		Set<Id> accountIds = new Set<Id>();

		for(AP_Detail_gne__c accPlan : accountPlanList){
			accountIds.add(accPlan.AP_Account_gne__c);
			String roleName = accPlan.Team_Member_gne__c;
			selectedRowMap.put(roleName, false);
			if(!objectivesMap.containsKey(roleName)){
				objectivesMap.put(roleName, new List<String>());
			}
			if(!tacticsMap.containsKey(roleName)){
				tacticsMap.put(roleName, new List<String>());
			}
			if(!resourcesMap.containsKey(roleName)){
				resourcesMap.put(roleName, new List<String>());
			}
			objectivesMap.get(roleName).add(accPlan.Objective_gne__c);
			tacticsMap.get(roleName).add(accPlan.Tactic_gne__c);
			resourcesMap.get(roleName).add(accPlan.Resource_gne__c);
		}
		apAccountList = GNE_AP_DAO.getAccounts(accountIds);

		territoryMetrics = [SELECT Brand_gne__c, Division_Month_gne__c, Division_Quarter_gne__c, Division_Year_gne__c, Franchise_Month_gne__c, Franchise_Quarter_gne__c, Franchise_Year_gne__c, Region_Month_gne__c, Region_Quarter_gne__c, Region_Year_gne__c, Territory_Month_gne__c, Territory_Quarter_gne__c, Territory_Year_gne__c, Type_gne__c FROM AP_PTP_gne__c WHERE AP_Account_Planning_gne__c = :accountPlanId];

		isPerformanceVisible = getIsPlanApproved() && !territoryMetrics.isEmpty();
		customLabels = GNE_AP_Territory_Planning.initializeCategoryLabels();
		customLabels.putAll(GNE_AP_Planning_Ctrl.initializeLabels());
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

	public class Row{
		public Integer rowId{get;set;}
		public AP_Territory_Planning_gne__c record{get; set;}
		public Row(Integer rowId, AP_Territory_Planning_gne__c record){
			this.rowId = rowId;
			this.record = record;
		}
	}

	public List<SelectOption> getAllResources(){
		List<SFA2_User_Sales_Roster_gne__c>  franchise = GNE_AP_Util.getFranchiseId(Userinfo.getUserId());
		List<AP_ResourceRequest_gne__c> result = null;
		if(franchise != null && franchise.size()>0){
			result = GNE_AP_Util.getResourceRequest(franchise.get(0).Sales_Roster_gne__r.Franchise__r.Id);
		} else {
			Id franchiseId = GNE_AP_Util.getFranchiseIdFromTerritoryMapping(Userinfo.getUserId());
			if(franchiseId != null){
				result = GNE_AP_Util.getResourceRequest(franchiseId);
			}
		}
		List<SelectOption> options = new List<SelectOption>();
		if(result != null){
			for(AP_ResourceRequest_gne__c apResource: result){
				options.add(new SelectOption(apResource.Name, apResource.Name));
			}
		}
		return options;
	}

	public Boolean getHasResources(){
		return !getAllResources().isEmpty();
	}

	public Set<String> getAvailableRoles(){
		Set<String> availableRows = new Set<String>();
		if(selectedRowMap != null){
			for(String key : selectedRowMap.keySet()){
				availableRows.add(key);
			}
		}
		availableRows.remove('ALL');
		return availableRows;
	}

	public Boolean getIsCopyAvailable(){
		if(GNE_AP_Util.isFE()){
			copyPlan = getCurrentlySelectedAccountPlan();
			currentPlan = GNE_AP_DAO.getActiveAccountPlan(UserInfo.getUserId());
			system.debug(accPlansInfo.Status_gne__c);
			system.debug(currentPlan);
			system.debug(copyPlan);
			system.debug( GNE_AP_Util.isFE());
			if(currentPlan != null && accPlansInfo.Status_gne__c == 'Archived' && ((currentPlan.Status_gne__c == 'In Progress')||(currentPlan.Status_gne__c == 'Approved')||(currentPlan.Status_gne__c == 'Returned')) &&(copyPlan.Id!=currentPlan.Id)){
				return true;
			}
		}
		return false;
	}

	private AP_Account_Planning_gne__c getCurrentlySelectedAccountPlan(){
		Map<String, Schema.SObjectField> allFieldsMap = schema.SObjectType.AP_Account_Planning_gne__c.fields.getMap();
		List<Schema.SObjectField> allFieldsValues = allFieldsMap.values();
		String query = 'SELECT ';
		for(Schema.SObjectField s : allFieldsValues){
			query += s.getDescribe().getName() + ',';
		}
		query = query.subString(0, query.length() - 1);
		query += ' FROM AP_Account_Planning_gne__c WHERE Id=:accountPlanId LIMIT 1';

		return Database.query(query);
	}

	private List<AP_Territory_Planning_gne__c> getAccountPlanRelatedTerritoryPlannings(Id accountPlanId){
		Map<String, Schema.SObjectField> allFieldsMap = schema.SObjectType.AP_Territory_Planning_gne__c.fields.getMap();
		List<Schema.SObjectField> allFieldsValues = allFieldsMap.values();
		String query = 'SELECT ';
		for(Schema.SObjectField s : allFieldsValues){
			query += s.getDescribe().getName() + ',';
		}
		query = query.subString(0, query.length() - 1);
		query += ' FROM AP_Territory_Planning_gne__c WHERE AP_Account_Planning_gne__c = :accountPlanId';
		return Database.query(query);
	}

	private List<AP_Detail_gne__c> getAccountPlanRelatedDetails(Id accountPlanId){
		Map<String, Schema.SObjectField> allFieldsMap = schema.SObjectType.AP_Detail_gne__c.fields.getMap();
		List<Schema.SObjectField> allFieldsValues = allFieldsMap.values();
		String query = 'SELECT ';
		for(Schema.SObjectField s : allFieldsValues){
			query += s.getDescribe().getName() + ',';
		}
		query = query.subString(0, query.length() - 1);
		query += ' FROM AP_Detail_gne__c WHERE AP_Account_Planning_gne__c = :accountPlanId';
		return Database.query(query);
	}

	private List<AP_Account_User_gne__c> getAccountPlanRelatedUsers(Id accountPlanId){
		Map<String, Schema.SObjectField> allFieldsMap = schema.SObjectType.AP_Account_User_gne__c.fields.getMap();
		List<Schema.SObjectField> allFieldsValues = allFieldsMap.values();
		String query = 'SELECT ';
		for(Schema.SObjectField s : allFieldsValues){
			query += s.getDescribe().getName() + ',';
		}
		query = query.subString(0, query.length() - 1);
		query += ' FROM AP_Account_User_gne__c WHERE AP_Account_Planning_gne__c= :accountPlanId';
		return Database.query(query);
	}

	public void getCloneAccountPlanning(){
		if(currentPlan != null){
			Id tempId = currentPlan.Id;
			currentPlan = copyPlan.clone(false, true, false, false);
			currentPlan.Date_Approved_gne__c = null;
			currentPlan.Date_Archived_gne__c = null;
			currentPlan.Date_Returned_gne__c = null;
			currentPlan.Date_Submitted_gne__c = null;
			currentPlan.Franchise_Goal_gne__c = null;
			currentPlan.CS_User_gne__c = UserInfo.getUserId();
			currentPlan.OwnerId = UserInfo.getUserId();
			currentPlan.DM_User_gne__c = GNE_AP_DAO.getUserManagerId(UserInfo.getUserId());

			currentPlan.Name = GNE_AP_Util.getNewAccountPlanName();
			GNE_AP_Util.setAccountPlanActionAndStatus(currentPlan, GNE_AP_Util.AP_NEW_STATUS);
			currentPlan.Id = tempId;

			List <AP_Territory_Planning_gne__c> relatedAccountPlanTerritories = getAccountPlanRelatedTerritoryPlannings(copyPlan.Id);
			List <AP_Detail_gne__c> relatedAccountPlanDetails = getAccountPlanRelatedDetails(copyPlan.Id);
			List <AP_Account_User_gne__c> relatedAccountPlanUsers = getAccountPlanRelatedUsers(copyPlan.Id);

			/*Remove old plan elements. I don't know why field territory.AP_Account_Planning_gne__c is set to value tempId */
			List <AP_Territory_Planning_gne__c> relatedAccountPlanTerritoriesCurrentRecord = getAccountPlanRelatedTerritoryPlannings(tempId);
			List <AP_Detail_gne__c> relatedAccountPlanDetailsCurrentRecord = getAccountPlanRelatedDetails(tempId);
			List <AP_Account_User_gne__c> relatedAccountUsersCurrentRecord = getAccountPlanRelatedUsers(tempId);

			if(!relatedAccountPlanTerritoriesCurrentRecord.isEmpty()){
				delete relatedAccountPlanTerritoriesCurrentRecord;
			}
			if(!relatedAccountPlanDetailsCurrentRecord.isEmpty()){
				delete relatedAccountPlanDetailsCurrentRecord;
			}
			if(!relatedAccountUsersCurrentRecord.isEmpty()){
				delete relatedAccountUsersCurrentRecord;
			}

			/*Copy plan elements from archive plan*/
			if(!relatedAccountPlanTerritories.isEmpty()){
				List<AP_Territory_Planning_gne__c>toInsert = new List<AP_Territory_Planning_gne__c>();
				for(AP_Territory_Planning_gne__c territory : relatedAccountPlanTerritories){
					AP_Territory_Planning_gne__c territoryClone = territory.clone(false, true, false, false);
					territoryClone.AP_Account_Planning_gne__c = tempId;
					toInsert.add(territoryClone);
				}
				insert toInsert;
			}
/*
			if(!relatedAccountPlanUsers.isEmpty()){
				for(AP_Account_User_gne__c user : relatedAccountPlanUsers){
					AP_Account_User_gne__c userClone = user.clone(false, true, false, false);
					userClone.Account_CSUser_gne__c = user.AP_Account_gne__c+'-'+user.CS_User_gne__c+'-'+tempId;
					userClone.AP_Account_Planning_gne__c = tempId;
					insert userClone;
				}
			}
	*/
			if(!relatedAccountPlanDetails.isEmpty()){
				List<AP_Detail_gne__c>toInsert = new List<AP_Detail_gne__c>();
				for(AP_Detail_gne__c detail : relatedAccountPlanDetails){
					AP_Detail_gne__c detailClone = detail.clone(false, true, false, false);
					detailClone.AP_Account_Planning_gne__c = tempId;
					toInsert.add(detailClone);
				}
				insert toInsert;
			}
			update currentPlan;
		}
	}

	public List<AP_Account_PTP_gne__c>getAccountsMetrics(){
		return [SELECT AP_Account_gne__c, AP_Account_gne__r.Name, AP_Account_Planning_gne__c, Brand_gne__c, RCP_R3_gne__c, RCP_R6_gne__c, RCP_R12_gne__c, RCR6_CTRB_PC_gne__c, RCR6_CTRB_RNK_gne__c, RCR6_GRWTH_PC_gne__c, RCR6_GRWTH_RNK_gne__c, RGPA_R12_gne__c, RGPA_R3_gne__c, RGPA_R6_gne__c, RVA_R12_gne__c, RVA_R3_gne__c, RVA_R6_gne__c, YOYGP_R12_gne__c, YOYGP_R3_gne__c, YOYGP_R6_gne__c FROM AP_Account_PTP_gne__c WHERE AP_Account_Planning_gne__c = :accountPlanId];
	}

	public List<AP_PTP_gne__c>getTerritoryMetrics(){
		return territoryMetrics;
	}

	public CompetitorMetricsWrapper getCompetitorMetrics(){
		CompetitorMetricsWrapper wrapper = new CompetitorMetricsWrapper();

		Set<String> brands = new Set<String>();
		Map<String, List<String>> brandToCompetitorBrands = new Map<String, List<String>>();
		Map<String, Set<String>> brandToCompetitorBrandsSet = new Map<String, Set<String>>();

		Map<String, Set<String>> brandToAccounts = new Map<String, Set<String>>();
		Map<String, Map<String, List<Double>>>brandToAccountsMetrics = new Map<String, Map<String, List<Double>>>();

		for(AP_Competitor_Metric_gne__c metric : [SELECT Id, AP_Account_PTP_gne__r.AP_Account_gne__r.Name, Brand_gne__c, CBGR6_PC_gne__c, Competitor_Brand_gne__c FROM AP_Competitor_Metric_gne__c WHERE AP_Account_PTP_gne__r.AP_Account_Planning_gne__c = :accountPlanId ORDER BY Competitor_Brand_gne__c]){
			String accountName = metric.AP_Account_PTP_gne__r.AP_Account_gne__r.Name;

			if(!brands.contains(metric.Brand_gne__c)){
				brands.add(metric.Brand_gne__c);
				brandToCompetitorBrands.put(metric.Brand_gne__c, new List<String>());
				brandToCompetitorBrandsSet.put(metric.Brand_gne__c, new Set<String>());

				brandToAccounts.put(metric.Brand_gne__c, new Set<String>());
				brandToAccountsMetrics.put(metric.Brand_gne__c, new Map<String, List<Double>>());
			}
			if(brandToCompetitorBrandsSet.get(metric.Brand_gne__c).add(metric.Competitor_Brand_gne__c)){
				brandToCompetitorBrands.get(metric.Brand_gne__c).add(metric.Competitor_Brand_gne__c);
			}
			if(brandToAccounts.get(metric.Brand_gne__c).add(accountName)){
				brandToAccountsMetrics.get(metric.Brand_gne__c).put(accountName, new List<Double>());
			}
			brandToAccountsMetrics.get(metric.Brand_gne__c).get(accountName).add(metric.CBGR6_PC_gne__c);
		}
		wrapper.brands = brands;
		wrapper.brandToCompetitorBrands = brandToCompetitorBrands;
		wrapper.brandToAccounts = brandToAccounts;
		wrapper.brandToAccountsMetrics = brandToAccountsMetrics;
		return wrapper;
	}

	public class CompetitorMetricsWrapper{
		public Set<String>brands{get; set;}
		public Map<String, List<String>>brandToCompetitorBrands {get; set;}
		public Map<String, Set<String>>brandToAccounts {get; set;}
		public Map<String, Map<String, List<Double>>>brandToAccountsMetrics {get; set;}
	}

	public Boolean getIsPlanApproved(){
		system.debug(accPlansInfo.Status_gne__c);
		return accPlansInfo.Status_gne__c == 'Approved' || accPlansInfo.Status_gne__c == 'Archived';
	}
}