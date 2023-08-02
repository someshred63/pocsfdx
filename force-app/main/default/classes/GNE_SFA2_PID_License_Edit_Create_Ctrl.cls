/************************************************************
*  @author: Kishore Chandolu
*  Date: 2013-02-22
*  Description: This is a controller extension for GNE_SFA2_PID_License_Edit_Create_Layout page
*   
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_PID_License_Edit_Create_Ctrl extends GNE_SFA2_Dynamic_VF_Edit_Create{
    public GNE_SFA2_PID_License_Edit_Create_Ctrl(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_PID_License_Layout');
        
        if(myObject == null){
            myObject = new ProfileID_License_gne__c();
        }
        String parentId = ApexPages.currentPage().getParameters().get('objectId');
        if(myObject.id == null && String.isNotEmpty(parentId)){
            myObject.put('Account_Name_gne__c', parentId);
        }
        if(GNE_SFA2_Util.isCanadaUser() && ((ProfileID_License_gne__c)myObject).id==null){
        	myObject.put('ID_License_Type_gne__c', 'State License');
        }
    }
}