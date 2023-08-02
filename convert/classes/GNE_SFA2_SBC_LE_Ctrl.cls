public class GNE_SFA2_SBC_LE_Ctrl {
    public static final String ACCOUNT_TYPE_DEFAULT = 'Health Care Professional';
    private static Id defaultAccountOwnerId;

    @AuraEnabled
    public static Map<String, String> getValues(String objectType, String recordTypeId, String fieldName) {
        //Endpoint
        String endpoint = Url.getSalesforceBaseUrl().toExternalForm();
        endpoint += '/services/data/v41.0';
        endpoint += '/ui-api/object-info/{0}/picklist-values/{1}/{2}';
        endpoint = String.format(endpoint, new String[]{
                objectType, recordTypeId, fieldName
        });
        EncodingUtil.urlEncode(endpoint, 'UTF-8');


        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        Http http = new Http();
        HttpResponse res = http.send(req);


        Map<String, String> result = new Map<String, String>();
        Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        if (!root.containsKey('values')) {
            return result;
        }
        List<Object> pValues = (List<Object>) root.get('values');
        for (Object pValue : pValues) {
            Map<String, Object> pValueMap = (Map<String, Object>) pValue;
            result.put((String) pValueMap.get('value'), (String) pValueMap.get('label'));
            System.debug(result);
        }

        return result;
    }

    @AuraEnabled
    public static SFASearchStrings_gne__c gethcpResults() {
        String hcpMode = GNE_SFA2_SBC_Config.AccountModes.HCP.name();
        String nameAddressSearchMode = GNE_SFA2_SBC_Config.SearchModes.NameAddress.name();
        SFASearchStrings_gne__c hcpSearchRec = new SFASearchStrings_gne__c(AccountType_gne__c = hcpMode, Mode_gne__c = nameAddressSearchMode);
        for (SFASearchStrings_gne__c searchSet : GNE_SFA2_SBC_DAO.getLastSearchHistoryRecord(hcpMode, UserInfo.getUserId())) {
            hcpSearchRec = searchSet;
        }

        return hcpSearchRec;
    }

    @AuraEnabled
    public static void upsertSearchSeting(SFASearchStrings_gne__c searchStrings) {
        System.debug(searchStrings);
        upsert searchStrings;
    }

    @AuraEnabled
    public static List<String> getHcpProfTypes() {
        return GNE_SFA2_SBC_Config.getHcpProfTypes();
    }

    @AuraEnabled
    public static List<String> getHcpCredentials() {
        List<String>result = new List<String>();
        for (Schema.PicklistEntry entry : Account.Credentials_vod__c.getDescribe().getPicklistValues()) {
            result.add(entry.getValue());
        }
        return result;
    }

    @AuraEnabled
    public static Map<String, String> cacheHcpRoles() {
        Map<String, String> result = new Map<String, String>();
        Map<String, GNE_Foun_Role_Ranking_gne__c> rrRecs = GNE_Foun_Role_Ranking_gne__c.getAll();

        for (String str : rrRecs.keySet()) {
            result.put(str, rrRecs.get(str).Account_Professional_Type_gne__c);
        }

        return result;
    }

    @AuraEnabled
    public static List<String> getStates() {
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Address_vod__c.State_vod__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f : ple) {
            options.add(f.getValue());
        }
        return options;
    }

    @AuraEnabled
    public static String searchAccountsSBC(String accType, String searchMode, Map<String, String> searchParams, Map<String, Integer> paginationData, String teamCode) {
        GNE_SFA2_SBC_Ctrl sbcCtrl = new GNE_SFA2_SBC_Ctrl();
        GNE_SFA2_SBC_DAO.DataWrapper result;
        Set<String> teamCodes = String.isBlank(teamCode) ? new Set<String>() : new Set<String>(teamCode.split(','));
        GNE_SFA2_SBC_DAO.PaginationDataWrapper paginationDataWrapper = new GNE_SFA2_SBC_DAO.PaginationDataWrapper();
        paginationDataWrapper.pageSize = paginationData.get('pageSize');
        paginationDataWrapper.endPageIdx = paginationData.get('offset');
        try {
            result = sbcCtrl.searchAccounts(accType, searchMode, searchParams, paginationDataWrapper, teamCodes);
        } catch (GNE_SFA2_SBC_DAO.ServiceException mex) {
            String knowErrorMessage = GNE_SFA2_SBC_Config.getMdmKnowErrorMessage(mex.statusCode);
            MdmExc exResult = new MdmExc(GNE_SFA2_SBC_Config.getMdmKnowErrorName(mex.statusCode), String.isNotBlank(knowErrorMessage) ? knowErrorMessage : mex.status);
            return JSON.serialize(exResult);
        } catch (Exception ex) {
            return JSON.serialize(ex);
        }
        return JSON.serialize(result);
    }

    @AuraEnabled //to remove
    public static Account searchAccountsByMdmId(String mdmId) {
        Account[] accs = [SELECT Id FROM Account WHERE MDMID_gne__c = :mdmId];
        return accs.isEmpty() ? null : accs[0];
    }

    @AuraEnabled
    public static String insertAccount(String jsonData) {
        System.debug('jsonData ' + jsonData);
        GNE_SFA2_SBC_Ctrl.DataWrapper dataToProcess = new GNE_SFA2_SBC_Ctrl.DataWrapper();

        dataToProcess.sbcMode = 'hcpSearch'; //TODO
        dataToProcess.isPopupMode = true;
        GNE_SFA2_SBC_DAO.AccountWrapper maw = (GNE_SFA2_SBC_DAO.AccountWrapper) JSON.deserialize(jsonData, GNE_SFA2_SBC_DAO.AccountWrapper.class);
        GNE_SFA2_SBC_Ctrl.SearchData sData = new GNE_SFA2_SBC_Ctrl.SearchData('hcp', new List<GNE_SFA2_Base_Ctrl.Field>());


        GNE_SFA2_SBC_Ctrl.SearchAccountWrapper selectedAccountRow = new GNE_SFA2_SBC_Ctrl.SearchAccountWrapper(maw);
        System.debug(maw);

        List<Territory2> userTerritoriesCache = GNE_SFA2_Util.getUserTerritories(UserInfo.getUserId());
        Map<Id, Territory2> userTerrs = new Map<Id, Territory2>(userTerritoriesCache);
        List<Group> groups = userTerrs.isEmpty() ? new List<Group>() : GNE_SFA2_SBC_DAO.getTerritoryGroups(userTerrs.keySet());
        Map<Id, Id> terrIdToGroupIdMap = new Map<Id, Id>();
        for (Group grp : groups) {
            terrIdToGroupIdMap.put(grp.RelatedId, grp.Id);
        }
        dataToProcess.territoriesMap = new Map<Id, GNE_SFA2_SBC_Ctrl.TerritoryWrapper>();
        for (Territory2 uTerr : userTerritoriesCache) {
            if (userTerrs.containsKey(uTerr.Id)) {
                dataToProcess.territoriesMap.put(uTerr.Id, new GNE_SFA2_SBC_Ctrl.TerritoryWrapper(uTerr, terrIdToGroupIdMap.get(uTerr.Id)));
            }
        }

        sData.selectedAccountRow = selectedAccountRow;
        dataToProcess.searchData = new Map<String, GNE_SFA2_SBC_Ctrl.SearchData>();

        sData.selectedAddressRows = new List<GNE_SFA2_SBC_Ctrl.SearchAddressWrapper>();
        for (GNE_SFA2_SBC_DAO.AddressWrapper mAddress : maw.addresses) {
            sData.selectedAddressRows.add(new GNE_SFA2_SBC_Ctrl.SearchAddressWrapper(mAddress, selectedAccountRow));
        }
        dataToProcess.searchData.put('hcp', sData);

        GNE_SFA2_SBC_Ctrl.DataWrapper result = GNE_SFA2_SBC_Ctrl.upsertAccountFromMdm(JSON.serialize(dataToProcess));
        //String resultAsStr = result.retUrl != null ? result.retUrl.removeStart('/') : result.accountId != null ? result.accountId : 'no Id' ;

        System.debug(result);
        String resultAsStr = JSON.serialize(result);
        System.debug(resultAsStr);

        return resultAsStr;
    }

    @AuraEnabled
    public static String insertAccountAndAddress(Account newAcc, Address_vod__c newAddr) {
        DMLResult result = new DMLResult();
        GNE_SFA2_SBC_Ctrl.DataWrapper resultAsWrapper = new GNE_SFA2_SBC_Ctrl.DataWrapper();
        System.debug(newAcc);
        System.debug(newAddr);
        Id addrRecTypeId = GNE_SFA2_SBC_DAO.getRecordTypeId('Address_vod__c', GNE_SFA2_SBC_Ctrl.REC_TYPE_ADDR_REP);
        newAddr.Primary_vod__c = true;
        newAddr.Active_Flag_gne__c = true;
        newAddr.MDM_Status_gne__c = 'Active';
        newAddr.RecordTypeId = addrRecTypeId;

        newAcc.MDMID_Status_gne__c = 'Active';
        newAcc.OwnerId = getDefaultAccountOwnerId(newAcc);

        try {
            insert newAcc;
            result.message = newAcc.Id;
            resultAsWrapper.accountId = newAcc.Id;
        } catch (Exception ex) {
            result.isSucess = false;
            result.errorMessage = ex.getMessage();
            resultAsWrapper.errors = new List<GNE_SFA2_Base_Ctrl.ExceptionWrapper>{
                    new GNE_SFA2_Base_Ctrl.ExceptionWrapper(ex.getMessage())
            };
        }

        newAddr.Account_vod__c = newAcc.Id;

        try {
            DmlExecutorWithoutSharing dmlExec = new DmlExecutorWithoutSharing();
            dmlExec.executeDml(GNE_SFA2_Base_Ctrl.DmlOperations.INS, new List<Address_vod__c>{
                    newAddr
            });
            resultAsWrapper.addressId = newAddr.Id;
        } catch (Exception ex) {
            result.isSucess = false;
            result.errorMessage = ex.getMessage();
            resultAsWrapper.errors = new List<GNE_SFA2_Base_Ctrl.ExceptionWrapper>{
                    new GNE_SFA2_Base_Ctrl.ExceptionWrapper(ex.getMessage())
            };
        }

        if (result.isSucess) {
            GNE_FRM_Synchronize_Records_With_MDM.syncOnAccountUpsert(newAcc, newAddr, GNE_FRM_Synchronize_Records_With_MDM.DML_Type.DML_INSERT, true);
        }

        String resultAsString = JSON.serialize(resultAsWrapper);

        return resultAsString;
    }

    private static Id getDefaultAccountOwnerId(Account acc) {
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

    private static Id getAccountOwner(String extId) {
        Id result = null;
        List<User> users = GNE_SFA2_Util.getUserByExternalId(extId);

        for (User u : users) {
            result = u.Id;
        }

        return result;
    }

    @AuraEnabled
    public static Map<Object, List<String>> getProfTypesDep() {
        Map<Object, List<String>>result = getDependentPicklistValues(Account.Credentials_vod__c);
        System.debug(result);
        return result;
    }

    public static Map<Object, List<String>> getDependentPicklistValues(Schema.SObjectField dependToken) {
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.SObjectField controlToken = depend.getController();
        if (controlToken == null) return null;
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries =
                (control.getType() == Schema.DisplayType.BOOLEAN
                        ? null
                        : control.getPicklistValues()
                );
        System.debug(control.getPicklistValues());
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<Object, List<String>> dependentPicklistValues = new Map<Object, List<String>>();
        for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
            if (entry.isActive()) {
                List<String> base64chars = String.valueOf(((Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                    Object controlValue =
                            (controlEntries == null
                                    ? (Object) (index == 1)
                                    : (Object) (controlEntries[index].isActive() ? controlEntries[index].getLabel() : null)
                            );
                    Integer bitIndex = index / 6, bitShift = 5 - Math.mod(index, 6);
                    if (base64chars.size() <= bitIndex || controlValue == null
                            || (base64map.indexOf(base64chars[bitIndex]) & (1 << bitShift)) == 0
                    ) {
                        continue;
                    }
                    if (!dependentPicklistValues.containsKey(controlValue)) {
                        dependentPicklistValues.put(controlValue, new List<String>());
                    }
                    dependentPicklistValues.get(controlValue).add(entry.getLabel());
                }
            }
        }
        return dependentPicklistValues;
    }

    public class DMLResult {
        @AuraEnabled
        public Boolean isSucess { get; set; }
        @AuraEnabled
        public String errorMessage { get; set; }
        @AuraEnabled
        public String message { get; set; }

        public DMLResult() {
            this.isSucess = true;
        }
    }

    public class MdmExc {
        @AuraEnabled
        public String statusCode { get; set; }
        @AuraEnabled
        public String status { get; set; }

        public MdmExc(String statCode, String stat) {
            this.statusCode = statCode;
            this.status = stat;
        }
    }

    public without sharing class DmlExecutorWithoutSharing {
        public void executeDml(GNE_SFA2_Base_Ctrl.DmlOperations operationType, List<SObject> recs) {
            if (recs != null && !recs.isEmpty()) {
                if (operationType == GNE_SFA2_Base_Ctrl.DmlOperations.INS) {
                    insert recs;
                } else if (operationType == GNE_SFA2_Base_Ctrl.DmlOperations.UPD) {
                    update recs;
                } else if (operationType == GNE_SFA2_Base_Ctrl.DmlOperations.UPS) {
                    if (recs.size() == 1 && recs.getSObjectType() == null) {
                        upsert recs[0];
                    } else {
                        upsert recs;
                    }
                } else if (operationType == GNE_SFA2_Base_Ctrl.DmlOperations.DEL) {
                    delete recs;
                }
            }
        }
    }
}