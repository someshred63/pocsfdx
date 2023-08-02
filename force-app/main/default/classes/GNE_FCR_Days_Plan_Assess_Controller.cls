public with sharing class GNE_FCR_Days_Plan_Assess_Controller {
	
	public FCR_DaysPlan_Job_Competency_gne__c jobCompetency {get; set;}
	public List<FCR_Daysplan_Job_Accountability_gne__c> daysplanJobAccountabilities {get; set;}
		
	public FCR_Days_Plan_gne__c fcr {get; private set;}
	public String selectedTab {get; set;}
	public Boolean isAssessDone {get; private set;}
	
	private static final String GIO_SALES_COMP_DOC_NAME = 'GIO_Sales_Competencies';
	public GNE_FCR_Util.FCRDocument gioSalesCompDoc { get; private set; }
	
	public GNE_FCR_Days_Plan_Assess_Controller(){
		String fcrId = ApexPages.currentPage().getParameters().get('fcrId');
		fcr = GNE_FCR_DAO.getFCR(fcrId);
		try{
			List<FCR_DaysPlan_Job_Competency_gne__c> planComments = GNE_FCR_DAO.getDaysPlanJobCompetency(fcrId);
			if(planComments.size() > 0) {
				jobCompetency = planComments[0];
			} else {
				jobCompetency = new FCR_DaysPlan_Job_Competency_gne__c(FCR_Days_Plan_gne__c=fcrId);	
			}
		} catch(Exception e){
			System.debug('An error occured while ' + e.getMessage());
		}
		selectedTab = 'tab1';
		if(ApexPages.currentPage().getParameters().containsKey('activeTab')){
			selectedTab = ApexPages.currentPage().getParameters().get('activeTab');
		}
		isAssessDone = false;
		if (fcr != null && fcr.Version_gne__c == 4){
			this.gioSalesCompDoc = initializeSalesCompDoc();
		}
	}
	
	public void initDaysplanJobAccountabilities(){		
		daysplanJobAccountabilities = GNE_FCR_DAO.getFcrJobAccountabilities(fcr.Id);
		if(daysplanJobAccountabilities.isEmpty()){
			List<FCR_Job_Accountability_gne__c>jobAccountabilities = [SELECT Id, Name, Description_gne__c, Franchise_name_gne__c, Title_gne__c, Display_Order_gne__c FROM FCR_Job_Accountability_gne__c WHERE Franchise_name_gne__c = :fcr.Franchise_Objective_gne__r.Franchise_gne__c ORDER BY Display_Order_gne__c];
			List<FCR_Daysplan_Job_Accountability_gne__c>result = new List<FCR_Daysplan_Job_Accountability_gne__c>();
			for(FCR_Job_Accountability_gne__c ja: jobAccountabilities){
				result.add(new FCR_Daysplan_Job_Accountability_gne__c(Job_Accountability_gne__c = ja.id, FCR_Days_Plan_gne__c= fcr.Id, Display_Order_fcr__c=ja.Display_Order_gne__c, Job_Accountability_Description_fcr__c = ja.Description_gne__c, Job_Accountability_Title_fcr__c=ja.Title_gne__c));
			}
			insert result;
			daysplanJobAccountabilities = GNE_FCR_DAO.getFcrJobAccountabilities(fcr.Id);
		}
	}
	
	public PageReference navigateToAssess(){
		saveFCR();
		PageReference assessPage = Page.GNE_FCR_Days_Plan_Assess;
		assessPage.getParameters().put('fcrId', fcr.Id);
		assessPage.setRedirect(true);
		return assessPage;
	}
	
	public PageReference save(){
		saveFCR();
		return null;
	}
	
	private void saveFCR(){
		upsert jobCompetency;
		upsert daysplanJobAccountabilities;
		update fcr;
	}
	
	public PageReference switchTab(){
		saveFCR();
		selectedTab  = selectedTab.equals('tab1') ? 'tab2' : 'tab1';
		PageReference assessPage = Page.GNE_FCR_Days_Plan_Assess;
		assessPage.getParameters().put('fcrId', fcr.Id);
		assessPage.getParameters().put('activeTab', selectedTab);
		assessPage.setRedirect(true);
		return assessPage;
	}
	
	public PageReference navigateToDaysPlan(){
		PageReference daysPlanPage = Page.GNE_FCR_Days_Plan;
		daysPlanPage.getParameters().put('fcrId', fcr.Id);
		daysPlanPage.setRedirect(true);
		return daysPlanPage;
	}
	
	public PageReference navigateToSummary(){
		saveFCR();
		isAssessDone = true;
		PageReference summaryPage = Page.GNE_FCR_Days_Plan_Summary;
		summaryPage.getParameters().put('fcrId', fcr.Id);
		summaryPage.setRedirect(true);
		return summaryPage;
	}
	
	private GNE_FCR_Util.FCRDocument initializeSalesCompDoc(){
		GNE_FCR_Util.FCRDocument result = null;
		List<Document> documents = [SELECT Id, Name FROM Document WHERE DeveloperName = :GIO_SALES_COMP_DOC_NAME LIMIT 1];
		if (documents.size() == 1){
			result = new GNE_FCR_Util.FCRDocument(documents[0].Id, documents[0].Name);
		}
		return result;
	}
	
	public List<SelectOption> getGatherInsightsTypes(){
		return GNE_FCR_Util.getPicklistGatherInsightsTypes(fcr.Version_gne__c, false);
	}
	
	public List<SelectOption> getIdentifyingShiftsTypes(){
		return GNE_FCR_Util.getPicklistIdentifyingShiftsTypes(fcr.Version_gne__c, false);
	}
	
	public List<SelectOption> getStrategicAccountPlanningTypes(){
		return GNE_FCR_Util.getPicklistStrategicAccountPlanningTypes(fcr.Version_gne__c, false);
	}
	
	public List<SelectOption> getCheckAssumptionsTypes(){
		return GNE_FCR_Util.getPicklistCheckAssumptionsTypes(fcr.Version_gne__c, false);
	}
	
	public List<SelectOption> getEffectiveProbingTypes(){
		return GNE_FCR_Util.getPicklistEffectiveProbingTypes(fcr.Version_gne__c, false);
	}
	
	public List<SelectOption> getReflectiveListeningTypes(){
		return GNE_FCR_Util.getPicklistReflectiveListeningTypes(fcr.Version_gne__c, false);
	}
	
	public List<SelectOption> getAligningInformationTypes(){
		return GNE_FCR_Util.getPicklistAligningInformationTypes(fcr.Version_gne__c, false);
	}
	
	public List<SelectOption> getObjectionHandlingTypes(){
		return GNE_FCR_Util.getPicklistObjectionHandlingTypes(fcr.Version_gne__c, false);
	}

	public List<SelectOption> getExecuteClosingTypes(){
		return GNE_FCR_Util.getPicklistExecuteClosingTypes(fcr.Version_gne__c, false);
	}
	
	public List<SelectOption> getJobAccountabilitiesTypes(){
		return GNE_FCR_Util.getPicklistJobAccountabilitiesTypes(fcr.Version_gne__c, false);
	}
	
}