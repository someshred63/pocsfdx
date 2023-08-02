public class GNE_SFA2_Merge_Util {
    private static final String DCH_ACTION_RELATED_LIST_LOGIC = 'Related List Logic';
    private static final String MERGE_OBJECT_HCP = 'Person Account-US';
    private static final String MERGE_OBJECT_HCO = 'Account-US';
    private static final String ERROR_MESSAGE_NON_PRESCRIBER_WITH_CASES = 'Winner HCP {0} is not prescriber and loser HCP {1} has cases';
    private static final String ERROR_MESSAGE_LOOKUP_DETECTED_ISSUE = 'Account {0} is parent of {1}';
    private static Map<Id, RecordType> recordTypesMap = new Map<Id, RecordType>([
        SELECT Id, DeveloperName
        FROM RecordType
        WHERE SobjectType = 'Account' AND DeveloperName = 'FRM_HCO'
    ]);
    private static final CORE_Merge_Object__c MERGE_OBJECT_ADDRES_US = [SELECT Id, Name FROM CORE_Merge_Object__c WHERE Name IN ('Address-US') LIMIT 1];
    /* ACTIONS */
    private static final String ACTION_PARENT_LOOKUP_DETECTOR = 'parentLookupDetector';
    private static final String ACTION_CASES_FOR_NON_PRESCRIBER = 'casesForNonPrescriber';
    private static final String ACTION_BLOCK_MERGE_FOR_FRM_AND_NONFRM ='blockFRMandNonFRMAccounts';
    private static final String MOVE_ADDRESS_EXTERNALID = 'moveAddressExternalId';

    public class AdminModeManager implements CORE_Merge_Interface.AdminModeManagerInterface {
        public Boolean switchAdminMode(Boolean turnOnOrOff) {
            GNE_SFA2_Admin_Mode__c adminModeSetting = GNE_SFA2_Admin_Mode__c.getInstance();

            if (adminModeSetting==null) {
                adminModeSetting = new GNE_SFA2_Admin_Mode__c(SetupOwnerId = UserInfo.getUserId(), GNE_SFA2_Is_Admin_Mode__c = false);
            }

            Boolean result = adminModeSetting.GNE_SFA2_Is_Admin_Mode__c;
            adminModeSetting.GNE_SFA2_Is_Admin_Mode__c = turnOnOrOff;

            if(result != turnOnOrOff){
                upsert adminModeSetting;
            }

            return result;
        }

        public Boolean isAdminMode() {
            Boolean result = false;
            GNE_SFA2_Admin_Mode__c adminModeSetting = GNE_SFA2_Admin_Mode__c.getInstance();

            if (adminModeSetting!=null) {
                result = adminModeSetting.GNE_SFA2_Is_Admin_Mode__c;
            }

            return result;
        }
    }

    public class CustomActionHandler implements
            CORE_Merge_Interface.CustomValidationInterface,
            CORE_Merge_Interface.CustomPreMergeActionInterface,
            CORE_Merge_Interface.CustomPostMergeActionInterface,
            CORE_Merge_Interface.CustomPostPopulateActionInterface,
            CORE_Merge_Interface.CustomMergeEngineListnerInterface {

        private transient Map<String,List<SObject>> recsWithExternalIdToUpdate;
        private transient List<TSF_vod__c> tsfsWithAddressToUpdate;

        public Boolean mergeValidate(String vrName, CORE_Merge_Interface.MergeObjectInterface mergeObject, CORE_Merge_Interface.MergeGroupInterface mergeGroup, CORE_Merge_Interface.MergeEngineInterface mergeEngine) {
            Boolean isOk = true;

            if(vrName == ACTION_CASES_FOR_NON_PRESCRIBER) {
                isOk = checkHcpCasesForNonPrescriber(mergeGroup, mergeEngine);
            }
            if(vrName == ACTION_PARENT_LOOKUP_DETECTOR){
                isOk = checkParentAccount(mergeGroup, mergeEngine, mergeObject);
            }
            if(vrName == ACTION_BLOCK_MERGE_FOR_FRM_AND_NONFRM){
                isOk = checkRecordTypesForAccounts(mergeGroup, mergeEngine, mergeObject);
            }

            return isOk;
        }

        public Boolean mergeExecutePreAction(String actionName, CORE_Merge_Interface.MergeObjectInterface mergeObject, CORE_Merge_Interface.MergeGroupInterface mergeGroup, CORE_Merge_Interface.MergeEngineInterface mergeEngine) {
            Boolean winnerChanged = false;

            if(mergeObject.getSObjectName()=='Account') {
                if(actionName=='updateClassifications') {
                    winnerChanged = updateClassifications(mergeGroup.getWinnerCandidate(), mergeGroup.getAllCandidates());
                } else if(actionName=='updateExclusions') {
                    winnerChanged = updateExclusions(mergeGroup.getWinnerCandidate(), mergeGroup.getAllCandidates());
                } else if(actionName=='updateLoserParentCalls') {
                    winnerChanged = updateLoserParentCalls(mergeGroup.getLoserCandidates());
                } else if(actionName=='updateAccountTestingStrategy') {
                    updateAccountTestingStrategy(mergeGroup);
                }
            } else if(mergeObject.getSObjectName()=='Address_vod__c') {
                if(actionName == 'mergeHcpAddressMapping') {
                    mergeHcpAddressMapping(mergeGroup);
                }
                if(actionName == 'avoidMoreThanOneMappingOnAddress') {
                    avoidMoreThanOneMappingOnAddress(mergeGroup);
                }
                if(actionName == MOVE_ADDRESS_EXTERNALID) {
                    moveAddressExternalId(mergeGroup);
                }
            }

            return winnerChanged;
        }

        public void mergeExecutePostAction(String actionName, CORE_Merge_Interface.MergeObjectInterface mergeObject, CORE_Merge_Interface.MergeGroupInterface mergeGroup, CORE_Merge_Interface.MergeEngineInterface mergeEngine) {
            if(mergeObject.getSObjectName()=='Account') {
                if(actionName=='updateAddressPrimaryFlag') {
                    updateAddressPrimaryFlag(mergeGroup.getWinnerCandidate().getSourceRecord());
                }
                if(actionName=='avoidMoreThanOneAddressForHCO') {
                    avoidMoreThanOneAddressForHCO(mergeGroup.getWinnerCandidate().getSourceRecord());
                }
                if(actionName=='updateVdstEventPrtcpntAccnt') {
                    updateVdstEventPrtcpntAccnt(mergeGroup);
                }
            } else if(mergeObject.getSObjectName()=='Address_vod__c') {
                if(actionName=='setTSFAddress') {
                    setTSFAddress((Address_vod__c)mergeGroup.getWinnerCandidate().getSourceRecord());
                } else if(actionName=='updateAddressPrimaryFlag') {
                    updateAddressPrimaryFlag(mergeGroup.getWinnerCandidate().getSourceRecord());
                } else if(actionName=='createArchiveAccountClone') {
                    createArchiveAccountCloneForAddresses(mergeGroup);
                }
            } else if(mergeObject.getSObjectName()=='TSF_vod__c') {
                if(actionName=='setTSFAddress') {
                    cacheTsfWithAddressToUpdate((TSF_vod__c)mergeGroup.getWinnerCandidate().getSourceRecord());
                } else if(actionName=='updateExternalId') {
                    cacheRecordsWithExternalId(mergeGroup.getWinnerCandidate().getSourceRecord());
                }
            } else if(mergeObject.getSObjectName()=='Affiliation_vod__c') {
                if(actionName=='updateExternalId') {
                    cacheRecordsWithExternalId(mergeGroup.getWinnerCandidate().getSourceRecord());
                }
            } else if(mergeObject.getSObjectName()=='Product_Metrics_vod__c') {
                if(actionName=='updateExternalId') {
                    cacheRecordsWithExternalId(mergeGroup.getWinnerCandidate().getSourceRecord());
                }
            } else if(mergeObject.getSObjectName()=='User_Preference_gne__c') {
                if(actionName=='updateExternalId') {
                    cacheRecordsWithExternalId(mergeGroup.getWinnerCandidate().getSourceRecord());
                }
            }
        }

        public void mergePostPopulateAction(String actionName, CORE_Merge_Interface.MergeObjectInterface mergeObject, List<SObject> duplicates, CORE_Merge_Interface.MergeEngineInterface mergeEngine) {
            if(actionName=='updateExternalId' && duplicates.size()==1) {
                cacheRecordsWithExternalId(duplicates);
            }
        }

        public void mergeNotifyOnAction(CORE_Merge_Interface.MergeProcessState state, CORE_Merge_Interface.MergeObjectInterface mergeObject, List<CORE_Merge_Interface.MergeGroupInterface> mergeGroups, CORE_Merge_Interface.MergeEngineInterface mergeEngine) {
            if(state==CORE_Merge_Interface.MergeProcessState.AfterMergeChildCandidates || state==CORE_Merge_Interface.MergeProcessState.AfterPopulateCandidates) {
                if(recsWithExternalIdToUpdate!=null) {
                    for(List<SObject> recs : recsWithExternalIdToUpdate.values()) {
                        updateExternalId(recs);
                    }

                    recsWithExternalIdToUpdate.clear();
                }

                if(tsfsWithAddressToUpdate!=null) {
                    setTSFAddress(tsfsWithAddressToUpdate);
                    tsfsWithAddressToUpdate.clear();
                }
            }
        }

        private void cacheRecordsWithExternalId(SObject rec) {
            cacheRecordsWithExternalId(new List<SObject>{rec});
        }

        private void cacheRecordsWithExternalId(List<SObject> recs) {
            if(!recs.isEmpty()) {
                if(recsWithExternalIdToUpdate==null) {
                    recsWithExternalIdToUpdate = new Map<String,List<SObject>>();
                }

                String key = String.valueOf(recs[0].getSObjectType());

                if(!recsWithExternalIdToUpdate.containsKey(key)) {
                    recsWithExternalIdToUpdate.put(key, new List<SObject>());
                }

                recsWithExternalIdToUpdate.get(key).addAll(recs);
            }
        }

        private void cacheTsfWithAddressToUpdate(TSF_vod__c tsf) {
            if(tsfsWithAddressToUpdate==null) {
                tsfsWithAddressToUpdate = new List<TSF_vod__c>();
            }

            tsfsWithAddressToUpdate.add(tsf);
        }

        private Boolean checkHcpCasesForNonPrescriber(CORE_Merge_Interface.MergeGroupInterface mergeGroup, CORE_Merge_Interface.MergeEngineInterface mergeEngine) {
            Boolean isOk = true;

            if(mergeGroup.getWinnerCandidate().isSourceValid()) {
                Account winnerAcc = (Account)mergeGroup.getWinnerCandidate().getSourceRecord();
                String winnerProfType = winnerAcc.Professional_Type_gne__c;
                String validProfessionalTypes = System.Label.DCH_CM_Valid_Professional_Types_gne;

                if(winnerProfType==null || validProfessionalTypes.indexOf(winnerProfType + ':')==-1) {
                    for(CORE_Merge_Interface.MergeCandidateInterface mc : mergeGroup.getLoserCandidates()) {
                        if(mc.isSourceValid()) {
                            Account loserAcc = (Account)mc.getSourceRecord();
                            if(loserAcc.Cases1__r!=null && !loserAcc.Cases1__r.isEmpty()) {
                                isOk = false;
                                String errMsg = String.format(ERROR_MESSAGE_NON_PRESCRIBER_WITH_CASES, new String[]{mergeGroup.getWinnerCandidate().print(), mc.print()});
                                mergeEngine.handleException(new CORE_Merge_Util.MergeCandidateException('LoserHcpHasCasesForNonPrescriber', errMsg), mc);
                            }
                        }
                    }
                }
            }

            return isOk;
        }

        private Boolean checkParentAccount(
            CORE_Merge_Interface.MergeGroupInterface mergeGroup,
            CORE_Merge_Interface.MergeEngineInterface mergeEngine,
            CORE_Merge_Interface.MergeObjectInterface mergeObject
        ) {
            Boolean isValidationSuccessfully = true;
            if(mergeGroup.getWinnerCandidate().isSourceValid()) {
                isValidationSuccessfully = runValitadionForCandidates(mergeGroup, mergeEngine, mergeObject);
            }
            return isValidationSuccessfully;
        }

        private Boolean runValitadionForCandidates(
            CORE_Merge_Interface.MergeGroupInterface mergeGroup,
            CORE_Merge_Interface.MergeEngineInterface mergeEngine,
            CORE_Merge_Interface.MergeObjectInterface mergeObject
        ) {
            Boolean isValidationSuccessfully = true;
            Set<Id> allCandidatesIds = new Set<Id>(mergeGroup.getAllIds());
            for(CORE_Merge_Interface.MergeCandidateInterface mc :mergeGroup.getAllCandidates()) {
                Account candidate = (Account)mc.getSourceRecord();
                if(candidate != null && candidate.parentId != null && allCandidatesIds.contains(candidate.parentId)){
                    String errorCode =  mergeObject.getPropertyErrorCode(
                        CORE_Merge_Configuration.MergeProperty.CustomMergeValidation.name(),
                         ACTION_PARENT_LOOKUP_DETECTOR
                    );
                    errorCode = errorCode == null ? 'Parent Lookup Loop Detected' : errorCode;
                    isValidationSuccessfully = false;
                    String errMsg = String.format(ERROR_MESSAGE_LOOKUP_DETECTED_ISSUE, new String[]{candidate.parentId, candidate.Id});
                    mergeEngine.handleException(new CORE_Merge_Util.MergeCandidateException(errorCode, errMsg), mc);
                }
            }
            return isValidationSuccessfully;
        }

        private void createArchiveAccountCloneForAddresses(CORE_Merge_Interface.MergeGroupInterface mergeGroup) {
            Id winnerId = null;
            List<Address_vod__c> archiveClones = new List<Address_vod__c>();

            for(CORE_Merge_Interface.MergeCandidateInterface mc : mergeGroup.getAllCandidates()) {
                if(mc.isSourceValid() && mc.getArchiveClone()!=null) {
                    if(mc.isWinner()) {
                        winnerId =  mc.getSourceRecord().Id;
                    }

                    Address_vod__c archiveClone = (Address_vod__c)mc.getArchiveClone();
                    archiveClones.add(archiveClone);
                }
            }

            if(winnerId!=null) {
                Account parentAccount = [SELECT Account_vod__r.Id, Account_vod__r.Name, Account_vod__r.FirstName, Account_vod__r.LastName, Account_vod__r.IsPersonAccount FROM Address_vod__c WHERE Id = :winnerId].Account_vod__r;
                String accMergeObjExtId = parentAccount.IsPersonAccount ? MERGE_OBJECT_HCP : MERGE_OBJECT_HCO;
                CORE_Merge_Object__c mObj = CORE_Merge_Configuration.getMergeObject(accMergeObjExtId);
                Id archiveOwnerId = (Id)CORE_Merge_Configuration.getPropertyValue(mObj, CORE_Merge_Configuration.MergeProperty.ArchiveOwner);
                Id archiveRecordTypeId = (Id)CORE_Merge_Configuration.getPropertyValue(mObj, CORE_Merge_Configuration.MergeProperty.ArchiveRecordType);
                String archiveMasterIdField = CORE_Merge_Configuration.getPropertyStringValue(mObj, CORE_Merge_Configuration.MergeProperty.ArchiveMasterIdField);
                String archiveIdField = CORE_Merge_Configuration.getPropertyStringValue(mObj, CORE_Merge_Configuration.MergeProperty.ArchiveIdField);
                SObject archiveCloneFieldDefaults = (SObject)CORE_Merge_Configuration.getPropertyValue(mObj, CORE_Merge_Configuration.MergeProperty.ArchiveCloneFieldDefaults);

                Account accountArchiveClone = new Account();
                accountArchiveClone.OwnerId = archiveOwnerId;
                accountArchiveClone.RecordTypeId = archiveRecordTypeId;
                accountArchiveClone.put(archiveMasterIdField, parentAccount.Id);
                accountArchiveClone.put(archiveIdField, parentAccount.Id);

                if(parentAccount.IsPersonAccount) {
                    accountArchiveClone.FirstName = parentAccount.FirstName;
                    accountArchiveClone.LastName = parentAccount.LastName;
                } else {
                    accountArchiveClone.Name = parentAccount.Name;
                }

                if(archiveCloneFieldDefaults!=null) {
                    Set<String> defaultFieldNames = CORE_Merge_Util.getFieldNamesFromSObject(archiveCloneFieldDefaults);

                    for(String fieldName : defaultFieldNames) {
                        accountArchiveClone.put(fieldName, archiveCloneFieldDefaults.get(fieldName));
                    }
                }

                accountArchiveClone.DCH_Action_gne__c = DCH_ACTION_RELATED_LIST_LOGIC;
                insert accountArchiveClone;

                for(Address_vod__c addr : archiveClones) {
                    addr.Account_vod__c = accountArchiveClone.Id;
                }
            }
        }

        private Boolean updateClassifications(CORE_Merge_Interface.MergeCandidateInterface winnerMc, List<CORE_Merge_Interface.MergeCandidateInterface> mcs) {
	        Boolean bWinnerObjectUpdated = false;
	        Account winnerAccount = (Account)winnerMc.getSourceRecordToUpdate();
	        Set<Id> accIds = new Set<Id>();

	        for(CORE_Merge_Interface.MergeCandidateInterface mc : mcs) {
	            if(mc.isSourceValid()) {
	                accIds.add(mc.getSourceRecord().Id);
	            }
	        }

	        List<Account> accounts = [
	            SELECT
	                Id,
	                EDM_Business_Classification_gne__c,
	                EDM_Business_Classification_Date_gne__c,
                    EDM_Business_Classification_DateTime_gne__c,
                    EDM_Business_Classification_CV_gne__c,
                    EDM_Business_Cl_Role_gne__c,
	                EDM_Clinical_Classification_gne__c,
	                EDM_Clinical_Classification_Date_gne__c,
                    EDM_Clinical_Classification_DateTime_gne__c,
                    EDM_Clinical_Classification_CV_gne__c
	            FROM Account
	            WHERE Id in :accIds
	        ];

	        DateTime winnerBCDate = null; DateTime winnerCCDate = null;
	        DateTime nearestBCDate = null; DateTime nearestCCDate = null;
            Account nearestBCAccount = null; Account nearestCCAccount = null;

	        for(Account acc : accounts) {
                DateTime businessClassifDate = acc.EDM_Business_Classification_DateTime_gne__c == null ? acc.EDM_Business_Classification_Date_gne__c : acc.EDM_Business_Classification_DateTime_gne__c;
                DateTime clinicalClassifDate = acc.EDM_Clinical_Classification_DateTime_gne__c == null ? acc.EDM_Clinical_Classification_Date_gne__c : acc.EDM_Clinical_Classification_DateTime_gne__c;

	            if(acc.Id == winnerAccount.Id) {
	                winnerBCDate = businessClassifDate;
	                winnerCCDate = clinicalClassifDate;
	            } else {
	                if(businessClassifDate!=null && (nearestBCDate==null || businessClassifDate > nearestBCDate)) {
	                    nearestBCDate = businessClassifDate;
                        nearestBCAccount = acc;
	                }

	                if(clinicalClassifDate!=null && (nearestCCDate==null || clinicalClassifDate > nearestCCDate)) {
	                    nearestCCDate = clinicalClassifDate;
                        nearestCCAccount = acc;
	                }
	            }
	        }

	        if(nearestBCDate!=null && (winnerBCDate==null || nearestBCDate > winnerBCDate)) {
                winnerAccount.EDM_Business_Classification_Date_gne__c = nearestBCAccount.EDM_Business_Classification_Date_gne__c;
	            winnerAccount.EDM_Business_Classification_DateTime_gne__c = nearestBCAccount.EDM_Business_Classification_DateTime_gne__c;
	            winnerAccount.EDM_Business_Classification_gne__c = nearestBCAccount.EDM_Business_Classification_gne__c;
                winnerAccount.EDM_Business_Classification_CV_gne__c = nearestBCAccount.EDM_Business_Classification_CV_gne__c;
                winnerAccount.EDM_Business_Cl_Role_gne__c = nearestBCAccount.EDM_Business_Cl_Role_gne__c;
	            bWinnerObjectUpdated = true;
	        }

	        if(nearestCCDate!=null && (winnerCCDate==null || nearestCCDate > winnerCCDate)) {
                winnerAccount.EDM_Clinical_Classification_Date_gne__c = nearestCCAccount.EDM_Clinical_Classification_Date_gne__c;
	            winnerAccount.EDM_Clinical_Classification_DateTime_gne__c = nearestCCAccount.EDM_Clinical_Classification_DateTime_gne__c;
	            winnerAccount.EDM_Clinical_Classification_gne__c = nearestCCAccount.EDM_Clinical_Classification_gne__c;
                winnerAccount.EDM_Clinical_Classification_CV_gne__c = nearestCCAccount.EDM_Clinical_Classification_CV_gne__c;
	            bWinnerObjectUpdated = true;
	        }

	        return bWinnerObjectUpdated;
	    }

	    private Boolean updateExclusions(CORE_Merge_Interface.MergeCandidateInterface winnerMc, List<CORE_Merge_Interface.MergeCandidateInterface> mcs) {
	        Boolean bWinnerObjectUpdated = false;
	        Account winnerAccount = (Account)winnerMc.getSourceRecordToUpdate();
	        Set<Id> accIds = new Set<Id>();

	        for(CORE_Merge_Interface.MergeCandidateInterface mc : mcs) {
	            if(mc.isSourceValid()) {
	                accIds.add(mc.getSourceRecord().Id);
	            }
	        }

	        List<Account> accounts = [
	            SELECT
	                Id,
	                AGS_EX_Exclusion_Status_base_gne__c,
	                AGS_EX_Date_Checked_Exclusion_gne__c
	            FROM Account
	            WHERE Id in :accIds
	        ];

	        Date winnerExDate = null;
	        Date nearestExDate = null;
	        String nearestExValue = null;

	        for(Account acc : accounts) {
	            if(acc.Id == winnerAccount.Id) {
	                winnerExDate = acc.AGS_EX_Date_Checked_Exclusion_gne__c;
	            } else {
	                if(acc.AGS_EX_Date_Checked_Exclusion_gne__c!=null && (nearestExDate==null || acc.AGS_EX_Date_Checked_Exclusion_gne__c > nearestExDate)) {
	                    nearestExDate = acc.AGS_EX_Date_Checked_Exclusion_gne__c;
	                    nearestExValue = acc.AGS_EX_Exclusion_Status_base_gne__c;
	              }
	            }
	        }

	        if(nearestExDate!=null && (winnerExDate==null || nearestExDate > winnerExDate)) {
	            winnerAccount.AGS_EX_Date_Checked_Exclusion_gne__c = nearestExDate;
	            winnerAccount.AGS_EX_Exclusion_Status_base_gne__c = nearestExValue;
	            bWinnerObjectUpdated = true;
	        }

	        return bWinnerObjectUpdated;
	    }

	    private Boolean updateLoserParentCalls(List<CORE_Merge_Interface.MergeCandidateInterface> loserMcs) {
	        Set<Id> loserObjectIdSet = new Set<Id>();

	        for(CORE_Merge_Interface.MergeCandidateInterface mc : loserMcs) {
	            if(mc.isSourceValid()) {
	                loserObjectIdSet.add(mc.getSourceRecord().Id);
	            }
	        }

	        List<Call2_vod__c> childCallsRelatedToLooserAccount = [
	            SELECT Id, Account_vod__c, Parent_Call_vod__c
	            FROM Call2_vod__c
	            WHERE Account_vod__c in :loserObjectIdSet
	                AND Parent_Call_vod__c != null
	        ];

	        Map<Id,Call2_vod__c> parentCallsToUpdate = new Map<Id,Call2_vod__c>();
	        for (Call2_vod__c call : childCallsRelatedToLooserAccount) {
	            if(!parentCallsToUpdate.containsKey(call.Parent_Call_vod__c)) {
	                parentCallsToUpdate.put(call.Parent_Call_vod__c, new Call2_vod__c(Id = call.Parent_Call_vod__c));
	            }
	        }

	        if(!parentCallsToUpdate.isEmpty()) {
	            update parentCallsToUpdate.values();
	        }

	        return false;
	    }

	    private void updateAddressPrimaryFlag(SObject winnerObject) {
	        updateAddressPrimaryFlag(winnerObject instanceof Address_vod__c ? (Id)winnerObject.get('Account_vod__c') : winnerObject.Id);
	    }

	    private void updateAddressPrimaryFlag(Id accId) {
	        List<Address_vod__c> addrs = [
	            SELECT
	                Id,
	                Primary_vod__c,
	                Inactive_vod__c,
	                Account_vod__r.Main_Address_gne__c,
	                (SELECT Call_Datetime_vod__c FROM Call2_vod__r ORDER BY Call_Datetime_vod__c DESC NULLS LAST LIMIT 1)
	            FROM Address_vod__c
	            WHERE Account_vod__c = :accId
	            ORDER BY Inactive_vod__c ASC, LastModifiedDate ASC
	        ];

	        List<Id> primaryAddrIds = new List<Id>();
	        Boolean activeAddressExists = false;
	        DateTime lastCallDateTime = null;
	        Id addrIdWithLatestCall = null;

	        for(Address_vod__c addr : addrs) {
	            if(addr.Primary_vod__c == true) {
	                primaryAddrIds.add(addr.Id);
	            }

	            if(!activeAddressExists && !addr.Inactive_vod__c) {
	                activeAddressExists = true;
	            }

	            if((!activeAddressExists || !addr.Inactive_vod__c) && !addr.Call2_vod__r.isEmpty() && (lastCallDateTime==null || addr.Call2_vod__r[0].Call_Datetime_vod__c>lastCallDateTime)) {
	                addrIdWithLatestCall = addr.Id;
	                lastCallDateTime = addr.Call2_vod__r[0].Call_Datetime_vod__c;
	            }
	        }

	        List<Address_vod__c> addrsToUpdate = new List<Address_vod__c>();
	        Id primaryAddrId = null;

	        if(primaryAddrIds.isEmpty() && !addrs.isEmpty()) {
	            primaryAddrId = addrIdWithLatestCall!=null ? addrIdWithLatestCall : addrs[0].Id;
	            addrsToUpdate.add(new Address_vod__c(Id = primaryAddrId, Primary_vod__c = true));
	        } else if(!primaryAddrIds.isEmpty()) {
	            primaryAddrId= primaryAddrIds.remove(0);

	            for(Id addrId : primaryAddrIds) {
	                addrsToUpdate.add(new Address_vod__c(Id = addrId, Primary_vod__c = false));
	            }
	        }

	        if(!addrsToUpdate.isEmpty()) {
	            update addrsToUpdate;
	        }

	        if(primaryAddrId!=null) {
	            Address_vod__c primaryAddr = new Map<Id,Address_vod__c>(addrs).get(primaryAddrId);

	            if(primaryAddr.Account_vod__r.Main_Address_gne__c != primaryAddr.Id) {
	                update new Account(Id = accId, Main_Address_gne__c =  primaryAddr.Id);
	            }
	        }
	    }

	    private void setTSFAddress(Address_vod__c addr) {
	        Id accId = addr.Account_vod__c;
	        // get all TSFs from loser addresses (reference to address won't be set)
	        List<TSF_vod__c> tsfs = [SELECT Account_vod__c, Territory_vod__c FROM TSF_vod__c WHERE Account_vod__c = :accId AND Address_vod__r.Id = null];

	        if(!tsfs.isEmpty()) {
	            GNE_SFA2_TSF_Field_Updates.updateAddressField(tsfs, false);
	            Database.update(tsfs);
	        }
	    }

	    private void setTSFAddress(List<TSF_vod__c> tsfs) {
            tsfs = [SELECT External_Id_vod__c, Account_vod__c, Territory_vod__c FROM TSF_vod__c WHERE Id IN :tsfs];

            if(!tsfs.isEmpty()) {
                GNE_SFA2_TSF_Field_Updates.updateAddressField(tsfs, false);
                Database.update(tsfs);
            }
        }

	    private void updateExternalId(List<SObject> recs) {
	        List<SObject> recsToUpdate;
	        SObject firstRec = recs.isEmpty() ? null : recs[0];

	        if(firstRec!=null && firstRec instanceof TSF_vod__c) {
	            List<TSF_vod__c> tsfs = [SELECT External_Id_vod__c, Account_vod__c, Territory_vod__c FROM TSF_vod__c WHERE Id IN :recs];
	            recsToUpdate = GNE_SFA2_TSF_Field_Updates.updateExternalIdField(tsfs);
	        } else if(firstRec!=null && firstRec instanceof Targets_and_Tiers_can_gne__c) {
	            List<Targets_and_Tiers_can_gne__c> tats = [SELECT External_Id_gne__c, Unique_Key_Calc_gne__c FROM Targets_and_Tiers_can_gne__c WHERE Id IN :recs];
	            recsToUpdate = GNE_SFA2_TargetsTiers_Field_Update.updateExternalId(tats);
	        } else if(firstRec!=null && firstRec instanceof Affiliation_vod__c) {
	            List<Affiliation_vod__c> affs = [SELECT External_Id_vod__c, From_Account_vod__c, From_Contact_vod__c, To_Account_vod__c, To_Contact_vod__c, Role_vod__c FROM Affiliation_vod__c WHERE Id IN :recs];
	            recsToUpdate = GNE_SFA2_Affiliation_Field_Updates.updateExternalId(affs);
	        } else if(firstRec!=null && firstRec instanceof Product_Metrics_vod__c) {
	            List<Product_Metrics_vod__c> bAffs = [SELECT Unique_Key_gne__c, Unique_Key_Calc_gne__c FROM Product_Metrics_vod__c WHERE Id IN :recs];
	            recsToUpdate = GNE_SFA2_Brand_Affil_Field_Updates.updateUniqueKey(bAffs);
	        } else if(firstRec!=null && firstRec instanceof User_Preference_gne__c) {
	            List<User_Preference_gne__c> uPrefs = [SELECT External_Id_gne__c, Unique_Key_Calc_gne__c FROM User_Preference_gne__c WHERE Id IN :recs];
	            recsToUpdate = GNE_SFA2_ExternalIdUpdater.setExternalId(uPrefs, String.valueOf(User_Preference_gne__c.External_Id_gne__c), String.valueOf(User_Preference_gne__c.Unique_Key_Calc_gne__c));
	        }

	        if(recsToUpdate!=null && !recsToUpdate.isEmpty()) {
	            Database.update(recsToUpdate, false);
	        }
	    }

        /**
         * update Account Id (as String) on VDST_EventPrtcpntAccnt_gne__c records
         */
         private void updateVdstEventPrtcpntAccnt(CORE_Merge_Interface.MergeGroupInterface mergeGroup) {
             List<VDST_EventPrtcpntAccnt_gne__c> forUpdate = [
                 SELECT Id, GNE_SFDC_ID_gne__c
                 FROM VDST_EventPrtcpntAccnt_gne__c
                 WHERE GNE_SFDC_ID_gne__c IN :mergeGroup.getAllIds()
                 	AND GNE_SFDC_ID_gne__c != :mergeGroup.getWinnerId()
                 	AND GNE_SFDC_ID_gne__c != NULL
             ];
             for(VDST_EventPrtcpntAccnt_gne__c record : forUpdate) {
                 record.GNE_SFDC_ID_gne__c = mergeGroup.getWinnerId();
             }
             Database.update(forUpdate, false);
         }

        /**
         * For HCO Account after merge should exist only one address    
         */
        private void avoidMoreThanOneAddressForHCO(SObject obj){
            Account acc = (Account) obj;
            //logic run only for HCO_FRM
            if(!checkRecordType(acc)) return;

            Address_vod__c[] existingAdrresses = fetchAccountAddresses(acc.Id);
            if(existingAdrresses.size() > 1){
                CORE_Merge_Candidate__c[] candidates = fetchAddressCandidates(existingAdrresses);
                Address_vod__c[]addressesWithOutCandidate = findAddressesWithOutCandidate(existingAdrresses, candidates);
                createCandidatesForAccounts(existingAdrresses, addressesWithOutCandidate, candidates);
            }
        }

        private Boolean checkRecordType (Account acc){
            Account tempAccount = [SELECT RecordTypeId FROM Account WHERE Id = :acc.Id];
            return recordTypesMap.containsKey(tempAccount.RecordTypeId);
        }

        private void createCandidatesForAccounts(Address_vod__c[] existingAdrresses, Address_vod__c[] addressesWithOutCandidate, CORE_Merge_Candidate__c[] candidates) {
            CORE_Merge_Candidate__c master;
            if(candidates.isEmpty()){
                Address_vod__c  oldestAddress = findOldestRecord(existingAdrresses);
                master = createWinnerCandidate(oldestAddress);
                CORE_Merge_Candidate__c[] candidatesToInsert = createCandidates(master, existingAdrresses);
                candidatesToInsert.add(master);
                executeDML(candidatesToInsert);
            } else if(!addressesWithOutCandidate.isEmpty()) {
                Map<Id, Address_vod__c> id2Address = new Map<Id, Address_vod__c>();
                for(Address_vod__c add : existingAdrresses){
                    id2Address.put(add.Id, add);
                }
                master = findOldestMaster(candidates, id2Address);
                CORE_Merge_Candidate__c[] candidatesToInsert = new CORE_Merge_Candidate__c[]{};
                if(master == null){
                    Address_vod__c  oldestAddress = findOldestRecord(existingAdrresses);
                    master = createWinnerCandidate(oldestAddress);
                    candidatesToInsert.add(master);
                }
                candidatesToInsert.addAll(createCandidates(master, addressesWithOutCandidate));

                executeDML(candidatesToInsert);
            }
        }

        private void executeDML(List<sObject> records) {
            Database.SaveResult[] sResults = Database.insert(records, false);
            handleErrors(sResults);
        }

        private void handleErrors(List<Database.SaveResult> sResults){
            for(Database.SaveResult result : sResults) {
                if(!result.isSuccess()) {
                    for(Database.Error err : result.getErrors()) {
                        System.debug('action: AVOID TO HAVE MORE THAN 1 ADDRESS: [INSERT ERROR] '  + err.getStatusCode() + ' - ' + err.getMessage());
                    }
                }
            }
        }

        private CORE_Merge_Candidate__c[] createCandidates(CORE_Merge_Candidate__c master, Address_vod__c[] addresses) {
            CORE_Merge_Candidate__c[] candidates = new CORE_Merge_Candidate__c[]{};
            for(Address_vod__c addr : addresses){
                if(master.Id_gne__c != addr.Id){
                    candidates.add(createCandidate(master, addr.Id));
                }
            }

            return candidates;
        }

        private CORE_Merge_Candidate__c createCandidate(CORE_Merge_Candidate__c master, Id addrId) {
            return new CORE_Merge_Candidate__c (
                Merge_Object_gne__c = master.Merge_Object_gne__c,
                Type_gne__c         = 'Merge',
                Source_gne__c       = 'Manual',
                Id_gne__c           = addrId,
                Master_Id_gne__c    = master.Id_gne__c,
                External_Id_gne__c  = addrId + '_' + master.Id_gne__c
            );
        }

        private CORE_Merge_Candidate__c createWinnerCandidate (Address_vod__c oldestAddres) {
            return new CORE_Merge_Candidate__c(
                Merge_Object_gne__c = MERGE_OBJECT_ADDRES_US.Id,
                Type_gne__c         = 'Merge',
                Source_gne__c       = 'Manual',
                Id_gne__c           = oldestAddres.Id,
                Master_Id_gne__c    = oldestAddres.Id,
                External_Id_gne__c  = oldestAddres.Id + '_' + oldestAddres.Id
            );
        }

        private Address_vod__c findOldestRecord(Address_vod__c[] existingAdrresses) {
            Address_vod__c oldestAddress;
            Datetime oldest = System.now();
            for(Address_vod__c addr : existingAdrresses){
                if(addr.CreatedDate < oldest){
                    oldest = addr.CreatedDate;
                    oldestAddress = addr;
                }
            }

            return oldestAddress;
        }

        private CORE_Merge_Candidate__c findOldestMaster(CORE_Merge_Candidate__c[] candidates, Map<Id, Address_vod__c> id2Address) {
            CORE_Merge_Candidate__c oldestCandidate;
            Datetime oldest = System.now();
            for(CORE_Merge_Candidate__c cand : candidates){
                if(cand.Candidate_Type_calc_gne__c  == 'WINNER'){
                    Address_vod__c add = id2Address.get(cand.Id_gne__c);
                    if(add.CreatedDate < oldest){
                        oldestCandidate = cand;
                        oldest = add.CreatedDate;
                    }
                }
            }

            return oldestCandidate;
        }

        private Address_vod__c[] findAddressesWithOutCandidate(Address_vod__c[]existingAdrresses, CORE_Merge_Candidate__c[] candidates) {
            Set<Id>existingCandidateIds = new Set<Id>();
            Address_vod__c[] addressesWithOutCandidate = new Address_vod__c[]{};
            for(CORE_Merge_Candidate__c cand : candidates){
                existingCandidateIds.add(cand.Id_gne__c);
            }
            for(Address_vod__c add : existingAdrresses){
                if(!existingCandidateIds.contains(add.Id)){
                    addressesWithOutCandidate.add(add);
                }
            }

            return addressesWithOutCandidate;
        }

        private CORE_Merge_Candidate__c [] fetchAddressCandidates(Address_vod__c[] existingAdrresses) {
            Set<Id> existingIds = new Set<Id>();
            for(Address_vod__c add : existingAdrresses){
                existingIds.add(add.Id);
            }
            return [
                SELECT Id_gne__c, Master_Id_gne__c, Candidate_Type_calc_gne__c, Merge_Object_gne__c
                FROM CORE_Merge_Candidate__c
                WHERE Id_gne__c IN :existingIds
                 AND Status_gne__c IN (:CORE_Merge_Util.CANDIDATE_STATUS_LOADED)
                   AND Type_gne__c IN (:CORE_Merge_Util.CANDIDATE_TYPE_MERGE)
            ];
        }

        private Address_vod__c[] fetchAccountAddresses(Id accId) {
        	return [SELECT Id, CreatedDate FROM Address_vod__c WHERE Account_vod__c = :accId];
        }

        private void moveAddressExternalId(CORE_Merge_Interface.MergeGroupInterface mergeGroup) {
            List<Address_vod__c> toUpdate = new List<Address_vod__c>();
            Address_vod__c winner = (Address_vod__c)mergeGroup.getWinnerCandidate().getSourceRecord();

            if(String.isNotBlank(winner.External_ID_vod__c)) return;

            Address_vod__c theCorrectRecordByLastModifiedDate;

            for(CORE_Merge_Util.MergeCandidateWrapper mcw: (List<CORE_Merge_Util.MergeCandidateWrapper>)mergeGroup.getLoserCandidates()) {
                Address_vod__c loser = (Address_vod__c) mcw.getSourceRecord();
                if(String.isBlank(loser.External_ID_vod__c)) continue;

                if(theCorrectRecordByLastModifiedDate == null){
                    theCorrectRecordByLastModifiedDate = loser;
                } else {
                    theCorrectRecordByLastModifiedDate = theCorrectRecordByLastModifiedDate.LastModifiedDate > loser.LastModifiedDate ? theCorrectRecordByLastModifiedDate : loser;
                }
            }
            if(theCorrectRecordByLastModifiedDate == null) return;

            String externalId = theCorrectRecordByLastModifiedDate.External_ID_vod__c;

            winner.External_ID_vod__c = theCorrectRecordByLastModifiedDate == null ? winner.External_ID_vod__c : externalId;
            toUpdate.add(winner);

            theCorrectRecordByLastModifiedDate.External_ID_vod__c += '_Merged_' + String.valueOf(Datetime.now() );
            toUpdate.add(theCorrectRecordByLastModifiedDate);

            Database.update(toUpdate);
        }

        /**
         *  during merge preserve the winner HCP/Address mapping only against the OLDEST FRM HCO account
         */
        private void mergeHcpAddressMapping(CORE_Merge_Interface.MergeGroupInterface mergeGroup) {
            Set<Id>addressIds = new Set<Id>(mergeGroup.getAllIds());
            List<FRM_HCO_Mapping_gne__c> hcoMappings = fetchHcoMappings(addressIds);

            Address_vod__c winner = (Address_vod__c)mergeGroup.getWinnerCandidate().getSourceRecord();
            if(winner.Account_vod__c != null && isHCPAddress(winner.Account_vod__c)){
                Id oldestHCO = findOldestHCO(hcoMappings);
                if(oldestHCO != null){
                    runDMLForMapping(hcoMappings, oldestHCO, mergeGroup.getWinnerId(), winner.Account_vod__c);
                }
            }
        }

        private List<FRM_HCO_Mapping_gne__c> fetchHcoMappings(Set<Id> addressIds) {
            return [
                SELECT Id, FRM_HCO_Account_gne__c, FRM_HCO_Account_gne__r.CreatedDate, HCP_Address_gne__c
                FROM FRM_HCO_Mapping_gne__c
                WHERE HCP_Address_gne__c IN : addressIds
            ];
        }

        private void runDMLForMapping(List<FRM_HCO_Mapping_gne__c> hcoMappings, Id oldestHCO, Id masterId, Id hcpAccountId) {
            List<FRM_HCO_Mapping_gne__c> toInsert = new List<FRM_HCO_Mapping_gne__c> ();
            List<FRM_HCO_Mapping_gne__c> toDelete = new List<FRM_HCO_Mapping_gne__c> ();
            FRM_HCO_Mapping_gne__c winnerMaping;

            for(FRM_HCO_Mapping_gne__c hMap : hcoMappings){
                if(hMap.FRM_HCO_Account_gne__c == oldestHCO && hMap.HCP_Address_gne__c == masterId && winnerMaping == null){
                    winnerMaping = hMap;
                } else {
                    toDelete.add(hMap);
                }
            }

            if(winnerMaping == null){
                delete [SELECT Id FROM HCP_To_FRM_HCO_Mapping_gne__c WHERE HCP_Address_gne__c = :masterId];
                winnerMaping = new FRM_HCO_Mapping_gne__c(HCP_Account_gne__c = hcpAccountId, HCP_Address_gne__c = masterId, FRM_HCO_Account_gne__c = oldestHCO);
                toInsert.add(winnerMaping);
            }

            delete toDelete;
            if(!toInsert.isEmpty()){
                insert winnerMaping;
            }
        }

        private Id findOldestHCO(List<FRM_HCO_Mapping_gne__c> hcoMappings) {
            Datetime oldest = System.now();
            Id oldestHCOId;
            for(FRM_HCO_Mapping_gne__c hMap : hcoMappings){
                if(hMap.FRM_HCO_Account_gne__r.CreatedDate < oldest){
                    oldest = hMap.FRM_HCO_Account_gne__r.CreatedDate;
                    oldestHCOId = hMap.FRM_HCO_Account_gne__c;
                }
            }
            return oldestHCOId;
        }

        private Boolean isHCPAddress(Id accountId) {
            return [SELECT Id, IsPersonAccount FROM Account WHERE ID = :accountId].IsPersonAccount;
        }

        /*
        * During merge addresses (Address-US) we want move one record from related lists of HCP_To_FRM_HCO_Mapping_gne__c & FRM_HCO_Mapping_gne__c from looser
        * only if these  related lista are empty.
        * If related lists on winner is not empty we remove related mapping from looser
        * We move only one record. Validadion to restrict related list size should be added on Address object 
        */
        private void avoidMoreThanOneMappingOnAddress(CORE_Merge_Interface.MergeGroupInterface mergeGroup) {
            Address_vod__c winner = (Address_vod__c)mergeGroup.getWinnerCandidate().getSourceRecord();
            Address_vod__c firstLooser = findLooser(mergeGroup);

            Boolean isEmptyWinnerMappingList = isEmptyWinnerMappingList(winner);
            if(isEmptyWinnerRelatedList(winner, isEmptyWinnerMappingList) && firstLooser != null) {
                updateMapping(firstLooser, winner);
            } else if(isEmptyWinnerMappingList && firstLooser != null) {
                updateMappingAndDeleteSuggested(firstLooser, winner);
            }
            deleteMappingsFromLoosers(mergeGroup);
        }

        private Address_vod__c findLooser(CORE_Merge_Interface.MergeGroupInterface mergeGroup) {
            Address_vod__c firstLooser;
            Map<Id, Address_vod__c> id2Looser = new Map<Id, Address_vod__c>();
            for(CORE_Merge_Interface.MergeCandidateInterface mc : mergeGroup.getLoserCandidates()){
                Address_vod__c addr = (Address_vod__c)mc.getSourceRecord();
                id2Looser.put(addr.Id, addr);
            }
            FRM_HCO_Mapping_gne__c [] mappings = [SELECT HCP_Address_gne__c FROM FRM_HCO_Mapping_gne__c WHERE HCP_Address_gne__c IN : id2Looser.keySet() LIMIT 1 ];
            if(!mappings.isEmpty()){
                FRM_HCO_Mapping_gne__c mapping = mappings[0];
                firstLooser =  id2Looser.get(mapping.HCP_Address_gne__c);
            }
            HCP_To_FRM_HCO_Mapping_gne__c [] suggestedMappings = [SELECT HCP_Address_gne__c FROM HCP_To_FRM_HCO_Mapping_gne__c WHERE HCP_Address_gne__c IN : id2Looser.keySet() LIMIT 1];
            if(!suggestedMappings.isEmpty() && firstLooser == null){
                HCP_To_FRM_HCO_Mapping_gne__c mapping = suggestedMappings[0];
                firstLooser = id2Looser.get(mapping.HCP_Address_gne__c);
            }
            return firstLooser;
        }

        private void deleteMappingsFromLoosers(CORE_Merge_Interface.MergeGroupInterface mergeGroup) {
            set<Id>looserIds = new Set<Id>();
            for(CORE_Merge_Interface.MergeCandidateInterface mc : mergeGroup.getLoserCandidates()){
                Address_vod__c addr = (Address_vod__c)mc.getSourceRecord();
                looserIds.add(addr.Id);
            }
            delete [
                SELECT Id
                FROM FRM_HCO_Mapping_gne__c
                WHERE HCP_Address_gne__c IN :looserIds
            ];
        }

        private Boolean isEmptyWinnerRelatedList(Address_vod__c winner, Boolean isEmptyWinnerMappingList) {
            Boolean result = [SELECT Id FROM HCP_To_FRM_HCO_Mapping_gne__c WHERE HCP_Address_gne__c = : winner.Id].isEmpty();
            result &= isEmptyWinnerMappingList;
            return result;
        }

        private Boolean isEmptyWinnerMappingList(Address_vod__c winner) {
            return [SELECT Id FROM FRM_HCO_Mapping_gne__c WHERE HCP_Address_gne__c = : winner.Id].isEmpty();
        }

        private void updateMapping(Address_vod__c firstLooser, Address_vod__c winner) {
            HCP_To_FRM_HCO_Mapping_gne__c[] suggestedMappingOnLooser = [SELECT Id, HCP_Address_gne__c FROM HCP_To_FRM_HCO_Mapping_gne__c WHERE HCP_Address_gne__c = : firstLooser.Id LIMIT 1];
            FRM_HCO_Mapping_gne__c [] mappingOnLooser = [SELECT Id, HCP_Address_gne__c FROM FRM_HCO_Mapping_gne__c WHERE HCP_Address_gne__c = : firstLooser.Id LIMIT 1];
            if(!mappingOnLooser.isEmpty() || !suggestedMappingOnLooser.isEmpty()){
            if(!mappingOnLooser.isEmpty()){
                    FRM_HCO_Mapping_gne__c toUpdate = mappingOnLooser[0];
                    toUpdate.HCP_Address_gne__c = winner.Id;
                    update toUpdate;
                } else {
                    HCP_To_FRM_HCO_Mapping_gne__c toUpdate = suggestedMappingOnLooser[0];
                    toUpdate.HCP_Address_gne__c = winner.Id;
                    update toUpdate;
                }
            }
        }

        private void updateMappingAndDeleteSuggested(Address_vod__c firstLooser, Address_vod__c winner) {
            FRM_HCO_Mapping_gne__c [] mappingOnLooser = [SELECT Id, HCP_Address_gne__c FROM FRM_HCO_Mapping_gne__c WHERE HCP_Address_gne__c = : firstLooser.Id LIMIT 1];
            if(!mappingOnLooser.isEmpty()){
                delete [SELECT Id FROM HCP_To_FRM_HCO_Mapping_gne__c WHERE HCP_Address_gne__c = :winner.Id];
                FRM_HCO_Mapping_gne__c toUpdate = mappingOnLooser[0];
                toUpdate.HCP_Address_gne__c = winner.Id;
                update toUpdate;
            }
        }

        /*
        * update PREP Account Testing Strategy. Winner always has LastModifiedDate bigest
        */
        private void updateAccountTestingStrategy(CORE_Merge_Interface.MergeGroupInterface mergeGroup) {
            Account winner = (Account)mergeGroup.getWinnerCandidate().getSourceRecord();
            Map<Id, Map<Id, SFA2_PREP_Account_MBO_gne__c>> accountId2MBO = createMapToCompare(mergeGroup);
            Map<Id, SFA2_PREP_Account_MBO_gne__c> tempWinners = findTempWinner(accountId2MBO);
            Map<Id, SFA2_PREP_Account_MBO_gne__c> toUpsert = new Map<Id, SFA2_PREP_Account_MBO_gne__c>();
            SFA2_PREP_Account_Testing_Strategy_gne__c [] toInsert = new SFA2_PREP_Account_Testing_Strategy_gne__c[]{};
            if(accountId2MBO.get(winner.Id)== null){
                //PREP Testing Strategy to SFA2_PREP_Account_Testing_Strategy_gne__c
                Map<Id, SFA2_PREP_Account_Testing_Strategy_gne__c> testStrId2AccountTestStrat = new Map<Id, SFA2_PREP_Account_Testing_Strategy_gne__c>();
                for(Id i :tempWinners.keySet()){
                    SFA2_PREP_Account_MBO_gne__c ambo = tempWinners.get(i);
                    if(testStrId2AccountTestStrat.get(ambo.Account_Testing_Strategy_gne__r.Testing_Strategy_gne__c) == null){
                        SFA2_PREP_Account_Testing_Strategy_gne__c ats = new SFA2_PREP_Account_Testing_Strategy_gne__c(
                            Account_gne__c = winner.Id,
                            Testing_Strategy_gne__c = ambo.Account_Testing_Strategy_gne__r.Testing_Strategy_gne__c,
                            External_Id_gne__c = winner.Id + '_1_'+ambo.Account_Testing_Strategy_gne__r.Testing_Strategy_gne__r.Name
                        );
                        testStrId2AccountTestStrat.put(ambo.Account_Testing_Strategy_gne__r.Testing_Strategy_gne__c, ats);
                    }
                    SFA2_PREP_Account_MBO_gne__c amboWinner = new SFA2_PREP_Account_MBO_gne__c(
                        Account_Testing_Strategy_gne__r = (new SFA2_PREP_Account_Testing_Strategy_gne__c(External_Id_gne__c = winner.Id + '_1_'+ambo.Account_Testing_Strategy_gne__r.Testing_Strategy_gne__r.Name)),
                        MBO_gne__c = ambo.MBO_gne__c,
                        Status_gne__c = ambo.Status_gne__c
                    );
                    toUpsert.put(ambo.MBO_gne__c, amboWinner);
                }
                toInsert.addAll(testStrId2AccountTestStrat.values());

            } else {
                Map<Id, SFA2_PREP_Account_MBO_gne__c> currentWinner = accountId2MBO.get(winner.Id);
                for(Id i :tempWinners.keySet()){
                    SFA2_PREP_Account_MBO_gne__c currentWin = currentWinner.get(i);
                    if(currentWin == null ) continue;
                    SFA2_PREP_Account_MBO_gne__c temp = findWinner(tempWinners.get(i), currentWin);
                    if(currentWin.Id != temp.Id && currentWin.Status_gne__c != temp.Status_gne__c){
                        currentWin.Status_gne__c = temp.Status_gne__c;
                        toUpsert.put(i, currentWin);
                    }
                }
            }

            GNE_SFA2_Util.updateAdminSetings(false);
            if(!toInsert.isEmpty()) insert toInsert;
            if(!toUpsert.isEmpty()) upsert toUpsert.values();
            GNE_SFA2_Util.updateAdminSetings(true);
        }

        private Map<Id, SFA2_PREP_Account_MBO_gne__c> findTempWinner(Map<Id, Map<Id, SFA2_PREP_Account_MBO_gne__c>> accountId2MBO) {
            Map<Id, SFA2_PREP_Account_MBO_gne__c> tempWinners = new Map<Id, SFA2_PREP_Account_MBO_gne__c>();
            for(Id i : accountId2MBO.keySet()){
                Map<Id, SFA2_PREP_Account_MBO_gne__c> mboMap = accountId2MBO.get(i);
                for(Id mbId :mboMap.keySet()){
                    SFA2_PREP_Account_MBO_gne__c toCompare = mboMap.get(mbId);
                    if(tempWinners.get(mbId) == null) {
                        tempWinners.put(mbId, toCompare);
                    } else {
                        SFA2_PREP_Account_MBO_gne__c tempWinner = tempWinners.get(mbId);
                        SFA2_PREP_Account_MBO_gne__c winner = findWinner(tempWinner, toCompare);
                        if(winner.Id == toCompare.Id){
                            tempWinners.put(mbId, toCompare);
                        }
                    }
                }
            }
            return tempWinners;
        }

        private SFA2_PREP_Account_MBO_gne__c findWinner(SFA2_PREP_Account_MBO_gne__c tempWinners, SFA2_PREP_Account_MBO_gne__c toCompare) {
            SFA2_PREP_Account_MBO_gne__c winner = tempWinners.LastModifiedDate > toCompare.LastModifiedDate ? tempWinners : toCompare;
            return winner;
        }

        private Map<Id, Map<Id, SFA2_PREP_Account_MBO_gne__c>> createMapToCompare (CORE_Merge_Interface.MergeGroupInterface mergeGroup) {
            Map<Id, Map<Id, SFA2_PREP_Account_MBO_gne__c>> accountId2MBO = new Map<Id, Map<Id, SFA2_PREP_Account_MBO_gne__c>>();
            for(SFA2_PREP_Account_MBO_gne__c ambo :[
                SELECT MBO_gne__c, Account_Testing_Strategy_gne__c, External_Id_gne__c, Status_gne__c, LastModifiedDate,
                    Account_Testing_Strategy_gne__r.Testing_Strategy_gne__c, Account_Testing_Strategy_gne__r.Testing_Strategy_gne__r.Name,
                    Account_Testing_Strategy_gne__r.Account_gne__c
                FROM SFA2_PREP_Account_MBO_gne__c
                WHERE Account_Testing_Strategy_gne__r.Account_gne__c IN  : mergeGroup.getAllIds()
            ]){
                Map<Id, SFA2_PREP_Account_MBO_gne__c> amboMap;
                if(accountId2MBO.get(ambo.Account_Testing_Strategy_gne__r.Account_gne__c) == null){
                    amboMap = new Map<Id, SFA2_PREP_Account_MBO_gne__c>();
                } else {
                    amboMap = accountId2MBO.get(ambo.Account_Testing_Strategy_gne__r.Account_gne__c);
                }
                amboMap.put(ambo.MBO_gne__c, ambo);
                accountId2MBO.put(ambo.Account_Testing_Strategy_gne__r.Account_gne__c, amboMap);
            }
            return accountId2MBO;
        }

        /*
    * block merge when one of account from group is FRM and at least one is non FRM 
    */
    private Boolean checkRecordTypesForAccounts(
        CORE_Merge_Interface.MergeGroupInterface mergeGroup,
        CORE_Merge_Interface.MergeEngineInterface mergeEngine,
        CORE_Merge_Interface.MergeObjectInterface mergeObject
    ) {
        Boolean isValidationSuccessfully = true;
        Set<Id> allCandidatesIds = new Set<Id>(mergeGroup.getAllIds());
        Boolean isFRMInGroup = false;
        Boolean isNonFRMInGroup = false;
        for(CORE_Merge_Interface.MergeCandidateInterface mc :mergeGroup.getAllCandidates()) {
            Account candidate = (Account)mc.getSourceRecord();
            if(checkRecordType(candidate) && !isFRMInGroup) {
                isFRMInGroup = true;
            }
            if(!checkRecordType(candidate) && !isNonFRMInGroup){
                isNonFRMInGroup = true;
            }
        }
        if(isFRMInGroup && isNonFRMInGroup){
            isValidationSuccessfully = false;
            for(CORE_Merge_Interface.MergeCandidateInterface mc :mergeGroup.getAllCandidates()) {
            Account candidate = (Account)mc.getSourceRecord();
                String errorCode =  mergeObject.getPropertyErrorCode(
                    CORE_Merge_Configuration.MergeProperty.CustomMergeValidation.name(),
                     ACTION_BLOCK_MERGE_FOR_FRM_AND_NONFRM
                );
                errorCode = errorCode == null ? 'In group are FRM and non FRM Account' : errorCode;
                isValidationSuccessfully = false;
                mergeEngine.handleException(new CORE_Merge_Util.MergeCandidateException(errorCode, errorCode), mc);
            }
        }

        return isValidationSuccessfully;
    }
    }
}