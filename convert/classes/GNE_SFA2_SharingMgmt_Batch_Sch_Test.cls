/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-07-20
*  This a test class for GNE_SFA2_SharingMgmt_Batch_Scheduler
*    
*  Modification History
*  Date        Name        Description
*************************************************************/
@isTest
public class GNE_SFA2_SharingMgmt_Batch_Sch_Test {
  public static testMethod void testScheduling() {
    Test.startTest();
    GNE_SFA2_SharingMgmt_Batch_Scheduler scheduler = new GNE_SFA2_SharingMgmt_Batch_Scheduler();
    String jobId = System.schedule('Test job', '0 0 0 3 9 ? 2033', scheduler);  
    Test.stopTest();
    
    CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
    
    System.assertEquals(0, ct.TimesTriggered);
    System.assertEquals('2033-09-03 00:00:00', String.valueOf(ct.NextFireTime));
  }
}