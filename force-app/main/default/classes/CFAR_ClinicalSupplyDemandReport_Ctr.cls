public with sharing class CFAR_ClinicalSupplyDemandReport_Ctr {
    public Boolean isError {get; set;}
    public String errorMessage {get; set;}
    public String selectedFilter {get;set;}
    public String filterName {get;set;}

    public String currentDateFromURL {get; set;}

    public List<String> selectedProducts {get;set;}
    public List<String> selectedStatuses {get;set;}
    public List<String> selectedConfiguration {get;set;}
    public List<String> selectedProtocols {get;set;}
    public List<String> selectedTrialTypes {get;set;}
    public List<String> selectedCtms {get;set;}
    public List<String> selectedTrials {get;set;}
    public List<String> selectedUnitTypes {get;set;}
    public List<String> selectedPiMembers {get;set;}
    public List<String> selectedCsms {get;set;}
    public Boolean isPanelVisible {get;private set;}
    public String searchParams {get;private set;}
    private List<SelectOption> trialStatuses;
    private List<SelectOption> configurations;
    @testVisible private List<SelectOption> trialTypes;
    @testVisible private List<SelectOption> unitTypes;

    @testVisible private List<SelectOption> wholeProductSelectOptions;
    private static List<CFAR_Product_gne__c> productNames;

    @testVisible private List<SelectOption> wholeProtocolSelectOptions;
    private static List<CFAR_Trial_gne__c> protocolNames; 

    @testVisible private List<SelectOption> wholePISelectOptions;
    private static List<CFAR_Contact_gne__c> piNames;    

    @testVisible private List<SelectOption> wholeConfigurationSelectOptions;
    private static List<CFAR_Molecule_Configuration_gne__c> configurationNames;     

    @testVisible private List<SelectOption> wholeCTMSSelectOptions;
    private static List<CFAR_Trial_gne__c> ctmsNames; 

    @testVisible private List<SelectOption> wholeTrialSelectOptions;
    private static List<CFAR_Trial_gne__c> trialNames;

    @testVisible private List<SelectOption> wholeCSMSelectOptions;
    private static List<CFAR_Trial_gne__c> csmNames;
    
    public CFAR_ClinicalSupplyDemandReport_Ctr(){
        isPanelVisible = false;
        initWholeProductSelectOptions();
        initWholeProtocolSelectOptions();
        initWholePISelectOptions();
        initWholeConfigurationSelectOptions();
        initWholeCTMSSelectOptions();
        initWholeTrialSelectOptions();
        initWholeCSMSelectOptions();
        if(Apexpages.currentpage().getparameters().get('currentDate') != null && Apexpages.currentpage().getparameters().get('currentDate') != ''){
            currentDateFromURL = Apexpages.currentpage().getparameters().get('currentDate');
        }
    }
    
    public Boolean isButtonVisible {
        get{
            if(selectedFilter != null && selectedFilter != '-- select filter --' && !isPanelVisible){
                return true;
            }else{
                return false;
            }
        }
        private set;
    }
	
	public List<CFAR_Contact_gne__c> getContactsSpecifiedRole (List<String> roles) {
		List<CFAR_Contact_gne__c> result = new List<CFAR_Contact_gne__c> ();
		result =  [
			SELECT Id, Search_Name__c, Role_Function_gne__c, Primary_Role_Function_gne__c, Tertiary_Role_Function_gne__c 
        	FROM CFAR_Contact_gne__c 
			WHERE Role_Function_gne__c IN :roles 
			OR Primary_Role_Function_gne__c IN :roles 
			OR Tertiary_Role_Function_gne__c IN :roles
		];
		return result;
	}

    public List<SelectOption> initWholeCSMSelectOptions() {
        wholeCSMSelectOptions = new List<SelectOption> ();
        List<String> roles = new List<String>{CFAR_TeamMemberHelper.ROLE_CLINICAL_PROGRAM_LEADER, CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_MANAGER, CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_ASSOCIATE, CFAR_TeamMemberHelper.ROLE_CLINICAL_ASSISTANT}; 
        Set<CFAR_Contact_gne__c> CSMs = new Set<CFAR_Contact_gne__c>();
        for(CFAR_Contact_gne__c contact : getContactsSpecifiedRole(roles)){
        	CSMs.add(contact);
        }
       
        for(CFAR_Contact_gne__c contact : CSMs){
        	wholeCSMSelectOptions.add(new SelectOption(contact.Search_Name__c, contact.Search_Name__c));
        }
       wholeCSMSelectOptions.sort();
      
        return wholeCSMSelectOptions;
    }

    public List<SelectOption> getCSMOptions1() {
        return CFAR_Utils.getThousandSelectOptions(wholeCSMSelectOptions, 1);
    }
    public List<SelectOption> getCSMOptions2() {
        return CFAR_Utils.getThousandSelectOptions(wholeCSMSelectOptions, 2);
    }
    public List<SelectOption> getCSMOptions3() {
        return CFAR_Utils.getThousandSelectOptions(wholeCSMSelectOptions, 3);
    }
    public List<SelectOption> getCSMOptions4() {
        return CFAR_Utils.getThousandSelectOptions(wholeCSMSelectOptions, 4);
    }

    public List<SelectOption> initWholePISelectOptions() {
        wholePISelectOptions = new List<SelectOption> ();
        Set<String> tempSet = new Set<String>();
        if (piNames == null) {

            piNames = [SELECT Id, First_Name_gne__c, Last_Name_gne__c, Middle_Initials_gne__c, Primary_Role_Function_gne__c
                FROM CFAR_Contact_gne__c
                WHERE Primary_Role_Function_gne__c = : CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR
                ORDER BY Last_Name_gne__c];
        }
        for (CFAR_Contact_gne__c pi : piNames) {

            String middleName = pi.Middle_Initials_gne__c != null ? pi.Middle_Initials_gne__c : '';
            String key = pi.id;
            String value = pi.Last_Name_gne__c + ', ' + pi.First_Name_gne__c + ' ' + middleName;
            if (tempSet.contains(value)) {
                continue;
            }
            tempSet.add(value);
            wholePISelectOptions.add(new SelectOption(key, value));
        }
        return wholePISelectOptions;
    }

    public List<SelectOption> getPIOptions1() {
        return CFAR_Utils.getThousandSelectOptions(wholePISelectOptions, 1);
    }
    public List<SelectOption> getPIOptions2() {
        return CFAR_Utils.getThousandSelectOptions(wholePISelectOptions, 2);
    }
    public List<SelectOption> getPIOptions3() {
        return CFAR_Utils.getThousandSelectOptions(wholePISelectOptions, 3);
    }
    public List<SelectOption> getPIOptions4() {
        return CFAR_Utils.getThousandSelectOptions(wholePISelectOptions, 4);
    } 

    public List<SelectOption> getUnitTypeOptions() {
        if(unitTypes == null){
            unitTypes = new List<SelectOption>();
            Set<String> tempSet = new Set<String>();
            for (CFAR_Molecule_Configuration_gne__c member : [
                SELECT Id, Configuration_gne__c, CFAR_Unit_Type_ref_gne__r.Name, CFAR_Unit_Type_ref_gne__c
                FROM CFAR_Molecule_Configuration_gne__c   
                WHERE Active_gne__c = true   
                AND CFAR_Unit_Type_ref_gne__r.Name != null
                ORDER BY CFAR_Unit_Type_ref_gne__r.Name
            ]) {
                String value = member.CFAR_Unit_Type_ref_gne__r.Name;
                String key = member.CFAR_Unit_Type_ref_gne__c;
                if(tempSet.contains(value)){
                    continue;
                }
                tempSet.add(value);
                unitTypes.add(new SelectOption(key, value));
            }
        }    
        return unitTypes;
    }

    public List<SelectOption> initWholeTrialSelectOptions() {
        wholeTrialSelectOptions = new List<SelectOption> ();
        Set<String> tempSet = new Set<String>();
        if (trialNames == null) {
            trialNames = [SELECT id, name
                FROM CFAR_Trial_gne__c
                ORDER BY name];
        }
        for (CFAR_Trial_gne__c trial : trialNames) {
            String value = trial.Name;
            String key = trial.id;
            if (tempSet.contains(value)) {
                continue;
            }
            tempSet.add(value);
            wholeTrialSelectOptions.add(new SelectOption(key, value));
        }
        return wholeTrialSelectOptions;
    }

    public List<SelectOption> getTrialOptions1() {
        return CFAR_Utils.getThousandSelectOptions(wholeTrialSelectOptions, 1);
    }
    public List<SelectOption> getTrialOptions2() {
        return CFAR_Utils.getThousandSelectOptions(wholeTrialSelectOptions, 2);
    }
    public List<SelectOption> getTrialOptions3() {
        return CFAR_Utils.getThousandSelectOptions(wholeTrialSelectOptions, 3);
    }
    public List<SelectOption> getTrialOptions4() {
        return CFAR_Utils.getThousandSelectOptions(wholeTrialSelectOptions, 4);
    }

    public List<SelectOption> initWholeCTMSSelectOptions() {
        wholeCTMSSelectOptions = new List<SelectOption> ();
        Set<String> tempSet = new Set<String>();
        if (ctmsNames == null) {
            ctmsNames = [SELECT CTMS_gne__c
                FROM CFAR_Trial_gne__c
                WHERE CTMS_gne__c != null
                ORDER BY CTMS_gne__c];
        }
        for (CFAR_Trial_gne__c ctms : ctmsNames) {
            String value = ctms.CTMS_gne__c;
            if (tempSet.contains(value)) {
                continue;
            }
            tempSet.add(value);
            wholeCTMSSelectOptions.add(new SelectOption(value, value));
        }
        return wholeCTMSSelectOptions;
    }

    public List<SelectOption> getCTMSOptions1() {
        return CFAR_Utils.getThousandSelectOptions(wholeCTMSSelectOptions, 1);
    }
    public List<SelectOption> getCTMSOptions2() {
        return CFAR_Utils.getThousandSelectOptions(wholeCTMSSelectOptions, 2);
    }
    public List<SelectOption> getCTMSOptions3() {
        return CFAR_Utils.getThousandSelectOptions(wholeCTMSSelectOptions, 3);
    }
    public List<SelectOption> getCTMSOptions4() {
        return CFAR_Utils.getThousandSelectOptions(wholeCTMSSelectOptions, 4);
    }
    
    public List<SelectOption> getTrialTypeOptions() {
        if(trialTypes == null){
            trialTypes = new List<SelectOption>();
            Set<String> tempSet = new Set<String>();
            for (CFAR_Trial_Type_gne__c member : [
                SELECT id, Name   
                FROM CFAR_Trial_Type_gne__c   
                ORDER BY Name 
            ]) {               
                String value = member.Name;
                if(tempSet.contains(value)){
                    continue;
                }
                tempSet.add(value);
                trialTypes.add(new SelectOption(value, value));
            }
        }   
        return trialTypes;
    }

    public List<SelectOption> initWholeProtocolSelectOptions() {
        wholeProtocolSelectOptions = new List<SelectOption> ();
        Set<String> tempSet = new Set<String>();
        if(protocolNames == null){

            protocolNames = [SELECT Other_Trial_gne_Id__c    
                FROM CFAR_Trial_gne__c   
                WHERE Other_Trial_gne_Id__c != null  
                ORDER BY Other_Trial_gne_Id__c];
        }
        for (CFAR_Trial_gne__c protocol : protocolNames) {
            String value = protocol.Other_Trial_gne_Id__c;
            if (tempSet.contains(value)) {
                continue;
            }
            tempSet.add(value);
            wholeProtocolSelectOptions.add(new SelectOption(value, value));
        }
        return wholeProtocolSelectOptions;
    }

    public List<SelectOption> getProtocolOptions1() {
        return CFAR_Utils.getThousandSelectOptions(wholeProtocolSelectOptions, 1);
    }
    public List<SelectOption> getProtocolOptions2() {
        return CFAR_Utils.getThousandSelectOptions(wholeProtocolSelectOptions, 2);
    }
    public List<SelectOption> getProtocolOptions3() {
        return CFAR_Utils.getThousandSelectOptions(wholeProtocolSelectOptions, 3);
    }
    public List<SelectOption> getProtocolOptions4() {
        return CFAR_Utils.getThousandSelectOptions(wholeProtocolSelectOptions, 4);
    }

    public List<SelectOption> getConfigurationsOptions() {
        if(configurations == null){
            configurations = new List<SelectOption>();
            Set<String> tempSet = new Set<String>();
            for (CFAR_Molecule_Configuration_gne__c member : [
                SELECT Id, Configuration_gne__c, CFAR_Unit_Type_ref_gne__r.Name
                FROM CFAR_Molecule_Configuration_gne__c   
                WHERE Active_gne__c = true   
                AND Configuration_gne__c != null
                ORDER BY Configuration_gne__c
            ]) {
                String value = member.Configuration_gne__c;
                if(tempSet.contains(value)){
                    continue;
                }
                tempSet.add(value);
                configurations.add(new SelectOption(value, value));
            }
        }
        return configurations;
    }

    public List<SelectOption> initWholeConfigurationSelectOptions() {
        wholeConfigurationSelectOptions = new List<SelectOption> ();
        Set<String> tempSet = new Set<String>();
        if (configurationNames == null) {

            configurationNames = [
                SELECT Id, Configuration_gne__c, CFAR_Unit_Type_ref_gne__r.Name
                FROM CFAR_Molecule_Configuration_gne__c
                WHERE Active_gne__c = true
                AND Configuration_gne__c != null
                ORDER BY Configuration_gne__c];
        }
        for (CFAR_Molecule_Configuration_gne__c configuration : configurationNames) {
            String value = configuration.Configuration_gne__c;
            if (tempSet.contains(value)) {
                continue;
            }
            tempSet.add(value);
            wholeConfigurationSelectOptions.add(new SelectOption(value, value));
        }
        return wholeConfigurationSelectOptions;
    }

    public List<SelectOption> getConfigurationOptions1() {
        return CFAR_Utils.getThousandSelectOptions(wholeConfigurationSelectOptions, 1);
    }
    public List<SelectOption> getConfigurationOptions2() {
        return CFAR_Utils.getThousandSelectOptions(wholeConfigurationSelectOptions, 2);
    }
    public List<SelectOption> getConfigurationOptions3() {
        return CFAR_Utils.getThousandSelectOptions(wholeConfigurationSelectOptions, 3);
    }
    public List<SelectOption> getConfigurationOptions4() {
        return CFAR_Utils.getThousandSelectOptions(wholeConfigurationSelectOptions, 4);
    }

    public List<SelectOption> initWholeProductSelectOptions() {
        wholeProductSelectOptions = new List<SelectOption> ();
        if(productNames == null){
            productNames = [SELECT Id, Generic_Name_gne__c, Name FROM CFAR_Product_gne__c WHERE Other_GNE_Agent_Active_gne__c = true ORDER BY Name];
        }
        for (CFAR_Product_gne__c product : productNames) {
            wholeProductSelectOptions.add(new SelectOption(product.Id, product.Generic_Name_gne__c));
        }
        return wholeProductSelectOptions;
    }

    public List<SelectOption> getProductsOptions1() {
        return CFAR_Utils.getThousandSelectOptions(wholeProductSelectOptions, 1);
    }
    public List<SelectOption> getProductsOptions2() {
        return CFAR_Utils.getThousandSelectOptions(wholeProductSelectOptions, 2);
    }
    public List<SelectOption> getProductsOptions3() {
        return CFAR_Utils.getThousandSelectOptions(wholeProductSelectOptions, 3);
    }
    public List<SelectOption> getProductsOptions4() {
        return CFAR_Utils.getThousandSelectOptions(wholeProductSelectOptions, 4);
    }

    public List<SelectOption> getTrialStatusOptions() {
        if(trialStatuses == null){
            trialStatuses = new List<SelectOption>();
            for (CFAR_Trial_Status_gne__c member : [
                SELECT Id, Name
                FROM CFAR_Trial_Status_gne__c   
                WHERE Active_gne__c = true  
                AND Name != 'Admin Fix'
                ORDER BY Name
            ]) {
                trialStatuses.add(new SelectOption(member.Id, member.Name));
            }
        }   
        return trialStatuses;
    }

    public PageReference generateReport() {
        searchParams = setSearchParams();
        return null;
    }

    @RemoteAction
    public static SupplyDemandReportData getSupplyDemandReportData(String searchParams) {
        return new SupplyDemandReportData(searchParams);
    }

    private static Set<Id> fetchTrialIds(List<CFAR_Cohort_Molecule_gne__c> cohortMoleculeList){
        Set<Id> trialIds = new Set<Id>();
        for(CFAR_Cohort_Molecule_gne__c cm : cohortMoleculeList){
            if(cm.Cohort_ref_gne__r.Trial_ref_gne__c != null){
                trialIds.add(cm.Cohort_ref_gne__r.Trial_ref_gne__c);
            }
        }
        return trialIds;
    }

    private String setSearchParams() {
        String searchParams = '';
        String products = createParameter(selectedProducts);
        searchParams += createSubCriteria(products, 'Molecule_Configuration_ref_gne__r.Product_gne__c');
        String statuses = createParameter(selectedStatuses);
        searchParams += createSubCriteria(statuses, 'Cohort_ref_gne__r.Trial_ref_gne__r.Trial_Status_ref_gne__c');
        String trialName = createParameter(selectedTrials);
        searchParams += createSubCriteria(trialName, 'Cohort_ref_gne__r.Trial_ref_gne__c');
        String configurations = createParameter(selectedConfiguration);
        searchParams += createSubCriteria(configurations, ' Molecule_Configuration_ref_gne__r.Configuration_gne__c');
        String contacts = createParameter(selectedCSMs);
        searchParams += createSubCriteria(contacts, 'Cohort_ref_gne__r.Trial_ref_gne__r.frm_Genentech_Primary_Contact_ref_gne__c');
        String ctms = createParameter(selectedCtms);
        searchParams += createSubCriteria(ctms, 'Cohort_ref_gne__r.Trial_ref_gne__r.CTMS_gne__c');
        String protocol = createParameter(selectedProtocols);
        searchParams += createSubCriteria(protocol, 'Cohort_ref_gne__r.Trial_ref_gne__r.Other_Trial_gne_Id__c');
        String trialTypes = createParameter(selectedTrialTypes);
        searchParams += createSubCriteria(trialTypes, 'Cohort_ref_gne__r.Trial_ref_gne__r.frm_Trial_Type_ref_gne__c');
        String unitTypes = createParameter(selectedUnitTypes);
        searchParams += createSubCriteria(unitTypes, 'Molecule_Configuration_ref_gne__r.CFAR_Unit_Type_ref_gne__c');
        String selectedPiMembers = createSubQuery(
                selectedPiMembers,
                CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR
        );
        searchParams += selectedPiMembers;
        return searchParams;
    }

    private String createSubCriteria(String input, String fieldApiname){
        String output = '';
        String escapedInput = String.escapeSingleQuotes(input);
        if(String.isNotBlank(escapedInput)){
            output += ' AND '+ fieldApiname + ' IN (';
            String [] table = escapedInput.split(';');
            for(String s : table){
                output += '\'' + s +'\',';
            }
            output = output.removeEnd(',');
            output += ')';
        }
        return output;
    }
    
    public PageReference cancelGenerateReport() {
        PageReference redirect = new PageReference('/apex/CFAR_TrialReportNav');
        return redirect;
    }
    
    public PageReference saveNewFilter(){
        if(!isPanelVisible){
            isPanelVisible = true;
        } else {
            isPanelVisible = false;
            Map<String, List<String>> stringToSelected = collectParameters();
            CFAR_FilterHelper.saveFilter(stringToSelected, filterName, null, CFAR_FilterHelper.RT_CLINICAL);
            List<CFAR_Filter_gne__c> filters = [ SELECT Id FROM CFAR_Filter_gne__c ORDER BY CreatedDate desc LIMIT 1];
            selectedfilter = filters[0].Id;
        }
        return null;
    }
    
    public PageReference saveFilter(){
        Map<String, List<String>> stringToSelected = collectParameters();
        String fName = [SELECT Name FROM CFAR_Filter_gne__c WHERE Id = : selectedFilter LIMIT 1 ].Name;
        CFAR_FilterHelper.saveFilter(stringToSelected, fName, selectedFilter, CFAR_FilterHelper.RT_CLINICAL);
        return null;
    }
    
    public PageReference cancelNewFilter(){
        isPanelVisible = false;       
        return null;
    }
    
    public PageReference deleteFilter(){
        Savepoint sp = Database.setSavepoint();
        try {
            CFAR_SecurityUtils.deleteRecord([SELECT Name FROM CFAR_Filter_gne__c WHERE Id = : selectedFilter]);
            selectedfilter = null;
            clearFilters();
        } catch (Exception e) {
            ApexPages.addMessages(e);
            Database.rollback(sp);
        }    
        return null;
    }

    public void clearFilters(){
        Map<String, List<String>> stringToSelected = collectParameters();
        for(List<String> ls : stringToSelected.values()){
            ls.clear();
        }
    }
    
    private Map<String, List<String>> collectParameters(){
        Map<String, List<String>> stringToSelected = new Map<String, List<String>> {
            'selectedProducts' => selectedProducts,
            'selectedStatuses' => selectedStatuses,
            'selectedConfiguration'  => selectedConfiguration,
            'selectedProtocols' => selectedProtocols,
            'selectedTrialTypes' => selectedTrialTypes,
            'selectedCtms' => selectedCtms,
            'selectedTrials' => selectedTrials,
            'selectedUnitTypes' => selectedUnitTypes,
            'selectedPiMembers' => selectedPiMembers,
            'selectedCsms' => selectedCsms

        };
        return stringToSelected;
    }
    
    
    public PageReference fechFilterOptions(){
        if(selectedFilter == null){
            return null;
        }
        Map<String, List<String>> stringToSelected = collectParameters();
        for(List<String> ls : stringToSelected.values()){
            ls.clear();
        }
        CFAR_Filter_gne__c filter = [
            SELECT Id, Name,
                (SELECT Id, Field_Name_gne__c, Value_gne__c, CFAR_Filter_ref_gne__c FROM CFAR_Filter_Options__r)
            FROM CFAR_Filter_gne__c
            WHERE Id = : selectedFilter           
        ];
        for(CFAR_Filter_Option_gne__c fr : filter.CFAR_Filter_Options__r){
            if(stringToSelected.get(fr.Field_Name_gne__c) != null){
                List<String> options = stringToSelected.get(fr.Field_Name_gne__c);
                options.add(fr.Value_gne__c);
                stringToSelected.put(fr.Field_Name_gne__c, options);
            }
        }
        return null;
    }
    
    public List<SelectOption> getFilterNames() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '-- select filter --'));
        
        List<CFAR_Filter_gne__c> filters = [
            SELECT Id, Name 
            FROM CFAR_Filter_gne__c
            WHERE RecordTypeId = :CFAR_FilterHelper.RT_CLINICAL
        ];
        for(CFAR_Filter_gne__c filter : filters) {
            options.add(new SelectOption(filter.Id, filter.Name));
        }
        return options;
    }
    
    private String createSubQuery(List<String> param, String role){
        String output = ' AND Cohort_ref_gne__r.Trial_ref_gne__c IN ( ';
        if(param == null || param.isEmpty()){
            return '';
        }
        Set<Id> tmIds = new Set<Id>();
        for(String s: param ){
            tmIds.add(s);
        }
        CFAR_Team_Member_gne__c [] memebers = [
            SELECT Id, CFAR_Trial_ref_gne__c, contact_address_ref_gne__c 
            FROM CFAR_Team_Member_gne__c 
            WHERE contact_address_ref_gne__r.CFAR_Contact_ref_gne__c IN : tmIds
                AND frm_function_role_gne__c = : role
                AND frm_Is_Inactive_gne__c = false
        ];
        if(memebers.isEmpty()){
            /* add dummy Id to return empy list of results */
            output += '\'aClS00000000000000\',';
        }
        for(CFAR_Team_Member_gne__c tm :memebers ){
            if(tm.CFAR_Trial_ref_gne__c != null){
                output += '\''+ tm.CFAR_Trial_ref_gne__c +'\',';
            }
        }
        output = output.removeEnd(',');
        output +=' )';
        return output;

    }

    private static String createParameter(List<String> input){
        if(input == null || input.isEmpty()) {
            return '';
        }
        String output = '';
        for(String s: input){
            output += s + ';';
        }
        if(String.isNotBlank(output)){
            output = output.removeEnd(';');
        }
        return output;
    }

    public class SupplyDemandReportData {
        public List<CFAR_Cohort_Molecule_gne__c> molecules {get;set;}
        public Map<Id, CFAR_Trial_gne__c> trials {get;set;}
        public SupplyDemandReportData(String searchParams) {
            molecules = CFAR_Cohort_Molecule_DAO.fetchCohortMoleculeForClinicalReport(searchParams);
            trials = CFAR_Cohort_Molecule_DAO.fetchTrialsForClinicalReport(fetchTrialIds(molecules));
        }
    }

}