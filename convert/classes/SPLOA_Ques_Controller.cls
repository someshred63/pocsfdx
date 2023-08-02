public class SPLOA_Ques_Controller {
     public void updatemainreq(List<C_Ops_SPLOA_Questionnaire_Questions__c> newList){
             Set<Id> reqStageIds = new Set<Id>();
         Set<Id> reqIds = new Set<Id>();
        for(C_Ops_SPLOA_Questionnaire_Questions__c ques :newList){
         if(ques.C_Ops_IAP_Requests_Stage__c != null && ques.Question_Type__c == 'Pharmacy Questions'  && ques.C_Ops_SPLOA_Questionnaire__c == NULL ){
               reqStageIds.add(ques.C_Ops_IAP_Requests_Stage__c);        
        	 }
         if(ques.C_Ops_SPLOA_Request__c != null && ques.C_Ops_IAP_Requests_Stage__c != null && ques.Question_Type__c == 'Pharmacy Questions'  && ques.C_Ops_SPLOA_Questionnaire__c == NULL ){
               reqIds.add(ques.C_Ops_SPLOA_Request__c);        
        	 }    
         }
        List<C_Ops_SPLOA_Questionnaire_Questions__c> quesList = new List<C_Ops_SPLOA_Questionnaire_Questions__c>([SELECT Id ,C_Ops_SPLOA_Request__c FROM C_Ops_SPLOA_Questionnaire_Questions__c WHERE C_Ops_SPLOA_Request__c =: reqIds AND C_Ops_IAP_Requests_Stage__c = NULL  ]);
    
         if(quesList.size()>0){
                    for(C_Ops_SPLOA_Questionnaire_Questions__c quesques: quesList){
                        if(quesques.C_Ops_SPLOA_Request__c != null)
                            quesques.C_Ops_SPLOA_Request__c = null;
                    }
                  
            Update quesList;

         }
                    

    for(C_Ops_SPLOA_Questionnaire_Questions__c ques :newList){
         if(ques.C_Ops_SPLOA_Request__c != null && ques.C_Ops_IAP_Requests_Stage__c != null  ){
               ques.C_Ops_IAP_Requests_Stage__c = null;       
        	 }
         }
         if(quesList.size()>0){ Delete quesList;}
     }

}