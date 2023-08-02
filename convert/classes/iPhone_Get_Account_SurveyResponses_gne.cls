/******************************************************************************************
*  @author: Jakub Lewandowski, Roche
*  Created: 2013-08-21
*  Project: OTR2
*  Description: REST Webservice, returns a list of Survey responses for the specified accounts.             
*******************************************************************************************/
@RestResource(urlMapping='/iPhoneGetAccountSurveyResponses/*')
global with sharing class iPhone_Get_Account_SurveyResponses_gne {
	
	@HttpPost 
    global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, String unixId, List<String> accountIds, List<String> brandAffiliationIds) {    	
    	return iPhone_Commons_gne.buildResponse(
	    		new GetAccountSurveyResponsesResponseBuilder(), 
	    		new iPhone_Commons_gne.DefaultDeltaArgs(
	    							   	lastSyncDate, unixId, accountIds, brandAffiliationIds
    		)
    	);     	  
    } 
              
    class GetAccountSurveyResponsesResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder { 
    													
    	protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
    		
    		if(args.brandAffiliationIds != null){
    			return iPhone_DAO.getSurveyResponsesByBrandAffiliationIds(args.brandAffiliationIds);
    		}
    		else{
    			return iPhone_DAO.getSurveyResponsesByAccountIds(args.accountIds);
    		}
    	} 	 
    	     	 			
    	protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
    		return new GetAccountSurveyResponsesRecord((Survey_Response_gne__c)sObj);
    	}
    }  
     
    class GetAccountSurveyResponsesRecord extends iPhone_Commons_gne.DeltaRecord {	
		public String ft;	// Survey_Response_gne__c.Free_Text_gne__c
		public String ht;	// Survey_Response_gne__c.Help_Text_gne__c
		public String la;	// Survey_Response_gne__c.Labels_gne__c
		public String mas;	// Survey_Response_gne__c.Maximum_Score_gne__c
		public String mis;	// Survey_Response_gne__c.Minimum_Score_gne__c
		public String pos;	// Survey_Response_gne__c.Position_gne__c
		public String qid;	// Survey_Response_gne__c.Question_gne__c
		public String rs;	// Survey_Response_gne__c.Response_Score_gne__c
		public String cat;	// Survey_Response_gne__c.Category_gne__c
		public String sl;	// Survey_Response_gne__c.Selected_Label_gne__c
		public String sv;	// Survey_Response_gne__c.Selected_Values_gne__c
		public String sid;	// Survey_Response_gne__c.Survey_gne__c
		public String ti;	// Survey_Response_gne__c.Title_gne__c
		public String ty;	// Survey_Response_gne__c.Type_gne__c
		public String va;	// Survey_Response_gne__c.Values_gne__c
		public String cb;	// Survey_Response_gne__c.CreatedBy.Name
		public String md;	// Survey_Response_gne__c.LastModifiedDate
		public String mr;	// Survey_Response_gne__c.Multiple_Responses_gne__c
		public String qt;	// Survey_Response_gne__c.Question_gne__c.Type_gne__c
         
        public GetAccountSurveyResponsesRecord(Survey_Response_gne__c surveyResponse) {
        	id	= surveyResponse.Id;		
			ft	= iPhone_StringUtil.getString(surveyResponse.Free_Text_gne__c);
			//ht	= (surveyResponse.Question_gne__c != null && surveyResponse.Question_gne__r.LastModifiedDate < surveyResponse.CreatedDate) ?  '' : iPhone_StringUtil.getString(surveyResponse.Help_Text_gne__c);
			//la	= (surveyResponse.Question_gne__c != null && surveyResponse.Question_gne__r.LastModifiedDate < surveyResponse.CreatedDate) ?  '' : iPhone_StringUtil.getString(surveyResponse.Labels_gne__c);
			//mas	= (surveyResponse.Question_gne__c != null && surveyResponse.Question_gne__r.LastModifiedDate < surveyResponse.CreatedDate) ?  '' : iPhone_StringUtil.getString(surveyResponse.Maximum_Score_gne__c);
			//mis	= (surveyResponse.Question_gne__c != null && surveyResponse.Question_gne__r.LastModifiedDate < surveyResponse.CreatedDate) ?  '' : iPhone_StringUtil.getString(surveyResponse.Minimum_Score_gne__c);
			//pos	= (surveyResponse.Question_gne__c != null && surveyResponse.Question_gne__r.LastModifiedDate < surveyResponse.CreatedDate) ?  '' : iPhone_StringUtil.getString(surveyResponse.Position_gne__c);
			//qid	= (surveyResponse.Question_gne__c != null && surveyResponse.Question_gne__r.LastModifiedDate < surveyResponse.CreatedDate) ?  surveyResponse.Question_gne__c : null;
			ht	= iPhone_StringUtil.getString(surveyResponse.Help_Text_gne__c);
			la	= iPhone_StringUtil.getString(surveyResponse.Labels_gne__c);
			mas	= iPhone_StringUtil.getString(surveyResponse.Maximum_Score_gne__c);
			mis	= iPhone_StringUtil.getString(surveyResponse.Minimum_Score_gne__c);
			pos	= iPhone_StringUtil.getString(surveyResponse.Position_gne__c);
			qid	= surveyResponse.Question_gne__c;
			rs	= iPhone_StringUtil.getString(surveyResponse.Response_Score_gne__c);
			cat	= iPhone_StringUtil.getString(surveyResponse.Category_gne__c);
			sl	= iPhone_StringUtil.getString(surveyResponse.Selected_Label_gne__c);
			sv	= iPhone_StringUtil.getString(surveyResponse.Selected_Values_gne__c);
			sid	= surveyResponse.Survey_gne__c;
			//ti	= (surveyResponse.Question_gne__c != null && surveyResponse.Question_gne__r.LastModifiedDate < surveyResponse.CreatedDate) ?  '' : iPhone_StringUtil.getString(surveyResponse.Title_gne__c);
			//ty	= (surveyResponse.Question_gne__c != null && surveyResponse.Question_gne__r.LastModifiedDate < surveyResponse.CreatedDate) ?  '' : iPhone_StringUtil.getString(surveyResponse.Type_gne__c);
			//va	= (surveyResponse.Question_gne__c != null && surveyResponse.Question_gne__r.LastModifiedDate < surveyResponse.CreatedDate) ?  '' : iPhone_StringUtil.getString(surveyResponse.Values_gne__c);
			ti	= iPhone_StringUtil.getString(surveyResponse.Title_gne__c);
			ty	= iPhone_StringUtil.getString(surveyResponse.Type_gne__c);
			va	= iPhone_StringUtil.getString(surveyResponse.Values_gne__c);
			cb	= surveyResponse.CreatedBy.Name;
			md	= iPhone_StringUtil.getString(surveyResponse.LastModifiedDate);
			mr	= iPhone_StringUtil.getString(surveyResponse.Multiple_Responses_gne__c);
			qt  = iPhone_StringUtil.getString(surveyResponse.Question_gne__r.Type_gne__c);
        }
	}
}