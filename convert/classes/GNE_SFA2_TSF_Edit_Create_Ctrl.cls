/************************************************************
*  @author: Kishore Chandolu
*  Date: 2013-02-22
*  Description: This is a controller extension for GNE_SFA2_TSF_Edit_Create_Layout page
*   
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_TSF_Edit_Create_Ctrl extends GNE_SFA2_Dynamic_VF_Edit_Create{
    public GNE_SFA2_TSF_Edit_Create_Ctrl(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_TSF_Layout');
        
        if(myObject == null){
                myObject = new TSF_vod__c();
        }
    }
}