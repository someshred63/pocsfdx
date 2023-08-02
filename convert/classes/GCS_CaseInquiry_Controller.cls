/**********************************************************************
Purpose: GCS_CaseInquiry_Controller class is used to Call Intake system.
========================================================
History                                                            
-------                                                            
VERSION  AUTHOR        DATE            DETAIL                       
1.0     Raheem       20/07/2020      INITIAL DEVELOPMENT

***********************************************************************/
public class GCS_CaseInquiry_Controller {
    
    /***Description: get existing case record detials  
     * param: casId=CaseId
 **/ 
    @AuraEnabled
    public static List<case> getCaseRecord(id casId){
        return [select id,GCS_Inquiry__c,GCS_Comments__c,recordTypeId,GCS_OTN__c,GCS_Warm_Call_Transferred_To_Name__c from case where id=:casId];        
    }
  
    /***Description:get Questions and along with answers  
     * Param:Inquiry= selected Inquiry value,casId= caseId
**/
    @AuraEnabled
    public static list<QuestionWrapper> getQuestionWrappers(String inquiry, id casId){
        
        List<QuestionWrapper> questionWrapperslst = new List<QuestionWrapper>();
        
        List<GNE_CRM_CC_Question__c> getQuestions =[SELECT Id, External_Id__c, Inquiry__c, Possible_Values__c, Question__c, Type__c, Order__c, Prerequisite__c,
                                                    (select id,Case__c,Question__c,Selected_Answer__c
                                                     from COCS_Answers__r where Case__c=:casId)
                                                    FROM GNE_CRM_CC_Question__c WHERE Inquiry__c = :inquiry ORDER BY Order__c];
        
        if(getQuestions.size() > 0){
            for(GNE_CRM_CC_Question__c question : getQuestions){
                QuestionWrapper qw = new QuestionWrapper();
                qw.label=question.Question__c;
                qw.type=question.Type__c; 
                qw.questionId=question.id;
                qw.possibleValues =  new List<PicklistWrapper>();
                if(question.Type__c.equalsIgnoreCase('Dropdown') || question.Type__c.equalsIgnoreCase('Multi Select')){
                    qw.possibleValues.add(new PicklistWrapper('--None--',''));
                    for(String value :question.Possible_Values__c.split(';;;')){                   
                        qw.possibleValues.add(new PicklistWrapper(value,value));
                    }
                }
            
            if(question.Type__c =='Multi Select'){
                qw.multiselect=true;
            }
            if(question.Type__c =='Dropdown'){
                qw.dropdown=true;
            }
            if(question.Type__c =='Checkbox'){
                qw.checkbox=true;
            }
            if(question.Type__c =='Text'){
                qw.text=true;
            }
            if(question.Type__c =='Numeric'){
                qw.Numeric=true;
            }
            if(question.Type__c =='Alpha-Numeric'){
                qw.AlphaNumeric=true;
            }
            for(GCS_Answer__c ans: question.COCS_Answers__r){                
                
                if(question.Type__c.equalsIgnoreCase('Dropdown')){
                    qw.selectedvalue=ans.Selected_Answer__c;
                }
                if(question.Type__c.equalsIgnoreCase('Multi Select')){
                    qw.selectedPossibleValues =  new List<String>();
                    if(ans.Selected_Answer__c !=null)
                    for(String value :ans.Selected_Answer__c.split(';')){
                        qw.selectedPossibleValues.add(value.trim());
                    }
                    
                }
               if(question.Type__c.equalsIgnoreCase('Checkbox')){   
                    if(ans.Selected_Answer__c =='true'){
                        qw.checkedvalue=true;
                    }else{
                        qw.checkedvalue=false;
                    }
                    
               }
                if(question.Type__c.equalsIgnoreCase('text')){
                    qw.textvalue=ans.Selected_Answer__c;
                }
                if(question.Type__c.equalsIgnoreCase('Numeric')){
                    qw.numbervalue=ans.Selected_Answer__c;
                }
                if(question.Type__c.equalsIgnoreCase('Alpha-Numeric')){
                    qw.alphanumericvalue=ans.Selected_Answer__c;
                }
                
            }
            
            questionWrapperslst.add(qw);
        }
        }
      
        return questionWrapperslst;
        
    }
    /**Description:Save Questions And Answers
     * Param: cseId=CaseId, listofAns= List of All question ,case.inquiry,case.comments,case.srvalue case.warmCallvalue
   **/
    @AuraEnabled
    public static string saveQuestions(id cseId,string listofAns){
        
        Set<Id> validAnswers = new Set<Id>(); 
        map<String, Object> mapOfAns= (Map<String, Object>)JSON.deserializeUntyped(listofAns);
        system.debug('mapOfAns'+mapOfAns);
         string multiselectval='';
         string dropdownVal = String.valueOf(mapOfAns.get('dropdown'));
        string inquiry=String.valueOf(mapOfAns.get('inqiry'));
        if(String.valueOf(mapOfAns.get('multiselect')) !=null || String.valueOf(mapOfAns.get('multiselect')) !=''){
            multiselectval = String.valueOf(mapOfAns.get('multiselect'));
            multiselectval = multiselectval.replaceAll('[\\[\\](){}]','');            
        }
        
        List<GCS_Answer__c> answersList = new List<GCS_Answer__c>();
        List<case>  caseList=[select id,GCS_Inquiry__c from case where id=:cseId];
        List<GNE_CRM_CC_Question__c> getQuestions =[SELECT Id, External_Id__c, Inquiry__c, Possible_Values__c, Question__c, Type__c, Order__c, Prerequisite__c
                                                    FROM GNE_CRM_CC_Question__c WHERE Inquiry__c = :inquiry ORDER BY Order__c];
        if(getQuestions.size() > 0){
            for(GNE_CRM_CC_Question__c qw : getQuestions){
                GCS_Answer__c ans = new GCS_Answer__c();
                ans.Question__c=qw.id;
                ans.Case__c=cseId;  
                if(String.valueOf(mapOfAns.get('claimQuestion')) !=null && String.valueOf(mapOfAns.get('claimQuestion')) !=''){
                    if(qw.Type__c.equalsIgnoreCase('Dropdown') && qw.Order__c ==1){
                        ans.Selected_Answer__c = String.valueOf(mapOfAns.get('claimQuestion'));
                    } else if(qw.Type__c.equalsIgnoreCase('Dropdown') && qw.Order__c ==2){
                        ans.Selected_Answer__c = dropdownVal;                    
                    }
                }else {
                    if(qw.Type__c.equalsIgnoreCase('Dropdown')){
                        ans.Selected_Answer__c = dropdownVal;
                    }
                    
                }
                if(String.valueOf(mapOfAns.get('trackingNoRet')) !=null && String.valueOf(mapOfAns.get('trackingNoRet')) !=''){
                    if(qw.Type__c.equalsIgnoreCase('text') && qw.Order__c ==3){
                         ans.Selected_Answer__c = String.valueOf(mapOfAns.get('trackingNoRet'));
                    } else if(qw.Type__c.equalsIgnoreCase('text') && qw.Order__c ==4){                        
                        ans.Selected_Answer__c = String.valueOf(mapOfAns.get('text'));   
                     }
                }else{
                    if(qw.Type__c.equalsIgnoreCase('Text')){
                    ans.Selected_Answer__c = String.valueOf(mapOfAns.get('text'));
                   } 
                }
                if(qw.Type__c.equalsIgnoreCase('Multi Select')){
                    ans.Selected_Answer__c = multiselectval;
                } else if(qw.Type__c.equalsIgnoreCase('Checkbox')){
                    ans.Selected_Answer__c = String.valueOf(mapOfAns.get('checkbox'));
                } else if(qw.Type__c.equalsIgnoreCase('Numeric')){
                    ans.Selected_Answer__c = String.valueOf(mapOfAns.get('number'));
                } else if(qw.Type__c.equalsIgnoreCase('Alpha-Numeric')){
                    ans.Selected_Answer__c = String.valueOf(mapOfAns.get('AlphaNumeric'));
                }
                answersList.add(ans);
            }
            try{
                 upsert answersList;
            }catch(exception e){
                system.debug('exception'+e);
            }
           
            system.debug('answersList'+answersList);
        }
        
        if(answersList.size() > 0 ){
            for(GCS_Answer__c ans: answersList){
                validAnswers.add(ans.Id);
            }
            
        }
        // updating case values
        if(caseList.size() > 0){
            for(case cs : caseList){
                cs.GCS_Inquiry__c=String.valueOf(mapOfAns.get('inqiry'));
                cs.GCS_OTN__c=String.valueOf(mapOfAns.get('srvalue'));
                cs.GCS_Warm_Call_Transferred_To_Name__c=String.valueOf(mapOfAns.get('warmCallvalue'));
                cs.GCS_Comments__c=String.valueOf(mapOfAns.get('comments'));
            }
            update caseList;
        }
       //Fetching existing ansers To delete
        List<GCS_Answer__c>  answersToDelete =[select id from GCS_Answer__c WHERE Id NOT IN :validAnswers and Case__c=:cseId];
        if(answersToDelete.size() > 0){
            delete answersToDelete;
        }
        if(answersList.size()>0){
            return answersList[0].id;
        }else{
            return 'Case Inquiry Updated';
        }
        
    }
    
    public class PicklistWrapper {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public String value {get;set;}
        
        public PicklistWrapper(String label, String value){
            this.label = label;
            this.value = value;
        }
    }
    public class QuestionWrapper{
        @AuraEnabled
        public GNE_CRM_CC_Question__c questionObj {get;set;}
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public id questionId {get;set;}
        @AuraEnabled
        public String type {get;set;}
        @AuraEnabled
        public String selectedvalue {get;set;}        
        @AuraEnabled
        public boolean checkedvalue {get;set;}
        @AuraEnabled
        public String textvalue {get;set;}
        @AuraEnabled
        public String numbervalue {get;set;}
        @AuraEnabled
        public String alphanumericvalue {get;set;}
        @AuraEnabled
        public List<PicklistWrapper> possibleValues {get;set;}
        @AuraEnabled
        public List<String> selectedPossibleValues {get;set;}       
        @AuraEnabled
        public boolean multiselect {get;set;}
        @AuraEnabled
        public boolean dropdown {get;set;}
        @AuraEnabled
        public boolean checkbox {get;set;}
        @AuraEnabled
        public boolean text {get;set;}
        @AuraEnabled
        public boolean Numeric {get;set;}
        @AuraEnabled
        public boolean AlphaNumeric {get;set;}
    }
    
    
}