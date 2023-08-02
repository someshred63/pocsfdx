/************************************************************
*  @author: Jakub Lewandowski, Roche
*  Date: 2013-03-27
*  Description: This is a controller extension for GNE_SFA2_Tumor_Board_Edit_Create_Layout page
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Tumor_Board_Edit_Create_Ext extends GNE_SFA2_Dynamic_VF_Edit_Create { 
    public GNE_SFA2_Tumor_Board_Edit_Create_Ext(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_Tumor_Board_Layout');
        
        String objectId = ApexPages.currentPage().getParameters().get('objectId');    
            
        if(myObject == null){
            myObject = new Tumor_Board_gne__c(); 
        }
        if(objectId != null && objectId != '' && myObject.id == null){
                myObject.put('Account_gne__c', objectId);
                myObject.put('OwnerId', UserInfo.getUserId());
        }        
    }
}