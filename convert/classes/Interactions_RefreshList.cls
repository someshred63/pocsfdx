global class Interactions_RefreshList implements Database.Batchable<SObject> {    
    
    /*   String query = 'Select id, account_vod__c,Meal_Expense_gne__c,parent_call_vod__c from call2_vod__c '
            + 'where (meal_expense_gne__c = true or parent_call_vod__r.meal_expense_gne__c = true) ' 
            + 'and account_vod__c <> null and account_vod__r.mdmid_gne__c = null ';
    */
    
    // Get all records for which Account MDM Id has been assigned after last report generation.
    
    String query = ' Select id from Account_Interaction_Expense_rpt_gne__c ' +
                   ' where Call_gne__r.account_vod__r.mdmid_gne__c <> null ';

    
    // Querylocator has no limits to number of records returned by SOQL    
    global Database.QueryLocator start(Database.BatchableContext bc) {        
        return Database.getQueryLocator (query);    
    } 
    
    // Execute function called in loop with each batch of 200 records.
    // if there are 2000 records, execute function will be called 10 times
    // this batch log can be viewed in App Setup->Monitoring->Apex Jobs
    
    global void execute(Database.BatchableContext bc, SObject[] CallList){     
        try {
                // delete all records fetched in the list
                delete CallList;
                CallList.clear();
        }
        catch ( exception e){
                System.debug ( 'Exception occured. getMessage--> ' + e.getMessage() );
        }
    }
    
    global void finish(Database.BatchableContext BC){      
         
    }   
} //class end