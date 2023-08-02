public without sharing class GNE_FCR_Search_Controller {

	private static final String ARCHIVED_STATUS = GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_ARCHIVED_STATUS);
	private static final String FORM_COMPLETED_STATUS = 'Form Complete';

	public Id dayPlanId {get; set;}
	public String sInputValue {get; set;}
	public List<FCR_Days_Plan_gne__c> fcrs {get;set;}
	public Boolean isAdvancedSearch {get;set;}
	public String dateFrom {get;set;}
	public String dateTo {get;set;}
	public List<String> pickedFRs {get;set;}
	public List<String> pickedFEs {get;set;}
	private String advancedParameters {get; set;}
	private String advancedReferencedParameters {get; set;}
	private Date dFrom {get; set;}
	private Date dTo {get; set;}

	public GNE_FCR_Search_Controller(){
		fcrs = new List<FCR_Days_Plan_gne__c>();
	}

	public void setLastVisitedPage() {
		GNE_FCR_Navigation_Controller.setLastVisitedPage();		
	}
	
	public PageReference simpleSearch(){
		try{
			if((!isAdvancedSearch && isQueryInputValid(sInputValue)) || (isQueryInputValid(sInputValue) && areDatesValid())){
				prepareQueryParameters();
				String input = '*'+sInputValue+'*';
				String queryString = 'FIND \'( '+input+' )\' IN ALL FIELDS RETURNING FCR_Days_Plan_gne__c(Territory_Name_gne__c, DM_User_Name_gne__c, DM_Action_Plan__c, DM_Comments_gne__c,Field_Objectives_gne__c,GPM_Objective_Comments_gne__c, CS_user_gne__r.name, CS_user_gne__r.FirstName, CS_user_gne__r.LastName, Date_Field_Visit_gne__c,FR_User_gne__c, FR_User_gne__r.FirstName,status_gne__c, FR_User_gne__r.LastName WHERE ((Version_gne__c = 2 AND Status_gne__c = :ARCHIVED_STATUS) OR (Version_gne__c = 1 AND Status_gne__c = :FORM_COMPLETED_STATUS)) '+advancedParameters+' ORDER BY Date_Field_Visit_gne__c DESC)'
				+', FCR_DaysPlan_Job_Competency_gne__c (Assess_Comments_gne__c, Clarify_Comments_gne__c, Execute_Comments_gne__c,FCR_Days_Plan_gne__c,FCR_Days_Plan_gne__r.CS_User_gne__r.name,FCR_Days_Plan_gne__r.CS_user_gne__r.FirstName,FCR_Days_Plan_gne__r.CS_user_gne__r.LastName ,FCR_Days_Plan_gne__r.DM_User_Name_gne__c,FCR_Days_Plan_gne__r.Date_Field_Visit_gne__c,FCR_Days_Plan_gne__r.FR_User_gne__c, FCR_Days_Plan_gne__r.FR_User_gne__r.FirstName, FCR_Days_Plan_gne__r.FR_User_gne__r.LastName,FCR_Days_Plan_gne__r.status_gne__c, FCR_Days_Plan_gne__r.Territory_Name_gne__c WHERE ((FCR_Days_Plan_gne__r.Version_gne__c = 2 AND FCR_Days_Plan_gne__r.Status_gne__c = :ARCHIVED_STATUS) OR (FCR_Days_Plan_gne__r.Version_gne__c = 1 AND FCR_Days_Plan_gne__r.Status_gne__c = :FORM_COMPLETED_STATUS)) '+advancedReferencedParameters+')'
				+', FCR_Action_Plan_gne__c (Description_gne__c ,FCR_Days_Plan_gne__c,FCR_Days_Plan_gne__r.CS_User_gne__r.name,FCR_Days_Plan_gne__r.CS_user_gne__r.FirstName,FCR_Days_Plan_gne__r.CS_user_gne__r.LastName ,FCR_Days_Plan_gne__r.DM_User_Name_gne__c,FCR_Days_Plan_gne__r.Date_Field_Visit_gne__c,FCR_Days_Plan_gne__r.FR_User_gne__c, FCR_Days_Plan_gne__r.FR_User_gne__r.FirstName, FCR_Days_Plan_gne__r.FR_User_gne__r.LastName, FCR_Days_Plan_gne__r.Territory_Name_gne__c WHERE ((FCR_Days_Plan_gne__r.Version_gne__c = 2 AND FCR_Days_Plan_gne__r.Status_gne__c = :ARCHIVED_STATUS) OR (FCR_Days_Plan_gne__r.Version_gne__c = 1 AND FCR_Days_Plan_gne__r.Status_gne__c = :FORM_COMPLETED_STATUS)) '+advancedReferencedParameters+')'
				+', FCR_Days_Objective_gne__c (Objective_gne__c ,FCR_Days_Plan_gne__c,FCR_Days_Plan_gne__r.CS_User_gne__r.name,FCR_Days_Plan_gne__r.CS_user_gne__r.FirstName,FCR_Days_Plan_gne__r.CS_user_gne__r.LastName ,FCR_Days_Plan_gne__r.DM_User_Name_gne__c,FCR_Days_Plan_gne__r.Date_Field_Visit_gne__c,FCR_Days_Plan_gne__r.FR_User_gne__c, FCR_Days_Plan_gne__r.FR_User_gne__r.FirstName, FCR_Days_Plan_gne__r.FR_User_gne__r.LastName, FCR_Days_Plan_gne__r.Territory_Name_gne__c WHERE ((FCR_Days_Plan_gne__r.Version_gne__c = 2 AND FCR_Days_Plan_gne__r.Status_gne__c = :ARCHIVED_STATUS) OR (FCR_Days_Plan_gne__r.Version_gne__c = 1 AND FCR_Days_Plan_gne__r.Status_gne__c = :FORM_COMPLETED_STATUS)) '+advancedReferencedParameters+')';
				List<List<SObject>> objects = search.query(queryString);
				fcrs = ((List<FCR_Days_Plan_gne__c>)objects[0]);
				Set<Id> resultIds = new Set<Id> (new Map<Id, FCR_Days_Plan_gne__c>(fcrs).keySet());
				for(Integer i = 1; i < objects.size(); i++){
					for(SObject ob : objects[i]){
						if(!resultIds.contains((Id)ob.get('FCR_Days_Plan_gne__c'))){
							fcrs.add((FCR_Days_Plan_gne__c)ob.getSobject('FCR_Days_Plan_gne__r'));
							resultIds.add((Id)ob.get('FCR_Days_Plan_gne__c'));
						}
					}
				}
				fcrs = subset(fcrs, 0, GNE_FCR_History_Controller.MAX_RECORD_COUNT);
			}
			return null;
		}catch(Exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.GNE_FCR_Search_Text_Validation));
			system.debug(logginglevel.error, e.getMessage());
			return null;
		}
	}
	
	
	private List<FCR_Days_Plan_gne__c> subset(List<FCR_Days_Plan_gne__c> list1, Integer startIndex, Integer recordCount) {
        List<FCR_Days_Plan_gne__c> returnList = new List<FCR_Days_Plan_gne__c>();
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
				advancedReferencedParameters+=' AND FCR_Days_Plan_gne__r.CS_User_gne__c IN :pickedFEs';
			}
			if(pickedFRs!=null && !pickedFRs.isEmpty()){
				advancedParameters+= ' AND FR_User_gne__c IN :pickedFRs';
				advancedReferencedParameters+=' AND FCR_Days_Plan_gne__r.FR_User_gne__c IN :pickedFRs';
			}
			if(dFrom!=null){
				advancedParameters+= ' AND Date_Field_Visit_gne__c >= :dFrom';
				advancedReferencedParameters+=' AND FCR_Days_Plan_gne__r.Date_Field_Visit_gne__c >= :dFrom';
			}
			if(dTo!=null){
				advancedParameters+= ' AND Date_Field_Visit_gne__c <= :dTo';
				advancedReferencedParameters+=' AND FCR_Days_Plan_gne__r.Date_Field_Visit_gne__c <= :dTo';
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
		for(List<FCR_Days_Plan_gne__c> fcrs : [SELECT CS_user_gne__r.name, CS_user_gne__c FROM FCR_Days_Plan_gne__c WHERE CS_user_gne__c!=null ORDER BY Createddate DESC LIMIT 999]){
			for(FCR_Days_Plan_gne__c fcr : fcrs){
				if(!distinctUsers.contains(fcr.CS_user_gne__c)){
					distinctUsers.add(fcr.CS_user_gne__c);
					results.add(new SelectOption(fcr.CS_user_gne__c, fcr.CS_user_gne__r.name));
				}
			}
		}
		return results;
	}
}