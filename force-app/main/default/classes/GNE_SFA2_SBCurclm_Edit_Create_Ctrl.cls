/************************************************************
*  @author: Kishore Chandolu 
*  Date: 2013-01-31
*  Description: This is a controller extension for GNE_SFA2_SBCurriculum_Edit_Create_Layout page
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_SBCurclm_Edit_Create_Ctrl extends GNE_SFA2_Dynamic_VF_Edit_Create{

    public GNE_SFA2_SBCurclm_Edit_Create_Ctrl(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_SBCurriculum_Layout');
        
        if(myObject == null){
                myObject = new Curriculum_Speaker_Bureau_gne__c();
        }
        String parentId = ApexPages.currentPage().getParameters().get('objectId');
        String parentObj = parentId.substring(0,3);
        system.debug('Parent Object:'+parentObj);
        if(parentId != null && parentId != ''){
            if (parentObj == 'a37')
                myObject.put('Speaker_Bureau_gne__c', parentId);
            else
                myObject.put('Event_Curriculum_gne__c', parentId);
        }
    }
}