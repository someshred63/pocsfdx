/************************************************************
*  @author: Sreedhar Karukonda
*  Date: 2013-02-04
*  Description: This is a controller class for GNE_SFA2_Key_Messages page
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Key_Messages_Controller extends GNE_SFA2_List_View_Base_Controller{
    public GNE_SFA2_List_View_Base_Controller thisController { get; set; }
    
    public PageReference newClick() {
        Schema.DescribeSObjectResult describeResult = Key_Message_vod__c.SObjectType.getDescribe();
        PageReference newKeyMessage= new PageReference('/' + describeResult.getKeyPrefix() + '/e');
        newKeyMessage.getParameters().put('retURL', '/apex/GNE_SFA2_Key_Messages');
        return newKeyMessage ;
    }
    
    public GNE_SFA2_Key_Messages_Controller () {
        super('Key_Message_vod__c');
        thisController = this;
    }
}