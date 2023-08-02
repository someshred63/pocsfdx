/**
* @author GFRS Dev Team - MG
* @date 29/09/2015
* @description gFRS_MERGMonthlyStatusReport - main batch class for MERG Send monthly status report reminder emails to requesters with grants in sub-status = Status Updates/Outcomes 
* http://jira.intranet.roche.com/jira/browse/GFRS-439 
*/
global without sharing class gFRS_MERGMonthlyStatusReport implements Database.Batchable<sObject>
{   
    global Database.Querylocator start(Database.BatchableContext BC)
    {
        String query = 'select Id, Name, OwnerId, Event_Program_Title__c, Owner_First_Name_Last_Name__c' 
        +' from GFRS_Funding_Request__c  where RecordType.Name=\'IMED\' and Status__c!=\'Closed\'' 
        +' and Sub_Status__c=\'Approved-Status Updates/Outcomes\''
        +' and (Program_Start_Date_Min__c < TODAY and Program_End_Date_max__c > TODAY)';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        
        List<GFRS_Funding_Request__c> reqlist =  (List<GFRS_Funding_Request__c>)scope;
        system.debug('Number of request to send notification ->' + reqList.Size());
        
        List<gFRS_EmailMessageWrapper> listEmailMessageWrapper = new List<gFRS_EmailMessageWrapper>();
        
        for(GFRS_Funding_Request__c f :  reqlist) 
        {           
                Map<String, String> mapSubjectParams = new Map<String, String> {
                    '{!GFRS_Funding_Request__c.Name}' => f.Name
                };
                
                Map<String, String> mapBodyParams = new Map<String, String> {
                    '#GFRS_Funding_Request__c.Name#' => f.Name,
                    '#GFRS_Funding_Request__c.Event_Program_Title__c#' => f.Event_Program_Title__c,
                    '#GFRS_Funding_Request__c.Owner_First_Name_Last_Name__c#' => f.Owner_First_Name_Last_Name__c
                    
                };
                
                listEmailMessageWrapper.add(new gFRS_EmailMessageWrapper('fundingrequestsystem-donotreply-d@gene.com', f.OwnerId, null, mapSubjectParams, mapBodyParams));
        }
        system.debug('listEmailMessageWrapper.size()->' + listEmailMessageWrapper.size());
        if(listEmailMessageWrapper.size() > 0)
        {
            gFRS_EmailUtility.sendEmail(listEmailMessageWrapper, 'gFRS IMED Monthly Status Updates/Outcomes');
            system.debug('Emails has been sent');
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        system.debug('Execution of gFRS_MERGMonthlyStatusReport ended successfully');
    }
    
}