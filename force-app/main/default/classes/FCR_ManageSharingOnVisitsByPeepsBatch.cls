public class FCR_ManageSharingOnVisitsByPeepsBatch implements Database.Batchable<sObject>, Database.Stateful {
    private List<FCR_PeepTriggerHandlerLogic.PeepChanges> peeps;
    private Set<String> userUnixIdsCS;
    private Set<String> userUnixIdsPM;
    private Set<String> userUnixIdsNewPM;
    private Map<String, FCR_PeepTriggerHandlerLogic.PeepChanges> key2PeepChange;
    private Datetime startProcessDT;
    
    public FCR_ManageSharingOnVisitsByPeepsBatch(Datetime startProcessDT, List<FCR_PeepTriggerHandlerLogic.PeepChanges> peeps) {
        this.peeps = new List<FCR_PeepTriggerHandlerLogic.PeepChanges> (peeps);
        fetchUserUnixIds ();
        fillMapByKey ();
        this.startProcessDT = startProcessDT;
    }
    
    public FCR_ManageSharingOnVisitsByPeepsBatch(List<FCR_PeepTriggerHandlerLogic.PeepChanges> peeps) {
        this.peeps = new List<FCR_PeepTriggerHandlerLogic.PeepChanges> (peeps);
        fetchUserUnixIds ();
        fillMapByKey ();
    }
    
    private void fillMapByKey() {
        key2PeepChange = new Map<String, FCR_PeepTriggerHandlerLogic.PeepChanges> ();
        for(FCR_PeepTriggerHandlerLogic.PeepChanges pc : peeps) {
            key2PeepChange.put(pc.cs, pc);
        }
    }
    
    private void fetchUserUnixIds() {
        this.userUnixIdsCS = new Set<String>();
        this.userUnixIdsPM = new Set<String>();
        this.userUnixIdsNewPM = new Set<String>();
        for(FCR_PeepTriggerHandlerLogic.PeepChanges pc : peeps) {
            userUnixIdsPM.add(pc.oldManager );
            userUnixIdsCS.add(pc.cs);
            userUnixIdsNewPM.add(pc.newManager);
        }
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([
            SELECT Id, RowCause, ParentId, UserOrGroupId
            FROM Visit_gne__Share 
            WHERE UserOrGroupId IN (SELECT Id FROM user WHERE External_Id_gne__c IN :userUnixIdsPM)
                AND RowCause = : Schema.Visit_gne__Share.RowCause.Peep_Manager__c
            	AND ParentId IN (SELECT Id FROM Visit_gne__c WHERE Clinical_Specialist_gne__r.External_Id_gne__c IN : userUnixIdsCS)
        ]);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope) {

        Map<String, Id> unixId2userId = new Map<String, Id>();
        for(User us : [SELECT Id, External_Id_gne__c FROM User WHERE External_Id_gne__c IN : userUnixIdsNewPM AND isActive = true]) {
            unixId2userId.put(us.External_Id_gne__c, us.Id);
        }
        Set<Id>parentIds = new Set<Id>();
        for(Visit_gne__Share vs : ( List<Visit_gne__Share>) scope) {
            parentIds.add(vs.ParentId);
        }
        Map<Id,Visit_gne__c> visits = new Map<Id,Visit_gne__c>([
            SELECT Clinical_Specialist_gne__r.External_Id_gne__c
            FROM Visit_gne__c
            WHERE Id IN : parentIds
        ]);
        List<Visit_gne__Share> toInsert = new List<Visit_gne__Share>();
        for(Visit_gne__Share vs : ( List<Visit_gne__Share>) scope) {
            Visit_gne__c record = visits.get(vs.ParentId);
            FCR_PeepTriggerHandlerLogic.PeepChanges cs = key2PeepChange.get(record.Clinical_Specialist_gne__r.External_Id_gne__c);
            Visit_gne__Share newSharing = new Visit_gne__Share(UserOrGroupId = unixId2userId.get(cs.newManager), ParentId = record.Id, AccessLevel = 'edit', RowCause = Schema.Visit_gne__Share.RowCause.Peep_Manager__c);
            toInsert.add(newSharing);            
        }
        Database.SaveResult[] sr = Database.insert(toInsert,false);
        delete scope;
    }
    
    public void finish(Database.BatchableContext BC) {
        if(startProcessDT!=null)DataBase.executeBatch(new FCR_DeletePeepsBatch(startProcessDT));
    }

}