/************************************************************
*  @author: Jakub Lewandowski, Roche
*  Date: 2013-01-17
*  Description: This is a controller extension for GNE_SFA2_Brand_Aff_Edit_Create_Layout page
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Brand_Aff_Edit_Create_Ext extends GNE_SFA2_Dynamic_VF_Edit_Create { 
    public GNE_SFA2_Brand_Aff_Edit_Create_Ext(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_Brand_Aff_Layout');
        
        String accountId = ApexPages.currentPage().getParameters().get('objectId');
        
        if(myObject == null){
            myObject = new Product_Metrics_vod__c();
        }

        if(accountId != null && accountId != '' && myObject.id == null){
            myObject.put('Account_vod__c', accountId);
        }
    }
}