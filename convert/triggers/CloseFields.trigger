trigger CloseFields on Issue_Log__c (before update) {
    String Errormsg='Please complete the following field in order to close the issue :';
    String defaultErrorMsg='Please complete the following field in order to close the issue :';
    
    for(Issue_Log__c IssueLog: Trigger.new)
    {   
        system.debug('IssueLog@@@'+IssueLog);
        system.debug('Detection_Method__c@@@'+IssueLog.Detection_Method__c);
        system.debug('Issue_Status__c@@@'+IssueLog.Issue_Status__c);
        
        if(IssueLog.Issue_Status__c == 'Closed' &&
           (
               (string.isblank(IssueLog.Detection_Method__c ) || string.isblank(IssueLog.Detection_Description__c) || string.isblank(IssueLog.Cause_Description__c) || string.isblank(IssueLog.Corrective_Action__c) ||  string.isblank(IssueLog.Corrective_Action_By__c) || string.isblank(IssueLog.Issue_Owner__c) ||
                string.isblank(IssueLog.Accountable_Team__c) || 
                string.isblank(IssueLog.Reporting_Period__c) || string.isblank(IssueLog.Pricing_Calculation_Impacted__c) || 
                string.isblank(IssueLog.System__c) || string.isblank(IssueLog.Restatement_Required__c)) || 
               IssueLog.Close_Date__c == NULL || IssueLog.Total_Time_Spent__c == NULL || 
               (IssueLog.Issue_Type__c == 'Recurring' && string.isblank(IssueLog.GP_Issue_Parent_Id__c)) ||
               (IssueLog.Accountable_Team__c == 'Contract Operations' && string.isblank(IssueLog.Corresponding_issue_id__c)) ||
               (IssueLog.GP_Issue_Reason_Code__c =='Other' && string.isblank(IssueLog.Description_Reason_Code_Detail__c )) || 
               string.isblank(IssueLog.GP_Issue_Reason_Code__c) ||
               (IssueLog.Restatement_Required__c == 'Yes' && IssueLog.Resubmission_Date__c == NULL) 
           )
          )
        {
            if(string.isblank(IssueLog.Detection_Method__c )){ 
                Errormsg=defaultErrorMsg+ '"Detection Method"';
                system.debug('Errormsg@@@'+Errormsg);
                IssueLog.Detection_Method__c.addError(Errormsg);
                Errormsg='';
                
            }            
            if(string.isblank(IssueLog.GP_Issue_Reason_Code__c)){
                if(Errormsg.contains('"'))
                {
                    Errormsg=defaultErrorMsg+'"Reason Code"';
                    
                    IssueLog.GP_Issue_Reason_Code__c.addError(Errormsg);
                    Errormsg='';
                }
                else
                {
                    Errormsg=defaultErrorMsg+'"Reason Code"';
                    system.debug('Errormsg@@@'+Errormsg);
                    IssueLog.GP_Issue_Reason_Code__c.addError(Errormsg);
                    Errormsg='';
                }
            }
            if(string.isblank(IssueLog.Detection_Description__c)){
                if(Errormsg.contains('"'))
                {
                    Errormsg=defaultErrorMsg+'"Detection Description"';
                    IssueLog.Detection_Description__c.addError(Errormsg);
                    Errormsg='';
                }
                else
                {
                    Errormsg=defaultErrorMsg+'"Detection Description"';
                    system.debug('Errormsg@@@'+Errormsg);
                    IssueLog.Detection_Description__c.addError(Errormsg);
                    Errormsg='';
                }
            }
            if(string.isblank(IssueLog.Cause_Description__c)){
                if(Errormsg.contains('"'))
                {
                    Errormsg=defaultErrorMsg+'"Cause Description"';
                    IssueLog.Cause_Description__c.addError(Errormsg);
                    Errormsg='';
                }
                else {
                    Errormsg=defaultErrorMsg+'"Cause Description"';
                    system.debug('Errormsg@@@'+Errormsg);
                    IssueLog.Cause_Description__c.addError(Errormsg);
                    Errormsg='';
                }
            }
            
            if(string.isblank(IssueLog.Corrective_Action__c)){
                if(Errormsg.contains('"'))
                {
                    Errormsg=defaultErrorMsg+'"Corrective Action"';
                    IssueLog.Corrective_Action__c.addError(Errormsg);
                    Errormsg='';
                }
                else
                {
                    Errormsg=defaultErrorMsg+'"Corrective Action"';
                    system.debug('Errormsg@@@'+Errormsg);
                    IssueLog.Corrective_Action__c.addError(Errormsg);
                    Errormsg='';
                }
            }
            if(string.isblank(IssueLog.Corrective_Action_By__c)){
                if(Errormsg.contains('"'))
                {
                    Errormsg=defaultErrorMsg+'"Corrective Action By"';
                    IssueLog.Corrective_Action_By__c.addError(Errormsg);
                    Errormsg='';
                }
                else
                {
                    Errormsg=defaultErrorMsg+'"Corrective Action By"';
                    system.debug('Errormsg@@@'+Errormsg);
                    IssueLog.Corrective_Action_By__c.addError(Errormsg);
                    Errormsg='';
                }
            }
            if(IssueLog.Issue_Type__c == 'Recurring' && string.isblank(IssueLog.GP_Issue_Parent_Id__c)){
                if(Errormsg.contains('"'))
                {
                    Errormsg=defaultErrorMsg+'"Parent-ID"';
                    IssueLog.GP_Issue_Parent_Id__c.addError(Errormsg);
                    Errormsg='';
                }
                else
                {
                    Errormsg=defaultErrorMsg+'"Parent-ID"';
                    system.debug('Errormsg@@@'+Errormsg);
                    IssueLog.GP_Issue_Parent_Id__c.addError(Errormsg);
                    Errormsg='';
                }
            }
            if(IssueLog.Accountable_Team__c == 'Contract Operations' && string.isblank(IssueLog.Corresponding_issue_id__c)){
                if(Errormsg.contains('"'))
                {
                    Errormsg=defaultErrorMsg+'"Corresponding Issue ID"';
                    IssueLog.Corresponding_issue_id__c.addError(Errormsg);
                    Errormsg='';
                }
                else
                {
                    Errormsg=defaultErrorMsg+'"Corresponding Issue ID"';
                    system.debug('Errormsg@@@'+Errormsg);
                    IssueLog.Corresponding_issue_id__c.addError(Errormsg);
                    Errormsg='';
                }
            }
            if(IssueLog.GP_Issue_Reason_Code__c =='Other'){
                if(string.isblank(IssueLog.Description_Reason_Code_Detail__c)){
                    if(Errormsg.contains('"'))
                    {
                        Errormsg=defaultErrorMsg+'"Other Description Reason Code"';
                        IssueLog.Description_Reason_Code_Detail__c.addError(Errormsg);
                        Errormsg='';
                    }
                    else
                    {
                        Errormsg=defaultErrorMsg+'"Other Description Reason Code"';
                        system.debug('Errormsg@@@'+Errormsg);
                        IssueLog.Description_Reason_Code_Detail__c.addError(Errormsg);
                        Errormsg='';
                    }
                }  
            }
            if(IssueLog.Restatement_Required__c == 'Yes' && IssueLog.Resubmission_Date__c == NULL){
                if(Errormsg.contains('"'))
                {
                    Errormsg=defaultErrorMsg+'"Resubmission Date"';
                    IssueLog.Resubmission_Date__c.addError(Errormsg);
                    Errormsg='';
                }
                else
                {
                    Errormsg=defaultErrorMsg+'"Resubmission Date"';
                    system.debug('Errormsg@@@'+Errormsg);
                    IssueLog.Resubmission_Date__c.addError(Errormsg);
                    Errormsg='';
                }
            }  
            if(IssueLog.Close_Date__c == NULL){
                if(Errormsg.contains('"'))
                {
                    Errormsg=defaultErrorMsg+'"Date All Actions Completed"';
                    IssueLog.Close_Date__c.addError(Errormsg);
                    Errormsg='';
                }
                else
                {
                    Errormsg=defaultErrorMsg+'"Date All Actions Completed"';
                    system.debug('Errormsg@@@'+Errormsg);
                    IssueLog.Close_Date__c.addError(Errormsg);
                    Errormsg='';
                }
            } 
            if(IssueLog.Total_Time_Spent__c == NULL){
                if(Errormsg.contains('"'))
                {
                    Errormsg=defaultErrorMsg+'"Total Time Spent"';
                    IssueLog.Total_Time_Spent__c.addError(Errormsg);
                    Errormsg='';
                }
                else
                {
                    Errormsg=defaultErrorMsg+'"Total Time Spent"';
                    system.debug('Errormsg@@@'+Errormsg);
                    IssueLog.Total_Time_Spent__c.addError(Errormsg);
                    Errormsg='';
                }
            } 
            if(string.isblank(IssueLog.Issue_Owner__c)){
                if(Errormsg.contains('"'))
                {
                    Errormsg=defaultErrorMsg+'"Issue Owner"';
                    IssueLog.Issue_Owner__c.addError(Errormsg);
                    Errormsg='';
                }
                else
                {
                    Errormsg=defaultErrorMsg+'"Issue Owner"';
                    system.debug('Errormsg@@@'+Errormsg);
                    IssueLog.Issue_Owner__c.addError(Errormsg);
                    Errormsg='';
                }
            }                      
            if(string.isblank(IssueLog.Accountable_Team__c)){ 
                Errormsg=defaultErrorMsg+'"Accountable Team"';                
                system.debug('Errormsg@@@'+Errormsg);
                IssueLog.Accountable_Team__c.addError(Errormsg);
                Errormsg='';
                
            } 
            if(string.isblank(IssueLog.Reporting_Period__c)){ 
                Errormsg=defaultErrorMsg+'"Reporting Period"';                
                system.debug('Errormsg@@@'+Errormsg);
                IssueLog.Reporting_Period__c.addError(Errormsg);
                Errormsg='';
                
            }
            if(string.isblank(IssueLog.Pricing_Calculation_Impacted__c)){ 
                Errormsg=defaultErrorMsg+'"Pricing Calculation Impacted"';                
                system.debug('Errormsg@@@'+Errormsg);
                IssueLog.Pricing_Calculation_Impacted__c.addError(Errormsg);
                Errormsg='';
                
            }
            if(string.isblank(IssueLog.System__c)){ 
                Errormsg=defaultErrorMsg+'"System"';                
                system.debug('Errormsg@@@'+Errormsg);
                IssueLog.System__c.addError(Errormsg);
                Errormsg='';
                
            }
            
            if(string.isblank(IssueLog.Restatement_Required__c)){ 
                Errormsg=defaultErrorMsg+'"Restatement Required"';                
                system.debug('Errormsg@@@'+Errormsg);
                IssueLog.Restatement_Required__c.addError(Errormsg);
                Errormsg='';
                
            }
            
            //IssueLog.addError(Errormsg);
        }         
    }
}