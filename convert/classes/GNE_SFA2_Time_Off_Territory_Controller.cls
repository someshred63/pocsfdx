/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2013-01-04
*  Description: This is a controller class for GNE_SFA2_Time_Off_Territory page
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Time_Off_Territory_Controller extends GNE_SFA2_List_View_Base_Controller{
    public GNE_SFA2_List_View_Base_Controller thisController { get; set; }
    
    public PageReference newClick() {
        //Schema.DescribeSObjectResult describeResult = Time_Off_Territory_gne__c.SObjectType.getDescribe();
        //PageReference newToT = new PageReference('/' + describeResult.getKeyPrefix() + '/e');
        PageReference newToT = Page.GNE_SFA2_TimeOffTerritory_Create_Layout;
        newToT.getParameters().put('retURL', '/apex/GNE_SFA2_Time_Off_Territory'); 
        return newToT;
    }
    
    public GNE_SFA2_Time_Off_Territory_Controller() {
        super('Time_Off_Territory_gne__c');
        thisController = this;
    }
}