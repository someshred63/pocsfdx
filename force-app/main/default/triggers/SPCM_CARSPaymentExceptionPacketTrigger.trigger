trigger SPCM_CARSPaymentExceptionPacketTrigger on SPCM_CARS_Wholesaler_Exception_Payment__c (before insert, before update, before delete, after update) {

    // create utility class
    SPCM_CARSPaymentExceptionPacketUtils handler = new SPCM_CARSPaymentExceptionPacketUtils();
    
    // before event
    if (Trigger.isBefore)
    {
    
        // insert event
        if (Trigger.isInsert)
        {
            handler.HandleBeforeInsert(Trigger.new);
            handler.ValidateApprover(Trigger.new);
        }
        
        // update event
        if (Trigger.isUpdate)
        {
            handler.HandleBeforeUpdate(Trigger.old, Trigger.new);
        }
        
        // delete event
        if (Trigger.isDelete)
        {
            handler.HandleBeforeDelete(Trigger.old);
        }
    }

}