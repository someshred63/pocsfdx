public with sharing class EMS_Budget_Planning_Controller {

    public BudgetWrapper mainBudget { get; set; }
    public String addButtonLabel { get; set; }
    public List<BudgetWrapper> budgetList { get; set; }
    public Map <Id, BudgetWrapper> budgetMap { get; set; }
    public Map <Id, List<FundRequestWrapper>> relatedFundRequestMap { get; set; }
    public Map <Id, List<FundRequestWrapperNotexistent>> notexistentFundRequestMap { get; set; }
    public Map <Id, Integer> notexistentFundRequestSizesMap { get; set; }
    public String fundRequestIndexToRemove { get; set; }
    public String displayMainBudget { get; set; }
    public Boolean showFundRequests { get; set; }
    public Boolean showRegionFundRequests { get; set; }
    public Id currentBudgetId { get; set; }
    public Integer fundRequestWrapperIndexToRemove { get; set; }
    public Integer budgetWrapperIndexToRemove { get; set; }
    public EMS_Fund_Request_gne__c currentFundRequest { get; set; }
    public Map<Id, EMS_WrapperList> relatedFundRequestWrapperListMap { get; set; }
    public String activeMenuItem { get; set; }
    public String fundOperationType { get; set; }


    private Id itemId;
    private String retURL;
    private String budgetType;
    private Map <Id, RecordType> mapFundRequestRecordTypes { get; set; }
    private List <EMS_Budget_Territory_gne__c> budgetTerritoryList;
    private List <EMS_Fund_Request_gne__c> relatedFundRequestList;
    private List <EMS_Budget_Region_gne__c> budgetRegionList;
    private List<id> idList;
    private List <FundRequestWrapper> tempFundRequestWrapperList;
    private Integer counter;

    public EMS_Budget_Planning_Controller() {
        itemId = System.currentPagereference().getParameters().get('id');
        retURL = System.currentPagereference().getParameters().get('retURL');
        budgetType = getObjectDevName(itemId);
        counter = 0;
        getMainBudgetInformation();
        loadPageConfiguration();
    }

    private string getObjectDevName(Id recordId) {
        return recordId.getSObjectType().getDescribe().getName();
    }

    private void getMainBudgetInformation() {
        if (budgetType == 'EMS_Budget_Product_gne__c') {
            activeMenuItem = 'Product Budget';
            EMS_Budget_Product_gne__c tempBudgetProduct = [Select Product_Budget_Allocated_Amount_gne__c, Product_Balance_gne__c, Total_Product_Funds_Approved_gne__c, Assigned_to_gne__c, Assigned_To_Territory_gne__c, Assigned_to_gne__r.Name, Id, Name, Product_Indication_gne__c, CreatedDate from EMS_Budget_Product_gne__c where Id = :itemId order by CreatedDate];
            mainBudget = new BudgetWrapper(tempBudgetProduct.Product_Balance_gne__c, tempBudgetProduct.Total_Product_Funds_Approved_gne__c, tempBudgetProduct.Assigned_to_gne__r.Name, tempBudgetProduct.Assigned_To_Territory_gne__c, tempBudgetProduct.Id, tempBudgetProduct.Name, tempBudgetProduct.Product_Indication_gne__c, tempBudgetProduct.Product_Budget_Allocated_Amount_gne__c, '/apex/EMS_Budget_Product_Layout?id=', 0, tempBudgetProduct.CreatedDate);
        } else if (budgetType == 'EMS_Budget_Region_gne__c') {
            EMS_Budget_Region_gne__c tempBudgetRegion = [Select Region_Budget_Allocated_Amount_gne__c, Region_Balance_gne__c, Total_Region_Funds_Approved_gne__c, Assigned_to_gne__c, Assigned_To_Territory_gne__c, Assigned_to_gne__r.Name, Id, Name, Product_Indication_gne__c, CreatedDate from EMS_Budget_Region_gne__c where Id = :itemId order by CreatedDate];
            mainBudget = new BudgetWrapper(tempBudgetRegion.Region_Balance_gne__c, tempBudgetRegion.Total_Region_Funds_Approved_gne__c, tempBudgetRegion.Assigned_to_gne__r.Name, tempBudgetRegion.Assigned_To_Territory_gne__c, tempBudgetRegion.Id, tempBudgetRegion.Name, tempBudgetRegion.Product_Indication_gne__c, tempBudgetRegion.Region_Budget_Allocated_Amount_gne__c, '/apex/EMS_Budget_Region_Layout?id=', 0, tempBudgetRegion.CreatedDate);
            activeMenuItem = 'Region Budget';
        }
    }

    private void loadPageConfiguration() {
        budgetMap = new Map <Id, BudgetWrapper>();
        relatedFundRequestMap = new Map<Id, List<FundRequestWrapper>>();
        notexistentFundRequestMap = new Map<Id, List<FundRequestWrapperNotexistent>>();
        notexistentFundRequestSizesMap = new Map<Id, Integer>();
        relatedFundRequestWrapperListMap = new Map<Id, EMS_WrapperList>();
        budgetList = new List<BudgetWrapper>();
        idList = new List<Id>();
        showRegionFundRequests = false;

        if (budgetType == 'EMS_Budget_Product_gne__c') {
            addButtonLabel = 'Add Region budget';
            showRegionFundRequests = true;
            loadSectionDetailsForProduct();
            loadFundingRequests();
            buildRelatedFundRequestWrapperLists();
            displayMainBudget = 'Product Budget';
        } else if (budgetType == 'EMS_Budget_Region_gne__c') {
            addButtonLabel = 'Add Territory budget';
            loadSectionDetailsForRegion();
            loadFundingRequests();
            buildRelatedFundRequestWrapperLists();
            displayMainBudget = 'Region Budget';
        }
    }

    private void buildRelatedFundRequestWrapperLists() {
        if (relatedFundRequestMap != null && relatedFundRequestMap.size() > 0) {
            Map<String, String> headersMap = new Map<String, String>();
            headersMap.put('fundRequest.name', 'Fund request#');
            headersMap.put('fundRequest.Requested_Amount_gne__c', 'Amount');
            headersMap.put('fundRequest.RecordType.Name', 'Type');
            headersMap.put('fundRequest.Status_gne__c', 'Status');
            headersMap.put('fundRequest.Reason_gne__c', 'Reason');
            headersMap.put('createdDate', 'Created Date');

            List<String> fieldNames = new List<String>();
            fieldNames.add('fundRequest.name');
            fieldNames.add('fundRequest.Percentage_of_Budget_gne__c');
            fieldNames.add('fundRequest.Requested_Amount_gne__c');
            fieldNames.add('fundRequest.RecordType.Name');
            fieldNames.add('fundRequest.Status_gne__c');
            fieldNames.add('fundRequest.Reason_gne__c');
            fieldNames.add('createdDate');

            Map<String, String> fieldTypesMap = new Map<String, String>();
            fieldTypesMap.put('fundRequest.name', 'Link');
            fieldTypesMap.put('fundRequest.Requested_Amount_gne__c', 'String');
            fieldTypesMap.put('fundRequest.RecordType.Name', 'String');
            fieldTypesMap.put('fundRequest.Status_gne__c', 'String');
            fieldTypesMap.put('fundRequest.Reason_gne__c', 'String');
            fieldTypesMap.put('createdDate', 'String');

            Map<String, String> linkActionMap = new Map<String, String>();
            linkActionMap.put('fundRequest.name', 'fundRequestLink');
            headersMap.put('fundRequest.Percentage_of_Budget_gne__c', '% of Budget');
            fieldTypesMap.put('fundRequest.Percentage_of_Budget_gne__c', 'String');


            for (Id id : relatedFundRequestMap.keySet()) {
                EMS_WrapperList wrapperList = new EMS_WrapperList();
                wrapperList.objectList = relatedFundRequestMap.get(id);
                wrapperList.headersMap = headersMap;
                wrapperList.fieldNames = fieldNames;
                wrapperList.fieldTypesMap = fieldTypesMap;
                wrapperList.linkActionMap = linkActionMap;
                relatedFundRequestWrapperListMap.put(id, wrapperList);
            }
        }
    }

    private void loadSectionDetailsForProduct() {
        FundRequestWrapper fRW;
        BudgetWrapper budgetWrapp;
        mapFundRequestRecordTypes = new Map <Id, RecordType>([Select Id, DeveloperName, Name from RecordType where SobjectType = 'EMS_Fund_Request_gne__c' and DeveloperName like '%Region%']);
        budgetRegionList = [Select Region_Budget_Allocated_Amount_gne__c, Region_Balance_gne__c, Total_Region_Funds_Approved_gne__c, Assigned_to_gne__c, Assigned_to_gne__r.Name, Assigned_To_Territory_gne__c, Id, Name, Product_Indication_gne__c, CreatedDate from EMS_Budget_Region_gne__c where EMS_Budget_Product_gne__c = :itemId];
        for (EMS_Budget_Region_gne__c bR : budgetRegionList) {
            budgetWrapp = new BudgetWrapper(bR.Region_Balance_gne__c, bR.Total_Region_Funds_Approved_gne__c, bR.Assigned_to_gne__r.Name, bR.Assigned_To_Territory_gne__c, bR.Id, bR.Name, bR.Product_Indication_gne__c, bR.Region_Budget_Allocated_Amount_gne__c, '/apex/EMS_Budget_Region_Layout?id=', budgetList.size(), br.CreatedDate);
            budgetList.add(budgetWrapp);
            idList.add(bR.Id);
            budgetMap.put(bR.Id, budgetWrapp);
        }
    }

    public PageReference updateFundRequestStatus() {
        for (FundRequestWrapperNotexistent frw : notexistentFundRequestMap.get(currentBudgetId)) {
            if (frw.index == fundRequestWrapperIndexToRemove) {
                if (mapFundRequestRecordTypes.get(frw.fundRequest.RecordTypeId).DeveloperName == 'Region_Fund_Allocation' ||
                        mapFundRequestRecordTypes.get(frw.fundRequest.RecordTypeId).DeveloperName == 'Territory_Fund_Allocation') {
                    frw.fundRequest.Status_gne__c = 'Approved';
                } else {
                    frw.fundRequest.Status_gne__c = 'New';
                }
            }
        }

        return null;
    }

    private void loadSectionDetailsForRegion() {
        FundRequestWrapper fRW;
        BudgetWrapper budgetWrapp;
        mapFundRequestRecordTypes = new Map <Id, RecordType>([Select Id, DeveloperName, Name from RecordType where SobjectType = 'EMS_Fund_Request_gne__c' and DeveloperName like '%Territory%']);
        budgetTerritoryList = [Select Events_Allocated_Amount_gne__c, Territory_Balance_gne__c, Total_Territory_Funds_Approved_gne__c, Assigned_to_gne__c, Assigned_To_Territory_gne__c, Assigned_to_gne__r.Name, Id, Name, Product_Indication_gne__c, CreatedDate from EMS_Budget_Territory_gne__c where EMS_Budget_Region_gne__c = :itemId];
        for (EMS_Budget_Territory_gne__c tR : budgetTerritoryList) {
            budgetWrapp = new BudgetWrapper(tR.Territory_Balance_gne__c, tR.Total_Territory_Funds_Approved_gne__c, tR.Assigned_to_gne__r.Name, tR.Assigned_To_Territory_gne__c, tR.Id, tR.Name, tR.Product_Indication_gne__c, tR.Events_Allocated_Amount_gne__c, '/apex/EMS_Budget_Territory_Layout?id=', budgetList.size(), tR.CreatedDate);
            budgetList.add(budgetWrapp);
            idList.add(tR.Id);
            budgetMap.put(tR.Id, budgetWrapp);
        }
    }

    private void loadFundingRequests() {
        FundRequestWrapper fRW;

        if (idList.size() > 0) {
            relatedFundRequestList = [Select CreatedDate, Percentage_of_Budget_gne__c, Reason_gne__c, Requested_Amount_gne__c, Name, Related_Region_Budget_gne__c, Related_Territory_Budget_gne__c, Related_Region_Budget_gne__r.Total_Region_Funds_Approved_gne__c, Status_gne__c, RecordType.DeveloperName, RecordType.Name from EMS_Fund_Request_gne__c where (Related_Region_Budget_gne__c in:idList or Related_Territory_Budget_gne__c in:idList)];
            if (relatedFundRequestList.size() > 0) {
                showFundRequests = true;
                Integer index = 0;
                for (BudgetWrapper bW : budgetList) {
                    tempFundRequestWrapperList = new List <FundRequestWrapper>();
                    for (EMS_Fund_Request_gne__c fR : relatedFundRequestList) {
                        if (bW.budgetId == fR.Related_Region_Budget_gne__c || bW.budgetId == fR.Related_Territory_Budget_gne__c) {
                            fRW = new FundRequestWrapper(fR, index, true, bW.totalFundsApproved, showRegionFundRequests);
                            tempFundRequestWrapperList.add(fRW);
                            index++;
                        }
                    }
                    sortFundRequestWrapperList();
                    relatedFundRequestMap.put(bW.budgetId, tempFundRequestWrapperList);
                    notexistentFundRequestMap.put(bW.budgetId, new List<FundRequestWrapperNotexistent>());
                    notexistentFundRequestSizesMap.put(bW.budgetId, 0);
                }
            } else {
                showFundRequests = false;
                for (BudgetWrapper bW : budgetList) {
                    notexistentFundRequestMap.put(bW.budgetId, new List<FundRequestWrapperNotexistent>());
                    notexistentFundRequestSizesMap.put(bW.budgetId, 0);
                }
            }
        }
    }

    private void sortFundRequestWrapperList() {
        for (FundRequestWrapper wrapper : tempFundRequestWrapperList) {
            wrapper.compareBy = 'fundRequest.CreatedDate';
            wrapper.ascending = true;
        }
        tempFundRequestWrapperList.sort();
    }

    public PageReference removeFundRequestCall() {
        for (Integer i = 0; i < notexistentFundRequestMap.get(currentBudgetId).size(); i++) {
            if (notexistentFundRequestMap.get(currentBudgetId).get(i).index == fundRequestWrapperIndexToRemove) {
                notexistentFundRequestMap.get(currentBudgetId).remove(i);
                notexistentFundRequestSizesMap.put(currentBudgetId, notexistentFundRequestSizesMap.get(currentBudgetId) - 1) ;
            }
        }

        return null;
    }

    public PageReference removeBudgetCall() {
        budgetList.remove(budgetWrapperIndexToRemove);
        for (BudgetWrapper bw : budgetList) {
            if (bw.index > budgetWrapperIndexToRemove) {
                bw.index--;
            }
        }
        return null;
    }

    public PageReference save() {
        if (saveData()) {
            loadPageConfiguration();
            getMainBudgetInformation();

            PageReference pr = Page.EMS_Budget_Planning;
            pr.getParameters().put('id', itemId);
            pr.getParameters().put('retURL', retURL);
            pr.setRedirect(true);
            return pr;

        } else {
            // Error display Apex page message
            return null;
        }
    }

    public PageReference saveAndReturn() {
        if (saveData()) {
            String retURL = System.currentPagereference().getParameters().get('retURL');
            PageReference retPR = new PageReference(retURL);
            retPR.setRedirect(true);
            return retPR;
        } else {
            // Error display Apex page message
            return null;
        }
    }

    public PageReference cancel() {
        String retURL = System.currentPagereference().getParameters().get('retURL');
        PageReference retPR = new PageReference(retURL);
        return retPR;
    }

    public String getActiveMenuItem() {
        if (budgetType == 'EMS_Budget_Product_gne__c') {
            return 'Product Budget';
        } else {
            return 'Region Budget';
        }
    }

    private Boolean saveData() {
        List <EMS_Fund_Request_gne__c> fundRequestsToInsert = new List <EMS_Fund_Request_gne__c>();
        List <EMS_Fund_Request_gne__c> fundRequestsToSubmit = new List <EMS_Fund_Request_gne__c>();
        List <EMS_Budget_Region_gne__c> budgetRegionToInsert = new List <EMS_Budget_Region_gne__c>();
        List <EMS_Budget_Territory_gne__c> budgetTerritoryToInsert = new List <EMS_Budget_Territory_gne__c>();
        // ApexPages.Message pageMsg;
        System.SavePoint sp = Database.setSavepoint();
        try {
            for (BudgetWrapper bw : budgetList) {
                if (!bw.exist) {
                    InvalidFieldsException invException = new InvalidFieldsException(bw);
                    if (bw.isRegion) {
                        bw.budgetRegion.Total_Region_Funds_Approved_gne__c = bw.totalFundsApproved;
                        budgetRegionToInsert.add(bw.budgetRegion);
                    } else if (bw.isTerritory) {
                        bw.budgetTerritory.Total_Territory_Funds_Approved_gne__c = bw.totalFundsApproved;
                        budgetTerritoryToInsert.add(bw.budgetTerritory);
                    }
                }
            }
            for (List<FundRequestWrapperNotexistent> fRWList : notexistentFundRequestMap.values()) {
                for (FundRequestWrapperNotexistent fRW : fRWList) {
                    fRW.fundRequest.Requested_Amount_gne__c = fRW.amount;
                    fRW.fundRequest.Percentage_of_Budget_gne__c = fRW.percentOfBudget;
                    InvalidFieldsException invException = new InvalidFieldsException(fRW);


                    if (mapFundRequestRecordTypes.get(fRW.fundRequest.RecordTypeId).DeveloperName == 'Region_Fund_De_Allocation' ||
                            mapFundRequestRecordTypes.get(fRW.fundRequest.RecordTypeId).DeveloperName == 'Territory_Fund_De_Allocation'
                            ) {
                        fRW.fundRequest.Submitted_By_gne__c = UserInfo.getUserId();
                        fundRequestsToSubmit.add(fRW.fundRequest);
                    }

                    fundRequestsToInsert.add(fRW.fundRequest);
                }
            }
            if (fundRequestsToInsert.size() > 0) {
                upsert fundRequestsToInsert;
            }
            if (fundRequestsToSubmit.size() > 0) {
                submitFundRequests(fundRequestsToSubmit);
            }
            if (budgetRegionToInsert.size() > 0) {
                insert budgetRegionToInsert;
            }
            if (budgetTerritoryToInsert.size() > 0) {
                insert budgetTerritoryToInsert;
            }
        } catch (DMLException ex) {
            if (ex.getMessage().contains('DUPLICATE_VALUE')) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, 'Budget with given Cost Center/Territory/Year already exists.'));
                return false;
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Error occured:' + ex.getMessage()));
                Database.rollback(sp);
                return false;
            }
        } catch (Exception ex) {
            if (ex.getMessage().contains('Invalid decimal')) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Amount value problem. Details: ' + ex.getMessage()));
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Exception occured: ' + ex.getMessage()));
            }
            Database.rollback(sp);
            return false;
        }
        return true;
    }

    private void submitFundRequests(List<EMS_Fund_Request_gne__c> fundRequestsToSubmit) {
        for (EMS_Fund_Request_gne__c fundRequest : fundRequestsToSubmit) {
            Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
            request.setObjectId(fundRequest.id);
            Approval.ProcessResult result = Approval.process(request);
        }
    }

    public PageReference addFundRequest() {
        if (!notexistentFundRequestMap.containsKey(currentBudgetId)) {
            notexistentFundRequestMap.put(currentBudgetId, new List<FundRequestWrapperNotexistent>());
        }
        EMS_Fund_Request_gne__c fundRequest = createNewFundRequest();
        FundRequestWrapperNotexistent fundRequestWrapper = new FundRequestWrapperNotexistent(fundRequest, getNextIndex(), budgetMap.get(currentBudgetId).totalFundsApproved, showRegionFundRequests);
        notexistentFundRequestMap.get(currentBudgetId).add(fundRequestWrapper);
        notexistentFundRequestSizesMap.put(currentBudgetId, notexistentFundRequestSizesMap.get(currentBudgetId) + 1) ;
        return null;
    }

    private EMS_Fund_Request_gne__c createNewFundRequest() {

        EMS_Fund_Request_gne__c fr;
        if (budgetType == 'EMS_Budget_Product_gne__c') {
            fr = new EMS_Fund_Request_gne__c(
                    Status_gne__c = 'New',
                    Related_Region_Budget_gne__c = currentBudgetId,
                    Related_Product_Budget_gne__c = itemId
            );
        } else if (budgetType == 'EMS_Budget_Region_gne__c') {
            fr = new EMS_Fund_Request_gne__c(
                    Status_gne__c = 'New',
                    Related_Territory_Budget_gne__c = currentBudgetId,
                    Related_Region_Budget_gne__c = itemId
            );
        }
        return fr;
    }

    public PageReference addBudget() {
        // ApexPages.Message pageMsg;
        BudgetWrapper budgetWrapp = createNewBudget();
        budgetList.add(budgetWrapp);
        return null;
    }

    private BudgetWrapper createNewBudget() {
        BudgetWrapper budgetWrapp;
        EMS_Budget_Region_gne__c budgetRegion;
        EMS_Budget_Territory_gne__c budgetTerritory;
        if (budgetType == 'EMS_Budget_Product_gne__c') {
            budgetRegion = new EMS_Budget_Region_gne__c(
                    Status_gne__c = 'Active',
                    EMS_Budget_Product_gne__c = itemId
            );
            budgetWrapp = new BudgetWrapper(budgetRegion, budgetList.size());
        } else if (budgetType == 'EMS_Budget_Region_gne__c') {
            budgetTerritory = new EMS_Budget_Territory_gne__c(
                    Status_gne__c = 'Active',
                    EMS_Budget_Region_gne__c = itemId
            );
            budgetWrapp = new BudgetWrapper(budgetTerritory, budgetList.size());
        }
        return budgetWrapp;
    }

    public Integer getNextIndex() {
        counter++;
        return counter;
    }

    public PageReference refreshPage() {
        return null;
    }

    public class FundRequestWrapperNotexistent {
        public EMS_Fund_Request_gne__c fundRequest { get; set; }
        public String fundRequestLink { get; set; }
        public Decimal percentOfBudget { get; set; }
        public Integer index { get; set; }
        public Decimal budgetRegionApprovedAmount;
        public Decimal amount { get; set; }
        public String percentageValue { get; set; }
        public FundRequestWrapperNotexistent(EMS_Fund_Request_gne__c fr, Integer t_index, Decimal approvedAmount, boolean showRegionFundRequests) {
            fundRequest = fr;
            index = t_index;
            amount = 0;
            fundRequest.Required_By_Date_gne__c = Date.Today();
            percentOfBudget = 0;
            budgetRegionApprovedAmount = approvedAmount;
            percentageValue = String.valueOf(fr.Percentage_of_Budget_gne__c);
        }
    }

    public class FundRequestWrapper extends EMS_Wrapper {
        public EMS_Fund_Request_gne__c fundRequest { get; set; }
        public String fundRequestLink { get; set; }
        public Decimal percentOfBudget { get; set; }
        public Integer index { get; set; }
        public Boolean exist { get; set; }
        public Decimal budgetRegionApprovedAmount;
        public Decimal amount { get; set; }
        public String percentageValue { get; set; }
        public String createdDate { get; set; }
        public FundRequestWrapper(EMS_Fund_Request_gne__c fr, Integer t_index, Boolean t_exist, Decimal approvedAmount, boolean showRegionFundRequests) {
            fundRequest = fr;
            index = t_index;
            exist = t_exist;
            this.fundRequestLink = '/apex/EMS_Fund_Request_Layout?id=' + fundRequest.id;
            this.createdDate = fr.CreatedDate.format();
        }

        public override Integer compareTo(Object compareTo) {
            if (compareBy == null || compareBy == '') {
                return 0;
            } else if (!ascending) {
                return compareToDescending(compareTo);
            } else {
                return compareToAscending(compareTo);
            }
        }

        public Integer compareToAscending(Object compareTo) {
            FundRequestWrapper wrapper = (FundRequestWrapper) compareTo;
            if (compareBy == 'fundRequest.Requested_Amount_gne__c') {
                if (wrapper.fundRequest.Requested_Amount_gne__c == this.fundRequest.Requested_Amount_gne__c) return 0;
                if (wrapper.fundRequest.Requested_Amount_gne__c > this.fundRequest.Requested_Amount_gne__c) return 1;
            } else if (compareBy == 'fundRequest.name') {
                return wrapper.fundRequest.name.compareTo(this.fundRequest.name);
            } else if (compareBy == 'fundRequest.Percentage_of_Budget_gne__c') {
                if (wrapper.fundRequest.Percentage_of_Budget_gne__c == this.fundRequest.Percentage_of_Budget_gne__c) return 0;
                if (wrapper.fundRequest.Percentage_of_Budget_gne__c > this.fundRequest.Percentage_of_Budget_gne__c) return 1;
            } else if (compareBy == 'fundRequest.RecordType.Name') {
                return wrapper.fundRequest.RecordType.Name.compareTo(this.fundRequest.RecordType.Name);
            } else if (compareBy == 'fundRequest.Status_gne__c') {
                return wrapper.fundRequest.Status_gne__c.compareTo(this.fundRequest.Status_gne__c);
            } else if (compareBy == 'fundRequest.Reason_gne__c') {
                return wrapper.fundRequest.Reason_gne__c.compareTo(this.fundRequest.Reason_gne__c);
            } else if (compareBy == 'fundRequest.CreatedDate') {
                if (wrapper.fundRequest.CreatedDate == this.fundRequest.CreatedDate) return 0;
                if (wrapper.fundRequest.CreatedDate > this.fundRequest.CreatedDate) return 1;
            }

            return -1;
        }

        public Integer compareToDescending(Object compareTo) {
            FundRequestWrapper wrapper = (FundRequestWrapper) compareTo;
            if (compareBy == 'fundRequest.Requested_Amount_gne__c') {
                if (wrapper.fundRequest.Requested_Amount_gne__c == this.fundRequest.Requested_Amount_gne__c) return 0;
                if (wrapper.fundRequest.Requested_Amount_gne__c > this.fundRequest.Requested_Amount_gne__c) return -1;
            } else if (compareBy == 'fundRequest.name') {
                return wrapper.fundRequest.name.compareTo(this.fundRequest.name) * (-1);
            } else if (compareBy == 'fundRequest.Percentage_of_Budget_gne__c') {
                if (wrapper.fundRequest.Percentage_of_Budget_gne__c == this.fundRequest.Percentage_of_Budget_gne__c) return 0;
                if (wrapper.fundRequest.Percentage_of_Budget_gne__c > this.fundRequest.Percentage_of_Budget_gne__c) return -1;
            } else if (compareBy == 'fundRequest.RecordType.Name') {
                return wrapper.fundRequest.RecordType.Name.compareTo(this.fundRequest.RecordType.Name) * (-1);
            } else if (compareBy == 'fundRequest.Status_gne__c') {
                return wrapper.fundRequest.Status_gne__c.compareTo(this.fundRequest.Status_gne__c) * (-1);
            } else if (compareBy == 'fundRequest.Reason_gne__c') {
                return wrapper.fundRequest.Reason_gne__c.compareTo(this.fundRequest.Reason_gne__c) * (-1);
            } else if (compareBy == 'fundRequest.CreatedDate') {
                if (wrapper.fundRequest.CreatedDate == this.fundRequest.CreatedDate) return 0;
            }
            return 1;
        }
    }

    public class BudgetWrapper {
        public Decimal balance { get; set; }
        public Boolean exist { get; set; }
        public String budgetLink { get; set; }
        public Integer index { get; set; }
        public Decimal budgetAllocatedAmount { get; set; }
        public Decimal totalFundsApproved { get; set; }
        public String status { get; set; }
        public String assignedTo { get; set; }
        public String assignedToTeritory { get; set; }
        public boolean isTerritory { get; set; }
        public boolean isRegion { get; set; }
        public Id budgetId { get; set; }

        public String budgetName { get; set; }
        public String indication { get; set; }
        private final String currencySign = ' $';
        public Date startDate { get; set; }
        public Date endDate { get; set; }
        public String newBudgetName { get; set; }
        public EMS_Budget_Territory_gne__c budgetTerritory { get; set; }
        public EMS_Budget_Region_gne__c budgetRegion { get; set; }
        public String creationDate { get; set; }

        public BudgetWrapper(Decimal balance_param,
                Decimal totalFundsApproved_param,
                String assignedTo_param,
                String assignedToTerritory_param,
                Id id_param,
                String name_param,
                String indication_param,
                Decimal budgetAllocatedAmount_param,
                String budgetLink_param,
                Integer index_param,
                DateTime createdDate_p) {

            balance = balance_param;
            totalFundsApproved = totalFundsApproved_param;
            totalFundsApproved = totalFundsApproved_param;
            assignedTo = assignedTo_param;
            assignedToTeritory = assignedToTerritory_param;
            budgetId = id_param;
            budgetName = name_param;
            indication = indication_param;
            budgetAllocatedAmount = budgetAllocatedAmount_param;
            budgetLink = budgetLink_param + budgetId;
            exist = true;
            index = index_param;
            creationDate = createdDate_p.format();
        }

        public BudgetWrapper(EMS_Budget_Region_gne__c budgetRegion_param, Integer index_param) {
            budgetRegion = budgetRegion_param;
            init(index_param, budgetRegion.Status_gne__c, 'New Region Budget', false, true, false);
        }

        public BudgetWrapper(EMS_Budget_Territory_gne__c budgetTerritory_param, Integer index_param) {
            budgetTerritory = budgetTerritory_param;
            init(index_param, budgetTerritory.Status_gne__c, 'New Territory Budget', false, false, true);
        }
        public void init(Integer index_param, String status_p, String newBudgetName_p, Boolean exist_p, Boolean isRegion_p, Boolean isTerritory_p) {
            exist = exist_p;
            isRegion = isRegion_p;
            isTerritory = isTerritory_p;
            //budgetAllocatedAmount = 0;
            //totalFundsApproved = 0;
            newBudgetName = newBudgetName_p;
            status = status_p;
            index = index_param;
        }

        public List<SelectOption> getAvailableTerritories() {
            Id userId;
            if (isRegion == TRUE && isTerritory == FALSE && budgetRegion.Assigned_to_gne__c != null) {
                userId = budgetRegion.Assigned_to_gne__c;
            } else if (isRegion == FALSE && isTerritory == TRUE && budgetTerritory.Assigned_to_gne__c != null) {
                userId = budgetTerritory.Assigned_to_gne__c;
            }

            return EMS_Util.getUserTerritorySelectOptions(userId);
        }
    }

    public List<SelectOption> getRecTypes() {
        List<SelectOption> options = new List<SelectOption>();
        for (RecordType rt : mapFundRequestRecordTypes.values()) {
            options.add(new SelectOption(rt.id, rt.Name));
        }
        return options;
    }


    public class InvalidFieldsException extends Exception {

        public String messages;
        public Integer exLength;
        public InvalidFieldsException(EMS_Budget_Planning_Controller.BudgetWrapper bw) {
            messages = 'Errors on adding new budget: ';
            exLength = messages.length();
            if (bw.isRegion) {
                if (bw.budgetRegion.Status_gne__c == null) {
                    messages += '\r\n Status not selected |';
                }
                if (bw.budgetRegion.Assigned_to_gne__c == null) {
                    messages += '\r\n "Assigned to" field empty |';
                }
                if (bw.budgetRegion.Start_Date_gne__c == null) {
                    messages += '\r\n Invalid Start Date |';
                }
                if (bw.budgetRegion.End_Date_gne__c == null) {
                    messages += '\r\n Invalid End Date |';
                }
                if (bw.budgetRegion.Year_gne__c == null) {
                    messages += '\r\n Invalid Year |';
                }
                /*		String UserRoleFromSR = EMS_Util.getUserRoleFromSR(bw.budgetRegion.Assigned_to_gne__c);
                     if (UserRoleFromSR == 'RSM' || UserRoleFromSR == 'ML') {
                         messages += '\r\n Invalid User |';
                     }*/

            }
            if (bw.isTerritory) {
                if (bw.budgetTerritory.Status_gne__c == null) {
                    messages += '\r\n Status not selected |';
                }
                if (bw.budgetTerritory.Assigned_to_gne__c == null) {
                    messages += '\r\n "Assigned to" field empty |';
                }
                if (bw.budgetTerritory.Start_Date_gne__c == null) {
                    messages += '\r\n Invalid Start Date |';
                }
                if (bw.budgetTerritory.End_Date_gne__c == null) {
                    messages += '\r\n Invalid End Date |';
                }
                if (bw.budgetTerritory.Year_gne__c == null) {
                    messages += '\r\n Invalid Year |';
                }
                /*	String UserRoleFromSR = EMS_Util.getUserRoleFromSR(bw.budgetRegion.Assigned_to_gne__c);
                 if (UserRoleFromSR == 'Rep') {
                     messages += '\r\n Invalid User |';
                 }*/
            }
            if (messages.length() > exLength) {
                throw new InvalidFieldsException(messages);
            }
        }
        public InvalidFieldsException(EMS_Budget_Planning_Controller.FundRequestWrapperNotexistent frw) {
            messages = 'Errors on adding new fund request: ';
            exLength = messages.length();
            if (frw.fundRequest.Requested_Amount_gne__c == null || frw.fundRequest.Requested_Amount_gne__c == 0) {
                messages += '\r\n Requested Amount cant be empty or zero |';
            }
            /*
            if(frw.fundRequest.Reason_gne__c == null){
                messages += '\r\n "Reason" field empty |';
            }*/
            if (messages.length() > exLength) {
                throw new InvalidFieldsException(messages);
            }
        }

    }


}