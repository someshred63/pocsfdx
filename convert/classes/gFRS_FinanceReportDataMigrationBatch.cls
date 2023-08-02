global with sharing class gFRS_FinanceReportDataMigrationBatch implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Name, Accountable_Employee__c, Amount__c, Biogen_Idec_WBS_Logos__c, Collaboration_Partner__c, Commercial_Activity_ID__c, Cost_Center__c, CreatedById, CreatedDate, Funding_Allocation__c, Funding_Record_Type__c, GL_Account_Code__c, Grant_Request__c, IsDeleted, IsLocked, LastModifiedById, LastModifiedDate, Line_Item_Total__c, Line_Item_Total_Literal__c, MayEdit, Percent__c, Request_Name__c, Split_Number__c, SystemModstamp, Tactic_WBS__c, WBS__c, WBS_Code_Lookup__c, WBS_Description__c, WBS_Element__c FROM GFRS_Funding_Allocation_Line_Item__c WHERE Id NOT IN (SELECT FundingAllocationLine__c FROM gFRS_Finance_Report_Junction__c)';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        List<GFRS_Funding_Allocation_Line_Item__c> items = (List<GFRS_Funding_Allocation_Line_Item__c>)scope;
        try{
           gFRS_Util_NoShare.insertFinanceReportJunction(items);

        }
        catch(Exception ex){        
            System.debug(LoggingLevel.WARN, 'finance repport migration data warning: '+ex.getMessage());
        }

    }

    global void finish(Database.BatchableContext BC){
        
    }
}