global class gFRS_TasksStatusRefresher implements Schedulable{
 
 global void execute(SchedulableContext sc){
        Type tType = Type.forName('gFRS_StatusReportTaskToNotSubmitedImpl');   
        if (tType!=null)   {   
            gFRS_ISchedulable obj = (gFRS_ISchedulable) tType.NewInstance();     
            obj.execute(sc);   
        } 
    }          
  
}