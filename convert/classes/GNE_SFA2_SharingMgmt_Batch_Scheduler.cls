/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-07-20
*  This class is used for scheduling GNE_SFA2_SharingMgmt_Batch batch
*    
*  Modification History
*  Date        Name        Description
*************************************************************/

global class GNE_SFA2_SharingMgmt_Batch_Scheduler implements Schedulable{
  global void execute(SchedulableContext SC) {
      GNE_SFA2_SharingMgmt_Batch sharingMgmtBatch = new GNE_SFA2_SharingMgmt_Batch();
      Database.executeBatch(sharingMgmtBatch); 
   }
}