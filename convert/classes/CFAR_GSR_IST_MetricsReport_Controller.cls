public with sharing class CFAR_GSR_IST_MetricsReport_Controller
{
	public String fileName {get;set;}
	public List<SingleItem> itemsToOperate = new List<SingleItem>();
	public List<GSR_ReportRow> reportRows {get;set;}
	private List<CFAR_Milestone_Activity_gne__c> milestoneActivities =  new List<CFAR_Milestone_Activity_gne__c>();
	private List<CFAR_Trial_gne__c> trials = new List<CFAR_Trial_gne__c>();
	private Map<Id, String> srrtMembers = new Map<Id, String>();
	private Set<Id> trialIds = new Set<Id>();
	private final static String PROPOSALS_APPROVED = 'Proposal Approval';
	private final static String PROTOCOLS_APPROVED = 'TRAC Protocol Approval';
	private final static String ACTIVATIONS = 'Activation';
	private final static String CLOUSURES = 'Study Closure';
	private final static String CHAIR_ROLE = 'SRT = Study Review Team Chair';
	private final static List<String> functionRoles = new List<String>{CHAIR_ROLE};
	private final static List<String> activityTypes =  new List<String>{PROPOSALS_APPROVED, PROTOCOLS_APPROVED, ACTIVATIONS, CLOUSURES};
	public CFAR_GSR_IST_MetricsReport_Controller()
	{
		init();
	}
	public String getWorkbookProperties()
	{
		String workbook = '<x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet><x:Name>' + 'GSR Summary Report' + '</x:Name><x:WorksheetOptions><x:DisplayGridlines/></x:WorksheetOptions></x:ExcelWorksheet></x:ExcelWorksheets></x:ExcelWorkbook>';
        return workbook;
	}
	private void init()
	{
		reportRows = new List<GSR_ReportRow>();
		this.fileName = 'GSR_Summary_Report_'+String.valueOf(Date.today());
		getMilActs();
		getCfarTrial();
		prepareItems();
		getTeamMembers();
		prepareReportRows();
	}
	private void getMilActs()
	{
		Integer currentYear = Date.today().year();
		Integer fromYear = 2010;
		Date fromDate = Date.newInstance(fromYear, 1, 1);
		Date toDate = Date.newInstance(currentYear, 12, 31);
		this.milestoneActivities = [SELECT Name, Actual_Date_gne__c, CFAR_Trial_ref_gne__c 
											FROM CFAR_Milestone_Activity_gne__c 
											WHERE Name IN: activityTypes 
											AND Actual_Date_gne__c >=: fromDate
											AND Actual_Date_gne__c <=: toDate
										  ];
		for(CFAR_Milestone_Activity_gne__c mAct : this.milestoneActivities)
		{
			this.trialIds.add(mAct.CFAR_Trial_ref_gne__c);
		}
	}
	private void getCfarTrial()
	{
		this.trials = [Select Id, Therapeutic_Area_ref_gne__r.Name, frm_Product_ref_gne__c from CFAR_Trial_gne__c where Id IN: this.trialIds];
	}
	private void getTeamMembers()
	{
		List<CFAR_Team_Member_gne__c> teamMembers = [Select CFAR_Trial_ref_gne__c, frm_Name_gne__c from CFAR_Team_Member_gne__c  where Function_Role_gne__c IN : functionRoles];
		for(CFAR_Team_Member_gne__c tM : teamMembers)
		{
			this.srrtMembers.put(tM.CFAR_Trial_ref_gne__c, tM.frm_Name_gne__c);
		}
	}
	private void prepareItems()
	{
		for(CFAR_Milestone_Activity_gne__c mA : this.milestoneActivities)
		{
			for(CFAR_Trial_gne__c trl :this.trials)
			{
				if(mA.CFAR_Trial_ref_gne__c == trl.Id)
				{
					SingleItem sItem = new SingleItem(trl.Therapeutic_Area_ref_gne__r.Name, trl.frm_Product_ref_gne__c, mA.Actual_Date_gne__c.year(), mA.Name, this.srrtMembers.get(trl.Id));
					this.itemsToOperate.add(sItem);
				}
			}
		}
	}
	private void prepareReportRows()
	{
		Map<String, GSR_ReportRow> t_map = new Map<String, GSR_ReportRow>();
		for(SingleItem si : this.itemsToOperate)
		{
			String keyString = si.cfarProduct+'_'+si.itemYear+'_'+si.therapeuticArea;
			if(!t_map.containsKey(keyString))
			{
				GSR_ReportRow rRow = new GSR_ReportRow();
				rRow.maTA = si.therapeuticArea;
				rRow.product = si.cfarProduct;
				rRow.year = String.valueOf(si.itemYear);
				rRow.srrt = si.srrtMember;
				if(si.typeOfActivity == PROPOSALS_APPROVED)
				{
					rRow.proposalsApprovedCount = 1;
				}
				if(si.typeOfActivity == PROTOCOLS_APPROVED)
				{
					rRow.protocolsApprovedCount = 1;
				}
				if(si.typeOfActivity == ACTIVATIONS)
				{
					rRow.activtionsCount = 1;
				}
				if(si.typeOfActivity == CLOUSURES)
				{
					rRow.clousuresCount = 1;
				}
				rRow.sortFormula = si.cfarProduct + si.itemYear;
				t_map.put(keyString, rRow);
			}
			else
			{
				if(si.typeOfActivity == PROPOSALS_APPROVED)
				{
					t_map.get(keyString).proposalsApprovedCount++;
				}
				if(si.typeOfActivity == PROTOCOLS_APPROVED)
				{
					t_map.get(keyString).protocolsApprovedCount++;
				}
				if(si.typeOfActivity == ACTIVATIONS)
				{
					t_map.get(keyString).activtionsCount++;
				}
				if(si.typeOfActivity == CLOUSURES)
				{
					t_map.get(keyString).clousuresCount++;
				}
			}
		}
		this.reportRows = t_map.values();
		for(GSR_ReportRow rr : this.reportRows)
		{
			rr.totalStudiesCount = rr.proposalsApprovedCount+rr.protocolsApprovedCount+rr.activtionsCount+rr.clousuresCount;
		}
		SuperSort.sortList(this.reportRows, 'sortFormula', 'ASC');
	}
	public class SingleItem
	{
		public String therapeuticArea {get;set;}
		public String cfarProduct{get;set;}
		public Integer itemYear{get;set;}
		public String typeOfActivity {get;set;}
		public String srrtMember {get;set;}

		public SingleItem(String tArea, String prod, Integer iYear, String tAct, String srrt)
		{
			this.therapeuticArea = tArea;
			this.cfarProduct = prod;
			this.itemYear = iYear;
			this.typeOfActivity = tAct;
			this.srrtMember = srrt;
		}
	}
	public class GSR_ReportRow implements IReflection
	{
		public String maTA {get;set;}
		public String srrt {get;set;}
		public String product {get;set;}
		public String year {get;set;}
		public Integer proposalsApprovedCount {get;set;}
		public Integer protocolsApprovedCount {get;set;}
		public Integer activtionsCount {get;set;}
		public Integer clousuresCount {get;set;}
		public Integer totalStudiesCount {get;set;}
		public String sortFormula {get;set;}

		public GSR_ReportRow()
		{
			this.proposalsApprovedCount = 0;
			this.protocolsApprovedCount = 0;
			this.activtionsCount = 0;
			this.clousuresCount = 0;
			this.totalStudiesCount = 0;
		}
		public object getValue(String field)
		{
			object result = null;
			if(field == 'sortFormula')
			{
				return this.sortFormula;
			}
			return result;
		}
	}	
}