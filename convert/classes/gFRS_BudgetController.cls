/**
 *  Controller specific to the Budget page.
 **/
public with sharing class gFRS_BudgetController {

    //-- Lookup Constants
    /** The type of page this is **/
    public static final String CONTENT_TYPE = 'Budget';

    /** page to confirm the budget discrepancy **/
    public static final String PARAM_CONFIRMATION = 'confirm';

    /** discrepency confirmation **/
    public static final String PARAM_DISCREPENCY = 'discrepency';

    /** page to move to after completing the page **/
    public static final String PATH_COMPLETE_ATTACHMENTS = '/apex/GFRS_FileAttachments';
    public static final String PATH_COMPLETE_CONFIRMATION = '/apex/GFRS_Confirmation';

    /** default page to move to when hitting 'BACK' **/
    public static final String PATH_BACK = '/apex/GFRS_Program';

    /** same page **/
    public static final String PATH_SELF = '/apex/GFRS_Budget';

    /** path for the budget confirmation on discrepency **/
    public static final String PATH_CONFIRMATION = '' + PARAM_CONFIRMATION + '=' + PARAM_DISCREPENCY;

    /** question for dependent budget picklist options **/
    public static final String PICKLIST_BUDGET_SUB_CATEGORIES = 'budgetSubCategories';

    /** The Funding request being used **/
    public GFRS_Funding_Request__c fundingRequest { get; set; }

    public GFRS_RequestBudget__c[] fundingRequestBudgets { get; set; }

    public Map<String, String> contentItems { get; set; }

    /** Whether the Live budget is provided **/
    public Boolean hasLiveBudget { get; set; }

    /** Whether the Webinar budget is provided **/
    public Boolean hasWebinarBudget { get; set; }

    /** Whether the Enduring budget is provided **/
    public Boolean hasEnduringBudget { get; set; }

    /** Budget categories **/
    public String budgetCategories { get; set; }

    /** whether the budget is different AND requires confirmation to continue **/
    public Boolean shouldConfirmBudgetDifference { get; set; }

    /** full path for completion **/
    public String pathCompleteFull { get; set; }

    /** self path when cancel **/
    public String pathSelfOnCancel { get; set; }

    public Map<String, Boolean> mapExistingBudgets;

    public Boolean isEditable { get; set; }

    public GFRS_BudgetController(ApexPages.StandardController std) {
        String resultPath = '';
        try {
            this.fundingRequest = (GFRS_Funding_Request__c) std.getRecord();
            try {
                this.fundingRequest = [
                        SELECT Id, Record_Type_Name__c, Information_Needed__c, Total_Program_Budget__c,Accountable_Employee_Approval__c,
                                Requested_Amount__c, Location__c, Organization__c, Other_Commercial_Supporters__c,
                                Authorized_Signer__c, Signing_Authority_Email__c, Foundation_Classified__c
                        FROM GFRS_Funding_Request__c
                        WHERE Id = :THIS.fundingRequest.Id
                ];
            } catch (Exception err) {
                System.debug('unable to find finding request[' + this.fundingRequest.Id + ']');
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to find funding request'));
                return;
            }
            this.isEditable = gFRS_Util.multiSelectHasItem(this.fundingRequest.Information_Needed__c, 'Budget');
            resultPath = (this.fundingRequest.Record_Type_Name__c == gFRS_Util.TYPE_HC_CHAR_NAME) ? PATH_COMPLETE_CONFIRMATION : PATH_COMPLETE_ATTACHMENTS;
            
            if (this.fundingRequest.Record_Type_Name__c == gFRS_Util.TYPE_HC_CHAR_NAME && this.fundingRequest.Foundation_Classified__c == 'FALSE') {
                this.pathCompleteFull = '/apex/gFRS_ACHData?id=' + fundingRequest.Location__c + '&fundingreq=' + fundingRequest.id;
            }
            else{
                this.pathCompleteFull = gFRS_Util.initializeLink(resultPath, this.fundingRequest, null);                
            }
        
            this.pathSelfOnCancel = gFRS_Util.initializeLink(PATH_SELF, this.fundingRequest, null);

            this.contentItems = gFRS_ContentTranslationUtil.fetchContentTranslationsByFilter(CONTENT_TYPE, UserInfo.getLanguage());

            this.mapExistingBudgets = new Map<String, Boolean>{
                    gFRS_Util.BUDGET_TYPE_LIVE => false,
                    gFRS_Util.BUDGET_TYPE_WEB => false,
                    gFRS_Util.BUDGET_TYPE_ENDURING => false
            };

            this.fundingRequestBudgets = [
                    SELECT Id, Name, Amount__c, Budget_Summary_Description__c, Request_Delivery_Format__c,
                            Type__c, Request_Name__c
                    FROM GFRS_RequestBudget__c
                    WHERE Grant_Request__c = :THIS.fundingRequest.Id
            ];

            for (GFRS_RequestBudget__c b : this.fundingRequestBudgets) {
                if (mapExistingBudgets.containsKey(b.Type__c)) {
                    mapExistingBudgets.put(b.Type__c, true);
                }
            }

            gFRS_ContentDependantPicklist budgetSubCategoryManager = new gFRS_ContentDependantPicklist(PICKLIST_BUDGET_SUB_CATEGORIES);
            this.budgetCategories = budgetSubCategoryManager.getMasterAnswersWithChildAnswers();

            this.hasLiveBudget = this.hasWebinarBudget = this.hasEnduringBudget = false;
            determineBudgets();

            Map<String, String> params = ApexPages.currentPage().getParameters();
            this.shouldConfirmBudgetDifference = (params.containsKey(PARAM_CONFIRMATION) && PARAM_DISCREPENCY.equals(params.get(PARAM_CONFIRMATION)));

        } catch (Exception err) {
            ApexPages.addMessages(err);
        }
    }

    /**
     *  Moves the page back
     **/
    public PageReference back() {
        return (new PageReference(gFRS_Util.initializeLink(PATH_BACK, this.fundingRequest, null)));
    }

    public PageReference next() {
        String resultPath = '';
        if (this.fundingRequest.Record_Type_Name__c == gFRS_Util.TYPE_HC_CHAR_NAME) {
            resultPath = PATH_COMPLETE_CONFIRMATION;
            if(this.fundingRequest.Foundation_Classified__c == 'FALSE'){
                return new PageReference('/apex/gFRS_ACHData?id=' + fundingRequest.Location__c + '&fundingreq=' + fundingRequest.id);
            }
            else{
                return new PageReference(gFRS_Util.initializeLink(resultPath, this.fundingRequest, null));
            }
            
        } else {
            resultPath = PATH_COMPLETE_ATTACHMENTS;
            return new PageReference(gFRS_Util.initializeLink(resultPath, this.fundingRequest, null));
        }
        //return new PageReference(gFRS_Util.initializeLink(resultPath, this.fundingRequest, null));
    }

    /**
     *  Method called to perform final submission
     **/
    public PageReference save() {
        if (!GFRS_BudgetRemotable.validBudgetLIs('', this.fundingRequest.Id)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.GFRS_ERR_BUDGET_COMP_VAL));
            return null;
        }
        if (!GFRS_BudgetRemotable.validBudgetLIsEmpty('', this.fundingRequest.Id)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.GFRS_ERR_BUDGET_LI_EMPTY));
            return null;
        }
        if (this.fundingRequest.Total_Program_Budget__c <= 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.GFRS_ERR_BUDGET_TOT_OV_EMPTY));
            return null;
        }
        try {
            gFRS_Util_NoShare.saveLockedFundingRequest(this.fundingRequest);
        } catch (Exception err) {
            System.debug('Exception occurred:' + err);
            String errMsg = gFRS_Util.getPrettyMessage(err);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errMsg));
            return(null);
        }

        Decimal totalAmount = this.fundingRequest.Total_Program_Budget__c;
        Decimal budgetedAmount = 0;
        for (GFRS_RequestBudget__c budget : [SELECT Id, Amount__c FROM GFRS_RequestBudget__c WHERE Grant_Request__c = :THIS.fundingRequest.Id]) {
            if (budget.Amount__c != null) {
                budgetedAmount += budget.Amount__c;
            }
        }

        if ((totalAmount > budgetedAmount ? totalAmount - budgetedAmount : budgetedAmount - totalAmount) > 1) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.GFRS_ERR_BUDGET_ENTERED_SO_FAR));
            return null;
        }

        if (this.fundingRequest.Requested_Amount__c >= totalAmount) {
            return (new PageReference(gFRS_Util.initializeLink(PATH_SELF, this.fundingRequest, PATH_CONFIRMATION)).setRedirect(true));
        } else {
            return(new PageReference(pathCompleteFull));
        }
    }

    /**
     *  Determine the budgets available.
     **/
    private void determineBudgets() {
        try {
            GFRS_Program__c[] programs = [
                    SELECT
                            Id, Type__c
                    FROM GFRS_Program__c
                    WHERE Funding_Request__c = :THIS.fundingRequest.Id
            ];

            for (GFRS_Program__c p : programs) {
                if (p.Type__c == gFRS_Util.BUDGET_TYPE_WEB && !this.mapExistingBudgets.get(gFRS_Util.BUDGET_TYPE_WEB)) {
                    hasWebinarBudget = true;
                }
                if (p.Type__c == gFRS_Util.BUDGET_TYPE_ENDURING && !this.mapExistingBudgets.get(gFRS_Util.BUDGET_TYPE_ENDURING)) {
                    hasEnduringBudget = true;
                }
                if ((p.Type__c == gFRS_Util.BUDGET_TYPE_LIVE || p.Type__c == 'Live Activity' || p.Type__c == 'Ongoing' || p.Type__c == 'Online Resources')
                        && !this.mapExistingBudgets.get(gFRS_Util.BUDGET_TYPE_LIVE)) {
                    hasLiveBudget = true;
                }
            }
        } catch (Exception err) {
            ApexPages.addMessages(err);
        }
    }

    public PageReference checkValidPage() {
        if (gFRS_Util.isInternalRequest(this.fundingRequest.Record_Type_Name__c)) {
            return (new PageReference(gFRS_Util.initializeLink(PATH_COMPLETE_ATTACHMENTS, this.fundingRequest, null)));
        } else {
            createBudgets();
            return (null);
        }
    }

    /**
     *  If there is no existing budget, create new ones.
     **/
    public void createBudgets() {
        GFRS_Request_Budget_Line_Item__c budgetLI = null;
        GFRS_Request_Budget_Line_Item__c[] budgetLIs = new GFRS_Request_Budget_Line_Item__c[]{
        };

        GFRS_RequestBudget__c liveBudget = null;
        GFRS_RequestBudget__c webinarBudget = null;
        GFRS_RequestBudget__c enduringBudget = null;

        GFRS_RequestBudget__c[] lBudgetsToInsert = new GFRS_RequestBudget__c[]{
        };
        try {
            //-- save the budgets
            if (this.hasLiveBudget == true) {
                liveBudget = new GFRS_RequestBudget__c(Budget_Summary_Description__c = gFRS_Util.BUDGET_DESC_LIVE, Grant_Request__c = this.fundingRequest.Id, Type__c = gFRS_Util.BUDGET_TYPE_LIVE);
                lBudgetsToInsert.add(liveBudget);

                this.fundingRequestBudgets.add(liveBudget);
            }
            if (this.hasWebinarBudget == true) {
                webinarBudget = new GFRS_RequestBudget__c(Budget_Summary_Description__c = gFRS_Util.BUDGET_DESC_WEB, Grant_Request__c = this.fundingRequest.Id, Type__c = gFRS_Util.BUDGET_TYPE_WEB);
                lBudgetsToInsert.add(webinarBudget);


                this.fundingRequestBudgets.add(webinarBudget);
            }
            if (this.hasEnduringBudget == true) {
                enduringBudget = new GFRS_RequestBudget__c(Budget_Summary_Description__c = gFRS_Util.BUDGET_DESC_ENDURE, Grant_Request__c = this.fundingRequest.Id, Type__c = gFRS_Util.BUDGET_TYPE_ENDURING);
                lBudgetsToInsert.add(enduringBudget);

                this.fundingRequestBudgets.add(enduringBudget);
            }
            gFRS_Util_NoShare.saveLockedBudgets(lBudgetsToInsert);

            //-- now the budgets are saved, we can save the LIs
            if (liveBudget != null) {
                budgetLI = new GFRS_Request_Budget_Line_Item__c(Budget__c = liveBudget.Id);
                budgetLIs.add(budgetLI);
            }
            if (webinarBudget != null) {
                budgetLI = new GFRS_Request_Budget_Line_Item__c(Budget__c = webinarBudget.Id);
                budgetLIs.add(budgetLI);
            }
            if (enduringBudget != null) {
                budgetLI = new GFRS_Request_Budget_Line_Item__c(Budget__c = enduringBudget.Id);
                budgetLIs.add(budgetLI);
            }
            gFRS_Util_NoShare.saveLockedBudgetLIs(budgetLIs);

        } catch (Exception err) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(err)));
        }
    }
}