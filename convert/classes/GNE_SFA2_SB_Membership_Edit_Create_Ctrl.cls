/************************************************************
*  @author: Kishore Chandolu
*  Date: 2013-01-31
*  Description: This is a controller extension for GNE_SFA2_SB_Membership_Edit_Create_Layout page
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_SB_Membership_Edit_Create_Ctrl extends GNE_SFA2_Dynamic_VF_Edit_Create{
    public GNE_SFA2_SB_Membership_Edit_Create_Ctrl(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_SBMembership_Nominate_Layout');
        if(myObject == null){
                myObject = new Speaker_Bureau_Membership_gne__c();
        }
        String parentId = ApexPages.currentPage().getParameters().get('objectId');
        if(parentId != null && parentId != '' && myObject.id==null){
            myObject.put('Speaker_Bureau_ID_gne__c', parentId);
        }        
    }
}