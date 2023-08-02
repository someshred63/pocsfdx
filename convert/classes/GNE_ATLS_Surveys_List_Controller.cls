public class GNE_ATLS_Surveys_List_Controller{

    public List<Account_Surveys> SurveysList { get; set;}
    public List<Survey_gne__c> SurveysListTmp { get; set;}

    public String AccName { get; set;}
    public String product_name { get; set;}
    public ID delId {get;set;}
    
    private SFA2_Configuration_Object_gne__c pageConfiguration;
    
    private String sortDirection = 'DESC';
    private String sortExp = 'CreatedDate';
    private String userId = UserInfo.getUserId();
    
    //temp
    public String userIdToViewLink {get;set;}
    
    public GNE_ATLS_Surveys_List_Controller(){
    	pageConfiguration = GNE_SFA2_Util.getListPageConfiguration('Survey_gne__c');
        SurveysList = new List<Account_Surveys>();
        SurveysListTmp = [Select s.Account__r.Name,s.Account__r.Id,s.Account__c,s.Questionnaire_gne__r.Name, s.Total_score_gne__c, s.Account_Name_gne__c,
                    s.Questionnaire_gne__c,s.Questionnaire_gne__r.Product_gne__r.Name,s.CreatedDate, s.id, s.Title_gne__c, s.Name, createdbyid, createdby.Name,lastmodifiedby.Name,
                    s.Product_Metrics_vod__r.Account_vod__c,s.Product_Metrics_vod__r.Account_vod__r.Id,s.Product_Metrics_vod__r.Account_vod__r.Name 
                    from Survey_gne__c s 
                    where s.createdbyid=:UserInfo.getUserId() or (s.lastmodifiedbyid=:UserInfo.getUserId() and s.createdby.profile_name_gne__c like 'GNE-TLS%') order by s.CreatedDate desc];
                     
        for(Survey_gne__c survey:SurveysListTmp)
        {
            Account_Surveys acctSurvey = new Account_Surveys();
            acctSurvey.Survey_Name = survey.Name;
            acctSurvey.Survey_Title= survey.Title_gne__c;
            acctSurvey.Survey_ID = survey.ID;
            acctSurvey.Questionnaire = survey.Questionnaire_gne__r.Name;
            acctSurvey.QuestionnaireID = survey.Questionnaire_gne__c;
            acctSurvey.Product = survey.Questionnaire_gne__r.Product_gne__r.Name;
            acctSurvey.Survey_Created_Date = survey.CreatedDate.format('EEE, d MMM yyyy');
            acctSurvey.Survey_Created_By = survey.createdby.Name;
            acctSurvey.Survey_Created_By_Id = survey.createdbyid;
            acctSurvey.Survey_Modified_By = survey.lastmodifiedby.Name;
            acctSurvey.Total_Score = survey.Total_score_gne__c;
            acctSurvey.Account_Name = survey.Account_Name_gne__c;
            if(survey.Account__c != null)
            {
                acctSurvey.Account_Id = survey.Account__r.ID;
            }
            else
            {
                acctSurvey.Account_Id = survey.Product_Metrics_vod__r.Account_vod__r.ID;
            }
            SurveysList.add(acctSurvey);
        }
    }
    public PageReference DelSurvey(){
        Id survey_id = System.currentPageReference().getParameters().get('survey_id');
        Survey_gne__c[] e = [select id from Survey_gne__c where id = :survey_id];
        delete e; 
        SurveysList = new List<Account_Surveys>();
        SurveysListTmp = [Select s.Account__r.Name,s.Account__r.Id,s.Account__c,s.Questionnaire_gne__r.Name, s.Total_score_gne__c, s.Account_Name_gne__c,
                    s.Questionnaire_gne__c,s.Questionnaire_gne__r.Product_gne__r.Name,s.CreatedDate, s.id, s.Title_gne__c, s.Name,createdby.Name,lastmodifiedby.Name,
                    s.Product_Metrics_vod__r.Account_vod__c,s.Product_Metrics_vod__r.Account_vod__r.Id,s.Product_Metrics_vod__r.Account_vod__r.Name 
                    from Survey_gne__c s 
                    where s.createdbyid=:UserInfo.getUserId() or s.lastmodifiedbyid=:UserInfo.getUserId() order by s.CreatedDate desc];
                    
        for(Survey_gne__c survey:SurveysListTmp)
        {
            Account_Surveys acctSurvey = new Account_Surveys();
            acctSurvey.Survey_Name = survey.Name;
            acctSurvey.Survey_Title= survey.Title_gne__c;
            acctSurvey.Survey_ID = survey.ID;
            acctSurvey.Questionnaire = survey.Questionnaire_gne__r.Name;
            acctSurvey.QuestionnaireID = survey.Questionnaire_gne__c;
            acctSurvey.Product = survey.Questionnaire_gne__r.Product_gne__r.Name;
            acctSurvey.Survey_Created_Date = survey.CreatedDate.format('EEE, d MMM yyyy');
            acctSurvey.Survey_Created_By = survey.createdby.Name;
            acctSurvey.Survey_Created_By_Id = survey.createdbyid;
            acctSurvey.Survey_Modified_By = survey.lastmodifiedby.Name;
            acctSurvey.Total_Score = survey.Total_score_gne__c;
            acctSurvey.Account_Name = survey.Account_Name_gne__c;
            if(survey.Account__c != null)
            {
                acctSurvey.Account_Id = survey.Account__r.ID;
            }
            else
            {
                acctSurvey.Account_Id = survey.Product_Metrics_vod__r.Account_vod__r.ID;
            }
            SurveysList.add(acctSurvey);
        }     
        return null;
    }
    
    public PageReference ViewData() {
        //build the full sort expression
        string sortFullExp = sortExpression  + ' ' + sortDirection;
        
        SurveysList = new List<Account_Surveys>();
        SurveysListTmp = DataBase.query('Select s.Account__r.Name,s.Account__r.Id,s.Account__c,s.Questionnaire_gne__r.Name, s.Total_score_gne__c, s.Account_Name_gne__c, '+
                    +'s.Questionnaire_gne__c,s.Questionnaire_gne__r.Product_gne__r.Name,s.CreatedDate, s.id, s.Title_gne__c, s.Name,createdby.Name,lastmodifiedby.Name, '+
                    +'s.Product_Metrics_vod__r.Account_vod__c,s.Product_Metrics_vod__r.Account_vod__r.Id,s.Product_Metrics_vod__r.Account_vod__r.Name '+
                    +'from Survey_gne__c s '+
                    +'where s.createdbyid= \''+userId+'\' or (s.lastmodifiedbyid= \''+userId+'\' '+
                    +'and s.createdby.profile_name_gne__c like \'GNE-TLS%\') order by '+sortFullExp);
                     
        for(Survey_gne__c survey:SurveysListTmp)
        {
            Account_Surveys acctSurvey = new Account_Surveys();
            acctSurvey.Survey_Name = survey.Name;
            acctSurvey.Survey_Title= survey.Title_gne__c;
            acctSurvey.Survey_ID = survey.ID;
            acctSurvey.Questionnaire = survey.Questionnaire_gne__r.Name;
            acctSurvey.QuestionnaireID = survey.Questionnaire_gne__c;
            acctSurvey.Product = survey.Questionnaire_gne__r.Product_gne__r.Name;
            acctSurvey.Survey_Created_Date = survey.CreatedDate.format('EEE, d MMM yyyy');
            acctSurvey.Survey_Created_By = survey.createdby.Name;
            acctSurvey.Survey_Created_By_Id = survey.createdbyid;
            acctSurvey.Survey_Modified_By = survey.lastmodifiedby.Name;
            acctSurvey.Total_Score = survey.Total_score_gne__c;
            acctSurvey.Account_Name = survey.Account_Name_gne__c;
            if(survey.Account__c != null)
            {
                acctSurvey.Account_Id = survey.Account__r.ID;
            }
            else
            {
                acctSurvey.Account_Id = survey.Product_Metrics_vod__r.Account_vod__r.ID;
            }
            SurveysList.add(acctSurvey);
        }
        return null;
    }

    public String sortExpression
    {
        get
        {
            return sortExp;
        }
        set
        {
            //if the column is clicked on then switch between Ascending and Descending modes
            if (value == sortExp)
            sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            else
            sortDirection = 'ASC';
            sortExp = value;
        }
    }

    public String getSortDirection()
    {
        //if not column is selected 
        if (sortExpression == null || sortExpression == '')
        return 'ASC';
        else
        return sortDirection;
    }

    public void setSortDirection(String value)
    {  
        sortDirection = value;
    }
    
    class Account_Surveys
    {
        public String Survey_Name { get; set;}
        public String Survey_Title{ get; set;}
        public ID Survey_ID{ get; set;}
        public String Account_Id { get; set;}
        public String Account_Name { get; set;}
        public String Questionnaire{ get; set;}
        public String QuestionnaireID{ get; set;}
        public String Product{ get; set;}
        public String Survey_Created_Date{ get; set;}
        public String Survey_Created_By{ get; set;}
        public String Survey_Created_By_Id{ get; set;}
        public String Survey_Modified_By{ get; set;}
        public Decimal Total_Score{ get; set;}
    }
    
    public PageReference overrideUserViewLink() {
        PageReference pageref = new PageReference('/apex/GNE_SFA2_User_Layout?Id=' + userIdToViewLink);
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