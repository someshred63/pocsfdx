global class InteractionsWithGifts implements Database.Batchable<SObject> {     
    
    // Main SOQL query
    // Get all Calls with Gifts and account MDM Id=Null
    String query = ' select call2_vod__c, call2_vod__r.Account_vod__c  ' +  
                    ' from call2_sample_vod__c ' +
                    ' where product_vod__r.product_type_vod__c like \'gift\' ' +
                    '       and call2_vod__r.account_vod__c <> null ' +  
                    '       and call2_vod__r.account_vod__r.mdmid_gne__c = null  ';

/*
    // string to store email address of user who sumbitted Job
    // this email address is passed from main class
    private final String email;

    // constructor to assign email id passed from main class to the local variable     
    global InteractionsWithGifts(String str){
        this.email = str;
    }
*/    
    // Runs SOQL to get all records in QueryLocator
    // Querylocator has no limits to number of records returned by SOQL    
    global Database.QueryLocator start(Database.BatchableContext bc) {         
        return Database.getQueryLocator (query);    
    } 
    
    // Execute function called in loop with each batch of 200 records.
    // if there are 2000 records, execute function will be called 10 times
    // this batch log can be viewed in App Setup->Monitoring->Apex Jobs
    
    global void execute(Database.BatchableContext bc, SObject[] CallSampleList){     
        // Assign each record value to sobject record 

        Set<String> callIdSet = new Set<String>();
                    
        try{
                List<Account_Interaction_Expense_rpt_gne__c> CallList = new List<Account_Interaction_Expense_rpt_gne__c>();
        
                for (SObject callSample: CallSampleList) {
                
                        // Type casting to access call2_sample_vod__c fields
                        Call2_Sample_vod__c callSampleRecord = (Call2_Sample_vod__c) callSample;                    
                
                        Account_Interaction_Expense_rpt_gne__c callRecord = new Account_Interaction_Expense_rpt_gne__c();
                  
                        callRecord.Call_id_gne__c  = callSampleRecord.call2_vod__c;                     
                        callRecord.Call_gne__c     = callSampleRecord.call2_vod__c; 
                        callRecord.Gifts_gne__c    = 1;                 
                        callRecord.Account_Id_gne__c = callSampleRecord.call2_vod__r.Account_vod__c;
                        
                        if ( callIdSet.contains(callRecord.call_id_gne__c) == false )
                            CallList.add (callRecord); 

                        callIdSet.add ( callRecord.call_id_gne__c );    
                            
                }
            
                if (CallList.size() > 0 ) {
                    // 1. Call samples can have multiple entries for same call
                    // 2. Another class InteractionsWithMeals is executed simultaneously with this class,
                    //    One call can have both Meal Expense and gifts, so both classes will try inserting 
                    //    same call id in the SObject
                    // So to avoid duplicate calls Use upsert instead of insert 
                    // Call_id_gne__c is the external Id of the SObject

                    upsert CallList Call_id_gne__c;
                    CallList.clear();
                }

        }
        catch ( exception e){
            System.debug ( 'Exception occured. getMessage--> ' + e.getMessage() );
        }
    }
    
    global void finish(Database.BatchableContext BC){      
/*
        // Get the ID of the AsyncApexJob representing this batch job    
        // from Database.BatchableContext.    
        // Query the AsyncApexJob object to retrieve the current job's information.    
        
        AsyncApexJob a = [Select Id, Status, NumberOfErrors,                       
                            JobItemsProcessed, TotalJobItems, CreatedBy.Email                        
                            from AsyncApexJob                         
                            where Id =:BC.getJobId()];                            
        // Send an email to the Apex job's submitter notifying of job completion.    
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();    
        String[] toAddresses = new String[] {this.email};    
        mail.setToAddresses(toAddresses);    
        mail.setSubject('Apex Job status ' + a.Status);    
        mail.setPlainTextBody ('The batch Apex job to Get all interactions With Gifts is now complete. Job processed ' + a.TotalJobItems +            
                                ' batches with ' + a.NumberOfErrors +
                                ' failures.\n'  );                
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });    
*/
    }
} //class end