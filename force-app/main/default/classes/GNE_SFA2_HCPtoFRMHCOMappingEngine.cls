global without sharing class GNE_SFA2_HCPtoFRMHCOMappingEngine {

    private static final String ARCHIVED_RECORD_TYPE_NAME = 'Archived_Person_Account_gne';
    private static final String FRM_HCO_RECORD_TYPE_NAME = 'FRM_HCO';
    private static final String MDM_ACCOUNT_MODE = GNE_SFA2_SBC_Config.AccountModes.HCP.name().toLowerCase();
    private static final String MDM_SEARCH_MODE = 'MDMId';
    // Order here MUST be from most specific to more general i.e. RESPFRM -> PFRM
    private Set<String> teamCodes = new Set<String>{
            'AFRM', 'BFRM', 'EFRM', 'IFRM', 'NFRM', 'RESPFRM', 'PFRM', 'RFRM', 'RCM', 'NEURORD'
    };

    private Id etlAdminUserId;
    public List<ServiceRequest> serviceRequests;
    public Set<String> existingMappingExtIds;
    public Map<String, AccountWithAddress> existingAccountAndAddress;
    public List<HCP_To_FRM_HCO_Mapping_gne__c> tempMappingToUpsert;
    public Map<String, HCP_To_FRM_HCO_Mapping_gne__c> existingTempMapping;
    public Map<String, String> zipToTerr;
    public Boolean migrationMode;
    public static Boolean batchMode;

    public GNE_SFA2_HCPtoFRMHCOMappingEngine() {
        tempMappingToUpsert = new List<HCP_To_FRM_HCO_Mapping_gne__c>();
        migrationMode = false;
        String profileName = GNE_SFA2_Util.getCurrentUserProfileName();
        for (String tCode : teamCodes) {
            if (profileName.containsIgnoreCase(tCode) || (GNE_SFA2_Util.isCrmFRMUser() && tCode == 'NEURORD')) {
                teamCodes = new Set<String>{
                        tCode
                };
                break;
            }
        }
    }

    public GNE_SFA2_HCPtoFRMHCOMappingEngine(Boolean migMode) {
        tempMappingToUpsert = new List<HCP_To_FRM_HCO_Mapping_gne__c>();
        migrationMode = migMode;
    }

    public void init(List<Case__x> servRequests) {
        batchMode = true;
        etlAdminUserId = [SELECT Id FROM User WHERE Name = 'ETL Admin' LIMIT 1].Id;
        serviceRequests = prepareServiceRequestsToProceed(servRequests);
        existingAccountAndAddress = fetchExistingAccountAndAddress(getAccountRecords(serviceRequests));
        updateServiceRequestsOnAccountWithAddress();
        autoMapping();
        upsertTempMapping();
    }

    public void init(List<Case> servRequests) {
        batchMode = true;
        serviceRequests = prepareServiceRequestsToProceed(servRequests);
        autoMapping();
        upsertTempMapping();
    }

    private List<ServiceRequest> prepareServiceRequestsToProceed(List<Case__x> servRequests) {
        List<ServiceRequest> result = new List<ServiceRequest>();
        Map<String, ServiceRequest> pactServiceRequests = new Map<String, ServiceRequest>();
        Set<String> accExtIds = new Set<String>();
        Set<String> accMDMIds = new Set<String>();
        Set<String> addrExtIds = new Set<String>();
        Set<String> addrMDMIds = new Set<String>();
        Map<String, String> accWithAddrNames = new Map<String, String>();
        Set<String> addrFullNames = new Set<String>();
        for (Case__x sr : servRequests) {
            if (String.isNotBlank(sr.Products_List__c)) {
                String extId = buildUniqueKeyInsensitive(sr.HCP_PACT_ID__c, sr.HCP_Address_PACT_ID__c);
                if (!pactServiceRequests.containsKey(extId)) {
                    pactServiceRequests.put(extId, new ServiceRequest(sr));
                } else if (String.isNotBlank(sr.Products_List__c)) {
                    pactServiceRequests.get(extId).mergeProducts(sr.Products_List__c.split(';'));
                }
                accExtIds.add(sr.HCP_PACT_ID__c);
                accMDMIds.add(sr.HCP_MDM_ID__c);
                addrExtIds.add(sr.HCP_Address_PACT_ID__c);
                addrMDMIds.add(sr.HCP_Address_MDM_ID__c);
                accWithAddrNames.put(buildUniqueKey(pactServiceRequests.get(extId).prescriber.getName(), pactServiceRequests.get(extId).address.getFullAddressName()), (sr.HCP_PACT_ID__c + '_' + sr.HCP_Address_PACT_ID__c));
            }
        }

        existingMappingExtIds = checkExistingMapping(accExtIds, accMDMIds, addrExtIds, addrMDMIds, accWithAddrNames);
        existingTempMapping = checkExistingTempMapping(accExtIds, addrExtIds, accWithAddrNames);

        for (String extId : pactServiceRequests.keySet()) {
            if (existingTempMapping.containsKey(extId)) {
                String srProducts = pactServiceRequests.get(extId).prescriber.products;
                HCP_To_FRM_HCO_Mapping_gne__c tempMapping = existingTempMapping.get(extId);
                String tempMappingProducts = tempMapping.Products_gne__c != null ? tempMapping.Products_gne__c : '';
                if (String.isNotBlank(srProducts)) {
                    List<String> products = srProducts.split(';');
                    for (String p : products) {
                        if (!tempMappingProducts.containsIgnoreCase(p)) {
                            tempMappingProducts += String.isNotBlank(tempMappingProducts) ? (';' + p) : p;
                        }
                    }

                    if (tempMapping.Products_gne__c != tempMappingProducts) {
                        tempMapping.Products_gne__c = String.join(new List<String>(new Set<String>(tempMappingProducts.split(';'))), ';');
                        tempMappingToUpsert.add(tempMapping);
                    }
                }
            } else {
                result.add(pactServiceRequests.get(extId));
            }
        }

        return result;
    }

    private List<ServiceRequest> prepareServiceRequestsToProceed(List<Case> servRequests) {
        List<ServiceRequest> result = new List<ServiceRequest>();
        Map<String, ServiceRequest> pactServiceRequests = new Map<String, ServiceRequest>();
        Set<String> accIds = new Set<String>();
        Set<String> addrIds = new Set<String>();
        for (Case sr : servRequests) {
            if (String.isNotBlank(sr.Product_gne__c)) {
                if (sr.Case_Treating_Physician_gne__c == sr.Address_gne__r.Account_vod__c) {
                    String extId = buildUniqueKeyInsensitive(sr.Case_Treating_Physician_gne__c, sr.Address_gne__c);
                    if (!pactServiceRequests.containsKey(extId)) {
                        pactServiceRequests.put(extId, new ServiceRequest(sr));
                    } else if (String.isNotBlank(sr.Product_gne__c)) {
                        pactServiceRequests.get(extId).mergeProducts(sr.Product_gne__c.split(';'));
                    }
                    accIds.add(sr.Case_Treating_Physician_gne__c);
                    addrIds.add(sr.Address_gne__c);
                }
            }
        }

        existingMappingExtIds = checkExistingMapping(accIds, addrIds);
        existingTempMapping = checkExistingTempMapping(accIds, addrIds, new Map<String, String>());

        for (String extId : pactServiceRequests.keySet()) {
            if (!existingMappingExtIds.contains(extId) && !existingTempMapping.containsKey(extId)) {
                result.add(pactServiceRequests.get(extId));
            } else if (existingTempMapping.containsKey(extId)) {
                String srProducts = pactServiceRequests.get(extId).prescriber.products;
                HCP_To_FRM_HCO_Mapping_gne__c tempMapping = existingTempMapping.get(extId);
                String tempMappingProducts = tempMapping.Products_gne__c;
                if (String.isNotBlank(srProducts)) {
                    List<String> products = srProducts.split(';');
                    for (String p : products) {
                        if (!tempMappingProducts.containsIgnoreCase(p)) {
                            tempMappingProducts += String.isNotBlank(tempMappingProducts) ? (';' + p) : p;
                        }
                    }

                    if (tempMapping.Products_gne__c != tempMappingProducts) {
                        tempMapping.Products_gne__c = tempMappingProducts;
                        tempMappingToUpsert.add(tempMapping);
                    }
                }
            }
        }

        return result;
    }

    private Set<String> checkExistingMapping(Set<String> accExtIds, Set<String> accMDMIds, Set<String> addrExtIds, Set<String> addrMDMIds, Map<String, String> accWithAddrNames) {
        Set<String> result = new Set<String>();
        List<FRM_HCO_Mapping_gne__c> mappingToUpdate = new List<FRM_HCO_Mapping_gne__c>();
        Set<String> accNames = new Set<String>();
        Set<String> addrNames = new Set<String>();
        for (String key : accWithAddrNames.keySet()) {
            List<String> names = key.split('_');
            accNames.add(names.get(0));
            addrNames.add(names.get(1));
        }

        for (FRM_HCO_Mapping_gne__c fhm : [SELECT HCP_Account_gne__r.Name, HCP_Address_Full_Name_gne__c, PACT_Prescriber_Id_gne__c, PACT_Prescriber_Address_Id_gne__c, HCP_Account_gne__r.MDMID_gne__c, HCP_Address_gne__r.MDM_Address_Id_gne__c FROM FRM_HCO_Mapping_gne__c WHERE (PACT_Prescriber_Id_gne__c IN :accExtIds AND PACT_Prescriber_Address_Id_gne__c IN :addrExtIds) OR (HCP_Account_gne__r.Name IN :accNames AND HCP_Address_Full_Name_gne__c IN :addrNames) OR (HCP_Account_gne__r.MDMID_gne__c IN :accMDMIds AND HCP_Address_gne__r.MDM_Address_Id_gne__c IN :addrMDMIds)]) {
            if (String.isNotBlank(fhm.PACT_Prescriber_Id_gne__c) && String.isNotBlank(fhm.PACT_Prescriber_Address_Id_gne__c)) {
                result.add(buildUniqueKeyInsensitive(fhm.PACT_Prescriber_Id_gne__c, fhm.PACT_Prescriber_Address_Id_gne__c));
            } else if (String.isNotBlank(fhm.HCP_Account_gne__r.MDMID_gne__c) && String.isNotBlank(fhm.HCP_Address_gne__r.MDM_Address_Id_gne__c)) {
                result.add(buildUniqueKeyInsensitive(fhm.HCP_Account_gne__r.MDMID_gne__c, fhm.HCP_Address_gne__r.MDM_Address_Id_gne__c));
            } else {
                String uniqueKey = buildUniqueKey(fhm.HCP_Account_gne__r.Name, fhm.HCP_Address_Full_Name_gne__c);
                if (accWithAddrNames.containsKey(uniqueKey)) {
                    result.add(accWithAddrNames.get(uniqueKey).toLowerCase());
                    List<String> extIds = accWithAddrNames.get(uniqueKey).split('_');
                    fhm.PACT_Prescriber_Id_gne__c = extIds.get(0);
                    fhm.PACT_Prescriber_Address_Id_gne__c = extIds.get(1);
                }
            }

            // Update PACT Acct and Addr reference Ids or do empty update to raise last modified date for PACT consumption
            mappingToUpdate.add(fhm);
        }

        if (!mappingToUpdate.isEmpty()) {
            update mappingToUpdate;
        }

        return result;
    }

    private Set<String> checkExistingMapping(Set<String> accIds, Set<String> addrIds) {
        Set<String> result = new Set<String>();

        for (FRM_HCO_Mapping_gne__c fhm : [SELECT HCP_Account_gne__c, HCP_Address_gne__c FROM FRM_HCO_Mapping_gne__c WHERE HCP_Account_gne__c IN :accIds AND HCP_Address_gne__c IN :addrIds]) {
            if (String.isNotBlank(fhm.HCP_Account_gne__c) && String.isNotBlank(fhm.HCP_Address_gne__c)) {
                result.add(buildUniqueKeyInsensitive(fhm.HCP_Account_gne__c, fhm.HCP_Address_gne__c));
            }
        }

        return result;
    }

    private Map<String, HCP_To_FRM_HCO_Mapping_gne__c> checkExistingTempMapping(Set<String> accIds, Set<String> addrIds, Map<String, String> accWithAddrNames) {
        Map<String, HCP_To_FRM_HCO_Mapping_gne__c> result = new Map<String, HCP_To_FRM_HCO_Mapping_gne__c>();
        if (!migrationMode) {
            List<HCP_To_FRM_HCO_Mapping_gne__c> tempMappToUpdt = new List<HCP_To_FRM_HCO_Mapping_gne__c>();
            Set<String> accNames = new Set<String>();
            Set<String> addrNames = new Set<String>();
            for (String key : accWithAddrNames.keySet()) {
                List<String> names = key.split('_');
                accNames.add(names.get(0));
                addrNames.add(names.get(1));
            }
            for (HCP_To_FRM_HCO_Mapping_gne__c htfhm : [SELECT Id, Products_gne__c, HCP_Account_gne__r.Name, HCP_Address_Full_Name_gne__c, PACT_Prescriber_Id_gne__c, PACT_Prescriber_Address_Id_gne__c, IsHidden_gne__c FROM HCP_To_FRM_HCO_Mapping_gne__c WHERE ((PACT_Prescriber_Id_gne__c IN :accIds AND PACT_Prescriber_Address_Id_gne__c IN :addrIds) OR (HCP_Account_gne__r.Name IN :accNames AND HCP_Address_Full_Name_gne__c IN :addrNames))]) {
                if (String.isNotBlank(htfhm.PACT_Prescriber_Id_gne__c) && String.isNotBlank(htfhm.PACT_Prescriber_Address_Id_gne__c)) {
                    result.put(buildUniqueKeyInsensitive(htfhm.PACT_Prescriber_Id_gne__c, htfhm.PACT_Prescriber_Address_Id_gne__c), htfhm);
                } else {
                    String uniqueKey = buildUniqueKey(htfhm.HCP_Account_gne__r.Name, htfhm.HCP_Address_Full_Name_gne__c);
                    if (accWithAddrNames.containsKey(uniqueKey)) {
                        result.put(buildUniqueKeyInsensitive(htfhm.PACT_Prescriber_Id_gne__c, htfhm.PACT_Prescriber_Address_Id_gne__c), htfhm);
                        List<String> extIds = accWithAddrNames.get(uniqueKey).split('_');
                        htfhm.PACT_Prescriber_Id_gne__c = extIds.get(0);
                        htfhm.PACT_Prescriber_Address_Id_gne__c = extIds.get(1);
                        tempMappToUpdt.add(htfhm);
                    }
                }
                htfhm.IsHidden_gne__c = false;
            }

            if (!tempMappToUpdt.isEmpty()) {
                update tempMappToUpdt;
            }
        } else {
            for (HCP_To_FRM_HCO_Mapping_gne__c htfhm : [SELECT Id, Products_gne__c, HCP_Account_gne__c, HCP_Address_gne__c FROM HCP_To_FRM_HCO_Mapping_gne__c WHERE HCP_Account_gne__c IN :accIds AND HCP_Address_gne__c IN :addrIds]) {
                result.put(buildUniqueKeyInsensitive(htfhm.HCP_Account_gne__c, htfhm.HCP_Address_gne__c), htfhm);
            }
        }

        return result;
    }

    private Account getAccountRecord(String accMDMId, String accExtId, String addrMDMId, String addrExtId) {
        List<Account> accRecs = getAccountRecords(new Set<String>{
                accMDMId
        }, new Set<String>{
                accExtId
        }, new Set<String>{
                addrMDMId
        }, new Set<String>{
                addrExtId
        }, null, null, null, null, null, null, null, null, true, true);
        return !accRecs.isEmpty() ? accRecs.get(0) : null;
    }

    private List<Account> getAccountRecords(List<ServiceRequest> servRequests) {
        Set<String> accMDMIds = new Set<String>();
        Set<String> accExtIds = new Set<String>();
        Set<String> addrMDMIds = new Set<String>();
        Set<String> addrExtIds = new Set<String>();
        Set<String> accNames = new Set<String>();
        Set<String> addrStreets = new Set<String>();
        Set<String> addrSuitesFloorsUnits = new Set<String>();
        Set<String> addrCities = new Set<String>();
        Set<String> addrStates = new Set<String>();
        Set<String> addrZipCodes = new Set<String>();

        for (ServiceRequest sr : servRequests) {
            if (String.isNotBlank(sr.prescriber.mdmId)) {
                accMDMIds.add(sr.prescriber.mdmId);
            }

            if (String.isNotBlank(sr.prescriber.extId)) {
                accExtIds.add(sr.prescriber.extId);
            }

            if (String.isNotBlank(sr.address.mdmId)) {
                addrMDMIds.add(sr.address.mdmId);
            }

            if (String.isNotBlank(sr.address.extId)) {
                addrExtIds.add(sr.address.extId);
            }

            if (String.isNotBlank(sr.prescriber.getName())) {
                accNames.add(sr.prescriber.getName());
            }

            if (String.isNotBlank(sr.address.street)) {
                addrStreets.add(sr.address.street);
            }

            if (String.isNotBlank(sr.address.suiteFloorUnit)) {
                addrSuitesFloorsUnits.add(sr.address.suiteFloorUnit);
            }

            if (String.isNotBlank(sr.address.city)) {
                addrCities.add(sr.address.city);
            }

            if (String.isNotBlank(sr.address.state)) {
                addrStates.add(sr.address.state);
            }

            if (String.isNotBlank(sr.address.zip)) {
                addrZipCodes.add(sr.address.zip);
            }
        }

        return getAccountRecords(accMDMIds, accExtIds, addrMDMIds, addrExtIds, accNames, addrStreets, addrSuitesFloorsUnits, addrCities, addrStates, addrZipCodes, null, null, false, false);
    }

    /**
     * Get Account Address
     * @param  accMDMIds             Set of Account MDM Ids
     * @param  accExtIds             Set of Account Ids From External Sources
     * @param  addrMDMIds            Set of Address MDM Ids
     * @param  addrExtIds            Set of Address Ids From External Sources
     * @param  accNames              Set of Account Names
     * @param  addrStreets           Set of Address Streets
     * @param  addrSuitesFloorsUnits Set of Address Suites/Floors/Units
     * @param  addrCities            Set of Address Cities
     * @param  addrStates            Set of Address States
     * @param  addrZipCodes          Set of Address Zip Codes
     * @param  accfieldNames         Set of Additional Account Fields to retrieve
     * @param  addrFieldNames        Set of Additional Address Fields to retrieve
     * @param  isAccSingleMode       Set of Account Single Mode
     * @param  isAddrSingleMode      Set of Address Single Mode
     * @return                       List of Accounts
     */
    private List<Account> getAccountRecords(Set<String> accMDMIds, Set<String> accExtIds, Set<String> addrMDMIds, Set<String> addrExtIds, Set<String> accNames, Set<String> addrStreets, Set<String> addrSuitesFloorsUnits, Set<String> addrCities, Set<String> addrStates, Set<String> addrZipCodes, Set<String> accfieldNames, Set<String> addrFieldNames, Boolean isAccSingleMode, Boolean isAddrSingleMode) {
        Set<String> accFields = new Set<String>{
                String.valueOf(Account.Id).toLowerCase(),
                String.valueOf(Account.MDMID_gne__c).toLowerCase(),
                String.valueOf(Account.PACT_Id__c).toLowerCase(),
                String.valueOf(Account.Name).toLowerCase(),
                String.valueOf(Account.FirstName).toLowerCase(),
                String.valueOf(Account.LastName).toLowerCase()
        };

        for (String fldName : (accfieldNames != null ? accfieldNames : new Set<String>())) {
            accFields.add(fldName.toLowerCase());
        }

        Set<String> addrFields = new Set<String>{
                String.valueOf(Address_vod__c.Id).toLowerCase(),
                String.valueOf(Address_vod__c.MDM_Address_Id_gne__c).toLowerCase(),
                String.valueOf(Address_vod__c.PACT_Id__c).toLowerCase(),
                String.valueOf(Address_vod__c.Name).toLowerCase(),
                String.valueOf(Address_vod__c.Address_Line_2_vod__c).toLowerCase(),
                String.valueOf(Address_vod__c.City_vod__c).toLowerCase(),
                String.valueOf(Address_vod__c.State_vod__c).toLowerCase(),
                String.valueOf(Address_vod__c.Zip_vod__c).toLowerCase(),
                String.valueOf(Address_vod__c.Location_gne__Latitude__s).toLowerCase(),
                String.valueOf(Address_vod__c.Location_gne__Longitude__s).toLowerCase(),
                String.valueOf(Address_vod__c.Force_Location_Update_gne__c).toLowerCase()
        };

        for (String fldName : (addrFieldNames != null ? addrFieldNames : new Set<String>())) {
            addrFields.add(fldName.toLowerCase());
        }

        List<String> accWhereStatements = new List<String>();
        List<String> addrWhereStatements = new List<String>();

        if (accMDMIds != null && !accMDMIds.isEmpty()) {
            accWhereStatements.add('MDMID_gne__c IN :accMDMIds');
        }

        if (accNames != null && !accNames.isEmpty()) {
            accWhereStatements.add('Name IN :accNames');
        }

        if (accExtIds != null && !accExtIds.isEmpty()) {
            accWhereStatements.add('PACT_Id__c IN :accExtIds');
        }

        if (addrMDMIds != null && !addrMDMIds.isEmpty()) {
            addrWhereStatements.add('MDM_Address_Id_gne__c IN :addrMDMIds');
        }

        if (addrExtIds != null && !addrExtIds.isEmpty()) {
            addrWhereStatements.add('PACT_Id__c IN :addrExtIds');
        }

        if (addrStreets != null && !addrStreets.isEmpty()) {
            addrWhereStatements.add('Name IN :addrStreets');
        }

        if (addrSuitesFloorsUnits != null && !addrSuitesFloorsUnits.isEmpty()) {
            addrWhereStatements.add('Address_Line_2_vod__c IN :addrSuitesFloorsUnits');
        }

        if (addrCities != null && !addrCities.isEmpty()) {
            addrWhereStatements.add('City_vod__c IN :addrCities');
        }

        if (addrStates != null && !addrStates.isEmpty()) {
            addrWhereStatements.add('State_vod__c IN :addrStates');
        }

        if (addrZipCodes != null && !addrZipCodes.isEmpty()) {
            addrWhereStatements.add('Zip_vod__c IN :addrZipCodes');
        }

        isAccSingleMode = isAccSingleMode != null ? isAccSingleMode : ((accMDMIds != null && accMDMIds.size() == 1) || (accExtIds != null && accExtIds.size() == 1));

        return !accWhereStatements.isEmpty() ? Database.query(String.format(
                'SELECT {0}, (SELECT {1} FROM Address_vod__r{4}) FROM Account WHERE RecordType.DeveloperName != :ARCHIVED_RECORD_TYPE_NAME AND IsPersonAccount = true AND ({2}) ORDER BY LastName, FirstName{3}', new String[]{
                        String.join(new List<String>(accFields), ','),
                        String.join(new List<String>(addrFields), ','),
                        String.join(accWhereStatements, ' OR '),
                        isAccSingleMode ? ' LIMIT 1' : '',
                        !addrWhereStatements.isEmpty() ? (' WHERE ' + String.join(addrWhereStatements, ' OR ')) : '',
                        isAddrSingleMode ? ' LIMIT 1' : ''
                })) : new List<Account>();
    }

    private Map<String, AccountWithAddress> fetchExistingAccountAndAddress(List<Account> existingAccountAndAddress) {
        Map<String, AccountWithAddress> result = new Map<String, AccountWithAddress>();
        for (Account acc : existingAccountAndAddress) {
            if (!acc.Address_vod__r.isEmpty()) {
                for (Address_vod__c addr : acc.Address_vod__r) {

                    String fullAddressName = prepareFullAddressName(addr);

                    // Put AccMDMId + AddrMDMId Key
                    if (String.isNotBlank(acc.MDMID_gne__c) && String.isNotBlank(addr.MDM_Address_Id_gne__c)) {
                        result.put(buildUniqueKeyInsensitive(acc.MDMID_gne__c, addr.MDM_Address_Id_gne__c), new AccountWithAddress(acc, addr));
                    }

                    // Put AccPACTId + AddrPACTId Key
                    if (String.isNotBlank(acc.PACT_Id__c) && String.isNotBlank(addr.PACT_Id__c)) {
                        result.put(buildUniqueKeyInsensitive(acc.PACT_Id__c, addr.PACT_Id__c), new AccountWithAddress(acc, addr));
                    }

                    // Put AccMDMId + AddrFullName Key
                    if (String.isNotBlank(acc.MDMID_gne__c) && String.isNotBlank(fullAddressName)) {
                        result.put(buildUniqueKey(acc.MDMID_gne__c, fullAddressName), new AccountWithAddress(acc, addr));
                    }

                    // Put AccName + AddrFullName Key
                    if (String.isNotBlank(acc.Name) && String.isNotBlank(fullAddressName)) {
                        result.put(buildUniqueKey(acc.Name, fullAddressName), new AccountWithAddress(acc, addr));
                    }
                }
            }

            if (String.isNotBlank(acc.MDMID_gne__c)) {
                result.put(acc.MDMID_gne__c, new AccountWithAddress(acc));
            }

            result.put(acc.Name.toLowerCase(), new AccountWithAddress(acc));
        }

        return result;
    }

    private String prepareFullAddressName(Address_vod__c addr) {
        String result = '';

        if (String.isNotBlank(addr.Address_Line_2_vod__c)) {
            result += addr.Address_Line_2_vod__c;
        }

        if (String.isNotBlank(addr.Name)) {
            result += String.isNotBlank(result) ? (' ' + addr.Name) : addr.Name;
        }

        if (String.isNotBlank(addr.City_vod__c)) {
            result += String.isNotBlank(result) ? (' ' + addr.City_vod__c) : addr.City_vod__c;
        }

        if (String.isNotBlank(addr.State_vod__c)) {
            result += String.isNotBlank(result) ? (' ' + addr.State_vod__c) : addr.State_vod__c;
        }

        if (String.isNotBlank(addr.Zip_vod__c)) {
            result += String.isNotBlank(result) ? (' ' + addr.Zip_vod__c) : addr.Zip_vod__c;
        }

        return result;
    }

    private void updateServiceRequestsOnAccountWithAddress() {
        Map<String, Account> accountsToInsert = new Map<String, Account>();
        Map<String, List<Address_vod__c>> addressesToInsert = new Map<String, List<Address_vod__c>>();
        Map<String, Address_vod__c> insertedAddresses = new Map<String, Address_vod__c>();
        Map<Id, Account> acctToUpdateOfPactIdMap = new Map<Id, Account>();
        Map<Id, Address_vod__c> addrToUpdateMap = new Map<Id, Address_vod__c>();

        for (ServiceRequest sr : serviceRequests) {
            System.debug('#0 sr.Id: ' + sr.Id);
            // AccMDMId + AddrMDMId Key
            if (String.isNotBlank(sr.prescriber.mdmId) && String.isNotBlank(sr.address.mdmId)) {
                String extId = buildUniqueKeyInsensitive(sr.prescriber.mdmId, sr.address.mdmId);
                if (existingAccountAndAddress.containsKey(extId)) {
                    AccountWithAddress accWithAddr = existingAccountAndAddress.get(extId);
                    sr.hcpAccount = accWithAddr.account;
                    sr.hcpAddress = accWithAddr.address;

                    String sr_fullAddr_Name = sr.address.getFullAddressName().toLowerCase();
                    String sfdc_fullAddr_Name = getFullAddrName(sr.hcpAddress).toLowerCase();

                    if (sr_fullAddr_Name != sfdc_fullAddr_Name) {
                        System.debug('#1 sr.hcpAddress.Id: ' + sr.hcpAddress.Id);
                        addrToUpdateMap.put(sr.hcpAddress.Id, new Address_vod__c(Id = sr.hcpAddress.Id, PACT_Id__c = sr.address.extId));
                    } else if (String.isBlank(sr.hcpAddress.PACT_Id__c)) {
                        System.debug('#2 sr.hcpAddress.Id: ' + sr.hcpAddress.Id);
                        addrToUpdateMap.put(sr.hcpAddress.Id, new Address_vod__c(Id = sr.hcpAddress.Id, PACT_Id__c = sr.address.extId));
                    }

                    if (String.isBlank(sr.hcpAccount.PACT_Id__c)) {
                        System.debug('#3 sr.hcpAccount.Id: ' + sr.hcpAccount.Id);
                        acctToUpdateOfPactIdMap.put(sr.hcpAccount.Id, new Account(Id = sr.hcpAccount.Id, PACT_Id__c = sr.prescriber.extId));
                    }
                    continue;
                }
            }

            // AccPACTId + AddrPACTId Key
            if (String.isNotBlank(sr.prescriber.extId) && String.isNotBlank(sr.address.extId)) {
                String extId = buildUniqueKeyInsensitive(sr.prescriber.extId, sr.address.extId);
                if (existingAccountAndAddress.containsKey(extId)) {
                    AccountWithAddress accWithAddr = existingAccountAndAddress.get(extId);
                    sr.hcpAccount = accWithAddr.account;
                    sr.hcpAddress = accWithAddr.address;

                    String sr_fullAddr_Name = sr.address.getFullAddressName().toLowerCase();
                    String sfdc_fullAddr_Name = getFullAddrName(sr.hcpAddress).toLowerCase();

                    if (sr_fullAddr_Name != sfdc_fullAddr_Name) {
                        System.debug('#5 sr.hcpAddress.Id: ' + sr.hcpAddress.Id);
                        addrToUpdateMap.put(sr.hcpAddress.Id, new Address_vod__c(Id = sr.hcpAddress.Id, PACT_Id__c = sr.address.extId));
                    } else if (String.isBlank(sr.hcpAddress.PACT_Id__c)) {
                        System.debug('#6 sr.hcpAddress.Id: ' + sr.hcpAddress.Id);
                        addrToUpdateMap.put(sr.hcpAddress.Id, new Address_vod__c(Id = sr.hcpAddress.Id, PACT_Id__c = sr.address.extId));
                    }

                    if (String.isBlank(sr.hcpAccount.PACT_Id__c)) {
                        System.debug('#7 sr.hcpAccount.Id: ' + sr.hcpAccount.Id);
                        acctToUpdateOfPactIdMap.put(sr.hcpAccount.Id, new Account(Id = sr.hcpAccount.Id, PACT_Id__c = sr.prescriber.extId));
                    }
                    continue;
                }
            }

            // AccMDMId + AddrFullName Key
            if (String.isNotBlank(sr.prescriber.mdmId) && String.isNotBlank(sr.address.getFullAddressName())) {
                String extId = buildUniqueKey(sr.prescriber.mdmId, sr.address.getFullAddressName());
                if (existingAccountAndAddress.containsKey(extId)) {
                    AccountWithAddress accWithAddr = existingAccountAndAddress.get(extId);
                    sr.hcpAccount = accWithAddr.account;
                    sr.hcpAddress = accWithAddr.address;

                    if (String.isBlank(sr.hcpAccount.PACT_Id__c)) {
                        System.debug('#9 sr.hcpAccount.Id: ' + sr.hcpAccount.Id);
                        acctToUpdateOfPactIdMap.put(sr.hcpAccount.Id, new Account(Id = sr.hcpAccount.Id, PACT_Id__c = sr.prescriber.extId));
                    }

                    if (String.isBlank(sr.hcpAddress.PACT_Id__c)) {
                        System.debug('#10 sr.hcpAddress.Id: ' + sr.hcpAddress.Id);
                        addrToUpdateMap.put(sr.hcpAddress.Id, new Address_vod__c(Id = sr.hcpAddress.Id, PACT_Id__c = sr.address.extId));
                    }
                    continue;
                }

            }

            // AccName + AddrFullName Key
            if (String.isNotBlank(sr.prescriber.getName()) && String.isNotBlank(sr.address.getFullAddressName())) {
                String extId = buildUniqueKey(sr.prescriber.getName(), sr.address.getFullAddressName());
                if (existingAccountAndAddress.containsKey(extId)) {
                    AccountWithAddress accWithAddr = existingAccountAndAddress.get(extId);
                    sr.hcpAccount = accWithAddr.account;
                    sr.hcpAddress = accWithAddr.address;

                    if (String.isBlank(sr.hcpAccount.PACT_Id__c)) {
                        System.debug('#12 sr.hcpAccount.Id: ' + sr.hcpAccount.Id);
                        acctToUpdateOfPactIdMap.put(sr.hcpAccount.Id, new Account(Id = sr.hcpAccount.Id, PACT_Id__c = sr.prescriber.extId));
                    }

                    if (String.isBlank(sr.hcpAddress.PACT_Id__c)) {
                        System.debug('#13 sr.hcpAddress.Id: ' + sr.hcpAddress.Id);
                        addrToUpdateMap.put(sr.hcpAddress.Id, new Address_vod__c(Id = sr.hcpAddress.Id, PACT_Id__c = sr.address.extId));
                    }
                    continue;
                }
            }

            // AccMDMId Key
            if (String.isNotBlank(sr.prescriber.mdmId)) {
                if (existingAccountAndAddress.containsKey(sr.prescriber.mdmId)) {
                    AccountWithAddress accWithAddr = existingAccountAndAddress.get(sr.prescriber.mdmId);
                    sr.hcpAccount = accWithAddr.account;

                    if (String.isBlank(sr.hcpAccount.PACT_Id__c)) {
                        System.debug('#15 sr.hcpAccount.Id: ' + sr.hcpAccount.Id);
                        acctToUpdateOfPactIdMap.put(sr.hcpAccount.Id, new Account(Id = sr.hcpAccount.Id, PACT_Id__c = sr.prescriber.extId));
                    }

                    if (!addressesToInsert.containsKey(sr.prescriber.extId)) {
                        System.debug('#16 sr.prescriber.extId: ' + sr.prescriber.extId);
                        addressesToInsert.put(sr.prescriber.extId, new List<Address_vod__c>{
                                createAddress(sr.address, accWithAddr.account.Id)
                        });
                    } else {
                        System.debug('#17 sr.prescriber.extId: ' + sr.prescriber.extId);
                        addressesToInsert.get(sr.prescriber.extId).add(createAddress(sr.address, accWithAddr.account.Id));
                    }
                    continue;
                }
            }

            // AccName Key
            if (String.isNotBlank(sr.prescriber.getName())) {
                if (existingAccountAndAddress.containsKey(sr.prescriber.getName().toLowerCase())) {
                    AccountWithAddress accWithAddr = existingAccountAndAddress.get(sr.prescriber.getName().toLowerCase());
                    sr.hcpAccount = accWithAddr.account;

                    if (String.isBlank(sr.hcpAccount.PACT_Id__c)) {
                        System.debug('#18 sr.hcpAccount.Id: ' + sr.hcpAccount.Id);
                        acctToUpdateOfPactIdMap.put(sr.hcpAccount.Id, new Account(Id = sr.hcpAccount.Id, PACT_Id__c = sr.prescriber.extId));
                    }

                    if (!addressesToInsert.containsKey(sr.prescriber.extId)) {
                        System.debug('#19 sr.prescriber.extId: ' + sr.prescriber.extId);
                        addressesToInsert.put(sr.prescriber.extId, new List<Address_vod__c>{
                                createAddress(sr.address, accWithAddr.account.Id)
                        });
                    } else {
                        System.debug('#20 sr.prescriber.extId: ' + sr.prescriber.extId);
                        addressesToInsert.get(sr.prescriber.extId).add(createAddress(sr.address, accWithAddr.account.Id));
                    }
                    continue;
                }
            }

            if (String.isNotBlank(sr.prescriber.mdmId) && sr.prescriber.mdmId.isNumeric()) {
                try {
                    retrieveAccountAndAddressFromMDM(sr.prescriber.mdmId, sr, accountsToInsert, addressesToInsert);
                } catch (Exception ex) {
                    if (!accountsToInsert.containsKey(sr.prescriber.extId)) {
                        System.debug('#21 sr.prescriber.extId: ' + sr.prescriber.extId);
                        accountsToInsert.put(sr.prescriber.extId, createAccount(sr.prescriber));
                    }

                    if (!addressesToInsert.containsKey(sr.prescriber.extId)) {
                        System.debug('#22 sr.prescriber.extId: ' + sr.prescriber.extId);
                        addressesToInsert.put(sr.prescriber.extId, new List<Address_vod__c>{
                                createAddress(sr.address)
                        });
                    } else {
                        System.debug('#23 sr.prescriber.extId: ' + sr.prescriber.extId);
                        addressesToInsert.get(sr.prescriber.extId).add(createAddress(sr.address));
                    }
                }
            } else {
                if (!accountsToInsert.containsKey(sr.prescriber.extId)) {
                    System.debug('#24 sr.prescriber.extId: ' + sr.prescriber.extId);
                    accountsToInsert.put(sr.prescriber.extId, createAccount(sr.prescriber));
                }

                if (!addressesToInsert.containsKey(sr.prescriber.extId)) {
                    System.debug('#25 sr.prescriber.extId: ' + sr.prescriber.extId);
                    addressesToInsert.put(sr.prescriber.extId, new List<Address_vod__c>{
                            createAddress(sr.address)
                    });
                } else {
                    System.debug('#26 sr.prescriber.extId: ' + sr.prescriber.extId);
                    addressesToInsert.get(sr.prescriber.extId).add(createAddress(sr.address));
                }
            }
        }

        if (!accountsToInsert.isEmpty()) {
            insert accountsToInsert.values();
        }

        if (!addressesToInsert.isEmpty()) {
            List<Address_vod__c> addrToIns = new List<Address_vod__c>();
            for (String key : addressesToInsert.keySet()) {
                for (Address_vod__c addr : addressesToInsert.get(key)) {
                    if (!String.isNotBlank(addr.Account_vod__c)) {
                        addr.Account_vod__c = accountsToInsert.get(key).Id;
                        addr.Primary_vod__c = true;
                    }
                    addrToIns.add(addr);
                }
            }

            insert addrToIns;

            for (Address_vod__c addr : addrToIns) {
                insertedAddresses.put(addr.PACT_Id__c, addr);
            }

        }

        if (!acctToUpdateOfPactIdMap.values().isEmpty()) {
            update acctToUpdateOfPactIdMap.values();
        }

        if (!addrToUpdateMap.values().isEmpty()) {
            update addrToUpdateMap.values();
        }

        for (ServiceRequest sr : serviceRequests) {
            if (accountsToInsert.containsKey(sr.prescriber.extId)) {
                sr.hcpAccount = accountsToInsert.get(sr.prescriber.extId);
            }

            if (insertedAddresses.containsKey(sr.address.extId)) {
                sr.hcpAddress = insertedAddresses.get(sr.address.extId);
            }
        }
    }

    private void autoMapping() {
        List<FRM_HCO_Mapping_gne__c> mappingToInsert = new List<FRM_HCO_Mapping_gne__c>();

        Set<String> zipCodes = new Set<String>();
        for (ServiceRequest sr : serviceRequests) {
            zipCodes.add(sr.address.zip);
        }

        Map<String, Map<String, List<Address_vod__c>>> coordinatesWithFRMHCOsMap = new Map<String, Map<String, List<Address_vod__c>>>();
        Map<String, List<Id>> fullAddressNamesWithFRMHCOsMap = new Map<String, List<Id>>();
        Map<String, List<Id>> fullAddressNamesWithoutCityWithFRMHCOsMap = new Map<String, List<Id>>();

        Id frmHCORecTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'FRM_HCO' LIMIT 1].Id;
        for (Address_vod__c addr : [SELECT Name, Address_Line_2_vod__c, City_vod__c, State_vod__c, Zip_vod__c, Location_gne__Latitude__s, Location_gne__Longitude__s, Account_vod__c FROM Address_vod__c WHERE Zip_vod__c IN :zipCodes AND Account_vod__r.RecordTypeId = :frmHCORecTypeId]) {
            if (addr.Location_gne__Latitude__s != null && addr.Location_gne__Longitude__s != null) {
                String coordinates = addr.Location_gne__Latitude__s + '_' + addr.Location_gne__Longitude__s;
                if (!coordinatesWithFRMHCOsMap.containsKey(addr.Zip_vod__c)) {
                    Map<String, List<Address_vod__c>> coordMap = new Map<String, List<Address_vod__c>>();
                    coordMap.put(coordinates, new List<Address_vod__c>{
                            addr
                    });
                    coordinatesWithFRMHCOsMap.put(addr.Zip_vod__c, coordMap);
                } else {
                    Map<String, List<Address_vod__c>> coordMap = coordinatesWithFRMHCOsMap.get(addr.Zip_vod__c);
                    if (!coordMap.containsKey(coordinates)) {
                        coordMap.put(coordinates, new List<Address_vod__c>{
                                addr
                        });
                    } else {
                        coordMap.get(coordinates).add(addr);
                    }
                    coordinatesWithFRMHCOsMap.put(addr.Zip_vod__c, coordMap);
                }

            }

            String fullAddressName = getFullAddrName(addr).toLowerCase();
            if (!fullAddressNamesWithFRMHCOsMap.containsKey(fullAddressName)) {
                fullAddressNamesWithFRMHCOsMap.put(fullAddressName, new List<Id>{
                        addr.Account_vod__c
                });
            } else {
                fullAddressNamesWithFRMHCOsMap.get(fullAddressName).add(addr.Account_vod__c);
            }

            String fullAddressNameWithoutCity = getFullAddrNameWithoutCity(addr).toLowerCase();
            if (!fullAddressNamesWithoutCityWithFRMHCOsMap.containsKey(fullAddressName)) {
                fullAddressNamesWithoutCityWithFRMHCOsMap.put(fullAddressNameWithoutCity, new List<Id>{
                        addr.Account_vod__c
                });
            } else {
                fullAddressNamesWithoutCityWithFRMHCOsMap.get(fullAddressNameWithoutCity).add(addr.Account_vod__c);
            }
        }

        for (Integer i = 0; i < serviceRequests.size(); i++) {
            Set<Id> frmHCOCandidatesToMapping = new Set<Id>();
            ServiceRequest sr = serviceRequests.get(i);
            String fAddrName = sr.address.getFullAddressName().toLowerCase();
            String fAddrNameWithoutCity = sr.address.getFullAddressNameWithoutCity().toLowerCase();

            if ((fullAddressNamesWithFRMHCOsMap.containsKey(fAddrName) && fullAddressNamesWithFRMHCOsMap.get(fAddrName).size() > 1) || (fullAddressNamesWithoutCityWithFRMHCOsMap.containsKey(fAddrNameWithoutCity) && fullAddressNamesWithoutCityWithFRMHCOsMap.get(fAddrNameWithoutCity).size() > 1)) {
                continue;
            } else if ((fullAddressNamesWithFRMHCOsMap.containsKey(fAddrName) && fullAddressNamesWithFRMHCOsMap.get(fAddrName).size() == 1) || (fullAddressNamesWithoutCityWithFRMHCOsMap.containsKey(fAddrNameWithoutCity) && fullAddressNamesWithoutCityWithFRMHCOsMap.get(fAddrNameWithoutCity).size() == 1)) {
                frmHCOCandidatesToMapping.add(fullAddressNamesWithFRMHCOsMap.containsKey(fAddrName) ? fullAddressNamesWithFRMHCOsMap.get(fAddrName).get(0) : fullAddressNamesWithoutCityWithFRMHCOsMap.get(fAddrNameWithoutCity).get(0));
            }

            if (frmHCOCandidatesToMapping.isEmpty() && coordinatesWithFRMHCOsMap.containsKey(sr.address.zip) && sr.hcpAddress.Location_gne__Latitude__s != null && sr.hcpAddress.Location_gne__Longitude__s != null) {
                Map<String, List<Address_vod__c>> coordMap = coordinatesWithFRMHCOsMap.get(sr.address.zip);
                List<Address_vod__c> frmHCOCandidates = new List<Address_vod__c>();
                for (String key : coordMap.keySet()) {
                    if (coordMap.get(key).size() == 1) {
                        Double lat1 = Double.valueOf(key.split('_').get(0));
                        Double lon1 = Double.valueOf(key.split('_').get(1));
                        Double lat2 = sr.hcpAddress.Location_gne__Latitude__s;
                        Double lon2 = sr.hcpAddress.Location_gne__Longitude__s;
                        if (checkAcceptedDistance(lat1, lon1, lat2, lon2) && coordMap.get(key).get(0).Address_Line_2_vod__c == sr.address.suiteFloorUnit) {
                            frmHCOCandidatesToMapping.add(coordMap.get(key).get(0).Account_vod__c);
                        }
                    }
                }
            }

            if (frmHCOCandidatesToMapping.size() == 1) {
                Id hcoId = (new List<Id>(frmHCOCandidatesToMapping)).get(0);
                Id hcpId = sr.hcpAccount.Id;
                Id hcpAddressId = sr.hcpAddress.Id;
                String pactAccountId = sr.prescriber.extId;
                String pactAddressId = sr.address.extId;
                mappingToInsert.add(createFRMHCOMapping(hcoId, hcpId, hcpAddressId, pactAccountId, pactAddressId));
                existingMappingExtIds.add(buildUniqueKeyInsensitive(pactAccountId, pactAddressId));
                serviceRequests.remove(i);
            }
        }

        if (!mappingToInsert.isEmpty()) {
            Database.insert(mappingToInsert, false);
        }
    }

    public static void autoMappingAfterUpdateAddressCoordinates(Set<Id> addrIds) {
        List<HCP_To_FRM_HCO_Mapping_gne__c> htfhm = [SELECT Id, HCP_Account_gne__c, HCP_Address_gne__c, HCP_Address_gne__r.Address_Line_2_vod__c, HCP_Address_gne__r.Zip_vod__c, HCP_Address_gne__r.Location_gne__Latitude__s, HCP_Address_gne__r.Location_gne__Longitude__s, PACT_Prescriber_Id_gne__c, PACT_Prescriber_Address_Id_gne__c FROM HCP_To_FRM_HCO_Mapping_gne__c WHERE HCP_Address_gne__c IN :addrIds];
        List<FRM_HCO_Mapping_gne__c> mappingToInsert = new List<FRM_HCO_Mapping_gne__c>();

        Set<String> zipCodes = new Set<String>();
        for (HCP_To_FRM_HCO_Mapping_gne__c h : htfhm) {
            zipCodes.add(h.HCP_Address_gne__r.Zip_vod__c);
        }

        Map<String, Map<String, List<Address_vod__c>>> coordinatesWithFRMHCOsMap = new Map<String, Map<String, List<Address_vod__c>>>();
        Id frmHCORecTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'FRM_HCO' LIMIT 1].Id;
        for (Address_vod__c addr : [SELECT Name, Address_Line_2_vod__c, City_vod__c, State_vod__c, Zip_vod__c, Location_gne__Latitude__s, Location_gne__Longitude__s, Account_vod__c FROM Address_vod__c WHERE Zip_vod__c IN :zipCodes AND Account_vod__r.RecordTypeId = :frmHCORecTypeId]) {
            if (addr.Location_gne__Latitude__s != null && addr.Location_gne__Longitude__s != null) {
                String coordinates = addr.Location_gne__Latitude__s + '_' + addr.Location_gne__Longitude__s;
                if (!coordinatesWithFRMHCOsMap.containsKey(addr.Zip_vod__c)) {
                    Map<String, List<Address_vod__c>> coordMap = new Map<String, List<Address_vod__c>>();
                    coordMap.put(coordinates, new List<Address_vod__c>{
                            addr
                    });
                    coordinatesWithFRMHCOsMap.put(addr.Zip_vod__c, coordMap);
                } else {
                    Map<String, List<Address_vod__c>> coordMap = coordinatesWithFRMHCOsMap.get(addr.Zip_vod__c);
                    if (!coordMap.containsKey(coordinates)) {
                        coordMap.put(coordinates, new List<Address_vod__c>{
                                addr
                        });
                    } else {
                        coordMap.get(coordinates).add(addr);
                    }
                    coordinatesWithFRMHCOsMap.put(addr.Zip_vod__c, coordMap);
                }

            }
        }

        for (HCP_To_FRM_HCO_Mapping_gne__c htm : htfhm) {
            Set<Id> frmHCOCandidatesToMapping = new Set<Id>();
            String htmZip = htm.HCP_Address_gne__r.Zip_vod__c;
            if (coordinatesWithFRMHCOsMap.containsKey(htmZip) && htm.HCP_Address_gne__r.Location_gne__Latitude__s != null && htm.HCP_Address_gne__r.Location_gne__Longitude__s != null) {
                Map<String, List<Address_vod__c>> coordMap = coordinatesWithFRMHCOsMap.get(htmZip);
                List<Address_vod__c> frmHCOCandidates = new List<Address_vod__c>();
                for (String key : coordMap.keySet()) {
                    if (coordMap.get(key).size() == 1) {
                        Double lat1 = Double.valueOf(key.split('_').get(0));
                        Double lon1 = Double.valueOf(key.split('_').get(1));
                        Double lat2 = htm.HCP_Address_gne__r.Location_gne__Latitude__s;
                        Double lon2 = htm.HCP_Address_gne__r.Location_gne__Longitude__s;
                        if (checkAcceptedDistance(lat1, lon1, lat2, lon2) && coordMap.get(key).get(0).Address_Line_2_vod__c == htm.HCP_Address_gne__r.Address_Line_2_vod__c) {
                            frmHCOCandidatesToMapping.add(coordMap.get(key).get(0).Account_vod__c);
                        }
                    }
                }
            }

            if (frmHCOCandidatesToMapping.size() == 1) {
                Id hcoId = (new List<Id>(frmHCOCandidatesToMapping)).get(0);
                Id hcpId = htm.HCP_Account_gne__c;
                Id hcpAddressId = htm.HCP_Address_gne__c;
                String pactAccountId = htm.PACT_Prescriber_Id_gne__c;
                String pactAddressId = htm.PACT_Prescriber_Address_Id_gne__c;
                mappingToInsert.add(createFRMHCOMapping(hcoId, hcpId, hcpAddressId, pactAccountId, pactAddressId));
            }
        }

        if (!mappingToInsert.isEmpty()) {
            Database.insert(mappingToInsert, false);
        }
    }

    public static void autoMappingAfterInsertUpdateFrmHcoAddress(List<Address_vod__c> addresses) {
        Set<String> addrZipCodes = new Set<String>();

        for (Address_vod__c addr : addresses) {
            if (String.isNotBlank(addr.Zip_vod__c)) {
                addrZipCodes.add(addr.Zip_vod__c);
            }
        }

        List<HCP_To_FRM_HCO_Mapping_gne__c> htfhm = [SELECT Id, HCP_Account_gne__c, HCP_Address_gne__c, HCP_Address_gne__r.Name, HCP_Address_gne__r.Address_Line_2_vod__c, HCP_Address_gne__r.City_vod__c, HCP_Address_gne__r.State_vod__c, HCP_Address_gne__r.Zip_vod__c, HCP_Address_gne__r.Location_gne__Latitude__s, HCP_Address_gne__r.Location_gne__Longitude__s, PACT_Prescriber_Id_gne__c, PACT_Prescriber_Address_Id_gne__c, HCP_Address_Full_Name_gne__c FROM HCP_To_FRM_HCO_Mapping_gne__c WHERE HCP_Address_gne__r.Zip_vod__c IN :addrZipCodes];
        List<FRM_HCO_Mapping_gne__c> mappingToInsert = new List<FRM_HCO_Mapping_gne__c>();

        Map<String, Map<String, List<Address_vod__c>>> coordinatesWithFRMHCOsMap = new Map<String, Map<String, List<Address_vod__c>>>();
        Map<String, List<Id>> fullAddressNamesWithFRMHCOsMap = new Map<String, List<Id>>();
        Map<String, List<Id>> fullAddressNamesWithoutCityWithFRMHCOsMap = new Map<String, List<Id>>();

        Id frmHCORecTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'FRM_HCO' LIMIT 1].Id;
        for (Address_vod__c addr : [SELECT Name, Address_Line_2_vod__c, City_vod__c, State_vod__c, Zip_vod__c, Location_gne__Latitude__s, Location_gne__Longitude__s, Account_vod__c FROM Address_vod__c WHERE Zip_vod__c IN :addrZipCodes AND Account_vod__r.RecordTypeId = :frmHCORecTypeId]) {
            if (addr.Location_gne__Latitude__s != null && addr.Location_gne__Longitude__s != null) {
                String coordinates = addr.Location_gne__Latitude__s + '_' + addr.Location_gne__Longitude__s;
                if (!coordinatesWithFRMHCOsMap.containsKey(addr.Zip_vod__c)) {
                    Map<String, List<Address_vod__c>> coordMap = new Map<String, List<Address_vod__c>>();
                    coordMap.put(coordinates, new List<Address_vod__c>{
                            addr
                    });
                    coordinatesWithFRMHCOsMap.put(addr.Zip_vod__c, coordMap);
                } else {
                    Map<String, List<Address_vod__c>> coordMap = coordinatesWithFRMHCOsMap.get(addr.Zip_vod__c);
                    if (!coordMap.containsKey(coordinates)) {
                        coordMap.put(coordinates, new List<Address_vod__c>{
                                addr
                        });
                    } else {
                        coordMap.get(coordinates).add(addr);
                    }
                    coordinatesWithFRMHCOsMap.put(addr.Zip_vod__c, coordMap);
                }

            }

            String fullAddressName = getFullAddrName(addr).toLowerCase();
            if (!fullAddressNamesWithFRMHCOsMap.containsKey(fullAddressName)) {
                fullAddressNamesWithFRMHCOsMap.put(fullAddressName, new List<Id>{
                        addr.Account_vod__c
                });
            } else {
                fullAddressNamesWithFRMHCOsMap.get(fullAddressName).add(addr.Account_vod__c);
            }

            String fullAddressNameWithoutCity = getFullAddrNameWithoutCity(addr).toLowerCase();
            if (!fullAddressNamesWithoutCityWithFRMHCOsMap.containsKey(fullAddressName)) {
                fullAddressNamesWithoutCityWithFRMHCOsMap.put(fullAddressNameWithoutCity, new List<Id>{
                        addr.Account_vod__c
                });
            } else {
                fullAddressNamesWithoutCityWithFRMHCOsMap.get(fullAddressNameWithoutCity).add(addr.Account_vod__c);
            }
        }

        for (HCP_To_FRM_HCO_Mapping_gne__c htm : htfhm) {
            Set<Id> frmHCOCandidatesToMapping = new Set<Id>();
            String htmZip = htm.HCP_Address_gne__r.Zip_vod__c;
            String htmlAddrName = getFullAddrName(htm.HCP_Address_gne__r.Name, htm.HCP_Address_gne__r.Address_Line_2_vod__c, htm.HCP_Address_gne__r.City_vod__c, htm.HCP_Address_gne__r.State_vod__c, htm.HCP_Address_gne__r.Zip_vod__c).toLowerCase();
            String htmlAddrNameWithoutCity = getFullAddrNameWithoutCity(htm.HCP_Address_gne__r.Name, htm.HCP_Address_gne__r.Address_Line_2_vod__c, htm.HCP_Address_gne__r.City_vod__c, htm.HCP_Address_gne__r.State_vod__c, htm.HCP_Address_gne__r.Zip_vod__c).toLowerCase();

            if ((fullAddressNamesWithFRMHCOsMap.containsKey(htmlAddrName) && fullAddressNamesWithFRMHCOsMap.get(htmlAddrName).size() > 1) || (fullAddressNamesWithoutCityWithFRMHCOsMap.containsKey(htmlAddrNameWithoutCity) && fullAddressNamesWithoutCityWithFRMHCOsMap.get(htmlAddrNameWithoutCity).size() > 1)) {
                continue;
            } else if ((fullAddressNamesWithFRMHCOsMap.containsKey(htmlAddrName) && fullAddressNamesWithFRMHCOsMap.get(htmlAddrName).size() == 1) || (fullAddressNamesWithoutCityWithFRMHCOsMap.containsKey(htmlAddrNameWithoutCity) && fullAddressNamesWithoutCityWithFRMHCOsMap.get(htmlAddrNameWithoutCity).size() == 1)) {
                frmHCOCandidatesToMapping.add(fullAddressNamesWithFRMHCOsMap.containsKey(htmlAddrName) ? fullAddressNamesWithFRMHCOsMap.get(htmlAddrName).get(0) : fullAddressNamesWithoutCityWithFRMHCOsMap.get(htmlAddrNameWithoutCity).get(0));
            }

            if (coordinatesWithFRMHCOsMap.containsKey(htmZip) && htm.HCP_Address_gne__r.Location_gne__Latitude__s != null && htm.HCP_Address_gne__r.Location_gne__Longitude__s != null) {
                Map<String, List<Address_vod__c>> coordMap = coordinatesWithFRMHCOsMap.get(htmZip);
                List<Address_vod__c> frmHCOCandidates = new List<Address_vod__c>();
                for (String key : coordMap.keySet()) {
                    if (coordMap.get(key).size() == 1) {
                        Double lat1 = Double.valueOf(key.split('_').get(0));
                        Double lon1 = Double.valueOf(key.split('_').get(1));
                        Double lat2 = htm.HCP_Address_gne__r.Location_gne__Latitude__s;
                        Double lon2 = htm.HCP_Address_gne__r.Location_gne__Longitude__s;
                        if (checkAcceptedDistance(lat1, lon1, lat2, lon2) && coordMap.get(key).get(0).Address_Line_2_vod__c == htm.HCP_Address_gne__r.Address_Line_2_vod__c) {
                            frmHCOCandidatesToMapping.add(coordMap.get(key).get(0).Account_vod__c);
                        }
                    }
                }
            }
            if (frmHCOCandidatesToMapping.size() == 1) {
                Id hcoId = (new List<Id>(frmHCOCandidatesToMapping)).get(0);
                Id hcpId = htm.HCP_Account_gne__c;
                Id hcpAddressId = htm.HCP_Address_gne__c;
                String pactAccountId = htm.PACT_Prescriber_Id_gne__c;
                String pactAddressId = htm.PACT_Prescriber_Address_Id_gne__c;
                mappingToInsert.add(createFRMHCOMapping(hcoId, hcpId, hcpAddressId, pactAccountId, pactAddressId));
            }
        }

        if (!mappingToInsert.isEmpty()) {
            Database.insert(mappingToInsert, false);
        }
    }

    private void upsertTempMapping() {
        for (ServiceRequest sr : serviceRequests) {
            String extIdKey = buildUniqueKeyInsensitive(sr.prescriber.extId, sr.address.extId);
            String mdmIdKey = buildUniqueKeyInsensitive(sr.prescriber.mdmId, sr.address.mdmId);
            if (!existingMappingExtIds.contains(extIdKey) && !existingMappingExtIds.contains(mdmIdKey) &&
                    !existingTempMapping.containsKey(extIdKey) && !existingTempMapping.containsKey(mdmIdKey)) {
                tempMappingToUpsert.add(createHCPToFRMHCOMapping(sr));
            }
        }

        if (!tempMappingToUpsert.isEmpty()) {
            Database.upsert(tempMappingToUpsert, false);
        }
    }

    // Accepted distance <= 100 m
    public static Boolean checkAcceptedDistance(Double lat1, Double lon1, Double lat2, Double lon2) {
        Location loc1 = Location.newInstance(lat1, lon1);
        Location loc2 = Location.newInstance(lat2, lon2);
        return Integer.valueOf((Decimal.valueOf(loc1.getDistance(loc2, 'km')).setScale(2)) * 1000) <= 100;
    }

    private void retrieveAccountAndAddressFromMDM(String mdmId, ServiceRequest servRequest, Map<String, Account> accountsToInsert, Map<String, List<Address_vod__c>> addressesToInsert) {
        GNE_SFA2_SBC_MDM_DAO mdm = new GNE_SFA2_SBC_MDM_DAO();

        GNE_SFA2_SBC_DAO.DataWrapper mdmResult = mdm.searchAccounts(MDM_ACCOUNT_MODE, MDM_SEARCH_MODE, new Map<String, String>{
                'MDMID' => mdmId
        });

        if (!mdmResult.rows.isEmpty()) {
            GNE_SFA2_SBC_DAO.AccountWrapper mdmAcc = mdmResult.rows.get(0);
            if (!accountsToInsert.containsKey(servRequest.prescriber.extId)) {
                accountsToInsert.put(servRequest.prescriber.extId, createAccount(mdmAcc, servRequest.prescriber));
            }
            Address_vod__c addr = null;
            for (GNE_SFA2_SBC_DAO.AddressWrapper address : mdmAcc.addresses) {
                if (servRequest.address.getFullAddressName() == address.getFullAddressName()) {
                    addr = createAddress(address, servRequest.address);
                    if (!addressesToInsert.containsKey(servRequest.prescriber.extId)) {
                        addressesToInsert.put(servRequest.prescriber.extId, new List<Address_vod__c>{
                                addr
                        });
                    } else {
                        addressesToInsert.get(servRequest.prescriber.extId).add(addr);
                    }
                    continue;
                }
            }

            if (addr == null) {
                if (!addressesToInsert.containsKey(servRequest.prescriber.extId)) {
                    addressesToInsert.put(servRequest.prescriber.extId, new List<Address_vod__c>{
                            createAddress(servRequest.address)
                    });
                } else {
                    addressesToInsert.get(servRequest.prescriber.extId).add(createAddress(servRequest.address));
                }
            }
        } else {
            if (!accountsToInsert.containsKey(servRequest.prescriber.extId)) {
                accountsToInsert.put(servRequest.prescriber.extId, createAccount(servRequest.prescriber));
            }

            if (!addressesToInsert.containsKey(servRequest.prescriber.extId)) {
                addressesToInsert.put(servRequest.prescriber.extId, new List<Address_vod__c>{
                        createAddress(servRequest.address)
                });
            } else {
                addressesToInsert.get(servRequest.prescriber.extId).add(createAddress(servRequest.address));
            }
        }
    }

    private Account createAccount(GNE_SFA2_SBC_DAO.AccountWrapper mdmAcc, Prescriber acc) {
        List<String> profTypes = GNE_SFA2_SBC_Config.getHcpProfTypesSortedByRank(mdmAcc.profTypes != null ? new Set<String>(mdmAcc.profTypes) : null);
        return new Account(
                FirstName = mdmAcc.firstName,
                LastName = mdmAcc.lastName,
                Middle_gne__c = mdmAcc.middleName,
                Status_gne__c = mdmAcc.status,
                Phone = acc.phone,
                Professional_Type_gne__c = !profTypes.isEmpty() ? profTypes[0] : null,
                Credentials_gne__c = !mdmAcc.credentials.isEmpty() ? (String.join(mdmAcc.credentials, ';')) : null,
                MDMID_gne__c = mdmAcc.mdmId,
                MDMID_Status_gne__c = mdmAcc.status,
                PACT_Id__c = acc.extId,
                OwnerId = etlAdminUserId
        );
    }

    private Account createAccount(Prescriber acc) {
        return new Account(
                FirstName = acc.firstName,
                LastName = acc.lastName,
                Middle_gne__c = acc.middleName,
                Status_gne__c = acc.status,
                Phone = acc.phone,
                Professional_Type_gne__c = acc.profType,
                Credentials_gne__c = acc.credentials,
                PACT_Id__c = acc.extId,
                OwnerId = etlAdminUserId
        );
    }

    private Address_vod__c createAddress(GNE_SFA2_SBC_DAO.AddressWrapper mdmAddr, Address addr) {
        return new Address_vod__c(
                MDM_Address_Id_gne__c = String.isNotBlank(mdmAddr.mdmAddressId) ? mdmAddr.mdmAddressId : null,
                Name = mdmAddr.streetAddress,
                Address_Line_2_vod__c = mdmAddr.suite,
                City_vod__c = mdmAddr.cityName,
                State_vod__c = mdmAddr.stateCode,
                Zip_vod__c = mdmAddr.zipCode,
                PACT_Id__c = addr.extId,
                Location_gne__Latitude__s = null,
                Location_gne__Longitude__s = null,
                Force_Location_Update_gne__c = true
        );
    }

    private Address_vod__c createAddress(Address addr) {
        return createAddress(addr, null);
    }

    private Address_vod__c createAddress(Address addr, Id accId) {
        return new Address_vod__c(
                Account_vod__c = accId,
                MDM_Address_Id_gne__c = String.isNotBlank(addr.mdmId) ? addr.mdmId : null,
                Name = addr.street,
                Address_Line_2_vod__c = addr.suiteFloorUnit,
                City_vod__c = addr.city,
                State_vod__c = addr.state,
                Zip_vod__c = addr.zip,
                PACT_Id__c = addr.extId,
                Location_gne__Latitude__s = null,
                Location_gne__Longitude__s = null,
                Force_Location_Update_gne__c = true
        );
    }

    private HCP_To_FRM_HCO_Mapping_gne__c createHCPToFRMHCOMapping(ServiceRequest servRequest) {
        return new HCP_To_FRM_HCO_Mapping_gne__c(
                HCP_Account_gne__c = servRequest.hcpAccount.Id,
                HCP_Address_gne__c = servRequest.hcpAddress.Id,
                PACT_Prescriber_Id_gne__c = servRequest.prescriber.extId,
                PACT_Prescriber_Address_Id_gne__c = servRequest.address.extId,
                Products_gne__c = servRequest.prescriber.products
        );
    }

    private static FRM_HCO_Mapping_gne__c createFRMHCOMapping(Id hcoId, Id hcpId, Id hcpAddressId, String pactAccountId, String pactAddressId) {
        return new FRM_HCO_Mapping_gne__c(
                FRM_HCO_Account_gne__c = hcoId,
                HCP_Account_gne__c = hcpId,
                HCP_Address_gne__c = hcpAddressId,
                PACT_Prescriber_Id_gne__c = pactAccountId,
                PACT_Prescriber_Address_Id_gne__c = pactAddressId,
                Is_Auto_Mapped_gne__c = true
        );
    }

    private String buildUniqueKey(String val1, String val2) {
        return (val1 + '_' + val2).toLowerCase();
    }

    private String buildUniqueKeyInsensitive(String val1, String val2) {
        return (val1 + '_' + val2);
    }

    public List<AccountMappingWrapper> getAccountMappingWrapper() {
        return getAccountMappingWrapper(null);
    }

    public List<HCP_To_FRM_HCO_Mapping_gne__c> getAccountMapping(Id userId) {
        List<HCP_To_FRM_HCO_Mapping_gne__c> result = new List<HCP_To_FRM_HCO_Mapping_gne__c>();
        Set<String> zipCodes = getUserTerritoriesZipCodes(userId);
        Set<String> products = getUserProducts(userId);

        if (!products.isEmpty()) {
            for (HCP_To_FRM_HCO_Mapping_gne__c htfhm : [SELECT Id, CreatedDate, LastModifiedDate, HCP_Account_gne__r.LastName, HCP_Account_gne__r.FirstName, HCP_Account_gne__r.MDMID_gne__c, HCP_Account_gne__c, HCP_Account_gne__r.Name, HCP_Account_gne__r.Formatted_Name_vod__c, HCP_Account_gne__r.MDMID_Status_gne__c, HCP_Account_gne__r.Status_gne__c, HCP_Account_gne__r.Phone, HCP_Address_gne__c, HCP_Account_gne__r.CreatedDate, HCP_Account_gne__r.CreatedById, HCP_Account_gne__r.CreatedBy.Name, HCP_Address_gne__r.Address_Line_2_vod__c, HCP_Address_gne__r.Name, HCP_Address_gne__r.City_vod__c, HCP_Address_gne__r.State_vod__c, HCP_Address_gne__r.Zip_vod__c, HCP_Address_gne__r.Location_gne__Latitude__s, HCP_Address_gne__r.Location_gne__Longitude__s, Products_gne__c, PACT_Prescriber_Id_gne__c, PACT_Prescriber_Address_Id_gne__c, IsHidden_gne__c FROM HCP_To_FRM_HCO_Mapping_gne__c WHERE Products_gne__c != null AND HCP_Address_gne__r.Zip_vod__c in :zipCodes AND IsHidden_gne__c = false ORDER BY HCP_Account_gne__r.LastName]) {
                for (String product : htfhm.Products_gne__c.split(';')) {
                    if (products.contains(product)) {
                        result.add(htfhm);
                        break;
                    }
                }
            }
        }
        return result;
    }

    public List<AccountMappingWrapper> getAccountMappingWrapper(String hcoId) {
        Double hcoAddrLat = null;
        Double hcoAddrLon = null;
        if (String.isNotBlank(hcoId)) {
            List<Address_vod__c> hcoAddr = [SELECT Location_gne__Latitude__s, Location_gne__Longitude__s FROM Address_vod__c WHERE Account_vod__c = :hcoId LIMIT 1];
            if (!hcoAddr.isEmpty() && hcoAddr.get(0).Location_gne__Latitude__s != null && hcoAddr.get(0).Location_gne__Longitude__s != null) {
                hcoAddrLat = hcoAddr.get(0).Location_gne__Latitude__s;
                hcoAddrLon = hcoAddr.get(0).Location_gne__Longitude__s;
            }
        }

        List<AccountMappingWrapper> result = new List<AccountMappingWrapper>();

        for (HCP_To_FRM_HCO_Mapping_gne__c htfhm : getAccountMapping(UserInfo.getUserId())) {
            result.add(new AccountMappingWrapper(htfhm, hcoAddrLat, hcoAddrLon));
        }
        return result;
    }

    public GNE_SFA2_Base_Ctrl.DataWrapper getSBCConfig() {
        GNE_SFA2_SBC_Ctrl sbc = new GNE_SFA2_SBC_Ctrl();
        sbc.isCreateAddressMode = false;
        sbc.dataWrapper = new GNE_SFA2_SBC_Ctrl.DataWrapper();
        Map<String, String> params = new Map<String, String>{
                'uiType' => 'standard',
                'debugMode' => '',
                'apiStaticResource' => '',
                'uiStaticResource' => '',
                'pageStaticResource' => '',
                'isPopup' => 'false',
                'popupReturnAction' => ''
        };

        return sbc.intInit(params);
    }

    global GNE_SFA2_Base_Ctrl.DataWrapper sbcSearchAccounts(String searchDataWrapperInJSON) {
        return (new GNE_SFA2_SBC_Ctrl()).searchAccounts(searchDataWrapperInJSON, false);
    }

    global GNE_SFA2_Base_Ctrl.DataWrapper searchMore(String searchMoreDataWrapperInJSON) {
        return (new GNE_SFA2_SBC_Ctrl()).searchAccounts(searchMoreDataWrapperInJSON, true);
    }

    global GNE_SFA2_Base_Ctrl.DataWrapper insertAccount(String inputDataWrapperInJSON) {
        GNE_SFA2_Base_Ctrl.DataWrapper resultData = (new GNE_SFA2_SBC_Ctrl()).insertAccount(inputDataWrapperInJSON);
        resultData.retUrl = null;
        return resultData;
    }

    global GNE_SFA2_Base_Ctrl.DataWrapper upsertAccount(String inputDataWrapperInJSON) {
        GNE_SFA2_Base_Ctrl.DataWrapper resultData = (new GNE_SFA2_SBC_Ctrl()).upsertAccount(inputDataWrapperInJSON);
        resultData.retUrl = null;
        return resultData;
    }

    global List<AccountMappingWrapper> getFRMHCO(Map<String, String> params) {
        List<AccountMappingWrapper> result = new List<AccountMappingWrapper>();
        Integer accLimit = 5;
        Decimal latitude = String.isNotBlank(params.get('latitude')) ? Decimal.valueOf(params.get('latitude')) : 0;
        Decimal longitude = String.isNotBlank(params.get('longitude')) ? Decimal.valueOf(params.get('longitude')) : 0;
        Set<String> currentTerrNames = getUserTerritoriesName();

        List<Address_vod__c> addrs = Database.query(String.format('SELECT {0} FROM Address_vod__c WHERE {1} ORDER BY {2} LIMIT {3}', new String[]{
                'Id, Account_vod__c, Account_vod__r.Name, Account_vod__r.Formatted_Name_vod__c, Account_vod__r.Phone, Account_vod__r.MDMID_Status_gne__c, Address_Line_2_vod__c, Name, City_vod__c, State_vod__c, Zip_vod__c, Location_gne__Latitude__s, Location_gne__Longitude__s',
                'Account_vod__c IN (SELECT Account_vod__c FROM TSF_vod__c WHERE Territory_vod__c IN :currentTerrNames AND Address_vod__c <> null AND Account_vod__r.IsPersonAccount = false AND Account_vod__r.RecordType.DeveloperName =: FRM_HCO_RECORD_TYPE_NAME)',
                'DISTANCE(Location_gne__c,GEOLOCATION(' + latitude + ',' + longitude + '), \'mi\') ASC NULLS LAST',
                String.valueOf(accLimit)
        }));

        for (Address_vod__c addr : addrs) {
            result.add(new AccountMappingWrapper(addr));
        }

        return result;
    }

    public AccountMappingWrapper getNewHCP(Map<String, String> params) {

        String acctId = params.get('accId');
        String addrId = null;
        if (params.containsKey('addrId')) {
            addrId = params.get('addrId');
        }

        Address_vod__c addr = Database.query(String.format('SELECT {0} FROM Address_vod__c WHERE {1} LIMIT 1', new String[]{
                'Id, Account_vod__c, Account_vod__r.Formatted_Name_vod__c, Account_vod__r.Phone, Account_vod__r.MDMID_Status_gne__c, Address_Line_2_vod__c, Name, City_vod__c, State_vod__c, Zip_vod__c, Location_gne__Latitude__s, Location_gne__Longitude__s',
                'Account_vod__c =: acctId' + (String.isNotBlank(addrId) ? ' AND Id =: addrId' : '')
        }));

        return new AccountMappingWrapper(addr);
    }

    global SaveMappingWrapper createAccountMapping(Id hcoId, Id hcpId, Id hcpAddressId, String pactAccountId, String pactAddressId) {
        List<FRM_HCO_Mapping_gne__c> fm = [SELECT FRM_HCO_Account_gne__c, FRM_HCO_Account_gne__r.Name, HCP_Account_gne__c, HCP_Account_gne__r.Formatted_Name_vod__c, HCP_Account_gne__r.MDMID_Status_gne__c, HCP_Account_gne__r.MDMID_gne__c, HCP_Address_Full_Name_gne__c, HCP_Account_gne__r.Phone, CreatedById, CreatedBy.Name, CreatedDate FROM FRM_HCO_Mapping_gne__c WHERE HCP_Account_gne__c = :hcpId AND HCP_Address_gne__c = :hcpAddressId LIMIT 1];
        List<HCP_To_FRM_HCO_Mapping_gne__c> tempMap = [SELECT Id FROM HCP_To_FRM_HCO_Mapping_gne__c WHERE HCP_Address_gne__c = :hcpAddressId AND HCP_Account_gne__c = :hcpId];
        Boolean isFHMExist = true;
        if (fm.isEmpty()) {
            isFHMExist = false;
            FRM_HCO_Mapping_gne__c newfm = new FRM_HCO_Mapping_gne__c(FRM_HCO_Account_gne__c = hcoId, HCP_Account_gne__c = hcpId, HCP_Address_gne__c = hcpAddressId, PACT_Prescriber_Id_gne__c = pactAccountId, PACT_Prescriber_Address_Id_gne__c = pactAddressId);
            insert newfm;
            fm = [SELECT FRM_HCO_Account_gne__c, FRM_HCO_Account_gne__r.Name, HCP_Account_gne__c, HCP_Account_gne__r.Formatted_Name_vod__c, HCP_Account_gne__r.MDMID_Status_gne__c, HCP_Account_gne__r.MDMID_gne__c, HCP_Address_Full_Name_gne__c, HCP_Account_gne__r.Phone, CreatedById, CreatedBy.Name, CreatedDate FROM FRM_HCO_Mapping_gne__c WHERE Id = :newfm.Id LIMIT 1];
        } else {
            if (!tempMap.isEmpty()) {
                delete tempMap;
            }
        }
        return new SaveMappingWrapper((!tempMap.isEmpty() ? tempMap.get(0).Id : null), fm.get(0), isFHMExist);
    }

    global SaveMappingWrapper createAccountMapping(Map<String, String> params) {
        return createAccountMapping(params.get('hcoId'), params.get('hcpId'), params.get('hcpAddrId'), params.get('pactId'), params.get('pactAddrId'));
    }

    global HideMappingWrapper hideMapping(Id mappingId) {
        HCP_To_FRM_HCO_Mapping_gne__c tempMap = [SELECT Id FROM HCP_To_FRM_HCO_Mapping_gne__c WHERE Id = :mappingId LIMIT 1];
        tempMap.IsHidden_gne__c = true;
        tempMap.Products_gne__c = '';
        update tempMap;
        return new HideMappingWrapper(tempMap.Id, tempMap);
    }

    public FRMHCOWrapper getFRMHCO(String frmId) {
        Account acct = [SELECT Id, Name, MDMId_Status_gne__c, Phone, (SELECT Address_Line_2_vod__c, Name, City_vod__c, State_vod__c, Zip_vod__c FROM Address_vod__r) FROM Account WHERE Id = :frmId LIMIT 1];

        return new FRMHCOWrapper(acct, acct.Address_vod__r.get(0));
    }

    public Set<String> getUserTerritoriesName() {
        Set<String> result = new Set<String>();

        for (Territory2 terr : [SELECT Name FROM Territory2 WHERE Id IN (SELECT Territory2Id FROM UserTerritory2Association WHERE UserId = :UserInfo.getUserId())]) {
            result.add(terr.Name);
        }

        return result;
    }

    public Set<String> getUserTerritoriesZipCodes(Id userId) {
        Set<String> result = new Set<String>();
        if (GNE_SFA2_Util.isFRMUser() || GNE_SFA2_Util.isCrmFrmUser()) {
            Set<String> userTerritoryNumbers = new Set<String>();
            for (Territory2 terr : [SELECT Territory_Number_gne__c FROM Territory2 WHERE Id IN (SELECT Territory2Id FROM UserTerritory2Association WHERE UserId = :userId) AND Territory_Number_gne__c != null]) {
                userTerritoryNumbers.add(terr.Territory_Number_gne__c);
            }

            String query = 'SELECT Zip_Code_gne__c FROM Zip_to_Territory_gne__c WHERE (STARS_BrandCode_gne__c IN :teamCodes' + (teamCodes.contains('RFRM') ? ' OR Salesforce_SubTeam_Code_gne__c = \'RCM\')' : ')') + ' AND Territory_Number_gne__c IN :userTerritoryNumbers AND Region_Code_gne__c = 1';

            for (Zip_to_Territory_gne__c ztt : Database.query(query)) {
                result.add(ztt.Zip_Code_gne__c);
            }
        }

        return result;
    }

    public Set<String> getUserTerritoriesZipCodes() {
        return getUserTerritoriesZipCodes(UserInfo.getUserId());
    }

    public Set<String> getUserProducts(Id userId) {
        Set<String> result = new Set<String>();

        if (GNE_SFA2_Util.isFRMUser() || GNE_SFA2_Util.isCrmFrmUser()) {
            Set<String> userTerritoryNumbers = new Set<String>();
            for (FRM_Prod_2_Team_gne__c p2t : [SELECT Product_Name_gne__c FROM FRM_Prod_2_Team_gne__c WHERE FRM_Team_Code_gne__c IN :teamCodes]) {
                result.add(p2t.Product_Name_gne__c);
            }
        }

        return result;
    }

    public Set<String> getUserProducts() {
        return getUserProducts(UserInfo.getUserId());
    }

    private static String getFullAddrName(Address_vod__c addr) {
        return getFullAddrName(addr.Name, addr.Address_Line_2_vod__c, addr.City_vod__c, addr.State_vod__c, addr.Zip_vod__c, true);
    }

    private static String getFullAddrName(String street, String addrLine2, String city, String state, String zipCode) {
        return getFullAddrName(street, addrLine2, city, state, zipCode, true);
    }

    private static String getFullAddrNameWithoutCity(Address_vod__c addr) {
        return getFullAddrName(addr.Name, addr.Address_Line_2_vod__c, addr.City_vod__c, addr.State_vod__c, addr.Zip_vod__c, false);
    }

    private static String getFullAddrNameWithoutCity(String street, String addrLine2, String city, String state, String zipCode) {
        return getFullAddrName(street, addrLine2, city, state, zipCode, false);
    }

    private static String getFullAddrName(String street, String addrLine2, String city, String state, String zipCode, Boolean withCity) {
        String result = '';

        if (String.isNotBlank(street)) {
            result += street;
        }

        if (String.isNotBlank(addrLine2)) {
            result += String.isNotBlank(result) ? (', ' + addrLine2) : addrLine2;
        }

        if (withCity && String.isNotBlank(city)) {
            result += String.isNotBlank(result) ? (', ' + city) : city;
        }

        if (String.isNotBlank(state)) {
            result += String.isNotBlank(result) ? (', ' + state) : state;
        }

        if (String.isNotBlank(zipCode)) {
            result += String.isNotBlank(result) ? (' ' + zipCode) : zipCode;
        }

        return result;
    }

    global class SaveMappingWrapper {
        protected Id tempMapId;
        protected FRM_HCO_Mapping_gne__c fm;
        protected Boolean isFHMExist;

        public SaveMappingWrapper() {
        }

        public SaveMappingWrapper(Id tempMapId, FRM_HCO_Mapping_gne__c fm, Boolean isFHMExist) {
            this.tempMapId = tempMapId;
            this.fm = fm;
            this.isFHMExist = isFHMExist;
        }

        public FRM_HCO_Mapping_gne__c getMapping() {
            return fm;
        }

    }

    global class HideMappingWrapper {
        protected Id tempMapId;
        protected HCP_To_FRM_HCO_Mapping_gne__c frmMapping;

        public HideMappingWrapper() {
        }

        public HideMappingWrapper(Id tempMapId, HCP_To_FRM_HCO_Mapping_gne__c frmMapping) {
            this.tempMapId = tempMapId;
            this.frmMapping = frmMapping;
        }

        public HCP_To_FRM_HCO_Mapping_gne__c getMapping() {
            return frmMapping;
        }

    }

    public class ServiceRequest {
        public String id;
        public Prescriber prescriber;
        public Address address;
        public Account hcpAccount;
        public Address_vod__c hcpAddress;

        public ServiceRequest() {
        }

        public ServiceRequest(Case__x serviceRequest) {
            this.id = serviceRequest.Id;
            this.prescriber = new Prescriber(serviceRequest);
            this.address = new Address(serviceRequest);
        }

        public ServiceRequest(Case serviceRequest) {
            this.id = serviceRequest.Id;

            Account acct = new Account(
                    Id = serviceRequest.Case_Treating_Physician_gne__c,
                    Name = serviceRequest.Case_Treating_Physician_gne__r.Name,
                    MDMID_gne__c = serviceRequest.Case_Treating_Physician_gne__r.MDMID_gne__c,
                    FirstName = serviceRequest.Case_Treating_Physician_gne__r.FirstName,
                    LastName = serviceRequest.Case_Treating_Physician_gne__r.LastName,
                    Middle_gne__c = serviceRequest.Case_Treating_Physician_gne__r.Middle_gne__c,
                    Phone = serviceRequest.Case_Treating_Physician_gne__r.Phone,
                    Status_gne__c = serviceRequest.Case_Treating_Physician_gne__r.Status_gne__c,
                    Professional_Type_gne__c = serviceRequest.Case_Treating_Physician_gne__r.Professional_Type_gne__c,
                    Credentials_gne__c = serviceRequest.Case_Treating_Physician_gne__r.Credentials_gne__c
            );

            Address_vod__c addr = new Address_vod__c(
                    Id = serviceRequest.Address_gne__c,
                    MDM_Address_Id_gne__c = serviceRequest.Address_gne__r.MDM_Address_Id_gne__c,
                    Name = serviceRequest.Address_gne__r.Name,
                    Address_Line_2_vod__c = serviceRequest.Address_gne__r.Address_Line_2_vod__c,
                    City_vod__c = serviceRequest.Address_gne__r.City_vod__c,
                    State_vod__c = serviceRequest.Address_gne__r.State_vod__c,
                    Zip_vod__c = serviceRequest.Address_gne__r.Zip_vod__c
            );

            this.prescriber = new Prescriber(acct, serviceRequest.Product_gne__c);
            this.address = new Address(addr);
            this.hcpAccount = acct;
            this.hcpAddress = addr;
        }

        public String getExtKey() {
            return this.prescriber.extId + '_' + this.address.extId;
        }

        public String getMDMKey() {
            return this.prescriber.mdmId + '_' + this.address.mdmId;
        }

        public String getAccMDMAddrNameKey() {
            return this.prescriber.mdmId + '_' + this.address.getFullAddressName();
        }

        public String getAccNameAddrMDMKey() {
            return this.prescriber.getName() + '_' + this.address.mdmId;
        }

        public String getAccNameAddrNameKey() {
            return this.prescriber.getName() + '_' + this.address.getFullAddressName();
        }

        public void mergeProducts(List<String> productsToMerge) {
            for (String p : productsToMerge) {
                if (!this.prescriber.products.containsIgnoreCase(p)) {
                    this.prescriber.products += String.isNotBlank(this.prescriber.products) ? (';' + p) : p;
                }
            }
        }
    }

    public class Prescriber {
        protected String extId;
        protected String extAddrId;
        public String mdmId;
        protected String firstName;
        protected String lastName;
        protected String middleName;
        protected String phone;
        protected String status;
        protected String profType;
        protected String credentials;
        protected String products;

        public Prescriber() {
        }

        public Prescriber(Case__x serviceRequest) {
            this.extId = serviceRequest.HCP_PACT_ID__c;
            this.mdmId = serviceRequest.HCP_MDM_ID__c;
            this.firstName = serviceRequest.HCP_Prescriber_First_Name__c;
            this.lastName = serviceRequest.HCP_Prescriber_Last_Name__c;
            this.middleName = serviceRequest.HCP_Prescriber_Middle_Name__c;
            this.phone = serviceRequest.HCP_Prescriber_Phone__c;
            this.status = serviceRequest.HCP_Status__c;
            this.profType = serviceRequest.HCP_Professional_Type__c;
            this.credentials = String.isNotBlank(serviceRequest.HCP_Credentials__c) ? serviceRequest.HCP_Credentials__c.replace('<br>', ';').removeEnd(';') : null;
            this.products = serviceRequest.Products_List__c;
        }

        public Prescriber(Account acct, String products) {
            this.mdmId = acct.MDMID_gne__c;
            this.firstName = acct.FirstName;
            this.lastName = acct.LastName;
            this.middleName = acct.Middle_gne__c;
            this.phone = acct.Phone;
            this.status = acct.Status_gne__c;
            this.profType = acct.Professional_Type_gne__c;
            this.credentials = acct.Credentials_gne__c;
            this.products = products;
        }

        public String getName() {
            return (String.isNotBlank(this.firstName) ? this.firstName : '') + ' ' + (String.isNotBlank(this.lastName) ? this.lastName : '');
        }

    }

    public class Address {
        protected String extId;
        protected String mdmId;
        protected String street;
        protected String suiteFloorUnit;
        protected String city;
        protected String state;
        protected String zip;

        public Address() {
        }

        public Address(Case__x serviceRequest) {
            this.extId = serviceRequest.HCP_Address_PACT_ID__c;
            this.mdmId = serviceRequest.HCP_Address_MDM_ID__c;
            this.street = serviceRequest.HCP_Prescriber_Address_Line_1__c;
            this.suiteFloorUnit = serviceRequest.HCP_Prescriber_Address_Line_2__c;
            this.city = serviceRequest.HCP_City__c;
            this.state = serviceRequest.HCP_State__c;
            this.zip = serviceRequest.HCP_Zip__c;
        }

        public Address(Address_vod__c addr) {
            this.mdmId = addr.MDM_Address_Id_gne__c;
            this.street = addr.Name;
            this.suiteFloorUnit = addr.Address_Line_2_vod__c;
            this.city = addr.City_vod__c;
            this.state = addr.State_vod__c;
            this.zip = addr.Zip_vod__c;
        }

        public String getFullAddressName() {
            return getFullAddressName(true);
        }

        public String getFullAddressNameWithoutCity() {
            return getFullAddressName(false);
        }

        public String getFullAddressName(Boolean withCity) {
            String result = '';

            if (String.isNotBlank(this.street)) {
                result += this.street;
            }

            if (String.isNotBlank(this.suiteFloorUnit)) {
                result += String.isNotBlank(result) ? (', ' + this.suiteFloorUnit) : this.suiteFloorUnit;
            }

            if (withCity && String.isNotBlank(this.city)) {
                result += String.isNotBlank(result) ? (', ' + this.city) : this.city;
            }

            if (String.isNotBlank(this.state)) {
                result += String.isNotBlank(result) ? (', ' + this.state) : this.state;
            }

            if (String.isNotBlank(this.zip)) {
                result += String.isNotBlank(result) ? (' ' + this.zip) : this.zip;
            }

            return result;
        }

    }

    public class AccountWithAddress {
        protected Account account;
        protected Address_vod__c address;

        public AccountWithAddress() {
        }

        public AccountWithAddress(Account account, Address_vod__c address) {
            this.account = account;
            this.address = address;
        }

        public AccountWithAddress(Account account) {
            this.account = account;
        }
    }

    global class AccountMappingWrapper {
        public String id;
        public String hcpId;
        public String hcpName;
        public String active;
        public String addressId;
        public String fullAddressName;
        public String phone;
        public String products;
        public Datetime createdDate;
        public String ownerId;
        public String ownerName;
        public Decimal latitude;
        public Decimal longitude;
        public Double distance;
        public String pactId;
        public String pactAddrId;
        public Boolean isHidden;

        public AccountMappingWrapper() {
        }

        public AccountMappingWrapper(String accId, String accName, String accStatus, Address_vod__c address, String phone) {
            this.hcpId = accId;
            this.hcpName = accName;
            this.active = String.isNotBlank(accStatus) ? accStatus : 'Active';
            this.fullAddressName = getFullAddressName(address);
            this.phone = phone;
        }

        public AccountMappingWrapper(HCP_To_FRM_HCO_Mapping_gne__c htfhm, Double hcoAddrLat, Double hcoAddrLon) {
            this.id = htfhm.Id;
            this.hcpId = htfhm.HCP_Account_gne__c;
            this.hcpName = htfhm.HCP_Account_gne__r.Formatted_Name_vod__c;
            this.active = String.isNotBlank(htfhm.HCP_Account_gne__r.MDMID_Status_gne__c) ? htfhm.HCP_Account_gne__r.MDMID_Status_gne__c : 'Active';
            this.addressId = htfhm.HCP_Address_gne__c;
            this.fullAddressName = getFullAddressName(htfhm);
            this.phone = htfhm.HCP_Account_gne__r.Phone;
            this.products = htfhm.Products_gne__c;
            this.createdDate = htfhm.HCP_Account_gne__r.CreatedDate;
            this.ownerId = htfhm.HCP_Account_gne__r.CreatedById;
            this.ownerName = htfhm.HCP_Account_gne__r.CreatedBy.Name;
            this.latitude = htfhm.HCP_Address_gne__r.Location_gne__Latitude__s;
            this.longitude = htfhm.HCP_Address_gne__r.Location_gne__Longitude__s;
            if (this.latitude != null && this.longitude != null && hcoAddrLat != null && hcoAddrLon != null) {
                this.distance = getDistanceFromHCO(Double.valueOf(this.latitude), Double.valueOf(this.longitude), hcoAddrLat, hcoAddrLon);
            }
            this.pactId = htfhm.PACT_Prescriber_Id_gne__c;
            this.pactAddrId = htfhm.PACT_Prescriber_Address_Id_gne__c;
            this.isHidden = htfhm.IsHidden_gne__c;
        }

        public AccountMappingWrapper(Address_vod__c addr) {
            this.id = addr.Account_vod__c;
            this.hcpId = addr.Account_vod__c;
            this.hcpName = addr.Account_vod__r.Formatted_Name_vod__c;
            this.active = String.isNotBlank(addr.Account_vod__r.MDMID_Status_gne__c) ? addr.Account_vod__r.MDMID_Status_gne__c : 'Active';
            this.addressId = addr.Id;
            this.fullAddressName = getFullAddressName(addr);
            this.phone = addr.Account_vod__r.Phone;
            this.latitude = addr.Location_gne__Latitude__s;
            this.longitude = addr.Location_gne__Longitude__s;
        }

        public Double getDistanceFromHCO(Double lat1, Double lon1, Double lat2, Double lon2) {
            return GlobalUtils.twoPointsDistance(lat1, lon1, lat2, lon2, false);
        }

        public String getFullAddressName(HCP_To_FRM_HCO_Mapping_gne__c htfhm) {
            String result = '';

            if (String.isNotBlank(htfhm.HCP_Address_gne__r.Name)) {
                result += htfhm.HCP_Address_gne__r.Name;
            }

            if (String.isNotBlank(htfhm.HCP_Address_gne__r.Address_Line_2_vod__c)) {
                result += String.isNotBlank(result) ? (', ' + htfhm.HCP_Address_gne__r.Address_Line_2_vod__c) : htfhm.HCP_Address_gne__r.Address_Line_2_vod__c;
            }

            if (String.isNotBlank(htfhm.HCP_Address_gne__r.City_vod__c)) {
                result += String.isNotBlank(result) ? (', ' + htfhm.HCP_Address_gne__r.City_vod__c) : htfhm.HCP_Address_gne__r.City_vod__c;
            }

            if (String.isNotBlank(htfhm.HCP_Address_gne__r.State_vod__c)) {
                result += String.isNotBlank(result) ? (', ' + htfhm.HCP_Address_gne__r.State_vod__c) : htfhm.HCP_Address_gne__r.State_vod__c;
            }

            if (String.isNotBlank(htfhm.HCP_Address_gne__r.Zip_vod__c)) {
                result += String.isNotBlank(result) ? (' ' + htfhm.HCP_Address_gne__r.Zip_vod__c) : htfhm.HCP_Address_gne__r.Zip_vod__c;
            }

            return result;
        }

        public String getFullAddressName(Address_vod__c addr) {
            String result = '';

            if (String.isNotBlank(addr.Name)) {
                result += addr.Name;
            }

            if (String.isNotBlank(addr.Address_Line_2_vod__c)) {
                result += String.isNotBlank(result) ? (', ' + addr.Address_Line_2_vod__c) : addr.Address_Line_2_vod__c;
            }

            if (String.isNotBlank(addr.City_vod__c)) {
                result += String.isNotBlank(result) ? (', ' + addr.City_vod__c) : addr.City_vod__c;
            }

            if (String.isNotBlank(addr.State_vod__c)) {
                result += String.isNotBlank(result) ? (', ' + addr.State_vod__c) : addr.State_vod__c;
            }

            if (String.isNotBlank(addr.Zip_vod__c)) {
                result += String.isNotBlank(result) ? (' ' + addr.Zip_vod__c) : addr.Zip_vod__c;
            }

            return result;
        }

    }

    public class FRMHCOWrapper {
        public String id;
        public String name;
        public String street;
        public String suite;
        public String city;
        public String state;
        public String zip;
        public String active;
        public String fullAddressName;
        public String phone;

        public FRMHCOWrapper() {
        }

        public FRMHCOWrapper(Account acct, Address_vod__c addr) {
            this.id = acct.Id;
            this.name = acct.Name;
            this.street = addr.Name;
            this.suite = addr.Address_Line_2_vod__c;
            this.city = addr.City_vod__c;
            this.state = addr.State_vod__c;
            this.zip = addr.Zip_vod__c;
            this.fullAddressName = getFullAddressName(addr);
            this.active = String.isNotBlank(acct.MDMID_Status_gne__c) ? acct.MDMID_Status_gne__c : 'Active';
            this.phone = acct.Phone;
        }

        public String getFullAddressName(Address_vod__c addr) {
            String result = '';

            if (String.isNotBlank(addr.Name)) {
                result += addr.Name;
            }

            if (String.isNotBlank(addr.Address_Line_2_vod__c)) {
                result += String.isNotBlank(result) ? (', ' + addr.Address_Line_2_vod__c) : addr.Address_Line_2_vod__c;
            }

            if (String.isNotBlank(addr.City_vod__c)) {
                result += String.isNotBlank(result) ? (', ' + addr.City_vod__c) : addr.City_vod__c;
            }

            if (String.isNotBlank(addr.State_vod__c)) {
                result += String.isNotBlank(result) ? (', ' + addr.State_vod__c) : addr.State_vod__c;
            }

            if (String.isNotBlank(addr.Zip_vod__c)) {
                result += String.isNotBlank(result) ? (' ' + addr.Zip_vod__c) : addr.Zip_vod__c;
            }

            return result;
        }
    }
}