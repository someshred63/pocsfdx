public class GNE_SFA2_My_Surveys_Controller {

    //temp
    public String sortField {get; set;}
    private String oldSortField {get; set;}
    public String sortDirection {get; set;}
    private SFA2_Configuration_Object_gne__c pageConfiguration;

    public GNE_SFA2_My_Surveys_Controller() {
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
        String query = 'SELECT Id, Name, Account__c, Account__r.Name, Survey_Status_gne__c, LastModifiedDate FROM Survey_gne__c WHERE CreatedById = \'' + UserInfo.getUserId() + '\' ORDER BY ' + sortField + ' ' + sortDirection  + '';
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