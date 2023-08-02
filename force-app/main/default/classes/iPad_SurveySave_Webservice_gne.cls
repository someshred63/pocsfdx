global without sharing class iPad_SurveySave_Webservice_gne 
{
    global class Response
    {
        Webservice DateTime StartTime = DateTime.now();
        Webservice DateTime EndTime = null;
        WebService String SyrveyErrorCode;
        WebService String SurveyErrorMessage;
        WebService String ResponseErrorCode;
        WebService String ResponseErrorMessage;
        WebService String SurveyIdAfterProcess;
    }
    global class SurveyResponse
    {
        Webservice String SurveyResponseId;
        Webservice String FreeText;
        Webservice String FullTitle;
        Webservice String HelpText;
        Webservice String Labels;
        Webservice Double MaxScore;
        Webservice Double MinScore;
        Webservice Boolean MultipleResponses;
        Webservice Double Position;
        Webservice String QuestionId;
        Webservice Double ResponseScore;
        Webservice String ResponseCategory;
        Webservice String SelectedLabel;
        Webservice String SelectedValues;
        Webservice String SurveyId;
        Webservice String Title;
        Webservice String ResponseType;
        Webservice String Values;
        Webservice Double Weight;
        Webservice String ResponseId;
    }
    global class Survey
    {
        Webservice String SurveyId;
        Webservice String AccountId;
        Webservice String BrandAffiliationId;
        Webservice String ContactId;
        Webservice Boolean IsATLSSyrvey;
        Webservice String MedicalEventId;
        Webservice String QuestionnaireId;
        Webservice String SpeakerBureauId;
        Webservice String SpeakerBureauMemberId;
        Webservice String SpeakerBureauMembershipId;
        Webservice String SpeakerNominationCategory;
        Webservice String SurveyType;
        Webservice String SurveyVersion;
        Webservice List<SurveyResponse> surveyResponsesList;
    }
    Webservice static Response insertOrUpdateSurvey(Survey srv)
    {
            SavePoint savePoint = Database.setSavePoint();
            Response resp = new Response();
            List<Survey_Response_gne__c> surveyResponses = new List<Survey_Response_gne__c>();
            List<Id> tmpSurveyRespIds = new List<Id>(); 
            Survey_gne__c singleSurvey = new Survey_gne__c();
            system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>srv= '+srv);
            if(srv.SurveyId != '' && srv.SurveyId != null)
            {
                singleSurvey = [Select Id From Survey_gne__c where Id =: srv.SurveyId];
            }
            if(srv.AccountId != '' && srv.AccountId != null)
            {
                singleSurvey.Account__c = srv.AccountId;
            }
            if(srv.ContactId != null && srv.ContactId != '')
            {
                singleSurvey.Contact_gne__c = srv.ContactId;
            }
            singleSurvey.Is_ATLS_Survey_gne__c = srv.IsATLSSyrvey;
            if(srv.MedicalEventId != null && srv.MedicalEventId !='')
            {
                singleSurvey.Medical_Event_gne__c = srv.MedicalEventId;
            }
            if(srv.QuestionnaireId != '' && srv.QuestionnaireId != null)
            {
                singleSurvey.Questionnaire_gne__c = srv.QuestionnaireId;
            }
            if(srv.SpeakerBureauId != null && srv.SpeakerBureauId != '')
            {
                singleSurvey.Speaker_Bureau_gne__c = srv.SpeakerBureauId;
            }
            if(srv.SpeakerBureauMemberId != null && srv.SpeakerBureauMemberId != '')
            {
                singleSurvey.Speaker_Bureau_Member_Name_gne__c = srv.SpeakerBureauMemberId;
            }
            if(srv.SpeakerBureauMembershipId != null && srv.SpeakerBureauMembershipId != '')
            {
                singleSurvey.Speaker_Bureau_Membership_gne__c = srv.SpeakerBureauMembershipId;
            }
            singleSurvey.Speaker_Nomination_Category_gne__c = srv.SpeakerNominationCategory;
            singleSurvey.Type_gne__c = srv.SurveyType;
            Database.Upsertresult surveyUpsert = Database.upsert(singleSurvey);
            Id syrveyUpsertId = surveyUpsert.getId();
            resp.SurveyIdAfterProcess = singleSurvey.Id;
            if(syrveyUpsertId == null)
            {
                Database.rollback ( savePoint );
                Database.Error dbError = surveyUpsert.getErrors()[0];
                resp.SyrveyErrorCode = dbError.getStatusCode().Name();
                resp.SurveyErrorMessage = dbError.getMessage();
            }
            for(SurveyResponse tmpResp : srv.surveyResponsesList)
            {
                if(tmpResp.ResponseId != null && tmpResp.ResponseId != '')
                {
                    tmpSurveyRespIds.add(tmpResp.ResponseId);
                }
            }
            if(tmpSurveyRespIds.size()>0)
            {
                surveyResponses = [Select Id from Survey_Response_gne__c where Id =: tmpSurveyRespIds];
                for(Survey_Response_gne__c srvResp1 : surveyResponses)
                {
                    for(SurveyResponse srvResp2 : srv.surveyResponsesList)
                    {
                        if(srvResp1.Id == srvResp2.ResponseId)
                        {
                            srvResp1.Category_gne__c = srvResp2.ResponseCategory;
                            srvResp1.Free_Text_gne__c = srvResp2.FreeText;
                            srvResp1.Full_Title_gne__c = srvResp2.FullTitle;
                            srvResp1.Help_Text_gne__c = srvResp2.HelpText;
                            srvResp1.Labels_gne__c = srvResp2.Labels;
                            srvResp1.Maximum_Score_gne__c = srvResp2.MaxScore;
                            srvResp1.Minimum_Score_gne__c = srvResp2.MinScore;
                            srvResp1.Multiple_Responses_gne__c = srvResp2.MultipleResponses;
                            srvResp1.Position_gne__c = srvResp2.Position;
                            srvResp1.Question_gne__c = srvResp2.QuestionId;
                            srvResp1.Response_Score_gne__c = srvResp2.ResponseScore;
                            srvResp1.Selected_Label_gne__c = srvResp2.SelectedLabel;
                            srvResp1.Selected_Values_gne__c = srvResp2.SelectedValues;
                            srvResp1.Title_gne__c = srvResp2.Title;
                            srvResp1.Type_gne__c = srvResp2.ResponseType;
                            srvResp1.Values_gne__c = srvResp2.Values;
                            srvResp1.Weight_gne__c = srvResp2.Weight;
                        }
                    }
                }
            }
            else
            {   system.debug('>>>>>>>>>>>>singleSurvey.Id= '+singleSurvey.Id);
                for(SurveyResponse srvResp : srv.surveyResponsesList)
                {
                    Survey_Response_gne__c singleResponse = new Survey_Response_gne__c();
                    singleResponse.Category_gne__c = srvResp.ResponseCategory;
                    singleResponse.Free_Text_gne__c = srvResp.FreeText;
                    singleResponse.Full_Title_gne__c = srvResp.FullTitle;
                    singleResponse.Help_Text_gne__c = srvResp.HelpText;
                    singleResponse.Labels_gne__c = srvResp.Labels;
                    singleResponse.Maximum_Score_gne__c = srvResp.MaxScore;
                    singleResponse.Minimum_Score_gne__c = srvResp.MinScore;
                    singleResponse.Multiple_Responses_gne__c = srvResp.MultipleResponses;
                    singleResponse.Position_gne__c = srvResp.Position;
                    singleResponse.Question_gne__c = srvResp.QuestionId;
                    singleResponse.Response_Score_gne__c = srvResp.ResponseScore;
                    singleResponse.Selected_Label_gne__c = srvResp.SelectedLabel;
                    singleResponse.Selected_Values_gne__c = srvResp.SelectedValues;
                    singleResponse.Survey_gne__c = singleSurvey.Id;
                    singleResponse.Title_gne__c = srvResp.Title;
                    singleResponse.Type_gne__c = srvResp.ResponseType;
                    singleResponse.Values_gne__c = srvResp.Values;
                    singleResponse.Weight_gne__c = srvResp.Weight;
                    surveyResponses.add(singleResponse);
                }
            }
            Database.Upsertresult[] responsesUpsert = Database.upsert(surveyResponses);
            Id responsesUpsertId = responsesUpsert[0].getId();
            if(responsesUpsertId == null)
            {
                Database.rollback ( savePoint );
                Database.Error dbError = responsesUpsert[0].getErrors()[0];
                resp.ResponseErrorCode = dbError.getStatusCode().Name();
                resp.ResponseErrorMessage = dbError.getMessage();
            }
            resp.EndTime = DateTime.now();
            return resp;
    }
    
    
}