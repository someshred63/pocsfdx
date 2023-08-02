/**
 *  Scheduler that starts the batch to recalculate the current amount of funding requests approved in the current year.
 *  
 *  <p>Must be done in this manner since we are at the max number of roll-up summaries</p>
 *  
 *  <code>
 *  GFRS_ScheduleResetCurrentYearBudgets scheduledBudgetReset = new GFRS_ScheduleResetCurrentYearBudgets();
 *  System.schedule( GFRS_ScheduleResetCurrentYearBudgets.TITLE, '0 0 3 * * ?', scheduledBudgetReset );
 *  </code>
 **/
global class GFRS_ScheduleResetCurrentYearBudgets implements Schedulable {
	
	global Static String TITLE = 'gFRS Organization Current Year Approved Rollup';
	
	global String scheduledJobId;
	
	global GFRS_ScheduleResetCurrentYearBudgets(){
	}
	
	global void execute( SchedulableContext sc ){
		GFRS_ResetCurrentYearBudgets driver = new GFRS_ResetCurrentYearBudgets( null );
		
		Database.executeBatch( driver,1 );
	}
}