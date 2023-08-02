public with sharing class CFAR_Budget_Controller extends CFAR_TrialBaseController {
        
    public Integer pageSize100 = 100; //LIMITATION !!!

    public ApexPages.StandardSetController stdSetControllerContractTracking;
    public CFAR_Budget_Contract_Tracking_gne__c currentContractTracking {get; set;}
    public Boolean addEditContractTracking {get;set;}
    public String contractTrackingId {get; set;}
    public transient List<String> contractTrackingErrorMessagesList;
    public Set<String> paymentErrorMessagesList;
    public Set<String> rtErrorMessagesList;
    public Set<String> ccErrorMessages;
    public Set<String> ccEditErrorMessages;
    private Set<String> contractAssignmentErrorList;
    public Boolean isContractTrackingError {get; set;}
    public Boolean isPaymentError {get; set;}
    public Boolean isRateTableError {get; set;}
    public Boolean isCCError {get; set;}
    public Boolean isCCEditError {get; set;}
    public Boolean isAssignmentError {get;set;}
    public String selectedInvestigator {get; set;}
    public String selectedInvestigatorToReassign {get;set;}
    public String selectedInvestigatorsBudgetContractId {get;set;}
    public CFAR_Budget_Contract_gne__c selectedInvestigatorContract {get;set;}
    public Boolean hasWithhold {get; set;}
    private Decimal initialInvoiceAmount;
    private String initialWithholdIndicator;
    private Id initialRT;
    private String initialWithholdType;
    private String initialContractTerm;
    public Boolean hasOriginalContract {get;set;}
    public Boolean hasLastPlannedOrCancelled {get;set;}
    public Boolean hasOriginalAmendmentOrAdjustmentContract {get;set;}
    
    public List<String> selectedPISubIs {get; set;}
    public Boolean includeSummary {get; set;}
    public Boolean poNumberIsEdit {get;set;}  
    public String poNumberValue {get;set;}    
    
    public CFAR_Rate_Table_gne__c currentRateTable {get; set;}
    public Cost_Center_for_Trial__c currentCostCenter {get; set;}
    public Boolean editCC {get; set;}
    public Boolean addEditRateTable {get;set;}
    public String rateTableId {get; set;}
    
    public ApexPages.StandardSetController stdSetControllerPaymentSchedule;
    public CFAR_Budget_CPS_Payments_gne__c currentPaymentSchedule {get; set;}
    public Boolean addEditPaymentSchedule {get;set;}
    public String paymentScheduleId {get; set;}
    public Boolean paymentScheduleFrozen {get; set;}
    public Boolean paidOnDateRerender {get; set;}
    public Boolean checkNumRerender {get; set;}
    public Decimal mostRecentContract {get; set;} 
    public Boolean isITAdminProfile {
    	get {
    		return CFAR_Budget_Utils.isAdminProfile(userinfo.getProfileId());
    	}
    	set;
    }
    public Boolean isAdminOrITAdminProfile {
        get {
            return CFAR_Budget_Utils.isAdminOrITAdminProfile(userinfo.getProfileId());
        }
        set;
    }

    public Boolean isAdminProfile {
        get {
            return CFAR_Budget_Utils.isBSAProfile(userinfo.getProfileId());
        }
        set;
    }

    public ApexPages.StandardSetController stdSetControllerProjection;
    public CFAR_Budget_CPS_Projection_gne__c currentProjection {get; set;}
    public Boolean addEditProjection {get;set;}
    public String projectionId {get; set;}
    public String paymentStatus {get; set;}
    
    public String psSortDirection {get; set;}
    public String psSortExpression {get; set;}

    public String rtSortDirection {get; set;}
    public String rtSortExpression {get; set;}    

    public String prjSortDirection {get; set;}
    public String prjSortExpression {get; set;}
    
    private String budgetSortFieldOld;
    public String budgetSortDirection {get; set;}
    public String budgetsortExpression {get {
        if(budgetSortExpression == null)
        return 'CreatedDate';
        else return budgetSortExpression;
    }
        set {
            budgetSortExpression = value;
            if(budgetSortFieldOld == null) budgetSortFieldOld = budgetSortExpression;
            if(budgetSortFieldOld == budgetSortExpression) {
                if(budgetSortDirection == 'desc') budgetSortDirection = 'asc';
                else budgetSortDirection = 'desc';
            } else {
                budgetSortDirection = 'desc';
                budgetSortFieldOld = budgetSortExpression;
            }
        }
    }

    private static Id WBSRequstedID;
    static {
        List<CFAR_WBS_gne__c> requestedWBS = [Select GSR_WBS_gne__c From CFAR_WBS_gne__c where GSR_WBS_gne__c = 'Requested'];
        if(requestedWBS.size() > 0) {
                WBSRequstedID = requestedWBS.get(0).Id;
        }
    }
    
    public Boolean isWBSRequired {
        get {
            return trial.frm_Trial_Status_ref_gne__c == Label.CFAR_GSTARS_TRIAL_STATUS_ACTIVE_ENROLLMENT || trial.frm_Trial_Status_ref_gne__c == Label.CFAR_GSTARS_TRIAL_STATUS_ACTIVE_PUBLICATION
                                        || trial.frm_Trial_Status_ref_gne__c == Label.CFAR_GSTARS_TRIAL_STATUS_FOLLOWUP || trial.frm_Trial_Status_ref_gne__c == Label.CFAR_GSTARS_TRIAL_STATUS_CONCLUDED 
                                                || trial.frm_Trial_Status_ref_gne__c == Label.CFAR_GSTARS_TRIAL_STATUS_PREMATURE_TERMINATION || trial.frm_Trial_Status_ref_gne__c == Label.CFAR_GSTARS_TRIAL_STATUS_PROPOSAL_APPROVED
                                                        || trial.frm_Trial_Status_ref_gne__c == Label.CFAR_GSTARS_TRIAL_STATUS_PROTOCOL_APPROVED || trial.frm_Trial_Status_ref_gne__c == Label.CFAR_GSTARS_TRIAL_STATUS_HOLD
                                                                || trial.frm_Trial_Status_ref_gne__c == Label.CFAR_GSTARS_TRIAL_STATUS_CANCELLED;
        } 
        private set;
    }
    
    private Map<Id, CFAR_Budget_Contract_Type_gne__c> contractTypesMap;
    public String originalPaymentStatus;
    public double originalPaymentPlannedAmount = 0;
    
    public String PAYMENT_VALIDATION_MESSAGE {
        get {
            String currentAmount = String.valueOf(selectedInvestigatorContract.frm_Current_Amount_gne__c);
            return String.format(Label.CFAR_PAYMENT_VALIDATION, new String[]{currentAmount});
        } 
        private set;
    }
    
    public String AMOUNT_LEFT_TO_PROJECT_PROJECTIONS_ERROR {
        get {
            return Label.CFAR_GSTARS_AMOUNT_LEFT_TO_PROJECT_PROJECTIONS_ERROR;
        } 
        private set;
    }
    
    public List<String> financialSectionErrorMessages {get; set;}
    public List<String> getFinancialSecErrorMessages() {
        List<String> financialErrors = new List<String>();
        Boolean trialStatusForWBSRequestedValidation = (trial.frm_Trial_Status_ref_gne__c == Label.CFAR_GSTARS_TRIAL_STATUS_ACTIVE_ENROLLMENT || trial.frm_Trial_Status_ref_gne__c == Label.CFAR_GSTARS_TRIAL_STATUS_ACTIVE_PUBLICATION
                                        || trial.frm_Trial_Status_ref_gne__c == Label.CFAR_GSTARS_TRIAL_STATUS_FOLLOWUP || trial.frm_Trial_Status_ref_gne__c == Label.CFAR_GSTARS_TRIAL_STATUS_CONCLUDED 
                                        || trial.frm_Trial_Status_ref_gne__c == Label.CFAR_GSTARS_TRIAL_STATUS_PREMATURE_TERMINATION);
                                        

            if(String.isBlank(trial.CFAR_WBS_ref_gne__c) && isWBSRequired) {
                financialErrors.add(Label.CFAR_GSTARS_WBS_IS_REQUIRED);
            } 
            
            if(WBSRequstedID != null && trial.CFAR_WBS_ref_gne__c == WBSRequstedID && trialStatusForWBSRequestedValidation ) {
                financialErrors.add(Label.CFAR_GSTARS_WBS_IS_INVALID);  
            }
        
        if(String.isBlank(trial.Cost_Center_gne__c) && getIsITAdministrator()) {
                financialErrors.add(Label.CFAR_GSTARS_COST_CENTER_IS_REQUIRED);
        }
        
        if(String.isBlank(trial.Cost_Element_gne__c) && getIsITAdministrator()) {
                financialErrors.add(Label.CFAR_GSTARS_COST_ELEMENT_IS_REQUIRED);
        }
        return financialErrors;
    }
    
    public List<String> getBudgetMainErrorMessages() {
        List<String> budgetErrors = new List<String>();
        if (trial.frm_Trial_Status_ref_gne__c != Label.CFAR_GSTARS_TRIAL_STATUS_CANCELLED && trial.frm_Trial_Status_ref_gne__c != Label.CFAR_GSTARS_TRIAL_STATUS_HOLD
        && trial.frm_Trial_Status_ref_gne__c != Label.CFAR_GSTARS_TRIAL_STATUS_CONCLUDED && trial.frm_Trial_Status_ref_gne__c != Label.CFAR_GSTARS_TRIAL_STATUS_PREMATURE_TERMINATION) {

            if (selectedInvestigatorContract != null) {
                if (trial.Is_Budget_Straight_Line__c
                && !(selectedInvestigatorContract.Total_Payments_gne__c == null
                && selectedInvestigatorContract.frm_Current_Amount_gne__c == 0)
                && selectedInvestigatorContract.Total_Payments_gne__c != selectedInvestigatorContract.frm_Current_Amount_gne__c) {
                    budgetErrors.add(Label.CFAR_GSTARS_TOTAL_PAYMENTS_NOT_EQUAL_CONTRACT);
                }

                if (selectedInvestigatorContract.Total_Rate_Table_Amount_gne__c != null && selectedInvestigatorContract.Total_Rate_Table_Amount_gne__c != selectedInvestigatorContract.frm_Current_Amount_gne__c) {
                    budgetErrors.add(Label.CFAR_GSTARS_TOTAL_RT_AMOUNT_NOT_MATCH_CURRENT_CONTRACT_AMOUNT);
                }

                if (selectedInvestigator2.frm_Is_Inactive_gne__c == true) {
                    budgetErrors.add(Label.CFAR_INVESTIGATOR_VENDOR_IS_NOT_ACTIVE);
                }
            }
            if (getNeedsContractReassignment()) {
                budgetErrors.add(Label.CFAR_REASSIGN_CONTRACT);
            }
        }
        return budgetErrors;
    }
        
    public Boolean hasPaymentPlannedNotEqualToCurrentAmount {
        get {
            return trial.Is_Budget_Straight_Line__c && selectedInvestigatorContract.Total_Payments_gne__c != selectedInvestigatorContract.frm_Current_Amount_gne__c;
        }
        private set;
    }
    
    public Boolean hasPaymentPlannedAbove250K {
        get {
            return selectedInvestigatorContract.Total_Payments_gne__c > 250000;
        }
        private set;
    }
    
    public Boolean hasNotDrugOnly {
        get {
            return selectedInvestigator2 == null || selectedInvestigator2.Dollar_and_Drug_ref_gne__c == null || (dollarAndDrugMap.get(selectedInvestigator2.Dollar_and_Drug_ref_gne__c) != DRUG_ONLY);
        }
        private set;
    }

    public List<SelectOption> costCenters {
        get {
            return getCostCenters();
        }
        private set;
    }

    public List<Cost_Center_for_Trial__c> costCentersForTrial {
        get {
            return getCostCentersForTrial();
        }
        private set;
    }

    public List<CostCenterWrapper> ccWrapper {get; set;}
    public Integer rowToRemove {get; set;}
    
    public CFAR_Budget_Controller() {
        super(true);
        System.debug('-------------------------- CFAR_Budget_Controller ---------------------------');
        resetBudgetErrors();
        initBudget();
        initInvestigators();
        initCC();
        componentID = 'componentID == Budget Controller!! ';
    }
    
    private void resetBudgetErrors() {
        resetContractTrackingError();
        resetPaymentError();
        resetRTError();
    }
    
    public void initBudget() {
        editMode = false;
        editCC = false;
        addEditRateTable = false;        
        addEditContractTracking = false;
        addEditPaymentSchedule = false;
        contractTypesMap = new Map<Id, CFAR_Budget_Contract_Type_gne__c>([select Id, Name from CFAR_Budget_Contract_Type_gne__c]);
    }

    /* START Multiple Contracts */
    private Map<Id, CFAR_Team_Member_gne__c> investigators;
    public Id selectedInvestigatorId {get; set;}

    private void initInvestigators() {

        List<String> teamMembersWithContracts = new List<String>();
        for (CFAR_Budget_Contract_gne__c contract : [SELECT Team_Member_ref_gne__c FROM CFAR_Budget_Contract_gne__c WHERE Team_Member_ref_gne__c != null])
            teamMembersWithContracts.add(contract.Team_Member_ref_gne__c);

        investigators = new Map<Id, CFAR_Team_Member_gne__c>([SELECT Id, frm_Name_gne__c, frm_Is_Inactive_gne__c, Function_Role_gne__c, frm_Function_Role_gne__c,
        contact_address_ref_gne__r.Contact_Address_ref_gne__r.Institution_gne__r.Name, Dollar_and_Drug_ref_gne__r.Name, (select Id from Budget_Contracts__r)
        FROM CFAR_Team_Member_gne__c 
        WHERE CFAR_Trial_ref_gne__c = :trial.Id 
        AND ((frm_Is_Inactive_gne__c = true AND Id IN :teamMembersWithContracts) 
        OR (frm_Is_Inactive_gne__c = false AND (frm_function_Role_gne__c = 'PI = Primary (or Principal) Investigator' OR frm_function_Role_gne__c = 'Sub-I = Sub-Investigator' OR frm_Function_Role_gne__c = 'DDC = Drug Depot Contact' OR frm_Function_Role_gne__c = 'SLC = Specialty Lab Contact' OR frm_Function_Role_gne__c = 'RCC = Reading Center Contact')))]);

        for (CFAR_Team_Member_gne__c tm : investigators.values()) {
            if (tm.frm_Function_Role_gne__c == 'PI = Primary (or Principal) Investigator' && !tm.frm_Is_Inactive_gne__c) {
                selectedInvestigator2 = tm;
                selectedInvestigatorId = tm.Id;
            } else if (selectedInvestigatorId == null && tm.frm_Function_Role_gne__c == 'PI = Primary (or Principal) Investigator' && tm.frm_Is_Inactive_gne__c) {
                selectedInvestigator2 = tm;
                selectedInvestigatorId = tm.Id;
            } else if (selectedInvestigatorId == null) {
                selectedInvestigator2 = tm;
                selectedInvestigatorId = tm.Id;
            }
        }
        if(investigators.size() < 1){
            selectedInvestigator2 = null;
            selectedInvestigatorId = null;
        }
        setSelectedInvestigatorsBudgetContractId();
    }

    public List<SelectOption> getInvestigatorToReassign() {
        List<String> teamMembersWithContracts = new List<String>();
        for (CFAR_Budget_Contract_gne__c contract : [SELECT Team_Member_ref_gne__c FROM CFAR_Budget_Contract_gne__c WHERE Team_Member_ref_gne__c != null])
            teamMembersWithContracts.add(contract.Team_Member_ref_gne__c);

        Map<Id, CFAR_Team_Member_gne__c> investigatorsToReassign = new Map<Id, CFAR_Team_Member_gne__c>([SELECT Id, frm_Name_gne__c FROM CFAR_Team_Member_gne__c
        WHERE CFAR_Trial_ref_gne__c = :trial.Id AND Id NOT IN :teamMembersWithContracts AND frm_Is_Inactive_gne__c = false
        AND (frm_Function_Role_gne__c = 'PI = Primary (or Principal) Investigator' OR frm_Function_Role_gne__c = 'Sub-I = Sub-Investigator' OR frm_Function_Role_gne__c = 'DDC = Drug Depot Contact' OR frm_Function_Role_gne__c = 'SLC = Specialty Lab Contact' OR frm_Function_Role_gne__c = 'RCC = Reading Center Contact')]);

        List<SelectOption> invOptions = new List<SelectOption> {new SelectOption('--None--', '--None--')};
        for (CFAR_Team_Member_gne__c tm : investigatorsToReassign.values()) {
            invOptions.add(new SelectOption(tm.Id, tm.frm_Name_gne__c));
        }
        return invOptions;
    }

    public CFAR_Team_Member_gne__c selectedInvestigator2 {get; set;}

    public void investigatorSelected() {
        selectedInvestigator2 = investigators.get(selectedInvestigatorId);
        setSelectedInvestigatorsBudgetContractId();
    }

    public String getSelectedInvestigatorRole() {
        if(selectedInvestigator2 != null)
            return selectedInvestigator2.frm_Function_Role_gne__c; 
        else return null;
    }

    public List<SelectOption> getInvestigatorOptions() {
        List<SelectOption> invOptions = new List<SelectOption>();
        for (CFAR_Team_Member_gne__c tm : investigators.values()) {
            invOptions.add(new SelectOption(tm.Id, tm.frm_Name_gne__c));
        }
        return invOptions;
    }

    public override void refreshTrialChildObjects() {
        initInvestigators();
    }

    /* END Multiple Contracts */

    public Boolean getHasPlanning() {
        if(currentContractTracking.Type_ref_gne__c == null) return false;
        return Label.CFAR_GSTARS_CONTRACT_TRACKING_PLANNED_TYPE == contractTypesMap.get(currentContractTracking.Type_ref_gne__c).Name;
    }
    
    public Boolean getHasCancelled() {
        if(currentContractTracking.Type_ref_gne__c == null) return false;
        return Label.CFAR_GSTARS_CONTRACT_TRACKING_CANCELED_TYPE == contractTypesMap.get(currentContractTracking.Type_ref_gne__c).Name;
    }
    
    public Boolean getIsAmendment() {
        if(currentContractTracking.Type_ref_gne__c == null) return false;
        return CFAR_Budget_Utils.getAmendmentTypeNames().contains(contractTypesMap.get(currentContractTracking.Type_ref_gne__c).Name); 
    }
    
    public Boolean getIsUserReadOnly() {
    	Boolean retVal = false;
    	Profile prof = [select Name from Profile where Id =: UserInfo.getProfileId() limit 1][0];
    	if (prof.Name.equals('GNE-CFAR-ReadOnlyUser-New')) {
    		retVal = true;
    	}
    	return retVal;
    }
    
    public Boolean getHasAmendment() {
        if(currentContractTracking.Type_ref_gne__c == null) return false;
        return contractTypesMap.get(currentContractTracking.Type_ref_gne__c) != null && contractTypesMap.get(currentContractTracking.Type_ref_gne__c).Name.toLowerCase().contains('amendment');
    }

	public Boolean getHasLastPlannedOrCancelled() {
		if(selectedInvestigator2 != null) {
			String typeName = CFAR_Budget_Utils.getLastContractType(selectedInvestigator2.Id);
			return typeName == Label.CFAR_GSTARS_CONTRACT_TRACKING_CANCELED_TYPE || typeName == Label.CFAR_GSTARS_CONTRACT_TRACKING_PLANNED_TYPE || typeName == 'Contract Cancelled';
		} else return false;
	}
	
	public Boolean getHasOriginalAmendmentOrAdjustmentContract() {
		if(selectedInvestigator2 != null) {
			return CFAR_Budget_Utils.hasOrginalContractTracking(selectedInvestigator2.Id) ||
					CFAR_Budget_Utils.hasAmendmentConractTracking(selectedInvestigator2.Id) ||
					CFAR_Budget_Utils.hasAdjustmentConractTracking(selectedInvestigator2.Id);
		} else return false;
	}
	
    public Boolean getHasOrginal() {
        if(selectedInvestigator2 != null)
            return CFAR_Budget_Utils.hasOrginalContractTracking(selectedInvestigator2.Id);
        else return false;
    }    
        
    public Boolean getIsRTEditPossible() {
            return getIsAverageUser() || getCurrentUserIsAdmin();
    }
    
    public Boolean getIsOrginal() {
        if(currentContractTracking.Type_ref_gne__c == null) return false;
        return contractTypesMap.get(currentContractTracking.Type_ref_gne__c).Name == Label.CFAR_GSTARS_CONTRACT_TRACKING_ORGINAL_TYPE;
    }
    
    public Boolean getIsAdjustment() {
        if(currentContractTracking.Type_ref_gne__c == null) return false;
        return contractTypesMap.get(currentContractTracking.Type_ref_gne__c).Name == Label.CFAR_GSTARS_CONTRACT_TRACKING_ADJUSTMENT_TYPE;
    }
    
    public Boolean getIsAmendmentNoChange() {
        if (currentContractTracking.Type_ref_gne__c == null) return false;
        return contractTypesMap.get(currentContractTracking.Type_ref_gne__c).Name == Label.CFAR_GSTARS_CONTRACT_TRACKING_AMENDMENT_NO_CHANGE_TYPE;
    }
    
    private void setSelectedInvestigatorsBudgetContractId() {
        try {
            CFAR_SearchParameters parameters = new CFAR_SearchParameters();
            parameters.andEqualsParameters.put('Team_Member_ref_gne__c', selectedInvestigator2.Id);
            CFAR_Budget_Contract_gne__c[] contract = CFAR_DAO.getBudgetContracts(parameters);
            selectedInvestigatorsBudgetContractId = contract[0].Id;
            selectedInvestigatorContract = contract[0];
        } catch (Exception e) {
            selectedInvestigatorsBudgetContractId = null;
            selectedInvestigatorContract = null;
        }
    }

    private Id createNewBudgetContract() {
        CFAR_Budget_Contract_gne__c newBudgetContract = new CFAR_Budget_Contract_gne__c(Team_Member_ref_gne__c = selectedInvestigator2.Id);
        try {
            insert newBudgetContract;
            return newBudgetContract.Id;
        } catch (Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
            return null;
        }
    }

    public CFAR_Budget_Contract_Tracking_gne__c[] getContractTrackings() {
        hasOriginalContract = getHasOrginal();
		hasLastPlannedOrCancelled = getHasLastPlannedOrCancelled();
		hasOriginalAmendmentOrAdjustmentContract = getHasOriginalAmendmentOrAdjustmentContract();
        CFAR_SearchParameters parameters = new CFAR_SearchParameters();
        if (budgetSortExpression != null) 
            parameters.sortExpression = budgetSortExpression;

        if (budgetSortDirection != null)
            parameters.sortDirection = budgetSortDirection;

        if (selectedInvestigatorsBudgetContractId != null) {
            parameters.andEqualsParameters.put('Budget_Contract_ref_gne__c', selectedInvestigatorsBudgetContractId);
            stdSetControllerPaymentSchedule = new ApexPages.StandardSetController(CFAR_DAO.getBudgetContractTrackings(parameters));
            stdSetControllerPaymentSchedule.setPageSize(pageSize100);
            return stdSetControllerPaymentSchedule.getRecords();
        }
        else return null;
    }
    
    public List<SelectOption> getPaymentExplanations() {  
        List<SelectOption> options = new List<SelectOption>{new SelectOption('--None--', '--None--')};
        options.add(new SelectOption('Projected Spend', 'Projected Spend'));
        List<CFAR_Rate_Table_gne__c> rates = [SELECT Payment_Type_gne__c, Id, Contract_Term_gne__c  FROM CFAR_Rate_Table_gne__c WHERE Budget_Contract_ref_gne__c = :selectedInvestigatorsBudgetContractId and Payment_Type_gne__c != 'Total' and Status_gne__c = 'Active' order by Contract_Term_gne__c];
        Set<String> pExp = new Set<String>();
        for (CFAR_Rate_Table_gne__c rate : rates) {
                pExp.add(rate.Contract_Term_gne__c);
        }
        
        for(String exp : pExp) {
                options.add(new SelectOption(exp, exp));
        }       
        return options;         
    }
    
    public Boolean getIsEditRT() { 
        return currentRateTable.Id != null;
    }
    
    public Boolean getIsAddRT() { 
        return currentRateTable.Id == null;
    }
    
    public List<RateTableWrapper> getRateTables() {

        if (String.isBlank(rtSortExpression)) {
            searchParam = new CFAR_SearchParameters();
            rtSortExpression = searchParam.sortExpression = 'CreatedDate';
            rtSortDirection = searchParam.sortDirection = 'asc';
        } else {
            if (null != rtSortExpression)
                searchParam.sortExpression = rtSortExpression;
            if (null != rtSortDirection)
                searchParam.sortDirection = rtSortDirection;

        }

        if (selectedInvestigatorsBudgetContractId != null) {
            searchParam.andEqualsParameters.put('Budget_Contract_ref_gne__c', selectedInvestigatorsBudgetContractId);

            stdSetControllerPaymentSchedule = new ApexPages.StandardSetController(CFAR_DAO.getRateTables(searchParam));
            stdSetControllerPaymentSchedule.setPageSize(pageSize100);
            List<RateTableWrapper> rtables = new List<RateTableWrapper>();

            CFAR_Rate_Table_gne__c[] rates =  stdSetControllerPaymentSchedule.getRecords();
            List<CFAR_Rate_Table_gne__c> totals = new List<CFAR_Rate_Table_gne__c>();
            for (CFAR_Rate_Table_gne__c rate : rates) {
                if (!'Total'.equals(rate.Payment_Type_gne__c))
                    rtables.add(new RateTableWrapper(rate));
                else totals.add(rate);
            }
            for (CFAR_Rate_Table_gne__c rate : totals) {
                rtables.add(new RateTableWrapper(rate));
            }
            return rtables;
        } else return null;
    }
    
    public CFAR_Budget_CPS_Payments_gne__c[] getPayments() {
        if (String.isBlank(psSortExpression)) {
            searchParam = new CFAR_SearchParameters();
            psSortExpression = searchParam.sortExpression = 'Planned_Date_gne__c;Line_Num_gne__c';
            psSortDirection = searchParam.sortDirection = 'desc';
        } else {
            if (null != psSortExpression)
                searchParam.sortExpression = psSortExpression;
            if (null != psSortDirection)
                searchParam.sortDirection = psSortDirection;
        }
		
        if (selectedInvestigatorsBudgetContractId != null) {
            searchParam.andEqualsParameters.put('Budget_Contract_ref_gne__c', selectedInvestigatorsBudgetContractId);
            stdSetControllerPaymentSchedule = new ApexPages.StandardSetController(CFAR_DAO.getPayments(searchParam));
            stdSetControllerPaymentSchedule.setPageSize(pageSize100);
            return stdSetControllerPaymentSchedule.getRecords();
        } else return null;
    }
    
    public CFAR_Budget_CPS_Projection_gne__c[] getProjections() {
        
searchParam = new CFAR_SearchParameters();

        if(String.isBlank(prjSortExpression)) {
            
            prjSortExpression = searchParam.sortExpression = 'Year_gne__c';
            prjSortDirection = searchParam.sortDirection = 'asc';
        } else {
            if (null!=prjSortExpression)
                searchParam.sortExpression = prjSortExpression;
            if (null!=prjSortDirection)
                searchParam.sortDirection = prjSortDirection;

        }
        


        stdSetControllerPaymentSchedule = new ApexPages.StandardSetController(CFAR_DAO.getProjections(searchParam, trial.Id));
        stdSetControllerPaymentSchedule.setPageSize(pageSize100);
        return stdSetControllerPaymentSchedule.getRecords();
    }
    
    public CFAR_Projected_Subject_Accrual_gne_ref__c[] getProjectedAccruals() {
        return CFAR_DAO.getAccrualRelatedToTrial(trial.Id);
    }
    
    public void onCheckChanged() {
        if(!String.isBlank(currentPaymentSchedule.Check_Num_gne__c) && currentPaymentSchedule.Paid_On_gne__c != null) {
            String paidStatus = Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PAID_STATUS;
            CFAR_Payment_Schedule_Status_gne__c s = [select Id, Name from CFAR_Payment_Schedule_Status_gne__c where Name = :paidStatus];
            currentPaymentSchedule.Payment_Status_ref_gne__c = s.Id;
            currentPaymentSchedule.Payment_Status_ref_gne__r = s;
        }
    }
    
    public void onPaindOnChanged() {
        if(!String.isBlank(currentPaymentSchedule.Check_Num_gne__c) && currentPaymentSchedule.Paid_On_gne__c != null) {
            String paidStatus = Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PAID_STATUS;
            CFAR_Payment_Schedule_Status_gne__c s = [select Id, Name from CFAR_Payment_Schedule_Status_gne__c where Name = :paidStatus];
            currentPaymentSchedule.Payment_Status_ref_gne__c = s.Id;
            currentPaymentSchedule.Payment_Status_ref_gne__r = s;
        }
        if(paymentErrorMessagesList == null)
                resetPaymentError();
        if(currentPaymentSchedule.Paid_On_gne__c!=null && currentPaymentSchedule.Paid_On_gne__c > Date.today()){
            paymentErrorMessagesList.add(Label.CFAR_GSTARS_PAID_ON_DATE_IS_A_FUTURE_DATE);
            isPaymentError=true;
        } else {
                paymentErrorMessagesList.remove(Label.CFAR_GSTARS_PAID_ON_DATE_IS_A_FUTURE_DATE);
        }
    }
    
    public void onPlannedDateChanged() {
        
        if(paymentErrorMessagesList == null)
                resetPaymentError();
        if(currentPaymentSchedule.Planned_Date_gne__c != null && selectedInvestigatorContract.Contract_End_Date_gne__c != null && currentPaymentSchedule.Planned_Date_gne__c > selectedInvestigatorContract.Contract_End_Date_gne__c){
            paymentErrorMessagesList.add(Label.CFAR_GSTARS_PLANNED_DATE_AFTER_CONTRACT_EXPIRY_DATE);
            isPaymentError=true;
        } else {
                paymentErrorMessagesList.remove(Label.CFAR_GSTARS_PLANNED_DATE_AFTER_CONTRACT_EXPIRY_DATE);
        }
        if(currentPaymentSchedule.Planned_Date_gne__c!=null && currentPaymentSchedule.Planned_Date_gne__c < Date.today()){
            paymentErrorMessagesList.add(Label.CFAR_GSTARS_PLANNED_DATE_IS_A_PAST_DATE);
            isPaymentError=true;
        } else {
                paymentErrorMessagesList.remove(Label.CFAR_GSTARS_PLANNED_DATE_IS_A_PAST_DATE);
        }
        if(currentPaymentSchedule.Planned_Date_gne__c!=null && selectedInvestigatorContract.Original_Contract_Execution_Date_gne__c != null && currentPaymentSchedule.Planned_Date_gne__c < selectedInvestigatorContract.Original_Contract_Execution_Date_gne__c){
            paymentErrorMessagesList.add(Label.CFAR_GSTARS_PLANNED_DATE_PRIOR_FULLY_EXECUTED_DATE);
            isPaymentError=true;
        } else {
                paymentErrorMessagesList.remove(Label.CFAR_GSTARS_PLANNED_DATE_PRIOR_FULLY_EXECUTED_DATE);
        }
    }
    
    public List<SelectOption> getContractTypes() {
        List<SelectOption> result = new List<SelectOption>();
        
        CFAR_SearchParameters searchParameters = new CFAR_SearchParameters();
        searchParameters.andEqualsParameters.put('Active_gne__c','true');
        CFAR_Budget_Contract_Type_gne__c[] types =  CFAR_DAO.getContractTrackings(searchParameters);
        Boolean hasOrginalType = getHasOrginal();
        for(CFAR_Budget_Contract_Type_gne__c t : types)
        {
            if(t.Name == Label.CFAR_GSTARS_CONTRACT_TRACKING_ORGINAL_TYPE && hasOrginalType) {
                continue;
            } else if(t.Name == Label.CFAR_GSTARS_CONTRACT_TRACKING_ADJUSTMENT_TYPE && !hasOrginalType){
                continue;
            } else if(t.Name == label.CFAR_GSTARS_CONTRACT_TRACKING_CANCELED_TYPE && currentContractTracking.Type_ref_gne__c == null){
                continue;
            }            
            result.add(new SelectOption(t.Id, t.Name));
        }  
        return result;
    }

    
    public void contractTypeChanged() {
        currentContractTracking.Amendment_Number_gne__c = null;
        if(getHasPlanning()) {
            currentContractTracking.Contract_ID_gne__c = null;
            currentContractTracking.Amendment_Number_gne__c = 0;
        } else if(getIsAmendment()) { 
                if(currentContractTracking.Amendment_Number_gne__c == null || currentContractTracking.Amendment_Number_gne__c == 0) {
                Integer amNumber = CFAR_Budget_Utils.getLastAmendmentNumber(currentContractTracking.Budget_Contract_ref_gne__c);
                currentContractTracking.Amendment_Number_gne__c = 1 + (amNumber == null ? 0 : amNumber);
                }
        } else if(getIsAdjustment()) { 
                if(currentContractTracking.Amendment_Number_gne__c == null || currentContractTracking.Amendment_Number_gne__c == 0) {
                Integer amNumber = CFAR_Budget_Utils.getLastAdjustmentNumber(currentContractTracking.Budget_Contract_ref_gne__c);
                currentContractTracking.Amendment_Number_gne__c = 1 + (amNumber == null ? 0 : amNumber);
                }
        } else {
                currentContractTracking.Amendment_Number_gne__c = 0;
        }
        if((getIsAdjustment() || getIsAmendmentNoChange()) && selectedInvestigatorContract != null){
            currentContractTracking.Amount_gne__c=selectedInvestigatorContract.frm_Current_Amount_gne__c;
        }
        if(currentContractTracking.Type_ref_gne__c != null) {
            currentContractTracking.Type_ref_gne__r = contractTypesMap.get(currentContractTracking.Type_ref_gne__c);
            if(currentContractTracking.Type_ref_gne__r.Name == 'Contract Cancelled'){
                currentContractTracking.Amount_gne__c = 0;
            }
        }
    }
    
    public PageReference saveTrial() {
        financialSectionErrorMessages = getFinancialSecErrorMessages();
        Savepoint sp = Database.setSavepoint();
            
        if(financialSectionErrorMessages.size() == 0) {
                PageReference pr = (new ApexPages.StandardController(trial)).save();
                isError = (pr == null && ApexPages.hasMessages()) || financialSectionErrorMessages.size() > 0;
        } else {
                isError = true;
        }
        
        if(isError) {
                Database.rollback(sp);
            logMessage();
        } else {
            refreshTrial();
            financialSectionErrorMessages.clear();
            editMode = false;
            return null; //new PageReference('/apex/CFAR_Trial?id='+trial.Id).setRedirect(true);
        }
        return null;
    }
    
    public override void edit() {
        editMode = true;
    }

    public void editCC() {
        editCC = true;
    }
    
    public void saveCC() {
        resetCCEditError();
        Decimal value = 0;
        for (Cost_Center_for_Trial__c c : this.trial.Cost_Centers_for_Trial__r) {
            value = value + c.Value__c;
        }
        if (value > 100) {
            isCCEditError = true;
            ccEditErrorMessages.add('Cost Center Values should not exceed 100.00');
        }

        List<ID> ccIds = new List<String>();
        for (Cost_Center_for_Trial__c c : this.trial.Cost_Centers_for_Trial__r) {
            if (ccIds.contains(c.Cost_Center__c)) {
                isCCEditError = true;
                ccEditErrorMessages.add('Cost Center Names should be unique.');
            }
            ccIds.add(c.Cost_Center__c);
        }

        if (!isCCEditError) {
            update this.trial.Cost_Centers_for_Trial__r;
            refreshTrial();
            cancelCC();
            resetCCEditError();        
        }         
    }

    public void cancelCC() {
        editCC = false;
    }
    
    public override PageReference cancel() {
        editMode = false;
        refreshTrial();
        if(financialSectionErrorMessages != null)
                financialSectionErrorMessages.clear();
        return null;
    }

    public void initCC() {
        recalculateMostRecentContract();
        ccWrapper = new List<CostCenterWrapper>();
        addNewCCRow();
    }

    public void recalculateMostRecentContract() {
        List<CFAR_Budget_Contract_Tracking_gne__c> getMostRecentContract = [SELECT id, Amount_gne__c FROM CFAR_Budget_Contract_Tracking_gne__c WHERE Budget_Contract_ref_gne__c = :selectedInvestigatorsBudgetContractId ORDER BY Id DESC limit 1];
        if (!getMostRecentContract.isEmpty()) {
            mostRecentContract = getMostRecentContract[0].Amount_gne__c;
        }
    }

    public void addNewCCRow() {
        CostCenterWrapper newCostCenter = new CostCenterWrapper();
        if (costCentersForTrial.size() + ccWrapper.size() == 0) {
            newCostCenter.record = new Cost_Center_for_Trial__c(
                Value__c = 100
            );
        } else {
            newCostCenter.record = new Cost_Center_for_Trial__c(
                Value__c = 0
            );
        }
        newCostCenter.index = ccWrapper.size();
        ccWrapper.add(newCostCenter);
    }

    public void removeCCRow() {
        ccWrapper.remove(rowToRemove);
    }

    public class CostCenterWrapper {
        public Integer index {get; set;}
        public Cost_Center_for_Trial__c record {get; set;}
    }

    public void createNewCostCenters() {
        resetError();
        currentCostCenter = new Cost_Center_for_Trial__c();
    }

    public void createNewRateTable() {
        resetError();
        resetRTError();

        currentRateTable = new CFAR_Rate_Table_gne__c();
        addEditRateTable = true;
    }
    
    public void editRateTable() {
        resetError();
        resetRTError();
        currentRateTable = [SELECT Status_gne__c, Comments_gne__c, Contract_Term_gne__c, Cost_gne__c, Net_Cost_gne__c, Net_Unit_Cost_gne__c, Budget_Contract_ref_gne__r.Team_Member_ref_gne__c, Payment_Type_gne__c,
                Name, Id, Total_Amount_gne__c, Budget_Contract_ref_gne__c, Unit_gne__c, WithHold_Type_gne__c, WithHold_Value_gne__c
                FROM CFAR_Rate_Table_gne__c where Id = :rateTableId];
        initialWithholdType = String.valueOf(currentRateTable.WithHold_Type_gne__c);
        initialContractTerm = String.valueOf(currentRateTable.Contract_Term_gne__c);
        addEditRateTable = true;
    }
    
    public void cancelRateTable() {
        addEditRateTable = false;
        resetError();
        resetRTError();
    }
    
    public PageReference submitRateTable() {   
        
        resetRTError();

        System.debug('--------- submitRateTable()');           
                if(String.isBlank(currentRateTable.Payment_Type_gne__c)) {
            rtErrorMessagesList.add(Label.CFAR_GSTARS_PAYMENT_TYPE_REQUIRED);
            isRateTableError=true;    
        } 
        
        if(String.isBlank(currentRateTable.Contract_Term_gne__c)) {
            rtErrorMessagesList.add(Label.CFAR_GSTARS_CONTRACT_TERM_REQUIRED);
            isRateTableError=true;                      
        }
        
        if(currentRateTable.Cost_gne__c == null ) {
            rtErrorMessagesList.add(Label.CFAR_GSTARS_UNIT_COST_REQUIRED);
            isRateTableError=true;    
        }
        
        if(currentRateTable.Unit_gne__c == null) {
            rtErrorMessagesList.add(Label.CFAR_GSTARS_NUMBER_OF_UNITS_REQUIRED);
            isRateTableError=true;    
        }
        if(currentRateTable.Cost_gne__c != null && currentRateTable.Cost_gne__c <= 0) {                      
                rtErrorMessagesList.add(Label.CFAR_GSTARS_UNIT_COST_GREATER_ZERO);
                isRateTableError=true;  
        }
        
        if(String.isNotBlank(currentRateTable.WithHold_Type_gne__c) && currentRateTable.WithHold_Value_gne__c == null) {
            rtErrorMessagesList.add(Label.CFAR_GSTARS_WITHHOLD_VALUE_REQUIRED);
            isRateTableError=true;    
        }

        if(String.isNotBlank(currentRateTable.WithHold_Type_gne__c) && currentRateTable.WithHold_Value_gne__c != null) {
            if (currentRateTable.WithHold_Value_gne__c <= 0) {
                rtErrorMessagesList.add(Label.CFAR_GSTARS_WITHHOLD_VALUE_GREATER_ZERO);
                isRateTableError=true;
            }
            else if ('Percent'.equals(currentRateTable.WithHold_Type_gne__c) && currentRateTable.WithHold_Value_gne__c > 100) {
                rtErrorMessagesList.add(Label.CFAR_GSTARS_WITHHOLD_VALUE_GREATER_100_PERCENT);
                isRateTableError=true;
            }
            else if ('Unit'.equals(currentRateTable.WithHold_Type_gne__c) && currentRateTable.Unit_gne__c != null && currentRateTable.WithHold_Value_gne__c > currentRateTable.Unit_gne__c) {
                rtErrorMessagesList.add(Label.CFAR_GSTARS_WITHHOLD_VALUE_GREATER_NUMBER_OF_UNITS);
                isRateTableError=true;
            }
        }
        for(CFAR_Rate_Table_gne__c rt : [Select id, Contract_Term_gne__c from CFAR_Rate_Table_gne__c where Budget_Contract_ref_gne__c =: selectedInvestigatorsBudgetContractId]) {
                if(rt.Contract_Term_gne__c.equalsIgnoreCase(currentRateTable.Contract_Term_gne__c) && rt.Id != currentRateTable.Id) {                   
                        rtErrorMessagesList.add(Label.CFAR_GSTARS_CONTRACT_TERM_IS_NOT_UNIQUE);
                        isRateTableError=true;  
                }
        }
        
        if(currentRateTable.Id != null) {
            String cancelledStatus = Label.CFAR_GSTARS_PAYMENT_SCHEDULE_CANCELLED_STATUS;
                List<CFAR_Budget_CPS_Payments_gne__c> payments = [Select Id from CFAR_Budget_CPS_Payments_gne__c where Rate_Table_ref_gne__c =: currentRateTable.Id 
                                AND Payment_Status_ref_gne__r.Name != :cancelledStatus];
                if(currentRateTable.Status_gne__c == 'Not Active' && payments.size() > 0 ) {
                        rtErrorMessagesList.add(Label.CFAR_GSTARS_UNABLE_TO_SET_NOT_ACTIVE_STATUS_IN_RATE_TABLE);
                        isRateTableError=true;                          
                }       
                if(initialContractTerm != currentRateTable.Contract_Term_gne__c && payments.size() > 0 ) {
                        rtErrorMessagesList.add(Label.CFAR_GSTARS_CONTRACT_TERM_USED_IN_PAYMENTS);
                        isRateTableError=true;                                          
                }
                if (String.isNotBlank(initialWithholdType) && !initialWithholdType.equals(currentRateTable.WithHold_Type_gne__c)) {
                                if ('Percent'.equals(initialWithholdType) && Integer.valueOf([select count(Id) counter from CFAR_Budget_CPS_Payments_gne__c where Rate_Table_ref_gne__c =: currentRateTable.Id][0].get('counter')) > 0) {
                                        //rtErrorMessagesList.add(Label.CFAR_GSTARS_CANT_CLEAR_WITHOLD_TYPE_PERCENT_IF_PAYMENTS_EXIST_FOR_RT);
                                        rtErrorMessagesList.add(Label.CFAR_GSTARS_CANT_CHANGE_WITHOLD_TYPE_IF_PAYMENTS_EXIST_FOR_RT);
                                        isRateTableError=true;
                                }
                                else if ('Unit'.equals(initialWithholdType) && Integer.valueOf([select count(Id) counter from CFAR_Budget_CPS_Payments_gne__c where Rate_Table_ref_gne__c =: currentRateTable.Id and Withhold_Indicator_gne__c = 'Yes'][0].get('counter')) > 0) {
                                        //rtErrorMessagesList.add(Label.CFAR_GSTARS_CANT_CLEAR_WITHOLD_TYPE_UNIT_IF_PAYMENTS_EXIST_FOR_RT);
                                        rtErrorMessagesList.add(Label.CFAR_GSTARS_CANT_CHANGE_WITHOLD_TYPE_IF_PAYMENTS_EXIST_FOR_RT);
                                        isRateTableError=true;
                                }

                }       
        }
        
        if (!isError && !isRateTableError) {

            if (selectedInvestigatorsBudgetContractId == null) {
                selectedInvestigatorsBudgetContractId = createNewBudgetContract();
            }

            if(currentRateTable.Budget_Contract_ref_gne__c == null) {
                currentRateTable.Budget_Contract_ref_gne__c = selectedInvestigatorsBudgetContractId; 
            }

            if (currentRateTable.Id != null) {
                CFAR_Rate_Table_gne__c clonedTable = currentRateTable;
                currentRateTable = new CFAR_Rate_Table_gne__c(
                    id = clonedTable.Id,
                    Status_gne__c = clonedTable.Status_gne__c,
                    Payment_Type_gne__c = clonedTable.Payment_Type_gne__c,
                    Contract_Term_gne__c = clonedTable.Contract_Term_gne__c,
                    Cost_gne__c = clonedTable.Cost_gne__c,
                    Unit_gne__c = clonedTable.Unit_gne__c,
                    Withhold_Type_gne__c = clonedTable.Withhold_Type_gne__c,
                    Withhold_Value_gne__c = clonedTable.Withhold_Value_gne__c,
                    Comments_gne__c = clonedTable.Comments_gne__c);
            }

            Database.UpsertResult result = CFAR_SecurityUtils.upsertRecord(currentRateTable, CFAR_Rate_Table_gne__c.getSObjectType())[0];
            if (!result.isSuccess()) {
                isRateTableError = true;
                for (Database.Error err : result.getErrors()) {
                    rtErrorMessagesList.add(err.getMessage());
                }
            }
            if (isError || isRateTableError) {
                logMessage();
            } else {
                refreshTrial();
                getRateTables();
                investigatorSelected();
            }
        }
        return null;
    }
    
    //CONTRACT TRACKING
    public void createNewContractTracking() {
        resetError();
        resetContractTrackingError();

        currentContractTracking = new CFAR_Budget_Contract_Tracking_gne__c();
        addEditContractTracking = true;
    }
    
    public PageReference submitContractTracking() {
        resetContractTrackingError();
        
        if(currentContractTracking.Type_ref_gne__c == null) {
            isContractTrackingError = true;
                contractTrackingErrorMessagesList.add(Label.CFAR_GSTARS_CONTRACT_TYPE_REQUIRED);
        }
        
        if (currentContractTracking.Type_ref_gne__r.Name == Label.CFAR_GSTARS_CONTRACT_TRACKING_CANCELED_TYPE && !getHasOrginal() && CFAR_Budget_Utils.hasProjections(currentContractTracking.frm_Trial_Id_gne__c)) {
        	List<CFAR_Budget_CPS_Projection_gne__c> projectionsToDel = 
        		[SELECT Id, Quarter_1_gne__c,Quarter_2_gne__c,Quarter_3_gne__c,Quarter_4_gne__c,
				January_gne__c, February_gne__c, March_gne__c, April_gne__c, May_gne__c, June_gne__c, July_gne__c, 
				August_gne__c, September_gne__c, October_gne__c, November_gne__c, December_gne__c, 
				CFAR_Trial_ref_gne__c, Year_gne__c, Total_Paid_gne__c, frm_Total_Amount_gne__c
				FROM CFAR_Budget_CPS_Projection_gne__c WHERE CFAR_Trial_ref_gne__r.Id = :currentContractTracking.frm_Trial_Id_gne__c];
			try{
                CFAR_SecurityUtils.deleteRecords(projectionsToDel);
            } catch(Exception ex){
                ApexPages.addMessages(ex);
                return null;
            }
        }
        
        if(currentContractTracking.Type_ref_gne__c != null 
            && (currentContractTracking.Type_ref_gne__r.Name == Label.CFAR_GSTARS_CONTRACT_TRACKING_INCREASE_TYPE
                    || currentContractTracking.Type_ref_gne__r.Name == Label.CFAR_GSTARS_CONTRACT_TRACKING_AMENDMENT_NO_CHANGE_TYPE
                    || currentContractTracking.Type_ref_gne__r.Name == Label.CFAR_GSTARS_CONTRACT_TRACKING_ADJUSTMENT_TYPE
                    || currentContractTracking.Type_ref_gne__r.Name == Label.CFAR_GSTARS_CONTRACT_TRACKING_DECREASE_TYPE)
            && !getHasOrginal()) {
                
                isContractTrackingError = true;
            contractTrackingErrorMessagesList.add(Label.CFAR_CONTRACT_ORGINAL_REQUIRED);
        }
 
        if(currentContractTracking.Type_ref_gne__c != null
                && (currentContractTracking.Type_ref_gne__r.Name == Label.CFAR_GSTARS_CONTRACT_TRACKING_DECREASE_TYPE
                || currentContractTracking.Type_ref_gne__r.Name == Label.CFAR_GSTARS_CONTRACT_TRACKING_INCREASE_TYPE
                || currentContractTracking.Type_ref_gne__r.Name == Label.CFAR_GSTARS_CONTRACT_TRACKING_ORGINAL_TYPE)
                && currentContractTracking.Contract_Requested_Date__c == null) {

            isContractTrackingError = true;
            contractTrackingErrorMessagesList.add(Label.CFAR_GSTARS_CONTRACT_REQUESTED_DATE_REQUIRED);
        }
 
        if (((currentContractTracking.Type_ref_gne__c == null  || !getHasPlanning()) && !getHasCancelled()) && String.isBlank(currentContractTracking.Contract_ID_gne__c)) {
                isContractTrackingError = true;
                contractTrackingErrorMessagesList.add(Label.CFAR_GSTARS_CONTRACT_ID_REQUIRED);
        }
        
        if (currentContractTracking.Amount_gne__c == null) {
                isContractTrackingError = true;
            contractTrackingErrorMessagesList.add(Label.CFAR_GSTARS_TOTAL_CONTRACT_AMOUNT_REQUIRED);
        }
        
        if (getIsAmendment()) {
                if (currentContractTracking.Amendment_Number_gne__c == null) {
                        isContractTrackingError = true;
                        contractTrackingErrorMessagesList.add(Label.CFAR_GSTARS_AMENDMENT_NUMBER_REQUIRED);
                }
                else if (CFAR_Utils.invalidIntegerOrLong(currentContractTracking.Amendment_Number_gne__c)) {
                        isContractTrackingError = true;
                        contractTrackingErrorMessagesList.add(Label.CFAR_GSTARS_AMENDMENT_NUMBER_NUMERIC);
                }
                else if (CFAR_Utils.invalidNegativeNumber(currentContractTracking.Amendment_Number_gne__c)) {
                        isContractTrackingError = true;
                        contractTrackingErrorMessagesList.add(Label.CFAR_GSTARS_AMENDMENT_NUMBER_NEGATIVE);
                }
        }
        
        if (!getHasCancelled() && (currentContractTracking.Type_ref_gne__c != null && !getHasPlanning() && currentContractTracking.Fully_Executed_Date_gne__c != null
                        && currentContractTracking.Fully_Executed_Date_gne__c > Date.today())) {
                isContractTrackingError = true;
                contractTrackingErrorMessagesList.add(Label.CFAR_GSTARS_FULLY_EXECUTED_DATE_FUTURE);
        }

        if (currentContractTracking.Fully_Executed_Date_gne__c == null && currentContractTracking.Type_ref_gne__r.Name != 'Planned' && currentContractTracking.Type_ref_gne__r.Name != 'Contract Cancelled') {
                isContractTrackingError = true;
                contractTrackingErrorMessagesList.add(Label.CFAR_GSTARS_FULLY_EXECUTED_DATE_REQUIRED);
        }
        
        if (currentContractTracking.Contract_Expiry_Date_gne__c == null && currentContractTracking.Type_ref_gne__r.Name != 'Planned' && currentContractTracking.Type_ref_gne__r.Name != 'Contract Cancelled') {
                isContractTrackingError = true;
                contractTrackingErrorMessagesList.add(Label.CFAR_GSTARS_CONTRACT_EXPIRY_DATE_REQUIRED);
        }
        
        if (currentContractTracking.Fully_Executed_Date_gne__c != null && currentContractTracking.Contract_Expiry_Date_gne__c != null && currentContractTracking.Contract_Expiry_Date_gne__c <= currentContractTracking.Fully_Executed_Date_gne__c) {
                isContractTrackingError = true;
                contractTrackingErrorMessagesList.add(Label.CFAR_GSTARS_CONTRACT_EXPIRY_AFTER_FULLY_EXECUTED);
        }
        
        if (isContractTrackingError) {
                return null;
        }

        if (selectedInvestigatorsBudgetContractId == null) {
            selectedInvestigatorsBudgetContractId = createNewBudgetContract();
        }

        if(currentContractTracking.Budget_Contract_ref_gne__c == null)
            currentContractTracking.Budget_Contract_ref_gne__c = selectedInvestigatorsBudgetContractId;

        ApexPages.StandardController ctrl = new ApexPages.StandardController(currentContractTracking);
        PageReference pr = ctrl.save();
        isContractTrackingError = pr == null && ApexPages.hasMessages();
        if(isContractTrackingError) {
            logContractTrackingMessage();
        } else {
            refreshTrial();
            getContractTrackings();
            investigatorSelected();
                if (currentContractTracking.Type_ref_gne__r.Name == Label.CFAR_GSTARS_CONTRACT_TRACKING_ORGINAL_TYPE) {                 
                        CFAR_Utils.setRDCCriteria(trial, null);
                        refreshTrial();
                }
            return null;
        }
        recalculateMostRecentContract();
        return null;
    }
    
    public void cancelCreateContractTracking() {
        addEditContractTracking = false;
        resetError();
        resetContractTrackingError();
    }
    
    public void editContractTracking() {
        resetError();
        resetContractTrackingError();
        currentContractTracking = [select Id, Name, Amount_gne__c, Contract_Requested_Date__c, Comments_gne__c, Contract_Expiry_Date_gne__c,
                Contract_ID_gne__c, Fully_Executed_Date_gne__c, Type_ref_gne__c, Type_ref_gne__r.Name, Variance_gne__c, frm_sfdc_Completed_gne__c, Frm_Trial_Id_gne__c, Amendment_Number_gne__c,
                Budget_Contract_ref_gne__c
                    from CFAR_Budget_Contract_Tracking_gne__c where Id = :contractTrackingId];
        addEditContractTracking = true;
    }
    
    private void resetContractTrackingError() {
        contractTrackingErrorMessagesList = new List<String>();
        isContractTrackingError = false;
    }
    

    public List<String> getContractTrackingErrors() {
        return contractTrackingErrorMessagesList;
    }
    
    private void logContractTrackingMessage() {
        for(ApexPages.Message m : ApexPages.getMessages()) {
            contractTrackingErrorMessagesList.add(m.getDetail());
        }
    }
    
    public List<SelectOption> getPaymentInvestigatorsOptions() {
        List<SelectOption> options = new List<SelectOption>();
        List<CFAR_Team_Member_gne__c> investigators = [select Id, Dollar_and_Drug_ref_gne__c, frm_Name_gne__c, frm_Is_Inactive_gne__c from CFAR_Team_Member_gne__c where CFAR_Trial_ref_gne__c = :trial.Id and frm_Function_Role_gne__c IN ('PI = Primary (or Principal) Investigator', 'Sub-I = Sub-investigator') order by frm_Name_gne__c, frm_Is_Inactive_gne__c];
        for (CFAR_Team_Member_gne__c member : investigators) {
                if (member.frm_Is_Inactive_gne__c == false || currentPaymentSchedule.Budget_Contract_ref_gne__r.Team_Member_ref_gne__c == member.Id) {
                        options.add(new SelectOption(member.Id, member.frm_Name_gne__c));
                }
        }
        return options;
    }
    
    public List<SelectOption> getRTInvestigatorsOptions() {
        List<SelectOption> options = new List<SelectOption>();
        List<CFAR_Team_Member_gne__c> investigators = [select Id, Dollar_and_Drug_ref_gne__c, frm_Name_gne__c, frm_Is_Inactive_gne__c from CFAR_Team_Member_gne__c where CFAR_Trial_ref_gne__c = :trial.Id and frm_Function_Role_gne__c IN ('PI = Primary (or Principal) Investigator', 'Sub-I = Sub-investigator') order by frm_Name_gne__c, frm_Is_Inactive_gne__c];
        for (CFAR_Team_Member_gne__c member : investigators) {
                if (member.frm_Is_Inactive_gne__c == false || currentRateTable.Budget_Contract_ref_gne__r.Team_Member_ref_gne__c == member.Id) {
                        options.add(new SelectOption(member.Id, member.frm_Name_gne__c));
                }
        }
        return options;
    }  
    
    public List<SelectOption> getInvestigatorsOptionsReport() {
        List<SelectOption> options = new List<SelectOption>();
        List<CFAR_Team_Member_gne__c> investigators = [select Id,Dollar_and_Drug_ref_gne__c, frm_Name_gne__c, frm_Is_Inactive_gne__c from CFAR_Team_Member_gne__c where CFAR_Trial_ref_gne__c = :trial.Id and frm_Function_Role_gne__c IN ('PI = Primary (or Principal) Investigator', 'Sub-I = Sub-investigator') order by frm_Name_gne__c, frm_Is_Inactive_gne__c];
        if(investigators != null && !investigators.isEmpty())
                options.add(new SelectOption('All Investigators', 'All Investigators'));
        for (CFAR_Team_Member_gne__c member : investigators) {
                if (member.frm_Is_Inactive_gne__c == false) {
                        options.add(new SelectOption(member.Id, member.frm_Name_gne__c));
                }
        }
        return options;
    } 
    
    public SelectOption[] getWBSes() {
        CFAR_SearchParameters searchParameters = new CFAR_SearchParameters();
        searchParameters.andEqualsParameters.put('Active_gne__c','true');
        return CFAR_Utils.getWBSSelectOptions(searchParameters);
    }
    
    public List<SelectOption> getCostCenters() {
        List<SelectOption> costCenters = new List<SelectOption>();
        for (CFAR_Cost_Center__c n : [SELECT Name, Id FROM CFAR_Cost_Center__c WHERE ID NOT IN (SELECT Cost_Center__c FROM Cost_Center_for_Trial__c WHERE gStars_Trial__c = :trial.Id) AND Active_gne__c = true]) {
            costCenters.add(new SelectOption(n.Id, n.Name));
        }
        return costCenters;
    }

    public List<Cost_Center_for_Trial__c> getCostCentersForTrial() {
        return [SELECT Cost_Center__c, Value__c FROM Cost_Center_for_Trial__c WHERE gStars_Trial__c = :trial.Id];
    }

    public void insertCostCenters() {
        resetError();
        resetCCError();
        List<Cost_Center_for_Trial__c> ccToInsert = new List<Cost_Center_for_Trial__c>();
        for (CostCenterWrapper cc : ccWrapper) {
            ccToInsert.add(new Cost_Center_for_Trial__c(
                Value__c = cc.record.Value__c,
                Cost_Center__c = cc.record.Cost_Center__c,
                gStars_Trial__c = trial.Id
            ));
        }
        editCC = false;
        if (validateCostCenters(ccToInsert) && (costCentersForTrial.size() + ccToInsert.size() <= 5)) {
            insert ccToInsert;
        } else {
            isCCError = true;
            if (costCentersForTrial.size() + ccToInsert.size() >= 5) {
                ccErrorMessages.add('User can add up to 5 Cost Centers.');
            }
        }
        refreshTrial();
    }

    public Boolean validateCostCenters(List<Cost_Center_for_Trial__c> ccToInsert) {
        Decimal value = 0;
        List<Cost_Center_for_Trial__c> currentValues = [SELECT Cost_Center__c, Value__c FROM Cost_Center_for_Trial__c WHERE gStars_Trial__c = :trial.Id];
        if (currentValues != null) {
            for (Cost_Center_for_Trial__c cV : currentValues) {
                value = value + cV.Value__c;
            }
        }

        for (Cost_Center_for_Trial__c c : ccToInsert) {
            value = value + c.Value__c;
        }

        List<ID> ccIds = new List<String>();
        for (Cost_Center_for_Trial__c c : ccToInsert) {
            if (ccIds.contains(c.Cost_Center__c)) {
                isCCError = true;
                ccErrorMessages.add('Cost Center Names should be unique.');
            }
            ccIds.add(c.Cost_Center__c);
        }
        for (Cost_Center_for_Trial__c c : currentValues) {
            if (ccIds.contains(c.Cost_Center__c)) {
                isCCError = true;
                ccErrorMessages.add('Cost Center Names should be unique.');
            }
            ccIds.add(c.Cost_Center__c);
        }

        if (value <= 100.00 && !isCCError) {
            return true;
        } else {
            ccErrorMessages.add('The Total Cost Center value should not exceed 100%.');
            return false;
        }
    }
    public Boolean getWBSUnsetOrRequested() {
        return String.isBlank(trial.CFAR_WBS_ref_gne__c) || trial.CFAR_WBS_ref_gne__c == WBSRequstedID;
    }

    private void resetPaymentError() {
        paymentErrorMessagesList = new Set<String>();
        isPaymentError = false;
    }
    
    private void resetRTError() {
        rtErrorMessagesList = new Set<String>();
        isRateTableError = false;
    }

    private void resetCCError() {
        ccErrorMessages = new Set<String>();
        isCCError = false;
    }
    
    private void resetCCEditError() {
        ccEditErrorMessages = new Set<String>();
        isCCEditError = false;
    }
    public SelectOption[] getPaymentScheduleStatuses() {
        if(originalPaymentStatus==null) originalPaymentStatus='';
        CFAR_SearchParameters searchParameters = new CFAR_SearchParameters();
        searchParameters.andEqualsParameters.put('Active_gne__c','true');
        SelectOption[] allStatusesWrongOrder = CFAR_Utils.getPaymentScheduleStatusSelectOptions(searchParameters);
        SelectOption[] allStatuses = new List<SelectOption>();
        Integer i = 0;
        Boolean add;
        Map<String,SelectOption> allStatusesWrongOrderMap = new Map<String,SelectOption>();
        for (SelectOption so : allStatusesWrongOrder) {
                allStatusesWrongOrderMap.put(so.getLabel(), so);
        }
        if (allStatusesWrongOrderMap.containsKey(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PLANNED_STATUS)) {
                allStatuses.add(allStatusesWrongOrderMap.get(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PLANNED_STATUS));
                allStatusesWrongOrderMap.remove(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PLANNED_STATUS);
        }
        if (allStatusesWrongOrderMap.containsKey(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_DUE_NO_INVOICE_SUBMITTED_STATUS)) {
                allStatuses.add(allStatusesWrongOrderMap.get(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_DUE_NO_INVOICE_SUBMITTED_STATUS));
                allStatusesWrongOrderMap.remove(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_DUE_NO_INVOICE_SUBMITTED_STATUS);
        }
        if (allStatusesWrongOrderMap.containsKey(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_SUBMITTED_STATUS)) {
                allStatuses.add(allStatusesWrongOrderMap.get(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_SUBMITTED_STATUS));
                allStatusesWrongOrderMap.remove(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_SUBMITTED_STATUS);
        }
        if (allStatusesWrongOrderMap.containsKey(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PAID_STATUS)) {
                allStatuses.add(allStatusesWrongOrderMap.get(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PAID_STATUS));
                allStatusesWrongOrderMap.remove(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PAID_STATUS);
        }
        if (allStatusesWrongOrderMap.containsKey(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_UNPAID_STATUS)) {
                allStatuses.add(allStatusesWrongOrderMap.get(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_UNPAID_STATUS));
                allStatusesWrongOrderMap.remove(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_UNPAID_STATUS);
        }
        if (allStatusesWrongOrderMap.containsKey(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_REFUND_STATUS)) {
                allStatuses.add(allStatusesWrongOrderMap.get(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_REFUND_STATUS));
                allStatusesWrongOrderMap.remove(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_REFUND_STATUS);
        }
        //previous logic removed other statuses (e.g. added by users) from the list, but let's leave it on allStatuses list
        //let's take remaining statuses in alphabetical order
        List<String> remainingStatuses = new List<String>(allStatusesWrongOrderMap.keySet());
        remainingStatuses.sort();
        for (String status : remainingStatuses) {
                allStatuses.add(allStatusesWrongOrderMap.get(status));
        }
        SelectOption[] statuses = new List<SelectOption>();
        if(currentPaymentSchedule.Payment_Explanation_Text_gne__c!=null && currentPaymentSchedule.Payment_Explanation_Text_gne__c.equals(Label.CFAR_GSTARS_PAYMENT_EXPLANATION_STATUS)){
            for(SelectOption pss : allStatuses){
                if(!pss.getLabel().equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PLANNED_STATUS) && !pss.getLabel().equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_UNPAID_STATUS)) continue;
                else if((pss.getLabel().equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_UNPAID_STATUS) && originalPaymentStatus==Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PLANNED_STATUS) 
                        || pss.getLabel().equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PLANNED_STATUS)
                        || (originalPaymentStatus.equals(pss.getLabel()) && pss.getLabel().equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_UNPAID_STATUS))){
                    statuses.add(pss);
                }
            }
        } else {
            for(SelectOption pss : allStatuses){
                if(!originalPaymentStatus.equals(pss.getLabel())) {
                    if (CFAR_Budget_Controller.UNAVAILABLE_PAYMENT_STATUSES.containsKey(pss.getLabel())
                            && CFAR_Budget_Controller.UNAVAILABLE_PAYMENT_STATUSES.get(pss.getLabel()).contains(originalPaymentStatus)) {
                        continue;
                    }
                }
                statuses.add(pss);
            }
        }
        return statuses;
    }
    
    /*
     * Map declares payment statuses which shouldn't be available to choose, if current status is contained in the set
     * key: status which is unavailable in the drop down list
     * value: set of status for which the status isn't available
     */
    private static Map<String, Set<String>> UNAVAILABLE_PAYMENT_STATUSES = new Map<String, Set<String>>
            {Label.CFAR_GSTARS_PAYMENT_SCHEDULE_UNPAID_STATUS => new Set<String> {
                    Label.CFAR_GSTARS_PAYMENT_SCHEDULE_REFUND_STATUS,
                    Label.CFAR_GSTARS_PAYMENT_SCHEDULE_SUBMITTED_STATUS}};
    
    //PROJECTION
    public PageReference submitProjection() {   
        ApexPages.StandardController ctrl = new ApexPages.StandardController(currentProjection);
        PageReference pr = ctrl.save();
        isError = pr == null && ApexPages.hasMessages();
        if(isError) {
            logMessage();
        } else {
            refreshTrial();
            getProjections();
            return null;
        }
        return null;
     }
     
     public void cancelEditProjection() {
        addEditProjection = false;
        resetError();
    }
    
    public void editProjection() {
        resetError();
        currentProjection = [select Id, Name, Quarter_1_gne__c,Quarter_2_gne__c,Quarter_3_gne__c,Quarter_4_gne__c,
                        frm_Total_Amount_gne__c,Total_Paid_gne__c,frm_Total_Remaining_Forecast_gne__c,Year_gne__c,Comments_gne__c, CFAR_Trial_ref_gne__c 
                        from CFAR_Budget_CPS_Projection_gne__c where Id = :projectionId];
        addEditProjection = true;
    }
    
    //PAYMENT SCHEDULE
    
    public CFAR_Rate_Table_gne__c setRateTableId() {
        if(currentPaymentSchedule == null || String.isBlank(currentPaymentSchedule.Payment_Explanation_Text_gne__c)) 
                return null;
        
        String pExp = currentPaymentSchedule.Payment_Explanation_Text_gne__c;
        List<CFAR_Rate_Table_gne__c> rates = [SELECT Remaining_Balance_gne__c, Remaining_Units_gne__c, Id, Contract_Term_gne__c, Net_Unit_Cost_gne__c,
                Total_Amount_gne__c, Cost_gne__c, Unit_gne__c, Withhold_Type_gne__c, Remaining_Withholding_Units_gne__c, Withhold_Value_gne__c
                FROM CFAR_Rate_Table_gne__c where Budget_Contract_ref_gne__c = :selectedInvestigatorsBudgetContractId and Contract_Term_gne__c = :pExp and Status_gne__c = 'Active' limit 1];
        if(rates != null && !rates.isEmpty())
                return rates.get(0);
        
        return null;
    }
    
    public void assignInvestigatorAndSetWithholdRelatedFields() {
        if(currentPaymentSchedule != null && String.isNotBlank(currentPaymentSchedule.Payment_Explanation_Text_gne__c) && currentPaymentSchedule.Payment_Explanation_Text_gne__c != Label.CFAR_GSTARS_PAYMENT_EXPLANATION_STATUS) {
        
                String pExp = currentPaymentSchedule.Payment_Explanation_Text_gne__c;
                List<CFAR_Rate_Table_gne__c> rates = [SELECT Id, Contract_Term_gne__c, Budget_Contract_ref_gne__r.Team_Member_ref_gne__c, PI_Sub_I_Name_gne__c, Withhold_Type_gne__c
                    FROM CFAR_Rate_Table_gne__c
                    where Budget_Contract_ref_gne__c =: selectedInvestigatorsBudgetContractId and Contract_Term_gne__c =:pExp  and Status_gne__c = 'Active' limit 1];
                        if(rates.size() > 0) {
                                currentPaymentSchedule.Rate_Table_ref_gne__c = rates.get(0).Id;
                                currentPaymentSchedule.Rate_Table_ref_gne__r = rates.get(0);
                                hasWithhold = (!String.isBlank(rates.get(0).Withhold_Type_gne__c)) ? true : false;
                        }
        }
        if (currentPaymentSchedule != null && (paymentScheduleFrozen || String.isBlank(currentPaymentSchedule.Payment_Explanation_Text_gne__c)) || '--None--'.equals(currentPaymentSchedule.Payment_Explanation_Text_gne__c) || currentPaymentSchedule.Payment_Explanation_Text_gne__c == Label.CFAR_GSTARS_PAYMENT_EXPLANATION_STATUS || !hasWithhold) {
                currentPaymentSchedule.Withhold_Indicator_gne__c = 'No';
        }
    }

    public Set<String> getPaymentErrors() {
        return paymentErrorMessagesList;
    }
    
    public Set<String> getRTErrors() {
        return rtErrorMessagesList;
    }

    public Set<String> getCCErrors() {
        return ccErrorMessages;
    }
    
    public Set<String> getCCEditErrors() {
        return ccEditErrorMessages;
    }
    
    public Set<String> getContractAssignmentErrors(){
        return contractAssignmentErrorList;
    }

    private void logPaymentMessage() {
        for(ApexPages.Message m : ApexPages.getMessages()) {
            paymentErrorMessagesList.add(m.getDetail());
        }
    }
    public void createNewPaymentSchedule() {
        resetError();
        resetPaymentError();
        CFAR_Team_Member_gne__c pi = CFAR_Utils.getPrimaryInvestigatorForTrial(trial.Id);

        currentPaymentSchedule = new CFAR_Budget_CPS_Payments_gne__c();
        selectedInvestigator = currentPaymentSchedule.frm_Investigator_ref_gne__c;
        paymentScheduleFrozen = false;
        addEditPaymentSchedule = true;
        originalPaymentStatus='';
        currentPaymentSchedule.Withhold_Indicator_gne__c = 'No';
        initialWithholdIndicator = 'No';
        initialRT = null;
        hasWithhold = false;
        initialInvoiceAmount = 0;
    }
    
    public PageReference submitPaymentSchedule() {
        resetPaymentError();
                
        // store a negative invoice refund value for proper contract calculations
        fixRefundPaymentForStore();
                CFAR_Rate_Table_gne__c rateTableAssigned = setRateTableId();
        currentPaymentSchedule.Rate_Table_ref_gne__c = rateTableAssigned != null ? rateTableAssigned.Id : null;
        
        if(currentPaymentSchedule.Paid_On_gne__c==null && currentPaymentSchedule.Payment_Status_ref_gne__r != null && currentPaymentSchedule.Payment_Status_ref_gne__r.Name.equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PAID_STATUS)){
            paymentErrorMessagesList.add(Label.CFAR_GSTARS_PAID_ON_DATE_REQUIRED);
            isPaymentError=true;
        }
        if(currentPaymentSchedule.Planned_Date_gne__c==null && currentPaymentSchedule.Payment_Status_ref_gne__r != null && (currentPaymentSchedule.Payment_Status_ref_gne__r.Name.equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PLANNED_STATUS) 
                || currentPaymentSchedule.Payment_Status_ref_gne__r.Name.equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_UNPAID_STATUS))){
            paymentErrorMessagesList.add(Label.CFAR_GSTARS_PAYMENT_PLANNED_DATE_REQUIRED);
            isPaymentError=true;
        }
        if(currentPaymentSchedule.Planned_Amount_gne__c==null && currentPaymentSchedule.Payment_Status_ref_gne__r != null && (currentPaymentSchedule.Payment_Status_ref_gne__r.Name.equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PLANNED_STATUS) 
                || currentPaymentSchedule.Payment_Status_ref_gne__r.Name.equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_UNPAID_STATUS))){
            paymentErrorMessagesList.add(Label.CFAR_GSTARS_PLANNED_AMOUNT_REQUIRED);
            isPaymentError=true;
        }
        if(currentPaymentSchedule.Payment_Status_ref_gne__r != null && (currentPaymentSchedule.Payment_Status_ref_gne__r.Name.equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_DUE_NO_INVOICE_SUBMITTED_STATUS) 
                || currentPaymentSchedule.Payment_Status_ref_gne__r.Name.equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_SUBMITTED_STATUS)
                || currentPaymentSchedule.Payment_Status_ref_gne__r.Name.equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PAID_STATUS)
                || currentPaymentSchedule.Payment_Status_ref_gne__r.Name.equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_REFUND_STATUS))) {
                if(currentPaymentSchedule.Invoice_Submitted_Date_gne__c==null){
                    paymentErrorMessagesList.add(Label.CFAR_GSTARS_INVOICE_SUBMITTED_DATE_REQUIRED);
                    isPaymentError=true;
                } else {
                         if(rateTableAssigned != null && currentPaymentSchedule.Invoice_Amount_gne__c != null && currentPaymentSchedule.Payment_Explanation_Text_gne__c != Label.CFAR_GSTARS_PAYMENT_EXPLANATION_STATUS){
                                        CFAR_Budget_CPS_Payments_gne__c previousPaymentSchedule;
                                        if(String.isNotBlank(currentPaymentSchedule.Id)) {
                                                List<CFAR_Budget_CPS_Payments_gne__c> schedules = [Select Id, Name, txt_Payment_Status__c, Invoice_Submitted_Date_gne__c, Invoice_Amount_gne__c, Planned_Amount_gne__c, Planned_Date_gne__c, 
                                                                                                                                                        Payment_Explanation_Text_gne__c from CFAR_Budget_CPS_Payments_gne__c where Id = :currentPaymentSchedule.Id];
                                        previousPaymentSchedule = schedules.size() > 0 ? schedules.get(0) : null;
                                        }
                                    Decimal remainingBalance = rateTableAssigned.Remaining_Balance_gne__c != null ? rateTableAssigned.Remaining_Balance_gne__c : 0;
                                        Decimal remainingUnits = rateTableAssigned.Remaining_Units_gne__c != null ? rateTableAssigned.Remaining_Units_gne__c : 0;
                                        Decimal netUnitCost = rateTableAssigned.Net_Unit_Cost_gne__c != null ? rateTableAssigned.Net_Unit_Cost_gne__c : 0;
                                        if(previousPaymentSchedule != null && previousPaymentSchedule.Invoice_Submitted_Date_gne__c != null  && previousPaymentSchedule.Invoice_Amount_gne__c != null && previousPaymentSchedule.txt_Payment_Status__c != null 
                                                && (previousPaymentSchedule.txt_Payment_Status__c.equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_DUE_NO_INVOICE_SUBMITTED_STATUS) || previousPaymentSchedule.txt_Payment_Status__c.equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_SUBMITTED_STATUS)
                                        || previousPaymentSchedule.txt_Payment_Status__c.equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PAID_STATUS) || previousPaymentSchedule.txt_Payment_Status__c.equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_REFUND_STATUS)) 
                                        && previousPaymentSchedule.Payment_Explanation_Text_gne__c == currentPaymentSchedule.Payment_Explanation_Text_gne__c) {
                                                
                                        remainingBalance = remainingBalance + previousPaymentSchedule.Invoice_Amount_gne__c - currentPaymentSchedule.Invoice_Amount_gne__c;
                                        if(netUnitCost != 0)
                                                remainingUnits = remainingUnits - (currentPaymentSchedule.Invoice_Amount_gne__c - previousPaymentSchedule.Invoice_Amount_gne__c)/netUnitCost;
                                } else {
                                        remainingBalance = remainingBalance - currentPaymentSchedule.Invoice_Amount_gne__c;
                                        if(netUnitCost != 0)
                                                remainingUnits = remainingUnits - currentPaymentSchedule.Invoice_Amount_gne__c/netUnitCost;
                                }
                                
                                if(remainingBalance < 0) {
                                            paymentErrorMessagesList.add(Label.CFAR_GSTARS_REMAINING_BALANCE_BELOW_ZERO);
                                            isPaymentError=true;                        
                                }
                
                                if(remainingBalance > rateTableAssigned.Total_Amount_gne__c) {
                                            paymentErrorMessagesList.add(Label.CFAR_GSTARS_REMAINING_BALANCE_GREATER_THAN_TOTAL_AMOUNT);
                                            isPaymentError=true;
                                }
                                        if(rateTableAssigned.Net_Unit_Cost_gne__c != null && rateTableAssigned.Net_Unit_Cost_gne__c != 0 && currentPaymentSchedule.Withhold_Indicator_gne__c != 'Yes') {
                                                Decimal div = currentPaymentSchedule.Invoice_Amount_gne__c/rateTableAssigned.Net_Unit_Cost_gne__c;
                                                if(div - Math.round(div) != 0) {
                                                paymentErrorMessagesList.add(Label.CFAR_GSTARS_PAID_UNITS_NOT_MULTIPLIER_OF_NET_UNIT_COST);
                                                isPaymentError=true;
                                                }
                                        }
                                }
                }
        }

        if(currentPaymentSchedule.Invoice_Amount_gne__c==null && currentPaymentSchedule.Payment_Status_ref_gne__r != null && (currentPaymentSchedule.Payment_Status_ref_gne__r.Name.equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_DUE_NO_INVOICE_SUBMITTED_STATUS) 
                || currentPaymentSchedule.Payment_Status_ref_gne__r.Name.equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_SUBMITTED_STATUS)
                || currentPaymentSchedule.Payment_Status_ref_gne__r.Name.equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PAID_STATUS)
                || currentPaymentSchedule.Payment_Status_ref_gne__r.Name.equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_REFUND_STATUS))){
            paymentErrorMessagesList.add(Label.CFAR_GSTARS_INVOICE_AMOUNT_REQUIRED);
            isPaymentError=true;
        }
        if(currentPaymentSchedule.Invoice_Date_gne__c==null  && currentPaymentSchedule.Payment_Status_ref_gne__r != null && (currentPaymentSchedule.Payment_Status_ref_gne__r.Name.equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_SUBMITTED_STATUS)
                || currentPaymentSchedule.Payment_Status_ref_gne__r.Name.equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PAID_STATUS))){
            paymentErrorMessagesList.add(Label.CFAR_GSTARS_INVOICE_DATE_REQUIRED);
            isPaymentError=true;
        }
        if(currentPaymentSchedule.Payment_Explanation_Text_gne__c==null || currentPaymentSchedule.Payment_Explanation_Text_gne__c.equals('--None--')){
            paymentErrorMessagesList.add(Label.CFAR_GSTARS_PAYMENT_EXPLANATION_REQUIRED);
            isPaymentError=true;
        }
        if(currentPaymentSchedule.Payment_Status_ref_gne__c==null || currentPaymentSchedule.Payment_Status_ref_gne__r.Name.equals('--None--')){
            paymentErrorMessagesList.add(Label.CFAR_GSTARS_PAYMENT_STATUS_REQUIRED);
            isPaymentError=true;
        }
        if((currentPaymentSchedule.Invoice_gne__c==null || currentPaymentSchedule.Invoice_gne__c.equals('')) && currentPaymentSchedule.Payment_Status_ref_gne__r != null 
            && (currentPaymentSchedule.Payment_Status_ref_gne__r.Name.equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_SUBMITTED_STATUS) || currentPaymentSchedule.Payment_Status_ref_gne__r.Name.equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PAID_STATUS))){
            paymentErrorMessagesList.add(Label.CFAR_GSTARS_INVOICE_NUMBER_REQUIRED);
            isPaymentError=true;
        }
        if((currentPaymentSchedule.Check_Num_gne__c==null || currentPaymentSchedule.Check_Num_gne__c.equals('')) && currentPaymentSchedule.Payment_Status_ref_gne__r != null && currentPaymentSchedule.Payment_Status_ref_gne__r.Name.equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PAID_STATUS)){
            paymentErrorMessagesList.add(Label.CFAR_GSTARS_CHECK_NUMBER_REQUIRED);
            isPaymentError=true;
        }
        if((currentPaymentSchedule.Comments_gne__c==null || currentPaymentSchedule.Comments_gne__c.equals('')) && currentPaymentSchedule.Payment_Status_ref_gne__r != null && currentPaymentSchedule.Payment_Status_ref_gne__r.Name.equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_REFUND_STATUS)){
            paymentErrorMessagesList.add(Label.CFAR_GSTARS_COMMENTS_REQUIRED);
            isPaymentError=true;
        }
        if(currentPaymentSchedule.Invoice_Date_gne__c != null && selectedInvestigatorContract.Contract_End_Date_gne__c != null && currentPaymentSchedule.Invoice_Date_gne__c > selectedInvestigatorContract.Contract_End_Date_gne__c){
            paymentErrorMessagesList.add(Label.CFAR_GSTARS_INVOICE_DATE_AFTER_CONTRACT_EXPIRY_DATE);
            isPaymentError=true;
        }
        if(currentPaymentSchedule.Planned_Date_gne__c != null && selectedInvestigatorContract.Contract_End_Date_gne__c != null && currentPaymentSchedule.Planned_Date_gne__c > selectedInvestigatorContract.Contract_End_Date_gne__c){
            paymentErrorMessagesList.add(Label.CFAR_GSTARS_PLANNED_DATE_AFTER_CONTRACT_EXPIRY_DATE);
            isPaymentError=true;
        }
        if(currentPaymentSchedule.Invoice_Submitted_Date_gne__c != null && selectedInvestigatorContract.Contract_End_Date_gne__c != null && currentPaymentSchedule.Invoice_Submitted_Date_gne__c > selectedInvestigatorContract.Contract_End_Date_gne__c
            && currentPaymentSchedule.Payment_Status_ref_gne__r != null && (currentPaymentSchedule.Payment_Status_ref_gne__r.Name.equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_DUE_NO_INVOICE_SUBMITTED_STATUS) 
            || currentPaymentSchedule.Payment_Status_ref_gne__r.Name.equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_SUBMITTED_STATUS)
            || currentPaymentSchedule.Payment_Status_ref_gne__r.Name.equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PAID_STATUS))){
            paymentErrorMessagesList.add(Label.CFAR_GSTARS_INVOICE_SUBMITTED_DATE_AFTER_CONTRACT_EXPIRY_DATE);
            isPaymentError=true;
        }
        if(currentPaymentSchedule.Planned_Date_gne__c!=null && currentPaymentSchedule.Planned_Date_gne__c < Date.today() && currentPaymentSchedule.Payment_Status_ref_gne__r != null
                && (currentPaymentSchedule.Payment_Status_ref_gne__r.Name.equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PLANNED_STATUS) || currentPaymentSchedule.Payment_Status_ref_gne__r.Name.equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_UNPAID_STATUS))){
            paymentErrorMessagesList.add(Label.CFAR_GSTARS_PLANNED_DATE_IS_A_PAST_DATE);
            isPaymentError=true;
        }
        if(currentPaymentSchedule.Invoice_Submitted_Date_gne__c!=null && currentPaymentSchedule.Invoice_Submitted_Date_gne__c > Date.today()){
            paymentErrorMessagesList.add(Label.CFAR_GSTARS_INVOICE_SUBMITTED_DATE_IS_A_FUTURE_DATE);
            isPaymentError=true;
        }
        if(currentPaymentSchedule.Paid_On_gne__c!=null && currentPaymentSchedule.Paid_On_gne__c > Date.today()){
            paymentErrorMessagesList.add(Label.CFAR_GSTARS_PAID_ON_DATE_IS_A_FUTURE_DATE);
            isPaymentError=true;
        }
        if(currentPaymentSchedule.Invoice_Date_gne__c!=null && currentPaymentSchedule.Invoice_Date_gne__c > Date.today()){
            paymentErrorMessagesList.add(Label.CFAR_GSTARS_INVOICE_DATE_IS_A_FUTURE_DATE);
            isPaymentError=true;
        }
        if(currentPaymentSchedule.Invoice_Date_gne__c!=null && selectedInvestigatorContract.Original_Contract_Execution_Date_gne__c != null && currentPaymentSchedule.Invoice_Date_gne__c < selectedInvestigatorContract.Original_Contract_Execution_Date_gne__c){
            paymentErrorMessagesList.add(Label.CFAR_GSTARS_INVOICE_DATE_PRIOR_FULLY_EXECUTED_DATE);
            isPaymentError=true;
        }
        if(currentPaymentSchedule.Invoice_Submitted_Date_gne__c!=null && selectedInvestigatorContract.Original_Contract_Execution_Date_gne__c != null && currentPaymentSchedule.Invoice_Submitted_Date_gne__c < selectedInvestigatorContract.Original_Contract_Execution_Date_gne__c
            && currentPaymentSchedule.Payment_Status_ref_gne__r != null && (currentPaymentSchedule.Payment_Status_ref_gne__r.Name.equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_DUE_NO_INVOICE_SUBMITTED_STATUS) 
            || currentPaymentSchedule.Payment_Status_ref_gne__r.Name.equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_SUBMITTED_STATUS)
            || currentPaymentSchedule.Payment_Status_ref_gne__r.Name.equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PAID_STATUS))){
            paymentErrorMessagesList.add(Label.CFAR_GSTARS_INVOICE_SUBMITTED_DATE_PRIOR_FULLY_EXECUTED_DATE);
            isPaymentError=true;
        }
        if(currentPaymentSchedule.Planned_Date_gne__c!=null && selectedInvestigatorContract.Original_Contract_Execution_Date_gne__c != null && currentPaymentSchedule.Planned_Date_gne__c < selectedInvestigatorContract.Original_Contract_Execution_Date_gne__c){
            paymentErrorMessagesList.add(Label.CFAR_GSTARS_PLANNED_DATE_PRIOR_FULLY_EXECUTED_DATE);
            isPaymentError=true;
        }
        if(currentPaymentSchedule.Invoice_Submitted_Date_gne__c!=null && currentPaymentSchedule.Invoice_Submitted_Date_gne__c.year() != Date.today().year()
            && currentPaymentSchedule.Payment_Status_ref_gne__r != null && (currentPaymentSchedule.Payment_Status_ref_gne__r.Name.equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_REFUND_STATUS))){
            paymentErrorMessagesList.add(Label.CFAR_GSTARS_INVOICE_SUBMITTED_DATE_WITHIN_CURRENT_YEAR);
            isPaymentError=true;
        }
        if(currentPaymentSchedule.Planned_Amount_gne__c != null && currentPaymentSchedule.Planned_Amount_gne__c <= 0){
            paymentErrorMessagesList.add(Label.CFAR_GSTARS_PLANNED_AMOUNT_GREATER_THAN_ZERO);
            isPaymentError=true;
        }
        if(currentPaymentSchedule.Planned_Amount_gne__c != null && currentPaymentSchedule.Planned_Amount_gne__c > selectedInvestigatorContract.Amount_Left_to_Project_gne__c + originalPaymentPlannedAmount){
            paymentErrorMessagesList.add(Label.CFAR_GSTARS_PLANNED_AMOUNT_GREATER_AMOUNT_LEFT_TO_PROJECT);
            isPaymentError=true;
        }
        if(currentPaymentSchedule.Payment_Status_ref_gne__r != null && currentPaymentSchedule.Payment_Status_ref_gne__r.Name.equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_REFUND_STATUS)){
            List<String> statuses = new List<String>();
            statuses.add(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PAID_STATUS);
            statuses.add(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_SUBMITTED_STATUS);
            statuses.add(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_DUE_NO_INVOICE_SUBMITTED_STATUS);
            List<CFAR_Budget_CPS_Payments_gne__c> budgetPayments = new List<CFAR_Budget_CPS_Payments_gne__c>(
                [Select Id,Payment_Explanation_Text_gne__c From CFAR_Budget_CPS_Payments_gne__c
                Where Payment_Status_ref_gne__r.Name in :statuses and Budget_Contract_ref_gne__c = :selectedInvestigatorsBudgetContractId]);
            Boolean paymentExplanationFound = false;
            if(budgetPayments!=null && !budgetPayments.isEmpty()){
                for(CFAR_Budget_CPS_Payments_gne__c bp : budgetPayments){
                    if(bp.Payment_Explanation_Text_gne__c!=null && currentPaymentSchedule.Payment_Explanation_Text_gne__c!=null && bp.Payment_Explanation_Text_gne__c.equals(currentPaymentSchedule.Payment_Explanation_Text_gne__c)) 
                        paymentExplanationFound = true;
                }
            }
            if(!paymentExplanationFound){
                paymentErrorMessagesList.add(Label.CFAR_GSTARS_PAID_INVOICE_MISSING);
                isPaymentError=true;
            } 
        }
        
        if(currentPaymentSchedule.Invoice_Submitted_Date_gne__c!=null && currentPaymentSchedule.Planned_Date_gne__c == null && currentPaymentSchedule.Payment_Status_ref_gne__r != null 
                && (currentPaymentSchedule.Payment_Status_ref_gne__r.Name.equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_DUE_NO_INVOICE_SUBMITTED_STATUS) 
            || currentPaymentSchedule.Payment_Status_ref_gne__r.Name.equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_SUBMITTED_STATUS))){
            currentPaymentSchedule.Planned_Date_gne__c = currentPaymentSchedule.Invoice_Submitted_Date_gne__c;
        }
        
        if (currentPaymentSchedule.Withhold_Indicator_gne__c == 'Yes' && rateTableAssigned != null && rateTableAssigned.Withhold_Type_gne__c != null && currentPaymentSchedule.Invoice_Amount_gne__c != null) {
                Decimal unitWithholdingAmount = 0;
                if (rateTableAssigned.Withhold_Type_gne__c == 'Unit' && rateTableAssigned.Unit_gne__c != null && rateTableAssigned.Unit_gne__c != 0) {
                        unitWithholdingAmount = rateTableAssigned.Cost_gne__c;
                }
                if (rateTableAssigned.Withhold_Type_gne__c == 'Percent') {
                        unitWithholdingAmount = rateTableAssigned.Cost_gne__c - rateTableAssigned.Net_Unit_Cost_gne__c;
                }
                Decimal paidUnits = currentPaymentSchedule.Invoice_Amount_gne__c/unitWithholdingAmount;
                    if(paidUnits - Math.round(paidUnits) != 0) {
                                paymentErrorMessagesList.add(Label.CFAR_GSTARS_INVOICE_AMOUNT_NOT_MULTIPLIER_OF_UNIT_WITHHOLDING_AMOUNT);
                                isPaymentError = true;
                    }
                    if (currentPaymentSchedule.Id == null || (currentPaymentSchedule.Id != null && (currentPaymentSchedule.Withhold_Indicator_gne__c != initialWithholdIndicator || currentPaymentSchedule.Rate_Table_ref_gne__c != initialRT))) {
                        if (paidUnits > rateTableAssigned.Remaining_Withholding_Units_gne__c) {
                                paymentErrorMessagesList.add(Label.CFAR_GSTARS_PAID_UNITS_LESS_EQUAL_REMAINING_WITHHOLD_UNITS);
                                        isPaymentError = true;
                        }
                    }
                    else {
                        if ((currentPaymentSchedule.Invoice_Amount_gne__c - initialInvoiceAmount)/unitWithholdingAmount > rateTableAssigned.Remaining_Withholding_Units_gne__c) {
                                paymentErrorMessagesList.add(Label.CFAR_GSTARS_PAID_UNITS_LESS_EQUAL_REMAINING_WITHHOLD_UNITS);
                                        isPaymentError = true;
                        }
                    }
        }
        
        if (currentPaymentSchedule.Withhold_Indicator_gne__c != 'Yes' && rateTableAssigned != null && currentPaymentSchedule.Invoice_Amount_gne__c != null) {
                Decimal remainingUnits = rateTableAssigned.Remaining_Units_gne__c != null ? rateTableAssigned.Remaining_Units_gne__c : 0;
                        Decimal netUnitCost = rateTableAssigned.Net_Unit_Cost_gne__c != null ? rateTableAssigned.Net_Unit_Cost_gne__c : 0;
                        if (netUnitCost != 0) {
                        if (currentPaymentSchedule.Id == null || (currentPaymentSchedule.Id != null && (currentPaymentSchedule.Withhold_Indicator_gne__c != initialWithholdIndicator || currentPaymentSchedule.Rate_Table_ref_gne__c != initialRT)))
                                remainingUnits = remainingUnits - currentPaymentSchedule.Invoice_Amount_gne__c/netUnitCost;
                        else 
                                remainingUnits = remainingUnits - (currentPaymentSchedule.Invoice_Amount_gne__c - initialInvoiceAmount)/netUnitCost;
                        }
                        if(remainingUnits < 0) {
                                paymentErrorMessagesList.add(Label.CFAR_GSTARS_REMAINING_UNITS_BELOW_ZERO);
                                isPaymentError=true;
                    }
        }
        
        if (!isError && !isPaymentError) {

            if(currentPaymentSchedule.Budget_Contract_ref_gne__c == null)
                currentPaymentSchedule.Budget_Contract_ref_gne__c = selectedInvestigatorsBudgetContractId;

            ApexPages.StandardController ctrl = new ApexPages.StandardController(currentPaymentSchedule);
            if (currentPaymentSchedule.Id == null) {
                currentPaymentSchedule.Line_Num_gne__c = Integer.valueOf(
                    [select count(Id) counter from CFAR_Budget_CPS_Payments_gne__c
                    where Budget_Contract_ref_gne__c = :selectedInvestigatorsBudgetContractId][0].get('counter')) + 1;
            }
            PageReference pr = ctrl.save();
            isError = pr == null && ApexPages.hasMessages();
            if(isError) {
                logMessage();
            } else {
                refreshTrial();
                getPayments();
                investigatorSelected();
                if(!trial.Is_Budget_Straight_Line__c)
                        usePaymentsAsProjections();
                return null;
            }
        }
        return null;
    }
    
    public void cancelCreatePaymentSchedule() {
        addEditPaymentSchedule = false;
        resetError();
        resetPaymentError();
    }

    public void editPaymentSchedule() {
        paymentScheduleFrozen = false;
        resetError();
        resetPaymentError();
        currentPaymentSchedule = [select Id, Name, Check_Num_gne__c, Comments_gne__c, Withhold_Indicator_gne__c,
                                                  Invoice_gne__c, Invoice_Amount_gne__c, Invoice_Date_gne__c, Invoice_Submitted_Date_gne__c, Line_Num_gne__c, Budget_Contract_ref_gne__r.Team_Member_ref_gne__c, frm_Investigator_ref_gne__c,
                                                  Paid_On_gne__c, Payment_Explanation_Text_gne__c, Payment_Status_ref_gne__c, Payment_Status_ref_gne__r.Name, Planned_Amount_gne__c, Planned_Date_gne__c, frm_Trial_Id_gne__c,
                                                  Rate_Table_ref_gne__r.Withhold_Type_gne__c, Rate_Table_ref_gne__c
                                          from CFAR_Budget_CPS_Payments_gne__c where Id = :paymentScheduleId];
        if (currentPaymentSchedule.Withhold_Indicator_gne__c == null) {
                currentPaymentSchedule.Withhold_Indicator_gne__c = 'No';
        }
        hasWithhold = (!String.isBlank(currentPaymentSchedule.Rate_Table_ref_gne__r.Withhold_Type_gne__c)) ? true : false;
        originalPaymentPlannedAmount = currentPaymentSchedule.Planned_Amount_gne__c;
        if(originalPaymentPlannedAmount == null) originalPaymentPlannedAmount = 0;
        selectedInvestigator = currentPaymentSchedule.frm_Investigator_ref_gne__c;
        originalPaymentStatus=currentPaymentSchedule.Payment_Status_ref_gne__r.Name;
        if(!String.isBlank(currentPaymentSchedule.Check_Num_gne__c) && currentPaymentSchedule.Paid_On_gne__c != null && !getCurrentUserIsAdmin()) {
            paymentScheduleFrozen = true;
        }
        addEditPaymentSchedule = true;
        initialInvoiceAmount = (currentPaymentSchedule.Invoice_Amount_gne__c != null) ? Decimal.valueOf(Double.valueOf(currentPaymentSchedule.Invoice_Amount_gne__c)) : 0;
        initialWithholdIndicator = String.valueOf(currentPaymentSchedule.Withhold_Indicator_gne__c);
        initialRT = (currentPaymentSchedule.Rate_Table_ref_gne__c != null) ? Id.valueOf(String.valueOf(currentPaymentSchedule.Rate_Table_ref_gne__c)) : null;
        // display positive refund invoice value
        fixRefundPaymentForDisplay();
    }
    
	public void deletePaymentSchedule() {
		CFAR_Budget_CPS_Payments_gne__c paymentScheduleToDel = [select Id, Name from CFAR_Budget_CPS_Payments_gne__c where Id = :paymentScheduleId];
		try{
            CFAR_SecurityUtils.deleteRecord(paymentScheduleToDel);
        } catch(Exception ex){
            ApexPages.addMessages(ex);
            return;
        }
		setSelectedInvestigatorsBudgetContractId();
    }
    
    public Boolean showPaymentWillLockWithholdTypePopup {
        get {
                Boolean retVal = false;
                Boolean RTWasLockedBefore = false;
                if (currentPaymentSchedule == null) {
                        retVal = false;
                }
                else if (hasWithhold) {
                        if ('Unit'.equals(currentPaymentSchedule.Rate_Table_ref_gne__r.Withhold_Type_gne__c)) {
                                RTWasLockedBefore = Integer.valueOf([select count(Id) counter from CFAR_Budget_CPS_Payments_gne__c where Rate_Table_ref_gne__c =: currentPaymentSchedule.Rate_Table_ref_gne__c and Withhold_Indicator_gne__c = 'Yes'][0].get('counter')) > 0;
                                if (!RTWasLockedBefore && 'Yes'.equals(currentPaymentSchedule.Withhold_Indicator_gne__c)) {
                                        retVal = true;
                                }
                        }
                        else if ('Percent'.equals(currentPaymentSchedule.Rate_Table_ref_gne__r.Withhold_Type_gne__c)) {
                                RTWasLockedBefore = Integer.valueOf([select count(Id) counter from CFAR_Budget_CPS_Payments_gne__c where Rate_Table_ref_gne__c =: currentPaymentSchedule.Rate_Table_ref_gne__c][0].get('counter')) > 0;
                                if (!RTWasLockedBefore) {
                                        retVal = true;
                                }
                        }
                }
                return retVal;
        }
        set;
    }
    
    public Boolean showRTWillLockWithholdTypePopup {
        get {
                Boolean retVal = false;
                Boolean RTWasLockedBefore = false;
                if (currentRateTable != null && currentRateTable.Id != null && String.isNotBlank(currentRateTable.WithHold_Type_gne__c) && currentRateTable.WithHold_Type_gne__c != initialWithholdType) {
                        if ('Unit'.equals(currentRateTable.WithHold_Type_gne__c)) {
                                RTWasLockedBefore = ('Percent'.equals(initialWithholdType) && ![select Id from CFAR_Budget_CPS_Payments_gne__c where Rate_Table_ref_gne__c =: currentRateTable.Id limit 1].isEmpty());
                                if (!RTWasLockedBefore && ![select Id from CFAR_Budget_CPS_Payments_gne__c where Rate_Table_ref_gne__c =: currentRateTable.Id and Withhold_Indicator_gne__c = 'Yes' limit 1].isEmpty()) {
                                        retVal = true;
                                }
                        }
                        else if ('Percent'.equals(currentRateTable.WithHold_Type_gne__c)) {
                                RTWasLockedBefore = ('Unit'.equals(initialWithholdType) && ![select Id from CFAR_Budget_CPS_Payments_gne__c where Rate_Table_ref_gne__c =: currentRateTable.Id and Withhold_Indicator_gne__c = 'Yes' limit 1].isEmpty());
                                if (!RTWasLockedBefore && ![select Id from CFAR_Budget_CPS_Payments_gne__c where Rate_Table_ref_gne__c =: currentRateTable.Id limit 1].isEmpty()) {
                                        retVal = true;
                                }
                        }
                }
                return retVal;
        }
        set;
    }
    
    public void paymentStatusChanged() {
        if(currentPaymentSchedule.Payment_Status_ref_gne__c != null) {
            CFAR_Payment_Schedule_Status_gne__c p = [select Id, Name from CFAR_Payment_Schedule_Status_gne__c where Id = :currentPaymentSchedule.Payment_Status_ref_gne__c];
            currentPaymentSchedule.Payment_Status_ref_gne__r = p;            
        } else {
            currentPaymentSchedule.Payment_Status_ref_gne__r.Name = '';
        }
    }
    
    public List<SelectOption> getWithholdIndicatorSelectOptions() {
                return CFAR_Utils.getPicklistValues(new CFAR_Budget_CPS_Payments_gne__c(), 'Withhold_Indicator_gne__c');
        }
    
    // Disabled this function during Phase 3 project. Not enough time to rewrite and business said it is not used.
    public void usePaymentsAsProjections() {
        Boolean containProjections = CFAR_Budget_Utils.hasProjections(trial.Id);
    }
    
        public void validateRateTableStatus() {
                if(rtErrorMessagesList == null)
                        resetRTError();
        if(currentRateTable.Id != null) {
            String cancelledStatus = Label.CFAR_GSTARS_PAYMENT_SCHEDULE_CANCELLED_STATUS;
                List<CFAR_Budget_CPS_Payments_gne__c> payments = [Select Id from CFAR_Budget_CPS_Payments_gne__c where Rate_Table_ref_gne__c =: currentRateTable.Id 
                                AND Payment_Status_ref_gne__r.Name != :cancelledStatus];
                if(currentRateTable.Status_gne__c == 'Not Active' && payments.size() > 0 ) {
                        rtErrorMessagesList.add(Label.CFAR_GSTARS_UNABLE_TO_SET_NOT_ACTIVE_STATUS_IN_RATE_TABLE);               
                        isRateTableError=true;                          
                } else {
                        rtErrorMessagesList.remove(Label.CFAR_GSTARS_UNABLE_TO_SET_NOT_ACTIVE_STATUS_IN_RATE_TABLE);                                    
                }       
        }               
        }
        
        public List<SelectOption> getRateTableStatusSelectOptions() {
                return CFAR_Utils.getPicklistValues(new CFAR_Rate_Table_gne__c(), 'Status_gne__c');
        }
        
        public void validateRateTableContractTerm() {
                if(rtErrorMessagesList == null)
                        resetRTError();
                Boolean hasSameContract = false;
        for(CFAR_Rate_Table_gne__c rt : [Select id, Contract_Term_gne__c from CFAR_Rate_Table_gne__c where Budget_Contract_ref_gne__c =: selectedInvestigatorsBudgetContractId]) {
                if(rt.Contract_Term_gne__c.equals(currentRateTable.Contract_Term_gne__c) && rt.Id != currentRateTable.Id) {                     
                        rtErrorMessagesList.add(Label.CFAR_GSTARS_CONTRACT_TERM_IS_NOT_UNIQUE);         
                        isRateTableError=true;
                        hasSameContract = true;
                }
        }
        
        if(!hasSameContract) {
                        rtErrorMessagesList.remove(Label.CFAR_GSTARS_CONTRACT_TERM_IS_NOT_UNIQUE);                              
        }
        
        if(currentRateTable.Id != null) {
            String cancelledStatus = Label.CFAR_GSTARS_PAYMENT_SCHEDULE_CANCELLED_STATUS;
                List<CFAR_Budget_CPS_Payments_gne__c> payments = [Select Id from CFAR_Budget_CPS_Payments_gne__c where Rate_Table_ref_gne__c =: currentRateTable.Id 
                                AND Payment_Status_ref_gne__r.Name != :cancelledStatus];
                if(initialContractTerm != currentRateTable.Contract_Term_gne__c && payments.size() > 0 ) {
                        rtErrorMessagesList.add(Label.CFAR_GSTARS_CONTRACT_TERM_USED_IN_PAYMENTS);              
                        isRateTableError=true;                                          
                } else {
                        rtErrorMessagesList.remove(Label.CFAR_GSTARS_CONTRACT_TERM_USED_IN_PAYMENTS);                           
                }               
        }               
        }
    
        public void validatePaymentInvoiceSubmittedDate() {
                if(paymentErrorMessagesList == null)
                        resetPaymentError();
        if(currentPaymentSchedule.Invoice_Submitted_Date_gne__c != null && selectedInvestigatorContract.Contract_End_Date_gne__c != null && currentPaymentSchedule.Invoice_Submitted_Date_gne__c > selectedInvestigatorContract.Contract_End_Date_gne__c
            && currentPaymentSchedule.Payment_Status_ref_gne__r != null && (currentPaymentSchedule.Payment_Status_ref_gne__r.Name.equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_DUE_NO_INVOICE_SUBMITTED_STATUS) 
            || currentPaymentSchedule.Payment_Status_ref_gne__r.Name.equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_SUBMITTED_STATUS)
            || currentPaymentSchedule.Payment_Status_ref_gne__r.Name.equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PAID_STATUS))){
            paymentErrorMessagesList.add(Label.CFAR_GSTARS_INVOICE_SUBMITTED_DATE_AFTER_CONTRACT_EXPIRY_DATE);
            isPaymentError=true;
        } else {
            paymentErrorMessagesList.remove(Label.CFAR_GSTARS_INVOICE_SUBMITTED_DATE_AFTER_CONTRACT_EXPIRY_DATE);               
        }
        if(currentPaymentSchedule.Invoice_Submitted_Date_gne__c!=null && currentPaymentSchedule.Invoice_Submitted_Date_gne__c > Date.today()){
            paymentErrorMessagesList.add(Label.CFAR_GSTARS_INVOICE_SUBMITTED_DATE_IS_A_FUTURE_DATE);
            isPaymentError=true;
        } else {
                paymentErrorMessagesList.remove(Label.CFAR_GSTARS_INVOICE_SUBMITTED_DATE_IS_A_FUTURE_DATE);
        }
        if(currentPaymentSchedule.Invoice_Submitted_Date_gne__c!=null && selectedInvestigatorContract.Original_Contract_Execution_Date_gne__c != null && currentPaymentSchedule.Invoice_Submitted_Date_gne__c < selectedInvestigatorContract.Original_Contract_Execution_Date_gne__c
            && currentPaymentSchedule.Payment_Status_ref_gne__r != null && (currentPaymentSchedule.Payment_Status_ref_gne__r.Name.equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_DUE_NO_INVOICE_SUBMITTED_STATUS) 
            || currentPaymentSchedule.Payment_Status_ref_gne__r.Name.equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_SUBMITTED_STATUS)
            || currentPaymentSchedule.Payment_Status_ref_gne__r.Name.equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PAID_STATUS))){
            paymentErrorMessagesList.add(Label.CFAR_GSTARS_INVOICE_SUBMITTED_DATE_PRIOR_FULLY_EXECUTED_DATE);
            isPaymentError=true;
        } else {
            paymentErrorMessagesList.remove(Label.CFAR_GSTARS_INVOICE_SUBMITTED_DATE_PRIOR_FULLY_EXECUTED_DATE);                
        }
        }
        
        public void validatePaymentInvoiceDate() {
                if(paymentErrorMessagesList == null)
                        resetPaymentError();
        if(currentPaymentSchedule.Invoice_Date_gne__c != null && selectedInvestigatorContract.Contract_End_Date_gne__c != null && currentPaymentSchedule.Invoice_Date_gne__c > selectedInvestigatorContract.Contract_End_Date_gne__c){
            paymentErrorMessagesList.add(Label.CFAR_GSTARS_INVOICE_DATE_AFTER_CONTRACT_EXPIRY_DATE);
            isPaymentError=true;
        } else {
            paymentErrorMessagesList.remove(Label.CFAR_GSTARS_INVOICE_DATE_AFTER_CONTRACT_EXPIRY_DATE);         
        }
        if(currentPaymentSchedule.Invoice_Date_gne__c!=null && currentPaymentSchedule.Invoice_Date_gne__c > Date.today()){
            paymentErrorMessagesList.add(Label.CFAR_GSTARS_INVOICE_DATE_IS_A_FUTURE_DATE);
            isPaymentError=true;
        } else {
                paymentErrorMessagesList.remove(Label.CFAR_GSTARS_INVOICE_DATE_IS_A_FUTURE_DATE);
        }
        if(currentPaymentSchedule.Invoice_Date_gne__c!=null && selectedInvestigatorContract.Original_Contract_Execution_Date_gne__c != null && currentPaymentSchedule.Invoice_Date_gne__c < selectedInvestigatorContract.Original_Contract_Execution_Date_gne__c){
            paymentErrorMessagesList.add(Label.CFAR_GSTARS_INVOICE_DATE_PRIOR_FULLY_EXECUTED_DATE);
            isPaymentError=true;
        } else {
                paymentErrorMessagesList.remove(Label.CFAR_GSTARS_INVOICE_DATE_PRIOR_FULLY_EXECUTED_DATE);
        }
        }
        
        public void validatePaymentPlannedAmount() {
                if(paymentErrorMessagesList == null)
                        resetPaymentError();
                if(currentPaymentSchedule.Planned_Amount_gne__c != null && currentPaymentSchedule.Planned_Amount_gne__c <= 0){
            paymentErrorMessagesList.add(Label.CFAR_GSTARS_PLANNED_AMOUNT_GREATER_THAN_ZERO);
            isPaymentError=true;
        }
        else {
                paymentErrorMessagesList.remove(Label.CFAR_GSTARS_PLANNED_AMOUNT_GREATER_THAN_ZERO);
        }
        }

    // SORTING

    public void sortContractTrackings(){
        getContractTrackings();
    }

    public PageReference sortRateTables(){
    if ('asc'.equals(rtSortDirection))
            rtSortDirection = 'desc';
        else
            rtSortDirection = 'asc';        
       return null;
    }

    public PageReference sortProjections() {
        if ('asc'.equals(prjSortDirection))
        prjSortDirection = 'desc';
        else
            prjSortDirection = 'asc';
        return null;
    }

    public PageReference sortPaymentSchedule() {
        if ('asc'.equals(psSortDirection))
            psSortDirection = 'desc';
        else
            psSortDirection = 'asc';
        return null;
    }

    public void editPoNumber() {
        poNumberIsEdit = true;
        poNumberValue = selectedInvestigatorContract.PO_Number_gne__c;
    }
    
    public Boolean poNumberCorrect = true;
    public Boolean getPoNumberCorrect(){
        return poNumberCorrect;
    }
    public void setPoNumberCorrect(Boolean poNumC){
    	poNumberCorrect = poNumC;
    } 
    public void savePoNumber() {
        if(poNumberValue.length() <= 255){
        
        selectedInvestigatorContract.Po_Number_gne__c = poNumberValue;        
        poNumberCorrect = true;
        CFAR_SecurityUtils.updateRecord(selectedInvestigatorContract);
        poNumberIsEdit = false;
        
        }
        else {
        poNumberCorrect = false;
        }
        
        
    }

    public void editContractAssignment() {
        contractAssignmentErrorList = new Set<String>();
    }

    public void reassignContract() {
        try {
            selectedinvestigatorcontract.Team_Member_ref_gne__c = selectedInvestigatorToReassign;
            CFAR_SecurityUtils.updateRecord(selectedinvestigatorcontract);

            selectedInvestigatorId = selectedinvestigatorcontract.Team_Member_ref_gne__c;
            selectedInvestigator2 = investigators.get(selectedInvestigatorId);
            isAssignmentError = false;

        } catch (Exception e) {
            if (selectedInvestigatorToReassign.equals('--None--')) {
                contractAssignmentErrorList.add('Please select a valid New Investigator / Vendor.');
                isAssignmentError = true;
            } else {
                contractAssignmentErrorList.add(e.getMessage());
            }
        }
    }

    public boolean getRenderEditWbs() {
        return !trial.frm_Is_Closed_gne__c && !getIsAdminFixStatus() && !getIsReadOnly()
                && !editMode && getSelectedInvestigatorRole() == 'PI = Primary (or Principal) Investigator';
    }

    public boolean getNeedsContractReassignment() {
        if (getSelectedInvestigatorRole() == CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR && !selectedInvestigator2.frm_Is_Inactive_gne__c 
                && !trial.frm_Is_Closed_gne__c && !getIsAdminFixStatus() && !editMode) {

            Integer existingInactivePiContracts = [SELECT COUNT() FROM CFAR_Budget_Contract_gne__c 
                WHERE Team_Member_ref_gne__r.CFAR_Trial_ref_gne__c =: trial.Id AND Team_Member_ref_gne__r.frm_Function_Role_gne__c = :CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR 
                AND Team_Member_ref_gne__r.frm_Is_Inactive_gne__c = true];
            if(existingInactivePiContracts > 0){
                return true;
            }
        }
        return false;
    }

    public class RateTableWrapper {
        public String id {get; set;}    
        public String status {get; set;}
        public String paymentType {get; set;}
        public String contractTerm {get; set;}
        public Decimal cost {get; set;}
        public String unit {get; set;}
        public String witholdType {get; set;}
        public String witholdValue {get; set;}
        public Decimal witholdAmount {get; set;}        
        public Decimal netCost {get; set;}
        public Decimal netUnitCost {get; set;}          
        public Decimal totalAmount {get; set;}
        public Decimal totalPaidAmount {get; set;}      
        public Decimal remainingBalance {get; set;}
        public Decimal remainingUnits {get; set;}       
        public String pisubi {get; set;}
        public String comments {get; set;}
        public Decimal remainingWithholdingUnits {get; set;}
        
        public RateTableWrapper(CFAR_Rate_Table_gne__c rate) {
                if(!'Total'.equals(rate.Payment_Type_gne__c)) {
                        this.id = rate.Id;
                        this.status = rate.Status_gne__c;                               
                        this.paymentType = rate.Payment_Type_gne__c;
                                this.contractTerm = rate.Contract_Term_gne__c;
                                this.cost = rate.Cost_gne__c;
                                this.unit = rate.Unit_gne__c == null ? '' : String.valueOf(rate.Unit_gne__c);
                                this.witholdType = rate.WithHold_Type_gne__c;
                                this.witholdValue = rate.WithHold_Value_gne__c == null ? '' : String.valueOf(rate.WithHold_Value_gne__c);
                                this.witholdAmount = rate.WithHold_Amount_gne__c;               
                                this.netCost = rate.Net_Cost_gne__c;
                                this.netUnitCost = rate.Net_Unit_Cost_gne__c;
                                this.totalAmount = rate.Total_Amount_gne__c;
                                this.totalPaidAmount = rate.Total_Paid_Amount_gne__c;                           
                                this.remainingBalance = rate.Remaining_Balance_gne__c;
                                this.remainingUnits = rate.Remaining_Units_gne__c;                              
                                this.pisubi = rate.PI_Sub_I_Name_gne__c;
                                this.comments = rate.Comments_gne__c;
                                this.remainingWithholdingUnits = rate.Remaining_Withholding_Units_gne__c;
                } else {
                        this.paymentType = rate.Payment_Type_gne__c;
                        this.remainingBalance = rate.Sum_Remaining_Balance_gne__c;
                        this.remainingUnits = rate.Sum_Remaining_Units_gne__c;          
                                this.totalAmount = rate.Sum_Total_Amount_gne__c;                
                }
                
        }
    }
    
    /**
     * Get negative value for properly storing of refund payment
     **/
    private void fixRefundPaymentForStore() {
        fixRefundPayment(false);
    }

    /**
     * Get positive value for properly displaying of refund payment
     **/
    private void fixRefundPaymentForDisplay() {
        fixRefundPayment(true);
    }

    private void fixRefundPayment(boolean getPositive) {
        if (currentPaymentSchedule.Payment_Status_ref_gne__c != null && currentPaymentSchedule.Payment_Status_ref_gne__r.Name.equals(Label.CFAR_GSTARS_PAYMENT_SCHEDULE_REFUND_STATUS)
                && (0 != currentPaymentSchedule.Invoice_Amount_gne__c)
                // XOR - true only if inputs differ
                && (getPositive ^ currentPaymentSchedule.Invoice_Amount_gne__c > 0)) {
            currentPaymentSchedule.Invoice_Amount_gne__c = -currentPaymentSchedule.Invoice_Amount_gne__c;
        }
    }
}