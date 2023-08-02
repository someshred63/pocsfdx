/************************************************************
*  @author: Kishore Chandolu
*  Date: 2013-01-31
*  Description: This is a controller class for GNE_SFA2_Event_Curclm page.
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Event_Curclm_Ctrl extends GNE_SFA2_List_View_Base_Controller{
    public GNE_SFA2_List_View_Base_Controller thisController { get; set; }
    
    public PageReference newClick() {
        Pagereference pageref = new pagereference('/apex/GNE_SFA2_ECurclmBureau_EdCr_Layout');
        pageref.getParameters().put('retURL', '/apex/GNE_SFA2_ECurriculum'); 
        pageref.setredirect(true);
        return pageref;
    }
    
    public GNE_SFA2_Event_Curclm_Ctrl() {
        super('Event_Curriculum_gne__c');
        thisController = this;
    }
}