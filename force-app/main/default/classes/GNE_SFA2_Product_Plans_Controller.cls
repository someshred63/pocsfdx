/************************************************************
*  @author: Lukasz Bieniawski
*  Date: 2013-02-27
*  Description: This is a controller for GNE_SFA2_Product_Plans
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Product_Plans_Controller extends GNE_SFA2_List_View_Base_Controller {
	
	public GNE_SFA2_List_View_Base_Controller thisController { get; set; }
    
    public GNE_SFA2_Product_Plans_Controller () {
    	super('Product_Plan_vod__c');
        thisController = this;    
    }
    
     public PageReference newClick() {
        PageReference newProductPlan = new PageReference('/apex/GNE_SFA2_Product_Plan_Edit_Create_Layout');
        newProductPlan.getParameters().put('retURL', '/apex/GNE_SFA2_Product_Plans');
        return newProductPlan;
    }
}