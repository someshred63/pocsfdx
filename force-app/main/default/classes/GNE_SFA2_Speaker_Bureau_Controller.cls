/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-12-21
*  Description: This is a controller class for GNE_SFA2_Speaker_Bureau page.
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Speaker_Bureau_Controller extends GNE_SFA2_List_View_Base_Controller{
    public GNE_SFA2_List_View_Base_Controller thisController { get; set; }
    
    public PageReference newClick() {
        PageReference newSB = new PageReference('/apex/GNE_SFA2_SBureau_Edit_Create_Layout');
        newSB.getParameters().put('retURL', '/apex/GNE_SFA2_SBureau');
        newSB.setRedirect(true); 
        return newSB;
    }
    
    public GNE_SFA2_Speaker_Bureau_Controller() {
        super('Speaker_Bureau_gne__c');
        thisController = this;
    }
}