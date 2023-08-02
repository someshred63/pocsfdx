public with sharing class GNE_SFA2_Qstner_Acc_Edit_Create_Ext extends GNE_SFA2_Dynamic_VF_Edit_Create {

    public GNE_SFA2_Qstner_Acc_Edit_Create_Ext(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_Questionnaire_Account_Layout');
        
                
        if(myObject == null){
          myObject = new QuestionnaireAccount_gne__c();
        }
        
        
    }
}