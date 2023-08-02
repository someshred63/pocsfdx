/************************************************************
*  @author: Michal Zaganczyk (michal.zaganczyk@contractors.roche.com)
*  @author: James Hou (hou.james-chung@gene.com)
*  Date: 2013-5-7
*  Description: For the Add Insight, View and Edit pages in Market Insights. This controls the individual Insight record.
*  
*  Modification History
*  Date        Name        Description
*  2013-6-12   James Hou   Lucentis Diagnosis Code Fix (Mapping values)
*  2013-10-21  James Hou   Onboarding Gazyva (GA101), Actemra SubQ, Perjeta Neo for IFRM and BFRMs
*  2013-12-12  James Hou   Onboarding Xolair CIU, minor formatting
*  2014-8-04   James hou   Product and ICD9 mappings are now configurable
*            
*************************************************************/
public with sharing class GNE_FRM_Market_Insights_EdCr_Ctrlr {
    
    /**
     * User context info class (to have both role and monitor privilege in one place). 
     * This class could be moved to the util class and reused instead of implementing the "isMonitor" 
     * property in all of the other controllers.
     */
    public class FRMUserContextInfo {
        
        /**
         * Flag indicating that current user is a FRM Monitor.
         */
        public Boolean isMonitor {get; private set;}
        
        /**
         * Role name of the current user.
         */
        public String roleName {get; private set;}
        
        /**
         * Constructor. Initializes properties.
         */
        public FRMUserContextInfo() {
            this.isMonitor = GNE_FRM_Market_Insights_Util.checkMonitorStatus(UserInfo.getUserId());
            this.roleName = GNE_SFA2_Util.getUserApplicationContext().Role_gne__c;
            this.roleName = (null == this.roleName) ? '' : this.roleName;
        }
    }
    
    /**
     * Enum with availability mode values used to distinguish between different modes of access.
     */
    private enum AvailabilityModeEnum { CREATE, EDIT, VIEW }
    
    /**
     * Name of the URL parameter used to pass value of the Market Insight record Id.
     */
    private final static String MARKET_INSIGHT_RECORD_ID_URL_PARAM_NAME = 'id';
    
    /**
     * Name of the URL parameter used to pass value determining the availability mode.
     */
    private final static String AVAILABILITY_MODE_URL_PARAM_NAME = 'mode';

    /**
     * Complete set of the current known FRM teams used for constructing lists
     */
    private final static Set<String> knownFRMTeams = new Set<String>{'AFRM','BFRM','RFRM','IFRM','EFRM','GFRM','PFRM','NFRM','RESPFRM'};
    
    /********************************************** Fields and properties *********************************************/
    
    private AvailabilityModeEnum availabilityMode;
    
    /**
     * Stores the current MarketInsight record.
     */
    public Market_Insight_gne__c marketInsight {get; private set;}
    
    /**
     * Stores the list of Case objects (wrapped), the elements are the Cases already assigned to current MarketInsight record.
     */
    public GNE_FRM_Market_Insights_Case_Assoc_Util.MarketInsightCaseAssociations caseAssociations {get; private set;}
    
    /**
     * Stores an index of element from the above list used to unassign Case from current MarketInsight record.
     */
    public Integer indexOfAssignedCaseToRemove {get; set;}
    
    /**
     * Stores a list of Case records, the elements are the Cases which are the candidates to be assigned 
     * to current MarketInsight record (from search result).
     */
    public List<Case> foundToAssignCases {get; private set;}
    
    /**
     * Stores the Case number to find by the Case search dialog. 
     */
    public String caseNumberToFind {get; set;}
    
    /**
     * Stores the list of products available to select by current user.
     */
    public List<SelectOption> availableProducts {get; private set;}
    
    /**
     * Stores the selected product (from the available to select by current user).
     */
    public String selectedProduct {get{return selectedProduct;} set{this.selectedProduct=value;}}
    
    /**
     * Stores the selected primary diagnosis (from the available to select - for product selected currently).
     */
    public String selectedPrimaryDiagnosis {get; set;}
    
    /**
     * Stores the selected secondary diagnosis (from the available to select - for product selected currently).
     */
    public String selectedSecondaryDiagnosis {get; set;}
    
    /**
     * Stores the selected tertiary diagnosis (from the available to select - for product selected currently).
     */
    public String selectedTertiaryDiagnosis {get; set;}

    /**
     * Stores product mapping of complete list diagnosis code for this FRM.
     */
    public Map<String, List<String>> completeProductCodes {get; private set;}

    /**
     * Stores the selected insight type (from the available to select).
     */
    public String selectedInsightType {get; set;}
    
    /**
     * Stores the selected issue resolution state (from the available to select).
     */
    public String selectedIssueResolutionState {get; set;}

    /**
     * Stores the theme field for decoding back on the VF page (for the jquery multiselect).
     */
    public String previouslySelectedThemes {get; set;}
    
    /**
     * Stores the guidance document URL to be hosted externally
     */
    public String guidanceURL {get; set;}
    
    /**
     * Stores the complete list of Themes, as a string, available in a custom setting
     */
    public String availableThemes {get; set;}
    
    /**
     * Stores the current user info wrapped into an object.
     */
    public final FRMUserContextInfo currentUser {get; private set;}
    
    /**
     * Constructor (initializes fields and properties).
     */
    public GNE_FRM_Market_Insights_EdCr_Ctrlr() {
        this.currentUser = new FRMUserContextInfo();
        this.caseAssociations = new GNE_FRM_Market_Insights_Case_Assoc_Util.MarketInsightCaseAssociations();
        this.trendSearch = new GNE_FRM_Market_Insights_Trends_Search();
        /* Custom Settings */
        this.fetchGuidanceURL();
        this.fetchAvailableThemes();
        /* Available products (depend on user role or currentContext) */
        this.availableProducts = new List<SelectOption>();
        this.populateAvailableProducts();
        /* Case search */
        this.foundToAssignCases = new List<Case>();
        this.indexOfAssignedCaseToRemove = -1;
        this.caseNumberToFind = '';
        /* Data initialization */
        this.initialize();
    }
    
    /**
     * Initialization of data and mode properties.
     */
    private void initialize() {
        /* Detect if the Id of a record was passed in URL, has effect on edit mode also */
        Map<String, String> urlParams = ApexPages.currentPage().getParameters();
        String recordIdUrlParamValue = urlParams.get(MARKET_INSIGHT_RECORD_ID_URL_PARAM_NAME);
        if (null == recordIdUrlParamValue) {
            this.availabilityMode = AvailabilityModeEnum.CREATE;
        } else {
            String availabilityModeUrlParamValue = urlParams.get(AVAILABILITY_MODE_URL_PARAM_NAME);
            if ('edit' == availabilityModeUrlParamValue) {
                this.availabilityMode = AvailabilityModeEnum.EDIT;
            } else if ('view' == availabilityModeUrlParamValue) {
                this.availabilityMode = AvailabilityModeEnum.VIEW;
            } else {
                this.availabilityMode = AvailabilityModeEnum.EDIT;
            }
        }
        /* In create mode create a new instance of Insight object to insert during save, 
           in edit or view mode load an existing Insight object and Case associations */
        if (this.availabilityMode == AvailabilityModeEnum.CREATE) {
            this.marketInsight = new Market_Insight_gne__c();
        } else if (this.availabilityMode == AvailabilityModeEnum.EDIT || this.availabilityMode == AvailabilityModeEnum.VIEW) {
            this.loadMarketInsight(recordIdUrlParamValue);
        }
    }
    
    /**
     * Fetches the existing Market Insight record.
     * @param marketInsightId Id of the Market Insight record to load.
     */
    private void loadMarketInsight(String marketInsightId) {
        this.marketInsight = [
            SELECT
                Id,
                Name,
                Status_gne__c,
                Topic_gne__c,
                Category_gne__c,
                Sub_Category_gne__c,
                Product_gne__c,
                Issue_Resolution_gne__c,
                Issue_Resolution_Date_gne__c,
                Type_gne__c,
                Observation_gne__c,
                Account_City_gne__c,
                Account_State_gne__c,
                Account_Zip_gne__c,
                Account_Manager_gne__c,
                Patients_Affected_gne__c,
                Primary_Diagnosis_gne__c,
                X3rd_Degree_Verification_gne__c,
                Primary_Payer_gne__c,
                Segment_Type_gne__c,
                Benefit_Type_gne__c,
                Benefit_Type_Secondary_gne__c,
                Reimbursement_Scenario_gne__c,
                Secondary_Payer_gne__c,
                Secondary_Diagnosis_gne__c,
                Tertiary_Diagnosis_gne__c,
                Other_Payer_gne__c,
                Denial_Appealed_gne__c,
                Appeal_Outcome_gne__c,
                Peer_to_Peer_Executed_gne__c,
                Contacted_PSR_gne__c,
                Insight_Submitted_Date_gne__c,
                Specialty_Pharmacy_Name_gne__c,
                Role_gne__c,
                Indication_gne__c,
                Owner.Name,
                CreatedBy.Name,
                Account_gne__c,
                Other_Payer_Indicated_gne__c,
                Theme_Container_gne__c,
                Known_Trend_gne__c,
                Known_Trend_gne__r.Name,
                Known_Trend_gne__r.Trend_Name_gne__c
            FROM
                Market_Insight_gne__c
            WHERE
                Id = :marketInsightId
            LIMIT 1
        ];
        /* Assign values from the record for those fields which are bound to controller properties rather than to record directly */
        this.selectedProduct = this.marketInsight.Product_gne__c;
        this.selectedPrimaryDiagnosis = this.marketInsight.Primary_Diagnosis_gne__c;
        this.selectedSecondaryDiagnosis = this.marketInsight.Secondary_Diagnosis_gne__c;
        this.selectedTertiaryDiagnosis = this.marketInsight.Tertiary_Diagnosis_gne__c;
        this.selectedInsightType = this.marketInsight.Type_gne__c;
        this.selectedIssueResolutionState = this.marketInsight.Issue_Resolution_gne__c;
        /* Load jquery multiselect component */
        this.previouslySelectedThemes = this.marketInsight.Theme_Container_gne__c;
        /* Load case associations */
        this.caseAssociations.load(this.marketInsight.Id);
    }
    
    /**
     * Populates the available products based on the current user's role or current context if exists.
     */
    private void populateAvailableProducts() {
        /* Grab current context of the Role, based on existence of the market insight record */
        Map<String, String> urlParams = ApexPages.currentPage().getParameters();
        String recordIdUrlParamValue = urlParams.get(MARKET_INSIGHT_RECORD_ID_URL_PARAM_NAME);
        String insightRoleCheck = (recordIdUrlParamValue!=null) ? [SELECT 
                                                                        Role_gne__c 
                                                                   FROM 
                                                                        Market_Insight_gne__c 
                                                                   WHERE 
                                                                        Id =: recordIdUrlParamValue
                                                                   LIMIT 1].Role_gne__c 
                                                                 : null;
        String currentContext = (insightRoleCheck==null) ? currentUser.roleName : insightRoleCheck;
        
        
        if (currentContext!=null) {
            fetchProductsByTeam(currentContext);
        } else {
            this.availableProducts.remove(0);
            this.availableProducts.add(new SelectOption('', 'No Products Aligned'));
        }
        /* Default to the first product if they only have one */
        if (this.availableProducts.size()==2 && this.marketInsight.Product_gne__c==null)
            this.selectedProduct = this.availableProducts[1].getValue();

        this.completeProductCodes = GNE_FRM_Market_Insights_Util.getCompleteProductCodesMap(this.availableProducts);            
    }

    /**
     *  Defines the available products select option list.
     *  @param eitherRoleOrTeamName: constructed by either currentUser.roleName or an insightRoleCheck (cross team edits)
     */
    private void fetchProductsByTeam(String eitherRoleOrTeamName) {
        String team;
        for (String knownTeam : knownFRMTeams) {
            if (eitherRoleOrTeamName.contains(knownTeam)) {
                team = knownTeam;
            }
        }
        // Null value, differs slightly between teams
        if (team=='BFRM') {
            this.availableProducts.add(new SelectOption('', '--Select One--'));
        } else {
            this.availableProducts.add(new SelectOption('', '--None--'));
        }
        // Construct their products
        for (String product : GNE_FRM_Market_Insights_Util.getFRMProducts(team)) {
            this.availableProducts.add(new SelectOption(product, product));
        }
    }
    
    /************************************************* Action handlers ************************************************/
    
    /**
     * Handler for "Save" action in dark blue nav.
     */
    public PageReference save() {
        try {
            this.saveMarketInsight(null, true);
        } catch (Exception ex) {
            ApexPages.addMessages(ex);
            /* DO NOT redirect on error */
            return null;
        }
        String recordId = ApexPages.currentPage().getParameters().get('id');
        PageReference pageRef = new PageReference('/' + recordId);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    /**
     * Handler for "Cancel" action in dark blue nav.
     */
    public PageReference cancel() {
        String retUrl = ApexPages.currentPage().getParameters().get('retUrl');
        PageReference pageRef;
        if (retUrl != null) {
            pageRef = new PageReference(retUrl);
        } else {
            pageRef = Page.GNE_FRM_Market_Insights_MyInsights;
        }
        pageRef.setRedirect(true);
        return pageRef;
    }
    /**
     * Handler for "Delete" action in dark blue nav. Only available for Insights in Draft status
     */
    public PageReference deleteInsight() {
        delete this.marketInsight;
        String retUrl = ApexPages.currentPage().getParameters().get('retUrl');
        PageReference pageRef;
        if (retUrl.contains('GNE_FRM_Market')) {
            pageRef = new PageReference(retUrl);
        } else {
            pageRef = Page.GNE_FRM_Market_Insights_MyInsights;
        }
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    /**
     * Handler for Status changes. JS from page will feed this utility function.
     *
     * @param insightStatus will decide which status this will be saved with
     * @param redirect is only used for restricting a redirect from Add Insight page
     */
    public PageReference setInsightLifecycle() {
        String insightStatus = Apexpages.currentPage().getParameters().get('actionFunctionStatusValue');
        String redirect = Apexpages.currentPage().getParameters().get('actionFunctionRedirString');
            
        if (insightStatus != 'Draft' && failedRequiredFieldsCheck()) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'All Required Fields have not been entered.');
            ApexPages.addMessage(msg);
            /* DO NOT redirect on error */
            return null;
        } else if (marketInsight.Primary_Payer_gne__c != null || marketInsight.Secondary_Payer_gne__c != null) {
        	 List<Id> payersIds = new List<Id>();
        	 if (marketInsight.Primary_Payer_gne__c != null) {
        	 	payersIds.add(marketInsight.Primary_Payer_gne__c);
        	 }
        	 if (marketInsight.Secondary_Payer_gne__c != null) {
        	 	payersIds.add(marketInsight.Secondary_Payer_gne__c);
        	 }
        	 List<Account> payers = new InsightHelper().queryPayers(payersIds);
        	 for (Account payer : payers) {
        	 	if(payer.Recordtype.Name != 'MCO_vod') {
		        	ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'The Payer you selected does not have a payer account type, please select a payer, using the searchable list.');
		            ApexPages.addMessage(msg);
		            /* DO NOT redirect on error */
		            return null;
        	 	}
        	 }
        } 
        try {
            this.saveMarketInsight(insightStatus, true);
        } catch (Exception ex) {
            ApexPages.addMessages(ex);
            /* DO NOT redirect on error */
            return null;
        }
        /* Redirect based on page Parameters explicitly refusing a redirect*/
        if (insightStatus=='Draft' && redirect=='No') {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Info, 'Market Insight Draft has been successfully saved with Insight ID: '+[select Name from Market_Insight_gne__c where Id =: this.marketInsight.id].Name);
            ApexPages.addMessage(msg);
            return null;
        } else {
            PageReference pageRef = new PageReference('/' + this.marketInsight.id);
            pageRef.setRedirect(true);
            return pageRef; 
        }
    }
     
    /**
     * Handler for "Remove case association" action.
     */
    public PageReference removeInsightCaseAction() {
        this.unassociateCase();
        return null;
    }
    
    /**
     * Handler for "Search" action on Case Search popup dialog.
     */
    public PageReference findCasesToAssignAction() {
        this.findCasesToAssign();
        return null;
    }
    
    /**
     * Handler for "Assign" action on Case Search popup dialog.
     */
    public PageReference assignFoundCasesAction() {
        this.assignFoundCases();
        return null;
    }
    
    /**
     * Handler for "Cancel" action on Case Search popup dialog.
     */
    public PageReference cancelAssignFoundCasesAction() {
        this.clearCaseSearch();
        return null;
    }
    
    /************************************************ Public methods **************************************************/

    public List<SelectOption> getProducts() {
        return this.availableProducts;
    }
    
    public static Boolean getIsMonitor() {
        return GNE_FRM_Market_Insights_Util.checkMonitorStatus(UserInfo.getUserId());
    }
    
    /**
     * Force setter for selectedProduct - was experiencing intermittent issues with get-set
     */
    public void manualSetSelectedProduct() {
        String incomingProductValue = Apexpages.currentPage().getParameters().get('actionFunctionProductValue');
        this.selectedProduct = incomingProductValue;
    }
    
    /**
     * Generate a list of primary diagnosis codes for on-label products based off values from the genentech-access.com website
     * This is duplicated on the page for most products (Primary Diagnosis and Secondary Diagnosis) but are collected in
     * saveMarketInsightRecord() to two different fields.
     */
    public List<SelectOption> getAvailablePrimaryDiagnoses() {
        List<SelectOption> result = new List<SelectOption>();
        
        result.add(new SelectOption('', '--None--'));
        List<String> diagnosisCodes = new List<String>(filterProductCodesFor(this.selectedProduct));

        if (!diagnosisCodes.isEmpty()) {
            for (String code : diagnosisCodes) {
                result.add(new SelectOption(code, code));
            }
        }
        
        if(diagnosisCodes.isEmpty()) {
            result[0].setDisabled(true);
        }
        return result;
    }
    
    /**
     * Generate list of secondary diagnoses - for GA-101 there are no secondary diagnoses, for other products this is the same list as primary diagnoses
     */
    public List<SelectOption> getAvailableSecondaryDiagnoses() {
        List<SelectOption> result = new List<SelectOption>();
        if (this.selectedProduct == 'Gazyva' || this.selectedProduct == 'Actemra SC') {
            result.add(new SelectOption('', '--None--'));
            result[0].setDisabled(true);
        } else {
            result = getAvailablePrimaryDiagnoses();
        }
        return result;
    }
    
    /**
     * Generate a completely different list for Lucentis. Context driven see populateAvailableProducts()
     */
    public List<SelectOption> getAvailableSecondaryLucentisDiagnoses() {
        List<SelectOption> result = new List<SelectOption>();
        result.add(new SelectOption('', '--None--'));

        if (this.selectedPrimaryDiagnosis == '362.07' && this.selectedProduct == 'Lucentis') {
            result.add(new SelectOption('250.50', '250.50'));
            result.add(new SelectOption('250.51', '250.51'));
            result.add(new SelectOption('250.52', '250.52'));
            result.add(new SelectOption('250.53', '250.53'));
        } else if (this.selectedPrimaryDiagnosis == '362.83' && this.selectedProduct == 'Lucentis') {
            result.add(new SelectOption('362.35','362.35'));
            result.add(new SelectOption('362.36','362.36'));
        } else if (this.selectedPrimaryDiagnosis == 'H35.81' && this.selectedProduct == 'Lucentis') {
            result.add(new SelectOption('H34.811','H34.811'));
            result.add(new SelectOption('H34.812','H34.812'));
            result.add(new SelectOption('H34.813','H34.813'));
            result.add(new SelectOption('H34.819','H34.819'));
            result.add(new SelectOption('H34.831','H34.831'));
            result.add(new SelectOption('H34.832','H34.832'));
            result.add(new SelectOption('H34.833','H34.833'));
            result.add(new SelectOption('H34.839','H34.839'));
        } else {
            // No codes
        }
        return result;
    }
    
    /**
     * Generate a completely different list for Lucentis. Context driven see populateAvailableProducts()
     */
    public List<SelectOption> getAvailableTertiaryLucentisDiagnoses() {
        List<SelectOption> result = new List<SelectOption>();
        result.add(new SelectOption('', '--None--'));

        if (this.selectedPrimaryDiagnosis == '362.07' && this.selectedProduct == 'Lucentis') {
            result.add(new SelectOption('362.01', '362.01'));
            result.add(new SelectOption('362.02', '362.02'));
            result.add(new SelectOption('362.03', '362.03'));
            result.add(new SelectOption('362.04', '362.04'));
            result.add(new SelectOption('362.05', '362.05'));
            result.add(new SelectOption('362.06', '362.06'));
        } else {
            // No Codes
        }
        return result;
    }
    
    /**
     * Account related field re-render. Fields are read only and derived from the Account.
     * JH Note: There are some discrepancies in Gene SFDC Account Data, i.e. Addresses are missing
     * and sometimes certain RecordTypes do not have a Main_Address_gne__c relation.
     *
     * Future MI release may need solution to manage mishandled account data rather than just blanking out.
     */
    public void fetchAccountRelatedFields() {
        /* Assure that old values are cleared when field is blanked on page*/
        if (this.marketInsight.Account_gne__c == null) {
            this.marketInsight.Account_City_gne__c = '';
            this.marketInsight.Account_State_gne__c = '';
            this.marketInsight.Account_Zip_gne__c = '';
            return;
        } else {
        	if(String.isNotBlank(this.marketInsight.Account_gne__c)) {
	        	List<Account> accounts = [
	                SELECT 
	                    Account.Main_Address_gne__r.City_vod__c,
	                    Account.Main_Address_gne__r.State_vod__c, 
	                    Account.Main_Address_gne__r.Zip_vod__c
	                FROM 
	                    Account 
	                WHERE 
	                    Id =: this.marketInsight.Account_gne__c
	            ];
	            if (!accounts.isEmpty()) {
		            this.marketInsight.Account_City_gne__c = accounts.get(0).Main_Address_gne__r.City_vod__c==null ? '' : accounts.get(0).Main_Address_gne__r.City_vod__c;
		            this.marketInsight.Account_State_gne__c = accounts.get(0).Main_Address_gne__r.State_vod__c==null ? '' : accounts.get(0).Main_Address_gne__r.State_vod__c;
		            this.marketInsight.Account_Zip_gne__c = accounts.get(0).Main_Address_gne__r.Zip_vod__c==null ? '' : accounts.get(0).Main_Address_gne__r.Zip_vod__c;
	            }
        	}
        }
    }
    
    public List<SelectOption> getAvailableInsightTypes() {
        return getSelectOptionsFromPicklistField(Market_Insight_gne__c.Type_gne__c);
    }
    
    public List<SelectOption> getAvailableIssueResolutions() {
        return getSelectOptionsFromPicklistField(Market_Insight_gne__c.Issue_Resolution_gne__c);
    }
    
    /************************************************ Non-public methods **********************************************/
    
    private static List<SelectOption> getSelectOptionsFromPicklistField(Schema.SObjectField sof) {
        return getSelectOptionsFromPicklistFieldDescribe(sof.getDescribe());
    }
    
    private static List<SelectOption> getSelectOptionsFromPicklistFieldDescribe(Schema.DescribeFieldResult dfr) {
        return getSelectOptionsFromPicklistEntries(dfr.getPicklistValues());
    }
    
    private static List<SelectOption> getSelectOptionsFromPicklistEntries(List<Schema.PicklistEntry> picklistEntries) {
        List<SelectOption> result = new List<SelectOption>();
        for (Schema.PicklistEntry entry : picklistEntries) {
            result.add(new SelectOption(entry.getValue(), entry.getLabel()));
        }
        return result;
    }
    
    /**
     * Works in conjunction with the multiselect plugin found on edit-create. Themes are created from its own custom setting.
     */
    private String fetchAvailableThemes() {
        List<String> miStringList = new List<String>();
        
        for (GNE_FRM_Market_Insights_Themes__c miThemes : GNE_FRM_Market_Insights_Themes__c.getall().values()) {
            miStringList.add(miThemes.Theme_Value__c);
        }
        miStringList.sort();
        availableThemes = String.join(miStringList, ';');
        return availableThemes;
    }
    
    /**
     * Free Text Guidance Document URL - from the generic MI Custom Setting object.
     */
    private void fetchGuidanceURL() {
        guidanceURL = GNE_FRM_Market_Insights_Util.getGuidanceURL();
    }

    /**
     *  TODO
     */
    private List<String> filterProductCodesFor(String selectedProduct) {
        List<String> filteredCodes = new List<String>();
        filteredCodes = completeProductCodes.get(selectedProduct);
        return filteredCodes;
    }    
    
    /******************************************* Case Search and Assign related ***************************************/
    
    /* MZ: We could move the Case search functionality to an individual class, just like we made for Trend Search */
    
    /**
     * Flag indicating that a Case search was performed.
     */
    public Boolean wasCaseSearchPerformed {get; private set;}
    
    /**
     * Flag indicating that a Case matching the search criteria was found.
     */
    public Boolean wasCaseFound {get; private set;}
    
    /**
     * Flag indicating that a Case matching the search criteria was found, but is already assigned to this Insight.
     */
    public Boolean wasCaseToFoundAlreadyAssigned {get; private set;}
    
    /**
     * Perform Case search.
     */
    private void findCasesToAssign() {
        /* Left padded with zeros to allow search for Case Number even if provided by the user without leading zeros. */
        String paddedCaseNumber = this.caseNumberToFind;
        if (String.isNotBlank(paddedCaseNumber))
            paddedCaseNumber = paddedCaseNumber.replaceAll('\\s','').leftPad(10).replace(' ', '0');
        Set<Id> alreadyAssignedCasesIds = new Set<Id>(this.caseAssociations.getRecordIds());
        this.foundToAssignCases.clear();
        List<Case> foundCaseRecords = [
            SELECT
                Id,
                CaseNumber,
                RecordType.Name,
                Product_gne__c,
                Practice_ID_gne__c,
                Practice_gne__r.Name
            FROM
                Case
            WHERE
                CaseNumber = :paddedCaseNumber
            LIMIT 1
        ];
        this.wasCaseSearchPerformed = true;
        this.wasCaseFound = false;
        this.wasCaseToFoundAlreadyAssigned = false;
        if (foundCaseRecords.size() > 0) {
            this.wasCaseFound = true;
            Case foundCaseRecord = foundCaseRecords[0];
            if (alreadyAssignedCasesIds.contains(foundCaseRecord.Id)) {
                this.wasCaseToFoundAlreadyAssigned = true;
            } else {
                this.foundToAssignCases.add(foundCaseRecord);
            }
        }
    }
    
    /**
     * Assign the Cases which are results of Case search to this Market Insight (add to collection only).
     */
    private void assignFoundCases() {
        this.caseAssociations.addAll(this.foundToAssignCases);
        this.clearCaseSearch();
    }
    
    /**
     * Resets the Case search (i.e. when closing the Case Search popup).
     */
    private void clearCaseSearch() {
        this.foundToAssignCases.clear();
        this.caseNumberToFind = '';
        this.wasCaseFound = false;
        this.wasCaseSearchPerformed = false;
        this.wasCaseToFoundAlreadyAssigned = false;
    }
    
    /*********************************************** Save Market Insight related **************************************/
    
    /**
     * Saves the current MarketInsight record and (optionally) associated records in an atomic/transactional manner.
     * Exception handlind should be done by the caller (thus the exception is catched, but re-thrown).
     *
     * @param status decides what status will the MarketInsight have.
     * @param updateCaseAssociations decides whether the MarketInsight case associations should be updated.
     */
    private void saveMarketInsight(String status, Boolean updateCaseAssociations) {
        Savepoint sp = Database.setSavepoint();
        try {
            this.saveMarketInsightRecord(status);
            if (updateCaseAssociations)
                this.saveCaseAssociations();
        } catch (Exception ex) {
            Database.rollback(sp);
            throw ex;
        }
    }
    
    /**
     * Saves the current MarketInsight record only.
     *
     * @param desiredStatus decides whether the MarketInsight is saved as a draft.
     */
    private void saveMarketInsightRecord(String desiredStatus) {
        /* Assign values to the record for those fields which are bound to controller properties rather than to record directly */
        this.marketInsight.Product_gne__c = this.selectedProduct;
        this.marketInsight.Primary_Diagnosis_gne__c = this.selectedPrimaryDiagnosis;
        this.marketInsight.Secondary_Diagnosis_gne__c = this.selectedSecondaryDiagnosis;
        this.marketInsight.Tertiary_Diagnosis_gne__c = this.selectedTertiaryDiagnosis;
        this.marketInsight.Type_gne__c = this.selectedInsightType;
        this.marketInsight.Issue_Resolution_gne__c = this.selectedIssueResolutionState;
        if (this.marketInsight.Issue_Resolution_gne__c == 'Closed' && 
            this.marketInsight.Issue_Resolution_Date_gne__c == null  &&
            desiredStatus != 'Draft')
        {
            this.marketInsight.Issue_Resolution_Date_gne__c = Date.today();
        }
        if (this.marketInsight.Role_gne__c==null) {
            String currentRecordRole;
            /* Not explicit in requirement(s), but safety catch if Managers also want to enter insights. OPS, however, cannot */
            if (this.currentUser.roleName.contains('FRM-Manager')) {
                currentRecordRole = this.currentUser.roleName.substringBefore('-');
            } else {
                currentRecordRole = this.currentUser.roleName;
            }
            this.marketInsight.Role_gne__c = currentRecordRole;
        }
        
        /* Apply dependent values */
        this.marketInsight.Master_Category_gne__c = String.join(new List<String>{
            this.marketInsight.Topic_gne__c, this.marketInsight.Category_gne__c, 
            this.marketInsight.Sub_Category_gne__c}, ' : ');
            
        /* Apply the joined multiselect value */
        this.marketInsight.Theme_Container_gne__c = Apexpages.currentPage().getParameters().get('actionFunctionMultiSelectString');

        /* Depending on the desired status */
        if ('Draft' == desiredStatus) {
            this.marketInsight.Status_gne__c = 'Draft';
        } else if ('Pending Review' == desiredStatus) {
            this.marketInsight.Status_gne__c = 'Pending Review';
            if (marketInsight.Insight_Submitted_Date_gne__c==null)
                this.marketInsight.Insight_Submitted_Date_gne__c = Date.today();
        } else if ('Monitoring' == desiredStatus) {
            this.marketInsight.Status_gne__c = 'Monitoring';
        } else if ('Trending' == desiredStatus) {
            this.marketInsight.Status_gne__c = 'Trending';
        } else if ('Archived' == desiredStatus) {
            this.marketInsight.Status_gne__c = 'Archived';
            if (marketInsight.Insight_Archived_Date_gne__c==null)
                this.marketInsight.Insight_Archived_Date_gne__c = Date.today();
        } else {
            // leave Status_gne__c field as it is
        }
        
        /* Do an insert/update finally */
        /*kozminsl: Dirty HACK - frm users has no longer visibility to payers accounts*/
        new InsightHelper().upsertRecord(this.marketInsight);
        //upsert this.marketInsight;
    }
    
    private without sharing class InsightHelper {
        public void upsertRecord(Market_Insight_gne__c marketInsight){
            upsert marketInsight;
        }
        
        public List<Account> queryPayers(List<Id> payersIds){
        	return [SELECT id, recordtype.Name FROM Account WHERE id IN :payersIds];
        }
    }
    
    /**
     * Required Fields for the all statuses outside of Draft mode.
     */
    private boolean failedRequiredFieldsCheck() {
        transient string tmpCategory = this.marketInsight.Category_gne__c;
        boolean failedCheck;
        
        /* Dependency check */
        transient boolean subCategoryCheck = (tmpCategory == 'Other' || tmpCategory == 'Fee Schedule Not Adjusted') ? false : this.marketInsight.Sub_Category_gne__c==null;
        /* Context Check for cross-team saving */
        transient string currentContext = (this.marketInsight.Role_gne__c==null) ? currentUser.roleName : this.marketInsight.Role_gne__c;
        
        if (
            this.marketInsight.Topic_gne__c==null ||
            this.marketInsight.Category_gne__c==null ||            
            this.selectedInsightType==null ||
            this.marketInsight.Account_gne__c==null ||
            (currentContext.contains('BFRM') && this.selectedProduct==null) ||
            subCategoryCheck
        ) {
            failedCheck = true;
        } else {
            failedCheck = false;
        }
        return failedCheck;
    }
    
    /**
     * Saves the CaseAssociation junction object records linking the Cases records to the current MarketInsight record.
     */
    private void saveCaseAssociations() {
        this.caseAssociations.save(this.marketInsight.Id);
    }
    
    /**
     * Deletes the association between current MarketInsight record and a Case record passed in the "indexOfCaseToRemove"
     * property. This operation is performed only in the controller - to perpetuate this state the "saveMarketInsight" 
     * method must be used.
     */
    private void unassociateCase() {
        if (this.indexOfAssignedCaseToRemove > -1 && this.indexOfAssignedCaseToRemove < this.caseAssociations.elements.size()) {
            this.caseAssociations.remove(this.indexOfAssignedCaseToRemove);
            this.indexOfAssignedCaseToRemove = -1;
        }
    }
    
    /****************************************** Trend Search related **************************************************/
    
    /**
     * Stores the reference to the Trend Search utility class, which will handle the search functionality.
     */
    public final GNE_FRM_Market_Insights_Trends_Search trendSearch {get; private set;}
    
    /**
     * Handler for the "Assign" action called from the Trend Search popup.
     */
    public PageReference assignToTrendAction() {
        /* Get the Id of the selected Trend record to assign the current Market Insight to. */
        String trendIdStr = ApexPages.currentPage().getParameters().get('selectedTrendId');
        if ((null != this.marketInsight) && (null != this.marketInsight.Id) && (null != trendIdStr)) {
            try {
                /* Call the assignment functionality from the utility class, can throw an exception (validation, data errors etc) */
                Id trendId = trendIdStr;
                Set<Id> marketInsightsIds = new Set<Id>{this.marketInsight.Id};
                GNE_FRM_Market_Insights_Trends_Util.assignMarketInsightsToTrend(marketInsightsIds, trendId);
                
                /* Redirect to the read-only layout on success */
                PageReference pr = new PageReference('/' + this.marketInsight.Id);
                pr.setRedirect(true);
                return pr;
            } catch (Exception ex) {
                /* Do not redirect, show error message only */
                ApexPages.addMessages(ex);
                return null;
            }
        } else {
            /* Handle missing request parameter error */
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Failed to assign Market Insight to a Trend. Market Insight Id or Trend Id were not passed.'));
        }
        return null;
    }
    
    /**
     * Executes Trend search by setting the properties and calling external class method.
     */
    public PageReference performTrendSearchAction() {
        this.trendSearch.searchMode = Integer.valueOf(ApexPages.currentPage().getParameters().get('trendSearchMode'));
        this.trendSearch.searchCriteria = ApexPages.currentPage().getParameters().get('trendSearchCriteria');
        this.trendSearch.rowsLimit = 5;
        this.trendSearch.performSearch();
        return null;
    }
    
    /**
     * Reset Trend search class.
     */
    public PageReference resetTrendSearchAction() {
        this.trendSearch.reset();
        return null;
    }
    
        
    @RemoteAction
    public static List<SObject> getRecords(String queryString) {
        return GNE_SFA2_Util.getDbWithoutSharingExecutor().executeQuery(queryString); 
    }
}