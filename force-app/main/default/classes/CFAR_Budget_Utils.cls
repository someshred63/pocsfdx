public class CFAR_Budget_Utils {
    
    private static boolean alreadyProcessedPayment = false;

    public static boolean hasAlreadyProcessedPayment() {
        return alreadyProcessedPayment;
    } 
    
    public static void setAlreadyProcessedPayment() {
        alreadyProcessedPayment = true;
    }

    public static void setAlreadyProcessedPayment(Boolean status) {
        alreadyProcessedPayment = status;
    }
    
    private static Boolean alreadyProcessedTracking = false;
    
    public static Boolean hasAlreadyProcessedTracking() {
        return alreadyProcessedTracking;
    }
    
    public static void setAlreadyProcessedTracking() {
        alreadyProcessedTracking = true;
    } 
    
    public static Boolean isAdminProfile(Id userProfileId) {
        List<String> profileNames = new List<String> {'System Administrator', 'GNE-CFAR-IT-Admin-New'};
        return isUserProfileInProfileNames(userProfileId, profileNames);
    }

    public static Boolean isAdminOrITAdminProfile(Id userProfileId) {
        List<String> profileNames = new List<String> {'System Administrator', 'GNE-CFAR-IT-Admin-New', 'GNE-CFAR-Admin-New'};
        return isUserProfileInProfileNames(userProfileId, profileNames);
    }

    public static Boolean isBSAProfile(Id userProfileId) {
        List<String> profileNames = new List<String> {'GNE-CFAR-Admin-New'};
        return isUserProfileInProfileNames(userProfileId, profileNames);
    }

    public static Boolean isUserProfileInProfileNames(Id userProfileId, List<String> profileNames) {
        List<Profile> p = [SELECT Name FROM profile WHERE Id = :userProfileId AND Name IN :profileNames];
        return (p.size() > 0);
    }


    public static Boolean hasPayments(Id trialId) {
        //DONE: ITERATION2 MultiContract - change where clause to reflect new object model
        return Integer.valueOf([select count(Id) counter from CFAR_Budget_CPS_Payments_gne__c 
                where Budget_Contract_ref_gne__r.Team_Member_ref_gne__r.CFAR_Trial_ref_gne__c = :trialId][0].get('counter')) > 0;
    }
    
    public static Boolean hasPaymentsSubmitted(Id trialId) {
        String cancelledStatus = Label.CFAR_GSTARS_PAYMENT_SCHEDULE_CANCELLED_STATUS;
        //DONE: ITERATION2 MultiContract
        return Integer.valueOf([select count(Id) counter from CFAR_Budget_CPS_Payments_gne__c where Name != :cancelledStatus and frm_Trial_Id_gne__c = :trialId][0].get('counter')) > 0;
    }
    
    public static Set<Id> hasPaymentsSubmitted(Set<Id> trialIds) {
        Set<Id> trialsWithPaymentsSubmitted = new Set<Id>();
        String cancelledStatus = Label.CFAR_GSTARS_PAYMENT_SCHEDULE_CANCELLED_STATUS;
        //DONE: ITERATION2 MultiContract
        for (CFAR_Budget_CPS_Payments_gne__c payment : [select frm_Trial_Id_gne__c from CFAR_Budget_CPS_Payments_gne__c where Name != :cancelledStatus and frm_Trial_Id_gne__c in :trialIds]) {
            trialsWithPaymentsSubmitted.add(payment.frm_Trial_Id_gne__c);
        }
        return trialsWithPaymentsSubmitted;
    }
    
    public static Boolean hasProjections(Id trialId) {
        return Integer.valueOf([select count(Id) counter from CFAR_Budget_CPS_Projection_gne__c where CFAR_Trial_ref_gne__c = :trialId][0].get('counter')) > 0;
    }
    
    public static Map<Id, AggregateResult> hasProjections(set<string> trialIds) {
        Map<Id, AggregateResult> res = new Map<Id, AggregateResult>([select CFAR_Trial_ref_gne__c Id, count(Id) counter from CFAR_Budget_CPS_Projection_gne__c where CFAR_Trial_ref_gne__c in :trialIds group by CFAR_Trial_ref_gne__c]);
        return res;
    }
    
    public static Boolean hasOrginalContractTracking(Id teamMemberId) {
        String originalType = Label.CFAR_GSTARS_CONTRACT_TRACKING_ORGINAL_TYPE;
        return Integer.valueOf([select count(Id) counter from CFAR_Budget_Contract_Tracking_gne__c where Budget_Contract_ref_gne__r.Team_Member_ref_gne__c = :teamMemberId 
            and Type_ref_gne__r.Name = :originalType][0].get('counter')) > 0;
    }
    
    public static Boolean hasAmendmentConractTracking(Id teamMemberId) {
        Set<String> amendmentType = getAmendmentTypeNames();
        return Integer.valueOf([select count(Id) counter from CFAR_Budget_Contract_Tracking_gne__c where Budget_Contract_ref_gne__r.Team_Member_ref_gne__c = :teamMemberId 
            and Type_ref_gne__r.Name IN :amendmentType][0].get('counter')) > 0;
    }
    
    public static Boolean hasAdjustmentConractTracking(Id teamMemberId) {
        String adjustmentType = Label.CFAR_GSTARS_CONTRACT_TRACKING_ADJUSTMENT_TYPE;
        return Integer.valueOf([select count(Id) counter from CFAR_Budget_Contract_Tracking_gne__c where Budget_Contract_ref_gne__r.Team_Member_ref_gne__c = :teamMemberId 
            and Type_ref_gne__r.Name = :adjustmentType][0].get('counter')) > 0;
    }
    
    public static String getLastContractType(Id teamMemberId) {
        List<CFAR_Budget_Contract_Tracking_gne__c> lastContract = [
        	SELECT Name, Type_ref_gne__r.Name 
        	FROM CFAR_Budget_Contract_Tracking_gne__c 
        	WHERE Budget_Contract_ref_gne__r.Team_Member_ref_gne__c = :teamMemberId 
        	ORDER BY Name DESC LIMIT 1];
        if (lastContract.size() > 0) {
        	return lastContract[0].Type_ref_gne__r.Name;
        } else {
        	return '';
        }
    }
    
    public static set<string> getOrginalAndAmendmentTypeNames() {
        set<string> s =  CFAR_Budget_Utils.getOrginalTypeName();
        s.addAll(CFAR_Budget_Utils.getAmendmentTypeNames());
        return s;
    }
    
    public static set<string> getOrginalTypeName() {
        return new set<string>{Label.CFAR_GSTARS_CONTRACT_TRACKING_ORGINAL_TYPE};
    }
    
    public static set<string> getAmendmentTypeNames() {
        return new set<string>{Label.CFAR_GSTARS_CONTRACT_TRACKING_INCREASE_TYPE, 
                                            Label.CFAR_GSTARS_CONTRACT_TRACKING_DECREASE_TYPE,
                                            Label.CFAR_GSTARS_CONTRACT_TRACKING_AMENDMENT_NO_CHANGE_TYPE};
    }
    
    //DONE: ITERATION2 MultiContract - change parameter trialId to BudgetContractId
    public static Integer getLastAmendmentNumber(Id budgetContractId) {
        return Integer.valueOf([select max(Amendment_Number_gne__c) maxAmendmentNumber from CFAR_Budget_Contract_Tracking_gne__c where Budget_Contract_ref_gne__c = :budgetContractId and frm_Type_gne__c in :getAmendmentTypeNames()][0].get('maxAmendmentNumber'));
    }
    
    public static Integer getLastAdjustmentNumber(Id budgetContractId) {
        String adjustmentType = Label.CFAR_GSTARS_CONTRACT_TRACKING_ADJUSTMENT_TYPE;
        //DONE: ITERATION2 MultiContract - change parameter trialId to BudgetContractId
        return Integer.valueOf([select max(Amendment_Number_gne__c) maxAdjustmentNumber from CFAR_Budget_Contract_Tracking_gne__c where Budget_Contract_ref_gne__c = :budgetContractId and frm_Type_gne__c = :adjustmentType][0].get('maxAdjustmentNumber'));
    }
    
    public static Integer determineYearsBetween(CFAR_Budget_Contract_Tracking_gne__c orginal) {
        return determineYearsBetween(orginal.Fully_Executed_Date_gne__c, orginal.Contract_Expiry_Date_gne__c);
    }
    
    public static Integer determineYearsBetween(Date fullyExecuted, Date contractExpired) {
        return contractExpired.year() == fullyExecuted.year() 
               ? 1 
               : contractExpired.year() - fullyExecuted.year() + 1;
    }
    
    public static Integer determineMonthsBetween(CFAR_Budget_Contract_Tracking_gne__c orginal) {
        return determineMonthsBetween(orginal.Fully_Executed_Date_gne__c, orginal.Contract_Expiry_Date_gne__c);
    }
    
    public static Integer determineMonthsBetween(Date fullyExecuted, Date contractExpired) {
        return (contractExpired.year() == fullyExecuted.year() 
                && contractExpired.month() == fullyExecuted.month())
                ? 1 : ((contractExpired.year() - fullyExecuted.year() -1) * 12) 
                        + (12 - fullyExecuted.month() + 1) + contractExpired.month();
    }
    
    public static Decimal roundForStraightLine(Decimal amount) {
        return amount.round(System.RoundingMode.HALF_EVEN);
    }
    
    public static Decimal determineAmountPerMonth(Decimal contractAmount, Integer monthsbetween) {
        return Decimal.valueOf(Double.valueOf(Double.valueOf(contractAmount) / Double.valueOf(monthsbetween)));
    }
    
    public static Decimal returnZeroNotNull(Decimal value) {
        return value == null ? 0 : value;
    }
    
	/* Update projections for a list of trials
     * Parameters: trialIds
     * 4/11/16 FL: Added to support trigger updating several trails at once
     */
    public static void updateProjections(set<Id> trialIds) {
        // Exit if list is empty
        if (trialIds == null || trialIds.isEmpty()) {
            //System.debug('Exiting updateProjections because no trialIds specified');
            return;
        }
        
        //System.debug('***************** Entered updateProjections (Number of trial IDs=' + trialIds.size() + ')');
            
        // Get all budget tracking records for the trials excluding canceled contracts
        String cancelType = Label.CFAR_GSTARS_CONTRACT_TRACKING_CANCELED_TYPE;
        List<CFAR_Budget_Contract_Tracking_gne__c> contrTracking =
            [select Id, frm_trial_id_gne__c, budget_contract_ref_gne__c, Amount_gne__c,
                    Fully_Executed_Date_gne__c, Contract_Expiry_Date_gne__c
               from CFAR_Budget_Contract_Tracking_gne__c 
              where Budget_Contract_ref_gne__r.Team_Member_ref_gne__r.cfar_trial_ref_gne__c in :trialIds
                and Amount_gne__c != null
                and Fully_Executed_Date_gne__c != null
                and Contract_Expiry_Date_gne__c != null
                and Type_ref_gne__r.Name != :cancelType
                order by CreatedDate];
        //System.debug('Number of contract tracking records=' + contrTracking.size());

        // Exit if there are no contracts created yet
        if (contrTracking.isEmpty()) {
            //System.debug('<<<<<<<<<<<<<<<<<< Exit updateProjections since there are no contract tracking records');
            CFAR_SecurityUtils.deleteRecords([select id from CFAR_Budget_CPS_Projection_gne__c where CFAR_Trial_ref_gne__c in :trialIds]);
            return;
        }
                
        // Separate contract tracking records by trial Ids.
        // contrTrackingTrialMap will hold a list of contract tracking records for each trial using trial ID as the key
        Map<Id, List<CFAR_Budget_Contract_Tracking_gne__c>> contrTrackingTrialMap = new Map<Id, List<CFAR_Budget_Contract_Tracking_gne__c>>();
        List<CFAR_Budget_Contract_Tracking_gne__c> contrTrackingList;   // Contract tracking records for one trial
                    
        // Loop through each contract tracking record
        for (CFAR_Budget_Contract_Tracking_gne__c bctRec : contrTracking) {
            // Get existing list from map
            contrTrackingList = contrTrackingTrialMap.get(bctRec.frm_trial_id_gne__c);
                    
            // Create new list if this is the first contract record for a trial
            if (contrTrackingList == null) {
                contrTrackingList = new List<CFAR_Budget_Contract_Tracking_gne__c>();
                contrTrackingTrialMap.put(bctRec.frm_trial_id_gne__c, contrTrackingList);
                        }  
                        
            // Add contract tracking record to the list
            contrTrackingList.add(bctRec);
                    }

        // Get existing projection records for the list of trial Ids
        List<CFAR_Budget_CPS_Projection_gne__c> oldProjections =
            [select Id, Name, CFAR_Trial_ref_gne__c, Year_gne__c, Total_Paid_gne__c, 
                    January_gne__c, February_gne__c, March_gne__c, April_gne__c, May_gne__c, June_gne__c,
                    July_gne__c, August_gne__c, September_gne__c, October_gne__c, November_gne__c, December_gne__c,
                    Quarter_1_gne__c, Quarter_2_gne__c, Quarter_3_gne__c, Quarter_4_gne__c
               from CFAR_Budget_CPS_Projection_gne__c
              where CFAR_Trial_ref_gne__c in :trialIds
              order by CFAR_Trial_ref_gne__c, Year_gne__c asc];
        //System.debug('Number of existing projection records=' + oldProjections.size());

        // Separate projection records by trial Ids.
        // projectionTrialMap will hold a list of projection records for each trial using trial ID as the key
        Map<Id, List<CFAR_Budget_CPS_Projection_gne__c>> projectionTrialMap = new Map<Id, List<CFAR_Budget_CPS_Projection_gne__c>>();
        List<CFAR_Budget_CPS_Projection_gne__c> projectionList;  // Existing projection records for one trial
        
        // Loop through each projection record
        for (CFAR_Budget_CPS_Projection_gne__c projRec : oldProjections) {
            // Get existing list from map
            projectionList = projectionTrialMap.get(projRec.CFAR_Trial_ref_gne__c);

            // Create new list if this is the first contract record for a trial
            if (projectionList == null) {
                projectionList = new List<CFAR_Budget_CPS_Projection_gne__c>();
                projectionTrialMap.put(projRec.CFAR_Trial_ref_gne__c, projectionList);
                }
                
            // Add projection record to the list
            projectionList.add(projRec);
                }
                
        // Create a list for insert/update projections and a list to delete out of range projections.
        List<CFAR_Budget_CPS_Projection_gne__c> upsertProjectionList = new List<CFAR_Budget_CPS_Projection_gne__c>();
        List<CFAR_Budget_CPS_Projection_gne__c> deleteProjectionList = new List<CFAR_Budget_CPS_Projection_gne__c>();
                
        // Loop through each trial and compute projections
        for (Id trialId : trialIds) {
            contrTrackingList = contrTrackingTrialMap.get(trialId);
                
            if (contrTrackingList != null) {
                Map<String, List<CFAR_Budget_CPS_Projection_gne__c>> trialProjections = getProjections(contrTrackingList, projectionTrialMap.get(trialId));
                upsertProjectionList.addAll(trialProjections.get('UPSERT'));
                deleteProjectionList.addAll(trialProjections.get('DELETE'));
                
            } else {
               System.debug('Trial ID ' + trialId + ' does not have any contracts');
            }                   
        }
        
        // upsert and delete projections that are out of range
        Savepoint sp = Database.setSavepoint();
        try {
            if (deleteProjectionList.size() > 0) {
                CFAR_SecurityUtils.deleteRecords(deleteProjectionList);
            }
    
            upsert upsertProjectionList;

        } catch(Exception e) {
            Database.rollback(sp);
            throw e;
            }

        //System.debug('<<<<<<<<<<<<<<<<<< Exit updateProjections');
        }

	/* Get projections for a trial
     * Parameters: contrTracking - list of contract tracking records ordered by budget_contract_ref_gne__c, CreatedDate
     *             oldProjections - list of existing projection records
     * Return: Map containing 2 list: One list of projection records to delete and one to upsert 
     * 4/8/16 FL: Modified to support multi-contracts
     */
    private static Map<String, List<CFAR_Budget_CPS_Projection_gne__c>> getProjections(List<CFAR_Budget_Contract_Tracking_gne__c> contrTracking, List<CFAR_Budget_CPS_Projection_gne__c> oldProjections) {
        //System.debug('***************** Entered getProjections (Number of contract tracking records=' + contrTracking.size() + ')');

        // This will be returned when it exists
        Map<String, List<CFAR_Budget_CPS_Projection_gne__c>> newProjections = new Map<String, List<CFAR_Budget_CPS_Projection_gne__c>>();
        newProjections.put('DELETE', new List<CFAR_Budget_CPS_Projection_gne__c>());
        newProjections.put('UPSERT', new List<CFAR_Budget_CPS_Projection_gne__c>());

        // Exit if trial does not have any contracts yet
        if (contrTracking == null || contrTracking.isEmpty()) {
            //System.debug('<<<<<<<<<<<<<<<<<< Exit updateTrialProjections because there are no contract tracking records');
            // Delete existing projections
            if (oldProjections != null) {
                newProjections.put('DELETE', oldProjections);
            }
            return newProjections;
    }
    
        //System.debug('getting projections for trial ' + contrTracking.get(0).frm_trial_id_gne__c + ')');
        
        // Separate contract tracking records by team members.
        // Also get the first and last year of projection.
        
        // contrTrackingMap will hold a list of contract tracking records for each team member
        // using budget contract ID as the key
        Map<Id, List<CFAR_Budget_Contract_Tracking_gne__c>> contrTrackingMap = new Map<Id, List<CFAR_Budget_Contract_Tracking_gne__c>>();
        List<CFAR_Budget_Contract_Tracking_gne__c> contrTrackingList;   // Contract tracking records for one team member
        Integer projYearStart = 10000, projYearEnd = 0;
            
        // Loop through each contract tracking record
        for (CFAR_Budget_Contract_Tracking_gne__c bctRec : contrTracking) {
            // Get existing list from map
            contrTrackingList = contrTrackingMap.get(bctRec.budget_contract_ref_gne__c);
                            
            // Create new list if this is the first contract record for a team member
            if (contrTrackingList == null) {
                contrTrackingList = new List<CFAR_Budget_Contract_Tracking_gne__c>();
                contrTrackingMap.put(bctRec.budget_contract_ref_gne__c, contrTrackingList);
                        }
                    
            // Add contract tracking record to the list
            contrTrackingList.add(bctRec);

            // Save min and max projection year
            if (bctRec.Fully_Executed_Date_gne__c.year() < projYearStart) {
                projYearStart = bctRec.Fully_Executed_Date_gne__c.year();
            }
            if (bctRec.Contract_Expiry_Date_gne__c.year() > projYearEnd) {
                projYearEnd = bctRec.Contract_Expiry_Date_gne__c.year();
                        }
                    } 
        //System.debug('Number of team members with contracts=' + contrTrackingMap.size());
        //System.debug('Will project from ' + projYearStart + ' to ' + projYearEnd);   
                    
        if (oldProjections == null) {
            oldProjections = new List<CFAR_Budget_CPS_Projection_gne__c>();
                            }
        //System.debug('Number of existing projection records=' + oldProjections.size());

        // Reuse existing projection records so as not to lose the comments
        // Create one projection record per projection year.
        List<CFAR_Budget_CPS_Projection_gne__c> projections = newProjections.get('UPSERT');
        for (integer i = projYearStart; i <= projYearEnd; i++) {
            CFAR_Budget_CPS_Projection_gne__c projRec = null;
                            
            // Reuse existing projection records to keep comments and payment info
            for (CFAR_Budget_CPS_Projection_gne__c oldProjRec : oldProjections) {
                if (Integer.valueof(oldProjRec.year_gne__c) == i) {
                    projRec = oldProjRec;
                    break;
                            }
                        }

            // Create new projection record if it doesn't exist
            if (projRec == null) {
                projRec = new CFAR_Budget_CPS_Projection_gne__c();
                projRec.CFAR_Trial_ref_gne__c = contrTracking.get(0).frm_trial_id_gne__c;
                projRec.year_gne__c = String.valueof(i);
            }
            
            // Initialize values
            projRec.January_gne__c = 0;
            projRec.February_gne__c = 0;
            projRec.March_gne__c = 0;
            projRec.April_gne__c = 0;
			projRec.May_gne__c = 0;
			projRec.June_gne__c = 0;
			projRec.July_gne__c = 0;
			projRec.August_gne__c = 0;
			projRec.September_gne__c = 0;
			projRec.October_gne__c = 0;
			projRec.November_gne__c = 0;
			projRec.December_gne__c = 0;
            if (projRec.Total_Paid_gne__c == null) projRec.Total_Paid_gne__c = 0;
            
            // Add to new projection list
            projections.add(projRec);
        }
        //System.debug('projections size=' + projections.size());
                
        Integer yearKey;

        // If projection record is outside of date range, add to delete list.
        for (integer i = 0; i < oldProjections.size();  i++) {
            yearKey = Integer.valueof(oldProjections.get(i).year_gne__c);

            //System.debug('Will delete projection for year ' + yearKey);
            if (yearKey < projYearStart || yearKey > projYearEnd) {
                newProjections.get('DELETE').add(oldProjections.get(i));
            }
        }
        //System.debug('Number of existing projection records to delete=' + newProjections.get('DELETE').size());

        // Get projections for one team member at a time
        for (List<CFAR_Budget_Contract_Tracking_gne__c> contractTrackingList : contrTrackingMap.values()) {
            Map<Integer, Double> projMap = computeLinearProjections(contractTrackingList);
            
            // Add projections to projection records
            for (CFAR_Budget_CPS_Projection_gne__c projRec : projections) {
                yearKey = Integer.valueof(projRec.year_gne__c) * 100;
                
                // if projMap has projection for Jan, it will have projections for the whole year
                if (projMap.containsKey(yearKey + 1)) {
                    projRec.January_gne__c   += projMap.get(yearKey + 1);
                    projRec.February_gne__c  += projMap.get(yearKey + 2);
                    projRec.March_gne__c     += projMap.get(yearKey + 3);
                    projRec.April_gne__c     += projMap.get(yearKey + 4);
                    projRec.May_gne__c       += projMap.get(yearKey + 5);
                    projRec.June_gne__c      += projMap.get(yearKey + 6);
                    projRec.July_gne__c      += projMap.get(yearKey + 7);
                    projRec.August_gne__c    += projMap.get(yearKey + 8);
                    projRec.September_gne__c += projMap.get(yearKey + 9);
                    projRec.October_gne__c   += projMap.get(yearKey + 10);
                    projRec.November_gne__c  += projMap.get(yearKey + 11);
                    projRec.December_gne__c  += projMap.get(yearKey + 12);
                }
            }
        }

        // Set quarterly projections and round to nearest even number (2.5=2 and 3.5=4) 
        for (CFAR_Budget_CPS_Projection_gne__c projRec : projections) {
            projRec.Quarter_1_gne__c = projRec.January_gne__c + projRec.February_gne__c + projRec.March_gne__c;
            projRec.Quarter_2_gne__c = projRec.April_gne__c + projRec.May_gne__c + projRec.June_gne__c;
            projRec.Quarter_3_gne__c = projRec.July_gne__c + projRec.August_gne__c + projRec.September_gne__c;
            projRec.Quarter_4_gne__c = projRec.October_gne__c + projRec.November_gne__c + projRec.December_gne__c;

            projRec.January_gne__c   = projRec.January_gne__c.round(System.RoundingMode.HALF_EVEN);
            projRec.February_gne__c  = projRec.February_gne__c.round(System.RoundingMode.HALF_EVEN);
            projRec.March_gne__c     = projRec.March_gne__c.round(System.RoundingMode.HALF_EVEN);
            projRec.April_gne__c     = projRec.April_gne__c.round(System.RoundingMode.HALF_EVEN);
            projRec.May_gne__c       = projRec.May_gne__c.round(System.RoundingMode.HALF_EVEN);
            projRec.June_gne__c      = projRec.June_gne__c.round(System.RoundingMode.HALF_EVEN);
            projRec.July_gne__c      = projRec.July_gne__c.round(System.RoundingMode.HALF_EVEN);
            projRec.August_gne__c    = projRec.August_gne__c.round(System.RoundingMode.HALF_EVEN);
            projRec.September_gne__c = projRec.September_gne__c.round(System.RoundingMode.HALF_EVEN);
            projRec.October_gne__c   = projRec.October_gne__c.round(System.RoundingMode.HALF_EVEN);
            projRec.November_gne__c  = projRec.November_gne__c.round(System.RoundingMode.HALF_EVEN);
            projRec.December_gne__c  = projRec.December_gne__c.round(System.RoundingMode.HALF_EVEN);
            projRec.Quarter_1_gne__c = projRec.Quarter_1_gne__c.round(System.RoundingMode.HALF_EVEN);
            projRec.Quarter_2_gne__c = projRec.Quarter_2_gne__c.round(System.RoundingMode.HALF_EVEN);
            projRec.Quarter_3_gne__c = projRec.Quarter_3_gne__c.round(System.RoundingMode.HALF_EVEN);
            projRec.Quarter_4_gne__c = projRec.Quarter_4_gne__c.round(System.RoundingMode.HALF_EVEN);
            
            //System.debug('Projection year '+projRec.year_gne__c+'='+(projRec.Quarter_1_gne__c+projRec.Quarter_2_gne__c+projRec.Quarter_3_gne__c+projRec.Quarter_4_gne__c));
        }

        //System.debug('<<<<<<<<<<<<<<<<<< Exit getProjections returning ' + newProjections.get('UPSERT').size() + ' upserts and ' +  newProjections.get('DELETE').size() + ' deletes');
        return newProjections;
    }

    /* Compute linear projections for one set of contracts. Called by getProjections().
     * Parameters: contractTrackingList (list of contract tracking records sorted by create date)
     * Returns: map of projections with yyyymm as the key
     * 4/8/16 FL: Created
     */
    private static Map<Integer, Double>  computeLinearProjections(List<CFAR_Budget_Contract_Tracking_gne__c> contractTrackingList) {
        //System.debug('***************** Entered computeProjections (contractTrackingList size=' + contractTrackingList.size() + ')');

        Integer projYearStart = 10000, projYearEnd = 0;
        Integer projMonthStart, projMonthEnd;

        // Get the first and last year of projection.
        for (CFAR_Budget_Contract_Tracking_gne__c bctRec : contractTrackingList) {
            // Save min and max year
            if (bctRec.Fully_Executed_Date_gne__c.year() < projYearStart) {
                projYearStart = bctRec.Fully_Executed_Date_gne__c.year();
                projMonthStart = bctRec.Fully_Executed_Date_gne__c.month();
            }
            if (bctRec.Contract_Expiry_Date_gne__c.year() > projYearEnd) {
                projYearEnd = bctRec.Contract_Expiry_Date_gne__c.year();
                projMonthEnd = bctRec.Contract_Expiry_Date_gne__c.month();
                    }
                }
        //System.debug('projYearStart=' + projYearStart + '  projMonthStart=' + projMonthStart);
        //System.debug('projYearEnd=' + projYearEnd + '  projMonthEnd=' + projMonthEnd);
                
        // Create a Map for each projection month using yyyymm as the key.
        Map<Integer, Double> projMap = new Map<Integer, Double>();
        for (integer i = projYearStart; i <= projYearEnd; i++) {
            for (integer j = 1; j <= 12; j++) {
                projMap.put((i*100)+j, 0);
            }
        }
        //System.debug('projMap size=' + projMap.size());
                
        // Get the projMap keys for the first and last projection
        Integer startProjKey = (projYearStart * 100) + projMonthStart;
        Integer endProjKey = (projYearEnd * 100) + projMonthEnd;
        //System.debug('startProjKey=' + startProjKey + '  endProjKey=' + endProjKey);
                
        // Working fields inside loops
        Integer startContrKey;   // yyyymm of the contract tracking executed date
        Integer endContrKey;     // yyyymm of the contract tracking expiry date
        Double priorProjAmt;     // Amount already projected prior to contract execution date
        Double amtToProject;     // Amount to project for a contract tracking record
        Double amtPerMonth;      // Projection amount for each month
        Integer numMonths;       // Number of months from contract execution to expiry
        Date startProjDate;      // Date to start projecting
        CFAR_Budget_Contract_Tracking_gne__c prevBctRec = null;
                
        // Loop through each contract tracking record
        for (CFAR_Budget_Contract_Tracking_gne__c bctRec : contractTrackingList) {
            //System.debug('bctRec date='+bctRec.Fully_Executed_Date_gne__c+' - '+bctRec.Contract_Expiry_Date_gne__c+' amt='+bctRec.Amount_gne__c);
            startProjDate = bctRec.Fully_Executed_Date_gne__c;
                
            // If there is more than a one month gap between previous expiry date and current rec start date,
            // adjust the projection start date so there is no gap.
            if (prevBctRec != null &&
                prevBctRec.Contract_Expiry_Date_gne__c.monthsBetween(startProjDate) > 1) {
                //System.debug('Theres is a gap from previous contract end date');
                    
                // If contract amount is different, then use the month after as the projection start date
                // so there are no projections with zero values in between contract dates.
                if (prevBctRec.Amount_gne__c != bctRec.Amount_gne__c) {
                    startProjDate = prevBctRec.Contract_Expiry_Date_gne__c.addMonths(1);
                // If contract amount is the same, then use start date from previous contract tracking rec
                        } else {
                    startProjDate = prevBctRec.Fully_Executed_Date_gne__c;
                        }
                //System.debug('projection start date changed to '+startProjDate+' from '+bctRec.Fully_Executed_Date_gne__c);
                    }
                    
            // Get the projMapKey yyyymm for the start and end of projections
            startContrKey = (startProjDate.year() * 100) + startProjDate.month();
            endContrKey = (bctRec.Contract_Expiry_Date_gne__c.year() * 100) + bctRec.Contract_Expiry_Date_gne__c.month();

            // Add all projections prior to projection start date
            priorProjAmt = 0;
            for (Integer projMapKey : projMap.keySet()) {
                if (projMapKey < startContrKey) {
                    priorProjAmt += projMap.get(projMapKey);
                        }
                    }
                
            // Amount to project is the contract amount - prior projections
            amtToProject = bctRec.Amount_gne__c - priorProjAmt;

            // Get number of months to project using projection start date and contract expiry date
            numMonths = startProjDate.monthsBetween(bctRec.Contract_Expiry_Date_gne__c) + 1;
            //System.debug('priorProjAmt='+priorProjAmt+' amtToProject='+amtToProject+' numMonths='+numMonths);
                
            // Should never get negative or 0 months to project. If it does, then set projections to zero.
            if (numMonths <= 0) {
                amtToProject = 0;
                numMonths = 1;
                }
                
            // Use straight line method for projection: amount/numMonths.
            amtPerMonth = amtToProject / numMonths;
            //System.debug('projection amount per month='+amtPerMonth);

            // Set projection amount between projection start and end dates.
            // Do not modify projections prior to projection start date.
            // Zero out projections after projection end date.
            for (Integer projMapKey : projMap.keySet()) {
                if (projMapKey >= startContrKey) {
                    if (projMapKey <= endContrKey) {
                        projMap.put(projMapKey, amtPerMonth);
                    } else if (projMapKey > endContrKey) {
                        projMap.put(projMapKey, 0);
                    }
            }
        }
        
            // Save contract record to compare with next record
            prevBctRec = bctRec;
            
            //for (Integer projMapKey : projMap.keySet()) System.debug(projMapKey+'='+projMap.get(projMapKey));
        }
       
        //System.debug('<<<<<<<<<<<<<<<<<< Exit computeProjections returning ' + projMap.size() + ' projMap records');
        return projMap;
    }
    
    public static void updateTotalPaidAmountOnRateTable(Set<String> budgetContractIds, List<CFAR_Rate_Table_gne__c> rateTables) {
        System.debug('----x  updateTotalPaidAmountOnRateTable rateTables ' + rateTables);
        //DONE: ITERATION2 MultiContract
        List<CFAR_Budget_CPS_Payments_gne__c> payments = [select Budget_Contract_ref_gne__c, frm_Trial_Id_gne__c, Invoice_Amount_gne__c,Payment_Explanation_Text_gne__c, Payment_Status_ref_gne__c, 
                                                            Rate_Table_ref_gne__c, Rate_Table_ref_gne__r.PI_Sub_I_Name_gne__c, Planned_Amount_gne__c, Payment_Status_ref_gne__r.Name  
                                                                FROM CFAR_Budget_CPS_Payments_gne__c where Budget_Contract_ref_gne__c in :budgetContractIds ];
                                                                        
        Map<String, Decimal> paymentsMap = new Map<String, Decimal>();
        for(CFAR_Budget_CPS_Payments_gne__c payment : payments) {
            if(String.isNotBlank(payment.Payment_Explanation_Text_gne__c) && payment.Payment_Explanation_Text_gne__c != 'Projected Spend') {
                //DONE: ITERATION2 MultiContract
                String paymentMapKey = createKeyForPaymentsMap(payment.Payment_Explanation_Text_gne__c, payment.Budget_Contract_ref_gne__c);
                if(!paymentsMap.containsKey(paymentMapKey)) 
                    paymentsMap.put(paymentMapKey,0);
                if((payment.Payment_Status_ref_gne__r.Name == Label.CFAR_GSTARS_PAYMENT_SCHEDULE_SUBMITTED_STATUS || payment.Payment_Status_ref_gne__r.Name == Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PAID_STATUS 
                    || payment.Payment_Status_ref_gne__r.Name == Label.CFAR_GSTARS_PAYMENT_SCHEDULE_REFUND_STATUS || payment.Payment_Status_ref_gne__r.Name == Label.CFAR_GSTARS_PAYMENT_SCHEDULE_DUE_NO_INVOICE_SUBMITTED_STATUS) 
                        && payment.Invoice_Amount_gne__c != null) {
                    paymentsMap.put(paymentMapKey,  paymentsMap.get(paymentMapKey) + payment.Invoice_Amount_gne__c);
                }
            }
        }
        
        for(CFAR_Rate_Table_gne__c rateTable : rateTables) {
            if('Total'.equals(rateTable.Payment_Type_gne__c))
                continue;
            
            System.debug('----x  updateTotalPaidAmountOnRateTable rateTable.Total_Paid_Amount_gne__c ' + rateTable.Total_Paid_Amount_gne__c);
            String paymentMapKey = createKeyForPaymentsMap(rateTable.Contract_Term_gne__c, rateTable.Budget_Contract_ref_gne__c);
            //DONE: ITERATION2 MultiContract
            if(paymentsMap.containsKey(paymentMapKey)) {
                //DONE: ITERATION2 MultiContract
                rateTable.Total_Paid_Amount_gne__c = paymentsMap.get(paymentMapKey);
            } else 
                rateTable.Total_Paid_Amount_gne__c = 0;
            System.debug('-x-x total paid ' + rateTable.Total_Paid_Amount_gne__c);
        }
    }
    
    private static String createKeyForPaymentsMap(String contractTerm, String contractId) {
        return contractTerm + contractId;
    }
    
    public static void updatePaidUnitsAndPaidWithheldUnitsOnRateTable(List<CFAR_Rate_Table_gne__c> rateTables) {
        Set<String> regardedPaymentStatuses = new Set<String>{Label.CFAR_GSTARS_PAYMENT_SCHEDULE_SUBMITTED_STATUS, Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PAID_STATUS, Label.CFAR_GSTARS_PAYMENT_SCHEDULE_REFUND_STATUS, Label.CFAR_GSTARS_PAYMENT_SCHEDULE_DUE_NO_INVOICE_SUBMITTED_STATUS};
        List<CFAR_Budget_CPS_Payments_gne__c> payments = [select Invoice_Amount_gne__c, Rate_Table_ref_gne__c, Withhold_Indicator_gne__c, Payment_Status_ref_gne__r.Name   
                                                          from CFAR_Budget_CPS_Payments_gne__c
                                                          where Rate_Table_ref_gne__c in :rateTables];
        
        Map<Id, Decimal> withholdPaymentsMap = new Map<Id, Decimal>();
        Map<Id, Decimal> nonWithholdPaymentsMap = new Map<Id, Decimal>();
        
        for (CFAR_Budget_CPS_Payments_gne__c payment : payments) {
            Id paymentMapKey = payment.Rate_Table_ref_gne__c;
            if ('Yes'.equals(payment.Withhold_Indicator_gne__c)) {
                if (!withholdPaymentsMap.containsKey(paymentMapKey))
                    withholdPaymentsMap.put(paymentMapKey, 0);
                if (regardedPaymentStatuses.contains(payment.Payment_Status_ref_gne__r.Name) && payment.Invoice_Amount_gne__c != null) 
                    withholdPaymentsMap.put(paymentMapKey, withholdPaymentsMap.get(paymentMapKey) + payment.Invoice_Amount_gne__c);
            } else {
                if (!nonWithholdPaymentsMap.containsKey(paymentMapKey))
                    nonWithholdPaymentsMap.put(paymentMapKey, 0);
                if (regardedPaymentStatuses.contains(payment.Payment_Status_ref_gne__r.Name) && payment.Invoice_Amount_gne__c != null)
                    nonWithholdPaymentsMap.put(paymentMapKey, nonWithholdPaymentsMap.get(paymentMapKey) + payment.Invoice_Amount_gne__c);
            }
        }
        
        for (CFAR_Rate_Table_gne__c rateTable : rateTables) {
            if (withholdPaymentsMap.containsKey(rateTable.Id)) {
                if ('Unit'.equals(rateTable.Withhold_Type_gne__c))
                    rateTable.Paid_Withheld_Units_gne__c = withholdPaymentsMap.get(rateTable.Id)/rateTable.Cost_gne__c;
                else if ('Percent'.equals(rateTable.Withhold_Type_gne__c))
                    //rateTable.Paid_Withheld_Units_gne__c = withholdPaymentsMap.get(rateTable.Id)/((rateTable.Cost_gne__c * rateTable.Withhold_Value_gne__c)/100);
                    rateTable.Paid_Withheld_Units_gne__c = withholdPaymentsMap.get(rateTable.Id)/(rateTable.Cost_gne__c - rateTable.Net_Unit_Cost_gne__c);
                else
                    rateTable.Paid_Withheld_Units_gne__c = 0;
            } else {
                rateTable.Paid_Withheld_Units_gne__c = 0;
            }
            if (nonWithholdPaymentsMap.containsKey(rateTable.Id)) {
                if (rateTable.Net_Unit_Cost_gne__c != 0)
                    rateTable.Paid_Units_gne__c = nonWithholdPaymentsMap.get(rateTable.Id)/rateTable.Net_Unit_Cost_gne__c;
                else
                    rateTable.Paid_Units_gne__c = 0;
            } else {
                rateTable.Paid_Units_gne__c = 0;
            }
        }
    }


    public static void updateRateTableTotals(Set<String> contractIds) {
            
        //DONE: ITERATION2
        if(contractIds == null || contractIds.isEmpty())
            return;
        
        List<CFAR_Rate_Table_gne__c> totalsToUpdate = new List<CFAR_Rate_Table_gne__c>();   
        Map<String, List<CFAR_Rate_Table_gne__c>> rtMap = new Map<String, List<CFAR_Rate_Table_gne__c>>();  
        Map<String, CFAR_Rate_Table_gne__c> rtInvMap = new Map<String, CFAR_Rate_Table_gne__c>();   
        //DONE: ITERATION2 MultiContract
        List<CFAR_Rate_Table_gne__c> rts = [SELECT Comments_gne__c, Contract_Term_gne__c, Cost_gne__c , Net_Cost_gne__c, Net_Unit_Cost_gne__c, Budget_Contract_ref_gne__r.Team_Member_ref_gne__c, Payment_Type_gne__c, 
                                                    Total_Type_gne__c,  Name, Id, Total_Amount_gne__c, Unit_gne__c, WithHold_Type_gne__c, 
                                                        WithHold_Value_gne__c, Withhold_Amount_gne__c, Sum_Net_Cost_gne__c, Sum_Total_Amount_gne__c, Status_gne__c, Remaining_Balance_gne__c,
                                                             Remaining_Units_gne__c,Budget_Contract_ref_gne__c FROM CFAR_Rate_Table_gne__c where Budget_Contract_ref_gne__c in: contractIds];
                                                              
       // Map<ID, CFAR_Trial_gne__c> trialsToUpdate = new Map<ID, CFAR_Trial_gne__c>([SELECT Id, Total_Rate_Table_Amount_gne__c, Total_Withholding_gne__c FROM CFAR_Trial_gne__c]);

        Map<ID, CFAR_Budget_Contract_gne__c> contractsToUpdate = new Map<ID, CFAR_Budget_Contract_gne__c>([SELECT Id, Total_Rate_Table_Amount_gne__c, Total_Withholding_gne__c FROM CFAR_Budget_Contract_gne__c]);
       
        
        for(CFAR_Rate_Table_gne__c rt : rts) {
            if(!'Total'.equals(rt.Payment_Type_gne__c)) {
                //DONE: ITERATION2 MultiContract
                if(!rtMap.containsKey(rt.Budget_Contract_ref_gne__c))
                    rtMap.put(rt.Budget_Contract_ref_gne__c, new List<CFAR_Rate_Table_gne__c>());
            
                rtMap.get(rt.Budget_Contract_ref_gne__c).add(rt);
            } else {
                rtInvMap.put(rt.Budget_Contract_ref_gne__c, rt);                         
            }
        }
        
        for(String contractId :rtMap.keyset()) {
            CFAR_Rate_Table_gne__c totalInv = rtInvMap.containsKey(contractId) ? rtInvMap.get(contractId) : new CFAR_Rate_Table_gne__c();
            CFAR_Budget_Contract_gne__c contractForUpdate = contractsToUpdate.get(contractId);
            totalInv.Payment_Type_gne__c = 'Total';
            totalInv.Contract_Term_gne__c = 'Total';
            totalInv.Sum_Total_Amount_gne__c = 0;
            totalInv.Sum_Remaining_Balance_gne__c = 0;
            totalInv.Sum_Remaining_Units_gne__c = 0;
            totalInv.Sum_Net_Cost_gne__c = 0;
            totalInv.Unit_gne__c = 0;
            totalInv.Cost_gne__c = 0.1;

            if(totalInv.Budget_Contract_ref_gne__c == null) 
                totalInv.Budget_Contract_ref_gne__c = contractId;

            contractForUpdate.Total_Withholding_gne__c = 0;
            contractForUpdate.Total_Rate_Table_Amount_gne__c = 0;
            //DONE: ITERATION2
            for(CFAR_Rate_Table_gne__c rt :rtMap.get(contractId)) {
                if(rt.Status_gne__c == 'Active') {
                    totalInv.Sum_Remaining_Balance_gne__c = totalInv.Sum_Remaining_Balance_gne__c + rt.Remaining_Balance_gne__c;
                    totalInv.Sum_Remaining_Units_gne__c = totalInv.Sum_Remaining_Units_gne__c + rt.Remaining_Units_gne__c;                  
                    totalInv.Sum_Total_Amount_gne__c = totalInv.Sum_Total_Amount_gne__c + rt.Total_Amount_gne__c;
                    contractForUpdate.Total_Rate_Table_Amount_gne__c = contractForUpdate.Total_Rate_Table_Amount_gne__c + rt.Total_Amount_gne__c;
                    contractForUpdate.Total_Withholding_gne__c = contractForUpdate.Total_Withholding_gne__c + rt.Withhold_Amount_gne__c;
                }
            }
            totalsToUpdate.add(totalInv);
        }
        if(!totalsToUpdate.isEmpty())
           upsert totalsToUpdate;
        
        if(!contractsToUpdate.isEmpty())
            upsert contractsToUpdate.values();
    }
}