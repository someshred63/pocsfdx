public without sharing class GNE_FCR_CompatibilityController {

	public String territoryName {get; set;}
	public FCR_Days_Plan_gne__c daysPlan {get; private set;}
    public FCR_Days_Plan_gne__c previousPlan{get; private set;}

    public GNE_FCR_CompatibilityController(){
    	String fcrId = ApexPages.currentPage().getParameters().get('fcrId');
		this.daysPlan = [SELECT Date_Field_Visit_gne__c, Field_Objectives_gne__c, Franchise_Obj_fcr__c, Previous_Action_Plan_gne__c, Previous_Action_Plan_CS_Comments__c,
											Job_Competency_gne__c, GPM_Objective_gne__c, GPM_Objective_Comments_gne__c, Status_gne__c, Other_Accounts_gne__c, Territory_gne__c, DM_Comments_gne__c,
											Territory_Name_gne__c, Summary_Comments_gne__c, FR_User_gne__c,	CS_User_gne__r.Name, Franchise_Objective_gne__r.Name, Franchise_Objective_gne__r.Franchise_gne__r.Name,
						(SELECT Account_gne__c, Account_gne__r.Name, AP_Account_gne__r.Name, AP_Account_gne__r.Address_gne__c, Territory_gne__c, Notes_gne__c FROM GNE_FCR_Junction__r),
						(SELECT Objective_gne__c, Objective_Date_gne__c, Id, SystemModstamp FROM FCR_Days_Objectives__r),
						(SELECT Description_gne__c, Name, Order_gne__c, Status_gne__c, Title_gne__c FROM GNE_FCR_Action_Item__r ORDER BY Order_gne__c),
						(SELECT Id, name, Division_Month_gne__c, Division_Quarter_gne__c, Division_Year_gne__c, Franchise_Month_gne__c, Franchise_Quarter_gne__c,
						Franchise_Year_gne__c, Product_gne__c, Product_gne__r.Name, Region_Month_gne__c, Region_Quarter_gne__c, Region_Year_gne__c, Territory_Month_gne__c,
						 Territory_Quarter_gne__c, Territory_Year_gne__c, Type_gne__c FROM FCR_PTP_gne__r)
					FROM FCR_Days_Plan_gne__c WHERE Id =: fcrId];

		if(String.isNotEmpty(daysPlan.Previous_Action_Plan_gne__c)){
			previousPlan = GNE_FCR_DAO.getPreviousDaysPlan(daysPlan.Previous_Action_Plan_gne__c);
		}
		if(daysPlan.GNE_FCR_Junction__r.size() > 0){
			Territory2 terr = [SELECT Name FROM Territory2 WHERE id = :daysPlan.GNE_FCR_Junction__r[0].Territory_gne__c];
			territoryName = terr.Name;
		}
    }

	public List<FCR_Daysplan_Job_Accountability_gne__c> getDaysplanJobAccountabilities(){
		try{
			return GNE_FCR_DAO.getFcrJobAccountabilities(daysPlan.id);
		}catch(Exception e){
			return new List<FCR_Daysplan_Job_Accountability_gne__c>();
		}
	}

	public FCR_DaysPlan_Job_Competency_gne__c getJobCompetency(){
		try{
			List<FCR_DaysPlan_Job_Competency_gne__c> planComments = GNE_FCR_DAO.getDaysPlanJobCompetency(daysPlan.id);
			if(planComments.size() > 0) {
				return planComments[0];
			} else {
				return new FCR_DaysPlan_Job_Competency_gne__c();
			}
		} catch(Exception e){
			System.debug('An error occured while ' + e.getMessage());
			return null;
		}
	}

	public PageReference validateVisibility(){
		if(GNE_FCR_Util.isUserAllowedToSeeFCR(daysPlan)){
			return null;
		}else{
			PageReference pr = Page.GNE_FCR_Error;
			pr.getParameters().put('exMessage', 'Insufficient priviliges.');
			return pr;
		}
	}

	public List<SelectOption> getGatherInsightsTypes(){
		return GNE_FCR_Util.getPicklistValues('FCR_DaysPlan_Job_Competency_gne__c', 'Assess_Gather_Insights_gne__c', false);
	}

	public List<SelectOption> getIdentifyingShiftsTypes(){
		return GNE_FCR_Util.getPicklistValues('FCR_DaysPlan_Job_Competency_gne__c', 'Assess_Identifying_Shifts_gne__c', false);
	}

	public List<SelectOption> getStrategicAccountPlanningTypes(){
		return GNE_FCR_Util.getPicklistValues('FCR_DaysPlan_Job_Competency_gne__c', 'Assess_Strategic_Account_Planning_gne__c', false);
	}

	public List<SelectOption> getCheckAssumptionsTypes(){
		return GNE_FCR_Util.getPicklistValues('FCR_DaysPlan_Job_Competency_gne__c', 'Clarify_Check_Assumptions_gne__c', false);
	}

	public List<SelectOption> getEffectiveProbingTypes(){
		return GNE_FCR_Util.getPicklistValues('FCR_DaysPlan_Job_Competency_gne__c', 'Clarify_Effective_Probing_gne__c', false);
	}

	public List<SelectOption> getReflectiveListeningTypes(){
		return GNE_FCR_Util.getPicklistValues('FCR_DaysPlan_Job_Competency_gne__c', 'Clarify_Reflective_Listening_gne__c', false);
	}

	public List<SelectOption> getAligningInformationTypes(){
		return GNE_FCR_Util.getPicklistValues('FCR_DaysPlan_Job_Competency_gne__c', 'Execute_Aligning_Information_gne__c', false);
	}

	public List<SelectOption> getObjectionHandlingTypes(){
		return GNE_FCR_Util.getPicklistValues('FCR_DaysPlan_Job_Competency_gne__c', 'Execute_Objection_Handling_gne__c', false);
	}

	public List<SelectOption> getJobAccountabilitiesTypes(){
		return GNE_FCR_Util.getPicklistValues('FCR_Daysplan_Job_Accountability_gne__c', 'Rating_gne__c', false);
	}

	//do not remove - neded by action function
	public void saveFCRIfNeeded(){
	}

}