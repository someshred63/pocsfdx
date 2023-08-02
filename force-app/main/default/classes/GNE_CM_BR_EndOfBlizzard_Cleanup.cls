global class  GNE_CM_BR_EndOfBlizzard_Cleanup implements Database.Batchable<sObject> 
{  
    global Database.QueryLocator start(Database.BatchableContext BC)    {     
       //return Database.getQueryLocator([SELECT id,  status_gne__C, product_gne__C from GNE_CM_MPS_BRC_RituxanRA__c where status_gne__c = 'Draft' and product_gne__c in ('Actemra','Lucentis') ]);  
       return Database.getQueryLocator([SELECT id,  status_gne__C, product_gne__C 
       									FROM GNE_CM_MPS_BRC_RituxanRA__c 
       									WHERE product_gne__c in ('Actemra','Lucentis') ]);  
    }       
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
      delete scope;    
    }

   global void finish(Database.BatchableContext BC){
   }
}