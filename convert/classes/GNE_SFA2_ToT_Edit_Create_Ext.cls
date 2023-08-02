/************************************************************
*  @author: Jakub Lewandowski, Roche
*  Date: 2013-01-04
*  Description: This is a controller extension for GNE_SFA2_ToT_Edit_Create_Layout page
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_ToT_Edit_Create_Ext extends GNE_SFA2_Dynamic_VF_Edit_Create { 
    public GNE_SFA2_ToT_Edit_Create_Ext(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_ToT_Layout');
        
        
        if(myObject == null){
            myObject = new Time_Off_Territory_gne__c();
        }
        
    }
    
}