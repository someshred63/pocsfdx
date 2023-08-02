global with sharing class CFAR_Administrator_Controller {
    final String fieldSet = '';

    public Boolean getshowOldWBS() {
        return Date.today() < Date.newInstance(2015, 1, 1);
    }

    public Boolean getRenderItAdminSection() {
        Boolean retVal = false;
        Profile prof = [select Name from Profile where Id = :UserInfo.getProfileId() limit 1][0];
        if (prof.Name.equals('GNE-CFAR-IT-Admin-New') || prof.Name.equals('System Administrator') || prof.Name.equals('GNE-SYS-Support-MedAffairs') || prof.Name.equals('GNE-MA-Support') || prof.Name.equals('GNE-CFAR-Admin-New')) {
            retVal = true;
        }
        return retVal;
    }

    public Boolean getRenderAdminSection() {
        Boolean retVal = false;
        Profile prof = [select Name from Profile where Id = :UserInfo.getProfileId() limit 1][0];
        if (prof.Name.equals('GNE-CFAR-Admin-New') || prof.Name.equals('System Administrator') || prof.Name.equals('GNE-SYS-Support-MedAffairs') || prof.Name.equals('GNE-MA-Support')) {
            retVal = true;
        }
        return retVal;
    }

    public String objectId { get; set; }
    public SObject s_object { get; set; }

    public Map<Id, CFAR_SObjectWrapper> objectMapWBS { get; set; }
    public List<CFAR_SObjectWrapper> objectListWBS { get; set; }

    public Map<Id, CFAR_SObjectWrapper> objectMapCostCenter { get; set; }
    public List<CFAR_SObjectWrapper> objectListCostCenter { get; set; }

    public Map<Id, CFAR_SObjectWrapper> objectMapRdt { get; set; }
    public List<CFAR_SObjectWrapper> objectListRdt { get; set; }

    public Map<Id, CFAR_SObjectWrapper> objectMapProduct { get; set; }
    public List<CFAR_SObjectWrapper> objectListProduct { get; set; }

    public Map<Id, CFAR_SObjectWrapper> objectMapTheme { get; set; }
    public List<CFAR_SObjectWrapper> objectListTheme { get; set; }

    public Map<Id, CFAR_SObjectWrapper> objectMapParentOrganization { get; set; }
    public List<CFAR_SObjectWrapper> objectListParentOrganization { get; set; }

    public Map<Id, CFAR_SObjectWrapper> objectMapInstitution { get; set; }
    public List<CFAR_SObjectWrapper> objectListInstitution { get; set; }

    public Map<Id, CFAR_SObjectWrapper> objectMapInstitutionAddress { get; set; }
    public List<CFAR_SObjectWrapper> objectListInstitutionAddress { get; set; }

    public Map<Id, CFAR_SObjectWrapper> objectMapMoleculeConfiguration { get; set; }
    public List<CFAR_SObjectWrapper> objectListMoleculeConfiguration { get; set; }

    public Map<Id, CFAR_SObjectWrapper> objectMapPartnership { get; set; }
    public List<CFAR_SObjectWrapper> objectListPartnership { get; set; }

    public Map<Id, CFAR_SObjectWrapper> objectMapSRTTeam { get; set; }
    public List<CFAR_SObjectWrapper> objectListSRTTeam { get; set; }

    public String selectedParentOrganization { get; set; }
    public List<SelectOption> parentOrganizationSelectOptions { get; set; }

    public String selectedInstitution { get; set; }
    public List<SelectOption> institutionSelectOptions { get; set; }

    public String selectedUnitType { get; set; }
    public List<SelectOption> unitTypeSelectOptions { get; set; }

    public String selectedProduct { get; set; }
    public List<SelectOption> productSelectOptions { get; set; }

    public List<SelectOption> addressTypeSelectOptions { get; set; }
    public List<SelectOption> contactSelectOptions { get; set; }

    //pagination
    final Integer pageSize = 10;
    private ApexPages.StandardSetController stdSetControllerWBS;
    private ApexPages.StandardSetController stdSetControllerCostCenter;
    private ApexPages.StandardSetController stdSetControllerRdt;
    private ApexPages.StandardSetController stdSetControllerProduct;
    private ApexPages.StandardSetController stdSetControllerTheme;
    private ApexPages.StandardSetController stdSetControllerParentOrganization;
    private ApexPages.StandardSetController stdSetControllerInstitution;
    private ApexPages.StandardSetController stdSetControllerInstitutionAddress;
    private ApexPages.StandardSetController stdSetControllerMoleculeConfiguration;
    private ApexPages.StandardSetController stdSetControllerPartnership;
    private ApexPages.StandardSetController stdSetControllerSRTTeam;

    public DateTime controllerWBSBDay { get; set; }
    public DateTime controllerCostCenterBDay { get; set; }
    public DateTime controllerRdtBDay { get; set; }
    public DateTime controllerProductBDay { get; set; }
    public DateTime controllerThemeBDay { get; set; }
    public DateTime controllerParentOrganizationBDay { get; set; }
    public DateTime controllerInstitutionBDay { get; set; }
    public DateTime controllerInstitutionAddressBDay { get; set; }
    public DateTime controllerMoleculeConfigurationBDay { get; set; }
    public DateTime controllerPartnershipBDay { get; set; }
    public DateTime controllerSRTTeamBDay { get; set; }
    public DateTime controllerUnitTypeBDay { get; set; }


    private Boolean newStandardSetController = true;
    public Boolean isError { get; set; }
    public Boolean isCCError {get; set;}
    public Boolean validation { get; set; }
    //disabled "create new" buttons
    public Boolean isEdit { get; set; }


    //Other
    public String parentOrganizationSearchString { get; set; }
    public String institutionSearchString { get; set; }
    public String unitTypeSearchString { get; set; }
    public String partnershipSearchString { get; set; }
    public String parentOfSelectedInstitution { get; set; }
    public String selectedCountry { get; set; }
    public String temporaryString { get; set; }
    public String selectedAddressType { get; set; }
    public List<String> existingAbbreviations {
        get {
            List<String> productAbbreviations = new List<String>();
            for (CFAR_Product_gne__c prod : [SELECT Abbreviation_gne__c FROM CFAR_Product_gne__c]) {
                if (prod.Abbreviation_gne__c != null && prod.Abbreviation_gne__c != '') {
                    productAbbreviations.add(prod.Abbreviation_gne__c);
                }
            }
            return productAbbreviations;
        }
        set;
    }

    public CFAR_Administrator_Controller() {

        selectedCountry = 'USA';

        CFAR_SearchParameters params = new CFAR_SearchParameters();
        params.sortDirection = 'asc';
        params.sortExpression = 'Name';

        addUnitType = false;
        initStdSetCtrlUnitType(params);
        fillUnitType();

        showWBS = true;
        addWBS = false;
        initStdSetCtrlWBS(params);
        fillWBSes();

        showCostCenter = true;
        addCostCenter = false;
        initStdSetCtrlCostCenter(params);
        fillCostCenters();

        showRdt = true;
        addRdt = false;
        initStdSetCtrlRdt(params);
        fillRdts();

        showProduct = true;
        addProduct = false;
        initStdSetCtrlProduct(params);
        fillProducts();

        showTheme = true;
        addTheme = false;
        initStdSetCtrlTheme(params);
        fillThemes();

        showInstitution = true;
        addInstitution = false;
        initStdSetCtrlInstitution(params);
        fillInstitutions();

        showInstitutionAddress = true;
        addInstitutionAddress = false;
        newStandardSetController = true;
        initInstitutionAddressesStdSetCtrl(null);

        addParentOrganization = false;
        stdSetControllerParentOrganization = new ApexPages.StandardSetController(CFAR_DAO.getParentOrganizations(params));
        stdSetControllerParentOrganization.setPageSize(pageSize);
        fillParentOrganizations();

        showMoleculeConfiguration = true;
        addMoleculeConfiguration = false;
        newStandardSetController = true;
        stdSetControllerMoleculeConfiguration = new ApexPages.StandardSetController(CFAR_DAO.getMoleculeConfigurations(params));
        stdSetControllerMoleculeConfiguration.setPageSize(pageSize);
        fillMoleculeConfigurations();

        addPartnership = false;
        initStdSetCtrlPartnership(params);
        fillPartnership();

        showSRTTeam = true;
        addSRTTeam = false;
        initStdSetCtrlSRTTeam(params);
        fillSRTTeam();

        fillContactSelectOptions();
        fillParentOrganizationSelectOptions();
        initDefaultOrganizationSelectetOption();
        fillInstitutionSelectOptions();
        initDefaultInstitutionSelectetOption();
        initDefaultProductSelectetOption();
        fillInstitutions();
        fillInstitutionAddresses();
        fillAddressTypeSelectOptions();
        fillProductSelectOptions();
        fillUnitTypeSelectOptions();
        historyInitialization();
    }

    private void initStdSetCtrlUnitType(CFAR_SearchParameters params) {
        stdSetControllerUnitType = new ApexPages.StandardSetController(CFAR_DAO.getUnitTypeQL(params));
        stdSetControllerUnitType.setPageSize(pageSize);
        controllerUnitTypeBDay = DateTime.now();
    }

    private void checkStdSetCtrlUnitTypeAge() {
        if (controllerUnitTypeBDay < DateTime.now().addMinutes(-10)) {
            Integer pageNum = stdSetControllerUnitType.getPageNumber();
            CFAR_SearchParameters params = new CFAR_SearchParameters();
            params.sortDirection = 'asc';
            params.sortExpression = 'Name';
            addUnitType = false;
            initStdSetCtrlUnitType(params);
            fillUnitType();
            stdSetControllerUnitType.setPageNumber(pageNum);
        }
    }

    private void initStdSetCtrlPartnership(CFAR_SearchParameters params) {
        stdSetControllerPartnership = new ApexPages.StandardSetController(CFAR_DAO.getPartnershipQL(params));
        stdSetControllerPartnership.setPageSize(pageSize);
        controllerPartnershipBDay = DateTime.now();
    }
    private void checkStdSetCtrlPartnershipAge() {
        if (controllerPartnershipBDay < DateTime.now().addMinutes(-10)) {
            Integer pageNum = stdSetControllerPartnership.getPageNumber();
            CFAR_SearchParameters params = new CFAR_SearchParameters();
            params.sortDirection = 'asc';
            params.sortExpression = 'Name';
            addPartnership = false;
            initStdSetCtrlPartnership(params);
            fillPartnership();
            stdSetControllerPartnership.setPageNumber(pageNum);
        }
    }

    private void initStdSetCtrlWBS(CFAR_SearchParameters params) {
        stdSetControllerWBS = new ApexPages.StandardSetController(CFAR_DAO.getAllWBSesQL(params));
        stdSetControllerWBS.setPageSize(pageSize);
        controllerWBSBDay = DateTime.now();
    }

    private void initStdSetCtrlCostCenter(CFAR_SearchParameters params) {
        stdSetControllerCostCenter = new ApexPages.StandardSetController(CFAR_DAO.getAllCostCentersQL(params));
        stdSetControllerCostCenter.setPageSize(pageSize);
        controllerCostCenterBDay = DateTime.now();
    }

    private void checkStdSetCtrlWBSAge() {
        if (controllerWBSBDay < DateTime.now().addMinutes(-10)) {
            Integer pageNum = stdSetControllerWBS.getPageNumber();
            CFAR_SearchParameters params = new CFAR_SearchParameters();
            params.sortDirection = 'asc';
            params.sortExpression = 'Name';
            addWBS = false;
            initStdSetCtrlWBS(params);
            fillWBSes();
            stdSetControllerWBS.setPageNumber(pageNum);
        }
    }

    private void checkStdSetCtrlCostCenterAge() {
        if (controllerCostCenterBDay < DateTime.now().addMinutes(-10)) {
            Integer pageNum = stdSetControllerCostCenter.getPageNumber();
            CFAR_SearchParameters params = new CFAR_SearchParameters();
            params.sortDirection = 'asc';
            params.sortExpression = 'Name';
            addCostCenter = false;
            initStdSetCtrlCostCenter(params);
            fillCostCenters();
            stdSetControllerCostCenter.setPageNumber(pageNum);
        }
    }

    private void initStdSetCtrlProduct(CFAR_SearchParameters params) {
        stdSetControllerProduct = new ApexPages.StandardSetController(CFAR_DAO.getProductsforAdminQL(params));
        stdSetControllerProduct.setPageSize(pageSize);
        controllerProductBDay = DateTime.now();
    }

    private void checkStdSetCtrlProductAge() {
        if (controllerProductBDay < DateTime.now().addMinutes(-10)) {
            Integer pageNum = stdSetControllerProduct.getPageNumber();
            CFAR_SearchParameters params = new CFAR_SearchParameters();
            params.sortDirection = 'asc';
            params.sortExpression = 'Name';
            addProduct = false;
            initStdSetCtrlProduct(params);
            fillProducts();
            stdSetControllerProduct.setPageNumber(pageNum);
        }
    }

    private void initStdSetCtrlRdt(CFAR_SearchParameters params) {
        stdSetControllerRdt = new ApexPages.StandardSetController(CFAR_DAO.getRdtsQL(params));
        System.debug('====Init Rdt std ctrl: ' + CFAR_DAO.getRdtsQL(params));
        System.debug('====Init Rdt std ctrl params: ' + params);
        stdSetControllerRdt.setPageSize(pageSize);   
        controllerRdtBDay = DateTime.now();
    }

    private void checkStdSetCtrlRdtAge() {
        if (controllerRdtBDay < DateTime.now().addMinutes(-10)) {
            Integer pageNum = stdSetControllerTheme.getPageNumber();
            CFAR_SearchParameters params = new CFAR_SearchParameters();
            params.sortDirection = 'asc';
            params.sortExpression = 'Name';
            addRdt = false;
            initStdSetCtrlRdt(params);
            fillRdts();
            stdSetControllerTheme.setPageNumber(pageNum);
        }
    }


    private void initStdSetCtrlTheme(CFAR_SearchParameters params) {
        stdSetControllerTheme = new ApexPages.StandardSetController(CFAR_DAO.getThemesQL(params));
        stdSetControllerTheme.setPageSize(pageSize);
        controllerThemeBDay = DateTime.now();
    }

    private void checkStdSetCtrlThemeAge() {
        if (controllerThemeBDay < DateTime.now().addMinutes(-10)) {
            Integer pageNum = stdSetControllerTheme.getPageNumber();
            CFAR_SearchParameters params = new CFAR_SearchParameters();
            params.sortDirection = 'asc';
            params.sortExpression = 'Name';
            addTheme = false;
            initStdSetCtrlTheme(params);
            fillThemes();
            stdSetControllerTheme.setPageNumber(pageNum);
        }
    }

    private void initStdSetCtrlInstitution(CFAR_SearchParameters params) {
        if (params == null) {
            params = new CFAR_SearchParameters();
            params.andEqualsParameters.put('Name', '');
        }
        stdSetControllerInstitution = new ApexPages.StandardSetController(CFAR_DAO.getInstitutionsQL(params));
        stdSetControllerInstitution.setPageSize(pageSize);
        controllerInstitutionBDay = DateTime.now();
    }

    private void checkStdSetCtrlInstitutionAge() {
        if (controllerInstitutionBDay < DateTime.now().addMinutes(-10)) {
            Integer pageNum = stdSetControllerInstitution.getPageNumber();
            CFAR_SearchParameters params = new CFAR_SearchParameters();
            params.sortDirection = 'asc';
            params.sortExpression = 'Name';
            addInstitution = false;
            initStdSetCtrlInstitution(params);
            fillInstitutions();
            stdSetControllerInstitution.setPageNumber(pageNum);
        }
    }

    private void initInstitutionAddressesStdSetCtrl(CFAR_SearchParameters params) {
        if (params == null) {
            params = new CFAR_SearchParameters();
            params.andEqualsParameters.put('Name', '');
        }
        stdSetControllerInstitutionAddress = new ApexPages.StandardSetController(CFAR_DAO.getInstitutionAddressesQL(params));
        stdSetControllerInstitutionAddress.setPageSize(pageSize);
        controllerInstitutionAddressBDay = DateTime.now();
    }

    private void checkStdSetCtrlInstitutionAddressAge() {
        if (controllerInstitutionAddressBDay < DateTime.now().addMinutes(-10)) {
            Integer pageNum = stdSetControllerInstitutionAddress.getPageNumber();
            CFAR_SearchParameters params = new CFAR_SearchParameters();
            params.sortDirection = 'asc';
            params.sortExpression = 'Name';
            addInstitutionAddress = false;
            initInstitutionAddressesStdSetCtrl(params);
            fillInstitutionAddresses();
            stdSetControllerInstitutionAddress.setPageNumber(pageNum);
        }
    }

    private void initStdSetCtrlMoleculeConfiguration(CFAR_SearchParameters params) {
        if (params == null) {
            params = new CFAR_SearchParameters();
            params.andEqualsParameters.put('Name', '');
        }
        stdSetControllerMoleculeConfiguration = new ApexPages.StandardSetController(CFAR_DAO.getMoleculeConfigurationsQL(params));
        stdSetControllerMoleculeConfiguration.setPageSize(pageSize);
        controllerMoleculeConfigurationBDay = DateTime.now();
    }

    private void checkStdSetCtrlMoleculeConfigAge() {
        if (controllerMoleculeConfigurationBDay < DateTime.now().addMinutes(-10)) {
            Integer pageNum = stdSetControllerMoleculeConfiguration.getPageNumber();
            CFAR_SearchParameters params = new CFAR_SearchParameters();
            params.sortDirection = 'asc';
            params.sortExpression = 'Name';
            addMoleculeConfiguration = false;
            initStdSetCtrlMoleculeConfiguration(params);
            fillMoleculeConfigurations();
            stdSetControllerMoleculeConfiguration.setPageNumber(pageNum);
        }
    }

    private void initStdSetCtrlSRTTeam(CFAR_SearchParameters params) {
        stdSetControllerSRTTeam = new ApexPages.StandardSetController(CFAR_DAO.getSRTTeamQL(params));
        stdSetControllerSRTTeam.setPageSize(pageSize);
        controllerSRTTeamBDay = DateTime.now();
    }

    private void checkStdSetCtrlSRTTeamAge() {
        if (controllerSRTTeamBDay < DateTime.now().addMinutes(-10)) {
            Integer pageNum = stdSetControllerSRTTeam.getPageNumber();
            CFAR_SearchParameters params = new CFAR_SearchParameters();
            params.sortDirection = 'asc';
            params.sortExpression = 'Name';
            addSRTTeam = false;
            initStdSetCtrlSRTTeam(params);
            fillSRTTeam();
            stdSetControllerSRTTeam.setPageNumber(pageNum);
        }
    }

    private void checkStdSetCtrlParentOrganization() {
        if (controllerParentOrganizationBDay < DateTime.now().addMinutes(-10)) {
            Integer pageNum = stdSetControllerParentOrganization.getPageNumber();
            CFAR_SearchParameters params = new CFAR_SearchParameters();
            params.sortDirection = 'asc';
            params.sortExpression = 'Name';
            addParentOrganization = false;
            stdSetControllerParentOrganization = new ApexPages.StandardSetController(CFAR_DAO.getParentOrganizations(params));
            stdSetControllerParentOrganization.setPageSize(pageSize);
            fillParentOrganizations();
            stdSetControllerParentOrganization.setPageNumber(pageNum);
        }
    }


    //sorting
    public String sortExpression {
        get;
        set {
            sortExpression = value;
            if (sortFieldOld == null) sortFieldOld = sortExpression;
            if (sortFieldOld == sortExpression) {
                if (sortDirection == 'desc') sortDirection = 'asc'; else sortDirection = 'desc';
            } else {
                sortDirection = 'desc';
                sortFieldOld = sortExpression;
            }
        }
    }
    private String sortFieldOld;
    public String sortDirection { get; set; }

    public void sortWBS() {
        CFAR_SearchParameters params = new CFAR_SearchParameters();
        params.sortDirection = 'asc';
        params.sortExpression = sortExpression;
        params.sortDirection = sortDirection;
        initStdSetCtrlWBS(params);
        fillWBSes();
    }

    public void sortCostCenter() {
        CFAR_SearchParameters params = new CFAR_SearchParameters();
        params.sortDirection = 'asc';
        params.sortExpression = sortExpression;
        params.sortDirection = sortDirection;
        initStdSetCtrlCostCenter(params);
        fillCostCenters();
    }

    public void sortRdt() {
        CFAR_SearchParameters params = new CFAR_SearchParameters();
        params.sortDirection = 'asc';
        params.sortExpression = sortExpression;
        params.sortDirection = sortDirection;
        initStdSetCtrlRdt(params);
        fillRdts();
    }
    public void sortProduct() {
        CFAR_SearchParameters params = new CFAR_SearchParameters();
        params.sortDirection = 'asc';
        params.sortExpression = sortExpression;
        params.sortDirection = sortDirection;
        initStdSetCtrlProduct(params);
        fillProducts();
    }
    public void sortTheme() {
        CFAR_SearchParameters params = new CFAR_SearchParameters();
        params.sortDirection = 'asc';
        params.sortExpression = sortExpression;
        params.sortDirection = sortDirection;
        initStdSetCtrlTheme(params);
        fillThemes();
    }

    public void sortSRTTeam() {
        CFAR_SearchParameters params = new CFAR_SearchParameters();
        params.sortDirection = 'asc';
        params.sortExpression = sortExpression;
        params.sortDirection = sortDirection;
        initStdSetCtrlSRTTeam(params);
        fillSRTTeam();
    }

    public Boolean addWBS { get; set; }
    public Boolean showWBS { get; set; }
    public void addNewWBS() {
        cancelAllObjects();
        showWBS = false;
        addWBS = true;
        createSObject('CFAR_WBS_gne__c');
    }

    public Boolean addCostCenter { get; set; }
    public Boolean showCostCenter { get; set; }
    public void addNewCostCenter() {
        cancelAllObjects();
        showCostCenter = false;
        addCostCenter = true;
        createSObject('CFAR_Cost_Center__c');
    }

    public Boolean addRdt { get; set; }
    public Boolean showRdt { get; set; }
    public void addNewRdt() {
        cancelAllObjects();
        showRdt = false;
        addRdt = true;
        createSObject('CFAR_Tracking_Activity_gne__c');
    }

    public Boolean addProduct { get; set; }
    public Boolean showProduct { get; set; }
    public void addNewProduct() {
        cancelAllObjects();
        showProduct = false;
        addProduct = true;
        createSObject('CFAR_Product_gne__c');
    }

    public Boolean addTheme { get; set; }
    public Boolean showTheme { get; set; }
    public void addNewTheme() {
        cancelAllObjects();
        showTheme = false;
        addTheme = true;
        createSObject('CFAR_Theme_gne__c');
    }

    public Boolean addSRTTeam { get; set; }
    public Boolean showSRTTeam { get; set; }
    public void addNewSRTTeam() {
        cancelAllObjects();
        showSRTTeam = false;
        addSRTTeam = true;
        createSObject('CFAR_Picklist_Value_gne__c');
    }

    public Boolean addParentOrganization { get; set; }
    public void addNewParentOrganization() {
        cancelAllObjects();
        addParentOrganization = true;
        createSObject('CFAR_Parent_Organization_gne__c');
    }

    public Boolean addInstitution { get; set; }
    public Boolean showInstitution { get; set; }
    public void addNewInstitution() {
        cancelAllObjects();
        fillParentOrganizationSelectOptions();
        showInstitution = false;
        addInstitution = true;
        createSObject('CFAR_Institution_gne__c');
    }

    public Boolean addInstitutionAddress { get; set; }
    public Boolean showInstitutionAddress { get; set; }
    public void addNewInstitutionAddress() {
        cancelAllObjects();
        fillInstitutionSelectOptions();
        selectedCountry = 'USA';
        showInstitutionAddress = false;
        addInstitutionAddress = true;
        createSObject('CFAR_Contact_Address_gne__c');
    }

    public Boolean addMoleculeConfiguration { get; set; }
    public Boolean showMoleculeConfiguration { get; set; }
    public void addNewMoleculeConfiguration() {
        cancelAllObjects();
        showMoleculeConfiguration = false;
        addMoleculeConfiguration = true;
        createSObject('CFAR_Molecule_Configuration_gne__c');
    }

    private void createSObject(String name) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(name);
        s_object = targetType.newSObject();
        s_object.put('Active_gne__c', true);

        if (name == 'CFAR_Institution_gne__c')
            s_object.put('Parent_Organization__c', selectedParentOrganization);
    }


    //cancel

    public void cancelAllObjects() {
        addWBS = false;
        addCostCenter = false;
        addRdt = false;
        addProduct = false;
        addTheme = false;
        addParentOrganization = false;
        addInstitution = false;
        addInstitutionAddress = false;
        addMoleculeConfiguration = false;
        addUnitType = false;
        addPartnership = false;
    }

    public void cancelCreateWBS() {
        showWBS = true;
        addWBS = false;
        isError = false;
    }
    public void cancelCreateCostCenter() {
        showCostCenter = true;
        addCostCenter = false;
        isError = false;
    }
    public void cancelCreateRdt() {
        showRdt = true;
        addRdt = false;
        isError = false;
    }
    public void cancelCreateProduct() {
        showProduct = true;
        addProduct = false;
        isError = false;
    }
    public void cancelCreateTheme() {
        showTheme = true;
        addTheme = false;
        isError = false;
    }
    public void cancelCreateSRTTeam() {
        showTheme = true;
        addTheme = false;
        isError = false;
    }
    public void cancelCreateInstitution() {
        showInstitution = true;
        addInstitution = false;
        isError = false;
    }
    public void cancelCreateInstitutionAddress() {
        showInstitutionAddress = true;
        addInstitutionAddress = false;
        isError = false;
    }
    public void cancelCreateMoleculeConfiguration() {
        showMoleculeConfiguration = true;
        addMoleculeConfiguration = false;
        isError = false;
    }

    //create new
    public void createWBS() {
        isError = false;
        if (s_object.get('GSR_WBS_gne__c') == null || s_object.get('Name') == null) {
            String emptyFieldName = s_object.get('GSR_WBS_gne__c') == null ? 'GSR_WBS_gne__c' : 'Name';
            ApexPages.addmessage(new ApexPages.message(
                    ApexPages.severity.ERROR, Schema.getGlobalDescribe().get('CFAR_WBS_gne__c').getDescribe().fields.getMap().get(emptyFieldName).getDescribe().getLabel()
                            + ' cannot be blank. Please enter a value.'));
            isError = true;
            return;
        }

        showWBS = true;
        addWBS = false;

        ApexPages.StandardController ctrl = new ApexPages.StandardController(s_object);
        PageReference pr = ctrl.save();
        if (pr != null && !ApexPages.hasMessages()) {
            CFAR_SearchParameters params = new CFAR_SearchParameters();
            params.sortDirection = 'asc';
            params.sortExpression = 'Name';

            initStdSetCtrlWBS(params);
            fillWBSes();
        }
    }

    public void createCostCenter() {
        isError = false;
        showCostCenter = true;
        addCostCenter = false;

        ApexPages.StandardController ctrl = new ApexPages.StandardController(s_object);
        PageReference pr = ctrl.save();
        if (pr != null && !ApexPages.hasMessages()) {
            CFAR_SearchParameters params = new CFAR_SearchParameters();
            params.sortDirection = 'asc';
            params.sortExpression = 'Name';

            initStdSetCtrlCostCenter(params);
            fillCostCenters();
        }
    }

    private Boolean canSaveProduct() {
        if (s_object.get('Name') == '' || s_object.get('Name') == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.CFAR_ADMINTAB_THEME_NAME_CANNOT_BE_BLANK));
        }
        if (s_object.get('Generic_Name_gne__c') == '' || s_object.get('Generic_Name_gne__c') == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.CFAR_ADMINTAB_GENERIC_NAME_CANNOT_BE_BLANK));
        }
        if (s_object.get('Theme_ref_gne__c') == null || s_object.get('Theme_ref_gne__c') == '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.CFAR_ADMINTAB_THEME_NO_CANNOT_BE_BLANK));
        }
        if (s_object.get('Abbreviation_gne__c') == null || s_object.get('Abbreviation_gne__c') == '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.CFAR_ADMINTAB_ABBREVIATION_CANNOT_BE_BLANK));
        } else if (!((String) s_object.get('Abbreviation_gne__c')).isAlpha() || ((String) s_object.get('Abbreviation_gne__c')).length() != 3) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.CFAR_ADMINTAB_ABBREVIATION_INVALID_FORMAT));
        } else if (CFAR_Utils.checkProductDuplicate((Id)s_object.get('Theme_ref_gne__c'), (String)s_object.get('Name'), (Id)s_object.get('Id'))) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.CFAR_ADMINTAB_PRODUCT_NAME_NOT_UNIQUE));
        }
        isError = ApexPages.hasMessages(ApexPages.Severity.ERROR);
        return !isError;
    }

    public void createProduct() {
        if (canSaveProduct()) {
            showProduct = true;
            addProduct = false;
            if (new ApexPages.StandardController(s_object).save() != null && !ApexPages.hasMessages()) {
                CFAR_SearchParameters params = new CFAR_SearchParameters();
                params.sortDirection = 'asc';
                params.sortExpression = 'Name';
                initStdSetCtrlProduct(params);
                fillProducts();
            }
        }
    }

    private Boolean canSaveRdt() {
        if (s_object.get('Name') == '' || s_object.get('Name') == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.CFAR_ADMINTAB_RDT_NAME_CANNOT_BE_BLANK));
        }
        // if (s_object.get('Study_Stage__c') == '' || s_object.get('Study_Stage__c') == null) {
        //     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.CFAR_ADMINTAB_GENERIC_NAME_CANNOT_BE_BLANK));
        // }
        isError = ApexPages.hasMessages(ApexPages.Severity.ERROR);
        return !isError;
    }

    public void createRdt() {
        if (canSaveRdt()) {
            showRdt = true;
            addRdt = false;
            if (new ApexPages.StandardController(s_object).save() != null && !ApexPages.hasMessages()) {
                CFAR_SearchParameters params = new CFAR_SearchParameters();
                params.sortDirection = 'asc';
                params.sortExpression = 'Name';
                initStdSetCtrlRdt(params);
                fillRdts();
            }
        }
    }


    private Boolean canSaveTheme() {
        if (s_object.get('Name') == '' || s_object.get('Name') == null) {
            isError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.CFAR_ADMINTAB_THEME_NO_NAME_CANNOT_BE_BLANK));
        } else if (CFAR_Utils.checkThemeDuplicate((String)s_object.get('Name'), (Id)s_object.get('Id'))) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.CFAR_ADMINTAB_THEME_NO_ALREADY_EXISTS));
        }
        isError = ApexPages.hasMessages(ApexPages.Severity.ERROR);
        return !isError;
    }

    public void createTheme() {
        if (canSaveTheme()) {
            showTheme = true;
            addTheme = false;

            ApexPages.StandardController ctrl = new ApexPages.StandardController(s_object);
            PageReference pr = ctrl.save();
            if (pr != null && !ApexPages.hasMessages()) {
                CFAR_SearchParameters params = new CFAR_SearchParameters();
                params.sortDirection = 'asc';
                params.sortExpression = 'Name';
                initStdSetCtrlTheme(params);
                fillThemes();
            }
        }
    }
    private Boolean canSaveSRTTeam() {
        if (s_object.get('Name') == '' || s_object.get('Name') == null) {
            isError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.CFAR_ADMINTAB_SRTTEAM_CANT_BE_BLANK));
        }
        isError = ApexPages.hasMessages(ApexPages.Severity.ERROR);
        return !isError;
    }

    public void createSRTTeam() {
        if (canSaveSRTTeam()) {
            showSRTTeam = true;
            addSRTTeam = false;

            ApexPages.StandardController ctrl = new ApexPages.StandardController(s_object);
            PageReference pr = ctrl.save();
            if (pr != null && !ApexPages.hasMessages()) {
                CFAR_SearchParameters params = new CFAR_SearchParameters();
                params.sortDirection = 'asc';
                params.sortExpression = 'Name';
                initStdSetCtrlSRTTeam(params);
                fillSRTTeam();
            }
        }
    }

    public PageReference createSRTTeamAF() {
        createSRTTeam();
        return null;
    }

    public PageReference validateSRTTeam() {
        isSRTTeamValid();
        return null;
    }

    public Boolean isSRTTeamValid() {
        isError = false;
        if (s_object.get('Name') == null || s_object.get('Name') == '') {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.CFAR_ADMINTAB_SRTTEAM_CANT_BE_BLANK));
            isError = true;
        }
        // duplicate validation
        for (CFAR_Picklist_Value_gne__c SRTTeam : CFAR_DAO.getSRTTeams(new CFAR_SearchParameters())) {
            if (SRTTeam.Name == this.s_object.get('Name') && SRTTeam.Id != this.s_object.Id) {
                isError = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.CFAR_ADMINTAB_SRTTEAM_EXISTS));
                break;
            }
        }
        isEdit = false;
        return !isError;
    }

    public void createParentOrganization() {
        isError = false;
        Savepoint sp = Database.setSavepoint();
        ApexPages.StandardController ctrl = new ApexPages.StandardController(s_object);
        PageReference pr = ctrl.save();

        if (pr == null || ApexPages.hasMessages())
            isError = true;

        else if (pr != null && !ApexPages.hasMessages() && validation) {
            stdSetControllerParentOrganization.setPageNumber(stdSetControllerParentOrganization.getPageNumber());
            fillParentOrganizationSelectOptions();
        }

        if (validation) {
            Database.rollback(sp);
        }
    }

    public void createInstitution() {
        isError = false;
        showInstitution = true;
        Savepoint sp = Database.setSavepoint();
        String initialName = String.ValueOf(s_object.get('Name'));
        validateDuplicateInstitution();
        ApexPages.StandardController ctrl = new ApexPages.StandardController(s_object);
        PageReference pr = ctrl.save();
        s_object.put('Name', initialName);
        if (pr == null || ApexPages.hasMessages())
            isError = true;

        else if (pr != null && !ApexPages.hasMessages()) {
            CFAR_SearchParameters params = new CFAR_SearchParameters();
            params.sortDirection = 'asc';
            params.sortExpression = 'Name';

            initStdSetCtrlInstitution(params);
            fillInstitutionSelectOptions();
        }
        if (validation) {
            Database.rollback(sp);
        }
    }

    public void createInstitutionAddress() {
        isError = false;
        showInstitutionAddress = true;
        Savepoint sp = Database.setSavepoint();
        this.s_object.put('Country_gne__c', selectedCountry);
        this.s_object.put('Institution_gne__c', selectedInstitution);
        ApexPages.StandardController ctrl = new ApexPages.StandardController(s_object);
        PageReference pr = ctrl.save();

        if (pr == null || ApexPages.hasMessages())
            isError = true;

        else if (pr != null && !ApexPages.hasMessages()) {
            Integer currentPageNum = stdSetControllerInstitutionAddress.getPageNumber();
            CFAR_SearchParameters params = new CFAR_SearchParameters();
            params.sortDirection = 'asc';
            params.sortExpression = 'Name';

            initInstitutionAddressesStdSetCtrl(params);
            stdSetControllerInstitutionAddress.setPageNumber(currentPageNum);
        }
        if (validation) {
            Database.rollback(sp);
        }
    }


    public void createMoleculeConfiguration() {
        isError = false;
        showMoleculeConfiguration = true;
        Savepoint sp = Database.setSavepoint();
        ApexPages.StandardController ctrl = new ApexPages.StandardController(s_object);
        this.s_object.put('Product_gne__c', selectedProduct);
        this.s_object.put('CFAR_Unit_Type_ref_gne__c', selectedUnitType);

        PageReference pr = ctrl.save();

        if (pr == null || ApexPages.hasMessages())
            isError = true;

        else if (pr != null && !ApexPages.hasMessages()) {
            CFAR_SearchParameters params = new CFAR_SearchParameters();
            params.sortDirection = 'asc';
            params.sortExpression = 'CFAR_Unit_Type_ref_gne__r.Name, Configuration_gne__c';

            initStdSetCtrlMoleculeConfiguration(params);
            fillMoleculeConfigurations();
        }
        if (validation) {
            Database.rollback(sp);
        }
    }

    public void deleteParentOrganization() {
        String objectId = Apexpages.currentPage().getParameters().get('parentOrgToDelete');
        CFAR_Utils_WithoutSharing.deleteSObject(objectMapParentOrganization.get(objectId).innerObject);
        CFAR_SearchParameters params = new CFAR_SearchParameters();
        params.sortDirection = 'asc';
        params.sortExpression = 'Name';

        stdSetControllerParentOrganization = new ApexPages.StandardSetController(CFAR_DAO.getParentOrganizations(params));
        stdSetControllerParentOrganization.setPageSize(pageSize);
        fillParentOrganizations();
        fillParentOrganizationSelectOptions();
    }
    public void deleteInstitution() {

        String objectId = Apexpages.currentPage().getParameters().get('institutionToDelete');
        CFAR_Utils_WithoutSharing.deleteSObject(objectMapInstitution.get(objectId).innerObject);
        CFAR_SearchParameters params = new CFAR_SearchParameters();
        params.sortDirection = 'asc';
        params.sortExpression = 'Name';

        initStdSetCtrlInstitution(params);
        fillInstitutions();
        fillInstitutionSelectOptions();

    }
    public void deleteInstitutionAddress() {
        String objectId = Apexpages.currentPage().getParameters().get('institutionAddressToDelete');

        try {
            CFAR_Utils_WithoutSharing.deleteSObject(objectMapInstitutionAddress.get(objectId).innerObject);
            CFAR_SearchParameters params = new CFAR_SearchParameters();
            params.sortDirection = 'asc';
            params.sortExpression = 'Name';

            initInstitutionAddressesStdSetCtrl(params);
            fillInstitutionAddresses();
        } catch (Exception e) {

            String relatedContactsString = '';
            List<CFAR_Contact_Address_JO_gne__c> contactList = [SELECT CFAR_Contact_ref_gne__r.Name FROM CFAR_Contact_Address_JO_gne__c WHERE Contact_Address_ref_gne__c = :objectId];
            if (contactList.size() > 0) {
                for (CFAR_Contact_Address_JO_gne__c contact : contactList)
                    relatedContactsString += contact.CFAR_Contact_ref_gne__r.Name + '; ';
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, String.format(Label.CFAR_ADMINTAB_CANT_DELETE_INSTITUTION_ADDRESS, new List<String>{
                        relatedContactsString
                })));
            } else
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));

        }
    }

    public void deleteMoleculeConfiguration() {
        String objectId = Apexpages.currentPage().getParameters().get('moleculeConfigurationToDelete');
        CFAR_Utils_WithoutSharing.deleteSObject(objectMapMoleculeConfiguration.get(objectId).innerObject);
        CFAR_SearchParameters params = new CFAR_SearchParameters();
        params.sortDirection = 'asc';
        params.sortExpression = 'CFAR_Unit_type_ref_gne__r.Name, Configuration_gne__c';

        initStdSetCtrlMoleculeConfiguration(params);
        fillMoleculeConfigurations();
    }


    @RemoteAction
    public static Boolean checkIfDeletableParentOrganization(String objectId) {
        Boolean isError = false;
        if ([SELECT COUNT() FROM CFAR_Institution_gne__c WHERE Parent_Organization__c = :objectId] > 0)
            isError = true;
        return isError;
    }


    @RemoteAction
    public static Boolean checkIfDeletableInstitution(String objectId) {
        Boolean isError = false;
        if ([SELECT COUNT() FROM CFAR_Contact_Address_gne__c WHERE Institution_gne__c = :objectId] > 0)
            isError = true;
        return isError;
    }

    @RemoteAction
    public static Boolean checkIfDeletableInstitutionAddress(String objectId) {
        Boolean isError = false;
        List<CFAR_Contact_Address_JO_gne__c> contactList = [SELECT CFAR_Contact_ref_gne__r.Name FROM CFAR_Contact_Address_JO_gne__c WHERE Contact_Address_ref_gne__c = :objectId];
        if (contactList.size() > 0)
            isError = true;
        return isError;
    }

    @RemoteAction
    public static Boolean checkIfDeletableMoleculeConfiguration(String objectId) {
        Boolean isError = false;
        List<CFAR_Cohort_Molecule_gne__c> moleculeList = [SELECT Molecule_Configuration_ref_gne__c FROM CFAR_Cohort_Molecule_gne__c WHERE Cohort_ref_gne__r.Trial_ref_gne__c != null AND Molecule_Configuration_ref_gne__c = :objectId];
        if (moleculeList.size() > 0)
            isError = true;
        return isError;
    }

    public void showParentOrganizationDeleteError() {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.CFAR_ADMINTAB_CANT_DELETE_ORGANIZATION));
    }

    public void showInstitutionDeleteError() {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.CFAR_ADMINTAB_CANT_DELETE_INSTITUTION_ASSOCIATED_ADDRESS));
    }

    public void showInstitutionAddressDeleteError() {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.CFAR_ADMINTAB_CANT_DELETE_INSTITUTION_ASSOCIATED_CONTACT));
    }

    public void showMoleculeConfigurationDeleteError() {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.CFAR_ADMINTAB_CANT_DELETE_MOLECULE_CONFIG));
    }

    private void validateDuplicateInstitution() {
        for (CFAR_Institution_gne__c institution : CFAR_DAO.getInstitutions(new CFAR_SearchParameters())) {
            if ((institution.Name == this.s_object.get('Name') && institution.Parent_Organization__c == this.s_object.get('Parent_Organization__c'))
                    && (this.s_object == null || this.s_object.Id == null || this.s_object.Id != institution.Id)) {
                isError = true;
                s_object.put('Name', 'duplicated');
            }
        }
    }

    public void previousWBS() {
        checkStdSetCtrlWBSAge();
        stdSetControllerWBS.previous();
        fillWBSes();
    }

    public void previousCostCenter() {
        checkStdSetCtrlCostCenterAge();
        stdSetControllerCostCenter.previous();
        fillCostCenters();
    }

    public void previousRdt() {
        checkStdSetCtrlRdtAge();
        stdSetControllerRdt.previous();
        fillRdts();
    }
    public void previousProduct() {
        checkStdSetCtrlProductAge();
        stdSetControllerProduct.previous();
        fillProducts();
    }
    public void previousTheme() {
        checkStdSetCtrlThemeAge();
        stdSetControllerTheme.previous();
        fillThemes();
    }
    public void previousSRTTeam() {
        checkStdSetCtrlSRTTeamAge();
        stdSetControllerSRTTeam.previous();
        fillSRTTeam();
    }
    public void previousParentOrganization() {
        checkStdSetCtrlParentOrganization();
        newStandardSetController = false;
        stdSetControllerParentOrganization.previous();
        fillParentOrganizations();
    }
    public void previousInstitution() {
        checkStdSetCtrlInstitutionAge();
        newStandardSetController = false;
        stdSetControllerInstitution.previous();
        fillInstitutions();
    }
    public void previousInstitutionAddress() {
        checkStdSetCtrlInstitutionAddressAge();
        newStandardSetController = false;
        stdSetControllerInstitutionAddress.previous();
        fillInstitutionAddresses();
    }
    public void previousMoleculeConfiguration() {
        checkStdSetCtrlMoleculeConfigAge();
        newStandardSetController = false;
        stdSetControllerMoleculeConfiguration.previous();
        fillMoleculeConfigurations();
    }

    //next
    public void nextWBS() {
        checkStdSetCtrlWBSAge();
        stdSetControllerWBS.next();
        fillWBSes();
    }

    public void nextCostCenter() {
        checkStdSetCtrlCostCenterAge();
        stdSetControllerCostCenter.next();
        fillCostCenters();
    }

    public void nextRdt() {
        checkStdSetCtrlRdtAge();
        stdSetControllerRdt.next();
        fillRdts();
    }
    public void nextProduct() {
        checkStdSetCtrlProductAge();
        stdSetControllerProduct.next();
        fillProducts();
    }
    public void nextTheme() {
        checkStdSetCtrlThemeAge();
        stdSetControllerTheme.next();
        fillThemes();
    }
    public void nextSRTTeam() {
        checkStdSetCtrlSRTTeamAge();
        stdSetControllerSRTTeam.next();
        fillSRTTeam();
    }
    public void nextParentOrganization() {
        checkStdSetCtrlParentOrganization();
        newStandardSetController = false;
        stdSetControllerParentOrganization.next();
        fillParentOrganizations();
    }
    public void nextInstitution() {
        checkStdSetCtrlInstitutionAge();
        newStandardSetController = false;
        stdSetControllerInstitution.next();
        fillInstitutions();
    }
    public void nextInstitutionAddress() {
        checkStdSetCtrlInstitutionAddressAge();
        newStandardSetController = false;
        stdSetControllerInstitutionAddress.next();
        fillInstitutionAddresses();
    }
    public void nextMoleculeConfiguration() {
        checkStdSetCtrlMoleculeConfigAge();
        newStandardSetController = false;
        stdSetControllerMoleculeConfiguration.next();
        fillMoleculeConfigurations();
    }

    //first
    public void firstWBS() {
        checkStdSetCtrlWBSAge();
        stdSetControllerWBS.first();
        fillWBSes();
    }

    public void firstCostCenter() {
        checkStdSetCtrlCostCenterAge();
        stdSetControllerCostCenter.first();
        fillCostCenters();
    }

    public void firstRdt() {
        checkStdSetCtrlRdtAge();
        stdSetControllerRdt.first();
        fillRdts();
    }
    public void firstProduct() {
        checkStdSetCtrlProductAge();
        stdSetControllerProduct.first();
        fillProducts();
    }
    public void firstTheme() {
        checkStdSetCtrlThemeAge();
        stdSetControllerTheme.first();
        fillThemes();
    }
    public void firstSRTTeam() {
        checkStdSetCtrlSRTTeamAge();
        stdSetControllerSRTTeam.first();
        fillSRTTeam();
    }
    public void firstParentOrganization() {
        checkStdSetCtrlParentOrganization();
        newStandardSetController = false;
        stdSetControllerParentOrganization.first();
        fillParentOrganizations();
    }
    public void firstInstitution() {
        checkStdSetCtrlInstitutionAge();
        newStandardSetController = false;
        stdSetControllerInstitution.first();
        fillInstitutions();
    }
    public void firstInstitutionAddress() {
        checkStdSetCtrlInstitutionAddressAge();
        newStandardSetController = false;
        stdSetControllerInstitutionAddress.first();
        fillInstitutionAddresses();
    }
    public void firstMoleculeConfiguration() {
        checkStdSetCtrlMoleculeConfigAge();
        newStandardSetController = false;
        stdSetControllerMoleculeConfiguration.first();
        fillMoleculeConfigurations();
    }

    //last
    public void lastWBS() {
        checkStdSetCtrlWBSAge();
        stdSetControllerWBS.last();
        fillWBSes();
    }

    public void lastCostCenter() {
        checkStdSetCtrlCostCenterAge();
        stdSetControllerCostCenter.last();
        fillCostCenters();
    }

    public void lastRdt() {
        checkStdSetCtrlRdtAge();
        stdSetControllerRdt.last();
        fillRdts();
    }
    public void lastProduct() {
        checkStdSetCtrlProductAge();
        stdSetControllerProduct.last();
        fillProducts();
    }
    public void lastTheme() {
        checkStdSetCtrlThemeAge();
        stdSetControllerTheme.last();
        fillThemes();
    }
    public void lastSRTTeam() {
        checkStdSetCtrlSRTTeamAge();
        stdSetControllerSRTTeam.last();
        fillSRTTeam();
    }
    public void lastParentOrganization() {
        checkStdSetCtrlParentOrganization();
        newStandardSetController = false;
        stdSetControllerParentOrganization.last();
        fillParentOrganizations();
    }
    public void lastInstitution() {
        checkStdSetCtrlInstitutionAge();
        newStandardSetController = false;
        stdSetControllerInstitution.last();
        fillInstitutions();
    }
    public void lastInstitutionAddress() {
        checkStdSetCtrlInstitutionAddressAge();
        newStandardSetController = false;
        stdSetControllerInstitutionAddress.last();
        fillInstitutionAddresses();
    }
    public void lastMoleculeConfiguration() {
        checkStdSetCtrlMoleculeConfigAge();
        newStandardSetController = false;
        stdSetControllerMoleculeConfiguration.last();
        fillMoleculeConfigurations();
    }

    //hasNext
    public Boolean hasNextWBS {
        get {
            return stdSetControllerWBS.getHasNext();
        }
        private set;
    }

    public Boolean hasNextCostCenter {
        get {
            return stdSetControllerCostCenter.getHasNext();
        }
        private set;
    }

    public Boolean hasNextRdt {
        get {
            return stdSetControllerRdt.getHasNext();
        }
        private set;
    }
    public Boolean hasNextProduct {
        get {
            return stdSetControllerProduct.getHasNext();
        }
        private set;
    }
    public Boolean hasNextTheme {
        get {
            return stdSetControllerTheme.getHasNext();
        }
        private set;
    }
    public Boolean hasNextSRTTeam {
        get {
            return stdSetControllerSRTTeam.getHasNext();
        }
        private set;
    }
    public Boolean hasNextParentOrganization {
        get {
            return stdSetControllerParentOrganization.getHasNext();
        }
        private set;
    }
    public Boolean hasNextInstitution {
        get {
            return stdSetControllerInstitution.getHasNext();
        }
        private set;
    }
    public Boolean hasNextInstitutionAddress {
        get {
            return stdSetControllerInstitutionAddress.getHasNext();
        }
        private set;
    }
    public Boolean hasNextMoleculeConfiguration {
        get {
            return stdSetControllerMoleculeConfiguration.getHasNext();
        }
        private set;
    }
    //hasPrevoius   
    public Boolean hasPreviousWBS {
        get {
            return stdSetControllerWBS.getHasPrevious();
        }
        private set;
    }

    public Boolean hasPreviousCostCenter {
        get {
            return stdSetControllerCostCenter.getHasPrevious();
        }
        private set;
    }
    public Boolean hasPreviousRdt {
        get {
            return stdSetControllerRdt.getHasPrevious();
        }
        private set;
    }
    public Boolean hasPreviousProduct {
        get {
            return stdSetControllerProduct.getHasPrevious();
        }
        private set;
    }
    public Boolean hasPreviousTheme {
        get {
            return stdSetControllerTheme.getHasPrevious();
        }
        private set;
    }
    public Boolean hasPreviousSRTTeam {
        get {
            return stdSetControllerSRTTeam.getHasPrevious();
        }
        private set;
    }
    public Boolean hasPreviousParentOrganization {
        get {
            return stdSetControllerParentOrganization.getHasPrevious();
        }
        private set;
    }
    public Boolean hasPreviousInstitution {
        get {
            return stdSetControllerInstitution.getHasPrevious();
        }
        private set;
    }
    public Boolean hasPreviousInstitutionAddress {
        get {
            return stdSetControllerInstitutionAddress.getHasPrevious();
        }
        private set;
    }
    public Boolean hasPreviousMoleculeConfiguration {
        get {
            return stdSetControllerMoleculeConfiguration.getHasPrevious();
        }
        private set;
    }
    //edit
    public void editWBS() {
        objectMapWBS.get(objectId).selected = true;
        isEdit = true;
        s_object = objectMapWBS.get(objectId).innerObject.clone(true, true, true, true);
        for (CFAR_SObjectWrapper obj : objectMapWBS.values()) {
            if (obj.innerObject.Id != objectId) {
                obj.selected = false;
            }
        }
    }

    public void editCostCenter() {
        objectMapCostCenter.get(objectId).selected = true;
        isEdit = true;
        s_object = objectMapCostCenter.get(objectId).innerObject.clone(true, true, true, true);
        for (CFAR_SObjectWrapper obj : objectMapCostCenter.values()) {
            if (obj.innerObject.Id != objectId) {
                obj.selected = false;
            }
        }
    }
    public void editRdt() {
        objectMapRdt.get(objectId).selected = true;
        isEdit = true;
        s_object = objectMapRdt.get(objectId).innerObject.clone(true, true, true, true);
        for (CFAR_SObjectWrapper obj : objectMapRdt.values()) {
            if (obj.innerObject.Id != objectId) {
                obj.selected = false;
            }
        }
    }
    public void editProduct() {
        objectMapProduct.get(objectId).selected = true;
        isEdit = true;
        s_object = objectMapProduct.get(objectId).innerObject.clone(true, true, true, true);
        for (CFAR_SObjectWrapper obj : objectMapProduct.values()) {
            if (obj.innerObject.Id != objectId) {
                obj.selected = false;
            }
        }
    }
    public void editTheme() {
        objectMapTheme.get(objectId).selected = true;
        isEdit = true;
        s_object = objectMapTheme.get(objectId).innerObject.clone(true, true, true, true);
        for (CFAR_SObjectWrapper obj : objectMapTheme.values()) {
            if (obj.innerObject.Id != objectId) {
                obj.selected = false;
            }
        }
    }
    public void editSRTTeam() {
        objectMapSRTTeam.get(objectId).selected = true;
        isEdit = true;
        s_object = objectMapSRTTeam.get(objectId).innerObject.clone(true, true, true, true);
        for (CFAR_SObjectWrapper obj : objectMapSRTTeam.values()) {
            if (obj.innerObject.Id != objectId) {
                obj.selected = false;
            }
        }
    }
    public void editParentOrganization() {
        objectMapParentOrganization.get(objectId).selected = true;
        isEdit = true;
        s_object = objectMapParentOrganization.get(objectId).innerObject.clone(true, true, true, true);
        for (CFAR_SObjectWrapper obj : objectMapParentOrganization.values()) {
            if (obj.innerObject.Id != objectId) {
                obj.selected = false;
            }
        }
    }
    public void editInstitution() {
        fillParentOrganizationSelectOptions();
        isEdit = true;
        objectMapInstitution.get(objectId).selected = true;
        s_object = objectMapInstitution.get(objectId).innerObject.clone(true, true, true, true);
        for (CFAR_SObjectWrapper obj : objectMapInstitution.values()) {
            if (obj.innerObject.Id != objectId) {
                obj.selected = false;
            }
        }
        showInstitution = false;

    }
    public void editInstitutionAddress() {

        objectMapInstitutionAddress.get(objectId).selected = true;
        isEdit = true;
        s_object = objectMapInstitutionAddress.get(objectId).innerObject.clone(true, true, true, true);
        selectedAddressType = String.valueOf(this.s_object.get('Address_Type_ref_gne__c'));
        for (CFAR_SObjectWrapper obj : objectMapInstitutionAddress.values()) {
            if (obj.innerObject.Id != objectId) {
                obj.selected = false;
            }
        }
        try {
            selectedCountry = String.ValueOf(this.s_object.get('Country_gne__c'));
        } catch (Exception e) {
        }

    }

    public void editMoleculeConfiguration() {
        objectMapMoleculeConfiguration.get(objectId).selected = true;
        isEdit = true;
        s_object = objectMapMoleculeConfiguration.get(objectId).innerObject.clone(true, true, true, true);
        selectedUnitType = String.valueOf(this.s_object.get('CFAR_Unit_Type_ref_gne__c'));
        for (CFAR_SObjectWrapper obj : objectMapMoleculeConfiguration.values()) {
            if (obj.innerObject.Id != objectId) {
                obj.selected = false;
            }
        }
        showMoleculeConfiguration = false;

    }

    //cancel edit
    public void cancelEditWBS() {
        objectMapWBS.get(objectId).selected = false;
        isEdit = false;
        isError = false;
    }

    public void cancelEditCostCenter() {
        objectMapCostCenter.get(objectId).selected = false;
        isEdit = false;
        isError = false;
    }

    public void cancelEditRdt() {
        objectMapRdt.get(objectId).selected = false;
        isEdit = false;
        isError = false;
    }
    public void cancelEditProduct() {
        objectMapProduct.get(objectId).selected = false;
        isEdit = false;
        isError = false;
    }
    public void cancelEditTheme() {
        objectMapTheme.get(objectId).selected = false;
        isEdit = false;
        isError = false;
    }
    public void cancelEditSRTTeam() {
        objectMapSRTTeam.get(objectId).selected = false;
        isEdit = false;
        isError = false;
    }
    public void cancelEditParentOrganization() {
        objectMapParentOrganization.get(objectId).selected = false;
        isEdit = false;
        isError = false;
    }
    public void cancelEditInstitution() {
        objectMapInstitution.get(objectId).selected = false;
        isEdit = false;
        isError = false;
    }
    public void cancelEditInstitutionAddress() {
        objectMapInstitutionAddress.get(objectId).selected = false;
        isEdit = false;
        isError = false;
    }
    public void cancelEditMoleculeConfiguration() {
        objectMapMoleculeConfiguration.get(objectId).selected = false;
        isEdit = false;
        isError = false;
    }

    //save
    public void saveWBS() {
        ApexPages.StandardController ctrl = new ApexPages.StandardController(s_object);
        objectMapWBS.get(s_object.Id).selected = false;
        PageReference pr = ctrl.save();
        if (pr != null && !ApexPages.hasMessages())
            objectMapWBS.get(s_object.Id).innerObject = s_object;
        Integer currentPageNum = stdSetControllerWBS.getPageNumber();
        CFAR_SearchParameters params = new CFAR_SearchParameters();
        params.sortDirection = 'asc';
        params.sortExpression = 'Name';

        initStdSetCtrlWBS(params);
        stdSetControllerWBS.setPageNumber(currentPageNum);
        isEdit = false;
    }

    
    public List<String> validateCostCenters(Id ccID) {
        List<String> costCentersInTrialNames = new List<String>();
        for (Cost_Center_for_Trial__c cc : [SELECT Cost_Center_Name__c FROM Cost_Center_for_Trial__c WHERE gSTARS_Trial__c =:ccID]) {
            costCentersInTrialNames.add(cc.Cost_Center_Name__c);
        }
        return costCentersInTrialNames;
    }
    public void saveCostCenter() {
        Boolean isAssociatedToTrial = false;
        // for (String s : validateCostCenters(s_object.Id)) {
        //     if (s_object.get('Name') == s) {
        //         isAssociatedToTrial = true;
        //     }
        // }
        List<Cost_Center_for_Trial__c> validationtest = [SELECT id, Cost_Center_Name__c FROM Cost_Center_for_Trial__c WHERE Cost_Center__c = :s_object.Id];
        if (!validationtest.isEmpty()) {
            isAssociatedToTrial = true;
        }

        if (isAssociatedToTrial) {
            isError = true;
            isCCError = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Cannot edit/modify the Cost Center since it is currently being used in one or more studies.'));
        } else {
            ApexPages.StandardController ctrl = new ApexPages.StandardController(s_object);
            objectMapCostCenter.get(s_object.Id).selected = false;
            PageReference pr = ctrl.save();
            if (pr != null && !ApexPages.hasMessages())
                objectMapCostCenter.get(s_object.Id).innerObject = s_object;
            Integer currentPageNum = stdSetControllerCostCenter.getPageNumber();
            CFAR_SearchParameters params = new CFAR_SearchParameters();
            params.sortDirection = 'asc';
            params.sortExpression = 'Name';
    
            initStdSetCtrlCostCenter(params);
            stdSetControllerCostCenter.setPageNumber(currentPageNum);
            isEdit = false;
            isCCError = false;
        }
    }

    public void saveRdt() {
        if (canSaveRdt()) {
            ApexPages.StandardController ctrl = new ApexPages.StandardController(s_object);
            objectMapRdt.get(s_object.Id).selected = false;
            PageReference pr = ctrl.save();
            if (pr != null && !ApexPages.hasMessages()) {
                objectMapRdt.get(s_object.Id).innerObject = s_object;
                Integer currentPageNum = stdSetControllerRdt.getPageNumber();
                CFAR_SearchParameters params = new CFAR_SearchParameters();
                params.sortDirection = 'asc';
                params.sortExpression = 'Name';

                initStdSetCtrlRdt(params);
                stdSetControllerRdt.setpageNumber(currentPageNum);
            }
            isEdit = false;
        }
    }
    public void saveProduct() {
        try {
            if (canSaveProduct()) {
                ApexPages.StandardController ctrl = new ApexPages.StandardController(s_object);
                objectMapProduct.get(s_object.Id).selected = false;
                PageReference pr = ctrl.save();
                if (pr != null && !ApexPages.hasMessages()) {
                    objectMapProduct.get(s_object.Id).innerObject = s_object;
                    Integer currentPageNum = stdSetControllerProduct.getPageNumber();
                    CFAR_SearchParameters params = new CFAR_SearchParameters();
                    params.sortDirection = 'asc';
                    params.sortExpression = 'Name';
                    initStdSetCtrlProduct(params);
                    stdSetControllerProduct.setPageNumber(currentPageNum);
                    fillProducts();
                }
                isEdit = false;
            }
        } catch (Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, '' + e));
        }

    }
    public void saveTheme() {
        if (canSaveTheme()) {
            ApexPages.StandardController ctrl = new ApexPages.StandardController(s_object);
            objectMapTheme.get(s_object.Id).selected = false;
            PageReference pr = ctrl.save();
            if (pr != null && !ApexPages.hasMessages()) {
                objectMapTheme.get(s_object.Id).innerObject = s_object;
                Integer currentPageNum = stdSetControllerTheme.getPageNumber();
                CFAR_SearchParameters params = new CFAR_SearchParameters();
                params.sortDirection = 'asc';
                params.sortExpression = 'Name';

                initStdSetCtrlProduct(params);
                stdSetControllerTheme.setpageNumber(currentPageNum);
            }
            isEdit = false;
        }
    }
    public void saveSRTTeam() {
        if (canSaveSRTTeam()) {
            ApexPages.StandardController ctrl = new ApexPages.StandardController(s_object);
            objectMapSRTTeam.get(s_object.Id).selected = false;
            PageReference pr = ctrl.save();
            if (pr != null && !ApexPages.hasMessages()) {
                objectMapSRTTeam.get(s_object.Id).innerObject = s_object;
                Integer currentPageNum = stdSetControllerSRTTeam.getPageNumber();
                CFAR_SearchParameters params = new CFAR_SearchParameters();
                params.sortDirection = 'asc';
                params.sortExpression = 'Name';
                stdSetControllerSRTTeam.setpageNumber(currentPageNum);
            }
            isEdit = false;
        }
    }
    public void saveParentOrganizationValidation() {
        isError = false;
        // deactivation validation
        if (s_object.get('Active_gne__c') == false) {
            String activeInstitutions = '';
            List<CFAR_Institution_gne__c> institutionList = [SELECT Name FROM CFAR_Institution_gne__c WHERE Parent_Organization__c = :objectId AND Active_gne__c = true];
            if (institutionList.size() > 0) {
                for (CFAR_Institution_gne__c institution : institutionList) {
                    activeInstitutions += institution.Name + '; ';
                }
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.CFAR_ADMINTAB_CANT_DEACTIVATE_ORGANIZATION));
                objectMapParentOrganization.get(s_object.Id).selected = true;
                isError = true;
            }
        }

        // null validation
        if (s_object.get('Name') == null) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.CFAR_ADMINTAB_ORGANIZATION_CANNOT_BE_BLANK));
            isError = true;
        }

        // duplicate validation
        for (CFAR_Parent_Organization_gne__c organization : CFAR_DAO.getParentOrganizations(new CFAR_SearchParameters())) {
            if (organization.Name == this.s_object.get('Name') && organization.Id != this.s_object.get('Id')) {
                isError = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.CFAR_ADMINTAB_ORGANIZATION_ALREADY_EXISTS));
                objectMapParentOrganization.get(s_object.Id).selected = true;

            }
        }
        isEdit = false;

    }
    public void saveParentOrganization() {
        ApexPages.StandardController ctrl = new ApexPages.StandardController(s_object);
        objectMapParentOrganization.get(s_object.Id).selected = false;
        PageReference pr = ctrl.save();
        if (pr != null && !ApexPages.hasMessages())
            objectMapParentOrganization.get(s_object.Id).innerObject = s_object;
        Integer currentPageNum = stdSetControllerParentOrganization.getPageNumber();
        CFAR_SearchParameters params = new CFAR_SearchParameters();
        params.sortDirection = 'asc';
        params.sortExpression = 'Name';

        stdSetControllerParentOrganization = new ApexPages.StandardSetController(CFAR_DAO.getParentOrganizations(params));
        stdSetControllerParentOrganization.setPageSize(pageSize);
        stdSetControllerParentOrganization.setPageNumber(currentPageNum);

        fillParentOrganizationSelectOptions();
        fillinstitutions();
        isEdit = false;
    }

    public void saveInstitutionValidation() {
        isError = false;
        // deactivation validation
        if (s_object.get('Active_gne__c') == false) {
            String activeAddresses = '';
            List<CFAR_Contact_Address_gne__c> addressList = [SELECT Address_gne__c, City_gne__c FROM CFAR_Contact_Address_gne__c WHERE Institution_gne__c = :objectId AND Active_gne__c = true];
            if (addressList.size() > 0) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.CFAR_ADMINTAB_CANT_DEACTIVATE_INSTITUTION));
                isError = true;
                objectMapInstitution.get(s_object.Id).selected = true;
            }
        }


        // duplicate validation
        for (CFAR_Institution_gne__c institution : CFAR_DAO.getInstitutions(new CFAR_SearchParameters())) {
            if ((institution.Name == this.s_object.get('Name') && institution.Parent_Organization__c == this.s_object.get('Parent_Organization__c'))
                    && (this.s_object == null || this.s_object.Id == null || this.s_object.Id != institution.Id)) {
                isError = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.CFAR_ADMINTAB_INSTITUTION_ALREADY_EXISTS));
                objectMapInstitution.get(s_object.Id).selected = true;

            }
        }

        // null validation
        if (s_object.get('Name') == null) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.CFAR_ADMINTAB_INSTITUTION_ADDRESS_CANT_BE_BLANK));
            isError = true;
        }
        isEdit = false;
    }
    public void saveInstitution() {
        ApexPages.StandardController ctrl = new ApexPages.StandardController(s_object);
        objectMapInstitution.get(s_object.Id).selected = false;
        PageReference pr = ctrl.save();
        if (pr != null && !ApexPages.hasMessages()) {
            replaceInnerObject(s_object, objectListInstitution, objectMapInstitution);
        }
        Integer currentPageNum = stdSetControllerInstitution.getPageNumber();
        CFAR_SearchParameters params = new CFAR_SearchParameters();
        params.sortDirection = 'asc';
        params.sortExpression = 'Name';

        stdSetControllerInstitution = new ApexPages.StandardSetController(CFAR_DAO.getInstitutionsQL(params));
        stdSetControllerInstitution.setPageSize(pageSize);
        stdSetControllerInstitution.setPageNumber(currentPageNum);
        fillInstitutionSelectOptions();

        CFAR_Parent_Organization_gne__c[] organizationNameList = [Select Name FROM CFAR_Parent_Organization_gne__c WHERE Id = :String.valueOf(s_object.get('Parent_Organization__c'))];
        objectMapInstitution.get(s_object.Id).tempValue = organizationNameList[0].Name;
        isEdit = false;
    }

    public void saveInstitutionAddressValidation() {
        isError = false;

        // deactivation validation
        if (s_object.get('Active_gne__c') == false) {
            List<CFAR_Contact_Address_JO_gne__c> contactList = [SELECT CFAR_Contact_ref_gne__r.Name FROM CFAR_Contact_Address_JO_gne__c WHERE Contact_Address_ref_gne__c = :objectId AND active_gne__c = true];
            if (contactList.size() > 0) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.CFAR_ADMINTAB_CANT_DEACTIVATE_INSTITUTION_ADDRESS));
                isError = true;
            }
        }
        //  null & content validations
        if (s_object.get('address_gne__c') == null) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.CFAR_ADMINTAB_ADDRESS_CANT_BE_BLANK));
            isError = true;
        }
        if (s_object.get('city_gne__c') == null) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.CFAR_ADMINTAB_CITY_CANT_BE_BLANK));
            isError = true;
        }
        if (selectedCountry == 'USA') {
            if (s_object.get('state_gne__c') == null) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.CFAR_ADMINTAB_STATE_CANT_BE_BLANK));
                isError = true;
            }
            if (s_object.get('Zip_gne__c') == null) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.CFAR_ADMINTAB_ZIP_CANT_BE_BLANK));
                isError = true;
            }
            if (s_object.get('Zip_gne__c') != null) {
                if (
                        (String.valueOf(s_object.get('Zip_gne__c')).length() != 5 && String.valueOf(s_object.get('Zip_gne__c')).length() != 10)
                                || (String.valueOf(s_object.get('Zip_gne__c')).length() == 5 && String.valueOf(s_object.get('Zip_gne__c')).isNumeric() == false)
                                || (String.valueOf(s_object.get('Zip_gne__c')).length() == 10 && (String.valueOf(s_object.get('Zip_gne__c')).left(5).isNumeric() == false || String.valueOf(s_object.get('Zip_gne__c')).right(4).isNumeric() == false || String.valueOf(s_object.get('Zip_gne__c')).contains('-') == false))
                        ) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.CFAR_ADMINTAB_INVALID_ZIP_FORMAT));
                    isError = true;
                }
            }

        }
        if (selectedCountry != 'USA') {
            if (s_object.get('Province_gne__c') == null) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.CFAR_ADMINTAB_PROVINCE_CANT_BE_BLANK));
                isError = true;
            }
            if (s_object.get('Postal_Code_gne__c') == null) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.CFAR_ADMINTAB_POSTAL_CANT_BE_BLANK));
                isError = true;
            }
        }
        if (s_object.get('Address_Type_ref_gne__c') == null) {
            System.debug('pies m 1');
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.CFAR_ADMINTAB_ADDRESS_CANT_BE_BLANK));
            isError = true;
        }
        isEdit = false;
    }

    public void saveInstitutionAddress() {
        this.s_object.put('Country_gne__c', selectedCountry);
        this.s_object.put('Address_Type_ref_gne__c', selectedAddressType);

        ApexPages.StandardController ctrl = new ApexPages.StandardController(s_object);
        objectMapInstitutionAddress.get(s_object.Id).selected = false;
        PageReference pr = ctrl.save();
        if (pr != null && !ApexPages.hasMessages()) {
            replaceInnerObject(s_object, objectListInstitutionAddress, objectMapInstitutionAddress);
        }
        Integer currentPageNum = stdSetControllerInstitutionAddress.getPageNumber();
        CFAR_SearchParameters params = new CFAR_SearchParameters();
        params.sortDirection = 'asc';
        params.sortExpression = 'Name';
        params.andEqualsParameters.put('Institution_gne__c', this.s_object.get('institution_gne__c'));

        stdSetControllerInstitutionAddress = new ApexPages.StandardSetController(CFAR_DAO.getInstitutionAddresses(params));
        stdSetControllerInstitutionAddress.setPageSize(pageSize);
        stdSetControllerInstitutionAddress.setPageNumber(currentPageNum);


        CFAR_Address_Type_gne__c[] addressTypeNameList = [Select Name FROM CFAR_Address_Type_gne__c WHERE Id = :selectedAddressType];
        objectMapInstitutionAddress.get(s_object.Id).tempValue = addressTypeNameList[0].Name;
        isEdit = false;

    }

    public void saveMoleculeConfigurationValidation() {
        isError = false;
        if (s_object.get('Configuration_gne__c') == null) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.CFAR_ADMINTAB_CONFIGURATION_CANT_BE_BLANK));
            isError = true;

        }

        if (selectedUnitType == null || selectedUnitType == '') {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.CFAR_ADMINTAB_UNITTYPE_CANT_BE_BLANK));
            isError = true;
        }


        Integer sameConfigurationCount = [SELECT COUNT() FROM CFAR_Molecule_Configuration_gne__c WHERE Configuration_gne__c = :String.valueOf(s_object.get('Configuration_gne__c')) AND Product_gne__c = :String.valueOf(s_object.get('Product_gne__c')) AND CFAR_Unit_Type_ref_gne__c = :selectedUnitType AND Id != :String.valueOf(s_object.get('Id'))];
        if (sameConfigurationCount > 0) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.CFAR_ADMINTAB_MOLECULE_CONFIGURATION_EXISTS));
            isError = true;
        }
        isEdit = false;

    }

    public void saveMoleculeConfiguration() {
        this.s_object.put('CFAR_Unit_Type_ref_gne__c', selectedUnitType);
        ApexPages.StandardController ctrl = new ApexPages.StandardController(s_object);
        objectMapMoleculeConfiguration.get(s_object.Id).selected = false;
        this.s_object.put('CFAR_Unit_Type_ref_gne__c', selectedUnitType);
        PageReference pr = ctrl.save();
        if (pr != null && !ApexPages.hasMessages())
            objectMapMoleculeConfiguration.get(s_object.Id).innerObject = s_object;
        Integer currentPageNum = stdSetControllerMoleculeConfiguration.getPageNumber();


        CFAR_SearchParameters params = new CFAR_SearchParameters();
        params.sortDirection = 'asc';
        params.sortExpression = 'Name';
        params.andEqualsParameters.put('Product_gne__c', selectedProduct);

        stdSetControllerMoleculeConfiguration = new ApexPages.StandardSetController(CFAR_DAO.getMoleculeConfigurations(params));
        stdSetControllerMoleculeConfiguration.setPageSize(pageSize);
        stdSetControllerMoleculeConfiguration.setPageNumber(currentPageNum);
        fillMoleculeConfigurations();
        isEdit = false;

    }

    private void replaceInnerObject(SObject s_object, List<CFAR_SObjectWrapper> objectList, Map<Id, CFAR_SObjectWrapper> objectsMap) {
        objectsMap.get(s_object.Id).innerObject = s_object;
        boolean found = false;
        for (integer i = 0; !found && i < objectList.size(); ++i) {
            if (s_object.Id == objectList[i].innerObject.Id) {
                objectList[i].innerObject = s_object;
                found = true;
            }
        }
    }

    //view list
    private void fillWBSes() {
        objectMapWBS = new Map<Id, CFAR_SObjectWrapper>();
        objectListWBS = new List<CFAR_SObjectWrapper>();
        for (SObject s : stdSetControllerWBS.getRecords()) {
            CFAR_SObjectWrapper obj = new CFAR_SObjectWrapper(s, false);
            objectListWBS.add(obj);
            objectMapWBS.put(s.Id, obj);
        }
    }

    private void fillCostCenters() {
        objectMapCostCenter = new Map<Id, CFAR_SObjectWrapper>();
        objectListCostCenter = new List<CFAR_SObjectWrapper>();
        for (SObject s : stdSetControllerCostCenter.getRecords()) {
            CFAR_SObjectWrapper obj = new CFAR_SObjectWrapper(s, false);
            objectListCostCenter.add(obj);
            objectMapCostCenter.put(s.Id, obj);
        }
    }

    private void fillRdts() {
        objectMapRdt = new Map<Id, CFAR_SObjectWrapper>();
        objectListRdt = new List<CFAR_SObjectWrapper>();
        for (SObject s : stdSetControllerRdt.getRecords()) {
            CFAR_SObjectWrapper obj = new CFAR_SObjectWrapper(s, false);
            objectListRdt.add(obj);
            objectMapRdt.put(s.Id, obj);
        }
        System.debug('====objectMapRdt: ' + objectMapRdt);
        System.debug('====objectListRdt: ' + objectListRdt);
    }
    private void fillProducts() {
        objectMapProduct = new Map<Id, CFAR_SObjectWrapper>();
        objectListProduct = new List<CFAR_SObjectWrapper>();
        for (SObject s : stdSetControllerProduct.getRecords()) {
            CFAR_SObjectWrapper obj = new CFAR_SObjectWrapper(s, false);
            objectListProduct.add(obj);
            objectMapProduct.put(s.Id, obj);
        }
    }
    private void fillThemes() {
        objectMapTheme = new Map<Id, CFAR_SObjectWrapper>();
        objectListTheme = new List<CFAR_SObjectWrapper>();
        for (SObject s : stdSetControllerTheme.getRecords()) {
            CFAR_SObjectWrapper obj = new CFAR_SObjectWrapper(s, false);
            objectListTheme.add(obj);
            objectMapTheme.put(s.Id, obj);
        }
    }
    private void fillSRTTeam() {
        objectMapSRTTeam = new Map<Id, CFAR_SObjectWrapper>();
        objectListSRTTeam = new List<CFAR_SObjectWrapper>();
        for (SObject s : stdSetControllerSRTTeam.getRecords()) {
            CFAR_SObjectWrapper obj = new CFAR_SObjectWrapper(s, false);
            objectListSRTTeam.add(obj);
            objectMapSRTTeam.put(s.Id, obj);
        }
    }
    public void fillParentOrganizations() {
        objectMapParentOrganization = new Map<Id, CFAR_SObjectWrapper>();
        objectListParentOrganization = new List<CFAR_SObjectWrapper>();

        CFAR_SearchParameters parameters = new CFAR_SearchParameters();
        parameters.sortExpression = 'Name';
        parameters.sortDirection = 'asc';
        isEdit = false;

        if (sortExpression != null)
            parameters.sortExpression = sortExpression;

        if (sortDirection != null)
            parameters.sortDirection = sortDirection;

        if (parentOrganizationSearchString != null) {
            parameters.andLikeParameters.put('Name', parentOrganizationSearchString);
        }

        if (newStandardSetController) {
            stdSetControllerParentOrganization = new ApexPages.StandardSetController(CFAR_DAO.getParentOrganizations(parameters));
            stdSetControllerParentOrganization.setPageSize(pageSize);
        }
        newStandardSetController = true;
        for (SObject s : stdSetControllerParentOrganization.getRecords()) {
            CFAR_SObjectWrapper obj = new CFAR_SObjectWrapper(s, false);
            objectListParentOrganization.add(obj);
            objectMapParentOrganization.put(s.Id, obj);
        }
    }

    private void fillContactSelectOptions() {
        contactSelectOptions = new List<SelectOption>();
        CFAR_SearchParameters parameters = new CFAR_SearchParameters();
        for (CFAR_Contact_gne__c contact : CFAR_DAO.getActiveContacts()) {
            contactSelectOptions.add(new SelectOption(contact.Id, contact.Name));
        }
    }

    private void fillParentOrganizationSelectOptions() {
        parentOrganizationSelectOptions = new List<SelectOption>();
        CFAR_SearchParameters parameters = new CFAR_SearchParameters();
        parameters.sortExpression = 'Name';
        parameters.sortDirection = 'asc';
        parameters.andEqualsParameters.put('Active_gne__c', 'true');
        for (CFAR_Parent_Organization_gne__c organization : CFAR_DAO.getParentOrganizations(parameters)) {
            parentOrganizationSelectOptions.add(new SelectOption(organization.Id, organization.Name));
        }
    }

    public void fillUnitTypeSelectOptions() {
        unitTypeSelectOptions = new List<SelectOption>();
        CFAR_SearchParameters parameters = new CFAR_SearchParameters();
        parameters.sortExpression = 'Name';
        parameters.sortDirection = 'asc';
        parameters.andEqualsParameters.put('Active_gne__c', 'true');
        for (CFAR_Unit_Type_gne__c unitType : CFAR_DAO.getUnitTypes(parameters)) {
            unitTypeSelectOptions.add(new SelectOption(unitType.Id, unitType.Name));
        }
    }
    public void fillInstitutionSelectOptions() {
        if (selectedParentOrganization != null) {
            objectListInstitutionAddress = null;
            institutionSelectOptions = new List<SelectOption>();

            CFAR_SearchParameters parameters = new CFAR_SearchParameters();
            parameters.sortExpression = 'Name';
            parameters.sortDirection = 'asc';
            parameters.andEqualsParameters.put('Active_gne__c', 'true');

            for (CFAR_Institution_gne__c institution : CFAR_DAO.getInstitutions(parameters)) {
                institutionSelectOptions.add(new SelectOption(institution.Id, institution.Name));
            }

            initDefaultInstitutionSelectetOption();
            fillInstitutionAddresses();
        }
    }

    public void fillProductSelectOptions() {
        productSelectOptions = new List<SelectOption>();

        CFAR_SearchParameters parameters = new CFAR_SearchParameters();
        parameters.sortExpression = 'Name';
        parameters.sortDirection = 'asc';
        parameters.andEqualsParameters.put('Other_GNE_Agent_Active_gne__c', 'true');

        for (CFAR_Product_gne__c product : CFAR_DAO.getProducts(parameters)) {
            productSelectOptions.add(new SelectOption(product.Id, product.Generic_Name_gne__c));
        }

        initDefaultProductSelectetOption();
        fillMoleculeConfigurations();
    }

    public void fillAddressTypeSelectOptions() {
        addressTypeSelectOptions = new List<SelectOption>();
        for (CFAR_Address_Type_gne__c addressType : CFAR_DAO.getAddressTypes(new CFAR_SearchParameters())) {
            addressTypeSelectOptions.add(new SelectOption(addressType.Id, addressType.Name));
        }
    }

    public void fillInstitutions() {
        if (selectedParentOrganization != null) {
            objectMapInstitution = new Map<Id, CFAR_SObjectWrapper>();
            objectListInstitution = new List<CFAR_SObjectWrapper>();
            CFAR_SearchParameters parameters = new CFAR_SearchParameters();
            parameters.sortExpression = 'Name';
            parameters.sortDirection = 'asc';
            isEdit = false;
            if (sortExpression != null)
                parameters.sortExpression = sortExpression;
            if (sortDirection != null)
                parameters.sortDirection = sortDirection;

            if (institutionSearchString != null) {
                parameters.andLikeParameters.put('Name', institutionSearchString);
            }

            if (newStandardSetController) {
                initStdSetCtrlInstitution(parameters);
            }
            newStandardSetController = true;

            for (SObject institution : stdSetControllerInstitution.getRecords()) {
                CFAR_SObjectWrapper obj = new CFAR_SObjectWrapper(institution, false);
                objectListInstitution.add(obj);
                objectMapInstitution.put(institution.Id, obj);
            }
        }
    }
    public void fillInstitutionAddresses() {
        objectMapInstitutionAddress = new Map<Id, CFAR_SObjectWrapper>();
        objectListInstitutionAddress = new List<CFAR_SObjectWrapper>();
        if (selectedInstitution != null) {

            CFAR_SearchParameters parameters = new CFAR_SearchParameters();

            parameters.sortExpression = 'Country_gne__c, State_gne__c, Province_gne__c, City_gne__c, Address_gne__c ';
            parameters.sortDirection = 'asc';
            isEdit = false;
            if (sortExpression != null)
                parameters.sortExpression = sortExpression;
            if (sortDirection != null)
                parameters.sortDirection = sortDirection;
            parameters.andEqualsParameters.put('Institution_gne__c', selectedInstitution);

            if (newStandardSetController) {
                initInstitutionAddressesStdSetCtrl(parameters);
            }

            newStandardSetController = true;

            for (SObject s : stdSetControllerInstitutionAddress.getRecords()) {
                CFAR_SObjectWrapper obj = new CFAR_SObjectWrapper(s, false);
                objectListInstitutionAddress.add(obj);
                objectMapInstitutionAddress.put(s.Id, obj);
            }
        } else {
            objectListInstitutionAddress = null;
            objectMapInstitutionAddress = null;
        }
        getParentOfSelectedInstitution();
    }

    public void fillMoleculeConfigurations() {
        if (productSelectOptions == null || productSelectOptions.isEmpty()) {
            return;
        }
        if (selectedProduct == null) {
            fillProductSelectOptions();
            selectedProduct = productSelectOptions.get(0).getValue();
        }
        objectMapMoleculeConfiguration = new Map<Id, CFAR_SObjectWrapper>();
        objectListMoleculeConfiguration = new List<CFAR_SObjectWrapper>();

        CFAR_SearchParameters parameters = new CFAR_SearchParameters();
        parameters.sortExpression = 'CFAR_Unit_type_ref_gne__r.Name, Configuration_gne__c';
        parameters.sortDirection = 'asc';
        parameters.andEqualsParameters.put('Product_gne__c', selectedProduct);
        isEdit = false;

        if (sortExpression != null)
            parameters.sortExpression = sortExpression;

        if (sortDirection != null)
            parameters.sortDirection = sortDirection;

        if (newStandardSetController) {
            stdSetControllerMoleculeConfiguration = new ApexPages.StandardSetController(CFAR_DAO.getMoleculeConfigurations(parameters));
            stdSetControllerMoleculeConfiguration.setPageSize(10);
        }
        newStandardSetController = true;
        for (SObject s : stdSetControllerMoleculeConfiguration.getRecords()) {
            CFAR_SObjectWrapper obj = new CFAR_SObjectWrapper(s, false);
            objectListMoleculeConfiguration.add(obj);
            objectMapMoleculeConfiguration.put(s.Id, obj);
        }
    }


    public void getParentOfSelectedInstitution() {
        if (selectedInstitution != null) {
            CFAR_SearchParameters parameters = new CFAR_SearchParameters();
            parameters.andEqualsParameters.put('Id', selectedInstitution);
            CFAR_Institution_gne__c[] institution = CFAR_DAO.getInstitutions(parameters);
            parentOfSelectedInstitution = institution[0].Parent_Organization__r.Name;
        }
    }

    private void initDefaultInstitutionSelectetOption() {
        try {
            selectedInstitution = institutionSelectOptions.get(0).getValue();
        } catch (Exception e) {
        }
    }

    private void initDefaultOrganizationSelectetOption() {
        try {
            selectedParentOrganization = parentOrganizationSelectOptions.get(0).getValue();
        } catch (Exception e) {
        }
    }

    private void initDefaultProductSelectetOption() {
        try {
            selectedProduct = productSelectOptions.get(0).getValue();
        } catch (Exception e) {
        }
    }

    /////////////////UNIT TYPE
    public Map<Id, CFAR_SObjectWrapper> objectMapUnitType { get; set; }
    public List<CFAR_SObjectWrapper> objectListUnitType { get; set; }
    private ApexPages.StandardSetController stdSetControllerUnitType;
    //save
    public void sortUnitType() {
        stdSetControllerUnitType = new ApexPages.StandardSetController(
                Database.query('select Id, Name, Active_gne__c from CFAR_Unit_Type_gne__c order by ' + sortExpression + ' ' + sortDirection));
        stdSetControllerUnitType.setPageSize(pageSize);
        fillUnitType();
    }

    //creation
    public Boolean addUnitType { get; set; }
    public void addNewUnitType() {
        cancelAllObjects();
        addUnitType = true;
        createSObject('CFAR_Unit_Type_gne__c');
    }

    public PageReference createUnitTypeAF() {
        createUnitType();
        return null;
    }

    //create new
    public void createUnitType() {
        ApexPages.StandardController ctrl = new ApexPages.StandardController(s_object);
        if (isUnitTypeValid()) {
            isError = false;
            addUnitType = false;
            PageReference pr = ctrl.save();
            if (pr != null && !ApexPages.hasMessages()) {
                CFAR_SearchParameters params = new CFAR_SearchParameters();
                params.sortDirection = 'asc';
                params.sortExpression = 'Name';

                initStdSetCtrlUnitType(params);
                fillUnitType();
                fillUnitTypeSelectOptions();
            }
        }
    }

    public Boolean canDeleteUnitType() {
        isError = false;

        if ([SELECT COUNT() FROM CFAR_Molecule_Configuration_gne__c WHERE CFAR_Unit_Type_ref_gne__c = :objectId] > 0) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.CFAR_ADMINTAB_CANT_DELETE_UNIT_TYPE));
            isError = true;
        }
        return isError;
    }

    //delete
    public void deleteUnitType() {
        if (!canDeleteUnitType()) {
            CFAR_Utils_WithoutSharing.deleteSObject(objectMapUnitType.get(objectId).innerObject);
            CFAR_SearchParameters params = new CFAR_SearchParameters();
            params.sortDirection = 'asc';
            params.sortExpression = 'Name';
            initStdSetCtrlUnitType(params);
            fillUnitType();
        }
    }

    private void fillUnitTypeRecords() {
        objectListUnitType.clear();
        objectMapUnitType.clear();
        for (SObject s : stdSetControllerUnitType.getRecords()) {
            CFAR_SObjectWrapper obj = new CFAR_SObjectWrapper(s, false);
            objectListUnitType.add(obj);
            objectMapUnitType.put(s.Id, obj);
        }
    }

    //prevoius
    public void previousUnitType() {
        checkStdSetCtrlUnitTypeAge();
        stdSetControllerUnitType.previous();
        fillUnitTypeRecords();
    }

    //next
    public void nextUnitType() {
        checkStdSetCtrlUnitTypeAge();
        stdSetControllerUnitType.next();
        fillUnitTypeRecords();
    }

    //first
    public void firstUnitType() {
        checkStdSetCtrlUnitTypeAge();
        stdSetControllerUnitType.first();
        fillUnitTypeRecords();
    }

    //last
    public void lastUnitType() {
        checkStdSetCtrlUnitTypeAge();
        stdSetControllerUnitType.last();
        fillUnitTypeRecords();
    }

    //hasNext
    public Boolean hasNextUnitType {
        get {
            return stdSetControllerUnitType.getHasNext();
        }
        private set;
    }

    //hasPrevoius
    public Boolean hasPreviousUnitType {
        get {
            return stdSetControllerUnitType.getHasPrevious();
        }
        private set;
    }

    //edit
    public void editUnitType() {
        isEdit = true;
        objectMapUnitType.get(objectId).selected = true;
        s_object = objectMapUnitType.get(objectId).innerObject.clone(true, true, true, true);

        for (CFAR_SObjectWrapper obj : objectMapUnitType.values()) {
            if (obj.innerObject.Id != objectId) {
                obj.selected = false;
            }
        }
    }

    //cancel edit
    public void cancelEditUnitType() {
        objectMapUnitType.get(objectId).selected = false;
        isEdit = false;
    }

    public PageReference validateUnitType() {
        isUnitTypeValid();
        return null;
    }

    //validation Unit Type
    public Boolean isUnitTypeValid() {
        isError = false;
        if (s_object.get('Name') == null || s_object.get('Name') == '') {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.CFAR_ADMINTAB_UNITTYPE_CANT_BE_BLANK));
            isError = true;
        }

        if (s_object.get('Name') != null && String.valueOf(s_object.get('Name')).length() > 25) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, String.format(Label.CFAR_GSTARS_MAX_CHAR_NUMBER_EXCEEDED, new List<String>{
                    '25'
            })));
            isError = true;
        }

        // duplicate validation
        for (CFAR_Unit_Type_gne__c unitType : CFAR_DAO.getUnitTypes(new CFAR_SearchParameters())) {
            if (unitType.Name == this.s_object.get('Name') && unitType.Id != this.s_object.Id) {
                isError = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.CFAR_ADMINTAB_MOLECULE_UNITTYPE_EXISTS));
                break;
            }
        }


        isEdit = false;
        return !isError;
    }

    //save
    public void saveUnitType() {
        ApexPages.StandardController ctrl = new ApexPages.StandardController(s_object);

        if (isUnitTypeValid()) {
            objectMapUnitType.get(s_object.Id).selected = false;
            isEdit = false;
            PageReference pr = ctrl.save();
            if (pr != null && !ApexPages.hasMessages())
                objectMapUnitType.get(s_object.Id).innerObject = s_object;
            Integer currentPageNum = stdSetControllerUnitType.getPageNumber();
            CFAR_SearchParameters params = new CFAR_SearchParameters();
            params.sortDirection = 'asc';
            params.sortExpression = 'Name';

            initStdSetCtrlUnitType(params);
            stdSetControllerUnitType.setPageNumber(currentPageNum);
            fillUnitTypeSelectOptions();
        }
    }

    //view list
    public void fillUnitType() {
        objectMapUnitType = new Map<Id, CFAR_SObjectWrapper>();
        objectListUnitType = new List<CFAR_SObjectWrapper>();
        CFAR_SearchParameters parameters = new CFAR_SearchParameters();
        parameters.sortExpression = 'Name';
        parameters.sortDirection = 'asc';
        isEdit = false;
        if (sortExpression != null)
            parameters.sortExpression = sortExpression;
        if (sortDirection != null)
            parameters.sortDirection = sortDirection;

        if (unitTypeSearchString != null) {
            parameters.andLikeParameters.put('Name', unitTypeSearchString);
        }

        if (newStandardSetController) {
            initStdSetCtrlUnitType(parameters);
        }
        newStandardSetController = true;
        fillUnitTypeRecords();
    }

    /////////////////Partnership

    //save
    public void sortPartnership() {
        stdSetControllerPartnership = new ApexPages.StandardSetController(
                Database.query('select Id, Name, Active_gne__c from CFAR_Partnership_gne__c order by ' + sortExpression + ' ' + sortDirection));
        stdSetControllerPartnership.setPageSize(pageSize);
        fillPartnership();
    }

    //creation

    public Boolean addPartnership { get; set; }

    public void addNewPartnership() {
        cancelAllObjects();
        addPartnership = true;
        createSObject('CFAR_Partnership_gne__c');
    }

    public PageReference createPartnershipAF() {
        createPartnership();
        return null;
    }

    //create new
    public void createPartnership() {
        ApexPages.StandardController ctrl = new ApexPages.StandardController(s_object);
        if (isPartnershipValid()) {
            isError = false;
            addPartnership = false;
            PageReference pr = ctrl.save();
            if (pr != null && !ApexPages.hasMessages()) {
                CFAR_SearchParameters params = new CFAR_SearchParameters();
                params.sortDirection = 'asc';
                params.sortExpression = 'Name';

                initStdSetCtrlPartnership(params);
                fillPartnership();
            }
        }
    }

    public Boolean canDeletePartnership() {
        isError = false;

        for (CFAR_Trial_Gne__c t : [SELECT Partnership_Multi_gne__c FROM CFAR_Trial_gne__c WHERE Partnership_Multi_gne__c != null]) {
            if (t.Partnership_Multi_gne__c.contains(objectId)) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.CFAR_ADMINTAB_CANT_DELETE_PARTNERSHIP));
                isError = true;
                break;
            }
        }
        return isError;
    }

    //delete
    public void deletePartnership() {
        if (!canDeletePartnership()) {
            CFAR_Utils_WithoutSharing.deleteSObject(objectMapPartnership.get(objectId).innerObject);
            CFAR_SearchParameters params = new CFAR_SearchParameters();
            params.sortDirection = 'asc';
            params.sortExpression = 'Name';
            initStdSetCtrlPartnership(params);
            fillPartnership();
        }
    }

    //prevoius
    public void previousPartnership() {
        checkStdSetCtrlPartnershipAge();
        newStandardSetController = false;
        stdSetControllerPartnership.previous();
        fillPartnership();
    }

    //next
    public void nextPartnership() {
        checkStdSetCtrlPartnershipAge();
        newStandardSetController = false;
        stdSetControllerPartnership.next();
        fillPartnership();
    }

    //first
    public void firstPartnership() {
        checkStdSetCtrlPartnershipAge();
        newStandardSetController = false;
        stdSetControllerPartnership.first();
        fillPartnership();
    }

    //last
    public void lastPartnership() {
        checkStdSetCtrlPartnershipAge();
        newStandardSetController = false;
        stdSetControllerPartnership.last();
        fillPartnership();
    }

    //hasNext
    public Boolean hasNextPartnership {
        get {
            return stdSetControllerPartnership.getHasNext();
        }
        private set;
    }

    //hasPrevoius
    public Boolean hasPreviousPartnership {
        get {
            return stdSetControllerPartnership.getHasPrevious();
        }
        private set;
    }

    //edit
    public void editPartnership() {
        isEdit = true;
        objectMapPartnership.get(objectId).selected = true;
        s_object = objectMapPartnership.get(objectId).innerObject.clone(true, true, true, true);

        for (CFAR_SObjectWrapper obj : objectMapPartnership.values()) {
            if (obj.innerObject.Id != objectId) {
                obj.selected = false;
            }
        }
    }

    //cancel edit
    public void cancelEditPartnership() {
        objectMapPartnership.get(objectId).selected = false;
        isEdit = false;
        isError = false;
    }

    public PageReference validatePartnership() {
        isPartnershipValid();
        return null;
    }

    //validation Partnership
    public Boolean isPartnershipValid() {
        isError = false;
        if (s_object.get('Name') == null || s_object.get('Name') == '') {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.CFAR_ADMINTAB_PARTNERSHIP_CANT_BE_BLANK));
            isError = true;
        }

        if (s_object.get('Name') != null && String.valueOf(s_object.get('Name')).length() > 25) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, String.format(Label.CFAR_GSTARS_MAX_CHAR_NUMBER_EXCEEDED, new List<String>{
                    '25'
            })));
            isError = true;
        }

        // duplicate validation
        for (CFAR_Partnership_gne__c partnership : CFAR_DAO.getPartnerships(new CFAR_SearchParameters())) {
            if (partnership.Name == this.s_object.get('Name') && partnership.Id != this.s_object.Id) {
                isError = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.CFAR_ADMINTAB_PARTNERSHIP_EXISTS));
            }
        }


        isEdit = false;
        return !isError;
    }

    //save
    public void savePartnership() {
        ApexPages.StandardController ctrl = new ApexPages.StandardController(s_object);

        if (isPartnershipValid()) {
            objectMapPartnership.get(s_object.Id).selected = false;
            isEdit = false;
            PageReference pr = ctrl.save();
            if (pr != null && !ApexPages.hasMessages())
                objectMapPartnership.get(s_object.Id).innerObject = s_object;
            Integer currentPageNum = stdSetControllerPartnership.getPageNumber();
            CFAR_SearchParameters params = new CFAR_SearchParameters();
            params.sortDirection = 'asc';
            params.sortExpression = 'Name';

            initStdSetCtrlPartnership(params);
            stdSetControllerPartnership.setPageNumber(currentPageNum);
        }
    }

    //view list
    public void fillPartnership() {
        objectMapPartnership = new Map<Id, CFAR_SObjectWrapper>();
        objectListPartnership = new List<CFAR_SObjectWrapper>();

        CFAR_SearchParameters parameters = new CFAR_SearchParameters();
        parameters.sortExpression = 'Name';
        parameters.sortDirection = 'asc';
        isEdit = false;

        if (sortExpression != null)
            parameters.sortExpression = sortExpression;

        if (sortDirection != null)
            parameters.sortDirection = sortDirection;

        if (PartnershipSearchString != null) {
            parameters.andLikeParameters.put('Name', PartnershipSearchString);
        }

        if (newStandardSetController) {
            stdSetControllerPartnership = new ApexPages.StandardSetController(CFAR_DAO.getPartnerships(parameters));
            stdSetControllerPartnership.setPageSize(pageSize);
        }

        newStandardSetController = true;
        for (SObject s : stdSetControllerPartnership.getRecords()) {
            CFAR_SObjectWrapper obj = new CFAR_SObjectWrapper(s, false);
            objectListPartnership.add(obj);
            objectMapPartnership.put(s.Id, obj);
        }
    }
    public Boolean canDeleteSRTTeam() {
        isError = false;
        for (CFAR_Trial_gne__c g : [SELECT SRT_Team_ref_gne__c FROM CFAR_Trial_gne__c WHERE SRT_Team_ref_gne__c = :objectId]) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.CFAR_ADMINTAB_CANT_DELETE_SRTTEAM));
            isError = true;
            break;
        }
        return isError;
    }

    //delete
    public void deleteSRTTeam() {
        if (!canDeleteSRTTeam()) {
            CFAR_Utils_WithoutSharing.deleteSObject(objectMapSRTTeam.get(objectId).innerObject);
            CFAR_SearchParameters params = new CFAR_SearchParameters();
            params.sortDirection = 'asc';
            params.sortExpression = 'Name';
            initStdSetCtrlSRTTeam(params);
            fillSRTTeam();
        }
    }

/////////////////Institution Address
    public void onCountryChange() {
        if (this.s_object.get('Country_gne__c') == 'USA') {
            this.s_object.put('Province_gne__c', null);
            this.s_object.put('Postal_Code_gne__c', null);
        } else {
            this.s_object.put('Zip_gne__c', null);
            this.s_object.put('State_gne__c', null);
        }
    }

    public List<SelectOption> getCountriesList() {
        List<SelectOption> options = new List<SelectOption>(); //{new SelectOption('', '--None--')};
        Map<String, CFAR_Countries_gne__c> countries = CFAR_Countries_gne__c.getAll();
        List<String> countryNames = new List<String>();

        for (String country : countries.keySet()) {
            countryNames.add(countries.get(country).Country_Name_gne__c);
        }

        countryNames.sort();

        for (String countryName : countryNames) {
            options.add(new SelectOption(countryName, countryName));
        }

        return options;
    }

    public List<SelectOption> getStatesList() {
        List<SelectOption> options = new List<SelectOption>{
                new SelectOption('', '--None--')
        };
        Map<String, CFAR_States_gne__c> states = CFAR_States_gne__c.getAll();
        List<String> stateNames = new List<String>();

        for (String state : states.keySet()) {
            stateNames.add(states.get(state).State_Name_gne__c);
        }

        stateNames.sort();

        for (String stateName : stateNames) {
            options.add(new SelectOption(stateName, stateName));
        }

        return options;
    }


/////////////////Field History
    public List<HistoryWrapper> fieldHistory { get; set; }
    public List<HistoryWrapper> displayedFieldHistory { get; set; }
    public Integer currentPageFieldHistory;
    public Integer pageSizeFieldHistory;
    public String historyTrialId { get; set; }

    private Integer lastPageFieldHistory;
    private Set<Id> trialObjectIdSet = new Set<Id>();
    private Map<Id, CFAR_Team_Member_gne__c> tmMap;
    private Map<Id, CFAR_Budget_Contract_Tracking_gne__c> bctMap;
    private Map<Id, CFAR_Comment_gne__c> cMap;
    private Map<Id, CFAR_Budget_CPS_Payments_gne__c> bpMap;

    private Map<Id, CFAR_Contact_gne__c> contactMap;

    private void historyInitialization() {
        historyTrialId = '';
        initWholeTrialsSelectOptionsList();
    }

    public void historyInitNewTrial() {
        populateTrialObjectIdSet();
        firstFieldHistory();
    }

    private List<SelectOption> wholeTrialsSelectOptions;
    private transient List<SelectOption> trialSelectOptions1;
    private transient List<SelectOption> trialSelectOptions2;
    private transient List<SelectOption> trialSelectOptions3;
    private transient List<SelectOption> trialSelectOptions4;

    private void initWholeTrialsSelectOptionsList() {
        wholeTrialsSelectOptions = new List<SelectOption>{
                new SelectOption('', '--None--')
        };
        CFAR_SearchParameters parameters = new CFAR_SearchParameters();
        parameters.sortExpression = 'LastModifiedDate';
        parameters.sortDirection = 'asc';
        wholeTrialsSelectOptions.addAll(CFAR_Utils.getTrialSelectOptions(parameters));
        System.debug('Slawek DBG wholeTrialsSelectOptions: ' + wholeTrialsSelectOptions.size());
    }

    public List<SelectOption> getTrialSelectOptions1() {
        trialSelectOptions1 = CFAR_Utils.getObjectSearchListPart1(wholeTrialsSelectOptions);
        System.debug('Slawek DBG trialSelectOptions1: ' + trialSelectOptions1.size());
        return trialSelectOptions1;
    }

    public List<SelectOption> getTrialSelectOptions2() {
        trialSelectOptions2 = CFAR_Utils.getObjectSearchListPart2(wholeTrialsSelectOptions);
        System.debug('Slawek DBG trialSelectOptions2: ' + trialSelectOptions2.size());
        return trialSelectOptions2;
    }

    public List<SelectOption> getTrialSelectOptions3() {
        trialSelectOptions3 = CFAR_Utils.getObjectSearchListPart3(wholeTrialsSelectOptions);
        System.debug('Slawek DBG trialSelectOptions3: ' + trialSelectOptions3.size());
        return trialSelectOptions3;
    }

    public List<SelectOption> getTrialSelectOptions4() {
        trialSelectOptions4 = CFAR_Utils.getObjectSearchListPart4(wholeTrialsSelectOptions);
        System.debug('Slawek DBG trialSelectOptions4: ' + trialSelectOptions4.size());
        return trialSelectOptions4;
    }

    private void populateTrialObjectIdSet() {
        trialObjectIdSet = new Set<Id>();
        tmMap = new Map<Id, CFAR_Team_Member_gne__c>([SELECT Id,frm_Name_gne__c FROM CFAR_Team_Member_gne__c WHERE CFAR_Trial_ref_gne__c = :historyTrialId]);
        //DONE: ITERATION2 MultiContract
        bctMap = new Map<Id, CFAR_Budget_Contract_Tracking_gne__c>([SELECT Id, Name, Type_ref_gne__r.Name, Budget_Contract_ref_gne__r.Team_Member_ref_gne__r.CFAR_Trial_ref_gne__c FROM CFAR_Budget_Contract_Tracking_gne__c WHERE Budget_Contract_ref_gne__r.Team_Member_ref_gne__r.CFAR_Trial_ref_gne__c = :historyTrialId]);
        cMap = new Map<Id, CFAR_Comment_gne__c>([SELECT Id, Name, Created_By_CFAR_Contact_ref_gne__r.Name FROM CFAR_Comment_gne__c WHERE CFAR_Trial_ref_gne__c = :historyTrialId]);
        //DONE: ITERATION2 MultiContract
        bpMap = new Map<Id, CFAR_Budget_CPS_Payments_gne__c>([SELECT Id, Name, Payment_Status_ref_gne__r.Name, Line_Num_gne__c, Budget_Contract_ref_gne__r.Team_Member_ref_gne__r.CFAR_Trial_ref_gne__c FROM CFAR_Budget_CPS_Payments_gne__c WHERE Budget_Contract_ref_gne__r.Team_Member_ref_gne__r.CFAR_Trial_ref_gne__c = :historyTrialId]);

        contactMap = new Map<Id, CFAR_Contact_gne__c>([SELECT Id, Name, Search_Name__c FROM CFAR_Contact_gne__c]);

        system.debug(LoggingLevel.INFO, '***** tmMap: ' + tmMap);
        system.debug(LoggingLevel.INFO, '***** bctMap: ' + bctMap);
        system.debug(LoggingLevel.INFO, '***** cMap: ' + cMap);
        system.debug(LoggingLevel.INFO, '***** bpMap: ' + bpMap);

        for (Id tm : tmMap.keySet()) {
            trialObjectIdSet.add(tm);
        }
        for (Id bct : bctMap.keySet()) {
            trialObjectIdSet.add(bct);
        }
        for (Id c : cMap.keySet()) {
            trialObjectIdSet.add(c);
        }
        for (Id bp : bpMap.keySet()) {
            trialObjectIdSet.add(bp);
        }
    }

    public void sortFieldHistory() {
        fieldHistory = new List<HistoryWrapper>();
        displayedFieldHistory = new List<HistoryWrapper>();

        List<CFAR_Trial_gne__history> trialList = [Select NewValue, OldValue, CreatedDate, CreatedById, Field, ParentId FROM CFAR_Trial_gne__history where parentId = :historyTrialId and (Field = 'Baselined__c' or Field = 'Last_Re_Baseline_Time_gne__c')];

        List<CFAR_Team_Member_gne__history> teamList = [Select NewValue, OldValue, CreatedDate, CreatedById, Field, ParentId FROM CFAR_Team_Member_gne__history where parentId IN:trialObjectIdSet];
        List<CFAR_Budget_Contract_Tracking_gne__history> contractList = [Select NewValue, OldValue, CreatedDate, CreatedById, Field, ParentId FROM CFAR_Budget_Contract_Tracking_gne__history where parentId IN:trialObjectIdSet];
        List<CFAR_Comment_gne__history> commentList = [Select NewValue, OldValue, CreatedDate, CreatedById, Field, ParentId FROM CFAR_Comment_gne__history where parentId IN:trialObjectIdSet];
        List<CFAR_Budget_CPS_Payments_gne__history> paynmentList = [Select NewValue, OldValue, CreatedDate, CreatedById, Field, ParentId FROM CFAR_Budget_CPS_Payments_gne__history where parentId IN:trialObjectIdSet];

        system.debug(LoggingLevel.INFO, '***** teamList: ' + teamList);
        system.debug(LoggingLevel.INFO, '***** contractList: ' + contractList);
        system.debug(LoggingLevel.INFO, '***** commentList: ' + commentList);
        system.debug(LoggingLevel.INFO, '***** paynmentList: ' + paynmentList);

        Map<String, Schema.SObjectField> tFieldMap = Schema.SObjectType.CFAR_Trial_gne__c.fields.getMap();
        Map<String, Schema.SObjectField> tmFieldMap = Schema.SObjectType.CFAR_Team_Member_gne__c.fields.getMap();
        Map<String, Schema.SObjectField> bctFieldMap = Schema.SObjectType.CFAR_Budget_Contract_Tracking_gne__c.fields.getMap();
        Map<String, Schema.SObjectField> cFieldMap = Schema.SObjectType.CFAR_Comment_gne__c.fields.getMap();
        Map<String, Schema.SObjectField> bpFieldMap = Schema.SObjectType.CFAR_Budget_CPS_Payments_gne__c.fields.getMap();


        Set<Id> userIdSet = new Set<Id>();
        for (CFAR_Trial_gne__history h : trialList) {
            userIdSet.add(h.CreatedById);
        }
        for (CFAR_Team_Member_gne__history h : teamList) {
            userIdSet.add(h.CreatedById);
        }
        for (CFAR_Budget_Contract_Tracking_gne__history h : contractList) {
            userIdSet.add(h.CreatedById);
        }
        for (CFAR_Comment_gne__history h : commentList) {
            userIdSet.add(h.CreatedById);
        }
        for (CFAR_Budget_CPS_Payments_gne__history h : paynmentList) {
            userIdSet.add(h.CreatedById);
        }
        Map<ID, User> userMap = new Map<ID, User>([SELECT Id, Name FROM User WHERE Id IN :userIdSet]);
        for (CFAR_Trial_gne__history h : trialList) {
            HistoryWrapper history = new HistoryWrapper();
            history.objectName = 'Milestone Activity';
            history.changeDate = h.CreatedDate;
            history.modifyBy = userMap.get(h.CreatedById).Name;
            if (tFieldMap.get(h.Field) != null) {
                history.Field = tFieldMap.get(h.Field).getDescribe().getLabel();
            } else {
                history.Field = h.Field;
            }
            fieldHistory.add(history);
        }
        for (CFAR_Team_Member_gne__history h : teamList) {
            HistoryWrapper history = new HistoryWrapper();
            history.objectName = 'Team Member';
            history.parentId = (tmMap.containsKey(h.parentId)) ? tmMap.get(h.parentId).frm_Name_gne__c : '';
            history.changeDate = h.CreatedDate;
            history.modifyBy = userMap.get(h.CreatedById).Name;
            if (tmFieldMap.get(h.Field) != null) {
                history.Field = tmFieldMap.get(h.Field).getDescribe().getLabel();
            } else {
                history.Field = h.Field;
            }
            if (history.Field == 'Active On' || history.Field == 'Inactive On') {
                history.newValue = parseDate(h.NewValue != null ? String.valueOf(h.NewValue) : null);
                history.oldValue = parseDate(h.NewValue != null ? String.valueOf(h.NewValue) : null);
            } else {
                history.newValue = h.NewValue != null ? String.valueOf(h.NewValue) : null;
                history.oldValue = h.oldValue != null ? String.valueOf(h.oldValue) : null;
            }
            fieldHistory.add(history);
        }
        for (CFAR_Budget_Contract_Tracking_gne__history h : contractList) {
            HistoryWrapper history = new HistoryWrapper();
            history.objectName = 'Budget Contract Tracking';
            history.parentId = (bctMap.containsKey(h.parentId)) ? bctMap.get(h.parentId).Name : '';
            history.changeDate = h.CreatedDate;
            history.modifyBy = userMap.get(h.CreatedById).Name;
            if (bctFieldMap.get(h.Field) != null) {
                history.Field = bctFieldMap.get(h.Field).getDescribe().getLabel();
            } else {
                history.Field = h.Field;
            }
            if (history.Field == 'Contract Expiry Date' || history.Field == 'Fully Executed Date') {
                history.newValue = parseDate(h.NewValue != null ? String.valueOf(h.NewValue) : null);
                history.oldValue = parseDate(h.OldValue != null ? String.valueOf(h.OldValue) : null);
            } else if (history.Field == 'Contract Type') {
                if (checkIsId(String.valueOf(h.NewValue)) && checkIsId(String.valueOf(h.oldValue))) {
                    continue;
                }
                history.newValue = String.valueOf(h.NewValue);
                history.oldValue = String.valueOf(h.oldValue);
            } else {
                history.newValue = h.NewValue != null ? String.valueOf(h.NewValue) : null;
                history.oldValue = h.oldValue != null ? String.valueOf(h.oldValue) : null;
            }
            fieldHistory.add(history);
        }
        for (CFAR_Comment_gne__history h : commentList) {
            HistoryWrapper history = new HistoryWrapper();
            history.objectName = 'Comment';
            history.parentId = (cMap.containsKey(h.parentId)) ? cMap.get(h.parentId).Name : '';
            history.changeDate = h.CreatedDate;
            history.modifyBy = userMap.get(h.CreatedById).Name;
            if (cFieldMap.get(h.Field) != null) {
                history.Field = cFieldMap.get(h.Field).getDescribe().getLabel();
            } else {
                history.Field = h.Field;
            }
            if (history.Field == 'Activity Date') {
                history.newValue = parseDate(h.NewValue != null ? String.valueOf(h.NewValue) : null);
                history.oldValue = parseDate(h.OldValue != null ? String.valueOf(h.OldValue) : null);
            } else if (history.Field == 'Created By') {
                if (!checkIsId(String.valueOf(h.NewValue)) && !checkIsId(String.valueOf(h.oldValue))) {
                    continue;
                }
                if (contactMap.containsKey(String.valueOf(h.NewValue))) {
                    history.newValue = contactMap.get(String.valueOf(h.NewValue)).Search_Name__c;
                } else {
                    history.newValue = '';
                }
                if (contactMap.containsKey(String.valueOf(h.OldValue))) {
                    history.oldValue = contactMap.get(String.valueOf(h.OldValue)).Search_Name__c;
                } else {
                    history.oldValue = '';
                }
            } else {
                history.newValue = h.NewValue != null ? String.valueOf(h.NewValue) : null;
                history.oldValue = h.oldValue != null ? String.valueOf(h.oldValue) : null;
            }
            fieldHistory.add(history);
        }
        for (CFAR_Budget_CPS_Payments_gne__history h : paynmentList) {
            HistoryWrapper history = new HistoryWrapper();
            history.objectName = 'Budget CPS Payments';
            history.parentId = (bpMap.containsKey(h.parentId)) ? String.valueOf(bpMap.get(h.parentId).Line_Num_gne__c) : '';
            history.changeDate = h.CreatedDate;
            history.modifyBy = userMap.get(h.CreatedById).Name;
            if (bpFieldMap.get(h.Field) != null) {
                history.Field = bpFieldMap.get(h.Field).getDescribe().getLabel();
            } else {
                history.Field = h.Field;
            }
            if (history.Field == 'Invoice Date' || history.Field == 'Paid On' || history.Field == 'Planned Date') {
                history.newValue = parseDate(h.NewValue != null ? String.valueOf(h.NewValue) : null);
                history.oldValue = parseDate(h.OldValue != null ? String.valueOf(h.OldValue) : null);
            } else if (history.Field == 'Payment Status') {
                if (checkIsId(String.valueOf(h.NewValue)) && checkIsId(String.valueOf(h.oldValue))) {
                    continue;
                }
                history.newValue = String.valueOf(h.NewValue);
                history.oldValue = String.valueOf(h.oldValue);
            } else {
                history.newValue = h.NewValue != null ? String.valueOf(h.NewValue) : null;
                history.oldValue = h.oldValue != null ? String.valueOf(h.oldValue) : null;
            }
            fieldHistory.add(history);
        }
        lastPageFieldHistory = getLastPageNum();
        Integer index = 0;
        fieldHistory.sort();
        for (HistoryWrapper fh : fieldHistory) {
            if (index >= currentPageFieldHistory * pageSize && index < (currentPageFieldHistory + 1) * pageSize) {
                displayedFieldHistory.add(fh);
            }
            index++;
        }
        system.debug(LoggingLevel.INFO, '**** displayedFieldHistory:' + displayedFieldHistory);
    }

    public Integer getLastPageNum() {
        if (math.mod(fieldHistory.size(), pageSize) > 0) {
            return fieldHistory.size() / pageSize;
        } else {
            return (fieldHistory.size() / pageSize) - 1;
        }
    }

    public static Boolean checkIsId(String value) {
        if (value.length() != 15 && value.length() != 18) {
            return false;
        }
        if (value.indexOf('0') == -1) {
            return false;
        }
        return true;
    }

    public static String parseDate(String d) {
        String parsedDate = '';
        if (d == null) {
            return parsedDate;
        }
        String[] splittedString = d.split('-');
        parsedDate += splittedString[1] + '/';
        parsedDate += splittedString[2].substring(0, 2) + '/';
        parsedDate += splittedString[0];
        return parsedDate;
    }

    //prevoius
    public void previousFieldHistory() {
        currentPageFieldHistory--;
        sortFieldHistory();
    }

    //next
    public void nextFieldHistory() {
        currentPageFieldHistory++;
        sortFieldHistory();
    }

    //first
    public void firstFieldHistory() {
        currentPageFieldHistory = 0;
        sortFieldHistory();
    }

    //last
    public void lastFieldHistory() {
        currentPageFieldHistory = lastPageFieldHistory;
        sortFieldHistory();
    }

    //hasNext
    public Boolean hasNextFieldHistory {
        get {
            return currentPageFieldHistory < lastPageFieldHistory;
        }
        private set;
    }

    //hasPrevoius
    public Boolean hasPreviousFieldHistory {
        get {
            return currentPageFieldHistory > 0;
        }
        private set;
    }

    global class HistoryWrapper implements Comparable {
        public String parentId { get; set; }
        public String oldValue { get; set; }
        public String newValue { get; set; }
        public DateTime changeDate { get; set; }
        public String modifyBy { get; set; }
        public String field { get; set; }
        public String objectName { get; set; }

        public HistoryWrapper() {

        }

        global Integer compareTo(Object compareTo) {
            HistoryWrapper compareToHW = (HistoryWrapper) compareTo;
            if (changeDate == compareToHW.changeDate) return 0;
            if (changeDate > compareToHW.changeDate) return 1;
            return -1;
        }
    }

    public PageReference exportToExcelClick() {
        PageReference pageRef = null;
        if (!String.isEmpty(historyTrialId)) {
            pageRef = new PageReference('/apex/CFAR_FieldHistoryXLS');
            pageRef.getParameters().put('id', historyTrialId);
            pageRef.setRedirect(true);
            //to avoid problem with going back and seeing trialId set without values in table
            //historyTrialId = '';
        }
        return pageRef;
    }
    public List<SelectOption> themeSelectOptions {
        get {
            CFAR_SearchParameters searchParms = new CFAR_SearchParameters();
            searchParms.andEqualsParameters.put('Active_gne__c', 'true');
            searchParms.sortExpression = 'Name';
            searchParms.sortDirection = 'asc';
            List<SelectOption> selectOptions = CFAR_Utils.getThemeSelectOptions(searchParms);
            SelectOption selectedOption;
            for (SelectOption so : selectOptions) {
                if (so.getValue() == this.s_object.get('Theme_ref_gne__c')) {
                    selectedOption = so;
                }
            }
            if (selectedOption != null) {
                selectOptions.remove(selectOptions.indexOf(selectedOption));
                selectOptions.add(1, selectedOption);
            }
            selectOptions.add(0, new SelectOption('', '--None--'));
            return selectOptions;
        } set; }
    
        public List<SelectOption> rdtSelectOptions {
            get {
                List<SelectOption> rdtSelectOptions = new List<SelectOption>();
                for (Schema.PicklistEntry entry : CFAR_Tracking_Activity_gne__c.Study_Stage__c.getDescribe().getPicklistValues()) {
                    rdtSelectOptions.add(new SelectOption(entry.label, entry.value));
                }
                return rdtSelectOptions;
            }
            set;
        }
        
}