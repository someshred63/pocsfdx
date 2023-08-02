global without sharing class EMS_Product_Budget_Assignment_Batch implements Database.Batchable<sObject>, Database.Stateful {

    global Map<String, Set<Id>> territoryToUserMap = new Map<String, Set<Id>>(); // territory id, List<user id>
    global Map<String, EMS_Util.EMS_Territory> territoriesMap = new Map<String, EMS_Util.EMS_Territory>(); // territory id, territory
    global Map<Id, String> budgetsWithNoTerritoryAssigned = new Map<Id, String>();

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Assigned_to_gne__c, Assigned_To_Territory_gne__c, Assigned_To_Territory_Id__c FROM EMS_Budget_Product_gne__c WHERE Status_gne__c = \'Active\'');
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        Set<String> territoryIds = new Set<String>();

        List<EMS_Budget_Product_gne__c> budgetsToUpdate = new List<EMS_Budget_Product_gne__c>();

        for (EMS_Budget_Product_gne__c pb : (List<EMS_Budget_Product_gne__c>) scope) {
            territoryIds.add(pb.Assigned_To_Territory_Id__c);
            territoryIds.add(pb.Assigned_To_Territory_Id__c);
        }

        territoryToUserMap.putAll(EMS_Util.getTerritoriesUsers(territoryIds));
        territoriesMap.putAll(EMS_Util.getTerritoriesByNames(territoryIds));

        // check territory assignments
        for (EMS_Budget_Product_gne__c pb : (List<EMS_Budget_Product_gne__c>) scope) {
            // owner territory
            if (territoryToUserMap.get(pb.Assigned_To_Territory_Id__c) != null && territoryToUserMap.get(pb.Assigned_To_Territory_Id__c).size() == 1) {
                if (pb.Assigned_to_gne__c != new List<Id>(territoryToUserMap.get(pb.Assigned_To_Territory_Id__c))[0]) {
                    pb.Assigned_to_gne__c = new List<Id>(territoryToUserMap.get(pb.Assigned_To_Territory_Id__c))[0];
                    budgetsToUpdate.add(pb);
                }
            } else {
                budgetsWithNoTerritoryAssigned.put(pb.Id, null);
            }
        }

        if (!budgetsToUpdate.isEmpty()) {
            EMS_Product_Budget_Helper.skipTriggerValidationRules = true;

            Database.SaveResult [] results = Database.update(budgetsToUpdate, false);
            for (Integer i = 0; i < results.size(); i++) {
                if (!results[i].isSuccess()) {
                    // add error
                    budgetsWithNoTerritoryAssigned.put(budgetsToUpdate[i].Id, results[i].getErrors()[0].getMessage());
                }
            }
        }

        // update budget allocations to refresh budget owner
        List<EMS_Budget_Allocation_gne__c> budgetAllocationsToUpdate = [SELECT Id FROM EMS_Budget_Allocation_gne__c WHERE EMS_Product_Budget_gne__c IN :budgetsToUpdate];
        update budgetAllocationsToUpdate;
    }


    global void finish(Database.BatchableContext BC) {
        // create assignment error record
        // select record types
        RecordType productBudgetAssignmentErrorRT = [SELECT Id FROM RecordType WHERE SObjectType = 'EMS_Assignment_Error_gne__c' AND DeveloperName = 'Product_Budget_Assignment_Error' LIMIT 1];
        // select existing assignment errors
        Map<String, EMS_Assignment_Error_gne__c> existingAssignmentErrors = new Map<String, EMS_Assignment_Error_gne__c>();

        for (EMS_Assignment_Error_gne__c assignmentError : [SELECT EMS_Product_Budget_gne__c, RecordTypeId FROM EMS_Assignment_Error_gne__c WHERE EMS_Product_Budget_gne__c != null]) {
            existingAssignmentErrors.put(String.valueOf(assignmentError.EMS_Product_Budget_gne__c) + String.valueOf(assignmentError.RecordTypeId), assignmentError);
        }

        List<EMS_Assignment_Error_gne__c> assignmentErrorsToUpsert = new List<EMS_Assignment_Error_gne__c>();
        List<EMS_Assignment_Error_gne__c> assignmentErrorsToDelete = [SELECT Id FROM EMS_Assignment_Error_gne__c WHERE EMS_Product_Budget_gne__c NOT IN :budgetsWithNoTerritoryAssigned.keySet() AND RecordTypeId = :productBudgetAssignmentErrorRT.Id];

        // clear old errors first
        if (!assignmentErrorsToDelete.isEmpty()) {
            Database.delete(assignmentErrorsToDelete, false);
        }

        for (Id pbId : budgetsWithNoTerritoryAssigned.keySet()) {
            String errorMessage = 'Could not assign the product budget to the new owner. ';
            if (!String.isBlank(budgetsWithNoTerritoryAssigned.get(pbId))) {
                errorMessage += budgetsWithNoTerritoryAssigned.get(pbId);
            }

            if (!existingAssignmentErrors.containsKey(String.valueOf(pbId) + String.valueOf(productBudgetAssignmentErrorRT.Id))) {
                assignmentErrorsToUpsert.add(new EMS_Assignment_Error_gne__c(Status_gne__c = 'New', EMS_Product_Budget_gne__c = pbId, Error_Message_gne__c = errorMessage, RecordTypeId = productBudgetAssignmentErrorRT.Id));
            } else {
                existingAssignmentErrors.get(String.valueOf(pbId) + String.valueOf(productBudgetAssignmentErrorRT.Id)).Error_Message_gne__c = errorMessage;
                assignmentErrorsToUpsert.add(existingAssignmentErrors.get(String.valueOf(pbId) + String.valueOf(productBudgetAssignmentErrorRT.Id)));
            }
        }

        if (!assignmentErrorsToUpsert.isEmpty()) {
            Database.upsert(assignmentErrorsToUpsert, false);
        }
    }
}