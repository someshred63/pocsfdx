/************************************************************
*  @author: Kishore Chandolu
*  Date: 2013-02-10
*  Description: This is a controller extension for GNE_SFA2_CModule_Edit_Create_Layout page
*   
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_CModule_Edit_Create_Ctrl extends GNE_SFA2_Dynamic_VF_Edit_Create{
    public GNE_SFA2_CModule_Edit_Create_Ctrl(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_CModule_Layout');
        
        if(myObject == null){
                myObject = new Curriculum_Module_gne__c();
        }
        String parentId = ApexPages.currentPage().getParameters().get('objectId');
        if(parentId != null && parentId != ''){
            myObject.put('Event_Curriculum_gne__c', parentId);
        }
    }
}