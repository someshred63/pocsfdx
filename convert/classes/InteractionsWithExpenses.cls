public class InteractionsWithExpenses{
    
    /*
        1. Get Email address of logged in user
        2. Call batch apex class to delete calls from custom Soject Accoun_Interaction_Expense_rpt
           if Account MDM Id have been assigned
        3. Call batch apex class to insert all calls with meals to custom Soject Accoun_Interaction_Expense_rpt
           Email Address is passed as parameter to the constructor   
        4. Call batch apex class to insert all calls with gifts to custom Soject Accoun_Interaction_Expense_rpt
           Email Address is passed as parameter to the constructor
        5. Classes in steps 3 & 4 uses Upsert instead of insert so to avoid duplications
           Call Id is used as External Id for Upsert             
    */
   
   
    String LastExecutionDate;
    String JobStartedBy;
    String JobStartTime;
    
    public InteractionsWithExpenses() {
            // needs at least one row
            try{
            
                Datetime d = [select LASTMODIFIEDDATE from Account_Interaction_Expense_rpt_gne__c 
                    Order by LASTMODIFIEDDATE desc Limit 1].LASTMODIFIEDDATE;
            
                Long diff = system.now().getTime() - d.getTime();
                Long tmp;
                LastExecutionDate  ='';
                If ( diff > 0)
                {
                     tmp = diff / (1000*60*60*24);
                     if (tmp > 0 )
                     {
                         if (tmp > 1) 
                             LastExecutionDate  = String.valueOf(tmp) + ' Days ';
                         else
                             LastExecutionDate  = String.valueOf(tmp) + ' Day ';

                         
                         diff = diff - (tmp*1000*60*60*24);
                     }
                 
                     tmp = diff / (1000*60*60);
                     if (tmp > 0 )
                     {
                         if (tmp > 1) 
                             LastExecutionDate  = LastExecutionDate  + String.valueOf(tmp) + ' Hours ';
                         else
                             LastExecutionDate  = LastExecutionDate  + String.valueOf(tmp) + ' Hour ';
                             
                         diff = diff - (tmp*1000*60*60);
                     }
                 
                     tmp = diff / (1000*60);
                     if (tmp > 0 )
                     {
                         if (tmp > 1) 
                             LastExecutionDate  = LastExecutionDate  + String.valueOf(tmp) + ' Minutes';
                         else
                             LastExecutionDate  = LastExecutionDate  + String.valueOf(tmp) + ' Minute';
                     }                 
                } 
            }
            catch(Exception e)
            {
                LastExecutionDate = '';
            }
           // LastExecutionDate =String.Valueof(System.now());
            //LastExecutionDate = String.ValueOf(d.format('MM-dd-yyyy HH:mm'));                              
    }    
    
    public Boolean getIsInteractionBatchApexRunning()
    {
            Boolean isActive = false;
         
            Integer numOfActiveBatchInstances = [Select count()
                                From AsyncApexJob a
                                Where status in ('Queued','Processing')
                                and a.ApexClass.Name in ('InteractionsWithMeals','InteractionsWithGifts','Interactions_RefreshList') ];
            
            if (numOfActiveBatchInstances > 0)
            {
                isActive = true;
                
                AsyncApexJob a = [Select a.CreatedDate, a.CreatedBy.Name, a.CreatedById 
                                    From AsyncApexJob a                        
                                    Where status in ('Queued','Processing')
                                    and a.ApexClass.Name in ('InteractionsWithMeals','InteractionsWithGifts','Interactions_RefreshList') limit 1 ];
                
                JobStartedBy = a.CreatedBy.Name;
                JobStartTime = String.valueof((a.CreatedDate).format('MM-dd-yyyy HH:mm a'));
            }
            return isActive;                
     }
    
    public String getLastExecutionDate()
    {
        return LastExecutionDate;
    }
    
    public String getJobStartedBy()
    {
        return JobStartedBy;
    }

    public String getJobStartTime()
    {
        return JobStartTime;
    }

    
    public PageReference openReport()
    {
         String rptURL ;
         Environment_variables__c env_list = [select key__c, value__c from environment_variables__C 
                                                   where key__c = 'ExpenseNoMDMIDReport'  ];
         rptURL = '//' + ApexPages.currentPage().getHeaders().get('Host') + '/' + env_list.value__c;


        PageReference pageRef = new PageReference(rptURL);
        return(pageRef);
    }
    
   
    
    public void process () {          
        String email;
        try {           
         
             String rptURL ;
             Environment_variables__c env_list = [select key__c, value__c from environment_variables__C 
                                                   where key__c = 'ExpenseNoMDMIDReport'  ];
             rptURL = '//' + ApexPages.currentPage().getHeaders().get('Host') + '/' + env_list.value__c;


            // 1. Get Email address of logged in user
            email = [Select email from user where id = :UserInfo.getUserId()].email;
        
            // 2. Call batch apex class to delete calls from custom Soject Accoun_Interaction_Expense_rpt
            //    if Account MDM Id have been assigned
            id batchinstanceid = database.executeBatch(new Interactions_RefreshList());
            
             // 3. Call batch apex class to insert all calls with meals to custom Soject Accoun_Interaction_Expense_rpt
            //     Email Address is passed as parameter to the constructor   
           id batchinstanceid2 = database.executeBatch(new InteractionsWithMeals(email,rptURL ));
 
            // 4. Call batch apex class to insert all calls with gifts to custom Soject Accoun_Interaction_Expense_rpt
            //    Email Address is passed as parameter to the constructor
            id batchinstanceid1 = database.executeBatch(new InteractionsWithGifts());

           
        }catch (Exception ex) {
           // use pagemessage tag in apex page
           // use ApexPages.addMessages in the controller here.
           // System.debug ('Exception Occurred in Class InteractionsWithExpenses ' + ex.getMessage() );
              ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR ,'Some problem while generating data for report. ' + ex.getMessage() +'\n Please contact SYS-Support.'));
              
        }                           
    }
}