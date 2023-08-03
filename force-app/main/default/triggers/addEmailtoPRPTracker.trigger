trigger addEmailtoPRPTracker on EmailMessage (after insert,after update) {
        if(trigger.isInsert || trigger.isUpdate ){
            emailSyncToPRPEmailTracker.emailTracker(Trigger.new);
        }
   }