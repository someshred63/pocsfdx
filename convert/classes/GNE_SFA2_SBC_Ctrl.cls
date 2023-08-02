global with sharing virtual class GNE_SFA2_SBC_Ctrl extends GNE_SFA2_Base_Ctrl {

    protected transient Map<String, Schema.DescribeFieldResult> accountFieldsDescribe;
    protected transient Map<String, Schema.DescribeFieldResult> addressFieldsDescribe;
    protected transient Map<String, Map<String, AccountTypeWrapper>> accountTypesMap;
    protected transient SFASearchStrings_gne__c hcpSearchRec;
    protected transient SFASearchStrings_gne__c hcoSearchRec;
    protected transient SFASearchStrings_gne__c currentSearchRec;
    protected transient Id defaultAccountOwnerId;
    public transient Boolean isCreateAddressMode;
    protected transient Id accountId;
    protected transient String mdmId;
    protected transient Account currentAccount;
    protected transient Boolean isHcp;
    protected transient Boolean isFRMHCOMode;
    protected transient Set<String> existingAddrMdmIds;
    protected transient String accLookupFieldId;
    protected transient String accLookupFieldDesc;
    protected transient Map<Id, AccountShare> existingAccShares;
    protected transient Map<String, TSF_vod__c> existingTSFs;
    protected transient Account upsertedAccount;
    protected transient List<Address_vod__c> upsertedAddresses;
    protected transient List<TSF_vod__c> upsertedTSFs;
    private transient GNE_SFA2_UserPreference_Ctrl hiddenAddressCtrl;

    private static final Map<String, String> helpTexts = new Map<String, String>{
            'Account.name' => System.Label.GNE_SFA2_SBC_HelpText_AccName,
            'Account.firstname' => System.Label.GNE_SFA2_SBC_HelpText_AccFirstName,
            'Account.middle_vod__c' => System.Label.GNE_SFA2_SBC_HelpText_AccMiddleName,
            'Account.lastname' => System.Label.GNE_SFA2_SBC_HelpText_AccLastName,
            'Account.professional_type_gne__c' => System.Label.GNE_SFA2_SBC_HelpText_AccProfType,
            'Account.credentials_vod__c' => System.Label.GNE_SFA2_SBC_HelpText_AccCredentials,
            'Account.account_type_gne__c' => System.Label.GNE_SFA2_SBC_HelpText_AccType,
            'Address_vod__c.name' => System.Label.GNE_SFA2_SBC_HelpText_AddrName,
            'Address_vod__c.address_line_2_vod__c' => System.Label.GNE_SFA2_SBC_HelpText_AddrSuite,
            'Address_vod__c.city_vod__c' => System.Label.GNE_SFA2_SBC_HelpText_AddrCity,
            'Address_vod__c.state_vod__c' => System.Label.GNE_SFA2_SBC_HelpText_AddrState,
            'Address_vod__c.zip_vod__c' => System.Label.GNE_SFA2_SBC_HelpText_AddrZip,
            'territory' => System.Label.GNE_SFA2_SBC_HelpText_Territory,
            'Account.sap_id_gne__c' => System.Label.GNE_SFA2_SBC_HelpText_AccSapId,
            'Account.web_order_enabled_gne__c' => System.Label.GNE_SFA2_SBC_HelpText_AccWebOrder
    };

    private static final Map<String, String> searchFieldNamesMap = new Map<String, String>{
            'LastName_gne__c' => 'personName',
            'OrgName_gne__c' => 'organizationName',
            'Street_gne__c' => 'streetAddress',
            'City_gne__c' => 'cityName',
            'State_gne__c' => 'stateCode',
            'Zip_gne__c' => 'zipCode',
            'License_Number_gne__c' => 'licenseNumber',
            'License_State_gne__c' => 'stateCode',
            'MDMID_gne__c' => 'MDMID',
            'FRM_Account_Type_gne__c' => 'orgType'
    };

    private static final String NO_TERRITORY_SELECTED = System.Label.GNE_SFA2_SBC_PicklistValue_NoTerritorySelected;
    public static final String REC_TYPE_HCP = 'Professional_vod';
    public static final String REC_TYPE_LWO_HCP = 'LWO Healthcare Professional_gne';
    public static final String REC_TYPE_LWO_HCO = 'LWO Health Care Organization_gne';
    public static final String REC_TYPE_ADDR_REP = 'RepMaintained';
    public static final String REC_TYPE_ADDR_COMPANY = 'CompanyMaintained';
    public static final String REC_TYPE_ADDR_CANADA_HCP_REP = 'SFA_Canada_Rep_Maintained_HCP';
    public static final String REC_TYPE_ADDR_CANADA_HCO_REP = 'SFA_Canada_Rep_Maintained_HCO';
    public static final String HCP_SEARCH_MODE = 'hcpSearch';
    public static final String HCO_SEARCH_MODE = 'hcoSearch';

    public GNE_SFA2_SBC_Ctrl(ApexPages.StandardController sctrl) {
        this();
    }

    public GNE_SFA2_SBC_Ctrl() {
        super();

        if (ApexPages.currentPage() != null && ApexPages.currentPage().getUrl().containsIgnoreCase(Page.GNE_SFA2_SBC_Sidebar.getUrl())) {
            dataWrapper.uiType = uiType = uiType + '-sidebar';
            includeCommonStyles = false;
        }
    }

    public override GNE_SFA2_Base_Ctrl.DataWrapper intInit(Map<String, String> params) {
        this.params = params.clone();
        this.params.put('sObjectType', 'SFASearchStrings_gne__c');
        this.activeMenuItem = 'My Accounts';
        this.pageExtId = 'sbc';
        return super.intInit(this.params);
    }

    protected override Boolean pageDispatcher() {
        return !Pattern.matches('(?i)^.*Canada.*$', getCurrentUserProfileName()) && hasAccess();
    }

    @TestVisible
    protected override PageReference getDispatcherOtherPage() {
        PageReference result = super.getDispatcherOtherPage();

        if (appContext.isSfa2Mode) {
            result = Page.GNE_SFA2_Account_Search_Before_Create;
        } else {
            if (isCreateAddressMode()) {
                //   result = hasAccess() ? new PageReference(getAddressCreateUrl()) : getAccessDeniedPage();
                result = new PageReference(getAddressCreateUrl());
            } else {
                result = Page.GNE_Account_Search_Create;
            }
        }

        return result;
    }

    private Boolean hasAccess() {
        Boolean result = true;
        if (isCreateAddressMode() && isStandardUI == true && isHcp == false) {
            result = false;
        }
        return result;
    }

    private PageReference getAccessDeniedPage() {
        PageReference result = null;
        if (GNE_SFA2_Util.isBamCrmUser()) {
            result = Page.GNE_CRM_Access_Denied;
        }
        return result;
    }

    protected override virtual GNE_SFA2_Base_Ctrl.DataWrapper getDataWrapperInstance() {
        return new DataWrapper();
    }

    protected override GNE_SFA2_Base_Ctrl.DataWrapper getDataWrapper(GNE_SFA2_Base_Ctrl.DataWrapper dataWrapper) {
        DataWrapper result = (DataWrapper) super.getDataWrapper(dataWrapper);

        if (isCreateAddressMode()) {
            result = getDataWrapperInCreateAddressMode();
        }

        result.isFRMHCOMode = getFRMHCOMode() || getCurrentUserProfileName().toUpperCase().contains('340B');

        return result;
    }

    private DataWrapper getDataWrapperInCreateAddressMode() {
        DataWrapper result = (DataWrapper) this.dataWrapper;
        result.isCreateAddressMode = true;
        result.mdmId = mdmId;
        result.accountId = accountId;
        result.addressCreateUrl = getAddressCreateUrl();
        this.inputDataWrapper = result;

        GNE_SFA2_Base_Ctrl.Field mdmFld = new GNE_SFA2_Base_Ctrl.Field('MDMID', '');
        mdmFld.setValue(mdmId);
        String accMode = getAccountMode(result.sbcMode);
        result.searchData = new Map<String, SearchData>{
                accMode => new SearchData(GNE_SFA2_SBC_Config.SearchModes.MDMId.name(), new List<GNE_SFA2_Base_Ctrl.Field>{
                        mdmFld
                })
        };

        if (String.isNotBlank(mdmId)) {
            result = getAddressesFromMdm(accMode);
        }

        SearchData searchData = result.searchData.get(accMode);
        List<SearchAccountWrapper> accountRows = searchData.results;
        List<Address_vod__c> hiddenAddresses = String.isNotBlank(accountId) ? getHiddenAddressCtrl().getHiddenAddresses(getCurrentUser().id, accountId) : null;

        if (hiddenAddresses != null && !hiddenAddresses.isEmpty()) {
            if (accountRows.isEmpty()) {
                searchData.accountColumns = getSearchAccountColumns(accMode);
                searchData.addressColumns = getSearchAddressColumns(accMode);
                searchData.accountAdditionalColumns = getSearchAccountAdditionalColumns(accMode);
                SearchAccountWrapper newWrapper = new SearchAccountWrapper();
                newWrapper.id = accountId;
                newWrapper.addresses = new List<SearchAddressWrapper>();
                accountRows.add(newWrapper);
            }

            SearchAccountWrapper accWrapper = accountRows[0];
            Set<String> visitedAddrMdmIds = new Set<String>();

            for (SearchAddressWrapper addrWrapper : accWrapper.addresses) {
                visitedAddrMdmIds.add(addrWrapper.mdmAddrId);
            }

            for (Address_vod__c addr : hiddenAddresses) {
                if (String.isBlank(addr.MDM_Address_ID_gne__c) || !visitedAddrMdmIds.contains(addr.MDM_Address_ID_gne__c)) {
                    new SearchAddressWrapper(addr, accWrapper);
                }
            }

            if (accountRows.isEmpty()) {
                accountRows.add(accWrapper);
            }
        }

        if (accountRows.isEmpty() || accountRows[0].addresses == null || accountRows[0].addresses.isEmpty()) {
            result.retUrl = result.addressCreateUrl;
        }

        return result;
    }

    private DataWrapper getAddressesFromMdm(String accMode) {
        DataWrapper result = (DataWrapper) this.dataWrapper;

        Boolean isOk = false;
        try {
            result = intSearchAccounts(false, false);
            isOk = true;
        } catch (GNE_SFA2_SBC_DAO.ServiceException mex) {
        }

        if (isOk) {
            List<SearchAccountWrapper> accountRows = result.searchData.get(accMode).results;
            List<Address_vod__c> hiddenAddresses = getHiddenAddressCtrl().getHiddenAddresses(getCurrentUser().id, accountId);

            Set<String> hiddenAddrMdmIds = new Set<String>();
            for (Address_vod__c addr : hiddenAddresses) {
                if (String.isNotBlank(addr.MDM_Address_ID_gne__c)) {
                    hiddenAddrMdmIds.add(addr.MDM_Address_ID_gne__c);
                }
            }

            for (SearchAccountWrapper accRow : accountRows) {
                List<SearchAddressWrapper> newResults = new List<SearchAddressWrapper>();
                for (SearchAddressWrapper addrRow : accRow.addresses.clone()) {
                    if (!existingAddrMdmIds.contains(addrRow.mdmAddrId) || hiddenAddrMdmIds.contains(addrRow.mdmAddrId)) {
                        newResults.add(addrRow);
                    }
                }

                accRow.addresses = newResults;
            }
        }

        return result;
    }

    protected virtual override void checkRecordAccess(RecordAccess rAccess) {
        // No validation, because no access is needed
    }

    public virtual override Map<String, String> getTranslationsMap() {
        return new Map<String, String>{
                'pageTitle' => isCreateAddressMode() ? System.Label.GNE_SFA2_SBC_PageLabel_CreateAddressTitle : System.Label.GNE_SFA2_SBC_PageLabel_Title,
                'createHcpPageTitle' => System.Label.GNE_SFA2_SBC_Section_CreateHCP,
                'helpText' => System.Label.GNE_SFA2_SBC_PageLabel_HelpText,
                'addressHelpText' => System.Label.GNE_SFA2_SBC_PageLabel_AddressHelpText,
                'sidebarHelpText' => System.Label.GNE_SFA2_SBC_PageLabel_SidebarHelpText,
                'buttonSearch' => System.Label.GNE_SFA2_SBC_Button_Search,
                'buttonClear' => System.Label.GNE_SFA2_SBC_Button_Clear,
                'buttonCreate' => isSfaBrandUser != true ? System.Label.GNE_SFA2_SBC_Button_Create : System.Label.GNE_SFA2_SBC_Button_Create_Customer,
                'buttonSave' => System.Label.GNE_SFA2_SBC_Button_Save,
                'buttonCancel' => System.Label.GNE_SFA2_SBC_Button_Cancel,
                'buttonCreateAddress' => System.Label.GNE_SFA2_SBC_Button_CreateAddress,
                'selectAccountLabel' => System.Label.GNE_SFA2_SBC_PageLabel_SelectAccount,
                'selectAccountHelpText' => System.Label.GNE_SFA2_SBC_HelpText_SelectAccount,
                'expandAccountHelpText' => System.Label.GNE_SFA2_SBC_HelpText_ExpandAccount,
                'noRecordsFound' => System.Label.GNE_SFA2_SBC_PageLabel_NoRecordsFound,
                'googleMapHelpText' => System.Label.GNE_SFA2_SBC_HelpText_GoogleMap,
                'nameAddressStateMandatoryError' => System.Label.GNE_SFA2_SBC_Error_NameAddressStateMandatory,
                'resultsLabel' => System.Label.GNE_SFA2_SBC_Section_AccountResults,
                'resultsInfo' => System.Label.GNE_SFA2_SBC_PageLabel_ResultsInfo,
                'resultsInfoSinglePage' => System.Label.GNE_SFA2_SBC_PageLabel_ResultsInfoSinglePage,
                'resultsInfoOnePage' => System.Label.GNE_SFA2_SBC_PageLabel_ResultsInfoOnePage,
                'addressResultsInfo' => System.Label.GNE_SFA2_SBC_PageLabel_AddressResultsInfo,
                'buttonSearchMore' => System.Label.GNE_SFA2_SBC_Button_LoadMore,
                'searchingInfo' => System.Label.GNE_SFA2_SBC_PageLabel_SearchingInfo
        };
    }

    private Boolean isCreateAddressMode() {
        if (isCreateAddressMode == null) {
            isCreateAddressMode = false;
            DataWrapper inputData = (DataWrapper) this.inputDataWrapper;

            if (inputData != null) {
                isCreateAddressMode = inputData.isCreateAddressMode == true;
                accountId = inputData.accountId;
            } else {
                String currentPageUrl = ApexPages.currentPage() != null ? ApexPages.currentPage().getUrl() : '';
                isCreateAddressMode = currentPageUrl.startsWithIgnoreCase(Page.GNE_SFA2_Address_SBC.getUrl()) || String.isNotBlank(params.get('accountId'));

                if (isCreateAddressMode) {
                    String accIdFromRetUrl = null;
                    String addrIdFromRetUrl = null;
                    Boolean lookupFieldFound = false;
                    Boolean isSaveNew = false;

                    for (String param : params.keySet()) {
                        String paramValue = params.get(param);

                        if (param.endsWithIgnoreCase('_lkid')) {
                            accountId = (Id) checkInputParam(param);
                            lookupFieldFound = true;
                        } else if (param == 'accountId') {
                            accountId = (Id) checkInputParam(param);
                            lookupFieldFound = true;
                        } else if (param == 'retURL' && String.isNotBlank(paramValue) && paramValue.startsWith('/' + Address_vod__c.SObjectType.getDescribe().getKeyPrefix())) {
                            addrIdFromRetUrl = paramValue.contains('?') ? paramValue.substringBetween('/', '?') : paramValue.substringAfter('/');
                            addrIdFromRetUrl = addrIdFromRetUrl instanceof Id ? addrIdFromRetUrl : null;
                        } else if (param == 'retURL' && String.isNotBlank(paramValue) && paramValue.startsWith('/' + Account.SObjectType.getDescribe().getKeyPrefix())) {
                            accIdFromRetUrl = paramValue.contains('?') ? paramValue.substringBetween('/', '?') : paramValue.substringAfter('/');
                            accIdFromRetUrl = accIdFromRetUrl instanceof Id ? accIdFromRetUrl : null;
                        } else if (param == 'save_new') {
                            isSaveNew = paramValue == '1';
                        }

                        if (lookupFieldFound == true) {
                            break;
                        }
                    }

                    List<Account> accountData = new List<Account>();

                    if (String.isNotBlank(accountId)) {
                        accountData = GNE_SFA2_SBC_DAO.getAccountsByIds(new Set<Id>{
                                accountId
                        });
                    } else if (isSaveNew && String.isNotBlank(accIdFromRetUrl)) {
                        accountData = GNE_SFA2_SBC_DAO.getAccountsByIds(new Set<Id>{
                                (Id) accIdFromRetUrl
                        });
                    } else if (isSaveNew && String.isNotBlank(addrIdFromRetUrl)) {
                        accountData = GNE_SFA2_SBC_DAO.getAccountsByAddressIds(new Set<Id>{
                                addrIdFromRetUrl
                        });
                    }

                    for (Account acc : accountData) {
                        currentAccount = acc;
                        accountId = currentAccount.Id;
                        accLookupFieldId = 'CF00N70000001tDKx';
                        accLookupFieldDesc = currentAccount.Name;

                        isHcp = currentAccount.IsPersonAccount;
                        mdmId = currentAccount.MDMID_gne__c;
                        existingAddrMdmIds = new Set<String>();

                        for (Address_vod__c addr : currentAccount.Address_vod__r) {
                            existingAddrMdmIds.add(addr.MDM_Address_ID_gne__c);
                        }
                    }
                }
            }
        }

        return isCreateAddressMode;
    }

    private String getAddressCreateUrl() {
        PageReference addrLayout = isStandardUI == true ? (GNE_SFA2_Util.isCrmUser() ? Page.GNE_CRM_Address_Edit_Create : new PageReference('/' + Address_vod__c.SObjectType.getDescribe().getKeyPrefix() + '/e')) : Page.GNE_SFA2_Address_Edit_Create_Layout;

        for (String paramKey : params.keySet()) {
            if (!new Set<String>{
                    'debugMode', 'sObjectType', 'userAlias', 'save_new'
            } .contains(paramKey)) {
                addrLayout.getParameters().put(paramKey, params.get(paramKey));
            }
        }

        if (isStandardUI == true && !GNE_SFA2_Util.isCrmUser()) {
            addrLayout.getParameters().put('nooverride', '1');
            if (String.isNotBlank(accLookupFieldId)) {
                addrLayout.getParameters().put(accLookupFieldId, accLookupFieldDesc);
                addrLayout.getParameters().put(accLookupFieldId + '_lkid', accountId);
            }
        } else {
            addrLayout.getParameters().put('accountId', accountId);
        }

        String rtDevName = getCurrentUser().isCanada()
                ? (currentAccount != null && currentAccount.IsPersonAccount ? REC_TYPE_ADDR_CANADA_HCP_REP : REC_TYPE_ADDR_CANADA_HCO_REP)
                : REC_TYPE_ADDR_REP;
        Id recTypeId = GNE_SFA2_SBC_DAO.getRecordTypeId('Address_vod__c', rtDevName);
        addrLayout.getParameters().put('preSetRecordType', recTypeId);
        addrLayout.getParameters().put('RecordType', recTypeId);
        return addrLayout.getUrl();
    }

    protected virtual GNE_SFA2_UserPreference_Ctrl getHiddenAddressCtrl() {
        if (hiddenAddressCtrl == null) {
            hiddenAddressCtrl = new GNE_SFA2_UserPreference_Ctrl();
        }

        return hiddenAddressCtrl;
    }

    protected override SObject getRecord(List<SFA2_Configuration_Object_gne__c> configObjects) {
        DataWrapper resultData = (DataWrapper) DataWrapper;
        String nameAddressSearchMode = GNE_SFA2_SBC_Config.SearchModes.NameAddress.name();
        String hcpMode = GNE_SFA2_SBC_Config.AccountModes.HCP.name();
        String hcoMode = GNE_SFA2_SBC_Config.AccountModes.HCO.name();
        hcpSearchRec = new SFASearchStrings_gne__c(AccountType_gne__c = hcpMode, Mode_gne__c = nameAddressSearchMode);
        hcoSearchRec = new SFASearchStrings_gne__c(AccountType_gne__c = hcoMode, Mode_gne__c = nameAddressSearchMode);
        record = new SFASearchStrings_gne__c();

        if (!isCreateAddressMode()) {
            Id userId = currentUser.id;

            List<SFASearchStrings_gne__c> hcpResults = GNE_SFA2_SBC_DAO.getLastSearchHistoryRecord(hcpMode, userId);
            for (SFASearchStrings_gne__c hcpRec : hcpResults) {
                hcpSearchRec = hcpRec;
                resultData.hcpSearchRecId = hcpRec.Id;
            }

            if (isSfaBrandUser != true) {
                List<SFASearchStrings_gne__c> hcoResults = GNE_SFA2_SBC_DAO.getLastSearchHistoryRecord(hcoMode, userId);
                for (SFASearchStrings_gne__c hcoRec : hcoResults) {
                    hcoSearchRec = hcoRec;
                    resultData.hcoSearchRecId = hcoRec.Id;
                }
            }
        }

        setSbcMode();
        return currentSearchRec;
    }

    private void setSbcMode() {
        DataWrapper resultData = (DataWrapper) DataWrapper;
        if (isCreateAddressMode()) {
            String accMode = isHcp == null ? '' : isHcp == true ? GNE_SFA2_SBC_Config.AccountModes.HCP.name() : GNE_SFA2_SBC_Config.AccountModes.HCO.name();
            resultData.sbcMode = accMode.toLowerCase() + 'SearchAddress';
            currentSearchRec = new SFASearchStrings_gne__c();
        } else {
            if (params.containsKey('searchOnlyHCO') && Boolean.valueOf(params.get('searchOnlyHCO'))) {
                resultData.sbcMode = HCO_SEARCH_MODE;
            } else if (params.containsKey('searchOnlyHCP') && Boolean.valueOf(params.get('searchOnlyHCP'))) {
                resultData.sbcMode = HCP_SEARCH_MODE;
            } else if (params.containsKey('isPopup') && Boolean.valueOf(params.get('isPopup'))) {
                if (getFRMHCOMode()) {
                    resultData.sbcMode = HCP_SEARCH_MODE;
                } else {
                    resultData.sbcMode = (!isSfaBrandUser && String.isNotBlank(resultData.hcoSearchRecId) && (String.isBlank(resultData.hcpSearchRecId) || hcoSearchRec.LastModifiedDate > hcpSearchRec.LastModifiedDate)) ? HCO_SEARCH_MODE : getFRMHCOMode() ? HCO_SEARCH_MODE : HCP_SEARCH_MODE;
                }
            } else {
                resultData.sbcMode = (!isSfaBrandUser && String.isNotBlank(resultData.hcoSearchRecId) && (String.isBlank(resultData.hcpSearchRecId) || hcoSearchRec.LastModifiedDate > hcpSearchRec.LastModifiedDate)) ? HCO_SEARCH_MODE : getFRMHCOMode() ? HCO_SEARCH_MODE : HCP_SEARCH_MODE;
            }

            currentSearchRec = isHcpAccountMode(resultData.sbcMode) ? hcpSearchRec : hcoSearchRec;
            resultData.hcpSearchMode = hcpSearchRec.Mode_gne__c;
            resultData.hcoSearchMode = hcoSearchRec.Mode_gne__c;
        }
    }

    private String getAccountMode(String sbcMode) {
        return sbcMode != null && sbcMode.startsWithIgnoreCase('hcp') ? GNE_SFA2_SBC_Config.AccountModes.HCP.name().toLowerCase() : GNE_SFA2_SBC_Config.AccountModes.HCO.name().toLowerCase();
    }

    private Boolean isHcpAccountMode(String sbcMode) {
        return getAccountMode(sbcMode) == 'hcp';
    }

    protected override GNE_SFA2_Base_Ctrl.Config getConfiguration(String recordTypeDeveloperName) {
        DataWrapper resultData = (DataWrapper) DataWrapper;
        getRecord(null);
        List<GNE_SFA2_Base_Ctrl.Section> sections;

        if (isCreateAddressMode()) {
            sections = new List<GNE_SFA2_Base_Ctrl.Section>{
                    new GNE_SFA2_Base_Ctrl.Section('searchResults', System.Label.GNE_SFA2_SBC_Section_AddressResults, 0, '--hcpSearchAddress -- hcoSearchAddress', null)
            };
        } else {
            sObjectFieldsDescribe = getSObjectFieldsDescribe();
            Boolean isLwoUser = isLWOUser();
            Boolean isSolrHcoUser = GNE_SFA2_SolrUtil.useSolr('hco');
            String nameAddressSearchMode = GNE_SFA2_SBC_Config.SearchModes.NameAddress.name() + 'SearchMode';
            String licenseSearchMode = GNE_SFA2_SBC_Config.SearchModes.License.name() + 'SearchMode';
            String mdmIdSearchMode = GNE_SFA2_SBC_Config.SearchModes.MDMId.name() + 'SearchMode';
            fieldsMap = new Map<String, GNE_SFA2_Base_Ctrl.Field>{
                    sObjectType + '.accounttype_gne__c' => new GNE_SFA2_Base_Ctrl.Field('Account Type', currentSearchRec.AccountType_gne__c, false, false),
                    'Account.firstname' => new GNE_SFA2_Base_Ctrl.Field('First Name', null, false, true),
                    'Account.middle_vod__c' => new GNE_SFA2_Base_Ctrl.Field('Middle Name', null, false, false),
                    'Account.lastname' => new GNE_SFA2_Base_Ctrl.Field('Last Name', null, false, true),
                    'Account.name' => new GNE_SFA2_Base_Ctrl.Field('Organization Name', null, false, true),
                    'Account.ins_id_gne__c' => new GNE_SFA2_Base_Ctrl.Field('INS ID', null, false, false)
            };

            if (isLwoUser) {
                fieldsMap.putAll(new Map<String, GNE_SFA2_Base_Ctrl.Field>{
                        'Account.sap_id_gne__c' => new GNE_SFA2_Base_Ctrl.Field('SAP ID', null, false, false),
                        'Account.web_order_enabled_gne__c' => new GNE_SFA2_Base_Ctrl.Field('Enable Web Ordering', null, false, false)
                });
            } else {
                fieldsMap.putAll(new Map<String, GNE_SFA2_Base_Ctrl.Field>{
                        'Account.Customer_Type_gne__c' => new GNE_SFA2_Base_Ctrl.Field('Customer Type', null, false, true),
                        'Account.account_type_gne__c' => new GNE_SFA2_Base_Ctrl.Field('Account Type', null, false, true),
                        'Address_vod__c.name' => new GNE_SFA2_Base_Ctrl.Field('Street Address', null, false, true),
                        'Address_vod__c.address_line_2_vod__c' => new GNE_SFA2_Base_Ctrl.Field('Suite/Floor/Unit', null, false, false),
                        'Address_vod__c.city_vod__c' => new GNE_SFA2_Base_Ctrl.Field('City', null, false, true),
                        'Address_vod__c.state_vod__c' => new GNE_SFA2_Base_Ctrl.Field('State', null, false, true),
                        'Address_vod__c.zip_vod__c' => new GNE_SFA2_Base_Ctrl.Field('Zip Code', null, false, true),
                        'Account.professional_type_gne__c' => new GNE_SFA2_Base_Ctrl.Field('Professional Type', null, false, true),
                        'Account.credentials_vod__c' => new GNE_SFA2_Base_Ctrl.Field('Credentials', null, false, true),
                        'Account.specialties_gne__c' => new GNE_SFA2_Base_Ctrl.Field('Specialties', null, false, false),
                        'territory' => new GNE_SFA2_Base_Ctrl.Field('Territory', null, false, false)
                });
            }

            for (String fieldKey : fieldsMap.keySet()) {
                GNE_SFA2_Base_Ctrl.Field fld = fieldsMap.get(fieldKey);
                fld.describe = getFieldDesribe(fieldKey);
                fld.name = fld.describe.name;
                fld.helpText = fld.describe.inlineHelpText;
            }

            if (fieldsMap.get('territory') != null && fieldsMap.get('territory').describe.permissionable == false) {
                fieldsMap.put('territory', null);
            }

            GNE_SFA2_Base_Ctrl.Field blankSpace = new GNE_SFA2_Base_Ctrl.Field(null, null);
            blankSpace.changeToBlankSpace();

            sections = new List<GNE_SFA2_Base_Ctrl.Section>();

            if (isSfaBrandUser == true) {
                sections.addAll(new List<GNE_SFA2_Base_Ctrl.Section>{
                        new GNE_SFA2_Base_Ctrl.Section('selectSearchType', null, 0, '--hcpSearch --cols[1]', null),
                        new GNE_SFA2_Base_Ctrl.Section('nameAddressSearch', System.Label.GNE_SFA2_SBC_Section_NameAddress, 1, '--hcpSearch --' + nameAddressSearchMode, new List<GNE_SFA2_Base_Ctrl.Field>{
                                new GNE_SFA2_Base_Ctrl.Field('Person Name', hcpSearchRec.LastName_gne__c, false, false, sObjectFieldsDescribe.get('lastname_gne__c'), sObjectType),
                                new GNE_SFA2_Base_Ctrl.Field('Street Address', hcpSearchRec.Street_gne__c, false, false, sObjectFieldsDescribe.get('street_gne__c'), sObjectType),
                                new GNE_SFA2_Base_Ctrl.Field('City', hcpSearchRec.City_gne__c, false, false, sObjectFieldsDescribe.get('city_gne__c'), sObjectType),
                                new GNE_SFA2_Base_Ctrl.Field('State', hcpSearchRec.State_gne__c, false, true, sObjectFieldsDescribe.get('state_gne__c'), sObjectType),
                                new GNE_SFA2_Base_Ctrl.Field('Zip Code', hcpSearchRec.Zip_gne__c, false, false, sObjectFieldsDescribe.get('zip_gne__c'), sObjectType)
                        }),
                        new GNE_SFA2_Base_Ctrl.Section('licenseSearch', System.Label.GNE_SFA2_SBC_Section_License, 2, '--hcpSearch --' + licenseSearchMode, new List<GNE_SFA2_Base_Ctrl.Field>{
                                new GNE_SFA2_Base_Ctrl.Field('License Number', hcpSearchRec.License_Number_gne__c, false, true, sObjectFieldsDescribe.get('license_number_gne__c'), sObjectType),
                                new GNE_SFA2_Base_Ctrl.Field('Issue State', hcpSearchRec.State_gne__c, false, true, sObjectFieldsDescribe.get('license_state_gne__c'), sObjectType)
                        }),
                        new GNE_SFA2_Base_Ctrl.Section('mdmSearch', System.Label.GNE_SFA2_SBC_Section_MdmId, 3, '--hcpSearch --' + mdmIdSearchMode, new List<GNE_SFA2_Base_Ctrl.Field>{
                                new GNE_SFA2_Base_Ctrl.Field('MDM Id', hcpSearchRec.MDMID_gne__c, false, true, sObjectFieldsDescribe.get('mdmid_gne__c'), sObjectType)
                        }),
                        new GNE_SFA2_Base_Ctrl.Section('searchResults', System.Label.GNE_SFA2_SBC_Section_AccountResults, 4, '--hcpSearch', null),
                        new GNE_SFA2_Base_Ctrl.Section('create', null, 5, '--hcpCreate', new List<GNE_SFA2_Base_Ctrl.Field>{
                                fieldsMap.get('Account.Customer_Type_gne__c'),
                                fieldsMap.get('Account.firstname'),
                                fieldsMap.get('Account.middle_vod__c'),
                                fieldsMap.get('Account.lastname'),
                                fieldsMap.get('Address_vod__c.name'),
                                fieldsMap.get('Address_vod__c.address_line_2_vod__c'),
                                fieldsMap.get('Address_vod__c.city_vod__c'),
                                fieldsMap.get('Address_vod__c.state_vod__c'),
                                fieldsMap.get('Address_vod__c.zip_vod__c'),
                                fieldsMap.get('Account.professional_type_gne__c'),
                                fieldsMap.get('Account.credentials_vod__c'),
                                fieldsMap.get('Account.specialties_gne__c')
                        })
                });
            } else {
                if (!getFRMHCOMode()) {
                    sections.add(new GNE_SFA2_Base_Ctrl.Section('selectSearchType', null, 0, '--hcpSearch --hcoSearch --cols[1]', new List<GNE_SFA2_Base_Ctrl.Field>{
                            fieldsMap.get(sObjectType + '.accounttype_gne__c')
                    }));
                }
                GNE_SFA2_Base_Ctrl.Field idSolrSearchField = new GNE_SFA2_Base_Ctrl.Field('MDM / INS ID', hcoSearchRec.MDMID_gne__c, false, true, sObjectFieldsDescribe.get('mdmid_gne__c'), sObjectType);
                idSolrSearchField.helpText = idSolrSearchField.helpText.replace('MDM Id', 'ID');

                sections.addAll(new List<GNE_SFA2_Base_Ctrl.Section>{
                        new GNE_SFA2_Base_Ctrl.Section('nameAddressSearch', System.Label.GNE_SFA2_SBC_Section_NameAddress, 1, '--hcpSearch --' + nameAddressSearchMode, new List<GNE_SFA2_Base_Ctrl.Field>{
                                new GNE_SFA2_Base_Ctrl.Field('Person Name', hcpSearchRec.LastName_gne__c, false, false, sObjectFieldsDescribe.get('lastname_gne__c'), sObjectType),
                                blankSpace,
                                new GNE_SFA2_Base_Ctrl.Field('Street Address', hcpSearchRec.Street_gne__c, false, false, sObjectFieldsDescribe.get('street_gne__c'), sObjectType),
                                new GNE_SFA2_Base_Ctrl.Field('City', hcpSearchRec.City_gne__c, false, false, sObjectFieldsDescribe.get('city_gne__c'), sObjectType),
                                new GNE_SFA2_Base_Ctrl.Field('State', hcpSearchRec.State_gne__c, false, true, sObjectFieldsDescribe.get('state_gne__c'), sObjectType),
                                new GNE_SFA2_Base_Ctrl.Field('Zip Code', hcpSearchRec.Zip_gne__c, false, false, sObjectFieldsDescribe.get('zip_gne__c'), sObjectType)
                        }),
                        new GNE_SFA2_Base_Ctrl.Section('nameAddressSearch', System.Label.GNE_SFA2_SBC_Section_NameAddress, 1, '--hcoSearch --' + nameAddressSearchMode, new List<GNE_SFA2_Base_Ctrl.Field>{
                                new GNE_SFA2_Base_Ctrl.Field('Organization Name', hcoSearchRec.OrgName_gne__c, false, false, sObjectFieldsDescribe.get('orgname_gne__c'), sObjectType),
                                getFRMHCOMode() ? new GNE_SFA2_Base_Ctrl.Field('Account Type', hcoSearchRec.FRM_Account_Type_gne__c, false, false, sObjectFieldsDescribe.get('frm_account_type_gne__c'), sObjectType) : blankSpace,
                                new GNE_SFA2_Base_Ctrl.Field('Street Address', hcoSearchRec.Street_gne__c, false, false, sObjectFieldsDescribe.get('street_gne__c'), sObjectType),
                                new GNE_SFA2_Base_Ctrl.Field('City', hcoSearchRec.City_gne__c, false, false, sObjectFieldsDescribe.get('city_gne__c'), sObjectType),
                                new GNE_SFA2_Base_Ctrl.Field('State', hcoSearchRec.State_gne__c, false, true, sObjectFieldsDescribe.get('state_gne__c'), sObjectType),
                                new GNE_SFA2_Base_Ctrl.Field('Zip Code', hcoSearchRec.Zip_gne__c, false, false, sObjectFieldsDescribe.get('zip_gne__c'), sObjectType)
                        }),
                        new GNE_SFA2_Base_Ctrl.Section('licenseSearch', System.Label.GNE_SFA2_SBC_Section_License, 2, '--hcpSearch --' + licenseSearchMode, new List<GNE_SFA2_Base_Ctrl.Field>{
                                new GNE_SFA2_Base_Ctrl.Field('License Number', hcpSearchRec.License_Number_gne__c, false, true, sObjectFieldsDescribe.get('license_number_gne__c'), sObjectType),
                                new GNE_SFA2_Base_Ctrl.Field('Issue State', hcpSearchRec.State_gne__c, false, true, sObjectFieldsDescribe.get('license_state_gne__c'), sObjectType)
                        }),
                        new GNE_SFA2_Base_Ctrl.Section('mdmSearch', System.Label.GNE_SFA2_SBC_Section_MdmId, 3, '--hcpSearch --' + mdmIdSearchMode, new List<GNE_SFA2_Base_Ctrl.Field>{
                                new GNE_SFA2_Base_Ctrl.Field('MDM Id', hcpSearchRec.MDMID_gne__c, false, true, sObjectFieldsDescribe.get('mdmid_gne__c'), sObjectType)
                        }),
                        new GNE_SFA2_Base_Ctrl.Section('mdmSearch', isSolrHcoUser ? 'ID Search' : System.Label.GNE_SFA2_SBC_Section_MdmId, 3, '--hcoSearch --' + mdmIdSearchMode, new List<GNE_SFA2_Base_Ctrl.Field>{
                                isSolrHcoUser ? idSolrSearchField :
                                        new GNE_SFA2_Base_Ctrl.Field('MDM Id', hcoSearchRec.MDMID_gne__c, false, true, sObjectFieldsDescribe.get('mdmid_gne__c'), sObjectType)

                        }),
                        new GNE_SFA2_Base_Ctrl.Section('searchResults', System.Label.GNE_SFA2_SBC_Section_AccountResults, 4, '--hcpSearch --hcoSearch', null),
                        new GNE_SFA2_Base_Ctrl.Section('create', System.Label.GNE_SFA2_SBC_Section_CreateHCP, 5, '--hcpCreate', new List<GNE_SFA2_Base_Ctrl.Field>{
                                fieldsMap.get('Account.firstname'),
                                fieldsMap.get('Account.middle_vod__c'),
                                fieldsMap.get('Account.lastname'),
                                fieldsMap.get('Address_vod__c.name'),
                                fieldsMap.get('Address_vod__c.address_line_2_vod__c'),
                                fieldsMap.get('Address_vod__c.city_vod__c'),
                                fieldsMap.get('Address_vod__c.state_vod__c'),
                                fieldsMap.get('Address_vod__c.zip_vod__c'),
                                fieldsMap.get('Account.professional_type_gne__c'),
                                fieldsMap.get('Account.credentials_vod__c'),
                                !getFRMHCOMode() ? fieldsMap.get('territory') : null,
                                fieldsMap.get('Account.sap_id_gne__c'),
                                fieldsMap.get('Account.web_order_enabled_gne__c')
                        }),
                        new GNE_SFA2_Base_Ctrl.Section('create', System.Label.GNE_SFA2_SBC_Section_CreateHCO, 5, '--hcoCreate', new List<GNE_SFA2_Base_Ctrl.Field>{
                                fieldsMap.get('Account.name'),
                                fieldsMap.get('Account.account_type_gne__c'),
                                fieldsMap.get('Address_vod__c.name'),
                                fieldsMap.get('Address_vod__c.address_line_2_vod__c'),
                                fieldsMap.get('Address_vod__c.city_vod__c'),
                                fieldsMap.get('Address_vod__c.state_vod__c'),
                                fieldsMap.get('Address_vod__c.zip_vod__c'),
                                fieldsMap.get('territory'),
                                fieldsMap.get('Account.sap_id_gne__c'),
                                fieldsMap.get('Account.web_order_enabled_gne__c')
                        })
                });
            }

            if (isStandardUI == false) {
                String columsArg = 'cols[1]';

                for (Section sec : sections) {
                    if (sec.attributeFlags != null && !sec.attributeFlags.contains(columsArg)) {
                        sec.attributeFlags.add(columsArg);
                        sec.attributes += ' --' + columsArg;
                    }
                }
            }

            for (GNE_SFA2_Base_Ctrl.Section sec : sections) {
                if (sec.fields != null) {
                    for (Integer i = (sec.fields != null ? sec.fields.size() : 0) - 1; i >= 0; i--) {
                        if (sec.fields[i] == null) {
                            sec.fields.remove(i);
                        } else if (isSfaBrandUser == true) {
                            sec.fields[i].placeholder = 'Enter ' + sec.fields[i].label;
                        }
                    }
                }
            }

            resultData.accountTypesMap = getAccountTypesMap();
        }

        return new GNE_SFA2_Base_Ctrl.Config(GNE_SFA2_Base_Ctrl.EDIT_MODE, new List<GNE_SFA2_Base_Ctrl.Button>(), sections, null);
    }

    private Map<String, Schema.DescribeFieldResult> getAccountFieldsDescribe() {
        cacheAccountFieldsDescribe();
        return accountFieldsDescribe;
    }

    public Map<String, Map<String, AccountTypeWrapper>> getAccountTypesMap() {
        DataWrapper inputData = (DataWrapper) this.inputDataWrapper;

        if (inputData != null && inputData.accountTypesMap != null) {
            accountTypesMap = inputData.accountTypesMap;
        } else {
            cacheAccountFieldsDescribe();
        }

        return accountTypesMap;
    }

    private void cacheAccountFieldsDescribe() {
        if (accountFieldsDescribe == null) {
            Schema.DescribeSObjectResult sObjectDescribe = Account.SObjectType.getDescribe();
            Map<String, Schema.SObjectField> objectFields = sObjectDescribe.fields.getMap();
            accountFieldsDescribe = new Map<String, Schema.DescribeFieldResult>();
            accountTypesMap = new Map<String, Map<String, AccountTypeWrapper>>{
                    'hcp' => new Map<String, AccountTypeWrapper>(),
                    'hco' => new Map<String, AccountTypeWrapper>()
            };
            Map<Id, Schema.RecordTypeInfo> rtMapById = sObjectDescribe.getRecordTypeInfosById();
            Map<Id, RecordType> rtMap = new Map<Id, RecordType>(GNE_SFA2_SBC_DAO.getRecordTypesById(rtMapById.keySet()));
            Boolean isLwoUser = isLWOUser();

            for (Id rtId : rtMapById.keySet()) {
                Schema.RecordTypeInfo rtById = rtMapById.get(rtId);

                if (rtMap.containsKey(rtId)) {
                    RecordType rt = rtMap.get(rtId);
                    if (isLwoUser && rt.Name == REC_TYPE_LWO_HCP) {
                        accountTypesMap.get('hcp').put('lwo', new AccountTypeWrapper(rt.Id));
                    } else if (isLwoUser && rt.Name == REC_TYPE_LWO_HCO) {
                        accountTypesMap.get('hco').put('lwo', new AccountTypeWrapper(rt.Id));
                    } else if (rt.IsPersonType && rt.Name == REC_TYPE_HCP) {
                        accountTypesMap.get('hcp').put('default', new AccountTypeWrapper(rt.Id));
                    }
                }
            }

            for (GNE_SFA2_Account_Trigger_Helper.AccountTypeWrapper atWrapper : GNE_SFA2_Account_Trigger_Helper.getAccountTypesMap(getCurrentUserProfileName()).values()) {
                if (atWrapper.getRecordTypeId() != null) {
                    accountTypesMap.get('hco').put(atWrapper.getKey(), new AccountTypeWrapper(atWrapper.getAccountType(), atWrapper.getRecordTypeId(), atWrapper.getSSN()));
                }
            }

            if (accountTypesMap.get('hco').containsKey('PHYSICIAN PRACTICE')) {
                accountTypesMap.get('hco').put('default', accountTypesMap.get('hco').get('PHYSICIAN PRACTICE'));
            }

            for (String fName : objectFields.keySet()) {
                Schema.DescribeFieldResult fieldDescribe = objectFields.get(fName).getDescribe();
                accountFieldsDescribe.put(fieldDescribe.getName().toLowerCase(), fieldDescribe);
            }
        }
    }

    private Map<String, Schema.DescribeFieldResult> getAddressFieldsDescribe() {
        cacheAddressFieldsDescribe();
        return addressFieldsDescribe;
    }

    private void cacheAddressFieldsDescribe() {
        if (addressFieldsDescribe == null) {
            Schema.DescribeSObjectResult sObjectDescribe = Address_vod__c.SObjectType.getDescribe();
            Map<String, Schema.SObjectField> objectFields = sObjectDescribe.fields.getMap();
            addressFieldsDescribe = new Map<String, Schema.DescribeFieldResult>();

            for (String fName : objectFields.keySet()) {
                Schema.DescribeFieldResult fieldDescribe = objectFields.get(fName).getDescribe();
                addressFieldsDescribe.put(fieldDescribe.getName().toLowerCase(), fieldDescribe);
            }
        }
    }

    private GNE_SFA2_Base_Ctrl.FieldDescribe getFieldDesribe(String fieldKey) {
        DataWrapper resultData = (DataWrapper) DataWrapper;
        String[] fieldKeyData = fieldKey.split('\\.');
        String fieldName = fieldKeyData.remove(fieldKeyData.size() - 1);
        String sObjectType = !fieldKeyData.isEmpty() ? fieldKeyData[0] : null;
        Map<String, Schema.DescribeFieldResult> schemafieldsDescribe = sObjectType == 'Account' ? getAccountFieldsDescribe() : sObjectType == 'Address_vod__c' ? getAddressFieldsDescribe() : String.isNotBlank(sObjectType) ? getSObjectFieldsDescribe() : null;
        Schema.DescribeFieldResult schemaFieldDescribe = schemafieldsDescribe != null ? schemafieldsDescribe.get(fieldName) : null;
        GNE_SFA2_Base_Ctrl.FieldDescribe describe;

        if (schemaFieldDescribe != null) {
            describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(schemaFieldDescribe, sObjectType);
        } else {
            describe = new GNE_SFA2_Base_Ctrl.FieldDescribe();
            describe.name = fieldName;
        }

        if (helpTexts.containsKey(fieldKey)) {
            describe.inlineHelpText = helpTexts.get(fieldKey);
        }

        if (fieldName == 'AccountType_gne__c') {
            describe.type = 'picklist';
            describe.picklistValues = new List<GNE_SFA2_Base_Ctrl.PicklistValue>{
                    new GNE_SFA2_Base_Ctrl.PicklistValue('HCO', System.Label.GNE_SFA2_SBC_PicklistValue_HCO),
                    new GNE_SFA2_Base_Ctrl.PicklistValue('HCP', System.Label.GNE_SFA2_SBC_PicklistValue_HCP)
            };
        } else if (fieldName == 'territory') {
            describe.type = 'picklist';
            describe.picklistValues = new List<GNE_SFA2_Base_Ctrl.PicklistValue>();
            List<Territory2> userTerrs = getTerritories();

            if (!getFRMHCOMode() || (getFRMHCOMode() && userTerrs.size() > 1)) {
                for (Territory2 uTerr : userTerrs) {
                    describe.picklistValues.add(new GNE_SFA2_Base_Ctrl.PicklistValue(uTerr.Id, uTerr.Name));
                }
            }

            if (describe.picklistValues.isEmpty()) {
                describe.permissionable = false;
            } else if (!getFRMHCOMode()) {
                describe.picklistValues.add(new GNE_SFA2_Base_Ctrl.PicklistValue(null, NO_TERRITORY_SELECTED));
            }
        } else if (fieldName == 'Professional_Type_gne__c') {
            describe.picklistValues = new List<GNE_SFA2_Base_Ctrl.PicklistValue>();

            for (String profType : GNE_SFA2_SBC_Config.getHcpProfTypes()) {
                describe.picklistValues.add(new GNE_SFA2_Base_Ctrl.PicklistValue(profType));
            }
        } else if (fieldName == 'Customer_Type_gne__c') {
            describe.type = 'picklist';
            describe.sObjectType = 'Account';
            describe.showNone = false;
            describe.picklistValues = new List<GNE_SFA2_Base_Ctrl.PicklistValue>{
                    new GNE_SFA2_Base_Ctrl.PicklistValue('HCP', 'HCP'),
                    new GNE_SFA2_Base_Ctrl.PicklistValue('Contact', 'Contact')
            };
        } else if (fieldName == 'Account_Type_gne__c') {
            describe.picklistValues = new List<GNE_SFA2_Base_Ctrl.PicklistValue>();
            Set<String> accTypesSet = new Set<String>();

            for (String key : getAccountTypesMap().get('hco').keySet()) {
                AccountTypeWrapper atWrapper = getAccountTypesMap().get('hco').get(key);
                if (key != 'default') {
                    accTypesSet.add(atWrapper.accountType);
                }
            }

            List<String> accTypesList = new List<String>(accTypesSet);
            accTypesList.sort();

            for (String accType : accTypesList) {
                describe.picklistValues.add(new GNE_SFA2_Base_Ctrl.PicklistValue(accType));
            }
        } else if (fieldName == 'Specialties_gne__c') {
            describe.type = 'picklist';
        } else if (fieldName == 'FRM_Account_Type_gne__c') {
            describe.showNone = true;
        }

        return describe;
    }

    protected List<Territory2> getTerritories() {
        DataWrapper resultData = (DataWrapper) DataWrapper;
        resultData.territoriesMap = new Map<Id, TerritoryWrapper>();
        resultData.teamCodes = new Set<String>();

        List<Territory2> result = new List<Territory2>();
        Id userId = getCurrentUser().id;

        Territory2 currentTerr = getCurrentTerritory();
        Map<Id, Territory2> userTerrs = new Map<Id, Territory2>(userTerritoriesCache);

        for (Territory2 cTerr : userTerritoriesCache) {
            userTerrs.remove(cTerr.ParentTerritory2Id);
        }

        Boolean teamCodesInitialized = false;

        if (dataWrapper.isSfaBrandUser == true && currentTerr != null) {
            userTerrs.put(currentTerr.Id, currentTerr);
            teamCodesInitialized = true;

            if (String.isNotBlank(currentTerr.Salesforce_Code_gne__c)) {
                resultData.teamCodes.add(currentTerr.Salesforce_Code_gne__c);
            }

        }

        Map<Id, Id> terrIdToGroupIdMap = new Map<Id, Id>();
        List<Group> groups = userTerrs.isEmpty() ? new List<Group>() : GNE_SFA2_SBC_DAO.getTerritoryGroups(userTerrs.keySet());

        for (Group grp : groups) {
            terrIdToGroupIdMap.put(grp.RelatedId, grp.Id);
        }

        for (Territory2 uTerr : userTerritoriesCache) {
            if (userTerrs.containsKey(uTerr.Id)) {
                result.add(uTerr);
                resultData.territoriesMap.put(uTerr.Id, new TerritoryWrapper(uTerr, terrIdToGroupIdMap.get(uTerr.Id)));

                if (!teamCodesInitialized && String.isNotBlank(uTerr.Salesforce_Code_gne__c)) {
                    resultData.teamCodes.add(uTerr.Salesforce_Code_gne__c);
                }
            }
        }

        return result;
    }

    global DataWrapper searchAccounts(String searchDataWrapperInJSON, Boolean searchMore) {
        DataWrapper = getDataWrapperInstance();

        try {
            this.inputDataWrapper = (DataWrapper) JSON.deserialize(searchDataWrapperInJSON, GNE_SFA2_SBC_Ctrl.DataWrapper.class);
            DataWrapper = intSearchAccounts(true, searchMore);
        } catch (GNE_SFA2_SBC_DAO.ServiceException mex) {
            handleMdmException(mex);
        } catch (Exception ex) {
            handleException(ex);
        }

        dataWrapper.onActionFinish(searchMore ? 'Search More Accounts' : 'Search Accounts');
        GNE_SFA2_DBCacheManager.initDmlCache();
        return (DataWrapper) DataWrapper;
    }

    protected virtual void handleMdmException(GNE_SFA2_SBC_DAO.ServiceException mex) {
        String knowErrorMessage = GNE_SFA2_SBC_Config.getMdmKnowErrorMessage(mex.statusCode);
        if (knowErrorMessage != null) {
            handleException(createException(new MdmServiceKnownErrorException(
                    GNE_SFA2_SBC_Config.getMdmKnowErrorName(mex.statusCode),
                    String.isNotBlank(knowErrorMessage) ? knowErrorMessage : mex.status
            )));
        } else {
            handleException(mex);
        }
    }

    private DataWrapper intSearchAccounts(Boolean dmlMode, Boolean searchMore) {
        DataWrapper inputData = (DataWrapper) this.inputDataWrapper;
        DataWrapper resultData = (DataWrapper) DataWrapper;
        String sbcMode = inputData.sbcMode;
        String accMode = getAccountMode(sbcMode);
        SearchData searchData = inputData.searchData.get(accMode);
        searchData.accountColumns = getSearchAccountColumns(accMode);
        searchData.addressColumns = getSearchAddressColumns(accMode);
        searchData.accountAdditionalColumns = getSearchAccountAdditionalColumns(accMode);
        searchData.searchValues = searchData.searchValues != null ? searchData.searchValues : getSearchValues(searchData.searchFields);
        Set<String> teamCodes = inputData.teamCodes;
        Boolean useSolrEngine = GNE_SFA2_SolrUtil.useSolr(accMode);
        Boolean useReltioEngine = GNE_SFA2_ReltioUtil.useReltio(accMode);
        if (resultData.success) {
            if (inputData.isSfaBrandUser == true && inputData.isCreateAddressMode != true) {
                resultData.isSfaBrandUser = inputData.isSfaBrandUser;
                getTerritories();
                teamCodes = resultData.teamCodes;
            }
            GNE_SFA2_SBC_Profiler.logStart(getSbcProfilerQuery(accMode, searchData.searchMode, searchData.searchValues, searchData.paginationData, teamCodes), Page.GNE_SFA2_SBC.getUrl());
            try {
                GNE_SFA2_SBC_DAO.DataWrapper dataWrapper;
                GNE_SFA2_SBC_DAO.PaginationDataWrapper paginationDataWrapper = searchMore ? searchData.paginationData : null;
                if (useReltioEngine) {
                    dataWrapper = new GNE_SFA2_SBC_RELTIO_DAO().searchAccounts(accMode, searchData.searchMode, searchData.searchValues, paginationDataWrapper, null);
                } else if (useSolrEngine) {
                    dataWrapper = new GNE_SFA2_SBC_Solr_DAO().searchAccounts(accMode, searchData.searchMode, searchData.searchValues, paginationDataWrapper, teamCodes);
                } else {
                    dataWrapper = new GNE_SFA2_SBC_MDM_DAO().searchAccounts(accMode, searchData.searchMode, searchMore ? null : searchData.searchValues, paginationDataWrapper, teamCodes);
                }
                GNE_SFA2_SBC_Profiler.logActionStart('SBC.PrepareResults');

                try {
                    List<GNE_SFA2_SBC_DAO.AccountWrapper> searchResults = dataWrapper.rows;
                    searchData.results = new List<SearchAccountWrapper>();
                    searchData.paginationData = dataWrapper.paginationData;

                    for (GNE_SFA2_SBC_DAO.AccountWrapper accWrapper : searchResults) {
                        if (getFRMHCOMode() && accMode == 'hco') {
                            Set<String> frmHCOAccTypes = new Set<String>();
                            for (CORE_Pub_Org_Typ_Map__c potm : CORE_Pub_Org_Typ_Map__c.getall().values()) {
                                if (potm.Account_Record_Type_gne__c == 'FRM_HCO') {
                                    frmHCOAccTypes.add(potm.Account_Type_gne__c.toUpperCase());
                                }
                            }

                            for (GNE_SFA2_SBC_DAO.AccountTypeWrapper accType : accWrapper.accountTypes) {
                                if (frmHCOAccTypes.contains(accType.name.toUpperCase())) {
                                    searchData.results.addAll(convertToSbcResult(accMode, accWrapper));
                                    break;
                                }
                            }

                        } else {
                            searchData.results.addAll(convertToSbcResult(accMode, accWrapper));
                        }
                    }

                    if (dmlMode == true && searchMore != true) {
                        saveSearchParams();
                    }
                    resultData.searchData = inputData.searchData;
                } finally {
                    GNE_SFA2_SBC_Profiler.logActionEnd('SBC.PrepareResults');
                }
            } finally {
                if (dmlMode == true) {
                    GNE_SFA2_SBC_Profiler.logEnd(searchData.results != null ? searchData.results.size() : null);
                }
            }
        }

        return resultData;
    }

    protected String getSbcProfilerQuery(String accMode, String searchMode, Map<String, String> searchValues, GNE_SFA2_SBC_DAO.PaginationDataWrapper paginationData, Set<String> teamCodes) {
        List<String> queryParams = new List<String>{
                'Mode: ' + searchMode,
                'Type: ' + accMode.toUpperCase(),
                'Team Codes: [' + String.join(teamCodes != null ? new List<String>(teamCodes) : new List<String>(), ',') + ']'
        };

        List<String> searchParams = new List<String>();
        for (String searchParam : searchValues.keySet()) {
            String val = searchValues.get(searchParam);
            searchParams.add(searchParam + ':' + (val != null ? '"' + val + '"' : 'null'));
        }

        queryParams.add('Params: {' + String.join(searchParams, ',') + '}');

        if (paginationData != null) {
            queryParams.add('Query More Params: {tokenID:"' + paginationData.tokenId + '", startIdx:' + paginationData.endPageIdx + '}');
        }

        return String.join(queryParams, ', ');

    }

    private void saveSearchParams() {
        DataWrapper inputData = (DataWrapper) this.inputDataWrapper;
        DataWrapper resultData = (DataWrapper) DataWrapper;

        List<SFASearchStrings_gne__c> searchRecs = new List<SFASearchStrings_gne__c>();
        for (String accType : inputData.searchData.keySet()) {
            SearchData searchData = inputData.searchData.get(accType);
            Id existingId = accType == 'hcp' ? inputData.hcpSearchRecId : inputData.hcoSearchRecId;
            SFASearchStrings_gne__c searchRec = new SFASearchStrings_gne__c(
                    Id = existingId,
                    AccountType_gne__c = accType.toUpperCase(),
                    Mode_gne__c = searchData.searchMode,
                    OwnerId = getCurrentUser().id);

            for (GNE_SFA2_Base_Ctrl.Field fld : searchData.searchFields) {
                searchRec.put(fld.describe.name, fld.getValue());
            }

            searchRecs.add(searchRec);
        }

        executeDml(GNE_SFA2_Base_Ctrl.DmlOperations.UPS, searchRecs, false);

        for (SFASearchStrings_gne__c searchRec : searchRecs) {
            if (searchRec.AccountType_gne__c == 'hcp') {
                resultData.hcpSearchRecId = searchRec.Id;
            } else {
                resultData.hcoSearchRecId = searchRec.Id;
            }
        }
    }

    private Map<String, String> getSearchValues(List<GNE_SFA2_Base_Ctrl.Field> searchFields) {
        Map<String, String> result = new Map<String, String>();

        for (GNE_SFA2_Base_Ctrl.Field fld : searchFields) {
            if (fld.name == 'Zip_gne__c' && !isZipValid(fld.value, true)) {
                handleException(createException(new SbcInvalidZipCodeException(String.valueOf(SFASearchStrings_gne__c.Zip_gne__c), 'SFASearchStrings_gne__c', true)));
            } else if (fld.name == 'License_Number_gne__c' && (fld.value == null || fld.value.length() < 3)) {
                handleException(createException(new SbcLincenseTooShortException(String.valueOf(SFASearchStrings_gne__c.License_Number_gne__c), 'SFASearchStrings_gne__c')));
            }

            String fldName = searchFieldNamesMap.containsKey(fld.name) ? searchFieldNamesMap.get(fld.name) : fld.name;
            Object fldValue = fld.getValue();
            result.put(fldName, fldValue != null ? String.valueOf(fldValue) : null);
        }

        return result;
    }

    private List<GNE_SFA2_Base_Ctrl.Field> getSearchAccountColumns(String accType) {
        List<GNE_SFA2_Base_Ctrl.Field> result = new List<GNE_SFA2_Base_Ctrl.Field>();
        DataWrapper inputData = (DataWrapper) this.inputDataWrapper;

        if (inputData.isCreateAddressMode != true) {
            if (inputData.isSfaBrandUser == true) {
                result.addAll(new List<GNE_SFA2_Base_Ctrl.Field>{
                        new GNE_SFA2_Base_Ctrl.Field('fullName', 'NAME'),
                        new GNE_SFA2_Base_Ctrl.Field('type', 'TYPE'),
                        new GNE_SFA2_Base_Ctrl.Field('mdmId', 'MDM ID'),
                        new GNE_SFA2_Base_Ctrl.Field('licenses', 'LICENSE NUMBER')
                });
            } else {
                if (accType == 'hcp') {
                    result.addAll(new List<GNE_SFA2_Base_Ctrl.Field>{
                            new GNE_SFA2_Base_Ctrl.Field('lastName', 'Last Name'),
                            new GNE_SFA2_Base_Ctrl.Field('firstName', 'First/Middle Name')
                    });
                } else {
                    result.add(new GNE_SFA2_Base_Ctrl.Field('name', 'Name'));
                }

                if (!getFRMHCOMode() || (getFRMHCOMode() && accType == 'hcp')) {
                    result.add(new GNE_SFA2_Base_Ctrl.Field('altNames', 'Other Names'));
                }

                result.add(new GNE_SFA2_Base_Ctrl.Field('mdmId', 'MDM ID'));
                if (GNE_SFA2_SolrUtil.useSolr(accType)) {
                    result.add(new GNE_SFA2_Base_Ctrl.Field('insId', 'INS ID'));
                }
                if (getFRMHCOMode() && accType == 'hco') {
                    result.add(new GNE_SFA2_Base_Ctrl.Field('status', 'Status'));
                }
                result.add(new GNE_SFA2_Base_Ctrl.Field('type', 'Type'));

                if (accType == 'hcp') {
                    result.add(new GNE_SFA2_Base_Ctrl.Field('licenses', 'License Number(s)'));
                }
            }
        }

        return result;
    }

    private List<GNE_SFA2_Base_Ctrl.Field> getSearchAddressColumns(String accType) {
        List<GNE_SFA2_Base_Ctrl.Field> result = new List<GNE_SFA2_Base_Ctrl.Field>();
        DataWrapper inputData = (DataWrapper) this.inputDataWrapper;

        if (inputData.isSfaBrandUser == true) {
            if (inputData.isCreateAddressMode != true) {
                result.addAll(new List<GNE_SFA2_Base_Ctrl.Field>{
                        new GNE_SFA2_Base_Ctrl.Field('address', 'ADDRESS')
                });
            } else {
                result.addAll(new List<GNE_SFA2_Base_Ctrl.Field>{
                        new GNE_SFA2_Base_Ctrl.Field('street', 'ADDRESS'),
                        new GNE_SFA2_Base_Ctrl.Field('city', 'CITY'),
                        new GNE_SFA2_Base_Ctrl.Field('state', 'STATE'),
                        new GNE_SFA2_Base_Ctrl.Field('zip', 'ZIP CODE'),
                        new GNE_SFA2_Base_Ctrl.Field('status', 'STATUS')
                });
            }
        } else {
            result.addAll(new List<GNE_SFA2_Base_Ctrl.Field>{
                    new GNE_SFA2_Base_Ctrl.Field('street', 'Address'),
                    new GNE_SFA2_Base_Ctrl.Field('city', 'City'),
                    new GNE_SFA2_Base_Ctrl.Field('state', 'State'),
                    new GNE_SFA2_Base_Ctrl.Field('zip', 'Zip Code')
            });
        }

        return result;
    }

    private List<GNE_SFA2_Base_Ctrl.Field> getSearchAccountAdditionalColumns(String accType) {
        List<GNE_SFA2_Base_Ctrl.Field> result = new List<GNE_SFA2_Base_Ctrl.Field>();
        DataWrapper inputData = (DataWrapper) this.inputDataWrapper;

        if (inputData.isCreateAddressMode != true && inputData.isSfaBrandUser == true) {
            result.add(new GNE_SFA2_Base_Ctrl.Field('status', 'STATUS'));
        }

        return result;
    }

    protected virtual List<SearchAccountWrapper> convertToSbcResult(String accType, GNE_SFA2_SBC_DAO.AccountWrapper accWrapper) {
        SearchAccountWrapper accountRow = new SearchAccountWrapper(accWrapper);
        List<SearchAccountWrapper> result = new List<SearchAccountWrapper>{
                accountRow
        };

        for (GNE_SFA2_SBC_DAO.AddressWrapper addr : accWrapper.addresses) {
            SearchAddressWrapper addressRow = new SearchAddressWrapper(addr, accountRow);
        }

        return result;
    }

    global virtual DataWrapper insertAccount(String inputDataWrapperInJSON) {
        DataWrapper = getDataWrapperInstance();
        System.Savepoint sp = Database.setSavepoint();
        Boolean isOk = false;

        try {
            this.inputDataWrapper = (DataWrapper) JSON.deserialize(inputDataWrapperInJSON, GNE_SFA2_SBC_Ctrl.DataWrapper.class);
            DataWrapper = intInsertAccount();
            isOk = true;
        } catch (Exception ex) {
            handleException(ex);
        } finally {
            if (!isOk) {
                Database.rollback(sp);
            }
        }

        dataWrapper.onActionFinish('Create Account');
        return (DataWrapper) DataWrapper;
    }

    protected virtual DataWrapper intInsertAccount() {
        DataWrapper inputData = (DataWrapper) this.inputDataWrapper;
        DataWrapper resultData = (DataWrapper) DataWrapper;
        String sbcMode = inputData.sbcMode;
        Account newAccount = new Account();
        Id addrRecTypeId = GNE_SFA2_SBC_DAO.getRecordTypeId('Address_vod__c', REC_TYPE_ADDR_REP);
        Address_vod__c newAddress = new Address_vod__c(Primary_vod__c = true, Active_Flag_gne__c = true, MDM_Status_gne__c = 'Active', RecordTypeId = addrRecTypeId);

        if (inputData.isCreateAddressMode == true) {
            newAddress.Primary_vod__c = false;
        }

        String accMode = getAccountMode(sbcMode);
        Id terrId = populateFromInputFields(newAccount, newAddress);

        if (inputData.isCreateAddressMode != true) {
            setAccountType(accMode, newAccount, true);
            setCredentials(accMode, newAccount);
            newAccount.OwnerId = getDefaultAccountOwnerId(newAccount);
            newAccount.MDMID_Status_gne__c = 'Active';
        }

        validateBeforeInsert(newAccount, newAddress);

        if (String.isNotBlank(newAccount.Customer_Type_gne__c) && newAccount.Customer_Type_gne__c == 'Contact') {
            newAccount.Credentials_vod__c = 'NONC';
            newAccount.Credentials_gne__pc = 'NONC';
        }

        if (resultData.success == true) {
            if (inputData.isCreateAddressMode != true) {
                executeDml(GNE_SFA2_Base_Ctrl.DmlOperations.INS, newAccount, false);
            }

            this.upsertedAccount = newAccount;

            if (!isLWOUser() || inputData.isCreateAddressMode == true) {
                newAddress.Account_vod__c = newAccount.Id;
                executeDml(GNE_SFA2_Base_Ctrl.DmlOperations.INS, newAddress, false);
                this.upsertedAddresses = new List<Address_vod__c>{
                        newAddress
                };
            }

            Boolean allignToTerritory = !(inputData.isCreateAddressMode == true || (getFRMHCOMode() && sbcMode == HCP_SEARCH_MODE));
            if (allignToTerritory) {
                Id iTerrId = terrId != null ? terrId : ((inputData.isSfaBrandUser == true || getFRMHCOMode()) ? getCurrentTerritoryId() : null);
                upsertTerritoryRecords(iTerrId, newAccount, newAddress, true);
                alignBrandAffiliationRecords(newAccount.Id, iTerrId);
            }

            if (inputData.isPopupMode == true) {
                resultData.accountId = newAccount.Id;
            } else {
                resultData.retUrl = '/' + newAccount.Id;
            }
        }
        GNE_FRM_Synchronize_Records_With_MDM.syncOnAccountUpsert(newAccount, newAddress, GNE_FRM_Synchronize_Records_With_MDM.DML_Type.DML_INSERT, true);

        return resultData;
    }

    protected virtual Id populateFromInputFields(Account acc, Address_vod__c addr) {
        DataWrapper inputData = (DataWrapper) this.inputDataWrapper;
        Id terrId = null;

        for (GNE_SFA2_Base_Ctrl.Field fld : inputData.createInputFields) {
            if (fld.name == 'territory' && String.isNotBlank(fld.value)) {
                terrId = (Id) fld.value;
            } else if (fld.describe != null && fld.describe.sObjectType == 'Account') {
                acc.put(fld.describe.name, fld.getValue());
            } else if (fld.describe != null && fld.describe.sObjectType == 'Address_vod__c') {
                addr.put(fld.describe.name, fld.getValue());
            }
        }

        return terrId;
    }

    protected virtual void validateBeforeInsert(Account newAccount, Address_vod__c newAddress) {
        validateBeforeUpsert(newAccount, newAddress);
    }

    protected virtual void validateBeforeUpsert(Account newAccount, Address_vod__c newAddress) {
        if (newAddress != null && !isZipValid(newAddress.Zip_vod__c, false)) {
            handleException(createException(new SbcInvalidZipCodeException(String.valueOf(Address_vod__c.Zip_vod__c), 'Address_vod__c', false)));
        }

        List<Account> sapIdDuplicateAcc;
        if (isLWOUser() && String.isNotBlank(newAccount.SAP_ID_gne__c) && !(sapIdDuplicateAcc = GNE_SFA2_SBC_DAO.getAccountBySapId(String.escapeSingleQuotes(newAccount.SAP_ID_gne__c))).isEmpty()) {
            handleException(createException(new SbcDuplicatedSapIdException(String.valueOf(Account.SAP_ID_gne__c), 'Account', sapIdDuplicateAcc[0].Name)));
        }
    }

    private Boolean isZipValid(String zipCode, Boolean searchOrCreateMode) {
        return String.isBlank(zipCode) || (searchOrCreateMode ? Pattern.matches('^[0-9]{3,5}$', zipCode) : Pattern.matches('^[0-9]{3,5}$|^[0-9]{5}-[0-9]{4}$', zipCode));
    }

    private void setAccountType(String accMode, Account acc, Boolean isCreateMode) {
        DataWrapper inputData = (DataWrapper) this.inputDataWrapper;
        inputData.accountTypesMap = inputData.accountTypesMap != null ? inputData.accountTypesMap : getAccountTypesMap();
        Map<String, AccountTypeWrapper> accTypesMap = inputData.accountTypesMap.get(accMode);
        String accType = accMode == 'hcp' ? 'default' : String.isNotBlank(acc.Account_Type_gne__c) ? acc.Account_Type_gne__c.toUpperCase() : 'default';
        accType = isLWOUser() && isCreateMode && accType == 'default' ? 'lwo' : accType;
        AccountTypeWrapper aTypeWrapper = accTypesMap.containsKey(accType) ? accTypesMap.get(accType) : accTypesMap.get('default');

        if (aTypeWrapper != null && acc.Professional_Type_gne__c == 'Patient Ambassador') {
            acc.RecordTypeId = GNE_SFA2_SBC_DAO.getRecordTypeIdMap('Account', new Set<String>{
                    'Contracted_Patient_gne'
            }).get('CONTRACTED_PATIENT_GNE');
        } else if (aTypeWrapper != null) {
            acc.RecordTypeId = aTypeWrapper.recordTypeId;
        }

        if (aTypeWrapper != null && String.isNotBlank(aTypeWrapper.accountType)) {
            acc.Account_Type_gne__c = aTypeWrapper.accountType;
        }

        if (aTypeWrapper != null && String.isNotBlank(aTypeWrapper.ssn)) {
            acc.Stewardship_System_Name_gne__c = aTypeWrapper.ssn;
        }
    }

    private void setCredentials(String accMode, Account acc) {
        if (accMode == 'hcp') {
            acc.Credentials_gne__pc = acc.Credentials_gne__c = acc.Credentials_vod__c;
        }
    }

    private Boolean getFRMHCOMode() {
        if (isFRMHCOMode != null) {
            return isFRMHCOMode;
        } else {
            isFRMHCOMode = GNE_SFA2_Util.isFrmUser() || getCurrentUserProfileName().toUpperCase().contains('340B') || getCurrentUserProfileName().toUpperCase().contains('BAM');
            return isFRMHCOMode;
        }
    }

    protected override virtual Id getCurrentTerritoryId() {
        Id result = null;
        DataWrapper inputData = (DataWrapper) this.inputDataWrapper;
        currentUser = inputData.appContext != null ? inputData.appContext.currentUser : getCurrentUser();
        result = super.getCurrentTerritoryId();

        if (result != null && inputData.territoriesMap != null && !inputData.territoriesMap.containsKey(result)) {
            inputData.territoriesMap.put(result, new TerritoryWrapper(
                    new Map<Id, Territory2>(userTerritoriesCache).get(result),
                    GNE_SFA2_SBC_DAO.getTerritoryGroups(new Set<Id>{
                            result
                    })[0].Id
            ));
        }

        return result;
    }

    protected virtual void upsertTerritoryRecords(Id terrId, Account newAccount, Address_vod__c newAddress, Boolean newAccountMode) {
        if (terrId != null) {
            DataWrapper inputData = (DataWrapper) this.inputDataWrapper;

            if (inputData.territoriesMap == null) {
                getTerritories();
                inputData.territoriesMap = ((DataWrapper) this.dataWrapper).territoriesMap;
            }

            TerritoryWrapper terrWrapper = inputData.territoriesMap.get(terrId);
            ObjectTerritory2Association territoryAssociation = new ObjectTerritory2Association(ObjectId = newAccount.Id, Territory2Id = terrWrapper.id, AssociationCause = 'Territory2Manual');
            TSF_vod__c tsf = getTSF(terrWrapper, newAccount);

            if (newAccountMode) {
                tsf.Address_vod__c = newAddress.Id;
                executeDml(GNE_SFA2_Base_Ctrl.DmlOperations.INS, new SObject[]{
                        territoryAssociation, tsf
                }, false);
            } else {
                if (existingAccShares.isEmpty()) {
                    executeDml(GNE_SFA2_Base_Ctrl.DmlOperations.UPS, territoryAssociation, false);
                }

                upsertTSF(tsf);
            }

            this.upsertedTSFs = new List<TSF_vod__c>{
                    tsf
            };
            Account_Alignment_WS.InsertBrandAffiliation(terrWrapper.id, newAccount.Id);
        }
    }

    protected virtual void alignBrandAffiliationRecords(Id accId, Id terrId) {
        if (accId != null) {
            GNE_SFA2_Territory_Alignment_Helper.alignBrandAffiliationsForTLCRM(new Set<Id>{
                    accId
            }, terrId);
        }
    }

    protected virtual TSF_vod__c getTSF(TerritoryWrapper tWrapper, Account acc) {
        TSF_vod__c result = new TSF_vod__c(Territory_vod__c = tWrapper.name, Account_vod__c = acc.Id, My_Target_vod__c = true, Is_Self_Alignment_gne__c = true);
        List<TSF_vod__c> existingTsf = [SELECT Id FROM TSF_vod__c WHERE Territory_vod__c = :tWrapper.name AND Account_vod__c = :acc.Id LIMIT 1];
        if (!existingTsf.isEmpty()) {
            result.Id = existingTsf.get(0).Id;
        }

        return result;
    }

    protected virtual void upsertTSF(TSF_vod__c tsf) {
        if (existingTSFs.isEmpty()) {
            executeDml(GNE_SFA2_Base_Ctrl.DmlOperations.UPS, tsf, false);
        } else {
            fetchExistingTSF(tsf, existingTSFs.get(tsf.Territory_vod__c.toUpperCase()));
        }
    }

    protected virtual void fetchExistingTSF(TSF_vod__c tsf, TSF_vod__c eTsf) {
        tsf.Id = eTsf.Id;
    }

    protected virtual DataWrapper updateAccount(String inputDataWrapperInJSON) {
        DataWrapper = getDataWrapperInstance();
        System.Savepoint sp = Database.setSavepoint();
        Boolean isOk = false;

        try {
            this.inputDataWrapper = (DataWrapper) JSON.deserialize(inputDataWrapperInJSON, GNE_SFA2_SBC_Ctrl.DataWrapper.class);
            DataWrapper = intUpdateAccount();
            isOk = true;
        } catch (Exception ex) {
            handleException(ex);
        } finally {
            if (!isOk) {
                Database.rollback(sp);
            }
        }

        dataWrapper.onActionFinish('Update Account');
        return (DataWrapper) DataWrapper;
    }

    protected virtual DataWrapper intUpdateAccount() {
        DataWrapper inputData = (DataWrapper) this.inputDataWrapper;
        DataWrapper resultData = (DataWrapper) DataWrapper;
        String sbcMode = inputData.sbcMode;
        Account existingAccount = new Account();
        Address_vod__c existingAddress = new Address_vod__c();

        String accMode = getAccountMode(sbcMode);
        Id terrId = populateFromInputFields(existingAccount, existingAddress);

        if (inputData.isEditAccountMode == true) {
            setAccountType(accMode, existingAccount, true);
            setCredentials(accMode, existingAccount);
        }

        validateBeforeUpsert(existingAccount, existingAddress);

        if (resultData.success == true) {
            if (inputData.isEditAccountMode == true) {
                executeDml(GNE_SFA2_Base_Ctrl.DmlOperations.UPD, existingAccount, false);
            }

            this.upsertedAccount = existingAccount;

            if (inputData.isEditAddressMode == true) {
                executeDml(GNE_SFA2_Base_Ctrl.DmlOperations.UPD, existingAddress, false);
                this.upsertedAddresses = new List<Address_vod__c>{
                        existingAddress
                };
            }

            Boolean allignToTerritory = inputData.isEditAccountMode == true && !(getFRMHCOMode() && sbcMode == HCP_SEARCH_MODE);

            if (allignToTerritory) {
                upsertTerritoryRecords(terrId, existingAccount, existingAddress, true);
                alignBrandAffiliationRecords(existingAccount.Id, terrId);
            }

            resultData.retUrl = '/' + existingAccount.Id;
        }

        return resultData;
    }

    global virtual DataWrapper upsertAccount(String inputDataWrapperInJSON) {
        DataWrapper = getDataWrapperInstance();
        System.Savepoint sp = Database.setSavepoint();
        Boolean isOk = false;

        try {
            this.inputDataWrapper = (DataWrapper) JSON.deserialize(inputDataWrapperInJSON, GNE_SFA2_SBC_Ctrl.DataWrapper.class);
            DataWrapper = intUpsertAccount();
            isOk = true;
        } catch (Exception ex) {
            handleException(ex);
        } finally {
            if (!isOk) {
                Database.rollback(sp);
            }
        }

        dataWrapper.onActionFinish('Upsert Account');
        return (DataWrapper) DataWrapper;
    }

    protected virtual DataWrapper intUpsertAccount() {
        DataWrapper inputData = (DataWrapper) this.inputDataWrapper;
        DataWrapper resultData = (DataWrapper) DataWrapper;
        String sbcMode = inputData.sbcMode;
        String accMode = getAccountMode(sbcMode);
        SearchData searchData = inputData.searchData.get(accMode);
        SearchAccountWrapper selectedAccountRow = searchData.selectedAccountRow;
        List<SearchAddressWrapper> selectedAddressRows = searchData.selectedAddressRows != null && !searchData.selectedAddressRows.isEmpty() ? searchData.selectedAddressRows : new List<SearchAddressWrapper>{
                selectedAccountRow.addresses[0]
        };
        Account acc = selectedAccountRow.getAccount();

        List<Address_vod__c> addrs = new List<Address_vod__c>();
        Map<String, Id> recordTypeIdsMap = GNE_SFA2_SBC_DAO.getRecordTypeIdMap('Address_vod__c', new Set<String>{
                REC_TYPE_ADDR_REP, REC_TYPE_ADDR_COMPANY
        });

        Set<String> licenseNumbers = new Set<String>();

        for (SearchAddressWrapper selectedAddressRow : selectedAddressRows) {
            Id addrRecTypeId = (String.isNotBlank(selectedAddressRow.mdmAddrId) || String.isNotBlank(selectedAddressRow.locationId)) ? recordTypeIdsMap.get(REC_TYPE_ADDR_COMPANY.toUpperCase()) : recordTypeIdsMap.get(REC_TYPE_ADDR_REP.toUpperCase());
            Address_vod__c addr = selectedAddressRow.getAddress(selectedAccountRow.licensesMap);
            addr.RecordTypeId = addrRecTypeId;
            addrs.add(addr);
            if (selectedAccountRow.licensesMap != null) {
                for (String state : selectedAccountRow.licensesMap.keySet()) {
                    LicenseWrapper lWrapper = selectedAccountRow.licensesMap.get(state)[0];
                    licenseNumbers.add(lWrapper.licenseNumber);
                }
            }
        }

        if (String.isNotBlank(acc.MDMID_gne__c)) {
            fetchExistingAccountAndAddress(acc, addrs);
        }

        if (inputData.isCreateAddressMode != true) {
            setAccountType(accMode, acc, false);
            acc.OwnerId = getDefaultAccountOwnerId(acc);
        }

        Set<Id> hiddenAddrIds = String.isNotBlank(acc.Id) ? getHiddenAddressCtrl().getHiddenAddressIds(getCurrentUser().id, acc.Id) : new Set<Id>();

        if (acc.Id == null && selectedAccountRow.status == 'Indeterminate') {
            acc.MDMID_Status_gne__c = 'Active';
        }

        CORE_Subscribe_Util.setSubscribeProcess(true);
        GNE_SFA2_Account_Trigger_Helper.setValidationDisabled(true);
        GNE_SFA2_Address_Trigger_Helper.setValidationDisabled(true);
        if (inputData.isCreateAddressMode != true) {
            executeDml(GNE_SFA2_Base_Ctrl.DmlOperations.UPS, acc, false);
        }

        this.upsertedAccount = acc;
        List<Address_vod__c> addrsToShow = new List<Address_vod__c>();

        for (Address_vod__c addr : addrs) {
            if (addr.Id == null) {
                addr.Account_vod__c = acc.Id;
            } else if (hiddenAddrIds.contains(addr.Id)) {
                addrsToShow.add(new Address_vod__c(Id = addr.Id, Account_vod__c = acc.Id));
            }
        }

        executeDml(GNE_SFA2_Base_Ctrl.DmlOperations.UPS, addrs, false);

        if (!addrsToShow.isEmpty()) {
            getHiddenAddressCtrl().showAddresses(getCurrentUser().id, addrsToShow);
        }

        Map<String, Prescriber_License_gne__c> licNumToLic = new Map<String, Prescriber_License_gne__c>();
        if (!licenseNumbers.isEmpty()) {
            for (Prescriber_License_gne__c lic : [SELECT Id, Name, Account_gne__c, Designation_gne__c, License_Expiration_Date_gne__c, License_State_gne__c, License_Status_gne__c, License_Valid_To_Sample_gne__c FROM Prescriber_License_gne__c WHERE Account_gne__c = :acc.Id AND Name in :licenseNumbers]) {
                licNumToLic.put(lic.Name, lic);
            }

            for (SearchAddressWrapper selectedAddressRow : selectedAddressRows) {
                for (String state : selectedAccountRow.licensesMap.keySet()) {
                    LicenseWrapper lWrapper = selectedAccountRow.licensesMap.get(state)[0];
                    if (licNumToLic.containsKey(lWrapper.licenseNumber)) {
                        Prescriber_License_gne__c lic = licNumToLic.get(lWrapper.licenseNumber);
                        lic.License_Expiration_Date_gne__c = String.isNotBlank(lWrapper.expirationDate) ? Date.valueOf(lWrapper.expirationDate) : null;
                        lic.License_Status_gne__c = lWrapper.isValid() ? 'Valid_vod' : 'Invalid_vod';
                        lic.Designation_gne__c = lWrapper.designation;
                    } else {
                        Prescriber_License_gne__c lic = new Prescriber_License_gne__c(Name = lWrapper.licenseNumber, License_State_gne__c = state, Account_gne__c = acc.Id);
                        lic.License_Expiration_Date_gne__c = String.isNotBlank(lWrapper.expirationDate) ? Date.valueOf(lWrapper.expirationDate) : null;
                        lic.License_Status_gne__c = lWrapper.isValid() ? 'Valid_vod' : 'Invalid_vod';
                        lic.Designation_gne__c = lWrapper.designation;
                        licNumToLic.put(lic.Name, lic);
                    }
                }
            }
            executeDml(DmlOperations.UPS, licNumToLic.values(), false);
        }

        CORE_Subscribe_Util.setSubscribeProcess(true);
        GNE_SFA2_Account_Trigger_Helper.setValidationDisabled(false);
        GNE_SFA2_Address_Trigger_Helper.setValidationDisabled(false);
        this.upsertedAddresses = addrs;

        Boolean allignToTerritory = !(inputData.isCreateAddressMode == true || (getFRMHCOMode() && sbcMode == HCP_SEARCH_MODE));

        if (allignToTerritory) {
            Id iTerrId = (inputData.isSfaBrandUser == true || getFRMHCOMode()) ? getCurrentTerritoryId() : null;
            upsertTerritoryRecords(iTerrId, acc, null, false);
            alignBrandAffiliationRecords(acc.Id, iTerrId);
        }

        if (inputData.isPopupMode == true) {
            resultData.accountId = acc.Id;
            resultData.addressId = addrs.get(0).Id;
        } else {
            resultData.retUrl = '/' + acc.Id;
        }

        return resultData;
    }

    protected virtual void fetchExistingAccountAndAddress(Account acc, List<Address_vod__c> addrs) {
        DataWrapper inputData = (DataWrapper) inputDataWrapper;
        Boolean manageTerritoryRecs = inputData.isCreateAddressMode != true && inputData.territoriesMap != null;
        fetchExistingAccountAndAddress(acc, addrs, manageTerritoryRecs ? inputData.territoriesMap.get(getCurrentTerritoryId()) : null);
    }
    protected virtual void fetchExistingAccountAndAddress(Account acc, List<Address_vod__c> addrs, TerritoryWrapper tWrapper) {
        Map<String, Address_vod__c> mdmIdToAddress = new Map<String, Address_vod__c>();
        Map<String, Address_vod__c> extIdToAddress = new Map<String, Address_vod__c>();
        existingAccShares = new Map<Id, AccountShare>();
        existingTSFs = new Map<String, TSF_vod__c>();
        for (Address_vod__c addr : addrs) {
            if (String.isNotBlank(addr.MDM_Address_ID_gne__c)) {
                mdmIdToAddress.put(addr.MDM_Address_ID_gne__c, addr);
            }
            if (String.isNotBlank(addr.External_ID_vod__c)) {
                extIdToAddress.put(addr.External_ID_vod__c, addr);
            }
        }
        Set<Id> terrGroupIds = tWrapper != null ? new Set<Id>{
                tWrapper.groupId
        } : new Set<Id>();

        Set<String> terrNames = tWrapper != null ? new Set<String>{
                tWrapper.name
        } : new Set<String>();

        List<Account> existingAccs = GNE_SFA2_SBC_DAO.getAccountByMdmId(acc.MDMID_gne__c, mdmIdToAddress.keySet(), extIdToAddress.keySet(), terrGroupIds, terrNames);

        for (Account eAcc : existingAccs) {
            fetchExistingAccount(acc, eAcc);

            for (Address_vod__c eAddr : eAcc.Address_vod__r) {
                Address_vod__c addr = mdmIdToAddress.get(eAddr.MDM_Address_ID_gne__c);
                if (addr == null) {
                    addr = extIdToAddress.get(eAddr.External_ID_vod__c);
                }
                fetchExistingAddress(addr, eAddr);
            }

            for (AccountShare aShare : eAcc.Shares) {
                existingAccShares.put(aShare.UserOrGroupId, aShare);
            }

            for (TSF_vod__c tsf : eAcc.TSF_vod__r) {
                existingTSFs.put(tsf.Territory_vod__c.toUpperCase(), tsf);
            }
        }
    }

    protected virtual void fetchExistingAccount(Account acc, Account eAcc) {
        acc.Id = eAcc.Id;

        if (!eAcc.IsPersonAccount && String.isNotBlank(acc.Account_Type_gne__c) && !getAccountTypesMap().get('hco').containsKey(acc.Account_Type_gne__c.toUpperCase())) {
            acc.Account_Type_gne__c = eAcc.Account_Type_gne__c;
        }
    }

    protected virtual void fetchExistingAddress(Address_vod__c addr, Address_vod__c eAddr) {
        addr.Id = eAddr.Id;
    }

    private Boolean isLWOUser() {
        return getCurrentUserProfileName().toUpperCase().contains('LWO');
    }

    private Id getDefaultAccountOwnerId(Account acc) {
        Map<Id, Schema.RecordTypeInfo> rt_Map = Account.SObjectType.getDescribe().getRecordTypeInfosById();
        String recordTypeName = acc.RecordTypeId != null ? rt_Map.get(acc.RecordTypeId).getName() : null;
        CORE_Pub_Org_Typ_Map__c [] settings = [
                SELECT Account_Owner_gne__c
                FROM CORE_Pub_Org_Typ_Map__c
                WHERE Account_Record_Type_Display_gne__c = :recordTypeName
                AND Account_Type_gne__c = :acc.Account_Type_gne__c
        ];

        String recTypeDefOwner = !settings.isEmpty() && String.isNotBlank(settings[0].Account_Owner_gne__c) ? settings[0].Account_Owner_gne__c : null;

        if (defaultAccountOwnerId == null) {
            String ownerExtId = recTypeDefOwner == null ? GNE_SFA2_SBC_Config.getConfigItem(GNE_SFA2_SBC_Config.ConfigItems.DefaultRecordOwner) : recTypeDefOwner;
            if (ownerExtId != null) {
                defaultAccountOwnerId = getAccountOwner(ownerExtId);
            }

            if (defaultAccountOwnerId == null) {
                defaultAccountOwnerId = getCurrentUser().id;
            }
        }

        return defaultAccountOwnerId;
    }

    private Id getAccountOwner(String extId) {
        Id result = null;
        List<User> users = GNE_SFA2_Util.getUserByExternalId(extId);

        for (User u : users) {
            result = u.Id;
        }

        return result;
    }

    global virtual class DataWrapper extends GNE_SFA2_Base_Ctrl.DataWrapper {
        public String sbcMode;
        public String hcpSearchMode;
        public String hcoSearchMode;
        public Id hcpSearchRecId;
        public Id hcoSearchRecId;
        public Boolean isCreateAddressMode;
        public Boolean isEditAccountMode;
        public Boolean isEditAddressMode;
        public Id accountId;
        public Id addressId;
        public String mdmId;
        public String addressCreateUrl;
        public Map<String, Map<String, AccountTypeWrapper>> accountTypesMap;
        public Map<Id, TerritoryWrapper> territoriesMap;
        public Set<String> teamCodes;
        public Map<String, SearchData> searchData;
        public List<GNE_SFA2_Base_Ctrl.Field> createInputFields;
        public Boolean isFRMHCOMode;

        public DataWrapper() {
            super();
        }

        public override void onActionFinish(String actionName) {
            super.onActionFinish(actionName);

            if (actionName.startsWithIgnoreCase('search')) {
                debugInfos[0] += '<a href="/' + SFA2_SBC_Profiler_Log_gne__c.SObjectType.getDescribe().getKeyPrefix() + '" target="_blank">Profiler Log</a>';
            }
        }
    }

    public class AccountTypeWrapper {
        public String accountType;
        public Id recordTypeId;
        public String ssn;

        public AccountTypeWrapper(Id recordTypeId) {
            this(null, recordTypeId, null);
        }

        public AccountTypeWrapper(String accountType, Id recordTypeId, String ssn) {
            this.accountType = accountType;
            this.recordTypeId = recordTypeId;
            this.ssn = ssn;
        }
    }

    public class TerritoryWrapper {
        public Id id;
        public Id groupId;
        public String name;

        public TerritoryWrapper(Territory2 terr, Id groupId) {
            this.id = terr.Id;
            this.name = terr.Name;
            this.groupId = groupId;
        }
    }

    public class SearchData {
        public String searchMode;
        public List<GNE_SFA2_Base_Ctrl.Field> searchFields;
        public Map<String, String> searchValues;
        public List<GNE_SFA2_Base_Ctrl.Field> accountColumns;
        public List<GNE_SFA2_Base_Ctrl.Field> addressColumns;
        public List<GNE_SFA2_Base_Ctrl.Field> accountAdditionalColumns;
        public List<SearchAccountWrapper> results;
        public GNE_SFA2_SBC_DAO.PaginationDataWrapper paginationData;
        public SearchAccountWrapper selectedAccountRow;
        public List<SearchAddressWrapper> selectedAddressRows;

        public SearchData(String searchMode, List<GNE_SFA2_Base_Ctrl.Field> searchFields) {
            this.searchMode = searchMode;
            this.searchFields = searchFields;
            this.results = new List<SearchAccountWrapper>();
        }
    }

    public virtual class SearchAccountWrapper {
        public String id;
        public String mdmId;
        public String insId;
        public String name;
        public String lastName;
        public String firstName;
        public String middleName;
        public String status;
        public String type;
        public String typeCode;
        public String phone;
        public String fax;
        public String website;
        public String facility;
        public List<String> credentials;
        public List<String> altNames;
        public List<String> licenses;
        public Map<String, List<LicenseWrapper>> licensesMap;
        public List<SearchAddressWrapper> addresses;
        public List<String> specialties;

        public SearchAccountWrapper() {
        }

        public SearchAccountWrapper(GNE_SFA2_SBC_DAO.AccountWrapper accWrapper) {
            if (accWrapper.isPersonAccount) {
                this.lastName = accWrapper.lastName;
                this.firstName = accWrapper.firstName;
                this.middleName = accWrapper.middleName;
                this.licensesMap = getLicensesMap(accWrapper);
                this.licenses = getLicensesList(this.licensesMap);
                List<String> profTypes = GNE_SFA2_SBC_Config.getHcpProfTypesSortedByRank(accWrapper.profTypes != null ? new Set<String>(accWrapper.profTypes) : null);
                this.type = !profTypes.isEmpty() ? profTypes[0] : null;
                this.credentials = accWrapper.credentials != null ? new List<String>(accWrapper.credentials) : new List<String>();
                this.credentials.sort();
                this.specialties = accWrapper.specialties != null ? new List<String>(accWrapper.specialties) : new List<String>();
            } else {
                this.name = accWrapper.name;
                this.insId = accWrapper.insId;
                if (!accWrapper.accountTypes.isEmpty()) {
                    this.type = accWrapper.accountTypes[0].name;
                    this.typeCode = accWrapper.accountTypes[0].code;
                }
                this.fax = accWrapper.fax;
                this.phone = accWrapper.phone;
                this.website = accWrapper.website;
                this.facility = accWrapper.facility;
            }

            this.mdmId = accWrapper.mdmId;
            this.status = accWrapper.status;
            this.altNames = new List<String>(accWrapper.alternateNames);
            this.addresses = new List<SearchAddressWrapper>();
        }

        private Map<String, List<LicenseWrapper>> getLicensesMap(GNE_SFA2_SBC_DAO.AccountWrapper mdmAccWrapper) {
            Map<String, List<LicenseWrapper>> result = mdmAccWrapper.licenses != null ? new Map<String, List<LicenseWrapper>>() : null;

            if (mdmAccWrapper.licenses != null) {
                for (GNE_SFA2_SBC_DAO.LicenseWrapper license : mdmAccWrapper.licenses) {
                    String lState = license.issuedState;

                    if (!result.containsKey(lState)) {
                        result.put(lState, new List<LicenseWrapper>());
                    }

                    result.get(lState).add(new LicenseWrapper(license));
                }

                for (String lState : result.keySet()) {
                    List<LicenseWrapper> lWrappers = result.get(lState);
                    lWrappers.sort();
                    if (lWrappers.size() > 1 && lWrappers[0].isValid()) {
                        if (lWrappers[0].sampleability) {
                            removeNotSampleableLicenses(lWrappers);
                        } else {
                            removeInvalidLicenses(lWrappers);
                        }

                    }
                }
            }

            return result;
        }

        private List<String> getLicensesList(Map<String, List<LicenseWrapper>> licensesMap) {
            List<String> licensesList = new List<String>();

            List<String> statesList = new List<String>(licensesMap != null ? licensesMap.keySet() : new Set<String>());
            statesList.sort();

            for (String state : statesList) {
                for (LicenseWrapper lWrapper : licensesMap.get(state)) {
                    licensesList.add(lWrapper.state + '-' + lWrapper.licenseNumber);
                }
            }

            return licensesList;
        }

        private void removeNotSampleableLicenses(List<LicenseWrapper> lWrappers) {
            for (Integer i = lWrappers.size() - 1; i > 0; i--) {
                if (!lWrappers[i].isValid() || lWrappers[i].sampleability != true) {
                    lWrappers.remove(i);
                }
            }
        }

        private void removeInvalidLicenses(List<LicenseWrapper> lWrappers) {
            for (Integer i = lWrappers.size() - 1; i > 0; i--) {
                if (!lWrappers[i].isValid()) {
                    lWrappers.remove(i);
                }
            }
        }

        public virtual Account getAccount() {
            Account acc = new Account(Id = this.id, MDMID_gne__c = mdmId, Status_gne__c = status);

            if (status != 'Indeterminate') {
                acc.MDMID_Status_gne__c = status == 'Active' ? status : 'Inactive';
            }

            if (String.isNotBlank(lastName)) {
                acc.LastName = lastName;
                acc.FirstName = firstName;
                acc.Middle_gne__c = acc.Middle_vod__c = middleName;
                acc.Professional_Type_gne__c = type;
                acc.Credentials_gne__c = String.join(credentials != null ? credentials : new List<String>(), ';');
                acc.Specialties_gne__c = String.join(specialties != null ? specialties : new List<String>(), ';');
            } else {
                acc.Name = name;
                acc.Account_Type_gne__c = type;
                acc.INS_ID_gne__c = insId;
                acc.Fax = fax;
                acc.Website = website;
                acc.Phone = phone;
                acc.Facility_Type_gne__c = facility;
            }

            return acc;
        }
    }

    public virtual class SearchAddressWrapper {
        public String id;
        public String locationId;
        public String mdmAddrId;
        public String street;
        public String street2;
        public String suite;
        public String city;
        public String state;
        public String zip;
        public Boolean isDefault;
        public Double latitude;
        public Double longitude;
        public String status;
        public String mapUrl;
        public Integer addrIdx;
        public String phoneNumber;

        public SearchAddressWrapper() {
        }

        public SearchAddressWrapper(GNE_SFA2_SBC_DAO.AddressWrapper addr, SearchAccountWrapper parent) {
            this(null, addr.mdmAddressId, addr.partyLocId, String.isNotBlank(addr.streetAddress) ? addr.streetAddress : addr.suite, String.isNotBlank(addr.streetAddress) ? addr.suite : null,
                    addr.stateCode, addr.cityName, addr.zipCode, addr.isDefault, addr.status, addr.latitude, addr.longitude, addr.phoneNumber, parent);
        }

        public SearchAddressWrapper(Address_vod__c addr, SearchAccountWrapper parent) {
            this(addr.Id, addr.MDM_Address_ID_gne__c, addr.External_ID_vod__c, addr.Name, addr.Address_line_2_vod__c, addr.State_vod__c, addr.City_vod__c, addr.Zip_vod__c, addr.Primary_vod__c, addr.MDM_Status_gne__c,
                    (Double) addr.Location_gne__Latitude__s, (Double) addr.Location_gne__Longitude__s, addr.Phone_vod__c, parent);
        }

        private SearchAddressWrapper(Id id, String mdmAddrId, String locationId, String street, String suite, String state, String city, String zip, Boolean isDefault, String status,
                Double latitude, Double longitude, String phoneNumber,
                SearchAccountWrapper parent) {
            this.id = id;
            this.mdmAddrId = mdmAddrId;
            this.locationId = locationId;
            this.street = street;
            this.suite = suite;
            this.state = state;
            this.city = city;
            this.zip = zip;
            this.isDefault = isDefault;
            this.latitude = latitude;
            this.longitude = longitude;
            this.status = status;
            this.mapUrl = String.format(GNE_SFA2_SBC_Config.getConfigItem(GNE_SFA2_SBC_Config.ConfigItems.SBCGoogleMapURL), new String[]{
                    EncodingUtil.urlEncode('+', 'UTF-8'),
                    EncodingUtil.urlEncode(street != null ? street : '', 'UTF-8'),
                    EncodingUtil.urlEncode(city != null ? city : '', 'UTF-8'),
                    EncodingUtil.urlEncode(state != null ? state : '', 'UTF-8'),
                    EncodingUtil.urlEncode(zip != null ? zip : '', 'UTF-8')
            });
            this.phoneNumber = phoneNumber;
            this.addrIdx = parent.addresses.size();
            parent.addresses.add(this);
        }

        public virtual Address_vod__c getAddress(Map<String, List<LicenseWrapper>> licensesMap) {
            Address_vod__c addr = new Address_vod__c(
                    Id = this.id,
                    MDM_Address_ID_gne__c = mdmAddrId,
                    Name = street,
                    Address_line_2_vod__c = suite,
                    City_vod__c = city,
                    State_vod__c = state,
                    Zip_vod__c = zip,
                    MDM_Status_gne__c = String.isNotBlank(status) ? status : 'Active',
                    Active_Flag_gne__c = true,
                    Inactive_vod__c = false,
                    Primary_vod__c = isDefault,
                    External_ID_vod__c = String.isBlank(mdmAddrId) ? locationId : null,
                    Phone_vod__c = phoneNumber
            );

            if (latitude != null && longitude != null) {
                addr.Latitude_vod__c = addr.Location_gne__Latitude__s = latitude;
                addr.Longitude_vod__c = addr.Location_gne__Longitude__s = longitude;
                addr.Force_Location_Update_gne__c = false;
            } else {
                addr.Force_Location_Update_gne__c = true;
            }

            if (licensesMap != null && licensesMap.containsKey(state)) {
                LicenseWrapper lWrapper = licensesMap.get(state)[0];
                addr.License_vod__c = lWrapper.licenseNumber;
                addr.License_Expiration_Date_vod__c = String.isNotBlank(lWrapper.expirationDate) ? Date.valueOf(lWrapper.expirationDate) : null;
                addr.License_Status_vod__c = lWrapper.isValid() ? 'Valid_vod' : 'Invalid_vod';
                addr.Designation_gne__c = lWrapper.designation;
            }

            return addr;
        }
    }

    public class LicenseWrapper implements Comparable {
        public String state;
        public String licenseNumber;
        public String expirationDate;
        public Boolean sampleability;
        public String designation;
        public transient Integer rank;

        public LicenseWrapper(GNE_SFA2_SBC_DAO.LicenseWrapper license) {
            this.state = license.issuedState;
            this.licenseNumber = license.licenseNumber;
            this.expirationDate = license.expirationDate != null ? Datetime.newInstanceGmt(license.expirationDate, Time.newInstance(0, 0, 0, 0)).formatGmt('yyyy-MM-dd') : null;
            this.sampleability = license.sampleability;
            this.designation = license.designation;
        }

        public Integer compareTo(Object otherLicense) {
            Integer rank = this.getRank();
            Integer otherRank = ((LicenseWrapper) otherLicense).getRank();
            Integer result = rank - otherRank;
            return result == 0 ? result : result > 0 ? -1 : 1;
        }

        public Integer getRank() {
            if (rank == null) {
                rank = 0;

                if (isValid()) {
                    rank += 10;
                }

                if (!isExpired()) {
                    rank += 1;
                }
            }

            return rank;
        }

        public Boolean isValid() {
            return sampleability;
        }

        public Boolean isExpired() {
            return expirationDate != null && Date.valueOf(expirationDate) <= System.today();
        }

        public Prescriber_License_gne__c getLicense() {
            Prescriber_License_gne__c lic = new Prescriber_License_gne__c(Name = this.licenseNumber, License_State_gne__c = state);
            lic.License_Expiration_Date_gne__c = String.isNotBlank(this.expirationDate) ? Date.valueOf(this.expirationDate) : null;
            lic.License_Status_gne__c = this.isValid() ? 'Valid_vod' : 'Invalid_vod';
            lic.Designation_gne__c = this.designation;
            return lic;
        }
    }

    public class SbcInvalidZipCodeException extends GNE_SFA2_Base_Ctrl.BaseException {
        public SbcInvalidZipCodeException(String fieldName, String sObjectType, Boolean searchMode) {
            this.type = ErrorTypes.Error.name();
            this.subType = 'SbcInvalidZipCode';
            this.fieldMessage = searchMode ? System.Label.GNE_SFA2_SBC_Error_InvalidZipSearchMode : System.Label.GNE_SFA2_SBC_Error_InvalidZipCreateMode;
            this.label = System.Label.GNE_SFA2_SBC_Error_InvalidZip + ' ' + this.fieldMessage;
            this.fieldName = fieldName;
            this.sObjectType = sObjectType;
        }

        protected override void init() {
        }
    }

    public class SbcLincenseTooShortException extends GNE_SFA2_Base_Ctrl.BaseException {
        public SbcLincenseTooShortException(String fieldName, String sObjectType) {
            this.type = ErrorTypes.Error.name();
            this.subType = 'SbcLincenseTooShort';
            this.fieldMessage = System.Label.GNE_SFA2_SBC_Error_LicenseTooShort;
            this.label = this.fieldMessage;
            this.fieldName = fieldName;
            this.sObjectType = sObjectType;
        }

        protected override void init() {
        }
    }

    public class SbcDuplicatedSapIdException extends GNE_SFA2_Base_Ctrl.BaseException {
        public SbcDuplicatedSapIdException(String fieldName, String sObjectType, String accName) {
            this.type = ErrorTypes.Error.name();
            this.subType = 'SbcDuplicatedSapId';
            this.fieldMessage = String.format(System.Label.GNE_SFA2_SBC_Error_InvalidSapId, new String[]{
                    accName
            });
            this.label = this.fieldMessage;
            this.fieldName = String.valueOf(Account.SAP_ID_gne__c);
            this.sObjectType = 'Account';
        }

        protected override void init() {
        }
    }

    public class MdmServiceKnownErrorException extends GNE_SFA2_Base_Ctrl.BaseException {
        public MdmServiceKnownErrorException(String subType, String message) {
            this.type = GNE_SFA2_Base_Ctrl.ErrorTypes.Error.name();
            this.subType = String.isNotBlank(subType) ? subType : 'MdmServiceKnownError';
            this.label = message;
        }

        protected override void init() {
        }
    }

    @RemoteAction
    global static DataWrapper search(String searchDataWrapperInJSON) {
        return (new GNE_SFA2_SBC_Ctrl()).searchAccounts(searchDataWrapperInJSON, false);
    }

    @RemoteAction
    global static DataWrapper searchMore(String searchMoreDataWrapperInJSON) {
        return (new GNE_SFA2_SBC_Ctrl()).searchAccounts(searchMoreDataWrapperInJSON, true);
    }

    @RemoteAction
    global static DataWrapper createAccount(String inputDataWrapperInJSON) {
        return (new GNE_SFA2_SBC_Ctrl()).insertAccount(inputDataWrapperInJSON);
    }

    @RemoteAction
    global static DataWrapper upsertAccountFromMdm(String inputDataWrapperInJSON) {
        return (new GNE_SFA2_SBC_Ctrl()).upsertAccount(inputDataWrapperInJSON);
    }


    // USPS Address Validation Logic

    @RemoteAction
    global static String addressValidate(Map<String, String> params) {
        return GNE_SFA2_USPSEngine.addressValidate(params);
    }

    @RemoteAction
    global static String cityStateLookup(Map<String, String> params) {
        return GNE_SFA2_USPSEngine.cityStateLookup(params);
    }

    @RemoteAction
    global static String zipCodeLookup(Map<String, String> params) {
        return GNE_SFA2_USPSEngine.zipCodeLookup(params);
    }


    public GNE_SFA2_SBC_DAO.DataWrapper searchAccounts(String accMode, String searchMode, Map<String, String> searchParams, GNE_SFA2_SBC_DAO.PaginationDataWrapper paginationData, Set<String> teamCodes) {
        Boolean useReltioEngine = GNE_SFA2_ReltioUtil.useReltio(accMode);
        Boolean useSolrEngine = GNE_SFA2_SolrUtil.useSolr(accMode);
        Boolean searchMore = paginationData != null;

        GNE_SFA2_SBC_Profiler.logStart(getSbcProfilerQuery(accMode, searchMode, searchParams, paginationData, teamCodes), Page.GNE_SFA2_SBC.getUrl());
        GNE_SFA2_SBC_DAO.DataWrapper dataWrapper;
        try {
            if(useReltioEngine) {
                dataWrapper = new GNE_SFA2_SBC_Reltio_DAO().searchAccounts(accMode, searchMode, searchParams, paginationData, teamCodes);
            } else if (useSolrEngine) {
                dataWrapper = new GNE_SFA2_SBC_Solr_DAO().searchAccounts(accMode, searchMode, searchParams, paginationData, teamCodes);
            } else {
                dataWrapper = new GNE_SFA2_SBC_MDM_DAO().searchAccounts(accMode, searchMode, searchMore ? null : searchParams, paginationData, teamCodes);
            }
        } finally {

            GNE_SFA2_SBC_Profiler.logEnd(dataWrapper != null && dataWrapper.rows != null ? dataWrapper.rows.size() : null);
        }
        return dataWrapper;
    }


}