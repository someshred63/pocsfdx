/************************************************************
*  @author: Krzysztof Wilczek, Roche
*  Date: 2010-09-15
*  Description: 
*  
*  Modification History
*  Date        Name        Description
*                
*************************************************************/
@isTest
private class GlobalUtilsTest 
{

    static testMethod void testGetEnvironment() 
    {
        Profile p = [select id from profile where name='Standard User'];
        
        User CMR2 = new User(alias = 'cm', email='cmtest@gene.com', 
                        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                        localesidkey='en_US', profileid = p.Id, 
                        timezonesidkey='America/Los_Angeles', username='cmtest@gene.com.cmr2');
                        
        User PROD = new User(alias = 'cm', email='cmtest@gene.com', 
                        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                        localesidkey='en_US', profileid = p.Id, 
                        timezonesidkey='America/Los_Angeles', username='cmtest@gene.com');
                        
        Test.startTest();
        System.runAs(CMR2) 
        {
            System.assertEquals('cmr2', GlobalUtils.getEnvironment()); 
        }
        System.runAs(PROD)
        {
            System.assertEquals('prod', GlobalUtils.getEnvironment());
        }
        Test.stopTest();
    }
    
    static testMethod void testTwoPointsDistance()
    {
        double lat1 = 10;
        double lon1 = 10;
        double lat2 = -100;
        double lon2 = 100;
        boolean km_switch = true;
        double result1 = GlobalUtils.twoPointsDistance(lat1, lon1, lat2, lon2, km_switch);
        km_switch = false;
        double result2 = GlobalUtils.twoPointsDistance(lat1, lon1, lat2, lon2, km_switch);      
        System.Assert(result1 >= 0);
        System.Assert(result2 >= 0);
        System.Assert(result1 >= result2);
    }
    
    static testMethod void testDictionary()
    {
        Map<String, String> testMap = new Map<String, String>{'key1' => 'value1',
                                                              'key2' => 'value2',
                                                              'key3' => 'value3',
                                                              'key4' => 'value4'};
        GlobalUtils.Dictionary myTest = new GlobalUtils.Dictionary(testMap);
        
        System.AssertEquals('key1', myTest.GetKey('value1'));
        System.AssertEquals('key4', myTest.GetKey('value4'));
        System.AssertEquals('value1', myTest.GetValue('key1'));
        System.AssertEquals('value4', myTest.GetValue('key4'));
    }
    
    static testmethod void testQSortCustomClasses()
    {    	
        GNE_CM_Task_Queue_Mgmt_Helper.CaseGroup cg1 = new GNE_CM_Task_Queue_Mgmt_Helper.CaseGroup(getTaskWithDueDate(7));
        GNE_CM_Task_Queue_Mgmt_Helper.CaseGroup cg2 = new GNE_CM_Task_Queue_Mgmt_Helper.CaseGroup(getTaskWithDueDate(6));        
        GNE_CM_Task_Queue_Mgmt_Helper.CaseGroup cg3 = new GNE_CM_Task_Queue_Mgmt_Helper.CaseGroup(getTaskWithDueDate(5));        
        GNE_CM_Task_Queue_Mgmt_Helper.CaseGroup cg4 = new GNE_CM_Task_Queue_Mgmt_Helper.CaseGroup(getTaskWithDueDate(4));        
        GNE_CM_Task_Queue_Mgmt_Helper.CaseGroup cg5 = new GNE_CM_Task_Queue_Mgmt_Helper.CaseGroup(getTaskWithDueDate(3));        
        GNE_CM_Task_Queue_Mgmt_Helper.CaseGroup cg6 = new GNE_CM_Task_Queue_Mgmt_Helper.CaseGroup(getTaskWithDueDate(2));
        List<GNE_CM_Task_Queue_Mgmt_Helper.CaseGroup> listToSort = new GNE_CM_Task_Queue_Mgmt_Helper.CaseGroup[]{cg4,cg5,cg1,cg2,cg3,cg6};
        
        GlobalUtils.qsort(listToSort, new GNE_CM_Task_Queue_Mgmt_Helper.CaseGroupComparator(), false);
        
        System.assertNotEquals(null, listToSort);
        System.assertEquals(6, listToSort.size());
        System.assertEquals(cg6.dueDate, listToSort.get(0).dueDate);
        System.assertEquals(cg5.dueDate, listToSort.get(1).dueDate);
        System.assertEquals(cg4.dueDate, listToSort.get(2).dueDate);
    }
    
    private static Task getTaskWithDueDate(Integer numberOfDaysInPast)
    {
    	return new Task(activityDate = system.today() - numberOfDaysInPast,
    						CM_Queue_TimeZone_Number_gne__c = 1,
    						CM_Case_AddressId_gne__c = '123456789012345678');
    } 
}