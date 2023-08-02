public with sharing class GNE_SFA2_Questionnaire_Ext extends GNE_SFA2_DynamicVFLoader {

    public GNE_SFA2_Questionnaire_Ext(ApexPages.StandardController controller) {
        super(controller,'/apex/GNE_SFA2_Questionnaire_Layout');
    }
    
    
    public PageReference AnalyzeClick(){
        Pagereference pageref = new pagereference('/apex/GNE_SFA2_SurveyGraph?Id='+myObject.Id);
        //pageref.getParameters().put('retURL', myObject.Id);
        pageref.setredirect(true);
        return pageref;
    }
    
    public PageReference edit(){
        Pagereference pageref = new pagereference('/apex/GNE_SFA2_Qstner_Edit_Create_Layout?id='+myObject.Id);
        pageref.setredirect(true);
        return pageref;
        return null;
    }
    
    public PageReference addQuestionnaireAccounts(){
        String sbcURL = '/apex/GNE_SFA2_AssignTerritories?objectId='+myObject.id;
        pagereference pageref = new pagereference(sbcURL);
        pageref.setredirect(true);
        return pageref;
    }

     //relatedList Custom Buttons
     public override PageReference callMethod(String methodName){
        if('addQuestionnaireAccounts'.compareTo(methodName) == 0){
            return addQuestionnaireAccounts(); 
        }
        return super.callMethod(methodName);      
     }
}