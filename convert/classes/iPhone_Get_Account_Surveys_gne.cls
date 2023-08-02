/******************************************************************************************
*  @author: Jakub Lewandowski, Roche
*  Created: 2013-08-20
*  Project: OTR2
*  Description: REST Webservice, returns a list of Surveys for the specified accounts.             
*******************************************************************************************/
@RestResource(urlMapping='/iPhoneGetAccountSurveys/*')
global with sharing class iPhone_Get_Account_Surveys_gne {
    
    @HttpPost 
    global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, String unixId, List<String> accountIds, List<String> brandAffiliationIds) {       
        return iPhone_Commons_gne.buildResponse(
                new GetAccountSurveysResponseBuilder(), 
                new iPhone_Commons_gne.DefaultDeltaArgs(
                                        lastSyncDate, unixId, accountIds, brandAffiliationIds
            )
        );        
    } 
              
    class GetAccountSurveysResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder { 
                                                        
        protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
            if(args.brandAffiliationIds != null){
                return iPhone_DAO.getSurveysByBrandAffiliationIds(args.brandAffiliationIds);
            }
            else{
                return iPhone_DAO.getSurveysByAccountIds(args.accountIds);
            }
        }    
                            
        protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
            return new GetAccountSurveysRecord((Survey_gne__c)sObj);
        }
    }  
     
    class GetAccountSurveysRecord extends iPhone_Commons_gne.DeltaRecord {  
        public String na;   // Survey_gne__c.Name
        public String ti;   // Survey_gne__c.Title_gne__c
        public String ts;   // Survey_gne__c.Total_Score_gne__c
        public String qid;  // Survey_gne__c.Questionnaire_gne__c
        public String cb;   // Survey_gne__c.CreatedBy.Name
        public String aid;  // Survey_gne__c.Account__c
        public String md;   // Survey_gne__c.LastModifiedDate
        public String cd;   // Survey_gne__c.CreatedDate
        public String bid;  // Survey_gne__c.Product_Metrics_vod__c
        public String rid;  // Survey_gne__c.iPhone_Request_Id_gne__c
        public String st;	// Survey_gne__c.Survey_Status_gne__c
        public String ow;	// Survey_gne__c.OwnerId
         
        public GetAccountSurveysRecord(Survey_gne__c survey) {
            id  = survey.Id;
            na  = survey.Name;
            ti  = iPhone_StringUtil.getString(survey.Title_gne__c);
            ts  = iPhone_StringUtil.getString(survey.Total_Score_gne__c);
            qid = survey.Questionnaire_gne__c;
            cb  = survey.CreatedBy.Name;
            aid = survey.Account__c;
            md  = iPhone_StringUtil.getString(survey.LastModifiedDate);
            cd  = iPhone_StringUtil.getString(survey.CreatedDate);
            bid = survey.Product_Metrics_vod__c;
            rid = iPhone_StringUtil.getString(survey.iphone_request_id_gne__c);
            st  = iPhone_StringUtil.getString(survey.Survey_Status_gne__c);
            ow  = iPhone_StringUtil.getString(survey.OwnerId);
        }
    }
}