public without sharing class EMS_Fund_Request_Validation_Rules {

    private static Map<Id, RecordType> fundRequestRecordTypes;

    private static Map<Id, EMS_Budget_Region_gne__c> relatedRegionBudgets;
    private static Map<Id, EMS_Budget_Product_gne__c> relatedProductBudgets;
    private static Map<Id, EMS_Budget_Territory_gne__c> relatedTerritoryBudgets;
    private static Map<Id, SObject> allRelatedBudgets = new Map<Id, SObject>();
    
    /* Methods called from trigger */
    public static boolean onBeforeUpdate(Map<ID, EMS_Fund_Request_gne__c> triggerOldMap, List<EMS_Fund_Request_gne__c> triggerNew) {
        if (!EMS_Fund_Request_Trigger_Helper.skipTriggerValidationRules) {
            getObjectRecordTypes(triggerNew);
            getRelatedObjectFields(triggerNew);
            boolean result = false;
            result = (runValidationRulesOnUpdate(triggerOldMap, triggerNew));
            return result;
        } else {
            return false;
        }
    }

    public static boolean onBeforeInsert(List<EMS_Fund_Request_gne__c> triggerNew) {
        if (!EMS_Fund_Request_Trigger_Helper.skipTriggerValidationRules) {
            getObjectRecordTypes(triggerNew);
            getRelatedObjectFields(triggerNew);
            boolean result = false;
            result = (runValidationRulesOnInsert(triggerNew));
            return result;
        } else {
            return false;
        }
    }
    
    /* Internal Methods */

    private static boolean runValidationRulesOnInsert(List<EMS_Fund_Request_gne__c> triggerNew) {
        boolean result = false;
        for (EMS_Fund_Request_gne__c fundRequest : triggerNew) {
            if (validateRequestedAmount(fundRequest)) {
                result = true;
            }

            if (validateProductRegionTerritoryBudget(fundRequest)) {
                result = true;
            }

            if (validateRequiredDate(null, fundRequest)) {
                result = true;
            }
        }

        return result;
    }

    private static boolean runValidationRulesOnUpdate(Map<ID, EMS_Fund_Request_gne__c> triggerOldMap, List<EMS_Fund_Request_gne__c> triggerNew) {
        boolean result = false;
        for (EMS_Fund_Request_gne__c fundRequest : triggerNew) {
            if (validateRequestedAmount(fundRequest)) {
                result = true;
            }

            if (validateProductRegionTerritoryBudget(fundRequest)) {
                result = true;
            }

            if (validateApprovalProcess(triggerOldMap.get(fundRequest.Id), fundRequest)) {
                result = true;
            }

            if (validateRequiredDate(triggerOldMap.get(fundRequest.Id), fundRequest)) {
                result = true;
            }
        }
        return result;
    }

    private static boolean validateRequestedAmount(EMS_Fund_Request_gne__c fundRequest) {
        Boolean result = false;
        RecordType rt = fundRequestRecordTypes.get(fundRequest.RecordTypeId);
        if (fundRequest.Requested_Amount_gne__c <= 0) {
            if (rt.DeveloperName.containsIgnoreCase('Fund_Allocation') || rt.DeveloperName.containsIgnoreCase('Fund_Transfer')) {
                fundRequest.addError(System.Label.Requested_Amount_Cannot_Be_Negative);
                result = true;
            }
        } else if (fundRequest.Requested_Amount_gne__c >= 0) {
            if (rt.DeveloperName.containsIgnoreCase('Fund_De_Allocation')) {
                fundRequest.addError(System.Label.Requested_Amount_Must_Be_Negative);
                result = true;
            }
        }

        return result;
    }

    private static boolean validateProductRegionTerritoryBudget(EMS_Fund_Request_gne__c fundRequest) {
        boolean result = false;
        String recordTypeName = fundRequestRecordTypes.get(fundRequest.RecordTypeId).Name;

        if (recordTypeName.containsIgnoreCase('Transfer')) {
            if (recordTypeName.containsIgnoreCase('Region')) {
                if (fundRequest.Target_Region_Budget_ID_gne__c == null) {
                    fundRequest.addError('Target Region Budget cannot be empty.');
                    result = true;
                }
                if (fundRequest.Target_Territory_Budget_ID_gne__c != null) {
                    fundRequest.addError('Target Territory Budget cannot be filled.');
                    result = true;
                }
                if (fundRequest.Related_Region_Budget_gne__c == null && fundRequest.Related_Product_Budget_gne__c == null) {
                    fundRequest.addError('Source Budget cannot be empty.');
                    result = true;
                }
                if (fundRequest.Related_Territory_Budget_gne__c != null) {
                    fundRequest.addError('Territory Budget cannot be filled.');
                    result = true;
                }
            } else if (recordTypeName.containsIgnoreCase('Territory')) {
                if (fundRequest.Target_Region_Budget_ID_gne__c != null) {
                    fundRequest.addError('Target Region Budget cannot be filled.');
                    result = true;
                }
                if (fundRequest.Target_Territory_Budget_ID_gne__c == null) {
                    fundRequest.addError('Target Territory Budget cannot be empty.');
                    result = true;
                }
                if (fundRequest.Related_Territory_Budget_gne__c == null && fundRequest.Related_Region_Budget_gne__c != null) {
                    fundRequest.addError('Source Budget cannot be empty.');
                    result = true;
                }
                if (fundRequest.Related_Product_Budget_gne__c != null) {
                    fundRequest.addError('Product Budget cannot be filled.');
                    result = true;
                }
            }
        } else if (recordTypeName.containsIgnoreCase('region')) {
            if (fundRequest.Related_Product_Budget_gne__c == null) {
                fundRequest.addError('Product Budget cannot be empty.');
                result = true;
            }
            if (fundRequest.Related_Region_Budget_gne__c == null) {
                fundRequest.addError('Region Budget cannot be empty.');
                result = true;
            }
            if (fundRequest.Related_Territory_Budget_gne__c != null) {
                fundRequest.addError('Territory Budget cannot be filled.');
                result = true;
            }
        } else if (recordTypeName.containsIgnoreCase('territory')) {
            if (fundRequest.Related_Product_Budget_gne__c != null) {
                fundRequest.addError('Product Budget cannot be filled.');
                result = true;
            }
            if (fundRequest.Related_Region_Budget_gne__c == null) {
                fundRequest.addError('Region Budget cannot be empty.');
                result = true;
            }
            if (fundRequest.Related_Territory_Budget_gne__c == null) {
                fundRequest.addError('Territory Budget cannot be empty.');
                result = true;
            }
        }
        return result;
    }

    private static boolean validateRequiredDate(EMS_Fund_Request_gne__c fundRequestOld, EMS_Fund_Request_gne__c fundRequestNew) {
        // check if the date is in the past
        if (fundRequestOld == null || fundRequestOld.Required_By_Date_gne__c != fundRequestNew.Required_By_Date_gne__c) {
            if (fundRequestNew.Required_By_Date_gne__c < Date.today()) {
                fundRequestNew.addError('Required By date cannot be in the past.');
                return true;
            }
        }

        // check if the date falls into related budgets' start and end date
        if (fundRequestRecordTypes.get(fundRequestNew.RecordTypeId).DeveloperName == 'Region_Fund_Allocation' || fundRequestRecordTypes.get(fundRequestNew.RecordTypeId).DeveloperName == 'Region_Fund_De_Allocation') {
            if (fundRequestNew.Required_By_Date_gne__c != null && isInDateRange(fundRequestNew, fundRequestNew.Related_Product_Budget_gne__c, fundRequestNew.Related_Region_Budget_gne__c) == false) {
                fundRequestNew.addError('Required By must be between Start date and End date of the related budgets.');
                return true;
            }
        } else if (fundRequestRecordTypes.get(fundRequestNew.RecordTypeId).DeveloperName == 'Territory_Fund_Allocation' || fundRequestRecordTypes.get(fundRequestNew.RecordTypeId).DeveloperName == 'Territory_Fund_De_Allocation') {
            if (fundRequestNew.Required_By_Date_gne__c != null && isInDateRange(fundRequestNew, fundRequestNew.Related_Territory_Budget_gne__c, fundRequestNew.Related_Region_Budget_gne__c) == false) {
                fundRequestNew.addError('Required By must be between Start date and End date of the related budgets.');
                return true;
            }
        } else if (fundRequestRecordTypes.get(fundRequestNew.RecordTypeId).Name == EMS_Consts.RT_TRANSFER_REGION_FUNDS) {
            if (fundRequestNew.Required_By_Date_gne__c != null && isInDateRange(fundRequestNew, fundRequestNew.Related_Region_Budget_gne__c, fundRequestNew.Target_Region_Budget_ID_gne__c) == false) {
                fundRequestNew.addError('Required By must be between Start date and End date of the related budgets.');
                return true;
            }
        } else if (fundRequestRecordTypes.get(fundRequestNew.RecordTypeId).Name == EMS_Consts.RT_TRANSFER_TERRITORY_FUNDS) {
            if (fundRequestNew.Required_By_Date_gne__c != null && isInDateRange(fundRequestNew, fundRequestNew.Related_Territory_Budget_gne__c, fundRequestNew.Target_Territory_Budget_ID_gne__c) == false) {
                fundRequestNew.addError('Required By must be between Start date and End date of the related budgets.');
                return true;
            }
        }
        return false;
    }

    private static Boolean isInDateRange(EMS_Fund_Request_gne__c fundRequest, Id firstBudgetId, Id secondBudgetId) {
        SObject firstBudget = allRelatedBudgets.get(firstBudgetId);
        SObject secondBudget = allRelatedBudgets.get(secondBudgetId);
        Date requestDate = fundRequest.Required_By_Date_gne__c;

        return (Date) firstBudget.get('Start_Date_gne__c') <= requestDate      // after  first  budget start
                && requestDate <= (Date) firstBudget.get('End_Date_gne__c')    // before first  budget ende
                && (Date) secondBudget.get('Start_Date_gne__c') <= requestDate // after  second budget start
                && requestDate <= (Date) secondBudget.get('End_Date_gne__c');  // before second budget end
    }

    private static boolean validateApprovalProcess(EMS_Fund_Request_gne__c fundRequestOld, EMS_Fund_Request_gne__c fundRequestNew) {
        if (fundRequestNew.Status_gne__c == 'Approved' && fundRequestOld.Status_gne__c == 'Submitted') {
            if (fundRequestRecordTypes.get(fundRequestNew.RecordTypeId).DeveloperName == 'Region_Fund_Allocation' && fundRequestNew.Requested_Amount_gne__c > relatedProductBudgets.get(fundRequestNew.Related_Product_Budget_gne__c).Product_Balance_gne__c) {
                fundRequestNew.addError('Requested value is higher than available amount');
                return true;
            } else if (fundRequestRecordTypes.get(fundRequestNew.RecordTypeId).DeveloperName == 'Region_Fund_De_Allocation' && (fundRequestNew.Requested_Amount_gne__c * -1) > relatedRegionBudgets.get(fundRequestNew.Related_Region_Budget_gne__c).Region_Balance_gne__c) {
                fundRequestNew.addError('Requested value is higher than available amount');
                return true;
            } else if (fundRequestRecordTypes.get(fundRequestNew.RecordTypeId).DeveloperName == 'Territory_Fund_Allocation' && fundRequestNew.Requested_Amount_gne__c > relatedRegionBudgets.get(fundRequestNew.Related_Region_Budget_gne__c).Region_Balance_gne__c) {
                fundRequestNew.addError('Requested value is higher than available amount');
                return true;
            } else if (fundRequestRecordTypes.get(fundRequestNew.RecordTypeId).DeveloperName == 'Territory_Fund_De_Allocation' && (fundRequestNew.Requested_Amount_gne__c * -1) > relatedTerritoryBudgets.get(fundRequestNew.Related_Territory_Budget_gne__c).Territory_Balance_gne__c) {
                fundRequestNew.addError('Requested value is higher than available amount');
                return true;
            } else if (fundRequestRecordTypes.get(fundRequestNew.RecordTypeId).Name == EMS_Consts.RT_TRANSFER_REGION_FUNDS) {
                if (String.isNotBlank(fundRequestNew.Related_Product_Budget_gne__c) && fundRequestNew.Requested_Amount_gne__c > relatedProductBudgets.get(fundRequestNew.Related_Product_Budget_gne__c).Product_Balance_gne__c) {
                    fundRequestNew.addError('Requested value is higher than available amount');
                    return true;
                } else if (String.isNotBlank(fundRequestNew.Related_Region_Budget_gne__c) && fundRequestNew.Requested_Amount_gne__c > relatedRegionBudgets.get(fundRequestNew.Related_Region_Budget_gne__c).Region_Balance_gne__c) {
                    fundRequestNew.addError('Requested value is higher than available amount');
                    return true;
                }
            } else if (fundRequestRecordTypes.get(fundRequestNew.RecordTypeId).Name == EMS_Consts.RT_TRANSFER_TERRITORY_FUNDS) {
                if (String.isNotBlank(fundRequestNew.Related_Region_Budget_gne__c) && fundRequestNew.Requested_Amount_gne__c > relatedRegionBudgets.get(fundRequestNew.Related_Region_Budget_gne__c).Region_Balance_gne__c) {
                    fundRequestNew.addError('Requested value is higher than available amount');
                    return true;
                } else if (String.isNotBlank(fundRequestNew.Related_Product_Budget_gne__c) && fundRequestNew.Requested_Amount_gne__c > relatedTerritoryBudgets.get(fundRequestNew.Related_Territory_Budget_gne__c).Territory_Balance_gne__c) {
                    fundRequestNew.addError('Requested value is higher than available amount');
                    return true;
                }
            }
        }
        return false;
    }

    private static void getObjectRecordTypes(List<EMS_Fund_Request_gne__c> triggerNew) {
        fundRequestRecordTypes = new Map<Id, RecordType>([SELECT Name, DeveloperName FROM RecordType WHERE SobjectType = 'EMS_Fund_Request_gne__c']);
    }

    private static void getRelatedObjectFields(List<EMS_Fund_Request_gne__c> triggerNew) {

        List <Id> relatedBudgetsIds = new List <Id>();
        for (EMS_Fund_Request_gne__c request : triggerNew) {
            if (request.Related_Region_Budget_gne__c != null) {
                relatedBudgetsIds.add(request.Related_Region_Budget_gne__c);
            }
            if (request.Target_Region_Budget_ID_gne__c != null) {
                relatedBudgetsIds.add(request.Target_Region_Budget_ID_gne__c);
            }
            if (request.Target_Territory_Budget_ID_gne__c != null) {
                relatedBudgetsIds.add(request.Target_Territory_Budget_ID_gne__c);
            }
            if (request.Related_Product_Budget_gne__c != null) {
                relatedBudgetsIds.add(request.Related_Product_Budget_gne__c);
            }
            if (request.Related_Territory_Budget_gne__c != null) {
                relatedBudgetsIds.add(request.Related_Territory_Budget_gne__c);
            }
        }
        relatedTerritoryBudgets = new Map<Id, EMS_Budget_Territory_gne__c>([SELECT Id, Territory_Balance_gne__c, Total_Territory_Funds_Approved_gne__c, Start_Date_gne__c, End_Date_gne__c FROM EMS_Budget_Territory_gne__c WHERE Id IN :relatedBudgetsIds]);
        relatedRegionBudgets = new Map<Id, EMS_Budget_Region_gne__c>([SELECT Id, Region_Balance_gne__c, Total_Region_Funds_Approved_gne__c, Start_Date_gne__c, End_Date_gne__c FROM EMS_Budget_Region_gne__c WHERE Id IN :relatedBudgetsIds]);
        relatedProductBudgets = new Map<Id, EMS_Budget_Product_gne__c>([SELECT Id, Product_Balance_gne__c, Total_Product_Funds_Approved_gne__c, Start_Date_gne__c, End_Date_gne__c FROM EMS_Budget_Product_gne__c WHERE Id IN :relatedBudgetsIds]);

        allRelatedBudgets.putAll((Map<Id, SObject>) relatedTerritoryBudgets);
        allRelatedBudgets.putAll((Map<Id, SObject>) relatedRegionBudgets);
        allRelatedBudgets.putAll((Map<Id, SObject>) relatedProductBudgets);
    }

}