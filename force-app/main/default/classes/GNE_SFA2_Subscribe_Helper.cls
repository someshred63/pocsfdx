public without sharing class GNE_SFA2_Subscribe_Helper extends CORE_Subscribe_Base implements CORE_Subscribe_Interface.Record_Retriever, CORE_Subscribe_Interface.Validator {

    private static final String DCH_WINNER_STATUS = 'Winner';
    private static final String RECORD_TYPE_NAME_LICENSE_CR = 'License/Sampleability Info';

    private Map<String, Set<String>>sfcdIdToPartyId;
    private Map<String, Set<String>>partyIdToSfdcId;

    private Map<String, Set<String>>mdmIdToPartyId;
    private Map<String, Set<String>>partyIdToMdmId;

    private Map<String, Set<String>>partyLocIdToSfdcIds;
    private Map<String, Set<String>>sfcdIdToPartyLocId;
    private Map<String, Set<String>>partyLocIdToMdmId;
    private Map<String, Set<String>>mdmIdToPartyLocId;

    private Map<String, Account>sfdcIdToAccount;
    private Map<String, Account>mdmIdToAccount;
    private Map<String, Address_vod__c>sfdcIdToAddress;
    private Map<String, Address_vod__c>mdmIdToAddress;

    protected Map<String, Map<String, Set<String>>> partyIdToIdMap;
    protected Map<String, Map<String, Set<String>>> partyLocIdToIdMap;
    protected Map<Id, List<CORE_Pub_Location__c>> partyToLocations;

    private Map<Id, List<Address_vod__c>> accountIdToAddresses = new Map<Id, List<Address_vod__c>>();

    private Boolean isInitialized;

    public GNE_SFA2_Subscribe_Helper() {

        partyIdToIdMap = new Map<String, Map<String, Set<String>>>();
        partyLocIdToIdMap = new Map<String, Map<String, Set<String>>>();

        sfcdIdToPartyId = new Map<String, Set<String>>();
        partyIdToSfdcId = new Map<String, Set<String>>();
        mdmIdToPartyId = new Map<String, Set<String>>();
        partyIdToMdmId = new Map<String, Set<String>>();

        partyLocIdToSfdcIds = new Map<String, Set<String>>();
        sfcdIdToPartyLocId = new Map<String, Set<String>>();
        partyLocIdToMdmId = new Map<String, Set<String>>();
        mdmIdToPartyLocId = new Map<String, Set<String>>();

        sfdcIdToAccount = new Map<String, Account>();
        mdmIdToAccount = new Map<String, Account>();

        sfdcIdToAddress = new Map<String, Address_vod__c>();
        mdmIdToAddress = new Map<String, Address_vod__c>();
        isInitialized = false;
    }

    public void init(List<CORE_Pub_Party__c>parties, Map<Id, List<CORE_Pub_External_Id__c>> partyToExtIds, Map<Id, List<CORE_Pub_Location__c>> partyToLocations, Map<Id, List<CORE_Pub_Plan_Product__c>>partyToProdPlans) {
        if (!isInitialized) {
            this.partyToLocations = partyToLocations;
            for (CORE_Pub_Party__c party : parties) {
                if (partyToExtIds != null && partyToExtIds.containsKey(party.Id)) {
                    for (CORE_Pub_External_Id__c extId : partyToExtIds.get(party.Id)) {
                        if (extId.Cnncl_Enty_Type_gne__c == CNNCL_PARTY) {
                            if (!partyIdToIdMap.containsKey(extId.Party_Id_ref_gne__c)) {
                                partyIdToIdMap.put(extId.Party_Id_ref_gne__c, new Map<String, Set<String>>());
                            }
                            Map<String, Set<String>>ctrbSourceToIds = partyIdToIdMap.get(extId.Party_Id_ref_gne__c);
                            if (!ctrbSourceToIds.containsKey(extId.Ctrb_Src_gne__c)) {
                                ctrbSourceToIds.put(extId.Ctrb_Src_gne__c, new Set<String>());
                            }
                            ctrbSourceToIds.get(extId.Ctrb_Src_gne__c).add(extId.Ctrb_Src_Id_gne__c);
                        } else if (extId.Cnncl_Enty_Type_gne__c == CNNCL_PARTY_LOC) {
                            if (!partyLocIdToIdMap.containsKey(extId.Party_Location_Id_ref_gne__c)) {
                                partyLocIdToIdMap.put(extId.Party_Location_Id_ref_gne__c, new Map<String, Set<String>>());
                            }

                            Map<String, Set<String>> ctrbSourceToIds = partyLocIdToIdMap.get(extId.Party_Location_Id_ref_gne__c);
                            if (!ctrbSourceToIds.containsKey(extId.Ctrb_Src_gne__c)) {
                                ctrbSourceToIds.put(extId.Ctrb_Src_gne__c, new Set<String>());
                            }
                            ctrbSourceToIds.get(extId.Ctrb_Src_gne__c).add(extId.Ctrb_Src_Id_gne__c);
                        }

                        if (extId.Cnncl_Enty_Type_gne__c == CNNCL_PARTY && extId.Ctrb_Src_gne__c == SFDC_CTRB_SOURCE_CODE) {
                            if (!partyIdToSfdcId.containsKey(party.Id)) {
                                partyIdToSfdcId.put(party.Id, new Set<String>());
                            }
                            partyIdToSfdcId.get(party.Id).add(extId.Ctrb_Src_Id_gne__c);

                            if (!sfcdIdToPartyId.containsKey(extId.Ctrb_Src_Id_gne__c)) {
                                sfcdIdToPartyId.put(extId.Ctrb_Src_Id_gne__c, new Set<String>());
                            }
                            sfcdIdToPartyId.get(extId.Ctrb_Src_Id_gne__c).add(party.Id);

                        } else if (extId.Cnncl_Enty_Type_gne__c == CNNCL_PARTY && extId.Ctrb_Src_gne__c == MDM_CTRB_SOURCE_CODE) {
                            if (!partyIdToMdmId.containsKey(party.Id)) {
                                partyIdToMdmId.put(party.Id, new Set<String>());
                            }
                            partyIdToMdmId.get(party.Id).add(extId.Ctrb_Src_Id_gne__c);

                            if (!mdmIdToPartyId.containsKey(extId.Ctrb_Src_Id_gne__c)) {
                                mdmIdToPartyId.put(extId.Ctrb_Src_Id_gne__c, new Set<String>());
                            }
                            mdmIdToPartyId.get(extId.Ctrb_Src_Id_gne__c).add(party.Id);
                        } else if (extId.Cnncl_Enty_Type_gne__c == CNNCL_PARTY_LOC && extId.Ctrb_Src_gne__c == SFDC_CTRB_SOURCE_CODE) {
                            if (!partyLocIdToSfdcIds.containsKey(extId.Party_Location_Id_ref_gne__c)) {
                                partyLocIdToSfdcIds.put(extId.Party_Location_Id_ref_gne__c, new Set<String>());
                            }
                            partyLocIdToSfdcIds.get(extId.Party_Location_Id_ref_gne__c).add(extId.Ctrb_Src_Id_gne__c);

                            if (!sfcdIdToPartyLocId.containsKey(extId.Ctrb_Src_Id_gne__c)) {
                                sfcdIdToPartyLocId.put(extId.Ctrb_Src_Id_gne__c, new Set<String>());
                            }
                            sfcdIdToPartyLocId.get(extId.Ctrb_Src_Id_gne__c).add(party.Id);
                        } else if (extId.Cnncl_Enty_Type_gne__c == CNNCL_PARTY_LOC && extId.Ctrb_Src_gne__c == MDM_CTRB_SOURCE_CODE) {
                            if (!partyLocIdToMdmId.containsKey(extId.Party_Location_Id_ref_gne__c)) {
                                partyLocIdToMdmId.put(extId.Party_Location_Id_ref_gne__c, new Set<String>());
                            }
                            partyLocIdToMdmId.get(extId.Party_Location_Id_ref_gne__c).add(extId.Ctrb_Src_Id_gne__c);

                            if (!mdmIdToPartyLocId.containsKey(extId.Ctrb_Src_Id_gne__c)) {
                                mdmIdToPartyLocId.put(extId.Ctrb_Src_Id_gne__c, new Set<String>());
                            }
                            mdmIdToPartyLocId.get(extId.Ctrb_Src_Id_gne__c).add(party.Id);
                        }
                    }
                }
            }

            List<Account> accounts = fetchAccounts(sfcdIdToPartyId.keySet(), mdmIdToPartyId.keySet());
            Set<Id> accountIds = new Set<Id>();
            for (Account acc : accounts) {
                sfdcIdToAccount.put(acc.Id, acc);
                if (acc.MDMID_gne__c != null) {
                    mdmIdToAccount.put(acc.MDMID_gne__c, acc);
                }
                accountIds.add(acc.Id);
            }
            for (Address_vod__c address : fetchAddresses(accountIds)) {
                if (!accountIdToAddresses.containsKey(address.Account_vod__c)) {
                    accountIdToAddresses.put(address.Account_vod__c, new List<Address_vod__c>());
                }
                accountIdToAddresses.get(address.Account_vod__c).add(address);
            }

            for (Address_vod__c address : fetchAddresses(sfcdIdToPartyLocId.keySet(), mdmIdToPartyLocId.keySet())) {
                sfdcIdToAddress.put(address.Id, address);
                if (address.MDM_Address_ID_gne__c != null) {
                    mdmIdToAddress.put(address.MDM_Address_ID_gne__c, address);
                }
            }

            isInitialized = true;
        }
    }

    public CORE_Subscribe_Interface.ExistingRecodsWrapper getExistingObjects(CORE_Pub_Party__c parentParty, List<SObject> publishRecords, CORE_Subscribe_Mapping_Configuration__c configuration, Set<SObject>subscribeRecords) {
        CORE_Subscribe_Interface.ExistingRecodsWrapper result;
        if (configuration.Target_Object_gne__c.equalsIgnoreCase('Prescriber_License_gne__c')) {
            result = getExistingLicenses(parentParty, (List<CORE_Pub_License__c>) publishRecords, subscribeRecords);
        } else if (configuration.Target_Object_gne__c.equalsIgnoreCase('TDDD_License_gne__c')) {
            result = getExistingLicenses(parentParty, (List<CORE_Pub_TDDD_License__c>) publishRecords, subscribeRecords);
        }
        return result;
    }

    public List<SObject> getExistingObjects(CORE_Pub_Party__c parentParty, SObject publishRecord, CORE_Subscribe_Mapping_Configuration__c configuration, Set<SObject>subscribeRecords) {
        List<SObject>result;
        if ((publishRecord instanceof CORE_Pub_Party__c) && configuration.Target_Object_gne__c.equalsIgnoreCase('Account')) {
            result = getExistingAccounts((CORE_Pub_Party__c) publishRecord, UPDATE_ON_MDM_ID);
        } else if ((publishRecord instanceof CORE_Pub_Location__c) && configuration.Target_Object_gne__c.equalsIgnoreCase('Address_vod__c')) {
            result = getExistingAddresses(parentParty, (CORE_Pub_Location__c) publishRecord, UPDATE_ON_MDM_ID);
        } else if ((publishRecord instanceof CORE_Pub_License__c) && configuration.Target_Object_gne__c.equalsIgnoreCase('Address_vod__c')) {
            result = getExistingAddressesForLicense(parentParty, (CORE_Pub_License__c) publishRecord, subscribeRecords);
        } else if ((publishRecord instanceof CORE_Pub_License__c) && configuration.Target_Object_gne__c.equalsIgnoreCase('Prescriber_License_gne__c')) {
            result = getExistingLicenses(parentParty, (CORE_Pub_License__c) publishRecord, subscribeRecords);
        } else if ((publishRecord instanceof CORE_Pub_TDDD_License__c) && configuration.Target_Object_gne__c.equalsIgnoreCase('TDDD_License_gne__c')) {
            result = getExistingLicenses(parentParty, (CORE_Pub_TDDD_License__c) publishRecord, subscribeRecords);
        } else if ((publishRecord instanceof CORE_Pub_External_Id__c) && configuration.Target_Object_gne__c.equalsIgnoreCase('Address_External_Id_gne__c')) {
            result = getExistingAddressesExternalIds(parentParty, (CORE_Pub_External_Id__c) publishRecord, subscribeRecords);
        } else if ((publishRecord instanceof CORE_Pub_External_Id__c) && configuration.Target_Object_gne__c.equalsIgnoreCase('Account_External_Id_gne__c')) {
            result = getExistingAccountExternalIds(parentParty, (CORE_Pub_External_Id__c) publishRecord, subscribeRecords);
        } else {
            result = new List<SObject>();
        }
        return result;
    }

    private List<SObject> getExistingLicenses(CORE_Pub_Party__c party, CORE_Pub_License__c publishLicense, Set<SObject>subscribeRecords) {
        List<SObject> result = new List<SObject>();
        List<Account> accounts = getExistingAccounts(party, false);
        if (accounts != null && !accounts.isEmpty()) {
            for (Prescriber_License_gne__c license : accounts.get(0).Licenses__r) {
                if (license.Name == publishLicense.License_Number_gne__c) {
                    result.add(license);
                }
            }
        }
        return result;
    }

    private List<SObject> getExistingLicenses(CORE_Pub_Party__c party, CORE_Pub_TDDD_License__c publishLicense, Set<SObject>subscribeRecords) {
        List<SObject> result = new List<SObject>();
        List<Account> accounts = getExistingAccounts(party, false);
        if (accounts != null && !accounts.isEmpty()) {
            for (TDDD_License_gne__c license : accounts.get(0).TDDD_Licenses__r) {
                if (license.Name == publishLicense.License_Number_gne__c) {
                    result.add(license);
                }
            }
        }
        return result;
    }

    private CORE_Subscribe_Interface.ExistingRecodsWrapper getExistingLicenses(CORE_Pub_Party__c party, List<CORE_Pub_License__c> publishLicenses, Set<SObject>subscribeRecords) {
        CORE_Subscribe_Interface.ExistingRecodsWrapper result = new CORE_Subscribe_Interface.ExistingRecodsWrapper();
        Map<String, Prescriber_License_gne__c> licNumToLic = new Map<String, Prescriber_License_gne__c>();

        List<Account> accounts = getExistingAccounts(party, false);

        if (!accounts.isEmpty()) {
            for (Prescriber_License_gne__c license : accounts.get(0).Licenses__r) {
                licNumToLic.put(license.Name, license);
            }
        }

        for (CORE_Pub_License__c license : publishLicenses) {
            if (!result.existingRecords.containsKey(license.License_Number_gne__c) && licNumToLic.containsKey(license.License_Number_gne__c)) {
                result.existingRecords.put(license.License_Number_gne__c, new List<SObject>());
                result.existingRecords.get(license.License_Number_gne__c).add(licNumToLic.remove(license.License_Number_gne__c));
            }
        }
        result.notMatchingRecords.addAll((List<SObject>) licNumToLic.values());
        return result;
    }

    private CORE_Subscribe_Interface.ExistingRecodsWrapper getExistingLicenses(CORE_Pub_Party__c party, List<CORE_Pub_TDDD_License__c> publishLicenses, Set<SObject>subscribeRecords) {
        CORE_Subscribe_Interface.ExistingRecodsWrapper result = new CORE_Subscribe_Interface.ExistingRecodsWrapper();
        Map<String, TDDD_License_gne__c> licNumToLic = new Map<String, TDDD_License_gne__c>();

        List<Account> accounts = getExistingAccounts(party, false);

        if (!accounts.isEmpty()) {
            for (TDDD_License_gne__c license : accounts.get(0).TDDD_Licenses__r) {
                licNumToLic.put(license.Name, license);
            }
        }

        for (CORE_Pub_TDDD_License__c license : publishLicenses) {
            if (!result.existingRecords.containsKey(license.License_Number_gne__c) && licNumToLic.containsKey(license.License_Number_gne__c)) {
                result.existingRecords.put(license.License_Number_gne__c, new List<SObject>());
                result.existingRecords.get(license.License_Number_gne__c).add(licNumToLic.remove(license.License_Number_gne__c));
            }
        }
        result.notMatchingRecords.addAll((List<SObject>) licNumToLic.values());
        return result;
    }

    private List<SObject> getExistingAccounts(CORE_Pub_Party__c party, Boolean retrieveUsingMdmId) {
        List<SObject>result = new List<SObject>();
        if (partyIdToSfdcId.containsKey(party.Id)) {
            List<String>sfdcIds = new List<String>(partyIdToSfdcId.get(party.Id));
            if (sfdcIds.size() == 1 && sfdcIdToAccount.containsKey(sfdcIds.get(0))) {
                result.add(sfdcIdToAccount.get(sfdcIds.get(0)));
            } else if (sfdcIds.size() > 1) {
                result.add(selectWinnerAccount(party, sfdcIds));
            }
        } else if (retrieveUsingMdmId) {
            if (partyIdToMdmId.containsKey(party.Id)) {
                List<String>mdmIds = new List<String>(partyIdToMdmId.get(party.Id));
                for (String mdmId : mdmIds) {
                    if (mdmIdToAccount.containsKey(mdmId)) {
                        Account acc = mdmIdToAccount.get(mdmId);
                        if (!partyIdToSfdcId.containsKey(party.Id)) {
                            partyIdToSfdcId.put(party.Id, new Set<String>());
                        }
                        partyIdToSfdcId.get(party.Id).add(acc.Id);
                    }
                }
            }
            result = getExistingAccounts(party, false);
        }
        return result;
    }

    private List<SObject>getExistingAddresses(CORE_Pub_Party__c party, CORE_Pub_Location__c partyLocation, Boolean retrieveUsingMdmId) {
        List<SObject>result = new List<SObject>();
        List<Account> accounts = getExistingAccounts(party, UPDATE_ON_MDM_ID);
        if (!accounts.isEmpty()) {  //if not new account
            Account account = accounts.get(0);
            if (partyLocIdToSfdcIds.containsKey(partyLocation.Id)) {
                List<String>sfdcIds = new List<String>(partyLocIdToSfdcIds.get(partyLocation.Id));
                if (sfdcIds.size() == 1 && sfdcIdToAddress.containsKey(sfdcIds.get(0))) {
                    Address_vod__c address = sfdcIdToAddress.get(sfdcIds.get(0));
                    if (address.Account_vod__c == account.Id) {
                        result.add(sfdcIdToAddress.get(sfdcIds.get(0)));
                    }
                } else if (sfdcIds.size() > 1) {
                    Address_vod__c address = selectWinnerAddress(partyLocation, sfdcIds, account);
                    if (address != null) {
                        result.add(selectWinnerAddress(partyLocation, sfdcIds, account));
                    }
                }
            } else if (retrieveUsingMdmId) {
                if (partyLocIdToMdmId.containsKey(partyLocation.Id)) {
                    List<String>mdmIds = new List<String>(partyLocIdToMdmId.get(partyLocation.Id));
                    for (String mdmId : mdmIds) {
                        if (mdmIdToAddress.containsKey(mdmId)) {
                            Address_vod__c address = mdmIdToAddress.get(mdmId);
                            if (!partyLocIdToSfdcIds.containsKey(partyLocation.Id)) {
                                partyLocIdToSfdcIds.put(partyLocation.Id, new Set<String>());
                            }
                            partyLocIdToSfdcIds.get(partyLocation.Id).add(address.Id);
                        }
                    }
                }
                result = getExistingAddresses(party, partyLocation, false);
            }
        }
        return result;
    }

    private List<SObject>getExistingAddressesForLicense(CORE_Pub_Party__c party, CORE_Pub_License__c publishLicense, Set<SObject>subscribeRecords) {
        List<SObject>result = new List<SObject>();
        List<Account> accounts = getExistingAccounts(party, false);
        Set<String>uniqueId = new Set<String>();

        if (subscribeRecords != null) {
            for (SObject obj : subscribeRecords) {
                Address_vod__c address = (Address_vod__c) obj;
                if (address.State_vod__c == publishLicense.License_State_gne__c && uniqueId.add(address.Id)) {
                    result.add(address);
                }
            }
        }
        if (!accounts.isEmpty()) {  //if not new account
            List<Address_vod__c> addresses = accountIdToAddresses.get(accounts.get(0).Id);
            if (addresses != null) {
                for (Address_vod__c address : addresses) {
                    if (address.State_vod__c == publishLicense.License_State_gne__c && uniqueId.add(address.Id)) {
                        result.add(address);
                    }
                }
            }
        }
        return result;
    }

    private List<SObject>getExistingAccountExternalIds(CORE_Pub_Party__c party, CORE_Pub_External_Id__c publishExtId, Set<SObject>subscribeRecords) {
        List<SObject>result = new List<SObject>();
        List<Account> accounts = getExistingAccounts(party, false);

        if (!accounts.isEmpty()) {  //if not new account
            for (Account_External_Id_gne__c extId : accounts.get(0).Account_External_ID_gne__r) {
                if (publishExtId.Ctrb_Src_Id_gne__c == extId.Third_Party_Id_gne__c && !subscribeRecords.contains(extId)) {
                    result.add(extId);
                    break;
                }
            }
        }
        return result;
    }

    private List<SObject>getExistingAddressesExternalIds(CORE_Pub_Party__c party, CORE_Pub_External_Id__c publishExtId, Set<SObject>subscribeRecords) {
        List<SObject>result = new List<SObject>();

        CORE_Pub_Location__c location;
        if (partyToLocations.containsKey(party.Id)) {
            for (CORE_Pub_Location__c loc : partyToLocations.get(party.Id)) {
                if (publishExtId.Party_Location_Id_ref_gne__c == loc.Id) {
                    location = loc;
                    break;
                }
            }
        }
        if (location != null) {
            List<SObject>addresses = getExistingAddresses(party, location, UPDATE_ON_MDM_ID);
            if (!addresses.isEmpty()) {
                Address_vod__c address = (Address_vod__c) addresses.get(0);
                for (Address_External_Id_gne__c extId : address.R00N70000002Gy6UEAS) {
                    if (publishExtId.Ctrb_Src_Id_gne__c == extId.Third_Party_Id_gne__c && !subscribeRecords.contains(publishExtId)) {
                        result.add(extId);
                        break;
                    }
                }
            }
        }
        return result;
    }

    /**
    * Selects winner account in case of multiple SFDC XRef (Merge scenario)
    */
    private Account selectWinnerAccount(CORE_Pub_Party__c party, List<String> sfdcIds) {
        Account winnerAccount;
        List<Datetime> createdDateList = new List<Datetime>();
        Map<Datetime, String> createdDateToAccountIdMap = new Map<Datetime, String>();

        if (partyIdToMdmId.containsKey(party.Id) && partyIdToMdmId.get(party.Id).size() == 1) {
            String mdmId = new List<String>(partyIdToMdmId.get(party.Id)).get(0);
            for (String sfdcId : sfdcIds) {
                if (sfdcIdToAccount.containsKey(sfdcId)) {
                    createdDateList.add(sfdcIdToAccount.get(sfdcId).CreatedDate);
                    createdDateToAccountIdMap.put(sfdcIdToAccount.get(sfdcId).CreatedDate, sfdcId);
                    if (winnerAccount == null && sfdcIdToAccount.get(sfdcId).MDMID_gne__c == mdmId) {
                        winnerAccount = sfdcIdToAccount.get(sfdcId);
                    }
                }
            }
            if (winnerAccount == null) {
                createdDateList.sort();
                winnerAccount = sfdcIdToAccount.get(createdDateToAccountIdMap.get(createdDateList[0]));
            }
        }
        if (winnerAccount != null) {
            // Prepare records for merge (mark the winner)
            winnerAccount.DCH_Action_gne__c = DCH_WINNER_STATUS;
        }
        return winnerAccount;
    }

    /**
   * Selects winner address in case of multiple SFDC XRef (Merge scenario)
   */
    private Address_vod__c selectWinnerAddress(CORE_Pub_Location__c ptyLoc, List<String> sfdcIds, Account account) {
        Address_vod__c winnerAddress;
        List<Datetime> createdDateList = new List<Datetime>();
        Map<Datetime, String> createdDateToAddressIdMap = new Map<Datetime, String>();

        if (partyLocIdToMdmId.containsKey(ptyLoc.Id) && partyLocIdToMdmId.get(ptyLoc.Id).size() == 1) {
            String mdmId = new List<String>(partyLocIdToMdmId.get(ptyLoc.Id)).get(0);
            for (String sfdcId : sfdcIds) {
                if (sfdcIdToAddress.containsKey(sfdcId)) {
                    Address_vod__c address = sfdcIdToAddress.get(sfdcId);
                    if (address.Account_vod__c == account.Id) {
                        createdDateList.add(sfdcIdToAddress.get(sfdcId).CreatedDate);
                        createdDateToAddressIdMap.put(sfdcIdToAddress.get(sfdcId).CreatedDate, sfdcId);
                        if (winnerAddress == null && sfdcIdToAddress.get(sfdcId).MDM_Address_ID_gne__c == mdmId) {
                            winnerAddress = sfdcIdToAddress.get(sfdcId);
                        }
                    }
                }
            }
            if (winnerAddress == null && !createdDateList.isEmpty()) {
                createdDateList.sort();
                winnerAddress = sfdcIdToAddress.get(createdDateToAddressIdMap.get(createdDateList[0]));
                winnerAddress.DCH_Action_gne__c = DCH_WINNER_STATUS;
            }
        }
        return winnerAddress;
    }

    /*Validation */
    public Map<Id, CORE_Subscribe_Error__c> validate(List<CORE_Pub_Party__c>parties, Map<Id, List<CORE_Pub_External_Id__c>>partyToExtIds, Map<Id, List<CORE_Pub_Location__c>> partyToLocations, Map<Id, List<CORE_Pub_Plan_Product__c>>partyToProdPlans, SubscribeMode mode) {
        Map<Id, CORE_Subscribe_Error__c>validationErrors = new Map<Id, CORE_Subscribe_Error__c>();

        init(parties, partyToExtIds, partyToLocations, partyToProdPlans);

        for (CORE_Pub_Party__c party : parties) {
            try {
                CORE_Subscribe_Error__c error = validateParty(party, partyIdToIdMap.get(party.Id), mode);
                if (error == null) {
                    if (partyToLocations.containsKey(party.Id)) {
                        for (CORE_Pub_Location__c loc : partyToLocations.get(party.id)) {
                            error = validatePartyLocation(loc, partyLocIdToIdMap.get(loc.Id), mode);
                            if (error != null) {
                                break;
                            }
                        }
                    }
                }
                //party should have exactly one active location marked as default
                if (error == null && !partyIdToIdMap.get(party.Id).containsKey(SFDC_CTRB_SOURCE_CODE) && mode != SubscribeMode.ASI) {
                    error = validatePartyLocationsDefaultFlag(party);
                }
                if (error != null) {
                    validationErrors.put(party.Id, error);
                }
            } catch (Exception e) {
                CORE_Subscribe_Error__c error = createError('CORE_Pub_Party__c', party.Id, e.getLineNumber() + ': ' + e.getMessage() + '\n' + e.getStackTraceString(), 'Runtime');
                validationErrors.put(party.Id, error);
            }
        }
        return validationErrors;
    }

    /**
   * Verifies if a given party is valid;
   * party - cads party record
   * ctrbSourceToIds - ctrbSource -> ids
   * return null if party is valid otherwise error object
   */
    private CORE_Subscribe_Error__c validateParty(CORE_Pub_Party__c party, Map<String, Set<String>>ctrbSourceToIds, SubscribeMode mode) {
        Boolean isValid = true;
        String sErrorMessage = '';

        // Party type must be either Individual or Organization
        if (isValid && party.Type_gne__c != PARTY_TYPE_INDIVIDUAL_CODE && party.Type_gne__c != PARTY_TYPE_ORGANIZATION_CODE) {
            isValid = false;
            sErrorMessage = 'Party type must be either Individual or Organization. Current party type code: ' + party.Type_gne__c;
        }
        // For a party to be valid it must have one active MDM ID
        if (isValid && (ctrbSourceToIds == null || !ctrbSourceToIds.containsKey(MDM_CTRB_SOURCE_CODE) || ctrbSourceToIds.get(MDM_CTRB_SOURCE_CODE).size() != 1)) {
            isValid = false;
            sErrorMessage = 'Party must have one active MDM ID';
        }

        // No more then one AMS ID is allowed
        if (isValid && ctrbSourceToIds.containsKey(AMS_CTRB_SOURCE_CODE) && ctrbSourceToIds.get(AMS_CTRB_SOURCE_CODE).size() > 1) {
            isValid = false;
            sErrorMessage = 'Party has more than one active AMS ID';
        }

        // The account/s must exist in the system as indicated by the SFDC xrefs             
        if (isValid && ctrbSourceToIds.containsKey(SFDC_CTRB_SOURCE_CODE) && ctrbSourceToIds.get(SFDC_CTRB_SOURCE_CODE).size() > 0) {
            for (String sfdcId : ctrbSourceToIds.get(SFDC_CTRB_SOURCE_CODE)) {
                if (!sfdcIdToAccount.containsKey(sfdcId)) {
                    sErrorMessage = 'Account does not exist in the system as indicated by party SFDC XRef';
                    isValid = false;
                    break;
                }
            }
        }

        // Party have to be contributed by approved systems (but not for ASI) - this rule is valid only for new accounts
        if (isValid && mode != SubscribeMode.ASI) {
            if (ctrbSourceToIds.get(SFDC_CTRB_SOURCE_CODE) == null || ctrbSourceToIds.get(SFDC_CTRB_SOURCE_CODE).isEmpty()) {
                isValid = isContributedBySource(CREATE_ACCOUNT_XREF, ctrbSourceToIds.keySet());
                if (!isValid) {
                    sErrorMessage = 'Party is not contributed by approved sources';
                }
            }
        }

        // If there is an account in the system having party MDM Id but there is no SFDC XRef in staging
        // use 'EnableUpdateOnMDMId' custom setting to determine whether either to perform 
        // an update using MDM ID or log an exception        
        if (isValid && !ctrbSourceToIds.containsKey(SFDC_CTRB_SOURCE_CODE) &&          // Party does not exist in SFDC 
                ctrbSourceToIds.containsKey(MDM_CTRB_SOURCE_CODE) && ctrbSourceToIds.get(MDM_CTRB_SOURCE_CODE).size() == 1) {
            String mdmId = new List<String>(ctrbSourceToIds.get(MDM_CTRB_SOURCE_CODE)).get(0);
            if (mdmIdToAccount.containsKey(mdmId)) {
                if (UPDATE_ON_MDM_ID) {
                    String sfdcId = mdmIdToAccount.get(mdmId).Id;
                    if (ctrbSourceToIds.containsKey(SFDC_CTRB_SOURCE_CODE)) {
                        ctrbSourceToIds.get(SFDC_CTRB_SOURCE_CODE).add(sfdcId);
                    } else {
                        ctrbSourceToIds.put(SFDC_CTRB_SOURCE_CODE, new Set<String>{
                                sfdcId
                        });
                    }
                } else {
                    isValid = false;
                    sErrorMessage = 'Party does not have active SFDC XRef however there is already SFDC account in the system having the party MDM ID: ' + mdmId;
                }
            }
        }

        // There should be only one active Organization Role Record
        if (isValid && (party.Type_gne__c == PARTY_TYPE_ORGANIZATION_CODE)) {
            List<JsonCodeValueList>values = (List<JsonCodeValueList>) JSON.deserialize(party.Org_Type_json_gne__c, List<JsonCodeValueList>.class);
            // Add exception - There should be only one active Organization Role Record
            if (values.size() != 1) {
                isValid = false;
                sErrorMessage = 'Party should have one active Organization Role Record';
            }
            //  Add exception when Org Role Type to SFDC Record Type/Account Type mapping is missing or blank value is provided
            String sRoleCode = values.get(0).code;
            if (isValid && !String.isEmpty(sRoleCode)) {
                GNE_SFA2_Account_Trigger_Helper.AccountTypeWrapper accTypeWrapper = GNE_SFA2_Account_Trigger_Helper.getAccountTypesMap(GNE_SFA2_Account_Trigger_Helper.AccountTypeKeyType.CODE).get(sRoleCode.toUpperCase());

                if (accTypeWrapper == null) {
                    isValid = false;
                    sErrorMessage = 'Organization Role Type > SFDC Record Type/Account Type mapping is missing. Verify custom setting: CORE_Pub_Org_Typ_Map__c';
                } else if (accTypeWrapper.getRecordTypeId() == null) {
                    isValid = false;
                    sErrorMessage = 'SFDC Record Type as defined by Organization Role Mapping custom setting is missing in SFDC. Verify custom setting: CORE_Pub_Org_Typ_Map__c';
                }
            }
        }

        // party must have at least one active PTY Loc
        if (isValid && !ctrbSourceToIds.containsKey(SFDC_CTRB_SOURCE_CODE)) {
            Boolean hasActiveLocation = false;
            if (partyToLocations.containsKey(party.Id)) {
                for (CORE_Pub_Location__c partyLocation : partyToLocations.get(party.Id)) {
                    if (partyLocation.MDM_Status_gne__c == 'A') {
                        hasActiveLocation = true;
                    }
                }
            }
            if (!hasActiveLocation) {
                isValid = false;
                sErrorMessage = 'Party must have at least one active party location';
            }
        }
        if (!isValid) {
            return createError('CORE_Pub_Party__c', party.Id, sErrorMessage, 'Low');
        }
        return null;
    }

    /**
    * Verifies if a given party location is valid
    * partyLocation - - cads party locatin record
    * ctrbSourceToIds - ctrbSource -> ids
    */
    private CORE_Subscribe_Error__c validatePartyLocation(CORE_Pub_Location__c partyLocation, Map<String, Set<String>>ctrbSourceToIds, SubscribeMode mode) {
        Boolean isValid = true;
        String sErrorMessage = '';
        // For a party location to be valid it must have only one active MDM ID
        if (isValid && (ctrbSourceToIds == null || !ctrbSourceToIds.containsKey(MDM_CTRB_SOURCE_CODE) || (ctrbSourceToIds.containsKey(MDM_CTRB_SOURCE_CODE) && ctrbSourceToIds.get(MDM_CTRB_SOURCE_CODE).size() != 1))) {
            isValid = false;
            sErrorMessage = 'Party location (' + partyLocation.Id + ') must have one active MDM ID';
        }

        // If Party Location SFDC XRef is present => the address having party SFDC Id must exist in SFDC otherwise the party is not valid
        if (isValid && ctrbSourceToIds.containsKey(SFDC_CTRB_SOURCE_CODE) && ctrbSourceToIds.get(SFDC_CTRB_SOURCE_CODE).size() > 0) {
            for (String sfdcId : ctrbSourceToIds.get(SFDC_CTRB_SOURCE_CODE)) {
                if (!sfdcIdToAddress.containsKey(sfdcId)) {
                    isValid = false;
                    sErrorMessage = 'Address as indicated by party location XRef SFDC Id does not exist in the system';
                    break;
                }
            }
        }

        // If SFDC XRef is present => there can not be more then one active party location having the same SFDC XRef
        if (isValid && ctrbSourceToIds.containsKey(SFDC_CTRB_SOURCE_CODE) && ctrbSourceToIds.get(SFDC_CTRB_SOURCE_CODE).size() > 0) {
            for (String sfdcId : ctrbSourceToIds.get(SFDC_CTRB_SOURCE_CODE)) {
                if (sfcdIdToPartyLocId.get(sfdcId).size() > 1) {
                    isValid = false;
                    sErrorMessage = 'There can not be more then one active party location having the same SFDC XRef';
                }
            }
        }

        // Update based on MDM Id match
        if (UPDATE_ON_MDM_ID) {
            if (isValid && !ctrbSourceToIds.containsKey(SFDC_CTRB_SOURCE_CODE)) {
                String mdmAddrId = new List<String>(ctrbSourceToIds.get(MDM_CTRB_SOURCE_CODE)).get(0);
                Address_vod__c address = mdmIdToAddress.get(mdmAddrId);
                if (address != null) {
                    if (ctrbSourceToIds.containsKey(SFDC_CTRB_SOURCE_CODE)) {
                        ctrbSourceToIds.get(SFDC_CTRB_SOURCE_CODE).add(address.Id);
                    } else {
                        ctrbSourceToIds.put(SFDC_CTRB_SOURCE_CODE, new Set<String>{
                                address.Id
                        });
                    }
                }
            }
        }

        // If Party Location SFDC XRef is not present (the address is a candidate to be created)
        // check that there are no other addresses in the system having its MDM ID  
        if (isValid && !ctrbSourceToIds.containsKey(SFDC_CTRB_SOURCE_CODE) &&
                ctrbSourceToIds.containsKey(MDM_CTRB_SOURCE_CODE) && ctrbSourceToIds.get(MDM_CTRB_SOURCE_CODE).size() > 0) {

            String mdmId = new List<String>(ctrbSourceToIds.get(MDM_CTRB_SOURCE_CODE)).get(0);
            if (mdmIdToAddress.containsKey(mdmId)) {
                isValid = false;
                sErrorMessage = 'There are other addresses in the system having party location MDM ID.';
            }
        }
        if (!isValid) {
            return createError('CORE_Pub_Location__c', partyLocation.Id, sErrorMessage, 'Low');
        }
        return null;
    }

    /**
   * Exactly one location for party should be marked as default. Default location have to be active.
   */
    private CORE_Subscribe_Error__c validatePartyLocationsDefaultFlag(CORE_Pub_Party__c party) {
        String sErrorMessage;
        CORE_Pub_Location__c defaultLocation;
        if (partyToLocations.containsKey(party.Id)) {
            for (CORE_Pub_Location__c location : partyToLocations.get(party.Id)) {
                if (location.Default_gne__c && location.MDM_Status_gne__c == 'I') {
                    sErrorMessage = 'Default location has to be active.';
                    break;
                } else if (location.Default_gne__c && defaultLocation != null) {
                    sErrorMessage = 'Only one location can be marked as default.';
                    break;
                } else if (location.Default_gne__c && defaultLocation == null) {
                    defaultLocation = location;
                }
            }
        }
        if (defaultLocation == null && String.isEmpty(sErrorMessage)) {
            sErrorMessage = 'Exactly one location for party should be marked as default.';
        }
        if (String.isNotEmpty(sErrorMessage)) {
            return createError('CORE_Pub_Party__c', party.Id, sErrorMessage, 'Low');
        }
        return null;
    }

    /**
    * Verifies if party is contributed by specific source/s
    */
    private Boolean isContributedBySource(Set<String> contributedSources, Set<String> objectSources) {
        Boolean isContributed = false;
        for (String source : objectSources) {
            if (contributedSources.contains(source)) {
                isContributed = true;
                break;
            }
        }
        return isContributed;
    }

    /**
    * Retreives account hierarchy (accounts and associated addresses and external Ids) from 
    * the Account object for a given list of account SFDC Ids or MDM Ids
    */
    private List<Account> fetchAccounts(Set<String> accountIds, Set<String> mdmIds) {
        return [
                SELECT
                        Id,                         // SFDC Account Id
                        CreatedDate,                // SFDC Account Created Date
                        Account_Type_gne__c,        // Account Type (Clinic, Pharmacy, Health Case Professional etc.)
                        AMS_ID_gne__c,              // AMD ID
                        Cell_Phone_gne__c,          // Cell Phone Number
                        Credentials_gne__c,         // Credentials (BA, MS, PHD etc.)
                        Date_of_Birth_gne__c,       // Date of Birth
                        FirstName,                  // First Name
                        Gender_vod__c,              // Gender of the professional (Person Account) (M, F)
                        LastName,                   // Last Name
                        MDM_Update_Date_gne__c,     // DW Last Updated timestamp
                        MDMID_gne__c,               // MDM ID
                        MDMID_Status_gne__c,        // MDMID Status (Active, Inactive)
                        Status_gne__c,              // Status (Active, Dead, Retired, Inactive, Indeterminate)
                        Middle_vod__c,              // Middle name of the professional (Person Account)
                        NPI_vod__c,                 // National Provider Identifier for health care providers
                        Phone,                      // Phone
                        Professional_Type_gne__c,   // Professional Type (Medical Doctor, Thought Leader etc.)
                        RecordTypeId,               // Record Type Id
                        RecordType.Name,            // Record Type Name
                        RecordType.Description,     // Record Type Description
                        Salutation,                 // Salutation
                        Specialties_gne__c,         // Specialties (Picklist Multi-Select)
                        Suffix_gne__c,              // Suffix (Used for person accounts)
                        Suffix_vod__c,              // =||=
                        Website,                    // Website
                        PDRP_Opt_Out_vod__c,        // PDRP Opt Out Flag
                        PDRP_Opt_Out_Date_vod__c,   // PDRP Opt Out Date
                        Fax,                        // Fax
                        PersonEmail,

                (
                        SELECT
                                Address_gne__c,             // SFDC Address FK
                                Account_gne__c,             // SFDC Account FK
                                MDMID_gne__c,               // MDM ID of the account
                                Third_Party_gne__c,         // External System Name (NVTS, PW, TSG etc.) (CADS Contributor Source Code)
                                Third_Party_Id_gne__c,      // CADS Contributor Source Id
                                Third_Party_Index_gne__c    // Third Party Index (concat. Third Party with Third Party Id)
                        FROM
                                Account_External_ID_gne__r
                ),//  Account External Id
                (
                        SELECT
                                Name,                                          // License Number
                                Account_gne__c,                             // SFDC Account Id
                                License_Expiration_Date_gne__c,             // Licanse Expiration Date
                                License_Status_gne__c,                      // License Sample-ablility
                                License_State_gne__c                        // License State
                        FROM
                                Licenses__r                         // Prescriber_License_gne__c
                ), (
                        SELECT
                                Account_gne__c,                             // SFDC Account Id
                                License_Expiration_Date_gne__c,             // License Expiration Date
                                License_Number_gne__c,                      // License Number
                                License_Overwrite_Expiration_Date_gne__c,   // License Expiration Date
                                License_Sample_ability_gne__c,              // License Sample-ablility
                                License_State_gne__c                        // License State
                        FROM
                                R00N70000001woYtEAI                         // Data Change Request
                        WHERE
                        RecordType.Name = :RECORD_TYPE_NAME_LICENSE_CR AND
                        (NOT Status_gne__c LIKE 'Closed%')
                ), (
                        SELECT
                                Name,                                          // License Number
                                Account_gne__c,                             // SFDC Account Id
                                License_Expiration_Date_gne__c,             // Licanse Expiration Date
                                License_Status_gne__c,                      // License Sample-ablility
                                License_State_gne__c,                        // License State
                                Organization_Name_gne__c,
                                Organization_Address_gne__c
                        FROM
                                TDDD_Licenses__r                         // TDDD_License_gne__c
                )
                FROM
                        Account
                WHERE
                Id IN :accountIds OR MDMID_gne__c IN :mdmIds
        ];
    }

    /**
    * Retreives addresses from SFDC (including external Ids) from 
    * the Address object for a given list of SFDC Ids or MDM Ids
    */
    private List<Address_vod__c> fetchAddresses(Set<String> sfdcIds, Set<String> mdmIds) {
        return [
                SELECT
                        Id,                     // SFDC Address Id
                        CreatedDate,            // SFDC Address Created Date
                        Account_vod__c,         // SFDC Account Id reference
                        MDM_Address_ID_gne__c,  // MDM Address Id
                        Name,                   // Street Address
                        Address_line_2_vod__c,  // Suite/Floor/Unit
                        Address_Line_3_gne__c,  // Department Name
                        City_vod__c,            // City
                        State_vod__c,           // State (Country dependent picklist)
                        Country_gen__c,         // Country
                        Zip_vod__c,             // Zip code of the Address
                        Zip_4_vod__c,           // ZIP + 4 of the Address
                        Shipping_vod__c,        // Shipping (checkbox that determines if an Address serves as a shipping address)
                        Mailing_vod__c,         // Mailing (checkbox that determines if an Address serves as a mailing address)
                        Billing_vod__c,         // Billing (checkbox to determine if an Address serves as a billing address)
                        Business_vod__c,        // Business (checkbox to determine if an Address serves as a business address)
                        Office_gne__c,          // Office
                        Hospital_gne__c,        // Hospital (checkbox to determine if the address is a Hospital address)
                        Fax_vod__c,             // Fax number for the Account at the Address
                        Phone_vod__c,           // Primary phone number for the Account at the Address
                        Phone_1_Ext_gne__c,     // Extension number for Phone 
                        Phone_2_vod__c,         // Alternate phone number for the Account at the Address
                        Phone_2_Ext_gne__c,     // Extension number for Phone 2
                        License_vod__c,         // State License Number for the corresponding State of the Address
                        License_Expiration_Date_vod__c, // State License Expiration Date
                        License_Status_vod__c,  // State License Status
                        Designation_gne__c,     // Designation
                        Active_Flag_gne__c,     // Active flag
                        GOLD_RECORD_gne__c,     // Gold Address Flag 
                        MDM_Status_gne__c,       // Address Status
                        AMS_gold_record_gne__c, // AMS Gold Address Flag
                        Latitude_vod__c,
                        Longitude_vod__c,
                        Inactive_vod__c, (
                        SELECT
                                Id,                         // SFDC Address External Id
                                Address_gne__c,             // SFDC Address Id
                                Third_Party_gne__c,         // External System Name (PW, TSG etc.) (CADS Contributor Source Code)
                                Third_Party_Id_gne__c,      // CADS Contributor Source Id
                                Third_Party_Index_gne__c    // Third Party Index (concat. Third Party with Third Party Id)
                        FROM
                                R00N70000002Gy6UEAS
                )        // Address External Id reference

                FROM
                        Address_vod__c
                WHERE
                Id IN :sfdcIds OR MDM_Address_ID_gne__c IN :mdmIds
        ];
    }

    private List<Address_vod__c> fetchAddresses(Set<Id> accountIds) {
        return [
                SELECT
                        Id,                     // SFDC Address Id
                        CreatedDate,            // SFDC Address Created Date
                        Account_vod__c,         // SFDC Account Id reference
                        MDM_Address_ID_gne__c,  // MDM Address Id
                        Name,                   // Street Address
                        Address_line_2_vod__c,  // Suite/Floor/Unit
                        Address_Line_3_gne__c,  // Department Name
                        City_vod__c,            // City
                        State_vod__c,           // State (Country dependent picklist)
                        Country_gen__c,         // Country
                        Zip_vod__c,             // Zip code of the Address
                        Zip_4_vod__c,           // ZIP + 4 of the Address
                        Shipping_vod__c,        // Shipping (checkbox that determines if an Address serves as a shipping address)
                        Mailing_vod__c,         // Mailing (checkbox that determines if an Address serves as a mailing address)
                        Billing_vod__c,         // Billing (checkbox to determine if an Address serves as a billing address)
                        Business_vod__c,        // Business (checkbox to determine if an Address serves as a business address)
                        Office_gne__c,          // Office
                        Hospital_gne__c,        // Hospital (checkbox to determine if the address is a Hospital address)
                        Fax_vod__c,             // Fax number for the Account at the Address
                        Phone_vod__c,           // Primary phone number for the Account at the Address
                        Phone_1_Ext_gne__c,     // Extension number for Phone
                        Phone_2_vod__c,         // Alternate phone number for the Account at the Address
                        Phone_2_Ext_gne__c,     // Extension number for Phone 2
                        License_vod__c,         // State License Number for the corresponding State of the Address
                        License_Expiration_Date_vod__c, // State License Expiration Date
                        License_Status_vod__c,  // State License Status
                        Designation_gne__c,     // Designation
                        Active_Flag_gne__c,     // Active flag
                        GOLD_RECORD_gne__c,     // Gold Address Flag
                        MDM_Status_gne__c,       // Address Status
                        AMS_gold_record_gne__c, // AMS Gold Address Flag
                        Latitude_vod__c,
                        Longitude_vod__c,
                        Inactive_vod__c
                FROM
                        Address_vod__c
                WHERE Account_vod__c IN :accountIds
        ];
    }

    /**
    * Retrieves user id by external user id
    */
    public List<User> fetchUsers(List<String> externalUserIds) {
        return [SELECT Id, External_ID_gne__c FROM User WHERE External_ID_gne__c IN :externalUserIds];
    }

    public Boolean canCreateNewObject(CORE_Pub_Party__c parentParty, SObject publishRecord, CORE_Subscribe_Mapping_Configuration__c configuration, CORE_Subscribe_Base.SubscribeMode mode) {
        Boolean canCreate = true;
        if (publishRecord instanceof CORE_Pub_Party__c) {
            /*
            CORE_Pub_Party__c party = (CORE_Pub_Party__c)publishRecord;
            Map<String, Set<String>> ctrbSourceToIds = partyIdToIdMap.get(party.Id);
            canCreate = isContributedBySource(CREATE_ACCOUNT_XREF, ctrbSourceToIds.keySet());
            */
        } else if (publishRecord instanceof CORE_Pub_Location__c) {
            CORE_Pub_Location__c loc = (CORE_Pub_Location__c) publishRecord;
            Map<String, Set<String>> ctrbSourceToIds = partyLocIdToIdMap.get(loc.Id);
            List<SObject> existingAccounts = getExistingAccounts(parentParty, UPDATE_ON_MDM_ID);
            Boolean isNewAccount = existingAccounts.isEmpty();
            if (isNewAccount || mode == SubscribeMode.ASI) {
                canCreate = true;
            } else {
                canCreate = isContributedBySource(CREATE_ADDRESS_XREF, ctrbSourceToIds.keySet());
            }

        } else if (publishRecord instanceof CORE_Pub_External_Id__c) {
            CORE_Pub_External_Id__c extId = (CORE_Pub_External_Id__c) publishRecord;
            if (extId.Cnncl_Enty_Type_gne__c == CNNCL_PARTY_LOC) {
                canCreate = CREATE_ADDRESS_EXT.contains(extId.Ctrb_Src_gne__c) || CREATE_ADDRESS_EXT.contains('[' + parentParty.Type_gne__c + ']' + extId.Ctrb_Src_gne__c);
            } else if (extId.Cnncl_Enty_Type_gne__c == CNNCL_PARTY) {
                canCreate = CREATE_ACCOUNT_EXT.contains(extId.Ctrb_Src_gne__c) || CREATE_ACCOUNT_EXT.contains('[' + parentParty.Type_gne__c + ']' + extId.Ctrb_Src_gne__c);
            }
        }

        return canCreate;
    }

    public Boolean canUpdateRecord(CORE_Pub_Party__c parentParty, SObject publishRecord, CORE_Subscribe_Mapping_Configuration__c configuration, List<SObject> existingRecords, CORE_Subscribe_Base.SubscribeMode mode) {
        if (configuration.Source_Object_gne__c == 'CORE_Pub_License__c') {
            List<Account> existingAccounts = getExistingAccounts(parentParty, UPDATE_ON_MDM_ID);
            if (!existingAccounts.isEmpty()) {
                for (Account acc : existingAccounts) {
                    if (!acc.R00N70000001woYtEAI.isEmpty()) {
                        return false;
                    }
                }
            }
        }
        return true;
    }

    public String getConfigurationType(SObject stagingRecord) {
        String confType;
        if (stagingRecord instanceof CORE_Pub_Party__c) {
            confType = ((CORE_Pub_Party__c) stagingRecord).Type_gne__c;
        } else if (stagingRecord instanceof CORE_Pub_External_Id__c) {
            confType = ((CORE_Pub_External_Id__c) stagingRecord).Cnncl_Enty_Type_gne__c;
        }
        return confType;
    }

}