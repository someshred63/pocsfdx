public with sharing class GNE_SFA2_PFG_Report_Filters_Ctrl extends GNE_SFA2_PFG_PaginationBase{
    public String reportType {get;set;}
    public String reportCategory {get;set;}
    public Boolean renderCsSelcetion {get;set;}
    public Boolean renderProdSelection {get;set;}
    public Boolean renderLotSelection {get;set;}
    public Boolean renderDateRangeSelection {get;set;}
    public Boolean renderYearsSelection {get;set;}
    public Boolean renderHcpSelection {get;set;}
    public Boolean renderShipmentSelection {get;set;}
    public Boolean renderLotExp {get;set;}
    public Boolean renderOrderId {get;set;}
    public Boolean renderDateField {get;set;}
    public Boolean renderOrderIdSelection {get;set;}
    public Boolean isProductSelectionRequired {get;set;}
    public Boolean isYearPicklistRequired {get;set;}
    public String sortField  {get;set;}
    public String sortDirection {get;set;}
    public List<WrappedReportRow> reportRows {get;set;}
    public List<List<WrappedReportRow>> reportRowsPrintPDF {get; private set;}
    public Map<Integer, WrappedCSResult> filteredCSc {get;set;}
    public Map<Integer, WrappedProductResult> filteredProducts {get;set;}
    public Map<Integer, WrappedLotResult> filteredLots {get;set;}
    public Map<Integer, WrappedAccResult> filteredAccounts {get;set;}
    public Map<Integer, WrappedShipmentResult> filteredShipments {get;set;}
    public Map<Integer, WrappedOrderResult> filteredOrders {get;set;}
    public String selectedCSsJSON {get;set;}
    public String selectedProductsJSON {get;set;}
    public String selectedLotsJSON {get;set;}
    public String selectedAccsJSON {get;set;}
    public String selectedShpJSON {get;set;}
    public String selectedOrdJSON {get;set;}
    public List<Id> selectedCSs {get; set;}
    public List<Id> selectedProds {get;set;}
    public List<Id> selectedLots {get;set;}
    public List<Id> selectedAccs {get;set;}
    public List<String> selectedShpnt {get;set;}
    public List<Id> selectedOrders {get;set;}
    public transient Integer csIndex {get;set;}
    public transient Integer prodIndex {get;set;}
    public transient Integer lotIndex {get;set;}
    public transient Integer accIndex {get;set;}
    public transient Integer shpntIndex {get;set;}
    public transient Integer orderIndex {get;set;}
    public String startDate {get;set;}
    public String endDate {get;set;}
    public String dateField {get;set;}
    public Set<Id> csIds {get;set;}
    public Set<Id> prodIds {get;set;}
    public Set<String> lotNOs {get;set;}
    public Set<Id> accIds {get;set;}
    public Set<String> shpntIds {get;set;}
    public Set<Id> orderIds {get;set;}
    public String expirationDays {get;set;}
    public Date lotExpirationDate {get;set;}
    public Integer csElementsCount {get;set;}
    public Integer prodElementsCount {get;set;}
    public Integer lotElementsCount {get;set;}
    public Integer accElementsCount {get;set;}
    public Integer shpntElementsCount {get;set;}
    public Integer orderElementsCount {get;set;}
    public static final String SELECT_REPORT_TYPE = 'Select Report';
    public static final String SELECT_REPORT_CAT = 'Select Category';
    public static final String SELECT_EXPIRATION = 'Select Expiration';
    public Boolean disableReportTypes {get;set;}
    public Boolean showResults {get;set;}
    public String transName {get;set;}
    public List<String> leftSelectedYears {get; set;}
    public List<String> rightSelectedYears {get; set;}
    public Set<String> leftYearValues = new Set<String>();
    public Set<String> rightYearValues = new Set<String>();
    private static Integer FIRST_BREAK = 10;
    private static Integer SUBSEQ_BREAKS = 12;
    public transient Integer printListSize {get; set;}
    public List<String> yearsToDisplay {get;set;}
    public String fileName {get;set;}
    private Integer csIdx = 0;
    private Integer prodIdx = 0;
    private Integer lotIdx = 0;
    private Integer accIdx = 0;
	private Integer shpIdx = 0;
	private Integer ordIdx = 0;

    public List<SelectOption> reportGroups{
        get{
        	List<SelectOption> options = new List<SelectOption>();
        	options.add(new SelectOption(SELECT_REPORT_CAT,'--'+SELECT_REPORT_CAT+'--'));

        	Id userId = UserInfo.getUserId();
        	Boolean isDtpActive = GNE_SFA2_PFG_Util.isDtpActiveForUser(userId);
        	Boolean isHcActive = GNE_SFA2_PFG_Util.isHcActiveForUser(userId);

            for(SFA2_PFG_Report_Categories_gne__c rCategories : SFA2_PFG_Report_Categories_gne__c.getAll().values()){

            	String distMethod = rCategories.Distribution_Method_gne__c;
            	Boolean activeForDistMethod =
                	(distMethod == GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP && isDtpActive) ||
                	(distMethod == GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC && isHcActive);
                Boolean noDistMethod =
                	distMethod != GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP &&
                	distMethod != GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC;

                if(rCategories.is_visible_gne__c == true && (activeForDistMethod || noDistMethod)) {
                	options.add(new SelectOption(rCategories.Name,rCategories.Name));
                }
            }
            return options;
        }
        set;
    }
    public List<SelectOption> reportTypes{
        get{
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption(SELECT_REPORT_TYPE,'--'+SELECT_REPORT_TYPE+'--'));
            for(SFA2_PFG_Report_Types_gne__c rTypes : SFA2_PFG_Report_Types_gne__c.getAll().values()){
                if(rTypes.Report_Category_gne__c == reportCategory){
                    options.add(new SelectOption(rTypes.Report_Name_gne__c,rTypes.Report_Name_gne__c.removeEnd('DTP')));
                }
            }
            return options;
        }
        set;
    }

    public List<SelectOption> expirationOptions{
        get{
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('30','30 days'));
            options.add(new SelectOption('60','60 days'));
            options.add(new SelectOption('90','90 days'));
            options.add(new SelectOption('120','120 days'));
            return options;
        }
        set;
    }

    public List<SelectOption> getUnselectedYearValues(){
        List<SelectOption> options = new List<SelectOption>();
        List<String> tmpList = new List<String>();
        tmpList.addAll(leftYearValues);
        tmpList.sort();
        for(String year : tmpList){
            options.add(new SelectOption(year,year));
        }
        return options;
    }

    public List<SelectOption> getSelectedYearValues(){
        List<SelectOption> options = new List<SelectOption>();
        List<String> tmpList = new List<String>();
        tmpList.addAll(rightYearValues);
        tmpList.sort();
        for(String year : tmpList){
            options.add(new SelectOption(year,year));
        }
        return options;

    }

    public PageReference selectProductClick() {
        PageReference result = null;
        try {
            result = intSelectProductClick();
        } catch(Exception ex) {
            result = GNE_SFA2_PFG_Base_Controller.setErrorPageReference(ex);
        }

        return result;
    }

    private PageReference intSelectProductClick(){
        rightSelectedYears.clear();
        this.yearsToDisplay.clear();
        for(String year : leftSelectedYears){
            leftYearValues.remove(year);
            rightYearValues.add(year);
        }
        this.yearsToDisplay.addAll(rightYearValues);
        return null;
    }

    public PageReference unselectProductClick() {
        PageReference result = null;
        try {
            result = intUnselectProductClick();
        } catch(Exception ex) {
            result = GNE_SFA2_PFG_Base_Controller.setErrorPageReference(ex);
        }

        return result;
    }

    private PageReference intUnselectProductClick(){
        leftSelectedYears.clear();
        this.yearsToDisplay.clear();
        for(String year : rightSelectedYears){
            rightYearValues.remove(year);
            leftYearValues.add(year);
        }
        this.yearsToDisplay.addAll(rightYearValues);
        return null;
    }

    public GNE_SFA2_PFG_Report_Filters_Ctrl(){
        this.reportCategory = SELECT_REPORT_CAT;
        this.reportType = SELECT_REPORT_TYPE;
        this.disableReportTypes = true;
        init();
    }

    private void init(){
        this.showResults = false;
        this.transName = '';
        this.expirationDays = '30';
        this.lotExpirationDate = Date.today().addDays(Integer.valueOf(this.expirationDays));
        this.leftYearValues = returnYears();
        this.leftSelectedYears = new List<String>();
        this.rightSelectedYears = new List<String>();
        this.renderCsSelcetion = false;
        this.renderProdSelection = false;
        this.renderLotSelection = false;
        this.renderDateRangeSelection = false;
        this.renderYearsSelection = false;
        this.renderHcpSelection = false;
        this.renderShipmentSelection = false;
        this.renderLotExp = false;
        this.renderOrderId = false;
        this.renderDateField = false;
        this.renderOrderIdSelection = false;
        this.isProductSelectionRequired = false;
        this.isYearPicklistRequired = false;
        this.startDate = String.valueOf(GNE_SFA2_PFG_Reports_Helper.returnFirstDayOfQuater());
        this.endDate = String.valueOf(DateTime.now().format('MM/dd/yyyy'));
        this.dateField = String.valueOf(DateTime.now().format('MM/dd/yyyy'));
        this.csIds = new Set<Id>();
        this.prodIds = new Set<Id>();
        this.lotNOs = new Set<String>();
        this.accIds = new Set<Id>();
        this.shpntIds = new Set<String>();
        this.orderIds = new Set<Id>();
        this.filteredCSc = new Map<Integer, WrappedCSResult>();
        this.filteredProducts = new Map<Integer, WrappedProductResult>();
        this.filteredLots = new Map<Integer, WrappedLotResult>();
        this.filteredAccounts = new Map<Integer, WrappedAccResult>();
        this.filteredShipments = new Map<Integer, WrappedShipmentResult>();
        this.filteredOrders = new Map<Integer, WrappedOrderResult>();
        this.csElementsCount = 0;
        this.prodElementsCount = 0;
        this.lotElementsCount = 0;
        this.accElementsCount = 0;
        this.shpntElementsCount = 0;
        this.orderElementsCount = 0;
        this.yearsToDisplay = new List<String>();
    }

    private Set<String> returnYears(){
        List<String> tmpList = new List<String>();
        Integer currentYear = Date.today().year();
        tmpList.add(String.valueOf(currentYear));
        for(Integer i=1; i<=21; i++){
            tmpList.add(String.valueOf(currentYear +i));
            tmpList.add(String.valueOf(currentYear -i));
        }
        tmpList.sort();
        Set<String> tmpSet = new Set<String>();
        tmpSet.addAll(tmpList);
        return tmpSet;

    }

    public PageReference selectLotExpiration() {
        PageReference result = null;
        try {
            result = intSelectLotExpiration();
        } catch(Exception ex) {
            result = GNE_SFA2_PFG_Base_Controller.setErrorPageReference(ex);
        }

        return result;
    }

    private PageReference intSelectLotExpiration(){
        if(this.expirationDays != SELECT_EXPIRATION){
            this.lotExpirationDate = Date.today().addDays(Integer.valueOf(this.expirationDays));
        }
        return null;
    }

    public PageReference selectReportCategory() {
        PageReference result = null;
        try {
            result = intSelectReportCategory();
        } catch(Exception ex) {
            result = GNE_SFA2_PFG_Base_Controller.setErrorPageReference(ex);
        }

        return result;
    }

    private PageReference intSelectReportCategory(){
        if(reportCategory != SELECT_REPORT_CAT){
            init();
            this.disableReportTypes = false;
        }
        else{
            init();
            this.reportType = SELECT_REPORT_TYPE;
            this.disableReportTypes = true;
        }
        return null;
    }

    public PageReference runReport() {
        PageReference result = null;
        try {
            result = intRunReport();
        } catch(Exception ex) {
            result = GNE_SFA2_PFG_Base_Controller.setErrorPageReference(ex);
        }

        return result;
    }

    private PageReference intRunReport(){
        if(reportCategory == SELECT_REPORT_CAT){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Cannot run report without report category selection.'));
        }
        if(reportType == GNE_SFA2_PFG_Reports_Helper.REPORT_TYPE_ADJUSTEMNTS){
            this.sortField = 'csName';
            this.sortDirection = 'ASC';
            prepareDataForAdjustmentReport(this.startDate, this.endDate, this.csIds, this.prodIds, this.lotNOs);
        }
        if(reportType == GNE_SFA2_PFG_Reports_Helper.REPORT_TYPE_DISBURSEMENTS){
            this.sortField = 'lotNo';
            this.sortDirection = 'ASC';
            prepareDataForDisbursementReport(this.startDate, this.endDate, this.prodIds, this.lotNOs, this.accIds);
        }
        if(reportType == GNE_SFA2_PFG_Reports_Helper.REPORT_TYPE_HC_EXCEPTION){
            this.sortField = 'transactionDate';
            this.sortDirection = 'DESC';
            prepareDataForHCExceptionReport(this.dateField, this.csIds, this.prodIds, this.transName);
        }
        if(reportType == GNE_SFA2_PFG_Reports_Helper.REPORT_TYPE_LOT_EXPIRATION){
            this.sortField = 'lotExpiration';
            this.sortDirection = 'DESC';
            prepareDataForLotExpirationReport(this.lotExpirationDate, this.prodIds, this.lotNOs);
        }
        if(reportType == GNE_SFA2_PFG_Reports_Helper.REPORT_TYPE_QTY_LMT_CHG_HISTORY){
            this.sortField = 'changeDate';
            this.sortDirection = 'DESC';
            prepareDataForQuantityLimitsForHCPChangeHistoryReport(this.prodIds, this.rightYearValues, this.accIds);
        }
        if(reportType == GNE_SFA2_PFG_Reports_Helper.REPORT_TYPE_QTY_LMT_CHG_HISTORY_DTP){
            this.sortField = 'changeDate';
            this.sortDirection = 'DESC';
            prepareDataForQuantityLimitsForHCPChangeHistoryReport(this.prodIds, this.rightYearValues, this.accIds);
        }
        if(reportType == GNE_SFA2_PFG_Reports_Helper.REPORT_TYPE_RETURNS){
            this.sortField = 'csName';
            this.sortDirection = 'ASC';
            prepareDataForReturnReport(this.startDate, this.endDate, this.csIds, this.prodIds, this.lotNOs);
        }
        if(reportType == GNE_SFA2_PFG_Reports_Helper.REPORT_TYPE_UNACKNOWLEDGED_SHIPMENTS){
            this.sortField = 'shipmentDate';
            this.sortDirection = 'DESC';
            prepareDataForUnacknowledgedShipmentsReport(this.dateField, this.csIds, this.orderIds, this.shpntIds);
        }
        if(reportType == GNE_SFA2_PFG_Reports_Helper.REPORT_TYPE_DTP_EXCEPTION){
        	this.sortField = 'transactionDate';
            this.sortDirection = 'DESC';
            prepareDataForDTPexception(this.dateField, this.accIds, this.prodIds, this.transName);
        }
        if(reportType == GNE_SFA2_PFG_Reports_Helper.REPORT_TYPE_OUTSTANDING_AOC){
        	this.sortField = 'hcpId';
            this.sortDirection = 'ASC';
        	prepareDataForOutstandingAOC(this.accIds, this.csIds, this.prodIds, this.lotNOs);
        }
        if(reportType == SELECT_REPORT_TYPE){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Cannot run report without report type selection.'));
        }
        if(this.reportRows != null && this.reportRows.size()>0){
            this.showResults = true;
            sortResults();
        }
        else{
            this.showResults = false;
        }
        if(ApexPages.hasMessages()){
            return null;
        }
        else{
            PageReference pageRef = new PageReference('/apex/GNE_SFA2_PFG_ReportDisplay');
            pageRef.setRedirect(false);
            return pageRef;
        }
    }

    public PageReference cancel(){
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_PFG_MyPFG');
        pageRef.setRedirect(true);
        return pageRef;
    }

    public PageReference goBack(){
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_PFG_Report_Filters');
        pageRef.setRedirect(false);
        return pageRef;
    }

    public PageReference exportToExcel() {
        PageReference result = null;
        try {
            result = intExportToExcel();
        } catch(Exception ex) {
            result = GNE_SFA2_PFG_Base_Controller.setErrorPageReference(ex);
        }

        return result;
    }

    private PageReference intExportToExcel(){
        this.fileName = reportType+' '+String.valueOf(Date.today());
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_PFG_ReportExportToExcel');
        pageRef.setRedirect(false);
        return pageRef;
        return null;
    }

    public String getWorkbookProperties() {
        String workbook = '<x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet><x:Name>' + this.reportType + '</x:Name><x:WorksheetOptions><x:DisplayGridlines/></x:WorksheetOptions></x:ExcelWorksheet></x:ExcelWorksheets></x:ExcelWorkbook>';
        return workbook;
    }

    public PageReference printReport() {
        PageReference result = null;
        try {
            result = intPrintReport();
        } catch(Exception ex) {
            result = GNE_SFA2_PFG_Base_Controller.setErrorPageReference(ex);
        }

        return result;
    }

    private PageReference intPrintReport(){
        perpareDataForPrintPDF(this.reportRows);
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_PFG_ReportPrint');
        pageRef.setRedirect(false);
        return pageRef;
    }

    private void perpareDataForPrintPDF(List<WrappedReportRow> rRows){
        this.reportRowsPrintPDF = new List<List<WrappedReportRow>>();
        List<WrappedReportRow> tmpList = new List<WrappedReportRow>();
        Integer counter = 0;
        Boolean firstBreakFound = false;
        Boolean setSubSeqBreak = false;
        Integer breakPoint = FIRST_BREAK;
        for(WrappedReportRow rRow : rRows) {
            if(counter <= breakPoint){
                tmpList.add(rRow);
                counter++;
            }
            if(counter == breakPoint){
                if(!firstBreakFound){
                    firstBreakFound = true;
                    setSubSeqBreak = true;
                }
                counter = 0;
                this.reportRowsPrintPDF.add(tmpList);
                tmpList = new List<WrappedReportRow>();
            }
            if(setSubSeqBreak){
                breakPoint = SUBSEQ_BREAKS;
                setSubSeqBreak = false;
            }
        }
        if(!tmpList.isEmpty()){
            this.reportRowsPrintPDF.add(tmpList);
        }
        this.printListSize = this.reportRowsPrintPDF.size();
    }

    private void prepareDataForAdjustmentReport(String startDate, String endDate, Set<Id> csIds, Set<Id> prodIds, Set<String> lotNOs){
        if(String.isEmpty(startDate)){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Start Date is required.'));
        }
        if(String.isEmpty(endDate)){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'End Date is required.'));
        }

        if(!ApexPages.hasMessages()){
	        if(GNE_SFA2_PFG_Reports_Helper.dateNewInstance(startDate).daysBetween(GNE_SFA2_PFG_Reports_Helper.dateNewInstance(endDate)) < 0){
	        	 ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'End Date cannot be prior to the Start Date'));
	        }
	        if(!ApexPages.hasMessages()){
		        List<SFA2_PFG_Transaction_gne__c> transactions = GNE_SFA2_PFG_Reports_DAO.getAdjustemntsByDatesAndCsAndProductsAndLotsHC(startDate, endDate, csIds, prodIds, lotNOs);
		        Set<String> lotNumbers = new Set<String>();
		        if(!lotNOs.isEmpty()){
		            lotNumbers.addAll(lotNOs);
		        }
		        Map<String, List<SFA2_PFG_Transaction_gne__c>> lotToTransactions = new Map<String, List<SFA2_PFG_Transaction_gne__c>>();
		        if(transactions != null && transactions.size()>0){
		            if(lotNumbers.size()>0){
		                for(SFA2_PFG_Transaction_gne__c trx : transactions){
		                    if(lotToTransactions.containsKey(trx.Lot_No_gne__c)){
		                        lotToTransactions.get(trx.Lot_No_gne__c).add(trx);
		                    }
		                    else{
		                        List<SFA2_PFG_Transaction_gne__c> trxList = new List<SFA2_PFG_Transaction_gne__c>();
		                        trxList.add(trx);
		                        lotToTransactions.put(trx.Lot_No_gne__c, trxList);
		                    }
		                }
		            }
		            else{
		                for(SFA2_PFG_Transaction_gne__c trx : transactions){
		                    lotNumbers.add(trx.Lot_No_gne__c);
		                    if(lotToTransactions.containsKey(trx.Lot_No_gne__c)){
		                        lotToTransactions.get(trx.Lot_No_gne__c).add(trx);
		                    }
		                    else{
		                        List<SFA2_PFG_Transaction_gne__c> trxList = new List<SFA2_PFG_Transaction_gne__c>();
		                        trxList.add(trx);
		                        lotToTransactions.put(trx.Lot_No_gne__c, trxList);
		                    }
		                }
		            }
		        }
		        List<SFA2_Lot_Catalog_gne__c> lotCatalogsList = GNE_SFA2_PFG_DAO.getLotCatalogsForLotNumber(lotNumbers);
		        this.reportRows = new List<WrappedReportRow>();
		        for(SFA2_Lot_Catalog_gne__c lotCat : lotCatalogsList){
		            if(lotToTransactions.containsKey(lotCat.Name)){
		                for(SFA2_PFG_Transaction_gne__c trans : lotToTransactions.get(lotCat.Name)){
		                    WrappedReportRow reportRow = new WrappedReportRow();
		                    //Inventory_Count_Flag_gne__c == true ---> To User
		                    //Inventory_Count_Flag_gne__c == false ---> From User
		                    if(trans.Inventory_Count_Flag_gne__c == true){
		                        reportRow.territoryNo = trans.To_Territory_Number_gne__c;
		                        reportRow.csId = trans.To_User_gne__r.Username.substringBefore('@');
		                        reportRow.csName = trans.To_User_gne__r.Name;
		                    }
		                    else{
		                        reportRow.territoryNo = trans.From_Territory_Number_gne__c;
		                        reportRow.csId = trans.From_User_gne__r.Username.substringBefore('@');
		                        reportRow.csName = trans.From_User_gne__r.Name;
		                    }
		                    reportRow.dmName = trans.Adjustment_DM_Name_Calc_gne__c;
		                    reportRow.ndcNumber = trans.NDC_Number__c;
		                    reportRow.productName = trans.Product_gne__r.Name;
		                    reportRow.lotNo = trans.Lot_No_gne__c;
		                    reportRow.lotExpiration = lotCat.Expiration_Date_gne__c;
		                    reportRow.quantity = trans.Shipped_Quantity_gne__c;
		                    reportRow.transactionId = trans.Id;
		                    reportRow.transactionName = trans.Name;
		                    reportRow.transactionDate = trans.Transaction_Date_gne__c;
		                    reportRow.transactionReason = trans.Transaction_Reason_gne__c;
		                    reportRow.callId = trans.Iteraction_Calculation_gne__c;
		                    reportRow.callName = trans.Iteraction_Name_Calculation_gne__c;
		                    this.reportRows.add(reportRow);
		                }
		            }
		        }
	        }
        }
    }
    private void prepareDataForReturnReport(String startDate, String endDate, Set<Id> csIds, Set<Id> prodIds, Set<String> lotNOs){
        if(String.isBlank(startDate)){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Start Date is required.'));
        }
        if(String.isBlank(endDate)){
        	 ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'End Date is required.'));
        }

        if(String.isNotBlank(startDate) && String.isNotBlank(endDate) && GNE_SFA2_PFG_Reports_Helper.dateNewInstance(startDate).daysBetween(GNE_SFA2_PFG_Reports_Helper.dateNewInstance(endDate)) < 0){
        	 ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'End Date cannot be prior to the Start Date'));
        }
        if(!ApexPages.hasMessages()){
	        List<SFA2_PFG_Transaction_gne__c> transactions = GNE_SFA2_PFG_Reports_DAO.getReturnsByDatesAndCsAndProductsAndLotsHC(startDate, endDate, csIds, prodIds, lotNOs);
	        Set<String> lotNumbers = new Set<String>();
	        if(!lotNOs.isEmpty()){
	            lotNumbers.addAll(lotNOs);
	        }
	        Map<String, List<SFA2_PFG_Transaction_gne__c>> lotToTransactions = new Map<String, List<SFA2_PFG_Transaction_gne__c>>();
	        if(transactions != null && transactions.size()>0){
	            if(lotNumbers.size()>0){
	                for(SFA2_PFG_Transaction_gne__c trx : transactions){
	                    if(lotToTransactions.containsKey(trx.Lot_No_gne__c)){
	                        lotToTransactions.get(trx.Lot_No_gne__c).add(trx);
	                    }
	                    else{
	                        List<SFA2_PFG_Transaction_gne__c> trxList = new List<SFA2_PFG_Transaction_gne__c>();
	                        trxList.add(trx);
	                        lotToTransactions.put(trx.Lot_No_gne__c, trxList);
	                    }
	                }
	            }
	            else{
	                for(SFA2_PFG_Transaction_gne__c trx : transactions){
	                    lotNumbers.add(trx.Lot_No_gne__c);
	                    if(lotToTransactions.containsKey(trx.Lot_No_gne__c)){
	                        lotToTransactions.get(trx.Lot_No_gne__c).add(trx);
	                    }
	                    else{
	                        List<SFA2_PFG_Transaction_gne__c> trxList = new List<SFA2_PFG_Transaction_gne__c>();
	                        trxList.add(trx);
	                        lotToTransactions.put(trx.Lot_No_gne__c, trxList);
	                    }
	                }
	            }
	        }
	        List<SFA2_Lot_Catalog_gne__c> lotCatalogsList = GNE_SFA2_PFG_DAO.getLotCatalogsForLotNumber(lotNumbers);
	        this.reportRows = new List<WrappedReportRow>();
	        for(SFA2_Lot_Catalog_gne__c lotCat : lotCatalogsList){
	            if(lotToTransactions.containsKey(lotCat.Name)){
	                for(SFA2_PFG_Transaction_gne__c trans : lotToTransactions.get(lotCat.Name)){
	                    WrappedReportRow reportRow = new WrappedReportRow();
	                    reportRow.territoryNo = trans.From_Territory_Number_gne__c;
	                    reportRow.csId = trans.From_User_gne__r.Username.substringBefore('@');
	                    reportRow.csName = trans.From_User_gne__r.Name;
	                    reportRow.dmName = trans.From_User_gne__r.Manager.Name;
	                    reportRow.ndcNumber = trans.NDC_Number__c;
	                    reportRow.productName = trans.Product_gne__r.Name;
	                    reportRow.lotNo = trans.Lot_No_gne__c;
	                    reportRow.lotExpiration = lotCat.Expiration_Date_gne__c;
	                    reportRow.quantity = trans.Shipped_Quantity_gne__c;
	                    reportRow.transactionId = trans.Id;
	                    reportRow.transactionName = trans.Name;
	                    reportRow.transactionDate = trans.Transaction_Date_gne__c;
	                    reportRow.transactionReason = trans.Transaction_Reason_gne__c;
	                    reportRow.callId = trans.Iteraction_Calculation_gne__c;
	                    reportRow.callName = trans.Iteraction_Name_Calculation_gne__c;
	                    this.reportRows.add(reportRow);
	                }
	            }
	        }
        }
    }

    private void prepareDataForLotExpirationReport(Date lotExp, Set<Id> prodIds, Set<String> lotNOs){
        if(lotExp == null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Lots expiring within is required.'));
        }
        if(!ApexPages.hasMessages()){
	        List<SFA2_PFG_Inventory_Count_gne__c> inventoryCounts = GNE_SFA2_PFG_Reports_DAO.getInventoryCountsByLotExpAndProductsAndLots(lotExp, prodIds, lotNOs);
	        this.reportRows = new List<WrappedReportRow>();
	        for(SFA2_PFG_Inventory_Count_gne__c invCount : inventoryCounts){
	            Id managerId = GNE_SFA2_PFG_Util.getManagerForUser(invCount.Inventory_For_gne__c);
	            Territory2 terr = GNE_SFA2_PFG_Util.getTerritoryForUser(managerId);
	            WrappedReportRow reportRow = new WrappedReportRow();
	            if(terr != null){
	                reportRow.territoryNo = terr.Territory_Number_gne__c;
	            }
	            if(invCount.Inventory_For_gne__r != null ){
	                reportRow.csId = invCount.Inventory_For_gne__r.Username.substringBefore('@');
	                reportRow.csName = invCount.Inventory_For_gne__r.Name;
	            }

	            SFA2_User_Sales_Roster_gne__c mgrUser = GNE_SFA2_PFG_Util.getSalesRosterForUser(invCount.Inventory_For_gne__r.ManagerId);

            	if(mgrUser!=null) {
            		reportRow.dmName = mgrUser.User_gne__r.Name;
            	}

	            reportRow.ndcNumber = invCount.Product_gne__r.NDC_Number_gne__c;
	            reportRow.productName = invCount.Product_gne__r.Name;
	            reportRow.lotNo = invCount.Lot_gne__c;
	            reportRow.lotExpiration = invCount.Expiration_Date_gne__c;
	            reportRow.quantity = invCount.Count_gne__c;
	            reportRow.lotExpiringWithin = Date.today().daysBetween(invCount.Expiration_Date_gne__c);
	            this.reportRows.add(reportRow);
	        }
        }
    }

    private void prepareDataForDisbursementReport(String startDate, String endDate, Set<Id> prodIds, Set<String> lotNOs, Set<Id> hcpIds){
        if(startDate == null || startDate == ''){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Start Date is required.'));
        }
        if(endDate == null || endDate == ''){
        	 ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'End Date is required.'));
        }
        if(prodIds.isEmpty()){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Filter By PFG Products is required.'));
        }
        if(!ApexPages.hasMessages()){
	        this.reportRows = new List<WrappedReportRow>();
	        List<SFA2_PFG_Transaction_gne__c> transactions = GNE_SFA2_PFG_Reports_DAO.getDisbursementsByDatesAndProductsAndLotsAndHCPsHC(startDate, endDate, prodIds, lotNOs, hcpIds);
	        Set<String> lotNumbers = new Set<String>();
	        if(!lotNOs.isEmpty()){
	            lotNumbers.addAll(lotNOs);
	        }
	        Map<String, List<SFA2_PFG_Transaction_gne__c>> lotToTransactions = new Map<String, List<SFA2_PFG_Transaction_gne__c>>();
	        if(transactions != null && transactions.size()>0){
	            if(lotNumbers.size()>0){
	                for(SFA2_PFG_Transaction_gne__c trx : transactions){
	                    if(lotToTransactions.containsKey(trx.Lot_No_gne__c)){
	                        lotToTransactions.get(trx.Lot_No_gne__c).add(trx);
	                    }
	                    else{
	                        List<SFA2_PFG_Transaction_gne__c> trxList = new List<SFA2_PFG_Transaction_gne__c>();
	                        trxList.add(trx);
	                        lotToTransactions.put(trx.Lot_No_gne__c, trxList);
	                    }
	                }
	            }
	            else{
	                for(SFA2_PFG_Transaction_gne__c trx : transactions){
	                    lotNumbers.add(trx.Lot_No_gne__c);
	                    if(lotToTransactions.containsKey(trx.Lot_No_gne__c)){
	                        lotToTransactions.get(trx.Lot_No_gne__c).add(trx);
	                    }
	                    else{
	                        List<SFA2_PFG_Transaction_gne__c> trxList = new List<SFA2_PFG_Transaction_gne__c>();
	                        trxList.add(trx);
	                        lotToTransactions.put(trx.Lot_No_gne__c, trxList);
	                    }
	                }
	            }
	        }
	        List<SFA2_Lot_Catalog_gne__c> lotCatalogsList = GNE_SFA2_PFG_DAO.getLotCatalogsForLotNumber(lotNumbers);
	        this.reportRows = new List<WrappedReportRow>();
	        for(SFA2_Lot_Catalog_gne__c lotCat : lotCatalogsList){
	            if(lotToTransactions.containsKey(lotCat.Name)){
	                for(SFA2_PFG_Transaction_gne__c trans : lotToTransactions.get(lotCat.Name)){
	                    WrappedReportRow reportRow = new WrappedReportRow();
	                    reportRow.territoryNo = trans.From_Territory_Number_gne__c;
	                    reportRow.csId = trans.From_User_gne__r.Username.substringBefore('@');
	                    reportRow.csName = trans.From_User_gne__r.Name;
	                    if(GNE_SFA2_PFG_Util.getSalesRosterForUser(trans.From_User_gne__r.ManagerId) != null){
	                    	reportRow.dmName = GNE_SFA2_PFG_Util.getSalesRosterForUser(trans.From_User_gne__r.ManagerId).User_gne__r.Name;
	                    }
	                    reportRow.ndcNumber = trans.NDC_Number__c;
	                    reportRow.productName = trans.Product_gne__r.Name;
	                    reportRow.lotNo = trans.Lot_No_gne__c;
	                    reportRow.lotExpiration = lotCat.Expiration_Date_gne__c;
	                    reportRow.quantity = trans.Received_Quantity_gne__c;
	                    reportRow.transactionId = trans.Id;
	                    reportRow.transactionName = trans.Name;
	                    reportRow.transactionDate = trans.Transaction_Date_gne__c;
	                    reportRow.hcpId = trans.Account_gne__c;
	                    reportRow.mdmId = trans.Account_gne__r.MDMID_gne__c;
	                    reportRow.hcpName = trans.Account_gne__r.Name;
	                    reportRow.hcpAddress = trans.Address_Line_1_gne__c+', '+trans.Address_Line_2_gne__c+', '+trans.City_gne__c+', '+trans.Zip_gne__c+' '+trans.State_gne__c;
	                    reportRow.hcpPhone = trans.Account_gne__r.Phone;
	                    this.reportRows.add(reportRow);
	                }
	            }
	        }
        }
    }

    private void prepareDataForQuantityLimitsForHCPChangeHistoryReport(Set<Id> prodIds, Set<String> years, Set<Id> hcpIds){
        if(prodIds.isEmpty()){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Filter By PFG Products is required.'));
        }
        if(years.isEmpty()){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Filter By Years is required.'));
        }
        if(!ApexPages.hasMessages()){
	        this.reportRows = new List<WrappedReportRow>();
	        List<PFG_Staging_Account_Limit_Exception_gne__c> lmtExceptions = GNE_SFA2_PFG_Reports_DAO.getExceptionsByProductsAndYearsAndHCPs(prodIds, years, hcpIds);
	        List<SFA2_PFG_Product_Limit_gne__c> prodLimits = GNE_SFA2_PFG_Reports_DAO.getLimitsByProductsAndYears(prodIds, years);

	        List<PFG_Staging_Account_Limit_Exception_gne__History> lmtExceptionsHistory = new List<PFG_Staging_Account_Limit_Exception_gne__History>();
	        List<SFA2_PFG_Product_Limit_gne__History> prodLmtHistory = new List<SFA2_PFG_Product_Limit_gne__History>();
	        Set<Id> exceptionsIds = new Set<Id>();
	        Set<Id> limitsIds = new Set<Id>();

            for(PFG_Staging_Account_Limit_Exception_gne__c lEx : lmtExceptions){
                exceptionsIds.add(lEx.Id);
            }
	        if(!exceptionsIds.isEmpty()){
	            lmtExceptionsHistory = GNE_SFA2_PFG_Reports_DAO.getExceptionsHistoryByParentId(exceptionsIds);
	        }

            for(SFA2_PFG_Product_Limit_gne__c pLmt : prodLimits){
	            limitsIds.add(pLmt.Id);
            }
	        if(!limitsIds.isEmpty()){
	            prodLmtHistory = GNE_SFA2_PFG_Reports_DAO.getLimitHistoryByParentIds(limitsIds);
	        }

	        if(!lmtExceptionsHistory.isEmpty()){
	            Map<PFG_Staging_Account_Limit_Exception_gne__c, List<PFG_Staging_Account_Limit_Exception_gne__History>> exceptionsToHistory = new Map<PFG_Staging_Account_Limit_Exception_gne__c, List<PFG_Staging_Account_Limit_Exception_gne__History>>();

	            for(PFG_Staging_Account_Limit_Exception_gne__c lmtEx : lmtExceptions){
	                for(PFG_Staging_Account_Limit_Exception_gne__History lmtExH : lmtExceptionsHistory){
	                    if(lmtExH.ParentId == lmtEx.Id){
	                        if(!exceptionsToHistory.containsKey(lmtEx)){
	                            exceptionsToHistory.put(lmtEx, new List<PFG_Staging_Account_Limit_Exception_gne__History>());
	                        }
                            exceptionsToHistory.get(lmtEx).add(lmtExH);
	                    }
	                }
	            }
	            //create wrapper records by map iteration
	            for(PFG_Staging_Account_Limit_Exception_gne__c accEx : exceptionsToHistory.keySet()){
	                for(PFG_Staging_Account_Limit_Exception_gne__History accExH : exceptionsToHistory.get(accEx)){
	                    WrappedReportRow reportRow = new WrappedReportRow();
	                    reportRow.changeDate = Date.valueOf(accExH.CreatedDate);
	                    SFA2_User_Sales_Roster_gne__c creatorUser = GNE_SFA2_PFG_Util.getSalesRosterForUser(accExH.CreatedById);

	                    if(creatorUser!=null) {
	                    	reportRow.userUnix = creatorUser.User_gne__r.External_Id_gne__c;
	                    	reportRow.userName = creatorUser.User_gne__r.Name;
	                    }

	                    if(accExH.Field == 'created'){
	                        reportRow.changeAction = 'HCP exception created';
	                        reportRow.changeFrom = '';
	                        reportRow.changeTo = accEx.Account_gne__r.Name + '; '+String.valueOf(accEx.Exception_Quantity_gne__c);
	                    }else if(accExH.Field == 'Logical_Delete_Flag_gne__c'){
	                        reportRow.changeAction = 'HCP exception deleted';
	                        reportRow.changeFrom = accEx.Account_gne__r.Name + '; ' +String.valueOf(accExH.OldValue);
	                        reportRow.changeTo = accEx.Account_gne__r.Name + '; ' +String.valueOf(accExH.NewValue);
	                    }else{
	                        reportRow.changeAction = 'HCP exception updated';
	                        reportRow.changeFrom = accEx.Account_gne__r.Name + '; ' +String.valueOf(accExH.OldValue);
	                        reportRow.changeTo = accEx.Account_gne__r.Name + '; ' +String.valueOf(accExH.NewValue);
	                    }
	                    this.reportRows.add(reportRow);
	                }
	            }
	        }

	        if(!prodLmtHistory.isEmpty()){
	            Map<SFA2_PFG_Product_Limit_gne__c, List<SFA2_PFG_Product_Limit_gne__History>> prodLimitsToHistory = new Map<SFA2_PFG_Product_Limit_gne__c, List<SFA2_PFG_Product_Limit_gne__History>>();
	            for(SFA2_PFG_Product_Limit_gne__c prodLimit : prodLimits){
	                for(SFA2_PFG_Product_Limit_gne__History prdLmtH : prodLmtHistory){
	                    if(prdLmtH.ParentId == prodLimit.Id){
	                        if(prodLimitsToHistory.containsKey(prodLimit)){
	                            prodLimitsToHistory.get(prodLimit).add(prdLmtH);
	                        }
	                        else{
	                            List<SFA2_PFG_Product_Limit_gne__History> tmpList = new List<SFA2_PFG_Product_Limit_gne__History>();
	                            tmpList.add(prdLmtH);
	                            prodLimitsToHistory.put(prodLimit, tmpList);
	                        }
	                    }
	                }
	            }
	            for(SFA2_PFG_Product_Limit_gne__c productLimit : prodLimitsToHistory.keySet()){
	                for(SFA2_PFG_Product_Limit_gne__History productLimitHistory : prodLimitsToHistory.get(productLimit)){
	                    WrappedReportRow reportRow = new WrappedReportRow();
	                    reportRow.changeDate = Date.valueOf(productLimitHistory.CreatedDate);
	                    if(GNE_SFA2_PFG_Util.getSalesRosterForUser(productLimitHistory.CreatedById) != null){
	                        reportRow.userUnix = GNE_SFA2_PFG_Util.getSalesRosterForUser(productLimitHistory.CreatedById).User_gne__r.External_Id_gne__c;
	                        reportRow.userName = GNE_SFA2_PFG_Util.getSalesRosterForUser(productLimitHistory.CreatedById).User_gne__r.Name;
	                    }
	                    if(productLimitHistory.Field == 'created'){
	                        reportRow.changeAction = 'Quantity Limit Set';
	                        reportRow.changeFrom = '0';
	                        reportRow.changeTo = String.valueOf(productLimit.Limit_Quantity_gne__c);
	                    }
	                    else{
	                        reportRow.changeAction = 'Quantity Limit Set';
	                        reportRow.changeFrom = String.valueOf(productLimitHistory.OldValue);
	                        reportRow.changeTo = String.valueOf(productLimitHistory.NewValue);
	                    }
	                    this.reportRows.add(reportRow);
	                }
	            }
	        }
        }
    }

    public void prepareDataForHCExceptionReport(String filterDate, Set<Id> csIds, Set<Id> prodIds, String orderId){
        if(String.isEmpty(filterDate)){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Filter By Date is required.'));
            return;
        }
        List<SFA2_PFG_Transaction_gne__c> transactions = GNE_SFA2_PFG_Reports_DAO.getOrdersByDateAndCSNameAndProductNameAndOrderIdHC(filterDate, csIds, prodIds, orderId);
        this.reportRows = new List<WrappedReportRow>();
        for(SFA2_PFG_Transaction_gne__c trx : transactions){
            WrappedReportRow reportRow = new WrappedReportRow();
            reportRow.territoryNo = trx.To_Territory_Number_gne__c;
            reportRow.csId = trx.To_User_gne__r.UserName.substringBefore('@');
            reportRow.csName = trx.To_User_gne__r.Name;
            SFA2_User_Sales_Roster_gne__c mgrUser = GNE_SFA2_PFG_Util.getSalesRosterForUser(trx.To_User_gne__r.ManagerId);

            if(mgrUser!=null) {
            	reportRow.dmName = mgrUser.User_gne__r.Name;
            }

            reportRow.ndcNumber = trx.NDC_Number__c;
            reportRow.productName = trx.Product_gne__r.Name;
            reportRow.lotNo = trx.Lot_No_gne__c;
            reportRow.quantity = trx.Received_Quantity_gne__c;
            reportRow.transactionDate = trx.Transaction_Date_gne__c;
            reportRow.orderName = trx.Name;
            reportRow.orderStatus = trx.Delivery_Status_gne__c;
            reportRow.orderId = trx.Id;
            this.reportRows.add(reportRow);
        }
    }

    public void prepareDataForUnacknowledgedShipmentsReport(String filterDate, Set<Id> csIds, Set<Id> orderIds, Set<String> shipmentIds){
        if(filterDate == ''){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Filter By Date is required.'));
            return;
        }
        List<SFA2_PFG_Transaction_gne__c> transactions = GNE_SFA2_PFG_Reports_DAO.getOrdersByDateCSNameOrdersAndShipmentsHC(filterDate, csIds, orderIds, shipmentIds);
        this.reportRows = new List<WrappedReportRow>();
        for(SFA2_PFG_Transaction_gne__c trx : transactions){
            WrappedReportRow reportRow = new WrappedReportRow();
            reportRow.territoryNo = trx.To_Territory_Number_gne__c;
            reportRow.csId = trx.To_User_gne__r.UserName.substringBefore('@');
            reportRow.csName = trx.To_User_gne__r.Name;
            SFA2_User_Sales_Roster_gne__c mgrUser = GNE_SFA2_PFG_Util.getSalesRosterForUser(trx.To_User_gne__r.ManagerId);

            if(mgrUser!=null) {
            	reportRow.dmName = mgrUser.User_gne__r.Name;
            }

            reportRow.ndcNumber = trx.NDC_Number__c;
            reportRow.productName = trx.Product_gne__r.Name;
            reportRow.lotNo = trx.Lot_No_gne__c;
            reportRow.quantity = trx.Requested_Quantity_gne__c;
            reportRow.transactionDate = trx.Transaction_Date_gne__c;
            reportRow.transactionName = trx.Name;
            reportRow.transactionId = trx.Id;
            reportRow.shipmentDate = trx.Shipped_Date_gne__c;
            reportRow.shipmentId = trx.Shipment_Id_gne__c;
            this.reportRows.add(reportRow);
        }
    }

    public void prepareDataForDTPexception(String filterDate, Set<Id> accIds, Set<Id> prodIds, String orderId){
    	if(String.isEmpty(filterDate)){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Filter By Date is required.'));
            return;
        }
        List<SFA2_PFG_Transaction_gne__c> transactions = GNE_SFA2_PFG_Reports_DAO.getOrdersByOrderDateHCPsProductsAndOrderIdDTP(filterDate, accIds, prodIds, orderId);
        this.reportRows = new List<WrappedReportRow>();
        for(SFA2_PFG_Transaction_gne__c trx : transactions){
        	WrappedReportRow reportRow = new WrappedReportRow();
        	reportRow.hcpId = trx.Account_gne__r.Id;
        	reportRow.mdmId = trx.Account_gne__r.MDMID_gne__c;
        	reportRow.hcpName = trx.Account_gne__r.Name;
        	reportRow.hcpAddress = trx.Address_Line_1_gne__c+', '+trx.Address_Line_2_gne__c+', '+trx.City_gne__c+', '+trx.Zip_gne__c+' '+trx.State_gne__c;
        	reportRow.ndcNumber = trx.NDC_Number__c;
        	reportRow.productName = trx.Product_gne__r.Name;
        	reportRow.quantity = trx.Requested_Quantity_gne__c;
        	reportRow.transactionDate = trx.Transaction_Date_gne__c;
        	reportRow.transactionId = trx.Id;
        	reportRow.transactionName = trx.Name;
        	reportRow.orderStatus = trx.Delivery_Status_gne__c;
        	reportRow.territoryNo = trx.From_Territory_Number_gne__c;
        	reportRow.csId = trx.From_User_gne__r.UserName.substringBefore('@');
        	reportRow.csName = trx.From_User_gne__r.Name;
        	if(GNE_SFA2_PFG_Util.getSalesRosterForUser(trx.From_User_gne__r.ManagerId) != null){
        		reportRow.dmName = GNE_SFA2_PFG_Util.getSalesRosterForUser(trx.From_User_gne__r.ManagerId).User_gne__r.Name;
        	}
        	this.reportRows.add(reportRow);
        }
    }

    public void prepareDataForOutstandingAOC(Set<Id> hcpIds, Set<Id> csIds, Set<Id> prodIds, Set<String> lotNos){
		this.reportRows = new List<WrappedReportRow>();
    	List<SFA2_PFG_Transaction_gne__c> transactions = GNE_SFA2_PFG_Reports_DAO.getOutstandingAOCtransactionsDTP(hcpIds, csIds, prodIds, lotNos);

		for(SFA2_PFG_Transaction_gne__c dtpTrans : transactions) {
	       	WrappedReportRow reportRow = new WrappedReportRow();
	        reportRow.hcpId = dtpTrans.Account_gne__c;
	        reportRow.mdmId = dtpTrans.Account_gne__r.MDMID_gne__c;
	        reportRow.hcpName = dtpTrans.Account_gne__r.Name;
			reportRow.hcpAddress = String.format('{0}{1}, {2}, {3} {4}', new String[]{
				dtpTrans.Address_Line_1_gne__c,	// {0}
				(String.isNotBlank(dtpTrans.Address_Line_2_gne__c) ? ', ' + dtpTrans.Address_Line_2_gne__c : ''),	// {1}
				dtpTrans.City_gne__c,			// {2}
				dtpTrans.Zip_gne__c,			// {3}
				dtpTrans.State_gne__c			// {4}
				});
			reportRow.ndcNumber = dtpTrans.NDC_Number__c;
	        reportRow.shipmentId = dtpTrans.Shipment_Id_gne__c;
	        reportRow.shipmentDate = dtpTrans.Shipped_Date_gne__c;
	        reportRow.transactionId = dtpTrans.Id;
	        reportRow.transactionName = dtpTrans.Name;
	        reportRow.transactionDate = dtpTrans.Transaction_Date_gne__c;
			reportRow.callId = dtpTrans.Iteraction_Calculation_gne__c;
			reportRow.callName = dtpTrans.Iteraction_Name_Calculation_gne__c;
	        reportRow.csId = dtpTrans.From_User_gne__r.Username.substringBefore('@');
	        reportRow.csName = dtpTrans.From_User_gne__r.Name;
	        reportRow.csPhone = dtpTrans.From_User_gne__r.Phone;
	        this.reportRows.add(reportRow);
	    }
    }

    public PageReference reportTypeSelect() {
        PageReference result = null;
        try {
            result = intReportTypeSelect();
        } catch(Exception ex) {
            result = GNE_SFA2_PFG_Base_Controller.setErrorPageReference(ex);
        }

        return result;
    }

    private PageReference intReportTypeSelect(){
        init();
        if(reportType == GNE_SFA2_PFG_Reports_Helper.REPORT_TYPE_ADJUSTEMNTS){
            this.renderCsSelcetion = true;
            this.renderDateRangeSelection = true;
            this.renderProdSelection = true;
            this.renderLotSelection = true;
        }else if(reportType == GNE_SFA2_PFG_Reports_Helper.REPORT_TYPE_DISBURSEMENTS){
            this.renderDateRangeSelection = true;
            this.renderProdSelection = true;
            this.renderLotSelection = true;
            this.renderHcpSelection = true;
            this.isProductSelectionRequired = true;
        }else if(reportType == GNE_SFA2_PFG_Reports_Helper.REPORT_TYPE_HC_EXCEPTION){
            this.renderDateField = true;
            this.renderCsSelcetion = true;
            this.renderProdSelection = true;
            this.renderOrderId = true;
        }else if(reportType == GNE_SFA2_PFG_Reports_Helper.REPORT_TYPE_LOT_EXPIRATION){
            this.renderLotExp = true;
            this.renderProdSelection = true;
            this.renderLotSelection = true;
        }else if(reportType == GNE_SFA2_PFG_Reports_Helper.REPORT_TYPE_QTY_LMT_CHG_HISTORY){
            this.renderYearsSelection = true;
            this.renderProdSelection = true;
            this.renderHcpSelection = true;
            this.isProductSelectionRequired = true;
            this.isYearPicklistRequired = true;
        }else if(reportType == GNE_SFA2_PFG_Reports_Helper.REPORT_TYPE_QTY_LMT_CHG_HISTORY_DTP){
            this.renderYearsSelection = true;
            this.renderProdSelection = true;
            this.renderHcpSelection = true;
            this.isProductSelectionRequired = true;
            this.isYearPicklistRequired = true;
        }else if(reportType == GNE_SFA2_PFG_Reports_Helper.REPORT_TYPE_RETURNS){
            this.renderCsSelcetion = true;
            this.renderDateRangeSelection = true;
            this.renderProdSelection = true;
            this.renderLotSelection = true;
        }else if(reportType == GNE_SFA2_PFG_Reports_Helper.REPORT_TYPE_UNACKNOWLEDGED_SHIPMENTS){
            this.renderDateField = true;
            this.renderCsSelcetion = true;
            this.renderShipmentSelection = true;
            this.renderOrderIdSelection = true;
        }else if(reportType == GNE_SFA2_PFG_Reports_Helper.REPORT_TYPE_DTP_EXCEPTION){
        	this.renderDateField = true;
        	this.renderProdSelection = true;
        	this.renderHcpSelection = true;
        	this.renderOrderId = true;
        }else if(reportType == GNE_SFA2_PFG_Reports_Helper.REPORT_TYPE_OUTSTANDING_AOC){
        	this.renderProdSelection = true;
        	this.renderHcpSelection = true;
        	this.renderLotSelection = true;
        	this.renderCsSelcetion = true;
        }else if(reportType == 'Select Report'){
            this.renderCsSelcetion = false;
            this.renderDateRangeSelection = false;
            this.renderProdSelection = false;
            this.renderLotSelection = false;
        }
        return null;
    }

    public void sortResults(){
        SuperSort.sortList(this.reportRows, sortField, sortDirection);
    }

    public String sortExpression{
        get{
            return sortField;
        }
        set{
            //if the column is clicked on then switch between Ascending and Descending modes
           if (value == sortField) {
                sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
           } else {
                    sortDirection = 'ASC';
           }
           sortField = value;
        }
    }

    public String getSortDirection(){
        //if no column is selected
            if (sortExpression == null || sortExpression == '') {
                return 'ASC';
            } else {
                return sortDirection;
            }
    }

    public void setSortDirection(String value){
        sortDirection = value;
    }

    @RemoteAction
    public static List<GNE_SFA2_PFG_Reports_Helper.WrappedCS>searchCSs(String searchString, Integer recordLimit){
        return GNE_SFA2_PFG_Reports_Helper.searchForCSs(searchString, recordLimit);
    }

    @RemoteAction
    public static List<GNE_SFA2_PFG_Reports_Helper.WrappedProduct> searchProducts(String searchString, Integer recordLimit, String distMethod){
        return GNE_SFA2_PFG_Reports_Helper.searchForProducts(searchString, recordLimit, distMethod);
    }
    @RemoteAction
    public static List<GNE_SFA2_PFG_Reports_Helper.WrappedLot> searchLots(String searchString, Integer recordLimit, String distMethod){
        return GNE_SFA2_PFG_Reports_Helper.searchForLots(searchString, recordLimit, distMethod);
    }

    @RemoteAction
    public static List<GNE_SFA2_PFG_Reports_Helper.WrappedAccount> searchAccounts(String searchString, Integer recordLimit, Boolean searchById, Boolean searchByName, Boolean searchByMDM){
        return GNE_SFA2_PFG_Reports_Helper.searchForHCPs(searchString, recordLimit, searchById, searchByName, searchByMDM);
    }
    @RemoteAction
    public static List<GNE_SFA2_PFG_Reports_Helper.WrappedShipment> searchShipments(String searchString, Integer recordLimit){
        return GNE_SFA2_PFG_Reports_Helper.searchForShipmentId(searchString, recordLimit);
    }

    @RemoteAction
    public static List<GNE_SFA2_PFG_Reports_Helper.WrappedOrder> searchOrders(String searchString, Integer recordLimit){
        return GNE_SFA2_PFG_Reports_Helper.searchForOrderId(searchString, recordLimit);
    }

    public PageReference addCSs() {
        PageReference result = null;
        try {
            result = intAddCSs();
        } catch(Exception ex) {
            result = GNE_SFA2_PFG_Base_Controller.setErrorPageReference(ex);
        }

        return result;
    }

    private PageReference intAddCSs(){
        List<GNE_SFA2_PFG_Reports_Helper.WrappedCS> selectedCSs = (List<GNE_SFA2_PFG_Reports_Helper.WrappedCS>)JSON.deserialize(selectedCSsJSON, List<GNE_SFA2_PFG_Reports_Helper.WrappedCS>.class);
        for(GNE_SFA2_PFG_Reports_Helper.WrappedCS wrapper : selectedCSs){
            if(!isCSAlreadyAdded(wrapper.userId)){
                this.filteredCSc.put(csIdx, new WrappedCSResult(wrapper));
                this.csIds.add(wrapper.userId);
                csIdx++;
            }
        }
        this.csElementsCount = this.csIds.size();
        return null;
    }

    public PageReference addProducts() {
        PageReference result = null;
        try {
            result = intAddProducts();
        } catch(Exception ex) {
            result = GNE_SFA2_PFG_Base_Controller.setErrorPageReference(ex);
        }

        return result;
    }

    private PageReference intAddProducts(){
        List<GNE_SFA2_PFG_Reports_Helper.WrappedProduct> selectedProducts = (List<GNE_SFA2_PFG_Reports_Helper.WrappedProduct>)JSON.deserialize(selectedProductsJSON, List<GNE_SFA2_PFG_Reports_Helper.WrappedProduct>.class);
        for(GNE_SFA2_PFG_Reports_Helper.WrappedProduct wrapper : selectedProducts){
            if(!isProductAlreadyAdded(wrapper.prodId)){
                this.filteredProducts.put(prodIdx, new WrappedProductResult(wrapper));
                this.prodIds.add(wrapper.prodId);
                prodIdx++;
            }
        }
        this.prodElementsCount = this.prodIds.size();
        return null;
    }

    public PageReference addLots() {
        PageReference result = null;
        try {
            result = intAddLots();
        } catch(Exception ex) {
            result = GNE_SFA2_PFG_Base_Controller.setErrorPageReference(ex);
        }

        return result;
    }

    private PageReference intAddLots(){
        List<GNE_SFA2_PFG_Reports_Helper.WrappedLot> selectedLots = (List<GNE_SFA2_PFG_Reports_Helper.WrappedLot>)JSON.deserialize(selectedLotsJSON, List<GNE_SFA2_PFG_Reports_Helper.WrappedLot>.class);
        for(GNE_SFA2_PFG_Reports_Helper.WrappedLot wrapper : selectedLots){
            if(!isLotAlreadyAdded(wrapper.lotId)){
                this.filteredLots.put(lotIdx, new WrappedLotResult(wrapper));
                this.lotNOs.add(wrapper.lotName);
                lotIdx++;
            }
        }
        this.lotElementsCount = this.lotNOs.size();
        return null;
    }

    public PageReference addAccounts() {
        PageReference result = null;
        try {
            result = intAddAccounts();
        } catch(Exception ex) {
            result = GNE_SFA2_PFG_Base_Controller.setErrorPageReference(ex);
        }

        return result;
    }

    private PageReference intAddAccounts(){
        List<GNE_SFA2_PFG_Reports_Helper.WrappedAccount> selectedAccounts = (List<GNE_SFA2_PFG_Reports_Helper.WrappedAccount>)JSON.deserialize(selectedAccsJSON, List<GNE_SFA2_PFG_Reports_Helper.WrappedAccount>.class);
        for(GNE_SFA2_PFG_Reports_Helper.WrappedAccount wrapper : selectedAccounts){
            if(!isAccountAlreadyAdded(wrapper.accId)){
                this.filteredAccounts.put(accIdx, new WrappedAccResult(wrapper));
                this.accIds.add(wrapper.accId);
                accIdx++;
            }
        }
        this.accElementsCount = this.accIds.size();
        return null;
    }

    public PageReference addShipments() {
        PageReference result = null;
        try {
            result = intAddShipments();
        } catch(Exception ex) {
            result = GNE_SFA2_PFG_Base_Controller.setErrorPageReference(ex);
        }

        return result;
    }

    private PageReference intAddShipments(){
        List<GNE_SFA2_PFG_Reports_Helper.WrappedShipment> selectedShipments = (List<GNE_SFA2_PFG_Reports_Helper.WrappedShipment>)JSON.deserialize(selectedShpJSON, List<GNE_SFA2_PFG_Reports_Helper.WrappedShipment>.class);
        for(GNE_SFA2_PFG_Reports_Helper.WrappedShipment wrapper : selectedShipments){
            if(!isShipmentAlreadyAdded(wrapper.shipmentId)){
                this.filteredShipments.put(shpIdx, new WrappedShipmentResult(wrapper));
                this.shpntIds.add(wrapper.shipmentId);
                shpIdx++;
            }
        }
        this.shpntElementsCount = this.shpntIds.size();
        return null;
    }

    public PageReference addOrders() {
        PageReference result = null;
        try {
            result = intAddOrders();
        } catch(Exception ex) {
            result = GNE_SFA2_PFG_Base_Controller.setErrorPageReference(ex);
        }

        return result;
    }

    private PageReference intAddOrders(){
        List<GNE_SFA2_PFG_Reports_Helper.WrappedOrder> selectedOrders = (List<GNE_SFA2_PFG_Reports_Helper.WrappedOrder>)JSON.deserialize(selectedOrdJSON, List<GNE_SFA2_PFG_Reports_Helper.WrappedOrder>.class);
        for(GNE_SFA2_PFG_Reports_Helper.WrappedOrder wrapper : selectedOrders){
            if(!isOrderAlreadyAdded(wrapper.orderId)){
                this.filteredOrders.put(ordIdx, new WrappedOrderResult(wrapper));
                this.orderIds.add(wrapper.orderId);
                ordIdx++;
            }
        }
        this.orderElementsCount = this.orderIds.size();
        return null;
    }

    public PageReference removeCS() {
        PageReference result = null;
        try {
            result = intRemoveCS();
        } catch(Exception ex) {
            result = GNE_SFA2_PFG_Base_Controller.setErrorPageReference(ex);
        }

        return result;
    }

    private PageReference intRemoveCS(){
        this.csIds.remove(this.filteredCSc.get(this.csIndex).csUser.userId);
        this.filteredCSc.remove(this.csIndex);
        csIdx--;
        this.csElementsCount = this.csIds.size();
        return null;
    }

    public PageReference removeProduct() {
        PageReference result = null;
        try {
            result = intRemoveProduct();
        } catch(Exception ex) {
            result = GNE_SFA2_PFG_Base_Controller.setErrorPageReference(ex);
        }

        return result;
    }

    private PageReference intRemoveProduct(){
        this.prodIds.remove(this.filteredProducts.get(this.prodIndex).product.prodId);
        this.filteredProducts.remove(this.prodIndex);
        prodIdx--;
        this.prodElementsCount = this.prodIds.size();
        return null;
    }

    public PageReference removeLot() {
        PageReference result = null;
        try {
            result = intRemoveLot();
        } catch(Exception ex) {
            result = GNE_SFA2_PFG_Base_Controller.setErrorPageReference(ex);
        }

        return result;
    }

    private PageReference intRemoveLot(){
    	system.debug('this.lotIndex='+this.lotIndex);
    	system.debug('this.lotNOs='+this.lotNOs);
    	system.debug('this.lotNOs='+this.lotNOs);
        this.lotNOs.remove(this.filteredLots.get(this.lotIndex).lotCatalog.lotName);
        this.filteredLots.remove(this.lotIndex);
        lotIdx--;
        this.lotElementsCount = this.lotNOs.size();
        return null;
    }

    public PageReference removeAcc() {
        PageReference result = null;
        try {
            result = intRemoveAcc();
        } catch(Exception ex) {
            result = GNE_SFA2_PFG_Base_Controller.setErrorPageReference(ex);
        }

        return result;
    }

    private PageReference intRemoveAcc(){
        this.accIds.remove(this.filteredAccounts.get(this.accIndex).hcpAccount.accId);
        this.filteredAccounts.remove(this.accIndex);
        accIdx--;
        this.accElementsCount = this.accIds.size();
        return null;
    }

    public PageReference removeShipment() {
        PageReference result = null;
        try {
            result = intRemoveShipment();
        } catch(Exception ex) {
            result = GNE_SFA2_PFG_Base_Controller.setErrorPageReference(ex);
        }

        return result;
    }

    private PageReference intRemoveShipment(){
        this.shpntIds.remove(this.filteredShipments.get(this.shpntIndex).shipment.shipmentId);
        this.filteredShipments.remove(this.shpntIndex);
        shpIdx--;
        this.shpntElementsCount = this.shpntIds.size();
        return null;
    }

    public PageReference removeOrder() {
        PageReference result = null;
        try {
            result = intRemoveOrder();
        } catch(Exception ex) {
            result = GNE_SFA2_PFG_Base_Controller.setErrorPageReference(ex);
        }

        return result;
    }

    private PageReference intRemoveOrder(){
        this.orderIds.remove(this.filteredOrders.get(this.orderIndex).pfgOrder.orderId);
        this.filteredOrders.remove(this.orderIndex);
        ordIdx--;
        this.orderElementsCount = this.orderIds.size();
        return null;
    }

    public PageReference removeAllCSs() {
        PageReference result = null;
        try {
            result = intRemoveAllCSs();
        } catch(Exception ex) {
            result = GNE_SFA2_PFG_Base_Controller.setErrorPageReference(ex);
        }

        return result;
    }

    private PageReference intRemoveAllCSs(){
        this.csIds.clear();
        this.filteredCSc.clear();
        this.csElementsCount = 0;
        csIdx = 0;
        return null;
    }

    public PageReference removeAllProducts() {
        PageReference result = null;
        try {
            result = intRemoveAllProducts();
        } catch(Exception ex) {
            result = GNE_SFA2_PFG_Base_Controller.setErrorPageReference(ex);
        }

        return result;
    }

    private PageReference intRemoveAllProducts(){
        this.prodIds.clear();
        this.filteredProducts.clear();
        this.prodElementsCount = 0;
        prodIdx = 0;
        return null;
    }

    public PageReference removeAllLots() {
        PageReference result = null;
        try {
            result = intRemoveAllLots();
        } catch(Exception ex) {
            result = GNE_SFA2_PFG_Base_Controller.setErrorPageReference(ex);
        }

        return result;
    }

    private PageReference intRemoveAllLots(){
        this.lotNOs.clear();
        this.filteredLots.clear();
        this.lotElementsCount = 0;
        lotIdx = 0;
        return null;
    }

    public PageReference removeAllAccounts() {
        PageReference result = null;
        try {
            result = intRemoveAllAccounts();
        } catch(Exception ex) {
            result = GNE_SFA2_PFG_Base_Controller.setErrorPageReference(ex);
        }

        return result;
    }

    private PageReference intRemoveAllAccounts(){
        this.accIds.clear();
        this.filteredAccounts.clear();
        this.accElementsCount = 0;
        accIdx = 0;
        return null;
    }

    public PageReference removeAllShipments() {
        PageReference result = null;
        try {
            result = intRemoveAllShipments();
        } catch(Exception ex) {
            result = GNE_SFA2_PFG_Base_Controller.setErrorPageReference(ex);
        }

        return result;
    }

    private PageReference intRemoveAllShipments(){
        this.shpntIds.clear();
        this.filteredShipments.clear();
        this.shpntElementsCount = 0;
        shpIdx = 0;
        return null;
    }

    public PageReference removeAllOrders() {
        PageReference result = null;
        try {
            result = intRemoveAllOrders();
        } catch(Exception ex) {
            result = GNE_SFA2_PFG_Base_Controller.setErrorPageReference(ex);
        }

        return result;
    }

    private PageReference intRemoveAllOrders(){
        this.orderIds.clear();
        this.filteredOrders.clear();
        this.orderElementsCount = 0;
        ordIdx = 0;
        return null;
    }

    private Boolean isCSAlreadyAdded(Id csId){
      for(WrappedCSResult rWrapper: this.filteredCSc.values()){
        if(rWrapper.csUser.userId == csId){
            return true;
        }
      }
      return false;
    }

    private Boolean isProductAlreadyAdded(Id prodId){
        for(WrappedProductResult rWrapper : this.filteredProducts.values()){
            if(rWrapper.product.prodId == prodId){
                return true;
            }
        }
        return false;
    }

    private Boolean isLotAlreadyAdded(Id lotId){
        for(WrappedLotResult rWrapper : this.filteredLots.values()){
            if(rWrapper.lotCatalog.lotId == lotId){
                return true;
            }
        }
        return false;
    }

    private Boolean isAccountAlreadyAdded(Id accId){
        for(WrappedAccResult rWrapper : this.filteredAccounts.values()){
            if(rWrapper.hcpAccount.accId == accId){
                return true;
            }
        }
        return false;
    }

    private Boolean isShipmentAlreadyAdded(String shpntId){
        for(WrappedShipmentResult rWrapper : this.filteredShipments.values()){
            if(rWrapper.shipment.shipmentId == shpntId){
                return true;
            }
        }
        return false;
    }

    private Boolean isOrderAlreadyAdded(String orderId){
        for(WrappedOrderResult rWrapper : this.filteredOrders.values()){
            if(rWrapper.pfgOrder.orderId == orderId){
                return true;
            }
        }
        return false;
    }

    //Wrapp CS data
    public class WrappedCSResult{
        public GNE_SFA2_PFG_Reports_Helper.WrappedCS csUser {get;set;}
        public Integer uIndex {get;set;}

        public WrappedCSResult(GNE_SFA2_PFG_Reports_Helper.WrappedCS user){
            this.csUser = user;
        }
    }

    //Wrap Product data
    public class WrappedProductResult{
        public GNE_SFA2_PFG_Reports_Helper.WrappedProduct product {get;set;}
        public WrappedProductResult(GNE_SFA2_PFG_Reports_Helper.WrappedProduct pfgProduct){
            this.product = pfgProduct;
        }
    }

    //Wrap Lot Data
    public class WrappedLotResult{
        public GNE_SFA2_PFG_Reports_Helper.WrappedLot lotCatalog {get;set;}
        public WrappedLotResult(GNE_SFA2_PFG_Reports_Helper.WrappedLot lotCat){
            this.lotCatalog = lotCat;
        }
    }

    //Wrap Account Data
    public class WrappedAccResult{
        public GNE_SFA2_PFG_Reports_Helper.WrappedAccount hcpAccount {get;set;}
        public WrappedAccResult(GNE_SFA2_PFG_Reports_Helper.WrappedAccount acc){
            this.hcpAccount = acc;
        }
    }

    //Wrap Shipment
    public class WrappedShipmentResult{
        public GNE_SFA2_PFG_Reports_Helper.WrappedShipment shipment {get;set;}
        public WrappedShipmentResult (GNE_SFA2_PFG_Reports_Helper.WrappedShipment shpnt){
            this.shipment = shpnt;
        }
    }

    //Wrap Order
    public class WrappedOrderResult{
        public GNE_SFA2_PFG_Reports_Helper.WrappedOrder pfgOrder {get;set;}
        public WrappedOrderResult (GNE_SFA2_PFG_Reports_Helper.WrappedOrder ord){
            this.pfgOrder = ord;
        }
    }

    //Wrapp data for Reports
    public class WrappedReportRow implements IReflection{
        public String territoryNo {get;set;}
        public String csId {get;set;}
        public String csName {get; set;}
        public String csPhone {get;set;}
        public String dmName {get;set;}
        public String ndcNumber {get;set;}
        public String productName {get;set;}
        public String lotNo {get; set;}
        public Date lotExpiration {get;set;}
        public Decimal quantity {get;set;}
        public String transactionName {get;set;}
        public Id transactionId {get;set;}
        public String transactionType {get;set;}
        public Id transactionRecordTypeId {get;set;}
        public Date transactionDate {get;set;}
        public String transactionReason {get;set;}
        public String callName {get;set;}
        public Id callId {get;set;}
        public Integer lotExpiringWithin {get;set;}
        public Id hcpId {get;set;}
        public String mdmId {get;set;}
        public String hcpName {get;set;}
        public String hcpAddress {get;set;}
        public String hcpPhone {get;set;}
        public String orderId {get;set;}
        public String orderName {get;set;}
        public String orderStatus {get;set;}
        public String shipmentId {get;set;}
        public Date shipmentDate {get;set;}
        public String changeAction {get;set;}
        public Date changeDate {get;set;}
        public String userUnix {get;set;}
        public String userName {get;set;}
        public String changeFrom {get;set;}
        public String changeTo {get;set;}

        public object getValue (String field){
            object result = null;
            if (field == 'csName'){
                result = this.csName;
            }
            else if (field == 'productName'){
                result = this.productName;
            }
            else if (field == 'lotNo'){
                result = this.lotNo;
            }
            else if(field == 'transactionDate'){
                result = this.transactionDate;
            }
            else if(field == 'lotExpiration'){
                result = this.lotExpiration;
            }
            else if(field == 'shipmentDate'){
                result = this.shipmentDate;
            }
            else if(field == 'shipmentId'){
                result = this.shipmentId;
            }
            else if(field == 'orderStatus'){
                result = this.lotExpiration;
            }
            else if(field == 'changeDate'){
                result = this.changeDate;
            }
            else if(field == 'hcpName'){
            	result = this.hcpName;
            }
            else if(field == 'hcpId'){
            	result = this.hcpId;
            }
             else if(field == 'mdmId'){
            	result = this.mdmId;
            }
            return result;
        }
    }
}