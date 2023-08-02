public with sharing class GNE_SFA2_Questionnaire_Accounts_Ext extends GNE_SFA2_DynamicVFLoader{


   public GNE_SFA2_Questionnaire_Accounts_Ext(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_Questionnaire_Account_Layout');
         
    }
   
    public PageReference edit(){
        pagereference pageref = new pagereference('/apex/GNE_SFA2_Qstner_Acc_Edit_Create_Layout?id='+myObject.Id);
        pageref.setredirect(true);
        return pageref;
        
    }
    
  
    
    
    
}