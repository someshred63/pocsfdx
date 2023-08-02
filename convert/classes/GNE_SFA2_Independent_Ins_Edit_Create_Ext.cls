global with sharing class GNE_SFA2_Independent_Ins_Edit_Create_Ext extends GNE_SFA2_Dynamic_VF_Edit_Create {

    public String selectedAccountsJSON { get; set; }
    private Set<String> selectedAccountIds { get; set; }
    private List<Account> selectedAccounts { get; set; }
    public String accountIdToRemoveFromSelected { get; set; }

    public Independent_Insight_vod__c currentIndependentInsight { get; set; }
    public Boolean newIndependentInsightMode { get; set; }
    public List<SelectOption> selectedProducts { get; set; }
    public Map<Id, String> selectedProductMap = new Map<Id, String>();

    public GNE_SFA2_Independent_Ins_Edit_Create_Ext(ApexPages.StandardController controller) {
        super(controller,'/apex/GNE_SFA2_Independent_Ins_Edit_Create');
        this.currentIndependentInsight = (Independent_Insight_vod__c)controller.getRecord();
        System.debug('this.currentIndependentInsight: ' + this.currentIndependentInsight);
        this.newIndependentInsightMode = this.currentIndependentInsight.Id == null ? true : false;

        if(!this.newIndependentInsightMode){
            Independent_Insight_vod__c currIndependentInsightRec = [
                    SELECT Id, CreatedDate, Insight_Description_gne__c, Display_Name_gne__c, Therapeutic_Area_gne__c, Account_gne__c,
                            Call2_vod__c, Title_gne__c, Product_and_Indication_gne__c, Territory_gne__c, iPhone_Request_Id_gne__c,
                            Insight_Name_gne__c, Date_of_Insight_gne__c, Insight_Status_gne__c
                    FROM Independent_Insight_vod__c
                    WHERE Id = :this.currentIndependentInsight.Id];
            this.selectedProducts = getSelectedProducts(currIndependentInsightRec.Product_and_Indication_gne__c);
            this.selectedAccountIds = String.isNotBlank(currIndependentInsightRec.Account_gne__c) ? new Set<String>(currIndependentInsightRec.Account_gne__c.split(';')) : new Set<String>();
            this.currentIndependentInsight.Call2_vod__c = String.isNotBlank(currIndependentInsightRec.Call2_vod__c) ? currIndependentInsightRec.Call2_vod__c : null;

            System.debug('apexpages.currentpage().getparameters().get(\'saved\'): ' + apexpages.currentpage().getparameters().get('saved'));
            if(apexpages.currentpage().getparameters().get('saved') == 'true') {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Record saved'));
            }

        } else {
            this.selectedProducts =new List<SelectOption>();
            this.selectedAccountIds = new Set<String>();
        }
    }

    public Boolean getIsMenuVisible() {
        return !GNE_SFA2_Util.isCanadaINFUUser();
    }

    public PageReference saveInProgress() {
        Savepoint sp = Database.setSavepoint();
        try {
            if(String.isNotBlank(this.currentIndependentInsight.Call2_vod__c)) {
                this.currentIndependentInsight.Insight_Status_gne__c = 'Planned';
            } else {
                this.currentIndependentInsight.Insight_Status_gne__c = 'Draft';
            }
            this.currentIndependentInsight.Territory_gne__c = getUserTerritory();
            this.currentIndependentInsight.Product_and_Indication_gne__c = saveSelectedProducts(selectedProducts);
            this.currentIndependentInsight.Account_gne__c = getSelectedAccountIdsAsString(selectedAccountIds);
            if(validateRecordBeforeSave(currentIndependentInsight)) {
                upsert this.currentIndependentInsight;
                    PageReference pageref = new PageReference('/apex/GNE_SFA2_My_Insights');
                    pageref.setredirect(true);
                    return pageref;
            }

        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Could not save Insight! ' + + ex.getMessage()));
            System.debug('Could not save Insight: ' + ex.getMessage());
            Database.rollback(sp);
        }
        return null;
    }

    public PageReference completeInsideRec() {
        Savepoint sp = Database.setSavepoint();
        try {
            this.currentIndependentInsight.Insight_Status_gne__c = 'Complete';
            this.currentIndependentInsight.Territory_gne__c = getUserTerritory();
            this.currentIndependentInsight.Product_and_Indication_gne__c = saveSelectedProducts(selectedProducts);
            this.currentIndependentInsight.Account_gne__c = getSelectedAccountIdsAsString(selectedAccountIds);
            if(validateRecordBeforeSave(currentIndependentInsight)) {
                upsert this.currentIndependentInsight;
                PageReference pageref = new PageReference('/apex/GNE_SFA2_My_Insights');
                pageref.setredirect(true);
                return pageref;
            }
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Could not save Insight! ' + + ex.getMessage()));
            System.debug('Could not save Insight: ' + ex.getMessage());
            Database.rollback(sp);
        }
        return null;
    }

    public Boolean validateRecordBeforeSave(Independent_Insight_vod__c record) {
        if(String.isBlank(record.Title_gne__c)) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Insight Title: you must enter a value'));
            return false;
        }
        if(String.isBlank(record.Therapeutic_Area_gne__c)) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Therapeutic Area: you must enter a value'));
            return false;
        }
        if(String.isBlank(record.Insight_Description_gne__c)) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Insight description: you must enter a value'));
            return false;
        }
        return true;
    }

    public override PageReference cancel() {
        PageReference pr;
        String retURL = System.currentPageReference().getParameters().get('retURL');

        if (retURL == null) {
            pr = new PageReference('/apex/GNE_SFA2_My_Insights');
            pr.setRedirect(true);
        } else {
            pr = new PageReference(retURL);
            pr.setRedirect(true);
        }
        return pr;
    }

    public List<Account> getSelectedAccounts() {
        this.selectedAccounts = [SELECT Id, Name, IsPersonAccount, HCP_Stakeholder_Type_gne__c, Tier_Level_gne__c, Account_Type_gne__c, Territory_vod__c From Account WHERE Id IN: selectedAccountIds];
        return this.selectedAccounts;
    }

    public Set<String> getSelectedAccountIds() {
        return this.selectedAccountIds;
    }

    public List<SelectOption> getTherapeuticArea() {
        List<SelectOption> therapeuticAreas = new List<SelectOption>();
        Set<String> ta = new Set<String>();

        List<Product_vod__c> productsVod = [
                SELECT Id, Name, Product_Type_vod__c, Detail_Product_Subtype_Code_gne__c
                FROM Product_vod__c
                WHERE Product_Type_vod__c ='Therapeutic Area' AND
                Detail_Product_Subtype_Code_gne__c = 'Therapeutic Area'
                ORDER BY Name
        ];

        therapeuticAreas.add(new SelectOption('', '--None--'));
        for(Product_vod__c pr : productsVod) {
                therapeuticAreas.add(new SelectOption(pr.Id, pr.Name));
        }

        return therapeuticAreas;
    }

    public List<SelectOption> getProduct() {
        List<SelectOption> products = new List<SelectOption>();
        List<Product_vod__c> productsVod = [SELECT Id, Name, Active__c, Product_Type_vod__c,
                Therapeutic_Area_vod__c, Therapeutic_Area_Reference__c
        FROM Product_vod__c
        WHERE Name <> null
        AND Product_Type_vod__c = 'Detail'
        AND Therapeutic_Area_Reference__c != ''
        AND Active__c = true
        AND Region_Code_gne__c = 2
        AND Owner.Name NOT IN ('GNE-INACTIVE-PROD-QUEUE','GNE-CANADA-INACTIVE-PROD-QUEUE','GNE-SFA-QUEUE')
        ORDER BY Name, Id];
        for(Product_vod__c pr : productsVod) {
            if(!this.selectedProductMap.containsKey(pr.Id)) {
                products.add(new SelectOption(pr.Id, pr.Name));
            }
        }
        return products;
    }

    public List<SelectOption> getSelectedProducts(String selected) {
        List<SelectOption> sList = new List<SelectOption>();

        if (!String.isBlank(selected)){
            List<String> opts = selected.split(';');
            List<Product_vod__c> selectedProductList = [SELECT Id, Name FROM Product_vod__c WHERE Id IN: opts];
            for (Product_vod__c pr : selectedProductList) {
                sList.add(new SelectOption(pr.Id, pr.Name));
                this.selectedProductMap.put(pr.Id, pr.Name);
            }
        }
        return sList;
    }

    public static String saveSelectedProducts(List<SelectOption> selectedOpts) {
        String result = '';
        for (SelectOption so : selectedOpts) {
            result += so.getValue() + ';';
        }
        return result;
    }

    public static String getUserTerritory() {
        String userTerritory = '';
        List<Territory2> userTerritories = [Select Id, Name from Territory2 where Id  IN (Select Territory2Id from UserTerritory2Association where UserId = :UserInfo.getUserId())];
        for(Territory2 terr : userTerritories) {
            userTerritory = terr.Name;
            break;
        }
        return userTerritory;
    }

    public PageReference addAttendees() {
        List<EMS_SearchUtils.AccountWrapper> selectedAccountsWrappers =
                (List<EMS_SearchUtils.AccountWrapper>) JSON.deserialize(selectedAccountsJSON, List<EMS_SearchUtils.AccountWrapper>.class);
        for(EMS_SearchUtils.AccountWrapper acc : selectedAccountsWrappers) {
            this.selectedAccountIds.add(acc.objectId);
        }

        return null;
    }

    public PageReference removeAccountFromSelected() {
        if(this.selectedAccountIds.contains(accountIdToRemoveFromSelected)) {
            this.selectedAccountIds.remove(accountIdToRemoveFromSelected);
        }
        return null;
    }

    public String getSelectedAccountIdsAsString(Set<String> selectedAccountIdsSet) {
        String selectedIds = '';
        if(!selectedAccountIdsSet.isEmpty()) {
            selectedIds = String.join(new List<String>(selectedAccountIdsSet), ';');
            selectedIds += ';';
        }
        return selectedIds;
    }

    @RemoteAction
    global static List<EMS_SearchUtils.AccountWrapper> searchAccountsEmployees(String searchString, Boolean allAccounts, Boolean myAccounts, Boolean myTargets, Boolean tieredAccounts) {
        return EMS_Event_Attendee_Interaction_Ext.searchAccountsEmployees(searchString, allAccounts, myAccounts, myTargets, tieredAccounts);
    }

}