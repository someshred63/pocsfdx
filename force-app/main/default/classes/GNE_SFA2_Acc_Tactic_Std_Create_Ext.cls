/************************************************************
*  @author: Jakub Lewandowski, Roche
*  Date: 2013-04-27
*  Description: This is a controller extension for GNE_SFA2_Acc_Tactic_Std_Create_Layout page
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Acc_Tactic_Std_Create_Ext extends GNE_SFA2_Dynamic_VF_Edit_Create { 
    public GNE_SFA2_Acc_Tactic_Std_Create_Ext(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_Account_Tactic_Layout');
        
        if(myObject == null){
            myObject = new Account_Tactic_vod__c();
        }
        String parentId = ApexPages.currentPage().getParameters().get('objectId');
        if(parentId != null && parentId != '' && myObject.id == null){        
            myObject.put('Account_Plan_vod__c', parentId);

        }    
    }
}