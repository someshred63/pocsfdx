public class gFRS_QuestionsEvaluationCntrl {
@AuraEnabled
    public static gFRS_Ltng_Application__c fetchFundingReqDetails(String reqId){
        Id recId = Id.valueof(reqId);
        system.debug('Application Id is : '+recId);
        gFRS_Ltng_Application__c appRec = new gFRS_Ltng_Application__c();
        try{
        appRec = [SELECT Id, Name, What_are_you_seeking_funding_for__c, Target_audience__c, Organization__c, Information_Needed__c,
                  Sister_Parent_Org_Strategic_Promo_Mktg__c, Firewall_for_Strategic_Promo_Mktg__c, Approved_Amount__c,
                  Is_this_program_accredited__c, Org_the_Accreditor__c, Content_Development__c, Event_Program_Type__c,
                  Requested_Amount__c, Event_Program_Title__c, Therapeutic_Area__c, Disease_State__c,
                  Please_Specify_If_Disease_State_Other__c, Support_Purpose_Program_Description__c, Benefits_Exchanged_for_Funding__c,
                  Clinical_Practice_Guideline_Development__c, Associated_clinical_practice_guidelines__c,
                  Primary_Audience_Description__c, Addressed_by_this_Program_Initiative__c, Program_Objectives__c, Outcome_levels_to_be_achieved__c,
                  Other_Commercial_Supporters__c, If_known_List_Other_Supporters__c, Resubmission_of_Previous_Request__c, Resubmission_Request_Name__c,
                  Secondary_Invitations_BRC_s_Help_Request__c, Is_there_an_exhibit_opportunity_for_this__c, External_Tracking_Code__c, 
                  Opt_In_Process_for_Enduring_Materials__c, If_Yes_Please_Describe_Opt_In_Process__c, Will_You_be_Working_With_a_third_Party__c,Total_Overall_Budget__c,
                  Evaluation_Methodology__c, Unrestricted_Support_Request__c, Thank_You_Benifits__c, Non_Charitable_Amount__c,
                  Record_Type_Name__c, Print_Deadline__c, Print_Deadline_Date__c ,Funding_Sub_Type__c,Invite_Code__c,Focus_on_equity__c,Focus_Area__c,
                  Program_Start_Date_Min__c,Program_End_Date_max__c,Free_or_Reduced_Lunch__c,Number_of_Patients__c,Teacher_Identification_PoC__c,Teachers_Served__c,Number_of_Attendees__c,
                  Youth_Student_Identification_PoC__c,Youth_Students_Served__c,Student_impact_people_first_generation__c,Student_impact_people_of_color__c,Program_Evaluation_Que_info__c FROM gFRS_Ltng_Application__c WHERE Id =: recId];
       				 system.debug('Application record is : '+appRec);
        return appRec;
    }
       catch(Exception e){ 
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        } 
    } 
    
    @AuraEnabled  
    public static List<string> getPicklistvalues(string objAPIName, string fieldAPIname) {        
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
    public static gFRS_Ltng_Task_Update__c saveEvaluationRecd(String reqId ,gFRS_Ltng_Task_Update__c objEvaluation){
        system.debug('Application Id is : ' +reqId); 
        if(objEvaluation.gFRS_Application__c!= null ||objEvaluation.gFRS_Application__c!=''){
            objEvaluation.gFRS_Application__c = reqId;  
        }else{
            objEvaluation.gFRS_Application__c = reqId;
        }        
        try{
            String recordId = gFRS_Ltng_Util_NoShare.createEvulationtask(objEvaluation);            
            return [Select Id,actual_number_served__c,CMS_Covered_Recipient__c,Equity_and_Inclusion_Focus__c,Explain_how_Equity_and_Inclusion__c,Explain_why_not_Equity_and_Inclusion__c,
                    Free_or_Reduced_Lunch_Actual__c,Key_Learnings__c,Key_Highlights_Milestones__c,Number_of_Attendees_Actual__c,Number_of_Patients_Actual__c,
                    Teacher_Identification_PoC_Actual__c,Teachers_Served_Actual__c,Youth_Student_Identification_PoC_Act__c,Youth_Students_Served_Actual__c,
                    Remaining_Grant_Funds__c,Grant_Activity_Sustained__c,Published_Stories_or_Announcements__c,Student_impact_people_first_gen_Actual__c,Actual_Student_impact_people_of_color__c,Evaluation_Comments__c from gFRS_Ltng_Task_Update__c 
                    Where Id=:recordId];
        }
        catch(exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            system.debug('auraExceptionObj'+auraExceptionObj);
            throw auraExceptionObj; 
            
        }
        
    }
    
    @AuraEnabled
    public static gFRS_Ltng_Task_Update__c fetchEvaluationobjrec(String reqId){
        system.debug('Application Id is : ' +reqId);
        Id recId = Id.valueof(reqId); 
        gFRS_Ltng_Task_Update__c objTask = new gFRS_Ltng_Task_Update__c();
       list<gFRS_Ltng_Task_Update__c> objTaskList = new list<gFRS_Ltng_Task_Update__c>();
        try{            
            objTaskList = [Select id,Name,actual_number_served__c,CMS_Covered_Recipient__c,Equity_and_Inclusion_Focus__c,Explain_how_Equity_and_Inclusion__c,Explain_why_not_Equity_and_Inclusion__c,
                    Free_or_Reduced_Lunch_Actual__c,Key_Learnings__c,Key_Highlights_Milestones__c,Number_of_Attendees_Actual__c,Number_of_Patients_Actual__c,
                    Teacher_Identification_PoC_Actual__c,Teachers_Served_Actual__c,Youth_Student_Identification_PoC_Act__c,Youth_Students_Served_Actual__c,Total_Amount_Used__c,Incidental_benefits__c,Good_faith_estimate_of_the_value__c,
                    Remaining_Grant_Funds__c,Grant_Activity_Sustained__c,Published_Stories_or_Announcements__c,Evaluation_Research_Summary_File_Type__c,Evaluation_Research_Summary_File_Name__c,Evaluation_Research_Summary__c,Student_impact_people_first_gen_Actual__c,
                    Actual_Student_impact_people_of_color__c,gFRS_Application__c,Sun_Shine_File_Id__c,Sun_Shine_FileName__c,Sun_Shine_File_Type__c,Evaluation_Comments__c from gFRS_Ltng_Task_Update__c 
                    Where gFRS_Application__c=:recId and Name='Evaluation'];
            objTask = objTaskList[0];
            return   objTask;         
        }
        catch(exception e){
            system.debug('@@@:::Msg:::'+e.getMessage());
            system.debug('@@@LineNum:::'+e.getLineNumber());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            system.debug('auraExceptionObj'+auraExceptionObj);
            throw auraExceptionObj; 
            
        }
        
    }
    
    @AuraEnabled
    public static List<String> fetchEvaluationFieds( String reqId){
        gFRS_Ltng_Application__c appRec = new gFRS_Ltng_Application__c();
        appRec = [SELECT Id, Name,Record_Type_Name__c  FROM gFRS_Ltng_Application__c WHERE Id =: reqId];
        system.debug('Application record is : '+appRec);
        list<String> fieldslst = new list<String>();
        for ( Schema.FieldSetMember f :  SObjectType.gFRS_Ltng_Task_Update__c.FieldSets.EvaluationFields.getFields() ) {  
            fieldslst.add(f.getFieldPath());
            system.debug( f.getFieldPath() );  
            
        }  
        if(appRec.Record_Type_Name__c =='Community Giving' || appRec.Record_Type_Name__c=='Education Focused Giving K-12' || appRec.Record_Type_Name__c=='Patient and Health Focused Giving'){
            for (Integer i = (fieldslst.size()-1) ; i>= 0 ; i--){
                String s = fieldslst[i];
                if(s.contains('Sunshine_Disclosure_Report__c')){
                    fieldslst.remove(i);
                }else if(s.contains('CMS_Covered_Recipient__c')){
                    fieldslst.remove(i);
                }
            } 
            
        }
        return fieldslst;
        
    }
    @AuraEnabled
    public static Id updateTaskRecd (Id parentId, Id docId, string typOfFile, string fileName,string extension) {
        try{ 
            gFRS_Ltng_Task_Update__c objTask =new gFRS_Ltng_Task_Update__c();
            objTask.id = parentId;
            if(typOfFile=='attachment1'){
                objTask.Evaluation_Research_Summary__c = docId;                
                objTask.Evaluation_Research_Summary_File_Name__c  = fileName;
                objTask.Evaluation_Research_Summary_File_Type__c  = extension;
            }else if(typOfFile=='attachment2'){
                objTask.Sun_Shine_File_Id__c = docId;                
                objTask.Sun_Shine_FileName__c  = fileName;
                objTask.Sun_Shine_File_Type__c  = extension;  
            }
            gFRS_Ltng_Util_NoShare.createEvulationtask(objTask);            
            return docId;
        }catch(Exception e){
            System.debug('@@@@ Upload chunk Error :'+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }
    
    @AuraEnabled
    public static void deleteAttachment(Id attchId,String attchmentName, Id parentId) {
        try{            
            
            List<ContentDocument> entries = [SELECT id,Title,FileType,CreatedBy.Name,ContentSize FROM ContentDocument WHERE Id =:attchId]; 
            delete entries;            
            
            gFRS_Ltng_Task_Update__c objTask = [Select id,Evaluation_Research_Summary_File_Type__c,Evaluation_Research_Summary__c,Evaluation_Research_Summary_File_Name__c,Sun_Shine_File_Id__c,Sun_Shine_FileName__c,Sun_Shine_File_Type__c From gFRS_Ltng_Task_Update__c
                                                     where id=: parentId];
            
            
            objTask.id = parentId;
            if(attchmentName=='Attachment1'){
                objTask.Evaluation_Research_Summary_File_Type__c = '';
                objTask.Evaluation_Research_Summary__c = '';
                objTask.Evaluation_Research_Summary_File_Name__c = '';
            }
            else if(attchmentName=='Attachment2'){
                objTask.Sun_Shine_File_Id__c = '';
                objTask.Sun_Shine_FileName__c = '';
                objTask.Sun_Shine_File_Type__c = '';
            }
            gFRS_Ltng_Util_NoShare.createEvulationtask(objTask);
            //upsert objBudget;
            
        }catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    } 
}