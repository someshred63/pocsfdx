public with sharing class GNE_SFA2_Task_Field_Updates {
    
    public static void onBeforeInsert(List<Task> newTasks){
        taskTriggerBeforeInsert(newTasks);
    }
   
    private static void taskTriggerBeforeInsert(List<Task> tasks)
    {
        try{
            for (Integer i=0; i<tasks.size(); i++) {
                if (tasks.get(i).Followup_Activity_Type_vod__c != null && tasks.get(i).Subject == 'Other - See Comments') {  
                    tasks.get(i).Subject = tasks.get(i).Description;
                }       
            }
        }
        catch(Exception e){
        }
    }
}