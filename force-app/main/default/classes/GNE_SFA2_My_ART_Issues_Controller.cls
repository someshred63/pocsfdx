public with sharing class GNE_SFA2_My_ART_Issues_Controller extends GNE_SFA2_List_View_Base_Controller {
       public GNE_SFA2_List_View_Base_Controller thisController { get; set; }
    
    public PageReference newClick() {
        //Schema.DescribeSObjectResult describeResult = ART_Issue_gne__c.SObjectType.getDescribe();
        PageReference newToT =Page.GNE_SFA2_ART_Issue_Edit_Create_Layout;
        newToT.getParameters().put('retURL', '/apex/GNE_SFA2_My_ART_Issues'); 
        return newToT;
    }
    
    public GNE_SFA2_My_ART_Issues_Controller() {
        super('ART_Issue_gne__c');
        thisController = this;
    } 
}