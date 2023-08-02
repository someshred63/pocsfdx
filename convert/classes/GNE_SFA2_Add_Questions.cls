global class GNE_SFA2_Add_Questions
{
    Public static void AddQuestionsAfterInsert(List<Question_gne__c> questions,String userId){
        
        //Survey_gne__c surv =null;
        List<Id> questionsIDs = new List<Id>();
        List<Id> questionnaireIDs = new List<Id>();
        for (Question_gne__c objQuestion : questions) 
        {
            System.debug('objQuestion.Questionnaire_gne__c: ' + objQuestion.Questionnaire_gne__c);
            System.debug('objQuestion.Id: ' + objQuestion.Id);
            questionsIDs.add(objQuestion.Id);
            questionnaireIDs.add(objQuestion.Questionnaire_gne__c);
        }
        String LucPredProf = 'Lucentis Predictive Profiling';
        Questionnaire_gne__c q=[Select q.Audience_Type_gne__c, q.Category_gne__c, q.Freeze_Surveys_gne__c, q.Hide_Surveys_gne__c, q.Id, 
                    q.Name, q.No_Edit_gne__c, q.Show_Questions_Position_gne__c,
                    q.Ready_For_Use_gne__c, q.Single_Survey_per_Mode_gne__c, q.Type_gne__c,
                    (Select Category_gne__c, Help_Text_gne__c, Id, Maximum_Score_gne__c, 
                        Minimum_Score_gne__c, Position_gne__c, Title_gne__c, 
                        Type_gne__c, Values_gne__c, Labels_gne__c, Weight_gne__c From Questions__r where Id=:questionsIds) 
                    from Questionnaire_gne__c q where q.ID=:questionnaireIDs];
        if(q.Type_gne__c != LucPredProf){
            Util.isLucentis = false;
        }
        List<Survey_gne__c> surv = [Select s.Account__c, s.CreatedById, s.Id, s.Name, s.Product_Metrics_vod__c, s.Questionnaire_gne__c, s.Title_gne__c, s.Total_Score_gne__c from Survey_gne__c s
            where s.Questionnaire_gne__c=:questionnaireIDs];
        
        List<Survey_Response_gne__c> survResps=new List<Survey_Response_gne__c>();
        List<String> scoreLst = new List<String>();
        List<String> labelLst = new List<String>();
        if(surv.size() > 0){
            for(Survey_gne__c survObject:surv)
            {
                for(Question_gne__c quest : q.Questions__r)
                {
                    Survey_Response_gne__c survResp=new Survey_Response_gne__c();
                    survResp.Survey_gne__c=survObject.Id;
                    survResp.Title_gne__c=quest.Title_gne__c;
                    survResp.Help_Text_gne__c = quest.Help_Text_gne__c ;
                    survResp.Minimum_Score_gne__c = quest.Minimum_Score_gne__c;
                    survResp.Maximum_Score_gne__c = quest.Maximum_Score_gne__c;
                    survResp.Weight_gne__c =  quest.Weight_gne__c ;
                    survResp.Position_gne__c = quest.Position_gne__c;
                    if(quest.Category_gne__c != null) survResp.Category_gne__c = quest.Category_gne__c;
                    if(quest.Values_gne__c != null) survResp.Values_gne__c = getDataWithoutSpace(quest.Values_gne__c);
                    if(quest.Labels_gne__c != null) survResp.Labels_gne__c = getDataWithoutSpace(quest.Labels_gne__c);
                    survResp.Type_gne__c = quest.Type_gne__c;
                    survResp.Question_gne__c=quest.Id;
                    survResps.add(survResp);
                }
            }
            if(survResps.size() > 0)
                insert survResps;
            if([select count() from Survey_gne__c where Questionnaire_gne__c=:questionnaireIDs]==1) {
                q.No_Edit_gne__c=true;
                update q;
            }   
        }
    }
    static String getDataWithoutSpace(String Labels)
    {
        String SelectedValues='';
        
        List<String> labelLst = new List<String>();
        if(Labels != null){
            labelLst = Labels.split(',');
        }
        for(String label3 : labelLst){
            if(SelectedValues == '')
                SelectedValues = label3.trim();
            else
                SelectedValues = SelectedValues.trim() + ',' + label3.trim();
        }
        return SelectedValues;
    }
}