/************************************************************
*  @author: Jakub Lewandowski, Roche
*  Date: 2013-02-18
*  Description: This is a controller extension for GNE_SFA2_ToT_Day_Edit_Create_Layout page
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_ToT_Day_Edit_Create_Ext extends GNE_SFA2_Dynamic_VF_Edit_Create{
    public GNE_SFA2_ToT_Day_Edit_Create_Ext(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_ToT_Day_Layout');
        
        String tot = ApexPages.currentPage().getParameters().get('objectId');
        
        if(myObject == null){
                myObject = new Time_off_Territory_Day_gne__c();
        }
        
        if(tot != null && tot != '' && myObject.id == null){
            myObject.put('Time_Off_Territory_gne__c', tot);
        }
    }
}