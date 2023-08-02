/************************************************************
*  @author: Sreedhar Karukonda
*  Date: 1/4/2013
*  Description: This class GNE_SFA2_Survey_Adv_Future handles all future calls on Survey_gne__c object on DML operations
*  This class is being used in GNE_SFA2_Survey_Trigger trigger
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/

public with sharing class GNE_SFA2_Survey_Adv_Future {
	// On Before Update method
    public static void OnBeforeUpdate (List<Survey_gne__c> oldSurveysList,  List<Survey_gne__c> newSurveysList){
        setLucentisSegment(oldSurveysList, newSurveysList, false);
    }
    
    // On after Delete method
    public static void OnAfterDelete (List<Survey_gne__c> oldSurveysList,  List<Survey_gne__c> newSurveysList){
        setLucentisSegment(oldSurveysList, newSurveysList, true);
    }
    
	//implemeted based on trigger GNE_ON_SURVEY_UPDATE on Survey_gne__c (before update,after delete)
	private static void setLucentisSegment(List< Survey_gne__c> OldSurveysList, List<Survey_gne__c> newSurveysList, boolean isDelete){
		//Run below method for Lucentis only Req. 2595
	    if(Util.isLucentis){
	       handleSurveyOnUpdate(OldSurveysList, newSurveysList, isDelete);
	    }
	}
	

    static Integer LucentisQuesCount = 6;
    @future
    static void lucentisSegmentFromSurvey (List<String> QuesIds, List<String> acctIds) {
        //Added accountAndSegmentMap to create collection to handle brand affiliation in bulk
        Map<id, String> accountAndSegmentMap = new Map<id, String>();
               
        for (integer surveyCnt = 0; SurveyCnt < QuesIds.Size(); surveyCnt ++){
           Survey_gne__c lastSurvey = getLastSurvey(QuesIds[surveyCnt], acctIds[surveyCnt]);
           String segment = getLucentisSegment(lastSurvey );
           accountAndSegmentMap.put(acctIds[surveyCnt], segment);
        }
        if(accountAndSegmentMap.size() > 0 ){
        	setLucentisSegmentBulk(accountAndSegmentMap);
        }
    }/*lucentisSegmentFromSurvey */
    
    private static boolean IsValidSurveyResponse(String SurvId){
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
    
    private static void setLucentisSegmentBulk(Map<Id, String> accountSegmentMap) {
         // Get Lucentis AMD
         String LucentisName = 'Lucentis - AMD';
         List<Product_vod__c> prodList = [Select Id from product_vod__c where name = :LucentisName];
         String ProductId;
         if(prodList.size() > 0){
         	ProductId = prodList[0].Id;
         }else{
         	return;
         }
         List<Product_Metrics_vod__c> updatePMVList = new List<Product_Metrics_vod__c>();
         List<Product_Metrics_vod__c> insertPMVList = new List<Product_Metrics_vod__c>();
         Set<Id> accountIds = accountSegmentMap.keySet();
         List<Product_Metrics_vod__c> brandAffil = [Select Id, name, Segment_Lucentis_gne__c, Account_vod__c from Product_Metrics_vod__c 
                                                    where Account_vod__c in : accountIds and Products_vod__c = :ProductId
                                                    order by Account_vod__c, lastmodifieddate desc];
         Id previousAccontHandled = null;
         for(Product_Metrics_vod__c pmv : brandAffil){
         	if(previousAccontHandled != pmv.Account_vod__c){
         		String segment = accountSegmentMap.get(pmv.Account_vod__c);
         		previousAccontHandled = pmv.Account_vod__c;
         		accountSegmentMap.remove(pmv.Account_vod__c);
         		pmv.Segment_Lucentis_gne__c =segment;
         		updatePMVList.add(pmv);
         	}
         }
         for(Id accId: accountSegmentMap.keySet()){
         	Product_Metrics_vod__c pmv = new Product_Metrics_vod__c();
         	pmv.Account_vod__c = accId;
	        pmv.Products_vod__c = ProductId;
	        pmv.Segment_Lucentis_gne__c =accountSegmentMap.get(accId);
	        insertPMVList.add(pmv);
         }
         try{
         	if(updatePMVList.size() > 0) update updatePMVList;
         }catch(Exception e){
         	Error_Log_gne__c errLog = new Error_Log_gne__c(Object_Name__c = 'Product_Metrics_vod__c', 
                                               Error_Level_gne__c = 'Low',
                                               Snippet_Name__c = 'UPD Product Metrics', 
                                               Code_Type__c = 'Apex Class',
                                               Error_Description__c = e.getMessage(), 
                                               User_Name__c = USERINFO.getUserName());
           insert errLog; 
         }
         
         try{
         	if(insertPMVList.size() > 0) insert insertPMVList;
         }catch(Exception e){
         	Error_Log_gne__c errLog = new Error_Log_gne__c(Object_Name__c = 'Product_Metrics_vod__c', 
                                               Error_Level_gne__c = 'Low',
                                               Snippet_Name__c = 'UPD Product Metrics', 
                                               Code_Type__c = 'Apex Class',
                                               Error_Description__c = e.getMessage(), 
                                               User_Name__c = USERINFO.getUserName());
           insert errLog; 
         }
    }/* setLucentisSegmentBulk() */
        
    private static String getLucentisSegment(Survey_gne__c surv){
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
                } catch (Exception e) {
                	Error_Log_gne__c errLog = new Error_Log_gne__c(Object_Name__c = 'Survey_gne__c', 
                                               Error_Level_gne__c = 'Low',
                                               Snippet_Name__c = 'Survey_gne__c', 
                                               Code_Type__c = 'Apex Class',
                                               Error_Description__c = e.getMessage(), 
                                               User_Name__c = USERINFO.getUserName());
           			insert errLog; 
                }
                //Segment= 'Failed:' + quesId;
                                                             
        
                if ( SegmentValue != null ) {
                    if ( SegmentValue.Segment_value_gne__c != null ) 
                        Segment = SegmentValue.Segment_value_gne__c;
                }
            }  
        } 
        catch (Exception e){
        	Error_Log_gne__c errLog = new Error_Log_gne__c(Object_Name__c = 'Survey_gne__c', 
                                               Error_Level_gne__c = 'Low',
                                               Snippet_Name__c = 'Survey_gne__c', 
                                               Code_Type__c = 'Apex Class',
                                               Error_Description__c = e.getMessage(), 
                                               User_Name__c = USERINFO.getUserName());
           insert errLog; 
        }   
        return Segment;
    }/* getLucentisSegment() */
                
    private static Survey_gne__c getLastsurvey(String QuesId, String acctId)  {
    	
        List<Survey_gne__c> allSurveys = [Select Questionnaire_gne__c, Name, LastModifiedDate, Id, Account__c From Survey_gne__c  
                                            where Questionnaire_gne__c = :QuesId
                                            and Account__c = :acctId
                                            order by createddate desc];
        Survey_gne__c lastSurvey = null;
        String segment = 'Q:'+ QuesId + 'A:' + acctId + 'size:' +allSurveys.size();
        System.debug('segment : ' + segment);
        
        for (Survey_gne__c survey: allSurveys)  {
              try
              {
                  String SurvId =String.ValueOf(survey.Id);
                  if (IsValidSurveyResponse(SurvId) == true){
                     lastSurvey = survey;
                     segment += 'Successid:' + SurvId + ':';
                     break;
                  }
              }
              catch (Exception e){
               segment += e.getMessage();
               Map<Id, String> temp = new Map<Id, String>();
               temp.put(acctId, segment);
               setLucentisSegmentBulk(temp);
              }
        }
        return lastSurvey; 
    }
    
    private static boolean handleSurveyOnUpdate(Survey_gne__c[] oldSurveys, Survey_gne__c[] newSurveys, Boolean isDelete) {
        System.debug('isDelete: ' + isDelete);
        String LucPredProf = 'Lucentis Predictive Profiling';
        Survey_gne__c[] surveys = isDelete ? oldSurveys : newSurveys;
        boolean handlingSurvey = false;
        List<String> surveyIds = new List<String>();
        List<String> accountIds = new List<String>();
        List<String> relatedSurveyIds = new List<String>();
        for(Survey_gne__c survey:  surveys){
            if(survey.Questionnaire_gne__c != null){
                relatedSurveyIds.add(survey.Id);
            } 
        }
        System.debug('relatedSurveyIds.size(): ' + relatedSurveyIds.size());
        Map<Id,Survey_gne__c> mapSurvey_qType = new Map<Id,Survey_gne__c>([select Id, Questionnaire_gne__r.Type_gne__c from Survey_gne__c where Id in :relatedSurveyIds]);
        String qType;
        System.debug('mapSurvey_qType.size(): ' + mapSurvey_qType.size());
        System.debug('mapSurvey_qType: ' + mapSurvey_qType);
        for(Survey_gne__c survey:  surveys){
            if(mapSurvey_qType.containsKey(survey.Id) && mapSurvey_qType.get(survey.Id).Questionnaire_gne__r != null && mapSurvey_qType.get(survey.Id).Questionnaire_gne__r.Type_gne__c != null){
                qType = mapSurvey_qType.get(survey.Id).Questionnaire_gne__r.Type_gne__c;
                System.debug('qType: ' + qType);
                if (qType != LucPredProf)
                   continue;
                surveyIds.add(survey.Questionnaire_gne__c);
                accountIds.add(survey.Account__c);
                handlingSurvey =true;
            }
            
        }/* for */
        if (handlingSurvey){
             lucentisSegmentFromSurvey(surveyIds, accountIds);  
    	}
         return handlingSurvey ;
    }/* handleSurveyOnUpdate() */

}