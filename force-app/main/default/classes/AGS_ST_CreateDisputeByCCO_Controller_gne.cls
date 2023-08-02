/** @date 10/11/2012
* @Author Pawel Sprysak
* @description Controller for AGS_ST_CreateDisputeByCCO_gne page
*/
global without sharing class AGS_ST_CreateDisputeByCCO_Controller_gne {
    private final static Integer MAX_ROW_NUM = 2000;
    public Boolean isMaxDisputes {
        get {
            return spendExpenseUtil.totalDisputes == MAX_ROW_NUM;
        }
    }
    // Spend Expense Transaction List
    public AGS_ST_DMPagingAndSortingUtils spendExpenseUtil { get; set; }
    private transient ApexPages.StandardSetController setCon { get; set; }
    public transient List<AGS_Spend_Expense_Transaction_gne__c> myList { get; set; }
    private String selectQuery { get; set; }
    public Boolean isAlreadyCreated { get; set; }
    // Search fields
    public String spendName { get; set; }
    public String firstName { get; set; }
    public String lastName { get; set; }
    public String mdmId { get; set; }
    public String npi { get; set; }
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
    public String eventCity { get; set; }
    public AGS_ST_DisputeManagement_gne__c paymentDateFrom { get; set; }
    public AGS_ST_DisputeManagement_gne__c paymentDateTo { get; set; }
    // Dispute fields
    public AGS_Spend_Expense_Transaction_gne__c spend { get; set; }
    private AGS_ST_User_gne__c stUser { get; set; }
    public String amountSpend { get; set; }
    public String formValue { get; set; }
    public String natureValue { get; set; }
    public String drugValue { get; set; }
    private String primaryAmountSpend { get; set; }
    private String primaryFormValue { get; set; }
    private String primaryNatureValue { get; set; }
    private String primaryDrugValue { get; set; }
    public String explanation { get; set; }
    public String preferredMethod { get; set; }
    public String preferredValue { get; set; }
    public String internalDispute { get; set; }
    public Boolean isCmsDispute { get; set; }
    public String cmsDisputeId { get; set; }
    public Id transactionId { get; set; }
    private Datetime paymentDateValue { get; set; }
    private String defaultEmail { get; set; }
    // Messages
    public String actionMessages { get; set; }
    public Boolean spendLogicalDelFlag {get; set;}

    /** @date 10/11/2012
    * @Author Pawel Sprysak
    * @description Constructor for AGS_ST_CreateDisputeByCCO_Controller_gne
    */
    public AGS_ST_CreateDisputeByCCO_Controller_gne() {
        spendName = '';
        firstName = '';
        lastName = '';
        paymentDateFrom = new AGS_ST_DisputeManagement_gne__c();
        paymentDateTo = new AGS_ST_DisputeManagement_gne__c();
        eventCity = '';
        mdmId = '';
        npi = '';
        spendExpenseUtil = new AGS_ST_DMPagingAndSortingUtils();
        actionMessages = '';
        internalDispute = 'false';
        isCmsDispute = false;
        cmsDisputeId = null;
        try {
            transactionId = (Id)ApexPages.currentPage().getParameters().get('id');
        } catch(StringException se) {
            transactionId = null;
        }
    }

    /** @date 10/11/2012
    * @Author Pawel Sprysak
    * @description Getter for Form of Payment select list
    * @return List<SelectOption>
    */
    public List<SelectOption> getFormsOfPayment() {
        return AGS_ST_Utils.getPickListValues(AGS_ST_DisputeManagement_gne__c.Form_Of_Payment_gne__c.getDescribe());
    }

    /** @date 10/11/2012
    * @Author Pawel Sprysak
    * @description Getter for Nature of Payment select list
    * @return List<SelectOption>
    */
    public List<SelectOption> getNaturesOfPayment() {
        return AGS_ST_Utils.getPickListValues(AGS_ST_DisputeManagement_gne__c.Nature_Of_Payment_gne__c.getDescribe());
    }

    /** @date 10/11/2012
    * @Author Pawel Sprysak
    * @description Getter for Drug Names select list
    * @return List<SelectOption>
    */
    public List<SelectOption> getDrugNames() {
        return AGS_ST_DbUtils.getDrugNames();
    }

    /** @date 10/11/2012
    * @Author Pawel Sprysak
    * @description Getter for Dispute Type
    * @return List<SelectOption>
    */
    public List<SelectOption> getDisputeStatus() {
        // Check whether is possibility to create External Dispute
        if(isAlreadyCreated || stuser == null) {
            return new List<SelectOption>{new SelectOption('true', 'Internal Dispute')};
        } else {
            return new List<SelectOption>{new SelectOption('', '-SELECT-'), new SelectOption('true', 'Internal Dispute'), new SelectOption('false', 'External Dispute')};
        }
    }

    /** @date 10/11/2012
    * @Author Pawel Sprysak
    * @description Getter for Preffered Communication Methods select list
    * @return List<SelectOption>
    */
    public List<SelectOption> getPrefferedCommunicationMethods() {
        return AGS_ST_Utils.getPickListValues(AGS_ST_DisputeManagement_gne__c.Preferred_communication_method_gne__c.getDescribe());
    }

    /** @date 01/22/2013
    * @Author Pawel Sprysak
    * @description Method for searching spends and creating query for execution
    * @return PageReference
    */
    public PageReference searchSpends() {
        actionMessages = '';
        if( String.isBlank(amountFromStr) ) {
            amountFrom = null;
        }
        if( String.isBlank(amountToStr) ) {
            amountTo = null;
        }
        selectQuery = AGS_ST_Utils.getSpendExpenseTransactionIdsQueryByParam(firstName, lastName, amountFrom, amountTo, paymentDateFrom, paymentDateTo, eventCity, mdmId, npi, spendName);
        changePageForSpends(true);
        return null;
    }

    /** @date 01/22/2013
    * @Author Pawel Sprysak
    * @description Method for setting values into Spend Expense Transaction List
    * @param Boolean initValue
    */
    public void changePageForSpends(Boolean initValue) {
        //Check whether is this init value or pagination/sorting value has been changed
        if(initValue || !spendExpenseUtil.compareValues()) {
            setCon = new ApexPages.StandardSetController(AGS_ST_DbUtils.getSpendExpTransactionByQuery(selectQuery + ' LIMIT ' + MAX_ROW_NUM));
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
    }

    /** @date 01/22/2013
    * @Author Pawel Sprysak
    * @description Getter for VF - for Spend Expense Transaction List
    * @return List<AGS_Spend_Expense_Transaction_gne__c>
    */
    public List<AGS_Spend_Expense_Transaction_gne__c> getSpendList() {
        changePageForSpends(false);
        return myList;
    }

    /** @date 01/22/2013
    * @Author Pawel Sprysak
    * @description Method for setting values into create dispute form
    * @return PageReference
    */
    public PageReference setDisputeValues() {
        actionMessages = '';
        internalDispute = '';
        isCmsDispute = false;
        cmsDisputeId = null;
        if(AGS_ST_DbUtils.getDMNumForSpend(transactionId) > 0) {
            isAlreadyCreated = true;
        } else {
            isAlreadyCreated = false;
        }
        spend = AGS_ST_DbUtils.getSpendExpTransById(transactionId);
        //Check that the Spend Expense Transaction report code is correct
        if(spend != null && spend.Report_Code_gne__c == 'XC_MON') {
        	stUser = null;
        	if(spend.Primary_Recipient_MDM_ID_gne__c != null) {
                stUser = AGS_ST_DbUtils.getAgsStUserByMDMId(spend.Primary_Recipient_MDM_ID_gne__c);
        	}
        	if(stUser == null && spend.Secondary_Recipient_MDM_ID_gne__c != null) {
        		stUser = AGS_ST_DbUtils.getAgsStUserByMDMId(spend.Secondary_Recipient_MDM_ID_gne__c);
        	}

            //Check that the Spend Expense Transaction is referenced to registred user
            if(stUser != null) {
                preferredMethod = 'Email';
                preferredValue = stUser.SFDC_User__r.Username;
                defaultEmail = stUser.SFDC_User__r.Username;
            }

            amountSpend = String.valueOf(spend.Allocated_Transaction_Amount_gne__c);
            primaryAmountSpend = String.valueOf(spend.Allocated_Transaction_Amount_gne__c);
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
            if(spend.AGS_expense_products_intercations1__r.size() > 0) {
            	drugValue = spend.AGS_expense_products_intercations1__r.get(0).AGS_Brand__c;
            } else {
            	drugValue = '';
            }
            primaryDrugValue = drugValue;
            paymentDateValue = spend.Event_Date_gne__c;
            explanation = '';
        }
        if(spend != null){
            spendLogicalDelFlag = [SELECT LogicalDeleteFlag_gne__c FROM AGS_Spend_Expense_Transaction_gne__c WHERE Id = :spend.Id limit 1].LogicalDeleteFlag_gne__c;
        }
        return null;
    }

    /** @date 01/22/2013
    * @Author Pawel Sprysak
    * @description Save new dispute action method for button
    * @return PageReference
    */
    public PageReference saveNewDispute() {
        Id disputeId = saveDispute(String.valueOf(transactionId),String.valueOf(paymentDateValue),String.valueOf(amountSpend),formValue,natureValue,drugValue,explanation);
        if(disputeId != null) {
            String disputeName = AGS_ST_DbUtils.getDisputeNameById(disputeId);
            actionMessages = 'New dispute <a href="/apex/AGS_ST_DisputeDetail_gne?id='+disputeId+'" target="_blank">'+disputeName+'</a> has been created<br/>';
        } else {
            actionMessages = 'Dispute has NOT been created.<br/>';
        }

        return null;
    }

    /** @date 01/22/2013
    * @Author Pawel Sprysak
    * @description Method for saving/creating new dispute
    * @param String spendId
    * @param String paymentDate
    * @param String amount
    * @param String formValue
    * @param String natureValue
    * @param String brand
    * @param String otherNote
    * @return Id
    */
    private Id saveDispute(String spendId,String paymentDate,String amount,String formValue,String natureValue,String brand,String otherNote) {
        //Check that the Spend Expense Transaction with this Id exists
        if(spend != null) {
            // Creating AGS_ST_Dispute_List_gne object
            AGS_ST_Dispute_List_gne__c disputeListObj = new AGS_ST_Dispute_List_gne__c();
            Id physicianId = stUser != null ? stUser.SFDC_User__r.Id : UserInfo.getUserId();
            disputeListObj.OwnerId = physicianId;
            disputeListObj.isPrivate_gne__c = false;
            disputeListObj.AGS_Spend_Expense_Transaction_gne__c = spendId;
            disputeListObj.IsCmsDispute_gne__c = isCmsDispute;
            disputeListObj.CmsDisputeId_gne__c = isCmsDispute ? cmsDisputeId : null;
            // Creating AGS_ST_DisputeManagement_gne object
            AGS_ST_DisputeManagement_gne__c disputeManObj = new AGS_ST_DisputeManagement_gne__c();
            disputeManObj.AGS_Spend_Expense_Transaction_gne__c = spendId;
            disputeManObj.Internal_Status_gne__c = 'Submitted';
            if(internalDispute.equals('false')) {
                disputeManObj.isPrivate__c = false;
                disputeListObj.isPrivate_gne__c = false;
            } else {
                disputeManObj.isPrivate__c = true;
                disputeListObj.isPrivate_gne__c = true;
            }
            disputeManObj.Preferred_communication_method_gne__c = preferredMethod;
            if(preferredMethod.equals('Email') && !AGS_ST_Utils.validateEmail(preferredValue)) {
                preferredValue = defaultEmail;
            }
            disputeManObj.Preferred_communication_value_gne__c = preferredValue;
            // Common values
            String spendBrand = '';
            if(spend.AGS_expense_products_intercations1__r.size() > 0) {
                spendBrand = spend.AGS_expense_products_intercations1__r[0].AGS_Brand__c;
            }
            AGS_ST_Utils.fillDLAndDMByStdValues(disputeListObj, disputeManObj, amount, spend.Allocated_Transaction_Amount_gne__c, brand, spendBrand, formValue, spend.Form_Of_Payment_gne__c, natureValue, spend.Nature_Of_Payment_gne__c);
            // Set indicators
            if(!primaryDrugValue.equals(drugValue)) {
                disputeListObj.isBrandDisputed_gne__c = true;
            } else {
                disputeListObj.isBrandDisputed_gne__c = false;
            }
            if(!primaryAmountSpend.equalsIgnoreCase(amountSpend)) {
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
            //if(disputeListObj.isBrandDisputed_gne__c || disputeListObj.isAmountDisputed_gne__c || disputeListObj.isFormDisputed_gne__c || disputeListObj.isNatureDisputed_gne__c) {
                // Insert objects
                insert disputeListObj;
                disputeManObj.Dispute_List_gne__c = disputeListObj.id;
                insert disputeManObj;
                // Add new note for explanation
                if(otherNote != '') {
                    AGS_ST_DbUtils.saveDisputeNotesFromDisputeId(disputeManObj.id, otherNote, 'HCP Dispute');
                }

                return disputeManObj.Id;
            //} else {
            //    return null;
            //} TODO: remove commented sections as requirements was changed
        }
        return null;
    }

    /** @date 24/9/2014
    * @Author Konrad Malinowski
    * @description Method for isCmsDispute checkbox change
    * @return PageReference
    */
    public PageReference isCmsDisputeOnChange() {
        cmsDisputeId = null;
        return null;
    }

    /** @date 24/9/2014
    * @Author Konrad Malinowski
    * @description Method for checking CMS Dispute ID uniqueness
    * @param String cmsDisputeId
    * @return Boolean
    */
    @RemoteAction
    global static Boolean isCmsDisputeIdUnique(String cmsDisputeId) {
        return AGS_ST_DbUtils.isCmsDisputeIdUnique(cmsDisputeId, null);
    }
}