trigger GT_DCCTrigger on GT_Data_Change_Capture_MDM__e (after insert) {
   for (GT_Data_Change_Capture_MDM__e event : Trigger.New) {
   System.debug('Payload:'+event.payload__c);
   }

}