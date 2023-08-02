/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2013-03-28
*  This class is used for scheduling GNE_SFA2_User_Sales_Roster_Assign_Batch batch
*    
*  Modification History
*  Date        Name        Description
*************************************************************/

global class GNE_SFA2_User_Sales_Roster_Schedulable implements Schedulable{
  global void execute(SchedulableContext SC) {
      GNE_SFA2_User_Sales_Roster_Assign_Batch userSalesRosterAssignmentBatch = new GNE_SFA2_User_Sales_Roster_Assign_Batch();
      GNE_Batch_Runner.executeBatch(userSalesRosterAssignmentBatch, GNE_SFA2_User_Sales_Roster_Assign_Batch.class,
      		false, true, true, false);
   }
}