public inherited sharing class GNE_Subscribe_Util {

    private Id defaultAccountOwnerId;

    public List<Account> searchAndSubscribeAccounts(Set<String>mdmIds) {
        Map<String, Account> accountsToInsert = new Map<String, Account>();
        if (!mdmIds.isEmpty()) {
            Map<String, Address_vod__c> addressesToInsert = new Map<String, Address_vod__c>();
            Map<String, List<Prescriber_License_gne__c>> licensesToInsert = new Map<String, List<Prescriber_License_gne__c>>();
            try {
                for (String mdmid : mdmIds) {
                    GNE_SFA2_SBC_DAO.DataWrapper mdmData = new GNE_SFA2_SBC_RELTIO_DAO().searchAccounts('hcp', 'MDMId', new Map<String, String>{
                            'MDMID' => mdmid
                    });

                    List<GNE_SFA2_SBC_Ctrl.SearchAccountWrapper> wrappers = new List<GNE_SFA2_SBC_Ctrl.SearchAccountWrapper> ();
                    for (GNE_SFA2_SBC_DAO.AccountWrapper aWrapper : mdmData.rows) {
                        wrappers.addAll(convertToSbcResult(aWrapper));
                    }

                    for (GNE_SFA2_SBC_Ctrl.SearchAccountWrapper accountWrapper : wrappers) {
                        Account account = accountWrapper.getAccount();
                        account.OwnerId = getDefaultAccountOwnerId(account);
                        accountsToInsert.put(accountWrapper.mdmId, account);
                        for (GNE_SFA2_SBC_Ctrl.SearchAddressWrapper addressWrapper : accountWrapper.addresses) {
                            addressesToInsert.put(accountWrapper.mdmId, addressWrapper.getAddress(accountWrapper.licensesMap));
                        }

                        for (List<GNE_SFA2_SBC_Ctrl.LicenseWrapper> licenseWrapperLst : accountWrapper.licensesMap.values()) {
                            if (!licensesToInsert.containsKey(accountWrapper.mdmId)) {
                                licensesToInsert.put(accountWrapper.mdmId, new List<Prescriber_License_gne__c>());
                            }
                            licensesToInsert.get(accountWrapper.mdmId).add(licenseWrapperLst.get(0).getLicense());
                        }
                    }
                }
            } catch (Exception e) {
                //ignore
            }
            if (!accountsToInsert.isEmpty()) {
                insert accountsToInsert.values();
                for (String mdmdId : addressesToInsert.keySet()) {
                    addressesToInsert.get(mdmdId).Account_vod__c = accountsToInsert.get(mdmdId).Id;
                }
                insert addressesToInsert.values();
                List<Prescriber_License_gne__c> licToInsert = new List<Prescriber_License_gne__c>();
                for (String mdmdId : licensesToInsert.keySet()) {
                    for (Prescriber_License_gne__c lic : licensesToInsert.get(mdmdId)) {
                        lic.Account_gne__c = accountsToInsert.get(mdmdId).Id;
                        licToInsert.add(lic);
                    }
                }
                insert licToInsert;
            }
        }
        return accountsToInsert.values();
    }

    private List<GNE_SFA2_SBC_Ctrl.SearchAccountWrapper> convertToSbcResult(GNE_SFA2_SBC_DAO.AccountWrapper mdmAccWrapper) {
        GNE_SFA2_SBC_Ctrl.SearchAccountWrapper accountRow = new GNE_SFA2_SBC_Ctrl.SearchAccountWrapper(mdmAccWrapper);
        List<GNE_SFA2_SBC_Ctrl.SearchAccountWrapper> result = new List<GNE_SFA2_SBC_Ctrl.SearchAccountWrapper>{
                accountRow
        };

        GNE_SFA2_SBC_Ctrl.SearchAddressWrapper defaultAddressWrapper;
        for (GNE_SFA2_SBC_DAO.AddressWrapper addr : mdmAccWrapper.addresses) {
            if (addr.isDefault) {
                defaultAddressWrapper = new GNE_SFA2_SBC_Ctrl.SearchAddressWrapper(addr, accountRow);
            }
        }
        if (defaultAddressWrapper == null && !mdmAccWrapper.addresses.isEmpty()) {
            defaultAddressWrapper = new GNE_SFA2_SBC_Ctrl.SearchAddressWrapper(mdmAccWrapper.addresses.get(0), accountRow);
        }
        return result;
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
                defaultAccountOwnerId = UserInfo.getUserId();
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
}