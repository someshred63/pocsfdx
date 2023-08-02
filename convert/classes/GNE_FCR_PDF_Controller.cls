public with sharing class GNE_FCR_PDF_Controller {
	public Id fcrId{set;}
	public GNE_FCR_General_Information_Controller genInfoController;
	
	public Id getFcrId(){
		return  ApexPages.currentPage().getParameters().get('fcrId');
	}
	
	public GNE_FCR_General_Information_Controller getGenInfoController(){
		if(genInfoController==null){
			genInfoController = new GNE_FCR_General_Information_Controller();
			genInfoController.fcrDaysPlanId = getFcrId();
		}
		return genInfoController;
	}
	
	public Boolean getIsSummary(){
		if(ApexPages.currentPage().getParameters().containsKey('isSummary')){
			return Boolean.valueOf(ApexPages.currentPage().getParameters().get('isSummary'));
		}
		return false;
	}
	
	public Boolean getIsAssesment(){
		if(ApexPages.currentPage().getParameters().containsKey('isAssesment')){
			return Boolean.valueOf(ApexPages.currentPage().getParameters().get('isAssesment'));
		}
		return false;
	}
}