public class FCR_PeepTriggerHandler {
    public static void onAfterUpdate() {
        System.debug('START TRIGGER HANDLER');
		FCR_PeepTriggerHandlerLogic.manageSharingOnUpdate(Trigger.new, (Map<Id, FCR_Peep_gne__c>)Trigger.oldMap);
	}

}