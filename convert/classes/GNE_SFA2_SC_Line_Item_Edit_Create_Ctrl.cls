/************************************************************
*  @author: Kishore Chandolu
*  Date: 2013-02-11
*  Description: This is a controller extension for GNE_SFA2_SC_Line_Item_Edit_Create_Layout page
*   
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_SC_Line_Item_Edit_Create_Ctrl extends GNE_SFA2_Dynamic_VF_Edit_Create{
    public GNE_SFA2_SC_Line_Item_Edit_Create_Ctrl(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_SC_Line_Item_Layout');
        
        if(myObject == null){
                myObject = new Speaker_Contract_Line_Item_gne__c();
        }
        String parentId = ApexPages.currentPage().getParameters().get('objectId');
        if(parentId != null && parentId != ''){
            myObject.put('Speaker_Contract_gne__c', parentId);
        }
    }
}