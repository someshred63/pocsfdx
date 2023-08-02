@RestResource(UrlMapping='/iPhoneSBC/*')
global with sharing class iPhone_SBC extends GNE_SFA2_SBC_Ctrl implements iPhone_Commons_gne.ResponseBuilder {
    private transient SbcRequest request;
    private transient Territory2 cachedTerritory;
    private transient User user;

    @HttpPost
    global static iPhone_Commons_gne.RestResponse processRequest(SbcRequest request) {
        return iPhone_Commons_gne.buildResponse(
                new iPhone_SBC(),
                request
        );
    }

    public iPhone_Commons_gne.RestResponse build(Object arg) {
        SbcResponse sbcResponse = new SbcResponse();

        try {
            sbcResponse = intBuild(arg, sbcResponse);
        } catch (GNE_SFA2_SBC_DAO.ServiceException mex) {
            handleMdmException(mex);
        }

        GNE_SFA2_DBCacheManager.initDmlCache();
        return sbcResponse;
    }

    protected override void handleMdmException(GNE_SFA2_SBC_DAO.ServiceException mex) {
        String knowErrorMessage = GNE_SFA2_SBC_Config.getMdmKnowErrorMessage(mex.statusCode);
        if (knowErrorMessage != null) {
            throw createException(new MdmServiceKnownErrorException(
                    GNE_SFA2_SBC_Config.getMdmKnowErrorName(mex.statusCode),
                    String.isNotBlank(knowErrorMessage) ? knowErrorMessage : mex.status
            ));
        } else {
            throw mex;
        }
    }

    private String getAccountMode(String accountType) {
        if (String.isNotBlank(accountType) && accountType.equalsIgnoreCase('hco')) {
            return 'hco';
        }
        return 'hcp';
    }

    private SbcResponse intBuild(Object arg, SbcResponse sbcResponse) {
        request = (SbcRequest) arg;
        String accMode = getAccountMode(request.accountType);
        Map<String, String> searchParams = request.searchParams != null ? request.searchParams.toMap() : new Map<String, String>();
        Set<String> teamCodes = request.teamCodes != null && !request.teamCodes.isEmpty() ? new Set<String>(request.teamCodes) : getTerritoryTeamCodes();
        Boolean isSbcAddressMode = request.isSbcAddressMode();
        GNE_SFA2_SBC_Profiler.logStart(getSbcProfilerQuery(accMode, request.searchMode, searchParams, request.paginationData, teamCodes), 'iPhone_SBC');
        try {
            GNE_SFA2_SBC_DAO.DataWrapper dataWrapper = null;
            Boolean useSolrEngine = GNE_SFA2_SolrUtil.useSolr(accMode);
            Boolean useReltioEngine = GNE_SFA2_ReltioUtil.useReltio(accMode);
            try {
                GNE_SFA2_SBC_DAO.PaginationDataWrapper paginationDataWrapper = request.searchMore == true ? request.paginationData : null;
                Integer pageSize = request.pageSize != null ? request.pageSize : getSiperianServicePageSize();
                if(useReltioEngine) {
                    dataWrapper = new GNE_SFA2_SBC_RELTIO_DAO().searchAccounts(accMode, request.searchMode, searchParams, paginationDataWrapper, null);
                } else if (useSolrEngine) {
                    dataWrapper = new GNE_SFA2_SBC_Solr_DAO().searchAccounts(accMode, request.searchMode, searchParams, paginationDataWrapper, teamCodes, pageSize);
                } else {
                    dataWrapper = new GNE_SFA2_SBC_MDM_DAO().searchAccounts(accMode, request.searchMode, searchParams, paginationDataWrapper, teamCodes, pageSize);
                }
            } catch (GNE_SFA2_SBC_DAO.ServiceException mex) {
                if (!isSbcAddressMode) {
                    throw mex;
                }
            }

            GNE_SFA2_SBC_Profiler.logActionStart('SBC.PrepareResults');

            try {
                sbcResponse.results = new List<AccountWrapper>();

                if (dataWrapper != null) {
                    sbcResponse.paginationData = dataWrapper.paginationData;
                    List<GNE_SFA2_SBC_DAO.AccountWrapper> searchMdmResults = dataWrapper.rows;

                    for (GNE_SFA2_SBC_DAO.AccountWrapper mdmAccWrapper : searchMdmResults) {
                        sbcResponse.results.addAll((List<AccountWrapper>) convertToSbcResult(accMode, mdmAccWrapper));
                    }
                } else if (isSbcAddressMode) {
                    AccountWrapper newAccWrapper = new AccountWrapper();
                    newAccWrapper.mdmId = request.searchParams.MDMID;
                    newAccWrapper.addresses = new List<AddressWrapper>();
                    sbcResponse.results.add(newAccWrapper);
                }
            } finally {
                GNE_SFA2_SBC_Profiler.logActionEnd('SBC.PrepareResults');
            }

            GNE_SFA2_SBC_Profiler.logActionStart('SBC.FetchWithExistingRecords');
            try {
                fetchResultsWithExistingRecords(sbcResponse.results, isSbcAddressMode);
            } finally {
                GNE_SFA2_SBC_Profiler.logActionEnd('SBC.FetchWithExistingRecords');
            }
        } finally {
            GNE_SFA2_SBC_Profiler.logEnd(sbcResponse.results != null ? sbcResponse.results.size() : null);
        }
        return sbcResponse;
    }

    private Integer getSiperianServicePageSize() {
        String pageSizeInString = GNE_SFA2_SBC_Config.getConfigItem(GNE_SFA2_SBC_Config.ConfigItems.SBCMdmSiperianOtrPageSize);
        return String.isNotBlank(pageSizeInString) && pageSizeInString.isNumeric() ? Integer.valueOf(pageSizeInString) : GNE_SFA2_SBC_DAO.SERVICE_DEFAULT_PAGE_SIZE;
    }

    protected override List<GNE_SFA2_SBC_Ctrl.SearchAccountWrapper> convertToSbcResult(String accType, GNE_SFA2_SBC_DAO.AccountWrapper mdmAccWrapper) {
        AccountWrapper accountRow = new AccountWrapper(mdmAccWrapper);
        List<AccountWrapper> result = new List<AccountWrapper>{
                accountRow
        };

        for (GNE_SFA2_SBC_DAO.AddressWrapper addr : mdmAccWrapper.addresses) {
            AddressWrapper addressRow = new AddressWrapper(addr, accountRow);
        }

        return result;
    }

    private void fetchResultsWithExistingRecords(List<AccountWrapper> results, Boolean isSbcAddressMode) {
        Set<String> mdmIds = new Set<String>();
        Set<String> mdmAddrIds = new Set<String>();

        if (results != null) {
            for (AccountWrapper accWrapper : results) {
                if (String.isNotBlank(accWrapper.mdmId)) {
                    mdmIds.add(accWrapper.mdmId);

                    for (GNE_SFA2_SBC_Ctrl.SearchAddressWrapper addrWrapper : accWrapper.addresses) {
                        if (String.isNotBlank(addrWrapper.mdmAddrId)) {
                            mdmAddrIds.add(addrWrapper.mdmAddrId);
                        }
                    }
                }
            }
        }

        if (!mdmIds.isEmpty()) {
            Map<String, Account> accsMap = new Map<String, Account>();
            Map<String, Address_vod__c> addrsMap = new Map<String, Address_vod__c>();
            Map<String, TSF_vod__c> tsfsMap = new Map<String, TSF_vod__c>();

            String terrName = getTerritoryName();
            List<Account> accs = getAccountsByMdmIds(mdmIds, mdmAddrIds, terrName != null ? new Set<String>{
                    terrName
            } : new Set<String>());

            for (Account acc : accs) {
                accsMap.put(acc.MDMID_gne__c.toUpperCase(), acc);
                for (Address_vod__c addr : acc.Address_vod__r) {
                    addrsMap.put(addr.MDM_Address_ID_gne__c.toUpperCase(), addr);
                }

                for (TSF_vod__c tsf : acc.TSF_vod__r) {
                    tsfsMap.put(acc.MDMID_gne__c.toUpperCase(), tsf);
                }
            }

            for (AccountWrapper accWrapper : results) {
                String mdmId = accWrapper.mdmId != null ? accWrapper.mdmId.toUpperCase() : null;
                accWrapper.fetchWithExistingRecord(accsMap.get(mdmId), tsfsMap.get(mdmId));

                if (isSbcAddressMode) {
                    List<Address_vod__c> hiddenAddresses = (new GNE_SFA2_UserPreference_Ctrl()).getHiddenAddresses(getUser().Id, accWrapper.id);

                    Set<String> hiddenAddrMdmIds = new Set<String>();
                    for (Address_vod__c addr : hiddenAddresses) {
                        if (String.isNotBlank(addr.MDM_Address_ID_gne__c)) {
                            hiddenAddrMdmIds.add(addr.MDM_Address_ID_gne__c);
                        }
                    }

                    Set<String> visitedAddrMdmIds = new Set<String>();

                    for (Integer i = accWrapper.addresses.size() - 1; i >= 0; i--) {
                        AddressWrapper addrWrapper = (AddressWrapper) accWrapper.addresses[i];

                        if (addrsMap.containsKey(addrWrapper.mdmAddrId) && !hiddenAddrMdmIds.contains(addrWrapper.mdmAddrId)) {
                            accWrapper.addresses.remove(i);
                        } else if (addrsMap.containsKey(addrWrapper.mdmAddrId)) {
                            visitedAddrMdmIds.add(addrWrapper.mdmAddrId);
                            addrWrapper.fetchWithExistingRecord(addrsMap.get(addrWrapper.mdmAddrId.toUpperCase()));
                        } else {
                            addrWrapper.fetchWhenNoExistingRecord();
                        }
                    }

                    for (Address_vod__c addr : hiddenAddresses) {
                        if (String.isBlank(addr.MDM_Address_ID_gne__c) || !visitedAddrMdmIds.contains(addr.MDM_Address_ID_gne__c)) {
                            new AddressWrapper(addr, accWrapper);
                        }
                    }
                } else {
                    for (Integer i = 0; i < accWrapper.addresses.size(); i++) {
                        AddressWrapper addrWrapper = (AddressWrapper) accWrapper.addresses[i];

                        if (addrsMap.containsKey(addrWrapper.mdmAddrId)) {
                            addrWrapper.fetchWithExistingRecord(addrsMap.get(addrWrapper.mdmAddrId.toUpperCase()));
                        } else {
                            addrWrapper.fetchWhenNoExistingRecord();
                        }
                    }
                }
            }
        }
    }

    private User getUser() {
        if (user == null) {
            user = String.isNotBlank(request.unixId) ? iPhone_DAO.getUserByExternalId(request.unixId) : new User(Id = UserInfo.getUserId());
        }

        return user;
    }

    private String getTerritoryName() {
        cacheTerritory();
        return cachedTerritory != null ? cachedTerritory.Name : null;
    }

    private Set<String> getTerritoryTeamCodes() {
        cacheTerritory();
        return cachedTerritory != null && String.isNotBlank(cachedTerritory.Salesforce_Code_gne__c) ? new Set<String>{
                cachedTerritory.Salesforce_Code_gne__c
        } : null;
    }

    private void cacheTerritory() {
        if (cachedTerritory == null && String.isNotBlank(request.tid)) {
            List<Territory2> terrs = [SELECT Id, Name, Salesforce_Code_gne__c FROM Territory2 WHERE Id = :request.tid LIMIT 1];

            for (Territory2 terr : terrs) {
                cachedTerritory = terr;
            }
        }
    }

    private List<Account> getAccountsByMdmIds(Set<String> mdmIds, Set<String> mdmAddrIds, Set<String> terrNames) {
        return [
                SELECT Id, MDMID_gne__c, iPhone_Request_Id_gne__c, IsPersonAccount, Stewardship_System_Name_gne__c, (
                        SELECT Id, MDM_Address_ID_gne__c, iPhone_Request_Id_gne__c,
                                Phone_vod__c, Phone_2_vod__c, Fax_vod__c, Fax_2_vod__c, PFG_BDTD_gne__c,
                                Location_gne__Latitude__s, Location_gne__Longitude__s, RecordType.DeveloperName
                        FROM Address_vod__r
                        WHERE MDM_Address_ID_gne__c IN :mdmAddrIds
                ), (
                        SELECT Id, Account_vod__c, Territory_vod__c, iPhone_Request_Id_gne__c
                        FROM TSF_vod__r
                        WHERE Territory_vod__c IN :terrNames
                )
                FROM Account
                WHERE MDMID_gne__c IN :mdmIds
        ];
    }

    global class SbcRequest implements iPhone_Commons_gne.BaseArgs, iPhoneBase.RequestTestable2 {
        public String unixId;
        public String searchMode;
        public String accountType;
        public SearchParams searchParams;
        public GNE_SFA2_SBC_DAO.PaginationDataWrapper paginationData;
        public List<String> teamCodes;
        public Integer pageSize;
        public Boolean searchMore;
        public String tid;

        public String getIPhoneRequestId() {
            return null;
        }

        public void testRequest() {
            new iPhone_SBC().build(this);
        }

        public System.Type getRequestType() {
            return SbcRequest.class;
        }

        private Boolean isSbcAddressMode() {
            return this.searchMode == GNE_SFA2_SBC_Config.SearchModes.MDMId.name();
        }
    }

    private class SearchParams {
        private String personName;
        private String organizationName;
        private String streetAddress;
        private String cityName;
        private String stateCode;
        private String zipCode;
        private String licenseNumber;
        private String MDMID;
        private String orgType;

        private Map<String, String> toMap() {
            return (Map<String, String>) JSON.deserialize(JSON.serialize(this), Map<String, String>.class);
        }
    }

    private class AccountWrapper extends GNE_SFA2_SBC_Ctrl.SearchAccountWrapper {
        private String tsfid;
        private Boolean isAMS;

        private AccountWrapper() {
        }

        private AccountWrapper(GNE_SFA2_SBC_DAO.AccountWrapper mdmAccWrapper) {
            super(mdmAccWrapper);
            this.name = String.isBlank(this.name) ? (this.firstName + ' ' + this.lastName) : this.name;
        }

        private void fetchWithExistingRecord(Account acc, TSF_vod__c tsf) {
            if (acc != null) {
                this.id = acc.Id;
                isAMS = iPhone_REST_Utils.isAMSAccount(acc);
            }

            if (tsf != null) {
                this.tsfid = tsf.Id;
            }


        }
    }

    private class AddressWrapper extends GNE_SFA2_SBC_Ctrl.SearchAddressWrapper {
        private String phone;
        private String phone2;
        private String fax;
        private String fax2;
        private String bestDays;
        private String isAddrCm; //isAddressCompanyMaintained

        public AddressWrapper(GNE_SFA2_SBC_DAO.AddressWrapper addr, GNE_SFA2_SBC_Ctrl.SearchAccountWrapper parent) {
            super(addr, parent);
            this.mapUrl = null;
        }

        public AddressWrapper(Address_vod__c addr, GNE_SFA2_SBC_Ctrl.SearchAccountWrapper parent) {
            super(addr, parent);
            this.fetchWithExistingRecord(addr);
            this.mapUrl = null;
        }

        private void fetchWithExistingRecord(Address_vod__c addr) {
            if (addr != null) {
                this.id = addr.Id;
                this.phone = addr.Phone_vod__c;
                this.phone2 = addr.Phone_2_vod__c;
                this.fax = addr.Fax_vod__c;
                this.fax2 = addr.Fax_2_vod__c;
                this.bestDays = addr.PFG_BDTD_gne__c;
                this.isAddrCm = iPhone_StringUtil.getString(GNE_SFA2_Address_Field_Updates.isRecordCompanyMaintained(addr.RecordType.DeveloperName));

                if ((this.latitude == null || this.longitude == null) && (addr.Location_gne__Latitude__s != null && addr.Location_gne__Longitude__s != null)) {
                    this.latitude = addr.Location_gne__Latitude__s;
                    this.longitude = addr.Location_gne__Longitude__s;
                }
            }
        }

        public void fetchWhenNoExistingRecord() {
            this.isAddrCm = iPhone_StringUtil.getString(String.isNotBlank(mdmAddrId));
        }
    }

    global class SbcResponse extends iPhone_Commons_gne.RestResponse {
        public List<AccountWrapper> results;
        public GNE_SFA2_SBC_DAO.PaginationDataWrapper paginationData;
    }
}