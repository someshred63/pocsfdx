trigger SPCM_Log_To_Prod_Junction on SPCM_log_to_Product_Junction__c (before insert, after insert, after delete, before delete) {

    if (Trigger.isAfter)
    {
        if (Trigger.isInsert)
        {
            SPCM_ICFRLogToProductUtils.UpdateICFRLogProductList(Trigger.new);
        }
        if (Trigger.isDelete)
        {
            SPCM_ICFRLogToProductUtils.UpdateICFRLogProductList(Trigger.old);
        }
    }
    if (Trigger.isBefore)
    {
        if (Trigger.isInsert)
        {
            SPCM_ICFRLogToProductUtils.ValidateNewJunction(Trigger.new, 'isInsert');
        }
        if (Trigger.isDelete)
        {
            SPCM_ICFRLogToProductUtils.ValidateNewJunction(Trigger.old, 'isDelete');
        }
    }
}