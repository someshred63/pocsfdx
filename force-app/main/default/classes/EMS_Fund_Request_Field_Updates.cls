public without sharing class EMS_Fund_Request_Field_Updates {

    private static Map<Id, String> fundRequestRecordTypes = new Map<Id, String>();
    private static Map<Id, EMS_Budget_Region_gne__c> relatedRegionBudgets;
    private static Map<Id, EMS_Budget_Product_gne__c> relatedProductBudgets;
    private static Map<Id, EMS_Budget_Territory_gne__c> relatedTerritoryBudgets;
    private static Map<Id, GNE_User_Delegation__c> userDelegations; //Id -> OwnerId

	/**************************************************************************
	********************* Methods called by trigger ***************************
	**************************************************************************/

    public static void onBeforeUpdate(Map<Id, EMS_Fund_Request_gne__c> triggerOldMap, List<EMS_Fund_Request_gne__c> triggerNew) {
        userDelegations = EMS_Util.getUserDelegations();

        getObjectRecordTypes();
        getRelatedObjectFields(triggerNew);
        runFieldUpdatesOnUpdate(triggerOldMap, triggerNew);
    }

    public static void onBeforeInsert(List<EMS_Fund_Request_gne__c> triggerNew) {
        userDelegations = EMS_Util.getUserDelegations();

        getObjectRecordTypes();
        getRelatedObjectFields(triggerNew);

        for (EMS_Fund_Request_gne__c fundRequest : triggerNew) {
            overrideBudgetOwner(fundRequest, null);
            overrideApprover(fundRequest, null);
        }
    }

    private static void runFieldUpdatesOnUpdate(Map<Id, EMS_Fund_Request_gne__c> triggerOldMap, List<EMS_Fund_Request_gne__c> triggerNew) {
        Map<Id, List<ProcessInstanceStep>> targetObjectIdToStepMap = fetchApprovalSteps(triggerNew);

        for (EMS_Fund_Request_gne__c fundRequest : triggerNew) {
            overrideBudgetOwner(fundRequest, triggerOldMap.get(fundRequest.Id));
            overrideApprover(fundRequest, triggerOldMap.get(fundRequest.Id)); // before update
            escalateFundRequest(fundRequest, triggerOldMap.get(fundRequest.Id));
        }
    }
	
	/**************************************************************************
	**************************** Action methods *******************************
	**************************************************************************/
    private static void overrideBudgetOwner(EMS_Fund_Request_gne__c fundRequest, EMS_Fund_Request_gne__c fundRequestOld) {
        Id approverUserId = null;
        if (fundRequestRecordTypes.get(fundRequest.RecordTypeId) == 'Territory Fund Allocation') {
            if (relatedRegionBudgets.get(fundRequest.Related_Region_Budget_gne__c).Assigned_to_gne__c == null
                    && relatedTerritoryBudgets.get(fundRequest.Related_Territory_Budget_gne__c).EMS_Budget_Region_gne__r.EMS_Budget_Product_gne__r.Assigned_to_gne__c != null
                    ) {
                approverUserId = relatedTerritoryBudgets.get(fundRequest.Related_Territory_Budget_gne__c).EMS_Budget_Region_gne__r.EMS_Budget_Product_gne__r.Assigned_to_gne__c;
            } else {
                approverUserId = relatedRegionBudgets.get(fundRequest.Related_Region_Budget_gne__c).Assigned_to_gne__c;
            }
        } else if (fundRequestRecordTypes.get(fundRequest.RecordTypeId) == 'Region Fund Allocation') {
            approverUserId = relatedProductBudgets.get(fundRequest.Related_Product_Budget_gne__c).Assigned_to_gne__c;
        } else if (fundRequestRecordTypes.get(fundRequest.RecordTypeId) == 'Region Fund De-Allocation') {
            approverUserId = relatedRegionBudgets.get(fundRequest.Related_Region_Budget_gne__c).Assigned_to_gne__c;
        } else if (fundRequestRecordTypes.get(fundRequest.RecordTypeId) == 'Territory Fund De-Allocation') {
            approverUserId = relatedTerritoryBudgets.get(fundRequest.Related_Territory_Budget_gne__c).Assigned_to_gne__c;
        } else if (fundRequestRecordTypes.get(fundRequest.RecordTypeId) == EMS_Consts.RT_TRANSFER_REGION_FUNDS) {
            approverUserId = relatedRegionBudgets.get(fundRequest.Related_Region_Budget_gne__c).Assigned_to_gne__c;
        } else if (fundRequestRecordTypes.get(fundRequest.RecordTypeId) == EMS_Consts.RT_TRANSFER_TERRITORY_FUNDS) {
            approverUserId = relatedTerritoryBudgets.get(fundRequest.Related_Territory_Budget_gne__c).Assigned_to_gne__c;
        }

        fundRequest.Budget_Owner_gne__c = approverUserId;
    }

    private static void overrideApprover(EMS_Fund_Request_gne__c fundRequest, EMS_Fund_Request_gne__c fundRequestOld) {
        if (fundRequest.Status_gne__c == 'Submitted' && (fundRequestOld == null || fundRequestOld.Status_gne__c != 'Submitted')) {
            fundRequest.Approver_gne__c = getDelegatedUser(fundRequest.Budget_Owner_gne__c);
            if (fundRequest.Approver_gne__c == null) {
                // no approver was found - set the FC as the approver
                fundRequest.Top_Level_Approval_gne__c = true;
            }
        }
    }

    private static void escalateFundRequest(EMS_Fund_Request_gne__c fundRequest, EMS_Fund_Request_gne__c fundRequestOld) {
        if (fundRequest.Escalated_gne__c && !fundRequestOld.Escalated_gne__c) {
            Id approverUserId = null;
            if (fundRequestRecordTypes.get(fundRequest.RecordTypeId) == 'Territory Fund Allocation') {
                approverUserId = relatedRegionBudgets.get(fundRequest.Related_Region_Budget_gne__c).EMS_Budget_Product_gne__r.Assigned_to_gne__c;
            } else if (fundRequestRecordTypes.get(fundRequest.RecordTypeId) == 'Region Fund Allocation') {
                fundRequest.Top_Level_Approval_gne__c = true;
            } else if (fundRequestRecordTypes.get(fundRequest.RecordTypeId) == 'Region Fund De-Allocation') {
                approverUserId = relatedRegionBudgets.get(fundRequest.Related_Region_Budget_gne__c).Assigned_to_gne__c;
            } else if (fundRequestRecordTypes.get(fundRequest.RecordTypeId) == 'Territory Fund De-Allocation') {
                approverUserId = relatedTerritoryBudgets.get(fundRequest.Related_Territory_Budget_gne__c).Assigned_to_gne__c;
            } else if (fundRequestRecordTypes.get(fundRequest.RecordTypeId) == EMS_Consts.RT_TRANSFER_REGION_FUNDS) {
                fundRequest.Top_Level_Approval_gne__c = true;
            } else if (fundRequestRecordTypes.get(fundRequest.RecordTypeId) == EMS_Consts.RT_TRANSFER_TERRITORY_FUNDS) {
                approverUserId = relatedRegionBudgets.get(fundRequest.Related_Region_Budget_gne__c).EMS_Budget_Product_gne__r.Assigned_to_gne__c;
            }

            fundRequest.Approver_gne__c = getDelegatedUser(approverUserId);
            if (fundRequest.Approver_gne__c == null) {
                // no approver was found - set the FC as the approver
                fundRequest.Top_Level_Approval_gne__c = true;
            }
        }
    }

	/**************************************************************************
	**************************** Helper methods *******************************
	**************************************************************************/

    private static Id getDelegatedUser(Id mainUserId) {
        if (userDelegations.containsKey(mainUserId)) {
            return userDelegations.get(mainUserId).Delegated_User__c;
        }
        return mainUserId;
    }

    private static void getObjectRecordTypes() {
        Schema.DescribeSObjectResult obj = EMS_Fund_Request_gne__c.SObjectType.getDescribe();
        Map<Id, Schema.RecordTypeInfo> recordTypeInfos = obj.getRecordTypeInfosByID();
        for (Schema.RecordTypeInfo rtInfo : recordTypeInfos.values()) {
            fundRequestRecordTypes.put(rtInfo.getRecordTypeId(), rtInfo.getName());
        }
    }

    private static void getRelatedObjectFields(List<EMS_Fund_Request_gne__c> triggerNew) {

        List <Id> relatedBudgetsIds = new List <Id>();
        for (EMS_Fund_Request_gne__c request : triggerNew) {
            if (request.Related_Region_Budget_gne__c != null) {
                relatedBudgetsIds.add(request.Related_Region_Budget_gne__c);
            }
            if (request.Related_Product_Budget_gne__c != null) {
                relatedBudgetsIds.add(request.Related_Product_Budget_gne__c);
            }
            if (request.Related_Territory_Budget_gne__c != null) {
                relatedBudgetsIds.add(request.Related_Territory_Budget_gne__c);
            }
        }
        relatedTerritoryBudgets = new Map<Id, EMS_Budget_Territory_gne__c>([SELECT Id, Assigned_to_gne__c, EMS_Budget_Region_gne__r.Assigned_to_gne__c, EMS_Budget_Region_gne__r.EMS_Budget_Product_gne__r.Assigned_to_gne__c FROM EMS_Budget_Territory_gne__c WHERE Id IN :relatedBudgetsIds]);
        relatedRegionBudgets = new Map<Id, EMS_Budget_Region_gne__c>([SELECT Id, Assigned_to_gne__c, EMS_Budget_Product_gne__r.Assigned_to_gne__c FROM EMS_Budget_Region_gne__c WHERE Id IN :relatedBudgetsIds]);
        relatedProductBudgets = new Map<Id, EMS_Budget_Product_gne__c>([SELECT Id, Assigned_to_gne__c FROM EMS_Budget_Product_gne__c WHERE Id IN :relatedBudgetsIds]);
    }

    private static Map<Id, List<ProcessInstanceStep>> fetchApprovalSteps(List<EMS_Fund_Request_gne__c> triggerNew) {
        List<ProcessInstanceStep> steps = [
                SELECT ProcessInstance.TargetObject.Id, StepStatus, Id, Comments, CreatedDate
                FROM ProcessInstanceStep
                WHERE ProcessInstance.TargetObjectId IN :triggerNew
                AND StepStatus != 'Started'
        ];

        Map<Id, List<ProcessInstanceStep>> targetObjectIdToStepMap = new Map<Id, List<ProcessInstanceStep>>();
        for (ProcessInstanceStep step : steps) {
            if (!targetObjectIdToStepMap.containsKey(step.ProcessInstance.TargetObject.Id)) {
                targetObjectIdToStepMap.put(step.ProcessInstance.TargetObject.Id, new List<ProcessInstanceStep>());
            }
            targetObjectIdToStepMap.get(step.ProcessInstance.TargetObject.Id).add(step);
        }
        return targetObjectIdToStepMap;
    }
}