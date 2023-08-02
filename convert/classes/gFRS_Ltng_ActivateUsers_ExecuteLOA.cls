public class gFRS_Ltng_ActivateUsers_ExecuteLOA implements Queueable {
    public List<User> userList ; 
    public Map<Id,Id> cdMap ; 
    public gFRS_Ltng_ActivateUsers_ExecuteLOA(List<User> userList, Map<Id,Id> cdMap){
        this.userList = userList ;  
        this.cdMap = cdMap;
    }
    public void execute(QueueableContext context) {
        
        update userList;
        System.enqueueJob(new gFRS_Ltng_UpdateCDOwner_ExecuteLOA(cdMap));
    }
}