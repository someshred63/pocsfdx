@RestResource(urlMapping='/iPhoneGetSurveys/*')
global with sharing class iPhone_Get_Surveys_gne {
	
	@HttpPost 
    global static iPhone_Commons_gne.RestResponse processRequest(List<String> surveyIds) {
        
        return iPhone_Commons_gne.buildResponse(
                new SurveyResponseBuilder(surveyIds), null
        );                              
    }
    
    class SurveyResponseBuilder implements iPhone_Commons_gne.ResponseBuilder{
    	List<String> surveyIds;
    	
		public SurveyResponseBuilder(List<String> surveyIds){
			this.surveyIds = surveyIds;
		}
		
    	public iPhone_Commons_gne.RestResponse build(Object args){
	    	List<Survey> surveys = new List<Survey>();
	    	for(GNE_MCCO_CRM_Survey__c surveyRec : getMccoSurveys(surveyIds)){
	    		surveys.add(new Survey(surveyRec));
	    	}
		    return new SurveyRecordsResponse(surveys);
    	}
    } 
    
    public class SurveyRecordsResponse extends iPhone_Commons_gne.RestResponse{
    	public final List<Survey> surveys;
        
        public SurveyRecordsResponse(List<Survey> surveys) {
            this.surveys = surveys;
        }
    }
    
    class Survey extends iPhone_Commons_gne.RestRecord {
        public String no;   // GNE_MCCO_CRM_Survey__c.Notification_gne__c	
        public String st;  // GNE_MCCO_CRM_Survey__c.Status_gne__c
        public String ti;   // GNE_MCCO_CRM_Survey__c.Title_gne__c	
        public List<SurveyGroup> groups;  // GNE_MCCO_CRM_Survey__c.Survey_Sections
        public List<SurveyQuestion> questions;  // GNE_MCCO_CRM_Survey__c.Survey_Questions
        
        public Survey(GNE_MCCO_CRM_Survey__c survey){
        	this.id = survey.id;
        	this.no = survey.Notification_gne__c;
        	this.st = survey.Status_gne__c;
        	this.ti = survey.Title_gne__c;
        	
        	groups = new List<SurveyGroup>();
        	questions = new List<SurveyQuestion>();
        	
        	for(GNE_MCCO_CRM_Survey_Group__c gr : survey.Survey_Sections__r){
        		groups.add(new SurveyGroup(gr));
        	}
        	
        	 for(GNE_MCCO_CRM_Survey_Question__c gr : survey.Survey_Questions__r){
        		questions.add(new SurveyQuestion(gr));
        	}
        }
            	
    }
    
    class SurveyGroup extends iPhone_Commons_gne.RestRecord {
        public String sid;   // GNE_MCCO_CRM_Survey_Group__c.Survey_gne__c
        public String od;   // GNE_MCCO_CRM_Survey_Group__c.Order_gne__c
        public String ti;  // GNE_MCCO_CRM_Survey_Group__c.Title_gne__c
        
        public SurveyGroup(GNE_MCCO_CRM_Survey_Group__c gr){
        	this.id = gr.id;
        	this.sid = gr.Survey_gne__c;
        	this.od = iPhone_StringUtil.getString(gr.Order_gne__c);
        	this.ti = gr.Title_gne__c;
        }
    }
    
    class SurveyQuestion extends iPhone_Commons_gne.RestRecord {
        public String cht;   // GNE_MCCO_CRM_Survey_Question__c.Conditional_Help_Text_gne__c
        public String gr;   // GNE_MCCO_CRM_Survey_Question__c.Group_gne__c
        public String ht;  // GNE_MCCO_CRM_Survey_Question__c.Help_Text_gne__c
        
        public String sid;   // GNE_MCCO_CRM_Survey_Question__c.Survey_gne__c
        public String od;   // GNE_MCCO_CRM_Survey_Question__c.Order_gne__c
        public String re;  // GNE_MCCO_CRM_Survey_Question__c.Required_gne__c
        public String qu;   // GNE_MCCO_CRM_Survey_Question__c.Question_gne__c
        public String ty;   // GNE_MCCO_CRM_Survey_Question__c.Type_gne__c
        public String va;  // GNE_MCCO_CRM_Survey_Question__c.Values_gne__c 
        
        public SurveyQuestion(GNE_MCCO_CRM_Survey_Question__c question){
        	this.id = question.id;
        	this.cht = question.Conditional_Help_Text_gne__c;
        	this.gr = question.Group_gne__c;
        	this.ht = question.Help_Text_gne__c;
        	this.sid = question.Survey_gne__c;
        	this.od = iPhone_StringUtil.getString(question.Order_gne__c);
        	this.re = iPhone_StringUtil.getString(question.Required_gne__c);
        	this.qu = question.Question_gne__c;
        	this.ty = question.Type_gne__c;
        	this.va = question.Values_gne__c;
        }
    }
    
    public static List<GNE_MCCO_CRM_Survey__c>getMccoSurveys(List<Id>surveyIds){    	
    	return [SELECT (SELECT CreatedById, CreatedDate, Name, LastModifiedById, LastModifiedDate, Survey_gne__c, Order_gne__c, Id, Region_Code_gne__c, Title_gne__c FROM  Survey_Sections__r),
    					(SELECT Conditional_Help_Text_gne__c, Group_gne__c, Help_Text_gne__c, Order_gne__c, Id, Required_gne__c, Name, Question_gne__c, Type_gne__c, Values_gne__c, Survey_gne__c from Survey_Questions__r),
    					Close_Survey_gne__c, CreatedById, CreatedDate, Id, LastModifiedById, LastModifiedDate, Name, Notification_gne__c, Ready_To_Use_gne__c, Record_Type_gne__c, Requested_By_gne__c, Status_gne__c,Title_gne__c 
    					FROM GNE_MCCO_CRM_Survey__c WHERE id in :surveyIds]; 
    }
}