global class gFRS_MERGMonthlyStatusReportScheduler Implements Schedulable 
{ 
    global void execute(SchedulableContext sc)
    { 
         Type targettype = Type.forName('gFRS_MERGMonthlyStatusReport');
         
         if(targettype!=null)   
         {   
              Database.Batchable<sObject> obj = (Database.Batchable<sObject>) targettype.NewInstance();
              Database.executeBatch(obj, 9);
         }
    } 

}