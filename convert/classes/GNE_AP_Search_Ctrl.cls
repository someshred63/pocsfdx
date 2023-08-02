public without sharing class GNE_AP_Search_Ctrl {

	private static final String ARCHIVED_AP_STATUS = GNE_AP_Util.AP_ARCHIVED;
	public static final Integer MAX_RECORD_COUNT = Integer.valueOf(Utilities.getGlobalVariable('GNE_FCR_History_Records_Limit'));

	public Id palnId {get; set;}
	public String sInputValue {get; set;}
	public List<AP_Account_Planning_gne__c> plans {get;set;}
	public Boolean isAdvancedSearch {get;set;}
	public String dateFrom {get;set;}
	public String dateTo {get;set;}
	public List<String> pickedFRs {get;set;}
	public List<String> pickedFEs {get;set;}
	private String advancedParameters {get; set;}
	private String advancedReferencedParameters {get; set;}
	private Date dFrom {get; set;}
	private Date dTo {get; set;}
	
	public Boolean getIsHCOUser(){
    	return GNE_AP_Util.getIsDataViewerAdmin();
    }
	
	public GNE_AP_Search_Ctrl(){
		plans = new List<AP_Account_Planning_gne__c>();
	}

	public void setLastVisitedPage() {
		GNE_AP_Navigation_Controller.setLastVisitedPage();		
	}
	
	public PageReference simpleSearch(){
		try{
			plans.clear();
			if((!isAdvancedSearch && isQueryInputValid(sInputValue)) || (isQueryInputValid(sInputValue) && areDatesValid())){
				prepareQueryParameters();
				String input = '*'+sInputValue+'*';
				
				String queryString = 'FIND \'( '+input+' )\' IN ALL FIELDS RETURNING  AP_Territory_Planning_gne__c (AP_Account_Planning_gne__r.Name, AP_Account_Planning_gne__r.CreatedDate, AP_Account_Planning_gne__r.Date_Approved_gne__c, AP_Account_Planning_gne__r.CS_User_gne__r.name, AP_Account_Planning_gne__r.CS_User_gne__r.FirstName, AP_Account_Planning_gne__r.CS_User_gne__r.LastName, AP_Account_Planning_gne__r.DM_User_gne__r.FirstName, AP_Account_Planning_gne__r.DM_User_gne__r.LastName, AP_Account_Planning_gne__r.DM_User_gne__r.name WHERE AP_Account_Planning_gne__r.status_gne__c = \''+ARCHIVED_AP_STATUS+'\'' + advancedReferencedParameters+' )'
						+',AP_Detail_gne__c (AP_Account_Planning_gne__r.Name, AP_Account_Planning_gne__r.CreatedDate, AP_Account_Planning_gne__r.Date_Approved_gne__c, AP_Account_Planning_gne__r.CS_User_gne__r.name, AP_Account_Planning_gne__r.DM_User_gne__r.name, AP_Account_Planning_gne__r.CS_User_gne__r.FirstName, AP_Account_Planning_gne__r.CS_User_gne__r.LastName, AP_Account_Planning_gne__r.DM_User_gne__r.FirstName, AP_Account_Planning_gne__r.DM_User_gne__r.LastName, resource_gne__c WHERE AP_Account_Planning_gne__r.status_gne__c = \''+ARCHIVED_AP_STATUS+'\'' + advancedReferencedParameters+' )'
						+',AP_Account_User_gne__c (AP_Account_Planning_gne__r.Name, AP_Account_Planning_gne__r.CreatedDate, AP_Account_Planning_gne__r.Date_Approved_gne__c, AP_Account_Planning_gne__r.CS_User_gne__r.name, AP_Account_Planning_gne__r.CS_User_gne__r.FirstName, AP_Account_Planning_gne__r.CS_User_gne__r.LastName, AP_Account_Planning_gne__r.DM_User_gne__r.FirstName, AP_Account_Planning_gne__r.DM_User_gne__r.LastName, AP_Account_Planning_gne__r.DM_User_gne__r.name WHERE AP_Account_Planning_gne__r.status_gne__c = \''+ARCHIVED_AP_STATUS+'\'' + advancedReferencedParameters+' )';
						
						
				List<List<SObject>> objects = search.query(queryString);
				Set<Id> resultIds = new Set<Id>();
				for(Integer i = 0; i < objects.size(); i++){
					for(SObject ob : objects[i]){
						if(!resultIds.contains((Id)ob.get('AP_Account_Planning_gne__c'))){
							plans.add((AP_Account_Planning_gne__c)ob.getSobject('AP_Account_Planning_gne__r'));
							resultIds.add((Id)ob.get('AP_Account_Planning_gne__c'));
						}
					}
				}
				plans = subset(plans, 0, MAX_RECORD_COUNT);
			}
			return null;
		}catch(Exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.GNE_FCR_Search_Text_Validation));
			system.debug(logginglevel.error, e.getMessage());
			return null;
		}
	}
	
	
	private List<AP_Account_Planning_gne__c> subset(List<AP_Account_Planning_gne__c> list1, Integer startIndex, Integer recordCount) {
        List<AP_Account_Planning_gne__c> returnList = new List<AP_Account_Planning_gne__c>();
        if(list1 != null && list1.size() > 0 && startIndex >= 0 && startIndex <= list1.size()-1 && recordCount > 0){
            for(Integer i = startIndex; i < list1.size() && i - startIndex < recordCount; i++){
                returnList.add(list1.get(i));
            }
        }
        return returnList;
    }
	
	private Boolean isQueryInputValid(String input){
		system.debug(input);
		input = input.replaceAll('\\*','\\\\*');
		system.debug(input);
		input = String.escapeSingleQuotes(input);
		if(String.isBlank(input) || input.length()<2){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.GNE_FCR_Search_Text_Validation));
			return false;
		}else{
			return true;
		}
	}
	
	private void parseDates(){
		dFrom = null;
		dTo=null;
		if(!String.isBlank(dateFrom)){
			dFrom = Date.parse(dateFrom);
		}
		if(!String.isBlank(dateTo)){
			dTo = Date.parse(dateTo);
		}
	}
	
	private Boolean areDatesValid(){
		if((!String.isBlank(dateFrom) && !GNE_FCR_Util.isDateStringValid(dateFrom)) || (!String.isBlank(dateTo) && !GNE_FCR_Util.isDateStringValid(dateTo))){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.GNE_FCR_Date_Format_Validation));
			return false;
		}
		parseDates();
		if(dFrom!=null && dTo!=null && dFrom > dTo){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.GNE_FCR_Dates_Validation));
			return false;
		}
		return true;
	}
	
	private void prepareQueryParameters(){
		advancedParameters ='';
		advancedReferencedParameters ='';
		if(isAdvancedSearch){
			if(pickedFEs != null && !pickedFEs.isEmpty()){
				advancedParameters+= ' AND CS_User_gne__c IN :pickedFEs';
				advancedReferencedParameters+=' AND AP_Account_Planning_gne__r.CS_User_gne__c IN :pickedFEs';
			}
			if(pickedFRs!=null && !pickedFRs.isEmpty()){
				advancedParameters+= ' AND DM_User_gne__c IN :pickedFRs';
				advancedReferencedParameters+=' AND AP_Account_Planning_gne__r.DM_User_gne__c IN :pickedFRs';
			}
			if(dFrom!=null){
				advancedParameters+= ' AND Date_Approved_gne__c >= :dFrom';
				advancedReferencedParameters+=' AND AP_Account_Planning_gne__r.Date_Approved_gne__c >= :dFrom';
			}
			if(dTo!=null){
				advancedParameters+= ' AND Date_Approved_gne__c <= :dTo';
				advancedReferencedParameters+=' AND AP_Account_Planning_gne__r.Date_Approved_gne__c <= :dTo';
			}
		}
	}
	
	public List<SelectOption> getAvailableFRs(){
		List<SelectOption> frs = new List<SelectOption>();
		for(User u: GNE_FCR_DAO.getAvailableFRs(UserInfo.getUserId())){
			frs.add(new SelectOption(u.id, u.name));
		}
		return frs;
	}
	
	public List<SelectOption> getAvailableFEs(){
		List<SelectOption> results = new List<SelectOption>();
		Set<Id> distinctUsers = new Set<Id>();
		for(List<AP_Account_Planning_gne__c> plans : [SELECT CS_user_gne__r.Name, CS_user_gne__c FROM AP_Account_Planning_gne__c WHERE CS_user_gne__c!=null ORDER BY CS_user_gne__r.Name ASC LIMIT 999]){
			for(AP_Account_Planning_gne__c plan : plans){
				if(!distinctUsers.contains(plan.CS_user_gne__c)){
					distinctUsers.add(plan.CS_user_gne__c);
					results.add(new SelectOption(plan.CS_user_gne__c, plan.CS_user_gne__r.name));
				}
			}
		}
		return results;
	}
}