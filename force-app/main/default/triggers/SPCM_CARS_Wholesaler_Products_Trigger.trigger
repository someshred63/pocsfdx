trigger SPCM_CARS_Wholesaler_Products_Trigger on SPCM_CARS_Wholesaler_Payment_Products__c (before delete) {

    if (Trigger.isBefore)
    {
        if (Trigger.isDelete)
        {
        	SPCM_CARSPaymentExceptionPacketUtils.ValidateProductsForPayment(Trigger.old);
        }
    }

}