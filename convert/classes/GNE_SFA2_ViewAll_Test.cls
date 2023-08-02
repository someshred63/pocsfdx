/************************************************************
*  @author: Piotr Przesmycki
*  Date: 2014-01-28
*  Description: This is a test class for GNE_SFA2_ViewAll class.
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
@isTest
private class GNE_SFA2_ViewAll_Test {
    
    public static testMethod void test_GNE_SFA2_ViewAll() {
        Account testAcc = new Account(Name = 'testAcc');
        insert testAcc;
        String viewObjectName='testObj';
        String viewFieldsCSV='testCsv';
        String viewFilter='testFilter';
        Integer viewPageSize=1;
        Id viewParentId=testAcc.Id;
        String viewParentFieldName='testParent__c';
        String viewOrderByFieldName='testParent__c';
        String viewUrlForNewRecord='testUrl';
        String viewSortDirection='ASC';
        Boolean viewHideButtons=false;
        Boolean viewHideEditLink=false;
        Boolean viewHideDeleteLink=false;
        String viewRelatedListLabel='testLabel';
        User sfa2User = GNE_SFA2_Util.selectSFA2User();

        SFA2_Configuration_Object_gne__c conf = new SFA2_Configuration_Object_gne__c(Attributes_gne__c='testAttr', Section_Header_gne__c='test',
                    Configuration_Type_gne__c = 'Page', Is_Active_gne__c = true, Application_Type__c = 'SFA-US',
                    Object_Name_gne__c = 'Account', Record_Type_gne__c='testType');
        insert conf;
        List<SFA2_Configuration_Object_Detail_gne__c> det = new List<SFA2_Configuration_Object_Detail_gne__c>();
        det.add(new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = viewObjectName, Label_gne__c = 'button1', Attributes_gne__c = '', Is_Required_gne__c = false,
                                                            Is_Read_Only_gne__c = true, Order_gne__c = 1.0, Type_gne__c = 'Related List', Style_gne__c=null,
                                                            Configuration_Object_ref_gne__c=conf.Id, Is_Active_gne__c=true));
        insert det;

        if(sfa2USer != null) {
            System.runAs(sfa2User) {
                insert new GNE_SFA2_User_App_Context_gne__c(SFA2_Mode_gne__c=true, App_Name_gne__c='SFA-US');
                PageReference pr = Page.GNE_SFA2_Account_Layout;
                pr.getParameters().put('parentObjectName','Account');
                pr.getParameters().put('parentRecordType','testType');
                pr.getParameters().put('viewObjectName',viewObjectName);
                pr.getParameters().put('viewPageSize',String.valueOf(viewPageSize));
                pr.getParameters().put('viewParentId',(String)viewParentId);
                pr.getParameters().put('viewParentFieldName',viewParentFieldName);
                pr.getParameters().put('viewOrderByFieldName',viewOrderByFieldName);
                pr.getParameters().put('viewUrlForNewRecord',viewUrlForNewRecord);
                pr.getParameters().put('viewSortDirection',viewSortDirection);
                pr.getParameters().put('viewHideEditLink',String.valueOf(viewHideEditLink));
                pr.getParameters().put('viewHideDeleteLink',String.valueOf(viewHideDeleteLink));
                pr.getParameters().put('viewRelatedListLabel',viewRelatedListLabel);
                pr.getParameters().put('viewHideButtons',String.valueOf(viewHideButtons));
                Test.setCurrentPage(pr);
                GNE_SFA2_ViewAll vaController = new GNE_SFA2_ViewAll();
                system.assertEquals(viewObjectName,vaController.viewObjectName);
                system.assertEquals(viewPageSize,vaController.viewPageSize);
                system.assertEquals(viewParentId,vaController.viewParentId);
                system.assertEquals(viewParentFieldName,vaController.viewParentFieldName);
                system.assertEquals(viewOrderByFieldName,vaController.viewOrderByFieldName);
                system.assertEquals(viewUrlForNewRecord,vaController.viewUrlForNewRecord);
                system.assertEquals(viewSortDirection,vaController.viewSortDirection);
                system.assertEquals(viewHideButtons,vaController.viewHideButtons);
                system.assertEquals(viewHideEditLink,vaController.viewHideEditLink);
                system.assertEquals(viewHideDeleteLink,vaController.viewHideDeleteLink);
                system.assertEquals(viewRelatedListLabel,vaController.viewRelatedListLabel);
            }
        }
    }   
}