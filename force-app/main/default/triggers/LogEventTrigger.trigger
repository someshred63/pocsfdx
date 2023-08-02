trigger LogEventTrigger on Log__e (after insert) {

    LogEventTriggerHandler.insertLogs(Trigger.new);
}