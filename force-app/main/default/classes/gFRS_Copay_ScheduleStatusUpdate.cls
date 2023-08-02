global class gFRS_Copay_ScheduleStatusUpdate implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        // We now call the batch class to be scheduled
        gFRS_Req_Sub_Status_Update b = new gFRS_Req_Sub_Status_Update();
       
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(b,200);
    }
   
}