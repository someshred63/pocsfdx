trigger sendDocusignDocument on gFRS_Ltng_Application__c (after update) {
      system.debug('Inside Trigger');
  if(trigger.IsAfter && trigger.IsUpdate){
    for(Integer i=0;i<trigger.new.size();i++){ 
        if(trigger.new[i].Status__c == 'Processing & Disposition' && trigger.new[i].Sub_Status__c == 'Approved-Awaiting LOA' && trigger.new[i].External_Status__c == 'Approved-Awaiting LOA'){ 
           if(trigger.new[i].Status__c != trigger.old[i].Status__c || trigger.new[i].Sub_Status__c != trigger.old[i].Sub_Status__c || trigger.new[i].External_Status__c != trigger.old[i].External_Status__c ){
              system.debug('Inside Trigger Line no 7');
               gFRS_DocusignAttachPDF.InsertDocument(trigger.new[i].Id);
               SendToDocuSignController.SendNow(trigger.new[i].Id);
           }
        }
    }
   }   
}