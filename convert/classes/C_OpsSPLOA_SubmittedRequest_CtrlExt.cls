public class C_OpsSPLOA_SubmittedRequest_CtrlExt {
private final C_Ops_SPLOA_Request__c request;
private ID requestId;
public List<C_Ops_SPLOA_Questionnaire_Questions__c> requestQuestionnaires;
public List<C_Ops_SPLOA_Additional_Pharmacy__c> requestAdtnlPharm;
public List<C_Ops_SPLOA_Questionnaire_Questions__c> patientSubquestions;
    public C_OpsSPLOA_SubmittedRequest_CtrlExt(ApexPages.StandardController controller) {
    PageReference curPage=ApexPages.currentPage();   
    if(curPage.getParameters()!=null) {
               requestId=curPage.getParameters().get('id');
           }  
           else requestId=controller.getRecord().id;  
           //List<C_Ops_SPLOA_Request__c > requestList=[select C_Ops_SPLOA_Product_Name__c  from C_Ops_SPLOA_Request__c where id=:requestId];

    }
public List<C_Ops_SPLOA_Questionnaire_Questions__c> getrequestQuestionnaires(){
        requestQuestionnaires=[select name, Answer__c,C_Ops_SPLOA_Request__c,Data_type__c,Parent_Question_Name__c,C_Ops_SPLOA_Question_Display_Order__c,Question_Label__c,Question_Type__c,C_Ops_SPLOA_Questionnaire__c from C_Ops_SPLOA_Questionnaire_Questions__c where C_Ops_SPLOA_Request__c =:requestId and Question_Type__c='Pharmacy Questions'];
        return requestQuestionnaires;
    }    

    public List<C_Ops_SPLOA_Additional_Pharmacy__c> getrequestAdtnlPharm(){
        requestAdtnlPharm=[select name, C_Ops_SPLOA_DEA_Number__c,Pharmacy_Name__c,C_Ops_SPLOA_Street_Address__c,C_Ops_SPLOA_Street_Address_2__c,C_Ops_SPLOA_City__c,C_Ops_SPLOA_State__c,C_Ops_SPLOA_Zip__c,C_Ops_SPLOA_Request__c from C_Ops_SPLOA_Additional_Pharmacy__c where C_Ops_SPLOA_Request__c =:requestId];
        return requestAdtnlPharm;
    }
    public List<C_Ops_SPLOA_Questionnaire_Questions__c> getpatientSubquestions(){
        patientSubquestions = [select id,name,Question_Label__c,Answer__c, (select id,name,Question_Label__c,Answer__c  from Questionnaire_SPLOA__r) from C_Ops_SPLOA_Questionnaire_Questions__c where C_Ops_SPLOA_Request__c =:requestId and Question_Type__c='Questionnaire' and C_Ops_SPLOA_Questionnaire__c=''];        
        return patientSubquestions ;        
    }
}