/************************************************************
*  @author: Kishore Chandolu
*  Date: 2012-01-31
*  Description: This is a controller class for GNE_SFA2_Speaker_Contract page.
*   
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Speaker_Contract_Controller extends GNE_SFA2_List_View_Base_Controller{
    public GNE_SFA2_List_View_Base_Controller thisController { get; set; }
    
    public PageReference newClick() {
        return null;
    }
    
    public GNE_SFA2_Speaker_Contract_Controller() {
        super('Speaker_Contract_gne__c');
        thisController = this;
    }
}