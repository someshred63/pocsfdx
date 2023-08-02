public class FCR_PeepTriggerHandlerLogic {
    private static List<PeepChanges> toSharingManage = new List<PeepChanges>();
    
    public static void manageSharingOnUpdate(List<FCR_Peep_gne__c> scope, Map<Id, FCR_Peep_gne__c> oldMap) {
        for(FCR_Peep_gne__c peep : scope) {
            FCR_Peep_gne__c oldPeep = oldMap.get(peep.Id);
            if(oldPeep.Manager_gne__c != null &&  peep.Manager_gne__c != oldPeep.Manager_gne__c ) {
                toSharingManage.add(new PeepChanges(peep, oldPeep) );
            }
        }
        
        if(!toSharingManage.isEmpty() && !System.isBatch())runBatchToManageChangesOnManagerForPeeps();
    }
    
    private static void runBatchToManageChangesOnManagerForPeeps() {
        DataBase.executeBatch(new FCR_ManageSharingOnVisitsByPeepsBatch(toSharingManage), 10);
    }
    
    public class PeepChanges {
        public String oldManager;
        public String newManager;
        public String cs;
        public PeepChanges(FCR_Peep_gne__c peep, FCR_Peep_gne__c oldPeep ) {
            oldManager = oldPeep.Manager_gne__c;
            newManager = peep.Manager_gne__c;
            cs = peep.UserUnixId__c;
        }
    }
}