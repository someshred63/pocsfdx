global with sharing virtual class CFAR_TrialReport_Model {
	public static final Integer BUDGET_YEARS_LIMIT = 4;
	public SearchData searchData {get; set;}

	public CFAR_TrialReport_Model() {
		searchData = new SearchData();
	}


	public class SearchData {
		public String studyNr {get; set;}
		public String ctms {get; set;}
		public String wbs {get; set;}
		public List<String> products {get; set;}
		public List<String> therapeuticAreas {get; set;}
		public List<String> indications {get; set;}
		public List<String> trialTypes {get; set;}
		public List<String> studyStatuses {get; set;}
		public List<String> subjectTypes {get; set;}
		public List<String> pediatricStudies {get; set;}
		public List<String> specIndications {get; set;}
		public List<String> impacts {get; set;}
		public List<String> SRTs {get; set;}
		public List<String> teamMember {get; set;}
		public List<String> GNEs {get; set;}
		public List<String> inclusiveResearch {get; set;}

		public SearchData(){
			products = new List<String>();
			therapeuticAreas = new List<String>();
			indications = new List<String>();
			trialTypes = new List<String>();
			studyStatuses = new List<String>();
			subjectTypes = new List<String>();
			pediatricStudies = new List<String>();
			specIndications = new List<String>();
			impacts = new List<String>();
			SRTs = new List<String>();
			teamMember = new List<String>();
			GNEs = new List<String>();
			inclusiveResearch = new List<String>();
		}

		public void fillSearchData(String studyNr, List<String> products, List<String> therapeuticAreas, List<String> indications,
			List<String> trialTypes, List<String> studyStatuses, List<String> subjectTypes, List<String> pediatricStudies,
			List<String> specIndications, List<String> impacts, List<String> SRTs, List<String> teamMember, List<String> GNEs, List<String> inclusiveResearch) {
			this.studyNr = studyNr;
			this.products = products;
			this.therapeuticAreas = therapeuticAreas;
			this.indications = indications;
			this.trialTypes = trialTypes;
			this.studyStatuses = studyStatuses;
			this.subjectTypes = subjectTypes;
			this.pediatricStudies = pediatricStudies;
			this.specIndications = specIndications;
			this.impacts = impacts;
			this.SRTs = SRTs;
			this.teamMember = teamMember;
			this.GNEs = GNEs;
			this.inclusiveResearch = inclusiveResearch;

		}
	}

	public SearchData getSearchParameters() {
		return searchData;
	}

	public void fillSearchData(String studyNr, List<String> products, List<String> therapeuticAreas, List<String> indications,
			List<String> trialTypes, List<String> studyStatuses, List<String> subjectTypes, List<String> pediatricStudies,
			List<String> specIndications, List<String> impacts, List<String> SRTs, List<String> teamMember, List<String> GNEs, List<String> inclusiveResearch) {
		searchData.fillSearchData(studyNr, products, therapeuticAreas, indications, trialTypes, studyStatuses, subjectTypes, pediatricStudies,
		specIndications, impacts, SRTs, teamMember, GNEs, inclusiveResearch);
	}

	global class SingleFilter {
		public String id {get; set;}
		public String name {get; set;}
		public String studyNr {get; set;}
		public String ctms {get; set;}
		public String wbs {get; set;}
		public List<String> products {get; set;}
		public List<String> indications {get; set;}
		public List<String> therapeuticAreas {get; set;}
		public List<String> trialTypes {get; set;}
		public List<String> trialStatuses {get; set;}
		public List<String> subjectTypes  {get; set;}
		public List<String> pediatricStudies {get; set;}
		public List<String> SRTs {get; set;}
		public List<String> specificIndications {get; set;}
		public List<String> teamMembers {get; set;}
		public List<String> GNESupports {get; set;}
		public List<String> impacts {get; set;}
		public List<String> inclusiveResearch {get; set;}


		public SingleFilter() {
			this.products = new List<String>();
			this.indications = new List<String>();
			this.trialTypes = new List<String>();
			this.therapeuticAreas = new List<String>();
			this.trialStatuses = new List<String>();
			this.subjectTypes  = new List<String>();
			this.pediatricStudies = new List<String>();
			this.SRTs = new List<String>();
			this.specificIndications = new List<String>();
			this.teamMembers = new List<String>();
			this.GNESupports = new List<String>();
			this.impacts = new List<String>();
			this.inclusiveResearch = new List<String>();
		}

	}

	global class FilterData {
    	public List<IdNameWrapper> products {get; set;}
    	public List<IdNameWrapper> indications {get; set;}
    	public List<IdNameWrapper> therapeuticAreas {get; set;}
    	public List<IdNameWrapper> trialTypes {get; set;}
    	public List<IdNameWrapper> trialStatuses {get; set;}
		public List<IdNameWrapper> SRTs {get; set;}
		public List<IdNameWrapper> specificIndications {get; set;}
		public List<IdNameWrapper> teamMembers {get; set;}
		public List<IdNameWrapper> GNESupports {get; set;}
		public List<String> pediatricStudies {get; set;}
		public List<String> subjectTypes {get; set;}
		public List<String> impacts {get; set;}
		public List<String> inclusiveResearch {get; set;}



		public FilterData() {
    		this.products = new List<IdNameWrapper>();
    		this.indications = new List<IdNameWrapper>();
    		this.therapeuticAreas = new List<IdNameWrapper>();
    		this.trialTypes = new List<IdNameWrapper>();
    		this.trialStatuses = new List<IdNameWrapper>();
    		this.subjectTypes = new List<String>();
    		this.pediatricStudies = new List<String>();
			this.SRTs = new List<IdNameWrapper>();
			this.specificIndications = new List<IdNameWrapper>();
			this.teamMembers = new List<IdNameWrapper>();
			this.GNESupports = new List<IdNameWrapper>();
			this.impacts = new List<String>();
			this.inclusiveResearch = new List<String>();
    	}
    }

    global class TableTabData {
    	public List<String> msls {get; set;}
    	public List<String> indications {get; set;}
    	public List<String> statuses {get; set;}

    	public TableTabData() {
    		msls = new List<String>();
 			indications = new List<String>();
 			statuses = new List<String>();
    	}
    }

    global class ProgramSummaryTabData {
    	public String Status {get; set;}
    	public List<CountData> statusData {get; set;}
    	public Integer statusTotalCount  {get; set;}
    	public List<CountData> indicationData  {get; set;}
    	public Integer indicationTotalCount  {get; set;}
    	public List<TrialData> trials  {get; set;}

    	public ProgramSummaryTabData() {
    		statusData = new List<CountData>();
    		statusTotalCount = 0;
    		indicationData = new List<CountData>();
    		indicationTotalCount = 0;
    		trials = new List<TrialData>();
    	}
    }

    global class InfrepTabData {
    	public List<InfrepData> infreps {get; set;}

    	public InfrepTabData() {
    		infreps = new List<InfrepData>();
    	}
    }
	global class BOMTabData {
		public List<BOMData> boms {get; set;}

		public BOMTabData() {
			boms = new List<BOMData>();
		}
	}

	global class BOMData {
		public String ctmsNumber {get; set;}
		public String themeNumber {get; set;}
		public String studyTitle {get; set;}
		public String BiomarkerSamplesCollected {get; set;}
		public String BOMDescription {get; set;}
		public String patSubPop {get; set;}
		public String typeOfSample {get; set;}
		public String BOM {get; set;}
		public String CSM {get; set;}
	}

    global class InfrepData {
    	public String trialNumber {get; set;}
		public String medicalUnit {get; set;}
		public String protocolNumber {get; set;}
		public String ctmsNumber {get; set;}
		public String productName {get; set;}
		public String investigatorSponsorName {get; set;}
		public String sponsorContactInformation {get; set;}
		public String briefTitle {get; set;}
		public String institutionName {get; set;}
		public String otherStudyName {get; set;}
		public String MSL {get; set;}
		public String trialStatus {get; set;}
		public String primaryIndication {get; set;}
		public String specificIndication {get; set;}
		public String protocolTitle {get; set;}
		public String gneAgents {get; set;}
		public String otherAgents {get; set;}
		public String regimen {get; set;}
		public Decimal sampleSize {get; set;}
		public Decimal totalEnrolled {get; set;}
		public String proposalApproved {get; set;}
		public String draftProtocolApproved {get; set;}
		//public String imlApproved {get; set;}
		public String srrtProtocolApproved {get; set;}
		public String tracProtocolApproved {get; set;}
		public String activationPlanned {get; set;}
		public String activationActual {get; set;}
		public String fpiPlanned {get; set;}
		public String fpiActual {get; set;}
		public String lpiPlanned {get; set;}
		public String lpiActual {get; set;}
		public String lpoPlanned {get; set;}
		public String lpoActual {get; set;}
		public String studyClosure {get; set;}
		public String studyClosureActual {get; set;}
		public String publicationsSymposia {get; set;}
		public String comments {get; set;}
		public String labSupport {get; set;}
		public String dose {get; set;}
		//public String priority {get; set;}
		public String trialType {get; set;}
		public String CSM {get; set;}
		public String CSA {get; set;}
		public String interventional {get; set;}
		public Map<String,Decimal> quartersOfActualDateChange {get; set;}
		//public String gmdApproved {get; set;}
		public String impact {get; set;}
		public String tiering {get; set;}
		public String srt {get; set;}
		public String msd {get; set;}
		public String srtTeam {get; set;}
		public String themeNumber {get; set;}
		public String fsrPlanned {get; set;}
		public String fsrActual {get; set;}
		public String gneSupport {get; set;}
		public String CSS {get; set;}
		public String impShipped {get; set;}

		public InfrepData(){
			trialNumber='';
			protocolNumber='';
			ctmsNumber='';
			productName='';
			investigatorSponsorName='';
			sponsorContactInformation='';
			briefTitle='';
			institutionName='';
			otherStudyName='';
			MSL='';
			trialStatus='';
			primaryIndication='';
			specificIndication='';
			protocolTitle='';
			gneAgents='';
			otherAgents='';
			regimen='';
			sampleSize=0;
			totalEnrolled=0;
			proposalApproved='';
			draftProtocolApproved='';
			srrtProtocolApproved='';
			tracProtocolApproved='';
			activationPlanned='';
			activationActual='';
			fpiPlanned='';
			fpiActual='';
			lpiPlanned='';
			lpiActual='';
			lpoPlanned='';
			lpoActual='';
			studyClosure='';
			studyClosureActual='';
			publicationsSymposia='';
			comments='';
			labSupport='';
			dose='';
			trialType = '';
			CSM = '';
			CSA = '';
			interventional = '';
			quartersOfActualDateChange = new Map<String,Decimal>{'SRT' => 0, 'Activation' => 0, 'Study Closure' => 0, 'LPI' => 0, 'LPO' => 0, 'FSR' => 0, 'FPI' => 0, 'GMD' => 0};
			impact = '';
			tiering = '';
			srt = '';
			msd = '';
			srtTeam = '';
			gneSupport = '';
		}
    }

    global class CountData {
    	public String name {get; set;}
    	public Integer size {get; set;}

    	public CountData(String n, Integer s) {
    		this.name = n;
    		this.size = s;
    	}
    }

    global class IdNameWrapper {
    	public String id {get; set;}
    	public String name {get; set;}

    	public IdNameWrapper(String id, String name) {
    		this.id = id;
    		this.name = name;
    	}
    }

    global class TrialData {
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
    }

    global class BudgetSummaryTabData {
    	public List<Budget> budgets {get; set;}
    	public Decimal totalInvoiceables {get; set;}
		public Decimal totalQ1 {get; set;}
		public Decimal totalQ2 {get; set;}
		public Decimal totalQ3 {get; set;}
		public Decimal totalQ4 {get; set;}
		public Decimal totalProjectedSpend {get; set;}
		public Decimal totalProjectedPatientAccrual {get; set;}
		public List<Integer> projectionYears {get; set;}
		public List<Projection> projectionsTotal {get; set;}

    	public BudgetSummaryTabData(Integer currentYear) {
    		this.budgets = new List<Budget>();
    		this.projectionsTotal = new List<Projection>();
    		this.totalInvoiceables = 0;
			this.totalQ1 = 0;
			this.totalQ2 = 0;
			this.totalQ3 = 0;
			this.totalQ4 = 0;
			this.totalProjectedSpend = 0;
			this.totalProjectedPatientAccrual = 0;
			this.projectionYears = new List<Integer>();
			for (Integer i=1; i<=BUDGET_YEARS_LIMIT; ++i) {
				projectionYears.add(currentYear + i);
			}
    	}
    }

    global class Budget {
    	public Integer year {get; set;}
    	public String studyNumber {get; set;}
		public String wbs {get; set;}
		public String newWbs {get; set;}
		public String investigatorSponsorName {get; set;}
		//public String piOtherStudyNumber {get; set;}
		public Decimal invoceables {get; set;}
		public Decimal q1 {get; set;}
		public Decimal q2 {get; set;}
		public Decimal q3 {get; set;}
		public Decimal q4 {get; set;}
		public Decimal projectedSpend {get; set;}
		public Decimal projectedPatientAccrual {get; set;}
		public String gStarsNo {get; set;}
    	public String trialType {get; set;}
    	public String CSM {get; set;}
    	public String CSA {get; set;}
    	public List<Projection> projections {get; set;}
    	public String ctmsNumber {get; set;}

    	public Budget() {
    		invoceables = 0;
    		q1 = 0;
    		q2 = 0;
    		q3 = 0;
    		q4 = 0;
    		projectedSpend = 0;
    		projectedPatientAccrual = 0;
    		this.projections = new List<Projection>();
    	}
    }

    global class CommentTabData {
    	public List<Comment> comments {get; set;}
    	public CommentTabData() {
    		this.comments = new List<Comment> ();
    	}
    }
    global class Comment {
    	public String protocolNumber {get; set;}
    	public String ctmsNumber {get; set;}
    	public String trialNumber {get; set;}
    	public String product {get; set;}
    	public String trialType {get; set;}
    	public String trialStatus {get; set;}
    	public String investigator {get; set;}
    	public String institution {get; set;}
    	public String sponsorContactInformation {get; set;}
    	public String activityDate {get; set;}
    	public String createdBy {get; set;}
    	public String commentText {get; set;}
    }
    global class Projection {
    	public Integer year {get; set;}
		public Decimal projectedSpend {get; set;}
		public Decimal projectedPatientAccrual {get; set;}

		public Projection(Integer year, Decimal projectedSpend, Decimal projectedPatientAccrual) {
			this.year = year;
			this.projectedSpend = projectedSpend == null ? 0 : projectedSpend;
			this.projectedPatientAccrual = projectedPatientAccrual == null ? 0 : projectedPatientAccrual;
		}
    }

    global class AccrualSummaryTabData {
    	public List<Accrual> accruals {get; set;}

    	public AccrualSummaryTabData() {
    		this.accruals = new List<Accrual>();
    	}
    }


    global class Accrual {
		public String sfdcName {get; set;}
		public String studyNo {get; set;}
		public String wbs {get; set;}
		public String newWbs {get; set;}
		public String po {get; set;}
		public String investigator {get; set;}
		public String otherStudyName {get; set;}
		public String indication {get; set;}
		public String studyStatus {get; set;}
		public String activationDate {get; set;}
		public Integer monthsActive {get; set;}
		public String fundingDrugSupport {get; set;}
		public Decimal sampleSize {get; set;}
		public Decimal totalEnrolled {get; set;}
		public Decimal monthlyAccrualRate {get; set;}
		public Integer year {get; set;}
		public Decimal costPerSubject {get; set;}
		public Decimal invoiceables {get; set;}
		public Decimal totalStudyBudget {get; set;}
		public Decimal totalAmountPaidAsOfOctober2012 {get; set;}
		public Decimal totalAmountPaid {get; set;}
		public Decimal contractBalance {get; set;}
		public Decimal patientAccrual {get; set;}
		public Decimal projectedInvoiceables {get; set;}
		public Decimal q1ProjectedSpend {get; set;}
		public Decimal q2ProjectedSpend {get; set;}
		public Decimal q3ProjectedSpend {get; set;}
		public Decimal q4ProjectedSpend {get; set;}
		public Decimal totalProjectedSpend {get; set;}
		public String comments {get; set;}
		public Decimal enrollmentGoal {get; set;}
		public Decimal projectedEnrolled {get; set;}
    	public String trialType {get; set;}
    	public String CSM {get; set;}
    	public String CSA {get; set;}
    	public String ctmsNumber {get; set;}
    	public String memberRole {get; set;}

		public List<AccrualProjection> projections {get; set;}

		public Accrual() {
			totalStudyBudget = 0;
			totalAmountPaidAsOfOctober2012 = 0;
			totalAmountPaid = 0;
			contractBalance = 0;
			patientAccrual = 0;
			projectedInvoiceables = 0;
			q1ProjectedSpend = 0;
			q2ProjectedSpend = 0;
			q3ProjectedSpend = 0;
			q4ProjectedSpend = 0;
			totalProjectedSpend = 0;
			enrollmentGoal = 0;
			projectedEnrolled = 0;
			this.projections = new List<AccrualProjection>();
		}

    }

    global class AccrualProjection {
    	public Integer year {get; set;}
		public Decimal patientAccrual {get; set;}
		public Decimal projectedInvoiceables {get; set;}
		public Decimal totalProjectedSpend {get; set;}

		public AccrualProjection(Integer year, Decimal patientAccrual,Decimal projectedInvoiceables,Decimal totalProjectedSpend) {
			this.year = year;
			this.patientAccrual = patientAccrual;
			this.projectedInvoiceables = projectedInvoiceables;
			this.totalProjectedSpend = totalProjectedSpend;
		}

    }

    global class PaymentsTabData {
		public List<Payment> payments {get; set;}
		public List<PaymentTotal> totals {get; set;}

		public PaymentsTabData() {
			this.payments = new List<Payment>();
			this.totals = new List<PaymentTotal>();
		}
    }

    global virtual class Payment {
    	public String yearQuarter {get; set;}
		public String studyNo {get; set;}
		public String poNumber {get; set;}
		public String wbs {get; set;}
		public String newWbs {get; set;}
		public String investigator {get; set;}
		public String studyStatus  {get; set;}
		public String paymentPurpose {get; set;}
		public String datePaid {get; set;}
		public Decimal amountPaid {get; set;}
		public String referenceNumber {get; set;}
		public String gStarsNo {get; set;}
    	public String trialType {get; set;}
    	public String CSM {get; set;}
    	public String CSA {get; set;}
    	public String ctmsNumber {get; set;}
    	public String invoiceNumber {get; set;}
    	public String memberRole {get; set;}
    	public Decimal invoiceSum {get; set;}
    	public Payment() {

    	}
    }

    global class PaymentTotal {
    	public Integer year {get; set;}
		public Decimal totalPaid {get; set;}

		public PaymentTotal(Integer year, Decimal totalPaid) {
			this.year = year;
			this.totalPaid = totalPaid;
		}

    }

    global class ClosedStudiesTabData {
    	public List<ClosedStudy> closedStudies {get; set;}
    	public ClosedStudiesTabData() {
    		this.closedStudies = new List<ClosedStudy>();
    	}
    }

    global class ClosedStudy {
		public String protocolNumber {get; set;}
		public String ctmsNumber {get; set;}
		public String investigatorSponsorName {get; set;}
		public String sponsorContactInformation {get; set;}
		public String otherStudyName {get; set;}
		public String trialType {get; set;}
		public String msl {get; set;}
		public String reg {get; set;}
		public String trialStatus {get; set;}
		public String primaryIndication {get; set;}
		public String secondaryOtherIndication {get; set;}
		public String diseaseStatus {get; set;}
		public String protocolTitle {get; set;}
		public String therapyType {get; set;}
		public String gneAgents {get; set;}
		public String otherAgents {get; set;}
		public String regimen {get; set;}
		public Integer sampleSize {get; set;}
		public Integer totalEnrolled {get; set;}
		public String proposalApproval {get; set;}
		public String draftProtocolApproval {get; set;}
		public String imlApproval {get; set;}
		public String tracProtocolApproval {get; set;}
		public String activationDate {get; set;}
		public String fpiPlanned {get; set;}
		public String fpiActual {get; set;}
		public String lpiPlanned {get; set;}
		public String lpiActual {get; set;}
		public String lpoPlanned {get; set;}
		public String lpoActual {get; set;}
		public String studyClosure {get; set;}
		public String publicationsSymposia {get; set;}
		public String comments {get; set;}
		public String covanceSupport {get; set;}
		public String dose {get; set;}

    	public ClosedStudy() {

    	}

    }

	global class OperationStatus{
		String id  {get; set;}
		String name  {get; set;}
		String status {get; set;}
		String msg {get; set;}

		public OperationStatus(String id, String name, String status, String msg) {
			this.id = id;
			this.name = name;
			this.status = status;
			this.msg = msg;
		}
	}

	global class PublicationTabData {
		public List<Publication> publications {get; set;}

		public PublicationTabData() {
			this.publications = new List<Publication>();
		}
	}

	global class Publication {
		public String protocolNumber {get; set;}
		public String author {get; set;}
		public String datePlanned {get; set;}
		public String dateReceived {get; set;}
		public String datePublished {get; set;}
		public String source {get; set;}
		public String status {get;set;}
		public String reviewed {get;set;}
		public String protocolNo {get; set;}
    	public String trialType {get; set;}
    	public String CSM {get; set;}
    	public String CSA {get; set;}
    	public String ctmsNumber {get; set;}

		public Publication(String protocolNumber, String author, Date datePlanned, Date dateReceived, Date datePublished, String source, String status, Boolean reviewed, String protocolNo, String trialType, String CSM, String CSA, String ctms) {
			this.protocolNumber = protocolNumber;
			this.author = author;
			this.datePlanned = datePlanned != null ? String.valueOf(Datetime.newInstance(datePlanned.year(), datePlanned.month(), datePlanned.day()).formatGMT('MM/dd/yyyy')) : null;
			this.dateReceived = dateReceived != null ? String.valueOf(Datetime.newInstance(dateReceived.year(), dateReceived.month(),dateReceived.day()).formatGMT('MM/dd/yyyy')) : null;
			this.datePublished = datePublished != null ? String.valueOf(Datetime.newInstance(datePublished.year(), datePublished.month(),datePublished.day()).formatGMT('MM/dd/yyyy')) : null;
			this.source = source;
			this.status= status;
			this.reviewed = reviewed ? 'Yes' : 'No';
			this.protocolNo = protocolNo;
			this.trialType = trialType;
			this.CSM = CSM;
			this.CSA = CSA;
			this.ctmsNumber = ctms;
		}
	}
}