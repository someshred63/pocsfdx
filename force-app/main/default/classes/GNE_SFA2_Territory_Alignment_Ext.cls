/************************************************************
*  @author: Michal Hrycenko, Roche
*  Date: 2012-10-01
*  Description: This is a extension controller for GNE_SFA2_Territory_Alignment_Layout Page
*
*  Modification History
*  Date        Name                Description
*  11-22-2013  Piotr Przesmycki    Moved profile map initialization to init() method to save some view state
*  11-08-2014  Lukasz Bieniawski   Added dynamic Page creation logic using javascript, optimized Apex methods and marked as RemoteAction
*************************************************************/

global without sharing class GNE_SFA2_Territory_Alignment_Ext {

    public Id accountId { get; private set; }
    public Boolean isPersonAccount { get; private set; }

    public GNE_SFA2_Territory_Alignment_Ext(ApexPages.StandardController controller) {
        this.accountId = controller.getId();
        this.isPersonAccount = ((Account)controller.getRecord()).IsPersonAccount;
    }

    @RemoteAction
    @ReadOnly
    global static ControllerData loadControllerData(Id accountId, Boolean isPersonAccount) {
        UserContext userContext = new UserContext();
        ControllerData remoteActionResult = new ControllerData(userContext, isPersonAccount);
        try {
            /* Get Groups FROM DB */
            List<Group> groups = [SELECT Id, RelatedId FROM Group WHERE RelatedId IN :userContext.userTerritoriesMap.keySet() AND Type = 'Territory'];
            Map<Id,Id> groupsMap = new Map<Id,Id>();
            for(Group g : groups) {
                groupsMap.put(g.Id, g.RelatedId);
            }

            /* Get AccountShares FROM DB */
            Map<Id,AccountShare> accountShareMap = new Map<Id,AccountShare>();
            for(AccountShare acctShare : [SELECT UserOrGroupId, LastModifiedby.Name, LastModifiedby.Profile.Name
                FROM AccountShare WHERE UserOrGroupId IN :groups AND AccountId = :accountId AND RowCause ='Territory2AssociationManual']) {
                accountShareMap.put(groupsMap.get(acctShare.UserOrGroupId), acctShare);
            }

            /* Get Account TSFs FROM DB */
            Map<String, TSF_vod__c> accountTSFsMap = new Map<String, TSF_vod__c>();
            Map<String, Boolean> userEditModeMap = new Map<String, Boolean>(); //Get User Edit Mode
            for(TSF_vod__c tsf : [SELECT Id, Territory_vod__c, My_Target_vod__c, LastModifiedBy.Name, LastModifiedby.Profile.Name
                FROM TSF_vod__c WHERE Account_vod__c = :accountId AND External_Id_vod__c != null AND Address_vod__c != null
                AND Territory_vod__c IN :userContext.userTerritoriesNames]) {
                accountTSFsMap.put(tsf.Territory_vod__c, tsf);
                if(userContext.profileName == tsf.LastModifiedBy.Profile.Name || userContext.hasMedAffairProfile || userContext.hasAtlsProfile
                    || userContext.hasCanadianProfile || userContext.hasFRMProfile || userContext.hasPrepProfile) {
                    userEditModeMap.put(tsf.Territory_vod__c, true);
                }
            }

            /* Get Tier Level Assignments */
            Map<String, Tier_Level_Assignment_gne__c> tierLevelAssignmentMap = new Map<String, Tier_Level_Assignment_gne__c>();
            if (userContext.hasTierLevelAssignmentContext){
                for (Tier_Level_Assignment_gne__c tierLevelAssignment : [SELECT Id, TSF_vod__c, Tier_Level_gne__c, Goal_gne__c, Account_gne__c, Territory_Id_gne__c, Territory_Name_gne__c
                    FROM Tier_Level_Assignment_gne__c WHERE Account_gne__c = :accountId AND Territory_Id_gne__c In :userContext.userTerritoriesMap.keyset()]){
                    tierLevelAssignmentMap.put(tierLevelAssignment.Territory_Id_gne__c, tierLevelAssignment);
                }
            }

            /* Sort User Territories Map */
            List<Territory2> tempList = userContext.userTerritoriesMap.values().clone();
            GNE_SFA2_Util.sortList(tempList, 'Name', true);

            remoteActionResult.territoryToAccountAlignmentSortedList.clear();
            for(Territory2 territory : tempList) {
                remoteActionResult.territoryToAccountAlignmentSortedList.add(new AccountAlignmentItem(userContext, territory,
                    accountShareMap.get(territory.Id), accountTSFsMap.get(territory.Name), userEditModeMap.get(territory.Name), isPersonAccount, tierLevelAssignmentMap.get(territory.Id)));
            }
        } catch(Exception ex){
            remoteActionResult.errorMessages.add('TerritoryAlignment:loadControllerData: ' + ex.getMessage());
        }
        return remoteActionResult;
    }

    @RemoteAction
    global static AlignmentRemoteActionResult setAlignedInMyView(Id accountId, Id territoryId, String territoryName){
        System.debug('#wk In setAlignedInMyView');
        AlignmentRemoteActionResult remoteActionResult = new AlignmentRemoteActionResult(territoryName);
        Savepoint savePoint = Database.setSavepoint();
        try {
            Boolean isUpdate = upsertTSF(accountId, territoryName, true);
            if (!isUpdate || (isUpdate && getAccountShares(GNE_SFA2_Territory_Alignment_Helper.getGroupId(territoryId), accountId).isEmpty())){
                insertSharingMgmt(accountId, territoryId, territoryName);
            }
            if(GNE_SFA2_Util.isCanadaRAMA()) {
                updateAccountTypeForRAMA(accountId);
            }
            remoteActionResult.hasBrandAffiliationChanged = insertBrandAffiliation(accountId, territoryName, territoryId);
            remoteActionResult.setUserAccountRecordAccessResult(accountId);
            String message = 'Aligned to ' + territoryName + ' as a target.<br/>Will now appear in the My... view(s) on the My Accounts tab.';
            remoteActionResult.infoMessages.add(message);
        } catch(Exception ex) {
            Database.rollback(savePoint);
            remoteActionResult.setRedirectToErrorPage('setAlignedInMyView', ex, Page.GNE_SFA2_Account_Layout);
        }
        return remoteActionResult;
    }

    @RemoteAction
    global static AlignmentRemoteActionResult setAlignedInAllView(Id accountId, Id territoryId, String territoryName){
        System.debug('#wk In setAlignedInAllView');
        AlignmentRemoteActionResult remoteActionResult = new AlignmentRemoteActionResult(territoryName);
        Savepoint savePoint = Database.setSavepoint();
        try {
            Boolean isUpdate = upsertTSF(accountId, territoryName, false);
            if (!isUpdate || (isUpdate && getAccountShares(GNE_SFA2_Territory_Alignment_Helper.getGroupId(territoryId), accountId).isEmpty())){
                insertSharingMgmt(accountId, territoryId, territoryName);
            }
            if(GNE_SFA2_Util.isCanadaRAMA()) {
                updateAccountTypeForRAMA(accountId);
            }
            remoteActionResult.hasBrandAffiliationChanged = insertBrandAffiliation(accountId, territoryName, territoryId);
            remoteActionResult.setUserAccountRecordAccessResult(accountId);
            String message = 'Aligned to ' + territoryName + ' as a non-Target.<br/>Will only be visible in the All... view(s) on the My Accounts tab.';
            remoteActionResult.infoMessages.add(message);
        } catch(Exception ex) {
            Database.rollback(savePoint);
            remoteActionResult.setRedirectToErrorPage('setAlignedInAllView', ex, Page.GNE_SFA2_Account_Layout);
        }
        return remoteActionResult;
    }

    @RemoteAction
    global static AlignmentRemoteActionResult setNotAligned(Id accountId, Id territoryId, String territoryName, Boolean editMode){
        AlignmentRemoteActionResult remoteActionResult = new AlignmentRemoteActionResult(territoryName);
        if (editMode == false){
            return remoteActionResult;
        }
        Savepoint savePoint = Database.setSavepoint();
        try {
            // Delete Account Share
            insertSharingMgmt(accountId, territoryId, territoryName, true);
            // Delete TSF
            TSF_vod__c tsf = [SELECT Id FROM TSF_vod__c WHERE Account_vod__c = :accountId AND Territory_vod__c = :territoryName];
            delete tsf;
            remoteActionResult.setUserAccountRecordAccessResult(accountId);
            String message = 'Unaligned from ' + territoryName + '.<br/>It will not be in any of the ' + territoryName + ' views on the My Accounts tab.';
            remoteActionResult.infoMessages.add(message);
        } catch(Exception ex) {
            Database.rollback(savePoint);
            remoteActionResult.setRedirectToErrorPage('setNotAligned', ex, Page.GNE_SFA2_Account_Layout);
        }
        return remoteActionResult;
    }

    @RemoteAction
    global static GNE_SFA2_Remoting_Base.RemoteActionResult updateTierLevelRecord(Id accountId, String tsfId, String tierLevelId, String territoryId, String territoryName, String tierLevelValue, String goalValue){
        GNE_SFA2_Remoting_Base.RemoteActionResult remoteActionResult = new GNE_SFA2_Remoting_Base.RemoteActionResult();
        Savepoint savePoint = Database.setSavepoint();
        try {
            Tier_Level_Assignment_gne__c tierLevelRecord = new Tier_Level_Assignment_gne__c(
                Account_gne__c = accountId,
                Territory_Id_gne__c = territoryId,
                Territory_Name_gne__c = territoryName,
                Tier_Level_gne__c = tierLevelValue,
                Goal_gne__c = goalValue
            );
            if (String.isNotBlank(tsfId)){
                tierLevelRecord.TSF_vod__c = tsfId;
            }
            if (String.isNotBlank(tierLevelId)){
                tierLevelRecord.Id = tierLevelId;
                update tierLevelRecord;
            } else {
                insert tierLevelRecord;
            }
        } catch(Exception ex){
            Database.rollback(savePoint);
            remoteActionResult.setRedirectToErrorPage('updateTierLevelRecord', ex, Page.GNE_SFA2_Account_Layout);
        }
        return remoteActionResult;
    }

    @TestVisible
    private static List<Product_Metrics_vod__c> getBrandAffiliationsToInsert(Id accountId, String territoryName) {
        String territoryCode = GNE_SFA2_Territory_Alignment_Helper.getTerritoryCode(territoryName);
        return GNE_SFA2_Territory_Alignment_Helper.getBrandAffiliationsToInsert(territoryCode, new List<Id>{accountId});
    }

    private static Boolean insertBrandAffiliation(Id accountId, String territoryName, Id territoryId){
        List<Product_Metrics_vod__c> brandAffiliations = getBrandAffiliationsToInsert(accountId, territoryName);
        if(brandAffiliations.size() > 0){
            insert brandAffiliations;
        }
        GNE_SFA2_Territory_Alignment_Helper.alignBrandAffiliationsForTLCRM(new Set<Id>{accountId}, territoryId);
        return brandAffiliations.size() > 0;
    }

    private static void insertSharingMgmt(Id accountId, Id territoryId, String territoryName){
        insertSharingMgmt(accountId, territoryId, territoryName, false);
    }

    private static void insertSharingMgmt(Id accountId, Id territoryId, String territoryName, Boolean forDelete){
        insert new Sharing_Mgmt_gne__c(
            Object_Name_gne__c = 'AccountShare',
            Account_Id_gne__c = accountId,
            Territory_Id_gne__c = territoryId,
            Territory_Name_gne__c = territoryName,
            Schedule_Date_Time_gne__c = System.Today(),
            Operation_gne__c = (forDelete == true ? 'Delete' : 'Insert'),
            Status_gne__c = 'New'
        );
    }

    private static Boolean upsertTSF(Id accountId, String territoryName, Boolean isMyTarget){
        TSF_vod__c tsf = null;
        List<TSF_vod__c> existedTSFs = [SELECT Id, My_Target_vod__c, Is_Self_Alignment_gne__c FROM TSF_vod__c
            WHERE Account_vod__c = :accountId AND Territory_vod__c = :territoryName AND External_Id_vod__c != null limit 1];
        Boolean isUpdate = existedTSFs.isEmpty() == false;
        if (isUpdate){
            tsf = existedTSFs[0];
        } else {
            tsf = new TSF_vod__c(
                Account_vod__c = accountId,
                Territory_vod__c = territoryName
            );
        }

        tsf.My_Target_vod__c = isMyTarget;
        tsf.Is_Self_Alignment_gne__c = true;

        if (isUpdate){
            update tsf;
        } else {
            insert tsf;
        }
        return isUpdate;
    }

    @TestVisible
    private static List<AccountShare> getAccountShares(String groupId, Id accountId){
        return [SELECT Id FROM AccountShare WHERE UserOrGroupId = :groupId AND AccountId = :accountId AND RowCause = 'Territory2AssociationManual'];
    }

    private static void updateAccountTypeForRAMA(Id accountId) {
        Account account = [SELECT Id, Account_Type_RAMA_gne__c, Account_Type_gne__c FROM Account WHERE Id =: accountId];
        account.Account_Type_RAMA_gne__c = account.Account_Type_gne__c;
        update account;
    }

    global class UserContext {
        public String profileName { get; private set; }
        //public Boolean hasHCVProfile { get; private set; }
        public Boolean hasAtlsProfile { get; private set; }
        public Boolean hasMedAffairProfile { get; private set; }
        public Boolean hasCanadianProfile { get; private set; }
        public Boolean hasFRMProfile { get; private set; }
        public Boolean hasPrepProfile { get; private set; }
        public Boolean has340BProfile { get; private set; }
        public Map<Id, Territory2> userTerritoriesMap { get; private set; }
        public Set<String> userTerritoriesNames { get; private set; }
        public Boolean hasTierLevelAssignmentContext { get; private set; }

        public UserContext(){
            this.profileName = GNE_SFA2_Util.getCurrentUserProfileName();
            //this.hasHCVProfile = GNE_SFA2_HCV_Profiles__c.getAll().containsKey(this.profileName);
            this.hasAtlsProfile = GNE_SFA2_ATLS_Profiles__c.getAll().containsKey(this.profileName);
            this.hasMedAffairProfile = GNE_SFA2_MedAffair_Users__c.getAll().containsKey(this.profileName);
            this.hasCanadianProfile = GNE_SFA2_Canadian_Users__c.getAll().containsKey(this.profileName);
            this.hasFRMProfile = this.profileName.containsIgnoreCase('FRM');
            this.hasPrepProfile = GNE_SFA2_PREP_Util.isPrepUser(this.profileName);
            this.userTerritoriesMap = getUserTerritoriesMap();
            this.userTerritoriesNames = getUserTerritoriesNames();
            this.hasTierLevelAssignmentContext = this.hasAtlsProfile == true;
            this.has340BProfile = this.profileName.containsIgnoreCase('GNE-MCCO-340B');
        }

        private Map<Id,Territory2> getUserTerritoriesMap() {
            Map<Id,Territory2> visibleTerritories = new Map<Id, Territory2>([SELECT Id, Name FROM Territory2
                WHERE Id IN (SELECT Territory2Id FROM UserTerritory2Association WHERE UserId = :UserInfo.getUserId() AND IsActive = true)]);
            if(this.hasMedAffairProfile && visibleTerritories.size() > 0) {
                Map<Id, Territory2> childTerritoriesFirstLevelMap = new Map<Id, Territory2>([SELECT Id, Name FROM Territory2
                    WHERE ParentTerritory2Id IN :visibleTerritories.keySet()]);
                if(childTerritoriesFirstLevelMap.size() > 0) {
                    visibleTerritories.putAll(childTerritoriesFirstLevelMap);
                    Map<Id, Territory2> childTerritoriesSecondLevelMap = new Map<Id, Territory2>([SELECT Id, Name FROM Territory2
                        WHERE ParentTerritory2Id IN :childTerritoriesFirstLevelMap.keySet()]);
                    if(childTerritoriesSecondLevelMap.size() > 0) {
                        visibleTerritories.putAll(childTerritoriesSecondLevelMap);
                        Map<Id, Territory2> childTerritoriesThirdLevelMap = new Map<Id, Territory2>([SELECT Id, Name FROM Territory2
                            WHERE ParentTerritory2Id IN :childTerritoriesSecondLevelMap.keySet()]);
                        if(childTerritoriesThirdLevelMap.size() > 0) {
                            visibleTerritories.putAll(childTerritoriesThirdLevelMap);
                            Map<Id, Territory2> childTerritoriesFourthLevelMap = new Map<Id, Territory2>([SELECT Id, Name FROM Territory2
                                WHERE ParentTerritory2Id IN :childTerritoriesThirdLevelMap.keySet()]);
                            if(childTerritoriesFourthLevelMap.size() > 0) {
                                visibleTerritories.putAll(childTerritoriesFourthLevelMap);
                            }
                        }
                    }
                }
            }
            return visibleTerritories;
        }

        private Set<String> getUserTerritoriesNames(){
            Set<String> territoryNames = new Set<String>();
            for (Territory2 territory : this.userTerritoriesMap.values()){
                territoryNames.add(territory.Name);
            }
            return territoryNames;
        }
    }

    public class AccountAlignmentItem {
        private Boolean accountIsPersonAccount { get; set; }
        private Boolean hasAcctShare { get; set; }
        private Boolean hasTSF { get; set; }
        private Boolean hasTSFmyTarget { get; set; }

        public Boolean alignedInMyView { get; private set; }
        public Boolean alignedInAllView { get; private set; }
        public Boolean notAligned { get; private set; }
        public String createdByName { get; private set; }
        public Boolean editMode { get; private set; }
        public String territoryName { get; private set; }
        public String territoryId { get; private set; }

        public String tsfId { get; private set; }
        public String tierLevelId { get; private set; }
        public String tierLevelValue { get; private set; }
        public String goalValue { get; private set; }

        public AccountAlignmentItem(UserContext userContext, Territory2 territory, AccountShare acctShare, TSF_vod__c tsf, Boolean editMode, Boolean accountIsPersonAccount, Tier_Level_Assignment_gne__c tierLevelAssignment) {
            this.territoryName = territory.Name;
            this.territoryId = territory.Id;
            this.hasAcctShare = acctShare != null;
            this.hasTSF = tsf != null;
            this.hasTSFmyTarget = this.hasTSF && tsf.My_Target_vod__c == true;
            this.editMode = editMode;
            this.accountIsPersonAccount = accountIsPersonAccount;
            this.alignedInMyView = getAlignedInMyView(userContext);
            this.alignedInAllView = getAlignedInAllView(userContext);
            this.notAligned = getNotAligned(userContext);
            this.createdByName = getCreatedBy(userContext, acctShare, tsf);
            this.tsfId = tsf != null ? tsf.Id : null;
            this.tierLevelId = tierLevelAssignment != null ? tierLevelAssignment.Id : null;
            this.tierLevelValue = tierLevelAssignment != null ? tierLevelAssignment.Tier_Level_gne__c : null;
            this.goalValue = tierLevelAssignment != null ? tierLevelAssignment.Goal_gne__c : null;
        }

        private Boolean getAlignedInMyView(UserContext userContext){
            if (userContext.hasFRMProfile){
                if (this.hasTSF) {
                    return true;
                }
            } else {
                if (userContext.hasMedAffairProfile){
                    if (this.hasTSFmyTarget){
                        return true;
                    }
                } else {
                    if (userContext.hasCanadianProfile && this.accountIsPersonAccount){
                        if (this.hasTSF){
                            return true;
                        }
                    } else {
                        if (this.hasTSFmyTarget){
                            return true;
                        }
                    }
                }
            }
            return false;
        }

        private Boolean getAlignedInAllView(UserContext userContext){
            if (!userContext.hasFRMProfile && !userContext.hasMedAffairProfile
                && !(userContext.hasCanadianProfile && this.accountIsPersonAccount)){
                if (this.hasTSF && this.hasTSFmyTarget == false){
                    return true;
                }
            }

            return false;
        }

        private Boolean getNotAligned(UserContext userContext){
            if (userContext.hasFRMProfile){
                if (this.hasTSF == false){
                    return true;
                }
            } else {
                if (userContext.hasMedAffairProfile){
                    if (this.hasTSF == false || this.hasTSFmyTarget == false){
                        return true;
                    }
                } else {
                    if (userContext.hasCanadianProfile && this.accountIsPersonAccount){
                        if (this.hasTSF == false){
                            return true;
                        }
                    } else {
                        if (this.hasTSF == false){
                            return true;
                        }
                    }
                }
            }
            return false;
        }

        private String getCreatedBy(UserContext userContext, AccountShare acctShare, TSF_vod__c tsf){
            if((this.hasAcctShare && this.hasTSF && userContext.hasMedAffairProfile == false)
                || (this.hasAcctShare && this.hasTSFmyTarget && userContext.hasMedAffairProfile)) {
                return acctShare.LastModifiedBy.Name;
            } else if((this.hasTSF && userContext.hasMedAffairProfile == false)
                || (this.hasTSFmyTarget && userContext.hasMedAffairProfile)) {
                return tsf.LastModifiedBy.Name;
            } else {
                return '';
            }
        }
    }

    global class ControllerData extends GNE_SFA2_Remoting_Base.RemoteActionResult {
        public List<AccountAlignmentItem> territoryToAccountAlignmentSortedList { get; set; }
        public Map<Integer, ColumnDescription> columnDescriptions { get; private set; }
        public Set<String> userTerritoriesNames { get; private set; }

        public ControllerData(UserContext userContext, Boolean isPersonAccount){
            this.territoryToAccountAlignmentSortedList = new List<AccountAlignmentItem>();
            this.userTerritoriesNames = userContext.userTerritoriesNames;
            initColumnDescriptions(userContext, isPersonAccount);
        }

        private void initColumnDescriptions(UserContext userContext, Boolean isPersonAccount){
            Map<Integer, String> columnOrderToLabelMap = new Map<Integer, String>{
                0 => 'Territory Name',
                1 => 'Aligned in My View',
                2 => 'Aligned',
                3 => 'Aligned in My Territory',
                4 => 'Aligned in My Territory',
                5 => 'Aligned in All View',
                6 => 'Not Aligned',
                8 => 'Created By'
            };
            if (userContext.hasTierLevelAssignmentContext){
                columnOrderToLabelMap.put(6, GNE_SFA2_Application_Cache.describeObject('Tier_Level_Assignment_gne__c').fields.getMap().get(String.valueOf(Tier_Level_Assignment_gne__c.Tier_Level_gne__c)).getDescribe().getLabel());
                columnOrderToLabelMap.put(7, GNE_SFA2_Application_Cache.describeObject('Tier_Level_Assignment_gne__c').fields.getMap().get(String.valueOf(Tier_Level_Assignment_gne__c.Goal_gne__c)).getDescribe().getLabel());
            }
            this.columnDescriptions = new Map<Integer, ColumnDescription>();
            for (Integer fieldOrder : columnOrderToLabelMap.keyset()){
                String fieldLabel = columnOrderToLabelMap.get(fieldOrder);
                if (fieldOrder == 0){ // Territory Name
                    ColumnDescription displayColumn = new ColumnDescription(fieldLabel);
                    displayColumn.width = '40%';
                    this.columnDescriptions.put(fieldOrder, displayColumn);
                } else if (fieldOrder == 1){ // Aligned in My View
                    if ((!userContext.hasCanadianProfile && !userContext.hasFRMProfile && !userContext.has340BProfile) || (userContext.hasCanadianProfile && !isPersonAccount) ){
                        ColumnDescription displayColumn = new ColumnDescription(fieldLabel);
                        displayColumn.styleClass = 'alignCenter';
                        this.columnDescriptions.put(fieldOrder, displayColumn);
                    }
                } else if (fieldOrder == 2){ // Aligned
                    if (userContext.hasCanadianProfile && isPersonAccount){
                        ColumnDescription displayColumn = new ColumnDescription(fieldLabel);
                        displayColumn.styleClass = 'alignCenter';
                        this.columnDescriptions.put(fieldOrder, displayColumn);
                    }
                } else if (fieldOrder == 3){ // Aligned in My Territory
                    if (userContext.hasFRMProfile ){
                        ColumnDescription displayColumn = new ColumnDescription(fieldLabel);
                        displayColumn.styleClass = 'alignCenter';
                        this.columnDescriptions.put(fieldOrder, displayColumn);
                    }
                } else if (fieldOrder == 4){ // Aligned in My Territory for 340B
                    if (userContext.has340BProfile){
                        ColumnDescription displayColumn = new ColumnDescription(fieldLabel);
                        displayColumn.styleClass = 'alignCenter';
                        this.columnDescriptions.put(fieldOrder, displayColumn);
                    }
                } else if (fieldOrder == 5){ // Aligned in All View
                    if ((!userContext.hasMedAffairProfile && !userContext.hasCanadianProfile && !userContext.hasFRMProfile && !userContext.has340BProfile)
                        || (userContext.hasCanadianProfile && !isPersonAccount)){
                        ColumnDescription displayColumn = new ColumnDescription(fieldLabel);
                        displayColumn.styleClass = 'alignCenter';
                        this.columnDescriptions.put(fieldOrder, displayColumn);
                    }
                } else if (fieldOrder == 6){ // Not Aligned
                    ColumnDescription displayColumn = new ColumnDescription(fieldLabel);
                    displayColumn.styleClass = 'alignCenter';
                    this.columnDescriptions.put(fieldOrder, displayColumn);
                } else if (fieldOrder == 7){ // Tier Level
                    if (userContext.hasTierLevelAssignmentContext){
                        ColumnDescription displayColumn = new ColumnDescription(fieldLabel);
                        displayColumn.width = '100px';
                        Map<String, String> picklistValues = new Map<String, String>();
                        for (Schema.PicklistEntry pEntry : Tier_Level_Assignment_gne__c.Tier_Level_gne__c.getDescribe().getPicklistValues()){
                            picklistValues.put(pEntry.getValue(), pEntry.getLabel());
                        }
                        displayColumn.customParams.put('TierLevelPicklistValues', picklistValues);
                        this.columnDescriptions.put(fieldOrder, displayColumn);
                    }
                } else if (fieldOrder == 9){ // Goal
                    if (userContext.hasTierLevelAssignmentContext){
                        ColumnDescription displayColumn = new ColumnDescription(fieldLabel);
                        displayColumn.width = '100px';
                        Map<String, String> picklistValues = new Map<String, String>();
                        for (Schema.PicklistEntry pEntry : Tier_Level_Assignment_gne__c.Goal_gne__c.getDescribe().getPicklistValues()){
                            picklistValues.put(pEntry.getValue(), pEntry.getLabel());
                        }
                        displayColumn.customParams.put('GoalPicklistValue', picklistValues);
                        this.columnDescriptions.put(fieldOrder, displayColumn);
                    }
                } else if (fieldOrder == 8){ // Created By
                    ColumnDescription displayColumn = new ColumnDescription(fieldLabel);
                    displayColumn.width = '20%';
                    this.columnDescriptions.put(fieldOrder, displayColumn);
                }
            }
        }
    }

    public class ColumnDescription{
        public String label { get; private set; }
        public String width { get; set; }
        public String styleClass { get; set; }
        public Map<String,Object> customParams { get; set; }

        public ColumnDescription(String label){
            this.label = label;
            this.width = null;
            this.styleClass = 'alignLeft';
            this.customParams = new Map<String,Object>();
        }
    }

    global class AlignmentRemoteActionResult extends GNE_SFA2_Remoting_Base.RemoteActionResult {
        public String territoryName { get; set; }
        public Boolean hasBrandAffiliationChanged { get; set; }
        public Boolean hasAccountEditAccess { get; set; }
        public Boolean hasAccountDeleteAccess { get; set; }
        public Boolean hasAccountTransferAccess { get; set; }

        public AlignmentRemoteActionResult(String territoryName){
            this.territoryName = territoryName;
        }

        public void setUserAccountRecordAccessResult(Id accountId){
            UserRecordAccess userRecordAccess = GNE_SFA2_Util.getUserRecordAccess(UserInfo.getUserId(), accountId);
            this.hasAccountEditAccess = userRecordAccess.HasEditAccess;
            this.hasAccountDeleteAccess = userRecordAccess.HasDeleteAccess;
            this.HasAccountTransferAccess = userRecordAccess.HasTransferAccess;
        }
    }
}