public without sharing class SPCM_ICFR_Log_ListController {

    public string query { get; set; }
    public Boolean IsEditMode { get; set; }
    public Boolean IsMultiEditMode { get; set; }
    public Boolean HasValue { get; set; }
    public Boolean SaveStatus { get; set; }
    public Boolean ShowIcfrErrors { get; set; }
    public Boolean IcfrErrors { get; set; }
    public Boolean ValidationErrors { get; set; }
    public Boolean massEditValidationError { get; set; }
    public List<LogWrapper> LogWrappers { get; set; }
    public List<LogWrapper> ErrorWrappers { get; set; }
    public FilterWrapper Filters { get; set; }
    public List<ProductWrapper> AllProducts { get; set; }
    public string SelectedView { get; set; }
    public List<SelectOption> Views { get; set; }
    public string UserType { get; set; }
    public integer PageNum { get; set; }
    public integer RecordsPerPage { get; set; }
    public integer ResSize { get; set; }
    public integer ErrorsPresent { get; set; }
    public integer TotalSelected { get; set; }
    public Boolean ShowProductColumn { get; set; }
    public string OrderDirection { get; set; }
    public String currentCmsEnv { get; set; }
    public String currentBackendStatus { get; set; }
    public Integer currentSaveBackendStatus { get; set; }
    public Integer currentErrorBackendStatus { get; set; }
    public String icfrInput { get; set; }
    public String icfrOutput { get; set; }
    public Set<String> icfrEditRecords { get; set; }
    public Map<Id, LogWrapper> AllPreviousLogWrappersMap { get; set; }
    public Map<Id, LogWrapper> PreviousLogWrappersMap { get; set; }
    public List<LogWrapper> UniqueEditLogWrapperList { get; set; }
    public Set<Id> UniqueEditedIcfrLogsIds { get; set; }
    public List<SPCM_ICFR_Log__c> AllSearchedIcfrLogs { get; set; }
    public List<SPCM_ICFR_Log__c> IcfrToShow { get; set; }
    String[] statuses = new String[]{};


    private final string ASCENDING = ' ASC';
    private final string DESCENDING = ' DESC';
    private boolean queryRebuilt = false;
    private boolean pageSwitched = false;
    private string ICFRLogPrefix;
    private string previousOrder;


    /***
    * @author Wojciech Jaskula
    *
    * @Description: Constructor, creates FilterWrapper to set default ordering and default Params for ICFR Log List
    */
    public SPCM_ICFR_Log_ListController() {
        PreviousLogWrappersMap = new Map<Id, LogWrapper>();
        //SPCM_ICFRLogUtils.actionFromController = true;
        SPCM_ICFRLogUtils.setActionFromController(true);
        IcfrToShow = new List<SPCM_ICFR_Log__c>();
        AllSearchedIcfrLogs = new List<SPCM_ICFR_Log__c>();
        UniqueEditLogWrapperList = new List<LogWrapper>();
        ErrorWrappers = new List<LogWrapper>();
        AllPreviousLogWrappersMap = new Map<Id, LogWrapper>();
        UniqueEditedIcfrLogsIds = new Set<Id>();
        Filters = new FilterWrapper();
        Filters.StatusFilter = 'New, Pending Analyst, Pending Level 1 Approval, Pending Level 2 Approval, Approved by Level 1, Approved By Level 2';
        ICFRLogPrefix = SPCM_ICFR_Log__c.sObjectType.getDescribe().getKeyPrefix();
        AllProducts = fetchProducts();
        UserType = getUserType();
        Order = 'name';
        previousOrder = 'name';
        OrderDirection = DESCENDING;
        PageNum = 1;
        RecordsPerPage = 100;
        HasValue = false;
        IsEditMode = false;
        IsMultiEditMode = false;
        IcfrErrors = false;
        ShowIcfrErrors = false;
        SaveStatus = false;
        ValidationErrors = false;
        massEditValidationError = false;
        currentCmsEnv = this.prepareGetCmsUrl();
        ErrorsPresent = 0;
        TotalSelected = 0;
    }
    /***
    * @author Wojciech Jaskula
    *
    * @Description: Method to set and get ICFR Log list ordering
    */
    public string Order {
        get;
        set {
            Order = value;
            if (Order == previousOrder){
                OrderDirection = OrderDirection == DESCENDING ? ASCENDING : DESCENDING;
			} else {
                OrderDirection = ASCENDING;
			}
            previousOrder = value;
        }
    }

    public string CurrentStatus {
        get {
            CurrentStatus = currentBackendStatus;
            return CurrentStatus;
        }
        set;
    }

    public Integer SuccessSavedRecords {
        get {
            SuccessSavedRecords = currentSaveBackendStatus;
            return SuccessSavedRecords;
        }
        set;
    }

    public Integer ErrorSavedRecords {
        get {
            ErrorSavedRecords = currentErrorBackendStatus;
            return ErrorSavedRecords;
        }
        set;
    }


    /***
    * @author Wojciech Jaskula
    *
    * @Description: Method getLogs() return logs of ICFR Log
    */
    public List<LogWrapper> GetLogs() {
        Set<Id> previousChecked = new Set<Id>();
        List<LogWrapper> newLogWrappers = new List<LogWrapper>();
        List<LogWrapper> valLogWrappers = new List<LogWrapper>();
        if (ShowIcfrErrors) {
            return ErrorWrappers;
        }
        for (LogWrapper singleLogWrapper : UniqueEditLogWrapperList) {
            if (singleLogWrapper.Checked) {
                previousChecked.add(singleLogWrapper.ICFRLog.id);
            }
        }
        LogWrappers = new List<logWrapper>();
        for (SPCM_ICFR_Log__c l : (List<SPCM_ICFR_Log__c>) ICFRLogSet.getRecords()) {
            LogWrappers.add(new LogWrapper(l));
        }
        if (LogWrappers != null && !queryRebuilt && !isEditMode) {
            return LogWrappers;
        }
        for (LogWrapper singleLogWrapper : LogWrappers) {
            if (previousChecked.contains(singleLogWrapper.ICFRLog.id)) {
                singleLogWrapper.Checked = true;
                if (IsMultiEditMode) {
                    singleLogWrapper.EditMode = true;
                } else {
                    singleLogWrapper.EditMode = false;
                }
                newLogWrappers.add(singleLogWrapper);
            } else {
                newLogWrappers.add(singleLogWrapper);
            }
        }
        return newLogWrappers;
    }

    /***
    * @author Wojciech Jaskula
    *
    * @Description: Method returns set of ICFR Log
    */
    public ApexPages.StandardSetController ICFRLogSet {
        get {
            if ((ICFRLogSet == null) && !IsEditMode) {
                pageSwitched = false;
                createQuery();
            }
            return ICFRLogSet;
        }
        set;
    }

    /***
    * @author Wojciech Jaskula
    *
    * @Description: Method is used to rebuild Query to retrieve more records (after filter change or next page click)
    */
    public PageReference RebuildQueryAction() {
        if (!isEditMode) {
            Cancel();
        }
        //SaveStatus = false;
        HasValue = false;
        ValidationErrors = false;
        massEditValidationError = false;
        createQuery();
        return null;
    }

    public PageReference RebuildQueryForFilterAction() {
        PageNum = 1;
        TotalSelected = 0;
        return RebuildQueryAction();
    }

    /***
    * @author Wojciech Jaskula
    *
    * @Description: Method is used to reset Icfr Log Page Filters 
    */
    public PageReference ClearFilters() {
        //@bartosz brodzinski clear more filters
        PageNum = 1;
        Filters.AgreementTypeFilter = '';
        Filters.RecordIdFilter = '';
        Filters.CopsCMFilter = '';
        Filters.StatusFilter = 'Not Closed';
        Filters.AccountFilter = '';
        Filters.AccountFilter = '';
        Filters.ContractIdFilter = '';
        Filters.CMSRecordIdFilter = '';
        Filters.EffectiveDateFilterFrom = null;
        Filters.modifiedDate = null;
        Filters.EffectiveDateFilterTo = null;
        Filters.ExpectedActivationDateFilterFrom = null;
        Filters.ExpectedActivationDateFilterTo = null;
        Filters.ExternalContractIdFilter = null;
        Filters.MccContractManager = '';
        Filters.EditedIcfrLogs = null;
        SaveStatus = false;
        TotalSelected = 0;
        ErrorsPresent = 0;
        for ( LogWrapper l : UniqueEditLogWrapperList ) {
            l.checked = false;
        }
        /***
        for(ProductWrapper pw : AllProducts)
        {
            pw.Selected = false;
        }
        */

        Cancel();
        createQuery();
        return null;
    }
    /***
    * @author Wojciech Jaskula
    *
    * @Description: Method is used to change Ordering by Name in Icfr Log Page 
    */
    public PageReference OrderByNameAction() {
        Cancel();
        Order = 'name';
        createQuery();
        return null;
    }
    /***
    * @author Wojciech Jaskula
    *
    * @Description: Method is used to change Ordering by Account in Icfr Log Page 
    */
    public PageReference OrderByAccountAction() {
        Cancel();
        Order = 'Account__c';
        createQuery();
        return null;
    }
    
    /***
    * @author Wojciech Jaskula
    *
    * @Description: Method is used to validate and Initiate CUT Process
    */
    public PageReference InitiateCUTProcess() {
        Cancel();
        //validation for C-Ops contract manager value. Similar one is performed in trigger.
        //Redundancy is coused by need to perform check before creating CUT Process record.
        Set<Id> agreementTypesSet = new Set<Id>();
        Boolean hasErrors = false;

        for (LogWrapper logRow : LogWrappers) {

            if (logRow.Checked != null && logRow.Checked == true) {

                agreementTypesSet.add(logRow.ICFRLog.Agreement_Type__c);

                if (logRow.ICFRLog.Status__c == 'Closed') {
                    logRow.ICFRLog.addError(logRow.ICFRLog.name + ': You cannot initiate closed ICFR log.');
                    hasErrors = true;
                }

                if (logRow.ICFRLog.C_Ops_Contract_Manager__c == null) {
                    logRow.ICFRLog.addError(logRow.ICFRLog.name + ': Please enter C-Ops Contract Manager value.');
                    hasErrors = true;
                }

            }
        }

        if (agreementTypesSet.size() > 1) {
            if (!LogWrappers.isEmpty()) {
                LogWrappers[0].ICFRLog.addError('Please select ICFR Logs with same Agreement Type to initiate.');
                hasErrors = true;
            }
        }

        if (hasErrors) {
            return null;
        }

        //create CUT Process record and set all selected Logs CUTId field to new CUT id.
        //TODO: Simple setController.save() call doesn't work here (CUT Id and status are not updated). It works only every second time.
        //after few hours of investigation no error source was found and simple update is used as a temp workaround.
        Id CUTId = CreateCUTRecord();
        List<id> logsIdToUpdate = new List<id>();
        for (LogWrapper logRow : LogWrappers) {
            if (logRow.Checked != null && logRow.Checked == true) {
                logsIdToUpdate.add(logRow.ICFRLog.id);
            }
        }
        List<SPCM_ICFR_Log__c> logsToUpdate = [select id, CUT_Approval_Id__c, CUT_Approver_Name__c, Status__c from SPCM_ICFR_Log__c where id in :logsIdToUpdate];
        for (SPCM_ICFR_Log__c l : logsToUpdate) {
            l.CUT_Approval_Id__c = CUTId;
            l.CUT_Approver_Name__c = null;
            l.Status__c = 'Pending Analyst';
        }
        try {
            update logsToUpdate;
            RebuildQueryAction();
        }
        // dummy catch to prevent redirect and to let the pageMessage show up in case of validation error
        catch (Exception ex) {
            RebuildQueryAction();
            return null;
        }

        return new PageReference('/' + CUTId + '/e?retURL=' + CUTId);
    }
    /***
    * @author Wojciech Jaskula
    *
    * @Description: Method is used to toggle Icfr Log to Edit Mode
    */
    public PageReference ToggleEditMode() {
        SaveStatus = false;
        HasValue = true;
        PageNum = 1;
        currentBackendStatus = 'Edit Mode';
        IsMultiEditMode = true;
        icfrToShow.clear();
        getSelectedEditIcfr();
        Boolean editedQuery = true;
        isEditMode = !isEditMode;
        Set<Id> uniqueIds = new Set<Id>();
        Integer countLogsToEdit = 0;
        for (LogWrapper logRow : UniqueEditLogWrapperList) {
            if (isEditMode && logRow.Checked != null && logRow.Checked == true) {
                logRow.EditMode = true;
                countLogsToEdit++;
                if ((logRow.ICFRLog.Status__c == 'Closed' || logRow.ICFRLog.Status__c == 'In Process') && UserType == 'COPS') {
                    logRow.ICFRLog.addError(logRow.ICFRLog.name + ': ICFR Status is In Process / Closed. Unable to edit.');
                    logRow.EditMode = false;
                    logRow.Checked = false;
                    countLogsToEdit--;
                }
                if (logRow.ICFRLog.Status__c != 'In Process' && UserType == 'MCC') {
                    logRow.ICFRLog.addError(logRow.ICFRLog.name + ': ICFR Status is not In Process. Unable to edit.');
                    logRow.EditMode = false;
                    logRow.Checked = false;
                    countLogsToEdit--;
                }
                if (uniqueIds.add(logRow.ICFRLog.id)) {
                    UniqueEditedIcfrLogsIds.add(logRow.ICFRLog.Id);
                    icfrToShow.add(logRow.ICFRLog);
                }
            } else {
                logRow.EditMode = false;
            }
        }
        if (isEditMode == true) {
            createQuery();
        }

        if (isEditMode && countLogsToEdit == 0) {
            isEditMode = !isEditMode;
        }

        if (!isEditMode) {
            //TODO: Simple setController.save() call doesn't work always here (seems not deterministic).
            //after few hours of investigation no error source was found and simple update is used as a temp workaround.
            List<SPCM_ICFR_Log__c> logsToUpdate = new List<SPCM_ICFR_Log__c>();
            for (LogWrapper logRow : LogWrappers) {
                if (logRow.Checked != null && logRow.Checked == true) {
                    logsToUpdate.add(logRow.ICFRLog);
                }
            }
            try {

                update logsToUpdate;
                isEditMode = false;
                RebuildQueryAction();
            }
            // dummy catch to prevent redirect and to let the pageMessage show up in case of validation error
            catch (Exception ex) {
                isEditMode = false;
                RebuildQueryAction();
            }
        }
        return null;
    }

    public void getSelectedEditIcfr() {
        UniqueEditLogWrapperList.clear();
        for (LogWrapper logRow : LogWrappers) {
            if (logRow.Checked != null && logRow.Checked == true) {
                AllPreviousLogWrappersMap.put(logRow.ICFRLog.Id, logRow);
            } else {
                if (logRow.Checked == false) {
                    if (AllPreviousLogWrappersMap.containsKey(logRow.ICFRLog.Id)) {
                        AllPreviousLogWrappersMap.remove(logRow.ICFRLog.Id);
                    }
                }
            }

        }
        UniqueEditLogWrapperList.addAll(AllPreviousLogWrappersMap.values());
    }


    public PageReference saveSearchedRecordsAction() {
        getSelectedEditIcfr();
        TotalSelected = 0;
        SPCM_ICFRLogUtils.setActionFromController(true);
        String status = ApexPages.currentPage().getParameters().get('icfrStatus');
        String copsContractManager = ApexPages.currentPage().getParameters().get('copsContractManager');
        String carsActivationDate = ApexPages.currentPage().getParameters().get('carsActivationDate');
        String notes = ApexPages.currentPage().getParameters().get('icfrNotes');
        String fromsearch = ApexPages.currentPage().getParameters().get('searchfrom');
        String replaceNotes = ApexPages.currentPage().getParameters().get('replaceNotes');
        String editNotes = ApexPages.currentPage().getParameters().get('editNotes');
        String editCarsActivationDate = ApexPages.currentPage().getParameters().get('editCopsContractManager');
        String editCopsContactManager = ApexPages.currentPage().getParameters().get('editCarsActivationDate');
        List<User> copsContractManagertoSave = [SELECT Id FROM User Where Name Like :copsContractManager Limit 1];
        Boolean wasSingleEditModed = IsMultiEditMode;
        IsMultiEditMode = false;
        List<SPCM_ICFR_Log__c> logsToUpdate = new List<SPCM_ICFR_Log__c>();
        Set<Id> uniquelogs = new Set<Id>();
        PreviousLogWrappersMap.clear();
        if (!IcfrErrors) {
            if (fromsearch != null && Boolean.valueOf(fromsearch) == true) {
                for (SPCM_ICFR_Log__c logRow : AllSearchedIcfrLogs) {
                    PreviousLogWrappersMap.put(logRow.Id, new LogWrapper(logRow));
                }
            } else {
                for (LogWrapper logRow : UniqueEditLogWrapperList) {
                    PreviousLogWrappersMap.put(logRow.ICFRLog.Id, logRow);
                }
            }
            for (logWrapper newLogRow : PreviousLogWrappersMap.values()) {
                if (status != null && !String.isBlank(status)) {
                    newLogRow.ICFRLog.Status__c = status;
                }
                if (editCopsContactManager == 'true') {
                    if (copsContractManager != null && !String.isBlank(copsContractManager) && !copsContractManagertoSave.isEmpty()) {
                        newLogRow.ICFRLog.C_Ops_Contract_Manager__c = copsContractManagertoSave.get(0).Id;
                    } else {
                        newLogRow.ICFRLog.C_Ops_Contract_Manager__c = null;
                    }
                }

                if (editCarsActivationDate == 'true') {
                    if (carsActivationDate != null && !String.isBlank(carsActivationDate)) {
                        newLogRow.ICFRLog.CARS_Activation_Date__c = Date.parse(carsActivationDate);
                    } else {
                        newLogRow.ICFRLog.CARS_Activation_Date__c = null;
                    }
                }

                if (editNotes == 'true') {
                    if (replaceNotes == 'true') {
                        newLogRow.ICFRLog.Notes__c = notes;
                    } else if (!String.isBlank(notes) && replaceNotes == 'false') {
                        if (String.isBlank(newLogRow.ICFRLog.Notes__c)) {
                            newLogRow.ICFRLog.Notes__c = notes;
                        } else {
                            newLogRow.ICFRLog.Notes__c += ' * ' + notes;
                        }
                    }
                }

                logsToUpdate.add(newLogRow.ICFRLog);
                uniquelogs.add(newLogRow.ICFRLog.Id);
            }
        } else {
            for (LogWrapper logRow : ErrorWrappers) {
                logsToUpdate.add(logRow.ICFRLog);
            }
        }
        List<logWrapper> tempLogWrappers = new List<LogWrapper>();
        List<logWrapper> newLogWraps = new List<LogWrapper>();
        Map<Id, String> errorList = new Map<Id, String>();
        String currentField = '';
        Integer savedrecords = 0;
        try {
            Database.SaveResult[] res = Database.update(logsToUpdate, false);
            for (Integer i = 0; i < logsToUpdate.size(); i++) {
                Database.SaveResult s = res[i];
                SPCM_ICFR_Log__c origRecord = logsToUpdate[i];

                if (!s.isSuccess()) {
                    tempLogWrappers.add(new LogWrapper(origRecord));
                    for (Database.Error err : s.getErrors()) {
                        if (!err.getFields().isEmpty()) {
                            if (err.getFields()[0] == 'Customer__c') {
                                currentField = ' Customer Type ';
                            }
                            if (err.getFields()[0] == 'Agreement_Type__c') {
                                currentField = ' Agreement Type';
                            }
                        }
                        errorList.put(origRecord.Id, currentField + '' + err.getMessage());
                    }
                } else {
                    savedrecords++;
                }
            }
            currentSaveBackendStatus = savedrecords;
            if (errorList.isEmpty()) {
                ShowIcfrErrors = false;
                IsEditMode = false;
                HasValue = true;
                ValidationErrors = false;
                massEditValidationError = false;
                SaveStatus = true;
                AllPreviousLogWrappersMap.clear();
                UniqueEditLogWrapperList.clear();
                RebuildQueryAction();
            } else {
                HasValue = true;
                LogWrappers.clear();
                ShowIcfrErrors = true;
                ValidationErrors = true;
                if (wasSingleEditModed) {
                    IsMultiEditMode = true;
                }
                SaveStatus = false;
                isEditMode = true;
                ErrorWrappers.clear();
                currentErrorBackendStatus = tempLogWrappers.size();
                for (LogWrapper singleWrapper : tempLogWrappers) {
                    singleWrapper.ValidationInfo = errorList.get(singleWrapper.ICFRLog.id);
                    singleWrapper.Checked = true;
                    singleWrapper.EditMode = true;
                    newLogWraps.add(singleWrapper);
                }
                ErrorWrappers.addAll(newLogWraps);
                if (!IsMultiEditMode) {
                    massEditValidationError = true;
                }
                currentBackendStatus = 'Edit Mode - Validation Errors';
            }
        } catch (Exception ex) {
            System.debug(Logginglevel.ERROR, ex.getMessage());
        }
        return null;
    }


    public PageReference ToggleMultiEditMode() {
        SaveStatus = false;
        HasValue = true;
        PageNum = 1;
        currentBackendStatus = 'Mass Edit Mode';
        isMultiEditMode = false;
        icfrToShow.clear();
        getSelectedEditIcfr();
        Boolean editedQuery = true;
        isEditMode = !isEditMode;
        Set<Id> uniqueIds = new Set<Id>();
        Integer countLogsToEdit = 0;

        for (LogWrapper logRow : UniqueEditLogWrapperList) {
            logRow.HiddenEditMode = true;
            if (isEditMode && logRow.Checked != null && logRow.Checked == true) {
                logRow.EditMode = true;
                countLogsToEdit++;
                if ((logRow.ICFRLog.Status__c == 'Closed' || logRow.ICFRLog.Status__c == 'In Process') && UserType == 'COPS') {
                    logRow.ICFRLog.addError(logRow.ICFRLog.name + ': ICFR Status is In Process / Closed. Unable to edit.');
                    logRow.EditMode = false;
                    logRow.Checked = false;
                    isEditMode = false;
                    countLogsToEdit--;
                }
                if (logRow.ICFRLog.Status__c != 'In Process' && UserType == 'MCC') {
                    logRow.ICFRLog.addError(logRow.ICFRLog.name + ': ICFR Status is not In Process. Unable to edit.');
                    logRow.EditMode = false;
                    logRow.Checked = false;
                    isEditMode = false;
                    countLogsToEdit--;
                }
                if (uniqueIds.add(logRow.ICFRLog.id)) {
                    UniqueEditedIcfrLogsIds.add(logRow.ICFRLog.Id);
                    icfrToShow.add(logRow.ICFRLog);
                }
            } else {
                logRow.EditMode = false;
            }
        }
        if (isEditMode == true) {
            createQuery();
        }
        return null;
    }

    /***
    * @author Wojciech Jaskula
    *
    * @Description: Method is used to Cancel Edit Mode of Icfr Log Page
    */
    public PageReference CancelEdit() {
        PageNum = 1;
        ErrorsPresent = 0;
        Cancel();
        isEditMode = false;
        SaveStatus = false;
        HasValue = false;
        ShowIcfrErrors = false;
        ValidationErrors = false;
        massEditValidationError = false;
        IsMultiEditMode = false;
        RebuildQueryAction();
        AllPreviousLogWrappersMap.clear();
        UniqueEditLogWrapperList.clear();
        return null;
    }
    /***
    * @author Wojciech Jaskula
    *
    * @Description: Method is helper to CancelEdit() Method 
    */
    public PageReference Cancel() {
        for (LogWrapper logRow : LogWrappers) {
            logRow.EditMode = false;
        }
        isEditMode = false;
        return null;
    }
    /***
    * @author Wojciech Jaskula
    *
    * @Description: Method is helper to export Icfr Log to MS Excel Format 
    */
    public PageReference ExportToExcel() {
        Cancel();
        return Page.SPCM_ICFR_Log_Download;
    }
    /***
    * @author Wojciech Jaskula
    *
    * @Description: Method is helper to initiate new Icfr Log 
    */
    public PageReference NewLog() {
        return new PageReference('/' + ICFRLogPrefix + '/e?retURL=/apex/SPCM_ICFR_Log_List');
    }
    /***
    * @author Wojciech Jaskula
    *
    * @Description: Method is helper to sort ICFR Logs
    */
    public PageReference Sort() {
        RebuildQueryAction();
		if ( !isEditMode ) {
            for ( LogWrapper l : UniqueEditLogWrapperList ) {
                l.checked = false;
            }
        }
        return null;
    }

    @RemoteAction
    public static String FetchCopsId(String copsName) {
        try {
            List<User> result = [SELECT Id FROM User WHERE Name = :copsName];
            if ( result.size() == 1 ) {
                return result.get(0).Id;
            }
        } catch (Exception e) {}

        return null;
    }

    /***
    * @author Wojciech Jaskula
    *
    * @Description: Main Method , Creates Query to retrieve ICFR Logs
    */
    private void createQuery() {
        AllSearchedIcfrLogs.clear();
        List<id> selectedProductsIds = GetSelectedProducts();
        Set<id> logsWithSelectedProducts = new Set<id>();
        Set<id> selectedIds = new Set<id>();
        for (SPCM_ICFR_Log__c singleIcfr : IcfrToShow) {
            selectedIds.add(singleIcfr.Id);
        }
        Boolean queryProducts = false;
        //show Products column only if any product is selected
        showProductColumn = selectedProductsIds.size() > 0;
        // if no product or every product is selected, skip querying by products.
        if (selectedProductsIds.size() > 0 && selectedProductsIds.size() != AllProducts.size()) {
            logsWithSelectedProducts = QueryLogsWithSelectedProducts(selectedProductsIds);
            queryProducts = true;
        }

        query = 'SELECT id, name, Account__c, Agreement_Type__c, Agreement_Type__r.Name, Amendment_Number__c, CARS_Activation_Date__c, Chargeback_Component__c, Contract_Activation_Timeline__c, ' +
                ' Contract_ID__c, C_Ops_Contract_Manager__c, C_Ops_Contract_Manager__r.Name, Created_Date__c, Created_date_to_Contract_Start_Date_Days__c, Created_Date_to_Expected_Activation_Days__c, Customer__c, Customer__r.Name, ' +
                ' CUT_Approval_Id__c, CUT_Approver_Name__c, Days_Created_after_Email_Notice__c, Document_Type__c, Effective_Date__c, External_CMS_Unique_ID__c, External_Contract_Id__c, notes__c,  ' +
                ' Effective_Date_to_Activation_Date_Days__c, Effective_to_Expected_Activation_Days__c, Email_Notice_Date__c, Expected_Activation_Date__c, product_list__c,' +
                ' Impacts_Revenue_Recognition__c, MCC_Contract_Manager__c, MCC_Contract_Manager__r.Name, MCC_Manager__c, MCC_Manager__r.Name, Retro_Effective_Dated__c, Status__c , External_CMS_URL__c,  CUT_Approval_Id__r.Approval_Status__c, ' +
                ' Amended_Contracts__c, CARS_Key_Legacy__c, CARS_Version__c, Reviewer__c ' +
                ' FROM SPCM_ICFR_Log__c where id != null '
                + (isEditMode ? ' AND id in :selectedIds ' : '')
                + (queryProducts ? ' AND id in :logsWithSelectedProducts ' : '')
                + BuildQueryCondition()
                + ' order by ' + Order + orderDirection
                + ' LIMIT 700';

        try {
            AllSearchedIcfrLogs = Database.query(query);
            ICFRLogSet = new ApexPages.StandardSetController(AllSearchedIcfrLogs);
            ICFRLogSet.setPageSize(RecordsPerPage);
            ICFRLogSet.setPageNumber(PageNum);
            queryRebuilt = true;
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Query time limit exceeded. Please reduce number of filters and try again.'));
        }

    }

    /***
    * @author Wojciech Jaskula
    *
    * @Description: Main Method Helper , Adds proper values to filter
    */
    private string BuildQueryCondition() {

        //Filters.StatusFilter = '';
        integer iterator = 0;
        for (String singleStatus : getStatuses()) {
            if (iterator == 0) {
                Filters.StatusFilter = '';
            }
            Filters.StatusFilter += (Filters.StatusFilter == '' ? '' : ',') + singleStatus;
            iterator++;
        }

        string filter = '';

        if (string.isNotBlank(Filters.StatusFilter)) {
            //exception due to business requirement
            if (getStringifyValue(Filters.StatusFilter) == 'Not In Process')
                filter += ' AND Status__c != \'In Process\''; else if (getStringifyValue(Filters.StatusFilter.trim()) == 'Not Closed')
                filter += ' AND Status__c != \'Closed\''; else if (getStringifyValue(Filters.StatusFilter.trim()) == 'Pending')
                filter += ' AND Status__c LIKE \'Pending%\''; else
                    filter += 'AND (Status__c LIKE ' + processOrStatusFilter(Filters.StatusFilter) + ')';
        }
        if (string.isNotBlank(Filters.RecordIdFilter))
            filter += ' AND Name like' + '\'%' + Filters.RecordIdFilter + '%\' ';
        if (string.isNotBlank(Filters.AgreementTypeFilter))
            filter += ' AND Agreement_Type__r.name like' + '\'%' + Filters.AgreementTypeFilter + '%\' ';
        if (string.isNotBlank(Filters.CopsCMFilter))
            filter += ' AND C_Ops_Contract_Manager__r.name like' + '\'%' + Filters.CopsCMFilter + '%\' ';
        if (string.isNotBlank(Filters.AccountFilter))
            filter += ' AND Account__c like' + '\'%' + Filters.AccountFilter + '%\' ';
        if (string.isNotBlank(Filters.ContractIdFilter))
            filter += ' AND Contract_ID__c =' + '\'' + Filters.ContractIdFilter + '\' ';
        if (String.isNotBlank(Filters.CMSRecordIdFilter)) {
            filter += ' AND External_CMS_Unique_ID__c =' + '\'' + Filters.CMSRecordIdFilter + '\' ';
        }
        if (string.isNotBlank(Filters.ExternalContractIdFilter))
            filter += ' AND External_Contract_Id__c =' + '\'' + Filters.ExternalContractIdFilter + '\' ';
        //effective date filter
        if (Filters.EffectiveDateFilterFrom != null)
            filter += ' AND Effective_Date__c >= ' + string.valueOf(Filters.EffectiveDateFilterFrom);
        if (Filters.EffectiveDateFilterTo != null)
            filter += ' AND Effective_Date__c <= ' + string.valueOf(Filters.EffectiveDateFilterTo);

        //Expected Activation Date Filter
        if (Filters.ExpectedActivationDateFilterFrom != null)
            filter += ' AND Expected_Activation_Date__c >= ' + string.valueOf(Filters.ExpectedActivationDateFilterFrom);
        if (Filters.ExpectedActivationDateFilterTo != null)
            filter += ' AND Expected_Activation_Date__c <= ' + string.valueOf(Filters.ExpectedActivationDateFilterTo);

        //Mcc Contract Manager Filter
        // Author Wojciech Jaskuła
        if (Filters.MccContractManager != null) {
            filter += ' AND MCC_Contract_Manager__r.name like' + '\'%' + Filters.MccContractManager + '%\' ';
        }

        // modified date filter
        if (Filters.modifiedDate != null) {
            filter += ' AND DAY_ONLY(LastModifiedDate) = ' + String.valueOf(Filters.modifiedDate);
        }

        return filter;
    }
    /***
    * @author Wojciech Jaskula
    *
    * @Description: Method used to process Filter , splits all filter values to list and returns as JSON
    */
    private string processStatusFilter(string filter) {
        List<string> filters = filter.split(',');
        List<string> resLst = new List<string>();
        for (string f : filters) {
            resLst.add('\'' + f.trim() + '\'');
        }
        return string.join(resLst, ',');
    }
    /***
    * @author Wojciech Jaskula
    *
    * @Description: Method used to process Filter , splits with  sql 'OR' all filter values to list and returns as JSON
    */
    private string processOrStatusFilter(string filter) {
        List<string> filters = filter.split(',');
        List<string> resLst = new List<string>();
        String orQuery;
        Integer count = 0;
        for (string f : filters) {

            if (count == 0) {
                orQuery += '\'%' + f.trim() + '%\' ';
            } else {
                orQuery += '' + ' OR Status__c LIKE ' + '\'%' + f.trim() + '%\' ';
            }
            count++;
        }
        orQuery = orQuery.replace('null', '');
        orQuery = orQuery.replaceAll('\\[|\\]', '');
        return orQuery;
    }


    private string getStringifyValue(string filter) {
        return filter.replaceAll('\\[|\\]', '');
    }


    /***
    * @author Wojciech Jaskula
    *
    * @Description: Method returns ICFR Logs for Selected Producs
    */
    private Set<id> QueryLogsWithSelectedProducts(List<id> selectedProductsIds) {
        Set<id> logsWithSelectedProducts = new Set<id>();
        for (SPCM_Log_To_Product_Junction__c junction : [select ICFR_Log__c from SPCM_Log_To_Product_Junction__c where SPCM_Product__c in :selectedProductsIds LIMIT 35000]) {
            LogsWithSelectedProducts.add(junction.ICFR_Log__c);
        }
        return LogsWithSelectedProducts;
    }
    /***
    * @author Wojciech Jaskula
    *
    * @Description: Helper Method  for QueryLogsWithSelectedProducts ,  returns Ids of selected Products from ICFR Log
    */
    private List<id> GetSelectedProducts() {
        List<id> selectedProductsIds = new List<id>();
        Set<id> LogsWithSelectedProducts = new Set<id>();
        for (ProductWrapper pw : AllProducts) {
            if (pw.Selected)
                selectedProductsIds.add(pw.Product.id);
        }
        return selectedProductsIds;
    }
    /***
    * @author Wojciech Jaskula
    *
    * @Description: Method creates new CUT Record
    */
    private Id CreateCUTRecord() {
        SPCM_CARS_Contract_Summary_Form__c cut = new SPCM_CARS_Contract_Summary_Form__c();
        cut.Approval_Status__c = 'New';
        cut.Initiated_By__c = UserInfo.getUserId();
        cut.Contract_Key__c = null;
        insert cut;
        return cut.id;
    }
    /***
    * @author Wojciech Jaskula
    *
    * @Description: Method fetches products to ProductWrapper to be used in other methods
    */
    private List<ProductWrapper> fetchProducts() {
        List<ProductWrapper> w = new List<ProductWrapper>();
        List<SPCM_Product__c> prods = [select id, name from SPCM_Product__c];
        for (SPCM_Product__c p : prods) {
            w.add(new ProductWrapper(p));
        }
        w.sort();
        return w;
    }
    /***
    * @author Wojciech Jaskula
    *
    * @Description: Method returns current User Type for Icfr Log to give proper permissions
    */
    private string getUserType() {
        List<string> adminPermissionSets = new List<string>{
                'SPCM_EC_SFDC_IT_Administrator', 'SPCM_EC_IT_Support', 'SPCM_Systems_Administrator'
        };
        List<string> mccPermissionSets = new List<string>{
                'SPCM_MCC_Contract_Manager', 'SPCM_MCC_Manager'
        };
        List<string> copsPermissionSets = new List<string>{
                'SPCM_C_Ops_Executive', 'SPCM_C_Ops_Contract_Manager', 'SPCM_C_Ops_Group_Manager'
        };
        PermissionSetAssignment permSet = [
                SELECT PermissionSetId, PermissionSet.Name
                FROM PermissionSetAssignment
                WHERE AssigneeId = :UserInfo.getUserId() AND
                (PermissionSet.Name in :adminPermissionSets OR
                PermissionSet.Name in :mccPermissionSets OR
                PermissionSet.Name in :copsPermissionSets)
                limit 1
        ][0];

        for (string ps : adminPermissionSets)
            if (ps == permSet.permissionSet.Name) return 'ADMIN';
        for (string ps : mccPermissionSets)
            if (ps == permSet.permissionSet.Name) return 'MCC';
        for (string ps : copsPermissionSets)
            if (ps == permSet.permissionSet.Name) return 'COPS';
        throw new SecurityException('Insufficient privileges.');
    }
    /***
    * @author Wojciech Jaskula
    *
    * @Description: Method returns current url of SPCM_ICFR_Log_Settings custom object , to set current cms Id in ICFR Log
    */
    private string prepareGetCmsUrl() {
        String metaurl = [Select CMS_Environment_Url__c FROM SPCM_ICFR_Log_Settings__c][0].CMS_Environment_Url__c;
        return metaurl;
    }


    // ------------Pagination methods
    /***
    * @author Wojciech Jaskula
    *
    * @Description: Pagination Method , checks if there is Next Page of Icfr Log
    */
    public Boolean hasNext {
        get {
            return ICFRLogSet.getHasNext();
        }
        set;
    }
    /***
    * @author Wojciech Jaskula
    *
    * @Description: Pagination Method , checks if there is Previous Page of Icfr Log
    */
    public Boolean hasPrevious {
        get {
            return ICFRLogSet.getHasPrevious();
        }
        set;
    }
    /***
    * @author Wojciech Jaskula
    *
    * @Description: Pagination Method , returns current Icfr Log page Number
    */
    public Integer pageNumber {
        get {
            return ICFRLogSet.getPageNumber();
        }
        set;
    }
    /***
    * @author Wojciech Jaskula
    *
    * @Description: Pagination Method , returns size of Pages in Icfr Log 
    */

    public Integer resultSize {
        get {
            return ICFRLogSet.getResultSize();
        }
        set;
    }


    public void refreshResults() {
        RebuildQueryAction();
    }


    public void previous() {
        getSelectedEditIcfr();
        pageSwitched = true;
        PageNum--;
        RebuildQueryAction();
    }
    /***
    * @author Wojciech Jaskula
    *
    * @Description: Pagination Method , returns 0next Page of Icfr Log
    */
    public void next() {
        getSelectedEditIcfr();
        pageSwitched = true;
        PageNum++;
        RebuildQueryAction();
    }
    /***
    * @author Wojciech Jaskula
    *
    * @Description: Wrapper Method , used to collect Logs 
    */
    public class LogWrapper {
        public LogWrapper(SPCM_ICFR_Log__c log) {
            this.ICFRLog = log;
            Checked = false;
            EditMode = false;
            HiddenEditMode = false;
            ValidationInfo = '';
        }
        public SPCM_ICFR_Log__c ICFRLog { get; set; }
        public Boolean Checked { get; set; }
        public Boolean EditMode { get; set; }
        public Boolean HiddenEditMode { get; set; }
        public String ValidationInfo { get; set; }
    }
    /*****
    * @author Wojciech Jaskula
    *
    * @Description: Wrapper Method , used to collect Filters 
    */
    public class FilterWrapper {
        public String AgreementTypeFilter { get; set; }
        public String RecordIdFilter { get; set; }
        public String CopsCMFilter { get; set; }
        public String StatusFilter { get; set; }
        public String AccountFilter { get; set; }
        public String ContractIdFilter { get; set; }
        public String CMSRecordIdFilter { get; set; }
        public String ExternalContractIdFilter { get; set; }
        public Date EffectiveDateFilterFrom { get; set; }
        public Date EffectiveDateFilterTo { get; set; }
        public Date ExpectedActivationDateFilterFrom { get; set; }
        public Date ExpectedActivationDateFilterTo { get; set; }
        public String MccContractManager { get; set; }
        public List<Id> EditedIcfrLogs { get; set; }
        public Date modifiedDate { get; set; }
    }
    /***
    * @author Wojciech Jaskula
    *
    * @Description: Wrapper Method , used to collect Products 
    */
    public class ProductWrapper implements Comparable {
        public ProductWrapper(SPCM_Product__c p) {
            Product = p;
            Selected = false;
        }

        public Integer compareTo(Object compareTo) {
            ProductWrapper w = (ProductWrapper) compareTo;
            return Product.Name.compareTo(w.Product.Name);
        }

        public SPCM_Product__c Product { get; set; }
        public Boolean Selected { get; set; }
    }

    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('New', 'New'));
        options.add(new SelectOption('Pending Analyst', 'Pending Analyst'));
        options.add(new SelectOption('Pending Level 1 Approval', 'Pending Level 1 Approval'));
        options.add(new SelectOption('Pending Level 2 Approval', 'Pending Level 2 Approval'));
        options.add(new SelectOption('Approved by Level 1', 'Approved by Level 1'));
        options.add(new SelectOption('Approved by Level 2', 'Approved by Level 2'));
        //options.add(new SelectOption('Not Closed','Not Closed'));
        options.add(new SelectOption('Closed', 'Closed'));
        options.add(new SelectOption('Cancelled', 'Cancelled'));
        options.add(new SelectOption('In Process', 'In Process'));
        return options;
    }


    public String[] getStatuses() {
        return statuses;
    }

    public void setStatuses(String[] statuses) {
        this.statuses = statuses;
    }
}