public with sharing class GNE_SFA2_MyTasks_Controller extends GNE_SFA2_List_View_Base_Controller {
       public GNE_SFA2_List_View_Base_Controller thisController { get; set; }
    
    public PageReference newClick() {
        Schema.DescribeSObjectResult describeResult = Task.SObjectType.getDescribe();
        PageReference newToT = new PageReference('/apex/GNE_SFA2_Task_Edit_Create_Layout');
        //PageReference newToT = new PageReference('/' + describeResult.getKeyPrefix() + '/e');
        newToT.getParameters().put('retURL', '/apex/GNE_SFA2_MyTasks'); 
        return newToT;
    }
    
    public GNE_SFA2_MyTasks_Controller() {
        super('Task');
        thisController = this;
    }
}