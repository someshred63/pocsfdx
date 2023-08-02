/************************************************************
*  @author: Jakub Lewandowski, Roche
*  Date: 2013-05-21
*  Description: This is a controller extension for GNE_SFA2_ECurclmBureau_EdCr_Layout page
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_ECurclmBureau_EdCr_Ext extends GNE_SFA2_Dynamic_VF_Edit_Create { 
    public GNE_SFA2_ECurclmBureau_EdCr_Ext(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_EventCurclmBureau_Layout');
        
        if(myObject == null){
            myObject = new Event_Curriculum_gne__c();
        }
        
        if(myObject.id == null){
            myObject.put('OwnerId', UserInfo.getUserId());
        }
    }
}