public without sharing class GNE_FCR_Detail_Controller {
	
	public FCR_Days_Plan_gne__c daysPlan {get; set;}
	
	public GNE_FCR_Detail_Controller(){
		String fcrId = ApexPages.currentPage().getParameters().get('fcrId');
		this.daysPlan = GNE_FCR_DAO.getFCR(fcrId);
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
	
	//do not remove - neded by action function
	public void saveFCRIfNeeded(){
	}
}