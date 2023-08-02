/*****************************************************************************************************************************
CLASS NAME: gFRS_OCR_createBatch_Sched
DESCRIPTION: Created this class to handle scheduler for create batch callouts.
Note: Maintain atleast last 5 logs

DATE			DEVELOPER			PURPOSE
-----------------------------------------------------------------------------------------------------------------------------
05-Jan-2021		Veera				Created this scheduler class for calling CreateBatch Batch class.

*/
global class gFRS_OCR_createBatch_Sched implements schedulable{
    
    /*
    Method Name: execute
    Description: This method helps to schedule batch.
    */
    global void execute(schedulableContext sc){
        ID processID = database.executeBatch(new gFRS_OCR_createBatch_Batch(),1);
    }

    
}