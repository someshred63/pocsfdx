global class ProductOrderItemExternalIDGeneration implements Database.Batchable<sObject>{
	

   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator('select UniqueKey__c, order__r.SAP_Order_ID__c, SAP_Line_Number_gne__c from Product_Order_Item_gne__c');
   }

   global void execute(Database.BatchableContext BC, List <Product_Order_Item_gne__c> items){
   	 
     for(Product_Order_Item_gne__c item: items){
     	item.UniqueKey__c=item.order__r.SAP_Order_ID__c+item.SAP_Line_Number_gne__c;
     }
     update items;
    }

   global void finish(Database.BatchableContext BC){
   	  AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
      TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
   // Send an email to the Apex job's submitter notifying of job completion.
   Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
   String[] toAddresses = new String[] {a.CreatedBy.Email, 'jiezhenw@gene.com'};
   mail.setToAddresses(toAddresses);
   mail.setSubject('Apex Sharing Recalculation ' + a.Status);
   mail.setPlainTextBody
   ('The batch Apex job processed ' + a.TotalJobItems +
   ' batches with '+ a.NumberOfErrors + ' failures.');
   Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   	 
   }
	
 	
}