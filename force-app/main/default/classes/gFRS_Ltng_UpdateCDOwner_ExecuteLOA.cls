public class gFRS_Ltng_UpdateCDOwner_ExecuteLOA implements Queueable {
    public Map<Id,Id> cdMap ; 
    List<ContentDocument> listCD = new List<ContentDocument>();
    
    public gFRS_Ltng_UpdateCDOwner_ExecuteLOA(Map<Id,Id> cdMap){
        this.cdMap = cdMap;
    }
    public void execute(QueueableContext context) {
        
        listCD = [SELECT Id, OwnerId FROM ContentDocument WHERE Id IN : cdMap.keySet()];
        for(ContentDocument CD : listCD){
            CD.OwnerId = cdMap.get(CD.Id);
            //listCD2.add(CD);
        }
        update listCD;
    }
}