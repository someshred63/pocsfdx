public class GNE_AP_Team_Planning extends GNE_AP_Base_Class {

	private List<AP_Detail_gne__c> accountPlanList;
	public Map<String, List<WrapperReadMore>> objectivesMap{get;set;}
	public Map<String, List<WrapperReadMore>> tacticsMap{get;set;}
	public Map<String, List<WrapperReadMore>> resourcesMap{get;set;}
	
	public Map<String, Boolean> objectivesMapRendered{get;set;}
	public Map<String, Boolean> tacticsMapRendered{get;set;}
	public Map<String, Boolean> resourcesMapRendered{get;set;}
	public Map<String, Boolean> selectedRowMap{get;set;}
	public List<SelectOption> accountList{get;set;}
	public List<SelectOption> timelineList{get;set;}
	public String selectedAccountFilter{get;set;}
	public String selectedTimelineFilter{get;set;}
	public String role{get;set;}
	public String searchTerm {get; set;}
	public String selectedEmail{get; set;}
	public Boolean areAllSelected {get;set;}
	public AP_Account_Planning_gne__c accountPlanning {get; set;}

	private class WrapperReadMore{
		public String element{get;set;}
		public Datetime modifiedDate{get;set;}

		public WrapperReadMore(String element, Datetime modifiedDate){
			this.element = element;
			this.modifiedDate = modifiedDate;
		}
	}

	public GNE_AP_Team_Planning(ApexPages.StandardController controller){
		super();
		accountPlanList = new List<AP_Detail_gne__c>();
		if(csUserId == null){
			csUserId = UserInfo.getUserId();
		}
		if(String.isNotEmpty(accountPlanId)){
			accountPlanList = GNE_AP_DAO.getAccountPlanDetails(accountPlanId);
			accountPlanning = GNE_AP_DAO.getAccountPlan(accountPlanId);
		} 
		objectivesMap = new Map<String,List<WrapperReadMore>>();
		tacticsMap = new Map<String, List<WrapperReadMore>>();
		resourcesMap = new Map<String, List<WrapperReadMore>>();
		objectivesMapRendered = new Map<String, Boolean>();
		tacticsMapRendered = new Map<String, Boolean>();
		resourcesMapRendered = new Map<String, Boolean>();
		selectedAccountFilter = 'Account';
		selectedTimelineFilter = 'Timeline';
		selectedRowMap = new Map<String, Boolean>();
		selectedRowMap.put('ALL', true);
		role = '';
		areAllSelected = true;
		Set<SelectOption> accountNoDuplicates = new Set<SelectOption>();
		Set<SelectOption> timelineNoDuplicates  = new Set<SelectOption>();
		for(AP_Detail_gne__c accPlan : accountPlanList){
			String roleName = accPlan.Team_Member_gne__c;
			String accountName = accPlan.AP_Account_gne__r.Name;
			String timeline = accPlan.Time_Line_gne__c;
			if(roleName != null){
				selectedRowMap.put(roleName, true);
				if(accPlan.AP_Account_gne__c != null){
					accountNoDuplicates.add(new SelectOption(accPlan.AP_Account_gne__c, accountName));
				}
				if(timeline != null){
					timelineNoDuplicates.add(new SelectOption(timeline, timeline));
				}
				if(!objectivesMap.containsKey(roleName)){
					objectivesMap.put(roleName, new List<WrapperReadMore>());
				}
				if(!tacticsMap.containsKey(roleName)){
					tacticsMap.put(roleName, new List<WrapperReadMore>());
				}
				if(!resourcesMap.containsKey(roleName)){
					resourcesMap.put(roleName, new List<WrapperReadMore>());
				}
				if(accPlan.Objective_gne__c != null){
					objectivesMap.get(roleName).add(new WrapperReadMore(accPlan.Objective_gne__c, accPlan.LastModifiedDate));
				}
				if(accPlan.Tactic_gne__c != null){
					tacticsMap.get(roleName).add(new WrapperReadMore(accPlan.Tactic_gne__c, accPlan.LastModifiedDate));
				}
				if(accPlan.Resource_gne__c != null){
					resourcesMap.get(roleName).add(new WrapperReadMore(accPlan.Resource_gne__c, accPlan.LastModifiedDate));
				}
				resourcesMapRendered.put(roleName, !resourcesMap.get(roleName).isEmpty());
				objectivesMapRendered.put(roleName, !objectivesMap.get(roleName).isEmpty());
				tacticsMapRendered.put(roleName, !tacticsMap.get(roleName).isEmpty());
			}
		}
		accountList = new List<SelectOption>();
		timelineList = new List<SelectOption>();

		accountList.addAll(accountNoDuplicates);
		timelineList.addAll(timelineNoDuplicates);
		timelineList.sort();
		accountList.sort();
		
		if(accountList.isEmpty()){
			accountList.add(new SelectOption('Account', 'Account'));
		}else{
			accountList.add(0, new SelectOption('Account', 'Account'));
		}
		if(timelineList.isEmpty()){
			timelineList.add(new SelectOption('Timeline','Timeline'));
		}else{
			timelineList.add(0, new SelectOption('Timeline','Timeline'));
		}
		
		role = 'ALL';
		system.debug(fmUserId);
	}

	public Set<String> getSelectedRoles(){
		Set<String> selectedRows = new Set<String>();
		for(String key : selectedRowMap.keySet()){
			if(selectedRowMap.get(key) && !key.equals('ALL')){
				selectedRows.add(key);
			}
		}
		return selectedRows;
	}

	public void selectedAccount(){
		system.debug(selectedAccountFilter);
		system.debug(selectedTimelineFilter);
		
		objectivesMap.clear();
		tacticsMap.clear();
		resourcesMap.clear();
		objectivesMapRendered.clear();
		tacticsMapRendered.clear();
		resourcesMapRendered.clear();
		
		for(AP_Detail_gne__c accPlan:accountPlanList){
			String roleName = accPlan.Team_Member_gne__c;
			String accountName = accPlan.AP_Account_gne__r.Name;
			String timeline = accPlan.Time_Line_gne__c;
			system.debug('Role Name: ' + roleName);
			system.debug('Account Name: ' + accountName);
			system.debug('Timeline: ' + timeline);
			if(roleName != null){
				if(!objectivesMap.containsKey(roleName)){
					objectivesMap.put(roleName, new List<WrapperReadMore>());
					objectivesMapRendered.put(roleName, false);
				}
				if(!tacticsMap.containsKey(roleName)){
					tacticsMap.put(roleName, new List<WrapperReadMore>());
					tacticsMapRendered.put(roleName, false);
				}
				if(!resourcesMap.containsKey(roleName)){
					resourcesMap.put(roleName, new List<WrapperReadMore>());
					resourcesMapRendered.put(roleName, false);
				}
				
				if((selectedAccountFilter.equals(accountName) || selectedAccountFilter.equals('Account')) && (selectedTimelineFilter.equals(timeline) || selectedTimelineFilter.equals('Timeline'))){
					if(accPlan.Objective_gne__c != null){
						objectivesMap.get(roleName).add(new WrapperReadMore(accPlan.Objective_gne__c, accPlan.LastModifiedDate));
						objectivesMapRendered.put(roleName, true);
					}
					if(accPlan.Tactic_gne__c != null){
						tacticsMap.get(roleName).add(new WrapperReadMore(accPlan.Tactic_gne__c, accPlan.LastModifiedDate));
						tacticsMapRendered.put(roleName, true);
					}
					if(accPlan.Resource_gne__c != null){
						resourcesMap.get(roleName).add(new WrapperReadMore(accPlan.Resource_gne__c, accPlan.LastModifiedDate));
						resourcesMapRendered.put(roleName, true);
					}
				}
			}
		}
	}

	public List<String> getAvailableRoles(){
		List<String>result = new List<String>(selectedRowMap.keySet());
		result.sort();
		return result;
	}

	public PageReference selectedRow(){
		system.debug(areAllSelected);
		if(role.equals('ALL')){
			for(String key : selectedRowMap.keySet()){
				system.debug(key);
				system.debug(selectedRowMap.get(key));
				if(selectedRowMap.get(key) == false){
					areAllSelected = false;
				}
			}
			for(String key : selectedRowMap.keySet()){
				selectedRowMap.put(key, !areAllSelected);
			}
		}
		areAllSelected = true;
		return null;
	}
	
	public Boolean getIsSubmitButtonEnabled(){
		return GNE_AP_DAO.isPlanContainsDetails(accountPlanId);
	}
}