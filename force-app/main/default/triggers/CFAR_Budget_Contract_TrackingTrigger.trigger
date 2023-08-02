/*
*@Author: Konrad Russa
*@Created: 30-10-2013
*/

//FIXME: should be under button not as triggered logic
trigger CFAR_Budget_Contract_TrackingTrigger on CFAR_Budget_Contract_Tracking_gne__c (before insert, before update, after insert, after update) {
    if (CFAR_ConfigUtil.isTriggerEnabled(new List<String>{'CFAR_Budget_Contract_TrackingTrigger','CFAR_Budget_Contract_Tracking_gne__c'})){
        if(!CFAR_Budget_Utils.hasAlreadyProcessedTracking()) {
            CFAR_Utils.increaseHowManyProcessedCTTrigger();
            System.debug('Slawek DBG how many trigger processing: ' + CFAR_Utils.howManyProcessedCTTrigger);

            Map<Id, String> typeMap = CFAR_Utils.getContractTypeMap();

            set<String> types = new set<String>();
            types.addAll(CFAR_Budget_Utils.getOrginalAndAmendmentTypeNames());
            types.add(Label.CFAR_GSTARS_CONTRACT_TRACKING_ADJUSTMENT_TYPE);
            types.add(Label.CFAR_GSTARS_CONTRACT_TRACKING_PLANNED_TYPE);

            if(trigger.isBefore) {
                //DONE: ITERATION2
                Set<Id> budgetIds = CFAR_Utils.fetchIdSet(trigger.new, 'Budget_Contract_ref_gne__c');

                //DONE: ITERATION2
                List<CFAR_Budget_Contract_Tracking_gne__c> listOfContracts = [select Id, Amount_gne__c, CreatedDate, Frm_Trial_Id_gne__c, Budget_Contract_ref_gne__c
                        from CFAR_Budget_Contract_Tracking_gne__c
                        where frm_Type_gne__c in :types and Budget_Contract_ref_gne__c in :budgetIds
                        order by CreatedDate asc];

                Map<Id, List<CFAR_Budget_Contract_Tracking_gne__c>> budget2Trackings = new Map<Id, List<CFAR_Budget_Contract_Tracking_gne__c>>();
                for(CFAR_Budget_Contract_Tracking_gne__c c : listOfContracts) {
                    if(budget2Trackings.containsKey(c.Budget_Contract_ref_gne__c)) {
                        budget2Trackings.get(c.Budget_Contract_ref_gne__c).add(c);
                    } else {
                        budget2Trackings.put(c.Budget_Contract_ref_gne__c, new List<CFAR_Budget_Contract_Tracking_gne__c> {c});
                    }
                }

                for(CFAR_Budget_Contract_Tracking_gne__c c : trigger.new) {
                    Boolean isRight = //typeMap.get(c.Type_ref_gne__c) == Label.CFAR_GSTARS_CONTRACT_TRACKING_INCREASE_TYPE
                        //|| typeMap.get(c.Type_ref_gne__c) == Label.CFAR_GSTARS_CONTRACT_TRACKING_DECREASE_TYPE
                        CFAR_Budget_Utils.getAmendmentTypeNames().contains(typeMap.get(c.Type_ref_gne__c))
                        || typeMap.get(c.Type_ref_gne__c) == Label.CFAR_GSTARS_CONTRACT_TRACKING_ADJUSTMENT_TYPE
                        || typeMap.get(c.Type_ref_gne__c) == Label.CFAR_GSTARS_CONTRACT_TRACKING_PLANNED_TYPE;

                    if (isRight && budget2Trackings.containsKey(c.Budget_Contract_ref_gne__c)) {
                        List<CFAR_Budget_Contract_Tracking_gne__c> trackList = budget2Trackings.get(c.Budget_Contract_ref_gne__c);
                        CFAR_Budget_Contract_Tracking_gne__c prevTracking = trackList[0];
                        for (CFAR_Budget_Contract_Tracking_gne__c tracking : trackList) {
                            if ( (c.CreatedDate == null || tracking.CreatedDate < c.CreatedDate)
                                    && tracking.CreatedDate > prevTracking.CreatedDate) {
                                prevTracking = tracking;
                            }
                        }
                        if (c.Id != prevTracking.Id) {
                            c.Variance_gne__c = c.Amount_gne__c - prevTracking.Amount_gne__c;
                        }
                    }
                }
            }

            if(trigger.isAfter) {
                Set<String> allBudgetContractsIds = CFAR_Utils.fetchSet(trigger.new, 'Budget_Contract_ref_gne__c');
                Set<String> expTypes = new Set<String> {Label.CFAR_GSTARS_CONTRACT_TRACKING_ORGINAL_TYPE, Label.CFAR_GSTARS_CONTRACT_TRACKING_ADJUSTMENT_TYPE};
                expTypes.addAll(CFAR_Budget_Utils.getAmendmentTypeNames());

                // Get list of contract records updated except for canceled and planned
                List<AggregateResult> lastExpContractTrackingList =
                    [select Budget_Contract_ref_gne__c, Contract_Expiry_Date_gne__c
                     from CFAR_Budget_Contract_Tracking_gne__c
                     where Budget_Contract_ref_gne__c in :allBudgetContractsIds
                     and Contract_Expiry_Date_gne__c != null
                     and Type_ref_gne__r.Name in :expTypes
                     group by Budget_Contract_ref_gne__c, Contract_Expiry_Date_gne__c
                     order by Budget_Contract_ref_gne__c, max(Contract_Expiry_Date_gne__c) DESC];

                Map<Id, AggregateResult> lastExpContractTracking = new Map<Id, AggregateResult>();
                for (AggregateResult ar : lastExpContractTrackingList) {
                    if (lastExpContractTracking.containsKey(Id.valueOf(String.valueOf(ar.get('Budget_Contract_ref_gne__c'))))) {
                        continue;
                    }
                    lastExpContractTracking.put(Id.valueOf(String.valueOf(ar.get('Budget_Contract_ref_gne__c'))), ar);
                }

                map<Id, Decimal> budgetContractWithLastAmendment = new map<Id, Decimal>();
                map<Id, Date> budgetContractWithExecutionDate = new map<Id, Date>();
                map<Id, Date> budgetContractWithEndDate = new map<Id, Date>();

                //list<CFAR_Budget_Contract_Tracking_gne__c> trackingAffectedProjections = new list<CFAR_Budget_Contract_Tracking_gne__c>();
                set<Id> trackingAffectedProjectionsTrialIdx = new set<Id>();
                Set<Id> budgetContractsIdx = new Set<Id>();
                //DONE: ITERATION2
                Set<Id> budgetContractIdxForPlanned = new Set<Id>();

                Date noDate = Date.newInstance(1970, 1, 1);
                Date oldExecutedDate, oldExpiryDate, newExecutedDate, newExpiryDate;
                Decimal oldContractAmnt, newContractAmnt;
                ID oldContractTypeId, newContractTypeId;

                for(CFAR_Budget_Contract_Tracking_gne__c c : trigger.new) {

                    Boolean isOrginal = typeMap.get(c.Type_ref_gne__c) == Label.CFAR_GSTARS_CONTRACT_TRACKING_ORGINAL_TYPE;
                    Boolean isAmendmentOrAdjustment = CFAR_Budget_Utils.getAmendmentTypeNames().contains(typeMap.get(c.Type_ref_gne__c))
                                                      || typeMap.get(c.Type_ref_gne__c) == Label.CFAR_GSTARS_CONTRACT_TRACKING_ADJUSTMENT_TYPE;
                    Boolean isPlanned = typeMap.get(c.Type_ref_gne__c) == Label.CFAR_GSTARS_CONTRACT_TRACKING_PLANNED_TYPE;

                    //DONE: ITERATION2 MultiContract
                    if(isOrginal || isAmendmentOrAdjustment) {
                        budgetContractsIdx.add(c.Budget_Contract_ref_gne__c);
                    }

                    //DONE: ITERATION2 MultiContract
                    if (isPlanned) {
                        budgetContractIdxForPlanned.add(c.Budget_Contract_ref_gne__c);
                    }

                    // Get old and new values to check for changes
                    if (trigger.isUpdate) {
                        oldExecutedDate   = Trigger.oldMap.get(c.Id).Fully_Executed_Date_gne__c;
                        oldExpiryDate     = Trigger.oldMap.get(c.Id).Contract_Expiry_Date_gne__c;
                        oldContractAmnt   = CFAR_Budget_Utils.returnZeroNotNull(Trigger.oldMap.get(c.Id).Amount_gne__c);
                        oldContractTypeId = Trigger.oldMap.get(c.Id).Type_ref_gne__c;
                        newExecutedDate   = Trigger.newMap.get(c.Id).Fully_Executed_Date_gne__c;
                        newExpiryDate     = Trigger.newMap.get(c.Id).Contract_Expiry_Date_gne__c;
                        newContractAmnt   = CFAR_Budget_Utils.returnZeroNotNull(Trigger.newMap.get(c.Id).Amount_gne__c);
                        newContractTypeId = Trigger.newMap.get(c.Id).Type_ref_gne__c;

                        // check for null values in case of bad data
                        if (oldExecutedDate == null) {
                            oldExecutedDate = noDate;
                        }
                        if (oldExpiryDate == null) {
                            oldExpiryDate = noDate;
                        }
                        if (newExecutedDate == null) {
                            newExecutedDate = noDate;
                        }
                        if (newExpiryDate == null) {
                            newExpiryDate = noDate;
                        }
                    }

                    // Get original executed date to update budget_contract.Original_Contract_Execution_Date_gne__c
                    if (isOrginal
                            && c.Fully_Executed_Date_gne__c != null
                            && (trigger.isInsert
                                || oldExecutedDate != newExecutedDate
                                || oldContractTypeId != newContractTypeId)) {
                        budgetContractWithExecutionDate.put(c.Budget_Contract_ref_gne__c, c.Fully_Executed_Date_gne__c);
                    }

                    // CFAR-463 Get last contract tracking expiry date to update budget_contract.Contract_End_Date_gne__c
                    if (lastExpContractTracking.containsKey(c.Budget_Contract_ref_gne__c)
                            && (isOrginal || isAmendmentOrAdjustment)
                            && c.Contract_Expiry_Date_gne__c != null) {
                        budgetContractWithEndDate.put(c.Budget_Contract_ref_gne__c, (Date)lastExpContractTracking.get(c.Budget_Contract_ref_gne__c).get('Contract_Expiry_Date_gne__c'));
                    }

                    // Need to recompute projection if inserted a new record or updated a field that impacts projections
                    if (trigger.isInsert ||
                            oldExecutedDate != newExecutedDate ||
                            oldExpiryDate != newExpiryDate ||
                            oldContractAmnt != newContractAmnt ||
                            oldContractTypeId != newContractTypeId) {
                        trackingAffectedProjectionsTrialIdx.add(c.Frm_Trial_Id_gne__c);
                    }
                }

                // Update projections
                if(!trackingAffectedProjectionsTrialIdx.isEmpty()) {
                    CFAR_Budget_Utils.updateProjections(trackingAffectedProjectionsTrialIdx);
                }

                List<CFAR_Budget_Contract_Tracking_gne__c> trackings = [select Budget_Contract_ref_gne__c, Amount_gne__c from CFAR_Budget_Contract_Tracking_gne__c
                        where Budget_Contract_ref_gne__c in :budgetContractsIdx and frm_Type_gne__c != :CFAR_BudgetContractTrackingHelper.TYPE_CONTRACT_PLANNED order by CreatedDate desc];
                for(CFAR_Budget_Contract_Tracking_gne__c t : trackings) {
                    if(!budgetContractWithLastAmendment.containsKey(t.Budget_Contract_ref_gne__c)) {
                        budgetContractWithLastAmendment.put(t.Budget_Contract_ref_gne__c, t.Amount_gne__c);
                    }
                }

                if (!budgetContractWithEndDate.isEmpty() || !budgetContractWithExecutionDate.isEmpty() || !budgetContractWithLastAmendment.isEmpty()) {

                    set<Id> budgetContractIds = new Set<Id>();
                    budgetContractIds.addAll(budgetContractWithEndDate.keySet());
                    budgetContractIds.addAll(budgetContractWithLastAmendment.keySet());
                    budgetContractIds.addAll(budgetContractWithExecutionDate.keySet());


                    List<CFAR_Budget_Contract_gne__c> budgetContracts = [SELECT Id, Original_Contract_Execution_Date_gne__c, Contract_End_Date_gne__c,  Last_Amendment_Amount_gne__c FROM CFAR_Budget_Contract_gne__c WHERE Id in :budgetContractIds];
                    for (CFAR_Budget_Contract_gne__c c : budgetContracts) {
                        if (budgetContractWithEndDate.containsKey(c.Id))
                            c.Contract_End_Date_gne__c = budgetContractWithEndDate.get(c.Id);
                        if (budgetContractWithExecutionDate.containsKey(c.Id))
                            c.Original_Contract_Execution_Date_gne__c = budgetContractWithExecutionDate.get(c.Id);
                        if (budgetContractWithLastAmendment.containsKey(c.Id))
                            c.Last_Amendment_Amount_gne__c = budgetContractWithLastAmendment.get(c.Id);
                    }
                    CFAR_Utils.setAlreadyProcessed();
                    update budgetContracts;
                }

                set<String> typesForEndDate = new set<String>();
                typesForEndDate.addAll(CFAR_Budget_Utils.getOrginalAndAmendmentTypeNames());
                typesForEndDate.add(Label.CFAR_GSTARS_CONTRACT_TRACKING_ADJUSTMENT_TYPE);

                Map<Id, Date> maxExpiryDatesMap = new Map<Id, Date>();
                for (AggregateResult expiryDate : [SELECT Budget_Contract_ref_gne__r.Team_Member_ref_gne__r.CFAR_Trial_ref_gne__c trialId, MAX(Contract_Expiry_Date_gne__c)maxDate
                        FROM CFAR_Budget_Contract_Tracking_gne__c
                        WHERE frm_Type_gne__c IN : typesForEndDate
                        AND Budget_Contract_ref_gne__r.Team_Member_ref_gne__r.frm_Function_Role_gne__c = :CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR
                        GROUP BY Budget_Contract_ref_gne__r.Team_Member_ref_gne__r.CFAR_Trial_ref_gne__c LIMIT 2000]) {
                    maxExpiryDatesMap.put(Id.valueOf(String.valueOf(expiryDate.get('trialId'))), Date.valueOf(expiryDate.get('maxDate')));
                }

                Map<Id, Date> minOriginalContractDatesMap = new Map<Id, Date>();
                for(AggregateResult executedDate : [SELECT Budget_Contract_ref_gne__r.Team_Member_ref_gne__r.CFAR_Trial_ref_gne__c trialId, MIN(Fully_Executed_Date_gne__c)minDate
                        FROM CFAR_Budget_Contract_Tracking_gne__c
                        WHERE Budget_Contract_ref_gne__r.Team_Member_ref_gne__r.frm_Function_Role_gne__c = :CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR
                        AND frm_Type_gne__c = :CFAR_BudgetContractTrackingHelper.TYPE_CONTRACT_ORIGINAL
                        GROUP BY Budget_Contract_ref_gne__r.Team_Member_ref_gne__r.CFAR_Trial_ref_gne__c LIMIT 2000]){
                    minOriginalContractDatesMap.put(Id.valueOf(String.valueOf(executedDate.get('trialId'))), Date.valueOf(executedDate.get('minDate')));
                }

                CFAR_Trial_gne__c[] trialsToUpdateList = [SELECT Id, name, Original_Contract_Execution_Date_gne__c, Contract_end_date_gne__c
                        FROM CFAR_Trial_gne__c WHERE Id IN : trackingAffectedProjectionsTrialIdx];
                for (CFAR_Trial_gne__c trial : trialsToUpdateList) {
                    trial.Contract_end_date_gne__c = maxExpiryDatesMap.get(trial.Id);
                    trial.Original_Contract_Execution_Date_gne__c = minOriginalContractDatesMap.get(trial.Id);
                }
                update trialsToUpdateList;

                //DONE: ITERATION2
                // get contract tracking for calculating of Variance based on triggered trackings.
                List<CFAR_Budget_Contract_Tracking_gne__c> contractList = [select Id, Name, Amendment_Number_gne__c, Amount_gne__c,
                                                           Comments_gne__c, Contract_Expiry_Date_gne__c, Contract_ID_gne__c, CreatedDate,
                                                           frm_sfdc_Completed_gne__c, frm_Type_gne__c, Fully_Executed_Date_gne__c, LastModifiedDate, Budget_Contract_ref_gne__c,
                                                           txt_Type_gne__c, Type_ref_gne__c, Type_ref_gne__r.Name, Variance_gne__c from CFAR_Budget_Contract_Tracking_gne__c
                                                           where (Budget_Contract_ref_gne__c in :budgetContractsIdx or Budget_Contract_ref_gne__c in :budgetContractIdxForPlanned)
                                                           and Type_ref_gne__r.Name IN :types
                                                           and Id not in :trigger.newMap.keySet() order by CreatedDate asc];

                List<CFAR_Budget_Contract_Tracking_gne__c> contractListToUpdate = new List<CFAR_Budget_Contract_Tracking_gne__c>();
                Map<Id, Double> lastAmount = new Map<Id, Double>();
                for(CFAR_Budget_Contract_Tracking_gne__c t : contractList) {
                    for(CFAR_Budget_Contract_Tracking_gne__c c : trigger.new) {
                        if(!lastAmount.containsKey(c.Budget_Contract_ref_gne__c)) {
                            lastAmount.put(c.Budget_Contract_ref_gne__c, c.Amount_gne__c);
                        }
                        if(c.Budget_Contract_ref_gne__c == t.Budget_Contract_ref_gne__c && t.CreatedDate > c.CreatedDate) {
                            if (t.frm_Type_gne__c != CFAR_BudgetContractTrackingHelper.TYPE_CONTRACT_ORIGINAL) {
                                t.Variance_gne__c = t.Amount_gne__c - lastAmount.get(t.Budget_Contract_ref_gne__c);
                                contractListToUpdate.add(t);
                            }
                            lastAmount.put(t.Budget_Contract_ref_gne__c, t.Amount_gne__c);
                            break;
                        }
                    }
                }
                CFAR_Budget_Utils.setAlreadyProcessedTracking();
                update contractListToUpdate;

                //FIXME
                //DONE: ITERATION2
                CFAR_Budget_CPS_Payments_gne__c[] payments = [select Id from CFAR_Budget_CPS_Payments_gne__c
                        WHERE Budget_Contract_ref_gne__c in :budgetContractsIdx or Budget_Contract_ref_gne__c in :budgetContractIdxForPlanned];
                //fake update to trigger logic
                update payments;
            }
        }
    }
}