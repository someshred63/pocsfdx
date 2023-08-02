/************************************************************
*  @author: Kishore Chandolu
*  Date: 2013-02-15
*  Description: This is a controller extension for GNE_SFA2_Product_Plan_Edit_Create_Layout page
*   
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Product_Plan_Edit_Create_Ctrl extends GNE_SFA2_Dynamic_VF_Edit_Create{
    public GNE_SFA2_Product_Plan_Edit_Create_Ctrl(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_Product_Plan_Layout');
        
        if(myObject == null){
        	myObject = new Product_Plan_vod__c();            
        }
        String parentId = ApexPages.currentPage().getParameters().get('objectId');
        if(parentId != null && parentId != ''){
            myObject.put('Product_vod__c', parentId);            
        }
        
        if (this.availabilityMode == 'New'){
        	myObject.put('OwnerId', UserInfo.getUserId());
        }
    }
}