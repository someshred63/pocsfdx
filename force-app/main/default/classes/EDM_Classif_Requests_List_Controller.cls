public with sharing class EDM_Classif_Requests_List_Controller extends GNE_SFA2_List_View_Base_Controller {
	
	public GNE_SFA2_List_View_Base_Controller thisController { get; set; }

	public EDM_Classif_Requests_List_Controller() {
		super('EDM_Classification_Request_gne__c');
		thisController = this;
	}

	public pageReference init(){
		if(!EDM_Classification_Request_gne__c.sObjectType.getDescribe().isUpdateable()){
            return GNE_SFA2_Util.redirectToAccessDeniedPage();
        }
        return null;
	}
}