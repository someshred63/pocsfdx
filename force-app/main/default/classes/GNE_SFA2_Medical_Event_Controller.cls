/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-12-21
*  Description: This is a controller class for GNE_SFA2_Medical_Event page.
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Medical_Event_Controller extends GNE_SFA2_List_View_Base_Controller{
    public GNE_SFA2_List_View_Base_Controller thisController { get; set; }
    
    public PageReference newClick() {
        PageReference pageref = new PageReference('/apex/GNE_SFA2_MedicalEvent_Edit_Create_Layout');
        pageref.setredirect(true);
        return pageref;
    }
    
    public GNE_SFA2_Medical_Event_Controller() {
        super('Medical_Event_vod__c');
        thisController = this;
    }
}