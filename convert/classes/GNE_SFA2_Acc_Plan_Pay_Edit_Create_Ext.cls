/************************************************************
*  @author: Jakub Lewandowski, Roche
*  Date: 2013-03-18
*  Description: This is a controller extension for GNE_SFA2_Acc_Plan_Pay_Edit_Create_Layout page
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Acc_Plan_Pay_Edit_Create_Ext extends GNE_SFA2_Dynamic_VF_Edit_Create { 
    public GNE_SFA2_Acc_Plan_Pay_Edit_Create_Ext(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_Acc_Plan_Pay_Layout');
        
        String accountPlan = ApexPages.currentPage().getParameters().get('objectId');
        
        if(myObject == null){
            myObject = new Account_Plan_Payer_gne__c();
        }
        
        if(accountPlan != null && accountPlan != '' && myObject.id == null){
            myObject.put('Account_Plan_gne__c', accountPlan);
        }
    }
}