public class GNE_AP_Planning_Ctrl extends GNE_AP_Base_Class{
	
	private static final Integer MAX_PLAN_ELEMENTS = 50;
	
	public String accountId {get; set;}
	public Map<String, String>labels {get; set;}

	private AP_Account_Planning_gne__c accountPlanning;
	private List<AP_Detail_gne__c> planDetails;
	
	public String filterAccounts {get; private set;}
	public String filterProducts {get; private set;}
	public String filterResources {get; private set;}
	public String filterTeamMembers {get; private set;}
	public String filterTimeLines {get; private set;}
	
	
	public GNE_AP_Planning_Ctrl(ApexPages.StandardController controller){
		super();
		accountId = ApexPages.currentPage().getParameters().get('accountId');
		
		if(String.isNotEmpty(accountPlanId)){
			accountPlanning = GNE_AP_DAO.getAccountPlan(accountPlanId);
		}
		planDetails = getDetails(accountPlanId);
		labels = initializeLabels();
		FilterWrrapper filterWrapper = getFilterVariables(planDetails);
				
		filterAccounts = filterWrapper.filterAccounts;
		filterProducts = filterWrapper.filterProducts;
		filterResources = filterWrapper.filterResources;
		filterTeamMembers = filterWrapper.filterTeamMembers;
		filterTimeLines = filterWrapper.filterTimeLines;
	}
	
	@RemoteAction
	public static List<AP_Detail_gne__c> getDetailList(String accountPlanId, String accountId, String teamMember, String timeLine, String product, String resource){
		String whereClause = '';
		if(String.isNotEmpty(accountPlanId)){
			whereClause = ' WHERE AP_Account_Planning_gne__c = :accountPlanId ' ;
		}else if(GNE_AP_Util.isFM()){
			String userid = UserInfo.getUserId();
			String submitted = GNE_AP_Util.AP_SUBMITTED;
			String approved = GNE_AP_Util.AP_APPROVED;
			whereClause = ' WHERE AP_Account_Planning_gne__r.DM_User_gne__c = :userid AND Status_gne__c IN (:submitted, :approved)';
		}

		if(accountId != null){
			whereClause += ' AND AP_Account_gne__c = :accountId';
		}
		if(teamMember != null){
			whereClause += ' AND Team_Member_gne__c = :teamMember';
		}
		if(timeLine != null){
			whereClause += ' AND Time_Line_gne__c = :timeLine';
		}
		if(product != null){
			whereClause += ' AND Product_gne__c = :product';
		}
		if(resource != null){
			whereClause += ' AND Resource_gne__c = :resource';
		}
		String query = 'SELECT Id, Name, AP_Account_gne__c, AP_Account_Planning_gne__c, AP_Account_gne__r.Id, AP_Account_gne__r.Name, AP_Account_gne__r.OrgId_gne__c, Comments_gne__c, Objective_gne__c, Resource_gne__c, Tactic_gne__c, Team_Member_gne__c, Team_Member_Comments_gne__c, Time_Line_gne__c, Product_gne__c, Product_gne__r.Name FROM AP_Detail_gne__c '+ whereClause + ' ORDER BY AP_Account_gne__r.Name ASC LIMIT 100';
		system.debug(query);
		return Database.query(query);
	}
	
	public Boolean getIsAPCreated(){
		String param = ApexPages.currentPage().getParameters().get('started');
		if(String.isNotEmpty(param) && param == 'true'){
			return true;
		}else{
			return false;
		}
	}
	
	public String getAvailableAccounts() {
		List<SelectOptionClass> options = new List<SelectOptionClass>();
		if(accountPlanning != null){
			for(AP_Account_User_gne__c apAccount : GNE_AP_DAO.getUserAccounts(accountPlanning.CS_User_gne__c)){
				options.add(new SelectOptionClass(apAccount.AP_Account_gne__c, apAccount.AP_Account_gne__r.Name));
			}
		}
		options.sort();
		return JSON.serialize(options);
	}
	
	public String getAvailableProducts() {
		List<SelectOptionClass> options = new List<SelectOptionClass>();
		options.add(new SelectOptionClass('', '--None--'));
		if(accountPlanning != null){
			for(Product_vod__c product : GNE_AP_DAO.getUserBrands(accountPlanning.CS_User_gne__c)){
				options.add(new SelectOptionClass(product.Id, product.Name));
			}
		}
		options.sort();
		return JSON.serialize(options);
	}
	
	public String getAvailableResources(){
		List<SelectOptionClass> options = new List<SelectOptionClass>();
		options.add(new SelectOptionClass('', '--None--'));
		for(AP_ResourceRequest_gne__c resource : GNE_AP_DAO.getAllResources()){
			options.add(new SelectOptionClass(resource.Name, resource.Name));
		}
		options.sort();
		return JSON.serialize(options);
	}
	
	public String getAvailableTimeLines(){
		List<SelectOptionClass> options = new List<SelectOptionClass>();
		options.add(new SelectOptionClass('', '--None--'));
		Schema.DescribeFieldResult fieldResult = AP_Detail_gne__c.Time_Line_gne__c.getDescribe();
		for(Schema.PicklistEntry entry : fieldResult.getPicklistValues()){
			options.add(new SelectOptionClass(entry.getValue(), entry.getLabel()));
		}
		options.sort();		
		return JSON.serialize(options);
	}
	
	public String getAvailableTeamMembers(){
		List<SelectOptionClass> availableTeamMembersOptionsForFranchise = new List<SelectOptionClass>();
		availableTeamMembersOptionsForFranchise.add(new SelectOptionClass('', '--None--'));
		if(accountPlanning != null){
			List<SFA2_User_Sales_Roster_gne__c>franchises = GNE_AP_Util.getFranchiseId(accountPlanning.CS_User_gne__c);
			if(!franchises.isEmpty()){
				Id franchiseId = franchises.get(0).Sales_Roster_gne__r.Franchise__r.Id;
				for(AP_Franchise_Team_Member_gne__c teamMember : [SELECT Name FROM AP_Franchise_Team_Member_gne__c WHERE Franchise_gne__c = :franchiseId]){
					availableTeamMembersOptionsForFranchise.add(new SelectOptionClass(teamMember.Name, teamMember.Name));
				}
			} else {
				Id franchiseId = GNE_AP_Util.getFranchiseIdFromTerritoryMapping(accountPlanning.CS_User_gne__c);
				if(franchiseId != null){
					for(AP_Franchise_Team_Member_gne__c teamMember : [SELECT Name FROM AP_Franchise_Team_Member_gne__c WHERE Franchise_gne__c = :franchiseId]){
						availableTeamMembersOptionsForFranchise.add(new SelectOptionClass(teamMember.Name, teamMember.Name));
					}
				}
			}
		}
		availableTeamMembersOptionsForFranchise.sort();
		return JSON.serialize(availableTeamMembersOptionsForFranchise);
	}
	
	private static FilterWrrapper getFilterVariables(List<AP_Detail_gne__c> planDetails){
		List<SelectOptionClass> accountsForFilter = new List<SelectOptionClass>();
		accountsForFilter.add(new SelectOptionClass('', '--None--'));
		List<SelectOptionClass> productsForFilter = new List<SelectOptionClass>();
		productsForFilter.add(new SelectOptionClass('', '--None--'));
		List<SelectOptionClass> resourceForFilter = new List<SelectOptionClass>();
		resourceForFilter.add(new SelectOptionClass('', '--None--'));
		List<SelectOptionClass> teamMemberForFilter = new List<SelectOptionClass>();
		teamMemberForFilter.add(new SelectOptionClass('', '--None--'));
		List<SelectOptionClass> timeLineForFilter = new List<SelectOptionClass>();
		timeLineForFilter.add(new SelectOptionClass('', '--None--'));
		
		Set<Id>uniqueAccounts = new Set<Id>();
		Set<Id>uniqueProducts = new Set<Id>();
		Set<String>uniqueResources = new Set<String>();
		Set<String>uniqueTeamMembers = new Set<String>();
		Set<String>uniqueTimeLines= new Set<String>();
		
		for(AP_Detail_gne__c detail: planDetails){
			if(uniqueAccounts.add(detail.AP_Account_gne__c)){
				accountsForFilter.add(new SelectOptionClass(detail.AP_Account_gne__c, detail.AP_Account_gne__r.Name));
			}
			if(String.isNotEmpty(detail.Product_gne__c) && String.isNotEmpty(detail.Product_gne__r.Name) && uniqueProducts.add(detail.Product_gne__c)) {						
				productsForFilter.add(new SelectOptionClass(detail.Product_gne__c, detail.Product_gne__r.Name));
			}
			if(String.isNotEmpty(detail.Resource_gne__c) && uniqueResources.add(detail.Resource_gne__c)){
				resourceForFilter.add(new SelectOptionClass(detail.Resource_gne__c, detail.Resource_gne__c));
			}
			if(String.isNotEmpty(detail.Team_Member_gne__c) && uniqueTeamMembers.add(detail.Team_Member_gne__c)){
				teamMemberForFilter.add(new SelectOptionClass(detail.Team_Member_gne__c, detail.Team_Member_gne__c));
			}
			if(String.isNotEmpty(detail.Time_Line_gne__c) && uniqueTimeLines.add(detail.Time_Line_gne__c)){
				timeLineForFilter.add(new SelectOptionClass(detail.Time_Line_gne__c, detail.Time_Line_gne__c));
			}
		}
		accountsForFilter.sort();
		productsForFilter.sort();
		resourceForFilter.sort();
		teamMemberForFilter.sort();
		timeLineForFilter.sort();
		return new FilterWrrapper(JSON.serialize(accountsForFilter), JSON.serialize(productsForFilter), JSON.serialize(resourceForFilter), JSON.serialize(teamMemberForFilter), JSON.serialize(timeLineForFilter));
	}
	
	@RemoteAction
	public static FilterWrrapper saveDetail(AP_Detail_gne__c detail){
		system.debug('Detail: '+detail);
		system.debug(detail.Product_gne__c);
		//There cann't be more than 50 accounts added
		//BR05:	There will never be more than one Account Plan for the same Account and Product for the same time period.
		List<AP_Detail_gne__c> details = [SELECT Id, Product_gne__c, AP_Account_gne__c FROM AP_Detail_gne__c WHERE AP_Account_Planning_gne__c = :detail.AP_Account_Planning_gne__c];
		system.debug(details);
		
		if(details.size() >= MAX_PLAN_ELEMENTS && detail.id == null){
			throw new GNE_AP_Exception(Label.GNE_AP_Plan_Max_Elements);
		}
		
		if(detail.Product_gne__c != null){
			for(AP_Detail_gne__c planDetail: details){
				if(planDetail.AP_Account_gne__c == detail.AP_Account_gne__c && planDetail.Product_gne__c == detail.Product_gne__c &&  planDetail.Id != detail.Id){
					throw new GNE_AP_Exception(Label.GNE_AP_Account_Product_Validation);
				}
			}
		}
		Database.upsert(detail);
		return getFilterVariables(getDetails(detail.AP_Account_Planning_gne__c));
	}

	@RemoteAction
	public static FilterWrrapper deleteDetail(AP_Detail_gne__c detail){
		Database.delete(detail);
		return getFilterVariables(getDetails(detail.AP_Account_Planning_gne__c));
	}
	
	private static List<AP_Detail_gne__c>getDetails(String accountPlanId){
		String whereClause = '';
		system.debug(GNE_AP_Util.isFM());
		system.debug(accountPlanId);
		if(String.isNotEmpty(accountPlanId)){
			whereClause = ' WHERE AP_Account_Planning_gne__c = :accountPlanId ' ;
		}else if(GNE_AP_Util.isFM()){
			String userid = UserInfo.getUserId();
			String submitted = GNE_AP_Util.AP_SUBMITTED;
			String approved = GNE_AP_Util.AP_APPROVED;
			whereClause = ' WHERE AP_Account_Planning_gne__r.DM_User_gne__c = :userid AND Status_gne__c IN (:submitted, :approved)';
		}
		String query = 'SELECT Id, Name, AP_Account_gne__c, AP_Account_Planning_gne__c, AP_Account_gne__r.Id, AP_Account_gne__r.Name, AP_Account_gne__r.OrgId_gne__c, Comments_gne__c, Objective_gne__c, Resource_gne__c, Tactic_gne__c, Team_Member_gne__c, Team_Member_Comments_gne__c, Time_Line_gne__c, Product_gne__c, Product_gne__r.Name FROM AP_Detail_gne__c '+ whereClause + ' ORDER BY AP_Account_gne__r.Name ASC LIMIT 100';
		system.debug(query);
		return Database.query(query);
	}
	
	public static Map<String, String> initializeLabels(){
		Map<String, String> labels = new Map<String, String>();
		labels.put('AP_Account_gne__c', 'Account');
		labels.put('Product_gne__c', 'Product');
		labels.put('Objective_gne__c', 'Objectives');
		labels.put('Tactic_gne__c', 'Tactic');
		labels.put('Resource_gne__c', 'Resource');
		labels.put('Team_Member_gne__c', 'Team Member');
		labels.put('Team_Member_Comments_gne__c', 'Team Member Comments');
		labels.put('Time_Line_gne__c', 'Time Line');
		labels.put('Comments_gne__c', 'Comments');
		
		List<Territory2>territories = GNE_AP_Util.getUserTerritories(UserInfo.getUserId());
		if(territories.size()>0){
			Map<String, String> customLabels = GNE_AP_Util.getCustomLabel(new List<String>(labels.keySet()), territories.get(0).Salesforce_Code_gne__c, territories.get(0).Salesforce_SubTeam_Code_gne__c);
			for(String key: labels.keySet()){
				if(customLabels.containsKey(key)){
					labels.put(key, customLabels.get(key));
				}
			}
		}
		return labels;
	}
	
	@RemoteAction
	public static void copyAccountPlan(AP_Detail_gne__c apDetail){
		system.debug(apDetail);
		AP_Plan_Detail_Storage_gne__c storage = GNE_AP_DAO.getUserStorage(UserInfo.getUserId());
		if(storage == null){
			storage = new AP_Plan_Detail_Storage_gne__c();
		}
		storage.Session_Id_gne__c = UserInfo.getSessionId();
		storage.AP_Account_gne__c = apDetail.AP_Account_gne__c;
		storage.Comments_gne__c = apDetail.Comments_gne__c;
		storage.Objective_gne__c = apDetail.Objective_gne__c;
		storage.Resource_gne__c = apDetail.Resource_gne__c;
		storage.Product_gne__c = apDetail.Product_gne__c;
		storage.Tactic_gne__c = apDetail.Tactic_gne__c;
		storage.Team_Member_Comments_gne__c = apDetail.Team_Member_Comments_gne__c;
		storage.Team_Member_gne__c = apDetail.Team_Member_gne__c;
		storage.Time_Line_gne__c = apDetail.Time_Line_gne__c;
		upsert storage;
	}
	
	@RemoteAction
	public static AP_Plan_Detail_Storage_gne__c pasteAccountPlan(){
		return GNE_AP_DAO.getUserStorage(UserInfo.getUserId());
	}
	
	public Boolean getIsPasteButtonEnabled(){
		if(getIsFM()){
			return false;
		}
		AP_Plan_Detail_Storage_gne__c storage = GNE_AP_DAO.getUserStorage(UserInfo.getUserId());
		return storage != null && (storage.Session_Id_gne__c == UserInfo.getSessionId());
	}
	
	public Boolean getIsAddButtonEnabled(){		
		return getIsFE() && accountPlanning != null && GNE_AP_DAO.getUserAccounts(accountPlanning.CS_User_gne__c).size() > 0;
	}
	
	public class SelectOptionClass implements Comparable{
		public String value { get; set; }
		public String label { get; set; }
		
		SelectOptionClass(String value, String label) {
			this.value = value;
			this.label = label;
		}
		
		public Integer compareTo(Object compareTo) {
		    SelectOptionClass compareToOption = (SelectOptionClass)compareTo;

		    if(label == '--None--' ) {
		    	return -1;
		    }else if (compareToOption.label == '--None--'){
		    	return 1;
		    }

		    return label.toLowerCase().compareTo(compareToOption.label.toLowerCase());
		}
	}
	
	public String getAccountPlanStatus(){
		if(accountPlanning != null){
			return accountPlanning.Status_gne__c;
		}
		return null;
	}
	
	public Boolean getIsSubmitButtonEnabled(){
		return planDetails.size() > 0;
	}
	
	@RemoteAction
	public static Boolean isSubmitButtonEnabled(String accountPlanId){
		return GNE_AP_DAO.isPlanContainsDetails(accountPlanId);
	}
	
	
	class FilterWrrapper{
		public String filterAccounts {get; private set;}
		public String filterProducts {get; private set;}
		public String filterResources {get; private set;}
		public String filterTeamMembers {get; private set;}
		public String filterTimeLines {get; private set;}
		
		public FilterWrrapper(String filterAccounts, String filterProducts, String filterResources, String filterTeamMembers, String filterTimeLines){
			this.filterAccounts = filterAccounts;
			this.filterProducts = filterProducts;
			this.filterResources = filterResources;
			this.filterTeamMembers = filterTeamMembers;
			this.filterTimeLines = filterTimeLines;
		}
	}
}