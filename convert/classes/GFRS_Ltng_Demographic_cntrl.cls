public class GFRS_Ltng_Demographic_cntrl {
    
    @AuraEnabled
    public static List<gFRS_Ltng_Request_Budget__c> createBudgetRecords(string appId){ 
        SavePoint sp = Database.setSavepoint();
        gFRS_Ltng_Application__c gfrsApp =new gFRS_Ltng_Application__c();
        try{
            Boolean hasLiveBudget = false;
            String liveBudget = 'Live (in-person)';
            Map<String, Boolean> mapExistingBudgets;
            mapExistingBudgets = new Map<String, Boolean>{
                liveBudget => false
                    };
                        
                        list<gFRS_Ltng_Request_Budget__c> fundingRequestBudgets = new list<gFRS_Ltng_Request_Budget__c>();
            fundingRequestBudgets = [
                SELECT Id, Name, Total_Amount__c, Budget_Summary_Description__c, Request_Delivery_Format__c,
                Type__c, Request_Name__c
                FROM gFRS_Ltng_Request_Budget__c
                WHERE gFRS_Application__c = :appId
            ];
            
            if(fundingRequestBudgets.size() > 0){
                for (gFRS_Ltng_Request_Budget__c b : fundingRequestBudgets) {
                    if (mapExistingBudgets.containsKey(b.Type__c)) {
                        mapExistingBudgets.put(b.Type__c, true);
                    }
                }                
            }
            
            if (!mapExistingBudgets.get(liveBudget)) {
                hasLiveBudget = true;
                system.debug('has Live Pgm');
            }          
            
            gFRS_Ltng_Request_Budget__c liveBudgetRec = null;
            
            gFRS_Ltng_Request_Budget__c[] lBudgetsToInsert = new gFRS_Ltng_Request_Budget__c[]{};
                
                if (hasLiveBudget == true) {
                    liveBudgetRec = new gFRS_Ltng_Request_Budget__c(Budget_Summary_Description__c = 'Budget for Live Activity', gFRS_Application__c = appId, Type__c = liveBudget);
                    lBudgetsToInsert.add(liveBudgetRec);
                    system.debug('live Budget add');
                }
            
            gfrsApp.id=appId;
            gfrsApp.Selected_Tab_Val__c='bgtInfo';
            gFRS_Ltng_Util_NoShare.updateGfrsAPP(gfrsApp);
            //update gfrsApp;
            upsert lBudgetsToInsert;
            
            return [Select id,name,Total_Amount__c,Type__c,gFRS_Application__c,(Select id,Category__c,Subcategory__c,Amount__c,Count__c,Explanation__c,gFRS_Request_Budget__c From FRS_Request_Budget_Line_Items__r) 
                    From gFRS_Ltng_Request_Budget__c Where gFRS_Application__c=:appId];
            
            
        }
        catch(Exception e){
            
            Database.rollback(sp);
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }       
    @AuraEnabled  
    public static List<picklistWrapper> getPicklistvalues(string objAPIName, string fieldAPIname) {        
        
        list<picklistWrapper> returnValue = new list<picklistWrapper>();
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Map<String, Schema.SObjectField> field_map = gd.get(objAPIName.toLowerCase()).getDescribe().fields.getMap();
        // Get the list of picklist values for this field.
        list < Schema.PicklistEntry > values = field_map.get(fieldAPIname).getDescribe().getPickListValues();
        
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a: values) {
            picklistWrapper aa = new picklistWrapper();
            aa.pickListLabel = a.getLabel();
            aa.pickListValue = a.getValue();
            returnValue.add(aa);
        }
        
        return returnValue;
        
    }
    
    @AuraEnabled
    public static gFRS_Ltng_Demographic_Data__c saveDemoGraphicRec(gFRS_Ltng_Demographic_Data__c objDemographicRec, String appId){
        system.debug('AppId'+appId);
        system.debug('AppId'+objDemographicRec.id);
        SavePoint sp = Database.setSavepoint();          
        system.debug('AppId@@'+objDemographicRec.id); 
        if(objDemographicRec.gFRS_Application__c!= null ||objDemographicRec.gFRS_Application__c!=''){
            objDemographicRec.gFRS_Application__c = appId;  
        }else{
            objDemographicRec.gFRS_Application__c = appId;
        }
        try{
            upsert objDemographicRec;
            
            return [Select id,Name,Age__c,Employment_Status__c,Sexual_orientation__c,Event_Program_leadership_Screen_reader_s__c,Gender_Identity_and_Sexual_Orientation__c,
                    Health_and_Insurance_Status__c,Non_English_speaking_populations__c,Race_and_Ethnicity__c,Social_and_Economic_Status__c,Support_ESL_Non_English__c,
                    Teachers_served__c,Underrepresented_communities__c,Youth_served__c,Age_other__c,Employment_Status_other__c,Gender_Identity_other__c,
                    Health_and_Insurance_other__c,Race_and_Ethnicity_other__c,Sexual_Orientation_other__c,Social_and_Economic_other__c,Age_actual__c,
                    Gender_Identity_Sexual_Orientation_Autl__c,Sexual_orientation_Actual__c,Race_and_Ethnicity_Actual__c,Social_and_Economic_Status_Actual__c,
                    Health_and_Insurance_Status_Actual__c,Employment_Status_Actual__c,Changes_from_Orginal_Submission__c,Employment_Status_other_Actual__c,
                    Health_and_Insurance_other_Actual__c,Race_and_Ethnicity_other_Actual__c,Social_and_Economic_other_Actual__c,Sexual_Orientation_other_Actual__c,
                    Gender_Identity_other_Actual__c,Age_other_Actual__c from gFRS_Ltng_Demographic_Data__c Where id=:objDemographicRec.Id];
        }
        catch(exception e){
            Database.rollback(sp);
            system.debug('@@@:::Msg:::'+e.getMessage());
            system.debug('@@@LineNum:::'+e.getLineNumber());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            system.debug('auraExceptionObj'+auraExceptionObj);
            throw auraExceptionObj; 
            
        }
        
        
    }
    @AuraEnabled
    public static gFRS_Ltng_Demographic_Data__c saveEvaluationDemoGraphicRec(gFRS_Ltng_Demographic_Data__c objDemographicRec, String appId, boolean taskClosed, gFRS_Ltng_Application__c appRecord){
        system.debug('AppId'+appId);
        system.debug('AppId'+objDemographicRec.id);
        SavePoint sp = Database.setSavepoint();          
        system.debug('AppId@@'+objDemographicRec.id); 
        if(objDemographicRec.gFRS_Application__c!= null ||objDemographicRec.gFRS_Application__c!=''){
            objDemographicRec.gFRS_Application__c = appId;  
        }else{
            objDemographicRec.gFRS_Application__c = appId;
        }
        list<gFRS_Ltng_Task__c> taskevaluation = new list<gFRS_Ltng_Task__c>();
        gFRS_Ltng_Task__c taskRFIRec;
        if(taskClosed){           
            taskevaluation = [SELECT Id, Name, Status__c, Action_Type__c FROM gFRS_Ltng_Task__c WHERE gFRS_Application__c =: appId AND Action_Type__c = 'Evaluation' AND Status__c != 'Completed'];
            if(taskevaluation.size() > 0){
                taskRFIRec = taskevaluation[0];
                taskRFIRec.Status__c = 'Completed';                        
            } 
            gFRS_Ltng_Application__c objApp = new gFRS_Ltng_Application__c();
            objApp.id=appId;
            //objApp.Status__c='Closed';
            if(appRecord.Refund_Due_External__c != null){
                if((appRecord.Refund_Due_External__c >= 1000) && (appRecord.Record_Type_Name__c!='Foundation Undergraduate' && appRecord.Record_Type_Name__c!='Foundation Safety Net Support')){
                    objApp.External_Status__c = 'Refund Required';
                    objApp.Sub_Status__c = 'Refund Required';
                } else {
                    objApp.Status__c = 'Closed';
                    objApp.External_Status__c = 'Approved';
                    objApp.Sub_Status__c = 'Approved';
                }
            } else {
                objApp.Status__c = 'Closed';
                objApp.External_Status__c = 'Approved';
                objApp.Sub_Status__c = 'Approved';
            }
            
            objApp.Evaluation_Completed__c='Yes';
            gFRS_Ltng_Util_NoShare.updateAppRecord(objApp);
        }else{
            gFRS_Ltng_Application__c objApp = new gFRS_Ltng_Application__c();
            objApp.id=appId;                
            objApp.Evaluation_Completed__c='No';
            gFRS_Ltng_Util_NoShare.updateAppRecord(objApp);
        }
        
        try{
            upsert objDemographicRec;
            if(taskClosed){
                gFRS_Ltng_Util_NoShare.updateTask(taskRFIRec);    
            }
            return [Select id,Name,Age__c,Employment_Status__c,Sexual_orientation__c,Event_Program_leadership_Screen_reader_s__c,Gender_Identity_and_Sexual_Orientation__c,
                    Health_and_Insurance_Status__c,Non_English_speaking_populations__c,Race_and_Ethnicity__c,Social_and_Economic_Status__c,Support_ESL_Non_English__c,
                    Teachers_served__c,Underrepresented_communities__c,Youth_served__c,Age_other__c,Employment_Status_other__c,Gender_Identity_other__c,
                    Health_and_Insurance_other__c,Race_and_Ethnicity_other__c,Sexual_Orientation_other__c,Social_and_Economic_other__c,Age_actual__c,
                    Gender_Identity_Sexual_Orientation_Autl__c,Sexual_orientation_Actual__c,Race_and_Ethnicity_Actual__c,Social_and_Economic_Status_Actual__c,
                    Health_and_Insurance_Status_Actual__c,Employment_Status_Actual__c,Changes_from_Orginal_Submission__c,Employment_Status_other_Actual__c,
                    Health_and_Insurance_other_Actual__c,Race_and_Ethnicity_other_Actual__c,Social_and_Economic_other_Actual__c,Sexual_Orientation_other_Actual__c,
                    Gender_Identity_other_Actual__c,Age_other_Actual__c from gFRS_Ltng_Demographic_Data__c Where id=:objDemographicRec.Id];
        }
        catch(exception e){
            Database.rollback(sp);
            system.debug('@@@:::Msg:::'+e.getMessage());
            system.debug('@@@LineNum:::'+e.getLineNumber());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            system.debug('auraExceptionObj'+auraExceptionObj);
            throw auraExceptionObj; 
            
        }
        
        
    }
    public class picklistWrapper{
        @AuraEnabled 
        public string pickListLabel{get;set;}
        @AuraEnabled 
        public string pickListValue{get;set;}
        
    }
    
    @AuraEnabled
    public static gFRS_Ltng_Demographic_Data__c getDemographicRecord(String appId){
        list<gFRS_Ltng_Demographic_Data__c> objDemoList = new list<gFRS_Ltng_Demographic_Data__c>();
        gFRS_Ltng_Demographic_Data__c objDemo = new gFRS_Ltng_Demographic_Data__c();
        try{
            
            objDemoList= [Select id,Name,Age__c,Employment_Status__c,Sexual_orientation__c,Event_Program_leadership_Screen_reader_s__c,Gender_Identity_and_Sexual_Orientation__c,
                          Health_and_Insurance_Status__c,Non_English_speaking_populations__c,Race_and_Ethnicity__c,Social_and_Economic_Status__c,Support_ESL_Non_English__c,
                          Teachers_served__c,Underrepresented_communities__c,Youth_served__c,Age_other__c,Employment_Status_other__c,Gender_Identity_other__c,gFRS_Application__c,
                          Health_and_Insurance_other__c,Race_and_Ethnicity_other__c,Sexual_Orientation_other__c,Social_and_Economic_other__c,
                          Age_actual__c,Gender_Identity_Sexual_Orientation_Autl__c,Sexual_orientation_Actual__c,Race_and_Ethnicity_Actual__c,Social_and_Economic_Status_Actual__c,
                          Health_and_Insurance_Status_Actual__c,Employment_Status_Actual__c,Changes_from_Orginal_Submission__c,Employment_Status_other_Actual__c,
                          Health_and_Insurance_other_Actual__c,Race_and_Ethnicity_other_Actual__c,Social_and_Economic_other_Actual__c,Sexual_Orientation_other_Actual__c,
                          Gender_Identity_other_Actual__c,Age_other_Actual__c from gFRS_Ltng_Demographic_Data__c Where gFRS_Application__c =:appId];
            if(objDemoList.size() > 0){
                objDemo = objDemoList.get(0);
                return objDemo;
            }
            return objDemo;
            
        } catch(exception e){
            system.debug('@@@:::Msg:::'+e.getMessage());
            system.debug('@@@LineNum:::'+e.getLineNumber());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            system.debug('auraExceptionObj'+auraExceptionObj);
            throw auraExceptionObj; 
            
        }
        
    }  
    @AuraEnabled
    public static gFRS_Ltng_Application__c fetchFundingReqDetails(String reqId){
        Id recId = Id.valueof(reqId);
        system.debug('Application Id is : '+recId);
        gFRS_Ltng_Application__c appRec = new gFRS_Ltng_Application__c();
        try{
            appRec = [SELECT Id, Name, What_are_you_seeking_funding_for__c, Target_audience__c, Organization__c, Information_Needed__c,
                      Sister_Parent_Org_Strategic_Promo_Mktg__c, Firewall_for_Strategic_Promo_Mktg__c, Refund_Due_External__c,
                      Is_this_program_accredited__c, Org_the_Accreditor__c, Content_Development__c, Event_Program_Type__c,
                      Requested_Amount__c, Event_Program_Title__c, Therapeutic_Area__c, Disease_State__c,
                      Please_Specify_If_Disease_State_Other__c, Support_Purpose_Program_Description__c, Benefits_Exchanged_for_Funding__c,
                      Clinical_Practice_Guideline_Development__c, Associated_clinical_practice_guidelines__c,
                      Primary_Audience_Description__c, Addressed_by_this_Program_Initiative__c, Program_Objectives__c, Outcome_levels_to_be_achieved__c,
                      Other_Commercial_Supporters__c, If_known_List_Other_Supporters__c, Resubmission_of_Previous_Request__c, Resubmission_Request_Name__c,
                      Secondary_Invitations_BRC_s_Help_Request__c, Is_there_an_exhibit_opportunity_for_this__c, External_Tracking_Code__c, 
                      Opt_In_Process_for_Enduring_Materials__c, If_Yes_Please_Describe_Opt_In_Process__c, Will_You_be_Working_With_a_third_Party__c,Total_Overall_Budget__c,
                      Evaluation_Methodology__c, Unrestricted_Support_Request__c, Thank_You_Benifits__c, Non_Charitable_Amount__c,
                      Record_Type_Name__c, Print_Deadline__c, Print_Deadline_Date__c ,Funding_Sub_Type__c,Invite_Code__c,Focus_on_equity__c,Program_Start_Date_Min__c,Program_End_Date_max__c
                      FROM gFRS_Ltng_Application__c WHERE Id =: recId];
            system.debug('Application record is : '+appRec);
            return appRec;
        }
        catch(Exception e){ 
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        } 
    } 
    
    @AuraEnabled 
    public static void saveAppSurvey(String appId,String Field1,String Field2,String Field3,String Field4,String Field5,String Field6,String Field7){
        try{
            gFRS_Ltng_App_Submission_Survey__c appsurevy=new gFRS_Ltng_App_Submission_Survey__c();
            appsurevy.gFRS_Application__c=appId;
            appsurevy.To_what_extent_do_you_agree_or_disagree__c=Field1;
            appsurevy.Please_explain_the_reason_for_your_score__c=Field2;
            appsurevy.How_would_you_rate_your_overall_experien__c=Field3;
            appsurevy.Rate_Application_Process__c=Field4;
            appsurevy.Rate_Grant_Operaions_Support_Teams__c=Field5;
            appsurevy.What_specific_improvements__c=Field6;
            appsurevy.Survey_Type__c=Field7;
            insert appsurevy;
            if(String.isNotEmpty(appsurevy.Id)){
                gFRS_Ltng_Application__c gfrsapp=[SELECT ID,gFRS_Evaluation_Submission_Survey__c FROM gFRS_Ltng_Application__c WHERE ID=:appId LIMIT 1];
                gfrsapp.gFRS_Evaluation_Submission_Survey__c=appsurevy.Id;
                update gfrsapp;
            }
        }
        catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        } 
    }
    @AuraEnabled 
    public static gFRS_Ltng_App_Submission_Survey__c getAppSurvey(Id appId){
       gFRS_Ltng_App_Submission_Survey__c appsurvey=[select Id,Name,gFRS_Application__c,Survey_Type__c,To_what_extent_do_you_agree_or_disagree__c, Please_explain_the_reason_for_your_score__c, How_would_you_rate_your_overall_experien__c, Rate_Application_Process__c, Rate_Grant_Operaions_Support_Teams__c, What_specific_improvements__c from gFRS_Ltng_App_Submission_Survey__c WHERE gFRS_Application__c=:appId LIMIT 1];
        return appsurvey;
    }
    @AuraEnabled 
    public static SurveyWrapperclass getAppSurveyInternal(Id appId){
        
       SurveyWrapperclass survey=new SurveyWrapperclass();
       List<gFRS_Ltng_App_Submission_Survey__c> appsur=[select Id,Name,gFRS_Application__c,Survey_Type__c,To_what_extent_do_you_agree_or_disagree__c, Please_explain_the_reason_for_your_score__c, How_would_you_rate_your_overall_experien__c, Rate_Application_Process__c, Rate_Grant_Operaions_Support_Teams__c, What_specific_improvements__c from gFRS_Ltng_App_Submission_Survey__c WHERE gFRS_Application__c=:appId and Survey_Type__c='Application_Submission' LIMIT 1];
       List<gFRS_Ltng_App_Submission_Survey__c> evalsur=[select Id,Name,gFRS_Application__c,Survey_Type__c,To_what_extent_do_you_agree_or_disagree__c, Please_explain_the_reason_for_your_score__c, How_would_you_rate_your_overall_experien__c, Rate_Application_Process__c, Rate_Grant_Operaions_Support_Teams__c, What_specific_improvements__c from gFRS_Ltng_App_Submission_Survey__c WHERE gFRS_Application__c=:appId and Survey_Type__c='Evaluation_Submission' LIMIT 1];
       if (appsur.size()>0){
        survey.appsurvey=appsur;
       }
        if (evalsur.size()>0){
       survey.EvalSurvey=evalsur;
        }
        return survey;
 
    }
    public class SurveyWrapperclass{
        @AuraEnabled
        public List<gFRS_Ltng_App_Submission_Survey__c> AppSurvey{get; set;}
        @AuraEnabled
        public List<gFRS_Ltng_App_Submission_Survey__c> EvalSurvey{get; set;}
    }
    
}