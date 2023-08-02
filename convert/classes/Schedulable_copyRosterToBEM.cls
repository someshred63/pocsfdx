global class Schedulable_copyRosterToBEM implements Schedulable,Database.AllowsCallouts  {
    global void execute(SchedulableContext ctx){
        copyRosterInfoToGenentechCont rstr = new copyRosterInfoToGenentechCont();
        rstr.copyDatatoBEM();
    }
}