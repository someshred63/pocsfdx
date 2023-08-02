global class InteractionsWithMeals implements Database.Batchable<SObject> {    
    
    /*   String query = 'Select id, account_vod__c,Meal_Expense_gne__c,parent_call_vod__c from call2_vod__c '
            + 'where (meal_expense_gne__c = true or parent_call_vod__r.meal_expense_gne__c = true) ' 
            + 'and account_vod__c <> null and account_vod__r.mdmid_gne__c = null ';
    */
    
     // Main SOQL query
    String query = ' Select id,Account_vod__c from call2_vod__c  ' +
                   ' where (meal_expense_gne__c = true or parent_call_vod__r.meal_expense_gne__c = true) ' +
                   '       and account_vod__c <> null ' + 
                   '       and account_vod__r.mdmid_gne__c = null ';
    // string to store email id of user who sumbitted Job
    // this id is passed from main class
    private final String email;
    private final String rptURL;

    
    
    // constructor to assign email id passed from main class to the local variable     
    global InteractionsWithMeals(String str, String URL){
        this.email = str;
        this.rptURL = URL;
    }
    
    // Runs SOQL to get all records in QueryLocator
    // Querylocator has no limits to number of records returned by SOQL    

    global Database.QueryLocator start(Database.BatchableContext bc) {        
        return Database.getQueryLocator (query);    
    } 

    // Execute function called in loop with each batch of 200 records.
    // if there are 2000 records, execute function will be called 10 times
    // this batch log can be viewed in App Setup->Monitoring->Apex Jobs
        
    global void execute(Database.BatchableContext bc, SObject[] call2List){     
        // Assign each record value to sobject record 
        Set<String> callIdSet = new Set<String>();
        try {
    
                List<Account_Interaction_Expense_rpt_gne__c> callList = new List<Account_Interaction_Expense_rpt_gne__c>();
        
                for (SObject c: call2List){

                    // Type casting to access call2_vod__c fields                    
                    Call2_vod__c call2Record = (Call2_vod__c) c;
                    
                    Account_Interaction_Expense_rpt_gne__c callRecord = new Account_Interaction_Expense_rpt_gne__c();
        
                    callRecord.Call_id_gne__c = call2Record.id;
                    callRecord.Call_gne__c    = call2Record.id;
                    callRecord.Meals_gne__c   = 1;
                    callRecord.Account_Id_gne__c = call2Record.Account_vod__c;

                    // callList.add (callRecord); 
                    if ( callIdSet.contains(callRecord.call_id_gne__c) == false )
                            CallList.add (callRecord); 
 
                        callIdSet.add ( callRecord.call_id_gne__c );   
                }
                if (CallList.size() > 0 ) {
                    upsert CallList Call_id_gne__c;
                    CallList.clear();
                }
                
        }
        catch ( exception e){
                System.debug ( 'Exception occured. getMessage--> ' + e.getMessage() );
        }
    }
    
    global void finish(Database.BatchableContext BC){      
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
       // mail.setPlainTextBody ('The batch Apex job processed ' + a.TotalJobItems +            
       //                         ' batches with ' + a.NumberOfErrors +
       //                         ' failures.\n Link to Report is ' + this.rptURL );                
        
        mail.setPlainTextBody ('Report generation of all the interactions with spend (meals or gifts) ' +
                                ' for which the attendees to the  interactions are not ' +
                                ' identified by an MDM ID is completed.' +            
                                ' \n\n Click following link to view report  ' + this.rptURL );                
       
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });    
    }   
} //class end