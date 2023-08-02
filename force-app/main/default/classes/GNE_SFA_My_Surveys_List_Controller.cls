public class GNE_SFA_My_Surveys_List_Controller {

    public List<Survey_gne__c> SurveysListTmp { get; set; }
    public List<SurveyWrapper> surveysList { get; set; }

    public String AccName { get; set; }
    public String product_name { get; set; }
    public ID delId { get; set; }
    
    private String sortDirection = 'DESC';
    private String sortExp = 'LastModifiedDate';
    private String userId = UserInfo.getUserId();
    
    public GNE_SFA_My_Surveys_List_Controller(){
        getSurveyList();
    }
    
    private void wrapSurveys(List<Survey_gne__c> surveys) {
    	 surveysList = new List<SurveyWrapper>();
    	 for(Survey_gne__c survey : surveys) {
    	 	SurveyWrapper s = new SurveyWrapper();
    	 	s.Id = survey.Id;
    	 	s.Name = survey.Name;
    	 	s.Account_Name = survey.Account__r.Name;
    	 	s.Status = survey.Survey_Status_gne__c;
    	 	s.LastModifiedDate = survey.LastModifiedDate;
    	 	if(survey.Account__c != null) {
                s.Account_Id = survey.Account__r.ID;
            }
            else {
                s.Account_Id = survey.Product_Metrics_vod__r.Account_vod__r.ID;
            }
    	 	surveysList.add(s);
    	 }
    }
    
    private void getSurveyList() {
        
        SurveysListTmp = DataBase.query('Select s.Account__r.Name,s.Account__r.Id,s.Account__c,s.Questionnaire_gne__r.Name, s.Total_score_gne__c, s.Account_Name_gne__c, '+
                    +'s.Questionnaire_gne__c,s.Questionnaire_gne__r.Product_gne__r.Name,s.CreatedDate, s.id, s.Title_gne__c, s.Name,createdby.Name,lastmodifiedby.Name, '+
                    +'s.Survey_Status_gne__c, Survey_gne__c.LastModifiedDate, s.Product_Metrics_vod__r.Account_vod__c,s.Product_Metrics_vod__r.Account_vod__r.Id,s.Product_Metrics_vod__r.Account_vod__r.Name '+
                    +'from Survey_gne__c s '+
                    +'where s.createdbyid= \''+userId+'\' or (s.lastmodifiedbyid= \''+userId+'\' '+
                    +'and s.createdby.profile_name_gne__c like \'GNE-SFA%\') order by s.LastModifiedDate desc');
        
        wrapSurveys(SurveysListTmp);   
    }
    
    public PageReference DelSurvey() {
        Id survey_id = System.currentPageReference().getParameters().get('survey_id');
        Survey_gne__c[] e = [select id from Survey_gne__c where id = :survey_id];
        delete e; 
        getSurveyList();
        SuperSort.sortList(surveysList, sortExpression, sortDirection);  
           
        return null;
    }
    
    public PageReference ViewData() {
        SuperSort.sortList(surveysList, sortExpression, sortDirection);

        return null;
    }

    public String sortExpression {
        get {
            return sortExp;
        }
        set {
            //if the column is clicked on then switch between Ascending and Descending modes
            if (value == sortExp)
            sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            else
            sortDirection = 'ASC';
            sortExp = value;
        }
    }

    public String getSortDirection() {
        //if not column is selected 
        if (sortExpression == null || sortExpression == '')
        return 'ASC';
        else
        return sortDirection;
    }

    public void setSortDirection(String value) {  
        sortDirection = value;
    }

    public class SurveyWrapper implements IReflection {
    	public String Id { get; set;}
    	public String Name { get; set;}
    	public String Account_Name { get; set;}
    	public String Account_Id { get; set;}
    	public String Status { get; set;}
    	public Datetime LastModifiedDate { get; set;}
    	
    	public object getValue(String name) {
    		if(name == 'Id') {
    			return Id;	
    		} else if(name == 'Name') {
    			return Name;	
    		} else if(name == 'Account_Name') {
    			return Account_Name;	
    		} else if(name == 'Account_Id') {
    			return Account_Id;	
    		} else if(name == 'Status') {
    			return Status;	
    		} else if(name == 'LastModifiedDate') {
    			return LastModifiedDate;	
    		}
    		
    		return null;
    	}
    }
}