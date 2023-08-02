/**
* @author GFRS Dev Team
* @date 25/08/2015
* @description gFRS_CreateAnnualReportTasksBatch class - Batch job responsible for creating Annual Report tasks for Foundation Fellowships. 
*/
global with sharing class gFRS_CreateAnnualReportTasksBatch  implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext BC){
        gFRS_SOQLBuilder query = new gFRS_SOQLBuilder()
        .selectFields(new String[] {'Name', 'Program_End_Date_max__c', 'Program_Start_Date_Min__c', 'Sub_Status__c', 'OwnerId'})
        .fromObject('GFRS_Funding_Request__c')
        .whereField('Record_Type_Name__c', '=', 'Fellowships')
        .whereField('AND', 'Foundation_Classified__c', '=', 'TRUE')
        .whereField('AND', 'LOA_Signed__c', '=', 'Yes')
        .whereField('AND', 'Sub_Status__c', 'IN', new String[] {'Approved', 'Approved-Program Evaluations'});
        return query.getQueryLocator();
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Map<ID, gFRS_Funding_Request__c> mapFundRequests = new Map<ID, gFRS_Funding_Request__c>((List<GFRS_Funding_Request__c>)scope);
        Map<Integer, List<GFRS_Funding_Request__c>> mapYearToRequests = new Map<Integer, List<GFRS_Funding_Request__c>>();
        for (Integer i = -5; i <= 0; i++) {
            mapYearToRequests.put(i, new List<gFRS_Funding_Request__c>());
        }
        
        for (GFRS_Funding_Request__c request : mapFundRequests.values()) {
            Integer currentYear = 0;       
            if ( request.Program_End_Date_max__c == Date.today() ) {
                mapYearToRequests.get(currentYear).add(request);
                    }
            else if ( request.Program_Start_Date_Min__c < Date.today() ) {
                for (Integer i = -5 ; i < 0 ; i++ ) {
                    if ( request.Program_End_Date_max__c.addYears(i) == Date.today() ) {
                        mapYearToRequests.get(i).add(request);
            }
        }
        }
    }

        List<gFRS_Tasks__c> lTasksToInsert = new List<gFRS_Tasks__c>();
        List<gFRS_Funding_Request__c> lRequestsToUpdate = new List<gFRS_Funding_Request__c>();
        
        for (Integer yearBefore : mapYearToRequests.keySet()) {
            List<GFRS_Funding_Request__c> lRequests = excludeRequestsWithAlreadyCreatedTasksForToday(yearBefore, mapYearToRequests.get(yearBefore));
            lTasksToInsert.addAll ( generateTasks(yearBefore, lRequests) );
            lRequestsToUpdate.addAll( lRequests );
    }
    
        try {
            insert lTasksToInsert;
            }
        catch (Exception ex) {
            System.debug('gFRS: Error occured while inserting gFRS Tasks.');
            System.debug(ex.getMessage());
            }
        gFRS_Annual_EvaluationTriggerUtil.updateRequestsSubStatusesToEvaluation(lRequestsToUpdate);
    }
    
    global void finish(Database.BatchableContext BC) {
        
        }
        
    private List<GFRS_Funding_Request__c> excludeRequestsWithAlreadyCreatedTasksForToday(Integer yearBefore, List<GFRS_Funding_Request__c> myRequestsList) {
        Map<Id, GFRS_Funding_Request__c> mapRequestsWithoutTasks = new Map<Id, GFRS_Funding_Request__c>(myRequestsList);
        for (gFRS_Tasks__c task : [SELECT Id, gFRS_Funding_Request__c FROM gFRS_Tasks__c
                                   WHERE Action_Type__c = 'Annual Evaluation'
                                           AND gFRS_Funding_Request__c IN :myRequestsList
                                           AND CreatedDate >= :Date.today()
                                           AND Years_Before_Annual_Evaluation__c = :yearBefore]) {
            mapRequestsWithoutTasks.remove(task.gFRS_Funding_Request__c);
        }
        return mapRequestsWithoutTasks.values();
    }
        
    public List<gFRS_Tasks__c> generateTasks(Integer yearBefore, List<GFRS_Funding_Request__c> myRequestsList) {
        List<gFRS_Tasks__c> lTasks = new List<gFRS_Tasks__c>();

        for (GFRS_Funding_Request__c request : myRequestsList) {
            lTasks.add(
                new gFRS_Tasks__c(
                    Status__c = 'Not Submitted',
                    Subject__c = 'Annual Evaluation Required',
                    Description__c = ' Please provide the Annual Evaluation for Funding Request: ' + request.Name,
                    gFRS_Funding_Request__c = request.Id, User__c = request.OwnerId,
                    Action_Type__c = 'Annual Evaluation',
                    Years_Before_Annual_Evaluation__c = yearBefore)
            );
        }
        return lTasks;
    }
}