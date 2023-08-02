public class gFRS_Ltng_PostpaymentController {
    @AuraEnabled
    public static gFRS_Ltng_Task_Update__c fetchUpdateTask(String appId) {
        try{
            return [select Id,Name,gFRS_Application__r.Name,gFRS_Application__r.Sub_Status__c,
                    gFRS_Application__r.Approved_Amount__c,gFRS_Application__r.Program_End_Date_max__c,
                    gFRS_Application__r.Are_the_outcomes_you_are_providing_premi__c,gFRS_Application__r.Thank_You_Benifits__c,
                    gFRS_Application__r.Event_Program_Title__c,gFRS_Application__r.Outcome_levels_to_be_achieved__c,
                    gFRS_Application__c,Evaluation_Status__c,gFRS_Application__r.Decision_Reasons__c,
                    Please_briefly_describe_the_final_result__c, Are_you_planning_to_publish_the_results__c,
                    Have_the_results_of_the_study_been_prese__c, If_available_please_attach_a_summary_of__c,
                    Additional_Evaluation_Comments__c, did_the_total_budget_amount__c, If_yes_Total_budget_amount__c, 
                    did_the_educational_objective__c, If_yes_did_the_educational_objective__c,
                    did_the_expected_outcomes__c, If_yes_did_the_expected_outcomes__c, did_the_educationa_design__c, 
                    Program_Specifications_Summary__c, Audience_Generation_Distribution__c, Attendance_Distribution__c, 
                    Project_Status__c, Expected_Outcome_Levels__c, Outcome1_Attach_Name__c,
                    If_outcome_levels_were_not_achieved__c, I_Certify_that_the_grant_received__c,
                    If_no_enter_reason_why_funds_not_used__c, Total_Amount_Used__c, Program_Changes_if_any__c,
                    Description_of_how_funds_were_used__c, Event_Program_Title__c, Scope_Attachment__c, 
                    Scope_Attachment_File_Name__c, Scope_Attachment_File_Type__c, Key_Highlights_Milestones__c,
                    Key_Learnings__c, Grant_Activity_Sustained__c, Equity_and_Inclusion_Focus__c, 
                    Explain_how_Equity_and_Inclusion__c, Explain_why_not_Equity_and_Inclusion__c,Number_of_Attendees_Actual__c
                    , Number_of_Patients_Actual__c, actual_number_served__c, Youth_Students_Served_Actual__c, Teachers_Served_Actual__c,
                    Teacher_Identification_PoC_Actual__c, Free_or_Reduced_Lunch_Actual__c, CMS_Covered_Recipient__c, Evaluation_Research_Summary__c,
                    Published_Stories_or_Announcements__c, Evaluation_Research_Summary_File_Name__c, Evaluation_Research_Summary_File_Type__c, Actual_Student_impact_people_of_color__c,
                    Student_impact_people_first_gen_Actual__c, If_available_upload_an_outcomes_report__c,
                    Are_the_outcomes_you_are_providing_premi__c, Select__c, Outcome1_Attach_Id__c, Outcome2_Attach_Id__c,
                    Outcome1_Attach_Type__c, Outcome2_Attach_Name__c, Outcome2_Attach_Type__c, Outcome3_Attach_Id__c,
                    Outcome3_Attach_Name__c, Outcome3_Attach_Type__c, Outcome4_Attach_Id__c, Outcome4_Attach_Name__c, 
                    Outcome4_Attach_Type__c,Were_the_expected_outcome_levels_achieve__c 
                    from gFRS_Ltng_Task_Update__c where gFRS_Application__c=:appId AND Name='Post Payment'];
        }
        catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }        
    }
    
    @AuraEnabled
    public static gFRS_Ltng_Application__c fetchAppRecord(String appId) {
        try{
            //return [select Id, Name, Event_Program_Title__c, Did_you_sponsor_exhibit_at_the_event__c, Why_didn_t_you_sponsor_exhibit_at_event__c, If_other_please_specify__c, Did_you_receive_benefits__c, Refund_Due_Status_Update__c from gFRS_Ltng_Application__c where Id =: appId];
            gFRS_Ltng_Application__c appRecord = new gFRS_Ltng_Application__c();
            appRecord = gFRS_Ltng_Util_NoShare.fetchAppRec(appId);
            return appRecord;
        }
        catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }        
    }    
    
    @AuraEnabled
    public static void updateProgram(gFRS_Ltng_Program__c gfrsprogram,List<gFRS_Ltng_Program_Audience_Group__c> prgaudlist){ 
        // gFRS_Ltng_Program__c gfrsprg=[select Id,Name,RecordTypeId,gFRS_Application__c, Program_Type__c, gFRS_End_Date__c, gFRS_Expected_number_of_attendees__c, gFRS_Expected_of_Attendees_US_Based_HCPs__c, gFRS_Nbr_of_Grand_Round_Mtg_Series_Activ__c, gFRS_Number_of_speakers_faculty__c, gFRS_Compliance_Flag__c, gFRS_Program_Type__c, gFRS_Start_Date__c, gFRS_Venue_City__c, gFRS_Secondary_program_title__c, gFRS_Venue_Name__c, gFRS_Venue_Province_Region_Territory__c, gFRS_Venue_State__c, gFRS_Venue_Type__c, gFRS_Venue_Zip_Code__c, gFRS_Web_URL__c, gFRS_Venue_Country__c, gFRS_Live_Real_time__c, gFRS_On_demand_Archived__c, gFRS_Program_Live_Subtype__c, gFRS_Program_Subtype__c, gFRS_Focus_Area__c, Venue_associated_with_this_event_program__c, Program_Status__c, gFRS_Funding_type__c, gFRS_Funding_sub_type__c, gFRS_Sub_Focus_Area__c, gFRS_Expected_number_of_patients_served__c, What_thank_you_benefits_will_be_provid__c, Is_there_an_exhibit_opportunity_price__c, Do_designated_HCPs_have_the_appropriate__c, focusArea__c, gFRS_Payment_to_a_Licensed_Physician__c, gFRS_Focus_on_STEM_education__c, gFRS_Expected_number_of_students_engaged__c, gFRS_Expected_number_of_teachers_engaged__c, gFRS_Free_and_Reduced_Lunch__c, gFRS_Fellowship_Opportunity_Publication__c, gFRS_Criteria_to_Select_a_Fellow__c, Student_impact_by_program__c, Product_being_Promoted__c, Number_of_exhibit_tables_purchasing__c, Are_there_any_other_commercial_sponsors__c, Are_any_students_impacted_by_Program__c, Financial_Assistance_Processes__c, Health_Screening_Broad_Audience__c, Event_program_geographic_location__c, Title_1_school__c, Scientific_Meeting_Broad_Audience__c, PoC_youth_students__c, Poc_teachers__c, SubFocusArea__c, How_many_attendees_do_you_expect__c from gFRS_Ltng_Program__c WHERE ID=:prgid];
        try{
            update gfrsprogram;
            if(prgaudlist.size()>0){    
                update prgaudlist;
            }
        }
        catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        } 
        
    }
    @AuraEnabled
    public static List<gFRS_Ltng_Program__c> getPrograms(String appId){ 
        system.debug('appID###'+appId);
        try{
            return [select Id, Name, RecordTypeId,Were_the_learning_objectives_achieved__c,gFRS_Application__r.Name, gFRS_Application__r.Event_Program_Title__c, gFRS_Program_Type__c, gFRS_Program_Live_Subtype__c, gFRS_End_Date__c, Program_Status__c, gFRS_Start_Date__c, gFRS_Venue_Name__c, gFRS_Venue_City__c, gFRS_Venue_State__c, gFRS_Venue_Zip_Code__c, gFRS_Venue_Country__c, gFRS_Web_URL__c, Number_of_Completions__c, Total_Unique_Visits__c, Number_of_Certificates_Issued__c, Summary__c, Number_of_CE_credits__c, Was_question_asked__c, Number_of_Respondents__c, Percent_Responding_Positively__c, Access_to_equipment__c, Conflicting_evidence__c, Lack_of_training__c, Patient_knowledge__c, None_were_identified__c, Access_to_treatment_or_clinical_trails__c, Cost_of_theraphy__c, Patient_adherence__c, Staffing__c, Did_you_exhibit_sponsor_at_the_event__c, Why_didnt_you_exhibit_at_the_event__c, If_No_please_specify_the_reason__c from gfrs_ltng_Program__c Where gFRS_Application__c=:appId ORDER BY CreatedDate  ASC];
        }
        catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }
    @AuraEnabled
    public static Integer checkProgramStatus(String appId){ 
        List<gFRS_Ltng_Program__c> pgmCount = new List<gFRS_Ltng_Program__c>();
        try{
            pgmCount = [SELECT Id, Name FROM gFRS_Ltng_Program__c WHERE gFRS_Application__c =: appId AND (Program_Status__c = 'Planned' OR Program_Status__c = 'Confirmed')];
            return pgmCount.size();
        }
        catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }
    //@InvocableMethod(label='Close Post Payment Task' description='Close Post Payment Task once Reconciliation is submitted.')
    @AuraEnabled
    public static void closePostPaymentTask(string appId) {
        List<gFRS_Ltng_Task__c> tasks = new List<gFRS_Ltng_Task__c>();
        try{
            tasks = [SELECT Id, Name FROM gFRS_Ltng_Task__c WHERE gFRS_Application__c =: appId AND Action_Type__c = 'Post Payment' AND Status__c = 'Open'];
            if(tasks.size() > 0){
                tasks[0].Status__c = 'Completed';
                update tasks[0];
            }
        }catch(Exception e){
            System.debug('@@@@ Error :'+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
        
    }
    @AuraEnabled
    public static Id updateTaskRecd (Id parentId, Id docId, string typOfFile, string fileName,string extension) {
        try{ 
            gFRS_Ltng_Task_Update__c objTask =new gFRS_Ltng_Task_Update__c();
            objTask.id = parentId;
            if(typOfFile=='Scope'){
                objTask.id = parentId;
                objTask.Scope_Attachment__c = docId;                
                objTask.Scope_Attachment_File_Name__c  = fileName;
                objTask.Scope_Attachment_File_Type__c  = extension;                
            }else if(typOfFile=='upload1'){
                objTask.id = parentId;
                objTask.Outcome1_Attach_Id__c = docId;                
                objTask.Outcome1_Attach_Name__c  = fileName;
                objTask.Outcome1_Attach_Type__c  = extension; 
            }else if(typOfFile=='upload2'){
                objTask.id = parentId;
                objTask.Outcome2_Attach_Id__c = docId;                
                objTask.Outcome2_Attach_Name__c  = fileName;
                objTask.Outcome2_Attach_Type__c  = extension; 
            }else if(typOfFile=='upload3'){
                objTask.id = parentId;
                objTask.Outcome3_Attach_Id__c = docId;                
                objTask.Outcome3_Attach_Name__c  = fileName;
                objTask.Outcome3_Attach_Type__c  = extension; 
            }else if(typOfFile=='upload4'){
                objTask.id = parentId;
                objTask.Outcome4_Attach_Id__c = docId;                
                objTask.Outcome4_Attach_Name__c  = fileName;
                objTask.Outcome4_Attach_Type__c  = extension; 
            }
            upsert objTask;            
            return docId;
        }catch(Exception e){
            System.debug('@@@@ Upload chunk Error :'+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }  
    
    @AuraEnabled
    public static void deleteAttachment1(Id attchId,String parentId,String att) {
        
        try{            
            //Attachment attach = [SELECT Id, name, parentId FROM Attachment WHERE Id =: attchId];
            //delete attach; 
            
            List<ContentDocument> entries = [SELECT id,Title,FileType,CreatedBy.Name,ContentSize FROM ContentDocument WHERE Id =:attchId]; 
            delete entries; 
            
            if(att=='Scope'){   
                gFRS_Ltng_Task_Update__c scopeattach = [Select id,Scope_Attachment__c,Scope_Attachment_File_Name__c,Scope_Attachment_File_Type__c From gFRS_Ltng_Task_Update__c where id=: parentId];
                scopeattach.Scope_Attachment__c='';                
                scopeattach.Scope_Attachment_File_Name__c='';
                scopeattach.Scope_Attachment_File_Type__c='';
                update scopeattach;
            }
            if(att=='upload1'){
                gFRS_Ltng_Task_Update__c objBudget = [Select id,Outcome1_Attach_Id__c,Outcome1_Attach_Name__c,Outcome1_Attach_Type__c From gFRS_Ltng_Task_Update__c where id=: parentId];
                
                objBudget.id = parentId;
                objBudget.Outcome1_Attach_Id__c ='';                
                objBudget.Outcome1_Attach_Name__c  = '';
                objBudget.Outcome1_Attach_Type__c  = '';
                upsert objBudget;
            }
            if(att=='upload2'){
                gFRS_Ltng_Task_Update__c objBudget = [Select id,Outcome2_Attach_Id__c,Outcome2_Attach_Name__c,Outcome2_Attach_Type__c From gFRS_Ltng_Task_Update__c where id=: parentId];
                
                objBudget.id = parentId;
                objBudget.Outcome2_Attach_Id__c= '';                
                objBudget.Outcome2_Attach_Name__c  ='';
                objBudget.Outcome2_Attach_Type__c  = '';
                upsert objBudget;
            }
            if(att=='upload3'){
                gFRS_Ltng_Task_Update__c objBudget = [Select id,Outcome3_Attach_Id__c,Outcome3_Attach_Name__c,Outcome3_Attach_Type__c From gFRS_Ltng_Task_Update__c where id=: parentId];
                
                objBudget.id = parentId;
                objBudget.Outcome3_Attach_Id__c = '';                
                objBudget.Outcome3_Attach_Name__c  = '';
                objBudget.Outcome3_Attach_Type__c  ='';
                upsert objBudget;
            }
            if(att=='upload4'){
                gFRS_Ltng_Task_Update__c objBudget = [Select id,Outcome4_Attach_Id__c,Outcome4_Attach_Name__c,Outcome4_Attach_Type__c From gFRS_Ltng_Task_Update__c where id=: parentId];
                
                objBudget.id = parentId;
                objBudget.Outcome4_Attach_Id__c = '';                
                objBudget.Outcome4_Attach_Name__c  = '';
                objBudget.Outcome4_Attach_Type__c  = '';
                upsert objBudget;
            }
            
        }catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
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
    public static void updateProgram1(gFRS_Ltng_Program__c gfrsprogram ){ 
         gFRS_Ltng_Program__c oldGfrsprogram=[select Id,Name,RecordTypeId,Total_Unique_Visits__c,Number_of_Completions__c,Number_of_Certificates_Issued__c,gFRS_Application__c, Program_Type__c, gFRS_End_Date__c, gFRS_Expected_number_of_attendees__c, gFRS_Expected_of_Attendees_US_Based_HCPs__c, gFRS_Nbr_of_Grand_Round_Mtg_Series_Activ__c, gFRS_Number_of_speakers_faculty__c, gFRS_Compliance_Flag__c, gFRS_Program_Type__c, gFRS_Start_Date__c, gFRS_Venue_City__c, gFRS_Secondary_program_title__c, gFRS_Venue_Name__c, gFRS_Venue_Province_Region_Territory__c, gFRS_Venue_State__c, gFRS_Venue_Type__c, gFRS_Venue_Zip_Code__c, gFRS_Web_URL__c, gFRS_Venue_Country__c, gFRS_Live_Real_time__c, gFRS_On_demand_Archived__c, gFRS_Program_Live_Subtype__c, gFRS_Program_Subtype__c, gFRS_Focus_Area__c, Venue_associated_with_this_event_program__c, Program_Status__c, gFRS_Funding_type__c, gFRS_Funding_sub_type__c, gFRS_Sub_Focus_Area__c, gFRS_Expected_number_of_patients_served__c, What_thank_you_benefits_will_be_provid__c, Is_there_an_exhibit_opportunity_price__c, Do_designated_HCPs_have_the_appropriate__c, focusArea__c, gFRS_Payment_to_a_Licensed_Physician__c, gFRS_Focus_on_STEM_education__c, gFRS_Expected_number_of_students_engaged__c, gFRS_Expected_number_of_teachers_engaged__c, gFRS_Free_and_Reduced_Lunch__c, gFRS_Fellowship_Opportunity_Publication__c, gFRS_Criteria_to_Select_a_Fellow__c, Student_impact_by_program__c, Product_being_Promoted__c, Number_of_exhibit_tables_purchasing__c, Are_there_any_other_commercial_sponsors__c, Are_any_students_impacted_by_Program__c, Financial_Assistance_Processes__c, Health_Screening_Broad_Audience__c, Event_program_geographic_location__c, Title_1_school__c, Scientific_Meeting_Broad_Audience__c, PoC_youth_students__c, Poc_teachers__c, SubFocusArea__c, How_many_attendees_do_you_expect__c from gFRS_Ltng_Program__c WHERE ID=:gfrsprogram.Id];
        Boolean ScopeChange=false;        
        if(gfrsprogram.gFRS_Start_Date__c != oldGfrsprogram.gFRS_Start_Date__c){
            ScopeChange=true;
        } else if(gfrsprogram.gFRS_End_Date__c != oldGfrsprogram.gFRS_End_Date__c){
            ScopeChange=true;
        } else if(gfrsprogram.gFRS_Venue_Name__c != oldGfrsprogram.gFRS_Venue_Name__c){
            ScopeChange=true;
        } else if(gfrsprogram.gFRS_Venue_City__c != oldGfrsprogram.gFRS_Venue_City__c){
            ScopeChange=true;
        }
        else if(gfrsprogram.gFRS_Venue_State__c != oldGfrsprogram.gFRS_Venue_State__c){
            ScopeChange=true;
        }
        else if(gfrsprogram.gFRS_Venue_Zip_Code__c != oldGfrsprogram.gFRS_Venue_Zip_Code__c){
            ScopeChange=true;
        }
        else if(gfrsprogram.gFRS_Venue_Country__c != oldGfrsprogram.gFRS_Venue_Country__c){
            ScopeChange=true;
        }
        else if(gfrsprogram.gFRS_Web_URL__c != oldGfrsprogram.gFRS_Web_URL__c){
            ScopeChange=true;
        }
        else if(gfrsprogram.Number_of_Completions__c != oldGfrsprogram.Number_of_Completions__c){
            ScopeChange=true;
        }
        else if(gfrsprogram.Total_Unique_Visits__c != oldGfrsprogram.Total_Unique_Visits__c){
            ScopeChange=true;
        }
        else if(gfrsprogram.Number_of_Certificates_Issued__c != oldGfrsprogram.Number_of_Certificates_Issued__c){
            ScopeChange=true;
        }
        try{           
            if(ScopeChange){                
                gFRS_Ltng_Application__c app=new gFRS_Ltng_Application__c();
                app.Id=gfrsprogram.gFRS_Application__c;
                app.Is_Scope_Change__c=true;
                app.Scope_Change_Date__c=system.today();
                update app;
            }
            update gfrsprogram;
        }
        catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        } 
        
    }
    
    @AuraEnabled
    public static void updateOutcome(String appId,String outcome){ 
        try{
            gFRS_Ltng_Application__c app=[select id,Are_the_outcomes_you_are_providing_premi__c from gFRS_Ltng_Application__c WHERE id=:appId];
            app.Are_the_outcomes_you_are_providing_premi__c=outcome;
            update app;
        }
        catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }
    @AuraEnabled  
    public static List<string> getMultiPicklistvalues(string objAPIName, string fieldAPIname) {        
        list<string> options = new List<string>();
        // list<picklistWrapper> returnValue = new list<picklistWrapper>();
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Map<String, Schema.SObjectField> field_map = gd.get(objAPIName.toLowerCase()).getDescribe().fields.getMap();
        // Get the list of picklist values for this field.
        list < Schema.PicklistEntry > values = field_map.get(fieldAPIname).getDescribe().getPickListValues();
        
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a: values) {           
            options.add(a.getValue());
            
        }
        system.debug('picklist values ' +options);
        return options;
        
    }
    @AuraEnabled
    public static List<gFRS_Ltng_Program_Audience_Group__c> getProgramAudience(String prgid){ 
        
        try{
            return [select Id,Name,gFRS_Program__c,Actual_Learners_with_Credit__c,Total_of_Actual_Learners__c,gFRS_Credit_Hours__c,gFRS_Credit_Type__c, gFRS_Degree__c,gFRS_Exp_Learners__c,gFRS_Expected_Learners_With_Credit__c,gFRS_Specialty__c,gFRS_Program__r.Summary__c from gFRS_Ltng_Program_Audience_Group__c Where gFRS_Program__c=:prgid ORDER BY CreatedDate ASC];
        }
        catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }
    @AuraEnabled
    public static void listUpdateProgram(List<gFRS_Ltng_Program__c> gfrsprogram){ 
        // gFRS_Ltng_Program__c gfrsprg=[select Id,Name,RecordTypeId,gFRS_Application__c, Program_Type__c, gFRS_End_Date__c, gFRS_Expected_number_of_attendees__c, gFRS_Expected_of_Attendees_US_Based_HCPs__c, gFRS_Nbr_of_Grand_Round_Mtg_Series_Activ__c, gFRS_Number_of_speakers_faculty__c, gFRS_Compliance_Flag__c, gFRS_Program_Type__c, gFRS_Start_Date__c, gFRS_Venue_City__c, gFRS_Secondary_program_title__c, gFRS_Venue_Name__c, gFRS_Venue_Province_Region_Territory__c, gFRS_Venue_State__c, gFRS_Venue_Type__c, gFRS_Venue_Zip_Code__c, gFRS_Web_URL__c, gFRS_Venue_Country__c, gFRS_Live_Real_time__c, gFRS_On_demand_Archived__c, gFRS_Program_Live_Subtype__c, gFRS_Program_Subtype__c, gFRS_Focus_Area__c, Venue_associated_with_this_event_program__c, Program_Status__c, gFRS_Funding_type__c, gFRS_Funding_sub_type__c, gFRS_Sub_Focus_Area__c, gFRS_Expected_number_of_patients_served__c, What_thank_you_benefits_will_be_provid__c, Is_there_an_exhibit_opportunity_price__c, Do_designated_HCPs_have_the_appropriate__c, focusArea__c, gFRS_Payment_to_a_Licensed_Physician__c, gFRS_Focus_on_STEM_education__c, gFRS_Expected_number_of_students_engaged__c, gFRS_Expected_number_of_teachers_engaged__c, gFRS_Free_and_Reduced_Lunch__c, gFRS_Fellowship_Opportunity_Publication__c, gFRS_Criteria_to_Select_a_Fellow__c, Student_impact_by_program__c, Product_being_Promoted__c, Number_of_exhibit_tables_purchasing__c, Are_there_any_other_commercial_sponsors__c, Are_any_students_impacted_by_Program__c, Financial_Assistance_Processes__c, Health_Screening_Broad_Audience__c, Event_program_geographic_location__c, Title_1_school__c, Scientific_Meeting_Broad_Audience__c, PoC_youth_students__c, Poc_teachers__c, SubFocusArea__c, How_many_attendees_do_you_expect__c from gFRS_Ltng_Program__c WHERE ID=:prgid];
        try{
            update gfrsprogram;
        }
        catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        } 
        
    }
    
    @AuraEnabled
    public static void updateAppRec(gFRS_Ltng_Application__c gfrsAppRecord){ 
        try{
            
            gFRS_Ltng_Util_NoShare.updateAppRecord(gfrsAppRecord);
            gFRS_Ltng_Util_NoShare.deleteTask(gfrsAppRecord.Id, 'Program Status'); 
            
            if(gfrsAppRecord.Refund_Due_Status_Update__c == 'Yes'){
                EmailTemplate template = [
                    SELECT Subject, Name, Id, Description, Body,DeveloperName
                    FROM EmailTemplate
                    WHERE DeveloperName = 'gFRS_2_0_Program_Status_Refund_Email'
                ];
                
                List<String> toAddresses = new List<String>{System.Label.gFRS_2_0_Compliance_DL_for_Refund};
                    toAddresses.add(Userinfo.getUserEmail());
                string body = template.Body;
                body = body.replace('<<Request Name>>', gfrsAppRecord.Name);
                body = body.replace('<<Program Title>>', gfrsAppRecord.Event_Program_Title__c);
                string subject;
                subject = template.Subject.replace('<<Request Name>>', gfrsAppRecord.Name);
                
                
                Messaging.SingleEmailMessage email=new Messaging.SingleEmailMessage();
                
                email.setToAddresses(toAddresses);
                email.setSubject(subject);
                email.setPlainTextBody(body);
                
                List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });  
                if(results[0].success){
                    
                    try{
                        Attachment a       = new Attachment();
                        a.ParentId         = gfrsAppRecord.Id;
                        a.ContentType = '.pdf';
                        String fileContent = '';
                        
                        fileContent +='From: '+Userinfo.getUserEmail()+'\n';
                        fileContent +='To: '+email.toAddresses+'\n';
                        
                        /* if(email.ccAddresses == null){
fileContent +='CC: \n';  
}else{
fileContent +='CC: '+email.ccAddresses+'\n';
} */
                        fileContent =fileContent.replace(')','').replace('(','');
                        fileContent +='Subject: '+email.subject+'\n\n';
                        
                        
                        if(email.plainTextBody != null){
                            fileContent += EncodingUtil.urlDecode(email.plainTextBody,'UTF-8');
                        }  
                        
                        a.Body = Blob.valueOf(fileContent);  
                        //a.Name = email.subject.replace('Genentech',emailtempName).replace(' ','_').replace('[','').replace(']','').replace(',','_').replace(':','').replace('@','at').replace('Sandbox_','')+'.txt'; 
                        a.Name = subject + '.txt'; 
                        
                        if(email.toaddresses != null){
                            a.Description='Sent by ' +Userinfo.getUserEmail();
                        }else{                  
                            a.Description='test';
                            
                        }  
                        
                        //insert a;       
                        gFRS_Ltng_Util_NoShare.saveLockedAttachment(a);
                        
                    }
                    
                    catch(Exception e){
                        system.debug('@@ Error while sending email');
                    }
                    
                }else{
                    //isSuccess = FALSE;
                }
            }
        }
        catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        } 
        
    }    
    
}