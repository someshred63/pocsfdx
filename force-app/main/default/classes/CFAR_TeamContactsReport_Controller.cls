public with sharing class CFAR_TeamContactsReport_Controller {
    public Id selectedTrialId {get; set;}
	public String errorMessage {get; set;}
	public Boolean isError {get; set;}
    public Boolean isPanelVisible {get;private set;}
    public String filterName {get;set;}
    public String selectedFilter {get;set;}
    
    private static List<CFAR_Product_gne__c> products;
    public List<String> selectedProducts {get;set;}
    
    private static List<CFAR_Team_Member_gne__c> tmNames;
    public List<String> selectedTMNames {get;set;}
    
    private static List<CFAR_Contact_gne__c> CSMs;
    public List<String> selectedCSMs {get;set;}
    
    private static List<CFAR_Contact_gne__c> CSAs;
    public List<String> selectedCSAs {get;set;}

    private static List<CFAR_Parent_Organization_gne__c> parentOrganizations;
    public List<String> selectedParentOrganizations {get;set;}
    
    private static List<CFAR_Trial_Status_gne__c> studyStatus;
    public List<String> selectedStudyStatus {get;set;}
    
    private static List<CFAR_Institution_gne__c> institutions;
    public List<String> selectedInstitutions {get;set;}
    
    private static List<CFAR_Trial_gne__c> gstarsNo;
    public List<String> selectedGStarsNo {get;set;}
    
    private static List<String> tmStatus;
	public String selectedTMStatus {get;set;}
    public List<String> selectedTMStatusToList {get;set;}
    
    private static List<String> internalExternals;
    public String selectedInternalExternal {get;set;}
    public List<String> selectedInternalExternalToList {get;set;}
    
    private static List<CFAR_Trial_gne__c> ctmsNo;
    public List<String> selectedCtmsNo {get;set;}
    
    private static List<CFAR_Roles_To_Users_Mapping_gne__c> functionRoles;
    public List<String> selectedFunctionRoles {get;set;}
        
    public CFAR_TeamContactsReport_Controller(){
        isPanelVisible = false;
        initWholeTMNameSelectOptions();
        initCtmsSelectOptions();
        initGStarsSelectOptions();
        initWholeProductSelectOptions();
        initWholeCSMSelectOptions();
        initWholeCSASelectOptions();
        initWholeOrganizationSelectOptions();
        initWholeInstitutionSelectOptions();
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
    private List<SelectOption> wholeTMNameSelectOptions;
    private transient List<SelectOption> tmNameSelectOptions1;
    private transient List<SelectOption> tmNameSelectOptions2;
    private transient List<SelectOption> tmNameSelectOptions3;
    private transient List<SelectOption> tmNameSelectOptions4;
    private transient List<SelectOption> tmNameSelectOptions5;

    private List<SelectOption> wholeProductSelectOptions;
    private transient List<SelectOption> productsOptions1;
    private transient List<SelectOption> productsOptions2;
    private transient List<SelectOption> productsOptions3;
    private transient List<SelectOption> productsOptions4;

    private List<SelectOption> wholeCSMSelectOptions;
    private transient List<SelectOption> csmOptions1;
    private transient List<SelectOption> csmOptions2;
    private transient List<SelectOption> csmOptions3;
    private transient List<SelectOption> csmOptions4; 

    private List<SelectOption> wholeCSASelectOptions;
    private transient List<SelectOption> csaOptions1;
    private transient List<SelectOption> csaOptions2;
    private transient List<SelectOption> csaOptions3;
    private transient List<SelectOption> csaOptions4;  

    private List<SelectOption> wholeOrganizationSelectOptions;
    private transient List<SelectOption> organizationOptions1;
    private transient List<SelectOption> organizationOptions2;
    private transient List<SelectOption> organizationOptions3;
    private transient List<SelectOption> organizationOptions4;   

    private List<SelectOption> wholeInstitutionSelectOptions;
    private transient List<SelectOption> institutionOptions1;
    private transient List<SelectOption> institutionOptions2;
    private transient List<SelectOption> institutionOptions3;
    private transient List<SelectOption> institutionOptions4;             
    
    private List<SelectOption> ctmsSelectOptions;
    private static List<CFAR_Trial_gne__c> ctmsNames; 

    private List<SelectOption> gStarsSelectOptions;
    private static List<CFAR_Trial_gne__c> trialNames;
    
    
    public List<SelectOption> initWholeTMNameSelectOptions() {
    	wholeTMNameSelectOptions = new List<SelectOption> ();
    	Set<String> distinctNames = new Set<String> ();
        if(tmNames == null){
            tmNames = [SELECT Id, frm_Name_gne__c FROM CFAR_Team_Member_gne__c ORDER BY frm_Name_gne__c];
        }
	    for (CFAR_Team_Member_gne__c member : tmNames) {
	    	distinctNames.add(member.frm_Name_gne__c);
	    }
	    for (String name : distinctNames) {
	    	wholeTMNameSelectOptions.add(new SelectOption(name, name));
	    }
    	return wholeTMNameSelectOptions;
    }
    
    public List<SelectOption> getTmNameSelectOptions1() {
    	tmNameSelectOptions1 = CFAR_Utils.getThousandSelectOptions(wholeTMNameSelectOptions,1);
    	return tmNameSelectOptions1;
    }
    
    public List<SelectOption> getTmNameSelectOptions2() {
    	tmNameSelectOptions2 = CFAR_Utils.getThousandSelectOptions(wholeTMNameSelectOptions,2);
    	return tmNameSelectOptions2;
    }
    
    public List<SelectOption> getTmNameSelectOptions3() {
    	tmNameSelectOptions3 = CFAR_Utils.getThousandSelectOptions(wholeTMNameSelectOptions,3);
    	return tmNameSelectOptions3;
    }
    
    public List<SelectOption> getTmNameSelectOptions4() {
    	tmNameSelectOptions4 = CFAR_Utils.getThousandSelectOptions(wholeTMNameSelectOptions,4);
    	return tmNameSelectOptions4;
	    }
    
    public List<SelectOption> getTmNameSelectOptions5() {
    	tmNameSelectOptions5 = CFAR_Utils.getThousandSelectOptions(wholeTMNameSelectOptions,5);
    	return tmNameSelectOptions5;
    }
    
    public List<SelectOption> getTMStatusOptions() {
    	List<SelectOption> options = new List<SelectOption> ();
        if(tmStatus == null){
            tmStatus = new List<String> {'All', 'Active Only'};
        }
	    for (String name : tmStatus) {
	    	options.add(new SelectOption(name, name));
	    }
    	return options;
    }

    public List<SelectOption> initWholeCSMSelectOptions() {
        wholeCSMSelectOptions = new List<SelectOption> ();
        Set<String> distinctCSMs = new Set<String> ();
        if (CSMs == null) {
            CSMs = getContactsSpecifiedRole(CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_MANAGER);
        }
        for (CFAR_Contact_gne__c cms : CSMs) {
            distinctCSMs.add(cms.Search_Name__c);
        }
        for (String name : distinctCSMs) {
            wholeCSMSelectOptions.add(new SelectOption(name, name));
        }
        wholeCSMSelectOptions.sort();
        return wholeCSMSelectOptions;
    }

    public List<SelectOption> getCSMOptions1() {
        csmOptions1 = CFAR_Utils.getThousandSelectOptions(wholeCSMSelectOptions, 1);
        return csmOptions1;
    }
    public List<SelectOption> getCSMOptions2() {
        csmOptions2 = CFAR_Utils.getThousandSelectOptions(wholeCSMSelectOptions, 2);
        return csmOptions2;
    }
    public List<SelectOption> getCSMOptions3() {
        csmOptions3 = CFAR_Utils.getThousandSelectOptions(wholeCSMSelectOptions, 3);
        return csmOptions3;
    }
    public List<SelectOption> getCSMOptions4() {
        csmOptions4 = CFAR_Utils.getThousandSelectOptions(wholeCSMSelectOptions, 4);
        return csmOptions4;
    }

	public List<CFAR_Contact_gne__c> getContactsSpecifiedRole (String role) {
		List<CFAR_Contact_gne__c> result = new List<CFAR_Contact_gne__c> ();
		result =  [
			SELECT Id, Search_Name__c, Role_Function_gne__c, Primary_Role_Function_gne__c, Tertiary_Role_Function_gne__c 
        	FROM CFAR_Contact_gne__c 
			WHERE Role_Function_gne__c = :role 
			OR Primary_Role_Function_gne__c = :role 
			OR Tertiary_Role_Function_gne__c = :role
		];
		return result;
	}

    public List<SelectOption> initWholeCSASelectOptions() {
        wholeCSASelectOptions = new List<SelectOption> ();
        Set<String> distinctCSAs = new Set<String> ();
        if (CSAs == null) {
        	CSAs = getContactsSpecifiedRole(CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_ASSOCIATE);
        }
        for (CFAR_Contact_gne__c csa : CSAs) {
            wholeCSASelectOptions.add(new SelectOption(csa.Search_Name__c, csa.Search_Name__c));
        }
        return wholeCSASelectOptions;
    }

    public List<SelectOption> getCSAOptions1() {
        csaOptions1 = CFAR_Utils.getThousandSelectOptions(wholeCSASelectOptions, 1);
        return csaOptions1;
    }
    public List<SelectOption> getCSAOptions2() {
        csaOptions2 = CFAR_Utils.getThousandSelectOptions(wholeCSASelectOptions, 2);
        return csaOptions2;
    }
    public List<SelectOption> getCSAOptions3() {
        csaOptions3 = CFAR_Utils.getThousandSelectOptions(wholeCSASelectOptions, 3);
        return csaOptions3;
    }
    public List<SelectOption> getCSAOptions4() {
        csaOptions4 = CFAR_Utils.getThousandSelectOptions(wholeCSASelectOptions, 4);
        return csaOptions4;
    }

    public List<SelectOption> initWholeOrganizationSelectOptions() {
        wholeOrganizationSelectOptions = new List<SelectOption> ();
        Set<String> distinctParentOrganizations = new Set<String> ();
        if(parentOrganizations == null){
            parentOrganizations = [SELECT Id, Active_gne__c, Name FROM CFAR_Parent_Organization_gne__c WHERE Active_gne__c = true ORDER BY Name];
        }
        for (CFAR_Parent_Organization_gne__c parOrg : parentOrganizations) {
            distinctParentOrganizations.add(parOrg.Name);
        }
        for (String name : distinctParentOrganizations) {
            wholeOrganizationSelectOptions.add(new SelectOption(name, name));
        }
        return wholeOrganizationSelectOptions;
    }

    public List<SelectOption> getOrganizationOptions1() {
        organizationOptions1 = CFAR_Utils.getThousandSelectOptions(wholeOrganizationSelectOptions, 1);
        return organizationOptions1;
    }
    public List<SelectOption> getOrganizationOptions2() {
        organizationOptions2 = CFAR_Utils.getThousandSelectOptions(wholeOrganizationSelectOptions, 2);
        return organizationOptions2;
    }
    public List<SelectOption> getOrganizationOptions3() {
        organizationOptions3 = CFAR_Utils.getThousandSelectOptions(wholeOrganizationSelectOptions, 3);
        return organizationOptions3;
    }
    public List<SelectOption> getOrganizationOptions4() {
        organizationOptions4 = CFAR_Utils.getThousandSelectOptions(wholeOrganizationSelectOptions, 4);
        return organizationOptions4;
    }

    public List<SelectOption> getStudyStatusOptions() {
    	List<SelectOption> options = new List<SelectOption> ();
        if(studyStatus == null){
            studyStatus = [SELECT Id, Name FROM CFAR_Trial_Status_gne__c WHERE Active_gne__c = true AND Name != :CFAR_TeamMemberHelper.TRIAL_STATUS_ADMIN_FIX ORDER BY Name];
        }
	    for (CFAR_Trial_Status_gne__c st : studyStatus) {
	    	options.add(new SelectOption(st.Id, st.Name));
	    }
    	return options;
    }

    public List<SelectOption> initWholeInstitutionSelectOptions() {
        wholeInstitutionSelectOptions = new List<SelectOption> ();
        if(institutions == null){
            institutions = [SELECT Id, Active_gne__c, Name FROM CFAR_Institution_gne__c WHERE Active_gne__c = true ORDER BY Name];
        }
        for (CFAR_Institution_gne__c inst : institutions) {
            wholeInstitutionSelectOptions.add(new SelectOption(inst.Name, inst.Name));
        }
        return wholeInstitutionSelectOptions;
    }

    public List<SelectOption> getInstitutionOptions1() {
        institutionOptions1 = CFAR_Utils.getThousandSelectOptions(wholeInstitutionSelectOptions, 1);
        return institutionOptions1;
    }
    public List<SelectOption> getInstitutionOptions2() {
        institutionOptions2 = CFAR_Utils.getThousandSelectOptions(wholeInstitutionSelectOptions, 2);
        return institutionOptions2;
    }
    public List<SelectOption> getInstitutionOptions3() {
        institutionOptions3 = CFAR_Utils.getThousandSelectOptions(wholeInstitutionSelectOptions, 3);
        return institutionOptions3;
    }
    public List<SelectOption> getInstitutionOptions4() {
        institutionOptions4 = CFAR_Utils.getThousandSelectOptions(wholeInstitutionSelectOptions, 4);
        return institutionOptions4;
    }

    public List<SelectOption> initGStarsSelectOptions() {
        gstarsSelectOptions = new List<SelectOption> ();
        Set<String> tempSet = new Set<String>();
        if (trialNames == null) {
            trialNames = [SELECT id, name
                FROM CFAR_Trial_gne__c
                ORDER BY name];
        }
        for (CFAR_Trial_gne__c trial : trialNames) {
            String value = trial.Name;
            if (tempSet.contains(value)) {
                continue;
	    }
            tempSet.add(value);
            gstarsSelectOptions.add(new SelectOption(value, value));
    }
        return gstarsSelectOptions;
    }
    
    public List<SelectOption> getGStarsOptions1() {
        return CFAR_Utils.getThousandSelectOptions(gstarsSelectOptions, 1);
    }
    public List<SelectOption> getGStarsOptions2() {
        return CFAR_Utils.getThousandSelectOptions(gstarsSelectOptions, 2);
    }
    public List<SelectOption> getGStarsOptions3() {
        return CFAR_Utils.getThousandSelectOptions(gstarsSelectOptions, 3);
    }
    public List<SelectOption> getGStarsOptions4() {
        return CFAR_Utils.getThousandSelectOptions(gstarsSelectOptions, 4);
    }
    
    public List<SelectOption> initCtmsSelectOptions() {
        ctmsSelectOptions = new List<SelectOption> ();
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
            ctmsSelectOptions.add(new SelectOption(value, value));
        }
        return ctmsSelectOptions;
    }
    
    public List<SelectOption> getCTMSOptions1() {
        return CFAR_Utils.getThousandSelectOptions(ctmsSelectOptions, 1);
    }
    public List<SelectOption> getCTMSOptions2() {
        return CFAR_Utils.getThousandSelectOptions(ctmsSelectOptions, 2);
    }
    public List<SelectOption> getCTMSOptions3() {
        return CFAR_Utils.getThousandSelectOptions(ctmsSelectOptions, 3);
    }
    public List<SelectOption> getCTMSOptions4() {
        return CFAR_Utils.getThousandSelectOptions(ctmsSelectOptions, 4);
    }
    
    public List<SelectOption> getInternalExternalOptions() {
    	List<SelectOption> options = new List<SelectOption> ();
        if(internalExternals == null){
            internalExternals = new List<String> {'All', 'Internal', 'External'};
        }
	    for (String name : internalExternals) {
	    	options.add(new SelectOption(name, name));
	    }
    	return options;
    }
    
    public List<SelectOption> getFunctionRoleOptions() {
    	List<SelectOption> options = new List<SelectOption> ();
    	Set<String> distinctFunctionRoles = new Set<String> ();
        if(functionRoles == null){
            functionRoles =  CFAR_Roles_To_Users_Mapping_gne__c.getAll().values();
        }
        for (CFAR_Roles_To_Users_Mapping_gne__c role : functionRoles) {
            options.add(new SelectOption(role.Drop_down_value_gne__c,role.Drop_down_value_gne__c));
        }
        options.sort();
    	return options;

    }
    
    public List<SelectOption> initWholeProductSelectOptions() {
        wholeProductSelectOptions = new List<SelectOption> ();
        if(products == null){
            products = [SELECT Id, Name FROM CFAR_Product_gne__c ORDER BY Name];
        }
        for (CFAR_Product_gne__c product : products) {
            wholeProductSelectOptions.add(new SelectOption(product.Id, product.name));
        }
        return wholeProductSelectOptions;
    }

    public List<SelectOption> getProductsOptions1() {
        productsOptions1 = CFAR_Utils.getThousandSelectOptions(wholeProductSelectOptions, 1);
        return productsOptions1;
    }
    public List<SelectOption> getProductsOptions2() {
        productsOptions2 = CFAR_Utils.getThousandSelectOptions(wholeProductSelectOptions, 2);
        return productsOptions2;
    }
    public List<SelectOption> getProductsOptions3() {
        productsOptions3 = CFAR_Utils.getThousandSelectOptions(wholeProductSelectOptions, 3);
        return productsOptions3;
    }
    public List<SelectOption> getProductsOptions4() {
        productsOptions4 = CFAR_Utils.getThousandSelectOptions(wholeProductSelectOptions, 4);
        return productsOptions4;
    }
        
    public PageReference generateReport() {
        PageReference redirect = new PageReference('/apex/CFAR_TeamContactsReportXLS');
        redirect.getParameters().put('products',createParameter(selectedProducts)); 
        redirect.getParameters().put('tmNames',createParameter(selectedTMNames));
        redirect.getParameters().put('csm',createParameter(selectedCSMs));
        redirect.getParameters().put('csa',createParameter(selectedCSAs));
        redirect.getParameters().put('parentOrganizations',createParameter(selectedParentOrganizations));
        redirect.getParameters().put('studyStatus',createParameter(selectedStudyStatus));
        redirect.getParameters().put('institutions',createParameter(selectedInstitutions));
        redirect.getParameters().put('gstarsNo',createParameter(selectedGStarsNo));
        redirect.getParameters().put('ctmsNo',createParameter(selectedCtmsNo));
        redirect.getParameters().put('tmStatus',selectedTMStatus);
        redirect.getParameters().put('internalExternal',selectedInternalExternal);
        redirect.getParameters().put('functionRoles',createParameter(selectedFunctionRoles));
        return redirect;
    }
    
    public PageReference cancelGenerateReport() {
		PageReference redirect = new PageReference('/apex/CFAR_TrialReportNav');
		return redirect;
	}
    
    public PageReference clearFilters() {
        setStatusToList();
        Map<String, List<String>> stringToSelected = collectParameters();
        for(List<String> ls : stringToSelected.values()){
            ls.clear();
        }
        selectedTMStatus = 'All';
		selectedInternalExternal = 'All';
		isPanelVisible = false;
		isButtonVisible = false;
		selectedFilter = null;
        return null;
	}
    
    private static String createParameter(List<String> input){
        String output = '';
        if (input.size() != 0) {
	        for(String s: input){
	            output += s + ';';
	        }
	        if(String.isNotBlank(output)){
	            output = output.removeEnd(';');
	        }
        }
        return output;
    }

	public void setStatusToList () {
		selectedTMStatusToList = new List<String> {selectedTMStatus};
		selectedInternalExternalToList = new List<String> {selectedInternalExternal};
	}
	
	public void setListToStatus () {
		selectedTMStatus = selectedTMStatusToList != null || selectedTMStatusToList.size() > 0 ? selectedTMStatusToList[0] : 'All';
		selectedInternalExternal = selectedInternalExternalToList != null || selectedInternalExternalToList.size() > 0 ? selectedInternalExternalToList[0] : 'All';
	}

	public PageReference saveNewFilter(){
		setStatusToList();
        if(!isPanelVisible){
            isPanelVisible = true;
        } else {
            isPanelVisible = false;
            Map<String, List<String>> stringToSelected = collectParameters();
            CFAR_FilterHelper.saveFilter(stringToSelected, filterName, null, CFAR_FilterHelper.RT_TEAMCONTACTS);

            List<CFAR_Filter_gne__c> filters = [ SELECT Id FROM CFAR_Filter_gne__c ORDER BY CreatedDate desc LIMIT 1];
            selectedfilter = filters[0].Id;
        }
        return null;
    }
    
    public PageReference saveFilter(){
    	setStatusToList();
        Map<String, List<String>> stringToSelected = collectParameters();
        String fName = [SELECT Name FROM CFAR_Filter_gne__c WHERE Id = : selectedFilter LIMIT 1 ].Name;
        CFAR_FilterHelper.saveFilter(stringToSelected, fName, selectedFilter, CFAR_FilterHelper.RT_TEAMCONTACTS);
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
        } catch (Exception e) {
            ApexPages.addMessages(e);
            Database.rollback(sp);
        } 
        selectedfilter = null;
        clearFilters();
        isPanelVisible = false;   
        return null;
    }
    
    private Map<String, List<String>> collectParameters(){
        Map<String, List<String>> stringToSelected = new Map<String, List<String>> {
            'selectedProducts' => selectedProducts,
            'selectedTMNames' => selectedTMNames,
            'selectedCSMs'  => selectedCSMs,
            'selectedCSAs' => selectedCSAs,
            'selectedParentOrganizations' => selectedParentOrganizations,
            'selectedStudyStatus' => selectedStudyStatus,
            'selectedInstitutions' => selectedInstitutions,
            'selectedCtmsNo' => selectedCtmsNo,
            'selectedGStarsNo' => selectedGStarsNo,
            'selectedTMStatus' => selectedTMStatusToList,
            'selectedInternalExternal' => selectedInternalExternalToList,
            'selectedFunctionRoles' => selectedFunctionRoles
        };
        return stringToSelected;
    }
    
    
    public PageReference fetchFilterOptions(){
        if(selectedFilter == null){
            return null;
        }
        setStatusToList();
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
        setListToStatus();
        return null;
    }
    
    public List<SelectOption> getFilterNames() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '-- select filter --'));
        
        List<CFAR_Filter_gne__c> filters = [
            SELECT Id, Name 
            FROM CFAR_Filter_gne__c
            WHERE RecordTypeId = :CFAR_FilterHelper.RT_TEAMCONTACTS
        ];
        for(CFAR_Filter_gne__c filter : filters) {
            options.add(new SelectOption(filter.Id, filter.Name));
        }
        return options;
    }

}