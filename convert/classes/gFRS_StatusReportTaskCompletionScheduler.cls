global class gFRS_StatusReportTaskCompletionScheduler implements Schedulable{
    
    global void execute(SchedulableContext sc){
        Type tType = Type.forName('gFRS_StatusReportTaskCompletionImpl');   
        if (tType!=null)   {   
            gFRS_ISchedulable obj = (gFRS_ISchedulable) tType.NewInstance();     
            obj.execute(sc);   
        } 
    }          
 }