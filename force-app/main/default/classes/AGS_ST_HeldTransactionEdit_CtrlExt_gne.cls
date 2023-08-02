/** @date 10/2/2012
* @Author Pawel Sprysak
* @description Controller for AGS_ST_HeldTransactionEdit_gne page
*/
public without sharing class AGS_ST_HeldTransactionEdit_CtrlExt_gne {
	/* HD Decommissioning
    private final static Integer MAX_ROW_NUM_FOR_SPENDS = 2000;
    private final static Integer MAX_ROW_NUM_FOR_DISPUTES = 5000;
    private final static Integer MAX_ROW_NUM_FOR_HELDS = 2000;
    public Boolean isMaxDisputes {
        get {
            return spendExpenseUtil.totalDisputes == MAX_ROW_NUM_FOR_SPENDS;
        }
    }
    // Linking list
    private Id heldId;
    public AGS_ST_Held_And_Dispute_Junction_gne__c disputeHolder { get; set; }
    public AGS_ST_DMPagingAndSortingUtils heldTransactionsUtil { get; set; }
    private transient ApexPages.StandardSetController heldsCon { get; set; }
    public transient List<AGS_ST_Held_Transaction_gne__c>  heldsList { get; set; }
    public AGS_ST_DMPagingAndSortingUtils linkedDisputesUtil { get; set; }
    private transient ApexPages.StandardSetController disputeCon { get; set; }
    public List<DisputeWrapper> disputeListHolder { get; set; }
    // Wizzard - 1 step
    public Integer stepVal { get; set; }
    public String spendName { get; set; }
    public String firstName { get; set; }
    public String lastName { get; set; }
    public String amountFromStr {
        get;
        set {
            amountFromStr = value;
            try {
                if(value != null) {
                    amountFrom = Decimal.valueOf(value);
                } else {
                    amountFrom = null;
                }
            } catch(TypeException te) {
                amountFrom = -9999999999999.99;
            }
        }
    }
    public String amountToStr {
        get;
        set {
            amountToStr = value;
            try {
                if(value != null) {
                    amountTo = Decimal.valueOf(value);
                } else {
                    amountTo = null;
                }
            } catch(TypeException te) {
                amountTo = 9999999999999.99;
            }
        } 
    }
    public Decimal amountFrom { get; set; }
    public Decimal amountTo { get; set; }
    public String mdmId { get; set; }
    public String npi { get; set; }
    public String eventCity { get; set; }
    public AGS_ST_DisputeManagement_gne__c paymentDateFrom { get; set; }
    public AGS_ST_DisputeManagement_gne__c paymentDateTo { get; set; }
    // Wizzard - 2 step
    public String setId { get; set; }
    public AGS_ST_DMPagingAndSortingUtils spendExpenseUtil { get; set; }
    public transient List<AGS_Spend_Expense_Transaction_gne__c> myList { get; set; }
    private transient ApexPages.StandardSetController setCon { get; set; }
    private String selectQuery { get; set; }
    // Wizzard - 3 step
    public Decimal amountValue { get; set; }
    public Boolean isAttendeeDisabled { get; set; }
    public String sourceAmountValue { get; set; }
    public String allocatedAmountValue { get; set; }
    public String attendeesValue { get; set; }
    public String formValue { get; set; }
    public String natureValue { get; set; }
    public String drugValue { get; set; }
    private String primarySrcSpend { get; set; }
    private String primaryAttendees { get; set; }
    private String primaryFormValue { get; set; }
    private String primaryNatureValue { get; set; }
    private String primaryDrugValue { get; set; }
    private Datetime paymentDateValue { get; set; }
    public String disputeStatus { get; set; }
    private Boolean temporaryUnlock { get; set; }
    public Boolean doNotReport { get; set; }
    public Integer plannedAttendeeCount { get; set; }
    public Integer actualAttendeeCount { get; set; }
    public Integer siteAtndCnt { get; set; }
    // Wizzard - 4 step
    public String statusValue { get; set; }
    private AGS_ST_Held_Transaction_gne__c heldTransactionObj;
    // HT Dispute Creation
    public Boolean showCreationForm { get; set; }
    public AGS_ST_DisputeManagement_gne__c dmWrapper { get; set; }
    public transient List<AGS_ST_DisputeManagement_gne__c> htDMListAll { get; set; }
    public AGS_ST_DMPagingAndSortingUtils htdmUtil { get; set; }
    private transient ApexPages.StandardSetController htdmCon { get; set; }
    // Messages
    public String actionMessages { get; set; }
    */

    /** @date 10/2/2012
    * @Author Pawel Sprysak
    * @description Constructor for AGS_ST_HeldTransactionEdit_CtrlExt_gne
    */
    public AGS_ST_HeldTransactionEdit_CtrlExt_gne(ApexPages.StandardController controller) {}
    /* HD Decommissioning
        heldTransactionObj = (AGS_ST_Held_Transaction_gne__c) controller.getRecord();
        heldId = controller.getId();
        actionMessages = '';
        // Linking dispute
        disputeHolder = new AGS_ST_Held_And_Dispute_Junction_gne__c();
        linkedDisputesUtil = new AGS_ST_DMPagingAndSortingUtils(5);
        heldTransactionsUtil = new AGS_ST_DMPagingAndSortingUtils(5);
        htdmUtil = new AGS_ST_DMPagingAndSortingUtils(5);
        disputeListHolder = new List<DisputeWrapper>(); 
        // Create dispute wizzard - Step 1
        stepVal = 1;
        spendName = '';
        firstName = '';
        lastName = '';
        paymentDateFrom = new AGS_ST_DisputeManagement_gne__c();
        paymentDateTo = new AGS_ST_DisputeManagement_gne__c();
        eventCity = '';
        mdmId = '';
        npi = '';
        // Create dispute wizzard - Step 2
        spendExpenseUtil = new AGS_ST_DMPagingAndSortingUtils();
        // Create dispute wizzard - Step 3
        temporaryUnlock = false;
        statusValue = heldTransactionObj.Held_Transaction_Process_Status_Code_gne__c;
        AGS_ST_Held_Transaction_gne__c heldTransct = [SELECT Planned_Attendee_Count__c, Actual_Attendee_Count_gne__c, Id FROM AGS_ST_Held_Transaction_gne__c WHERE Id = :heldId limit 1];
        if(heldTransct.Planned_Attendee_Count__c != null){
            plannedAttendeeCount = heldTransct.Planned_Attendee_Count__c.intValue();
        }
        if(heldTransct.Actual_Attendee_Count_gne__c != null){
            actualAttendeeCount = heldTransct.Actual_Attendee_Count_gne__c.intValue();
        }
        changePageForHelds(true);
        //if(heldTransct.SITE_ATND_CNT_GNE__c != null && heldTransct.SITE_ATND_CNT_GNE__c > 0){
        //  siteAtndCnt = heldTransct.SITE_ATND_CNT_GNE__c.intValue();
        //}else{
        //  siteAtndCnt = 0;
        //}
        // Create HT Dispute
        setHTDDefaultValues();
        changePageForHTDM(true);
    }
    */

    /** @date 7/30/2013
    * @Author Pawel Sprysak
    * @description Setting HT Dispute default values
    */
    /* HD Decommissioning
    public void setHTDDefaultValues() {
        showCreationForm = false;
        dmWrapper = new AGS_ST_DisputeManagement_gne__c(AGS_ST_Held_Transaction__c = heldTransactionObj.Id, isPrivate__c = true, Payment_Date_gne__c = heldTransactionObj.Transaction_Date_gne__c, Amount_gne__c = heldTransactionObj.Source_Transaction_Amount_gne__c, Orig_Allocated_Transaction_Amount_gne__c = heldTransactionObj.Source_Transaction_Amount_gne__c, Drug_Name_gne__c = heldTransactionObj.Brand_Code_List_gne__c, Orig_Drug_Name_gne__c = heldTransactionObj.Brand_Code_List_gne__c, Form_Of_Payment_gne__c = heldTransactionObj.Form_of_Payment_gne__c, Orig_Form_Of_Payment_gne__c = heldTransactionObj.Form_of_Payment_gne__c, Nature_Of_Payment_gne__c = heldTransactionObj.Nature_of_Payment_gne__c, Orig_Nature_Of_Payment_gne__c = heldTransactionObj.Nature_of_Payment_gne__c, Internal_Status_gne__c = 'Corrected Pending SSR', External_Status_gne__c = 'Resolved');
        changePageForHTDM(true);
    }
    */

    /** @date 7/30/2013
    * @Author Pawel Sprysak
    * @description Getter for Held Transaction Disputes
    * @return List<AGS_ST_DisputeManagement_gne__c>
    */
    /* HD Decommissioning
    public List<AGS_ST_DisputeManagement_gne__c> gethtDMList() {
        changePageForHTDM(false);
        return htDMListAll;
    }
    */

    /** @date 7/30/2013
    * @Author Pawel Sprysak
    * @description Method for setting values into the list
    * @param Boolean initValue
    */
    /* HD Decommissioning
    public void changePageForHTDM(Boolean initValue) {
        // Check whether is this init value or pagination/sorting value has been changed
        if(initValue || !htdmUtil.compareValues()) {
            if(htdmCon == null) {
                htdmCon = new ApexPages.StandardSetController([SELECT CreatedDate, Internal_Status_gne__c, Amount_gne__c, Form_Of_Payment_gne__c, Nature_Of_Payment_gne__c, Drug_Name_gne__c FROM AGS_ST_DisputeManagement_gne__c WHERE AGS_ST_Held_Transaction__c = :heldTransactionObj.Id ORDER BY CreatedDate DESC LIMIT 1000]);
            }
            htdmUtil.setParameters(htdmCon.getResultSize());
            htdmCon.setPageSize(htdmUtil.perPage);
            for(Integer i=1; i<htdmUtil.actualPage; i++) {
                htdmCon.next();
            }
            
            htDMListAll = ((List<AGS_ST_DisputeManagement_gne__c>)htdmCon.getRecords()).clone();
            htdmCon = null;
            
            htdmUtil.duplicateValues();           
        }
    }
    */

    /** @date 10/2/2012
    * @Author Pawel Sprysak
    * @description Getter for Form of Payment
    * @return List<SelectOption>
    */
    /* HD Decommissioning
    public List<SelectOption> getFormsOfPayment() {
        return AGS_ST_Utils.getPickListValues(AGS_ST_DisputeManagement_gne__c.Form_Of_Payment_gne__c.getDescribe());
    }
    */

    /** @date 10/2/2012
    * @Author Pawel Sprysak
    * @description Getter for Nature of Payment
    * @return List<SelectOption>
    */
    /* HD Decommissioning
    public List<SelectOption> getNaturesOfPayment() {
        return AGS_ST_Utils.getPickListValues(AGS_ST_DisputeManagement_gne__c.Nature_Of_Payment_gne__c.getDescribe());
    }
    */

    /** @date 10/2/2012
    * @Author Pawel Sprysak
    * @description Getter for Drug Names
    * @return List<SelectOption>
    */
    /* HD Decommissioning
    public List<SelectOption> getDrugNames() {
        return AGS_ST_DbUtils.getDrugNames();
    }
    */

    /** @date 12/24/2012
    * @Author Pawel Sprysak
    * @description Getter for Dispute Statuses (possible statuses for creating dispute in Step 3)
    * @return List<SelectOption>
    */
    /* HD Decommissioning
    public List<SelectOption> getDisputeStatuses() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Corrected Pending SSR', 'Corrected Pending SSR'));
        options.add(new SelectOption('Resolved With Correction', 'Resolved With Correction'));
        options.add(new SelectOption('Resolved No Correction', 'Resolved No Correction'));
        return options;
    }
    */

    /** @date 12/24/2012
    * @Author Pawel Sprysak
    * @description Getter for Held Process Status (possible statuses for user in Step 4)
    * @return List<SelectOption>
    */
    /* HD Decommissioning
    public List<SelectOption> getHeldTransactionStatusList() {
        return AGS_ST_Utils.getPickListValuesWithExcept(
                                AGS_ST_Held_Transaction_gne__c.Held_Transaction_Process_Status_Code_gne__c.getDescribe(), 
                                new List<String>{'No Longer Valid'});
    }
    */

    /** @date 12/10/2012
    * @Author Pawel Sprysak
    * @description Method for setting list of disputes to Linked Disputes section
    * @param Boolean initValue
    */
    /* HD Decommissioning
    public void setNewDisputeList(Boolean initValue) {
        // Check whether is this init value or pagination/sorting value has been changed
        if(initValue || !linkedDisputesUtil.compareValues()) {
            if(disputeCon == null) {
                disputeCon = new ApexPages.StandardSetController(AGS_ST_DbUtils.getHeldJuncListByHeldId(heldId, MAX_ROW_NUM_FOR_DISPUTES));
            }
            linkedDisputesUtil.setParameters(disputeCon.getResultSize());
            disputeCon.setPageSize(linkedDisputesUtil.perPage);
            for(Integer i=1; i<linkedDisputesUtil.actualPage; i++) {
                disputeCon.next();
            }
            disputeListHolder.clear();
            for(sObject junc : disputeCon.getRecords()) {
                disputeListHolder.add(new DisputeWrapper((AGS_ST_Held_And_Dispute_Junction_gne__c)junc));
            }
            disputeCon = null;
            linkedDisputesUtil.duplicateValues();
        }
    }

    public List<AGS_ST_Held_Transaction_gne__c> getHeldList() {
        changePageForHelds(false);
        return heldsList;
    }
    
    public void changePageForHelds(Boolean initValue) {
        // Check whether is this init value or pagination/sorting value has been changed
        if(initValue || !heldTransactionsUtil.compareValues()) {
            if(heldsCon == null) {
                heldsCon = new ApexPages.StandardSetController(AGS_ST_DbUtils.getHeldListByMDMIdList(heldTransactionObj.MDM_ID_GNE__c, MAX_ROW_NUM_FOR_HELDS));
            }
            heldTransactionsUtil.setParameters(heldsCon.getResultSize());
            heldsCon.setPageSize(heldTransactionsUtil.perPage);
            for(Integer i=1; i<heldTransactionsUtil.actualPage; i++) {
                heldsCon.next();
            }
            
            heldsList = ((List<AGS_ST_Held_Transaction_gne__c>)heldsCon.getRecords()).clone();
            heldsCon = null;
            
            heldTransactionsUtil.duplicateValues();           
        }
    }      
    */

    /** @date 12/10/2012
    * @Author Pawel Sprysak
    * @description Getter for VF - for Dispute List
    * @return List<DisputeWrapper>
    */
    /* HD Decommissioning
    public List<DisputeWrapper> getDisputeList() {
        setNewDisputeList(false);
        return disputeListHolder;
    }
    */

    /** @date 7/30/2012
    * @Author Pawel Sprysak
    * @description Methof for changing show form flag and creating default values
    * @return PageReference
    */
    /* HD Decommissioning
    public PageReference showCreatingForm() {
        setHTDDefaultValues();
        showCreationForm = true;
        return null;
    }
    */

    /** @date 7/30/2012
    * @Author Pawel Sprysak
    * @description Methof for creating Held Transaction Dispute
    * @return PageReference
    */
    /* HD Decommissioning
    public PageReference createHTDispute() {
        insert dmWrapper;
        setHTDDefaultValues();
        actionMessages = 'Dispute for Held Transaction has been created.';
        return null;
    }
    */

    /** @date 12/10/2012
    * @Author Pawel Sprysak
    * @description Method for linking Dispute with Held Transaction
    * @return PageReference
    */
    /* HD Decommissioning
    public PageReference linkDisputeToHeldTransaction() {
        // Checking wheather dispute allready linked to this Held Transaction
        Boolean allreadyExist = false;
        for(DisputeWrapper wrap : disputeListHolder) {
            if(wrap.dmId == disputeHolder.AGS_ST_Dispute_Management_gne__c) {
                allreadyExist = true;
            }
        }
        // Checking dispute status
        String internalStatus = AGS_ST_DbUtils.getDisputeInternalStatusById(disputeHolder.AGS_ST_Dispute_Management_gne__c);
        if(!temporaryUnlock && (internalStatus.equals('Corrected Pending SSR') || internalStatus.equals('Resolved With Correction') || internalStatus.equals('Resolved No Correction'))) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Cannot link disputes with status Resolved.'));
            actionMessages = '';
        } else if(disputeHolder.AGS_ST_Dispute_Management_gne__c == null) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please fill correct dispute value.'));
            actionMessages = '';
        } else if(allreadyExist == false) {
            // Linking dispute to Held Transaction
            AGS_ST_Held_And_Dispute_Junction_gne__c newJunction = new AGS_ST_Held_And_Dispute_Junction_gne__c();
            newJunction.AGS_ST_Held_Transaction_gne__c = heldId;
            newJunction.AGS_ST_Dispute_Management_gne__c = disputeHolder.AGS_ST_Dispute_Management_gne__c;
            newJunction.AGS_ST_ProcessedByEmailBatch_gne__c = true;
            insert newJunction;
            disputeHolder = new AGS_ST_Held_And_Dispute_Junction_gne__c();
            actionMessages = 'Dispute has been linked to this Held Transaction<br/>';
            setNewDisputeList(true);
        } else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'That relation allready exist.'));
            actionMessages = '';
        }

        return null;
    }
    */

    /** @date 12/10/2012
    * @Author Pawel Sprysak
    * @description Method for unlinking Dispute from Held Transaction
    * @return PageReference
    */
    /* HD Decommissioning
    public PageReference unlinkDisputesFromHeldTransaction() {
        List<AGS_ST_Held_And_Dispute_Junction_gne__c> disputesToUnlink = new List<AGS_ST_Held_And_Dispute_Junction_gne__c>();
        //Checking dispute status (can unlink only disputes with status other than Resolved)
        for(DisputeWrapper wrap : disputeListHolder) {
            if(wrap.selectedDispute == true && !wrap.isResolved) {
                AGS_ST_Held_And_Dispute_Junction_gne__c junction = new AGS_ST_Held_And_Dispute_Junction_gne__c(Id = wrap.juncId);
                disputesToUnlink.add(junction);
            }
        }
        if(disputesToUnlink.size() > 0) {
            //Unlinking dispute
            delete disputesToUnlink;
            actionMessages = 'Dispute has been unlinked from this Held Transaction<br/>';
            setNewDisputeList(true);
        } else {
            actionMessages = '';
        }

        return null;
    }
    */

    /** @date 12/10/2012
    * @Author Pawel Sprysak
    * @description Searching Spend Expense Transaction method (Step 1) 
    * @return PageReference
    */
    /* HD Decommissioning
    public PageReference searchSpends() {
        stepVal = 2;
        actionMessages = '';
        if( String.isBlank(amountFromStr) ) {
            amountFrom = null;
        }
        if( String.isBlank(amountToStr) ) {
            amountTo = null;
        } 
        selectQuery = AGS_ST_Utils.getAllSpendExpenseTransactionIdsQueryByParam(firstName, lastName, amountFrom, amountTo, paymentDateFrom, paymentDateTo, eventCity, mdmId, npi, spendName);
        changePageForSpends(true);

        return null;
    }
    */

    /** @date 12/10/2012
    * @Author Pawel Sprysak
    * @description Method for setting values into Spend Expense Transaction List
    * @param Boolean initValue
    * @return PageReference
    */
    /* HD Decommissioning
    public PageReference changePageForSpends(Boolean initValue) {
        //Check whether is this init value or pagination/sorting value has been changed
        if(initValue || !spendExpenseUtil.compareValues()) {
            setCon = new ApexPages.StandardSetController(AGS_ST_DbUtils.getSpendExpTransactionByQuery(selectQuery + ' LIMIT ' + MAX_ROW_NUM_FOR_SPENDS));
            spendExpenseUtil.setParameters(setCon.getResultSize());
            setCon.setPageSize(spendExpenseUtil.perPage);
            setCon.first();
            for(Integer i=1; i<spendExpenseUtil.actualPage; i++) {
                setCon.next();
            }
            List<Id> idList = new List<Id>();
            for(AGS_Spend_Expense_Transaction_gne__c set1 : (List<AGS_Spend_Expense_Transaction_gne__c>)setCon.getRecords()) {
                idList.add(set1.Id);
            }
            setCon = null;
            myList = AGS_ST_DbUtils.getSpendExpTransListByIdList(idList);
            idList = null;
            spendExpenseUtil.duplicateValues();
        }
        return null;
    }  
    */

    /** @date 12/10/2012
    * @Author Pawel Sprysak
    * @description Getter for VF - for Spend Expense Transaction List
    * @return List<AGS_Spend_Expense_Transaction_gne__c>
    */
    /* HD Decommissioning
    public List<AGS_Spend_Expense_Transaction_gne__c> getSpendList() {
        changePageForSpends(false);
        return myList;
    }
    */

    /** @date 12/10/2012
    * @Author Pawel Sprysak
    * @description Selecting Spend Expense Transaction and displaying Dispute Create form (Step 2)
    * @return PageReference
    */
    /* HD Decommissioning
    public PageReference selectDispute() {
        stepVal = 3;
        AGS_Spend_Expense_Transaction_gne__c spend = AGS_ST_DbUtils.getSpendExpTransById(setId);
        // Filling fields for create dispute form
        amountValue = spend.Allocated_Transaction_Amount_gne__c;
        sourceAmountValue = String.valueOf(spend.Source_Transaction_Amount_gne__c);
        primarySrcSpend = String.valueOf(spend.Source_Transaction_Amount_gne__c);
        isAttendeeDisabled = false;
        if(spend.Event_Actual_Attendee_Count_gne__c == null || spend.Source_System_Code_gne__c.equals('SAPBW')) {
            attendeesValue = '1';
            primaryAttendees = '1';
            if(spend.Source_System_Code_gne__c.equals('SAPBW')) {
                isAttendeeDisabled = true;
            }
        } else {
            attendeesValue = String.valueOf(spend.Event_Actual_Attendee_Count_gne__c);
            primaryAttendees = String.valueOf(spend.Event_Actual_Attendee_Count_gne__c);
        }
        if(spend.Form_Of_Payment_gne__c == null) {
            formValue = 'UNCLASSIFIED';
        } else {
            formValue = spend.Form_Of_Payment_gne__c;
        }
        primaryFormValue = formValue;
        if(spend.Nature_Of_Payment_gne__c == null) {
            natureValue = 'UNCLASSIFIED';
        } else {
            natureValue = spend.Nature_Of_Payment_gne__c;
        }
        primaryNatureValue = natureValue;
        if(spend.AGS_Expense_Products_Interaction__r.size() > 0) {
            drugValue = spend.AGS_Expense_Products_Interaction__r.get(0).AGS_Brand__c;
            primaryDrugValue = spend.AGS_Expense_Products_Interaction__r.get(0).AGS_Brand__c;
        } else {
            drugValue = '';
            primaryDrugValue = '';
        }

        return null;
    }
    */

    /** @date 12/10/2012
    * @Author Pawel Sprysak
    * @description Creating Dispute method (Step 3) 
    * @return PageReference
    */
    /* HD Decommissioning
    public PageReference createDispute() {
        if(heldTransactionObj.Held_Transaction_Process_Status_Code_gne__c != null && (heldTransactionObj.Held_Transaction_Process_Status_Code_gne__c.equalsIgnoreCase('Ok to Process') || heldTransactionObj.Held_Transaction_Process_Status_Code_gne__c.equalsIgnoreCase('No Longer Valid'))){
            stepVal = 1;
        } else {
            stepVal = 4;
        }
        Id disputeId = saveDispute(String.valueOf(setId),String.valueOf(paymentDateValue),String.valueOf(amountValue),formValue,natureValue,drugValue,'',sourceAmountValue,attendeesValue);
        if(disputeId != null) {
            String disputeName = AGS_ST_DbUtils.getDisputeNameById(disputeId);
            actionMessages = 'New dispute <a href="/apex/AGS_ST_DisputeDetail_gne?id='+disputeId+'" target="_blank">'+disputeName+'</a> has been created<br/>';
        //  setNewDisputeList(true);
        } else {
            actionMessages = 'Dispute has NOT been created. You must change at least one of the dispute fields.<br/>';
        }

        return null;
    }
    */

    /** @date 12/10/2012
    * @Author Pawel Sprysak
    * @description Method for saving/creating new dispute
    * @param String spendId
    * @param String paymentDate
    * @param String amount
    * @param String formValue
    * @param String natureValue
    * @param String brand
    * @param String otherNote
    * @param String sourceValue
    * @param String attendeesValue
    * @return Id
    */
    /* HD Decommissioning
    private Id saveDispute(String spendId,String paymentDate,String amount,String method,String reason,String brand,String otherNote,String sourceValue,String attendeesValue) {
        AGS_Spend_Expense_Transaction_gne__c spend = AGS_ST_DbUtils.getSpendExpTransById(spendId);
        if(spend != null) {
            // Reseting values for No Correction
            if(disputeStatus.equals('Resolved No Correction')) {
                attendeesValue = primaryAttendees;
                sourceValue = primarySrcSpend;
                brand = primaryDrugValue;
                formValue = primaryFormValue;
                natureValue = primaryNatureValue;
            } else {
                amount = String.valueOf((Decimal.valueOf(sourceValue)/Decimal.valueOf(attendeesValue)).SetScale(2));
            }
            // Creating AGS_ST_Dispute_List_gne object
            AGS_ST_Dispute_List_gne__c disputeListObj = new AGS_ST_Dispute_List_gne__c();
            disputeListObj.OwnerId = UserInfo.getUserId();
            disputeListObj.isPrivate_gne__c = true;
            disputeListObj.AGS_Spend_Expense_Transaction_gne__c = spendId;
            // Creating AGS_ST_DisputeManagement_gne object
            AGS_ST_DisputeManagement_gne__c disputeManObj = new AGS_ST_DisputeManagement_gne__c();
            disputeManObj.AGS_Spend_Expense_Transaction_gne__c = spendId;
            disputeManObj.Internal_Status_gne__c = disputeStatus;
            disputeManObj.isPrivate__c = true;
            disputeManObj.Do_Not_Report_Flag_gne__c = doNotReport;
            disputeManObj.Attendees_gne__c = Decimal.valueOf(attendeesValue);
            disputeManObj.Source_Amount_gne__c = Decimal.valueOf(sourceValue);
            // Common values
            String spendBrand = '';
            if(spend.AGS_Expense_Products_Interaction__r.size() > 0) {
                spendBrand = spend.AGS_Expense_Products_Interaction__r[0].AGS_Brand__c;
            }
            AGS_ST_Utils.fillDLAndDMByStdValues(disputeListObj, disputeManObj, amount, spend.Allocated_Transaction_Amount_gne__c, brand, spendBrand, formValue, spend.Form_Of_Payment_gne__c, natureValue, spend.Nature_Of_Payment_gne__c);
            // Set indicators
            if(!primaryDrugValue.equals(drugValue)) {
                disputeListObj.isBrandDisputed_gne__c = true;
            } else {
                disputeListObj.isBrandDisputed_gne__c = false;
            }
            if(!primaryAttendees.equalsIgnoreCase(attendeesValue) || !primarySrcSpend.equalsIgnoreCase(sourceAmountValue)) {
                disputeListObj.isAmountDisputed_gne__c = true;
            } else {
                disputeListObj.isAmountDisputed_gne__c = false;
            }
            if(primaryFormValue == null || !primaryFormValue.equalsIgnoreCase(formValue)) {
                disputeListObj.isFormDisputed_gne__c = true;
            } else {
                disputeListObj.isFormDisputed_gne__c = false;
            }
            if(primaryNatureValue == null || !primaryNatureValue.equalsIgnoreCase(natureValue)) {
                disputeListObj.isNatureDisputed_gne__c = true;
            } else {
                disputeListObj.isNatureDisputed_gne__c = false;
            }
            System.debug('------- save dispute ');
            if(disputeStatus.equals('Resolved No Correction') || disputeListObj.isBrandDisputed_gne__c || disputeListObj.isAmountDisputed_gne__c || disputeListObj.isFormDisputed_gne__c || disputeListObj.isNatureDisputed_gne__c) {
                System.debug('------- save dispute - inserting');
                // Insert objects
                AGS_ST_DisputeResolver_gne__c disputeResObj = new AGS_ST_DisputeResolver_gne__c();
                insert disputeResObj;
                insert disputeListObj;
                disputeManObj.Dispute_List_gne__c = disputeListObj.id;
                disputeManObj.Dispute_Resolver_gne__c = disputeResObj.Id;
                insert disputeManObj;
                // set Logical Delete flag on Spend
                System.debug('------- save dispute - spend.LogicalDeleteFlag_gne__c != doNotReport ' + spend.LogicalDeleteFlag_gne__c +' ' + doNotReport);
                if(spend.LogicalDeleteFlag_gne__c != doNotReport) {
                    spend.LogicalDeleteFlag_gne__c = doNotReport;
                    System.debug('------- save dispute - updating spend');
                    update spend;
                }   
                // Linking dispute with held functionality
                disputeHolder.AGS_ST_Dispute_Management_gne__c = disputeManObj.Id;
                temporaryUnlock = true;
                linkDisputeToHeldTransaction();
                temporaryUnlock = false;
                statusValue = heldTransactionObj.Held_Transaction_Process_Status_Code_gne__c;
                return disputeManObj.Id;
            } else {
                return null;
            }
        }
        return null;
    }
    */

    /** @date 12/10/2012
    * @Author Pawel Sprysak
    * @description Changing status method in wizzard (Step 4)
    * @return PageReference
    */
    /* HD Decommissioning
    public PageReference changeStatus() {
        stepVal = 1;
        changeOnlyStatus();

        return null;
    }
    */

    /** @date 12/10/2012
    * @Author Pawel Sprysak
    * @description Changing status method
    * @return PageReference
    */
    /* HD Decommissioning
    public PageReference changeOnlyStatus() {
        Id recordId = heldTransactionObj.Id;
        AGS_ST_Held_Transaction_gne__c heldTransaction = AGS_ST_DbUtils.getHeldListByIdList(new List<Id>{recordId}).get(0);
        heldTransaction.Held_Transaction_Process_Status_Code_gne__c = statusValue;
        update heldTransaction;
        heldTransactionObj.Held_Transaction_Process_Status_Code_gne__c = statusValue;
        actionMessages += 'New held transaction status has been settled<br/>';

        return null;
    }
    */

    /** @date 12/10/2012
    * @Author Pawel Sprysak
    * @description Wrapped class for Dispute List
    */
    /* HD Decommissioning
    public class DisputeWrapper {
        public Id juncId { get; set; }
        public Boolean selectedDispute { get; set; }
        public Boolean isResolved { get; set; }
        public String linkDate { get; set; }
        public Id dmId { get; set; }
        public String dmName { get; set; }
        public String dmIsPrivate { get; set; }
        public String dmStatus { get; set; }
        public String isDirect { get; set; } 

        public DisputeWrapper(AGS_ST_Held_And_Dispute_Junction_gne__c junc) {
            juncId = junc.Id;
            dmName = junc.AGS_ST_Dispute_Management_gne__r.Name;
            dmId = junc.AGS_ST_Dispute_Management_gne__r.Id;
            if(junc.AGS_ST_Dispute_Management_gne__r.isPrivate__c) {
                dmIsPrivate = 'Internal';
            } else {
                dmIsPrivate = 'External';
            }
            if(junc.AGS_ST_Direct_Relationship_Indicator_gne__c == 'true') {
                isDirect = 'Direct';
            } else {
                isDirect = 'Indirect';
            }
            dmStatus = junc.AGS_ST_Dispute_Management_gne__r.Internal_Status_gne__c;
            isResolved = (junc.AGS_ST_Dispute_Management_gne__r.Internal_Status_gne__c == 'Corrected Pending SSR' || junc.AGS_ST_Dispute_Management_gne__r.Internal_Status_gne__c == 'Resolved With Correction' || junc.AGS_ST_Dispute_Management_gne__r.Internal_Status_gne__c == 'Resolved No Correction');
            linkDate = junc.LastModifiedDate.format('M/d/yyyy h:mm a');
            selectedDispute = false;
        }
    }
    */
}