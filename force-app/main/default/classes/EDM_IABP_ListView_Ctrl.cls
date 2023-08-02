public with sharing class EDM_IABP_ListView_Ctrl extends GNE_SFA2_List_View_Base_Controller {
	public GNE_SFA2_List_View_Base_Controller thisController { get; set; }

	public EDM_IABP_ListView_Ctrl() {
		super('EDM_IABP_gne__c');
		thisController = this;
	}

	public String getListViewLabel(){
		try{
			List<PermissionSetAssignment> ps = [SELECT PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId= :UserInfo.getUserId()];
			List<String> psNames = new List<String>();
			for (PermissionSetAssignment p : ps) {
				psNames.add(p.PermissionSet.Name);
			}
			List<SFA2_User_Group_Mapping_gne__c> ugm = [SELECT Role_gne__c FROM SFA2_User_Group_Mapping_gne__c WHERE Application_gne__c = 'ABM' AND Permission_Set_Name_gne__c IN :psNames];
			
			List<String> roleNames = new List<String>();
			for(SFA2_User_Group_Mapping_gne__c r : ugm) {
				roleNames.add(r.Role_gne__c);
			}

			return [SELECT View_Name_gne__c FROM SFA2_View_Config_gne__c WHERE Role_gne__c IN :roleNames AND Page_Name_gne__c = :getPageName() LIMIT 1].View_Name_gne__c;
		} 
		catch(Exception e) {
			System.debug('No list viewes found');
			return '';
		}
	}

	public String getPageName() {
		return 'Individual Advisory Board Plans';
	}

	public String getAdditionalConditionForViews() {
		return ' EDM_Historical_gne__c = false AND EDM_Executive_Summary_gne__c = false ';
	}
}