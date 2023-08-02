public class FCR_VisitTriggerHandler {
    
    public static void onAfterInsert() {
		FCR_VisitTriggerHandlerLogic.createSharingsOnInsert(Trigger.new);
        FCR_VisitTriggerHandlerLogic.sendNotification(Trigger.new);
	}
	
	public static void onAfterUpdate() {
		FCR_VisitTriggerHandlerLogic.manageSharingOnUpdate(Trigger.new, (Map<Id, Visit_gne__c>)Trigger.oldMap);
        FCR_VisitTriggerHandlerLogic.sendNotification(Trigger.new);
	}
}