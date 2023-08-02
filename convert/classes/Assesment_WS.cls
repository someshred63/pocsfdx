global class Assesment_WS{
    public class HelperException extends Exception {}
    static string NoUsersQueueName='No Users';

    private static Boolean isCanadaUser(){
        String profileName = [select Name from Profile where Id = :UserInfo.getProfileId()].Name;
        if(profileName != null && profileName.toUpperCase().contains('CANADA')){
            return true;
        }else{
            return false;
        }
    }

    WebService static Boolean isSFAUser(){
        String profileName = [select Name from Profile where Id = :UserInfo.getProfileId()].Name;
        if(profileName != null && profileName.toUpperCase().contains('GNE-SFA') && !profileName.startsWithIgnoreCase('GNE-SFA-OPS') ){
            return true;
        }else{
            return false;
        }
    }

    WebService static Boolean isAssesmentAnalyzeButtonDisabled(){
        Boolean result = false;
        Set<String> profilesWithButtonDisabled = new Set<String>{'GNE-MCCO-AM',
            'GNE-MCCO-FRM-BFRM', 'GNE-MCCO-FRM-BFRM-MANAGER', 'GNE-MCCO-FRM-EFRM', 'GNE-MCCO-FRM-EFRM-MANAGER',
            'GNE-MCCO-FRM-IFRM', 'GNE-MCCO-FRM-IFRM-MANAGER', 'GNE-MCCO-FRM-NFRM', 'GNE-MCCO-FRM-NFRM-MANAGER',
            'GNE-MCCO-FRM-RFRM', 'GNE-MCCO-FRM-RFRM-MANAGER', 'GNE-MCCO-FRM-RESPFRM', 
            'GNE-MEDAFFAIRS-MCL', 'GNE-MEDAFFAIRS-MCL-MANAGER'};
        String profileName = [select Name from Profile where Id = :UserInfo.getProfileId()].Name;
        if (profileName != null && profilesWithButtonDisabled.contains(profileName.toUpperCase())){
            result = true;
        }
        return result;
    }

    WebService static Boolean isAssesmentReadOnlyByMCCOTeamsShared(){
        Boolean result = false;
        Set<String> profilesWithReadOnlyView = new Set<String>{
            'GNE-MEDAFFAIRS-MCL', 'GNE-MEDAFFAIRS-MCL-MANAGER'};
        String profileName = [select Name from Profile where Id = :UserInfo.getProfileId()].Name;
        if (profileName != null && profilesWithReadOnlyView.contains(profileName.toUpperCase())){
            result = true;
        }
        return result;
    }

    static string GetNoUsersQueueID(){
        return [Select g.Id from Group g where g.Name=:NoUsersQueueName].Id;
    }

    WebService static Account getAssesmentAccount(String surveyID){
        Account acc;
        Survey_gne__c sv = [Select s.Account__c, s.Product_Metrics_vod__c, s.id from Survey_gne__c s where s.id=: surveyID];

        if(sv.Product_Metrics_vod__c!=null) {
            Product_Metrics_vod__c pm=[select p.Account_vod__c from Product_Metrics_vod__c p where p.id=:sv.Product_Metrics_vod__c];
            acc=[Select a.FirstName, a.Id, a.LastName from Account a where a.id=:pm.Account_vod__c];
        } else {
            acc=[Select a.FirstName, a.Id, a.LastName from Account a where a.id=:sv.Account__c];
        }
        return acc;
    }
    WebService static boolean isBrandAffiliationID(String brandAffiliationID){
        List<Product_Metrics_vod__c> pms=[Select Id from Product_Metrics_vod__c where id =: brandAffiliationID];
        return pms.size()>0;
    }
    WebService static boolean isAccountID(String accountID){
        List<Account> acs=[Select a.Id from Account a where a.id=:accountID];
        return acs.size()>0;
    }
    WebService static boolean isContactID(String contactID){
        List<Contact> acs=[Select a.Id from Contact a where a.id=:contactID];
        return acs.size()>0;
    }
    WebService static Account getBrandAffiliationAccount(String brandAffiliationID){
        Product_Metrics_vod__c pm = [Select Account_vod__c from Product_Metrics_vod__c where id =: brandAffiliationID];
        Account acc=[Select a.FirstName, a.Id, a.LastName from Account a where a.id=:pm.Account_vod__c];
        return acc;
    }
    WebService static Account getAccount(String accountID){
        return [Select a.FirstName, a.Id, a.LastName, a.Name from Account a where a.id=:accountID];
    }
    WebService static Product_vod__c getBrandAffiliationProduct(String brandAffiliationID){
        Product_Metrics_vod__c pm = [Select Products_vod__c from Product_Metrics_vod__c where id =: brandAffiliationID];
        Product_vod__c prod=[Select p.Name, p.Id from Product_vod__c p where p.id=:pm.Products_vod__c];
        return prod;
    }
    WebService static Product_Metrics_vod__c getSurveyBrandAffiliation(String surveyID){
        Survey_gne__c sv = [Select s.Product_Metrics_vod__c, s.id from Survey_gne__c s where s.id=: surveyID];
        if(sv.Product_Metrics_vod__c==null) return null;
        return [select p.Account_vod__c from Product_Metrics_vod__c p where p.id=:sv.Product_Metrics_vod__c];
    }
    WebService static Contact getContact(String ContactId){
        return [Select a.Name,a.Id,a.AccountId from Contact a where a.id=: ContactId];
    }
    WebService static List<Product_vod__c> getAccountProducts(String accountID){
        Product_Metrics_vod__c[] pms = [Select Products_vod__c from Product_Metrics_vod__c where Account_vod__c =: accountID];
        List<Product_vod__c> prods=new List<Product_vod__c>();
        for(Product_Metrics_vod__c pm:pms){
            prods.addAll([Select p.Name, p.Id from Product_vod__c p where id=:pm.Products_vod__c]);
        }
        return prods;
    }
    WebService static Product_Metrics_vod__c getBrandAffiliation (String accountID, String productID){
        return [Select p.Id, p.Account_vod__c, p.Products_vod__c from
                Product_Metrics_vod__c p where p.Account_vod__c=:accountID and
                p.Products_vod__c=:productID];
    }
    WebService static boolean hasQuestionnaireSurveys(String questionnaireID){
        return ([Select count() from Survey_gne__c s where s.Questionnaire_gne__c=:questionnaireID]>0);
    }
    WebService static List<Question_gne__c> getQuestionnaireQuestions(string questionnaireID){
        List<Question_gne__c> quest=new List<Question_gne__c>();
        quest.addAll([Select q.Category_gne__c, q.Help_Text_gne__c, q.Labels_gne__c, q.Maximum_Score_gne__c, q.Minimum_Score_gne__c, q.Position_gne__c, q.Questionnaire_gne__c, q.Title_gne__c, q.Type_gne__c, q.Values_gne__c, q.Weight_gne__c,q.Multiple_Responses_gne__c, q.Force_Ranking_Value_gne__c from Question_gne__c q where q.Questionnaire_gne__c=:questionnaireID order by q.Category_gne__c,q.Position_gne__c]);
        return quest;
    }
    Webservice static integer getQuestionnaireQuestionsNumber(string questionnaireID){
        return [Select count() from Question_gne__c q where q.Questionnaire_gne__c=:questionnaireID];
    }
    WebService static integer reorderQuestionnaireQuestions(String questionnaireID){
        List<Question_gne__c> qs=getQuestionnaireQuestions(questionnaireID);
        string currSection=null;
        integer count=0;
        for(integer i=1;i<qs.size()+1;i++){
            qs[i-1].Position_gne__c=i;
        }
        update qs;
        return count;
    }


    WebService static List<Questionnaire_gne__c> getQuestionnaires(String category,String productID,String accountID){
        if (productID!=''){
            List<Questionnaire_gne__c> qs=
                    [Select q.RecordType.Name,q.Audience_Type_gne__c, q.Category_gne__c, q.Freeze_Surveys_gne__c, q.Hide_Surveys_gne__c, q.Id,
                        q.Name, q.No_Edit_gne__c, q.Product_gne__c, q.Product_gne__r.Id, q.ProductSpecific_gne__c,
                        q.Ready_For_Use_gne__c, q.Single_Survey_per_Mode_gne__c, q.Type_gne__c, q.Version_gne__c, q.Show_Questions_Position_gne__c,
                        (Select Account__c, Id From QuestionnairesAccounts__r where Account__c=:accountID), (Select Account__c, Id From Surveys__r where Account__c=:accountID)
                        from Questionnaire_gne__c q  where
                        q.Ready_For_Use_gne__c = true and
                        q.ProductSpecific_gne__c=true and
                        q.Hide_Surveys_gne__c=false and
                        q.Freeze_Surveys_gne__c=false and
                        q.Product_gne__c=:productID and
                        q.Category_gne__c =:category];
            List<Questionnaire_gne__c> qs2=new List<Questionnaire_gne__c>();
            for(Questionnaire_gne__c q:qs ){
                boolean addIt=true;
                if(q.Audience_Type_gne__c=='Targeted' && q.QuestionnairesAccounts__r.size()==0) addIt=false;

                if(q.Freeze_Surveys_gne__c && q.Surveys__r.size()==0) addIt=false;

                if(addIt) qs2.add(q);
            }
            return qs2;
        } else {
            List<Questionnaire_gne__c> qs=
                    [Select q.RecordType.Name,q.Audience_Type_gne__c, q.Category_gne__c, q.Freeze_Surveys_gne__c, q.Hide_Surveys_gne__c, q.Id,
                        q.Name, q.No_Edit_gne__c,
                        q.Ready_For_Use_gne__c, q.Single_Survey_per_Mode_gne__c, q.Type_gne__c, q.Version_gne__c, q.Show_Questions_Position_gne__c,
                        (Select Account__c, Id From QuestionnairesAccounts__r where Account__c=:accountID), (Select Account__c, Id From Surveys__r where Account__c=:accountID)
                        from Questionnaire_gne__c q  where
                        q.Ready_For_Use_gne__c = true and
                        q.ProductSpecific_gne__c=false and
                        q.Hide_Surveys_gne__c=false and
                        q.Freeze_Surveys_gne__c=false and
                        q.Category_gne__c =:category];
            List<Questionnaire_gne__c> qs2=new List<Questionnaire_gne__c>();
            for(Questionnaire_gne__c q:qs ){
                boolean addIt=true;
                if(isCanadaUser()){
                    if(q.QuestionnairesAccounts__r.size()==0){
                        addIt=false;
                    }
                }else{
                    if(q.Audience_Type_gne__c=='Targeted' && q.QuestionnairesAccounts__r.size()==0){
                        addIt=false;
                    }
                }

                if(q.Freeze_Surveys_gne__c && q.Surveys__r.size()==0) addIt=false;

                if(addIt) qs2.add(q);
            }
            return qs2;
        }
    }


    WebService static List<Questionnaire_gne__c> getQuestionnairesByAccount(String category,String productID,String accountID){
        List<Questionnaire_gne__c> qs=
                [Select q.Audience_Type_gne__c, q.Category_gne__c, q.Id, q.Name, q.ProductSpecific_gne__c,
                q.RecordType.Id, q.RecordType.Name, q.Type_gne__c, q.Single_Survey_per_Mode_gne__c, q.Show_Questions_Position_gne__c,
                (Select Account__c, Id From QuestionnairesAccounts__r where Account__c=:accountID) from Questionnaire_gne__c q  where
                q.Ready_For_Use_gne__c = true and q.ProductSpecific_gne__c=true and  q.Category_gne__c =:category and q.Product_gne__c=: productID];
        List<Questionnaire_gne__c> qs2=new List<Questionnaire_gne__c>();
        for(Questionnaire_gne__c q:qs ){
            if(q.Audience_Type_gne__c=='Targeted' && q.QuestionnairesAccounts__r.size()>0 || q.Audience_Type_gne__c=='General') qs2.add(q);
        }
        return qs2;
    }

    Webservice static boolean updateSurveyVisibility(boolean visible, string questionnaireID){

        string NoUsersQueueID=GetNoUsersQueueID();
        if(visible){
            List<Survey_gne__c> survs=new List<Survey_gne__c>();
            do{
                survs=[Select s.Id, s.Questionnaire_gne__c, s.CreatedById, s.OwnerId from Survey_gne__c s  where s.Questionnaire_gne__c=:questionnaireID and s.OwnerId=:NoUsersQueueID limit 900];
                for(Survey_gne__c surv:survs) surv.OwnerId=surv.CreatedById;
                update survs;
            }while (survs.size()>0);
            return true;

        } else {
            List<Survey_gne__c> survs=new List<Survey_gne__c>();
            do{
                survs=[Select s.Id, s.Questionnaire_gne__c, s.CreatedById, s.OwnerId from Survey_gne__c s  where s.Questionnaire_gne__c=:questionnaireID and s.OwnerId<>:NoUsersQueueID limit 900];
                for(Survey_gne__c surv:survs) surv.OwnerId=NoUsersQueueID;
                update survs;
            }while (survs.size()>0);
            return true;
        }
    }
    //2597
    static  Decimal getDefaultScore(String Scores){
        System.debug('Scores: ' + Scores);
        Decimal defaultScore = 0;
        List<String> scoreLst = new List<String>();
        if(Scores != null){
            scoreLst = Scores.split(',');
        }
        if (scoreLst.size() >0){
            defaultScore = Decimal.valueOf(scoreLst[0]);
        }
        return defaultScore;

    }
    static  String getDefaultLabel(String Labels){
        String defaultLabel = '';
        List<String> labelLst = new List<String>();
        if(Labels != null){
            labelLst = Labels.split(',');
        }
        if (labelLst.size() >0){
            defaultLabel = labelLst[0];
        }
        return defaultLabel;

    }
    static String getDataWithoutSpace(String Labels)
    {
        System.debug('Labels: ' + Labels);
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
        System.debug('SelectedValues: ' + SelectedValues);
        return SelectedValues;
    }

    WebService static Survey_gne__c createSurveyFromBrandAffiliation(String questionnaireID,String brandAffiliationId,String accountId,String userId){
        Questionnaire_gne__c q=[Select q.Audience_Type_gne__c, q.Category_gne__c, q.Freeze_Surveys_gne__c, q.Hide_Surveys_gne__c, q.Id,
                                q.Name, q.No_Edit_gne__c,
                                q.Ready_For_Use_gne__c, q.Single_Survey_per_Mode_gne__c, q.Type_gne__c, q.Show_Questions_Position_gne__c,
                                (Select Category_gne__c, Help_Text_gne__c, Id, Maximum_Score_gne__c,
                                        Minimum_Score_gne__c, Position_gne__c, Title_gne__c,
                                        Type_gne__c, Values_gne__c, Labels_gne__c, Weight_gne__c, Multiple_Responses_gne__c, Force_Ranking_Value_gne__c From Questions__r)
                                 from Questionnaire_gne__c q where q.ID=:questionnaireID];
        if(q.Single_Survey_per_Mode_gne__c=='Per User Per Account' && [Select count() from Survey_gne__c s where s.CreatedById=:userId and s.Account__c=:accountId and  s.Questionnaire_gne__c=:questionnaireID and s.Product_Metrics_vod__c=:brandAffiliationId]>0){
            return [
                Select s.Account__c, s.CreatedById, s.Id, s.Name, s.Product_Metrics_vod__c, s.Questionnaire_gne__c, s.Title_gne__c, s.Total_Score_gne__c from Survey_gne__c s
                where s.CreatedById=:userId and s.Account__c=:accountId and  s.Questionnaire_gne__c=:questionnaireID and s.Product_Metrics_vod__c=:brandAffiliationId
            ];
        }
        if(q.Single_Survey_per_Mode_gne__c=='Per Account' && [Select count() from Survey_gne__c s where s.CreatedById=:userId and s.Account__c=:accountId and  s.Questionnaire_gne__c=:questionnaireID and s.Product_Metrics_vod__c=:brandAffiliationId]>0){
            return [
                Select s.Account__c, s.CreatedById, s.Id, s.Name, s.Product_Metrics_vod__c, s.Questionnaire_gne__c, s.Title_gne__c, s.Total_Score_gne__c from Survey_gne__c s
                where s.Account__c=:accountId and  s.Questionnaire_gne__c=:questionnaireID and s.Product_Metrics_vod__c=:brandAffiliationId
            ];
        }
        Survey_gne__c surv=new Survey_gne__c();
        surv.Product_Metrics_vod__c=brandAffiliationId;
        surv.Questionnaire_gne__c=questionnaireID;
        //surv.Title_gne__c = q.Type_gne__c; // No longer needed since now a lookup formula to parent Questionnaire
        insert surv;
        List<Survey_Response_gne__c> survResps=new List<Survey_Response_gne__c>();
        for(Question_gne__c quest:q.Questions__r){
            Survey_Response_gne__c survResp=new Survey_Response_gne__c();
            survResp.Survey_gne__c=surv.Id;
            survResp.Title_gne__c=quest.Title_gne__c;
            survResp.Type_gne__c=quest.Type_gne__c;
            survResp.Help_Text_gne__c = quest.Help_Text_gne__c ;
            survResp.Minimum_Score_gne__c = quest.Minimum_Score_gne__c;
            survResp.Maximum_Score_gne__c = quest.Maximum_Score_gne__c;
            survResp.Weight_gne__c =  quest.Weight_gne__c ;
        survResp.Position_gne__c = quest.Position_gne__c;
            if(quest.Labels_gne__c != null) survResp.Labels_gne__c =  getDataWithoutSpace(quest.Labels_gne__c);
            if(quest.Category_gne__c != null) survResp.Category_gne__c = quest.Category_gne__c;
            if(quest.Values_gne__c != null) survResp.Values_gne__c = getDataWithoutSpace(quest.Values_gne__c);
            survResp.Question_gne__c=quest.Id;
            // Force Ranking
            survResp.Force_Ranking_Value_gne__c = quest.Force_Ranking_Value_gne__c;
            //2597
            if(quest.Type_gne__c=='Numeric'){
                survResp.Selected_Label_gne__c = String.valueOf(quest.Minimum_Score_gne__c);
                survResp.Response_Score_gne__c = quest.Minimum_Score_gne__c;
                survResp.Selected_Values_gne__c = String.valueOf(quest.Minimum_Score_gne__c);
                System.debug('Sud1 survResp.Selected_Values_gne__c: ' + survResp.Selected_Values_gne__c);
            }else if (quest.Type_gne__c=='Free Text'){
                survResp.Free_Text_gne__c = '';

            }
            else if(quest.Type_gne__c=='List of Values'){
                survResp.Selected_Label_gne__c = getDefaultLabel(quest.Values_gne__c);
                survResp.Response_Score_gne__c = Decimal.valueOf(survResp.Selected_Label_gne__c);
                survResp.Selected_Values_gne__c = survResp.Selected_Label_gne__c;
                System.debug('Sud2 survResp.Selected_Values_gne__c: ' + survResp.Selected_Values_gne__c);
            }
            else{
                survResp.Selected_Label_gne__c = getDefaultLabel(quest.Labels_gne__c);
                survResp.Response_Score_gne__c = getDefaultScore(quest.Values_gne__c);
                survResp.Selected_Values_gne__c = String.valueOf(survResp.Response_Score_gne__c);
                System.debug('Sud3 survResp.Selected_Values_gne__c: ' + survResp.Selected_Values_gne__c);
            }
            survResp.Multiple_Responses_gne__c = quest.Multiple_Responses_gne__c;
            survResps.add(survResp);
        }
        insert survResps;
        if([select count() from Survey_gne__c where Questionnaire_gne__c=:questionnaireID]==1) {
            q.No_Edit_gne__c=true;
            update q;
        }
        return surv;
    }


    WebService static Survey_gne__c createSurveyFromAccount(String questionnaireID,String accountID,String userId,String contactID){
        Questionnaire_gne__c q=[Select q.Audience_Type_gne__c, q.Category_gne__c, q.Freeze_Surveys_gne__c, q.Hide_Surveys_gne__c, q.Id,
                                q.Name, q.No_Edit_gne__c, q.Show_Questions_Position_gne__c,
                                q.Ready_For_Use_gne__c, q.Single_Survey_per_Mode_gne__c, q.Type_gne__c,
                                (Select Category_gne__c, Help_Text_gne__c, Id, Maximum_Score_gne__c,
                                        Minimum_Score_gne__c, Position_gne__c, Title_gne__c,
                                        Type_gne__c, Values_gne__c, Labels_gne__c, Weight_gne__c,Multiple_Responses_gne__c, Force_Ranking_Value_gne__c From Questions__r)
                                from Questionnaire_gne__c q where q.ID=:questionnaireID];
        system.debug('Create Survey from Account q : '  +q );
        system.debug('q.Id : '  +q.ID );

        if(q.Single_Survey_per_Mode_gne__c=='Per User Per Account' && [Select count() from Survey_gne__c s where s.CreatedById=:userId and s.Account__c=:accountId and  s.Questionnaire_gne__c=:questionnaireID]>0){
            return [
                Select s.Account__c, s.CreatedById, s.Id, s.Name, s.Product_Metrics_vod__c, s.Questionnaire_gne__c, s.Title_gne__c, s.Total_Score_gne__c from Survey_gne__c s
                where s.CreatedById=:userId and s.Account__c=:accountId and  s.Questionnaire_gne__c=:questionnaireID
            ];
        }
        if(q.Single_Survey_per_Mode_gne__c=='Per Account' && [Select count() from Survey_gne__c s where s.CreatedById=:userId and s.Account__c=:accountId and  s.Questionnaire_gne__c=:questionnaireID ]>0){
            return [
                Select s.Account__c, s.CreatedById, s.Id, s.Name, s.Product_Metrics_vod__c, s.Questionnaire_gne__c, s.Title_gne__c, s.Total_Score_gne__c from Survey_gne__c s
                where s.Account__c=:accountId and  s.Questionnaire_gne__c=:questionnaireID
            ];
        }
       Survey_gne__c surv=new Survey_gne__c();
        surv.Account__c=accountID;
        if(contactID!=null && contactID!='') surv.Contact_gne__c=contactID;
        surv.Questionnaire_gne__c=questionnaireID;
        //surv.Title_gne__c = q.Type_gne__c; // No longer needed since now a lookup formula to parent Questionnaire

        insert surv;
    system.debug('survey Inserted 1 : '     +surv);
        List<Survey_Response_gne__c> survResps=new List<Survey_Response_gne__c>();
        for(Question_gne__c quest:q.Questions__r){
            Survey_Response_gne__c survResp=new Survey_Response_gne__c();
            survResp.Survey_gne__c=surv.Id;
            survResp.Title_gne__c=quest.Title_gne__c;
            survResp.Help_Text_gne__c = quest.Help_Text_gne__c ;
            survResp.Minimum_Score_gne__c = quest.Minimum_Score_gne__c;
            survResp.Maximum_Score_gne__c = quest.Maximum_Score_gne__c;
            survResp.Weight_gne__c =  quest.Weight_gne__c ;
            survResp.Position_gne__c = quest.Position_gne__c;
            if(quest.Labels_gne__c != null) survResp.Labels_gne__c =  getDataWithoutSpace(quest.Labels_gne__c);
            if(quest.Category_gne__c != null) survResp.Category_gne__c = quest.Category_gne__c;
            if(quest.Values_gne__c != null) survResp.Values_gne__c = getDataWithoutSpace(quest.Values_gne__c);
            survResp.Type_gne__c = quest.Type_gne__c;
            survResp.Question_gne__c=quest.Id;
            // Force Ranking
            survResp.Force_Ranking_Value_gne__c = quest.Force_Ranking_Value_gne__c;
            //2597
            if(quest.Type_gne__c=='Numeric'){
                survResp.Selected_Label_gne__c = String.valueOf(quest.Minimum_Score_gne__c);
                survResp.Response_Score_gne__c = quest.Minimum_Score_gne__c;
                survResp.Selected_Values_gne__c = String.valueOf(quest.Minimum_Score_gne__c);
            }else if (quest.Type_gne__c=='Free Text'){
                survResp.Free_Text_gne__c = '';

            }

            else if(quest.Type_gne__c=='List of Values'){
                survResp.Selected_Label_gne__c = getDefaultLabel(quest.Values_gne__c);
                survResp.Response_Score_gne__c = Decimal.valueOf(survResp.Selected_Label_gne__c);
                survResp.Selected_Values_gne__c = survResp.Selected_Label_gne__c;
            }
            else{
                survResp.Selected_Label_gne__c = getDefaultLabel(quest.Labels_gne__c);
                survResp.Response_Score_gne__c = getDefaultScore(quest.Values_gne__c);
                survResp.Selected_Values_gne__c = String.valueOf(survResp.Response_Score_gne__c);
            }
            survResp.Multiple_Responses_gne__c = quest.Multiple_Responses_gne__c;
            survResps.add(survResp);
        }
        insert survResps;
    system.debug('survResps : '     +survResps);
        if([select count() from Survey_gne__c where Questionnaire_gne__c=:questionnaireID]==1) {
            q.No_Edit_gne__c=true;
            update q;
        }
    system.debug('survey Inserted 2 : '     +surv);
        return surv;

    }

    //New WS Created by Chatham Reed for use in Balanced_ScoreCard VisualForce page (clone of above WS with minor modifications
    //Allows for creation of Survey from VF Page.

    WebService static Survey_gne__c createSurveyFromAccount_mcco(String questionnaireID,String accountID,String userId){
        Questionnaire_gne__c q=[Select q.Audience_Type_gne__c, q.Category_gne__c, q.Freeze_Surveys_gne__c, q.Hide_Surveys_gne__c, q.Id,
                                q.Name, q.No_Edit_gne__c, q.Show_Questions_Position_gne__c,
                                q.Ready_For_Use_gne__c, q.Single_Survey_per_Mode_gne__c, q.Type_gne__c,
                                (Select Category_gne__c, Help_Text_gne__c, Id, Maximum_Score_gne__c,
                                        Minimum_Score_gne__c, Position_gne__c, Title_gne__c,
                                        Type_gne__c, Values_gne__c, Labels_gne__c, Weight_gne__c, Force_Ranking_Value_gne__c From Questions__r)
                                from Questionnaire_gne__c q where q.ID=:questionnaireID];



        if(q.Single_Survey_per_Mode_gne__c=='Per User Per Account' && [Select count() from Survey_gne__c s where s.CreatedById=:userId and s.Account__c=:accountId and  s.Questionnaire_gne__c=:questionnaireID]>0){
            return [
                Select s.Account__c, s.CreatedById, s.Id, s.Name, s.Product_Metrics_vod__c, s.Questionnaire_gne__c, s.Title_gne__c, s.Total_Score_gne__c from Survey_gne__c s
                where s.CreatedById=:userId and s.Account__c=:accountId and  s.Questionnaire_gne__c=:questionnaireID
            ];
        }
        if(q.Single_Survey_per_Mode_gne__c=='Per Account' && [Select count() from Survey_gne__c s where s.CreatedById=:userId and s.Account__c=:accountId and  s.Questionnaire_gne__c=:questionnaireID ]>0){
            return [
                Select s.Account__c, s.CreatedById, s.Id, s.Name, s.Product_Metrics_vod__c, s.Questionnaire_gne__c, s.Title_gne__c, s.Total_Score_gne__c from Survey_gne__c s
                where s.Account__c=:accountId and  s.Questionnaire_gne__c=:questionnaireID
            ];
        }
        Survey_gne__c surv=new Survey_gne__c();
        surv.Account__c=accountID;
        surv.Questionnaire_gne__c=questionnaireID;
        //surv.Title_gne__c = q.Type_gne__c;// No longer needed since now a lookup formula to parent Questionnaire

        insert surv;
        List<Survey_Response_gne__c> survResps=new List<Survey_Response_gne__c>();
        for(Question_gne__c quest:q.Questions__r){
            Survey_Response_gne__c survResp=new Survey_Response_gne__c();
            survResp.Survey_gne__c=surv.Id;
            survResp.Title_gne__c=quest.Title_gne__c;
            survResp.Help_Text_gne__c = quest.Help_Text_gne__c ;
            survResp.Minimum_Score_gne__c = quest.Minimum_Score_gne__c;
            survResp.Maximum_Score_gne__c = quest.Maximum_Score_gne__c;
            survResp.Weight_gne__c =  quest.Weight_gne__c ;
            survResp.Position_gne__c = quest.Position_gne__c;
            if(quest.Labels_gne__c != null) survResp.Labels_gne__c =  getDataWithoutSpace(quest.Labels_gne__c);
            if(quest.Category_gne__c != null) survResp.Category_gne__c = quest.Category_gne__c;
            if(quest.Values_gne__c != null) survResp.Values_gne__c = getDataWithoutSpace(quest.Values_gne__c);
            survResp.Type_gne__c = quest.Type_gne__c;
            survResp.Question_gne__c=quest.Id;
            // Force Ranking
            survResp.Force_Ranking_Value_gne__c = quest.Force_Ranking_Value_gne__c;
            //2597
            if(quest.Type_gne__c=='Numeric'){
                survResp.Selected_Label_gne__c = String.valueOf(quest.Minimum_Score_gne__c);
                survResp.Response_Score_gne__c = quest.Minimum_Score_gne__c;
                survResp.Selected_Values_gne__c = String.valueOf(quest.Minimum_Score_gne__c);
            }
            else if(quest.Type_gne__c=='List of Values'){
                survResp.Selected_Label_gne__c = getDefaultLabel(quest.Values_gne__c);
                System.debug('Sud Listof Values1: Selected Label: '+ survResp.Selected_Label_gne__c);
                survResp.Response_Score_gne__c = Decimal.valueOf(survResp.Selected_Label_gne__c);
                survResp.Selected_Values_gne__c = survResp.Selected_Label_gne__c;
            }
            else{
                survResp.Selected_Label_gne__c = getDefaultLabel(quest.Labels_gne__c);
                System.debug('Sud Listof Values2: Selected Label: '+survResp.Selected_Label_gne__c);
                survResp.Response_Score_gne__c = getDefaultScore(quest.Values_gne__c);
                survResp.Selected_Values_gne__c = String.valueOf(survResp.Response_Score_gne__c);
            }
            survResps.add(survResp);
        }
        insert survResps;
        if([select count() from Survey_gne__c where Questionnaire_gne__c=:questionnaireID]==1) {
            q.No_Edit_gne__c=true;
            update q;
        }
        return surv;
    }



 /** Added by Vp on Nov 25th 2009 for
      * update survey to current definitions of questionnaire
      */
    WebService static Survey_gne__c updateSurvey(String surveyID){

        //  Survey_gne__c surv = [select Id, OwnerId, Name, Account__c, Product_Metrics_vod__c, Questionnaire_gne__c, Contact_gne__c, Total_Score_gne__c, Contact_Name_gne__c, Current_Access_Metrics_Survey_gne__c, User_Business_Role_gne__c, Version_gne__c, Title_gne__c from Survey_gne__c where Id = :surveyId];
        Survey_gne__c survey = [select Id, OwnerId, Name, Account__c, Product_Metrics_vod__c, Questionnaire_gne__c, Contact_gne__c, Total_Score_gne__c, Contact_Name_gne__c, Current_Access_Metrics_Survey_gne__c, Version_gne__c,                      Title_gne__c from Survey_gne__c where Id = :surveyId];

        Questionnaire_gne__c questionnaire =[Select questionnaire.Audience_Type_gne__c, questionnaire.Category_gne__c, questionnaire.Freeze_Surveys_gne__c, questionnaire.Hide_Surveys_gne__c, questionnaire.Id,
                                                questionnaire.Name, questionnaire.No_Edit_gne__c, questionnaire.Ready_For_Use_gne__c, questionnaire.Single_Survey_per_Mode_gne__c, questionnaire.Type_gne__c, questionnaire.Show_Questions_Position_gne__c,
                                                (Select Category_gne__c, Help_Text_gne__c, Id, Maximum_Score_gne__c, Minimum_Score_gne__c, Position_gne__c, Title_gne__c,
                                                    Type_gne__c, Values_gne__c, Labels_gne__c, Weight_gne__c, Multiple_Responses_gne__c, Force_Ranking_Value_gne__c
                                                from Questions__r)
                                            from Questionnaire_gne__c questionnaire
                                            where questionnaire.ID = :survey.Questionnaire_gne__c];
        System.debug(questionnaire);


        List<Survey_Response_gne__c> oldSurveyResponses = [select Id, Free_Text_gne__c, Category_gne__c, Help_Text_gne__c, Labels_gne__c, Maximum_Score_gne__c, Minimum_Score_gne__c,
                                                                Position_gne__c, Question_gne__c, Response_Score_gne__c, Survey_gne__c, Title_gne__c, Type_gne__c, Values_gne__c, Weight_gne__c,
                                                                Weighted_Score_gne__c, Selected_Label_gne__c, Full_Title_gne__c, Selected_Values_gne__c,Multiple_Responses_gne__c, Force_Ranking_Value_gne__c
                                                            from Survey_Response_gne__c
                                                            where Survey_gne__c = :survey.Id];

        Map<Id, Question_gne__c> questionnaireQuestionsMap = new Map<Id, Question_gne__c>();
        Map<Id, Survey_Response_gne__c> surveyResponsesMap = new Map<Id, Survey_Response_gne__c>();
        Map<Id, Survey_Response_gne__c> responsesToDeleteMap = new Map<Id, Survey_Response_gne__c>();

        List<Survey_Response_gne__c> survRespsToUpdate = new List<Survey_Response_gne__c>();

        for(Question_gne__c question : questionnaire.Questions__r){
            questionnaireQuestionsMap.put(question.Id, question);
        }

        for(Survey_Response_gne__c response : oldSurveyResponses){
            surveyResponsesMap.put(response.Question_gne__c, response);
            responsesToDeleteMap.put(response.Question_gne__c, response);
        }

        for(Id questionId : questionnaireQuestionsMap.keySet()){
            Boolean isDifferent = false;
            if(surveyResponsesMap.containsKey(questionId)){
                // question exists, so we will not remove it from survey
                responsesToDeleteMap.remove(questionId);
                // check if anything changed in this question and if yes, update survey response
                if(questionnaireQuestionsMap.get(questionId).Title_gne__c != surveyResponsesMap.get(questionId).Title_gne__c){
                    isDifferent = true;
                    surveyResponsesMap.get(questionId).Title_gne__c = questionnaireQuestionsMap.get(questionId).Title_gne__c;
                }
                if(questionnaireQuestionsMap.get(questionId).Type_gne__c != surveyResponsesMap.get(questionId).Type_gne__c){
                    isDifferent = true;
                    surveyResponsesMap.get(questionId).Type_gne__c = questionnaireQuestionsMap.get(questionId).Type_gne__c;
                }
                if(questionnaireQuestionsMap.get(questionId).Multiple_Responses_gne__c != surveyResponsesMap.get(questionId).Multiple_Responses_gne__c){
                    isDifferent = true;
                    surveyResponsesMap.get(questionId).Multiple_Responses_gne__c = questionnaireQuestionsMap.get(questionId).Multiple_Responses_gne__c;
                }
                if(questionnaireQuestionsMap.get(questionId).Position_gne__c != surveyResponsesMap.get(questionId).Position_gne__c){
                    isDifferent = true;
                    surveyResponsesMap.get(questionId).Position_gne__c = questionnaireQuestionsMap.get(questionId).Position_gne__c;
                }
                if(questionnaireQuestionsMap.get(questionId).Minimum_Score_gne__c != surveyResponsesMap.get(questionId).Minimum_Score_gne__c){
                    isDifferent = true;
                    surveyResponsesMap.get(questionId).Minimum_Score_gne__c = questionnaireQuestionsMap.get(questionId).Minimum_Score_gne__c;
                }
                if(questionnaireQuestionsMap.get(questionId).Maximum_Score_gne__c != surveyResponsesMap.get(questionId).Maximum_Score_gne__c){
                    isDifferent = true;
                    surveyResponsesMap.get(questionId).Maximum_Score_gne__c = questionnaireQuestionsMap.get(questionId).Maximum_Score_gne__c;
                }
                if(questionnaireQuestionsMap.get(questionId).Weight_gne__c != surveyResponsesMap.get(questionId).Weight_gne__c){
                    isDifferent = true;
                    surveyResponsesMap.get(questionId).Weight_gne__c = questionnaireQuestionsMap.get(questionId).Weight_gne__c;
                }
                if(questionnaireQuestionsMap.get(questionId).Help_Text_gne__c != surveyResponsesMap.get(questionId).Help_Text_gne__c){
                    isDifferent = true;
                    surveyResponsesMap.get(questionId).Help_Text_gne__c = questionnaireQuestionsMap.get(questionId).Help_Text_gne__c;
                }
                if(questionnaireQuestionsMap.get(questionId).Category_gne__c != surveyResponsesMap.get(questionId).Category_gne__c){
                    isDifferent = true;
                    surveyResponsesMap.get(questionId).Category_gne__c = questionnaireQuestionsMap.get(questionId).Category_gne__c;
                }
                if(questionnaireQuestionsMap.get(questionId).Labels_gne__c != surveyResponsesMap.get(questionId).Labels_gne__c){
                    isDifferent = true;
                    surveyResponsesMap.get(questionId).Labels_gne__c = questionnaireQuestionsMap.get(questionId).Labels_gne__c;
                }
                if(questionnaireQuestionsMap.get(questionId).Values_gne__c != surveyResponsesMap.get(questionId).Values_gne__c){
                    isDifferent = true;
                    surveyResponsesMap.get(questionId).Values_gne__c = questionnaireQuestionsMap.get(questionId).Values_gne__c;
                }
                if(questionnaireQuestionsMap.get(questionId).Force_Ranking_Value_gne__c != surveyResponsesMap.get(questionId).Force_Ranking_Value_gne__c){
                    isDifferent = true;
                    surveyResponsesMap.get(questionId).Force_Ranking_Value_gne__c = questionnaireQuestionsMap.get(questionId).Force_Ranking_Value_gne__c;
                }
                if(isDifferent){
                    survRespsToUpdate.add(surveyResponsesMap.get(questionId));
                }
            }
        }

        // delete all survey responses that match deleted questionnaire questions
        if(responsesToDeleteMap.size() > 0){
            delete responsesToDeleteMap.values();
        }

        // update all changed responses and survey to update it's lastModifiedDate
        if(survRespsToUpdate.size() > 0){
            update survRespsToUpdate;
            update survey;
        }

        if([select count() from Survey_gne__c where Questionnaire_gne__c=:survey.Questionnaire_gne__c] > 0){
            questionnaire.No_Edit_gne__c = true;
            update questionnaire;
        }
        return survey;
    }
    static Decimal getCurrentScoreForLabel(String Label,String Scores, String Labels, String strType)
    {
        System.debug('Label: '+Label);
        System.debug('Labels: '+Labels);
        System.debug('Scores: '+Scores);
        //2606
        List<String> scoreLst = new List<String>();
        if(Scores != null){
            scoreLst = Scores.split(',');
        }
        List<String> labelLst = new List<String>();
        if(Labels != null){
            labelLst = Labels.split(',');
        }
        List<String> selectedLabelLst = new List<String> ();
        Decimal selectedscore = 0;
        if(Label != null && Label !=''){
            selectedLabelLst = Label.split(',');
            System.debug('selectedLabelLst: '+selectedLabelLst);
        }
        for(String label1 : selectedLabelLst){
            label1.trim();
        }
        map<String,Decimal> mapNewLabelForScore = new map<String,Decimal> ();
        Integer rowCount = 0;
        If(strType == 'List of Values'){
            rowCount = scoreLst.size();
            labelLst = scoreLst;
        }else
        {
            if(scoreLst.size() < labelLst.size()){
                rowCount = scoreLst.size();
            }
            else{
                rowCount = labelLst.size();
            }
        }
        for(Integer i=0; i<rowCount; i++){
                mapNewLabelForScore.put(labelLst[i].trim(),Decimal.valueOf(scoreLst[i].trim()));
        }
        //System.debug('mapNewLabelForScore.get(Label) : ' + mapNewLabelForScore.get(Label));
        if(selectedLabelLst.size() > 0){
            for(Integer i=0; i<selectedLabelLst.size(); i++){
                if(mapNewLabelForScore.containsKey(selectedLabelLst[i])){
                    //selectedscore = selectedscore + Decimal.valueOf(mapNewLabelForScore.get(selectedLabelLst[i]));
                    //changed due to version change to 18.0 - Required by Req2771
                    selectedscore = selectedscore + mapNewLabelForScore.get(selectedLabelLst[i]);
                }
            }
        }
        else{
            if(mapNewLabelForScore.containsKey(Label)){
                selectedscore = mapNewLabelForScore.get(Label);
            }
        }
        System.debug('selectedscore: '+selectedscore);
        return selectedscore;
    }
    static String getSelectedValue(String Label,String Scores, String Labels, String strType)
    {
        System.debug('Label: '+Label);
        System.debug('Labels: '+Labels);
        System.debug('Scores: '+Scores);

        //2606
        List<String> scoreLst = new List<String>();
        if(Scores != null){
            scoreLst = Scores.split(',');
        }
        List<String> labelLst = new List<String>();
        if(Labels != null){
            labelLst = Labels.split(',');
        }

        List<String> selectedLabelLst = new List<String> ();
        String selectedValue = '';
        if(Label != null && Label !=''){
            selectedLabelLst = Label.split(',');
            System.debug('selectedLabelLst: '+selectedLabelLst);
        }

        map<String,String> mapNewLabelForScore = new map<String,String> ();

        Integer rowCount = 0;
        If(strType == 'List of Values'){
            rowCount = scoreLst.size();
            labelLst = scoreLst;
        }else
        {
            if(scoreLst.size() < labelLst.size()){
                rowCount = scoreLst.size();
            }
            else{
                rowCount = labelLst.size();
            }
        }
        for(Integer i=0; i<rowCount; i++){
                mapNewLabelForScore.put(labelLst[i].trim(),scoreLst[i].trim());
        }
        System.debug('Sud mapNewLabelForScore.get(Label) : ' + mapNewLabelForScore.get(Label));
        if(selectedLabelLst.size() > 0){
            for(Integer i=0; i<selectedLabelLst.size(); i++){
                System.debug('Sud selectedLabelLst[i]: '+selectedLabelLst[i]);
                if(mapNewLabelForScore.containsKey(selectedLabelLst[i].trim())){
                    System.debug('Sud 1 selectedValue: '+selectedValue);
                    if(selectedValue ==''){
                      selectedValue = mapNewLabelForScore.get(selectedLabelLst[i].trim());
                      selectedValue = selectedValue.trim();
                      System.debug('Sud 2 selectedValue: '+selectedValue);
                    }else{
                        selectedValue = selectedValue.trim() + ',' + mapNewLabelForScore.get(selectedLabelLst[i].trim());
                        selectedValue = selectedValue.trim();
                        System.debug('Sud 3 selectedValue: '+selectedValue);
                        }
                }
            }
        }
        else{
            if(mapNewLabelForScore.containsKey(Label.trim())){
                selectedValue = mapNewLabelForScore.get(Label.trim());
                selectedValue = selectedValue.trim();
            }
        }
        System.debug('return selectedValue: '+selectedValue);
        return selectedValue;
    }

    /**
     * Helper Method to update existing surveys where labels may have changes but should be keot in synch with values
     * @score - socre values previously selected
     * @Scores - current list of available scores
     * @Labels - current list of available Labels
     */


    static String getCurrentLabelForScore(Decimal score,String Label,String Scores, String Labels,String SelectedValues, String strType)
    {
        System.debug('Labels: '+Labels);
        System.debug('Scores: '+Scores);
        System.debug('SelectedValues: '+SelectedValues);
        //2606
        List<String> scoreLst = new List<String>();
        if(Scores != null){
            scoreLst = Scores.split(',');
        }
        List<String> labelLst = new List<String>();
        if(Labels != null){
            labelLst = Labels.split(',');
        }
        for(String label2 : labelLst){
            label2.trim();
        }
        List<String> Selected_Values = new List<String> ();
        if(SelectedValues != null && SelectedValues !=''){
            Selected_Values = SelectedValues.split(',');
            System.debug('Selected_Values: '+Scores);
        }
        for(String label3 : Selected_Values){
            label3.trim();
        }
        map<String,Decimal> mapNewLabelForScore = new map<String,Decimal> ();
        map<Decimal,String> mapNewScoreForLabel = new map<Decimal,String> ();
        Integer rowCount = 0;
        If(strType == 'List of Values'){
            rowCount = scoreLst.size();
            labelLst = scoreLst;
        }else
        {
            if(scoreLst.size() < labelLst.size()){
                rowCount = scoreLst.size();
            }
            else{
                rowCount = labelLst.size();
            }
        }
        for(Integer i=0; i<rowCount; i++){
            mapNewLabelForScore.put(labelLst[i].trim(),Decimal.valueOf(scoreLst[i].trim()));
            mapNewScoreForLabel.put(Decimal.valueOf(scoreLst[i].trim()),labelLst[i].trim());
        }

        map<String,Decimal> mapCurrentLabelForScore = new map<String,Decimal> ();

        boolean isLabelFound = true;
        String selectedLabel = '';
        Decimal selectedscore = 0;

        if(Selected_Values.size() > 0){
            for (Integer j=0; j<Selected_Values.size();j++){
                if(mapNewScoreForLabel.containsKey(Decimal.valueOf(Selected_Values[j].trim()))){
                    isLabelFound = false;
                    if(selectedLabel == ''){
                        selectedLabel = mapNewScoreForLabel.get(Decimal.valueOf(Selected_Values[j].trim()));
                        selectedLabel = selectedLabel.trim();
                    }else{
                        selectedLabel = selectedLabel.trim() + ',' + mapNewScoreForLabel.get(Decimal.valueOf(Selected_Values[j].trim()));
                        selectedLabel = selectedLabel.trim();
                        }
                }
            }

        }

        if(isLabelFound){
            if(Label != null && mapNewLabelForScore.containsKey(Label.trim())){
                //changed due to version change to 18.0 - Required by Req2771
                //selectedscore = Decimal.valueOf(mapNewLabelForScore.get(Label.trim()));
                selectedscore = mapNewLabelForScore.get(Label.trim());
                selectedLabel = Label.trim();
                selectedLabel = selectedLabel.trim();
                isLabelFound = false;
            }
            if(isLabelFound)
            {
                if(mapNewScoreForLabel.containsKey(score)){
                    selectedLabel = mapNewScoreForLabel.get(score);
                    selectedLabel = selectedLabel.trim();
                    selectedscore = score;
                    isLabelFound = false;
                }
            }
            if(isLabelFound)
            {
                selectedscore = Decimal.valueOf(scoreLst[0]);
                selectedLabel = labelLst[0].trim();
                isLabelFound = false;
            }
            mapCurrentLabelForScore.clear();
            mapCurrentLabelForScore.put(selectedLabel,selectedscore);
        }

        return selectedLabel;

    }


   //Ends here Vp
    WebService static Questionnaire_gne__c duplicateQuestionnaire(string questionnaireID){
        Questionnaire_gne__c q=[Select q.Audience_Type_gne__c, q.Category_gne__c, q.Freeze_Surveys_gne__c, q.Hide_Surveys_gne__c, q.Id,
                                q.Version_gne__c, q.Name, q.No_Edit_gne__c, q.Product_gne__c, q.ProductSpecific_gne__c, q.Show_Questions_Position_gne__c,
                                q.Ready_For_Use_gne__c, q.Single_Survey_per_Mode_gne__c, q.Type_gne__c,
                                (Select Category_gne__c, Help_Text_gne__c, Id, Maximum_Score_gne__c,
                                        Minimum_Score_gne__c, Position_gne__c, Title_gne__c,
                                        Type_gne__c, Values_gne__c, Labels_gne__c, Weight_gne__c, Force_Ranking_Value_gne__c From Questions__r)
                                from Questionnaire_gne__c q where q.ID=:questionnaireID];
        Questionnaire_gne__c q1=new Questionnaire_gne__c(
                Audience_Type_gne__c=q.Audience_Type_gne__c,
                Category_gne__c=q.Category_gne__c,
                Ready_For_Use_gne__c=false,
                Single_Survey_per_Mode_gne__c=q.Single_Survey_per_Mode_gne__c,
                Type_gne__c=q.Type_gne__c ,
                Version_gne__c = q.Version_gne__c + ' <duplicate>',
                Product_gne__c=q.Product_gne__c,
                ProductSpecific_gne__c=q.ProductSpecific_gne__c,
                Show_Questions_Position_gne__c=q.Show_Questions_Position_gne__c
        );
        insert q1;

        /*List<QuestionnaireAccount_gne__c> qas= [Select q.Account__c, q.Questionnaire_gne__c from QuestionnaireAccount_gne__c q where q.Questionnaire_gne__c=:questionnaireID];
        for(QuestionnaireAccount_gne__c qa:qas){
            QuestionnaireAccount_gne__c qan=new QuestionnaireAccount_gne__c( Account__c=qa.Account__c,Questionnaire_gne__c=qa.Questionnaire_gne__c);
            insert qan;
        }*/

        List<Question_gne__c> qsn=new List<Question_gne__c>();
        for(Question_gne__c qs:q.Questions__r){
            qsn.add(new Question_gne__c(
                Category_gne__c=qs.Category_gne__c,
                Help_Text_gne__c=qs.Help_Text_gne__c,
                Maximum_Score_gne__c=qs.Maximum_Score_gne__c,
                Minimum_Score_gne__c=qs.Minimum_Score_gne__c,
                Position_gne__c=qs.Position_gne__c,
                Title_gne__c=qs.Title_gne__c,
                Type_gne__c=qs.Type_gne__c,
                Values_gne__c=qs.Values_gne__c,
                Labels_gne__c=qs.Labels_gne__c,
                Weight_gne__c=qs.Weight_gne__c,
                Force_Ranking_Value_gne__c=qs.Force_Ranking_Value_gne__c,
                Questionnaire_gne__c=q1.Id
            ));
        }
        insert qsn;
        List<Questionnaire_gne__c> qs=
                [   Select q.Audience_Type_gne__c, q.Category_gne__c, q.Freeze_Surveys_gne__c, q.Hide_Surveys_gne__c,
                    q.Id, q.Name, q.No_Edit_gne__c, q.Product_gne__c, q.ProductSpecific_gne__c, q.Ready_For_Use_gne__c,
                    q.Single_Survey_per_Mode_gne__c, q.Type_gne__c, q.Version_gne__c, q.Product_gne__r.Id, q.Product_gne__r.Name from Questionnaire_gne__c q  where q.id=: q1.id];
        return qs[0];
    }

//2474 - add s.Multiple_Responses_gne__c in SOQL
    WebService static Survey_Response_gne__c[] getSurveyResponses(String surveyID){
        return [Select s.Category_gne__c, s.Help_Text_gne__c, s.Id, s.Selected_Label_gne__c,
        s.Maximum_Score_gne__c, s.Minimum_Score_gne__c, s.Position_gne__c,
        s.Response_Score_gne__c, s.Survey_gne__c,s.Free_Text_gne__c,
        s.Title_gne__c, s.Type_gne__c, s.Values_gne__c, s.Labels_gne__c, s.Weight_gne__c,
        s.Weighted_Score_gne__c,s.Multiple_Responses_gne__c, s.Force_Ranking_Value_gne__c from Survey_Response_gne__c s where
        s.Survey_gne__c=:surveyID  order by s.Category_gne__c,s.Position_gne__c];
    }
    WebService static Survey_gne__c[] getSurvey(String surveyID){
        return [Select s.Account__c, s.Questionnaire_gne__r.RecordType.Name, s.Questionnaire_gne__r.Category_gne__c, s.Speaker_Bureau_Member_Name_gne__r.Name, s.Medical_Event_gne__c, s.Product_Metrics_vod__c, s.Questionnaire_gne__c, s.Title_gne__c, s.Total_Score_gne__c from Survey_gne__c s where
        s.Id=:surveyID];
    }

    WebService static Product_vod__c getProduct(String productID){
        return [Select p.Name, p.Id from Product_vod__c p where id=:productID];
    }

    WebService static Questionnaire_gne__c getQuestionnaire(String questionnaireID){
        List<Questionnaire_gne__c> qs=
                [   Select q.RecordType.Name, q.Audience_Type_gne__c, q.Version_gne__c, q.Category_gne__c, q.Freeze_Surveys_gne__c, q.Hide_Surveys_gne__c, q.Show_Questions_Position_gne__c,
                    q.Id, q.Name, q.No_Edit_gne__c, q.Product_gne__c, q.ProductSpecific_gne__c, q.Ready_For_Use_gne__c,
                    q.Single_Survey_per_Mode_gne__c, q.Type_gne__c,q.Product_gne__r.Id, q.Product_gne__r.Name, q.Show_Weight_gne__c from Questionnaire_gne__c q  where q.id=: questionnaireID];
        if(qs.size()>0) return qs[0];
        return null;
    }
    WebService static List<Account> getQuestionnaireAccounts(String questionnaireID){
        List<QuestionnaireAccount_gne__c> qas= [Select q.Account__c, q.Id from QuestionnaireAccount_gne__c q where q.Questionnaire_gne__c=:questionnaireID];
        List<Account> accs=new List<Account>();
        Set<id> ids=new Set<id>();
        for(QuestionnaireAccount_gne__c qa:qas){
            ids.add(qa.Account__c);
        }
        accs=[select a.Name, a.FirstName, a.Id, a.LastName, a.IsPersonAccount from Account a where a.Id in :ids];
        return accs;
    }
    WebService static boolean setQuestionnaireRecordType(String questionnaireID, string recordTypeId){
        Questionnaire_gne__c q=new Questionnaire_gne__c(Id=questionnaireID);
        q.RecordTypeId=recordTypeId;
        update q;
        return true;
    }
    WebService static string setQuestionnaireAccountsFromCSV(String questionnaireID, string newList){
        integer num=0;
        Savepoint sp = Database.setSavepoint();
        try{
            List<QuestionnaireAccount_gne__c> QuestionnaireAccounts=[select Id from QuestionnaireAccount_gne__c where Questionnaire_gne__c=:questionnaireID];
            delete QuestionnaireAccounts;
        } catch (Exception e){
            Database.rollback(sp);
            return('Operation Aborted: Error during the delete of current Questionnaire Account association;  Questionnaire ID=' + questionnaireID);
        }
        List<Account> accs=new List<Account>();
        List<QuestionnaireAccount_gne__c> qAccs=new List<QuestionnaireAccount_gne__c>();
        if(newList!=''){
            string currId;
            try{
                string accCSV='';
                List<String> sList=newList.split(',');
                accs=[Select a.LastName,a.FirstName,a.Id from Account a where a.Id in :sList];
                for(Account acc:accs){
                    qAccs.add(new QuestionnaireAccount_gne__c(Account__c=acc.id,Questionnaire_gne__c=questionnaireID));
                }
                insert qAccs;
                //if(!accounts.isEmpty()) this.m_accountsCSV=accCSV.substring(0,accCSV.length()-1);
                //else this.m_accountsCSV='';
            } catch (Exception e){
                Database.rollback(sp);
                return('Operation Aborted: Unable to add new Questionnaire Account association;');
            }
        }
        return 'ok';
    }
    //2474 - add q.Multiple_Responses_gne__c in SOQL
    WebService static Question_gne__c getQuestion(String questionID){
        List<Question_gne__c> qs=
                [Select q.Category_gne__c, q.Help_Text_gne__c, q.Labels_gne__c, q.Maximum_Score_gne__c,
                q.Minimum_Score_gne__c, q.Position_gne__c, q.Questionnaire_gne__c, q.Title_gne__c, q.Id,
                q.Type_gne__c, q.Values_gne__c, q.Weight_gne__c,q.Multiple_Responses_gne__c, Force_Ranking_Value_gne__c from Question_gne__c q  where q.id=: questionID];
        if(qs.size()>0) return qs[0];
        return null;
    }
    WebService static boolean deleteQuestion(string questionID){
        List<Question_gne__c> qs= [Select q.Id from Question_gne__c q  where q.id=: questionID];
        if(qs.size()>0) delete qs[0];
        return true;
    }

    WebService static List<Product_vod__c> getProductByName(String name){
        name=name+'%';
        return [Select p.Id, p.Name from Product_vod__c p where p.Name like :name];
    }

    //ADDED BY OMEAR 10/07/09
    //adds pf targets or access traget accounts to questionnaire accounts
    WebService static String addTargets(String questID, String Mode, String AccountType){
      //String to hold message to return to user
      String resultMsg = '';

      //Accounts to be filtered from soql query
    set<ID> qAccs_set = new set<ID>();

    //List of questionnaire accounts to be inserted
    List<QuestionnaireAccount_gne__c> toInsert = new List<QuestionnaireAccount_gne__c>();

    //List of accounts to create questionnaire accounts out of
    List<Account> accounts = new List<Account>();

    //Query all QuestionnaireAccounts for the given questionnaire
    List<QuestionnaireAccount_gne__c> qAccs;

    if(AccountType == 'PT')
    {
      qAccs = [select Account__c from QuestionnaireAccount_gne__c
             where Questionnaire_gne__c = :questID];
      for(QuestionnaireAccount_gne__c qa : qAccs){
        qAccs_set.add(qa.Account__c);
      }

      if(Mode == 'Access'){
        accounts = [select Id from Account where Access_Account_x_gne__c = true AND ID NOT IN :qAccs_set];
      }else if (Mode == 'Target'){
        accounts = [select Id from Account where Target__c = true AND ID NOT IN :qAccs_set];
      }
    }

    if(AccountType == 'AM')
    {
    Set<ID> TrIDx = new Set<Id>();
    List<String> TerNamesSt = new List<String>();
    Set<ID> AccountsId = new Set<ID>();

    List<UserTerritory2Association > TerIDList;
    if(AccountType == 'AM')
      TerIDList = [Select Territory2Id  From UserTerritory2Association  where UserId IN (Select Id From User where Profile.Name Like  'GNE-MCCO-AM%')];

    for(UserTerritory2Association   a : TerIDList){
          TrIDx.add(a.Territory2Id );
    }
    List<Territory2 > TerrName = [Select Name from Territory2 where Id IN :TrIDx];

    for(Territory2 a : TerrName ){
          TerNamesSt.add(a.Name);
    }
    database.executeBatch(new QuestionnaireAccounts_for_CFT_FRM(questID, mode, accountType, TerNamesSt), 100);
    }

    if(AccountType == 'PT')
    {
    for(Account a : accounts){
      toInsert.add(new QuestionnaireAccount_gne__c(Account__c = a.id, Questionnaire_gne__c = questID));
    }

    List<Database.Saveresult> result;
    try{
      result = Database.insert(toInsert);
    }catch(DmlException e){System.debug(e.getMessage());}

    Integer succCount = 0;
    Integer failCount = 0;

    for(Database.Saveresult ds : result){
      if(ds.isSuccess()){
        succCount++;
      }else {
        failCount++;
        System.debug('The Following Failed:'+ds);
      }
    }

  if(succCount > 0 && failCount == 0) {
    return resultMsg = 'The Questionnaire Accounts List has been updated with ' + succCount + ' Access Accounts.';
  } else if (succCount==0) {
    return resultMsg = 'No Accounts were added. Please verify the Accounts you are adding or contact your system administrator for further assistance.';
    } else {
        return resultMsg = 'A system error occurred while adding the Accounts. Please contact your system administrator for further assistance.';
      }
    }
    return 'Process started. Please wait 5 minutes and refresh page.';
    }

    WebService static Boolean isUserValidToTakeSurvey(String accountID, String userId){
        Boolean result = false;
        //GNE_SFAC_TargetsAndTiers_Service


        return result;
    }


}