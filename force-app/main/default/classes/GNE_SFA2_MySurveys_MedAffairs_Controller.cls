public with sharing class GNE_SFA2_MySurveys_MedAffairs_Controller {

    //temp
    public String sortField {get; set;}
    private String oldSortField {get; set;}
    public String sortDirection {get; set;}
    public String surveyId {get;set;}
    public String questionnaireId {get;set;}
    
    private SFA2_Configuration_Object_gne__c pageConfiguration;

    public GNE_SFA2_MySurveys_MedAffairs_Controller () {
        initSortingSettings();
        pageConfiguration = GNE_SFA2_Util.getListPageConfiguration('Survey_gne__c');
    }
    
    private void initSortingSettings() {
        sortField = 'LastModifiedDate';
        oldSortField = sortField;
        sortDirection = 'DESC';
    }
    
    public List<Survey_gne__c> getUserSurveysList() {
        //Prepare query
        String query = 'SELECT Id, Name, Account__c, Account__r.Name, Title_gne__c, Questionnaire_gne__c, Questionnaire_gne__r.Name, Product_Metrics_vod__r.Products_vod__r.Name, LastModifiedDate FROM Survey_gne__c WHERE CreatedById = \'' + UserInfo.getUserId() + '\' ORDER BY ' + sortField + ' ' + sortDirection  + '';
        System.debug(query);
        // Get User Surveys From DB
        List<Survey_gne__c> surveysList = Database.query(query);
        return surveysList; 
    }
    
    public PageReference sortTable() {
        if(sortField == oldSortField){
            if(sortDirection == 'ASC'){
                sortDirection = 'DESC';
            }else{
                sortDirection = 'ASC';
            }
        }else{            
            sortDirection = 'ASC';
            oldSortField = sortField;
        } 
        getUserSurveysList();
        return null;
    }
    
    public PageReference clickDelete() {
        
        Survey_gne__c surveyToDelete = [SELECT Id FROM Survey_gne__c WHERE Id =: surveyId LIMIT 1];
        delete surveyToDelete;
        return null;
    }
    
    public PageReference clickAnalyze() {
    
        PageReference pageref = new PageReference('/apex/GNE_SFA2_SurveyGraph?Id=' + questionnaireId);
        pageref.setredirect(true);
        return pageref; 
    }
    
    public String getListPageName() {
        String result;
        if(pageConfiguration != null) {
            result = pageConfiguration.Section_Header_gne__c;
        } else {
            result = '';
        }
  	 	return result;
  	}
  
  	public String getActiveMenuItem() {
  	 	String result = '';
      	if(pageConfiguration != null && pageConfiguration.Attributes_gne__c!=null && pageConfiguration.Attributes_gne__c.contains('activeMenuItem')){
    	  result = pageConfiguration.Attributes_gne__c.substringBetween('activeMenuItem=',';');
      	}
      	return result;
  	}
}