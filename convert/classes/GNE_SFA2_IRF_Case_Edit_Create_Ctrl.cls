/************************************************************
*  @author: Kishore Chandolu
*  Date: 2013-03-28
*  Description: This is a controller extension for GNE_SFA2_IRF_Related_Cases_Edit_Create_Layout
*   
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_IRF_Case_Edit_Create_Ctrl extends GNE_SFA2_Dynamic_VF_Edit_Create{
    
    public GNE_SFA2_IRF_Case_Edit_Create_Ctrl(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_IRF_Case_Layout');
        
        if(myObject == null){
                myObject = new IRF_Case_gne__c();
        }
        
        String parentId = ApexPages.currentPage().getParameters().get('objectId');
        if(parentId != null && parentId != ''){
            myObject.put('IRF_gne__c', parentId);
        }    
   }
}