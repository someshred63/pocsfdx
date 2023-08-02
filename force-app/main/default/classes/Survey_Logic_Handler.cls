public without sharing class Survey_Logic_Handler {

    static Integer LucentisQuesCount = 6;
    
    Survey_Logic_Handler(){
    }
    
    @future
    static void lucentisSegmentFromSurvey (List<String> QuesIds, List<String> acctIds) {
        
        Survey_Logic_Handler hndlr = new Survey_Logic_Handler();
               
        for (integer surveyCnt = 0; SurveyCnt < QuesIds.Size(); surveyCnt ++){
           Survey_gne__c lastSurvey = hndlr.getLastSurvey(QuesIds[surveyCnt], acctIds[surveyCnt]);
           String segment = hndlr.getLucentisSegment(lastSurvey );
           hndlr.setLucentisSegment(acctIds[surveyCnt], segment);
        }
        
    }/*lucentisSegmentFromSurvey */
    
    static boolean IsValidSurveyResponse(String SurvId){
        boolean IsValid = true;
        List<Survey_Response_gne__c> resps = [Select Id, Name, Response_Score_gne__c  from Survey_Response_gne__c 
                                                         where  Survey_gne__c = :SurvId];
        if (resps.Size() != LucentisQuesCount)
            return false;
         
        for (integer i=0 ; i<resps.size(); i++){
            if (resps[i].Response_Score_gne__c == null){
                    isValid = false;
                    break;
                }
        }
     return isValid;
    }
    
    
    boolean setLucentisSegment(string AcctId, String segment) {
 
         // Get Lucentis AMD
         String LucentisName = 'Lucentis-AMD';
         Product_vod__c prodList = [Select Id from product_vod__c where name = :LucentisName];
         String ProductId;
         ProductId = prodList.Id;
         
        List<Product_Metrics_vod__c> brandAffil = [Select Id, name, Segment_Lucentis_gne__c from Product_Metrics_vod__c 
                                                    where Account_vod__c = :AcctId and Products_vod__c = :ProductId
                                                    order by lastmodifieddate desc];

        if (brandAffil.size()==0)
        {
          Product_Metrics_vod__c pmv = new Product_Metrics_vod__c();
          pmv.Account_vod__c = AcctId;
          pmv.Products_vod__c = ProductId;
          pmv.Segment_Lucentis_gne__c =segment;
          try {
              insert (pmv);
          } catch (Exception e) {
                //Segment= 'Failed:' + quesId;
            }   
         }
         else
         {
                brandAffil[0].Segment_Lucentis_gne__c = segment;//string(segment);
                update brandAffil[0]; 
                try {
                  update brandAffil[0]; 
                } catch (Exception e) {
                  } 
         }
                
        return true;
    }/* setLucentisSegment() */
        
    String getLucentisSegment(Survey_gne__c surv){

        String SurveyResponse = '';
        String Segment = 'Not Assigned';
        try {
            List<Question_gne__c> questions = [select Id, Name from Question_gne__c 
                                            where Questionnaire_gne__c = :surv.Questionnaire_gne__c
                                            order by position_gne__c asc];
                         
            String quesId = 'SurveyId:' +surv.Id +'|';
            for(Integer quesCnt = 0; quesCnt<questions.size(); quesCnt++){

                Survey_Response_gne__c thisSurv = [Select Id, Name, Response_Score_gne__c  from Survey_Response_gne__c 
                                                where question_gne__c = :questions[quesCnt].Id and Survey_gne__c = :surv.Id
                                                order by position_gne__c asc];
                //ROSS - IT RETURNS NULL VALUE SOME REASON, 
                //SurveyResponse +=  quesCnt>0 ? ',' : '' + String.valueOf(Integer.valueOf(thisSurv.Response_Score_gne__c));                  
                if(SurveyResponse != '') 
                SurveyResponse += ',';
           
                if (thisSurv.Response_Score_gne__c != null)
                        SurveyResponse +=  thisSurv.Response_Score_gne__c;
                quesId += 'QId:' + questions[quesCnt].Id + '&v:' + thisSurv.Response_Score_gne__c;
             }/* for */
        
             if ( SurveyResponse != '') { 
                Survey_LookUp_gne__c SegmentValue = null;
                try {         
                    SegmentValue = [Select Segment_value_gne__c,Survey_User_Response_gne__c from Survey_lookup_gne__c
                                                     where Survey_User_Response_gne__c =:SurveyResponse];
                } catch (Exception e) {}
                //Segment= 'Failed:' + quesId;
                                                             
        
                if ( SegmentValue != null ) {
                    if ( SegmentValue.Segment_value_gne__c != null ) 
                        Segment = SegmentValue.Segment_value_gne__c;
                }
            }  
        } 
        catch (Exception e){}   
        
                     
        return Segment;
        
          
    }/* getLucentisSegment() */
                
    Survey_gne__c getLastsurvey(String QuesId, String acctId)  {
        // Make sure this is the last survey by this name for this user
        List<Survey_gne__c> allSurveys = [Select Questionnaire_gne__c, Name, LastModifiedDate, Id, Account__c From Survey_gne__c  
                                            where Questionnaire_gne__c = :QuesId
                                            and Account__c = :acctId
                                            order by createddate desc];
        // Determine most recent Survey with survey response
        Survey_gne__c lastSurvey = null;
        String segment = 'Q:'+ QuesId + 'A:' + acctId + 'size:' +allSurveys.size();
        
        //segment +=allSurveys[5].Id;
        //if  (allSurveys.size()==0){
        //    segment += ' Zero record';
        //   setLucentisSegment(acctId, segment);
        //}
        
        for (integer i=0; i<= allSurveys.size(); i++)  {
            //Check here whether valid survey or not?
              //
              try
              {
                  String SurvId =String.ValueOf(allSurveys[i].Id);
                  //segment +=  's'+ SurvId ;//allSurveys[i].Id;
                  if (IsValidSurveyResponse(SurvId) == true){
                     lastSurvey = allSurveys[i];
                     segment += 'Successid:' + SurvId + ':';
                     break;
                  }
              }
              catch (Exception e){
               segment += e.getMessage();
                setLucentisSegment(acctId, segment);
               }
        }
        return lastSurvey; 
    }
    
    public static boolean handleSurveyOnUpdate(Survey_gne__c[] oldSurveys, Survey_gne__c[] newSurveys, Boolean isDelete, Boolean isInsert) {
     
        System.debug('isDelete: ' + isDelete);
        System.debug('isInsert: ' + isInsert);
        String LucPredProf = 'Lucentis Predictive Profiling';
        Survey_gne__c[] surveys = isDelete ? oldSurveys : newSurveys;
        boolean handlingSurvey = false;
        //surveys[0].title_gne__C ='Inside update';

         // No response associated with newly created survey.
         if (isInsert){
          String SurvId =newSurveys[0].Id;
          if (IsValidSurveyResponse(SurvId) == false)
              return handlingSurvey;
         }
         
        Integer countSurveys =isDelete ? oldSurveys.Size() : newSurveys.Size();
        List<String> surveyIds = new List<String>();
        List<String> accountIds = new List<String>();
        List<String> relatedSurveyIds = new List<String>();
        for(integer i=0; i<countSurveys; i++){
            if(surveys[i].Questionnaire_gne__c != null){
                relatedSurveyIds.add(surveys[i].Id);
            }
        }
        System.debug('relatedSurveyIds.size(): ' + relatedSurveyIds.size());
        Map<Id,Survey_gne__c> mapSurvey_qType = new Map<Id,Survey_gne__c>([select Id, Questionnaire_gne__r.Type_gne__c from Survey_gne__c where Id in :relatedSurveyIds]);
        String qType;
        System.debug('mapSurvey_qType.size(): ' + mapSurvey_qType.size());
        System.debug('mapSurvey_qType: ' + mapSurvey_qType);
        
        for(integer i=0; i<countSurveys; i++){
            if(mapSurvey_qType.containsKey(surveys[i].Id) && mapSurvey_qType.get(surveys[i].Id).Questionnaire_gne__r != null && mapSurvey_qType.get(surveys[i].Id).Questionnaire_gne__r.Type_gne__c != null){
                qType = mapSurvey_qType.get(surveys[i].Id).Questionnaire_gne__r.Type_gne__c;
                System.debug('qType: ' + qType);
                if (qType != LucPredProf)
                   continue;
                surveyIds.add(surveys[i].Questionnaire_gne__c);
                accountIds.add(surveys [i].Account__c);
                handlingSurvey =true;
            }
            
        }/* for */
        
        // If this is Lucentis Predictive Profiling Survey calculate and set Segment for account
         if (handlingSurvey){

             lucentisSegmentFromSurvey(surveyIds, accountIds);  
    }
         return handlingSurvey ;
       
        
        
    }/* handleSurveyOnUpdate() */
 }