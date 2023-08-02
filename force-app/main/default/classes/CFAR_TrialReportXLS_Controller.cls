public with sharing class CFAR_TrialReportXLS_Controller extends CFAR_TrialReport_Model {
	
	//report metadata
	public transient String productName {get; private set;} 
	public transient String fileName {get; private set;}
	public transient String budgetFileName {get; private set;}
	
	//data part
	//public transient List<TableData> tableDataXLS {get; private set;}
	public transient ProgramSummaryTabData programSummaryXLS {get; private set;}
	public transient List<ProgSummData> progSummDataXLS {get; private set;}
	public transient InfrepTabData infrepXLS {get; private set;}
	public transient BudgetSummaryTabData budgetSummaryXLS {get; private set;}
	public transient AccrualSummaryTabData accrualsXLS {get; private set;}
    //public transient List<PaymentData> paymentDataXLS {get; private set;}
	public transient CommentTabData commentsXLS {get; private set;}
	//public transient ClosedStudiesTabData closedStudiesXLS {get; private set;}
	public transient PublicationTabData publicationXLS {get; private set;}
	public transient BOMTabData bomXLS {get; private set;}
	
	public transient Integer budgetFirstYear {get; private set;}
	
	public transient Integer accrualFirstYear {get; private set;}
	public transient List<Integer> accrualLastYears {get; private set;}
	
	//excel part
	public transient String xmlheader {get;set;}
    public transient String endfile {get;set;} 
	
	public CFAR_TrialReportXLS_Controller() {
		super();
		init();
		//VF page gives some issues directly using the below code there, so wrap up in variable
	    xmlheader ='<?xml version="1.0" encoding="UTF-8"?><?mso-application progid="Excel.Sheet"?>';
	    endfile = '</Workbook>';
    }
    
    private void init() {
    	initSearchParamsFromUlr();
    	//initTableData();
    	System.debug('-------- TIME CHECK PS START ' + Datetime.now());
		initProjectSummary();
		System.debug('-------- TIME CHECK INFREP START ' + Datetime.now());
		initInfrep();
		System.debug('-------- TIME CHECK COMMENTS START ' + Datetime.now());
		initComments();
		System.debug('-------- TIME CHECK BS START ' + Datetime.now());
		initBudgetSummary();
		System.debug('-------- TIME CHECK ACC START ' + Datetime.now());
		initAccruals();
        //System.debug('-------- TIME CHECK Payments START ' + Datetime.now());
        //initPayments();
		//initClosedStudies();
		System.debug('-------- TIME CHECK Publications START ' + Datetime.now());
		initPublications();
		initBOM();
		
		productName = '';
		if(!searchData.products.isEmpty()) {
			productName = [select Name from CFAR_Product_gne__c where Id = :searchData.products[0]].Name + ' ';
		}

		//String budgetLast = budgetLastYears.isEmpty() ? '' : String.valueOf(budgetLastYears[budgetLastYears.size()-1]);
        fileName = ((productName != '' ? productName : 'Molecule_') + 'Monthly_Report_' + String.valueOf(Date.today())
        	 //+ 'Supported_Research_Program_&_Budget_Report' 
        	 //+ (budgetFirstYear != null ? '' : ('_' + budgetFirstYear))
        	 //+ (String.isBlank(budgetLast) ? '' : ('-' + budgetLast)) 
        	 + '.xls').replaceAll(' ', '_');
		budgetFileName = ((productName != '' ? productName : 'Molecule_') + 'Budget_Accruals_Report_' + String.valueOf(Date.today()) + '.xls').replaceAll(' ', '_');
    }
	
	public String getWorkbookProperties() {
        String workbook = '<x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet><x:Name>' + fileName + '</x:Name><x:WorksheetOptions><x:DisplayGridlines/></x:WorksheetOptions></x:ExcelWorksheet></x:ExcelWorksheets></x:ExcelWorkbook>';
        return workbook;
    }
    
    /*
    public class TableData {
    	public String msl {get; private set;}
    	public String status {get; private set;}
    	public String indication {get; private set;}
    }
    
    
    public void initTableData() {
    	tableDataXLS = new List<TableData>();
    	TableTabData tableLists = CFAR_TrialReport_Controller.getTableTabData();
    	Integer mslSize = tableLists.msls.size();
    	Integer statusSize = tableLists.statuses.size();
    	Integer indicationSize = tableLists.indications.size();
    	Integer max = Math.max(Math.max(mslSize, statusSize), indicationSize);
    	
    	for(Integer i = 0; i < max; i++) {
    		TableData dataXLS = new TableData();
    		if(i < mslSize) dataXLS.msl = tableLists.msls[i];
    		if(i < statusSize) dataXLS.status = tableLists.statuses[i];
    		if(i < indicationSize) dataXLS.indication = tableLists.indications[i];
    		tableDataXLS.add(dataXLS);
    	}
    }
    */
    
    public class ProgSummData {
    	//trials
    	public String protocolNumber {get; set;}
    	public String ctmsMLNumber {get; set;}
    	public String investigatorSponsor {get; set;}
    	public String trialStatus {get; set;}
    	public String msl {get; set;}
		public String msd {get; set;}
    	public String primaryIndication {get; set;}
    	public Decimal sampleSize {get; set;}
    	public Decimal totalEnrolled {get; set;}
		public String gneSupport {get; set;}
    	//indications
    	public String name {get; set;}
    	public Integer size {get; set;}
    }
    
    public void initProjectSummary() {
    	CFAR_TrialReport_Model.SearchData data = getSearchParameters();
    	programSummaryXLS = CFAR_TrialReport_Controller.getProgramSummaryTabData(data.studyNr, data.ctms, data.wbs, data.products, 
			data.therapeuticAreas, data.indications, data.trialTypes, data.studyStatuses, data.subjectTypes, data.pediatricStudies,
			data.specIndications, data.impacts, data.SRTs, data.teamMember, data.GNEs, data.inclusiveResearch);
    	
    	progSummDataXLS = new List<ProgSummData>();
    	List<TrialData> tData = programSummaryXLS.trials;
    	List<CountData> cData = programSummaryXLS.indicationData;
    	Integer tSize = tData.size();
    	Integer cSize = cData.size();
    	Integer max = Math.max(tSize, cSize);
    	for(Integer i = 0; i < max; i++) {
    		ProgSummData dataXLS = new ProgSummData();
    		if(i < tSize) {
    			dataXLS.protocolNumber = tData[i].protocolNumber;
    			dataXLS.ctmsMLNumber = tData[i].ctmsMLNumber;
    			dataXLS.investigatorSponsor = tData[i].investigatorSponsor;
    			dataXLS.trialStatus = tData[i].trialStatus;
    			dataXLS.msl = tData[i].msl;
				dataXLS.msd = tData[i].msd;
    			dataXLS.primaryIndication = tData[i].primaryIndication;
    			dataXLS.sampleSize = tData[i].sampleSize;
    			dataXLS.totalEnrolled = tData[i].totalEnrolled;
				dataXLS.gneSupport = tData[i].gneSupport;
    		} 
    		if(i < cSize) {
    			dataXLS.name = cData[i].name;
    			dataXLS.size = cData[i].size;
    		}
    		progSummDataXLS.add(dataXLS);
    	}
    }
    
    public void initInfrep() {
    	CFAR_TrialReport_Model.SearchData data = getSearchParameters();
    	infrepXLS = CFAR_TrialReport_Controller.getInfrepTabData(data.studyNr, data.ctms, data.wbs, data.products, 
			data.therapeuticAreas, data.indications, data.trialTypes, data.studyStatuses, data.subjectTypes, data.pediatricStudies,
				data.specIndications, data.impacts, data.SRTs, data.teamMember, data.GNEs, data.inclusiveResearch);
    }
    
    public void initBudgetSummary() {
    	CFAR_TrialReport_Model.SearchData data = getSearchParameters();
    	budgetSummaryXLS = CFAR_TrialReport_Controller.getBudgetSummaryTabData(data.studyNr, data.ctms, data.wbs, data.products, 
			data.therapeuticAreas, data.indications, data.trialTypes, data.studyStatuses, data.subjectTypes, data.pediatricStudies,
				data.specIndications, data.impacts, data.SRTs, data.teamMember, data.GNEs, data.inclusiveResearch);
        budgetFirstYear = System.Today().year();
    }
    
    public void initAccruals() {
    	CFAR_TrialReport_Model.SearchData data = getSearchParameters();
    	accrualsXLS = CFAR_TrialReport_Controller.getAccrualSummaryTabData(data.studyNr, data.ctms, data.wbs, data.products, 
			data.therapeuticAreas, data.indications, data.trialTypes, data.studyStatuses, data.subjectTypes, data.pediatricStudies,
				data.specIndications, data.impacts, data.SRTs, data.teamMember, data.GNEs, data.inclusiveResearch);
    	accrualLastYears = new List<Integer>();
    	set<Integer> years = new set<Integer>();
    	accrualFirstYear = System.today().year();
    	for(Accrual a : accrualsXLS.accruals) {
    		for(AccrualProjection p : a.projections) {
    			years.add(p.year);
    		}
    	}
    	accrualLastYears.addAll(years);
    	accrualLastYears.sort();
    }
    
    /*public class PaymentData extends Payment {

		//Totals
		public Integer year {get; set;}
		public Decimal totalPaid {get; set;}
    }
    */
    /*public void initPayments() {
    	CFAR_TrialReport_Model.SearchData data = getSearchParameters();
    	PaymentsTabData paymentsXLS = CFAR_TrialReport_Controller.getPaymentTabData(data.studyNr, data.ctms, data.wbs, data.products, 
			data.therapeuticAreas, data.indications, data.trialTypes, data.studyStatuses, data.subjectTypes, data.pediatricStudies);
    	
    	paymentDataXLS = new List<PaymentData>();	
    	Integer pSize = paymentsXLS.payments.size();
    	Integer tSize = paymentsXLS.totals.size();
    	integer max = Math.max(pSize, tSize);
    	
    	for(Integer i = 0; i < max; i++) {
    		PaymentData dataXLS = new PaymentData();
    		if(i < pSize) {
    			dataXLS.yearQuarter = paymentsXLS.payments[i].yearQuarter;
    			dataXLS.studyNo = paymentsXLS.payments[i].studyNo;
    			dataXLS.poNumber = paymentsXLS.payments[i].poNumber;
    			dataXLS.investigator = paymentsXLS.payments[i].investigator;
    			dataXLS.studyStatus = paymentsXLS.payments[i].studyStatus;
    			dataXLS.paymentPurpose = paymentsXLS.payments[i].paymentPurpose;
    			dataXLS.wbs = paymentsXLS.payments[i].wbs;
    			dataXLS.newWbs = paymentsXLS.payments[i].newWbs;
    			dataXLS.datePaid = paymentsXLS.payments[i].datePaid;
    			dataXLS.amountPaid = paymentsXLS.payments[i].amountPaid;
    			dataXLS.referenceNumber = paymentsXLS.payments[i].referenceNumber;
    			dataXLS.gStarsNo = paymentsXLS.payments[i].gStarsNo;
    			dataXLS.trialType = paymentsXLS.payments[i].trialType;
    			dataXLS.CSM = paymentsXLS.payments[i].CSM;
    			dataXLS.CSA = paymentsXLS.payments[i].CSA;
    			dataXLS.ctmsNumber = paymentsXLS.payments[i].ctmsNumber;
    			dataXLS.memberRole = paymentsXLS.payments[i].memberRole;
    			dataXLS.invoiceNumber = paymentsXLS.payments[i].invoiceNumber;
    			dataXLS.invoiceSum = paymentsXLS.payments[i].invoiceSum;
    		} 
    		if(i < tSize) {
    			dataXLS.year = paymentsXLS.totals[i].year;
    			dataXLS.totalPaid = paymentsXLS.totals[i].totalPaid;
    		}
    		paymentDataXLS.add(dataXLS);
    	}
    }
    */
    /*
    public void initClosedStudies() {
    	CFAR_TrialReport_Model.SearchData data = getSearchParameters();
    	closedStudiesXLS = CFAR_TrialReport_Controller.getClosedStudiesTabData(data.studyNr, data.products, 
    		data.therapeuticAreas, data.indications, data.trialTypes, data.studyStatuses, data.subjectTypes);
    }
    */
    
    public void initPublications() {
    	CFAR_TrialReport_Model.SearchData data = getSearchParameters();
    	publicationXLS = CFAR_TrialReport_Controller.getPublicationTabData(data.studyNr, data.ctms, data.wbs, data.products, 
			data.therapeuticAreas, data.indications, data.trialTypes, data.studyStatuses, data.subjectTypes, data.pediatricStudies,
				data.specIndications, data.impacts, data.SRTs, data.teamMember, data.GNEs, data.inclusiveResearch);
    }

	public void initBOM() {
		CFAR_TrialReport_Model.SearchData data = getSearchParameters();
		bomXLS = CFAR_TrialReport_Controller.getBOMTabData(data.studyNr, data.ctms, data.wbs, data.products,
				data.therapeuticAreas, data.indications, data.trialTypes, data.studyStatuses, data.subjectTypes, data.pediatricStudies,
				data.specIndications, data.impacts, data.SRTs, data.teamMember, data.GNEs, data.inclusiveResearch);
	}
    
    private void initSearchParamsFromUlr() {
    	String indication = Apexpages.currentpage().getparameters().get('indication');
    	String product = Apexpages.currentpage().getparameters().get('product');
    	String therapeuticArea = Apexpages.currentpage().getparameters().get('therapeuticArea');
    	String studyNr = Apexpages.currentpage().getparameters().get('studyNo');
    	String trialType = Apexpages.currentpage().getparameters().get('trialType');
    	String studyStatus = Apexpages.currentpage().getparameters().get('studyStatus');
    	String subjectType = Apexpages.currentpage().getparameters().get('subjectType');
    	String wbs = Apexpages.currentpage().getparameters().get('wbs');
    	String ctms = Apexpages.currentpage().getparameters().get('ctms');
		String pediatricStudies = Apexpages.currentpage().getparameters().get('pediatricStudies');
		String specIndications = ApexPages.currentPage().getParameters().get('specificIndications');
		String impacts = ApexPages.currentPage().getParameters().get('impact');
		String SRTs = ApexPages.currentPage().getParameters().get('SRT');
		String teamMembers = ApexPages.currentPage().getParameters().get('teamMember');
		String gneSupport = ApexPages.currentPage().getParameters().get('gneSupport');
		String inclusiveResearch = ApexPages.currentPage().getParameters().get('inclusive');
    		
    	if(String.isNotBlank(indication))
    		searchData.indications.addAll(indication.split(';', -2));
    	if(String.isNotBlank(product))
    		searchData.products.addAll(product.split(';', -2));
    	if(String.isNotBlank(therapeuticArea))
    		searchData.therapeuticAreas.addAll(therapeuticArea.split(';', -2));
    	if(String.isNotBlank(studyNr))
    		searchData.studyNr = studyNr;
    	if(String.isNotBlank(trialType))
    		searchData.trialTypes.addAll(trialType.split(';', -2));
    	if(String.isNotBlank(studyStatus))
    		searchData.studyStatuses.addAll(studyStatus.split(';', -2));
    	if(String.isNotBlank(subjectType))
    		searchData.subjectTypes.addAll(subjectType.split(';', -2));	
    	if(String.isNotBlank(wbs))
    		searchData.wbs = wbs;
    	if(String.isNotBlank(ctms))
    		searchData.ctms = ctms;
		if(String.isNotBlank(pediatricStudies))
			searchData.pediatricStudies.addAll(pediatricStudies.split(';', -2));
		if (String.isNotBlank(specIndications))
			searchData.specIndications.addAll(specIndications.split(';', -2));
		if (String.isNotBlank(impacts))
			searchData.impacts.addAll(impacts.split(';', -2));
		if (String.isNotBlank(SRTs))
			searchData.SRTs.addAll(SRTs.split(';', -2));
		if (String.isNotBlank(teamMembers))
			searchData.teamMember.addAll(teamMembers.split(';', -2));
		if (String.isNotBlank(gneSupport))
			searchData.GNEs.addAll(gneSupport.split(';', -2));
		if (String.isNotBlank(inclusiveResearch))
			searchData.inclusiveResearch.addAll(inclusiveResearch.split(';', -2));
    }
    
    public void initComments() {
    	CFAR_TrialReport_Model.SearchData data = getSearchParameters();
    	commentsXLS = CFAR_TrialReport_Controller.getCommentsTabData(data.studyNr, data.ctms, data.wbs, data.products, 
			data.therapeuticAreas, data.indications, data.trialTypes, data.studyStatuses, data.subjectTypes, data.pediatricStudies,
				data.specIndications, data.impacts, data.SRTs, data.teamMember, data.GNEs, data.inclusiveResearch);
    }

}