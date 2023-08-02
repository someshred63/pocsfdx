public with sharing class GNE_SFA2_New_Dispatcher_Ext {
	
	private String sObjectType;
	private String sObjectKeyPrefix;
	private Map<String, String> urlParameters;
	private Boolean isCreatable;
	private String recordTypeName;
	
	public GNE_SFA2_New_Dispatcher_Ext(ApexPages.StandardController stdController){		
		sObjectType = String.valueOf(stdController.getRecord().getSObjectType());
        Schema.DescribeSObjectResult sObjectDescribe = stdController.getRecord().getSObjectType().getDescribe();
		sObjectKeyPrefix = sObjectDescribe.getKeyPrefix();
		isCreatable = sObjectDescribe.isCreateable();
		urlParameters = System.currentPageReference().getParameters().clone();
	}
	
	public PageReference doRedirect(){
		PageReference pageRef = null;
		Boolean isSFA2UiUser = GNE_SFA2_Util.isSFA2UserForUI();		
		
		if (!isCreatable){
			pageRef = isSFA2UiUser ? Page.GNE_SFA2_Access_Denied : Page.GNE_CRM_Access_Denied;			 
		} else {		
			if (sObjectType == 'Medical_Communication_gne__c'){
				if (GNE_SFA2_Util.IsBamCrmUser() || GNE_SFA2_Util.isSfaCCUser() || GNE_SFA2_Util.isCrmFrmUser() ){
					pageRef = Page.GNE_CRM_Create_MedComm_Layout;
				} else {
					pageRef = isSFA2UIUser ? Page.GNE_SFA2_Create_MedComm_Layout : getRedirectToStandardPage();
				}			
			} else {
				pageRef = getRedirectToStandardPage();
			}
		}
		
		if (pageRef != null){			
			for (String key : urlParameters.keyset()){
				pageRef.getParameters().put(key, urlParameters.get(key));
			}
			pageRef.setRedirect(true);
		}
		
		return pageRef;
	}
	
	private PageReference getRedirectToStandardPage(){		
		return new PageReference('/' + sObjectKeyPrefix + '/e?nooverride=1');
	}
}