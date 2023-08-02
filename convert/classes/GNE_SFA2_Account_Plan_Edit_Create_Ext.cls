/************************************************************
*  @author: Jakub Lewandowski, Roche
*  Date: 2012-09-28
*  Description: This is a controller extension for GNE_SFA2_Account_Plan_Edit_Create_Layout page
*  
*  Modification History
*  Date        Name        Description
*  2012-12-13  lewandj2    New approach with configuration object
*            
*************************************************************/
public with sharing class GNE_SFA2_Account_Plan_Edit_Create_Ext extends GNE_SFA2_Dynamic_VF_Edit_Create{
    public GNE_SFA2_Account_Plan_Edit_Create_Ext(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_Account_Plan_Layout');
        
        String accountId = ApexPages.currentPage().getParameters().get('objectId');
        
        if(myObject == null){
                myObject = new Account_Plan_vod__c();
        }
        
        if(accountId != null && accountId != '' && myObject.id == null){
            myObject.put('Account_vod__c', accountId);
        }
    }
}