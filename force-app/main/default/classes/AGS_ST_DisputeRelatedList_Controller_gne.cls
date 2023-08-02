/** @date 9/19/2012
* @Author Pawel Sprysak
* @description Controller Extension for AGS_ST_DisputeRelatedLists_gne
*/
public without sharing class AGS_ST_DisputeRelatedList_Controller_gne {
	/* HD Decommissioning 
    private final static String CCO_GROUP_NAME = 'GNE-AGS-CCO-Analyst-Group';
    //_GET parameters
    public String pr = '';
    public String event = '';
    public String setId = '';
    public String disputeId = '';
    //Common
    public String actionMessages { get; set; }
    public Boolean isCCOUser {
        get {
            for (User u : AGS_ST_DbUtils.getUsersFromGroupsByGroupNames(new List<String> {CCO_GROUP_NAME})) {
                if(Userinfo.getUserId() == u.Id) return true;
            }
            return false;
        }
    }
    private transient ApexPages.StandardSetController standardCon { get; set; }
    //Expense List
    public transient List<AGS_Spend_Expense_Transaction_gne__c> relatedExpensesList { get; set; }
    public AGS_ST_DMPagingAndSortingUtils relatedExpensesUtil { get; set; }
    //Direct List
    public List<HeldTransactionContainer> directRelatedHeldList { get; set; }
    public AGS_ST_DMPagingAndSortingUtils directHTUtil { get; set; }
    //Indirect List
    public List<HeldTransactionContainer> indirectRelatedHeldList { get; set; }
    public AGS_ST_DMPagingAndSortingUtils indirectHTUtil { get; set; }
    //Historical List
    public transient List<AGS_ST_Held_And_Dispute_Junction_gne__c> historicalHeldList { get; set; }
    public AGS_ST_DMPagingAndSortingUtils historicalHTUtil { get; set; }
    public String disputeManId { get; set; }
    public String spendId { get; set; }
    public String heldKey { get; set; }
    //Changing status
    public List<Id> selectedIds { get; set; }
    public String statusValue { get; set; }
    
    public Boolean isAvStChngInd {get; set;}
    public Boolean isAvStChngDir {get; set;}
    public Boolean isAllAvStChngInd {get; set;}
    public Boolean isAllAvStChngDir {get; set;}
    
    public AGS_ST_DisputeManagement_gne__c relatedDispute {get; set;}
    */

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Constructor for AGS_ST_DisputeRelatedList_Controller_gne
    */
    /* HD Decommissioning
    public AGS_ST_DisputeRelatedList_Controller_gne() {
        //_GET parameters - init
        pr = ApexPages.currentPage().getParameters().get('pr');
        event = ApexPages.currentPage().getParameters().get('event');
        setId = ApexPages.currentPage().getParameters().get('set');
        disputeId = ApexPages.currentPage().getParameters().get('dispute');
        // Messages initialization
        String com = ApexPages.currentPage().getParameters().get('com');
        if(com!=null && com.equals('2')) {
            actionMessages = 'Held transaction status has been changed<br/>';
        }
        // Util - init
        relatedExpensesUtil = new AGS_ST_DMPagingAndSortingUtils(5);
        directHTUtil = new AGS_ST_DMPagingAndSortingUtils(5);
        indirectHTUtil = new AGS_ST_DMPagingAndSortingUtils(5);
        // Status change
        selectedIds = new List<Id>();
        // set lists
        changeHTList(true, true, directHTUtil);
        changeHTList(true, false, indirectHTUtil);
        changeExpenseList(true);
        
        relatedDispute = [SELECT Dispute_Resolver_gne__c, OwnerId, Internal_Status_gne__c FROM AGS_ST_DisputeManagement_gne__c WHERE Id = :disputeId];
    }
    */
    
    /** @date 5/20/2013
    * @Author Piotr Skowroński
    * @description Check if user is owner or resolver
    * @return Boolean
    */
    /* HD Decommissioning
    public Boolean isCorrectableUser{
        get{
            if(relatedDispute != null){
                if(String.valueOf(relatedDispute.Dispute_Resolver_gne__c) == UserInfo.getUserId() || String.valueOf(relatedDispute.OwnerId) == UserInfo.getUserId()){
                    return true;
                }
            }
            return false;
        }
    }
    */

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Getter for Held Transaction statuses
    * @return List<SelectOption>
    */
    /* HD Decommissioning
    public List<SelectOption> getHeldTransactionStatusList() {
        return AGS_ST_Utils.getPickListValuesWithExcept(
                                AGS_ST_Held_Transaction_gne__c.Held_Transaction_Process_Status_Code_gne__c.getDescribe(), 
                                new List<String>{'No Longer Valid'});
    }
    */

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Method for adding selected Id's to changing status to list
    * @return PageReference
    */
    /* HD Decommissioning
    public PageReference changeStatus() {
        selectedIds.clear();
        // Direct related list
        for(Integer i = 0; i<directRelatedHeldList.size(); i++) {
            if(directRelatedHeldList.get(i).isSelected == true) {
                selectedIds.add(directRelatedHeldList.get(i).heldId);
            }
        }
        // Indirect related list
        for(Integer i = 0; i<indirectRelatedHeldList.size(); i++) {
            if(indirectRelatedHeldList.get(i).isSelected == true) {
                selectedIds.add(indirectRelatedHeldList.get(i).heldId);
            }
        }
        return null;
    }
    */

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Method for adding all Id's to changing status to list
    * @return PageReference
    */
    /* HD Decommissioning
    public PageReference changeAllStatus() {
        selectedIds.clear();
        // Direct related list
        for(AGS_ST_Held_And_Dispute_Junction_gne__c junc : AGS_ST_DbUtils.getHeldListByDispIdAndDirectIndicator(disputeId, 'true', 1000)) {
            selectedIds.add(junc.AGS_ST_Held_Transaction_gne__r.Id);
        }
        // Indirect related list
        for(AGS_ST_Held_And_Dispute_Junction_gne__c junc : AGS_ST_DbUtils.getHeldListByDispIdAndDirectIndicator(disputeId, 'false', 9000)) {
            selectedIds.add(junc.AGS_ST_Held_Transaction_gne__r.Id);
        }
        return null;
    }
    */

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Method for updating statuses of Held Transactions
    * @return PageReference
    */
    /* HD Decommissioning
    public PageReference confirmStatusChange() {
        if(selectedIds.size()>0) {
            List<AGS_ST_Held_Transaction_gne__c> heldTransactionList = AGS_ST_DbUtils.getHeldListByIdList(selectedIds);
            List<AGS_ST_Held_Transaction_gne__c> htList = new List<AGS_ST_Held_Transaction_gne__c>();
            Integer i = 0;
            for(AGS_ST_Held_Transaction_gne__c ht : heldTransactionList) {
                ht.Held_Transaction_Process_Status_Code_gne__c = statusValue;
                // Limiting to 10000
                if(i<10000) {
                    htList.add(ht);
                }
                i++;
            }
            heldTransactionList = null;
            update htList;
            selectedIds.clear();
        }
        changeHTList(true, true, directHTUtil);
        changeHTList(true, false, indirectHTUtil);
        return null;
    }
    */

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Method for cancelling update action
    * @return PageReference
    */
    /* HD Decommissioning
    public PageReference cancelAction() {
        selectedIds.clear();
        return null;
    }
    */

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Method for setting values into Spend Expense Transaction List
    * @param Boolean initValue
    * @return PageReference
    */
    /* HD Decommissioning
    public PageReference changeExpenseList(Boolean initValue) {
        if(initValue || !relatedExpensesUtil.compareValues()) {
            relatedExpensesList = new List<AGS_Spend_Expense_Transaction_gne__c>();
            if(!String.isBlank(pr)) {
                standardCon = new ApexPages.StandardSetController(AGS_ST_DbUtils.getSpendExpTransByRecipientAndEventId(pr, event));
                relatedExpensesUtil.setParameters(standardCon.getResultSize());
                standardCon.setPageSize(relatedExpensesUtil.perPage);
                standardCon.first();
                for(Integer i=1; i<relatedExpensesUtil.actualPage; i++) {
                    standardCon.next();
                }
                for(AGS_Spend_Expense_Transaction_gne__c set1 : (List<AGS_Spend_Expense_Transaction_gne__c>)standardCon.getRecords()) {
                    relatedExpensesList.add(set1);
                }
                standardCon = null;
                relatedExpensesUtil.duplicateValues();
            }
        }
        return null;
    }  
    */

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Getter for VF - Spend Expense Transaction for the same event
    * @return List<AGS_Spend_Expense_Transaction_gne__c>
    */
    /* HD Decommissioning
    public List<AGS_Spend_Expense_Transaction_gne__c> getExpenseList() {
        changeExpenseList(false);
        return relatedExpensesList;
    }
    */

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Method for setting values into Related Transaction Lists
    * Boolean initValue
    * Boolean directList
    * AGS_ST_DMPagingAndSortingUtils htUtil
    * @return PageReference
    */
    /* HD Decommissioning
    public PageReference changeHTList(Boolean initValue, Boolean directList, AGS_ST_DMPagingAndSortingUtils htUtil) {
        if(initValue || !htUtil.compareValues()) {
            standardCon = new ApexPages.StandardSetController(AGS_ST_DbUtils.getHeldListByDispIdAndDirectIndicator(disputeId, String.valueOf(directList), (directList==true?1000:9000)));
            htUtil.setParameters(standardCon.getResultSize());
            standardCon.setPageSize(htUtil.perPage);
            standardCon.first();
            for(Integer i=1; i<htUtil.actualPage; i++) {
                standardCon.next();
            }
            List<HeldTransactionContainer> tempRelatedHeldList = new List<HeldTransactionContainer>();
            for(AGS_ST_Held_And_Dispute_Junction_gne__c ht : (List<AGS_ST_Held_And_Dispute_Junction_gne__c>)standardCon.getRecords()) {
                tempRelatedHeldList.add(new HeldTransactionContainer(ht));
            }
            if(directList) {
                directRelatedHeldList = tempRelatedHeldList.clone();
            } else {
                indirectRelatedHeldList = tempRelatedHeldList.clone();
            }
            standardCon = null;
            htUtil.duplicateValues();
        }
        return null;
    }  
    */

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Getter for VF - Direct Related Held Transactions
    * @return List<HeldTransactionContainer>
    */
    /* HD Decommissioning
    public List<HeldTransactionContainer> getDirectRelatedHTList() {
        changeHTList(false, true, directHTUtil);
        if(directRelatedHeldList != null && directRelatedHeldList.size() > 0){
            isAvStChngDir = true;
            isAllAvStChngDir = true;
        }
        Integer numUnavHelds = 0;
        Decimal srcAmount = 0;
        String status;
        for(HeldTransactionContainer i : directRelatedHeldList){
            status = i.heldTransaction.AGS_ST_Held_Transaction_gne__r.Held_Transaction_Process_Status_Code_gne__c;
            srcAmount = i.heldTransaction.AGS_ST_Held_Transaction_gne__r.Source_Transaction_Amount_gne__c;
            if((status != null && status.containsIgnoreCase('Ok to Process')) || (srcAmount != null && srcAmount < 0)){
                isAvStChngDir = false;
                numUnavHelds++;
            }
        }
        if(numUnavHelds > 0) isAllAvStChngDir = false;
        return directRelatedHeldList;
    }
    */

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Getter for VF - Indirect Related Held Transactions
    * @return List<HeldTransactionContainer>
    */
    /* HD Decommissioning
    public List<HeldTransactionContainer> getIndirectRelatedHTList() {
        changeHTList(false, false, indirectHTUtil);
        if(indirectRelatedHeldList != null && indirectRelatedHeldList.size() > 0){
            isAvStChngInd = true;
            isAllAvStChngInd = true;
        }
        Integer numUnavHelds = 0;
        Decimal srcAmount = 0;
        String status;
        for(HeldTransactionContainer i : indirectRelatedHeldList){
            status = i.heldTransaction.AGS_ST_Held_Transaction_gne__r.Held_Transaction_Process_Status_Code_gne__c;
            srcAmount = i.heldTransaction.AGS_ST_Held_Transaction_gne__r.Source_Transaction_Amount_gne__c;
            if((status != null && status.containsIgnoreCase('Ok to Process')) || (srcAmount != null && srcAmount < 0)){
                isAvStChngInd = false;
                numUnavHelds++;
            }
        }
        if(numUnavHelds > 0) isAllAvStChngInd = false;
        return indirectRelatedHeldList;
    }
    */

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Wrapper class for AGS_ST_Held_And_Dispute_Junction_gne__c object
    */
    /* HD Decommissioning
    public class HeldTransactionContainer {
        public transient AGS_ST_Held_And_Dispute_Junction_gne__c heldTransaction { get; set; }
        public Id heldId { get; set; }
        public Boolean isSelected { get; set; }
        public HeldTransactionContainer(AGS_ST_Held_And_Dispute_Junction_gne__c ht) {
            heldTransaction = ht;
            heldId = ht.AGS_ST_Held_Transaction_gne__r.Id;
            isSelected = false;
        }
    }
    */

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Method for setting values into Historical Related Transaction List
    * @param Boolean initValue
    * @return PageReference
    */
    /* HD Decommissioning
    public PageReference changeHistorical(Boolean initValue) {
        if(disputeManId == null || heldKey == null || disputeManId == '' || heldKey == '') {
            historicalHeldList = new List<AGS_ST_Held_And_Dispute_Junction_gne__c>();
        } else if(initValue || !historicalHTUtil.compareValues()) {
            standardCon = new ApexPages.StandardSetController(AGS_ST_DbUtils.getHeldListByDispIdAndSpendId((Id)disputeManId, heldKey));
            historicalHTUtil.setParameters(standardCon.getResultSize());
            standardCon.setPageSize(historicalHTUtil.perPage);
            standardCon.first();
            for(Integer i=1; i<historicalHTUtil.actualPage; i++) {
                standardCon.next();
            }
            historicalHeldList = new List<AGS_ST_Held_And_Dispute_Junction_gne__c>();
            for(AGS_ST_Held_And_Dispute_Junction_gne__c ht : (List<AGS_ST_Held_And_Dispute_Junction_gne__c>)standardCon.getRecords()) {
                historicalHeldList.add(ht);
            }
            standardCon = null;
            historicalHTUtil.duplicateValues();
        }
        return null;
    } 
    */

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Getter for VF - Historical related list
    * @return List<AGS_ST_Held_And_Dispute_Junction_gne__c>
    */
    /* HD Decommissioning
    public List<AGS_ST_Held_And_Dispute_Junction_gne__c> getHistoricalHTList() {
        changeHistorical(false);
        return historicalHeldList;
    }
    */

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Method for executing changeHistorical() method
    * @return PageReference
    */
    /* HD Decommissioning
    public PageReference setHistorical() {
        historicalHTUtil = new AGS_ST_DMPagingAndSortingUtils(5);
        changeHistorical(true);
        return null;
    }
    */
}