global class Schedulable_Roster implements Schedulable,Database.AllowsCallouts {
    global void execute(SchedulableContext ctx){
        cleanRosterData();
        Roster_JSONDeserialize.deserialize();
    }
    
        //Jie added on 4/11/23 to clean roster data object before load new data in from the interface
    private static void cleanRosterData(){
        List<Roster_Data__c> rds=[select id from Roster_Data__c];
        if(rds!=null && rds.size()>0) delete rds;
    }
}