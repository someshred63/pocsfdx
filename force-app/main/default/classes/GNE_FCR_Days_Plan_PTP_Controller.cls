public with sharing class GNE_FCR_Days_Plan_PTP_Controller {
	
	public FCR_PTP_Summary_gne__c ptpSummary {get; set;}
	public Boolean isEditMode {get; set;}
	
	public GNE_FCR_Days_Plan_PTP_Controller(){
		isEditMode = false;
		List<FCR_PTP_Summary_gne__c>ptps = [SELECT id, Notes_gne__c FROM FCR_PTP_Summary_gne__c WHERE CreatedById=:UserInfo.getUserId()];
		if(ptps.isEmpty()){
			ptpSummary = new FCR_PTP_Summary_gne__c(Notes_gne__c='');
		}else{
			ptpSummary = ptps.get(0);
		}
	}
	
	public PageReference save(){
		isEditMode = false;
		upsert ptpSummary;
		return null;
	}
	
	public PageReference edit(){
		isEditMode = true;
		return null;
	}
	
	public PageReference cancel(){
		isEditMode = false;
		return null;
	}
	
	
}