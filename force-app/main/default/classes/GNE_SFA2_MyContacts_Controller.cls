/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2013-01-04
*  Description: This is a controller class for GNE_SFA2_MyContacts page
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_MyContacts_Controller extends GNE_SFA2_List_View_Base_Controller{
    public GNE_SFA2_List_View_Base_Controller thisController { get; set; }
    
    public PageReference newClick() {
        PageReference newContact = Page.GNE_SFA2_Contact_Edit_Create_Layout;
        newContact.getParameters().put('retURL', '/apex/GNE_SFA2_MyContacts');
        return newContact ;
    }
    
    public GNE_SFA2_MyContacts_Controller() {
        super('Contact');
        thisController = this;
    }
}