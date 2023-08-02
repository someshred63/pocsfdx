public class AGS_UserActivationCaseActionsAssingment extends AGS_AbstractCaseBatch implements Database.Stateful {
    
    public static final Integer MINUTE = 45; // 45 minutes after full hour
    
    public static final String QUERY = 'SELECT Inactive_Owner_gne__c FROM AGS_Case_Action_gne__c WHERE OwnerId IN (' +
        'SELECT QueueId FROM QueueSobject WHERE SobjectType = \'AGS_Case_Action_gne__c\'' +
    ')';
    
    private sObject[] actions = new sObject[]{ };
    
    public AGS_UserActivationCaseActionsAssingment() {
        super('AGS_PendingCaseActionsBatchSchedule', 'AGS Pending Case Actions', QUERY);
    }
    
    public override void execute(final Database.BatchableContext ctx, final List<sObject> caseActions) {
        final Map<Id, User> usrs = new Map<Id, User>();
        for (sObject action : caseActions) {
            usrs.put((Id) action.get('Inactive_Owner_gne__c'), new User(IsActive = true));
        }
        usrs.remove(null);
        actions.addAll(caseActions);
        usrs.putAll(new Map<Id, User>(usrs.isEmpty() ? new User[]{ } : [
            SELECT IsActive FROM User WHERE Id IN :usrs.keySet() AND IsActive = false LIMIT :usrs.size()
        ]));
        for (User usr : usrs.values()) {
            if (usr.IsActive) {
                usrs.remove(usr.Id);
            } else {
                usr.IsActive = true;
            }
        }
        Database.update(usrs.values(), false);
    }
    
    public override void finish(final Database.BatchableContext ctx) {
        final AGS_User_Activation_Finish_gne__c[] settings = AGS_User_Activation_Finish_gne__c.getAll().values();
        for (sObject action : actions) {
            action.put('OwnerId', action.get('Inactive_Owner_gne__c'));
        }
        Database.update(actions, false);
        upsert new AGS_User_Activation_Finish_gne__c(
            Name = settings.isEmpty() ? '0' : settings[0].Name,
            Id = settings.isEmpty() ? null : settings[0].Id,
            Status_gne__c = 'Proceed'
        );
        super.finish(ctx);
    }
    
    public override DateTime getNextJobScheduledRun() {
        final DateTime now = System.now();
        return now.addMinutes(MINUTE - now.minute() + (now.minute() < MINUTE ? 0 : 60));
    }
}