/************************************************************
*  @author: Jakub Lewandowski, Roche
*  Date: 2011-02-10
*  Description: 
*  The class is used to create scheduled jobs for the class GNE_Event_Curriculum_Batch_Update
*  Modification History
*  Date        Name        Description
*                
*************************************************************/
global class GNE_Event_Curriculum_Scheduler implements Schedulable
{
	global void execute(SchedulableContext sc) 
	{
		database.executeBatch(new GNE_Event_Curriculum_Batch(), 100);		
	}
}