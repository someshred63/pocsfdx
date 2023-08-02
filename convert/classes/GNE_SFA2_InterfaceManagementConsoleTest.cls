@isTest
private class GNE_SFA2_InterfaceManagementConsoleTest {
    @testSetup
    static void initData() {
        insert new CORE_Subscribe_Object__c(Name ='SFA_US', Retriever_Interface_gne__c = 'GNE_SFA2_Subscribe_Helper', Validation_Interface_gne__c = 'GNE_SFA2_Subscribe_Helper');
        insert new CORE_Merge_Object__c (Name ='ALL-US',Object_Name_gne__c = 'ALL', Object_Type_gne__c = 'ALL', Region_Code_gne__c = 1);
    }
    
    @isTest
    static void initTest() {
        PageReference pageRef = new PageReference('/apex/apex/GNE_SFA2_InterfaceManagementConsole');
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        	GNE_SFA2_InterfaceManagementConsole ctrl = new GNE_SFA2_InterfaceManagementConsole();
        Test.stopTest();        
    }
    
    @isTest
    static void test_getObjectsToDisplay() {
        PageReference pageRef = new PageReference('/apex/apex/GNE_SFA2_InterfaceManagementConsole');
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        	GNE_SFA2_InterfaceManagementConsole ctrl = new GNE_SFA2_InterfaceManagementConsole();
        	GNE_SFA2_InterfaceManagementConsole.CountryWrapper [] wrappers = ctrl.getObjectsToDisplay();
        	System.debug(wrappers);
        Test.stopTest();   
    }
    
    @isTest
    static void test_getBatchResponse() {     
        GNE_FRM_TestUtilities.CalloutMock callMock = new GNE_FRM_TestUtilities.CalloutMock();
        callMock.response = '{"totalSize":0,"done":true,"records":[]}';       
        Test.setMock(HttpCalloutMock.class, callMock);
        Test.startTest();
        	String resp = GNE_SFA2_InterfaceManagementConsole.getBatchResponse(1);
        System.debug(resp);
        Test.stopTest();   
    }
    
    @isTest
    static void test_getQueryResponse() {    
        GNE_FRM_TestUtilities.CalloutMock callMock = new GNE_FRM_TestUtilities.CalloutMock();
        callMock.response = '{"totalSize":0,"done":true,"records":[]}';       
        Test.setMock(HttpCalloutMock.class, callMock);
        Test.startTest();
        	String resp = GNE_SFA2_InterfaceManagementConsole.getQueryResponse(1);
        	System.debug(resp);
        Test.stopTest();   
    }
}