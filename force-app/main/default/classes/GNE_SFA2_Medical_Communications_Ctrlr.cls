/************************************************************
*  @author: Jakub Lewandowski, Roche
*  Date: 2013-03-15
*  Description: This is a controller class for GNE_SFA2_Medical_Communications page.
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Medical_Communications_Ctrlr extends GNE_SFA2_List_View_Base_Controller{
    public GNE_SFA2_List_View_Base_Controller thisController { get; set; }
    
    public PageReference newClick() {
        String newURL = '/apex/GNE_SFA2_Create_MedComm_Layout?acctId';
        pagereference pageref = new pagereference(newURL);
        pageref.setredirect(true);
        return pageref;
    }
    
    public GNE_SFA2_Medical_Communications_Ctrlr() {
        super('Medical_Communication_gne__c');
        thisController = this;
    }
}